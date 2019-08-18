//Created By: Marie Gougeon
//Create Date: 2018-11-12 to 2018-11-14
//Description: Reporting Tool

$(document).ready(function () {
    $("select").select2();
    getReportTypes();
    getServicesForClient();
    // Set dates to default dates, so no errors occur
    if ($("#fromdate").val() == "") { 
        $("#fromdate").datepicker("setDate", new Date());
    }
    if ($("#todate").val() == "") {
        $("#todate").datepicker("setDate", new Date());
    }

    //Create Chart click function that will render your chart on the page
    $("input[id*='btn_createReport']").click(function () {
        createChart($("select[id$='ddl_report'] option:selected").val(), $("#todate").data("iso-date"), $("#fromdate").data("iso-date"), $("select[id$='ddl_report'] option:selected").attr("data-sectionname"));
    });

    InitializeDatepicker();
    handleReportChange();

    //save the chart as an image
    $("input[id*='btn_saveChart']").click(function () {
        document.getElementById("myChart").style.background = 'white';
        var fileName = "ChartImage_" + $("select[id$='ddl_report'] option:selected").text().replace(/\s/g, '');
        var canvas = document.getElementById("myChart"), ctx = canvas.getContext("2d", { alpha: false });
        canvas.toBlob(function (blob) {
            saveAs(blob, fileName + ".jpg");
        });
    });

    $("#ddl_report").on("change", function () {
        handleReportChange();
    });

    //download the chart on a .xlsx file, with all the given parameters
    $("input[id*='btn_download']").click(function () {
        var reportName = $("select[id$='ddl_report'] option:selected").text() + "- Ranging from " + $("#fromdate").val() + " to " + $("#todate").val();
        var selectedReportVal = $("select[id$='ddl_report'] option:selected").val();
        var toDate = $("#todate").data("iso-date");
        var fromDate = $("#fromdate").data("iso-date");
        $.ajax({
            url: getApi + "/api/OldOrgsysGetData/GetReportsOldOrgsys/" + Token + "/" + selectedReportVal + "/" + toDate + "/" + fromDate,
            async: false,
            success: function (data) {
                var results = JSON.parse(data);
                downloadJSONtoExcel(results, reportName, true);
            }
        });
        
    });

});
function getReportTypes() {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) {
            xhr.setRequestHeader('Language', window.Language);
            xhr.setRequestHeader('Authentication', window.token);
        },
        url: getApi + "/api/Report/GetReportTypes",
        success: function (data) {
            var results = JSON.parse(data);
            $.each(results, function (i, result) {
                $('#ddl_report').append('<option data-sectionname="' + result.SectionName + '" value="' + result.ReportValue + '">' + result.ReportText + '</option>');
            });
        }
    });
}
function getServicesForClient() {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Language', window.Language); },
        url: getApi + "/api/Client/GetClientServices/" + Token,
        success: function (data) {
            var results = JSON.parse(data);
            console.log(results);
            $.each(results, function (i, result) {
                var newOption = new Option(result.ServiceDescription, result.Abbreviation, false, false);
                $("#selectService").append(newOption).trigger('change');
            });
        }
    });
}

//When a new report is selected, run this function
function handleReportChange() {
    if ($("#ddl_report").val() == 0) {
        $("#btn_createReport").attr("disabled", "disabled");
        $("#btn_download").attr("disabled", "disabled");
        $("#btn_saveChart").attr("disabled", "disabled");
    } else {
        $("#btn_createReport").removeAttr("disabled");
        $("#btn_download").removeAttr("disabled");
        $("#btn_saveChart").removeAttr("disabled");
    }
}
var reportEndpoints = {
    1: "Report_NewReferralsAggregateByMonth",
    2: "Report_ClosedReferralsAggregatebyMonth"
    //3: "Report_NewReferralsDetailsbySite",
    //4: "Report_NewReferralsDetailsbyDivision",
    //5: "Report_NewReferralsAggregatebyDepartment",
    //6: "Report_NewReferralsAggregateByProvince",
    //7: "Report_NewReferralsAggregateByGender",
    //8: "Report_NewReferralsDetailsbyByAge_Datepicker",
    //9: "Report_NewReferralsAggregateByPrimaryInjury",
    //10: "Report_ClosedReferralsAggregatebyReasonClosed"
};

