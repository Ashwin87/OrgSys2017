<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotMyPassword.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.ForgotMyPassword" %>

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
        function psFunction() {
            var userName = $("#txtUsername").val();
            if (userName.length > 0) {

                $.ajax({
                    url: "<%= get_api%>/api/Login/RecoverPassword" ,
                    type: 'POST',
                    data: "=" + encodeURIComponent(userName),
                    success: function () {
                        $.notify(
                                {
                                    icon: 'glyphicon glyphicon-thumbs-up',
                                    message: 'An email with a password recovery link has been sent to your email address. You will now be redirected to the login page.'
                                },
                                {
                                    type: 'success',
                                    placement: {
                                        from: "top",
                                        align: "center"
                                    }
                                }
                        );

                        setTimeout(function () {
                            window.location.replace("/Orgsys_Forms/Orgsys_Login.aspx");
                        }, 3500);
                    },
                    error: function () {
                        swal('', 'This user could not be found or does not have an email associated with their account. Please reach out to your OSI Contact to request a new password.', 'info');
                    }
                })
            } else {
                $.notify(
                    {
                        icon: 'glyphicon glyphicon-thumbs-down',
                        message: 'Please enter you username to continue.'
                    },
                    {
                        type: 'danger',
                        placement: {
                            from: "top",
                            align: "center"
                        },
                    }
                );
            };
        };
    </script>
</head>
<body>
     <div class="container">
    <div class="row">
        <div class="col-sm-6 col-md-4 col-md-offset-4">
        </div>
        <div class="col-sm-6 col-md-4 col-md-offset-4">
            <div class="forgot-wall">
                <h1 class="text-center login-title2" style="font-weight:600; font-size:large; color:steelblue;">Organizational Solutions Inc.</h1>
                <h1 class="text-center login-title" style="font-weight:600;color:darkslategray;">Forgot my Password</h1>
                <h2 class="text-center2 login-undertitle" style="color:darkslategray;">You will recieve an email with a link to create a new password.</h2>
                
                <form class="form-signin" method="post" runat="server">
                    <label id="VerifyUsername" runat="server">Username:</label>
                    <input type="text" id="txtUsername" class="form-control" name="txtUsername" placeholder="Username" required autofocus autocomplete="off"/>
                        <br />
                    <button class="btn btn-lg btn-primary btn-block" id="btnGetMyPassword" type="button" runat="server" onclick="psFunction()">Recover Password</button>
                    <span class="clearfix"></span>                   
                </form>

            </div>
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

