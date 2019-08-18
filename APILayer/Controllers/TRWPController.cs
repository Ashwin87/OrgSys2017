using DataLayer;
using System.Web.Http;
using Newtonsoft.Json;
using System;
using Orgsys_2017.Orgsys_Classes;
using System.Collections.Generic;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/TRWP")]
    public class TRWPController : ApiController {
        public OrgSys2017DataContext context = new OrgSys2017DataContext();

        [HttpPost]
        [Route("SaveTRWP")]
        public void SaveTRWP([FromBody]string trwpData) {
            Connection con = new Connection();           
            TRWPList trwplist = JsonConvert.DeserializeObject<TRWPList>(trwpData);             
            string cols = "";
            string vals = "";            
           

            if (trwplist != null) {
                try {
                    foreach (TRWPData col in trwplist.trwpData) {
                        cols += "[" + col.ColName + "],";
                        vals += "'" + col.ColVal + "',";
                    }

                    context.TRWPSave(cols.Substring(0, cols.Length - 1), vals.Substring(0, vals.Length - 1));                   
                }
                catch (Exception ex) {
                    ExceptionLog.LogException(ex);
                }
            }
        }
    }

    public class TRWPData {
        public string ColName { get; set; }
        public string ColVal { get; set; }
    }

    public class TRWPList {
        public List<TRWPData> trwpData { get; set; }
    }


}