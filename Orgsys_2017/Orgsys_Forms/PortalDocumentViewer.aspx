<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="PortalDocumentViewer.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.PortalDocumentViewer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(document).ready(function () {
            window._token = '<%= Orgsys_2017.Orgsys_Classes.OSI_Page.token %>';
            window._api = '<%= Orgsys_2017.Orgsys_Classes.OSI_Page.get_api %>';
        });
    </script>
    <script src="/Assets/js/moment.js"></script>
    <script src="/Assets/js/datetime-moment.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <!--<script src="/Scripts/build/documentviewer.bundle.js"></script>-->
    <script src="Generic_Forms/JSFilesExternal/DocumentViewer.js"></script>
    <script src="/Assets/js/orgsysNavbar.js"></script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div id="banner-container" class="osp-heading panel-heading banner-container">
            <div class="row">
                <div id="welcome-container" class="osp-heading panel-heading welcome-container narrow-container">
                    <h4 id="welcome-header" class="welcome-header">Document Manager</h4>
                </div>
                <div id="logo-container" class="osp-heading panel-heading"></div>
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
        </div>
        <div class="spacer"></div>

    <div class="panel panel-body narrow-container">
       <form id="search-documents-form" class="">
            <div class="input-group">
                <input id="#search-documents-input" type="text" class="form-control" style="width:350px;" placeholder="Search for..."/>
                <%--<span class="input-group-btn">
                    <button class="btn btn-default" type="submit">Search Documents</button>
                </span>--%>
            </div>
        </form>
<%--        <button id="download-documents-link" class="btn btn-default navbar-btn col-md-1 disabled" type="button">Download</button>--%>
        <table id="documents-table" class="table table-bordered table-striped table-hover document_manager_table">
            <thead>
                <tr id="tDefDocuments-table">
                    <th>Actions</th>
                    <th>Uploaded By</th>
                    <th>Claim #</th>
                    <th>File Name</th>
                    <th>Date Created</th>
                    <th>Document Description</th>
                    <th>File Extension</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
</div>
</asp:Content>
