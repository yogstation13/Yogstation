SUBSYSTEM_DEF(credits)
	name = "Credits Screen Storage"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_CREDITS

	var/director = "Some monkey we found on the street"
	var/list/disclaimers = list()
	var/list/datum/episode_name/episode_names = list()

	var/episode_name = ""
	var/episode_reason = ""
	var/producers_string = ""
	var/list/episode_string
	var/list/disclaimers_string
	var/list/cast_string

	//If any of the following five are modified, the episode is considered "not a rerun".
	var/customized_name = ""
	var/rare_episode_name = FALSE
	var/theme = "NT"

	var/list/contributer_pref_images = list()
	var/list/admin_pref_images = list()
	var/list/major_event_icons = list()
	var/list/contributors = list()

	var/list/credit_order
	var/list/ignored_clients

/datum/controller/subsystem/credits/Initialize()
	load_contributors()
	generate_pref_images()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/credits/proc/generate_credits()
	credit_order = list()

	draft()
	finalize()

	credit_order += episode_string
	credit_order += producers_string
	credit_order += disclaimers_string
	credit_order += cast_string

	credit_order += "<center>The Admin Bus</center>"
	var/list/admins = shuffle(admin_pref_images)
	var/admin_length = length(admins)

	for(var/i in 1 to admin_length)
		for(var/b in 1 to 8)
			var/atom/movable/screen/map_view/char_preview/client_image = pick_n_take(admins)
			if(!client_image)
				break
			client_image.screen_loc = "LEFT+[(b - 1) * 13]%:24,BOTTOM"
			credit_order += client_image

	credit_order += "<center>Our Lovely Contributors</center>"
	var/list/contributors = shuffle(contributer_pref_images)

	var/contributors_length = length(contributors)
	for(var/i in 1 to contributors_length)
		for(var/b in 1 to 8)
			var/atom/movable/screen/map_view/char_preview/client_image = pick_n_take(contributors)
			if(!client_image)
				break
			client_image.screen_loc = "LEFT+[(b - 1) * 13]%:24,BOTTOM"
			credit_order += client_image

	for(var/i in major_event_icons)
		credit_order += i
		var/list/returned_images = resolve_clients(major_event_icons[i], i)
		for(var/y in 1 to length(returned_images))
			for(var/b in 1 to 8)
				var/atom/movable/screen/map_view/char_preview/client_image = pick_n_take(returned_images)
				if(!client_image)
					break
				client_image.screen_loc = "LEFT+[(b - 1) * 13]%:24,BOTTOM"
				credit_order += client_image

/datum/controller/subsystem/credits/proc/load_contributors()
	contributors = list()
	var/list/lines = world.file2list("[global.config.directory]/contributors.txt")
	for(var/line in lines)
		if(!length(line))
			continue
		if(findtextEx(line, "#", 1, 2))
			continue
		contributors |= line

/datum/controller/subsystem/credits/proc/draft()
	draft_episode_names()
	draft_disclaimers()
	draft_caststring()

/datum/controller/subsystem/credits/proc/finalize()
	finalize_name()
	finalize_episodestring()
	finalize_disclaimerstring()

/datum/controller/subsystem/credits/proc/generate_pref_images()
	for(var/ckey in contributors)
		var/datum/client_interface/interface = new(ckey)
		var/datum/preferences/mocked = new(interface)

		var/atom/movable/screen/map_view/char_preview/appearance = new(null, mocked)
		appearance.update_body()
		appearance.maptext_width = 120
		appearance.maptext_x = -42
		appearance.maptext_y = -12
		appearance.maptext = "<center>[ckey]</center>"
		contributer_pref_images += appearance

	for(var/ckey in GLOB.admin_datums)
		var/datum/client_interface/interface = new(ckey(ckey))
		var/datum/preferences/mocked = new(interface)

		var/atom/movable/screen/map_view/char_preview/appearance = new(null, mocked)
		appearance.update_body()
		appearance.maptext_width = 120
		appearance.maptext_x = -42
		appearance.maptext_y = -12
		appearance.maptext = "<center>[ckey]</center>"
		admin_pref_images += appearance

/datum/controller/subsystem/credits/proc/finalize_name()
	if(customized_name)
		episode_name = customized_name
		return
	var/list/drafted_names = list()
	var/list/name_reasons = list()
	var/list/is_rare_assoc_list = list()
	for(var/datum/episode_name/N as anything in episode_names)
		drafted_names["[N.thename]"] = N.weight
		name_reasons["[N.thename]"] = N.reason
		is_rare_assoc_list["[N.thename]"] = N.rare
	episode_name = pick_weight(drafted_names)
	episode_reason = name_reasons[episode_name]
	if(is_rare_assoc_list[episode_name] == TRUE)
		rare_episode_name = TRUE

/datum/controller/subsystem/credits/proc/finalize_episodestring()
	var/season = time2text(world.timeofday,"YY")
	var/episodenum = GLOB.round_id || 1
	episode_string = list("<center>SEASON [season] EPISODE [episodenum]</center>")
	episode_string += "<center>[episode_name]</center>"

/datum/controller/subsystem/credits/proc/finalize_disclaimerstring()
	disclaimers_string =  list()
	for(var/disclaimer in disclaimers)
		disclaimers_string += "<center>[disclaimer]</center>"

