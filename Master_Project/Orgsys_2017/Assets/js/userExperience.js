//These scripts are meant to add to the user experience

//Gives the user an option to minimize 'clickable' panels to reduce clutter on the page.
$(document).on('click', '.panel-heading span.clickable', function (e) {
    var $this = $(this);
    if (!$this.hasClass('panel-collapsed')) {
        $this.closest('.panel').find('.panel-body:first').slideUp();
        $this.addClass('panel-collapsed');
        $this.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
    } else {
        $this.closest('.panel').find('.panel-body:first').slideDown();
        $this.removeClass('panel-collapsed');
        $this.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
    }
});

//This will let the user delete the section if added by accident.
$(document).on('click', '.panel-heading span.removeable', function () {
    var panel = $(this);
    var $delete = $("#deleteSection");
    DEBUG(panel, null, null);
    $("#modalDeleteSection").modal();
        $delete.click(function () {
            panel.parents(".panel-primary:first").fadeOut(300, function () {
                $(this).remove();
            });
        });
});
$(document).ready(function () {
    //================================NAVBAR FUNTIONALITY===================
    $("#main-content li").click(function () {
        $("#main-content li").each(function () {
            $(this).removeClass("active");
        });
        $(this).addClass("active");
    });
    //=============================NAVBAR FUNTIONALITY END==================
    //================================TABLE FUNTIONALITY====================
    $('.selectable tbody').on('click', 'tr', function () {
        if ($(this).hasClass('selected')) {
            $(this).removeClass('selected');
        }
        else {
            $(this).addClass('selected');
        }
    });
    //================================TABLE FUNTIONALITY END================
     //================================PRE-DEFINED SWAL=====================
    //================================PRE-DEFINED SWAL END=================

    //================================Bootstrap notification tempaltes=====================
    //================================Bootstrap notification templates END=================
});

