//default JSON for Primary Incident
const PrimaryIncidentModel = {
    EmpPremise: "",
    ICDCMID: "",
    IncidentDesc: "",
    Location: "",
    collateralDamages: [],
    correctiveActions: [],
    icdcmCategory: [],
    limitationDetails: [],
    witnesses: []
};

//default JSON for ICDCM Category
const IcdcmCategoryModel = {
    CatICDCM: 0,
    CatID: 0,
    Category: "",
    CategoryID:"",
    DDGAvg: "",
    DDGMax: "",
    DDGMin: "",
    Description: "",
    Diagnosis: "",
    DiagnosisID: "",
    categoryActivities: [],
    categoryBodyParts: [],
    categoryDiagnosis: [],
    categoryMedications: [],
    categoryCause: {}
};

//A custom function to left merge two objects
function leftMergeTwoObjects(leftObject, rightObject) {
    const res = {};
    for (const p in leftObject)
        res[p] = (p in rightObject ? rightObject : leftObject)[p];
    return res;
}

function createObjectArrayByObjectModel(rows, objectModel) {
    let objectArray = [];
    rows.each(function (row, index) {
        let object = Object.assign({}, objectModel);
        $.each(object, function (key, value) {
            object[key] = row[key];
        });
        objectArray.push(object);
    });

    return objectArray;
}

//compiles a json for all of the incidents
function compileIncidentJSON() {
    const getIncidents = GetIncidentSection("GetIncidentDetails");
    //Witnesses section
    const getWitnesses = GetIncidentSection("GetICDCMWitness");
    //limitations section
    const getLimitations = GetIncidentSection("GetICDCMLimitation");
    //corrective actions section
    const getCorrectiveActions = GetIncidentSection("GetICDCMCorAction");
    //collateral damage and all of its sub categorys
    const getCollateralDamages = GetIncidentSection("GetICDCMDamage");
    const getColAnimal = GetIncidentSection("GetICDCMCColAni");
    const getColProperty = GetIncidentSection("GetICDCMCColProp");

    //Loads ICDCM Category and all of it's sub-categorys
    const getIcdcmCategories = GetIncidentSection("GetICDCMCategory");
    const getCategoryBodyParts = GetIncidentSection("GetICDCMCatPart");
    const getCategoryDiagnosis = GetIncidentSection("GetICDCMCatDia");
    const getCategoryActivities = GetIncidentSection("GetICDCMCatAct");
    const getCategoryMedications = GetIncidentSection("GetICDCMMedication");
    const getCategoryCause = GetIncidentSection("GetICDCMCatCause");
    //initialize object array for incidents
    let IncidentJSON = {
        incidents: []
    };

    if (getIncidents.length === 0) {
        IncidentJSON.incidents.push(PrimaryIncidentModel);
    }
    const incidents = getIncidents.map(incident => {
        let primaryIncident = { ...PrimaryIncidentModel, ...incident };

        primaryIncident.witnesses = getWitnesses.filter(witness => witness.WitnessICDCM === incident.ICDCMID);
        primaryIncident.correctiveActions = getCorrectiveActions.filter(action => action.CorICDCM === incident.ICDCMID);
        primaryIncident.limitationDetails = getLimitations.filter(limit => limit.LimitationICDCM === incident.ICDCMID);

        const damagesByType = [...getColAnimal, ...getColProperty];
        primaryIncident.collateralDamages = getCollateralDamages
            .filter(damage => damage.DamageICDCM === incident.ICDCMID)
            .map(damage => {
                return { ...damage, data: damagesByType.find(damageType => damageType.CollateralID === damage.CollateralID) };
            });

        const icdcmCategories = getIcdcmCategories.filter(category => category.CatICDCM === incident.ICDCMID).map(category => {
            let icdcmCategory = { ...IcdcmCategoryModel, ...category };
            icdcmCategory.categoryBodyParts = getCategoryBodyParts.filter(bodyPart => bodyPart.CatID === category.CatID);
            icdcmCategory.categoryActivities = getCategoryActivities.filter(activity => activity.CatID === category.CatID);
            icdcmCategory.categoryMedications = getCategoryMedications.filter(medication => medication.CatID === category.CatID);
            icdcmCategory.categoryDiagnosis = getCategoryDiagnosis.filter(diagnosis => diagnosis.CatID === category.CatID);
            icdcmCategory.categoryCause = { ...getCategoryCause[0] };
            icdcmCategory.EnvironmentFactors = [];
            icdcmCategory.EquipmentInvolved = [];
            icdcmCategory.HumanFactor = [];
            icdcmCategory.InjuryLocation = [];
            icdcmCategory.WeatherCondition = [];

            //claims from portal do not have these values /abovtenko
            icdcmCategory.DiagnosisID = icdcmCategory.DiagnosisID || 0
            icdcmCategory.CategoryID = icdcmCategory.CategoryID || 0

            return icdcmCategory;
        });

        primaryIncident.icdcmCategory = icdcmCategories;
        return primaryIncident;
    });
    IncidentJSON.incidents.push(...incidents);
    return IncidentJSON;
}

const getCauseListSelectedValues = (listName, causeId) => {
    let values = [];
    if (!causeId)
        return values;
    
    $.ajax({
        url: `${window.getApi}/api/Incident/${listName}/${causeId}`,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        dataType: 'json',
        async: false,
        success: function (response) {
            values = JSON.parse(response);
        }
    });
    return values;
};

