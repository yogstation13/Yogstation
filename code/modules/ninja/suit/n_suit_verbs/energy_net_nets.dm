/*
It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
It is possible to destroy the net by the occupant or someone else.
*/

/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = TRUE//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = MOUSE_OPACITY_ICON//So you can hit it with stuff.
	anchored = TRUE//Can't drag/grab the net.
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 40 //How much health it has.
	can_buckle = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	var/mob/living/carbon/affecting//Who it is currently affecting, if anyone.
	var/mob/living/carbon/master//Who shot web. Will let this person know if the net was successful or failed.
	var/check = 15 //30 seconds before teleportation. Could be extended I guess.

/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/slash.ogg', 80, 1)
		if(BURN)
			playsound(src, 'sound/weapons/slash.ogg', 80, 1)

/obj/structure/energy_net/Destroy()
	if(!success)
		if(!QDELETED(affecting))
			affecting.visible_message("[affecting.name] was recovered from the energy net!", "You were recovered from the energy net!", span_italics("You hear a grunt."))
	return ..()

/obj/structure/energy_net/process()
	if(QDELETED(affecting)||affecting.loc!=loc)
		qdel(src)//Get rid of the net.
		return

	if(check>0)
		check--
		return

	qdel(src)

/obj/structure/energy_net/attack_paw(mob/user)
	return attack_hand()

/obj/structure/energy_net/user_buckle_mob(mob/living/M, mob/living/user)
	return//We only want our target to be buckled

/obj/structure/energy_net/user_unbuckle_mob(mob/living/buckled_mob, mob/living/user)
	return//The net must be destroyed to free the target
