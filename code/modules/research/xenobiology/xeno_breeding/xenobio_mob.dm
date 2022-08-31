/mob/living/simple_animal/hostile/retaliate/xenobio
	name = "fucking xenos"
	desc = "This dude shoudln't exist."
	faction = list("neutral")

	///What active mutations do we currently have?
	var/list/current_mutations = list()

	///With what active mutations can we start?
	var/list/possible_mutations = list()

	///A list of inert mutations
	var/list/inert_mutations = list()

	///With what inert mutations can we start?
	var/list/possible_inert_mutations = list()

	///Mutations blacklist and whitelist
	var/list/mutation_whitelist = list()
	var/list/mutation_blacklist = list()

	///A list of food that the mob likes to eat. Please don't put anything except objects and mobs.
	var/list/food = list()

	///How many nutrition does the mob get from eating food?
	var/nutrition_from_feeding = 25

	///What happens to eaten atoms?
	var/eating_action = QDEL_ON_EATING_OBJECTS

	///How many food did we eaten
	var/nutrition_amount = 0

	///Maximal amount of nutrition
	var/max_nutrition = GENERIC_XENO_MOB_MAX_NUTRITION

	///How adult the mob is
	var/stage = 1

	///At what stage the mob is considered as fully grown and will stop growing
	var/max_stage = 2

	///The growth progress. Gained by eating.
	var/stage_progress = 0

	///How many food we need to eat to get to next stage
	var/stage_progress_req = 75

	///How each stage is named
	var/list/stage_names = list(
		1 = "Baby", \
		2 = "Adult", \
	)

	///What genders can start with?
	var/list/possible_genders = list(MALE, FEMALE) 

///If the mob is spawned by map generation or other similar things, it gets it's mutations from possible mutations list. Otherwise it is handeled by the thing that creates the mob.
/mob/living/simple_animal/hostile/retaliate/xenobio/New(loc, born = FALSE)
	. = ..()
	if(mutation_whitelist.len)
		mutation_whitelist = typecacheof(mutation_whitelist)
	if(mutation_blacklist.len)
		mutation_blacklist = typecacheof(mutation_blacklist)

	if(food.len)
		food = typecacheof(food)
		wanted_objects += food
		for(var/i in food)
			if(isobj(i))
				search_objects = 1
				break

	if(!born) ///If the mob isn't born, we generate mutations.
		for(var/datum/xeno_mutation/mutation in possible_mutations)
			AddMut(mutation, FALSE, FALSE)
		for(var/datum/xeno_mutation/mutation in possible_inert_mutations)
			AddMut(mutation, TRUE, FALSE)
		gender = pick(possible_genders)
	RegisterSignal(src, COMSIG_LIVING_BIOLOGICAL_LIFE, .proc/LifeTick)

/mob/living/simple_animal/hostile/retaliate/xenobio/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_LIVING_BIOLOGICAL_LIFE)

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/get_all_muts()
	var/list/mymuts = current_mutations + inert_mutations
	return mymuts

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/AddMut(mutation, inert = FALSE, force = FALSE)
	if(!mutation)
		return
	var/datum/xeno_mutation/new_mut
	if(!ispath(mutation))
		new_mut = mutation
		if(!istype(new_mut))
			return
	else
		new_mut = new mutation()
	if(!new_mut.AddToMob(src, inert, force))
		qdel(new_mut)

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/LifeTick()
	HandleHungerAndGrowth()
	
/mob/living/simple_animal/hostile/retaliate/xenobio/proc/HandleHungerAndGrowth()
	if(stat == DEAD)
		return
	adjust_nutrition_amount(-1)
	
/mob/living/simple_animal/hostile/retaliate/xenobio/proc/adjust_nutrition_amount(amount)
	if(nutrition > 0)
		adjust_growth_stage_progress(amount)
	nutrition += amount
	if(nutrition > max_nutrition)
		nutrition = max_nutrition
	if(nutrition < 0)
		nutrition = 0
	if(nutrition == 0 && prob(XENOBIO_MOB_ANGER_CHANCE))
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/adjust_growth_stage_progress(amount)
	if(stage >= max_stage)
		return
	stage_progress += amount
	if(stage_progress < 0)
		stage_progress = 0
	if(stage_progress >= stage_progress_req)
		stage_progress = 0
		adjust_growth_stage(1)

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/adjust_growth_stage(amount)
	stage += amount
	if(stage > max_stage)
		stage = max_stage
	if(stage < 1)
		stage = 1
	var/stage_name = stage_names[stage]
	name = "[stage_name] [initial(name)]"
	handle_growth_icons()

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/handle_growth_icons()
	return

/mob/living/simple_animal/hostile/retaliate/xenobio/CanAttack(atom/the_target)
	if(is_type_in_typecache(the_target, food))
		if(isliving(the_target))
			var/mob/living/L = the_target
			///If our wanted food mob is suitable for eating(unconsinous or dead), but we are not hungry - ignore
			if((L.stat == UNCONSCIOUS || L.stat == DEAD) && nutrition >= max_nutrition)
				return FALSE
		else
			if(nutrition >= max_nutrition)
				return FALSE
	return ..()

/mob/living/simple_animal/hostile/retaliate/xenobio/AttackingTarget()
	if(is_type_in_typecache(target, food))
		Eat(target)
	return ..()

/mob/living/simple_animal/hostile/retaliate/xenobio/proc/Eat(atom/movable/the_target)
	if(!istype(the_target)) ///We don't eat anything except movable atoms!
		return
	visible_message(span_danger("[src] starts devouring [the_target]."), span_notice("You start devouring [the_target]."))
	if(isliving(the_target))
		to_chat(the_target, span_userdanger("[src] starts devouring you!"))
	if(nutrition >= max_nutrition)
		return
	if (!do_after(src, 2 SECONDS, the_target))
		return
	adjust_nutrition_amount(nutrition_from_feeding)
	visible_message(span_danger("[src] devours [the_target]."), span_notice("You devour [the_target]."))
	the_target.forceMove(src)
	if(isliving(the_target))
		to_chat(the_target, span_userdanger("[src] devours you!"))
		if(eating_action == QDEL_ON_EATING_EVERYTHING || eating_action == QDEL_ON_EATING_MOBS)
			qdel(the_target)
			return
		var/mob/living/L = the_target
		L.death() ///You are vored, die
	else if(isobj(the_target))
		if(eating_action == QDEL_ON_EATING_EVERYTHING || eating_action == QDEL_ON_EATING_OBJECTS)
			qdel(the_target)
