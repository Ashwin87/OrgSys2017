using APILayer.Controllers.DataAnnotations;
using APILayer.Models.DTOS;
using DataLayer;
using Newtonsoft.Json;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace APILayer.Controllers
{
    [RoutePrefix("api/Multilingual")]
    public class MultilingualController : ApiController
    {
        OrgSys2017DataContext _context = new OrgSys2017DataContext();

        [HttpGet]
        [Route("GetMultilingualObject/{page}/{masterPage}")]
        [SwaggerOperationFilter(typeof(LanguageHeaderIOFilter))]
        [SwaggerResponse(HttpStatusCode.OK, "Return the Multilingual object that contains the control data and the messages", typeof(MultilingualDTO))]
        public HttpResponseMessage GetMultilingualObject(string page, string masterPage)
        {
            Dictionary<string, string> Messages = _context.GetMultilingualMessages(Request.Headers.GetValues("Language").First()).ToDictionary(t => t.Name, t => t.Data);
            var Controls = _context.GetMultilingualControls(Request.Headers.GetValues("Language").First(),page, masterPage).ToArray();

            MultilingualDTO multilingualDto = new MultilingualDTO()
            {
                Controls = Controls,
                Messages = Messages
            };

            return new HttpResponseMessage()
            {
                Content = new StringContent(JsonConvert.SerializeObject(multilingualDto))
            };
        }

        [HttpPost]
        [Route("AddMultilingualControl")]
        public HttpResponseMessage AddControlData([FromBody]MultilingualControlDTO[] controlJson)
        {
            foreach (var controlDTO in controlJson)
            {
                Language_Control control = new Language_Control()
                {
                    ControlID = controlDTO.ControlID,
                    ControlTypeID = controlDTO.Type,
                    Page = controlDTO.Page
                };
                _context.Language_Controls.InsertOnSubmit(control);
                _context.SubmitChanges();
                foreach (var controlData in controlDTO.ControlData)
                {
                    Language_Control_Data Data = new Language_Control_Data()
                    {
                        ControlID = control.Id,
                        Data = controlData.Data,
                        LanguageID = controlData.LanguageID
                    };
                    _context.Language_Control_Datas.InsertOnSubmit(Data);
                    _context.SubmitChanges();
                }
            }
            return new HttpResponseMessage();
        }

       
    }
}
