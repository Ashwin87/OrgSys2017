using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Orgsys_2017.Orgsys_Classes;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Web.Script.Serialization;

namespace Orgsys_2017.Orgsys_Forms.Generic_Forms
{
    /// <summary>
    /// Summary description for PDFHandler
    /// </summary>
    public class PDFHandler : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            var jsonString = string.Empty;
            var gen = new PDFGenerator();

            context.Request.InputStream.Position = 0;
            using (var inputStream = new StreamReader(context.Request.InputStream))
            {
                jsonString = inputStream.ReadToEnd();
            }

            var json = JObject.Parse(jsonString);    
            var pdf = gen.CreatePDF(json["json"]["html"].ToString(), json["json"]["cssFilename"].ToString());
            
            context.Response.Clear();
            context.Response.ClearHeaders();
            context.Response.AddHeader("Content-Disposition", "inline; filename=testclaimpdf.pdf");
            context.Response.AddHeader("Content-Length", pdf.Length.ToString());
            context.Response.ContentType = "application/pdf";
            context.Response.BinaryWrite(pdf);
            context.Response.End();

        }


        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }

}