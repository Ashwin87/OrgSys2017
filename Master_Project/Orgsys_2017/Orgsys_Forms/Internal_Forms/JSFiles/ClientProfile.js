//models

var clientModel = {
    ClientID: '',
    ClientName: '',
    TradeLegalName: '',
    BusMailingAddress: '',
    BusCity: '',
    BusCountry: '',
    BusProvince: '',
    BusPostal: '',
    BusFax: '',
    BusTelephone: '',
    BusAlternate: '',
    BusActivityDescr: '',
    FirmNumer: '',
    AccountNumber: '',
    _20MoreWorkers: '',
    IsActive: '',
    ClientStartDate: '',
    BusUnit: '',
    BusDiv: '',
    BusDept: '',
    STDWaitPeriodDays: '',
    LTDDurationWeeks: '',
    OfferedService: '',
    MainEmail: '',
    MainWebsite: ''

}


var ClientAddedModel = {
    ClientId: '',
    ClaimProcess: '',
    ClaimOther: '',
    EAPProvider: '',
    EAPName: '',
    EAPPhoneNo: '',
    EAPFax: '',
    EAPEmail: '',
    EAPExtention: '',
    SurveyCheck: '',
    SurveySpecify: '',
    SurvesTypes: '',
    SurvesTypesOther: '',
    SendSurveyTo: '',
    SendSurveySpecify: '',
    EvaluationType: '',
    ApprovedBy: '',
    Comments: ''
}

var ClientSTDLTDModel = {
    ClientId: '',
    STD_Definition: '',
    STDLength: '',
    STDLength2: '',
    STDProgramOther: '',
    STDTriggerCheck: '',
    STDTriggerSpecify: '',
    STDProcess: '',
    STDProcessOther: '',
    STDAppealsCheck: '',
    STDAppealsSpecify: '',
    STDAppealsProcess: '',
    STDRelapseDefinition: '',
    STDAppealsLength: '',
    STDAppealsLength2: '',
    STDAppealsMedicalLength: '',
    STDAppealsMedicalLength2: '',
    ExistingSTDCheck: '',
    ExistingSTDSpecify: '',
    MVAProcessCheck: '',
    MVAProcessSpecify: '',
    STDturnaroundnotificationLength: '',
    STDturnaroundnotificationLength2: '',
    STDturnaroundnotificationOther: '',
    STDturnaroundMedicalLength: '',
    STDturnaroundMedicalLength2: '',
    STDturnaroundMedicalOther: '',
    APSPackageProvider: '',
    ProvideRTWs: '',
    STDAPSFollowUpInstructions: '',
    STDNonSupportDecisionInstructions: '',
    STDCommunicationWithPayrollInstructions: '',
    STDOtherSpecificInstructions: '',
    LTDProvider: '',
    LTDPolicyNum: '',
    LTDStartdate: '',
    LTDProcess: '',
    LTDformsSenderEE: '',
    LTDformsSenderER: '',
    LTDrelapseDefinition: '',
    LTDspecificinstructions: '',
    LTDCaseManagerName: '',
    LTDCaseManagerPhone: '',
    LTDCaseManagerEXT: '',
    LTDCaseManagerEmail: '',
    LTDCaseManagerFax: ''

}

var ClientWcModel = {
    ClientId: '',
    WCProvince: '',
    WCAccount: '',
    WCEmployees: '',
    EmployerReportProvider: '',
    WCReportProviderSpecify: '',
    WCWorkDutiesProvider: '',
    WCWorkDutiesProviderSpecify: '',
    WCLegalRepresentative: '',
    WCLegalRepresentativeSpecify: '',
    WCWorkDutiesModifiedClick: '',
    WCWorkDutiesModifiedSpecify: '',
    WCJobDescriptionsClick: '',
    WCJobDescriptionsSpecify: '',
    WCProcess: '',
    ClaimstoSTDClick: '',
    ClaimstoSTDSpecify: '',
    CSSSpecificClick: '',
    CSSSpecificSpecify: '',
    ClientFinancialModelatCSST: '',
    WCCommunicationWithPayrollInstructions: ''
}

var clientContactModel = {
    ContactID: '',
    ClientID: '',
    FirstName: '',
    LastName: '',
    Title: '',
    Country: '',
    Province: '',
    Address: '',
    City: '',
    ZIP: '',
    WorkPhone: '',
    MobilePhone: '',
    Email: ''
}

/**
 * Returns a JSON array of all data or a specific row, of a datatable.
 * 
 * @param {any} tableSelector
 * @param {any} row
 */
function GetTableJSON(tableSelector, row) {

    var selector = (row === undefined) ? 'tr' : row;
    return $(tableSelector).DataTable().rows(selector).data().toArray();

}

//OPENS SWAL FORM WITH EDITABLE DATA, SAVES EDITS TO TABLES

