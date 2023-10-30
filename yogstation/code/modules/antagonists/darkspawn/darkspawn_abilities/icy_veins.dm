/datum/action/cooldown/spell/aoe/icyveins //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage while hampering their movement."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "icy_veins"
	sound = 'sound/effects/ghost2.ogg'
	aoe_radius = 3
	panel = null
	antimagic_flags = NONE
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/aoe/icyveins/cast(atom/cast_on)
	. = ..()
	to_chat(owner, span_velvet("You freeze the nearby air."))

/datum/action/cooldown/spell/aoe/icyveins/cast_on_thing_in_aoe(atom/target, atom/user)
	if(!isliving(target))
		return
	var/mob/living/victim = target
	if(is_darkspawn_or_veil(victim)) //no friendly fire
		return
	to_chat(victim, span_userdanger("A wave of shockingly cold air engulfs you!"))
	victim.Stun(2) //microstun
	victim.apply_damage(5, BURN)
	if(victim.bodytemperature)
		victim.adjust_bodytemperature(-100, 50)
	if(victim.reagents)
		victim.reagents.add_reagent(/datum/reagent/consumable/frostoil, 5) //some amount of a cryo sting fucked if I care
		victim.reagents.add_reagent(/datum/reagent/shadowfrost, 5)
