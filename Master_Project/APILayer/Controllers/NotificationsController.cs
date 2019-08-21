using DataLayer;
using System.Web.Http;
using Newtonsoft.Json;
using System;
using Orgsys_2017.Orgsys_Classes;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Notifications")]
    public class NotificationsController : ApiController
    {

        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        /* Author:      Kamil Salagan
         * Created:     02-17-2017
         * Updated:     Marie 03-21-2018
         * Description: Pass user group ID and return all notifications for that group
         * Update:      Added more SP for data collection and updating the DB information (roles, groups, etc)
         * 
         * Updated:     Andriy 05-01-2018
         * Update:      Added methods for sprocs to get notifications for portal and set viewed notifications to 'viewed'
         */ 
        [HttpGet]
        [Route("GetNotifications_V2/{token}")]
        public string GetNotifications_v2(string token)
        {
            //grab role values based on the user id and build a query to grab all notifications for the roles and values
            try { 
            return JsonConvert.SerializeObject(context.GetNotifications_V2(token), Formatting.None);
            }catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return ex.ToString();
            }
        }

        //Grabs the information for the notification that is selected in the 'Notifications Panel"
        [HttpGet]
        [Route("GetNewNotifications/{token}/{nid}")]
        public string GetNewNotifications(string token, int nid)
        {
            return JsonConvert.SerializeObject(context.GetNewNotifications(token, nid), Formatting.None);
        }

        //Update system notifications and claims to add user information and notification information
        [HttpGet]
        [Route("UpdateNotificationsClaims/{token}/{notificationID}")]
        public string UpdateNotificationsClaims(string token, int notificationID)
        {
            return JsonConvert.SerializeObject(context.UpdateNotificationsClaims(token, notificationID), Formatting.None);
        }

        //Grab the information for the opened claim in the "open claims panel"
        [HttpGet]
        [Route("GetSelectedOpenedClaim/{token}/{nid}")]
        public string GetSelectedOpenedClaim(string token, int nid)
        {
            return JsonConvert.SerializeObject(context.GetSelectedOpenedClaim(token, nid), Formatting.None);
        }

        //Close any notifications once handled
        [HttpGet]
        [Route("CloseNotifications/{NotificationID}")]
        public string CloseNotifications(string NotificationID)
        {
            return JsonConvert.SerializeObject(context.CloseNotification(NotificationID), Formatting.None);

        }

        //Gets data for selected notification on the external dashboard
        [HttpGet]
        [Route("GetNotificationExternal/{token}/{nid}")]
        public string GetNotificationExternal(string token, int nid)
        {
            return JsonConvert.SerializeObject(context.GetNotificationExternal(token, nid), Formatting.None);
        }

        //Gets all active notifications for the user of a session
        [HttpGet]
        [Route("GetNotifications_External/{token}")]
        public string GetNotifications_External(string Token)
        {
            return JsonConvert.SerializeObject(context.GetNotifications_External(Token), Formatting.None);
        }

        //Gets data for selected notification on the external dashboard
        [HttpGet]
        [Route("UpdateNotificationViewed/{token}/{nid}")]
        public string UpdateNotificationViewed(string token, int nid)
        {
            return JsonConvert.SerializeObject(context.UpdateNotificationViewed(token, nid), Formatting.None);
        }

    }
}