function EditClient(rowIndex) {

    swal({
        title: "Edit Client",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Save Changes',
        html: clientTemplate,
        customClass: 'swal-wide',
        width: '850px',
        onOpen: function () {
            InitializeSwalDatepicker()
            var client = GetTableJSON('#ClientDetailsTable', rowIndex)[0]
            SetSwalData(client);
            PopulateClientSwalLists(client);
            AttachCountryEventHandler('BusCountry');
            AttachProvinceEventHandler('BusCity');
            $('[name="BusCity"]').select2();

            MaskInputs(this)
        },
        preConfirm: validate.validateSwalContentPM
    })
        .then(function () {
            UnMaskInputs(this);

            var client = GetClientSwalData()
            UpdateClient(client).then(
                function () {
                    ClientDetailsDT.row(rowIndex).data(client).draw();
                    AttachClientActionHandlers($('#ClientDetailsTable tBody > tr').eq(rowIndex));
                    $('[data-toggle="tooltip"]').tooltip()
                    swal('Client has been updated!', '', 'success')
                },
                function () {
                    swal('', 'An unknown error occured. Please try again at another time.', 'error')
                }
            );
        });

}

function EditClientContact(rowIndex) {

    swal({
        title: "Edit Client Contact",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Save Changes',
        customClass: 'swal-wide',
        html: clientContactTemplate,
        width: '850px',
        onOpen: function () {
            InitializeSwalDatepicker()
            var clientContact = GetTableJSON('#ClientContactDetailsTable', rowIndex)[0]
            SetSwalData(clientContact);
            PopulateClientContactSwalLists(clientContact);
            AttachCountryEventHandler('Province');
            AttachProvinceEventHandler('City');
            $('[name="City"]').select2();

            MaskInputs(this)
        },
        preConfirm: validate.validateSwalContentPM
    })
        .then(function () {
            UnMaskInputs(this);

            var clientContact = GetClientContactSwalData();
            UpdateClientContact(clientContact).then(
                function () {
                    ClientContactsDT.row(rowIndex).data(clientContact).draw();
                    AttachClientContactActionHandlers($('#ClientContactDetailsTable tBody > tr').eq(rowIndex));
                    $('[data-toggle="tooltip"]').tooltip()
                    MaskInputs();
                    swal('Client Contact has been updated!', '', 'success');
                },
                function () {
                    swal('', 'An unknown error occured. Please try again at another time.', 'error')
                }
            );
        });

}

function RemoveClientSwal(rowIndex) {

    var clientName = GetTableJSON('#ClientDetailsTable', rowIndex)[0].ClientName;

    swal({
        title: 'Are you sure you want to remove this client?',
        text: clientName,
        showCancelButton: true,
        cancelButtonText: 'No',
        confirmButtonText: 'Yes',
        width: '850px'
    }).then(function () {
        var client = GetTableJSON('#ClientDetailsTable', rowIndex)[0];
        RemoveClient(client).then(
            function () {
                ClientDetailsDT.rows(rowIndex).remove().draw();
                swal('Client has been removed!', '', 'success')
            },
            function () {
                swal('', 'An unknown error occured. Please try again at another time.', 'error')
            }
        );
    });

}

function RemoveClientContactSwal(rowIndex) {

    var client = GetTableJSON('#ClientContactDetailsTable', rowIndex)[0]
    var clientName = client.FirstName + ' ' + client.LastName

    swal({
        title: 'Are you sure you want to remove this contact?',
        text: clientName,
        showCancelButton: true,
        cancelButtonText: 'No',
        confirmButtonText: 'Yes',
        width: '850px'
    }).then(function () {
        var clientContact = GetTableJSON('#ClientContactDetailsTable', rowIndex)[0];
        RemoveClientContact(clientContact).then(
            function () {
                ClientContactsDT.rows(rowIndex).remove().draw();
                swal('Client Contact has been removed', '', 'success')
            },
            function () {
                swal('', 'An unknown error occured. Please try again at another time.', 'error')
            }
        );
    });

}

//OPENS SWAL FORM, ADDS NEW RECORD TO TABLE

function ClientAdded() {
    debugger;
    if (validate.validateSubmission()) {
        var client = GetClientAddedSwalData();
        var clientAdded = GetClientAddedModelSwalData();
        var ClientSTDLTD = GetClientClientSTDLTDModelSwalData();
        var ClientWc = GetClientClientWCModelSwalData();
        //var ClientContact = ClientContact;
        //if (ClientContact == undefined) {
        //    ClientContact = GetClientAddedContactModelSwalData();
        //}
        SaveClient(client).then(
            function (data) {
                clientAdded.ClientId = data.ClientID;
                SaveClientAdded(clientAdded);
                ClientSTDLTD.ClientId = data.ClientID;
                SaveClientSTDLTDAdded(ClientSTDLTD);
                ClientWc.ClientId = data.ClientID;
                SaveClientWCAdded(ClientWc);
                ClientContact.ClientID = data.ClientID;
                SaveClientContact(ClientContact);
                console.log(data);
                ClientDetailsDT.row.add(client).draw();
                var rowIndex = ClientDetailsDT.rows().indexes().length - 1;
                AttachClientActionHandlers($('#ClientDetailsTable tBody > tr').eq(rowIndex));
                $('[data-toggle="tooltip"]').tooltip();
                swal('Client has been added!', '', 'success');
                location.reload(true);
            },
            function () {
                swal('', 'An unknown error occured. Please try again at another time.', 'error');
            }
        );           //Form is valid the Client is saved in to database
    }
    else {
        var sectionsWithErrorFields = getSectionNamesWithErrorFields(); //Gets a unique list of comma delimited section names with error fields
        swal('Error!', 'Oops! You missed required field(s) from the following section(s): <br/><br/>' + sectionsWithErrorFields + '', 'error');
    }
}


