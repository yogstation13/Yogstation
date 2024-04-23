///How much Blood it costs to live.
#define BLOODSUCKER_PASSIVE_BLOOD_DRAIN 0.1

/// Runs from COMSIG_LIVING_LIFE, handles Bloodsucker constant proccesses.
/datum/antagonist/bloodsucker/proc/LifeTick(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(isbrain(owner.current))
		return

	if(!owner && !owner.current)
		INVOKE_ASYNC(src, PROC_REF(HandleDeath))
		return

	if(HAS_TRAIT(owner.current, TRAIT_NODEATH))
		INVOKE_ASYNC(src, PROC_REF(check_end_torpor))

	if(istype(owner.current, /mob/living/simple_animal/hostile/bloodsucker))
		return

	if(isbrain(owner.current))
		return

	// Deduct Blood
	if(owner.current.stat == CONSCIOUS && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		INVOKE_ASYNC(src, PROC_REF(AddBloodVolume), -BLOODSUCKER_PASSIVE_BLOOD_DRAIN) // -.1 currently
	if(INVOKE_ASYNC(src, PROC_REF(HandleHealing)))
		if((COOLDOWN_FINISHED(src, bloodsucker_spam_healing)) && bloodsucker_blood_volume)
			INVOKE_ASYNC(src, PROC_REF(to_chat), owner.current, span_notice("The power of your blood begins knitting your wounds..."))
			COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_HEALING)
	// Standard Updates
	SEND_SIGNAL(src, COMSIG_BLOODSUCKER_ON_LIFETICK)
	INVOKE_ASYNC(src, PROC_REF(HandleStarving))
	INVOKE_ASYNC(src, PROC_REF(update_blood))

	INVOKE_ASYNC(src, PROC_REF(update_hud))

/datum/antagonist/bloodsucker/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(HandleDeath))
	RegisterSignal(owner.current, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(src, COMSIG_BLOODSUCKER_ON_LIFETICK, PROC_REF(HandleDeath))

/datum/antagonist/bloodsucker/proc/on_revive(mob/living/source)
	UnregisterSignal(owner.current, COMSIG_LIVING_REVIVE)
	UnregisterSignal(src, COMSIG_BLOODSUCKER_ON_LIFETICK)

/**
 * ## BLOOD STUFF
 */
/datum/antagonist/bloodsucker/proc/AddBloodVolume(value)
	bloodsucker_blood_volume = clamp(bloodsucker_blood_volume + value, 0, max_blood_volume)

/datum/antagonist/bloodsucker/proc/on_examine(datum/source, mob/examiner, examine_text)
	SIGNAL_HANDLER

	if(!iscarbon(source))
		return
	var/mob/living/carbon/carbon_source = source
	var/vamp_examine = carbon_source.return_vamp_examine(examiner)
	examine_text += vamp_examine

/datum/antagonist/bloodsucker/proc/AddHumanityLost(value)
	if(humanity_lost >= 500)
		to_chat(owner.current, span_warning("You hit the maximum amount of lost Humanity, you are far from Human."))
		return
	if(my_clan?.get_clan() == CLAN_TOREADOR)
		if(humanity_lost >= TOREADOR_MAX_HUMANITY_LOSS)
			to_chat(owner.current, span_warning("Your morals prevent you from becoming more inhuman."))
			SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, /datum/mood_event/toreador_inhuman2)
			return
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, /datum/mood_event/toreador_inhuman)
	humanity_lost += value
	to_chat(owner.current, span_warning("You feel as if you lost some of your humanity, you will now enter Frenzy at [FRENZY_THRESHOLD_ENTER + humanity_lost * 10] Blood."))