//REPORT CHARTS
//clicking create report will trigger this function to draw on the canvas
function createChart(SelectedReport, toDate, fromDate, dataAttr) {
    $('#myChart').remove(); // this is my <canvas> element, gotta wipe it out before making a new one
    $('#canvasContainer').append('<canvas id="myChart"><canvas>');
    //explicitly state the labels and data
    var labelPoints = [];
    var dataPoints = [];
    var inputData = {
        dateFrom: fromDate,
        dateTo: toDate,
        clientService: $("#selectService").val()
    };
    var selectedReport = reportEndpoints[$("#ddl_report").val()];

    //AJAX call to grab the right stored procedure, run it and grab the data from it api/ReportReport_NewReferralsAggregateByMonth/{token }
    $.ajax({
        type:'POST',
        url: getApi + "/api/Report/" + selectedReport + "/" + Token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: inputData,
        async: false,
        success: function (data) {
            //Loop through results and push proper data to the right array
            var results = JSON.parse(data);
            
            for (i = 0; i < results.length; i++) {
                labelPoints.push(results[i][dataAttr]);
                dataPoints.push(results[i]["Claim_Count"]);
            }
        }
    });
    //find canvas
    var canvas = document.getElementById("myChart").getContext("2d");
    //create new chart with presets
    var myChart = new Chart(canvas, {
        type: 'bar',
        data: {
            labels: labelPoints,
            datasets: [
                {
                    label: "Claim Count",
                    backgroundColor: "#267DB3",
                    data: dataPoints
                }
            ]
        },
        options: {
            scales: {
                xAxes: [{
                    categorySpacing: 20
                }],
                yAxes: [{
                    categorySpacing: 20,
                    ticks: {
                        beginAtZero: true
                    }
                }]
            },
            responsive: true,
            maintainAspectRatio: false,
            barThickness: 200,
            //title is taken from a few inputs on the page
            title: {
                display: true,
                text: $("select[id$='ddl_report'] option:selected").text() + "- Ranging from " + $("#fromdate").val() + " to " + $("#todate").val(),
                position: "top"
            }
        }
    });
}

function downloadJSONtoExcel(JSONData, ReportTitle, ShowLabel) {
    //If JSONData is not an object then JSON.parse will parse the JSON string in an Object
    var arrData = typeof JSONData != 'object' ? JSON.parse(JSONData) : JSONData;
    var CSV = '';
    //Set Report title in first row or line
    CSV += ReportTitle + '\r\n\n';
    //This condition will generate the Label/Header
    if (ShowLabel) {
        var row = "";
        //This loop will extract the label from 1st index of on array
        for (var index in arrData[0]) {
            //Now convert each value to string and comma-seprated
            row += index + ',';
        }
        row = row.slice(0, -1);
        //append Label row with line break
        CSV += row + '\r\n';
    }
    //1st loop is to extract each row
    for (var i = 0; i < arrData.length; i++) {
        var row = "";
        //2nd loop will extract each column and convert it in string comma-seprated
        for (var index in arrData[i]) {
            row += '"' + arrData[i][index] + '",';
        }
        row.slice(0, row.length - 1);
        //add a line break after each row
        CSV += row + '\r\n';
    }
    if (CSV == '') {
        alert("Invalid data");
        return;
    }

    //Generate a file name with the datetime stamp so it is unique always
    var date = new Date();
    var isodate = date.toISOString();
    var fileName = isodate;
    //this will remove the blank-spaces from the title and replace it with an underscore
    fileName += ReportTitle.replace(/ /g, "_");

    //Initialize file format you want csv or xls
    var uri = 'data:text/csv;charset=utf-8,' + escape(CSV);
    var link = document.createElement("a");
    link.href = uri;
    link.style = "visibility:hidden";
    link.download = fileName + ".csv";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}


