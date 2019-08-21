using APILayer.Models;
using APILayer.Models.ExecutiveSummary;
using DataLayer;
using HighchartsExportClient;
using Newtonsoft.Json;
using OpenHtmlToPdf;
using Orgsys_2017.Orgsys_Classes;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;

namespace APILayer.Controllers
{

    #region data models 


    /// <summary>
    /// this is the PDF Model used in pdf generation 
    /// </summary>
    public class PdfModel
    {
        public string html { get; set; }
        public int clientId { get; set; }
        public DateTime? fromDate { get; set; }
        public DateTime? toDate { get; set; }

        public bool generatePdf { get; set; }

        /// <summary>
        /// count of eligible employees year 1
        /// </summary>
        public int CountEmployeesYear1 { get; set; }
        /// <summary>
        /// count of eligible employees year 2
        /// </summary>
        public int CountEmployeesYear2 { get; set; }
        /// <summary>
        /// count of eligible employees year 3
        /// </summary>
        public int CountEmployeesYear3 { get; set; }
        /// <summary>
        /// count of eligible employees year 4
        /// </summary>
        public int CountEmployeesYear4 { get; set; }
    }

    #endregion

    [RoutePrefix("api/ExecutiveSummaryReport")]
    public class ExecutiveSummaryReportController : ApiController
    {
        const int MAX_MEDICALCONDITIONS = 6;
        const int MIN_REQUIRED_CLAIMS_BEFORE_AGGREGATION = 3; //there must be at least 3 claims before aggregating into "Other" group

        #region internal typedefs
        //type defs
        private class QueryParameters
        {
            public int clientId { get; set; }
            public string query { get; set; }
            public string queryName { get; set; }
            public DateTime fromDate { get; set; }
            public DateTime toDate { get; set; }

            public static QueryParameters FromApiParameters(PdfModel apiParameters, string queryName)
            {
                return new QueryParameters()
                {
                    clientId = apiParameters.clientId,
                    fromDate = apiParameters.fromDate.Value,
                    toDate = apiParameters.toDate.Value,
                    queryName = queryName
                };
            }
        }

        private class BenchmarkIndicators
        {
            public string Name { get; set; }
            public int Year { get; set; }
            public string PercentIncidentRate { get; set; }
            public string AvgDuration { get; set; }
            public string PercentReturnToWork { get; set; }
            public string PercentStdTransferredToLtd { get; set; }
            public string PercentDecisionTurnaroundFollowingAps { get; set; }
            public BenchmarkClaimCategory[] HighestClaimCategories { get; set; }

            public static BenchmarkIndicators CreateEriccsonBenchmarks(int year)
            {
                BenchmarkIndicators bi = new BenchmarkIndicators();
                bi.Name = "Ericcson";
                bi.Year = year;
                bi.PercentIncidentRate = "3%";
                bi.AvgDuration = "25";
                bi.PercentReturnToWork = "85%";
                bi.PercentStdTransferredToLtd = "8";
                bi.PercentDecisionTurnaroundFollowingAps = "92%";
                bi.HighestClaimCategories = new BenchmarkClaimCategory[]
                {
                    new BenchmarkClaimCategory()
                    {
                        Category="Musculoskeletal",
                        Percentage="26%"
                    },
                    new BenchmarkClaimCategory()
                    {
                        Category="Mental Health",
                        Percentage="23%"
                    },
                };
                return bi;
            }

            public static BenchmarkIndicators CreateOSIBenchmarks(int year)
            {
                BenchmarkIndicators bi = new BenchmarkIndicators();
                bi.Name = "OSI";
                bi.Year = year;
                bi.PercentIncidentRate = "5 - 11%";
                bi.AvgDuration = "21 to 39 days";
                bi.PercentReturnToWork = "80 - 90%";
                bi.PercentStdTransferredToLtd = "4 - 9";
                bi.PercentDecisionTurnaroundFollowingAps = "92%";
                bi.HighestClaimCategories = new BenchmarkClaimCategory[]
                {
                    new BenchmarkClaimCategory()
                    {
                        Category="Musculoskeletal",
                        Percentage="25 - 40%"
                    },
                    new BenchmarkClaimCategory()
                    {
                        Category="Mental Health",
                        Percentage="20 - 35%"
                    },
                };
                return bi;
            }
        }

        private class BenchmarkClaimCategory
        {
            public string Category { get; set; }
            public string Percentage { get; set; }
        }
        #endregion

        /// <summary>
        /// loop for a specified number of years and execute the sql query on each iteration.
        /// </summary>
        /// <param name="queryParameters"></param>
        /// <param name="numYears"></param>
        /// <param name="a"></param>
        /// <returns></returns>
        private async Task ExecuteSqlQueryHelper(QueryParameters queryParameters, int numYears, Action<SqlDataReader, int> a)
        {
            DateTime refToDate = queryParameters.toDate;
            DateTime refFromDate = queryParameters.fromDate;
            int yearsDelta = numYears - 1;
            while (yearsDelta > -1)
            {
                queryParameters.fromDate = refFromDate.AddYears(-yearsDelta);
                queryParameters.toDate = refToDate.AddYears(-yearsDelta);
                int year = queryParameters.toDate.Year;

                using (SqlCommand sqlCommand = new SqlCommand(queryParameters.query, OrgsysdbConn))
                {
                    sqlCommand.CommandType = CommandType.Text;
                    sqlCommand.Parameters.Add("@StartDate", SqlDbType.Date).Value = queryParameters.fromDate;
                    sqlCommand.Parameters.Add("@EndDate", SqlDbType.Date).Value = queryParameters.toDate;
                    sqlCommand.Parameters.Add("@ClientId", SqlDbType.Int).Value = queryParameters.clientId;

                    try
                    {
                        OrgsysdbConn.Open();
                        // Execute the query
                        using (SqlDataReader sqlDataReader = await sqlCommand.ExecuteReaderAsync())
                        {
                            a(sqlDataReader, year);
                        }
                    }
                    catch (Exception ex)
                    {
                        ExceptionLog.LogException(ex);
                    }
                    finally
                    {
                        OrgsysdbConn.Close();
                    }
                }

                yearsDelta--;
            }
        }


        private string[] GetAgeCategories()
        {
            //build age category list
            return new string[]
            {
                "30 / Under",
                "31 to 40",
                "41 to 50",
                "51 to 60",
                "61 / Over"
            };
        }

        private string[] GetSeniorityCategories()
        {
            //build age category list
            return new string[]
            {
                "0 to 1",
                "2 to 3",
                "4 to 5",
                "6 to 7",
                "8 to 9",
                "10 / Over"
            };
        }

        private string[] GetLagTimeCategories()
        {
            return new[]
            {
                "0 to 5",
                "6 to 10",
                "11 to 15",
                "16 to 20",
                "21 to 25",
                "26 to 30",
                "30 / Over"
            };
        }

        private string[] GetBarChartColors(int numSeries)
        {
            var colors = new string[]
            {
                "#92D050",
                "#00B050",
                "#0070C0",
                "#002060"
            };

            if (numSeries >= 4)
            {
                return colors;
            }
            else
            {
                return colors.Skip(4 - numSeries).ToArray();
            }
        }

        private string[] GetPieChartColors()
        {
            return new string[]
            {
                "#91A7CD", "#F7BD8D", "#87A34C", "#4470A5", "#F9E7D7", "#70568D", "#4095AD"
            };
        }

        private int GetIntegerDbValue(object dbValue)
        {
            if (dbValue == null || dbValue == DBNull.Value)
                return 0;
            return Convert.ToInt32(dbValue);
        }

        private string GetStringDbValue(object dbValue, bool treatNullAsEmpty = true)
        {
            if (dbValue == null || dbValue == DBNull.Value)
                return treatNullAsEmpty ? string.Empty : null;
            return Convert.ToString(dbValue);
        }

        /// <summary>
        /// groups the list such that:
        /// - If the list contains more items than maxItemsBeforeOther, the excess items are added to an "Other" item
        /// - If any item contains less claims than minCategorySize, it is removed and grouped into the "Other" item
        /// </summary>
        /// <param name="items"></param>
        /// <param name="minCategorySize"></param>
        /// <param name="maxItemsBeforeOther"></param>
        /// <param name="otherItemCreator">function to generate a new OTher claim category when necessary</param>
        /// <returns></returns>
        private List<IClaimsByCategory> GroupClaimCategories(List<IClaimsByCategory> items, int minCategorySize, int maxItemsBeforeOther, Func<List<IClaimsByCategory>, IClaimsByCategory> otherItemCreator)
        {
            var otherItems = new List<IClaimsByCategory>();

            //sort on count desc
            var sortedItems = items.OrderByDescending(t => t.Category).ToList();

            if (minCategorySize > 0)
            {
                List<int> indicesToRemove = new List<int>();
                //check if any item needs grouping into other                
                for (int i = sortedItems.Count - 1; i >= 0; i--)
                {
                    int claimsCount = sortedItems[i].ClaimsCount;
                    if (claimsCount <= minCategorySize)
                    {
                        otherItems.Add(sortedItems[i]);
                        //remove this one
                        indicesToRemove.Add(i);
                    }
                }

                foreach (var idx in indicesToRemove)
                    sortedItems.RemoveAt(idx);
            }

            if (sortedItems.Count > maxItemsBeforeOther)
            {
                //group into other group
                for (int i = maxItemsBeforeOther; i < sortedItems.Count; i++)
                {
                    otherItems.Add(sortedItems[i]);
                }

                //remove excess items
                sortedItems = sortedItems.Take(maxItemsBeforeOther).ToList();
            }

            if (otherItems.Any())
            {
                //create an other item
                var otherItem = otherItemCreator(otherItems);
                sortedItems.Add(otherItem);
            }

            //sort again
            return sortedItems.OrderByDescending(t => t.ClaimsCount).ToList();
        }

        private async Task<List<IClaimsByCategory>> GetClaimsByMedicalCondition(PdfModel model)
        {
            var sql = "select lic.InjuryCat_EN as MedicalCondition, Count(StdClaims.ClaimId) as CountOfClaims " +
                 "FROM" +
                 "(select ClientName, Claims.* FROM " +
                 "                dbo.GetClientDivisions(@clientId) client" +
                 "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                 "                AND claims.Archived = 0" +
                 "                WHERE Claims.Description = 'STD') as StdClaims " +
                 "INNER JOIN Claim_ICDCM icdcm on icdcm.ClaimID = StdClaims.ClientID " +
                 "INNER JOIN Claim_ICDCMCategory icdcmCat ON icdcmCat.ICDCMID = icdcm.ICDCMID AND icdcmCat.IsPrimary = 1 " +
                 "INNER JOIN List_InjuryCategories lic on lic.InjuryCatID = icdcmcat.CategoryID " +
                 "where StdClaims.ReferralDate BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                 "GROUP BY lic.InjuryCat_EN";

            var claimsByCondition = new List<IClaimsByCategory>();

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 1, (r, y) =>
            {
                while (r.Read())
                {
                    var condition = GetStringDbValue(r["MedicalCondition"]);
                    var countForCondition = GetIntegerDbValue(r["CountOfClaims"]);
                    claimsByCondition.Add(new StdClaimsByMedicalCondition()
                    {
                        MedicalCondition = condition,
                        ClaimsCount = countForCondition
                    });
                }
            });

