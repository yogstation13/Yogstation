/mob/living/simple_animal/hostile/bloodsucker
	icon = 'icons/mob/bloodsucker_mobs.dmi'
	harm_intent_damage = 20
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 10
	speak_chance = 0
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = FALSE
	movement_type = GROUND
	attack_sound = 'sound/weapons/slash.ogg'
	faction = list("hostile", "bloodhungry")
	response_help = "touches"
	response_disarm = "flails at"
	response_harm = "punches"
	var/mob/living/bloodsucker

/mob/living/simple_animal/hostile/bloodsucker/werewolf
	name = "werewolf"
	desc = "Who could imagine this things 'were' actually real?"
	icon_state = "wolfform"
	icon_living = "wolfform"
	icon_dead = "wolf_dead"
	icon_gib = "wolf_dead"
	speed = -1.5
	maxHealth = 450
	health = 450
	harm_intent_damage = 25
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "violently mawls"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 5)
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_WALLS
	speak_emote = list("gnashes")
	del_on_death = TRUE
	var/satiation = 0

/mob/living/simple_animal/hostile/bloodsucker/giantbat
	name = "giant bat"
	desc = "That's a fat ass bat."
	icon_state = "batform"
	icon_living = "batform"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	maxHealth = 350
	health = 350
	attacktext = "bites"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 35
	pass_flags = PASSTABLE | PASSCOMPUTER
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	movement_type = FLYING
	speak_emote = list("loudly squeaks")

/mob/living/simple_animal/hostile/bloodsucker/possessedarmor
	name = "possessed armor"
	desc = "Whatever possessed this suit of armor to suddenly walk about and start killing everyone?"
	icon_state = "posarmor"
	icon_living = "posarmor"
	response_help = "pokes"
	response_disarm = "pushes"
	response_harm = "punches"
	maxHealth = 250
	health = 250
	attacktext = "rends"
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_emote = list("manifests")
	var/upgraded = FALSE

/mob/living/simple_animal/hostile/bloodsucker/possessedarmor/upgraded
	name = "armed possessed armor"
	icon_state = "posarmor_sword"
	icon_living = "posarmor_sword"
	upgraded = TRUE
	obj_damage = 55
	harm_intent_damage = 25
	melee_damage_lower = 25
	melee_damage_upper = 25

/////////////////////////////////////////////////////
///          TZIMISCE BLOODSUCKER MOBS            ///
/////////////////////////////////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/tzimisce

/mob/living/simple_animal/hostile/bloodsucker/tzimisce/triplechest
	name = "gigantous monstrosity"
	desc = "You wouldn't think a being so messed up like this would be able to even breathe."
	icon_state = "triplechest"
	icon_living = "triplechest"
	icon_dead = "triplechest_dead"
	speed = 1
	maxHealth = 175
	health = 175
	environment_smash = ENVIRONMENT_SMASH_WALLS
	harm_intent_damage = 25
	melee_damage_lower = 25
	melee_damage_upper = 25
	obj_damage = 50
	
/mob/living/simple_animal/hostile/bloodsucker/tzimisce/calcium
	name = "boney monstrosity"
	desc = "Heretical being beyond comprehesion, now with bones free of charge!"
	icon_state = "calcium"
	icon_living = "calcium"
	icon_dead = "calcium_dead"
	speed = -1
	maxHealth = 110
	health = 110
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	harm_intent_damage = 7
	melee_damage_lower = 7
	melee_damage_upper = 7
	obj_damage = 20

/mob/living/simple_animal/hostile/bloodsucker/tzimisce/armmy
	name = "tiny monstrosity"
	desc = "Is that a head?!"
	icon_state = "armmy"
	icon_living = "armmy"
	icon_dead = "armmy_dead"
	speed = -2
	maxHealth = 75
	health = 75
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_sound = 'sound/weapons/bite.ogg'
	obj_damage = 10

///////////////////////////////
///      Inheritances       ///
///////////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/Destroy() //makes us alive again
	if(bloodsucker && mind)
		visible_message(span_warning("[src] rapidly transforms into a humanoid figure!"), span_warning("You forcefully return to your normal form."))
		playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
		mind.transfer_to(bloodsucker)
		if(bloodsucker.status_flags & GODMODE)
			bloodsucker.status_flags -= GODMODE
		bloodsucker.forceMove(get_turf(src))
		if(istype(src, /mob/living/simple_animal/hostile/bloodsucker/possessedarmor))
			STOP_PROCESSING(SSprocessing, src)
		return ..()