//SWAL message for required Error Fields 
function getSectionNamesWithErrorFields() {
    var sectionsWithErrorFields = {
        sections: []
    };
    $(".error").each(function () {//Loops through fields with errors and adds their tab section name to an array. This will be added to a SWAL to let the user know what sections are missing required values.
        var sectionID = $(this).parents(".tab-pane").attr('id');

        var curSectionId = $("a[href='#" + sectionID + "']").first().text();

        var result = sectionsWithErrorFields.sections.filter(function (obj) { return obj.sectionName == curSectionId; })[0];
        if (result == null) {
            sectionsWithErrorFields.sections.push({
                "sectionName": curSectionId,
                "errCount": 1
            });
        } else {
            result.errCount += 1;
        }
    });

    var listItemString = "";
    for (var i = 0; i < sectionsWithErrorFields.sections.length; i++) {
        listItemString += "<li class='list-group-item' style='text-align: left;'>" + sectionsWithErrorFields.sections[i].sectionName + "<span class='badge badge-error'>" + sectionsWithErrorFields.sections[i].errCount + "</span></li>";
    }

    return "<ul class='list-group'>" + listItemString + "</ul>";
}




function AddClient() {

    swal({
        title: "Add Client",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Add Client',
        html: clientTemplate,
        customClass: 'swal-wide',
        width: '850px',
        onOpen: function () {
            InitializeSwalDatepicker()
            PopulateClientSwalLists()
            AttachCountryEventHandler('BusProvince');
            AttachProvinceEventHandler('BusCity');
            $('[name="BusCity"]').select2();

            MaskInputs(this)
        },
        preConfirm: validate.validateSwalContentPM
    })
        .then(function () {
            UnMaskInputs(this);

            var client = GetClientSwalData();
            SaveClient(client).then(
                function () {
                    ClientDetailsDT.row.add(client).draw();
                    var rowIndex = ClientDetailsDT.rows().indexes().length - 1
                    AttachClientActionHandlers($('#ClientDetailsTable tBody > tr').eq(rowIndex));
                    $('[data-toggle="tooltip"]').tooltip()
                    swal('Client has been added!', '', 'success')
                },
                function () {
                    swal('', 'An unknown error occured. Please try again at another time.', 'error')
                }
            );
        });

}

function AddClientContact() {

    swal({
        title: "Add Client Contact",
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Add Client Contact',
        html: clientContactTemplate,
        width: '850px',
        onOpen: function () {
            InitializeSwalDatepicker()
            PopulateClientContactSwalLists()
            AttachCountryEventHandler('Province');
            AttachProvinceEventHandler('City');
            $('[name="City"]').select2();

            MaskInputs(this)
        },
        preConfirm: validate.validateSwalContentPM
    })
        .then(function () {
            UnMaskInputs(this);

            var clientContact = GetClientContactSwalData()
            SaveClientContact(clientContact).then(
                function () {
                    ClientContactsDT.row.add(clientContact).draw();
                    var rowIndex = ClientContactsDT.rows().indexes().length - 1
                    AttachClientContactActionHandlers($('#ClientContactDetailsTable tBody > tr').eq(rowIndex));
                    $('[data-toggle="tooltip"]').tooltip()
                    MaskInputs();
                    swal('Client Contact has been added!', '', 'success')

                },
                function () {
                    swal('', 'An unknown error occured. Please try again at another time.', 'error')
                }
            );
        });

}

//SAVE DATA TO DB

/**
 * Saves a single client table record identified by row index
 * @param {any} rowIndex
 */

function SaveClient(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/AddClient/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}

function SaveClientAdded(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/AddedClient/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}

function SaveClientSTDLTDAdded(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/AddedClientSTDLTD/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}

function SaveClientWCAdded(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/AddedClientWC/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}

function SaveClientAdded(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/AddedClient/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}


function UpdateClient(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/UpdateClient/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}

function RemoveClient(clientJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/RemoveClient/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientJson,
        dataType: 'JSON'
    });

}

function SaveClientContact(clientContactJson) {

    //var clientContactJson = GetTableJSON('#ClientContactDetailsTable', rowIndex)[0];

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/AddClientContact/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientContactJson,
        dataType: 'JSON'
    });

}

function UpdateClientContact(clientContactJson) {

    //var clientContactJson = GetTableJSON('#ClientContactDetailsTable', rowIndex)[0];

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/UpdateClientContact/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientContactJson,
        dataType: 'JSON'
    });

}

