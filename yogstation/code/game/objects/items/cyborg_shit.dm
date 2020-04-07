//i fucking hate my life
/obj/item/cyborg/jawsoflife
	name = "cyborg jaws of life"
	icon = 'icons/obj/tools.dmi'
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.7
	tool_behaviour = TOOL_CROWBAR

/obj/item/cyborg/jawsoflife/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	if (tool_behaviour == TOOL_CROWBAR)
		desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a cutting head."
		to_chat(user,"<span class='notice'>Your servos whirr as the prying head reconfigures into a cutting head.</span>")
		attack_verb = list("pinched", "nipped")
		icon_state = "jaws_cutter"
		hitsound = 'sound/items/jaws_cut.ogg'
		usesound = 'sound/items/jaws_cut.ogg'
		tool_behaviour = TOOL_WIRECUTTER
		update_icon()
	else if (tool_behaviour == TOOL_WIRECUTTER)
		desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
		to_chat(user,"<span class='notice'>Your servos whirr as the cutting head reconfigures into a prying head.</span>")
		attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
		usesound = 'sound/items/jaws_pry.ogg'
		hitsound = 'sound/items/jaws_pry.ogg'
		tool_behaviour = TOOL_CROWBAR
		icon_state = "jaws_pry"
		update_icon()
	else
		to_chat(user,"<span class='warning'>You shouldn't be able to see this! Please contact a coder!</span>")
		playsound(get_turf(user), 'sound/effects/adminhelp.ogg', 50, 1)

//shitcode time
/obj/item/cyborg/handdrill
	name = "hand drill"
	desc = "A simple powered hand drill. It's fitted with a screw bit."
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_screw"
	item_state = "drill"
	force = 8 //might or might not be too high, subject to change
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.7
	tool_behaviour = TOOL_SCREWDRIVER

/obj/item/cyborg/handdrill/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	if (tool_behaviour == TOOL_SCREWDRIVER)
		to_chat(user,"<span class='notice'>Your servos whirr as the drill reconfigures into bolt mode.</span>")
		desc = "A simple powered hand drill. It's fitted with a bolt bit."
		icon_state = "drill_bolt"
		item_state = "drill"
		tool_behaviour = TOOL_WRENCH
		update_icon()
	else if (tool_behaviour == TOOL_WRENCH)
		to_chat(user,"<span class='notice'>Your servos whirr as the drill reconfigures into screw mode.</span>")
		desc = "A simple powered hand drill. It's fitted with a screw bit."
		icon_state = "drill_screw"
		item_state = "drill"
		tool_behaviour = TOOL_SCREWDRIVER
		update_icon()
	else
		to_chat(user,"<span class='warning'>You shouldn't be able to see this! Please contact a coder!</span>")
		playsound(get_turf(user), 'sound/effects/adminhelp.ogg', 50, 1)