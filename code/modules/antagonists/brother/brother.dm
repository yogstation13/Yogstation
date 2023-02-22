/datum/antagonist/brother
	name = "Brother"
	antagpanel_category = "Brother"
	job_rank = ROLE_BROTHER
	var/special_role = ROLE_BROTHER
	var/datum/team/brother_team/team
	antag_moodlet = /datum/mood_event/focused
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/brother/create_team(datum/team/brother_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/brother/get_team()
	return team

/datum/antagonist/brother/on_gain()
	SSticker.mode.brothers += owner
	objectives += team.objectives
	owner.special_role = special_role
	if(owner.current)
		give_pinpointer()
		equip_brother()
	finalize_brother()
	return ..()

/datum/antagonist/brother/proc/equip_brother()
	var/obj/item/book/granter/crafting_recipe/weapons/W = new
	W.on_reading_finished(owner.current)
	qdel(W)
	owner.equip_traitor(uplink_owner = src, starting_tc = 0)

	if(!iscarbon(owner.current))
		return
	var/mob/living/carbon/brother_to_equip = owner.current

	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left pocket" = SLOT_L_STORE,
		"right pocket" = SLOT_R_STORE
	)
	var/obj_folder = new /obj/item/folder/objective
	var/where = brother_to_equip.equip_in_one_of_slots(obj_folder, slots)
	if(!where)
		to_chat(brother_to_equip, span_userdanger("Unfortunately, you weren't able to get a [obj_folder]. This is very bad and you should adminhelp immediately (press F1)."))
	else
		to_chat(brother_to_equip, span_danger("You have a [obj_folder] in your [where] that contains an objective. Complete this objective and you will receive a reward of telecrystals."))
		if(where == "backpack")
			SEND_SIGNAL(brother_to_equip.back, COMSIG_TRY_STORAGE_SHOW, brother_to_equip)

/datum/antagonist/brother/on_removal()
	SSticker.mode.brothers -= owner
	if(owner.current)
		to_chat(owner.current,span_userdanger("You are no longer the [special_role]!"))
		owner.current.remove_status_effect(/datum/status_effect/agent_pinpointer/brother)
	owner.special_role = null
	return ..()

/datum/antagonist/brother/antag_panel_data()
	return "Conspirators : [get_brother_names()]"

/datum/antagonist/brother/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new

	brother1.dna.features["ethcolor"] = GLOB.color_list_ethereal["Faint Red"]
	brother1.set_species(/datum/species/ethereal)

	brother2.dna.features["moth_antennae"] = "Plain"
	brother2.dna.features["moth_markings"] = "None"
	brother2.dna.features["moth_wings"] = "Plain"
	brother2.set_species(/datum/species/moth)

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	brother1_icon.Blend(icon('icons/effects/blood.dmi', "maskblood"), ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist, brother2)
	brother2_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)

	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return finish_preview_icon(final_icon)

/datum/antagonist/brother/proc/get_brother_names()
	var/list/brothers = team.members - owner
	var/brother_text = ""
	for(var/i = 1 to brothers.len)
		var/datum/mind/M = brothers[i]
		brother_text += M.name
		if(i == brothers.len - 1)
			brother_text += " and "
		else if(i != brothers.len)
			brother_text += ", "
	return brother_text

/datum/antagonist/brother/proc/give_meeting_area()
	if(!owner.current || !team || !team.meeting_area)
		return
	to_chat(owner.current, "<B>Your designated meeting area:</B> [team.meeting_area]")
	antag_memory += "<b>Meeting Area</b>: [team.meeting_area]<br>"

/datum/antagonist/brother/greet()
	var/brother_text = get_brother_names()
	to_chat(owner.current, span_alertsyndie("You are the [owner.special_role] of [brother_text]."))
	to_chat(owner.current, "The Syndicate only accepts those that have proven themselves. Prove yourself and prove your [team.member_name]s by completing your objectives together! You and your team are outfitted with communication implants allowing for direct, encrypted communication.")
	owner.announce_objectives()
	give_meeting_area()

/datum/antagonist/brother/proc/finalize_brother()
	var/obj/item/implant/bloodbrother/I = new /obj/item/implant/bloodbrother()
	I.implant(owner.current, null, TRUE, TRUE)
	for(var/datum/mind/M in team.members) // Link the implants of all team members
		var/obj/item/implant/bloodbrother/T = locate() in M.current.implants
		I.link_implant(T)
	SSticker.mode.update_brother_icons_added(owner)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/brother/admin_add(datum/mind/new_owner,mob/admin)
	//show list of possible brothers
	var/list/candidates = list()
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(!L.mind || L.mind == new_owner || !can_be_owned(L.mind))
			continue
		candidates[L.mind.name] = L.mind

	var/choice = input(admin,"Choose the blood brother.", "Brother") as null|anything in candidates
	if(!choice)
		return
	var/datum/mind/bro = candidates[choice]
	var/datum/team/brother_team/T = new
	T.add_member(new_owner)
	T.add_member(bro)
	T.pick_meeting_area()
	T.forge_brother_objectives()
	new_owner.add_antag_datum(/datum/antagonist/brother,T)
	bro.add_antag_datum(/datum/antagonist/brother, T)
	T.update_name()
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] and [key_name_admin(bro)] into blood brothers.")
	log_admin("[key_name(admin)] made [key_name(new_owner)] and [key_name(bro)] into blood brothers.")

