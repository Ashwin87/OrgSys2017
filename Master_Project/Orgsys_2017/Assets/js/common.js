$.fn.ignore = function (sel) {
    return this.clone().find(sel || ">*").remove().end();
};


// common functions
function notSuccessMessage(message) {
    toastr.error(message, 'Error!');
}
function warningMessage(message) {
    toastr.warning(message, 'Warning!');
}

// initialize 
function initializeCkEditor(id) {
    CKEDITOR.replace(id, {
        allowedContent: true,
        height: '500px',
        width: '100%',
        filebrowserUploadUrl: '/editor/uploadEmailTemplateImages/',
        forcePasteAsPlainText: true,
        toolbar: [
            { name: 'document', items: ['Source'] },
            { name: 'clipboard', items: ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo'] },
            { name: 'insert', items: ['Image', 'Table', 'HorizontalRule', 'SpecialChar', 'PageBreak', 'Iframe'] },
            { name: 'links', items: ['Link', 'Unlink'] },
            { name: 'editing', groups: ['find', 'selection', 'spellchecker'], items: ['Find', 'Replace', '-', 'SelectAll', '-', 'Scayt'] },
            '/',
            { name: 'basicstyles', items: ['Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat'] },
            { name: 'paragraph', items: ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'] },
            { name: 'styles', items: ['Styles', 'Format', 'Font', 'FontSize'] },
            { name: 'colors', items: ['TextColor', 'BGColor'] },
            { name: 'tools', items: ['Maximize', 'ShowBlocks'] },
        ]
    });
    for (instance in CKEDITOR.instances) {
        CKEDITOR.instances[instance].updateElement();
    }
}

//initialise datepicker
$.datepicker.regional['fr'] = {
    clearText: 'Effacer', clearStatus: '',
    closeText: 'Fermer', closeStatus: 'Fermer sans modifier',
    prevText: '&lt;Préc', prevStatus: 'Voir le mois précédent',
    nextText: 'Suiv&gt;', nextStatus: 'Voir le mois suivant',
    currentText: 'Courant', currentStatus: 'Voir le mois courant',
    monthNames: ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
        'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'],
    monthNamesShort: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
        'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
    monthStatus: 'Voir un autre mois', yearStatus: 'Voir un autre année',
    weekHeader: 'Sm', weekStatus: '',
    dayNames: ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'],
    dayNamesShort: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
    dayNamesMin: ['Di', 'Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa'],
    dayStatus: 'Utiliser DD comme premier jour de la semaine', dateStatus: 'Choisir le DD, MM d',
    dateFormat: 'dd/mm/yy', firstDay: 0,
    initStatus: 'Choisir la date', isRTL: false
};
if (getCookie("Language") === "fr-ca") {
    $.datepicker.setDefaults($.datepicker.regional['fr']);
}





function datePicker() {
    $(".datepicker").datepicker({ dateformat: 'dd-mm-yyyy' });
}

// update all text boxes 
function updateTextBoxes() {
    for (instance in CKEDITOR.instances) {
        CKEDITOR.instances[instance].updateElement();
    }
}
/***************************************Ajax Loading Bar Starts***************************************/
$.fn.center = function () {
    this.css("position", "absolute");
    this.css("top", ($(window).height() - this.height()) / 2 + $(window).scrollTop() + "px");
    this.css("left", ($(window).width() - this.width()) / 2 + $(window).scrollLeft() + "px");
    return this;
};
function showLoader() {
    $.blockUI({
        centerX: true,
        centerY: true,
        css: { width: "140px", height: "140px" },
        message: "<img src='../Assets/img/loading.gif'/>"
    });
    //$('.blockUI.blockMsg').center();
    $('.blockUI.blockMsg').css({
        "border": "0",
        "background-color": "transparent"

    });
}
function hideLoader() {
    $.unblockUI();
}
/***************************************Ajax Loading Bar Ends***************************************/
function addListenerMulti(element, eventNames, listener) {
    var events = eventNames.split(' ');
    for (var i = 0, iLen = events.length; i < iLen; i++) {
        element.addEventListener(events[i], listener, false);
    }
}
function PostData(url, _successHandler, data, showBlackImage, spinWheelButtonId) {
    var isSpinWheelButtonExist = false;
    if (showBlackImage == null) {
        showBlackImage = true;
    }
    if (spinWheelButtonId != null && spinWheelButtonId != undefined && spinWheelButtonId != "") {
        isSpinWheelButtonExist = true;
        startLaddaSpinWheel(spinWheelButtonId);
    }
    $.ajax({
        type: "POST",
        url: url,
        data: data,
        success: function successHandler(result) {
            if (isSpinWheelButtonExist) {
                stopLaddaSpinWheel(spinWheelButtonId);
            }
            _successHandler(result, data);
        },
        global: showBlackImage
    });
}