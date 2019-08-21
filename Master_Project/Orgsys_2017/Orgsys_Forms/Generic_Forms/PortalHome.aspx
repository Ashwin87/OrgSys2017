<%@ Page Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="PortalHome.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Master.PortalHome" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/promise-polyfill.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/gauge.min.js"></script>
    <script src="/Assets/js/orgsysNavbar.js"></script>
    <script src="../../Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/PortalHome.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script src="../../Assets/js/countUp.min.js"></script>
    <script>
        //initialize token and api for this window
        window.api = "<%= get_api%>";
        window.token = "<%= token%>";
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <%--<div class="spacer"></div>--%>
    <div class="content_holder">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading">
                <div id="welcome-header" class="osp-heading panel-heading">
                    <div class="welcome_text" id="pWelcome">Welcome&nbsp;</div>
                    <div class="welcome_username" id="welcome-username"></div>
                </div>
                <div id="welcome-footer" class="osp-heading panel-heading">
                    <div class="last_login" id="pLastLogin">Your last login was reported on&nbsp;</div>
                    <div id="welcome-lastlogin"></div>
                </div>
            </div>
            <div id="logo-container" class="osp-heading panel-heading welcome-container narrow-container"></div>
            <%--<ul class="nav navbar-nav navbar-right language_setter portal_home_language">
                <li class="Language">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">
                        <span>Language</span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li>
                            <a class="Language" href="#">en-ca</a>
                        </li>
                        <li>
                            <a class="Language" href="#">fr-ca</a>
                        </li>
                    </ul>
                </li>
            </ul>--%>
        </div>
        <div class="spacer"></div>
        <div id="portal-container" class="container-fluid narrow-container">
            <div class="row equal">
                 <div class="panel panel-default">
                    <div class="panel-heading panel_title">
                        <h3 class="panel-title" id="hHowCanHelp">
                            <i class="fa fa-bullhorn fa-fw"></i>How can we help you today?
                        </h3>
                    </div>
                    <div class="help-panel-body-right">
                        <div class="list-group" id="self-help">
                            <div id="starting-actions" class="styleList">
                                <div class="help_blocks report_an_absence">
                                    <a id="ReportAnAbsence" href="#" class="list-group-item" data-toggle="modal" data-target="modal">
                                      <div class="help_block_setter">
                                         <i class="icon icon-clipboard-edit"></i><br />
                                         <p id="pReportAnAbsence">Report an Absence</p>
                                      </div>
                                    </a>
                                 </div>
                                <div class="help_blocks view_past_absence">
                                    <a href="/OrgSys_Forms/Generic_Forms/PortalClaimManager.aspx" class="list-group-item" data-toggle="modal" data-target="">
                                        <div class="help_block_setter">
                                            <i class="icon icon-book"></i><br />
                                            <p id="pViewPastAbsences">View Past Absences</p>
                                        </div>
                                    </a>
                                </div>
                                <div class="help_blocks view_documents">
                                    <a href="../PortalDocumentViewer.aspx" class="list-group-item" data-toggle="modal" data-target="">
                                        <div class="help_block_setter">
                                            <i class="icon icon-folder-open1"></i><br />
                                            <p id="pViewDocs">View Documents</p>
                                        </div>
                                    </a>
                                 </div>
                                <div class="help_blocks download_reports">
                                    <a href="/OrgSys_Forms/ReportingTool.aspx" class="list-group-item" data-toggle="modal" data-target="">
                                        <div class="help_block_setter">
                                            <i class="icon icon-stats-bars"></i><br />
                                            <p id="pDownloadReports">View/Download Reports</p>
                                        </div>
                                     </a>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="absence_container">
                    <div class="absence_reports">
                        <div class="panel panel-default absence_report_container absence_normal_container">
                            <div class="panel-heading absence_report_logo">
                                <i class="icon icon-stats-dots"></i>
                            </div>
                            <div class="report_text">
                                <div class="absence_report_header">
                                    <h3 class="panel-title" id="hAbsencesReported">Absences Reported</h3>
                                </div>
                                <div class="panel-body align-text-center fill-panel-height">
                                    <div class="dashboard-report-container">
                                        <h1 id="TotalAbsencesReported" class="ReportValue"></h1>
                                        <h2 class="dashboard-report-suffix" id="hrepAbsences">Absences</h2>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="absence_reports">
                        <div class="panel panel-default absence_report_container absence_yeartodate_container">
                            <div class="panel-heading absence_report_logo">
                                <i class="icon icon-stats-dots"></i>
                            </div>
                            <div class="report_text">
                                <div class="absence_report_header">
                                    <h3 class="panel-title" id="hAbsencesReportedYD">Absences Reported (Year-Date)</h3>
                                </div>
                                <div class="panel-body align-text-center fill-panel-height">
                                    <div class="dashboard-report-container">
                                        <h1 id="TotalAbsencesReportedYTD" class="ReportValue"></h1>
                                        <h2 class="dashboard-report-suffix" id="hAbsencesYD">Absences</h2>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
