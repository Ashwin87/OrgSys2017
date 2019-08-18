<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LatentAdministrationInterface.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.LatentAdministrationInterface" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script src="/Assets/js/jquery-3.1.1.js"></script>

    <script src="/Assets/bs/bootstrap.js"></script>   
    <link href="/Assets/css/bootstrap.css" rel="stylesheet" /> 

    <script src="/Assets/js/sweetalert.js"></script>
    <link rel="stylesheet" href="/Assets/css/sweetalert.css"/>

    <script src="/Assets/js/jquery-ui.js"></script>
    <link rel="stylesheet" href="/Assets/css/jquery-ui.css"/>

    <script src="/Assets/js/select2.min.js"></script>
    <link href="/Assets/css/select2.min.css" rel="stylesheet" type="text/css"/>

    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="Internal_Forms/JSFiles/DataBind.js"></script>

    <script>
        window.getApi = '<%= get_api%>';
        const clientModel = {
            ClientID: 0,
            ClientName: '',
            TradeLegalName: '',
            BusMailingAddress: '',
            BusCity: '',
            BusCountry: '',
            BusProvince: '',
            BusPostal: '',
            BusFax: '',
            BusTelephone: '',
            BusAlternate: '',
            BusActivityDescr: '',
            FirmNumer: null,
            AccountNumber: null,
            _20MoreWorkers: false,
            IsActive: true,
            ClientStartDate: '',
            BusUnit: '',
            BusDiv: '',
            BusDept: '',
            LogoPath: '',
            DivisionName: '',
            ParentID: 0
        }

        $(function () {
            InitializeDatepicker();
            MaskInputs();
            $('.has-select2').select2();
            InitLogoSearch();
            initSearchableSelect2Fields();

            GetListDiffVal('all', 'client-users', 'Username', 'UserID', '/<%=token%>/Users');

            $('[data-bus-location-type]').on('select2:select', function (event) {
                const type = $(this).data('bus-location-type');
                const data = event.params.data;
                switch (type) {
                    case 'COUNTRY':
                        $("[data-bus-location-type='PROVINCE'], [data-bus-location-type='CITY']").val(null).trigger('change');
                        initSelectInput(`<%= get_api%>/api/OldOrgsysGetData/GetList_ProvinceStates/${data.id}`, `#BusProvince`, 'id', 'ProvinceState');
                        break;
                    case 'PROVINCE':
                        $("[data-bus-location-type='CITY']").val(null).trigger('change');
                        initSelectInput(`<%= get_api%>/api/OldOrgsysGetData/GetList_Cities/${data.id}`, `#BusCity`, 'id', 'City');
                        break;
                    default:
                }

            })

            $('#company').on('select2:select', function (event) {
                const data = event.params.data;
                $("#ParentID").empty().trigger('change');
                initSelectInput(`<%= get_api%>/api/Client/${data.id}/divisions`, `#ParentID`, 'ParentID', 'DivisionName');
            })

            $(document).on('click', '#registerUserBtn', function () {
                const password1 = $('#password1').val();
                const password2 = $('#password2').val();
                const clientIds = $('#client').select2('data').map((c) => c.element.value);
                const userType = $('#userType').val();
                
                if (!validate.validateSubmission('#user-panel')) {
                    swal('', 'There are errors in the form.', 'error');
                    return;
                }
                if (password1 !== password2) {
                    swal('', 'Passwords do not match.', 'error');
                    return;
                }
                
                const user = {
                    firstName: $('#firstName').val(),
                    lastName: $('#lastName').val(),
                    userName: $('#username').val(),
                    employeeNumber: $('#empNumber').val(),
                    phoneNumber: $('#phoneNumber').cleanVal(),
                    dob: ConvertDateCustomToIso($('#dob').val()),
                    email: $('#email').val(),
                    passwordClear: password1,
                    userTypeId: userType,
                    clientId: (userType == 1) ? 0 : clientIds[0],
                    roleId: $('.user-role').val(),
                    divisionId: $('#client-divisions :selected').attr('id')
                }


                $.ajax({
                    type: 'POST',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
                    url: '<%= get_api%>/api/<%= token%>/users/register',
                    data:user,
                    success: function (data) {
                        var results = JSON.parse(data);
                        console.log(results);
                        $.each(results, function (i, result) {
                            var newOption = new Option(result.ServiceDescription, result.Abbreviation, false, false);
                            $("#selectService").append(newOption).trigger('change');
                        });
                    }
                }).then(
                    (userId) => {
                        var userGroups = clientIds.map((c) => {
                            return {
                                clientId: c,
                                userId: userId
                            }
                        });

                        $.ajax({
                            type: 'POST',
                            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                            url: '<%= get_api%>/api/<%= token%>/Users/assign/client/',
                            data: { objUsers: userGroups },
                            success: function (data) {
                                var results = JSON.parse(data);
                                console.log(results);
                                $.each(results, function (i, result) {
                                    var newOption = new Option(result.ServiceDescription, result.Abbreviation, false, false);
                                    $("#selectService").append(newOption).trigger('change');
                                });
                            }
                        }).then(
                            () => swal('', 'User has been created', 'success'),
                            () => swal('', 'The user has been created successfully but clients could not be assigned at this time.', 'info')
                        );

                        $('input').not('.btn').val('');
                        $('select').val(0);
                    },
                    () => swal('', 'Your request could not be completed at this time. Please contact support@orgsoln.com.', 'error')
                );
            })

            $(document).on('click', '#CreateClientBtn', function () {

                if (!validate.validateSubmission('#client-panel')) {
                    swal('', 'There are errors in the form.', 'error');
                    return;
                }

                const clientControls = $("#client-panel .form-control,#client-panel .form-checkbox").toArray();
                let clientServiceModel = {
                    client: { ...clientModel },
                    clientServices: [],
                    isDivision: false
                };

                UnMaskInputs();
                clientControls.map((element, index) => {
                    const elementData =
                        element.hasAttribute('multiple') && element.classList.contains('has-select2') ? $(element).select2('data').map(element => parseInt(element.id)) :
                            element.classList.contains('has-select2') && $(element).select2('data').length > 0 && element.getAttribute('data-saveformat') == 'text' ? $(element).select2('data')[0].text :
                                element.classList.contains('has-select2') && $(element).select2('data').length > 0 && element.getAttribute('data-saveformat') == 'id' ? $(element).select2('data')[0].id :
                                    element.classList.contains('date') ? ConvertDateCustomToIso($(element).val()) :
                                        element.getAttribute('type') == 'checkbox' ? element.checked :
                                            $(element).val();


                    if (element.id == 'ClientServices')
                        return clientServiceModel.clientServices = elementData;
                    if (clientServiceModel.client.hasOwnProperty(element.id))
                        return clientServiceModel.client[element.id] = elementData

                });
                MaskInputs();


                $.ajax({
                    type: 'POST',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url: '<%= get_api%>/api/Client/create', clientServiceModel
                }).then(
                    (clientId) => {
                        var userGroups = $('.client-users').select2('data').map((u) => {
                            return {
                                clientId: clientId,
                                userId: parseInt(u.element.value)
                            }
                        });

                        $.ajax({
                            type: 'POST',
                            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                            url: '<%= get_api%>/api/<%= token%>/Users/assign/client/', { objUsers: userGroups }
                        ).then(
                            () => swal('', 'Client has been created', 'success'),
                            () => swal('', 'The client has been created successfully but users could not be assigned at this time.', 'info')
                        );

                        $('input').not('.btn').val('');
                        $('select').val(0);
                    },
                    () => swal('', 'Your request could not be completed at this time. Please contact support@orgsoln.com.', 'error')
                );
            });

            $(document).on('click', '#isClientDivision', function (element) {
                $('#clientDivisionSection').toggleClass('hidden');
                $("#clientDivisionSection .has-select2").empty().trigger('change');

                if (this.checked) {
                    $('#clientDivisionSection .has-select2').select2();
                    $("#company").select2({
                        ajax: {
                            url: '<%= get_api %>/api/Client/all/query',
                            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                            dataType: 'json',
                            delay: 250,
                            data: function (params) {
                                return {
                                    queryString: params.term,
                                };
                            },
                            processResults: function (data) {
                                const clients = JSON.parse(data);
                                const select2Results = clients.map((client, index) => {
                                    return { "id": client.ClientID, "text": `${client.ClientName}` }
                                })
                                return {
                                    results: select2Results
                                };
                            },
                            cache: true
                        },
                        placeholder: 'Search for a Client',
                        escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
                        minimumInputLength: 2
                    })
                } else {
                    clearFormElementsForSection("#client-panel");
                    $("#clientDivisionSection .has-select2").val(null).trigger('change');
                }
            });

            $(document).on('change', '#userType', function () {
                var clientSelect = $('#client');
                var clientDivisionSection = $('.client-division-section');   
                $('.user-role').empty();

                if (this.value != 0)
                    GetListDiffVal('GetList_Roles?IsInternal=' + (this.value == 1), 'user-role', 'RoleName', 'Role_ID', 'DataBind');

                if (this.value == 1) {
                    clientDivisionSection.addClass('hidden');
                    clientDivisionSection.find('#client-divisions').removeClass('required');
                    clientSelect.attr('multiple', 'multiple');
                }
                else if (this.value == 4) {
                    clientDivisionSection.removeClass('hidden');
                    clientDivisionSection.find('#client-divisions').addClass('required');
                    clientSelect.removeAttr('multiple');
                    clientSelect.trigger('change');
                }
                else {
                    clientDivisionSection.addClass('hidden');                    
                }

                ClearClientDivision();
                clientSelect.select2('destroy');
                clientSelect.select2();
            })

            $(document).on('change', '#client', function () {
                if ($('#userType').val() != 4)
                    return;

                window.ClientID = this.value;
                ClearClientDivision();
                PopulateDivisions(window.ClientID, '.populateDivision');
            });

            $(document).on('change', '#isClientDivision', function () {
                if(this.checked)
                    $('#company, #ParentID, #DivisionName').addClass('required');
                else
                    $('#company, #ParentID, #DivisionName').removeClass('required error');
            })
        });

        function clearFormElementsForSection(sectionId) {
            $(`${sectionId} input`).not('.btn').val('');
            $(`${sectionId} select`).val(0);
        }

        function ClearClientDivision() {
            $('.populateDivision').empty();
            $('.clear-divisions').trigger('click');
        }
       
        //finds logo filepaths 
        function InitLogoSearch() {
            $("#LogoPath").select2({
                ajax: {
                    url: '<%= get_api %>/api/Files/logos/',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    dataType: 'json',
                    delay: 250,
                    data: function (params) {
                        return {
                            queryString: params.term,
                        };
                    },
                    processResults: function (data) {
                        const logoNames = JSON.parse(data);
                        const select2Results = logoNames.map((logoName, index) => {
                            return { "id": index, "text": logoName}
                        })

                        return {
                            results: select2Results
                        };
                    },
                    cache: true
                },
                placeholder: 'Search for a logo',
                escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
                minimumInputLength: 2
            });
        }

        //Get's data associated with select componenent and initializes it
        function initSelectInput(httpRequestLink, targetElementSelector, optionValueProperty, optionTextProperty) {
            $.ajax({
                type: 'GET',
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                url: httpRequestLink,
                success: function (response) {
                    const data = JSON.parse(response);
                    const targetElement = $(targetElementSelector);

                    const options = data.map((datum) => `<option value='${datum[optionValueProperty]}'>${datum[optionTextProperty]}</option>`)
                    targetElement.append(`<option></option>`)
                    targetElement.append(options);

                    targetElement.select2({
                        minimumResultsForSearch: -1,
                        placeholder: targetElement.data('placeholder')
                    })
                }
            });
        }

        function initSearchableSelect2Fields() {
            const initSelect2Objects = [
                {
                    targetElementSelector: "#client",
                    HttpRequestLink: '<%= get_api %>/api/client/all/<%= token%>',
                     optionValueProperty: 'ClientID',
                     optionTextProperty: 'ClientName',
                     transport: function (params) {
                         params.beforeSend = function (request) {
                             request.setRequestHeader("Authentication", window.token);
                         };
                         return $.ajax(params);
                     }
                 },
                 {
                    targetElementSelector: "#BusCountry",
                    HttpRequestLink: '<%= get_api%>/api/OldOrgsysGetData/GetList_Countries',
                    optionValueProperty: 'id',
                    optionTextProperty: 'Country',

                },
                {
                    targetElementSelector: "#ClientServices",
                    HttpRequestLink: '<%= get_api%>/api/servicecontroller/services/<%= token%>',
                    optionValueProperty: 'ServiceID',
                    optionTextProperty: 'Abbreviation'
                }
            ];
            //initialize select componenets with select2 library
            initSelect2Objects.forEach(select => initSelectInput(select.HttpRequestLink, select.targetElementSelector, select.optionValueProperty, select.optionTextProperty));
        }

    </script>

    <style>
        input.error, select.error {
            border: 1px double red;
        }
        div.row {
            padding-bottom : 10px;
        }
        .date {
            background-color : white !important;
        }
        .root-container { 
            padding-top: 20px;
        }
    </style>

</head>
<body>
    <div class="col-md-10 col-md-offset-1">
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
                        <label for="userType">User Type</label>
                        <select id="userType" class="form-control required">
                            <option value="0">Select</option>
                            <option value="1">Internal</option>
                            <option value="4">Portal</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="client">Client Name</label>
                        <select id="client" data-placeholder="Select a Client" class="form-control has-select2 required" multiple="multiple"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="user-role">User Role</label>
                        <select id="user-role" data-placeholder="Select a Role" class="form-control required user-role" ></select>
                    </div>
                </div>
                <div class="row hidden client-division-section">
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
                    <div class="col-md-3">
                        <input id="registerUserBtn" class="form-control btn btn-primary" type="button" value="Register User" />
                    </div>
                </div>
            </div>
        </div>
        <div id="client-panel" class="panel panel-default">
            <div class="panel-heading">
                <h2>Client Onboarding</h2>
            </div>
            <div class="panel-body">
                <div class="row">
                    <label class="col-md-3">
                        <input id="isClientDivision" class="form-checkbox" type="checkbox" />
                        <label for="isClientDivision">Is this a client division? </label>
                    </label>
                </div>
                <div id="clientDivisionSection" class="row hidden">
                    <%--<div class="alert alert-info alert-dismissible col-md-10 col-md-offset-1" role="alert">
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <strong>Info!</strong> If 'Parent Division' is left blank, the division will be applied to the root company.
                    </div>--%>
                    <div class="col-md-3">
                        <label for="company">Select a Client: </label>
                        <select id="company" data-placeholder="Select a Client" data-saveformat="text" class="form-control has-select2"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="ParentID">Select a Parent Division: </label>
                        <select id="ParentID" data-placeholder="Select a Client Division" data-saveformat="id" class="form-control has-select2"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="DivisionName">Division Name: </label>
                        <input id="DivisionName" class="form-control required" type="text" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3">
                        <label for="ClientName">Client Name</label>
                        <input id="ClientName" class="form-control required" type="text" />
                    </div>
                    <div class="col-md-3">
                        <label for="TradeLegalName">Client Trade Legal Name</label>
                        <input id="TradeLegalName" class="form-control required" type="text" />
                    </div>
                    <div class="col-md-3">
                        <label for="ClientUsers">Assign Users</label>
                        <select id="ClientUsers" data-placeholder="Assign Users" class="form-control has-select2 client-users required" multiple="multiple"></select>
                    </div>
                </div>
                <div class="row"></div>
                <div class="row">
                    <div class="col-md-3">
                        <label for="BusCountry">Business Country</label>
                        <select id="BusCountry" data-bus-location-type="COUNTRY" data-placeholder="Select a Country" data-saveformat="text" class="form-control has-select2 required"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="BusProvince" >Business Province</label>
                        <select id="BusProvince" data-bus-location-type="PROVINCE" data-placeholder="Select a Province" data-saveformat="text" class="form-control has-select2 required"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="BusCity">Business City</label>
                        <select id="BusCity" data-bus-location-type="CITY" data-placeholder="Select a City" data-saveformat="text" class="form-control has-select2 required"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="BusPostal">Business Postal</label>
                        <input id="BusPostal" class="form-control vld-postal" type="text" />
                    </div>
                    <div class="col-md-3">
                        <label for="BusFax">Business Fax Number</label>
                        <input id="BusFax" class="form-control vld-phone" type="text" />
                    </div>
                    <div class="col-md-3">
                        <label for="BusTelephone">Business Telephone</label>
                        <input id="BusTelephone" class="form-control required vld-phone" type="text" />
                    </div>
                    <div class="col-md-3">
                        <label for="BusAlternate">Alternative Telephone</label>
                        <input id="BusAlternate" class="form-control vld-phone" type="text" />
                    </div>
                    <div class="col-md-3">
                        <label for="BusActivityDescr">Business Activity Description</label>
                        <input id="BusActivityDescr" class="form-control" type="text" />
                    </div>
                </div>
                <div class="row"></div>
                <div class="row">
                     <div class="col-md-3">
                        <label for="ClientServices">Select Client Services</label>
                        <select id="ClientServices" data-placeholder="Select Client Services" data-saveformat="id" multiple="multiple" class="form-control has-select2 required"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="ClientStartDate">Client Start Date</label>
                        <input id="ClientStartDate" class="form-control required" type="date" />
                    </div>
                    <div class="col-md-3">
                        <label for="LogoPath">Client Logo Path</label>
                        <select id="LogoPath" data-saveformat="text" class="form-control has-select2"></select>
                    </div>
                    <div class="col-md-3">
                        <label for="ImportID">Import ID</label>
                        <input id="ImportID" class="form-control" type="text" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-3">
                        <label>
                            <input id="_20MoreWorkers" class="form-checkbox" type="checkbox" />
                            <label for="_20MoreWorkers" >Employees > 20?</label>
                        </label>
                    </div>
                </div>
                <div class="row"></div>
                <div class="row">
                    <div class="col-md-3">
                        <input id="CreateClientBtn" class="btn btn-primary form-control" type="button" value="Create Client" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
