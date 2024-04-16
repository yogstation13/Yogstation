/obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	materials = list(/datum/material/iron=500, /datum/material/glass=500)
	w_class = WEIGHT_CLASS_SMALL
	var/turf/pointer_loc
	var/charges = 5
	var/max_charges = 5
	var/effectchance = 33
	///Icon for the laser, affects both the laser dot and the laser pointer itself, as it shines a laser on the item itself
	var/pointer_icon_state = null
	///The diode is what determines the effectiveness and recharge rate of the laser pointer. Higher tier part means stronger pointer
	var/obj/item/stock_parts/micro_laser/diode 
	var/diode_type = /obj/item/stock_parts/micro_laser
	COOLDOWN_DECLARE(recharging)
	var/recharge_rate = 30 SECONDS

/obj/item/laser_pointer/red
	pointer_icon_state = "red_laser"
/obj/item/laser_pointer/green
	pointer_icon_state = "green_laser"
/obj/item/laser_pointer/blue
	pointer_icon_state = "blue_laser"
/obj/item/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/laser_pointer/Initialize(mapload)
	. = ..()
	if(!diode_type)
		diode = /obj/item/stock_parts/micro_laser
	diode = new diode_type
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")
	RefreshParts()

/obj/item/laser_pointer/upgraded
	diode_type = /obj/item/stock_parts/micro_laser/ultra

/obj/item/laser_pointer/attackby(obj/item/item_used, mob/user, params)
	if(istype(item_used, /obj/item/stock_parts/micro_laser))
		if(!diode)
			if(!user.transferItemToLoc(item_used, src))
				return
			diode = item_used
			to_chat(user, span_notice("You install a [diode.name] in [src]."))
			RefreshParts()
		else
			to_chat(user, span_notice("[src] already has a diode installed."))

	else if(item_used.tool_behaviour == TOOL_SCREWDRIVER)
		if(diode)
			to_chat(user, span_notice("You remove the [diode.name] from \the [src]."))
			diode.forceMove(drop_location())
			diode = null
	else
		return ..()

/obj/item/laser_pointer/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!diode)
			. += span_notice("The diode is missing.")
		else
			. += span_notice("A class [span_bold("[diode.rating]")] laser diode is installed. It is [span_italics("screwed")] in place.")
			. += span_notice("It currently has [span_bold("[charges]/[max_charges]")] charges and generates a charge every [span_bold("[recharge_rate/10] seconds")].")

/obj/item/laser_pointer/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	laser_act(target, user, params)

