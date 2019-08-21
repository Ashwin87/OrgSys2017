using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models
{
    public class FormViewModel
    {
        public string controlType { get; set; }
        public string controlId { get; set; }
        public string controlValue { get; set; }
        public string parentId { get; set; }
        public bool isDeleted { get; set; }
        public int displayOrder { get; set; }
        public int userId { get; set; }
        public string token { get; set; }
        public bool isParentRemoved { get; set; }
    }
}