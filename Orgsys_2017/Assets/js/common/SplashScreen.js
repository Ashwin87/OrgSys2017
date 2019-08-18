
$('body').append('<div id="loadingDiv"><div class="loaderImg"><img id="loadingImg" src="/Assets/img/osilogonotrans.png"></div></div>');

$(window).on('load', function () {
    setTimeout(removeLoader, 500); //wait for page load PLUS 0.5 seconds.
});

function removeLoader() {
    $("#loadingDiv").fadeOut(500, function () {
        $("#loadingDiv").remove();
    });
}