/**
 * ASSAULT OPERATIVE ANTAG DATUM
 */

/datum/antagonist/assault_operative
	name = ROLE_ASSAULT_OPERATIVE
	job_rank = ROLE_ASSAULT_OPERATIVE
	roundend_category = "assault operatives"
	antagpanel_category = "Assault Operatives"
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/focused
	show_to_ghosts = TRUE
	hijack_speed = 2
	remove_from_manifest = TRUE

	preview_outfit = /datum/outfit/assaultops_preview
	/// In the preview icon, the operatives who are behind the leader
	var/preview_outfit_behind = /datum/outfit/assaultops_preview/background

	ui_name = "AntagInfoAssaultops"
	/// The default outfit given BEFORE they choose their equipment.
	var/assault_operative_default_outfit = /datum/outfit/assaultops
	/// The team linked to this antagonist datum.
	var/datum/team/assault_operatives/assault_team
	/// Should we move the operative to a designated spawn point?
	var/send_to_spawnpoint = TRUE
	//If not assigned a team by default ops will try to join existing ones, set this to TRUE to always create new team.
	var/always_new_team = FALSE
	var/spawn_text = "Your mission is to assault NTSS13 and get all of the GoldenEye keys that you can from the heads of staff that reside there. \
	Use your pinpointer to locate these after you have extracted the GoldenEye key from the head of staff. It will be sent in by droppod. \
	You must then upload the key to the GoldenEye upload terminal on this GoldenEye station. After you have completed your mission, \
	The GoldenEye defence network will fall, and we will gain access to Nanotrasen's military systems. Good luck agent."
	/// A link to our team monitor, used to track keycards.
	var/datum/component/team_monitor/monitor

/datum/antagonist/assault_operative/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_GOLDENEYE_KEY_CREATED)
	QDEL_NULL(monitor)
	return ..()

/datum/antagonist/assault_operative/apply_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	monitor = target.AddComponent(/datum/component/team_monitor, "goldeneye_key")
	for(var/obj/item/goldeneye_key/keycard as anything in SSgoldeneye.goldeneye_keys)
		if(QDELETED(keycard))
			continue
		monitor.add_to_tracking_network(keycard.beacon)
	monitor.show_hud(target)
	add_team_hud(target, /datum/antagonist/assault_operative)

/datum/antagonist/assault_operative/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	monitor?.hide_hud(target)
	QDEL_NULL(monitor)

/datum/antagonist/assault_operative/get_team()
	return assault_team

/datum/antagonist/assault_operative/greet()
	owner.current.playsound_local(get_turf(owner.current), 'monkestation/code/modules/assault_ops/sound/assault_operatives_greet.ogg', 30, 0, use_reverb = FALSE)
	to_chat(owner, span_big("You are an assault operative!"))
	to_chat(owner, span_red(spawn_text))
	owner.announce_objectives()

/datum/antagonist/assault_operative/on_gain()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_GOLDENEYE_KEY_CREATED, PROC_REF(on_goldeneye_key_created))
	equip_operative()
	forge_objectives()
	if(send_to_spawnpoint)
		move_to_spawnpoint()
	give_alias()

/datum/antagonist/assault_operative/create_team(datum/team/assault_operatives/new_team)
	if(!new_team)
		if(!always_new_team)
			for(var/datum/antagonist/assault_operative/assault_operative in GLOB.antagonists)
				if(!assault_operative.owner)
					stack_trace("Antagonist datum without owner in GLOB.antagonists: [assault_operative]")
					continue
				if(assault_operative.assault_team)
					assault_team = assault_operative.assault_team
					return
		assault_team = new /datum/team/assault_operatives
		assault_team.add_member(owner)
		assault_team.update_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	assault_team = new_team
	assault_team.add_member(owner)

// UI systems
/datum/antagonist/assault_operative/ui_data(mob/user)
	return list(
		"uploaded_keys" = SSgoldeneye.uploaded_keys,
		"available_targets" = get_available_targets(),
		"extracted_targets" = get_extracted_targets(),
		"goldeneye_keys" = get_goldeneye_keys(),
	)

