/datum/action/cooldown/spell/toggle/thrall_net
	name = "Thrall net"
	desc = "Call up your boys."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	sound = 'sound/magic/staff_door.ogg'
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	var/obj/item/modular_computer/tablet/phone/preset/advanced/darkspawn/orb


/datum/action/cooldown/spell/toggle/thrall_net/Grant(mob/grant_to)
	. = ..()
	orb = new()

/datum/action/cooldown/spell/toggle/thrall_net/Remove(mob/living/remove_from)
	qdel(orb)
	. = ..()

/datum/action/cooldown/spell/toggle/thrall_net/process()
	active = owner.is_holding_item_of_type(/obj/item/modular_computer/tablet/phone/preset/advanced/darkspawn)
	. = ..()

/datum/action/cooldown/spell/toggle/thrall_net/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/thrall_net/Enable()
	owner.visible_message(span_warning("[owner] pulled shadows together into an orb!"), span_velvet("You summon your orb"))
	owner.put_in_hands(orb)

/datum/action/cooldown/spell/toggle/thrall_net/Disable()
	owner.visible_message(span_warning("The orb [owner] was holding puffed into shadows!"), span_velvet("You dispel your orb"))
	orb.moveToNullspace()

/obj/item/modular_computer/tablet/phone/preset/advanced/darkspawn
	base_active_power_usage = 0
	base_idle_power_usage = 0
	has_light = FALSE
	starting_files = list(/datum/computer_file/program/secureye/darkspawn)
	initial_program = /datum/computer_file/program/secureye/darkspawn
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/datum/computer_file/program/secureye/darkspawn
	usage_flags = PROGRAM_ALL
	network = list("darkspawn")
