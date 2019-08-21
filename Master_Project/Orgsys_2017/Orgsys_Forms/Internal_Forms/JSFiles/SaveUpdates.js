//Declare Global Variables for saveupdates.js and claimupdates.js
//Created by Marie
//Created on 09-10-2018
//Update on 3/14/2019 - jvangeemen - fixed syntax errors, changes IsActive to IsArchived to match db model
//Update on 3/29/2019 - jvangeemen - CMR Template, Defaults set
//ClaimUpdates.HTML

var isBillable;
var isDirectContact;
var isPostage;
var isCourier;
var isInReview;
var SeniorConsulting;
var ClaimUpdate;
var Documents;
var ClaimUpdatesDocuments;
var ClaimUpdateDTO;
var BillingUpdate;

var ActionType;
var UpdateDate;
var Duration;
var ReportedComments;
var EmployeeComments;
var InternalComments;
var BillReason;
var BillMethod;
var BillComments;


function SaveUpdates() {

    if (Validate('#UpdatesForm')) {
        CreateClaimUpdates();
        SaveUpdatesData();
    } else {
        swal("Invalid", "Please check all highlighted fileds", "error");
    }
}

//will validate and element with the class of validRequired returns true if all elements valid in given selector
function Validate(selector) {
    var valid = true;

    $(selector).find(".validRequired").each(function () {
        if (!$(this).val()) {
            $(this).closest(".form-group").addClass("has-error");
            valid = false;
        } else {
            $(this).closest(".form-group").removeClass("has-error");
        }
    });
    return valid;
}


function CreateClaimUpdates() {

    if ($('#billable').is(":checked")) {
        isBillable = 1;
    } else {
        isBillable = 0;
    }
    if ($('#directcontact').is(":checked")) {
        isDirectContact = 1;
    } else {
        isDirectContact = 0;
    }
    if ($('#postage').is(":checked")) {
        isPostage = 1;
    } else {
        isPostage = 0;
    }
    if ($('#courier').is(":checked")) {
        isCourier = 1;
    } else {
        isCourier = 0;
    }
    if ($('#SeniorConsulting').is(":checked")) {
        SeniorConsulting = 1;
    } else {
        SeniorConsulting = 0;
    }

    //Updates payloads
    var UpdFileData = new FormData();
    var UpdDocuments = [];

    window.fileArray.forEach(function (fileObject) {
        UpdFileData.append('doc' + fileObject.id, fileObject.file);
        UpdDocuments.push({
            TimeStamp: $('#UpdatesDate').val(),
            UserID: window.UserID,
            FileExt: fileObject.ext,
            VersionNumber: 1,
            FileName: fileObject.file.name,
            ClaimReference: window.ClaimRefNu,
            UpdateID: 0 //set in controller upon ClaimInsert
        });
    });

    ClaimUpdate = {
        UserID: window.UserID,
        ActionType: $('#ActionType').val(),
        UpdatesDate: $('#UpdatesDate').val(),
        InternalComments: $('#InternalComments').val(),
        ReportedComments: $('#ReportedComments').val(),
        EmployeeComments: $('#EmployeeComments').val(),
        ClaimRefNu: window.ClaimRefNu,
        Billable: isBillable,
        IsArchived: 0,
        IsInReview: isInReview
    };
    BillingUpdate = {
        Completed: 1,
        CompletionDate: $('#UpdatesDate').val(),
        DirectContact: isDirectContact,
        Postage: isPostage,
        Courier: isCourier,
        Method: $('#BillingMethod').val(),
        Reason: $('#BillingReason').val(),
        Duration: $('#ClientBillDuration').val(),
        UpdateId: 0, //set in controller upon Claim update insert
        Comments: $('#ClientBillComments').val(),
        SeniorConsulting: SeniorConsulting
    };


    Documents = UpdFileData;
    ClaimUpdatesDocuments = UpdDocuments;
    ClaimUpdateDTO = {
        claimUpdate: ClaimUpdate,
        claimUpdatesBilling: BillingUpdate,
        claimUpdateDocuments: ClaimUpdatesDocuments
    };
}

//Post payloads to api
var update = 0;
function SaveUpdatesData() {
    var ClaimId = window.ClaimID;
    var files = window.fileArray;

    if ($.trim(ClaimUpdate.ReportedComments) !== '') {
        ClaimUpdate.isInReview = 1;
    } else {
        ClaimUpdate.isInReview = 0;
    }

    $.ajax({
        url: getApi + "/api/ClaimUpdates/SaveUpdates",
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        type: "POST",
        async: false,
        data: '=' + encodeURIComponent(JSON.stringify(ClaimUpdateDTO)),
        success: function (updateid) {
            window.UpdateID = updateid;
            //if files exist post them
            if (files.length !== 0) {
                SaveClaimDocuments(files, ClaimId);
            }
            swal({
                title: 'Claim update saved successfuly',
                text:
                    "If you would like to fill out a CMR please click Open CMR, or click close to enter more updates.",
                type: 'success',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                cancelButtonText: "Close",
                confirmButtonText: 'Open CMR'
            }).then(function (json_data) {
                //refresh the claim updates table to show new data
                PopulateUpdates(window.ClaimRefNu);

                window.reportedComments = $("#ReportedComments").val();

                //if the update worked open a cmr 
                OpenCMR();
            },
                function (dismiss) {
                    if (dismiss === 'cancel' || dismiss === 'close') {
                        PopulateUpdates(window.ClaimRefNu);
                    }
                });
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            swal('Updates not saved', errorThrown, 'error');
        }
    });
    ClearClaimUpdates();
}

