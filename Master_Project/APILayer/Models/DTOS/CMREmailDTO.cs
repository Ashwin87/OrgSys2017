using DataLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class CMREmailDTO
    {
        public string Email { get; set; }
        public string Html { get; set; }
        public string Body { get; set; }
        public string ClaimRefNo { get; set; }
        private List<Claim_Contact> ClaimContacts { get; set; }
    }
}