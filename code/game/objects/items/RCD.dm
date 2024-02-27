
/*
CONTAINS:
RCD
ARCD
RLD
*/

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with metal, plasteel, glass or compressed matter cartridges."
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=100000)
	req_access_txt = "11"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/no_ammo_message = span_warning("The \'Low Ammo\' light on the device blinks yellow.")
	var/has_ammobar = FALSE	//controls whether or not does update_icon apply ammo indicator overlays
	var/ammo_sections = 10	//amount of divisions in the ammo indicator overlay/number of ammo indicator states
	/// Bitflags for upgrades
	var/upgrade = NONE
	/// Bitflags for banned upgrades
	var/banned_upgrades = NONE
	var/datum/component/remote_materials/silo_mats //remote connection to the silo
	var/silo_link = FALSE //switch to use internal or remote storage
	var/linked_switch_id = null	//integer variable, the id for the assigned conveyor switch
	var/obj/machinery/conveyor/last_placed
	var/color_choice = null
	var/silent = FALSE // does it make sound? (used for mime mech RCD)

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", mapload, FALSE)

/// Used for examining the RCD and for its UI
/obj/item/construction/proc/get_silo_iron()
	if(silo_link && silo_mats.mat_container && !silo_mats.on_hold())
		return silo_mats.mat_container.get_material_amount(/datum/material/iron)/500
	return FALSE

/obj/item/construction/examine(mob/user)
	. = ..()
	. += "It currently holds [matter]/[max_matter] matter-units."
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		. += "Remote storage link state: [silo_link ? "[silo_mats.on_hold() ? "ON HOLD" : "ON"]" : "OFF"]."
		var/iron = get_silo_iron()
		if(iron)
			. += "Remote connection has iron in equivalent to [iron] RCD unit\s." //1 matter for 1 floor tile, as 4 tiles are produced from 1 metal

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	silo_mats = null
	return ..()

/obj/item/construction/pre_attack(atom/target, mob/user, params)
	if(istype(target, /obj/item/rcd_upgrade))
		install_upgrade(target, user)
		return TRUE
	if(insert_matter(target, user))
		return TRUE
	return ..()

/obj/item/construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_upgrade))
		install_upgrade(W, user)
		return TRUE
	if(insert_matter(W, user))
		return TRUE
	return ..()

/// Installs an upgrade into the RCD checking if it is already installed, or if it is a banned upgrade
/obj/item/construction/proc/install_upgrade(obj/item/rcd_upgrade/rcd_up, mob/user)
	if(rcd_up.upgrade & upgrade)
		to_chat(user, span_warning("[src] has already installed this upgrade!"))
		return
	if(rcd_up.upgrade & banned_upgrades)
		to_chat(user, span_warning("[src] can't install this upgrade!"))
		return
	upgrade |= rcd_up.upgrade
	if((rcd_up.upgrade & RCD_UPGRADE_SILO_LINK) && !silo_mats)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE, FALSE)
	if(!silent)
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(rcd_up)

