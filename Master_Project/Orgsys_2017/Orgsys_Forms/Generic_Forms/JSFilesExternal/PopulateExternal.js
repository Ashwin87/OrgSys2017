
function PopulateSubmitterDetails(userJson) {
    var userJson = userJson[0]
    $(".autoPopulateSubFirstName").val(userJson.EmpFirstName);
    $(".autoPopulateSubLastName").val(userJson.EmpLastName);
    $(".autoPopulateSubPhone").val(userJson.WorkPhone);
    $(".autoPopulateSubExt").val(userJson.Ext);
    $(".autoPopulateSubEmail").val(userJson.Email);
}

function PopulateAbsenceDetails(absencesJson) {
    $.each(absencesJson, function (key, absence) {
        SetIsoDateFormat('[name="AbsAuthTo"]', absence.AbsAuthTo);
        SetIsoDateFormat('[name="DayOff"]', absence.DayOff);
    })
}

//Gets weekly earnings of an employee
function PopulateOtherEarnings() {
    $.ajax({
        url: getApi + "/api/Claim/GetOtherEarnings/" + ClaimID,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        async: false,
        success: function (data) {
            results = ReplaceDFValues(JSON.parse(data));
            for (i = 0; i < results.length; i++) {
                SetIsoDateFormat('[name=OtherFromDate' + results[i]["WeekNu"] + ']', results[i]["OtherFromDate"])
                SetIsoDateFormat('[name=OtherToDate' + results[i]["WeekNu"] + ']', results[i]["OtherToDate"])
                $('[name=ManOverPay' + results[i]["WeekNu"] + ']').val(results[i]["ManOverPay"]);
                $('[name=VolOverPay' + results[i]["WeekNu"] + ']').val(results[i]["VolOverPay"]);
            };
        }
    });
}

//Gets the schedule of an employee if it does exist
function PopulateSchedule(async) {

    var async = (async == false) ? false : true;

    $.ajax({
        url: getApi + "/api/Claim/GetSchedule/" + ClaimID,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        async: async,
        success: function (data) {
            var results = ReplaceDFValues( JSON.parse(data) );

            if (results.length > 0) {
                for (var i = 2; i <= results.length; i++) {
                    $('.AddWeek').trigger('click');
                }

                //only the first record contains the scheduleType value
                $('.schedule-type').val(results[0]["ScheduleType"]);

                for (var i = 0; i < results.length; i++) {

                    var rowN = i + 1;
                    var totalHours = parseInt(results[i]["TotalHours"]);
                    var daysOn = parseInt(results[i]["DaysOn"]);
                    var hoursPerShift = (daysOn > 0 && totalHours > 0) ? (totalHours / daysOn).toFixed(1) : 0.0;

                    //using rowN because AddWeek event handler will append name attribute with next row number
                    SetIsoDateFormat('[name=WeekStart' + rowN + ']', results[i]["WeekStart"])
                    SetIsoDateFormat('[name=WeekEnd' + rowN + ']', results[i]["WeekEnd"])
                    $('[name=Sunday' + rowN + ']').val(results[i]["Sunday"]);
                    $('[name=Monday' + rowN + ']').val(results[i]["Monday"]);
                    $('[name=Tuesday' + rowN + ']').val(results[i]["Tuesday"]);
                    $('[name=Wednesday' + rowN + ']').val(results[i]["Wednesday"]);
                    $('[name=Thursday' + rowN + ']').val(results[i]["Thursday"]);
                    $('[name=Friday' + rowN + ']').val(results[i]["Friday"]);
                    $('[name=Saturday' + rowN + ']').val(results[i]["Saturday"]);
                    $('[name=DaysOn' + rowN + ']').val(results[i]["DaysOn"]);
                    $('[name=DaysOff' + rowN + ']').val(results[i]["DaysOff"]);
                    $('[name=HrsperShift' + rowN + ']').val(hoursPerShift);

                };
            }
        }
    });
}

