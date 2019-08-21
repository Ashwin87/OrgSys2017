using System;
using System.Collections.Generic;
using System.Linq;
using DataLayer;

namespace APILayer.Services
{
    public class QueryService
    {
        public string TableName { get; set; }
        public int ImportID { get; set; }
        public string Token { get; set; }
        public string ViewType { get; set; }
        public int? OrgsysEmployeeID { get; set; }
        public List<string> SelectColumnList { get; set; } = new List<string>();
        public List<string> JoinTableList { get; set; } = new List<string>();
        public List<string> WhereClausePermissionList { get; set; } = new List<string>();   //restrict the data selected
        public List<string> WhereClauseQueryList { get; set; } = new List<string>();        //selects data to be (potentially) restricted

        public QueryService(string tableName, string viewType, int importId, string token, int? orgsysEmployeeID)
        {
            ViewType = viewType;
            TableName = tableName;
            ImportID = importId;
            Token = token;
            OrgsysEmployeeID = orgsysEmployeeID;
        }

        public QueryService(string tableName, string viewType, string token)
        {
            ViewType = viewType;
            TableName = tableName;
            Token = token;

            //these JOIN or WHERE statements need the values passed to the, not to be done through db
            JoinTableList.Add($" LEFT JOIN [Session] ON [Session].SessionToken = '{Token}' ");
            JoinTableList.Add($" INNER JOIN [ClientDivisionUserView] ON [ClientDivisionUserView].UserID = [Session].UserID ");            
        }

        /// <summary>
        /// Returns an SQL query as a string, where this query only returns the data which the user has permissions to view.
        /// </summary>
        /// <param name="fields"></param>
        /// <param name="permissions"></param>
        /// <returns></returns>
        public string BuildQuery(List<GetPortalPortalDataViewResult> fields, List<GetFilteredDataResult> permissions)
        {
            var groupedFieldsByTable = fields.OrderBy(f => f.TableOrder).GroupBy(x => x.TableOrder);
            int? userId;

            using (var context = new OrgSys2017DataContext())
            {
                userId = context.GetUserIDSession(Token).SingleOrDefault().UserID;
            }

            //these JOIN or WHERE statements need the values passed to the, not to be done through db
            if (TableName.StartsWith("OSI_New"))
            {
                SelectColumnList.Add(" OSI_New.os_claims.id AS ClaimID ");
                SelectColumnList.Add(" OSI_New.os_claims.ClaimType AS Description ");
                WhereClauseQueryList.Add($" OSI_New.os_employees.CompanyID = {ImportID} ");
            }
            else
            {
                //this portion is only for creating document views at the moment
                JoinTableList.Add($" LEFT JOIN [Session] ON [Session].SessionToken = '{Token}' ");
                JoinTableList.Add($" LEFT JOIN [User_Profiles] ON [Claim_Documents].UserID = [User_Profiles].UserID ");
                JoinTableList.Add($" LEFT JOIN [Client] ON [User_Profiles].ClientID = [Client].ClientID ");
                WhereClauseQueryList.Add($" Client.ClientID = [Session].ClientID ");

            }

            foreach (var group in groupedFieldsByTable)
            {
                foreach (var field in group)
                {
                    if (!field.IsPresented) continue;       //skips fields that are not for display
                    if (field.IsEncrypted)
                    {
                        SelectColumnList.Add($"fn_DecryptString({field.TableName}.{field.ColumnName}) AS {field.ColumnAlias}");
                    }
                    else
                    {
                        SelectColumnList.Add($"{field.TableName}.{field.ColumnName} AS {field.ColumnAlias}");
                    }
                }

                var item = group.First();

                if (item.TableName != "OSI_New.os_employees" && item.TableName != "User_Profiles" && item.TableName != "Claim_Documents")
                {
                    //PKName and PKTable are coming from Table_Order table
                    JoinTableList.Add($"LEFT JOIN {item.TableName} ON {item.PKTable}.{item.PKName} = {item.TableName}.{item.FKName}");
                }
            }

            foreach (var filter in permissions)
            {
                object value;
                switch (filter.FilterValue) //substitutes current user id when needed, allows for dynamic query
                {
                    case "UserID":
                        value = userId;
                        break;
                    case "OrgsysUserID":
                        value = OrgsysEmployeeID;
                        break;
                    default:
                        value = filter.FilterValue;
                        break;
                }
                bool isFilterColumn = filter.isFilterValueColumn.Value;

                if(isFilterColumn)//If the filter is an actual column in the built query
                {
                    WhereClausePermissionList.Add($"{filter.TableName}.{filter.ColumnName} {filter.Operator} {value}");
                } else
                {
                    WhereClausePermissionList.Add($"{filter.TableName}.{filter.ColumnName} {filter.Operator} '{value}'");
                }
            }

            var query = $" SELECT {string.Join(", ", SelectColumnList)} FROM {TableName} {string.Join(" ", JoinTableList)} WHERE ";
            if (WhereClauseQueryList.Count > 0 && permissions.Count > 0)
            {
                query += string.Join(" AND ", WhereClauseQueryList) + " AND "; //add WHEREs that are part of the query itself, not permissions
            } else if (WhereClauseQueryList.Count > 0)
            {
                query += $" {string.Join(" AND ", WhereClauseQueryList)} ;";
            }
            
            if(permissions.Count > 0)
            {
                query += $" ({string.Join(" OR ", WhereClausePermissionList)}) ;";
            } 

            return query;
        }