$(document).ready(function () {
    //If there is a claim to be loaded, load all templates and initialize controls corresponding to the claim. If there is not, load a incident default incident template
    const compiledIncidentSection = compileIncidentJSON();
    loadIncidents(compiledIncidentSection);

    handleTabSwitch("#incidentDetailsTabs", "#witness-details-tab-body_0");

    //Adds a new tab to the main incident and loads controls for the section as well
    $("button[data-id='addICDCMCategoryTab']").on("click", function () {
        let IcdcmCategoryObject = { ...IcdcmCategoryModel };
        const PrimaryIncidentID = $(this).attr("data-primaryincidentid") ? $(this).attr("data-primaryincidentid") : 0;
        const DiagnosisSelectData = $("#selectDiagnosis_" + PrimaryIncidentID).select2("data");
        const CategorySelectData = $("#selectIcdcmCategory_" + PrimaryIncidentID).select2("data");

        IcdcmCategoryObject["DiagnosisID"] = DiagnosisSelectData[0].id;
        IcdcmCategoryObject["Diagnosis"] = DiagnosisSelectData[0].text;
        IcdcmCategoryObject["CategoryID"] = CategorySelectData[0].id;
        IcdcmCategoryObject["Category"] = CategorySelectData[0].text;

        $("#ICDCMCategoryTabs_" + PrimaryIncidentID).prepend(loadIcdcmTabs([IcdcmCategoryObject]));
        $("#ICDCMCategorys_" + PrimaryIncidentID).append(loadIcdcmTabPaneTemplate([IcdcmCategoryObject]));
        createICDCMCategoryPaneControls(DiagnosisSelectData[0].id, IcdcmCategoryObject);
        $(`#ICDCMCategoryTabPane_${DiagnosisSelectData[0].id}`).find('select').select2();
    });

    //dynamic event handlers for adding a row to a table
    $("div[id='IncidentDetailsWrapper']").on("click", "button[id*='AddRowModal']", function () {
        //Gets table related to the button clicked and stores the ID
        var tableId = $(this).attr("data-tableid");
        var addEditModalBody = $("#AddEditModal").find(".modal-body")[0];

        $(addEditModalBody).html($("#" + $(this).attr("data-modaltemplateid")).html());
        InitializeDatepicker($(addEditModalBody).find('input[type="date"]'));

        $("#AddRow").attr("data-tableid", tableId);
        $("#AddEditModal").modal("show");
        $("#AddRow").show();
        $("#EditRow").hide();
    });

    $("div[id='IncidentDetailsWrapper']").on("click", "#AddRow", function () {
        var tableId = $(this).attr("data-tableid");
        var formFields = $("#AddEditModal").find(".form-control");
        var IncidentSectionDataTable = $(tableId).DataTable();
        var rowAddition = {};

        //Will have to include type of formField in the future
        formFields.each(function () {
            rowAddition[$(this).attr("data-id")] = $(this).val();
        });
        IncidentSectionDataTable.row.add(rowAddition).draw();

        $("#AddEditModal").modal('hide');
        $.notify({
            message: 'You\'ve added a row!'
        }, {
                type: 'success'
            });
    });

    //click handler for the button with data-id of 'EditRow'. This handler pops up a modal to edit a row to the relative table
    $("div[id='IncidentDetailsWrapper']").on("click","button[id*='EditRowModal']",function () {
        var IncidentSectionModalForm = $("#AddEditModal").find(".modal-body")[0];
        var tableId = $(this).attr("data-tableid");
        var IncidentSectionDataTable = $(tableId).DataTable();

        $(IncidentSectionModalForm).html($("#" + $(this).attr("data-modaltemplateid")).html());

        var formSelects = $("#AddEditModalBody").find("select[class='form-control']");
        var formFields = $("#AddEditModalBody").find(".form-control").not("select");
        var rowSelected = $(tableId + " .selected");


        //Loading values with the data provided from the DataTable
        var data = IncidentSectionDataTable.row(rowSelected).data();
        //Setting the values for specifically Dropdowns and triggering a change event for functionality
        formSelects.each(function () {
            $(this).val(data[$(this).attr("data-id")]);
            $(this).change();
        });

        //I need to inlude field type in the future. For select, checkboxes, etc. It loads data from the selected row into the modal form based on fieldIDs and json name/value pairs
        formFields.each(function (field) {
            //Sets the value of the field according to the JSON provided by the datatables row
            $(this).val(data[$(this).attr("data-id")]);
        });

        //Sets the edit row buttons ID to the proper table id to edit
        $("#EditRow").attr("data-tableid", tableId);

        $("#AddEditModal").modal("show");
        $("#AddRow").hide();
        $("#EditRow").show();
    });
    $("div[id='IncidentDetailsWrapper']").on("click","#EditRow", function () {
        var tableId = $(this).attr("data-tableid");
        var formFields = $("#AddEditModal").find(".form-control");
        var rowSelected = $(tableId + " .selected");
        var IncidentSectionDataTable = $(tableId).DataTable();
        var rowEdited = {};
        formFields.each(function () {
            rowEdited[$(this).attr("data-id")] = $(this).val();
        });
        IncidentSectionDataTable.row(rowSelected).data(rowEdited).draw();

        $("#AddEditModal").modal('hide');
        $.notify({
            message: 'You\'ve edited a row!'
        }, {
                type: 'success'
            });
    });
    //event handler for when remove row is clicked
    $("div[id='IncidentDetailsWrapper']").on("click","button[id*='RemoveRowModal']", function () {
        var tableId = $(this).attr("data-tableid");
        var dataTable = $(tableId).DataTable();
        var rowSelected = $(tableId + " .selected");
        swal({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, delete it!'
        }).then(function () {
            dataTable.row(rowSelected).remove().draw();
            swal('Deleted!', 'Row has been deleted', 'success');
        });
    });

    $('#IncidentDetailsWrapper').find('select').select2();
});

//loads the incident details section
function loadIncidents(compiledIncidentSection) {
    //first time loading claim
    compiledIncidentSection.incidents.forEach((incident, incidentID) => {
        PopulateGenericList("WorkIssues", "populateWorkIssues", "ListText", "ListValue")
        $("#IncidentDetailsWrapper").append(incidentTemplate(incident, incidentID));
        //creates tables for each primary incident sections
        $("#primaryIncident_" + incidentID).find("table[data-section='primaryIncident']").each(function () {
            initializeDataTable($(this).attr("id"), $(this).attr("data-propertyname"));
            renderDataTableData($(this).attr("id"), incident[$(this).attr("data-propertyname")]);
        });
        //Initializes select2 for every incidents "Add Diagnosis/ICDCM Category" Modal
        initSelect2("#selectDiagnosis_" + incidentID, GetListForIncident("GetList_Diagnosis"), "");
        initSelect2("#selectIcdcmCategory_" + incidentID, GetListForIncident("GetList_InjuryCategories"), "");
        
        //loads corresponding icdcm categories for the incident
        loadICDCMCategoriesControls(incident,incidentID);
    });
}

