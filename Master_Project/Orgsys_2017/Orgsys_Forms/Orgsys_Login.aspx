<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Orgsys_Login.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Orgsys_Login" %>

<!DOCTYPE html>
<!-- 
*   Author: Marie Gougeon
*   Created        : 01-12-2017
*   Update Date    : 2018-03-21 - Marie
*   Description: login controller for all api calls at login
-->
<html xmlns="https://www.w3.org/1999/xhtml">
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
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@8"></script>
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
        <%--VALIDATING LOGIN - validation, Warning and User Attempts--%>
        var count = 0;
        $(document).ready(function () {
            const urlParams = new URLSearchParams(window.location.search);
            const status = urlParams.get('logout');

            if (status) {
                if (status === "Expired") {
                    Swal.fire(
                        'You were logged out',
                        'This account was inactive for too long',
                        'warning'
                    )
                }
                if (status === "Kicked") {
                    Swal.fire(
                        'You were logged out',
                        'You have been logged out by another session.',
                        'warning'
                    )
                }
                if (status === "InvalidAspSession") {
                    Swal.fire(
                        'You were logged out',
                        'You Were logged out due to an invalid ASP Session.',
                        'warning'
                    )
                }

            }

            var PrefLanguage = getCookie("Language");
            if (PrefLanguage == "") {
                Swal.fire({
                    title: 'Please select a language',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'English',
                    cancelButtonText: 'French'
                }).then((result) => {
                    if (result.value) {
                        setCookie("Language", "en-ca", 999);
                    } else {
                        setCookie("Language", "fr-ca", 999);
                    }
                })
            }


            var user, pass;

            $(document).on('submit', 'form', function (e) {
                e.preventDefault();
                CheckIfLoggedIn()

            });

            function CheckIfLoggedIn() {
                pass = $('#txtPassword').val();
                user = $('#txtUsername').val();

                $.ajax({
                    url: "<%= get_api%>/api/Login/CheckIfLoggedIn",
                    type: "POST",
                    cache: false,
                    async: false,
                    data: "=" + encodeURIComponent(JSON.stringify({ Username: user, Password: pass }))
                }).always(function (result, text, xhr) {
                    if (xhr.status === 200) {
                        Login()
                    } else if (xhr.status === 400) {
                        $("#UserWarning").css('display', 'block');
                    } else if (xhr.status === 202) {
                        var json = JSON.parse(result);
                        Swal.fire({
                            title: 'User is already logged in!',
                            text: "User logged in at " +
                                json._DateCreated +
                                " and was last active at " +
                                json._DateLastActive +
                                ". Do you want to log the user out and log yourself in?",
                            type: 'warning',
                            showCancelButton: true,
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#d33',
                            confirmButtonText: 'Yes, log out'
                        }).then((result) => {
                            if (result.value) {
                                LogUserOut(json.Token);
                            }
                        })
                    } else {
                        $("#UserWarning").css('display', 'block');
                    }
                })
            }


            function LogUserOut(Token) {
                $.ajax({
                    url: "<%=get_api %>/api/Session/RemoveSessionByToken/" + Token,
                    type: 'POST',
                    success: function (result) {
                        Login();
                    }
                });
            }

            function Login() {

             
                    $.ajax({
                    url: "<%= get_api%>/api/Login/LoginCredentials/",
                    type: "POST",
                    cache: false,
                    async: false,
                    data: "=" + encodeURIComponent(JSON.stringify({ Username: user, Password: pass, IP:"", Browser: bowser.name+ '-' + bowser.version}))
                }).always(function (result, text, xhr) {
                    if (xhr.status !== 200) {
                        grecaptcha.reset();
                        $("#UserWarning").css('display', 'block');
                        count++;
                        if (count >= 5) {
                            //Login Unsucessful - User's Login Attempts have exceeded 5 unsucessful attempts
                            loginAttempts();
                        }
                    }
                    else {
                        var token = JSON.parse(result).Token
                        $.ajax({
                            cache: false,
                            type: "POST",
                            contentType: "application/json; charset=utf-8",
                            url: "Orgsys_Login.aspx/setTokenSession",
                            dataType: "json",
                            data: JSON.stringify({ token: token }),
                            success: OnSuccess(token),
                            async: false
                        });
                    }
                })

      
            }

            //URL results from previous validation to allow successful redirect
            function OnSuccess(token) {
                $.getJSON("<%= get_api %>/api/Login/GetPageType/" + token, function (result) {
                    var results = JSON.parse(result);
                    var ut = results[0]["UserType"];
                    var href = results[0]["URL"];
                    if (ut == 4) {
                        //Login Unsucessful - Username or Password is blocked (Lockout)
                        grecaptcha.reset();
                        //$('#LockOutWarning').css('display', 'block');
                        count++;
                    } else if (ut == 0) {
                        //Login Unsucessful - Username or Password is incorrect, missing credentials or error occured
                        grecaptcha.reset();
                        $('#UserWarning').css('display', 'block');
                        count++;
                        if (count >= 5) { //Login Unsucessful - Login Attempts have exceeded 5 unsucessful attempts
                            loginAttempts();
                        };
                    };
                    setTimeout(function () {//this is here because firefox... yeah..
                        window.location.href = href;
                    }, 0);

                });
            };

            //Login Unsucessful - Login Attempts have exceeded 5 unsucessful attempts
            function loginAttempts() {
                $('#LoginButton').attr('disabled', 'disabled');
                $.ajax({
                    type: 'POST',
                    url: "<%= get_api %>/api/Login/ExceedLoginAttempts",
                     data: "=" + encodeURIComponent(user),
                    success: function (data) {
                       attempts = JSON.parse(data);
                    if (attempts = true) {
                        $('#UserWarning').css('display', 'none');
                        $('#ExceedLoginAttempts').css('display', 'block');
                        grecaptcha.reset();
                    } else {
                        alert("username is non existant");
                    }
                    }
                });
            };


           //Detect Debug Mode and remove recaptcha, no need to test for url
           <% #if DEBUG %>
            $('.g-recaptcha').css("visibility", "hidden");
            $('.g-recaptcha').css("height", "10px");
            $('#LoginButton').removeAttr('disabled');
            <% #endif %>

            //Detect if Dev server
            <% if (HttpContext.Current.Request.Url.Host.Contains("umbrelladev"))
        { %>
            $('.g-recaptcha').css("visibility", "hidden");
            $('.g-recaptcha').css("height", "10px");
            $('#LoginButton').removeAttr('disabled');
            <% } %>

            //TEMPORARILY DISABLE ReCaptcha in PROD until DOMAIN SETTINGS ARE FIXED
            $('.g-recaptcha').css("visibility", "hidden");
            $('.g-recaptcha').css("height", "10px");
            $('#LoginButton').removeAttr('disabled');
            //---------------------------------------------------------------------
        });

        //Actions taken when recaptcha is clicked and the call back response in json checks for encryption exists then returns bool
        function recaptchaCallback() {
            var googleResponse = jQuery('#g-recaptcha-response').val();
            if (!googleResponse) {
                return false;
            } else {
                $('#UserWarning').css('display', 'none');
                $('#LoginButton').removeAttr('disabled');
                $("#LoginButton").animate({
                    fontSize: '1em',
                }, "fast");
                $("#LoginButton").animate({
                    fontSize: '18px'
                }, "fast");
                return true;
            };
        };
    </script>
    <script src='https://www.google.com/recaptcha/api.js'></script>

