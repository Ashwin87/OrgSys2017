<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="PortalLibrary.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.PortalLibrary" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <script src="JSFilesExternal/PortalLibrary.js"></script>
</asp:Content>
<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mx-3">
        <div id="banner-container" class="osp-heading panel-heading banner-container">
            <div id="welcome-container" class="osp-heading panel-heading welcome-container narrow-container">
                <h4 id="welcome-header" class="welcome-header">Portal Library</h4>
            </div>
            <div id="logo-container" class="osp-heading panel-heading welcome-container narrow-container"></div>
        </div>
        <div class="spacer"></div>

        <div class="panel panel-body panel-body-bordered narrow-container">
            <div class="row">
                <div class="portal_library_form_setter">
                    <label for="library-type-select" id="lbllibrary-type-select">Select the document type: </label>
                    <select id="library-type-select"></select>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 col-lg-12 col-sm-12">
                    <table style="width: 100%;" id="LibraryResources" class="table table-bordered table-striped table-hover dataTable no-footer">
                        <thead>
                            <tr>
                                <th style="width: 20px">Download</th>
                                <th style="width: 20px">Name</th>
                                <th style="width: 20px">Version</th>
                                <th style="width: 10px">Type</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
