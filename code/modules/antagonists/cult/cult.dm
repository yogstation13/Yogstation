#define SUMMON_POSSIBILITIES 3
#define CULT_VICTORY 1
#define CULT_LOSS 0
#define CULT_NARSIE_KILLED -1

/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	antag_moodlet = /datum/mood_event/cult
	preview_outfit = /datum/outfit/cultist
	job_rank = ROLE_CULTIST
	antag_hud_name = "cult"
	show_to_ghosts = TRUE

	var/datum/team/cult/cult_team
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new
	var/datum/action/innate/cult/blood_magic/magic = new
	var/ignore_implant = FALSE
	var/give_equipment = FALSE
	var/original_eye_color = "000" //this will store the eye color of the cultist so it can be returned if they get deconverted

/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
	objectives |= cult_team.objectives

/datum/antagonist/cult/Destroy()
	QDEL_NULL(communion)
	QDEL_NULL(vote)
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE
	return is_convertable_to_cult(new_owner.current, cult_team, ignore_implant)

/datum/antagonist/cult/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are a member of the cult!</font><B>")
	to_chat(owner.current, "<b>If you are new to Blood Cult, please review <a href='https://forums.yogstation.net/threads/how-to-newbloodcult-for-hyperdunces.16896/'>this tutorial!</a><b>") //Yogs
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/on_gain()
//	add_objectives() figure it out sometime later (remove cult the gamemode in favor of dynamic ruleset)
	. = ..()
	add_objectives()
	var/mob/living/current = owner.current
	if(ishuman(current))
		var/mob/living/carbon/human/H = current
		original_eye_color = H.eye_color
	if(give_equipment)
		equip_cultist(TRUE)
	current.log_message("has been converted to the cult of Nar'sie!", LOG_ATTACK, color="#960000")

	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image

