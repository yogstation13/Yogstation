/datum/antagonist/nukeop
	remove_from_manifest = TRUE

/datum/round_event_control/junior_lone_operative
	name = "Junior Lone Operative"
	typepath = /datum/round_event/ghost_role/junior_operative

	category = EVENT_CATEGORY_INVASION
	description = "A junior nuclear operative infiltrates the station."
	weight = 1

/datum/round_event/ghost_role/junior_operative
	minimum_required = 1
	role_name = "junior lone operative"
	fakeable = FALSE

/datum/round_event/ghost_role/junior_operative/spawn_role()
	var/list/candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_OPERATIVE, role = ROLE_LONE_OPERATIVE, alert_pic = /obj/item/clothing/head/helmet/space/syndicate, role_name_text = "Junior Lone Operative")
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/spawn_location = find_space_spawn()
	if(isnull(spawn_location))
		return MAP_ERROR

	var/mob/living/carbon/human/operative = new(spawn_location)
	operative.randomize_human_appearance(~RANDOMIZE_SPECIES)
	operative.dna.update_dna_identity()
	var/datum/mind/Mind = new /datum/mind(selected.key)
	Mind.set_assigned_role(SSjob.GetJobType(/datum/job/lone_operative))
	Mind.special_role = ROLE_LONE_OPERATIVE
	Mind.active = TRUE
	Mind.transfer_to(operative)
	if(!operative.client?.prefs.read_preference(/datum/preference/toggle/nuke_ops_species))
		var/species_type = operative.client.prefs.read_preference(/datum/preference/choiced/species)
		operative.set_species(species_type) //Apply the preferred species to our freshly-made body.

	Mind.add_antag_datum(/datum/antagonist/nukeop/lone/junior)

	message_admins("[ADMIN_LOOKUPFLW(operative)] has been made into a junior lone operative by an event.")
	operative.log_message("was spawned as a junior lone operative by an event.", LOG_GAME)
	spawned_mobs += operative
	return SUCCESSFUL_SPAWN

/datum/antagonist/nukeop/lone/junior
	name = "Junior Lone Operative"
	nukeop_outfit = /datum/outfit/syndicate/junior
	preview_outfit = /datum/outfit/syndicate/junior

/datum/outfit/syndicate/junior
	name = "Syndicate Junior Operative"

	glasses = /obj/item/clothing/glasses/night
	back = /obj/item/storage/backpack/fireproof
	head = /obj/item/clothing/head/helmet/space/syndicate
	suit = /obj/item/clothing/suit/space/syndicate
	suit_store = /obj/item/tank/jetpack/oxygen
	belt = /obj/item/storage/belt/military
	l_pocket = /obj/item/pinpointer/nuke
	r_pocket = null
	id = /obj/item/card/id/advanced/chameleon
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m9mm = 1,
		/obj/item/pen/edagger = 1,
	)
	tc = 10
	uplink_type = /obj/item/uplink/old

/datum/outfit/syndicate/junior/plasmaman
	name = "Syndicate Junior Operative (Plasmaman)"
	uniform = /obj/item/clothing/under/plasmaman/syndicate
	r_hand = /obj/item/tank/internals/plasmaman/belt/full

/datum/outfit/syndicate/junior/plasmaman/New()
	backpack_contents += /obj/item/clothing/head/helmet/space/plasmaman/syndie
	return ..()

/datum/antagonist/nukeop/lone/junior/assign_nuke()
	if(nuke_team && !nuke_team.tracked_nuke)
		nuke_team.memorized_code = random_nukecode()
		var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
		if(nuke)
			nuke_team.tracked_nuke = nuke
			if(nuke.r_code == NUKE_CODE_UNSET)
				nuke.r_code = nuke_team.memorized_code
			else //Already set by admins/something else?
				nuke_team.memorized_code = nuke.r_code
		else
			stack_trace("Station self-destruct not found during lone op team creation.")
			nuke_team.memorized_code = null

/datum/antagonist/nukeop/lone/junior/memorize_code()
	if(nuke_team && nuke_team.tracked_nuke)
		antag_memory += "<B>[nuke_team.tracked_nuke]</B>"
	var/code
	var/obj/item/paper/fluff/nuke_code/nuke_code_paper = new
	if(nuke_team?.memorized_code)
		var/scrambled = FALSE
		var/scramble_attempts = 0
		code = "[nuke_team.memorized_code]"
		while(!scrambled)
			var/random_number = rand(0,9)
			scramble_attempts++
			if(findtext(code, "[random_number]"))
				code = replacetext(code, "[random_number]", "#")
				scrambled = TRUE
			if(scramble_attempts >= 10)
				scrambled = TRUE
	else
		code = "ERROR"
	nuke_code_paper.add_raw_text("The nuclear authorization code is: <b>[code]</b>")
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		nuke_code_paper.forceMove(get_turf(H))
	else
		H.equip_to_slot_or_del(nuke_code_paper, ITEM_SLOT_RPOCKET)
	var/mob/living/datum_owner = owner.current
	to_chat(datum_owner, "<b>Code Phrases</b>: [span_blue(jointext(GLOB.syndicate_code_phrase, ", "))]")
	to_chat(datum_owner, "<b>Code Responses</b>: [span_red("[jointext(GLOB.syndicate_code_response, ", ")]")]")
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_phrase_regex, "blue", src)
	datum_owner.AddComponent(/datum/component/codeword_hearing, GLOB.syndicate_code_response_regex, "red", src)
	datum_owner.add_mob_memory(/datum/memory/key/codewords)
	datum_owner.add_mob_memory(/datum/memory/key/codewords/responses)

/obj/item/paper/fluff/nuke_code
	name = "ATTENTION: Mission Instructions."
	color = "#b94030"
	desc = "Seems important."
	default_raw_text = {"
Greetings operative.

<br>Your mission is to destroy the targeted Nanotrasen facility using it's own self destruct mechanism.
<br>
<br>Nanotrasen building codes usually place the self destruct terminal in the facility's high security vault.
You will need a Nanotrasen nuclear authentication disk to get through the first security barrier of the terminal.
The disk can be found on the captain or acting captain of the facility as they are are required to keep the disk on
their person at all times.
<B>Your pinpointer is set to track the disk to further aid in locating it.<B>
<br>
<br>The steps for activating the self destruct via the terminal are as follows:
<br>
<br> 1. Insert the nuclear authentication disk into the terminal.
<br>
<br> 2. Enter the five digit nuclear authorization code.
<br>
<br> 5. Set the timer by entering a time between 90 and 3600 seconds.
<br>
<br> 4. Arm the self destruct. Remove and take the disk to prevent disarmament of the self destruct mechanism.
<br>
<br> <B>THE FOLLOWING CODE MAY BE INCOMPLETE DUE TO INEFFECTIVE SECTOR SURVEILLANCE. AN OVERALL DIGIT MAY BE OMITTED.<B>
<br>
	"}
