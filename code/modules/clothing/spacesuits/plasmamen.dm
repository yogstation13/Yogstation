 //Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version


/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like its smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
	allowed = list(/obj/item/gun, /obj/item/ammo_casing, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75)
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10
	item_flags = NONE


/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There [extinguishes_left == 1 ? "is" : "are"] [extinguishes_left] extinguisher charge\s left in this suit.</span>"


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit automatically extinguishes [H.p_them()]!</span>","<span class='warning'>Your suit automatically extinguishes you.</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "purple envirosuit helmet"
	desc = "A generic purple envirohelm."
	icon_state = "purple_envirohelm"
	item_state = "purple_envirohelm"
	strip_delay = 80
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75)
	resistance_flags = FIRE_PROOF
	var/brightness_on = 4 //luminosity when the light is on
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head() //So the mob overlay updates

	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security envirosuit helmet"
	desc = "A plasma containment helmet designed for security, protecting them from being flashed and burning alive, along-side other undesirables."
	icon_state = "deathcurity_envirohelm"
	item_state = "deathcurity_envirohelm"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 75)

/obj/item/clothing/head/helmet/space/plasmaman/blue
	name = "blue envirosuit helmet"
	desc = "A generic blue envirohelm."
	icon_state = "blue_envirohelm"
	item_state = "blue_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 10, "fire" = 100, "acid" = 75)

/obj/item/clothing/head/helmet/space/plasmaman/curator
	name = "prototype envirosuit helmet"
	desc = "A slight modification on a tradiational voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "curator_envirohelm"
	item_state = "curator_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. It's not very colourful."
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. <i>'HONK!'</i>"
	icon_state = "clown_envirohelm"
	item_state = "clown_envirohelm"
