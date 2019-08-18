using APILayer.Models;
using DataLayer;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Transactions;
using System.Web.Http;
using APILayer.Controllers.DataAnnotations;
using Swashbuckle.Swagger.Annotations;
using APILayer.Services;
using System.Net.Http;
using System.Net;
using APILayer.Controllers.Auth.Authentication;
using APILayer.Controllers.Auth.SwaggerFilters;

namespace APILayer.Controllers
{
    /*Created By   : Sam Khan
      Create Date  : 2017 -05-18
      Update Date  : 2017-06-18 [Added comments and did code clean up]
      Description  : It saves the control's data created dynamically in the data base
      Updated by   : Sam Khan*/
    [OSIAuthenticationFilter]
    [SwaggerOperationFilter(typeof(OSITokenHeader))]
    [RoutePrefix("api/Dynamic")]
    public class DynamicController : ApiController
    {
        private OrgSys2017DataContext context;

        [HttpPost]
        [Route("SaveJSON/{Token}")]
        public string SaveJSON(string Token, [FromBody]DataList list)
        {
            int ClaimID = 0;
            ClaimModel model = new ClaimModel();
            Connection con = new Connection();
            var insertHistory = new List<PKInfo>();

            if (list.contrlData == null)
                return JsonConvert.SerializeObject(new { Submitted = false });

            int userId;
            int clientId;
            var txCommitted = false;
            var archive = false;
            var claimRefNuValue = list
                .contrlData
                .Find(x => x.TableName == "Claims")
                .Columns
                .Find(c => c.ColumnName == "ClaimRefNu")
                .Value;
            list.contrlData
                .Find(x => x.TableName == "Claims")
                .Columns
                .Find(c => c.ColumnName == "DateCreation")
                .Value = DateTime.Now.ToString();

            using (var context = new OrgSys2017DataContext()) {
                userId = context.GetUserIDSession(Token).SingleOrDefault().UserID;
                clientId = context.GetClientIDBySession(Token).SingleOrDefault().ClientID;
            }

            //done outside transaction to prevent escalation to MSDTC
            if (string.IsNullOrEmpty(claimRefNuValue))
            {
                claimRefNuValue = model.UniqueClaimReference("1003");
                list
                    .contrlData
                    .Find(x => x.TableName == "Claims")
                    .Columns
                    .Find(c => c.ColumnName == "ClaimRefNu")
                    .Value = claimRefNuValue;
            }
            else
            {
                archive = true;
            }

            try
            {
                using (var tx = new TransactionScope())
                {
                    var conString = ConfigurationManager.ConnectionStrings["OrgSysConnectionString"].ToString();
                    using (var connection = new SqlConnection(conString))
                    {
                        connection.Open();
                        foreach (var table in list.contrlData)
                        {
                            if (string.IsNullOrEmpty(table.TableName) | table.Columns.Count == 0 | table.Columns == null) continue;

                            var tableRows = table.Columns.GroupBy(x => x.Row).OrderBy(rowNu => rowNu.Key);   //may have multiple rows                                

                            foreach (var row in tableRows)
                            {
                                var query = new PortalQuery(table.TableName);
                                object columnDescription = "";

                                foreach (var col in row)
                                {
                                    object val = String.IsNullOrEmpty(col.Value) ? DBNull.Value : (object) col.Value;

                                    query.AddParameter(col.ColumnName, val);
                                    columnDescription = col.ColumnType;
                                }

                                //                                                                
                                if (table.TableName == "Claim_Documents")
                                {
                                    query.AddParameter("ClaimRefNu", claimRefNuValue);
                                    query.AddParameter("UserId", User);
                                    query.AddParameter("Timestamp", DateTime.Now.ToString());
                                }
                                if (table.TableName == "Claim_Dates")
                                {
                                    query.AddParameter("DateDescription", columnDescription);
                                }
                                if (table.TableName == "Claim_Contacts")
                                {
                                    query.AddParameter("ContactType", columnDescription);
                                    query.AddParameter("ClaimRefNu", claimRefNuValue);
                                }
                                if (table.TableName == "Claim_Emp_Schedule")
                                {
                                    query.AddParameter("WeekNo", row.Key);
                                }
                                if (table.TableName == "Claim_Emp_OtherEarnings")
                                {
                                    query.AddParameter("WeekNu", row.Key);
                                }
                                if (table.TableName == "Claim_Employee")
                                {
                                    query.AddParameter("DemEmpID", 1);
                                }
                                if (table.TableName == "Claim_Emp_ContactTypeDetails")
                                {
                                    query.AddParameter("ClaimReference", claimRefNuValue);
                                }
                                if (table.TableName == "Claim_ICDCM_Witness")
                                {
                                    query.AddParameter("Witness", row.Key);
                                    query.AddParameter("ClaimRefNu", claimRefNuValue);
                                }
                                if (table.TableName == "Claim_Injury_Cause")
                                {
                                    query.AddParameter("IsSafe", 1);
                                }
                                if (table.TableName == "Claim_Injury_BodyPart")
                                {
                                    query.AddParameter("Partside", row.FirstOrDefault().Group);
                                }
                              
                                if (table.TableName == "Claims")
                                {                                    
                                    query.AddParameter("Status", list.status);
                                    query.AddParameter("ClientID", clientId);
                                    query.AddParameter("UserSubmitted", userId);
                                    if (!archive)
                                    {
                                        query.AddParameter("Archived", 0);
                                    }
                                }

                                //find fk reference and add as parameter if present
                                var res = insertHistory.Find(x => x.PkTable == table.PKTable);

                                if (res != null) query.AddParameter(table.FKName, res.PkValue);

                                var insertedId = query.ExecuteInsert(connection);
                                insertHistory.Add(new PKInfo(table.TableName, insertedId));

                                if (table.TableName == "Claims")
                                {
                                    ClaimID = insertedId;
                                }
                            }

                        }

                    }

                    tx.Complete();
                    txCommitted = true;
                }

                if (txCommitted && archive)
                {
                    //newClaimRefNu not set means it exists; archive
                    //done outside transaction to prevent escalation to MSDTC
                    model.ArchiveClaim(claimRefNuValue);
                }

            }
                catch (Exception e)
            {
                ExceptionLog.LogException(e);
            }

            return JsonConvert.SerializeObject(new { Submitted = txCommitted, ClaimID = ClaimID });
        }

