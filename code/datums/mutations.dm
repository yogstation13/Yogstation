/datum/mutation

	var/name

/datum/mutation/human
	name = "mutation"
	var/desc = "A mutation."
	///Whether the mutation is locked, and therefore will not show up in
	///people's genes randomly.
	var/locked
	var/quality
	var/get_chance = 100
	var/lowest_value = 256 * 8
	var/text_gain_indication = ""
	var/text_lose_indication = ""
	var/static/list/list/mutable_appearance/visual_indicators = list()
	/// The path of action we grant to our user on mutation gain
	var/datum/action/cooldown/spell/power_path
	var/layer_used = MUTATIONS_LAYER //which mutation layer to use
	var/list/species_allowed = list() //to restrict mutation to only certain species
	var/health_req //minimum health required to acquire the mutation
	var/limb_req //required limbs to acquire this mutation
	var/time_coeff = 1 //coefficient for timed mutations
	var/datum/dna/dna
	var/mob/living/carbon/human/owner
	var/instability = 0 //instability the holder gets when the mutation is not native
	var/blocks = 4 //Amount of those big blocks with gene sequences
	var/difficulty = 8 //Amount of missing sequences. Sometimes it removes an entire pair for 2 points
	var/timed = FALSE   //Boolean to easily check if we're going to self destruct
	var/alias           //'Mutation #49', decided every round to get some form of distinction between undiscovered mutations
	var/scrambled = FALSE //Wheter we can read it if it's active. To avoid cheesing with mutagen
	var/class           //Decides player accesibility, sorta
	var/list/conflicts //any mutations that might conflict. put mutation typepath defines in here. make sure to enter it both ways (so that A conflicts with B, and B with A)
	
	///Boolean on whether the mutation can be transferred through cloning
	var/allow_transfer = FALSE
	///Boolean on whether the mutation can be downloaded onto a DNA console and cloned.
	var/allow_cloning = TRUE
	//MUT_NORMAL - A mutation that can be activated and deactived by completing a sequence
	//MUT_EXTRA - A mutation that is in the mutations tab, and can be given and taken away through though the DNA console. Has a 0 before it's name in the mutation section of the dna console
	//MUT_OTHER Cannot be interacted with by players through normal means. I.E. wizards mutate


	var/can_chromosome = CHROMOSOME_NONE //can we take chromosomes? 0: CHROMOSOME_NEVER never,  1:CHROMOSOME_NONE yeah, 2: CHROMOSOME_USED no, already have one
	var/chromosome_name   //purely cosmetic
	var/modified = FALSE  //ugly but we really don't want chromosomes and on_acquiring to overlap and apply double the powers
	var/mutadone_proof = FALSE

	//Chromosome stuff - set to -1 to prevent people from changing it. Example: It'd be a waste to decrease cooldown on mutism
	var/stabilizer_coeff = 1 //genetic stability coeff
	var/synchronizer_coeff = -1 //makes the mutation hurt the user less
	var/power_coeff = -1 //boosts mutation strength
	var/energy_coeff = -1 //lowers mutation cooldown
	var/list/valid_chrom_list = list() //List of strings of valid chromosomes this mutation can accept.

/datum/mutation/human/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	. = ..()
	class = class_
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(remove)), timer)
		timed = TRUE
	if(copymut && istype(copymut, /datum/mutation/human))
		copy_mutation(copymut)
	update_valid_chromosome_list()

/datum/mutation/human/proc/on_acquiring(mob/living/carbon/human/H)
	if(!H || !istype(H) || H.stat == DEAD || (src in H.dna.mutations))
		return TRUE
	for(var/i in H.dna.mutations)
		if(is_type_in_list(i, conflicts))
			return TRUE
	if(species_allowed.len && !species_allowed.Find(H.dna.species.id))
		return TRUE
	if(health_req && H.health < health_req)
		return TRUE
	if(limb_req && !H.get_bodypart(limb_req))
		return TRUE
	owner = H
	dna = H.dna
	dna.mutations += src
	if(text_gain_indication)
		to_chat(owner, text_gain_indication)
	if(visual_indicators.len)
		var/list/mut_overlay = list(get_visual_indicator())
		if(owner.overlays_standing[layer_used])
			mut_overlay = owner.overlays_standing[layer_used]
			mut_overlay |= get_visual_indicator()
		owner.remove_overlay(layer_used)
		owner.overlays_standing[layer_used] = mut_overlay
		owner.apply_overlay(layer_used)
	grant_power() //we do checks here so nothing about hulk getting magic
	if(!modified)
		addtimer(CALLBACK(src, PROC_REF(modify), 0.5 SECONDS)) //gonna want children calling ..() to run first

/datum/mutation/human/proc/get_visual_indicator()
	return

/datum/mutation/human/proc/on_attack_hand( atom/target, proximity)
	return

/datum/mutation/human/proc/on_ranged_attack(atom/target)
	return

/datum/mutation/human/proc/on_life()
	return

