/datum/xeno_mutation/reproduction
	name = "Cringe"
	coexisting = XENO_MUT_UNIQUE
	mut_type = XENO_MUT_REPRODUCTION

	var/datum/action/innate/xeno_reproduce/action

	var/action_name = "Become cringe"
	var/action_desc = "amongus"
	var/icon_icon = 'icons/mob/actions.dmi'
	var/button_icon_state = "default"

	var/inert_activation_chance = 35

	var/mutation_chance_chance = 5

/datum/xeno_mutation/reproduction/Activate()
	. = ..()
	if(action)
		action.Grant(mymob)
	else
		action = new
		action.name = action_name
		action.name = action_desc
		action.name = icon_icon
		action.name = button_icon_state
		action.linked_mutation = src
		action.UpdateButtonIcon()

/datum/xeno_mutation/reproduction/Deactivate(remove = FALSE)
	. = ..()
	qdel(action)

/datum/xeno_mutation/reproduction/proc/OnActionActivate()
	if(!CanReproduce())
		return FALSE

/datum/xeno_mutation/reproduction/proc/CanReproduce()
	if(mymob.stage < mymob.max_stage)
		to_chat(mymob, span_warning("You need to be an adult in order to reproduce!"))
		return FALSE
	if(mymob.nutrition < XENO_MOB_REPRODUCTION_COST * mymob.max_nutrition)
		to_chat(mymob, span_warning("You need to have atleast [mymob.max_nutrition*XENO_MOB_REPRODUCTION_COST] nutrition in order to reproduce!"))
		return FALSE

/datum/xeno_mutation/reproduction/proc/AddNewbornMobMuts(mob/living/simple_animal/hostile/retaliate/xenobio/baby)
	for(var/datum/xeno_mutation/mut in mymob.get_all_muts())
		if(!istype(mut))
			continue
		if(!mut.CanMutate(baby))
			continue
		var/datum/xeno_mutation/new_mut = new mut.type ()
		baby.AddMut(new_mut, mut.inert)

	for(var/datum/xeno_mutation/mut in baby.get_all_muts())
		if(!istype(mut))
			continue
		if(mut.inert && prob(inert_activation_chance))
			mut.Activate()
			continue
		if(prob(mutation_chance_chance))
			mut.AttemptChange()
			continue

/datum/action/innate/xeno_reproduce
	var/datum/xeno_mutation/reproduction/linked_mutation

/datum/action/innate/xeno_reproduce/Trigger()
	linked_mutation.OnActionActivate()

/datum/xeno_mutation/reproduction/segmentation
	name = "Segmentation Reproduction"
	action_name = "Split"
	action_desc = "Split into two copies of yourself."
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "slimesplit"

/datum/xeno_mutation/reproduction/segmentation/OnActionActivate()
	. = ..()
	if(!.)
		return
	mymob.nutrition -= mymob.max_nutrition*XENO_MOB_REPRODUCTION_COST
	stage = 1
	var/mob/living/simple_animal/hostile/retaliate/xenobio/baby = new mymob.type (get_turf(mymob))
	AddNewbornMobMuts(baby)
	to_chat(mymob, span_notice("You split yourself into two entities."))
	to_chat(baby, span_notice("You split yourself into two entities.")) 
	playsound(get_turf(src), 'sound/effects/wounds/blood1.ogg')
	