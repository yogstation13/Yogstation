GLOBAL_LIST_INIT(cassette_reviews, list())

#define ADMIN_OPEN_REVIEW(id) "(<A href='byond://?_src_=holder;[HrefToken(forceGlobal = TRUE)];open_music_review=[id]'>Open Review</a>)"
/proc/submit_cassette_for_review(obj/item/device/cassette_tape/submitted, mob/user)
	if(!user.client)
		return
	var/datum/cassette_review/new_review = new
	new_review.submitter = user
	new_review.submitted_ckey = user.client.ckey
	for(var/num = 1 to length(submitted.song_names["side1"]))
		new_review.cassette_data["side1"]["song_name"] += submitted.song_names["side1"][num]
		new_review.cassette_data["side1"]["song_url"] += submitted.songs["side1"][num]

	for(var/num = 1 to length(submitted.song_names["side2"]))
		new_review.cassette_data["side2"]["song_name"] += submitted.song_names["side2"][num]
		new_review.cassette_data["side2"]["song_url"] += submitted.songs["side2"][num]

	if(!length(new_review.cassette_data))
		return
	new_review.id = "[random_string(4, GLOB.hex_characters)]_[new_review.submitted_ckey]"
	new_review.submitted_tape = submitted

	GLOB.cassette_reviews["[new_review.id]"] = new_review
	SEND_NOTFIED_ADMIN_MESSAGE('sound/items/bikehorn.ogg', "[span_big(span_admin("[span_prefix("MUSIC APPROVAL:")] <EM>[key_name(user)]</EM> [ADMIN_OPEN_REVIEW(new_review.id)] \
															has requested a review on their cassette."))]")
	to_chat(user, span_notice("Your Cassette has been sent to the Space Board of Music for review, you will be notified when an outcome has been made."))

/obj/item/device/cassette_tape/proc/generate_cassette_json()
	if(approved_tape)
		return
	if(!length(GLOB.approved_ids))
		GLOB.approved_ids = json_decode(file2text("data/cassette_storage/ids.json"))
	var/list/data = list()
	data["name"] = name
	data["desc"] = cassette_desc_string
	data["side1_icon"] = side1_icon
	data["side2_icon"] = side2_icon
	data["author_ckey"] = ckey_author
	data["author_name"] = author_name
	data["approved"] = TRUE
	data["songs"] = songs
	data["song_names"] = song_names

	approved_tape = TRUE
	update_appearance()
	var/json_name = "[random_string(16, GLOB.hex_characters)]_[ckey_author]"

	WRITE_FILE(file("data/cassette_storage/[json_name].json"), json_encode(data))
	var/list/names = json_decode(file2text(file("data/cassette_storage/ids.json")))
	fdel(file("data/cassette_storage/ids.json"))
	names += json_name
	GLOB.approved_ids += json_name
	WRITE_FILE(file("data/cassette_storage/ids.json"), json_encode(names))

/datum/cassette_review
	///the cassette_id random 4 characters + _submitted_ckey
	var/id
	///the submitting mob
	var/mob/submitter
	///the submitted mobs ckey
	var/submitted_ckey
	///the list of youtube links with the titles beside them as double list ie 1 = list(name, link)
	var/list/cassette_data = list(
		"side1" = list(
			"song_name" = list(),
			"song_url" = list()
		),
		"side2" = list(
			"song_name" = list(),
			"song_url" = list()
		)
	)
	var/obj/item/device/cassette_tape/submitted_tape

	var/action_taken = FALSE
	var/verdict = "NONE"

/datum/cassette_review/Destroy(force)
	if(cassette_data)
		cassette_data["side1"]["song_name"] = null
		cassette_data["side1"]["song_url"] = null
		cassette_data["side2"]["song_name"] = null
		cassette_data["side2"]["song_url"] = null
		cassette_data.Cut()
		cassette_data = null
	if(isnull(submitted_tape.loc))
		QDEL_NULL(submitted_tape) // Remove any tapes in null_space. Denied or Pending condition.
	if(id && (id in GLOB.cassette_reviews))
		GLOB.cassette_reviews -= id // Remove the key
	return 	..()

/datum/cassette_review/ui_state(mob/user)
	return GLOB.always_state

/datum/cassette_review/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteReview", "[submitted_ckey]'s Cassette")
		ui.open()