function ClearClaimUpdates() {
    $('#ActionType').val('1');
    $('#InternalComments').val('');
    $('#ReportedComments').val('');
    $('#EmployeeComments').val('');
    $('#BillingMethod').val('0');
    $('#BillingReason').val('0');
    $('#ClientBillDuration').val('');
    $('#ClientBillComments').val('');
    $('input:checkbox').removeAttr('checked');

    var w = document.getElementsByTagName('input');
    for (var i = 0; i < w.length; i++) {
        if (w[i].type === 'checkbox') {
            w[i].checked = false;
        }
    }
}

function OpenCMR() {
    $('#AllUpdates').hide();
    $('#CMR').show();

    //grab the cmr template and inject it 
    $.get("/Orgsys_Forms/Internal_Forms/Templates/CMRTemplate.html", function (html) {
        $('#CMRINJECT').html(html);
    }).then(function () {
        InitializeCMRTemplate();
        PopulateOSIContactList();
        PopulateClaimStatusList();
    });


}

$("#btnSendCMR").click(function () {
    if (Validate('.CMRTemplate')) {
        SendCMR();
    } else {
        swal("Invalid", "Please check all highlighted fileds", "error");
    }
});
$("#btnCloseCMR").click(function () {
    $('#AllUpdates').show();
    $('#CMR').hide();
});



function SendCMR() {
    cmr = {       
        UserID :window.UserID,
        UpdateID: window.UpdateID,
        AbsenceAuthorization: $("#AbsenceAuthorization").val(),
        ClaimHistoryInformation: $("#ClaimHistoryInformation").val(),
        ClaimStatusID: $("#ClaimStatus").val(),
        DateOfAbsence: $("#DateofAbsence").val(),
        DateOfReferal: $("#DateOfReferral").val(),
        DateOfReport : $("#DateOfReport").val(),
        EmployeeID :$("#EmployeeID").val(),
        EmployeeName: $("#EmployeeName").val(),
        EmployerContactID: $("#EmployerContact").val(),
        Location: $("#Location").val(),
        NextSteps: $("#NextSteps").val(),
        OSIContactID: $("#OSIContact").val(),
        ReturntoWorkRecommendations: $("#ReturntoWorkRecommendations").val(),
        TreatmentPlan: $("#TreatmentPlan").val(),
        EmployeeContactID: $("#ddlEmployeeContact").val()
    };

    $.ajax({
        url: getApi + "/api/CMR/SaveCmr",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: "POST",
        async: false,
        data: JSON.stringify(cmr),
        contentType: "application/json",
        success: function (updateid) {
            swal({
                title: 'Sent!',
                text: "",
                type: 'success',
                showCancelButton: false,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'OK'
            }).then(function () {
                $('#CMR').hide();
                $('#AllUpdates').show();
            });
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            swal('Not sent', errorThrown, 'error');
        }
    });
}

function InitializeCMRTemplate() {
    $.ajax({
        url: getApi + "/api/CMR/GetCMRDefaults/" + window.ClaimID,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            $("#DateOfReport").val(data.DateOfReport);
            $("#EmployeeName").val(data.EmpName);
            $("#EmployeeID").val(data.EmpIDNO);
            $("#DateOfReferral").val(data.DateOfReferal);
            $("#Location").val(data.Location);

            var contacts = data.ClaimContacts;
            var data_length = contacts.length;
            for (var i = 0; i < data_length; i++) {
                $('#EmployerContact').append($('<option/>', {
                    text: contacts[i]["ContactType"] + " - " + contacts[i]["ContactName"],
                    value: contacts[i]["ContactID"]
                }));
            }

            var empContacts = data.EmployeeContacts;
            for (var c = 0; c < empContacts.length; c++) {
                $('#ddlEmployeeContact').append($('<option/>', {
                    text: empContacts[c]["ContactPriority"] + " - " + empContacts[c]["ContactEmail"],
                    value: empContacts[c]["ContactID"]
                }));
            }

        }
    });
}

function PopulateOSIContactList() {
    $.ajax({
        url: getApi + "/api/" + token + "/Users/all",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            var contacts = JSON.parse(data);
            var data_length = contacts.length;
            for (var i = 0; i < data_length; i++) {
                $('#OSIContact').append($('<option/>', {
                    text: contacts[i]["EmpFirstName"] + " " + contacts[i]["EmpLastName"],
                    value: contacts[i]["UserID"]
                }));
            }
        }
    });
}

function PopulateClaimStatusList() {
    $.ajax({
        url: getApi + "/api/Databind/GetList_ClaimStatus",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            var contacts = JSON.parse(data);
            var data_length = contacts.length;
            for (var i = 0; i < data_length; i++) {
                $('#ClaimStatus').append($('<option/>', {
                    text: contacts[i]["Status_EN"],
                    value: contacts[i]["index"]
                }));
            }
        }
    });
}