/datum/antagonist/brother/get_admin_commands()
	. = ..()
	.["Convert To Traitor"] = CALLBACK(src, .proc/make_traitor)

/datum/antagonist/brother/proc/make_traitor()
	if(alert("Are you sure? This will turn the blood brother into a traitor with the same objectives!",,"Yes","No") != "Yes")
		return

	var/datum/antagonist/traitor/tot = new()
	tot.give_objectives = FALSE
	
	for(var/datum/objective/obj in objectives)
		var/obj_type = obj.type
		var/datum/objective/new_obj = new obj_type()
		new_obj.owner = owner
		new_obj.copy_target(obj)
		tot.add_objective(new_obj)
		qdel(obj)
	objectives.Cut()
	
	owner.add_antag_datum(tot)
	owner.remove_antag_datum(/datum/antagonist/brother)

/datum/antagonist/brother/proc/give_pinpointer()
	if(owner && owner.current)
		var/datum/status_effect/agent_pinpointer/brother/P = owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer/brother)
		P.allowed_targets = team.members - owner

/datum/team/brother_team
	name = "brotherhood"
	member_name = "blood brother"
	var/meeting_area
	var/static/meeting_areas = list("The Bar", "Dorms", "Escape Dock", "Arrivals", "Holodeck", "Primary Tool Storage", "Recreation Area", "Chapel", "Library")

/datum/team/brother_team/is_solo()
	return FALSE

/datum/team/brother_team/proc/pick_meeting_area()
	meeting_area = pick(meeting_areas)
	meeting_areas -= meeting_area

/datum/team/brother_team/proc/update_name()
	var/list/last_names = list()
	for(var/datum/mind/M in members)
		var/list/split_name = splittext(M.name," ")
		last_names += split_name[split_name.len]

	name = last_names.Join(" & ")

/datum/team/brother_team/roundend_report()
	var/list/parts = list()

	parts += span_header("The blood brothers of [name] were:")
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	
	// Spending report
	var/purchases = ""
	var/TC_uses = 0
	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	for(var/datum/mind/I in members)
		var/datum/uplink_purchase_log/H = GLOB.uplink_purchase_logs_by_key[I.key]
		if(H)
			TC_uses += H.total_spent
			purchases += H.generate_render(show_key = FALSE)
	
	var/win = TRUE
	var/objective_count = 1
	var/objectives_text = ""
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			objectives_text += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [span_greentext("Success!")]"
		else
			objectives_text += "<B>Objective #[objective_count]</B>: [objective.explanation_text] [span_redtext("Fail.")]"
			win = FALSE
		objective_count++

	parts += "(used [TC_uses] TC) [purchases]"
	if(TC_uses == 0 && win)
		parts += "<BIG>[icon2html('icons/badass.dmi', world, "badass")]</BIG>"

	parts += objectives_text

	if(win)
		parts += span_greentext("The blood brothers were successful!")
	else
		parts += span_redtext("The blood brothers have failed!")

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/brother_team/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	if(needs_target)
		O.find_target(dupe_search_range = list(src))
	O.update_explanation_text()
	objectives += O

/datum/team/brother_team/proc/forge_brother_objectives()
	objectives = list()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 30) // Less murderboning on lowpop thanks
		is_hijacker = prob(10)
	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (members.len > 2) - is_hijacker))
		forge_single_objective()
	if(is_hijacker)
		if(!locate(/datum/objective/hijack) in objectives)
			add_objective(new/datum/objective/hijack)
	else if(!locate(/datum/objective/escape) in objectives)
		add_objective(new/datum/objective/escape)

/datum/team/brother_team/proc/forge_single_objective()
	if(prob(50))
		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
			add_objective(new/datum/objective/destroy, TRUE)
		else if(prob(30))
			add_objective(new/datum/objective/maroon, TRUE)
		else
			var/A = pick(/datum/objective/assassinate, /datum/objective/assassinate/cloned, /datum/objective/assassinate/once)
			add_objective(new A, TRUE)
	else
		add_objective(new/datum/objective/steal, TRUE)

/datum/team/brother_team/antag_listing_name()
	return "[name] blood brothers"
