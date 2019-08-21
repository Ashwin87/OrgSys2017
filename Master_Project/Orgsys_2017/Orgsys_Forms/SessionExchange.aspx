<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SessionExchange.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.SessionExchange" %>

<!DOCTYPE html>
<!-- 
*   Author: Kamil Salagan
*   Created        : 03-01-2018
*   Update Date    : 
*   Description: Landing page for handling a redirected user from the old portal
-->
<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title></title>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <!-- jQuery References-->
        <script src="/Assets/js/jquery-3.1.1.js"></script>
        <script src="/Assets/js/jquery.validate.min.js"></script>
        <!-- Bootstrap References-->
        <script src="../Assets/bs/bootstrap.js"></script>
        <script src="../Assets/bs/bootstrap.min.js"></script>
        <script src="/Assets/bs/bootstrap-notify.min.js"></script>
        <!-- FONTAWESOME STYLES-->
        <link href="../Assets/css/font-awesome.css" rel="stylesheet" />
        <!-- Style Sheet References-->
        <link href="../Assets/css/bootstrap.css" rel="stylesheet" />
        <link href="../Assets/css/login-custom.css" rel="stylesheet" />
        <!-- GOOGLE FONTS-->
        <link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css' />
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" />
        <link href='https://fonts.googleapis.com/css?family=Varela+Round' rel='stylesheet' type='text/css' />
        <%--JAVASCRIPT DISABLED DETECTION--%>
        <noscript> 
          <style>
              html {
                  display: none;
              }
          </style>
          <meta http-equiv="refresh" content="0; url=nojavascript.aspx" />
        </noscript>
        <script src="../Scripts/Cookie.js"></script>
        <script>
            function GetURLParameter(sParam) {
                var sPageURL = window.location.search.substring(1);
                var sURLVariables = sPageURL.split('&');
                for (var i = 0; i < sURLVariables.length; i++) {
                    var sParameterName = sURLVariables[i].split('=');
                    if (sParameterName[0] == sParam) {
                        return sParameterName[1];
                    }
                }
            }
            <%--VALIDATING LOGIN - validation, Warning and User Attempts--%>
            var count = 0;
            $(document).ready(function () {
                var username = GetURLParameter("user");
                var hashid = GetURLParameter("hashid");
                //$(document).on('submit', 'form', function (e) {
                //    e.preventDefault();
                //Check if username and password are valid
                $.ajax({
                    url: "<%= get_api%>/api/Login/OldLoginCredentials/" + username +"/" + hashid,
                    type: "POST",
                    cache: false,
                    async: false,
                    //data: "=" + encodeURIComponent(JSON.stringify({ Username: user, Password: pass})),
                    success: function (result) {
                        if (result == null) {
                        }
                        else {
                            $.ajax({
                                cache: false,
                                type: "POST",
                                contentType: "application/json; charset=utf-8",
                                url: "Orgsys_Login.aspx/setTokenSession",
                                dataType: "json",
                                data: JSON.stringify({ token: result }),
                                success: OnSuccessRedirect(result, "https://umbrella02.orgsoln.com/OrgSys_Forms/Generic_Forms/PortalHome.aspx"),
                                async: false
                            });
                        }
                    }
                });

            function OnSuccessRedirect(token, url) {
                $.getJSON("<%= get_api %>/api/Login/GetPageType/" + token, function (result) {
                    var results = JSON.parse(result);
                    var ut = results[0]["UserType"];
                    var href = results[0]["URL"];
                    if (ut == 4) {
                        //Login Unsucessful - Username or Password is blocked (Lockout)
                        //grecaptcha.reset();
                        $('#LockOutWarning').css('display', 'block');
                        count++;
                    } else if (ut == 0) {
                        //Login Unsucessful - Username or Password is incorrect, missing credentials or error occured
                        //grecaptcha.reset();
                        $('#UserWarning').css('display', 'block');
                        count++;
                        if (count >= 5) { //Login Unsucessful - Login Attempts have exceeded 5 unsucessful attempts
                            loginAttempts();
                        };
                    };
                    window.location.href = url;
                });
            };

            function OnSuccess(token) {
                $.getJSON("<%= get_api %>/api/Login/GetPageType/" + token, function (result) {
                    var results = JSON.parse(result);
                    var ut = results[0]["UserType"];
                    var href = results[0]["URL"];
                    if (ut == 4) {
                        //Login Unsucessful - Username or Password is blocked (Lockout)
                        //grecaptcha.reset();
                        $('#LockOutWarning').css('display', 'block');
                        count++;
                    } else if (ut == 0) {
                        //Login Unsucessful - Username or Password is incorrect, missing credentials or error occured
                        //grecaptcha.reset();
                        $('#UserWarning').css('display', 'block');
                        count++;
                        if (count >= 5) { //Login Unsucessful - Login Attempts have exceeded 5 unsucessful attempts
                            loginAttempts();
                        };
                    };
                    window.location.href = href;
                });
            };
           // });


            <%--Browser Type Detection--%>
            // Opera 8.0+
            var isOpera = (!!window.opr && !!opr.addons) || !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;
            // Firefox 1.0+
            var isFirefox = typeof InstallTrigger !== 'undefined';
            // At least Safari 3+
            var isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0;
            // Internet Explorer 6-11
            var isIE = /*@cc_on!@*/false || !!document.documentMode;
            // Edge 20+
            var isEdge = !isIE && !!window.StyleMedia;
            // Chrome 1+
            var isChrome = !!window.chrome && !!window.chrome.webstore;
            // Blink engine detection
            var isBlink = (isChrome || isOpera) && !!window.CSS;

            var output = 'Detecting Browser:' + '\n';
            output += '-Firefox: ' + isFirefox + '\n';
            output += '-Chrome: ' + isChrome + '\n';
            output += '-Safari: ' + isSafari + '\n';
            output += '-Opera: ' + isOpera + '\n';
            output += '-IE6-11: ' + isIE + '\n';
            output += '-Edge: ' + isEdge + '\n';
            output += '-Blink: ' + isBlink + '\n';
            console.log(output);
        });
</script>

</head>
<body>
    <div class="container container-table">
        <div class="row vertical-center-row">
            <div class="account-wall col-md-4 col-md-offset-4">
                <img class="profile-img" src="/Assets/img/logo_vector_2017.png" alt="" />
                
            </div>
        </div>
    </div>
    <div id="footer">
        <div class="footer-style">
            <p>All Rights Reserved, Organizational Solutions Inc. © 2017</p>
        </div>
    </div>
</body>
</html>
