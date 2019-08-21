using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace APILayer.Controllers
{
    /* Created By   : Sam Khan
      Create Date  : 2017 -06-26
      Description  : It validates if the session token is valid 
     */

    [RoutePrefix("api/Validate")]
    public class ValidateController : ApiController
    {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();
        [HttpGet]
        [Route("CheckIfTokenValid/{token}")]
        public string CheckIfTokenValid(string token)
        {
            return JsonConvert.SerializeObject(context.CheckIfTokenValid(token), Formatting.None);
        }

        //object classes for inserting validation code
        public class ValidateCodeClass
        {
            public ValidateCodeDetail codeData { get; set; }
        }
        public class ValidateCodeDetail
        {
            public User_Registration obj_Con_valid { get; set; }
        }

        [HttpPost]
        [Route("AddRegistrationCode/")]
        public string Post([FromBody]ValidateCodeClass registrationCode)
        {
            string Code = "";
            try
            {
                using (var db = new OrgSys2017DataContext())
                {
                    db.User_Registrations.InsertOnSubmit(registrationCode.codeData.obj_Con_valid);
                    db.SubmitChanges();
                    Code = registrationCode.codeData.obj_Con_valid.RegistrationCode;
                }
            }
            catch (Exception ex)
            {

                ExceptionLog.LogException(ex);

            }

            return Code;
        }

        //object classes for checking validation code
        public class ValidateCheckClass
        {
            public ValidateCheckDetail checkCodeData { get; set; }
        }
        public class ValidateCheckDetail
        {
            public User_Registration obj_Con_Check { get; set; }
        }



        [HttpGet]
        [Route("CheckRegistrationCode/{code}")]
        public string CheckRegistrationCode(string code)
        {

            return JsonConvert.SerializeObject(context.CheckRegistrationCode(code), Formatting.None);

        }
    }
}

