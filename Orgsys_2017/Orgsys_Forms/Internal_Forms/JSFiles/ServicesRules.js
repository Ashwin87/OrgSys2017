

function GetServicesRules() {
    $.ajax({
        url: getApi + "/api/Form/GetServicesRules",
        beforeSend: function (xhr) { xhr.setRequestHeader('Authentication', token); },
        type: "Get",
        async: false,
        success: function (data) {
            results = JSON.parse(data);
            console.log(results);
            for (i = 0; i < results.length; i++) {
                $('[name="' + results[i]["ControlName"] + '"]').addClass(results[i]["FormType"]);

            }
        }, 
        error: function (msg) {
        }
    });
}

function LoadServices()
{
    if (formName == "WC") {
        //$('.panel-title').text("WC Internal Form");
        $(".WC").each(function () {
            // $(this).pare
            $(this).parent("div").css("display", "block");
        });
        $(".WC_STD").each(function () {
            // $(this).pare
            $(this).parent("div").css("display", "block");
        });
        $(".STD").each(function () {
            $(this).parent("div").css("display", "none");
        });
        
    }
    
    else if (formName == "STD") {
        $('.panel-title').text("STD Internal Form");
        $(".STD").each(function () {
            $(this).parent("div").css("display", "block");
        });
        $(".WC_STD").each(function () {
            // $(this).pare
            $(this).parent("div").css("display", "block");
        });
        $(".WC").each(function () {
            $(this).parent("div").css("display", "none");
        });
       
    }
}