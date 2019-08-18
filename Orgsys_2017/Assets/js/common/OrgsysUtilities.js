
/**
 * A wrapper that calls ReplaceJSONValuesByValue to replace default and/or null values with an empty string.
 * @param {any} json
 */
function ReplaceDFValues(json) {
    return ReplaceJSONValuesByValue(json, ['1900-01-01', '1900-01-01T00:00:00', null], '');
}

/**
 * Replace specific values in json array or object with another value
* 
* @param json
* @param replaceThis A string or array of strings
*/
function ReplaceJSONValuesByValue(json, replaceThis, replaceWith) {

    var targets = (typeof replaceThis == 'string') ? [replaceThis] : replaceThis ;
    var replaceObjectValues = function (object) {

        var keys = Object.keys(object);
        var newObject = object;

        for (var i = 0; i < keys.length; i++) {
            if (replaceThis.indexOf(newObject[keys[i]]) != -1) {
                newObject[keys[i]] = replaceWith;
            }
        }

        return newObject;
    }

    if ($.isArray(json)) {
        var newArray = []
        //for each object in the array
        for (var i = 0; i < json.length; i++) {
            newArray.push(replaceObjectValues(json[i]))
        }

        return newArray;
    }
    else {
        return replaceObjectValues(json)
    }

}

/**
 * Groups the objects in an array by a property of the object. 
 * 
 * Returns an array of objects, where each object is a group.
 * 
 * @param objectArray
 * @param property
 */
function GroupByProperty(objectArray, property) {

    return objectArray.reduce(function (accumulator, object) {

        var key = object[property];
        //determine if an object for the group already exists
        var hasGroup = accumulator.some(function (group) {
            return group.groupId == key;
        });

        //if not, add object for the group
        if (!hasGroup) {

            accumulator.push({
                groupId: key,
                data: []
            });

        }

        //push the current object to its relevant group's data property
        accumulator = accumulator.map(function (group) {

            if (group.groupId == key) {
                group.data.push(object);
            }

            return group;

        });

        return accumulator;

    }, []);

}  

/**
 * Selects css classes of an element that match a specified pattern
 * @param {any} css
 * @param {any} fragment
 */
function SelectCssClassLike(css, fragment) {
    var ar = [];
    var rgx = new RegExp(fragment);

    if (css.length > 0) {

        ar = css.split(' ').filter(function (iClass) {
            return rgx.test(iClass);
        });
    }

    return ar;

}
