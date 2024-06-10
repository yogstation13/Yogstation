/datum/component/keypad_lock //Thanks johnfulpwillard, didn't know components existed until I saw your PR
	//What the user inputed and what shows in the bottom display
	var/keypad_input = "INPUT NEW 5 DIGIT CODE"
	//Keypad's code
	var/access_code = ""
	//If the item is locked or not
	var/lock_status = FALSE
	//What is added to lock_status_display
	var/lock_display = "UNLOCKED"
	//If there is an error message
	var/error_message = FALSE
	//If a displayed message can be replaced by keypad_input
	var/replace_message = TRUE
	//Sound to play
	var/keypad_sound = 'sound/machines/terminal_select.ogg'

	//If the panel is open
	var/panel_open = FALSE

/datum/component/keypad_lock/Initialize(keypad_code = access_code, lock_state = lock_status, keypad_text = keypad_input, lock_text = lock_display)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.access_code = keypad_code
	src.lock_status = lock_state
	src.keypad_input = keypad_text
	src.lock_display = lock_text

	var/atom/atom_parent = parent

	atom_parent.update_appearance()

/datum/component/keypad_lock/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver_act))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_multitool_act))

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_interact))
	else
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_interact))

/datum/component/keypad_lock/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL),
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_UPDATE_ICON_STATE,
	))

	if(isitem(parent))
		UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	else
		UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	return ..()

/datum/component/keypad_lock/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "The service panel is currently <b>[panel_open ? "unscrewed" : "screwed shut"]</b>."

/datum/component/keypad_lock/proc/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!src.lock_status)
		return COMPONENT_BLOCK_TOOL_ATTACK
	panel_open = !panel_open
	user.balloon_alert(user, "panel [panel_open ? "opened" : "closed"]")
	return COMPONENT_BLOCK_TOOL_ATTACK

/datum/component/keypad_lock/proc/on_multitool_act(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!src.lock_status)
		return COMPONENT_BLOCK_TOOL_ATTACK
	if(!panel_open)
		user.balloon_alert(user, "panel is closed!")
		return COMPONENT_BLOCK_TOOL_ATTACK
	user.balloon_alert(user, "reseting memory")
	INVOKE_ASYNC(src, PROC_REF(hack_open), source, user, tool)
	return COMPONENT_BLOCK_TOOL_ATTACK

/datum/component/keypad_lock/proc/hack_open(atom/source, mob/user, obj/item/tool)
	if(!tool.use_tool(parent, user, 40 SECONDS))
		user.balloon_alert(user, "interupted!")
		return
	user.balloon_alert(user, "memory reset")
	src.access_code = ""
	src.keypad_input = "INPUT NEW 5 DIGIT CODE"

/datum/component/keypad_lock/proc/on_update_icon_state(obj/source)
	SIGNAL_HANDLER
	source.icon_state = source.base_icon_state + "[src.lock_status ? "_locked" : null]"

/datum/component/keypad_lock/proc/on_interact(atom/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_interact), user)

/datum/component/keypad_lock/ui_interact(mob/user, datum/tgui/ui) //Thanks chubby for helping me with TGUI 
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KeypadLock", parent)
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/component/keypad_lock/ui_data(mob/user)
	var/list/data = list()
	data["lock_status_display"] = "Lock Status: " + lock_display
	data["keypad_code_display"] = src.keypad_input
	return data

/datum/component/keypad_lock/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "keypad")
		var/digit = params["digit"]
		var/atom/source = parent
		switch(digit)
			if("0","1","2","3","4","5","6","7","8","9")
				//No input when an error exists
				if(!error_message)
					if(replace_message == TRUE)
						src.keypad_input = digit
						replace_message = FALSE
					else
						src.keypad_input += digit
					//Throw an error if too many digits
					if(length(src.keypad_input) > 5)
						src.keypad_input = "ERROR: TOO MANY DIGITS"
						error_message = TRUE
					. = TRUE
			if("E")
				//Only allow if there is no error message
				if(!error_message)
					//Make input the access code if there is none and it meets criteria
					if(src.access_code == "" && length(src.keypad_input) == 5)
						src.access_code = src.keypad_input
						src.keypad_input = "*****"
						src.lock_status = FALSE
						lock_display = "UNLOCKED"
						SEND_SIGNAL(parent, COMSIG_TRY_STORAGE_SET_LOCKSTATE, lock_status)
						source.update_appearance(UPDATE_ICON)
						. = TRUE
					//Code too short
					else if(length(src.keypad_input) < 5)
						src.keypad_input = "ERROR: TOO FEW DIGITS"
						error_message = TRUE
					//Wrong code
					else if(src.keypad_input != src.access_code)
						src.keypad_input = "ERROR: WRONG CODE"
						error_message = TRUE
					//Correct code
					else if(src.keypad_input == src.access_code)
						src.keypad_input = "*****"
						//Unlock if locked
						if(src.lock_status)
							src.lock_status = FALSE
							lock_display = "UNLOCKED"
							SEND_SIGNAL(parent, COMSIG_TRY_STORAGE_SET_LOCKSTATE, lock_status)
							source.update_appearance(UPDATE_ICON)
						. = TRUE
			//Reset current code and engage lock
			if("R")
				if(access_code == "")
					src.keypad_input = "INPUT NEW 5 DIGIT CODE"
				else
					src.keypad_input = "INPUT 5 DIGIT CODE"
				error_message = FALSE
				replace_message = TRUE
				src.lock_status = TRUE
				lock_display = "LOCKED"
				SEND_SIGNAL(parent, COMSIG_TRY_STORAGE_SET_LOCKSTATE, lock_status)
				SEND_SIGNAL(parent, COMSIG_TRY_STORAGE_HIDE_FROM, usr)
				source.update_appearance(UPDATE_ICON)
				. = TRUE
		//Play appropriate sound
		if(error_message)
			keypad_sound = 'sound/machines/terminal_prompt_deny.ogg'
		else if(src.keypad_input == "*****")
			keypad_sound = 'sound/machines/terminal_prompt_confirm.ogg'
		else
			keypad_sound = 'sound/machines/terminal_select.ogg'
		playsound(parent, keypad_sound, 10, FALSE)
