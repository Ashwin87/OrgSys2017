
function returnErrorHTML() {
var registerErrorHTML =
            '<div class="row margin_bottom">' +
            '<div class="col-sm-14" style="margin-top:3px;">' +
            '<div class="col-sm-14" style="margin-top:3px;">' +
            '<label id="titleissue" style="font-size:14px">You are not registered in our system with these credentials</label>' +
            '</br>' +
            '<label id="contentissue" style="font-size:12px">Either there is incorrect information, missing information, or you have not been added yet. </label>' +
            '</br>' +
            '</br>' +
            '<label id="contentissue2" style="font-size:12px">Please try again or contact info@orgsoln.com</label>' +
            '</div>' +
            '</div>' +
            '</div>';

    return registerErrorHTML;
  
}

function returnVerificationEmailHTML(code) {
    var verificationHTML =
        "Thank you for registering with OSI's MyCRS Portal." +
        "Your Verification Code is " + code + " Please do not reply to this email.";
    return verificationHTML;
}

function returnEmailData(code, email, html) {
   var emailData = {
        ClientID: 0, //for now, but hook up client id when searched in demo later
        ClaimID: 0,
        To: 'mgougeon@orgsoln.com',
        From: 'noreply@orgsoln.com',
        Subject: 'Verification Code - OSI Portal Setup',
        Body: html,
    }

    return emailData

}

function getGeneratedCode() {
    var code = (Math.random() * new Date().getTime()).toString(36).replace(/\./g, '').toUpperCase().substring(0, 6);
    return code;
}

function SendEmaiData(postedEmail) {

    $.ajax({
        url: getApi +"/api/Email",
        type: "POST",
        async: false,
        data: '=' + JSON.stringify({ emailData: postedEmail })
    });
}

function registerVerificationCode(code, email) {
    var date = GetCurrentDate();
    var RegistrationCode = {
        RegistrationCode: code,
        RegistrationEmail: email,
        DateRegistered: date,
        CheckCount: 0
    };
    var validationArray = { obj_Con_valid: RegistrationCode };
    $.ajax({
        url: getApi +"/api/Validate/AddRegistrationCode/",
        type: "POST",
        async: false,
        data: { codeData: validationArray },
        success: function (data) {
            if (data.length > 0) {
                swal("Success", "A Registration Code has been send to " + email, "info");
            } else {
                swal("Error Occured", "We have encountered an error. Please contact info@orgsoln.com", "info");
            }
        }
    });
};

function checkVerificationCode(vcode) {
    $.getJSON(getApi +"/api/Validate/CheckRegistrationCode/" + vcode, function (data) {
        results = JSON.parse(data);
        if (results.length > 0) {
            $('#btnSecurityQuestionglyph').addClass('glyphicon-ok').removeClass('glyphicon-arrow-right');
            $('#btnSecurityQuestion').addClass('btn-success').removeClass('btn-primary');
            $('#c').addClass('active');
            $('#b').removeClass('active');
            $('#a').removeClass('active');
            $('#topInfo').val('Create a User Account');


        } else {
            swal("Invalid Verification Code", "The code you have supplied is not valid. Please try again or contact info@orgsoln.com", "info");
        }
    });
};
