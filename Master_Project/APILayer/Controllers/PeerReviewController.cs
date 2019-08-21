using APILayer.Models.DTOS;
using DataLayer;
using Newtonsoft.Json;
using OpenHtmlToPdf;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Mail;
using System.Web.Hosting;
using System.Web.Http;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/PeerReview")]
    public class PeerReviewController : ApiController
    {
        OrgSys2017DataContext _ctx = new OrgSys2017DataContext();

        [HttpGet]
        [Route("GetPRByToken/{token}")]
        public HttpResponseMessage GetPRByToken(string token)
        {
            PeerReview peerReview = new PeerReview();

            peerReview.Assigned = _ctx.GetAssignedPeerReviewsByToken(token);
            peerReview.Outgoing = _ctx.GetOutgoingPeerReviewsByToken(token);
            peerReview.Pending = _ctx.GetPendingPeerReviewsByToken(token);
            peerReview.Returned = _ctx.GetReturnedPeerReviewsByToken(token);
            peerReview.PRavailable = _ctx.GetUserPrAvailable(token).SingleOrDefault().PrAvailable;

            return new HttpResponseMessage()
            {
                Content = new StringContent(JsonConvert.SerializeObject(peerReview, Formatting.None))
            };
        }

        [HttpPut]
        [Route("UpdateReviewComment/{updateID}/{token}")]
        public HttpResponseMessage UpdateReviewComment([FromBody] string comment, int updateID, string token)
        {
            _ctx.UpdatePeerReviewComment(token, updateID, comment);
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("")
            };
        }

        [HttpPut]
        [Route("ReturnReviewForChanges/{updateID}")]
        public HttpResponseMessage ReturnReviewForChanges(int updateID)
        {
            var query =
                (from CPR in _ctx.Claim_Peer_Reviews
                    where CPR.Update_ID == updateID && CPR.Review_Status_ID == 0
                    select CPR).SingleOrDefault();
                query.Review_Status_ID = 2;
           

            try
            {
                _ctx.SubmitChanges();
                return new HttpResponseMessage()
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent("")
                };
            }
            catch (Exception e)
            {
                return new HttpResponseMessage()
                {
                    StatusCode = HttpStatusCode.BadRequest,
                    Content = new StringContent(e.ToString())
                };
            }

           
        }

        [HttpPut]
        [Route("TakePendingReview/{updateID}/{token}")]
        public HttpResponseMessage TakePendingReview(int updateID, string token)
        {
            int updated = _ctx.TakePendingReview(updateID, token);

            if (updated == 0 || updated == 2)
            {
                return new HttpResponseMessage()
                {
                    StatusCode = HttpStatusCode.BadRequest,
                    Content = new StringContent("Cannot assign user to its own update, or claim is no longer pending.")
                };
            }
            else
            {
                return new HttpResponseMessage()
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent("Updated")
                };
            }
        }

        [HttpPut]
        [Route("ClosePeerReview/{updateID}/{token}")]
        public HttpResponseMessage ClosePeerReview(int updateID, string token)
        {
            _ctx.ClosePeerReview(token, updateID);
            SendCMRReportToClient(updateID);


            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("Updated")
            };
        }

        [HttpGet]
        [Route("GetAssignedPRData/{updateID}/{token}")]
        public HttpResponseMessage GetAssignedPRData(string token, int updateID)
        {
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(_ctx.GetAssignedPRData(updateID, token).SingleOrDefault(), Formatting.None))
            };
        }

        [HttpGet]
        [Route("GetPRClaimUpdate/{updateID}/{token}")]
        public HttpResponseMessage GetPRClaimUpdate(int updateID, string token)
        {
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(_ctx.GetPRClaimUpdate(token, updateID).SingleOrDefault(), Formatting.None))
            };
        }

        [HttpGet]
        [Route("GetPRClaimUpdateFiles/{updateID}/{token}")]
        public HttpResponseMessage GetPRClaimUpdateFiles(int updateID, string token)
        {
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(_ctx.GetPrClaimUpdateFiles(token, updateID), Formatting.None))
            };
        }

        [HttpPost]
        [Route("ArchiveClaimUpdateAndBilling/{updateID}/{token}")]
        public HttpResponseMessage ArchiveClaimUpdateAndBilling([FromBody] string UpdatesBilling,int updateID,string Token)
        {
            //insert into archive table
            Claim_Update claimUpdate = _ctx.Claim_Updates.Single(i => i.UpdateID == updateID);
            Claim_Updates_Billing updatesBilling = _ctx.Claim_Updates_Billings.Single(i => i.UpdateID == updateID);
            Session session = _ctx.Sessions.FirstOrDefault(i => i.SessionToken == Token);

            
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
                IsInReview = true,
                Method = updatesBilling.Method,
                Postage = updatesBilling.Postage,
                Reason = updatesBilling.Reason,
                ReportedComments = claimUpdate.ReportedComments,
                UpdateBy = Convert.ToInt32(session.UserID),
                UpdateId = claimUpdate.UpdateID,
                UpdatesDate = claimUpdate.UpdatesDate,
                SeniorConsulting = updatesBilling.SeniorConsulting

            };
            _ctx.Claim_Updates_Billing_PR_Archives.InsertOnSubmit(archive);
            _ctx.SubmitChanges();



            dynamic updates = JsonConvert.DeserializeObject(UpdatesBilling);

            claimUpdate.InternalComments = updates.InternalComments;
            claimUpdate.ReportedComments = updates.ReportedComments;
            claimUpdate.EmployeeComments = updates.EmployeeComments;
            claimUpdate.Billable = updates.Billable;

            updatesBilling.CompletionDate = Convert.ToDateTime(updates.CompletionDate);
            updatesBilling.DirectContact =  Convert.ToBoolean(updates.DirectContact);
            updatesBilling.Postage =  Convert.ToBoolean(updates.Postage);
            updatesBilling.Courier = Convert.ToBoolean(updates.Courier);
            updatesBilling.Method = updates.Method;
            updatesBilling.Reason = updates.Reason;
            updatesBilling.Duration = updates.Duration;
            updatesBilling.Comments = updates.Comments;
            updatesBilling.SeniorConsulting = updates.SeniorConsulting;

            _ctx.SubmitChanges();


            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("")
            };

        }

        [HttpGet]
        [Route("GetPRCMR/{updateID}/{token}")]
        public HttpResponseMessage GetPRCMR(int updateID, string token)
        {
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(_ctx.GetPRCMR(token, updateID).SingleOrDefault(), Formatting.None))
            };
        }

        [HttpGet]
        [Route("GetPRCMREmployeeContacts/{ClaimID}")]
        public HttpResponseMessage GetPRCMREmployeeContacts(int ClaimID)
        {
            Claim claim = _ctx.Claims.SingleOrDefault(i => i.ClaimID == ClaimID);
            Claim_Employee claimEmployee = _ctx.Claim_Employees.Single(i => i.ClaimID == ClaimID);
            List<Claim_Emp_ContactTypeDetail> employeeContacts = _ctx.Claim_Emp_ContactTypeDetails.Where(i => i.EmpID == claimEmployee.EmpID && i.ContactType.Contains("Email")).ToList();
            List<CMREmployeeContactPartial> employeeContactPartial = new List<CMREmployeeContactPartial>();

            foreach (var Empcontact in employeeContacts)
            {
                employeeContactPartial.Add(new CMREmployeeContactPartial()
                {
                    ContactID = Empcontact.ContactTypeID,
                    ContactEmail = Empcontact.ContactDetail,
                    ContactPriority = Empcontact.PriorityOrder ?? 0

                });
            }

            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent(JsonConvert.SerializeObject(employeeContactPartial, Formatting.None))
            };
        }

        [HttpPost]
        [Route("ArchivePRCMR/{updateID}/{token}")]
        public HttpResponseMessage ArchivePRCMR([FromBody] Claim_Update_Cmr updateCmr, int updateID, string token)
        {
            Session session = _ctx.Sessions.SingleOrDefault(i => i.SessionToken == token);
            Claim_Update_Cmr oldCMR = _ctx.Claim_Update_Cmrs.SingleOrDefault(i => i.UpdateID == updateID);

            Claim_Update_Cmr_Archive archive = new Claim_Update_Cmr_Archive()
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
            _ctx.Claim_Update_Cmr_Archives.InsertOnSubmit(archive);
            _ctx.SubmitChanges();

            oldCMR.UserID = updateCmr.UserID;
            oldCMR.UpdateID = updateCmr.UpdateID;
            oldCMR.AbsenceAuthorization = updateCmr.AbsenceAuthorization;
            oldCMR.ClaimHistoryInformation = updateCmr.ClaimHistoryInformation;
            oldCMR.ClaimStatusID = updateCmr.ClaimStatusID;
            oldCMR.DateOfAbsence = updateCmr.DateOfAbsence;
            oldCMR.DateOfReferal = updateCmr.DateOfReferal;
            oldCMR.DateOfReport = updateCmr.DateOfReport;
            oldCMR.EmployeeID = updateCmr.EmployeeID;
            oldCMR.EmployeeName = updateCmr.EmployeeName;
            oldCMR.EmployerContactID = updateCmr.EmployerContactID;
            oldCMR.Location = updateCmr.Location;
            oldCMR.NextSteps = updateCmr.NextSteps;
            oldCMR.OSIContactID = updateCmr.OSIContactID;
            oldCMR.ReturntoWorkRecommendations = updateCmr.ReturntoWorkRecommendations;
            oldCMR.TreatmentPlan = updateCmr.TreatmentPlan;
            oldCMR.EmployeeContactID = updateCmr.EmployeeContactID;

            _ctx.SubmitChanges();

            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("Updated")
            };
        }


        [HttpPut]
        [Route("ToggleUserPRAvailability/{token}/{available}")]
        public void ToggleUserPRAvailability(string token, bool available)
        {
            _ctx.TogleUserPrAvailability(token, available);
        }





        ///// <summary>
        ///// Genrate a pdf from html, bootsrap injected, email to provided email
        ///// </summary>
        ///// <param name="CMREmailDTO"></param>
        [HttpPost]
        [Route("SendCMR")]
        public void SendCMRReportToClient(int UpdateID)
        {
            SmtpClient smtp = new SmtpClient();
            MailMessage mm;
            Claim_Update_Cmr cmr = _ctx.Claim_Update_Cmrs.SingleOrDefault(i => i.UpdateID == UpdateID);

            if(cmr == null)
            {
                return;
            }


            Claim_Update claimUpdate = _ctx.Claim_Updates.SingleOrDefault(i => i.UpdateID == UpdateID);
            Claim_Contact EmployerContact = _ctx.Claim_Contacts.SingleOrDefault(i => i.ContactID == cmr.EmployerContactID);
            Claim_Emp_ContactTypeDetail EmployeeContact = _ctx.Claim_Emp_ContactTypeDetails.SingleOrDefault(i => i.EmpID == cmr.EmployeeContactID);
            List_ClaimStatus claimStatus = _ctx.List_ClaimStatus.SingleOrDefault(i => i.index == cmr.ClaimStatusID);
            List<string> emails = new List<string>();
            User_Profile OSIContact = _ctx.User_Profiles.SingleOrDefault(i => i.UserID == cmr.OSIContactID);

            //emails.Add(EmployerContact.Con_Email);
            //emails.Add(EmployeeContact.ContactDetail);
            emails.Add("EmailHere");
            //create email body
            string EmailTemplate = File.ReadAllText(HostingEnvironment.MapPath(@"~/EmailTemplates/CMREmailTemplate.html"));
            EmailTemplate = EmailTemplate.Replace(" {{ReportedComments}}", claimUpdate.ReportedComments);

            //create cmr pdf
            string cmrhtml = File.ReadAllText(HostingEnvironment.MapPath(@"~/EmailTemplates/CMRTemplate.html"));
            cmrhtml = cmrhtml.Replace("{{ClaimStatus}}", claimStatus.Status_EN);
            cmrhtml = cmrhtml.Replace("{{DateOfReport}}", cmr.DateOfReport.ToLongDateString());
            cmrhtml = cmrhtml.Replace("{{EmployeeName}}", cmr.EmployeeName);
            cmrhtml = cmrhtml.Replace("{{EmployeeEmail}}", EmployeeContact.ContactDetail);
            cmrhtml = cmrhtml.Replace("{{EmployeeID}}", cmr.EmployeeID.ToString());
            cmrhtml = cmrhtml.Replace("{{ReferalDate}}", cmr.DateOfReferal.ToLongDateString());
            cmrhtml = cmrhtml.Replace("{{Location}}", cmr.Location);
            cmrhtml = cmrhtml.Replace("{{AbsenceDate}}", cmr.DateOfAbsence.ToLongDateString());
            cmrhtml = cmrhtml.Replace("{{EmployerContact}}", EmployerContact.Con_Email);
            cmrhtml = cmrhtml.Replace("{{OSIContact}}", OSIContact.Email);
            cmrhtml = cmrhtml.Replace("{{HistoryInformation}}", cmr.ClaimHistoryInformation);
            cmrhtml = cmrhtml.Replace("{{AbsenceAuthorization}}", cmr.AbsenceAuthorization);
            cmrhtml = cmrhtml.Replace("{{TreatmentPlan}}", cmr.TreatmentPlan);
            cmrhtml = cmrhtml.Replace("{{Recommendations}}", cmr.ReturntoWorkRecommendations);
            cmrhtml = cmrhtml.Replace("{{NextSteps}}", cmr.NextSteps);

            string FilePath = HostingEnvironment.MapPath(@"~/TempFiles/ClaimUpdate" + claimUpdate.ClaimRefNu + "-" + DateTime.Now.ToString("dd-MM-yyyy") + ".pdf");
            string Html = "<html><head><title></title><style>" + File.ReadAllText(HostingEnvironment.MapPath(@"~/Content/bootstrap.min.css")) + "</style></head><body>" + cmrhtml + "</body></html>";
            var pdf = Pdf
                            .From(Html)
                            .OfSize(PaperSize.A4)
                            .Content();
            System.IO.File.WriteAllBytes(FilePath, pdf);

            foreach (string email in emails)
            {
                smtp.UseDefaultCredentials = false;
                smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                smtp.Credentials = new NetworkCredential("noreply", "44bananas55$");
                smtp.Host = "connect.orgsoln.com"; //Change for smtp from OSI
                smtp.EnableSsl = false;
                smtp.Port = 25;

                mm = new MailMessage("noreply@orgsoln.com", email);
                mm.Subject = "Claim update for " + claimUpdate.ClaimRefNu;
                mm.IsBodyHtml = true;
                mm.Body = EmailTemplate;

                mm.Attachments.Add(new Attachment(FilePath));
                smtp.Send(mm);
                smtp.Dispose();
                mm.Attachments.Dispose();

                File.Delete(FilePath);
            }

        }

    }

    public class PeerReview
    {
        public ISingleResult<GetAssignedPeerReviewsByTokenResult> Assigned { get; set; }
        public ISingleResult<GetReturnedPeerReviewsByTokenResult> Returned { get; set; }
        public ISingleResult<GetOutgoingPeerReviewsByTokenResult> Outgoing { get; set; }
        public ISingleResult<GetPendingPeerReviewsByTokenResult> Pending { get; set; }
        public Nullable<bool> PRavailable { get; set; }
    }
}
