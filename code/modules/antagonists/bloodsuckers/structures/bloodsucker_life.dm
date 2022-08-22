/// Runs from COMSIG_LIVING_BIOLOGICAL_LIFE, handles Bloodsucker constant proccesses.
/datum/antagonist/bloodsucker/proc/LifeTick()

	if(!owner && !owner.current)
		INVOKE_ASYNC(src, .proc/HandleDeath)
		return

	if(istype(owner.current, /mob/living/simple_animal/hostile/bloodsucker))
		return

	if(isbrain(owner.current))
		return

	// Deduct Blood
	if(owner.current.stat == CONSCIOUS && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		INVOKE_ASYNC(src, .proc/AddBloodVolume, passive_blood_drain) // -.1 currently
	if(HandleHealing(1))
		if((COOLDOWN_FINISHED(src, bloodsucker_spam_healing)) && owner.current.blood_volume > 0)
			to_chat(owner.current, span_notice("The power of your blood begins knitting your wounds..."))
			COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_HEALING)
	// Standard Updates
	INVOKE_ASYNC(src, .proc/HandleDeath)
	INVOKE_ASYNC(src, .proc/HandleStarving)
	INVOKE_ASYNC(src, .proc/HandleTorpor)

	if(my_clan == CLAN_TOREADOR && owner.current.stat != DEAD)
		for(var/datum/antagonist/vassal in vassals)
			if(vassal.master != src)
				continue
			if(!vassal.owner.current || vassal.owner.current == DEAD)
				continue
			if(get_dist(get_turf(owner.current), get_turf(vassal.owner.current)) > 5)
				continue
			SEND_SIGNAL(vassal.owner.current, COMSIG_ADD_MOOD_EVENT, /datum/mood_event/toreador_vassal)
			

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//			BLOOD
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/antagonist/bloodsucker/proc/AddBloodVolume(value)
	owner.current.blood_volume = clamp(owner.current.blood_volume + value, 0, max_blood_volume)
	update_hud()

/datum/antagonist/bloodsucker/proc/AddHumanityLost(value)
	if(humanity_lost >= 500)
		to_chat(owner.current, span_warning("You hit the maximum amount of lost Humanity, you are far from Human."))
		return
	if(humanity_lost >= TOREADOR_MAX_HUMANITY_LOSS)
		to_chat(owner.current, span_warning("Your moral prevents you from becoming more ihuman."))
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, /datum/mood_event/toreador_inhuman2)
		return
	SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, /datum/mood_event/toreador_inhuman)
	humanity_lost += value
	to_chat(owner.current, span_warning("You feel as if you lost some of your humanity, you will now enter Frenzy at [FRENZY_THRESHOLD_ENTER + humanity_lost * 10] Blood."))

