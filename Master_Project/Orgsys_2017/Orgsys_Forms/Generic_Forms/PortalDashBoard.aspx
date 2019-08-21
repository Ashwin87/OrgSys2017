<%@ Page Title="" Language="C#" MasterPageFile="~/Orgsys_Forms/Master/Portal.Master" AutoEventWireup="true" CodeBehind="PortalDashBoard.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Generic_Forms.PortalDashBoard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="/Assets/js/promise-polyfill.js"></script>
    <script src="/Assets/js/orgsysNavbar.js"></script>

    <script>
        var token = '<%= token %>';

        $(function () {

            $("#WC").click(function () {
                window.location.href = "Form7.aspx?ClientID=" + 0 + "&FormID=" + 1;
            });
            $("#STD").click(function () {
                window.location.href = "Form7.aspx?ClientID=" + 0 + "&FormID=" + 2;
            });

            var date = new Date();
            UpdateNotificationPanel();
            UpdateOpenClaimsPanel();
            UpdateDraftClaimsPanel();

            //updates every 30 seconds
            setInterval(UpdateNotificationPanel, 30000);
            setInterval(UpdateOpenClaimsPanel, 30000);
            setInterval(UpdateDraftClaimsPanel, 30000);

            var services = ['', 'WC', 'STD', 'LOA']

            /*
            Created By     : Kamil Salagan
            Created Date   : 2017-02-23
            Update Date    : 2017-09-28 - Marie
            Description    : populates "Notification Panel" with latest data in intervals

            Modified By    : Andriy Bovtenko
            Description    : changed url and some selectors for use on the portal dashboard
            */
            function UpdateNotificationPanel() {
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url: "<%= get_api %>/api/Notifications/GetNotifications_External/" + token,
                    success: function (data) {
                        $("#notifications_panel li.styleList").remove(); //Remove old notifications
                        var results = JSON.parse(data);

                        if (results.length >= 1) {
                            for (i = 0; i < results.length; i++) {

                                var ndate = new Date(results[i]["NDateTime"]);
                                var min = Math.floor(((date - ndate) / 1000) / 60); //minutes

                                var time_msg = '';
                                if (min < 6) {
                                    time_msg = 'Just now'
                                }
                                else if (min < 181) {
                                    time_msg = '1 hour ago'
                                }
                                else {
                                    var hrs = Math.floor(((date - ndate) / 1000) / 3600);

                                    if (hrs > 24) {
                                        time_msg = Math.floor(hrs / 24) + ' days';
                                    }
                                    else if (hrs >= 24 && hrs < 48) {
                                        time_msg = Math.floor(hrs / 24) + ' day';
                                    }
                                    else {
                                        time_msg = hrs + ' hours';
                                    }
                                }
                                var link = $('<li class="styleList" id="' + results[i]["NID"] + '"><a href="" class="list-group-item" data-toggle="modal" data-target="#modal' + results[i]["NID"] + '"><span class="badge">' + time_msg + ' </span><i class="icon icon-user"></i>' + results[i]["NMSGShort"] + '</a></li>');
                                $('#notifications_panel ul').append(link);
                            }
                        } else if (results.length < 1) {
                            $('#notificationsEmpty').remove();
                            $('#notifications_panel').append('<span id="notificationsEmpty" class="notificationsEmpty">Nothing to see here!</span>');
                        }
                    }
                });






            }

            /*
             Created By     : Marie Gougeon
             Created Date   : 2018-03-10
             Description    : Updating open claims panel - view button logic and info display

             Modified By    : Andriy Bovtenko
             Description    : changed url and some selectors for use on the portal dashboard
             */
            function UpdateOpenClaimsPanel() {
                $.ajax({
                    url: "<%= get_api %>/api/Claim/GetClaimsExternalDashboard/" + token + '/' + true,
                    beforeSend: function (request) {
                        request.setRequestHeader("Authentication", window.token);
                    },
                    success: function (data) {
                        $("#openClaimsPanel li.styleList").remove(); //Remove old notifications
                        var results = JSON.parse(data);

                        if (results.length >= 1) {
                            var i = 0;
                            while (i < results.length && i < 10) {

                                var date = ConvertDateIsoToCustom(results[i]["DateCreation"]);
                                var formId = services.indexOf(results[i].Description)
                                var li = $('<li class="styleList"></li>');
                                var a = $('<a href="Form7.aspx?ClaimID=' + results[i].ClaimID + '&FormID=' + formId + '&ViewClaim=true" class= "list-group-item" >' + results[i]["EmpLastName"] + ', ' + results[i]["EmpFirstName"] + " - Reference Number: " + results[i]["ClaimRefNu"] + '</a>');

                                li.append(a.append('<span class="badge">' + date + ' </span> <i class="icon icon-user"></i>'));
                                $('#openClaimsPanel ul').append(li);

                                i++;
                            }
                        } else if (results.length < 1) {
                            $('#notificationsEmpty').remove();
                            $('#openClaimsPanel').append('<span id="notificationsEmpty" class="notificationsEmpty">Nothing to see here!</span>');
                        }

                    }
                });
            }

            function UpdateDraftClaimsPanel() {
                $.ajax({
                    url: "<%= get_api %>/api/Claim/GetClaimsExternalDashboard/" + token + '/' + false,
                    beforeSend: function (request) {
                        request.setRequestHeader("Authentication", window.token);
                    },
                    async: false,
                    success: function (data) {
                        var drafts = JSON.parse(data);

                        if (drafts.length > 0) {
                            $("#DraftClaimsPanel li.styleList").remove();
                            $.each(drafts, function (key, draft) {
                                var date = ConvertDateIsoToCustom(draft.DateCreation)
                                var formId = services.indexOf(draft.Description)
                                var linkText = draft.EmpLastName.concat(', ', draft.EmpFirstName, ' - Reference Number: ', draft.ClaimRefNu)

                                var a = $('<a href="Form7.aspx?ClaimID=' + draft.ClaimID + '&FormID=' + formId + '" class="list-group-item">' + linkText + '</a>')
                                var li = $('<li class="styleList"></li>').append(a.append('<span class="badge">' + date + ' </span> <i class="icon icon-user"></i>'))

                                $('#DraftClaimsPanel ul').append(li)
                            });
                        }
                        else {
                            $('#notificationsEmpty').remove();
                            $('#DraftClaimsPanel').append('<span id="notificationsEmpty" class="notificationsEmpty">Nothing to see here!</span>');

                        }
                    }
                });
            }

            /*
             Created By     : Kamil Salagan
             Created Date   : 2018-01-26
             Description    : Generates SWAL for each notification in notifications panel

             Modified By    : Andriy Bovtenko
             Description    : changed url and some selectors for use on the portal dashboard
             */
            $('#notifications_panel').on('click', 'a.list-group-item', function () {

                var notificationID = $(this).closest('li').attr('id');

                $.ajax({
                    url: "<%= get_api %>/api/Notifications/GetNotificationExternal/" + token + "/" + notificationID,
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    success: function (data) {
                        var notifications = JSON.parse(data);

                        if (notifications.length > 0) {
                            swal({
                                title: "Notification - " + notifications[0]["NMSGShort"],
                                text: notifications[0]["NMSGLong"],
                                type: "info",
                                showCancelButton: false,
                                confirmButtonClass: "btn-success",
                                confirmButtonText: "OK"
                            }).then(function (result) {
                                $.ajax({
                                    url: "<%= get_api %>/api/Notifications/UpdateNotificationViewed/" + token + "/" + notificationID,
                                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                                        success: function () {
                                            UpdateNotificationPanel();
                                        }
                                    });
                                });
                        }
                    }
                });
            });

        });

    </script>

    <script src="/Assets/js/common/DateInput.js"></script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="spacer"></div>
    <div id="banner-container" class="osp-heading panel-heading narrow-container">
        <div id="welcome-container" class="osp-heading panel-heading">
            <div id="welcome-header" class="osp-heading panel-heading">My Dashboard</div>
        </div>
        <div id="logo-container" class="osp-heading panel-heading"></div>
    </div>
    <div class="spacer"></div>

    <div id="portal-container" class="container-fluid narrow-container">

        <div id="portal-content" class="panel-body osp-body">

            <div class="row">
                <div class="col-sm-12 col-md-6 col-lg-6">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><i class="icon icon-clock  "></i>Notification Panel</h3>
                        </div>
                        <div class="panel-body">
                            <div class="list-group" id="notifications_panel">
                                <ul class="styleList">
                                </ul>
                            </div>

                            <!--
                                <div class="text-right">
                                    <a href="#">View All Activity <i class="icon icon-circle-right"></i></a>
                                </div>
                                -->
                        </div>
                    </div>
                </div>

                <div class="col-xs-12 col-sm-12 col-md-6 col-lg-6">
                    <div class="panel panel-default">

                        <ul class="nav nav-tabs">
                            <li class="active"><a data-toggle="tab" href="#OpenClaimsList">New Claims</a></li>
                            <li><a data-toggle="tab" href="#DraftClaimsList">Draft Claims</a></li>
                        </ul>

                        <div class="panel-body">

                            <div class="tab-content">

                                <div id="OpenClaimsList" class="tab-pane fade in active">
                                    <div class="list-group" id="openClaimsPanel">
                                        <ul class="styleList"></ul>
                                    </div>
                                    <div class="text-right">
                                        <a href="/OrgSys_Forms/Generic_Forms/PortalClaimManager.aspx">View All Claims <i class="icon icon-circle-right"></i></a>
                                    </div>
                                </div>

                                <div id="DraftClaimsList" class="tab-pane fade in">
                                    <div class="list-group" id="DraftClaimsPanel">
                                        <ul class="styleList"></ul>
                                    </div>
                                    <div class="text-right">
                                        <a href="/OrgSys_Forms/Generic_Forms/PortalClaimManager.aspx">View All Claims <i class="icon icon-circle-right"></i></a>
                                    </div>
                                </div>

                            </div>

                            <!--
                            <div class="list-group" id="openClaimsPanel">
                                <!-- holds all claim items ->
                                <ul class="styleList">
                                </ul>
                            </div>
                            <div class="text-right">
                                <a href="/OrgSys_Forms/Generic_Forms/PortalClaimManager.aspx">View All Claims <i class="icon icon-circle-right"></i></a>
                            </div>
                            -->

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
