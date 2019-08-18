
var fileCounter = 2;

/**
 * Craetes and appends file objects to fileArray and adds file icons
 * @param {any} files
 */
function AddFilesToClaim(files) {
    for (var i = 0; i < files.length; i++) {
        var file = files[i].file;
        fileArray.push({
            id: fileCounter,
            file: file,
            ext: file.name.match(/\.[a-zA-Z]+$/)[0].replace('.', ''),
            documentTypeId: files[i].typeID
        });

        var fileDisplay = $('.showFilesList')
        if (fileDisplay.length > 0) {   //some users of this function do not need the uploaded files to displayed
            fileDisplay.append('<div class="col-md-3 appended-file" id="file' + fileCounter + '">' + file.name + '<span class="btn glyphicon glyphicon-remove"></span></div>');
        }

        fileCounter++;
    }
}

/**
 * Append file icons that represent files which have already been upload to the claim.
 * @param {any} filesJson
 */
function ShowFilesDraft(filesJson) {

    $('<div class="row showFilesList"></div>').insertAfter($('#FileUpload .row:first'));

    $.each(filesJson, function (key, doc) {

        var fileIcon = $('<div class="col-md-3 saved-file" >' + doc.DocName + '   <span class="glyphicon glyphicon-saved"></span></div>')
            .data('documentId', doc.DocID)
        $('.showFilesList').append(fileIcon);

    })    

}

// removes the file icon from the list and file object from fileArray
$(document).on('click', '.appended-file > .btn', function () {
       
    var fileIcon = $(this).closest('.appended-file');
    var fileId = fileIcon.attr('id');
    var fileIndex = fileId.replace(/[a-zA-Z]/g, '');

    fileArray = fileArray.filter(function (file) {
        return file.id != fileIndex;
    });

    RemoveFileSwal().then(function () {
        fileIcon.remove();
        $('.' + fileId).remove(); //removes hidden controls that hold file data 
    });
    
});

/**
 * Confirm removal of file.
 */
function RemoveFileSwal() {
    return swal({
        title: '',
        text: window.MessagesData["fileRemoveDesc"],
        type: 'info',
        confirmButtonText: window.MessagesData["Remove"],
        cancelButtonText: window.MessagesData["Cancel"],
        showCancelButton: true
    });
}

/**
 * Attaches a change event handler to a field which will be used to initiate the file upload process. Pass the function to push files to fileArray.
 * @param {any} selector
 * @param {any} filePushFunction
 * @param {any} saveOnUpload
 */
function AttachFileUploadHandler(selector, saveOnUpload) {

    if (selector) {
        $(document).on('change', selector, function () {
            var fileInput = $(this);
            var files = validate.groupFilesByValidity(fileInput.prop('files'));
            var hasValid = files.valid.length > 0;
            var hasInvalid = files.invalid.length > 0;
            
            fileInput.val('');    //clears the FileList object in prop('files') .abovtenko

            var uploadValidFiles = function () {    //wrapper for calls below
                UploadFilesSwal(files.valid).then(function (validFiles) {
                    if (validFiles) {
                        AddFilesToClaim(validFiles);
                        if ((saveOnUpload || false) === true) {     //save file immediately after upload
                            SaveClaimDocuments(fileArray)
                        }
                    }
                })
            }

            if (hasValid & hasInvalid) {
                ShowInvalidFilesSwal(files.invalid).then(uploadValidFiles);     //lets user know which files will not be uploaded
            } else if (hasValid) {
                uploadValidFiles();
            } else if (hasInvalid) {
                ShowInvalidFilesSwal(files.invalid);
            }
        });
    }

}

/**
 * Shows the user any files that were not uploaded because they did not meet the requirements.
 * @param {any} files
 */
function ShowInvalidFilesSwal(files) {

    var message = window.MessagesData["invalidExtension"];

    files.forEach(function (item) {
        message += '<br>' + item.file.name;
    });

    message += window.MessagesData["fileRequirements"];

    return swal({
        title: window.MessagesData["invalidDocTitle"],
        type: 'info',
        showCancelButton: false,
        html: message,
        width: '850px'
    });

}