/datum/antagonist/assault_operative/ui_static_data(mob/user)
	return list(
		"required_keys" = SSgoldeneye.required_keys,
		"objectives" = get_objectives(),
	)

/datum/antagonist/assault_operative/proc/get_available_targets()
	var/list/available_targets_data = list()
	for(var/datum/mind/iterating_mind in SSjob.get_all_heads())
		if(iterating_mind in SSgoldeneye.goldeneye_extracted_minds)
			continue
		available_targets_data += list(list(
			"name" = iterating_mind.name,
			"job" = iterating_mind.assigned_role.title,
		))
	return available_targets_data

/datum/antagonist/assault_operative/proc/get_extracted_targets()
	var/list/extracted_targets_data = list()
	for(var/datum/mind/iterating_mind in SSgoldeneye.goldeneye_extracted_minds)
		extracted_targets_data += list(list(
			"name" = iterating_mind.name,
			"job" = iterating_mind.assigned_role.title,
		))
	return extracted_targets_data

/datum/antagonist/assault_operative/proc/get_goldeneye_keys()
	. = list()
	for(var/obj/item/goldeneye_key/keycard as anything in SSgoldeneye.goldeneye_keys)
		if(QDELETED(keycard))
			continue
		var/turf/location = get_turf(keycard)
		. += list(list(
			"name" = keycard.goldeneye_tag,
			"color" = keycard.beacon_color,
			"coord_x" = location.x,
			"coord_y" = location.y,
			"coord_z" = location.z,
			"ref" = REF(keycard),
		))


/datum/antagonist/assault_operative/forge_objectives()
	if(assault_team)
		objectives |= assault_team.objectives

/datum/antagonist/assault_operative/proc/give_alias()
	var/chosen_name = sanitize_text(tgui_input_text(owner.current, "Please input your desired name!", "Name", "Randy Random"))
	if(!chosen_name)
		if(ishuman(owner.current))
			var/mob/living/carbon/human/human = owner.current
			owner.current.real_name = human.dna?.species.random_name(human.gender)
		return
	owner.current.real_name = chosen_name

/datum/antagonist/assault_operative/proc/equip_operative()
	if(!ishuman(owner.current))
		return

	var/mob/living/carbon/human/human_target = owner.current

	if(human_target.dna.species.id == "plasmaman" )
		human_target.set_species(/datum/species/human)
		to_chat(human_target, span_userdanger("You are now a human!"))

	human_target.clear_inventory()

	var/obj/item/organ/internal/brain/human_brain = human_target.get_organ_slot(BRAIN)
	human_brain.destroy_all_skillchips() // get rid of skillchips to prevent runtimes
	human_target.equipOutfit(assault_operative_default_outfit)
	human_target.regenerate_icons()

	if(!human_target.has_language(/datum/language/common, TRUE))
		human_target.grant_language(/datum/language/common, TRUE, TRUE, LANGUAGE_MIND)

	return TRUE

/datum/antagonist/assault_operative/proc/move_to_spawnpoint()
	var/team_number = 1
	if(assault_team)
		team_number = assault_team.members.Find(owner)
	owner.current.forceMove(GLOB.assault_operative_start[((team_number - 1) % GLOB.assault_operative_start.len) + 1])

