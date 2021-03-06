/*
 * Author: Glowbal
 * Local callback for checking the pulse of a patient
 *
 * Arguments:
 * 0: The medic <OBJECT>
 * 1: The patient <OBJECT>
 * 2: Body part <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_caller", "_target", "_bodyPart"];

private _heartRate = 0;

if (alive _target && !([_target, _bodyPart] call EFUNC(medical,hasTourniquetAppliedTo))) then {
    _heartRate = _target getVariable [QEGVAR(medical,heartRate), 80];
};

private _heartRateOutput = ELSTRING(medical,Check_Pulse_Output_5);
private _logOutPut = ELSTRING(medical,Check_Pulse_None);

if (_heartRate > 1.0) then {
    if (_caller call EFUNC(medical,isMedic)) then {
        _heartRateOutput = ELSTRING(medical,Check_Pulse_Output_1);
        _logOutPut = format ["%1", round(_heartRate)];
    } else {
        // non medical personel will only find a pulse/HR
        _heartRateOutput = ELSTRING(medical,Check_Pulse_Output_2);
        _logOutPut = ELSTRING(medical,Check_Pulse_Weak);

        if (_heartRate > 60) then {
            if (_heartRate > 100) then {
                _heartRateOutput = ELSTRING(medical,Check_Pulse_Output_3);
                _logOutPut = ELSTRING(medical,Check_Pulse_Strong);
            } else {
                _heartRateOutput = ELSTRING(medical,Check_Pulse_Output_4);
                _logOutPut = ELSTRING(medical,Check_Pulse_Normal);
            };
        };
    };
};

[QEGVAR(common,displayTextStructured), [[_heartRateOutput, _target call EFUNC(common,getName), round _heartRate], 1.5, _caller], _caller] call CBA_fnc_targetEvent;

if (_logOutPut != "") then {
    [_target, "activity", ELSTRING(medical,Check_Pulse_Log), [_caller call EFUNC(common,getName), _logOutPut]] call FUNC(addToLog);
    [_target, "quick_view", ELSTRING(medical,Check_Pulse_Log), [_caller call EFUNC(common,getName), _logOutPut]] call FUNC(addToLog);
};
