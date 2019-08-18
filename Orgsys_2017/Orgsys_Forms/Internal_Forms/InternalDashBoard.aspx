<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="InternalDashBoard.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.InternalDashBoard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="JSFiles/TaskManager.js"></script>
    <script>
        window.getApi = "<%= get_api %>";
        // TEST DEBUG CALLS
        //DEBUG('Just testing debug calls', 'warn', 'warn');
        //DEBUG('Just testing debug calls', 'info', 'info');
        //DEBUG('Just testing debug calls', 'error', 'error');
        //DEBUG('Just testing debug calls', 'log', 'log');

        var token = "<%= token %>"; 
        var getApi = "<%= get_api %>"; 
        $(function () {
            /*
            Created By     : Sam Khan
            Created Date   : 2017-05-18
            Updated by     : Marie Gougeon
            Update Date    : 2018-03-21
            Description    : It gets the new claims of the specific client for the respective users
            */
            //Updated by: Marie Gougeon - Revised 2018-03-09
            
            DEBUG(token, 'Token', 'info');
            //Get Opened Claims to populate the list for internal clients
            $.ajax({
                    url: "<%= get_api %>/api/Claim/GetOpenedClaims/" + token,
                      beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                         var results = JSON.parse(data);

                for (i = 0; i < results.length; i++) {
                    $('#pendingCliams').append($('<option>').text(results[i]["EmpFirstName"] + ' ' + results[i]["EmpLastName"] + ' Claim Number: ' + results[i]["ClaimID"] + ' Client: ' + results[i]["ClientName"]).attr('value', results[i]["ClaimID"]).attr('data-tokens', results[i]["EmpLastName"]));
                }
                    }
                });

            //Updated by: Marie Gougeon - Revised 2017-09-25
            //pending claims - when selected, time viewed changes (and status)
            $(".selectpicker").click(function () {
                $.ajax({
                    url: "<%=get_api %>/api/Claim/Claims_ChangeStatus/" + $(this).val(),
                      beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false
                });
                window.location.href = "WC.aspx?ClaimID=" + $(this).val();
            });
            //Calendar JS
            var calendarTarget = $('#calendar')
            var calendar = new FullCalendar.Calendar(calendarTarget, {
                selectable: true,
                unselectAuto: true,
                selectMinDistance: 1,
                bootstrapGlyphicons: {
                    close: 'fa-times',
                    prev: 'fa-chevron-left',
                    next: 'fa-chevron-right',
                    prevYear: 'fa-angle-double-left',
                    nextYear: 'fa-angle-double-right'
                },
                themeSystem: 'bootstrap4',
                customButtons: {
                    addEvent: {
                        text: 'Add Event',
                        click: function () {
                            ShowNewTaskSwal(PostTask).then(
                                function (isTaskCreated) {
                                    if (isTaskCreated) calendar.refetchEvents();
                                }
                            );
                        }
                    }
                },
                header: {
                    center: 'month,agendaWeek,listWeek',
                    right: 'addEvent prev,next'
                },
                views: {
                    month: { // options apply to month view
                    },
                    agenda: {
                        // options apply to agendaWeek views
                    },
                    day: {
                        // options apply to basicDay views
                    }
                },
                weekends: false,
                eventClick: function (info) {
                    ShowTaskActionSwal(info);
                },
                eventSources: [
                    {
                         headers: { Authentication: '<%= token%>' },
                        url: '<%= get_api%>/api/Task/<%= token%>/calendarfeed'
                       
                    }
                ],
                displayEventTime: false,
                eventRender: eventRenderCallback
            });
            function eventRenderCallback(event, element) {
                console.log(event);

                element.find("div").addClass(`${event.extendedProps.taskClassName}`);
            }

            calendar.render();
            calendar.refetchEvents();

            var date = new Date('<%= DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") %>');
        
            //update_tasks_panel();
            //update_openClaims_panel();


            /////////////////////////////////////////// Notifications ////////////////////////////////////////
            LoadNotifications();
            InitializeDataTable();
            var noti;
            function LoadNotifications() {
                $.ajax({
                    url: "<%= get_api %>/api/Notifications/GetNotifications_V2/" + token,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    success: function (data) {
                        noti = JSON.parse(data);
                    }
                });
            }

            var NotiTable;
            function InitializeDataTable() {
                NotiTable = $('#notificationsTable').DataTable({
                    select: true,
                    searching: false,
                    lengthChange: false,
                    pagingType: 'simple',
                    "order": [[ 1, "asc" ]],
                    data: noti,
                    columns: [
                        { data: 'NMSGShort' },
                        {
                            data: 'NDateTime',
                            render: function (data, type, row) {
                                if (type === 'display' || type === 'filter') {
                                    return GetTimeMessage(data)
                                } else {
                                    return data;
                                }
                               
                            }
                        }
                    ]
                });
            }
            setInterval(function () {
                LoadNotifications();
                NotiTable.clear();
                NotiTable.rows.add(noti).draw(false);
            }, 30000);







                        /*
             Created By     : Kamil Salagan
             Created Date   : 2018-01-26
             Description    : Generates SWAL for each notification in notifications panel
             Updated By     : Marie Gougeon
             Update Date    : 2018-03-21
             Updated        : Added logic for claim types - view mode and extra data - added notifications to groups policy, changed stored procedure to make more sense
             */
            $('#notificationsTable').on('click', 'tbody tr', function () {


                var notres;
                var notificationID = NotiTable.row(this).data().NID;
                var ClientID = NotiTable.row(this).data().ClientID
                var notificationType = "";
                var systemTaskNumber;
                var claimid;
                $.ajax({
                    url: "<%= get_api %>/api/Notifications/GetNewNotifications/" + token + "/" + notificationID,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    success: function (data) {
                        notres = JSON.parse(data);
                        if (notres.length > 0) {
                            swal({
                                title: "Notification - " + notres[0]["NMSGShort"],
                                html: notres[0]["NMSGLong"],
                                type: "info",
                                showCancelButton: true,
                                confirmButtonClass: "btn-success",
                                cancelButtonText: 'Close',
                                confirmButtonText: "Proceed",
                                reverseButtons: true
                            }).then(function (result) {
                                    if (result) {
                                        notificationType = notres[0]["NDataType"];
                                        if (notificationType === 'ClaimID') { //check what kind of notification it is
                                            systemTaskNumber = 1; //claim task number in db will always be 1 for Claims
                                            claimid = notres[0]["NData"];
                                            swal({
                                                title: "Claim Assignment",
                                                html: "Once accepted, this claim will become your responsibility and will be assigned to you. Proceed? ",
                                                type: "info",
                                                showCancelButton: true,
                                                confirmButtonClass: "btn-success",
                                                cancelButtonText: 'No',
                                                confirmButtonText: "Yes - Assign Claim",
                                                reverseButtons: true
                                            }).then(function (result) {
                                                if (result) {
                                                    UpdateData(token, notificationID, systemTaskNumber, notificationType, claimid);
                                                        location.href = "WC.aspx?ClaimID=" + claimid +"&ClientID=" + ClientID ;
                                                }
                                            });
                                            
                                        } else if (notificationType === 'Adjudicated') {
                                            CloseNotifications(notificationID);
                                            location.href = "/OrgSys_Forms/ClaimsManager.aspx";
                                        } else if (notificationType === 'TaskID') {
                                            CloseNotifications(notificationID);
                                            location.href = "/OrgSys_Forms/TaskManager.aspx";
                                        }
                                    }
                                },
                                function (dismiss) {
                                    if (dismiss === 'cancel') {
                                        swal("Action Aborted", "You have chosen not to reviewed this item yet. Please make sure to review all items in a timely manner.", "error");
                                        LoadNotifications();
                                    }
                                })
                        }

                    }

                });

            });
            /*
             Created By     : Marie Gougeon
             Created Date   : 2018-03-14
             Description    : Updating the database with info depending on the type of notification under review
             Updated By     : Marie Gougeon
             Update Date    : 2018-03-21
             Updated        : Added logic for claim types - fixed ajax
             */
            function UpdateData(token, notificationID, systemTaskNumber, notificationType, claimid) {
                if (notificationType == "ClaimID") {
                    $.ajax({
                        url: "<%= get_api %>/api/Notifications/UpdateNotificationsClaims/" + token + "/" + notificationID,
                        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                        async: false,
                        success: function (data) {
                            DEBUG("UpdateNotifications Success");
                        },
                        error: function (request, status, error) {
                            DEBUG(request.responseText);
                        }
                    });
                    $.ajax({
                        url: "<%= get_api %>/api/Task/AddSystemTask/" + token + "/" + systemTaskNumber + "/" + claimid,
                        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                        async: false,
                        success: function (data) {
                            DEBUG("AddSystemTask Success");
                        },
                        error: function (request, status, error) {
                            DEBUG(request.responseText);
                        }
                    });
                    CloseNotifications(notificationID);
                };
            }


            function CloseNotifications(notificationID) {
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url: "<%= get_api %>/api/Notifications/CloseNotifications/" + notificationID,
                    success: function (data) {
                        LoadNotifications();
                    }
                });
            };
            ///////////////////////////////////////////Notifications End//////////////////////////////////////////







      

            function update_openClaims_panel() {
                DEBUG("Updating Open Claims Panel", null, null);
                $.ajax({
                    url: "<%= get_api %>/api/Claim/GetClaims/" + token + '/' + true + '/' + false,
                    beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                        $("#openClaims_panel a").remove(); //Remove old notifications
                        $("#dialogs .modal").remove();
                        var results = JSON.parse(data);
                        if (results.length >= 1) {
                            for (i = 0; i < results.length; i++) {
                                var date = new Date(results[i]["DateCreation"].replace('T', ' '));
                                var datecreated = (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear();
                                var ReferenceNumber = results[i]["ClaimRefNu"]
                                var link = $('<li class="styleList" id="' + results[i]["ClaimID"] + '"><a href="" class="list-group-item" id="' + results[i]["ClaimID"] + '" data-toggle="modal" data-target="#modal' + results[i]["ClaimID"] + '"><span class="badge">' + datecreated + ' </span><i class="icon icon-user"></i>' + results[i]["EmpLastName"] + ', ' + results[i]["EmpFirstName"] + " - Reference Number: "+ ReferenceNumber + '</a></li>');
                                $('#openClaims_panel').append(link);
                            }
                        } else if (results.length < 1) {
                            $('#notificationsEmpty').remove();
                            $('#openClaims_panel').append('<span id="notificationsEmpty" class="notificationsEmpty">Nothing to see here!</span>');
                        }
                    }
                })
            }

            /*
             Created By     : Kamil Salagan
             Created Date   : 2018-01-19
             Description    : populates tasks panel with latest data.
             Updated By     : Marie Gougeon
             Update Date    : 2018-07-13
             Updated        : Fixed calculations producing negative values for future dates
                              Fixed panel displaying negative values
                              Removed '1 hour' badge, conflicted with 'Past Due' badge
             */
            function update_tasks_panel() {
                DEBUG("Updating Tasks Panel", null, null);
                var results;
                var taskID;
                $("#tasks_panel a").remove(); //Remove old tasks
                $.ajax({
                    url: "<%= get_api %>/api/Roles/GetAssignedTasks10/" + token,
                     beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    success: function (data) {
                        results = JSON.parse(data);
                        if (results.length >= 1) {

                            var count = (results.length < 8) ? results.length : 8;
                            for (i = 0; i < count ; i++) {//Maximum 8 tasks aloud to be displayed on front page

                                var ndate = new Date(results[i]["DueDate"].replace('T', ' ')); //Convert to neutral date between FF and Chrome
                                var min = Math.floor(((ndate - date) / 1000) / 60); //minutes

                                var prefix = "";
                                var warn = " good";

                                if (date > ndate) {
                                    prefix = "Past Due ";
                                    warn = " bad";
                                }
                                else {
                                    prefix = "Due in ";
                                    warn = " good";
                                }

                                if (min < 0) //Compensate for negative values, we dont want to show negative symbols
                                    min = min * (-1);

                                var time_msg = '';
                                if (min < 6) {
                                    time_msg = prefix + 'now'
                                }
                                else {
                                    var hrs = Math.floor(((ndate - date) / 1000) / 3600);
                                    if (hrs < 0) //Compensate for negative values, we dont want to show negative symbols
                                        hrs = hrs * (-1);

                                    if (hrs > 24) {
                                        time_msg = prefix + Math.floor(hrs / 24) + ' days';
                                    }
                                    else {
                                        time_msg = prefix + hrs + ' hours';
                                    }
                                }

                                var link = $('<li class="styleList" id="' + results[i]["TaskID"] + '"><a href="" class="list-group-item' + warn + '" id="' + results[i]["TaskID"] + '" data-toggle="modal" data-target="#modal' + results[i]["TaskID"] + '"><span class="badge">' + time_msg + ' </span><i class="icon icon-user"></i>' + results[i]["TaskName"] + '</a></li>');
                                $('#tasks_panel').append(link);
                            }
                        } else if (results.length < 1) {
                            $('#tasksEmpty').remove();
                            $('#tasks_panel').append('<span id="tasksEmpty" class="tasksEmpty">Nothing to see here!</span>');
                        }
                    }
                });
            }



            /*
             Created By     : Marie Gougeon
             Created Date   : 2018-03-10
             Description    : Updating open claims panel - view button logic and info display
             Updated By     : Marie Gougeon
             Update Date    : 2018-03-21
             Updated        : fixed redirect, fixed swal
             */

            $('#openClaims_panel').on('click', 'a.list-group-item', function () {
                var notres;
                var ClaimID = this.id;

                $.ajax({
                    url: "<%= get_api %>/api/Notifications/GetSelectedOpenedClaim/" + token + "/" + ClaimID,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    success: function (data) {
                        notres = JSON.parse(data);
                        if (notres.length > 0) {
                            swal({
                                title: "Claim - " + notres[0]["ClaimRefNu"],
                                html: "Client: " + notres[0]["ClientName"] + "</br>" + "Employee: " + notres[0]["EmpFirstName"] + " " + notres[0]["EmpLastName"] + "</br>" + "" + "</br></br>Click 'view' to review or add to this claim",
                                type: "info",
                                showCancelButton: true,
                                confirmButtonClass: "btn-success",
                                cancelButtonText: 'Close',
                                confirmButtonText: "View",
                                reverseButtons: true
                            }).then(function (result) {
                                if (result) {
                                    location.href = "WC.aspx?ClaimID=" + notres[0]["ClaimID"];
                                }                                
                            },
                            function (dismiss) {
                                if (dismiss === 'cancel') {
                                    swal("Claim Not Updated", "Please review - Claim Reference #" + notres[0]["ClaimRefNu"], "error");
                                }
                            })
                        }
                    }
                });
            });

            /*
             Created By     : Kamil Salagan
             Created Date   : 2018-01-19
             Description    : Generates SWAL for each task in tasks panel
             Updated By     : Kamil Salagan
             Update Date    : 2018-01-25
             Updated        : Added cancel handler.
                              Added complete task handler
             Updated By     : Marie Gougeon
             Update Date    : 2018-03-21
             Updated        : added more info to task, added fix to complete task, update task panel.
            */
            $('#tasks_panel').on('click', 'a.list-group-item', function () {
                var tskres;
                var taskID = this.id;
                $.ajax({
                    url: "<%= get_api %>/api/Roles/GetTaskInfo/" + token + "/" + taskID,
                     beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    async: false,
                    success: function (data) {
                        tskres = JSON.parse(data);
                        if (tskres.length > 0) {
                            var date = new Date(tskres[0]["CreatedDate"]);
                            var newdate = (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear();
                            swal({
                                title: "Task - " + tskres[0]["TaskName"],
                                html: "Date Created: " + newdate + "</br>Description: " + tskres[0]["TaskDesc"],
                                type: "info",
                                showCancelButton: true,
                                confirmButtonClass: "btn-success",
                                cancelButtonText: 'Cancel',
                                confirmButtonText: "Completed",
                                reverseButtons: true
                            }).then(function (result) {
                                if (result) {
                                    swal({
                                        title: "Complete Task",
                                        html: "<h3>Please provide any final comments to this task.</h3></br> Note: This task will be closed once a final comment is entered. To view and edit all tasks please visit the Tasks page in your navigation bar.",
                                        input: 'textarea',
                                        customClass: 'swal-wide',
                                        showCancelButton: true,
                                        closeOnConfirm: false,
                                        buttonsStyling: false,
                                        confirmButtonClass: 'btn btn-success',
                                        cancelButtonClass: 'btn btn-default',
                                        inputPlaceholder: "Final comment"
                                    }).then(function (UserComments) {
                                        if (UserComments) {
                                            swal("Success", "Task " + tskres[0]["TaskName"] + " Completed!", "success").then(function () {
                                                $.ajax({
                                                    type: 'GET',
                                                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                                                    url:"<%= get_api %>/api/Roles/Update_CompleteTask/" + taskID + "/" + UserComments,
                                                    success: function (Tdata) {
                                                      results = JSON.parse(Tdata);
                                                    update_tasks_panel();
                                                    }
                                                });                                           
                                            });
                                        } else {
                                            swal('Cancelled','You have not completed the task','error');
                                            return false;
                                        }
                                       
                                        });
                                    }
                                },
                                function (dismiss) {
                                    if (dismiss === 'cancel') {
                                        swal("Action Aborted", "You failed to review your task at this time - " + tskres[0]["TaskName"], "error");
                                        update_tasks_panel();
                                    }
                                })
                        }
                    }
                });
            });

            

            function ShowTaskActionSwal(task) {
                swal({
                    title: "Act on Task",
                    html: taskActionHTML,
                    showCancelButton: true,
                    width: '650px',
                    confirmButtonClass: "btn-info",
                    cancelButtonText: 'Close',
                    confirmButtonText: 'Submit',
                    onOpen: function () {
                        InitializeSwalDatepicker();
                        $('#dateCreated').val(ConvertDateIsoToCustom(task.extendedProps.dateCreated)) //fullcalender changes the value of start property
                        $('#createdBy').val(task.extendedProps.createdByName)
                        $('#dateDue').val(ConvertDateIsoToCustom(task.extendedProps.dueDate))
                        $('#assignedTo').val(task.extendedProps.assignedToName)
                        $('#taskDescription').val(task.extendedProps.taskDescription)
                        $('#postponeTaskButton, #ReassignTaskButton, #DeleteTaskButton, #completeButton, #viewCommentsAssignedButton, #EditTaskButton').attr('data-taskId', task.id)
                        $('#openClaimButton').attr('data-ClaimRefNo', task.ClaimRefNo)
                        if (task.ClaimRefNo == 0) {
                            $('#openClaimButton').hide();
                        }
                    },
                    preConfirm: validate.validateSwalContentPM
                })
            }

            $(document).on('click', '#postponeTaskButton', function () {
                var data = { TaskID : this.getAttribute('data-taskId') }
                PostponeTaskSwal(data).then(
                    function (isTaskPostponed) {
                        if (isTaskPostponed) {
                            calendar.refetchEvents();
                        }
                    }
                );
            });

            $(document).on('click', 'a.deletetask', function () {
                var data = { TaskID : this.getAttribute('data-taskId') }
                DeleteTaskSwal(data).then(
                    function (isTaskDeleted) {
                        if (isTaskDeleted) {
                            calendar.refetchEvents();
                        }
                    }
                );
            });    

            $(document).on('click', '#ReassignTaskButton', function () {
                var data = { TaskID : this.getAttribute('data-taskId') }
                ReassignTaskSwal(data).then(
                    function (isTaskReassigned) {
                        if (isTaskReassigned) {
                            calendar.refetchEvents();
                        }
                    }
                );
            });

            $(document).on('click', '#completeButton', function () {
                var data = { TaskID : this.getAttribute('data-taskId') }
                CompleteTaskSwal(data).then(
                    function (isTaskCompleted) {
                        if (isTaskCompleted) {
                            calendar.refetchEvents();
                        }
                    }
                );
            });

            $(document).on('click', 'a.updatetask', function () {
                var data = { TaskID : this.getAttribute('data-taskId') }
                AddTaskCommentSwal(data);
            });

            $(document).on('click', '#viewCommentsAssignedButton', function () {
                var data = { TaskID : this.getAttribute('data-taskId') }
                ViewTaskCommentsSwal(data)
            });
            $(document).on('click', '#openClaimButton', function () {
                var claimRefNo = this.getAttribute('data-ClaimRefNo')
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url: "<%= get_api %>/api/Client/GetClientIDByClaimRefNo/" + claimRefNo,
                    success: function (data) {
                          window.location.replace("/OrgSys_Forms/Internal_Forms/WC.aspx?ClaimRefNo="+claimRefNo+ "&ClientID="+JSON.parse(data));
                    }
                });
            });
            

        }); //end doc ready        

        function GetTimeMessage(date) {
            var now = new Date()
            var ndate = new Date(date.replace('T', ' ')); //Convert to neutral date between FF and Chrome
            var min = Math.floor(((now - ndate) / 1000) / 60); //minutes
            var time_msg = '';
            if (min < 6) {
                time_msg = 'Just now'
            }
            else if (min < 181) {
                time_msg = '1 hour ago'
            }
            else {
                var hrs = Math.floor(((now - ndate) / 1000) / 3600);

                if (hrs > 24) {
                    time_msg = Math.floor(hrs / 24) + ' days';
                }
                else {
                    time_msg = hrs + ' hours';
                }
            }

            return time_msg;
        }        

        var taskActionHTML = `
            <div class="act_on_task">
                <div class="act_on_task_container">
                    <input type="hidden" id="taskObject" value=""/>
                    <div class="row">
                        <div class="col-sm-6 act_on_task_row">
                            <label class="act_on_task_label" for="dateCreated">Created On</label>
                            <input type="text" class="form-control act_on_task_input" id="dateCreated" disabled="disabled"/>
                        </div>
                        <div class="col-sm-6 act_on_task_row">
                            <label class="act_on_task_label" for="createdBy">Created By</label>
                            <input type="text" class="form-control act_on_task_input" id="createdBy" disabled="disabled"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-6 act_on_task_row">
                            <label class="act_on_task_label" for="dateDue">Due Date</label>
                           <input type="text" class="form-control act_on_task_input" id="dateDue" disabled="disabled"/>
                        </div>
                        <div class="col-sm-6 act_on_task_row">
                            <label class="act_on_task_label" for="assignedTo">Assigned To</label>
                            <input type="text" class="form-control act_on_task_input" id="assignedTo" disabled="disabled"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-sm-12 act_on_task_row">
                            <input type="textarea" class="form-control act_on_task_input" id="taskDescription" disabled="disabled" />
                        </div>
                    </div>
                </div>
                <div class="act_on_task_button_container">
                    <a id='completeButton' data-toggle='tooltip' title='Complete Task' class='complete btn btn-default view_description'>
                        <i class='icon icon-checkmark'></i>
                    </a>
                    <a id='postponeTaskButton' data-toggle='tooltip' title='Postpone - Change Due Date' class='btn btn-default view_description'>
                        <i class='icon icon-clock'></i>
                    </a>
                    <a id='EditTaskButton' data-toggle='tooltip' title='Add a Comment' class='updatetask btn btn-default view_description'>
                        <i class='icon icon-edit1'></i>
                    </a>
                    <a id='ReassignTaskButton' data-toggle='tooltip' title='Re-assign a task' class='btn btn-default view_description'>
                        <i class='icon icon-user-plus'></i>
                    </a>
                    <a id='DeleteTaskButton' data-toggle='tooltip' title='Delete a task' class='deletetask btn btn-default btn-danger'>
                        <i class='icon icon-bin'></i>
                    </a>
                    <a id='viewCommentsAssignedButton' data-toggle='tooltip' title='View Comments' class='view btn btn-default view_description'>
                        <i class='icon icon-eye'></i>
                    </a>
                    <a id='openClaimButton' data-toggle='tooltip' title='View Claim' class='view btn btn-default view_description'>
                        <i class='icon icon-eye'></i>
                    </a>
                </div>
            </div>`

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper" style="margin: 0 0 0 0;">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading">
                <h4 id="welcome-header" class="osp-heading panel-heading">Home</h4>
            </div>
            <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div class="container-fluid">
            <div class="row dashboard-container">
                <div class="btn-group btn-group-toggle claim_button_container" data-toggle="buttons">
                    <label class="btn btn-secondary active">
                        <input type="radio" name="options" id="option1" checked/> Daily
                    </label>
                    <label class="btn btn-secondary">
                        <input type="radio" name="options" id="option2"/> Weekly
                    </label>
                    <label class="btn btn-secondary">
                        <input type="radio" name="options" id="option3"/> Monthly
                    </label>
                </div>
                <div class="claim_container">
                    <div class="dashboard-panel">
                        <div class="dashboard-panel-heading">New Claims</div>
                        <div class="dashboard-panel-body">
                            <div class="dashboard_button">
                                <div class="claim_button_setter">
                                    <button class="button_text" value="STD" onclick="myFunction2()">
                                        <div class="claim_button btn">
                                            <div class="button_text">STD</div>
                                        </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text" onclick="myFunction4()">
                                         <div class="claim_button btn">
                                            <div class="button_text">LTD</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                      </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text" onclick="myFunction6()">
                                         <div class="claim_button btn">
                                            <div class="button_text">WC</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                     </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text">
                                         <div class="claim_button btn">
                                            <div class="button_text">Other</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="claim_container">
                    <div class="dashboard-panel">
                        <div class="dashboard-panel-heading">Open Claims</div>
                        <div class="dashboard-panel-body">
                            <div class="dashboard_button">
                                <div class="claim_button_setter">
                                    <button class="button_text" onclick="myFunction2()">
                                        <div class="claim_button btn">
                                            <div class="button_text">STD</div>
                                        </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text" onclick="myFunction4()">
                                         <div class="claim_button btn">
                                            <div class="button_text">LTD</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text" onclick="myFunction6()">
                                         <div class="claim_button btn">
                                            <div class="button_text">WC</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text">
                                         <div class="claim_button btn">
                                            <div class="button_text">Other</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                     </button>
                                 </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="claim_container">
                    <div class="dashboard-panel">
                        <div class="dashboard-panel-heading">Closed Claims</div>
                        <div class="dashboard-panel-body">
                            <div class="dashboard_button">
                                <div class="claim_button_setter">
                                    <button class="button_text" onclick="myFunction2()">
                                        <div class="claim_button btn">
                                            <div class="button_text">STD</div>
                                        </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text" onclick="myFunction4()">
                                         <div class="claim_button btn">
                                            <div class="button_text">LTD</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                      </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text" onclick="myFunction6()">
                                         <div class="claim_button btn">
                                            <div class="button_text">WC</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                 </div>
                                 <div class="claim_button_setter">
                                     <button class="button_text">
                                         <div class="claim_button btn">
                                            <div class="button_text">Other</div>
                                         </div>
                                        <div class="claims_number">
                                            <div class="claims-number">
                                                <span>2</span>
                                            </div>
                                            <div class="claims-percentage">
                                                <span>100.0%</span>
                                            </div>
                                        </div>
                                    </button>
                                 </div>
                            </div>
                         </div>
                    </div>
                </div>
                <div class="claim_billable_container">
                    <div class="billable_container">
                        <div class="billable_minutes">
                            <span class="billable_label">Billable Minutes:</span>
                            <span class="billable_minutes_data">180</span>
                        </div>
                        <div class="billable_percentage">
                            <span class="billable_label">Billable %:</span>
                            <span class="billable_minutes_data">37.5%</span>
                        </div>
                        <div class="non_billable_minutes">
                            <span class="non_billable_label">Non-Billable Minutes:</span>
                            <span class="non_billable_minutes_data">0</span>
                        </div>
                    </div>
                    <div class="notes_container">
                        <div class="notes_setter">
                            <span class="notes"> NOTE: Previous business day numbers are updated daily at 5am EST.</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="spacer"></div>
            <div class="notification_setter">
                <div class="notification_container">
                    <div class="panel panel-default">
                        <table id="notificationsTable" class="display table table-bordered table-hover dataTable no-footer margin_bottom_10">
                            <thead>
                            <tr>
                                <th>Notification</th>
                                <th>Age</th>
                            </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
             </div>
             <div class="dashboard_calander_setter">
                 <div class="panel panel-default ">
                     <div class="panel-heading">
                         <h3 class="panel-title">
                             <i class="icon icon-calendar"></i>
                             <p>Calendar</p>
                         </h3>
                     </div>
                     <div class="panel-body front-panels-long">
                          <div id='calendar' class="calendar_setter"></div>
                     </div>
                 </div>
             </div>
         </div>
    </div>
    <div id="dialogs" class="hidden new_claims_std std_claims">
         <div class="std_claim_container">
             <div class="std_claim_header">
                 <div class="claim_header_title">
                     <span> STD Claim KPMs</span>
                 </div>
             </div>
             <div class="std_claim_body">
                 <div class="claim_table_setter">
                     <div class="claim_table_row claim_table_header">
                       <div class="claim_table_title">
                           <div class="claim_lables_row"></div>
                            <div class="your_kpm_title">
                                 <span>Your KPMs</span>
                            </div>
                        </div>
                         <div class="claim_table_label claim_table_header">
                             <span></span>
                         </div>
                         <div class="claim_table_body claim_table_header">
                             <div class="claim_body_first_column claim_column_title">
                                 <span>Open</span>
                             </div>
                             <div class="claim_body_second_column claim_column_title">
                                 <span>Clsd</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Claims</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>32</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>1</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>1st EE Contact</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>81.3%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Claim Decesion</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>84.4%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>Avrg TDO</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>47.0</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>19.0</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>TDO vs DDG</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>50.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>LTD Out</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>0.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span></span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>% Clms RTM auth</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>50.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>% Clms RTM</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>15.6%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>0.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Avrg Bill Hrs on claims</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>7.8</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>4.8</span>
                             </div>
                         </div>
                     </div>
                 </div>
                 <div class="claim_table_kpm_row">
                      <div class="claim_table_row">
                          <div class="claim_table_title claim_table_header">
                              <div class="kpm_row">
                                  <span>KPM</span>
                              </div>
                          </div>
                          <div class="claim_table_label claim_table_header">
                              <span>Req'd</span>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>90.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>90.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>28.0</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>95.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>95.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>5.0</span>
                              </div>
                          </div>
                      </div>
                 </div>
             </div>
             <div class="std_claim_footer">
                 <div class="back_button" onclick="myFunction3()">
                     <button class="btn btn-primary">Back</button>
                 </div>
             </div>
        </div>
    </div>
    <div id="dialogs2" class="hidden new_claims_std ltd_claims">
         <div class="std_claim_container">
             <div class="std_claim_header">
                 <div class="claim_header_title">
                     <span> LTD Claim KPMs</span>
                 </div>
             </div>
             <div class="std_claim_body">
                 <div class="claim_table_setter">
                     <div class="claim_table_row claim_table_header">
                       <div class="claim_table_title">
                           <div class="claim_lables_row"></div>
                            <div class="your_kpm_title">
                                 <span>Your KPMs</span>
                            </div>
                        </div>
                         <div class="claim_table_label claim_table_header">
                             <span></span>
                         </div>
                         <div class="claim_table_body claim_table_header">
                             <div class="claim_body_first_column claim_column_title">
                                 <span>Open</span>
                             </div>
                             <div class="claim_body_second_column claim_column_title">
                                 <span>Clsd</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Claims</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>32</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>1</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>Initial Ajudication</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>81.3%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Initial EE Contact</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>84.4%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>COD 1st Warn</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>47.0</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>19.0</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>COD 2nd Warn</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>50.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>Last Cntct within 60 D</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>0.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span></span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Avrg Bill Hrs on claims</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>7.8</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>4.8</span>
                             </div>
                         </div>
                     </div>
                 </div>
                 <div class="claim_table_kpm_row">
                      <div class="claim_table_row">
                          <div class="claim_table_title claim_table_header">
                              <div class="kpm_row">
                                  <span>KPM</span>
                              </div>
                          </div>
                          <div class="claim_table_label claim_table_header">
                              <span>Req'd</span>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>90.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>90.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>28.0</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>95.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>95.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>10.0</span>
                              </div>
                          </div>
                      </div>
                 </div>
             </div>
             <div class="std_claim_footer">
                 <div class="back_button" onclick="myFunction5()">
                     <button class="btn btn-primary">Back</button>
                 </div>
             </div>
        </div>
    </div>
    <div id="dialogs3" class="hidden new_claims_std wc_claims">
         <div class="std_claim_container">
             <div class="std_claim_header">
                 <div class="claim_header_title">
                     <span> WC Claim KPMs</span>
                 </div>
             </div>
             <div class="std_claim_body">
                 <div class="claim_table_setter">
                     <div class="claim_table_row claim_table_header">
                       <div class="claim_table_title">
                           <div class="claim_lables_row"></div>
                            <div class="your_kpm_title">
                                 <span>Your KPMs</span>
                            </div>
                        </div>
                         <div class="claim_table_label claim_table_header">
                             <span></span>
                         </div>
                         <div class="claim_table_body claim_table_header">
                             <div class="claim_body_first_column claim_column_title">
                                 <span>Open</span>
                             </div>
                             <div class="claim_body_second_column claim_column_title">
                                 <span>Clsd</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Claims</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>32</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>1</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>Initial EE Contact</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>81.3%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Initial CMR</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>84.4%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>Form 7 to Board</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>47.0</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>19.0</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>Lost time %</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>50.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>No Lost Time %</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>0.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span></span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row even_row">
                         <div class="claim_table_label">
                             <span>First Aid %</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>50.0%</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>100.0%</span>
                             </div>
                         </div>
                     </div>
                     <div class="claim_table_row">
                         <div class="claim_table_label">
                             <span>Avrg Bill Hrs on claims</span>
                         </div>
                         <div class="claim_table_body">
                             <div class="claim_body_first_column">
                                 <span>7.8</span>
                             </div>
                             <div class="claim_body_second_column">
                                 <span>4.8</span>
                             </div>
                         </div>
                     </div>
                 </div>
                 <div class="claim_table_kpm_row">
                      <div class="claim_table_row">
                          <div class="claim_table_title claim_table_header">
                              <div class="kpm_row">
                                  <span>KPM</span>
                              </div>
                          </div>
                          <div class="claim_table_label claim_table_header">
                              <span>Req'd</span>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>90.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>90.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>28.0</span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span>95.0%</span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body even_row">
                              <div class="claim_body_first_column">
                                  <span></span>
                              </div>
                          </div>
                          <div class="claim_table_body">
                              <div class="claim_body_first_column">
                                  <span>15.0</span>
                              </div>
                          </div>
                      </div>
                 </div>
             </div>
             <div class="std_claim_footer">
                 <div class="back_button" onclick="myFunction7()">
                     <button class="btn btn-primary">Back</button>
                 </div>
             </div>
        </div>
    </div>
    <script>
        
        function myFunction2() {
            $(".std_claims").addClass("visible");
            $("#page-wrapper").css("opacity", "0.1");
            $(".std_claims").css("opacity","1");
        };
        function myFunction3() {
            $(".std_claims").addClass("hidden");
            $("#page-wrapper").css("opacity", "1");
            $(".std_claims").css("opacity","0");
        };
        function myFunction4() {
            $(".ltd_claims").addClass("visible");
            $("#page-wrapper").css("opacity", "0.1");
            $(".ltd_claims").css("opacity","1");
        };
        function myFunction5() {
            $(".ltd_claims").addClass("hidden");
            $("#page-wrapper").css("opacity", "1");
            $(".ltd_claims").css("opacity","0");
        };
        function myFunction6() {
            $(".wc_claims").addClass("visible");
            $("#page-wrapper").css("opacity", "0.1");
            $(".wc_claims").css("opacity","1");
        };
        function myFunction7() {
            $(".wc_claims").addClass("hidden");
            $("#page-wrapper").css("opacity", "1");
            $(".wc_claims").css("opacity","0");
        };
    </script>
</asp:Content>
