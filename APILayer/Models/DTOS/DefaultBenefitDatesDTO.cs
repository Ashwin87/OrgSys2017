using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class DefaultBenefitDatesDTO
    {
        public string STDStartDate { get; set; }
        public string STDEndDate { get; set; }
        public string LTDStartDate { get; set; }
    }
}