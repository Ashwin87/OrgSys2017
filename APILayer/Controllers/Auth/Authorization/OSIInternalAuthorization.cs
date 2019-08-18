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

namespace APILayer.Controllers.Auth.Authorization
{
    /// <summary>
    /// auhtorization filter to validate if user is internal
    /// </summary>
    public class OSIInternalAuthorization : AuthorizationFilterAttribute
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
                 if (SkipAuthorization(actionContext))
                {
                    //User is Authorized, complete execution
                    return Task.FromResult<object>(actionContext);
                }

                if (actionContext.Request.Headers.TryGetValues("Authentication", out IEnumerable<string> values) && ctx.IsUserInternal(values.FirstOrDefault()) == 1)
                {
                    //User is Authorized, complete execution
                    return Task.FromResult<object>(actionContext);
                }
                else
                {
                    actionContext.Response = actionContext.Request.CreateResponse(HttpStatusCode.Unauthorized, "The token provided does not have internal access");
                    return Task.FromResult<object>(null);
                }
            }
        }
    }
}