/// Inserts matter into the RCD allowing it to build
/obj/item/construction/proc/insert_matter(obj/O, mob/user)
	if(iscyborg(user))
		return FALSE

	var/loaded = FALSE
	if(istype(O, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = O
		var/load = min(R.ammoamt, max_matter - matter)
		if(load <= 0)
			to_chat(user, span_warning("[src] can't hold any more matter-units!"))
			return FALSE
		R.ammoamt -= load
		if(R.ammoamt <= 0)
			qdel(R)
		matter += load
		if(!silent)
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		loaded = TRUE
	else if(istype(O, /obj/item/stack))
		loaded = loadwithsheets(O, user)
	if(loaded)
		to_chat(user, span_notice("[src] now holds [matter]/[max_matter] matter-units."))
		update_appearance(UPDATE_ICON)	//ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/proc/loadwithsheets(obj/item/stack/S, mob/user)
	var/value = S.matter_amount
	if(value <= 0)
		to_chat(user, span_notice("You can't insert [S.name] into [src]!"))
		return FALSE
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		if(!silent)
			playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		to_chat(user, span_notice("You insert [amount_to_use] [S.name] sheets into [src]. "))
		return TRUE
	to_chat(user, span_warning("You can't insert any more [S.name] sheets into [src]!"))
	return FALSE

/obj/item/construction/proc/activate()
	if(!silent)
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/item/construction/attack_self(mob/user)
	if(!silent)
		playsound(src.loc, 'sound/effects/pop.ogg', 50, FALSE)
	if(prob(20))
		spark_system.start()

/obj/item/construction/proc/useResource(amount, mob/user)
	if(!silo_link || !silo_mats || !silo_mats.mat_container)
		if(matter < amount)
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE
		matter -= amount
		update_appearance(UPDATE_ICON)
		return TRUE
	else
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, span_alert("Mineral access is on hold, please contact the quartermaster."))
			return FALSE
		if(!silo_mats.mat_container)
			to_chat(user, span_alert("No silo link detected. Connect to silo via multitool."))
			return FALSE
		if(!silo_mats.mat_container.has_materials(list(/datum/material/iron = 500), amount))
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE

		var/list/materials = list()
		materials[getmaterialref(/datum/material/iron)] = 500
		silo_mats.mat_container.use_materials(materials, amount)
		silo_mats.silo_log(src, "consume", -amount, "build", materials)
		return TRUE

/obj/item/construction/ui_data(mob/user)
	var/list/data = list()

	//matter in the rcd
	var/total_matter = ((upgrade & RCD_UPGRADE_SILO_LINK) && silo_link) ? get_silo_iron() : matter
	if(!total_matter)
		total_matter = 0
	data["matterLeft"] = total_matter

	//silo details
	data["silo_upgraded"] = !!(upgrade & RCD_UPGRADE_SILO_LINK)
	data["silo_enabled"] = silo_link

	return data

///shared action for toggling silo link rcd,rld & plumbing
/obj/item/construction/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(action == "toggle_silo")
		if(silo_mats)
			if(!silo_mats.mat_container && !silo_link) // Allow them to turn off an invalid link
				to_chat(usr, span_alert("No silo link detected. Connect to silo via multitool."))
				return FALSE
			silo_link = !silo_link
			to_chat(usr, span_notice("You change [src]'s storage link state: [silo_link ? "ON" : "OFF"]."))
		else
			to_chat(usr, span_warning("[src] doesn't have remote storage connection."))
		return TRUE
	return FALSE

/obj/item/construction/proc/checkResource(amount, mob/user)
	if(!silo_link || !silo_mats || !silo_mats.mat_container)
		. = matter >= amount
	else
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, span_alert("Mineral access is on hold, please contact the quartermaster."))
			return FALSE
		. = silo_mats.mat_container.has_materials(list(/datum/material/iron = 500), amount)
	if(!. && user)
		to_chat(user, no_ammo_message)
		if(has_ammobar)
			flick("[icon_state]_empty", src)	//somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .

/obj/item/construction/proc/range_check(atom/A, mob/user)
	if(!(A in view(7, get_turf(user))))
		to_chat(user, span_warning("The \'Out of Range\' light on [src] blinks red."))
		return FALSE
	else
		return TRUE

/obj/item/construction/proc/prox_check(proximity)
	if(proximity)
		return TRUE
	else
		return FALSE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The living mob interacting with the menu
 * * remote_anchor The remote anchor for the menu
 */
/obj/item/construction/proc/check_menu(mob/living/user, remote_anchor)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(remote_anchor && user.remote_control != remote_anchor)
		return FALSE
	return TRUE

///each define maps to a variable used for construction in the RCD
#define CONSTRUCTION_MODE "construction_mode"
#define WINDOW_TYPE "window_type"
#define WINDOW_GLASS "window_glass"
#define WINDOW_SIZE "window_size"
#define COMPUTER_DIR "computer_dir"
#define FURNISH_TYPE "furnish_type"
#define FURNISH_COST "furnish_cost"
#define FURNISH_DELAY "furnish_delay"
#define AIRLOCK_TYPE "airlock_type"
#define CONVEYOR_TYPE "conveyor_type"

///flags to be sent to UI
#define TITLE "title"
#define ICON "icon"

///flags for creating icons shared by an entire category
#define CATEGORY_ICON_STATE  "category_icon_state"
#define CATEGORY_ICON_SUFFIX "category_icon_suffix"
#define TITLE_ICON "ICON=TITLE"

