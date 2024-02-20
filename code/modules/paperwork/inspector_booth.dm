/obj/machinery/inspector_booth
	name = "inspector booth"
	desc = "Used for inspecting paperwork and ID cards."
	icon = 'icons/obj/machines/inspector_booth.dmi'
	icon_state = "booth"
	// TODO: add reduced power usage for part upgrades
	//use_power = NO_POWER_USE
	//idle_power_usage = 20
	//active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/inspector_booth
	density = TRUE
	
	// TODO: add increased health and armor for part upgrades
	// armor = list(MELEE = 25, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 70)
	// max_integrity = 200

	var/max_items = 5
	var/max_stamps = 3

	// Internal data
	var/item_ids = 0
	var/item_list = list()
	var/list/stamp_upgrades = list()
	var/list/concurrent_users = list()

	// Reference data
	var/stamp_types = list(
		"stamp-ok" = "stamp_approve.png",
		"stamp-deny" = "stamp_deny.png",
		"stamp-cap" = "stamp_cap.png",
		"stamp-hop" = "stamp_hop.png",
		"stamp-hos" = "stamp_hos.png",
		"stamp-cmo" = "stamp_cmo.png",
		"stamp-qm" = "stamp_qm.png",
		"stamp-rd" = "stamp_rd.png",
		"stamp-ce" = "stamp_ce.png",
		"stamp-law" = "stamp_law.png",
		"stamp-clown" = "stamp_clown.png",
		"stamp-syndi" = "stamp_syndi.png",
		"stamp-cent" = "stamp_cent.png",
		"stamp-syndiround" = "stamp_syndiround.png",
	)
	var/sfx = list(
		"speaker" = 'sound/machines/inspector_booth/speech-announce.wav',
		"tray_open" = 'sound/machines/inspector_booth/stampbar-open.wav',
		"tray_close" = 'sound/machines/inspector_booth/stampbar-close.wav',
		"stamp_up" = 'sound/machines/inspector_booth/stamp-up.wav',
		"stamp_down" = 'sound/machines/inspector_booth/stamp-down.wav',
		"drag_start" = 'sound/machines/inspector_booth/paper-dragstart1.wav',
		"drag_stop" = 'sound/machines/inspector_booth/paper-dragstop1.wav',
		"card_drag_start" = 'sound/machines/inspector_booth/paper-dragstart0.wav',
		"card_drag_stop" = 'sound/machines/inspector_booth/paper-dragstop0.wav',
	)


/obj/machinery/inspector_booth/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/inspector_booth/update_icon_state()
	. = ..()
	if (stat & NOPOWER)
		icon_state = "booth_off"
	else if (panel_open || stat & MAINT)
		icon_state = "booth_maintenance"
	else
		icon_state = "booth"

/obj/machinery/inspector_booth/RefreshParts()
	var/b
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		b += B.rating
	var/m
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		m += M.rating
	max_items = 3 + 2*b
	max_stamps = 2 + m

/obj/machinery/inspector_booth/examine(mob/user)
	. = ..()
	var/item_capacity = max_items - contents.len
	var/stamp_capacity = max_stamps - stamp_upgrades.len
	if (in_range(user, src) || isobserver(user))
		. += span_notice("It looks like there is room for [item_capacity] more items and [stamp_capacity] more stamps.")
	if (panel_open)
		. += span_notice("[src]'s maintenance panel is open!")

/obj/machinery/inspector_booth/attackby(obj/item/I, mob/user, params)
	// Normal tool interactions
	if ((get_dir(user, src) == src.dir || get_dist_chebyshev(src, user) == 0) && default_deconstruction_screwdriver(user, "booth_maintenance", "booth", I))
		return
	if (default_change_direction_wrench(user, I) || default_deconstruction_crowbar(I))
		return

	if (user.a_intent != INTENT_HELP)
		return ..()

	// For adding stamp upgrades to component_parts
	if (istype(I, /obj/item/stamp))
		if (stamp_upgrades.len < max_stamps) 
			if (!(I.icon_state in stamp_upgrades))
				if (is_item_safe(user, I))
					component_parts += I
					stamp_upgrades += I.icon_state
					I.moveToNullspace()
					user.visible_message("[user] upgrades \the [src] with \the [I].", \
					span_notice("You upgrade \the [src] with \the [I]."))
			else 
				to_chat(user, span_warning("\The [src] already contains \a [I]!"))
		else
			to_chat(user, span_warning("\The [src]'s stamp tray is full!"))
		return
	
	// Adding to src
	if (contents.len >= max_items)
		to_chat(user, span_warning("\The [src] is full!"))
		return

	var/valid = FALSE
	if (istype(I, /obj/item/paper))
		valid = TRUE
	else if (istype(I, /obj/item/card/id))
		if (!istype(I, /obj/item/card/id/captains_spare/temporary))
			valid = TRUE
	
	if (valid)
		if (is_item_safe(user, I))
			if (user.transferItemToLoc(I, src))
				user.visible_message("[user] inserts \the [I] into \the [src].", \
				span_notice("You insert \the [I] into \the [src]."))
				item_list["item"+ num2text(++item_ids)] = list("item" = I, "x" = 0, "y" = 0, "z" = -1)
			else
				to_chat(user, span_warning("You failed to insert \the [I] into \the [src]!"))
	else
		to_chat(user, span_warning("\The [src] rejects \the [I]."))

