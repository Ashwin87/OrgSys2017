

function getClaimUsersTemplate(claim) {
    return `
    ${getAddClaimUserTemplate(claim)}
    <div class='row margin_bottom'></div>
        <div class="row">
             <div class='col-md-12'>
                <table id='searchUserDataTable' class='table table-bordered table-striped table-hover dataTable no-footer claims_manager_table' style='width: 100% !important'>
                    <thead>
                        <tr>
                            <th>Actions</th>
                            <th>Employee Name</th>
                            <th>Username</th>
                            <th>Employee Email</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>`
}

function getAddClaimUserTemplate(claim) {
    return `
    <div id="claim-users-modal" class="row">
        <div class='col-md-12'>
            <div class='modify_user_submenu'>Search and select a user to re-assign a claim and the tasks associated with it.</div> \n\n
            <div class='row'>
                <div class='col-md-12'>
                    <label for="selectUsers">To add a user, Select user and click 'Add'</label>
                    <div class='input-group'>
                        <select id="selectUsers" class="form-control"></select>
                        <span class="input-group-btn">
                            <button id="AddUser" data-userassignedid="${claim.UserAssignedID}" data-claimid="${claim.claimID}" data-claimrefnu="${claim.claimRefNu}" type="button" class="btn btn-primary margin_left_5">Add</button>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>`
}



var claimUsersDTConfig = {
    lengthChange: false,
    pageLength: 5,
    columns: [
        {
            data: null, render: function (data, type, row) {
                return `<a  data-UserAssignedID="${data.UserAssignedID}" 
                            data-UserID="${data.UserID}" 
                            data-ClaimID="${data.ClaimID}"
                            data-ClaimRefNu="${data.ClaimReferenceNumber}"
                            data-UserAssigned="${data.Username}"
                            type='button' 
                            class='removeUser btn btn-danger' 
                            width='5px' 
                            data-toggle='tooltip' 
                            title='Remove this user from this claim'>
                                <i class='icon icon-bin'></i>
                        </a>`;
            }
        },
        {
            data: null, render: function (data, type, row) {
                return data.EmpFirstName + " " + data.EmpLastName;
            }
        },
        { data: "Username" },
        { data: "Email" }
    ]
}

function AddClaimUser(claim) {
    var userList = $("#selectUsers");
    var userData = userList.select2("data")[0];

    if (!userData) 
        return;

    var user = {
        UserAssignedID: claim.UserAssignedID,
        ClaimReferenceNumber: claim.claimRefNu,
        ClaimID: claim.claimID,
        UserID: userData.element.attributes["data-userid"].value,
        ActiveUserID: window.UserID || ActiveUserID,
        Email: userData.element.attributes["data-email"].value,
        EmpFirstName: userData.element.attributes["data-empfirstname"].value,
        EmpLastName: userData.element.attributes["data-emplastname"].value,
        Username: userData.element.attributes["data-username"].value
    };
    
    userList.find("option[value='" + user.UserID + "']").remove().trigger("change");
    return $.ajax({
        url: `${getApi}/api/Claim/AddUsersAssignedToClaim/${token}/${user.ClaimReferenceNumber}/${user.ClaimID}/${user.UserID}`,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        async: false
    }).then(
        function () {
            $.notify({ message: `You\'ve added user ${user.EmpFirstName} ${user.EmpLastName} to the claim!` }, { type: 'success' });
        }
    );
}

function AddClaimUserSwal(claim, tableSelector) {
    GetUsersByClaimAndClient(claim).then(function (data) {
        swal({
            title: "Add users to this claim",
            showCancelButton: true,
            showConfirmButton: false,
            cancelButtonText: 'Close',
            customClass: "swal-wide",
            html: getAddClaimUserTemplate(claim),
            onOpen: function () {
                $("#selectUsers").select2().append(data.options);

                $("#AddUser").on("click", () =>
                    AddClaimUser(claim).then(
                        () => GetDataGeneric('DataBind', 'GetOSIContacts', ClaimRefNu).then(function (contacts) {
                            SetDataDT(tableSelector, contacts);
                        })
                    )
                );
            }
        });
    });
}

