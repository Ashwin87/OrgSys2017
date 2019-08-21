using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.ExecutiveSummary
{

    internal class ExecutiveSummaryStatsByYear
    {
        public int Year { get; set; }
        public int CountEligibleEmployees { get; set; }
        public int CountNewClaims { get; set; }
        public int CountCancelledClaims { get; set; }
        /// <summary>
        /// incident rate (STD Claims/ Total Eligible Employees)
        /// </summary>
        public float ClaimsIncidentRate { get; set; }
        public int CountNonSupportedStdClaims { get; set; }
        public int CountClosedClaims { get; set; }
        public int CountClaimsTransferredToLtd { get; set; }
        /// <summary>
        /// % ltd transfers on closed std claims
        /// </summary>
        public float PercentLtdTransferOnClosed { get; set; }
        public int TotalDaysLost { get; set; }
        public float AvgDurationDaysLostExcludingLtdTransfers { get; set; }
        public float AvgDurationDaysLostIncludingLtdTransfers { get; set; }
        public int DaysSaved { get; set; }
    }

    internal class StdClaimsByCategoryAndYearViewModel
    {
        public string Category { get; set; }

        public List<ClaimsPercentByYear> ClaimsByYear { get; set; }
    }

    internal class ClaimsPercentByYear
    {
        public int Year { get; set; }
        public float Percent { get; set; }        
    }

    internal class SiteClaimsColumnHeaders
    {
        public string ClaimsY1 { get; set; }
        public string ClaimsY2 { get; set; }
        public string StdReferralY1 { get; set; }
        public string StdReferralY2 { get; set; }
        public string TotalEmployees {get;set;}
        public string StdReferralsIncidentRate { get; set; }
    }

    internal class SiteClaimsStats
    {
        public string Site { get; set; }
        public int TotalClaimsY1 { get; set; }
        public int TotalClaimsY2 { get; set; }
        public float StdReferralPercentY1 { get; set; }
        public float StdReferralPercentY2 { get; set; }
        public int TotalEmployees { get; set; }
        public float StdReferralsIncidentRate { get; set; }
    }

    internal class StdClaimsForGender
    {
        public string Gender { get; set; }
        public int CountUnder30Age { get; set; }
        public int Count31To40Age { get; set; }
        public int Count41To50Age { get; set; }
        public int Count51To60Age { get; set; }
        public int CountAbove60Age { get; set; }
    }

    internal interface IClaimsByCategory
    {
        string Category { get;  }
        int ClaimsCount { get; }
    }

    internal class StdClaimsByClosureReason : IClaimsByCategory
    {
        public string ClosureReason { get; set; }
        public int ClaimsCount { get; set; }

        public string Category => ClosureReason;
    }

    internal class StdClaimsByMedicalCondition : IClaimsByCategory
    {
        public string MedicalCondition { get; set; }
        public int ClaimsCount { get; set; }
        public int DaysAbsent { get; set; }
        public float AvgDuration { get; set; }
        public int LtdTransfers { get; set; }

        public string Category => MedicalCondition;
    }

    internal class StdClaimsByDiagnosis : IClaimsByCategory
    {
        public int MedicalConditionId { get; set; }        
        public string Diagnosis { get; set; }
        public int ClaimsCount { get; set; }

        public string Category => Diagnosis;
    }
}