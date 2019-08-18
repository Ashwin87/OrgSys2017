<%@ Page Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="TaskManager.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.TaskManager" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Assets/js/common/Validation.js"></script>
    <script src="Internal_Forms/JSFiles/TaskManager.js"></script>
    <script>
          /*Created By     : Marie Gougeon
            Created Date   : 2017-10-10
            Update Date    : 2018-05-10 - Marie
            Description    : TASKS CREATOR & EDITOR
            Updated by     : Richa Patel
            Update Date    : 2019-05-18-10 - Richa
          */
        var token = '<%= token %>'; 
        window.getApi = "<%= get_api %>";
        $(function () {
            var results;
            $.ajax({
                url: getApi + "/api/Roles/GetUserTasks/" + token,
                 beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                async: false,
                success: function (data) {
                    results = JSON.parse(data);
                }
            });
            var editTable = $("#ActiveTaskDT").DataTable({
                data: results,
                //"order": [[4, "CreatedDate"]],
                "sPaginationType": "full_numbers",
                "columns": [
                    { "data": "TaskID" },
                    { "data": "" },
                    { "data": "TaskName" },
                    { "data": "UserCreated" },
                    { "data": "UserTaskAssigned" },
                    //{
                    //    "data": "CreatedDate",
                    //    "render": ConvertDateIsoToCustom
                    //},
                    {
                        "data": "DateModified",
                        "render": ConvertDateIsoToCustom
                    },
                    {
                        "data": "DueDate",
                        "render": ConvertDateIsoToCustom
                    }
                    //{ "data": "TaskType" }
                ],
                "columnDefs": [
                    {
                        "targets": 1,
                        "data": null,
                        "searchable": false,
                        "orderable": false,
                        "defaultContent": `
                        <div class="row">
                            <a id='completeButton' data-toggle='tooltip' title='Complete Task' class='complete btn btn-default view_description'>
                                <i class='icon icon-checkmark'></i>
                            </a>
                            <a id='postponeTaskButton' data-toggle='tooltip' title='Postpone - Change Due Date' class='btn btn-default view_description'>
                                <i class='icon icon-clock'></i>
                            </a>
                            <a id='EditTaskButton' data-toggle='tooltip' title='View and add Comment' class='updatetask btn btn-default view_description'>
                                <i class='icon icon-edit1'></i>
                            </a>
                        </div>
                        <div class="row">
                            <a id='ReassignTaskButton' data-toggle='tooltip' title='Re-assign a task' class='btn btn-default view_description'>
                                <i class='icon icon-user-plus'></i>
                            </a>
                            <a id='reviewDescriptionTaskButton' data-toggle='tooltip' title='View Description' class='checkdesc btn btn-default view_description'>
                                <i class='icon icon-bubble'></i>
                            </a>
                            <a id='DeleteTaskButton' data-toggle='tooltip' title='Delete a task' class='deletetask btn btn-default btn-danger'>
                                <i class='icon icon-bin'></i>
                            </a>
                            <!-- <a id='viewCommentsAssignedButton' data-toggle='tooltip' title='View Comments' class='view btn btn-default view_description'>
                                <i class='icon icon-eye'></i> --!>
                            </a>
                        </div>
                            `
                    }
                ]
            });
            $('#activeTaskFilter').on('change', function () {
                var columnId = this.value;
                var username = $('#dropdownName').text()

                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url: getApi + "/api/DataManagement/GetUserInfo/" + username
                }).then(
                    function (data) {
                        var name = JSON.parse(data)[0]['EmpName']
                        var searchText = columnId == 0 ? '' : name;
                        editTable.columns().search('');
                        editTable.column(columnId).search(searchText).draw();
                    },
                    function () {
                        editTable.columns().search('');
                    }
                )
            });
            //DATATABLE - COMPLETED TASKS DATATABLE - based on tasks the user created
            $.ajax({
                url: getApi + "/api/Roles/GetCompletedTasks/" + token,
                 beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                async: false,
                success: function (data) {
                    results = JSON.parse(data);
                }
            });
            var completeTable = $("#CompletedTaskDT").DataTable({
                data: results,
                "order": [[5, "CompletedDate"]],
                "sPaginationType": "full_numbers",
                "columns": [
                    { "data": "TaskID" },
                    { "data": "" },
                    { "data": "EmpName" },
                    { "data": "TaskName" },
                    {
                        "data": "DateModified", 
                        "render": ConvertDateIsoToCustom
                    },
                    {
                        "data": "DueDate",
                        "render": ConvertDateIsoToCustom
                    },
                    {
                        "data": "CompleteDate",
                        "render": ConvertDateIsoToCustom
                    }
                    //{ "data": "TaskType" }
                ],
                "columnDefs": [
                    {
                        "targets":1,
                        "data": null,
                        "searchable": false,
                        "orderable": false,
                        "defaultContent":`
                            <a id='reviewDescriptionTaskButton' data-toggle='tooltip' title='View Description' class='checkdesc btn btn-default view_description'>
                                <i class='icon-bubble'></i>
                            </a>
                            <a id='viewCommentsAssignedButton' data-toggle='tooltip' title='View Comments' class='view btn btn-default view_description'>
                                <i class='icon-eye'></i>
                            </a>`
                    }
                ]
            });
            //Standard datatable setup
            $('.Standard').DataTable({
                "order": [[4, "desc"]],
                "sPaginationType": "full_numbers",
            });    
            $("tr:even").css("background-color", "#dfebf3");
            $("tr:odd").css("background-color", "white");
            $(document).on('click', "#newTask-modal", function () {
                ShowNewTaskSwal(PostTask).then(
                    function (isTaskCreated) {
                        if (isTaskCreated) {
                            GetUserTasks().then(function (tasks) {
                                SetDataDT('#ActiveTaskDT', tasks);
                            });
                        }
                    }
                );
            });
            $(document).on('click', '#ActiveTaskDT #postponeTaskButton', function () {
                var data = editTable.row($(this).parents("tr")).data();
                PostponeTaskSwal(data).then(
                    function (isTaskPostponed) {
                        if (isTaskPostponed)
                            GetUserTasks().then(function (tasks) {
                                SetDataDT('#ActiveTaskDT', tasks);
                            });
                    }
                );
            });
            $(document).on('click', '#ActiveTaskDT a.deletetask', function () {
                var data = editTable.row($(this).parents("tr")).data();
                DeleteTaskSwal(data).then(
                    function (isTaskDeleted) {
                        if (isTaskDeleted)
                            GetUserTasks().then(function (tasks) {
                                SetDataDT('#ActiveTaskDT', tasks);
                            });
                    }
                );
            });   
            $(document).on('click', '#ActiveTaskDT #ReassignTaskButton', function () {
                var data = editTable.row($(this).parents("tr")).data();
                ReassignTaskSwal(data).then(
                    function (isTaskReassigned) {
                        if (isTaskReassigned)
                            GetUserTasks().then(function (data) {
                                SetDataDT('#ActiveTaskDT', data);
                            });
                    }
                );
            });
            $(document).on('click', '#completeButton', function () {
                var data = editTable.row($(this).parents("tr")).data();
                CompleteTaskSwal(data).then(
                    function (isTaskCompleted) {
                        if (isTaskCompleted) {
                            GetUserTasks().then(function (data) {
                                SetDataDT('#ActiveTaskDT', data);
                            });
                            loadCompletedTasks().then(function (data) {
                                SetDataDT('#CompletedTaskDT', data);
                            });
                        }
                    }
                );
            });
            $(document).on('click', '#ActiveTaskDT a.updatetask', function () {
                var data = editTable.row($(this).parents("tr")).data();
                AddTaskCommentSwal(data);
            });    
            $(document).on('click', '#ActiveTaskDT a.checkdesc', function () {
                var data = editTable.row($(this).parents("tr")).data();
                TaskDecriptionSwal(data);                
            });
            $(document).on('click', '#CompletedTaskDT a.checkdesc', function () {
                var data = completeTable.row($(this).parents("tr")).data();
                TaskDecriptionSwal(data);                
            });
            $(document).on('click', '#CompletedTaskDT a.view', function () {
                var data = completeTable.row($(this).parents("tr")).data();
                ViewTaskCommentsSwal(data)
            });
            $(document).on('click', '#ActiveTaskDT a.view', function () {
                var data = editTable.row($(this).parents("tr")).data();
                ViewTaskCommentsSwal(data)
            });
        });
        $(document).ready(function () {
            
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="page-wrapper">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
            <div id="welcome-container" class="osp-heading panel-heading"> 
               <h4 id="welcome-header" class="osp-heading panel-heading">Tasks Manager</h4>
            </div>
            <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div class="create_new_task">
            <!-- CREATE A NEW TASK -->
            <div class="new_task_button_container" id="app1">
                 <div class="form-group new_task_button">
                     <a id="newTask-modal" data-toggle="tooltip" title="Create a new task for yourself or for another team member. The tasks are not claim related. " class="btn btn-info new_task"><i class="icon-plus"></i></a>
                 </div>
            </div>
        </div>
        <div class="main-wrapper task_manager" style="height: 570px!important;">
        <!-- TABLES SHOW & EDIT TASKS -->
            <div id="tabs" class="task_manager_tabs">
                <ul class="tabCheck nav nav-tabs">
                    <li class="active" id="editTab">
                        <a data-toggle="tab" href="#assignedEdit">Active Tasks</a>
                    </li>
                    <li id="completeTab">
                        <a data-toggle="tab" href="#assignedComplete">Completed Tasks</a>
                    </li>
                </ul>
            </div>
            <div class="tab-content task_manager_tab_content">
                <div id="assignedEdit" class="active tab-pane edit_tasks">
                    <div>
                        <p>Filter By:</p> 
                        <select id="activeTaskFilter">
                            <option value="0">All Active</option>
                            <option value="4">Assigned to you</option>
                            <option value="3">Created by you</option>
                        </select>
                        <br/><br/>
                    </div>
                    <table id="ActiveTaskDT" class="table table-bordered table-striped table-hover">
                        <thead>
                            <tr>
                                <th>Task ID</th>
                                <th>Actions</th>                            
                                <th>Task Name</th>
                                <th>Created by</th>
                                <th>Assigned to</th>
                                <%--<th>Created</th>--%>
                                <th>Date Last Modified</th>
                                <th>Due Date</th>
                                <%--<th>Task Type</th>--%>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div id="assignedComplete" class="tab-pane fade completed_tasks">
                    <table id="CompletedTaskDT" class="table table-bordered table-striped table-hover" style="width:100%;">
                        <thead>
                            <tr>
                                <th>Task ID</th>
                                <th>Actions</th>                            
                                <th>Assigned to</th>
                                <th>Task Name</th>
                                <th>Date Last Modified</th>
                                <th>Due Date</th>
                                <th>Completion Date</th>
                                <%--<th>Task Type</th>--%>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
