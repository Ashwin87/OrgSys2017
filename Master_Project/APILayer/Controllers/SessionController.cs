using DataLayer;
using System;
using System.Data.Linq;
using System.Linq;
using System.Net;
using Elmah;
using Swashbuckle.Swagger.Annotations;
using System.Net.Http.Headers;
using Orgsys_2017.Orgsys_Classes;
using System.Web.Http;
using System.Net.Http;
using Newtonsoft.Json;

namespace APILayer.Controllers
{
    /// <summary>
    /// API endpoint for controling session timeout
    /// </summary>
    [System.Web.Http.RoutePrefix("api/session")]
    public class SessionController : ApiController
    {

        /// <summary>
        /// Returns true if session state is valid
        /// </summary>
        /// <param name="token">session token window.token</param>
        [HttpPost]
        [Route("SessionTracker/{token}/{ActivePing}")]
        public HttpResponseMessage SessionTracker(string token, bool ActivePing)
        {
            HttpResponseMessage message = new HttpResponseMessage();
            using (var _ctx = new OrgSys2017DataContext())
            {
                try
                {
                    if (_ctx.Sessions.Count(i => i.SessionToken == token) > 0)
                    {
                        if (ActivePing)
                        {
                            _ctx.UpdateSessionLastValidDate(token);
                            message.StatusCode = HttpStatusCode.OK;
                            message.Content = new StringContent("");
                        }
                        else
                        {
                            DateTime LastActiveDate = _ctx.Sessions.Single(i => i.SessionToken == token).DateLastActive ?? DateTime.MinValue;
                            if (!(LastActiveDate.AddMinutes(60) > DateTime.Now))
                            {
                                RemoveSessionByToken(token);
                                message.StatusCode = HttpStatusCode.Unauthorized;
                                message.Content = new StringContent("Expired");
                            }
                            message.StatusCode = HttpStatusCode.OK;
                            message.Content = new StringContent("");
                        }
                    }
                    else
                    {
                        message.StatusCode = HttpStatusCode.Unauthorized;
                        message.Content = new StringContent("Kicked");
                    }
                }
                catch
                {
                    _ctx.ChangeConflicts.ResolveAll(RefreshMode.KeepChanges);
                    _ctx.SubmitChanges();
                }
            }
            return message;
        }

        [HttpPost]
        [Route("SessionBrowserInfoUpdate/{token}")]
        public HttpResponseMessage SessionBrowserInfoUpdate([FromBody]string browserInfo, string token)
        {
            BrowserInfo bInfo = JsonConvert.DeserializeObject<BrowserInfo>(browserInfo);
            using (var _ctx = new OrgSys2017DataContext())
            {
                Session session = _ctx.Sessions.FirstOrDefault(i => i.SessionToken == token);
                session.Browser = bInfo.Browser;
                session.IPAdress = bInfo.IPAddress;

                _ctx.SubmitChanges();
            }
            return new HttpResponseMessage() {
                StatusCode = HttpStatusCode.OK
            };
               
        }

        /// <summary>
        /// Remove the Session
        /// </summary>
        [HttpPost]
        [Route("RemoveSessionByToken/{token}")]
        public void RemoveSessionByToken(string token)
        {
            using (var _ctx = new OrgSys2017DataContext())
            {
                try
                {
                    if (_ctx.Sessions.Count(i => i.SessionToken == token) > 0)
                    {
                        _ctx.ArchiveSession(token);
                    }
                }
                catch(Exception e)
                {
                    _ctx.ChangeConflicts.ResolveAll(RefreshMode.OverwriteCurrentValues);
                    _ctx.SubmitChanges();
                }
            }
        }

        [HttpGet]
        [Route("client/{token}/{clientId}")]
        public HttpResponseMessage UpdateSessionClient(string token, int clientId)
        {
            try
            {
                using (var con = new OrgSys2017DataContext())
                {
                    var isSessionActive = con.CheckIfTokenValid(token) == 10001;
                    if (!isSessionActive)
                        return Request.CreateResponse(HttpStatusCode.Unauthorized);

                    var session = con.Sessions.Single(x => x.SessionToken == token);
                    var user = con.Users.Single(x => x.UserID == int.Parse(session.UserID));
                    var isInternalUser = user.UserType == 1;
                    //all internal users have a default clientId of 0 in session table
                    var hasPermission = (isInternalUser && clientId == 0) ? true : con.ClientDivisionUserViews.Any(x => x.UserID == user.UserID && x.RootClientID == clientId); 

                    if(!hasPermission || !isInternalUser)
                        return Request.CreateResponse(HttpStatusCode.Forbidden);

                    con.Sessions.Single(x => x.SessionToken == token).ClientID = clientId + "";
                    con.SubmitChanges();

                    return Request.CreateResponse(HttpStatusCode.OK);
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }
    }

    public class BrowserInfo {
        public string Browser { get; set; }
        public string IPAddress { get; set; }
    }

}