/obj/item/clothing/suit/hooded/miningmedic
	name = "recovery suit"
	desc = "A lightly armoured suit for search and rescue in harsh environments."
	icon_state = "recovery"
	item_state = "recovery"
	worn_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES
	flags_prot = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/miningmedic
	armor = list(MELEE = 40, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)

	resistance_flags = FIRE_PROOF
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/suit/hooded/miningmedic/Initialize(mapload) //can't be reinforced like regular explorer suits, but can also carry medical stuff in addition to mining stuff
	. = ..()
	allowed |= GLOB.labcoat_allowed
	allowed |= GLOB.mining_allowed

/obj/item/clothing/head/hooded/miningmedic
	name = "recovery hood"
	desc = "A lightly armoured hood for search and rescue in harsh environments."
	icon_state = "recovery"
	icon = 'yogstation/icons/obj/clothing/hats.dmi'
	worn_icon = 'yogstation/icons/mob/clothing/head/head.dmi'
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS // hoods don't hide your face, silly
	flags_prot = HIDEHAIR
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list(MELEE = 40, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)
	resistance_flags = FIRE_PROOF
	var/adjusted = NORMAL_STYLE

//don't want this to be a subtype of the explorer suit or it'll inherit the armor plating
/obj/item/clothing/head/hooded/miningmedic/verb/hood_adjust()
	set name = "Adjust Hood Style"
	set category = null
	set src in usr
	switch(adjusted)
		if(NORMAL_STYLE)
			adjusted = ALT_STYLE
			to_chat(usr, span_notice("You adjust the hood to wear it more casually."))
			flags_inv &= ~HIDEHAIR
		if(ALT_STYLE)
			adjusted = NORMAL_STYLE
			to_chat(usr, span_notice("You adjust the hood back to normal."))
			flags_inv |= HIDEHAIR
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_hair()
		H.update_body()
