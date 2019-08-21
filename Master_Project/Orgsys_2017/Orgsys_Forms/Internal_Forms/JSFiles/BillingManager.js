/*Created By   : Marie Gougeon
Created Date   : 2018-07-20
Update Date    : Marie - 2018-09-20
Description    : BillingManager Javascript File*/

$(document).ready(function () {
    //Datatables
    var tblBills;

    //re usable objects
    var BillingMethods;
    var AddBillingSwalHTML;
    var BillingSwallCommentsHTML;

    GetAddBillingItemSwalHTML();
    GetBillingCommentsSwalHTML();
    GetBillingMethods();
    PopulateBillableItems();

    /** @description Gets billable items from the api and renders them into tblBillable datatable */
    function PopulateBillableItems() {
        //get the billable items from api
        $.ajax({
            url: getApi + "/api/Billing/GetBillingItem_ByUser/" + token,
            async: false
        }).then(function (data) {
            InjectDatatable(data);
        });
    }

    /** @description Gets non billable items from the api and renders them into tblNonBillable datatable */
    function PopulateNonBillableItems() {
        //get the non billable items from api
        $.ajax({
            url: getApi + "/api/Billing/GetNonBillingItem_ByUser/" + token,
            async: false
        }).then(function (data) {
            InjectDatatable(data);
        });
    }

    function InjectDatatable(data) {
        //render datatable with billable items
        tblBills = $('#tblBills').DataTable({
            data: JSON.parse(data),
            order: [[1, "BillDate"]],
            PaginationType: "full_numbers",
            rowId: "BillID",
            columns: [
                { data: "" },
                {
                    data: "BillDate",
                    render: function (data, type, row, meta) {
                        if (type === 'display') {
                            return ConvertDateIsoToCustom(data);
                        }
                        return data;
                    }
                },
                {
                    data: "DateAdded",
                    render: function (data, type, row, meta) {
                        if (type === 'display') {
                            return ConvertDateTimeIsoToCustom(data);
                        }
                        return data;
                    }
                },
                {
                    data: "CompletionDate",
                    render: function (data, type, row, meta) {
                        if (type === 'display') {
                            return ConvertDateIsoToCustom(data);
                        }
                        return data;
                    }
                },
                { data: "ClientName" },
                { data: "BillDuration" },
                { data: "Method_EN" },
                { data: "Reason_EN" },
                { data: "AssignedTo" }],
            columnDefs: [{ "targets": -9, "data": null, "searchable": false, "orderable": false, "defaultContent": "<a id='editBilling' data-toggle='tooltip' title='Edit Billing' class='editBill btn btn-default view_description'><i class='icon icon-edit1'></i></a><a id='reviewBillingComment' data-toggle='tooltip' title='View Comments' class='checkComm btn btn-default view_description'><i class='icon icon-bubble'></i></a>" }]
        });

    }



    //Edit Billing Item
    $(document).delegate("#editBilling", "click", function (event) {
        var BillID = tblBills.row($(this).parents("tr")).data().BillID;
        swal({
            title: "Edit Billing",
            html: AddBillingSwalHTML,
            showCancelButton: true,
            width: '850px',
            height: '1000px',
            confirmButtonClass: "btn-info",
            cancelButtonText: 'Close',
            confirmButtonText: 'Save',
            onOpen: function () {
                PopulateBillingSWAL(true, BillID);
            },
            preConfirm: function () {
                return new Promise(function (resolve, reject) {
                    if (Validate('#billAction')) {
                        resolve();
                    } else {
                        reject("Please check all highlighted fileds");
                    }
                });
            }
        }).then(function (result) {
            if (result) {
                UpdateBillingItem(BillID);
            }
        });
    });

    //View Billing Comments
    $(document).delegate("#reviewBillingComment", "click", function (event) {
        var Comments = tblBills.row($(this).parents("tr")).data().Comments;
        swal({
            title: "Billing Comment",
            html: BillingSwallCommentsHTML,
            showCancelButton: true,
            showConfirmButton: false,
            width: '850px',
            height: '1000px',
            cancelButtonText: 'Close',
            onOpen: function () {
                if (Comments.trim()) {
                    $('#BillingComment').append(Comments);
                } else {
                    $('#BillingComment').append("There are no comments for this Billing Item");
                }

            }
        });
    });

    //New Billing SWAL and Save a New Billing Item
    $(document).delegate("#newBilling-swal", "click", function (event) {
        var billResults;
        swal({
            title: "Add a Billing Item",
            html: AddBillingSwalHTML,
            showCancelButton: true,
            width: '850px',
            height: '1000px',
            confirmButtonClass: "btn-info",
            cancelButtonText: 'Close',
            confirmButtonText: 'Add',
            onOpen: function () {
                PopulateBillingSWAL();
            },
            preConfirm: function () {
                return new Promise(function (resolve, reject) {
                    if (Validate('#billAction')) {
                        resolve();
                    } else {
                        reject("Please check all highlighted fileds");
                    }
                });
            }
        }).then(function () {

            var billDetails = {
                BillDate: $('#billDate').val(),
                CompletionDate: $('#billDateClosed').val(),
                BillMethod: $('#billMethod').val(),
                BillReason: $('#billReason').val(),
                BillDuration: $('#billDuration').val(),
                DirectContact: $('#directcontact').is(":checked") ? 1 : 0,
                Postage: $('#postage').is(":checked") ? 1 : 0,
                Courier: $('#courier').is(":checked") ? 1 : 0,
                ClientID: $('#billClient').val(),
                Billable: $('#billable').is(":checked") ? 1 : 0,
                Comments: $('#billComment').val()
            };

            $.ajax({
                url: getApi + "/api/Billing/AddBillingItem/" + window.token,
                type: "POST",
                async: false,
                data: '=' + encodeURIComponent(JSON.stringify(billDetails)),
                success: function (data) {
                    $('#ddlBillType').trigger('change');
                    swal(
                        'Seccuess',
                        'Bill item saved',
                        'success'
                    );
                }
            });
        });
    });


    $(document.body).on('change', '#ddlBillType', function () {
        if ($.fn.DataTable.isDataTable("#tblBills")) {
            $('#tblBills').DataTable().clear().destroy();
        }
        var billType = this.value;
        if (billType === "1") {
            PopulateBillableItems();
        }
        else {
            PopulateNonBillableItems();
        }
    });

    function GetAddBillingItemSwalHTML() {
        $.get("/Orgsys_Forms/Internal_Forms/Templates/BillingManagerAddBillingItem.html", function (html) {
            AddBillingSwalHTML = html;
        });

    }
    function GetBillingCommentsSwalHTML() {
        $.get("/Orgsys_Forms/Internal_Forms/Templates/BillingManagerComments.html", function (html) {
            BillingSwallCommentsHTML = html;
        });
    }

    $(document.body).on('change', '.populateMethod', function () {
        var BillingMethodID = this.value;
        if (BillingMethodID !== '0') {
            $('.populateReason').prop("disabled", false);
            //Populate Reason
            PopulateReasonDDL(BillingMethodID);
        }
        else {
            $('.populateReason').empty();
            $('.populateReason').prop("disabled", true);
        }


    });


});
function UpdateBillingItem(BillID) {
    var billDetails = {
        BillID: BillID,
        BillDate: $('#billDate').val(),
        CompletionDate: $('#billDateClosed').val(),
        BillMethod: $('#billMethod').val(),
        BillReason: $('#billReason').val(),
        BillDuration: $('#billDuration').val(),
        DirectContact: $('#directcontact').is(":checked") ? 1 : 0,
        Postage: $('#postage').is(":checked") ? 1 : 0,
        Courier: $('#courier').is(":checked") ? 1 : 0,
        ClientID: $('#billClient').val(),
        Billable: $('#billable').is(":checked") ? 1 : 0,
        Comments: $('#billComment').val()
    };

    $.ajax({
        url: getApi + "/api/Billing/UpdateBillingItem/" + window.token,
        type: "PUT",
        async: false,
        data: '=' + encodeURIComponent(JSON.stringify(billDetails)),
        success: function (data) {
            $('#ddlBillType').trigger('change');
            swal(
                'Seccuess',
                'Bill item updated',
                'success'
            );
        }
    });
}

