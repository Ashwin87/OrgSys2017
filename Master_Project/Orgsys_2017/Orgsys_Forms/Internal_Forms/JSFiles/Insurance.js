
if (ClaimID != null) {
    
      var earnings = GetEarnings();
    function GetEarnings() {
        var ear;
        $.ajax({
            url: getApi + "/api/Claim/GetPayrollEarnings/" + ClaimID,
            beforeSend: function (request) {
                request.setRequestHeader("Authentication", window.token);
            },
            async: false,
            success: function (data) {
                ear = JSON.parse(data);
            }
        });
        return ear;
    }

    var offsets = GetOffsets();
    function GetOffsets() {
        var offset;
        $.ajax({
            url: getApi + "/api/Claim/GetPayrollOffsets/" + ClaimID,
            beforeSend: function (request) {
                request.setRequestHeader("Authentication", window.token);
            },
            async: false,
            success: function (data) {
                offset = JSON.parse(data);
            }
        });
        return offset;
    }

    var predisability = GetPayrollDisability();
    function GetPayrollDisability() {
        var predis;
        $.ajax({
            url: getApi + "api/Claim/GetPayrollDisability/" + ClaimID,
            beforeSend: function (request) {
                request.setRequestHeader("Authentication", window.token);
            },
            async: false,
            success: function (data) {
                predis = JSON.parse(data);
            }
        });
        return predis;
    }

    console.log("INSURANCE.JS WORKING");
}
var template = `
<div class ="panel panel-default">
    <div class ="panel-heading">Payroll Information <span class ="pull-right clickable"><i class ="glyphicon glyphicon-chevron-up"></i></span></div>
    <div id="payRoll" class ="panel-body">
        <div class ="row margin_bottom">
            <div class ="col-md-4">
                <label for="dateLastPaid">Date Last Paid</label>
                <input type="date" class ="form-control col-md-3 " name="dateLastPaid" placeholder="Date Last Paid" id="DateLastPaid" />
            </div>
            <div class ="col-md-4">
                <label for="empClass">Employee Class</label>
                <select class ="form-control col-md-3" name="empClass" placeholder="Employee Class" id="EmpClass"></select>
            </div>
            <div class ="col-md-4">
                <label for="contractDate">Term Contract Date</label>
                <input type="date" class ="form-control col-md-3 " name="contractDate" placeholder="Term Contract Date" id="ContractDate" />
            </div>
        </div>
        <div class ="row margin_bottom">
            <div class ="col-md-4">
                <label for="payFreq">Payroll Frequency</label>
                <select class ="form-control col-md-3" name="payFreq" placeholder="Pay Frequency" id="PayFreq"></select>
            </div>
            <div class ="col-md-4">
                <label for="incomeContStatus">Income Continuity Status</label>
                 <select class ="form-control col-md-3" name="incomeContStatus" id="IncomeContStatus" placeholder="Income Continuity Date"></select>
                          </div>
            <div class ="col-md-4">
                <label for="incomeContDate">Income Continuity Date</label>
                 <input type="date" class ="form-control col-md-3" name="incomeContDate" placeholder="Income Continuity Date" id="IncomeContDate" />
            </div>
        </div>
        <div class ="row margin_bottom">
            <div class ="col-md-4">
                <label for="cppStatus">CPP status</label>
                <select class ="form-control col-md-3" name="cppStatus" placeholder="CPP status" id="CPPStatus"></select>
            </div>
            <div class ="col-md-4">
                <label for="ltdCode">LTD Benefit Code</label>
                <select class ="form-control col-md-3" name="ltdCode" placeholder="LTD Benefit Code" id="LTDCode"></select>
            </div>
         </div>

        <div class ="row margin_bottom">
        <div class ="col-md-4">

                <label for="emplJobCode">Job/NIC Code</label>
                <input type="text" class ="form-control col-md-3" name="jobCode" placeholder="Job Code" id="JobCode" />
            </div>

                    <div class ="col-md-4">
                <label for="ratePerHour">Rate of Pay</label>
                <input type="text" class ="form-control col-md-3" name="ratePerHour" placeholder="Rate Per Hour" id="RatePerHour" />
            </div>
            <div class ="col-md-4">
                <label for="payGroup" class ="form-control-placeholder">Pay Group(hrly)</label>
                <input type="text" class ="form-control col-md-3" name="payGroup" placeholder="Pay Group" id="PayGroup" />
            </div>
       </div>
       <div class ="row margin_bottom">

            <div class ="col-md-4">
                <label>Vacation Pay on Pay?</label>
                <select class ="form-control col-md-3" id="VacationPay" name="vacationPay" placeholder="Vacation Pay on Pay?" ></select>
            </div>
            <div class ="col-md-4">
                <label>Vacation Pay %</label>
                <input type="text" class ="form-control col-md-3" name="vacPayPercentage" placeholder="Vacation Pay %" id="VacPayPercentage" />
            </div>
            </div>
        <div role="tabpanel">
            <!--Nav tabs-->
            <ul class ="nav nav-tabs" role="tablist">
                <li role="presentation" class ="active">
                    <a href="#payrollTab" aria-controls="payrollTab" role="tab" data-toggle="tab">Payroll</a>

                </li>
                <li role="presentation">
                    <a href="#offsetTab" aria-controls="offsetTab" role="tab" data-toggle="tab">Payroll Offsets</a>

                </li>
                <li role="presentation">
                    <a href="#preDisTab" aria-controls="preDisTab" role="tab" data-toggle="tab">Prediasability</a>

                </li>
            </ul>
            
            </div>


            <div class ="tab-content">
                <div role="tabpanel" class ="tab-pane active" id="payrollTab">
                    <div class ="row margin_bottom">
                        <button type="button" id="btnPayroll" class ="btn btn-default" data-toggle="modal" data-target="#payRollDia">Create Payroll</button>
                    </div>
                    <table style="width:100%;" id="tblPayRoll">
                        <thead>
                            <tr>
                             <th style="width:20px">Earnings</th>
                                <th style="width:20px">Valid From</th>
                                  <th style="width:20px">Valid To</th>
                                <th style="width:20px">Gross Earnings</th>
                                <th style="width:20px">Gross Earnings Type</th>
                                <th style="width:40px">Federal Taxes</th>
                                <th style="width:20px">Provincial Taxes</th>
                                <th style="width:20px">CPP Contributions</th>
                                <th style="width:20px">EI Contributions</th>
                                <th style="width:20px">Work Hours</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div id="payRollDia" class ="modal fade">
                    <div class ="modal-dialog"  style="height:80%;width:80%">
                        <div class ="modal-content">
                            <div class ="modal-header">
                                <button type="button" class ="close" data-dismiss="modal" aria-hidden="true">&times; </button>
                                <h4 class ="modal-title">Pay Roll Information</h4>
                            </div>
                            <div class ="modal-body">

                                <div class ="row margin_bottom">
                                 <div class ="col-md-3">
                                        <label for="empLastName">Earnings Type</label>
                                        <select class ="form-control col-md-3 " name="earningsType" id="EarningsType"></select>
                                    </div>
                                <div class ="col-md-3">
                                        <label for="empLastName">Valid From</label>
                                        <input type="date" class ="form-control col-md-3 " name="validFrom" placeholder="Valid From" id="ValidFrom" />
                                    </div>
                                      <div class ="col-md-3">
                                        <label for="ValidTo">Valid To</label>
                                        <input type ="date" class ="form-control col-md-3 " name="validTo" placeholder="Valid To" id="ValidTo" ></select>
                                    </div>
                                     <div class ="col-md-3">
                                        <label for="grossEarnings">Gross Earnings</label>
                                        <input type ="text" class ="form-control col-md-3 " name="grossEarnings" placeholder="Gross Earnings" id="GrossEarnings" ></select>
                                    </div>

                                </div>
                                <div class ="row margin_bottom">
                                <div class ="col-md-4">
                                        <label for="empLastName">Gross Earnings Type</label>
                                        <select class ="form-control col-md-3 " name="grossEarnings_Type" placeholder="Regular Type" id="GrossEarningsType"></select>
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="empLastName">Federal Taxes</label>
                                        <input type="text" class ="form-control col-md-3 " name="federalTaxes" placeholder="Federal Taxes" id="FederalTaxes" />
                                    </div>
                                <div class ="col-md-4">
                                        <label for="empFirstName">Provincial Taxes</label>
                                        <input type="text" class ="form-control col-md-3" name="commisionGross" placeholder="Provincial Taxes" id="ProvincialTaxes" />
                                    </div>

                                </div>
                                  <div class ="row margin_bottom">
                                  <div class ="col-md-4">
                                        <label for="empNu">CPP Contributions</label>
                                        <input type="text" class ="form-control col-md-3" name="cppContributions" placeholder="CPP Contributions" id="CPPContributions" />
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="contributions_EI">EI Contributions</label>
                                        <input type="text" class ="form-control col-md-3" name="contributions_EI" id="Contributions_EI" placeholder="EI Contributions" />
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="friday">Work Hours</label>
                                        <input type="text" class ="form-control col-md-3" name="from" id="WorkHours" placeholder="Work Hours" />
                                    </div>
                                    </div>
                                <div class ="row margin_bottom">
                                    <div class ="col-md-4">
                                        <button type="button" id="AddPayroll" class ="btn btn-default" @click="AddPayroll()" data-toggle="modal" data-target="#payRollDia">Add Payroll</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>


                <div role="tabpanel" class ="tab-pane" id="offsetTab">

                    <div class ="row margin_bottom">
                        <button type="button" id="btnOffset" class ="btn btn-default" data-toggle="modal" data-target="#offSetDia">Create Payroll Offsets</button>
                    </div>
                    <table style="width:100%;" id="tblOffset">
                        <thead>
                            <tr>
                                <th style="width:20px">From Date</th>
                                <th style="width:20px">To Date</th>
                                <th style="width:20px">Period</th>
                                <th style="width:20px">PayType</th>
                                <th style="width:40px">Gross</th>
                                <th style="width:20px">Net</th>

                            </tr>
                        </thead>
                    </table>
                </div>

                <div id="offSetDia" class ="modal fade">
                    <div class ="modal-dialog"  style="height:80%;width:80%">
                        <div class ="modal-content">
                            <div class ="modal-header">
                                <button type="button" class ="close" data-dismiss="modal" aria-hidden="true">&times; </button>
                                <h4 class ="modal-title">Recorded Payroll Offset Information</h4>
                            </div>
                            <div class ="modal-body">
                                <div class ="row margin_bottom">
                                    <div class ="col-md-4">
                                        <label for="empLastName">From Date</label>
                                        <input type="date" class ="form-control" name="regularGross" placeholder="From Date" id="OffsetFrom" />
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="empLastName">To Date</label>
                                        <input type="date" class ="form-control" name="regularType" placeholder=" Offset To" id="OffsetTo" />
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="empLastName">Period</label>
                                        <select class ="form-control" name="offsetPeriod" placeholder="Period" id="Period" > </select>
                                    </div>
                            </div>
                                <div class ="row margin_bottom">
                                    <div class ="col-md-4">
                                        <label for="offsetType">Offset Type</label>
                                        <select class ="form-control" name="offsetType" placeholder="Offset Type" id="OffsetType"></select>
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="empNu">Gross</label>
                                        <input type="text" class ="form-control" name="commisionType" placeholder="Gross" id="GrossAmount" />
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="friday">Net</label>
                                        <input type="text" class ="form-control" name="from" id="NetAmount" placeholder="FromAmount" />
                                    </div>
                                </div>
                                <div class ="row margin_bottom">
                                    <div class ="col-md-4">
                                        <button type="button" id="AddOffset" class ="btn btn-default" @click="AddOffset()" data-toggle="modal" data-target="#offSetDia">Add Offset</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div role="tabpanel" class ="tab-pane" id="preDisTab">
                    <div class ="row margin_bottom">
                        <button type="button" id="btnPreDisabilty" class ="btn btn-default" data-toggle="modal" data-target="#preDisDia">Create PreDisability</button>
                    </div>
                    <table style="width:100%;" id="tblPreDisability">
                        <thead>
                            <tr>
                                <th style="width:20px">From Date</th>
                                <th style="width:20px">To Date</th>
                                <th style="width:20px">Amount</th>
                                <th style="width:20px">WorkHours</th>
                                <th style="width:20px">IncomeType</th>
                                <th style="width:40px">ClientConfirmed</th>
                            </tr>
                        </thead>
                    </table>
                </div>
                <div id="preDisDia" class ="modal fade">
                    <div class ="modal-dialog" style="height:80%;width:80%">
                        <div class ="modal-content">
                            <div class ="modal-header">
                                <button type="button" class ="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                                <h4 class ="modal-title">PreDisability/Advance Income Received</h4>
                            </div>
                            <div class ="modal-body">
                                <div class ="row margin_bottom">
                                    <div class ="col-md-3">
                                        <label for="empLastName">From Date</label>
                                        <input type="date" class ="form-control col-md-3" name="disDateFrom" placeholder="From Date" id="DisDateFrom" />
                                    </div>
                                    <div class ="col-md-3">
                                        <label for="empLastName">To Date</label>
                                        <input type="date" class ="form-control col-md-3" name="regularType" placeholder="To Date" id="DisDateTo" />
                                    </div>
                                    <div class ="col-md-3">
                                        <label for="empLastName">Amount</label>
                                        <input type="text" class ="form-control col-md-3" name="workHours" placeholder="Amount" id="Amount" />
                                    </div>
                                    <div class ="col-md-3">
                                        <label for="empFirstName">Work Hours</label>
                                        <input type="text" class ="form-control col-md-3" name="disWorkHours" placeholder="Work Hours" id="DisWorkHours" />
                                    </div>
                                </div>
                                <div class ="row margin_bottom">
                                    <div class ="col-md-4">
                                        <label for="empNu">Income Type</label>
                                        <input type="text" class ="form-control col-md-3" name="incomeType" placeholder="Income Type" id="IncomeType" />
                                    </div>
                                    <div class ="col-md-4">
                                        <label for="friday">Client Confirmed</label>
                                        <input type="text" class ="form-control col-md-3" name="clientConfirmed" id="ClientConfirmed" placeholder="Client Confirmed" />
                                    </div>
                                </div>
                                <div class ="row margin_bottom">
                                    <div class ="col-md-4">
                                        <button type="button" id="AddPreDisability" class ="btn btn-default" @click="AddPreDisability()" data-toggle="modal" data-target="#preDisDia">Add Predisability</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

`
var compInsurance = Vue.component('insurance', {
    props: ["Api"],
    mounted: function () {
        this.PopulateEarnings();
        this.PopulateOffset();
        this.PopulteDisability();
    },

    template: template,
    methods: {
        //Add Payroll
        AddPayroll() {

            var table = $('#tblPayRoll').DataTable();

            table.row.add({
                EarningsType: $('#EarningsType').val(),
                ValidFrom: $("#ValidFrom").val(),
                ValidTo: $("#ValidTo").val(),
                GrossEarnings: $('#GrossEarnings').val(),
                GrossEarningsType: $('#GrossEarningsType').val(),
                FederalTaxes: $('#FederalTaxes').val(),
                ProvincialTaxes: $('#ProvincialTaxes').val(),
                CPPContributions: $('#CPPContributions').val(),
                EIContributions: $("#Contributions_EI").val(),
                WorkHours: $('#WorkHours').val()

            }).draw();

        },
        //Add Offset
        AddOffset() {

            var table = $('#tblOffset').DataTable();

            table.row.add({
                OffsetFrom: $("#OffsetFrom").val(),
                OffsetTo: $('#OffsetTo').val(),
                Period: $('#Period').val(),
                OffsetType: $('#OffsetType').val(),
                GrossAmount: $('#GrossAmount').val(),
                NetAmount: $('#NetAmount').val(),

            }).draw();

        },
        //Add Predisability
        AddPreDisability() {

            var table = $('#tblPreDisability').DataTable();

            table.row.add({
                DateFrom: $("#DisDateFrom").val(),
                DateTo: $('#DisDateTo').val(),
                Amount: $('#Amount').val(),
                WorkHours: $('#DisWorkHours').val(),
                IncomeType: $('#IncomeType').val(),
                ClientConfirmed: $('#ClientConfirmed').val()

            }).draw();

        },
        //Populate Payroll
        PopulateEarnings() {
            $('#tblPayRoll').DataTable({
                select: true,
                data: earnings,
                "columns": [
                    { "data": "EarningsType" }, { "data": "ValidFrom" }, { "data": "ValidTo" }, { "data": "GrossEarnings" }, { "data": "GrossEarningsType" },
                    { "data": "FederalTaxes" }, { "data": "ProvincialTaxes" }, { "data": "CPPContributions" }, { "data": "EIContributions" }, { "data": "WorkHours" }
                ]
            });


        },
        //Populate Offset
        PopulateOffset() {
            $('#tblOffset').DataTable({
                select: true,
                data: offsets,
                "columns": [
                    { "data": "OffsetFrom" }, { "data": "OffsetTo" }, { "data": "Period" }, { "data": "OffsetType" },
                    { "data": "GrossAmount" }, { "data": "NetAmount" }
                ]
            });

        },
        //Populate Disabilty
        PopulteDisability () {
            $('#tblPreDisability').DataTable({
                select: true,
                data: predisability,
                "columns": [
                    { "data": "DateFrom" }, { "data": "DateTo" }, { "data": "Amount" }, { "data": "WorkHours" },
                    { "data": "IncomeType" }, { "data": "ClientConfirmed" }
                ]
            });

        }

    }
})



var insurance = new Vue({
    el: '#ins',
    components: {
        'comp-insurance': compInsurance
    }

});

