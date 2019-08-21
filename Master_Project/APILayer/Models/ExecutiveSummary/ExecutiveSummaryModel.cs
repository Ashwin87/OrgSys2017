using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.ExecutiveSummary
{
    public class ExecutiveSummaryModel
    {
        public string Title { get; set; }
        public ReportingClientModel Client { get; set; }
        public DateTime Date { get; set; }

        
    }
}