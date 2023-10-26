/datum/action/cooldown/spell/toggle/thrall_net
	name = "Thrall net"
	desc = "Call up your boys."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	var/obj/item/modular_computer/tablet/phone/preset/advanced/darkspawn/orb
	var/casting = FALSE


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
	if(casting)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/thrall_net/before_cast(atom/cast_on)
	casting = TRUE
	if(!do_after(owner, 2 SECONDS, owner))
		casting = FALSE
		return SPELL_CANCEL_CAST
	casting = FALSE
	return ..()
	
/datum/action/cooldown/spell/toggle/thrall_net/Enable()
	owner.visible_message(span_warning("[owner] pulled shadows together into an orb!"), span_velvet("You summon your orb"))
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_begin.ogg', 50, TRUE)
	owner.put_in_hands(orb)

/datum/action/cooldown/spell/toggle/thrall_net/Disable()
	owner.visible_message(span_warning("The orb [owner] was holding puffed into shadows!"), span_velvet("You dispel your orb"))
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	orb.moveToNullspace()

/obj/item/modular_computer/tablet/phone/preset/advanced/darkspawn
	name = "dark orb"
	desc = "lol"
	icon = 'icons/obj/modular_phone.dmi'
	icon_state = "phone-red"
	icon_state_base = "phone"
	icon_state_unpowered = "phone"
	icon_state_powered = "phone"
	base_active_power_usage = 0
	base_idle_power_usage = 0
	has_light = FALSE
	no_overlays = TRUE
	starting_files = list(/datum/computer_file/program/secureye/darkspawn)
	initial_program = /datum/computer_file/program/secureye/darkspawn
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	pen_type = null
	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 2
	interact_sounds = list('yogstation/sound/creatures/crawlingshadows/crawling_shadows_walk_01.ogg', 'yogstation/sound/creatures/crawlingshadows/crawling_shadows_walk_02.ogg', 'yogstation/sound/creatures/crawlingshadows/crawling_shadows_walk_03.ogg')//change to something spooky

/obj/item/modular_computer/tablet/phone/preset/advanced/darkspawn/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/light_eater)

/datum/computer_file/program/secureye/darkspawn
	usage_flags = PROGRAM_ALL
	network = list("darkspawn")
	available_on_ntnet = FALSE
	unsendable = TRUE
	undeletable = TRUE
	turnoff_sound = null
	action_sound = "crawling_shadows_walk"
