//radioactive anomaly, creates radioactive goo
/obj/effect/anomaly/radioactive
	name = "Radioactive Anomaly"
	icon_state = "shield-grey"
	desc = "A highly unstable mass of charged particles leaving waste material in it's wake."
	color = "#86c4dd"
	var/active = TRUE

/obj/effect/anomaly/radioactive/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/radioactive/Destroy()
	. = ..()
	RemoveElement(/datum/element/connect_loc)

/obj/effect/anomaly/radioactive/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	if(active && isliving(atom_movable))
		var/mob/living/victim = atom_movable
		active = FALSE
		victim.Paralyze(1 SECONDS)
		var/atom/target = get_edge_target_turf(victim, get_dir(src, get_step_away(victim, src)))
		victim.throw_at(target, 3, 1)
		radiation_pulse(victim, 100)
		to_chat(victim, "<span class='danger'>You feel a disgusting wave of heat wash over you!!!</span>")

/obj/effect/anomaly/radioactive/anomalyEffect(seconds_per_tick)
	..()
	active = TRUE

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	radiation_pulse(src, 50)
	if(!locate(/obj/effect/decal/nuclear_waste) in src.loc)
		playsound(src, pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg'), vol = 50, vary = 1)
		new /obj/effect/decal/nuclear_waste(src.loc)
		if(prob(15))
			new /obj/effect/decal/nuclear_waste/epicenter(src.loc)

/obj/effect/anomaly/radioactive/detonate()
	playsound(src, 'sound/effects/empulse.ogg', vol = 100, vary = 1)
	radiation_pulse(src, 1000)
