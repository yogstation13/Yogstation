
/*
	Blunt/Bone wounds
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons

/datum/wound_pregen_data/bone
	abstract = TRUE
	required_limb_biostate = BIO_BONE

	required_wounding_types = list(WOUND_BLUNT)

	wound_series = WOUND_SERIES_BONE_BLUNT_BASIC

/datum/wound/blunt/bone
	name = "Blunt (Bone) Wound"
	wound_flags = (ACCEPTS_GAUZE)

	default_scar_file = BONE_SCAR_FILE

	/// Have we been bone gel'd?
	var/gelled
	/// Have we been taped?
	var/taped
	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown
	/// If this is a chest wound and this is set, we have this chance to cough up blood when hit in the chest
	var/internal_bleeding_chance = 0
	/// Counts which tick we're on for footsteps
	var/footstep_counter = 0

/*
	Overwriting of base procs
*/
/datum/wound/blunt/bone/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	if(limb.held_index && victim.get_item_for_held_index(limb.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(limb.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message(
				span_danger("[victim] drops [I] in shock!"),
				span_boldwarning("The force on your [limb.plaintext_zone] causes you to drop [I]!"),
				vision_distance = COMBAT_MESSAGE_RANGE,

			)

	update_inefficiencies()
	return ..()

/datum/wound/blunt/bone/set_victim(new_victim)

	if (victim)
		UnregisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
		UnregisterSignal(victim, COMSIG_MOB_ITEM_ATTACK)
		UnregisterSignal(victim, COMSIG_CARBON_STEP)
		UnregisterSignal(victim, COMSIG_CARBON_ATTEMPT_BREATHE)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(attack_with_hurt_hand))
		RegisterSignal(new_victim, COMSIG_MOB_ITEM_ATTACK, PROC_REF(weapon_attack_with_hurt_hand))
		RegisterSignal(new_victim, COMSIG_CARBON_STEP, PROC_REF(carbon_step))
		RegisterSignal(new_victim, COMSIG_CARBON_ATTEMPT_BREATHE, PROC_REF(breath))

	return ..()

/datum/wound/blunt/bone/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	limp_chance = 0
	QDEL_NULL(active_trauma)
	return ..()

/datum/wound/blunt/bone/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if(active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	var/is_bone_limb = ((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
	if(!gelled || (!taped && !is_bone_limb))
		return

	regen_ticks_current++
	if(victim.body_position == LYING_DOWN)
		if(SPT_PROB(30, seconds_per_tick))
			regen_ticks_current += 1
		if(victim.IsSleeping() && SPT_PROB(30, seconds_per_tick))
			regen_ticks_current += 1

	if(!is_bone_limb && SPT_PROB(severity * 1.5, seconds_per_tick))
		victim.take_bodypart_damage(rand(1, severity * 2), wound_bonus=CANT_WOUND)
		victim.stamina.adjust(-rand(2, severity * 2.5))
		if(prob(33))
			to_chat(victim, span_danger("You feel a sharp pain in your body as your bones are reforming!"))

/// If we're a human who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/blunt/bone/proc/attack_with_hurt_hand(datum/source, atom/target, proximity)
	if(!proximity || severity <= WOUND_SEVERITY_MODERATE)
		return NONE
	if(limb.body_zone != BODY_ZONE_CHEST && victim.get_active_hand() != limb)
		return NONE
	var/weapon = victim.get_active_held_item()
	if(!weapon && ((victim.istate & ISTATE_HARM)|| !ismob(target)))
		return NONE

	// With a severe or critical wound, you have a 15% or 30% chance to proc pain on hit
	if(!prob((severity - 1) * 15))
		return NONE

	var/painless = !victim.can_feel_pain() || victim.has_status_effect(/datum/status_effect/determined)
	// And you have a 70% or 50% chance to actually land the blow, respectively
	if(prob(70 - 20 * (severity - 1)))
		to_chat(victim, span_userdanger("The fracture in your [limb.plaintext_zone] [painless ? "jostles uncomfortably" : "shoots with pain"] as you strike [target]!"))
		victim.apply_damage(8, BRUTE, limb)
		return NONE

	victim.visible_message(
		span_danger("[victim] weakly strikes [target] with [victim.p_their()] broken [limb.plaintext_zone], recoiling from pain!"),
		span_userdanger("You [weapon ? "weakly" : "fail"] to strike [target] as the fracture in your [limb.plaintext_zone] [painless ? "jostles uncomfortably" : "lights up in unbearable pain"]!"),
		vision_distance = COMBAT_MESSAGE_RANGE,

	)
	victim.Stun(0.5 SECONDS)
	victim.apply_damage(10, BRUTE, limb)
	victim.pain_emote(pick("wince", "grimace", "flinch"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/wound/blunt/bone/proc/weapon_attack_with_hurt_hand(datum/source, mob/target, mob/user, params)
	SIGNAL_HANDLER

	return attack_with_hurt_hand(source, target, TRUE)

/datum/wound/blunt/bone/proc/carbon_step(datum/source)
	SIGNAL_HANDLER

	if(limb.body_zone != BODY_ZONE_L_LEG && limb.body_zone != BODY_ZONE_R_LEG)
		return
	if(victim.body_position == LYING_DOWN || victim.buckled) // wheelchair = fine, being pulled = not fine
		return
	if(victim.has_status_effect(/datum/status_effect/determined))
		return

	footstep_counter += 1
	if(footstep_counter >= 8)
		footstep_counter = 1

	if((limb.current_gauze ? limb.current_gauze.splint_factor : 1) <= 0.75 || !victim.can_feel_pain())
		return
	if(limb.body_zone == SELECT_LEFT_OR_RIGHT(footstep_counter, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		return
	var/mod = 1
	switch(victim.m_intent)
		if(MOVE_INTENT_RUN)
			mod = 1.5
		if(MOVE_INTENT_WALK)
			mod = 1
		if(MOVE_INTENT_SPRINT)
			mod = 2
	if(!prob(severity * mod * 20))
		return
	if(SEND_SIGNAL(victim, COMSIG_CARBON_PAINED_STEP, limb, footstep_counter) & STOP_PAIN)
		return

	to_chat(victim, span_danger("Your [limb.plaintext_zone] [pick("aches", "pangs", "stings")] as you take a step!"))
	victim.sharp_pain(limb.body_zone, severity * 6, BRUTE, 10 SECONDS)


/datum/wound/blunt/bone/proc/breath(...)
	SIGNAL_HANDLER

	if(limb.body_zone != BODY_ZONE_CHEST)
		return NONE
	if(!victim.can_feel_pain() || (limb.current_gauze && limb.current_gauze.splint_factor <= 0.75))
		return NONE
	var/pain_prob = min(75, 20 * severity * (victim.body_position == LYING_DOWN ? 1.5 : 1))
	if(!prob(pain_prob))
		return NONE
	to_chat(victim, span_danger("You wince as you take a deep breath, feeling the pain in your ribs!"))
	var/breath_prob = min(50, 15 * severity * (victim.body_position == LYING_DOWN ? 1.2 : 1))
	if(prob(breath_prob))
		victim.pain_emote("gasp")
		. = BREATHE_SKIP_BREATH
	else
		victim.pain_emote("wince")
		. = NONE
	victim.sharp_pain(BODY_ZONE_CHEST, rand(5, 10), BRUTE, 10 SECONDS)
	return .

/datum/wound/blunt/bone/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction, damage_source)
	if(victim.stat == DEAD || wounding_dmg < WOUND_MINIMUM_DAMAGE || wounding_type == WOUND_BURN)
		return
	if(limb.body_zone != BODY_ZONE_CHEST || !limb.can_bleed() || !prob(internal_bleeding_chance))
		return
	if(limb.current_gauze?.splint_factor)
		wounding_dmg *= (1 - limb.current_gauze.splint_factor)
	var/blood_bled = sqrt(wounding_dmg) * (severity * 0.75) * pick(0.75, 1, 1.25) // melbert todo : push upstream
	switch(blood_bled)
		if(7 to 13)
			victim.visible_message(
				span_smalldanger("A thin stream of blood drips from [victim]'s mouth from the blow to [victim.p_their()] chest."),
				span_danger("You cough up a bit of blood from the blow to your chest."),
				vision_distance = COMBAT_MESSAGE_RANGE,

			)
		if(14 to 19)
			victim.visible_message(
				span_smalldanger("Blood spews out of [victim]'s mouth from the blow to [victim.p_their()] chest!"),
				span_danger("You spit out a string of blood from the blow to your chest!"),
				vision_distance = COMBAT_MESSAGE_RANGE,

			)
		if(20 to INFINITY)
			victim.visible_message(
				span_danger("Blood spurts out of [victim]'s mouth from the blow to [victim.p_their()] chest!"),
				span_bolddanger("You choke up on a spray of blood from the blow to your chest!"),
				vision_distance = COMBAT_MESSAGE_RANGE,

			)
	victim.bleed(blood_bled, TRUE)
	if(blood_bled >= 14)
		victim.do_splatter_effect(attack_direction)
		victim.add_splatter_floor(get_step(victim.loc, victim.dir))
		victim.blood_particles(amount = 1 * round(blood_bled / 14, 1))

/datum/wound/blunt/bone/modify_desc_before_span(desc)
	. = ..()

	if (!limb.current_gauze)
		if(taped)
			. += ", [span_notice("and appears to be reforming itself under some surgical tape!")]"
		else if(gelled)
			. += ", [span_notice("with fizzing flecks of blue bone gel sparking off the bone!")]"

/*
	New common procs for /datum/wound/blunt/bone/
*/

/datum/wound/blunt/bone/get_scar_file(obj/item/bodypart/scarred_limb, add_to_scars)
	if (scarred_limb.biological_state & BIO_BONE && (!(scarred_limb.biological_state & BIO_FLESH))) // only bone
		return BONE_SCAR_FILE
	else if (scarred_limb.biological_state & BIO_FLESH && (!(scarred_limb.biological_state & BIO_BONE)))
		return FLESH_SCAR_FILE

	return ..()

/datum/wound_pregen_data/bone/rib_break
	abstract = FALSE
	wound_path_to_generate = /datum/wound/blunt/bone/rib_break
	required_limb_biostate = BIO_BONE
	threshold_minimum = 20
	viable_zones = list(BODY_ZONE_CHEST)

/datum/wound/blunt/bone/rib_break
	// You may notice higher severity bone wounds are fractures on their own
	// So this one seems a bit out of place, seeing as it's a generic "rib fracture" when more specific ones exist
	// This is here as the chest has no moderate wound (as it's not jointed, and can't dislocate)
	// Flavor wise imagine it as one rib being broken rather than multiple
	name = "Fractured Rib"
	desc = "One of the patient's ribs has been fractured, causing sharp pain and difficulty breathing."
	treat_text = "Repair surgically. In the event of an emergency, \
		one can also apply bone gel and surgical tape to the affected area to fix over time."
	treat_text_short = "Repair surgically, or apply bone gel and surgical tape."
	occur_text = "cracks and bruises"
	examine_desc = ""

	severity = WOUND_SEVERITY_MODERATE
	threshold_penalty = 20
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/rib_break
	scar_keyword = "dislocate"
	internal_bleeding_chance = 25
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR)
	regen_ticks_needed = 180 // ticks every 2 seconds, 360 seconds, so roughly 6 minutes default

	simple_treat_text = "<b>Bandaging</b> the wound will reduce its impact until treated \
		<b>surgically</b> or via bone gel and surgical tape."
	homemade_treat_text = "<b>Bone gel and surgical tape</b> may be applied directly to the wound, \
		though this is quite difficult for most people to do so individually \
		unless they've dosed themselves with one or more <b>painkillers</b>."

/datum/wound/blunt/bone/rib_break/get_self_check_description(mob/user)
	if(locate(/datum/wound/bleed_internal) in limb.wounds)
		return null
	return span_warning("It feels tense to the touch.") // same as IB!

/// Joint Dislocation (Moderate Blunt)
/datum/wound/blunt/bone/moderate
	name = "Joint Dislocation"
	undiagnosed_name = "Dislocation"
	desc = "Patient's limb has been unset from socket, causing pain and reduced motor function."
	treat_text = "Apply Bonesetter to the affected limb. \
		Manual relocation by via an aggressive grab and a tight hug to the affected limb may also suffice."
	treat_text_short = "Apply Bonesetter, or manually relocate the limb."
	examine_desc = "is awkwardly janked out of place"
	occur_text = "janks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.3
	limp_slowdown = 3
	limp_chance = 50
	threshold_penalty = 15
	treatable_tools = list(TOOL_BONESET)
	status_effect_type = /datum/status_effect/wound/blunt/bone/moderate
	scar_keyword = "dislocate"

	simple_treat_text = "<b>Bandaging</b> the wound will reduce its impact until treated with a bonesetter. \
		Most commonly, it is treated by aggressively grabbing someone and helpfully wrenching the limb in place, \
		though there's room for malfeasance when doing this."
	homemade_treat_text = "Besides bandaging and wrenching, <b>bone setters</b> \
		can be printed in lathes and utilized on oneself at the cost of great pain. \
		As a last resort, <b>crushing</b> the patient with a <b>firelock</b> has sometimes been noted to fix their dislocated limb."

/datum/wound_pregen_data/bone/dislocate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/moderate

	required_limb_biostate = BIO_JOINTED

	threshold_minimum = 35

/datum/wound/blunt/bone/moderate/Destroy()
	if(victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	return ..()

/datum/wound/blunt/bone/moderate/set_victim(new_victim)

	if (victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_LIVING_DOORCRUSHED, PROC_REF(door_crush))

	return ..()

/datum/wound/blunt/bone/moderate/get_self_check_description(mob/user)
	return span_warning("It feels dislocated!")

/// Getting smushed in an airlock/firelock is a last-ditch attempt to try relocating your limb
/datum/wound/blunt/bone/moderate/proc/door_crush()
	SIGNAL_HANDLER
	if(prob(40))
		victim.visible_message(span_danger("[victim]'s dislocated [limb.plaintext_zone] pops back into place!"), span_userdanger("Your dislocated [limb.plaintext_zone] pops back into place! Ow!"))
		remove_wound()

/datum/wound/blunt/bone/moderate/try_handling(mob/living/user)
	if(user.usable_hands <= 0 || user.pulling != victim)
		return FALSE
	if(!isnull(user.hud_used?.zone_select) && user.zone_selected != limb.body_zone)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, span_warning("You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [lowertext(undiagnosed_name || name)]!"))
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message(span_danger("[user] begins twisting and straining [victim]'s dislocated [limb.plaintext_zone]!"), span_notice("You begin twisting and straining [victim]'s dislocated [limb.plaintext_zone]..."), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] begins twisting and straining your dislocated [limb.plaintext_zone]!"))
		if(!(user.istate & ISTATE_HARM))
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/// If someone is snapping our dislocated joint back into place by hand with an aggro grab and help intent
/datum/wound/blunt/bone/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	if(prob(65))
		user.visible_message(span_danger("[user] snaps [victim]'s dislocated [limb.plaintext_zone] back into place!"), span_notice("You snap [victim]'s dislocated [limb.plaintext_zone] back into place!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] snaps your dislocated [limb.plaintext_zone] back into place!"))
		victim.pain_emote("scream")
		victim.apply_damage(20, BRUTE, limb, wound_bonus = CANT_WOUND)
		qdel(src)
	else
		user.visible_message(span_danger("[user] wrenches [victim]'s dislocated [limb.plaintext_zone] around painfully!"), span_danger("You wrench [victim]'s dislocated [limb.plaintext_zone] around painfully!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] wrenches your dislocated [limb.plaintext_zone] around painfully!"))
		victim.apply_damage(10, BRUTE, limb, wound_bonus = CANT_WOUND)
		chiropractice(user)

/// If someone is snapping our dislocated joint into a fracture by hand with an aggro grab and harm or disarm intent
/datum/wound/blunt/bone/moderate/proc/malpractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	if(prob(65))
		user.visible_message(span_danger("[user] snaps [victim]'s dislocated [limb.plaintext_zone] with a sickening crack!"), span_danger("You snap [victim]'s dislocated [limb.plaintext_zone] with a sickening crack!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] snaps your dislocated [limb.plaintext_zone] with a sickening crack!"))
		victim.pain_emote("scream")
		victim.apply_damage(25, BRUTE, limb, wound_bonus = 30)
	else
		user.visible_message(span_danger("[user] wrenches [victim]'s dislocated [limb.plaintext_zone] around painfully!"), span_danger("You wrench [victim]'s dislocated [limb.plaintext_zone] around painfully!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] wrenches your dislocated [limb.plaintext_zone] around painfully!"))
		victim.apply_damage(10, BRUTE, limb, wound_bonus = CANT_WOUND)
		malpractice(user)


/datum/wound/blunt/bone/moderate/treat(obj/item/I, mob/user)
	var/scanned = HAS_TRAIT(src, TRAIT_WOUND_SCANNED)
	var/self_penalty_mult = user == victim ? 1.5 : 1
	var/scanned_mult = scanned ? 0.5 : 1
	var/treatment_delay = base_treat_time * self_penalty_mult * scanned_mult

	if(victim == user)
		victim.visible_message(span_danger("[user] begins [scanned ? "expertly" : ""] resetting [victim.p_their()] [limb.plaintext_zone] with [I]."), span_warning("You begin resetting your [limb.plaintext_zone] with [I][scanned ? ", keeping the holo-image's indications in mind" : ""]..."))
	else
		user.visible_message(span_danger("[user] begins [scanned ? "expertly" : ""] resetting [victim]'s [limb.plaintext_zone] with [I]."), span_notice("You begin resetting [victim]'s [limb.plaintext_zone] with [I][scanned ? ", keeping the holo-image's indications in mind" : ""]..."))

	if(!do_after(user, treatment_delay, target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return

	if(victim == user)
		limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message(span_danger("[user] finishes resetting [victim.p_their()] [limb.plaintext_zone]!"), span_userdanger("You reset your [limb.plaintext_zone]!"))
	else
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		user.visible_message(span_danger("[user] finishes resetting [victim]'s [limb.plaintext_zone]!"), span_nicegreen("You finish resetting [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] resets your [limb.plaintext_zone]!"))

	victim.pain_emote("scream")
	qdel(src)

/*
	Severe (Hairline Fracture)
*/

/datum/wound/blunt/bone/severe
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Repair surgically. In the event of an emergency, an application of bone gel over the affected area will fix over time. \
		A splint or sling of medical gauze can also be used to prevent the fracture from worsening."
	treat_text_short = "Repair surgically, or apply bone gel. A splint or gauze sling can also be used."
	examine_desc = "appears grotesquely swollen, jagged bumps hinting at chips in the bone"
	occur_text = "sprays chips of bone and develops a nasty looking bruise"

	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 60
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/severe
	scar_keyword = "bluntsevere"
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	internal_bleeding_chance = 40
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR)
	regen_ticks_needed = 120 // ticks every 2 seconds, 240 seconds, so roughly 4 minutes default

	simple_treat_text = "<b>Bandaging</b> the wound will reduce its impact until treated \
		<b>surgically</b> or via bone gel and surgical tape."
	homemade_treat_text = "<b>Bone gel and surgical tape</b> may be applied directly to the wound, \
		though this is quite difficult for most people to do so individually \
		unless they've dosed themselves with one or more <b>painkillers</b>."


/datum/wound_pregen_data/bone/hairline
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/severe

	threshold_minimum = 60

/// Compound Fracture (Critical Blunt)
/datum/wound/blunt/bone/critical
	name = "Compound Fracture"
	undiagnosed_name = "Compound Fracture" // you can tell it's a compound fracture at a glance because of a skin breakage
	desc = "Patient's bones have suffered multiple fractures, \
		couped with a break in the skin, causing significant pain and near uselessness of limb."
	treat_text = "Immediately bind the affected limb with gauze or a splint. Repair surgically. \
		In the event of an emergency, bone gel and surgical tape can be applied to the affected area to fix over a long period of time."
	treat_text_short = "Repair surgically, or apply bone gel and surgical tape. A splint or gauze sling should also be used."
	examine_desc = "is thoroughly pulped and cracked, exposing shards of bone to open air"
	occur_text = "cracks apart, exposing broken bones to open air"

	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 2.5
	limp_slowdown = 7
	limp_chance = 70
	sound_effect = 'sound/effects/wounds/crack2.ogg'
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/critical
	scar_keyword = "bluntcritical"
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	internal_bleeding_chance = 60
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR)
	regen_ticks_needed = 240 // ticks every 2 seconds, 480 seconds, so roughly 8 minutes default

	simple_treat_text = "<b>Bandaging</b> the wound will slightly reduce its impact until treated \
		<b>surgically</b> or via bone gel and surgical tape."
	homemade_treat_text = "Although this is extremely difficult and slow to function, \
		<b>Bone gel and surgical tape</b> may be applied directly to the wound, \
		though this is nigh-impossible for most people to do so individually \
		unless they've dosed themselves with one or more <b>painkillers</b>."

/datum/wound_pregen_data/bone/compound
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/critical

	threshold_minimum = 115

// doesn't make much sense for "a" bone to stick out of your head
/datum/wound/blunt/bone/critical/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/old_wound = null, smited = FALSE, attack_direction = null, wound_source = "Unknown")
	if(L.body_zone == BODY_ZONE_HEAD)
		occur_text = "splits open, exposing a bare, cracked skull through the flesh and blood"
		examine_desc = "has an unsettling indent, with bits of skull poking out"
	. = ..()

/// if someone is using bone gel on our wound
/datum/wound/blunt/bone/proc/gel(obj/item/stack/medical/bone_gel/I, mob/user)
	// skellies get treated nicer with bone gel since their "reattach dismembered limbs by hand" ability sucks when it's still critically wounded
	if((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
		return skelly_gel(I, user)

	if(gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already coated with bone gel!"))
		return TRUE

	user.visible_message(span_danger("[user] begins hastily applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin hastily applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone], disregarding the warning label..."))

	if(!do_after(user, base_treat_time * 1.5 * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	I.use(1)
	victim.pain_emote("scream")
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [I] to your [limb.plaintext_zone], and you can feel the bones exploding with pain as they begin melting and reforming!"))
	else
		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			var/painkiller_bonus = 50 * (1 - (victim.pain_controller?.pain_modifier || 1))
			if(prob(25 + (20 * (severity - 2)) - painkiller_bonus)) // 25%/45% chance to fail self-applying with severe and critical wounds, modded by drunkenness
				victim.visible_message(span_danger("[victim] fails to finish applying [I] to [victim.p_their()] [limb.plaintext_zone], passing out from the pain!"), span_notice("You pass out from the pain of applying [I] to your [limb.plaintext_zone] before you can finish!"))
				victim.AdjustUnconscious(5 SECONDS)
				return TRUE
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], grimacing from the pain!"), span_notice("You finish applying [I] to your [limb.plaintext_zone], and your bones explode in pain!"))

	limb.receive_damage(25, wound_bonus=CANT_WOUND)
	victim.stamina.adjust(-100)
	gelled = TRUE
	return TRUE

/// skellies are less averse to bone gel, since they're literally all bone
/datum/wound/blunt/bone/proc/skelly_gel(obj/item/stack/medical/bone_gel/I, mob/user)
	if(gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already coated with bone gel!"))
		return

	user.visible_message(span_danger("[user] begins applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return

	I.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [I] to your [limb.plaintext_zone], and you feel a funny fizzy tickling as they begin to reform!"))
	else
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], emitting a funny fizzing sound!"), span_notice("You finish applying [I] to your [limb.plaintext_zone], and feel a funny fizzy tickling as the bone begins to reform!"))

	gelled = TRUE
	processes = TRUE
	return TRUE

/// if someone is using surgical tape on our wound
/datum/wound/blunt/bone/proc/tape(obj/item/stack/sticky_tape/surgical/I, mob/user)
	if(!gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] must be coated with bone gel to perform this emergency operation!"))
		return TRUE
	if(taped)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already wrapped in [I.name] and reforming!"))
		return TRUE

	user.visible_message(span_danger("[user] begins applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if(victim == user)
		regen_ticks_needed *= 1.5

	I.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_green("[user] finishes applying [I] to your [limb.plaintext_zone], you immediately begin to feel your bones start to reform!"))
	else
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], !"), span_green("You finish applying [I] to your [limb.plaintext_zone], and you immediately begin to feel your bones start to reform!"))

	taped = TRUE
	processes = TRUE
	return TRUE

/datum/wound/blunt/bone/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/bone_gel))
		return gel(I, user)
	else if(istype(I, /obj/item/stack/sticky_tape/surgical))
		return tape(I, user)

/datum/wound/blunt/bone/get_scanner_description(mob/user)
	. = ..()

	. += "<div class='ml-3'>"

	if(severity > WOUND_SEVERITY_MODERATE)
		if(!gelled)
			. += "Recommended Treatment: \
				Operate where possible. In the event of emergency, apply bone gel directly to injured limb. \
				Creatures of pure bone don't seem to mind bone gel application nearly as much as fleshed individuals. \
				Surgical tape will also be unnecessary.\n"

	if(limb.body_zone == BODY_ZONE_HEAD)
		. += "Cranial Trauma Detected: \
			Patient will suffer random bouts of [severity == WOUND_SEVERITY_SEVERE ? "mild" : "severe"] brain traumas until bone is repaired."
	else if(limb.body_zone == BODY_ZONE_CHEST && !HAS_TRAIT(victim, TRAIT_NOBLOOD))
		. += "Ribcage Trauma Detected: \
			Further trauma to chest is likely to worsen internal bleeding until bone is repaired."
	. += "</div>"
