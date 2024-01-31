// Vox space gear (vaccuum suit, low pressure armour)
// Can't be equipped by any other species due to bone structure and vox cybernetics.

/obj/item/clothing/suit/space/vox
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword, \
	/obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 40, BULLET = 40, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 80, ACID = 85)
	icon = 'icons/obj/clothing/species/vox/suits.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi')
	slowdown = 2

/obj/item/clothing/head/helmet/space/vox
	armor = list(MELEE = 40, BULLET = 40, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 80, ACID = 85)
	clothing_flags = STOPSPRESSUREDAMAGE
	flags_cover = HEADCOVERSEYES
	icon = 'icons/obj/clothing/species/vox/hats.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/helmet/space/vox/pressure
	name = "alien helmet"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"

/obj/item/clothing/suit/space/vox/pressure
	name = "alien pressure suit"
	icon_state = "vox-pressure"
	item_state = "vox-pressure"
	desc = "A huge, armoured, pressurized suit, designed for distinctly nonhuman proportions."

/obj/item/clothing/head/helmet/space/vox/carapace
	name = "alien visor"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."

/obj/item/clothing/suit/space/vox/carapace
	name = "alien carapace armour"
	icon_state = "vox-carapace"
	item_state = "vox-carapace"
	desc = "An armoured, segmented carapace with glowing purple lights. It looks pretty run-down."
	slowdown = 1

/obj/item/clothing/head/helmet/space/vox/stealth
	name = "alien stealth helmet"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A smoothly contoured, matte-black alien helmet."

/obj/item/clothing/suit/space/vox/stealth
	name = "alien stealth suit"
	icon_state = "vox-stealth"
	item_state = "vox-stealth"
	desc = "A sleek black suit. It seems to have a tail, and is very heavy."

/obj/item/clothing/head/helmet/space/vox/medic
	name = "alien goggled helmet"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An alien helmet with enormous goggled lenses."

/obj/item/clothing/suit/space/vox/medic
	name = "alien armour"
	icon_state = "vox-medic"
	item_state = "vox-medic"
	desc = "An almost organic looking nonhuman pressure suit."

/obj/item/clothing/under/vox
	icon = 'icons/obj/clothing/species/vox/uniforms.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/misc.dmi'
		)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	item_state = "vox-casual-1"

/obj/item/clothing/under/vox/vox_robes
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	item_state = "vox-casual-2"

/obj/item/clothing/under/vox/vox_casual
	name = "alien jumpsuit"
	desc = "These loose clothes are optimized for the labors of the lower castes onboard the arkships. Large openings in the top allow for breathability while the pants are durable yet flexible enough to not restrict movement."
	icon = 'icons/mob/clothing/species/vox/under/misc.dmi'
	icon_state = "vox-jumpsuit"
	item_state = "vox-jumpsuit"

/obj/item/clothing/suit/hooded/vox_robes
	name = "alien hooded robes"
	desc = "Large, comfortable robes worn by those who need a bit more covering. The thick fabric contains a pocket suitable for those that need their hands free during their work, while the cloth serves to cover scars or other injuries to the wearer's body."
	icon = 'icons/mob/clothing/species/vox/suit.dmi'
	icon_state = "vox-robes"
	item_state = "vox-robes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/vox_robe_hood
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
	)

//Vox Robes Hood
/obj/item/clothing/head/hooded/vox_robe_hood
	name = "alien hood"
	desc = "The thick fabric of this hood serves a variety of purposes to the vox wearing it - serving as a method to hide a scarred face or a way to keep warm in the coldest areas onboard the ship."
	icon = 'icons/mob/clothing/species/vox/head.dmi'
	icon_state = "vox-robes-hood"
	item_state = "vox-robes-hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
	)

/obj/item/clothing/gloves/color/yellow/vox
	name = "insulated gauntlets"
	desc = "These bizarre gauntlets seem to be fitted for...bird claws?"
	icon_state = "gloves-vox"
	item_state = "gloves-vox"
	icon = 'icons/obj/clothing/species/vox/gloves.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/gloves.dmi')

/obj/item/clothing/shoes/magboots/vox
	name = "vox magclaws"
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	item_state = "boots-vox"
	icon_state = "boots-vox"
	icon = 'icons/obj/clothing/species/vox/shoes.dmi'
	species_restricted = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/feet.dmi')

/obj/item/clothing/shoes/magboots/vox/attack_self(mob/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP
		REMOVE_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		to_chat(user, "You relax your deathgrip on the flooring.")
	else
		//make sure these can only be used when equipped.
		if(!ishuman(user))
			return
		var/mob/living/carbon/human/H = user
		if(H.shoes != src)
			to_chat(user, span_warning("You will have to put on [src] before you can do that."))
			return
		clothing_flags |= NOSLIP	//kinda hard to take off magclaws when you are gripping them tightly.
		ADD_TRAIT(src, TRAIT_NODROP, "vox_magclaws")
		to_chat(user, "You dig your claws deeply into the flooring, bracing yourself.")
		to_chat(user, "It would be hard to take off [src] without relaxing your grip first.")
	magpulse = !magpulse
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()

//In case they somehow come off while enabled.
/obj/item/clothing/shoes/magboots/vox/dropped(mob/user)
	..()
	if(magpulse)
		user.visible_message("[src] go limp as they are removed from [usr]'s feet.", "[src] go limp as they are removed from your feet.")
		magpulse = FALSE
		clothing_flags &= ~NOSLIP
		REMOVE_TRAIT(src, TRAIT_NODROP, "vox_magclaws")

/obj/item/clothing/shoes/magboots/vox/examine(mob/user)
	. = ..()
	if(magpulse)
		. += "It would be hard to take these off without relaxing your grip first."//theoretically this message should only be seen by the wearer when the claws are equipped.
