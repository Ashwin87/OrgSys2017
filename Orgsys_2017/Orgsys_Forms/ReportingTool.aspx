<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="ReportingTool.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.ReportTool" %>

<asp:Content ID="Content_head" ContentPlaceHolderID="Head" runat="server">
    <!-- Created By   : Marie Gougeon
         Create Date  : 2018-11-12
         Description  : Reporting Tool -->
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/common/Reporting.js"></script>
    <script> 
        var getApi = window.getApi = "<%= Orgsys_2017.Orgsys_Classes.OSI_Page.get_api%>";
        var Token = window.Token = "<%= Orgsys_2017.Orgsys_Classes.OSI_Page.token%>";
    </script>
    <script src="/Assets/js/orgsysNavbar.js"></script>

</asp:Content>
<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mx-3">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading welcome-container narrow-container">
                <h4 id="welcome-header" class="welcome-header">Reporting Tool</h4>
            </div>
            <div id="logo-container" class="osp-heading panel-heading welcome-container narrow-container"></div>
            <%--<ul class="nav navbar-nav navbar-right language_setter">
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

        <div class="panel panel-body panel-body-bordered narrow-container">
            <div id="form-content" class="tab-content">
                <div class="row margin_bottom">
                    <div class="col-md-3">
                        <label for="ddl_report" id="lblSelectReport">Select Report:</label>
                        <select id="ddl_report" class="form-control col-md-3" name="selectReport" data-id="selectReport">           
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="selectService" id="lblSelectService">Select Service:</label>
                        <select id="selectService" class="form-control col-md-3" name="selectService" data-id="selectService">
                            <option value="0">--Select--</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="fromdate" id="lblFromDate">Date From:</label>
                        <input id="fromdate" type="date" class="form-control col-md-3" name="fromdate" data-id="fromdate" />
                    </div>
                    <div class="col-md-3">
                        <label for="todate" id="lblDateTo">Date To:</label>
                        <input id="todate" type="date" class="form-control col-md-3" name="todate" data-id="todate" />
                    </div>
                </div>
                <div class="row margin_bottom">
                    <div class="col-md-12">
                        <input id="btn_createReport" type="submit" class="btn btn-primary" value="Create Report" />
                        <input id="btn_download" type="submit" class="btn btn-primary" value="Download" />
                        <input id="btn_saveChart" type="submit" class="btn btn-primary" value="Save Chart Image" />
                    </div>
                </div>
                <div id="canvasContainer" style="width:100%; height:500px" class="row margin_bottom">
                    <canvas id="myChart"></canvas>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

