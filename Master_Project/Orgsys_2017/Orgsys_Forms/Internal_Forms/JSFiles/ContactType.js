
$(document).ready(function () {
    //if (ClaimID) {
        PopulateEmployeeContacts('tblEmployee');
    //}
});

//It populates Employee Contacts
function PopulateEmployeeContacts(tableName) {
   
    var employee;
    if (ClaimID) {
        $.ajax({
            url: getApi + "/api/DataBind/GetEmployeeContacts/" + token + "/" + ClaimID,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            async: false,
            success: function (data) {
                employee = JSON.parse(data);
            }
        })
    }

    $('#' + tableName).DataTable({
        select: true,
        data: employee,
        "columns": [
            {
                data: null,
                render: function () {
                    return `
                    <a class="btn btn-default editEmployee edit_button" title="Edit Employee" data-toggle="tooltip"><i class="icon icon-pencil"></i></a>
                    <a class="btn btn-default deleteEmployeeContact btn-danger" title="Delete Employee" data-toggle="tooltip"><i class="icon icon-bin"></i></a>`;
                }
            },
            { "data": "ContactType" },
            {
                data: null,
                render: function (data, type, row) {
                    //add masking class for appropriate type .abovtenko
                    var classAttribute = (/(Phone|Fax)/g.test(data.ContactType)) ? 'vld-phone' : '';
                    return '<span class="' + classAttribute + '">' + data.ContactDetail + '</span>';
                } 
            },
            { "data": "Ext" },
            { "data": "PriorityOrder" },
            { "data": "PreferredTOD" }
        ]
    });

    MaskInputs();

}

function CreateEmployeeContact(tblName) {
    GetList('GetList_ContactType', 'populateEmpContactType', 'ContactType_En');
    GetList("GetList_Order", "populateOrder", "Desc_EN");
    var employeeTemplate = `
    <div class="row margin_bottom dialogbox_container">
        <div class ="col-sm-3 dialogbox_form">
            <label for="contactName" class="dialogbox_form_label">Contact Type</label>
            <select class="required form-control populateEmpContactType dialogbox_form_input" name="contactType"  id="ContactType"></select>
        </div>
        <div class="col-sm-2 dialogbox_form">
            <label class="dialogbox_form_label">Contact Detail</label>
            <input type="text" class="required form-control dialogbox_form_input" name="contactDetail" id="ContactDetail" />
        </div>
        <div class="col-sm-2 dialogbox_form">
            <label class="dialogbox_form_label">Ext(if apply):</label>
            <input type="text" class="form-control vld-number dialogbox_form_input" name="ext"  id="Ext" />
        </div>
        <div class="col-sm-2 dialogbox_form">
            <label class="dialogbox_form_label">Priority Order:</label>
            <select class ="form-control populateOrder dialogbox_form_input" name="priorityOrder" id="PriorityOrder"></select>
        </div>
        <div class ="col-sm-2 dialogbox_form">
            <label class="dialogbox_form_label">Preffered TOD:</label>
            <input type="text" class ="form-control dialogbox_form_input" name="preferredTOD" id="PreferredTOD" />
        </div>
   </div>`
    swal({
        title: "Add Employee Contact",
        text: "",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Add Contact',
        html: employeeTemplate,
        width: '850px',
        onOpen: function () {
            //mask phone if selected
            MaskContactDetail();
        },
        preConfirm: validate.validateSwalContentPM
    }).then(function (isConfirm) {
        if (isConfirm) {
            var table = $('#' + tblName).DataTable();
            var contact = {
                ContactType: $('#ContactType').val(),
                ContactDetail: $('#ContactDetail').val(),
                Ext: $('#Ext').val(),
                PriorityOrder: $('#PriorityOrder').val(),
                PreferredTOD: $('#PreferredTOD').val()
            }

            table.row.add(contact).draw();
            SetDataDT('#tblConEmployee', table.data());
            swal("", "Employee Contact has been added", "success");
        }
    }, function (dismiss) {
        swal("Cancelled", "Not Added", "error");
    });
}