/datum/antagonist/cult/on_removal()
	if(!silent)
		owner.current.visible_message("[span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!")]", null, null, null, owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant."))
		owner.current.log_message("has renounced the cult of Nar'sie!", LOG_ATTACK, color="#960000")
	if(cult_team.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image

	return ..()

/*
/datum/antagonist/cult/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// The longsword is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/cultblade/longsword = new
	icon.Blend(icon(longsword.lefthand_file, longsword.item_state), ICON_OVERLAY)
	qdel(longsword)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)
*/
/datum/antagonist/cult/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/cult1 = new
	var/mob/living/carbon/human/dummy/consistent/cult2 = new

	var/icon/final_icon = render_preview_outfit(/datum/outfit/cultist/leader, cult1)
	var/icon/teammate = render_preview_outfit(/datum/outfit/cultist/follower, cult2)
	teammate.Blend(rgb(128, 128, 128, 128), ICON_MULTIPLY)

	final_icon.Blend(teammate, ICON_OVERLAY, -world.icon_size / 4, 0)
	final_icon.Blend(teammate, ICON_OVERLAY, world.icon_size / 4, 0)

	qdel(cult1)
	qdel(cult2)

	return finish_preview_icon(final_icon)

/datum/outfit/cultist/leader
	suit = /obj/item/clothing/suit/hooded/cultrobes/berserker
	shoes = /obj/item/clothing/shoes/cult/alt
	head = /obj/item/clothing/head/hooded/berserkerhood
	glasses = /obj/item/clothing/glasses/hud/health/night/cultblind
	r_hand = /obj/item/melee/cultblade
	l_hand = /obj/item/shield/mirror

/datum/outfit/cultist/follower
	suit = /obj/item/clothing/suit/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult/alt
	head = /obj/item/clothing/head/culthood/alt
	glasses = /obj/item/clothing/glasses/hud/health/night/cultblind
	r_hand = /obj/item/melee/cultblade

/datum/antagonist/cult/proc/equip_cultist(metal=TRUE)
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, owner.current)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, owner.current)
	to_chat(owner, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")


/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/current_mob)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)

	var/T = new item_path(current_mob)
	var/item_name = initial(item_path.name)
	var/where = current_mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(current_mob, span_userdanger("Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(current_mob, span_danger("You have a [item_name] in your [where]."))
		if(where == "backpack")
			SEND_SIGNAL(current_mob.back, COMSIG_TRY_STORAGE_SHOW, current_mob)
		return TRUE

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	current.faction |= "cult"
	current.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	if(!cult_team.cult_master)
		vote.Grant(current)
	communion.Grant(current)
	if(ishuman(current))
		magic.Grant(current)
	current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(cult_team.cult_risen)
		cult_team.rise(current)
		if(cult_team.cult_ascendent)
			cult_team.ascend(current)

	add_team_hud(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	current.faction -= "cult"
	current.remove_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	vote.Remove(current)
	communion.Remove(current)
	magic.Remove(current)
	current.clear_alert("bloodsense")
	if(ishuman(current))
		var/mob/living/carbon/human/H = current
		H.eye_color = original_eye_color
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		REMOVE_TRAIT(H, CULT_EYES, null)
		H.remove_overlay(HALO_LAYER)
		H.updateappearance()

/datum/antagonist/cult/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has cult'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has cult'ed [key_name(new_owner)].")

/datum/antagonist/cult/admin_remove(mob/user)
	silent = TRUE
	return ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src, PROC_REF(admin_give_dagger))
	.["Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_give_metal))
	.["Remove Dagger and Metal"] = CALLBACK(src, PROC_REF(admin_take_all))

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(metal=FALSE))
		to_chat(admin, span_danger("Spawning dagger failed!"))

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(metal=TRUE))
		to_chat(admin, span_danger("Spawning runed metal failed!"))

/datum/antagonist/cult/proc/admin_take_all(mob/admin)
	var/mob/living/current = owner.current
	for(var/o in current.get_all_contents())
		if(istype(o, /obj/item/melee/cultblade/dagger) || istype(o, /obj/item/stack/sheet/runed_metal))
			qdel(o)

/datum/antagonist/cult/master
	ignore_implant = TRUE
	show_in_antagpanel = FALSE //Feel free to add this later
	antag_hud_name = "cultmaster"
	var/datum/action/innate/cult/master/finalreck/reckoning = new
	var/datum/action/innate/cult/master/cultmark/bloodmark = new
	var/datum/action/innate/cult/master/pulse/throwing = new

/datum/antagonist/cult/master/Destroy()
	QDEL_NULL(reckoning)
	QDEL_NULL(bloodmark)
	QDEL_NULL(throwing)
	return ..()

/datum/antagonist/cult/master/greet()
	to_chat(owner.current, "[span_cultlarge("You are the cult's Master")]. As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
	targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of summoning the entire living cult to your location <b><i>once</i></b>.")
	to_chat(owner.current, "Use these abilities to direct the cult to victory at any cost.")

/datum/antagonist/cult/master/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(!cult_team.reckoning_complete)
		reckoning.Grant(current)
	bloodmark.Grant(current)
	throwing.Grant(current)
	current.update_mob_action_buttons()
	current.apply_status_effect(/datum/status_effect/cult_master)
	if(cult_team.cult_risen)
		cult_team.rise(current)
		if(cult_team.cult_ascendent)
			cult_team.ascend(current)
	add_team_hud(current, /datum/antagonist/cult)

/datum/antagonist/cult/master/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	reckoning.Remove(current)
	bloodmark.Remove(current)
	throwing.Remove(current)
	current.update_mob_action_buttons()
	current.remove_status_effect(/datum/status_effect/cult_master)

	if(ishuman(current))
		var/mob/living/carbon/human/H = current
		H.eye_color = original_eye_color
		H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
		REMOVE_TRAIT(H, CULT_EYES, null)
		H.remove_overlay(HALO_LAYER)
		H.updateappearance()

/datum/objective/sacrifice
	var/sacced = FALSE
	var/sac_image

/datum/objective/sacrifice/is_valid_target(possible_target)
	. = ..()
	var/datum/mind/M = possible_target
	if(istype(M) && isipc(M.current))
		return FALSE

/// Unregister signals from the old target so it doesn't cause issues when sacrificed of when a new target is found.
/datum/objective/sacrifice/proc/clear_sacrifice()
	if(!target)
		return
	UnregisterSignal(target, COMSIG_MIND_TRANSFERRED)
	if(target.current)
		UnregisterSignal(target.current, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_MIND_TRANSFERRED_INTO))
	target = null

/datum/objective/sacrifice/find_target(dupe_search_range, list/blacklist)
	clear_sacrifice()
	if(!istype(team, /datum/team/cult))
		return
	var/datum/team/cult/cult = team
	var/list/target_candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && !is_convertable_to_cult(player) && player.stat != DEAD)
			target_candidates += player.mind
	if(target_candidates.len == 0)
		message_admins("Cult Sacrifice: Could not find unconvertible target, checking for convertible target.")
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && player.stat != DEAD)
				target_candidates += player.mind
	listclearnulls(target_candidates)
	if(LAZYLEN(target_candidates))
		target = pick(target_candidates)
		update_explanation_text()
		// Register a bunch of signals to both the target mind and its body
		// to stop cult from softlocking everytime the target is deleted before being actually sacrificed.
		RegisterSignal(target, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transfer))
		RegisterSignal(target.current, COMSIG_PARENT_QDELETING, PROC_REF(on_target_body_del))
		RegisterSignal(target.current, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(on_possible_mindswap))
	else
		message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. WELP!")
		sacced = TRUE // Prevents another hypothetical softlock. This basically means every PC is a cultist.
	if(!sacced)
		cult.make_image(src)
	for(var/datum/mind/mind in cult.members)
		if(mind.current)
			mind.current.clear_alert("bloodsense")
			mind.current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)

