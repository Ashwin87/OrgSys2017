bootstrap_alert = function () { }
bootstrap_alert.warning = function (message) {
    $('#alert_placeholder').html('<div class="alert alert-warning" role="alert"><span>' + message + '</span></div>')
        .fadeTo(500, .9).delay(5000).slideUp(500, function () {
            $("#success-alert").slideUp(500);
            $(this).alert('close');
        });
}
bootstrap_alert.success = function (message) {
    $('#alert_placeholder').html('<div class="alert alert-success" role="alert"><span>' + message + '</span></div>')
        .fadeTo(500, .9).delay(5000).slideUp(500, function () {
            $("#success-alert").slideUp(500);
            $(this).alert('close');
        });
}
bootstrap_alert.danger = function (message) {
    $('#alert_placeholder').html('<div class="alert alert-danger alert-design" role="alert"><span>' + message + '</span></div>')
        .fadeTo(500, .9).delay(5000).slideUp(500, function () {
            $("#success-alert").slideUp(500);
            $(this).alert('close');
    });
}