/datum/mutation/human/proc/on_losing(mob/living/carbon/human/owner)
	if(owner && istype(owner) && (owner.dna.mutations.Remove(src)))
		if(text_lose_indication && owner.stat != DEAD)
			to_chat(owner, text_lose_indication)
		if(visual_indicators.len)
			var/list/mut_overlay = list()
			if(owner.overlays_standing[layer_used])
				mut_overlay = owner.overlays_standing[layer_used]
			owner.remove_overlay(layer_used)
			mut_overlay.Remove(get_visual_indicator())
			owner.overlays_standing[layer_used] = mut_overlay
			owner.apply_overlay(layer_used)
		if(power_path)
			// Any powers we made are linked to our mutation datum,
			// so deleting ourself will also delete it and remove it
			// ...Why don't all mutations delete on loss? Not sure.
			qdel(src)
		return 0
	return 1

/mob/living/carbon/proc/update_mutations_overlay()
	return

/mob/living/carbon/human/update_mutations_overlay()
	for(var/datum/mutation/human/CM in dna.mutations)
		if(CM.species_allowed.len && !CM.species_allowed.Find(dna.species.id))
			dna.force_lose(CM) //shouldn't have that mutation at all
			continue
		if(CM.visual_indicators.len)
			var/list/mut_overlay = list()
			if(overlays_standing[CM.layer_used])
				mut_overlay = overlays_standing[CM.layer_used]
			var/mutable_appearance/V = CM.get_visual_indicator()
			if(!mut_overlay.Find(V)) //either we lack the visual indicator or we have the wrong one
				remove_overlay(CM.layer_used)
				for(var/mutable_appearance/MA in CM.visual_indicators[CM.type])
					mut_overlay.Remove(MA)
				mut_overlay |= V
				overlays_standing[CM.layer_used] = mut_overlay
				apply_overlay(CM.layer_used)

/**
 * Called when a chromosome is applied so we can properly update some stats
 * without having to remove and reapply the mutation from someone
 *
 * Returns `null` if no modification was done, and
 * returns an instance of a power if modification was complete
 */
/datum/mutation/human/proc/modify() //called when a genome is applied so we can properly update some stats without having to remove and reapply the mutation from someone
	if(modified || !power_path || !owner)
		return
	var/datum/action/cooldown/spell/modified_power = locate(power_path) in owner.actions
	if(!modified_power)
		CRASH("Genetic mutation [type] called modify(), but could not find a action to modify!")
	modified_power.cooldown_time *= GET_MUTATION_ENERGY(src) // Doesn't do anything for mutations with energy_coeff unset
	return modified_power

/datum/mutation/human/proc/copy_mutation(datum/mutation/human/HM)
	if(!HM)
		return
	chromosome_name = HM.chromosome_name
	stabilizer_coeff = HM.stabilizer_coeff
	synchronizer_coeff = HM.synchronizer_coeff
	power_coeff = HM.power_coeff
	energy_coeff = HM.energy_coeff
	mutadone_proof = HM.mutadone_proof
	can_chromosome = HM.can_chromosome
	valid_chrom_list = HM.valid_chrom_list

/datum/mutation/human/proc/remove_chromosome()
	stabilizer_coeff = initial(stabilizer_coeff)
	synchronizer_coeff = initial(synchronizer_coeff)
	power_coeff = initial(power_coeff)
	energy_coeff = initial(energy_coeff)
	mutadone_proof = initial(mutadone_proof)
	can_chromosome = initial(can_chromosome)
	chromosome_name = null

/datum/mutation/human/proc/remove()
	if(dna)
		dna.force_lose(src)
	else
		qdel(src)

/datum/mutation/human/proc/grant_power()
	if(!ispath(power_path) || !owner)
		return FALSE

	var/datum/action/cooldown/new_power = new power_path(src)
	new_power.background_icon_state = "bg_tech_blue"
	new_power.base_background_icon_state = new_power.background_icon_state
	new_power.active_background_icon_state = "[new_power.base_background_icon_state]_on"
	new_power.overlay_icon_state = "bg_tech_blue_border"
	new_power.active_overlay_icon_state = null
	new_power.panel = "Genetic"
	new_power.Grant(owner)

	return new_power

// Runs through all the coefficients and uses this to determine which chromosomes the
// mutation can take. Stores these as text strings in a list.
/datum/mutation/human/proc/update_valid_chromosome_list()
	valid_chrom_list.Cut()

	if(can_chromosome == CHROMOSOME_NEVER)
		valid_chrom_list += "none"
		return

	valid_chrom_list += "Reinforcement"

	if(stabilizer_coeff != -1)
		valid_chrom_list += "Stabilizer"
	if(synchronizer_coeff != -1)
		valid_chrom_list += "Synchronizer"
	if(power_coeff != -1)
		valid_chrom_list += "Power"
	if(energy_coeff != -1)
		valid_chrom_list += "Energetic"
