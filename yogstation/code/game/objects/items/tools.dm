
//the new and improved jaws
/obj/item/jawsoflife
	name = "jaws of life"
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
	materials = list(/datum/material/iron=150,/datum/material/silver=50,/datum/material/titanium=25)
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.7
	tool_behaviour = TOOL_CROWBAR
	var/pryforce = 1 // the speed at which airlocks are pried open. Default is 1 .

//jaws of life changing jaw code
/obj/item/jawsoflife/attack_self(mob/user)
	if (tool_behaviour == TOOL_CROWBAR)
		transform_cutters(user)
	else
		transform_crowbar(user)

//jaws of life suicide code
/obj/item/jawsoflife/suicide_act(mob/user)
	switch(tool_behaviour)
		if(TOOL_CROWBAR)
			user.visible_message(span_suicide("[user] is putting [user.p_their()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!"))
			playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
		if(TOOL_WIRECUTTER)
			user.visible_message(span_suicide("[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!"))
			playsound(loc, 'sound/items/jaws_cut.ogg', 50, 1, -1)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
				if(BP)
					BP.drop_limb()
					playsound(loc,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
	return (BRUTELOSS)

/obj/item/jawsoflife/attack(mob/living/carbon/C, mob/user)
	if (tool_behaviour == TOOL_WIRECUTTER)
		if(istype(C) && C.handcuffed)
			user.visible_message(span_notice("[user] cuts [C]'s restraints with [src]!"))
			qdel(C.handcuffed)
			return
		else
			..()
	else
		..()

/obj/item/jawsoflife/proc/transform_crowbar(mob/user)
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	usesound = 'sound/items/jaws_pry.ogg'
	hitsound = 'sound/items/jaws_pry.ogg'
	tool_behaviour = TOOL_CROWBAR
	icon_state = "jaws_pry"
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	if (iscyborg(user))
		to_chat(user,span_notice("Your servos whirr as the cutting head reconfigures into a prying head."))
	else
		to_chat(user, span_notice("You attach the pry jaws to [src]."))
	update_icon()

/obj/item/jawsoflife/proc/transform_cutters(mob/user)
	attack_verb = list("pinched", "nipped")
	icon_state = "jaws_cutter"
	hitsound = 'sound/items/jaws_cut.ogg'
	usesound = 'sound/items/jaws_cut.ogg'
	tool_behaviour = TOOL_WIRECUTTER
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a cutting head."
	if (iscyborg(user))
		to_chat(user,span_notice("Your servos whirr as the prying head reconfigures into a cutting head."))
	else
		to_chat(user, span_notice("You attach the cutting jaws to [src]."))
	update_icon()

//better handdrill
/obj/item/handdrill
	name = "hand drill"
	desc = "A simple powered hand drill. It's fitted with a screw bit."
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_screw"
	item_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(/datum/material/iron=150,/datum/material/silver=50,/datum/material/titanium=25) //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.7
	tool_behaviour = TOOL_SCREWDRIVER
	sharpness = SHARP_POINTY

/obj/item/handdrill/attack_self(mob/user)
	if (tool_behaviour == TOOL_SCREWDRIVER)
		transform_wrench(user)
	else
		transform_screwdriver(user)

/obj/item/handdrill/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!"))
	return(BRUTELOSS)

/obj/item/handdrill/proc/transform_wrench(mob/user)
	desc = "A simple powered hand drill. It's fitted with a bolt bit."
	icon_state = "drill_bolt"
	tool_behaviour = TOOL_WRENCH
	sharpness = SHARP_NONE
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	if (iscyborg(user))
		to_chat(user,span_notice("Your servos whirr as the drill reconfigures into bolt mode."))
	else
		to_chat(user, span_notice("You attach the bolt driver bit to [src]."))
	update_icon()

/obj/item/handdrill/proc/transform_screwdriver(mob/user)
	desc = "A simple powered hand drill. It's fitted with a screw bit."
	icon_state = "drill_screw"
	tool_behaviour = TOOL_SCREWDRIVER
	sharpness = SHARP_POINTY
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	if (iscyborg(user))
		to_chat(user,span_notice("Your servos whirr as the drill reconfigures into screw mode."))
	else
		to_chat(user, span_notice("You attach the screw driver bit to [src]."))
	update_icon()

/obj/item/jawsoflife/jimmy
	name = "airlock jimmy"
	desc = "A pump assisted airlock prying jimmy."
	icon_state = "jimmy"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(MAT_METAL=400,MAT_SILVER=10,MAT_TITANIUM=80)
	toolspeed = 0.3 // Starting minimum value. Pump it up by using it up to the max
	tool_behaviour = TOOL_CROWBAR
	pryforce = 0.4
	var/pump_charge = 0
	var/pump_max = 100
	var/pump_min = 0
	var/pump_cost = 50 // the cost to pump best if done in incriments of 25 up to the max
	var/pump_rate = 25
	var/is_pumping = FALSE // are we charging at the moment?
	
/obj/item/jawsoflife/jimmy/attack_self(mob/user) // airlock jimmy can't switch tool modes back to cutters.
	if(user)
		pump(user)
		show_gage(user)
	
/obj/item/jawsoflife/jimmy/proc/pump(mob/user)
	if(pump_charge >= pump_max && user)
		to_chat(user,"[src] is fully pumped.")
	else
		if(!is_pumping)
			var/old_value = pump_charge
			is_pumping = TRUE
			pump_charge = (pump_charge + pump_rate) > pump_max ? pump_max : pump_charge + pump_rate
			if(old_value != pump_charge)
				playsound(src, 'sound/items/jimmy_pump.ogg', 100, TRUE) // no need you pump; didn't pump but instead looked at the gage
				addtimer(CALLBACK(src, .proc/pump_cooldown), 5) // cooldown between pumps
				addtimer(CALLBACK(src, .proc/pump_powerdown), 300) // lose gained power after 30 seconds
	return

/obj/item/jawsoflife/jimmy/proc/pump_powerdown(mob/user)
	if((pump_charge - 25) >= 0)
		pump_charge = pump_charge - 25
	return

/obj/item/jawsoflife/jimmy/proc/show_gage(mob/user)
	var/emag_givaway_flavor = ""
	if(pump_charge > 101)
		emag_givaway_flavor = pick("somehow","unironically","ironically","actually","maybe")
	to_chat(user,"[src]'s pressure gage [emag_givaway_flavor] reads [pump_charge]%")

/obj/item/jawsoflife/jimmy/proc/pump_cooldown()
	is_pumping = FALSE

/obj/item/jawsoflife/jimmy/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("Nothing new seems to happen when you swipe the emag."))
		return
	to_chat(user, span_notice("You swipe the emag on [src]'s pressure gage' enabling you to pump more pressure. "))
	obj_flags |= EMAGGED
	pump_max = 150
	pump_cost = 75
	. = ..()

/obj/item/jawsoflife/jimmy/examine(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		. += span_danger("The pressure gage has been tampered with.")
	if(user)
		show_gage(user)
