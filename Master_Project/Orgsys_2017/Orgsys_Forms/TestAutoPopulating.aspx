<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestAutoPopulating.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.TestAutoPopulating" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="../Assets/js/jquery-3.1.1.js"></script>
    <script>
        $(document).ready(function () {
            
            var select = $("<select></select>");
            select.css("width", "180px");
            select.addClass("selectpicker");
            select.attr("size", 7);
            select.attr("id", "Emp");
            $("#container").append(select);
            $('#Emp').hide();
            $("#inputId").keyup(function (event) {
                $('#Emp').empty();
                $('#Emp').hide();
                if (event.target.value.length > 2)

                    BindEmpNames(0, event.target.value);
            });

            function BindEmpNames(ClientID, EmpName) {
                $.ajax({
                    type: 'GET',
                    beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                    url: "<%= get_api %>/api/DataBind/PopulateEmpNames/" + ClientID + "/" + EmpName,
                    success: function (data) {
                        results = JSON.parse(data);
                        if (results.length > 0) {
                            $('#Emp').css("top", 250);
                            $('#Emp').css("zindex", 250);
                            $('#Emp').show();
                        }
                        console.log(results);
                        for (i = 0; i < results.length; i++) {
                            $('#Emp').append($('<option>').text(results[i]["EmpFirstName"]).attr('value', results[i]["EmpID"]));
                        }
                    }
                });
            }
            function BindDemoData() {


                var jsondata = [{ "Values": [{ "Selected": false, "Text": "MyHtml", "Value": "1011" }, { "Selected": false, "Text": "gh", "Value": "1013" }, { "Selected": false, "Text": "wer", "Value": "1014" }], "Selected": false, "Text": "Your HTML", "Value": "1019" }, { "Values": [], "Selected": false, "Text": "More html", "Value": "1021" }];

                //Dynamic Select box
                var select = $("<select></select>");
                select.css("width", "180px");

                var opt;

                opt = $("<option></option>");
                opt.text("<--select -->");
                opt.val("N");
                opt.attr("selected", true);

                select.append(opt);

                // Bind  Select Box :

                $.each(jsondata, function (index, elem) {

                    var opt = $("<option></option>");
                    opt.attr("selected", elem.Selected);
                    opt.text(elem.Text);
                    opt.val(elem.Value);

                    select.append(opt);  // bind parent select box
                });

               // $("#container").append(select);
            }
        });
    </script>
</head>

<body>
    <form id="form1" runat="server">
       <div class="row margin_bottom">
             <input type="text" class="auto" id="inputId" />
           
        </div>
        <div class="row margin_bottom" id="container" style="top:550px">
           
        </div>
    </form>
</body>
</html>
