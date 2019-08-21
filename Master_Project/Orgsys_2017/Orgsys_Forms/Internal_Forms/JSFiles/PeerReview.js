var Assigned;
var Outgoing;
var Pending;
var Returned;
var PrAvailable = false;
var availStr;

LoadPrData();
$(document).ready(function () {
    $('#chkPrAvailable').prop('checked', PrAvailable);
});

function LoadPrData() {
    $.ajax({
        url: getApi + "/api/PeerReview/GetPRByToken/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            var pr = JSON.parse(data);
            console.log(pr);
            Assigned = pr.Assigned;
            Outgoing = pr.Outgoing;
            Pending = pr.Pending;
            Returned = pr.Returned;
            PrAvailable = pr.PRavailable;
        }
    }).then(
        function () {
            loadAssignedReviews(Assigned);
            loadOutgoingReviews(Outgoing);
            loadPendingReviews(Pending);
            loadReturnedReviews(Returned);
        }, function () {
            alert("$.get failed!");
        }
    );
}

function loadAssignedReviews(assigned) {
    if ($.fn.DataTable.isDataTable("#tblAssignedReviews")) {
        $('#tblAssignedReviews').DataTable().clear().destroy();
    }

    tblAssignedReviews = $('#tblAssignedReviews').DataTable({
        select: true,
        data: assigned,
        "order": [[2, "Date_Opened"]],
        "sPaginationType": "full_numbers",
        "rowId": "Update_ID",
        "columns": [
            { "data": "" }, { "data": "Claim_Ref_No" }, { "data": "user_Submited" }, { "data": "Date_Opened" }, { "data": "ClientName" }, { "data": "EmpLastName" }, { "data": "Change_Comments" }
        ],
        "columnDefs": [
            {
                "targets": -7,
                "data": null,
                "searchable": false,
                "orderable": false,
                "defaultContent":
                    "<a id='btnViewUpdateAssigned' data-toggle='tooltip' title='View update' class='btn btn-default view_description'><i class='glyphicon glyphicon-eye-open'></i></a><a id='btnViewClaimAssigned' data-toggle='tooltip' title='View Claim' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-eye-open'></i><a id='btnAddComments' data-toggle='tooltip' title='Add comments to review' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-comment'></i><a id='btnDenied' data-toggle='tooltip' title='Send back for changes' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-remove-circle'></i><a id='btnSubmitReviewAssigned' data-toggle='tooltip' title='Submit review' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-ok-circle'></i>"
            }
        ]
    });
}

function loadOutgoingReviews(outgoing) {
    if ($.fn.DataTable.isDataTable("#tblOutgoingReviews")) {
        $('#tblOutgoingReviews').DataTable().clear().destroy();
    }

    tblOutgoingReviews = $('#tblOutgoingReviews').DataTable({
        select: true,
        data: outgoing,
        "order": [[2, "Date_Opened"]],
        "sPaginationType": "full_numbers",
        "rowId": "Update_ID",
        "columns": [
            { "data": "Claim_Ref_No" }, { "data": "user_Assigned" }, { "data": "Date_Opened" }, { "data": "ClientName" }, { "data": "EmpLastName" }
        ]
    });
}

function loadPendingReviews(pending) {
    if ($.fn.DataTable.isDataTable("#tblPendingReviews")) {
        $('#tblPendingReviews').DataTable().clear().destroy();
    }

    tblPendingReviews = $('#tblPendingReviews').DataTable({
        select: true,
        data: pending,
        "order": [[2, "Date_Opened"]],
        "sPaginationType": "full_numbers",
        "rowId": "Update_ID",
        "columns": [
            { "data": "" }, { "data": "Claim_Ref_No" }, { "data": "user_Submited" }, { "data": "Date_Opened" }, { "data": "ClientName" }, { "data": "EmpLastName" }
        ],
        "columnDefs": [
            {
                "targets": -6,
                "data": null,
                "searchable": false,
                "orderable": false,
                "defaultContent":
                    "<a id='btnTakeReview' data-toggle='tooltip' title='Take Review' class='btn btn-default view_description'><i class='glyphicon glyphicon-plus'></i></a>"
            }
        ]
    });
}

