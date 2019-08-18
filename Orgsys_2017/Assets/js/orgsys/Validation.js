var validate = (function () {

    var public = {};
    var rgxIsNumber = /^[0-9]+$/;
    var rgxIsISODateFormat = /^[0-9]{4}-[0-9]{2}-[0-9]{2}/;
    var rgxIsCurrency = /^\d+\.\d{2}$/;
    var rgxIsEmail = /^([a-zA-Z0-9\-\.]+)@([a-zA-Z0-9\-\.]+)\.([a-zA-Z]{1,10})$/;
    var rgxIsText = /rgx/;
    var rgxIsSIN = /^[0-9]{9}$/;
    var rgxIsPostalCodeCA = /^[a-zA-Z0-9]{3}[\s]*[a-zA-Z0-9]{3}$/;
    var rgxIsPostalCodeUS = /^[0-9]{5}$|^[0-9]{5}-[0-9]{4}$/;
    var rgxIsPhoneNumber = /^[0-9]{10}$/;
    var rgxIsAllowedExt = /\.(doc|docx|txt|pdf)$/;

    var binaryBytesInMB = 1048576;
    var standardMaxFileSize = 4 * binaryBytesInMB;

    //these messages will appear as tooltips when hovering over a field that has an error
    var isRequiredMessage = 'Required';
    var isNumberMessage = 'Must be a number';
    var isEmailMessage = 'Emails must be in the format x@x.x e.g. jsmith@mail.com';
    var isSINMessage = 'Must be a number consisting of 9 digits';
    var isPhoneNumberMessage = 'Phone numbers must consist of 10 digits';    
    
    var isPostalCodeMessageArray = [
        { countryCode : 'US', rgx : rgxIsPostalCodeUS, message : 'Postal Code must consist of digits and be in the format XXXXX or XXXXX-XXXX' },
        { countryCode : 'CA', rgx : rgxIsPostalCodeCA, message : 'Postal Code must consist of 6 alphanumeric characters e.g. 123 XYZ' }
    ]

    //only members of object public are exposed to the client
    public.isNumber = function (value) {
        return rgxIsNumber.test(value);
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

    public.groupFilesByValidity = function (files) {
        return GroupFilesByValidity(files);
    };
    
    public.validateAll = function () {
        return ValidateAll();
    }

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
     * Validates all common controls, append / removes error class where appropriate
     */
    function ValidateAll() {

        //returns a reprt
        var report = {
            valid: false,
            errors: []
        }
        console.log('validating all')

        //ensure required controls have a value, excluding groups of control in divs
        $('.required').not('div').each(function () {
            var valid = $(this).val() != '';
            toggleErrorAndTooltip(valid, $(this), isRequiredMessage);

            if (!valid) report.errors.push($(this));
        });

        //ensure option selected is not the prompt on required select controls
        $('select.required').each(function () {
            var valid = hasSelected($(this));
            toggleErrorAndTooltip(valid, $(this), isRequiredMessage);

            if (!valid) report.errors.push($(this));
        });

        $('.regexNumbers, .number').each(function () {
            if ($(this).val() != '') {
                var valid = public.isNumber($(this).val());
                toggleErrorAndTooltip(valid, $(this), isNumberMessage);

                if (!valid) report.errors.push($(this));
            }
        });

        $('.sin').each(function () {
            if ($(this).val() != '') {
                var valid = public.isSIN($(this).val());
                toggleErrorAndTooltip(valid, $(this), isSINMessage);

                if (!valid) report.errors.push($(this));
            }
        });

        $('.regexCurrency').each(function () {
            if ($(this).val() != '') {
                var valid = public.isCurrency($(this).val());
                toggleErrorAndTooltip(valid, $(this));

                if (!valid) report.errors.push($(this));
            }
        });

        $('.email').each(function () {
            if ($(this).val() != '') {
                var valid = public.isEmail($(this).val());
                toggleErrorAndTooltip(valid, $(this), isEmailMessage);

                if (!valid) report.errors.push($(this));
            }
        });

        $('.postalcode').each(function () {
            if ($(this).val() != '') {

                //validation is based on selected country; would like this field to be more specific /abovtenko
                var country = $('[name="Country"]').first();
                var countryIdx = country.prop('selectedIndex');
                var countryCode = country.find('option').eq(countryIdx).val();

                //cannot validate unless a country is selected
                if (countryIdx > 0) {

                    var validationObject = isPostalCodeMessageArray.filter(function (p) {
                        return p.countryCode == countryCode;
                    })[0];

                    var valid = validationObject.rgx.test($(this).val());
                    toggleErrorAndTooltip(valid, $(this), validationObject.message);

                    if (!valid) report.errors.push($(this));

                }
            }
        });

        $('.phone').each(function () {
            if ($(this).val() != '') {
                var valid = public.isPhoneNumber($(this).val());
                toggleErrorAndTooltip(valid, $(this), isPhoneNumberMessage);

                if (!valid) report.errors.push($(this));
            }
        });

        $('.check-group.required').each(function () {
            var valid = isAnyChecked($(this));
            toggleErrorAndTooltip(valid, $(this), isRequiredMessage);

            if (!valid) report.errors.push($(this));
        });

        if (report.errors.length == 0) {
            report.valid = true;
        }

        return report;

    }

    /**
     * Iterates over an input:file element's files property and returns an object containing two file arrays, valid and invalid
     * in order to show the user which files uploaded successfully and which didn't
     * @param {any} files
     */
    function GroupFilesByValidity(files) {

        var invalidFiles = [];
        var validFiles = [];
        //var files = $('#' + fieldID).prop('files');

        for (var i = 0; i < files.length; i++) {

            if (isValidFile(files[i])) {
                validFiles.push(files[i]);
            } else {
                invalidFiles.push(files[i]);
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
        var target = $(target);

        if (!valid) {
            //initialize new tooltip
            if (target.attr('data-original-title') === undefined) {
                target.addClass('error').attr('title', message).attr('data-toggle', 'tooltip').tooltip();
            }
            //update tooltip
            else {
                target.addClass('error').attr('data-original-title', message).tooltip('enable');
            }
            
        }
        else {
            target.removeClass('error').tooltip('disable');
        }
    }


    return public;

}())

