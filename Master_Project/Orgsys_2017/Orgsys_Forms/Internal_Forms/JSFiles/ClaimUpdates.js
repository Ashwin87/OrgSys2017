$(document).ready(function () {
    $('[data-toggle="tooltip"]').tooltip();
});
var validUpdates = true;

function GetUpdatesFewFields() {
    var upd;
    $.ajax({
        url: getApi + "/api/DataBind/GetUpdatesFewFields/" + window.ClaimRefNu,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            upd = JSON.parse(data);
        }
    });
    return upd;
}

function CheckIfFirstAbsence() {
    //var count
    $.ajax({
        url: getApi + "/api/DataBind/CheckIfFirstAbsence/" + window.ClaimID,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (data) {
            upd = JSON.parse(data);
        }
    });
    return upd[0]["Absence"];
}



function SaveUpdates() {
    $.ajax({
        url: getApi + "/api/ClaimUpdates/SaveUpdates",
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        type: "POST",
        async: false,
        data: '=' + JSON.stringify({ updatesData: claimUpdate }),
        success: function (responseCode) {
            console.log(responseCode);
            if (responseCode == 10) {
                $('#Updates').html("");
                PopulateClaimUpdates(ClaimRefNu);
                bootstrap_alert.success('The claim has been saved successfully');
            }
        },

        error: function (msg) {
            bootstrap_alert.danger('Oops! Something went wrong.');
            console.log(msg);
        }
    });
    //class ="glyphicon glyphicon-remove-circle"
    //<span class ="pull-right clickable"><i class ="glyphicon glyphicon-chevron-up"></i></span>
}
var template = `<transition name="modal">
    <div class="modal-mask">
        <div class="modal-wrapper">
            <div class="modal-container" style="overflow-y:scroll;height:90%;width:90%">
                <div class ="panel panel-default">
                    <div class ="panel-heading">Claim Updates<span class ="pull-right removeable">
                    <b class="close" @click="$emit('close')">Close</b>
                    </span>

                    </div>
                    <div id="claimUpdates" class="panel-body">
                        <div class="row margin_bottom">
                            <div class="col-md-5">
                                <label>Action Type</label>
                                <select data-toggle="tooltip" title="Select an action you would like to perform on this claim. Remember to save this change at the bottom of this window." class ="form-control" name="actionType" id="ActionType" @change="CreateSubSections('AddMedical')"></select>
                            </div>
                            <div class="col-md-5">
                                <label>Date</label>
                                <input data-toggle="tooltip" title="Date this action took place" type="date" class ="form-control col-md-3 test" name="updatesDate" id="UpdatesDate" />
                            </div>
                        </div>
                        <div class="row margin_bottom">
                            <div class="form-group col-md-12">
                                <label>Comments</label>
                                <textarea class="form-control" name="Comments" id="Comments" rows="4"></textarea>
                            </div>
                        </div>

                        <div  class ='panel panel-custom-baby-default'>
                            <div class ="panel-heading">Document Upload<span class ="pull-right removeable"></span><span class ="pull-right clickable"><i class ="glyphicon glyphicon-chevron-up"></i></span></div>
                            <div class="panel-body">
                                <label data-toggle="tooltip" title=".doc, .docx, .pdf, .xlsl, .text, .jpeg">Select File to Upload - Hover Here for list of proper file extensions</label>
                                <input data-toggle="tooltip" title="Ensure your file fits the proper criteria." id="fileUpload" type="file"/></br>
                                <input data-toggle="tooltip" title="Save your document to this form" id="btnUploadFile" type="button" value="Upload File" @click="SaveClaimDocuments()" />
                            </div>
                        </div>


                        <div  class ='panel panel-custom-baby-default'>
                            <div class ="panel-heading">Additional Billable Items<span class ="pull-right clickable"><i class ="glyphicon glyphicon-chevron-up"></i></span></div>
                            <div class="panel-body">
                                <div class="row margin_bottom">
                                    <label class="checkbox-inline">
                                        <input class="form-check-input" type="checkbox" name="completed" id="Completed">Completed
                                    </label>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-sm-5">
                                        <label>Completion Date</label>
                                        <input type="date" class="form-control" name="completionDate" id="CompletionDate" />
                                    </div>
                                    <div class="col-md-5">
                                        <label>Reason</label>
                                        <input type="text" class="form-control" name="Reason" id="Reason" />
                                    </div>
                                </div>
                                <div class="row margin_bottom">
                                    <label class="checkbox-inline">
                                        <input class="form-check-input" type="checkbox" name="directContact" id="DirectContact">Direct Contact
                                    </label>
                                    <label class="checkbox-inline">
                                        <input class="form-check-input" type="checkbox" name="Postage" id="Postage">Postage
                                    </label>
                                    <label class="checkbox-inline">
                                        <input class="form-check-input" type="checkbox" name="Courier" id="Courier">Courier
                                    </label>
                                </div>
                                <div class="row margin_bottom">
                                    <div class="col-md-5">
                                        <label>Method</label>
                                        <input type="date" class="form-control" name="Method" id="Method" />
                                    </div>
                                    <div class="col-md-5">
                                        <label>Duration</label>
                                        <input type="text" class="form-control" name="Duration" id="Duration" />
                                    </div>
                                </div>
                            </div>
                        </div>

                          <div v-show="ShowAbsences" class ='panel panel-custom-baby-default'>
                        <div class ="panel-heading">Absences<span class ="pull-right clickable"><i class ="glyphicon glyphicon-chevron-up"></i></span></div>
                        <div class ="panel-body">
                            <div class ="row margin_bottom" v-show="ShowFirst">
                                <label class ="checkbox-inline">
                                    <input class ="form-check-input" type="checkbox" name="completed" id="Completed">Wait period waived
                                </label>
                            </div>
                            <div class ="row margin_bottom">
                                <div class ="col-sm-3">
                                    <label id="lblDayOff">First Off</label>
                                    <input type="date" class ="form-control" name="dayOff" id="DayOff" />
                                </div>
                                <div class ="col-md-3">
                                    <label>Last Day Worked</label>
                                    <input type="date" class ="form-control" name="lastWorked" id="LastWorked" />
                                </div>
                                <div class ="col-md-3" v-show="ShowFirst">
                                    <label>LTD Start Date</label>
                                    <input type="date" class ="form-control" name="LTDStartDate" id="LTDStartDate" />
                                </div>
                            </div>

                            <div class ="row margin_bottom">
                                <div class ="col-md-3">
                                    <label>Absence Decision</label>
                                    <input type="text" class ="form-control" name="absenceApproved" id="AbsenceApproved" />
                                </div>
                                <div class ="col-md-3">
                                    <label>Approve Date</label>
                                    <input type="date" class ="form-control" name="approvalDate" id="ApprovalDate" />
                                </div>
                            </div>
                            <div class ="row margin_bottom">
                                <div class ="col-md-3">
                                    <label>Abs Auth From</label>
                                    <input type="date" class ="form-control" name="absAuthFrom" id="AbsAuthFrom" />
                                </div>
                                <div class ="col-md-3">
                                    <label>Abs Auth To</label>
                                    <input type="date" class ="form-control" name="absAuthTo" id="AbsAuthTo" />
                                </div>
                                <div class ="col-md-3">
                                    <label>RTW Auth</label>
                                    <input type="date" class ="form-control" name="RTWAuthDate" id="RTWAuthDate" />
                                </div>
                            </div>
                            <div class ="row margin_bottom">
                                <div class ="col-md-3">
                                    <label>RTM</label>
                                    <input type="date" class ="form-control" name="RTMDate" id="RTMDate1" />
                                </div>
                                <div class ="col-md-3">
                                    <label>RTF</label>
                                    <input type="date" class ="form-control" name="RTFDate" id="RTFDate" />
                                </div>
                            </div>
                            <div class ="row margin_bottom">
                                <label class ="checkbox-inline">
                                    <input class ="form-check-input" type="checkbox" name="transRTW" id="TransRTW">RTM includes tradional /gradual RTW
                                </label>
                                <label class ="checkbox-inline">
                                    <input class ="form-check-input" type="checkbox" name="transRTWDis" id="TransRTWDis">Tradional RTW disconnected or absence recurred
                                </label>

                            </div>
                        </div>
                    </div>
                        <div v-show="ShowRTW" class ='panel panel-custom-baby-default'>
                            <div class="panel-heading">Transitional Return to Work Plan<span class="pull-right clickable"><i class="glyphicon glyphicon-chevron-up"></i></span></div>
                            <div class="panel-body">
                                 <div class ="col-lg">
            </div>
            <div class ="row margin_bottom">
                <div class ="col-md-4">
                    <label><b>Employee: </b></label>
                    <input type="text" name="EmpName" id="EmpName"  />
                </div>
                <div class ="col-md-4">
                    <label><b>Date of Injury: </b></label>
                    <input type="date" name="InjuryDate"/>
                </div>
                <div class ="col-md-4">
                    <label><b>Supervisor: </b></label>
                    <input type="text" name="SuperName"/>
                </div>
            </div>
            <div class ="row row margin_bottom">
                <div class ="col-md-4">
                    <label style="padding-left:0px; margin-left:0px"><b>First day of Transitional Duty: </b></label>
                    <input type="date" name="TransDutyFirstDay" id="TransDuty_FirstDay"/>
                </div>
                <div class ="col-md-4">
                    <label><b>Date transitional Duty Ends: </b></label>
                    <input type="date" name="TransDutyEnd" id="TransDuty_LastDay"/>
                </div>
                <div class ="col-md-4">
                    <label><b>Claim Reference Number: </b></label></br>
                    <input type="text" name="ClaimNumber"/>
                </div>
            </div>
            <div class ="row row margin_bottom">
                <p>Welcome back to work following your illness / injury.We are in receipt of your healthcare provider's recommendations for your participation in our transitional RTW program. The objective of the program is to allow you to maintain your earnings potential while safely transitionaing back to full duties. It is your responsibility to work within your capabilities.</p>
                <b><u>Please report to your supervisor immediately if you have any difficulty completing assigned job tasks.</u></b>
            </div>

            <div class ="row row margin_bottom">
                <p>All appointments with your physician and/or physiotherapist should be scheduled outside of normal work hours.We look forward to assissting you in your recovery and to having you back to full duties.If you have any recurrance or symptoms, you must report immediately to your supervisor.</p>
            </div>

            <div class ="row row margin_bottom">
                <p>You should report back to work as of <input type="date" name="ReturnDate" id="TransDuty_ReturnDate"/>at <input type="text" name="ReturnOther"/>.Based on your abilities, transitional work is available for the following tasks: </p>

            </div>
            <div class ="row row margin_bottom">
                <div class ="row margin_bottom">
                    <p><input class ="form-check-input" type="checkbox" name="FAFChk" id="FAF_Capabilities" /><b>&ensp; Capabilities/Restrictions as per FAF&emsp; <input class ="form-check-input" type="checkbox" name="ModifiedChk" id="PDA_ModifiedWork" /><b>&ensp; Modified work as per PDA/Job Description</b></b></p>
                </div>
            </div>

                                    <button type="button" id="AddWeek" class ="btn btn-default" @click="CreateWeek()">Add Week</button>
                                </div>
                                <center>
                                   <table style="width:100%;margin-left:auto; margin-right:auto;">
                                   <thead>
                <tr>
                    <th rowspan="2">Date</th>
                    <th rowspan="2">Transitional RTW Task</th>
                    <th colspan="7">Transitional RTW Hours</th>
                    <th rowspan="2">Comments/Restrictions</th>
                </tr>
                <tr>
                    <th style="width:20px">S</th>
                    <th style="width:20px">M</th>
                    <th style="width:20px">T</th>
                    <th style="width:20px">W</th>
                    <th style="width:20px">T</th>
                    <th style="width:20px">F</th>
                    <th style="width:20px">S</th>
                            </tr>
                            </thead>

                            <tr class="RTW">

                    <td style="width:50px"><input type="date" name="RTW_Week_Date" id="RTW_Week_Date0"/></td>
                    <td><input name="RTW_Task" id="RTW_Task0"/></td>
                    <td><input class ="col-md-2" id="RTW_Hrs_Sun0" name="RTW_Hrs_Sun"/></td>
                    <td><input class ="col-sm-2" id="RTW_Hrs_Mon0" name="RTW_Hrs_Mon"/></td>
                    <td><input class ="col-sm-2" id="RTW_Hrs_Tue0" name="RTWTues"/></td>
                    <td><input class ="col-sm-2" id="RTW_Hrs_Wed0" name="RTW_Hrs_Wed"/></td>
                    <td><input class ="col-sm-2" id="RTW_Hrs_Thu0" name="RTW_Hrs_Thu"/></td>
                    <td><input class ="col-sm-2" id="RTW_Hrs_Fri0" name="RTW_Hrs_Fri"/></td>
                    <td><input class ="col-sm-2" id="RTW_Hrs_Sat0" name="RTW_Hrs_Sat"/></td>
                    <td><input class ="col-md-4"  id="RW_Comments0" name="RW_Comments"/></td>
                </tr>
                            <tr v-for="counter in WeekCounter" class ="RTW" track-by="$counter">

                     <td style="width:50px"><input type="date" name="RTW_Week_Date" :id="'RTW_Week_Date' + counter + ''" /></td>
                    <td><input name="RTW_Task" :id="'RTW_Task' + counter + ''" /></td>
                    <td><input class ="col-sm-2"  :id="'RTW_Hrs_Sun' + counter + ''" name="RTW_Hrs_Sun"/></td>
                    <td><input class ="col-sm-2"  :id="'RTW_Hrs_Mon' + counter + ''"  name="RTW_Hrs_Mon"/></td>
                    <td><input class ="col-sm-2" :id="'RTW_Hrs_Tue' + counter + ''"  name="RTWTues"/></td>
                    <td><input class ="col-sm-2" :id="'RTW_Hrs_Wed' + counter + ''"  name="RTW_Hrs_Wed"/></td>
                    <td><input class ="col-sm-2" :id="'RTW_Hrs_Thu' + counter + ''"  name="RTW_Hrs_Thu"/></td>
                    <td><input class ="col-sm-2" :id="'RTW_Hrs_Fri' + counter + ''"  name="RTW_Hrs_Fri"/></td>
                    <td><input class ="col-sm-2" :id="'RTW_Hrs_Sat' + counter + ''"  name="RTW_Hrs_Sat"/></td>
                    <td><input class ="col-md-4"  :id="'RW_Comments' + counter + ''"  name="RW_Comments"/></td>
                </tr>
            </table>
                </center>                </div>

                            </div>
                        </div>


                        <div class="modal-footer">
                            <slot name="footer">

                                <div class="row margin_bottom">

                                    <a href="#" class="btn btn-info" role="button" @click="SaveClaimUpdates">Save Updates</a>
                                </div>
                            </slot>
                        </div>


                    </div>
                </div>
            </div>
        </div>
    </div>
</transition>`;