/*        var opts = {
          angle: 0.15, // The span of the gauge arc
          lineWidth: 0.44, // The line thickness
          radiusScale: 1, // Relative radius
          pointer: {
            length: 0.6, // // Relative to gauge radius
            strokeWidth: 0.035, // The thickness
            color: '#000000' // Fill color
          },
          limitMax: false,     // If false, max value increases automatically if value > maxValue
          limitMin: false,     // If true, the min value of the gauge will be fixed
          colorStart: '#6FADCF',   // Colors
          colorStop: '#8FC0DA',    // just experiment with them
          strokeColor: '#E0E0E0',  // to see which ones work best for you
          generateGradient: true,
          highDpiSupport: true,     // High resolution support
  
        };
*/
/*      var opts = {
          angle: -0.5, // The span of the gauge arc
          lineWidth: 0.02, // The line thickness
          radiusScale: 1, // Relative radius
          pointer: {
            length: 0, // // Relative to gauge radius
            strokeWidth: 0, // The thickness
            color: '#000000' // Fill color
          },
          limitMax: false,     // If false, max value increases automatically if value > maxValue
          limitMin: false,     // If true, the min value of the gauge will be fixed
          colorStart: '#195388',   // Colors
          colorStop: '#195388',    // just experiment with them
          strokeColor: '#94B1C7',  // to see which ones work best for you
          generateGradient: false,
          highDpiSupport: true,     // High resolution support
        };

        var target = document.getElementById('gauge1'); // your canvas element
        var gauge = new Gauge(target).setOptions(opts); // create sexy gauge!
        gauge.setTextField(document.getElementById('gauge1-textfield'));
        gauge.maxValue = 3000; // set max gauge value
        gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
        gauge.animationSpeed = 32; // set animation speed (32 is default value)
        gauge.set(12); // set actual value

        target = document.getElementById('gauge2'); // your canvas element
        gauge = new Gauge(target).setOptions(opts); // create sexy gauge!
        gauge.setTextField(document.getElementById('gauge2-textfield'));
        gauge.maxValue = 3000; // set max gauge value
        gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
        gauge.animationSpeed = 32; // set animation speed (32 is default value)
        gauge.set(125); // set actual value

        target = document.getElementById('gauge3'); // your canvas element
        gauge = new Gauge(target).setOptions(opts); // create sexy gauge!
        gauge.setTextField(document.getElementById('gauge3-textfield'));
        gauge.maxValue = 3000; // set max gauge value
        gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
        gauge.animationSpeed = 32; // set animation speed (32 is default value)
        gauge.set(250); // set actual value

        target = document.getElementById('gauge4'); // your canvas element
        gauge = new Gauge(target).setOptions(opts); // create sexy gauge!
        gauge.setTextField(document.getElementById('gauge4-textfield'));
        gauge.maxValue = 3000; // set max gauge value
        gauge.setMinValue(0);  // Prefer setter over gauge.minValue = 0
        gauge.animationSpeed = 32; // set animation speed (32 is default value)
        gauge.set(150); // set actual value
        */
    </script>
</asp:Content>