        /// <summary>
        /// Gets the data for claim manager page tables
        /// </summary>
        /// <param name="Token"></param>
        /// <param name="StatusString"></param>
        /// <param name="Fields"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetPortalClaimManagerData/{Token}/{StatusString}")]
        public HttpResponseMessage GetPortalClaimManagerData(string Token, string StatusString, [FromBody] ClaimManagerFieldList Fields)
        {
            try
            {
                var status = "";
                switch (StatusString)
                {
                    case "open":
                        status = "(9, 19)";
                        break;
                    case "closed":
                        status = "(29)";
                        break;
                    case "draft":
                        status = "(0)";
                        break;
                    default:
                        status = "";
                        break;
                }

                var qservice = new QueryService("Claims", "Claim", Token);
                //if the same table needs to be joined multiple times, the correct aliases must be referenced in [PermissionDataFilter] table
                //qservice.JoinTableList.Add($" LEFT JOIN [Claim_UserAssigned] ON [Claim_UserAssigned].[ClaimReferenceNumber] = [Claims].[ClaimRefNu] ");
                qservice.JoinTableList.Add($" INNER JOIN [User_Profiles] ON [User_Profiles].[UserID] = [Session].[UserID] ");
                qservice.WhereClauseQueryList.Add($" [Claims].ClientID = [ClientDivisionUserView].[ClientID] ");
                qservice.WhereClauseQueryList.Add($" [Claims].[Status] IN {status} ");
                qservice.WhereClauseQueryList.Add($" [Claims].Archived = 0 ");
                qservice.WhereClauseQueryList.Add($" Claims.Description  IN(SELECT SL.Abbreviation FROM User_Service_Permission as USP INNER JOIN Services_LookUp as SL on USP.ServiceTypeID = SL.ServiceID WHERE USP.UserID = Session.UserID AND Claims.ClientID = USP.ClientID)");
                qservice.SelectColumnList.Add("[Claims].ClaimID");
                qservice.SelectColumnList.Add("[Claims].Description");

                context = new OrgSys2017DataContext();
                var filters = context.GetFilteredData(Token, "Claim")?.ToList();
                var UserRoleName = context.GetUserRole(Token).FirstOrDefault()?.RoleName; //at this time, users are only assigned a single role

                if ((filters == null && UserRoleName != "OSIUser") || UserRoleName == null)
                    return Request.CreateResponse(HttpStatusCode.Forbidden);

                var dataView = context.GetPortalPortalDataView(Token, "Claim").ToList();
                var query = qservice.BuildQueryFromPermissions(dataView, filters);
                var con = new Connection();
                var result = con.SelectData(query);

                var response = Request.CreateResponse();
                response.Content = new StringContent(result);

                return response;
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }

        }


