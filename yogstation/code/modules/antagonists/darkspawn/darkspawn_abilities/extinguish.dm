/datum/action/cooldown/spell/aoe/extinguish
	name = "Extinguish"
	desc = "Extinguish all light around you."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	aoe_radius = 7
	panel = null
	antimagic_flags = NONE
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	cooldown_time = 15 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_gasp.ogg'
	var/obj/item/dark_orb/bopper

/datum/action/cooldown/spell/aoe/extinguish/Grant(mob/grant_to)
	. = ..()
	bopper = new(src)
	
/datum/action/cooldown/spell/aoe/extinguish/Remove(mob/living/remove_from)
	qdel(bopper)
	. = ..()

/datum/action/cooldown/spell/aoe/extinguish/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(isturf(victim)) //no turf hitting
		return
	if(ishuman(victim))//put out any
		var/mob/living/carbon/human/target = victim
		target.extinguish_mob()
		if(is_darkspawn_or_veil(target))
			return
	if(isobj(victim))//put out any items too
		var/obj/target = victim
		target.extinguish()
	bopper.afterattack(victim, owner) //just use a light eater attack on everyone

/obj/item/dark_orb
	name = "extinguish"
	desc = "you shouldn't be seeing this, it's just used for the spell and nothing else"

/obj/item/dark_orb/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/light_eater)

