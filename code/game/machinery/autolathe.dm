#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/autolathe
	layer = BELOW_OBJ_LAYER

	var/operating = FALSE
	var/list/L = list()
	var/list/LL = list()
	var/hacked = FALSE
	var/disabled = 0
	var/shocked = FALSE
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/prod_coeff = 1
	var/datum/techweb/stored_research
	var/base_price = 25
	var/hacked_price = 50
	var/datum/research/files
	var/search
	var/datum/material_container/materials
	var/queue_max_len = 12
	var/processing_queue = FALSE
	var/datum/design/item_beingbuilt
	var/datum/design/request
	var/list/being_built = list()
	var/list/autoqueue = list()
	var/processing_line
	var/printdirection = 0
	var/queuelength = 0
	var/list/categories = list("Tools","Electronics","Construction","T-Comm","Security","Machinery","Medical","Miscellaneous","Dinnerware","Imported", "Search")

/obj/machinery/autolathe/Initialize()
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass), 0, TRUE, null, null, CALLBACK(src, .proc/AfterMaterialInsert))
	. = ..()

	wires = new /datum/wires/autolathe(src)
	stored_research = new /datum/techweb/specialized/autounlocking/autolathe
	request = list()

/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if(shocked && !(stat & NOPOWER))
		shock(user,50)
	if(!ui)
		ui = new(user, src, "Autolathe", name)
		ui.open()

/obj/machinery/autolathe/proc/wallcheck(direction) //Check for nasty walls and update ui
	if(iswallturf(get_step(src,(direction))))
		return TRUE
	else
		return FALSE

/obj/machinery/autolathe/ui_data(mob/user) // All the data the ui will need
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	data["total_amount"] = materials.total_amount
	data["max_amount"] = materials.max_amount
	data["metal_amount"] = materials.get_material_amount(/datum/material/iron)
	data["glass_amount"] = materials.get_material_amount(/datum/material/glass)
	data["rightwall"] = wallcheck(4) // Wall data for ui
	data["leftwall"] = wallcheck(8)
	data["abovewall"] = wallcheck(1)
	data["belowwall"] = wallcheck(2)
	processing_line = being_built.len ? get_processing_line() : null
	data["processing"] = processing_line
	data["printdir"] = printdirection
	data["isprocessing"] = processing_queue
	data["queuelength"] = queuelength
	data["categories"] = categories
	if(istype(autoqueue) && autoqueue.len)
		var/list/uidata = list()
		var/index = 1
		for(var/list/L in autoqueue)
			var/datum/design/D = L[1]
			uidata[++uidata.len] = list("name" = initial(D.name), "multiplier" = L[2], "index" = index)
			index++
		data["queue"] = uidata
	else
		data["queue"] = list()

	return data

/obj/machinery/autolathe/ui_static_data(mob/user)
	var/list/data = list()
	var/list/designs = list()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		var/list/design = list()
		design["name"] = D.name
		design["id"] = D.id
		design["disabled"] = disabled || !can_build(D)
		design["category"] = D.category
		var/max_multiplier_list = list()
		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier
			for(var/datum/material/mat in D.materials)
				max_multiplier = min(D.maxstack, round(materials.get_material_amount(mat)/D.materials[mat]))
			if (max_multiplier > 10 && !disabled)
				max_multiplier_list += "10"
			if (max_multiplier > 25 && !disabled)
				max_multiplier_list += "25"
			if(max_multiplier > 0 && !disabled)
				max_multiplier_list += max_multiplier
		else
			if(can_build(D))
				max_multiplier_list += "5"
				max_multiplier_list += "10"
		design["max_multiplier"] = max_multiplier_list
		design["materials_metal"] = get_design_cost_metal(D)
		design["materials_glass"] = get_design_cost_glass(D)
		designs += list(design)
	data["designs"] = designs
	return data
	
