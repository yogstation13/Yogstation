/datum/guardian_ability/major/special/timestop
	name = "Time Stop"
	desc = "The guardian can stop time in a localized area."
	cost = 5
	spell_type = /datum/action/cooldown/spell/timestop/guardian

/datum/guardian_ability/major/special/timestop/Berserk()
	spell.Remove(guardian)
	spell = new /datum/action/cooldown/spell/timestop/guardian/beserk
	spell.Grant(guardian)

/datum/action/cooldown/spell/timestop/guardian
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/datum/action/cooldown/spell/timestop/guardian/Grant(mob/grant_to)
	. = ..()
	var/mob/living/simple_animal/hostile/guardian/guardian = owner
	if(guardian && istype(guardian) && guardian.summoner)
		ADD_TRAIT(guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))

/datum/action/cooldown/spell/timestop/guardian/Remove(mob/remove_from)
	var/mob/living/simple_animal/hostile/guardian/guardian = owner
	if(guardian && istype(guardian) && guardian.summoner)
		REMOVE_TRAIT(guardian.summoner, TRAIT_TIME_STOP_IMMUNE, REF(src))
	return ..()

/datum/action/cooldown/spell/timestop/guardian/beserk
	timestop_effect = /obj/effect/timestop/berserk

/obj/effect/timestop/berserk
	name = "lagfield"
	desc = "Oh no. OH NO."
	freezerange = 4
	duration = 175
	pixel_x = -64
	pixel_y = -64
	start_sound = 'yogstation/sound/effects/unnatural_clock_noises.ogg'

/obj/effect/timestop/berserk/Initialize(mapload, radius, time, list/immune_atoms, start)
	. = ..()
	var/matrix/ntransform = matrix(transform)
	ntransform.Scale(2)
	animate(src, transform = ntransform, time = 0.2 SECONDS, easing = EASE_IN|EASE_OUT)
