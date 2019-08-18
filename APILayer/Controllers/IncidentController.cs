using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using DataLayer;
using Elmah;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Swashbuckle.Swagger.Annotations;
using System.Linq;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /*Created By   : Sam Khan
      Create Date  : 2017 -05-18
      Update Date  : 2017-05-18 [Added comments and did code clean up]
      Description  : It grabs the incident and all of it's sub categories information
      Updated by   : Sam Khan*/
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Incident")]
    public class IncidentController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();
        // It gets all the Incident details of the respective Claim.
        [HttpGet]
        [Route("GetIncidentDetails/{ClaimID}")]
        public string GetIncidentDetails(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetIncidentDetails(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Wintess details of all the Incidents
        [HttpGet]
        [Route("GetICDCMWitness/{ClaimID}")]
        public string GetICDCMWitness(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMWitness(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Damage details of all the Incidents
        [HttpGet]
        [Route("GetICDCMDamage/{ClaimID}")]
        public string GetICDCMDamage(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMDamage(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Animal damage details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCColAni/{ClaimID}")]
        public string GetICDCMCColAni(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMColAni(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Property damage details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCColProp/{ClaimID}")]
        public string GetICDCMCColProp(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMColProp(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Category details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCategory/{ClaimID}")]
        public string GetICDCMCategory(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCat(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Activities details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCatAct/{ClaimID}")]
        public string GetICDCMCatAct(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCatAct( ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Cause details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCatCause/{ClaimID}")]
        public string GetICDCMCatCause(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCatCause(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        //Gets all Cause - Environment Factors for a claim
        //[HttpGet]
        //[Route("GetCauseEnvironmentFactors/{ClaimID}")]
        //public string GetCauseEnvironmentFactors(int ClaimID)
        //{
        //    return JsonConvert.SerializeObject(context.GetCauseEnvironmentFactors(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        //}
        ////Gets all Cause - Equipments Involved for a claim
        //[HttpGet]
        //[Route("GetCauseEquipmentInvolved/{ClaimID}")]
        //public string GetCauseEquipmentInvolved(int ClaimID)
        //{
        //    return JsonConvert.SerializeObject(context.GetCauseEquipmentInvolved(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        //}
        ////Gets all Cause - Human Factors for a claim
        //[HttpGet]
        //[Route("GetCauseHumanFactor/{ClaimID}")]
        //public string GetCauseHumanFactor(int ClaimID)
        //{
        //    return JsonConvert.SerializeObject(context.GetCauseHumanFactor(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        //}
        ////Gets all Cause - Injury Locations for a claim
        //[HttpGet]
        //[Route("GetCauseInjuryLocation/{ClaimID}")]
        //public string GetCauseInjuryLocation(int ClaimID)
        //{
        //    return JsonConvert.SerializeObject(context.GetCauseInjuryLocation(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        //}
        ////Gets all Cause - Weather Conditions for a claim
        //[HttpGet]
        //[Route("GetCauseWeatherCondition/{ClaimID}")]
        //public string GetCauseWeatherCondition(int ClaimID)
        //{
        //    return JsonConvert.SerializeObject(context.GetCauseWeatherCondition(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        //}
        // It gets all the Diagnosis details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCatDia/{ClaimID}")]
        public string GetICDCMCatDia(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCatDia(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Body Part details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCatPart/{ClaimID}")]
        public string GetICDCMCatPart(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCatPart(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Medication details of all the Incidents
        [HttpGet]
        [Route("GetICDCMMedication/{ClaimID}")]
        public string GetICDCMMedication(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCatMedication(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the limitation details of all the Incidents
        [HttpGet]
        [Route("GetICDCMLimitation/{ClaimID}")]
        public string GetICDCMLimitation(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMLimit(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        // It gets all the Cor Action details of all the Incidents
        [HttpGet]
        [Route("GetICDCMCorAction/{ClaimID}")]
        public string GetICDCMCorAction(int ClaimID)
        {
            return JsonConvert.SerializeObject(context.GetICDCMCorAction(ClaimID), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
       
        //It gets all the sections for Incident Details and serilizes them into one json.
        [HttpGet]
        [Route("GetAllSectionsCompiled/{ClaimID}")]
        public string GetAllSectionsCompiled(int ClaimID)
        {
            var witness = context.GetICDCMWitness(ClaimID);
            var incidents = context.GetIncidentDetails(ClaimID);
            string witnesses = JsonConvert.SerializeObject(GetICDCMWitness(ClaimID));

            foreach (var incident in incidents)
            {
                Console.WriteLine(incident);
            }
            return witnesses;
        }
        //Get the list of diagnosis for incident details section
        [HttpGet]
        [Route("GetList_Diagnosis")]
        public string GetList_Diagnosis()
        {
            return JsonConvert.SerializeObject(context.GetList_Diagnosis(), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }
        //Get's the list of incident categories for incident details section
        [HttpGet]
        [Route("GetList_InjuryCategories")]
        public string GetList_InjuryCategories()
        {
            return JsonConvert.SerializeObject(context.GetList_InjuryCategories(), Formatting.None, new IsoDateTimeConverter() { DateTimeFormat = "yyyy-MM-dd" });
        }

        /// <summary>
        /// Returns a list of weather conditions associated with a claims cause section
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns a list of weather conditions associated with a claims cause section", typeof(List<Claim_Injury_Cause_WeatherCondition>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("WeatherConditions/{causeId}")]
        public HttpResponseMessage WeatherConditions(int causeId)
        {
            try
            {
                var weatherConditions = (from WeatherCondition in context.Claim_Injury_Cause_WeatherConditions
                                               where WeatherCondition.CauseID == causeId
                                               select WeatherCondition.Value).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(weatherConditions));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Returns a list of environment factors associated with a claims cause section
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns a list of environment factors associated with a claims cause section", typeof(List<Claim_Injury_Cause_EnvironmentFactor>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("EnvironmentFactors/{causeId}")]
        public HttpResponseMessage EnvironmentFactors(int causeId)
        {
            try
            {
                var environmentFactors = (from EnvironmentFactor in context.Claim_Injury_Cause_EnvironmentFactors
                                          where EnvironmentFactor.CauseID == causeId
                                          select EnvironmentFactor.Value).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(environmentFactors));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Returns a list of the equipment involved associated with a claims cause section
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns a list of the equipment involved associated with a claims cause section", typeof(List<Claim_Injury_Cause_EquipmentInvolved>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("EquipmentInvolved/{causeId}")]
        public HttpResponseMessage EquipmentInvolved(int causeId)
        {
            try
            {
                var equipmentInvolved = (from EquipmentInvolved in context.Claim_Injury_Cause_EquipmentInvolveds
                                         where EquipmentInvolved.CauseID == causeId
                                         select EquipmentInvolved.Value).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(equipmentInvolved));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Returns a list of human factors associated with a claims cause section
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns a list of human factors associated with a claims cause section", typeof(List<Claim_Injury_Cause_HumanFactor>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("HumanFactors/{causeId}")]
        public HttpResponseMessage HumanFactors(int causeId)
        {
            try
            {
                var humanFactors = (from HumanFactors in context.Claim_Injury_Cause_HumanFactors
                                    where HumanFactors.CauseID == causeId
                                    select HumanFactors.Value).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(humanFactors));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>
        /// Returns a list of injury locations associated with a claims cause section
        /// </summary>
        [SwaggerResponse(HttpStatusCode.OK, "Returns a list of injury locations associated with a claims cause section", typeof(List<Claim_Injury_Cause_InjuryLocation>))]
        [SwaggerResponse(HttpStatusCode.InternalServerError, "Returns 500", null)]
        [HttpGet]
        [Route("InjuryLocations/{causeId}")]
        public HttpResponseMessage InjuryLocations(int causeId)
        {
            try
            {
                var injuryLocations = (from InjuryLocations in context.Claim_Injury_Cause_InjuryLocations
                                       where InjuryLocations.CauseID == causeId
                                       select InjuryLocations.Value).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(injuryLocations));
            }
            catch (System.Exception e)
            {
                ErrorSignal.FromCurrentContext().Raise(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }
    }
}
