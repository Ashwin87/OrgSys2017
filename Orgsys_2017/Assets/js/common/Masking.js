
/**
 * Applys new mask where one does not exist or enable existing mask for an element
 * 
 * @param {any} element
 * @param {any} mask
 * @param {any} options
 */
function ApplyMask(element, mask, options) {
    var options = (options === undefined) ? {} : options;

    //enable current mask
    if (element.data('mask')) {
        element.data('mask').init();
    }
    //apply new mask only if a mask was supplied
    else if(mask !== undefined) {
        element.mask(mask, options);
    }

}

/**
 * Adds input masks to fields
 */
function MaskInputs(swal) {

    //target swal if passed
    var root = (swal === undefined) ? $(document) : $('#swal2-content') ;
    var sin = root.find('.vld-sin');
    var currency = root.find('.vld-currency');
    var phone = root.find('.vld-phone');
    var postal = root.find('.vld-postal');       

    //these have more involved implementations; separate
    MaskPhone(phone);
    MaskPostal(postal, root); 
    
    sin.each(function () {
        ApplyMask($(this), '000 000 000');
    });
    currency.each(function () {
        ApplyMask($(this), '#,##0.00', { reverse: true });
    });

}

function MaskPostal(postal, root) {

    postal.each(function () {

        //
        var country = root.find('[name="' + validate.getVldA(this) + '"]');
        var postalElement = $(this);

        //attach handler to update mask on corresponding postal field
        country.on('change.mask-postal', function () {
            //the 39 and 229 are id values of those countries in the os_countries table
            var postalMasks = [
                { country: ['CA', '39'], mask: 'AAA AAA' },
                { country: ['US', '229'], mask: '00000-0000' }
            ]
            var countryIdx = $(this).prop('selectedIndex');
            var countryCode = $(this).find(':selected').val();            

            if (countryIdx > 0) {
                //select mask
                var mask = postalMasks.filter(function (m) {                    
                    return m.country.indexOf(countryCode) != -1;
                })[0].mask;

                //this always sets a new mask
                //not using ApplyMask() here since a mask will already exist but needs to be changed
                postalElement.mask(mask);
            }

        });
        //initiate mask
        country.trigger('change.mask-postal')

        //enables existing mask; after unmask
        ApplyMask(postalElement);

    });

}

/**
 * Masks all phone inputs
 * 
 * @param {any} phone
 */
function MaskPhone(phone) {

    //returns a phone mask appropriate for the length of input
    var getPhoneMask = function (input) {

        var digits = input.replace(/\D+/g, '').length;

        //extra zero appended to end of masks so that they can 'step' to the next one
        switch (digits) {
            case 11:
                return '0 (000) 000 00000';
                break;
            case 12:
                return '00 (000) 000 00000';
                break;
            case 13:
                return '000 (000) 000 00000';
                break;
            case 14:
                return '0 000 (000) 000 0000';
                break;
            default:
                return '(000) 000 00000';
        }

    }

    var phoneOptions = {
        onKeyPress: function (val, e, field, options) {

            var mask = getPhoneMask(val);
            //apply new mask per key press
            $(field).mask(mask, phoneOptions);

        }
    }    

    phone.each(function () {
        var value = $(this).val() || $(this).text() //handle tags that have no value attribute
        var mask = getPhoneMask(value);
        ApplyMask($(this), mask, phoneOptions);
    });

}

/**
 * Remove the mask of all inputs that have masks
 */
function UnMaskInputs(swal) {

    var root = (swal === undefined) ? $(document) : $('#swal2-content');

    root.find('.vld-phone, .vld-postal, .vld-sin, .vld-currency').each(function () {
        if ($(this).data('mask') !== undefined) {
            //the decimal point in currency mask is kept /abovtenko
            if (/vld-currency/.test(this.className)) {
                var value = $(this).val().replace(/[$,]*/g, '');
                $(this).data('mask').remove();
                $(this).val(value);
            }
            else {
                //calling unmask() did not work; it removed the mask for a moment before it was re-applied //abovtenko
                $(this).data('mask').remove();
            }
        }
    })

}