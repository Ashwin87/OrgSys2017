<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="ReturnToWork.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.WebForm1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<script>
    $(document).ready(function () {
        $('#btnSubmit').click(function (e) {
            valid = true;
            
            //ValidateControls();
            if (valid && validEmail && validDate) {
                SaveForm(); //Form is valid & the claim is saved in the database
            }
           
        });

        function SaveSOP() {
            var cols = new Array();            

            $('input').each(
                function (index) {
                    var input = $(this);
                    if (input.attr('type') != 'button') {

                        if (input.attr('type') == 'checkbox') {
                            if (input.is(':checked')) {
                                cols.push({ "ColName": input.attr('name'), "ColVal": "Yes" });
                            }
                            else {
                                cols.push({ "ColName": input.attr('name'), "ColVal": "No" });
                            }
                        }
                        else if (input.attr('type') == 'radio') {
                            if (input.is(":checked")) {
                                cols.push({ "ColName": input.attr('name'), "ColVal": input.val() });
                            }
                        }                        
                        else {
                            cols.push({ "ColName": input.attr('name'), "ColVal": input.val() });
                        }
                    }
                }
            );           

            $('textarea').each(
                function (index) {
                    var input = $(this);
                    cols.push({ "ColName": input.attr('name'), "ColVal": input.val() });
                }
            );

            var sop = { sopData: cols, contData: contcols }
            //console.log(JSON.stringify({ sop }));
            $.ajax({
                type: "POST",
                url: "<%= get_api %>/api/Client/SaveSOP",
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                data: '=' + JSON.stringify({ sopConData: sop }),
                dataType: "JSON",
                success: function () {
                    $(" <div class=\"row margin_bottom\" style= \"background: #98fb98;margin-top: 50px;margin-left: 15px;margin-right: 15px;\"><p style=\"margin-left:15px;margin-top:-10px\">Success</p></div>").appendTo("#bottom");
                },
                error: function (msg) {
                }
            });
         }
    });
