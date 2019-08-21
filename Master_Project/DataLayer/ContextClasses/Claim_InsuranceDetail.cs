using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataLayer
{
    partial class Claim_InsuranceDetail
    {
        partial void OnCreated()
        {
            if (this.Rate == null)
                this.Rate = -1;

            if (this.WeeklyRate == null)
                this.WeeklyRate = -1;

            if (this.WeeklyHours == null)
                this.WeeklyHours = -1;

            if (this.RegHours == null)
                this.RegHours = -1;

            if (this.ModifiedHours == null)
                this.ModifiedHours = -1;

            if (this.SEIFFunds == null)
                this.SEIFFunds = -1;

            if (this.ClaimCost == null)
                this.ClaimCost = -1;

            if (this.CostReserve == null)
                this.CostReserve = -1;

            if (this.ReservePrevious == null)
                this.ReservePrevious = -1;

            if (this.CostReduction == null)
                this.CostReduction = -1;

            if (this.TotalCost == null)
                this.TotalCost = -1;

        }
    }
}
