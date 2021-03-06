/*
 * Author: Zakant
 * Gets the name of the current medical state of an unit. Unit has to be local to the caller.
 *
 * Arguments:
 * 0: The Unit <OBJECT>
 *
 * ReturnValue:
 * Name of the current medical state of the unit <STRING>
 *
 * Public: Yes
 */
#include "script_component.hpp"

params ["_unit"];

if (!local _unit) exitWith { ERROR("unit is not local"); };

[_unit, GVAR(STATE_MACHINE)] call CBA_statemachine_fnc_getCurrentState
