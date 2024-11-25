//ported directly from Bee, cleaned up and updated to function with TG. thanks bee!

#define TAIL_SWEEP_COMBO "DH"
#define FACE_SCRATCH_COMBO "HH"
#define JUGULAR_CUT_COMBO "HD"
#define TAIL_GRAB_COMBO "DDG"

/datum/martial_art/tribal_claw
	name = "Tribal Claw"
	id = MARTIALART_TRIBALCLAW
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/tribal_claw_help
	var/list/tribal_traits = list(TRAIT_HARDLY_WOUNDED, TRAIT_HARD_SOLES)

	smashes_tables = TRUE //:3

	block_chance = 60  //you can use throw mode to block melee attacks... sometimes
	//originally wanted to do inverse correlation but it donbt work :pensive:

/datum/armor/scales
	melee = 40
	bullet = 40
	laser = 40
	wound = 50

/datum/martial_art/tribal_claw/teach(mob/living/carbon/human/target, make_temporary = FALSE)
	. = ..()
	if(!.)
		return
	target.add_traits(tribal_traits)
	target.set_armor(target.get_armor().add_other_armor(/datum/armor/scales))

/datum/martial_art/tribal_claw/on_remove(mob/living/carbon/human/target)
	target.set_armor(target.get_armor().subtract_other_armor(/datum/armor/scales))
	REMOVE_TRAITS_IN(target, tribal_traits)
	. = ..()

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if(findtext(streak,TAIL_SWEEP_COMBO))
		streak = ""
		tailSweep(attacker,defender)
		return TRUE
	if(findtext(streak,FACE_SCRATCH_COMBO))
		streak = ""
		faceScratch(attacker,defender)
		return TRUE
	if(findtext(streak,JUGULAR_CUT_COMBO))
		streak = ""
		jugularCut(attacker,defender)
		return TRUE
	if(findtext(streak,TAIL_GRAB_COMBO))
		streak = ""
		tailGrab(attacker,defender)
		return TRUE
	return FALSE

//Tail Sweep, triggers an effect similar to Alien Queen's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if(attacker == current_target)
		return
	log_combat(attacker, defender, "tail sweeped(Tribal Claw)", name)
	defender.visible_message(span_warning("[attacker] sweeps [defender] off their legs with their tail!"), \
						span_userdanger("[attacker] sweeps you off your legs with their tail!"))
	var/static/datum/action/cooldown/spell/aoe/repulse/martial/lizard/tail_sweep = new
	tail_sweep.cast(attacker)

//Face Scratch, deals 30 brute to head(reduced by armor), blurs the defender's vision and gives them the confused effect for a short time.
/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	var/def_check = defender.getarmor(BODY_ZONE_HEAD, MELEE)
	log_combat(attacker, defender, "face scratched (Tribal Claw)", name)
	defender.visible_message(span_warning("[attacker] scratches [defender]'s face with their claws!"), \
						span_userdanger("[attacker] scratches your face with their claws!"))
	defender.apply_damage(30, BRUTE, BODY_ZONE_HEAD, def_check)
	defender.adjust_confusion(5 SECONDS)
	defender.adjust_eye_blur(5 SECONDS)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
	playsound(get_turf(defender), 'sound/weapons/slash.ogg', 50, 1, -1)

/*
Jugular Cut
Deals 15 damage to the target plus 10 seconds of oxygen loss and 10 oxyloss, with an open laceration
If the target is T3 grabbed or sleeping, instead deal 60 damage with a weeping avulsion alongside the previous.
*/
/datum/martial_art/tribal_claw/proc/jugularCut(mob/living/carbon/attacker, mob/living/carbon/defender)
	var/def_check = defender.getarmor(BODY_ZONE_HEAD, MELEE)
	var/obj/item/bodypart/head = defender.get_bodypart(BODY_ZONE_HEAD)

	var/wound_type = /datum/wound/slash/flesh/severe
	var/critical_wound_type = /datum/wound/slash/flesh/critical
	var/datum/wound/slash/flesh/laceration = new wound_type()
	var/datum/wound/slash/flesh/jugcut = new critical_wound_type()
	var/is_jugcut = FALSE

	log_combat(attacker, defender, "jugular cut (Tribal Claw)", name)

	//balance feature, prevents damage bonus
	if(LAZYLEN(head?.wounds) > 0)
		for(var/i in head.wounds)
			if (i == critical_wound_type)
				is_jugcut = TRUE
				break

	if((defender.health <= defender.crit_threshold || (attacker.pulling == defender && attacker.grab_state >= GRAB_NECK) || defender.IsSleeping()) && !is_jugcut) {
		log_combat(attacker, defender, "strong jugular cut (Tribal Claw)", name)
		defender.apply_damage(60, BRUTE, BODY_ZONE_HEAD, def_check)
		defender.visible_message(span_warning("[attacker] tears out [defender]'s throat with their tail!"), \
						span_userdanger("[attacker] tears out your throat with their tail!"))
		jugcut.apply_wound(head)
		playsound(get_turf(defender), 'sound/effects/wounds/splatter.ogg')
	} else {
		defender.apply_damage(15, BRUTE, BODY_ZONE_HEAD, def_check)
		defender.visible_message(span_warning("[attacker] cuts [defender]'s jugular vein with their claws!"), \
						span_userdanger("[attacker] cuts your jugular vein!"))
		laceration.apply_wound(head)
	}
	//aditional effects
	//this should improve lethality
	if(defender.losebreath <= 50)
		defender.losebreath = clamp(defender.losebreath + 10, 0, 50)
	defender.adjustOxyLoss(10)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
	playsound(get_turf(defender), 'sound/weapons/slash.ogg', 50, 1, -1)



//Tail Grab, instantly puts your defender in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/tribal_claw/proc/tailGrab(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	log_combat(attacker, defender, "tail grabbed (Tribal Claw)", name)
	defender.visible_message(span_warning("[attacker] grabs [defender] with their tail!"), \
						span_userdanger("[attacker] grabs you with their tail!6</span>"))
	defender.grabbedby(attacker, 1)
	defender.Knockdown(5) //Without knockdown defender still stands up while T3 grabbed.
	attacker.setGrabState(GRAB_NECK)
	defender.adjust_silence_up_to(10 SECONDS, 10 SECONDS)

/datum/martial_art/tribal_claw/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("H",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/disarm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("D",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/grab_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	add_to_streak("G",defender)
	if(check_streak(attacker,defender))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/tribal_claw_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

	to_chat(usr, span_notice("Tail Sweep</span>: Disarm Harm. Pushes everyone around you away and knocks them down."))
	to_chat(usr, span_notice("Face Scratch</span>: Harm Harm. Damages your target's head and confuses them for a short time."))
	to_chat(usr, span_notice("Jugular Cut</span>: Harm Disarm. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition."))
	to_chat(usr, span_notice("Tail Grab</span>: Disarm Disarm Grab. Grabs your target by their neck and makes them unable to talk for a short time."))
