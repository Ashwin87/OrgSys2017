using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Web.Http;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers

/* Author: Marie Gougeon
 * Created: 11-23-2017
 * Updated: 
 * Description: Universal methods for program to api
 */
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/DataManagement")]
    public class DataManagementController : ApiController
    {
        public OrgSys2017DataContext con = new OrgSys2017DataContext();
        
        //Populate List of all users
        [HttpGet]
        [Route("PopulateAllUsers/")]
        public string PopulateAllUsers()
        {
            return JsonConvert.SerializeObject(con.PopulateAllUsers(), Formatting.None);
        }

        //Populate List of all users names internally
        [HttpGet]
        [Route("GetUserProfileName_Internal/{token}")]
        public string GetUserProfileName_Internal(string token)
        {
            return JsonConvert.SerializeObject(con.GetUserProfileName_Internal(token), Formatting.None);
        }

        //Grab User ID Logged In (user id only)
        [HttpGet]
        [Route("GetUserInfo/{Username}")]
        public string GetUserInfo(string Username)
        {
            return JsonConvert.SerializeObject(con.GetUserInfo(Username), Formatting.None);
        }

        //Get User name Assigned to anything by UserID
        [HttpGet]
        [Route("GetUserAssignedToTask/{UserID}")]
        public string GetUserAssignedToTask(int UserID)
        {
            return JsonConvert.SerializeObject(con.GetUserAssignedToTask(UserID), Formatting.None);
        }

        //Grab User ID Logged In (Session Token)
        [HttpGet]
        [Route("GetUserIDSession/{token}")]
        public string GetUserIDSession(string token)
        {
            return JsonConvert.SerializeObject(con.GetUserIDSession(token), Formatting.None);
        }

        [HttpGet]
        [Route("ConfirmUser/{Username}")]
        public string ConfirmUser(string Username)
        {
            return JsonConvert.SerializeObject(con.ConfirmUser(Username), Formatting.None);
        }

        //Grab the User's Group
        [HttpGet]
        [Route("GetUserGroups/{UserID}")]
        public string GetUserGroups(int UserID)
        {
            return JsonConvert.SerializeObject(con.GetUserGroups(UserID), Formatting.None);
        }

        //Get all Clients list (client name)
        [HttpGet]
        [Route("GetAllClients/")]
        public string GetAllClients()
        {
            try
            {
                return JsonConvert.SerializeObject(con.GetAllClients(), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }
        
        [HttpGet]
        [Route("GetClientsAssignedToUserByToken/{token}")]
        public string GetClientsAssignedToUserByToken(string token)
        {
            return JsonConvert.SerializeObject(con.GetClientsAssignedToUserByToken(token), Formatting.None);
        }

    }
}
