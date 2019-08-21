<%@ Page Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="UserRoles.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.UserRoles" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="../Assets/js/common/DateInput.js"></script>
    <script>
        var token = '<%= token %>';

        $(document).ready(function () {
            //Initialize tooltips 
            $('body').tooltip({
                selector: '[data-toggle=tooltip]'
            });
            //setting global default for select2 theme
            $.fn.select2.defaults.set("theme", "bootstrap");
            //setting global default for notify position
            $.notifyDefaults({
                placement: {
                    from: "bottom",
                    align: "right"
                }
            });

            //=============START===============
            // Initialize DataTables for Users
            // And Clients Tab
            //=================================
            $("#users-table").DataTable({
                lengthChange: false,
                pageLength: 5,
                columns: [
                    {
                        data: null, render: function (user, type, row) {
                            return `<a id='edit-user-button_${user.GroupID}' data-usergroupid='${user.GroupID}' data-username='${user.EmpFirstName + " " + user.EmpLastName}' type='button' class='btn btn-default editEmployee edit_button' width='5px' data-toggle='tooltip' title='Edit User'><i class='icon icon-pencil'></i></a> <a id='edit-confirm-user-button_${user.GroupID}' data-usergroupid='${user.GroupID}' data-username='${user.EmpFirstName + " " + user.EmpLastName}' type='button' class='btn btn-success hidden' width='5px' data-toggle='tooltip' title='Confirm Edit'><i class='icon icon-edit1'></i></a> <a id='remove-user-button' data-tableid='#users-table' data-usergroupid='${user.GroupID}' data-clientname='${user.ClientName}' data-username='${user.EmpFirstName + " " + user.EmpLastName}' type='button' class='btn btn-default deleteEmployeeContact btn-danger' width='5px' data-toggle='tooltip' title='Remove user from the Client'><i class='icon icon-bin'></i></a>`;
                        }
                    },
                    {
                        data: null, render: function (user, type, row) {
                            return user.EmpFirstName + " " + user.EmpLastName;
                        }
                    },
                    {
                        data: null, render: function (user, type, row) {
                            return new Date(user.AssignDate).toISOString().split("T")[0];
                        }
                    },
                    {
                        data: null, render: function (user, type, row) {
                            return new Date(user.DateFrom).toISOString().split("T")[0];
                        }
                    },
                    {
                        data: null, render: function (user, type, row) {
                            return new Date(user.DateTo).toISOString().split("T")[0];
                        }
                    },
                    { data: "Email" },
                    { data: "Username" }
                ]
            });
            $("#clients-table").DataTable({
                lengthChange: false,
                pageLength: 5,
                columns: [
                    {
                        data: null, render: function (client, type, row) {
                            return `<a id='edit-confirm-user-button_${client.GroupID}' data-usergroupid='${client.GroupID}' type='button' class='btn btn-default editEmployee view_description' width='5px' data-toggle='tooltip' title='Confirm Edit'><i class='icon icon-edit1'></i></a>  <a id='edit-client-button_${client.GroupID}' data-clientid='${client.ClientID}' data-clientname='${client.ClientName}' type='button' class='btn btn-default editEmployee edit_button' width='5px' data-toggle='tooltip' title='Edit User'><i class='icon icon-pencil'></i></a> <a id='remove-user-button' data-tableid='#clients-table' data-usergroupid='${client.GroupID}' data-clientname='${client.ClientName}' data-username='${$("#user-select").select2("data")[0].text}' type='button' class='btn btn-default deleteEmployeeContact btn-danger' width='5px' data-toggle='tooltip' title='Remove user from the Client'><i class='icon icon-bin'></i></a>`;
                        }
                    },
                    {
                        data: null, render: function (client, type, row) {
                            return client.ClientName;
                        }
                    },
                    {
                        data: null, render: function (client, type, row) {
                            return new Date(client.AssignDate).toISOString().split("T")[0];
                        }
                    },
                    {
                        data: null, render: function (client, type, row) {
                            return new Date(client.DateFrom).toISOString().split("T")[0];
                        }
                    },
                    {
                        data: null, render: function (client, type, row) {
                            return new Date(client.DateTo).toISOString().split("T")[0];
                        }
                    }
                ]
            });
            //=============END=================
            // Initialize DataTables for Users
            // And Clients Tab
            //=================================

            //=============START===============
            // Event handlers for User Tab
            // 
            //=================================

            //initialize select2 for #user-select
            $("#user-select").select2({
                width: "100%",
                placeholder:"Select a User",
                ajax: {
                    url: `<%= get_api %>/api/${token}/Users/all`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    processResults: function (users) {
                        var mappedJson = mapJsonForSelect2DataSource(JSON.parse(users), "UserID", ["EmpFirstName", "EmpLastName"]);
                        return {
                            results: mappedJson
                        };
                    }
                }
            });
            //Event handler for  #user-select
            $("#user-select").on('select2:select', function (e) {
                $("#load-clients-button").attr("data-userid", e.params.data["UserID"]);
            });

            //Initialize select2 for #clients-select
            $("#clients-select").select2({
                width: "100%",
                placeholder:"Select Clients",
                ajax: {
                    url: `<%= get_api %>/api/DataManagement/GetAllClients/`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    processResults: function (clients) {
                        var clientsDataTableData = $("#clients-table").DataTable().data();
                        var results = [];

                        var mappedJson = mapJsonForSelect2DataSource(JSON.parse(clients), "ClientID", ["ClientName"]);

                        $.each(clientsDataTableData, function (key, client) {
                            var objIndex = mappedJson.findIndex(obj => obj["ClientID"] === client["ClientID"]);
                            if (objIndex !== -1) {
                                mappedJson[objIndex]["disabled"] = true;
                            }
                        });

                        results = mappedJson;
                        return {
                            results: results
                        };
                    }
                }
            });

            //Event handler that loads clients into the datatable when a user is selected
            $("#load-clients-button").on("click", function () {
                var UserID = $(this).attr("data-userid");
                $.ajax({
                    url: `<%= get_api%>/api/${token}/Users/${UserID}/clients/all`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    success: function (clients) {
                        var clientDatatable = $("#clients-table").DataTable();
                        clientDatatable.clear();
                        clientDatatable.rows.add(JSON.parse(clients)).draw();
                    },
                    error: function (er) {
                        console.log(er);
                    }
                });
            });

            //Event handler for #add-clients-button
            $("#add-clients-button").on("click", function () {
                var clientAdditionSelectData = $("#clients-select").select2("data");
                var UserID = $("#user-select").val();
                var user_groups = [];

                $.each(clientAdditionSelectData, function (key, ug_client) {
                    var currentDate = new Date();
                    var nextYear = new Date();
                    nextYear.setFullYear(nextYear.getFullYear() + 1);
                    var DateFrom = $("#DateFromByClient").val() ? new Date($("#DateFromByClient").val()).toISOString() : null;
                    var DateTo = $("#DateToByClient").val() ? new Date($("#DateToByClient").val()).toISOString() : null;

                    user_groups.push({
                            UserID: UserID,
                            ClientID: ug_client["ClientID"],
                            DateFrom: DateFrom && DateTo ? DateFrom : currentDate.toISOString(),
                            DateTo: DateFrom && DateTo ? DateTo : nextYear.toISOString(),
                            AssignDate: currentDate.toISOString()
                    });
                    ug_client["DateFrom"] = DateFrom && DateTo ? DateFrom : currentDate.toISOString();
                    ug_client["DateTo"] = DateFrom && DateTo ? DateTo : nextYear.toISOString();
                    ug_client["AssignDate"] = currentDate.toISOString();
                });

                //set user controls to null values
                $("#clients-select").val(null).trigger("change");
                $("#DateFromByClient").val(null);
                $("#DateToByClient").val(null);
                

                $.ajax({
                    url: `<%= get_api%>/api/${token}/Users/assign/client/`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    type: "POST",
                    dataType: "JSON",
                    data: { objUsers: user_groups },
                    success: function (clients) {
                        $("#load-clients-button").trigger("click");
                        $.notify({ message: `Client(s) have been added to the User!` }, { type: 'success' });
                    },
                    error: function(e) {
                        $.notify({ message: `Unable to add client(s) to the User (Server Error)` }, { type: 'danger' });
                    }
                });

            });
            //=============END=================
            // Event handlers for User Tab
            // 
            //=================================

            //=============START===============
            // Event handlers for Clients Tab
            // 
            //=================================
            //initialize select2 for client-select
            $("#client-select").select2({
                width: "100%",
                placeholder:"Select a Client",
                ajax: {
                    url: `<%= get_api %>/api/DataManagement/GetAllClients/`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    processResults: function (clients) {
                        var mappedJson = mapJsonForSelect2DataSource(JSON.parse(clients), "ClientID", ["ClientName"]);
                        return {
                            results: mappedJson
                        };
                    }
                }
            });
            //Event handler for #client-select
            $("#client-select").on('select2:select', function (e) {
                $("#load-users-button").attr("data-clientid", e.params.data["ClientID"]);
            });

            //Initialize select2 for users-select
            $("#users-select").select2({
                width: "100%",
                placeholder:"Select Users",
                ajax: {
                    url: `<%= get_api %>/api/${token}/Users/all`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    processResults: function (users) {
                        var usersDataTableData = $("#users-table").DataTable().data();
                        var results = [];

                        if ($("#load-users-button").attr("data-clientid")) {
                            var mappedJson = mapJsonForSelect2DataSource(JSON.parse(users), "UserID", ["EmpFirstName", "EmpLastName"]);

                            $.each(usersDataTableData, function (key, user) {
                                var objIndex = mappedJson.findIndex(obj => obj["UserID"] === user["UserID"]);
                                if (objIndex !== -1) {
                                    mappedJson[objIndex]["disabled"] = true;
                                }
                            });
                            results = mappedJson;
                        } else {
                            $.notify({ message: `Select a client and click load before selecting a user.` }, { type: 'danger' });
                        }
                        return {
                            results: results
                        };
                    }
                }
            });


            //Event handler that loads users into datatable when a client is selected
            $("#load-users-button").on("click", function () {
                var ClientID = $(this).attr("data-clientid");
                if ($("#client-select").val()) {
                    $.ajax({
                        url: `<%= get_api%>/api/${token}/Users/GetUsersAssignedToClient/${ClientID}`,
                        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    success: function (users) {
                        var userDataTable = $("#users-table").DataTable();
                        userDataTable.clear();
                        userDataTable.rows.add(JSON.parse(users)).draw();
                        }
                    });
                }
            });

            //Event handler for #add-users-button
            $("#add-users-button").on("click", function () {
                var userAdditionSelectData = $("#users-select").select2("data");
                var ClientID = $("#client-select").val();
                var users = [];

                $.each(userAdditionSelectData, function (key, obj) {
                    var currentDate = new Date();
                    var nextYear = new Date();
                    nextYear.setFullYear(nextYear.getFullYear() + 1);
                    var DateFrom = $("#DateFrom").val() ? new Date($("#DateFrom").val()).toISOString() : null;
                    var DateTo = $("#DateTo").val() ? new Date($("#DateTo").val()).toISOString() : null;

                    users.push({
                        UserID: obj["UserID"],
                        ClientID: ClientID,
                        DateFrom: DateFrom && DateTo ? DateFrom : currentDate.toISOString(),
                        DateTo: DateFrom && DateTo ? DateTo : nextYear.toISOString(),
                        AssignDate: currentDate.toISOString()
                    });
                    obj["DateFrom"] = DateFrom && DateTo ? DateFrom : currentDate.toISOString();
                    obj["DateTo"] = DateFrom && DateTo ? DateTo : nextYear.toISOString();
                    obj["AssignDate"] = currentDate.toISOString();
                });

                //set user controls to null values
                $("#users-select").val(null).trigger("change");
                $("#DateFrom").val(null);
                $("#DateTo").val(null);


                $.ajax({
                    url: `<%= get_api%>/api/${token}/Users/assign/client/`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    type: "POST",
                    dataType: "JSON",
                    data: { objUsers: users },
                    success: function (users) {
                        $("#load-users-button").trigger("click");
                        $.notify({ message: `User(s) have been added to the Client!` }, { type: 'success' });
                    },
                    error: function(e) {
                        $.notify({ message: `Unable to add user(s) to the Client (Server Error)` }, { type: 'danger' });
                    }
                });

            });

            //Dynamic event handler for the users table that allows edits to a users [DateTo]
            $("#users-table").on("click", "[id*='edit-user-button_']", function () {
                var GroupID = $(this).attr("data-usergroupid");
                var row = $(this).closest("tr");
                var DateFromCol = row.find("td")[4];//DateFrom column position

                $(`#edit-confirm-user-button_${GroupID}`).toggleClass("hidden");
                $(this).toggleClass("hidden");
                $(DateFromCol).html(`<input id='DateFromCellInput_${GroupID}' type='date' class='form-control'/>`);

                //Initialize all datepickers on the form
                InitializeDatepicker();
            });

            //Edits the "DateFrom" from for a specific user
            $("#users-table").on("click", "[id*='edit-confirm-user-button_']", function () {
                var UserDataTable = $("#users-table").DataTable();
                var GroupID = $(this).attr("data-usergroupid");
                var UserDateTo = $(`#DateFromCellInput_${GroupID}`).val();
                var row = $(this).closest("tr");
                var UserDataTableRowData = UserDataTable.row(row).data();

                if (UserDateTo) {
                    $(this).toggleClass("hidden");
                    $(`#edit-user-button_${GroupID}`).toggleClass("hidden");

                    UserDataTableRowData["DateTo"] = formatDateTime(UserDateTo);
                    UserDataTable.row(row).data(UserDataTableRowData).draw();

                    $.ajax({
                        url: `<%= get_api %>/api/${token}/Users/update/usergroup/${GroupID}/${UserDateTo}`,
                        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                        type: "POST"
                    });
                } else {
                    $.notify({ message: `You must select an expiry date!` }, { type: 'danger' });
                }
            });

            //Dynamic event handler for the users table that allows the removing of a user from a client 
            $("#users-table, #clients-table").on("click", "#remove-user-button", function () {
                var ClientName = $(this).attr("data-clientname");
                var UserGroupID = $(this).attr("data-usergroupid");
                var UserName = $(this).attr("data-username");
                var DataTable = $($(this).attr("data-tableid")).DataTable();
                var DataRow = $(this).parents("tr");

                swal({
                    title: `Expire user ${UserName} from ${ClientName}?`,
                    type: "warning",
                    showCancelButton: true,
                    confirmButtonText: 'Expire User',
                    cancelButtonText: 'Cancel',
                    reverseButtons: true
                }).then(function (result) {
                    DataTable.row(DataRow).remove().draw();
                    $.ajax({
                        url: `<%= get_api %>/api/${token}/Users/usergroup/${UserGroupID}/`,
                        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                            type: "POST",
                            success: function (data) {
                                results = JSON.parse(data);
                                swal("Success!", `${UserName} has been expired from ${ClientName}`, "success");
                            },
                            error: function (data) {
                                swal("Error!", ` ${UserName} has not been expired from ${ClientName} (Server Error)`, "error");
                            }
                        });
                    },
                    function (dissmiss) {
                        if (dissmiss === "cancel") {
                            swal("Cancelled!", `${UserName} has not been expired from ${ClientName}`, "error");
                        }
                    });
            });

            //Initialize all datepickers on the form
            InitializeDatepicker();
        });
        //=============END=================
        // Event handlers for Clients Tab
        // 
        //=================================


        function mapJsonForSelect2DataSource(unmappedJson, idProperty, textPropertyArray) {
            var mappedObject = $.map(unmappedJson, function (obj) {
                var concatString = "";
                for (var i = 0; i < textPropertyArray.length; i++) {
                    concatString += obj[textPropertyArray[i]] + " ";
                }

                obj.id = obj.id || obj[idProperty];
                obj.text = obj.text || concatString;

                return obj;
            });
            return mappedObject;
        }

        //A custom function to left merge two objects
        function leftMergeTwoObjects(leftObject, rightObject) {
            const res = {};
            for (const p in leftObject)
                res[p] = (p in rightObject ? rightObject : leftObject)[p];
            return res;
        }

        //Returns a datetime isostring
        function formatDateTime(date) {
            var d = new Date(date);
            var day = ("0" + d.getDate()).slice(-2);
            var month = ("0" + (d.getMonth() + 1)).slice(-2);
            var year = d.getFullYear();
            var hour = d.getHours();
            var min = d.getMinutes();
            var sec = d.getSeconds();

            return new Date(year + "-" + month + "-" + day + " " + hour + ':' + min + ':' + sec).toISOString();
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper">
    <div id="banner-container" class="osp-heading panel-heading narrow-container">
        <div id="welcome-container" class="osp-heading panel-heading">
           <h4 id="welcome-header" class="osp-heading panel-heading">User Roles and Permissions </h4>
        </div>
    </div>
    <div class="main-wrappe user_roles_container">
        <%--<h2 style="padding: 2px 2px 2px 2px">User Roles and Permissions<small> Configuration Page</small></h2>--%>
        <div class="main-wrapper" style="height: 570px!important;">
            <!-- TABLES SHOW & EDIT TASKS -->
            <div id="tabs">
                <ul class="nav nav-tabs">
                    <li id="clients-tab-link" class="active"><a data-toggle="tab" href="#clients-tab">Clients</a></li>
                    <li id="users-tab-link"><a data-toggle="tab" href="#users-tab">Users</a></li>
                </ul>
            </div>
            <div class="tab-content user_roles_client">
                <div id="clients-tab" class="tab-pane fade in active user_roles_client_container">
                    <div class="panel panel-default" style="border-top: 0px;">
                        <%--<div class="panel-heading user_roles_client_heading">
                            <div class="row">
                                <div class="user_roles_client_heading_container">
                                    <h3 class="panel-title user_roles_client_title">Edit Users by Client</h3>
                                </div>
                            </div>
                        </div>--%>
                        <div class="panel-body">
                            <div class="row margin-bottom">
                                <div class="col-md-4">
                                    <label for="client-select">Select a client from the list below to populate the table</label>
                                    <div class='input-group'>
                                        <select id="client-select" class="form-control"></select>
                                        <span class="input-group-btn">
                                            <button id="load-users-button" type="button" class="btn btn-primary load_button margin_left_5">Load</button>
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h3 style="padding: 2px 2px 2px 2px"><small>Select a valid date to/from. If no dates are selected, the users will be valid from today for exactly one year.</small></h3>
                                </div>
                            </div>
                            <div class="row margin-bottom">
                                <div class="col-md-4">
                                    <label for="users-select">Select a list of users to add to the client</label>
                                    <div class='input-group'>
                                        <select id="users-select" multiple="multiple" class="form-control"></select>
                                        <span class="input-group-btn">
                                            <button id="add-users-button" type="button" class="btn btn-primary load_button margin_left_5">Add</button>
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label for="DateFrom">Select a date valid from: </label>
                                    <input id="DateFrom" type="date" class="form-control hasDatePicker date" />
                                </div>
                                <div class="col-md-3">
                                    <label for="DateTo">Select a date valid to: </label>
                                    <input id="DateTo" type="date" class="form-control hasDatePicker date" />
                                </div>
                            </div>
                            <div class="row margin-bottom">
                                <div class="col-md-12">
                                    <table id="users-table" class="table table-bordered table-striped table-hover dataTable no-footer">
                                        <thead>
                                            <tr>
                                                <th>Actions</th>
                                                <th>Employee Name</th>
                                                <th>Date Assigned</th>
                                                <th>Date Valid From</th>
                                                <th>Date Valid To</th>
                                                <th>Employee Email</th>
                                                <th>Username</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="users-tab" class="tab-pane fade in">
                    <div class="panel panel-default" style="border-top: 0px;">
                        <%--<div class="panel-heading">
                            <div class="row">
                                <div class="col col-xs-6">
                                    <h3 class="panel-title">Edit Users by User</h3>
                                </div>
                            </div> 
                        </div>--%>
                        <div class="panel-body">
                            <div class="row margin-bottom">
                                <div class="col-md-4">
                                    <label for="user-select">Select a user from the list below to populate the table</label>
                                    <div class='input-group'>
                                        <select id="user-select" class="form-control"></select>
                                        <span class="input-group-btn">
                                            <button id="load-clients-button" type="button" class="btn btn-primary margin_left_5">Load</button>
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h3 style="padding: 2px 2px 2px 2px">
                                        <small>Select a valid date to/from. If no dates are selected, the users will be valid from today for exactly one year.</small>
                                    </h3>
                                </div>
                            </div>
                            <div class="row margin-bottom">
                                <div class="col-md-4">
                                    <label for="clients-select">Select a list of clients to add to the user</label>
                                    <div class='input-group'>
                                        <select id="clients-select" multiple="multiple" class="form-control"></select>
                                        <span class="input-group-btn">
                                            <button id="add-clients-button" type="button" class="btn btn-primary margin_left_5">Add</button>
                                        </span>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label for="DateFromByClient">Select a date valid from: </label>
                                    <input id="DateFromByClient" type="date" class="form-control hasDatePicker date" />
                                </div>
                                <div class="col-md-3">
                                    <label for="DateTo">Select a date valid to: </label>
                                    <input id="DateToByClient" type="date" class="form-control hasDatePicker date" />
                                </div>
                            </div>
                            <div class="row margin-bottom">
                                <div class="col-md-12">
                                    <table id="clients-table" class="table table-bordered table-striped table-hover dataTable no-footer">
                                        <thead>
                                            <tr>
                                                <th>Actions</th>
                                                <th>Client Name</th>
                                                <th>Date Assigned</th>
                                                <th>Date Valid From</th>
                                                <th>Date Valid To</th>
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
        </div>
        </div>
    </div>
</asp:Content>