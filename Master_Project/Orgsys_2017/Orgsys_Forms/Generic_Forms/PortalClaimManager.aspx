<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="PortalClaimManager.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.PortalClaimManager" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="../../Assets/css/PortalClaimManager.css"/>
    <script src="/Assets/js/promise-polyfill.js"></script>
    <script src="/Assets/js/moment.js"></script>
    <script src="/Assets/js/datetime-moment.js"></script>
    <script src="/Assets/js/orgsysNavbar.js"></script>

    <script>
        $(function () {
            // PCM  = PortalClaimManager

            var token = "<%= token%>";
            var claimFields;
            var claimFieldsGrouped;
            window.DTConfig = [];
            var refresh = true; //determines if a refresh is required
            var claimTypeMap;

            $.ajax({
                url: "<%= get_api %>/api/Claim/GetClaimTypeID_FormID",

                beforeSend: function (request) {
                    request.setRequestHeader("Authentication", window.token);
                },
                async: false,
                type: 'GET',
                success: function (data) {
                    claimTypeMap = JSON.parse(data);
                }
            });

            if (refresh) {

                InitializeTable('#OpenClaimsTable');
                InitializeTable('#ClosedClaimsTable');
                //InitializeTable('#DraftClaimsTable');
                refresh = false;

            }

            //enables sorting of the passed date format
            $.fn.dataTable.moment('DD-MMM-YYYY');

            function InitializeTable(selector) {

                var table = $(selector);
                var tableId = table.attr('id');
                var statusString = selector.replace('ClaimsTable', '').slice(1).toLowerCase(); //(open)ClaimsTable, (closed)ClaimsTable, (draft)ClaimsTable
                var draft = statusString == 'draft';

                $.ajax({
                    type: "GET",
                    beforeSend: function (xhr) {
                        xhr.setRequestHeader('Language', window.Language);
                        xhr.setRequestHeader('Authentication', window.token);
                    },
                    async: false,
                    url: "<%= get_api%>/api/Dynamic/DataViewV2/" + token + "/Claim"

                }).then(function (data) {

                        claimFields = JSON.parse(data);
                        claimFields = claimFields.filter(function (column) {
                            return column.IsPresented === true;
                        });
                        claimFieldsGrouped = GroupByProperty(claimFields, "GroupID");
                        DTConfig = BuildDTConfig(claimFieldsGrouped);

                        return claimFields;

                    })
                    .then(function (data) {
                        getPCMData(statusString, data)
                            .then(function (claimData) {
                                //initialize and populate a table with data
                                PopulatePCMTable(tableId, claimData, draft);
                                //append a div for the preferences section to appear in
                                AppendPreferenceSection(tableId, tableId);
                                //set the column visibility from the db initially, held in DTConfig
                                SetColumnVisibility(tableId, DTConfig);

                                //move export buttons to header; keeps consistent ux
                                var exButtons = table.DataTable().buttons().container().find('a').addClass('exp-btn-' + tableId);
                                exButtons.insertBefore('.action-buttons > *:first').hide();

                                //will show appropriate buttons
                                $('.exp-btn-OpenClaimsTable').show();
                            })
                            .then(function () {

                                //listens for column reorder event and updates [DTConfig] when fired
                                table.DataTable().on('column-reorder', function (e, settings, details) {
                                    var id = GetActivePanelId();
                                    UpdateColumnOrder($(this).attr('id'));
                                    $('#' + id + ' .dt-pref-btns').show();
                                });

                                $('[data-toggle="tooltip"]').tooltip();

                            });
                    });

            }

            $('a[data-toggle="tab"]').click(function () {
                //if table preferences changed, this flag would be true
                if (refresh) {
                    var tableDivId = $(this).attr('href');
                    InitializeTable(tableDivId + 'Table');
                }

            });

            /**
             * Posts claim fields in $claimFields to controller in order to generate dynamic query for the data referenced
             * 
             * @param open 
             */
            function getPCMData(statusString, claimFields) {
                return $.ajax({
                    type: "POST",
                    url: "<%= get_api%>/api/Dynamic/GetPortalClaimManagerData/" + token + "/" + statusString,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    data: { claimManagerFields: claimFields }
                })
                .then(
                    function (response) {
                        var json = JSON.parse(response);
                        return ReplaceDFValues(json).map(ConvertObjectIsoDatesToCustom);
                    },
                    function () { }
                );
            }

            /**
             * Populates a table on the claim manager page with claim data.
             * 
             * @param tableSelector
             * @param claimData
             */
            function PopulatePCMTable(id, claimData, draft) {
                var targetTable = $('#' + id);                            
                var dataColumns = [];

                if ($.fn.DataTable.isDataTable(targetTable)) {
                    targetTable.DataTable().destroy();
                    targetTable.empty();
                }

                var thead = targetTable.append('<thead><tr></tr></thead><tbody></tbody>').find('thead > tr');                 
                thead.append('<th>'+window.MessagesData["Claim Links"]+'</th>');

                dataColumns.push({
                    data: null,
                    render: function (data, type, row) {
                        var formId = ['', 'WC', 'STD', 'LOA'].indexOf(data.Description);
                        claimTypeMap.map(function (t) {
                            if (t.OrgsysTypeID == data.Description) formId = t.FormID;
                        })
                        var html = (draft) ? RenderDraftClaimLinks(data, formId) : RenderOpenClosedClaimLinks(data, formId);

                        html += RenderCommentsLink(data.ClaimRefNu);

                        return html;
                    }
                });

                claimFieldsGrouped.forEach(function (group) {

                    //label is the same within each group
                    thead.append('<th id="' + group.groupId + '">' + group.data[0].FieldLabel + '</th>');
                    dataColumns.push({
                        data: null,
                        render: function (data, type, row) {
                            //joins data of multiple fields for presentation, but most will only have one field
                            return group.data.map(function (f) {
                                return data[f.ColumnAlias];
                            }).join(' ');
                        },
                        defaultContent: "" //prevent null or undefined values from causing problems
                    });
                        
                });

                targetTable.DataTable({
                    data: claimData,
                    columns: dataColumns,
                    colReorder: {
                        fixedColumnsLeft : 1
                    },
                    columnDefs: [
                            { orderable: false, targets: 0 } //Disable ordering on 'Claim Links' field (Assumes it's in 0th position)
                        ],
                    buttons: [
                        {
                            extend: 'excel',
                            text: window.MessagesData['btnExportToExcel'],
                            filename: 'Claims',
                            className: 'btn btn-primary btn-md',
                            exportOptions: {
                                columns : ':visible:not(:first)'
                            }
                        }
                    ]
                });

            } 

            /**
             * Creates an array that stores the state of the table by column
             * 
             * @param groupedFields
             */
            function BuildDTConfig(groupedFields) {

                if (groupedFields !== undefined) {
                    return groupedFields.map(function (group, index) {
                        return {
                            id: group.groupId,
                            label: group.data[0].FieldLabel,
                            isVisible: group.data[0].IsVisible,
                            index: index +1
                        };
                    });
                }

            }

            //update the claimd fields array to the new values, then post to controller in order to update the db
            //this modifies the initail data from db
            function GetUpdatedPCMFields(newColConfig) {

                var updatedClaimFields = [];

                for (var i = 0; i < claimFieldsGrouped.length; i++) {
                    claimFieldsGrouped[i].data
                        .forEach(function (f) {
                            f.FieldOrder = newColConfig[i].index;
                            f.IsVisible = (newColConfig[i].isVisible ? 1 : 0);

                            updatedClaimFields.push(f);
                        });
                }
                
                return updatedClaimFields;
            }

            function RenderDraftClaimLinks(data, formId) {
                var link = $('<a><i class="icon icon-pencil"></i></a>');

                link.attr('href', "/OrgSys_Forms/Generic_Forms/Form7.aspx?ClaimID=" + data.ClaimID + '&FormID=' + formId);
                link.attr('type', 'button');
                link.attr('class', 'btn btn-default');
                link.attr('title', 'Continue Claim');
                link.attr('data-toggle', 'tooltip');

                return link.get(0).outerHTML;
            }

            function RenderOpenClosedClaimLinks(data, formId) {                
                var link = $('<a><i class="icon icon-eye"></i></a>');

                link.attr('href', "/OrgSys_Forms/Generic_Forms/Form7.aspx?ClaimID=" + data.ClaimID + '&ViewClaim=true&FormID=' + formId);
                link.attr('type', 'button');
                link.attr('class', 'btn btn-default view_description');
                link.attr('title', 'View Claim');
                link.attr('data-toggle', 'tooltip');

                return link.get(0).outerHTML;
            }

            /**
             * Renders a comments button 
             * @param claimId
             */
            function RenderCommentsLink(claimRefNu) {
                var link = $('<a class="btn btn-default viewComments view_description" style="margin-left: 4px;" type="button"><i class="icon icon-bubble"</i></a>');
                link.attr("data-claimrefnu", claimRefNu);

                return link.get(0).outerHTML;
            }

            /**
             * Posts DTConfig to controller for saving to db
             * 
             * @param PCMFields
             */
            function SaveDTConfig(PCMFields) {
                $.ajax({
                    type : "POST",
                    url: "<%= get_api%>/api/Dynamic/SavePCMPreferences/<%= token%>",
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    data: { claimManagerFields: PCMFields },
                    dataType: "JSON"
                });

            }

            function GetActivePanelId() {
                return $('#pcm-content > .tab-pane.active').attr('id');
            }

            $(document).on('click', '#pcm-nav-tabs a', function () {

                var panelId = $(this).attr('href').replace('#', '');
                var expBtns = $('.action-buttons [class*="exp-btn"]');
                var currentTableButtons = $('.action-buttons [class*="exp-btn-'+panelId+'"]');

                if (expBtns.length > 0) {
                    expBtns.hide();
                    //show only those relating to active table
                    currentTableButtons.show();
                } 

            })

            $(document).on('click', '#save-preferences', function () {

                var id = GetActivePanelId();

                //update DTConfig with values from column tiles
                UpdateColumnVisibility(id);

                //set column visibility on current table
                SetColumnVisibility(id + 'Table', DTConfig);

                //translate updated values back to claimFields array
                var updatedPCMFields = GetUpdatedPCMFields(DTConfig);
                
                SaveDTConfig(updatedPCMFields);
                ConfirmDTChangesSwal();
                refresh = true;

            });         

            //Dynamic binding jquery to trigger view comments
            $("table").on("click", '.viewComments', function () {
                var ClaimRefNu = $(this).data().claimrefnu;
                $.ajax({
                    type: "Get",
                    async: false,
                    url: "<%= get_api%>/api/ClaimUpdates/GetReportedComments/" + ClaimRefNu,
                    beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    success: function (response) {
                        var comments = JSON.parse(response);

                        $("#reportedCommentsModal .modal-body").empty();

                        if (comments.length > 0) {
                            comments.forEach(function (comment) {
                                $("#reportedCommentsModal .modal-body").append("<div class='row well'>" +
                                                                                    "<div class='col-md-12'>" +
                                                                                        "<div class='row'>" +
                                                                                            "<div class='col-md-6'>"+comment.ActionType+"</div>" +
                                                                                            "<div class='col-md-6 text-right'>"+comment.UpdatesDate + "  |  "+ comment.EmpName +"</div>" +
                                                                                        "</div>" +
                                                                                        "<div class='row' style='margin-top:20px;'>" +
                                                                                            "<div class='col-md-12'>"+comment.ReportedComments+"</div>" +
                                                                                        "</div>" +
                                                                                    "</div></div>");
                            });
                        } else {
                            $("#reportedCommentsModal .modal-body").empty();
                            $("#reportedCommentsModal .modal-body").append("<div class='well'>"+window.MessagesData["NoReportedComments"]+"</div>");
                        }
                       

                        $("#reportedCommentsModal").modal('show');
                    },
                    error: function (response) {
                        $("#reportedCommentsModal .modal-body").empty();
                        $("#reportedCommentsModal .modal-body").append("<div class='well'>"+window.MessagesData["NoReportedComments"]+"</div>");
                    }
                });
            });
        });


    </script>

    <script src="/Assets/js/common/OrgsysUtilities.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="JSFilesExternal/DTPreferences.js"></script>