</head>
<body>
    <div class="container container-table">
        <div class="row vertical-center-row">
            <div class="account-wall col-md-4 col-md-offset-4">
                <img class="profile-img" src="/Assets/img/logo_vector_2017.png" alt="" />
                <form class="form-signin" method="post" runat="server">

                    <div class="input-group">
                        <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
                        <input type="text" id="txtUsername" class="form-control" name="txtUsername" placeholder="Username" required autofocus autocomplete="off" />
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
                        <input type="password" id="txtPassword" name="txtPassword" class="form-control" placeholder="Password" required autocomplete="off" />
                    </div>

                    <label id="UserWarning" runat="server" style="display: none;" class="text-center2 login-undertitle">The Username or Password is incorrect.</label>
                    <label id="LockOutWarning" runat="server" style="display: none;" class="text-center2 login-undertitle">You do not have permission to access the portal. Please contact info@orgsoln.com.</label>
                    <label id="ExceedLoginAttempts" runat="server" style="display: none;" class="text-center2 login-undertitle">You have reached the maximum attemps to access the portal. Please contact info@orgsoln.com.</label>
                    <div class="g-recaptcha" data-callback="recaptchaCallback" data-sitekey="<%= get_recaptcha_key %>"></div>
                    <input id="LoginButton" class="btn btn-lg btn-primary btn-block" type="submit" value="submit" style="margin-top: 10px" disabled />
                    <div class="col-md-10">
                        <a href="http://orgsoln.com" class="checkbox pull-left" style="text-align: center!important;">Looking for the OSI Homepage?</a><%--<span class="clearfix"></span>--%>
                        <a href="/Orgsys_Forms/ForgotMyPassword.aspx" class="checkbox pull-left" style="text-align: center!important;">Forgot your password?</a>
                        <%--<a href="/Orgsys_Forms/RegistrationPage.aspx" class="checkbox pull-left" style="text-align: center!important;">Create an account</a><span class="clearfix"></span>--%>
                    </div>

                </form>
            </div>
        </div>
    </div>
    <div id="footer">
        <div class="footer-style">
            <p>All Rights Reserved, Organizational Solutions Inc. © 2017</p>
        </div>
    </div>
