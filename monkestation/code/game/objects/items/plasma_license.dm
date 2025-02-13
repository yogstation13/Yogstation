/obj/item/card/plasma_license
	name = "License to Murderbone"
	desc = "A charred contract letting the holder kill everyone they meet. Not offically recognized by Nanotrasen."
	icon = 'monkestation/icons/obj/items/plasmalicense.dmi'
	icon_state = "plasmalicense"
	resistance_flags = FIRE_PROOF
	//For the person who signers the contract
	var/datum/mind/owner

/obj/item/card/plasma_license/attack_self(mob/user)
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [src.name]."), span_notice("You show \the [src.name]."))
	add_fingerprint(user)

/obj/item/card/plasma_license/Initialize(mapload)
	. = ..()
	message_admins("A murderbone license has been created.")

/obj/item/card/plasma_license/examine(mob/user)
	. = ..()
	if(owner)
		. += "There is a small signature on the bottom of the contract: \"[owner]\"."
	else
		. += "It appears to be unsigned."

/obj/item/card/plasma_license/attack_self(mob/user)
	if(!owner)
		if(!user.mind)
			return
		to_chat(user, span_notice("You sign your name at the bottom of the [src]."))
		owner = user.mind
		message_admins("A License to Murderbone has been signed by [owner].")
		investigate_log("A License to Murderbone by [key_name(user)]", INVESTIGATE_ATMOS)
		return

	if(user.mind != owner)
		to_chat(user, span_warning("[src] has already been signed!"))
		return

	return ..()
