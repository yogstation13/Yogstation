/obj/machinery/factory/bag_creator
	name = "automated bag creator"
	desc = "A machine that takes creates bags out of thin air!"
	icon_state = "autolathe"

	var/cooldownBase = 300
	var/cooldown = 0

/obj/machinery/factory/bag_creator/attackby(obj/item/I, mob/user, params)
	if (cooldown < world.time)
		new /obj/item/storage/backpack/duffelbag(src)
		cooldown = world.time + cooldownBase
	else
		to_chat(user, "<span class='warning'>The cooldown is still active! Please wait [cooldown / 10] seconds!</span>")
	..()