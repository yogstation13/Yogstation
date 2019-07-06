/obj/item/implant/mindslave
	name = "mindslave implant"
	desc = "Turn a crewmate into your eternal slave"
	activated = FALSE

/obj/item/implant/mindslave/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Syndicate Loyalty Implant<BR>
<b>Life:</b> Single use<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Makes the injected a slave to the owner of the implant.<HR>"}
	return dat

/obj/item/implant/mindslave/implant(mob/source, mob/user)

	if(!source.mind)
		to_chat(user.mind, "<span class='notice'>[source] doesn't posses the mental capabilities to be a slave.</span>")
		return FALSE

	var/mob/living/carbon/target = source
	var/mob/living/carbon/holder = user

	if(target == holder)
		to_chat(holder, "<span class='notice'>You can't implant yourself!</span>")
		return FALSE

	var/obj/item/implant/mindslave/imp = locate(src.type) in source
	if(imp)
		to_chat(holder, "<span class='warning'>[target] is already a slave!</span>")
		return FALSE

	if(target.has_trait(TRAIT_MINDSHIELD))
		to_chat(holder, "<span class='warning'>[target] seems to resist the implant!</span>")
		return FALSE

	to_chat(target, "<span class='userdanger'><FONT size = 3>You feel a strange urge to serve [holder.real_name]. A simple thought about disobeying his/her commands makes your head feel like it is going to explode. You feel like you dont want to know what will happen if you actually disobey your new master.</FONT></span>")

	var/datum/antagonist/mindslave/MS = new
	target.mind.add_antag_datum(MS)
	MS.master = user
	var/datum/objective/mindslave/new_objective = new /datum/objective/mindslave
	MS.objectives += new_objective
	new_objective.explanation_text = "Serve [holder.real_name] no matter what!"

	log_game("[holder.ckey] enslaved [target.ckey] with a Mindslave implant")

	return ..()

/obj/item/implant/mindslave/removed(mob/source)
	if(!..())
		return
	if(source.mind && source.mind.has_antag_datum(/datum/antagonist/mindslave))
		source.mind.remove_antag_datum(/datum/antagonist/mindslave)
		to_chat(source,"<span class='userdanger'>You feel your free will come back to you! You no longer have to obey your master!</span>")
		if(!source.mind.has_antag_datum(/datum/antagonist))
			to_chat(source,"<span class='notice'>You are no longer an antagonist.</span>")

/obj/item/implanter/mindslave
	name = "implanter (mindslave)"

/obj/item/implanter/mindslave/Initialize()
	imp = new /obj/item/implant/mindslave(src)
	..()