////<a href="#" class ="btn btn-info" role="button" @click="$emit('close')">Close</a>
//Vue.component('modal', {
//    props: ['ShowAbsences', 'ShowFirst', 'ShowUpload', 'ShowRTW', 'ShowWeek', 'WeekCounter'],

//    computed: {
//        // a computed getter
//        ShowUpdates: function () {
//            // `this` points to the vm instance
//            return this.ShowUpdates = false
//        }
//    },
//    template: template,
//    methods: {

//        CreateSubSections(SectionName) {
//            //This does nothing - Marie
//            //if (SectionName == 'Billable') {
//            //    this.ShowBillable = !this.ShowBillable
//            //}
//            if (SectionName == 'AddMedical') {
//                //I removed this part because basically, all of these action types could have a document - Marie
//                //if ($('#ActionType').val() == "Additional Medical") {
//                //    console.log("Tesng.....");
//                //    this.ShowUpload = !this.ShowUpload;

//                //}
//                //else 
//                if ($('#ActionType').val() == "TRTW Plan (Out)") {
//                    var updates = GetUpdatesFewFields();
//                    $("#EmpName").val(updates[0]["EmpName"]);
//                    this.ShowRTW = true;

//                }
//                if ($('#ActionType').val() == "Absences") {
//                    var absences = CheckIfFirstAbsence();
//                    $('#LastWorked').val($('#DateLastWorked').val());
//                    $('#DayOff').val($('#DateFirstOff').val());
//                    var date = new Date($('#DateFirstOff').val());
//                    //  var newdate = new Date(date);

