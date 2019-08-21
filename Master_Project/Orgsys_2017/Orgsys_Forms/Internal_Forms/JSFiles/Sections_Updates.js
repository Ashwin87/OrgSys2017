
var template = `<div><div class ="row margin_bottom">
                    <div class ="col-sm-2">
                        <label>
                            <input type="checkbox" name="directContact" id="comm14">Completed
                        </label>
                    </div>
                    <div class ="col-md-4">
                        <input type="date" class ="form-control col-md-3" name="dateBillingComp" id="comm11" />
                    </div>
                </div>
                <div>
                    <label class ="checkbox-inline">
                        <input class ="form-check-input" type="checkbox" name="directContact" id="DirectContact">Direct Contact
                    </label>
                    <label class ="checkbox-inline">
                        <input class ="form-check-input" type="checkbox" name="postage" id="Postage">Postage
                    </label>
                    <label class ="checkbox-inline">
                        <input class ="form-check-input" type="checkbox" name="courier" id="Courier">Courier
                    </label>
                </div>
                <div class ="row margin_bottom">
                    <div class ="col-md-4">
                        <label>Method</label>
                        <select class ="form-control col-md-3" name="method" id="Method"></select>
                    </div>
                    <div class ="col-md-4">
                        <label>Reason</label>
                        <select class ="form-control col-md-3" name="reason" id="Reason"></select>
                    </div>
                    <div class ="col-md-4">
                        <label>Duration</label>
                        <input type="text" class ="form-control col-md-3" name="duration" id="Duration" />
                    </div>
                </div></div>`;

new Vue({
    el: '#claimUpdates',
    data: {
        currentComponent: null,
        componentsArray: ['Billable', 'bar']
    },
    components: {
        'Billable': {
            template: template
        },
        'bar': {
            template: '<h1>Bar component</h1>'
        }
    },
    methods: {
        swapComponent: function (component) {
            this.currentComponent = component;
        }
    }
})



