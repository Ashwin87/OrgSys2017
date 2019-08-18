using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataLayer
{
    partial class Claim_Emp_RegSchedule
    {
        partial void OnCreated()
        {
            if (this.WeekNo == null)
                this.WeekNo = -1;

            if (this.Mon == null)
                this.Mon = -1;

            if (this.Tue == null)
                this.Tue = -1;

            if (this.Wed == null)
                this.Wed = -1;

            if (this.Thur == null)
                this.Thur = -1;

            if (this.Fri == null)
                this.Fri = -1;

            if (this.Sat == null)
                this.Sat = -1;

            if (this.Sun == null)
                this.Sun = -1;
            
        }
    }
}