/obj/item/laser_pointer/proc/laser_act(atom/target, mob/living/user, params)
	if( !(user in (viewers(7,target))) )
		return
	if (!diode)
		to_chat(user, span_notice("You point [src] at [target], but nothing happens!"))
		return
	if (!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	if(HAS_TRAIT(user, TRAIT_NOGUNS))
		to_chat(user, span_warning("Your fingers can't press the button!"))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna.check_mutation(HULK))
			to_chat(user, span_warning("Your fingers can't press the button!"))
			return

	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(charges<=0)
		to_chat(user, span_notice("You point [src] at [target], but it needs more time to recharge."))
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == BODY_ZONE_PRECISE_EYES)
			log_combat(user, C, "shone in the eyes", src)

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//chance to actually hit the eyes depends on internal component
			if(prob(effectchance * diode.rating) && C.flash_act(severity))
				outmsg = span_notice("You blind [C] by shining [src] in [C.p_their()] eyes.")
				for(var/datum/brain_trauma/trauma in C.get_traumas())
					trauma.on_shine_laser(user, C)
			else
				outmsg = span_warning("You fail to blind [C] by shining [src] at [C.p_their()] eyes!")

	//robots
	else if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		log_combat(user, R, "shone in the sensors", src)
		//chance to actually hit the eyes depends on internal component
		if(prob(effectchance * diode.rating))
			R.overlay_fullscreen("laserpointer", /atom/movable/screen/fullscreen/flash/static)
			R.uneq_all()
			R.stop_pulling()
			R.break_all_cyborg_slots(TRUE)
			addtimer(CALLBACK(R, TYPE_PROC_REF(/mob/living/silicon/robot, clear_fullscreen), "laserpointer"), 7 SECONDS)
			addtimer(CALLBACK(R, TYPE_PROC_REF(/mob/living/silicon/robot, repair_all_cyborg_slots)), 7 SECONDS)
			to_chat(R, span_danger("Your sensors were overloaded by a laser!"))
			outmsg = span_notice("You overload [R] by shining [src] at [R.p_their()] sensors.")
		else
			outmsg = span_warning("You fail to overload [R] by shining [src] at [R.p_their()] sensors!")

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(EMP_HEAVY)
			outmsg = span_notice("You hit the lens of [C] with [src], temporarily disabling the camera!")
			log_combat(user, C, "EMPed", src)
		else
			outmsg = span_warning("You miss the lens of [C] with [src]!")

	//catpeople
	for(var/mob/living/carbon/human/H in view(1,targloc))
		if(!iscatperson(H) || H.incapacitated() || H.eye_blind )
			continue
		if(user.mobility_flags & MOBILITY_STAND)
			H.setDir(get_dir(H,targloc)) // kitty always looks at the light
			if(prob(effectchance))
				H.visible_message(span_warning("[H] makes a grab for the light!"),span_userdanger("LIGHT!"))
				H.Move(targloc)
				log_combat(user, H, "moved with a laser pointer",src)
			else
				H.visible_message(span_notice("[H] looks briefly distracted by the light."),"<span class = 'warning'> You're briefly tempted by the shiny light... </span>")
		else
			H.visible_message(span_notice("[H] stares at the light"),"<span class = 'warning'> You stare at the light... </span>")

	//cats!
	for(var/mob/living/simple_animal/pet/cat/C in view(1,targloc))
		if(prob(50))
			C.visible_message(span_notice("[C] pounces on the light!"),span_warning("LIGHT!"))
			C.Move(targloc)
			C.set_resting(TRUE, FALSE)
		else
			C.visible_message(span_notice("[C] looks uninterested in your games."),span_warning("You spot [user] shining [src] at you. How insulting!"))

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	//setup pointer blip
	var/mutable_appearance/laser = mutable_appearance('icons/obj/projectiles.dmi', pointer_icon_state)
	var/list/modifiers = params2list(params)
	if(modifiers)
		if(LAZYACCESS(modifiers, ICON_X))
			laser.pixel_x = (text2num(LAZYACCESS(modifiers, ICON_X)) - 16)
		if(LAZYACCESS(modifiers, ICON_Y))
			laser.pixel_y = (text2num(LAZYACCESS(modifiers, ICON_Y)) - 16)
	else
		laser.pixel_x = target.pixel_x + rand(-5,5)
		laser.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		to_chat(user, outmsg)
	else
		to_chat(user, span_info("You point [src] at [target]."))
	
	//start the recharge cooldown after using the first of your charges
	if(charges == max_charges)
		COOLDOWN_START(src, recharging, recharge_rate)
	charges -= 1
	
	if(charges <= max_charges)
		START_PROCESSING(SSobj, src)

	//flash a pointer blip at the target
	target.flick_overlay_view(laser, 1 SECONDS)
	//reset pointer sprite
	icon_state = "pointer"

/obj/item/laser_pointer/process(delta_time)
	//it probably shouldn't be charging if the laser pointer is missing pieces 
	if(!diode)
		return PROCESS_KILL
	//if the current recharge isn't done stop here
	if(!COOLDOWN_FINISHED(src, recharging))
		return
	//recharge period has finished here's your charge
	charges += 1
	//just to make sure the rating hasn't somehow changed like from var edit fuckery to adjust the cooldown time
	RefreshParts()
	COOLDOWN_START(src, recharging, recharge_rate)
	if(charges >= max_charges)
		charges = max_charges
		//I'M FULLY CHARGED so we don't need to keep running this process
		return PROCESS_KILL
		
/obj/item/laser_pointer/proc/RefreshParts()
	///The rate at which the laser regenerates charge. Clamped between 30 seconds and basically instantly just in case of weirdness. Knock off 5 seconds per diode rating
	recharge_rate = clamp((30 SECONDS - (5 SECONDS * diode.rating)), 1, 30 SECONDS)