//                    date.setDate(date.getDate() + 129);
//                    ;
//                    $('#LTDStartDate').val($('#DateLastWorked').val());

//                    if (absences == 0) {
//                        this.ShowFirst = true;
//                        this.ShowAbsences = true;

//                    }
//                    else {
//                        $('#lblDayOff').html("Relapce Date");
//                        this.ShowAbsences = true;

//                    }


//                }
//            }

//        },
//        CreateWeek() // Should change Names later
//        {
//            this.ShowWeek = !this.ShowWeek;
//            this.WeekCounter += 1;

//        },

//        SaveClaimDocuments() {
//            var files = new Array();
//            for (var i = 0; i < $("#fileUpload").prop("files").length; i++) {
//                var file = {};
//                file.Name = $("#fileUpload").prop("files")[i].name;
//                file.Path = $("#fileUpload").val().split(', ')[i];
//                files.push(file);
//            }
//            var formDocument = new FormData();
//            var files = $("#fileUpload").get(0).files;
//            if (files.length > 0) {
//                for (var i = 0; i < files.length; i++) {
//                    console.log(files[i].Path);
//                    formDocument.append("document" + i, files[i]);
//                    swal({
//                        title: "File Uploaded",
//                        text: "Please ensure all items are saved - Click on Save Updates when finished with all Claim Updates",
//                        type: "success",
//                        showCancelButton: false,
//                        confirmButtonText: 'Return to Claim Updates',
//                        closeOnConfirm: true,
//                    });
//                }
//                //  formDocument.append("document", file);

