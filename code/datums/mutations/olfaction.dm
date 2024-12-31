/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("Smells begin to make more sense...")
	text_lose_indication = span_notice("Your sense of smell goes back to normal.")
	instability = 30
	synchronizer_coeff = 1
	
	var/datum/action/cooldown/spell/olfaction/acquire_scent/smelling

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
	if(!scent_color || color)
		scent_color = sanitize_hexcolor(color, 6, TRUE, COLOR_RED)
	
	var/icon/trail = icon(icon, image_state, dir)
	if(flip_icon)
		trail.Flip(dir)
		trail.Turn(180)
		
	img = image(trail, loc = src)
	img.plane = HUD_PLANE
	img.appearance_flags = NO_CLIENT_COLOR
	img.alpha = 0
	img.color = sanitize_hexcolor(scent_color, 6, TRUE)
	img.name = img_name
	smell_hud = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/scent_hunter, "smelly", img, FALSE)

	animate(img, alpha = 255, time = 0.5 SECONDS, easing = EASE_IN) //fade IN

/obj/effect/temp_visual/scent_trail/Destroy()
	animate(img, alpha = 0, time = 1 SECONDS, easing = EASE_OUT) //fade out
	INVOKE_ASYNC(src, PROC_REF(Fade))
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
			new effect_type(oldposition, trail_dir, sniffer, flip, trail_color)
			
	oldposition = get_turf(holder)


#define TRACKING_SCENT			(1<<0)
#define TRACKING_BLOOD			(1<<1)

/datum/action/cooldown/spell/olfaction
	name = "Sanguine Olfaction"
	desc = "Olfaction:\n\
		Here's the sniffer.\n\
		You shouldn't see this text, please scream and cry in the discord chat or ooc about it after the round if you do.\n\
		Or make a bug report."
	button_icon_state = "power_olfac"
	spell_requirements = null
	cooldown_time = 20 SECONDS

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Aquiring a new scent-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/olfaction/acquire_scent
	name = "Transcendent Olfaction"
	desc = "Acquire a scent from the environment immediately around you to track."

	buttontooltipstyle = ""
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_spell"
	active_background_icon_state = "bg_spell"
	base_background_icon_state = "bg_spell"
	
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"

	cooldown_time = 60 SECONDS

	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()
	
	///the coefficient for disgust stacks and gauging if the air is miasma free enough. synchronizer chromo makes it more miasma tolerant for genetics olfaction
	var/sensitivity = 1
	///whether or not to even check for miasma in the air.
	var/sensitive = TRUE
	///tracking blood or scents. scent for genetics olfaction, blood if we want that
	var/tracking_flags = TRACKING_SCENT

	var/datum/action/cooldown/spell/olfaction/follow_scent/follow = new /datum/action/cooldown/spell/olfaction/follow_scent()

/datum/action/cooldown/spell/olfaction/acquire_scent/Grant(mob/user, tracking)
	. = ..()
	if(!iscarbon(user))
		to_chat(owner, span_warning("Your olfactory senses aren't developed enough to utilize this ability!"))
		qdel(src)
		return
	if(tracking)
		tracking_flags = tracking

/datum/action/cooldown/spell/olfaction/acquire_scent/cast(atom/cast_on)
	. = ..()
	var/datum/gas_mixture/air = owner.loc.return_air()
	if(air.get_moles(GAS_MIASMA) >= 0.1/sensitivity && sensitive)
		owner.adjust_disgust(sensitivity * 45)
		to_chat(owner, span_warning("With your overly sensitive nose, you get a whiff of stench and feel sick! Try moving to a cleaner area!"))
		return
	
	var/old_target = tracking_target
	possible = list()

	var/list/blood_samples = list()
	var/list/scents = list()
	for(var/obj/samples in range(1, owner))
		if(tracking_flags & TRACKING_BLOOD)
			blood_samples |= samples.return_blood_DNA()
		if(tracking_flags & TRACKING_SCENT)
			scents |= samples.return_scents()
	for(var/mob/living/carbon/C in GLOB.carbon_list)
		if(blood_samples.Find(C.dna.unique_enzymes) && !possible.Find(C))
			possible |= C
		if(scents[md5(C.dna.unique_identity)] && !possible.Find(C))
			var/datum/job/J = SSjob.GetJob(C.job)
			if(!J)
				J = new()
			var/stink_string = "[J.smells_like] and [C.dna.species.smells_like]"
			possible |= stink_string
			possible[stink_string] = C
	
	if(!length(possible))
		to_chat(owner,span_warning("Despite your best efforts, there are no scents to be found here"))
		return
	tracking_target = tgui_input_list(owner, "Choose a scent to focus in on.", "Scent Tracking", possible)
	if(tracking_flags & TRACKING_SCENT)
		tracking_target = possible[tracking_target]
	if(!tracking_target)
		to_chat(owner,span_warning("You decide against focusing on any scents. Instead, you notice your own nose in your peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was."))
		return
	
	if(tracking_target == owner)
		to_chat(owner,span_warning("Wait a minute, this scent is familiar. Too familiar. It's yours."))
		return
	
	if(tracking_target == old_target)
		to_chat(owner,span_warning("Wait a minute, this is the same scent as before."))
		return
	
	if(!follow)
		follow = new()

	if(!owner.actions.Find(follow))
		follow.Grant(owner)
	
	follow = locate(follow) in owner.actions
	
	follow.tracking_target = tracking_target
	
	return TRUE