/datum/objective/sacrifice/proc/on_target_body_del()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(find_target))

/datum/objective/sacrifice/proc/on_mind_transfer(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	//If, for some reason, the mind was transferred to a ghost (better safe than sorry), find a new target.
	if(!isliving(target.current))
		INVOKE_ASYNC(src, PROC_REF(find_target))
		return
	UnregisterSignal(previous_body, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_MIND_TRANSFERRED_INTO))
	RegisterSignal(target.current, COMSIG_PARENT_QDELETING, PROC_REF(on_target_body_del))
	RegisterSignal(target.current, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(on_possible_mindswap))

/datum/objective/sacrifice/proc/on_possible_mindswap(mob/source)
	SIGNAL_HANDLER
	UnregisterSignal(target.current, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_MIND_TRANSFERRED_INTO))
	//we check if the mind is bodyless only after mindswap shenanigeans to avoid issues.
	addtimer(CALLBACK(src, PROC_REF(do_we_have_a_body)), 0 SECONDS)

/datum/objective/sacrifice/proc/do_we_have_a_body()
	if(!target.current) //The player was ghosted and the mind isn't probably going to be transferred to another mob at this point.
		find_target()
		return
	RegisterSignal(target.current, COMSIG_PARENT_QDELETING, PROC_REF(on_target_body_del))
	RegisterSignal(target.current, COMSIG_MOB_MIND_TRANSFERRED_INTO, PROC_REF(on_possible_mindswap))

/datum/objective/sacrifice/check_completion()
	return sacced || completed

/datum/objective/sacrifice/update_explanation_text()
	if(target)
		explanation_text = "Sacrifice [target], the [target.assigned_role] via invoking a Sacrifice rune with [target.p_them()] on it and three acolytes around it."
	else
		explanation_text = "The veil has already been weakened here, proceed to the final objective."

/datum/objective/eldergod
	var/summoned = FALSE
	var/killed = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(GLOB.areas - summon_spots)
		if(summon && is_station_level(summon.z) && summon.valid_territory)
			summon_spots += summon
		sanity++
	update_explanation_text()

/datum/objective/eldergod/update_explanation_text()
	explanation_text = "Summon Nar'sie by invoking the rune 'Summon Nar'sie'. <b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/eldergod/check_completion()
	if(killed)
		return CULT_NARSIE_KILLED // You failed so hard that even the code went backwards.
	return summoned || completed

/datum/outfit/cultist
	name = "Cultist (Preview only)"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/yogs/armor/sith_suit
	shoes = /obj/item/clothing/shoes/cult/alt
	r_hand = /obj/item/melee/blood_magic/stun

/datum/outfit/cultist/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.eye_color = BLOODCULT_EYE
	H.update_body()

	var/obj/item/clothing/suit/hooded/hooded = locate() in H
	if(!isdummy(H))
		hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
		hooded.ToggleHood()
