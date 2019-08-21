using DataLayer;
using System.Web.Http;
using Newtonsoft.Json;
using System;
using System.Net;
using Orgsys_2017.Orgsys_Classes;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Roles")]
    public class RolesController : ApiController
    {
        public OrgSys2017DataContext con = new OrgSys2017DataContext();

        [HttpGet]
        [Route("GetAllRoles/")]
        public string GetAllRoles()
        {
            return JsonConvert.SerializeObject(con.GetUserRoles(), Formatting.None);
        }

        [HttpGet]
        [Route("GetRolesByUser/{token}")]
        public string GetRolesByUser(string token)
        {
            return JsonConvert.SerializeObject(con.GetRolesByUser(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetUserTasks/{token}")]
        public string GetUserTasks(string token)
        {
            return JsonConvert.SerializeObject(con.GetUserTasks(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetAssignedTasks/{token}")]
        public string GetAssignedTasks(string token)
        {
            return JsonConvert.SerializeObject(con.GetAssignedTasks(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetAssignedTasks10/{token}")]
        public string GetAssignedTasks10(string token)
        {
            return JsonConvert.SerializeObject(con.GetAssignedTasks10(token), Formatting.None);
        }

        [HttpGet]
        [Route("GetTaskInfo/{token}/{id}")]
        public string GetTaskInfo(string token, int id)
        {
            return JsonConvert.SerializeObject(con.GetTaskInfo(token, id), Formatting.None);
        }

        [HttpGet]
        [Route("GetCompletedTasks/{token}")]
        public string GetCompletedTasks(string token)
        {
            return JsonConvert.SerializeObject(con.GetCompletedTasks(token), Formatting.None);
        }

        [HttpPost]
        [Route("Update_CompleteTask")]
        public IHttpActionResult Update_CompleteTask([FromBody] User_Task model)
        {
            try
            {
                con.UpdateCompleteTasks(model.TaskID, model.UserComments);
                return StatusCode(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return InternalServerError();
            }
        }

        public class Tasks
        {
            public string taskAssignment { get; set; }
            public string TaskTypeID { get; set; }
            public string taskDescription { get; set; }
        }

        public String Post([FromBody] Tasks AddTask)
        {
            return "True";
        }
    }
}