/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_price = 150
	max_matter = 160
	slot_flags = ITEM_SLOT_BELT
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE

	///all stuff used by RCD for construction
	var/static/list/root_categories = list(
		//1ST ROOT CATEGORY
		"Construction" = list( //Stuff you use to make & decorate areas
			//Walls & Windows
			"Structures" = list(
				list(CONSTRUCTION_MODE = RCD_FLOORWALL, ICON = "wallfloor", TITLE = "Wall/Floor"),
				list(CONSTRUCTION_MODE = RCD_DECONSTRUCT, ICON = "delete", TITLE = "Deconstruct"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window, WINDOW_GLASS = RCD_WINDOW_NORMAL, WINDOW_SIZE =  RCD_WINDOW_DIRECTIONAL, ICON = "dirwindow", TITLE = "Directional Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/fulltile, WINDOW_GLASS = RCD_WINDOW_NORMAL, WINDOW_SIZE =  RCD_WINDOW_FULLTILE, ICON = "fullwindow", TITLE = "Full Tile Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/reinforced, WINDOW_GLASS = RCD_WINDOW_REINFORCED, WINDOW_SIZE =  RCD_WINDOW_DIRECTIONAL, ICON = "dirwindow_r", TITLE = "Directional Reinforced Window"),
				list(CONSTRUCTION_MODE = RCD_WINDOWGRILLE, WINDOW_TYPE = /obj/structure/window/reinforced/fulltile, WINDOW_GLASS = RCD_WINDOW_REINFORCED, WINDOW_SIZE =  RCD_WINDOW_FULLTILE, ICON = "fullwindow_r", TITLE = "Full Tile Reinforced Window"),
			),

			//Computers & Machine Frames
			"Machines" = list(
				list(CONSTRUCTION_MODE = RCD_MACHINE, ICON = "box_1", TITLE = "Machine Frame"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 1, ICON = "cnorth", TITLE = "Computer North"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 2, ICON = "csouth", TITLE = "Computer South"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 4, ICON = "ceast", TITLE = "Computer East"),
				list(CONSTRUCTION_MODE = RCD_COMPUTER, COMPUTER_DIR = 8, ICON = "cwest", TITLE = "Computer West"),
			),

			//Interior Design[construction_mode = RCD_FURNISHING is implied]
			"Furniture" = list(
				list(FURNISH_TYPE = /obj/structure/chair, FURNISH_COST = 8, FURNISH_DELAY = 10, ICON = "chair", TITLE = "Chair"),
				list(FURNISH_TYPE = /obj/structure/chair/stool, FURNISH_COST = 8, FURNISH_DELAY = 10, ICON = "stool", TITLE = "Stool"),
				list(FURNISH_TYPE = /obj/structure/table, FURNISH_COST = 16, FURNISH_DELAY = 20, ICON = "table",TITLE = "Table"),
				list(FURNISH_TYPE = /obj/structure/table/glass, FURNISH_COST = 16, FURNISH_DELAY = 20, ICON = "glass_table", TITLE = "Glass Table"),
			),

			//Conveyors & Switches
			"Conveyors" = list(
				list(CONSTRUCTION_MODE = RCD_CONVEYOR, ICON = "conveyor_construct", TITLE = "Conveyor Belt"),
				list(CONSTRUCTION_MODE = RCD_SWITCH, ICON = "switch-off", TITLE = "Conveyor Switch"),
			)
		),

		//2ND ROOT CATEGORY[construction_mode = RCD_AIRLOCK is implied,"icon=closed"]
		"Airlocks" = list( //used to seal/close areas
			//Solid Airlocks[airlock_glass = FALSE is implied,no fill_closed overlay]
			"Solid Airlocks" = list(
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock, TITLE = "Standard", CATEGORY_ICON_STATE = TITLE_ICON),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/public, TITLE = "Public"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/engineering, TITLE = "Engineering"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/atmos, TITLE = "Atmospherics"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/security, TITLE = "Security"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/command, TITLE = "Command"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/medical, TITLE = "Medical"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/research, TITLE = "Research"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/freezer, TITLE = "Freezer"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/virology, TITLE = "Virology"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/mining, TITLE = "Mining"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance, TITLE = "Maintenance"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/external, TITLE = "External"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance/external, TITLE = "External Maintenance"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/hatch, TITLE = "Airtight Hatch"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance_hatch, TITLE = "Maintenance Hatch"),
			),

			//Glass Airlocks[airlock_glass = TRUE is implied,do fill_closed overlay]
			"Glass Airlocks" = list(
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/glass, TITLE = "Standard", CATEGORY_ICON_STATE = TITLE_ICON, CATEGORY_ICON_SUFFIX = "Glass"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/public/glass, TITLE = "Public"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/engineering/glass, TITLE = "Engineering"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/atmos/glass, TITLE = "Atmospherics"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/security/glass, TITLE = "Security"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/command/glass, TITLE = "Command"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/medical/glass, TITLE = "Medical"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/research/glass, TITLE = "Research"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/virology/glass, TITLE = "Virology"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/mining/glass, TITLE = "Mining"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance/glass, TITLE = "Maintenance"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/external/glass, TITLE = "External"),
				list(AIRLOCK_TYPE = /obj/machinery/door/airlock/maintenance/external/glass, TITLE = "External Maintenance"),
			),

			//Window Doors[airlock_glass = TRUE is implied]
			"Windoors" = list(
				list(AIRLOCK_TYPE = /obj/machinery/door/window, ICON = "windoor", TITLE = "Windoor"),
				list(AIRLOCK_TYPE = /obj/machinery/door/window/brigdoor, ICON = "secure_windoor", TITLE = "Secure Windoor"),
			),			
		),

		//3RD CATEGORY Airlock access,empty list cause airlock_electronics UI will be displayed  when this tab is selected
		"Airlock Access" = list()
	)

	///english name for the design to check if it was selected or not
	var/design_title = "Wall/Floor"
	var/design_category = "Structures"
	var/root_category = "Construction"
	var/closed = FALSE
	///owner of this rcd. It can either be an construction console or an player
	var/owner

	var/construction_mode = RCD_FLOORWALL
	var/ranged = FALSE
	var/computer_dir = 1
	var/airlock_type = /obj/machinery/door/airlock
	var/airlock_glass = FALSE // So the floor's rcd_act knows how much ammo to use
	var/window_type = /obj/structure/window/fulltile
	var/window_glass = RCD_WINDOW_NORMAL
	var/window_size = RCD_WINDOW_FULLTILE
	var/furnish_type = /obj/structure/chair
	var/furnish_cost = 8
	var/furnish_delay = 10
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.
	var/delay_mod = 1
	var/canRturf = FALSE //Variable for R walls to deconstruct them
	/// Integrated airlock electronics for setting access to a newly built airlocks
	var/obj/item/electronics/airlock/airlock_electronics

