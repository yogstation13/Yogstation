//////////////////////////////////////////////////////////////////////////
//-------------------Abilities that only two classes get----------------//
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//-------------------Scout and warlock, hide in person------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/touch/umbral_trespass
	name = "Umbral trespass"
	desc = "Melds with a target's shadow, causing you to invisibly follow them. Only works in lit areas, and you will be forced out if you hold any items. Costs 30 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "umbral_trespass"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	invocation_type = INVOCATION_NONE
	psi_cost = 30
	cooldown_time = 10 SECONDS
	hand_path = /obj/item/melee/touch_attack/darkspawn
	///status effect applied by the spell
	var/datum/status_effect/tagalong/tagalong

/datum/action/cooldown/spell/touch/umbral_trespass/cast(mob/living/carbon/cast_on)
	if(tagalong)
		var/possessing = FALSE
		if(cast_on.has_status_effect(STATUS_EFFECT_TAGALONG))
			possessing = TRUE
		QDEL_NULL(tagalong)
		if(possessing)
			return //only return if the user is actually still hiding
	return ..()
	
/datum/action/cooldown/spell/touch/umbral_trespass/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/target, mob/living/carbon/human/caster)
	tagalong = caster.apply_status_effect(STATUS_EFFECT_TAGALONG, target)
	caster.balloon_alert(caster, "Iahz")
	to_chat(caster, span_velvet("You slip into [target]'s shadow. This will last five minutes, until canceled, or you are forced out by darkness."))
	caster.forceMove(target)
	return TRUE

//////////////////////////////////////////////////////////////////////////
//-----------------Scout and warlock, aoe slow and chill----------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/icyveins //Stuns and freezes nearby people - a bit more effective than a changeling's cryosting
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, slowing them and rapidly chilling their body."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "icy_veins"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	sound = 'sound/effects/ghost2.ogg'
	aoe_radius = 3
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 60
	cooldown_time = 45 SECONDS

/datum/action/cooldown/spell/aoe/icyveins/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Syn'thra")
	to_chat(owner, span_velvet("You freeze the nearby air."))
	if(isliving(owner))
		var/mob/living/target = owner
		target.extinguish_mob()

/datum/action/cooldown/spell/aoe/icyveins/cast_on_thing_in_aoe(atom/target, atom/user)
	if(!can_see(user, target))
		return
	if(!isliving(target))
		return
	var/mob/living/victim = target
	if(is_team_darkspawn(victim)) //no friendly fire
		return
	to_chat(victim, span_userdanger("A wave of shockingly cold air engulfs you!"))
	victim.apply_damage(10, BURN)
	if(victim.reagents)
		victim.reagents.add_reagent(/datum/reagent/consumable/frostoil, 10)
		victim.reagents.add_reagent(/datum/reagent/shadowfrost, 10)

//////////////////////////////////////////////////////////////////////////
//--------------------Transform into a simplemob------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/shapeshift/crawling_shadows
	name = "Crawling Shadows"
	desc = "Assumes a shadowy form that can crawl through vents and squeeze through the cracks in doors."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "crawling_shadows"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	psi_cost = 55
	cooldown_time = 1 SECONDS //to prevent double clicking by accident
	die_with_shapeshifted_form = FALSE
	convert_damage = TRUE
	convert_damage_type = STAMINA
	sound = 'yogstation/sound/magic/devour_will_end.ogg'
	possible_shapes = list(/mob/living/simple_animal/hostile/crawling_shadows)

/datum/action/cooldown/spell/shapeshift/crawling_shadows/do_shapeshift(mob/living/caster)
	. = ..()
	if(.)
		owner.balloon_alert(owner, "Zov...")

/datum/action/cooldown/spell/shapeshift/crawling_shadows/do_unshapeshift(mob/living/caster)
	. = ..()
	if(.)
		owner.balloon_alert(owner, "...Voz")

/datum/action/cooldown/spell/shapeshift/crawling_shadows/can_cast_spell(feedback)
	if(owner.has_status_effect(/datum/status_effect/shapechange_mob/from_spell)) //so it's free to change back, but costs psi to change
		psi_cost = 0
	else
		psi_cost = initial(psi_cost)
	if(owner.has_status_effect(STATUS_EFFECT_TAGALONG))
		return FALSE
	if(owner.movement_type & VENTCRAWLING) //don't let them smoosh themselves
		if(feedback)
			to_chat(owner, span_warning("There isn't enough room to release your transformation"))
		return FALSE
	return ..()
	
