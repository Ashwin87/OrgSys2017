using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using Swashbuckle.Swagger.Annotations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{       /* Author:      Aaron St Germain
         * Created:     2018-04-16
         * Updated:     
         * Description: User API controller
         */
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/{token}/Users")]
    public class UserController : ApiController
    {
        public OrgSys2017DataContext con = new OrgSys2017DataContext();

        //Get's a list of internal users and returns it has json
        [HttpGet]
        [Route("GetInternalUsers/")]
        public string GetInternalUsers(string token)
        {
            return JsonConvert.SerializeObject(con.GetInternalUsers(token), Formatting.None);
        }

        //Get's a list of all the internal users info
        [HttpGet]
        [Route("all/")]
        public string GetAllUsersInternalInfo(string token)
        {
            return JsonConvert.SerializeObject(con.GetAllUsersInternalInfo(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetUsersAssignedToClient/{ClientID}/")]
        public string GetUsersAssignedToClient(string token, string ClientID)
        {
            return JsonConvert.SerializeObject(con.GetUsersAssignedToClient(token, ClientID), Formatting.None);
        }
                
        //Gets all clients assigned to a user
        [HttpGet]
        [Route("{UserID}/clients/all")]
        public string GetClientsAssignedToUser(string token, string UserID)
        {
            return JsonConvert.SerializeObject(con.GetClientsAssignedToUser(token, UserID), Formatting.None);
        }

        //Gets a users profile information based on login token
        [HttpGet]
        [Route("profile")]
        public HttpResponseMessage GetUserProfile(string token)
        {
            try
            {
                using (OrgSys2017DataContext context = new OrgSys2017DataContext())
                {
                    UserProfile profile = new UserProfile();
                    var USER_ID = context.GetUserIDSession(token).SingleOrDefault().UserID;

                    //gets the two most recent sessions by ther user
                    var LastLoginTime = (from Session in context.Sessions
                                         where Session.UserID == USER_ID.ToString()
                                         orderby Session.SessionID descending
                                         select Session).Take(2).ToList();

                    var UserName = (from User_Profile in context.User_Profiles
                                         where User_Profile.UserID == USER_ID
                                         select User_Profile.EmpFirstName + " " + User_Profile.EmpLastName);

                    profile.USER_ID = USER_ID;
                    profile.Name = UserName.First();
                    profile.previousSessions = LastLoginTime;

                    //return a json object of the 2 most recent sessions
                    return Request.CreateResponse(HttpStatusCode.OK,JsonConvert.SerializeObject(profile));
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.BadRequest);
            }
            
        }

        [HttpGet]
        [Route("user")]
        public string GetUser(string token)
        {
            return JsonConvert.SerializeObject(con.GetUser(token), Formatting.None);
        }

        [HttpGet]
        [Route("user/clients")]
        public string GetUserClients(string token)
        {
            return JsonConvert.SerializeObject(con.GetClients(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetServicePermissionsExternal/{userID}/{ClientID}")]
        public string GetServicePermissionsExternal(int userID, int clientID)
        {
            return JsonConvert.SerializeObject(con.GetUserServicePermissions(userID, clientID), Formatting.None);
        }

        [HttpPost]
        [Route("UpdateUserServicePermissions/{userID}")]
        public HttpResponseMessage UpdateUserServicePermissions([FromBody]string NewPermissionsJson, int userID)
        {
            List<User_Service_Permission> NewPermissions = JsonConvert.DeserializeObject<List<User_Service_Permission>>(NewPermissionsJson);

            //delete current permissions
            var CurrentPermissions = con.User_Service_Permissions.Where(i => i.UserID == userID);
            foreach(var perm in CurrentPermissions)
            {
                con.User_Service_Permissions.DeleteOnSubmit(perm);
            }

            //add new permissions
            foreach(var perm in NewPermissions)
            {
                con.User_Service_Permissions.InsertOnSubmit(perm);
            }
            con.SubmitChanges();
            return new HttpResponseMessage(HttpStatusCode.OK);          
        }

        //Ability to assign multiple users to a client or multiple clients to a user
        [HttpPost]
        [Route("assign/client/")]
        public HttpStatusCode AssignUsersToClient(string token,[FromBody]string Users)
        {
            var users = JsonConvert.DeserializeObject<Users>(Users);
            if (!hasAuthorizedRole(con, token))
                return HttpStatusCode.Forbidden;

            foreach (User_Group user_group in users.objUsers)
            {
                user_group.AssignDate = user_group.AssignDate ?? DateTime.Now;
                user_group.DateFrom = user_group.DateFrom ?? DateTime.Now;
                user_group.DateTo = user_group.DateTo ?? DateTime.Now.AddYears(1);

                con.User_Groups.InsertOnSubmit(user_group);
            }
            try
            {
                con.SubmitChanges();
                return HttpStatusCode.OK;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return HttpStatusCode.InternalServerError;
            }
        }

        //Ability to remove a user from a client
        [HttpPost]
        [Route("usergroup/{UserGroupID}/")]
        public string ExpireUserAssignedToClient(string token, string UserGroupID)
        {
            return JsonConvert.SerializeObject(con.ExpireUserAssignedToClient(token, UserGroupID));
        }

        //Update a users expiry date
        [HttpPost]
        [Route("update/usergroup/{UserGroupID}/{DateTo}")]
        public HttpStatusCode UpdateExpiryDateForUser(string token, string UserGroupID, string DateTo)
        {
            var context = new OrgSys2017DataContext();
            int UserGroupInt = -1;

            DateTime DateToParsed = DateTime.Parse(DateTo);
            Int32.TryParse(UserGroupID, out UserGroupInt);

            var UserGroupQuery = from UG in context.User_Groups
                            where UG.GroupID == UserGroupInt
                            select UG;

            foreach(User_Group user in UserGroupQuery)
            {
                user.DateTo = DateToParsed;
            }

            try
            {
                context.SubmitChanges();
                return HttpStatusCode.OK;
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return HttpStatusCode.InternalServerError;
            }
        }

        [HttpPost]
        [Route("register")]
        public HttpResponseMessage Register(string token, [FromBody]UserRegistration user)
        {
            try
            {
                if (!hasAuthorizedRole(con, token))
                    return Request.CreateResponse(HttpStatusCode.Forbidden);

                var salt = MembershipProvider.CreateNewSalt();
                var hash = MembershipProvider.GenerateHash(user.PasswordClear, salt);

                var userId = con.OnboardUser(user.Username, hash, Convert.ToBase64String(salt), user.ClientID, user.LastName, user.FirstName, user.DOB, user.Email, user.UserTypeID, user.DivisionID);
                var role = new User_Role
                {
                    Role_ID = user.RoleID,
                    UserID = userId,
                    DateCreated = DateTime.Now,
                    isActive = true
                };

                con.User_Roles.InsertOnSubmit(role);
                con.SubmitChanges();

                return Request.CreateResponse(HttpStatusCode.OK, userId);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpGet]
        [Route("portal")]
        public HttpResponseMessage GetPortalUsers(string token)
        {
            try
            {
                var users = con.GetPortalUsers(token);

                return Request.CreateResponse(HttpStatusCode.OK, users);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("{userId}/role/{userRoleId}")]
        public HttpResponseMessage UpdateUserRole(string token, int userId, int userRoleId, [FromBody] User_Role userRole)
        {
            try
            {
                if (!hasAuthorizedRole(con, token))
                    return Request.CreateResponse(HttpStatusCode.Forbidden);

                var target = con.User_Roles.Single(x => x.User_Role_ID == userRoleId);
                if (target == null)
                    return Request.CreateResponse(HttpStatusCode.NotFound);

                target.Role_ID = userRole.Role_ID;
                con.SubmitChanges();

                return Request.CreateResponse(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("{userId}")]
        public HttpResponseMessage UpdateUser(string token, int userId, [FromBody] User user)
        {
            try
            {
                if (!hasAuthorizedRole(con, token))
                    return Request.CreateResponse(HttpStatusCode.Forbidden);

                var target = con.Users.Single(x => x.UserID == userId);
                if (target == null)
                    return Request.CreateResponse(HttpStatusCode.NotFound);

                target.Active = user.Active;
                con.SubmitChanges();

                return Request.CreateResponse(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("employeeoptionsInternal/{clientId}")]
        public HttpResponseMessage EmployeeOptionsInternal(string token, string clientId)
        {
            try
            {
                var clientDivisions = con.GetClientDivisions(Convert.ToInt32(clientId));
                List<int ?> divisionIds = clientDivisions.Select(division => division.ClientID).ToList();
                var userProfiles = (from UserProfile in con.User_Profiles
                                    where divisionIds.Contains(UserProfile.ClientID)
                                    select UserProfile).ToList();
                return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(userProfiles));
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }     
        }

        [HttpPost]
        [Route("employeeoptionsExternal")]
        public HttpResponseMessage EmployeeOptionsExternal(string token)
        {
            try
            {
                var clientId = con.GetClientIDBySession(token).SingleOrDefault().ClientID;
                var clientDivisions = con.GetClientDivisions(Convert.ToInt32(clientId));
                List<int?> divisionIds = clientDivisions.Select(division => division.ClientID).ToList();
                //using the same filter(s) as for claim since user cannot create a claim for an employee they cannot view
                var filters = con.GetFilteredData(token, "Claim").ToList();

                if(filters.FindIndex(f => f.FilterValue == "DIVISION_TREE") > -1)
                {
                    var userProfiles = (from UserProfile in con.User_Profiles
                                        where divisionIds.Contains(UserProfile.ClientID)
                                        select UserProfile).ToList();
                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(userProfiles));
                }
                else if(filters.FindIndex(f => f.FilterValue == "DIVISION") > -1)
                {
                    var userProfiles = (from UserProfile in con.User_Profiles
                                        where UserProfile.ClientID == clientId
                                        select UserProfile).ToList();
                    return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(userProfiles));
                } else
                {
                    return Request.CreateResponse(HttpStatusCode.Forbidden);
                }
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        public bool hasAuthorizedRole(OrgSys2017DataContext context, string token)
        {
            var roles = context.GetRolesByUser(token).ToList();
            foreach (var userRole in roles)
            {
                if (userRole.UserType == 1) //is internal user
                    break;
                if (userRole.Role_ID != 2) //is not a portal manager; assumes portal user only has one role
                    return false;
            }

            return true;
        }

    }
    //List class for user_groups
    public class Users
    {
        public List<User_Group> objUsers { get; set; }
    }

    public class UserProfile
    {
        public string Name { get; set; }
        public int USER_ID { get; set; }
        public List<Session> previousSessions { get; set; }
        public string DistroEmailTo { get; set; }
        public string DistroEmailFrom { get; set; }
    }

    public class UserRegistration
    {
        public string Username { get; set; }
        public string PasswordClear { get; set; }
        public string LastName { get; set; }
        public string FirstName { get; set; }
        public string EmployeeNumber { get; set; }
        public string DOB { get; set; }
        public string Email { get; set; }
        public int ClientID { get; set; }
        public int UserTypeID { get; set; }
        public int RoleID { get; set; }
        public int DivisionID { get; set; }
    }

    public class EmployeeOption
    {
        public int ProfileID { get; set; }
        public string EmpFirstName { get; set; }
        public string EmpLastName { get; set; }
    }
}