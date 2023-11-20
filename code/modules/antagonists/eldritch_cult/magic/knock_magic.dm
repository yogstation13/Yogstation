/datum/action/cooldown/spell/jaunt/ethereal_jaunt/knock
	name = "Expedited Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "phaseout"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	exit_jaunt_sound = null
	jaunt_duration = 1.5 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/knock_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/knock_shift/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/knock/do_steam_effects()
	return

/obj/effect/temp_visual/dir_setting/knock_shift
	name = "knock_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "phasein"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/dir_setting/knock_shift/out
	icon_state = "phaseout"

/datum/action/cooldown/spell/pointed/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Steal a random item from the victim's backpack."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "burglarsfinesse"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "Y'O'INK!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION|SPELL_REQUIRES_NO_ANTIMAGIC

	cast_range = 6

/datum/action/cooldown/spell/pointed/burglar_finesse/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on) && (locate(/obj/item/storage/backpack) in cast_on.contents)

/datum/action/cooldown/spell/pointed/burglar_finesse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_danger("You feel a light tug, but are otherwise fine, you were protected by holiness!"))
		to_chat(owner, span_danger("[cast_on] is protected by holy forces!"))
		return FALSE

	var/obj/storage_item = locate(/obj/item/storage/backpack) in cast_on.contents
	
	if(isnull(storage_item))
		return FALSE

	var/item = pick(storage_item.contents)
	if(isnull(item))
		return FALSE

	to_chat(cast_on, span_warning("Your [storage_item] feels lighter..."))
	to_chat(owner, span_notice("With a blink, you pull [item] out of [cast_on][p_s()] [storage_item]."))
	owner.put_in_active_hand(item)


/datum/action/cooldown/spell/spacetime_dist/eldritch
	name = "Freedom Forever"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate..."
	sound = 'sound/effects/magic.ogg'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "spacetime"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 60 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION|SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_STATION

	scramble_radius = 3
	/// The duration of the scramble
	duration = 5 SECONDS
	