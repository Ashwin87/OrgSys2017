<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ExternalPasswordConfig.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.ExternalPasswordConfig" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title> 
    <!-- jQuery References-->
    <script src="/Assets/js/jquery-1.12.4.js"></script>
    <script src="/Assets/js/jquery.validate.min.js"></script>
    <script src="/Assets/js/purl.js"></script>
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
    <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css' />
    <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"/>
    <link href='http://fonts.googleapis.com/css?family=Varela+Round' rel='stylesheet' type='text/css'/>
    <!-- SWAL -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/limonte-sweetalert2/6.10.3/sweetalert2.js"></script>
    <link href='https://cdnjs.cloudflare.com/ajax/libs/limonte-sweetalert2/6.10.3/sweetalert2.css' rel='stylesheet' type='text/css' />
    
    <%--JAVASCRIPT DISABLED DETECTION--%>
    <noscript> 
      <style>html{display:none;}</style>
      <meta http-equiv="refresh" content="0; url=nojavascript.aspx" />
    </noscript>

    <script>
        var recoveryToken;
        if ($.url().param('recoverytoken')) {
            recoveryToken = $.url().param('recoverytoken');
            $.get("<%= get_api%>/api/Login/ValidateRecoveryToken/" + recoveryToken, function (data) {
                if (data !== true) {                                                //token expired
                    window.location.replace('/Orgsys_Forms/Orgsys_Login.aspx')      //redirect to login
                }
            })
        }
        else {
            window.location.replace('/Orgsys_Forms/Orgsys_Login.aspx')      
        }


   
       

        $(function () {            

            $('button[id*="btnPassword"]').prop('disabled', true);

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

            //Validate the new password given and redirect if valid
            $('#btnPassword').click(function () {
                $('#ExistingUserError').css('display', 'none');
                $('#NullUserError').css('display', 'none');

                var userName = $("#txtUsername").val()
                if (userName.length > 0) {

                    $.ajax({
                        url: "<%= get_api%>/api/Login/PasswordConfig/" + recoveryToken,
                        type: 'POST',
                        data: {
                            username: userName,
                            password: $('#txtFirstPass').val()
                        },
                        success: function (data) {
                            if (data === true) {

                                swal({
                                    title: 'Password Changed',
                                    html: 'You will be redirected to the login page in a moment.',
                                    type: 'success',
                                    timer: 3210,
                                    onOpen: function () {
                                        swal.showLoading();
                                        setTimeout(function () {
                                            window.location.replace('/Orgsys_Forms/Orgsys_Login.aspx')
                                        }, 3210)
                                    }
                                });

                            } else {
                                $('#ExistingUserError').css('display', 'block');    //Error: User does not exist
                            }
                        },
                        error: function () { }
                    });
                } else {
                    $('#NullUserError').css('display', 'block');                    //Error: No Username Provided
                };
            });
        });
    </script>
    
</head>
<body>
     <div class="container">
    <div class="row">
        <div class="col-sm-6 col-md-4 col-md-offset-4">
            
        </div>
        <div class="col-sm-6 col-md-4 col-md-offset-4">
            <div class="password-wall">
                <h1 class="text-center login-title" style="font-weight:600;color:darkslategray;">Password Reset</h1>
            <h2 class="text-center2 login-undertitle" style="color:darkslategray;">Set the password you wish to use for your account</h2>
                <%--<img class="password-img" src="/Assets/img/OSISecurity.png" alt=""/>--%>
                <form class="form-signin" method="post" runat="server">
                <label id="VerifyUsername" runat="server">Verify Username:</label>
                <input type="text" id="txtUsername" class="form-control" name="txtUsername" placeholder="Username" required autofocus autocomplete="off"/>
                <label id="ExistingUserError" runat="server" style="color:red;display:none;" class="text-center2 login-undertitle" >Ensure that you have entered the correct username. If this issue continues, please contact info@orgsoln.com.</label>
                <label id="NullUserError" runat="server" style="color:red;display:none;" class="text-center2 login-undertitle" >Please fill in the Username to continue</label>
                    <br />
                <label id="VerifyPassword" runat="server">Type New Password:</label>
                <label id="Label1" runat="server" style="font-size:smaller">Passwords must contain at least six characters, including uppercase, lowercase letters and numbers. Special Characters make a stronger password.</label>
                
                <input type="password" id="txtFirstPass" name="txtFirstPass" class="input-lg form-control"  placeholder="Password" required autofocus autocomplete="off"/>
                    <div class="row">
                        <div class="col-sm-6">
                            <span id="6char" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>6 Characters Long<br/>
                            <span id="ucase" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>1 Uppercase Letter
                        </div>
                        <div class="col-sm-6">
                            <span id="lcase" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>1 Lowercase Letter<br/>
                            <span id="num" class="glyphicon glyphicon-remove" style="color: #FF0004; font-size:small;"></span>Number(s)
                        </div>
                    </div><br />
                <input type="password" id="txtSecondPass" name="txtSecondPass" class="input-lg form-control" placeholder="Confirm Password" required autocomplete="off"/>
                    <div class="row">
                        <div class="col-sm-12">
                            <span id="pwmatch" class="glyphicon glyphicon-remove" style="color: #FF0004;"></span>Passwords Match
                        </div>
                    </div>
                    <br />
                    <button class="btn btn-lg btn-primary btn-block" id="btnPassword" type="button" runat="server">Change Password</button><br />
               <span class="clearfix"></span>
                   
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>