//Get body parts injured.....
function PopulateICDCMCatPart() {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/Incident/GetICDCMCatPart/" + ClaimID,
        success: function (data) {
            var results = JSON.parse(data);

            for (i = 0; i < results.length; i++) {
                var partSides = [['Left', 'Right', 'InjArea'], ['L', 'R', '']]
                var p = partSides[0].indexOf(results[i]["PartSide"])
                var selector = '[name="' + partSides[1][p] + results[i]["BodyPart"] + '"]'

                $(selector).prop('checked', true);

                if (results[i]['OtherBodyPart'] != '') $('[name="OtherBodyPart"]').val(results[i]['OtherBodyPart']);
            }
        }
    });

}

//Get witness data and populate corresponding controls
function PopulateWitnesses(async) {
    //optional parameter
    var async = (async == false) ? false : true;

    $.ajax({
        url: getApi + "/api/Incident/GetICDCMWitness/" + ClaimID,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: async,
        success: function (data) {
            var results = JSON.parse(data);

            if (results.length > 1) {
                for (var i = 2; i <= results.length; i++)
                    $('.AddWitness').trigger('click');
            }

            for (var i = 0; i < results.length; i++) {
                var w = i + 1;
                $('[name=WitnessName' + w + ']').val(results[i]["WitnessName"]);
                $('[name=WitnessEmail' + w + ']').val(results[i]["WitnessEmail"]);
                $('[name=WitnessPhone' + w + ']').val(results[i]["WitnessPhone"]);
                $('[name=WitnessStatement' + w + ']').val(results[i]["WitnessStatement"]);
            }
        }
    });
}

//Gets all the claim contacts of a respective claim
function PopulateClaimContacts() {
    $.ajax({
        url: getApi + "/api/Claim/GetClaimContacts/" + ClaimID,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        async: false,
        success: function (data) {
            var results = JSON.parse(data);
            for (i = 0; i < results.length; i++) {
                LoadContacts(results[i]["ContactType"], results[i]["Con_FirstName"], results[i]["Con_LastName"], results[i]["Con_Title"], results[i]["Con_WorkPhone"], results[i]["Con_Ext"], results[i]["Con_Email"], results[i]["Con_Fax"]);
            }
        }
    });
}

function LoadContacts(val, firstName, lastName, position, phone, ext, email, fax) {
    $('[name="' + val + 'FirstName"]').val(firstName);
    $('[name="' + val + 'LastName"]').val(lastName);
    $('[name="' + val + 'Position"]').val(position);
    $('[name="' + val + 'Phone"]').val(phone);
    $('[name="' + val + 'Ext"]').val(ext);
    $('[name="' + val + 'Email"]').val(email);
    $('[name="' + val + 'Fax"]').val(fax);
}

//Populate the [Country] drop down when the form is populated function PopulateCountries() {
    return $.ajax({
        url: getApi + "/api/DataBind/PopulateCountries",
        async: false,
        success: function (data) {
            var results = JSON.parse(data);
            var target = $('.populateCountries');

            target.append($('<option>').text('--Select---'));
            for (i = 0; i < results.length; i++) {
                target.append($('<option>').text(results[i]["Country_Name"]).attr('value', results[i]["Country_ISO_Code"]));
            }
        }
    });
}

function PopulateCountriesOO() {
    return $.ajax({
        url: getApi + "/api/OldOrgsysGetData/GetList_Countries",
        async: false,
        success: function (data) {
            var results = JSON.parse(data);
            var target = $('.populateCountries');

            target.append($('<option>').text('--Select---'));
            for (i = 0; i < results.length; i++) {
                target.append($('<option>').text(results[i]["Country"]).attr('value', results[i]["id"]));
            }
        }
    });
}

function PopulateClientDetails(clientTargets) {
    GetDataGeneric('OldOrgsysGetData', 'GetClientDetails', Token).then(function (details) {

        clientTargets.forEach(function (control) {
            var value = details[0][control.ControlName];

            if (value === true || value === false) {
                value = (value) ? 1 : 0;
            }

            $('#' + control.ID).val(value)
        });

    });
}

/**
 * FUNCTIONS BELOW ARE FOR POPULATING THE PRINT VERSION OF FORMS, HAS DIFFERENT STRUCTURE 
 */
