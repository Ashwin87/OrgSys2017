using System;
using System.Collections.Generic;
using System.Web.Http;
using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using APILayer.Models;
using System.Linq;
using System.Net.Http;
using System.Net;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.SwaggerFilters;
using APILayer.Controllers.Auth.Authentication;

namespace APILayer.Controllers
{
    /*Created By   : Sam Khan
      Create Date  : 2017 -05-18
      Update Date  : 2017-05-18 [Added comments and did code clean up]
      Description  : It saves the claim data [internal] in the data base
      Updated by   : Sam Khan
      Updated by   : Marie 2018-03-23 - Added a return, the claimid generated after submit is pulled and returned
    */
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/SaveClaim")]
    public class SaveClaimController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();
        int ClaimID;
        public HttpResponseMessage Post([FromBody]string claimData) {

            try
            {
                ClaimModel model = new ClaimModel();
                var archive = false;

                using (var context = new OrgSys2017DataContext())
                {
                    if (claimData.Length > 0)
                    {
                        //Deserialzing Claim Objects
                        ClaimList list = JsonConvert.DeserializeObject<ClaimList>(claimData.ToString());
                        //Employee Schedule
                        foreach (Claim_Emp_Schedule schedule in list.claimData.objSch)
                        {
                            list.claimData.objEmp.Claim_Emp_Schedules.Add(schedule);
                        }
                        //Need to fix it[FIXED]
                        //Billing Details
                        //foreach (Billable bill in list.claimData.objBill)
                        //{
                        //    if (bill.objBilling != null)
                        //    {
                        //        bill.objComm.Claim_BillingDetails.Add(bill.objBilling);
                        //    }
                        //  //  list.claimData.objClaim.Claim_Comments.Add(bill.objComm);
                        //}
                        //Main Dates
                        foreach (Claim_Date claimDate in list.claimData.objDates)
                        {
                            list.claimData.objClaim.Claim_Dates.Add(claimDate);
                        }
                        //Abs Dates
                        foreach (Claim_AbsenceDate absDate in list.claimData.objAbs)
                        {
                            list.claimData.objClaim.Claim_AbsenceDates.Add(absDate);
                        }
                        //Doc Dates
                        foreach (Claim_Date docDate in list.claimData.objDoc)
                        {
                            list.claimData.objClaim.Claim_Dates.Add(docDate);
                        }
                        //Contacts
                        foreach (Claim_Contact claimCon in list.claimData.objCon)
                        {
                            list.claimData.objClaim.Claim_Contacts.Add(claimCon);
                        }
                        // Job Details
                        list.claimData.objEmp.Claim_Emp_JobDetails.Add(list.claimData.objJob);

                        // Pay Details
                        list.claimData.objEmp.Claim_Emp_PayDetails.Add(list.claimData.objPay);


                        //Payroll
                        list.claimData.objEmp.Claim_Employee_PayRolls.Add(list.claimData.objPayroll);

                        //Payroll Earnings
                        foreach (Claim_Emp_Payroll_Earning ear in list.claimData.objEarn)
                        {
                            list.claimData.objPayroll.Claim_Emp_Payroll_Earnings.Add(ear);
                        }

                        //Payroll Offsets
                        foreach (Claim_Emp_Payroll_Offset offset in list.claimData.objOffset)
                        {
                            list.claimData.objPayroll.Claim_Emp_Payroll_Offsets.Add(offset);
                        }

                        //Offset Insurance
                        foreach (Claim_Emp_Payroll_Insurance ins in list.claimData.objIns)
                        {
                            list.claimData.objPayroll.Claim_Emp_Payroll_Insurances.Add(ins);
                        }

                        //Predisability
                        foreach (Claim_Emp_Payroll_PreDi dis in list.claimData.objDisability)
                        {
                            list.claimData.objPayroll.Claim_Emp_Payroll_PreDis.Add(dis);

                        }
                        //Add Contct Type
                        foreach (Claim_Emp_ContactTypeDetail conType in list.claimData.objContactType)
                        {
                            list.claimData.objEmp.Claim_Emp_ContactTypeDetails.Add(conType);
                        }

                        list.claimData.objClaim.Claim_Absences.AddRange(list.claimData.objAbsence);
                        list.claimData.objClaim.Claim_CPP_Applications.AddRange(list.claimData.objCPP);
                        list.claimData.objClaim.Claim_GRTW_Schedules.AddRange(list.claimData.objGRTW);
                        list.claimData.objClaim.Claim_Rehabilitations.AddRange(list.claimData.objRehab);
                        list.claimData.objClaim.Claim_AdditionalDetails.Add(list.claimData.objAdditionalDetails);

                        //Employee
                        list.claimData.objClaim.Claim_Employees.Add(list.claimData.objEmp);

                        //All the incident saving information would go in here.........
                        //Incidents
                        foreach (Incident incident in list.claimData.objInc)
                        {
                            //Witness
                            if (incident.objWitness != null)
                            {
                                incident.objIncident.Claim_ICDCM_Witnesses.AddRange(incident.objWitness);
                            }
                            //Limitations
                            if (incident.objLimit != null)
                            {
                                incident.objIncident.Claim_ICDCM_Limitations.AddRange(incident.objLimit);
                            }
                            //Corrective Actions
                            if (incident.objAct != null)
                            {
                                incident.objIncident.Claim_Injury_CorrActions.AddRange(incident.objAct);
                            }
                            //Damage
                            foreach (Damage dam in incident.objDam)
                            {
                                if (dam.objProp.PropertyType != "")
                                {
                                    Claim_ICDCM_Collateral_Property pro = dam.objProp;
                                    dam.objDamage.Claim_ICDCM_Collateral_Properties.Add(pro);
                                }
                                if (dam.objAni.AnimalType != "")
                                {
                                    Claim_ICDCM_Collateral_Animal ani = dam.objAni;
                                    dam.objDamage.Claim_ICDCM_Collateral_Animals.Add(ani);
                                }
                                incident.objIncident.Claim_ICDCM_CollateralDamages.Add(dam.objDamage);
                            }
                            //Category
                            foreach (Category cat in incident.objCat)
                            {
                                cat.objCategory.Claim_Injury_BodyParts.AddRange(cat.objPart);
                                cat.objCategory.Claim_Injury_Medications.AddRange(cat.objMed);
                                cat.objCategory.Claim_Injury_Activities.AddRange(cat.objActivities);
                                //Cause
                                //if (cat.objCause != null)
                                //{
                                //    Cause cause = cat.objCause;
                                //    cat.objCategory.Claim_Injury_Causes = cause.objCauseFields;
                                //    cat.objCategory.Claim_Injury_Causes.Claim_Injury_Cause_EnvironmentFactors.AddRange(cause.objEnvironmentFactors);
                                //    cat.objCategory.Claim_Injury_Causes.Claim_Injury_Cause_EquipmentInvolveds.AddRange(cause.objEquipmentInvolved);
                                //    cat.objCategory.Claim_Injury_Causes.Claim_Injury_Cause_HumanFactors.AddRange(cause.objHumanFactors);
                                //    cat.objCategory.Claim_Injury_Causes.Claim_Injury_Cause_InjuryLocations.AddRange(cause.objInjuryLocations);
                                //    cat.objCategory.Claim_Injury_Causes.Claim_Injury_Cause_WeatherConditions.AddRange(cause.objWeatherConditions);
                                //}
                                incident.objIncident.Claim_ICDCMCategories.Add(cat.objCategory);
                            }
                            //Commented it out so that I could do some of the testing-----Sam Khan -----08/13/2018
                            //I tried uncommenting , but it would give me an error which Aaron has to take a look.
                            list.claimData.objClaim.Claim_ICDCMs.Add(incident.objIncident);
                        }

                        var claimReferenceNumber = list.claimData.objClaim.ClaimRefNu;
                        if (claimReferenceNumber == null || claimReferenceNumber == string.Empty)
                        {
                            var claimRef = model.UniqueClaimReference(list.claimData.objClaim.ClientID.ToString());
                            //set claimrefnu for new claim objects
                            list.claimData.objClaim.ClaimRefNu = claimRef;
                            list.claimData.objContactType.ForEach(x => x.ClaimReference = claimRef);
                            list.claimData.objCon.ForEach(x => x.ClaimRefNu = claimRef);
                            list.claimData.objAbsence.ForEach(x => x.ClaimRefNu = claimRef);
                        }
                        else
                        {
                            archive = true;
                            //archive table records that are linked to the claim by claimReferenceNumber /abovtenko
                            context.Claim_Emp_ContactTypeDetails
                                .Where(x => x.ClaimReference == claimReferenceNumber).ToList().ForEach(x => x.Archived = true);
                        }
                        list.claimData.objClaim.Archived = false;
                        var RefDate = list.claimData.objClaim.ReferralDate;
                        if (RefDate == null)
                        {
                            var now = DateTime.Now;
                            if (now > new DateTime(now.Year, now.Month, now.Day, 15, 30, 00))
                            {
                                list.claimData.objClaim.ReferralDate = new DateTime().AddDays(1);
                            }
                            else
                            {
                                list.claimData.objClaim.ReferralDate = new DateTime();
                            }

                        }
                        context.Claims.InsertOnSubmit(list.claimData.objClaim);
                        context.SubmitChanges(); //Save changes in to data base

                        //archive old claim after SubmitChanges() to ensure that a new version of this claim was added to db /abovtenko
                        if (archive) {
                            model.ArchiveClaim(list.claimData.objClaim.ClaimRefNu);
                        }

                        ClaimID = list.claimData.objClaim.ClaimID;
                    }
                }
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return  new HttpResponseMessage(HttpStatusCode.BadRequest);
            }

            return new HttpResponseMessage(HttpStatusCode.OK) {
                Content = new StringContent(ClaimID.ToString())
            };
        }


