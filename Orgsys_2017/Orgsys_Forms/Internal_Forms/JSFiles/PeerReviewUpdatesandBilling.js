var updateID;
var assigned;
var MethodID;
var Reason;
var UpdatesBilling;
var CMRUpdate;
var UserID;
var CLaimRefNo;
var OsiContact;
var EmployerContact;
var ClaimStatus;
var FilesTable;
var fileArray = [];
var EmpContact;

$(document).ready(function () {
    if ($.url().param('UpdateID')) {
        updateID = $.url().param('UpdateID');
    } else {
        alert('No update id supplied');
        window.location.replace("/OrgSys_Forms/Internal_Forms/PeerReview.aspx");
    }
    if ($.url().param('Assigned') && $.url().param('Assigned') === 'true') {
        $('#btnAddComments').css('display', 'inline-block');
    }
    LoadPRData();  
       
});

function LoadPRData() {
    $.ajax({
        url: getApi + "/api/PeerReview/GetAssignedPRData/" + updateID + "/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function (data) {
            var pr = JSON.parse(data);
            $('#hDateOpened').val(pr.Date_Opened.substring(0, 10) + " - " + pr.Date_Opened.substring(11, 16));
            $('#hClaimRefNo').val(pr.Claim_Ref_No);
            CLaimRefNo = pr.Claim_Ref_No;
            $('#hUserSubmited').val(pr.Username);
            $('#hClient').val(pr.ClientName);
            $('#hEmployeeLast').val(pr.EmpLastName);
            $('#hReviewComments').text(pr.Change_Comments);
        }, function () {
            alert("$.get failed!");
        }
    ).then(function() {
        GetClaimID();
    });
}
function LoadControls() {
    $.ajax({
        url: getApi + "/api/Databind/GetList_BillingMethod",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function (data) {
            var pr = JSON.parse(data);
            for (var i = 0; i < pr.length; i++) {
                $("#BillingMethod").append('<option value='+pr[i].MethodID+'>'+pr[i].Method_EN+'</option>');
            }
            
        }, function () {
            alert("$.get failed!");
        }
    ).then(function() {
        $("#BillingMethod").val(MethodID);
    }).then(function() {
        LoadBillingReason(MethodID);
    }).then(function () {
        $("#BillingReason").val(Reason);
    });

    
}
function LoadBillingReason(method) {
    $.ajax({
        url: getApi + "/api/Databind/GetList_BillingReason/" + method,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function(data) {
            var pr = JSON.parse(data);
            for (var i = 0; i < pr.length; i++) {
                $("#BillingReason").append('<option value=' + pr[i].ReasonID + '>' + pr[i].Reason_EN + '</option>');
            }
        },
        function() {
            alert("$.get failed!");
        }
    );
}
function LoadPRClaimUpdate() {
    $.ajax({
        url: getApi + "/api/PeerReview/GetPRClaimUpdate/" + updateID + "/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function (data) {
            var pr = JSON.parse(data);
            $('#ActionType').val(pr.ActionType);
            $('#UpdatesDate').val(pr.UpdatesDate.substring(0, 10));
            $('#InternalComments').val(pr.InternalComments);
            $('#ReportedComments').val(pr.ReportedComments);
            $('#EmployeeComments').val(pr.EmployeeComments);
            $('#ClientBillDuration').val(pr.Duration);
            $('#billable').prop('checked', pr.Billable);
            $('#directcontact').prop('checked', pr.DirectContact);
            $('#postage').prop('checked', pr.Postage);
            $('#courier').prop('checked', pr.Courier);
            $('#SeniorConsulting').prop('checked', pr.SeniorConsulting);

            MethodID = pr.Method;
            Reason = pr.Reason;
            $('#ClientBillComments').text(pr.Comments);

            if (pr.HasCMR === true) {
                $('#cmrtab').css('display', 'inline-block');
                LoadCMR();
            }
        }, function () {
            alert("$.get failed!");
        }
    ).then(function() {
        LoadControls();
        GetClaimUpdateFiles();
    });
}
function CompileUpdateData() {
        UpdatesBilling = {
        InternalComments: $('#InternalComments').val(),
        ReportedComments: $('#ReportedComments').val(),
        EmployeeComments: $('#EmployeeComments').val(),
        Billable: $('#billable').prop('checked'),
        CompletionDate: $('#UpdatesDate').val(),
        DirectContact: $('#directcontact').prop('checked'),
        Postage: $('#postage').prop('checked'),
        Courier: $('#courier').prop('checked'),
        SeniorConsulting: $('#SeniorConsulting').prop('checked'),
        Method: $('#BillingMethod').val(),
        Reason: $('#BillingReason').val(),
        Duration: $('#ClientBillDuration').val(),
        Comments: $('#ClientBillComments').val()
    };
}
function CompileCMRData() {
    CMRUpdate = {
        UserID: UserID,
        UpdateID: updateID,
        AbsenceAuthorization: $("#AbsenceAuthorization").val(),
        ClaimHistoryInformation: $("#ClaimHistoryInformation").val(),
        ClaimStatusID: $("#ClaimStatus").val(),
        DateOfAbsence: $("#DateofAbsence").val(),
        DateOfReferal: $("#DateOfReferral").val(),
        DateOfReport: $("#DateOfReport").val(),
        EmployeeID: $("#EmployeeID").val(),
        EmployeeName: $("#EmployeeName").val(),
        EmployerContactID: $("#EmployerContact").val(),
        Location: $("#Location").val(),
        NextSteps: $("#NextSteps").val(),
        OSIContactID: $("#OSIContact").val(),
        ReturntoWorkRecommendations: $("#ReturntoWorkRecommendations").val(),
        TreatmentPlan: $("#TreatmentPlan").val(),
        EmployeeContactID: $("#ddlEmployeeContact").val()

    };
}
function GetPRCMR() {
    $.ajax({
        url: getApi + "/api/PeerReview/GetPRCMR/" + window.updateID + "/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function(data) {
            var CMR = JSON.parse(data);

            ClaimStatus = CMR.ClaimStatusID;
            $("#DateOfReport").val(CMR.DateOfReport.substring(0, 10));
            $("#EmployeeName").val(CMR.EmployeeName);
            $("#EmployeeID").val(CMR.EmployeeID);
            $("#DateOfReferral").val(CMR.DateOfReferal.substring(0, 10));
            $("#Location").val(CMR.Location);
            $("#DateofAbsence").val(CMR.DateOfAbsence.substring(0, 10));
            EmployerContact = CMR.EmployerContactID;
            OsiContact = CMR.OSIContactID;
            $("#ClaimHistoryInformation").val(CMR.ClaimHistoryInformation);
            $("#AbsenceAuthorization").val(CMR.AbsenceAuthorization);
            $("#TreatmentPlan").val(CMR.TreatmentPlan);
            $("#ReturntoWorkRecommendations").val(CMR.ReturntoWorkRecommendations);
            $("#NextSteps").val(CMR.NextSteps); 
            EmpContact = CMR.EmployeeContactID;

            UserID = CMR.UserID;
        }
    });
}
function LoadCMR() {
    $.get("/Orgsys_Forms/Internal_Forms/Templates/CMRTemplate.html", function (html) {
        $('#CMR').html(html);
    }).then(function () {
        GetPRCMR();
        PopulateOSIContactList();
        $("#OSIContact").val(OsiContact);
        GetClaimContacts();
        PopulateClaimStatusList();
        $('#ClaimStatus').val(ClaimStatus);
        GetEmployeeContacts();
    });
}
function GetClaimID() {
    $.ajax({
        url: getApi + "/api/Claim/GetLatestClaimIDFromRefNo/" + CLaimRefNo,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        async: false
    }).then(
        function(id) {
            window.ClaimID = JSON.parse(id).ClaimID;
            LoadPRClaimUpdate();
        },
        function(error) {
            alert("failed to get claim id from claimrefNO");
            console.log(error);
        }
    );
}
function GetClaimContacts() {
            $.ajax({
                url: getApi + "/api/Claim/GetClaimContacts/" + window.ClaimID,
                beforeSend: function (request) {
                    request.setRequestHeader("Authentication", window.token);
                },
                async: false,
                success: function (data) {
                    var contacts = JSON.parse(data);
                    for (var i = 0; i < contacts.length; i++) {
                        $('#EmployerContact').append($('<option/>', {
                            text: contacts[i]["ContactType"] + " - " + contacts[i]["Con_FirstName"] + " " + contacts[i]["Con_LastName"],
                            value: contacts[i]["ContactID"]
                        }));
                    }
                }
            }).then(function() {
        $('#EmployerContact').val(EmployerContact);
    }); 
}
function GetEmployeeContacts() {
    $.ajax({
        url: getApi + "/api/PeerReview/GetPRCMREmployeeContacts/" + window.ClaimID,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            var empContacts = JSON.parse(data);
            for (var c = 0; c < empContacts.length; c++) {
                $('#ddlEmployeeContact').append($('<option/>', {
                    text: empContacts[c]["ContactPriority"] + " - " + empContacts[c]["ContactEmail"],
                    value: empContacts[c]["ContactID"]
                }));
            }
        }
    }).then(function () {
        $('#ddlEmployeeContact').val(EmpContact);
    });
}
function GetClaimUpdateFiles() {
    $.ajax({
        url: getApi + "/api/PeerReview/GetPRClaimUpdateFiles/" + updateID + "/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function (data) {
            var files = JSON.parse(data);
            if (files.length > 0) {
                $('#filesTab').css('display', 'inline-block');
                FilesTable = $('#tblClaimUpdateFiles').DataTable({
                    data: files,
                    select: false,
                    "sPaginationType": "full_numbers",
                    "rowId": "DocumentID",
                    "columns": [
                        { "data": "" }, { "data": "FileName" }
                    ],
                    "columnDefs": [
                        {
                            "targets": 0,
                            "data": null,
                            "searchable": false,
                            "orderable": false,
                            "defaultContent":
                                "<a id='btnOpenFile' data-toggle='tooltip' title='View update' class='btn btn-default view_description'><i class='glyphicon glyphicon-eye-open'></i>"
                        }
                    ]
                });
            }
        }, function () {
            alert("$.get failed!");
        }
    );
}
$(document).delegate("#btnAddComments", "click", function (event) {


    swal({
        title: "Enter comments.",
        input: "textarea",
        showCancelButton: true,
        preConfirm: false,
        animation: "slide-from-top",
        inputPlaceholder: "Write something"
    }).then(function (result) {
        if ($.trim(result) === '') {
            swal('Empty !', 'you must enter text.');
        } else {
            $.ajax({
                url: getApi + "/api/PeerReview/UpdateReviewComment/" + updateID + "/" + window.token,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                method: "PUT",
                async: false,
                data: JSON.stringify(result),
                contentType: 'application/json',
            }).then(
                function () {
                    swal("Updated!");
                    $('#hReviewComments').append(document.createTextNode(String.fromCharCode(13, 10) + String.fromCharCode(13, 10)+result));
                }, function () {
                    alert("failed!");
                }
            );
        }
    });
});

