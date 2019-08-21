using DataLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class MultilingualDTO
    {
        public Dictionary<string, string> Messages { get; set; }
        public GetMultilingualControlsResult[] Controls { get; set; }
    }
}