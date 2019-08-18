//Created by:   Marie
//Created on:   04-20-2018

$(document).ready(function () {
    $('[data-toggle="tooltip"]').tooltip();
});

$(function () {
    $(document).on('click', '.closeClaim', function (e) {
        var reason = $('#reasonClosed option:selected').text();
        var claimid = $.url().param('ClaimID');
        var claimRefNo = $('#ClaimRefNu').val();
        var userid = window.UserID;
        var finalComments = $('#reasonClosedDesc').val();

        AdjudicateClaim(reason, claimid, claimRefNo, userid, finalComments);
    });
});
function AdjudicateClaim(reason, claimid, claimRefNo, userid, finalComments) {
    $.ajax({
        url: getApi + "/api/ClaimUpdates/UpdateAdjudicateClaim/" + token,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        type: "POST",
        data: {
            reason: reason,
            claimId: claimid,
            claimReference: claimRefNo,
            userId: userid,
            comment: finalComments
        }
    }).then(
        function () { 
            swal({
                title: "Claim # " + claimRefNo + " has been Closed",
                text: "Reason: " + reason,
                type: "info",
                showCancelButton: false,
                confirmButtonClass: "btn-success",
                cancelButtonText: 'Close',
                confirmButtonText: "Proceed to Dashboard",
                reverseButtons: true
            }).then(
                function () {
                    location.href = "InternalDashBoard.aspx";
                },
                function () { }
            )
        },
        function () {
            swal('', "Sorry, your request could not be fulfilled at this time. Please contact support@orgsoln.com", 'error');
        }
    );            
};