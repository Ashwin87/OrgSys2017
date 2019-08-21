/*Created By   : Marie Gougeon
Created Date   : 2018-05-10
Updated Date   : 2018-06-07
Description    : TaskManager Javascript File*/

//Global Variables
var activeTable;
var currentTable;
function completeTask(taskID, comment) {
    var task = {
        TaskID: taskID,
        UserComments: comment
    }
    return $.ajax({
        url: getApi + "/api/Roles/Update_CompleteTask",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        data: task
    });
}
function disableTask(taskID, comment) {
    var task = {
        TaskID: taskID,
        UserComments: comment
    }
    return $.ajax({
        url: getApi + "/api/Task/UpdateDisableTask",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        data: task
    })
    .then(function () {
        return updateTask(taskID, comment);
    })
}
function updateTask(taskId, UserTaskComments) {
    var task = {
        TaskID: taskId,
        UserComments: UserTaskComments
    }
    return $.ajax({
        url: getApi + "/api/Task/UpdateAddCommentsTask/" + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        data: task
    });
}
function postponeTask(taskID, newDate, comment) {
    var task = {
        TaskID: taskID,
        DueDate: newDate,
        UserComments: comment
    }
    return $.ajax({
        url: getApi + "/api/Task/UpdatePostponeTask",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        data: task
    })
    .then(function () {
        return updateTask(taskID, comment);
    })
}
function changeAssignedUser(taskID, newUserId, comment) {
    var task = {
        TaskID: taskID,
        UserAssigned: newUserId
    }
    return $.ajax({
        url: getApi + "/api/Task/UpdateChangeUserTasks",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        data: task
    })
    .then(function () {
        return updateTask(taskID, comment);
    })
}
function GetUserTasks() {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Roles/GetUserTasks/" + token
    }).then(function (data) {
        return JSON.parse(data);
    });
}
function GetClaimTasks() {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Task/GetAssignedTasksByClaim/" + ClaimID
    }).then(function (data) {
        return JSON.parse(data);
    });
}
function loadCompletedTasks() {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Roles/GetCompletedTasks/" + token
    }).then(function (data) {
        return JSON.parse(data);
    });
}
function PostTask(taskData) {
    return $.ajax({
        url: getApi + "/api/Task/AddTask/" + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: "POST",
        data: taskData
    })
}
function PostClaimTask(taskData) {
    return $.ajax({
        url: getApi + "/api/Task/Add_ClaimTask/" + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: "POST",
        data: taskData
    })
}
    //Hover-over ToolTips for buttons and tables
    $('[data-toggle="tooltip"]').tooltip();
    //Autocomplete dropdown on top of modal - CSS
    $('.ui-autocomplete-input').css("z-index", 2147483647);
    $('.swal2-overflow').css("overflow-x", "visible");
    $('.swal2-overflow').css("overflow-y", "visible"); 
    //Check which table you are one
    $('.tabCheck').on("click", "li", function (event) {
        var activeTab = $(this).find('a').attr('href');
        activeTable = $('' + activeTab + '').find('table').attr('id');
        currentTable = $('#' + activeTable + '').DataTable();
    });
