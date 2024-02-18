/datum/tool_switcher_program
	var/name = "Program"
	var/list/tools_list = list() // list of tool typepaths to use
	var/current_index = 1
	var/can_edit = TRUE

/datum/tool_switcher_program/proc/update_tools_list(I)
	return

/datum/tool_switcher_program/default
	name = "None"
	can_edit = FALSE

/datum/tool_switcher_program/default/update_tools_list(obj/item/I)
	tools_list.Cut()
	for(var/obj/item/T in I)
		tools_list += T.type
	I.updateUsrDialog()

/obj/item/storage/belt/tool_switcher
	name = "programmable tool switcher"
	desc = "An advanced programmable device capable of quickly swapping to the correct tool for performing repetitive tasks quickly."
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "tool_switcher"
	item_state = null
	actions_types = list(/datum/action/item_action/tool_switcher_config)
	var/selected_tool_type = null
	var/list/programs = list()
	var/datum/tool_switcher_program/current_program
	var/obj/item/current_tool
	var/datum/effect_system/spark_spread/spark_system
	// struff you don't want to use the tool on if you click
	var/static/list/default_use_objs = typecacheof(list(
		/obj/item/storage,
		/obj/structure/table,
		/obj/structure/rack,
		/obj/machinery/disposal/bin,

	))

/obj/item/storage/belt/tool_switcher/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/static/list/can_hold = typecacheof(list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/stack/cable_coil,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		))
	STR.can_hold = can_hold
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	programs += new /datum/tool_switcher_program/default
	for(var/I in 1 to 3)
		var/datum/tool_switcher_program/program = new
		program.name = "Program #[I]"
		programs += program
	current_program = programs[1]

/obj/item/storage/belt/tool_switcher/Destroy()
	. = ..()
	qdel(spark_system)
	spark_system = null

/obj/item/storage/belt/tool_switcher/proc/find_current_tool()
	if(!current_program || !current_program.current_index || current_program.current_index > current_program.tools_list.len || current_program.current_index < 1)
		return null
	return locate(current_program.tools_list[current_program.current_index]) in src

