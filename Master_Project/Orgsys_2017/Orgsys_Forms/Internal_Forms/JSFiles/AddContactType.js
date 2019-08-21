
var contactTypeTemplate = `
        <div class ="row margin_bottom rowContactType">
    <div class ="col-md-2">
        <label>Contact Type</label>
        <select class ="form-control populateContactType" name="contactType" v-bind:id="'ContactType'+id"></select>
    </div>
    <div class ="col-md-2">
        <label for="contactDetail">Contact Detail</label>
        <input type="text" class ="form-control" name="contactDetail" placeholder="Contact Detail" v-bind:id="'ContactDetail'+id" />
    </div>
    <div class ="col-md-2">
        <label for="Fax">Ext (if apply) </label>
        <input type="text" class ="form-control" name="ext" placeholder="Ext" v-bind:id="'Ext'+id" />
    </div>
    <div class ="col-md-2">
        <label for="PriorityOrder">Priority Order</label>
        <select class ="form-control priorityOrder" name="priorityOrder" placeholder="Priority Order" v-bind:id="'PriorityOrder'+id"></select>
    </div>
    <div class ="col-md-2">
        <label for="preferredTOD">Preferred TOD</label>
        <input type="text" class ="form-control" name="preferredTOD" placeholder="Preferred TOD" v-bind:id="'PreferredTOD'+id" />
    </div>
</div>`

Vue.component('contacttype', {
    props: ['id'],
    mounted: function () {
        this.Priority();
        this.PopulateContactType();
    },
    methods:
        {
            PopulateContactType:function()
            {
                GetList('GetList_ContactType','populateContactType','ContactType_En')
            },
            Priority: function () {

                for (var i = 1, l = this.id; i <= l; i++) {
                    $('.priorityOrder').append($('<option>').text(i).attr('value', i));


                }
            }
        },

    template: contactTypeTemplate

});

new Vue({
    el: '#appContactType',
    data: {
        contactTypeCounter: 0
    },

    methods: {
        addContactType: function () {
            $('.priorityOrder').empty();
            this.contactTypeCounter += 1;
           
        }
        
    }
})
