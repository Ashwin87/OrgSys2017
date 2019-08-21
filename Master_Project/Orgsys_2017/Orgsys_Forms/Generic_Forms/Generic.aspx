<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="Generic.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.Generic" %>

<asp:Content ID="content_Head" runat="server" ContentPlaceHolderID="head">

    <%-- The height should be auto,not the fixed one[Need to work on that]--%>
    <style>
        .container, .panel {
            height: 1400px;
        }
    </style>

    <script>

        $(function () {
            $("[id$='1']").show();
            $(".btn-primary").click(function () {
                $(this).parent().hide().next().show();//hide parent and show next
                //window.scrollTo(0, 0); //Replaced by Kamil for code below
                $("html, body").animate({ scrollTop: 0 }, "slow");
            });
            $(".btn-default").click(function () {
                $(this).parent().hide().prev().show();//hide parent and show previous
                window.scrollTo(0, 0);
            });

            $('a.sectionTabs').click(function (e) {
                $(".divClass").hide();
                //window.scrollTo(0, 0);
                $("html, body").animate({ scrollTop: 0 }, "slow");
                $($(e.target).attr('href')).show();//Show sections accordingly
            });

            $("#formGeneric").validate({
                errorPlacement: function () {
                    return false;
                },

                invalidHandler: function (e, validator) {
                    $("#errors").text(validator.numberOfInvalids() + " field(s) are invalid");
                    $('#messageModal').modal('show');
                }
                //[If in future errors need to be appended]
                //defaultShowErrors: function () {
                //    for (var i = 0; this.errorList[i]; i++) {
                //        var error = this.errorList[i];
                //        this.settings.highlight && this.settings.highlight.call(this, error.element, this.settings.errorClass, this.settings.validClass);
                //        this.showLabel(error.element, error.message);
                //    }
                //}
            });

            $('#formGeneric').submit(function () {
                var tabId;
                $(".divClass").each(function () {
                    tabId = $(this).attr('id').replace('Section', 'Tab');
                    if ($(this).children().hasClass('error')) {
                        //if($('#MainContent_1').hasClass('test'))
                        $("#" + tabId).addClass('glyphicon glyphicon-remove');
                    }
                    else
                        console.log("Not Found");
                })

            });

            $('.loadDiv').children().each(function () {
                var lastTop = $(this).last().position().top;
               
                var top = $(this).last().position().top + lastTop + 30;
                $(this).css({ 'top': top + 'px' });


            })
            
        });

    </script>

</asp:Content>

<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">
    <form runat="server" method="post" id="formGeneric" action="">

        <div class="panel panel-default flex-col">
            <div class="panel-heading">
                <h5>Worker Compensation Form</h5>
            </div>

            <div class="tabs">
                <ul id="list_tabs" runat="server" class="nav nav-tabs"></ul>
            </div>
            <div class="panel-body flex-grow" runat="server" id="section_All" style="width: auto; position: relative">
                <%--<div id="err" class="modal-body" style="background-color: lightgrey; width: 300px; height: 100px;"></div>--%>
            </div>
        </div>
    </form>

    <div class="modal fade" id="messageModal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h5 class="modal-title">Errors</h5>
                </div>

                <div class="modal-body">
                    <!-- The messages container -->
                    <div id="errors"></div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
