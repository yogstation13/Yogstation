/proc/brainwash(mob/living/L, directives)
	if(!L.mind)
		return
	if(!islist(directives))
		directives = list(directives)
	var/datum/mind/M = L.mind
	var/datum/antagonist/brainwashed/B = M.has_antag_datum(/datum/antagonist/brainwashed)
	if(B)
		for(var/O in directives)
			var/datum/objective/brainwashing/objective = new(O)
			B.objectives += objective
		B.greet()
	else
		B = new()
		for(var/O in directives)
			var/datum/objective/brainwashing/objective = new(O)
			B.objectives += objective
		M.add_antag_datum(B)

	var/begin_message = " has been brainwashed with the following objectives: "
	var/obj_message = english_list(directives)
	var/end_message = "."
	var/rendered = begin_message + obj_message + end_message
	deadchat_broadcast(rendered, "<b>[L]</b>", follow_target = L, turf_target = get_turf(L), message_type=DEADCHAT_REGULAR)

/datum/antagonist/brainwashed
	name = "Brainwashed Victim"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "brainwashed victims"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/brainwashed/greet()
	to_chat(owner, span_warning("Your mind reels as it begins focusing on a single purpose..."))
	to_chat(owner, "<big><span class='warning'><b>Follow the Directives, at any cost!</b></span></big>")
	owner.current.throw_alert("brainwash_notif", /obj/screen/alert/brainwashed)
	SEND_SOUND(owner.current, sound('sound/ambience/ambimystery.ogg'))
	SEND_SOUND(owner.current, sound('sound/effects/glassbr1.ogg'))
	var/i = 1
	for(var/X in objectives)
		var/datum/objective/O = X
		to_chat(owner, "<b>[i].</b> [O.explanation_text]")
		i++

/datum/antagonist/brainwashed/farewell()
	to_chat(owner, span_warning("Your mind suddenly clears..."))
	to_chat(owner, "<big><span class='warning'><b>You feel the weight of the Directives disappear! You no longer have to obey them.</b></span></big>")
	owner.current.clear_alert("brainwash_notif")
	owner.announce_objectives()

/datum/antagonist/brainwashed/apply_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_added()

/datum/antagonist/brainwashed/remove_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_removed()

/datum/antagonist/brainwashed/proc/update_traitor_icons_added(datum/mind/slave_mind)
	var/datum/atom_hud/antag/brainwashedhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	brainwashedhud.join_hud(owner.current)
	set_antag_hud(owner.current, "brainwashed")

/datum/antagonist/brainwashed/proc/update_traitor_icons_removed(datum/mind/slave_mind)
	var/datum/atom_hud/antag/brainwashedhud = GLOB.huds[ANTAG_HUD_BRAINWASHED]
	brainwashedhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/brainwashed/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		return
	var/list/objectives = list()
	do
		var/objective = stripped_input(admin, "Add an objective, or leave empty to finish.", "Brainwashing", null, MAX_MESSAGE_LEN)
		if(objective)
			objectives += objective
	while(alert(admin,"Add another objective?","More Brainwashing","Yes","No") == "Yes")

	if(alert(admin,"Confirm Brainwashing?","Are you sure?","Yes","No") == "No")
		return

	if(!LAZYLEN(objectives))
		return

	if(QDELETED(C))
		to_chat(admin, "Mob doesn't exist anymore")
		return

	brainwash(C, objectives)
	var/obj_list = english_list(objectives)
	message_admins("[key_name_admin(admin)] has brainwashed [key_name_admin(C)] with the following objectives: [obj_list].")
	log_admin("[key_name(admin)] has brainwashed [key_name(C)] with the following objectives: [obj_list].")

/datum/objective/brainwashing
	completed = TRUE
