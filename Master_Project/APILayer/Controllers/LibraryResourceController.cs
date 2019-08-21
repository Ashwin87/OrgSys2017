using APILayer.Models.DTOS;
using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;
using APILayer.Controllers.Auth.Authorization;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/LibraryResources")]
    public class LibraryResourceController : ApiController
    {
        /// <summary>
        /// Database Context for orgsoln umbrella
        /// </summary>
        public OrgSys2017DataContext context = new OrgSys2017DataContext();
        /// <summary>
        /// drive for claim documents and library resources
        /// </summary>
        private readonly string path = ConfigurationManager.AppSettings["DocumentDriveDirectoy"];

        /// <summary>
        /// Returns library resourced based on what the user is allowed to view. 
        /// </summary>
        /// <param name="token">Session Token</param>
        [HttpGet]
        [Route("GetLibraryResources/{token}")]
        [SwaggerResponse(HttpStatusCode.OK, null,typeof(GetLibraryResourcesResult))]
        public HttpResponseMessage GetLibraryResources(string token)
        {
            if (context.CheckIfTokenValid(token) != 10001)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(context.GetLibraryResources(token)))
            };
        }


        /// <summary>
        /// Returns the library resources for internal users to view and edit. 
        /// </summary>
        /// <param name="token">Session Token</param>
        [HttpGet]
        [OSIInternalAuthorization]
        [Route("GetLibraryResourcesInternal/{token}/{ClientID}")]
        [SwaggerResponse(HttpStatusCode.OK, null, typeof(GetLibraryResourcesResult))]
        public HttpResponseMessage GetLibraryResourcesInternal(string token, int ClientID)
        {
            if (context.CheckIfTokenValid(token) != 10001 && context.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(context.GetLibraryResourcesInternal(ClientID)))
            };
        }


        /// <summary>
        /// Returns the library resource types with theit respective ID
        /// </summary>
        [HttpGet]
        [Route("GetLibraryResourceTypes")]
        public HttpResponseMessage GetLibraryResourceTypes()
        {
            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(context.GetLibraryResourceTypes()))
            };
        }

        /// <summary>
        /// Endpoint to upload a generic library resource or a client specific resource.
        /// </summary>
        /// <param name="token"></param>
        /// <param name="resource"></param>
        [HttpPost]
        [OSIInternalAuthorization]
        [Route("UploadLibraryResource/{token}")]
        public HttpResponseMessage UploadLibraryResource(string token, [FromBody]Library_Resource_DTO resource)
        {
            
            if (context.CheckIfTokenValid(token) != 10001 && context.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }
            try
            {
                //generate a unique quid for filename
                string storedGuid = Guid.NewGuid().ToString();

                Library_Resource library_Resource = new Library_Resource {
                    DocumentName = resource.DocumentName,
                    ResourceTypeID = resource.ResourceTypeID,
                    SpecificClientID = resource.SpecificCLientID,
                    StoredGuid = storedGuid,
                    VersionNumber = resource.VersionNumber,
                    DocExt = resource.DocExt,
                    MIMEType = resource.MIMEType
                };
          
                context.Library_Resources.InsertOnSubmit(library_Resource);
                //save the file with the unique guid
                File.WriteAllBytes(path + storedGuid, Convert.FromBase64String(resource.Base64));
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

        /// <summary>
        /// Endpoint for downloading library resources
        /// </summary>
        /// <param name="token"></param>
        /// <param name="documentId"></param>
        [AllowAnonymousAttribute]
        [HttpGet]
        [Route("DownloadLibraryResource/{token}/{documentId}")]
        public HttpResponseMessage DownloadLibraryResource(string token, int documentId)
        {

            if (context.CheckIfTokenValid(token) != 10001)
            {
                return Request.CreateResponse(HttpStatusCode.Unauthorized);
            }
            try
            {
                var doc = context.Library_Resources.Single(d => d.Id == documentId);

                //if user is internal they have access to all library resources. if they are external they have access to documents that arent client specific or their own client specific documents
                if (doc.SpecificClientID != 1934 && context.IsUserInternal(token) != 1 )
                {
                    if (doc.SpecificClientID != null && doc.SpecificClientID != context.GetClientIDBySession(token).Single().ClientID)
                    {
                        return Request.CreateResponse(HttpStatusCode.Unauthorized);
                    }
                }
              

                string DocName = doc.DocumentName;
                string DocType = doc.MIMEType;
                string DocExt = doc.DocExt;
                string DocGuid = doc.StoredGuid;

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
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }

        [HttpPost]
        [Route("ArchiveLibraryResource/{token}/{DocID}")]
        public HttpResponseMessage ArchiveLibraryResource(string token, int DocID)
        {
            if(context.IsUserInternal(token) != 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }

            Library_Resource _Resource = context.Library_Resources.Single(i => i.Id == DocID);
            _Resource.IsArchived = true;
            context.SubmitChanges();
            return new HttpResponseMessage(HttpStatusCode.OK);
        }

        //TODO: Set up for admin user accounts
        //[HttpPost]
        //[Route("UnArchiveLibraryResource/{token}/{DocID}")]
        //public HttpResponseMessage UnArchiveLibraryResource(string token, int DocID)
        //{
        //    if (context.IsUserInternal(token) != 1)
        //    {
        //        return new HttpResponseMessage(HttpStatusCode.Unauthorized);
        //    }

        //    Library_Resource _Resource = context.Library_Resources.Single(i => i.Id == DocID);
        //    _Resource.IsArchived = false;
        //    context.SubmitChanges();
        //    return new HttpResponseMessage(HttpStatusCode.OK);
        //}
    }
}