/*
//Gets weekly earnings of an employee
function PopulateOtherEarningsPrint() {
    $.getJSON(getApi + "/api/Claim/GetOtherEarnings/" + ClaimID, function (data) {
        var results = ReplaceDFValues(JSON.parse(data));

        for (i = 0; i < results.length; i++) {
            $('.view-claim [id=OtherFromDate' + results[i]["WeekNu"] + ']').text(ConvertDateIsoToCustom(results[i]["OtherFromDate"]));
            $('.view-claim [id=OtherToDate' + results[i]["WeekNu"] + ']').text(ConvertDateIsoToCustom(results[i]["OtherToDate"]));
            $('.view-claim [id=ManOverPay' + results[i]["WeekNu"] + ']').text(results[i]["ManOverPay"]);
            $('.view-claim [id=VolOverPay' + results[i]["WeekNu"] + ']').text(results[i]["VolOverPay"]);
        };
    });
}

//Gets the schedule of an employee if it does exist
function PopulateSchedulePrint() {
    $.getJSON(getApi + "/api/Claim/GetSchedule/" + ClaimID, function (data) {
        var results = JSON.parse(data);

        if (results.length > 0) {
            //only the first record contains the scheduleType value
            $('.view-claim .schedule-type').find('option[value="' + results[0]["ScheduleType"] + '"]').prop('selected', true);

            for (var i = 0; i < results.length; i++) {
                var rowN = i + 1;
                var totalHours = parseInt(results[i]["TotalHours"]);
                var daysOn = parseInt(results[i]["DaysOn"]);
                var hoursPerShift = (daysOn > 0 && totalHours > 0) ? (totalHours / daysOn).toFixed(1) : 0.0;

                //using rowN because AddWeek event handler will append name attribute with next row number
                $('.view-claim [id=WeekStart' + rowN + ']').text(ConvertDateIsoToCustom(results[i]["WeekStart"]));
                $('.view-claim [id=WeekEnd' + rowN + ']').text(ConvertDateIsoToCustom(results[i]["WeekEnd"]));
                $('.view-claim [id=Sunday' + rowN + ']').text(results[i]["Sunday"]);
                $('.view-claim [id=Monday' + rowN + ']').text(results[i]["Monday"]);
                $('.view-claim [id=Tuesday' + rowN + ']').text(results[i]["Tuesday"]);
                $('.view-claim [id=Wednesday' + rowN + ']').text(results[i]["Wednesday"]);
                $('.view-claim [id=Thursday' + rowN + ']').text(results[i]["Thursday"]);
                $('.view-claim [id=Friday' + rowN + ']').text(results[i]["Friday"]);
                $('.view-claim [id=Saturday' + rowN + ']').text(results[i]["Saturday"]);
                $('.view-claim [id=DaysOn' + rowN + ']').text(results[i]["DaysOn"]);
                $('.view-claim [id=DaysOff' + rowN + ']').text(results[i]["DaysOff"]);
                //change once getschedule sproc is updated, currently returning HrsperShift as a sum of hours //abovtenko
                $('.view-claim [id=HrsperShift' + rowN + ']').text(hoursPerShift);

            };
        }
    });
}

//Get body parts injured.....
function PopulateICDCMCatPartPrint() {
    $.getJSON(getApi + "/api/Incident/GetICDCMCatPart/" + ClaimID, function (data) {
        var strId = '';
        var results = JSON.parse(data);

        for (i = 0; i < results.length; i++) {
            if (results[i]["PartSide"] == 'Left') {
                strId = 'L';
                $('.view-claim [id=' + strId + results[i]["BodyPart"] + ']').prop('checked', true);
            }
            if (results[i]["PartSide"] == 'Right') {
                strId = 'R';
                $('.view-claim [id=' + strId + results[i]["BodyPart"] + ']').prop('checked', true);
            }
            if (results[i]["PartSide"] == 'InjArea') {
                $('.view-claim [id=' + results[i]["BodyPart"] + ']').prop('checked', true);
            }
        }
    });
}

//Get witness data and populate corresponding controls
function PopulateWitnessesPrint() {
    $.getJSON(getApi + "/api/Incident/GetICDCMWitness/" + ClaimID, function (data) {
        var results = JSON.parse(data);
                
        for (var i = 0; i < results.length; i++) {
            var w = i + 1;
            $('.view-claim [id=WitnessName' + w + ']').text(results[i]["WitnessName"]);
            $('.view-claim [id=WitnessEmail' + w + ']').text(results[i]["WitnessName"]);
            $('.view-claim [id=WitnessPhone' + w + ']').text(results[i]["WitnessName"]);
            $('.view-claim [id=WitnessStatement' + w + ']').text(results[i]["WitnessName"]);
        }
    });
}

function PopulateClaimContactsPrint() {
    $.getJSON(getApi + "/api/Claim/GetClaimContacts/" + ClaimID, function (data) {
        var results = JSON.parse(data);

        for (i = 0; i < results.length; i++) {
            LoadContactsPrint(results[i]["ContactType"], results[i]["Con_FirstName"], results[i]["Con_LastName"], results[i]["Con_Title"], results[i]["Con_WorkPhone"], results[i]["Con_Ext"], results[i]["Con_Email"], results[i]["Fax"]);
        }
    });
}

function LoadContactsPrint(val, firstName, lastName, position, phone, ext, email, fax) {
    $('.view-claim [id="' + val + 'FirstName"]').val(firstName);
    $('.view-claim [id="' + val + 'LastName"]').val(lastName);
    $('.view-claim [id="' + val + 'Name"]').text(name);
    $('.view-claim [id="' + val + 'Position"]').text(position);
    $('.view-claim [id="' + val + 'Phone"]').text(phone);
    $('.view-claim [id="' + val + 'Ext"]').text(ext);
    $('.view-claim [id="' + val + 'Email"]').text(email);
    $('.view-claim [id="' + val + 'Fax"]').text(fax);
}
*/
//
// FUNCTIONS FOR POPULATING JSON DATA INTO FORMS
//

