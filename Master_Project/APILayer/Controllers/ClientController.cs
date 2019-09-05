using DataLayer;
using System.Web.Http;
using Newtonsoft.Json;
using System;
using System.Linq;
using Orgsys_2017.Orgsys_Classes;
using System.Collections.Generic;
using System.Net.Http;
using System.IO;
using System.Net;
using APILayer.Controllers.Auth.SwaggerFilters;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Client")]
    public class ClientController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        /**
         * Route: api/Client/create
         * Discription: This endpoint handles creating a new client or division for a client.
         * 
         ***/
        [HttpPost]
        [Route("create")]
        public HttpResponseMessage CreateNewClient([FromBody]ClientServiceModel clientServiceModel)
        {
            try
            {
                Client client = clientServiceModel.client;

                client.DateLastUpdated = DateTime.Now;
                if (client.ParentID == null)
                {
                    client.ParentID = 0;
                    client.DivisionName = client.ClientName;
                }
                context.Clients.InsertOnSubmit(client);
                context.SubmitChanges();

                foreach (int clientService in clientServiceModel.clientServices)
                {
                    context.Client_Services.InsertOnSubmit(new Client_Service { ClientID = client.ClientID, ServiceID = clientService });
                }

                context.SubmitChanges();

                return Request.CreateResponse(HttpStatusCode.OK, client.ClientID);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        //api/Client/:clientid/division/create
        [HttpPost]
        [Route("division/create")]
        public HttpResponseMessage CreateNewClientDivision([FromBody]ClientServiceModel clientServiceModel)
        {
            try
            {
                clientServiceModel.client.DateLastUpdated = DateTime.Now;

                context.Clients.InsertOnSubmit(clientServiceModel.client);
                context.SubmitChanges();

                int clientID = clientServiceModel.client.ClientID;

                return Request.CreateResponse(HttpStatusCode.OK);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Gets the lient id by claim reference number
        /// </summary>
        /// <param name="ClaimRefNo"></param>
        [HttpGet]
        [Route("GetClientIDByClaimRefNo/{ClaimRefNo}")]
        public HttpResponseMessage GetClientIDByClaimRefNo(string ClaimRefNo)
        {
            int ClientID = context.Claims.Where(i => i.ClaimRefNu == ClaimRefNo && i.Archived == false).Distinct().SingleOrDefault().ClientID;

            return new HttpResponseMessage()
            {
                Content = new StringContent(ClientID.ToString())
            };
        }


        /// <summary>
        /// Gets the lient id by claim reference number
        /// </summary>
        /// <param name="ClaimRefNo"></param>
        [HttpGet]
        [Route("GetClientIDBySession/{Token}")]
        public HttpResponseMessage GetClientIDBySession(string Token)
        {

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(context.GetClientIDBySession(Token)))
            };
        }



        //Gets a list of divisions for a specific client
        //api/Client/divisions
        [HttpGet]
        [Route("{ClientID}/divisions")]
        public HttpResponseMessage GetClientDivisions(int ClientID)
        {
            try
            {
                var clients = context.GetClientDivisions(ClientID);
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(clients));
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        //Gets a list of clients based on query
        //api/Client/query
        [HttpGet]
        [Route("all/query")]
        public HttpResponseMessage GetAllClientsByFilter([FromUri] Query request)
        {
            try
            {
                var clients = from client in context.Clients
                              where client.ClientName.Contains($"{request.queryString}") &&
                                    client.ParentID == 0
                              select new { client.ClientID, client.ClientName, client.DivisionName };

                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(clients));
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("SaveSOP")]
        public void SaveSOP([FromBody]string sopConData)
        {
            Connection con = new Connection();
            int sopListEnd = sopConData.IndexOf("\"contData\":"); //find the end of the SOPList data
            SOPList soplist = JsonConvert.DeserializeObject<SOPList>(sopConData.Substring(14, sopListEnd - 15) + "}"); //deserialize the SOP section into an SOPList
            ContList contlist = JsonConvert.DeserializeObject<ContList>("{" + sopConData.Substring(sopListEnd, sopConData.Length - sopListEnd - 1)); //deserialize the Contact section into a ContList
            string cols = "";
            string vals = "";
            string contcols = "";
            string contvals = "";
            int? createdId = 0; //for connecting contacts to the SOP data if there was more than one contact
            bool clientAdded = false; //determines if a client was already added, for cases wih multiple contacts

            if (soplist != null)
            {
                try
                {
                    foreach (SOPData col in soplist.sopData)
                    {
                        cols += "[" + col.ColName + "],";
                        vals += "'" + col.ColVal + "',";
                    }

                    foreach (ContData col in contlist.contData)
                    {
                        contcols += "[" + col.ContColname + "],";
                        contvals += "'" + col.ContColVal + "',";
                        if (col.ContColname == "Fax" && clientAdded == false)
                        {
                            context.SOPSave(cols.Substring(0, cols.Length - 1), vals.Substring(0, vals.Length - 1), contcols.Substring(0, contcols.Length - 1), contvals.Substring(0, contvals.Length - 1), 0, ref createdId);
                            contcols = "";
                            contvals = "";
                            System.Diagnostics.Debug.WriteLine("created id == " + createdId);
                            clientAdded = true;
                        }
                        else if (col.ContColname == "Fax" && clientAdded == true)
                        {
                            context.SOPSave(cols.Substring(0, cols.Length - 1), vals.Substring(0, vals.Length - 1), contcols.Substring(0, contcols.Length - 1), contvals.Substring(0, contvals.Length - 1), createdId, ref createdId);
                            contcols = "";
                            contvals = "";
                        }
                    }
                }
                catch (Exception ex)
                {
                    ExceptionLog.LogException(ex);
                }
            }
        }

        [HttpGet]
        [Route("GetClientServices/{Token}")]
        public string GetClientServices(string Token)
        {
            return JsonConvert.SerializeObject(context.GetClientServices(Token), Formatting.None);
        }


        [HttpGet]
        [Route("GetClientServices_V2/{Token}")]
        public string GetClientServices_V2(string Token)
        {
            return JsonConvert.SerializeObject(context.GetClientServices_v2(Token, Request.Headers.GetValues("Language").First()), Formatting.None);
        }

        [HttpGet]
        [Route("GetClientDetails/{Token}")]
        public string GetClientDetails(string Token)
        {
            return JsonConvert.SerializeObject(context.GetClientDetails(Token), Formatting.None);
        }

        [HttpGet]
        [Route("GetClientProfiles/{Token}")]
        public string GetClientProfiles(string Token)
        {
            return JsonConvert.SerializeObject(context.GetClientProfiles(Token), Formatting.None);
        }

        [HttpGet]
        [Route("GetClientContactDetails/{Token}/{ClientID}")]
        public string GetClientContactDetails(string Token, int ClientID)
        {
            return JsonConvert.SerializeObject(context.GetClientContactDetails(Token, ClientID), Formatting.None);
        }


        [HttpPost]
        [Route("UpdateClient/{Token}")]
        public void UpdateClient(string token, [FromBody] Client updatedClient)
        {
            try
            {
                var userId = context.GetUserIDSession(token).SingleOrDefault().UserID;
                var originalClient = context.Clients
                    .Where(x => x.ClientID == updatedClient.ClientID)
                    .SingleOrDefault();
                var propertiesNotUpdated = new List<string> { "User_Groups", "UserID", "LogoPath", "IsActive", "ImportID", "OrgsysDivisionID", "DivisionName", "ParentID" };
                var properties = typeof(Client).GetProperties().Where(x => !propertiesNotUpdated.Contains(x.Name));

                //update entity properties
                foreach (var p in properties)
                {
                    p.SetValue(originalClient, p.GetValue(updatedClient));
                }
                originalClient.DateLastUpdated = DateTime.Now;
                originalClient.LastUpdatedByUserID = userId;

                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }

        }

        [HttpPost]
        [Route("AddClient/{Token}")]
        public Client AddClient(string token, [FromBody] Client client)
        {
            try
            {
                var userId = context.GetUserIDSession(token).SingleOrDefault().UserID;
                var userGroup = new User_Group
                {
                    UserID = userId,
                    AssignDate = DateTime.Now,
                    DateFrom = DateTime.Now,
                    DateTo = new DateTime(2020, 01, 01)
                };

                client.DateLastUpdated = DateTime.Now;
                client.LastUpdatedByUserID = userId;
                client.User_Groups.Add(userGroup);

                context.Clients.InsertOnSubmit(client);
                context.SubmitChanges();

                return client;
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }
            return null;
        }

        [HttpPost]
        [Route("AddedClient/{Token}")]
        public void AddedClient(string token, [FromBody] Client_Added client)
        {
            try
            {
                context.Client_Addeds.InsertOnSubmit(client);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }

        }

        [HttpPost]
        [Route("AddedClientSTDLTD/{Token}")]
        public void AddedClientSTDLTD(string token, [FromBody] Client_STD_LTD_Preference client)
        {
            try
            {
                context.Client_STD_LTD_Preferences.InsertOnSubmit(client);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }

        }

        [HttpPost]
        [Route("AddedClientWC/{Token}")]
        public void AddedClientWC(string token, [FromBody] Client_WC_Preference client)
        {
            try
            {
                context.Client_WC_Preferences.InsertOnSubmit(client);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }

        }

        [HttpPost]
        [Route("RemoveClient/{Token}")]
        public void RemoveClient(string token, [FromBody] Client client)
        {
            try
            {
                var userId = context.GetUserIDSession(token).SingleOrDefault().UserID;
                var userGroup = context.User_Groups
                    .Where(x => x.UserID == userId && x.ClientID == client.ClientID)
                    .SingleOrDefault();

                context.User_Groups.DeleteOnSubmit(userGroup);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }
        }

        [HttpPost]
        [Route("UpdateClientContact/{Token}")]
        public void UpdateClientContact(string token, [FromBody] Client_Contact updatedClientContact)
        {
            try
            {
                var userId = context.GetUserIDSession(token).SingleOrDefault().UserID;
                var originalClientContact = context.Client_Contacts
                    .Where(x => x.ContactID == updatedClientContact.ContactID)
                    .SingleOrDefault();
                var properties = typeof(Client_Contact).GetProperties();

                //update entity properties
                foreach (var p in properties)
                {
                    p.SetValue(originalClientContact, p.GetValue(updatedClientContact));
                }
                originalClientContact.DateLastUpdated = DateTime.Now;
                originalClientContact.LastUpdatedByUserID = userId;

                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }
        }

        [HttpPost]
        [Route("AddClientContact/{Token}")]
        public void AddClientContact(string token, [FromBody] Client_Contact clientContact)
        {
            try
            {
                var userId = context.GetUserIDSession(token).SingleOrDefault().UserID;

                clientContact.DateLastUpdated = DateTime.Now;
                clientContact.LastUpdatedByUserID = userId;

                //pass clientContact with the clientId set once linked to client record 
                context.Client_Contacts.InsertOnSubmit(clientContact);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }
        }

        [HttpPost]
        [Route("RemoveClientContact/{Token}")]
        public void RemoveClientContact(string token, [FromBody] Client_Contact clientContact)
        {
            try
            {
                var deleteClientContact = context.Client_Contacts
                    .Where(x => x.ContactID == clientContact.ContactID)
                    .SingleOrDefault();

                context.Client_Contacts.DeleteOnSubmit(deleteClientContact);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }
        }

        [HttpGet]
        [Route("GetClientLogo/{token}")]
        public HttpResponseMessage GetClientLogo(string token)
        {
            try
            {
                using (context = new OrgSys2017DataContext())
                {
                    var logoFileName = context.GetClientLogo(token).SingleOrDefault().LogoPath;
                    var filePath = $@"\\OSI-DEV01\umbrella\logos\{logoFileName}";

                    var mimeType = Path.GetExtension(filePath) == "png" ? "image/png" : "image/jpeg";
                    var logoBytes = File.ReadAllBytes(filePath);
                    var base64Data = Convert.ToBase64String(logoBytes);

                    var response = new HttpResponseMessage(HttpStatusCode.OK);
                    response.Content = new StringContent(JsonConvert.SerializeObject(new { imageBase64 = $"data:{mimeType};base64,{base64Data}" }));

                    return response;
                }

            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        [HttpGet]
        [Route("All/{token}")]
        public string GetClients(string token)
        {
            return JsonConvert.SerializeObject(context.GetClientsAll(token));
        }
    }

    public class Query
    {
        public string queryString { get; set; }
    }

    public class ClientServiceModel
    {
        public Client client { get; set; }
        public List<int> clientServices { get; set; }
        public bool isDivision { get; set; }
    }

    public class ClientDivisionServiceModel
    {
        public Client client { get; set; }
        public List<string> clientServices { get; set; }
    }

    public class SOPData
    {
        public string ColName { get; set; }
        public string ColVal { get; set; }
    }

    public class ContData
    {
        public string ContColname { get; set; }
        public string ContColVal { get; set; }
    }

    public class SOPList
    {
        public List<SOPData> sopData { get; set; }
    }

    public class ContList
    {
        public List<ContData> contData { get; set; }
    }

    public class ClientList
    {
        public List<Client> Clients { get; set; }
    }
}