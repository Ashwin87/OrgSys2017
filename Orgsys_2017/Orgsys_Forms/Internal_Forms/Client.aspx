 <%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" CodeBehind="Client.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.Client" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
<script>
    var contactCounter = 1;   

    $(document).ready(function () {    
        phoneMask();

        $('#btnSubmit').click(function (e) {

            var valid = validate.validateSubmission();

            if (valid) {
                swal('Client Submitted', '', 'success');
            }
            else {                
                var errors = $('.error').length
                swal('There are currently ' + errors + ' errors in your form.', 'Please review the sections highlighted in red and submit again.', 'error');
            }

        });

        //Adds in a new contact add div
        $('#btnContact').click(function (e) {
            var newdiv = document.createElement('div');
            var divId = "contactAdd";    
            contactCounter++;
            newdiv.innerHTML = "<div id=\"contact" + contactCounter + "\"><div class=\"panel-heading\" id=\"Contact" + contactCounter + "><h3 class=\"panel-title\"><b>Contact " + contactCounter + "</b></h3></div>"
                + "<div class=\"panel-body\">"
                + "<div class=\"col-sm-offset-12\"><input type=\"button\"value=\"&#10799\"class=\"btn-danger btn-xs\" style=\"float:right; margin-top:-27px\"name=\"btnRemove" + contactCounter + "\" id=\"btnRemove\"/></div>"
                + "<div class=\"col-md-2\"><label for=\"ConFName\">First Name</label><input type=\"text\" class=\"form-control col-md-2 required\" name=\"FName\" id=\"contFName" + contactCounter + "\"/></div>"
                + "<div class=\"col-md-2\"><label for=\"ConLName\">Last Name</label> <input type=\"text\" class=\"form-control col-md-2 required\" name=\"LName\" id=\"contLName" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConTitle\">Title</label> <input type=\"text\" class=\"form-control col-md-2\" name=\"Title\" id=\"contTitle" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConAddress\">Address</label> <input type=\"text\" class=\"form-control col-md-2 required\" name=\"Address\" id=\"contAddress" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConCity\">City</label> <input type=\"text\" class=\"form-control col-md-2 required\" name=\"City\" id=\"contCity" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConProv\">Province/State</label> <input type=\"text\" class=\"form-control col-md-2 required\" name=\"Province\" id=\"contProv" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConPostal\">Postal/ZIP</label> <input type=\"text\" class=\"form-control col-md-2 required\" name=\"ZIP\" id=\"contPostal" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConPhone\">Phone</label> <input type=\"text\" class=\"form-control col-md-2 required vld-phone\" name=\"Phone\" id=\"contPhone" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConEmail\">Email</label> <input type=\"text\" class=\"form-control col-md-2 vld-email required\" name=\"Email\" id=\"contEmail" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConCell\">Cell</label> <input type=\"text\" class=\"form-control col-md-2 vld-phone\" name=\"Mobile\" id=\"contCell" + contactCounter + "\"/></div > "
                + "<div class=\"col-md-2\"><label for=\"ConFax\">Fax</label> <input type=\"text\" class=\"form-control col-md-2 vld-phone\" name=\"Fax\" id=\"contFax" + contactCounter + "\"/></div></div></div>";
            document.getElementById(divId).appendChild(newdiv);   
            phoneMask();
        });        

        $('#contactAdd').on('click', '#btnRemove', (function (e) {
            var currButton = $(this).attr('name').substr(9);
            if (confirm("Are you should you want to remove contact " + currButton + "?")) {
                var contactRemove = "#contact" + currButton;
                $(contactRemove).remove(); 
            }                      
        }));

        function SaveSOP() {
            var cols = new Array();
            var contcols = new Array();

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
                        else if (input.attr('id').substr(0, 4) == 'cont') {
                            contcols.push({ "ContColName": input.attr('name'), "ContColVal": input.val() });
                        }     
                        else {
                            cols.push({ "ColName": input.attr('name'), "ColVal": input.val() });
                        }
                    }
                }
            );

            cols.push({ "ColName": 'AdditionalComments', "ColVal": $("#AdditionalComments").val() })

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
                    DEBUG(msg, null, null);
                }
            });           
        }
    });

    function phoneMask() {
        $(".phone").mask("(999) 999-9999");
    }

    function numberMast() {
        $(".number").mask("")
    }
