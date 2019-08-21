using System;
using System.Web.Http;
using DataLayer;
using Orgsys_2017.Orgsys_Classes;
using Newtonsoft.Json;
using System.Linq;
using System.Collections.Generic;
using System.Net.Http;
using System.Net;
using System.Configuration;
using Swashbuckle.Swagger.Annotations;
using APILayer.Models.DTOS;
using System.Web;


/*  Author: Marie Gougeon
*   Created: 01-12-2017
*   Updated: 03-21-2018 - Marie
*   Description: login controller for all api calls at login
*/

namespace APILayer.Controllers {
    [RoutePrefix("api/Login")]
    public class LoginController : ApiController
    {
        //OrgSys2017DataContext con = new OrgSys2017DataContext(ConfigurationManager.ConnectionStrings["OrgsysConnectionString"].ConnectionString);
        //OrgSys2017DataContext con = new OrgSys2017DataContext(@"Data Source=OSI-SQLDEV\DEVDBSQL;Initial Catalog=orgsys2017;User ID=sa;Password=!Saturn42;");
        OrgSys2017DataContext con = new OrgSys2017DataContext();

        /// <summary>
        /// Checks if user is logged in. if they are return their session information.
        /// </summary>
        /// <param name="Username"></param>
        [SwaggerResponse(HttpStatusCode.OK, "Returns session information", typeof(Session))]
        [SwaggerResponse(HttpStatusCode.OK, "Returns null if not logged in", null)]
        [HttpPost]
        [Route("CheckIfLoggedIn")]
        public HttpResponseMessage CheckIfLoggedIn([FromBody] string user_json)
        {

            UserAcc user = JsonConvert.DeserializeObject<UserAcc>(user_json);
            User Dbuser = con.Users.First(i => i.Username == user.username);

            if (!string.IsNullOrEmpty(user.username) && !string.IsNullOrEmpty(user.password))
            {

                var userInfo = con.GetUserInfo(user.username).Single();
                var output = "";

                if (userInfo == null)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound);
                }

