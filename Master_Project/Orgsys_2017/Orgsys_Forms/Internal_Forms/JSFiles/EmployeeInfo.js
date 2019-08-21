
function LoadSchedule() {
    InitializeDT('#tblSchedule', ScheduleDTC);

    GetDataGeneric('Claim', 'GetSchedule', ClaimID).then(function (schedule) {
        if (schedule.length > 0) {
            $('#Type_Schedule').val(schedule[0]["ScheduleType"] || '');
            SetDataDT('#tblSchedule', ReplaceDFValues(schedule));
        }
    });
}

//It creates Schedule
function CreateSchedule() {
    var table = $('#tblSchedule').DataTable();
    
    swal({
        title: "Add Schedule",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Add Schedule',
        html: scheduleTemplate,
        customClass: 'swal-wide',
        width: '850px',
        preConfirm: validate.validateSwalContentPM
    }).then(function (isConfirm) {
        if (results) {            
            var schedule = GetScheduleSwalObject();

            table.row.add(schedule).draw();
            swal("", "Schedule has been added", "success");
        }
    }, function (dismiss) {
        swal("Cancelled", "Not Added", "error");
    });

}

$(document).on('click', '.editSchedule', function () {
    var table = $('#tblSchedule').DataTable();
    var index = table.row($(this).closest('tr')).index();
    var data = table.row(index).data();

    swal({
        title: "Edit Schedule",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Update Schedule',
        html: scheduleTemplate,
        width: '850px',
        onOpen: function () {
            SetScheduleSwalObject(data);
        },
        preConfirm: validate.validateSwalContentPM
    }).then(function (isConfirm) {
        if (results) {
            var schedule = GetScheduleSwalObject();

            table.row(index).data(schedule).draw();
            swal("", "Schedule has been updated!", "success");
        }
    }, function (dismiss) {
        swal("Cancelled", "Not updated.", "error");
    });

});

$(document).on('click', '.deleteSchedule', function () {
    DeleteRecordSwalDT('#tblSchedule', 'Schedule Week', $(this));
});

function GetScheduleSwalObject() {

    return {
        DaysOn: $('#DaysOn').val(),
        DaysOff: $('#DaysOff').val(),
        ScheduledDayOff: $('#ScheduledDayOff').val(),
        TotalHours: $('#Hours_Total').val(),
        WeekNo: $('#WeekNo').val(),
        Sunday: $('#Sunday').val(),
        Monday: $('#Monday').val(),
        Tuesday: $('#Tuesday').val(),
        Wednesday: $('#Wednesday').val(),
        Thursday: $('#Thursday').val(),
        Friday: $('#Friday').val(),
        Saturday: $('#Saturday').val()
    }

}

function SetScheduleSwalObject(schedule) {

    $('#DaysOn').val(schedule.DaysOff);
    $('#DaysOff').val(schedule.DaysOff);
    $('#ScheduledDayOff').val(schedule.ScheduledDayOff);
    $('#Hours_Total').val(schedule.TotalHours);
    $('#WeekNo').val(schedule.WeekNo);
    $('#Sunday').val(schedule.Sunday);
    $('#Monday').val(schedule.Monday);
    $('#Tuesday').val(schedule.Tuesday);
    $('#Wednesday').val(schedule.Wednesday);
    $('#Thursday').val(schedule.Thursday);
    $('#Friday').val(schedule.Friday);
    $('#Saturday').val(schedule.Saturday);

}

var ScheduleDTC = {
    select: true,
    "columns": [
        {
            data: null,
            render: function () {
                return `
                <a class="btn btn-default editSchedule edit_button" title="Edit Schedule" data-toggle="tooltip"><i class="icon icon-pencil"></i></a>
                <a class="btn btn-default deleteSchedule btn-danger" title="Delete Schedule" data-toggle="tooltip"><i class="icon icon-bin"></i></a>`;
            }
        },
        { "data": "DaysOn" },
        { "data": "DaysOff" },
        { "data": "ScheduledDayOff" },
        { "data": "TotalHours" },
        { "data": "WeekNo" },
        { "data": "Sunday" },
        { "data": "Monday" },
        { "data": "Tuesday" },
        { "data": "Wednesday" },
        { "data": "Thursday" },
        { "data": "Friday" },
        { "data": "Saturday" }
    ]
}

var JobDescDocsDTC = {
    select: true,
    "columns": [
        {
            data: null,
            render: function () {
                return `
                <a class="btn btn-default deleteSchedule btn-danger" title="Delete Schedule" data-toggle="tooltip"><i class="icon icon-bin"></i></a>`;
            }
        },
        { "data": "DocName" },
        { "data": "TimeStamp" }
    ]
};

var scheduleTemplate = `
                    <div class ="row margin_bottom dialogbox_container">
                       <div class="col-sm-2 dialogbox_form margin-bottom">
                            <label for="DaysOn" class="dialogbox_form_label">Work Days On:</label>
                            <input type="text" class="form-control vld-number dialogbox_form_input" name="daysOn"  id="DaysOn" />
                        </div>
                        <div class="col-sm-2 dialogbox_form margin-bottom">
                            <label for="DaysOff" class="dialogbox_form_label">Work Days Off:</label>
                            <input type="text" class="form-control vld-number dialogbox_form_input" name="daysOff" id="DaysOff" />
                        </div>
                         <div class ="col-sm-3 dialogbox_form margin-bottom">
                            <label for="scheduledDayOff" class="dialogbox_form_label">Work Scheduled Day Off:</label>
                            <input type="text" class ="form-control dialogbox_form_input" name="ScheduledDayOff" id="ScheduledDayOff" />
                        </div>
                        <div class ="col-sm-3 dialogbox_form margin-bottom">
                            <label class="dialogbox_form_label">Work Hours Per Shift:</label>
                            <input type="text" class ="form-control dialogbox_form_input" name="hours_Total" id="Hours_Total" />
                        </div>
                        <div class ="col-sm-3 dialogbox_form margin-bottom">
                            <label class="dialogbox_form_label">Work Weeks In Cycle: </label>
                            <input type="text" class ="form-control dialogbox_form_input" name="weekNo" id="WeekNo" />
                        </div>
                  </div>
                  <div class ="row margin_bottom dialogbox_container">
                        <div class="dialogbox_form weekday_form">
                            <label for="Sunday" class="dialogbox_form_label">Sunday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="sunday" id="Sunday"  />
                        </div>
                        <div class ="dialogbox_form weekday_form">
                            <label for="Monday" class="dialogbox_form_label">Monday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="monday" id="Monday" />
                        </div>
                        <div class ="dialogbox_form weekday_form">
                            <label for="Tuesday" class="dialogbox_form_label">Tuesday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="tuesday" id="Tuesday" />
                        </div>
                        <div class ="dialogbox_form weekday_form">
                            <label for="Wednesday" class="dialogbox_form_label">Wednesday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="wednesday" id="Wednesday"  />
                        </div>
                        <div class ="dialogbox_form weekday_form">
                            <label for="Thursday" class="dialogbox_form_label">Thursday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="thursday" id="Thursday"  />
                        </div>
                        <div class ="dialogbox_form weekday_form">
                            <label for="Friday" class="dialogbox_form_label">Friday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="friday" id="Friday" />
                        </div>
                        <div class ="dialogbox_form weekday_form">
                            <label for="Saturday" class="dialogbox_form_label">Saturday</label>
                            <input type="text" class="form-control vld-decimal dialogbox_form_input" name="saturday" id="Saturday" />
                        </div>
                  </div>`