/datum/action/cooldown/spell/olfaction/acquire_scent/Remove(mob/M)	
	follow = locate(follow) in owner.actions
	if(follow)
		follow.Remove(owner)
	return ..()


////////////////////////////////////////////////////////////////////////////////////
//--------------------------Following the aquired scent---------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/olfaction/follow_scent
	name = "Follow the Scent"
	desc = "Begin following the scent of your target."
	buttontooltipstyle = ""
	
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_spell"
	active_background_icon_state = "bg_spell"
	base_background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"

	cooldown_time = 60 SECONDS

	var/mob/living/carbon/sniffer
	var/mob/living/carbon/tracking_target
	///which status effect is being applied on use
	var/status_effect = STATUS_EFFECT_SCENT_HUNTER

/datum/action/cooldown/spell/olfaction/follow_scent/Grant(mob/user, tracking)
	. = ..()
	if(!iscarbon(user))
		to_chat(owner, span_warning("Your olfactory senses aren't developed enough to utilize this ability!"))
		qdel(src)
		return
	sniffer = user
	if(tracking)
		tracking_target = tracking

/datum/action/cooldown/spell/olfaction/follow_scent/cast(atom/cast_on)
	. = ..()
	if(!tracking_target)
		to_chat(owner, span_warning("You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug."))
		return
	if(tracking_target == owner)
		to_chat(owner,span_warning("You smell out the trail to yourself. Yep, it's you."))
		return
	var/turf/pos = get_turf(tracking_target)
	if(usr.z < pos.z)
		to_chat(owner,span_warning("The trail leads... way up above you? Huh. They must be really, really far away."))
		return
	else if(usr.z > pos.z)
		to_chat(owner,span_warning("The trail leads... way down below you? Huh. They must be really, really far away."))
		return

	var/access_card = new /obj/item/card/id/captains_spare()
	var/list/trail = get_path_to(owner, get_turf(pos), /turf/proc/Distance_cardinal, 0, 0, 0, /turf/proc/reachableTurftest, access_card, simulated_only = FALSE, get_best_attempt = TRUE)
	
	if(!trail || trail.len <= 2)
		to_chat(owner,span_warning("You can't get a good read on the trail, maybe you should try again from a different spot."))
		return

	var/scent_color
	//if there's no scent color we will use the tracked target's mutant_color from their dna, provided it's of a vibrant enough color to see
	if(iscarbon(tracking_target))
		var/mob/living/carbon/carbon_target = tracking_target
		if(round((ReadHSV(RGBtoHSV(carbon_target.dna.features["mcolor"]))[2]/255)*100) > 40)
			var/mcolor = carbon_target.dna.features["mcolor"]
			if(length(mcolor) < 6)
				mcolor = repeat_string(2, mcolor[1]) + repeat_string(2, mcolor[2])+repeat_string(2, mcolor[3])
			scent_color = sanitize_hexcolor(mcolor, 6, TRUE)
	
	if(ishuman(tracking_target) && !scent_color)
		var/mob/living/carbon/human/human_target = tracking_target
		if(round((ReadHSV(RGBtoHSV(human_target.eye_color))[2]/255)*100) > 40)
			var/eyecolor = human_target.eye_color
			if(length(eyecolor) < 6)
				eyecolor = repeat_string(2, eyecolor[1]) + repeat_string(2, eyecolor[2])+repeat_string(2, eyecolor[3])
			scent_color = sanitize_hexcolor(eyecolor, 6, TRUE)
	if(!scent_color)
		scent_color = sanitize_hexcolor(pick(COLOR_RED, COLOR_ORANGE, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE), 6, TRUE)
	if(status_effect == STATUS_EFFECT_BLOOD_HUNTER)
		scent_color = COLOR_RED
	sniffer.apply_status_effect(status_effect, tracking_target, scent_color)
	for(var/i in 1 to (trail.len))
		var/turf/trail_step = trail[i]
		var/turf/trail_step_prev
		var/turf/trail_step_next
		var/invert = FALSE

		var/scent_dir
		if (i == 1)
			//if we're at the beginning of the list, we'll skip the first location because otherwise the starting scent spawns on top of you instead of in front
			continue
		else if (i == trail.len)
			//if we're at the end of the list, we'll determine the orientation of the last sprite by using the previous location
			trail_step_prev = trail[i-1]
			scent_dir = get_dir(trail_step_prev, trail_step)
		else
			//we're not at the end of the list so we're going to use the next and previous location to determine sprite orientation
			trail_step_prev = trail[i-1]
			trail_step_next = trail[i+1]
			if(get_dir(trail_step_prev, trail_step) == EAST || get_dir(trail_step_prev, trail_step) == WEST && get_dir(trail_step, trail_step_next) == NORTH || get_dir(trail_step, trail_step_next) == SOUTH)
				//this is neccessary because if you get the direction while travelling horizontally, the resulting directional sprite needs to be flipped
				//travelling south and turning east gives you the correct south to east bend 
				//but travelling east and turning south gives you another south to east bend
				invert = TRUE
				scent_dir = get_dir(trail_step_next, trail_step_prev)
			else
				scent_dir = get_dir(trail_step_prev, trail_step_next)
			scent_dir = get_dir(trail_step_prev, trail_step_next)
		
		if((locate(/obj/structure/falsewall) in get_turf(trail_step)))
			continue
		new /obj/effect/temp_visual/scent_trail(trail_step, scent_dir, sniffer, invert, scent_color)
		sleep(0.1 SECONDS)
