<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegistrationPage.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.RegistrationPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title> 
    <!-- jQuery References-->
    <script src="/Assets/js/jquery-1.12.4.js"></script>
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
    <link href="../Assets/css/custom.css" rel="stylesheet" />
    <link href="../Assets/css/orgsys-Internal.css" rel="stylesheet" />
    <!-- GOOGLE FONTS-->
    <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css' />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"/>
    <link href='http://fonts.googleapis.com/css?family=Varela+Round' rel='stylesheet' type='text/css'/>
    <!-- Sweet Alerts -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/limonte-sweetalert2/6.10.3/sweetalert2.js"></script>
    <link href='https://cdnjs.cloudflare.com/ajax/libs/limonte-sweetalert2/6.10.3/sweetalert2.css' rel='stylesheet' type='text/css' />
    <!-- Date Input -->
    <script src="/Assets/js/common/DateInput.js"></script>
    <script src="/Orgsys_Forms/Generic_Forms/JSFilesExternal/RegistrationExternal.js"></script>

    <%--JAVASCRIPT DISABLED DETECTION--%>
    <noscript> 
      <style>html{display:none;}</style>
      <meta http-equiv="refresh" content="0; url=nojavascript.aspx" />
    </noscript>
    <script>
        var code;
        var count;
        var emailData;
        var Token = window.Token = "<%= Orgsys_2017.Orgsys_Classes.OSI_Page.token%>";

        //User Credentials
        function validateExternalUser() {
            count = 0;
            $('.isValid').each(function () {
                if ($(this).val().length > 0) { //check if all fields have been filled
                    $(this).css('border-color', 'darkgrey');
                    count++;
                } else {
                    //highlight fields that need to be put in before checking registration
                    $(this).css('border-color', 'red');
                    $('#Note').text("Missing Fields!").css('color', 'red');
                };
              });
              if (count === 5) {
                    $.getJSON("<%= get_api %>/api/OldOrgsysGetData/ConfirmRegistration/" + txtFirstName.value + "/" + txtLastName.value + "/" + txtEmployeeNumberorPhone.value + "/" + BirthDate.value + "/" + txtempEmail.value + "/363", function (data) {
                        results = JSON.parse(data);
                        if (results.length > 0) {
                           // $('#SubmitRequest').attr('disabled', 'disabled'); //xxx
                            $('#Note').text(" ");
                            $('.isValid').css('border-color', 'darkgrey');

                            //Generate a verification code to be sent via email
                            code = getGeneratedCode();
                            registerVerificationCode(code, $('#txtempEmail').val());
                            var html = returnVerificationEmailHTML(code);
                            emailData = returnEmailData(code, $('#txtempEmail').val(), html);
                            SendEmaiData(emailData);
                             $('#b').addClass('active');
                            $('#SubmitRequest').attr('disabled', 'disabled');
                            $('#SubmitRequest').css('color', 'darkgrey');
                            $('#Note').text("Verification code has been sent to your email. Use the code above to proceed.").css('color', 'black');
                           
                            //show verification input
                           
                        } else {
                            //sweet alert saying they are not registered, redirect to main page
                            $('#Note').text(" ");
                            $('.isValid').css('border-color', 'darkgrey');
                            swal("Registration", returnErrorHTML(), "info").then(function () {
                                location.reload();
                            });
                        };
                    })
                };
        };

        $(document).ready(function () {
            $("#btnSecurityQuestion").click(function () {
                var vcode = $('#txtsecurityQuestion').val();
                if (vcode.length > 0) {
                    checkVerificationCode(vcode);
                } else {
                    swal("Missing Validation Code", "Please enter the validation code provided in your email", "info");
                };
            });
        });

         $(function () {
            //Set the type of regex that will be used
            $("input[type=password]").keyup(function () {
                var ucase = new RegExp("[A-Z]+");
                var lcase = new RegExp("[a-z]+");
                var num = new RegExp("[0-9]+");
                var releasebutton = 0 //set a variable to count requirements

                //If the length is more or equal to 6
                if ($("#txtFirstPass").val().length >= 6) {
                    $("#6char").removeClass("glyphicon-remove");
                    $("#6char").addClass("glyphicon-ok");
                    $("#6char").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#6char").removeClass("glyphicon-ok");
                    $("#6char").addClass("glyphicon-remove");
                    $("#6char").css("color", "#FF0004");
                    releasebutton--;
                }
                //if the password contains upper case letters
                if (ucase.test($("#txtFirstPass").val())) {
                    $("#ucase").removeClass("glyphicon-remove");
                    $("#ucase").addClass("glyphicon-ok");
                    $("#ucase").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#ucase").removeClass("glyphicon-ok");
                    $("#ucase").addClass("glyphicon-remove");
                    $("#ucase").css("color", "#FF0004");
                    releasebutton--;
                }
                //if the password contains lower case letters
                if (lcase.test($("#txtFirstPass").val())) {
                    $("#lcase").removeClass("glyphicon-remove");
                    $("#lcase").addClass("glyphicon-ok");
                    $("#lcase").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#lcase").removeClass("glyphicon-ok");
                    $("#lcase").addClass("glyphicon-remove");
                    $("#lcase").css("color", "#FF0004");
                    releasebutton--;
                }
                //If the password contains a number
                if (num.test($("#txtFirstPass").val())) {
                    $("#num").removeClass("glyphicon-remove");
                    $("#num").addClass("glyphicon-ok");
                    $("#num").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#num").removeClass("glyphicon-ok");
                    $("#num").addClass("glyphicon-remove");
                    $("#num").css("color", "#FF0004");
                    releasebutton--;
                }
                //if the passwords match
                if ($("#txtFirstPass").val() == $("#txtSecondPass").val() && ($("#txtFirstPass").val() != "")) {
                    $("#pwmatch").removeClass("glyphicon-remove");
                    $("#pwmatch").addClass("glyphicon-ok");
                    $("#pwmatch").css("color", "#00A41E");
                    releasebutton++;
                } else {
                    $("#pwmatch").removeClass("glyphicon-ok");
                    $("#pwmatch").addClass("glyphicon-remove");
                    $("#pwmatch").css("color", "#FF0004");
                    releasebutton--;
                }

                //if the requirements are met, enable the button
                if (releasebutton >= 5) {
                    $('button[id*="btnPassword"]').prop('disabled', false);
                } else {
                    $('button[id*="btnPassword"]').prop('disabled', true);
                }
            });
        });

         //Validate the new password given and redirect if valid
        $(document).ready(function () {
        $('#SubmitPasswordRequest').click(function () {
            if ($("#txtUsername").val().length > 0) {
                $.getJSON("<%= get_api %>/api/Login/PasswordConfig/" + txtUsername.value + "/" + txtFirstPass.value + "/" + txtSecondPass.value, function (data) {
                    results = JSON.parse(data);
                    if (results == true) {
                        $('#SubmitPasswordRequest').attr('disabled', 'disabled');
                        $('#TimerMsg').css('display', 'block');
                        $('#timeLeft').css('display', 'block');

                        window.setInterval(function () {
                            var timeLeft = $("#timeLeft").html();
                            if (eval(timeLeft) == 0) {
                                window.location.replace("/Orgsys_Forms/Orgsys_Login.aspx");
                            } else {
                                $("#timeLeft").html(eval(timeLeft) - eval(1));
                            }
                        }, 1000);

                    } else if (results == false) {
                        $('#ExistingUserError').css('display', 'block'); //Error: User does not exist
                    };
                }).error(function (error) { DEBUG(JSON.stringify(error) + "-" + error.toString() + " error", null, null); });
            } else {
                $('#NullUserError').css('display', 'block'); //Error: No Username Provided
        };
        });
        });
    </script>