function loadReturnedReviews(returned) {
    if ($.fn.DataTable.isDataTable("#tblReturnedReviews")) {
        $('#tblReturnedReviews').DataTable().clear().destroy();
    }

    tblReturnedReviews = $('#tblReturnedReviews').DataTable({
        select: true,
        data: returned,
        "order": [[2, "Date_Opened"]],
        "sPaginationType": "full_numbers",
        "rowId": "Update_ID",
        "columns": [
            { "data": "" }, { "data": "Claim_Ref_No" }, { "data": "user_Assigned" }, { "data": "Date_Opened" }, { "data": "ClientName" }, { "data": "EmpLastName" }
        ],
        "columnDefs": [
            {
                "targets": -6,
                "data": null,
                "searchable": false,
                "orderable": false,
                "defaultContent": "<a id='btnViewUpdateChanges' data-toggle='tooltip' title='View update' class='btn btn-default view_description'><i class='glyphicon glyphicon-eye-open'></i></a><a id='btnViewClaimChanges' data-toggle='tooltip' title='View Claim' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-eye-open'></i><a id='btnReturnedComments' data-toggle='tooltip' title='Comments from reviewer' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-comment'></i><a id='btnSubmitReviewChanges' data-toggle='tooltip' title='Submit review' class='btn btn-default view_description'><i class='icon glyphicon glyphicon-ok-circle'></i>"
            }
        ]
    });
}

function PrAvailableToggle() {
    PrAvailable = !PrAvailable;
    $('#chkPrAvailable').prop('checked', PrAvailable);

     availStr = "Available";
    if (!PrAvailable) {
        availStr = "Unavailable";
    }
}

$(document).delegate("#btnViewUpdateAssigned", "click", function (event) {
    var updateID = tblAssignedReviews.row($(this).parents("tr")).data().Update_ID;
    window.location.replace("/OrgSys_Forms/Internal_Forms/PeerReviewClaimUpdate.aspx?UpdateID=" + updateID + "&Assigned=true");
});
$(document).delegate("#btnViewUpdateChanges", "click", function (event) {
    var updateID = tblReturnedReviews.row($(this).parents("tr")).data().Update_ID;
    window.location.replace("/OrgSys_Forms/Internal_Forms/PeerReviewClaimUpdate.aspx?UpdateID=" + updateID + "&Assigned=false");
});

$(document).delegate("#btnViewClaimAssigned", "click", function (event) {
    var claimRefNo = tblAssignedReviews.row($(this).parents("tr")).data().Claim_Ref_No;
    window.location.replace("/OrgSys_Forms/Internal_Forms/WC.aspx?ClaimRefNo=" + claimRefNo);
});

$(document).delegate("#btnViewClaimChanges", "click", function (event) {
    var claimRefNo = tblReturnedReviews.row($(this).parents("tr")).data().Claim_Ref_No;
    window.location.replace("/OrgSys_Forms/Internal_Forms/WC.aspx?ClaimRefNo=" + claimRefNo);
});

$(document).delegate("#btnDenied", "click", function (event) {
    var ChangeComments = tblAssignedReviews.row($(this).parents("tr")).data().Change_Comments;
    var updateID = tblAssignedReviews.row($(this).parents("tr")).data().Update_ID;
    if ($.trim(ChangeComments) === '') {
        swal('No Comments!', 'You must add comments as to where the user needs to update the claim for submission.').catch(swal.noop);
    } else {
        $.ajax({
            url: getApi + "/api/PeerReview/ReturnReviewForChanges/" + updateID,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            method: "PUT",
            async: false,
            success: function (data) {

            }
        }).then(
            function () {
                swal("Returned!").catch(swal.noop);
                LoadPrData();
            }, function () {
                alert("failed!");
            }
        );
    }
});

