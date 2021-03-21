/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 *		Torture beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon_state = "bed"
	icon = 'icons/obj/objects.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 2
	var/bolts = TRUE

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(bolts)
		. += "<span class='notice'>It's held together by a couple of <b>bolts</b>.</span>"

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/bed/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/bed/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, "<span class='notice'>You start deconstructing [src]...</span>")
		if(W.use_tool(src, user, 40, volume=50))
			W.play_tool_sound(src)
			deconstruct(TRUE)
	else
		return ..()

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = FALSE
	resistance_flags = NONE
	var/foldabletype = /obj/item/roller

/obj/structure/bed/roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = W
		if(R.loaded)
			to_chat(user, "<span class='warning'>You already have a roller bed docked!</span>")
			return

		if(has_buckled_mobs())
			if(buckled_mobs.len > 1)
				unbuckle_all_mobs()
				user.visible_message("<span class='notice'>[user] unbuckles all creatures from [src].</span>")
			else
				user_unbuckle_mob(buckled_mobs[1],user)
		else
			R.loaded = src
			forceMove(R)
			user.visible_message("[user] collects [src].", "<span class='notice'>You collect [src].</span>")
		return 1
	else
		return ..()

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return 0
		if(has_buckled_mobs())
			return 0
		usr.visible_message("[usr] collapses \the [src.name].", "<span class='notice'>You collapse \the [src.name].</span>")
		var/obj/structure/bed/roller/B = new foldabletype(get_turf(src))
		usr.put_in_hands(B)
		qdel(src)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	density = TRUE
	icon_state = "up"
	M.pixel_y = initial(M.pixel_y)

/obj/structure/bed/roller/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/M)
	density = FALSE
	icon_state = "down"
	M.pixel_x = M.get_standard_pixel_x_offset(M.lying)
	M.pixel_y = M.get_standard_pixel_y_offset(M.lying)

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_NORMAL // No more excuses, stop getting blood everywhere

/obj/item/roller/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = I
		if(R.loaded)
			to_chat(user, "<span class='warning'>[R] already has a roller bed loaded!</span>")
			return
		user.visible_message("<span class='notice'>[user] loads [src].</span>", "<span class='notice'>You load [src] into [R].</span>")
		R.loaded = new/obj/structure/bed/roller(R)
		qdel(src) //"Load"
		return
	else
		return ..()

/obj/item/roller/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(isopenturf(target))
		deploy_roller(user, target)

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(location)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/robo //ROLLER ROBO DA!
	name = "roller bed dock"
	desc = "A collapsed roller bed that can be ejected for emergency use. Must be collected or replaced after use."
	var/obj/structure/bed/roller/loaded = null

/obj/item/roller/robo/Initialize()
	. = ..()
	loaded = new(src)

/obj/item/roller/robo/examine(mob/user)
	. = ..()
	. += "The dock is [loaded ? "loaded" : "empty"]."

/obj/item/roller/robo/deploy_roller(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message("[user] deploys [loaded].", "<span class='notice'>You deploy [loaded].</span>")
		loaded = null
	else
		to_chat(user, "<span class='warning'>The dock is empty!</span>")

//Dog bed

/obj/structure/bed/dogbed
	name = "dog bed"
	icon_state = "dogbed"
	desc = "A comfy-looking dog bed. You can even strap your pet in, in case the gravity turns off."
	anchored = FALSE
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 10
	var/mob/living/owner = null

/obj/structure/bed/dogbed/ian
	desc = "Ian's bed! Looks comfy."
	name = "Ian's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/cayenne
	desc = "Seems kind of... fishy."
	name = "Cayenne's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Renault's bed! Looks comfy. A foxy person needs a foxy pet."
	name = "Renault's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "A comfy-looking cat bed. You can even strap your pet in, in case the gravity turns off."
	name = "Runtime's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/birdboat
	desc = "A former dog bed, now covered in droppings and scratches. Ew."
	name = "Birdboat's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/proc/update_owner(mob/living/M)
	owner = M
	name = "[M]'s bed"
	desc = "[M]'s bed! Looks comfy."

/obj/structure/bed/dogbed/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	update_owner(M)

/obj/structure/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon_state = "abed"

//torture device, stretches a person strapped to it when wrenched
/obj/structure/bed/rack
	name = "torture rack"
	desc = "A contraption dating the early medieval days, designed to torture prisoners and cure dwarfism.\nUse a <b>wrench</b> to move its wheel. \n<span class='notice'>It's held together by a couple of <b>screws</b>.</span>"
	icon_state = "torture_rack"
	max_buckled_mobs = 1
	bolts = FALSE
	
/obj/structure/bed/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER && !(flags_1&NODECONSTRUCT_1))
		to_chat(user, "<span class='notice'>You start deconstructing [src]...</span>")
		if(W.use_tool(src, user, 40, volume=50))
			W.play_tool_sound(src)
			deconstruct(TRUE)
	else if (W.tool_behaviour == TOOL_WRENCH)
		if(!has_buckled_mobs())
			to_chat(user, "<span class='notice'>You move the [src] wheel with ease, there's nobody strapped onto it!</span>")
			W.play_tool_sound(src)
		else
			var/mob/living/carbon/human/H = buckled_mobs[1]
			to_chat(user, "<span class='notice'>You begin to stretch [H] on the [src]...</span>")
			if(W.use_tool(src, user, 40, volume=120))
				W.play_tool_sound(src)
				var/obj/item/bodypart/LL = H.get_bodypart(BODY_ZONE_L_LEG)
				var/obj/item/bodypart/RL = H.get_bodypart(BODY_ZONE_R_LEG)
				var/obj/item/bodypart/LA = H.get_bodypart(BODY_ZONE_L_ARM)
				var/obj/item/bodypart/RA = H.get_bodypart(BODY_ZONE_R_ARM)
				
				if(!LL && !RL) //can't stretch without at least one leg
					return
				if(!LA && !RA) //neither without an arm
					return
				
				if(LL)
					H.apply_damage(rand(5,10), BRUTE, LL)
					if(prob(5))
						LL.dismember()
				if(RL)
					H.apply_damage(rand(5,10), BRUTE, RL)
					if(prob(5))
						RL.dismember()
				if(LA)
					H.apply_damage(rand(5,10), BRUTE, LA)
					if(prob(5))
						LA.dismember()
				if(RA)
					H.apply_damage(rand(5,10), BRUTE, RA)
					if(prob(5))
						RA.dismember()
				H.emote("scream")
				H.transform = H.transform.Scale(1.04, 1) //STREETCH, not by much so people can't get ridiculously long
	else
		return ..()
