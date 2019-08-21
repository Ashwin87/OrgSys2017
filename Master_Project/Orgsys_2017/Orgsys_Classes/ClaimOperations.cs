using DataLayer;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http.Results;

namespace Orgsys_2017.Orgsys_Classes
{
    public class ClaimOperations
    {

        public void SaveClaim(Claim claimObj)
        {
            HttpClient client = new HttpClient();
            string path = "http://localhost:49627/";
            client.BaseAddress = new Uri(path);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));


            try
            {
                string claimData = JsonConvert.SerializeObject(claimObj, Formatting.Indented, new JsonSerializerSettings
                {
                    PreserveReferencesHandling = PreserveReferencesHandling.Arrays,
                    ReferenceLoopHandling = ReferenceLoopHandling.Ignore
                });

                var result = client.PostAsJsonAsync("api/Claim/SaveClaims", claimData).Result;
               
            }
            catch (Exception e)
            {
                var me = e.Message;
            }
          
        }

       
    }
}