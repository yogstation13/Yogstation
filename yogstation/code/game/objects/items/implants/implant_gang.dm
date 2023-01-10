/obj/item/implant/gang
	name = "gang implant"
	desc = "Makes you a gangster."
	activated = FALSE
	var/datum/team/gang/gang

/obj/item/implant/gang/Initialize(loc, setgang)
	.=..()
	gang = setgang

/obj/item/implant/gang/Destroy()
	gang = null
	return ..()

/obj/item/implant/gang/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Criminal brainwash implant<BR>
				<b>Life:</b> A few seconds after injection.<BR>
				<b>Important Notes:</b> Illegal<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that change the host's brain to be loyal to a certain organization.<BR>
				<b>Integrity:</b> Implant's EMP function will destroy itself in the process."}
	return dat

/obj/item/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(!target || !target.mind || target.stat == DEAD)
		return FALSE
	var/datum/antagonist/gang/G = target.mind.has_antag_datum(/datum/antagonist/gang)
	if(G && G.gang == G)
		return FALSE // it's pointless
	if(..())
		if(ishuman(target))

			var/success
			if(G)
				if(!istype(G, /datum/antagonist/gang/boss))
					success = TRUE	//Was not a gang boss, convert as usual
					target.mind.remove_antag_datum(/datum/antagonist/gang)
			else
				success = TRUE
			
			if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
				success = FALSE
			
			if(!success)
				target.visible_message(span_warning("[target] seems to resist the implant!"), span_warning("You feel the influence of your enemies try to invade your mind!"))
				return FALSE
			else
				target.mind.add_antag_datum(/datum/antagonist/gang, gang)
				qdel(src)
				return TRUE

/obj/item/implanter/gang
	name = "implanter (gang)"

/obj/item/implanter/gang/Initialize(loc, gang)
	if(!gang)
		return INITIALIZE_HINT_QDEL
	imp = new /obj/item/implant/gang(src,gang)
	.=..()