//takes a select inputs data atribute of data-sectionname and toggles the class 'hidden'.
function showHideBasedOnSelect(dropdownElement) {
    //shows the section by removing the class hidden on the selected element
    $("[data-id='" + $(dropdownElement.find("option:selected")[0]).attr("data-sectionname") + "']").removeClass("hidden");

    //loops through all the options not selected and hides their corresponding section
    dropdownElement.find("option:not(:selected)").each(function () {
        $("[data-id='" + $(this).attr("data-sectionname") + "']").addClass("hidden");
    });
}

//loads ICDCMCategories for specific incident
function loadICDCMCategoriesControls(incident, incidentID) {
    //creates a table for all the icdcmCategorys in the current incident
    $(`#primaryIncident_${incidentID}`).find("[id*='ICDCMCategoryTabPane']").each(function () {
        const DiagnosisID = $(this).attr("data-icdcmCategoryID");
        const categoryData = incident.icdcmCategory.find(category => category.DiagnosisID == DiagnosisID);
        createICDCMCategoryPaneControls($(this).attr("data-icdcmCategoryID"), categoryData);
    });
}
//creates a ICDCMCategorypane
function createICDCMCategoryPaneControls(DiagnosisID, icdcmCategoryData) {
    //creates data tables for every category
    $("#ICDCMCategoryTabPane_" + DiagnosisID).find("table[data-section='icdcmCategory']").each(function () {
        initializeDataTable($(this).attr("id"), $(this).attr("data-propertyname"));
        renderDataTableData($(this).attr("id"), icdcmCategoryData[$(this).attr("data-propertyname")]);
    });
    //initializes select 2 for every ICDCM category with the proper options selected
    initSelect2("#Diagnosis_" + DiagnosisID, GetListForIncident("GetList_Diagnosis"), icdcmCategoryData["DiagnosisID"]);
    initSelect2("#Category_" + DiagnosisID, GetListForIncident("GetList_InjuryCategories"), icdcmCategoryData["CategoryID"]);
}

const renderListOptions = (endPoint, causeId, listName) => {
    let options;
    let selectedOptions = getCauseListSelectedValues(listName, causeId);
    $.ajax({
        url: `${window.getApi}/api/DataBind/${endPoint}`,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        dataType: 'json',
        async:false,
        success: function (response) {
            let list = JSON.parse(response);

            options = list.map(item => `<option value='${item.index}' ${selectedOptions.find(element => element === item.index) ? 'selected' : ''}>${item.Desc_EN}</option>`).join('');
        }
    });
    return options;
};

//initializes the select 2 plugin with data provided
function initSelect2(selectID, data, optionSelected) {
    $(selectID).select2({
        width: "100%",
        placeholder: 'Select an option',
        data: data
    });

    $(selectID).val(optionSelected).trigger('change');
}

//A list of column structures for each datatable in incident details. Used for dynamic generation of tables.
const dataTableColumnStructureMeta = {
    witnesses: [{ title: "Full Name", data: "WitnessName" }, { title: "Phone Number", data: "WitnessPhone" }, { title: "Email", data: "WitnessEmail" }, { title: "Statement", data: "WitnessStatement" }],
    collateralDamages: [{ title: "Damage Type", data: "DamType" }, { title: "Reason", data: "DamReason" }],
    correctiveActions: [{ title: "JHSCM", data: "JHSCM" }, { title: "Start Date", data: "CorrDateTime" }, { title: "Description", data: "CorrDescription" }, { title: "Reason", data: "CorrReason" }],
    limitationDetails: [{ title: "Start Date", data: "LimitDateTime" }, { title: "Description", data: "LimitDescription" }],
    categoryActivities: [{ title: "Start Date", data: "ActTime" }, { title: "Description", data: "ActDescription" }],
    categoryBodyParts: [{ title: "Body Part", data: "BodyPart" }, { title: "Body Part Side", data: "PartSide" }, { title: "Description", data: "PartDescription" }],
    categoryMedications: [{ title: "Name", data: "MedName" }, { title: "Reason", data: "MedReason" }]
};
function initializeDataTable(tableId, jsonPropertyName) {
    const dataColumnStructure = dataTableColumnStructureMeta[jsonPropertyName];
    // In order to have dynamic tables we need to generate headers for said table
    dataColumnStructure.forEach(column => $(`#${tableId} > thead > tr `).append(`<th>${column.title}</th>`));

    $(`#${tableId}`).DataTable({
        select: true,
        lengthChange: false,
        pageLength: 5,
        columns: dataColumnStructure,
        columnDefs: [
            { "width": "10%", "targets": 0 }
        ]
    });
}
//loads data into a data table and re draws
function renderDataTableData(tableId, data) {
    $(`#${tableId}`).DataTable().clear().rows.add(data).draw();
}

//clears form values that are children of a specific ID.
function clearForms(formId) {
    $("[data-id='" + formId + "']").find(":input").not(':button, :submit, :reset, :hidden, :checkbox, :radio').val('');
    //$('#' + formId + ' :input').not(':button, :submit, :reset, :hidden, :checkbox, :radio').val('');
    $("[data-id='" + formId + "']").find(":checkbox, :radio").prop('checked', false);
    $("[data-id='" + formId + "']").find("select").val("0");
}

//This function is called within the incidentTemplate. It loops through however many icdcm categories there are and appends 
//icdcm tabs for the icdcm tabpanes
function loadIcdcmTabs(icdcmCategorys) {
    var icdcmCategoryTabs = [];
    icdcmCategorys.forEach(function (category, index) {
        icdcmCategoryTabs += `<li id="ICDCMCategory_${category["DiagnosisID"]}"><a href="#ICDCMCategoryTabPane_${category["DiagnosisID"]}" data-toggle="tab">Diagnosis - ${category.Diagnosis || 'Undiagnosed'}</a></li>`;
    });
    return icdcmCategoryTabs;
}

