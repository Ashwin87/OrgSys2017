
    var absences = GetAbsences();
    function GetAbsences() {
        var abs;
        $.ajax({
            url: getApi + "/api/Claim/GetAbsencesDetails/" + ClaimID,
            async: false,
            success: function (data) {
                abs = JSON.parse(data);
            }

        });

        return abs;
    }


var template = `<div id="divAbsences">
                       <table style="width:100%;" id="tblAbsences">
                       <thead>
                           <tr>
                               <th style="width:20px">First Off</th>
                               <th style="width:20px">Absences Approved</th>
                               <th style="width:20px">Approval Date</th>
                               <th style="width:20px">Auth From</th>
                               <th style="width:20px">Auth To</th>
                               <th style="width:40px">RTW Auth</th>
                               <th style="width:40px">RTM</th>
                               <th style="width:40px">RTF</th>
                               <th style="width:40px">Gradual RTW</th>
                               <th style="width:40px">RTW Discontinued</th>
                           </tr>
                       </thead>
                   </table>
               </div>`
var compAbsences = Vue.component('absences', {
    props: ["Api"],
    mounted: function () {
        this.PopulateAbsences();

    },

    template: template,
    methods: {
        //Populate Absences
        PopulateAbsences() {
            $('#tblAbsences').DataTable({
                select: true,
                data: absences,
                "columns": [
                    { "data": "DayOff" }, { "data": "AbsenceApproved" }, { "data": "ApprovalDate" }, { "data": "AbsAuthFrom" }, { "data": "AbsAuthTo" },
                    { "data": "RTWAuthDate" }, { "data": "RTMDate" }, { "data": "RTFDate" }, { "data": "TransRTW" }, { "data": "TransRTWDis" }
                ]
            });

        }
    }
})



var absences = new Vue({
    el: '#abs',
    components: {
        'comp-absences': compAbsences
    }

});