/datum/cassette_review/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	data["ckey"] = submitted_ckey
	data["submitters_name"] = submitter.real_name
	data["side1"] = cassette_data["side1"]
	data["side2"] = cassette_data["side2"]
	data["reviewed"] = action_taken
	data["verdict"] = verdict

	return data

/datum/cassette_review/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("approve")
			approve_review(usr)
		if("deny")
			to_chat(submitter, span_warning("You feel a wave of disapointment wash over you, you can tell that your cassette was denied by the Space Board of Music"))
			logger.Log(LOG_CATEGORY_MUSIC, "[submitter]'s tape has been rejected by [usr]", list("approver" = usr.name, "submitter" = submitter.name))
			action_taken = TRUE
			verdict = "DENIED"

/datum/cassette_review/proc/approve_review(mob/user)
	if(!check_rights_for(user.client, R_FUN))
		return
	submitted_tape.generate_cassette_json()
	to_chat(submitter, span_notice("You can feel the Space Board of Music has approved your cassette:[submitted_tape.name]."))
	submitted_tape.forceMove(get_turf(submitter))
	message_admins("[submitter]'s tape has been approved by [user]")
	logger.Log(LOG_CATEGORY_MUSIC, "[submitter]'s tape has been approved by [user]", list("approver" = user.name, "submitter" = submitter.name))
	action_taken = TRUE
	verdict = "APPROVED"

/proc/fetch_review(id)
	return GLOB.cassette_reviews[id]

#undef ADMIN_OPEN_REVIEW

// Handles UI to manage cassettes.
/client/proc/review_cassettes() //Creates a verb for admins to open up the ui
	set name = "Review Cassettes"
	set desc = "Review this rounds cassettes."
	set category = "Admin.Game"
	if(!check_rights(R_FUN))
		return
	new /datum/review_cassettes(usr)

/datum/review_cassettes
	var/client/holder //client of whoever is using this datum
	var/is_funmin = FALSE

/datum/review_cassettes/New(user)//user can either be a client or a mob due to byondcode(tm)
	holder = get_player_client(user)
	is_funmin = check_rights(R_FUN)
	ui_interact(holder.mob)//datum has a tgui component, here we open the window

/datum/review_cassettes/ui_status(mob/user, datum/ui_state/state)
	return (user.client == holder && is_funmin) ? UI_INTERACTIVE : UI_CLOSE


/datum/review_cassettes/ui_close()// Don't leave orphaned datums laying around. Hopefully this handles timeouts?
	qdel(src)

/datum/review_cassettes/ui_interact(mob/user, datum/tgui/ui) // Open UI and update as it remains open.
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CassetteManager")
		ui.open()

/datum/review_cassettes/ui_data(mob/user)
	. = ..()
	var/list/data = list("cassettes" = list()) // Initialize main data structure with an empty "cassettes" list

	for(var/cassette_id in GLOB.cassette_reviews)
		var/datum/cassette_review/cassette = GLOB.cassette_reviews[cassette_id]
		var/submitters_name = cassette.submitter
		var/obj/item/tape_obj = cassette.submitted_tape
		var/reviewed = cassette.action_taken
		var/verdict = cassette.verdict

		// Add this cassette's data under its cassette_id
		data["cassettes"][cassette_id] = list(
			"submitter_name" = submitters_name,
			"tape_name" = tape_obj.name,
			"reviewed" = reviewed,
			"verdict" = verdict,
		)
	return data

/datum/review_cassettes/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!length(GLOB.cassette_reviews))
		return

	var/tape_id = params["tape_id"]
	if(!tape_id || !GLOB.cassette_reviews[tape_id])
		return

	if(action == "delete_cassette")
		var/datum/cassette_review/cassette = GLOB.cassette_reviews[tape_id]
		var/final_info = (cassette.action_taken ? "Action taken: True, verdict was [cassette.verdict]" : "Action taken: False")
		message_admins("[key_name_admin(usr)] has deleted Cassette:[cassette.submitted_tape.name] with ID:[tape_id]. [final_info]")
		log_admin("[key_name(usr)] sent \"[action]\" on [cassette.submitted_tape.name] with ID:[tape_id]. [final_info]")
		qdel(cassette)
		return

	if(action == "review_cassette")
		var/datum/cassette_review/cassette = GLOB.cassette_reviews[tape_id]
		cassette.ui_interact(ui.user)
		return