//This function is called within the incidentTemplate. It loops through however many icdcm categories there are,
//modifies the icdcmTemplate literal and appends all of them to the corresponding incidentTemplate literal.
function loadIcdcmTabPaneTemplate(icdcmCategories) {
    var icdcmTabPanes = [];
    icdcmCategories.forEach(function (category, index) {
        icdcmTabPanes += icdcmTemplate(category, category["DiagnosisID"]);
    });
    return icdcmTabPanes;
}

const handleTabSwitch = (navBarId, tabHref) => {
    $(`${navBarId} a[href="${tabHref}"]`).tab('show');
};
//<input id="SubmitForm" type="button" class="btn btn-default btn-small" value="Submit" />
//TEMPLATE LITERALS
function incidentTemplate(incident, id) {
    var templateLiteral = `
    <div data-id="primaryIncident" data-primaryincidentid="${id}" class="panel panel-default container" style="min-height: 500px;">
        <div id="banner-container" class="osp-heading panel-heading narrow-container">
           <div id="welcome-container" class="osp-heading panel-heading">
               <h4 id="welcome-header" class="osp-heading panel-heading">Incident Details</h4>
           </div>
           <div id="logo-container" class="osp-heading panel-heading"></div>
        </div>
        <div class="panel-body incident_details_container remove-top-border">
            <div class="row margin-bottom incident_detail">
                <div class="row margin-bottom">
                    <div class="incident_location_container">
                        <label for="ICD10Location_${id}" data-toggle="tooltip" title="Location where the incident occured">Location the incident occured</label>
                        <input id="ICD10Location_${id}" name="ICD10Location" type="text" class="form-control" value="${incident.Location}" />
                    </div>
                    <div class="incident_description_container">
                        <label for="ICD10Description_${id}" data-toggle="tooltip" title="General description of incident">Incident Description</label>
                        <textarea id="ICD10Description_${id}" name="ICD10Description" rows="2" class="form-control">${incident.IncidentDesc}</textarea>
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-3">
                        <label for="PerformanceIssues">Performance Issues</label>
                        <select id="PerformanceIssues" class="form-control populateWorkIssues"></select>
                    </div>
                    <div class="col-sm-3">
                        <label for="AttendanceIssues">Attendance Issues</label>
                        <select id="AttendanceIssues" class="form-control populateWorkIssues"></select>
                    </div>
                    <div class="col-sm-3">
                        <label for="ChangeInDuties">Change In Duties</label>
                        <select id="ChangeInDuties" class="form-control populateWorkIssues"></select>
                    </div>
                    <div class="col-sm-3">
                        <label for="WorkplaceConflicts">Workplace Conflicts</label>
                        <select id="WorkplaceConflicts" class="form-control populateWorkIssues"></select>
                    </div>
                    <div class="col-sm-3">
                        <label for="OtherIssues">Other Issues</label>
                        <select id="OtherIssues" class="form-control populateWorkIssues"></select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-sm-12">
                        <label for="IssueDescription">Issue Description</label>
                        <input id="IssueDescription" type="textarea" class="form-control" />
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <!-- Nav tabs category -->
                    <ul id="incidentDetailsTabs" class="nav nav-tabs faq-cat-tabs">
                        <li data-id="witnesses-tab" class="incident_li_setter"><a href="#witness-details-tab-body_${id}" data-toggle="tab"><i class="glyphicon glyphicon-user"></i><p class="incident_detail_tab">Witness Details</p></a></li>
                        <li data-id="collateralDamages-tab" class="incident_li_setter"><a href="#collateral-damages-tab-body_${id}" data-toggle="tab"><i class="glyphicon glyphicon-plus"></i><p class="incident_detail_tab">Collateral Damages</p></a></li>
                        <li data-id="correctiveActions-tab" class="incident_li_setter"><a href="#corrective-actions-tab-body_${id}" data-toggle="tab"><i class="glyphicon glyphicon-leaf"></i><p class="incident_detail_tab">Corrective Actions</p></a></li>
                        <li data-id="limitationDetails-tab" class="incident_li_setter"><a href="#limitation-details-tab-body_${id}" data-toggle="tab"><i class="glyphicon glyphicon-user"></i><p class="incident_detail_tab">Limitation Details</p></a></li>
                        <li data-id="icdcmCategory-tab" class="incident_li_setter"><a href="#incident-details-tab-body_${id}" data-toggle="tab"><i class="glyphicon glyphicon-plus"></i><p class="incident_detail_tab">ICDCM Categories</p></a></li>
                        <li data-id="CreateNewTab-tab"><button data-id="CreateNewTab" data-target="#primaryIncidentTabModal_${id}" data-toggle="modal" type="button" class="btn btn-primary btn-sm icon_setter icon-plus margin_5 hidden"></button></li>
                    </ul>
                    <!-- Tab panes -->
                    <div class="tab-content faq-cat-content">
                        <div class="button_container">
                            <div class="button_setter">
                                <button class="down_button" function="scrollFunction()">
                                    <i class="icon-circle-down"></i>
                                </button>
                            </div>
                        </div>
                        <div class="tab-pane fade" data-id="incident-details-tab-body">
                            <div class="tableContainer">
                                <div class="panel panel-default panel-table remove-top-border">
                                    <!--<div class="panel-heading">
                                        <div class="row">
                                            <div class="col col-xs-6">
                                                <h3 class="panel-title">ICDCM Categories</h3>
                                            </div>
                                        </div>
                                    </div>-->
                                    <div class="panel-body">
                                        <!-- Nav tabs category -->
                                        <ul class="nav nav-tabs faq-cat-tabs incident_details_sub_cat" data-id="ICDCMCategoryTabs">
                                            ${incident.icdcmCategory.length ? loadIcdcmTabs(incident.icdcmCategory) : ''}
                                            <li id="AddICDCMCategory-tab"><button data-id="createNewIcdcmCategory" data-toggle="modal" data-target="#IcdcmCategoryModal_${id}" data-primaryincidentid="${id}" type="button" class="btn btn-primary btn-sm icon_setter icon-plus margin_top_3"></button></li>
                                        </ul>
                                        <!-- Tab panes -->
                                        <div data-id="ICDCMCategorys" class="tab-content faq-cat-content incident_details_tab">
                                            ${incident.icdcmCategory.length ? loadIcdcmTabPaneTemplate(incident.icdcmCategory) : ''}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane in fade" data-id="witness-details-tab-body">
                            <div class="tableContainer">
                                <div class="panel panel-default panel-table remove-top-border">
                                    <div class="panel-heading">
                                        <div class="row">
                                            <div class="col col-xs-6">
                                                <!--<h3 class="panel-title">Witness Details</h3>-->
                                            </div>
                                            <div class="col col-xs-6 text-right">
                                                <button data-id="AddRowModal_witnesses" data-modaltemplateid="witnesses-ModalTemplate" data-tableid="#WitnessDetailsTable_${id}" type="button" class="btn btn-sm btn-primary add_button_setter"><i class="icon-plus"></i></button>
                                                <button data-id="EditRowModal_witnesses" data-modaltemplateid="witnesses-ModalTemplate" data-tableid="#WitnessDetailsTable_${id}" type="button" class="btn btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                                <button data-id="RemoveRowModal_witnesses" data-tableid="#WitnessDetailsTable_${id}" type="button" class="btn btn-danger"><i class="icon icon-bin"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <table data-id="WitnessDetailsTable" data-section="primaryIncident" data-propertyname="witnesses" class="table table-bordered table-striped table-hover dataTable no-footer selectable" cellspacing="0" width="100%">
                                            <thead>
                                                <tr></tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane in fade" data-id="collateral-damages-tab-body">
                            <div class="tableContainer">
                                <div class="panel panel-default panel-table remove-top-border">
                                    <div class="panel-heading">
                                        <div class="row">
                                           <div class="col col-xs-6">
                                            <!--<h3 class="panel-title">Collateral Damages</h3>-->
                                            </div>
                                            <div class="col col-xs-6 text-right">
                                                <button data-id="AddRowModal_CollateralDamages" data-modaltemplateid="collateralDamages-ModalTemplate" data-tableid="#CollateralDamagesTable_${id}" type="button" class="btn btn-sm btn-primary add_button_setter"><i class="icon-plus"></i></button>
                                                <button data-id="EditRowModal_CollateralDamages" data-modaltemplateid="collateralDamages-ModalTemplate" data-tableid="#CollateralDamagesTable_${id}" type="button" class="btn btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                                <button data-id="RemoveRowModal_CollateralDamages" data-tableid="#CollateralDamagesTable_${id}" type="button" class="btn btn-danger"><i class="icon icon-bin"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <table data-id="CollateralDamagesTable" data-section="primaryIncident" data-propertyname="collateralDamages" class="table table-bordered table-striped table-hover dataTable no-footer selectable" cellspacing="0" width="100%">
                                            <thead>
                                                <tr></tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane in fade" data-id="corrective-actions-tab-body">
                            <div class="tableContainer">
                                <div class="panel panel-default panel-table remove-top-border">
                                    <div class="panel-heading">
                                        <div class="row">
                                             <div class="col col-xs-6">
                                                <!--<h3 class="panel-title">Corrective Actions</h3>-->
                                           </div>
                                            <div class="col col-xs-6 text-right">
                                                <button data-id="AddRowModal_CorrectiveActions" data-modaltemplateid="correctiveActions-ModalTemplate" data-tableid="#CorrectiveActionsTable_${id}" type="button" class="btn btn-sm btn-primary add_button_setter"><i class="icon-plus"></i></button>
                                                <button data-id="EditRowModal_CorrectiveActions" data-modaltemplateid="correctiveActions-ModalTemplate" data-tableid="#CorrectiveActionsTable_${id}" type="button" class="btn btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                                <button data-id="RemoveRowModal_CorrectiveActions" data-tableid="#CorrectiveActionsTable_${id}" type="button" class="btn btn-danger"><i class="icon icon-bin"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <table data-id="CorrectiveActionsTable" data-section="primaryIncident" data-propertyname="correctiveActions" class="table table-bordered table-striped table-hover dataTable no-footer selectable" cellspacing="0" width="100%">
                                            <thead>
                                                <tr></tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="tab-pane in fade" data-id="limitation-details-tab-body">
                            <div class="tableContainer">
                                <div class="panel panel-default panel-table remove-top-border">
                                    <div class="panel-heading">
                                        <div class="row">
                                            <div class="col col-xs-6">
                                                <!--<h3 class="panel-title">Limitation Details</h3>-->
                                            </div>
                                            <div class="col col-xs-6 text-right">
                                                <button data-id="AddRowModal_LimitationDetails" data-modaltemplateid="limitationDetails-ModalTemplate" data-tableid="#LimitationDetailsTable_${id}" type="button" class="btn btn-sm btn-primary add_button_setter"><i class="icon-plus"></i></button>
                                                <button data-id="EditRowModal_LimitationDetails" data-modaltemplateid="limitationDetails-ModalTemplate" data-tableid="#LimitationDetailsTable_${id}" type="button" class="btn btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                                <button data-id="RemoveRowModal_LimitationDetails" data-tableid="#LimitationDetailsTable_${id}" type="button" class="btn btn-danger"><i class="icon icon-bin"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="panel-body">
                                        <table data-id="LimitationDetailsTable" data-section="primaryIncident" data-propertyname="limitationDetails" class="table table-bordered table-striped table-hover dataTable no-footer selectable" cellspacing="0" width="100%">
                                            <thead>
                                                <tr></tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="AddEditModal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <!-- Modal Body -->
                            <div id="AddEditModalBody" class="modal-body">
                            </div>
                            <!-- Modal Footer -->
                            <div class="modal-footer">
                                <button id="AddRow" data-tableid="" type="button" class="btn btn-primary add_button_setter swal2-confirm swal2-styled" style="background-color: rgb(48, 133, 214); border-left-color: rgb(48, 133, 214); border-right-color: rgb(48, 133, 214);">Add</button>
                                <button type="button" onclick="clearForms('AddEditModalBody');" class="btn btn-default swal2-cancel swal2-styled" data-dismiss="modal" style="display: inline-block; background-color: rgb(170, 170, 170);">Close</button>
                                <button id="EditRow" data-tableid="" type="button" class="btn btn-primary swal2-confirm btn-success swal2-styled" style="background-color: rgb(48, 133, 214); border-left-color: rgb(48, 133, 214); border-right-color: rgb(48, 133, 214);">Edit Row</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Modal Create tab -->
            <div data-id="primaryIncidentTabModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <!-- Modal Header -->
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">
                            <span aria-hidden="true">&times;</span>
                            <span class="sr-only">Close</span>
                        </button>
                        <h2 id="myModalLabel" class="swal2-title">Section Selection</h2>
                    </div>
                    <!-- Modal Body -->
                        <div class="modal-body">
                        <form role="form">
                            <div class="form-group">
                                <label for="selectSection">Select a section to add:</label>
                                <select data-id="selectSection" class="form-control">
                                    <option label="---" value="0"></option>
                                    <option value="icdcmCategory" class="active">ICDCM Category</option>
                                    <option value="witnesses" class="active">Witness Details</option>
                                    <option value="collateralDamages" class="active">Collateral Damage</option>
                                    <option value="correctiveActions" class="active">Corrective Actions</option>
                                    <option value="limitationDetails" class="active">Limitations</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <!-- Modal Footer -->
                        <div class="modal-footer">
                        <button data-id="addPrimaryIncidentTab" data-primaryincidentid="${id}" data-dismiss="modal" type="button" class="btn btn-primary add_button_setter swal2-confirm swal2-styled" style="background-color: rgb(48, 133, 214); border-left-color: rgb(48, 133, 214); border-right-color: rgb(48, 133, 214);">Add</button>
                        <button type="button" class="btn swal2-cancel swal2-styled" data-dismiss="modal" style="display: inline-block; background-color: rgb(170, 170, 170);">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <div data-id="IcdcmCategoryModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <!-- Modal Header -->
                        <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">
                            <span aria-hidden="true">&times;</span>
                            <span class="sr-only">Close</span>
                        </button>
                        <h4 class="modal-title">Add Diagnosis & ICDCM Category</h4>
                    </div>
                    <!-- Modal Body -->
                        <div class="modal-body">
                        <form role="form">
                            <div class="form-group">
                                <div class="row">
                                    <div class='col-md-10'>
                                        <h4>Select a diagnosis first to filter the proper ICDCM Categories:</h4>
                                    </div>
                                </div>
                                <div class="row"> 
                                    <div class='col-md-10'>
                                        <label for="selectDiagnosis">Select a Diagnosis:</label>
                                        <select data-id="selectDiagnosis" class="form-control"/>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class='col-md-10'>
                                        <label for="selectIcdcmCategory">Select a ICDCM Category:</label>
                                        <select data-id="selectIcdcmCategory" class="form-control"/>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <!-- Modal Footer -->
                    <div class="modal-footer">
                        <button data-id="addICDCMCategoryTab" data-primaryincidentid="${id}" data-dismiss="modal" type="button" class="btn btn-primary swal2-confirm swal2-styled" style="background-color: rgb(48, 133, 214); border-left-color: rgb(48, 133, 214); border-right-color: rgb(48, 133, 214);">Add ICDCM Category</button>
                        <button type="button" class="btn swal2-cancel swal2-styled" data-dismiss="modal" style="display: inline-block; background-color: rgb(170, 170, 170);">Close</button>
                    </div>
                </div>
            </div>
        </div>
    </div>`;
    //further modifications with JQuery
    var modifiedTemplate = $(templateLiteral);
    modifiedTemplate.attr("id", modifiedTemplate.attr("data-id") + "_" + id);
    modifiedTemplate.find("[data-id]").each(function () {
        $(this).attr("id", $(this).attr("data-id") + "_" + id);
    });

    return modifiedTemplate;
}
//Icdcm category template
function icdcmTemplate(icdcmData, id) {
    let templateLiteral = `
  <div id="ICDCMCategoryTabPane_${id}" data-icdcmCategoryID="${id}" class="tab-pane fade">
        <div>
            <div class="row margin-bottom">
                <div class="col-md-3">
                    <label for="Diagnosis">Diagnosis</label>
                    <select class="form-control" id="Diagnosis_${id}" name="Diagnosis" placeholder="Diagnosis" value="${icdcmData.Diagnosis}" />
                </div>
                <div class="col-md-3">
                    <label for="ICD10CatType">Category</label>
                    <select class="form-control" id="Category_${id}" name="Category" placeholder="Category" value="${icdcmData.Category}" />
                </div>
                <div class="col-md-2">
                    <label for="ICD10CatDDG">DDG Min</label>
                    <input type="text" class="form-control" id="DDGMin_${id}" name="DDGMin" placeholder="DDG Minimum" value="${icdcmData.DDGMin}" />
                </div>
                <div class="col-md-2">
                    <label for="ICD10CatType">DDG Avg</label>
                    <input class="form-control" id="DDGAvg_${id}" name="DDGAvg" placeholder="DDG Average" value="${icdcmData.DDGAvg}" />
                </div>
                <div class="col-md-2">
                    <label for="ICD10CatDDG">DDG Max</label>
                    <input class="form-control" id="DDGMax_${id}" name="DDGMax" placeholder="DDG" value="${icdcmData.DDGMax}" />
                </div>
            </div>
            <div class="row margin-bottom">
                <div class="col-md-12">
                    <label for="ICD10CatDescription">Description</label>
                    <textarea class="form-control" id="Description_${id}" rows="3" name="Description" placeholder="Description">${icdcmData.Description}</textarea>
                </div>
            </div>
            <div class="row card">
                <div class="col-md-12">
                    <div class="tableContainer">
                        <div class="card-header card-header-blue2">
                            <div class="row">
                                <div class="col-md-6 card_title_container">
                                    <span class="card-title">Activities</span>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-12">
                                <div class="col-md-6">
                                    <div>
                                        <button id="AddRowModal_Activities_${id}" data-modaltemplateid="Activities-ModalTemplate" data-tableid="#ActivitiesTable_${id}" type="button" class="btn btn-sm btn-default add_button_setter add_button"><i class="icon-plus"></i></button>
                                        <button id="EditRowModal_Activities_${id}" data-modaltemplateid="Activities-ModalTemplate" data-tableid="#ActivitiesTable_${id}" type="button" class="btn btn-sm btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                        <button id="RemoveRowModal_Activities_${id}" data-tableid="#ActivitiesTable_${id}" type="button" class="btn btn-sm btn-danger"><i class="icon icon-bin"></i></button>
                                    </div>
                                </div>
                                    <table id="ActivitiesTable_${id}" data-section='icdcmCategory' data-propertyname="categoryActivities" class="table table-bordered table-striped table-hover dataTable no-footer" cellspacing="0" width="100%">
                                        <thead>
                                            <tr></tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row card">
                <div class="col-md-12">
                    <div class="tableContainer">
                        <div class="card-header card-header-blue2">
                            <div class="row">
                                <div class="col-md-6 card_title_container">
                                    <span class="card-title">Medications</span>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row margin-bottom">
                                <div class="col-md-12">
                                    <div class="col-md-6">
                                        <div>
                                            <button id="AddRowModal_Medications_${id}" data-modaltemplateid="Medications-ModalTemplate" data-tableid="#MedicationsTable_${id}" type="button" class="btn btn-sm btn-default add_button_setter add_button"><i class="icon-plus"></i></button>
                                            <button id="EditRowModal_Medications_${id}" data-modaltemplateid="Medications-ModalTemplate" data-tableid="#MedicationsTable_${id}" type="button" class="btn btn-sm btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                            <button id="RemoveRowModal_Medications_${id}" data-tableid="#MedicationsTable_${id}" type="button" class="btn btn-sm btn-danger"><i class="icon icon-bin"></i></button>
                                        </div>
                                    </div>
                                    <table id="MedicationsTable_${id}" data-section='icdcmCategory' data-propertyname="categoryMedications" class="table table-bordered table-striped table-hover dataTable no-footer" cellspacing="0" width="100%">
                                        <thead>
                                            <tr></tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row card">
                <div class="col-md-12">
                    <div class="tableContainer">
                        <div class="card-header card-header-blue2">
                            <div class="row">
                                <div class="col-md-6 card_title_container">
                                    <span class="card-title">Body Parts Injured</span>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row margin-bottom">
                                <div class="col-md-12">
                                    <div class="col-md-6">
                                        <div>
                                            <button id="AddRowModal_BodyParts_${id}" data-modaltemplateid="BodyParts-ModalTemplate" data-tableid="#BodyPartsTable_${id}" type="button" class="btn btn-sm btn-default add_button_setter add_button"><i class="icon-plus"></i></button>
                                            <button id="EditRowModal_BodyParts_${id}" data-modaltemplateid="BodyParts-ModalTemplate" data-tableid="#BodyPartsTable_${id}" type="button" class="btn btn-sm btn-default edit_button"><i class="icon icon-pencil"></i></button>
                                            <button id="RemoveRowModal_BodyParts_${id}" data-tableid="#BodyPartsTable_${id}" type="button" class="btn btn-sm btn-danger"><i class="icon icon-bin"></i></button>
                                        </div>
                                    </div>
                                    <table id="BodyPartsTable_${id}" data-section='icdcmCategory' data-propertyname="categoryBodyParts" class="table table-bordered table-striped table-hover dataTable no-footer selectable body_parts_table" cellspacing="0" width="100%">
                                        <thead>
                                            <tr></tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row card">
                <div class="col-md-12">
                    <div class="tableContainer">
                        <div class="card-header card-header-blue2">
                            <div class="row">
                                <div class="col-md-6 card_title_container">
                                    <span class="card-title">Cause</span>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row margin-bottom">
                                <div class="col-md-12">
                                    <div class="row form-group">
                                        <div class="col-md-12">
                                            <label for="CauseInjury">What happened to cause the injury/illness and what was the employee was doing at that time: <small>(max 1500 characters)</small></label>
                                            <textarea class="form-control" maxlength="1500" id="CauseInjury_${id}" name="CauseInjury" rows="4">${icdcmData.categoryCause.CauseInjury ? icdcmData.categoryCause.CauseInjury : ''}</textarea>
                                        </div>
                                    </div>
                                    <div class="row margin-bottom">
                                        <div class="col-md-6">
                                            <label class="checkbox-inline">
                                                <input class="form-check-input" type="checkbox" id="SimInjury_${id}" ${icdcmData.categoryCause.SimInjury ? 'checked' : ''} /> Was it a similar Injury
                                            </label>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="GradInjury" class="checkbox-inline">
                                                <input class="form-check-input" type="checkbox" id="GradInjury_${id}" ${icdcmData.categoryCause.GradInjury ? 'checked' : ''} /> Gradual Injury?
                                            </label>
                                        </div>
                                    </div>
                                    <div class="row margin-bottom">
                                        <div class="col-md-6">
                                            <label for="SimReason">If 'yes', please elobrate <small>(max 500 characters)</small></label>
                                            <textarea class="form-control" maxlength="500" id="SimReason_${id}" rows="4">${icdcmData.categoryCause.SimReason ? icdcmData.categoryCause.SimReason : ''}</textarea>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="GradReason">If "Gradual Injury", describe activites performed. <small>(max 500 characters)</small></label>
                                            <textarea class="form-control" maxlength="500" id="GradReason_${id}" rows="4">${icdcmData.categoryCause.GradReason ? icdcmData.categoryCause.GradReason : ''}</textarea>
                                        </div>
                                    </div>
                                    <div class="row margin-bottom">
                                        <div class="col-md-6">
                                            <label for="weatherconditions-select">Weather Conditions (Select All that apply): </label>
                                            <select id="weatherconditions-select_${id}" class="form-control" multiple="multiple">
                                                ${renderListOptions('GetList_WeatherConditions', icdcmData.categoryCause.CauseID, 'WeatherConditions')}
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="environmentfactors-select">Environment Factors Involved (select All that apply):</label>
                                            <select id="environmentfactors-select_${id}" class="form-control" multiple="multiple">
                                                ${renderListOptions('GetList_EnvironmentFactors', icdcmData.categoryCause.CauseID, 'EnvironmentFactors')}
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row margin-bottom">
                                        <div class="col-md-6">
                                            <label for="injurylocation-select">Select descriptive injury location (select All that apply):</label>
                                            <select id="injurylocation-select_${id}" class="form-control" multiple="multiple">
                                                ${renderListOptions('GetList_InjuryIllnessLocation', icdcmData.categoryCause.CauseID, 'InjuryLocations')}
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="clients-select">Equipment Involved (Select All the apply): </label>
                                            <select id="equipmentinvolved-select_${id}" class="form-control" multiple="multiple">
                                                ${renderListOptions('GetList_EquipmentInvolved', icdcmData.categoryCause.CauseID, 'EquipmentInvolved')}
                                            </select>
                                        </div> 
                                    </div>
                                    <div class="row margin-bottom">
                                        <div class="col-md-6">
                                            <label for="humanfactor-select">Human Factor (select All that apply):</label>
                                            <select id="humanfactor-select_${id}" class="form-control" multiple="multiple">
                                                ${renderListOptions('GetList_HumanFactor', icdcmData.categoryCause.CauseID, 'HumanFactors')}
                                            </select>
                                        </div> 
                                    </div> 
                                    <div class="row margin-bottom">
                                        <div class="col-md-6">
                                            <label for="IsSafe">Based on the human factor(s), the employees actions are considered:</label>
                                            <select class="form-control" id="IsSafe_${id}"> 
                                                 <option value="true" ${icdcmData.categoryCause.IsSafe ? 'selected' : ''}>Safe</option>
                                                 <option value="false" ${icdcmData.categoryCause.IsSafe ? '' : 'selected'}>Unsafe</option>
                                            </select>                                            
                                            <label for="IsSafeReason_${id}">Reason for Determination: (max 1500 characters)</label>
                                            <textarea class="form-control" maxlength="1500" id="IsSafeReason_${id}" rows="5">${icdcmData.categoryCause.IsSafeReason ? icdcmData.categoryCause.IsSafeReason : ''}</textarea>
                                        </div> 
                                    </div>
                                </div>
                            </div>
                        </div>
                     </div>
                </div>
           </div>
       </div>
   </div>`;

    return templateLiteral;
}

