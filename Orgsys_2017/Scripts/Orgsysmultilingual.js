$(document).ready(function () {
    //get the controls with their associated data and itterate through them and set their language data
    $.ajax({
        type: "GET",
        beforeSend: function (xhr) { xhr.setRequestHeader('Language', window.Language); },
        async: false,
        url: window.getApi + "/api/Multilingual/GetMultilingualObject/" + window.getPage + "/" + window.getMaster,
        success: function (data) {
            var data = JSON.parse(data);
            window.ControlsData = data.Controls;
            window.MessagesData = data.Messages;
        },
        error: function (data) {

        }
    }).then(
        function () {
            InjectData();
        }, function () {
            alert("$.get failed!");
        }
    );

   


    //set preffered language to cookie and reload page 
    $('ul.dropdown-menu li .Language').click(function (e) {

        swal({
            title: 'Changing the language will refresh the page, data loss may occur if not saved.',
            text: 'Do you wish to proceed?',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Continue',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result) {
                setCookie("Language", this.innerHTML, 999);
                location.reload();
            }
        });
    });


    function CreateMultilingualBuildObject() {
        var controls = [];
        var MissingID = [];
        
        //paragraphs
        $("p").each(function () {
            if (typeof $(this).attr('id') !== 'undefined') {
                controls.push({
                    Type: 7, ControlID: $(this).attr('id'), ControlData: [{ Data: $(this).text(), LanguageID: 1 }, { Data: "French Here", LanguageID: 2 }],Page: window.getPage
                });
            } else {
                MissingID.push({ Type: "p", Text: $(this).text() });
            }
            
        });
        //anchors
        $("a").each(function () {
            if (typeof $(this).attr('id') !== 'undefined') {
                controls.push({
                    Type: 8, ControlID: $(this).attr('id'), ControlData: [{ Data: $(this).text(), LanguageID: 1 }, { Data: "French Here", LanguageID: 2 }], Page: window.getPage
                });
            } else {
                MissingID.push({ Type: "a", Text: $(this).text() });
            }
        });
        //headings
        for (var i = 1; i <= 6; i++) {
            $("h" + i).each(function () {
                if (typeof $(this).attr('id') !== 'undefined') {
                    controls.push({
                        Type: 6, ControlID: $(this).attr('id'), ControlData: [{ Data: $(this).text(), LanguageID: 1 }, { Data: "French Here", LanguageID: 2 }], Page: window.getPage
                    });
                } else {
                    MissingID.push({ Type: "h", Text: $(this).text() });
                }
            });
        }
        //Buttons
        $("button").each(function () {
            if (typeof $(this).attr('id') !== 'undefined') {
                controls.push({
                    Type: 5, ControlID: $(this).attr('id'), ControlData: [{ Data: $(this).text(), LanguageID: 1 }, { Data: "French Here", LanguageID: 2 }], Page: window.getPage
                });
            } else {
                MissingID.push({ Type: "btn", Text: $(this).text() });
            }
        });
        var Controls = { controls: controls, MissingID: MissingID};
        console.log(Controls);

        var blob = new Blob([JSON.stringify(Controls)], { type: "text" });

        var a = document.createElement('a');
        a.download = "controls.txt";
        a.href = URL.createObjectURL(blob);
        a.dataset.downloadurl = ["text", a.download, a.href].join(':');
        a.style.display = "none";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        setTimeout(function () { URL.revokeObjectURL(a.href); }, 1500);
    }
});

function InjectData() {
    var ControlsData = window.ControlsData;
    for (var i = 0; i < ControlsData.length; i++) {
        switch (ControlsData[i].TypeAbbr) {
        case "h":
                $('#' + ControlsData[i].ControlID).val(ControlsData[i].Data);
                $('#' + ControlsData[i].ControlID).text(ControlsData[i].Data);
                break;
        case "lbl":
            $('#' + ControlsData[i].ControlID).text(ControlsData[i].Data);
            break;
        case "a":
            $('#' + ControlsData[i].ControlID).text(ControlsData[i].Data);
            break;
        case "p":
            $('#' + ControlsData[i].ControlID).text(ControlsData[i].Data);
                break;
            case "ph":
                $('#' + ControlsData[i].ControlID).attr('placeholder',ControlsData[i].Data);
                break;
        case "btn":
            $('#' + ControlsData[i].ControlID).val(ControlsData[i].Data);
            $('#' + ControlsData[i].ControlID).text(ControlsData[i].Data);
                break;
        case "tDef":
            var tDef = JSON.parse(ControlsData[i].Data);
            var count = 0;
            $('#' + ControlsData[i].ControlID + ' > thead > tr > th').each(function () {
                $(this).text(tDef[count]);
                count++;
            });

            break;
        }
    }
}