        /// <summary>
        /// Returns an SQL query as a string, where this query only returns the data which the user has permissions to view.
        /// </summary>
        /// <param name="fields"></param>
        /// <param name="permissions"></param>
        /// <returns></returns>
        public string BuildQueryFromPermissions(List<GetPortalPortalDataViewResult> fields, List<GetFilteredDataResult> permissions)
        {
            var groupedFieldsByTable = fields.OrderBy(f => f.TableOrder).GroupBy(x => x.TableOrder);

            using (var context = new OrgSys2017DataContext())
            {
                var userId = context.GetUserIDSession(Token).SingleOrDefault()?.UserID;

                foreach (var group in groupedFieldsByTable)
                {
                    foreach (var field in group)
                    {
                        if (!field.IsPresented) continue;       //skips fields that are not for display
                        if (field.IsEncrypted)
                        {
                            SelectColumnList.Add($"fn_DecryptString({field.TableName}.{field.ColumnName}) AS {field.ColumnAlias}");
                        }
                        else
                        {
                            SelectColumnList.Add($"{field.TableName}.{field.ColumnName} AS {field.ColumnAlias}");
                        }
                    }

                    var item = group.First();

                    if (item.TableName != "Claims" && item.TableName != "User_Profiles" && item.TableName != "Claim_Documents")
                    {
                        //PKName and PKTable are coming from Table_Order table
                        JoinTableList.Add($"LEFT JOIN {item.TableName} ON {item.PKTable}.{item.PKName} = {item.TableName}.{item.FKName}");
                    }
                }

                foreach (var filter in permissions)
                {
                    object value = ResolveFilterValue(filter, context, Token);
                    WhereClausePermissionList.Add($"{filter.TableName}.{filter.ColumnName} {filter.Operator} {value}");
                }
            }

            var query = $" SELECT DISTINCT {string.Join(", ", SelectColumnList)} FROM {TableName} {string.Join(" ", JoinTableList)} WHERE ";
            if (WhereClauseQueryList.Count > 0 && permissions.Count > 0)
            {
                query += string.Join(" AND ", WhereClauseQueryList) + " AND "; //add WHEREs that are part of the query itself, not permissions
            }
            else if (WhereClauseQueryList.Count > 0)
            {
                query += $" {string.Join(" AND ", WhereClauseQueryList)} ;";
            }

            if (permissions.Count > 0)
            {
                query += $" ({string.Join(" OR ", WhereClausePermissionList)}) ;";
            }

            return query;
        }

        /// <summary>
        /// Resolves the filter value to that of what will be used in the query.
        /// </summary>
        /// <param name="filterValue"></param>
        /// <param name="context"></param>
        /// <param name="token"></param>
        /// <returns></returns>
        public static object ResolveFilterValue(GetFilteredDataResult filter, OrgSys2017DataContext context, string token)
        {
            object value;
            var userId = context.GetUserIDSession(token).SingleOrDefault()?.UserID;

            switch (filter.FilterValue) //substitutes current user id when needed, allows for dynamic query
            {
                case "UserID":
                    value = userId;
                    break;
                case "DIVISION_TREE":
                    var resultList = new List<string>();
                    var userDivisionId = context.GetUserClientDivision(token);
                    context.GetClientDivisions(userDivisionId)
                        .ToList()
                        .ForEach(x => resultList.Add("" + x.ClientID));
                    value = $"({string.Join(",", resultList)})";
                    break;
                case "DIVISION":
                    value = context.GetUserClientDivision(token);
                    break;
                default:
                    value = filter.FilterValue;
                    break;
            }

            return filter.isFilterValueColumn.Value ? value : $"'{value}'";
        }

    }
}