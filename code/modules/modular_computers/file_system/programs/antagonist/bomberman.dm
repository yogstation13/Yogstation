GLOBAL_LIST_EMPTY(PDABombCodes)

/datum/computer_file/program/bomberman
	filename = "bomberman"
	filedesc = "BomberMan"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "A new-age version of the classic 'Detomatix' program run on legacy PDAs. Can be used to attempt detonation of any PDA on the messaging list."
	size = 5
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosBomberMan"
	program_icon = "comment-alt"

	var/insults = list(
		"THINK FAST CHUCKLENUTS!",
		"Oh my God! JC! A bomb!",
		"You've got mail!",
		"0.3 seconds to revelation.",
		"Sticks and stones may break my bones, but these words will hurt just a little.",
		"Get pwn3d",
		"The Spacial OSM Maneuver Test is an agility exercise that gets more difficult the more spin is put on the individual over time.",
		"Crazy how these are meant to explode like this",
		"My finger slipped, sorry",
		"You have been visited by the SPOOKY SYNDICATE MALWARE. Great wealth and opportunities will come to you, only if you share this with ten other people in the next second."
	)
	var/syndinames = list(
		"PRO SYNDIE HACKER",
		"Network Admin (Real)",
		"Anonymous #597301",
		"Spicy Hot Jalepeno Donkpocket",
		"128 TB of RAM",
		"The Malfunctioning AI",
		"Ian",
		"Your Mom"
	)
	var/bombcode = "Insert Code"

/datum/computer_file/program/bomberman/ui_act(action, params)
	if(..())
		return
	computer.play_interact_sound()
	switch(action)
		if("PRG_codechange")
			var/newcode = params["newcode"]
			if(!newcode)
				return
			bombcode = newcode
			return TRUE

		if("PRG_sendbomb")
			var/datum/ntosbombcode/bomb
			for(var/datum/ntosbombcode/B in GLOB.PDABombCodes)
				if(bombcode == B.code)
					bomb = B
					break
			
			if(!bomb)
				computer.visible_message(span_danger("ERROR. Invalid bomb code."), null, null, 1)
				return
			
			if(bomb.uses <= 0)
				computer.visible_message(span_danger("ERROR. No more charges on this code."), null, null, 1)
				return

			var/datum/computer_file/program/pdamessager/fakepda = new /datum/computer_file/program/pdamessager
			fakepda.username = pick(syndinames)

			var/datum/computer_file/program/pdamessager/target = locate(params["recipient"]) in GLOB.NTPDAs
			if(istype(target))
				bomb.uses-- // Deduct a charge
				var/difficulty = 1

				var/obj/item/modular_computer/target_computer
				if(target.computer) // Find computer
					target_computer = target.computer
				else if(istype(target.holder.loc, /obj/item/modular_computer))
					target_computer = target.holder.loc
				
				var/obj/item/card/id/targetid
				if(target_computer) // Find ID
					var/obj/item/computer_hardware/card_slot/card_slot = target_computer.all_components[MC_CARD]
					if(card_slot)
						targetid = card_slot.GetID()
					
				if(targetid) // Adjust difficulty based on target's access
					difficulty += BitCount(text2num(targetid.access_txt) & (ACCESS_MEDICAL | ACCESS_SECURITY | ACCESS_ENGINE | ACCESS_THEATRE | ACCESS_JANITOR | ACCESS_HEADS))
				
				if(SEND_SIGNAL(target_computer, COMSIG_PDA_CHECK_DETONATE) & COMPONENT_PDA_NO_DETONATE || prob(difficulty * 15))
					computer.visible_message(span_notice("Detonation failed. [bomb.uses] charges remaining."), null, null, 1)
				else
					log_bomber(usr, "triggered a PDA explosion on", target.username, "[!is_special_character(usr) ? "(TRIGGED BY NON-ANTAG)" : ""]")
					computer.visible_message(span_notice("Detonation success. [bomb.uses] charges remaining."), null, null, 1)
					target.receive_message(pick(insults), fakepda)
					spawn(0.3 SECONDS) // comedic timing but not fast enough to react
						target.explode()
			else
				computer.visible_message(span_danger("ERROR. PDA not found."), null, null, 1)
				return

			return TRUE


/datum/computer_file/program/bomberman/clone()
	var/datum/computer_file/program/bomberman/temp = ..()
	temp.bombcode = bombcode
	return temp

/datum/computer_file/program/bomberman/ui_data(mob/user)
	var/list/data = get_header_data()

	data["bombcode"] = bombcode
	
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

/datum/ntosbombcode
	var/code = ""
	var/uses = 4

/datum/ntosbombcode/New()
	code = "[num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)]" // 8 hexadecimal digits
	GLOB.PDABombCodes += src