function PopulateEditSwal(BillID) {
    return $.ajax({
        url: getApi + "/api/Billing/GetBillingItem_ByID/" + BillID + "/" + window.token,
        async: false,
        success: function (data) {
            var BillItem = JSON.parse(data)[0];
            $('.populateBillClient').val(BillItem.ClientName);
            $(".populateEmployee").val(BillItem.AssignedTo);
            $("#billDate").val(ConvertDateIsoToCustom(BillItem.BillDate));
            $("#billDuration").val(BillItem.BillDuration);
            $('#billDateClosed').val(ConvertDateIsoToCustom(BillItem.CompletionDate));
            $(".populateMethod").val(BillItem.Method_EN);
            $(".populateUser").val(BillItem.BilledBy);
            $("#billable").prop('checked', BillItem.Billable === 1 ? true : false);
            $("#directcontact").prop('checked', BillItem.DirectContact === 1 ? true : false);
            $("#postage").prop('checked', BillItem.Postage === 1 ? true : false);
            $("#courier").prop('checked', BillItem.Courier === 1 ? true : false);
            $('.populateReason').prop("disabled", false);
            $("#billComment").val(BillItem.Comments);
            PopulateReasonDDL(BillItem.Method_EN).then(function () {
                $('.populateReason').val(BillItem.Reason_EN);
            });
        }
    });
}



