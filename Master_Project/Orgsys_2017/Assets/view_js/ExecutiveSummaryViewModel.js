var ExecutiveSummaryViewModel = new function () {

    var thisViewModel = this;

    //this.bindBarChart = function (options) {

    //    Highcharts.chart(options.chartId, options.data.results);
    //};

    function bindChart(chartId, data) {

        var target = $('#' + chartId);
        if (target.length) {
            Highcharts.chart(chartId, data.results);
            //append the image URL with charts
            target.siblings("img").attr("src", data.imageUrl);
        }
    }

    function generateTableUsingChartData (data, tableSelector, dataType) {
        //populate table column headers
        var tableHeaderRow = "<tr><th class='bg-primary text-white text-center'></th>";

        data.results.xAxis.categories.forEach(function (year) {
            tableHeaderRow += ("<th class='bg-primary text-white text-center'>" + year + '</th>');
        });

        tableHeaderRow += '</tr>';

        $(tableSelector + ' thead').html(tableHeaderRow);

        //populate table rows
        var tableBody = $(tableSelector + ' tbody');
        tableBody.html(""); //Empty existing body

        //For each gender
        var i = 0;
        var colors = data.results.colors;
        data.results.series.forEach(function (yearData) {
            var tableRow = "<tr><td class='text-left'><div class='color-box' style='display:inline-block;background-color:" + colors[i] + "'></div>" + yearData.name + "</td>";

            switch (dataType) {
                case 'percentage':
                    yearData.data.forEach(function (monthValue) {
                        tableRow += ("<td>" + monthValue.toFixed(1) + "%</td>");
                    });
                    break;

                case 'integer':
                    yearData.data.forEach(function (monthValue) {
                        tableRow += ("<td>" + monthValue.toFixed(0) + "</td>");
                    });
                    break;

                default:
                    yearData.data.forEach(function (monthValue) {
                        tableRow += ("<td>" + monthValue + "</td>");
                    });
            }

            tableRow += "</tr>";

            tableBody.append(tableRow);

            i++;
        });
    }

    this.bindExecutiveSummarySlide = function (data) {

        //console.log('I Received the data for the Executive Summary Slide!');
        //console.log(data);

        for (i = 0; i < 4; i++) {

            //header
            $('#pg7-col' + i + '-head').html(data.StatsByYear[i].Year);

            //body
            $('#pg7-r1-c' + i).html(data.StatsByYear[i].CountNewClaims);
            $('#pg7-r2-c' + i).html(data.StatsByYear[i].CountCancelledClaims);
            $('#pg7-r3-c' + i).html(data.StatsByYear[i].ClaimsIncidentRate.toFixed(1) + '%');
            $('#pg7-r4-c' + i).html(data.StatsByYear[i].CountNonSupportedStdClaims);
            $('#pg7-r5-c' + i).html(data.StatsByYear[i].CountClosedClaims);
            $('#pg7-r6-c' + i).html(data.StatsByYear[i].CountClaimsTransferredToLtd);
            $('#pg7-r7-c' + i).html(data.StatsByYear[i].PercentLtdTransferOnClosed.toFixed(1) + '%');
            $('#pg7-r8-c' + i).html(data.StatsByYear[i].TotalDaysLost);
            $('#pg7-r9-c' + i).html(data.StatsByYear[i].AvgDurationDaysLostExcludingLtdTransfers.toFixed(1));
            $('#pg7-r10-c' + i).html(data.StatsByYear[i].AvgDurationDaysLostIncludingLtdTransfers.toFixed(1));
            $('#pg7-r11-c' + i).html(data.StatsByYear[i].DaysSaved);

            //footer
            $('#pg7-y' + i).html(data.Years[i]);
            $('#pg7-emp-y' + i).html(data.Employees[i]);
        }

    };

    this.bindBenchmarksSlide = function (data) {

        //header
        $('#pg8-c0-head').html("(" + data[0].Year + " OSI BENCHMARKING)");
        $('#pg8-c1-head').html(data[1].Year);

        for (var i = 0; i < 2; i++) {
            $('#pg8-r0-c' + i).html(data[i].PercentIncidentRate);
            $('#pg8-r1-c' + i).html(data[i].AvgDuration);
            $('#pg8-r2-c' + i).html(data[i].PercentReturnToWork);
            $('#pg8-r3-c' + i).html(data[i].PercentStdTransferredToLtd);
            $('#pg8-r4-c' + i).html(data[i].PercentDecisionTurnaroundFollowingAps);

            var highestClaimHtml = '';
            data[i].HighestClaimCategories.forEach(function (c) {

                highestClaimHtml += '<div>' + c.Category + '</div>' + '<div><small class="font-weight-bold">' + c.Percentage + '</small></div>';               

            });

            $('#pg8-r5-c' + i).html(highestClaimHtml);
        }

    };

    this.bindClaimsByMonth = function (data) {

        bindChart("claimsByMonth", data);
        generateTableUsingChartData(data, '#newStdReferralsTable');

    };

    this.bindClaimsBySite = function (data) {

        $('#pg10-c1-head').html(data.columnHeaders.ClaimsY1);
        $('#pg10-c2-head').html(data.columnHeaders.ClaimsY2);
        $('#pg10-c3-head').html(data.columnHeaders.StdReferralY1);
        $('#pg10-c4-head').html(data.columnHeaders.StdReferralY2);
        $('#pg10-c5-head').html(data.columnHeaders.TotalEmployees);
        $('#pg10-c6-head').html(data.columnHeaders.StdReferralsIncidentRate);

        var table = $('#claimsBySite tbody');

        data.data.forEach(function (d) {
            var newRowContent = "<tr><td>" + d.Site + "</td>" +
                "<td>" + d.TotalClaimsY1 + "</td>" +
                "<td>" + d.TotalClaimsY2 + "</td>" +
                "<td>" + d.StdReferralPercentY1.toFixed(1) + "%</td>" +
                "<td>" + d.StdReferralPercentY2.toFixed(1) + "%</td>" +
                "<td>" + d.TotalEmployees + "</td>" +
                "<td>" + d.StdReferralsIncidentRate.toFixed(1) + "%</td>" +
                "<tr>";
            table.append(newRowContent);
        });
    };

    this.bindClaimsByProvince = function (data) {

        for (var i = 0; i < 4; i++) {
            $('#pg11-c' + i + '-head').html(data.years[i]);
        }


        var table = $('#claimsByProvince tbody');

        data.data.forEach(function (d) {

            var newRowContent = "<tr><td>" + d.Category + "</td>";

            for (var i = 0; i < 4; i++) {
                 newRowContent += "<td>" + d.ClaimsByYear[i].Percent.toFixed(1) + "%</td>";
                
            }
            newRowContent += "<tr>";
            table.append(newRowContent);
        });
    };    

    this.bindClaimsByGenderAndAge = function (data) {

        bindChart("claimsByGenderAndAge", data);
        generateTableUsingChartData(data, '#newStdClaimsByGenderAndAgeTable');
    };

    this.bindClaimsByGenderYearOverYear = function (data) {
        console.log("bindClaimsByGenderYearOverYear");

        //populate column headers
        var tableHeaderRow = "<tr><th class='bg-primary text-white text-center'>Gender</th>";

        data.years.forEach(function (year) {
            tableHeaderRow += ("<th class='bg-primary text-white text-center'>" + year + '</th>');
        });

        tableHeaderRow += '</tr>';

        $('#newClaimsByGenderAndYearTable thead').html(tableHeaderRow);

        //populate rows
        var tableBody = $('#newClaimsByGenderAndYearTable tbody');
        tableBody.html(""); //Empty existing body

        //For each gender
        data.data.forEach(function (genderObject) {
            var tableRow = "<tr><td>" + genderObject.Category + "</td>";

            genderObject.ClaimsByYear.forEach(function (yearData) {
                tableRow += ("<td>" + yearData.Percent.toFixed(1) + "%</td>");
            });

            tableRow += "</tr>";

            tableBody.append(tableRow);
        });
    };

    this.bindClaimsByClosureReasonsYearOverYear = function (data) {
        console.log("bindClaimsByClosureReasonsYearOverYear");

        //populate column headers
        var tableHeaderRow = "<tr><th class='bg-primary text-white text-center'>Reason For Closure</th>";

        data.years.forEach(function (year) {
            tableHeaderRow += ("<th class='bg-primary text-white text-center'>" + year + '</th>');
        });

        tableHeaderRow += '</tr>';

        $('#claimsByClosureReasonYearOverYearTable thead').html(tableHeaderRow);

        //populate rows
        var tableBody = $('#claimsByClosureReasonYearOverYearTable tbody');
        tableBody.html(""); //Empty existing body

        //For each closure reason
        data.data.forEach(function (dataItem) {
            var tableRow = "<tr><td>" + dataItem.Category + "</td>";

            dataItem.ClaimsByYear.forEach(function (yearData) {
                tableRow += ("<td>" + yearData.Percent.toFixed(1) + "%</td>");
            });

            tableRow += "</tr>";

            tableBody.append(tableRow);
        });
    };

    this.bindMedicalConditionsAnalysis = function (data) {
        console.log("bindMedicalConditionsAnalysis");

        //populate rows
        var tableBody = $('#medicalConditionsAnalysisTable tbody');

        tableBody.html(""); //Clear existing data

        data.Data.forEach(function (rowData) {
            var tableRow = "<tr><td>" + rowData.MedicalCondition + "</td>";
            tableRow += ("<td>" + rowData.ClaimsCount + "</td>");
            tableRow += ("<td>" + rowData.DaysAbsent + "</td>");
            tableRow += ("<td>" + rowData.AvgDuration + "</td>");
            tableRow += ("<td>" + rowData.LtdTransfers + "</td></tr>");
            tableBody.append(tableRow);
        });
    };

    this.bindClaimsByAgeYearOverYear = function (data) {
        console.log("bindClaimsByAgeYearOverYear");

        //populate column headers
        var tableHeaderRow = "<tr><th class='bg-primary text-white text-center'>Age Group</th>";

        data.years.forEach(function (year) {
            tableHeaderRow += ("<th class='bg-primary text-white text-center'>" + year + '</th>')
        });

        tableHeaderRow += '</tr>';

        $('#newClaimsByAgeGroupAndYearTable thead').html(tableHeaderRow);

        //populate rows
        var tableBody = $('#newClaimsByAgeGroupAndYearTable tbody');

        tableBody.html(""); //Clear existing body

        //For each age group
        data.data.forEach(function (ageGroupObject) {
            var tableRow = "<tr><td>" + ageGroupObject.Category + "</td>";

            ageGroupObject.ClaimsByYear.forEach(function (yearData) {
                tableRow += ("<td>" + yearData.Percent.toFixed(1) + "%</td>");
            });

            tableBody.append(tableRow);
        });

        //Append Total Claims for each column
        var totalClaimsRow = "<tr><td>Total Claims</td>";
        data.totals.forEach(function (x) {
            totalClaimsRow += ("<td>" + x + "</td>");
        });
        totalClaimsRow += "</tr>";

        tableBody.append(totalClaimsRow);
    };

    this.bindClaimsBySeniority = function (data) {
        console.log("bindClaimsBySeniority");

        //console.log(data);
        bindChart("claimsBySeniority", data);
        //build table under
        generateTableUsingChartData(data, '#stdClaimsBySeniorityTable');
    };

    this.bindClaimsByMedicalCondition = function (data) {
        console.log("bindClaimsByMedicalCondition");
        bindChart("claimsByMedicalCondition", data);

        var footer = $('#newMedicalClaimsDescription div');
        if (footer.length) {
            var footerHtml = '<div>On <strong>' + data.otherData.totalClaims + '</strong> claims with Medical</div>';
            footerHtml += data.otherData.footerText;
            footer.html(footerHtml);
        }

    };

    this.bindClaimsByMedicalConditionYearOverYear = function (data) {
        console.log("bindClaimsByMedicalConditionYearOverYear");
        //populate column headers
        var tableHeaderRow = "<tr><th class='bg-primary text-white text-center'></th>";

        data.years.forEach(function (year) {
            tableHeaderRow += ("<th class='bg-primary text-white text-center'>" + year + '</th>');
        });

        tableHeaderRow += '</tr>';

        $('#claimsByMedicalConditionYearOverYearTable thead').html(tableHeaderRow);

        //populate rows
        var tableBody = $('#claimsByMedicalConditionYearOverYearTable tbody');

        tableBody.html("");

        //For each gender
        data.data.forEach(function (dataItem) {
            var tableRow = "<tr><td>" + dataItem.Category + "</td>";

            dataItem.ClaimsByYear.forEach(function (yearData) {
                tableRow += ("<td>" + yearData.Percent.toFixed(1) + "%</td>");
            });

            tableBody.append(tableRow);
        });
    };
    
    this.bindClaimsByDiagnosisForMentalHealth = function (data) {
        console.log("bindClaimsByDiagnosisForMentalHealth");
        bindChart("mentalClaimsByDiagnosis", data);

        var footer = $('#mentalHealthClaimsDescription div');
        if (footer.length) {
            var footerHtml = data.otherData.footerText;
            footer.html(footerHtml);
        }
    };

    this.bindClaimsByDiagnosisForMusucloskeletal = function (data) {
        console.log("bindClaimsByDiagnosisForMusucloskeletal");

        bindChart("musculoskeletalClaimsByDiagnosis", data);

        var footer = $('#musculoskeletalStdClaimsDescription div');
        if (footer.length) {
            var footerHtml = data.otherData.footerText;
            footer.html(footerHtml);
        }
    };

    this.bindClaimsByClosureReason = function (data) {

        bindChart("claimsByClosureResearch", data);

        var footer = $('#closureReasonClaimsDescription div');
        if (footer.length) {
            var footerHtml = data.otherData.footerText;
            footer.html(footerHtml);
        }
    };
    
    this.bindClaimsLagTimeToReferral = function (data) {

        bindChart("claimsLagToReferralTimeChart", data);
        
        generateTableUsingChartData(data, '#stdClaimsLagTimeToReferralTable', 'percentage');

    };

    this.bindClaimsLagTimeToAps = function (data) {

        bindChart("claimsLagToApsTimeChart", data);

        generateTableUsingChartData(data, '#stdClaimsLagTimeToApsTable', 'percentage');

    };

    this.bindClaimsTdoVsDdg = function (data) {

        bindChart("claimsTdoVsDdgChart", data);        

    };

    this.getChartDataByUrlAndParamter = function (isPdfGenerated) {

        //build post data
        var fromDate = "";
        var toDate = "";
        var clientId = "";
        fromDate = $('#fromDate').val();
        toDate = $('#toDate').val();
        clientId = $("#ddl_report").val();

        var employeeCountY1 = $('#employee_y1').val();
        var employeeCountY2 = $('#employee_y2').val();
        var employeeCountY3 = $('#employee_y3').val();
        var employeeCountY4 = $('#employee_y4').val();

        var postData = {
            fromDate: fromDate,
            toDate: toDate,
            clientId: clientId,
            generatePdf: isPdfGenerated,
            countEmployeesYear1: employeeCountY1,
            countEmployeesYear2: employeeCountY2,
            countEmployeesYear3: employeeCountY3,
            countEmployeesYear4: employeeCountY4
        };

        var expectedAjaxHitCount = 19;
        var actualAjaxHitCount = 0;
        var completionFunc = function () {

            if (++actualAjaxHitCount === expectedAjaxHitCount) {
                if (isPdfGenerated) {
                    thisViewModel.generatePdf();
                }
                else {
                    thisViewModel.getFormElementState();
                }
            }
        };

        //executive summary slide
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetExecutiveSummarySlideStats/", postData, this.bindExecutiveSummarySlide, completionFunc);

        //TODO: OSI benchmarking
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetBenchmarkIndicators/", postData, this.bindBenchmarksSlide, completionFunc);

        //referrals by month
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForReferralByMonthClaims/", postData, this.bindClaimsByMonth, completionFunc);

        //claims by site
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsbySite/", postData, this.bindClaimsBySite, completionFunc);

        //claims by province
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsbyProvince/", postData, this.bindClaimsByProvince, completionFunc);

        //claims by gender and age 
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByGenderAndAge/", postData, this.bindClaimsByGenderAndAge, completionFunc);

        //claims by gender, year over year
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByGenderYearOverYear/", postData, this.bindClaimsByGenderYearOverYear, completionFunc);

        //claims by age, year over year
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByAgeYearOverYear/", postData, this.bindClaimsByAgeYearOverYear, completionFunc);

        ////claims by seniority chart
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsBySeniority/", postData, this.bindClaimsBySeniority, completionFunc);

        ////claims by medical condition chart
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByMedicalCondition/", postData, this.bindClaimsByMedicalCondition, completionFunc);

        ////claims by medical condition year over year table
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByMedicalYearOverYear/", postData, this.bindClaimsByMedicalConditionYearOverYear, completionFunc);

        ////claims by Mental Health Diagnosis
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByDiagnosisMentalHealth/", postData, this.bindClaimsByDiagnosisForMentalHealth, completionFunc);

        ////claims by Musculoskeletal Diagnosis
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByDiagnosisMusculoskeletal/", postData, this.bindClaimsByDiagnosisForMusucloskeletal, completionFunc);

        //medical conditions analysis table
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataMedicalConditionAnalysisTable/", postData, this.bindMedicalConditionsAnalysis, completionFunc);

        //claims by closure reasons chart
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByClosureReason/", postData, this.bindClaimsByClosureReason, completionFunc);

        //claims by closure reasons - year over year - table
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByClosureReasonYearOverYear/", postData, this.bindClaimsByClosureReasonsYearOverYear, completionFunc);

        //claims lag to referral chart
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByLagReferralTime/", postData, this.bindClaimsLagTimeToReferral, completionFunc);

        //claims lag to APS chart
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByLagApsTime/", postData, this.bindClaimsLagTimeToAps, completionFunc);

        //claims lag to APS chart
        this.getDataForSlide("/api/ExecutiveSummaryReport/GetDataForClaimsByTdoVsDdg/", postData, this.bindClaimsTdoVsDdg, completionFunc);

    };

    this.getDataForSlide = function (url, postData, callbackOnSuccess, callbackOnCompletion) {

        $.ajax({
            url: this.ApiUrl + url,
            type: "POST",
            data: postData,
            beforeSend: function () {

            },
            success: function (response) {
                callbackOnSuccess(response);
            },
            complete: function () {
                if (callbackOnCompletion !== null)
                    callbackOnCompletion();
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                hideLoader();
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });

    };    
    // filter dashboard according to and from date devision 
    this.isFormValid = function () {
        // get the selected values 
        var clientId = $("#ddl_report").val();
        var from = $("#fromDate").val();
        var to = $("#toDate").val();
        if (clientId == "" || clientId == undefined || clientId == null) {
            notSuccessMessage("Please select client first!");
            return false;
        }
        if (from == "" && to == "") {
            notSuccessMessage("Please select to and from date!");
            return false;
        }
        if (from != "" && to == "") {
            notSuccessMessage("Please select to date!");
            return false;
        } else if (from == "" && to != "") {
            notSuccessMessage("Please select from date!");
            return false;
        } else if (new Date(from) > new Date(to)) {
            notSuccessMessage("From can not be greater than to date!");
            return false;
        } else {
            return true;
        }
    };
    //return true if all the input selected by user else return false
    this.validationForGeneratingReport = function () {
        // get the selected values 
        var clientId = $("#ddl_report").val();
        var from = $("#fromDate").val();
        var to = $("#toDate").val();
        if (clientId != null && clientId != "" && clientId != undefined && from != null && from != undefined && from != "" && to != "" && to != undefined && to != null) {
            return true;
        }
        return false;
    };

    //save state of every element of Form
    this.saveFormElementState = function (controlType, controlId, controlValue, parentId) {
        $.ajax({
            url: this.ApiUrl + "/api/ExecutiveSummaryReport/SaveFormStateBasedOnControlId/",
            type: "POST",
            data: {
                controlType: controlType,
                controlId: controlId,
                controlValue: controlValue,
                parentId: parentId,
                userId: thisViewModel.UserId
            },
            success: function (response) {
                if (!response) {
                    //notSuccessMessage("Something went wrong!");
                }
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };
    //update form state element when slide deleted
    this.updateFormElementState = function (controlId, parentId) {
        $.ajax({
            url: this.ApiUrl + "/api/ExecutiveSummaryReport/DeleteSlideById/",
            type: "POST",
            data: {
                controlId: controlId,
                parentId: parentId,
                userId: thisViewModel.UserId
            },
            success: function (response) {
                if (!response) {
                    // notSuccessMessage("Something went wrong!");
                }
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                hideLoader();
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };
    //replace HTML on the basis of new input data
    this.generateHtmlForPdf = function () {
        if (thisViewModel.isFormValid()) {
            showLoader();
            //disabled all form input
            thisViewModel.disabledFormElement();
            //thisViewModel.disabledFormButton();
            thisViewModel.getChartDataByUrlAndParamter(true);
        }
    };
    // function to generate the PDF
    this.generatePdf = function () {


        console.log("generatePdf()");

        var style = '<style>body{font-family: Tahoma, sans-serif !important;} .panel-footer{ clear: both;} #page-25 .h1{font-family:"Brush Script MT" !important;font-size: 80px !important;} .pdf-control p {font-size:25px !important;}.h1{font-size: 50px !important; font-weight: 700 !important;} h1{font-size: 50px !important; font-weight: 900 !important;}h2{font-size: 42px !important; font-weight: 700 !important;} h3{font-size: 40px !important; font-weight: 600 !important;}h4{font-size: 40px !important; font-weight: 900 !important;} .pdf-page {min-height: 19cm !important; page-break-before:always}  table { page-break-inside:auto }  tr{ page-break-inside: avoid; page-break-after: auto } thead{ display:table-header-group } .ui-control{display: none !important;} .pageBreak{ page-break-before: always !important;} .container{width:100%}.float-right{float:right!important}.text-right{text-align:right!important}.text-left{text-align:left!important}.text-center{text-align:center!important}.text-uppercase{text-transform:uppercase}.text-muted{color:#777}ol,ul{margin-top:0;margin-bottom:10px}.lead{margin-bottom:20px;font-size:21px;font-weight:300;line-height:1.4}p{padding:0!important;margin:0!important}.btn-primary{color:#fff;background-color:#337ab7;border-color:#2e6da4}.btn{display:inline-block;padding:6px 12px;margin-bottom:0;font-size:14px;font-weight:400;line-height:1.42857143;text-align:center;white-space:nowrap;vertical-align:middle;-ms-touch-action:manipulation;touch-action:manipulation;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;background-image:none;border:1px solid transparent;border-radius:4px}blockquote{padding:10px 20px;margin:0 0 20px;font-size:17.5px;border-left:5px solid #eee}blockquote .small,blockquote footer,blockquote small{display:block;font-size:80%;line-height:1.42857143;color:#777}blockquote .small:before,blockquote footer:before,  .small,small{font-size:85%}.p-0{padding:0!important}.p-4{padding:1.5rem!important}.p-5{padding:3rem!important}.p-3{padding:1rem!important}.pr-4{padding-right:1.5rem!important}.pl-5,.px-5{padding-left:3rem!important}.pr-5,.px-5{padding-right:3rem!important}.pb-4,.py-4{padding-bottom:1.5rem!important}.pt-4,.py-4{padding-top:1.5rem!important}.pb-5,.py-5{padding-bottom:3rem!important}.pt-5,.py-5{padding-top:3rem!important}.mb-1,.my-1{margin-bottom:.25rem!important}.mt-1,.my-1{margin-top:.25rem!important}.mb-4,.my-4{margin-bottom:1.5rem!important}.ml-2,.mx-2{margin-left:.5rem!important}.mt-4,.my-4{margin-top:1.5rem!important}.mb-5,.my-5{margin-bottom:3rem!important}.h1,h1{font-size:36px;margin:.67em 0}.h1,.h2,.h3,h1,h2,h3{margin-top:20px;margin-bottom:10px}.h1,.h2,.h3,.h4,.h5,.h6,h1,h2,h3,h4,h5,h6{font-family:inherit;font-weight:500;line-height:1.1;color:inherit}.h2,h2{font-size:30px;color:#000!important}.h3,h3{font-size:24px}.h4,h4{font-size:18px}.h4,.h5,.h6,h4,h5,h6{margin-top:10px;margin-bottom:10px} .panel .panel-heading{background-image: -webkit-linear-gradient(-130deg, #1C1C82, #F4F4F6);background-image: -o-linear-gradient(-130deg, #1C1C82, #F4F4F6);background-image: -moz-linear-gradient(-130deg, #1C1C82, #F4F4F6);background-image: -ms-linear-gradient(-130deg, #1C1C82, #F4F4F6);background-image: linear-gradient(-130deg, #1C1C82, #F4F4F6); color: black!important;padding:10px 15px;border-bottom:1px solid #00000033}.panel .panel-body{background-color:#fff!important;padding:15px}.panel .panel-body table thead tr th{color:#fff!important}.font-weight-bold,.panel .panel-body table thead tr th{font-weight:700!important}.panel-default{border-color:#ddd}.panel{margin-bottom:20px;background-color:#fff;border:1px solid #00000033;border-radius:6px;-webkit-box-shadow:0 1px 1px rgba(0,0,0,.05);box-shadow:0 1px 1px rgba(0,0,0,.05)}.col-md-12{width:100%}.col-md-3{width:25%}.col-md-1,.col-md-10,.col-md-11,.col-md-12,.col-md-2,.col-md-3,.col-md-4,.col-md-5,.col-md-6,.col-md-7,.col-md-8,.col-md-9{float:left}.table-responsive{min-height:.01%;overflow-x:auto}.table{width:100%;max-width:100%;margin-bottom:20px}table{background-color:transparent}table{border-spacing:0;border-collapse:collapse}table thead tr{color:#deedf9;background-color:#2c699e!important}.table>caption+thead>tr:first-child>td,.table>caption+thead>tr:first-child>th,.table>colgroup+thead>tr:first-child>td,.table>colgroup+thead>tr:first-child>th,.table>thead:first-child>tr:first-child>td,.table>thead:first-child>tr:first-child>th{border-top:0}.panel .panel-body table thead tr th{color:#fff!important}.panel .panel-body table thead tr th{font-weight:700!important}.table>thead>tr>th{vertical-align:bottom;border-bottom:2px solid #ddd}.table>tbody>tr>td,.table>tbody>tr>th,.table>tfoot>tr>td,.table>tfoot>tr>th,.table>thead>tr>td,.table>thead>tr>th{padding:8px;line-height:1.42857143;text-align:center;border:1px solid #ddd}.table-striped>tbody>tr:nth-of-type(odd){background-color:#f9f9f9}.table-bordered{border:1px solid #ddd}*{-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box}.bg-primary{color:#fff;background-color:#337ab7}.list-style{list-style-type:square}.align-middle{vertical-align:middle!important}#page-1{border:1px solid gray!important}.no-gutters{padding-left:25px;height:170px} </style>';
        var rawHtml = $("#main-sections").ignore(".cke_ltr,.chartData,.formInputBracket,.web-only").html();
        var htmlString = '<html><head><meta charset="utf-8"/><title></title>' + style + '    </head><body>' + rawHtml + '  </body></html>';
        $.ajax({
            url: this.ApiUrl + "/api/ExecutiveSummaryReport/GeneratePdf/",
            type: "POST",
            data: {
                html: htmlString,
                fromDate: $('#fromDate').val(),
                toDate: $('#toDate').val()
            },
            beforeSend: function () {

            },
            success: function (response) {
                var arrayBuffer = thisViewModel.base64ToArrayBuffer(response);
                //enable all input
                thisViewModel.enableFormElement();
                //thisViewModel.enabledFormButton();
                thisViewModel.saveByteArray("Report" + thisViewModel.getFormattedTime(), arrayBuffer);
            },
            complete: function () {
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                hideLoader();
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };

    this.resetCustomizations = function () {
        console.log("resetCustomizations()");

        $.ajax({
            url: this.ApiUrl + "/api/ExecutiveSummaryReport/ResetCustomizationsForUser/" + thisViewModel.UserId,
            type: "POST",
            success: function (response) {
                location.reload(true);
            },
            complete: function () {
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };

    // to add slide dynamically 
    this.addSlide = function (control) {
        //first check control have parentId or not
        var parentId = $(control).parents("section").attr("parentId");
        if (parentId == null || parentId == undefined || parentId == "") {
            parentId = $(control).parents("section").attr("id");
        }
        //  var button = $(control);
        //  var btnLadda = button.ladda();
        // fetch the user control html and append after the slide 
        $.ajax({
            cache: false,
            type: "POST",
            contentType: "application/json; charset=utf-8",
            url: "ExecutiveSummaryReport.aspx/AddSlide",
            dataType: "json",
            async: false,
            beforeSend: function () {
                //btnLadda.ladda('start');
            },
            success: function (response) {
                $(control).parents("section").after(response.d.htmlString).find('section').attr('id', 'value');
                $("#Slide_" + response.d.controlId + "").attr("parentId", parentId);
                initializeCkEditor("Editor_" + response.d.controlId + "");
                thisViewModel.saveFormElementState("Slide", response.d.controlId, "", parentId);
                //append a common function for saving text editor data in table
                setTimeout(function () {
                    $("textarea").siblings("div[class!='pdf-control']").attr("onmouseleave", "ExecutiveSummaryViewModel.saveCkEditorData(this)");
                }, 1000);

            },
            complete: function () {
                //btnLadda.ladda('stop');
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                hideLoader();
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };
    //fetch state for form element
    this.getFormElementState = function () {
        console.log("getFormElementState()");
        // fetch the user control html and append after the slide 
        $.ajax({
            url: this.ApiUrl + "/api/ExecutiveSummaryReport/GetFormElementState/",
            type: "GET",
            data: {
                userId: thisViewModel.UserId
            },
            beforeSend: function () {
            },
            success: function (response) {                
                thisViewModel.showFormElementValue(response);
            },
            complete: function () {
                hideLoader();
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                console.log("Error!" + jqXHR.responseText);
                hideLoader();
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };
    //bind data with editable fields
    this.bindEditableFormFields = function (controlId, controlValue) {
        $("#" + controlId + "").editable({
            placement: 'top',
            value: controlValue,
            success: function (response, newValue) { }
        });
    };
    //check each editable fields with the result we get from db
    this.IsEditableFieldsValueExist = function (data) {
        
        var txtYearExists = false;
        var txtClientNameExists = false;
        var txtRecoveryFacilitatorNamesExists = false;
        var txtClientLeadNameExists = false;


        for (var i = 0; i < data.length; i++) {
            if (data[i].controlId == 'txtYear') {
                txtYearExists = true;
            }
            if (data[i].controlId == 'txtClientName') {
                txtClientNameExists = true;
            }
            if (data[i].controlId == 'txtRecoveryFacilitatorNames') {
                txtRecoveryFacilitatorNamesExists = true;
            }
            if (data[i].controlId == 'txtClientLeadName') {
                txtClientLeadNameExists = true;
            }

        }

        if (!txtYearExists) {
            thisViewModel.bindEditableFormFields("txtYear", "Year");
        }
        if (!txtClientNameExists) {
            thisViewModel.bindEditableFormFields("txtClientName", "Name of Client");
        }
        if (!txtRecoveryFacilitatorNamesExists) {
            thisViewModel.bindEditableFormFields("txtRecoveryFacilitatorNames", "name(s) of person(s)");
        }
        if (!txtClientLeadNameExists) {
            thisViewModel.bindEditableFormFields("txtClientLeadName", "name of person");
        }      
    };

    //display the value of form element
    this.showFormElementValue = function (data) {
        console.log("showFormElementValue");
        //console.log(data)

        var formData = $.parseJSON(data.results);
        //check is their any value exist for each editable fields if no then bind it with default value
        thisViewModel.IsEditableFieldsValueExist(formData);

        formData.forEach(function (item) {
            if (item.controlId != '') {
                if (item.controlType == "TextBox") {
                    $("#" + item.controlId + "").val(item.controlValue);
                    //add data into their corresponding label
                    $("#" + item.controlId + "").siblings("label").text(item.controlValue);
                    thisViewModel.bindEditableFormFields(item.controlId, item.controlValue);
                }
                else {
                    var slideHtmlId = thisViewModel.slideControlIdToHtmlId(item.controlId);
                    var editorHtmlId = thisViewModel.editorControlIdToHtmlId(item.controlId);

                    //Delete slide if already exists
                    $('#' + slideHtmlId).remove();

                    var html = '<section class="pdf-page" id="' + slideHtmlId + '" parentid="' + item.parentId + '"><div class="container"><div class="panel panel-default"><div class="panel-heading"><h4><i class="icon icon-calendar"></i></h4></div><div class="panel-body"><div class="row"><div class="col-5 p-5"><div class="pdf-control"></div><textarea onkeyup="ExecutiveSummaryViewModel.UpdateLabelValue(this)" class="form-control ui-control" id="Editor_' + item.controlId + '" controltype="Slide"> </textarea></div></div><div class="row p-3"><button class="btn btn-primary ml-2 ui-control pull-right" onclick="ExecutiveSummaryViewModel.addSlide(this)" controltype="Slide"><span class="icon icon-plus"></span></button><button class="btn btn-warning pull-right ui-control" style="margin-right:4px" onclick="ExecutiveSummaryViewModel.removeSlide(this)" controltype="Slide"><span class="icon icon-bin"></span></button></div></div> </div></div ></section >';
                    $("#" + item.parentId + "").after(html);
                    initializeCkEditor("Editor_" + item.controlId + "");
                    $('#' + editorHtmlId).val(item.controlValue);
                    thisViewModel.updateLabelValueForCkEditor(editorHtmlId, item.controlValue);
                }
            }
        });
        //now remove the deleted static slides 
        data.deletedStaticSlideId.forEach(function (item) {
            $("#" + item + "").remove();
        });
        //enable all input
        thisViewModel.enableFormElement();
        //show/hide the main section for generating report
        $("#main-sections").show();
        $("#genearate-pdf").removeClass("hidden");
        //append a common function for saving text editor data in table
        setTimeout(function () {
            $("textarea").siblings("div[class!='pdf-control']").attr("onmouseleave", "ExecutiveSummaryViewModel.saveCkEditorData(this)");
        }, 3000);
    };

    this.slideControlIdToHtmlId = function (controlId) {
        return 'Slide_' + controlId
    };

    this.editorControlIdToHtmlId = function (controlId) {
        return 'Editor_' + controlId
    };

    // to remove Slide  dynamically
    this.removeSlide = function (control) {
        var parentId = $(control).parents("section").attr("parentid");
        if (parentId == null || parentId == undefined || parentId == "") {
            thisViewModel.updateFormElementState("", $(control).parents("section").attr("id"));
        }
        else {
            var slideId = $(control).parents("section").attr("id");
            thisViewModel.updateFormElementState(slideId.split("_")[1], "");
        }
        $(control).parents("section").remove();
    };
    // for initializing dashboard 
    this.InitializeView = function (url, token) {
        $("#main-sections").hide();
        //region 17-4-2019
        this.ApiUrl = url;
        //get user id based on token created on logIn time
        thisViewModel.getUserIdBasedOnToken(token);
        //bind client data with dropdown
        thisViewModel.getClientsBasedOnToken(token);

        //diabled only form button
        //thisViewModel.disabledFormButton();

        //end


    };
    //show render html and show html based on input data
    this.generateClientReport = function () {
        if (thisViewModel.isFormValid()) {
            showLoader();
            //disabled all form input
            //thisViewModel.disabledFormElement();
            thisViewModel.getChartDataByUrlAndParamter(false);

            thisViewModel.showResetCustomizationButton();
        }
    }
    //jquery api for post back the data entered by user in text-editable
    //ajax emulation. Type "err" to see error message
    $.mockjax({
        url: '/post',
        responseTime: 400,
        response: function (settings) {
            if (settings.data.value == 'err') {
                this.status = 500;
                this.responseText = 'Validation error!';
            } else {
                //successfully save then save the textbox data in database and upadte its corresponding label value
                var controlValue = settings.data.value;
                var id = settings.data.name;
                var parentId = $("#" + id).parents("section").attr("id");
                $("#" + id + "").siblings("label").text(controlValue);
                thisViewModel.saveFormElementState("TextBox", id, controlValue, parentId);
            }
        }
    });
    //get clients based on token generated when logIn
    this.getClientsBasedOnToken = function (token) {
        $.ajax({
            url: this.ApiUrl + "/api/Client/All/" + token,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            type: "GET",
            success: function (response) {
                var data = JSON.parse(response);
                $("#ddl_report").append($("<option></option>").val("").html("Select client"));
                data.forEach(function (item) {
                    $("#ddl_report").append($("<option></option>").val(item.ClientID).html(item.ClientName));
                });
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };
    //get user info based on logIn token
    this.getUserIdBasedOnToken = function (token) {
        $.ajax({
            url: this.ApiUrl + "/api/{token}/Users/profile?token=" + token + "",
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            type: "GET",
            success: function (response) {
                var data = JSON.parse(response);
                if (data != null) {
                    thisViewModel.UserId = data.USER_ID;
                }
                // call to fetch all  form state element 
                //thisViewModel.getFormElementState();
            },
            failure: function (jqXHR, textStatus, errorThrown) {
                alert("HTTP Status: " + jqXHR.status + "; Error Text: " + jqXHR.responseText); // Display error message  
            }
        });
    };
    //check firefox browser and other
    this.detectBrowser = function () {
        var BrowserDetect = {
            init: function () {
                this.browser = this.searchString(this.dataBrowser) || "Other";
                this.version = this.searchVersion(navigator.userAgent) || this.searchVersion(navigator.appVersion) || "Unknown";
            },
            searchString: function (data) {
                for (var i = 0; i < data.length; i++) {
                    var dataString = data[i].string;
                    this.versionSearchString = data[i].subString;

                    if (dataString.indexOf(data[i].subString) !== -1) {
                        return data[i].identity;
                    }
                }
            },
            searchVersion: function (dataString) {
                var index = dataString.indexOf(this.versionSearchString);
                if (index === -1) {
                    return;
                }
                var rv = dataString.indexOf("rv:");
                if (this.versionSearchString === "Trident" && rv !== -1) {
                    return parseFloat(dataString.substring(rv + 3));
                } else {
                    return parseFloat(dataString.substring(index + this.versionSearchString.length + 1));
                }
            },
            dataBrowser: [
                { string: navigator.userAgent, subString: "Edge", identity: "MS Edge" },
                { string: navigator.userAgent, subString: "MSIE", identity: "Explorer" },
                { string: navigator.userAgent, subString: "Trident", identity: "Explorer" },
                { string: navigator.userAgent, subString: "Firefox", identity: "Firefox" },
                { string: navigator.userAgent, subString: "Opera", identity: "Opera" },
                { string: navigator.userAgent, subString: "OPR", identity: "Opera" },
                { string: navigator.userAgent, subString: "Chrome", identity: "Chrome" },
                { string: navigator.userAgent, subString: "Safari", identity: "Safari" }
            ]
        };
        return BrowserDetect;
    };
    //disabled all input,dropdown and button on page load/pdf generator
    this.disabledFormElement = function () {
        $("form").find("input,select").each(function () {
            $(this).prop("disabled", "disabled");
        });
        $("#main-sections").find("textarea,button").each(function () {
            $(this).prop("disabled", "disabled");
        });
        $("#main-sections").find("a").each(function () {
            $(this).css({ "pointer-events": "none", "cursor": "default" });
        });
    };
    ////disabled form button
    //this.disabledFormButton = function () {

    //    console.log('disabling form buttons');

    //    $("form").find("input[type='submit'],button[id!='genearate-pdf']").each(function () {
    //        $(this).prop("disabled", "disabled");
    //    });
    //};

    this.showResetCustomizationButton = function () {
        $('#reset-customizations-button').removeClass('hidden');
    };

    //enabled all form element like input,dropdown and buttons
    this.enableFormElement = function () {
        //console.log("enableFormElement");
        $("form").find("select,input").each(function () {
            $(this).removeProp("disabled");
        });
        $("#main-sections").find("textarea,button").each(function () {
            $(this).removeProp("disabled");
        });
        $("#main-sections").find("a").each(function () {
            $(this).removeAttr("style");
        });
    };
    ////enabled form button
    //this.enabledFormButton = function () {
    //    //console.log("enabledFormButton");
    //    $("form").find("input[type='submit'],button[id!='genearate-pdf']").each(function () {
    //        //console.log(this);            
    //        $(this).prop("disabled", false);
    //    });
    //};
    //save bytes of generated pdf
    this.saveByteArray = function (reportName, byte) {
        //first detect broswer(if firefox) then generate pdf in other way
        var browserDetect = thisViewModel.detectBrowser();
        browserDetect.init();
        var blob = new Blob([byte], { type: "application/pdf" });
        if (browserDetect.browser === "Firefox") {
            var url = window.URL.createObjectURL(blob);
            window.open(url, '_blank');
            //var a = document.createElement("a");
            //document.body.appendChild(a);
            //a.style = "display: none";
            //blob = new Blob([byte], { type: "octet/stream" }),
            //    url = window.URL.createObjectURL(blob);
            //a.href = url;
            //a.download = reportName;
            //a.click();
            //window.URL.revokeObjectURL(url);
        }
        else {
            //blob = new Blob([byte], { type: "application/pdf" });
            var link = document.createElement('a');
            link.href = window.URL.createObjectURL(blob);
            var fileName = reportName;
            link.download = fileName;
            link.click();
        }
        hideLoader();
    };
    //  convert base64 to array Buffer sent by server
    this.base64ToArrayBuffer = function (base64) {
        var binaryString = window.atob(base64);
        var binaryLen = binaryString.length;
        var bytes = new Uint8Array(binaryLen);
        for (var i = 0; i < binaryLen; i++) {
            var ascii = binaryString.charCodeAt(i);
            bytes[i] = ascii;
        }
        return bytes;
    };
    //get formatted time
    this.getFormattedTime = function () {
        var today = new Date();
        var y = today.getFullYear();
        // JavaScript months are 0-based.
        var m = today.getMonth() + 1;
        var d = today.getDate();
        var h = today.getHours();
        var mi = today.getMinutes();
        var s = today.getSeconds();
        return y + "-" + m + "-" + d + "-" + h + "-" + mi + "-" + s;
    };
    //on mouse leave event of ckeditor we will fetch data from ckeditor and then save it inside db and 
    //update its label
    this.saveCkEditorData = function (control) {
        var id = $(control).siblings("textarea").attr("id");
        var parentId = $(control).parents("section").attr("parentid");
        var value = CKEDITOR.instances[id].getData();
        thisViewModel.saveFormElementState("Slide", id.split("_")[1], value, parentId);
        thisViewModel.updateLabelValueForCkEditor(id, value);
    };
    //update label value with ckeditor 
    this.updateLabelValueForCkEditor = function (controlId, controlValue) {
        $("#" + controlId + "").siblings("div.pdf-control").html(controlValue);
    };
};