/obj/item/construction/rcd/suicide_act(mob/user)
	construction_mode = RCD_FLOORWALL
	if(!rcd_create(get_turf(user), user))
		return SHAME
	if(isfloorturf(get_turf(user)))
		return SHAME
	user.visible_message(span_suicide("[user] sets the RCD to 'Wall' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide.."))
	return (BRUTELOSS)

/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE
	var/delay = rcd_results["delay"] * delay_mod
	var/obj/effect/constructing_effect/rcd_effect = new(get_turf(A), delay, src.construction_mode)
	var/datum/beam/rcd_beam
	if(checkResource(rcd_results["cost"], user))
		if(!A.Adjacent(owner ? owner : user)) // ranged RCDs create beams
			if(isatom(owner))
				var/atom/owner_atom = owner
				rcd_beam = owner_atom.Beam(A,icon_state="rped_upgrade",time=delay)
			else
				rcd_beam = Beam(A,icon_state="rped_upgrade",time=delay)
		if(do_after(user, delay, (owner ? owner : A)))
			if(checkResource(rcd_results["cost"], user))
				if(A.rcd_act(user, src, rcd_results["mode"]))
					rcd_effect.end_animation()
					useResource(rcd_results["cost"], user)
					activate()
					if(!silent)
						playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
					return TRUE
	if(rcd_beam)
		qdel(rcd_beam)
	qdel(rcd_effect)
	return FALSE

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	airlock_electronics = new(src)
	airlock_electronics.name = "Access Control"
	airlock_electronics.holder = src
	GLOB.rcd_list += src

/obj/item/construction/rcd/Destroy()
	QDEL_NULL(airlock_electronics)
	GLOB.rcd_list -= src
	. = ..()

/obj/item/construction/rcd/ui_host(mob/user)
	return owner || ..()

/obj/item/construction/rcd/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/rcd)
		assets.send(user)
		ui = new(user, src, "RapidConstructionDevice", name)
		ui.open()

/obj/item/construction/rcd/ui_static_data(mob/user)
	return airlock_electronics.ui_static_data(user)

