using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class MultilingualControlDTO
    {
        public string ControlID { get; set; }
        public int Type { get; set; }
        public ControlData[] ControlData { get; set; }
        public string Page { get; set; }
    }

    public class ControlData
    {
        public string Data { get; set; }
        public int LanguageID { get; set; }
    }
}