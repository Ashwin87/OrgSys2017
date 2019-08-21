<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="ClientProfile.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.ClientProfile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/common/OrgsysUtilities.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="JSFiles/ClientProfile.js"></script>
    <script src="JSFiles/DataBind.js"></script>
    <script src="/Assets/js/select2.min.js"></script>
    <link href="/Assets/css/select2.min.css" rel="stylesheet" type="text/css"/>
    <link href="/Assets/css/select2-bootstrap.css" rel="stylesheet" type="text/css"/>

    <script>
        $(function () {
            window.api = "<%= get_api %>";
            window.getApi = window.api;
            window.token = "<%= token %>";
            GetClientProfilesJX()
                .then(function (profiles) {
                    //DATATABLE INITIALIZATION
                    window.ClientDetailsDT = $('#ClientDetails > table').DataTable({
                        data: profiles,
                        searching: true,
                        pageLength: 10,
                        paging:true,
                        columns: [
                            {
                                data: null,
                                render: function (data, type, row) {
                                    //the input tag is not visible
                                    var html = '<input id="UploadLogo" class="hidden-file" type="file" />';
                                    var buttons = $(`<div>
                                            <a class="edit-client view_description btn btn-default" title="Edit Client"><i class="icon icon-edit1"></i></a>
                                            <a class="view-contacts view_description" title="View Client Contacts"><i class="icon icon-eye"></i></a>
                                            <a for="UploadLogo" class="add-clientlogo view_description" title="Add/Update Logo"><i class="icon icon-picture"></i></a>
                                            <a class="Library-Resources view_description" title="Library Resources / Packages"><i class="glyphicon glyphicon-folder-open"></i></a>
                                        <div>`).find('a, label');

                                    buttons.addClass('btn btn-default');
                                    buttons.attr('data-toggle', 'tooltip')
                                    buttons.each(function () {
                                        html += $(this).get(0).outerHTML;
                                    });
                                    return html;
                                }
                            },
                            { data: 'ClientName' },
                            { data: 'TradeLegalName' },
                            { data: 'BusCountry' },
                            { data: 'BusCity' },
                            { data: 'BusProvince' },
                            { data: 'BusMailingAddress' },
                            { data: 'BusPostal' },
                            {
                                data: 'BusTelephone',
                                render: function (data) {
                                    return '<span class="vld-phone">' + data + '</span>'
                                }
                            },
                            {
                                data: 'BusFax',
                                render: function (data) {
                                    return '<span class="vld-phone">' + data + '</span>'
                                }
                            },
                            { data: 'BusActivityDescr' },
                            {
                                data: '_20MoreWorkers',
                                render: function (data, type, row) {
                                    return (data) ? 'Yes' : 'No';
                                }
                            },
                            {
                                data: 'IsActive',
                                render: function (data) {
                                    return (data == null || data == false) ? 'No' : 'Yes';
                                }
                            },
                            { data: 'ClientStartDate' }
                        ]

                    });     
                    MaskInputs();
                    //ATTACH BUTTON EVENT HANDLERS  
                    $('.add-client').on('click', function () {
                        AddClient();
                    });
                    AttachClientActionHandlers();
                    $('[data-toggle="tooltip"]').tooltip()
                });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper">
    <div id="banner-container" class="osp-heading panel-heading narrow-container">
        <div id="welcome-container" class="osp-heading panel-heading">
           <h4 id="welcome-header" class="osp-heading panel-heading">Client Profile</h4>
        </div>
        <div id="logo-container" class="osp-heading panel-heading"></div>
    </div>
    <div id="ClientProfileMain"> 
        <!--
        <ul class="nav nav-tabs" role="tablist">
            <li class="nav-item active"><a data-toggle="tab" role="tab" href="#ClientDetails">Client Details</a></li>
        </ul>
        -->
       <div id="ClientDetails" class="tab-pane active" role="tabpanel">
           <div>
               <button type="button" class="btn btn-default add-client">
                    <i class="icon-plus"></i>
                </button>
           </div>
           <table id="ClientDetailsTable" class="table table-bordered table-striped table-hover dataTable no-footer client_profile_table">
               <thead>
                   <tr>
                       <th class="client_profile_header">Actions</th>
                       <th class="client_profile_header">Client Name</th>
                       <th class="client_profile_header">Trade / Legal Name</th>
                       <th class="client_profile_header">Country</th>
                       <th class="client_profile_header">City</th>
                       <th class="client_profile_header">Province / State</th>
                       <th class="client_profile_header">Mailing Address</th>
                       <th class="client_profile_header">Postal Code</th>
                       <th class="client_profile_header">Phone</th>
                       <th class="client_profile_header">Fax</th>
                       <th class="client_profile_header">Activity Description</th>
                       <th class="client_profile_header">Has 20 Or More Workers</th>
                       <th class="client_profile_header">Active</th>
                       <th class="client_profile_header">Start Date</th>
                    </tr>
               </thead>
               <tbody>
               </tbody>
           </table>
       </div>
        </div>
    </div>
</asp:Content>