</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script src="/Assets/js/common/SplashScreen.js"></script>
    <div id="banner-container" class="osp-heading panel-heading banner-container">
        <div class="row">
            <div id="welcome-container" class="osp-heading panel-heading welcome-container narrow-container">
                <h4 id="form-title" class="welcome-header">Claim Manager</h4>
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
    <div id="pcm-container" class="osp-container container-fluid narrow-container">
         <div class="action-buttons btn-toolbar pull-right">
              <input class="btn-preferences btn btn-primary gradient-button btn-md" type="button" value="View Table Preferences" id="btnTablePrefs" />
         </div> 
         <div class="spacer"></div>
         <div class="osp-body panel-body">
            <ul id="pcm-nav-tabs" class="nav nav-tabs">
                <li class="active">
                    <a data-toggle="tab" href="#OpenClaims">Open Claims</a>
                </li>
                <li>
                    <a data-toggle="tab" href="#ClosedClaims">Closed Claims</a>
                </li>
            </ul>
            <div id="pcm-content" class="tab-content margin_bottom_10 navbar-panel navbar-panel-bordered">
                <div id="OpenClaims" class="tab-pane fade in active">
                    <table id="OpenClaimsTable" class="table table-bordered"></table>
                </div>
                <div id="ClosedClaims" class="tab-pane fade in">
                    <table id="ClosedClaimsTable" class="table table-bordered"></table>
                </div>
            </div>
        </div>
        <!-- Modal -->
        <div class="modal fade" id="reportedCommentsModal" tabindex="-1" role="dialog" aria-labelledby="reportedCommentsLabel">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <h4 class="modal-title" id="reportedCommentsLabel">Reported Comments</h4>
                    </div>
                    <div class="modal-body">
                        <div class="reportedComment">There's no comments for this claim.</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
