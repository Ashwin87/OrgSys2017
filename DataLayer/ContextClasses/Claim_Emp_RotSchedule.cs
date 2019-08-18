using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataLayer
{
    partial class Claim_Emp_RotSchedule
    {
        partial void OnCreated()
        {
            if (this.WorkDaysOn == null)
                this.WorkDaysOn = -1;

            if (this.WorkDaysOff == null)
                this.WorkDaysOff = -1;

            if (this.WorkScheduledDayOff == null)
                this.WorkScheduledDayOff = -1;

            if (this.WorkHoursShift == null)
                this.WorkHoursShift = -1;

            if (this.WorkWeeksCycle == null)
                this.WorkWeeksCycle = -1;

            
        }
    }
}
