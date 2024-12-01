//Storm Anomaly (Lightning)
//LORD OF LIGHTNING SHIFTS HIS GAZE
#define STORM_MIN_RANGE 2
#define STORM_MAX_RANGE 5
#define STORM_POWER_LEVEL 1500

/obj/effect/anomaly/storm
	name = "Storm Anomaly"
	desc = "The lord of lightning peeks through the veil."
	icon_state = "flux"
	color = "#fbff00"
	lifespan = 30 SECONDS //Way too strong to give a full 99 seconds.
	var/active = TRUE

//POINTS HIS STRUM FINGER OUR WAY
/obj/effect/anomaly/storm/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/storm/Destroy()
	. = ..()
	RemoveElement(/datum/element/connect_loc)

//ELECTRICITY ESCAPES
/obj/effect/anomaly/storm/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

	if(active && iscarbon(atom_movable))
		var/mob/living/carbon/target = atom_movable
		active = FALSE
		target.electrocute_act(23, "[name]", flags = SHOCK_NOGLOVES)
		target.adjustFireLoss(10)

//LEAVES DESTRUCTION IN HIS WAKE
/obj/effect/anomaly/storm/anomalyEffect(seconds_per_tick)
	..()
	if(!active) //Only works every other tick
		active = TRUE
		return
	active = FALSE

	tesla_zap(src, rand(STORM_MIN_RANGE, STORM_MAX_RANGE), STORM_POWER_LEVEL)
	playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE)

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	var/turf/location = get_turf(src)
	location.atmos_spawn_air("water_vapor=10;TEMP=350")

//No detonation because it's strong enough as it is


#undef STORM_MIN_RANGE
#undef STORM_MAX_RANGE
#undef STORM_POWER_LEVEL
