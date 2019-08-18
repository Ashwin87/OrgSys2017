using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class CloseClaimDTO
    {
        public int ClaimID { get; set; }
        public string ClaimReference { get; set; }
        public int UserID { get; set; }
        public string Reason { get; set; }
        public string Comment { get; set; }
    }
}