                if (userInfo.Active == 0)
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized);
                }

                output = userInfo.UserID.ToString();

                //Grab the salt from the DB to compare
                var DBsalt = MembershipProvider.GetSalt(output);
                //convert it to base64 for compare
                byte[] SaltBytes = Convert.FromBase64String(DBsalt);
                //Grab the hash from the DB to compare
                var DBHash = MembershipProvider.GetHash(output);

                //Use the hash grabbed from the database based on userid and take the password provided by the user.
                //once the password given is verfied match to the hash provided by userid - return bool true
                bool checkhash = MembershipProvider.VerifyHash(user.password, DBHash);
                if (checkhash != true)
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized);
                }

                if (con.Sessions.Any(i => Convert.ToInt32(i.UserID) == Dbuser.UserID))
                {
                    Session session = con.Sessions.OrderByDescending(o => o.DateLastActive)
                        .First(i => Convert.ToInt32(i.UserID) == Dbuser.UserID);
                    SessionInformationDTO informationDto = new SessionInformationDTO()
                    {
                        _DateCreated = session.DateCreated?.ToString("MM/dd/yyyy h:mm tt"),
                        _DateLastActive = session.DateLastActive?.ToString("MM/dd/yyyy h:mm tt"),
                        Token = session.SessionToken
                    };
                    return new HttpResponseMessage(HttpStatusCode.Accepted)
                    {
                        Content = new StringContent(JsonConvert.SerializeObject(informationDto ))
                };
                }
                else
                {
                    return new HttpResponseMessage(HttpStatusCode.OK);
                }
            }
            else
            {
                return Request.CreateResponse(HttpStatusCode.BadRequest);
            }
        }

        private string generateTokenID(string Username, string browser, string ip)
        {
            //Generate token
            string token = MembershipProvider.createToken();
             
            var user = con.GetUserInfo(Username).SingleOrDefault();
            if (user != null)
            {
                con.Add_Session(token, user.UserID.ToString(), user.ClientID.ToString(), browser, ip);
            }

            return token;
        }

        //Checks if User logging in is Internal, External or New - result is URL used for redirect
        [HttpGet]
        [Route("GetPageType/{token}")]
        public string GetPageType(string token)
        {
            return JsonConvert.SerializeObject(con.GetPageType(token), Formatting.None);
        }


        //Validate Login Credentials
        //Username and Password is passed through - Username is validated through checking if exist with userid return
        //Password is validated through
        [HttpPost]
        [Route("LoginCredentials/")]
        public HttpResponseMessage LoginCredentials([FromBody]string user_json)
        {
            try
            {
                //get client IP
                string clientAddress = HttpContext.Current.Request.UserHostAddress;

                UserAcc user = JsonConvert.DeserializeObject<UserAcc>(user_json);                

                if (!string.IsNullOrEmpty(user.username) && !string.IsNullOrEmpty(user.password))
                {
                    var userInfo = con.GetUserInfo(user.username).SingleOrDefault();
                    var output = "";

                    if (userInfo == null)
                    {
                        UserLog(0, 0);
                        return Request.CreateResponse(HttpStatusCode.NotFound);
                    }

                    if (userInfo.Active == 0)
                    {
                        UserLog((int)userInfo.UserID, 4);
                        return Request.CreateResponse(HttpStatusCode.Unauthorized);
                    }

                    output = userInfo.UserID.ToString();

                    //Grab the salt from the DB to compare
                    var DBsalt = MembershipProvider.GetSalt(output);
                    //convert it to base64 for compare
                    byte[] SaltBytes = Convert.FromBase64String(DBsalt);
                    //Grab the hash from the DB to compare
                    var DBHash = MembershipProvider.GetHash(output);

                    //Use the hash grabbed from the database based on userid and take the password provided by the user.
                    //once the password given is verfied match to the hash provided by userid - return bool true
                    bool checkhash = MembershipProvider.VerifyHash(user.password, DBHash);
                    if (checkhash != true)
                    {
                        return Request.CreateResponse(HttpStatusCode.Unauthorized);
                    }
                    //Log success and info of session (browser type, etc)
                    UserLog(Convert.ToInt32(output), 1);

                    var token = generateTokenID(user.username, user.Browser, user.IP);
                    var response = Request.CreateResponse(HttpStatusCode.OK);
                    response.Content = new StringContent(JsonConvert.SerializeObject(new { Token = token }));

                    return response;
                }
                else
                { //if the passsword, username or both are missing, dont even bother!
                    return Request.CreateResponse(HttpStatusCode.BadRequest);
                }
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                UserLog(0, 0);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        //Validate Login Credentials
        //Username and Password is passed through - Username is validated through checking if exist with userid return
        //Password is validated through
        [HttpPost]
        [Route("OldLoginCredentials/{username}/{hashid}")]
        public string OldLoginCredentials(string username, string hashid)
        {
            try
            {
                if (!String.IsNullOrEmpty(username) && !String.IsNullOrEmpty(hashid))
                {
                    var userInfo = con.GetUserInfo(username).SingleOrDefault();
                    var output = "";

                    if (userInfo != null)
                    {

                        output = userInfo.UserID.ToString();

                        //Grab the salt from the DB to compare
                        var DBsalt = MembershipProvider.GetSalt(output);
                        //convert it to base64 for compare
                        byte[] SaltBytes = Convert.FromBase64String(DBsalt);
                        //Grab the hash from the DB to compare
                        var DBHash = MembershipProvider.GetHash(output);

                        var OldHash = MembershipProvider.GetOldHash(Convert.ToInt32(hashid));
                        //Use the hash grabbed from the database based on userid and take the password provided by the user.
                        //once the password given is verfied match to the hash provided by userid - return bool true
                        //bool checkhash = MembershipProvider.VerifyHash(user.password, DBHash);
                        if (DBHash.Equals(OldHash))
                        {
                            //Log success and info of session (browser type, etc)
                            UserLog(Convert.ToInt32(output), 2);

                            return generateTokenID(username, null, null);
                        }
                    }
                    //if the password hash is not a match, the count will be 0
                    UserLog(Convert.ToInt32(output), 0);
                    return null;
                }
                else
                { //if the passsword, username or both are missing, dont even bother!
                    return null;
                }
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                UserLog(0, 0);
                return null;
            }
        }

        public class UserController
        {
            public string UserID { get; set; }
        }

        //Log user attempts to login, and send data to db
        protected void UserLog(int UserID, int Event)
        {
            try
            {
                if (!String.IsNullOrEmpty(UserID.ToString()))
                {
                    String LoginEvent = "";
                    switch (Event)
                    {
                        case 1:
                            LoginEvent = "Successful Internal Orgsys Login";
                            break;
                        case 2:
                            LoginEvent = "Successful External Portal Login";
                            break;
                        case 3:
                            LoginEvent = "Password Config Page";
                            break;
                        case 4:
                            LoginEvent = "Blocked User";
                            break;
                        case 0:
                            LoginEvent = "Incorrect Username or Password";
                            break;
                    }

                    JsonConvert.SerializeObject(con.SetLoginUpdate(UserID, "Chrome", LoginEvent), Formatting.None);

                }
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
            }
        }

        //Validate new Password Credentials when provided on ExternalPasswordConfig.aspx
        [HttpPost]
        [Route("PasswordConfig/{token}")]
        public bool PasswordConfig(string token, [FromBody]UserAcc account)
        {
            bool PasswordConfirmation = ChangePassword(token, account);
            return PasswordConfirmation;
        }

        //Login Attempts Exceed Maximum password attempt, lockout user if username is correct.
        [HttpPost] //REVISE
        [Route("ExceedLoginAttempts/{Username}")]
        public bool ExceedLoginAttempts(String Username)
        {
            bool LoginAttempts = Lockout(Username);
            return LoginAttempts;
        }

        public class UserList
        {
            public String UserInfo { get; set; }
        }
        
        protected bool ChangePassword(string token, UserAcc account)
        {
            try
            {
                var isActive = con.ValidatePasswordRecoveryAttempt(token, account.username) == 1;
                if (isActive)
                {
                    var user = con.GetUserInfo(account.username).SingleOrDefault();
                    if (user != null)
                    { //check if the user actually exists                      
                        string SHASalt = MembershipProvider.CreateNewSaltString();                          //Create Salt String
                        byte[] saltBytes = Convert.FromBase64String(SHASalt);                               //Convert Salt String
                        //Generte Hash and Salt for new password and add it to the Database
                        var SHAHash = MembershipProvider.GenerateHash(account.password, saltBytes);
                        //used only for external, so set permission to 2
                        con.Set_PasswordPermissions(user.UserID.ToString(), SHAHash, SHASalt);

                        return true;
                    }
                    else
                    {
                        return false; //user doesnt exist
                    }
                }
                else
                {
                    return false; //username is null
                }

            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return false; //error occured
            }

        }


        //RECONSTRUCT
        //if username is correctly provided, and password attempts exceed 5 tries, lock user out
        protected Boolean Lockout(String Username)
        {
            try
            {
                if (!String.IsNullOrEmpty(Username))
                {
                    JsonConvert.SerializeObject(con.Set_UserLockout(Username), Formatting.None);
                    return true; //proceed with lockout
                }
                else
                {
                    return false; //username does not exist, nothing happens
                }
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return false; //error occured
            }
        }

        [HttpPost]
        [Route("RecoverPassword")]
        public HttpResponseMessage RecoverPassword([FromBody]string UserName)
        {
            try
            {
                using (var context = new OrgSys2017DataContext())
                {
                    var user = context.GetUserInfo(UserName).SingleOrDefault();
                    if (user != null)
                    {
                        if (user.Email == "")
                        {
                            return Request.CreateResponse(HttpStatusCode.NotFound);
                        }
                        var token = MembershipProvider.createToken();
                        context.CreatePasswordRecoveryAttempt(token, user.ClientID, user.UserID);

                        using (var mail = new EmailController())
                        {
                            var origin = Request.Headers.GetValues("Origin").FirstOrDefault();
                            var email = new
                            {
                                To = user.Email,
                                From = "noreply@orgsoln.com",
                                Subject = "OSI Portal - Recover Password",
                                Body = $"Hello, </br></br>Please click <a href='https://umbrella02.orgsoln.com/Orgsys_Forms/ExternalPasswordConfig?recoverytoken={token}'>here</a> to create a new password.</br>"
                                    + "This link will expire in 2 hours.</br></br></br>Thank you"
                            };

                            mail.Post(null,JsonConvert.SerializeObject(new { emailData = email}));

                            return Request.CreateResponse(HttpStatusCode.OK);
                        }                        
                    }
                    else
                    {
                        return Request.CreateResponse(HttpStatusCode.NotFound);
                    }
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpGet]
        [Route("ValidateRecoveryToken/{token}")]
        public bool ValidateRecoveryToken(string token)
        {
            try
            {
                if (!string.IsNullOrEmpty(token))
                {
                    using (var context = new OrgSys2017DataContext())
                    {
                        var isActive = context.ValidatePasswordRecoveryAttempt(token, "") == 1;
                        return isActive;
                    }
                }
                else
                {
                    return false;
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return false;
            }
        }
        
    }

    public class UserAcc
    {
        public string username { get; set; }
        public string password { get; set; }
        public string IP { get; set; }
        public string Browser { get; set; }
    }
}


