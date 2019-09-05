
//This Java Script file will contain all the ajax calls to populate the lists  //Sam Khan
window.Country = "";
var Lang = "EN";
var LangGen = "_EN";

function PopulateLists() {

    var dfd = $.Deferred();

    var requests = [
        GetList("GetList_Gender", "populateGender", "Gen_EN"),
        GetList("GetList_JobClassification", "populateJobClassification", "Desc_EN"),
        GetList("GetList_JobStatus", "populateJobStatus", "Desc_EN"),
        GetList("GetList_SchType", "populateSchType", "SchType_EN"),
        GetList("GetList_RateType", "populateRateType", "RateType_EN"),
        GetList("GetList_Language", "populateLanguage", "Lang_EN"),
        GetList("GetList_ClaimStatus", "populateStatus", "Status_EN"),
        GetList("GetList_ClaimType", "populateType", "Type_EN"),
        GetList("GetList_BillingMethod", "populateBillingMethod", "Method_EN"),
        GetListDiffVal("GetBillingMethod", "populateBillingMethodwithID", "Method_EN", "MethodID", "Billing"),
        GetList("GetList_BillingMethod", "populateBillingMethod", "Method_EN"),
        GetList("GetList_ClaimActivity", "populateActionType", "ActivityType_EN"),
        //GetListDiffVal("GetUserProfileName_Internal", "populateInternalUserwithID", "EmpName", "UserID","DataBind"),
        //GetList("GetUserProfileName_Internal", "populateInternalUser", "EmpName"),
        GetListwithParameterandID("GetList_InsuranceCoverage", window.ClientID, "populateEmpClass", "Text_" + Lang, "Value"),

        GetList("GetList_Frequency", "populateFrequency", "Frequency_EN"),
        GetList("GetList_BenefitCode", "populateBenefitCode", "Benefit_Code_EN"),
        GetList("GetList_EarningsType", "populateEarningsType", "Earnings_Type_EN"),
        GetList("GetList_RoleType", "populateRoleType", "Role_EN"),
        GetList("GetList_ActivityLevel", "populateJobActivity", "ActivityLevel_EN"),
        GetList("GetList_CloseReasons", "populateCloseReasons", "Desc_EN"),
        GetList("GetList_AppealStatus", "populateAppealStatus", "Desc_En"),
        GetList("GetList_OSHA", "populateOSHACategory", "Desc_EN"),
        GetList("GetList_InsuranceOptions", "populateInsOption", "DESC_EN"),
        PopulateDivisions(window.ClientID, '.populateDivision'),

        PopulateGenericList("YesNo", "populateModWork", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("DaysType", "populateWaitPeriodType" + LangGen, "ListText", "ListValue"),
        PopulateGenericList("YesNo", "populateUnionized", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("YesNo", "populateJobPartnership", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("ReportLate", "populateReport", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("YesNo", "populateAbsences", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("AddressVerified", "populateAddress", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("CPPStatus", "populateCPPStatus", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("IncomeContStatus", "populateIncomeContStatus", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("ModDaysWeeks", "populateDaysWeeks", "ListText" + LangGen, "ListValue"),
        //GetListDiffVal('employeeoptions', '.employee-options', 'FullName', 'UserID', token + '/Users')
    ];

    PopulateCountries('populateCountries');
    PopulateCountries('populateWorkCountries');
    //AutoPopulateEmpInfo();
    AutoPopulateJobType();

    if (window.ClaimID) {
        GetListwithParameter("GetList_PopulateRF", window.ClaimID, "populateRF", "RFAssigned");
    }

    $.when.apply($, requests).done(function () {
        dfd.resolve();
    });

    return dfd.promise();

}

function PopulateListsExternal() {
    var dfd = $.Deferred();

    if (getCookie("Language") !== null) {
        Lang = getCookie("Language").substring(0, 2).toUpperCase();
        LangGen = "_" + getCookie("Language").substring(0, 2).toUpperCase();
    }

    var requests = [
        GetList("GetList_Gender", "populateGender", "Gen_" + Lang),
        GetList("GetList_JobStatus", "populateJobStatus", "Desc_" + Lang),
        GetList("GetList_Unions", "populateUnions", "UnionName"),
        GetList("GetList_TreatmentLocation", "populateTreatLoc", "Desc_" + Lang),
        GetList("GetList_AccidentCause", "populateAccidentCause", "Desc_" + Lang),
        GetList("GetList_SchType", "populateSchType", "SchType_" + Lang),
        GetList("GetList_RateType", "populateRateType", "RateType_" + Lang),
        GetList("GetList_Language", "populateLanguage", "Lang_" + Lang),
        GetList("GetList_Frequency", "populateFrequency", "Frequency_" + Lang),
        GetList("GetList_ReturnWorkType", "populateReturnWorkType", "WorkType_" + Lang),
        GetList("GetList_InjuryIllnessCause", "populateInjuryCause", "Desc_" + Lang),
        GetList("GetList_FamilyCareRelationship", "populateFCRelationship", "DESC_" + Lang),
        GetListwithParameterandID("GetList_InsuranceCoverage", window.ClientID, "PoulateCoverage", "Text_" + Lang, "Value"),
        GetListwithParameterandID("GetList_STDType", window.ClientID, "populateSTDType", "Text_" + Lang, "Value"),
        GetDataGeneric("Databind", "GetList_LOAType").done(PopulateLOAType),

        PopulateGenericList("WorkIssues", "populateWorkIssues", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("ModAvailable", "populateModAvailable", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("YesNo", "populateYesNo", "ListText" + LangGen, "ListValue"),
        PopulateGenericList("ModWorkStatus", "populateModWorkStatus", "ListText" + LangGen, "ListValue"),
        PopulateGenericList('ModRespSubmitter', 'populateModRespSubmitter', "ListText" + LangGen, "ListValue"),

        GetListRTWJX(),
        GetGenericListWithColumnsJX('ModRespSubmitter', 'populateLNLSub'),
        //GetListDiffVal('employeeoptions', '.employee-options', 'FullName', 'UserID', token + '/Users')

    ]

    //AutoPopulateEmpInfo_Demographic();

    $.when.apply($, requests).done(function () {
        dfd.resolve();
    });

    return dfd.promise();
}

//Populate the drop downs when the form is populated 
function PopulateGenericList(ListType, ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_Generic/" + ListType,
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateEAPProviderList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_EAPProvider",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateClaimSubmissionList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_ClaimSubmission",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateEvaluationTypeList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_EvaluationType",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateSTDProcessList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_STDProcess",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}


function PopulateSendAPSToEEList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_SendAPSToEE",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateProvidesRTWList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_ProvidesRTW",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateLTDProviderList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_LTDProvider",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateSendLTDToEEList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_SendLTDToEE",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateSendLTDToERList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_SendLTDToER",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateProvidesWCModDutyFormList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_ProvidesWCModDutyForm",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateLegalWCRepList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_LegalWCRep",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}

function PopulateFinancialModelWCBList(ClassName, Text, Value) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_FinancialModelWCB",
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + Text + ""]).attr('value', results[i]["" + Value + ""]));
            }
        }
    });
}









//Populate the drop downs when the form is populated 
function GetListwithParameter(ProcName, ParameterValue, ClassName, ColumnName) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/" + ProcName + "/" + ParameterValue,
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + ColumnName + ""]).attr('value', (results[i]["" + ColumnName + ""])));
            }
        }
    });
}