$(document).delegate("#btnSavePRUpdates", "click", function (event) {
    swal({
        title: 'Please confirm',
        text:
            "Have you reviewed the change comments and made the necesary changes to the peer review?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function() {
        CompileUpdateData();
    }).then(function () {
            console.log(JSON.stringify(UpdatesBilling));
       
            //ajax call here to update claim status to updates and PR to closed
            $.ajax({
                url: getApi + "/api/PeerReview/ArchiveClaimUpdateAndBilling/" + updateID + "/" + window.token,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                method: "POST",
                async: false,
                data: '=' + encodeURIComponent(JSON.stringify(UpdatesBilling))
            }).then(
                function () {
                    swal('success', "Changes have been saved", 'success');
                }, function (error) {
                    alert("failed to save updates");
                    console.log(error);
                }
            );
        },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close') {
                swal('Not sumbited', 'you must read the change comments and make the necessary changes.', 'error');
            }
        });
});

$(document).on('change', '.populateBillingMethodwithID', function (event) {
    $('#BillingReason').empty();
    LoadBillingReason($('#BillingMethod').val());
});

$(document).delegate("#btnSavePrCMR", "click", function (event) {
    if (Validate('.CMRTemplate')) {
    swal({
        title: 'Please confirm',
        text:
            "Have you reviewed the change comments and made the necesary changes to the peer review?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function () {
        CompileCMRData();
    }).then(function () {

            //ajax call here to update claim status to updates and PR to closed
            $.ajax({
                url: getApi + "/api/PeerReview/ArchivePRCMR/" + updateID + "/" + window.token,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                method: "POST",
                async: false,
                data: JSON.stringify(CMRUpdate),
                contentType: "application/json"
            }).then(
                function () {
                    swal('success', "Changes have been saved", 'success');
                }, function (error) {
                    alert("failed to save updates");
                    console.log(error);
                }
            );
        },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close') {
                swal('Not sumbited', 'you must read the change comments and make the necessary changes.', 'error');
            }
            });

    } else {
        swal("Invalid", "Please check all highlighted fileds", "error");
    }

});

$(document).delegate("#btnOpenFile", "click", function (event) {
    var DocID = FilesTable.row($(this).parents("tr")).data().DocumentID;
    var link = document.createElement('a');
    document.body.appendChild(link);
    link.href = getApi + "/api/Files/DownloadClaimFile/" + window.token + "/" + DocID;
    link.click();
});


$(document).delegate("#btnBackPeerReview", "click", function (event) {
   
    swal({
        title: 'Please confirm',
        text:
            "Have you saved all changes to this document?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function (json_data) {
        window.location.replace("/OrgSys_Forms/Internal_Forms/PeerReview.aspx");
        },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close' || dismiss === 'overlay') {
               //nothing
            }
        });
});


