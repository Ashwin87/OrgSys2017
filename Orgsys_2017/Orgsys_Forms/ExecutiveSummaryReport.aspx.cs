using APILayer.Controllers;
using Orgsys_2017.Models;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;

namespace Orgsys_2017.Orgsys_Forms
{
    public partial class ExecutiveSummaryReport : OSI_Page
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        //grab string from javascript, parse out the clientid and send it to OSI_Page.cs
        public static void setTokenSession(string token)
        {
            try
            {
                HttpContext.Current.Session["token"] = token;
            }
            catch (Exception ex)
            {
                ExceptionLogger.LogException(ex);
            }
        }
        public FormControlViewModel NewAddedSlideHtml()
        {
            FormControlViewModel formControlViewModel = new FormControlViewModel();
            Page page = new Page();
            Control control = (Control)LoadControl("~/Orgsys_Forms/Slides/Slide.ascx");
            StringWriter sw = new StringWriter();
            page.Controls.Add(control);          
            Server.Execute(page, sw, false);
            var controlString = sw.ToString();

            StringBuilder stringBuilder = new StringBuilder(controlString);
            string id = Guid.NewGuid().ToString();
            stringBuilder.Replace("@@ControlId", "Slide_"+ id);
            stringBuilder.Replace("@@EditorId", "Editor_" + id);
            formControlViewModel.htmlString = stringBuilder.ToString();
            formControlViewModel.controlId = id;

            return formControlViewModel;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="htmlPage"></param>
        /// [WebMethod]
        /// 
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static FormControlViewModel AddSlide()
        {
            ExecutiveSummaryReport executiveSummaryReport = new ExecutiveSummaryReport();

            return executiveSummaryReport.NewAddedSlideHtml();

            //Response.Write(sw.ToString());
            //Response.Flush();
            //Response.Close();




            //var pdf = Pdf
            //   .From(htmlPage)
            //   .OfSize(PaperSize.A4)
            //    .WithTitle("Title")
            //    .WithoutOutline()
            //   // .WithMargins(1.25.Centimeters())
            //   .Portrait()
            //     .Comressed()
            //   .Content();
            //_phpFileProvider.WriteAllBytes("PDf/template" + Guid.NewGuid().ToString() + ".pdf", pdf);
        }

    }
}
