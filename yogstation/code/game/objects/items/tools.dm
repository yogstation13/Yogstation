
//the new and improved jaws
/obj/item/jawsoflife
	name = "jaws of life"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a cutting head."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'

	usesound = 'sound/items/jaws_cut.ogg'
	force = 15
	toolspeed = 0.7
	tool_behaviour = TOOL_WIRECUTTER

//jaws of life suicide code
/obj/item/jawsoflife/suicide_act(mob/user)
	switch(tool_behaviour)
		if(TOOL_CROWBAR)
			user.visible_message("<span class='suicide'>[user] is putting [user.p_their()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!</span>")
			playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
			return (BRUTELOSS)
		if(TOOL_WIRECUTTER)
			user.visible_message("<span class='suicide'>[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!</span>")
			playsound(loc, 'sound/items/jaws_cut.ogg', 50, 1, -1)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
				if(BP)
					BP.drop_limb()
					playsound(loc,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
			return (BRUTELOSS)

//jaws of life changing jaw code
/obj/item/jawsoflife/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	if (tool_behaviour == TOOL_CROWBAR)
		desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a cutting head."
		if (iscyborg(user))
			to_chat(user,"<span class='notice'>Your servos whirr as the prying head reconfigures into a cutting head.</span>")
		else
			to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
		attack_verb = list("pinched", "nipped")
		icon_state = "jaws_cutter"
		hitsound = 'sound/items/jaws_cut.ogg'
		usesound = 'sound/items/jaws_cut.ogg'
		tool_behaviour = TOOL_WIRECUTTER
		update_icon()
	else if (tool_behaviour == TOOL_WIRECUTTER)
		desc = "A set of jaws of life, compressed through the magic of science. It's fitted with a prying head."
		if (iscyborg(user))
			to_chat(user,"<span class='notice'>Your servos whirr as the cutting head reconfigures into a prying head.</span>")
		else
			to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
		attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
		usesound = 'sound/items/jaws_pry.ogg'
		hitsound = 'sound/items/jaws_pry.ogg'
		tool_behaviour = TOOL_CROWBAR
		icon_state = "jaws_pry"
		update_icon()
	else
		to_chat(user,"<span class='warning'>You shouldn't be able to see this! Please contact a coder!</span>")
		playsound(get_turf(user), 'sound/effects/adminhelp.ogg', 50, 1)

/obj/item/jawsoflife/attack(mob/living/carbon/C, mob/user)
	if (tool_behaviour == TOOL_WIRECUTTER)
		if(istype(C) && C.handcuffed)
			user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
			qdel(C.handcuffed)
			return
		else
			..()
	else
		..()


//better handdrill
/obj/item/handdrill
	name = "hand drill"
	desc = "A simple powered hand drill. It's fitted with a bolt bit."
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_bolt"
	item_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25) //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.7
	tool_behaviour = TOOL_WRENCH

/obj/item/handdrill/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/handdrill/attack_self(mob/user)
	playsound(get_turf(user),'sound/items/change_drill.ogg',50,1)
	if (tool_behaviour == TOOL_SCREWDRIVER)
		if (iscyborg(user))
			to_chat(user,"<span class='notice'>Your servos whirr as the drill reconfigures into bolt mode.</span>")
		else
			to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
		desc = "A simple powered hand drill. It's fitted with a bolt bit."
		icon_state = "drill_bolt"
		item_state = "drill"
		tool_behaviour = TOOL_WRENCH
		update_icon()
	else if (tool_behaviour == TOOL_WRENCH)
		if (iscyborg(user))
			to_chat(user,"<span class='notice'>Your servos whirr as the drill reconfigures into screw mode.</span>")
		else
			to_chat(user, "<span class='notice'>You attach the screw driver bit to [src].</span>")
		desc = "A simple powered hand drill. It's fitted with a screw bit."
		icon_state = "drill_screw"
		item_state = "drill"
		tool_behaviour = TOOL_SCREWDRIVER
		update_icon()
	else
		to_chat(user,"<span class='warning'>You shouldn't be able to see this! Please contact a coder!</span>")
		playsound(get_turf(user), 'sound/effects/adminhelp.ogg', 50, 1)