//            }

//            // Make Ajax request with the contentType = false, and procesDate = false
//            var ajaxRequest = $.ajax({
//                type: "POST",
//                url: getApi + "/api/ClaimUpdates/SaveDocuments",
//                data: formDocument,
//                dataType: 'json',
//                contentType: false,
//                processData: false,
//            });
//            console.log("Data");
//            console.log(formDocument);
//            //ajaxRequest.done(function (xhr, textStatus) {
//            //    // Do other operation
//            //});
//        },
//        SaveClaimUpdates() {
//            //this.$set(loginSubmit, 'Logging In...');
//            CreateClaimUpdates();
//            validUpdates = true;
//            $('.requiredUpdates').each(function (key, value) {
//                ValidateRequiredNew($(this).val(), this);
//            });
//            console.log(validUpdates);
//            if (validUpdates == true) {
//                SaveUpdates();

//            }

//        }

//    }
//});

//new Vue({
//    el: '#app',
//    //props:  ['showBillable1'],

//    data: {

//        ShowUpdates: false,

//    },
//    methods: {
//        LoadUpdatesModal() {
//            this.ShowUpdates = true;
//            $('#ActionType')[0].selectedIndex = 0;


//        }

//    }


//})
//mounted: function () {
//    var self = this;
//    $.ajax({
//        url: '/items',
//        method: 'GET',
//        success: function (data) {
//            self.items = data;
//        },
//        error: function (error) {
//            console.log(error);
//        }

//    });

//    var ItemsVue = new Vue({
//        el: '#Itemlist',
//        data: {
//            items: []
//        },
//        mounted: function () {
//            var self = this;
//            $.ajax({
//                url: '/items',
//                method: 'GET',
//                success: function (data) {
//                    self.items = data;
//                },
//                error: function (error) {
//                    console.log(error);
//                }
//            });
//        } 
