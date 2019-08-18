using DataLayer;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Transactions;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;


namespace Orgsys_2017.Orgsys_Forms.Generic_Forms
{
    public partial class Generic : System.Web.UI.Page
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            int i = 0;
            List<FormControl> controlsList;
            int totalSection;
            GenerateForm fromObj = new GenerateForm();

            if (!IsPostBack)
            {
                //Generate Sections along with controls dynamically
                if (Request.QueryString["ClaimID"] != null)
                {
                    Session["ClaimID"] = Request.QueryString["ClaimID"];
                    totalSection = fromObj.GetTotalSections();
                    for (int section = 1; section <= totalSection; section++)
                    {
                        string controls = fromObj.GenerateControlsWithData(section, Convert.ToInt32(Session["ClaimID"]));
                        CreateSections(section.ToString(), controls, "block", "loadDiv");

                    }
                }
                else
                {
                    totalSection = fromObj.GetTotalSections();
                    for (int section = 1; section <= totalSection; section++)
                    {

                        string controls = fromObj.GenerateControls(section);
                        CreateSections(section.ToString(), controls, "none", "divClass");

                    }
                    CreateTabs(totalSection);
                }

                //Saving control structure to a Cache List

                if (Cache["controlsList"] == null)
                {
                    // Cache.Insert("controlsList", GenerateForm.controlList, null, DateTime.Now.AddMinutes(2), System.Web.Caching.Cache.NoSlidingExpiration);
                    Cache.Add("controlsList", fromObj.controlList, null, DateTime.Now.AddMinutes(10), System.Web.Caching.Cache.NoSlidingExpiration, System.Web.Caching.CacheItemPriority.NotRemovable, null);
                }

            }
            else
            {
                //Saving Form values to Data Base dynamically
                // I would have to do a Json string here, so it would be an Ajax API Call.
                OrgSys2017DataContext context = new OrgSys2017DataContext();

                Claim claim = new Claim();
                claim.Status = "new";
                context.Claims.InsertOnSubmit(claim);
                context.SubmitChanges();

                try
                {

                    //[Query to get employee id and later employee object from Demograpghics table[Would be in API Layer]
                    //var empid = context.Demographics.Where(x => x.EmpFirstName == Request.Form["EmpFirstName"]).
                    //                                                       Select(x => new
                    //                                                       {
                    //                                                           x.EmpID
                    //                                                       }).FirstOrDefault();


                    List<GenericList> list = new List<GenericList>();
                    controlsList = Cache["controlsList"] as List<FormControl>;
                    if (controlsList != null)
                    {
                        var tableNames_All = controlsList.Select(x => x.TableName).Distinct().ToList();

                        if (tableNames_All.Count > 0)
                        {
                            var type = default(Type);
                            var obj = default(object);
                            List<GenericList> listTables = new List<GenericList>();

                            foreach (var tableName in tableNames_All)
                            {
                                if (!string.IsNullOrEmpty(tableName))
                                {
                                    Assembly assembly = Assembly.Load("DataLayer");
                                    type = assembly.GetType("DataLayer." + tableName);
                                    if (type != null)
                                    {
                                        obj = Activator.CreateInstance(type);

                                        listTables.Add(new GenericList { tableObj = obj, tableName = type });
                                    }

                                }
                            }

                            foreach (string cntrlValue in Request.Form.AllKeys)
                            {

                                var controlValues = controlsList.Where(x => x.ControlName == cntrlValue).ToList();

                                if (controlValues.Count > 0)
                                {
                                    foreach (var val in controlValues)
                                    {
                                        var tableName = val.TableName;
                                        var columnName = val.ColumnName;
                                        if (!string.IsNullOrEmpty(tableName) && !string.IsNullOrEmpty(columnName))
                                        {
                                            var re = listTables.Find(x => x.tableName.Name == tableName);
                                            if (re != null)
                                                if(re.tableName.GetType().GetProperty(columnName)!=null)
                                                re.tableName.GetType().GetProperty(columnName).SetValue(re.tableObj, Request.Form[cntrlValue], null);


                                            if (tableName == "Claim_Schedule")
                                            {
                                                //I have changed the Schedule Table definition so it would not work, I have to make changes here too.

                                                //object obja= Activator.CreateInstance(re.key);


                                                //  Claim_Emp_ScheduleDetail objClaim = new Claim_Emp_ScheduleDetail();
                                                // objClaim.GetType().GetProperty("WeekDay").SetValue(objClaim, val.Label, null);
                                                // objClaim.GetType().GetProperty("ClaimID").SetValue(objClaim, claim.ClaimID, null);
                                                // dailyHours = Request.Form.GetValues(cntrlValue);

                                                // objClaim.GetType().GetProperty(columnName).SetValue(objClaim, dailyHours[i], null);
                                                // context.Claim_Emp_ScheduleDetails.InsertOnSubmit(objClaim);
                                                i++;
                                            }


                                        }


                                    }
                                }
                            }
                            using (TransactionScope tranScope = new TransactionScope())
                            {
                                foreach (var table in listTables)
                                {
                                    if (table.tableName.Name != "Claim_Schedule")
                                    {
                                        if (table.tableObj.GetType().GetProperty("EmpID") != null)
                                        {
                                            table.tableObj.GetType().GetProperty("EmpID").SetValue(table.tableObj, 1, null);
                                        }
                                        if (table.tableObj.GetType().GetProperty("ClaimID") != null)
                                            table.tableObj.GetType().GetProperty("ClaimID").SetValue(table.tableObj, claim.ClaimID, null);

                                        context.GetTable(table.tableName).InsertOnSubmit(table.tableObj);
                                        context.SubmitChanges();
                                    }
                                }

                                //dem.GetType().GetProperty(colName).SetValue(dem, Request.Form[cntrlValue]);


                                tranScope.Complete();
                            }
                        }

                    }
                }

                catch (TransactionAbortedException ex)
                {
                    Console.WriteLine(ex.Message);
                }

            }
        }
        /// <summary>
        /// It creates sections depending on the values from data base
        /// </summary>
        /// <param name="sectionNu"></param>
        /// <param name="Controls"></param>
        private void CreateSections(string sectionNu, string Controls, string Display, string className)
        {
            HtmlGenericControl divSection = new HtmlGenericControl("div");
            divSection.ID = "Section" + sectionNu;
            divSection.InnerHtml = Controls;
            divSection.Style["display"] = Display;
            divSection.Attributes.Add("Class", className);
            section_All.Controls.Add(divSection);

        }
        /// <summary>
        /// It creates the tabs depending on the no of sections
        /// </summary>
        /// <param name="NoOfDivs"></param>
        private void CreateTabs(int NoOfDivs)
        {

            StringBuilder strTabs = new StringBuilder();
            for (int i = 1; i <= NoOfDivs; i++)
            {
                //strTabs.AppendFormat("<li><a href='{0}'>'{1}'</a></li>",);
                HtmlGenericControl tabs = new HtmlGenericControl("li");
                list_tabs.Controls.Add(tabs);
                HtmlGenericControl anchor = new HtmlGenericControl("a");
                anchor.ID = "Tab" + i;
                anchor.Attributes.Add("Class", "sectionTabs");
                anchor.Attributes.Add("href", "#" + "MainContent_Section" + i.ToString());
                anchor.InnerText = "Section" + " " + i;
                tabs.Controls.Add(anchor);
            }
        }
    }
}