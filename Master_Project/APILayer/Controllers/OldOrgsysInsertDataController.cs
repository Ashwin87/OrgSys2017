using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web.Http;
using APILayer.Models;
using System.Data;
using MySql.Data.MySqlClient;
using Newtonsoft.Json;
using Orgsys_2017.Orgsys_Classes;
using APILayer.Services;
using DataLayer;

namespace APILayer.Controllers
{
    [RoutePrefix("api/DynamicOrgsys")]
    public class OldOrgsysInsertDataController : ApiController
    {
        private OldOrgsysServices orgsysService;

        [HttpPost]
        [Route("SavePortalForm/{token}")]
        public string SavePortalForm([FromBody]DataList list, string token)
        {
            MySqlTransaction transaction = null;
            var insertHistory = new List<PKInfo>();            
            var txIsCommitted = false;            
            var claimIndex = 1; //default; this is updated if employee record exists            
            string[] os_claimsEncryptedFields = { "EmployeeLast", "DateBirth", "Phone1", "Phone2", "Phone3", "SIN" }; //these os_claims fields are to be encrypted 
            string[] blankRecordTables = { "OSI_New.os_claims_absences", "OSI_New.os_claimsextended", "OSI_New.os_employees_additional" }; 
            int importId;
            int claimId = 0;

            using (var context = new OrgSys2017DataContext())
            {
                //userId = context.GetUserIDSession(token).SingleOrDefault().UserID;
                //clientId = context.GetClientIDBySession(token).SingleOrDefault().ClientID;
                importId = context.GetClientImportID(token);
            }            

            if (list.contrlData != null)
            {

                using (var connection = new MySqlConnection(ConfigurationManager.ConnectionStrings["OldOrgsysConnectionString"].ConnectionString))
                {                        
                    
                    try
                    {
                        connection.Open();
                        transaction = connection.BeginTransaction();
                        orgsysService = new OldOrgsysServices(connection, transaction);
                        object managerId = null;
                        object supervisorId = null;
                        object referralId = null;

                        foreach (var item in list.contrlData)
                        {
                            if (string.IsNullOrEmpty(item.TableName)) continue;
                            if (item.Columns != null)
                            {
                                var tableRows = item.Columns.GroupBy(x => x.Row).OrderBy(rowNu => rowNu.Key);   //may have multiple rows                                

                                foreach (var row in tableRows) 
                                {
                                    var query = new PortalQuery(item.TableName);

                                    foreach (var col in row)
                                    {
                                        object parameterValue = col.Value;
                                        //some values have to be modified before insert
                                        if (item.TableName == "OSI_New.os_employees" & (Array.IndexOf(os_claimsEncryptedFields, col.ColumnName) >= 0))
                                        {
                                            parameterValue = orgsysService.EncryptString(col.Value);
                                        }

                                        query.AddParameter(col.ColumnName, parameterValue);
                                        
                                    }

                                    //find fk reference and add as parameter if present
                                    var res = insertHistory.Find(x => x.PkTable == item.PKTable);
                                    if (res != null) query.AddParameter(item.FKName, res.PkValue);

                                    //orgsys pandering
                                    if (item.TableName == "OSI_New.os_employees")
                                    {
                                        //ColumnType is used here to differentiate between types of employees  (manager, supervisor, employee)
                                        var employeeType = row.FirstOrDefault().ColumnType;

                                        //these will become parameters for checking if an employee exists
                                        string employeeDOB = null;
                                        var employeeFirst = item.Columns.FirstOrDefault(c => c.ColumnName == "EmployeeFirst" & c.ColumnType == employeeType).Value;
                                        var employeeLast = item.Columns.FirstOrDefault(c => c.ColumnName == "EmployeeLast" & c.ColumnType == employeeType).Value;
                                        
                                        var employeeDOBColumn = item.Columns.FirstOrDefault(c => c.ColumnName == "DateBirth" & c.ColumnType == employeeType);
                                        if (employeeDOBColumn != null)
                                        {
                                            employeeDOB = employeeDOBColumn.Value;
                                        }
                                        
                                        var employeeId = orgsysService.GetEmployeeID(importId, employeeFirst, employeeLast, employeeDOB);
                                        var isNewEmployee = employeeId == 0;

                                        switch (employeeType)
                                        {
                                            case "Manager":
                                                if (isNewEmployee)
                                                {
                                                    query.AddParameter("IsManager", -1);
                                                    query.AddParameter("CompanyID", importId);

                                                    orgsysService.ExecuteInsert(query);
                                                    managerId = orgsysService.GetLastInsertID();
                                                }
                                                else
                                                {
                                                    managerId = employeeId;
                                                }
                                                continue; //a new record has been inserted or one already exists; go to next iteration
                                            case "Supervisor":
                                                if (isNewEmployee)
                                                {
                                                    query.AddParameter("IsSupervisor", -1);
                                                    query.AddParameter("CompanyID", importId);

                                                    orgsysService.ExecuteInsert(query);
                                                    supervisorId = orgsysService.GetLastInsertID();
                                                }
                                                else
                                                {
                                                    supervisorId = employeeId;
                                                }
                                                continue;
                                            case "SubBy":
                                                if (isNewEmployee)
                                                {
                                                    query.AddParameter("CompanyID", importId);

                                                    orgsysService.ExecuteInsert(query);
                                                    referralId = orgsysService.GetLastInsertID();
                                                }
                                                else
                                                {
                                                    referralId = employeeId;
                                                }
                                                continue;
                                            default:    //handle as employee 
                                                if (!isNewEmployee)
                                                {
                                                    insertHistory.Add(new PKInfo("OSI_New.os_employees", employeeId));
                                                    claimIndex = orgsysService.GetClaimIndexByEmployeeID(employeeId);
                                                    continue;
                                                }
                                                else
                                                {
                                                    query.AddParameter("CompanyID", importId);
                                                }
                                                break;

                                        }
                                    }

                                    if (item.TableName == "OSI_New.os_employees_additional")
                                    {
                                        //os_employees_additional has a column for os_claims.id and os_employees.id
                                        var os_employeesDetail = insertHistory.Find(x => x.PkTable == "OSI_New.os_employees");
                                        if (os_employeesDetail != null)
                                        {
                                            query.AddParameter("os_employeesID", os_employeesDetail.PkValue);
                                        }
                                    }

                                    if (item.TableName == "OSI_New.os_claims")
                                    {
                                        query.AddParameter("ClaimStatusID", 1);
                                        query.AddParameter("ReasonClosedID", 9);
                                        query.AddParameter("ClaimIndex", claimIndex);
                                        query.AddParameter("ManagerID", managerId);
                                        query.AddParameter("SupervisorID", supervisorId);
                                        query.AddParameter("ReferralSubmittedBy", referralId);

                                        orgsysService.ExecuteInsert(query);
                                        claimId = orgsysService.GetLastInsertID();  //need claimId for link with any documents
                                        insertHistory.Add(new PKInfo(item.TableName, claimId));
                                        continue;
                                    }

                                    if (item.TableName == "OSI_New.os_employees_schedule")
                                    {
                                        query.AddParameter("sched_order", row.Key);
                                    }

                                    if (item.TableName == "OSI_New.os_claims_healthsafety")
                                    {
                                        query.ConcatenateParameters("witnessesdescr", ",");
                                    }

                                    orgsysService.ExecuteInsert(query);
                                    var id = orgsysService.GetLastInsertID();

                                    insertHistory.Add(new PKInfo(item.TableName, id));
                                }
                                                                
                            }

                        }

                        //these tables require that at minimum, an empty record be inserted that references the claim
                        foreach (var table in blankRecordTables) 
                        {
                            if (insertHistory.Where(x => x.PkTable == table).Count() == 0)
                            {
                                var query = new PortalQuery(table);
                                query.AddParameter("ClaimID", claimId);
                                orgsysService.ExecuteInsert(query);
                            }
                        }

                        transaction.Commit();
                        txIsCommitted = true;

                    }
                    catch (Exception e)
                    {
                        ExceptionLog.LogException(e);

                        try
                        {
                            transaction.Rollback();
                        }
                        catch (MySqlException rbe)
                        {
                            ExceptionLog.LogException(rbe);
                        }
                    }
                }                
            }

            return JsonConvert.SerializeObject(new { Submitted = txIsCommitted, ClaimID = claimId });
        }
        
    }

}