/// mult: SILENT feed is 1/3 the amount
/datum/antagonist/bloodsucker/proc/HandleFeeding(mob/living/carbon/target, mult=1, power_level)
	// Starts at 15 (now 8 since we doubled the Feed time)
	var/feed_amount = 15 + (power_level * 2)
	var/blood_taken = min(feed_amount, target.blood_volume) * mult
	target.blood_volume -= blood_taken
	// Simple Animals lose a LOT of blood, and take damage. This is to keep cats, cows, and so forth from giving you insane amounts of blood.
	if(!ishuman(target))
		target.blood_volume -= (blood_taken / max(target.mob_size, 0.1)) * 3.5 // max() to prevent divide-by-zero
		target.apply_damage_type(blood_taken / 3.5) // Don't do too much damage, or else they die and provide no blood nourishment.
		if(target.blood_volume <= 0)
			target.blood_volume = 0
			target.death(0)
	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((owner.current.blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (owner.current.blood_volume + blood_taken)
	// our volume * temp, + their volume * temp, / total volume
	///////////
	// Reduce Value Quantity
	if(target.stat == DEAD) // Penalty for Dead Blood
		blood_taken /= 4
	if(!ishuman(target)) // Penalty for Non-Human Blood
		blood_taken /= 3
	if(!target.mind && !target.client)
		blood_taken /= 5 // Penalty for Catatonics / Braindead
	//if (!iscarbon(target)) // Penalty for Animals (they're junk food)
	// Apply to Volume
	AddBloodVolume(blood_taken)
	// Reagents (NOT Blood!)
	if(target.reagents && target.reagents.total_volume)
		target.reagents.trans_to(owner.current, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	total_blood_drank += blood_taken
	if(frenzied)
		frenzy_blood_drank += blood_taken
	if(current_task)
		if(target.mind)
			task_blood_drank += blood_taken
		else
			to_chat(owner, span_warning("[target] is catatonic and won't yield any usable blood for tasks!"))
	return blood_taken

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			HEALING

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// Constantly runs on Bloodsucker's LifeTick, and is increased by being in Torpor/Coffins
/datum/antagonist/bloodsucker/proc/HandleHealing(mult = 1)
	var/actual_regen = bloodsucker_regen_rate + additional_regen
	// Don't heal if I'm staked or on Masquerade (+ not in a Coffin). Masqueraded Bloodsuckers in a Coffin however, will heal.
	if(owner.current.AmStaked() || (HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && !HAS_TRAIT(owner.current, TRAIT_NODEATH) && my_clan != CLAN_TOREADOR))
		return FALSE
	owner.current.adjustCloneLoss(-1 * (actual_regen * 4) * mult, 0)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4) * mult) //adjustBrainLoss(-1 * (actual_regen * 4) * mult, 0)
	if(!iscarbon(owner.current)) // Damage Heal: Do I have damage to ANY bodypart?
		return
	var/mob/living/carbon/user = owner.current
	var/costMult = 1 // Coffin makes it cheaper
	var/bruteheal = min(user.getBruteLoss_nonProsthetic(), actual_regen) // BRUTE: Always Heal
	var/fireheal = 0 // BURN: Heal in Coffin while Fakedeath, or when damage above maxhealth (you can never fully heal fire)
	/// Checks if you're in a coffin here, additionally checks for Torpor right below it.
	var/amInCoffin = istype(user.loc, /obj/structure/closet/crate/coffin)
	if(amInCoffin && HAS_TRAIT(user, TRAIT_NODEATH))
		if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && my_clan != CLAN_TOREADOR)
			to_chat(user, span_warning("You will not heal while your Masquerade ability is active."))
			return
		fireheal = min(user.getFireLoss_nonProsthetic(), actual_regen)
		mult *= 5 // Increase multiplier if we're sleeping in a coffin.
		costMult /= 2 // Decrease cost if we're sleeping in a coffin.
		user.ExtinguishMob()
		user.remove_all_embedded_objects() // Remove Embedded!
		if(check_limbs(costMult))
			return TRUE
	// In Torpor, but not in a Coffin? Heal faster anyways.
	else if(HAS_TRAIT(user, TRAIT_NODEATH))
		mult *= 3
	// Heal if Damaged
	if((bruteheal + fireheal > 0) && mult != 0) // Just a check? Don't heal/spend, and return.
		// We have damage. Let's heal (one time)
		user.adjustBruteLoss(-bruteheal * mult, forced=TRUE) // Heal BRUTE / BURN in random portions throughout the body.
		user.adjustFireLoss(-fireheal * mult, forced=TRUE)
		AddBloodVolume(((bruteheal * -0.5) + (fireheal * -1)) * costMult * mult) // Costs blood to heal
		return TRUE

