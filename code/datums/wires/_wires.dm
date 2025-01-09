#define MAXIMUM_EMP_WIRES 3

/proc/is_wire_tool(obj/item/I)
	if(!I)
		return

	if(I.tool_behaviour == TOOL_WIRECUTTER || I.tool_behaviour == TOOL_MULTITOOL || I.tool_behaviour == TOOL_WIRING)
		return TRUE
	if(istype(I, /obj/item/assembly))
		var/obj/item/assembly/A = I
		if(A.attachable)
			return TRUE

/atom/proc/attempt_wire_interaction(mob/user)
	if(!wires)
		return WIRE_INTERACTION_FAIL
	if(!user.CanReach(src))
		return WIRE_INTERACTION_FAIL
	wires.interact(user)
	return WIRE_INTERACTION_BLOCK

/datum/wires
	/// The holder (atom that contains these wires).
	var/atom/holder = null
	/// The holder's typepath (used for sanity checks to make sure the holder is the appropriate type for these wire sets).
	var/holder_type = null
	/// Key that enables wire assignments to be common across different holders. If null, will use the holder_type as a key.
	var/dictionary_key = null
	/// The display name for the wire set shown in station blueprints. Not shown in blueprints if randomize is TRUE or it's an item NT wouldn't know about (Explosives/Nuke). Also used in the hacking interface.
	var/proper_name = "Unknown"

	/// List of all wires.
	var/list/wires = list()
	/// List of cut wires.
	var/list/cut_wires = list() // List of wires that have been cut.
	/// Dictionary of colours to wire.
	var/list/colors = list()
	/// List of attached assemblies.
	var/list/assemblies = list()
	/// Skill required to identify each wire, EXP_GENIUS if not specified here.
	var/static/list/wire_difficulty = list(
		WIRE_SHOCK = EXP_MID,
		WIRE_RESET_MODULE = EXP_MID,
		WIRE_ZAP = EXP_MID,
		WIRE_ZAP1 = EXP_HIGH,
		WIRE_ZAP2 = EXP_HIGH,
		WIRE_LOCKDOWN = EXP_HIGH,
		WIRE_CAMERA = EXP_HIGH,
		WIRE_POWER = EXP_HIGH,
		WIRE_POWER1 = EXP_MASTER,
		WIRE_POWER2 = EXP_MASTER,
		WIRE_IDSCAN = EXP_MASTER,
		WIRE_UNBOLT = EXP_MASTER,
		WIRE_BACKUP1 = EXP_MASTER,
		WIRE_BACKUP2 = EXP_MASTER,
		WIRE_LAWSYNC = EXP_MASTER,
		WIRE_PANIC = EXP_MASTER,
		WIRE_OPEN = EXP_MASTER,
		WIRE_HACK = EXP_MASTER,
		WIRE_AI = EXP_MASTER,
	)

	/// If every instance of these wires should be random. Prevents wires from showing up in station blueprints.
	var/randomize = FALSE

/datum/wires/New(atom/holder)
	..()
	if(!istype(holder, holder_type))
		CRASH("Wire holder is not of the expected type!")

	src.holder = holder

	// If there is a dictionary key set, we'll want to use that. Otherwise, use the holder type.
	var/key = dictionary_key ? dictionary_key : holder_type

	if(randomize)
		randomize()
	else
		if(!GLOB.wire_color_directory[key])
			randomize()
			GLOB.wire_color_directory[key] = colors
			GLOB.wire_name_directory[key] = proper_name
		else
			colors = GLOB.wire_color_directory[key]

/datum/wires/Destroy()
	holder = null
	assemblies = list()
	return ..()

/datum/wires/proc/add_duds(duds)
	while(duds)
		var/dud = WIRE_DUD_PREFIX + "[--duds]"
		if(dud in wires)
			continue
		wires += dud

