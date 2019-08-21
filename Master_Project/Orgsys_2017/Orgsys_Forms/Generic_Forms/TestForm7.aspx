<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestForm7.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.TestForm7" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title></title>

    <script>
        $(document).ready(function () {
            $.getJSON("http://localhost:49627/api/Form/GetFormControls/0/1", function (data) {
                var results = JSON.parse(data);
                for (i = 0; i < results.length; i++) {
                    //var customDiv = $("<div>");
                    $('#MainContent_print_All').append('<label style="width:175px">' + results[i]["ControlLabel"] + '</label><input style="width:250px" type="' + results[i]["ControlType"] + '" />');

                }
                //    $("#MainContent_print_All").append('<label style="width:175px">' + results[i]["ControlLabel"] + '</label>');
                //    $("#MainContent_print_All").append('<input type='+ results[i]["ControlType"]+' style=width:175px></input>');
                //};
            });
        });
    </script>
</asp:Content>
<asp:Content ID="content_Body" ContentPlaceHolderID="MainContent" runat="server">

    <form id="form1" runat="server">
        <div id="MainContent_print_All">
            <div id="1" />
        </div>
    </form>
</asp:Content>
