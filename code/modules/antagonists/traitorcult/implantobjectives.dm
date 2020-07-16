#define CULT_TEAM_CLOCK /datum/antagonist/clockcult/agent
#define CULT_TEAM_BLOOD /datum/antagonist/cult/agent

/datum/objective/implant //implant x dudes with guvax implants
	name = "clockcult implant"
	explanation_text = "<span class='sevtug'>STab some dudes with these funny things</span>"
	var/dudes_to_stab = 0						//list of people who need to be implanted to win
	var/list/datum/mind/dudes_stabbed = list()  //list of people with the implants


/datum/objective/implant/New()
	..()
	dudes_to_stab = SSticker.mode.agent_scaling * rand(1,5) //1 to 5 implantees per agent
	update_explanation_text()

/datum/objective/implant/update_explanation_text()
	explanation_text = "<span class='sevtug'>Implant at least [dudes_to_stab] of these heretics with guvax capacitors, I'll need them later. Use a replica fabricator on an implanter to make one, and try to keep them alive please and thank you.</span>"

/datum/objective/implant/check_completion()
	var/successful_stabs = 0
	for(var/datum/mind/M in dudes_stabbed)
		if(considered_alive(M))
			successful_stabs++
		else
			successful_stabs += 0.5 //still get points if they're dead
	return successful_stabs >= dudes_to_stab

/datum/objective/implant/blood
	name = "bloodcult implant"

/datum/objective/implant/blood/update_explanation_text()
	explanation_text = "<span class='cultbold'>Implant at least [dudes_to_stab] of the nonbelievers with soulshards created from using twisted construction on implanters. Keeping them alive is preferable.</span>"

/datum/antagonist/cult_implanted //used for guvax implanted gamers to stop them from being twits
	name = "Capacitor-seeded"
	show_in_antagpanel = FALSE
	var/flavor_message = "<span class='sevtug'>You need to get away from here. Run.</span>" //message displayed on being implanted

/datum/antagonist/cult_implanted/proc/forge_objectives()
	var/datum/objective/keep_implant/I = new
	I.target_implant = locate(/obj/item/implant/cult) in owner.current?.implants
	I.owner = owner
	I.update_explanation_text()
	add_objective(I)
	add_objective(new/datum/objective/survive)

/datum/antagonist/cult_implanted/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/cult_implanted/greet()
	to_chat(owner, "[flavor_message]\n\
	<span class='boldwarning'>You prioritize flight over fight, and use direct confrontation as a last resort!</span>") //attempt to stop people from just stabbing the cultists the second they get up
	owner.announce_objectives()

/datum/antagonist/cult_implanted/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/cult_implanted/proc/remove_objective(datum/objective/O)
	objectives -= O


/datum/objective/keep_implant
	name = "no implant removal"
	explanation_text = "Don't have this implant removed."
	var/obj/item/implant/target_implant  //implant targetted by the objective, if it's removed it fails the objective

/datum/objective/keep_implant/update_explanation_text()
	explanation_text = "You cannot allow [target_implant] to be removed from your body."

/datum/objective/keep_implant/check_completion()
	for(var/obj/item/implant/I in owner.current?.implants)
		if(I == target_implant)
			return TRUE
	return FALSE


/obj/item/implanter/cult //used to hold guvax implant
	name = "guvax capacitor"
	desc = "A strange brass object that looks vaguely similar to an antlion. The tips look sharp."
	var/clockwork_desc = "A guvax capacitor, which can be implanted into heretics to increase Sevtug's sway over their minds." //used for flavortext
	var/blood_desc = "A mind-altering implant used by a lesser force." //also used for flavortext
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "geis_capacitor"
	imp_type = /obj/item/implant/cult

/obj/item/implanter/cult/update_icon()
	return

/obj/item/implanter/cult/examine(mob/user)
	if(clockwork_desc && (is_servant_of_ratvar(user) || isobserver(user)))
		desc = clockwork_desc
	if(blood_desc && (iscultist(user)) || (istype(src, /obj/item/implanter/cult/blood) && isobserver(user)))
		desc = blood_desc
	. = ..()
	desc = initial(desc)

/obj/item/implanter/cult/attackby(obj/item/W, mob/user, params)
	return

/obj/item/implanter/cult/attack(mob/living/M, mob/user)
	..()
	if(!imp)
		qdel(src)


/obj/item/implant/cult
	name = "guvax capacitor"
	activated = FALSE
	var/linkedantag = /datum/antagonist/cult_implanted //antag given to implantee
	var/cult_team = CULT_TEAM_CLOCK
	var/datum/team/linkedteam //team that gets points
	var/break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //sound when removed

/obj/item/implant/cult/New()
	..()
	switch(cult_team)
		if(CULT_TEAM_CLOCK)
			linkedteam = SSticker.mode.clock_agent_team
		if(CULT_TEAM_BLOOD)
			linkedteam = SSticker.mode.blood_agent_team

/obj/item/implant/cult/can_be_implanted_in(mob/living/target)
	if(is_servant_of_ratvar(target) || iscultist(target) || !target.mind || HAS_TRAIT(target, TRAIT_MINDSHIELD) || target.mind.has_antag_datum(/datum/antagonist/cult_implanted))//cannot implant clockies, bloodcultists, mindless, or mindshielded
		return FALSE
	. = ..()

/obj/item/implant/cult/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(!user.mind.has_antag_datum(cult_team))
		return
	. = ..()
	if(.)
		var/datum/mind/M = target.mind
		M.add_antag_datum(linkedantag)
		for(var/datum/objective/implant/O in linkedteam?.objectives)
			O.dudes_stabbed += M
		target.SetSleeping(200)

/obj/item/implant/cult/removed(mob/living/source, silent = FALSE, special = 0)
	if(..())
		source.visible_message("<span class='warning'>[src] shatters as it is removed!</span>")
		playsound(source, break_sound, 20, 1)
		QDEL_NULL(src)

/datum/antagonist/cult_implanted/blood
	name = "Soul-seeded"
	flavor_message = "<span class ='cultbold'>\"Run, insect. Your time will come.\"</span>"

/obj/item/implanter/cult/blood
	name = "soulshard"
	desc = "A small red crystal with pointy ends"
	clockwork_desc = "A mind-altering implant used by our enemy"
	blood_desc = "A small soulstone, incapable of holding a soul, but can modify one to suit the Geometer's needs"
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit_crystal"
	imp_type = /obj/item/implant/cult/blood

/obj/item/implant/cult/blood
	name = "soulshard"
	linkedantag = /datum/antagonist/cult_implanted/blood
	cult_team = CULT_TEAM_BLOOD
	break_sound = 'sound/effects/glassbr2.ogg'

#undef CULT_TEAM_CLOCK
#undef CULT_TEAM_BLOOD
