
/datum/martial_art/conduit
	name = "Conduit"
	id = MARTIALART_CONDUIT
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/conduit_help
	var/recalibration = /mob/living/carbon/human/proc/conduit_recalibration
	var/datum/action/cooldown/spell/jaunt/wirecrawl/linked_wire
	var/dashing = FALSE
	COOLDOWN_DECLARE(dash_cooldown)
	var/dropkick_cooldown = 5 SECONDS

/datum/martial_art/conduit/can_use(mob/living/carbon/human/H)
	if(H.stat == DEAD || H.incapacitated() || HAS_TRAIT(H, TRAIT_PACIFISM))
		return FALSE
	return isethereal(H)

/datum/martial_art/conduit/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return TRUE  //no disarming, you have a dropkick instead

/datum/martial_art/conduit/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/target)
	var/list/modifiers = params2list(params)
	if(!can_use(H) || (modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"]))
		return

	if(isitem(target))//don't attack if we're clicking on our inventory
		var/obj/item/thing = target
		if(thing in H.get_all_contents())
			return

	if(H.get_active_held_item()) //abilities need an empty hand
		return

	if(H.a_intent == INTENT_DISARM)
		dropkick(H, target)
		return TRUE

/*---------------------------------------------------------------
	here, have a fancy zap punch i guess
---------------------------------------------------------------*/
/datum/martial_art/conduit/harm_act(mob/living/carbon/human/A, mob/living/D)
	tesla_zap(D, 3, 10000, TESLA_MOB_DAMAGE)
	D.electrocute_act(5, stun = FALSE)
	return FALSE

/*---------------------------------------------------------------
	dropkick section
---------------------------------------------------------------*/
/datum/martial_art/conduit/proc/dropkick(mob/living/carbon/human/H, atom/target)
	if(dashing)
		return

	if(!COOLDOWN_FINISHED(src, dash_cooldown))
		return

	COOLDOWN_START(src, dash_cooldown, dropkick_cooldown)
	H.Knockdown(1 SECONDS, TRUE, TRUE)
	H.Immobilize(1 SECONDS, TRUE, TRUE)
	dashing = TRUE
	new /obj/effect/particle_effect/sparks(get_turf(H))
	H.throw_at(target, 3, 2, H, FALSE, TRUE)

/datum/martial_art/conduit/handle_throw(atom/hit_atom, mob/living/carbon/human/A)
	if(!dashing)
		return FALSE
	dashing = FALSE
	if(hit_atom && isliving(hit_atom))
		var/mob/living/L = hit_atom
		L.visible_message("<span class ='danger'>[A] dropkicks [L]!</span>", "<span class ='userdanger'>[A] dropkicks you!</span>")
		L.Knockdown(10 SECONDS)
		L.throw_at(get_edge_target_turf(L, get_dir(get_turf(A), get_turf(L))), 5, 3, A, TRUE)
		L.electrocute_act(10, stun = FALSE)
		do_sparks(4, FALSE, A)
		A.SetKnockdown(0)
		sleep(1)//Runtime prevention (infinite bump() calls on hulks)
		A.SetImmobilized(0)
		return TRUE
	return FALSE
/*---------------------------------------------------------------
	training related section
---------------------------------------------------------------*/
/mob/living/carbon/human/proc/conduit_help()//negative flavour, i just wanted to add something to attach wirecrawling to
	set name = "Focus"
	set desc = "Remember what you are capable of."
	set category = "Conduit"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You focus your mind.</i></b>"

	combined_msg += span_warning("Your disarm has been replaced with a short cooldown dropkick.")
	combined_msg += span_warning("Your punches electrocute everyone nearby.")
	combined_msg += span_notice("<b>You are immune to getting shocked.</b>")
	combined_msg += span_notice("<b>You can travel through wires using your wirecrawl ability.</b>")

	to_chat(usr, examine_block(combined_msg.Join("\n")))

/mob/living/carbon/human/proc/conduit_recalibration()
	set name = "Flicker"
	set desc = "Fix click intercepts."
	set category = "Conduit"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You straighten yourself out, ready for more.</i></b>"
	to_chat(usr, examine_block(combined_msg.Join("\n")))

	usr.click_intercept = usr.mind.martial_art


/datum/martial_art/conduit/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	usr.click_intercept = src 
	add_verb(H, recalibration)
	ADD_TRAIT(H, TRAIT_SHOCKIMMUNE, type) //walk through that fire all you like, hope you don't care about your clothes
	if(!linked_wire)
		linked_wire = new
		linked_wire.Grant(H)

/datum/martial_art/conduit/on_remove(mob/living/carbon/human/H)
	usr.click_intercept = null 
	remove_verb(H, recalibration)
	REMOVE_TRAIT(H, TRAIT_SHOCKIMMUNE, type)
	if(linked_wire)
		linked_wire.Remove(H)
	return ..()

