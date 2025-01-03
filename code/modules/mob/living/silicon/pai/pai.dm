/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"
	mouse_opacity = MOUSE_OPACITY_ICON
	density = FALSE
	hud_type = /datum/hud/pai
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be activated."
	weather_immunities = WEATHER_STORM
	light_on = FALSE
	light_flags = LIGHT_ATTACHED
	light_system = MOVABLE_LIGHT
	health = 500
	maxHealth = 500
	layer = BELOW_MOB_LAYER
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_lh = 'icons/mob/pai_item_lh.dmi'
	held_rh = 'icons/mob/pai_item_rh.dmi'
	held_icon = 'icons/mob/pai_item_head.dmi'
	var/network = "ss13"
	var/obj/machinery/camera/current = null

	///Used as currency to purchase different abilities
	var/ram = 100	
	var/list/software = list()
	///The DNA string of our assigned user
	var/userDNA		
	///The card we inhabit
	var/obj/item/computer_hardware/paicard/card	
	///Are we hacking a door?
	var/hacking = FALSE		

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"

	///The cable we produce and use when door or camera jacking
	var/obj/item/pai_cable/cable		

	///Name of the one who commands us
	var/master				
	///DNA string for owner verification
	var/master_dna			

// Various software-specific vars

	///The airlock being hacked
	var/obj/machinery/door/hackdoor		
	///Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check
	var/hackprogress = 0				

	///Remote signaler
	var/obj/item/assembly/signaler/internal/signaler

	var/obj/item/instrument/piano_synth/internal_instrument
	///pAI Newscaster
	var/obj/machinery/newscaster		
	///pAI healthanalyzer	
	var/obj/item/healthanalyzer/hostscan				

	///Whether the pAI has bought the encryption slot module or not
	var/encryptmod = FALSE
	var/holoform = FALSE
	///Can pAI use their holoprojector?
	var/canholo = TRUE
	///Can pAI transmit radio messages?
	var/can_transmit = TRUE
	///Can pAI receive radio messages?
	var/can_receive = TRUE
	var/obj/item/card/id/access_card = new /obj/item/card/id
	var/chassis = "repairbot"
	var/list/possible_chassis = list("cat" = TRUE, "mouse" = TRUE, "monkey" = TRUE, "corgi" = FALSE, "fox" = FALSE, "repairbot" = TRUE, "rabbit" = TRUE, "frog" = TRUE)		//assoc value is whether it can be picked up.

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitter_regen_per_second = 1.25
	var/emittercd = 50
	var/emitteroverloadcd = 100
	var/emittersemicd = FALSE

	var/overload_ventcrawl = 0
	//Why is this a good idea?
	var/overload_bulletblock = 0	
	var/overload_maxhealth = 0
	var/silent = FALSE
	var/brightness_power = 5

	var/atom/movable/screen/ai/mod_pc/interfaceButton

/mob/living/silicon/pai/can_unbuckle()
	return FALSE

/mob/living/silicon/pai/can_buckle()
	return FALSE

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(internal_instrument)
	if (loc != card)
		card.forceMove(drop_location())
	card.pai = null
	card.cut_overlays()
	card.add_overlay("pai-off")
	GLOB.pai_list -= src
	return ..()

/mob/living/silicon/pai/Initialize(mapload)
	var/obj/item/computer_hardware/paicard/P = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/computer_hardware/paicard(newcardloc)
		P.setPersonality(src)
	forceMove(P)
	card = P
	job = "Personal AI"
	signaler = new(src)
	hostscan = new /obj/item/healthanalyzer(src)
	if(!radio)	
		radio = new /obj/item/radio/headset/silicon/pai(src)
	newscaster = new /obj/machinery/newscaster(src)
	if(!aicamera)
		aicamera = new /obj/item/camera/siliconcam/ai_camera(src)
		aicamera.flash_enabled = TRUE

	. = ..()

	emittersemicd = TRUE
	addtimer(CALLBACK(src, PROC_REF(emittercool)), 600)

/mob/living/silicon/pai/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(hacking)
		process_hack()
	return ..()

/mob/living/silicon/pai/can_interact_with(atom/target)
	if(target == signaler) // Bypass for signaler
		return TRUE
	if(target == modularInterface)
		return TRUE
	return ..()

/mob/living/silicon/pai/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated/pai(src)
	return ..()

