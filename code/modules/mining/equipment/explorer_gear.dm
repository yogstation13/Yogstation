/****************Explorer's Suit and Mask****************/
/obj/item/clothing/suit/hooded/explorer
	name = "explorer suit"
	desc = "An armoured suit for exploring harsh environments."
	icon_state = "explorer"
	item_state = "explorer"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES
	flags_prot = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/explorer
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife/combat)
	resistance_flags = FIRE_PROOF
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/head/hooded/explorer
	name = "explorer hood"
	desc = "An armoured hood for exploring harsh environments."
	icon_state = "explorer"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	flags_prot = HIDEHAIR|HIDEFACE
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 50, WOUND = 10)
	resistance_flags = FIRE_PROOF
	var/adjusted = NORMAL_STYLE

/obj/item/clothing/head/hooded/explorer/verb/hood_adjust()
	set name = "Adjust Hood Style"
	set category = null
	set src in usr
	switch(adjusted)
		if(NORMAL_STYLE)
			adjusted = ALT_STYLE
			to_chat(usr, span_notice("You adjust the hood to wear it more casually."))
			flags_inv &= ~(HIDEHAIR|HIDEFACE)
		if(ALT_STYLE)
			adjusted = NORMAL_STYLE
			to_chat(usr, span_notice("You adjust the hood back to normal."))
			flags_inv |= (HIDEHAIR|HIDEFACE)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_hair()
		H.update_body()

/obj/item/clothing/suit/hooded/explorer/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/hooded/explorer/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon_state = "gas_mining"
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	actions_types = list(/datum/action/item_action/adjust)
	armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, BIO = 50, RAD = 0, FIRE = 20, ACID = 40, WOUND = 5)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/gas/explorer/adjustmask(user)
	..()
	w_class = mask_adjusted ? WEIGHT_CLASS_NORMAL : WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/gas/explorer/folded/Initialize()
	. = ..()
	adjustmask()

/obj/item/clothing/suit/space/hostile_environment
	name = "H.E.C.K. suit"
	desc = "Hostile Environment Cross-Kinetic Suit: A suit designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon_state = "hostile_env"
	item_state = "hostile_env"
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	slowdown = 0
	armor = list(MELEE = 75, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife/combat)

/obj/item/clothing/suit/space/hostile_environment/Initialize()
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/hostile_environment/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/space/hostile_environment/process()
	var/mob/living/carbon/C = loc
	if(istype(C) && prob(2)) //cursed by bubblegum
		if(prob(15))
			new /datum/hallucination/oh_yeah(C)
			to_chat(C, span_colossus("<b>[pick("I AM IMMORTAL.","I SHALL TAKE BACK WHAT'S MINE.","I SEE YOU.","YOU CANNOT ESCAPE ME FOREVER.","DEATH CANNOT HOLD ME.")]</b>"))
		else
			to_chat(C, span_warning("[pick("You hear faint whispers.","You smell ash.","You feel hot.","You hear a roar in the distance.")]"))

/obj/item/clothing/head/helmet/space/hostile_environment
	name = "H.E.C.K. helmet"
	desc = "Hostile Environiment Cross-Kinetic Helmet: A helmet designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon_state = "hostile_env"
	item_state = "hostile_env"
	w_class = WEIGHT_CLASS_NORMAL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	armor = list(MELEE = 75, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | LAVA_PROOF

/obj/item/clothing/head/helmet/space/hostile_environment/Initialize()
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	update_icon()

/obj/item/clothing/head/helmet/space/hostile_environment/update_icon()
	..()
	cut_overlays()
	var/mutable_appearance/glass_overlay = mutable_appearance(icon, "hostile_env_glass")
	glass_overlay.appearance_flags = RESET_COLOR
	add_overlay(glass_overlay)

/obj/item/clothing/head/helmet/space/hostile_environment/worn_overlays(isinhands)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/M = mutable_appearance(mob_overlay_icon, "hostile_env_glass")
		M.appearance_flags = RESET_COLOR
		. += M
