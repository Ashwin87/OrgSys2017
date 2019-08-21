
//Main
$(document).ready(function () {
    var TOKEN = window._token;
    var API = window._api;
    var Documents = [];

    //enables sorting of the passed date format
    $.fn.dataTable.moment('DD-MMM-YYYY');
    //Gets a list of claim files based on permissions
    $.ajax({
        type: 'GET',
        url: API + "/api/Files/GetClaimFileDataForUserExternal/" + TOKEN + "/",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (returnValue, textStatus, xhr) {
            if (xhr.status === 200) {
                Documents = JSON.parse(returnValue);
            }
        }
    });

    //initialize datatable class
    var documentviewer = new DocumentViewer(
        "#documents-table",
        "lrtip",
        "DocID",
        [
            {
                data: null, render: function (document, type, row) {
                    return '<a data-documentid="'+document["DocID"]+'" target="_blank" type="button" class="btn btn-default view_description" width="5px" data-toggle="tooltip" title="View Document"><i class="icon icon-eye"></i></a>';
                }
            },
            {
                data: null, render: function (document, type, row) {
                    return document["EmpFirstName"] + " " + document["EmpLastName"];
                }
            },
            { data: "ClaimRefNu" },
            { data: "DocName" },
            { data: "Timestamp", render: ConvertDateIsoToCustom },
            { data: "DocumentDescr" },
            { data: "DocExt" }
        ],
        Documents
    );

    var table = documentviewer.DataTable();

    //When the user clicks download, initiate DownloadClaimDocument for the DocumentViewer
    $(documentviewer.tableId + " tbody").on("click", "tr a[data-documentid]", function () {
        var Document = table.row($(this).parent()).data();
        documentviewer.DownloadClaimDocument(API, TOKEN, Document);
    });

    //On document row click, assign the selected rows data to the DocumentViewer
    $(documentviewer.tableId + " tbody").on('click', 'tr', function () {
        documentviewer.selectedRowData = table.row(this).data();
        var downloadDocumentButton = $("#download-documents-link");

        if ($(this).hasClass("selected")) {
            downloadDocumentButton.addClass("disabled");
        } else {
            downloadDocumentButton.removeClass("disabled");
        }

    });

    //When a user clicks enter on the text field or hits 'search documents' button. This event gets handled
    $("#search-documents-form").submit(function (event) {
        event.preventDefault();//prevents typical behavior of dom
        documentviewer.filterRows(event.target[0].value);
    });
});

function DocumentViewer(tableId, dom, rowId, columns, data) {
    this.tableId = tableId;
    this.dom = dom;
    this.rowId = rowId;
    this.columns = columns;
    this.data = data;
    this.initDataTable = this.initDocumentDataTable();
}

DocumentViewer.prototype.initDocumentDataTable = function () {
    return $(this.tableId).DataTable({
        dom: this.dom,
        data: this.data,
        columns: this.columns,
        rowId: this.rowId
    });
};

DocumentViewer.prototype.DataTable = function () {
    return $(this.tableId).DataTable();
};

DocumentViewer.prototype.DownloadClaimDocument = function (API, TOKEN, Document) {
    //If there's a document selected
    if (Document) {
        var link = document.createElement('a');
        document.body.appendChild(link);
        link.href = API + "/api/Files/DownloadClaimFile/" + TOKEN + "/" + Document.DocID;
        link.click();
    }
};


DocumentViewer.prototype.filterRows = function (keys) {
    this.DataTable().search(keys).draw();
};

