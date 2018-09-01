//the telebeacon used by the spythieves to teleport shit in/out of ss13
/obj/item/telebeacon
	name = "\improper Tele-Beacon"
	desc = "A beacon used by a teleporter"
	icon = 'yogstation/icons/obj/radio.dmi'
	icon_state = "syndiebeacon"
	var/datum/effect_system/spark_spread/spark_system

/obj/item/telebeacon/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)

/obj/item/telebeacon/attack_self(mob/user)
	if(!user.mind || !user.mind.has_antag_datum(/datum/antagonist/spythief))
		return

	return // todo: make this show all the available bounties

/obj/item/telebeacon/attackby(obj/item/I, mob/user, params)
	check_complete(I, user)
	return TRUE

/obj/item/telebeacon/afterattack(atom/target, mob/user, proximity)
	if(proximity > 1)
		return
	check_complete(target, user)

/obj/item/telebeacon/proc/check_complete(atom/target, mob/user)
	if(!user.mind || !user.mind.has_antag_datum(/datum/antagonist/spythief))
		return

	for(var/datum/spythief_bounty/bounty in SSticker.mode.spythief_bounties)
		if(!bounty.check_complete(target, user)) //does the target match any known bounty? If it doesn't, continue on
			continue

		to_chat(user, "<span class='notice'>Initiating transport, please stay still.</span>") //should probably come up with a better way to word this.

		if(!do_after(user, 50, target = src)) //stand still while it tries to "teleport" the bounty out
			break

		spark_system.start()
		qdel(target)
		bounty.complete(user)
		return