
/* return index of key k using data in techPrefModel */
function keyToIndex (k) {
    console.warn('keyToIndex key:', k)
    for (var i=0; i < techPrefModel.count; i++) {
        if (indexToKey(i) === k) {
            return i;
        }
    }
    // we did not find a suitable ui item
    console.warn('keyToIndex did not find matching index for key', k);
    return -1;
}

/* return key of index i using data in techPrefModel */
function indexToKey (i) {
    return techPrefModel.get(i).key;
}

/* return currently selected key or null if none selected */
function getSelectedKey () {
    var sI = techPrefSelector.selectedIndex;
    var model = techPrefModel.get(sI);
    return model ? model.key : null;
}

/* return key or 'any' if key matches 'lte' or 'umts'
The UI currently does not support umts/lte only
*/
function normalizeKey (k) {
    if (k === 'lte' || k === 'umts') {
        console.warn("normalizeKey saw", k);
        return 'any';
    } else {
        return k;
    }
}

/* handler for when RadioSettings TechnologyPreference changes */
function preferenceChanged (preference) {
    var sI = techPrefSelector.selectedIndex;
    var rdoKey = rdoSettings.technologyPreference;
    var selKey = getSelectedKey();

    // if preference changes, but the user has chosen one already,
    // make sure the user's setting is respected
    if (sI > 0) {
        console.log('overriding RadioSettings TechnologyPreference signal', preference, 'with user selection', selKey);
        rdoSettings.technologyPreference = selKey;
        return;
    }

    // if the pref changes and the modem is on,
    // normlize and update the UI
    if (connMan.powered) {
        sI = keyToIndex(normalizeKey(rdoKey));
    } else {
        // if the modem is off,
        // just normalize
        rdoSettings.technologyPreference = normalizeKey(rdoKey);
    }
    console.log('modem', connMan.powered ? 'online' : 'offline', 'TechnologyPreference', rdoKey);
}

/* handler for when ConnectionManager powered changes */
function poweredChanged (powered) {
    var rdoKey = rdoSettings.technologyPreference;
    if (powered) {
        if (rdoKey === '') {
            console.warn('modem came online but TechnologyPreference is empty');
            return;
        } else {
            console.log('modem came online, TechnologyPreference', rdoKey);
            techPrefSelector.selectedIndex = keyToIndex(normalizeKey(rdoKey));
        }
    } else {
        console.log('modem went offline');
        techPrefSelector.selectedIndex = 0;
    }
}

/* handler for when user clicks the TechnologyPreference item selector */
function delegateClicked (index) {
    // if the user selects a TechnologyPreference, update RadioSettings
    if (index > 0) {
        rdoSettings.technologyPreference = indexToKey(index);
    }
}
