#include "script_component.hpp"

[QEGVAR(medical,initialized), FUNC(checkItems)] call CBA_fnc_addEventHandler;
["loadout", FUNC(checkItems)] call CBA_fnc_addPlayerEventHandler;


if (isServer) then {
    [QGVAR(createLitterServer), FUNC(litterHandleCreate)] call CBA_fnc_addEventHandler;
};

// treatment events
[QGVAR(treatmentBandageLocal), FUNC(treatmentBandageLocal)] call CBA_fnc_addEventHandler;
[QGVAR(treatmentTourniquetLocal), FUNC(treatmentTourniquetLocal)] call CBA_fnc_addEventHandler;
[QGVAR(treatmentMedicationLocal), FUNC(treatmentMedicationLocal)] call CBA_fnc_addEventHandler;
[QGVAR(treatmentIVLocal), FUNC(treatmentIVLocal)] call CBA_fnc_addEventHandler;
[QGVAR(treatmentCPRLocal), FUNC(treatmentCPRLocal)] call CBA_fnc_addEventHandler;
[QGVAR(treatmentPartialHealLocal), FUNC(treatmentPartialHealLocal)] call CBA_fnc_addEventHandler;
[QGVAR(treatmentFullHealLocal), FUNC(treatmentFullHealLocal)] call CBA_fnc_addEventHandler;

// action events
[QGVAR(actionCheckPulseLocal), FUNC(actionCheckPulseLocal)] call CBA_fnc_addEventHandler;
[QGVAR(actionCheckBloodPressureLocal), FUNC(actionCheckBloodPressureLocal)] call CBA_fnc_addEventHandler;
[QGVAR(actionPlaceInBodyBag), FUNC(actionPlaceInBodyBag)] call CBA_fnc_addEventHandler;
