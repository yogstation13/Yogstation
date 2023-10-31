/datum/action/cooldown/spell/aoe/deluge
	name = "deluge"
	desc = "Erase the very concept of time for a short period of time."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "time_dilation"
	panel = null
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 10
	cooldown_time = 20 SECONDS

/datum/action/cooldown/spell/aoe/deluge/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		var/mob/living/target = owner
		target.extinguish_mob()
		target.adjust_wet_stacks(20)
		ADD_TRAIT(target, TRAIT_NOFIRE, type)
		addtimer(CALLBACK(src, PROC_REF(REMOVE_TRAIT), target, TRAIT_NOFIRE), 10 SECONDS, TIMER_UNIQUE, TIMER_OVERRIDE)

/datum/action/cooldown/spell/aoe/deluge/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isliving(victim))
		return
	var/mob/living/target = victim
	target.extinguish_mob()
	if(is_darkspawn_or_veil(target) && ispreternis(target)) //don't make preterni allies wet
		return
	target.adjust_wet_stacks(20)