function PopulateSiteDivisionDepartment(Token) {

}

function PopulateClaimData(claimData) { //xxx

    var provinceControls = [];
    var cityControls = [];

    $.each(claimData, function (key, value) {
        var target = $('[name="' + key + '"]');    
        var type = target.attr('type');

        if (value === true) {

            //for radio buttons
            if (target.val() == "1") {
                var id = $('[name=' + key + ']').attr('id');
                $('#' + id).prop('checked', true);
            }
            else if (target.is('select')) {    
                //for yes/no select controls
                target.find('option[value=1], option[value="-1"], option[value="Yes"]').prop('selected', true);
            }
            //for when options are saved to different columns, option contains hidden tag
            else {
                target.parent().prop('selected', true);
            }

        }
        else if (value === false) {

            if (target.val() == "0") {
                target.prop('checked', true);
            }
            else if (target.is('select')) {
                target.find('option[value=0]').prop('selected', true);
            }

        }
        else if (type === 'checkbox') {
            target.val(1);
        }
        //dates; convert to custom format by setting iso through dp api
        else if (isIsoDateFormat(value)) {
            SetIsoDateFormat(target, value);
        }
        else if (target.hasClass('isTime')) {
            target.timepicker('setTime', value)
        }
        else if (target.hasClass('province')) {            
            //record to populate separately
            provinceControls.push({ field: target, value: value });
            
            //allows the value to be used instantly if needed (needed for pdf) /abovtenko
            target.append('<option>Select<option><option value="' + value + '">' + value + '</option>');
            target.val(value);   
        }
        else if (target.hasClass('city')) {
            //record to populate separately
            cityControls.push({ field: target, value: value });

            //allows the value to be used instantly if needed (needed for pdf) /abovtenko
            target.append('<option>Select<option><option value="' + value + '">' + value + '</option>');
            target.val(value); 
        }  
        else if (target.hasClass('populateDivision')) {
            SetDivision(value, target);
        }
        else if (target.is('select')) {
            if (value != '') {
                target.append('<option><option><option value="' + value + '">' + value + '</option>'); //to not have to wait for the list to populate, remove this is draft claim is an option
                target.val(value)
            }
        }
        else if (key == 'LocationOfTreatment') { //key matches a group of checkboxes; for orgsys
                $('#TreatLoc input[type="checkbox"]').each(function () {
                    if (this.value == value) $(this).prop('checked', true);
                });    
        }        
        else {
            target.val(value);
        }
    });
    
    //setting province field requires api call after country is set;
    //a page may also have many country-province pairs    
    provinceControls.forEach(function (provinceControl) {

        var country = PopulateByValue(provinceControl.field);
        var name = provinceControl.field.attr('name');

        GetDataGeneric('OldOrgsysGetData', 'GetList_ProvinceStates', country.value, false).then(function (provinces) {
            PopulateList(provinces, name, 'ProvinceState', 'id');
            provinceControl.field.val(provinceControl.value);
            
            cityControls.map(function (control) {
                var province = PopulateByValue(control.field)

                //find the city control that is populated based on province value
                if (province.fieldName == name) {
                    GetDataGeneric('OldOrgsysGetData', 'GetList_Cities', province.value, false).then(function (cities) {
                        PopulateList(cities, control.field.attr('name'), 'City', 'id');
                        control.field.val(control.value);
                    });
                }
            })

        });

    });     

}