// TODO: Add auto extinguishing/decontam for part upgrades
/obj/machinery/inspector_booth/proc/is_item_safe(mob/user, obj/item/I)
	var/safe = TRUE
	if (I.resistance_flags & ON_FIRE)
		safe = FALSE
		to_chat(user, span_warning("\The [src] rejects the burning [I]!"))
	else
		var/datum/component/radioactive/radiation = I.GetComponent(/datum/component/radioactive)
		if (radiation && radiation.strength > 50)
			safe = FALSE
			to_chat(user, span_warning("\The [src] rejects the irradiated [I]!"))
	return safe

/obj/machinery/inspector_booth/can_interact(mob/user)
	. = ..()
	if (get_dist_chebyshev(src, user) == 0)
		return TRUE
	if((get_dir(user, src) != src.dir && !isobserver(user)))
		return FALSE

/obj/machinery/inspector_booth/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		var/user_ref = REF(user)
		var/is_living = isliving(user)
		if (is_living)
			concurrent_users += user_ref
		ui = new(user, src, "InspectorBooth", name)
		ui.open()

/obj/machinery/inspector_booth/ui_close(mob/user)
	var/user_ref = REF(user)
	concurrent_users -= user_ref

/obj/machinery/inspector_booth/ui_data(mob/living/carbon/human/user)
	var/list/data = list()
	var/list/items = list()

	// Process items
	var/list/names = list()
	var/name_index = 0
	for (var/key in item_list)
		var/I = item_list[key]["item"]
		
		if (istype(I, /obj/item/paper))
			var/obj/item/paper/P = I
			var/text = P.info
			for (var/i = 1; i <= P.written.len; ++i)
				if (istype(P.written[i] ,/datum/langtext))
					var/datum/langtext/L = P.written[i]
					text += "\n" + L.text
			items["papers"] += list(list("id" = key, "text" = text, "stamps" = P.stamps, 
				"x" = item_list[key]["x"], "y" = item_list[key]["y"], "z" = item_list[key]["z"]))
		
		if (istype(I, /obj/item/card/id))
			var/obj/item/card/id/D = I
			names[D.registered_name] = ++name_index
			var/colors = get_colors_by_job(D.originalassignment)
			items["idcards"] += list(list("id" = key, "name" = D.registered_name, "age" = D.registered_age, 
				"job" = D.assignment, "bg" = D.icon_state, "department" = colors[1], "color" = colors[2], 
				"x" = item_list[key]["x"], "y" = item_list[key]["y"], "z" = item_list[key]["z"]))
	
	// Retroactively add profile pictures to ids
	// The reason why we want to store all the names we want to search
	// first is so that we only have to loop through the data core once
	// This could be improved by caching the datum/record on item insert
	if (name_index > 0)
		for (var/record in GLOB.data_core.general)
			var/datum/data/record/R = record
			var/name = R.fields["name"]
			if ((name in names) && (istype(R.fields["photo_front"], /obj/item/photo)))
				var/obj/item/photo/P = R.fields["photo_front"]
				var/icon/picture = icon(P.picture.picture_image)
				picture.Crop(10, 32, 22, 22)
				var/md5 = md5(fcopy_rsc(picture))
				if (!SSassets.cache["photo_[md5]_cropped.png"])
					SSassets.transport.register_asset("photo_[md5]_cropped.png", picture)
				SSassets.transport.send_assets(user, list("photo_[md5]_cropped.png" = picture))
				items["idcards"][names[name]] += list("picture" = SSassets.transport.get_asset_url("photo_[md5]_cropped.png"))

	data["items"] = items

	// Process stamp components
	var/list/stamps = list()
	for (var/obj/item/stamp/S in component_parts)
		var/name = S.icon_state
		if (name in stamp_types)
			stamps += list(list("type" = name, "icon" = stamp_types[name]))
		else
			stamps += list(list("type" = name, "icon" = "stamp_unknown.png"))
	data["stamps"] = stamps
			
	return data

