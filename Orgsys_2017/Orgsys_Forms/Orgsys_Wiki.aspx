<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Orgsys_Wiki.aspx.cs" Inherits="Orgsys_2017.Orgsys_Forms.Orgsys_Wiki" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Orgsys Wiki</title>
    <link rel="stylesheet" type="text/css" href="../Assets/css/wikiStyle.css" />
    <script src="../Assets/js/jquery-1.12.4.js"></script>
    <%--<script src="../Assets/js/modernizr.js"></script>--%>
    <script>//Script for data control
        var categoriesDistinct = <%=jsonCategoriesDis%>;
        var fullTable = <%=jsonResult%>;
        var questionArray = [];

        $(document).ready(function() {
            for(category in categoriesDistinct){//For each distinct category insert respective page elements
                var questionArray = [];
                var categoryName = categoriesDistinct[category];
                var categoryNameAsId = categoryName.replace(/\s/g,'');
                $("#categoryLinks").append("<li><a href='#"+categoryNameAsId+"'>"+categoryName+"</a></li>");
                $("#categoryLists").append("<ul id='"+categoryNameAsId+"' class='cd-faq-group'>"+
                                              "<li class='cd-faq-title'>"+
                                                 "<h2 class='categoryName'>"+categoryName+"</h2>"+
                                              "</li>"+
                                           "</ul>");
                questionArray = getQuestionObjects(categoryNameAsId);//Gets the question for specific category
                for(question in questionArray){
                    $("#"+categoryNameAsId+"").append("<li><a class='cd-faq-trigger' href='#0'>"+questionArray[question][0]+"</a>"+
                                                        "<div class='cd-faq-content'>" +
                                                            "<p>"+questionArray[question][1]+"</p>"+
                                                        "</div></li>");
                }
            };
            $("#categoryLinks").append("<li><a id='closeAllTabs' href='#'>Close all tabs</a></li>");//Appends a collapse all option to the category menu
            $("#closeAllTabs").click(function () {//The functionality for collapse all function
                $('.cd-faq-content').each(function () {
                    if ($(this).attr("style") == 'display: block;') {
                        $(this).siblings(".cd-faq-trigger").click();
                    }
                });

            });
        
            $("#searchBoxx").keyup(function (e) {//Search all list titles and bodies for value of text box
                var listTitles = document.getElementsByClassName('cd-faq-trigger');
                var question = $("#search").val().toUpperCase();
                for(t in listTitles){
                    title = listTitles[t].innerHTML;
                    if(title != null){
                        title = title.toUpperCase();
                        bodyText = listTitles[t].nextSibling.innerHTML.toUpperCase();
                        if (title.indexOf(question) > -1) {
                            listTitles[t].parentElement.style.display = "block";
                        } else {
                            listTitles[t].parentElement.style.display = "none";
                        }
                    }
                }
                $("#categoryLists").children("ul").each(function(){
                    isCategoryEmpty($(this));
                });
            });

            function isCategoryEmpty(category){//Gets the total amount of list items from each category and hides/shows the categorys
                var ListItems = $(category).children("li[style='display: block;']").length;
                if(ListItems == 0){
                    $(category).hide();
                } else {
                    $(category).show();
                }
            }

            function getQuestionObjects(id){
                var array = [];
                for(i in fullTable){
                    if(fullTable[i].category.replace(/\s/g,'') == id){
                        array.push([fullTable[i].question,fullTable[i].answer]);
                    }
                }
                return array;
            }
        });
    </script>
    <script src="../Assets/js/wikiScripts/wikiuserExperience.js"></script>

</head>
<body>
    <form id="searchBoxx" class="searchbox" action="">
        <input id="search" type="search" placeholder="search.." />
        <ul class="suggestions"></ul>
    </form>
    <section class="cd-faq">
        <ul id="categoryLinks" class="cd-faq-categories"></ul>
        <div id="categoryLists" class="cd-faq-items"></div>
    </section>
</body>
</html>