function PopulateByValue(field) {

    //selects the css class that matches the desired pattern
    var ptfClass = SelectCssClassLike(field.attr('class'), 'ptf-');
    //second part contains country control's name attribute
    var fieldName = ptfClass[0].replace('ptf-', '');
    var value = $('[name="' + fieldName + '"]').find(':selected').val();

    return { value: value, fieldName: fieldName };

}

function PopulateList(json, controlName, textColumn, valueColumn) {
    var control = $('select[name="' + controlName + '"]');

    control.empty();
    control.append('<option>Select</option>')

    $.each(json, function (key, val) {
        control.append($('<option>').text(val[textColumn]).attr('value', val[valueColumn]));
    });
}

function PopulateClaimDatesPrint(datesJson) {
    $.each(datesJson, function (key, val) {
        $('.view-claim [id=' + val["DateDescription"] + ']').text(ConvertDateIsoToCustom(val["OccurenceDate"]));
    });
}

function PopulateClaimDates(datesJson) {
    $.each(datesJson, function (key, val) {
        SetIsoDateFormat('[name=' + val["DateDescription"] + ']', val["OccurenceDate"])
    });
}

function PopulateEmployeeContactsExternal(contactsJson) {
    $.each(contactsJson, function (key, val) {
        $('[name="Emp' + val['ContactType'] + '"]').val(val['ContactDetail']).trigger('change');
        //set extension
        $('[name="Emp' + val['ContactType'] + 'Ext"]').val(val['Ext']).trigger('change');
    });
}

function PopulateHealthProfessional(doctorJson) {
    //sets only a single health professional
    $.each(doctorJson[0], function (key, val) {
        $('[name="HP' + key + '"]').val(val);
    });
}

function PopulateIncidentTypesCB(incidentTypes) {
    $.each(incidentTypes, function (key, val) {
        $('[value="' + val.IncidentType + '"]').prop('checked', true);
    });
}

function PopulateAreaOfInjuryIllnessOO(bodyParts) {
    $.each(bodyParts, function (key, val) {
        $('#Left, #Right, #InjArea').find('input[type="checkbox"]').each(function () {
            if (this.value == val.BodyPart) $(this).prop('checked', true);
        });
        if (val.OtherInjuryArea != null) $('[name="OtherInjuryArea"]').val(val.OtherInjuryArea)
    });
}

function PopulateScheduleOO(schedule) {
    if (schedule.length > 0) {
        for (var i = 2; i <= schedule.length; i++) {
            $('.AddWeek').trigger('click');
        }

        //only the first record contains the scheduleType value
        //$('.schedule-type').val(schedule[0]["ScheduleType"]); //old orgsys stores this in a different table

        for (var i = 0; i < schedule.length; i++) {
            var week = schedule[i];
            var rowN = i + 1;
            var daysOn = [week.Sunday, week.Monday, week.Tuesday, week.Wednesday, week.Thursday, week.Friday, week.Saturday].filter(function (x) {
                return x > 0;
            }).length;
            var totalHours = parseInt(week["TotalHours"]);
            //var daysOn = parseInt(week["DaysOn"]);
            var hoursPerShift = (daysOn > 0 && totalHours > 0) ? (totalHours / daysOn).toFixed(1) : 0.0;

            //using rowN because AddWeek event handler will append name attribute with next row number
            SetIsoDateFormat('[name=WeekStart' + rowN + ']', week["WeekStart"]);
            SetIsoDateFormat('[name=WeekEnd' + rowN + ']', week["WeekEnd"]);
            $('[name=Sunday' + rowN + ']').val(week["Sunday"]);
            $('[name=Monday' + rowN + ']').val(week["Monday"]);
            $('[name=Tuesday' + rowN + ']').val(week["Tuesday"]);
            $('[name=Wednesday' + rowN + ']').val(week["Wednesday"]);
            $('[name=Thursday' + rowN + ']').val(week["Thursday"]);
            $('[name=Friday' + rowN + ']').val(week["Friday"]);
            $('[name=Saturday' + rowN + ']').val(week["Saturday"]);
            $('[name=DaysOn' + rowN + ']').val(daysOn);
            $('[name=DaysOff' + rowN + ']').val(7 - daysOn);
            $('[name=HrsperShift' + rowN + ']').val(hoursPerShift);

        };
    }
}

