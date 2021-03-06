#define DEBUG_MODE_FULL
#include "script_component.hpp"

["ace_interactMenuClosed", {[objNull, 0] call FUNC(displayPatientInformation);}] call CBA_fnc_addEventHandler;

//Handle Deleting Bodies and creating litter on Server:
if (isServer) then {
    ["ace_placedInBodyBag", FUNC(serverRemoveBody)] call CBA_fnc_addEventHandler;
};

["ace_unconscious", {
    params ["_unit", "_status"];

    if (local _unit) then {
        if (_status) then {
            _unit setVariable ["tf_voiceVolume", 0, true];
            _unit setVariable ["tf_unable_to_use_radio", true, true];
            _unit setVariable ["acre_sys_core_isDisabled", true, true];
        } else {
            _unit setVariable ["tf_voiceVolume", 1, true];
            _unit setVariable ["tf_unable_to_use_radio", false, true];
            _unit setVariable ["acre_sys_core_isDisabled", false, true];
        };
    };
}] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

[missionNamespace, "ACE_setCustomAimCoef", QUOTE(ADDON), {
    private _pain = [ACE_player] call FUNC(getPainLevel);

    linearConversion [0, 1, _pain, 1, 5, true];
}] call EFUNC(common,arithmeticSetSource);

#ifdef DEBUG_MODE_FULL
    [] call FUNC(dev_watchMedicalStats);

    [{!isNull findDisplay 46}, {
        INFO("Creating Debug Display");
        if (!isNull (uiNamespace getVariable [QGVAR(debugControl), controlNull])) then {
            ctrlDelete (uiNamespace getVariable [QGVAR(debugControl), controlNull]); // cleanup on SP Restart
        };
        private _ctrl = findDisplay 46 ctrlCreate ["RscText", -1];
        _ctrl ctrlSetPosition [
            safeZoneX,
            safeZoneY,
            safeZoneW,
            40 * pixelH
        ];
        _ctrl ctrlSetFontHeight (40 * pixelH);
        _ctrl ctrlSetTextColor [0.6, 0, 0, 1];
        _ctrl ctrlCommit 0;
        uiNamespace setVariable [QGVAR(debugControl), _ctrl];

        [{
            private _playerState = [ACE_player, GVAR(STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState;
            (uiNamespace getVariable [QGVAR(debugControl), controlNull]) ctrlSetText format ["Player state: %1", _playerState];

            if (!isNull cursorTarget && {cursorTarget isKindOf "CAManBase"}) then {
                private _targetState = [cursorTarget, GVAR(STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState;
                drawIcon3D ["", [0.6, 0, 0, 1], cursorTarget modelToWorldVisual (cursorTarget selectionPosition "pelvis"), 0, 0, 0, format ["State: %1", _targetState], 2, 40 * pixelH, "RobotoCondensed"];
            };
        }, 0 ,[]] call CBA_fnc_addPerFrameHandler;
    }, []] call CBA_fnc_waitUntilAndExecute;
#endif
