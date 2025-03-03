/// The weight used to pick a positive mutation.
#define POSITIVE_WEIGHT 5
/// The weight used to pick a neutral mutation.
#define NEUTRAL_WEIGHT 2
/// The weight used to pick a negative mutation.
#define NEGATIVE_WEIGHT 2
/// The percent chance that a mutation will have a random (non-stabilizer) chromosome applied, if applicable
#define CHROMOSOME_PROB 70
/// The percent chance that a mutation will have a stabilizer chromosome applied, if another chromosome wasn't already applied.
#define STABILIZER_PROB 15

/obj/item/disk/data/random
	name = "old DNA data disk"
	desc = "A dust-caked disk with DNA mutation info on it. Wonder what it has..."
	read_only = TRUE
	/// A weighted list of mutations, albeit a two layered one, so it will do a weighted pick for mutation quality, then pick a mutation of that quality.
	var/static/list/mutation_weights

/obj/item/disk/data/random/Initialize(mapload)
	. = ..()
	if(isnull(mutation_weights))
		mutation_weights = initialize_mutation_weights()

	var/mutation_type = pick_weight_recursive(mutation_weights)
	var/datum/mutation/human/mutation = new mutation_type(GET_INITIALIZED_MUTATION(mutation_type))
	roll_for_chromosome(mutation)?.apply(mutation)
	mutations += mutation

/// Randomly returns a valid initialized chromosome or null.
/obj/item/disk/data/random/proc/roll_for_chromosome(datum/mutation/human/mutation) as /obj/item/chromosome
	RETURN_TYPE(/obj/item/chromosome)
	var/chromosome_type
	var/list/valid_chromosomes = mutation.valid_chromosome_types() - /obj/item/chromosome/stabilizer
	if(length(valid_chromosomes) && prob(CHROMOSOME_PROB))
		chromosome_type = pick(valid_chromosomes)
	else if(prob(STABILIZER_PROB) && mutation.stabilizer_coeff != -1)
		chromosome_type = /obj/item/chromosome/stabilizer
	if(chromosome_type)
		return new chromosome_type

/// Returns a (recursive) weighted list of mutations.
/obj/item/disk/data/random/proc/initialize_mutation_weights() as /list
	RETURN_TYPE(/list)
	. = list()
	.[get_non_random_locked_mutations(GLOB.good_mutations)] = POSITIVE_WEIGHT
	.[get_non_random_locked_mutations(GLOB.not_good_mutations)] = NEUTRAL_WEIGHT
	.[get_non_random_locked_mutations(GLOB.bad_mutations)] = NEGATIVE_WEIGHT

/// Returns a list of the typepaths of mutations in the given list without the random_locked var enabled.
/obj/item/disk/data/random/proc/get_non_random_locked_mutations(list/mutations) as /list
	RETURN_TYPE(/list)
	. = list()
	for(var/datum/mutation/human/mutation as anything in mutations)
		if(!mutation.random_locked)
			.[mutation.type] = isnull(mutation.species_allowed) ? 2 : 3

#undef STABILIZER_PROB
#undef CHROMOSOME_PROB
#undef NEGATIVE_WEIGHT
#undef NEUTRAL_WEIGHT
#undef POSITIVE_WEIGHT
