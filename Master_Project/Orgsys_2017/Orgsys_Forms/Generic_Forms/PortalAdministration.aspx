<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PortalAdministration.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.PortalAdministration" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master"%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/common/DTUtilities.js"></script>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="../Internal_Forms/JSFiles/DataBind.js"></script>
    <script>
        window.getApi = '<%= get_api%>';
        window.token = '<%= token%>'

        var ClientServiceTypes;
        $.ajax({
            type: 'GET',
            beforeSend: function (xhr) {
                xhr.setRequestHeader('Language', window.Language);
                xhr.setRequestHeader('Authentication', window.token);
            },
            url: getApi + "/api/Client/GetClientServices_V2/" + window.token,
            success: function (data) {
                ClientServiceTypes = JSON.parse(data);
            }
        });

        $(function () {
            InitializeDatepicker();
            MaskInputs();
            $('#registerUserBtn').prop('disabled', true);

            GetListDiffVal('GetList_Roles?IsInternal=false', 'user-role', 'RoleName', 'Role_ID', 'DataBind');
            $.ajax({
                type: 'GET',
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                url: getApi + "/api/Client/GetClientDetails/" + token,
                success: function (data) {
                    window.ClientID = JSON.parse(data)[0].ClientID
                    PopulateDivisions(window.ClientID, '.populateDivision')
                }
            });

            var portalUsersDT = InitializeDT('#PortalUsersDT', portalUserDTConfig);
            PopulatePortalUsersDT();


            //moved from externalpasswordconfig.aspx
            $("input[type=password]").keyup(function () {
                var ucase = new RegExp("[A-Z]+");
                var lcase = new RegExp("[a-z]+");
                var num = new RegExp("[0-9]+");
                var releasebutton = 0 //set a variable to count requirements
                var ps1 = $('#password1').val();
                var ps2 = $('#password2').val();

                //If the length is more or equal to 6
                if (ps1.length >= 6) {
                    $("#6char").removeClass("glyphicon-remove");
                    $("#6char").addClass("glyphicon-ok");
                    $("#6char").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#6char").removeClass("glyphicon-ok");
                    $("#6char").addClass("glyphicon-remove");
                    $("#6char").css("color", "#FF0004");
                    releasebutton--;
                }
                //if the password contains upper case letters
                if (ucase.test(ps1)) {
                    $("#ucase").removeClass("glyphicon-remove");
                    $("#ucase").addClass("glyphicon-ok");
                    $("#ucase").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#ucase").removeClass("glyphicon-ok");
                    $("#ucase").addClass("glyphicon-remove");
                    $("#ucase").css("color", "#FF0004");
                    releasebutton--;
                }
                //if the password contains lower case letters
                if (lcase.test(ps1)) {
                    $("#lcase").removeClass("glyphicon-remove");
                    $("#lcase").addClass("glyphicon-ok");
                    $("#lcase").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#lcase").removeClass("glyphicon-ok");
                    $("#lcase").addClass("glyphicon-remove");
                    $("#lcase").css("color", "#FF0004");
                    releasebutton--;
                }
                //If the password contains a number
                if (num.test(ps1)) {
                    $("#num").removeClass("glyphicon-remove");
                    $("#num").addClass("glyphicon-ok");
                    $("#num").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#num").removeClass("glyphicon-ok");
                    $("#num").addClass("glyphicon-remove");
                    $("#num").css("color", "#FF0004");
                    releasebutton--;
                }
                //if the passwords match
                if (ps1 == ps2 && (ps1 != "")) {
                    $("#pwmatch").removeClass("glyphicon-remove");
                    $("#pwmatch").addClass("glyphicon-ok");
                    $("#pwmatch").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#pwmatch").removeClass("glyphicon-ok");
                    $("#pwmatch").addClass("glyphicon-remove");
                    $("#pwmatch").css("color", "#FF0004");
                    releasebutton--;
                }

                //if the requirements are met, enable the button
                if (releasebutton >= 5) {
                    $('#registerUserBtn').prop('disabled', false);
                } else {
                    $('#registerUserBtn').prop('disabled', true);
                }
            });

            $(document).on('click', '#registerUserBtn', function () {
                var password1 = $('#password1').val();
                
                if (!validate.validateSubmission('#user-panel')) {
                    swal('', 'There are errors in the form.', 'error');
                    return;
                }
                
                var user = {
                    firstName: $('#firstName').val(),
                    lastName: $('#lastName').val(),
                    userName: $('#username').val(),
                    employeeNumber: $('#empNumber').val(),
                    phoneNumber: $('#phoneNumber').cleanVal(),
                    dob: ConvertDateCustomToIso($('#dob').val()),
                    email: $('#email').val(),
                    passwordClear: password1,
                    userTypeId: 4,
                    clientId: window.ClientID,
                    roleId: $('.user-role').val(),
                    divisionId: $('#client-divisions :selected').attr('id')
                }

                $.ajax({
                    type: 'POST',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                    data: user,
                    url: '<%= get_api%>/api/<%= token%>/users/register'
                }).then(
                    function (userId) {
                        var userGroups = {
                            clientId: window.ClientID,
                            userId: userId
                        }

                        $.ajax({
                            type: 'POST',
                            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                            url: '<%= get_api%>/api/<%= token%>/Users/assign/client/',
                            data:'=' + encodeURIComponent({ objUsers: [userGroups] }),
                            success: function (data) {
                                var results = JSON.parse(data);
                                console.log(results);
                                $.each(results, function (i, result) {
                                    var newOption = new Option(result.ServiceDescription, result.Abbreviation, false, false);
                                    $("#selectService").append(newOption).trigger('change');
                                });
                            }
                        }).then(
                            function () { 
                                swal('', 'User has been created', 'success');
                                PopulatePortalUsersDT();
                            },
                            function () { swal('', 'The user has been created successfully but the client could not be assigned at this time.', 'info') }
                        );

                        $('input').not('.btn').val('');
                        $('select').val(0);
                    },
                    ErrorSwal_Basic
                );
            })    

            $(document).on('click', '.change-role', function () {
                var row = $(this).closest('tr');
                var rowData = portalUsersDT.row(row).data();

                swal({
                    title: 'Change User Role',
                    showCancelButton: true,
                    confirmButtonText: 'Change',
                    html: '<div class="row"><div class="col-sm-12"><label for="user-roles">Select Role</label><select id="user-roles" class="form-control user-role-swal"><select></div></div>',
                    onOpen: function () {
                        GetListDiffVal('GetList_Roles?IsInternal=false', 'user-role-swal', 'RoleName', 'Role_ID', 'DataBind').then(function () {
                            $('.user-role-swal').val(rowData.Role_ID);
                        })
                    }
                }).then(
                    function () {
                        var userRole = {
                            Role_ID: $('.user-role-swal').val()
                        }
                        $.ajax({
                            type: 'POST',
                            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                            data: userRole,
                            url: getApi + "/api/" + token + "/Users/" + rowData.UserID + "/role/" + rowData.User_Role_ID,
                            success: function (data) {
                                var results = JSON.parse(data);
                                console.log(results);
                                $.each(results, function (i, result) {
                                    var newOption = new Option(result.ServiceDescription, result.Abbreviation, false, false);
                                    $("#selectService").append(newOption).trigger('change');
                                });
                            }
                        }).then(
                            function () {
                                swal('', 'User role updated.', 'success');
                                PopulatePortalUsersDT();
                            },
                            ErrorSwal_Basic
                        )
                    },
                    function () { }
                )
            });

            $(document).on('click', '.change-service-permissions', function () {
                var row = $(this).closest('tr');
                var rowData = portalUsersDT.row(row).data();

                //get the services that the user is allowed currently
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) {
                        xhr.setRequestHeader('Language', window.Language);
                         xhr.setRequestHeader('Authentication', token);
                    },
                    url: getApi + "/api/" + window.token + "/Users/GetServicePermissionsExternal/" + rowData.UserID + "/" + window.ClientID
                }).then(function (data) {

                    var UserPermissions = JSON.parse(data);//ServiceTypeID
                    var ClientServicesHTML = "";

                    //loop through each service that the client has and check the boxe that the user is currently authorized for
                    ClientServicesHTML += "<div id='UserServicePermissionForm'>";
                    for (var i = 0; i < ClientServiceTypes.length; i++) {
                        var hasPermission = false;
                        for (var x = 0; x < UserPermissions.length; x++) {
                            if (ClientServiceTypes[i].ServiceID === UserPermissions[x].ServiceTypeID) {
                                hasPermission = true;
                            }
                        }
                        ClientServicesHTML += `<div class="form-check">
                                            <input class="form-check-input" name="ServicePermission" type="checkbox" value="`+ ClientServiceTypes[i].ServiceID + `" id="` + ClientServiceTypes[i].ServiceDescription + `" `+(hasPermission ? "checked" : "" )+`>
                                            <label class="form-check-label" for="`+ ClientServiceTypes[i].ServiceDescription + `">` + ClientServiceTypes[i].ServiceDescription + `
                                            </label>
                                       </div>`
                    }
                    ClientServicesHTML += "</div>";

                    var NewPermissions = [];

                        swal({
                            title: 'User service permissions',
                            showCancelButton: true,
                            confirmButtonText: 'Update',
                            html: ClientServicesHTML
                        }).then(
                            function () {
                                $.each($("input[name='ServicePermission']:checked"), function () {
                                    NewPermissions.push({
                                        Id:0,
                                        UserID: rowData.UserID,
                                        ServiceTypeID: $(this).val(),
                                        ClientID: window.ClientID
                                    });
                                });
                                $.ajax({
                                    type: "POST",
                                    url: getApi + "/api/" + window.token + "/Users/UpdateUserServicePermissions/" + rowData.UserID,
                                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                                    data:  '=' + encodeURIComponent( JSON.stringify(NewPermissions)),
                                }).then(function () {
                                    swal('Updated successfuly!');
                                });
                            },
                            function () { }
                        )

                    });
            });

            $(document).on('click', '.user-activity', function () {
                var row = $(this).closest('tr');
                var rowData = portalUsersDT.row(row).data();
                var successMessage = 'The account for user ' + rowData.Username + ' has been ' + ((rowData.Active) ? 'disabled.' : 'enabled.')
                var user = {
                    Active : (rowData.Active) ? 0 : 1
                }

                $.ajax({
                    type: 'POST',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                    url: getApi + "/api/" + token + "/Users/" + rowData.UserID,
                    data: user,
                    success: function (data) {
                        var results = JSON.parse(data);
                        console.log(results);
                        $.each(results, function (i, result) {
                            var newOption = new Option(result.ServiceDescription, result.Abbreviation, false, false);
                            $("#selectService").append(newOption).trigger('change');
                        });
                    }
                }).then(
                    function () {
                        PopulatePortalUsersDT();
                        swal('', successMessage, 'success');
                    },
                    ErrorSwal_Basic
                )
            })

            function PopulatePortalUsersDT() {
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                    url: getApi + "/api/" + token + "/Users/portal",
                    success: function (data) {
                         SetDataDT('#PortalUsersDT', data)
                    }
                });
            }

        })

        var portalUserDTConfig = {
            "columns": [                   
                {
                    data: null,
                    render: function () {
                        return '<a class="btn btn-default change-role view_description" title="Change Role" data-toggle="tooltip"><i class="icon icon-copy1"></i></a>     <a class="btn btn-default change-service-permissions view_description" title="Change Service permissions" data-toggle="tooltip"><i class="icon icon-eye"></i></a>';
                    }
                },
                {
                    data: null,
                    render: function (data) {
                        var title = (data.Active) ? 'Disable Account' : 'Enable Account'; 
                        var text = (data.Active) ? 'Active' : 'Disabled'; 
                        return '<a class="btn btn-default user-activity btn-primary" title="'+title+'" data-toggle="tooltip">'+text+'</a>'
                    }
                },
                { data: "Username" },
                {
                    data: "DateAdded",
                    render: ConvertDateIsoToCustom
                },
                { data: "RoleName" },
                {
                    data: "LoginDate",
                    render: ConvertDateIsoToCustom
                }
            ]
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <div class="tabs">
            <ul id="AdminTabs" class="nav nav-tabs">
                <li>
                    <a href="#UserOverview" data-toggle="tab" class="active">Users</a>
                </li>
                <li>
                    <a href="#UserRegistration" data-toggle="tab">Register</a>                    
                </li>
            </ul>
        </div>
        <div id="AdminContent" class="tab-content">
            <div id="UserRegistration" class="tab-pane fade">
                <div id="user-panel" class="panel panel-default user-panel">
                    <div class="panel-heading">
                        <h2>User Registration</h2>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-3">
                                <label for="firstName">First Name</label>
                                <input id="firstName" class="form-control required" type="text" />
                            </div>
                            <div class="col-md-3">
                                <label for="lastName">Last Name</label>
                                <input id="lastName" class="form-control required" type="text" />
                            </div>
                            <div class="col-md-3">
                                <label for="dob">Date of Birth</label>
                                <input id="dob" class="form-control required" type="date" />
                            </div>
                            <div class="col-md-3">
                                <label for="empNumber">Employee Number</label>
                                <input id="empNumber" class="form-control" type="text" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-3">
                                <label for="phoneNumber">Phone Number</label>
                                <input id="phoneNumber" class="form-control vld-phone" type="text" />
                            </div>
                            <div class="col-md-3">
                                <label for="email">Email</label>
                                <input id="email" class="form-control vld-email required" type="text" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-3">
                                <label for="user-role">User Role</label>
                                <select id="user-role" data-placeholder="Select a Role" class="form-control required user-role" ></select>
                            </div>
                        </div>
                        <div class="row client-division-section">
                            <label class="subsection-label">Client Division</label>
                            <div class="col-md-6">
                                <label for="client-divisions">Business Site</label>
                                <select id="client-divisions" class="form-control populateDivision required"></select>
                            </div>
                            <div class="division-display col-md-6"></div>
                        </div>
                        <div class="row">
                            <div class="col-md-3">
                                <label for="username">Username</label>
                                <input id="username" class="form-control required" type="text" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-3">
                                <label for="password1">Password</label>
                                <input id="password1" class="form-control required" type="password" />
                            </div>
                            <div class="col-md-3">
                                <label for="password2">Confirm Password</label>
                                <input id="password2" class="form-control required" type="password" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-sm-4">
                                <span id="6char" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>6 Characters Long<br/>
                                <span id="ucase" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>1 Uppercase Letter
                            </div>
                            <div class="col-sm-4">
                                <span id="lcase" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>1 Lowercase Letter<br/>
                                <span id="num" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>Number(s)
                            </div>
                            <div class="col-sm-4">
                                <span id="pwmatch" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>Passwords Match<br/>
                            </div>
                        </div><br />
                        <div class="row">
                            <div class="col-md-3">
                                <input id="registerUserBtn" class="form-control btn btn-primary" type="button" value="Register User" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="UserOverview" class="tab-pane fade in active">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h2>User Summary</h2>
                    </div>
                    <div class="panel-body">
                        <table id="PortalUsersDT" class="table table-bordered table-striped table-hover dataTable no-footer">
                            <thead>
                                <tr>
                                    <th>Actions</th>
                                    <th>Active</th>
                                    <th>Username</th>
                                    <th>Date Added</th>
                                    <th>Role</th>
                                    <th>Last Login</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
    </div>
</asp:Content>
