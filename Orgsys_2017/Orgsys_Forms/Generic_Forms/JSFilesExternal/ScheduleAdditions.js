


var weekCounter = 1;
/*
 * Created By:    Andriy Bovtenko
 * Description:   Clones the first row of the schedule table, alters attribute values and appends the modified clone after last row
 */

function AddScheduleRow(scheduleControls, caller) {
    //using weekcounter to set id, name attributes and the control's Row property
    //this is to maintain unique values beyond removal and re-addition of rows and will produce values beyond the number of actual rows //abovtenko
    weekCounter++;

    var tBody = $('#' + scheduleControls[0].ID).closest('tbody');
    var firstRow = tBody.find('tr:first'); //used as a model
    var lastRow = tBody.find('tr:last');
   
    var rowClone = firstRow.clone();
    var newScheduleControls = [];
    
    rowClone.attr('id').replace(/\d$/, weekCounter);
    rowClone.find('td > input, td > div > input')
        .each(function () {

            var id = this.id;
            var oldObject = scheduleControls.filter(function (control) {
                return control.ID == id;
            });
            
            var newID = $(this).attr('id') + '-' + weekCounter;
            var newName = $(this).attr('name').replace(/\d$/, weekCounter);

            $(this).attr('id', newID);
            $(this).attr('name', newName);
            $(this).val('');

            if ($(this).hasClass('date')) {
                //will not init without removing class :hasDatepicker
                InitializeDatepicker($(this).removeClass('hasDatepicker'));
            }

            var controlObject = $.extend({}, oldObject[0]);
            controlObject.ID = $(this).attr('id');
            controlObject.ControlName = $(this).attr('name');
            controlObject.Row = weekCounter;
            controlObject.Value = '';

            newScheduleControls.push(controlObject);
        });
    rowClone.append($('<td class="remove_button_container"><button class="btn btn-default remove-week">X</button></td>'));

    //$('.earning_details_table tbody tr:nth-child(1)').append($('<td></td>'));
    //$('.earning_details_table thead tr:last').append($('<th></th>'));
    //this check is neccessary for schedule population, since first week values will still be empty
    if ($('[name^=WeekStart]:last').data('iso-date') != '') {
        var nextStart = new moment($('[name^=WeekStart]:last').data('iso-date'), 'YYYY-MM-DD').subtract(7, 'd');
        var nextEnd = new moment(nextStart).add(6, 'd');
        var weekStart = rowClone.find('[name^=WeekStart]');
        var weekEnd = rowClone.find('[name^=WeekEnd]');

        SetIsoDateFormat(weekStart, nextStart._i);
        SetIsoDateFormat(weekEnd, nextEnd._i);
    }

    rowClone.insertAfter(lastRow);
    rowClone.find('.date').trigger('change');
    UpdateTableRowNumbers(tBody);

    if (tBody.find('tr').length == 4)
        caller.attr('disabled', 'disabled');

    return newScheduleControls;

};

function RemoveScheduleRow(caller) {
    $('.AddWeek').removeAttr('disabled');
    $('.AddWeek').removeAttr('disabled');
    UpdateTableRowNumbers(caller.closest('tbody'));
    caller.closest('tr').remove();
};

//Update row numbers after add/remove of rows
function UpdateTableRowNumbers($tBody) {
    var n = 1;
    var rows = $tBody.children('tr');
    $.each(rows, function () {
        var newID = $(this).attr('id').replace(/\d$/, n);
        $(this).attr('id', newID);
        $(this).find('td:first').text(n);
        n++;
    });

}

function GetWeekStart(IncidentDate, numberOfDaysToSub) {

    var date = new Date(IncidentDate);
    if (numberOfDaysToSub == 0) {
        var day = date.getDay();
        switch (day) {
            case 0:
                numberOfDaysToSub = 7;
                break;
            case 1:
                numberOfDaysToSub = 8;
                break;
            case 2:
                numberOfDaysToSub = 9;
                break;
            case 3:
                numberOfDaysToSub = 10;
                break;
            case 4:
                numberOfDaysToSub = 11;
                break;
            case 5:
                numberOfDaysToSub = 12;
                break;
            case 6:
                numberOfDaysToSub = 13;
        }
    }

    date.setDate(date.getDate() - parseInt(numberOfDaysToSub));
    return date;

}


$(document).on('change', '.day-hours', function () {

    var row = $(this).closest('tr');
    var totalHours = 0;
    var daysOn = 0
    var daysOff;    

    row.find('.day-hours').each(function () {
        var val = $(this).val();
        var hours = (val != '') ? parseInt(val) : 0;

        if (hours > 0) {
            daysOn += 1;
            totalHours += hours;
        }
    })

    daysOff = 7 - daysOn;
    var hoursPerShift = (daysOn != 0) ? (totalHours / daysOn).toFixed(1) : 0; 

    row.find('[name^=DaysOn]').val(daysOn);
    row.find('[name^=DaysOff]').val(daysOff);
    row.find('[name^=HrsperShift]').val(hoursPerShift);  

});