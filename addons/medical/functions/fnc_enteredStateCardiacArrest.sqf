/*
 * Author: BaerMitUmlaut
 * Handles a unit entering cardiac arrest.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit"];

private _time = GVAR(cardiacArrestTime);
_time = _time + random [_time*-0.1, 0, _time*0.1];

_unit setVariable [QGVAR(cardiacArrestTime), _time];
_unit setVariable [QGVAR(cardiacArrestStart), CBA_missionTime];

[_unit] call FUNC(setCardiacArrest);
