var validate = (function () {

    /* BASIC USAGE
     * 
     * : adding validation classes to fields 
     *      - vld-number        : an integer
     *      - vld-decimal       : a number rounded to two or less decimal places
     *      - vld-alphanumeric  : letters and/or numbers only; any case
     *      - vld-email         : generic emails such as johnson@yahoo.com
     *      - vld-phone         : 10 - 14 digits, only digits
     *      - vld-postal        : multiple formats based on what country is selected, country field is bound; see ValidatePostalCode() and GetVLDA() for details
     *      - vld-checkgroup    : assign this to div containing a radio/checkbox grouping, ensures at least one is checked
     *      - vld-sin           : 9 digits, only digits
     *      
     * : once above are added, call appropriate validation set function
     *      - validateAllWithValues     : validates values of fields that have values entered; ignores required
     *      - validateAllRequried       : ensures that required fields have a value entered
     *      - validateSubmission        : validates all entered values and required fields
     *      - validateSwalContentPM     : validates all entered values and required fields within restricted scope of current swal
     * 
     */

    //
    // all regex and other information which will be used to validate data
    //
    var public = {};
    var rgxIsNumber = /^[0-9]+$/;
    var rgxIsDecimal = /^[0-9]+(\.[0-9]{1,2})*$/;
    var rgxIsAlphaNumeric = /^[a-zA-Z0-9]+$/;
    var rgxIsISODateFormat = /^[0-9]{4}-[0-9]{2}-[0-9]{2}/;
    var rgxIsEmail = /^([a-zA-Z0-9\-\.\_]+)@([a-zA-Z0-9\-\.\_]+)\.([a-zA-Z]{1,10})$/;
    var rgxIsText = /rgx/;
    var rgxIsSIN = /^[0-9]{9}$/;
    var rgxIsPostalCodeCA = /^[a-zA-Z0-9]{3}[\s]*[a-zA-Z0-9]{3}$/;
    var rgxIsPostalCodeUS = /^[0-9]{5}$|^[0-9]{5}[-]*[0-9]{4}$/;
    var rgxIsPhoneNumber = /^[0-9]{10,14}$/;
    var rgxIsAllowedExt = /\.(doc|docx|txt|pdf)$/;
    var rgxIsImageExt = /\.(jpg|png)$/i;

    var binaryBytesInMB = 1048576;
    var standardMaxFileSize = 4 * binaryBytesInMB;

    //
    //these messages will appear as tooltips when hovering over a field that has an error
    //
    var isRequiredMessage = 'Required';
    var isNumberMessage = 'Must be a number';
    var isDecimalMessage = 'Must be a number with no more than 2 digits after the decimal point';
    var isEmailMessage = 'Emails must be in the format X@X.X e.g. jsmith@mail.com';
    var isSINMessage = 'Must be a number consisting of 9 digits';
    var isPhoneNumberMessage = 'Please enter a valid phone number';
    var isAlpaNumericMessage = 'Must consist of alphanumeric characters';    
    //the 39 and 229 are id values of those countries in the os_countries table
    var isPostalCodeMessageArray = [
        { countryCode : ['US', '229'], rgx : rgxIsPostalCodeUS, message : 'Postal Code must consist of digits and be in the format XXXXX or XXXXX-XXXX' },
        { countryCode : ['CA', '39'], rgx : rgxIsPostalCodeCA, message : 'Postal Code must consist of 6 alphanumeric characters e.g. 123 XYZ' }
    ]   

    //
    //validation that cannot use regex and/or implementations of regex validation for use in validation sets.
    //

    /**
     * Determines if any checkboxes of a group have been selected, returns boolean.
     * 
     * @param {any} target
     */
    function isAnyChecked(target) {
        var checked = $(target).find(':checked');

        if (checked.length > 0) {
            return true;
        }

        return false;
    }

    /**
     * Determines if an option has been selected from a dropdown, returns boolean.
     * 
     * @param {any} target
     */
    function hasSelected(target) {
        //exclude first option since it is a prompt
        var selected = $(target).find('option').not(':first').filter(':selected');

        if (selected.length == 1) {
            return true;
        }

        return false;
    }

    /**
     * Determines if a file has an allowed extension and its size does not exceed a limit
     * @param {any} file
     * @param {any} maxFileSize
     */
    function isValidFile(file, maxFileSize) {
        //use passed limit value if available
        var maxFileSize = (maxFileSize == undefined) ? standardMaxFileSize : maxFileSize ;

        if (rgxIsAllowedExt.test(file.name) && file.size <= maxFileSize) {
            return true;
        }

        return false;
    }

    /**
     * Determines if a file has an allowed extension of an image and its size does not exceed a limit
     * @param {any} file
     * @param {any} maxFileSize
     */
    function isValidImage(file, maxFileSize) {

        var maxFileSize = (maxFileSize || standardMaxFileSize);
        if (rgxIsImageExt.test(file.name) && file.size <= maxFileSize) {
            return true;
        }

        return false;
    }

    //ensure required controls have a value, excluding groups of control in divs
    function ValidateRequired(trg) {
        var value = ($(trg).data('mask') !== undefined) ? $(trg).cleanVal() : $(trg).val();
        var valid = value != '';
        toggleErrorAndTooltip(valid, $(trg), isRequiredMessage);

        return valid;
    }

    function ValidateEmpContactDetails(controls) {
        var valid = false;
        for (var i = 0; i < controls.length; i++) {
            if ($(controls[i]).val() !== "") {
                valid = true;
            }
        }
        if (!valid && !$("#vldPersonalCntact").is(":hidden") ) {
            $(empValidHtml).prependTo($(controls[0]).parent().parent());
            toggleErrorAndTooltip(valid, $(controls), isRequiredMessage);
        } else {
            $("#vldPersonalCntact").hide();
        }

        return valid;
    }

    //ensure option selected is not the prompt on required select controls
    function ValidateRequiredSelect(trg) {
        var valid = hasSelected($(trg));
        toggleErrorAndTooltip(valid, $(trg), isRequiredMessage);

        return valid;
    }

    function ValidateNumber(trg) {
        var valid = false;

        if ($(trg).val() != '') {
            valid = public.isNumber($(trg).val());
            toggleErrorAndTooltip(valid, $(trg), isNumberMessage);
        }
        else {
            return null;
        }

        return valid;
    }

    function ValidateSIN(trg) {
        var valid = false;
        var value = ($(trg).data('mask') !== undefined) ? $(trg).cleanVal() : $(trg).val() ;

        if (value != '') {
            valid = public.isSIN(value);
            toggleErrorAndTooltip(valid, $(trg), isSINMessage);
        }
        else {
            return null;
        }

        return valid;
    }

    function ValidateEmail(trg) {
        var valid = false;

        if ($(trg).val() != '') {
            valid = public.isEmail($(trg).val());
            toggleErrorAndTooltip(valid, $(trg), isEmailMessage);
        }
        else {
            return null;
        }

        return valid;
    }

    function ValidatePostalCode(trg, country) {
        var valid = false;
        var country = $(country).first();
        //keep dash for US ZIP+4 format?
        var value = ($(trg).data('mask') !== undefined) ? $(trg).cleanVal() : $(trg).val();

        if (value != '' && country.length > 0) {

            //validation is based on selected country          
            var countryIdx = country.prop('selectedIndex');
            var countryCode = country.find('option').eq(countryIdx).val();

            //cannot validate unless a country is selected
            if (countryIdx > 0) {

                var validationObject = isPostalCodeMessageArray.filter(function (p) {
                    return p.countryCode.indexOf(countryCode) != -1;
                })[0];

                valid = validationObject.rgx.test(value);
                toggleErrorAndTooltip(valid, $(trg), validationObject.message);
            }
            else {
                toggleErrorAndTooltip(false, $(trg), 'Please select a country first');
            }
        }
        else {
            return null;
        }

        return valid;

    }

    function ValidatePhoneNumber(trg) {
        var valid = false;
        var value = ($(trg).data('mask') !== undefined) ? $(trg).cleanVal() : $(trg).val();

        if (value != '') {
            valid = public.isPhoneNumber(value);
            toggleErrorAndTooltip(valid, $(trg), isPhoneNumberMessage);
        }
        else {
            return null;
        }

        return valid;
    }

    function ValidateDecimal(trg) {
        var valid = false;
        //remove junk from possible mask
        var value = $(trg).val().replace(/[$,]*/g, '');

        if (value != '') {
            valid = public.isDecimal(value);
            toggleErrorAndTooltip(valid, $(trg), isDecimalMessage);
        }
        else {
            return null;
        }

        return valid;
    }

    function ValidateAlphaNumeric(trg) {
        var valid = false;

        if ($(trg).val() != '') {
            valid = public.isAlphaNumeric($(trg).val());
            toggleErrorAndTooltip(valid, $(trg), isAlphaNumericMessage);
        }
        else {
            return null;
        }

        return valid;
    }

    function ValidateCheckGroup(trg) {
        var valid = isAnyChecked($(trg));
        toggleErrorAndTooltip(valid, $(trg), isRequiredMessage);

        return valid;
    }

    //
    //validation set functions;
    //these are used to validate whole forms or whole sections of forms, create as needed.
    //

    /**
     * Validates all fields that have a value to check and returns false if any errors occur, otherwise true.
     */
    function ValidateAllWithValues(rootElement) {

        //need to restrict search scope for swal validation
        var rootElement = (rootElement === undefined) ? document : rootElement;
        var errors = 0;

        $(rootElement).find('.regexNumbers, .vld-number').each(function () {
            var result = ValidateNumber(this);
            if (result == false) errors += 1;
        });

        $(rootElement).find('.vld-sin').each(function () {
            var result = ValidateSIN(this);
            if (result == false) errors += 1 ;
        });

        $(rootElement).find('.vld-decimal, .vld-currency').each(function () {
            var result = ValidateDecimal(this);
            if (result == false) errors += 1;
        });

        $(rootElement).find('.vld-email').each(function () {
            var result = ValidateEmail(this);
            if (result == false) errors += 1;
        });

        $(rootElement).find('.vld-postal').each(function () {
            //gets the name value of the country dropdown to validate postalcode against /abovtenko
            var nameValue = GetVLDA(this);
            var result = ValidatePostalCode(this, '[name="' + nameValue + '"]');
            if (result == false) errors += 1;
        });

        $(rootElement).find('.vld-phone').each(function () {
            var result = ValidatePhoneNumber(this);
            if (result == false) errors += 1;
        });

        if (errors == 0) {
            return true
        }

        return false;

    }

    /**
     * Validates all required fields and returns false if any errors occur, otherwise true.
     */
    function ValidateAllRequired(rootElement) {

        //need to restrict search scope for swal validation
        var rootElement = (rootElement === undefined) ? document : rootElement;
        var errors = 0;

        $(rootElement).find('.required').not('div, select').each(function () {
            if (!ValidateRequired(this)) errors += 1;
        });

        $(rootElement).find('select.required').each(function () {
            if (!ValidateRequiredSelect(this)) errors += 1;
        });

        $(rootElement).find('.vld-checkgroup.required').each(function () {
            if (!ValidateCheckGroup(this)) errors += 1;
        });

        var EmpContactControls=[];
        $(rootElement).find('.vld-empContact').each(function () {
            EmpContactControls.push(this);
        });
        if (EmpContactControls.length !== 0 && !ValidateEmpContactDetails(EmpContactControls)) errors += 1;

        if (errors == 0) {
            return true;
        }

        return false;

    }

    /**
     * Validates all required fields and all field values, return false if any errors occur, otherwise true.
     */
    function ValidateSubmission(rootElementSelector) {
        var root = (rootElementSelector === undefined) ? document : $(rootElementSelector);
        var errors = 0;
        
        if (!ValidateAllRequired(root)) {
            errors += 1;
        }

        if (!ValidateAllWithValues(root)) {
            errors += 1;
        }
        
        if (errors == 0) {
            return true;
        }

        return false;
    }

    /**
    * Validates all required fields and all field values within the currently displayed swal, returns false if any errors occur, otherwise true.
    */
    function ValidateSwalContent() {
        //ensure only the swal content is validated
        var swalRoot = $('#swal2-content');
        var errors = 0;

        if (!ValidateAllRequired(swalRoot)) {
            errors += 1;
        }

        if (!ValidateAllWithValues(swalRoot)) {
            errors += 1;
        }

        if (errors == 0) {
            return true;
        }

        return false;
    }
    
    //
    // miscellaneous, helpers
    //

    /**
     * Iterates over an input:file element's files property and returns an object containing two file arrays, valid and invalid
     * in order to show the user which files uploaded successfully and which didn't
     * @param {any} files
     */
    function GroupFilesByValidity(files) {

        var invalidFiles = [];
        var validFiles = [];

        for (var i = 0; i < files.length; i++) {

            if (isValidFile(files[i])) {
                validFiles.push({
                    file: files[i],
                    typeID: undefined
                });
            } else {
                invalidFiles.push({
                    file: files[i],
                    typeID: undefined
                });
            }
        }

        return {
            valid: validFiles,
            invalid: invalidFiles
        }

    }

    /**
     * Adds or removes error class and tooltip depending on validity
     * 
     * @param {any} valid 
     * @param {any} target 
     */
    function toggleErrorAndTooltip(valid, target, message) {
        var hasTooltip = target.attr('data-original-title') !== undefined;
        //select2 hides original field 
        if (target.hasClass('select2-hidden-accessible')) {
            target = $('[aria-labelledby="select2-' + target.attr('id') + '-container"]');
        }

        if (!valid) {
            //initialize new tooltip
            if (!hasTooltip) {
                target.addClass('error').attr('title', message).attr('data-toggle', 'tooltip').tooltip();
            }
            //update tooltip
            else {
                target.addClass('error').attr('data-original-title', message).tooltip('enable');
            }

        }
        else if (hasTooltip) {
            target.removeClass('error').tooltip('disable');
        }
        else {
            target.removeClass('error');
        }
    }

    /**
     * Returns the name attribute of the control which is used to validate the current one. 
     * @param {any} field
     */
    function GetVLDA(field) {
        var name = $(field).attr('class').split(' ').filter(function (value) {
            //a class that starts with [vlda-] holds the control name 
            return /^vlda-/.test(value);
        })

        if (name.length > 0) {
            return name[0].slice(5);
        }
    }

    //
    //only members of object public are exposed.
    //expose raw validation functions to allow for use outside the context of validating an entire claim.
    //

    public.isNumber = function (value) {
        return rgxIsNumber.test(value);
    };

    public.isDecimal = function (value) {
        return rgxIsDecimal.test(value);
    };

    public.isAlphaNumeric = function (value) {
        return rgxIsAlphaNumeric.test(value);
    };

    public.isSIN = function (value) {
        return rgxIsSIN.test(value);
    };

    public.isCurrency = function (value) {
        return rgxIsCurrency.test(value);
    };

    public.isEmail = function (value) {
        return rgxIsEmail.test(value);
    };

    public.isISODateFormat = function (value) {
        return rgxIsISODateFormat.test(value);
    };

    public.isAnyChecked = function (target) {
        return isAnyChecked(target);
    };

    public.hasSelected = function (target) {
        return hasSelected(target);
    };

    public.isPostalCodeCAN = function (value) {
        return rgxIsPostalCodeCA.test(value);
    };

    public.isPostalCodeUSA = function (value) {
        return rgxIsPostalCodeUS.test(value);
    };

    public.isPhoneNumber = function (value) {
        return rgxIsPhoneNumber.test(value);
    };

    public.isValidFile = function (file, maxFileSize) {
        return isValidFile(file, maxFileSize);
    };

    public.isValidImage = function (file, maxFileSize) {
        return isValidImage(file, maxFileSize);
    };

    public.groupFilesByValidity = function (files) {
        return GroupFilesByValidity(files);
    };

    public.toggleErrorAndTooltip = function (valid, target, message) {
        return toggleErrorAndTooltip(valid, target, message)
    }

    public.validateSubmission = function (root) {
        return ValidateSubmission(root);
    }

    public.validateAllWithValues = function () {
        return ValidateAllWithValues();
    }

    public.validateAllRequired = function () {
        return ValidateAllRequired();
    }

    public.getVldA = function (field) {
        return GetVLDA(field);
    }

    //this function is passed into the preConfirm member of swal config 
    public.validateSwalContentPM = function () {
        return new Promise(function (resolve, reject) {
            var valid = ValidateSwalContent();
            if (valid) {
                resolve();
            } else {
                reject();
            }
        })
    }

    var empValidHtml = `
<div id="vldPersonalCntact" class="alert alert-danger" role="alert">
  <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span>
  <span class="sr-only">Error:</span>
  Enter at least one personal contact
</div>
`;

    return public;

}())