/**
 * Show files that will be uploaded and asks for user to select a document type for each.
 * @param {any} files
 */
function UploadFilesSwal(files) {
    var doctype = window.MessagesData["docType"];
    var fileName = window.MessagesData["fileName"];
    var fileUploadTemplate = '<div id="fileUploadSwal" class="container">' +
        '<div class="row" > ' +
        '<div class="col-md-6 fileupload-type">' + doctype + '</div > ' +
        '<div class="col-md-6 fileupload-name">' + fileName + '</div > ' +
        '</div >' +
        '</div >';

    return swal({
        title: window.MessagesData["uplDocsTitle"],
        showCancelButton: true,
        cancelButtonText: window.MessagesData["Cancel"],
        html: fileUploadTemplate,
        width: '850px',
        onOpen: function() {
            var modal = $('#fileUploadSwal');

            files.forEach(function(f, index) {
                var fileRow = '<div class="row"> ' +
                    '<div class="col-md-6 documentType">' +
                    '<select class="typeid-list form-control required"></select>' +
                    '</div>' +
                    '<div class="col-md-6 documentName">' +
                    '<div class="filename-display">' +
                    f.file.name +
                    '</div>' +
                    '</div>' +
                    '</div>';

                DEBUG('setting typelist index :' + index);

                modal.append(fileRow);
                modal.find('.typeid-list:last').data('idx', index);
            });

            GetListDiffVal('GetList_DocumentType', 'typeid-list', 'Type', 'DocumentTypeID', 'Databind');

        },
        preConfirm: validate.validateSwalContentPM
    }).then(
        function() {
            $('.typeid-list').each(function() {
                var index = $(this).data('idx');
                files[index].typeID = $(this).val();
                DEBUG('setting index : ' + index);
                DEBUG('valid file doc type : ' + files[index].typeID)
            })
            //valid files have been modified
            return files;
        },
        function() {
            swal(window.MessagesData["Canceled"], window.MessagesData["noUpload"], 'error');
            return false;
        }
    );
}


function SaveClaimDocuments($fileArray, claimId) {
    claimId = claimId || window.ClaimID;
    var UpdateID = window.UpdateID || 0;
    console.log(UpdateID);
    $fileArray.forEach(function (fileObject) { 
        var doc;
        const reader = new FileReader();
        reader.readAsDataURL(fileObject.file);
        reader.onload = () => {
            let encoded = reader.result.replace(/^data:(.*;base64,)?/, '');
            if ((encoded.length % 4) > 0) {
                encoded += '='.repeat(4 - (encoded.length % 4));
            }
            doc = {
                ClaimID: claimId,
                UpdateID: UpdateID,
                DocumentDescrID: fileObject.documentTypeId,
                DocName: fileObject.file.name,
                DocExt: fileObject.ext,
                DocType: fileObject.file.type,
                FileBase64: encoded
            };

            $.ajax({
                type: "POST",
                url: getApi + "/api/Files/UploadClaimFiles/" + token,
                beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
                data: JSON.stringify(doc),
                contentType: "application/json"
            }).then(
                function () {

                },
                function () {
                    alert("failed to upload documents");
                });


        };
        reader.onerror = error => reject(error);
    });
}

   



/**
 * Creates and returns a claim document object.
 * @param {any} claimReferenceNumber
 * @param {any} type
 * @param {any} name
 * @param {any} typeId
 * @param {any} updateId
 */
function CreateClaimDocument(claimReferenceNumber, type, name, typeId, updateId) { //possible dead code
    var DateVar = new Date().toISOString();

    return {
        DocType: type,
        VersionNu: "",
        ClaimID: window.ClaimID,
        DocName: name,
        Timestamp: DateVar,
        UserID: window.UserID,
        ClaimRefNu: claimReferenceNumber,
        UpdateID: updateId || 0,
        Archived: 0,
        DocumentDescrID: typeId || 0
    }

}



function SendFile() {

}