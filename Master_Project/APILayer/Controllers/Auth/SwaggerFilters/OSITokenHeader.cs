using DataLayer;
using Swashbuckle.Swagger;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http.Description;

namespace APILayer.Controllers.Auth.SwaggerFilters
{
    /// <summary>
    /// swagger operation filter to enable entering in an authorization token
    /// </summary>
    public class OSITokenHeader : IOperationFilter
    {
        OrgSys2017DataContext _context = new OrgSys2017DataContext();
        /// <summary>
        /// apply the operation filter
        /// </summary>
        /// <param name="operation"></param>
        /// <param name="schemaRegistry"></param>
        /// <param name="apiDescription"></param>
        public void Apply(Operation operation, SchemaRegistry schemaRegistry, ApiDescription apiDescription)
        {
            if (operation.parameters == null)
            {
                operation.parameters = new List<Parameter>();
            }

            var languages = _context.Languages.Select(r => r.ISOAbbr).ToArray();

            operation.parameters.Add(new Parameter
            {
                name = "Authentication",
                @in = "header",
                type = "string",
                required = true
            });
        }
    }
}
