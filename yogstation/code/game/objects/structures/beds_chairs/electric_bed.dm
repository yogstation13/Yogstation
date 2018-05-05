/obj/structure/bed/roller/e_roller
	name = "electric roller bed"
	icon = 'yogstation/icons/obj/erollerbed.dmi'
	icon_state = "down"
	var/obj/item/assembly/shock_kit/part = null
	var/last_time = 1
	var/mutable_appearance/cables

/obj/structure/bed/roller/e_roller/post_buckle_mob(mob/living/M)
	..()
	cables = mutable_appearance('yogstation/icons/obj/erollerbed.dmi', "up_cables", MOB_LAYER + 1)
	add_overlay(cables)

/obj/structure/bed/roller/e_roller/post_unbuckle_mob(mob/living/M)
	..()
	cut_overlay(cables)

/obj/structure/bed/roller/e_roller/proc/shock()
	if(last_time + 50 > world.time)
		return
	last_time = world.time

	// special power handling
	var/area/A = get_area(src)
	if(!isarea(A))
		return
	if(!A.powered(EQUIP))
		return
	A.use_power(EQUIP, 5000)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(12, 1, src)
	s.start()
	if(has_buckled_mobs())
		flick("electrocute", src)
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.electrocute_act(85, src, 1)
			to_chat(buckled_mob, "<span class='userdanger'>You feel a deep shock course through your body!</span>")
			addtimer(CALLBACK(buckled_mob, /mob/living.proc/electrocute_act, 85, src, 1), 1)
		addtimer(CALLBACK(src, /obj/structure/bed/roller/e_roller.proc/correct_mobs), 2)
	visible_message("<span class='danger'>The electric roller bed went off!</span>", "<span class='italics'>You hear a deep sharp shock!</span>")

/obj/structure/bed/roller/e_roller/proc/correct_mobs()
	for(var/M in buckled_mobs)
		var/mob/living/buckled_mob = M
		buckled_mob.pixel_y = initial(buckled_mob.pixel_y)

/obj/structure/bed/roller/e_roller/MouseDrop()
	return

/obj/structure/bed/roller/e_roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(loc)
		W.play_tool_sound(src)
		part.forceMove(loc)
		part.master = null
		part = null
		qdel(src)

/obj/structure/bed/roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/shock_kit))
		if(!user.temporarilyRemoveItemFromInventory(W))
			return
		var/obj/item/assembly/shock_kit/SK = W
		var/obj/structure/bed/roller/e_roller/E = new /obj/structure/bed/roller/e_roller(src.loc)
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
		E.part = SK
		SK.forceMove(E)
		SK.master = E
		qdel(src)
	else
		return ..()
