/datum/antagonist/infiltrator
	name = "Syndicate Infiltrator"
	roundend_category = "syndicate infiltrators" //just in case
	antagpanel_category = "Infiltrator"
	job_rank = ROLE_INFILTRATOR
	antag_hud_name = "synd"
	show_to_ghosts = TRUE
	count_towards_antag_cap = TRUE
	var/datum/team/infiltrator/infiltrator_team
	var/always_new_team = FALSE //If not assigned a team by default ops will try to join existing ones, set this to TRUE to always create new team.
	var/send_to_spawnpoint = TRUE //Should the user be moved to default spawnpoint.
	var/dress_up = TRUE
	preview_outfit = /datum/outfit/infiltrator_preview

/datum/antagonist/infiltrator/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	add_team_hud(M)

/datum/antagonist/infiltrator/greet()
	owner.current.playsound_local(get_turf(owner.current), 'yogstation/sound/ambience/antag/infiltrator.ogg', 100, 0)
	to_chat(owner, span_userdanger("You are a syndicate infiltrator!"))
	to_chat(owner, span_boldnotice("Your job is to infiltrate [station_name()], and complete our objectives"))
	to_chat(owner, span_big(span_notice("Click on your pinpointer at the top right to access your uplink, pinpointer, or ship controls.")))
	to_chat(owner, span_notice("You also have an internal radio, for communicating with your team-mates at all times."))
	to_chat(owner, span_notice("You have a dusting implant, to ensure that Nanotrasen does not get their hands on Syndicate gear. Only activate it, if you are compromised."))
	to_chat(owner, span_boldnotice(span_italics("Do NOT kill or destroy needlessly, as this defeats the purpose of an 'infiltration'!")))
	owner.announce_objectives()

/datum/antagonist/infiltrator/on_gain()
	var/mob/living/carbon/human/H = owner.current
	owner.assigned_role = "Syndicate Infiltrator"
	owner.special_role = "Syndicate Infiltrator"
	if(istype(H))
		if(dress_up)
			H.set_species(/datum/species/human)
			var/new_name = H.dna.species.random_name(H.gender, TRUE)
			H.fully_replace_character_name(H.real_name, new_name)
			H.equipOutfit(/datum/outfit/infiltrator)
	owner.store_memory("Do <B>NOT</B> kill or destroy needlessly, as this defeats the purpose of an 'infiltration'!")
	. = ..()
	if(send_to_spawnpoint)
		move_to_spawnpoint()

/datum/antagonist/infiltrator/get_team()
	return infiltrator_team

/datum/antagonist/infiltrator/create_team(datum/team/infiltrator/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/infiltrator/N in GLOB.antagonists)
				if(!N.owner)
					continue
				if(N.infiltrator_team)
					infiltrator_team = N.infiltrator_team
					return
		infiltrator_team = new /datum/team/infiltrator
		infiltrator_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	infiltrator_team = new_team

/datum/antagonist/infiltrator/get_admin_commands()
	. = ..()
	.["Send to base"] = CALLBACK(src, PROC_REF(admin_send_to_base))

/datum/antagonist/infiltrator/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.assigned_role = ROLE_INFILTRATOR
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has infiltrator'ed [new_owner.current].")
	log_admin("[key_name(admin)] has infiltrator'ed [new_owner.current].")

/datum/antagonist/infiltrator/proc/admin_send_to_base(mob/admin)
	owner.current.forceMove(pick(GLOB.infiltrator_start))

/datum/antagonist/infiltrator/proc/move_to_spawnpoint()
	var/team_number = 1
	if(infiltrator_team)
		team_number = infiltrator_team.members.Find(owner)
	owner.current.forceMove(GLOB.infiltrator_start[((team_number - 1) % GLOB.infiltrator_start.len) + 1])