/// mult: SILENT feed is 1/3 the amount
/datum/antagonist/bloodsucker/proc/handle_feeding(mob/living/carbon/target, mult=1, power_level)
	// Starts at 15 (now 8 since we doubled the Feed time)
	var/feed_amount = 15 + (power_level * 2)
	var/blood_taken = min(feed_amount, target.blood_volume) * mult
	target.blood_volume -= blood_taken

	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((bloodsucker_blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (bloodsucker_blood_volume + blood_taken)
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
	if(has_task)
		if(target.mind)
			task_blood_drank += blood_taken
		else
			to_chat(owner, span_warning("[target] is catatonic and won't yield any usable blood for tasks!"))
	return blood_taken

/**
 * ## HEALING
 */

/// Constantly runs on Bloodsucker's LifeTick, and is increased by being in Torpor/Coffins
/datum/antagonist/bloodsucker/proc/HandleHealing(mult = 1)
	var/actual_regen = bloodsucker_regen_rate + additional_regen
	// Don't heal if I'm staked or on Masquerade (+ not in a Coffin). Masqueraded Bloodsuckers in a Coffin however, will heal.
	if(owner.current.am_staked() || (HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && !HAS_TRAIT(owner.current, TRAIT_NODEATH) && my_clan?.get_clan() != CLAN_TOREADOR))
		return FALSE
	owner.current.adjustCloneLoss(-1 * (actual_regen * 4) * mult, 0)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4) * mult) //adjustBrainLoss(-1 * (actual_regen * 4) * mult, 0)
	if(!iscarbon(owner.current)) // Damage Heal: Do I have damage to ANY bodypart?
		return
	var/mob/living/carbon/user = owner.current
	var/costMult = 1 // Coffin makes it cheaper
	var/bruteheal = min(user.getBruteLoss(), actual_regen) // BRUTE: Always Heal
	var/fireheal = 0 // BURN: Heal in Coffin while Fakedeath, or when damage above maxhealth (you can never fully heal fire)
	/// Checks if you're in a coffin here, additionally checks for Torpor right below it.
	var/amInCoffin = istype(user.loc, /obj/structure/closet/crate/coffin)
	if(amInCoffin && HAS_TRAIT(user, TRAIT_NODEATH))
		if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && (COOLDOWN_FINISHED(src, bloodsucker_spam_healing)))
			to_chat(user, span_alert("You do not heal while your Masquerade ability is active."))
			COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_MASQUERADE)
			return
		fireheal = min(user.getFireLoss(), actual_regen)
		mult *= 8 // Increase multiplier if we're sleeping in a coffin.
		costMult *= 0 // No cost if we're sleeping in a coffin.
		user.extinguish_mob()
		user.remove_all_embedded_objects() // Remove Embedded!
		if(check_limbs(costMult))
			return TRUE
	// In Torpor, but not in a Coffin? Heal faster anyways.
	else if(HAS_TRAIT(user, TRAIT_NODEATH))
		mult *= 3
	// Heal if Damaged
	if((bruteheal + fireheal > 0) && mult != 0) // Just a check? Don't heal/spend, and return.
		// We have damage. Let's heal (one time)
		
		var/realbrute = bruteheal * mult
		var/realfire = fireheal * mult

		var/list/hurt_limbs = user.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)//heal all organic limbs for 100% effectiveness
		var/num_limbs = LAZYLEN(hurt_limbs)
		if(num_limbs)
			for(var/X in hurt_limbs)
				var/obj/item/bodypart/affecting = X
				if(affecting.heal_damage(realbrute/num_limbs, realfire/num_limbs, null, BODYPART_ANY))
					user.update_damage_overlays()
		
		hurt_limbs = user.get_damaged_bodyparts(1, 1, null, BODYPART_ROBOTIC)//heal all robotics limbs for 50% effectiveness
		num_limbs = LAZYLEN(hurt_limbs)
		realbrute /= 2
		realfire /= 2
		if(num_limbs)
			for(var/X in hurt_limbs)
				var/obj/item/bodypart/affecting = X
				if(affecting.heal_damage(realbrute/num_limbs, realfire/num_limbs, null, BODYPART_ANY))
					user.update_damage_overlays()

		AddBloodVolume(((bruteheal * -0.5) + (fireheal * -1)) * costMult * mult) // Costs blood to heal
		return TRUE