function RemoveClientContact(clientContactJson) {

    return $.ajax({
        type: 'POST',
        url: api + '/api/Client/RemoveClientContact/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        data: clientContactJson,
        dataType: 'JSON'
    });

}


//AJAX CALLS

function GetClientProfilesJX() {

    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: api + "/api/Client/GetClientProfiles/" + token
    }).then(function (data) {
        var profiles = ReplaceDFValues(JSON.parse(data));
        for (var i = 0; i < profiles.length; i++) {
            profiles[i] = ConvertObjectIsoDatesToCustom(profiles[i]);
        }
        return profiles;
    });
}

function GetClientContactDetailsJX(clientId) {

    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: api + "/api/Client/GetClientContactDetails/" + token + '/' + clientId,
    }).then(function (data) {
        return ReplaceDFValues(JSON.parse(data));
    });
}

//function GetServiceLookup() {
//    return $.ajax({
//        type: 'GET',
//        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
//        url: api + "/api/servicecontroller/services/",
//    }).then(function (data) {
//        return ReplaceDFValues(JSON.parse(data));
//    });
//}
//RECORD ACTION EVENT HANDLERS
//each new or updated row is 're-rendered', thus handlers for actions must be added again /abovtenko

function AttachClientActionHandlers(scope) {

    scope = scope || $(document);

    scope.find('.edit-client').on('click', function () {
        var rowIndex = ClientDetailsDT.row($(this).closest('tr')).index()
        EditClient(rowIndex);
    });

    scope.find('.view-contacts').on('click', function () {

        var tr = $(this).closest('tr'); //add shown class to
        var row = ClientDetailsDT.row(tr); //show/hide child

        var lastTr = $(this).closest('table').find('tr[class*="shown"]')
        var lastRow = ClientDetailsDT.row(lastTr);

        var clientId = GetTableJSON('#ClientDetailsTable', row.index())[0].ClientID;

        if (row.child.isShown()) {
            row.child.hide();
            tr.removeClass('shown');
        }
        else {

            var contactSection = $('#ClientContactDetails');
            //a previous section was open
            if (contactSection.length > 0) {
                //close previously open section
                lastRow.child.hide()
                lastTr.removeClass('shown');

                ClientContactsDT.destroy();
                contactSection.closest('tr').remove()
            }
            //will show the client contacts table bones
            row.child(format()).show();
            InitializeClientContactsDT();
            tr.addClass('shown');

            GetClientContactDetailsJX(clientId).then(function (contacts) {
                ClientContactsDT.clear().rows.add(contacts).draw();
                AttachClientContactActionHandlers();
                $('[data-toggle="tooltip"]').tooltip();
                //
                $('.add-clientcontact').data('clientId', clientId);
                MaskInputs();
            });
        }



    });

    scope.find('.remove-client').on('click', function () {
        var rowIndex = ClientDetailsDT.row($(this).closest('tr')).index()
        RemoveClientSwal(rowIndex);
    });
}

function AttachClientContactActionHandlers(scope) {

    var scope = scope || $(document)

    scope.find('.edit-clientcontact').on('click', function () {
        var rowIndex = ClientContactsDT.row($(this).closest('tr')).index()
        EditClientContact(rowIndex);
    });

    scope.find('.remove-clientcontact').on('click', function () {
        var rowIndex = ClientContactsDT.row($(this).closest('tr')).index()
        RemoveClientContactSwal(rowIndex);
    });

}
$(document).delegate(".Library-Resources", "click", function (event) {
    var ClientID = ClientDetailsDT.row($(this).parents("tr")).data().ClientID;
    ShowCLientLibraryResourcesSwal(ClientID);
});
$(document).delegate(".UploadLibraryResource", "click", function (event) {
    if (document.querySelector('#LibraryResourceFiles').files.length === 0 || $("#ddlResourceType").val() === 0 || isNaN($("#txtVersionNumber").val())) {
        $('#fileValidation').css('visibility', 'visible');
    } else {
        var file = document.querySelector('#LibraryResourceFiles').files[0];
        UploadLibraryResource(file);
    }
});

$(document).delegate("#DownloadResource", "click", function (event) {
    var DocID = documentstable.row($(this).parents("tr")).data().Id;
    var link = document.createElement('a');
    document.body.appendChild(link);
    link.href = getApi + "/api/LibraryResources/DownloadLibraryResource/" + window.token + "/" + DocID;
    link.click();
});
$(document).delegate("#ArchiveResource", "click", function (event) {
    var DocID = documentstable.row($(this).parents("tr")).data().Id;
    swal({
        title: 'Please confirm',
        text:
            "Are you sure you want to archive this resource? have you added an updated resource?",
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        cancelButtonText: "No",
        confirmButtonText: 'Yes'
    }).then(function () {

        ArchiveLibraryResource(DocID);
    },
        function (dismiss) {
            if (dismiss === 'cancel' || dismiss === 'close') {
                swal('Not Archived', 'Library resource has not been archived', 'error');
            }
        });

});


