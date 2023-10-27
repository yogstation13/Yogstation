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
	