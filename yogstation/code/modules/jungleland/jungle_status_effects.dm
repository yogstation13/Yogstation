/atom/movable/screen/alert/status_effect/toxic_buildup
	name = "Toxic buildup"
	desc = "Toxins have built up in your system, they cause sustained toxin damage and given enough time severely damage the liver. If you choose to neglect this condition and let it worsen it will lead to exhaustaion followed by death from either liver failure or toxin damage. To cure it use an un-corrupted dryad heart, injest anti-toxin medication or if the condition isn't severe, let your body naturally expell the toxic metabolites."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "toxic_buildup"

/atom/movable/screen/alert/magnus_purpura
	name = "Magnus Purpura Immunity"
	desc = "The anti-acidic enzymes found in magnus purpura make you temporarily immune to shallow sulphuric pits, allowing you to walk over them without harm. You are not immune to deep sulphuric pits."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "magnus_purpura"

/atom/movable/screen/alert/status_effect/tar_curse
	name = "Curse of Tar"
	desc = "You've been cursed by the tar priest, next attack by any tar monster will cause more damage and may have additional effects."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "tar_curse"

/datum/status_effect/tar_curse
	id = "tar_curse"
	duration = 60 SECONDS// we handle this ourselves
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/tar_curse


/datum/status_effect/tar_curse/on_apply()
	. = ..()
	RegisterSignal(owner,COMSIG_JUNGLELAND_TAR_CURSE_PROC,PROC_REF(curse_used))

/datum/status_effect/tar_curse/proc/curse_used()
	qdel(src)


/atom/movable/screen/alert/status_effect/dryad
	name = "Blessing of the forest"
	desc = "The heart of the dryad fuels you, it's tendrils engulfed you temporarily increasing your capabilities"
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "dryad_heart"

/datum/status_effect/regenerative_core/dryad
	alert_type = /atom/movable/screen/alert/status_effect/dryad

/datum/status_effect/corrupted_dryad
	id = "corrupted_dryad"
	duration = 80 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/corrupted_dryad
	var/health_multiplier = 1.5
	var/initial_health = 100

/datum/status_effect/corrupted_dryad/on_apply()
	. = ..()
	initial_health = owner.maxHealth
	owner.setMaxHealth(initial_health * health_multiplier)
	owner.adjustBruteLoss(-50)
	owner.adjustFireLoss(-50)
	owner.remove_CC()
	owner.bodytemperature = BODYTEMP_NORMAL
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "corruption", /datum/mood_event/corrupted_dryad)

/datum/status_effect/corrupted_dryad/on_remove()
	owner.setMaxHealth(initial_health)
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.vomit(10, TRUE, TRUE, 3)
	owner.adjust_dizzy(30)
	owner.adjust_jitter(30)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, id)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "corruption", /datum/mood_event/corrupted_dryad_bad)
	return ..()

/atom/movable/screen/alert/status_effect/corrupted_dryad
	name = "Corruption of the forest"
	desc = "Your heart beats unnaturally strong, you feel empowered, but nothing is bound to last..."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "rage"

/datum/status_effect/tar_shield
	id = "tar_shield"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	var/mutable_appearance/cached_image
	alert_type = null

/datum/status_effect/tar_shield/on_apply()
	. = ..()
	cached_image = mutable_appearance('yogstation/icons/effects/effects.dmi',"tar_shield")
	owner.add_overlay(cached_image)
	RegisterSignal(owner,COMSIG_MOB_CHECK_SHIELDS,PROC_REF(react_to_attack))

/datum/status_effect/tar_shield/on_remove()
	owner.cut_overlay(cached_image)
	UnregisterSignal(owner,COMSIG_MOB_CHECK_SHIELDS)
	. = ..()
	
/datum/status_effect/tar_shield/proc/react_to_attack(datum/source, atom/AM, damage, attack_text, attack_type, armour_penetration)
	new /obj/effect/better_animated_temp_visual/tar_shield_pop(get_turf(owner))
	owner.visible_message(span_danger("[owner]'s shields absorbs [attack_text]!"))
	qdel(src)

/datum/status_effect/bounty_of_the_forest
	id = "bounty_of_the_forest"
	duration = -1 // we handle this ourselves
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/bounty_of_the_forest
	var/stack = 0
	var/max_stack = 4
	var/stack_decay_time = 5 SECONDS
	var/current_stack_decay = 0

	var/healing_per_stack = 2

/datum/status_effect/bounty_of_the_forest/tick()
	current_stack_decay += initial(tick_interval)
	if(current_stack_decay >= stack_decay_time)
		current_stack_decay = 0
		update_stack(-1)
		if(stack <= 0)
			qdel(src)
			return

	if(!ishuman(owner))
		return 
	var/mob/living/carbon/human/human_owner = owner

	human_owner.adjustBruteLoss(-healing_per_stack * (stack + 1))
	human_owner.adjustFireLoss(-healing_per_stack * (stack + 1))
	human_owner.adjustToxLoss(-healing_per_stack * (stack + 1))
	human_owner.adjustOxyLoss(-healing_per_stack * (stack + 1))

/datum/status_effect/bounty_of_the_forest/proc/update_stack(amt)
	stack = min(stack + amt,max_stack)
	linked_alert = owner.throw_alert(id,alert_type,stack)

/datum/status_effect/bounty_of_the_forest/refresh()
	update_stack(1)
	current_stack_decay = 0

/datum/status_effect/bounty_of_the_forest/on_creation(mob/living/new_owner, ...)
	. = ..()
	update_stack(1)
/atom/movable/screen/alert/status_effect/bounty_of_the_forest
	name = "Bounty of the forest"
	desc = "The forest takes and the forest provides. In this circumstance I'm on the better end of the stick."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "bounty_of_the_forest"

/atom/movable/screen/alert/status_effect/glory_of_victory
	name = "Glory of victory"
	desc = "The forest gives and forest takes, no longer. I will take what's rightfully mine."
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "glory_of_victory"