function EditClaimUsersSwal(claim) {
    GetUsersByClaimAndClient(claim).then(function (data) {
        swal({
            title: "Modify Users for this Claim",
            showCancelButton: true,
            showConfirmButton: false,
            cancelButtonText: 'Close',
            customClass: "swal-wide",
            html: getClaimUsersTemplate(claim),
            onOpen: function () {
                $("#selectUsers").select2().append(data.options);
                InitializeDT("#searchUserDataTable", claimUsersDTConfig);                
                SetDataDT("#searchUserDataTable", data.claimUsers);

                $("#AddUser").on("click", function () {
                    var claim = {
                        claimRefNu: $(this).attr("data-claimrefnu"),
                        claimID: $(this).attr("data-claimid"),
                        UserAssignedID: $(this).attr("data-userassignedid")
                    }
                    AddClaimUser(claim).then(
                        () => GetDataGeneric("Claim", "GetUsersAssignedToClaim", [token, claim.claimRefNu, false]).then(function (users) {
                            SetDataDT("#searchUserDataTable", users)
                        })
                    );
                });
            }
        });
    });
}

function RemoveClaimUserSwal(user, tableSelector) {
    var claimUserDT = $(tableSelector).DataTable()
    var UsersAssignedCount = claimUserDT.data().length;
    var index = claimUserDT.row(user.tableRow).index();

    if (UsersAssignedCount === 1) {
        swal("", "At least one person must remain assigned to the claim.", "error");
        return;
    }

    swal({
        title: "Expire user " + user.userAssignedToClaim + " from claim?",
        text: "",
        type: "warning",
        showCancelButton: true,
        cancelButtonText: 'Close',
        confirmButtonText: 'Expire User',
        reverseButtons: true
    }).then(
        function () {
            $.ajax({
                url: getApi + "/api/Claim/ExpireUserAssignedToClaim/" + token + "/" + user.UserAssignedID + "/" + (window.UserID || ActiveUserID),
                beforeSend: function (request) {
                    request.setRequestHeader("Authentication", window.token);
                },
                async: false,
                success: function (data) {
                    results = JSON.parse(data);
                    claimUserDT.rows(index).remove().draw();
                    swal("Success!", user.userAssignedToClaim + " has been expired from the claim. ", "success");
                },
                error: function (data) {
                    swal("Error!", user.userAssignedToClaim + " has not been removed from the claim", "error");
                }
            });
        },
        function () {
            swal("Cancelled!", "User has not been expired from the claim", "error");
        }
    );
}

function GetUsersByClaimAndClient(claim) {
     return $.when(
        GetDataGeneric(token + "/Users", "GetUsersAssignedToClient", claim.clientID),
        GetDataGeneric("Claim", "GetUsersAssignedToClaim", [token, claim.claimRefNu, false])
    ).then(
        function (usersAssignedToClient, usersAssignedToClaim) {
            return {
                claimUsers: usersAssignedToClaim,
                clientUsers: usersAssignedToClient,
                options: GetClaimUserOptions(usersAssignedToClaim, usersAssignedToClient)
            }
        }
    );
}

function GetClaimUserOptions(claimUsers, clientUsers) {
    var options = ''

    $.each(clientUsers, function (key, user) {
        var isUserAssignedToClaim = $.grep(claimUsers, function (e) { return e.UserID == user.UserID; }).length === 0;
        if (isUserAssignedToClaim) {
            options += `<option data-userid='${user.UserID}'
                                data-empfirstname='${user.EmpFirstName}'
                                data-emplastname='${user.EmpLastName}'
                                data-username='${user.Username}'
                                data-email='${user.Email}'
                                value='${user.UserID}'>
                            ${user.EmpFirstName} ${user.EmpLastName}
                        </option>`;
        }
    });

    return options;
}