        [HttpPost]
        [Route("SavePCMPreferences/{Token}")]
        public void SavePCMPreferences(string Token, [FromBody] ClaimManagerFieldList pcmPreferences) {

            var query = $"UPDATE [Portal_Data_View] SET [FieldOrder] = @FieldOrder, [IsVisible] = @IsVisible WHERE [FieldID] = @FieldID;";

            using (var con = new SqlConnection(ConfigurationManager.ConnectionStrings["OrgSysConnectionString"].ToString()))
            {
                con.Open();
                foreach (var field in pcmPreferences.claimManagerFields)
                {
                    using (var command = new SqlCommand(query, con))
                    {
                        command.Parameters.AddWithValue("@FieldOrder", field.FieldOrder);
                        command.Parameters.AddWithValue("@IsVisible", field.IsVisible);
                        command.Parameters.AddWithValue("@FieldID", field.FieldID);
                        command.ExecuteNonQuery();
                    }
                }

            }                
            
        }

        [HttpGet]
        [AllowAnonymous]
        [SwaggerOperationFilter(typeof(LanguageHeaderIOFilter))]
        [Route("DataViewV2/{token}/{viewType}")]
        public string GetDataViewV2(string token, string viewType)
        {
            using (context = new OrgSys2017DataContext())
            {
                return JsonConvert.SerializeObject(context.GetPortalPortalDataViewV2(token, viewType, Request.Headers.GetValues("Language").First()), Formatting.None);
            }
        }
    }
    //All of the below Classes are used to get JSON object ,deserialize it
    //and save the JSON in to data base
    public class ContrlData
    {

        public string TableName { get; set; }
        public int Order { get; set; }
        public string PKTable { get; set; }
        public string PKName { get; set; }
        public string FKName { get; set; }
        public List<Columns> Columns { get; set; }
    }
    public class DataList
    {
        public int status { get; set; }
        public int clientId { get; set; }
        public List<ContrlData> contrlData { get; set; }
    }


    public class Columns
    {   //Matches the same structure of JSON being sent from browser
        public string ColumnName { get; set; }
        public string Value { get; set; }
        public string Group { get; set; }
        public string ColumnType { get; set; }
        public int Row { get; set; }
        public bool OtherDataType { get; set; }
    }

    //model for result of GetPortalClaimManagerFields sproc
    public class ClaimManagerField
    {
        public int FieldID { get; set; }
        public int FieldOrder { get; set; }
        public string FieldLabel { get; set; }
        public string ColumnAlias { get; set; }
        public string PKTable { get; set; }
        public string PKName { get; set; }
        public int TableOrder { get; set; }
        public string TableName { get; set; }
        public string ColumnName { get; set; }
        public int IsVisible { get; set; }
    }

    public class ClaimManagerFieldList
    {
        public List<ClaimManagerField> claimManagerFields { get; set; }
    }
    
    //This class is used to create a DB connection
    public class Connection
    {
        string connectionString;
        public Connection()
        {
            connectionString = ConfigurationManager.ConnectionStrings["OrgSysConnectionString"].ToString();
        }
        //It executes the sql command
        public int AddData(string sqlQuery)
        {
            int returnedID;

            using (SqlConnection connection = new SqlConnection(
                       connectionString))
            {
                connection.Open();
                SqlCommand command = connection.CreateCommand();
                command.CommandText = sqlQuery;
                returnedID = int.Parse(command.ExecuteScalar().ToString());
                connection.Close();
            }

            return returnedID;

        }

        //Executes queries that return a result set
        public string SelectData(string sqlQuery)
        {
            var result = new DataSet();

            using (var connection = new SqlDataAdapter(sqlQuery,  new SqlConnection(connectionString)))
            {
                connection.Fill(result);
            }

            //only one table is contained in the result set, select position [0]
            return JsonConvert.SerializeObject(result.Tables[0]);
        }

        //It executes the sql command
        public int UpdateData(string sqlQuery)
        {
            int nRowsAffected;
            
            using (SqlConnection connection = new SqlConnection(
                   connectionString))
            {
                connection.Open();
                SqlCommand command = connection.CreateCommand();
                command.CommandText = sqlQuery;
                nRowsAffected = command.ExecuteNonQuery();
                connection.Close();
            }

            return nRowsAffected;

        }

    }
}