/obj/machinery/inspector_booth/ui_act(action, list/params)
	if (..())
		return
	
	var/mob/living/user = params["ckey"] ? get_mob_by_key(params["ckey"]) : null
	if (user != null && get_dist_chebyshev(src, user) > sqrt(2))
		user = null
	var/obj/item = (params["id"] in item_list) ? item_list[params["id"]]["item"] : null

	switch(action)
		if ("play_sfx")
			var/name = params["name"]
			if (name in sfx)
				var/volume = params["volume"] ? params["volume"] : 50
				var/vary = params["vary"] ? params["vary"] > 0 : TRUE
				var/extra_range = params["extrarange"] ? params["extrarange"] : -3
				playsound(user ? user : src, sfx[name], volume, vary, extra_range)
				. = TRUE
		if ("stamp_item")
			var/type = params["type"] ? params["type"] : "stamp-mime"
			if (item != null)
				if (istype(item, /obj/item/paper))
					var/obj/item/paper/P = item
					// This was copied from Paper.dm and should probably be moved into its own proc there
					var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
					if (isnull(P.stamps))
						P.stamps = sheet.css_tag()
					P.stamps += sheet.icon_tag(type)
					var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[type]")
					stampoverlay.pixel_x = rand(-2, 2)
					stampoverlay.pixel_y = rand(-3, 2)
					LAZYADD(P.stamped, type)
					P.add_overlay(stampoverlay)
					. = TRUE
		if ("move_item")
			if (params["id"] in item_list)
				var/id = params["id"]
				item_list[id]["x"] = params["x"]
				item_list[id]["y"] = params["y"]
				item_list[id]["z"] = params["z"]
				. = TRUE
		if ("take_item")
			if (user && item && !QDELETED(item))
				user.put_in_hands(item)
				item_list -= params["id"]
				. = TRUE
		if ("drop_item")
			if (item && !QDELETED(item))
				item.forceMove(drop_location())
				item_list -= params["id"]
				. = TRUE

/obj/machinery/inspector_booth/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inspector_booth),
		get_asset_datum(/datum/asset/spritesheet/simple/paper),
	)

// Should probably be moved into game.dm
/proc/get_dist_chebyshev(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y
	return max(abs(dx), abs(dy))

// Copy-pasting the entire proc from yogstation/../cards_ids.dm
// because the list there is a private var and its more work
// to parse and process the overlays back into strings
/obj/machinery/inspector_booth/proc/get_colors_by_job(real_job)
	var/list/idfluff = list(
	"Assistant" = list("civillian","green"),
	"Captain" = list("captain","gold"),
	"Head of Personnel" = list("civillian","silver"),
	"Head of Security" = list("security","silver"),
	"Chief Engineer" = list("engineering","silver"),
	"Research Director" = list("science","silver"),
	"Chief Medical Officer" = list("medical","silver"),
	"Station Engineer" = list("engineering","yellow"),
	"Atmospheric Technician" = list("engineering","white"),
	"Network Admin" = list("engineering","green"),
	"Medical Doctor" = list("medical","blue"),
	"Geneticist" = list("medical","purple"),
	"Virologist" = list("medical","green"),
	"Chemist" = list("medical","orange"),
	"Paramedic" = list("medical","white"),
	"Psychiatrist" = list("medical","brown"),
	"Scientist" = list("science","purple"),
	"Roboticist" = list("science","black"),
	"Quartermaster" = list("cargo","silver"),
	"Cargo Technician" = list("cargo","brown"),
	"Shaft Miner" = list("cargo","black"),
	"Mining Medic" = list("cargo","blue"),
	"Bartender" = list("civillian","black"),
	"Botanist" = list("civillian","blue"),
	"Cook" = list("civillian","white"),
	"Janitor" = list("civillian","purple"),
	"Curator" = list("civillian","purple"),
	"Chaplain" = list("civillian","black"),
	"Clown" = list("clown","rainbow"),
	"Mime" = list("mime","white"),
	"Artist" = list("civillian","yellow"),
	"Clerk" = list("civillian","blue"),
	"Tourist" = list("civillian","yellow"),
	"Warden" = list("security","black"),
	"Security Officer" = list("security","red"),
	"Detective" = list("security","brown"),
	"Brig Physician" = list("security","blue"),
	"Lawyer" = list("security","purple")
	)
	if (real_job in idfluff)
		return idfluff[real_job]
	else
		return idfluff["Assistant"]
