function ShowValidationErrorsSwal() {
    var errors = $('.error').length;//evaluated below, see multilingual documentation
    var formerror = eval("`" + window.MessagesData["InterpolFormError"] + "`");
    swal(formerror, window.MessagesData["formReview"], 'error');
}

function ShowClaimSubmissionSuccessSwal() {
    swal(window.MessagesData["claimSuccessTitle"], window.MessagesData["claimSuccessDesc"], 'success')
        .then(function () {
            window.location.href = '/Orgsys_Forms/Generic_Forms/PortalHome.aspx';
        });
}

function ShowClaimDraftSavedSuccessSwal() {
    swal(window.MessagesData["draftSavedTitle"], window.MessagesData["draftSavedDesc"], 'success')
        .then(function () {
            window.location.href = '/Orgsys_Forms/Generic_Forms/PortalHome.aspx';
        });
}