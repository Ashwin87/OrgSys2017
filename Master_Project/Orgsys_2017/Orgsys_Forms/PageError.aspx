<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PageError.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.PageError" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <!-- jQuery References-->
    <script src="/Assets/js/jquery-1.12.4.js"></script>
    <script src="/Assets/js/jquery.validate.min.js"></script>
    <script src="http://cdn.jsdelivr.net/alasql/0.2/alasql.min.js"></script>
    <!-- Style Sheet References-->
    <link href="/Assets/css/bootstrap.css" rel="stylesheet" />
    <!-- FONTAWESOME STYLES-->
    <link href="/Assets/css/font-awesome.css" rel="stylesheet" />
    <!-- MORRIS CHART STYLES-->
    <link href="/Assets/js/morris/morris-0.4.3.min.css" rel="stylesheet" />
    <!-- CUSTOM STYLES-->
    <link href="/Assets/css/custom.css" rel="stylesheet" />
    <link href="/Assets/css/orgsys-Internal.css" rel="stylesheet" />
    <!-- GOOGLE FONTS-->
    <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css' />
    <!-- OrgSys Styles-->
   
    <link href="/Assets/css/orgsys.css" rel="stylesheet" />
    <link href="/Assets/css/orgsys-external.css" rel="stylesheet" />
    
     <!-- Bootstrap References-->
     <script src="/Assets/bs/bootstrap.js"></script>
    <script src="/Assets/bs/bootstrap.min.js"></script>

</head>
<body>
    <form id="PageError" runat="server">
    <div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="error-template">
                <h1>Oops!</h1>
                <h1><img src="/Assets/img/Oops.png" /></h1>
                <h2>Page Not Found</h2>
                <div class="error-details">
                    Sorry, an error has occured, Requested page not found!
                </div>
                <div class="error-actions">
                    <a href="http://www.google.com" class="btn btn-primary btn-lg">Return to Login Page</a>
                    <a href="http://www.google.com" class="btn btn-default btn-lg">Contact Support</a>
                </div>
            </div>
        </div>
    </div>
</div
    </form>
</body>
</html>