//Populate the drop downs when the form is populated 
function GetListwithParameterandID(ProcName, ParameterValue, ClassName, ColumnName, ColumnID) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/" + ProcName + "/" + ParameterValue,
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + ColumnName + ""]).attr('value', (results[i]["" + ColumnID + ""])));
            }
        }
    });
}
//Populate the drop downs when the form is populated 
function GetList(ProcName, ClassName, ColumnName) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/" + ProcName,
        success: function (data) {
            results = JSON.parse(data);

            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i][ColumnName]).attr('value', (results[i][ColumnName])));
            }
        }
    });
}

//Populate the drop downs when the form is populated with different value than result
function GetListDiffVal(ProcName, ClassName, ColumnName, ColumnVal, APIType) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/" + APIType + "/" + ProcName,
        success: function (data) {
            var results = JSON.parse(data);
            var target = $('.' + ClassName);
            target.empty();
            target.append($('<option>').text('--Select---').val(''));

            for (i = 0; i < results.length; i++) {
                target.append($('<option>').text(results[i][ColumnName]).attr('value', (results[i][ColumnVal])));
            }
        }
    });
}

//Populate the drop downs when the form is populated 
function GetContacts_Employee(ProcName, ClassName, ColumnName, Value) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/" + ProcName,
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + ColumnName + ""]).attr('value', (results[i]["" + ColumnName + ""])));
            }
            $("#ContactType").val(Value);
        }
    });
}
function GetContacts_Employer(ProcName, ClassName, ColumnName, Value) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/" + ProcName,
        success: function (data) {
            results = JSON.parse(data);
            $('.' + ClassName).append($('<option>').text('--Select---').val(''));
            for (i = 0; i < results.length; i++) {
                $('.' + ClassName).append($('<option>').text(results[i]["" + ColumnName + ""]).attr('value', (results[i]["" + ColumnName + ""])));
            }
            $("#ContactType").val(Value);
        }
    });
}