</body>

<script src="../Scripts/bowser.min.js"></script>
<script>
    //window.mobilecheck = function () {
    //    var check = false;
    //    (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor || window.opera);
    //    return check;
    //};

    const browsers = [
        { browser: bowser.firefox, MinVersion: 74 },
        { browser: bowser.chrome, MinVersion: 75 }
    ]

    function isBrowserValid(browsers) {
        for (var i = 0; i < browsers.length; i++) {

            if (browsers[i].browser == undefined ? false : browsers[i].browser && browsers[i].MinVersion >= bowser.version) {
                return true;
            }
        }
    }
    if (!isBrowserValid(browsers)) {
        Swal.fire({
            title: 'Unsupported browser '+bowser.name+ '-' + bowser.version,
            html: 
                `<div class="well">
                    <div class="row"> 
                    <div class="col-md-12">
                       <h5>Please consider upgrading or installing a supported browser. By using an unsupported browser you understand that some features may not work correctly or as quickly. An updated browser is not required however it is strongly reccomended to ensure a better experience.</h5>
                    </div>
                </div>
                <div class="row"> 
                    <div class="col-md-12">
                       <h4>Supported browsers</h4>
                    </div>
                </div>
                <div class="row"> 
                    <div class="col-md-6">
                       <a href="https://www.google.ca/chrome/">Google Chrome</a>
                    </div>
                    <div class="col-md-6">
                        <a href="https://www.mozilla.org/en-CA/firefox/">Mozilla Firefox</a>
                    </div>
                </div>
                </div>
        `,
            type: 'error',
            allowOutsideClick: false,
            allowEscapeKey : false,
            showCancelButton: false,
            confirmButtonColor: '#3085d6',
            confirmButtonText: 'I Understand',
        })
    }
        //console.log(bowser.msedge==undefined?'false':bowser.msedge)
        //console.log(bowser.msie==undefined?'false':bowser.msie)
        //console.log(bowser.safari==undefined?'false':bowser.safari)
        //console.log(bowser.opera==undefined?'false':bowser.opera)
        //console.log(bowser.windows==undefined?'false':bowser.windows)


</script>
</html>
