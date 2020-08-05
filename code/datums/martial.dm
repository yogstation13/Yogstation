/datum/martial_art
	///the name of the martial art
	var/name = "Martial Art"
	///ID, used by mind/has_martialart
	var/id = "" 
	///current streak, successful attacks add to this
	var/streak = ""
	///longest a streak can be before the oldest attack is forgotten
	var/max_streak_length = 6
	///current thing being targetted for combos, switches if the user hits a different opponent
	var/current_target
	var/datum/martial_art/base // The permanent style. This will be null unless the martial art is temporary
	///chance to deflect bullets
	var/deflection_chance = 0
	///check for if deflected bullets should be destroyed (false) or redirected (true)
	var/reroute_deflection = FALSE
	///chance for the martial art to block a melee attack when throw is on
	var/block_chance = 0
	///used for CQC's restrain combo
	var/restraining = 0
	///verb used to get a description of the art
	var/help_verb
	///forbid use of guns if martial art is active
	var/no_guns = FALSE
	///check for if the martial art can be used by pacifists
	var/nonlethal = FALSE
	var/allow_temp_override = TRUE //if this martial art can be overridden by temporary martial arts

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return FALSE

/datum/martial_art/proc/handle_counter(mob/living/carbon/human/user, mob/living/carbon/human/attacker) //handles martial art counters if a block is scored
	return

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return TRUE

/datum/martial_art/proc/add_to_streak(element,mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
		restraining = 0
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak, 1 + length(streak[1]))
	return

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A,mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)

	var/atk_verb = A.dna.species.attack_verb
	if(!(D.mobility_flags & MOBILITY_STAND))
		atk_verb = "kick"

	switch(atk_verb)
		if("kick")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		if("slash")
			A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
		if("smash")
			A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		else
			A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)

	if(!damage)
		playsound(D.loc, A.dna.species.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>", \
			"<span class='userdanger'>[A] has attempted to [atk_verb] [D]!</span>", null, COMBAT_MESSAGE_RANGE)
		log_combat(A, D, "attempted to [atk_verb]")
		return FALSE

	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, A.dna.species.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
			"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>", null, COMBAT_MESSAGE_RANGE)

	D.apply_damage(damage, A.dna.species.attack_type, affecting, armor_block)

	log_combat(A, D, "punched")

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] has knocked [D] down!!</span>", \
								"<span class='userdanger'>[A] has knocked [D] down!</span>")
		D.apply_effect(40, EFFECT_KNOCKDOWN, armor_block)
		D.forcesay(GLOB.hit_appends)
	else if(!(D.mobility_flags & MOBILITY_STAND))
		D.forcesay(GLOB.hit_appends)
	return TRUE

/datum/martial_art/proc/teach(mob/living/carbon/human/H,make_temporary=0)
	if(!istype(H) || !H.mind)
		return FALSE
	if(H.mind.martial_art)
		if(make_temporary)
			if(!H.mind.martial_art.allow_temp_override)
				return FALSE
			store(H.mind.martial_art,H)
		else
			H.mind.martial_art.on_remove(H)
	else if(make_temporary)
		base = H.mind.default_martial_art
	if(help_verb)
		H.verbs += help_verb
	H.mind.martial_art = src
	return TRUE

/datum/martial_art/proc/store(datum/martial_art/M,mob/living/carbon/human/H)
	M.on_remove(H)
	if(M.base) //Checks if M is temporary, if so it will not be stored.
		base = M.base
	else //Otherwise, M is stored.
		base = M

/datum/martial_art/proc/remove(mob/living/carbon/human/H)
	if(!istype(H) || !H.mind || H.mind.martial_art != src)
		return
	on_remove(H)
	if(base)
		base.teach(H)
	else
		var/datum/martial_art/X = H.mind.default_martial_art
		X.teach(H)

/datum/martial_art/proc/on_remove(mob/living/carbon/human/H)
	if(help_verb)
		H.verbs -= help_verb
	return

/**
  * Martial arts, allow different attack effects and combo attacks
  *
  * Martial arts are used to change how a carbon can attack, giving different effects based on intent
  * Martial arts can also use combination attacks, which drastically change how an attack effects its target
  * The user can also gain projectile or melee block chance from having a martial art
  */
