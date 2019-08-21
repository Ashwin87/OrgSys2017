using DataLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class CMRDefaultsDTO
    {
        public string EmpName { get; set; }
        public int  EmpIDNO { get; set; }
        public string DateOfReferal { get; set; }
        public string Location { get; set; }
        public List<CMRClaimContactPartial> ClaimContacts { get; set; }
        public List<CMREmployeeContactPartial> EmployeeContacts { get; set; }
        public string ClaimRefNo { get; set; }
        public string DateOfReport { get; set; }
    }

    public class CMRClaimContactPartial
    {
        public int ContactID { get; set; }
        public string ContactType { get; set; }
        public string ContactName { get; set; }
    }

    public class CMREmployeeContactPartial
    {
        public int ContactID { get; set; }
        public string ContactEmail { get; set; }
        public int ContactPriority { get; set; }
    }
}