/datum/wires/proc/randomize()
	var/static/list/possible_colors = list(
	"blue",
	"brown",
	"crimson",
	"cyan",
	"gold",
	"grey",
	"green",
	"magenta",
	"orange",
	"pink",
	"purple",
	"red",
	"silver",
	"violet",
	"white",
	"yellow"
	)

	var/list/my_possible_colors = possible_colors.Copy()

	for(var/wire in shuffle(wires))
		colors[pick_n_take(my_possible_colors)] = wire

/datum/wires/proc/shuffle_wires()
	colors.Cut()
	randomize()

/datum/wires/proc/repair()
	cut_wires.Cut()

/datum/wires/proc/get_wire(color)
	return colors[color]

/datum/wires/proc/get_color_of_wire(wire_type)
	for(var/color in colors)
		var/other_type = colors[color]
		if(wire_type == other_type)
			return color

/datum/wires/proc/get_attached(color)
	if(assemblies[color])
		return assemblies[color]
	return null

/datum/wires/proc/is_attached(color)
	if(assemblies[color])
		return TRUE

/datum/wires/proc/is_cut(wire)
	return (wire in cut_wires)

/datum/wires/proc/is_color_cut(color)
	return is_cut(get_wire(color))

/datum/wires/proc/is_all_cut()
	if(cut_wires.len == wires.len)
		return TRUE

/datum/wires/proc/is_dud(wire)
	return findtext(wire, WIRE_DUD_PREFIX, 1, length(WIRE_DUD_PREFIX) + 1)

/datum/wires/proc/is_dud_color(color)
	return is_dud(get_wire(color))

/datum/wires/proc/is_revealed(color, mob/user)
	// Admin ghost can see a purpose of each wire.
	if(IsAdminGhost(user))
		return TRUE

	// Same for anyone with an abductor multitool.
	else if(user.is_holding_item_of_type(/obj/item/multitool/abductor))
		return TRUE

	// Station blueprints do that too, but only if the wires are not randomized.
	else if(!randomize)
		if(user.is_holding_item_of_type(/obj/item/areaeditor/blueprints))
			return TRUE
		else if(user.is_holding_item_of_type(/obj/item/photo))
			var/obj/item/photo/P = user.is_holding_item_of_type(/obj/item/photo)
			if(P.picture.has_blueprints)	//if the blueprints are in frame
				return TRUE

	var/skill_required = wire_difficulty[get_wire(color)]
	if(skill_required && user.skill_check(SKILL_TECHNICAL, skill_required))
		return TRUE
	return FALSE

/datum/wires/proc/cut(wire, mob/user)
	if(is_cut(wire))
		cut_wires -= wire
		on_cut(wire, mend = TRUE)
	else
		cut_wires += wire
		on_cut(wire, mend = FALSE)
	if(user)
		user.add_exp(SKILL_TECHNICAL, 50, "[wire]_[type]")

/datum/wires/proc/cut_color(color)
	cut(get_wire(color))

/datum/wires/proc/cut_random()
	cut(wires[rand(1, wires.len)])

/datum/wires/proc/cut_all()
	for(var/wire in wires)
		cut(wire)

/datum/wires/proc/pulse(wire, mob/user)
	if(is_cut(wire))
		return
	on_pulse(wire, user)
	if(user)
		user.add_exp(SKILL_TECHNICAL, 50, "[wire]_[type]")

/datum/wires/proc/pulse_color(color, mob/living/user)
	pulse(get_wire(color), user)

/datum/wires/proc/pulse_assembly(obj/item/assembly/S)
	for(var/color in assemblies)
		if(S == assemblies[color])
			pulse_color(color)
			return TRUE

/datum/wires/proc/attach_assembly(color, obj/item/assembly/S)
	if(S && istype(S) && S.attachable && !is_attached(color))
		assemblies[color] = S
		S.forceMove(holder)
		S.connected = src
		return S

/datum/wires/proc/detach_assembly(color)
	var/obj/item/assembly/S = get_attached(color)
	if(S && istype(S))
		assemblies -= color
		S.connected = null
		S.forceMove(holder.drop_location())
		return S