$(document).delegate("#btnSubmitReviewChanges", "click", function (event) {
    var updateID = tblReturnedReviews.row($(this).parents("tr")).data().Update_ID;
    //swal check if user has made all changes
    swal({
        title: 'Please confirm',
        text:
            "Have you reviewed the change comments and made the necesary changes to the peer review?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function (json_data) {
        //ajax call here to update claim status to updates and PR to closed
        $.ajax({
            url: getApi + "/api/PeerReview/ClosePeerReview/" + updateID + "/" + window.token,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            method: "PUT",
            async: false
        }).then(
            function () {
                swal('success', "Peer review has been submited", 'success').catch(swal.noop);
                LoadPrData();
            }, function () {
                alert("failed!");
            }
        );
    },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close' || dismiss === 'overlay') {
                swal('Not sumbited', 'you must read the change comments and make the necessary changes.', 'error').catch(swal.noop);
            }
        });
});

$(document).delegate("#btnSubmitReviewAssigned", "click", function (event) {
    var updateID = tblAssignedReviews.row($(this).parents("tr")).data().Update_ID;
    //swal check if user has made all changes
    swal({
        title: 'Please confirm',
        text:
            "Have you reviewed the claim and updates regarding this PR?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function (json_data) {
            //ajax call here to update claim status to updates and PR to closed
            $.ajax({
                url: getApi + "/api/PeerReview/ClosePeerReview/" + updateID + "/" + window.token,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                method: "PUT",
                async: false
            }).then(
                function () {
                    swal('success', "Peer review has been submited", 'success').catch(swal.noop);
                    LoadPrData();
                }, function () {
                    alert("failed!");
                }
            );
        },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close' || dismiss === 'overlay') {
                swal('Not sumbited', 'you must review the claim and update regarding this claim', 'error').catch(swal.noop);
            }
        });

});

$(document).delegate("#btnReturnedComments", "click", function (event) {
    var ChangeComments = tblReturnedReviews.row($(this).parents("tr")).data().Change_Comments;
    swal('Returned comments.', ChangeComments).catch(swal.noop);
});

$(document).delegate("#btnTakeReview", "click", function (event) {
    var updateID = tblPendingReviews.row($(this).parents("tr")).data().Update_ID;
    $.ajax({
        url: getApi + "/api/PeerReview/TakePendingReview/" + updateID + "/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        method: "PUT",
        async: false
    }).then(
        function (data) {
            swal('Success', data).catch(swal.noop);
            LoadPrData();
        }, function (data) {
            swal('Error', data.responseText).catch(swal.noop);
        }
    );
});

$(document).delegate("#btnAddComments", "click", function (event) {

    var updateID = tblAssignedReviews.row($(this).parents("tr")).data().Update_ID;

    swal({
        title: "Enter comments.",
        input: "textarea",
        showCancelButton: true,
        preConfirm : false,
        animation: "slide-from-top",
        inputPlaceholder: "Write something"
    }).then(function(result) {
        if ($.trim(result) === '') {
            swal('Empty !','you must enter text.');
        } else {
            $.ajax({
                url: getApi + "/api/PeerReview/UpdateReviewComment/" + updateID + "/" + window.token,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                method: "PUT",
                async: false,
                data: JSON.stringify(String.fromCharCode(13, 10) + String.fromCharCode(13, 10) +result),
                contentType: 'application/json'
            }).then(
                function () {
                    swal("Updated!").catch(swal.noop);
                    LoadPrData();
                }, function () {
                    alert("failed!").catch(swal.noop);
                }
            );
        }
    });
});

$(document).delegate("#chkPrAvailable", "change", function (event) {
    PrAvailableToggle();

    swal({
        title: 'Please confirm',
        text:
            "Do you wish to become " + availStr + " ?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function () {
            $.ajax({
                url: getApi + "/api/PeerReview/ToggleUserPRAvailability/" + window.token + "/" + PrAvailable,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                method: "PUT",
                async: false
            }).then(
                function () {
                    swal('success', "You have become " + availStr, 'success').catch(swal.noop);
                }, function () {

                    PrAvailableToggle();
                    swal('Not changed', 'Availablity not changed, you are still ' + availStr, 'error').catch(swal.noop);
                }
            );
        },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close' || dismiss === "overlay") {

                PrAvailableToggle();
                swal('Not changed', 'Availablity not changed, you are still ' + availStr, 'error').catch(swal.noop);
            }
        });

});