/obj/machinery/autolathe/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("make") // Lets try make the item supplied via the UI
			request = stored_research.isDesignResearchedID(params["item_id"])
			if(!request)
				return
			var/multiplier = text2num(params["multiplier"])
			multiplier = clamp(multiplier,1,50)
			if((autoqueue.len + 1) < queue_max_len)
				add_to_queue(request, multiplier) // Add item to queue for processing
			else
				to_chat(usr, span_warning("The autolathe queue is full!"))
		if("eject")
			request = stored_research.isDesignResearchedID(params["item_id"])
			if(processing_queue)
				to_chat(usr, span_warning("The autolathe queue is processing, please stop before ejecting material"))
			if(!request)
				return
			var/multiplier = text2num(params["multiplier"])
			multiplier = clamp(multiplier,1,50)
			make_item(request, multiplier)
			processing_queue = FALSE

		if("process_queue")   // Processing queue flag triggers the queue
			if(processing_queue)
				processing_queue = FALSE
				return
			processing_queue = TRUE
			process_queue()

		if("remove_from_queue")
			var/index = text2num(params["index"])
			if(isnum(index) && ISINRANGE(index, 1, autoqueue.len))
				remove_from_queue(index)

		if("queue_move")  // Moves items up and down the list
			var/index = text2num(params["index"])
			var/new_index = index + text2num(params["queue_move"])
			if(isnum(index) && isnum(new_index))
				if(ISINRANGE(new_index, 1, autoqueue.len))
					autoqueue.Swap(index,new_index)

		if("clear_queue")
			queuelength = 0
			processing_queue = FALSE
			autoqueue = list()
			processing_line = null

		if("printdir")
			printdirection = text2num(params["direction"])
			if(printdirection > 8)  // Simple Sanity Check
				printdirection = 0

	update_icon()

/obj/machinery/autolathe/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

/obj/machinery/autolathe/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load \the [O] in \the [src]...",
			"You begin to load a design from \the [O]...",
			"You hear the chatter of a floppy drive.")
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 1.5 SECONDS, src))
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
			update_static_data(user)
		return TRUE

	return ..()

/obj/machinery/autolathe/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		switch(id_inserted)
			if (/datum/material/iron)
				flick("autolathe_o",src)//plays metal insertion animation
			else
				flick("autolathe_r",src)//plays glass insertion animation
		use_power(min(1000, amount_inserted / 100))

/obj/machinery/autolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating * 75000
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = T
	T=1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/autolathe/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[prod_coeff*100]%</b>.<span>"

/obj/machinery/autolathe/proc/materials_printout()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/dat = "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = mat_id
		var/mineral_amount = materials.materials[mat_id]
		if(mineral_amount > 0)
			dat += "<b>[M.name] amount:</b> [mineral_amount] cm<sup>3</sup><br>"
	return dat

/obj/machinery/autolathe/proc/can_build(datum/design/D, amount = 1)
	if(D.make_reagents.len)
		return FALSE
	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)

	var/list/required_materials = list()

	for(var/i in D.materials)
		required_materials[i] = D.materials[i] * coeff * amount

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(wallcheck(printdirection))
		say("Output blocked, please remove obstruction.")
		return FALSE
	return materials.has_materials(required_materials)

/obj/machinery/autolathe/proc/get_design_cost_metal(datum/design/D)
	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)
	var/dat
	if(D.materials[/datum/material/iron])
		dat = D.materials[/datum/material/iron] * coeff
	else
		dat = 0
	return dat

/obj/machinery/autolathe/proc/get_design_cost_glass(datum/design/D)
	var/coeff = (ispath(D.build_path, /obj/item/stack) ? 1 : prod_coeff)
	var/dat
	if(D.materials[/datum/material/glass])
		dat = D.materials[/datum/material/glass] * coeff
	else
		dat = 0
	return dat

/obj/machinery/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/autolathe/proc/adjust_hacked(state)
	hacked = state
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)

/obj/machinery/autolathe/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)

//Called when the object is constructed by an autolathe
//Has a reference to the autolathe so you can do !!FUN!! things with hacked lathes
/obj/item/proc/autolathe_crafted(obj/machinery/autolathe/A)
	return

