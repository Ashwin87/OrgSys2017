using DataLayer;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;

namespace APILayer.Controllers
{
    [RoutePrefix("api/servicecontroller")]
    public class ServiceController : ApiController
    {
        private OrgSys2017DataContext context;

        //ROUTE: api/servicecontroller/services/:token
        [HttpGet]
        [Route("services")]
        public string GetServices()
        {
            
                using (context = new OrgSys2017DataContext())
                {
                    return JsonConvert.SerializeObject(context.GetServices());
                }
            
        }

    }
}