function ArchiveLibraryResource(DocID) {
    $.ajax({
        url: api + '/api/LibraryResources/ArchiveLibraryResource/' + token + '/' + DocID,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        contentType: "application/json"
    }).then(
        function () {
            swal('', 'Library resource Archived', 'success');
        },
        function () {
            swal('', 'We could not archive the library resource at this time. Please try again later.', 'error');
        }
    );
}
//TODO: set up for administrator accounts
//$(document).delegate("#UnArchiveResource", "click", function (event) {
//    var DocID = documentstable.row($(this).parents("tr")).data().Id;
//    UnArchiveLibraryResource(DocID);
//});


//function UnArchiveLibraryResource(DocID) {
//    $.ajax({
//        url: api + '/api/LibraryResources/UnArchiveLibraryResource/' + token + '/' + DocID,
//beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
//        type: 'POST',
//        contentType: "application/json"
//    }).then(
//        function () {
//            swal('', 'Library resource UnArchived', 'success');
//        },
//        function () {
//            swal('', 'We could not Unarchive the library resource at this time. Please try again later.', 'error');
//        }
//    );
//}
function UploadLibraryResource(file) {
    var reader = new FileReader();
    var filename = file.name;
    var mimetype = file.type;
    var docExt = file.name.slice((Math.max(0, file.name.lastIndexOf(".")) || Infinity) + 1);
    reader.readAsDataURL(file);
    reader.onload = function () {
        doc = {
            DocumentName: filename,
            VersionNumber: $('#txtVersionNumber').val(),
            SpecificCLientID: $('#SwalClientID').val(),
            ResourceTypeID: $("#ddlResourceType").val(),
            Base64: reader.result.substr(reader.result.indexOf(',') + 1),
            DocExt: docExt,
            MIMEType: mimetype
        };

        $.ajax({
            url: api + '/api/LibraryResources/UploadLibraryResource/' + token,
            beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
            type: 'POST',
            data: JSON.stringify(doc),
            contentType: "application/json"
        }).then(
            function () {
                swal('', 'Library resource uploaded!', 'success');
            },
            function () {
                swal('', 'We could not upload the library resource at this time. Please try again later.', 'error');
            }
        );
    };
    reader.onerror = function (error) {
        console.log('Error: ', error);
    };
}


//GETTING AND SETTING SWAL DATA

function SetSwalData(model) {

    Object.keys(model)
        .forEach(function (key) {
            $('#swal2-content [name="' + key + '"]').val(model[key]);
        });

}

