<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="ExecutiveSummaryReport.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.ExecutiveSummaryReport" %>

<asp:Content ID="Content_head" ContentPlaceHolderID="Head" runat="server">
    <link href="../Assets/x-editable/css/bootstrap-editable.css" rel="stylesheet" />
    <link href="../Assets/toastr/toastr.min.css" rel="stylesheet" />

    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/highcharts-3d.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>
    <script src="https://code.highcharts.com/modules/export-data.js"></script>



    <!-- Created By   : Phd Solutions
         Create Date  : 2019-02-19
         Description  : Executive Summary Reporting Tool -->
    <style>
        .ui-widget-header {
            background-color: none !important;
        }

        .pdf-control {
            display: none !important;
        }
    </style>
</asp:Content>

<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="button" id="test"></div>

    <div class="mx-3">
        <div class="spacer"></div>
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading">
                <div id="welcome-header" class="osp-heading panel-heading">Executive Reporting Tool</div>
            </div>
            <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div class="spacer"></div>

        <div class="panel panel-body panel-body-bordered narrow-container">
            <form id="form1" runat="server">
                <div id="form-content" class="tab-content">
                    <div class="row margin-bottom">
                        <div class="col-md-3">
                            <label for="selectReport">Select Report:</label>
                            <select id="ddl_report" class="form-control col-md-3" name="selectReport" data-id="selectReport">
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label for="fromdate">Date From:</label>
                            <input id="fromDate" type="date" class="form-control col-md-3" name="fromdate" data-id="fromdate" onkeydown="return(event.keyCode!=13);" />
                        </div>
                        <div class="col-md-3">
                            <label for="todate">Date To:</label>
                            <input id="toDate" type="date" class="form-control col-md-3" name="todate" data-id="todate" onkeydown="return(event.keyCode!=13);" />
                        </div>
                    </div>
                    <div class="row margin-bottom">
                        <div class="col-md-3">
                            <label for="employee_y1">Employees Year 1:</label>
                            <input type="number" id="employee_y1" class="form-control col-md-3" value="100" />
                        </div>
                        <div class="col-md-3">
                            <label for="employee_y2">Employees Year 2:</label>
                            <input type="number" id="employee_y2" class="form-control col-md-3" value="100" />
                        </div>
                        <div class="col-md-3">
                            <label for="employee_y1">Employees Year 3:</label>
                            <input type="number" id="employee_y3" class="form-control col-md-3" value="100" />
                        </div>
                        <div class="col-md-3">
                            <label for="employee_y1">Employees Year 4:</label>
                            <input type="number" id="employee_y4" class="form-control col-md-3" value="100" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <div class="col-md-12">
                            <button class="btn btn-primary ladda-button" id="genearate-report" data-style="expand-left" type="button" onclick="ExecutiveSummaryViewModel.generateClientReport()">Generate Report</button>
                            <button class="btn btn-primary ladda-button hidden" id="genearate-pdf" data-style="expand-left" type="button" onclick="ExecutiveSummaryViewModel.generateHtmlForPdf()">Generate Pdf</button>
                            <button class="btn btn-danger ladda-button hidden" id="reset-customizations-button" data-style="expand-left" type="button" onclick="ExecutiveSummaryViewModel.resetCustomizations()">Reset Customizations</button>
                        </div>
                    </div>
                </div>
            </form>
            <div id="main-sections" class="clientReport">
                <style type="text/css">
                    /*.clientReport {
                        padding: 25px;
                        display: none;
                    }*/

                    .bg-agenda {
                        background-image: url('../Assets/Img/agenda.png');
                        background-repeat: no-repeat;
                        background-position: right top;
                    }

                    .list-style {
                        list-style-type: square;
                    }

                    .panel {
                        background-color: #f5f5f5;
                        color: black !important;
                    }

                    .panel-heading {
                        margin-top: 0 !important;
                    }

                    .panel .panel-body {
                        background-color: white !important;
                    }

                        .font-weight-bold, .panel .panel-body table thead tr th {
                            font-weight: 700 !important;
                        }

                        .panel .panel-body table thead tr th {
                            color: white !important;
                        }

                    .align-middle {
                        vertical-align: middle !important;
                    }

                    #page-1 {
                        border: 1px solid gray !important;
                    }

                    #txtYear {
                        font-size: 28px !important;
                        width: 88px !important;
                        text-align: center;
                        color: white !important;
                        margin: 5px !important;
                        border-bottom: 1px solid !important;
                    }

                    .popover-title {
                        color: black !important;
                    }

                    #txtClientName {
                        font-size: 28px !important;
                        width: 97px !important;
                        color: white !important;
                        border: none;
                        border-bottom: 1px solid !important;
                    }

                    #txtRecoveryFacilitatorNames {
                        font-size: 23px !important;
                        width: 220px !important;
                        border: none;
                    }

                    #txtClientLeadName {
                        font-size: 23px !important;
                        width: 169px !important;
                        border: none;
                    }

                    ::placeholder {
                        color: black;
                        opacity: 1; /* Firefox */
                    }

                    :-ms-input-placeholder { /* Internet Explorer 10-11 */
                        color: black;
                    }

                    ::-ms-input-placeholder { /* Microsoft Edge */
                        color: black;
                    }

                    .section1-img {
                        width: 100% !important;
                    }

                    #page-1 .text-over-image {
                        position: absolute;
                        right: 25px;
                        top: 37%;
                    }

                    #page-1 .text-Presentedto {
                        position: absolute;
                        position: absolute;
                        right: 5%;
                        bottom: 13%;
                    }

                    #page-1 .text-over-image h2 {
                        color: white !important;
                    }

                    #page-1 .text-Presentedto h2 {
                        color: white !important;
                    }

                    #page-1 .container {
                        position: relative;
                        color: white;
                    }

                    .ui-datepicker .ui-datepicker-title {
                        color: azure !important;
                    }

                    .ui-datepicker .ui-datepicker-prev {
                        background-color: azure !important;
                    }

                    .ui-datepicker .ui-datepicker-next {
                        background-color: azure !important;
                    }

                    .color-box {
                        width: 10px;
                        height: 10px;
                        margin: 0 5px;
                    }

                    .blockquote-no-border > blockquote {
                        border-left: none;
                    }

                    .pie-chart-description > .panel {
                        background-color: #ffffff;
                    }
                </style>

                <%--section 1--%>
                <section id="page-1" class="pdf-page pb-2">
                    <div class="container">
                        <img src="<%= get_api%>/Images/ExecutiveSummary/Executive_Summary_Slide1_bg.jpg" style="width: 1450px; height: 920px" class="pdf-control" alt="Responsive image" />
                        <img src="<%= get_api%>/Images/ExecutiveSummary/Executive_Summary_Slide1_bg.jpg" class="img-fluid section1-img chartData" alt="Responsive image" />
                        <div class="text-over-image text-right">
                            <h1 class="text-uppercase">SHORT TERM DISABILITY</h1>
                            <h2>
                                <label class="pdf-control">
                                </label>
                                <span class="formInputBracket">[</span>
                                <a href="#" data-type="text" data-pk="1" data-url="/post" data-title="Year" id="txtYear" class="ui-control" controltype="TextBox"></a>
                                <span class="formInputBracket">]&nbsp</span>Annual Report
                            </h2>
                        </div>
                        <div class="col text-right text-Presentedto">
                            <h2>
                                <label class="pdf-control">
                                </label>
                                <span class="formInputBracket">[</span>
                                <a href="#" data-type="text" data-pk="2" data-url="/post" data-title="Name of Client" class="ui-control" id="txtClientName" controltype="TextBox"></a>
                                <span class="formInputBracket">]</span>
                            </h2>
                        </div>
                    </div>
                </section>
                <%-- / section 1--%>
                <%-- section 2--%>
                <section style="page-break-before: always" id="page-2" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-calendar"></i>&nbsp;Agenda</h4>
                            </div>
                            <div class="panel-body bg-agenda">
                                <div class="row">
                                    <div class="col-lg-5 p-5">
                                        <ul class="py-4">
                                            <li class="h3 mb-4">Introductions</li>
                                            <li class="h3 mb-4">Updates and Discussion</li>
                                            <li class="h3 mb-4">Annual Report</li>
                                            <p class="font-italic lead">- Executive Summary</p>
                                            <p class="mb-4 font-italic lead">- Trends</p>
                                            <li class="h3">OSI Updates/Developments</li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>

                                </div>

                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 2--%>
                <%-- section 3--%>
                <section style="page-break-before: always" id="page-3" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-users"></i>&nbsp;OSI Team</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-12 py-5 text-center mt-4 blockquote-no-border">
                                        <blockquote class="blockquote text-center mb-4">
                                            <p class="h3">
                                                <label class="pdf-control">
                                                </label>
                                                <span class="formInputBracket">[</span>
                                                <a href="#" data-type="text" data-pk="3" data-url="/post" data-title="name(s) of person(s)" id="txtRecoveryFacilitatorNames" class="ui-control" controltype="TextBox"></a>
                                                <span class="formInputBracket">]</span>
                                            </p>
                                            <footer><cite title="Source Title" class="text-dark font-italic lead">Recovery Facilitator</cite></footer>
                                        </blockquote>
                                        <blockquote class="blockquote text-center mb-4">
                                            <p class="h3">
                                                <label class="pdf-control">
                                                </label>
                                                <span class="formInputBracket">[</span>
                                                <a href="#" data-type="text" data-pk="4" data-url="/post" data-title="name of person" id="txtClientLeadName" class="ui-control" controltype="TextBox"></a>
                                                <span class="formInputBracket">]</span>
                                            </p>
                                            <footer><cite title="Source Title" class="text-dark font-italic lead">Client Lead</cite></footer>
                                        </blockquote>
                                        <blockquote class="blockquote text-center">
                                            <p class="h3">Liz Scott,</p>
                                            <footer><cite title="Source Title" class="text-dark font-italic lead">CEO / Principal</cite></footer>
                                        </blockquote>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-trashcan"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>

                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 3--%>
                <%-- section 4--%>
                <section style="page-break-before: always" id="page-4" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-file-zip"></i>&nbsp;Updates & Discussion</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-12 py-5 pft-h1">
                                        <div class="col-12 text-center py-5">
                                            <div class="h1 font-weight-bolder">Updates</div>
                                            <div class="h1  font-weight-bolder">&</div>
                                            <div class="h1 font-weight-bolder">Discussion</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-trashcan"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 4--%>
                <%-- section 5--%>
                <section style="page-break-before: always" id="page-5" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-clock"></i>&nbsp;Process</h4>
                            </div>
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-12 p-5">
                                        <ul class="py-5 list-style">
                                            <li class="h3 mb-5">Process review</li>
                                            <li class="h3 mb-5">Communications Review</li>
                                            <li class="h3 mb-5">Strengthening our Partnership</li>
                                            <li class="h3">Portal feedback</li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-trashcan"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>

                    </div>
                </section>
                <%-- / section 5--%>
                <%-- section 6--%>
                <section style="page-break-before: always" id="page-6" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-earth" aria-hidden="true"></i>&nbsp;Annual Report & Trends</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-12 py-5">
                                        <div class="col-12 text-center py-5">
                                            <div class="h1 font-weight-bolder">Annual Report</div>
                                            <div class="h1  font-weight-bolder">&</div>
                                            <div class="h1 font-weight-bolder">Trends</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-trashcan"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 6--%>
                <%-- section 7--%>
                <section style="page-break-before: always" id="page-7" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;Executive Summary</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-sm border">
                                                <thead>
                                                    <tr>
                                                        <th class="bg-primary text-white"></th>
                                                        <th class="text-center bg-primary text-white" id="pg7-col0-head"></th>
                                                        <th class="text-center bg-primary text-whiter" id="pg7-col1-head"></th>
                                                        <th class="text-center bg-primary text-white" id="pg7-col2-head"></th>
                                                        <th class="text-center bg-primary text-white" id="pg7-col3-head"></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td class="text-left">Total New STD Claims Referred to OSI </td>
                                                        <td id="pg7-r1-c0"></td>
                                                        <td id="pg7-r1-c1"></td>
                                                        <td id="pg7-r1-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r1-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="font-italic text-left">Total Cancelled Claims</td>
                                                        <td id="pg7-r2-c0"></td>
                                                        <td id="pg7-r2-c1"></td>
                                                        <td id="pg7-r2-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r2-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">STD Claims Incident Rate (Total STD claims /Total Eligible  Employees) <sup>(1)</sup> </td>
                                                        <td id="pg7-r3-c0"></td>
                                                        <td id="pg7-r3-c1"></td>
                                                        <td id="pg7-r3-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r3-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Total Non-Supported STD Claims</td>
                                                        <td id="pg7-r4-c0"></td>
                                                        <td id="pg7-r4-c1"></td>
                                                        <td id="pg7-r4-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r4-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Total Closed STD Claims </td>
                                                        <td id="pg7-r5-c0"></td>
                                                        <td id="pg7-r5-c1"></td>
                                                        <td id="pg7-r5-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r5-c3"></td>
                                                    </tr>
                                                    <tr class="bg-primary">
                                                        <td class="p-4"></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Transfers to LTD on Closed STD Claims </td>
                                                        <td id="pg7-r6-c0"></td>
                                                        <td id="pg7-r6-c1"></td>
                                                        <td id="pg7-r6-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r6-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">% Transfer to LTD on Closed STD Claims </td>
                                                        <td id="pg7-r7-c0"></td>
                                                        <td id="pg7-r7-c1"></td>
                                                        <td id="pg7-r7-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r7-c3"></td>
                                                    </tr>
                                                    <tr class="bg-primary">
                                                        <td class="p-2 bg-primary"></td>
                                                        <td class="bg-primary"></td>
                                                        <td class="bg-primary"></td>
                                                        <td class="bg-primary"></td>
                                                        <td class="bg-primary"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Total Days Lost (STD) <sup>(2)</sup></td>
                                                        <td id="pg7-r8-c0"></td>
                                                        <td id="pg7-r8-c1"></td>
                                                        <td id="pg7-r8-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r8-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Avg Duration on Days Lost on Closed STD Claims<sup>(1)(2)</sup> , Excluding LTD Transfers</td>
                                                        <td id="pg7-r9-c0"></td>
                                                        <td id="pg7-r9-c1"></td>
                                                        <td id="pg7-r9-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r9-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Avg Duration on Days Lost on Closed STD Claims<sup>(1)(2)</sup> , Including LTD Transfers</td>
                                                        <td id="pg7-r10-c0"></td>
                                                        <td id="pg7-r10-c1"></td>
                                                        <td id="pg7-r10-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r10-c3"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="text-left">Days Saved <span class="font-italic">(versus Disability Duration Guidelines) </span></td>
                                                        <td id="pg7-r11-c0"></td>
                                                        <td id="pg7-r11-c1"></td>
                                                        <td id="pg7-r11-c2"></td>
                                                        <td class="font-weight-bold" id="pg7-r11-c3"></td>
                                                    </tr>
                                                    <tr class="bg-primary">
                                                        <td class="p-2"></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                            <p class="small font-italic text-left">
                                                (1) Excludes Cancelled Claims
                                    
                                        (2) In Calendar Days
                                            </p>
                                            <p class="small font-italic text-left">
                                                <span class="pr-5">Total Employees <span id="pg7-y3"></span>:  <span id="pg7-emp-y3"></span></span><span class="pl-5">&nbsp;Total Employees <span id="pg7-y2"></span>:  <span id="pg7-emp-y2"></span></span>

                                                <span class="pr-5">&nbsp;Total Employees <span id="pg7-y1"></span>:  <span id="pg7-emp-y1"></span></span><span class="pl-5">&nbsp;Total Employees <span id="pg7-y0"></span>: <span id="pg7-emp-y0"></span></span>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-delete"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 7--%>
                <%-- section 8--%>
                <section style="page-break-before: always" id="page-8" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;OSI Benchmarking</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table class="table table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th class="align-middle h4 font-weight-bold border-bottom-0 text-center bg-primary text-white">Benchmarking</th>
                                                        <th class="border-bottom-0 text-center bg-primary text-white">OSI                                            
                                                            <div class="border">BOOK OF BUSINESS</div>
                                                            <div><small id="pg8-c0-head"></small></div>
                                                        </th>
                                                        <th class="border-bottom-0 text-center bg-primary text-white">
                                                            <div class="border">ERICSSON</div>
                                                            <div><small id="pg8-c1-head"></small></div>
                                                        </th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td class="p-4 bg-primary text-white">Incident Rates</td>
                                                        <td id="pg8-r0-c0" class="p-4"></td>
                                                        <td id="pg8-r0-c1" class="font-weight-bold p-4"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class=" bg-primary text-white">Average Durations
                                                <div><small>(Excluding LTD Claims)</small></div>
                                                        </td>
                                                        <td id="pg8-r1-c0" class="align-middle"></td>
                                                        <td id="pg8-r1-c1" class="align-middle font-weight-bold"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="p-4 bg-primary text-white">Return to Work Outcomes</td>
                                                        <td id="pg8-r2-c0" class="p-4"></td>
                                                        <td id="pg8-r2-c1" class="font-weight-bold p-4"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="p-4 bg-primary text-white">% STD Claims Transferred to LTD</td>
                                                        <td id="pg8-r3-c0" class="p-4"></td>
                                                        <td id="pg8-r3-c1" class="font-weight-bold p-4"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="bg-primary text-white">Decision Turnaround Time following Initial APS
                                                 <div><small>(2 to 4 business days)</small></div>
                                                        </td>
                                                        <td id="pg8-r4-c0" class="align-middle"></td>
                                                        <td id="pg8-r4-c1" class="align-middle font-weight-bold"></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="align-middle bg-primary text-white">Highest Claim Medical Categories</td>
                                                        <td id="pg8-r5-c0"></td>
                                                        <td id="pg8-r5-c1" class="font-weight-bold"></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-delete"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 8--%>
                <%-- section 9--%>
                <section style="page-break-before: always" id="page-9" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-stats-bars2" aria-hidden="true"></i>&nbsp;New STD Referrals- By Month</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsByMonth" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5" id="referralByMonthClaimsDescription">
                                        <div class="table-responsive">
                                            <table id="newStdReferralsTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right web-only">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 9--%>
                <%-- section 10--%>

                <section style="page-break-before: always" id="page-10" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;STD Claims - By Site</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-sm table-bordered" id="claimsBySite">
                                                <thead>
                                                    <tr>
                                                        <th class="align-middle bg-primary text-white text-center">Sites</th>
                                                        <th class="align-middle bg-primary  text-white text-center" id="pg10-c1-head"></th>
                                                        <th class="align-middle bg-primary  text-white text-center" id="pg10-c2-head"></th>
                                                        <th class="align-middle bg-primary  text-white text-center" id="pg10-c3-head"></th>
                                                        <th class="align-middle bg-primary  text-white text-center" id="pg10-c4-head"></th>
                                                        <th class="align-middle bg-primary  text-white text-center" id="pg10-c5-head"></th>
                                                        <th class="align-middle bg-primary  text-white text-center" id="pg10-c6-head"></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide" controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- section 11--%>
                <section style="page-break-before: always" id="page-11" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;STD Claims - By Province</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table class="table table-striped table-sm table-bordered" id="claimsByProvince">
                                                <thead>
                                                    <tr>
                                                        <th class="bg-primary text-white text-center">Province</th>
                                                        <th class="bg-primary  text-white text-center" id="pg11-c0-head"></th>
                                                        <th class="bg-primary  text-white text-center" id="pg11-c1-head"></th>
                                                        <th class="bg-primary  text-white text-center" id="pg11-c2-head"></th>
                                                        <th class="bg-primary  text-white text-center" id="pg11-c3-head"></th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide" controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 11--%>
                <%-- section 12--%>
                <section style="page-break-before: always" id="page-12" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-stats-bars2" aria-hidden="true"></i>&nbsp;STD Claims: By Gender & Age</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsByGenderAndAge" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5" id="ageAndGenderClaimsDescription">
                                        <div class="table-responsive">
                                            <table id="newStdClaimsByGenderAndAgeTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 12--%>
                <%-- section 13--%>
                <section style="page-break-before: always" id="page-13" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;New STD Claims - Gender, Year Over Year + Age, Year Over Year</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table id="newClaimsByGenderAndYearTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table id="newClaimsByAgeGroupAndYearTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 13--%>
                <%-- section 14--%>
                <section style="page-break-before: always" id="page-14" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-stats-bars2 " aria-hidden="true"></i>&nbsp;STD Claims - By Seniority (Yrs)</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsBySeniority" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5" id="seniorityClaimsDescription">
                                        <div class="table-responsive">
                                            <table id="stdClaimsBySeniorityTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 14--%>
                <%-- section 15--%>
                <section style="page-break-before: always" id="page-15" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-pie-chart " aria-hidden="true"></i>&nbsp;New STD Claims - By Medical Condition</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsByMedicalCondition" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5 pie-chart-description" id="newMedicalClaimsDescription">
                                        <div class="panel panel-default text-center">
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 15--%>
                <%-- section 16--%>
                <section style="page-break-before: always" id="page-16" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;STD Claims by Medical Condition: Year-over-Year</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <div class="font-weight-bold bg-primary text-center p-2 text-white">Medical Conditions</div>
                                            <table id="claimsByMedicalConditionYearOverYearTable" class="table table-striped table-sm table-bordered" id="claimsByMedicalConditionForTable">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 16--%>
                <%-- section 17--%>
                <section style="page-break-before: always" id="page-17" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-pie-chart " aria-hidden="true"></i>&nbsp;New Mental Health STD Claims - By Diagnosis</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="mentalClaimsByDiagnosis" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5" id="mentalHealthClaimsDescription">
                                        <div class="panel panel-default text-center">
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- section 18--%>
                <section style="page-break-before: always" id="page-18" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-pie-chart" aria-hidden="true"></i>&nbsp;New Musculoskeletal STD Claims - By Diagnosis</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="musculoskeletalClaimsByDiagnosis" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5 pie-chart-description" id="musculoskeletalStdClaimsDescription">
                                        <div class="panel panel-default text-center">
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide" controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 18--%>
                <%-- section 19--%>
                <section style="page-break-before: always" id="page-19" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;Medical Conditions Analysis</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <div class="font-weight-bold bg-primary text-center p-2 text-white">Injury / Illness Category Analysis (On Closed Claims in Period)</div>
                                            <table id="medicalConditionsAnalysisTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                    <tr>
                                                        <th class="bg-primary text-white text-left align-middle">InjCat </th>
                                                        <th class="bg-primary  text-white align-middle text-center"># Closed Claims</th>
                                                        <th class="bg-primary  text-white text-center">Total Days Lost
                                                <div>(Based on Authorized Periods)</div>
                                                        </th>
                                                        <th class="bg-primary  text-white text-center">Avg Duration
                                                <div>(Calendar Days)</div>
                                                        </th>
                                                        <th class="bg-primary  text-white align-middle text-center">2018 LTD Transfers</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 19--%>
                <%-- section 20--%>
                <section style="page-break-before: always" id="page-20" class="pdf-page pageBreak">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-pie-chart" aria-hidden="true"></i>&nbsp;New STD Claims - By Closure Reasons</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsByClosureResearch" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5 pie-chart-description" id="closureReasonClaimsDescription">
                                        <div class="panel panel-default text-center p-2">
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide" controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 20--%>
                <%-- section 21--%>
                <section style="page-break-before: always" id="page-21" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-table2" aria-hidden="true"></i>&nbsp;STD Claims by Closure Reasons- Year-Over-Year</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div class="table-responsive">
                                            <table id="claimsByClosureReasonYearOverYearTable" class="table table-striped table-sm table-bordered" id="claimsByClosureReasonTable">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 21--%>
                <%-- section 22--%>
                <section style="page-break-before: always" id="page-22" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-stats-bars2" aria-hidden="true"></i>&nbsp;Closed STD Claims - TDO vs DDG</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsTdoVsDdgChart" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 22--%>
                <%-- section 23--%>
                <section style="page-break-before: always" id="page-23" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-stats-bars2" aria-hidden="true"></i>&nbsp;New STD Claims - Lag Time to Referral (Days)</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsLagToReferralTimeChart" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5" id="lagReferralTimeClaimsDescription">
                                        <div class="table-responsive">
                                            <table id="stdClaimsLagTimeToReferralTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide " controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 23--%>
                <%-- section 24--%>
                <section style="page-break-before: always" id="page-24" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="icon icon-stats-bars2" aria-hidden="true"></i>&nbsp;New STD Claims - Lag Time to APS (Days)</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 p-5">
                                        <div id="claimsLagToApsTimeChart" class="chartData"></div>
                                        <img src="" class="pdf-control" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 mb-3 px-5" id="lagApsTimeClaimsDescription">
                                        <div class="table-responsive">
                                            <table id="stdClaimsLagTimeToApsTable" class="table table-striped table-sm table-bordered">
                                                <thead>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>

                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide" controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 24--%>
                <%-- section 25--%>
                <section style="page-break-before: always" id="page-25" class="pdf-page">
                    <div class="container">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4><i class="fa fa-handshake" aria-hidden="true"></i>&nbsp;Thank you</h4>
                            </div>
                            <div class="panel-body text-center">
                                <div class="row">
                                    <div class="col-lg-10 col-md-offset-1 text-center py-5 my-5">
                                        <div class="h1 font-weight-bolder">Thank you</div>
                                    </div>
                                </div>
                                <div class="row p-3 text-right">
                                    <button class="btn btn-warning float-right ml-2 ui-control" onclick="ExecutiveSummaryViewModel.removeSlide(this)" title="Delete Slide" controltype="Slide"><span class="icon icon-bin"></span></button>
                                    <button class="btn btn-primary float-right ui-control ladda-button" data-style="expand-left" onclick="ExecutiveSummaryViewModel.addSlide(this)" title="Add New Slide" controltype="Slide"><span class="icon icon-plus"></span></button>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
                <%-- / section 25--%>
            </div>
        </div>
        <%--</div>--%>
    </div>
    <%-- </form>--%>
</asp:Content>

<asp:Content ID="Content_Footer" ContentPlaceHolderID="Footer" runat="server">
    <script src="../Assets/bs/bootstrap.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.9.2/jquery-ui.min.js" type="text/javascript"></script>
    <script src="https://malsup.github.io/jquery.blockUI.js" type="text/javascript"></script>
    <script src="../Assets/x-editable/js/bootstrap-editable.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-mockjax/1.6.2/jquery.mockjax.js"></script>
    <script src="../Assets/ckeditor/ckeditor.js"></script>
    <script src="../Assets/toastr/toastr.min.js"></script>
    <script src="../Assets/js/common.js"></script>
    <script src="../Assets/view_js/ExecutiveSummaryViewModel.js?v=4"></script>

    <script>
        $(document).ready(function () {
            ExecutiveSummaryViewModel.InitializeView('<%= get_api%>', '<%=token %>');
        });
    </script>
</asp:Content>