/datum/antagonist/bloodsucker/proc/check_limbs(costMult = 1)
	var/limb_regen_cost = 50 * -costMult
	var/mob/living/carbon/user = owner.current
	var/list/missing = user.get_missing_limbs()
	if(missing.len && user.blood_volume < limb_regen_cost + 5)
		return FALSE
	for(var/targetLimbZone in missing) // 1) Find ONE Limb and regenerate it.
		user.regenerate_limb(targetLimbZone, FALSE) // regenerate_limbs() <--- If you want to EXCLUDE certain parts, do it like this ----> regenerate_limbs(0, list("head"))
		AddBloodVolume(limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = user.get_bodypart(targetLimbZone) // 2) Limb returns Damaged
		missing_bodypart.brute_dam = 60
		to_chat(user, span_notice("Your flesh knits as it regrows your [missing_bodypart]!"))
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
		return TRUE

/*
 *	# Heal Vampire Organs
 *
 *	This is used by Bloodsuckers, these are the steps of this proc:
 *	Step 1 - Cure husking and Regenerate organs. regenerate_organs() removes their Vampire Heart & Eye augments, which leads us to...
 *	Step 2 - Repair any (shouldn't be possible) Organ damage, then return their Vampiric Heart & Eye benefits.
 *	Step 3 - Revive them, clear all wounds, remove any Tumors (If any).
 *
 *	This is called on Bloodsucker's Assign, and when they end Torpor.
 */

/datum/antagonist/bloodsucker/proc/HealVampireOrgans()
	var/mob/living/carbon/bloodsuckeruser = owner.current

	// Step 1 - Fix basic things, husk and organs.
	bloodsuckeruser.cure_husk()
	bloodsuckeruser.regenerate_organs()

	// Step 2 NOTE: Giving passive organ regeneration will cause Torpor to spam /datum/client_colour/monochrome at the Bloodsucker, permanently making them colorblind!
	for(var/all_organs in bloodsuckeruser.internal_organs)
		var/obj/item/organ/organ = all_organs
		organ.setOrganDamage(0)
	var/obj/item/organ/heart/current_heart = bloodsuckeruser.getorganslot(ORGAN_SLOT_HEART)
	if(!istype(current_heart, /obj/item/organ/heart/vampheart) && !istype(current_heart, /obj/item/organ/heart/demon) && !istype(current_heart, /obj/item/organ/heart/cursed && !istype(current_heart, /obj/item/organ/heart/nightmare)))
		qdel(current_heart)
		var/obj/item/organ/heart/vampheart/vampiric_heart = new
		vampiric_heart.Insert(owner.current)
		vampiric_heart.Stop()
	var/obj/item/organ/eyes/current_eyes = bloodsuckeruser.getorganslot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, - 1)
		current_eyes.sight_flags = SEE_MOBS
		current_eyes.see_in_dark = 8
		current_eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if(my_clan == CLAN_LASOMBRA && ishuman(bloodsuckeruser))
			var/mob/living/carbon/human/bloodsucker = bloodsuckeruser
			bloodsucker.eye_color = "f00"
			bloodsuckeruser.update_body()
	bloodsuckeruser.update_sight()

	// Step 3
	if(bloodsuckeruser.stat == DEAD)
		bloodsuckeruser.revive(full_heal = FALSE, admin_revive = FALSE)
	for(var/i in bloodsuckeruser.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.remove_wound()
	// From [powers/panacea.dm]
	var/list/bad_organs = list(
		bloodsuckeruser.getorgan(/obj/item/organ/body_egg),
		bloodsuckeruser.getorgan(/obj/item/organ/zombie_infection))
	for(var/tumors in bad_organs)
		var/obj/item/organ/yucky_organs = tumors
		if(!istype(yucky_organs))
			continue
		yucky_organs.Remove(bloodsuckeruser)
		yucky_organs.forceMove(get_turf(bloodsuckeruser))
	
	// Good to go!

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			DEATH

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// FINAL DEATH
/datum/antagonist/bloodsucker/proc/HandleDeath()
	// Not "Alive"?
	if(!owner.current || !get_turf(owner.current))
		FinalDeath()
		return
	// Fire Damage? (above double health)
	if(owner.current.getFireLoss() >= owner.current.maxHealth * 2.5)
		FinalDeath()
		return
	// Staked while "Temp Death" or Asleep
	if(owner.current.StakeCanKillMe() && owner.current.AmStaked())
		FinalDeath()
		return
	// Not organic/living? (Zombie/Skeleton/Plasmaman)
	if(!(owner.current.mob_biotypes & MOB_ORGANIC))
		FinalDeath()
		return
	// Temporary Death? Convert to Torpor.
	if(owner.current.stat == DEAD)
		var/mob/living/carbon/human/dead_bloodsucker = owner.current
		if(!HAS_TRAIT(dead_bloodsucker, TRAIT_NODEATH))
			to_chat(dead_bloodsucker, span_danger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
			Check_Begin_Torpor(TRUE)

/datum/antagonist/bloodsucker/proc/HandleStarving() // I am thirsty for blood!
	// Nutrition - The amount of blood is how full we are.
	owner.current.set_nutrition(min(owner.current.blood_volume, NUTRITION_LEVEL_FED))

	// BLOOD_VOLUME_GOOD: [336] - Pale
//	handled in bloodsucker_integration.dm
	// BLOOD_VOLUME_EXIT: [560] - Exit Frenzy (If in one) This is high because we want enough to kill the poor soul they feed off of.
	if(owner.current.blood_volume >= (FRENZY_THRESHOLD_EXIT + humanity_lost * 10) && frenzied)
		owner.current.remove_status_effect(STATUS_EFFECT_FRENZY)
	// BLOOD_VOLUME_BAD: [224] - Jitter
	if(owner.current.blood_volume < BLOOD_VOLUME_BAD(owner.current) && prob(0.5) && !HAS_TRAIT(owner.current, TRAIT_NODEATH) && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.Jitter(3)
	// BLOOD_VOLUME_SURVIVE: [122] - Blur Vision
	if(owner.current.blood_volume < BLOOD_VOLUME_SURVIVE(owner.current))
		owner.current.blur_eyes(8 - 8 * (owner.current.blood_volume / BLOOD_VOLUME_BAD(owner.current)))

	// The more blood, the better the Regeneration, get too low blood, and you enter Frenzy.
	if(owner.current.blood_volume < (FRENZY_THRESHOLD_ENTER + humanity_lost * 10) && !frenzied)
		if(!iscarbon(owner.current))
			return
		if(owner.current.stat == DEAD)
			HandleDeath()
			return
		enter_frenzy()
	else if(owner.current.blood_volume < BLOOD_VOLUME_BAD(owner.current))
		additional_regen = 0.1
	else if(owner.current.blood_volume < BLOOD_VOLUME_OKAY(owner.current))
		additional_regen = 0.2
	else if(owner.current.blood_volume < BLOOD_VOLUME_NORMAL(owner.current))
		additional_regen = 0.3
	else if(owner.current.blood_volume < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else
		additional_regen = 0.5

/datum/antagonist/bloodsucker/proc/enter_frenzy()
	if(my_clan == CLAN_GANGREL)
		var/mob/living/carbon/user = owner.current
		switch(frenzies)
			if(0)
				owner.current.apply_status_effect(STATUS_EFFECT_FRENZY)
				return
			if(1)
				to_chat(owner, span_warning("You start feeling hungrier, you feel like a normal frenzy won't satiate it enough anymore."))
				owner.current.apply_status_effect(STATUS_EFFECT_FRENZY)
				return
			if(2 to INFINITY)
				AddBloodVolume(FRENZY_THRESHOLD_EXIT + humanity_lost * 10 - user.blood_volume) //so it doesn't happen multiple times and refills your blood when you get out again
				if(!do_mob(user, user, 2 SECONDS, TRUE))
					return
				playsound(user.loc, 'sound/weapons/slash.ogg', 25, TRUE)
				to_chat(user, span_warning("<i><b>You skin rips and tears.</b></i>"))
				if(!do_mob(user, user,  1 SECONDS, TRUE))
					return
				playsound(user.loc, 'sound/weapons/slashmiss.ogg', 25, TRUE)
				to_chat(user, span_warning("<i><b>You heart pumps blackened blood into your veins as your skin turns into fur.</b></i>"))
				if(!do_mob(user, user,  1 SECONDS, TRUE))
					return
				playsound(user.loc, 'sound/weapons/slice.ogg', 25, TRUE)
				to_chat(user, span_boldnotice("<i><b><FONT size = 3>YOU HAVE AWOKEN.</b></i>"))
				var/mob/living/simple_animal/hostile/bloodsucker/werewolf/ww
				if(!ww || ww.stat == DEAD)
					ww = new /mob/living/simple_animal/hostile/bloodsucker/werewolf(user.loc)
					user.forceMove(ww)
					ww.bloodsucker = user
					user.status_flags |= GODMODE
					user.mind.transfer_to(ww)
					var/list/wolf_powers = list(new /datum/action/bloodsucker/targeted/feast,)
					for(var/datum/action/bloodsucker/power in powers)
						if(istype(power, /datum/action/bloodsucker/fortitude))
							wolf_powers += new /datum/action/bloodsucker/gangrel/wolfortitude
						if(istype(power, /datum/action/bloodsucker/targeted/lunge))
							wolf_powers += new /datum/action/bloodsucker/targeted/pounce
						if(istype(power, /datum/action/bloodsucker/cloak))
							wolf_powers += new /datum/action/bloodsucker/gangrel/howl
						if(istype(power, /datum/action/bloodsucker/targeted/trespass))
							wolf_powers += new /datum/action/bloodsucker/gangrel/rabidism
					for(var/datum/action/bloodsucker/power in wolf_powers) 
						power.Grant(ww)
				frenzies++
	else
		owner.current.apply_status_effect(STATUS_EFFECT_FRENZY)

/**
 * # Torpor
 *
 * Torpor is what deals with the Bloodsucker falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Being in a Coffin while Sol is on, dealt with by /HandleTorpor()
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [bloodsucker_coffin.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol, dealt with by /HandleTorpor()
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol, dealt with by /HandleTorpor()
 * - Sol being over, dealt with by /sunlight/process() [bloodsucker_daylight.dm]
*/

/datum/antagonist/bloodsucker/proc/HandleTorpor()
	if(!owner.current)
		return
	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin))
		if(!HAS_TRAIT(owner.current, TRAIT_NODEATH))
			/// Staked? Dont heal
			if(owner.current.AmStaked())
				to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
				return
			/// Otherwise, check if it's Sol, to enter Torpor.
			if(clan.bloodsucker_sunlight.amDay)
				Check_Begin_Torpor(TRUE)
	if(HAS_TRAIT(owner.current, TRAIT_NODEATH)) // Check so I don't go insane.
		Check_End_Torpor()

/datum/antagonist/bloodsucker/proc/Check_Begin_Torpor(SkipChecks = FALSE)
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		Torpor_Begin()
		return
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!clan.bloodsucker_sunlight.amDay && total_damage >= 10 && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		Torpor_Begin()

/datum/antagonist/bloodsucker/proc/Check_End_Torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(!clan.bloodsucker_sunlight.amDay && total_damage <= 10)
			Torpor_End()
	// You're not in a Coffin? We won't check for low Burn damage
	else if(!clan.bloodsucker_sunlight.amDay && total_brute <= 10)
		// You're under 10 brute, but over 200 Burn damage? Don't exit Torpor, to prevent spam revival/death. Only way out is healing that Burn.
		if(total_burn >= 199)
			return
		Torpor_End()

/datum/antagonist/bloodsucker/proc/Torpor_Begin()
	var/mob/living/carbon/human/bloodsucker = owner.current
	to_chat(owner.current, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	/// Force them to go to sleep
	REMOVE_TRAIT(owner.current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	/// Without this, you'll just keep dying while you recover.
	ADD_TRAIT(owner.current, TRAIT_NODEATH, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_FAKEDEATH, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_DEATHCOMA, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, BLOODSUCKER_TRAIT)
	bloodsucker.physiology.brute_mod *= 0
	owner.current.Jitter(0)
	/// Disable ALL Powers
	DisableAllPowers()

/datum/antagonist/bloodsucker/proc/Torpor_End()
	var/mob/living/carbon/human/bloodsucker = owner.current
	owner.current.grab_ghost()
	to_chat(owner.current, span_warning("You have recovered from Torpor."))
	if(my_clan == CLAN_LASOMBRA)
		bloodsucker.physiology.brute_mod *= 0
	else
		bloodsucker.physiology.brute_mod = initial(bloodsucker.physiology.brute_mod)
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_DEATHCOMA, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_FAKEDEATH, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NODEATH, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	HealVampireOrgans()

/// Gibs the Bloodsucker, roundremoving them.
/datum/antagonist/bloodsucker/proc/FinalDeath()
	FreeAllVassals()
	// If we have no body, end here.
	if(!owner.current)
		return

	DisableAllPowers()
	if(!iscarbon(owner.current))
		owner.current.gib(TRUE, FALSE, FALSE)
		return
	// Drop anything in us and play a tune
	var/mob/living/carbon/user = owner.current
	owner.current.drop_all_held_items()
	owner.current.unequip_everything()
	user.remove_all_embedded_objects()
	playsound(owner.current, 'sound/effects/tendril_destroyed.ogg', 40, TRUE)
	// Elders get dusted, Fledglings get gibbed
	if(bloodsucker_level >= 4)
		owner.current.visible_message(
			span_warning("[owner.current]'s skin crackles and dries, their skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("You hear a dry, crackling sound."))
		addtimer(CALLBACK(owner.current, /mob/living.proc/dust), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		owner.current.visible_message(
			span_warning("[owner.current]'s skin bursts forth in a spray of gore and detritus. A horrible cry echoes from what is now a wet pile of decaying meat."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("<span class='italics'>You hear a wet, bursting sound."))
		owner.current.gib(TRUE, FALSE, FALSE)


// Bloodsuckers moodlets //
/datum/mood_event/drankblood
	description = "<span class='nicegreen'>I have fed greedly from that which nourishes me.</span>\n"
	mood_change = 10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = "<span class='boldwarning'>I drank the blood of a lesser creature. Disgusting.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = "<span class='boldwarning'>I drank dead blood. I am better than this.</span>\n"
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = "<span class='boldwarning'>I drank synthetic blood. What is wrong with me?</span>\n"
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = "<span class='boldwarning'>I fed off of a dead person. I feel... less human.</span>\n"
	mood_change = -15
	timeout = 10 MINUTES

/datum/mood_event/madevamp
	description = "<span class='boldwarning'>A soul has been cursed to undeath by my own hand.</span>\n"
	mood_change = 15
	timeout = 20 MINUTES

/datum/mood_event/coffinsleep
	description = "<span class='nicegreen'>I slept in a coffin during the day. I feel whole again.</span>\n"
	mood_change = 10
	timeout = 6 MINUTES

/datum/mood_event/daylight_1
	description = "<span class='boldwarning'>I slept poorly in a makeshift coffin during the day.</span>\n"
	mood_change = -3
	timeout = 6 MINUTES

/datum/mood_event/daylight_2
	description = "<span class='boldwarning'>I have been scorched by the unforgiving rays of the sun.</span>\n"
	mood_change = -6
	timeout = 6 MINUTES

/datum/mood_event/toreador_inhuman
	description = "<span class='boldwarning'>I commited inhuman actions. I feel... bad.</span>\n"
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/toreador_inhuman2
	description = "<span class='boldwarning'>I should stop acting like this. What am I turning into?</span>\n"
	mood_change = -10
	timeout = 10 MINUTES

/datum/mood_event/toreador_vassal
	description = "<span class='nicegreen'>My master is near me. I love them.</span>\n"
	mood_change = 4
	timeout = 30 SECONDS

///Candelabrum's mood event to non Bloodsucker/Vassals
/datum/mood_event/vampcandle
	description = "<span class='boldwarning'>Something is making your mind feel... loose.</span>\n"
	mood_change = -15
	timeout = 5 MINUTES