/mob/living/simple_animal/hostile/bloodsucker/death()
	. = ..()
	if(bloodsucker && mind)
		mind.transfer_to(bloodsucker)
		bloodsucker.adjustBruteLoss(200)
		if(bloodsucker.status_flags & GODMODE)
			bloodsucker.status_flags -= GODMODE

/mob/living/simple_animal/hostile/bloodsucker/proc/devour(mob/living/target)
	if(maxHealth > target.maxHealth / 4 + health)
		health += target.maxHealth / 4
	else
		health += maxHealth - health
	var/mob/living/carbon/human/H = target
	var/foundorgans = 0
	for(var/obj/item/organ/O in H.internal_organs)
		if(O.zone == "chest")
			foundorgans++
			qdel(O)
	if(foundorgans)
		if(istype(src, /mob/living/simple_animal/hostile/bloodsucker/werewolf))
			var/mob/living/simple_animal/hostile/bloodsucker/werewolf/ww = src
			ww.satiation++
			src.visible_message(span_danger("[src] devours [target]'s organs!"), \
			span_userdanger("As you devour [target]'s organs you feel as if the beast inside you has calmed itself down, you'll need to feast [3 - ww.satiation] more times to become human again."))
	for(var/obj/item/bodypart/B in H.bodyparts)
		if(B.body_zone == "chest")
			B.dismember()
		else
			to_chat(src, span_warning("There are no organs left in this corpse."))

///////////////////////////
///      Tzimisce       ///
///////////////////////////

////////////////////////////
///      Werewolf       ///
///////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/werewolf/Life(delta_time = (SSmobs.wait/10), times_fired)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_BIOLOGICAL_LIFE, delta_time, times_fired)
	if(bloodsucker)
		if(ishuman(bloodsucker))
			var/mob/living/carbon/human/user = bloodsucker
			var/datum/antagonist/bloodsucker/bloodsuckerdatum = src.mind.has_antag_datum(/datum/antagonist/bloodsucker)
			if(user.blood_volume < FRENZY_THRESHOLD_EXIT + bloodsuckerdatum.humanity_lost * 10)
				user.blood_volume += 10
		adjustFireLoss(2.5)
		updatehealth() //3 minutes to die
	if(satiation >= 3)
		to_chat(src, span_notice("It has been fed. You turn back to normal."))
		qdel(src)
	return

/mob/living/simple_animal/hostile/bloodsucker/werewolf/Destroy()
	. = ..()
	if(ishuman(bloodsucker))
		var/mob/living/carbon/human/user = bloodsucker
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
		var/datum/species/user_species = user.dna.species
		var/mutation = ""
		var/slot = ""
		var/additionalmessage = ""
		bloodsuckerdatum.clanprogress++
		switch(bloodsuckerdatum.clanprogress)
			if(1)
				additionalmessage = "You have mutated a collar made out of fur!"
				user_species.armor += 10
				mutation = /obj/item/clothing/neck/wolfcollar
				slot = SLOT_NECK
			if(2)
				additionalmessage = "You have mutated werewolf ears!"
				mutation = /obj/item/radio/headset/wolfears
				slot = SLOT_EARS
			if(3)
				additionalmessage = "You have mutated werewolf claws!"
				user_species.punchdamagelow += 2.5
				user_species.punchdamagehigh += 2.5
				mutation = /obj/item/clothing/gloves/wolfclaws
				slot = SLOT_GLOVES
			if(4)
				additionalmessage = "You have mutated werewolf legs!"
				mutation = /obj/item/clothing/shoes/wolflegs
				slot = SLOT_SHOES
				if(DIGITIGRADE in user.dna.species.species_traits)
					mutation = /obj/item/clothing/shoes/xeno_wraps/wolfdigilegs
			if(5 to INFINITY)
				to_chat(user, span_danger("The beast inside of you seems satisfied with your current form."))
				return
		to_chat(user, span_danger("After returning to normal, you feel strange. [additionalmessage]"))
		var/obj/item/pastdrip = user.get_item_by_slot(slot)
		user.dropItemToGround(pastdrip)
		user.equip_to_slot_or_del(new mutation(user), slot)

////////////////////////
///      Armor       ///
////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/possessedarmor/death()
	. = ..()
	if(upgraded)
		new /obj/structure/bloodsucker/possessedarmor/upgraded(src.loc)
	else
		new /obj/structure/bloodsucker/possessedarmor(src.loc)
	qdel(src)