//////////////////////////////////////////////////////////////////////////
//------------------------Summon a distraction--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/simulacrum
	name = "Simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will fight nearby enemies in your stead for 10 seconds. Costs 40 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "simulacrum"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 40
	///How long the clones last
	var/duration = 10 SECONDS

/datum/action/cooldown/spell/simulacrum/cast(atom/cast_on)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/L = owner
	L.balloon_alert(L, "Zkxa'ya")
	L.visible_message(span_warning("[L] breaks away from [L]'s shadow!"), span_velvet("You create an illusion of yourself."))
	playsound(L, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)

	var/mob/living/simple_animal/hostile/illusion/darkspawn/M = new(get_turf(L))
	M.Copy_Parent(L, duration, 100, 10) //closely follows regular player stats so it's not painfully obvious (still sorta is)
	M.move_to_delay = L.movement_delay()
	
//////////////////////////////////////////////////////////////////////////
//--------------------Summon a sentient distraction---------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/fray_self
	name = "Fray self"
	desc = "Attemps to split a piece of your psyche into a sentient copy of yourself that lasts until destroyed. Costs 80 Psi."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "fray_self"
	panel = "Darkspawn"
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 100
	cooldown_time = 3 MINUTES
	///mob summoned by the spell
	var/mob/living/simple_animal/hostile/illusion/darkspawn/psyche/dude
	///health of the mob summoned by the spell
	var/health = 100
	///punch damage of the mob summoned by the spell
	var/damage = 10
	///Boolean, whether or not the spell is trying to call a ghost
	var/searching = FALSE

/datum/action/cooldown/spell/fray_self/can_cast_spell(feedback)
	if(dude)
		if(feedback)
			to_chat(owner, span_velvet("The piece of your psyche hasn't yet returned to you."))
		return FALSE
	if(searching)
		return FALSE
	return ..()

/datum/action/cooldown/spell/fray_self/cast(atom/cast_on)
	. = ..()
	if(dude || searching)
		return
	if(!isliving(owner))
		return
	INVOKE_ASYNC(src, PROC_REF(fray))

///Attempt to spawn the sentient ghost mob
/datum/action/cooldown/spell/fray_self/proc/fray()
	var/mob/living/caster = owner
	
	to_chat(caster, span_velvet("You attempt to split a piece of your psyche."))
	searching = TRUE
	var/mob/dead/observer/chosen_ghost
	var/list/consenting_candidates = pollGhostCandidates("Would you like to play as piece of [caster]'s psyche?", "Darkspawn", null, ROLE_DARKSPAWN, 10 SECONDS, POLL_IGNORE_DARKSPAWN_PSYCHE)
	if(consenting_candidates.len)
		chosen_ghost = pick(consenting_candidates)
	searching = FALSE
	if(!chosen_ghost)
		to_chat(caster, span_danger("You fail to split a piece of your psyche."))
		return

	caster.balloon_alert(caster, "Zkxa'yaera Hohef'era!")
	caster.visible_message(span_warning("[caster] breaks away from [caster]'s shadow!"), span_velvet("The piece of your psyche creates a form for itself."))
	playsound(caster, 'yogstation/sound/magic/devour_will_form.ogg', 50, 1)

	if(!dude)
		dude = new(get_turf(caster))
		RegisterSignal(dude, COMSIG_LIVING_DEATH, PROC_REF(rejoin))
	dude.Copy_Parent(caster, 100, health, damage)
	dude.ckey = chosen_ghost.ckey
	dude.name = caster.name
	dude.real_name = caster.real_name
	if(isdarkspawn(caster))
		var/datum/antagonist/darkspawn/darkspawn = isdarkspawn(caster)
		darkspawn.block_psi(30 SECONDS, type)

///Make sure to properly reset the ability when the ghost mob dies
/datum/action/cooldown/spell/fray_self/proc/rejoin()
	to_chat(owner, span_velvet("You feel your psyche form back into a singular entity."))
	if(!QDELETED(dude))
		qdel(dude)
	dude = null
