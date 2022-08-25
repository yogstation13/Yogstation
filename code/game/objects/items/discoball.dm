/obj/item/discoballdeployer
	name = "Portable Disco Ball"
	desc = "Press the button to launch a small party!!"
	icon = 'icons/obj/device.dmi'
	icon_state = "ethdisco"

/obj/item/discoballdeployer/attack_self(mob/living/carbon/user)
	.=..()
	to_chat(user, span_notice("You deploy the Disco Ball."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
	new /obj/structure/discoball(user.loc)
	qdel(src)

/obj/structure/discoball
	name = "Disco Ball"
	desc = "This is an improved portable disco ball model. Use wrench to undeploy."
	icon = 'icons/obj/device.dmi'
	icon_state = "disco_0"
	anchored = TRUE
	density = TRUE
	var/TurnedOn = FALSE
	var/current_color
	var/TimerID
	var/range = 7
	var/power = 3
	var/list/spotlights = list()
	var/list/sparkles = list()

/obj/structure/discoball/Initialize()
	. = ..()
	update_icon()

/obj/structure/discoball/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(TurnedOn)
		TurnOff()
	else 
		TurnOn()

/obj/structure/discoball/proc/TurnOn()
	var/mob/living/user = usr
	to_chat(user, span_notice("You turn on the disco ball."))
	TurnedOn = TRUE //Same
	DiscoFever()
	dance_setup()
	lights_spin()

/obj/structure/discoball/proc/TurnOff()
	var/mob/living/user = usr
	to_chat(user, span_notice("You turn off the disco ball."))
	TurnedOn = FALSE
	set_light(0)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_icon()
	if(TimerID)
		deltimer(TimerID)
	over()

/obj/structure/discoball/Destroy() //delete lights if destroyed
	over()
	return ..()

/obj/structure/discoball/proc/over()
	QDEL_LIST(spotlights)
	QDEL_LIST(sparkles)

/obj/structure/discoball/proc/DiscoFever()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	current_color = random_color()
	set_light(range, power, current_color)
	add_atom_colour("#[current_color]", FIXED_COLOUR_PRIORITY)
	update_icon()
	TimerID = addtimer(CALLBACK(src, .proc/DiscoFever), 5, TIMER_STOPPABLE)  //Call ourselves every 0.5 seconds to change colors

/obj/structure/discoball/update_icon()
	cut_overlays()
	icon_state = "disco_[TurnedOn]"
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "ethdisco_base")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)

/obj/structure/discoball/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!TurnedOn)	
		to_chat(user, span_notice("You undeploy the Disco Ball."))
		playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		new /obj/item/discoballdeployer(user.loc)
		qdel(src)
		return TRUE
	else
		to_chat(user, span_notice("Cannot undeploy if active."))
		return TRUE

/** 
 * im literally copying shit from radiant mk IV
 * :(
*/

/obj/structure/discoball/proc/dance_setup()
	var/turf/cen = get_turf(src)
	FOR_DVIEW(var/turf/t, 3, get_turf(src),INVISIBILITY_LIGHTING)
		if(t.x == cen.x && t.y > cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_RED
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x == cen.x && t.y < cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_PURPLE
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x > cen.x && t.y == cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_YELLOW
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if(t.x < cen.x && t.y == cen.y)
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_GREEN
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y+1 == cen.y) || (t.x+2==cen.x && t.y+2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_ORANGE
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y-1 == cen.y) || (t.x-2==cen.x && t.y-2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_CYAN
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x-1 == cen.x && t.y+1 == cen.y) || (t.x-2==cen.x && t.y+2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_BLUEGREEN
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		if((t.x+1 == cen.x && t.y-1 == cen.y) || (t.x+2==cen.x && t.y-2 == cen.y))
			var/obj/item/flashlight/spotlight/L = new /obj/item/flashlight/spotlight(t)
			L.light_color = LIGHT_COLOR_BLUE
			L.light_power = 30-(get_dist(src,L)*8)
			L.range = 1.4+get_dist(src, L)
			spotlights+=L
			continue
		continue
	FOR_DVIEW_END

/obj/structure/discoball/proc/hierofunk()
	for(var/i in 1 to 10)
		spawn_atom_to_turf(/obj/effect/temp_visual/hierophant/telegraph/edge, src, 1, FALSE)
		sleep(0.5 SECONDS)

#define DISCO_INFENO_RANGE (rand(85, 115)*0.01)

/obj/structure/discoball/proc/lights_spin()
	for(var/i in 1 to 25)
		if(QDELETED(src) || !TurnedOn)
			return
		var/obj/effect/overlay/sparkles/S = new /obj/effect/overlay/sparkles(src)
		S.alpha = 0
		sparkles += S
		switch(i)
			if(1 to 8)
				S.orbit(src, 30, TRUE, 60, 36, TRUE)
			if(9 to 16)
				S.orbit(src, 62, TRUE, 60, 36, TRUE)
			if(17 to 24)
				S.orbit(src, 95, TRUE, 60, 36, TRUE)
			if(25)
				S.pixel_y = 7
				S.forceMove(get_turf(src))
		sleep(0.7 SECONDS)
	for(var/obj/reveal in sparkles)
		reveal.alpha = 255
	while(TurnedOn)
		for(var/obj/item/flashlight/spotlight/glow in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(QDELETED(src) || !TurnedOn || QDELETED(glow))
				return
			if(glow.light_color == LIGHT_COLOR_RED)
				glow.light_color = LIGHT_COLOR_BLUE
				glow.light_power = glow.light_power * 1.48
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_BLUE)
				glow.light_color = LIGHT_COLOR_GREEN
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.light_power = glow.light_power * 2 // Any changes to power must come in pairs to neutralize it for other colors
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_GREEN)
				glow.light_color = LIGHT_COLOR_ORANGE
				glow.light_power = glow.light_power * 0.5
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_ORANGE)
				glow.light_color = LIGHT_COLOR_PURPLE
				glow.light_power = glow.light_power * 2.27
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_PURPLE)
				glow.light_color = LIGHT_COLOR_BLUEGREEN
				glow.light_power = glow.light_power * 0.44
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_BLUEGREEN)
				glow.light_color = LIGHT_COLOR_YELLOW
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_YELLOW)
				glow.light_color = LIGHT_COLOR_CYAN
				glow.light_range = 0
				glow.update_light()
				continue
			if(glow.light_color == LIGHT_COLOR_CYAN)
				glow.light_color = LIGHT_COLOR_RED
				glow.light_power = glow.light_power * 0.68
				glow.light_range = glow.range * DISCO_INFENO_RANGE
				glow.update_light()
				continue
		if(prob(2))  // Unique effects for the dance floor that show up randomly to mix things up
			INVOKE_ASYNC(src, .proc/hierofunk)
		sleep(0.5 SECONDS)

#undef DISCO_INFENO_RANGE

