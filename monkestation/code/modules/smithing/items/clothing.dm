/obj/item/clothing/smithed_clothes
	name = "generic smithed clothes"
	desc = "generic smithed clothes"
	var/smithed_quality = 100
	var/obj/made_of = null
	var/base_name = "generic smithed clothes"

	armor_type = /datum/armor/smithed_dummy //This isnt actually used, its just a dummy

/datum/armor/smithed_dummy

/obj/item/clothing/smithed_clothes/Initialize(mapload,obj/item/created_from,quality)
	. = ..()
	smithed_quality = max(quality, 5)

	if(!created_from)
		created_from = new /obj/item/stack/sheet/mineral/gold
	made_of = new created_from.type

	if(isstack(created_from) && !created_from.material_stats)
		var/obj/item/stack/stack = created_from
		create_stats_from_material(stack.material_type)
	else
		create_stats_from_material_stats(created_from.material_stats)

	name = "[material_stats.material_name] [base_name]"
	var/damage_state
	switch(smithed_quality)
		if(0 to 24)
			damage_state = "damage-4"
			desc += " It looks of poor quality... Quality:[smithed_quality]"
		if(25 to 49)
			damage_state = "damage-3"
			desc += " It looks slightly under average. Quality:[smithed_quality]"
		if(50 to 59)
			damage_state = "damage-2"
			desc += " It looks pretty average quality. Quality:[smithed_quality]"
		if(60 to 89)
			damage_state = "damage-1"
			desc += " It looks well forged! Quality:[smithed_quality]"
		if(90 to 99)
			damage_state = null
			desc += " It looks about as perfect as can be! Quality:[smithed_quality]"
		if(100 to 125)
			damage_state = null
			desc += " It's utterly flawless! Quality:[smithed_quality]"

	if(damage_state)
		add_filter("damage_filter", 1, alpha_mask_filter(icon = icon('monkestation/code/modules/smithing/icons/forge_items.dmi', damage_state), flags = MASK_INVERSE))

	if(material_stats.thermal <= 50)
		resistance_flags |= FIRE_PROOF
	if(material_stats.thermal <= 20)
		resistance_flags |= LAVA_PROOF
	max_integrity = round(200 * (smithed_quality/100))
	repairable_by = made_of.type //This cant go wrong right
	if(material_stats.conductivity <= 10)
		siemens_coefficient = 0

	var/datum/armor/temp = new() //Scuffed, but no idea how to better.
	set_armor(temp.generate_new_with_modifiers(list(
		ACID = min(round((material_stats.density / 1.75) * (smithed_quality/100)),60),
		BOMB = min(round(((material_stats.density + material_stats.hardness)/3.5) * (smithed_quality/100)),60),
		BULLET = min(round(((material_stats.density + material_stats.hardness)/3.5) * (smithed_quality/100)),60),
		ENERGY = min(round((material_stats.refractiveness / 1.75) * (smithed_quality/100)),60),
		FIRE = min(round(((100-material_stats.thermal)/1.75) * (smithed_quality/100)),60),
		LASER = min(round(((material_stats.refractiveness + material_stats.density)/3.5) * (smithed_quality/100)),60),
		MELEE = min(round(((material_stats.density + material_stats.hardness)/1.75) * (smithed_quality/100)),60),
		WOUND = min(round((material_stats.density/3.5) * (smithed_quality/100)),60)
	)))
	QDEL_NULL(temp) //Thanks now back to the void with you


/obj/item/clothing/smithed_clothes/update_name(updates)
	. = ..()
	if(smithed_quality < 100)
		name = "[material_stats.material_name] [base_name]"
	else
		name = "flawless [material_stats.material_name] [base_name]"

/obj/item/clothing/smithed_clothes/gloves
	name = "generic smithed gloves"
	desc = "Some smithed gloves."
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_icon_state = "greyscale_gloves"
	icon_state = "gray"
	lefthand_file = 'icons/mob/inhands/clothing/gloves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/gloves_righthand.dmi'
	greyscale_colors = null
	greyscale_config_inhand_left = /datum/greyscale_config/gloves_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/gloves_inhand_right
	siemens_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	attack_verb_continuous = list("challenges")
	attack_verb_simple = list("challenge")
	strip_delay = 20
	equip_delay_other = 40

	base_name = "gloves"

/obj/item/clothing/smithed_clothes/suit
	name = "generic smithed suit"
	desc = "A smithed suit."
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	icon_state = "cuirass"
	allowed = null
	body_parts_covered = CHEST

	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT

	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	resistance_flags = NONE
	slot_flags = ITEM_SLOT_OCLOTHING

	allowed = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/storage/belt/holster,
		/obj/item/smithed_part,
		/obj/item/gun/ballistic/rifle/boltaction/pipegun,
		/obj/item/gun/energy/laser/musket,
		/obj/item/gun/energy/disabler/smoothbore,
		/obj/item/shield/buckler,
		/obj/item/spear,
		/obj/item/melee/baton/security/cattleprod,
		/obj/item/melee/baseball_bat
		)

	base_name = "suit"
/obj/item/clothing/smithed_clothes/helmet
	name = "generic smithed helmet"
	desc = "A smithed helmet."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "knight_green"

	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT

	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 60
	clothing_flags = SNUG_FIT | PLASMAMAN_HELMET_EXEMPT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	slot_flags = ITEM_SLOT_HEAD

	base_name = "helmet"

/obj/item/clothing/smithed_clothes/shoes
	name = "generic smithed shoes"
	desc = "Some smithed shoes."
	icon = 'monkestation/code/modules/smithing/icons/boots.dmi'
	worn_icon = 'monkestation/code/modules/smithing/icons/boots.dmi'
	icon_state = "smithed_boots_inhand"
	worn_icon_state = "smithed_boots"
	inhand_icon_state = "jackboots"

	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT

	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	lefthand_file = 'icons/mob/inhands/clothing/shoes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/shoes_righthand.dmi'
	gender = PLURAL //Carn: for grammarically correct text-parsing

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

	base_name = "shoes"
