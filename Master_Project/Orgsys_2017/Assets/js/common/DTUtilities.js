

/**
 * Checks if item is a DataTable, then clears and destroys it.
 * @param {any} targetTable
 */
function ClearAndDestroyIfDataTable(targetTable) {

    if ($.fn.DataTable.isDataTable(targetTable)) {
        targetTable.DataTable().clear().draw();
        targetTable.DataTable().destroy();
    }

}

/**
 * Initializes a table identified by a selector using a config object
 * @param {any} tableSelector
 * @param {any} tableConfig
 */
function InitializeDT(tableSelector, tableConfig) {

    var table = $(tableSelector);
    if (!$.fn.DataTable.isDataTable(table)) {
        table.DataTable(tableConfig);
    }

    return table.DataTable();

}

/**
 * Set datatable data. Existing data will be cleared.
 * @param {any} DTApi
 * @param {any} data
 */
function SetDataDT(table, data) {
    var isDataTable = $.fn.DataTable.isDataTable(table)

    if (isDataTable) {
        var tableDT = $(table).DataTable();
        tableDT.clear();
        tableDT.rows.add(data).draw();
        try {
            MaskInputs();
        }
        catch (e) { }
    }
    else {
        throw table + " is not a DataTable"
    }
}

/**
 * Displays swal modal, deletes record if deletion confirmed by user
 * @param {any} tableSelector   The table to be changed.
 * @param {any} itemName        Used in prompts to identify the type of record.
 * @param {any} caller          The element on which the event occured. Used to get row index.
 */
function DeleteRecordSwalDT(tableSelector, itemName, caller) {

    var table = $(tableSelector).DataTable();
    var index = table.row(caller.closest('tr')).index();

    return swal({
        title: 'Delete ' + itemName,
        text: 'Are you sure you want to remove this '+ itemName +' information?',
        showCancelButton: true,
        cancelButtonText: 'Cancel',
        confirmButtonText: 'Delete ' + itemName,
        width: '850px'
    }).then(
        function () {
            table.row(index).remove().draw();
            swal('', itemName + ' has been removed!', 'success');

            return table; //allow for further manipulations from inside then block
        },
        function () {
            swal("Cancelled", itemName + ' not removed.', "error");

            return false;
        }
    );

}