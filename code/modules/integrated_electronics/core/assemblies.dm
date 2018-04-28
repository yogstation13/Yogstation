#define IC_MAX_SIZE_BASE		25
#define IC_COMPLEXITY_BASE		75

<<<<<<< HEAD
/obj/item/electronic_assembly
=======
/obj/item/device/electronic_assembly
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "electronic assembly"
	obj_flags = CAN_BE_HIT
	desc = "It's a case, for building small electronics with."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small"
	flags_1 = NOBLUDGEON_1
	materials = list()		// To be filled later
	var/list/assembly_components = list()
	var/max_components = IC_MAX_SIZE_BASE
	var/max_complexity = IC_COMPLEXITY_BASE
	var/opened = FALSE
	var/obj/item/stock_parts/cell/battery // Internal cell which most circuits need to work.
	var/cell_type = /obj/item/stock_parts/cell
	var/can_charge = TRUE //Can it be charged in a recharger?
	var/charge_sections = 4
	var/charge_tick = FALSE
	var/charge_delay = 4
	var/use_cyborg_cell = TRUE
	var/ext_next_use = 0
	var/atom/collw
<<<<<<< HEAD
	var/obj/item/card/id/access_card
=======
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	var/allowed_circuit_action_flags = IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE //which circuit flags are allowed
	var/combat_circuits = 0 //number of combat cicuits in the assembly, used for diagnostic hud
	var/long_range_circuits = 0 //number of long range cicuits in the assembly, used for diagnostic hud
	var/prefered_hud_icon = "hudstat"		// Used by the AR circuit to change the hud icon.
	hud_possible = list(DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_TRACK_HUD, DIAG_CIRCUIT_HUD) //diagnostic hud overlays
	max_integrity = 50
	pass_flags = 0
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	anchored = FALSE
	var/can_anchor = TRUE
	var/detail_color = COLOR_ASSEMBLY_BLACK
	var/list/color_whitelist = list( //This is just for checking that hacked colors aren't in the save data.
		COLOR_ASSEMBLY_BLACK,
		COLOR_FLOORTILE_GRAY,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

<<<<<<< HEAD
/obj/item/electronic_assembly/examine(mob/user)
=======
/obj/item/device/electronic_assembly/examine(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	if(can_anchor)
		to_chat(user, "<span class='notice'>The anchoring bolts [anchored ? "are" : "can be"] <b>wrenched</b> in place and the maintainence panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")
	else
		to_chat(user, "<span class='notice'>The maintainence panel [opened ? "can be" : "is"] <b>screwed</b> in place.</span>")

<<<<<<< HEAD
/obj/item/electronic_assembly/proc/check_interactivity(mob/user)
	return user.canUseTopic(src, BE_CLOSE)

/obj/item/electronic_assembly/Collide(atom/AM)
	collw = AM
	.=..()
	if((istype(collw, /obj/machinery/door/airlock) ||  istype(collw, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = collw
		if(D.check_access(access_card))
			D.open()

/obj/item/electronic_assembly/Initialize()
=======
/obj/item/device/electronic_assembly/proc/check_interactivity(mob/user)
	return user.canUseTopic(src, BE_CLOSE)

/obj/item/device/electronic_assembly/Collide(atom/AM)
	collw = AM
	.=..()

/obj/item/device/electronic_assembly/Initialize()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	.=..()
	START_PROCESSING(SScircuit, src)
	materials[MAT_METAL] = round((max_complexity + max_components) / 4) * SScircuit.cost_multiplier

	//sets up diagnostic hud view
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_circuithealth()
	diag_hud_set_circuitcell()
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()

<<<<<<< HEAD
	access_card = new /obj/item/card/id(src)

/obj/item/electronic_assembly/Destroy()
	STOP_PROCESSING(SScircuit, src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	QDEL_NULL(access_card)
	return ..()

/obj/item/electronic_assembly/process()
=======
/obj/item/device/electronic_assembly/Destroy()
	STOP_PROCESSING(SScircuit, src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	return ..()

/obj/item/device/electronic_assembly/process()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	handle_idle_power()
	check_pulling()

	//updates diagnostic hud
	diag_hud_set_circuithealth()
	diag_hud_set_circuitcell()

<<<<<<< HEAD
/obj/item/electronic_assembly/proc/handle_idle_power()
=======
/obj/item/device/electronic_assembly/proc/handle_idle_power()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	// First we generate power.
	for(var/obj/item/integrated_circuit/passive/power/P in assembly_components)
		P.make_energy()

	// Now spend it.
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		if(IC.power_draw_idle)
			if(!draw_power(IC.power_draw_idle))
				IC.power_fail()

<<<<<<< HEAD
/obj/item/electronic_assembly/interact(mob/user)
	ui_interact(user)

/obj/item/electronic_assembly/ui_interact(mob/user)
=======
/obj/item/device/electronic_assembly/interact(mob/user)
	ui_interact(user)

/obj/item/device/electronic_assembly/ui_interact(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	if(!check_interactivity(user))
		return

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()
	var/HTML = ""

	HTML += "<html><head><title>[name]</title></head><body>"

	HTML += "<a href='?src=[REF(src)]'>\[Refresh\]</a>  |  <a href='?src=[REF(src)];rename=1'>\[Rename\]</a><br>"
	HTML += "[total_part_size]/[max_components] ([round((total_part_size / max_components) * 100, 0.1)]%) space taken up in the assembly.<br>"
	HTML += "[total_complexity]/[max_complexity] ([round((total_complexity / max_complexity) * 100, 0.1)]%) maximum complexity.<br>"
	if(battery)
		HTML += "[round(battery.charge, 0.1)]/[battery.maxcharge] ([round(battery.percent(), 0.1)]%) cell charge. <a href='?src=[REF(src)];remove_cell=1'>\[Remove\]</a>"
	else
		HTML += "<span class='danger'>No power cell detected!</span>"
	HTML += "<br><br>"



	HTML += "Components:"

	var/builtin_components = ""

	for(var/c in assembly_components)
		var/obj/item/integrated_circuit/circuit = c
		if(!circuit.removable)
<<<<<<< HEAD
			builtin_components += "<a href='?src=[REF(circuit)];rename=1;return=1'>\[R\]</a> | "
			builtin_components += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a>"
=======
			builtin_components += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a> | "
			builtin_components += "<a href='?src=[REF(circuit)];rename=1;return=1'>\[Rename\]</a> | "
			builtin_components += "<a href='?src=[REF(circuit)];scan=1;return=1'>\[Copy Ref\]</a>"
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
			builtin_components += "<br>"

	// Put removable circuits (if any) in separate categories from non-removable
	if(builtin_components)
		HTML += "<hr>"
		HTML += "Built in:<br>"
		HTML += builtin_components
		HTML += "<hr>"
		HTML += "Removable:"

	HTML += "<br>"

	for(var/c in assembly_components)
		var/obj/item/integrated_circuit/circuit = c
		if(circuit.removable)
<<<<<<< HEAD
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];up=1' style='text-decoration:none;'>&#8593;</a> "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];down=1' style='text-decoration:none;'>&#8595;</a>  "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];top=1' style='text-decoration:none;'>&#10514;</a> "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];bottom=1' style='text-decoration:none;'>&#10515;</a> | "
			HTML += "<a href='?src=[REF(circuit)];component=[REF(circuit)];rename=1;return=1'>\[R\]</a> | "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];remove=1'>\[-\]</a> | "
			HTML += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a>"
=======
			HTML += "<a href='?src=[REF(circuit)]'>[circuit.displayed_name]</a> | "
			HTML += "<a href='?src=[REF(circuit)];rename=1;return=1'>\[Rename\]</a> | "
			HTML += "<a href='?src=[REF(circuit)];scan=1;return=1'>\[Copy Ref\]</a> | "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];remove=1'>\[Remove\]</a> | "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];up=1' style='text-decoration:none;'>&#8593;</a> "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];down=1' style='text-decoration:none;'>&#8595;</a>  "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];top=1' style='text-decoration:none;'>&#10514;</a> "
			HTML += "<a href='?src=[REF(src)];component=[REF(circuit)];bottom=1' style='text-decoration:none;'>&#10515;</a>"
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
			HTML += "<br>"

	HTML += "</body></html>"
	user << browse(HTML, "window=assembly-[REF(src)];size=655x350;border=1;can_resize=1;can_close=1;can_minimize=1")

<<<<<<< HEAD
/obj/item/electronic_assembly/Topic(href, href_list)
=======
/obj/item/device/electronic_assembly/Topic(href, href_list)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(..())
		return 1

	if(href_list["rename"])
		rename(usr)

	if(href_list["remove_cell"])
		if(!battery)
			to_chat(usr, "<span class='warning'>There's no power cell to remove from \the [src].</span>")
		else
			battery.forceMove(drop_location())
			playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
			to_chat(usr, "<span class='notice'>You pull \the [battery] out of \the [src]'s power supplier.</span>")
			battery = null
			diag_hud_set_circuitstat() //update diagnostic hud

	if(href_list["component"])
		var/obj/item/integrated_circuit/component = locate(href_list["component"]) in assembly_components
		if(component)
			// Builtin components are not supposed to be removed or rearranged
			if(!component.removable)
				return

			var/current_pos = assembly_components.Find(component)

			// Find the position of a first removable component
			var/first_removable_pos
			for(var/i in 1 to assembly_components.len)
				var/obj/item/integrated_circuit/temp_component = assembly_components[i]
				if(temp_component.removable)
					first_removable_pos = i
					break

			if(href_list["remove"])
				try_remove_component(component, usr)

			else
				// Adjust the position
				if(href_list["up"])
					current_pos--
				else if(href_list["down"])
					current_pos++
				else if(href_list["top"])
					current_pos = first_removable_pos
				else if(href_list["bottom"])
					current_pos = assembly_components.len

				// Wrap around nicely
				if(current_pos < first_removable_pos)
					current_pos = assembly_components.len
				else if(current_pos > assembly_components.len)
					current_pos = first_removable_pos

				assembly_components.Remove(component)
				assembly_components.Insert(current_pos, component)

	interact(usr) // To refresh the UI.

<<<<<<< HEAD
/obj/item/electronic_assembly/pickup(mob/living/user)
=======
/obj/item/device/electronic_assembly/pickup(mob/living/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	//update diagnostic hud when picked up, true is used to force the hud to be hidden
	diag_hud_set_circuithealth(TRUE)
	diag_hud_set_circuitcell(TRUE)
	diag_hud_set_circuitstat(TRUE)
	diag_hud_set_circuittracking(TRUE)

<<<<<<< HEAD
/obj/item/electronic_assembly/dropped(mob/user)
=======
/obj/item/device/electronic_assembly/dropped(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = ..()
	//update diagnostic hud when dropped
	diag_hud_set_circuithealth()
	diag_hud_set_circuitcell()
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()

<<<<<<< HEAD
/obj/item/electronic_assembly/proc/rename()
=======
/obj/item/device/electronic_assembly/proc/rename()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	var/mob/M = usr
	if(!check_interactivity(M))
		return

	var/input = reject_bad_name(input("What do you want to name this?", "Rename", src.name) as null|text, TRUE)
	if(!check_interactivity(M))
		return
	if(src && input)
		to_chat(M, "<span class='notice'>The machine now has a label reading '[input]'.</span>")
		name = input

<<<<<<< HEAD
/obj/item/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/electronic_assembly/update_icon()
=======
/obj/item/device/electronic_assembly/proc/can_move()
	return FALSE

/obj/item/device/electronic_assembly/update_icon()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(opened)
		icon_state = initial(icon_state) + "-open"
	else
		icon_state = initial(icon_state)
	cut_overlays()
	if(detail_color == COLOR_ASSEMBLY_BLACK) //Black colored overlay looks almost but not exactly like the base sprite, so just cut the overlay and avoid it looking kinda off.
		return
	var/mutable_appearance/detail_overlay = mutable_appearance('icons/obj/assemblies/electronic_setups.dmi', "[icon_state]-color")
	detail_overlay.color = detail_color
	add_overlay(detail_overlay)

<<<<<<< HEAD
/obj/item/electronic_assembly/examine(mob/user)
=======
/obj/item/device/electronic_assembly/examine(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	..()
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.external_examine(user)
	if(opened)
		interact(user)

<<<<<<< HEAD
/obj/item/electronic_assembly/proc/return_total_complexity()
=======
/obj/item/device/electronic_assembly/proc/return_total_complexity()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_components)
		part = p
		. += part.complexity

<<<<<<< HEAD
/obj/item/electronic_assembly/proc/return_total_size()
=======
/obj/item/device/electronic_assembly/proc/return_total_size()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	. = 0
	var/obj/item/integrated_circuit/part
	for(var/p in assembly_components)
		part = p
		. += part.size

// Returns true if the circuit made it inside.
<<<<<<< HEAD
/obj/item/electronic_assembly/proc/try_add_component(obj/item/integrated_circuit/IC, mob/user)
=======
/obj/item/device/electronic_assembly/proc/try_add_component(obj/item/integrated_circuit/IC, mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(!opened)
		to_chat(user, "<span class='warning'>\The [src]'s hatch is closed, you can't put anything inside.</span>")
		return FALSE

	if(IC.w_class > w_class)
		to_chat(user, "<span class='warning'>\The [IC] is way too big to fit into \the [src].</span>")
		return FALSE

	var/total_part_size = return_total_size()
	var/total_complexity = return_total_complexity()

	if((total_part_size + IC.size) > max_components)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', as there's insufficient space.</span>")
		return FALSE
	if((total_complexity + IC.complexity) > max_complexity)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since this setup's too complicated for the case.</span>")
		return FALSE
	if((allowed_circuit_action_flags & IC.action_flags) != IC.action_flags)
		to_chat(user, "<span class='warning'>You can't seem to add the '[IC]', since the case doesn't support the circuit type.</span>")
		return FALSE

	if(!user.transferItemToLoc(IC, src))
		return FALSE

	to_chat(user, "<span class='notice'>You slide [IC] inside [src].</span>")
	playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)

	add_component(IC)
	return TRUE


// Actually puts the circuit inside, doesn't perform any checks.
<<<<<<< HEAD
/obj/item/electronic_assembly/proc/add_component(obj/item/integrated_circuit/component)
=======
/obj/item/device/electronic_assembly/proc/add_component(obj/item/integrated_circuit/component)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	component.forceMove(get_object())
	component.assembly = src
	assembly_components |= component

	//increment numbers for diagnostic hud
	if(component.action_flags & IC_ACTION_COMBAT)
		combat_circuits += 1;
	if(component.action_flags & IC_ACTION_LONG_RANGE)
		long_range_circuits += 1;

	//diagnostic hud update
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()


<<<<<<< HEAD
/obj/item/electronic_assembly/proc/try_remove_component(obj/item/integrated_circuit/IC, mob/user, silent)
=======
/obj/item/device/electronic_assembly/proc/try_remove_component(obj/item/integrated_circuit/IC, mob/user, silent)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(!opened)
		if(!silent)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
		return FALSE

	if(!IC.removable)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is permanently attached to the case.</span>")
		return FALSE

	remove_component(IC)
	if(!silent)
		to_chat(user, "<span class='notice'>You pop \the [IC] out of the case, and slide it out.</span>")
		playsound(src, 'sound/items/crowbar.ogg', 50, 1)
		user.put_in_hands(IC)

	return TRUE

// Actually removes the component, doesn't perform any checks.
<<<<<<< HEAD
/obj/item/electronic_assembly/proc/remove_component(obj/item/integrated_circuit/component)
=======
/obj/item/device/electronic_assembly/proc/remove_component(obj/item/integrated_circuit/component)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	component.disconnect_all()
	component.forceMove(drop_location())
	component.assembly = null
	assembly_components.Remove(component)

	//decriment numbers for diagnostic hud
	if(component.action_flags & IC_ACTION_COMBAT)
		combat_circuits -= 1;
	if(component.action_flags & IC_ACTION_LONG_RANGE)
		long_range_circuits -= 1;

	//diagnostic hud update
	diag_hud_set_circuitstat()
	diag_hud_set_circuittracking()


<<<<<<< HEAD
/obj/item/electronic_assembly/afterattack(atom/target, mob/user, proximity)
=======
/obj/item/device/electronic_assembly/afterattack(atom/target, mob/user, proximity)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	for(var/obj/item/integrated_circuit/input/S in assembly_components)
		if(S.sense(target,user,proximity))
			visible_message("<span class='notice'> [user] waves [src] around [target].</span>")


<<<<<<< HEAD
/obj/item/electronic_assembly/screwdriver_act(mob/living/user, obj/item/I)
=======
/obj/item/device/electronic_assembly/screwdriver_act(mob/living/user, obj/item/I)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	I.play_tool_sound(src)
	opened = !opened
	to_chat(user, "<span class='notice'>You [opened ? "open" : "close"] the maintenance hatch of [src].</span>")
	update_icon()
	return TRUE

<<<<<<< HEAD
/obj/item/electronic_assembly/attackby(obj/item/I, mob/living/user)
=======
/obj/item/device/electronic_assembly/attackby(obj/item/I, mob/living/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(can_anchor && default_unfasten_wrench(user, I, 20))
		return
	if(istype(I, /obj/item/integrated_circuit))
		if(!user.canUnEquip(I))
			return FALSE
		if(try_add_component(I, user))
			interact(user)
			return TRUE
		else
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()
<<<<<<< HEAD
	else if(istype(I, /obj/item/multitool) || istype(I, /obj/item/integrated_electronics/wirer) || istype(I, /obj/item/integrated_electronics/debugger))
=======
	else if(istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/integrated_electronics/wirer) || istype(I, /obj/item/device/integrated_electronics/debugger))
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
		if(opened)
			interact(user)
			return TRUE
		else
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't fiddle with the internal components.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()
	else if(istype(I, /obj/item/stock_parts/cell))
		if(!opened)
			to_chat(user, "<span class='warning'>[src]'s hatch is closed, so you can't access \the [src]'s power supplier.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()
		if(battery)
			to_chat(user, "<span class='warning'>[src] already has \a [battery] installed. Remove it first if you want to replace it.</span>")
			for(var/obj/item/integrated_circuit/input/S in assembly_components)
				S.attackby_react(I,user,user.a_intent)
			return ..()
		var/obj/item/stock_parts/cell = I
		user.transferItemToLoc(I, loc)
		cell.forceMove(src)
		battery = cell
		diag_hud_set_circuitstat() //update diagnostic hud
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You slot \the [cell] inside \the [src]'s power supplier.</span>")
		interact(user)
		return TRUE
<<<<<<< HEAD
	else if(istype(I, /obj/item/integrated_electronics/detailer))
		var/obj/item/integrated_electronics/detailer/D = I
=======
	else if(istype(I, /obj/item/device/integrated_electronics/detailer))
		var/obj/item/device/integrated_electronics/detailer/D = I
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
		detail_color = D.detail_color
		update_icon()
	else
		for(var/obj/item/integrated_circuit/input/S in assembly_components)
			S.attackby_react(I,user,user.a_intent)
		return ..()


<<<<<<< HEAD
/obj/item/electronic_assembly/attack_self(mob/user)
=======
/obj/item/device/electronic_assembly/attack_self(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(!check_interactivity(user))
		return
	if(opened)
		interact(user)

	var/list/input_selection = list()
	var/list/available_inputs = list()
	for(var/obj/item/integrated_circuit/input/input in assembly_components)
		if(input.can_be_asked_input)
			available_inputs.Add(input)
			var/i = 0
			for(var/obj/item/integrated_circuit/s in available_inputs)
				if(s.name == input.name && s.displayed_name == input.displayed_name && s != input)
					i++
			var/disp_name= "[input.displayed_name] \[[input]\]"
			if(i)
				disp_name += " ([i+1])"
			input_selection.Add(disp_name)

	var/obj/item/integrated_circuit/input/choice
	if(available_inputs)
		if(available_inputs.len ==1)
			choice = available_inputs[1]
		else
			var/selection = input(user, "What do you want to interact with?", "Interaction") as null|anything in input_selection
			if(!check_interactivity(user))
				return
			if(selection)
				var/index = input_selection.Find(selection)
				choice = available_inputs[index]

	if(choice)
		choice.ask_for_input(user)

<<<<<<< HEAD
/obj/item/electronic_assembly/emp_act(severity)
=======
/obj/item/device/electronic_assembly/emp_act(severity)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	..()
	for(var/i in 1 to contents.len)
		var/atom/movable/AM = contents[i]
		AM.emp_act(severity)

// Returns true if power was successfully drawn.
<<<<<<< HEAD
/obj/item/electronic_assembly/proc/draw_power(amount)
=======
/obj/item/device/electronic_assembly/proc/draw_power(amount)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(battery && battery.use(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

// Ditto for giving.
<<<<<<< HEAD
/obj/item/electronic_assembly/proc/give_power(amount)
=======
/obj/item/device/electronic_assembly/proc/give_power(amount)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(battery && battery.give(amount * GLOB.CELLRATE))
		return TRUE
	return FALSE

<<<<<<< HEAD
/obj/item/electronic_assembly/Moved(oldLoc, dir)
=======
/obj/item/device/electronic_assembly/Moved(oldLoc, dir)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.ext_moved(oldLoc, dir)
	if(light) //Update lighting objects (From light circuits).
		update_light()

<<<<<<< HEAD
/obj/item/electronic_assembly/stop_pulling()
=======
/obj/item/device/electronic_assembly/stop_pulling()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	for(var/I in assembly_components)
		var/obj/item/integrated_circuit/IC = I
		IC.stop_pulling()
	..()


// Returns the object that is supposed to be used in attack messages, location checks, etc.
// Override in children for special behavior.
<<<<<<< HEAD
/obj/item/electronic_assembly/proc/get_object()
=======
/obj/item/device/electronic_assembly/proc/get_object()
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	return src

// Returns the location to be used for dropping items.
// Same as the regular drop_location(), but with checks being run on acting_object if necessary.
/obj/item/integrated_circuit/drop_location()
	var/atom/movable/acting_object = get_object()

	// plz no infinite loops
	if(acting_object == src)
		return ..()

	return acting_object.drop_location()

<<<<<<< HEAD
/obj/item/electronic_assembly/attack_tk(mob/user)
=======
/obj/item/device/electronic_assembly/attack_tk(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(anchored)
		return
	..()

<<<<<<< HEAD
/obj/item/electronic_assembly/attack_hand(mob/user)
=======
/obj/item/device/electronic_assembly/attack_hand(mob/user)
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(anchored)
		attack_self(user)
		return
	..()

<<<<<<< HEAD
/obj/item/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/electronic_assembly/calc
=======
/obj/item/device/electronic_assembly/default //The /default electronic_assemblys are to allow the introduction of the new naming scheme without breaking old saves.
  name = "type-a electronic assembly"

/obj/item/device/electronic_assembly/calc
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-b electronic assembly"
	icon_state = "setup_small_calc"
	desc = "It's a case, for building small electronics with. This one resembles a pocket calculator."

<<<<<<< HEAD
/obj/item/electronic_assembly/clam
=======
/obj/item/device/electronic_assembly/clam
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-c electronic assembly"
	icon_state = "setup_small_clam"
	desc = "It's a case, for building small electronics with. This one has a clamshell design."

<<<<<<< HEAD
/obj/item/electronic_assembly/simple
=======
/obj/item/device/electronic_assembly/simple
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-d electronic assembly"
	icon_state = "setup_small_simple"
	desc = "It's a case, for building small electronics with. This one has a simple design."

<<<<<<< HEAD
/obj/item/electronic_assembly/hook
=======
/obj/item/device/electronic_assembly/hook
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-e electronic assembly"
	icon_state = "setup_small_hook"
	desc = "It's a case, for building small electronics with. This one looks like it has a belt clip, but it's purely decorative."

<<<<<<< HEAD
/obj/item/electronic_assembly/pda
=======
/obj/item/device/electronic_assembly/pda
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-f electronic assembly"
	icon_state = "setup_small_pda"
	desc = "It's a case, for building small electronics with. This one resembles a PDA."

<<<<<<< HEAD
/obj/item/electronic_assembly/medium
=======
/obj/item/device/electronic_assembly/medium
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "electronic mechanism"
	icon_state = "setup_medium"
	desc = "It's a case, for building medium-sized electronics with."
	w_class = WEIGHT_CLASS_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

<<<<<<< HEAD
/obj/item/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/electronic_assembly/medium/box
=======
/obj/item/device/electronic_assembly/medium/default
	name = "type-a electronic mechanism"

/obj/item/device/electronic_assembly/medium/box
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-b electronic mechanism"
	icon_state = "setup_medium_box"
	desc = "It's a case, for building medium-sized electronics with. This one has a boxy design."

<<<<<<< HEAD
/obj/item/electronic_assembly/medium/clam
=======
/obj/item/device/electronic_assembly/medium/clam
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-c electronic mechanism"
	icon_state = "setup_medium_clam"
	desc = "It's a case, for building medium-sized electronics with. This one has a clamshell design."

<<<<<<< HEAD
/obj/item/electronic_assembly/medium/medical
=======
/obj/item/device/electronic_assembly/medium/medical
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-d electronic mechanism"
	icon_state = "setup_medium_med"
	desc = "It's a case, for building medium-sized electronics with. This one resembles some type of medical apparatus."

<<<<<<< HEAD
/obj/item/electronic_assembly/medium/gun
=======
/obj/item/device/electronic_assembly/medium/gun
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-e electronic mechanism"
	icon_state = "setup_medium_gun"
	desc = "It's a case, for building medium-sized electronics with. This one resembles a gun, or some type of tool, if you're feeling optimistic."

<<<<<<< HEAD
/obj/item/electronic_assembly/medium/radio
=======
/obj/item/device/electronic_assembly/medium/radio
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-f electronic mechanism"
	icon_state = "setup_medium_radio"
	desc = "It's a case, for building medium-sized electronics with. This one resembles an old radio."

<<<<<<< HEAD
/obj/item/electronic_assembly/large
=======
/obj/item/device/electronic_assembly/large
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "electronic machine"
	icon_state = "setup_large"
	desc = "It's a case, for building large electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4

<<<<<<< HEAD
/obj/item/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/electronic_assembly/large/scope
=======
/obj/item/device/electronic_assembly/large/default
	name = "type-a electronic machine"

/obj/item/device/electronic_assembly/large/scope
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-b electronic machine"
	icon_state = "setup_large_scope"
	desc = "It's a case, for building large electronics with. This one resembles an oscilloscope."

<<<<<<< HEAD
/obj/item/electronic_assembly/large/terminal
=======
/obj/item/device/electronic_assembly/large/terminal
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-c electronic machine"
	icon_state = "setup_large_terminal"
	desc = "It's a case, for building large electronics with. This one resembles a computer terminal."

<<<<<<< HEAD
/obj/item/electronic_assembly/large/arm
=======
/obj/item/device/electronic_assembly/large/arm
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-d electronic machine"
	icon_state = "setup_large_arm"
	desc = "It's a case, for building large electronics with. This one resembles a robotic arm."

<<<<<<< HEAD
/obj/item/electronic_assembly/large/tall
=======
/obj/item/device/electronic_assembly/large/tall
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-e electronic machine"
	icon_state = "setup_large_tall"
	desc = "It's a case, for building large electronics with. This one has a tall design."

<<<<<<< HEAD
/obj/item/electronic_assembly/large/industrial
=======
/obj/item/device/electronic_assembly/large/industrial
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-f electronic machine"
	icon_state = "setup_large_industrial"
	desc = "It's a case, for building large electronics with. This one resembles some kind of industrial machinery."

<<<<<<< HEAD
/obj/item/electronic_assembly/drone
=======
/obj/item/device/electronic_assembly/drone
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "electronic drone"
	icon_state = "setup_drone"
	desc = "It's a case, for building mobile electronics with."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 3
	max_complexity = IC_COMPLEXITY_BASE * 3
	allowed_circuit_action_flags = IC_ACTION_MOVEMENT | IC_ACTION_COMBAT | IC_ACTION_LONG_RANGE
	can_anchor = FALSE

<<<<<<< HEAD
/obj/item/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/electronic_assembly/drone/default
	name = "type-a electronic drone"

/obj/item/electronic_assembly/drone/arms
=======
/obj/item/device/electronic_assembly/drone/can_move()
	return TRUE

/obj/item/device/electronic_assembly/drone/default
	name = "type-a electronic drone"

/obj/item/device/electronic_assembly/drone/arms
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-b electronic drone"
	icon_state = "setup_drone_arms"
	desc = "It's a case, for building mobile electronics with. This one is armed and dangerous."

<<<<<<< HEAD
/obj/item/electronic_assembly/drone/secbot
=======
/obj/item/device/electronic_assembly/drone/secbot
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-c electronic drone"
	icon_state = "setup_drone_secbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Securitron."

<<<<<<< HEAD
/obj/item/electronic_assembly/drone/medbot
=======
/obj/item/device/electronic_assembly/drone/medbot
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-d electronic drone"
	icon_state = "setup_drone_medbot"
	desc = "It's a case, for building mobile electronics with. This one resembles a Medibot."

<<<<<<< HEAD
/obj/item/electronic_assembly/drone/genbot
=======
/obj/item/device/electronic_assembly/drone/genbot
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-e electronic drone"
	icon_state = "setup_drone_genbot"
	desc = "It's a case, for building mobile electronics with. This one has a generic bot design."

<<<<<<< HEAD
/obj/item/electronic_assembly/drone/android
=======
/obj/item/device/electronic_assembly/drone/android
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "type-f electronic drone"
	icon_state = "setup_drone_android"
	desc = "It's a case, for building mobile electronics with. This one has a hominoid design."

<<<<<<< HEAD
/obj/item/electronic_assembly/wallmount
=======
/obj/item/device/electronic_assembly/wallmount
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "wall-mounted electronic assembly"
	icon_state = "setup_wallmount_medium"
	desc = "It's a case, for building medium-sized electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_NORMAL
	max_components = IC_MAX_SIZE_BASE * 2
	max_complexity = IC_COMPLEXITY_BASE * 2

<<<<<<< HEAD
/obj/item/electronic_assembly/wallmount/heavy
=======
/obj/item/device/electronic_assembly/wallmount/heavy
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "heavy wall-mounted electronic assembly"
	icon_state = "setup_wallmount_large"
	desc = "It's a case, for building large electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_BULKY
	max_components = IC_MAX_SIZE_BASE * 4
	max_complexity = IC_COMPLEXITY_BASE * 4

<<<<<<< HEAD
/obj/item/electronic_assembly/wallmount/light
=======
/obj/item/device/electronic_assembly/wallmount/light
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	name = "light wall-mounted electronic assembly"
	icon_state = "setup_wallmount_small"
	desc = "It's a case, for building small electronics with. It has a magnetized backing to allow it to stick to walls, but you'll still need to wrench the anchoring bolts in place to keep it on."
	w_class = WEIGHT_CLASS_SMALL
	max_components = IC_MAX_SIZE_BASE
	max_complexity = IC_COMPLEXITY_BASE

<<<<<<< HEAD
/obj/item/electronic_assembly/wallmount/proc/mount_assembly(turf/on_wall, mob/user) //Yeah, this is admittedly just an abridged and kitbashed version of the wallframe attach procs.
=======
/obj/item/device/electronic_assembly/wallmount/proc/mount_assembly(turf/on_wall, mob/user) //Yeah, this is admittedly just an abridged and kitbashed version of the wallframe attach procs.
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	if(get_dist(on_wall,user)>1)
		return
	var/ndir = get_dir(on_wall, user)
	if(!(ndir in GLOB.cardinals))
		return
	var/turf/T = get_turf(user)
	if(!isfloorturf(T))
		to_chat(user, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return
	if(gotwallitem(T, ndir))
		to_chat(user, "<span class='warning'>There's already an item on this wall!</span>")
		return
	playsound(src.loc, 'sound/machines/click.ogg', 75, 1)
	user.visible_message("[user.name] attaches [src] to the wall.",
		"<span class='notice'>You attach [src] to the wall.</span>",
		"<span class='italics'>You hear clicking.</span>")
	user.dropItemToGround(src)
	switch(ndir)
		if(NORTH)
			pixel_y = -31
		if(SOUTH)
			pixel_y = 31
		if(EAST)
			pixel_x = -31
		if(WEST)
			pixel_x = 31