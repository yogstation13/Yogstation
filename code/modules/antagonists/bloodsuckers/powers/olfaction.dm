#define TRACKING_SCENT			(1<<0)
#define TRACKING_BLOOD			(1<<1)

/datum/action/bloodsucker/olfaction
	name = "Sanguine Olfaction"
	desc = "Smells blood."
	button_icon_state = "power_olfac"
	power_explanation = "<b>Olfaction</b>:\n\
		Here's the sniffer.\n\
		You shouldn't see this text, please scream and cry in the discord chat or ooc about it after the round if you do.\n\
		Or make a bug report."
	power_flags = BP_AM_STATIC_COOLDOWN
	cooldown = 20 SECONDS

/datum/action/bloodsucker/olfaction/acquire_scent
	name = "Sanguine Olfaction"
	desc = "Acquire a scent from the environment immediately around you to track."
	power_explanation = "<b>Sanguine Olfaction</b>:\n\
		Activating this power will search around you in a 1-tile radius for bloodied objects and floors.\n\
		If these objects are covered in blood from another humanoid being, you will see the option to track one of those scents.\n\
		Selecting one of those scents will grant you a new ability to follow that scent. This will create a visible trail to follow to the owner of that blood.\n\
		WARNING: it will be difficult to see around you while following a scent trail due to the the color being drained from all your vision except for the trail and your target."

	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()
	
	///the coefficient for disgust stacks and gauging if the air is miasma free enough. synchronizer chromo makes it more miasma tolerant for genetics olfaction
	var/sensitivity = 1
	///whether or not to even check for miasma in the air. since bloodsucker olfac is based on smelling blood, they don't care about miasma
	var/sensitive = TRUE
	///tracking blood or scents. blood for bloodsuckers, scent for genetics olfaction
	var/tracking_flags = TRACKING_SCENT

	var/datum/action/bloodsucker/olfaction/follow_scent/follow = new /datum/action/bloodsucker/olfaction/follow_scent()

/datum/action/bloodsucker/olfaction/acquire_scent/Grant(mob/user, tracking)
	. = ..()
	if(!iscarbon(user))
		to_chat(owner, span_warning("Your olfactory senses aren't developed enough to utilize this ability!"))
		qdel(src)
		return
	if(tracking)
		tracking_flags = tracking

/datum/action/bloodsucker/olfaction/acquire_scent/Trigger()
	if(!..())
		return FALSE
	DeactivatePower()
	var/datum/gas_mixture/air = owner.loc.return_air()
	if(air.get_moles(/datum/gas/miasma) >= 0.1/sensitivity && sensitive)
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
		if(scents[md5(C.dna.uni_identity)] && !possible.Find(C))
			var/datum/job/J = SSjob.GetJob(C.job)
			if(!J)
				J = new()
			var/stink_string = "[J.smells_like] and [C.dna.species.smells_like]"
			possible |= stink_string
			possible[stink_string] = C
	
	if(!length(possible))
		to_chat(owner,span_warning("Despite your best efforts, there are no scents to be found here"))
		return
	tracking_target = input(owner, "Choose a scent to focus in on.", "Scent Tracking") as null|anything in possible
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

/datum/action/bloodsucker/olfaction/acquire_scent/Remove(mob/M)	
	follow = locate(follow) in owner.actions
	if(follow)
		follow.Remove(owner)
	return ..()

/datum/action/bloodsucker/olfaction/acquire_scent/sanguine
	sensitive = FALSE
	tracking_flags = TRACKING_BLOOD
	purchase_flags = BLOODSUCKER_CAN_BUY

	follow = new /datum/action/bloodsucker/olfaction/follow_scent/sanguine()

/datum/action/bloodsucker/olfaction/acquire_scent/lesser
	name = "Transcendent Olfaction"

	button_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_spell"
	background_icon_state_on = "bg_spell"
	background_icon_state_off = "bg_spell"
	
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"

	buttontooltipstyle = ""

	sensitive = TRUE
	tracking_flags = TRACKING_SCENT
	power_explanation = "<b>Transcendent Olfaction</b>:\n\
		Activating this power will search all objects and items in a 1-tile radius around you for scents.\n\
		If these objects or items have been used by humanoid beings and still have their scent, you will see the option to track one of those scents.\n\
		Selecting one of those scents will grant you a new ability to follow that scent. This will create a visible trail to follow to the owner of that scent.\n\
		WARNING: it will be difficult to see around you while following a scent trail due to the the color being drained from all your vision except for the trail and your target."

	follow = new /datum/action/bloodsucker/olfaction/follow_scent/lesser()

/datum/action/bloodsucker/olfaction/follow_scent
	name = "Follow the Scent"
	desc = "Begin following the scent of your target."
	button_icon_state = "power_olfac"
	power_explanation = "<b>Follow the Scent</b>:\n\
		Activating this power will create a trail you can follow to the target scent you selected with Olfaction.\n\
		During this time, the target you're tracking will also leave a trail behind them as they move.\n\
		WARNING: The path created for you to follow may bring you to doors you can't open and areas you don't have access to. If this happens, try again later or from a new area. \n\
		Color will be drained from everything in your vision except for the trail and your target.\n\
		Moving on the trail will dissipate each segment as you move along it, but grant you a speed boost.\n\
		This effect will stay active for 20 seconds."
	var/mob/living/carbon/sniffer
	var/mob/living/carbon/tracking_target
	///which status effect is being applied on use
	var/status_effect = STATUS_EFFECT_BLOOD_HUNTER

/datum/action/bloodsucker/olfaction/follow_scent/Grant(mob/user, tracking)
	. = ..()
	if(!iscarbon(user))
		to_chat(owner, span_warning("Your olfactory senses aren't developed enough to utilize this ability!"))
		qdel(src)
		return
	sniffer = user
	if(tracking)
		tracking_target = tracking

/datum/action/bloodsucker/olfaction/follow_scent/Trigger()
	if(!..())
		return FALSE
	DeactivatePower()
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

/datum/action/bloodsucker/olfaction/follow_scent/sanguine
	name = "Follow the Scent"
	desc = "Begin following the scent of your target."
	
	status_effect = STATUS_EFFECT_BLOOD_HUNTER

/datum/action/bloodsucker/olfaction/follow_scent/lesser
	name = "Follow the Scent"
	desc = "Begin following the scent of your target."

	button_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_spell"
	background_icon_state_on = "bg_spell"
	background_icon_state_off = "bg_spell"
	buttontooltipstyle = ""
	
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "nose"

	status_effect = STATUS_EFFECT_SCENT_HUNTER
