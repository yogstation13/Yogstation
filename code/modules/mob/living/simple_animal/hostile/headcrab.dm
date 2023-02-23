/mob/living/simple_animal/hostile/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	gender = NEUTER
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_vis_effect = ATTACK_EFFECT_BITE
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = DEAD
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_ALWAYS
	var/datum/mind/stored_mind = null //mind that is stored on creation
	var/egg_lain = FALSE
	var/obj/item/organ/body_egg/antag_egg/egg = /obj/item/organ/body_egg/antag_egg/changeling_egg //what eggo to use
	gold_core_spawnable = NO_SPAWN //yogs

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/victim)
	egg = new egg(victim)
	egg.Insert(victim)
	for(var/obj/item/organ/head_organs in src)
		head_organs.forceMove(egg)
	egg.fetus_mind = stored_mind ? stored_mind : mind //prioritize the stored one
	visible_message(span_warning("[src] plants something in [victim]'s flesh!"), \
					span_danger("We inject our egg into [victim]'s body!"))
	egg_lain = TRUE

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	. = ..()
	if(. && !egg_lain && iscarbon(target) && !ismonkey(target))
		// Changeling egg can survive in aliens!
		var/mob/living/carbon/C = target
		if(C.stat == DEAD)
			if(HAS_TRAIT(C, TRAIT_XENO_HOST))
				to_chat(src, span_userdanger("A foreign presence repels us from this body. Perhaps we should try to infest another?"))
				return
			Infect(target)
			to_chat(src, span_userdanger("With our egg laid, our death approaches rapidly..."))
			addtimer(CALLBACK(src, .proc/death), 10 SECONDS)

/obj/item/organ/body_egg/antag_egg
	name = "le antag egg"
	desc = "Greentexting and redtexting."
	var/datum/mind/fetus_mind
	var/time
	var/incubation_time = 120 //this shit takes roughly 5 minutes

/obj/item/organ/body_egg/antag_egg/egg_process()
	// eggs grow in people
	time++
	if(time >= incubation_time)
		Pop()
		Remove(owner)
		qdel(src)

/obj/item/organ/body_egg/antag_egg/proc/Pop()
	return

/obj/item/organ/body_egg/antag_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."

/obj/item/organ/body_egg/antag_egg/changeling_egg/Pop()
	var/mob/living/carbon/monkey/M = new(owner)
	owner.stomach_contents += M // Yogs -- Yogs vorecode

	for(var/obj/item/organ/I in src)
		I.Insert(M, 1)

	if(fetus_mind && (fetus_mind.current ? (fetus_mind.current.stat == DEAD) : fetus_mind.get_ghost()))
		fetus_mind.transfer_to(M)
		var/datum/antagonist/changeling/C = fetus_mind.has_antag_datum(/datum/antagonist/changeling)
		if(!C)
			C = fetus_mind.add_antag_datum(/datum/antagonist/changeling/xenobio)
		if(C.can_absorb_dna(owner))
			C.add_new_profile(owner)

		var/datum/action/changeling/humanform/hf = new
		C.purchasedpowers += hf
		C.regain_powers()
		M.key = fetus_mind.key
	owner.gib()