function PopulateEmployeeContactOO(employee, employeeType) {
    if (employee[0]) {
        $('[name="' + employeeType + 'FirstName"]').val(employee[0].EmpFirstName);
        $('[name="' + employeeType + 'LastName"]').val(employee[0].EmpLastName);
        $('[name="' + employeeType + 'Phone-Work"]').val(employee[0].Phone1);
        $('[name="' + employeeType + 'Phone-WorkExt"]').val(employee[0].PhoneExtension1);
        $('[name="' + employeeType + 'Phone-Home"]').val(employee[0].Phone2);
        $('[name="' + employeeType + 'Phone-Mobile"]').val(employee[0].Phone3);
        $('[name="' + employeeType + 'Email-Work"]').val(employee[0].Email);
        $('[name="' + employeeType + 'Fax"]').val(employee[0].Facsimile);
    }
}


//will return the html that is inserted into the section/subsection
function GetFormComponent(type, id, name, value, classes, label, placeholder) {

    switch (type) {
        case 'button':
            return '<button  id="' + id + '" class="wide btn btn-default ' + classes + '"   name="' + name + '">' + label + '</button>'
        case 'checkbox':
            return '<div class="checkbox checkbox-inline">' +
                        '<label for="'+ id +'">' +
                            '<input id="' + id + '" type="checkbox" name="' + name + '" value="' + value + '" class="' + classes + '" />' +
                            '' +
                            label +
                        '</label>' +
                   '</div>'
        case 'radio':
        case 'text':
        case 'date':
        case 'textarea':
            var label = '<label for=' + id + '>' + label + '</label>'
            var input = '<input id="' + id + '"type="' + type + '" name="' + name + '"  value="' + value + '" class="' + classes + '" placeholder="' + placeholder + '"/>'
            return '<div>' + label + input + '</div>'
        case 'select':
            var label = '<label for=' + id + '>' + label + '</label>'
            var select = '<select id="' + id + '" name="' + name + '" class="' + classes + '"></select>'
            return '<div>' + label + select + '</div>'
        case 'hidden':
            return '<input id="' + id + '"  value="' + value + '" name="' + name + '" type="hidden" class="' + classes + '" />'
        case 'file':
            var label = '<label class="btn btn-primary" for=' + id + '>' + label + '</label>'
            var input = '<input id="' + id + '"type="' + type + '" name="' + name + '"  class="' + classes + '" multiple="multiple"/>'
            return '<div>' + label + input + '</div>'
        case 'p':
            return '<p id="' + id + '" class="' + classes + '">' + label + '</p>'
        case 'time':
            var label = '<label for=' + id + '>' + label + '</label>'
            var input = '<input id="' + id + '" type="text" value="' + value + '" name="' + name + '" class="' + classes + '" placeholder="' + placeholder + '" readonly/>'
            return '<div>' + label + '<div class="input-group bootstrap-timepicker timepicker">' + input + '<span class="input-group-addon"><i class="glyphicon glyphicon-time" ></i></span></div></div>'
        case 'div':
            return '<div class="' + classes + '"></div>'
        default:
            return '';
        }
    
    }
    
function CreateFormSubsection(parentSection, groupName, controlLabel, classes) {
    if (controlLabel !== '') {
        parentSection.append('<div id="' + groupName + '" class="' + classes + '"><label class="subsection-label test">' + controlLabel + '</label></div>');
    }
    else {
        parentSection.append('<div id="' + groupName + '" class="' + classes + '"><label></label></div>');
    }

    return $('#' + groupName);
}
