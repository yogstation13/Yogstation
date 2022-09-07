 //Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version


/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like its smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 100, ACID = 75)
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10
	item_flags = NONE


/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charge\s left in this suit.")


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "purple envirosuit helmet"
	desc = "A generic purple envirohelm of Nanotrasen design. This updated model comes with a built-in lamp."
	icon_state = "purple_envirohelm"
	item_state = "purple_envirohelm"
	strip_delay = 80
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 100, ACID = 75)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/brightness_on = 4 //luminosity when the light is on
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	flash_protect = 0

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	toggle_helmet_light(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_helmet_light(mob/user)
	on = !on
	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head()
	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security envirosuit helmet"
	desc = "A reinforced envirohelm designed for security personnel, reducing most traditional forms of injury."
	icon_state = "curity_envirohelm"
	item_state = "curity_envirohelm"
	armor = list(MELEE = 35, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 0, FIRE = 100, ACID = 75, WOUND = 10)

/obj/item/clothing/head/helmet/space/plasmaman/blue
	name = "blue envirosuit helmet"
	desc = "A generic blue envirohelm."
	icon_state = "blue_envirohelm"
	item_state = "blue_envirohelm"
	
/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology envirosuit helmet"
	desc = "An envirohelm specially designated for virologists."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering envirosuit helmet"
	desc = "A tougher, space-worthy envirohelm designed for engineering personnel."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list(MELEE = 15, BULLET = 5, LASER = 20, ENERGY = 10, BOMB = 20, BIO = 100, RAD = 20, FIRE = 100, ACID = 75, WOUND = 10)

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "prototype envirosuit helmet"
	desc = "An ancient envirohelm from the second generation of Nanotrasen-plasmaman related equipment. Clunky, but still sees use due to its reliability."
	icon_state = "curator_envirohelm"
	item_state = "curator_envirohelm"
	
/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The make-up is painted on. It's a miracle it doesn't chip. It's not very colourful."
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	
/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The make-up is painted on. It's a miracle it doesn't chip. <i>'HONK!'</i>"
	icon_state = "clown_envirohelm"
	item_state = "clown_envirohelm"
	