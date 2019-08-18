import Document from './ClaimDocument';
import '../../../jquery-1.12.4';
import * as moment from '../../../moment';
import '../../../dataTables/jquery.dataTables';
import '../../../dataTables/dataTables.bootstrap';
import '../../../../DataTables/Select-1.2.3/js/dataTables.select';
import '../../../datetime-moment';


let Documents = [];

//Main
$(document).ready(() => {
    const TOKEN = window._token;
    const API = window._api;

    //enables sorting of the passed date format
    $.fn.dataTable.moment('DD-MMM-YYYY');
    //Gets a list of claim files based on permissions
    $.ajax({
        type: 'GET',
        url: `${API}/api/Files/GetClaimFileDataForUser/${TOKEN}/`,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        async: false,
        success: function (returnValue) {
            Documents = JSON.parse(returnValue);
            var date = moment(Documents[0].Timestamp);
            console.log(date.format(moment.HTML5_FMT.DATE));

            //console.log(moment.format(Documents[0].Timestamp));
        }
    });
    //initialize datatable class
    let documentviewer = new DocumentViewer({
        tableId: "#documents-table",
        dom: "lrtip",
        rowId: "DocID",
        data: Documents,
        columns: [{ data: null, render: (data) => `${data.EmpFirstName} ${data.EmpLastName}` }, { data: "ClaimRefNu" }, { data: "DocName" }, { data: "Timestamp" }, { data: "DocumentDescr" }, { data: "DocExt" }]
    });
   
    var table = documentviewer.DataTable();

    //When the user clicks download, initiate DownloadClaimDocument for the DocumentViewer
    $("#download-documents-link").on("click", function () {
        if (!$(this).hasClass("disabled")) {
            documentviewer.DownloadClaimDocument(API, TOKEN);
        }
    });

    //On document row click, assign the selected rows data to the DocumentViewer
    $(`${documentviewer.tableId} tbody`).on('click', 'tr', function () {
        documentviewer.selectedRowData = table.row(this).data();
        let downloadDocumentButton = $("#download-documents-link");

        if ($(this).hasClass("selected")) {
            downloadDocumentButton.addClass("disabled");
        } else {
            downloadDocumentButton.removeClass("disabled");
        }
        
    });

    //When a user clicks enter on the text field or hits 'search documents' button. This event gets handled
    $("#search-documents-form").submit(function(event){
        event.preventDefault();//prevents typical behavior of dom
        documentviewer.filterRows(event.target[0].value);
    });
});

//DocumentViewer Class
class DocumentViewer {
    constructor(props) {
        this.tableId = props.tableId;
        this.dom = props.dom;
        this.rowId = props.rowId;
        this.columns = props.columns;
        this.data = props.data;
        this.selectedRowData = props.selectedRowData;
        this.initDataTable = this.initDocumentDataTable();
    }
    //initialize the DataTable
    initDocumentDataTable() {
        return $(`${this.tableId}`).DataTable({
            dom: `${this.dom}`,
            select: {
              style: 'single'  
            },
            data: this.data,
            columns: this.columns,
            rowId: this.rowId
        });
    }
    //Gets the current state of the datatable
    DataTable() {
        return $(`${this.tableId}`).DataTable();
    }
    //Downloads a claim document provided the API LINK, TOKEN and Document selected
    DownloadClaimDocument(API, TOKEN) {
        var Document = this.selectedRowData;
        //If there's a document selected
        if (Document) {
            var request = new XMLHttpRequest();
            request.open('GET', `${API}/api/Files/DownloadClaimFile/${TOKEN}/${Document.DocID}`, true);
            reguest.setRequestHeader("Authentication", window.token);
            request.onload = function () {
                // Only handle status code 200
                if (request.status === 200) {
                    const blob = new Blob([request.response], { type: Document.DocType });
                    let link = document.createElement('a');
                    link.href = window.URL.createObjectURL(blob);
                    link.download = Document.DocName;

                    //Appends a link to the body of the page, clicks the link and then removes the link to prevent a buildup
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                }
            };
            request.send();
        }
    }

    //Filters the rows of the datatable 
    filterRows(keys) {
        this.DataTable().search(keys).draw();
    }
}