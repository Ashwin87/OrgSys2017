<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="Form7.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.Form7" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    <script src="../Internal_Forms/JSFiles/DataBind.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="JSFilesExternal/Navigation.js"></script>
    <script src="JSFilesExternal/WitnessAdditions.js"></script>
    <script src="JSFilesExternal/ScheduleAdditions.js"></script>
    <script src="JSFilesExternal/FileInput.js"></script>
    <script src="JSFilesExternal/PopulateExternal.js"></script>
    <script src="JSFilesExternal/ViewClaim.js"></script>
    <script src="JSFilesExternal/Swals.js"></script>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="/Assets/js/common/OrgsysUtilities.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="/Assets/js/common/SendEmail.js"></script>    
    <script src="/Assets/js/promise-polyfill.js"></script><!-- for ie -->
    <script src="/Assets/js/select2.min.js"></script>
    <link href="/Assets/css/select2.min.css" rel="stylesheet" type="text/css"/>
    <link href="/Assets/css/select2-bootstrap.css" rel="stylesheet" type="text/css"/>
    <script src="/Assets/js/orgsysNavbar.js"></script>
    <script src="../../Assets/js/jquery.easy-autocomplete.min.js"></script>
    <link href="../../Assets/css/easy-autocomplete.min.css" rel="stylesheet" />

    <link type="text/css" rel="stylesheet" href="/Assets/css/bootstrap-timepicker.min.css" />
    <script type="text/javascript" src="/Assets/js/time-picker/bootstrap-timepicker.min.js"></script>
    <script>
        /* Created By   : Sam Khan
           Create Date  : 2017 -05-16
           Update Date  : 2017-07-07 [Added comments and did code clean up, and put all the function in an order]
           Description  : It loads and saves the claim data,applies business rules and validations.
           Updated by   : Sam Khan*/
        $(document).ready(function () {
            //Global variables to be used in this form
            var results = [];
            var tableInfo = [];
            var FormID = parseInt($.url().param('FormID'));
            var ViewClaim = $.url().param('ViewClaim') ? true : false
            var claimData, claimStatus;
            window.ClaimID = parseInt($.url().param('ClaimID'));
            window.Token = "<%= token%>";
            window.token = "<%= token%>";
            window.getApi = "<%= get_api%>";
            window.fileArray = [];
            window.claimType = GetClaimType(FormID);
            GetDataGeneric('Client', 'GetClientDetails', "<%= token%>").then(function (client) {
                window.ClientID = client[0].ClientID;
            }).then(function () {
                $('#form-title h4').append(window.claimType + ' Form');
                try {
                    if (ClaimID) {
                        LoadControlsWithValues();
                    }
                    else
                        LoadControls();
                }
                finally {
                    AttachFileUploadHandler('input[type="file"]', FileUpload_AddControls, 0)
                }
            });
            //these arrays holds id values of subsections whose children are to be formatted into grid of specific size //abovtenko
            var colMd3SubSections = [];
            var colMd2SubSections = [];
            var colMd6SubSections = [];
            var yesNoControlNames = [];
            var yesNoControlNames = [];
            //When the form is loaded....
            //It gets all the controls from db to create a dynamic form      
            
            GetProfilesForAutocomplete();
            /**
             * Get forms controls and populates into DOM, building the forms pages.
             */
            function LoadControls() {
                $('#form-actions, #form-tabs').show();
                //I have to change it 
                $.ajax({
                    type: "GET",
                    beforeSend: function (xhr) {
                        xhr.setRequestHeader('Language', window.Language);
                        xhr.setRequestHeader('Authentication', window.token);
                    },
                    async: false,
                    url: "<%= get_api %>/api/Form/GetFormControlsV2/" + Token + "/" + FormID,
                    success: function (data) {
                        results = JSON.parse(data);
                    },
                    error: function (data) {
                    }
                })
                .then(
                    function () {
                        CreateDivSections(results);
                        tableInfo = PopulateControls2(results);
                        GetBusinessRules();
                        CreateBsColumns('col-md-3 form_field_setter', colMd3SubSections, 4);
                        CreateBsColumns('col-md-2', colMd2SubSections, 5);
                        CreateBsColumns('col-md-6', colMd6SubSections, 2);
                        PopulateListsExternal().done(function () {
                            if (FormID == 1) {
                                PopulateClientDetails(GetControlsByGroupName('ClientDetails'));
                            }
                            //attach handler to fields that may populate user details depending on selection
                            $('.popUserTrigger').each(function () {
                                AttachUserPopulationHandler($(this));
                            });
                            $('.dep-on').trigger('change');
                        });
                        PopulateCountries();
                        GetDataGeneric('DataBind', 'GetUserInfo_External', Token).done(function (data) {
                            PopulateSubmitterDetails(data);
                            MaskInputs();
                        })
                        InitializeDatepicker();
                        $('.timepicker input').timepicker({
                            defaultTime: false
                        });
                        $('[name="Description"]').val(claimType);
                        //set the date creation field to todays date, disable editing
                        var dateCreation = $('[name="DateCreation"]');
                        SetIsoDateFormat(dateCreation, new Date().toISOString());
                        dateCreation.attr('disabled', 'disabled').addClass('print-view');
                    },
                    function () {
                        alert("$.get failed!");
                    }
                );
            }
            /**
             * Get forms controls and populates into DOM, building the forms pages and then setting the data.
             */
            function LoadControlsWithValues() {
                GetDataGeneric('Claim', 'GetClaimData', [Token, ClaimID]).then(ReplaceDFValues).done(function (data) {
                    claimData = data[0];
                });
                $.ajax({
                    type: "GET",
                    beforeSend: function (xhr) {
                        xhr.setRequestHeader('Language', window.Language);
                        xhr.setRequestHeader('Authentication', window.token);
                    },
                    async: false,
                    url: "<%= get_api %>/api/Form/GetFormControlsV2/" + Token + "/" + FormID,
                    success: function (data) {
                    },
                    error: function (data) {
                    }
                }).then(function (data) {
                    results = JSON.parse(data);
                    CreateDivSections(results);
                    tableInfo = PopulateControls2(results);
                    GetBusinessRules();
                    CreateBsColumns('col-md-3', colMd3SubSections, 4);
                    CreateBsColumns('col-md-2', colMd2SubSections, 5);
                    CreateBsColumns('col-md-6', colMd6SubSections, 2);
                    InitializeDatepicker();
                    $('.timepicker input').timepicker({
                        defaultTime: false
                    });
                }).then(function () {
                    PopulateWitnesses(!ViewClaim);
                    PopulateClaimContacts();
                    PopulateOtherEarnings();
                    PopulateICDCMCatPart();
                    GetDataGeneric('DataBind', 'GetUserInfo_External', Token).done(PopulateSubmitterDetails);
                    GetDataGeneric('Claim', 'GetClaimDates', ClaimID).then(ReplaceDFValues).done(PopulateClaimDates);
                    GetDataGeneric('Databind', 'GetEmployeeContacts', [Token, ClaimID]).done(PopulateEmployeeContactsExternal);
                    GetDataGeneric('Claim', 'GetAbsencesDetails', ClaimID).then(ReplaceDFValues).done(PopulateAbsenceDetails);
                    GetDataGeneric('Databind', 'GetContactsByType', [ClaimID, 1]).done(PopulateHealthProfessional);
                    GetDataGeneric('Claim', 'GetClaimInjuryCause_IncidentTypes', [Token, ClaimID]).then(PopulateIncidentTypesCB);
                    //country dropdown must be populated before values can be selected; ajax call within is now async:false //abovtenko
                    PopulateCountries();
                    PopulateListsExternal().done(function () {
                        PopulateSchedule(!ViewClaim);
                        PopulateClaimData(claimData);
                        MaskInputs();
                        $('[name="Description"]').val(claimType);
                        if (!ViewClaim) {
                            //set the date creation field to todays date, disable editing
                            var dateCreation = $('[name="DateCreation"]');
                            SetIsoDateFormat(dateCreation, new Date().toISOString());
                            dateCreation.attr('disabled', 'disabled').addClass('print-view');
                            //append file icons of files related to this claim
                            GetDataGeneric('Databind', 'GetDocuments', claimData.ClaimRefNu).then(ReplaceDFValues).done(ShowFilesDraft);
                            //attach handler to fields that may populate user details depending on selection
                            $('.popUserTrigger').each(function () {
                                AttachUserPopulationHandler($(this));
                            });
                            $('.dep-on').trigger('change');
                            $('#form-actions, #form-tabs').show();
                        }
                        else {
                            $('.dep-on').trigger('change');
                            ViewClaimReadOnly(claimData);
                        }
                    });
                });
            }
            /**
             * Creates Divs for each section respectively
             */
            function CreateDivSections() {
                var count = GetSectionCount();
                for (var i = 1; i <= count; i++) {
                    $('#form-content').append('<div id="Section' + i + '" class="section tab-pane fade in"></div>');
                }
                $('#Section1').addClass('active');
            }
            /**
             * Get the total number of sections
             */
            function GetSectionCount() {
                var sectionIds = [];
                for (var i = 1; i < results.length; i++) {
                    if (sectionIds.indexOf(results[i].SectionID) == -1) {
                        sectionIds.push(results[i].SectionID);
                    }
                }
                return sectionIds.length;
            }  
            /**
             * Creates and appends the html for the form from control data.
             * @param controls
             */
            function PopulateControls2(controls) {
                var groupedControls = GroupByProperty(controls, 'GroupName')
                var tableInfo = [];
                    var max = 0;
                for (var i = 0; i < groupedControls.length; i++) {
                    var section = $('#Section' + groupedControls[i].data[0].SectionID);
                    var subSection = false;
                    //groups that are a table must have their name end in [Table] by convention
                    var isTable = /Table$/.test(groupedControls[i].groupId);
                    var tableID = undefined;
                    var rowNumber = undefined;
                    $.each(groupedControls[i].data, function (key, val) {
                        //identify controls that are part of a table
                        var type = (isTable) ? 'table.' + val.ControlType : val.ControlType
                        //at the begining of each group, subsection is set to false
                        //  and it will only be created by a label
                        //if there is no subsection, append to the section
                        var domTarget = (!subSection) ? section : subSection;
                        switch (type) {
                            case 'section-tab':
                                $('#form-tabs').append('<li id="' + val.GroupName + '"><a class="form_link_setter" href="#Section' + val.SectionID + '" data-toggle="tab">' + val.Value + '</a></li>');
                                if (val.SectionID === 1) {
                                    $('#Section1Tab').addClass('active');
                                }
                                var lastSection;
                                $(val.SectionID).each(function () {
                                    max = val.SectionID;
                                    lastSection = val;
                                });
                                $("#form-tabs").click(function () {
                                    $('.schedule-input.hasDatepicker').parent().parent().addClass('width_10');
                                });
                                break;                            
                            case 'label':
                                SetGroupingArray(val.CssClass, 'subsection-col-md-3', colMd3SubSections, val.GroupName);
                                SetGroupingArray(val.CssClass, 'subsection-col-md-2', colMd2SubSections, val.GroupName);
                                SetGroupingArray(val.CssClass, 'subsection-col-md-6', colMd6SubSections, val.GroupName);
                                subSection = CreateFormSubsection(section, val.GroupName, val.ControlLabel, val.CssClass);
                                break;
                            case 'table.label':
                                $('#' + tableID + ' > thead > tr').append('<th class="' + val.CssClass + '">' + val.ControlLabel + '</th>');
                                break;
                            case 'table.table':
                                subSection = CreateFormSubsection(section, val.GroupName, val.ControlLabel, val.CssClass);
                                subSection.append('<div class="table-responsive"><table id="' + val.ControlID + '" name="' + val.ControlName + '" class="table table-bordered table-striped table-hover dataTable no-footer earning_details_table"><thead><tr></tr></thead><tbody></tbody></table></div>');
                                tableID = val.ControlID;
                                rowNumber = 0;
                                break;
                            case 'table.text':
                            case 'table.checkbox':
                            case 'table.date':
                                if (rowNumber != val.RowNu) {
                                    rowNumber = val.RowNu;
                                    $('#' + tableID + ' > tbody').append('<tr id="wk' + rowNumber + '"><td>' + rowNumber + '</td></tr>');
                                }
                                $('#' + tableID + ' > tbody > tr[id=wk' + rowNumber + ']').append('<td><input id="' + val.ControlID + '"type="' + val.ControlType + '" name="' + val.ControlName + '"  value="' + val.Value + '" class="' + val.CssClass + '"/></td>');
                                break;
                            default:
                                if (type === 'select') {
                                    SetGroupingArray(val.CssClass, 'yes-no', yesNoControlNames, val.ControlName);
                                }
                                var item = GetFormComponent(type, val.ControlID, val.ControlName, val.Value, val.CssClass, val.ControlLabel, val.PlaceHolder);
                                domTarget.append(item)
                                break;
                        }
                        AttachControlEventHandlers(val);
                        var controlObject = {
                            ControlName : val.ControlName,
                            TableName : val.TableName,
                            ColumnName : val.ColumnName,
                            ID : val.ControlID,
                            GroupName : val.GroupName,
                            OtherDataType : val.OtherDataType,
                            Class : val.CssClass,
                            Value : val.Value,
                            Row : val.RowNu,
                            ColumnType : val.ColumnType,
                            ControlType : val.ControlType
                        }
                        tableInfo.push(controlObject);
                    });
                }
                 $("#Section" + max).addClass('display_submit');
                var submit_button = $("#Section" + max).val();
                $("#form-tabs").click(function () {
                    $("#main-container").mousemove(function () {
                        if ($(".display_submit").hasClass("active")) {
                            $('.btn-success').prop("disabled", false);
                            $("#form-actions").addClass("submit_button_visible");
                        }
                        else {
                            $("#form-actions").removeClass("submit_button_visible");
                        }
                    });
                });
                $("#btnNextBottom").click(function () {
                    $("#main-container").mousemove(function () {
                        if ($(".display_submit").hasClass("active")) {
                            $("#form-actions").addClass("submit_button_visible");
                        }
                        else {
                            $("#form-actions").removeClass("submit_button_visible");
                        }
                    });
                }); 
                $('.hasSelect2').select2();
                return tableInfo;
            }
            //It adds the classes to the controls //xxx
            function GetBusinessRules() {
                $.ajax({
                    url: "<%= get_api %>/api/Form/GetBusRules/" + Token + "/" + FormID,
                     beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    type: "Get",
                    async: false,
                    success: function (data) {
                        var results = JSON.parse(data);
                        for (i = 0; i < results.length; i++) {
                            $('[name="' + results[i]["ControlName"] + '"]').addClass(results[i]["Class"]);
                            $('#' + results[i]["ControlName"]).addClass(results[i]["Class"]); //subsections use controlname as id //abovtenko
                            //It would make the fields as read only
                            if (results[i]["ReadOnly"] == true) {
                                $('[name="' + results[i]["ControlName"] + '"]').attr('readonly', 'readonly');
                            }
                            if (results[i]["DemographicColumn"] != null) { //Adds a demographiccolumn attr to the control if it exists //mgougeon
                                $('[name="' + results[i]["ControlName"] + '"]').attr('data-demographicinfo', results[i]["DemographicColumn"]);
                            }
                        }
                    },
                    error: function (msg) {
                    }
                });
            }
            $('#btnSubmit').click(function (e) { 
                $.getJSON(getApi + "/api/Validate/CheckIfTokenValid/" + Token).then(function (data) {
                    //return type to be changed to bool later /abovtenko
                    if (data == '10001') {
                        UnMaskInputs()
                        var claimValid = validate.validateSubmission();
                        MaskInputs()
                        if (claimValid) {
                            swal({
                                title: 'Submitting Claim...',
                                allowOutsideClick: false
                            });
                            swal.showLoading();
                            SaveClaimByTableOrder(9); //Form is valid the claim is saved in to database
                        }
                        else {
                            ShowValidationErrorsSwal();
                            JumpToErrorSection();
                        }
                    }
                })
            });
            $('#btnDraft').click(function (e) {
                swal({
                    title: 'Draft Claim',
                    text: 'This claim will be saved as a draft and can be completed at a later time. Do you wish to proceed?',
                    type: 'info',
                    showCancelButton: true,
                    confirmButtonText: 'Yes'
                }).then(function () {
                    $.getJSON(getApi + "/api/Validate/CheckIfTokenValid/" + Token).then(function (data) {
                        //return type to be changed to bool later /abovtenko
                        if (data == '10001') {
                            UnMaskInputs();
                            var draftValid = validate.validateAllWithValues();
                            MaskInputs();
                            if (draftValid) {
                                SaveClaimByTableOrder(0); //Form is valid the claim is saved in to database
                            }
                            else {
                                ShowValidationErrorsSwal();
                                JumpToErrorSection();
                            }
                        }
                    });
                });
            });
            /**
             * Prepares data for saving and saves claim.
             * @param status
             */
            function SaveClaimByTableOrder(status) {
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url:"<%= get_api %>/api/Form/GetTableOrder/false",
                    success: function (data) {
                       var results = JSON.parse(data);
                    UnMaskInputs();
                    var claimControlData = GetControlValues(results); //Gets all the fields values
                    MaskInputs();
                    console.log(claimControlData);
                    SaveClaim(claimControlData, status); //Saves the claim in data base
                    }
                });
            }
            /**
             * Gets entered form data by table order.
             * @param tableOrder
             */
            function GetControlValues(tableOrder) {
                var child = new Array();
                var val;
                for (var i = 0; i < tableOrder.length; i++) {
                    var cols = new Array();
                    for (var s = 0; s < tableInfo.length; s++) {
                        if (tableInfo[s].TableName != null) {
                            if (tableInfo[s].TableName == tableOrder[i].TableName) {
                                var type = tableInfo[s].ControlType;
                                var control = $('#' + tableInfo[s].ID);
                                if(control.length === 0 || control.hasClass('no-save')) continue;   
                                //Checking the types of input .....CheckBox
                                if (type == 'checkbox') {
                                    if (control.prop("checked")) {
                                        var val = control.val();
                                        cols.push({ 'ColumnName': tableInfo[s].ColumnName, 'Value': val, 'Row': tableInfo[s].Row, 'ColumnType': tableInfo[s].ColumnType, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                                //Checking the types of input .....RadioButton                                  
                                else if (type == 'radio') {
                                    if (control.prop("checked")) {
                                        cols.push({ 'ColumnName': tableInfo[s].ColumnName, 'Value': 1, 'Row': tableInfo[s].Row, 'ColumnType': tableInfo[s].ColumnType, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                                //Checking the types of input .....Text /Text Area
                                else if (type == 'text' || type == 'textarea') {
                                    var val = control.val()
                                    if (val.trim().length != 0) {
                                        cols.push({ 'ColumnName': tableInfo[s].ColumnName, 'Value': val, 'ColumnType': tableInfo[s].ColumnType, 'Row': tableInfo[s].Row, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                                //Checking the types of input .....Date 
                                else if (type == 'date') {
                                    var val = control.data('iso-date');
                                    if (val && control.val()) {
                                        cols.push({ 'ColumnName': tableInfo[s].ColumnName, 'Value': val, 'ColumnType': tableInfo[s].ColumnType, 'Row': tableInfo[s].Row, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                                else if (type == 'hidden') {
                                    var val = control.val();
                                    if (!control.hasClass('file0')) {
                                        cols.push({ 'ColumnName': tableInfo[s].ColumnName, 'Value': val, 'ColumnType': tableInfo[s].ColumnType, 'Row': tableInfo[s].Row, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                                //gets select control value
                                else if (control.is('select')) {
                                    //index 0 is empty or has default prompt value
                                    if (control.prop('selectedIndex') > 0) {
                                        var columnNameData = control.find(':selected input').attr('name');
                                        var columnName;
                                        var val = control.val();
                                        //use the columnname in input:name if defined, needed for options that save to different columns //abovtenko
                                        if (columnNameData === undefined) {
                                            columnName = tableInfo[s].ColumnName
                                        }
                                        else {
                                            columnName = columnNameData;
                                            val = 1;
                                        }
                                        cols.push({ 'ColumnName': columnName, 'Value': val, 'ColumnType': tableInfo[s].ColumnType, 'Row': tableInfo[s].Row, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                                else if (control.hasClass('isTime')) { //timepicker
                                    if (control.val() !== '') {
                                        var time = control.data('timepicker')
                                        var hour = (time.meridian === "PM") ? time.hour + 12 : time.hour;
                                        if (hour < 10) hour = '0' + hour
                                        var minute = (time.minute < 10) ? '0' + time.minute : time.minute;   
                                        var timeString = hour + ':' + minute + ':00'
                                        cols.push({ 'ColumnName': tableInfo[s].ColumnName, 'Value': timeString, 'ColumnType': tableInfo[s].ColumnType, 'Row': tableInfo[s].Row, 'Group': tableInfo[s].GroupName, 'OtherDataType': tableInfo[s].OtherDataType });
                                    }
                                }
                            }
                        }
                    }
                    if (cols.length > 0) {
                        child.push({
                            "TableName": tableOrder[i].TableName,
                            "Order": tableOrder[i].TableOrder,
                            "PKTable": tableOrder[i].PKTable,
                            'ColumnType': tableOrder[i].ColumnType,
                            "PKName": tableOrder[i].PKName,
                            "FKName": tableOrder[i].FKName,
                            "Columns": cols
                        });
                    }
                }
                return child;
            }
            /**
             * Posts claim data to controller and handles response.
             * @param tableData
             * @param status
             */
            function SaveClaim(tableData, status) {
                $.ajax({
                    type: "POST",
                    url: "<%= get_api %>/api/Dynamic/SaveJSON/" + Token,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    data: { contrlData: tableData, status: status },
                    dataType: "JSON",
                    success: function (data) {                        
                        var result = JSON.parse(data);
                        if (result.Submitted) {
                            if (fileArray.length > 0) {
                                SaveClaimDocuments(fileArray, result.ClaimID);
                            }
                            if (status === 0) {
                                ShowClaimDraftSavedSuccessSwal()
                            }
                            else {
                                SendClaimNotificationEmail(result.ClaimID)
                                ShowClaimSubmissionSuccessSwal();
                            }                        
                        }
                        else {
                            swal('', 'Unknown error. Please try again at a later time.', 'error');
                        }
                    },
                    error: function (msg) {
                        swal('', 'Unknown error. Please try again at a later time.', 'error');
                    }
                });
            }
            //The provinces would be populated based on the Country selection
            $(document).on('change', '.populateProvinces', function (event) {
                var provinceClass = SelectCssClassLike($(this).attr('class'), 'psf-');
                var provinceFieldName = provinceClass[0].replace('psf-', '');
                GetDataGeneric('Databind', 'PopulateProvinces', event.target.value).then(function (data) {
                    PopulateList(data, provinceFieldName, 'Sub_Name', 'Sub_Name');
                });
            });
            //cities would be populated based on the province selection
            $(document).on('change', '.province', function (event) {
                var cityClass = SelectCssClassLike($(this).attr('class'), 'psf-');
                var cityFieldName = cityClass[0].replace('psf-', '');
                //PopulateCities($(this).val(), cityFieldName);
                GetDataGeneric('Databind', 'PopulateCities', event.target.value).then(function (data) {
                    PopulateList(data, cityFieldName, 'City_Name', 'City_Name');
                });
            });
            //handlers for addition / removal of witnesses 
            $(document).on('click', '.AddWitness', function () {
                var control = GetControlById(this.id);
                var witnessControls = GetControlsByGroupName(control.GroupName);
                var newWitnessControls = AddWitness(witnessControls, $(this)); 
                MaskInputs();
                for (var i = 0; i < newWitnessControls.length; i++) {
                    tableInfo.push(newWitnessControls[i]);
                }
            });
            $(document).on('click', '.remove-witness', function() {
                RemoveWitness($(this));
            });
            //handlers for addition / removal of schedule weeks
            $(document).on('click', '.AddWeek', function () {
                //var control = GetControlById(this.id);
                var scheduleControls = GetControlsByGroupName('ScheduleTable');                
                var newScheduleControls = AddScheduleRow(scheduleControls, $(this));
                for (var i = 0; i < newScheduleControls.length; i++) {
                    tableInfo.push(newScheduleControls[i]);
                }
            });
            $(document).on('click', '.remove-week', function () {
                RemoveScheduleRow($(this));
            });
            $("[disabled]").click(function (e) {
                e.preventDefault();
                return false;
            });
            /**
             * Adds a new set of file controls to tableInfo and makes pushes files to fileArray
             * @param files
             * @param fileInput
             */
            function FileUpload_AddControls(files, fileInput) {
                var control = GetControlById(fileInput.attr('id'));
                var fileControls = GetControlsByGroupName(control.GroupName).filter(function (c) {
                    return c.ControlType == 'hidden' && c.Row == 1;
                });
                var newFileControls = UploadFiles_PortalForm(files, fileControls, fileInput);
                for (var i = 0; i < newFileControls.length; i++) {
                    tableInfo.push(newFileControls[i]);
                }
            }
            /**
             * Appends a container to each subsection and places the children into rows which are created dynamically based on
             * the length of children and what amount should be in each row.
             * @param $col
             * @param $subSections
             * @param $wrap
             */
            function CreateBsColumns($col, $subSections, $wrap) {  
                $subSections.forEach(function (subsection) {
                    var count = 1;
                    var id = '#' + subsection;
                    var target = $(id);
                    var children = target.children().not('[type="hidden"], label');
                    target.append('<div class="container"><div class="form_setter"></div></div>');
                    target = $(id + ' > .container');//set target to container of rows
                    $.each(children, function () {
                        if ($(this).is('p, .wide')) {
                            target.append($('<div class="form_setter"><div class="col"></div></div>').find('.col').append($(this)))
                            //target.append('<div class="row"></div>');   //row for subsequent elements
                        }
                        else {
                            //adding another element will exceed the desired number
                            if (count > $wrap) {
                                target.append('<div class="form_setter"></div>');
                                count = 1;
                            }
                            $(this).addClass($col);//add passed bootstrap column class; such as 'col-md-3'
                            target.children('.row:last').append($(this));
                            count++;
                        }
                    });
                });                
            }        
            /**
             * Pushes values into an array if a specific css class is present within the control's css classes;
             * Used to create an array of subsection id values that require a specific grid styling.
             * @param css
             * @param targetCss
             * @param array
             * @param arrayItem
             */
            function SetGroupingArray(css, targetCss, array, arrayItem) {
                var test = $('<span></span>').addClass(css);
                if (test.hasClass(targetCss))
                    array.push(arrayItem);
            }
            //the return value for populating claim:description
            function GetClaimType(formId) {
                if (formId) {
                    var types = ['', 'WC', 'STD', 'LOA']
                    return types[formId]
                }
            }
            /**
             * Gets a control object by control Id.
             * @param id
             */
            function GetControlById(id) {
                var control = tableInfo.filter(function (control) {
                    return control.ID == id;
                });
                return control[0] || {};
            }
            /**
             * Gets an array of control objects by groupname.
             * @param groupName
             */
            function GetControlsByGroupName(groupName) {
                var controls = tableInfo.filter(function (control) {
                    return control.GroupName == groupName && control.Row == 1;
                });
                return controls;
            }
            /**
             * Attaches event handler(s) to field(s) that have a dependent field. 
             * @param dependedOnIDs
             * @param dependentID
             */
            function AttachDependedOnHandler(dependedOnIDs, dependentID) {
                //one field may be dependent on many; stored as space-separated string of ids //abovtenko
                var dependedOnSelector = dependedOnIDs
                    .split(" ")
                    .map(function (id) {
                        return '#' + id
                    })
                    .join(',');
                var dependedOn = $(dependedOnSelector);
                var dependent = $('#' + dependentID);
                //disabled by default
                dependent.prop('disabled', true);
                dependent.addClass("disabled");
                //for identification; trigger event on these when claim is being updated to potentially activate dependent fields
                dependedOn.addClass('dep-on');
                var SectionEnabler = function() {
                    //the tab that points to the dependent section
                    var tab = $('li > a[href="#' + dependentID + '"]');
                    //this is strictly for LOA form at the moment.
                    //needs solution for passing 'enable condition' and reference to arguments dynamically     -abovtenko 
                    if (dependedOn.find(':selected').data('description') != 'This leave is not administered by OSI.' 
                        && dependedOn.prop('selectedIndex') != 0) {
                        $('.action-buttons button').removeProp('disabled');
                        tab.parent().removeClass('disabled');
                        tab.removeProp('disabled');
                    }
                    else {
                        $('.action-buttons button').prop('disabled', true);
                        tab.parent().addClass('disabled');
                        tab.prop('disabled', true);
                    }
                }
                var ControlEnabler = function () {
                    var enable;
                    if (dependedOn.is('select')) {

                        //the array values > 1 correspond to a selection of 'Other' and are id values in orgsys

                        for (var i = 0; i < dependedOn.length; i++) {

                            enable = ['1', 'Yes', '-1', '130', '112', '40', '256', 'Other'].indexOf($('#' + dependedOn[i].id).find(':selected').val()) >= 0 ? true : false;

                            if (enable) break;

                        }

                    }
                    else {
                        enable = dependedOn.prop('checked')   //for checkboxes
                    }
                    if (enable) {
                        dependent.prop("disabled", false).addClass('required');
                    }
                    else {
                        dependent.prop('disabled', true).removeClass('required');
                        //wipe value since one may have been entered //abovtenko
                        if (dependent.is('select')) {
                            dependent.prop('selectedIndex', 0);
                        }
                        else {
                            dependent.val('');
                        }
                    }
                }
                var CorrectHandler = (/^Section/.test(dependentID)) ? SectionEnabler : ControlEnabler
                dependedOn.on('change', CorrectHandler)
            }
            /**
             * Attaches event handler to dropdown which will trigger other fields to be populated with the currently logged in user's details, depending on selection. 
             * @param source
             */
            function AttachUserPopulationHandler(source) {
                source.on('change', function () {
                    var name = $(this).attr('name');
                    var popTargets = $('[class*=popTrgFor-' + name);
                    if ($(this).val() == 1) {
                        if (popTargets.length > 0) {
                            $.ajax({
                                type: 'GET',
                                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                                url: getApi + "/api/Databind/AutoPopulateSubInfo/" + window.Token,
                                success: function (data) {
                                  var result = JSON.parse(data)[0];
                                //these classes are business rules
                                popTargets.filter('[class*="popTrgFor-' + name + '-Name"]').val(result['EmpFirstName'] + ' ' + result['EmpLastName']);
                                popTargets.filter('[class*="popTrgFor-' + name + '-FirstName"]').val(result['EmpFirstName']);
                                popTargets.filter('[class*="popTrgFor-' + name + '-LastName"]').val(result['EmpLastName']);
                                popTargets.filter('[class*="popTrgFor-' + name + '-Phone"]').val(result['WorkPhone']).data('mask').init();
                                popTargets.filter('[class*="popTrgFor-' + name + '-Ext"]').val(result['Ext']);
                                popTargets.filter('[class*="popTrgFor-' + name + '-Email"]').val(result['Email']);
                                }
                            });
                        }
                    }
                    else {
                        popTargets.val('');
                    }
                });
            }
            /**
             * Attach event handler to update the value of a target control, when the value of a source control changes.
             * @param controlId
             * @param slaveControlId
             */
            function AttachSlaveControlHandler(controlId, slaveControlId) {
                $('#' + controlId).data('slaveControlID', slaveControlId);
                $(document).on('change', '#' + controlId, function() {
                    var slave = $('#' + $(this).data('slaveControlID'));
                    var isDate = $(this).hasClass('date');
                    if(isDate) {
                        slave.val($(this).data('iso-date'));
                    }
                    else {
                        slave.val($(this).val());
                    }  
                });
            }
            /**
             * Attaches all event handlers.
             * @param control
             */
            function AttachControlEventHandlers(control) {
                if (control.DependentOn !=  "0") {
                    var dependentID = (control.ControlType == 'section') ? 'Section' + control.SectionID : control.ControlID;
                    AttachDependedOnHandler(control.DependentOn, dependentID);
                }
                //attach handler to set slave controls' values to master's value /abovtenko
                if (control.SlaveControlID !== 0) {
                    AttachSlaveControlHandler(control.ControlID, control.SlaveControlID);
                }
                //attach prescribed event handler
                if (control.EventHandler != '') {
                    control.EventHandler
                        .split(' ')
                        .forEach(function (functionName) {
                            $(document).on('change', '#' + control.ControlID, window[functionName])
                        });                    
                }
            }
            //this function is called by an event handler, attached dynamically by AttachControlEventHandlers()
            window.AttachContactTypeHandler = function () {
                //corresponding contact type field has same name, appended CT
                var CTField = $('[name="' + $(this).attr('name') + 'CT"]');
                if($(this).val().length != 0) {                   
                    CTField.removeClass('no-save');
                } 
                else {
                    CTField.addClass('no-save');
                }
            }
            window.AppendLOADescription = function () {
                var descContainer = $('#LOADescription')
                var desc = $(this).find(':selected').data('description') || ''
                //append description container if not present
                if (descContainer.length === 0) {
                    $('<div id="LOADescription">' + desc + '</div>').insertAfter($(this).closest('.row'))
                }
                descContainer.text(desc)
            }
            window.ShowLOASection = function () {
                var sectionId = $(this).find(':selected').data('sectionId')
                if (sectionId) {
                    var subSection = $('#' + sectionId);
                    subSection.siblings().hide();                //hide all subsections
                    subSection.siblings().find('input, select').val('').trigger('change')            //wipe any entered data when changing loa type
                    subSection.removeClass('hidden').show();
                }
            }
            /**
             * Sets active tab and content to the first which contains a field with an error class
             */
            function JumpToErrorSection() {
                var errorSection = $('.section').removeClass('active').find('.error').first().closest('.section');
                var errorTab = $('#' + errorSection.attr('id') + 'Tab');
                $('.divSections > ul > li').removeClass('active');
                errorTab.addClass('active');
                errorSection.addClass('in active');
            }
        });
        //Sends a claim notification email to the distroEmailTo when a claim is submitted
        function SendClaimNotificationEmail(claimID) {
            var firstDayOff = '';
            firstDayOff = window.claimType == "STD" ? $("[name='DayOff']").val() : firstDayOff
            firstDayOff = window.claimType == "WC" ? $("[name='IncidentDate']").val() : firstDayOff
            firstDayOff = window.claimType == "LOA" ? $("[name='AbsenceStartDate']").val() : firstDayOff
            var email = {
                ClaimID: claimID,
                To: 'astgermain@orgsoln.com',
                EmployeeFirst: $("[name='EmpFirstName']").val(),
                EmployeeLast: $("[name='EmpLastName']").val(),
                EmployeeNumber: $("[name='EmpNu']").val(),
                FirstDayAbsence: firstDayOff,
                ClaimSubissionDate: $("[name='DateCreation']").val()
            }
            SendEmail(EMAIL_TYPE_HTML.CLAIM_DEFAULT_EXTERNAL_NOTIFICATION, email);
        }
    </script>
    <script>
    </script>
</asp:Content>
<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">
    <script src="/Assets/js/common/SplashScreen.js"></script>
        <div class="osp-heading panel-heading banner-container">
            <div class="row">
                <div id="form-title" class="osp-heading panel-heading welcome-container">
                    <h4 class="welcome-header"></h4>
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
    <div class="osp-container container-fluid flex-col">
        <div class="form_navigation">
            <%--<div id="form-actions" class="action-buttons pull-right btn-group form_submit_button">
                    <%--<button type="button" id="btnDraft" class="btn btn-default" >Draft</button>
                <button type="button" id="btnSubmit" class="btn btn-success" >Submit</button>
            </div>--%>
            <div class="action-buttons pull-right btn-group">
                <button type="button" class="btn btn-default btn-previous" id="btnPreviousTop">Previous
                    <%--<span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>Previous--%>
                </button>
                <button type="button" class="btn btn-default btn-next" id="btnNextTop" >Next
                     <%--Next<span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>--%>
                </button>
            </div>
        </div>
        <div class="spacer"></div>
        <div class="osp-body panel-body">
            <div class="tabs divSections">
                <ul id="form-tabs" class="nav nav-tabs absence_form"></ul>
            </div>
            <div id="form-content" class="tab-content absence_form">
                
            <div id="form-actions" class="action-buttons pull-right btn-group form_submit_button">
                    <%--<button type="button" id="btnDraft" class="btn btn-default" >Draft</button>--%>
                <button type="button" id="btnSubmit" class="btn btn-success" >Submit</button>
            </div>
            </div>
        </div>
        <div class="spacer"></div>
        <div class="osp-heading panel-heading">
            <div class="row">
                <div class="action-buttons pull-right btn-group">
                    <button type="button" class="btn btn-default btn-previous" id="btnPreviousBottom">
                        <%--<span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>--%>Previous
                    </button>
                    <button type="button" class="btn btn-default btn-next" id="btnNextBottom">
                        Next<%--<span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>--%>
                    </button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>