/obj/item/storage/belt/tool_switcher/proc/check_tool()
	var/obj/item/T = find_current_tool()
	if(T == current_tool)
		return
	if(istype(T, /obj/item/weldingtool))
		var/obj/item/weldingtool/W = T
		if(!W.welding)
			W.switched_on()
	else if(istype(current_tool, /obj/item/weldingtool) && current_tool.loc == src) // only turn off if it's still in the tool switcher
		var/obj/item/weldingtool/W = current_tool
		if(W.welding)
			W.switched_on() // switched_off() doesn't make any sounds
	if(!T)
		name = initial(name)
		force = initial(force)
		item_state = initial(item_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
		tool_behaviour = initial(tool_behaviour)
		toolspeed = initial(toolspeed)
	else
		name = "[initial(name)] ([T.name])"
		force = T.force
		item_state = T.item_state
		lefthand_file = T.lefthand_file
		righthand_file = T.righthand_file
		tool_behaviour = T.tool_behaviour
		toolspeed = T.toolspeed
	cut_overlays()
	if(T)
		var/mutable_appearance/overlay = new(T)
		overlay.layer = FLOAT_LAYER
		add_overlay(overlay)
	current_tool = T
	if(istype(loc, /mob))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/storage/belt/tool_switcher/proc/switch_tool_index(I)
	if(!current_program || I > current_program.tools_list.len || I < 1)
		return FALSE
	current_program.current_index = I
	check_tool()
	spark_system.start()

/obj/item/storage/belt/tool_switcher/ui_action_click(mob/user)
	interact(user)

/obj/item/storage/belt/tool_switcher/ui_interact(mob/living/user)
	. = ..()
	var/dat = "<b>Programs:</b> <div>"
	for(var/I in 1 to programs.len)
		var/datum/tool_switcher_program/program = programs[I]
		dat += "<a href='?src=[REF(src)];change_program=[I]' class='[program == current_program ? "linkOn" : ""]'>[program.name]</a>"
	dat += "</div><hr>"
	if(current_program)
		dat += "<table>"
		for(var/I in 1 to current_program.tools_list.len)
			var/obj/item/tool_type = current_program.tools_list[I]
			var/no_tool = (locate(tool_type) in src) == null
			dat += "<tr><td><a href='?src=[REF(src)];change_tool=[I]' style='[no_tool ? "color:red" : ""]' class='[I == current_program.current_index ? "linkOn" : ""]'>[initial(tool_type.name)]</a></td>"
			dat += "<td><a href='?src=[REF(src)];remove_tool=[I]'>X</a></td>"
			if(current_program.can_edit)
				dat += "<td><a href='?src=[REF(src)];move_tool=[I];move_tool_dir=1' class='[I == current_program.tools_list.len ? "linkOff" : ""]'>&#8595</a></td>"
				dat += "<td><a href='?src=[REF(src)];move_tool=[I];move_tool_dir=0' class='[I == 1 ? "linkOff" : ""]'>&#8593</a></td>"
			dat += "</tr>"
		dat += "</table>"
		if(current_program.can_edit)
			dat += "<div><a href='?src=[REF(src)];add_tool=1'>Add to Sequence</a>"
	var/datum/browser/popup = new(user, "tool_switcher", name, 350, 500)
	popup.set_content(dat)
	popup.open()
	user.set_machine(src)

/obj/item/storage/belt/tool_switcher/Topic(href, href_list)
	if(..())
		return
	if(!usr || !usr.canUseTopic(src) || QDELETED(src))
		return
	if(href_list["change_program"])
		var/idx = text2num(href_list["change_program"])
		if(idx > programs.len || idx < 1)
			return
		current_program = programs[idx]
		switch_tool_index(1)
	if(href_list["change_tool"])
		switch_tool_index(text2num(href_list["change_tool"]))
	if(href_list["move_tool"])
		var/idx = text2num(href_list["move_tool"])
		var/tdir = text2num(href_list["move_tool_dir"])
		tdir = tdir ? 1 : -1
		if(!current_program || (tdir == -1 && idx == 1) || (tdir == 1 && idx == current_program.tools_list.len))
			return
		current_program.tools_list.Swap(idx, idx + tdir)
		if(current_program.current_index == idx)
			switch_tool_index(idx + tdir)
		else if(current_program.current_index == idx + tdir)
			switch_tool_index(idx)
	if(href_list["add_tool"])
		if(!current_program || !current_program.can_edit)
			return
		var/list/tools_map = list()
		for(var/obj/item/I in src)
			tools_map[initial(I.name)] = I.type
		var/tool_type = input(usr, "Select a tool", name) as null|anything in tools_map
		if(!src || !usr || !usr.canUseTopic(src) || QDELETED(src) || tool_type == null || !current_program || !current_program.can_edit)
			return
		current_program.tools_list += tools_map[tool_type]
	if(href_list["remove_tool"])
		var/idx = text2num(href_list["remove_tool"])
		if(!current_program || idx > current_program.tools_list.len || idx < 1)
			return
		current_program.tools_list.Cut(idx, idx+1)

	updateUsrDialog()

/obj/item/storage/belt/tool_switcher/attack_self(mob/user)
	if(!current_program)
		return
	var/new_index = current_program.current_index + 1
	if(new_index > current_program.tools_list.len)
		new_index = 1
	switch_tool_index(new_index)
	updateUsrDialog()

/obj/item/storage/belt/tool_switcher/melee_attack_chain(mob/user, atom/target)
	var/obj/item/tool = find_current_tool()
	if(tool)
		if(tool_behaviour && (target.tool_act(user, src, tool_behaviour) & TOOL_ACT_MELEE_CHAIN_BLOCKING))
			return TRUE
		if(is_type_in_typecache(target, default_use_objs))
			. = ..()
			return
		. = tool.melee_attack_chain(arglist(args)) // copy the tool's actions
		// make sure the tool didn't get removed
		if(!QDELETED(tool) && tool.loc != src)
			var/datum/component/storage/STR = GetComponent(/datum/component/storage)
			STR.remove_from_storage(tool, tool.loc) // update the shizz
	else
		. = ..()

/obj/item/storage/belt/tool_switcher/updateUsrDialog() // because it fucking doesn't work
	// the absolute disaster that is tg's datum/browser makes me want to engage in an involuntary personal protein spill
	var/is_in_use = FALSE
	if((obj_flags & IN_USE) && !(obj_flags & USES_TGUI))
		var/mob/M = loc
		if ((istype(M) && M.client && M.machine == src))
			is_in_use = TRUE
			ui_interact(M)
		if (is_in_use)
			obj_flags |= IN_USE
		else
			obj_flags &= ~IN_USE


/obj/item/storage/belt/tool_switcher/Entered()
	. = ..()
	if(current_program)
		current_program.update_tools_list(src)
	check_tool(loc)

/obj/item/storage/belt/tool_switcher/Exited()
	. = ..()
	if(current_program)
		current_program.update_tools_list(src)
	check_tool(loc)