</script>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .row {
            margin-left: 5px !important;
        }

        input[type=text] {
            background: transparent;
            border: none;
            border-bottom: 1px solid #000000;
        }

        .col-lg {
            background: white !important;
            color: black !important;
        }
        #page-wrapper {
            background: white !important;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
        }
    </style>

    <link href="/Assets/css/client.css" rel="stylesheet" />
    <div id="wrapper">
        <div id="page-wrapper">
            <div class="col-lg">
                <h3>XYZ Company - Transitional return to work Plan</h3>
            </div>
            <div class="row">
                <div class="col-md-4" style="padding-left:0px">
                    <label style="padding-left:0px; margin-left:0px"><b>EMPLOYEE: </b></label>
                    <input type="text" name="EmpName" />
                </div>
                <div class="col-md-4">
                    <label><b>INJURY DATE: </b></label>
                    <input type="text" name="InjuryDate"/>
                </div>
                <div class="col-md-4">
                    <label><b>SUPERVISOR: </b></label>
                    <input type="text" name="SuperName"/>
                </div>
            </div>
            <div class="row">
                <div class="col-md-4" style="padding-left:0px">
                    <label style="padding-left:0px; margin-left:0px"><b>First day of Transitional Duty:</b></label>
                    <input type="text" name="TransDutyFirstDay"/>
                </div>
                <div class="col-md-4">
                    <label><b>Date transitional Duty Ends:</b></label>
                    <input type="text" name="TransDutyEnd"/>
                </div>
                <div class="col-md-4">
                    <label><b>CLAIM NUMBER:</b></label>
                    <input type="text" name="ClaimNumber"/>
                </div>
            </div>
            <div class="row">
                <p>Welcome back to work following your illness / injury. We are in receipt of your healthcare provider's recommendations for your participation in our transitional RTW program. The objective of the program is to allow you to maintain your earnings potential while safely transitionaing back to full duties. It is your responsibility to work within your capabilities. &nbsp; <b><u>Please report to your supervisor immediately if you have any difficulty completing assinged job tasks.</u></b> </p>
            </div>
            
            <div class="row">
                <p>All appointments with your physician and/or physiotherapist should be scheduled outside of normal work hours. We look forward to assissting you in your recovery and to having you back to full duties. If you have any recurrance or symptoms, you must report immediately to your supervisor.</p>
            </div>
            
            <div class="row">
                <p>You should report back to work as of <input type="text" name="ReturnDate"/>at <input type="text" name="ReturnOther"/>. Based on your abilities, transitional work is available for the following tasks:</p>
                
            </div>
            <div class="row">
                <div class="row margin_bottom">
                    <p><input class="form-check-input" type="checkbox" name="FAFChk" id="FAFChk" /><b>&ensp;Capabilities/Restrictions as per FAF&emsp;<input class="form-check-input" type="checkbox" name="ModifiedChk" id="ModifiedChk" /><b>&ensp;Modified work as per PDA/Job Description</b></b></p>                              
                </div> 
            </div>

           
            <table style="width:100%;">
                <tr>
                    <th rowspan="2">Date</th>
                    <th rowspan="2">Transitional RTW Task</th>
                    <th colspan="7">Transitional RTW Hours</th>
                    <th rowspan="2">Comments/Restrictions</th>
                </tr>
                <tr>
                    <th style="width:30px">S</th>
                    <th style="width:30px">M</th>
                    <th style="width:30px">T</th>
                    <th style="width:30px">W</th>
                    <th style="width:30px">T</th>
                    <th style="width:30px">F</th>
                    <th style="width:30px">S</th>
                </tr>
                <tr>
                    <td style="width:100px"><b>Week One</b></td>
                    <td><textarea name="WeekOneRTW"></textarea></td>
                    <td><textarea name="WeekOneRTWSun"></textarea></td>
                    <td><textarea name="WeekOneRTWMon"></textarea></td>
                    <td><textarea name="WeekOneRTWTues"></textarea></td>
                    <td><textarea name="WeekOneRTWWed"></textarea></td>
                    <td><textarea name="WeekOneRTWThurs"></textarea></td>
                    <td><textarea name="WeekOneRTWFri"></textarea></td>
                    <td><textarea name="WeekOneRTWSat"></textarea></td>
                    <td><textarea name="WeekOneComments"></textarea></td>
                </tr>
                 <tr>
                    <td style="width:100px"><b>Week Two</b></td>
                    <td><textarea name="WeekTwoRTW"></textarea></td>
                    <td><textarea name="WeekTwoRTWSun"></textarea></td>
                    <td><textarea name="WeekTwoRTWMon"></textarea></td>
                    <td><textarea name="WeekTwoRTWTues"></textarea></td>
                    <td><textarea name="WeekTwoRTWWed"></textarea></td>
                    <td><textarea name="WeekTwoRTWThurs"></textarea></td>
                    <td><textarea name="WeekTwoRTWFri"></textarea></td>
                    <td><textarea name="WeekTwoRTWSat"></textarea></td>
                    <td><textarea name="WeekTwoComments"></textarea></td>
                </tr>
                 <tr>
                    <td style="width:100px"><b>Week Three</b></td>
                    <td><textarea name="WeekThreeRTW"></textarea></td>
                    <td><textarea name="WeekThreeRTWSun"></textarea></td>
                    <td><textarea name="WeekThreeRTWMon"></textarea></td>
                    <td><textarea name="WeekThreeRTWTues"></textarea></td>
                    <td><textarea name="WeekThreeRTWWed"></textarea></td>
                    <td><textarea name="WeekThreeRTWThurs"></textarea></td>
                    <td><textarea name="WeekThreeRTWFri"></textarea></td>
                    <td><textarea name="WeekThreeRTWSat"></textarea></td>
                    <td><textarea name="WeekThreeComments"></textarea></td>
                </tr>
                 <tr>
                    <td style="width:100px"><b>Week Four</b></td>
                    <td><textarea name="WeekFourRTW"></textarea></td>
                    <td><textarea name="WeekFourRTWSun"></textarea></td>
                    <td><textarea name="WeekFourRTWMon"></textarea></td>
                    <td><textarea name="WeekFourRTWTues"></textarea></td>
                    <td><textarea name="WeekFourRTWWed"></textarea></td>
                    <td><textarea name="WeekFourRTWThurs"></textarea></td>
                    <td><textarea name="WeekFourRTWFri"></textarea></td>
                    <td><textarea name="WeekFourRTWSat"></textarea></td>
                    <td><textarea name="WeekFourComments"></textarea></td>
                </tr>
                 <tr>
                    <td style="width:100px"><b>Week Five</b></td>
                    <td><textarea name="WeekFiveRTW"></textarea></td>
                    <td><textarea name="WeekFiveRTWSun"></textarea></td>
                    <td><textarea name="WeekFiveRTWMon"></textarea></td>
                    <td><textarea name="WeekFiveRTWTues"></textarea></td>
                    <td><textarea name="WeekFiveRTWWed"></textarea></td>
                    <td><textarea name="WeekFiveRTWThurs"></textarea></td>
                    <td><textarea name="WeekFiveRTWFri"></textarea></td>
                    <td><textarea name="WeekFiveRTWSat"></textarea></td>
                    <td><textarea name="WeekFiveComments"></textarea></td>
                </tr>
                 <tr>
                    <td style="width:100px"><b>Week Six</b></td>
                    <td><textarea name="WeekSixRTW"></textarea></td>
                    <td><textarea name="WeekSixRTWSun"></textarea></td>
                    <td><textarea name="WeekSixRTWMon"></textarea></td>
                    <td><textarea name="WeekSixRTWTues"></textarea></td>
                    <td><textarea name="WeekSixRTWWed"></textarea></td>
                    <td><textarea name="WeekSixRTWThurs"></textarea></td>
                    <td><textarea name="WeekSixRTWFri"></textarea></td>
                    <td><textarea name="WeekSixRTWSat"></textarea></td>
                    <td><textarea name="WeekSixComments"></textarea></td>
                </tr>
            </table>   
            

            <div class="panel-body" style="border: 1px solid black; margin-top: 100px;">                
                <div class="row">
                    <div class="radio">
                        <label class="checkbox-inline"><input class="radio" type="radio" id="WorkPlanAccept" name="WorkPlan" value="Accept" /> I accept the above transitional work plan and understand my role in the return to work process.</label>                           
                    </div>
                </div>
                <div class="row">
                    <div class="radio">
                        <label class="checkbox-inline"><input class="radio" type="radio" id="WorkPlanDecline" name="WorkPlan" value="Decline" /> I decline the above transitional work plan and understand my role in the return to work process.</label>                           
                    </div>
                </div>                
                <div class="row">                    
                    <p><b>Employee Signature: ____________________________&emsp;Date: <input type="text" name="EmpCurrDate"/></b></p>    
                </div>
                <div class="row">                     
                    <p><b>Supervisor Signature: ____________________________&emsp;Date: <input type="text" name="SupCurrDate"/></b></p>                    
                </div>
            </div>
            <div class="row">
                <div class="col-md-5"><p><b><i>Note: this form must be completed by the comployee and supervisor</i></b></p></div>
                <div class="col-md-5"><p><i>CC: Supervisor, Employee, HR, Organizational Solutions Inc.</i></p></div>
            </div>
       </div>
    </div>
</asp:Content>