function PostponeTaskSwal(task) {
    return swal({
        title: 'Do you want to Postpone this Task to a later date?',
        text: "Note: The due date will change and a notification will be sent to the person assigned to this task.",
        type: 'warning',
        html: `
        <div class="margin-bottom">
            <label for="postponeDatepicker">Choose a date: </label>
            <input id="postponeDatepicker" class="date required form-control" type="date" />
        </div>
        <div>
            <input type="textarea" id="postponeComment" class="form-control required" placeholder="Why is this task being postponed?"/>
        </div>`,
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Postpone Task',
        weekends: false,
        beforeShowDay: $.datepicker.noWeekends,
        onOpen: function () {
            InitializeSwalDatepicker();
        },
        preConfirm: validate.validateSwalContentPM
    }).then(function () {
        var newDueDate = $('#postponeDatepicker').data('iso-date')
        var comment = $('#postponeComment').val()
        return postponeTask(task.TaskID, newDueDate, comment).then(
            function () {
                swal('Due Date Changed', 'Your Task has been postponed to a later date. New Date: ' + newDueDate, 'success');
                return true;
            },
            function () {
                swal('', 'Your request could not be completed at this time. Please contact support@orgsoln.com', 'error');
                return false;
            }
        );
    });
}
function AddTaskCommentSwal(task) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Task/GetTaskComments/" + task.TaskID
    }).then(
        function (data) {
            var comments = JSON.parse(data);
            var target = $('#taskComments');
            for (var i = 0; i < comments.length; i++)
                target.append('<div class="taskComment"><div class="task_comment_dilog_date">' + (comments[i].commentdate) + '</div><div class="task_comment_text">' + comments[i].taskcomment + '</div></div>');
        },
        function () { }
    );
    swal({
        title: "Add a Comment",
        html: '<div id="taskComments"></div><div class="taskComment_note">Note: You can view all comments that are assigned to you, tasks that you created, or tasks that you completed.</div>',
        input: 'textarea',
        customClass: 'swal-wide',
        showCancelButton: true,
        confirmButtonClass: 'btn btn-success swal2-confirm swal2-styled',
        cancelButtonClass: 'btn btn-default swal2-styled',
        inputPlaceholder: "Add a comment...",
        onOpen: function () {
            comment('#taskComment');
            InitializeSwalDatepicker();
            TaskTypeBox('#TaskTypeID');
            TaskClassName('#TaskClassName');
        }
    }).then(function (UserTaskComments) {
        return updateTask(task.TaskID, UserTaskComments).then(
            function () {
                swal("Success", "Task " + task.TaskName + " Your comment has been added to this task", "success")
                return true;
            },
            function () {
                swal('', 'Your request could not be completed at this time. Please contact support@orgsoln.com', 'error');
                return false;
            }
        );
    });
}
function CompleteTaskSwal(task) {
    return swal({
        title: "Complete Task",
        html: "<h3>Please provide any final comments to this task.</h3></br> Note: This task will be closed once a final comment is entered. To view and edit all tasks please visit the Tasks page in your navigation bar.",
        input: 'textarea',
        customClass: 'swal-wide',
        showCancelButton: true,
        buttonsStyling: 'background-color: red;',
        confirmButtonClass: 'btn btn-primary swal2-confirm',
        cancelButtonClass: 'btn btn-primary swal2-styled',
        inputPlaceholder: "Final comment",
        preConfirm: function (value) {
            return new Promise(function (resolve, reject) {
                if (value != '') {
                    resolve();
                }
                else {
                    validate.toggleErrorAndTooltip(false, $('.swal2-textarea'), 'Required');
                    reject();
                }
            });
        }
    }).then(function (UserComments) {
        return completeTask(task.TaskID, UserComments).then(
            function () {
                swal("Confirmation", "This task has been completed!", "success")
                return true
            },
            function () {
                swal('', 'Your request could not be completed at this time. Please contact support@orgsoln.com', 'error');
                return false;
            }
        );
    });
}
function TaskDecriptionSwal(task) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Task/GetTaskDetails/" + task.TaskID
    }).then(
        function (data) {
            var result = JSON.parse(data);
            var description = "There is no description for this task.";
            if (result[0])
                if (result[0].TaskDesc)
                    description = result[0].TaskDesc;
            $('#taskDescription').append(description);
        },
        function () { }
    );
    swal({
        title: 'Task Description',
        html: '<div id="taskDescription"></div>',
        customClass: 'swal-wide'
    });
}
function DeleteTaskSwal(task) {
    return swal({
        title: 'Do you want to Delete this Task?',
        text: "Note: Task will be removed from all claims and other users.",
        type: 'warning',
        html: '<input type="textarea" id="comment" class="form-control required" placeholder="Why is this task being deleted?"/>',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Yes, delete it!',
        preConfirm: validate.validateSwalContentPM
    }).then(function () {
        var comment = $('#comment').val();
        return disableTask(task.TaskID, comment).then(
            function () {
                swal('Deleted!', 'Your Task has been deleted.', 'success');
                return true;
            },
            function () {
                swal('', 'Your request could not be completed at this time. Please contact support@orgsoln.com', 'error');
                return false;
            }
        );
    })
} 
function ReassignTaskSwal(task) {
    return swal({
        title: "Reassign Task",
        html: `
        <div>
            <div class="margin-bottom">
                <label class="margin-bottom" for="inputSearch">Assign this task to a new user</label>
                <select id="inputSearch" class="hasSelect2 required" style="width:250px;"></select>
            </div>
            <input type="textarea" id="comment" class="form-control required" placeholder="Why is this task being reassigned?"/>
        </div>`,
        showCancelButton: true,
        onOpen: function () {
            $('.hasSelect2').select2();
            AssignUserSearchBox('select#inputSearch');
        },
        preConfirm: validate.validateSwalContentPM
    }).then(function () {
        var userId = $('select#inputSearch').val();
        var comment = $('#comment').val();
        return changeAssignedUser(task.TaskID, userId, comment).then(
            function () {
                swal("Confirmation", "Task has been assigned.", "success");
                return true;
            },
            function () {
                swal('', "Sorry, your request could not be fulfilled at this time. Please contact support@orgsoln.com", 'error');
                return false;
            }
        );
    });
}
function ViewTaskCommentsSwal(task) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Task/GetTaskComments/" + task.TaskID
    }).then(
        function (data) {
            var comments = JSON.parse(data);
            var target = $('#taskComments');
            for (var i = 0; i < comments.length; i++)
                //target.append('<div class="taskComment"><div class="task_comment_dilog_date">' + ConvertDateIsoToCuShowNewTaskSwalstom(comments[i].commentdate) + '</div><div class="task_comment_text">' + comments[i].taskcomment + '</div></div>');
                target.append('<div class="taskComment"><div class="task_comment_dilog_date">' + comments[i].commentdate + '</div><div class="task_comment_text">' + comments[i].taskcomment + '</div></div>');
        },
        function () { }
    );
    swal({
        title: 'Task Comments',
        html: '<div id="taskComments"></div>'
    });
}
function ShowNewTaskSwal(postFunction) {
    return swal({
        title: "Task Creator",
        html: newTaskHTML,
        showCancelButton: true,
        width: '650px',
        confirmButtonClass: "btn-info",
        cancelButtonText: 'Close',
        confirmButtonText: 'Submit',
        onOpen: function () {
            AssignUserSearchBox('#taskAssignment');
            InitializeSwalDatepicker();
            TaskTypeBox('#TaskTypeID');
        },
        preConfirm: validate.validateSwalContentPM
    }).then(function () {
        var taskData = {
            TaskName: $('#taskName').val(),
            dueDate: $('#taskEndDate').val(),
            TaskDesc: $('#taskDescription').val(),
            UserAssigned: $("#taskAssignment").val(),
            TaskTypeID: $('#TaskTypeID').val(),
            TaskClassName: $('#TaskClassName').val(),
            ClaimID: $.url().param('ClaimID') || 0,
            ClaimReferenceNumber: window.ClaimRefNu || ''
        }
        $('#taskEndDate').datepicker(
            {
                inline: true,
                showOn: "both",
                firstDay: 1,
                changeFirstDay: true,
                dateFormat: "dd-mm-yy"
            }
        );
        var taskEndDate = document.getElementById('taskEndDate');
        var taskEndDateValue = new Date(taskEndDate.value);
        var date = taskEndDateValue.getDate();
        var month = taskEndDateValue.getMonth();
        var year = taskEndDateValue.getFullYear();
        if (taskEndDateValue != 'Invalid Date') {
            //var checkvaluedate = taskEndDateValue.getDate();
            var weekend = taskEndDateValue.getDay();
            if (weekend == 6) {
                var SaturDay = date + 2;
                var monthupdate = month + 1;
                var yearupdate = year; 
                if (SaturDay >= 30) {
                    if (SaturDay == 31) {
                        if (monthupdate == 1 || monthupdate == 3 || monthupdate == 5 || monthupdate == 7 || monthupdate == 8 || monthupdate == 10) {
                            SaturDay = date + 2;
                        }
                        else {
                            SaturDay = date - 29;
                            monthupdate = month + 2;
                        }
                    }
                    if (SaturDay == 32 || SaturDay == 33) {
                        SaturDay = date - 29;
                        monthupdate = month + 2;
                    }
                    else {
                        if (monthupdate == 1 || monthupdate == 3 || monthupdate == 5 || monthupdate == 7 || monthupdate == 8 || monthupdate == 10) {
                            DEBUG("It's that time of the month!!");
                            SaturDay = date - 29;
                            monthupdate = month + 2;
                        }
                        if (monthupdate == 12) {
                            if (SaturDay == 30 || SaturDay == 31) {
                                SaturDay = date + 2;
                            }
                            if (SaturDay == 32) {
                                SaturDay = date - 31;
                                monthupdate = month - 11;
                                yearupdate = year + 1;
                            }
                        }
                        else {
                            SaturDay = date - 29;
                            monthupdate = month + 2;
                        }
                    }
                }
                var updatedDate = monthupdate + '-' + SaturDay +'-' + yearupdate;
                taskData.dueDate = updatedDate;
            }
            if (weekend == 0) {
                var SunDay = date + 1;
                var monthupdate = month + 1;
                var yearupdate = year;
                if (SunDay >= 30) {
                    if (SunDay == 31) {
                        if (monthupdate == 1 || monthupdate == 3 || monthupdate == 5 || monthupdate == 7 || monthupdate == 8 || monthupdate == 10) {
                            SunDay = date + 1;
                        }
                        else {
                            SunDay = date - 30;
                            monthupdate = month + 2;
                        }
                    }
                    if (SunDay == 32) {
                        if (monthupdate == 1 || monthupdate == 3 || monthupdate == 5 || monthupdate == 7 || monthupdate == 8 || monthupdate == 10) {
                            SunDay = date;
                        }
                        else {
                            SunDay = date - 31;
                            monthupdate = month + 2;
                        }
                    }
                    if (SunDay == 33) {
                        SunDay = date - 32;
                        monthupdate = month + 2;
                    }
                    else {
                        if (monthupdate == 1 || monthupdate == 3 || monthupdate == 5 || monthupdate == 7 || monthupdate == 8 || monthupdate == 10) {
                            SunDay = date + 1;
                        }
                        if (monthupdate == 12) {
                            if (SunDay == 30) {
                                SunDay = date + 1;
                            }
                            if (SunDay == 31) {
                                SunDay = date - 29;
                                monthupdate = month - 11;
                                yearupdate = year + 1;
                            }
                            if (SunDay == 32) {
                                SunDay = date - 31;
                                monthupdate = month - 11;
                                yearupdate = year + 1;
                            }
                        }
                        else {
                            SunDay = date - 30;
                            monthupdate = month + 2;
                        }
                    }
                }
                var updatedDate = monthupdate + '-' + SunDay + '-' + yearupdate;
                taskData.dueDate = updatedDate;
            }
        }
        return postFunction(taskData).then(
            function () {
                swal({
                    title: "Confirmation",
                    text: "You have added a new task",
                    closeOnConfirm: true,
                    type: "success"
                });
                return true;
            },
            function () {
                swal('', "Sorry, your request could not be fulfilled at this time. Please contact support@orgsoln.com", 'error');
                return false;
            },
        );
    });
}
function AssignUserSearchBox(controlId) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataManagement/GetUserProfileName_Internal/" + token
    }).then(
        function (data) {
            var users = JSON.parse(data);
            var userOptions = '<option>Select</option>'

            for (var i = 0; i < users.length; i++)
                userOptions += '<option value="' + users[i].UserID + '">' + users[i].EmpName + '</option>';

            $(controlId).append(userOptions);
        },
        function () { }
    );
}
function TaskTypeBox(TaskTypeID) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_TaskType"
    }).then(
        function (data) {
            var tasks = JSON.parse(data);

            for (var i = 0; i < tasks.length; i++) {

                $("#TaskTypeID").append('<option value=' + tasks[i].TaskTypeID + '>' + tasks[i].TaskType + '</option>');

            }
        },
        function () { }
    );
}
function TestClassName() {
    //$.getJSON(getApi + "/api/DataBind/GetList_TaskType")
    $.ajax({
        url: `${getApi}/api/DataBind/GetList_TaskType`,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'GET',
        success: function (result) {

        }
    });
    //alert("test");
    //var tasks = JSON.parse(data);
    //alert("test");
    //if (eventDef.id = data.TaskT) {
    //    alert("Hello");
    //}
    //TaskTypeID = tasks;
    //if (eventDef.id = data.TaskTypeID) {
    //    alert("Hello");
    //    //var TaskClassNamep = $("#TaskClassName");
    //    //$("#TaskTypeID").append(tasks);
    //    //alert(TaskClassNamep);
    //}
}
var newTaskHTML = `
<div id='taskAction'>
    <div class='row margin_bottom'>
        <div class='col-sm-12'>
            <div>Please fill in all fields:</div>
            <br/>
            <div class='col-sm-12'>
                <div class='row margin-bottom'>
                    <div class='col-sm-3'>
                        <label>Task Name: </label>
                        <input id='taskName' class='form-control required' />
                    </div>
                    <div id='due_date_label' class='col-sm-3'>
                        <label>Due Date: </label>
                        <input type='date' id='taskEndDate' name='date' class='form-control date required' />
                    </div>
                    <div class='col-sm-3'>
                        <label>Assigned to: </label>
                        <select id="taskAssignment" class='form-control required'></select>
                    </div>
                    <div class='col-sm-3'>
                        <label>Task Type: </label>
                        <select id="TaskTypeID" class='form-control'></select>
                    </div>
                </div>
                <div class='row'>
                    <div class='col-sm-12'>
                        <label>Description: </label>
                        <textarea id='taskDescription' class='form-control' maxlength='80'></textarea>
                    </div>
                </div>
            </div>
        </div>
    </div> 
</div>`