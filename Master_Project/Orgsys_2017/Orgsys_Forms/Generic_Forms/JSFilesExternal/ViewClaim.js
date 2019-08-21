function ViewClaimReadOnly() {
    $(document).off();
    var fileButton = '<label class="btn btn-primary" for="1746">Add Files</label><input id="1746" type="file" name="Upload" class="add-files hidden-file" multiple="multiple">';
    var buttons = '<div class="pull-right action-buttons btn-group">' + fileButton + '<input id="btn-pdf" type="button" class="btn btn-info" value="Download PDF" /></div>'
    $('.osp-heading:first > div.row').append(buttons);
    $('.btn-previous, .btn-next').remove();
    $('#form-tabs').parent().remove(); //remove tabs
    $('#form-content > div').show(); //show all sections
    $('#form-actions').remove(); //remove claim action buttons
    //disable or remove inputs
    $('input[type="text"], input[type="textarea"]').attr('disabled', 'disabled').addClass('print-view').removeAttr('placeholder');
    $('input[type="checkbox"], input[type="radio"], select, .date').attr('disabled', 'disabled').removeAttr('placeholder');
    $('select').addClass('print-view').each(function () {
        if ($(this).prop('selectedIndex') === 0) {
            $(this).find('option:first').text(''); //appear empty when nothing selected insead of 'Select' /abovtenko
        }
    });
    $('.AddWitness, .AddWeek').hide();
    $('.remove-week').closest('td').remove(); 
    $('.remove-witness').remove();
    $('input[type="file"]').not('.add-files').closest('.row').remove();
    $('#FileUpload').remove();
    //remove the select2 structure, show the original select control
    $('.select2-container').remove();
    $('.select2-hidden-accessible').removeClass('select2-hidden-accessible');
    //increase width of datepicker in schedule table 
    $('.schedule-input.hasDatepicker').parent().parent().addClass('width_10');
    //insert div to hold the html structure from which the pdf will be generated
    $('<div class="hidden view-claim"><div class="osi_logo">< img class= "img_setter" src = "../../../Assets/img/Logo2017.png" /></div ><div class="important_info"><div class="first_para"><span class="info">In order for an absence to qualify under the Employers Short Term Disability plan, the medical documentation must contain objective clinical findings and detailed medical information which establishes the presence of a medical condition and treatment including objective evidence of an impairment severe enough to prevent your patient / client from participating in work. </span></div></div></div>').insertAfter('#main-container');
    //load the pdf friendly html
    $('.view-claim').load('HTMLSections/Print' + claimType + '.html', function () {
        //subsections with a class of hidden in the input form will be removed from the pdf form.
        //they are there initially since we do not know in advance which subsections will be hidden(LOA)     \abovtenko
        $('#main-container').find('.section > div.hidden').each(function () {
            $('.view-claim #' + this.id).remove();
        });
        //transferring the values this way maintains the existing masks and date formats
        $('#main-container').find('input, select').each(function () {
            var item = $(this);
            var itemName = item.attr('name') != '' ? item.attr('name') : undefined;
            if (item.attr('type') == 'checkbox' && item.prop('checked')) {
                    $('.view-claim #' + itemName).attr('checked', 'checked');
            }
            else if (item.is('select')) {
                var idx = item.prop('selectedIndex');                
                if (idx > 0) {
                    $('.view-claim #' + itemName).text(item.find('option').eq(idx).text());
                }
            }
            else {
                $('.view-claim #' + itemName).text(item.val());
            }
        });
        $('.view-claim #print-logo').append('<img src="' + logoBase64 + '" />');
        $('.view-claim .osi_logo').append('<img class="img_setter" src="../../../Assets/img/Logo2017.png" />');
    });    
    AttachFileUploadHandler('.add-files', true);
    $(document).on('click', '#btn-pdf', function () {
        var fhtml = $('.view-claim').get(0).outerHTML;
        var jsonObject = {
            json: {
                html: fhtml,
                cssFilename: "PrintTemplate_V2.css"
            }
        };
        swal('', 'Your file is being prepared and will be available in a moment.', 'info');
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'PDFHandler.ashx', true);
        xhr.setRequestHeader('Content-Disposition', 'application/json');
        xhr.responseType = 'arraybuffer';
        xhr.onload = function () {
            if (this.status == 200) {
                var file = new Blob([this.response], { type: 'application/pdf' });
                var fileURL = URL.createObjectURL(file);
                var link = document.createElement('a');
                var fileName = claimType + '_Claim.pdf';
                if (navigator.msSaveOrOpenBlob) {
                    navigator.msSaveOrOpenBlob(file, fileName);
                }
                else {
                    //neccessary for FF /abovtenko
                    document.body.appendChild(link);
                     
                    link.href = fileURL;
                    link.download = fileName;
                    link.click();
                }
            }
        }
        xhr.send(JSON.stringify(jsonObject));
    });    
}