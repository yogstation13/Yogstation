#define ACTION_DELAY (0.8 SECONDS) //regular punch delay
#define DASH_RANGE 3
#define DASH_SPEED 2


/datum/martial_art/lightning_flow
	name = "Lightning Flow"
	id = MARTIALART_LIGHTNINGFLOW
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/lightning_flow_help
	var/recalibration = /mob/living/carbon/human/proc/lightning_flow_recalibration
	var/dashing = FALSE
	COOLDOWN_DECLARE(action_cooldown)
	var/action_type = null	

/datum/martial_art/lightning_flow/can_use(mob/living/carbon/human/H)
	if(H.stat == DEAD || H.incapacitated() || HAS_TRAIT(H, TRAIT_PACIFISM))
		return FALSE
	return isethereal(H)

/datum/martial_art/lightning_flow/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return dashing

/datum/martial_art/lightning_flow/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return dashing

/datum/martial_art/lightning_flow/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(dashing)
		return TRUE
	damage(D, A, 5, zone=A.zone_selected)
	return FALSE

/datum/martial_art/lightning_flow/proc/damage(mob/living/target, mob/living/carbon/human/user, amount = 5, stun = FALSE, zone = null)
	target.electrocute_act(amount, user, stun = stun, zone = zone)

/datum/martial_art/lightning_flow/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/target)
	var/list/modifiers = params2list(params)
	if(!can_use(H) || (modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"]))
		return

	if(H.Adjacent(target))//just do the regular action
		return

	if(isitem(target))//don't attack if we're clicking on our inventory
		var/obj/item/thing = target
		if(thing in H.get_all_contents())
			return

	if(H.get_active_held_item()) //abilities need an empty hand
		return

	if(H.a_intent == INTENT_HELP)
		return

	if(H.pulling && H.a_intent == INTENT_GRAB) //don't do anything if you're currently grabbing someone
		return

	if(!(H.mobility_flags & MOBILITY_STAND))//require standing to dash
		return

	if(!COOLDOWN_FINISHED(src, action_cooldown))
		return

	COOLDOWN_START(src, action_cooldown, ACTION_DELAY)
	action_type = H.a_intent
	dash(H, target)

/////////////////////////////////////////////////////////////////
//-------------------dash handling section---------------------//
/////////////////////////////////////////////////////////////////
/datum/martial_art/lightning_flow/proc/dash(mob/living/carbon/human/H, atom/target)
	dashing = TRUE
	if(action_type && action_type == INTENT_DISARM)
		H.Knockdown(2 SECONDS, TRUE, TRUE)
	H.Immobilize(1 SECONDS, TRUE, TRUE) //to prevent canceling the dash
	new /obj/effect/particle_effect/sparks/electricity/short/loud(get_turf(H))
	H.throw_at(target, DASH_RANGE, DASH_SPEED, H, FALSE, callback = CALLBACK(src, PROC_REF(end_dash), H))
		
/datum/martial_art/lightning_flow/proc/end_dash(mob/living/carbon/human/H)
	dashing = FALSE
	H.SetImmobilized(0, TRUE, TRUE) //remove the block on movement

/datum/martial_art/lightning_flow/handle_throw(atom/hit_atom, mob/living/carbon/human/H, datum/thrownthing/throwingdatum)
	if(!dashing || !action_type)
		return FALSE
	if(!hit_atom || !isliving(hit_atom))
		return FALSE
	var/mob/living/target = hit_atom
	dashing = FALSE
	switch(action_type)
		if(INTENT_DISARM)
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target
				if(victim.check_shields(src, 0, "[H]", attack_type = LEAP_ATTACK))
					return FALSE
			H.SetKnockdown(0) //remove the self knockdown from the dropkick
			dropkick(target, H, throwingdatum)
		if(INTENT_GRAB)
			target.grabbedby(H)
		if(INTENT_HARM)
			target.attack_hand(H)
	action_type = null
	return TRUE

/////////////////////////////////////////////////////////////////
//-------------------dropkick section--------------------------//
/////////////////////////////////////////////////////////////////
/datum/martial_art/lightning_flow/proc/dropkick(mob/living/target, mob/living/carbon/human/H, datum/thrownthing/throwingdatum)
	target.visible_message(span_danger("[H] dropkicks [target]!"), span_userdanger("[H] dropkicks you!"))
	target.Knockdown(5 SECONDS)
	damage(target, H, 15, TRUE, BODY_ZONE_CHEST)
	var/destination = throwingdatum.target
	if(get_dist(target, destination) < 5)
		destination = get_ranged_target_turf(get_turf(H), throwingdatum.init_dir, 5)
	target.throw_at(destination, 5, 3, H)
	do_sparks(4, FALSE, target)

/////////////////////////////////////////////////////////////////
//-----------------training related section--------------------//
/////////////////////////////////////////////////////////////////
/mob/living/carbon/human/proc/lightning_flow_help()
	set name = "Focus"
	set desc = "Remember what you are capable of."
	set category = "Lightning Flow"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You focus your mind.</i></b>"

	combined_msg += span_warning("Every intent now dashes first.")
	combined_msg += span_notice("<b>If you collide with someone during a disarm dash, you'll instead dropkick them.</b>")
	combined_msg += span_notice("<b>Your grabs are aggressive.</b>")
	combined_msg += span_notice("<b>Your harm intent does more damage and shocks.</b>")

	to_chat(usr, examine_block(combined_msg.Join("\n")))

/mob/living/carbon/human/proc/lightning_flow_recalibration()
	set name = "Flicker"
	set desc = "Fix click intercepts."
	set category = "Lightning Flow"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You straighten yourself out, ready for more.</i></b>"
	to_chat(usr, examine_block(combined_msg.Join("\n")))

	usr.click_intercept = usr.mind.martial_art


/datum/martial_art/lightning_flow/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	usr.click_intercept = src 
	add_verb(H, recalibration)
	if(ishuman(H))//it's already a human, but it won't let me access physiology for some reason
		var/mob/living/carbon/human/user = H
		user.physiology.punchdamagelow_bonus += 5
		user.physiology.punchdamagehigh_bonus += 5
		user.physiology.punchstunthreshold_bonus += 5
	ADD_TRAIT(H, TRAIT_STRONG_GRABBER, type)

/datum/martial_art/lightning_flow/on_remove(mob/living/carbon/human/H)
	usr.click_intercept = null 
	remove_verb(H, recalibration)
	if(ishuman(H))//it's already a human, but it won't let me access physiology for some reason
		var/mob/living/carbon/human/user = H
		user.physiology.punchdamagelow_bonus -= 5
		user.physiology.punchdamagehigh_bonus -= 5
		user.physiology.punchstunthreshold_bonus -= 5
	REMOVE_TRAIT(H, TRAIT_STRONG_GRABBER, type)
	return ..()

#undef ACTION_DELAY
#undef DASH_RANGE
#undef DASH_SPEED
