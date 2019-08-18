using DataLayer;
using System.Web.Http;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using Swashbuckle.Swagger.Annotations;
using Elmah;
using APILayer.Models.DTOS;
using APILayer.Controllers.Auth.SwaggerFilters;
using APILayer.Controllers.Auth.Authentication;

namespace APILayer.Controllers
{
    /// <summary>
    /// API controler for CRUD opperations on claims and relational data
    /// </summary>
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Claim")]
    public class ClaimController : ApiController
    {   // I have created seperate stored procedures in order to avoid complex queries
        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        [HttpGet]
        [Route("GetLatestClaimIDFromRefNo/{RefNo}")]
        public HttpResponseMessage GetLatestClaimIDFromRefNo(string RefNo)
        {
            HttpResponseMessage message = new HttpResponseMessage();

            if (RefNo == "" || RefNo == null)
            {
                message.StatusCode = HttpStatusCode.BadRequest;
                return message;
            }

            try
            {
                message.Content =
                    new StringContent(JsonConvert.SerializeObject(context.GetLatestClaimIdFromRefNo(RefNo).Single(),
                        Formatting.None));
                return message;
            }
            catch
            {
                message.StatusCode = HttpStatusCode.NotFound;
                return message;
            }

        }




        // It gets all the contacts of a claim for the respective Client.
        // It is a seperate stored procedure to avoid Complex SQL statements. [Looping and Self Joins]
        [HttpGet]
        [Route("GetClaimContacts/{ClaimID}")]
        public string GetClaimContacts(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetClaimContacts(ClaimID), Formatting.None);
        }
        //Sam Khan --- 08/15/2018
        //It gets GRTW schedule
        [HttpGet]
        [Route("GetGRTWSchedule/{ClaimID}")]
        public string GetGRTWSchedule(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetGRTWSchedule(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        [HttpGet]
        [Route("GetRehabilitation/{ClaimID}")]
        public string GetRehabilitation(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetRehabilitation(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        [HttpGet]
        [Route("GetCpp_AppDetails/{ClaimID}")]
        public string GetCpp_AppDetails(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetCPPApp_Details(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        [HttpGet]
        [Route("GetIsClaimClosed/{ClaimID}")]
        public string GetIsClaimClosed(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetIsClaimClosed(ClaimID), Formatting.None);
        }

        // It gets all the new claims of a specific client
        //[HttpGet]
        //[Route("GetNewClaims/{token}")]
        //public string GetNewClaims(string token)
        //{
        //    return JsonConvert.SerializeObject(context.GetNewClaims(token), Formatting.None);
        //}

        //change the status of the claim to open
        [HttpGet]
        [Route("Claims_ChangeStatus/{ClaimID}")]
        public string Claims_ChangeStatus(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.Claims_ChangeStatus(ClaimID), Formatting.None);
        }

        [HttpGet]
        [Route("CheckClaimIfExists/{ClaimRefNo}")]
        public string CheckClaimIfExists(string ClaimRefNo)
        {
            return JsonConvert.SerializeObject(context.CheckClaimIfExists(ClaimRefNo), Formatting.None);
        }

        // It gets all the opened claims of a specific client
        [HttpGet]
        [Route("GetOpenedClaims/{token}")]
        public string GetOpenedClaims(String token)
        {
            return JsonConvert.SerializeObject(context.GetOpenedClaims(token), Formatting.None);
        }

        //It gets all the opened or closed claims of a specific client
        [HttpGet]
        [Route("GetClaims/{token}/{OpenOrClosed}/{UserOrClient}")]
        public string GetClaims(String token, bool OpenOrClosed, bool UserOrClient)
        {
            return JsonConvert.SerializeObject(context.GetClaims(token, OpenOrClosed, UserOrClient), Formatting.None);
        }

        // It gets all the drafts of a specific client
        [HttpGet]
        [Route("GetDrafts/{ClientID}")]
        public string GetDrafts(int ClientID)
        {
            return JsonConvert.SerializeObject(context.GetDrafts(ClientID), Formatting.None);
        }
        // It gets the claim data of a specific claim for Portal [As the fields are different]
        [HttpGet]
        [Route("GetClaimData/{Token}/{ClaimID}")]
        public string GetClaimData(string Token, int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetClaimData(Token, ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        /// <summary>
        /// Returns the default dates for claim benefit dates
        /// </summary>
        /// <remarks>
        /// Consumed in: Claim_Dates.html
        /// </remarks>
        /// <param name="ClaimID">Id of Claim</param>
        [HttpGet]
        [SwaggerResponse(HttpStatusCode.OK, Type = typeof(DefaultBenefitDatesDTO))]
        [SwaggerResponse(HttpStatusCode.NotFound,"Claim does not exist", Type = typeof(HttpResponseMessage))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, Type = typeof(HttpResponseMessage))]       
        [Route("GetClaimBenefitsDefaultDates/{ClaimID}")]
        public HttpResponseMessage GetClaimBenefitsDefaultDates (int ClaimID)
        {
            HttpResponseMessage message = new HttpResponseMessage();

            if (context.Claims.SingleOrDefault(i => i.ClaimID == ClaimID) == null)
            {
                return new HttpResponseMessage(HttpStatusCode.NotFound)
                {
                    Content = new StringContent("Claim does not exist")
                };
            }
            try
            {
                var bd = context.GetClaimBenefitsDefaultDates(ClaimID).First();
                DateTime ReferralDate = bd.ReferralDate ?? DateTime.Now;
                int WaitPeriod = bd.STDWaitPeriodDays ?? 0;
                int LTDDuration = bd.LTDDurationWeeks ?? 0;
                DateTime STDStartDate = ReferralDate.AddDays(WaitPeriod);
                DateTime STDEndDate = STDStartDate.AddDays(LTDDuration * 7);
                DateTime LTDStartDate = STDEndDate.AddDays(1);

                DefaultBenefitDatesDTO benefitDates = new DefaultBenefitDatesDTO
                {
                    STDStartDate = STDStartDate.ToString("yyyy-MM-dd"),
                    LTDStartDate = LTDStartDate.ToString("yyyy-MM-dd"),
                    STDEndDate = STDEndDate.ToString("yyyy-MM-dd")
                };
                message.StatusCode = HttpStatusCode.OK;
                message.Content = new StringContent(JsonConvert.SerializeObject(benefitDates), Encoding.UTF8, "application/json");
            }
            catch(Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e); //ELMAH Signaling, this will log the catched exception to elmah.axd

                return new HttpResponseMessage(HttpStatusCode.InternalServerError)
                {
                    Content = new StringContent(e.Message)
                };
            }           
            return message;
        }
        [HttpGet]
        [Route("GetClaimHeaderInfo/{ClaimID}")]
        public string GetClaimHeaderInfo(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetClaimHeaderInfo(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It gets the claim data of a specific claim for Internal Form
        [HttpGet]
        [Route("GetClaimDataInternal/{token}/{ClaimID}")]
        public string GetClaimDataInternal(string token, int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetClaimDataInternal(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It gets only few Claim fields
        [HttpGet]
        [Route("GetClaimFewFields/{ClaimID}")]
        public string GetClaimFewFields(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetClaimFewFields(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It gets the earnings of a specific claim
        [HttpGet]
        [Route("GetPayrollEarnings/{ClaimID}")]
        public string GetPayrollEarnings(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetPayrollEarnings(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It gets the offsets of a specific claim
        [HttpGet]
        [Route("GetPayrollOffsets/{ClaimID}")]
        public string GetPayrollOffsets(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetPayrollOffsets(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets the Insurances of a specific claim
        [HttpGet]
        [Route("GetPayrollInsurance/{ClaimID}")]
        public string GetPayrollInsurance(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetPayrollInsurance(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It gets the predisability of a specific claim
        [HttpGet]
        [Route("GetPayrollDisability/{ClaimID}")]
        public string GetPayrollDisability(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetPayrollDisability(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets the other earnings of a specific claim
        [HttpGet]
        [Route("GetOtherEarnings/{ClaimID}")]
        public string GetOtherEarnings(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetOtherEarnings(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets the  schedule of an employee
        [HttpGet]
        [Route("GetSchedule/{ClaimID}")]
        public string GetSchedule(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetSchedule(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        [HttpGet]
        [Route("GetDocumentsByType/{ClaimRefNo}/{Type}")]
        public string GetDocumentsByType(string ClaimRefNo, int Type)
        {
            return JsonConvert.SerializeObject(context.GetDocumentsByType(ClaimRefNo, Type), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It gets all the dates of a claim for the respective Client.
        [HttpGet]
        [Route("GetClaimDates/{ClaimID}")]
        public string GetClaimDates(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetClaimDates(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Specialist details of the respective Claim.
        [HttpGet]
        [Route("GetSpecialistDetails/{ClientID}/{ClaimID}")]
        public string GetSpecialistDetails(int ClientID, int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetSpecialistDetails(ClientID, ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It is a seperate stored procedure to get date details to avoid Complex SQL statements.
        [HttpGet]
        [Route("GetDateDetails/{ClaimID}")]
        public string GetDateDetails(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetAbsDates(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        //Gets expired or non-expired users assigned to a specific claim ++++++++++++++
        [HttpGet]
        [Route("GetUsersAssignedToClaim/{token}/{ClaimRefNu}/{getExpired}")]
        public string GetUsersAssignedToClaim(String token, String ClaimRefNu, bool getExpired)
        {
            return JsonConvert.SerializeObject(context.GetUsersAssignedToClaim(token, ClaimRefNu, getExpired), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        //Updates claim assigned to a specific user
        //[HttpPatch]
        //[Route("PatchClaimsAssignedToUser/{token}/{ClaimRefNu}/{UserID}")]
        //public string PatchClaimAssignedToUser(String token, String ClaimRefNu, String UserId)
        //{
        //    return JsonConvert.SerializeObject(context.PatchClaimAssignedToUser(token, ClaimRefNu, UserId), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        //}

            //COMMENTED OUT DUE TO ERROR --KAMIL
        //Expires a user assigned to a specific claim 
        [HttpGet]
        [Route("ExpireUserAssignedToClaim/{token}/{ClaimAssignedID}/{ActiveUserID}")]
        public string ExpireUserAssigntedToClaim(String token, int ClaimAssignedID, int ActiveUserID)
        {
            return JsonConvert.SerializeObject(context.ExpireUserAssignedToClaim(token, ClaimAssignedID, ActiveUserID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        //Expires a user assigned to a specific claim 
        [HttpGet]
        [Route("AddUsersAssignedToClaim/{token}/{claimRefNu}/{claimID}/{userID}")]
        public string AddUsersAssignedToClaim(String token, String claimRefNu, int claimID, int userID)
        {
            return JsonConvert.SerializeObject(context.PatchUsersAssignedToClaim(token, claimRefNu, claimID, userID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // Use Token to retrieve client and user ids - TO USE
        //[HttpGet]
        //[Route("GetUserInfo/{token}")]
        //public string GetUserInfo(string token)
        //{
        //   // return JsonConvert.SerializeObject(context.GetSessionInfo(token), Formatting.None);
        //}

        //
        [HttpGet]
        [Route("GetClaimsExternalDashboard/{Token}/{Open}")]
        public string GetClaimsExternalDashboard(string Token, bool Open)
        {
            return JsonConvert.SerializeObject(context.GetClaimsExternalDashboard(Token, Open), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        [HttpGet]
        [Route("GetAbsencesDetails/{ClaimID}")]
        public string GetAbsencesDetails(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetAbsencesDetails(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        [HttpGet]
        [Route("GetPortalClaimManagerFields/{token}")]
        public string GetPortalClaimManagerFields(string token)
        {
            return JsonConvert.SerializeObject(context.GetPortalClaimManagerFields(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetClaimInjuryCause_IncidentTypes/{token}/{claimId}")]
        public string GetClaimInjuryCause_IncidentTypes(string token, int claimId)
        {
            return JsonConvert.SerializeObject(context.GetClaimInjuryCause_IncidentTypes(token, claimId), Formatting.None);
        }

        [HttpGet]
        [Route("GetClaimTypeID_FormID")]
        public string GetClaimTypeID_FormID()
        {
            return JsonConvert.SerializeObject(context.GetClaimTypeID_FormID(), Formatting.None);
        }
    }
}
