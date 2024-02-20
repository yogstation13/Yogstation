/datum/action/item_action/toggle

/datum/action/item_action/toggle/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Toggle [item_target.name]"

/datum/action/item_action/toggle_light
	name = "Toggle Light"

/datum/action/item_action/toggle_hood
	name = "Toggle Hood"

/datum/action/item_action/toggle_firemode
	name = "Toggle Firemode"

/datum/action/item_action/toggle_bodycam
	name = "Toggle Bodycamera"

/datum/action/item_action/toggle_gunlight
	name = "Toggle Gunlight"

/datum/action/item_action/toggle_mode
	name = "Toggle Mode"

/datum/action/item_action/toggle_barrier_spread
	name = "Toggle Barrier Spread"

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_paddles
	name = "Toggle Paddles"

/datum/action/item_action/toggle_helmet_light
	name = "Toggle Helmet Light"

/datum/action/item_action/toggle_welding_screen
	name = "Toggle Welding Screen"

/datum/action/item_action/toggle_welding_screen/Trigger()
	var/obj/item/clothing/head/hardhat/weldhat/H = target
	if(istype(H))
		H.toggle_welding_screen(owner)

/datum/action/item_action/toggle_headphones
	name = "Toggle Headphones"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/toggle_headphones/Trigger()
	var/obj/item/clothing/ears/headphones/H = target
	if(istype(H))
		H.toggle(owner)

/datum/action/item_action/toggle_unfriendly_fire
	name = "Toggle Friendly Fire \[ON\]"
	desc = "Toggles if the club's blasts cause friendly fire."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_ff_on"

/datum/action/item_action/toggle_unfriendly_fire/Trigger()
	if(..())
		build_all_button_icons()

/datum/action/item_action/toggle_unfriendly_fire/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	if(!istype(target, /obj/item/hierophant_club))
		return
	var/obj/item/hierophant_club/H = target
	button_icon_state = H.friendly_fire_check ? "vortex_ff_off" : "vortex_ff_on"
	name = H.friendly_fire_check ? "Toggle Friendly Fire \[OFF\]" : "Toggle Friendly Fire \[ON\]"
	return ..()

/datum/action/item_action/toggle_research_scanner
	name = "Toggle Research Scanner"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "scan_mode"
	var/active = FALSE

/datum/action/item_action/toggle_research_scanner/Trigger()
	if(IsAvailable(feedback = FALSE))
		active = !active
		if(active)
			owner.research_scanner++
		else
			owner.research_scanner--
		to_chat(owner, span_notice("[target] research scanner has been [active ? "activated" : "deactivated"]."))
		return 1

/datum/action/item_action/toggle_research_scanner/Remove(mob/M)
	if(owner && active)
		owner.research_scanner--
		active = FALSE
	..()

/datum/action/item_action/jetpack_stabilization
	name = "Toggle Jetpack Stabilization"

/datum/action/item_action/jetpack_stabilization/IsAvailable(feedback = FALSE)
	var/obj/item/tank/jetpack/linked_jetpack = target
	if(!istype(linked_jetpack) || !linked_jetpack.on)
		return FALSE
	return ..()

/datum/action/item_action/toggle_helmet_flashlight
	name = "Toggle Helmet Flashlight"

/datum/action/item_action/toggle_helmet_mode
	name = "Toggle Helmet Mode"

/datum/action/item_action/toggle_wings
	name = "Toggle Wings"

/datum/action/item_action/toggle_voice_box
	name = "Toggle Voice Box"

/datum/action/item_action/toggle_human_head
	name = "Toggle Human Head"

/datum/action/item_action/toggle_helmet
	name = "Toggle Helmet"

/datum/action/item_action/toggle_jetpack
	name = "Toggle Jetpack"

/datum/action/item_action/wheelys
	name = "Toggle Wheely-Heel's Wheels"
	desc = "Pops out or in your wheely-heel's wheels."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"

/datum/action/item_action/kindle_kicks
	name = "Activate Kindle Kicks"
	desc = "Kick you feet together, activating the lights in your Kindle Kicks."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "kindleKicks"

/datum/action/item_action/storage_gather_mode
	name = "Switch gathering mode"
	desc = "Switches the gathering mode of a storage object."
	background_icon = 'icons/mob/actions/actions_items.dmi'
	background_icon_state = "storage_gather_switch"
	overlay_icon_state = "bg_tech_border"

/datum/action/item_action/equip_unequip_TED_Gun
	name = "Equip/Unequip TED Gun"

/datum/action/item_action/toggle_pseudocider
	name = "Toggle Pseudocider"
