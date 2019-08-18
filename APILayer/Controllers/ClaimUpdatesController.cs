using System;
using System.Collections.Generic;
using System.Web.Http;
using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using Newtonsoft.Json.Linq;
using APILayer.Models.DTOS;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.SwaggerFilters;
using APILayer.Controllers.Auth.Authentication;

namespace APILayer.Controllers
{
    /*Created By   : Sam Khan
      Create Date  : 2017 -10-12
      Update Date  : 2017-05-18 [Added comments and did code clean up]
      Description  : It saves the claim updates [internal] in the data base
      Updated by   : Marie Gougeon - 04-15-2018
      */
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/ClaimUpdates")]
    public class ClaimUpdatesController : ApiController
    {
        public Claim_Updates_Document objDocument { get; set; }
        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        [HttpGet]
        [Route("GetClaimUpdates/{token}/{RefNu}")]
        public string GetClaimUpdates(string token, string RefNu)
        {
            return JsonConvert.SerializeObject(context.GetClaimUpdates(token, RefNu), Formatting.None);
        }


        [HttpGet]
        [Route("GetUpdateDocsInfo/{updateID}/{token}")]
        public HttpResponseMessage GetUpdateDocsInfo(int updateID, string token)
        {
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(context.GetPrClaimUpdateFiles(token, updateID), Formatting.None))
            };
        }

        [HttpGet]
        [Route("GetReportedComments/{RefNu}")]
        public string GetReportedComments(string RefNu)
        {
            return JsonConvert.SerializeObject(context.GetReportedComments(RefNu), Formatting.None);
        }

        [HttpPost]
        [Route("UpdateAdjudicateClaim/{token}")]
        public HttpResponseMessage UpdateAdjudicateClaim(string token, [FromBody] CloseClaimDTO model)
        {
            try
            {
                var valid = context.CheckIfTokenValid(token) != 0;
                if (!valid)
                    return Request.CreateResponse(HttpStatusCode.Unauthorized);

                context.UpdateAdjudicateClaim(model.Reason, model.ClaimID, model.ClaimReference, model.UserID, model.Comment);
                return new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent("Closed")
                };
                    
                
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        //TODO: needs auth
        [HttpPost]
        [Route("SaveUpdates")]
        public HttpResponseMessage SaveUpdates([FromBody]string ClaimUpdateDTO)
        {
            HttpResponseMessage message = new HttpResponseMessage();
            Claim_Update claimUpdate = new Claim_Update();
            try
            {
                dynamic claimupdateDto = JObject.Parse(ClaimUpdateDTO);
                
                 claimUpdate = ((JObject) claimupdateDto.claimUpdate).ToObject<Claim_Update>();
                Claim_Updates_Billing updatesBilling = ((JObject) claimupdateDto.claimUpdatesBilling).ToObject<Claim_Updates_Billing>();
                claimUpdate.DateTimeSubmitted_ = DateTime.UtcNow; 
                context.Claim_Updates.InsertOnSubmit(claimUpdate);
                context.SubmitChanges(); //submit because the claim update id is needed for foreign key

                //set billing update foreign key to claim updateID
                updatesBilling.UpdateID = claimUpdate.UpdateID;
                context.Claim_Updates_Billings.InsertOnSubmit(updatesBilling);
                context.SubmitChanges();
            }
            catch (Exception e)
            {
                return Request.CreateErrorResponse(HttpStatusCode.InternalServerError, e.Message);
            }
            message.StatusCode = HttpStatusCode.Created;
            message.Content = new StringContent(claimUpdate.UpdateID.ToString());
            return message;
        }

        /// <summary>
        /// If the user creates a claim update they can delete it within 2 hours of creation if they make a mistake 
        /// </summary>
        /// <param name="token"></param>
        /// <param name="updateID"></param>
        /// <returns></returns>
        [HttpDelete]
        [Route("ArchiveUpdate/{token}/{updateID}")]
        public HttpResponseMessage ArchiveUpdate(string token, int updateID)
        {
            Claim_Update claimUpdate = context.Claim_Updates.Single(i => i.UpdateID == updateID);
            Session session = context.Sessions.FirstOrDefault(i => i.SessionToken == token);

            if (claimUpdate.DateTimeSubmitted_ < DateTime.UtcNow.AddHours(-2))
            {
                return new HttpResponseMessage()
                {
                    StatusCode = HttpStatusCode.BadRequest,
                    Content = new StringContent("Claim update exceeded 2 hours old, cannot be archived.")
                };
            }

            if (claimUpdate.UserID != Convert.ToInt32(session.UserID))
            {
                return new HttpResponseMessage()
                {
                    StatusCode = HttpStatusCode.BadRequest,
                    Content = new StringContent("You did not create this claim update. you cannot delete it")
                };
            }
            Claim_Updates_Billing updatesBilling = context.Claim_Updates_Billings.Single(i => i.UpdateID == updateID);
            Claim_Update_Cmr oldCMR = context.Claim_Update_Cmrs.SingleOrDefault(i => i.UpdateID == updateID);
            List<Claim_Updates_Document> updatesDocuments = context.Claim_Updates_Documents.Where(i => i.UpdateID == updateID).ToList();
            Claim_Peer_Review peerReview = context.Claim_Peer_Reviews.SingleOrDefault(i => i.Update_ID == updateID);
            Claim_Updates_Billing_PR_Archive archive = new Claim_Updates_Billing_PR_Archive()
            {
                UserID = claimUpdate.UserID,
                ClaimRefNu = claimUpdate.ClaimRefNu,
                ActionType = claimUpdate.ActionType,
                Archived_By = Convert.ToInt32(session.UserID),
                BillID = updatesBilling.BillID,
                Billable = claimUpdate.Billable,
                Comments = updatesBilling.Comments,
                Completed = updatesBilling.Completed,
                CompletionDate = updatesBilling.CompletionDate,
                Courier = updatesBilling.Courier,
                Date_Archived = DateTime.Now,
                DirectContact = updatesBilling.DirectContact,
                Duration = updatesBilling.Duration,
                EmployeeComments = claimUpdate.EmployeeComments,
                InternalComments = claimUpdate.InternalComments,
                IsArchived = claimUpdate.IsArchived,
                IsInReview = false,
                Method = updatesBilling.Method,
                Postage = updatesBilling.Postage,
                Reason = updatesBilling.Reason,
                ReportedComments = claimUpdate.ReportedComments,
                UpdateBy = Convert.ToInt32(session.UserID),
                UpdateId = claimUpdate.UpdateID,
                UpdatesDate = claimUpdate.UpdatesDate,
                SeniorConsulting = updatesBilling.SeniorConsulting
                

            };

            if (oldCMR != null)
            {
                Claim_Update_Cmr_Archive cmrarchive = new Claim_Update_Cmr_Archive()
                {
                    UserID = oldCMR.UserID,
                    UpdateID = oldCMR.UpdateID,
                    AbsenceAuthorization = oldCMR.AbsenceAuthorization,
                    ArchiveDate = DateTime.Now,
                    ArchivedBy = Convert.ToInt32(session.UserID),
                    ClaimHistoryInformation = oldCMR.ClaimHistoryInformation,
                    ClaimStatusID = oldCMR.ClaimStatusID,
                    DateOfAbsence = oldCMR.DateOfAbsence,
                    DateOfReferal = oldCMR.DateOfReferal,
                    DateOfReport = oldCMR.DateOfReport,
                    EmployeeID = oldCMR.EmployeeID,
                    EmployeeName = oldCMR.EmployeeName,
                    EmployerContactID = oldCMR.EmployerContactID,
                    Location = oldCMR.Location,
                    NextSteps = oldCMR.NextSteps,
                    OSIContactID = oldCMR.OSIContactID,
                    ReturntoWorkRecommendations = oldCMR.ReturntoWorkRecommendations,
                    TreatmentPlan = oldCMR.TreatmentPlan
                };
                context.Claim_Update_Cmr_Archives.InsertOnSubmit(cmrarchive);
            }
            foreach (Claim_Updates_Document doc in updatesDocuments)
            {
                Claim_Updates_Documents_Archive docarchive = new Claim_Updates_Documents_Archive()
                {
                    UserID = doc.UserID,
                    UpdateID = doc.UpdateID,
                    ArchivedBy = Convert.ToInt32(session.UserID),
                    ClaimReference = doc.ClaimReference,
                    DateArchived = DateTime.Now,
                    DocumentID = doc.DocumentID,
                    FileExt = doc.FileExt,
                    FileName = doc.FileName,
                    Timestamp = doc.Timestamp,
                    VersionNumber = doc.VersionNumber

                };
                context.Claim_Updates_Documents_Archives.InsertOnSubmit(docarchive);
            }
            if (peerReview != null)
            {
                context.Claim_Peer_Reviews.DeleteOnSubmit(peerReview);
            }
            context.Claim_Updates_Billing_PR_Archives.InsertOnSubmit(archive);
            context.SubmitChanges();
            context.Claim_Updates.DeleteOnSubmit(claimUpdate);
            context.Claim_Updates_Billings.DeleteOnSubmit(updatesBilling);
            if (oldCMR != null)
            {
                context.Claim_Update_Cmrs.DeleteOnSubmit(oldCMR);
            }
            foreach (Claim_Updates_Document doc in updatesDocuments)
            {
                context.Claim_Updates_Documents.DeleteOnSubmit(doc);
            }
            context.SubmitChanges();

            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("Claim update and child records successfuly archived")
            };
        }


        //NEED TO REVISE
        [HttpPost]
        [Route("SaveDocuments")]
        public void SaveDocuments()
        {
            {
                try
                {
                    foreach (string file in HttpContext.Current.Request.Files)
                    {
                        if (file != null)
                        {
                            HttpPostedFile postedDocument = HttpContext.Current.Request.Files[file];
                            var fileName = Path.GetFileName(postedDocument.FileName);
                            var documentSavePath = Path.Combine(HttpContext.Current.Server.MapPath("~/UploadedDocuments"), fileName);
                            postedDocument.SaveAs(documentSavePath);

                        }
                    }
                }
                catch (Exception e)
                {
                    ExceptionLog.LogException(e);
                }
            }
        }
    }
}


