using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataLayer
{
    partial class Claim_Employee
    {
        partial void OnCreated()
        {
            if (this.YearsofService == null)
                this.YearsofService = -1;

            if (this.DemEmpID == 0)
                this.DemEmpID = 1;

            if (this.OrgCode == null)
                this.OrgCode = -1;
        }
    }
}
