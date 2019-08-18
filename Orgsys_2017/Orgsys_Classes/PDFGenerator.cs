using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using OpenHtmlToPdf;

namespace Orgsys_2017.Orgsys_Classes
{
    public class PDFGenerator
    {

        public byte[] CreatePDF(string html, string cssFilename)
        {
            var cssPath = HttpContext.Current.Server.MapPath("~/Assets/css");
            var bytes = Pdf
                .From($"<!DOCTYPE html><html><head></head><body>{html}</body></html>")
                .WithObjectSetting("web.userStyleSheet", $@"{cssPath}\{cssFilename}")
                .WithGlobalSetting("web.defaultEncoding", "utf-8")
                .WithObjectSetting("web.loadImages", "true")
                .Content();

            return bytes;
        }

    }
}