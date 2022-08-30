/datum/xeno_mutation/organ
	name = "Crayon"
	continous = TRUE

	///What items need to be inside the mob in order to mutation have it's effect or punish the mob
	var/list/organ_types = list(/obj/item/toy/crayon) //Don't put here anything except items please

	///How much valid organs do we need to have in order to have effect?
	var/organ_amount = 1

	///A list of items created by mutating this
	var/list/organs_created = list()

	///Delete organs on mutation deactivation, or no
	var/del_on_deactivation = FALSE

	///Create required organs, or no
	var/create_organs = TRUE

/datum/xeno_mutation/organ/Activate()
	. = ..()
	if(create_organs)
		for(var/numbo in 1 to organ_amount)
			var/organ_type = pick(organ_types)
			var/atom/organ = new organ_type (mymob)
			organs_created |= organ
	organ_types = typecacheof(organ_types)

/datum/xeno_mutation/organ/on_mob_life()
	var/valid_organ_amount = 0
	for(var/atom/movable/AM in mymob)
		if(!istype(AM))
			continue
		if(!IsValidOrgan(AM))
			continue
		valid_organ_amount++
	if(valid_organ_amount >= organ_amount)
		OrganEffect()
	else
		Punish()

/datum/xeno_mutation/organ/proc/IsValidOrgan(atom/movable/AM)
	return is_type_in_typecache(AM, organ_types)

/datum/xeno_mutation/organ/proc/Punish() ///Don't have required organs? Get something bad
	return

/datum/xeno_mutation/organ/proc/OrganEffect() ///Have required organs? The mutations has it effect. Or just doesnt punish. Who knows?
	return