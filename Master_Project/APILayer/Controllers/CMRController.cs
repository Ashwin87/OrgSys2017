using APILayer.Models.DTOS;
using System;
using System.Net.Http;
using System.Web.Http;
using System.Net;
using DataLayer;
using Swashbuckle.Swagger.Annotations;
using System.Linq;
using System.Net.Http.Formatting;
using Elmah;
using System.Collections.Generic;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /// <summary>
    /// Created 4/1/2019 by John VanGeemen
    /// </summary>
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/CMR")]
    public class CMRController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();
        /// <summary>
        /// Returns the CMR Defaults when a claim update is completed to populate a cmr form
        /// </summary>
        /// <param name="ClaimID"></param>
        [HttpGet]
        [Route("GetCMRDefaults/{ClaimID}")]
        [SwaggerResponse(HttpStatusCode.OK, "CMR Defaults DTO", typeof(CMRDefaultsDTO))]
        public HttpResponseMessage GetCMRDefaults(int ClaimID)
        {
            try
            {
                Claim claim = context.Claims.SingleOrDefault(i => i.ClaimID == ClaimID);
                Claim_Employee claimEmployee = context.Claim_Employees.Single(i => i.ClaimID == ClaimID);
                List<Claim_Contact> claimContact = context.Claim_Contacts.Where(i => i.ClaimID == ClaimID /*&& i.ContactType == "Manager"*/).ToList();
                List<CMRClaimContactPartial> claimContactPartial = new List<CMRClaimContactPartial>();
                List<Claim_Emp_ContactTypeDetail> employeeContacts = context.Claim_Emp_ContactTypeDetails.Where(i=>i.EmpID == claimEmployee.EmpID && i.ContactType.Contains("Email")).ToList();
                List<CMREmployeeContactPartial> employeeContactPartial = new List<CMREmployeeContactPartial>();

                string employeeName = claimEmployee.EmpFirstName + " " + claimEmployee.EmpLastName;

                foreach (var contact in claimContact)
                {
                    claimContactPartial.Add(new CMRClaimContactPartial()
                    {
                        ContactName = contact.Con_FirstName +" "+ contact.Con_LastName,
                        ContactType = contact.ContactType,
                        ContactID = contact.ContactID
                    });
                }


                foreach (var Empcontact in employeeContacts)
                {
                    employeeContactPartial.Add(new CMREmployeeContactPartial()
                    {
                        ContactID = Empcontact.EmpID,
                        ContactEmail = Empcontact.ContactDetail,
                        ContactPriority = Empcontact.PriorityOrder ?? 0

                    });
                }


                CMRDefaultsDTO dto = new CMRDefaultsDTO()
                {
                    ClaimRefNo = claim.ClaimRefNu,
                    DateOfReferal = claim.ReferralDate?.ToString("yyyy-MM-dd"),
                    Location = claim.IncidentLocation,
                    EmpIDNO = claimEmployee.EmpID,
                    EmpName = employeeName,                    
                    ClaimContacts = claimContactPartial,
                    DateOfReport = DateTime.Now.ToString("yyyy-MM-dd"),
                    EmployeeContacts = employeeContactPartial
                };
                return new HttpResponseMessage()
                {
                    Content = new ObjectContent(typeof(CMRDefaultsDTO), dto, new JsonMediaTypeFormatter())
                };
            }
            catch (Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return new HttpResponseMessage(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("SaveCmr")]
        public HttpResponseMessage SaveCmr([FromBody] Claim_Update_Cmr cmr )
        {
            context.Claim_Update_Cmrs.InsertOnSubmit(cmr);
            context.SubmitChanges();
            return new HttpResponseMessage()
            {
                StatusCode = HttpStatusCode.OK,
                Content = new StringContent("Inserted")
            };
        }
    }
}