        /// <summary>
        /// Checks if the claim employe has any open records and return a result with two integers. # of open claims and # of historical claims
        /// </summary>
        /// <param name="Employee"> DTO of employee</param>
        /// <returns></returns>
        [HttpPost]
        [Route("CheckIfDuplicateClaim")]
        [SwaggerResponse(HttpStatusCode.OK, "returns OK",typeof(DetectDuplicateClaimResult))]
        public HttpResponseMessage CheckIfDuplicateClaim([FromBody]DuplicateEmpCheck Employee)
        {
            if(context.CheckIfTokenValid(Employee.Token) != 10001)
            {
                return new HttpResponseMessage(HttpStatusCode.Unauthorized)
                {
                    Content = new StringContent("Invalid token")
                }; 
            }
            if(String.IsNullOrEmpty(Employee.EmpFirstName) || String.IsNullOrEmpty(Employee.EmplastName) || Employee.DOB == null)
            {
                return new HttpResponseMessage(HttpStatusCode.BadRequest)
                {
                    Content = new StringContent("Client ID, First name, Last name and date of birth must be specified")
                };
            }

            return new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(context.DetectDuplicateClaim(Employee.ClientID, Employee.EmpNu, Employee.EmpFirstName, Employee.EmplastName, Employee.DOB, Employee.SIN)))
            };
        }

    }
    //DTO for duplicate claim check
    public class DuplicateEmpCheck
    {
        public int ClientID { get; set; }
        public string EmpNu { get; set; }
        public string EmpFirstName { get; set; }
        public string EmplastName { get; set; }
        public DateTime DOB { get; set; }
        public string SIN { get; set; }
        public string Token { get; set; }
    }





    public class ClaimList
    {
        public ClaimDetails claimData { get; set; }
    }
    //All the claim realted objects are created here 
    public class ClaimDetails
    {
        public Claim objClaim { get; set; }
        public List<Claim_Emp_Schedule> objSch { get; set; }
        //public List<Billable> objBill { get; set; }
        public Claim_Employee objEmp { get; set; }
        public List<Claim_Date> objDates { get; set; }
        public Claim_Emp_JobDetail objJob { get; set; }
        public Claim_Emp_PayDetail objPay { get; set; }
        public Claim_Employee_PayRoll objPayroll { get; set; }
        public List<Claim_Emp_Payroll_Earning> objEarn { get; set; }
        public List<Claim_Emp_Payroll_Offset> objOffset { get; set; }
        public List<Claim_Emp_Payroll_PreDi> objDisability { get; set; }
        public List<Claim_Emp_Payroll_Insurance> objIns { get; set; }
        public Claim_Emp_RotSchedule objRot { get; set; }
        public Claim_Emp_RegSchedule objReg { get; set; }
        public List<Claim_Date> objDoc { get; set; }
        public List<Claim_Emp_ContactTypeDetail> objContactType { get; set; }
        public List<Claim_AbsenceDate> objAbs { get; set; }
        public List<Claim_Contact> objCon { get; set; }
        public List<Incident> objInc { get; set; }
        public List<Claim_Absence> objAbsence { get; set; }
        public List<Claim_CPP_Application> objCPP { get; set; }
        public List<Claim_GRTW_Schedule> objGRTW { get; set; }
        public List<Claim_Rehabilitation> objRehab { get; set; }
        public Claim_AdditionalDetail objAdditionalDetails {get; set;}
    }
    // I created the class to incorporate the billing with comments 
    //public class Billable
    //{
    //    public Claim_Comment objComm { get; set; }
    //    public Claim_BillingDetail objBilling { get; set; }
    //}
    // I created the class to incorporate the incident with all the information related to incident 
    public class Incident
    {
        public Claim_ICDCM objIncident { get; set; }
        public List<Claim_ICDCM_Witness> objWitness { get; set; }
        public List<Claim_ICDCM_Limitation> objLimit { get; set; }
        public List<Claim_Injury_CorrAction> objAct { get; set; }
        public List<Damage> objDam { get; set; }
        public List<Category> objCat { get; set; }
    }
    public class Damage
    {
        public Claim_ICDCM_CollateralDamage objDamage { get; set; }
        public Claim_ICDCM_Collateral_Animal objAni { get; set; }
        public Claim_ICDCM_Collateral_Property objProp { get; set; }
    }
    public class Category
    {
        public Claim_ICDCMCategory objCategory { get; set; }
        public List<Claim_Injury_BodyPart> objPart { get; set; }
        public List<Claim_Injury_Medication> objMed { get; set; }
        public List<Claim_Injury_Activity> objActivities { get; set; }
        public Cause objCause { get; set; }
        //public List<Claim_Injury_Diagnosi> objDia { get; set; }
        //
    }
    public class Cause
    {
        public Claim_Injury_Cause objCauseFields { get; set; }
        public List<Claim_Injury_Cause_EnvironmentFactor> objEnvironmentFactors { get; set; }
        public List<Claim_Injury_Cause_EquipmentInvolved> objEquipmentInvolved { get; set; }
        public List<Claim_Injury_Cause_HumanFactor> objHumanFactors { get; set; }
        public List<Claim_Injury_Cause_InjuryLocation> objInjuryLocations { get; set; }
        public List<Claim_Injury_Cause_WeatherCondition> objWeatherConditions { get; set; }
    }
}
