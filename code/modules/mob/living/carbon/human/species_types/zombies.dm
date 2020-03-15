#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin
#define SPIT_COOLDOWN 3000

/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBLOOD,NOZOMBIE,NOTRANSSTING)
	inherent_traits = list(TRAIT_RESISTCOLD ,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_EASYDISMEMBER,TRAIT_LIMBATTACHMENT,TRAIT_NOBREATH,TRAIT_NODEATH,TRAIT_FAKEDEATH)
	inherent_biotypes = list(MOB_UNDEAD, MOB_HUMANOID)
	mutanttongue = /obj/item/organ/tongue/zombie
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | ERT_SPAWN

/datum/species/zombie/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return ..()

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = "memezombies"
	limbs_id = "zombie"
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 1.6
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie
	var/heal_rate = 1
	var/regen_cooldown = 0
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

/datum/species/zombie/infectious/check_roundstart_eligible()
	return FALSE


/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(20, amount)

/datum/species/zombie/infectious/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 2
		C.heal_overall_damage(heal_amt,heal_amt)
		C.adjustToxLoss(-heal_amt)
	if(!C.InCritical() && prob(4))
		playsound(C, pick(spooks), 50, TRUE, 10)

//Congrats you somehow died so hard you stopped being a zombie
/datum/species/zombie/infectious/spec_death(mob/living/carbon/C)
	. = ..()
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(infection)
		qdel(infection)

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	// Deal with the source of this zombie corruption
	//  Infection organ needs to be handled separately from mutant_organs
	//  because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(!infection)
		infection = new()
		infection.Insert(C)


// Your skin falls off
/datum/species/krokodil_addict
	name = "Human"
	id = "goofzombies"
	limbs_id = "zombie" //They look like zombies
	sexes = 0
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	mutanttongue = /obj/item/organ/tongue/zombie
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN

//The special zombie you get turned into in the zombie gamemode
/datum/species/zombie/infectious/gamemode
	armor = 25
	brutemod = 0.9
	burnmod = 0.9
	mutanthands = /obj/item/zombie_hand/gamemode
	inherent_traits = list(TRAIT_EASYDISMEMBER, TRAIT_RESISTCOLD, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE,
	TRAIT_RADIMMUNE, TRAIT_LIMBATTACHMENT, TRAIT_NOBREATH, TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_NOHUNGER, TRAIT_RESISTHEAT, TRAIT_SHOCKIMMUNE, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE, TRAIT_BADDNA)
	no_equip = list(SLOT_WEAR_MASK, SLOT_GLASSES, SLOT_HEAD)

/datum/species/zombie/infectious/gamemode/runner
	mutanthands = /obj/item/zombie_hand/gamemode/runner
	armor = 15 // 120 damage to KO a zombie, which kills it
	speedmod = 1
	brutemod = 1

/datum/species/zombie/infectious/gamemode/juggernaut
	armor = 35 // 120 damage to KO a zombie, which kills it
	brutemod = 0.8
	speedmod = 2
	heal_rate = 1.1

/datum/species/zombie/infectious/gamemode/spitter
	armor = 15 // 120 damage to KO a zombie, which kills it
	brutemod = 1
	burnmod = 1

/datum/species/zombie/infectious/gamemode/spec_stun(mob/living/carbon/human/H,amount)
	. = 0

/datum/species/zombie/infectious/gamemode/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	if(damagetype == STAMINA)
		return
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/carbon/proc/spitter_zombie_acid(O as obj|turf in oview(1)) // right click menu verb ugh
	set name = "Corrosive Acid"

	if(!isinfected(usr))
		return
	var/mob/living/carbon/user = usr
	var/datum/antagonist/zombie/A = locate() in user.mind.antag_datums
	if(!A)
		return

	if(A.spit_cooldown > world.time)
		to_chat(user, "<span class='userdanger'>Please wait. You will be able to use this ability in [(A.spit_cooldown - world.time) / 10] seconds</span>")
		return

	if(corrode_object(O, user))
		A.spit_cooldown = world.time + SPIT_COOLDOWN

/mob/living/carbon/proc/corrode_object(atom/target, mob/living/carbon/user = usr)
	if(target in oview(1, user))
		if(target.acid_act(300, 150))
			user.visible_message("<span class='alertalien'>[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
			return TRUE
		else
			to_chat(user, "<span class='noticealien'>You cannot dissolve this object.</span>")


			return FALSE
	else
		to_chat(src, "<span class='noticealien'>[target] is too far away.</span>")
		return FALSE

#undef REGENERATION_DELAY
#undef SPIT_COOLDOWN