/obj/item/construction/rcd/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/rcd),
	)

/obj/item/construction/rcd/ui_data(mob/user)
	var/list/data = ..()

	//main categories
	data["selected_root"] = root_category
	data["root_categories"] = list()
	for(var/category in root_categories)
		data["root_categories"] += category

	//create the category list
	data["selected_category"] = design_category
	data["selected_design"] = design_title
	data["categories"] = list()

	var/category_icon_state
	var/category_icon_suffix
	for(var/list/sub_category as anything in root_categories[root_category])
		var/list/target_category = root_categories[root_category][sub_category]
		if(target_category.len == 0)
			continue

		//skip category if upgrades were not installed for these
		if(sub_category == "Machines" && !(upgrade & RCD_UPGRADE_FRAMES))
			continue
		if(sub_category == "Furniture" && !(upgrade & RCD_UPGRADE_FURNISHING))
			continue
		if(sub_category == "Conveyors" && !(upgrade & RCD_UPGRADE_CONVEYORS))
			continue
		category_icon_state = ""
		category_icon_suffix = ""

		var/list/designs = list() //initialize all designs under this category
		for(var/i in 1 to target_category.len)
			var/list/design = target_category[i]

			//check for special icon flags
			if(design[CATEGORY_ICON_STATE] != null)
				category_icon_state = design[CATEGORY_ICON_STATE]
			if(design[CATEGORY_ICON_SUFFIX] != null)
				category_icon_suffix = design[CATEGORY_ICON_SUFFIX]

			//get icon or create it from pre defined flags
			var/icon_state
			if(design[ICON] != null)
				icon_state = design[ICON]
			else
				icon_state = category_icon_state
				if(icon_state == TITLE_ICON)
					icon_state = design[TITLE]
			icon_state = "[icon_state][category_icon_suffix]"

			//sanitize them so you dont go insane when icon names contain spaces in them
			icon_state = sanitize_css_class_name(icon_state)

			designs += list(list("design_id" = i, TITLE = design[TITLE], ICON = icon_state))
		data["categories"] += list(list("cat_name" = sub_category, "designs" = designs))

	//merge airlock_electronics ui data with this
	var/list/airlock_data = airlock_electronics.ui_data(user)
	for(var/key in airlock_data)
		data[key] = airlock_data[key]

	return data


/obj/item/construction/rcd/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("root_category")
			var/new_root = params["root_category"]
			if(root_categories[new_root] != null) //is a valid category
				root_category = new_root

		if("design")
			var/category_name = params["category"]
			var/index = params["index"]

			var/list/root = root_categories[root_category]
			if(root == null) //not a valid root
				return TRUE
			var/list/category = root[category_name]
			if(category == null) //not a valid category
				return TRUE
			var/list/design = category[index]
			if(design == null) //not a valid design
				return TRUE

			design_category = category_name
			design_title = design["title"]

			if(category_name == "Structures")
				construction_mode = design[CONSTRUCTION_MODE]
				if(design[WINDOW_TYPE] != null)
					window_type = design[WINDOW_TYPE]
				if(design[WINDOW_GLASS] != null)
					window_glass = design[WINDOW_GLASS]
				if(design[WINDOW_SIZE] != null)
					window_size = design[WINDOW_SIZE]
			else if(category_name == "Machines")
				construction_mode = design[CONSTRUCTION_MODE]
				if(design[COMPUTER_DIR] != null)
					computer_dir = design[COMPUTER_DIR]
			else if(category_name == "Furniture")
				construction_mode = RCD_FURNISHING
				furnish_type = design[FURNISH_TYPE]
				furnish_cost = design[FURNISH_COST]
				furnish_delay = design[FURNISH_DELAY]
			else if(category_name == "Conveyors")
				construction_mode = design[CONSTRUCTION_MODE]

			if(root_category == "Airlocks")
				construction_mode = RCD_AIRLOCK
				airlock_glass = (category_name != "Solid AirLocks")
				airlock_type = design[AIRLOCK_TYPE]
		else
			airlock_electronics.do_action(action, params)

	return TRUE

/obj/item/construction/rcd/attack_self(mob/user)
	. = ..()
	ui_interact(user)

/obj/item/construction/rcd/proc/target_check(atom/A, mob/user) // only returns true for stuff the device can actually work with
	if((isturf(A) && A.density && construction_mode==RCD_DECONSTRUCT) || (isturf(A) && !A.density) || (istype(A, /obj/machinery/door/airlock) && construction_mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/grille) || (istype(A, /obj/structure/window) && construction_mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/girder))
		return TRUE
	else
		return FALSE

