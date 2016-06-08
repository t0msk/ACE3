/*
 * Author: commy2
 * Adjust the grenades throwing direction and speed to the selected throwing mode. Called from the unified fired EH only for CAManBase
 *
 * Arguments:
 * None. Parameters inherited from EFUNC(common,firedEH)
 *
 * Return Value:
 * None
 *
 * Example:
 * [clientFiredBIS-XEH] call ace_grenades_fnc_throwGrenade
 *
 * Public: No
 */
#include "script_component.hpp"

//IGNORE_PRIVATE_WARNING ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle", "_gunner", "_turret"];
TRACE_10("firedEH:",_unit, _weapon, _muzzle, _mode, _ammo, _magazine, _projectile, _vehicle, _gunner, _turret);

if (_weapon != "Throw") exitWith {};

// http://feedback.arma3.com/view.php?id=12340
if (isNull _projectile) then {
    _projectile = nearestObject [_unit, _ammo];
};

private _config = configFile >> "CfgAmmo" >> _ammo;

// handle special grenades and sounds
if (local _unit) then {
    // handle priming sound, if not IR grenade
    if (_ammo isKindOf "GrenadeHand") then {
        private _posASLProjectile = getPosASL _projectile;
        
        switch (true) do {
            case (_ammo isKindOf "Chemlight_base"): {
                playSound3D ["A3\sounds_f\weapons\Other\dry4.wss", objNull, false, _posASLProjectile, 3, 2, 10]
            };
            case (_ammo isKindOf "ACE_G_Handflare_White"): {
                playSound3D ["A3\sounds_f\weapons\smokeshell\smoke_1.wss", objNull, false, _posASLProjectile, 0.4, 1, 10]
            };
            default {
                playSound3D ["A3\sounds_f\weapons\grenades\Grenade_PullPin.wss", objNull, false, _posASLProjectile, 1.5, 1, 10]
            };
        };
    };

    if (getNumber (_config >> QGVAR(flashbang)) == 1) then {
        private _fuzeTime = getNumber (_config >> "explosionTime");

        [FUNC(flashbangThrownFuze), [_projectile], _fuzeTime] call CBA_fnc_waitAndExecute;
    };
};

if (getNumber (_config >> QGVAR(flare)) == 1) then {
    private _fuzeTime = getNumber (_config >> "explosionTime");
    private _timeToLive = getNumber (_config >> "timeToLive");
    private _color = getArray (_config >> QGVAR(color));
    private _intensity = _color deleteAt 3;

    [FUNC(flare), [_projectile, _color, _intensity, _timeToLive], _fuzeTime, 0] call CBA_fnc_waitAndExecute;
};

// handle throw modes
if (_unit != ACE_player) exitWith {};

private _mode = missionNamespace getVariable [QGVAR(currentThrowMode), 0];

if (_mode != 0) then {
    private _velocity = velocity _projectile;

    switch (_mode) do {
        //high throw
        case 1 : {
            _velocity = [
            0.5 * (_velocity select 0),
            0.5 * (_velocity select 1),
            [0, 0, 0] distance (_velocity vectorMultiply 0.5)
            ];
        };
        //precise throw
        case 2 : {
            _velocity = (_unit weaponDirection _weapon) vectorMultiply (vectorMagnitude _velocity);
        };
        //roll grande
        case 3 : {
            //@todo
        };
        //drop grenade
        case 4 : {
            _velocity = [0, 0, 0];
        };
    };

    _projectile setVelocity _velocity;
};
