/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("Smells begin to make more sense...")
	text_lose_indication = span_notice("Your sense of smell goes back to normal.")
	instability = 30
	synchronizer_coeff = 1
	
	var/datum/action/bloodsucker/olfaction/acquire_scent/lesser/smelling

/datum/mutation/human/olfaction/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(!smelling)
		smelling = new()

	if(!owner.actions.Find(smelling))
		smelling.Grant(owner)
	
/datum/mutation/human/olfaction/modify()
	if(smelling)
		smelling.sensitivity = GET_MUTATION_SYNCHRONIZER(src)

/datum/mutation/human/olfaction/on_losing(mob/living/carbon/human/owner)
	. = ..()
	smelling = locate(smelling) in owner.actions
	if(smelling)
		smelling.Remove(owner)

/obj/effect/temp_visual/scent_trail
	name = "/improper scent trail"
	icon = 'icons/effects/genetics.dmi'
	var/img_name = "smelly"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	randomdir = FALSE
	duration = 2 SECONDS
	///we cannot use icon_state bc we are invisible, this is the same thing but can be not visible
	var/image_state = "scent_trail"
	///whomst doing the sniffing, we need this because the scent lines will only be visible to them
	var/mob/living/sniffer
	///tracker image
	var/image/img

	var/datum/atom_hud/alternate_appearance/basic/scent_hunter/smell_hud

	var/scent_color

/obj/effect/temp_visual/scent_trail/Initialize(mapload, dir = SOUTH, mob/living/user, flip_icon, color)
	. = ..()
	if(user)
		sniffer = user
	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/Sniffed)
	if(!scent_color || color)
		scent_color = sanitize_hexcolor(color, 6, TRUE, COLOR_RED)
	
	var/icon/trail = icon(icon, image_state, dir)
	if(flip_icon)
		trail.Flip(dir)
		trail.Turn(180)
		
	img = image(trail, loc = src, layer = HUD_LAYER)
	img.layer = HUD_LAYER
	img.plane = HUD_PLANE
	img.appearance_flags = NO_CLIENT_COLOR
	img.alpha = 0
	img.color = sanitize_hexcolor(scent_color, 6, TRUE)
	img.name = img_name
	smell_hud = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/scent_hunter, "smelly", img, FALSE)

	animate(img, alpha = 255, time = 0.5 SECONDS, easing = EASE_IN) //fade IN

/obj/effect/temp_visual/scent_trail/proc/Sniffed(datum/source, atom/movable/AM)
	//whoever is following the trail sniffs it so hard the trail is dissipated. this is for balance reasons so you can's sit on a trail for speed boost
	if(sniffer && sniffer == AM && sniffer?.has_status_effect(STATUS_EFFECT_BLOOD_HUNTER))
		sniffer.apply_status_effect(STATUS_EFFECT_BLOODTHIRSTY)
		Destroy()

/obj/effect/temp_visual/scent_trail/Destroy()
	UnregisterSignal(src, COMSIG_MOVABLE_CROSSED)
	animate(img, alpha = 0, time = 1 SECONDS, easing = EASE_OUT) //fade out
	INVOKE_ASYNC(src, .proc/Fade)
	return ..()

/obj/effect/temp_visual/scent_trail/proc/Fade()
	sleep(1 SECONDS)
	sniffer.remove_alt_appearance("smelly")
	img = null

/datum/effect_system/trail_follow/scent
	effect_type = /obj/effect/temp_visual/scent_trail
	qdel_in_time = 20
	fade = FALSE
	nograv_required = FALSE
	var/trail_color
	///the person who made the trail exist, not the atom it's attatched to
	var/mob/living/sniffer

	var/turf/trail_step_prev
	var/turf/trail_step_current

	///It's a surprise tool that will help us later
	var/turf/trail_step_prev_prev
	var/flip = FALSE
	var/turf/vert_test
	var/turf/horiz_test

/datum/effect_system/trail_follow/scent/set_up(atom/atom, mob/living/user, color = COLOR_RED)
	. = ..()
	trail_color = sanitize_hexcolor(color, 6, TRUE, COLOR_RED)
	sniffer = user

/datum/effect_system/trail_follow/scent/generate_effect()
	if(!check_conditions())
		return stop()
	if(oldposition && !(oldposition == get_turf(holder)))
		if(!oldposition.has_gravity() || !nograv_required)
			if(trail_step_prev)
				trail_step_prev_prev = trail_step_prev
			trail_step_prev = oldposition
			trail_step_current = get_turf(holder)
			var/trail_dir = get_dir(trail_step_prev, trail_step_current)
			flip = FALSE
			vert_test = null
			horiz_test = null
			switch(trail_dir)
				if(SOUTHEAST)
					vert_test = get_step(trail_step_prev, SOUTH)
					horiz_test = get_step(trail_step_prev, EAST)
					if(!vert_test.density)
						new effect_type(vert_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = vert_test
					else if(!horiz_test.density)
						new effect_type(horiz_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = horiz_test
					 
					flip = TRUE
					trail_dir = get_dir(trail_step_prev_prev, trail_step_prev)
				if(SOUTHWEST)
					vert_test = get_step(trail_step_prev, SOUTH)
					horiz_test = get_step(trail_step_prev, WEST)
					if(!vert_test.density)
						new effect_type(vert_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = vert_test
					else if(!horiz_test.density)
						new effect_type(horiz_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = horiz_test
					flip = TRUE
					trail_dir = get_dir(trail_step_prev_prev, trail_step_prev)
				if(NORTHEAST)
					vert_test = get_step(trail_step_prev, NORTH)
					horiz_test = get_step(trail_step_prev, EAST)
					if(!vert_test.density)
						new effect_type(vert_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = vert_test
					else if(!horiz_test.density)
						new effect_type(horiz_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = horiz_test
					flip = TRUE
					trail_dir = get_dir(trail_step_prev_prev, trail_step_prev)
				if(NORTHWEST)
					vert_test = get_step(trail_step_prev, NORTH)
					horiz_test = get_step(trail_step_prev, WEST)
					if(!vert_test.density)
						new effect_type(vert_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = vert_test
					else if(!horiz_test.density)
						new effect_type(horiz_test, trail_dir, sniffer, flip, trail_color)
						trail_step_prev = horiz_test
					flip = TRUE
					trail_dir = get_dir(trail_step_prev_prev, trail_step_prev)
				else
					if(trail_step_prev_prev)
						if(get_dir(trail_step_prev_prev, trail_step_prev) != get_dir(trail_step_prev, trail_step_current) && trail_step_prev_prev.Adjacent(trail_step_current))
							trail_dir = get_dir(trail_step_prev_prev, trail_step_current)
							if(get_dir(trail_step_prev_prev, trail_step_prev) == EAST || get_dir(trail_step_prev_prev, trail_step_prev) == WEST && get_dir(trail_step_prev, trail_step_current) == NORTH || get_dir(trail_step_prev, trail_step_current) == SOUTH)
								//this is neccessary because if you get the direction while travelling horizontally, the resulting directional sprite needs to be flipped
								//travelling south and turning east gives you the correct south to east bend 
								//but travelling east and turning south gives you another south to east bend
								//if(get_dir(trail_step, trail_step_next) == NORTH || get_dir(trail_step, trail_step_next) == SOUTH)
								flip = TRUE
						else
			new effect_type(oldposition, trail_dir, sniffer, flip, trail_color)
			
	oldposition = get_turf(holder)