/mob/living/silicon/pai/proc/process_hack()

	if(cable && cable.machine && istype(cable.machine, /obj/machinery/door) && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
		hackprogress = clamp(hackprogress + 20, 0, 100)
	else
		hackprogress = 0
		hacking = FALSE
		hackdoor = null
		return
	if(hackprogress >= 100)
		hackprogress = 0
		var/obj/machinery/door/D = cable.machine
		D.open()
		hacking = FALSE

/mob/living/silicon/pai/make_laws()
	laws = new()
	laws.name = "pAI Directives"
	laws.set_zeroth_law("Serve your master.")
	laws.set_supplied_laws(list("None."))
	return TRUE

/mob/living/silicon/pai/Login()
	..()
	if(client)
		client.perspective = EYE_PERSPECTIVE
		if(holoform)
			client.set_eye(src)
		else
			client.set_eye(card)


/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [emitterhealth * (100/emittermaxhealth)]")
	else
		. += text("Systems nonfunctional")

/mob/living/silicon/pai/restrained(ignore_grab)
	. = FALSE

// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	if(be_close && !in_range(M, src))
		to_chat(src, span_warning("You are too far away!"))
		return FALSE
	return TRUE

/mob/proc/makePAI(delold)
	var/obj/item/computer_hardware/paicard/card = new /obj/item/computer_hardware/paicard(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.key = key
	pai.name = name
	card.setPersonality(pai)
	if(delold)
		qdel(src)

/datum/action/innate/pai
	name = "PAI Action"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	var/mob/living/silicon/pai/P

/datum/action/innate/pai/Trigger()
	if(!ispAI(owner))
		return 0
	P = owner

/datum/action/innate/pai/software
	name = "Software Interface"
	button_icon_state = "pai"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/software/Trigger()
	..()
	P.ui_interact(usr)

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/shell/Trigger()
	..()
	if(P.holoform)
		P.fold_in(0)
	else
		P.fold_out()

/datum/action/innate/pai/chassis
	name = "Holochassis Appearance Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/chassis/Trigger()
	..()
	P.choose_chassis()

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/rest/Trigger()
	..()
	P.lay_down()

/datum/action/innate/pai/light
	name = "Toggle Integrated Lights"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "emp"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/innate/pai/light/Trigger()
	..()
	P.toggle_integrated_light()

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(!.)
		add_movespeed_modifier(MOVESPEED_ID_PAI_SPACEWALK_SPEEDMOD, TRUE, 100, multiplicative_slowdown = 2)
		return TRUE
	remove_movespeed_modifier(MOVESPEED_ID_PAI_SPACEWALK_SPEEDMOD, TRUE)
	return TRUE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master ? master : "empty"]."
	if(software && isobserver(user))
		. += "<b>[src] has the following modules:</b>"
		for(var/module in software)
			. += "[module]"

/mob/living/silicon/pai/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	if(stat == DEAD)
		return
	if(cable)
		if(get_dist(src, cable) > 1)
			var/turf/T = get_turf(src.loc)
			T.visible_message(span_warning("[src.cable] rapidly retracts back into its spool."), span_italics("You hear a click and the sound of wire spooling rapidly."))
			qdel(src.cable)
			cable = null
			cable_status = "Retracted"
	silent = max(silent - 1, 0)
	. = ..()

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getBruteLoss() - getFireLoss()
	update_stat()

/mob/living/silicon/pai/process(delta_time)
	emitterhealth = clamp((emitterhealth + (emitter_regen_per_second * delta_time)), -50, emittermaxhealth)

/obj/item/computer_hardware/paicard/attackby(obj/item/W, mob/user, params)
	. = ..()
	user.set_machine(src)
	if(W.tool_behaviour == TOOL_SCREWDRIVER||istype(W, /obj/item/encryptionkey))
		if(pai.encryptmod == TRUE)
			pai.radio.attackby(W, user, params)
		else
			to_chat(user, "Encryption Key ports not configured.")
	else if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/id_card = W
		pai.copy_access(id_card, user)

/mob/living/silicon/pai/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/id_card = W
		copy_access(id_card, user)

/mob/living/silicon/pai/proc/copy_access(obj/item/card/id/ID, mob/user)
	access_card.access += ID.access
	to_chat(user, span_info("Copied access from [ID]!"))
	to_chat(src, span_notice("Data transfer complete: New access encryption keys stored in memory."))

/mob/living/silicon/pai/Bump(atom/A) //Copied from bot.dm
	. = ..()
	if((istype(A, /obj/machinery/door/airlock) ||  istype(A, /obj/machinery/door/window)) && (!isnull(access_card)))
		var/obj/machinery/door/D = A
		if(D.check_access(access_card))
			D.open()
