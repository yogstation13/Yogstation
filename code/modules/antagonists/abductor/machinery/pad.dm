/obj/machinery/abductor/pad
	name = "Alien Telepad"
	desc = "Use this to transport to and from the humans' habitat."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	var/turf/teleport_target
	var/obj/machinery/abductor/console/console

/obj/machinery/abductor/pad/Destroy()
	if(console)
		console.pad = null
		console = null
	return ..()

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	if(!target.buckled)
		target.forceMove(get_turf(src))

/obj/machinery/abductor/pad/proc/Send()
	if(teleport_target == null)
		teleport_target = GLOB.teleportlocs[pick(GLOB.teleportlocs)]
	flick("alien-pad", src)
// Monkestation Edit Start
	for(var/atom/movable/target in loc)
		if(isliving(target) || istype(target, /obj/item/toy/plush))
			target.forceMove(teleport_target)
			new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
			if(isliving(target))
				var/mob/living/abductedTarget = target
				to_chat(abductedTarget, span_warning("The instability of the warp leaves you disoriented!"))
				abductedTarget.Stun(60)
// Monkestation Edit End

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	flick("alien-pad", src)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
	Warp(target)

/obj/machinery/abductor/pad/proc/doMobToLoc(place, atom/movable/target)
	flick("alien-pad", src)
	target.forceMove(place)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)

/obj/machinery/abductor/pad/proc/MobToLoc(place,mob/living/target)
	new /obj/effect/temp_visual/teleport_abductor(place)
	addtimer(CALLBACK(src, PROC_REF(doMobToLoc), place, target), 80)

/obj/machinery/abductor/pad/proc/doPadToLoc(place)  
	flick("alien-pad", src)
// Monkestation Edit Start
	for(var/atom/movable/target in get_turf(src))
		if(isliving(target) || istype(target, /obj/item/toy/plush))
			target.forceMove(place)
			new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)
// Monkestation Edit End

/obj/machinery/abductor/pad/proc/PadToLoc(place)
	new /obj/effect/temp_visual/teleport_abductor(place)
	addtimer(CALLBACK(src, PROC_REF(doPadToLoc), place), 80)

/obj/effect/temp_visual/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
	duration = 80

/obj/effect/temp_visual/teleport_abductor/Initialize(mapload)
	. = ..()
	var/datum/effect_system/spark_spread/S = new
	S.set_up(10,0,loc)
	S.start()
