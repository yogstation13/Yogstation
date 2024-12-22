/datum/artifact_effect/false_rod
	examine_hint = span_warning("You feel a binding aura connected to this.")
	examine_discovered = span_warning("Will bind it self to the wearer, forcing upon them an oath to heal!")
	weight = ARTIFACT_UNCOMMON

	artifact_size = ARTIFACT_SIZE_SMALL
	type_name = "Oath-Bearing Rod Effect"

	var/list/first_touched

	var/mob/living/our_victim

	COOLDOWN_DECLARE(touch_cooldown)

/datum/artifact_effect/false_rod/setup()
	RegisterSignal(our_artifact.holder,COMSIG_ITEM_POST_EQUIPPED,TYPE_PROC_REF(/datum/artifact_effect/false_rod,on_pickup))

/datum/artifact_effect/false_rod/proc/on_pickup(obj/item/the_item,mob/taker,slot)
	SIGNAL_HANDLER
	if(!isliving(taker))
		return COMPONENT_EQUIPPED_FAILED
	var/mob/living/user = taker
	if(!(isitem(our_artifact.holder)) || !COOLDOWN_FINISHED(src,touch_cooldown))
		return COMPONENT_EQUIPPED_FAILED
	if(!LAZYACCESS(first_touched, user))
		to_chat(user,span_bolddanger("You hesitate before touching [our_artifact.holder], feeling it will do something that cannot be un-done easily!"))
		LAZYSET(first_touched, user, TRUE)
		COOLDOWN_START(src, touch_cooldown, 7.5 SECONDS) // so you don't get fucked over by spam-clicking it
		return COMPONENT_EQUIPPED_FAILED
	addtimer(CALLBACK(src,PROC_REF(post_pickup),user),(0.2 SECOND))
	return

/datum/artifact_effect/false_rod/on_destroy(atom/source)
	our_victim?.remove_status_effect(/datum/status_effect/forced_oath)
	. = ..()

/datum/artifact_effect/false_rod/proc/post_pickup(mob/living/user)
	to_chat(user,span_danger("[our_artifact.holder] forcefully melds with you, and a healing aura surrounds you!"))
	ADD_TRAIT(our_artifact.holder,TRAIT_NODROP,CURSED_ITEM_TRAIT(our_artifact.holder.type))
	user.apply_status_effect(/datum/status_effect/forced_oath)
	our_victim = user
	return

/datum/status_effect/forced_oath
	id = "Forced Oath"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = 25
	alert_type = null
	var/datum/component/aura_healing/our_aura

/datum/status_effect/forced_oath/on_apply()
	var/static/list/organ_healing = list(
		ORGAN_SLOT_BRAIN = 0.7,
	)
	//This is literally shitty Rod of Ascep.
	our_aura = owner.AddComponent( \
		/datum/component/aura_healing, \
		range = 5, \
		brute_heal = 1, \
		burn_heal = 1, \
		toxin_heal = 1, \
		suffocation_heal = 1, \
		stamina_heal = 1, \
		clone_heal = 0.2, \
		simple_heal = 1, \
		organ_healing = organ_healing, \
		healing_color = "#375637", \
	)

	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.show_to(owner)
	return TRUE
/datum/status_effect/forced_oath/on_remove()
	QDEL_NULL(our_aura)
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.hide_from(owner)
/datum/status_effect/forced_oath/get_examine_text()
	return span_notice("[owner.p_they(TRUE)] seem[owner.p_s()] to have an aura of healing around [owner.p_them()].")
/datum/status_effect/forced_oath/tick()
	if(owner.stat ==DEAD)
		return
	else
		if(iscarbon(owner))
			if(owner.health < owner.maxHealth)
				new /obj/effect/temp_visual/heal(get_turf(owner), "#375637")
				owner.adjustBruteLoss(-1)
				owner.adjustFireLoss(-1)
				owner.adjustToxLoss(-1, forced = TRUE) //Because Slime People are people too
				owner.adjustOxyLoss(-1, forced = TRUE)
				owner.stamina.adjust(1)
				owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1)
				owner.adjustCloneLoss(-0.25) //Becasue apparently clone damage is the bastion of all health
