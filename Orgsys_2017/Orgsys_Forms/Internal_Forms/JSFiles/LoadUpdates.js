//var doc = new pdfobject();

var updatesModal = `<div id="updateSummary" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times; </button>
                <h4 class="modal-title">Claim Updates</h4>
            </div>
            <div class="modal-Docu">
                <div id="view"></div>
                  <div id="test"></div>
            </div>
        </div>
    </div>
</div>
`

//Populate ClaimUpdates List
function PopulateClaimUpdates(RefNu) {
    $.ajax({
        url: getApi + "/api/ClaimUpdates/GetClaimUpdates/" + RefNu,
        beforeSend: function (request) {
            request.setRequestHeader("Authentication", window.token);
        },
        async: false,
        success: function (data) {
            var results = JSON.parse(data);
            for (i = 0; i < results.length; i++) {
                if (i % 2 == 0) {
                    linkClass = "fa fa-circle";
                    listClass = ""
                }
                else {
                    linkClass = "fa fa-circle invert";
                    listClass = "timeline-inverted";
                }

                CreateList(results[i]["ActionType"], results[i]["Comments"], results[i]["UpdatesDate"], results[i]["UpdateID"], listClass, linkClass);
            }
        }
    });
}
// Try Loading////
function CreateList(ActionType, Comments, Date, UpdateID, ListClass, LinkClass) {
    var htmlList = '<ul class="timeline">' +
                    '<li  class="' + ListClass + '">' +
                    '<div class="timeline-badge">' +
                    '<a><i class="' + LinkClass + '" +id=""></i></a>' +
                    '</div>' +
                    '<div class="timeline-panel">' +
                    '<div class ="timeline-heading">' +
                    '<h4>' + ActionType + '</h4>' +
                 '</div>' +
                    '<div class="timeline-body">' +
                    '<p>' + Comments + '</p>' +
                     '<a href="#" id="ReadMore" onclick="GetUpdatesSummary(event)" data-toggle="modal" data-target="#updateSummary" role="button" >Read More</a>' +
                      '<input type="hidden" name="updateID" class="updateID" value="' + UpdateID + '">' +
                      '<input type="hidden" name="ActionType" class="Action" value="' + ActionType + '">' +
                     
                '</div>' +
                '<div class="timeline-footer">' +
                '<p class="text-right">' + Date + '</p>' +
                '</div>' +
        '</div>' +
    '</li>' +
  '</ul>';
    $('#Updates').append(htmlList);
}
function ViewDocument(FileName) {
    $.ajax({
        type: 'GET',
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        url: getApi + "/api/DataBind/ReturnFile/" + FileName.substring(0, FileName.indexOf('.')) + "/" + FileName.substr(FileName.lastIndexOf('.') + 1),
        success: function (data) {
            var arr = data;
            var byteArray = new Uint8Array(arr);
            var a = window.document.createElement('a');

            a.href = window.URL.createObjectURL(new Blob([byteArray], { type: 'application/octet-stream' }));
            a.download = FileName;
            // Append anchor to body.
            document.body.appendChild(a);
            a.click();
            // Remove anchor from body
            document.body.removeChild(a);
        }
    });
}
function GetUpdatesSummary(event) {
    $("#test").empty();
    var target = event.target;
    var myparent = $(event.target).parent();
    var classes = $(this).parent('div').attr('class');
    var $parent = $(event.target);
    //if ($(this).children().hasClass('error'))
    //if ($(myparent).children().hasClass('updateID')) {
    var id = $(myparent).children().closest(".updateID").attr("value");
    var ac = $(myparent).children().closest(".Action").attr("value");
    var htlstr = '';

    $('#UpdatesSummary').append(updatesModal);

    $.ajax({
        url: getApi + "/api/DataBind/GetUpdatesSummary/" + id,
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', window.token); },
        type: "Get",
        async: false,
        success: function (data) {
            upd = JSON.parse(data);

            if (ac == "Additional Medical") {

                htlstr += '<a href="#" id="ReadMore" onclick="ViewDocument(\''+ upd[0]["DocName"] +'\')" role="button" >' + upd[0]["DocName"] + '</a>'
                // '<label style="padding-left:25px; padding-right:25px;font-weight:4;color:blue;">' + upd[0]["FileName"] + '</label><br><button>View</label><br>'
            }
            else if (ac == "TRTW Plan (Out)") {
                htlstr += '<label style="padding-left:25px; padding-right:25px;font-weight:4;color:blue;">' + upd[0]["TransDuty_LastDay"] + '</label><label>' + upd[1]["TransDuty_LastDay"] + '</label><br>'
                //  htlstr += '<input type="text"  value= "' + key + '" style="width: 60px;" readonly="readonly" />';

            }
        }
    });

    $("#test").append(htlstr);

    //$('#updateSummary').modal({ show: true });
}
