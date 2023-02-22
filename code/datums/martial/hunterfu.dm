#define BODYSLAM_COMBO "GH"
#define STAKESTAB_COMBO "HH"
#define NECKSNAP_COMBO "GDH"
#define HOLYKICK_COMBO "DG"

// From CQC.dm
/datum/martial_art/hunterfu
	name = "Hunter-Fu"
	id = MARTIALART_HUNTERFU
	help_verb = /mob/living/carbon/human/proc/hunterfu_help
	block_chance = 60
	allow_temp_override = TRUE
	var/old_grab_state = null

/datum/martial_art/hunterfu/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak, BODYSLAM_COMBO))
		streak = ""
		body_slam(A, D)
		return TRUE
	if(findtext(streak, STAKESTAB_COMBO))
		streak = ""
		stake_stab(A, D)
		return TRUE
	if(findtext(streak, NECKSNAP_COMBO))
		streak = ""
		neck_snap(A, D)
		return TRUE
	if(findtext(streak, HOLYKICK_COMBO))
		streak = ""
		holy_kick(A, D)
		return TRUE
	return FALSE

/datum/martial_art/hunterfu/proc/body_slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(D.mobility_flags & MOBILITY_STAND)
		D.visible_message(
			span_danger("[A] slams both [A.p_them()]self and [D] into the ground!"),
			span_userdanger("You're slammed into the ground by [A]!"),
			span_hear("You hear a sickening sound of flesh hitting flesh!"),
		)
		to_chat(A, span_danger("You slam [D] into the ground!"))
		playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, TRUE, -1)
		log_combat(A, D, "bodyslammed (Hunter-Fu)")
		if(!D.mind)
			D.Paralyze(40)
			A.Paralyze(25)
			return TRUE
		if(D.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(D, span_cultlarge("Our DNA shakes as we are body slammed!"))
			D.apply_damage(A.get_punchdamagehigh() + 5, BRUTE)	//15 damage
			D.Paralyze(60)
			A.Paralyze(25)
			return TRUE
		else
			D.Paralyze(40)
			A.Paralyze(25)
	else
		harm_act(A, D)
	return TRUE

/datum/martial_art/hunterfu/proc/stake_stab(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message(
		span_danger("[A] stabs [D] in the heart!"),
		span_userdanger("You're staked in the heart by [A]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
	)
	to_chat(A, span_danger("You stab [D] viciously!"))
	playsound(get_turf(A), 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	log_combat(A, D, "stakestabbed (Hunter-Fu)")
	var/stake_damagehigh = A.get_punchdamagehigh() * 1.5 + 10	//25 damage
	if(!D.mind)
		D.apply_damage(A.get_punchdamagehigh() + 5, BRUTE, BODY_ZONE_CHEST)	//15 damage
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(D, span_danger("Their arm tears through our monstrous form!"))
		D.apply_damage(stake_damagehigh, BRUTE, BODY_ZONE_CHEST)
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/sinfuldemon))
		to_chat(D, span_danger("Their arm tears through your demonic form!"))
		D.apply_damage(stake_damagehigh, BRUTE, BODY_ZONE_CHEST)
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		to_chat(D, span_cultlarge("Their arm stakes straight into your undead flesh!"))
		D.apply_damage(A.get_punchdamagehigh() + 10, BURN)				//20 damage
		D.apply_damage(A.get_punchdamagehigh(), BRUTE, BODY_ZONE_CHEST)	//10 damage
		return TRUE
	else
		D.apply_damage(A.get_punchdamagehigh() + 5, BRUTE, BODY_ZONE_CHEST)	//15 damage
	return TRUE

/datum/martial_art/hunterfu/proc/neck_snap(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat)
		D.visible_message(
			span_danger("[A] snapped [D]'s neck!"),
			span_userdanger("Your neck is snapped by [A]!"),
			span_hear("You hear a snap!"),
		)
		to_chat(A, span_danger("You snap [D]'s neck!"))
		playsound(get_turf(A), 'sound/effects/snap.ogg', 50, TRUE, -1)
		log_combat(A, D, "neck snapped (Hunter-Fu)")
		if(!D.mind)
			D.SetSleeping(30)
			playsound(get_turf(A), 'sound/effects/snap.ogg', 50, TRUE, -1)
			log_combat(A, D, "neck snapped (Hunter-Fu)")
			return TRUE
		if(D.mind.has_antag_datum(/datum/antagonist/changeling))
			to_chat(D, span_warning("Our monstrous form protects us from being put to sleep!"))
			return TRUE
		if(D.mind.has_antag_datum(/datum/antagonist/heretic))
			to_chat(D, span_cultlarge("The power of the Codex Cicatrix flares as we are swiftly put to sleep!"))
			D.apply_damage(A.get_punchdamagehigh() + 5, BRUTE, BODY_ZONE_HEAD)	//15 damage
			D.SetSleeping(40)
			return TRUE
		if(D.mind.has_antag_datum(/datum/antagonist/bloodsucker))
			to_chat(D, span_warning("Your undead form protects you from being put to sleep!"))
			return TRUE
		if(D.mind.has_antag_datum(/datum/antagonist/sinfuldemon))
			to_chat(D, span_warning("Your demonic form protects you from being put to sleep!"))
			return TRUE
		else
			D.SetSleeping(30)
	return TRUE

/datum/martial_art/hunterfu/proc/holy_kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.visible_message(
		span_warning("[A] kicks [D], splashing holy water in every direction!"),
		span_userdanger("You're kicked by [A], with holy water dripping down on you!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
	)
	to_chat(A, span_danger("You holy kick [D]!"))
	playsound(get_turf(A), 'sound/weapons/slash.ogg', 50, TRUE, -1)
	log_combat(A, D, "holy kicked (Hunter-Fu)")
	var/holykick_staminadamage = A.get_punchdamagehigh() * 3 + 30 //60 damage (holy shit)
	var/holykick_hereticburn = A.get_punchdamagehigh() * 1.5 + 10	//25 damage
	if(!D.mind)
		D.apply_damage(holykick_staminadamage, STAMINA)
		D.Paralyze(20)
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/heretic))
		to_chat(D, span_cultlarge("The holy water burns your flesh!"))
		D.apply_damage(holykick_hereticburn, BURN)
		D.apply_damage(holykick_staminadamage, STAMINA)
		D.Paralyze(20)
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/bloodsucker))
		to_chat(D, span_warning("This just seems like regular water..."))
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/cult))
		for(var/datum/action/innate/cult/blood_magic/BD in D.actions)
			to_chat(D, span_cultlarge("Your blood rites falter as the holy water drips onto your body!"))
			for(var/datum/action/innate/cult/blood_spell/BS in BD.spells)
				qdel(BS)
		D.apply_damage(holykick_staminadamage, STAMINA)
		D.Paralyze(20)
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/sinfuldemon))
		to_chat(D, span_cultlarge("The holy water burns deep inside you!"))
		D.apply_damage(holykick_hereticburn, BURN)
		D.apply_damage(holykick_staminadamage, STAMINA)
		D.Paralyze(40)
		return TRUE
	if(D.mind.has_antag_datum(/datum/antagonist/wizard) || (/datum/antagonist/wizard/apprentice))
		to_chat(D, span_danger("The holy water seems to be muting you somehow!"))
		if(D.silent <= 10)
			D.silent = clamp(D.silent + 10, 0, 10)
		D.apply_damage(holykick_staminadamage, STAMINA)
		D.Paralyze(20)
		return TRUE
	else
		D.apply_damage(holykick_staminadamage, STAMINA)
		D.Paralyze(20)
	return TRUE