            claimsByCondition = GroupClaimCategories(claimsByCondition, MIN_REQUIRED_CLAIMS_BEFORE_AGGREGATION, MAX_MEDICALCONDITIONS, (otherItems) =>
            {
                return new StdClaimsByMedicalCondition()
                {
                    MedicalCondition = "Other",
                    ClaimsCount = otherItems.Sum(o => o.ClaimsCount)
                };
            });

            return claimsByCondition;
        }

        private async Task<List<IClaimsByCategory>> GetClaimsByClosureReason(PdfModel model)
        {
            var sql = "select lcr.Desc_EN ClosureReason, Count(StdClaims.ClaimId) as CountOfClaims " +
                "FROM " +
                "(select ClientName, Claims.* FROM dbo.GetClientDivisions(@clientId) client INNER JOIN Claims on claims.ClientID = client.ClientID AND claims.Archived = 0 " +
                "WHERE Claims.Description = 'STD') as StdClaims " +
                "INNER JOIN List_CloseReasons lcr on StdClaims.ReasonClosed = lcr.[index] " +
                "where StdClaims.ReferralDate BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                "GROUP BY lcr.Desc_EN";

            var claimsByCondition = new List<IClaimsByCategory>();

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 1, (r, y) =>
            {
                while (r.Read())
                {
                    var condition = GetStringDbValue(r["ClosureReason"]);
                    var countForCondition = GetIntegerDbValue(r["CountOfClaims"]);
                    claimsByCondition.Add(new StdClaimsByMedicalCondition()
                    {
                        MedicalCondition = condition,
                        ClaimsCount = countForCondition
                    });
                }
            });

            claimsByCondition = GroupClaimCategories(claimsByCondition, 0, 12, (otherItems) =>
            {
                return new StdClaimsByClosureReason()
                {
                    ClosureReason = "Other",
                    ClaimsCount = otherItems.Sum(o => o.ClaimsCount)
                };
            });