//Populate the reason dropdown when method is selected
$(document).on('change', '.populateBillingMethodwithID', function (event) {
    $('#BillingReason').empty();
    GetListwithParameterandID("GetList_BillingReason", event.target.value, "populateBillingReason", "Reason_EN", "ReasonID");
});

//The provinces would be populated based on the Country selection
$(document).on('change', '.populateProvinces', function (event) {
    $('select[name="province"]').empty();
    PopulateProvinces(event.target.value, "province")
});

//The cities would be populated based on the Province/State selection
$(document).on('change', '.populateCities', function (event) {
    $('select[name="city"]').empty();
    PopulateCities(event.target.value, "city")
});

//The cities would be populated based on the Province/State selection
$(document).on('change', '.populateWorkCities', function (event) {
    $('select[name="city_Work"]').empty();
    PopulateCities(event.target.value, "city_Work")
});
//The work provinces would be populated based on the Country selection
$(document).on('change', '.populateWorkProvinces', function (event) {
    $('select[name="province_Work"]').empty();
    PopulateProvinces(event.target.value, "province_Work");
});

$(document).on('click', '.clear-divisions', function () {
    $(this).parent('.breadcrumb').remove();
    PopulateDivisions(window.ClientID, '.populateDivision')
})

//Populate the [Country] drop down when the form is populated 
function PopulateCountries(DDClass) {
    return $.getJSON(getApi + "/api/DataBind/PopulateCountries", function (data) {
        results = JSON.parse(data);
        $('.' + DDClass).append($('<option>').text('Select').val(''));
        for (i = 0; i < results.length; i++) {
            $('.' + DDClass).append($('<option>').text(results[i]["Country_Name"]).attr('value', results[i]["Country_ISO_Code"]));
        }
    });
}

//re-wrote so it is not asynchronous //mgougeon
function PopulateProvinces(CountryID, DDName) {
    if (CountryID)
        return $.ajax({
            url: getApi + "/api/DataBind/PopulateProvinces/" + CountryID,
            async: false,
            success: function (data) {
                var results = JSON.parse(data);
                var target = $('select[name*="' + DDName + '"]');

                target.append($('<option>').text('Select').val(''));
                for (i = 0; i < results.length; i++) {
                    target.append($('<option>').text(results[i]["Sub_Name"]).attr('value', results[i]["Sub_Name"]));
                }
            }
        });
}
//re-wrote so it is not asynchronous //mgougeon
//by the way, subname is apparently region name - ex. province //mgougeon
function PopulateCities(SubName, DDName) {
    if (SubName)
        return $.ajax({
            url: getApi + "/api/DataBind/PopulateCities/" + SubName,
            async: false,
            success: function (data) {
                var results = JSON.parse(data);
                var target = $('select[name*="' + DDName + '"]');
                target.empty();
                target.append($('<option>').text('Select').val(''));
                for (i = 0; i < results.length; i++) {
                    target.append($('<option>').text(results[i]["City_Name"]).attr('value', results[i]["City_Name"]));

                }
            }
        });
}

