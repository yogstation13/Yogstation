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

	///A list of food that the mob likes to eat
	var/list/food = list()

	///How many food did we eaten
	var/nutrition_amount = 0

	var/max_nutrition = GENERIC_XENO_MOB_MAX_NUTRITION

	///How adult the mob is
	var/stage = 1

	///At what stage the mob is considered as fully grown and will stop growing
	var/max_stage = 2

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

	if(!born) ///If the mob isn't born, we generate mutations.
		for(var/datum/xeno_mutation/mutation in possible_mutations)
			AddMut(mutation, FALSE, FALSE)
		for(var/datum/xeno_mutation/mutation in possible_inert_mutations)
			AddMut(mutation, TRUE, FALSE)
		gender = pick(possible_genders)

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