function PopulateBillingSWAL(EditMode, BillID) {

    InitializeDatepicker("#billDate");
    InitializeDatepicker("#billDateClosed");

    //get lists data
    PopulateClientDDL().then(function () {
        PopulateMethodDDL();
    }).then(function () {
        if (EditMode) {
            PopulateEditSwal(BillID);
        }
    });


}

function PopulateMethodDDL() {
    $('.populateMethod ').append($('<option>').text("--Select--").attr('value', 0));
    for (i = 0; i < BillingMethods.length; i++) {
        $('.populateMethod ').append($('<option>').text(BillingMethods[i].Method_EN).attr('value', BillingMethods[i].MethodID));
    }
}
function PopulateReasonDDL(BillingMethodID) {
    return $.getJSON(getApi + "/api/Billing/GetBillingReason/" + BillingMethodID, function (data) {
        results = data;
        if ($('.populateReason').has('option').length !== 0) {
            $('.populateReason').empty();
        }
        for (i = 0; i < results.length; i++) {
            $('.populateReason').append($('<option>').text(results[i]["Reason_EN"]).attr('value', results[i]["ReasonID"]));
        }
    });
}

function PopulateClientDDL() {

    return $.ajax({
        url: getApi + "/api/DataManagement/GetClientsAssignedToUserByToken/" + window.token,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('Authentication', window.token);
        },
        async: false
    }).then(function (data) {
        results = JSON.parse(data);
        console.log(results);
        $('.populateBillClient').append($('<option>').text("--Select--").attr('value', 0));
        for (i = 0; i < results.length; i++) {
            $('.populateBillClient').append($('<option>').text(results[i]["ClientName"]).attr('value', results[i]["ClientID"]));
        }
    });
}

function GetBillingMethods() {
    return $.ajax({
        url: getApi + "/api/Billing/GetBillingMethod/",
        async: false
    }).then(function (data) {
        BillingMethods = JSON.parse(data);
    });
}

function Validate(selector) {
    var valid = true;

    $(selector).find(".validRequired").each(function () {
        if (!$(this).val() || $(this).val() === "0") {
            $(this).closest(".form-group").addClass("has-error");
            valid = false;
        } else {
            $(this).closest(".form-group").removeClass("has-error");
        }
    });
    return valid;
}



