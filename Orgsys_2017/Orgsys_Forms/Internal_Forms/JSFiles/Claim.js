
//Created By - Sam Khan
//Updated - 03/15/2018 - Marie Gougeon
var postData = "";

function CreateClaimObjects() {
    var Dates = [];
    var DocDates = [];
    var AbsDates = [];
    var Contacts = [];
    var BillComments = [];
    var ContactType = [];

    //Creating a Claim Object
    var Claim = {
        Status: window.ClaimStatus,
        Type: $('#ClaimType').val(),
        Adjudicator: $('#Adjudicator').val(),
        ClaimStatus: $('#ClaimStatus').val(),
        ClaimRefNu: $('#ClaimRefNu').val(),
        ReasonLate: $('#ReasonLate').val(),
        ReportLate: $('#ReportLate').prop("checked") ? true : false,
        AccTracNu: $('#AccTracNu').val(),
        WSIBClaimNu: $('#WSIBClaimNu').val(),
        GradualRTW: $('#gradRTW').prop("checked") ? true : false,
        AbsenceRecurred: $('#absRecurred').prop("checked") ? true : false,
        Attorney: $('#Attorney').prop("checked") ? true : false,
        EAP: $('#EAP').prop("checked") ? true : false,
        CriticalInjury: $('#CriticalInjury').prop("checked") ? true : false,
        FileAppeal: $('#FileAppeal').prop("checked") ? true : false,
        FileAudit: $('#FileAudit').prop("checked") ? true : false,
        SafetySensitiveJob: $('#SafetySensitiveJob').prop("checked") ? true : false,
        AppealStatus: $('#AppealStatus').val(),
        AuditDate: $('#AuditDate').data('iso-date'),
        Complex: $('#Complex').prop("checked") ? true : false,
        WorkIssues: $('#WorkIssues').prop("checked") ? true : false,
        PreExisCondition: $('#PreExisCondition').prop("checked") ? true : false,
        FileArchieved: $('#FileArchieved').prop("checked") ? true : false,
        OSHACategory: $('#OSHACategory').val(),
        Diagnosis: $('#claimDiagnosis').val(),
        Description: formName,
        ClientID: window.ClientID,
        DateCreation: new Date(),
        UserSubmitted: UserID,
        DateFirstOff: $('#DateFirstOff').data('iso-date'),
        DateLastWorked: $('#DateLastWorked').data('iso-date'),

        //More Mising fields added 
        InsuredLTD: $('#InsuredLTD').val(),
        STDPeriod_Weeks: $('#STDPeriod_Weeks').val(),
        LTDPeriod_Weeks: $('#LTDPeriod_Weeks').val(),
        WaitPeriod_Days: $('#WaitPeriod_Days').val(),
        WaitPeriod_Type: $('#WaitPeriod_Type').val(),
        
        //Few more missing fileds added ---08/14/2018 
        //MedicalAttention: $('#WaitPeriod_Type').val(), wrong value assigned ? /abovtenko
        ModifiedWork: $('#ModifiedWork').val(),
        AssignmentNo: $('#AssignmentNo').val(),
        CostCenter: $('#CostCenter').val(),
        IncidentDate: $('#IncidentDate').data('iso-date'),
        ReferralDate: $('#DateCreation').data('iso-date'),
        LTDDate: $("#LTDDate").data('iso-date'),
        LTDTargetDate: $("#LTDTargetDate").data('iso-date')
    }


    var RegSch = [];

    var htmlTable = $('#tblSchedule');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            RegSch.push({
                DaysOn: $tds.eq(1).text(),
                DaysOff: $tds.eq(2).text(),
                ScheduledDayOff: $tds.eq(3).text(),
                Hours_Total: $tds.eq(4).text(),
                WeekNo: $tds.eq(5).text(),
                Sunday: $tds.eq(6).text(),
                Monday: $tds.eq(7).text(),
                Tuesday: $tds.eq(8).text(),
                Wednesday: $tds.eq(9).text(),
                Thursday: $tds.eq(10).text(),
                Friday: $tds.eq(11).text(),
                Saturday: $tds.eq(12).text(),
                ScheduleType: $('[name=scheduleType]').val()

            })
        }

    });

    //It could be a just one call

    //Claim Contacts [Employer]

    var htmlTable = $('#tblEmployer');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            Contacts.push({
                ContactType: $tds.eq(1).text(),
                Con_LastName: $tds.eq(2).text(),
                Con_FirstName: $tds.eq(3).text(),
                Con_Title: $tds.eq(4).text(),
                Con_WorkPhone: $tds.eq(5).text(),
                Con_Ext: $tds.eq(6).text(),
                Con_Email: $tds.eq(7).text(),
                Con_TypeID: 0,
                Archived: 0,
                ClaimRefNu: $('#ClaimRefNu').val()
            })
        }
    });
    //Claim Contacts [Physician]

    var htmlTable = $('#tblPhysicians');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            Contacts.push({
                ContactType: $tds.eq(1).text(),
                Con_LastName: $tds.eq(2).text(),
                Con_FirstName: $tds.eq(3).text(),
                Con_Title: $tds.eq(4).text(),
                Con_WorkPhone: $tds.eq(5).text(),
                Con_Ext: $tds.eq(6).text(),
                Con_Email: $tds.eq(8).text(),
                Con_Fax: $tds.eq(7).text(),
                Con_TypeID: 1,
                Archived: 0,
                ClaimRefNu: $('#ClaimRefNu').val()
            })
        }
    });


    //Claim Contacts [Others]

    var htmlTable = $('#tblOther');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            Contacts.push({
                ContactType: $tds.eq(1).text(),
                Con_LastName: $tds.eq(2).text(),
                Con_FirstName: $tds.eq(3).text(),
                Con_Title: $tds.eq(4).text(),
                Con_WorkPhone: $tds.eq(5).text(),
                Con_Ext: $tds.eq(7).text(),
                Con_Email: $tds.eq(6).text(),
                Con_TypeID: 2,
                Archived: 0,
                ClaimRefNu: $('#ClaimRefNu').val()
            });
        }
    });
    //Earnings
    var PayrollEar = [];
    var htmlTable = $('#tblPayRollEar');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            PayrollEar.push({
                EarningsType: $tds.eq(1).text(),
                ValidFrom: ConvertDateCustomToIso($tds.eq(2).text()),
                ValidTo: ConvertDateCustomToIso($tds.eq(3).text()),
                GrossEarnings: $tds.eq(4).text(),
                GrossEarningsType: $tds.eq(5).text(),
                FederalTaxes: $tds.eq(6).text(),
                ProvincialTaxes: $tds.eq(7).text(),
                CPPContributions: $tds.eq(8).text(),
                EIContributions: $tds.eq(9).text(),
                WorkHours: $tds.eq(10).text()
            })
        }
    });

    //Offsets
    var Offset = [];
    var htmlTable = $('#tblOffset');

    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            Offset.push({
                OffsetType: $tds.eq(1).text(),
                OffsetFrom: ConvertDateCustomToIso($tds.eq(2).text()),
                OffsetTo: ConvertDateCustomToIso( $tds.eq(3).text()),
                Period: $tds.eq(4).text(),
                GrossAmount: $tds.eq(5).text(),
                NetAmount: $tds.eq(6).text(),

            });
        }
    });

    var Insurance = [];

    $('#insuranceOption li').each(function () {
        Insurance.push(
            {
                InsuranceType: $(this).data('value')
            });
    });


    //Disability
    var preDis = [];
    var htmlTable = $('#tblPreDisability');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            preDis.push({
                DateFrom: $tds.eq(1).text(),
                DateTo: $tds.eq(2).text(),
                Amount: $tds.eq(3).text(),
                WorkHours: $tds.eq(4).text(),
                IncomeType: $tds.eq(5).text(),
                ClientConfirmed: $tds.eq(6).text()
            });
        }
    });

    ////Creating a Schedule object
    //$(".RegSchedule").each(function (index) {
    //    // index += 1
    //    RegSch.push({
    //        WeekNo: index,
    //        ScheduleType: $('[name=scheduleType]').val(),
    //        WeekStart: $('#Reg_Start_Date' + index).val(),
    //        WeekEnd: $('#Reg_End_Date' + index).val(),
    //        DaysOn: $('#Reg_Days_On' + index).val(),
    //        DaysOff: $('#Reg_Days_Off' + index).val(),
    //        Hours_Total: $('#Reg_Hrs_Total' + index).val(),
    //        ScheduleType: $('#RTW_Week_Date' + index).val(),
    //        Sunday: $('#Reg_Hrs_Sun' + index).val(),
    //        Monday: $('#Reg_Hrs_Mon' + index).val(),
    //        Tuesday: $('#Reg_Hrs_Tue' + index).val(),
    //        Wednesday: $('#Reg_Hrs_Wed' + index).val(),
    //        Thursday: $('#Reg_Hrs_Thu' + index).val(),
    //        Friday: $('#Reg_Hrs_Fri' + index).val(),
    //        Saturday: $('#Reg_Hrs_Sat' + index).val()

    //    })
    //});
    //Will delete it later as moved billing to Claim Dates
    //creating a billing object
    var k = 0;
    var commCounter = $('#commentCounter').val();
    if (commCounter) {
        var type = $('.comment1').map(function () {
            return $(this).val();
        });
        var description = $('.comment2').map(function () {
            return $(this).val();
        });

        var provider = $('.comment3').map(function () {
            return $(this).val();
        });
        var source = $('.comment4').map(function () {
            return $(this).val();
        });
        var code = $('.comment5').map(function () {
            return $(this).val();
        });
        var action = $('.comment6').map(function () {
            return $(this).val();
        });
        var billable = $('.comment7').map(function () {
            return $(this).val();
        });
        var date = $('.comment8').map(function () {
            return $(this).val();
        });
        var time = $('.comment9').map(function () {
            return $(this).val();
        });
        var completed = $('.comment10').map(function () {
            return $(this).val();
        });
        var completionDate = $('.comment11').map(function () {
            return $(this).val();
        });
        var duration = $('.comment12').map(function () {
            return $(this).val();
        });
        var billedby = $('.comment13').map(function () {
            return $(this).val();
        });
        var directContact = $('.comment14').map(function () {
            return $(this).val();
        });
        var postage = $('.comment15').map(function () {
            return $(this).val();
        });
        var courier = $('.comment16').map(function () {
            return $(this).val();
        });
        var method = $('.comment17').map(function () {
            return $(this).val();
        });
        var reason = $('.comment18').map(function () {
            return $(this).val();
        });
        for (i = 0; i < parseInt(commCounter) ; i++) {

            if (billable[i] == "true") {
                var Billing = {
                    BillDate: date[k],
                    BillTime: time[k],
                    Completed: completed[k],
                    BilledBy: billedby[k],
                    DirectContact: directContact[k] == "yes" ? true : false,
                    Postage: postage[k] == "yes" ? true : false,
                    Courier: courier[k] == "yes" ? true : false,
                    BillMethod: method[k],
                    BillReason: reason[k],
                    CompletionDate: completionDate[k],
                    ClientID: ClientId
                };
                var billComment = {
                    CommentType: type[i],
                    CommentDescription: description[i],
                    Provider: provider[i],
                    Source: source[i],
                    Code: code[i],
                    Action: action[i],
                    Billable: billable[i]
                };
                k++;
                BillComments.push({
                    objComm: billComment,
                    objBilling: Billing
                });
            }
            else {
                var nonBillComment = {
                    CommentType: type[i],
                    CommentDescription: description[i],
                    Provider: provider[i],
                    Source: source[i],
                    Code: code[i],
                    Action: action[i],
                    Billable: billable[i]
                };
                BillComments.push({
                    objComm: nonBillComment
                });
            }
        }

    }
    //
    // Creating a dates object
    var datesControl = ["EEReported","MMAR","LTDDate","LTDTargetDate","COD","EstDateClosed", "dateOfRetire", "dateOfDeath", "EEReports", "codFirstWarn", "codSecondWarn","stdStart","stdEnd", "eiStart","eiEnd","ltdStart","ltdEnd"];
   // var datesControl = ["dateOfAccident", "dateOfReferal", "initialContact", "nextFollowUp", "dateClosed", "EEReports", "profile", "dateOfDeath", "dateOfRetire", "APSDate", "codFirstWarn", "codSecondWarn", "PkgDate", "MWPInDate", "MWPOutDate", "firstCall", "IMEDate", "FEDate", "firstDayOff", "lastDayWorked", "rtwAuth", "OSIRTM", "OSIRTF", "ltdStart", "ltdTarget", "ltdOut", "stdPeriod", "endStd"];
    $.each(datesControl, function (key, value) {
        var control = $('#' + value);
        if (control.length > 0 && control.val() != "") {
            Dates.push({
                DateDescription: value,
                OccurenceDate: $('#' + value).data('iso-date')
            });
        }
    });
    console.log("Dates");
    console.log(Dates);
    //Creating a Doc dates object
    var dateCounter = $('#dateCounter').val();
    if (dateCounter) {
        var dateOcc = $('.date1').map(function () {
            return $(this).val();
        });
        var dateDesc = $('.date2').map(function () {
            return $(this).val();
        });
        for (i = 0; i < parseInt(dateCounter); i++) {
            DocDates.push({
                OccurenceDate: dateOcc[i],
                DateDescription: dateDesc[i]
            });
        }
    }
    //Creating an Abs dates Object
    var absCounter = $('#absCounter').val();
    if (absCounter) {
        var status = $('.schedule1').map(function () {
            return $(this).val();
        });
        var hours = $('.schedule2').map(function () {
            return $(this).val();
        });
        var dateTo = $('.schedule3').map(function () {
            return $(this).val();
        });
        var dateFrom = $('.schedule4').map(function () {
            return $(this).val();
        });
        for (i = 0; i < parseInt(absCounter); i++) {
            AbsDates.push({
                Status: status[i],
                Hours: parseInt(hours[i]),
                DateTo: dateTo[i],
                DateFrom: dateFrom[i]
            });
        }
    }

    // Creating an Employee Object
    var Employee = {
        EmpLastName: $('#EmpLastName').val(),
        EmpFirstName: $('#EmpFirstName').val(),
        EmpNu: $('#EmpNu').val(),
        DOB: $('#DOB').data('iso-date'),
        Gender: $('#Gender').val(),
        Language: $('#Language').val(),
        AddressLine1: $('#AddressLine1').val(),
        AddressLine2: $('#AddressLine2').val(),
        City: $('#City').val(),
        Zip: $('#Zip').val(),
        Province: $('#Province').val(),
        Country: $('#Country').val(),
        HomePhone: $('#HomePhone').val(),
        Fax: $('#Fax').val(),
        WorkPhone: $('#WorkPhone').val(),
        Ext: $('#Ext').val(),
        Email: $('#Email').val(),
        //if (Request.Form["DOH"] !: string.Empty)
        HiringDate: $('#HiringDate').data('iso-date'),
        AddressVerified: $('#AddressVerified').val(),
        AddressUpdated: $('#AddressUpdated').val(),
        BusUnit: $('#BusUnit').val(),
        BusDiv: $('#BusDiv').val(),
        BusDept: $('#BusDept').val(),
        AccountNum: $('#AccountNum').val(),
        PrefFirstName: $('#PrefFirstName').val(),
        SIN: $('#SIN').val()
    };
    //Creating a Contact Type Object
    var htmlTable = $('#tblEmployee');
    htmlTable.find('tbody > tr').each(function () {
        var $tds = $(this).find('td');
        if (htmlTable.length > 0 && $tds.eq(0).text() != "No data available in table") {
            ContactType.push({
                ContactType: $tds.eq(1).text(),
                ContactDetail: $tds.eq(2).text(),
                Ext: $tds.eq(3).text(),
                PriorityOrder: $tds.eq(4).text(),
                PreferredTOD: $tds.eq(5).text(),
                Archived: 0,
                ClaimReference: $('#ClaimRefNu').val()
            });
        }
    });
    //Creating a Doctor Object
    $(".panelDoctor").each(function (index) {
        var Doctor = [];
        index += 1;
        Doctor.push({
            DoctorType: $('#DoctorType' + index).val(),
            FullName: $('#FullName' + index).val(),
            Address: $('#Address' + index).val(),
            PhoneNo: $('#PhoneNo' + index).val(),
            Fax: $('#Fax' + index).val(),
            Email: $('#Email' + index).val()
        });
        //console.log(index);
    });
    // Creating a Job Object
    var Job = {
        JobTitle: $('#JobTitle').val(),
        JobStatus: $('#JobStatus').val(),
        JobRole: $('#JobRole').val(),
        JobCode: $('#JobCode').val(),
        JobActivityLevel: $('#JobActivityLevel').val(),
        SeniorityDate: $('#SeniorityDate').data('iso-date'),
        JobEntryDate: $('#JobEntryDate').data('iso-date'),
        Unionized: $('#Unionized').val(),
        UnionName: $('#UnionName').val(),
        JobPartnership: $('#JobPartnership').val(),

        // Incorporating Job Locations details
        Code_Work: $('#Code_Work').val(),
        Country_Work: $('#Country_Work').val(),
        Province_Work: $('#Province_Work').val(),
        Postal_Work: $('#Postal_Work').val(),
        City_Work: $('#City_Work').val(),
        Address1_Work: $('#Address1_Work').val(),
        Address2_Work: $('#Address2_Work').val()
    };

    // Creating a Pay Object
    var Pay = {
        PayGroup: $('#PayGroup').val(),
        RegRatePay: $('#RegRatePay').val(),
        VacationPay: $('#VacationPay').val(),
        VacPayPercentage: $('#VacPayPercentage').val(),
        STD: $('#STD').val(),
        PayCycle: $('#PayCycle').val()
    };

    //Creating a Payroll Object

    var Payroll = {
        DateLastPaid: $('#DateLastPaid').data('iso-date'),
        EmpClass: $('#EmpClass').val(),
        ContractDate: $('#ContractDate').data('iso-date'),
        PayFreq: $('#PayFreq').val(),
        IncomeContStatus: $('#IncomeContStatus').val(),
        IncomeContDate: $('#IncomeContDate').data('iso-date'),
        CPPStatus: $('#CPPStatus').val(),
        LTDCode: $('#LTDCode').val()
    };

    var AdditionalDetails = {
        PerformanceIssues: $('#PerformanceIssues').val(),
        AttendanceIssues: $('#AttendanceIssues').val(),
        ChangeInDuties: $('#ChangeInDuties').val(),
        WorkplaceConflicts: $('#WorkplaceConflicts').val(),
        OtherIssues: $('#OtherIssues').val(),
        IssueDescription: $('#IssueDescription').val()
    }

    ////Creating an Insurance Object
    //var Insurance = {
    //    RateType: $('#RateType').val(),
    //    Rate: $('#Rate').val(),
    //    WeeklyRate: $('#WeeklyRate').val(),
    //    WeeklyHours: $('#WeeklyHours').val(),
    //    RegHours: $('#RegHours').val(),
    //    ModifiedHours: $('#ModHours').val(),
    //    SEIFFunds: $('#SEIFFunds').val(),
    //    SIEFOutDate: $('#SIEFOutDate').data('iso-date'),
    //    SIEFInDate: $('#SIEFInDate').data('iso-date'),
    //    TotalCost: $('#TotalCost').val(),
    //    SIEFIn: $('#SIEFIn').val(),
    //    SIEFOut: $('#SIEFOut').val(),
    //    ClaimCost: $('#ClaimCost').val(),
    //    CostReserve: $('#CostReserve').val(),
    //    ReservePrevious: $('#ReservePrevious').val(),
    //    CostReduction: $('#CostReduction').val()
    //}
    //Creating Rot Schedule Object
    var RotSchedule = {
        ScheduleType: $('#ScheduleType').val(),
        WorkDaysOff: $('#WorkDaysOff').val(),
        WorkDaysOn: $('#WorkDaysOn').val(),
        WorkScheduledDayOff: $('#WorkScheduledDayOff').val(),
        WorkHoursShift: $('#WorkHoursShift').val(),
        WorkWeeksCycle: $('#WorkWeeksCycle').val()
    };
    //Creating Reg Schedule Object
    var RegSchedule = {
        Mon: $('#Mon').val(),
        Tue: $('#Tue').val(),
        Wed: $('#Wed').val(),
        Thur: $('#Thur').val(),
        Fri: $('#Fri').val(),
        Sat: $('#Sat').val(),
        Sun: $('#Sun').val()
    };
    
    //A custom function to left merge two objects
    function leftMergeTwoObjects(leftObject, rightObject) {
        const res = {};
        for (const p in leftObject)
            res[p] = (p in rightObject ? rightObject : leftObject)[p];
        return res;
    }

    function createObjectArrayByObjectProperties(rows, objectConst) {
        var objectArray = [];
        rows.each(function (row, index) {
            var object = Object.assign({}, objectConst);
            $.each(object, function (key, value) {
                object[key] = row[key];
            });
            objectArray.push(object);
        });
        return objectArray;
    }

    var incidentObject = PrimaryIncidentModel.incident;
    var icdcmCategoryObject = IcdcmCategoryModel;
    const WitnessModel = { WitnessEmail: "", WitnessName: "", WitnessPhone: "", WitnessStatement: "" };
    const LimitModel = { LimitDateTime: "", LimitDescription: "" };
    const ActionModel = { JHSCM: "", CorrDescription: "", CorrDateTime: "", CorrReason: "" };
    const DamageModelProps = { DamReason: "", DamType: "", Make: "", Model: "", Plate: "", PropDescription: "", PropertyType: "", Year: "", AnimalDesc: "", AnimalType: "", OwnerContact: "", OwnerName: "" };
    const DamageModel = { objDamage: { DamReason: "", DamType: "" }, objAni: { AnimalDesc: "", AnimalType: "", OwnerContact: "", OwnerName: "" }, objProp: { Make: "", Model: "", Plate: "", PropDescription: "", PropertyType: "", Year: "" } };
    let Incidents = [];
    $("div[data-id='primaryIncident']").each(function () {
        const primaryIncidentID = $(this).attr("data-primaryincidentid");

        //Gets related table data for the primary incident
        const witnessDataTableRows = $(`#WitnessDetailsTable_${primaryIncidentID}`).DataTable().rows().data();
        const limitDataTableRows = $(`#LimitationDetailsTable_${primaryIncidentID}`).DataTable().rows().data();
        const actionDataTableRows = $(`#CorrectiveActionsTable_${primaryIncidentID}`).DataTable().rows().data();
        const damageDataTableRows = $(`#CollateralDamagesTable_${primaryIncidentID}`).DataTable().rows().data();

        const witnesses = createObjectArrayByObjectModel(witnessDataTableRows, WitnessModel);
        const limitations = createObjectArrayByObjectModel(limitDataTableRows, LimitModel);
        const actions = createObjectArrayByObjectModel(actionDataTableRows, ActionModel);

        let objDamages = [];
        damageDataTableRows.each(function (damageRow, index) {
            let damage = Object.assign({}, DamageModel);
            damage.objDamage = leftMergeTwoObjects(damage.objDamage, damageRow);
            damage.objAni = leftMergeTwoObjects(damage.objAni, damageRow.data);
            damage.objProp = leftMergeTwoObjects(damage.objProp, damageRow.data);
            objDamages.push(damage);
        });

        let objCategories = [];
        //save data from icdcm categories
        $(this).find("div[id*='ICDCMCategoryTabPane']").each(function () {
            const icdcmCategoryID = $(this).attr("data-icdcmcategoryid");
            let bodyParts = [], medications = [], activities = [];

            const bodyPartTableRows = $("#BodyPartsTable_" + icdcmCategoryID).DataTable().rows().data();
            const medicationTableRows = $("#MedicationsTable_" + icdcmCategoryID).DataTable().rows().data();
            const activityTableRows = $("#ActivitiesTable_" + icdcmCategoryID).DataTable().rows().data();

            let CategoryModel = {
                objCategory: {
                    CategoryID: $(`#Category_${icdcmCategoryID} option:selected`).val(),
                    DDGAvg: $("#DDGAvg_" + icdcmCategoryID).val(),
                    DDGMax: $("#DDGMax_" + icdcmCategoryID).val(),
                    DDGMin: $("#DDGMin_" + icdcmCategoryID).val(),
                    Description: $("#Description_" + icdcmCategoryID).val(),
                    DiagnosisID: $(`#Diagnosis_${icdcmCategoryID} option:selected`).val()
                },
                objPart: [],
                objMed: [],
                objActivities: [],
                objCause: {}
            };

            const BodyPartModel = { BodyPart: "", PartDescription: "", PartSide: "" };
            const MedicationModel = { MedName: "", MedReason: "" };
            const ActivityModel = { ActDescription: "", ActTime: "" };
            const CauseModel = {
                objCauseFields: {
                    CauseInjury: $(`#CauseInjury_${icdcmCategoryID}`).val(),
                    SimReason: $(`#SimReason_${icdcmCategoryID}`).val(),
                    GradReason: $(`#GradReason_${icdcmCategoryID}`).val(),
                    IsSafe: $(`#IsSafe_${icdcmCategoryID}`).select2('val'),
                    IsSafeReason: $(`#IsSafeReason_${icdcmCategoryID}`).val()
                },
                objEnvironmentFactors: $(`#environmentfactors-select_${icdcmCategoryID}`).select2('val').map(value => ({ CauseID: icdcmCategoryID, Value: value })),
                objEquipmentInvolved: $(`#equipmentinvolved-select_${icdcmCategoryID}`).select2('val').map(value => ({ CauseID: icdcmCategoryID, Value: value })),
                objHumanFactors: $(`#humanfactor-select_${icdcmCategoryID}`).select2('val').map(value => ({ CauseID: icdcmCategoryID, Value: value })),
                objInjuryLocations: $(`#injurylocation-select_${icdcmCategoryID}`).select2('val').map(value => ({ CauseID: icdcmCategoryID, Value: value })),
                objWeatherConditions: $(`#weatherconditions-select_${icdcmCategoryID}`).select2('val').map(value => ({ CauseID: icdcmCategoryID, Value: value }))
            };

            bodyParts = createObjectArrayByObjectModel(bodyPartTableRows, BodyPartModel);
            medications = createObjectArrayByObjectModel(medicationTableRows, MedicationModel);
            activities = createObjectArrayByObjectModel(activityTableRows, ActivityModel);

            CategoryModel.objCause = CauseModel;
            CategoryModel.objPart = bodyParts;
            CategoryModel.objMed = medications;
            CategoryModel.objActivities = activities;
            objCategories.push(CategoryModel);
        });
        let incidentFields = {
            IncidentDesc: $("#ICD10Description_" + primaryIncidentID).val(),
            Location: $("#ICD10Location_" + primaryIncidentID).val()
        };
        Incidents.push({
            objIncident: incidentFields,
            objWitness: witnesses,
            objLimit: limitations,
            objAct: actions,
            objDam: objDamages,
            objCat: objCategories
        });
    });
    //Finally formulating the string of objects
    return {
        objClaim: Claim,
        objSch: RegSch,
        objBill: BillComments,
        objDates: Dates,
        objDoc: DocDates,
        objAbs: AbsDates,
        objCon: Contacts,
        objEmp: Employee,
        objJob: Job,
        objPay: Pay,
        objPayroll: Payroll,
        objEarn: PayrollEar,
        objOffset: Offset,
        objDisability: preDis,
        objIns: Insurance,
        objInc: Incidents,
        objContactType: ContactType,
        objAbsence: $('#tblAbsences').DataTable().data().toArray(),
        objCPP: $('#tbl_AppCpp').DataTable().data().toArray(),
        objGRTW: $('#tblGRTW').DataTable().data().toArray(),
        objRehab: $('#tblRehab').DataTable().data().toArray(),
        objAdditionalDetails: AdditionalDetails
    };

}