/datum/antagonist/assault_operative/get_preview_icon()
	if (!preview_outfit)
		return null

	var/icon/final_icon = render_preview_outfit(preview_outfit)

	if (!isnull(preview_outfit_behind))
		var/icon/teammate = render_preview_outfit(preview_outfit_behind)
		teammate.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)

		final_icon.Blend(teammate, ICON_UNDERLAY, -world.icon_size / 4, 0)
		final_icon.Blend(teammate, ICON_UNDERLAY, world.icon_size / 4, 0)

	var/icon/disky = icon('monkestation/code/modules/assault_ops/icons/goldeneye.dmi', "goldeneye_key")
	disky.Shift(SOUTH, 12)
	final_icon.Blend(disky, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/assault_operative/proc/on_goldeneye_key_created(datum/source, obj/item/goldeneye_key/key)
	SIGNAL_HANDLER
	monitor?.add_to_tracking_network(key.beacon)

/**
 * ASSAULT OPERATIVE TEAM DATUM
 */

/datum/team/assault_operatives
	/// Our core objective, it's obviously goldeneye.
	var/core_objective = /datum/objective/goldeneye

/datum/team/assault_operatives/proc/update_objectives()
	if(core_objective)
		var/datum/objective/new_objective = new core_objective
		new_objective.team = src
		objectives += new_objective

/datum/team/assault_operatives/proc/operatives_dead()
	var/total_operatives = LAZYLEN(members)
	var/alive_operatives = 0
	for(var/datum/mind/iterating_mind in members)
		if(ishuman(iterating_mind.current) && (iterating_mind.current.stat != DEAD))
			alive_operatives++
	if(!alive_operatives)
		return ASSAULTOPS_ALL_DEAD
	if(alive_operatives >= total_operatives)
		return ASSAULTOPS_ALL_ALIVE
	return ASSAULTOPS_PARTLY_DEAD


/datum/team/assault_operatives/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Assault Operatives:</span>"

	switch(get_result())
		if(ASSAULT_RESULT_WIN)
			parts += span_greentext("Assault Operatives Major Victory!")
			parts += "<B>The Assault Operatives have successfully subverted and activated GoldenEye, and they all survived!</B>"
		if(ASSAULT_RESULT_PARTIAL_WIN)
			parts += span_greentext("Assault Operatives Minor Victory!")
			parts += "<B>The Assault Operatives have successfully subverted and activated GoldenEye, but only some survived!</B>"
		if(ASSAULT_RESULT_HEARTY_WIN)
			parts += span_greentext("Assault Operatives Hearty Victory!")
			parts += "<B>The Assault Operatives have successfully subverted and activated GoldenEye, but they all died!</B>"
		if(ASSAULT_RESULT_LOSS)
			parts += span_redtext("Crew Victory!")
			parts += "<B>The Research Staff of [station_name()] have killed all of the assault operatives and stopped them activating GoldenEye!</B>"
		if(ASSAULT_RESULT_STALEMATE)
			parts += "<span class='neutraltext big'>Stalemate!</span>"
			parts += "<B>The assault operatives have failed to activate GoldenEye and are still alive!</B>"
		else
			parts += "<span class='neutraltext big'>Neutral Victory</span>"
			parts += "<B>Mission aborted!</B>"
	parts += span_redtext("GoldenEye keys uploaded: [SSgoldeneye.uploaded_keys]/[SSgoldeneye.required_keys]")

	var/text = "<br><span class='header'>The assault operatives were:</span>"
	text += printplayerlist(members)
	text += "<br>"

	parts += text

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/assault_operatives/proc/get_result()
	var/goldeneye_activated = SSgoldeneye.goldeneye_activated
	var/operatives_dead_status = operatives_dead()

	if(goldeneye_activated && operatives_dead_status == ASSAULTOPS_ALL_ALIVE)
		return ASSAULT_RESULT_WIN
	else if(goldeneye_activated && operatives_dead_status == ASSAULTOPS_PARTLY_DEAD)
		return ASSAULT_RESULT_PARTIAL_WIN
	else if(goldeneye_activated && operatives_dead_status == ASSAULTOPS_ALL_DEAD)
		return ASSAULT_RESULT_HEARTY_WIN
	else if(!goldeneye_activated &&	operatives_dead_status == ASSAULTOPS_ALL_DEAD)
		return ASSAULT_RESULT_LOSS
	else if(!goldeneye_activated && operatives_dead_status)
		return ASSAULT_RESULT_STALEMATE

/**
 * ASSAULT OPERATIVE JOB TYPE
 */
/datum/job/assault_operative
	title = ROLE_ASSAULT_OPERATIVE


/datum/job/assault_operative/get_roundstart_spawn_point()
	return pick(GLOB.assault_operative_start)

/datum/job/assault_operative/get_latejoin_spawn_point()
	return pick(GLOB.assault_operative_start)


