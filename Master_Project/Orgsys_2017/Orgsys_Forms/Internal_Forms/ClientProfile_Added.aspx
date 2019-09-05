<%@ Page Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="ClientProfile_Added.aspx" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.ClientProfile_Added" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/common/OrgsysUtilities.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="JSFiles/ClientProfile.js"></script>
    <script src="JSFiles/DataBind.js"></script>
    <script src="/Assets/js/select2.min.js"></script>
    <link href="/Assets/css/select2.min.css" rel="stylesheet" type="text/css" />
    <link href="/Assets/css/select2-bootstrap.css" rel="stylesheet" type="text/css" />

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
                        paging: true,
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

                });
        });
    </script>

    <script>
        $(document).ready(function () {
            // Select types of Services
            $('#services').select2({
                placeholder: 'Select Services',
                ajax: {
                    url: `<%= get_api %>/api/servicecontroller/services`,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    processResults: function (data) {
                        var mappedJson = mapJsonForSelect2DataSource(JSON.parse(data), "ServiceID", ["ServiceDescription"]);
                        return {
                            results: mappedJson
                        };
                    }
                }

            });
            //Date Picker 
            $("#StartDateClientProfile").click(function () {
                if ($(this).hasClass('date')) {
                    //will not init without removing class :hasDatepicker
                    InitializeDatepicker($(this).removeClass('hasDatepicker'));
                }

                $('.schedule-input.hasDatepicker').parent().parent().addClass('width_40');
            });

            ////Populate priority order
            //GetList("GetList_Order", "populateOrder", "Desc_EN").done(function () {
            //    $('.populateOrder').val(data[0]['PriorityOrder'])
            //});

            //Populate the 20 or more workers dropdown
            PopulateGenericList("yesno", "populateYesNo", "ListText" + LangGen, "ListValue");

            // Populate the remainining the Dropdown Lists in the Client Portal

            PopulateEAPProviderList("populateEapProvider", "EAPProvider", "EAPProviderID");

            PopulateClaimSubmissionList("populateClaimSubmission", "ClaimSubmissionEN", "ClaimSubmissionID");

            PopulateEvaluationTypeList("populateEvaluationType", "EvaluationTypeEN", "EvaluationTypeID");

            PopulateSTDProcessList("populateSTDProcess", "STDProcessEN", "ddSTDProcessID");

            PopulateSendAPSToEEList("populateSendAPSToEE", "SendApsToEEEN", "SendApsToEEID");

            PopulateProvidesRTWList("PopulateProvidesRTW", "ProvidesRTWEN", "ProvidesRTWID");

            PopulateLTDProviderList("PopulateLTDProvider", "LTDProviderEN", "LTDProviderID");

            PopulateSendLTDToEEList("PopulateSendLTDToEE", "SendLTDToEEEN", "SendLTDToEEID");

            PopulateSendLTDToERList("PopulateSendLTDToER", "SendLTDToEREN", "SendLTDToERID");

            PopulateProvidesWCModDutyFormList("PopulateProvidesWCModDutyForm", "ProvidesRTWEN", "ProvidesRTWID");

            PopulateLegalWCRepList("PopulateLegalWCRep", "LegalWcbRepEN", "LegalWcbRepID");

            PopulateFinancialModelWCBList("PopulateFinancialModelWCB", "FinancialModelWcbEN", "FinancialModelWcbID");

            //Populate the Length Field
            PopulateGenericList("DaysType", "populateWaitPeriodType", "ListText" + LangGen, "ListValue");

            //Populate the [Country] drop down when the form is populated 
            PopulateCountries("populateCountries");

            PopulateProvinces("BusProvince");

            //Attach Event to populate [Province and City drop down]
            AttachCountryEventHandler("BusProvince");
            AttachProvinceEventHandler("BusCity");

            MaskInputs();

            //ATTACH BUTTON EVENT HANDLERS  
            $('#saveclient').on('click', function () {
                ClientAdded();
            });

            $('.add-clientcontact').on('click', function () {
                AddClientContact();
            });


            //$('#evaluationtype').select2({
            //    placeholder: 'Select Services'
            //});

            //$('#approvedby').select2({
            //    placeholder: 'Select Services'
            //});


        });

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





    </script>
    <style>
        .select2-container--default .select2-selection--multiple .select2-selection__choice__remove {
            color: red !important;
        }


        .panel-heading {
            padding: 0 !important;
        }

        .group-custom-input {
            padding-left: 25px;
        }

        .group-input input {
            max-width: 75px;
        }

        .group-input select {
            max-width: 130px;
        }

        .group input {
            max-width: 50px;
        }

        .group select {
            max-width: 75px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper" class="internal_form">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading">
                <h4 id="welcome-header" class="osp-heading panel-heading">Client Profile_Added</h4>
            </div>
            <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div id="ClientDetails" class="tab-pane active" role="tabpanel">
            <div class="panel with-nav-tabs panel-primary">
                <div class="panel-heading">
                    <ul class="tabCheck nav nav-tabs">
                        <li class="nav-item active"><a href="#tab1primary" data-toggle="tab">General Info</a></li>
                        <li class="nav-item"><a href="#tab2primary" data-toggle="tab">General Info 2</a></li>
                        <li class="nav-item"><a href="#tab3primary" data-toggle="tab">STD</a></li>
                        <li class="nav-item"><a href="#tab4primary" data-toggle="tab">STD KPI/CMRs</a></li>
                        <li class="nav-item"><a href="#tab5primary" data-toggle="tab">LTD</a></li>
                        <li class="nav-item"><a href="#tab6primary" data-toggle="tab">WC</a></li>
                        <li class="nav-item"><a href="#tab7primary" data-toggle="tab">WC KPI/CMRs</a></li>
                    </ul>
                </div>
                <div class="panel-body">
                    <div class="tab-content  faq-cat-content">
                        <!--General Info Tab-->
                        <div class="tab-pane fade in active" id="tab1primary">
                            <div id="swal2-content">
                                <div class="row margin_bottom">
                                    <div class="col-md-5">
                                        <label for="Company">Company Name</label>
                                        <input type="text" class="form-control required" name="ClientName" id="CompanyName" placeholder="Company Name" data-original-title="Required" />
                                    </div>
                                    <div class="col-md-5 form_field_setter">
                                        <label class="form_label_setter">Trade / Legal Name</label>
                                        <input type="text" class="form-control required client_profile_textarea" name="TradeLegalName" placeholder="Trade Legal Name" data-original-title="Required" />
                                    </div>
                                </div>

                                <div class="row margin_bottom">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Offered Services</b></></h5>
                                    </div>
                                    <div class="col-md-9">
                                        <label for="OfferedService">Services</label>
                                        <select class="form-control" id="services" name="OfferedService" multiple="multiple">
                                        </select>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Company Information</b></></h5>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label class="form_label_setter">Mailing Address1</label>
                                        <input type="text" class="form-control required" id="BusMailingAddress" name="BusMailingAddress" placeholder="Address1" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label class="form_label_setter">Mailing Address2</label>
                                        <input type="text" class="form-control" id="BusMailingAddress2" name="BusMailingAddress2" placeholder="Address2" data-original-title="Required" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label for="country">Country</label>
                                        <select class="form-control populateCountries required client_profile_textarea" id="BusCountry" name="BusCountry" data-original-title="Required"></select>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label for="province">Province/State:</label>
                                        <select class="form-control required  populateProvinces  required client_profile_textarea" name="BusProvince" id="BusProvince" data-original-title="Required"></select>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="City">City:</label>
                                        <select class="form-control populateCities  required client_profile_textarea" id="BusCity" name="BusCity">
                                        </select>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label for="postalcode">Postal Code</label>
                                        <input type="text" class="form-control vld-postal vlda-BusCountry required client_profile_textarea" name="BusPostal" data-original-title="Required" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter margin-bottom">
                                        <label for="phonenumber">Main Phone</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" name="BusTelephone" maxlength="15" autocomplete="off" data-original-title="Required" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter margin-bottom">
                                        <label for="fax">Fax</label>
                                        <input type="text" class="form-control vld-phone client_profile_textarea" name="BusFax" maxlength="15" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label class="form_label_setter">Activity Description</label>
                                        <input type="text" class="form-control required client_profile_textarea" name="BusActivityDescr" data-original-title="Required" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter margin-bottom">
                                        <label class="form_label_setter">Has 20 Or More Workers?</label>
                                        <select class="form-control populateYesNo client_profile_textarea" name="_20MoreWorkers">
                                        </select>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter margin-bottom">
                                        <label for="DateTo">Start Date</label>
                                        <input type="date" class="form-control hasDatepicker date" name="ClientStartDate" id="StartDateClientProfile" readonly="" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="MainEmail">Main Email</label>
                                        <input type="text" class="form-control col-md-3" name="MainEmail" id="mainEmail" placeholder="Email" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="MainWebsite">Main Website</label>
                                        <input type="text" class="form-control col-md-3" name="MainWebsite" id="mainWebsite" placeholder="Website" />
                                    </div>
                                </div>
                            </div>
                            <%--<div class="row margin_bottom">
                                     <div class="row margin_bottom">
                                        <h5 runat="server"><b>Point of Contact</b></></h5>
                                     </div>
                                    <div class="row margin_bottom">
                                        <div id="ClientContactDetails">
                                            <div>
                                                <button type="button" class="btn btn-default add-clientcontact">
                                                    <i class="icon-plus"></i>
                                                </button>
                                            </div>
                                            <table id="ClientContactDetailsTable" class="table table-bordered table-striped table-condensed table-hover dataTable no-footer">
                                                <thead>
                                                    <tr>
                                                        <th>Actions</th>
                                                        <th>First Name</th>
                                                        <th>Last Name</th>
                                                        <th>Title</th>
                                                        <th>Country</th>
                                                        <th>Province / State</th>
                                                        <th>Address</th>
                                                        <th>City</th>
                                                        <th>Postal Code</th>
                                                        <th>Work Phone</th>
                                                        <th>Mobile Phone</th>
                                                        <th>Email</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>--%>
                            <%-- <div class="row margin_bottom">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Point of Contact</b></></h5>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="ContactName">Name</label>
                                        <input type="text" class="form-control col-md-3" name="ContactName" id="ContactName" placeholder="Name" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="Title">Title</label>
                                        <input type="text" class="form-control col-md-3" name="Title" id="Title" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="Email">Email</label>
                                        <input type="text" class="form-control col-md-3" name="Email" id="Email" placeholder="Email" />
                                    </div>

                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-md-3 form_field_setter">
                                        <label for="Phone">Phone</label>
                                        <input type="tel" class="form-control vld-phone client_profile_textarea" id="Phone" name="Phone" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 form_field_setter">
                                        <label for="Extension">Extension</label>
                                        <input type="tel" class="form-control client_profile_textarea" id="primaryExtension" name="primaryExtension" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 form_field_setter">
                                        <label for="Fax">Fax</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="primaryFax" name="primaryFax" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 form_field_setter">
                                        <label for="priorityorder">Priority Order</label>
                                        <select class="form-control populateOrder" id="PriorityOrder" name="priorityOrder">
                                        </select>
                                    </div>
                                </div>--%>
                        </div>
                        <!--General Info Tab 2-->
                        <div class="tab-pane fade" id="tab2primary">
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <h5 runat="server"><b>Claim Submission Process</b></></h5>

                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-4">
                                            <label for="claimsubmissionprocess">Process:</label>
                                            <select class="form-control populateClaimSubmission" id="ClaimProcess" name="ClaimProcess">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-6 col-md-6 col-sm-12">
                                            <label for="claimsubmissionother">Other:</label>
                                            <input type="text" class="form-control col-md-3" name="ClaimOther" id="ClaimOther" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="row margin_bottom">
                                    <h5 runat="server"><b>EAP Provider Information</b></></h5>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-md-3">
                                        <label for="EAP">EAP</label>
                                        <select class="form-control populateEapProvider" id="EAPProvider" name="EAPProvider">
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-md-3">
                                    <label for="eapName">Name</label>
                                    <input type="text" class="form-control col-md-3" name="EAPName" id="EAPName" placeholder="Name" />
                                </div>
                                <div class="col-md-2 form_field_setter">
                                    <label for="eapPhone">Phone</label>
                                    <input type="text" class="form-control vld-phone client_profile_textarea" name="EAPPhoneNo" id="EAPPhoneNo" maxlength="15" />
                                </div>
                                <div class="col-md-2 form_field_setter">
                                    <label for="eapFax">Fax</label>
                                    <input type="text" class="form-control vld-phone client_profile_textarea" id="EAPFax" name="EAPFax" maxlength="15" />
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-md-3">
                                    <label for="epaEmail">Email</label>
                                    <input type="text" class="form-control col-md-3" name="EAPEmail" id="EAPEmail" placeholder="Email" />
                                </div>
                                <div class="col-md-2 form_field_setter">
                                    <label for="epaExtension">Extension</label>
                                    <input type="text" class="form-control vld-phone  client_profile_textarea" id="EAPExtention" name="EAPExtention" maxlength="15" />
                                </div>
                            </div>
                            <div class="container">
                                <div class="row">
                                    <h5 runat="server"><b>Surveys</b></></h5>
                                </div>
                                <div class="row">
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row">
                                            <div class="col-lg-8 col-md-8 col-sm-8">
                                                <label class="form-check-label" for="surveys"><b>Surveys? (check for yes)</b></label>
                                                <input type="checkbox" data-toggle="toggle" id="SurveyCheck" name="SurveyCheck" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-lg-3 col-md-3 col-sm-4">
                                                <label for="eapName">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="SurveySpecify" name="SurveySpecify" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row">
                                            <h5 runat="server"><b>Select Survey Types (all that apply)</b></></h5>
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="surveytype">STD:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="surveytype">WCB:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="surveytype">Other:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-sm-12 col-md-12 col-lg-12 margin_top_10">
                                                <label for="surveytypetext">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="surveytypetext" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row">
                                            <h5 runat="server"><b>Send Survey To? (all that apply)</b></></h5>
                                             <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="sendsurvey">Employee:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="sendsurvey">WCB:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="sendsurvey">Other:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-sm-12 col-md-12 col-lg-12 margin_top_10">
                                                <label for="sendsurveytext">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="SendSurveySpecify" name="SendSurveySpecify" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row margin_bottom">
                                <h5 runat="server"><b>Who Approves Evaluation?</b></></h5>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-12">
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="evaluationtype">Evaluation Type</label>
                                        <select class="form-control populateEvaluationType" id="EvaluationType" name="EvaluationType">
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="approvedby">Approved By</label>
                                        <input type="text" class="form-control client_profile_textarea" id="ApprovedBy" name="ApprovedBy" maxlength="15" />
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-12">
                                <label for="evaluationtype">General Comments</label>
                                <textarea class="form-control" name="Comments" id="Comments" rows="4" required=""></textarea>
                            </div>
                        </div>
                        <%--<div id="ClientStdLtd">--%>
                         <!--STD Tab-->
                        <div class="tab-pane fade ClientStdLtd" id="tab3primary">
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <h5 runat="server"><b>STD Definition of Disability</b></></h5>
                                    <div class="row margin_bottom incident_description_container">
                                        <label for="definition">Definition:</label>
                                        <textarea class="form-control" name="STD_Definition" id="STD_Definition" rows="3" required=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>STD Program Length</b></></h5>
                                    <div class="input-group group-input group-custom-input">
                                        <input type="text" class="form-control" id="STDLength" name="STDLength" aria-label="Text input with dropdown button" />
                                        <select class="form-control pull-left populateWaitPeriodType" id="STDLength2" name="STDLength2">
                                        </select>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-8 col-md-6 col-sm-6">
                                            <label for="other">Other:</label>
                                            <input type="text" class="form-control col-md-3" name="STDProgramOther" id="STDProgramOther" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>STD Trigger Period</b></></h5>
                                    <div class="col-lg-3 col-md-3 col-sm-12">
                                        <label class="form-check-label" for="triggerperiod">Yes:</label>
                                        <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                    </div>
                                    <div class="col-sm-5 col-md-9 col-lg-9">
                                        <label for="stdtrigger">Specify:</label>
                                        <textarea class="form-control" name="STDTriggerSpecify" id="STDTriggerSpecify" rows="3" required=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <h5 runat="server"><b>STD Process</b></></h5>

                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-4">
                                            <label for="STDProcess">Process:</label>
                                            <select class="form-control populateSTDProcess" id="STDProcess" name="STDProcess">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-6 col-md-6 col-sm-12">
                                            <label for="STDProcessOther">Other:</label>
                                            <input type="text" class="form-control col-md-3" name="STDProcessOther" id="STDProcessOther" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <h5 runat="server"><b>STD Appeals Process</b></></h5>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-1 col-md-1 col-sm-12">
                                            <label class="form-check-label" for="appealsprocess">Yes:</label>
                                            <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                        </div>
                                        <div class="col-lg-4 col-md-4 col-sm-4">
                                            <label for="STDAppealsProcess">Process:</label>
                                            <select class="form-control populateSTDProcess" id="STDAppealsProcess" name="STDAppealsProcess">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-sm-12 col-md-12 col-lg-12 incident_description_container">
                                            <label for="STDAppealsSpecify">Specify:</label>
                                            <textarea class="form-control" name="STDAppealsSpecify" id="STDAppealsSpecify" rows="3" required=""></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                    <h5 runat="server"><b>STD Relapse / Recurrence Definition</b></></h5>
                                    <div class="row margin_bottom">
                                        <label for="relapseorrecurrencedefinition">Definition:</label>
                                        <textarea class="form-control" name="STDRelapseDefinition" id="STDRelapseDefinition" rows="3" required=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-4 col-md-4 col-sm-12">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>STD Appeals - Days to provide intent in writing:</b></></h5>
                                        <label for="stdappealslength">Length:</label>
                                        <div class="input-group group-input">
                                            <input type="text" class="form-control" id="STDAppealsLength" name="STDAppealsLength" aria-label="Text input with dropdown button" />
                                            <select class="form-control pull-left populateWaitPeriodType" id="STDAppealsLength2" name="STDAppealsLength2">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>STD Appeals - Days to provide medical info:</b></></h5>
                                        <label for="stdappealsmedicallength">Length:</label>
                                        <div class="input-group group-input">
                                            <input type="text" class="form-control" id="STDAppealsMedicalLength" name="STDAppealsMedicalLength" aria-label="Text input with dropdown button" />
                                            <select class="form-control pull-left populateWaitPeriodType" id="STDAppealsMedicalLength2" name="STDAppealsMedicalLength2">
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-4 col-md-4 col-sm-12">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Existing STD policy?</b></></h5>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-12">
                                            <label class="form-check-label" for="appealsprocess">Yes:</label>
                                            <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-12 col-md-12 col-sm-12">
                                            <label for="stdpolicy">Specify:</label>
                                            <textarea class="form-control" name="ExistingSTDSpecify" id="ExistingSTDSpecify" rows="4" required=""></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-4 col-md-4 col-sm-12">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Is there a MVA Process in Place?</b></></h5>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-12">
                                            <label class="form-check-label" for="appealsprocess">Yes:</label>
                                            <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-12 col-md-12 col-sm-12">
                                            <label for="mvaprocess">Specify:</label>
                                            <textarea class="form-control" name="MVAProcessSpecify" id="MVAProcessSpecify" rows="4" required=""></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!--STD KPI/CMRs-->
                        <div class="tab-pane fade ClientStdLtd" id="tab4primary">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>STD turnaround for first call following notification:</b></></h5>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-4">
                                            <label for="stdfirstcall">Length:</label>
                                            <div class="input-group group">
                                                <input type="text" class="form-control" id="STDturnaroundnotificationLength" name="STDturnaroundnotificationLength" aria-label="Text input with dropdown button" />
                                                <select class="form-control pull-left populateWaitPeriodType" id="STDturnaroundnotificationLength2" name="STDturnaroundnotificationLength2">
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-8 col-md-6 col-sm-6">
                                            <label for="otherstdfirstcall">Other:</label>
                                            <input type="text" class="form-control col-md-3" name="STDturnaroundnotificationOther" id="STDturnaroundnotificationOther" />
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>STD turnaround for decision following medical / notification:</b></></h5>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-4">
                                            <label for="stdturnaroundmedical">Length:</label>
                                            <div class="input-group group">
                                                <input type="text" class="form-control" id="STDturnaroundMedicalLength" name="STDturnaroundMedicalLength" aria-label="Text input with dropdown button" />
                                                <select class="form-control pull-left populateWaitPeriodType" id="STDturnaroundMedicalLength2" name="STDturnaroundMedicalLength2">
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-8 col-md-6 col-sm-6">
                                            <label for="otherstdturnaroundmedical">Other:</label>
                                            <input type="text" class="form-control col-md-3" name="STDturnaroundMedicalOther" id="STDturnaroundMedicalOther" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <h5 runat="server"><b>STD APS Package & Ability to Provide RTWs</b></></h5>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-6 col-md-6 col-sm-12">
                                            <label for="stdtaps">Who provides employee with APS package?</label>
                                            <select class="form-control populateSendAPSToEE" id="APSPackageProvider" name="APSPackageProvider">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-6 col-md-6 col-sm-12">
                                            <label for="stdrtw">Who confirms ability to provide RTWs?</label>
                                            <select class="form-control PopulateProvidesRTW" id="ProvideRTWs" name="ProvideRTWs">
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                    <h5 runat="server"><b>STD APS Follow Up Instructions:</b></></h5>
                                    <textarea class="form-control" name="STDAPSFollowUpInstructions" id="STDAPSFollowUpInstructions" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                    <h5 runat="server"><b>STD Non-Support Decision Instructions:</b></></h5>
                                    <textarea class="form-control" name="STDNonSupportDecisionInstructions" id="STDNonSupportDecisionInstructions" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                    <h5 runat="server"><b>STD Communication With Payroll Instructions:</b></></h5>
                                    <textarea class="form-control" name="STDCommunicationWithPayrollInstructions" id="STDCommunicationWithPayrollInstructions" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                    <h5 runat="server"><b>STD Other Specific Instructions:</b></></h5>
                                    <textarea class="form-control" name="STDOtherSpecificInstructions" id="STDOtherSpecificInstructions" rows="3" required=""></textarea>
                                </div>
                            </div>
                        </div>
                        <!--LTD Tab-->
                        <div class="tab-pane fade ClientStdLtd" id="tab5primary">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <label for="ltdprovider">LTD Provider:</label>
                                    <select class="form-control PopulateLTDProvider" id="LTDProvider" name="LTDProvider">
                                    </select>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <label for="policynum">Policy Num:</label>
                                    <input type="text" class="form-control col-md-3" name="LTDPolicyNum" id="LTDPolicyNum" />
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>LTD Transfer Initiation & process</b></></h5>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-5 col-md-5 col-sm-12">
                                    <label for="initiation">Initiation before LTD Start date:</label>
                                    <select class="form-control" id="LTDStartdate" name="LTDStartdate">
                                    </select>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <label for="ltdprocess">Process:</label>
                                    <textarea class="form-control" name="LTDProcess" id="LTDProcess" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <label for="ltdformstoee">Who sends LTD forms to EE?</label>
                                    <select class="form-control PopulateSendLTDToEE" id="LTDformsSenderEE" name="LTDformsSenderEE">
                                    </select>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <label for="ltdformstoer">Who sends LTD forms to ER?</label>
                                    <select class="form-control PopulateSendLTDToER" id="LTDformsSenderER" name="LTDformsSenderER">
                                    </select>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>LTD relapse / Recurrence Definition</b></></h5>
                                </div>
                            </div>
                            
                            <div class="row margin_bottom">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <label for="ltdrelapse">Definition:</label>
                                    <textarea class="form-control" name="LTDrelapseDefinition" id="LTDrelapseDefinition" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>LTD specific instructions:</b></></h5>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-12 col-md-12 col-sm-12">
                                    <label for="ltdspecific">Definition:</label>
                                    <textarea class="form-control" name="LTDspecificinstructions" id="LTDspecificinstructions" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>Insurer LTD Case Manager:</b></></h5>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-6 col-md-3 col-md-12">
                                    <label for="ltdcasename">Name</label>
                                    <input type="text" class="form-control col-md-3" name="LTDCaseManagerName" id="LTDCaseManagerName" placeholder="Name" />
                                </div>
                                <div class="col-md-3 col-md-3 col-md-12 form_field_setter">
                                    <label for="ltdcasephone">Phone</label>
                                    <input type="text" class="form-control vld-phone client_profile_textarea" id="LTDCaseManagerPhone" name="LTDCaseManagerPhone" maxlength="15" />
                                </div>
                                <div class="col-md-3 col-md-3 col-md-12 form_field_setter">
                                    <label for="ltdcaseextension">Extension</label>
                                    <input type="text" class="form-control vld-phone client_profile_textarea" id="LTDCaseManagerEXT" name="LTDCaseManagerEXT" maxlength="15" />
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-6 col-md-3 col-md-12">
                                    <label for="ltdcaseemail">Email</label>
                                    <input type="text" class="form-control col-md-3" name="LTDCaseManagerEmail" id="LTDCaseManagerEmail" placeholder="Email" />
                                </div>
                                <div class="col-md-3 col-md-3 col-md-12 form_field_setter">
                                    <label for="ltdcasefax">Fax</label>
                                    <input type="text" class="form-control vld-phone client_profile_textarea" name="LTDCaseManagerFax" id="LTDCaseManagerFax" maxlength="15" />
                                </div>
                            </div>
                        </div>
                        <%--</div>--%>

                        <%--<div id="ClientWc">--%>
                        <div class="tab-pane fade ClientWc" id="tab6primary">
                            <div class="row">
                                <h5 runat="server"><b>WC By Province Information</b></></h5>
                                <div class="col-lg-4 col-md-4 col-sm-12">
                                    <label for="province">Province</label>
                                    <select class="form-control populateProvinces" name="BusProvince" id="BusProvinceWC">
                                    </select>
                                </div>
                                <div class="col-lg-5 col-md-5 col-sm-12">
                                    <label for="wcaccount">Account:</label>
                                    <input type="text" class="form-control col-md-3" name="WCAccount" id="WCAccount" />
                                </div>
                                <div class="col-lg-3 col-md-5 col-sm-12">
                                    <label for="noofemployees">Number of Employees:</label>
                                    <input type="text" class="form-control col-md-3" name="WCEmployees" id="WCEmployees" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="row margin_bottom">
                                    <h5 runat="server"><b>WC - Who Completes the Employer Report (Form 7, ADR, etc)</b></></h5>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="whocompletes">Who Completes:</label>
                                        <select class="form-control PopulateProvidesWCModDutyForm" id="EmployerReportProvider" name="EmployerReportProvider">
                                        </select>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                        <label for="wcspecify">Specify:</label>
                                        <textarea class="form-control" name="WCReportProviderSpecify" id="WCReportProviderSpecify" rows="3" required=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>WC - Who Provides modified Work Duties Form (FAF, AT, etc)</b></></h5>
                                    <label for="whoprovides">Who Provides:</label>
                                    <select class="form-control PopulateProvidesWCModDutyForm" id="WCWorkDutiesProvider" name="WCWorkDutiesProvider">
                                    </select>
                                    <label for="wcprovidesspecify">Specify:</label>
                                    <textarea class="form-control" name="WCWorkDutiesProviderSpecify" id="WCWorkDutiesProviderSpecify" rows="3" required=""></textarea>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>WC - Legal (Tribunal) Representation By</b></></h5>
                                    <label for="wcrepresentative">Representative:</label>
                                    <select class="form-control PopulateLegalWCRep" id="WCLegalRepresentative" name="WCLegalRepresentative">
                                    </select>
                                    <label for="wcrepresentativespecify">Specify:</label>
                                    <textarea class="form-control" name="WCLegalRepresentativeSpecify" id="WCLegalRepresentativeSpecify" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>WC - Client Open to Modified Work Duties?</b></></h5>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-3 col-md-3 col-sm-12">
                                            <label class="form-check-label" for="wcworkduties">Yes:</label>
                                            <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-12 col-md-12 col-sm-12">
                                            <label for="wcworkdutiesspecify">Specify:</label>
                                            <textarea class="form-control" name="WCWorkDutiesModifiedSpecify" id="WCWorkDutiesModifiedSpecify" rows="3" required=""></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>WC - Job Descriptions Available?</b></></h5>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-3 col-md-3 col-sm-12">
                                            <label class="form-check-label" for="wcjobdescription">Yes:</label>
                                            <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-12 col-md-12 col-sm-12">
                                            <label for="wcjobdescriptionspecify">Specify:</label>
                                            <textarea class="form-control" name="WCJobDescriptionsSpecify" id="WCJobDescriptionsSpecify" rows="3" required=""></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <h5 runat="server"><b>WC - WC Process</b></></h5>
                                <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                    <label for="wcprocesspecify">Specify:</label>
                                    <textarea class="form-control" name="WCProcess" id="WCProcess" rows="3" required=""></textarea>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <h5 runat="server"><b>WC - Is There a Process for Transferring Denied WC/CSST Claims to STD?</b></></h5>
                                <div class="row margin_bottom">
                                    <div class="col-lg-1 col-md-1 col-sm-12">
                                        <label class="form-check-label" for="wcworkduties">Yes:</label>
                                        <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                        <label for="wccsst">Specify:</label>
                                        <textarea class="form-control" name="ClaimstoSTDSpecify" id="ClaimstoSTDSpecify" rows="3" required=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <h5 runat="server"><b>CSS Specific - Client pay 1st 14 days?</b></></h5>
                                <div class="row margin_bottom">
                                    <div class="col-lg-1 col-md-1 col-sm-12">
                                        <label class="form-check-label" for="wcworkduties">Yes:</label>
                                        <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-12 col-md-12 col-sm-12 incident_description_container">
                                        <label for="csst">Specify:</label>
                                        <textarea class="form-control" name="CSSSpecificSpecify" id="CSSSpecificSpecify" rows="3" required=""></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="row margin_bottom">
                                <div class="col-lg-4 col-md-4 col-sm-12">
                                    <label for="financialmodel">Client's Financial Model at CSST:</label>
                                    <select class="form-control PopulateFinancialModelWCB" id="ClientFinancialModelatCSST" name="ClientFinancialModelatCSST">
                                    </select>
                                </div>
                            </div>
                            <%-- Save Province To File  --%>
                        </div>
                       <!--WC KPI/CMRs-->
                        <div class="tab-pane fade ClientWc" id="tab7primary">
                            <div class="row margin_bottom">
                                <h5 runat="server"><b>WC - Communication With Payroll Instructions:</b></></h5>
                            </div>
                            <div class="row margin_bottom incident_description_container">
                                <label for="csst"></label>
                                <textarea class="form-control" name="WCCommunicationWithPayrollInstructions" id="WCCommunicationWithPayrollInstructions" rows="4" required=""></textarea>
                            </div>
                        </div>
                       <%-- </div>--%>
                    </div>
                </div>
            </div>
        </div>
        <div class="row margin_bottom text-right">
            <div class="swal2-buttonswrapper" style="display: inline-block;">
                <button type="button" class="swal2-confirm swal2-styled" aria-label="" style="background-color: rgb(48, 133, 214); border-left-color: rgb(48, 133, 214); border-right-color: rgb(48, 133, 214);" id="saveclient">Save Client</button>
            </div>
        </div>
    </div>
</asp:Content>























