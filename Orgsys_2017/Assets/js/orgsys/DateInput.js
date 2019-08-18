
if ($.fn.datepicker.noConflict && !$.fn.datepickerBS) {
    $.fn.datepickerBS = $.fn.datepicker.noConflict();
}

var customDateFormat = 'dd-M-yy';
var datepickerJQOptions = {
    dateFormat: customDateFormat,
    changeYear : true,
    changeMonth: true,
    yearRange: '1900:' + new Date().getUTCFullYear()
}
var customMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/*
 * Created By       : Andriy Bovtenko
 * Description      : Initializes datepickers on all inputs of type:date with dd/M/yyyy display format
 */
function InitializeDatepicker(selector) {

    //convert all dates by default, can also target specific fields
    var selector = (selector === undefined) ? 'input[type="date"]' : selector;

    $(selector)
        .attr('type', 'text')
        .prop('readonly', true)
        .datepicker(datepickerJQOptions)
        .addClass('date')
        .data('iso-date', '');

}

//add a data attrubute to store the iso format of the date for storage in db
$(document).on('change', '.date', function () {

    var val = $(this).val();

    if (val != '') {
        var isoDate = ConvertDateCustomToIso(val);
        $(this).data('iso-date', isoDate);
    }

});

/*
 * Created By       : Andriy Bovtenko   
 * Description      : Checks if the string value is in iso date format
 */
function isIsoDateFormat(value) {

    return /[0-9]{4}-[0-9]{2}-[0-9]{2}/.test(value);

}

/*
 * Created By       : Andriy Bovtenko   
 * Description      : Sets the datepicker value of the target element so that it is displayed in the custom format
 */
function SetIsoDateFormat(target, value, dateTimeBool) {
    
    if (target.length != 0) {
        console.log('seting date ' + value);
        target.datepicker('setDate', ConvertDateIsoToCustom(value));
        console.log('date set to : ' + target.val())
        //required to set data:iso-date property; event does not fire on its own when setting date with api
        target.trigger('change');
    }

}

/*
 * Description      : Converts supported date string to iso date, without time
 */
function ConvertDateCustomToIso(dateString) {
    //custom format is dd-M-yyyy or 01-Jan-2000
    
    var day = dateString.slice(0, 2);
    var year = dateString.slice(7);
    var month = customMonths.indexOf(dateString.slice(3, 6)) + 1;
    if (month < 10) month = '0' + month;

    var isoDate = year + '-' + month + '-' + day;


    return isoDate;

}

/*
 * Description      : Converts iso date format string into custom format
 */
function ConvertDateIsoToCustom(dateString) {

    if (!isIsoDateFormat(dateString)) {
        return '';
    }

    var day = dateString.substring(8,10);
    var month = customMonths[parseInt(dateString.slice(5, 7)) - 1];
    var year = dateString.slice(0, 4);

    console.log('day : ' + day + '; month : ' + month + '; year : ' + year);

    var customDate = day + '-' + month + '-' + year;
    

    return customDate;

}

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
