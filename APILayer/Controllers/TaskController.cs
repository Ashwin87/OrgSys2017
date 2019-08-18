using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Linq;
using System.Collections.Generic;
using Swashbuckle.Swagger.Annotations;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{       /* Author:      Marie Gougeon
         * Created:     02-17-2017
         * Updated:     Marie 03-21-2018
         * Description: Task API handlers
         * Update:      Added more SP for data collection and updating the DB information (roles, groups, etc)
         */
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Task")]
    public class TaskController : ApiController
    {
        public OrgSys2017DataContext con = new OrgSys2017DataContext();
        
        [HttpPost]
        [Route("AddTask/{token}")]
        public void AddTask(string token, [FromBody] User_Task model)
        {
            try
            {
                con.Add_Task(token, model.TaskName, DateTime.Now, model.DueDate, model.TaskDesc, model.UserAssigned, model.TaskTypeID);
            }
            catch (Exception e) {
                ExceptionLog.LogException(e);
            }
        }

        [HttpPost]
        [Route("Add_ClaimTask/{token}")]
        public IHttpActionResult Add_ClaimTask(string token, [FromBody] User_Task model)
        {
            try
            {
                var user = con.GetUserIDSession(token).SingleOrDefault();
                con.Add_ClaimTask(token, model.TaskName, model.DueDate, model.TaskDesc, user.UserID, model.UserAssigned, model.ClaimID, model.ClaimReferenceNumber);
                return StatusCode(HttpStatusCode.NoContent);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return InternalServerError();
            }
        }

        [HttpGet]
        [Route("AddSystemTask/{token}/{systemTaskNumber}/{claimID}")]
        public string AddSystemTask(string token, int systemTaskNumber, int claimID)
        {
            try{
           
                return JsonConvert.SerializeObject(con.Add_SystemTask(token, systemTaskNumber,claimID), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }

        [HttpGet]
        [Route("GetList_TaskComments/{TaskID}")]
        public string GetList_TaskComments(int TaskID)
        {
            try
            {
                return JsonConvert.SerializeObject(con.GetList_TaskComments(TaskID), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }

        [HttpGet]
        [Route("GetAssignedTasksByClaim/{ClaimID}")]
        public string GetAssignedTasksByClaim(int ClaimID)
        {
            try
            {
                return JsonConvert.SerializeObject(con.GetAssignedTasksByClaim(ClaimID), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }

        [HttpGet]
        [Route("GetTaskComments/{TaskID}")]
        public string GetTaskComments(int TaskID)
        {
            try
            {
                return JsonConvert.SerializeObject(con.GetTaskComments(TaskID), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }

        [HttpGet]
        [Route("GetTaskDetails/{TaskID}")]
        public string GetTaskDetails(int TaskID)
        {
            try
            {
                return JsonConvert.SerializeObject(con.GetTaskDetails(TaskID), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }

        [HttpGet]
        [Route("GetUserInternalSearch_V1/{name}")]
        public string GetUserInternalSearch_V1(string name)
        { 
            try
            {
                return JsonConvert.SerializeObject(con.GetUserInternalSearch_V1(name), Formatting.None);
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "False";
            }
        }

        [HttpPost]
        [Route("UpdateChangeUserTasks")]
        public IHttpActionResult UpdateChangeUserTasks([FromBody] User_Task model) 
        {
            try
            {
                con.UpdateChangeUserTasks(model.TaskID, model.UserAssigned);
                return StatusCode(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return InternalServerError();
            }
        }

        [HttpPost]
        [Route("UpdateDisableTask")]
        public IHttpActionResult UpdateDisableTask([FromBody] User_Task model)
        {
            try
            {
                con.UpdateDisableTask(model.TaskID);
                return StatusCode(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return InternalServerError();
            }
        }

        [HttpPost]
        [Route("UpdatePostponeTask")]
        public IHttpActionResult UpdatePostponeTask([FromBody] User_Task model)
        {
            try
            {
                con.UpdatePostponeTask(model.TaskID, model.DueDate.ToString());
                return StatusCode(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return InternalServerError();
            }
        }

        [HttpPost]
        [Route("UpdateAddCommentsTask/{token}")]
        public IHttpActionResult UpdateAddCommentsTask(string token, [FromBody] User_Task model)
        {
            try
            {
                con.UpdateAddCommentsTask(model.TaskID, model.UserComments, token);
                return StatusCode(HttpStatusCode.NoContent);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return InternalServerError();
            }
        }

        [HttpGet]
        [Route("{token}/calendarfeed")]
        public HttpResponseMessage CalendarFeed(string token)
        {
            try
            {
                var feed = new List<object>();
                var tasks = con.GetUserTasks(token).AsEnumerable();

                foreach (var task in tasks)
                {
                    feed.Add(new {
                        id = task.TaskID,
                        title = task.TaskName,
                        start = task.DueDate,
                        ClaimRefNo=  task.ClaimReferenceNumber,
                        extendedProps = new
                        {
                            createdByName = task.UserCreated,
                            assignedToName = task.UserTaskAssigned,
                            dueDate = task.DueDate,
                            dateCreated = task.CreatedDate,
                            taskName = task.TaskName,
                            taskDescription = task.TaskDesc,
                            taskClassName=task.TaskClassName
                        }
                    });
                }

                var response = Request.CreateResponse(HttpStatusCode.OK);
                response.Content = new StringContent(JsonConvert.SerializeObject(feed));

                return response;
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);            
            }
        }

    }
}