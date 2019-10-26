/obj/machinery/factory/bag_creator
	name = "automated bag creator"
	desc = "A machine that takes creates bags out of thin air!"
	icon_state = "autolathe"

	var/cooldownBase = 300
	var/cooldown = 0

/obj/machinery/factory/bag_creator/attack_hand(mob/living/user)
	if (cooldown < world.time)
		var/turf/ourTurf = get_turf(src)
		new /obj/item/storage/backpack/duffelbag(ourTurf)
		cooldown = world.time + cooldownBase
	else
		to_chat(user, "<span class='warning'>The cooldown is still active! Please wait [(cooldown - world.time) / 10] seconds!</span>")
	..()