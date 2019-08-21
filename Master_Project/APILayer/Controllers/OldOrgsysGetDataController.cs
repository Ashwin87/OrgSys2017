using DataLayer;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Configuration;
using System.Web.Http;
using MySql.Data.MySqlClient;
using System.Data;
using APILayer.Models;
using APILayer.Services;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Transactions;
using System.Net.Http;
using System.Net;

namespace APILayer.Controllers
{
    [RoutePrefix("api/OldOrgsysGetData")]
    public class OldOrgsysGetDataController : ApiController
    {
        //mgougeon
        public OrgSys2017DataContext context = new OrgSys2017DataContext();
        MySqlConnection OrgsysdbConn = new MySqlConnection(ConfigurationManager.ConnectionStrings["OldOrgsysConnectionString"].ConnectionString);
        MySqlConnection DemographicdbConn = new MySqlConnection(ConfigurationManager.ConnectionStrings["DemographicConnectionString"].ConnectionString);


        // It gets clients importID from osidbdev //mgougeon
        [HttpGet]
        [Route("GetClientImportID/{Token}")]
        public int GetClientImportID(string Token)
        {
            int result = (int)context.GetClientImportID(Token);
            return result;
        }
        //Get Site from Old Orgsys MySQL based on ImportID //mgougeon
        [HttpGet]
        [Route("GetSiteOldOrgsys/{Token}")]
        public string GetSiteOldOrgsys(string Token)
        {
            var ImportID = GetClientImportID(Token);

            using (MySqlCommand command = new MySqlCommand("PORTALORG_GETSITE", OrgsysdbConn)) {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ImportID", ImportID);
                OrgsysdbConn.Open();
                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();
                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }
        //Get Division based on Site from Old Orgsys MySQL //mgougeon
        [HttpGet]
        [Route("GetDivisionOldOrgsys/{SiteName}/{Token}")]
        public string GetDivisionOldOrgsys(string SiteName, string Token)
        {
            var ImportID = GetClientImportID(Token);
            using (MySqlCommand command = new MySqlCommand("PORTALORG_GETDIV", OrgsysdbConn))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@SiteName", SiteName);
                command.Parameters.AddWithValue("@ImportID", ImportID);
                OrgsysdbConn.Open();
                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();
                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }
        //Get Department based on Division from Old Orgsys MySQL
        [HttpGet]
        [Route("GetDepartmentOldOrgsys/{DivName}/{Token}")]
        public string GetDepartmentOldOrgsys(string DivName, string Token)
        {
            var ImportID = GetClientImportID(Token);
            using (MySqlCommand command = new MySqlCommand("PORTALORG_GETDEPT", OrgsysdbConn))
            {
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@DivName", DivName);
                command.Parameters.AddWithValue("@ImportID", ImportID);
                OrgsysdbConn.Open();
                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();
                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        //Getter Setters for EmpInfo initial setup mgougeon
        public class EmpInfo
        {
            public string tableColumn { get; set; }
            public string colValue { get; set; }
        }

        //mgougeon
        //Check if demographic file exists in db-2, if yes, prepopulate!
        //Autopopulate the Portal (STD for now) with employees from the Old Orgsys Demographic Files
        [HttpGet]
        [Route("GetEmployeeInformationOldOrgsys/{EmployeeName}/{Token}")]
        public string GetEmployeeInformationOldOrgsys(string EmployeeName, string Token)
        {
            var ImportID = GetClientImportID(Token);
            List<EmpInfo> _EmpInfo = new List<EmpInfo>();
            using (MySqlCommand command = new MySqlCommand("ORGSYSPORTAL_CheckIfExists", DemographicdbConn))
            {

                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ImportID", ImportID);
                command.Parameters.AddWithValue("@EmpName", EmployeeName);
                DemographicdbConn.Open();
                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
                Dictionary<string, object> row;
                foreach (DataRow dr in dt.Rows)
                {
                    row = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        row.Add(col.ColumnName, dr[col]);
                    }
                    rows.Add(row);
                }
                DemographicdbConn.Close();
                return serializer.Serialize(rows);
            }
        }

        /*
           * Created By       : Aaron St Germain
             * Description      : Gets the data for claim manager page with the fields defined in PortalClaimManagerFields table for a specific client 
             * 
        */
        [HttpPost]
        [Route("GetPortalClaimManagerData/{Token}/{StatusString}")]
        public HttpResponseMessage GetPortalClaimManagerData(string Token, string StatusString, [FromBody] ClaimManagerFieldList Fields)
        {
            try
            {
                var ImportID = GetClientImportID(Token);
                var employeeID = context.GetOrgsysEmployeeID(Token).SingleOrDefault()?.OrgsysEmployeeID;                
                var filters = context.GetFilteredData(Token, "Claim").ToList();
                var UserRoleName = context.GetUserRole(Token).FirstOrDefault().RoleName;

                var qservice = new QueryService("OSI_New.os_employees", "Claim", ImportID, Token, employeeID);
                if (StatusString == "open")
                {
                    qservice.WhereClauseQueryList.Add($"OSI_New.os_claims.DateClosed is null "); //part of query, not permission
                    qservice.WhereClauseQueryList.Add($"OSI_New.os_claims.id is not null "); 
                }
                else
                {
                    qservice.WhereClauseQueryList.Add($"OSI_New.os_claims.DateClosed is not null "); //part of query, not permission
                }

                if (filters.Count() > 0 || UserRoleName == "OSIUser")        //ensure user has some permissions or is a OSI USer for the client
                {
                    var dataView = context.GetPortalPortalDataView(Token, "Claim").ToList();
                    var query = qservice.BuildQuery(dataView, filters);

                    using (MySqlCommand command = new MySqlCommand(query, OrgsysdbConn))
                    {
                        command.CommandType = CommandType.Text;
                        OrgsysdbConn.Open();
                        MySqlDataAdapter da = new MySqlDataAdapter(command);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        OrgsysdbConn.Close();

                        return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(dt, Formatting.None));
                    }
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.Unauthorized);
                }
                
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [HttpPost]
        [Route("GetReportedCommentsByClaimID/{Token}/{ClaimID}")]
        public HttpResponseMessage GetReportedComments(string Token, string ClaimID)
        {
            try
            {
                if (context.CheckIfTokenValid(Token) == 10001)
                {
                    using (var command = OrgsysdbConn.CreateCommand())
                    {

                        OrgsysdbConn.Open();
                        command.CommandText = "PORTALORG_GetReportedCommentsByClaimID";
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@ClaimID", ClaimID);

                        var da = new MySqlDataAdapter(command);
                        var dt = new DataTable();
                        da.Fill(dt);
                        OrgsysdbConn.Close();

                        return Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(dt, Formatting.None));
                    }
                }

                return Request.CreateResponse(HttpStatusCode.NotFound);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }


        [HttpGet]
        [Route("GetList_Countries")]
        public string GetList_Countries()
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT id, Country FROM OSI_New.os_countries WHERE ArchivedRecord = 0;";                

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetList_ProvinceStates/{countryId}")]
        public string GetList_ProvinceStates(int countryId)
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT id, ProvinceState FROM OSI_New.os_provinces_states WHERE CountryID = @countryId AND ArchivedRecord = 0;";
                command.Parameters.AddWithValue("@countryId", countryId);

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetList_Cities/{provinceStateId}")]
        public string GetList_Cities(int provinceStateId)
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT id, City FROM OSI_New.os_cities WHERE ProvinceStateID = @provinceStateId AND ArchivedRecord = 0;";
                command.Parameters.AddWithValue("@provinceStateId", provinceStateId);

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetList_Genders")]
        public string GetList_Genders()
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT id, Gender FROM OSI_New.os_genders WHERE ArchivedRecord = 0;";

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetList_JobStatuses")]
        public string GetList_JobStatuses()
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT id, EmploymentStatus FROM OSI_New.os_employment_status WHERE ArchivedRecord = 0;";

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetList_Unions")]
        public string GetList_Unions()
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT id, UnionName FROM OSI_New.os_unions WHERE ArchivedRecord = 0;";

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetOrgsysDDL/{dropDownID}")]
        public string GetOrgsysDDL(int dropDownID)
        {
            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                OrgsysdbConn.Open();
                command.CommandText = "SELECT DropDownListID, DropDownListDescr FROM OSI_New.os_dropdownlists WHERE DropDownID = @dropDownID;";
                command.Parameters.AddWithValue("@dropDownID", dropDownID);

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);
                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }

        [HttpGet]
        [Route("GetClaimData/{token}/{claimId}")]
        public string GetClaimData(string token, int claimId)
        {
            if (context.CheckIfTokenValid(token) == 10001)
            {
                using (var command = OrgsysdbConn.CreateCommand())
                {
                    OrgsysdbConn.Open();
                    command.CommandText = "PORTALORG_GetClaimData";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@claimId", claimId);

                    var da = new MySqlDataAdapter(command);
                    var dt = new DataTable();
                    da.Fill(dt);
                    OrgsysdbConn.Close();

                    return JsonConvert.SerializeObject(dt, Formatting.None);
                }
            }
            else
            {
                return "";
            }
        }

        [HttpGet]
        [Route("GetAreaOfInjuryIllness/{token}/{claimId}")]
        public string GetAreaOfInjuryIllness(string token, int claimId)
        {
            if (context.CheckIfTokenValid(token) == 10001)
            {
                using (var command = OrgsysdbConn.CreateCommand())
                {
                    OrgsysdbConn.Open();
                    command.CommandText = "PORTALORG_GetAreaOfInjuryIllness";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@claimId", claimId);

                    var da = new MySqlDataAdapter(command);
                    var dt = new DataTable();
                    da.Fill(dt);
                    OrgsysdbConn.Close();

                    return JsonConvert.SerializeObject(dt, Formatting.None);
                }
            }
            else
            {
                return "";
            }
        }

        [HttpGet]
        [Route("GetEmployeeData/{token}/{employeeId}")]
        public string GetEmployeeData(string token, int employeeId)
        {
            if (context.CheckIfTokenValid(token) == 10001)
            {
                using (var command = OrgsysdbConn.CreateCommand())
                {
                    OrgsysdbConn.Open();
                    command.CommandText = "PORTALORG_GetEmployeeData";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@employeeId", employeeId);

                    var da = new MySqlDataAdapter(command);
                    var dt = new DataTable();
                    da.Fill(dt);
                    OrgsysdbConn.Close();

                    return JsonConvert.SerializeObject(dt, Formatting.None);
                }
            }
            else
            {
                return "";
            }
        }

        [HttpGet]
        [Route("GetEmployeeSchedule/{token}/{claimId}")]
        public string GetEmplyeeSchedule(string token, int claimId)
        {
            if (context.CheckIfTokenValid(token) == 10001)
            {
                using (var command = OrgsysdbConn.CreateCommand())
                {
                    OrgsysdbConn.Open();
                    command.CommandText = "PORTALORG_GetEmployeeSchedule";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@claimId", claimId);

                    var da = new MySqlDataAdapter(command);
                    var dt = new DataTable();
                    da.Fill(dt);
                    OrgsysdbConn.Close();

                    return JsonConvert.SerializeObject(dt, Formatting.None);
                }
            }
            else
            {
                return "";
            }
        }

        [HttpGet]
        [Route("GetClientDetails/{token}")]
        public string GetClientDetails(string token)
        {
            if (context.CheckIfTokenValid(token) == 10001)
            {
                var importId = 0;
                using (var context = new OrgSys2017DataContext())
                {
                    importId = context.GetClientImportID(token);
                }

                using (var command = OrgsysdbConn.CreateCommand())
                {
                    OrgsysdbConn.Open();
                    command.CommandText = "PORTALORG_GetClientDetails";
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@importId", importId);

                    var da = new MySqlDataAdapter(command);
                    var dt = new DataTable();
                    da.Fill(dt);
                    OrgsysdbConn.Close();

                    return JsonConvert.SerializeObject(dt, Formatting.None);
                }
            }
            else
            {
                return "";
            }
        }

        //Get Reports from Old Orgsys MySQL based on ImportID //mgougeon
        [HttpGet]
        [Route("GetReportsOldOrgsys/{Token}/{selectedReport}/{toDate}/{fromDate}")]
        public string GetReportsOldOrgsys(string Token, int selectedReport, string toDate, string fromDate)
        {
            var ImportID = GetClientImportID(Token);
            var reportSP = "";
            var Services = "STD"; //for now keep at std
            var currentYear = DateTime.UtcNow.Year;
            switch (selectedReport) {
            case 1:
                reportSP = "Report_NewReferralsAggregatebyMonth_Datepicker"; break;
            case 2:
                reportSP = "Report_ClosedReferralsAggregatebyMonth_Datepicker"; break;
            case 3:
                reportSP = "Report_NewReferralsDetailsbySite"; break;
            case 4:
                reportSP = "Report_NewReferralsDetailsbyDivision"; break;
            case 5:
                reportSP = "Report_NewReferralsAggregatebyDepartment"; break;
            case 6: 
                reportSP = "Report_NewReferralsAggregateByProvince"; break;
            case 7:
                reportSP = "Report_NewReferralsAggregateByGender"; break;
            case 8:
                reportSP = "Report_NewReferralsDetailsbyByAge_Datepicker"; break;
            case 9:
                reportSP = "Report_NewReferralsAggregateByPrimaryInjury"; break;
            case 10:
                reportSP = "Report_ClosedReferralsAggregatebyReasonClosed"; break;
            }
            OrgsysdbConn.Open();
            using (MySqlCommand command = new MySqlCommand(reportSP, OrgsysdbConn)) { 
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ClientService", Services);
                command.Parameters.AddWithValue("@inYear", currentYear);
                command.Parameters.AddWithValue("@CompanyID", ImportID);
                command.Parameters.AddWithValue("@Archived", "False");
                command.Parameters.AddWithValue("@DateFrom", fromDate);
                command.Parameters.AddWithValue("@DateTo", toDate);

            MySqlDataAdapter da = new MySqlDataAdapter(command);
            DataTable dt = new DataTable();
            da.Fill(dt);
            OrgsysdbConn.Close();

            return JsonConvert.SerializeObject(dt, Formatting.None);
            }
        }        

        public class ClaimManagerFieldList
        {
            public List<QueryField> claimManagerFields { get; set; }
        }

        //mgougeon
        //Check if exists in demographic file to register a new employee
        [HttpPost]
        [Route("ConfirmRegistration/{ImportID}")]
        public string ConfirmRegistration(int ImportID, [FromBody]UserRegistration user)
        {
            //var ImportID = GetClientImportID(Token); //may or may not need this
            List<EmpInfo> _EmpInfo = new List<EmpInfo>();
            using (MySqlCommand command = new MySqlCommand("ORGSYSPORTAL_ConfirmRegistration", DemographicdbConn))
            {

                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ImportID", ImportID);
                command.Parameters.AddWithValue("@FirstName", user.FirstName);
                command.Parameters.AddWithValue("@LastName", user.LastName);
                command.Parameters.AddWithValue("@EmpNumber", user.EmployeeNumber);
                command.Parameters.AddWithValue("@BirthDate", user.DOB);
                command.Parameters.AddWithValue("@Email", user.Email);
                DemographicdbConn.Open();
                MySqlDataAdapter da = new MySqlDataAdapter(command);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DemographicdbConn.Close();

                return JsonConvert.SerializeObject(new { Confirmed = (dt.Rows.Count > 0) });
            }
        }

        [HttpGet]
        [Route("GetDashboardReportData/{token}")]
        public string GetDashboardReportData(string token)
        {
            var EmployeeID = -1;
            using (var context = new OrgSys2017DataContext())
            {
                var USER_ID = context.GetUserIDSession(token).SingleOrDefault().UserID;
                EmployeeID = (from User in context.Users
                                where User.UserID == USER_ID
                                select User.OrgsysEmployeeID).FirstOrDefault().Value;
            }

            //Default values for 'EmployeeID' are stored as 0 in OSI_New.os_claims, so we do not want to return those results
            if(EmployeeID == 0)
            {
                EmployeeID = -1;
            }

            using (MySqlCommand command = OrgsysdbConn.CreateCommand())
            {
                
                OrgsysdbConn.Open();
                command.CommandText = "SELECT COUNT(*) AS ClaimCount FROM OSI_New.os_claims WHERE EmployeeID = @EmployeeID AND ArchivedRecord = 0;";
                command.Parameters.AddWithValue("@EmployeeID", EmployeeID);

                MySqlDataAdapter da = new MySqlDataAdapter(command);
                var ClaimCount = command.ExecuteScalar();

                OrgsysdbConn.Close();

                return JsonConvert.SerializeObject(ClaimCount, Formatting.None);
            }
        }
    }

}