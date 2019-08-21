
//All the validations functions are created here 
//Validate Required Fields
function ValidateControls() {
    //Required Field Validation
    $('.required').each(function (key, value) {
        ValidateRequired($(this).val(), this);
    });
    //Numbers Validation
    $('.regexNumbers').each(function (key, value) {
        ValidateNumbers($(this).val(), this);
    });
    //Currency Validation
    $('.regexCurrency').each(function (key, value) {
        ValidateCurrency($(this).val(), this);
    });

    $('.email').each(function (key, value) {
        ValidateEmail($(this).val(), this);
    });

    $('.radio').each(function (key, value) {
        ValidateRadio($(this).val(), this, $(this).attr('name'));
    });
}
//All the validations functions are created here 
//Validate Required Fields
function ValidateRequired(fieldValue, fieldID) {
    if ($(fieldID).is(":visible") == true) {
        if (fieldValue !== '') {
            $(fieldID).removeClass('error');
        }
        else {
            var id = $(this).attr('id');
            $(fieldID).addClass('error');
            valid = false;
        }
    }
}


//All the validations functions are created here 
//Validate Required Fields
function ValidateRequiredNew(fieldValue, fieldID) {
    if ($(fieldID).is(":visible") == true) {
        console.log(fieldID);
        if (fieldValue !== '') {
            $(fieldID).removeClass('error');
            
        }
        else {
            var id = $(this).attr('id');
            $(fieldID).addClass('error');
            validUpdates= false;
        }
    }
}
function ValidateRadio(fieldValue, fieldID, fieldName) {
    var xpr = 'input[name=' + fieldName + ']:checked';
    if ($(xpr).val()) {
        $(fieldID).parent().parent().parent().removeClass('error');
    }
    else {
        $(fieldID).parent().parent().parent().addClass('error');
        valid = false;
    }
}

function ValidateEmail(fieldValue, fieldID) {
    var emailExp = new RegExp("^([a-zA-Z0-9\-\.]+)@([a-zA-Z0-9\-\.]+)\.([a-zA-Z]{1,10})$");
    if (emailExp.test(fieldValue)) {
        $(fieldID).removeClass('error');
    }
    else {
        $(fieldID).addClass('error');
        validEmail = false;
    }
}

function ValidateDates(fieldValue, fieldID) {
    var dateExp = new RegExp("[0-9]{4}[-][0-9]{2}[-][0-9]{2}"); //regular expression for dates
    if (dateExp.test(fieldValue)) {
        $(fieldID).removeClass("error");
    }
    else {
        $(fieldID).addClass("error");
        validDate = false;
    }
}
///^[0-9]{2}[\/]{1}[0-9]{2}[\/]{1}[0-9]{4}$/g
// Validate Currency
function ValidateCurrency(fieldValue, fieldID) {
    curExp = /[\d].[\d]{2}/; //regular expression for currency
    if (curExp.test(fieldValue)) {
        $(fieldID).removeClass("error");
    }
    else {
        $(fieldID).addClass("error");
        valid = false;
    }
}
//Validate Numbers
function ValidateNumbers(fieldValue, fieldID) {
    regExp = /[0-9]+$/;
    if (regExp.test(fieldValue)) {
        if ($(fieldID).hasClass("error"))
            $(fieldID).removeClass("error");
    }
    else {
        $(fieldID).addClass("error");
        valid = false;
    }
}