function PopulateDivisions(clientId, selector) {
    return $.ajax({
        url: getApi + "/api/client/" + clientId + "/divisions",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        success: function (data) {
            var divisions = JSON.parse(data);
            var target = $(selector);
            target.empty();
            target.append('<option value="">Select</option>');
            target.data('divisions', divisions);

            divisions.map(function (d) {
                if (d.ParentID == 0) {
                    target.append('<option id="' + d.ClientID + '" value="' + d.DivisionName + '">' + d.DivisionName + '</option>');
                }
            });
        }
    });
};

function SetDivision(value, target) {
    if (!value)
        return;

    var divisions = target.data('divisions')
    var division = divisions.filter(function (d) {
        return d.DivisionName == value;
    })[0];
    var divisionPath = [value]

    for (var i = divisions.length - 1; i >= 0; i--) {
        if (divisions[i].ClientID != division.ParentID)
            continue;

        divisionPath.push(divisions[i].DivisionName)
        division = divisions[i];
    }

    for (var i = divisionPath.length - 1; i >= 0; i--) {
        target.val(divisionPath[i]);
        target.trigger('change');
    }
}

//Populate the JobType dropdown when JobType is input
function AutoPopulateJobType() {
    $('.autoPopulateJobType').autocomplete({
        source: function (request, response) {
            $.ajax({
                url: getApi + "/api/DataBind/AutoPopulateJobTypes/" + request.term,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                dataType: "json",
                data: {

                    q: request.term
                },
                success: function (data) {
                    response(JSON.parse(data));
                    response($.map(JSON.parse(data), function (val, index) {
                        return {
                            label: val.Desc_EN, value: val.Desc_EN
                        };
                    }));

                }
            });

        },
        minLength: 4,
    });
}

/*  //Autopopulate the Portal with employees from the Old Orgsys Demographic Files //MGougeon
 *  ----
    * They Key in the KeyValue Pair is the name of the column from OldOrgsys Demographic File. These column names will eventually be universal.
    * The Key in the KeyValue Pair can be found in the data-demographicinfo attr on the field, loaded on the DOM when BusRules is applied (taken from DemographicColumn column).
    * If you would like to add a new field, ensure in bus rules there is an entry, ensure it is the same as the column, and add it to the list.
    * Eventually we will have a complete list when all Demographic files are included and we will not need to fill these anymore.
    * KeyValue pairs are dynamically loaded from OldOrgsysGetData, where the Demographic Table is fed in by ImportID.
 */