/// Intents
/datum/martial_art/hunterfu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D", D)
	if(check_streak(A, D))
		return TRUE
	log_combat(A, D, "disarmed (Hunter-Fu)")
	return ..()

/datum/martial_art/hunterfu/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H", D)
	if(check_streak(A, D))
		return TRUE
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("kick", "chop", "hit", "slam")
	var/harm_damage = A.get_punchdamagehigh() + rand(0,5)	//10-15 damage
	D.visible_message(
		span_danger("[A] [atk_verb]s [D]!"),
		span_userdanger("[A] [atk_verb]s you!"),
	)
	to_chat(A, span_danger("You [atk_verb] [D]!"))
	D.apply_damage(harm_damage, BRUTE, affecting, wound_bonus = CANT_WOUND)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(A, D, "harmed (Hunter-Fu)")
	return TRUE

/datum/martial_art/hunterfu/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A!=D && can_use(A))
		add_to_streak("G", D)
		if(check_streak(A, D)) // If a combo is made no grab upgrade is done
			return TRUE
		old_grab_state = A.grab_state
		D.grabbedby(A, 1)
		if(old_grab_state == GRAB_PASSIVE)
			D.drop_all_held_items()
			A.grab_state = GRAB_AGGRESSIVE // Instant agressive grab
			log_combat(A, D, "grabbed (Hunter-Fu)")
			D.visible_message(
				span_warning("[A] violently grabs [D]!"),
				span_userdanger("You're grabbed violently by [A]!"),
				span_hear("You hear sounds of aggressive fondling!"),
			)
			to_chat(A, span_danger("You violently grab [D]!"))
		return TRUE
	..()

/mob/living/carbon/human/proc/hunterfu_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of Hunter-Fu."
	set category = "Hunter-Fu"
	to_chat(usr, span_notice("<b><i>You try to remember some of the basics of Hunter-Fu.</i></b>"))

	to_chat(usr, span_notice("<b>Body Slam</b>: Grab Harm. Slam opponent into the ground, knocking you both down."))
	to_chat(usr, span_notice("<b>Stake Stab</b>: Harm Harm. Stabs opponent with your bare fist, as strong as a Stake."))
	to_chat(usr, span_notice("<b>Neck Snap</b>: Grab Disarm Harm. Snaps an opponents neck, knocking them out."))
	to_chat(usr, span_notice("<b>Holy Kick</b>: Disarm Grab. Splashes the user with Holy Water, removing Cult Spells, while dealing stamina damage."))

	to_chat(usr, span_notice("<b><i>In addition, by having your throw mode on, you take a defensive position, allowing you to block and sometimes even counter attacks done to you.</i></b>"))