</head>
<body>
<div class="container">
    <div class="row">
        <div class="col-sm-12 col-md-12 col-md-offset-12">
            <div class="registration-wall"><h1 class="text-center login-title2" style="font-weight:600; font-size:medium; color:#161F40;">Organizational Solutions Inc.</h1>
                <h1 class="text-center login-title2" style="font-weight:600; font-size:medium; color:#195388;">Account Registration</h1>
                <div class="panel panel-default" style="border-top: 0px;">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col col-xs-14">
                                <label id="topInfo" class="text-center panel-title" style="font-size: small">Please provide your full name, employee number or phone number, email and date of birth associated to this account.</label>
                            </div>
                        </div>
                    </div>
                    <div class="panel-body tab-content">
                        <div class="tab-pane tab-content active" id="a">
                        <div class="row margin-bottom">
                            <div class="col-md-6 bottom-buffer">
                                <label for="txtFirstName">First Name:</label>
                                <input id="txtFirstName" type="text" class="form-control isValid" />
                            </div>
                            <div class="col-md-6 bottom-buffer">
                                <label for="txtLastName">Last Name:</label>
                                <input id="txtLastName" type="text" class="form-control isValid" />
                            </div>
                        </div>
                        <div class="row margin-bottom">
                            <div class="col-md-6 bottom-buffer">
                                <label for="txtEmployeeNumberorPhone">Employee Number or Phone Number:</label>
                                <input id="txtEmployeeNumberorPhone" type="text" class="form-control isValid" />
                            </div>
                            <div class="col-md-6 bottom-buffer">
                                <label for="BirthDate">Birth Date:</label>
                                <input id="BirthDate" type="date" class="form-control hasDatePicker date isValid" />
                            </div>
                        </div>
                        <div class="row margin-bottom">
                            <div class="col-md-6 bottom-buffer">
                                <label for="txtempEmail">Email Address:</label>
                                <input id="txtempEmail" type="text" class="form-control isValid" />
                            </div>
                            <div class="col-md-6 bottom-buffer">
                                <label id="txterror" for="SubmitRequest">&nbsp;</label>
                                <button id="SubmitRequest" type="button" onclick="validateExternalUser()" class="form-control btn btn-primary">Check Credentials</button>
                            </div>
                        </div>
                        </div>
                        
                         <div class="tab-pane tab-content" id="b">
                             
                             <div class="col-md-12 margin_bottom">
                                 <center>
                                    <label for="txtsecurityQuestion">Verification Code:</label>
                                     <div class="input-group">
                                    <input id="txtsecurityQuestion" style="text-align:center !important;" type="text" class="form-control" />
                                        <span class="input-group-btn">
                                            <button id="btnSecurityQuestion" class="btn btn-primary" type="button"><span id="btnSecurityQuestionglyph" class="glyphicon glyphicon-arrow-right" aria-hidden="true"></span></button>
                                        </span>
                                </div>
                                 </center>
                            </div>
                        </div>
                        <div class="tab-pane tab-content" id="c">
                            <div class="row margin_bottom">
                                    <label for="txtUsername">Create a Username:</label>
                                    <input id="txtUsername" type="text" class="form-control" />
                                <br />
                                <label id="VerifyPassword" runat="server">Type New Password:</label>
                                <label id="Label1" runat="server" style="font-size: smaller">Passwords must contain at least six characters, including uppercase, lowercase letters and numbers. Special Characters make a stronger password.</label>

                                <input type="password" id="txtFirstPass" name="txtFirstPass" class="form-control" placeholder="Password" required autofocus autocomplete="off" />
                                <div class="row">
                                    <div class="col-sm-6">
                                        <span id="6char" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size: small;"></span>6 Characters Long<br />
                                        <span id="ucase" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size: small;"></span>1 Uppercase Letter
                                    </div>
                                    <div class="col-sm-6">
                                        <span id="lcase" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size: small;"></span>1 Lowercase Letter<br />
                                        <span id="num" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size: small;"></span>Number(s)
                                    </div>
                                </div>
                                <br />
                                <input type="password" id="txtSecondPass" name="txtSecondPass" class="form-control" placeholder="Confirm Password" required autocomplete="off" />
                                <div class="row">
                                    <div class="col-sm-12">
                                        <span id="pwmatch" class="glyphicon glyphicon-remove" style="color: #FF0004;"></span>Passwords Match
                                    </div>
                                </div>

                                <div class="col-md-12">
                                    <div class="col-sm-6" style="float: right;">
                                        <button id="SubmitPasswordRequest" type="button" class="form-control btn btn-primary">Create login</button>
                                        <div>
                                            <center><label id="TimerMsg" runat="server" class="timer" >Success! Redirect in&nbsp;</label><label id="timeLeft" runat="server" style="color:orangered; font-family:Verdana; display:none; font-size:medium">3</label></center>
                                        </div>
                                        <span class="clearfix"></span>
                                    </div>
                                </div>

                            </div>
                        </div>
                    </div>
                    
                    <div class="panel-footer">
                        <div class="row">
                            <div class="col-md-14">
                                <center><label id="Note" class="text-center panel-title" style="font-size: small"></label></center>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="footer">
                    <div class="footer-style">
                        <p style="font-size:small !important; color:darkgray;">All Rights Reserved, Organizational Solutions Inc. © 2018</p>
                    </div>

                </div></div>
            </div>
        </div>
    </div>
    
</body>
</html>
