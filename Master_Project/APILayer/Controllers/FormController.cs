using DataLayer;
using Newtonsoft.Json;
using System.Linq;
using System.Web.Http;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.DataAnnotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /* Created By   : Sam Khan
       Create Date  : 2017 -05-18
       Update Date  : 2017-05-18 [Added comments and did code clean up]
       Description  : It grabs the controls data to create a dynamic form
       Updated by   : Sam Khan*/
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Form")]
    public class FormController : ApiController
    {
        public OrgSys2017DataContext context;
        // Database Context for OrgSys2017 Database
        protected FormController()
        {
            if (context == null)
            {
                context = new OrgSys2017DataContext();
            }
        }
        // It gets all the html controls to create a dynamic form for a specific/generic client
        [HttpGet]
        [Route("GetFormControls/{Token}/{FormID}")]
        public string GetFormControls(string Token, int FormID)
        {
            return JsonConvert.SerializeObject(context.GetFormControls(Token, FormID), Formatting.Indented);
        }

        [HttpGet]
        [SwaggerOperationFilter(typeof(LanguageHeaderIOFilter))]
        [Route("GetFormControlsV2/{Token}/{FormID}")]
        public string GetFormControlsV2(string Token, int FormID)
        {
            return JsonConvert.SerializeObject(context.GetFormControls_V2(Token, FormID, Request.Headers.GetValues("Language").First()), Formatting.None);
        }
        //It gets all the business rules of the respective controls
        [HttpGet]
        [Route("GetBusRules/{Token}/{FormID}")]
        public string GetBusRules(string Token, int FormID)
        {
            return JsonConvert.SerializeObject(context.GetBusRules(Token, FormID), Formatting.None);
        }
        //It gets all the service rules of the respective controls
        [HttpGet]
        [Route("GetServicesRules")]
        public string GetServicesRules()
        {
            return JsonConvert.SerializeObject(context.GetServicesRules(), Formatting.None);
        }
        //It gets the table order from data base
        [HttpGet]
        [Route("GetTableOrder/{isOldOrgsys}")]
        public string GetTableOrder(bool isOldOrgsys)
        {
            return JsonConvert.SerializeObject(context.GetTableOrder(isOldOrgsys), Formatting.None);
        }
    }
}
