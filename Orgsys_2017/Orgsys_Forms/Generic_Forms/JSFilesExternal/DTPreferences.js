
/**
* Updates column visibilities of a table in DTConfig
* 
* @param containerId 
*/
function UpdateColumnVisibility(containerId) {

    //ensure that the values pulled are from the correct section
    var selector = '#' + containerId + ' .column-tiles';
    var tiles = $(selector);

    tiles
        .children()
        .each(function () {

            var isVisible = $(this).data('selected');
            var groupId = $(this).data('colId');

            UpdateDTConfig(groupId, "isVisible", isVisible);

        });

}

/**
 * Updates column indexes of a table in DTConfig
 * 
 * @param id
 */
function UpdateColumnOrder(id) {

    if ($.fn.DataTable.isDataTable('#' + id)) {
        //access dt api, get array of columns with properties
        var columns = $('#' + id).DataTable().columns().context[0].aoColumns;

        //iterate over each column to update indexes
        columns.forEach(function (col) {
            //get properties of columns after reorder event
            var groupId = col.nTh.id;
            var idx = col.idx;

            UpdateDTConfig(groupId, "index", idx);

        });
    }

}

/**
 * Updates a specific property of DTConfig 
 * 
 * @param groupId
 * @param property
 * @param value
 */
function UpdateDTConfig(groupId, property, value) {

    DTConfig.map(function (c, index, array) {

        //match column object reference
        if (c.id == groupId) {
            array[index][property] = value;
        }

    });

}

/**
 * Sets the visibility of the columns of a table based on config array
 * 
 * @param id
 * @param colConfig
 */
function SetColumnVisibility(id, colConfig) {

    if ($.fn.DataTable.isDataTable('#' + id)) {

        var DTApi = $('#' + id).DataTable();

        colConfig.forEach(function (col) {
            DTApi.column(col.index).visible(col.isVisible);
        });

    }

}

/**
 * Insert a container for the preferences section above the table referenced by tableId; idCounter is to ensure unique id values.
 * 
 * @param containerId
 * @param idCounter
 */
function AppendPreferenceSection(tableId, idCounter) {

    var tableWrapper = $('#' + tableId + '_wrapper')
    var preferenceWrapper = tableWrapper.siblings('.dt-preferences-wrapper');

    if (preferenceWrapper.length == 0) {

        //insert above datatable
        $('<div class="dt-preferences-wrapper"></div>')
            .insertBefore(tableWrapper)
            .load("HTMLSections/DTPreferences.html", function () {

                SetColumnTiles('.column-tiles', DTConfig);

                $(this).find('.nav-tabs a').each(function () {

                    var idSelector = $(this).attr('href');
                    //link preference tabs href to their content panel
                    $(this).attr('href', idSelector + idCounter);
                    $(idSelector).attr('id', idSelector.replace('#', '') + idCounter);

                });            

        });
        
    } else {
        SetColumnTiles('.column-tiles', DTConfig);
    }

}

/**
* Appends buttons corresponding to columns with css class to denote visibility
* 
* @param colConfig
*/
function SetColumnTiles(selector, colConfig) {
    //this element is from external html
    var tiles = $(selector);
    tiles.empty();

    for (var i = 0; i < colConfig.length; i++) {

        var tile = $('<input type="button" class="btn btn-default column-tile" />')
            .val(colConfig[i].label)
            .data('colId', colConfig[i].id); //to match column to config object

        if (colConfig[i].isVisible) {
            tile.addClass('column-tile-selected').data('selected', true);
        }
        else {
            tile.data('selected', false);
        }

        tiles.append(tile)

    }
}

/**
* Switches a tile's properties to represent a selected state if not and vice versa
* 
* @param tileElement
*/
function ToggleSelectedTile(tileElement) {

    if (tileElement.data('selected')) {
        tileElement.removeClass('column-tile-selected').data('selected', false)
    }
    else {
        tileElement.addClass('column-tile-selected').data('selected', true)
    }

}

function ConfirmDTChangesSwal() {
    swal({
        type: "success",
        title: "Table Settings Saved",
    });
}

//shows the config sections above the relevant datatable
$(document).on('click', '.btn-preferences', function () {
    SetColumnTiles('.column-tiles', DTConfig);
    var claimTab = $('#pcm-content > .active'); 

    claimTab.find('.dt-pref-tabs, .dt-pref-btns').show();
});

$(document).on('click', '.column-tile', function () {
    ToggleSelectedTile($(this));
});

$(document).on('click', '#close-preferences', function () {
    $('.dt-pref-tabs, .dt-pref-btns').hide();
});