/datum/wires/proc/emp_pulse()
	var/list/possible_wires = shuffle(wires)
	var/remaining_pulses = MAXIMUM_EMP_WIRES

	for(var/wire in possible_wires)
		if(prob(33))
			pulse(wire)
			remaining_pulses--
			if(!remaining_pulses)
				break

// Overridable Procs
/datum/wires/proc/interactable(mob/user)
	return TRUE

/datum/wires/proc/get_status()
	return list()

/datum/wires/proc/on_cut(wire, mend = FALSE)
	return

/datum/wires/proc/on_pulse(wire, user)
	return
// End Overridable Procs

/datum/wires/proc/interact(mob/user)
	if(!interactable(user))
		return
	ui_interact(user)
	for(var/A in assemblies)
		var/obj/item/I = assemblies[A]
		if(istype(I) && I.on_found(user))
			return

/datum/wires/ui_host()
	return holder

/datum/wires/ui_status(mob/user)
	if(interactable(user))
		return ..()
	return UI_CLOSE

/datum/wires/ui_state(mob/user)
	return GLOB.physical_state

/datum/wires/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Wires", "[holder.name] Wires")
		ui.open()

/datum/wires/ui_data(mob/user)
	var/list/data = list()
	var/list/payload = list()

	var/colorblind = HAS_TRAIT(user, TRAIT_COLORBLIND)
	for(var/color in colors)
		payload.Add(list(list(
			"color" = color,
			"wire" = (!colorblind && !is_dud_color(color) && is_revealed(color, user)) ? get_wire(color) : null,
			"cut" = is_color_cut(color),
			"attached" = is_attached(color)
		)))
	data["wires"] = payload
	data["status"] = get_status()
	data["proper_name"] = (proper_name != "Unknown") ? proper_name : null
	data["colorblind"] = colorblind
	return data

/datum/wires/ui_act(action, params)
	if(..() || !interactable(usr))
		return
	if(!holder) // wires with no holder makes no sense to exist and probably breaks things, so catch any instances of that
		CRASH("[type] has no holder!")
	var/target_wire = params["wire"]
	var/mob/living/user = usr
	var/obj/item/tool
	var/tool_delay = max((0.5**user.get_skill(SKILL_TECHNICAL)) SECONDS, 0)
	if(tool_delay < 0.2 SECONDS) // effectively already instant
		tool_delay = 0
	switch(action)
		if("cut")
			tool = user.is_holding_tool_quality(TOOL_WIRECUTTER)
			if(tool?.use_tool(holder, user, tool_delay) || IsAdminGhost(usr))
				tool.play_tool_sound(holder, 20)
				cut_color(target_wire)
				. = TRUE
			else if(!tool)
				to_chat(user, span_warning("You need wirecutters!"))
		if("pulse")
			tool = user.is_holding_tool_quality(TOOL_MULTITOOL)
			if(tool?.use_tool(holder, user, tool_delay) || IsAdminGhost(usr))
				tool.play_tool_sound(holder, 20)
				pulse_color(target_wire, user)
				. = TRUE
			else if(!tool)
				to_chat(user, span_warning("You need a multitool!"))
		if("attach")
			if(is_attached(target_wire))
				if(!do_after(user, tool_delay, holder))
					return
				user.put_in_hands(detach_assembly(target_wire))
				. = TRUE
			else
				tool = user.get_active_held_item()
				if(istype(tool, /obj/item/assembly) && tool?.use_tool(holder, user, tool_delay))
					var/obj/item/assembly/A = tool
					if(A.attachable)
						if(!user.temporarilyRemoveItemFromInventory(A))
							return
						if(!attach_assembly(target_wire, A))
							A.forceMove(user.drop_location())
						. = TRUE
					else
						to_chat(user, span_warning("You need an attachable assembly!"))

#undef MAXIMUM_EMP_WIRES
