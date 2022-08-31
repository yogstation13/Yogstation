GLOBAL_LIST_EMPTY(PDAFrameCodes)

/datum/computer_file/program/frame
	filename = "frame"
	filedesc = "F.R.A.M.E."
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "A new-age version of the classic 'F.R.A.M.E.' program run on legacy PDAs. Can be used to silently open an uplink on any PDA on the messaging list."
	size = 5
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosFrame"
	program_icon = "comment-alt"

	var/framecode = "Insert Code"

/datum/computer_file/program/frame/ui_act(action, params)
	if(..())
		return
	computer.play_interact_sound()
	switch(action)
		if("PRG_codechange")
			var/newcode = params["newcode"]
			if(!newcode)
				return
			framecode = newcode
			return TRUE

		if("PRG_sendframe")
			var/datum/ntosframecode/framer
			for(var/datum/ntosframecode/B in GLOB.PDAFrameCodes)
				if(framecode == B.code)
					framer = B
					break
			
			if(!framer)
				computer.visible_message(span_danger("ERROR. Invalid frame code."), null, null, 1)
				return
			
			if(framer.uses <= 0)
				computer.visible_message(span_danger("ERROR. No more charges on this code."), null, null, 1)
				return

			var/datum/computer_file/program/pdamessager/target = locate(params["recipient"]) in GLOB.NTPDAs
			if(istype(target))

				if(!target.receiving)
					computer.visible_message(span_danger("ERROR. Target not available."), null, null, 1)
					return TRUE

				var/obj/item/modular_computer/target_computer
				if(target.computer) // Find computer
					target_computer = target.computer
				else if(istype(target.holder.loc, /obj/item/modular_computer))
					target_computer = target.holder.loc
				
				if(!target_computer)
					computer.visible_message(span_danger("ERROR. Target computer not found."), null, null, 1)
					return TRUE

				framer.uses--

				var/lock_code = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"
				computer.visible_message(span_notice("Virus Sent! [framer.uses] left. The unlock code to the target is: [lock_code]"), null, null, 1)

				var/datum/component/uplink/hidden_uplink = target_computer.GetComponent(/datum/component/uplink)
				if(!hidden_uplink)
					hidden_uplink = target_computer.AddComponent(/datum/component/uplink)
					hidden_uplink.unlock_code = lock_code
				else
					hidden_uplink.hidden_crystals += hidden_uplink.telecrystals //Temporarially hide the PDA's crystals, so you can't steal telecrystals.
				hidden_uplink.telecrystals = 0
				hidden_uplink.locked = FALSE
			else
				computer.visible_message(span_danger("ERROR. Target not found."), null, null, 1)

			return TRUE


/datum/computer_file/program/frame/clone()
	var/datum/computer_file/program/frame/temp = ..()
	temp.framecode = framecode
	return temp

/datum/computer_file/program/frame/ui_data(mob/user)
	var/list/data = get_header_data()

	data["framecode"] = framecode
	
	var/list/pdas = list()
	for(var/datum/computer_file/program/pdamessager/P in GLOB.NTPDAs)
		if(P.receiving == FALSE)
			continue
		if(!P.holder)
			continue
		if(!istype(holder.loc, /obj/item/modular_computer))
			continue
		pdas += list(list(P.username, REF(P)))
	data["pdas"] = pdas

	return data

/datum/ntosframecode
	var/code = ""
	var/uses = 5

/datum/ntosframecode/New()
	code = "[num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)]" // 8 hexadecimal digits
	GLOB.PDAFrameCodes += src
