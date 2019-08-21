using DataLayer;
using Swashbuckle.Swagger;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.Description;

namespace APILayer.Controllers.DataAnnotations
{
    public class LanguageHeaderIOFilter : IOperationFilter
    {
        OrgSys2017DataContext _context = new OrgSys2017DataContext();
        public void Apply(Operation operation, SchemaRegistry schemaRegistry, ApiDescription apiDescription)
        {
            if (operation.parameters == null)
            {
                operation.parameters = new List<Parameter>();
            }

            var languages = _context.Languages.Select(r => r.ISOAbbr).ToArray();

            operation.parameters.Add(new Parameter
            {
                name = "Language",
                @in = "header",
                type = "string",
                required = true,
                @enum = languages,
                @default = "en-ca"
            });


        }
    }
}