var saveAs = saveAs || function (e) {
    "use strict";
    if (typeof e === "undefined" || typeof navigator !== "undefined" && /MSIE [1-9]\./.test(navigator.userAgent)) {
        return
    }
    var t = e.document,
        n = function () {
            return e.URL || e.webkitURL || e;
        },
        r = t.createElementNS("http://www.w3.org/1999/xhtml", "a"),
        o = "download" in r,
        i = function (e) {
            var t = new MouseEvent("click");
            e.dispatchEvent(t);
        },
        a = /constructor/i.test(e.HTMLElement),
        f = /CriOS\/[\d]+/.test(navigator.userAgent),
        u = function (t) {
            (e.setImmediate || e.setTimeout)(function () {
                throw t;
            }, 0);
        },
        d = "application/octet-stream",
        s = 1e3 * 40,
        c = function (e) {
            var t = function () {
                if (typeof e === "string") {
                    n().revokeObjectURL(e);
                } else {
                    e.remove();
                }
            };
            setTimeout(t, s);
        },
        l = function (e, t, n) {
            t = [].concat(t);
            var r = t.length;
            while (r--) {
                var o = e["on" + t[r]];
                if (typeof o === "function") {
                    try {
                        o.call(e, n || e);
                    } catch (i) {
                        u(i);
                    }
                }
            }
        },
        p = function (e) {
            if (/^\s*(?:text\/\S*|application\/xml|\S*\/\S*\+xml)\s*;.*charset\s*=\s*utf-8/i.test(e.type)) {
                return new Blob([String.fromCharCode(65279), e], {
                    type: e.type
                });
            }
            return e;
        },
        v = function (t, u, s) {
            if (!s) {
                t = p(t);
            }
            var v = this,
                w = t.type,
                m = w === d,
                y, h = function () {
                    l(v, "writestart progress write writeend".split(" "));
                },
                S = function () {
                    if ((f || m && a) && e.FileReader) {
                        var r = new FileReader;
                        r.onloadend = function () {
                            var t = f ? r.result : r.result.replace(/^data:[^;]*;/, "data:attachment/file;");
                            var n = e.open(t, "_blank");
                            if (!n) e.location.href = t;
                            t = undefined;
                            v.readyState = v.DONE;
                            h();
                        };
                        r.readAsDataURL(t);
                        v.readyState = v.INIT;
                        return
                    }
                    if (!y) {
                        y = n().createObjectURL(t);
                    }
                    if (m) {
                        e.location.href = y;
                    } else {
                        var o = e.open(y, "_blank");
                        if (!o) {
                            e.location.href = y;
                        }
                    }
                    v.readyState = v.DONE;
                    h();
                    c(y);
                };
            v.readyState = v.INIT;
            if (o) {
                y = n().createObjectURL(t);
                setTimeout(function () {
                    r.href = y;
                    r.download = u;
                    i(r);
                    h();
                    c(y);
                    v.readyState = v.DONE;
                });
                return
            }
            S();
        },
        w = v.prototype,
        m = function (e, t, n) {
            return new v(e, t || e.name || "download", n)
        };
    if (typeof navigator !== "undefined" && navigator.msSaveOrOpenBlob) {
        return function (e, t, n) {
            t = t || e.name || "download";
            if (!n) {
                e = p(e);
            }
            return navigator.msSaveOrOpenBlob(e, t);
        };
    }
    w.abort = function () { };
    w.readyState = w.INIT = 0;
    w.WRITING = 1;
    w.DONE = 2;
    w.error = w.onwritestart = w.onprogress = w.onwrite = w.onabort = w.onerror = w.onwriteend = null;
    return m;
}(typeof self !== "undefined" && self || typeof window !== "undefined" && window || this.content);
if (typeof module !== "undefined" && module.exports) {
    module.exports.saveAs = saveAs;
} else if (typeof define !== "undefined" && define !== null && define.amd !== null) {
    define([], function () {
        return saveAs;
    });
}