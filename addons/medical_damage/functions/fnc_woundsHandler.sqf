/*
 * Author: Glowbal, commy2
 * Handling of the open wounds & injuries upon the handleDamage eventhandler.
 *
 * Arguments:
 * 0: Unit That Was Hit <OBJECT>
 * 1: Name Of Body Part <STRING>
 * 2: Amount Of Damage <NUMBER>
 * 3: Type of the damage done <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */
#include "script_component.hpp"

params ["_unit", "_bodyPart", "_damage", "_typeOfDamage"];
TRACE_5("start",_unit,_bodyPart,_damage,_typeOfDamage);

if (_typeOfDamage isEqualTo "") then {
    _typeOfDamage = "unknown";
};

// Administration for open wounds and ids
private _openWounds = _unit getVariable [QEGVAR(medical,openWounds), []];
private _woundID = _unit getVariable [QGVAR(lastUniqueWoundID), 1];  // Unique wound ids are not used anywhere: ToDo Remove from openWounds array

TRACE_4("extension call",_bodyPart,_damage,_typeOfDamage,_woundID);
private _extensionOutput = "ace_medical" callExtension format ["HandleDamageWounds,%1,%2,%3,%4", _bodyPart, _damage, _typeOfDamage, _woundID];
TRACE_1("",_extensionOutput);

// these are default values and modified by _extensionOutput
private _painToAdd = 0;
private _woundsCreated = [];

call compile _extensionOutput;

// todo: Make the pain and bleeding calculations part of the extension again
private _woundDamage = _damage / ((count _woundsCreated) max 1); // If the damage creates multiple wounds
private _painLevel = 0;
private _critialDamage = false;
private _bodyPartDamage = _unit getVariable [QEGVAR(medical,bodyPartDamage), [0,0,0,0,0,0]];
{
    _x params ["", "_woundClassIDToAdd", "_bodyPartNToAdd", "", "_bleeding"];

    _bodyPartDamage set [_bodyPartNToAdd, (_bodyPartDamage select _bodyPartNToAdd) + _woundDamage];

    // The higher the nastiness likelihood the higher the change to get a painful and bloody wound
    private _nastinessLikelihood = linearConversion [0, 20, _woundDamage, 0.5, 30, true];
    private _bleedingModifier = 0.25 + 8 * exp ((random [-4.5, -5, -6]) / _nastinessLikelihood);
    private _painModifier = 0.05 + 2 * exp (-2 / _nastinessLikelihood);

    TRACE_3("",_nastinessLikelihood,_bleedingModifier,_painModifier);

    _bleeding = _bleeding * _bleedingModifier;
    private _pain = (((GVAR(woundsData) select _woundClassIDToAdd) select 3) * _painModifier);
    _painLevel = _painLevel + _pain;

    // wound category (minor [0..0.5], medium[0.5..1.0], large[1.0+])
    private _category = floor linearConversion [0, 1, _bleedingModifier, 0, 2, true];

    _x set [4, _bleeding];
    _x set [5, _woundDamage];
    _x set [6, _category];


    if (_bodyPartNToAdd == 0 || {_bodyPartNToAdd == 1 && {_woundDamage > PENETRATION_THRESHOLD}}) then {
        _critialDamage = true;
    };
#ifdef DEBUG_MODE_FULL
    systemChat format["%1, damage: %2, peneration: %3, bleeding: %4, pain: %5", _bodyPart, round(_woundDamage * 100) / 100, _woundDamage > PENETRATION_THRESHOLD, round(_bleeding * 1000) / 1000, round(_pain * 1000) / 1000];
#endif

    if (_bodyPartNToAdd == 0 && {_woundDamage > LETHAL_HEAD_DAMAGE_THRESHOLD}) then {
        [QEGVAR(medical,FatalInjury), _unit] call CBA_fnc_localEvent;
    };

    // todo `forceWalk` based on leg damage
    private _causeLimping = (GVAR(woundsData) select _woundClassIDToAdd) select 7;
    if (_causeLimping == 1 && {_woundDamage > LIMPING_DAMAGE_THRESHOLD} && {_bodyPartNToAdd > 3}) then {
        [_unit, true] call EFUNC(medical_engine,setLimping);
    };

    // if possible merge into existing wounds
    private _createNewWound = true;
    {
        _x params ["", "_classID", "_bodyPartN", "_oldAmountOf", "_oldBleeding", "_oldDamage", "_oldCategory"];
        if (_woundClassIDToAdd == _classID && {_bodyPartNToAdd == _bodyPartN && {(_woundDamage < PENETRATION_THRESHOLD) isEqualTo (_oldDamage < PENETRATION_THRESHOLD)}}) then {
            if (_oldCategory == _category) exitWith {
                private _newAmountOf = _oldAmountOf + 1;
                _x set [3, _newAmountOf];
                private _newBleeding = (_oldAmountOf * _oldBleeding + _bleeding) / _newAmountOf;
                _x set [4, _newBleeding];
                private _newDamage = (_oldAmountOf * _oldDamage + _woundDamage) / _newAmountOf;
                _x set [5, _newDamage];
                _createNewWound = false;
            };
        };
    } forEach _openWounds;

    if (_createNewWound) then {
        _openWounds pushBack _x;
    };
} forEach _woundsCreated;

_unit setVariable [QEGVAR(medical,openWounds), _openWounds, true];
_unit setVariable [QEGVAR(medical,bodyPartDamage), _bodyPartDamage, true];

[_unit, _bodyPart] call EFUNC(medical_engine,updateBodyPartVisuals);
[_unit, _painLevel] call EFUNC(medical,adjustPainLevel);
[_unit, "hit", PAIN_TO_SCREAM(_painLevel)] call EFUNC(medical_engine,playInjuredSound);

if (_critialDamage || {_painLevel > PAIN_UNCONSCIOUS}) then {
    [_unit] call EFUNC(medical,handleIncapacitation);
};

TRACE_5("exit",_unit,_painLevel,_unit getVariable QEGVAR(medical,pain),_unit getVariable QEGVAR(medical,openWounds),_woundsCreated);
