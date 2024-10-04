/obj/item/clothing/head/helmet/space/hardsuit/juggernaut
	name = "cybersun juggernaut helmet"
	desc = "A hardened helmet plated in synthetic xenofauna hide. A biometric scanning line flashes across the visor."
	icon_state = "hardsuit0-juggernaut"
	hardsuit_type = "juggernaut"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor_type = /datum/armor/hardsuit/juggernaut
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT | HEADINTERNALS
	actions_types = null

/obj/item/clothing/head/helmet/space/hardsuit/juggernaut/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/head/helmet/space/hardsuit/juggernaut/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		var/datum/atom_hud/SHUD = GLOB.huds[DATA_HUD_SECURITY_BASIC]
		var/datum/atom_hud/MHUD = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		DHUD.show_to(user)
		SHUD.show_to(user)
		MHUD.show_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/juggernaut/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		var/datum/atom_hud/SHUD = GLOB.huds[DATA_HUD_SECURITY_BASIC]
		var/datum/atom_hud/MHUD = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		DHUD.hide_from(user)
		SHUD.hide_from(user)
		MHUD.hide_from(user)
		user.update_sight()

/datum/action/item_action/toggle_suit_flashlight //monkestation addition
	name = "Toggle Integrated Flashlight"

/obj/item/clothing/suit/space/hardsuit/juggernaut
	name = "cybersun juggernaut hardsuit"
	desc = "A hyper resilient suit created from several layers of exotic materials and alloys. An etching in the neck pressure seal reads \"Property of Gorlex Marauders.\""
	worn_icon_digitigrade = 'monkestation/icons/mob/clothing/species/suit_digi.dmi'
	icon_state = "hardsuit-juggernaut"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	clothing_flags = BLOCKS_SHOVE_KNOCKDOWN | STOPSPRESSUREDAMAGE | THICKMATERIAL //you are a walking wall you can't shove a wall down!
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/gun,
		/obj/item/tank/jetpack/oxygen/captain
	)
	armor_type = /datum/armor/hardsuit/juggernaut
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/juggernaut
	cell = /obj/item/stock_parts/cell/super
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_outer_range = 5
	light_power = 1
	light_on = FALSE
	light_color = LIGHT_COLOR_GREEN
	actions_types = list(/datum/action/item_action/toggle_helmet, /datum/action/item_action/toggle_spacesuit,/datum/action/item_action/toggle_suit_flashlight)
	slowdown = 2
	strip_delay = 70

/obj/item/clothing/suit/space/hardsuit/juggernaut/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)

/obj/item/clothing/suit/space/hardsuit/juggernaut
	var/on = FALSE

/obj/item/clothing/suit/space/hardsuit/juggernaut/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_suit_flashlight))
		on = !on
		set_light_on(on)
	if(istype(actiontype, /datum/action/item_action/toggle_spacesuit))
		toggle_spacesuit(user)
	else if(istype(actiontype, /datum/action/item_action/toggle_helmet))
		ToggleHelmet()
