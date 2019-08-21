<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="Print.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.Print" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Style Sheet References-->
    <link href="/Assets/css/PrintTemplate.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Roboto:300" />
    <script src="JSFilesExternal/PopulateExternal.js"></script>
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="../Internal_Forms/JSFiles/DataBind.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.0.550/pdf.js"></script>
    <script>
        /*  Created By      : Sam Khan
            Create Date     : 2017 -05-17
            //Update Date     : 2017-05-17 [Added comments and did code clean up]
            Description     : It loads the claim data
            Updated by      : Marie Gougeon
            Update Desc     : added token in the script to obtain client ID - please revise
        */

        $(document).ready(function () {
            //NEED TO CHANGE CLIENTID TO GRAB FROM TOKEN - PLEASE REVISE
            window.ClaimID = $.url().param('ClaimID');
            window.ClientID = $.url().param('ClientID');
            window.Token = '<%=token%>';
            window.getApi = "<%= get_api%>";

            $.ajax({
                url: "<%= get_api %>/api/Claim/GetClaimData/" + Token + "/" + ClaimID,
                beforeSend: function (request) {
                    request.setRequestHeader("Authentication", window.token);
                },
                async: false,
                success: function (data) {
                    var claimData = JSON.parse(data);

                    //get claim type, make the corresponding column in db not null to eliminate this check?
                    var claimType = (claimData[0]["Description"] == null) ? 'WC' : claimData[0]["Description"];

                    $('.panel-body').load('HTMLSections/Print' + claimType + '.html', function () {

                        $.each(claimData[0], function (key, value) {
                            if (value == true) {
                                $('#' + key).attr('checked', 'checked');
                            }
                            else if (value == null) {
                                value = " ";
                            } else {
                                $('#' + key).text(value);
                            }
                        });

                        PopulateSchedulePrint();
                        PopulateClaimContactsPrint();
                        PopulateOtherEarningsPrint();
                        PopulateICDCMCatPartPrint();
                        PopulateClaimDatesPrint();
                        PopulateWitnessesPrint();

                    });
                }
            });


            $(document).on('click', '#btn-pdf', function () {

                var doc = $('div.panel-body:first');
                var fhtml = doc.get(0).outerHTML;
                
                $.ajax({
                    cache: false,
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: "Print.aspx/GeneratePDF",
                    dataType: "json",
                    data: JSON.stringify({
                        json: {
                            html: fhtml,
                            cssFilename: "PrintTemplate_V2.css"
                        }
                    }),
                    success: function (pdfdata) {                        
                        var file = new Blob([pdfdata], { type: 'application/pdf' });
                        var fileURL = URL.createObjectURL(file);
                        window.open(fileURL);
                    }
                });

            });

        });
    </script>
</asp:Content>
<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">
    <form runat="server" method="post" id="formGeneric">

        <div class="panel panel-default flex-col">
            <div class="panel-heading">
                <h5>Worker Compensation Form Print</h5>
            </div>

            <div runat="server" id="print_All" style="width: auto; position: relative; float: left"></div>
            <!--<input type="button" value="PDF" id="btn-pdf"/>-->
            <div class="panel-body"></div>
        </div>
    </form>
</asp:Content>