function AutoPopulateEmpInfo_Demographic() {
    $('.populateEmpNames').autocomplete({
        source: function (request, response) {
            $.ajax({
                url: getApi + "/api/OldOrgsysGetData/GetEmployeeInformationOldOrgsys/" + request.term + "/" + Token,
                dataType: "json",
                data: {
                    q: request.term
                },
                success: function (data) {
                    response($.map(JSON.parse(data), function (val, index) {
                        //FORMAT DATES from DateInput.JS
                        var DOB = ToJavaScriptDate(val.DateOfBirth);
                        var DOH = ToJavaScriptDate(val.DateofHire);

                        return {
                            label: val.EmployeeFirstName + " " + val.EmployeeLastName, EmployeeLastName: val.EmployeeLastName
                            , EmployeeFirstName: val.EmployeeFirstName, EmployeeNumber: val.EmployeeNumber, DOB: DOB,
                            Gender: val.Gender, Language: val.LanguagePreference, Address: val.Address, Address2: val.Address2,
                            City: val.City, PostalCode: val.PostalCode, Province: val.Province, Country: val.Country,
                            HomePhoneNumber: val.HomePhoneNumber, WorkPhoneNumber: val.WorkPhoneNumber,
                            EMailAddress: val.EMailAddress, DOH: DOH, JobTitle: val.JobTitle, WorkStatus: val.WorkStatus,
                            HourlyRate: val.HourlyRate, PayFrequency: val.PayFrequency, Site: val.Site, Division: val.Division, Department: val.Department,
                            ManagerLastName: val.ManagerLastName, ManagerFirstName: val.ManagerFirstName, ManagerPhone: val.ManagerPhoneNumber, ManagerEmail: val.ManagerEMail,
                            SupervisorLastName: val.SupervisorLastName, SupervisorFirstName: val.SupervisorFirstName, SupervisorPhone: val.SupervisorPhoneNumber, SupervisorEmail: val.SupervisorEMail
                        };
                    }));
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            var siteName;
            var divName;
            $("[data-demographicinfo]").each(function () {

                var demodata = $(this).data('demographicinfo');

                //Populate Province for Autocomplete
                if ($(this).hasClass("province")) {
                    var countryid = $(".populateCountries").val();
                    PopulateProvinces(countryid, "Province");
                }

                //Populate City for Autocomplete
                if ($(this).hasClass("city")) {
                    var provinceName = $(".province").val();
                    PopulateCities(provinceName, "City");
                }

                //Populate Site/Division/Department for Autocomplete
                if ($(this).hasClass("site")) {
                    $(".site").val(ui.item[demodata]).change();
                    siteName = $(".site").val();

                } else if ($(this).hasClass("div")) {
                    PopulateDivision(siteName, "BusDiv");
                    $(".div").val(ui.item[demodata]).change();
                    divName = $(".div").val();

                } else if ($(this).hasClass("dept")) {
                    PopulateDepartment(divName, "BusDept");
                    $(".dept").val(ui.item[demodata]);
                }

                //Populate the rest of the fields for Autocomplete
                $(this).val(ui.item[demodata]);

            });
        }
    });
    return 0;
};

function GetProfilesForAutocomplete() {
    let easyAutocompleteOptions = {
        data: [],
        getValue: "EmpLastName",
        list: {
            match: {
                enabled: true
            },
            onClickEvent: function () {
                autoFillFormExternal($("[name='EmpLastName']").getSelectedItemData());
            }
        },
        template: {
            type: "custom",
            method: function (value, item) {
                return item.EmpFirstName + " " + value;
            }
        }
    };
    $.ajax({
        url: window.getApi + "/api/" + window.token + "/Users/employeeoptionsExternal/",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: "POST"
    }).then(function (response) {
        var userProfiles = JSON.parse(response);
        easyAutocompleteOptions.data = userProfiles;
        $("[name='EmpLastName']").easyAutocomplete(easyAutocompleteOptions);
    });
}

function autoFillFormExternal(userProfileObject) {
    //The keys of this object are related to the IDs of the form elements
    var userProfileFormObject = {
        AddressLine1: userProfileObject.Address,
        AddressLine2: userProfileObject.AddressLine2,
        City: userProfileObject.City,
        Country: userProfileObject.Country,
        DOB: userProfileObject.DOB,
        Email: userProfileObject.Email,
        EmpFirstName: userProfileObject.EmpFirstName,
        EmpLastName: userProfileObject.EmpLastName,
        EmpNu: userProfileObject.EmployeeNumber,
        Ext: userProfileObject.Ext,
        Fax: userProfileObject.Fax,
        Gender: userProfileObject.Gender,
        HiringDate: userProfileObject.HiringDate,
        HomePhone: userProfileObject.HomePhone,
        JobClassification: userProfileObject.JobClassification,
        JobDescription: userProfileObject.JobDescription,
        JobGrade: userProfileObject.JobGrade,
        JobStatus: userProfileObject.JobStatus,
        JobTitle: userProfileObject.JobTitle,
        Language: userProfileObject.Language,
        AddressUpdated: userProfileObject.LastUpdated,
        OrgCode: userProfileObject.OrgCode,
        Province: userProfileObject.Province,
        SIN: userProfileObject.SIN,
        SalaryGrade: userProfileObject.SalaryGrade,
        WorkPhone: userProfileObject.WorkPhone,
        YearsOfService: userProfileObject.YearsOfService,
        Zip: userProfileObject.Zip
    }
    for (let property in userProfileFormObject) {
        if (!property == 'Country' && !property == 'Province' && !property == 'City') {
            $("[name='" + property + "']").val(userProfileFormObject[property]);
        }
    }
}

//need seperate implementation since options save to separate columns //abovtenko
function GetListRTWJX() {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_RTW",
        success: function (data) {
            var rtw = JSON.parse(data);
            var target = $('[name="RTWType"]').addClass('selectColumnName').append('<option>Select</option>');

            $.each(rtw, function (key, val) {
                var option = $('<option>' + val['Desc_En'] + '</option>')
                    .append('<input type="hidden" name="' + val['ColumnName'] + '" />');

                target.append(option);
            });
        }
    });
}

//need seperate implementation since options save to separate columns //abovtenko
function GetGenericListWithColumnsJX(listType, className) {
    return $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/GetList_Generic/" + listType,
        success: function (data) {
            var result = JSON.parse(data);
            //must add class to business rules
            var target = $('.' + className).addClass('selectColumnName').append('<option>Select</option>');

            $.each(result, function (key, val) {
                var option = $('<option value="' + val['ListValue'] + '">' + val['ListText'] + '</option>')
                    .append('<input type="hidden" name="' + val['ColumnName'] + '" />');

                target.append(option);
            });
        }
    });
}

