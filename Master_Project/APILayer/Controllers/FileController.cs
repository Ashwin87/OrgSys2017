using System;
using DataLayer;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.IO;
using System.Web;
using Orgsys_2017.Orgsys_Classes;
using APILayer.Services;
using System.Configuration;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Files")]
    public class FileController : ApiController
    {
        private OrgSys2017DataContext context = new OrgSys2017DataContext();
        private string path = ConfigurationManager.AppSettings["DocumentDriveDirectoy"];

        [HttpPost]
        [Route("UploadClientLogo/{Token}")]
        public HttpResponseMessage UploadClientLogo(string Token)
        {

            var file = HttpContext.Current.Request.Files[0];

            if (file != null)
            {
                //prepend unique identifier to file name
                var fileName = Guid.NewGuid().ToString().Substring(0, 8) + "_" + file.FileName;
                var filePath = $@"\\OSI-DEV01\umbrella\logos\{fileName}";

                try
                {
                    file.SaveAs(filePath);

                    //update the reference to the logo in db
                    using (var context = new OrgSys2017DataContext())
                    {
                        var clientId = context.GetClientIDBySession(Token).SingleOrDefault().ClientID;
                        context.Clients.Where(c => c.ClientID == clientId).SingleOrDefault().LogoPath = fileName;

                        context.SubmitChanges();
                    }

                    return new HttpResponseMessage(HttpStatusCode.OK);
                }
                catch (Exception e)
                {
                    ExceptionLog.LogException(e);
                    return new HttpResponseMessage(HttpStatusCode.InternalServerError);
                }

            }
            else
            {
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }


        }

        [HttpPost]
        [Route("UploadClaimFiles/{token}")]
        public HttpResponseMessage UploadClaimFiles(string token, [FromBody] Document document)
        {
            try
            {
                //get session to validate user
                Session session = context.Sessions.SingleOrDefault(i => i.SessionToken == token);
                //get claim for claim data
                Claim claim = context.Claims.SingleOrDefault(i => i.ClaimID == document.ClaimID);

                //if session is null user is unauthorized
                if (session == null)
                {
                    return new HttpResponseMessage(HttpStatusCode.Unauthorized);
                }

                //if no file exist quit and retun bad request
                if (document == null)
                {
                    return new HttpResponseMessage(HttpStatusCode.BadRequest);
                }


                //generate a unique quid for filename
                string storedGuid = Guid.NewGuid().ToString();
                //create claim document record
                Claim_Document claimDocument = new Claim_Document()
                {
                    Archived = false,
                    ClaimID = document.ClaimID,
                    ClaimRefNu = claim.ClaimRefNu,
                    DocExt = document.DocExt,
                    DocName = document.DocName,
                    DocType = document.DocType,
                    DocumentDescrID = document.DocumentDescrID,
                    OrgsysClaimID = document.ClaimID,
                    StoredGuid = storedGuid,
                    Timestamp = DateTime.Now,
                    UpdateID = document.UpdateID,
                    UserID = Convert.ToInt32(session.UserID),
                    ClientID = claim.ClientID
                };
                context.Claim_Documents.InsertOnSubmit(claimDocument);
                //save the file with the unique guid
                File.WriteAllBytes(path + storedGuid, Convert.FromBase64String(document.FileBase64));

                //if file is from claim update create a record
                if (document.UpdateID != 0)
                {
                    Claim_Updates_Document updatesDocument = new Claim_Updates_Document()
                    {
                        UserID = Convert.ToInt32(session.UserID),
                        UpdateID = document.UpdateID,
                        ClaimReference = claim.ClaimRefNu,
                        DocumentID = claimDocument.DocID,
                        FileExt = document.DocExt,
                        FileName = document.DocName,
                        Timestamp = DateTime.Now
                    };
                    context.Claim_Updates_Documents.InsertOnSubmit(updatesDocument);
                }

                context.SubmitChanges();

                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent("Uploaded")
                };
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }


        //api/Files/DownloadClaimFile/:token/:documentId
        [AllowAnonymousAttribute]
        [HttpGet]
        [Route("DownloadClaimFile/{token}/{documentId}")]
        public HttpResponseMessage DownloadClaimFile(string token, int documentId)
        {
            try
            {
                using (context = new OrgSys2017DataContext())
                {
                    if (context.CheckIfTokenValid(token) != 10001)
                    {
                        return Request.CreateResponse(HttpStatusCode.Forbidden);
                    }

                    var doc = context.Claim_Documents.Where(d => d.DocID == documentId);

                    if (doc.Count() == 1)
                    {
                        string DocName = doc.Single().DocName;
                        string DocType = doc.Single().DocType;
                        string DocExt = doc.Single().DocExt;
                        string DocGuid = doc.Single().StoredGuid;

                        HttpContext httpContext = HttpContext.Current;
                        FileInfo file = new FileInfo(path + DocGuid);
                        httpContext.Response.Clear();
                        httpContext.Response.ClearHeaders();
                        httpContext.Response.AddHeader("Content-Disposition", $"attachment; filename={DocName}");
                        //httpContext.Response.AddHeader("Content-length", file.Length.ToString());
                        httpContext.Response.ContentType = DocType;
                        httpContext.Response.Flush();
                        httpContext.Response.TransmitFile(file.FullName);
                        httpContext.Response.End();
                        return Request.CreateResponse(HttpStatusCode.OK, DocName + "." + DocExt, Configuration.Formatters.JsonFormatter);
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.NotFound);
                    }
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }

        //api/Files/GetClaimFileDataForUser/:token
        [HttpGet]
        [Route("GetClaimFileDataForUser/{token}/")]
        public HttpResponseMessage GetClaimFileDataForUser(string Token)
        {
            try
            {
                using (context = new OrgSys2017DataContext())
                {
                    var filters = context.GetFilteredData(Token, "Document")?.ToList();
                    var userRoleName = context.GetUserRole(Token).FirstOrDefault().RoleName;
                    var qservice = new QueryService("Claim_Documents", "Document", Token);

                    if (filters == null && userRoleName != "OSIUser")
                        return Request.CreateResponse(HttpStatusCode.Forbidden);

                    var dataView = context.GetPortalPortalDataView(Token, "Document").ToList();
                    var query = qservice.BuildQuery(dataView, filters);
                    var con = new Connection();
                    var result = con.SelectData(query);

                    return Request.CreateResponse(HttpStatusCode.OK, result);
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }


        //api/Files/GetClaimFileDataForUser/:token
        [HttpGet]
        [Route("GetClaimFileDataForUserExternal/{token}/")]
        public HttpResponseMessage GetClaimFileDataForUserExternal(string Token)
        {
            try
            {
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonConvert.SerializeObject(context.GetClaimDocumentInfoExternal(Token)))
                };
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }




        //api/Files/Logos/:queryString
        [HttpGet]
        [Route("logos/")]
        public HttpResponseMessage Logos([FromUri]Query requestBody)
        {
            try
            {
                string logoFilePath = $@"\\OSI-DEV01\umbrella\logos\";
                string query = requestBody.queryString.Length > 0 ? $"*{requestBody.queryString}*" : "";

                var filesNames = Directory
                                .GetFiles(logoFilePath, query)
                                .Select(file => Path.GetFileName(file));


                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(filesNames));
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        public class Query
        {
            public string queryString { get; set; }
        }

        public class ClaimUpdateDocSaveDetail
        {
            public List<Claim_Document> obj_ClaimUpdateDoc { get; set; }
        }



        public class Document
        {
            public int ClaimID;
            public int UpdateID;
            public string FileBase64;
            public string DocType;
            public string DocExt;
            public string DocName;
            public int DocumentDescrID;
        }
    }
}