/obj/machinery/autolathe/proc/make_item(datum/design/D, multiplier)
	var/is_stack = ispath(D.build_path, /obj/item/stack)
	var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
	var/total_amount = 0
	for(var/MAT in D.materials)
		total_amount += D.materials[MAT]
	var/power = max(2000, (total_amount)*multiplier/5) //Change this to use all materials
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if (!materials)
		say("No access to material storage, please contact the quartermaster.")
		return FALSE
	if(can_build(D, multiplier))  // Check if we can build if not, return
		var/list/materials_used = list()
		var/list/picked_materials
		var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.
		for(var/MAT in D.materials)
			var/datum/material/used_material = MAT
			var/amount_needed = D.materials[MAT] * coeff * multiplier
			if(istext(used_material)) //This means its a category
				var/list/list_to_show = list()
				for(var/i in SSmaterials.materials_by_category[used_material])
					if(materials.materials[i])
						list_to_show += i

				used_material = input("Choose [used_material]", "Custom Material") as null|anything in list_to_show
				if(!used_material)
					return //Didn't pick any material, so you can't build shit either.
				custom_materials[used_material] += amount_needed

			materials_used[used_material] = amount_needed

		if(materials.has_materials(materials_used))
			use_power(power)
			materials.use_materials(materials_used)
			being_built = list(D, multiplier)
			desc = "It's building \a [initial(D.name)]."
			icon_state = "autolathe_n"
			var/time = is_stack ? 32 : 32 * coeff * multiplier
			sleep(time)
			if(wallcheck(printdirection))
				printdirection = 0
			var/atom/A = drop_location()
			var/location = get_step(src,(printdirection))
			if(printdirection)
				A = location
			if(is_stack) // If its a stack we need to define it as so
				var/obj/item/stack/N = new D.build_path(A, multiplier)
				N.update_icon()
				N.autolathe_crafted(src)
			else
				for(var/i=1, i<=multiplier, i++)
					var/obj/item/new_item = new D.build_path(A)
					new_item.materials = new_item.materials.Copy()
					for(var/mat in materials_used)
						new_item.materials[mat] = materials_used[mat] / multiplier
					new_item.autolathe_crafted(src)
					if(picked_materials?.len)
						new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount
			item_beingbuilt = null
			icon_state = "autolathe"
			desc = initial(desc)
			return TRUE
	else
		say("Not enough resources. Queue processing stopped.")
		return FALSE

/obj/machinery/autolathe/proc/add_to_queue(D, multiplier)
	queuelength++
	if(!istype(autoqueue))
		autoqueue = list()
	if(D)
		autoqueue.Add(list(list(D,multiplier)))
	return autoqueue.len

/obj/machinery/autolathe/proc/remove_from_queue(index)
	queuelength--
	if(!isnum(index) || !istype(autoqueue) || (index<1 || index>autoqueue.len))
		return FALSE
	autoqueue.Cut(index,++index)
	return TRUE

/obj/machinery/autolathe/proc/process_queue() //Process the queue from the autoqueue list. Will add temp metal and glass later.
	var/datum/design/D = autoqueue[1][1]
	var/multiplier = autoqueue[1][2]
	if(!multiplier || !isnum(multiplier) || isnan(multiplier))
		message_admins("[ADMIN_FULLMONTY(usr)] is attempting to create NAN stacks of items")
		return
	if(!processing_queue)
		say("Queue processing halted.")
		return
	if(stat&(NOPOWER|BROKEN) || panel_open)
		processing_queue = FALSE
		return
	if(!can_build(D,multiplier))
		say("Not enough resources. Queue processing terminated.")
		processing_queue = FALSE
		return
	remove_from_queue(1)
	make_item(D,multiplier)
	if(autoqueue.len)
		process_queue()
	else
		being_built = new /list()
		say("Queue processing finished successfully.")
		processing_queue = FALSE

/obj/machinery/autolathe/proc/get_processing_line()  //Gets processing line for whats building for UI
	var/datum/design/D = being_built[1]
	var/multiplier = being_built[2]
	var/is_stack = (multiplier>1)
	var/output = "[initial(D.name)][is_stack?" (x[multiplier])":null]"
	return output
