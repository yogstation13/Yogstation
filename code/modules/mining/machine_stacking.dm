/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "Controls a stacking machine... in theory."
	density = FALSE
	circuit = /obj/item/circuitboard/machine/stacking_unit_console
	var/obj/machinery/mineral/stacking_machine/machine
	var/machinedir = SOUTHEAST

/obj/machinery/mineral/stacking_unit_console/Initialize()
	. = ..()
	machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
	if (machine)
		machine.console = src

/obj/machinery/mineral/stacking_unit_console/ui_interact(mob/user)
	. = ..()

	if(!machine)
		to_chat(user, span_notice("[src] is not linked to a machine!"))
		return

	var/obj/item/stack/sheet/s
	var/dat = text("<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>")

	dat += text("<b>Stacking unit console</b><br><br>")

	for(var/O in machine.stack_list)
		s = machine.stack_list[O]
		if(s.amount > 0)
			dat += text("[capitalize(s.name)]: [s.amount] <A href='?src=[REF(src)];release=[s.type]'>Release</A><br>")

	dat += text("<br>Stacking: [machine.stack_amt]<br><br>")

	dat += text("</BODY></HTML>")

	user << browse(dat, "window=console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return
	var/obj/item/multitool/M = I
	M.buffer = src
	to_chat(user, span_notice("You store linkage information in [I]'s buffer."))
	return TRUE

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["release"])
		if(!(text2path(href_list["release"]) in machine.stack_list))
			return //someone tried to spawn materials by spoofing hrefs
		var/obj/item/stack/sheet/inp = machine.stack_list[text2path(href_list["release"])]
		var/obj/item/stack/sheet/out = new inp.type(null, inp.amount)
		inp.amount = 0
		machine.unload_mineral(out)

	src.updateUsrDialog()
	return

/obj/machinery/mineral/stacking_unit_console/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "console-open", "console", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/**********************Mineral stacking unit**************************/
#define INPUT 0
#define OUTPUT 1

/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	desc = "A machine that automatically stacks acquired materials. Controlled by a nearby console."
	density = TRUE
	circuit = /obj/item/circuitboard/machine/stacking_machine
	input_dir = EAST
	output_dir = WEST
	var/obj/machinery/mineral/stacking_unit_console/console
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50 //amount to stack before releassing
	var/datum/component/remote_materials/materials
	var/force_connect = FALSE
	var/io = INPUT //This is used for determining whether we change the Input or Output


/obj/machinery/mineral/stacking_machine/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Currently outputting stacks at <b>[stack_amt] sheet[(stack_amt > 1) ? "s" : ""]</b><span>"
	if(panel_open)
		. += "The I/O is set to change <b>[io ? "output" : "input"]</b> currently."
		. += "Input is <b>[dir2text(input_dir)]</b>"
		. += "Output is <b>[dir2text(output_dir)]</b>."
		. += "There is a dial that can be <b>turned by hand</b> to change direction."
		. += "The I/O setting can be <b>changed with a multitool</b> to change what the dial controls."
		. += "There are some <b>bolts</b> to limit stack size."

/obj/machinery/mineral/stacking_machine/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	materials = AddComponent(/datum/component/remote_materials, "stacking", mapload, FALSE, mapload && force_connect)

/obj/machinery/mineral/stacking_machine/HasProximity(atom/movable/AM)
	if(panel_open || (stat & (BROKEN|NOPOWER)))
		return
	if(istype(AM, /obj/item/stack/sheet) && AM.loc == get_step(src, input_dir))
		process_sheet(AM)

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/inp)
	var/key = inp.merge_type
	var/obj/item/stack/sheet/storage = stack_list[key]
	if(!storage) //It's the first of this sheet added
		stack_list[key] = storage = new inp.type(src, 0)
	storage.amount += inp.amount //Stack the sheets
	qdel(inp)

	if(materials.silo && !materials.on_hold()) //Dump the sheets to the silo
		var/matlist = storage.materials & materials.mat_container.materials
		if (length(matlist))
			var/inserted = materials.mat_container.insert_stack(storage)
			materials.silo_log(src, "collected", inserted, "sheets", matlist)
			if (QDELETED(storage))
				stack_list -= key
			return

	while(storage.amount >= stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new inp.type(null, stack_amt)
		unload_mineral(out)
		storage.amount -= stack_amt

/obj/machinery/mineral/stacking_machine/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "stacker-open", "stacker", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return

	if(W.tool_behaviour == TOOL_WRENCH && panel_open)
		var/stsize = input(user, "How much should [src] stack to? (1-50)", "Stack size") as null|num
		if(stsize)
			stack_amt = clamp(stsize,1,50)
			to_chat(user, "<span class='notice'>[src] is now set to output <b>[stack_amt] sheet[(stack_amt > 1) ? "s" : ""]</b><span>")
			return

	return ..()

/obj/machinery/mineral/stacking_machine/attack_hand(mob/user)
	if(!panel_open)
		return ..()
	if(io == INPUT)
		input_dir = turn(input_dir, -90)
		if(input_dir == output_dir) //Input and output can't be the same or you create the immovable sheet.
			input_dir = turn(input_dir, -90)
		to_chat(user, span_notice("You set [src]'s input to take from the [dir2text(input_dir)]."))
		return
	else if (io == OUTPUT)
		output_dir = turn(output_dir, -90)
		if(input_dir == output_dir)
			output_dir = turn(output_dir, -90)
		to_chat(user, span_notice("You set [src]'s output to drop stacks [dir2text(output_dir)]."))
		return
	return ..()

/obj/machinery/mineral/stacking_machine/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(istype(M.buffer, /obj/machinery/mineral/stacking_unit_console) && !panel_open)
			console = M.buffer
			console.machine = src
			to_chat(user, span_notice("You link [src] to the console in [M]'s buffer."))
			return TRUE
	if(panel_open)
		io = !io
		to_chat(user, span_notice("You set the I/O to change [io ? "output" : "input"]."))
		return TRUE
