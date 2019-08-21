<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="WC.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.WC" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        
    </style>
    <script>
        window.valid = true;
        window.getApi = "<%= get_api %>";
        window.ClaimRefNu = "";
        window.ClaimID = $.url().param('ClaimID');
        window.ClientID = $.url().param('ClientID');        
        window.ClaimStatus = 9; //status updated from claim data on load
        window.formName = $.url().param('FormName');
        window.UserID = "";
        var token = '<%= token %>';

        //if a claim ref number is passed in the url we will get the latest claim id
        if ($.url().param('ClaimRefNo')) {
            window.ClaimRefNu = $.url().param('ClaimRefNo');

            $.ajax({
                url: "<%= get_api%>/api/Claim/GetLatestClaimIDFromRefNo/" + window.ClaimRefNu,
                beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                async: false,
                success: function (data) {
                    window.ClaimID = JSON.parse(data).ClaimID;
                    //resolve claim ref no to claim id for application use
                    window.history.replaceState(null, null, "?ClaimID="+window.ClaimID+ "&ClientID="+$.url().param('ClientID'));
                },
                error:function (xhr, ajaxOptions, thrownError){
                    if(xhr.status==404) {
                        alert('Invalid claim reference number: '+ $.url().param('ClaimRefNo') + " Please search for the claim with this Reference number.");
                        window.location.replace("/OrgSys_Forms/ClaimsManager.aspx");
                    }
                    if(xhr.status==400) {
                        alert('Claim reference number was not provided. Query recieved:'+ $.url().param('ClaimRefNo'));
                        window.location.replace("/OrgSys_Forms/ClaimsManager.aspx");
                    }
                }
            });
        }






        

        //gets lists that are associated with incidet section and appends options to select
        function GetListForIncident(listName) {
            var list = [];
            $.ajax({
                url: "<%= get_api%>/api/Incident/" + listName,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                async: false,
                success: function (data) {
                    list = JSON.parse(data);
                }
            });
            var options = "";
            var description;
            if (listName == "GetList_Diagnosis") {
                description = "Diagnosis_EN"
            } else if (listName == "GetList_InjuryCategories") {
                description = "InjuryCat_EN"
            }
            list.forEach(function (item) {
                options += `<option label="${item[description]}" value="${item[description]}"></option>`;
            });

            return options;
        }

        //gets incident sections based on claim number
        function GetIncidentSection($SubSection) {
            var val = [];
            if ($.url().param('ClaimID')) {
                $.ajax({
                    url: "<%= get_api %>/api/Incident/" + $SubSection + "/" + $.url().param('ClaimID'),
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    success: function (data) {
                        val = JSON.parse(data);
                    }
                });
            }
            return val;
        }
    </script>
    <script src="../../Assets/js/IncidentDetails.js"></script>
    <script src="../Generic_Forms/JSFilesExternal/FileInput.js"></script>
    <script>
        /*  Created By: Sam Khan
            Update Date: 2018-03-15 - Marie Gougeon
            Update Date: 2018-03-23 - Marie Gougeon
            Description: It loads and saves the claim data,applies business rules and validations.
            */
  



        //load claim header
        if ($.url().param('ClaimID')) {
            $.ajax({
                url: "<%= get_api %>/api/Claim/GetClaimHeaderInfo/" + window.ClaimID,
                beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                type: "Get",
                async: false,
            }).then(
                function (data) {
                    var HeaderInfo = JSON.parse(data)[0];
                    $.get("/Orgsys_Forms/Internal_Forms/Templates/InternalClaimHeaderTemplate.html",
                        function (html) {
                            //variables evaluated into html below
                            var EmployeeName = HeaderInfo.EmpFullName;
                            var EmployerName = HeaderInfo.ClientName;
                            var LastAbsence = HeaderInfo.AbsDate;
                            var ReferralDate = HeaderInfo.ReferralDate;
                            var LTDTartgetDate = HeaderInfo.LTDTargetDate;
                            var TDO = HeaderInfo.TDO;
                            html = eval("`" + html + "`");
                            $('#ClaimInfoHeader').html(html);
                        });
                }, function() {
                    alert( "$.get failed!" );
                }
            );
        }
     

        $(function () {
            $("#AddUpdates").hide();
            $("#updatesMsg").show();
            $('#Updates').hide();
            $('[data-toggle="tooltip"]').tooltip();
            $('#City').select2();
            $('#City_Work').select2({ width: '100%' });
            $('#billingDiv').hide();


            $.ajax({
                type: 'GET',
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                url:"<%= get_api %>/api/DataManagement/GetUserIDSession/" + token,
                success: function (data) {
                    var results = JSON.parse(data);
                window.UserID = results[0]["UserID"]; //Not Supposed to save it locally.......Should never be on Client Side.....
                }
            });


            GetBusinessRules();
            GetServicesRules();
            LoadServices();     
            MaskInputs();
            InitializeDatepicker();

            if (formName == "STD") {
                $('.panel-title').text("STD Internal Form");
                $(".WC_Form").each(function () {
                    $(this).css("display", "none");
                });
            }
            else if (formName == "WC") {
                $('#panel-heading').remove();
                $(".Std_Form").each(function () {
                    $(this).css("display", "none");
                });
            }
            
            //Sam Khan -------Date : 09/29/2017
            //Loading is done here
            //I need to imporove on this code to make it more organized
            //Will Move to JS files

            //Sam Khan -- 05/27/2018
            if (ClaimID) {
                $("#updatesMsg").hide();
                $("#AddUpdates").show();
                //Sam Khan -- 07/27/2018
                //Show Absences section
                $("#absMsg").hide();
                $("#btnAddAbsences").show();
                $("#divAbsences").show();
                $("#ShowContactInfo").show();

                $.getJSON("<%= get_api %>/api/Validate/CheckIfTokenValid/" + token, function (data) {
                    var validate = JSON.parse(data);
                    if (validate == 10001) {
                        GetClaimFewFields();
                        PopulateLists().then(function () {
                            //below calls contain data that is selected from a list /abovtenko
                            LoadSchedule();
                            GetClaimData();
                        });
                        LoadClaimContacts();
                        LoadEmployeeInformation();
                        LoadClaimDatesDT();
                        LoadClaimDocuments();
                        PopulateJobDescriptionDocs();

                        GetClaimContacts();
                        GetClaimDates();
                    }
                    else {
                        window.location.href = "/Orgsys_Forms/Orgsys_Login.aspx";
                    }
                });
            }
            else {
                InitializeDT('#tblSchedule', ScheduleDTC);
                InitializeClaimContactsDT();
                InitializeEmployeeInformationDT();
                InitializeClaimDatesDT();
                InitializeClaimDocumentsDT();

                PopulateLists();
                $(".claim-user-add").attr('title', 'Claim must be saved before adding users.');
                $("#btnAddAbsences").hide();
                $("#absMsg").show();
                $("#divAbsences").hide();  
            }

            // The business rules are to be retrieved from the database 
            // It will make these arguments dynamic for external and internal form.
            //It adds the classes to the controls
            function GetBusinessRules() {
                $.ajax({
                    url: "<%= get_api %>/api/Form/GetBusRules/" + token + "/1",
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    type: "Get",
                    async: false,
                    success: function (data) {
                        results = JSON.parse(data);
                        for (i = 0; i < results.length; i++) {
                            $('[name="' + results[i]["ControlName"] + '"]').addClass(results[i]["Class"]);
                            if (results[i]["ReadOnly"] == true) {
                                $('#' + results[i]["ControlName"]).attr('readonly', 'readonly');
                            }
                        }
                    },
                    error: function (msg) {
                    }
                });
            }

            $('.loadBillable').click(function (e) {
                $('#bill').style.display = "block";
            })

            $('.loadUpdates').click(function (e) {
                $('#updates').modal({ show: true })
            });
            //Disable all input field for closed claims
            $(window).ready(function () {
                var claimIsClosed = false;
                if (window.ClaimID) {
                    claimIsClosed = CheckClaimStatus(ClaimID);
                }
                if (claimIsClosed == true) { //Claim has been closed already, no editing!
                    $(".WC_page_container input").prop("disabled", true);
                    $(".WC_page_container select").prop("disabled", true);
                    $(':button').prop('disabled', true);
                    $('.btn').addClass('disable');
                    $('.edit_button').addClass('disable');
                    $('.btn-danger').addClass('disable');
                    $('.sorting_1').addClass('disable');
                    $('.table-bordered').addClass('disable');
                    $('.table-bordered .sorting_1').addClass('disable');
                }
            });
            //UPDATED: 05/01/2018 - Marie
            $('#submit').click(function (e) {
                var claimIsClosed = false;
                if (window.ClaimID) {
                    claimIsClosed = CheckClaimStatus(ClaimID);
                }

                if (claimIsClosed == false) {
                    DeleteFormStructure();          //Deletes the templates used for creating forms
                    UnMaskInputs();                 //temporarily remove masks to allow for creation of claim objects without changing claimjs //abovtenko
                    var claim = CreateClaimObjects(status);     //The claim objects are created in the external file
                    MaskInputs();
                    
                    if (validate.validateSubmission()) {
                        SaveClaimData(claim);            //Form is valid the claim is saved in to database
                    }
                    else {
                        var sectionsWithErrorFields = getSectionNamesWithErrorFields(); //Gets a unique list of comma delimited section names with error fields
                        swal('Error!', 'Oops! You missed required field(s) from the following section(s): <br/><br/>' + sectionsWithErrorFields + '', 'error');
                    }

                } else { //Claim has been closed already, no editing!
                    swal("Cannot Save Claim ", "The claim you are attempting to edit is already closed. Please consult the Claims Manager Tool on the dashboard.", "error");
                }
            });

            //Created: 03/23/2018 - Marie
            //Check the status of the claim before proceeding to submit
            function CheckClaimStatus(ClaimID) {
                var node;
                var isclosed;
                $.ajax({
                    url: "<%= get_api %>/api/Claim/GetIsClaimClosed/" + ClaimID,
                    beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    type: "GET",
                    async: false,
                    success: function (data) {
                        node = JSON.parse(data);
                        isclosed = node[0]["IsClaimClosed"];
                    }
                });
                return isclosed;
            }

            //UPDATED: 03/23/2018 - Marie
            //Added the newly saved claimID to transfer over to the reciept to grab data
            function SaveClaimData(data) {
                $.ajax({
                    url: "<%= get_api %>/api/SaveClaim",
                     beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    type: "POST",
                    async: false,
                    data: "=" + encodeURIComponent(JSON.stringify({ claimData: data })),
                    success: function (claimId) {
                        window.ClaimID = claimId
                        var newurl = window.location.protocol + "//" + window.location.host + window.location.pathname + '?ClaimID=' + claimId + '?ClientID=' + window.ClientID;
                        window.history.pushState({ path: newurl }, '', newurl);
                        swal({
                            title: 'Success!',
                            text: 'You have successfully submitted a claim!',
                            type: "success",
                            showCancelButton: false,
                            confirmButtonClass: "btn-success",
                            confirmButtonText: "Okay"
                        });
                    },
                    error: function (msg) {
                        swal('','An error occurred and your claim was not submitted.Please report this issue.', 'error');
                    }
                });
            }

            function DeleteFormStructure() {
                $("#claimStrucure").remove();
            }            

            //It gets Country and Form Type from Data Base
            function GetClaimFewFields() {
                $.ajax({
                    url: `<%= get_api%>/api/Claim/GetClaimFewFields/${ClaimID}`,
                    beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    type: "GET",
                    async: false,
                    success: function (data) {
                        var results = JSON.parse(data);
                        window.ClaimRefNu = results[0]["ClaimRefNu"];

                        PopulateProvinces(results[0]["Country"], "province");
                        PopulateProvinces(results[0]["Country_Work"], "province_Work");
                        //Populate Cities based on Province selection
                        PopulateCities(results[0]["Province"], "city");
                        PopulateCities(results[0]["Province_Work"], "city_Work");
                        PopulateUpdates(results[0]["ClaimRefNu"]);
                        if (results[0]["Description"] == "STD") {
                            $('.panel-title').text("STD Internal Form");
                            $(".WC_Form").each(function () {
                                $(this).css("display", "none");
                            });
                        }
                        if (results[0]["Description"] == "WC") {
                            //$('.panel-title').text("WC Internal Form");
                            $(".Std_Form").each(function () {
                                $(this).css("display", "none");
                            });
                        }
                        window.formName = results[0]["Description"];
                    },
                    error: function (err) {
                    }
                });
            }
            // It gets the data of the claim from Claim Table 
            function GetClaimData() {
                $.ajax({
                    url:"<%= get_api %>/api/Claim/GetClaimDataInternal/" + token + "/" + ClaimID,
                      beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                          var results = ReplaceDFValues(JSON.parse(data));
                    window.ClientID = results[0].ClientID;
                    window.ClaimStatus = results[0].Status;
                    
                    $.each(results[0], function (key, value) {
                        if (key == "City") {
                            $("#City").val(value);
                            $('#City').trigger('change');
                        }
                        if (key == "City_Work") {
                            $("#City_Work").val(value);
                            $('#City_Work').trigger('change');
                        }                        
                        if (key == "SIN") {
                            if (value.length > 0) {
                                $('#' + key).val(value);
                                $('#' + key).hide();
                                $('#' + key).parent().hide();
                            }
                        }
                        else if (isIsoDateFormat(value)) {
                            SetIsoDateFormat($('#' + key), value);
                        }
                        else if (key === 'BusUnit') {
                            SetDivision(value, $('#' + key));
                        }
                        else
                            $('#' + key).val(value);
                    });

                    

                    if (results[0].IsPortalSubmission) {
                        $('#DateCreation').prop('disabled', true);
                    }

                    //reflect change in first absence record
                    $(document).on('change', '#DateFirstOff', function () {
                        var table = $('#tblAbsences').DataTable();
                        if (table.rows()[0].length > 0) {
                            var firstAbsence = table.row(0).data();
                            firstAbsence.DayOff = $(this).data('iso-date');
                            table.row(0).data(firstAbsence).draw();
                        }
                    });
                    $(document).on('change', '#DateLastWorked', function () {
                        window.absLastWorked = $(this).data('iso-date'); //used to populate first absence
                    });
                    $(document).on('change', '#LTDDate', function () {
                        window.absLTDStartDate = $(this).data('iso-date'); //used to populate first absence
                    });
                    }
                });
            }

            /*Sam Khan ------06/26/2018*/
            /*I think we do not need it any more,as we moved the dates to Claim Updates */
            //It Gets Claim Dates
            function GetClaimDates() {
                $.ajax({
                    url:"<%= get_api %>/api/Claim/GetClaimDates/" + ClaimID,
                      beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                         var results = JSON.parse(data);
                    for (i = 0; i < results.length; i++) {
                        SetIsoDateFormat('#' + results[i].DateDescription, results[i].OccurenceDate)
                    };
                    }
                });
            }
            //Gets Date Details
            function GetDatesDetails() {
                $.ajax({
                    url: "<%= get_api %>/api/Claim/GetDateDetails/" + ClaimID,
                    beforeSend: function (request) {
                        request.setRequestHeader("Authentication", window.token);
                    },
                    async: false,
                    success: function (data) {
                        var results = JSON.parse(data);
                        for (i = 0; i < results.length; i++) {
                            $('#dateAbsList').append($('<tr>').append($('<td>' + results[i]["Status"] + '</td>' + '<td>'
                                + '<td>' + results[i]["DateTo"] + '</td>'
                                + '<td>' + results[i]["DateFrom"] + '</td>'
                                + '<td>' + results[i]["Hours"] + '</td>'
                            )));
                        }
                    }
                });
            };
            // Get Claim Contacts 
            function GetClaimContacts() {
                $.ajax({
                    url: "<%= get_api %>/api/Claim/GetClaimContacts/" + ClaimID,
                      beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                                  var results = JSON.parse(data);
                    var val;
                    for (i = 0; i < results.length; i++) {
                        if (results[i]["Type"] == "SubBy") {
                            val = "SubBy";
                        }
                        if (results[i]["Type"] == "Manager") {
                            val = "Mgr";
                            $('#StationID').val(results[i]["StationID"]);
                            $('#StationAddress').val(results[i]["StationAddress"]);
                        }
                        if (results[i]["Type"] == "InvBy") {
                            val = "InvBy";
                        }
                        if (results[i]["Type"] == "Coordinator") {
                            val = "Coordinator";
                        }
                        if (results[i]["Type"] == "RepTo") {
                            val = "RepTo";
                        }
                        $('#' + val + "Name").val(results[i]["Name"]);
                        $('#' + val + "Position").val(results[i]["Position"]);
                        $('#' + val + "Phone").val(results[i]["Phone"]);
                        $('#' + val + "Email").val(results[i]["Email"]);
                    };
                    }
                });
            }

            $('.divSections').hide();
            $('#MainContent_employeeInformation').show();
            $('a.sub-menu').click(function () {
                $("a.sub-menu").children("li").removeClass("leftliSelect");
                $(this).children("li").toggleClass("leftliSelect");
                $('.divSections').hide();
                //window.scrollTo(0, -30); //Replaced by Kamil for code below
                $("html, body").animate({ scrollTop: 0 }, "slow");
                $($(this).attr('href')).show();//Show sections accordingly
            });

            $('#claimContacts').on("click", function () {
                $('#submit').show();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });
            $('#employeeInformationTab').on("click", function () {
                $('#submit').show();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });
            $('#claimupdatesTab').on("click", function () {
                $('#submit').hide();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });
            $('#closeClaims').on("click", function () {
                $('#submit').hide();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
                    alert("text");
                    $("#WC_page_container input").prop("disabled", true);
            });
            $('#claimTasks').on("click", function () {
                $('#submit').hide();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });
            $('#insuDetailsTab').on("click", function () {
                $('#submit').show();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });
            $('#insuDetailsTab').on("click", function () {
                $('#submit').show();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });
            $('#cinsiDetailsTab').on("click", function () {
                $('#submit').show();
                $('.nav_item_forms').addClass("nav-item nav-item-active");
                $('.nav_item_forms a').addClass("nav-link");
            });

            $('#addDate').click(function (e) {
                AddListWithCounter('dateList', 3, 'dates', 'dateCounter', 'date')
            });
            $('#addAbsDates').click(function (e) {
                AddListWithCounter('dateAbsList', 5, 'sch', 'absCounter', 'schedule')
            });
            $('#addComment').click(function (e) {
                var count;
                var counter = "commentCounter";
                if ($('#comm7').is(":checked")) count = 18;
                else count = 7;
                AddListWithCounter('commentList', count, 'comm', counter, 'comment')
            });

            function AddListWithCounter($listName, $length, $fieldName, $listCounter, $name) {
                var value;
                var html = '';
                html += '<tr>';
                for (i = 1; i < $length; i++) {
                    var type = $('#' + $fieldName + i).attr('type');
                    if (type == 'checkbox') {
                        if ($('#' + $fieldName + i).prop('checked')) {
                            value = true
                        }
                        else {
                            value = false;
                        }
                    }
                    else
                        value = $('#' + $fieldName + i).val();
                    html += '<td><input type="text"  name="' + $name + i + '" value= "' + value + '" class ="' + $name + i + '" style="width: 60px;" readonly="readonly" /></td>';
                }
                $('#' + $listName).append(html);
                $('#' + $listName).append($('</tr>'));
                var newValue = parseInt($('#' + $listCounter).val()) + 1;
                $('#' + $listCounter).val(newValue);
            };
            function AddList($listName, $fieldName, $listCounter, $name) {
                var value;
                $('#' + $listName).append($('<tr>'));
                value = $('#' + $fieldName).val();
                $('#' + $listName + '>tbody>tr:last').append($('<td><input type="text"  name= "' + $name + '" value= "' + value + '" style="width: 250px;" readonly="readonly" /></td>'));
                $('#' + $listName).append($('</tr>'));
                var $counter = $('#' + $listCounter);
                $counter.val(+$counter.val() + 1);
            };
            $('#Billable').change(function () {
                if ($(this).is(":checked")) {
                    CreateModalDialogs("modalBilling", "Billable");
                }
            });
            function CreateModalDialogs(Title, ID) {
                $('#' + Title).modal({
                    show: true,
                    title: ID,
                });
            }


        });

        //Generates a comma delimited list of section names that contain error fields.
        function getSectionNamesWithErrorFields() {
            var sectionsWithErrorFields = {
                sections: []
            };
            $(".error").each(function () {//Loops through fields with errors and adds their tab section name to an array. This will be added to a SWAL to let the user know what sections are missing required values.
                var sectionID = $(this).parents(".tab-pane").attr('id');

                var curSectionId = $("a[href='#"+sectionID+"']").first().text();

                var result = sectionsWithErrorFields.sections.filter(function (obj) { return obj.sectionName == curSectionId; })[0];
                if (result == null) {
                    sectionsWithErrorFields.sections.push({
                        "sectionName": curSectionId,
                        "errCount": 1
                    });
                } else {
                    result.errCount += 1;
                }
            });

            var listItemString = "";
            for (var i = 0; i < sectionsWithErrorFields.sections.length; i++) {
                listItemString += "<li class='list-group-item' style='text-align: left;'>" + sectionsWithErrorFields.sections[i].sectionName + "<span class='badge badge-error'>" + sectionsWithErrorFields.sections[i].errCount + "</span></li>";
            }

            return "<ul class='list-group'>" + listItemString + "</ul>";
        }
    </script>
    <script>
        //gets lists that are associated with incidet section and appends options to select
        function GetListForIncident(listName) {
            var jsonList = [];
            $.ajax({
                url: "<%= get_api%>/api/Incident/" + listName,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                async: false,
                success: function (data) {
                    jsonList = JSON.parse(data);
                }
            });
            var listID, description = "";

            if (listName == "GetList_Diagnosis") {
                listID = "DiagnosisID";
                description = "Diagnosis_EN";

            } else if (listName == "GetList_InjuryCategories") {
                listID = "InjuryCatID";
                description = "InjuryCat_EN";
            }
            var list = [];
            jsonList.forEach(function (item) {
                list.push({ id: item[listID], text: item[description] });
            });
            return list;
        }

        $(document).ready(function () {
            let easyAutocompleteOptions = {
                data: [],
                getValue: "EmpLastName",
                list: {
                    match: {
                        enabled: true
                    },
                    onClickEvent: function () {
                        bootstrap_alert.danger("A claim with this employee may already exist.");
                        autoFillForm($("#EmpLastName").getSelectedItemData());
                    }
                },
                template: {
                    type: "custom",
                    method: function (value, item) {
                        return `${item.EmpFirstName} ${value}`
                    }
                }
            };
            $.ajax({
                url: "<%= get_api %>/api/" + window.token + "/Users/employeeoptionsInternal/" + window.ClientID,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                type: "POST"
            }).then(function (response) {
                let userProfiles = JSON.parse(response);
                easyAutocompleteOptions.data = userProfiles;
                $("#EmpLastName").easyAutocomplete(easyAutocompleteOptions);
            });
        })

        function autoFillForm(userProfileObject) {
            //The keys of this object are related to the IDs of the form elements
            let userProfileFormObject = {
                AddressLine1: userProfileObject.Address,
                AddressLine2: userProfileObject.AddressLine2,
                City: userProfileObject.City,
                Country: userProfileObject.Country,
                DOB: userProfileObject.DOB,
                Email: userProfileObject.Email,
                EmpFirstName: userProfileObject.EmpFirstName,
                EmpLastName: userProfileObject.EmpLastName,
                EmpNu: userProfileObject.EmployeeNumber,
                Ext: userProfileObject.Ext,
                Fax: userProfileObject.Fax,
                Gender: userProfileObject.Gender,
                HiringDate: userProfileObject.HiringDate,
                HomePhone: userProfileObject.HomePhone,
                JobClassification: userProfileObject.JobClassification,
                JobDescription: userProfileObject.JobDescription,
                JobGrade: userProfileObject.JobGrade,
                JobStatus: userProfileObject.JobStatus,
                JobTitle: userProfileObject.JobTitle,
                Language: userProfileObject.Language,
                AddressUpdated: userProfileObject.LastUpdated,
                OrgCode: userProfileObject.OrgCode,
                Province: userProfileObject.Province,
                SIN: userProfileObject.SIN,
                SalaryGrade: userProfileObject.SalaryGrade,
                WorkPhone: userProfileObject.WorkPhone,
                YearsOfService: userProfileObject.YearsOfService,
                Zip: userProfileObject.Zip
            }
            for (let property in userProfileFormObject) {
                if(property != 'City' && property != 'Province')
                    $("#" + property).val(userProfileFormObject[property]);
            }
            PopulateProvinces(userProfileFormObject['Country'], 'province').then(function () {
                $("#Province").val(userProfileFormObject['Province']);
                PopulateCities(userProfileFormObject['Province'], 'city').then(function () {
                    $("#City").val(userProfileFormObject['City']);
                });
            });

        

        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div id="page-wrapper" class="internal_form">
    <script src="/Assets/js/common/SplashScreen.js"></script>
   
    <form runat="server" method="post" id="formInternal">
         
        <div id="wrapper">
          
            <div class="left">
                
                <ul class="internal_form_menu">
                      
                    <a id="employeeInformationTab" href="#MainContent_employeeInformation" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-stack"></i>
                            <span class="menu">Employee Information</span>
                        </li>
                    </a>
                    <a id="insiDetailsTab" href="#MainContent_incidentDetails" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-list" ></i>
                            <span class="menu">Incident Details</span>
                        </li>
                    </a>
                    <a id="claimupdatesTab" href="#MainContent_claimUpdates" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-equalizer2" ></i>
                            <span class="menu">Claim Updates</span>
                        </li>
                    </a>
                    <a id="claimTasks" href="#MainContent_ClaimTasks" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-clipboard"></i>
                            <span class="menu">Claim Tasks</span>
                        </li>
                    </a>
                    <%-- --It needs to be fixed as Table[Claim_Contacts] definitions are changed now.--%>
                    <a id="claimContacts" href="#MainContent_ClaimContacts" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-address-book" ></i>
                            <span class="menu">Claim Contacts</span>
                        </li>
                    </a>
                    <a id="claimDetails" href="#MainContent_ClaimDetails" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-list" ></i>
                            <span class="menu">Claim Details</span>
                        </li>
                    </a>
                    <a id="claimDates" href="#MainContent_ClaimDates" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-calendar" ></i>
                            <span class="menu">Claim Dates</span>
                        </li>
                    </a>
                    <a id="claimDocuments" href="#MainContent_ClaimDocuments" class="sub-menu">
                        <li class="item-menu">
                            <i class="icon_setter icon-folder-open" ></i>
                            <span class="menu">Claim Documents</span>
                        </li>
                    </a>
                </ul>
            </div>
            <!-- end left -->
            <div class="right">
                <div id="page-wrapper">
                 
                    <div class="panel panel-default WC_page_container">
                        <div class="panel-body WC_container">
                               <div id="alert_placeholder" style="position: absolute; top: 5px; left: 50%; z-index: 999;"></div>
                            <%--Employee Information--%>
                            <div id="employeeInformation" class="divSections padding_top_20" runat="server">
                                <!--#include file="HtmlSections/EmployeeInformation.html"-->
                            </div>
                            <%--Claim Updates--%>
                            <div id="claimUpdates" class="divSections" runat="server">
                               <%-- <p>Claim Updates</p>--%>
                                <!--#include file="HtmlSections/ClaimUpdates.html"-->
                            </div>
                            <%--Incident Details--%>
                            <div id="incidentDetails" class="divSections" runat="server">
                                <!-- HTML will be rendered into the div App -->
                                <div class="row" style="margin-top: 10px;">
                                    <div id="IncidentDetailsWrapper" class="col-md-12 padding_0">
                                    </div>
                                </div>
                                <%--<div style="margin-bottom: 600px;"></div>--%>
                                <!-- ------------------------------------------------------MODAL TEMPLATES---------------------------------------------------------------- -->
                                <template id="witnesses-ModalTemplate">
                                    <div id='witnesses' data-tablename="WitnessDetailsTable">
                                        <div class="row margin_bottom">
                                            <div class="col-md-4">
                                                <label for="mgrName">Name</label>
                                                <input type="text" class="form-control col-md-3" name="WitnessName" data-id="WitnessName" placeholder="Name" />
                                            </div> 
                                            <div class="col-md-4">
                                                <label for="mgrPhone">Phone Number</label>
                                                <input type="text" class="form-control col-md-3 vld-phone" name="WitnessPhone" data-id="WitnessPhone" placeholder="Phone Number" />
                                            </div>
                                            <div class="col-md-4">
                                                <label for="mrgEmail">Email</label>
                                                <input type="text" class="form-control col-md-3" name="WitnessEmail" data-id="WitnessEmail" placeholder="Email" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="witnessStat">Witness Statement</label>
                                                <textarea class="form-control" name="WitnessStatement" rows="3" data-id="WitnessStatement" placeholder="Witness Statement"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                                <template id="collateralDamages-ModalTemplate">
                                <!-- Collatoral Damage FORM STRUCTURE -->
                                    <div id='CollDamageDetails' data-tablename="CollateralDamagesTable">
                                        <div class="row">
                                            <div class="col-md-8">
                                                <label for="DamType">Select a damage type:</label>
                                                <select data-id="DamType" onchange="showHideBasedOnSelect($(this)); clearForms($(this).find('option:selected').attr('data-sectionname'));" class="form-control">
                                                    <option label="---" value="0"></option>
                                                    <option data-sectionname="AnimalDetails" value="Animal">Animal</option>
                                                    <option data-sectionname="PropertyDetails" value="Property">Property</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="DamReason">Reason</label>
                                                <textarea data-id="DamReason" name="DamReason" class="form-control" rows="4" placeholder="Reason"></textarea>
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div data-id='AnimalDetails' class='panel panel-custom-primarybaby-default hidden' >
                                                <div class="panel-heading">Animal Details</div>
                                                <div class="panel-body">
                                                    <div class="row margin_bottom">
                                                        <div class="col-md-3">
                                                            <label for="aniDescription">Description</label>
                                                            <input type="text" class="form-control" data-id="AnimalDesc" name="AnimalDesc" placeholder="Description" />
                                                        </div>
                                                        <div class="col-md-3">
                                                            <label for="aniType">Animal Type</label>
                                                            <input type="text" class="form-control" data-id="AnimalType" name="AnimalType" placeholder="Animal Type" />
                                                        </div>
                                                        <div class="col-md-3">
                                                            <label for="aniOwnName">Owner Name</label>
                                                            <input type="text" class="form-control" data-id="OwnerName" name="OwnerName" placeholder="Owner Name" />
                                                        </div>
                                                        <div class="col-md-3">
                                                            <label for="aniOwnContact">Owner Contact</label>
                                                            <input type="text" class="form-control" data-id="OwnerContact" name="OwnerContact" placeholder="Owner Contact" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <!--PropertyDetails Form Structure-->
                                            <div data-id='PropertyDetails' class='panel panel-custom-primarybaby-default hidden'>
                                                <div class="panel-heading">Property Details</div>
                                                <div class="panel-body">
                                                    <div class="row margin_bottom">
                                                        <div class="col-md-4">
                                                            <label for="propType">Property Type</label>
                                                            <input type="text" class="form-control" data-id="PropertyType" name="PropertyType" placeholder="Property Type" />
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label for="plate">Plate</label>
                                                            <input type="text" class="form-control" data-id="Plate" name="Plate" placeholder="Plate" />
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label for="make">Make</label>
                                                            <input type="text" class="form-control" data-id="Make" name="Make" placeholder="Make" />
                                                        </div>
                                                    </div>
                                                    <div class="row margin_bottom">
                                                        <div class="col-md-4">
                                                            <label for="model">Model</label>
                                                            <input type="text" class="form-control" data-id="Model" name="Model" placeholder="Model" />
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label for="year">Year</label>
                                                            <input type="text" class="form-control" data-id="Year" name="Year" placeholder="Year" />
                                                        </div>
                                                        <div class="col-md-4">
                                                            <label for="propDescription">Description</label>
                                                            <input type="text" class="form-control" data-id="PropDescription" name="PropDescription" placeholder="Property Description" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                                <template id="correctiveActions-ModalTemplate">
                                <!-- Corrective Action Details FORM STRUCTURE -->
                                    <div id='CorrActionDetails' data-tablename="CorrectiveActionsTable">
                                        <div class="form-group">
                                            <label for="commitieMember">Joint Health & Safety Commmittie Member</label>
                                            <input type="text" class="form-control" data-id="JHSCM" name="JHSCM" placeholder="Joint Health & Safety Commmittie Member" />
                                        </div>
                                        <label>Corrective Measures (Select All that Apply):</label>
                                        <div class="row margin_bottom">
                                            <div class="col-md-3">
                                                <label for="corrMeasure">Description</label>
                                                <select class="form-control" name="CorrDescription" data-id="CorrDescription">
                                                    <option value="0" label="Select"></option>
                                                    <option label="Test Description" value="Test Description"></option>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="dateCorrectiveMeas">Date of implementing corrective measures</label>
                                                <input type="date" class="form-control" data-id="CorrDateTime" name="CorrDateTime" placeholder="Date of implementing corrective measures" />
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label for="ifnotCorrectiveMeas">If not taking corrective measures, why</label>
                                            <textarea class="form-control" data-id="CorrReason" name="CorrReason" rows="4" placeholder="If not taking corrective measures, why"></textarea>
                                        </div>
                                    </div>
                                </template>
                                <template id="limitationDetails-ModalTemplate">
                                <!-- Limitation Details FORM STRUCTURE -->
                                    <div id='limitationDetails' data-tablename="LimitationDetailsTable">
                                        <div class="row margin_bottom">
                                            <div class="col-md-6">
                                                <label for="ifnotCorrectiveMeas">DateTime</label>
                                                <input type="date" class="form-control" data-id="LimitDateTime" name="LimitDateTime" placeholder="DateTime" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="limitDescription">Description</label>
                                                <textarea data-id="LimitDescription" class="form-control" rows="4" name="LimitDescription" placeholder="Description"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                                <template id="BodyParts-ModalTemplate">
                                <!-- Modal Body -->
                                    <div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-6">
                                                <label for="BodyPart">Body Part</label>
                                                <input type="text" class="form-control" data-id="BodyPart" name="BodyPart" placeholder="Part" />
                                            </div>
                                            <div class="col-md-6">
                                                <label for="PartSide">Side</label>
                                                <input type="text" class="form-control" data-id="PartSide" name="PartSide" placeholder="Side" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="ICD10CatDescription">Enter a body part</label>
                                                <textarea class="form-control" data-id="PartDescription" rows="2" name="PartDescription" placeholder="Description"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                                <template id="Medications-ModalTemplate">
                                    <div>
                                    <!-- Modal Body -->
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="MedName">Name</label>
                                                <input type="text" class="form-control" data-id="MedName" name="MedName" placeholder="Name" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="MedReason">Reason</label>
                                                <textarea class="form-control" data-id="MedReason" name="MedReason" rows="2" placeholder="Reason"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                                <template id="Activities-ModalTemplate">
                                    <div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-6">
                                                <label for="actTime">Activity Time</label>
                                                <input type="date" class="form-control" data-id="ActTime" name="ActTime" placeholder="Activity Time" />
                                            </div>
                                        </div>
                                        <div class="row margin_bottom">
                                            <div class="col-md-12">
                                                <label for="actTime">Activity Description</label>
                                                <textarea data-id="ActDescription" name="ActDescription" rows="2" class="form-control" placeholder="Description"></textarea>
                                            </div>
                                        </div>
                                    </div>
                                </template>
                                <template id="Causes-ModalTemplate">
                                    <div>
                                    </div>
                                </template>
                            </div>
                            <%--ICDC10 Details--%>
                            <div id="ICD10Details" class="divSections" runat="server">
                                <!--#include file="HtmlSections/ICD10Details.html"-->
                            </div>
                            <%--Claim Tasks--%>
                            <div id="ClaimTasks" class="divSections" runat="server">
                                <!--#include file="HtmlSections/ClaimTasks.html"-->
                            </div>
                            <div id="ClaimContacts" class="divSections padding_top_20" runat="server">
                                <%--<p>Claim Contacts</p>--%>
                                <!--#include file="HtmlSections/ClaimContacts.html"-->
                            </div>
                            <div id="ClaimDetails" class="divSections" runat="server">
                                <!--#include file="HtmlSections/ClaimDetails.html"-->
                            </div>
                            <div id="ClaimDates" class="divSections padding_top_20" runat="server">
                                <!--#include file="HtmlSections/Claim_Dates.html"-->
                            </div>
                            <div id="ClaimDocuments" class="divSections" runat="server">
                                <!--#include file="HtmlSections/ClaimDocuments.html"-->
                            </div>
                            <div class="pull-right" style="padding-bottom: 20px!important; padding-right: 20px!important;">
                                <input type="button" value="submit" class="btn btn-success" id="submit" />
                                <input type="hidden" id="postBack" />
                                <input type="hidden" id="claimID" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>        
    </form>
    <script src="JSFiles/Claim.js"></script>
    <script src="JSFiles/EmployeeInfo.js"></script>
    <%--External File to create Claim Objects--%>
    <%--All the business rules are created in this file--%>
    <script src="JSFiles/DataBind.js"></script>
    <script src="JSFiles/Alerts.js"></script>
    <script src="JSFiles/ClaimTasks.js"></script>
    <script src="JSFiles/CloseClaim.js"></script>
    <script src="JSFiles/ServicesRules.js"></script>
    <script src="JSFiles/SaveUpdates.js"></script>
    <script src="JSFiles/PDF.js"></script>
    <%-- <script src="JSFiles/Absences.js"></script> --%>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="/Assets/js/common/Masking.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="JSFiles/ContactType.js"></script>
    <script src="JSFiles/TaskManager.js"></script>
    <script src="JSFiles/UserAssignment.js"></script>
</asp:Content>