$(document).ready(function () {
    $('.nav_item_forms').addClass("nav-item nav-item-active");
    $('.nav_item_forms a').addClass("nav-link");
    //$('#addPrimaryIncidentTab_0').click(function () {
    //    if (!$('#icdcmCategory-tab_0').hasClass('hidden')) {
    //        $('#icdcmCategory-tab_0').addClass('active').siblings().removeClass('active');
    //        if ($('#icdcmCategory-tab_0').hasClass('active')) {
    //            $("#incident-details-tab-body_0").addClass('active in').siblings().removeClass('active');
    //        };
    //    };
    //    if (!$('#witnesses-tab_0').hasClass('hidden')) {
    //        $('#witnesses-tab_0').addClass('active').siblings().removeClass('active');
    //        if ($('#witnesses-tab_0').hasClass('active')) {
    //            $("#witness-details-tab-body_0").addClass('active in').siblings().removeClass('active');
    //        };
    //    };
    //    if (!$('#collateralDamages-tab_0').hasClass('hidden')) {
    //        $('#collateralDamages-tab_0').addClass('active').siblings().removeClass('active');
    //        if ($('#collateralDamages-tab_0').hasClass('active')) {
    //            $("#collateral-damages-tab-body_0").addClass('active in').siblings().removeClass('active');
    //        };
    //    };
    //    if (!$('#correctiveActions-tab_0').hasClass('hidden')) {
    //        $('#correctiveActions-tab_0').addClass('active').siblings().removeClass('active');
    //        if ($('#correctiveActions-tab_0').hasClass('active')) {
    //            $("#corrective-actions-tab-body_0").addClass('active in').siblings().removeClass('active');
    //        };
    //    };
    //    if (!$('#limitationDetails-tab_0').hasClass('hidden')) {
    //        $('#limitationDetails-tab_0').addClass('active').siblings().removeClass('active');
    //        if ($('#limitationDetails-tab_0').hasClass('active')) {
    //            $("#limitation-details-tab-body_0").addClass('active in').siblings().removeClass('active');
    //        };
    //    };
    //});
    //$('.incident_details_container .row .col-md-12 .faq-cat-tabs .incident_details_sub_cat li.incident_li_setter').addClass('active');
    $('.collapse').on('show.bs.collapse', function () {
        var id = $(this).attr('id');
        $('a[href="#' + id + '"]').closest('.panel-heading').addClass('active-faq');
        $('a[href="#' + id + '"] .panel-title span').html('<i class="glyphicon glyphicon-minus"></i>');
    });
    $('.collapse').on('hide.bs.collapse', function () {
        var id = $(this).attr('id');
        $('a[href="#' + id + '"]').closest('.panel-heading').removeClass('active-faq');
        $('a[href="#' + id + '"] .panel-title span').html('<i class="glyphicon glyphicon-plus"></i>');
    });
    //================================TABLE FUNTIONALITY====================
    $('.selectable tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        } else {
            $('tr.selected').removeClass('selected');
            $(this).addClass('selected');
        }
    });

    //A default notification setting for global notification calls
    $.notifyDefaults({
        placement: {
            from: 'bottom',
            align: 'right'
        }
    });
});

$(function scrollFunction() {
    var $elem = $('#MainContent_incidentDetails');
    $('.down_button').click(
        function(e) {
            $('html, body').animate({ scrollTop: $elem.height() }, 800);
        }
    );
});