/datum/action/cooldown/spell/worm_contract
	name = "Force Contract"
	desc = "Forces all the worm parts to collapse onto a single turf"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_contract"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

/datum/action/cooldown/spell/worm_contract/cast(mob/living/user)
	. = ..()
	if(!istype(user,/mob/living/simple_animal/hostile/eldritch/armsy))
		to_chat(user, span_userdanger("You try to contract your muscles but nothing happens..."))
		return
	var/mob/living/simple_animal/hostile/eldritch/armsy/armsy = user
	armsy.contract_next_chain_into_single_tile()

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6

/obj/effect/temp_visual/eldritch_smoke
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "smoke"
	duration = 1 SECONDS
