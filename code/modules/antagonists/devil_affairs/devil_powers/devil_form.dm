/datum/action/cooldown/spell/shapeshift/devil
	name = "Devil Form"
	desc = "Take on the true shape of a devil."
	invocation = "P'ease't d'y 'o' a w'lk!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE
	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

	button_icon = 'icons/mob/actions/actions_devil.dmi'
	button_icon_state = "devil_form"

	possible_shapes = list(/mob/living/simple_animal/hostile/devil)
