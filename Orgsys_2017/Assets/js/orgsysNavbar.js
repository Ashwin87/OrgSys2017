$(document).ready(function () {
    var windowhref = window.location.href.split(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)[5];//rfc2396 official regex to split URLs
    $($('.navbar-right').find("a[href='" + windowhref + "']")[0]).parent().addClass('nav-item-active');

    $('.nav-link').on('click', function (e) {
        //e.preventDefault();//prevents instant navigation to the link

        //apply animations to navigation
        $('.nav-item-active').addClass("nav-item-noborder");
        $(this).parent().addClass('nav-item-active');

        //disables functionality of the dropdown link in the portal-navbar
        if (!$(this).hasClass('dropdown-toggle')) {
            window.location.href = $(this).attr("href");
        }
    });
});