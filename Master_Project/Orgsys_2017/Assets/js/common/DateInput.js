
var customDateFormat = 'dd-M-yy';
var datepickerJQOptions = {
    dateFormat: customDateFormat,
    changeYear: true,
    changeMonth: true,
    showButtonPanel: true,
    yearRange: '1910:' + (new Date().getUTCFullYear() + 1),
    todayBtn: "linked",
    autoclose: true
};
var customMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

//check if multilingual functions exist before setting language data
if (typeof getCookie === "function" && getCookie("Language") === "fr-ca") {
    customMonths = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
}

function AddClearDateButton(dateField) {
    var target = $(dateField);
    var dpHeader = $('.ui-datepicker-buttonpane');
    var clearDate = function () {
        $.datepicker._clearDate(target);
        target.data('iso-date', '');
    };

    //capture backspace and delete key events
    target.keyup(function (e) {
        if (e.keyCode === 8 || e.keyCode === 46) {
            clearDate();
        }
    });

    if (dpHeader.find('button.clear-date').length === 0) {
        var clearButton = $('<button class="clear-date btn btn-default">Clear Date</button>').on('click', clearDate);
        dpHeader.append(clearButton);
    }
}

/**
 * Initialize datepickers on all inputs of type:date with dd/M/yyyy display format
 * @param {any} selector
 */
function InitializeDatepicker(selector) {

    //convert all dates by default, can also target specific fields
    var SELECTOR = selector || 'input[type="date"]';

    $(SELECTOR).each(function (index, element) {//Wraps the datefield element with a bootstrap input-group div to make it look like a datefield
        if ($(element).parent("div[class='input-group']").length == 0) {
            $(element)
                .wrap("<div class='input-group'></div>")//following two lines makes it look like a date field
                .after();
        }
    });

    $(SELECTOR)
        .attr('type', 'text')
        .attr('placeholder', 'Click to select a date...')
        .prop('readonly', true)
        .datepicker(datepickerJQOptions)
        .addClass('date')
        .data('iso-date', '')
        .on('focus', function () {
            AddClearDateButton(this);
        });
}

/**
 * Initialize datepickers that are part of a sweet alert modal
 */
function InitializeSwalDatepicker() {
    //separate initialization needed because dp position relative to control was inconsistent (usually far below; np if scrollbar was at top) //abovtenko

    $('#swal2-content')
        .find('input[type="date"]')
        .attr('type', 'text')
        .prop('readonly', true)
        .datepicker(datepickerJQOptions)
        .addClass('date')
        .data('iso-date', '')
        .each(function () {
            //attach handler to consistently position dp below input as expected
            $(this).on('focus', function () {

                //get element position
                var position = this.getBoundingClientRect();
                //other styling needs to be included; 34 is control height
                var dpStyle =
                    'position : fixed; ' +
                    'top : ' + (position.top + 34) + 'px; ' +
                    'left : ' + position.left + 'px; ' +
                    'z-index : 1061; ' +
                    'display : block; ';

                $('#ui-datepicker-div').attr('style', dpStyle);
                AddClearDateButton(this);

            });

        });
    
}

//add a data attrubute to store the iso format of the date for storage in db
$(document).on('change', '.date', function () {
    var val = $(this).val();

    if (val != '') {
        var isoDate = ConvertDateCustomToIso(val);
        $(this).data('iso-date', isoDate);
    }
});    


/**
 * Checks if the string value is in iso date format
 * @param {any} value
 */
function isIsoDateFormat(value) {
    return /[0-9]{4}-[0-9]{2}-[0-9]{2}/.test(value);
}

/**
 * Sets the datepicker value of the target element so that it is displayed in the custom format
 * @param {any} target
 * @param {any} value
 */
function SetIsoDateFormat(target, value) {
    var target = $(target);

    if (target.length != 0) {
        target.datepicker('setDate', ConvertDateIsoToCustom(value));
        target.trigger('change'); //event does not fire on its own when setting date with api
    }
}

/**
 * Converts custome date string to iso formate date string
 * @param {any} dateString
 */
function ConvertDateCustomToIso(dateString) {
    //custom format is dd-M-yyyy like 01-Jan-2000
    if (!/[0-9]{2}-[A-Za-z]{3}-[0-9]{4}/.test(dateString)) {
        return '';
    }

    var day = dateString.slice(0, 2);
    var year = dateString.slice(7);
    var month = customMonths.indexOf(dateString.slice(3, 6)) + 1;
    if (month < 10) month = '0' + month;

    var isoDate = year + '-' + month + '-' + day;

    return isoDate;
}

/**
 * Converts iso date format string into custom format
 * @param {any} dateString
 */
function ConvertDateIsoToCustom(dateString) {
    if (!isIsoDateFormat(dateString)) {
        return '';
    }

    var day = dateString.substring(8,10);
    var month = customMonths[parseInt(dateString.slice(5, 7)) - 1];
    var year = dateString.slice(0, 4);
    
    var customDate = day + '-' + month + '-' + year;    

    return customDate;
}
function ConvertDateTimeIsoToCustom(dateTimeString) {
    if (!isIsoDateFormat(dateTimeString)) {
        return '';
    }

    var day = dateTimeString.substring(8, 10);
    var month = customMonths[parseInt(dateTimeString.slice(5, 7)) - 1];
    var year = dateTimeString.slice(0, 4);
    var Time = dateTimeString.slice(11, 16);

    var customDate = day + '-' + month + '-' + year + '  ' + tConv24(Time);

    return customDate;
}

function tConv24(time24) {
    var ts = time24;
    var H = +ts.substr(0, 2);
    var h = (H % 12) || 12;
    h = (h < 10) ? ("0" + h) : h;  // leading 0 at the left for 1 digit hours
    var ampm = H < 12 ? " AM" : " PM";
    ts = h + ts.substr(2, 3) + ampm;
    return ts;
};

/**
 * Converts all level 1 properties that are in iso date format to custom.
 * Returns the object with any conversions.
 * 
 * @param {any} object
 */
function ConvertObjectIsoDatesToCustom(object) {
    var rObject = object;
    var keys = Object.keys(rObject);

    keys.forEach(function (key) {
        if (isIsoDateFormat(rObject[key]))
            rObject[key] = ConvertDateIsoToCustom(rObject[key]);
    });

    return rObject;
}

//for mysql dates to json converting them to regular date format //mgougeon
// * @param mysql formatting /DATE numsequence/ changing to mm/dd/yyyy
function ToJavaScriptDate(dateValue) {
    var pattern = /Date\(([^)]+)\)/;
    var results = pattern.exec(dateValue);
    var dt = new Date(parseFloat(results[1]));
    return ('0' + dt.getDate()).slice(-2) + '-' + customMonths[parseInt(dt.getMonth())] + '-' + dt.getFullYear();
}

//return the current date in dd/mm/yyyy

function GetCurrentDate() {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1; //January is 0!
    var yyyy = today.getFullYear();
    var today = yyyy + '-' + mm + '-' + dd;
    return today;
}

//converts a date to a user friendly one
function ConvertToReadableDate(date) {
    var formattedDate = $.datepicker.formatDate(customDateFormat, new Date(date));
    return formattedDate;
}