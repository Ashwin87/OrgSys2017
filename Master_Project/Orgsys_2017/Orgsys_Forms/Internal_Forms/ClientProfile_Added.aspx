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
        
        $(document).ready(function () {
            $('#existingcompany').select2({
                placeholder: 'Select The Existing Company Name'
            });
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

            $('#evaluationtype').select2({
                placeholder: 'Select Services'
            });

            $('#approvedby').select2({
                placeholder: 'Select Services'
            });

            // Date Picker 
            $("#StartDateClientProfile").click(function () {
                if ($(this).hasClass('date')) {
                    //will not init without removing class :hasDatepicker
                    InitializeDatepicker($(this).removeClass('hasDatepicker'));
                }

                $('.schedule-input.hasDatepicker').parent().parent().addClass('width_40');
            });

            // populate the 20 or more workers dropdown
            PopulateGenericList("yesno", "populateYesNo", "ListText" + LangGen, "ListValue");
        
           //Populate the [Country] drop down when the form is populated 
            PopulateCountries("populateCountries");

           // Attach Event to populate [Province and City drop down]
            AttachCountryEventHandler("BusProvince");
            AttachProvinceEventHandler("BusCity");
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

        <div id="ClientProfileMain">
            <div id="ClientDetails" class="tab-pane active" role="tabpanel">
                <div class="panel with-nav-tabs panel-primary">
                    <div class="panel-heading">
                        <ul class="nav nav-tabs">
                            <li class="active"><a href="#tab1primary" data-toggle="tab">General Info</a></li>
                            <li><a href="#tab2primary" data-toggle="tab">General Info 2</a></li>
                            <li><a href="#tab3primary" data-toggle="tab">STD</a></li>
                            <li><a href="#tab4primary" data-toggle="tab">STD KPI/CMRs</a></li>
                            <li><a href="#tab5primary" data-toggle="tab">LTD</a></li>
                            <li><a href="#tab6primary" data-toggle="tab">WC</a></li>
                            <li><a href="#tab7primary" data-toggle="tab">WC KPI/CMRs</a></li>
                        </ul>
                    </div>
                    <div class="panel-body">
                        <div class="tab-content">
                            <!--General Info Tab-->
                            <div class="tab-pane fade in active" id="tab1primary">
                                <div class="row margin_bottom">
                                    <div class="col-md-5">
                                        <label for="Company">Company</label>
                                        <input type="text" class="form-control" name="ClientName" id="CompanyName" placeholder="Company Name" />
                                    </div>
                                    <div class="col-md-5 form_field_setter">
                                        <label class="form_label_setter">Trade / Legal Name</label>
                                        <input type="text" class="form-control required client_profile_textarea" name="TradeLegalName"  placeholder="Trade Legal Name"/>
                                    </div>
                                </div>

                                <div class="row margin_bottom">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Offered Services</b></></h5>
                                    </div>
                                    <div class="col-md-9">
                                        <label for="Services">Services</label>
                                        <select class="form-control" id="services" name="Services" multiple="multiple">
                                        </select>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>Company Information</b></></h5>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label class="form_label_setter">Mailing Address1</label>
                                        <input type="text" class="form-control" id="BusMailingAddress" name="BusMailingAddress" placeholder="Address1" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label for="country">Country</label>
                                        <select class="form-control populateCountries required client_profile_textarea" id="BusCountry" name="BusCountry"></select>
                                    </div>

                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="City">City:</label>
                                        <select class="form-control populateCities  required client_profile_textarea" id="BusCity" name="BusCity">
                                        </select>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label class="form_label_setter">Mailing Address2</label>
                                        <input type="text" class="form-control" id="BusMailingAddress2" name="BusMailingAddress2" placeholder="Address2" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label for="province">Province/State:</label>
                                        <select class="form-control required  populateProvinces  required client_profile_textarea" name="BusProvince" id="BusProvince"></select>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label for="postalcode">Postal Code</label>
                                        <input type="text" class="form-control vld-postal vlda-BusCountry required client_profile_textarea" name="BusPostal" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter margin-bottom">
                                        <label for="phonenumber">Main Phone</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" name="BusTelephone" maxlength="15" autocomplete="off" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter margin-bottom">
                                        <label for="fax">Fax</label>
                                        <input type="text" class="form-control vld-phone client_profile_textarea" name="BusFax" maxlength="15" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12 form_field_setter">
                                        <label class="form_label_setter">Activity Description</label>
                                        <input type="text" class="form-control required client_profile_textarea" name="BusActivityDescr" />
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
                                        <label for="mainEmail">Main Email</label>
                                        <input type="text" class="form-control col-md-3" name="mainEmail" id="mainEmail" placeholder="Email" />
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="mainWebsite">Main Website</label>
                                        <input type="text" class="form-control col-md-3" name="mainWebsite" id="mainWebsite" placeholder="Website" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
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
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="Phone" name="Phone" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 form_field_setter">
                                        <label for="Extension">Extension</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="primaryExtension" name="primaryExtension" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 form_field_setter">
                                        <label for="Fax">Fax</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="primaryFax" name="primaryFax" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 form_field_setter">
                                        <label for="priorityorder">Priority Order</label>
                                        <select class="form-control" id="priorityorder" name="EAP">
                                        </select>
                                    </div>
                                </div>
                                <div class="row margin_bottom text-right">
                                    <div class="swal2-buttonswrapper" style="display: inline-block;">
                                        <button type="button" class="swal2-confirm swal2-styled" aria-label="" style="background-color: rgb(48, 133, 214); border-left-color: rgb(48, 133, 214); border-right-color: rgb(48, 133, 214);">Add Client</button>
                                        <button type="button" class="swal2-cancel swal2-styled" aria-label="" style="display: inline-block; background-color: rgb(170, 170, 170);">Cancel</button>
                                    </div>
                                </div>
                            </div>
                            <!--General Info Tab 2-->
                            <div class="tab-pane fade" id="tab2primary">
                                <div class="row">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>EAP Provider Information</b></></h5>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-md-3">
                                            <label for="EAP">EAP</label>
                                            <select class="form-control" id="EAP" name="EAP">
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-md-3">
                                        <label for="eapName">Name</label>
                                        <input type="text" class="form-control col-md-3" name="eapName" id="EAPName" placeholder="Name" />
                                    </div>
                                    <div class="col-md-2 form_field_setter">
                                        <label for="eapPhone">Phone</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" name="eapPhone" id="EAPPhone" maxlength="15" />
                                    </div>
                                    <div class="col-md-2 form_field_setter">
                                        <label for="eapFax">Fax</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="eapFax" name="eapFax" maxlength="15" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-md-3">
                                        <label for="epaEmail">Email</label>
                                        <input type="text" class="form-control col-md-3" name="epaEmail" id="epaEmail" placeholder="Email" />
                                    </div>
                                    <div class="col-md-2 form_field_setter">
                                        <label for="epaExtension">Extension</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="epaExtension" name="epaExtension" maxlength="15" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="row">
                                        <h5 runat="server"><b>Surveys</b></></h5>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row margin_bottom">
                                            <div class="col-lg-10 col-md-10 col-sm-12">
                                                <label class="form-check-label" for="surveys"><b>Surveys? (check for yes)</b></label>
                                                <input type="checkbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-12 col-md-12 col-sm-12">
                                                <label for="eapName">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="specify" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row">
                                            <h5 runat="server"><b>Select Survey Types (all that apply)</b></></h5>
                                        </div>
                                        <div class="row">
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
                                        </div>
                                        <div class="row">
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
                                                <textarea class="swal2-textarea" placeholder="" id="sendsurveytext" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <h5 runat="server"><b>Who Approves Evaluation?</b></></h5>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <div class="col-md-12">
                                        <label for="evaluationtype">Evaluation Type</label>
                                        <select class="form-control" id="evaluationtype" name="evaluationtype">
                                        </select>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="approvedby">Approved By</label>
                                            <select class="form-control" id="approvedby" name="approvedby">
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 col-md-6 col-sm-12">
                                    <h5 runat="server"><b>General Comments</b></></h5>
                                    <textarea class="swal2-textarea" cols="" placeholder="" id="generalComments" style="display: block;"></textarea>
                                </div>
                            </div>
                            <!--STD Tab-->
                            <div class="tab-pane fade" id="tab3primary">
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD Definition of Disability</b></></h5>
                                        <div class="row margin_bottom">
                                            <label for="definition">Definition:</label>
                                            <textarea class="swal2-textarea" cols="" placeholder="" id="definition" style="display: block;"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <h5 runat="server"><b>STD Program Length</b></></h5>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-4 col-md-4 col-sm-4">
                                                <label for="programlength">Length:</label>
                                                <select class="form-control" id="programlength" name="programlength">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-8 col-md-6 col-sm-6">
                                                <label for="other">Other:</label>
                                                <input type="text" class="form-control col-md-3" name="other" id="other" />
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
                                            <textarea class="swal2-textarea" placeholder="" id="stdtrigger" style="display: block;"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD Process</b></></h5>

                                        <div class="row margin_bottom">
                                            <div class="col-lg-4 col-md-4 col-sm-4">
                                                <label for="stdprocess">Process:</label>
                                                <select class="form-control" id="stdprocess" name="appealsprocess">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-6 col-md-6 col-sm-12">
                                                <label for="otherProcess">Other:</label>
                                                <input type="text" class="form-control col-md-3" name="other" id="otherProcess" />
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
                                                <label for="appealsprocess">Process:</label>
                                                <select class="form-control" id="appealsprocess" name="appealsprocess">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-sm-12 col-md-12 col-lg-12">
                                                <label for="stdappeals">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="stdappeals" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD Relapse / Recurrence Definition</b></></h5>
                                        <div class="row margin_bottom">
                                            <label for="relapseorrecurrencedefinition">Definition:</label>
                                            <textarea class="swal2-textarea" cols="" placeholder="" id="rrdefinition" style="display: block;"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row margin_bottom">
                                            <h5 runat="server"><b>STD Appeals - Days to provide intent in writing:</b></></h5>
                                            <label for="stdappealslength">Length:</label>
                                            <select class="form-control" id="stdappealslength" name="stdappealslength">
                                            </select>
                                        </div>
                                        <div class="row margin_bottom">
                                            <h5 runat="server"><b>STD Appeals - Days to provide medical info:</b></></h5>
                                            <label for="stdappealsmedicallength">Length:</label>
                                            <select class="form-control" id="stdappealsmedicallength" name="stdappealsmedicallength">
                                            </select>
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
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label for="stdpolicy">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="stdpolicy" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <div class="row margin_bottom">
                                            <h5 runat="server"><b>Is there an MVA Process in Place?</b></></h5>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label class="form-check-label" for="appealsprocess">Yes:</label>
                                                <input type="checkbox" class="customcheckbox" data-toggle="toggle" data-size="small" data-on="yes" data-off="no" data-offstyle="danger" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-4 col-md-4 col-sm-12">
                                                <label for="mvaprocess">Specify:</label>
                                                <textarea class="swal2-textarea" placeholder="" id="mvaprocess" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!--STD KPI/CMRs-->
                            <div class="tab-pane fade" id="tab4primary">
                                <div class="row">
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <h5 runat="server"><b>STD turnaround for first call following notification:</b></></h5>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-4 col-md-4 col-sm-4">
                                                <label for="stdfirstcall">Length:</label>
                                                <select class="form-control" id="stdfirstcall" name="stdturnaround">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-8 col-md-6 col-sm-6">
                                                <label for="otherstdfirstcall">Other:</label>
                                                <input type="text" class="form-control col-md-3" name="other" id="otherstdfirstcall" />
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <h5 runat="server"><b>STD turnaround for decision following medical / notification:</b></></h5>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-4 col-md-4 col-sm-4">
                                                <label for="stdturnaroundmedical">Length:</label>
                                                <select class="form-control" id="stdturnaroundmedical" name="stdturnaroundmedical">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-8 col-md-6 col-sm-6">
                                                <label for="otherstdturnaroundmedical">Other:</label>
                                                <input type="text" class="form-control col-md-3" name="otherstdturnaroundmedical" id="otherstdturnaroundmedical" />
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
                                                <select class="form-control" id="stdtaps" name="stdtaps">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-lg-6 col-md-6 col-sm-12">
                                                <label for="stdrtw">Who confirms ability to provide RTWs?</label>
                                                <select class="form-control" id="stdrtw" name="stdrtw">
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD APS Follow Up Instructions:</b></></h5>
                                        <textarea class="swal2-textarea" placeholder="" id="stdapsfollowup" style="display: block;"></textarea>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD Non-Support Decision Instructions:</b></></h5>
                                        <textarea class="swal2-textarea" placeholder="" id="stdnonsupport" style="display: block;"></textarea>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD Communication With Payroll Instructions:</b></></h5>
                                        <textarea class="swal2-textarea" placeholder="" id="stdcommunicationpayroll" style="display: block;"></textarea>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <h5 runat="server"><b>STD Other Specific Instructions:</b></></h5>
                                        <textarea class="swal2-textarea" placeholder="" id="stdotherspecific" style="display: block;"></textarea>
                                    </div>
                                </div>
                            </div>
                            <!--LTDTab-->
                            <div class="tab-pane fade" id="tab5primary">
                                <div class="row">
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <label for="ltdprovider">LTD Provider:</label>
                                        <select class="form-control" id="ltdprovider" name="ltdprovider">
                                        </select>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <label for="policynum">Policy Num:</label>
                                        <select class="form-control" id="policynum" name="ltdprovider">
                                        </select>
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
                                        <select class="form-control" id="initiation" name="initiation">
                                        </select>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <label for="ltdprocess">Process:</label>
                                        <textarea class="swal2-textarea" placeholder="" id="ltdprocess" style="display: block;"></textarea>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <label for="ltdformstoee">Who sends LTD forms to EE?</label>
                                        <select class="form-control" id="ltdformstoee" name="ltdformstoee">
                                        </select>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <label for="ltdformstoer">Who sends LTD forms to ER?</label>
                                        <select class="form-control" id="ltdformstoer" name="ltdformstoer">
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
                                        <textarea class="swal2-textarea" placeholder="" id="ltdrelapse" style="display: block;"></textarea>
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
                                        <textarea class="swal2-textarea" placeholder="" id="ltdspecific" style="display: block;"></textarea>
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
                                        <input type="text" class="form-control col-md-3" name="ltdcasename" id="ltdcasename" placeholder="Name" />
                                    </div>
                                    <div class="col-md-3 col-md-3 col-md-12 form_field_setter">
                                        <label for="ltdcasephone">Phone</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="ltdcasephone" name="ltdcasephone" maxlength="15" />
                                    </div>
                                    <div class="col-md-3 col-md-3 col-md-12 form_field_setter">
                                        <label for="ltdcaseextension">Extension</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" id="ltdcaseextension" name="primaryExtension" maxlength="15" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-6 col-md-3 col-md-12">
                                        <label for="ltdcaseemail">Email</label>
                                        <input type="text" class="form-control col-md-3" name="ltdcasename" id="ltdcaseemail" placeholder="Email" />
                                    </div>
                                    <div class="col-md-3 col-md-3 col-md-12 form_field_setter">
                                        <label for="ltdcasefax">Fax</label>
                                        <input type="text" class="form-control vld-phone required client_profile_textarea" name="ltdcasefax" id="ltdcasefax" maxlength="15" />
                                    </div>
                                </div>
                            </div>
                            <div class="tab-pane fade" id="tab6primary">
                                <div class="row">
                                    <h5 runat="server"><b>WC By Province Information</b></></h5>
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="province">Province</label>
                                        <select class="form-control" id="province" name="province">
                                        </select>
                                    </div>
                                    <div class="col-lg-5 col-md-5 col-sm-12">
                                        <label for="wcaccount">Account:</label>
                                        <input type="text" class="form-control col-md-3" name="wcaccount" id="wcaccount" />
                                    </div>
                                    <div class="col-lg-3 col-md-5 col-sm-12">
                                        <label for="noofemployees">Number of Employees:</label>
                                        <input type="text" class="form-control col-md-3" name="noofemployees" id="noofemployees" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="row margin_bottom">
                                        <h5 runat="server"><b>WC - Who Completes the Employer Report (Form 7, ADR, etc)</b></></h5>
                                        <div class="col-lg-4 col-md-4 col-sm-12">
                                            <label for="whocompletes">Who Completes:</label>
                                            <select class="form-control" id="whocompletes" name="whocompletes">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin_bottom">
                                        <div class="col-lg-4 col-md-4 col-sm-12">
                                            <label for="wcspecify">Specify:</label>
                                            <textarea class="swal2-textarea" placeholder="" id="wcspecify" style="display: block;"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <h5 runat="server"><b>WC - Who Provides modified Work Duties Form (FAF, AT, etc)</b></></h5>
                                        <label for="whoprovides">Who Provides:</label>
                                        <select class="form-control" id="whoprovides" name="whoprovides">
                                        </select>
                                        <label for="wcprovidesspecify">Specify:</label>
                                        <textarea class="swal2-textarea" placeholder="" id="wcprovidesspecify" style="display: block;"></textarea>
                                    </div>
                                    <div class="col-lg-6 col-md-6 col-sm-12">
                                        <h5 runat="server"><b>WC - Legal (Tribunal) Representation By</b></></h5>
                                        <label for="wcrepresentative">Representative:</label>
                                        <select class="form-control" id="wcrepresentative" name="wcrepresentative">
                                        </select>
                                        <label for="wcrepresentativespecify">Specify:</label>
                                        <textarea class="swal2-textarea" placeholder="" id="wcrepresentativespecify" style="display: block;"></textarea>
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
                                                <textarea class="swal2-textarea" placeholder="" id="wcworkdutiesspecify" style="display: block;"></textarea>
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
                                                <textarea class="swal2-textarea" placeholder="" id="wcjobdescriptionspecify" style="display: block;"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <h5 runat="server"><b>WC - WC Process</b></></h5>
                                    <div class="col-lg-12 col-md-12 col-sm-12">
                                        <label for="wcprocesspecify">Specify:</label>
                                        <textarea class="swal2-textarea" placeholder="" id="wcprocesspecify" style="display: block;"></textarea>
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
                                        <div class="col-lg-12 col-md-12 col-sm-12">
                                            <label for="wccsst">Specify:</label>
                                            <textarea class="swal2-textarea" placeholder="" id="wccsst" style="display: block;"></textarea>
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
                                        <div class="col-lg-12 col-md-12 col-sm-12">
                                            <label for="csst">Specify:</label>
                                            <textarea class="swal2-textarea" placeholder="" id="csst" style="display: block;"></textarea>
                                        </div>
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-lg-4 col-md-4 col-sm-12">
                                        <label for="financialmodel">Client's Financial Model at CSST:</label>
                                        <select class="form-control" id="financialmodel" name="financialmodel">
                                        </select>
                                    </div>
                                </div>
                                <%-- Save Province To File  --%>
                            </div>
                            <!--WC KPI/CMRs-->
                            <div class="tab-pane fade" id="tab7primary">
                                <div class="row margin_bottom">
                                    <h5 runat="server"><b>WC - Communication With Payroll Instructions:</b></></h5>
                                </div>
                                <div class="row margin_bottom">
                                    <label for="csst"></label>
                                    <textarea class="swal2-textarea" placeholder="" id="wccommunication" style="display: block;"></textarea>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>























