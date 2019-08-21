//Main
$(document).ready(function () {
    initUserProfile();

    var count = getReportData();

    //In the future this will be a request to the server and will generate the markup
    var DASHBOARD_REPORTS = [
        {
            ReportID: 'TotalAbsencesReported',
            ReportTitle: 'Absences Reported',
            ReportValue: count
        },
        {
            ReportID: 'TotalAbsencesReportedYTD',
            ReportTitle: 'Absences Reported (YTD)',
            ReportValue: count
        }];

    initDashboardReportCounters(DASHBOARD_REPORTS);

    //Event handler for clicking the report an absence button on the portal home
    $(".report_an_absence").on('click', function () {

        $.ajax({
            type: 'GET',
            beforeSend: function (xhr) {
                xhr.setRequestHeader('Language', window.Language);
                xhr.setRequestHeader('Authentication', window.token);
            },
            url: window.api + "/api/Client/GetClientServices_V2/" + window.token,
            success: function (response) {
                var CLIENT_SERVICES_ARRAY = JSON.parse(response);
                var inputOptions = {};
                $.map(CLIENT_SERVICES_ARRAY, function (service) {
                    inputOptions[service.ServiceID] = service.ServiceDescription;
                });
                swal({
                    title: 'What absence type would you like to report?',
                    input: 'select',
                    showCancelButton: true,
                    inputOptions: inputOptions
                }).then(function (formID) {
                    window.location.href = '/Orgsys_Forms/Generic_Forms/Form7.aspx?FormID=' + formID;
                });
            }
        });
    });
});

//gets information required to render the UI for PortalHome and then initializes the UI for the page
function initUserProfile() {
    //get the last activity for the user logged in
    $.ajax({
        url: window.api + "/api/" + window.token + "/Users/profile",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        success: function (profile) {
            RenderProfileDataUI(JSON.parse(profile));
        }
    });
}

//Renders all of the UI elements accoiciated with the token currently used
function RenderProfileDataUI(profile) {
    $("#welcome-username").text(profile.Name);
    var DateLastActive_SessionID = Math.min.apply(Math, profile.previousSessions.map(function (sesh) { return sesh.SessionID; }));
    var DateLastActive = profile.previousSessions.find(function (session) { return session.SessionID === DateLastActive_SessionID; }).DateLastActive;

    $("#welcome-lastlogin").text(ConvertToReadableDate(DateLastActive));
}

/**
 * Initialize the dashboard reports
 * @param {any} dashBoardReports
 */
function initDashboardReportCounters(dashBoardReports) {
    var dashboardReportCounters = [];
    var options = {
        useEasing: true,
        useGrouping: true,
        separator: ',',
        decimal: '.'
    };

    dashBoardReports.forEach(function (report) {
        var reportCounter = new CountUp(report.ReportID, 0, report.ReportValue, null, null, options);
        if (!reportCounter.error) {
            dashboardReportCounters.push(reportCounter);
            reportCounter.start();
        }
    });
}

//
function getReportData() {
    var claimCount = 0;

    $.ajax({
        type: 'GET',
        url: window.api + "/api/OldOrgsysGetData/GetDashboardReportData/" + window.token,
        async: false,
        success: function (response, status, xhr) {
            if (xhr.status === 200) {
                claimCount = JSON.parse(response);
            }
        }
    });

    return claimCount;
}