function GetClientContactSwalData() {

    var model = {};

    Object.keys(clientContactModel)
        .forEach(function (key) {
            var val = $('#swal2-content [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });

    model.ClientID = $('.add-clientcontact').data('clientId');

    return model;

}

function GetClientSwalData() {

    var model = {};
    Object.keys(clientModel)
        .forEach(function (key) {
            var val = $('#swal2-content [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });

    model._20MoreWorkers = (parseInt(model._20MoreWorkers)) ? true : false;

    return model;

}
// Saves Multiple Offered Services into the DB
function GetClientAddedSwalData() {

    let Services = '';
    var model = {};
    Object.keys(clientModel)
        .forEach(function (key) {
            var val = $('#swal2-content [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });

    var listObject = model.OfferedService;
    if (listObject != null && listObject != undefined) {
        for (var i = 0; i < listObject.length; i++) {
            Services += listObject[i] + ',';
        }
        Services = Services.substring(0, Services.length - 1);
        model.OfferedService = Services;
    }

    model._20MoreWorkers = (parseInt(model._20MoreWorkers)) ? true : false;

    return model;

}

function GetClientAddedModelSwalData() {
    debugger;
    let ServeyType = '';
    var model = {};
    Object.keys(ClientAddedModel)
        .forEach(function (key) {
            var val = $('#tab2primary [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });

    var arr = [];

    $('.Surveycustomcheckbox:checkbox:checked').each(function () {
        arr[i++] = $(this).val();
    }); 

    var arrString = arr.join(", ");
    arrString = arrString.substring(0, arrString.length - 1);
    model.SurvesTypes = arrString;

    var arr2 = [];

    $('.Sendcustomcheckbox:checkbox:checked').each(function () {
        arr2[i++] = $(this).val();
    });

    var arrString2 = arr2.join(", ");
    arrString2 = arrString2.substring(0, arrString2.length - 1);
    model.SendSurveyTo = arrString2;

    if ($('#SurveyCheckId').is(":checked")) {
        model.SurveyCheck = 'Yes';
    }
    else {
        model.SurveyCheck = 'No';
    }

    return model;

}

function GetClientAddedContactModelSwalData() {

    let Services = '';
    var model = {};
    Object.keys(clientContactModel)
        .forEach(function (key) {
            var val = $('#ClientContactSwal [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });
    return model;

}

function GetClientClientSTDLTDModelSwalData() {
    var model = {};
    Object.keys(ClientSTDLTDModel)
        .forEach(function (key) {
            var val = $('.ClientStdLtd [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });

    if ($('#STDTriggerCheckID').is(":checked")) {
        model.STDTriggerCheck = 'Yes';
    }
    else {
        model.STDTriggerCheck = 'No';
    }

    if ($('#STDAppealsCheckId').is(":checked")) {
        model.STDAppealsCheck = 'Yes';
    }
    else {
        model.STDAppealsCheck = 'No';
    }

    if ($('#ExistingSTDCheckId').is(":checked")) {
        model.ExistingSTDCheck = 'Yes';
    }
    else {
        model.ExistingSTDCheck = 'No';
    }

    if ($('#MVAProcessCheckId').is(":checked")) {
        model.MVAProcessCheck = 'Yes';
    }
    else {
        model.MVAProcessCheck = 'No';
    }
    return model;

}


function GetClientClientWCModelSwalData() {
    var model = {};
    Object.keys(ClientWcModel)
        .forEach(function (key) {
            var val = $('.ClientWc [name="' + key + '"]').val();
            model[key] = (val === undefined) ? "" : val;
        });
  

    if ($('#WCWorkDutiesModifiedClickId').is(":checked")) {
        model.WCWorkDutiesModifiedClick = 'Yes';
    }
    else {
        model.WCWorkDutiesModifiedClick = 'No';
    }

    if ($('#WCJobDescriptionsClickId').is(":checked")) {
        model.WCJobDescriptionsClick = 'Yes';
    }
    else {
        model.WCJobDescriptionsClick = 'No';
    }

    if ($('#ClaimstoSTDClickId').is(":checked")) {
        model.ClaimstoSTDClick = 'Yes';
    }
    else {
        model.ClaimstoSTDClick = 'No';
    }

    if ($('#CSSSpecificClickId').is(":checked")) {
        model.CSSSpecificClick = 'Yes';
    }
    else {
        model.CSSSpecificClick = 'No';
    }

    return model;
}

//SWAL LIST POPULATION

function PopulateClientSwalLists(client) {
    //only for client swal
    PopulateGenericList("yesno", "populateYesNo", "ListText" + LangGen, "ListValue").then(function () {
        (client) ? $('#swal2-content [name="_20MoreWorkers"]').val(client._20MoreWorkers ? 1 : 0) : ''
    })

    //for both swals /populates countries with a value
    PopulateCountries('populateCountries').then(function () {
        if (client) {
            $('.populateCountries').val(client.BusCountry)

            PopulateProvinces($('.populateCountries').val(), 'BusProvince').then(function () {
                $('.populateProvinces').val(client.BusProvince);

                PopulateCities(client.BusProvince, 'BusCity').done(function () {
                    $('.populateCities').val(client.BusCity)
                });
            });
        }
    })
}

function PopulateClientContactSwalLists(clientContact) {

    //for both swals /populates countries with a value
    PopulateCountries('populateCountries').then(function () {
        if (clientContact) {
            $('.populateCountries').val(clientContact.Country)

            PopulateProvinces($('.populateCountries').val(), 'province').then(function () {
                $('.populateProvinces').val(clientContact.Province)

                PopulateCities(clientContact.Province, 'city').done(function () {
                    $('.populateCities').val(clientContact.City)
                });
            });
        }
    })
}

function PopulateClientAddedContactSwalLists(clientContact) {

    //for both swals /populates countries with a value
    PopulateCountries('populateCountries').then(function () {
        if (clientContact) {
            $('.populateCountries').val(clientContact.Country)

            PopulateProvinces($('.populateCountries').val(), 'provincePopulate').then(function () {
                $('.populateProvinces').val(clientContact.Province)

                PopulateCities(clientContact.Province, 'cityPopulate').done(function () {
                    $('.populateCities').val(clientContact.City)
                });
            });
        }
    })
}


//should be elsewhere
function AttachCountryEventHandler(provinceFieldName) {
    $('.populateCountries').on('change', function () {
        $('.populateProvinces').empty();
        $('select.populateProvinces').append('<option>Select</option>')
        PopulateProvinces($(this).val(), provinceFieldName)
    })
}

function AttachProvinceEventHandler(cityFieldName) {
    $('.populateProvinces').on('change', function () {
        $('.populateCities').empty();
        $('.populateCities').append('<option>Select</option>')
        PopulateCities($(this).val(), cityFieldName)
    })
}

function InitializeClientContactsDT() {
    window.ClientContactsDT = $('#ClientContactDetails > table').DataTable({
        sDom: '<"top"><"bottom"><"clear">',
        columns: [
            {
                data: null,
                render: function (data, type, row) {

                    var html = '';
                    var buttons = $('<div><a class="edit-client view_description btn btn-default" title="Edit Contact"><i class="icon icon-edit1"></i></a><a class="removeUser btn btn-danger" title="Delete Contact"><i class="icon icon-bin"></i></a><div>').find('a');

                    buttons.addClass('btn btn-default');
                    buttons.attr('data-toggle', 'tooltip');
                    buttons.each(function () {
                        html += $(this).get(0).outerHTML;
                    });

                    return html;
                }
            },
            { data: 'FirstName' },
            { data: 'LastName' },
            { data: 'Title' },
            { data: 'Country' },
            { data: 'Province' },
            { data: 'Address' },
            { data: 'City' },
            { data: 'ZIP' },
            {
                data: 'WorkPhone',
                render: function (data) {
                    return '<span class="vld-phone">' + data + '</span>'
                }
            },
            {
                data: 'MobilePhone',
                render: function (data) {
                    return '<span class="vld-phone">' + data + '</span>'
                }
            },
            {
                data: 'Email',
                render: function (data) {
                    return '<span class="vld-email">' + data + '</span>'
                }
            }
        ]

    });

    MaskInputs();

    //ATTACH BUTTON EVENT HANDLERS  
    $('.add-clientcontact').on('click', function () {
        AddClientContact();
    });

}

function ShowCLientLibraryResourcesSwal(ClientID) {
    swal({
        title: "LibraryResources",
        html: LibraryResourcesTableHTML,
        showCancelButton: true,
        showConfirmButton: false,
        defaultStyling: false,
        width: '1000px',
        height: '1000px',
        cancelButtonText: 'Close',
        onOpen: function () {
            GetLibraryResources(ClientID);
            GetLibraryResourceTypes();
        }
    });
}

var documentstable;
function GetLibraryResources(ClientID) {
    $('#SwalClientID').val(ClientID);
    $.ajax({
        url: getApi + "/api/LibraryResources/GetLibraryResourcesInternal/" + window.token + "/" + ClientID,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function (data) {
            var resources = JSON.parse(data);
            documentstable = $('#LibraryResources').DataTable({
                select: false,
                data: resources,
                "order": [[4, "asc"]],
                "sPaginationType": "full_numbers",
                "rowId": "Id",
                "columns": [
                    { "data": "" }, { "data": "DocumentName" }, { "data": "VersionNumber" }, { "data": "TypeName" }, { "data": "IsArchived" }],
                "columnDefs": [{
                    "targets": -5, "data": null, "searchable": false, "orderable": false,
                    render: function (a, b, data, d) {
                        if (data.IsArchived === "Yes") {
                            //return "<a id='UnArchiveResource' data-toggle='tooltip' title='UnArchive Resource' class=' btn btn-default'><i class='glyphicon glyphicon-ok'></i></a>";
                            return "<a id='DownloadResource' data-toggle='tooltip' title='Download library resource' class=' btn btn-default'><i class='glyphicon glyphicon-download-alt'></i></a>";

                        }
                        else {
                            return "<a id='DownloadResource' data-toggle='tooltip' title='Download library resource' class=' btn btn-default'><i class='glyphicon glyphicon-download-alt'></i></a><a id='ArchiveResource' data-toggle='tooltip' title='Archive Resource' class=' btn btn-default'><i class='glyphicon glyphicon-trash'></i></a>";
                        }
                    }
                }]
            });
        }, function () {
            alert("$.get failed!");
        }
    );
}
function GetLibraryResourceTypes() {
    $.ajax({
        url: getApi + "/api/LibraryResources/GetLibraryResourceTypes/",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(
        function (data) {
            var Types = JSON.parse(data);
            $("#ddlResourceType").append('<option value=' + 0 + '>' + "--Select--" + '</option>');
            for (var i = 0; i < Types.length; i++) {
                $("#ddlResourceType").append('<option value=' + Types[i].ResourceTypeId + '>' + Types[i].TypeName + '</option>');
            }


        }, function () {
            alert("$.get failed!");
        }
    );
}

$(document).on('change', '#UploadLogo', function () {
    DEBUG('logo uploading')
    var files = $(this).prop('files');
    if (files.length > 0) {
        if (validate.isValidImage(files[0])) {
            SaveClientLogo(files[0]);
        }
        else {
            swal('', 'The file you are trying to upload has an invalid extesion. Only files that end with a .jpg or .png are allowed.', 'error');
        }
    }
});

function SaveClientLogo(image) {
    DEBUG('Upload files : start')

    var formData = new FormData()
    formData.append(image.name, image, image.name);

    return $.ajax({
        url: api + '/api/Files/UploadClientLogo/' + token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: 'POST',
        data: formData,
        contentType: false,
        processData: false
    }).then(
        function () {
            swal('', 'Client Logo Updated!', 'success')
        },
        function () {
            swal('', 'We could not update your logo at this time. Please try again later.', 'error')
        }
    )
}



function format(d) {
    return `
<div id="ClientContactDetails">
    <div>
        <button type="button" class="btn btn-default add-clientcontact add-client">
            <i class="icon-plus"></i>
        </button>
    </div>
    <table id="ClientContactDetailsTable" class="table table-condensed table-hover">
        <thead>
            <tr>
                <th>Actions</th>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Title</th>
                <th>Country</th>
                <th>Province / State</th>
                <th>Address</th>
                <th>City</th>
                <th>Postal Code</th>
                <th>Work Phone</th>
                <th>Mobile Phone</th>
                <th>Email</th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
</div>`;
}


//SWAL TEMPLATES

var clientTemplate =
    `<div id="ClientSwal" class="container client_profile_container">
        <hidden name="ClientID"></hidden>
        <div class="row">
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Company Name</label>
                <input type="text" class="form-control required client_profile_textarea" name="ClientName" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Trade / Legal Name</label>
                <input type="text" class="form-control required client_profile_textarea" name="TradeLegalName" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Country</label>
                <select class="form-control populateCountries required client_profile_textarea" name="BusCountry"></select>
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Province / State</label>
                <select class="form-control populateProvinces required client_profile_textarea" name="BusProvince" ></select>
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">City</label>
                <select class="form-control populateCities required client_profile_textarea" name="BusCity" ></select>
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Mailing Address</label>
                <input type="text" class="form-control required client_profile_textarea" name="BusMailingAddress" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Postal Code</label>
                <input type="text" class="form-control vld-postal vlda-BusCountry required client_profile_textarea" name="BusPostal" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Phone</label>
                <input type="text" class="form-control vld-phone required client_profile_textarea" name="BusTelephone" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Fax</label>
                <input type="text" class="form-control vld-phone client_profile_textarea" name="BusFax" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Activity Description</label>
                <input type="text" class="form-control required client_profile_textarea" name="BusActivityDescr" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Has 20 Or More Workers?</label>
                <select class="form-control populateYesNo client_profile_textarea" name="_20MoreWorkers"></select>
            </div>            
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">Start Date</label>
                <input type="date" class="form-control client_profile_textarea" name="ClientStartDate" />
            </div>
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">STD Wait Period Weeks</label>
                <input type="text" class="form-control client_profile_textarea" name="STDWaitPeriodDays" />
            </div>  
            <div class="col-md-4 form_field_setter margin-bottom">
                <label class="form_label_setter">LTD Duration Weeks</label>
                <input type="text" class="form-control client_profile_textarea" name="LTDDurationWeeks" />
            </div>  
        </div>   
    </div>`;

var clientContactTemplate =
    `<div id="ClientContactSwal" class="container client_profile_container">
        <hidden name="ClientID"></hidden>
        <hidden name="ContactID"></hidden>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">First Name</label>
            <input type="text" class="form-control required" id="firstname" name="FirstName" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Last Name</label>
            <input type="text" class="form-control required" id="lastname" name="LastName" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Title</label>
            <input type="text" class="form-control required" id="title" name="Title" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Country</label>
            <select class="form-control populateCountries1 required" id="country" name="Country" ></select>
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Province / State</label>
            <select class="form-control populateProvinces required" id="provincePopulate" name="Province" ></select>
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">City</label>
            <select class="form-control populateCities required" id=cityPopulate name="City" ></select>
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Address</label>
            <input type="text" class="form-control" id="address" name="Address" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Postal Code</label>
            <input type="text" class="form-control vld-postal vlda-Country" id="zip" name="ZIP" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Work Phone</label>
            <input type="text" class="form-control required vld-phone" id="workphone" name="WorkPhone" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Cell Phone</label>
            <input type="text" class="form-control required vld-phone" id="mobilephone" name="MobilePhone" />
        </div>
        <div class="col-md-4 form_field_setter margin-bottom">
            <label class="form_label_setter">Email</label>
            <input type="text" class="form-control vld-email required" id="email" name="Email" />
        </div>
    </div>`;

var LibraryResourcesTableHTML =
    `<div class="text-left">  
    <div class="row" style="visibility:hidden;" id="fileValidation">
        <div class="col-md-12">
            <div class="alert alert-danger" role="alert">
                Please select a document, Document type and a version number.
            </div>
        </div>
    </div>
    <div class="row well">
        <div class="col-md-4">
            <label for="LibraryResourceFiles">Upload a file</label>
            <input type="file" id="LibraryResourceFiles" name="LibraryResourceFiles" >
        </div>
        <div class="col-md-4">
            <label for="ddlResourceType">Select a Library Resource Type</label>
            <select data-toggle="tooltip" title="Select a Library Resource Type" class="form-control" name="LibraryType" id="ddlResourceType"></select>
        </div>
        <div class="col-md-2">
            <label for="txtVersionNumber">Version number</label>
            <input type="text" class="form-control" id="txtVersionNumber" value="1"/>
        </div>
        <div class="col-md-2">
            <label>Upload Resource</label>
            <input type="button" class="btn btn-success UploadLibraryResource" value="Upload"/>
        </div>
    </div>
    <input type="hidden" id="SwalClientID" name="SwalClientID" value="">
    <table style="width: 100%;" id="LibraryResources" class="table table-bordered table-striped table-hover dataTable no-footer">
                        <thead>
                            <tr>
                                <th style="width: 20px">Actions</th>
                                <th style="width: 20px">Resource Name</th>
                                <th style="width: 20px">Resource Version</th>
                                <th style="width: 10px">Resource Type</th>
                                <th style="width: 10px">Is Archived</th>
                            </tr>
                        </thead>
                    </table></div>`;