</script>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <link href="/Assets/css/client.css" rel="stylesheet" />
    <div id="alert_placeholder" style="position: fixed; top: 5px; left: 50%; z-index: 999;"></div>
    <div id="wrapper">
        <div id="page-wrapper">
            <div class="col-lg">
                <h2 class="biggerheading">SALES TO OPS FORM</h2>
            </div>
            <div class="row margin_bottom">
                <label for="CoName" id="CoLabel">Client company name:</label> 
                <div class="col-md-4">                        
                    <input type="text" class="form-control col-md-3 required" name="CoName" id="CoName"/>
                </div>
                <label for="GoLive" id="GoLabel">Go Live Date:</label>
                <div class="col-md-3">                    
                    <input type="date" class="form-control col-md-3 required date" name="GoLive" id="GoLive"/>
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading bluePanel">
                    <h3 class="panel-title"><b>Client Profile</b></h3>
                </div>

                <div class="panel-body">
                    <div class="row margin_bottom">
                    <label class="widthlabel" for="Tier">Client Tier</label>
                    <div class="col-md-3">                            
                        <input type="number" class="form-control required" name="Tier" id="Tier" />
                    </div>           
                        <div class="right_align">
                            <label for="NoEmp" id="EmpLabel">Number of Employees</label>
                            <div class="col-md-3">                                
                                <input type="number" class="form-control col-md-3 required vld-number" name="NoEmp" id="NoEmp" />
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="TypeIndustry">Type of Industry</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 required" name="TypeIndustry" id="TypeIndustry" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="CoWWW">Company Website</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="CoWWW" id="CoWWW" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="CoAddress">Head Office Address</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 required" name="CoAddress" id="CoAddress"/>
                        </div>
                        <label for="NoLoc">Number of Locations</label>
                        <div class="col-md-3">                        
                            <input type="number" class="form-control col-md-3 required vld-number" name="NoLoc" id="NoLoc" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="COPhone">Company Head Office Phone number</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 vld-phone required" name="CoPhone" id="CoPhone" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="COFax">Company Head Office Fax number</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 vld-phone" name="CoFax" id="CoFax" />
                        </div>
                    </div>  

                    <div class="row margin_bottom">                        
                        <label class="widthlabel">Operating Provinces</label>                        
                        <div class="col-md-9 FAChk">
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkBC" id="chkBC" />BC</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkAB" id="chkAB" />AB</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkSK" id="chkSK" />SK</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkMB" id="chkMB" />MB</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkON" id="chkON" />ON</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkQC" id="chkQC" />QC</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkNB" id="chkNB" />NB</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkNS" id="chkNS" />NS</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPE" id="chkPE" />PE</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkNF" id="chkNF" />NF</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkYK" id="chkYK" />YK</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkNW" id="chkNW" />NW</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkNU" id="chkNU" />NU</label>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                        <label class="widthlabel" for="isUnionized">Is the Company Unionized</label>
                        <div class="col-md-3">                           
                            <div class="radio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="UnionYes" name="isUnionized" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="UnionNo" name="isUnionized" value="No" /> No</label>
                            </div>
                        </div>
                        <label for="UnionName">Union Name(s)</label>
                        <div class="col-md-4">                            
                            <input type="text" class="form-control col-md-3" name="UnionName" id="UnionName" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="panel panel-default">
                <div class="panel-heading beigePanel">
                    <h3 class="panel-title"><b>Broker/Consultant/Partnership</b></h3>
                </div>
                <div class="panel-body">
                    <div class="row margin_bottom">                        
                        <label>Is the client through the OSI/Industrial Alliance Partnership?</label>                        
                        <div class="col-md-2">                            
                            <div class="radio" id="PartnerRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PartnershipYes" name="isPartnership" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PartnershipNo" name="isPartnership" value="No" /> No</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="BrokerName">Broker Company Name</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="BrokerName" id="BrokerName" />
                        </div>
                        <label for="BrokerContact">Broker Contact Name</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="BrokerContact" id="BrokerContact" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="BrokerPhone">Phone Number</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 vld-phone" name="BrokerPhone" id="BrokerPhone" />
                        </div>
                        <label for="BrokerEmail">Email</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 vld-email" name="BrokerEmail" id="BrokerEmail" />
                        </div>
                    </div>

                    <div class="row margin_bottom">
                            <label class="widthlabel">Is there a Broker Commission Agreement in place?</label>                        
                        <div class="col-md-2">
                          <div class="radio" id="BrokerRadio">
                            <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="BrokerYes" name="brokerCommission" value="Yes" /> Yes</label>
                            <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="BrokerNo" name="brokerCommission" value="No" /> No</label>
                          </div>
                        </div>
                    </div>
                </div>
            </div>

            
                <div class="panel panel-default" id="contactAdd">
                    <div class="panel-heading beigePanel">
                        <h3 class="panel-title"><b>Client Contact</b></h3>
                    </div>
                    <div class="panel-body">                   
                        <div class="col-md-2">
                            <label for="ConFName">First Name</label>
                             <input type="text" class="form-control col-md-2 required" name="FName" id="contFName"/>
                        </div>
                        <div class="col-md-2">
                            <label for="ConLName">Last Name</label>
                            <input type="text" class="form-control col-md-2 required" name="LName" id="contLName" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConTitle">Title</label>
                            <input type="text" class="form-control col-md-2" name="Title" id="contTitle" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConAddress">Address</label>
                            <input type="text" class="form-control col-md-2 required" name="Address" id="contAddress" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConCity">City</label>
                            <input type="text" class="form-control col-md-2 required" name="City" id="contCity" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConProv">Province/State</label>
                            <input type="text" class="form-control col-md-2 required" name="Province" id="contProv" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConPostal">Postal/ZIP</label>
                            <input type="text" class="form-control col-md-2 required" name="ZIP" id="contPostal" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConPhone">Phone</label>
                            <input type="text" class="form-control col-md-2 required vld-phone" name="Phone" id="contPhone" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConEmail">Email</label>
                            <input type="text" class="form-control col-md-2 required vld-email" name="Email" id="contEmail" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConCell">Cell</label>
                            <input type="text" class="form-control col-md-2 vld-phone" name="Mobile" id="contCell" />
                        </div>
                        <div class="col-md-2">
                            <label for="ConFax">Fax</label>
                            <input type="text" class="form-control col-md-2 vld-phone" name="Fax" id="contFax" />
                        </div>                       
                     </div> 
                 </div>
            
                <div class="panel-body"style="padding-top:0px">
                    <div class="col-md-2">
                        <input type="button" value="Add another contact" class="form-control col-md-3" style="background:darkgreen; color:white" name="btnContact" id="btnContact"/>                        
                    </div>                   
                </div>

            <div class="panel panel-default">
                <div class="panel-heading bluePanel">
                    <h3 class="panel-title"><b>Service Details</b></h3>
                </div>
                <div class="panel-body">
                    <div class="row margin_bottom">
                        <label class="widthlabel">Service Scope:</label>
                    </div>
                    <div class="row margin_bottom">                        
                        <div class="col-md-9 FAChk">
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkSTD" id="chSTD" />STD</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCCNESST" id="chkWCCNESST" />WC/CNESST</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkLTD" id="chkLTD" />LTD</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkAttendance" id="chkAttendance" />Attendance Management</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPDA" id="chkPDA" />PDAs</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkCDA" id="chkCDA" />CDAs</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPermAccomodation" id="chkPermAccomodation" />Permanent Accomodations</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkErgo" id="chkErgo" />Ergo</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkSTDCoord" id="chkSTDCoord" />STD Coordination with Insurer</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkProj" id="chkProj" />Project</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkSTDCons" id="chkSTDCons" />STD Consulting</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCCons" id="chkWCCons" />WC Consulting</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkImp" id="chkImp" />Implementation & Roll Out</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkITImp" id="chkITImp" />IT Implementation</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkOther" id="chkOther" />Other</label>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="OtherSrvcs">Other Services</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="OtherSrvcs" id="OtherSrvcs" />
                        </div>
                    </div>
                    <div class="row margin_bottom">                       
                        <label class="widthlabel">Are Bilingual Services Required?</label>                        
                        <div class="col-md-2">                           
                            <div class="radio" id="BilingualRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="BilingualYes" name="bilingualRequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="BilingualNo" name="bilingualRequired" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="BilingualTBD" name="bilingualRequired" value="Unknown" /> Do not Know</label>
                            </div>
                        </div>
                    </div>     
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Is a Roll Out Required?</label>                        
                        <div class="col-md-2">                            
                            <div class="radio" id="RolloutRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="RolloutYes" name="serviceRolloutRequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="RolloutNo" name="serviceRolloutRequired" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="RolloutTBD" name="serviceRolloutRequired" value="Unknown" /> Do not Know</label>
                            </div>
                        </div>
                    </div>
                </div>

            <div class="panel panel-default">
                <div class="panel-heading bluePanel">
                    <h3 class="panel-title"><b>Implementation/Roll Out Billing instructions</b></h3>
                </div>
                <div class="panel-body">
                    <div class="row margin_bottom">
                        <label for="ImpBillable">Implementation/Rollout Activities are Billable</label>
                        <input class="form-check-input FAChk" type="checkbox" name="ImplementationBillable" id="ImpBillable" />
                    </div>
                     <div class="row margin_bottom">
                        <label for="ImpNonBillable">Implementation/Rollout Activities are Non-Billing</label>
                        <input class="form-check-input FAChk" type="checkbox" name="ImplementationNonBillable" id="ImpNonBillable" />
                    </div>
                     <div class="row margin_bottom">
                        <input type="checkbox" class="FAChk" name="OperationalSetUpMax" id="OpSetupMaxTime" />  
                        <label for="OpSetupMaxTime">Implementation/Rollout Activities should not exceed ____ hours of billable time (for Operational set up)</label>  
                         <input type="text" name="OperationalSetUpTime" style="margin-left: 20px" id="OperationalSetUpTime" />
                    </div>                    
                     <div class="row margin_bottom">
                        <label for="ItsetupMaxTime">Implementation/Rollout Activities should not exceed ____ hours of billable time (for IT set up)</label>
                        <input class="form-check-input FAChk" type="checkbox" name="ITSetUpMax" id="ItSetupMaxTime" />   
                        <input type="text" name="ItSetUpTime" style="margin-left: 20px" id="ItSetUpTime" />
                    </div>                    
                    <div class="row margin_bottom FAChk">
                        <label>Aditional Implementation/Rollout comments</label>
                        <input type="text" class="form-control col-md-7" name="ImpComments" id="ImpComments" />
                    </div>
                </div>
            </div>

            <div class="panel panel-default">
                <div class="panel-heading beigePanel">
                    <h3 class="panel-title"><b>STD Services</b></h3>
                </div>
                <div class="panel-body">
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="SrvcType">Service Type</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="SrvcType" id="SrvcType" />
                        </div>
                        <label for="STDVol">Potential STD Claim Volume Per year</label>
                        <div class="col-md-2">                            
                            <input type="text" class="form-control col-md-3 vld-number" name="STDVol" id="STDVol" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="STDProvider">Current STD Provider</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="STDProvider" id="STDProvider" />
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="STDPeriod">STD Period</label>
                        <div class="col-md-2">                            
                            <input type="number" class="form-control col-md-3" name="STDPeriod" id="STDPeriod" />
                        </div>
                        <div class="col-md-2">                            
                            <div class="radio">
                                <label class="checkbox-inline""><input type="radio" class="FARadio" id="daysCheck" name="daysWeeks" value="Days" /> Days</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="weeksCheck" name="daysWeeks" value="weeks" /> Weeks</label>
                            </div>
                        </div>
                        <label for="LTDProvider">LTD Provider</label>
                        <div class="col-md-4">                            
                            <input type="text" class="form-control col-md-3" name="LTDProvider" id="LTDProvider" />
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Are Legacy Claims being Transferred?</label>
                        <div class="col-md-4">                           
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="LegacyYes" name="STDlegacyClaims" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="LegacyNo" name="STDlegacyClaims" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="LegacyTBD" name="STDlegacyClaims" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                            <label class="widthlabel">Are Payroll Reports Required?</label>
                        <div class="col-md-4">                            
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="PayrollYes" name="STDpayrollReports" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="PayrollNo" name="STDpayrollReports" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="PayrollTBD" name="STDpayrollReports" value="Uknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                            <label class="widthlabel">Is Rollout Required?</label>
                        <div class="col-md-4">                           
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="STDRolloutYes" name="STDRolloutRequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="STDRolloutNo" name="STDRolloutRequired" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="STDRolloutTBD" name="STDRolloutRequired" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                            <label class="widthlabel">Is OSI Paying Claims?</label>
                        <div class="col-md-4">
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="PayingYes" name="isOSIPaying" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="PayingNo" name="isOSIPaying" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="PayingTBD" name="isOSIPaying" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="STDPaymentType">STD Claims Payment Type</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="STDPaymentType" id="STDPaymentType" />
                        </div>
                        <label for="OtherPaymentType">Other Payment Type (If Applicable)</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3" name="OtherPaymentType" id="OtherPaymentType" />
                        </div>
                        
                    </div>
                </div>
            </div>

            <div class="panel panel-default">
                <div class="panel-heading beigePanel">
                    <h3 class="panel-title"><b>WC/CNESST Services</b></h3>
                </div>
                <div class="panel-body">
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="WCSrvcType">Service Type</label>
                        <div class="col-md-4">                            
                            <input type="text" class="form-control col-md-3" name="WCSrvcType" id="WCSrvcType"/>
                        </div>
                        <label for="WCVol">Claim Volume Est.</label>
                        <div class="col-md-2">                            
                            <input type="number" class="form-control col-md-3 vld-number" name="WCVol" id="WCVol" />
                        </div>
                    </div>
                     <div class="row margin_bottom">
                        <div class="col-md-4">
                            <label style="margin-left:5px">What provincial WC authorizations are required?</label>
                        </div>
                      </div>
                    <div class="row margin_bottom">
                        <div class="col-md-9">
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCBC" id="chkWCBC" />BC</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCAB" id="chkWCAB" />AB</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCSK" id="chkWCSK" />SK</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCMB" id="chkWCMB" />MB</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCON" id="chkWCON" />ON</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCQC" id="chkWCQC" />QC</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCNB" id="chkWCNB" />NB</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCNS" id="chkWCNS" />NS</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCPE" id="chkWCPE" />PE</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCNF" id="chkWCNF" />NF</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCYK" id="chkWCYK" />YK</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCNW" id="chkWCNW" />NW</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkWCNU" id="chkWCNU" />NU</label>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label for="RegNo">Employer Registration Number for Worksafe BC Access Required (9 Digit Number on Payroll Submission Form)</label>
                        <div class="col-md-5">                            
                            <input type="text" class="form-control col-md-2" name="RegNo" id="RegNo" />
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Are Legacy Claims being Transferred</label>
                        <div class="col-md-4">                            
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCLegacyYes" name="WClegacyClaims" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCLegacyNo" name="WClegacyClaims" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCLegacyTBD" name="WClegacyClaims" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                   <div class="row margin_bottom">                        
                            <label class="widthlabel">Legacy Review Requested</label>                      
                        <div class="col-md-4">                          
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCLegacyReviewYes" name="WClegacyreview" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCLegacyReviewNo" name="WClegacyreview" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCLegacyReviewTBD" name="WClegacyreview" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Are KPM's Required</label>                        
                        <div class="col-md-4">                           
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCKPMYes" name="WCKPMrequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCKPMNo" name="WCKPMrequired" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCKPMTBD" name="WCKPMrequired" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                       
                            <label class="widthlabel">RTW Policy</label>
                        <div class="col-md-4">
                            <div class="radio">
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCRTWPolicyYes" name="WCRTWPolicy" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCRTWPolicyNo" name="WCRTWPolicy" value="No" /> No</label>
                                <label class="checkbox-inline"><input type="radio" class="FARadio" id="WCRTWPolicyTBD" name="WCRTWPolicy" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="WCPayType">WC/CNESST Claims Payment Type</label>
                        <div class="col-md-3">
                            <input type="text" class="form-control col-md-3" name="WCPayType" id="WCPayType"/>
                        </div>
                        <label for="WCOtherPayType">Other Payment Type if Applicable</label>
                        <div class="col-md-3">
                            <input type="text" class="form-control col-md-3" name="WCOtherPayType" id="WCOtherPayType" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

            <div class="panel panel-default">
                <div class="panel-heading bluePanel">
                    <h3 class="panel-title"><b>IT Requirements</b></h3>
                </div>
                <div class="panel-body">
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Basic Portal Required</label>                        
                        <div class="col-md-4">                           
                            <div class="radio" id="PortalReqRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalRequiredYes" name="portalrequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalRequiredNo" name="portalrequired" value="No" /> No</label>
                            </div>
                        </div>                        
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel">Portal Submission Forms</label>                       
                        <div class="col-md-5">
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPortalSTD" id="chkPortalSTD" />STD</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPortalWC" id="chkPortalWC" />WC</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPortalAttendance" id="chkPortalAttendance" />Attendance</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPortalLTD" id="chkPortalLTD" />LTD</label>
                            <label class="checkbox-inline"><input class="form-check-input FAChk" type="checkbox" name="chkPortalOther" id="chkPortalOther" />Other</label>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Customized Portal Setup</label>                       
                        <div class="col-md-4">                         
                            <div class="radio" id="PortalSetupRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalSetupYes" name="PortalSetup" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalSetupNo" name="PortalSetup" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalSetupTBD" name="PortalSetup" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                   <div class="row margin_bottom">                        
                            <label class="widthlabel">Employee Portal Required</label>                        
                        <div class="col-md-4">                           
                            <div class="radio" id="EmpPortalRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="EmployeePortalYes" name="EmployeePortal" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="EmployeePortalNo" name="EmployeePortal" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="EmployeePortalTBD" name="EmployeePortal" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                       
                            <label class="widthlabel">Portal Reporting Module Required</label>                        
                        <div class="col-md-4">                            
                            <div class="radio" id="ReportingRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalreportingYes" name="PortalReporting" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalreportingNo" name="PortalReporting" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalreportingTBD" name="PortalReporting" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Portal Training Required</label>                        
                        <div class="col-md-4">                           
                            <div class="radio" id="TrainingRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="portalTrainingYes" name="PortalTraining" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="portalTrainingNo" name="PortalTraining" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="portalTrainingTBD" name="PortalTraining" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Designated Email Account Required</label>                        
                        <div class="col-md-4">                           
                            <div class="radio" id="EmailRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="EmailRequiredYes" name="EmailRequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="EmailRequiredNo" name="EmailRequired" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="EmailRequiredTBD" name="EmailRequired" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>                        
                    </div>
                    <div class="row margin_bottom">
                        <label class="widthlabel" for="DesignatedEmail">Email is:</label>
                        <div class="col-md-3">                            
                            <input type="text" class="form-control col-md-3 vld-email" name="DesignatedEmail" id="DesignatedEmail"/>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Custom Programming Required</label>                        
                        <div class="col-md-4">                          
                            <div class="radio" id="ProgRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="CustomProgrammingYes" name="CustomProgramming" value="Yes" />Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="CustomProgrammingNo" name="CustomProgramming" value="No" />No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="CustomProgrammingTBD" name="CustomProgramming" value="Unknown" />Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                        
                            <label class="widthlabel">Demographic File Upload Required</label>                        
                        <div class="col-md-4">                          
                            <div class="radio" id="PortalDemoRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalDemogYes" name="PortalDemog" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalDemogNo" name="PortalDemog" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PortalDemogTBD" name="PortalDemog" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">                       
                            <label class="widthlabel">Toll Free Phone Line Required</label>                        
                        <div class="col-md-4">                          
                            <div class="radio" id="PhoneRadio">
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PhoneRequiredYes" name="PhoneRequired" value="Yes" /> Yes</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PhoneRequiredNo" name="PhoneRequired" value="No" /> No</label>
                                <label class="checkbox-inline"><input class="radio required FARadio" type="radio" id="PhoneRequiredTBD" name="PhoneRequired" value="Unknown" /> Do Not Know</label>
                            </div>
                        </div>
                    </div>
                    <div class="row margin_bottom">
                        <label for="ITComments">Additional Comments for I.T.</label>
                        <div class="col-md-12">                            
                            <input type="text" class="form-control col-md-3" name="ITComments" id="ITComments"/>
                        </div>
                    </div>                    
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading beigePanel">
                    <h3><b>Additional Comments On The Account</b></h3>
                    <h4><b>Please also include the following, if available:</b></h4>
                    <h5><i><b>Type of approach they are wanting:</b> tough adjucation? Facilitation of care? etc.</i></h5>
                    <h5><i><b>outcome expectation:</b> is focus on minimizing durations & cost? Process efficiencies? Treating everyone the same? Etc.</i></h5>
                    <h5><b>Describe the organizational culture.</b></h5>
                    <h5><b>Describe the main contact person.</b></h5>
                </div>
                <div class="panel-body">
                    <textarea class="form-control col-md-11" rows="6" name="AdditionalComments" id="AdditionalComments"> </textarea>
                </div>
            </div>
            <div class="row margin_bottom" id="bottom">
                <div class="col-md-2">
                    <input type="button" value="Submit" class="form-control col-md-3" style="background:darkgreen; color:white;" name="btnSubmit" id="btnSubmit"/>
                </div>
            </div>
        </div>
    </div>

    <script src="/Assets/js/common/Validation.js"></script>
    <script src="/Assets/js/jquery.mask.js"></script>
    <script src="JSFiles/Alerts.js"></script>
</asp:Content>

