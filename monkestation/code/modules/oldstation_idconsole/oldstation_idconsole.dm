//i'd rather type suicide in the command bar than put everything in separate files

//charlie station uses it's own machine for this since all it does is turn the id into an old id
/obj/machinery/oldpdapainter
	name = "Charlie Station ID Painter"
	desc = "A painting machine that can be used to paint IDs. To use, simply insert the ID. It looks old and dusty.."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdapainter"
	density = TRUE
	max_integrity = 200
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.02
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.05
	//dont turn these ids into charlie station ids please, this might be redundant
	var/static/list/blacklisted_typecache = typecacheof(list(
		/obj/item/card/id/away,
		/obj/item/card/id/advanced/silver,
		/obj/item/card/id/advanced/gold,
		/obj/item/card/id/advanced/chameleon,
	))

/obj/machinery/oldpdapainter/attackby(obj/item/item, mob/living/user, params)
	if(!is_operational)
		to_chat(user, span_warning("[src] has to be on to do this!"))
		return FALSE

	if(istype(item, /obj/item/card/id))
		var/obj/item/card/id/card = item

		if(is_type_in_typecache(card, blacklisted_typecache) || card.trim)
			to_chat(user, span_warning("You can't paint this card!"))
			return FALSE

		to_chat(user, span_notice("You start painting \the [card]..."))

		if(!do_after(user, 4 SECONDS, target = src))
			return FALSE

		use_power(active_power_usage)

		var/old_name = card.name
		QDEL_NULL(card)

		var/obj/item/card/id/away/old/custom/new_id = new(drop_location())
		SSid_access.apply_trim_to_card(new_id, /datum/id_trim/job/away/old/custom, copy_access = FALSE)

		to_chat(user, span_notice("You paint \the [old_name]!"))
	else
		return ..()

/datum/computer_file/program/card_mod/old
	filename = "charliestationidwriter"
	filedesc = "Charlie Station Access Management"
	available_on_ntnet = FALSE //charlie station only fools

	//every access i could find on charlie station ids
	valid_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_RESEARCH,
		ACCESS_AWAY_SCIENCE,
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)

/datum/computer_file/program/card_mod/old/authenticate(mob/user, obj/item/card/id/auth_card)
	if(!auth_card)
		return

	if((ACCESS_AWAY_COMMAND in auth_card.access))
		authenticated_card = "[auth_card.name]"
		authenticated_user = auth_card.registered_name ? auth_card.registered_name : "Unknown"
		return TRUE

	return FALSE

/datum/computer_file/program/card_mod/old/ui_static_data(mob/user)
	var/list/data = list()
	data["station_name"] = "Charlie Station" //we arent ss13, don't show as such (despite the fact this isn't shown anywhere??)
	data["centcom_access"] = is_centcom
	data["minor"] = target_dept || minor ? TRUE : FALSE

	var/list/regions = list()
	var/list/tgui_region_data = SSid_access.all_region_access_tgui

	regions += tgui_region_data[REGION_CHARLIE_STATION] //we only give charlie access, sorry buddy

	data["regions"] = regions


	data["accessFlags"] = SSid_access.flags_by_access
	data["wildcardFlags"] = SSid_access.wildcard_flags_by_wildcard
	data["accessFlagNames"] = SSid_access.access_flag_string_by_flag
	data["showBasic"] = TRUE
	data["templates"] = job_templates

	return data

/obj/machinery/modular_computer/preset/id/old
	starting_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/card_mod/old,
		/datum/computer_file/program/job_management,
		/datum/computer_file/program/crew_manifest,
	)

/obj/machinery/modular_computer/preset/command/old
	starting_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/card_mod/old,
	)

/datum/id_trim/job/away/old
	trim_state = null

/datum/id_trim/job/away/old/custom
	assignment = "Charlie Station Crew"
	minimal_access = list(
		ACCESS_AWAY_GENERAL,
		ACCESS_ROBOTICS,
		ACCESS_ORDNANCE,
		ACCESS_RESEARCH,
		ACCESS_AWAY_SCIENCE,
		ACCESS_AWAY_MAINTENANCE,
		ACCESS_AWAY_SUPPLY,
		ACCESS_AWAY_GENERIC1,
		ACCESS_AWAY_GENERIC2,
		ACCESS_AWAY_GENERIC3,
		ACCESS_AWAY_GENERIC4,
		ACCESS_AWAY_COMMAND,
		ACCESS_AWAY_MEDICAL,
		ACCESS_AWAY_SEC,
		ACCESS_AWAY_ENGINEERING,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP
	)

/obj/item/card/id/away/old/custom
	name = "Charlie Station ID card"
	desc = "A card used to provide ID and determine access across Charlie Station."
