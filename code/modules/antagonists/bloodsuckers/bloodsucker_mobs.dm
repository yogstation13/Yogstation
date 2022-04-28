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
	maxHealth = 800
	health = 800
	harm_intent_damage = 25
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "violently mawls"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 5)
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_WALLS
	speak_emote = list("gnashes")
	var/satiation = 0

/mob/living/simple_animal/hostile/bloodsucker/giantbat
	name = "giant bat"
	desc = "That's a fat ass bat."
	icon_state = "batform"
	icon_living = "batform"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	maxHealth = 500
	health = 500
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

///////////////////////////////
///      Inheritances       ///
///////////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/Destroy() //makes us alive again
	if(bloodsucker && mind)
		visible_message(span_warning("[src] rapidly transforms into a humanoid figure!"), span_warning("You forcefully return to your normal form."))
		playsound(src, 'sound/weapons/slash.ogg', 50, 1)
		if(mind)
			mind.transfer_to(bloodsucker)
		bloodsucker.forceMove(get_turf(src))
		if(istype(src, /mob/living/simple_animal/hostile/bloodsucker/werewolf) && istype(src, /mob/living/simple_animal/hostile/bloodsucker/possessedarmor))
			STOP_PROCESSING(SSprocessing, src)
		return ..()

/mob/living/simple_animal/hostile/bloodsucker/death()
	if(bloodsucker && mind)
		mind.transfer_to(bloodsucker)
		bloodsucker.death()
	if(src)
		addtimer(CALLBACK(src, .proc/gib), 20 SECONDS)
	..()

/mob/living/simple_animal/hostile/bloodsucker/proc/devour(mob/living/target)
	if(istype(src, /mob/living/simple_animal/hostile/bloodsucker/werewolf))
		var/mob/living/simple_animal/hostile/bloodsucker/werewolf/ww = src
		ww.satiation++
		src.visible_message(span_danger("[src] devours [target] whole!"), \
		span_userdanger("You devour [target] and feel the beast inside you sedate itself a little, you'll need to feast [3 - ww.satiation] more times to become human again."))
	health += target.maxHealth / 4
	target.gib()

////////////////////////////
///      Werewolf       ///
///////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/werewolf/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/mob/living/simple_animal/hostile/bloodsucker/werewolf/process()
	if(bloodsucker)
		initial(health) -= 0.44444444 //3 minutes to die
	if(satiation == 3)
		to_chat(src, span_notice("It has been fed. You turn back to normal."))
		qdel(src)
	return

/mob/living/simple_animal/hostile/bloodsucker/werewolf/Destroy()
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
				mutation = /obj/item/clothing/ears/wolfears
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
			if(5 to INFINITY)
				to_chat(user, span_danger("The beast inside of you seems satisfied with your current form."))
				return
		to_chat(user, span_danger("After returning to normal, you feel strange. [additionalmessage]"))
		var/obj/item/pastdrip = user.get_item_by_slot(slot)
		user.dropItemToGround(pastdrip)
		user.equip_to_slot_or_del(new mutation(user), slot)
	return ..()

////////////////////////
///      Armor       ///
////////////////////////

/mob/living/simple_animal/hostile/bloodsucker/possessedarmor/death()
	if(upgraded)
		new /obj/structure/bloodsucker/possessedarmor/upgraded(src.loc)
	else
		new /obj/structure/bloodsucker/possessedarmor(src.loc)
	qdel(src)
	..()