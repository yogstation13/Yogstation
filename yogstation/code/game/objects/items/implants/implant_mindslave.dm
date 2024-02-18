/obj/item/implant/mindslave
	name = "mindslave implant"
	desc = "Turn a crewmate into your eternal slave"
	var/mob/living/carbon/mindmaster

/obj/item/implant/mindslave/get_data()
	var/dat = {"
		<b>Implant Specifications:</b><BR>
		<b>Name:</b> Syndicate Loyalty Implant<BR>
		<b>Life:</b> Single use<BR>
		<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
		<HR>
		<b>Implant Details:</b> <BR>
		<b>Function:</b> Makes the injected a slave to the owner of the implant.<HR>
	"}
	return dat

/obj/item/implant/mindslave/implant(mob/living/carbon/target, mob/user, silent = FALSE, force = FALSE)

	if(!target.mind)
		to_chat(user, span_notice("[target] doesn't posses the mental capabilities to be a slave."))
		return FALSE
	mindmaster = user

	if(target == mindmaster)
		to_chat(mindmaster, span_notice("You can't implant yourself!"))
		return FALSE

	var/obj/item/implant/mindslave/imp = locate(src.type) in target
	if(imp)
		to_chat(mindmaster, span_warning("[target] is already a slave!"))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(mindmaster, span_warning("[target] seems to resist the implant!"))
		return FALSE

	slave_mob(target)
	return ..()

/obj/item/implant/mindslave/proc/slave_mob(mob/living/carbon/target)
	if(!mindmaster)
		return
	if(is_mindslaved(target)) // woah now
		return
	to_chat(target, span_hypnophrase("<FONT size = 3>You feel a strange urge to serve [mindmaster.real_name]. A simple thought about disobeying [mindmaster.p_their()] commands makes your head feel like it is going to explode. You feel like you dont want to know what will happen if you actually disobey your new master.</FONT>"))

	var/datum/antagonist/mindslave/MS = new
	target.mind.add_antag_datum(MS)
	MS.master = mindmaster
	var/datum/objective/mindslave/new_objective = new /datum/objective/mindslave
	MS.objectives += new_objective
	new_objective.explanation_text = "Serve [mindmaster.real_name] no matter what!"

	log_game("[mindmaster.ckey] enslaved [target.ckey] with a Mindslave implant")

/obj/item/implant/mindslave/removed(mob/living/source, silent = 0, special = 0)
	if(!..())
		return
	if(source.mind && source.mind.has_antag_datum(/datum/antagonist/mindslave))
		source.mind.remove_antag_datum(/datum/antagonist/mindslave)
		to_chat(source,span_userdanger("You feel your free will come back to you! You no longer have to obey your master!"))
		if(!source.mind.has_antag_datum(/datum/antagonist))
			to_chat(source,span_notice("You are no longer an antagonist."))

/obj/item/implanter/mindslave
	name = "implanter (mindslave)"
	imp_type = /obj/item/implant/mindslave