/datum/antagonist/bloodsucker/proc/check_limbs(costMult = 1)
	var/limb_regen_cost = 50 * -costMult
	var/mob/living/carbon/user = owner.current
	var/list/missing = user.get_missing_limbs()
	if(missing.len && bloodsucker_blood_volume < limb_regen_cost + 5)
		return FALSE
	for(var/missing_limb in missing) //Find ONE Limb and regenerate it.
		user.regenerate_limb(missing_limb, FALSE)
		AddBloodVolume(-limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = user.get_bodypart(missing_limb) // 2) Limb returns Damaged
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

/datum/antagonist/bloodsucker/proc/heal_vampire_organs()
	var/mob/living/carbon/bloodsuckeruser = owner.current

	// Step 1 - Fix basic things, husk and organs.
	bloodsuckeruser.cure_husk()
	bloodsuckeruser.regenerate_organs()

	// Step 2 NOTE: Giving passive organ regeneration will cause Torpor to spam /datum/client_colour/monochrome at the Bloodsucker, permanently making them colorblind!
	for(var/obj/item/organ/organ as anything in bloodsuckeruser.internal_organs)
		organ.setOrganDamage(0)
	if(!HAS_TRAIT(bloodsuckeruser, TRAIT_MASQUERADE))
		var/obj/item/organ/heart/current_heart = bloodsuckeruser.getorganslot(ORGAN_SLOT_HEART)
		current_heart.beating = FALSE
	var/obj/item/organ/eyes/current_eyes = bloodsuckeruser.getorganslot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, - 1)
		current_eyes.color_cutoffs = list(25, 8, 5)
		current_eyes.sight_flags = SEE_MOBS

		current_eyes.setOrganDamage(0) //making sure
		if(my_clan?.get_clan() == CLAN_LASOMBRA && ishuman(bloodsuckeruser))
			var/mob/living/carbon/human/bloodsucker = bloodsuckeruser
			bloodsucker.eye_color = BLOODCULT_EYE
			bloodsuckeruser.update_body()
	bloodsuckeruser.update_sight()

	// Step 3
	if(bloodsuckeruser.stat == DEAD)
		bloodsuckeruser.revive(full_heal = FALSE, admin_revive = FALSE)
	for(var/datum/wound/iter_wound as anything in bloodsuckeruser.all_wounds)
		iter_wound.remove_wound()
	// From [powers/panacea.dm]
	var/list/bad_organs = list(
		bloodsuckeruser.getorgan(/obj/item/organ/body_egg),
		bloodsuckeruser.getorgan(/obj/item/organ/zombie_infection))
	for(var/obj/item/organ/yucky_organs as anything in bad_organs)
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
	if(!owner.current)
		FinalDeath()
		return
	// Fire Damage and Fledgeling? (above double health)
	if(owner.current.getFireLoss() >= owner.current.maxHealth * 2 && bloodsucker_level < 4)
		FinalDeath()
		return
	// Fire Damage and Daytime?
	if(owner.current.getFireLoss() >= owner.current.maxHealth * 2 && (SSsunlight.sunlight_active || frenzied))
		FinalDeath()
		return
	// Staked while "Temp Death" or Asleep
	if(owner.current.StakeCanKillMe() && owner.current.am_staked())
		FinalDeath()
		return
	// Temporary Death? Convert to Torpor.
	if(HAS_TRAIT(owner.current, TRAIT_NODEATH))
		return
	to_chat(owner.current, span_danger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
	check_begin_torpor(TRUE)


/datum/antagonist/bloodsucker/proc/HandleStarving() // I am thirsty for blood!
	// Nutrition - The amount of blood is how full we are.
	owner.current.set_nutrition(min(bloodsucker_blood_volume, NUTRITION_LEVEL_FED))

	// BLOOD_VOLUME_GOOD: [336] - Pale
//	handled in bloodsucker_integration.dm
	// BLOOD_VOLUME_EXIT: [560] - Exit Frenzy (If in one) This is high because we want enough to kill the poor soul they feed off of.
	if(bloodsucker_blood_volume >= (FRENZY_THRESHOLD_EXIT + humanity_lost * 10) && frenzied)
		owner.current.remove_status_effect(STATUS_EFFECT_FRENZY)
	// BLOOD_VOLUME_BAD: [224] - Jitter
	if(bloodsucker_blood_volume < BLOOD_VOLUME_BAD(owner.current) && prob(0.5) && !HAS_TRAIT(owner.current, TRAIT_NODEATH) && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.adjust_jitter(3 SECONDS)
	// BLOOD_VOLUME_SURVIVE: [122] - Blur Vision
	if(bloodsucker_blood_volume < BLOOD_VOLUME_SURVIVE(owner.current))
		owner.current.adjust_eye_blur((8 - 8 * (bloodsucker_blood_volume / BLOOD_VOLUME_BAD(owner.current)))* 2 SECONDS)

	// The more blood, the better the Regeneration, get too low blood, and you enter Frenzy.
	if(bloodsucker_blood_volume < (FRENZY_THRESHOLD_ENTER + humanity_lost * 10) && !frenzied)
		if(!iscarbon(owner.current))
			return
		if(my_clan?.get_clan() == CLAN_GANGREL)
			var/mob/living/carbon/user = owner.current
			switch(frenzies)
				if(0)
					owner.current.apply_status_effect(STATUS_EFFECT_FRENZY)
				if(1)
					to_chat(owner, span_warning("You start feeling hungrier, you feel like a normal frenzy won't satiate it enough anymore."))
					owner.current.apply_status_effect(STATUS_EFFECT_FRENZY)
				if(2 to INFINITY)
					if(do_after(user, 2 SECONDS, user, IGNORE_ALL))
						playsound(user.loc, 'sound/weapons/slash.ogg', 25, 1)
						to_chat(user, span_warning("<i><b>You skin rips and tears.</b></i>"))
						if(do_after(user, 1 SECONDS, user, IGNORE_ALL))
							playsound(user.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
							to_chat(user, span_warning("<i><b>You heart pumps blackened blood into your veins as your skin turns into fur.</b></i>"))
							if(do_after(user, 1 SECONDS, user, IGNORE_ALL))
								playsound(user.loc, 'sound/weapons/slice.ogg', 25, 1)
								to_chat(user, span_boldnotice("<i><b><FONT size = 3>YOU HAVE AWOKEN.</b></i>"))
								var/mob/living/simple_animal/hostile/bloodsucker/werewolf/ww
								if(!ww || ww.stat == DEAD)
									AddBloodVolume(560 - user.blood_volume) //so it doesn't happen multiple times and refills your blood when you get out again
									ww = new /mob/living/simple_animal/hostile/bloodsucker/werewolf(user.loc)
									user.forceMove(ww)
									ww.bloodsucker = user
									user.mind.transfer_to(ww)
									var/list/wolf_powers = list(new /datum/action/cooldown/bloodsucker/targeted/feast,)
									for(var/datum/action/cooldown/bloodsucker/power in powers)
										if(istype(power, /datum/action/cooldown/bloodsucker/fortitude))
											wolf_powers += new /datum/action/cooldown/bloodsucker/gangrel/wolfortitude
										if(istype(power, /datum/action/cooldown/bloodsucker/targeted/lunge))
											wolf_powers += new /datum/action/cooldown/bloodsucker/targeted/pounce
										if(istype(power, /datum/action/cooldown/bloodsucker/cloak))
											wolf_powers += new /datum/action/cooldown/bloodsucker/gangrel/howl
										if(istype(power, /datum/action/cooldown/bloodsucker/targeted/trespass))
											wolf_powers += new /datum/action/cooldown/bloodsucker/gangrel/rabidism
									for(var/datum/action/cooldown/bloodsucker/power in wolf_powers) 
										power.Grant(ww)
								frenzies ++
		else
			owner.current.apply_status_effect(STATUS_EFFECT_FRENZY)
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_BAD(owner.current))
		additional_regen = 0.1
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_OKAY(owner.current))
		additional_regen = 0.2
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_NORMAL(owner.current))
		additional_regen = 0.3
	else if(bloodsucker_blood_volume < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else
		additional_regen = 0.5

/// Cycle through all vamp antags and check if they're inside a closet.
/datum/antagonist/bloodsucker/proc/handle_sol()
	SIGNAL_HANDLER
	if(!owner)
		return

	if(!istype(owner.current.loc, /obj/structure))
		if(COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
			if(bloodsucker_level > 0)
				to_chat(owner, span_userdanger("The solar flare sets your skin ablaze!"))
			else
				to_chat(owner, span_userdanger("The solar flare scalds your neophyte skin!"))
			COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol

		if(owner.current.fire_stacks <= 0)
			owner.current.fire_stacks = 0
		if(bloodsucker_level > 0)
			owner.current.adjust_fire_stacks(0.2 + bloodsucker_level / 10)
			owner.current.ignite_mob()
		owner.current.adjustFireLoss(2 + (bloodsucker_level / 2))
		owner.current.updatehealth()
		SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_2)
		return

	if(istype(owner.current.loc, /obj/structure/closet/crate/coffin)) // Coffins offer the BEST protection
		if(owner.current.am_staked() && COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn))
			to_chat(owner.current, span_userdanger("You are staked! Remove the offending weapon from your heart before sleeping."))
			COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
		if(!HAS_TRAIT(owner.current, TRAIT_NODEATH))
			check_begin_torpor(TRUE)
			SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)
		return

	if(COOLDOWN_FINISHED(src, bloodsucker_spam_sol_burn)) // Closets offer SOME protection
		to_chat(owner, span_warning("Your skin sizzles. [owner.current.loc] doesn't protect well against UV bombardment."))
		COOLDOWN_START(src, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
	owner.current.adjustFireLoss(0.5 + (bloodsucker_level / 4))
	owner.current.updatehealth()
	SEND_SIGNAL(owner.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_1)

/datum/antagonist/bloodsucker/proc/give_warning(atom/source, danger_level, vampire_warning_message, vassal_warning_message)
	SIGNAL_HANDLER
	if(!owner)
		return
	to_chat(owner, vampire_warning_message)

	switch(danger_level)
		if(DANGER_LEVEL_FIRST_WARNING)
			owner.current.playsound_local(null, 'sound/effects/griffin_3.ogg', 50, 1)
		if(DANGER_LEVEL_SECOND_WARNING)
			owner.current.playsound_local(null, 'sound/effects/griffin_5.ogg', 50, 1)
		if(DANGER_LEVEL_THIRD_WARNING)
			owner.current.playsound_local(null, 'sound/effects/alert.ogg', 75, 1)
		if(DANGER_LEVEL_SOL_ROSE)
			owner.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', 100, 1)
		if(DANGER_LEVEL_SOL_ENDED)
			owner.current.playsound_local(null, 'sound/spookoween/ghosty_wind.ogg', 90, 1)

/**
 * # Torpor
 *
 * Torpor is what deals with the Bloodsucker falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Being in a Coffin while Sol is on, dealt with by Sol
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [bloodsucker_coffin.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [bloodsucker_daylight.dm]
*/

/**
 *	# Assigning Sol
 *
 *	Sol is the sunlight, during this period, all Bloodsuckers must be in their coffin, else they burn.
 */

/// Start Sol, called when someone is assigned Bloodsucker
/datum/antagonist/bloodsucker/proc/check_start_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("New Sol has been created due to Bloodsucker assignment.")
		SSsunlight.can_fire = TRUE

/// End Sol, if you're the last Bloodsucker
/datum/antagonist/bloodsucker/proc/check_cancel_sunlight()
	var/list/existing_suckers = get_antag_minds(/datum/antagonist/bloodsucker) - owner
	if(!length(existing_suckers))
		message_admins("Sol has been deleted due to the lack of Bloodsuckers")
		SSsunlight.can_fire = FALSE

/datum/antagonist/bloodsucker/proc/check_begin_torpor(SkipChecks = FALSE)
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		torpor_begin()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!SSsunlight.sunlight_active && total_damage >= 10 && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		torpor_begin()

/datum/antagonist/bloodsucker/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss_nonProsthetic()
	var/total_burn = user.getFireLoss_nonProsthetic()
	var/total_damage = total_brute + total_burn
	if(total_burn >= 199)
		return FALSE
	if(SSsunlight.sunlight_active)
		return FALSE
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(total_damage <= 10)
			torpor_end()
	else
		if(total_brute <= 10)
			torpor_end()

/datum/antagonist/bloodsucker/proc/torpor_begin()
	var/mob/living/carbon/human/bloodsucker = owner.current
	to_chat(owner.current, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	// Force them to go to sleep
	REMOVE_TRAIT(owner.current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	// Without this, you'll just keep dying while you recover.
	owner.current.add_traits(list(TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_DEATHCOMA, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), BLOODSUCKER_TRAIT)
	bloodsucker.physiology.brute_mod *= 0
	bloodsucker.physiology.burn_mod *= 0.75
	owner.current.set_timed_status_effect(0 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// Disable ALL Powers
	DisableAllPowers()

/datum/antagonist/bloodsucker/proc/torpor_end()
	var/mob/living/carbon/human/bloodsucker = owner.current
	owner.current.grab_ghost()
	to_chat(owner.current, span_warning("You have recovered from Torpor."))
	bloodsucker.physiology.brute_mod = initial(bloodsucker.physiology.brute_mod)
	bloodsucker.physiology.burn_mod = initial(bloodsucker.physiology.brute_mod)
	owner.current.remove_traits(list(TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_DEATHCOMA, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), BLOODSUCKER_TRAIT)
	if(!HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		ADD_TRAIT(owner.current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	heal_vampire_organs()

	SEND_SIGNAL(src, BLOODSUCKER_EXIT_TORPOR)

/// Makes your blood_volume look like your bloodsucker blood, unless you're Masquerading.
/datum/antagonist/bloodsucker/proc/update_blood()
	if(!iscarbon(owner.current))
		return
	var/mob/living/carbon/bloodsucker = owner.current
	if(LAZYFIND(bloodsucker.dna.species.species_traits, NOBLOOD))
		return
	//If we're on Masquerade, we appear to have full blood, unless we are REALLY low, in which case we don't look as bad.
	if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		if(bloodsucker_blood_volume >= BLOOD_VOLUME_OKAY(owner.current))
			owner.current.blood_volume = initial(bloodsucker_blood_volume)
		else if(bloodsucker_blood_volume >= BLOOD_VOLUME_BAD(owner.current))
			owner.current.blood_volume = BLOOD_VOLUME_SAFE(owner.current)
		else
			owner.current.blood_volume = BLOOD_VOLUME_OKAY(owner.current)
		return
	owner.current.blood_volume = bloodsucker_blood_volume

/// Gibs the Bloodsucker, roundremoving them.
/datum/antagonist/bloodsucker/proc/FinalDeath()
	// If we have no body, end here.
	if(!owner.current)
		return

	free_all_vassals()
	DisableAllPowers(forced = TRUE)
	if(!iscarbon(owner.current))
		owner.current.gib(TRUE, FALSE, FALSE)
		return
	// Drop anything in us and play a tune
	var/mob/living/carbon/user = owner.current
	owner.current.drop_all_held_items()
	owner.current.unequip_everything()
	user.remove_all_embedded_objects()
	playsound(owner.current, 'sound/effects/tendril_destroyed.ogg', 40, TRUE)
	var/unique_death = SEND_SIGNAL(src, BLOODSUCKER_FINAL_DEATH)
	if(unique_death & DONT_DUST)
		return

	// Elders get dusted, Fledglings get gibbed.
	if(bloodsucker_level >= 4)
		user.visible_message(
			span_warning("[user]'s skin crackles and dries, their skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("You hear a dry, crackling sound."))
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dust)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		user.visible_message(
			span_warning("[user]'s skin bursts forth in a spray of gore and detritus. A horrible cry echoes from what is now a wet pile of decaying meat."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("<span class='italics'>You hear a wet, bursting sound."))
		user.gib(TRUE, FALSE, FALSE)


// Bloodsuckers moodlets //
/datum/mood_event/drankblood
	description = "<span class='nicegreen'>I have fed greedily from that which nourishes me.</span>\n"
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
	mood_change = -4
	timeout = 6 MINUTES

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

