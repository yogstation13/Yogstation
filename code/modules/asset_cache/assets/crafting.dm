/// Representative icons for the contents of each crafting recipe.
/datum/asset/spritesheet/crafting
	name = "crafting"

/datum/asset/spritesheet/crafting/create_spritesheets()
	var/id = 1
	for(var/atom in GLOB.crafting_recipes_atoms)
		add_atom_icon(atom, id++)
	add_tool_icons()

/datum/asset/spritesheet/crafting/cooking
	name = "cooking"

/datum/asset/spritesheet/crafting/cooking/create_spritesheets()
	var/id = 1
	for(var/atom in GLOB.cooking_recipes_atoms)
		add_atom_icon(atom, id++)

/datum/asset/spritesheet/crafting/proc/add_atom_icon(ingredient_typepath, id)
	var/icon_file
	var/icon_state
	var/obj/preview_item = ingredient_typepath
	if(ispath(ingredient_typepath, /datum/reagent))
		var/datum/reagent/reagent = ingredient_typepath
		preview_item = initial(reagent.default_container)

	icon_file ||= initial(preview_item.icon_preview) || initial(preview_item.icon)
	icon_state ||= initial(preview_item.icon_state_preview) || initial(preview_item.icon_state)

	#ifdef UNIT_TESTS
	if(!icon_exists(icon_file, icon_state, scream = TRUE))
		return
	#endif

	Insert("a[id]", icon(icon_file, icon_state, SOUTH))

///Adds tool icons to the spritesheet
/datum/asset/spritesheet/crafting/proc/add_tool_icons()
	var/list/tool_icons = list(
		TOOL_CROWBAR = icon('icons/obj/tools.dmi', "crowbar"),
		TOOL_MULTITOOL = icon('icons/obj/device.dmi', "multitool"),
		TOOL_SCREWDRIVER = icon('icons/obj/tools.dmi', "screwdriver_map"),
		TOOL_WIRECUTTER = icon('icons/obj/tools.dmi', "cutters_map"),
		TOOL_WRENCH = icon('icons/obj/tools.dmi', "wrench"),
		TOOL_WELDER = icon('icons/obj/tools.dmi', "welder"),
		TOOL_ANALYZER = icon('icons/obj/device.dmi', "analyzer"),
		TOOL_MINING = icon('icons/obj/mining.dmi', "minipick"),
		TOOL_SHOVEL = icon('icons/obj/mining.dmi', "spade"),
		TOOL_RETRACTOR = icon('icons/obj/surgery.dmi', "retractor"),
		TOOL_HEMOSTAT = icon('icons/obj/surgery.dmi', "hemostat"),
		TOOL_CAUTERY = icon('icons/obj/surgery.dmi', "cautery"),
		TOOL_DRILL = icon('icons/obj/surgery.dmi', "drill"),
		TOOL_SCALPEL = icon('icons/obj/surgery.dmi', "scalpel"),
		TOOL_SAW = icon('icons/obj/surgery.dmi', "saw"),
		TOOL_BONESET = icon('icons/obj/surgery.dmi', "bonesetter"),
	)

	for(var/tool in tool_icons)
		Insert(replacetext(tool, " ", ""), tool_icons[tool])
