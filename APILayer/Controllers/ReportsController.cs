using DataLayer;
using System.Web.Http;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using Orgsys_2017.Orgsys_Classes;
using Newtonsoft.Json.Linq;
using Elmah;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.DataAnnotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /// <summary>
    /// Reports controller for 
    /// </summary>
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Report")]
    public class ReportsController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        [HttpGet]
        [Route("Reports_TotalClaimsDaily/{token}")]
        public string Reports_TotalClaimsDaily(string token)
        {
            return JsonConvert.SerializeObject(context.Reports_TotalClaimsDaily(token), Formatting.None);
        }


        [HttpGet]
        [SwaggerOperationFilter(typeof(LanguageHeaderIOFilter))]
        [Route("GetReportTypes")]
        public string GetReportTypes()
        {
            return JsonConvert.SerializeObject(context.GetList_ReportType(Request.Headers.GetValues("Language").First()), Formatting.None);
        }

        /// <summary>
        ///  Gets new referrals aggregate by month and year filtered by the provided request properties
        /// </summary>
        /// <param name="token">token to verify the users session</param>
        /// <param name="request">object that contains dateFrom, dateTo, and clientId for filtering data</param>
        /// <returns></returns>
        [HttpPost]
        [Route("Report_NewReferralsAggregateByMonth/{token}")]
  //      [SwaggerResponse(HttpStatusCode.OK, "Returns new referrals aggregated by month and year as a json string", typeof(Report_NewReferralsAggregateByMonthResult))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        public HttpResponseMessage Report_NewReferralsAggregateByMonth(string token, [FromBody] ReportRequestModel request)
        {
            try
            {
                var clientId = context.GetClientIDBySession(token).FirstOrDefault().ClientID.ToString();
                string divisions = "";

                if (clientId == "1934")
                {// -- MEGA HACK !! For Demo purposes only (KAMIL SALAGAN IS TO BLAME FOR THIS)
                    //Override ClientID to allow demo user account to pull data for generating reports without directly linking the account to that ClientID
                    clientId = "1811"; 
                    divisions = "1811";
                } else
                {
                    divisions = getDivisionsForUser(token, clientId);
                }
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(context.Report_NewReferralsAggregateByMonth(token, request.dateFrom, request.dateTo, request.clientService, divisions)));
            }
            catch (Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        ///  Gets closed referrals aggregate by month and year filtered by the provided request properties
        /// </summary>
        /// <param name="token">token to verify the users session</param>
        /// <param name="request">object that contains dateFrom, dateTo, and clientId for filtering data</param>
        /// <returns></returns>
        [HttpPost]
        [Route("Report_ClosedReferralsAggregateByMonth/{token}")]
        [SwaggerResponse(HttpStatusCode.OK, "Returns closed referrals aggregated by month and year as a json string", typeof(Report_ClosedReferralsAggregateByMonthResult))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        public HttpResponseMessage Report_ClosedReferralsAggregateByMonth(string token, [FromBody] ReportRequestModel request)
        {
            try
            {
                var clientId = context.GetClientIDBySession(token).FirstOrDefault().ClientID.ToString();
                string divisions = getDivisionsForUser(token, clientId);
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(context.Report_ClosedReferralsAggregateByMonth(token, request.dateFrom, request.dateTo, request.clientService, divisions)));
            }
            catch (Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }
        /// <summary>
        /// A helper function that takes in a token and basicClientId. If the user is a manager it gets all divisions for root, if the
        /// user is a basic user it returns basicClientId (which is the users clientId)
        /// </summary>
        /// <param name="token"></param>
        /// <param name="basicClientId"></param>
        /// <returns>a comma delimited string of the divisions associated with the user</returns>
        public string getDivisionsForUser(string token, string basicClientId)
        {
            var userRoleList = context.GetUserRole(token).ToList();
            bool isManager = userRoleList.FindIndex(role => role.Role_ID == 2) > -1 ? true : false;
            var userId = context.GetUserIDSession(token).FirstOrDefault().UserID;

            var rootClientId = (from division in context.ClientDivisionUserViews
                                where division.Clientid == Convert.ToInt32(basicClientId)
                                select division).FirstOrDefault().RootClientID;

            if (isManager)
            {
                var allDivisionsForClient = (from division in context.ClientDivisionUserViews
                                                             where division.UserID == userId &&
                                                             division.RootClientID == rootClientId
                                                             select division.Clientid).ToList();
                return String.Join(",", allDivisionsForClient);
            }
            else
            {
                return basicClientId;
            }
        }
    }

    /// <summary>
    /// Report request model
    /// </summary>
    public class ReportRequestModel
    {
        public string dateFrom { get; set; }
        public string dateTo { get; set; }
        public string clientService { get; set; }
    }
}
