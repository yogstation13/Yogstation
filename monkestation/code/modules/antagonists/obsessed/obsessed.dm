/datum/antagonist/obsessed
	var/protection = FALSE // used to tell what flavor to text to give.

/datum/antagonist/obsessed/forge_objectives(datum/mind/obsessionmind)
	var/list/objectives_left = list("spendtime", "polaroid", "hug")
	var/obj/family_heirloom
	for(var/datum/quirk/quirky in obsessionmind.current.quirks)
		if(istype(quirky, /datum/quirk/item_quirk/family_heirloom))
			var/datum/quirk/item_quirk/family_heirloom/heirloom_quirk = quirky
			family_heirloom = heirloom_quirk.heirloom?.resolve()
			break
	if(family_heirloom)
		objectives_left += "heirloom"

	// If they have no coworkers, jealousy will pick someone else on the station. This will never be a free objective.
	if(!is_captain_job(obsessionmind.assigned_role))
		objectives_left += "jealous"

	for(var/i in 1 to 3)
		var/chosen_objective = pick(objectives_left)
		objectives_left.Remove(chosen_objective)
		switch(chosen_objective)
			if("spendtime")
				var/datum/objective/spendtime/spendtime = new
				spendtime.owner = owner
				spendtime.target = obsessionmind
				objectives += spendtime
			if("polaroid")
				var/datum/objective/polaroid/polaroid = new
				polaroid.owner = owner
				polaroid.target = obsessionmind
				objectives += polaroid
			if("hug")
				var/datum/objective/hug/hug = new
				hug.owner = owner
				hug.target = obsessionmind
				objectives += hug
			if("heirloom")
				var/datum/objective/steal/heirloom_thief/heirloom_thief = new
				heirloom_thief.owner = owner
				heirloom_thief.target = obsessionmind//while you usually wouldn't need this for stealing, we need the name of the obsession
				heirloom_thief.steal_target = family_heirloom
				objectives += heirloom_thief
			if("jealous")
				var/datum/objective/assassinate/jealous/jealous = new
				jealous.owner = owner
				jealous.target = obsessionmind//will reroll into a coworker on the objective itself
				objectives += jealous


	var/final_pick = rand(1,2)
	switch(final_pick) // determines the fate of the obsession.
		if(1)
			var/datum/objective/assassinate/obsessed/kill = new
			kill.owner = owner
			kill.target = obsessionmind
			objectives += kill //Kill the obsession
		if(2)
			var/datum/objective/protect/obsessed/yandere = new
			yandere.owner = owner
			yandere.target = obsessionmind
			objectives += yandere
			protection = TRUE


	for(var/datum/objective/O in objectives)
		O.update_explanation_text()

/datum/antagonist/obsessed/greet()
	to_chat(owner, "<span class='userdanger'>You are the Obsessed!</span>")
	if(protection)
		to_chat(owner, "<span class='bold'>Realization floods over you and everything that's happened this shift makes sense.</span>")
		to_chat(owner, "<span class='bold'>[trauma.obsession.name] has no idea how much danger they're in and you're the only person that can be there for them.</span>")
		to_chat(owner, "<span class='bold'>Nobody else can be trusted, they are all liars and will use deceit to stab you and [trauma.obsession.name] in the back as soon as they can.</span>")
	to_chat(owner, "<span class='boldannounce'>This role does NOT enable you to otherwise surpass what's deemed creepy behavior per the rules.</span>")//ironic if you know the history of the antag
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/creepalert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.announce_objectives()


//New objectives Yandere aka protect
/datum/objective/protect/obsessed //just a creepy version of protect

/datum/objective/protect/obsessed/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role.title : target.special_role] from any harm."
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] obsessed objectives forged without an obsession!")
		explanation_text = "Free Objective"
