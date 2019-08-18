using DataLayer;
using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

namespace APILayer.Controllers.Auth.Authentication
{
    /// <summary>
    /// Authorization filter class used to validate tokens generated on login. if a token is valid pass. if not set httpstatus code to Unauthorized. created because DRY principle
    /// </summary>
    public class OSIAuthenticationFilter : AuthorizationFilterAttribute
    {
        private static bool SkipAuthorization(HttpActionContext filterContext)
        {
            Contract.Assert(filterContext != null);

            return filterContext.ActionDescriptor.GetCustomAttributes<AllowAnonymousAttribute>(true).Any()
                   || filterContext.ActionDescriptor.ControllerDescriptor.GetCustomAttributes<AllowAnonymousAttribute>(true).Any();
        }
        /// <summary>
        /// Executed before action is called when [OSIAuthenticationFilter] is used in a controller action
        /// </summary>
        /// <param name="actionContext"> http context of action</param>
        /// <param name="cancellationToken"></param>
        public override Task OnAuthorizationAsync(HttpActionContext actionContext, System.Threading.CancellationToken cancellationToken)
        {
            using (var ctx = new OrgSys2017DataContext())
            {
                if (actionContext.Request.Headers.TryGetValues("Authentication", out IEnumerable<string> values) && ctx.CheckIfTokenValid(values.FirstOrDefault()) == 10001)
                {
                    //User is Authorized, complete execution
                    return Task.FromResult<object>(actionContext);
                }
                else if (SkipAuthorization(actionContext))
                {
                    //User is Authorized, complete execution
                    return Task.FromResult<object>(actionContext);
                }
                else
                {
                    actionContext.Response = actionContext.Request.CreateResponse(HttpStatusCode.Unauthorized, "The token provided is not valid.");
                    return Task.FromResult<object>(null);
                }
            }
        }
    }
}
