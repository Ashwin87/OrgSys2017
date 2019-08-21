<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Internal.Master" AutoEventWireup="true" CodeBehind="OrgsysReceipt.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Internal_Forms.OrgsysReceipt" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        input[type="text"] {
            border-top: none !important;
            border-right: none !important;
            border-left: none !important;
            border-bottom: 1px dotted #2196f3 !important;
            box-shadow: none !important;
            -webkit-box-shadow: none !important;
            -moz-box-shadow: none !important;
            -moz-transition: none !important;
            -webkit-transition: none !important;
        }

        .heading {
            color: #2196f3;
        }

        .control {
            padding-top: 7px;
        }

        .reciept {
            border-top: 5px solid #2196f3;
            -webkit-box-shadow: 0px 5px 21px -2px rgba(0,0,0,0.47);
            -moz-box-shadow: 0px 5px 21px -2px rgba(0,0,0,0.47);
            box-shadow: 0px 5px 21px -2px rgba(0,0,0,0.47);
            margin-top: 20px !important;
            margin-bottom: 10px;
            width: 80%;
            margin: 0 auto;
        }
    </style>
    <script>
        /*  Created By      : Marie Gougeon
            Create Date     : 2018-03-23
            Description     : Populates a page for an orgsys claim save 
                                - Once changes are submitted it will visit this page
                                - This is for internal use only, with the option to print reciept
            Updated Date    : 2018-03-28
            Updated Date    : 2018-04-10 - added DFO
        */
        var token = '<%=token%>';

        $(document).ready(function () {

            $('[data-toggle="tooltip"]').tooltip();

            var ClaimID = $.url().param('ClaimID');
            $("#navigateToClaim").attr("href", '/OrgSys_Forms/Internal_Forms/WC.aspx?ClaimID=' + ClaimID);

            $.ajax({
                url: "<%= get_api %>/api/Claim/GetClaimDataInternal/" + ClaimID,
                beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                async: false,
                success: function (data) {
                    var results = JSON.parse(data);
                    var claimRN = results[0]["ClaimRefNu"]
                    UpdateClaimData(claimRN);
                    $.each(results[0], function (key, value) {
                        if (value == true) {
                            $('#' + key).prop('checked', true);
                        }
                        else
                            if (value == null)
                                value = "";
                        $('#' + key).text(value);
                    })


                },
                error: function (req, status, err) {
                    console.log('something went wrong', status, err);
                }

            });

            function UpdateClaimData(claimRN) {
                $.ajax({
                    url: "<%= get_api %>/api/Claim/CheckClaimIfExists/" + claimRN,
                    beforeSend: function(request) {
                        request.setRequestHeader("Authentication", window.token);
                        },
                    async: false,
                    success: function (data) {
                        console.log("Update Claim Success!");
                    },
                    error: function (request, status, error) {
                        console.log(request.responseText);
                    }
                });
            };

        });

    </script>
    <!------ Include the above in your HEAD tag ---------->
    <div class="reciept">
        <form runat="server" method="post" id="receiptForm">
            <div class="panel panel-default flex-col">
                <div class="panel-heading">
                    <h3>Receipt for Submission</h3>
                </div>
                <div class="panel-body" style="margin-left: .5cm">
                    <div class="row margin_bottom">
                        <div class="">
                            <label class="lblHead" data-toggle="tooltip" title="This will be used to follow your claim through its cycle">Claim Reference Number:</label>
                            <label class="lblVal" id="ClaimRefNu" />
                        </div>
                        <div class="">
                            <label class="lblHead">Client:</label>
                            <label class="lblVal" id="ClientName" />
                        </div>
                        <div class="">
                            <label class="lblHead">Employee First Name:</label>
                            <label class="lblVal" id="EmpFirstName" />
                        </div>
                        <div class="">
                            <label class="lblHead">Employee Last Name:</label>
                            <label class="lblVal" id="EmpLastName" />
                        </div>
                        <div class="">
                            <label class="lblHead">Date First Off:</label>
                            <label class="lblVal" id="DateFirstOff" />
                        </div>
                        <div class="">
                            <label class="lblHead">Date Last Edited:</label>
                            <label class="lblVal" id="DateCreation" />
                        </div>
                        <div class="">
                            <label class="lblHead">Claim Type:</label>
                            <label class="lblVal" id="Type" />
                        </div>

                        <div class="">
                            <label class="lblHead" data-toggle="tooltip" title="If applicable, this will be added to the claim">WSIB Number:</label>
                            <label class="lblVal" id="WSIBClaimNu" />
                        </div>
                    </div>
                    <hr />
                    <div class="row margin_bottom">
                        <div class="">
                            <label class="lblHead">Employee Contact Work Phone:</label>
                            <label class="lblVal" id="BusTelephone" />
                        </div>
                        <div class="">
                            <label class="lblHead">Employee Contact Home Phone:</label>
                            <label class="lblVal" id="HomePhone" />
                        </div>
                        <div class="">
                            <label class="lblHead">Employee Contact Email:</label>
                            <label class="lblVal" id="Email" />
                        </div>
                        <div class="">
                            <label class="lblHead" data-toggle="tooltip" title="If applicable, scheduled dates absence from work">Absence Dates:</label>
                        </div>
                    </div>
                    <hr />
                    <div class="row margin_bottom">
                        <label class="lblHead">Please do not distribute. This reciept is for internal purposes only.</label>
                        <label class="lblHead">Your changes have been saved. If this is a new claim, please note that your are not assigned to this claim until you view it in the Dashboard.</label>
                        <label class="lblHead">If this was an existing claim and has been edited, please follow your next assigned task to this claim.</label>
                    </div>
                    <div class="row margin_bottom">
                        <a id="navigateToClaim" class="btn btn-default" data-toggle="tooltip" title="Return to the claim to edit">Edit</a> <a class="btn btn-default" href="/OrgSys_Forms/Internal_Forms/InternalDashBoard.aspx" data-toggle="tooltip" title="Return to the dashboard">Done</a>
                    </div>

                </div>
            </div>
        </form>
    </div>
</asp:Content>