            return claimsByCondition;
        }

        private async Task<List<IClaimsByCategory>> GetClaimsByDiagnosis(PdfModel model, int medicalConditionId)
        {
            var sql = "select " +
                "lic.InjuryCatID, lic.InjuryCat_EN as MedicalCondition, " +
                "cid.DiagDescription, Count(StdClaims.ClaimId) as CountOfClaims " +
                "FROM(select ClientName, Claims.* FROM " +
                "dbo.GetClientDivisions(@clientId) client " +
                " INNER JOIN Claims on claims.ClientID = client.ClientID" +
                "             AND claims.Archived = 0" +
                "                  WHERE Claims.Description = 'STD') as StdClaims " +
                "INNER JOIN Claim_ICDCM icdcm on icdcm.ClaimID = StdClaims.ClientID " +
                "INNER JOIN Claim_ICDCMCategory icdcmCat ON icdcmCat.ICDCMID = icdcm.ICDCMID AND icdcmCat.IsPrimary = 1 " +
                "INNER JOIN List_InjuryCategories lic on lic.InjuryCatID = icdcmcat.CategoryID " +
                "INNER JOIN Claim_Injury_Diagnosis cid on cid.CatID = icdcmCat.CatID " +
                "where StdClaims.ReferralDate BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                "AND lic.InjuryCatID = " + medicalConditionId + " " +
                "GROUP BY lic.InjuryCatID, lic.InjuryCat_EN, cid.DiagDescription";

            var claimsByDiagnosis = new List<IClaimsByCategory>();

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 1, (r, y) =>
            {
                while (r.Read())
                {
                    var diagnosis = GetStringDbValue(r["DiagDescription"]);
                    var claims = GetIntegerDbValue(r["CountOfClaims"]);
                    claimsByDiagnosis.Add(new StdClaimsByDiagnosis()
                    {
                        MedicalConditionId = medicalConditionId,
                        Diagnosis = diagnosis,
                        ClaimsCount = claims
                    });
                }
            });

            claimsByDiagnosis = GroupClaimCategories(claimsByDiagnosis, MIN_REQUIRED_CLAIMS_BEFORE_AGGREGATION, 12, (otherItems) =>
            {
                return new StdClaimsByDiagnosis()
                {
                    MedicalConditionId = medicalConditionId,
                    Diagnosis = "Other",
                    ClaimsCount = otherItems.Sum(o => o.ClaimsCount)
                };
            });

            return claimsByDiagnosis;
        }

        // db connections
        SqlConnection OrgsysdbConn = new SqlConnection(ConfigurationManager.ConnectionStrings["OrgsysConnectionString"].ConnectionString);
        OrgSys2017DataContext context = new OrgSys2017DataContext();

        /// <summary>
        /// return hard-coded ericsson benchmarks
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetBenchmarkIndicators")]
        public IHttpActionResult GetBenchmarkIndicators(PdfModel pdfModel)
        {
            int year = pdfModel.toDate.Value.Year;

            return Ok(new[]
            {
                BenchmarkIndicators.CreateOSIBenchmarks(year),
                BenchmarkIndicators.CreateEriccsonBenchmarks(year)
            });
        }

        /// <summary>
        /// convert the whole view html into pdf 
        /// </summary>
        /// <param name="pdfModel"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GeneratePdf")]
        public string GeneratePdf(PdfModel pdfModel)
        {
            float zoomFactor = 1.0f;

            float.TryParse(ConfigurationManager.AppSettings["HtmlToPdfZoomFactor"], out zoomFactor);

            var pdf = Pdf
                        .From(pdfModel.html)
                        .OfSize(PaperSize.A4)
                        .Landscape()
                        .WithoutOutline()
                        .WithGlobalSetting("margin.top", "0cm")
                        .WithGlobalSetting("margin.left", "0cm")
                        .WithGlobalSetting("margin.right", "0cm")
                        .WithGlobalSetting("margin.bottom", "1.5cm")
                        .WithObjectSetting("load.zoomFactor", zoomFactor.ToString("F1"))
                        .WithObjectSetting("footer.htmlUrl", System.Web.Hosting.HostingEnvironment.MapPath("~/Images/ExecutiveSummary/report_footer.html"))
                        .WithObjectSetting("web.enableIntelligentShrinking", "true")
                        .WithObjectSetting("web.defaultEncoding ", "utf-8")
                        .Content();

            return Convert.ToBase64String(pdf);
        }

        /// <summary>
        /// Deletes all the customizations that the user has previously set
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("ResetCustomizationsForUser/{userId}")]
        public Task ResetCustomizationsForUser(int userId)
        {
            var formStatesToDelete = context.FormStates
                .Where(fs => fs.UserId == userId);

            context.FormStates.DeleteAllOnSubmit(formStatesToDelete);
            context.SubmitChanges();

            return Task.CompletedTask;
        }

        /// <summary>
        /// these methods used to generate the images only 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GenertaeChartImage")]
        public async Task<string> GenerateChartImage(string chartResult)
        {
            try
            {
                #region generate Images 
                var settings = new HighchartsSetting
                {
                    ExportImageType = "jpg",
                    ScaleFactor = 2,
                    ImageWidth = 1100,
                    ServerAddress = "http://export.highcharts.com/"
                };
                var client = new HighchartsClient(settings);
                #endregion
                return await client.GetChartImageLinkFromOptionsAsync(chartResult);
            }
            catch (Exception e)
            {
                ExceptionLog.LogException(e);
                return "";
            }
        }

        [HttpPost]
        [Route("GetExecutiveSummarySlideStats")]
        public async Task<IHttpActionResult> GetExecutiveSummarySlideStats(PdfModel model)
        {

            List<ExecutiveSummaryStatsByYear> allStats = new List<ExecutiveSummaryStatsByYear>();

            //1. get claim aggregates            
            const string sql = "select SUM(CASE WHEN DateCreation BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) NewStdClaims, " +
                                "SUM(CASE WHEN DateClosed BETWEEN @StartDate AND @EndDate AND ReasonClosed = 1 THEN 1 ELSE 0 END) CancelledStdClaims, " +
                                "SUM(CASE WHEN DateClosed BETWEEN @StartDate AND @EndDate AND ReasonClosed = 3 THEN 1 ELSE 0 END) NotSupportedStdClaims, " +
                                "SUM(CASE WHEN DateClosed BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) ClosedStdClaims, " +
                                "SUM(CASE WHEN DateClosed BETWEEN @StartDate AND @EndDate AND ReasonClosed = 5 THEN 1 ELSE 0 END) LTDTransferStdClaims ," +
                                "SUM(CASE WHEN DateClosed BETWEEN @StartDate AND @EndDate THEN DaysAbsent ELSE 0 END) TotalDaysLost " +
                                "FROM (select DateCreation, DateClosed, ReasonClosed, " +
                                "SUM(DATEDIFF(day, AbsAuthFrom, COALESCE(AbsAuthTo, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)))) as DaysAbsent" +
                                " FROM" +
                                " (select ClientName, Claims.* FROM dbo.GetClientDivisions(@clientId) client INNER JOIN Claims on claims.ClientID = client.ClientID AND claims.Archived = 0 WHERE Claims.Description = 'STD') as StdClaims" +
                                " LEFT JOIN Claim_Absences ca ON StdClaims.ClaimID = ca.ClaimID" +
                                " GROUP BY  DateCreation, DateClosed, ReasonClosed ) as aggregated";

            //calculate for same date over 4 year historical period
            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;

            int[] employees = new int[] { model.CountEmployeesYear1, model.CountEmployeesYear2, model.CountEmployeesYear3, model.CountEmployeesYear4 };

            int yearCounter = 0;
            await ExecuteSqlQueryHelper(qp, 4, (r, y) =>
            {
                ExecutiveSummaryStatsByYear statsForYear = new ExecutiveSummaryStatsByYear();

                statsForYear.CountEligibleEmployees = employees[yearCounter];
                statsForYear.Year = y;

                if (r.Read())
                {
                    statsForYear.CountNewClaims = GetIntegerDbValue(r["NewStdClaims"]);
                    statsForYear.CountCancelledClaims = GetIntegerDbValue(r["CancelledStdClaims"]);
                    statsForYear.CountNonSupportedStdClaims = GetIntegerDbValue(r["NotSupportedStdClaims"]);
                    statsForYear.CountClosedClaims = GetIntegerDbValue(r["ClosedStdClaims"]);
                    statsForYear.CountClaimsTransferredToLtd = GetIntegerDbValue(r["LTDTransferStdClaims"]);
                    statsForYear.TotalDaysLost = GetIntegerDbValue(r["TotalDaysLost"]);
                }

                if (statsForYear.CountEligibleEmployees > 0)
                    statsForYear.ClaimsIncidentRate = (statsForYear.CountNewClaims / (float)statsForYear.CountEligibleEmployees) * 100.0f;

                var eligibleForIncidentRate = statsForYear.CountClosedClaims - statsForYear.CountCancelledClaims;
                if (eligibleForIncidentRate > 0)
                    statsForYear.PercentLtdTransferOnClosed = (statsForYear.CountClaimsTransferredToLtd / (float)eligibleForIncidentRate) * 100.0f;

                var eligibleForAvg = statsForYear.CountClosedClaims;
                if (eligibleForAvg > 0)
                    statsForYear.AvgDurationDaysLostIncludingLtdTransfers = (statsForYear.TotalDaysLost / (float)eligibleForAvg);
                eligibleForAvg = statsForYear.CountClosedClaims - statsForYear.CountClaimsTransferredToLtd;
                if (eligibleForAvg > 0)
                    statsForYear.AvgDurationDaysLostExcludingLtdTransfers = (statsForYear.TotalDaysLost / (float)eligibleForAvg);

                allStats.Add(statsForYear);
                yearCounter++;
            });

            return Ok(new
            {
                ClientId = model.clientId,
                Years = allStats.Select(s => s.Year).ToArray(),
                Employees = employees,
                StatsByYear = allStats.ToArray()
            });
        }

        #region jsonData for tables
        /// <summary>
        /// Get data for claims by site table
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsbySite")]
        public async Task<IHttpActionResult> GetDataForClaimsbySite(PdfModel model)
        {

            Dictionary<string, List<Tuple<int, int>>> siteDict = new Dictionary<string, List<Tuple<int, int>>>();
            Dictionary<int, int> totalsForYear = new Dictionary<int, int>();

            var sql = "Select DivisionName, Count(1) as CountOfClaims " +
                "FROM " +
                "(select ClientName, DivisionName, Claims.* FROM " +
                "dbo.GetClientDivisions(@clientId) clientSite INNER JOIN Claims on claims.ClientID = clientSite.ClientID AND claims.Archived = 0" +
                "WHERE Claims.Description = 'STD') as ClaimsBySite " +
                "WHERE ClaimsBySite.DateCreation BETWEEN @startdate AND DATEADD(day, 1, @endDate) " +
                "GROUP BY DivisionName";

            //calculate for same date over 2 year historical period
            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 2, (r, year) =>
            {
                int totalClaims = 0;

                while (r.Read())
                {
                    string division = GetStringDbValue(r["DivisionName"]);
                    Tuple<int, int> yearTuple = new Tuple<int, int>(year, GetIntegerDbValue(r["CountOfClaims"]));
                    totalClaims += yearTuple.Item2;

                    if (!siteDict.ContainsKey(division))
                        siteDict.Add(division, new List<Tuple<int, int>>()
                            {
                                yearTuple
                            });
                    else
                        siteDict[division].Add(yearTuple);

                }

                totalsForYear.Add(year, totalClaims);
            });

            //generate vm
            List<SiteClaimsStats> claimsByAllSites = new List<SiteClaimsStats>();

            //get distinct sites

            int year1 = model.toDate.Value.AddYears(-1).Year;
            int year2 = model.toDate.Value.Year;

            var sites = siteDict.Keys.ToArray();
            foreach (var site in sites)
            {
                SiteClaimsStats siteClaimsStats = new SiteClaimsStats()
                {
                    Site = site,
                };

                siteClaimsStats.TotalClaimsY1 = (siteDict[site].FirstOrDefault(t => t.Item1 == year1)?.Item2).GetValueOrDefault();
                siteClaimsStats.TotalClaimsY2 = (siteDict[site].FirstOrDefault(t => t.Item1 == year2)?.Item2).GetValueOrDefault();
                siteClaimsStats.TotalEmployees = model.CountEmployeesYear4;

                if (siteClaimsStats.TotalEmployees > 0)
                    siteClaimsStats.StdReferralsIncidentRate = (siteClaimsStats.TotalClaimsY2 / (float)siteClaimsStats.TotalEmployees) * 100.0f;

                claimsByAllSites.Add(siteClaimsStats);
            }

            //build column headers

            SiteClaimsColumnHeaders claimsColumnHeaders = new SiteClaimsColumnHeaders()
            {
                ClaimsY1 = "STD Referrals<br>" + year1,
                ClaimsY2 = "STD Referrals<br>" + year2,
                StdReferralY1 = $"STD Referral <br>{year1}%",
                StdReferralY2 = $"STD Referral <br>{year2}%",
                TotalEmployees = $"Total Employees<br>{year2}",
                StdReferralsIncidentRate = $"STD Referrals<br>{year2}<br>Incident Rates"
            };

            return Ok(new { columnHeaders = claimsColumnHeaders, data = claimsByAllSites });

        }


        /// <summary>
        /// Get data for claims by province table
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsbyProvince")]
        public async Task<IHttpActionResult> GetDataForClaimsbyProvince(PdfModel model)
        {

            Dictionary<string, List<Tuple<int, int>>> provinceDict = new Dictionary<string, List<Tuple<int, int>>>();
            Dictionary<int, int> totalsForYear = new Dictionary<int, int>();

            var sql = "select ce.Province, Count(StdClaims.ClaimID) as CountOfClaims FROM " +
                        "(select ClientName, Claims.* FROM " +
                        "dbo.GetClientDivisions(@clientId) client " +
                        "INNER JOIN Claims on claims.ClientID = client.ClientID " +
                        "AND claims.Archived = 0 " +
                        "WHERE Claims.Description = 'STD') as StdClaims " +
                        "INNER JOIN Claim_Employee ce on ce.ClaimID = StdClaims.ClaimID " +
                        "WHERE StdClaims.DateCreation BETWEEN @StartDate AND DATEADD(d, 1, @EndDate) " +
                        "GROUP BY ce.Province";


            //calculate for same date over 4 year historical period
            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                int sumAllProvinces = 0;

                while (r.Read())
                {
                    string province = GetStringDbValue(r["Province"]);
                    Tuple<int, int> yearTuple = new Tuple<int, int>(year, GetIntegerDbValue(r["CountOfClaims"]));
                    sumAllProvinces += yearTuple.Item2;

                    if (!provinceDict.ContainsKey(province))
                        provinceDict.Add(province, new List<Tuple<int, int>>()
                            {
                                yearTuple
                            });
                    else
                        provinceDict[province].Add(yearTuple);

                }

                totalsForYear.Add(year, sumAllProvinces);
            });

            //generate vm
            List<StdClaimsByCategoryAndYearViewModel> claimsByAllProvinces = new List<StdClaimsByCategoryAndYearViewModel>();

            //get distinct provinces
            var provinces = provinceDict.Keys.ToArray();
            foreach (var province in provinces)
            {
                var stdClaimsByProvince = new StdClaimsByCategoryAndYearViewModel()
                {
                    Category = province,
                    ClaimsByYear = new List<ClaimsPercentByYear>()
                };

                int yearsDelta = 3;
                while (yearsDelta > -1)
                {
                    int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                    //get count for province for year
                    int claimsForProvince = (provinceDict[province].FirstOrDefault(t => t.Item1 == year)?.Item2).GetValueOrDefault();
                    int totalForYear = totalsForYear.ContainsKey(year) ? totalsForYear[year] : 0;

                    var claimPercentByYear = new ClaimsPercentByYear()
                    {
                        Year = year,
                        Percent = totalForYear > 0 ? (claimsForProvince / (float)totalForYear) * 100.0f : 0
                    };
                    stdClaimsByProvince.ClaimsByYear.Add(claimPercentByYear);
                    yearsDelta--;
                }

                claimsByAllProvinces.Add(stdClaimsByProvince);
            }

            return Ok(new
            {
                years = totalsForYear.Keys.ToArray(),
                data = claimsByAllProvinces
            });

        }
        #endregion

        #region get json data for charts
        /// <summary>
        /// Get data for bar chart of claims referral by month
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForReferralByMonthClaims")]
        public async Task<IHttpActionResult> GetDataForReferralByMonthClaims(PdfModel model)
        {

            ChartSeriesCollection<string, int> chartSeriesCollection = new ChartSeriesCollection<string, int>();

            var sql = "select MONTH(StdClaims.DateCreation) as dMonth, Count(StdClaims.ClaimID) as CountOfClaims FROM " +
                        "(select ClientName, Claims.* FROM " +
                        "dbo.GetClientDivisions(@clientId) client " +
                        "INNER JOIN Claims on claims.ClientID = client.ClientID " +
                        "AND claims.Archived = 0 " +
                        "WHERE Claims.Description='STD') as StdClaims " +
                        "WHERE StdClaims.DateCreation BETWEEN @StartDate AND DATEADD(day, 1, @EndDate) " +
                        "GROUP BY MONTH(StdClaims.DateCreation)";

            //build month names list
            var dt = new DateTime(DateTime.Now.Year, 1, 1);
            List<string> monthNames = new List<string>(12);
            for (int i = 0; i < 12; i++)
            {
                monthNames.Add(dt.AddMonths(i).ToString("MMM"));
            };

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                ChartSeries<string, int> yearSeries = new ChartSeries<string, int>();
                yearSeries.Name = year.ToString();

                List<Tuple<int, int>> monthsWithData = new List<Tuple<int, int>>();

                while (r.Read())
                {
                    int month = GetIntegerDbValue(r["dMonth"]);
                    int count = GetIntegerDbValue(r["CountOfClaims"]);
                    monthsWithData.Add(new Tuple<int, int>(month, count));
                }

                //fill the whole series
                for (int i = 0; i < 12; i++)
                {
                    var monthData = monthsWithData.FirstOrDefault(t => t.Item1 == i + 1);
                    if (monthData != null)
                        yearSeries.Add(new Tuple<string, int>(monthNames[i], monthData.Item2));
                    else
                        yearSeries.Add(new Tuple<string, int>(monthNames[i], 0));
                }

                chartSeriesCollection.Add(yearSeries);
            });

            var chartOptions = new
            {
                chart = new
                {
                    type = "column",
                    height = "45%"
                },
                title = new
                {
                    text = "New STD Referrals By Month"
                },
                xAxis = new
                {
                    categories = monthNames.ToArray()
                },
                yAxis = new
                {
                    min = 0,
                    title = new
                    {
                        text = "Claims Referred"
                    }
                },
                plotOptions = new
                {
                    series = new
                    {
                        pointPadding = 0,
                        groupPadding = 0.2,
                        border = 0
                    }
                },
                legend = new
                {
                    enabled = false
                },
                colors = GetBarChartColors(4),
                series = chartSeriesCollection.Series.Select(s => new
                {
                    name = s.Name,
                    data = s.Select(sd => sd.Item2).ToArray()
                })
            };

            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new { results = chartOptions, imageUrl = chartImageUrl });
        }

        /// <summary>
        /// Get data for bar chart of new STD Claims By Gender and age
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByGenderAndAge")]
        public async Task<IHttpActionResult> GetDataForClaimsByGenderAndAge(PdfModel model)
        {
            var sql = "SELECT Gender, " +
                 "SUM(CASE WHEN eAge <= 30 THEN 1 ELSE 0 END) as Count30AndUnder, " +
                 "SUM(CASE WHEN eAge > 30 AND eAge <= 40 THEN 1 ELSE 0 END) as Count31To40, " +
                 "SUM(CASE WHEN eAge > 40 AND eAge <= 50 THEN 1 ELSE 0 END) as Count41To50, " +
                 "SUM(CASE WHEN eAge > 50 AND eAge <= 60 THEN 1 ELSE 0 END) as Count51To60, " +
                 "SUM(CASE WHEN eAge > 60 THEN 1 ELSE 0 END) as Count60AndOver " +
                 "FROM (select ClientID, clientname," +
                 "IIF(ce.DOB Is Null, 0, DateDiff(year, ce.DOB, StdClaims.DateCreation) + IIF(DATEADD(MONTH, DATEDIFF(MONTH, 0, StdClaims.DateCreation), 0) < DATEADD(MONTH, DATEDIFF(MONTH, 0, DOB), 0), 1, 0)) as eAge," +
                 "ce.Gender FROM " +
                 "(select ClientName, Claims.* FROM " +
                 "dbo.GetClientDivisions(@clientId) client" +
                 "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                 "                AND claims.Archived = 0" +
                "                 WHERE Claims.Description = 'STD') as StdClaims " +
                 "                INNER JOIN Claim_Employee ce ON ce.ClaimID = StdClaims.ClaimID " +
                 "WHERE StdClaims.DateCreation BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                 "AND ce.DOB > '01/01/1850') as ClaimsEmployeeAgeGender " +
                 "GROUP BY Gender";

            ChartSeriesCollection<string, int> chartSeriesCollection = new ChartSeriesCollection<string, int>();
            List<StdClaimsForGender> stdClaimsByGender = new List<StdClaimsForGender>();

            //get gender list
            var genderList = context.GetList_Gender().ToList();
            var ageCategories = GetAgeCategories();

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;

            await ExecuteSqlQueryHelper(qp, 1, (r, y) =>
            {
                ChartSeries<string, int> genderSeries = new ChartSeries<string, int>();

                while (r.Read())
                {
                    var claimsForGender = new StdClaimsForGender()
                    {
                        Gender = GetStringDbValue(r["Gender"]),
                        CountUnder30Age = GetIntegerDbValue(r["Count30AndUnder"]),
                        Count31To40Age = GetIntegerDbValue(r["Count31To40"]),
                        Count41To50Age = GetIntegerDbValue(r["Count41To50"]),
                        Count51To60Age = GetIntegerDbValue(r["Count51To60"]),
                        CountAbove60Age = GetIntegerDbValue(r["Count60AndOver"]),
                    };
                    stdClaimsByGender.Add(claimsForGender);
                }
            });

            //fill the series

            foreach (var gender in genderList.Select(g => g.Gen_EN))
            {
                ChartSeries<string, int> stdClaimsByGenderSeries = new ChartSeries<string, int>();
                stdClaimsByGenderSeries.Name = gender;

                //do we have data for this gender?
                var claimsForGender = stdClaimsByGender.FirstOrDefault(g => g.Gender == gender);
                if (claimsForGender == null)
                {
                    foreach (var category in ageCategories)
                        stdClaimsByGenderSeries.Add(new Tuple<string, int>(category, 0));
                }
                else
                {
                    stdClaimsByGenderSeries.Add(new Tuple<string, int>(ageCategories[0], claimsForGender.CountUnder30Age));
                    stdClaimsByGenderSeries.Add(new Tuple<string, int>(ageCategories[1], claimsForGender.Count31To40Age));
                    stdClaimsByGenderSeries.Add(new Tuple<string, int>(ageCategories[2], claimsForGender.Count41To50Age));
                    stdClaimsByGenderSeries.Add(new Tuple<string, int>(ageCategories[3], claimsForGender.Count51To60Age));
                    stdClaimsByGenderSeries.Add(new Tuple<string, int>(ageCategories[4], claimsForGender.CountAbove60Age));
                }

                chartSeriesCollection.Add(stdClaimsByGenderSeries);
            }
            var chartOptions = new
            {
                chart = new
                {
                    type = "column",
                    height = "45%"
                },
                title = new
                {
                    text = $"New STD Claims {model.toDate.Value.Year}: By Gender & Age"
                },
                xAxis = new
                {
                    categories = ageCategories
                },
                yAxis = new
                {
                    min = 0,
                    title = new
                    {
                        text = "Claims Referred"
                    }
                },
                plotOptions = new
                {
                    series = new
                    {
                        pointPadding = 0,
                        groupPadding = 0.2,
                        border = 0
                    }
                },
                legend = new
                {
                    enabled = false
                },
                colors = GetBarChartColors(3),
                series = chartSeriesCollection.Series.Select(s =>
                    new
                    {
                        name = s.Name,
                        data = s.Select(sd => sd.Item2)
                    })
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new { results = chartOptions, imageUrl = chartImageUrl });
        }

        /// <summary>
        /// get a table of data for claims by gender for a period of 4 years 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByGenderYearOverYear")]
        public async Task<IHttpActionResult> GetDataForClaimsByGenderYearOverYear(PdfModel model)
        {
            var sql = "select ce.Gender, Count(stdClaims.ClaimId) as CountOfClaims FROM " +
                "(select ClientName, Claims.* FROM" +
                "                dbo.GetClientDivisions(@clientId) client" +
                "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                "                AND claims.Archived = 0" +
                "                WHERE Claims.Description = 'STD') as StdClaims " +
                "INNER JOIN Claim_Employee ce ON ce.ClaimID = StdClaims.ClaimID WHERE " +
                "StdClaims.DateCreation BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                "AND ce.DOB > '01/01/1850' " +
                "Group By Gender";

            //each entry is a gender with a list of year->value tuples
            Dictionary<string, List<Tuple<int, int>>> genderTableData = new Dictionary<string, List<Tuple<int, int>>>();
            Dictionary<int, int> totalsForYears = new Dictionary<int, int>();

            //get gender list
            var genderList = context.GetList_Gender().Select(g => g.Gen_EN).ToList();
            //build gender dict
            foreach (var gender in genderList)
                genderTableData.Add(gender, new List<Tuple<int, int>>());

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;

            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                int sumAllGenders = 0;

                while (r.Read())
                {
                    string gender = GetStringDbValue(r["Gender"]);
                    Tuple<int, int> yearTuple = new Tuple<int, int>(year, GetIntegerDbValue(r["CountOfClaims"]));
                    sumAllGenders += yearTuple.Item2;
                    genderTableData[gender].Add(yearTuple);
                }

                totalsForYears.Add(year, sumAllGenders);
            });


            //generate vm
            List<StdClaimsByCategoryAndYearViewModel> claimsByAllGenders = new List<StdClaimsByCategoryAndYearViewModel>();

            foreach (var gender in genderList)
            {
                var stdClaimsByGender = new StdClaimsByCategoryAndYearViewModel()
                {
                    Category = gender,
                    ClaimsByYear = new List<ClaimsPercentByYear>()
                };

                int yearsDelta = 3;
                while (yearsDelta > -1)
                {
                    int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                    //get count for gender for year
                    int claimsForGender = (genderTableData[gender].FirstOrDefault(t => t.Item1 == year)?.Item2).GetValueOrDefault();
                    int totalForYear = totalsForYears[year];

                    var claimPercentByYear = new ClaimsPercentByYear()
                    {
                        Year = year,
                        Percent = totalForYear > 0 ? (claimsForGender / (float)totalForYear) * 100.0f : 0
                    };
                    stdClaimsByGender.ClaimsByYear.Add(claimPercentByYear);
                    yearsDelta--;
                }

                claimsByAllGenders.Add(stdClaimsByGender);
            }

            return Ok(new
            {
                years = totalsForYears.Keys.ToArray(),
                data = claimsByAllGenders
            });
        }

        /// <summary>
        /// get a table of data for claims by age for a period of 4 years
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByAgeYearOverYear")]
        public async Task<IHttpActionResult> GetDataForClaimsByAgeYearOverYear(PdfModel model)
        {
            var sql = "SELECT " +
                "SUM(CASE WHEN eAge <= 30 THEN 1 ELSE 0 END) as Count30AndUnder," +
                "SUM(CASE WHEN eAge > 30 AND eAge <= 40 THEN 1 ELSE 0 END) as Count31To40," +
                "SUM(CASE WHEN eAge > 40 AND eAge <= 50 THEN 1 ELSE 0 END) as Count41To50," +
                "SUM(CASE WHEN eAge > 50 AND eAge <= 60 THEN 1 ELSE 0 END) as Count51To60," +
                "SUM(CASE WHEN eAge > 60THEN 1 ELSE 0 END) as Count60AndOver," +
                "Count(1) as TotalClaims " +
                "FROM " +
                "(select ClientID, clientname, " +
                "IIF(ce.DOB Is Null, 0, DateDiff(year, ce.DOB, StdClaims.ReferralDate) + " +
                "IIF(DATEADD(MONTH, DATEDIFF(MONTH, 0, StdClaims.DateCreation), 0) < DATEADD(MONTH, DATEDIFF(MONTH, 0, DOB), 0), 1, 0)) as eAge FROM " +
                "(select ClientName, Claims.* FROM " +
                "                dbo.GetClientDivisions(@clientId) client" +
                "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                "                AND claims.Archived = 0" +
                "                WHERE Claims.Description = 'STD') as StdClaims " +
                "INNER JOIN Claim_Employee ce ON ce.ClaimID = StdClaims.ClaimID " +
                "WHERE StdClaims.DateCreation BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                "AND ce.DOB > '01/01/1850') As EmployeeClaimsAge";

            //each entry is an age category with a list of year->value tuples
            Dictionary<string, List<Tuple<int, int>>> ageCategoriesTableData = new Dictionary<string, List<Tuple<int, int>>>();
            Dictionary<int, int> totalsForYears = new Dictionary<int, int>();

            //get age category list
            var ageCategories = GetAgeCategories();

            //prime output dict
            foreach (var category in ageCategories)
                ageCategoriesTableData.Add(category, new List<Tuple<int, int>>());


            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;

            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                //there will be only one row / year
                int total = 0;
                if (r.Read())
                {
                    total = GetIntegerDbValue(r["TotalClaims"]);
                    //field order is the same as the category order
                    for (int i = 0; i < ageCategories.Length; i++)
                    {
                        int countForCategory = GetIntegerDbValue(r[i]);
                        ageCategoriesTableData[ageCategories[i]].Add(new Tuple<int, int>(year, countForCategory));
                    }
                }

                totalsForYears.Add(year, total);
            });


            //generate vm
            List<StdClaimsByCategoryAndYearViewModel> claimsByAgeCategories = new List<StdClaimsByCategoryAndYearViewModel>();

            foreach (var ageCategory in ageCategories)
            {
                var stdClaimsByAgeCategory = new StdClaimsByCategoryAndYearViewModel()
                {
                    Category = ageCategory,
                    ClaimsByYear = new List<ClaimsPercentByYear>()
                };

                int yearsDelta = 3;
                while (yearsDelta > -1)
                {
                    int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                    //get count for gender for year
                    int claimsForAgeCategory = (ageCategoriesTableData[ageCategory].FirstOrDefault(t => t.Item1 == year)?.Item2).GetValueOrDefault();
                    int totalForYear = totalsForYears[year];

                    var claimPercentByYear = new ClaimsPercentByYear()
                    {
                        Year = year,
                        Percent = totalForYear > 0 ? (claimsForAgeCategory / (float)totalForYear) * 100.0f : 0
                    };
                    stdClaimsByAgeCategory.ClaimsByYear.Add(claimPercentByYear);
                    yearsDelta--;
                }

                claimsByAgeCategories.Add(stdClaimsByAgeCategory);
            }

            return Ok(new
            {
                years = totalsForYears.Keys.ToArray(),
                data = claimsByAgeCategories,
                totals = totalsForYears.Values.ToArray()
            });
        }


        /// <summary>
        /// Get data for bar chart by seniority
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsBySeniority")]
        public async Task<IHttpActionResult> GetDataForClaimsBySeniority(PdfModel model)
        {
            ChartSeriesCollection<string, int> chartSeriesCollection = new ChartSeriesCollection<string, int>();

            var sql = "SELECT " +
                "SUM(CASE WHEN eSeniority <= 1 THEN 1 ELSE 0 END) as Count0To1Years," +
                "SUM(CASE WHEN eSeniority > 1 AND eSeniority <= 2 THEN 1 ELSE 0 END) as Count2To3Years," +
                "SUM(CASE WHEN eSeniority > 3 AND eSeniority <= 5 THEN 1 ELSE 0 END) as Count4To5Years," +
                "SUM(CASE WHEN eSeniority > 5 AND eSeniority <= 7 THEN 1 ELSE 0 END) as Count6To7Years," +
                "SUM(CASE WHEN eSeniority > 7 AND eSeniority <= 9 THEN 1 ELSE 0 END) as Count8o9Years," +
                "SUM(CASE WHEN eSeniority > 9 THEN 1 ELSE 0 END) as Count10YearsAndOver " +
                "FROM " +
                "(select ClientID, clientname, " +
                "IIF(ce.HiringDate Is Null, 0, DateDiff(year, ce.HiringDate, StdClaims.ReferralDate) + " +
                "IIF(DATEADD(MONTH, DATEDIFF(MONTH, 0, StdClaims.DateCreation), 0) < DATEADD(MONTH, DATEDIFF(MONTH, 0, HiringDate), 0), 1, 0)) as eSeniority" +
                " FROM " +
                "(select ClientName, Claims.* FROM " +
                "                dbo.GetClientDivisions(@clientId) client" +
                "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                "                AND claims.Archived = 0" +
                "                WHERE Claims.Description = 'STD') as StdClaims " +
                "INNER JOIN Claim_Employee ce ON ce.ClaimID = StdClaims.ClaimID WHERE " +
                "StdClaims.DateCreation BETWEEN @startDate AND @endDate AND ce.DOB > '01/01/1850' " +
                ") As EmployeeClaimsSeniority";

            var seniorityCategories = GetSeniorityCategories();

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                ChartSeries<string, int> yearSeries = new ChartSeries<string, int>();
                yearSeries.Name = year.ToString();

                if (r.Read())
                {
                    //field names align with categories
                    for (int i = 0; i < seniorityCategories.Length; i++)
                    {
                        yearSeries.Add(new Tuple<string, int>(seniorityCategories[i], GetIntegerDbValue(r[i])));
                    }
                }
                else
                {
                    //empty list
                    foreach (var category in seniorityCategories)
                        yearSeries.Add(new Tuple<string, int>(category, 0));
                }

                chartSeriesCollection.Add(yearSeries);
            });

            var chartOptions = new
            {
                chart = new
                {
                    type = "column",
                    height = "45%"
                },
                title = new
                {
                    text = "STD Claims - By Seniority (Yrs)"
                },
                xAxis = new
                {
                    categories = seniorityCategories.ToArray()
                },
                yAxis = new
                {
                    min = 0,
                    title = new
                    {
                        text = "Claims Referred"
                    }
                },
                plotOptions = new
                {
                    series = new
                    {
                        pointPadding = 0,
                        groupPadding = 0.2,
                        border = 0
                    }
                },
                legend = new
                {
                    enabled = false
                },
                colors = GetBarChartColors(4),
                series = chartSeriesCollection.Series.Select(s => new
                {
                    name = s.Name,
                    data = s.Select(sd => sd.Item2).ToArray()
                }),
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new { results = chartOptions, imageUrl = chartImageUrl });
        }

        /// <summary>
        /// Get image url of pie chart by medical condition
        /// </summary>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByMedicalCondition")]
        public async Task<IHttpActionResult> GetDataForClaimsByMedicalCondition(PdfModel model)
        {
            var claimsByCondition = await GetClaimsByMedicalCondition(model);
            int year = model.toDate.Value.Year;
            int totalClaims = claimsByCondition.Sum(c => c.ClaimsCount);

            //calculate percentages
            ChartSeries<string, float> chartSeries = new ChartSeries<string, float>();

            foreach (var claimCount in claimsByCondition)
            {
                chartSeries.Add(new Tuple<string, float>(claimCount.Category,
                    totalClaims > 0 ? (claimCount.ClaimsCount / (float)totalClaims) * 100.0f : 0
                    ));
            }

            var chartOptions = new
            {
                chart = new
                {
                    type = "pie",
                    options3d = new
                    {
                        enabled = true,
                        alpha = 60,
                        beta = 0
                    },
                    height = "55%"
                },
                title = new
                {
                    text = $"New STD Claims {year} – by Medical Condition"
                },
                plotOptions = new
                {
                    pie = new
                    {
                        allowPointSelect = true,
                        cursor = "pointer",
                        depth = 60,
                        dataLabels = new
                        {
                            enabled = true,
                            style = new
                            {
                                textOutline = false
                            }
                        },
                        //showInLegend = true,
                        colors = GetPieChartColors()
                    }
                },
                //legend = new
                //{
                //    align = "right",
                //    verticalAlign = "middle",
                //    layout = "vertical",
                //    x = -50,
                //    y = 0,
                //    itemMarginTop = 15,
                //    itemMarginBottom = 15,
                //    symbolRadius = 0
                //},
                series = new[]{
                        new
                        {
                            name= "Medical Conditions",
                            data = chartSeries.Select(t =>
                            new
                            {
                                name = $"{t.Item1} ({t.Item2.ToString("0")}%)",
                                y = t.Item2
                            })
                        }
                     }
            };

            //build footer text
            StringBuilder sb = new StringBuilder();
            for (var i = 0; i < Math.Min(2, chartSeries.Count); i++)
            {
                var c = chartSeries[i];
                sb.Append($"<div>{c.Item2.ToString("0")}% of STD Claims were {c.Item1} claims</div>");
            }

            var otherData = new
            {
                totalClaims,
                footerText = sb.ToString()
            };

            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new
            {
                results = chartOptions,
                otherData,
                imageUrl = chartImageUrl
            });
        }

        /// <summary>
        /// GetDataForClaimsByMedicalConditionYearOverYear
        /// </summary>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByMedicalYearOverYear")]
        public async Task<IHttpActionResult> GetDataForClaimsByMedicalConditionYearOverYear(PdfModel model)
        {

            Dictionary<int, List<IClaimsByCategory>> medicalConditionsDict = new Dictionary<int, List<IClaimsByCategory>>();
            Dictionary<int, int> totalsForYears = new Dictionary<int, int>();

            int yearsDelta = 3;
            while (yearsDelta > -1)
            {
                int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                //get medical conditions for the year
                var yearModel = new PdfModel()
                {
                    clientId = model.clientId,
                    fromDate = model.fromDate.Value.AddYears(-yearsDelta),
                    toDate = model.toDate.Value.AddYears(-yearsDelta)
                };

                var claimsByMedicalCondition = await GetClaimsByMedicalCondition(yearModel);
                medicalConditionsDict.Add(year, claimsByMedicalCondition);

                totalsForYears.Add(year, claimsByMedicalCondition.Sum(t => t.ClaimsCount));

                yearsDelta--;
            }

            //get distinct conditions
            var distinctMedicalConditions = medicalConditionsDict.Values.SelectMany(t => t.Select(t2 => t2.Category)).Distinct();

            //generate final vm
            List<StdClaimsByCategoryAndYearViewModel> medicalConditionClaims = new List<StdClaimsByCategoryAndYearViewModel>();

            foreach (var medicalCondition in distinctMedicalConditions)
            {
                var stdClaimsByCondition = new StdClaimsByCategoryAndYearViewModel()
                {
                    Category = medicalCondition,
                    ClaimsByYear = new List<ClaimsPercentByYear>()
                };

                yearsDelta = 3;
                while (yearsDelta > -1)
                {
                    int year = model.toDate.Value.AddYears(-yearsDelta).Year;

                    //get count for condition for that year
                    int claimCount = (medicalConditionsDict[year].FirstOrDefault(t => t.Category == medicalCondition)?.ClaimsCount).GetValueOrDefault();
                    int totalForYear = totalsForYears[year];

                    var claimPercentByYear = new ClaimsPercentByYear()
                    {
                        Year = year,
                        Percent = totalForYear > 0 ? (claimCount / (float)totalForYear) * 100.0f : 0
                    };
                    stdClaimsByCondition.ClaimsByYear.Add(claimPercentByYear);

                    yearsDelta--;
                }

                medicalConditionClaims.Add(stdClaimsByCondition);

            }

            return Ok(
                new
                {
                    years = totalsForYears.Keys.ToArray(),
                    data = medicalConditionClaims
                });
        }

        /// <summary>
        /// Get image url of pie chart by diagnosis by medical condition musculoskeletal
        /// </summary>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByDiagnosisMusculoskeletal")]
        public async Task<IHttpActionResult> GetDataForClaimsByDiagnosisMusculoskeletal(PdfModel model)
        {
            var claimsByCondition = await GetClaimsByDiagnosis(model, 1);
            int year = model.toDate.Value.Year;
            int totalClaims = claimsByCondition.Sum(c => c.ClaimsCount);

            //calculate percentages
            ChartSeries<string, float> chartSeries = new ChartSeries<string, float>();

            foreach (var claimCount in claimsByCondition)
            {
                chartSeries.Add(new Tuple<string, float>(claimCount.Category,
                    totalClaims > 0 ? (claimCount.ClaimsCount / (float)totalClaims) * 100.0f : 0
                    ));
            }

            var chartOptions = new
            {
                chart = new
                {
                    type = "pie",
                    options3d = new
                    {
                        enabled = true,
                        alpha = 60,
                        beta = 0
                    },
                    height = "55%"
                },
                title = new
                {
                    text = $"New Musculoskeletal STD Claims {year} – by Diagnosis"
                },
                plotOptions = new
                {
                    pie = new
                    {
                        allowPointSelect = true,
                        cursor = "pointer",
                        depth = 60,
                        dataLabels = new
                        {
                            enabled = true,
                            style = new
                            {
                                textOutline = false
                            }
                        },
                        //showInLegend = true,
                        colors = GetPieChartColors()
                    }
                },
                //legend = new
                //{
                //    align = "right",
                //    verticalAlign = "middle",
                //    layout = "vertical",
                //    x = -50,
                //    y = 0,
                //    itemMarginTop = 15,
                //    itemMarginBottom = 15,
                //    symbolRadius = 0
                //},
                series = new[]{
                        new
                        {
                            name= "Diagnosis",
                            data = chartSeries.Select(t =>
                            new
                            {
                                name = $"{t.Item1} ({t.Item2.ToString("0")}%)",
                                y = t.Item2
                            })
                        }
                     }
            };

            //build footer text
            StringBuilder sb = new StringBuilder();
            for (var i = 0; i < Math.Min(2, chartSeries.Count); i++)
            {
                var c = chartSeries[i];
                sb.Append($"<div>{c.Item2.ToString("0")}% of M.S. STD Claims were {c.Item1}</div>");
            }

            var otherData = new
            {
                totalClaims,
                footerText = sb.ToString()
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new
            {
                results = chartOptions,
                otherData,
                imageUrl = chartImageUrl
            });
        }

        /// <summary>
        /// Get image url of pie chart by diagnosis by medical condition Mental Health
        /// </summary>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByDiagnosisMentalHealth")]
        public async Task<IHttpActionResult> GetDataForClaimsByDiagnosisMentalHealth(PdfModel model)
        {
            var claimsByCondition = await GetClaimsByDiagnosis(model, 42);
            int year = model.toDate.Value.Year;
            int totalClaims = claimsByCondition.Sum(c => c.ClaimsCount);

            //calculate percentages
            ChartSeries<string, float> chartSeries = new ChartSeries<string, float>();

            foreach (var claimCount in claimsByCondition)
            {
                chartSeries.Add(new Tuple<string, float>(claimCount.Category,
                    totalClaims > 0 ? (claimCount.ClaimsCount / (float)totalClaims) * 100.0f : 0
                    ));
            }

            var chartOptions = new
            {
                chart = new
                {
                    type = "pie",
                    options3d = new
                    {
                        enabled = true,
                        alpha = 60,
                        beta = 0
                    },
                    height = "55%"
                },
                title = new
                {
                    text = $"New Mental Health STD Claims {year} – by Diagnosis"
                },
                plotOptions = new
                {
                    pie = new
                    {
                        allowPointSelect = true,
                        cursor = "pointer",
                        depth = 60,
                        dataLabels = new
                        {
                            enabled = true,
                            style = new
                            {
                                textOutline = false
                            }
                        },
                        //showInLegend = true,
                        colors = GetPieChartColors()
                    }
                },
                //legend = new
                //{
                //    align = "right",
                //    verticalAlign = "middle",
                //    layout = "vertical",
                //    x = -50,
                //    y = 0,
                //    itemMarginTop = 15,
                //    itemMarginBottom = 15,
                //    symbolRadius = 0
                //},
                series = new[]{
                        new
                        {
                            name= "Diagnosis",
                            data = chartSeries.Select(t =>
                            new
                            {
                                name = $"{t.Item1} ({t.Item2.ToString("0")}%)",
                                y = t.Item2
                            })
                        }
                     }
            };

            //build footer text
            StringBuilder sb = new StringBuilder();
            for (var i = 0; i < Math.Min(2, chartSeries.Count); i++)
            {
                var c = chartSeries[i];
                sb.Append($"<div>{c.Item2.ToString("0")}% of Mental Health STD Claims were {c.Item1}</div>");
            }

            var otherData = new
            {
                totalClaims,
                footerText = sb.ToString()
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new
            {
                results = chartOptions,
                otherData,
                imageUrl = chartImageUrl
            });
        }

        /// <summary>
        /// GetDataMedicalConditionAnalysis
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataMedicalConditionAnalysisTable")]
        public async Task<IHttpActionResult> GetMedicalConditionAnalysisTable(PdfModel model)
        {
            var sql = "select lic.InjuryCat_EN as MedicalCondition, Count(StdClaims.ClaimId) as CountOfClaims, " +
                 "SUM(DATEDIFF(day, AbsAuthFrom, COALESCE(AbsAuthTo, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)))) as DaysAbsent, " +
                 "SUM(CASE WHEN DateClosed BETWEEN @StartDate AND DATEADD(day, 1, @EndDate) AND ReasonClosed = 5 THEN 1 ELSE 0 END) LTDTransferStdClaims " +
                 "FROM" +
                 "(select ClientName, Claims.* FROM " +
                 "                dbo.GetClientDivisions(@clientId) client" +
                 "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                 "                AND claims.Archived = 0" +
                 "                WHERE Claims.Description = 'STD') as StdClaims " +
                 "INNER JOIN Claim_ICDCM icdcm on icdcm.ClaimID = StdClaims.ClientID " +
                 "INNER JOIN Claim_ICDCMCategory icdcmCat ON icdcmCat.ICDCMID = icdcm.ICDCMID AND icdcmCat.IsPrimary = 1 " +
                 "INNER JOIN List_InjuryCategories lic on lic.InjuryCatID = icdcmcat.CategoryID " +
                 "LEFT JOIN Claim_Absences ca on StdClaims.ClaimID = ca.ClaimID " +
                 "where StdClaims.DateClosed BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                 "GROUP BY lic.InjuryCat_EN";

            int year = model.toDate.Value.Year;
            var claimsByCondition = new List<IClaimsByCategory>();

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 1, (r, y) =>
            {
                while (r.Read())
                {
                    var stdClaimsByCondition = new StdClaimsByMedicalCondition()
                    {
                        MedicalCondition = GetStringDbValue(r["MedicalCondition"]),
                        ClaimsCount = GetIntegerDbValue(r["CountOfClaims"]),
                        DaysAbsent = GetIntegerDbValue(r["DaysAbsent"]),
                        LtdTransfers = GetIntegerDbValue(r["LTDTransferStdClaims"]),
                    };

                    if (stdClaimsByCondition.ClaimsCount > 0)
                        stdClaimsByCondition.AvgDuration = (stdClaimsByCondition.DaysAbsent / (float)stdClaimsByCondition.ClaimsCount);
                    claimsByCondition.Add(stdClaimsByCondition);
                }
            });

            claimsByCondition = GroupClaimCategories(claimsByCondition, MIN_REQUIRED_CLAIMS_BEFORE_AGGREGATION, 16, (otherItems) =>
            {

                var otherMedicalClaims = otherItems.Cast<StdClaimsByMedicalCondition>();

                var otherItem = new StdClaimsByMedicalCondition()
                {
                    MedicalCondition = "Other",
                    ClaimsCount = otherMedicalClaims.Sum(o => o.ClaimsCount),
                    DaysAbsent = otherMedicalClaims.Sum(o => o.DaysAbsent),
                    LtdTransfers = otherMedicalClaims.Sum(o => o.LtdTransfers)
                };
                if (otherItem.ClaimsCount > 0)
                    otherItem.AvgDuration = (otherItem.DaysAbsent / (float)otherItem.ClaimsCount);
                return otherItem;
            });

            //add a totals item
            var totalsItem = new StdClaimsByMedicalCondition()
            {
                MedicalCondition = "Totals",
                ClaimsCount = claimsByCondition.Sum(c => c.ClaimsCount),
                DaysAbsent = claimsByCondition.Sum(c => ((StdClaimsByMedicalCondition)c).DaysAbsent),
                LtdTransfers = claimsByCondition.Sum(c => ((StdClaimsByMedicalCondition)c).LtdTransfers),
                AvgDuration = claimsByCondition.Average(c => ((StdClaimsByMedicalCondition)c).AvgDuration)
            };
            claimsByCondition.Add(totalsItem);

            return Ok(new { Year = year, Data = claimsByCondition });
        }

        /// <summary>
        /// Get image url of pie chart by Closure Reason
        /// </summary>
        /// <param name="fromDate"></param>
        /// <param name="toDate"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByClosureReason")]
        public async Task<IHttpActionResult> GetDataForClaimsByClosureReason(PdfModel model)
        {
            var claimsByClosureReason = await GetClaimsByClosureReason(model);

            int year = model.toDate.Value.Year;

            int totalClaims = claimsByClosureReason.Sum(c => c.ClaimsCount);

            //calculate percentages
            ChartSeries<string, float> chartSeries = new ChartSeries<string, float>();

            foreach (var claimCount in claimsByClosureReason)
            {
                chartSeries.Add(new Tuple<string, float>(claimCount.Category,
                    totalClaims > 0 ? (claimCount.ClaimsCount / (float)totalClaims) * 100.0f : 0
                    ));
            }

            var chartOptions = new
            {
                chart = new
                {
                    type = "pie",
                    options3d = new
                    {
                        enabled = true,
                        alpha = 60,
                        beta = 0
                    },
                    height = "55%"
                },
                title = new
                {
                    text = $"STD Claims {year} – Closure Reason"
                },
                plotOptions = new
                {
                    pie = new
                    {
                        allowPointSelect = true,
                        cursor = "pointer",
                        depth = 60,
                        dataLabels = new
                        {
                            enabled = true,
                            style = new
                            {
                                textOutline = false
                            }
                        },
                        //showInLegend = true,
                        colors = GetPieChartColors()
                    }
                },
                //legend = new
                //{
                //    align = "right",
                //    verticalAlign = "middle",
                //    layout = "vertical",
                //    x = -50,
                //    y = 0,
                //    itemMarginTop = 15,
                //    itemMarginBottom = 15,
                //    symbolRadius = 0
                //},
                series = new[]{
                        new
                        {
                            name= "",
                            data = chartSeries.Select(t =>
                            new
                            {
                                name = $"{t.Item1} ({t.Item2.ToString("0")}%)",
                                y = t.Item2
                            })
                        }
                     },
            };

            //build footer text
            StringBuilder sb = new StringBuilder();
            for (var i = 0; i < Math.Min(1, chartSeries.Count); i++)
            {
                var c = chartSeries[i];
                sb.Append($"<div>{c.Item2.ToString("0")}% of claims closed were due to {c.Item1}</div>");
            }

            var otherData = new
            {
                totalClaims,
                footerText = sb.ToString()
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new
            {
                results = chartOptions,
                otherData,
                imageUrl = chartImageUrl
            });
        }

        /// <summary>
        /// GetDataForClaimsByClosureReasonYearOverYear
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByClosureReasonYearOverYear")]
        public async Task<IHttpActionResult> GetDataForClaimsByClosureReasonYearOverYear(PdfModel model)
        {

            Dictionary<int, List<IClaimsByCategory>> closureReasonsDict = new Dictionary<int, List<IClaimsByCategory>>();
            Dictionary<int, int> totalsForYears = new Dictionary<int, int>();

            int yearsDelta = 3;
            while (yearsDelta > -1)
            {
                int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                //get medical conditions for the year
                var yearModel = new PdfModel()
                {
                    clientId = model.clientId,
                    fromDate = model.fromDate.Value.AddYears(-yearsDelta),
                    toDate = model.toDate.Value.AddYears(-yearsDelta)
                };

                var claimsByClosureReason = await GetClaimsByClosureReason(yearModel);
                closureReasonsDict.Add(year, claimsByClosureReason);

                totalsForYears.Add(year, claimsByClosureReason.Sum(t => t.ClaimsCount));

                yearsDelta--;
            }

            //get distinct conditions
            var distinctClosureReasons = closureReasonsDict.Values.SelectMany(t => t.Select(t2 => t2.Category)).Distinct();

            //generate final vm
            List<StdClaimsByCategoryAndYearViewModel> closureReasonClaims = new List<StdClaimsByCategoryAndYearViewModel>();

            foreach (var closureReason in distinctClosureReasons)
            {
                var stdClaimsByCondition = new StdClaimsByCategoryAndYearViewModel()
                {
                    Category = closureReason,
                    ClaimsByYear = new List<ClaimsPercentByYear>()
                };

                yearsDelta = 3;
                while (yearsDelta > -1)
                {
                    int year = model.toDate.Value.AddYears(-yearsDelta).Year;

                    //get count for condition for that year
                    int claimCount = (closureReasonsDict[year].FirstOrDefault(t => t.Category == closureReason)?.ClaimsCount).GetValueOrDefault();
                    int totalForYear = totalsForYears[year];

                    var claimPercentByYear = new ClaimsPercentByYear()
                    {
                        Year = year,
                        Percent = totalForYear > 0 ? (claimCount / (float)totalForYear) * 100.0f : 0
                    };
                    stdClaimsByCondition.ClaimsByYear.Add(claimPercentByYear);

                    yearsDelta--;
                }

                closureReasonClaims.Add(stdClaimsByCondition);

            }

            return Ok(new
                {
                    years = totalsForYears.Keys.ToArray(),
                    data = closureReasonClaims
                });
        }

        /// <summary>
        /// Get data of bar chart for claims by lag refrral time
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByLagReferralTime")]
        public async Task<IHttpActionResult> GetDataForClaimsByLagReferralTime(PdfModel model)
        {
            var sql = "SELECT SUM(CASE WHEN LagToRef <= 5 THEN 1 ELSE 0 END) Count0To5Days," +
                "SUM(CASE WHEN LagToRef > 5 AND LagToRef <= 10 THEN 1 ELSE 0 END) Count6To10Days," +
                "SUM(CASE WHEN LagToRef > 10 AND LagToRef <= 15 THEN 1 ELSE 0 END) Count11To15Days," +
                "SUM(CASE WHEN LagToRef > 15 AND LagToRef <= 20 THEN 1 ELSE 0 END) Count16To20Days," +
                "SUM(CASE WHEN LagToRef > 20 AND LagToRef <= 25 THEN 1 ELSE 0 END) Count21To25Days," +
                "SUM(CASE WHEN LagToRef > 26 AND LagToRef <= 30 THEN 1 ELSE 0 END) Count26To30Days," +
                "SUM(CASE WHEN LagToRef > 30 THEN 1 ELSE 0 END) CountOver30Days," +
                "Count(1) as TotalClaims " +
                "FROM (select ClientID, clientname,DateDiff(DAY, IncidentDate, DateCreation) as LagToRef " +
                "FROM (select ClientName, Claims.* " +
                "FROM " +
                "                dbo.GetClientDivisions(@clientId) client" +
                "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                "                AND claims.Archived = 0" +
                "                WHERE Claims.Description = 'STD') as StdClaims " +
                "WHERE " +
                "StdClaims.DateCreation BETWEEN @startDate AND DATEADD(day, 1, @endDate)) as ClaimsLagTime";

            var lagCategoriesDataTable = new Dictionary<string, List<Tuple<int, int>>>();
            var totalsForYears = new Dictionary<int, int>();

            var lagTimeCategories = GetLagTimeCategories();
            //add all categories
            foreach (var category in lagTimeCategories)
                lagCategoriesDataTable.Add(category, new List<Tuple<int, int>>());

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                //there will be only one row / year
                int total = 0;
                if (r.Read())
                {
                    total = GetIntegerDbValue(r["TotalClaims"]);
                    //field order is the same as the category order
                    for (int i = 0; i < lagTimeCategories.Length; i++)
                    {
                        int countForCategory = GetIntegerDbValue(r[i]);
                        lagCategoriesDataTable[lagTimeCategories[i]].Add(new Tuple<int, int>(year, countForCategory));
                    }
                }

                totalsForYears.Add(year, total);
            });

            //determine percentages
            var chartSeriesCollection = new ChartSeriesCollection<string, float>();

            int yearsDelta = 3;
            while (yearsDelta > -1)
            {
                var chartSeries = new ChartSeries<string, float>();
                int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                chartSeries.Name = year.ToString();

                foreach (var category in lagTimeCategories)
                {
                    //get count for lag category
                    int claimsForLagCategory = (lagCategoriesDataTable[category].FirstOrDefault(t => t.Item1 == year)?.Item2).GetValueOrDefault();
                    int totalForYear = totalsForYears[year];

                    float percentage = totalForYear > 0 ? (claimsForLagCategory / (float)totalForYear) * 100.0f : 0;
                    chartSeries.Add(new Tuple<string, float>(category, percentage));
                }

                chartSeriesCollection.Add(chartSeries);
                yearsDelta--;
            }

            var chartOptions = new
            {
                chart = new
                {
                    type = "column",
                    height = "45%"
                },
                title = new
                {
                    text = "New STD Claims – Lag Time to Referral (Days)"
                },
                xAxis = new
                {
                    categories = lagTimeCategories
                },
                yAxis = new
                {
                    min = 0,
                    title = new
                    {
                        text = "Claims Referred"
                    }
                },
                plotOptions = new
                {
                    series = new
                    {
                        pointPadding = 0,
                        groupPadding = 0.2,
                        border = 0
                    }
                },
                legend = new
                {
                    enabled = false
                },
                colors = GetBarChartColors(4),
                series = chartSeriesCollection.Series.Select(s =>
                    new
                    {
                        name = s.Name,
                        data = s.Select(sd => sd.Item2)
                    })
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new { results = chartOptions, imageUrl = chartImageUrl });
        }

        /// <summary>
        /// Get data of bar chart for claims by lag aps time
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByLagApsTime")]
        public async Task<IHttpActionResult> GetDataForClaimsByLagApsTime(PdfModel model)
        {

            var sql = "SELECT SUM(CASE WHEN LagToAPS <= 5 THEN 1 ELSE 0 END) Count0To5Days," +
                "SUM(CASE WHEN LagToAPS > 5 AND LagToAPS <= 10 THEN 1 ELSE 0 END) Count6To10Days," +
                "SUM(CASE WHEN LagToAPS > 10 AND LagToAPS <= 15 THEN 1 ELSE 0 END) Count11To15Days," +
                "SUM(CASE WHEN LagToAPS > 15 AND LagToAPS <= 20 THEN 1 ELSE 0 END) Count16To20Days," +
                "SUM(CASE WHEN LagToAPS > 20 AND LagToAPS <= 25 THEN 1 ELSE 0 END) Count21To25Days," +
                "SUM(CASE WHEN LagToAPS > 26 AND LagToAPS <= 30 THEN 1 ELSE 0 END) Count26To30Days," +
                "SUM(CASE WHEN LagToAPS > 30 THEN 1 ELSE 0 END) CountOver30Days," +
                "Count(1) as TotalClaims " +
                "FROM " +
                "(select ClientId, clientname, DateDiff(DAY, DateCreation, (SELECT TOP 1 UpdatesDate From Claim_Updates WHERE ClaimRefNu = ClaimRefNu AND ActionType = 'APS')) as LagToAPS " +
                "FROM (select ClientName, Claims.* FROM" +
                "                dbo.GetClientDivisions(@clientId) client" +
                "                INNER JOIN Claims on claims.ClientID = client.ClientID" +
                "                AND claims.Archived = 0" +
                "                WHERE Claims.Description = 'STD') as StdClaims " +
                "WHERE " +
                "StdClaims.DateCreation BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                "AND (SELECT COUNT(1) FROM Claim_Updates cu WHERE cu.ClaimRefNu = StdClaims.ClaimRefNu and cu.ActionType = 'APS') > 0) as ClaimsLagTime";


            var lagCategoriesDataTable = new Dictionary<string, List<Tuple<int, int>>>();
            var totalsForYears = new Dictionary<int, int>();

            var lagTimeCategories = GetLagTimeCategories();
            //add all categories
            foreach (var category in lagTimeCategories)
                lagCategoriesDataTable.Add(category, new List<Tuple<int, int>>());

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;
            await ExecuteSqlQueryHelper(qp, 4, (r, year) =>
            {
                //there will be only one row / year
                int total = 0;
                if (r.Read())
                {
                    total = GetIntegerDbValue(r["TotalClaims"]);
                    //field order is the same as the category order
                    for (int i = 0; i < lagTimeCategories.Length; i++)
                    {
                        int countForCategory = GetIntegerDbValue(r[i]);
                        lagCategoriesDataTable[lagTimeCategories[i]].Add(new Tuple<int, int>(year, countForCategory));
                    }
                }

                totalsForYears.Add(year, total);
            });

            //determine percentages
            var chartSeriesCollection = new ChartSeriesCollection<string, float>();

            int yearsDelta = 3;
            while (yearsDelta > -1)
            {
                var chartSeries = new ChartSeries<string, float>();
                int year = model.toDate.Value.AddYears(-yearsDelta).Year;
                chartSeries.Name = year.ToString();

                foreach (var category in lagTimeCategories)
                {
                    //get count for lag category
                    int claimsForLagCategory = (lagCategoriesDataTable[category].FirstOrDefault(t => t.Item1 == year)?.Item2).GetValueOrDefault();
                    int totalForYear = totalsForYears[year];

                    float percentage = totalForYear > 0 ? (claimsForLagCategory / (float)totalForYear) * 100.0f : 0;
                    chartSeries.Add(new Tuple<string, float>(category, percentage));
                }

                chartSeriesCollection.Add(chartSeries);
                yearsDelta--;
            }

            var chartOptions = new
            {
                chart = new
                {
                    type = "column",
                    height = "45%"
                },
                title = new
                {
                    text = "New STD Claims – Lag Time to APS (Days)"
                },
                xAxis = new
                {
                    categories = lagTimeCategories
                },
                yAxis = new
                {
                    min = 0,
                    title = new
                    {
                        text = "Claims Referred"
                    }
                },
                plotOptions = new
                {
                    series = new
                    {
                        pointPadding = 0,
                        groupPadding = 0.2,
                        border = 0
                    }
                },
                legend = new
                {
                    enabled = false
                },
                colors = GetBarChartColors(4),
                series = chartSeriesCollection.Series.Select(s =>
                    new
                    {
                        name = s.Name,
                        data = s.Select(sd => sd.Item2)
                    })
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new { results = chartOptions, imageUrl = chartImageUrl });
        }

        /// <summary>
        /// Get data of bar chart for claims by lag aps time
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [Route("GetDataForClaimsByTdoVsDdg")]
        public async Task<IHttpActionResult> GetDataForClaimsByTdoVsDdg(PdfModel model)
        {

            var sql = "select Top 50 " +
                "StdClaims.ClaimId, " +
                "(DATEDIFF(day, AbsAuthFrom, COALESCE(AbsAuthTo, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0)))) as DaysAbsent, " +
                "DDGAvg FROM " +
                "(select ClientName, Claims.* FROM dbo.GetClientDivisions(@clientId) client INNER JOIN Claims on claims.ClientID = client.ClientID AND claims.Archived = 0 WHERE Claims.Description = 'STD') as StdClaims " +
                "INNER JOIN Claim_Absences ca ON StdClaims.ClaimID = ca.ClaimID " +
                "INNER JOIN Claim_ICDCM icdcm on icdcm.ClaimID = StdClaims.ClientID " +
                "INNER JOIN Claim_ICDCMCategory icdcmCat ON icdcmCat.ICDCMID = icdcm.ICDCMID AND icdcmCat.IsPrimary = 1 " +
                "WHERE StdClaims.DateClosed BETWEEN @startDate AND DATEADD(day, 1, @endDate) " +
                "Order by (DATEDIFF(day, AbsAuthFrom, COALESCE(AbsAuthTo, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0))))";

            var qp = QueryParameters.FromApiParameters(model, "");
            qp.query = sql;

            ChartSeries<string, int> ddgSeries = new ChartSeries<string, int>();
            ChartSeries<string, int> tdoSeries = new ChartSeries<string, int>();
            tdoSeries.Name = "TDO";
            ddgSeries.Name = "DDG";

            int year = 0;
            await ExecuteSqlQueryHelper(qp, 1, (r, y) =>
            {
                year = y;
                while (r.Read())
                {
                    int tdo = GetIntegerDbValue(r["DaysAbsent"]);

                    string strDDG = GetStringDbValue(r["DDGAvg"]).Trim();
                    int ddg = 0;
                    int.TryParse(strDDG, out ddg);

                    tdoSeries.Add(new Tuple<string, int>(string.Empty, tdo));
                    ddgSeries.Add(new Tuple<string, int>(string.Empty, ddg));
                }

            });

            var colors = new string[]
            {
                GetBarChartColors(4)[3],
                "#C0504D"
            };

            var chartOptions = new
            {
                chart = new
                {                    
                    height = "56%"
                },
                title = new
                {
                    text = $"Closed STD Claims {year} – TDO vs DDG"
                },
                xAxis = new
                {
                    categories = tdoSeries.Select(s => s.Item1).ToArray(), //empty strings
                    title = new
                    {
                        text = "Claims"
                    }
                },
                yAxis = new
                {
                    min = 0,
                    title = new
                    {
                        text = "Calendar Days"
                    }
                },
                plotOptions = new
                {
                    line = new
                    {
                        marker = new 
                        {
                            enabled = false
                        },
                        lineWidth = 2                        
                    }
                },
                //legend = new
                //{
                //    enabled = false
                //},                
                series = new[]
                {
                    new {
                        name = tdoSeries.Name,
                        type = "column",
                        color = colors[0],
                        data = tdoSeries.Select(s => s.Item2)
                    },
                    new {
                        name = ddgSeries.Name,
                        type = "line",
                        color = colors[1],
                        data = ddgSeries.Select(s => s.Item2)
                    },
                }
            };
            string chartImageUrl = "";
            if (model.generatePdf)
                chartImageUrl = await GenerateChartImage(JsonConvert.SerializeObject(chartOptions));
            return Ok(new { results = chartOptions, imageUrl = chartImageUrl });
        }
        #endregion

        #region save form state
        /// <summary>
        ///  save form element state
        /// </summary>
        /// <param name="pdfModel"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("SaveFormStateBasedOnControlId")]
        public bool SaveFormStateBasedOnControlId(FormViewModel formViewModel)
        {
            try
            {
                string query;
                bool isExist;
                //in case user try to delete the static slide without adding child slides then first need
                //to insert the static slide data in table
                if (formViewModel.controlId == "")
                {
                    isExist = context.FormStates.Any(fs => fs.ParentId == formViewModel.parentId && fs.UserId == formViewModel.userId && !fs.IsDeleted.GetValueOrDefault());

                    //query = "select Count(*) from FormState where ([ParentId] = @ParentId and UserId = @UserId) and IsDeleted = 0";
                    ////first check whether data is already exist for id or not for textBox
                    //SqlCommand checkDataExistence = new SqlCommand(query, OrgsysdbConn);
                    //checkDataExistence.CommandType = CommandType.Text;
                    //checkDataExistence.Parameters.AddWithValue("@ParentId", formViewModel.parentId);
                    //checkDataExistence.Parameters.AddWithValue("@UserId", formViewModel.userId);
                    //OrgsysdbConn.Open();
                    //isExist = (int)checkDataExistence.ExecuteScalar();
                    //OrgsysdbConn.Close();
                }
                else
                {
                    isExist = context.FormStates.Any(fs => fs.ControlId == formViewModel.controlId && fs.UserId == formViewModel.userId && !fs.IsDeleted.GetValueOrDefault());
                    //query = "select Count(*) from FormState where ([ControlId] = @ControlId and UserId=@UserId) and IsDeleted=0";
                    ////first check whether data is already exist for id or not for textBox
                    //SqlCommand checkDataExistence = new SqlCommand(query, OrgsysdbConn);
                    //checkDataExistence.CommandType = CommandType.Text;
                    //checkDataExistence.Parameters.AddWithValue("@ControlId", formViewModel.controlId);
                    //checkDataExistence.Parameters.AddWithValue("@UserId", formViewModel.userId);
                    //OrgsysdbConn.Open();
                    //isExist = (int)checkDataExistence.ExecuteScalar();
                    //OrgsysdbConn.Close();
                }
                if (isExist)
                {
                    foreach (var fs in context.FormStates.Where(fs => fs.ControlId == formViewModel.controlId && fs.UserId == formViewModel.userId))
                    {
                        fs.ControlValue = formViewModel.controlValue;
                        fs.ModefiedOn = DateTime.Now;
                    }
                    context.SubmitChanges();

                    //string updateQuery = "update FormState set ControlValue=@ControlValue,ModefiedOn=@ModefiedOn where ControlId=@ControlId";
                    //using (SqlCommand command = new SqlCommand(updateQuery, OrgsysdbConn))
                    //{
                    //    command.CommandType = CommandType.Text;
                    //    command.Parameters.AddWithValue("@ControlValue", formViewModel.controlValue);
                    //    command.Parameters.AddWithValue("@ModefiedOn", DateTime.Now);
                    //    command.Parameters.AddWithValue("@ControlId", formViewModel.controlId);
                    //    OrgsysdbConn.Open();
                    //    if (command.ExecuteNonQuery() > 0)
                    //    {
                    //        OrgsysdbConn.Close();
                    //        return true;
                    //    }
                    //}
                }
                else
                {
                    if (formViewModel.controlValue == null)
                        formViewModel.controlValue = "";

                    FormState fs = new FormState()
                    {
                        ControlType = formViewModel.controlType,
                        ControlId = formViewModel.controlId,
                        ControlValue = formViewModel.controlValue,
                        UserId = formViewModel.userId,
                        IsDeleted = false,
                        IsParent = false,
                        CreatedOn = DateTime.Now
                    };
                    if (!String.IsNullOrEmpty(formViewModel.parentId))
                    {
                        fs.ParentId = formViewModel.parentId;
                    }

                    context.FormStates.InsertOnSubmit(fs);
                    context.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                return false;
            }
            return false;
        }
        /// <summary>
        /// Soft delete the child and parent slide by their respective id's
        /// </summary>
        /// <param name="formViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("DeleteSlideById")]
        public bool DeleteSlideById(FormViewModel formViewModel)
        {
            try
            {

                if (!String.IsNullOrEmpty(formViewModel.parentId))
                {
                    formViewModel.controlType = "Slide";
                    formViewModel.controlId = "";

                    //first check that parentId is exist(in case of deleting static slide without creating child
                    SaveFormStateBasedOnControlId(formViewModel);

                    var formState = context.FormStates.FirstOrDefault(fs => fs.ParentId == formViewModel.parentId && fs.UserId == formViewModel.userId && !fs.IsDeleted.GetValueOrDefault());
                    if (formState != null)
                        formState.IsParent = true;

                }
                else
                {
                    var formState = context.FormStates.FirstOrDefault(fs => fs.ControlId == formViewModel.controlId && fs.UserId == formViewModel.userId);
                    formState.IsDeleted = true;
                }
                context.SubmitChanges();

                //string query = "update FormState set IsDeleted=1 where [ControlId]=@SlideId and UserId=@UserId";
                //if (!String.IsNullOrEmpty(formViewModel.parentId))
                //{
                //    formViewModel.controlType = "Slide";
                //    formViewModel.controlId = "";
                //    //first check that parentId is exist(in case of deleting static slide without creating child
                //    SaveFormStateBasedOnControlId(formViewModel);

                //    query = "update FormState set IsParent=1 where (ParentId=@ParentId and UserId=@UserId) and IsDeleted=0";

                //}
                //using (SqlCommand command = new SqlCommand(query, OrgsysdbConn))
                //{
                //    command.CommandType = CommandType.Text;
                //    command.Parameters.AddWithValue("@UserId", formViewModel.userId);
                //    if (!String.IsNullOrEmpty(formViewModel.parentId))
                //    {
                //        command.Parameters.AddWithValue("@ParentId", formViewModel.parentId);
                //    }
                //    else
                //    {
                //        command.Parameters.AddWithValue("@SlideId", formViewModel.controlId);
                //    }
                //    OrgsysdbConn.Open();
                //    if (command.ExecuteNonQuery() > 0)
                //    {
                //        OrgsysdbConn.Close();
                //        return true;
                //    }
                //}
            }
            catch (Exception ex)
            {
                return false;
            }
            return false;
        }
        /// <summary>
        /// fetch all the form element status based on userId
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("GetFormElementState")]
        public IHttpActionResult GetFormElementState(int userId)
        {
            List<FormViewModel> formViewModels = new List<FormViewModel>();
            var formStates = context.FormStates.Where(f => f.UserId == userId && !f.IsDeleted.GetValueOrDefault()).OrderByDescending(f => f.CreatedOn);
            foreach (var formState in formStates)
            {
                FormViewModel formViewModel = new FormViewModel();
                formViewModel.controlId = formState.ControlId;
                formViewModel.controlType = formState.ControlType;
                formViewModel.controlValue = formState.ControlValue;
                formViewModel.parentId = formState.ParentId;
                formViewModel.isParentRemoved = formState.IsParent.GetValueOrDefault();
                formViewModels.Add(formViewModel);
            }

            var deletedStaticSlide = formViewModels.Where(x => x.isParentRemoved).Select(x => x.parentId).ToArray();
            return Ok(new { results = JsonConvert.SerializeObject(formViewModels), deletedStaticSlideId = deletedStaticSlide });
        }
        #endregion
    }
}

