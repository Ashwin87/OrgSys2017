using DataLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace Orgsys_2017.Orgsys_Classes
{
    public class GenerateForm
    {
        HttpClient client = new HttpClient();
        string path = "http://localhost:49627/";

        public GenerateForm()
        {
            client.BaseAddress = new Uri(path);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
        }
        public List<FormControl> controlList { get; set; }

        /// <summary>
        /// It Gets total nu of sections
        /// </summary>
        /// <returns></returns>
        public int GetTotalSections()
        {
            controlList = GetControls();
            //[Can query this way too]
            //int count = (from p in control
            //             select p.SectionID).Distinct().Count();
            return controlList.Select(x => x.SectionID).Distinct().Count();

        }

        /// <summary>
        /// It gets controls with data
        /// </summary>
        /// <param name="ControlName"></param>
        /// <returns></returns>
        public string GetControlData(string ControlName)
        {
            return controlList.Select(x => x.ControlName == ControlName).ToString();
        }


        public string GenerateControlsWithData(int sectionId,int ClaimID)
        {
            var val = string.Empty;
            var tableName = string.Empty;
            StringBuilder strControls = new StringBuilder();
            OrgSys2017DataContext con = new OrgSys2017DataContext();


            // [It would be in API an in Cache List]
            //Lazy loading.....

            var results =
            from claim in con.Claims
            from emp in con.Claim_Employees
            from emp3 in con.Claim_Injuries
            from emp4 in con.Claim_ContributingObjects
            where claim.ClaimID == emp.ClaimID && claim.Status == "new" && claim.ClaimID == ClaimID
            select new
            {
                claim,
                emp

            };

            var que = results.FirstOrDefault();
            //var testResults = con.Claims.Where(claim => claim.Status == "new" && claim.ClaimID == 26)
            //  .SelectMany(claim => claim.Claim_Employees,

            //  (claim, Employee) => new
            //  {
            //      Employee.EmpLastName,
            //      Employee.EmpFirstName,
            //      Employee.Demographic.EmpID,
            //      Employee.JobGrade,

            //  }).ToList();

            foreach (var res in controlList.Where(x => x.SectionID.Equals(sectionId)))
            {
                object obj = res.ColumnName;

                //if (v.GetType().GetProperty(res.ColumnName).ToString() == res.ColumnName)
                if (res.ColumnName != null)
                {
                    //results.Where(x=>x.GetType().GetProperty(res.ColumnName).GetValue()

                    // [To pass the table names ,I need to figure out some thing efficient,not the multiple if and else ]

                    if (res.TableName == "Claim_Employee")
                    {
                        var value = que.emp;
                        if (value.GetType().GetProperties().Any(p => p.Name == res.ColumnName))

                            if (value.GetType().GetProperty(res.ColumnName).GetValue(value, null) != null)
                                val = value.GetType().GetProperty(res.ColumnName).GetValue(value, null).ToString();

                    }
                }

                switch (res.ControlType)
                {

                    case "Radio":
                        strControls.AppendFormat("<label for='{0}'  style='top:{1}px;left:{2}px;' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                       // strControls.AppendFormat("<label style='top:{0}px;left:{1}px; ' class='{2}'>{3}</label>", res.Top, res.Left, res.CssClass, val);
                        break;

                    case "Select":
                        strControls.AppendFormat("<label for='{0}'  style='top:{1}px;left:{2}px;width:450px' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        strControls.AppendFormat("<label style='top:{0}px;left:{1}px;width: 100%;' class='{2}'>{3}</label>", res.Top, res.Left, res.CssClass, val);
                        break;

                    //case "Button":
                    //    strControls.AppendFormat("<input type = '{0}' id ='{1}{2}' value ={3} style='left:{4}px;top:{5}px;' class='{6}'/>", res.ControlType, res.Label, res.CntrolID, res.Label, res.Left, res.Top, res.CssClass);
                    //    break;

                    //case "CheckBox":
                    //    strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;position:relative'>{3}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.Label);
                    //    strControls.AppendFormat("<input type = '{0}' id ='{1}' style='left:{2}px;top:{3}px;position:relative'/>", res.ControlType, res.CntrolID, res.Left, res.Top);
                    //    break;

                    case "Password":
                        strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;'>{3}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.Label);
                        strControls.AppendFormat("<input type = '{0}' id ='{1}' style='left:{2}px;top:{3}px;'/>", res.ControlType, res.CntrolID, res.Left, res.Top);
                        break;

                    case "Label":
                        strControls.AppendFormat("<label style='top:{0}px;left:{1}px;' class='{2}'>{3}</label>", res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        break;

                    //case "File":
                    //    strControls.AppendFormat("<input type = '{0}' name ='{1}' style='left:{2}px;top:{3}px;width:{4}px;' class='{5}'/>", res.ControlType, res.CntrolID, res.Left, res.Top, res.Width, res.CssClass);
                    //    break;

                    //case "Submit":
                    //    strControls.AppendFormat("<input type = '{0}' id ='{1}{2}' value ={3} style='left:{4}px;top:{5}px;' class='{6}'/>", res.ControlType, res.Label, res.CntrolID, res.Label, res.Left, res.Top, res.CssClass);
                    //    break;

                    case "Text":
                        strControls.AppendFormat("<label for='{0}'  style='top:{1}px;left:{2}px;width:250px' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        strControls.AppendFormat("<label style='top:{0}px;left:{1}px;width: 250px; ' class='{2}'>{3}</label>", res.Top, res.Left, res.CssClass, val);
                        break;
                    case "TextArea":
                        strControls.AppendFormat("<label for='{0}'  style='top:{1}px;left:{2}px;width:250px' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        strControls.AppendFormat("<label style='top:{0}px;left:{1}px;width: 100%; ' class='{2}'>{3}</label>", res.Top, res.Left, res.CssClass, val);
                        break;
                }
            }


            return strControls.ToString();

        }
        /// <summary>
        /// It Generates Controls from data base
        /// </summary>
        /// <param name="sectionId"></param>
        /// <returns></returns>
        public string GenerateControls(int sectionId)
        {
            StringBuilder strControls = new StringBuilder();


            foreach (var res in controlList.Where(x => x.SectionID.Equals(sectionId)))
            {
                // I think it is redundant code, I will ask Kamil about it......

                switch (res.ControlType)
                {

                    case "Text":
                        strControls.AppendFormat("<label for='{0}'  style='top:{1}px;left:{2}px;position:absolute' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        strControls.AppendFormat("<input type = '{0}'  id ='{1}' name='{2}' style='left:{3}px;top:{4}px;width:{5}px;position:absolute' class='{6}' data-validation= '{7}'/>", res.ControlType, res.CntrolID, res.ControlName, res.Left, res.Top, res.Width, res.CssClass, res.DataValidation);
                        break;

                    case "Date":
                        strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;position:absolute'>{3}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.Label);
                        strControls.AppendFormat("<input type = '{0}' id ='{1}' style='left:{2}px;top:{3}px;width:{4}px;position:absolute' class='{5}'/>", res.ControlType, res.CntrolID, res.Left, res.Top, res.Width, res.CssClass);
                        break;
                    case "Radio":
                        strControls.AppendFormat("<label for='{0}'  style='top:{1}px;left:{2}px;position:absolute' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        strControls.AppendFormat("<input type = '{0}' name = '{1}' id={2} style='left:{3}px;top:{4}px;position:absolute'/>", res.ControlType, res.ControlName, res.CntrolID, res.Left, res.Top);
                        break;

                    case "Select":
                        strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;position:absolute'>{3}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.Label);
                        strControls.AppendFormat("<select name = '{0}' style='left:{1}px;top:{2}px;position:absolute'/>", res.ControlName, res.Left, res.Top);
                        strControls.AppendFormat("<option>{0}</option>", "---Select---");
                        strControls.AppendFormat("<option>{0}</option>", res.ControlName);
                        strControls.AppendFormat("<option>{0}</option></select>", res.ControlName);
                        break;

                    case "Button":
                        strControls.AppendFormat("<input type = '{0}' id ='{1}{2}' value ={3} style='left:{4}px;top:{5}px;position:absolute' class='{6}'/>", res.ControlType, res.Label, res.CntrolID, res.Label, res.Left, res.Top, res.CssClass);
                        break;

                    case "CheckBox":
                        strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;position:absolute'>{3}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.Label);
                        strControls.AppendFormat("<input type = '{0}' id ='{1}' style='left:{2}px;top:{3}px;position:absolute'/>", res.ControlType, res.CntrolID, res.Left, res.Top);
                        break;

                    case "Password":
                        strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;position:absolute'>{3}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.Label);
                        strControls.AppendFormat("<input type = '{0}' id ='{1}' style='left:{2}px;top:{3}px;position:absolute'/>", res.ControlType, res.CntrolID, res.Left, res.Top);
                        break;

                    case "TextArea":
                        strControls.AppendFormat("<label for='{0}' style='top:{1}px;left:{2}px;position:absolute' class='{3}'>{4}</label>", res.CntrolID, res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        strControls.AppendFormat("<input type = '{0}' id ='{1}' name='{2}' style='left:{3}px;top:{4}px;width:{5}px;position:absolute' class='{6}'/>", res.ControlType, res.CntrolID, res.ControlName, res.Left, res.Top, res.Width, res.CssClass);
                        break;

                    case "Label":
                        strControls.AppendFormat("<label style='top:{0}px;left:{1}px;position:absolute' class='{2}'>{3}</label>", res.LabelTop, res.LabelLeft, res.CssClass, res.Label);
                        break;

                    case "File":
                        strControls.AppendFormat("<input type = '{0}' name ='{1}' style='left:{2}px;top:{3}px;width:{4}px;position:absolute' class='{5}'/>", res.ControlType, res.CntrolID, res.Left, res.Top, res.Width, res.CssClass);
                        break;

                    case "Submit":
                        strControls.AppendFormat("<input type = '{0}' id ='{1}' value ={2} style='left:{3}px;top:{4}px;position:absolute' class='{5}'/>", res.ControlType, "btn-Submit", res.Label, res.Left, res.Top, res.CssClass);
                        break;

                }
            }

            return strControls.ToString();
        }

        /// <summary>
        /// Service call to retrieve control data
        /// </summary>
        /// <returns></returns>
        private List<FormControl> GetControls()
        {
            HttpResponseMessage response = client.GetAsync(string.Format("api/Form/GetAllControls/{0}", 15)).Result;
            if (response.IsSuccessStatusCode)
            {
                controlList = response.Content.ReadAsAsync<IEnumerable<FormControl>>().Result.ToList();

            }
            client.Dispose();
            return controlList;

        }

        public bool SaveChanges()
        {
            //[Need to Pass time out for the API call]
            //client.Timeout = TimeSpan.Parse("-1");
            HttpResponseMessage response = client.GetAsync(string.Format("api/Form/SaveDataBaseChanges/{0}", 15)).Result;
            if (response.IsSuccessStatusCode)
                return true;
            else
                return false;

        }
    }
}