/obj/item/construction/rcd/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity) && !(ranged && range_check(A, user)))
		return
	if((upgrade & RCD_UPGRADE_CONVEYORS) && istype(A, /obj/machinery/conveyor_switch))
		var/obj/machinery/conveyor_switch/C = A
		linked_switch_id = C.id
		balloon_alert(user, "linked")
		return
	rcd_create(A, user)

/obj/item/construction/rcd/attackby(obj/item/I, mob/user, params)
	. = ..()
	if((upgrade & RCD_UPGRADE_CONVEYORS) && istype(I, /obj/item/conveyor_switch_construct))
		var/obj/item/conveyor_switch_construct/C = I
		linked_switch_id = C.id
		balloon_alert(user, "linked")

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, PROC_REF(detonate_pulse_explode)), 50)

/obj/item/construction/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/construction/rcd/update_overlays()
	. = ..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		. += "[icon_state]_charge[ratio]"

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/construction/rcd/borg
	no_ammo_message = span_warning("Insufficient charge.")
	desc = "A device used to rapidly build walls and floors."
	banned_upgrades = RCD_UPGRADE_SILO_LINK
	var/energyfactor = 72


/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/syndicate
	icon_state = "ircd"
	item_state = "ircd"
	canRturf = TRUE
	energyfactor = 66

/obj/item/construction/rcd/loaded
	matter = 160

/obj/item/construction/rcd/combat
	name = "industrial RCD"
	icon_state = "ircd"
	item_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE

#undef CONSTRUCTION_MODE
#undef WINDOW_TYPE
#undef WINDOW_GLASS
#undef WINDOW_SIZE
#undef COMPUTER_DIR
#undef FURNISH_TYPE
#undef FURNISH_COST
#undef FURNISH_DELAY
#undef AIRLOCK_TYPE

#undef TITLE
#undef ICON

#undef CATEGORY_ICON_STATE
#undef CATEGORY_ICON_SUFFIX
#undef TITLE_ICON

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = WEIGHT_CLASS_TINY
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(/datum/material/iron=48000, /datum/material/glass=32000)
	var/ammoamt = 160


/obj/item/construction/rcd/combat/admin
	name = "admin RCD"
	max_matter = INFINITY
	matter = INFINITY
	ranged = TRUE
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING


// Ranged RCD


/obj/item/construction/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity. Reload with metal, plasteel, glass or compressed matter cartridges."
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	item_state = "oldrcd"
	has_ammobar = FALSE

/obj/item/construction/rcd/arcd/afterattack(atom/A, mob/user)
	if(!range_check(A,user))
		return
	return ..()

/obj/item/construction/rcd/exosuit
	name = "mounted RCD"
	desc = "You're not supposed to see this!"
	max_matter = 1000
	matter = 0 // starts off empty, load materials into the mech itself
	delay_mod = 0.5
	ranged = TRUE
	has_ammobar = FALSE // don't bother, you can't see it
	item_flags = NO_MAT_REDEMPTION | DROPDEL | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | UNACIDABLE // would be weird if it could somehow be destroyed inside the equipment item

/obj/item/construction/rcd/exosuit/ui_state(mob/user)
	return GLOB.pilot_state

/obj/item/construction/rcd/exosuit/ui_status(mob/user)
	if(!(owner && ismecha(owner)))
		return UI_CLOSE
	var/obj/mecha/gundam = owner
	if(user != gundam.occupant)
		return UI_CLOSE
	if(!gundam.equipment_disabled && gundam.selected == loc)
		return UI_INTERACTIVE
	return UI_UPDATE

/obj/item/construction/rcd/exosuit/mime
	name = "silenced mounted RCD"
	silent = TRUE

// RAPID LIGHTING DEVICE

#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/obj/item/construction/rld
	name = "Rapid Lighting Device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with metal, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	slot_flags = ITEM_SLOT_BELT
	///it does not make sense why any of these should be installed
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING

	var/matter_divisor = 35
	var/mode = LIGHT_MODE

	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

	///reference to thr original icons
	var/list/original_options = list(
		"Color Pick" = icon(icon = 'icons/mob/radial.dmi', icon_state = "omni"),
		"Glow Stick" = icon(icon = 'icons/obj/lighting.dmi', icon_state = "glowstick"),
		"Deconstruct" = icon(icon = 'icons/obj/tools.dmi', icon_state = "wrench"),
		"Light Fixture" = icon(icon = 'icons/obj/lighting.dmi', icon_state = "ltube"),
	)
	///will contain the original icons modified with the color choice
	var/list/display_options = list()

