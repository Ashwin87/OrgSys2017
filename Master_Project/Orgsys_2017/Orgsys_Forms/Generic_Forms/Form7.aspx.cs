using DataLayer;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace Orgsys_2017.Orgsys_Forms.Generic_Forms
{
    public partial class Form7 : Orgsys_2017.Orgsys_Classes.OSI_Page
    {
        static List<GenericList> listTables = new List<GenericList>();
        static List<RecordInsertion> recordInsertion = new List<RecordInsertion>();
        static Claim claimObj = new Claim();
        static OrgSys2017DataContext context = new OrgSys2017DataContext();

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ReturnJSON(string[] users)
        {
            string d = "abc";
            return d;
        }
        [WebMethod]
        public static void SaveData(TableInfo[] tableDet)
        {
            var tableNames = tableDet.Select(x => x.TableName).Distinct().ToList();
            CreateTableObjects(tableNames);
            SaveTableData(tableDet);
        }

        public static void CreateTableObjects(List<string> TableNames)
        {
            if (TableNames.Count > 0)
            {
                var table = default(Type);
                var tableObj = default(object);

                foreach (var tableName in TableNames)
                {
                    if (!string.IsNullOrEmpty(tableName))
                    {
                        Assembly assembly = Assembly.Load("DataLayer");
                        table = assembly.GetType("DataLayer." + tableName);
                        if (table != null)
                        {
                            tableObj = Activator.CreateInstance(table);

                            listTables.Add(new GenericList { tableObj = tableObj, tableName = table });
                        }

                    }
                }
            }
        }

        public static void SaveTableData(TableInfo[] tableDet)
        {

            string[] tableNames = { };
            PropertyInfo[] propertyInfo = { };
            int pkValue = 0;
            string primaryKey = "";
            bool inserted = false;

            foreach (var det in tableDet)
            {
                var controlName = det.ControlName;
                var tableName = det.TableName;
                var columnName = det.ColumnName;
                var value = det.Value;
                if (!string.IsNullOrEmpty(tableName) && !string.IsNullOrEmpty(columnName))
                {
                    var res = listTables.Find(x => x.tableName.Name == tableName);
                    if (res != null)
                        if (res.tableObj.GetType().GetProperty(columnName) != null)
                        {

                            res.tableObj.GetType().GetProperty(columnName).SetValue(res.tableObj, value, null);
                        }
                }
            }
            foreach (var tblList in listTables)
            {
                propertyInfo = tblList.tableObj.GetType().GetProperties();
                if (recordInsertion.Count > 0)
                {
                    var result = recordInsertion.SingleOrDefault(x => x.TableName == tblList.tableName.Name && x.Inserted == true);
                    if (result != null)
                    {
                        inserted = true;

                        if (inserted)

                            pkValue = result.PrimaryKey;
                    }
                }

                else if (inserted == false)
                {
                    context.GetTable(tblList.tableName).InsertOnSubmit(tblList.tableObj);
                    context.SubmitChanges();
                    var pk = context.Mapping.GetTable(tblList.tableName).RowType.DataMembers.Single(x => x.IsPrimaryKey);
                    primaryKey = pk.Name.ToString();
                    pkValue = Convert.ToInt32(tblList.tableObj.GetType().GetProperty(primaryKey).GetValue(tblList.tableObj, null));
                    recordInsertion.Add(new RecordInsertion { TableName = tblList.tableName.Name, Inserted = true, PrimaryKey = pkValue });

                }

                foreach (var prop in propertyInfo)
                {
                    if (prop.PropertyType.Name.ToString() == "EntitySet`1")
                    {
                        foreach (var list in listTables)
                        {
                            if (list.tableName.Name + "s" == prop.Name)
                            {
                                if (list != null)
                                {
                                    list.tableObj.GetType().GetProperty(primaryKey).SetValue(list.tableObj, pkValue, null);
                                    context.GetTable(list.tableName).InsertOnSubmit(list.tableObj);
                                    context.SubmitChanges();
                                    var primKey = context.Mapping.GetTable(list.tableName).RowType.DataMembers.Single(x => x.IsPrimaryKey);
                                    //  pkValue = Convert.ToInt32(list.tableObj.GetType().GetProperty(primKey.Name).GetValue(list.tableObj, null));
                                    recordInsertion.Add(new RecordInsertion { TableName = list.tableName.Name, Inserted = true, PrimaryKey = pkValue });
                                }
                            }

                        }
                    }

                }

            }
        }
        public class TableInfo
        {
           
            public string ControlName { get; set; }
            public string TableName { get; set; }
            public string ColumnName { get; set; }
            public string Value { get; set; }
        }
    }

  
}