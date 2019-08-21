
/**
 * Shows next page if one exists
 */
function MoveNext() {
    var page = $('#form-content .section.active');
    var tab = $('#form-tabs li.active');

    if (tab.next().length > 0) {
        tab.removeClass('active').next().addClass('active in');
        page.removeClass('active').next().addClass('active in');
    }
}

/**
 * Shows previous page if one exists
 */
function MovePrevious() {
    var page = $('#form-content .section.active');
    var tab = $('#form-tabs li.active');

    if (tab.prev().length > 0) {
        tab.removeClass('active').prev().addClass('active in');
        page.removeClass('active').prev().addClass('active in');
    }
}

//shows the next section
$(document).on('click', '.btn-next', function (e) {
    MoveNext();
});    
//  //shows the previous section
$(document).on('click', '.btn-previous', function (e) {
    MovePrevious();
});    

// 
function GetSectionID() {
    return $('div.section.active').attr('id');
}