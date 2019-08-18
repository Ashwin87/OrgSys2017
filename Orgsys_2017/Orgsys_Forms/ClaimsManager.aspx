<%@ Page Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="ClaimsManager.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.ClaimsManager" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/common/DTUtilities.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="Internal_Forms/JSFiles/DataBind.js"></script>
    <script src="Internal_Forms/JSFiles/UserAssignment.js"></script>    
    <script>
        /*Created By     : Aaron St Germain
          Created Date   : 2018-04-06
          Update Date    : 2018-04-06 - Aaron
          Description    : Claims Manager*/
        window.getApi = "<%= get_api %>";
        var token = '<%= token %>';
        var ActiveUserID = 0;

        $.ajax({
            url: "<%= get_api%>/api/DataManagement/GetUserIDSession/" + token,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            success: function (data) {
                ActiveUserID = JSON.parse(data)[0].UserID;
            }
        });

        $(document).ready(function () {
            //set the ClientID window var /
            GetDataGeneric('Client', 'GetClientDetails', token).then(function (client) {
                window.ClientID = client[0].ClientID;
            });

            var openClaims, openClaimsByClient, closedClaims;//json results for open claims and closed claims
            var openTable, openByClientTable, closedTable;//DataTables to visualize the data from the claims

            //event handler for switching tabs to open/closed claims. Makes sure to only load once on each switch
            $("a[data-toggle='tab']").click(function () {
                var tableDiv = $(this).attr("href");
                //Loads open claims and creates a datatable to display to the user
                if (tableDiv == "#openClaims" && openClaims == null) {
                    openClaims = getTableData(true, false);
                    openTable = createDataTable($(tableDiv).find("table"), openClaims, 1);
                }//Loads open claims that belongs to a client
                if (tableDiv == "#openClaimsAssignedToClient" && openClaimsByClient == null) {
                    openClaimsByClient = getTableData(true, true);
                    openByClientTable = createDataTable($(tableDiv).find("table"), openClaimsByClient, 1);
                }
                //loads closed claims and creats a datatable to display to the user.
                if (tableDiv == "#closedClaims" && closedClaims == null) {
                    closedClaims = getTableData(false, true);
                    closedTable = createDataTable($(tableDiv).find("table"), closedClaims, 0);
                }
                //Deselects row when switching tab
                if (openClaims != null && closedClaims != null) {
                    openTable.rows('.selected').deselect();
                    openByClientTable.rows('.selected').deselect();
                    closedTable.rows('.selected').deselect();
                }
                //Toggles bootstrap tool tips for clarity on the functionality for the user
                $('[data-toggle="tooltip"]').tooltip();
                MaskInputs();
            });
            $("a[href='#openClaims']").trigger("click");//Initialize open claims on document ready


            //Delegated event handler for viewing dynamically created links to a specific claim
            $(".tab-content").on("click", ".viewClaim",function () {
                var ClaimReferenceNumber = $(this).attr("data-ClaimRefNu");
                var ClientName = $(this).attr("data-ClientName");
                var ClaimLink = $(this).attr("data-ClaimLink");

                   swal({
                    title: "View Claim - #" + ClaimReferenceNumber,
                    text: ClientName,
                    type: "info",
                    showCancelButton: true,
                    confirmButtonClass: "btn-success",
                    confirmButtonText: "View",
                    cancelButtonText: 'Close',
                    reverseButtons: true
                }).then(function (result) {
                     redirectToClaim(ClaimLink);
                });
            });

            function redirectToClaim(ClaimLink) {
                setTimeout(function(){ window.location.href = ClaimLink;}, 1000);
            }
     



                 
            

            //Delegated event handler for editing a user assigned to a specific claim.
            $(document).on("click", ".editUser", function () {
                var claimData = {
                    claimRefNu : $(this).attr("data-claimrefnu"),
                    claimID : $(this).attr("data-claimid"),
                    clientID : $(this).attr("data-ClientID"),
                    UserAssignedID : $(this).attr("data-userassignedid")
                }

                EditClaimUsersSwal(claimData);
                $('[data-toggle="tooltip"]').tooltip();
            });

            //Removes a user from the datatable
            $(document).on("click", ".removeUser", function () {
                var data = {
                    userAssignedToClaim : $(this).attr("data-userassigned"),
                    UserAssignedID: $(this).attr("data-userassignedid"),
                    tableRow: $(this).closest('tr')
                }                

                RemoveClaimUserSwal(data, "#searchUserDataTable")
            });

            //creates a datatable based on data given as a parameter
            function createDataTable(tableSelector, results, openOrClosed) {
                var table = tableSelector.DataTable({
                    data: results,
                    "sPaginationType": "full_numbers",
                    "columns": [
                        {
                            "data": null,
                            render: function (data, type, row) {
                                return `<a  data-ClientName='${data.ClientName}' 
                                            data-ClaimRefNu='${data.ClaimRefNu}' 
                                            data-ClaimLink='/OrgSys_Forms/Internal_Forms/WC.aspx?ClaimID=${data.ClaimID}&ClientID=${data.ClientID}' 
                                            type='button'
                                            class='viewClaim btn btn-default view_description'
                                            width='5px'
                                            data-toggle='tooltip'
                                            title='View Claim'>
                                                <i class='icon icon-eye'></i>
                                        </a>
                                        <a  data-ClientName='${data.ClientName}' 
                                            data-userassignedid='${data.UserAssignedID}' 
                                            data-claimid='${data.ClaimID}' 
                                            data-ClaimRefNu='${data.ClaimRefNu}' 
                                            data-ClientID='${data.ClientID}' 
                                            type='button'
                                            class='editUser edit_button btn btn-default ${openOrClosed ? '' : 'hidden'}' 
                                            width='5px'
                                            data-toggle='tooltip'
                                            title='Edit users assigned to this claim'>
                                                <i class='icon icon-pencil'></i>
                                        </a>`;
                            }
                        },
                        {
                            "data": null, render: function (data, type, row) {
                                return data.EmpFirstName + ' ' + data.EmpLastName;
                            }
                        },
                        { "data": "ClaimRefNu" },
                        {
                            "data": "DateFirstOff",
                            "render":
                                function(data, type, row) {
                                    if (type === 'display' || type === 'filter') {
                                        return ConvertDateIsoToCustom(data);
                                        
                                    } else {
                                        return data;
                                    }
                                }
                        },
                        {
                            "data": "DateCreation",
                            "render":function(data, type, row) {
                                if (type === 'display' || type === 'filter') {
                                    return ConvertDateIsoToCustom(data);
                                        
                                } else {
                                    return data;
                                }
                            }
                        },
                        {
                            "data": "HomePhone",
                            "render": function(data) {
                                return `<span class="vld-phone">${data}</span>`
                            }
                        },
                        { "data": "ClientName" },
                         { "data": "userlist" }
                    ]
                });

                return table;
            }
            
            //Gets claims based on valid token value and whether the claims are open or closed.
            function getTableData(OpenOrClosed, UserOrClient) {
                var results;
                $.ajax({
                    url: `<%= get_api %>/api/Claim/GetClaims/${token}/${OpenOrClosed}/${UserOrClient}`,
                      beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                        results = ReplaceDFValues(JSON.parse(data));
                    }
                });
                return results;
            }
            
        });//End DocReady
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper">
    <div id="banner-container" class="osp-heading panel-heading narrow-container">
        <div id="welcome-container" class="osp-heading panel-heading">
           <h4 id="welcome-header" class="osp-heading panel-heading">Claims</h4>
        </div>
        <div id="logo-container" class="osp-heading panel-heading"></div>
    </div>
    <div class="main-wrapper claim_manager" style="height: 570px!important;">
        <!-- TABLES SHOW & EDIT TASKS -->
        <div id="tabs">
            <ul class="nav nav-tabs claim_manager_header">
                <li class="active claim_manager_li" id="openClaimsTab">
                    <a data-toggle="tab" href="#openClaims">Open Claims Assigned To Me</a>
                </li>
                <li id="openClaimsAssignedToClientTab" class="claim_manager_li">
                    <a data-toggle="tab" href="#openClaimsAssignedToClient">Open Claims By Clients</a>
                </li>
                <li id="ClosedClaimsTab" class="claim_manager_li">
                    <a data-toggle="tab" href="#closedClaims">Closed Claims</a>
                </li>
            </ul>
        </div>
        <div class="tab-content claim_manager_container">
            <div id="openClaims" class="tab-pane fade in active">
                <div class="panel panel-default" style="border-top: 0px;">
                    <%--<div class="panel-heading">
                        <div class="row">
                            <div class="col col-xs-6">
                                <h3 class="panel-title">Open Claims</h3>
                            </div>
                        </div>
                    </div>--%>
                    <div class="panel-body">
                        <table id="openTable" class="table table-bordered table-striped table-hover">
                            <thead>
                                <tr>
                                    <th>Actions</th>
                                    <th>Employee Name</th>
                                    <th>Claim Reference Number</th>
                                    <th>Date First Off</th>
                                    <th>Date Created</th> 
                                    <th>Home Phone</th> 
                                    <th>Client Name</th>
                                    <th>OSI Contacts</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div id="openClaimsAssignedToClient" class="tab-pane fade in">
                <div class="panel panel-default" style="border-top: 0px;">
                    <%--<div class="panel-heading">
                        <div class="row">
                            <div class="col col-xs-6">
                                <h3 class="panel-title">Open Claims Assigned To My Clients</h3>
                            </div>
                        </div>
                    </div>--%>
                    <div class="panel-body">
                        <table id="openByClientTable" class="table table-bordered table-striped table-hover" style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>Actions</th>
                                    <th>Employee Name</th>
                                    <th>Claim Reference Number</th>
                                    <th>Date First Off</th>
                                    <th>Date Created</th>
                                    <th>Home Phone</th>
                                    <th>Client Name</th>
                                    <th>OSI Contacts</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div id="closedClaims" class="tab-pane fade in">
                <div class="panel panel-default" style="border-top: 0px;">
                    <%--<div class="panel-heading">
                        <div class="row">
                            <div class="col col-xs-6">
                                <h3 class="panel-title">Closed Claims</h3>
                            </div>
                        </div> 
                    </div>--%>
                    <div class="panel-body">
                        <table id="closedTable" class="table table-bordered table-striped table-hover" style="width: 100% !important;">
                            <thead>
                                <tr>
                                    <th>Actions</th>
                                    <th>Employee Name</th>
                                    <th>Claim Reference Number</th>
                                    <th>Date First Off</th>
                                    <th>Date Created</th>
                                    <th>Home Phone</th>
                                    <th>Client Name</th>
                                    <th>OSI Contacts</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        </div>
    </div>
</asp:Content>
