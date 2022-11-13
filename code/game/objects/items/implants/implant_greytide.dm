/obj/item/implant/greytide
	name = "Greytide implant"
	desc = "Turn a crewmate into greytider"
	activated = FALSE

/obj/item/implant/greytide/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Syndicate Greytide Implant<BR>
<b>Life:</b> Single use<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Makes the injected have a strong urge to break into places.<HR>"}
	return dat

/obj/item/implant/greytide/implant(mob/source, mob/user)

	if(!source.mind)
		to_chat(user.mind, span_notice("[source] doesn't posses the mental capabilities to be a greytider."))	//"doesn't posses the mental capabilities to be a greytider"
		return FALSE

	var/mob/living/carbon/target = source
	var/mob/living/carbon/holder = user

	if(target == holder)
		to_chat(holder, span_notice("You can't implant yourself!"))
		return FALSE

	var/obj/item/implant/greytide/imp = locate(src.type) in source
	if(imp)
		to_chat(holder, span_warning("[target] is already a slave!"))
		return FALSE

	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(holder, span_warning("[target] seems to resist the implant!"))
		return FALSE

	to_chat(target, span_userdanger("<FONT size = 3>You feel a strong urge to break everything.  You feel a strong loyalty to [holder.real_name] and your assistant brothers. You want to break into everything, but harming others isn't something you will do.</FONT>"))

	var/datum/antagonist/greytide/GT = new
	target.mind.add_antag_datum(GT)
	GT.master = user
	var/datum/objective/greytide/new_objective = new /datum/objective/greytide
	GT.objectives += new_objective
	new_objective.explanation_text = "Never betray [holder.real_name] or abandon your assistant brothers! Remember not to harm others "
	ADD_TRAIT(target, TRAIT_PACIFISM, "Greytide Implant")

	message_admins("[target.ckey] was implanted by with greytide implant ")
	log_game("[holder.ckey] enslaved [target.ckey] with a greytide implant")

	return ..()

/obj/item/implant/greytide/removed(mob/source)
	. = ..()
	if(!.)
		return
	if(source.mind && source.mind.has_antag_datum(/datum/antagonist/greytide))
		source.mind.remove_antag_datum(/datum/antagonist/greytide)
		to_chat(source,span_userdanger("You feel your free will come back to you! You no longer wish to break everything!"))
		if(!source.mind.has_antag_datum(/datum/antagonist))
			to_chat(source,span_notice("You are no longer an antagonist."))
	REMOVE_TRAIT(source, TRAIT_PACIFISM, "Greytide Implant")

/obj/item/implanter/greytide
	name = "implanter (greytide)"

/obj/item/implanter/greytide/Initialize()
	. = ..()
	imp = new /obj/item/implant/greytide(src)
