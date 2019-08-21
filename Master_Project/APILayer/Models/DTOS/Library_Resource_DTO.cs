using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class Library_Resource_DTO
    {
        public string DocumentName { get; set; }
        public int VersionNumber { get; set; }
        public string StoredGuid { get; set; }
        public Nullable<int> SpecificCLientID { get; set; }
        public int ResourceTypeID { get; set; }
        public string Base64 { get; set; }
        public string DocExt { get; set; }
        public string MIMEType { get; set; }
    }
}