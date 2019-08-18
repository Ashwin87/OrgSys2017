
/**
 * Converts NULLs in an object's level 1 properties to empty strings
* 
* @param object
*/
function NullsToString(object) {

    var keys = Object.keys(object);
    var altObject = object;

    for (var i = 0; i < keys.length; i++) {
        if (altObject[keys[i]] == null) {
            altObject[keys[i]] == "";
        }
    }

    return altObject;

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