using System;
using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Swashbuckle.Swagger.Annotations;

namespace APILayer.Controllers
{ 
    /// <summary>
    /// Controller for bills unrelated to claims 
    /// </summary>
    [RoutePrefix("api/Billing")]
    public class BillingController : ApiController
    {
        /// <summary>
        /// orgsys data context
        /// </summary>
        public OrgSys2017DataContext con = new OrgSys2017DataContext();

        /// <summary>
        /// Add a billing item that is not related to a claim
        /// </summary>
        /// <param name="billDetails"> Bill item DTO</param>
        /// <param name="token"> session token</param>
        [HttpPost]
        [Route("AddBillingItem/{token}")]
        public HttpResponseMessage AddBillingItem([FromBody]string billDetails, string token)
        {
            if (con.CheckIfTokenValid(token) != 10001 && con.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }
            try
            {
                BillingDetail bill = JsonConvert.DeserializeObject<BillingDetail>(billDetails);
                int UserID = con.GetUserIDSession(token).SingleOrDefault().UserID;
                bill.AssignedTo = UserID;
                bill.BilledBy = UserID;
                bill.DateAdded = DateTime.Now;

                con.BillingDetails.InsertOnSubmit(bill);
                con.SubmitChanges();
                return new HttpResponseMessage(HttpStatusCode.OK);

            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }

            
        }

        /// <summary>
        /// Updated an existsing bill item
        /// </summary>
        /// <param name="billDetails"> Bill item DTO </param>
        /// <param name="token"> Session token </param>
        [HttpPut]
        [Route("UpdateBillingItem/{token}")]
        public HttpResponseMessage UpdateBillingItem([FromBody]string billDetails, string token)
        {
            if (con.CheckIfTokenValid(token) != 10001 && con.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }
            try
            {
                BillingDetail UpdateBill = JsonConvert.DeserializeObject<BillingDetail>(billDetails);
                BillingDetail OldBill = con.BillingDetails.SingleOrDefault(i => i.BillID == UpdateBill.BillID);

                OldBill.BillDate = UpdateBill.BillDate;
                OldBill.CompletionDate = UpdateBill.CompletionDate;
                OldBill.BillMethod = UpdateBill.BillMethod;
                OldBill.BillReason = UpdateBill.BillReason;
                OldBill.BillDuration = UpdateBill.BillDuration;
                OldBill.DirectContact = UpdateBill.DirectContact;
                OldBill.Postage = UpdateBill.Postage;
                OldBill.Courier = UpdateBill.Courier;
                OldBill.Billable = UpdateBill.Billable;
                OldBill.Comments = UpdateBill.Comments;
                OldBill.ClientID = UpdateBill.ClientID;
                con.SubmitChanges();
                return new HttpResponseMessage(HttpStatusCode.OK);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest) {
                    Content = new StringContent(JsonConvert.SerializeObject(ex))
                };
            }
        }


        /// <summary>
        /// Get existing billable items that the user submited by token
        /// </summary>
        /// <param name="token"> Session token</param>
        [HttpGet]
        [Route("GetBillingItem_ByUser/{token}")]
        [SwaggerResponse(HttpStatusCode.OK, null, typeof(GetBillingItem_ByUserResult))]
        public HttpResponseMessage GetBillingItem_ByUser(string token)
        {
            if (con.CheckIfTokenValid(token) != 10001 && con.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }
            try
            {
                return new HttpResponseMessage(HttpStatusCode.OK) {
                    Content = new StringContent(JsonConvert.SerializeObject(con.GetBillingItem_ByUser(token), Formatting.None))
                };
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }

        /// <summary>
        /// Get existing non billable items that the user submited by token
        /// </summary>
        /// <param name="token"> Session token</param>
        [HttpGet]
        [Route("GetNonBillingItem_ByUser/{token}")]
        [SwaggerResponse(HttpStatusCode.OK, null, typeof(GetNonBillingItem_ByUserResult))]
        public HttpResponseMessage GetNonBillingItem_ByUser(string token)
        {
            if (con.CheckIfTokenValid(token) != 10001 && con.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }
            try
            {
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonConvert.SerializeObject(con.GetNonBillingItem_ByUser(token), Formatting.None))
                };
               
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }

       /// <summary>
       /// Get billing method types
       /// </summary>
        [HttpGet]
        [Route("GetBillingMethod")]
        [SwaggerResponse(HttpStatusCode.OK, null, typeof(GetBillingMethodResult))]
        public HttpResponseMessage GetBillingMethod()
        {
            try
            {
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonConvert.SerializeObject(con.GetBillingMethod(), Formatting.None))
                };
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }

        /// <summary>
        /// Get billing reasons by billing method ID
        /// </summary>
        /// <param name="BillingMethodID"> billing method ID</param>
        [HttpGet]
        [Route("GetBillingReason/{billingMethodID}")]
        [SwaggerResponse(HttpStatusCode.OK, null, typeof(GetBillingReasonResult))]
        public HttpResponseMessage GetBillingReason(int BillingMethodID)
        {
            try
            {
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonConvert.SerializeObject(con.GetBillingReason(BillingMethodID), Formatting.None))
                };
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }

        /// <summary>
        /// Get a single billing item by the bill ID
        /// </summary>
        /// <param name="BillID"> Bill ID</param>
        /// <param name="token"> Session token</param>
        [HttpGet]
        [Route("GetBillingItem_ByID/{BillID}/{token}")]
        [SwaggerResponse(HttpStatusCode.OK, null, typeof(GetBillingItem_ByIDResult))]
        public HttpResponseMessage GetBillingItem_ByID(string BillID, string token)
        {
            if (con.CheckIfTokenValid(token) != 10001 && con.IsUserInternal(token) == 1)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized);
            }
            try
            {
               
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonConvert.SerializeObject(con.GetBillingItem_ByID(BillID), Formatting.None))
                };
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return new HttpResponseMessage(HttpStatusCode.BadRequest);
            }
        }
    }
}
