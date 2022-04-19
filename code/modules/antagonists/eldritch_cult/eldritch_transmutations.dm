/datum/eldritch_transmutation
	var/name = "Transmutation Recipe"
	///Used with rituals, how many items this needs
	var/list/required_atoms = list()
	///What do we get out of this
	var/list/result_atoms = list()
	///string that quickly describes the required atoms
	var/required_shit_list

/datum/eldritch_transmutation/New()
	. = ..()
	var/list/temp_list
	for(var/X in required_atoms)
		var/atom/A = X
		temp_list += list(typesof(A))
	required_atoms = temp_list

/**
  * Special check for recipes
  *
  * If you are adding a more complex summoning or something that requires a special check that parses through all the atoms in an area override this.
  */
/datum/eldritch_transmutation/proc/recipe_snowflake_check(list/atoms,loc)
	return TRUE

/**
  * What happens once the recipe is succesfully finished
  *
  * By default this proc creates atoms from result_atoms list. Override this is you want something else to happen.
  */
/datum/eldritch_transmutation/proc/on_finished_recipe(mob/living/user,list/atoms,loc)
	if(result_atoms.len == 0)
		return FALSE

	for(var/A in result_atoms)
		new A(loc)

	return TRUE

/**
  * Used atom cleanup
  *
  * Overide this proc if you dont want ALL ATOMS to be destroyed. useful in many situations.
  */
/datum/eldritch_transmutation/proc/cleanup_atoms(list/atoms)
	for(var/X in atoms)
		var/atom/A = X
		if(!isliving(A))
			atoms -= A
			qdel(A)
	return

/**
  * If a transmutation for some reason needs to do stuff on life at any point
  *
  * Activated on SSprocess in the heretic antag
  */
/datum/eldritch_transmutation/proc/on_life(mob/user)
	return

//////////////
///Subtypes///
//////////////

/datum/eldritch_transmutation/curse
	var/timer = 5 MINUTES
	var/list/fingerprints = list()

/datum/eldritch_transmutation/curse/recipe_snowflake_check(list/atoms, loc)
	fingerprints = list()
	for(var/X in atoms)
		var/atom/A = X
		fingerprints |= A.return_fingerprints()
	listclearnulls(fingerprints)
	if(fingerprints.len == 0)
		return FALSE
	return TRUE

/datum/eldritch_transmutation/curse/on_finished_recipe(mob/living/user,list/atoms,loc)

	var/list/compiled_list = list()

	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(fingerprints[md5(H.dna.uni_identity)])
			compiled_list |= H

	if(compiled_list.len == 0)
		to_chat(user, span_warning("The items don't posses required fingerprints."))
		return FALSE

	var/mob/living/carbon/human/chosen_mob = input("Select the person you wish to curse","Your target") as null|anything in sortList(compiled_list, /proc/cmp_mob_realname_dsc)
	if(!chosen_mob)
		return FALSE
	curse(chosen_mob)
	addtimer(CALLBACK(src, .proc/uncurse, chosen_mob),timer)
	return TRUE

/datum/eldritch_transmutation/curse/proc/curse(mob/living/chosen_mob)
	return

/datum/eldritch_transmutation/curse/proc/uncurse(mob/living/chosen_mob)
	return

/datum/eldritch_transmutation/summon
	//Mob to summon
	var/mob/living/mob_to_summon

/datum/eldritch_transmutation/summon/on_finished_recipe(mob/living/user,list/atoms,loc)
	//we need to spawn the mob first so that we can use it in pollCandidatesForMob, we will move it from nullspace down the code
	var/mob/living/summoned = new mob_to_summon(loc)
	message_admins("[summoned.name] is being summoned by [user.real_name] in [loc]")
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as [summoned.name]", ROLE_HERETIC, null, FALSE, 100, summoned)
	if(!LAZYLEN(candidates))
		to_chat(user,span_warning("No ghost could be found..."))
		qdel(summoned)
		return FALSE
	var/mob/dead/observer/C = pick(candidates)
	log_game("[key_name_admin(C)] has taken control of ([key_name_admin(summoned)]), their master is [user.real_name]")
	summoned.ghostize(FALSE)
	summoned.key = C.key
	summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.has_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	return TRUE

