
var witnessCounter = 1;

/**
 *  Created By:    Andriy Bovtenko
 *  Description:   Creates a new set of witness controls with modified attributes and appends after current last set.
 *                 Returns an updated verion of tableInfo which includes added controls.
 */
function AddWitness(witnessControls, caller) {

    witnessCounter++;
    var newWitnessControls = [];    
    var target = $('#' + witnessControls[0].GroupName + ' > .container');           //subsection id's are set to the group name
    $('<div class="row witness"></div>').insertAfter(target.find('.row:last'));    //the last row contains the 'Add Witness' button

    witnessControls
        .forEach(function (controlData) {
            var control = $('#' + controlData.ID);

            var newControlName = controlData.ControlName.replace(/\d+$/, '') + witnessCounter;
            var newControlID = controlData.ID + '-' + witnessCounter;

            var controlClone = control.clone();
            controlClone.attr('name', newControlName);
            controlClone.attr('id', newControlID);
            controlClone.val('');

            var controlLabelClone = control.prev().clone();
            controlLabelClone.attr('for', newControlID);

            var col = $('<div class="col-md-3"></div>');
            col.append(controlLabelClone);
            col.append(controlClone);

            target.find('.row.witness:last').append(col);

            var controlObject = $.extend({}, controlData);
            //these are the only properties that would differ
            controlObject.ControlName = newControlName;
            controlObject.ID = newControlID;
            controlObject.Row = witnessCounter;
            controlObject.Value = '';

            newWitnessControls.push(controlObject);
        });

    target.find('.row.witness:last').append($('<div class="col-md-3"><button class="btn btn-default remove-witness">Remove</button></div>'));

    if (target.children().length == 5)
        caller.attr('disabled', 'disabled');

    return newWitnessControls;

};

function RemoveWitness(caller) {
    caller.closest('.row').remove();
    $('.AddWitness').removeAttr('disabled');
};