//Delete an employee contact record from the datatable
$(document).on('click', '.deleteEmployeeContact', function () {
    DeleteRecordSwalDT('#tblEmployee', 'Employee Contact', $(this)).then(function (table) {
        if (table) SetDataDT('#tblConEmployee', table.data());
    });
});

//It Edits an Employee
$(document).on('click', '.editEmployee', function () {
    var table = $('#tblEmployee').DataTable();
    var index = table.row($(this).closest('tr')).index()
    var data = table.rows(index).data();

    GetList('GetList_ContactType', 'populateContactType_Edit', 'ContactType_En').done(function () {
        $('.populateContactType_Edit').val(data[0]["ContactType"]).trigger('change')
    });
    GetList("GetList_Order", "populateOrder", "Desc_EN").done(function () {
        $('.populateOrder').val(data[0]['PriorityOrder'])
    });
    
    var editEmployeeTemplate = '<div>' +
  '<div class="row margin_bottom dialogbox_container">' +
      '<div class="col-sm-3 dialogbox_form">' +
          '<label class="dialogbox_form_label">Contact Type</label>' +
          '<select type="text" class="required form-control populateContactType_Edit dialogbox_form_input" name="contactType" id="ContactType">' +
          '</select>' +
      '</div>' +
      '<div class ="col-sm-2 dialogbox_form">' +
          '<label class="dialogbox_form_label">ContactDetail</label>' +
          '<input type="text" class=" required form-control dialogbox_form_input" name="contactDetail"  value="' + data[0]["ContactDetail"] + '" id="ContactDetail" />' +
      '</div>' +
             '<div class="col-sm-2 dialogbox_form">' +
          '<label class="dialogbox_form_label">Ext</label>' +
          '<input type="text" class="form-control dialogbox_form_input" name="Ext" id="Ext" value="' + data[0]["Ext"] + '" />' +
      '</div>' +
           '<div class="col-sm-2 dialogbox_form">' +
          '<label class="dialogbox_form_label">PriorityOrder</label>' +
          '<select class="form-control populateOrder dialogbox_form_input" name="priorityOrder"  id="PriorityOrder" ></select>' +
      '</div>' +
      '<div class="col-sm-2 dialogbox_form">' +
          '<label class="dialogbox_form_label">PreferredTOD</label>' +
          '<input type="text" class="form-control dialogbox_form_input" name="preferredTOD"  id="PreferredTOD" value="' + data[0]["PreferredTOD"] + '" />' +
      '</div>' +
        '</div>' +
       '</div>'

    swal({
        title: 'Edit Employee Contact',
        text: 'Are you sure, you want to Edit Employee contact',
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Edit',
        html: editEmployeeTemplate,
        width: '850px',
        onOpen: function () {
            //masking on change
            MaskContactDetail();
        },
        preConfirm: validate.validateSwalContentPM
    }).then(function (isConfirm) {
        if (isConfirm) {
            var empContact = {
                ContactType: $('#ContactType').val(),
                ContactDetail: $('#ContactDetail').val(),
                Ext: $('#Ext').val(),
                PriorityOrder: $('#PriorityOrder').val(),
                PreferredTOD: $('#PreferredTOD').val()
            };            

            table.row(index).data(empContact).draw();
            SetDataDT('#tblConEmployee', table.data());           
        }
        else {
            swal("Cancelled", "Not Edited", "error");
        }
    });
        
});

//Masks contact details and adds relevant validation identifier.
function MaskContactDetail() {
    $('#ContactType').on('change', function () {
        var detail = $('#ContactDetail');
        DEBUG('contact type changed. value : ' + this.value)
        //remove existing mask and validators
        if (detail.data('mask')) {
            detail.unmask()
            detail.removeClass('vld-email vld-phone');
        }

        //apply mask and classes
        if (/Phone/.test(this.value)) {
            DEBUG('masking phone')
            MaskPhone($('#ContactDetail'));
            detail.addClass('vld-phone required form-control')
        }
        else if (/Email/.test(this.value)) {
            DEBUG('masking email')
            detail.addClass('vld-email required form-control');
        }
    });
    $('#ContactType').trigger('change');
}