//Ascension knowledge
/datum/eldritch_transmutation/final
	var/finished = FALSE

/datum/eldritch_transmutation/final/recipe_snowflake_check(list/atoms, loc,selected_atoms)
	if(finished)
		return FALSE
	var/counter = 0
	for(var/mob/living/carbon/human/H in atoms)
		selected_atoms |= H
		counter++
		if(counter == 3)
			return TRUE
	return FALSE

/datum/eldritch_transmutation/final/on_finished_recipe(mob/living/user, list/atoms, loc)
	finished = TRUE
	return TRUE

/datum/eldritch_transmutation/final/cleanup_atoms(list/atoms)
	. = ..()
	for(var/mob/living/carbon/human/H in atoms)
		atoms -= H
		H.gib()

/datum/eldritch_transmutation/basic
	name = "Attune Heart"
	required_atoms = list(/obj/item/living_heart)
	required_shit_list = "A living heart, which will be given a target for sacrifice or sacrifice its target if their corpse is on the rune."

/datum/eldritch_transmutation/basic/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	for(var/obj/item/living_heart/LH in atoms)
		if(!LH.target)
			return TRUE
		if(LH.target in atoms)
			return TRUE
	return FALSE

/datum/eldritch_transmutation/basic/on_finished_recipe(mob/living/user, list/atoms, loc)
	. = TRUE
	var/mob/living/carbon/carbon_user = user
	for(var/obj/item/living_heart/LH in atoms)

		if(LH.target && LH.target.stat == DEAD)
			to_chat(carbon_user,span_danger("Your patrons accepts your offer.."))
			var/mob/living/carbon/human/H = LH.target
			H.apply_status_effect(STATUS_EFFECT_BRAZIL_PENANCE)
			LH.target = null
			var/datum/antagonist/heretic/EC = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)

			EC.total_sacrifices++
			for(var/X in carbon_user.get_all_gear())
				if(!istype(X,/obj/item/forbidden_book))
					continue
				EC.charge += 2
				break

		if(!LH.target)
			var/datum/objective/A = new
			A.owner = user.mind
			var/list/targets = list()
			for(var/i in 0 to 3)
				var/list/BR = list()
				var/datum/mind/targeted =  A.find_target(blacklist = BR)//easy way, i dont feel like copy pasting that entire block of code
				if(!targeted)
					break
				if(targeted.current?.has_status_effect(STATUS_EFFECT_BRAZIL_PENANCE)) //stops people from being selected while afk in the shadow realm
					BR |= targeted
					i--
					continue
				targets[targeted.current.real_name] = targeted.current
			LH.target = targets[input(user,"Choose your next target","Target") in targets]
			qdel(A)
			if(LH.target)
				to_chat(user,span_warning("Your new target has been selected, go and sacrifice [LH.target.real_name]!"))

			else
				to_chat(user,span_warning("A target could not be found for the living heart."))

/datum/eldritch_transmutation/basic/cleanup_atoms(list/atoms)
	return

/datum/eldritch_transmutation/living_heart
	name = "Living Heart"
	required_atoms = list(/obj/item/organ/heart,/obj/effect/decal/cleanable/blood,/obj/item/reagent_containers/food/snacks/grown/poppy)
	result_atoms = list(/obj/item/living_heart)
	required_shit_list = "A pool of blood, a poppy, and a heart."

/datum/eldritch_transmutation/codex_cicatrix
	name = "Codex Cicatrix"
	required_atoms = list(/obj/item/organ/eyes,/obj/item/stack/sheet/animalhide/human,/obj/item/storage/book/bible,/obj/item/pen)
	result_atoms = list(/obj/item/forbidden_book)
	required_shit_list = "A bible, a sheet of human skin, a pen, and a pair of eyes."