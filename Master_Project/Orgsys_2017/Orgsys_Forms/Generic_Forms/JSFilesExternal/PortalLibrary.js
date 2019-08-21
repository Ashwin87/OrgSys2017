$(document).ready(function () {
    initLibraryDataTable();
    initLibraryTypes();

    $("#library-type-select").on("change", function () {
        handleDocumentFilterChange($(this).children("option:selected").text());
    });
});


//creates an event hander for when a filter is applied to the table
function handleDocumentFilterChange(filter) {
    var table = $("#LibraryResources").DataTable();

    if (filter === 'All') {
        filter = '';
    }

    table.search(filter).draw();
}




var documentstable;
function initLibraryDataTable() {
    $.ajax({
        url: window.getApi + "/api/LibraryResources/GetLibraryResources/" + window.token,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(function (data) {
        var resources = JSON.parse(data);
        documentstable = $('#LibraryResources').DataTable({
            select: false,
            data: resources,
            "order": [[2, "DocumentName"]],
            "sPaginationType": "full_numbers",
            "rowId": "Id",
            "columns": [
                { "data": "" }, { "data": "DocumentName" }, { "data": "VersionNumber" }, { "data": "TypeName" }],
            "columnDefs": [{
                "targets": -4, "data": null, "searchable": false, "orderable": false, "defaultContent": "<a id='DownloadResource' data-toggle='tooltip' title='Download library resource' class=' btn btn-default view_description'><i class='icon icon-download3'></i></a>"
            }]
        });
    });
}

function initLibraryTypes() {
    $.ajax({
        url: window.getApi + "/api/LibraryResources/GetLibraryResourceTypes",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false
    }).then(function (data) {

        $('#library-type-select').append(new Option("All", 0, false, false)).trigger('change');
        var Types = JSON.parse(data);
        for (var i = 0; i < Types.length; i++) {
            var newOption = new Option(Types[i].TypeName, Types[i].ResourceTypeID, false, false);
            $('#library-type-select').append(newOption).trigger('change');
        }
    });
}


$(document).delegate("#DownloadResource", "click", function (event) {
    var DocID = documentstable.row($(this).parents("tr")).data().Id;
    var link = document.createElement('a');
    document.body.appendChild(link);
    link.href = getApi + "/api/LibraryResources/DownloadLibraryResource/" + window.token + "/" + DocID;
    link.click();
    
});