using DataLayer;
using Elmah;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Swashbuckle.Swagger.Annotations;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /*Created By   : Sam Khan
      Create Date  : 2017 -05-18
      Update Date  : 2017-01-06 [Added comments and did code clean up]
      Description  : It populates all the drop downs in the form
      Updated by   : Sam Khan*/
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/DataBind")]
    public class PopulateController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        // It gets the values to be populate the generic list
        [HttpGet]
        [Route("GetList_Generic/{ListType}")]
        public string GetList_Generic(string ListType)
        {
            return JsonConvert.SerializeObject(context.GetList_Generic(ListType), Formatting.None);

        }
        /// <summary>
        /// It gets the values to be populate the Appeal status
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        [Route("GetList_AppealStatus")]
        public string GetList_AppealStatus()
        {
            return JsonConvert.SerializeObject(context.GetList_AppealStatus(), Formatting.None);
        }
        // It gets the values to be populate the OSHA category
        [HttpGet]
        [Route("GetList_OSHA")]
        public string GetList_OSHA()
        {
            return JsonConvert.SerializeObject(context.GetList_OSHA(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_TaskType")]
        public string GetList_TaskType()
        {
            var returned = JsonConvert.SerializeObject(context.GetListTaskType(), Formatting.None);
            return returned;
        }

        [HttpGet]
        [Route("GetList_InsuranceCoverage/{ClientID}")]
        public string GetList_InsuranceCoverage(int ClientID)
        {
            var returned = JsonConvert.SerializeObject(context.GetList_InsuranceCoverage(ClientID), Formatting.None);
            return returned;
        }

        [HttpGet]
        [Route("GetList_STDType/{ClientID}")]
        public string GetList_STDType(int ClientID)
        {
            var returned = JsonConvert.SerializeObject(context.GetList_STDType(ClientID), Formatting.None);
            return returned;
        }


        // It gets the values to be populate the Claim Updates Popup
        [HttpGet]
        [Route("GetUpdatesFewFields/{RefNu}")]
        public string GetUpdatesFewFields(string RefNu)
        {
            return JsonConvert.SerializeObject(context.GetUpdatesFewFields(RefNu), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It populates the Order List
        [HttpGet]
        [Route("GetList_Order")]
        public string GetList_Order()
        {
            return JsonConvert.SerializeObject(context.GetList_Order(), Formatting.None);
        }


        // It populates the JobType drop down based on the selected text
        [HttpGet]
        [Route("AutoPopulateJobTypes/{JobType}")]
        public string AutoPopulateJobTypes(string JobType)
        {
            return JsonConvert.SerializeObject(context.AutoPopulateJobType(JobType), Formatting.None);
        }

        // It populates the Claim Update comments
        [HttpGet]
        [Route("GetClaimUpdateComments/{BillID}")]
        public string GetClaimUpdateComments(int BillID)
        {
            return JsonConvert.SerializeObject(context.GetClaimUpdateComments(BillID), Formatting.None);
        }
        [HttpGet]
        [Route("GetClaimUpdateBillingComments/{BillID}")]
        public string GetClaimUpdateBillingComments(int BillID)
        {
            return JsonConvert.SerializeObject(context.GetClaimUpdateBillingComments(BillID), Formatting.None);
        }

        // It gets the values to be populate the billing Method list
        [HttpGet]
        [Route("GetList_BillingMethod")]
        public string GetList_BillingMethod()
        {
            return JsonConvert.SerializeObject(context.GetList_BillingMethod(), Formatting.None);
        }
        // It gets the values to be populate the billing Reason list

        [HttpGet]
        [Route("GetList_CloseReasons")]
        public string GetList_CloseReasons()
        {
            return JsonConvert.SerializeObject(context.GetList_CloseReasons(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_PopulateRF/{ClaimID}")]
        public string GetList_PopulateRF(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetList_PopulateRF(ClaimID), Formatting.None);
        }

        // It gets the values to be populate the billing Reason list
        [HttpGet]
        [Route("GetList_BillingReason/{MethodID}")]
        public string GetList_BillingReason(string MethodID)
        {
            return JsonConvert.SerializeObject(context.GetList_BillingReason(MethodID), Formatting.None);
        }
        // It gets the values to be populate the gender list
        [HttpGet]
        [Route("GetList_Gender")]
        public string GetList_Gender()
        {
            return JsonConvert.SerializeObject(context.GetList_Gender(), Formatting.None);
        }

        // It gets the values to  populate the Activity level list
        [HttpGet]
        [Route("GetList_ActivityLevel")]
        public string GetList_ActivityLevel()
        {
            return JsonConvert.SerializeObject(context.GetList_ActivityLevel(), Formatting.None);
        }

        // It gets the values to be populate the Emp class list
        [HttpGet]
        [Route("GetList_EmpClass/{ClientID}")]
        public string GetList_EmpClass(int ClientID)
        {
            return JsonConvert.SerializeObject(context.GetList_EmpClass(ClientID), Formatting.None);
        }

        // It gets the values to be populate the Pay Frequency
        [HttpGet]
        [Route("GetList_Frequency")]
        public string GetList_Frequency()
        {
            return JsonConvert.SerializeObject(context.GetList_Frequency(), Formatting.None);
        }

        
        // It gets the values to be populate the Benefit Code
        [HttpGet]
        [Route("GetList_BenefitCode")]
        public string GetList_BenefitCode()
        {
            return JsonConvert.SerializeObject(context.GetList_Benefit_Code(), Formatting.None);
        }
        // It gets the values to be populate the Offset Type
        [HttpGet]
        [Route("GetList_OffsetType")]
        public string GetList_OffsetType()
        {
            return JsonConvert.SerializeObject(context.GetList_Offset_Type(), Formatting.None);
        }
        // It gets the values to be populate Earnings Type
        [HttpGet]
        [Route("GetList_EarningsType")]
        public string GetList_EarningsType()
        {
            return JsonConvert.SerializeObject(context.GetList_EarningsType(), Formatting.None);
        }
        // It gets the values to be populate the schType list
        [HttpGet]
        [Route("GetList_SchType")]
        public string GetList_SchType()
        {
            return JsonConvert.SerializeObject(context.GetList_SchType(), Formatting.None);
        }

        // It gets the values to be populate the jobStatus list
        [HttpGet]
        [Route("GetList_JobStatus")]
        public string GetList_JobStauts()
        {
            return JsonConvert.SerializeObject(context.GetList_JobStatus(), Formatting.None);
        }

        // It gets the values to be populate the roleType
        [HttpGet]
        [Route("GetList_RoleType")]
        public string GetList_RoleType()
        {
            return JsonConvert.SerializeObject(context.GetList_RoleType(), Formatting.None);
        }

        // It gets the values to be populate the jobClassification list
        [HttpGet]
        [Route("GetList_JobClassification")]
        public string GetList_JobClassification()
        {
            return JsonConvert.SerializeObject(context.GetList_JobClassification(), Formatting.None);
        }
        // It gets the values to be populate the schType list
        [HttpGet]
        [Route("GetList_ClaimActivity")]
        public string GetList_ClaimActivity()
        {
            return JsonConvert.SerializeObject(context.GetList_ClaimActivity(), Formatting.None);
        }

        // It gets the values to be populate the rateType list
        [HttpGet]
        [Route("GetList_RateType")]
        public string GetList_RateType()
        {
            return JsonConvert.SerializeObject(context.GetList_RatType(), Formatting.None);
        }

        // It gets the values to be populate the language list
        [HttpGet]
        [Route("GetList_Language")]
        public string GetList_Language()
        {
            return JsonConvert.SerializeObject(context.GetList_Language(), Formatting.None);
        }
        // It gets the values to be populate the language list
        [HttpGet]
        [Route("GetList_ClaimStatus")]
        public string GetList_ClaimStatus()
        {
            return JsonConvert.SerializeObject(context.GetList_ClaimStatus(), Formatting.None);
        }
        // It gets the values to be populate the language list
        [HttpGet]
        [Route("GetList_ClaimType")]
        public string GetList_ClaimType()
        {
            return JsonConvert.SerializeObject(context.GetList_ClaimType(), Formatting.None);
        }
        // It gets the values to be populate the contact type list
        [HttpGet]
        [Route("GetList_ContactType")]
        public string GetList_ContactType()
        {
            return JsonConvert.SerializeObject(context.GetList_ContactType(), Formatting.None);
        }
        //Returns RTW options for RTW dropdown
        [HttpGet]
        [Route("GetList_RTW")]
        public string GetList_RTW()
        {
            return JsonConvert.SerializeObject(context.GetList_RTW(), Formatting.None);
        }
        // It populates the countries drop down
        [AllowAnonymousAttribute]
        [HttpGet]
        [Route("PopulateCountries")]
        public string PopulateCountries()
        {
            return JsonConvert.SerializeObject(context.PopulateCountries(), Formatting.None);
        }
        // It populates the provinces drop down based on the selected country
        [AllowAnonymousAttribute]
        [HttpGet]
        [Route("PopulateProvinces/{CountryID}")]
        public string PopulateProvinces(string CountryID)
        {
            return JsonConvert.SerializeObject(context.PopulateProvinces(CountryID), Formatting.None);
        }

        // It populates the cities drop down based on the selected province/state
        [AllowAnonymousAttribute]
        [HttpGet]
        [Route("PopulateCities/{SubName}")]
        public string PopulateCities(string SubName)
        {
            return JsonConvert.SerializeObject(context.PopulateCities(SubName), Formatting.None);
        }

        // It auto populates the employee information based on the employee name //CURRENTLY NOT IN USE as of nov7 2018 //mgougeon
        [HttpGet]
        [Route("AutoPopulateEmpInfo/{token}/{EmpName}")]
        public string AutoPopulateEmpInfo(string token, string EmpName)
        {
            var cid = context.FetchClientID(token);
            return JsonConvert.SerializeObject(context.AutoPopulateEmpInfo(clientID: cid, empName: EmpName), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        // It  populates the Claim Updates information based on the Update ID
        [HttpGet]
        [Route("GetUpdatesSummary/{UpdateID}")]
        public string GetUpdatesSummary(int UpdateID)
        {
            return JsonConvert.SerializeObject(context.GetUpdatesSummary(UpdateID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It  populates the Documents in Claim Updates section
        [Route("ReturnFile/{FileName}/{Extension}")]
        public byte[] ReturnFile(string FileName, string Extension)
        {
            System.IO.FileStream dd = System.IO.File.OpenRead(HttpContext.Current.Server.MapPath("~/UploadedDocuments/" + FileName + '.' + Extension));
            byte[] Bytes = new byte[dd.Length];
            dd.Read(Bytes, 0, Bytes.Length);
            return Bytes;
        }
        //Retrieves data to populate 'type of work returned to' dropdown
        [HttpGet]
        [Route("GetList_ReturnWorkType")]
        public string GetList_ReturnWorktype()
        {
            return JsonConvert.SerializeObject(context.GetList_ReturnWorkType(), Formatting.None);
        }
        //Added by Sam Khan, I am not sure is it the right place to add this method or should it be added to  any other controller. 
        //Date : 05/17/2018
        // It  checks whether the absence is first or not.......
        [HttpGet]
        [Route("CheckIfFirstAbsence/{ClaimID}")]
        public string CheckIfFirstAbsence(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.CheckIfFirstAbsence(ClaimID), Formatting.None);
        }
        //Added by Sam Khan, I am not sure is it the right place to add this method or should it be added to  any other controller. 
        //Date : 05/30/2018
        // It  gets a list of all the documents Uploaded
        [HttpGet]
        [Route("GetDocuments/{ClaimReference}")]
        public string GetDocuments(string ClaimReference)
        {
            return JsonConvert.SerializeObject(context.GetDocuments(ClaimReference), Formatting.None);
        }

        //Added by : Sam Khan
        //Date : 06/06/2018
        //It  gets a list of contacts by Type
        [HttpGet]
        [Route("GetContactsByType/{ClaimID}/{Type}")]
        public string GetContactsByType(int ClaimID, int Type)
        {
            return JsonConvert.SerializeObject(context.GetContactsByType(ClaimID, Type), Formatting.None);
        }

        //Added by : Sam Khan
        //Date : 07/16/2018
        //It  gets a list of all contacts by Type
        [HttpGet]
        [Route("GetAllContactsByType/{ClaimReference}/{Type}")]
        public string GetAllContactsByType(string ClaimReference, int Type)
        {
            return JsonConvert.SerializeObject(context.GetAllContactsByType(ClaimReference, Type), Formatting.None);
        }
        //Added by : Sam Khan
        //Date : 06/06/2018
        //It  gets a list of OSI contacts

        [Route("GetOSIContacts/{ClaimReference}")]
        public string GetOSIContacts(string ClaimReference)
        {
            return JsonConvert.SerializeObject(context.GetOSIContacts(ClaimReference), Formatting.None);
        }

        //Added by : Sam Khan
        //Date : 06/06/2018
        //It  gets a list of Witness contacts

        [Route("GetWitnessContacts/{token}/{claimId}")]
        public string GetWitnessContacts(string token, int claimId)
        {
            return JsonConvert.SerializeObject(context.GetWitnessContacts(token, claimId), Formatting.None);
        }

        //Added by : Sam Khan
        //Date : 07/31/2018
        //It  gets a list of Physician type

        [Route("GetList_PhysicianType")]
        public string GetList_PhysicianType()
        {
            return JsonConvert.SerializeObject(context.GetList_PhysicianType(), Formatting.None);
        }

        //Added by : Sam Khan
        //Date : 07/31/2018
        //It  gets a list of Insurance Options 
        [HttpGet]
        [Route("GetList_InsuranceOptions")]
        public string GetList_InsuranceOptions()
        {
            return JsonConvert.SerializeObject(context.GetList_InsuranceOpt(), Formatting.None);
        }

        //Added by : Sam Khan
        //Date : 06/13/2018
        //It  gets a list of Employee contacts

        [Route("GetEmployeeContacts/{Token}/{ClaimID}")]
        public string GetEmployeeContacts(string Token, int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetEmployeeContacts(Token, ClaimID), Formatting.None);
        }

        [HttpGet]
        [Route("GetAbsFewFields/{ClaimID}")]
        public string GetAbsFewFields(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetAbsFewFields(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        //Retrieves data to populate submitter details on final page of forms
        [HttpGet]
        [Route("GetUserInfo_External/{token}")]
        public string GetUserInfof_External(string token)
        {
            return JsonConvert.SerializeObject(context.GetUserInfo_External(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_InjuryIllnessCause")]
        public string GetList_InjuryIllnessCause()
        {
            return JsonConvert.SerializeObject(context.GetList_InjuryIllnessCause(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_LOAType")]
        public string GetList_LOAType()
        {
            return JsonConvert.SerializeObject(context.GetList_LOAType(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_FamilyCareRelationship")]
        public string GetList_FamilyCareRelationship()
        {
            return JsonConvert.SerializeObject(context.GetList_FamilyCareRelationship(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_DocumentType")]
        public string GetList_DocumentType()
        {
            return JsonConvert.SerializeObject(context.GetList_DocumentType(), Formatting.None);
        }
        
        [HttpGet]
        [Route("GetList_TreatmentLocation")]
        public string GetList_TreatmentLocation()
        {
            return JsonConvert.SerializeObject(context.GetList_TreatmentLocation(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_AccidentCause")]
        public string GetList_AccidentCause()
        {
            return JsonConvert.SerializeObject(context.GetList_AccidentCause(), Formatting.None);
        }

        [HttpGet]
        [Route("GetList_Unions")]
        public string GetList_Unions()
        {
            return JsonConvert.SerializeObject(context.GetList_Unions(), Formatting.None);
        }

        /// <summary>
        /// Gets a list of useable weather conditions in portal
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns list of weather conditions", typeof(List<List_WeatherCondition>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("GetList_WeatherConditions")]
        public HttpResponseMessage GetList_WeatherConditions()
        {
            try
            {
                List<List_WeatherCondition> weatherConditions = (from WeatherCondition in context.List_WeatherConditions
                                                                 select WeatherCondition).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(weatherConditions));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Gets a list of useable environmental factors for dropdowns
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns list of environmental factors", typeof(List<List_EnvironmentalFactor>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("GetList_EnvironmentFactors")]
        public HttpResponseMessage GetList_EnvironmentFactors()
        {
            try
            {
                List<List_EnvironmentalFactor> environmentFactors = (from EnvironmentalFactor in context.List_EnvironmentalFactors
                                                                 select EnvironmentalFactor).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(environmentFactors));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Gets a list of useable equipment that could be involved in an incident cause
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns list of equipment that could be involved in an incident", typeof(List<List_EquipmentInvolved>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("GetList_EquipmentInvolved")]
        public HttpResponseMessage GetList_EquipmentInvolved()
        {
            try
            {
                List<List_EquipmentInvolved> equipmentInvolved = (from EquipmentInvolved in context.List_EquipmentInvolveds
                                                                   select EquipmentInvolved).ToList();

                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(equipmentInvolved));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Gets a list of useable equipment that could be involved in an incident cause
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns list of injury illness locations that could be involved in an incident", typeof(List<List_InjuryIllnessLocation>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("GetList_InjuryIllnessLocation")]
        public HttpResponseMessage GetList_InjuryIllnessLocation()
        {
            try
            {
                List<List_InjuryIllnessLocation> injuryIllnessLocations = (from InjuryIllnessLocation in context.List_InjuryIllnessLocations
                                                                            select InjuryIllnessLocation).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(injuryIllnessLocations));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Gets a list of useable human factors that can be used for the incident cause section
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns list of human factors that could be involved in an incident", typeof(List<List_HumanFactor>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("GetList_HumanFactor")]
        public HttpResponseMessage GetList_HumanFactor()
        {
            try
            {
                List<List_HumanFactor> humanFactors = (from HumanFactor in context.List_HumanFactors
                                                       select HumanFactor).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(humanFactors));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpGet]
        [Route("GetList_Roles")]
        public string GetRoles([FromUri] bool IsInternal)
        {
            var roles = context.Roles
                .Where(x => x.IsInternal == IsInternal)
                .Select(r => new
                {
                    r.Role_ID,
                    r.RoleName
                }).ToList();

            return JsonConvert.SerializeObject(roles, Formatting.None);
        }
    }
}
