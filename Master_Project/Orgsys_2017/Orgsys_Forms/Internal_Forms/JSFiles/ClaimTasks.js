//Created by:   Marie
//Created on:   04-20-2018
//Updated on:   05-16-2018 - Marie

$(document).ready(function () {
    $('[data-toggle="tooltip"]').tooltip();

    var ClaimID = $.url().param('ClaimID');
    var results;
    if (ClaimID) {
        $.ajax({
            url: getApi + "/api/Task/GetAssignedTasksByClaim/" + ClaimID,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            async: false,
            success: function (data) {
                results = JSON.parse(data);
            }
        });
    }
    var claimTaskTable = $('#claimTaskTable').DataTable({
        data: results,
        "order": [[5, "CreatedDate"]],
        "sPaginationType": "full_numbers",
        "rowId": "TaskID",
        "columns": [
            {
                "class": "details-control",
                "orderable": false,
                "data": null,
                "defaultContent": ""
            },
            { "data": "" },
            { "data": "TaskID", "searchable": false, "orderable": false, },
            { "data": "AssignedTo" },
            { "data": "TaskName" },
            {
                "data": "CreatedDate",
                "render": ConvertDateIsoToCustom
            },
            {
                "data": "DateModified",
                "render": ConvertDateIsoToCustom
            },
            {
                "data": "DueDate",
                "render": ConvertDateIsoToCustom
            }
        ],
        "columnDefs": [
            {
                "targets": -7,
                "data": null,
                "searchable": false,
                "orderable": false,
                "defaultContent": `
                    <a id='completeButton' data-toggle='tooltip' title='Complete Task' class='completeAssign btn btn-default view_description'> 
                        <i class='icon icon-clipboard'></i>
                    </a>
                    <a id='addCommentsAssignedButton' data-toggle='tooltip' title='Add a Comment' class='add btn btn-default view_description' >
                        <i class='icon icon-edit1'></i>
                    </a>
                    <a id='viewCommentsAssignedButton' data-toggle='tooltip' title='View Comments' class='view btn btn-default view_description'> 
                        <i class='icon icon-eye'></i>
                    </a>
                    <a id='reviewDescriptionTaskButton' data-toggle='tooltip' title='View Description' class='checkdesc btn btn-default view_description'>
                        <i class='icon icon-bubble'></i>
                    </a>`
            }
        ]
    });

    $(document).on('click', '#completeButton', function () {
        var data = claimTaskTable.row($(this).parents("tr")).data();
        CompleteTaskSwal(data).then(
            function (isTaskCompleted) {
                if (isTaskCompleted) {
                    GetClaimTasks().then(function (data) {
                        SetDataDT('#claimTaskTable', data);
                    });
                }
            }
        );
    });

    $(document).on('click', '#claimTaskTable a.checkdesc', function () {
        var data = claimTaskTable.row($(this).parents("tr")).data();
        TaskDecriptionSwal(data);
    });

    $(document).on('click', '#claimTaskTable #addCommentsAssignedButton', function () {
        var data = claimTaskTable.row($(this).parents("tr")).data();
        AddTaskCommentSwal(data);
    });   

    $(document).on('click', '#claimTaskTable a.view', function () {
        var data = claimTaskTable.row($(this).parents("tr")).data();
        ViewTaskCommentsSwal(data);
    });

    $(document).on('click', "#addClaimTaskDB", function () {
        ShowNewTaskSwal(PostClaimTask).then(
            function (isTaskCreated) {
                if (isTaskCreated) {
                    GetClaimTasks().then(function (tasks) {
                        SetDataDT('#claimTaskTable', tasks);
                    });
                }
            }
        );
    });

});