/datum/controller/subsystem/credits/proc/draft_disclaimers()
	disclaimers += "Filmed on Location at [station_name()].<br>"
	disclaimers += "Filmed with BYOND&#169; cameras and lenses. Outer space footage provided by NASA.<br>"
	disclaimers += "Additional special visual effects by LUMMOX&#174; JR. Motion Picture Productions.<br>"
	disclaimers += "Unofficially Sponsored by The United States Navy.<br>"
	disclaimers += "All rights reserved.<br>"
	disclaimers += "<br>"
	disclaimers += pick("All stunts were performed by underpaid and expendable interns. Do NOT try at home.<br>", "[director] does not endorse behaviour depicted. Attempt at your own risk.<br>")
	disclaimers += "This motion picture is (not) protected under the copyright laws of the United States and all countries throughout the universe"
	disclaimers += "Country of first publication: United States of America."
	disclaimers += "Any unauthorized exhibition, distribution, or copying of this picture or any part thereof (including soundtrack)"
	disclaimers += "is an infringement of the relevant copyright and will subject the infringer to civil liability and criminal prosecution."
	disclaimers += "The story, all names, characters, and incidents portrayed in this production are fictitious."
	disclaimers += "No identification with actual persons (living or deceased), places, buildings, and products is intended or should be inferred."

/datum/controller/subsystem/credits/proc/draft_caststring()
	cast_string = list("<center>CAST:</center>")
	var/cast_num = 0
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!H.ckey && !(H.stat == DEAD))
			continue
		var/assignment = H.get_assignment(if_no_id = "", if_no_job = "")
		cast_string += "<center><tr><td class= 'actorname'>[uppertext(H.mind.key)]</td><td class='actorsegue'> as </td><td class='actorrole'>[H.real_name][assignment == "" ? "" : ", [assignment]"]</td></tr></center>"
		cast_num++

	for(var/mob/living/silicon/S in GLOB.silicon_mobs)
		if(!S.ckey)
			continue
		cast_string += "<center>[uppertext(S.mind.key)] as [S.name]</center>"
		cast_num++

	if(!cast_num)
		cast_string += "<center><td class='actorsegue'>Nobody!</td></center>"

	var/list/corpses = list()
	for(var/mob/living/carbon/human/H in GLOB.dead_mob_list)
		if(!H.mind)
			continue
		if(H.real_name)
			corpses += H.real_name
	if(corpses.len)
		var/true_story_bro = "<center><br>[pick("BASED ON","INSPIRED BY","A RE-ENACTMENT OF")] [pick("A TRUE STORY","REAL EVENTS","THE EVENTS ABOARD [uppertext(station_name())]")]</center>"
		cast_string += "<center><h3>[true_story_bro]</h3><br>In memory of those that did not make it.<br>[english_list(corpses)].<br></center>"
	cast_string += "<br>"

/datum/controller/subsystem/credits/proc/generate_major_icon(list/mobs, passed_icon_state)
	if(!passed_icon_state)
		return
	var/obj/effect/title_card_object/MA
	for(var/obj/effect/title_card_object/effect as anything in major_event_icons)
		if(effect.icon_state == passed_icon_state)
			MA = effect
			break

	if(!MA)
		MA = new
		MA.icon_state = passed_icon_state
		major_event_icons += MA
		major_event_icons[MA] = list()

	major_event_icons[MA] |= mobs

/datum/controller/subsystem/credits/proc/resolve_clients(list/clients, icon_state)
	var/list/created_appearances = list()

	//hell
	switch(icon_state)
		if("cult")
			var/datum/team/cult/cult = locate(/datum/team/cult) in GLOB.antagonist_teams
			if(cult)
				for(var/mob/living/cultist in cult.true_cultists)
					if(!cultist.client)
						continue
					clients |= WEAKREF(cultist.client)
		if("revolution")
			var/datum/team/revolution/revolution = locate(/datum/team/revolution) in GLOB.antagonist_teams
			if(revolution)
				for(var/datum/mind/revolutionist in (revolution.ex_revs + revolution.ex_headrevs + revolution.members))
					if(!revolutionist?.current?.client)
						continue
					clients |= WEAKREF(revolutionist.current.client)
		if("clockcult")
			var/datum/team/clock_cult/clock_cult = locate(/datum/team/clock_cult) in GLOB.antagonist_teams
			if(clock_cult)
				for(var/mob/living/carbon/human/cultist in (clock_cult.human_servants))
					if(!cultist.client)
						continue
					clients |= WEAKREF(cultist.client)

	for(var/datum/weakref/weak as anything in clients)
		var/client/client = weak.resolve()
		if(!client)
			continue
		var/atom/movable/screen/map_view/char_preview/appearance = new(null, client.prefs)
		var/mutable_appearance/preview = new(getFlatIcon(client.mob?.appearance))
		appearance.appearance = preview.appearance
		appearance.maptext_width = 120
		appearance.maptext_x = -42
		appearance.maptext_y = -12
		appearance.maptext = "<center>[client.mob.real_name]</center>"
		created_appearances += appearance

	return created_appearances

/obj/effect/title_card_object
	plane = SPLASHSCREEN_PLANE
	icon = 'monkestation/code/modules/and_roll_credits/icons/title_cards.dmi'
	screen_loc = "CENTER-4,BOTTOM"
