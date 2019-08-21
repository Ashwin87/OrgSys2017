using System;
using System.Web;
using System.IO;
using Newtonsoft.Json.Linq;

namespace Orgsys_2017.Orgsys_Forms.Generic_Forms
{
    /// <summary>
    /// Summary description for FileHandler
    /// </summary>
    public class FileHandler : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            var jsonString = "";

            context.Request.InputStream.Position = 0;
            using (var inputStream = new StreamReader(context.Request.InputStream))
            {
                jsonString = inputStream.ReadToEnd();
            }

            var json = JObject.Parse(jsonString);
            var fileName = json["imgName"].ToString();
            var mimeType = json["mimeType"].ToString();
            var filePath = $@"\\OSI-DEV01\umbrella\logos\{fileName}";

            context.Response.Clear();
            context.Response.ClearHeaders();
            context.Response.AddHeader("Content-Disposition", $"inline; filename={fileName}");
            context.Response.ContentType = mimeType;
            context.Response.WriteFile(filePath);
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