/obj/item/construction/rld/Initialize(mapload)
	. = ..()
	for(var/option in original_options)
		display_options[option] = icon(original_options[option])

/obj/item/construction/rld/update_icon_state()
	. = ..()
	icon_state = "rld-[round(matter/35)]"

/obj/item/construction/rld/attack_self(mob/user)
	. = ..()

	if((upgrade & RCD_UPGRADE_SILO_LINK) && display_options["Silo Link"] == null) //silo upgrade instaled but option was not updated then update it just one
		display_options["Silo Link"] = icon(icon = 'icons/obj/mining.dmi', icon_state = "silo")
	var/choice = show_radial_menu(user, src, display_options, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	if(!choice)
		return

	switch(choice)
		if("Light Fixture")
			mode = LIGHT_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Permanent Light Construction'."))
		if("Glow Stick")
			mode = GLOW_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Light Launcher'."))
		if("Color Pick")
			var/new_choice = input(user,"","Choose Color",color_choice) as color
			if(new_choice == null)
				return

			var/list/new_rgb = ReadRGB(new_choice)
			for(var/option in original_options)
				if(option == "Color Pick" || option == "Deconstruct" || option == "Silo Link")
					continue
				var/icon/icon = icon(original_options[option])
				icon.SetIntensity(new_rgb[1]/255, new_rgb[2]/255, new_rgb[3]/255) //apply new scale
				display_options[option] = icon

			color_choice = new_choice
		if("Deconstruct")
			mode = REMOVE_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Deconstruct'."))
		else
			ui_act("toggle_silo", list())

/obj/item/construction/rld/proc/checkdupes(target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/construction/rld/afterattack(atom/A, mob/user)
	..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, span_notice("You start deconstructing [A]..."))
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					if(!silent)
						playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
					if(do_after(user, decondelay, A))
						if(!useResource(deconcost, user))
							return FALSE
						activate()
						qdel(A)
						return TRUE
				return FALSE
		if(LIGHT_MODE)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, span_notice("You start building a wall light..."))
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					if(!silent)
						playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
						playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, FALSE)
					if(do_after(user, floordelay, A))
						if(!istype(W))
							return FALSE
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in GLOB.cardinals)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if(start.can_atmos_pass(C) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, span_warning("Valid target not found..."))
							if(!silent)
								playsound(src.loc, 'sound/misc/compiler-failure.ogg', 30, TRUE)
							return FALSE
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = cheap_hypotenuse(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return FALSE
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.setDir(align)
						L.color = color_choice
						L.light_color = L.color
						return TRUE
				return FALSE

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, span_notice("You start building a floor light..."))
					user.Beam(A,icon_state="light_beam",time=15)
					if(!silent)
						playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
						playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, TRUE)
					if(do_after(user, floordelay, A))
						if(!istype(F))
							return 0
						if(!useResource(floorcost, user))
							return 0
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.light_color = FL.color
						return TRUE
				return FALSE

		if(GLOW_MODE)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, span_notice("You fire a glowstick!"))
				var/obj/item/flashlight/glowstick/G  = new /obj/item/flashlight/glowstick(start)
				G.color = color_choice
				G.light_color = G.color
				G.throw_at(A, 9, 3, user)
				G.light_on = TRUE
				G.update_brightness()
				return TRUE
			return FALSE
/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "It contains the design for machine frames and computer frames."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/silo_link
	desc = "It contains direct silo connection RCD upgrade."
	upgrade = RCD_UPGRADE_SILO_LINK

/obj/item/rcd_upgrade/furnishing
	desc = "It contains the design for chairs, stools, tables, and glass tables."
	upgrade = RCD_UPGRADE_FURNISHING

/obj/item/rcd_upgrade/conveyor
	desc = "The disk warns against building an endless conveyor trap, but we know what you're gonna do."
	upgrade = RCD_UPGRADE_CONVEYORS

/datum/action/item_action/pick_color
	name = "Choose A Color"
	
#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE
