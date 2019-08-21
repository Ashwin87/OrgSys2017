

function SendEmail(getEmailTypeHTML, email) {
    var profile = { DistroEmailTo: '', DistroEmailFrom: '' };
    $.ajax({
        url: window.getApi + "/api/" + window.token + "/Users/profile",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (profile) {
            profile = JSON.parse(profile);
        }
    });

    var emailData = {
        ClaimID: email.ClaimID,
        To: email.To,
        From: 'noreply@orgsoln.com',//'noreply@orgsoln.com'
        Subject: 'Claim Notification', //'Claim Notification'
        Body: getEmailTypeHTML(email),
        AttachmentPaths: null
    };

    
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: window.getApi + "/api/Email/" + window.token,
        data: '=' + JSON.stringify({ emailData: emailData })
    });

}


////////////////////////////////////////////////////////////////////////////////////////////////////BELOW WILL BE EMAIL TEMPLATES ONLY //////////////////////////////////////////////////////////////////////////
function CLAIM_NOTIFICATION_HTML(email) {
    return `ORGANIZATIONAL SOLUTIONS INC.  <br/ ><br/ >

    New Claim Submission Notification <br/ ><br/ >

    A new claim has been submitted for the following employee: <br/ >
    Employee: ${email.EmployeeFirst} ${email.EmployeeLast} <br/ >
    Employee Number: ${email.EmployeeNumber} <br/ >
    First Day of Absence: ${email.FirstDayAbsence} <br/ ><br/ >

    Claim Submission Date: ${email.ClaimSubissionDate} <br/ ><br/ >

    To access this claim submission, please log into your My CRS Portal account, and click on 'Submitted Claims' https://portal.orgsoln.com/`; 
}

//Declare types of emails that could be sent along with a reference to a function that returns HTML
var EMAIL_TYPE_HTML = {
    CLAIM_DEFAULT_EXTERNAL_NOTIFICATION: CLAIM_NOTIFICATION_HTML
};


function CLAIM_NOTIFICATION_HTML_FRENCH(emailData) {
    return "SOLUTIONS ORGANISATIONNELLES INC.  " +
        "Nouvelle Réclamation Soumise" +
        "Une nouvelle demande a été soumise par l’employeur suivant(e) : " +
        "Employé(e): " +
        "Premier jour d'absence: " +
        "Date de la réclamation:  " +
        "Merci," +
        "Système de notification de OrgSoln" +
        "**SVP NE PAS RÉPONDRE À CE MESSAGE**" +
        "This e-mail and any attachments may be confidential or legally privileged.  If you received this message in error or are not the intended recipient, you should " +
        "destroy the e-mail message and any attachments or copies, and your are prohibited from retaining, disbributing, disclosing or using any information contained here in.  Please" +
        "inform us of the erroneous delivery by return e-mail.  Thank you for your cooperation" +
        "CONFIDENTIEL:  Ce courriel est confidentiel et protégé.  L’expéditeur ne renonce pas aux droits et obligations qui s’y rapportent.  Toute diffusion, utilisation ou copie de ce  message ou des renseignements qu’il contient par une personne autre que le (les) destinataire(s) désignés est interdite.  Si vous recevez ce courriel par erreur, veuillez m’en aviser immédiatement, par retour de courriel ou par un autre moyen";
}




