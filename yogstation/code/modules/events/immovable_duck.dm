/datum/round_event_control/immovable_rod/duck
	name = "Immovable Duck"
	typepath = /datum/round_event/immovable_rod/duck
	weight = 2
	max_occurrences = 3

/datum/round_event_control/immovable_rod/duck/admin_setup()
	if(!check_rights(R_FUN))
		return

	var/aimed = alert("Aimed at current location?","SniperQUACK", "Yes", "No")
	if(aimed == "Yes")
		special_target = get_turf(usr)

/datum/round_event/immovable_rod/duck/announce(fake)
	priority_announce("What the duck was that?!", "General Alert")

/datum/round_event/immovable_rod/duck/start()
	var/datum/round_event_control/immovable_rod/duck/C = control
	var/startside = pick(GLOB.cardinals)
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/turf/startT = spaceDebrisStartLoc(startside, z)
	var/turf/endT = spaceDebrisFinishLoc(startside, z)
	new /obj/effect/immovablerod/duck(startT, endT, C.special_target)

/obj/effect/immovablerod/duck
	name = "immovable DUCK"
	desc = "What the duck is that?"
	icon = 'yogstation/icons/obj/objects.dmi'
	icon_state = "immquack"

/obj/effect/immovablerod/duck/Initialize()
	. = ..()
	SpinAnimation(24,-1)


/obj/effect/immovablerod/duck/Bump(atom/clong)
	if(prob(90))
		playsound(src, 'yogstation/sound/misc/quack.ogg', 50, 1)
		if(prob(50))
			audible_message(span_danger("You hear a QUACK!"))

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if(special_target && clong == special_target)
		complete_trajectory()

	if(isturf(clong) || isobj(clong))
		if(clong.density)
			clong.ex_act(EXPLODE_HEAVY)

	else if(isliving(clong))
		penetrate(clong)
	else if(istype(clong, type))
		var/obj/effect/immovablerod/other = clong
		visible_message("<span class='danger'>[src] collides with [other]!\
			</span>")
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(2, get_turf(src))
		smoke.start()
		qdel(src)
		qdel(other)

/obj/effect/immovablerod/duck/penetrate(mob/living/L)
	L.visible_message(span_danger("[L] is QUACKED by an immovable duck!") , span_userdanger("You get QUACKED!!!") , "<span class ='danger'>You hear a QUACK!</span>")
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.adjustBruteLoss(160)
	if(L && (L.density || prob(10)))
		L.ex_act(EXPLODE_HEAVY)
