#define ACTION_DELAY (0.8 SECONDS) //regular punch delay
#define DASH_RANGE 3
#define DASH_SPEED 2


/datum/martial_art/lightning_flow
	name = "Lightning Flow"
	id = MARTIALART_LIGHTNINGFLOW
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/lightning_flow_help
	martial_traits = list(TRAIT_STRONG_GRABBER, TRAIT_NO_PUNCH_STUN)
	var/dashing = FALSE
	COOLDOWN_DECLARE(action_cooldown)
	var/list/action_modifiers = list()

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
	damage(D, A, 5, A.zone_selected)
	return FALSE

/datum/martial_art/lightning_flow/proc/damage(mob/living/target, mob/living/carbon/human/user, amount = 5, zone = null)
	var/electric_armour = target.run_armor_check(zone, ELECTRIC)
	var/melee_armour = target.run_armor_check(zone, MELEE)
	var/final_armour = (electric_armour + melee_armour) / 2
	target.apply_damage(amount, BURN, zone, final_armour)
	if(ishuman(target))
		var/mob/living/carbon/human/flicker = target
		flicker.electrocution_animation(4 SECONDS)

/datum/martial_art/lightning_flow/proc/on_click(mob/living/carbon/human/H, atom/target, params)
	var/list/modifiers = params2list(params)
	if(!can_use(H) || !H.combat_mode || modifiers[SHIFT_CLICK] || modifiers[ALT_CLICK] || (modifiers[CTRL_CLICK] && H.CanReach(target))) // only intercept ranged grabs
		return

	if(H.Adjacent(target))//just do the regular action
		return
	
	if(H.in_throw_mode) // so you can throw people properly
		return

	if(isitem(target))//don't attack if we're clicking on our inventory
		var/obj/item/thing = target
		if(thing in H.get_all_contents())
			return

	if(H.get_active_held_item()) //abilities need an empty hand
		return

	if(!(H.mobility_flags & MOBILITY_STAND))//require standing to dash
		return

	if(!COOLDOWN_FINISHED(src, action_cooldown))
		return

	COOLDOWN_START(src, action_cooldown, ACTION_DELAY)
	action_modifiers = modifiers
	dash(H, target, modifiers)
	return COMSIG_MOB_CANCEL_CLICKON

/////////////////////////////////////////////////////////////////
//-------------------dash handling section---------------------//
/////////////////////////////////////////////////////////////////
/datum/martial_art/lightning_flow/proc/dash(mob/living/carbon/human/H, atom/target)
	dashing = TRUE
	if(H.pulling) //if you're currently grabbing someone, let go
		H.stop_pulling()
	if(action_modifiers[RIGHT_CLICK])
		H.Knockdown(2 SECONDS, TRUE)
	H.Immobilize(1 SECONDS, TRUE, TRUE) //to prevent canceling the dash
	new /obj/effect/particle_effect/sparks/electricity/short/loud(get_turf(H))
	H.throw_at(target, DASH_RANGE, DASH_SPEED, H, FALSE, callback = CALLBACK(src, PROC_REF(end_dash), H))
		
/datum/martial_art/lightning_flow/proc/end_dash(mob/living/carbon/human/H)
	dashing = FALSE
	H.SetImmobilized(0, TRUE, TRUE) //remove the block on movement

/datum/martial_art/lightning_flow/handle_throw(atom/hit_atom, mob/living/carbon/human/H, datum/thrownthing/throwingdatum)
	if(!dashing)
		return FALSE
	if(!hit_atom || !isliving(hit_atom))
		return FALSE
	var/mob/living/target = hit_atom
	dashing = FALSE
	if(action_modifiers[RIGHT_CLICK])
		var/mob/living/carbon/human/victim = target
		if(victim.check_shields(src, 0, "[H]", attack_type = LEAP_ATTACK))
			return FALSE
		dropkick(target, H, throwingdatum)
	else if(action_modifiers[CTRL_CLICK])
		target.grabbedby(H)
	else
		target.attack_hand(H)
	action_modifiers = list()
	return TRUE

/////////////////////////////////////////////////////////////////
//-------------------dropkick section--------------------------//
/////////////////////////////////////////////////////////////////
/datum/martial_art/lightning_flow/proc/dropkick(mob/living/target, mob/living/carbon/human/H, datum/thrownthing/throwingdatum)
	target.visible_message(span_danger("[H] dropkicks [target]!"), span_userdanger("[H] dropkicks you!"))
	do_sparks(4, FALSE, target)

	target.Knockdown(5 SECONDS)
	H.SetKnockdown(0) //remove the self knockdown from the dropkick
	H.set_resting(FALSE)
	damage(target, H, 15, BODY_ZONE_CHEST)

	var/destination = throwingdatum.target
	if(get_dist(target, destination) < 5)
		destination = get_ranged_target_turf(get_turf(H), throwingdatum.init_dir, 5)
	target.throw_at(destination, 5, 3, H)

/////////////////////////////////////////////////////////////////
//-----------------training related section--------------------//
/////////////////////////////////////////////////////////////////
/mob/living/carbon/human/proc/lightning_flow_help()
	set name = "Focus"
	set desc = "Remember what you are capable of."
	set category = "Lightning Flow"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You focus your mind.</i></b>"

	combined_msg += span_warning("Punches, shoves, and grabs now dash first while combat mode is enabled.")
	combined_msg += span_notice("<b>If you collide with someone during a shove dash, you'll instead dropkick them.</b>")
	combined_msg += span_notice("<b>Your grabs are aggressive.</b>")
	combined_msg += span_notice("<b>Your punch does more damage and shocks.</b>")

	to_chat(usr, examine_block(combined_msg.Join("\n")))


/datum/martial_art/lightning_flow/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	if(ishuman(H))//it's already a human, but it won't let me access physiology for some reason
		var/mob/living/carbon/human/user = H
		user.physiology.punchdamagelow_bonus += 5
		user.physiology.punchdamagehigh_bonus += 5

/datum/martial_art/lightning_flow/on_remove(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_MOB_CLICKON)
	if(ishuman(H))//it's already a human, but it won't let me access physiology for some reason
		var/mob/living/carbon/human/user = H
		user.physiology.punchdamagelow_bonus -= 5
		user.physiology.punchdamagehigh_bonus -= 5
	return ..()

#undef ACTION_DELAY
#undef DASH_RANGE
#undef DASH_SPEED