function PopulateLOAType(listOptions) {
    var target = $('.populateLOAType');
    target.append('<option>Select</option>')

    listOptions.forEach(function (o) {
        var option = $('<option value="' + o.ClaimTypeID + '">' + o["LOA_" + Lang] + '</option>')
            .data('description', o.Description_EN)
            .data('sectionId', o.Section);
        target.append(option);
    })
}

/**
 * Send get request to api and return thenable object
 * @param {any} controller
 * @param {any} method
 * @param {any} parameterArray optional
 */
function GetDataGeneric(controller, method, parameterArray, asyncBool) {

    asyncBool = (asyncBool === undefined) ? true : asyncBool;
    parameterArray = parameterArray || []                               //optional parameter    
    if (!$.isArray(parameterArray)) parameterArray = [parameterArray];  //allow passing single non-array value

    var endpoint = getApi + '/api/' + controller + '/' + method + '/' + parameterArray.join('/');

    return $.ajax({
        url: endpoint,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: asyncBool
    }).then(function (data) {
        return JSON.parse(data);
    });

}

window.AttachDivisionBreadcrumbs = function () {
    var target = $(this);
    var divisionName = target.find(':selected').val();
    var parentId = target.find(':selected').attr('id');

    var displaySection = $('.division-display');
    var displaySectionHasDivision = displaySection
        .find('li')
        .filter(function () {
            return this.innerText === divisionName
        })
        .length === 1;

    if (divisionName === '' || displaySectionHasDivision) return;

    AppendDivisionBreadcrumb(displaySection, divisionName)
    target.find('option').not(':selected, :first').remove(); //keep so that validation can ensure a selection was made and the value is (getable)
    target
        .data('divisions')
        .map(function (d) {
            if (d.ParentID == parentId)
                target.append('<option id="' + d.ClientID + '" value="' + d.DivisionName + '">' + d.DivisionName + '</option>');
        });
}

window.AppendDivisionBreadcrumb = function (displaySection, value) {
    var displayIsEmpty = displaySection.get(0).innerText === "";

    if (displayIsEmpty)
        displaySection.append('<ol class="breadcrumb"><span class="btn clear-divisions glyphicon glyphicon-remove"></span></ol>')

    displaySection.find('.breadcrumb').append('<li>' + value + '</li>');
}

$(document).on('change', '.populateDivision', AttachDivisionBreadcrumbs);
