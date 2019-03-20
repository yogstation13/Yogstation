/obj/item/clothing/glasses/sunglasses/cheap
	name = "cheap sunglasses"
	desc = "Made in china"
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = 1
	flash_protect = 0
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/gray
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/glasses/threed
	name = "3D glasses"
	desc = "A pair of glasses used to watch films in red-cyan anaglyph 3D."
	icon_state = "threed"
	item_state = "glasses"

/obj/item/clothing/glasses/hypno
	name = "hypno-spectacles"
	desc = "A pair of glasses which claim to have the ability to hypnotize people."
	icon_state = "hypnospecs"
	item_state = "glasses"
	action_button_name = "Activate Hypno-Spectacles"
	var/cooldown = 0

/obj/item/clothing/glasses/hypno/attack_self(mob/user)
	if (user.get_item_by_slot(slot_glasses) != src)
		user << "<span class='alert'>You must be wearing the glasses to ogle.</span>"
		return
	if (cooldown < world.time)
		cooldown = world.time + 600 //1 minute.
		user.visible_message("<span class='warning'>[user] ogles you disconcertingly!</span>", "<span class='notice'>You ogle everyone nearby.</span>")
	else
		var/timeleft = (cooldown - world.time)
		user << "<span class='notice'>The glasses are recharging, you must wait [round(timeleft/10)] seconds before you can ogle again.</span>"