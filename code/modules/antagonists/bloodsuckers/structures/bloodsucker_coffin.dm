/datum/antagonist/bloodsucker/proc/claim_coffin(obj/structure/closet/crate/claimed, area/current_area)
	// ALREADY CLAIMED
	if(claimed.resident)
		if(claimed.resident == owner.current)
			to_chat(owner, "This is your [claimed.name].")
		else
			to_chat(owner, "This [claimed.name] has already been claimed by another.")
		return FALSE
	if(!LAZYFIND(GLOB.the_station_areas, current_area.type))
		claimed.balloon_alert(owner.current, "not part of station!")
		return
	// This is my Lair
	coffin = claimed
	bloodsucker_lair_area = current_area
	if(!(/datum/crafting_recipe/vassalrack in owner?.learned_recipes))
		owner.teach_crafting_recipe(/datum/crafting_recipe/vassalrack)
		owner.teach_crafting_recipe(/datum/crafting_recipe/candelabrum)
		//owner.teach_crafting_recipe(/datum/crafting_recipe/bloodthrone)
		owner.teach_crafting_recipe(/datum/crafting_recipe/meatcoffin)
		owner.teach_crafting_recipe(/datum/crafting_recipe/staketrap)
		owner.teach_crafting_recipe(/datum/crafting_recipe/woodenducky)
		if(my_clan?.get_clan() != CLAN_TZIMISCE) // better things to do
			owner.teach_crafting_recipe(/datum/crafting_recipe/bloodaltar)
		to_chat(owner, span_danger("You learned new recipes - You can view them in the Structure and Weaponry section of the crafting menu!"))
	to_chat(owner, span_userdanger("You have claimed the [claimed] as your place of immortal rest! Your lair is now [bloodsucker_lair_area]."))
	to_chat(owner, span_announce("Bloodsucker Tip: Find new lair recipes in the structure tab of the <i>Crafting Menu</i>, including the <i>Persuasion Rack</i> for converting crew into Vassals and the <i>Blood Altar</i> which lets you gain two tasks per night to Rank Up."))
	return TRUE

/obj/structure/closet/crate/coffin/examine(mob/user)
	. = ..()
	if(user == resident)
		. += span_cult("This is your Claimed Coffin.")
		. += span_cult("Rest in it while injured to enter Torpor. Entering it with unspent Ranks will allow you to spend one.")
		. += span_cult("Alt Click while inside the Coffin to Lock/Unlock.")
		. += span_cult("Alt Click while outside of your Coffin to Unclaim it, unwrenching it and all your other structures as a result.")

/obj/structure/closet/crate/coffin/blackcoffin
	name = "black coffin"
	desc = "For those departed who are not so dear."
	icon_state = "coffin"
	icon = 'icons/obj/vamp_obj.dmi'
	breakout_time = 30 SECONDS
	pry_lid_timer = 20 SECONDS
	resistance_flags = NONE
	material_drop = /obj/item/stack/sheet/metal
	material_drop_amount = 2
	armor = list(MELEE = 50, BULLET = 20, LASER = 30, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 70, ACID = 60)

/obj/structure/closet/crate/coffin/securecoffin
	name = "secure coffin"
	desc = "For those too scared of having their place of rest disturbed."
	icon_state = "securecoffin"
	icon = 'icons/obj/vamp_obj.dmi'
	open_sound = 'sound/effects/coffin_open.ogg'
	close_sound = 'sound/effects/coffin_close.ogg'
	breakout_time = 35 SECONDS
	pry_lid_timer = 35 SECONDS
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	material_drop = /obj/item/stack/sheet/metal
	material_drop_amount = 2
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 0, BOMB = 100, BIO = 0, RAD = 100, FIRE = 100, ACID = 100)

/obj/structure/closet/crate/coffin/meatcoffin
	name = "meat coffin"
	desc = "When you're ready to meat your maker, the steaks can never be too high."
	icon_state = "meatcoffin"
	icon = 'icons/obj/vamp_obj.dmi'
	resistance_flags = FIRE_PROOF
	open_sound = 'sound/effects/footstep/slime1.ogg'
	close_sound = 'sound/effects/footstep/slime1.ogg'
	breakout_time = 25 SECONDS
	pry_lid_timer = 20 SECONDS
	material_drop = /obj/item/reagent_containers/food/snacks/meat/slab
	material_drop_amount = 3
	armor = list(MELEE = 70, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 70, BIO = 0, RAD = 0, FIRE = 70, ACID = 60)

/obj/structure/closet/crate/coffin/metalcoffin
	name = "metal coffin"
	desc = "A big metal sardine can inside of another big metal sardine can, in space."
	icon_state = "metalcoffin"
	icon = 'icons/obj/vamp_obj.dmi'
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	open_sound = 'sound/effects/pressureplate.ogg'
	close_sound = 'sound/effects/pressureplate.ogg'
	breakout_time = 25 SECONDS
	pry_lid_timer = 30 SECONDS
	material_drop = /obj/item/stack/sheet/metal
	armor = list(MELEE = 40, BULLET = 15, LASER = 50, ENERGY = 0, BOMB = 10, BIO = 0, RAD = 50, FIRE = 70, ACID = 60)
 
//////////////////////////////////////////////

/// NOTE: This can be any coffin that you are resting AND inside of.
/obj/structure/closet/crate/coffin/proc/claim_coffin(mob/living/claimant, area/current_area)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = claimant.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	// Successfully claimed?
	if(bloodsuckerdatum?.claim_coffin(src, current_area))
		resident = claimant
		anchored = TRUE
		START_PROCESSING(SSprocessing, src)

/obj/structure/closet/crate/coffin/examine(mob/user)
	. = ..()
	if(user == resident)
		. += span_cult("This is your Claimed Coffin.")
		. += span_cult("Rest in it while injured to enter Torpor. Entering it with unspent Ranks will allow you to spend one.")
		. += span_cult("Alt-Click while inside the Coffin to Lock/Unlock.")
		. += span_cult("Alt-Click while outside of your Coffin to Unclaim it, unwrenching it and all your other structures as a result.")

/obj/structure/closet/crate/coffin/Destroy()
	unclaim_coffin()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/closet/crate/coffin/process(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	if(user in src)
		var/list/turf/area_turfs = get_area_turfs(get_area(src))
		// Create Dirt etc.
		var/turf/T_Dirty = pick(area_turfs)
		if(T_Dirty && !T_Dirty.density)
			// Default: Dirt
			// STEP ONE: COBWEBS
			// CHECK: Wall to North?
			var/turf/check_N = get_step(T_Dirty, NORTH)
			if(istype(check_N, /turf/closed/wall))
				// CHECK: Wall to West?
				var/turf/check_W = get_step(T_Dirty, WEST)
				if(istype(check_W, /turf/closed/wall))
					new /obj/effect/decal/cleanable/cobweb(T_Dirty)
				// CHECK: Wall to East?
				var/turf/check_E = get_step(T_Dirty, EAST)
				if(istype(check_E, /turf/closed/wall))
					new /obj/effect/decal/cleanable/cobweb/cobweb2(T_Dirty)
			new /obj/effect/decal/cleanable/dirt(T_Dirty)

/obj/structure/closet/crate/proc/unclaim_coffin(manual = FALSE)
	// Unanchor it (If it hasn't been broken, anyway)
	anchored = FALSE
	if(!resident || !resident.mind)
		return
	// Unclaiming
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = resident.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum && bloodsuckerdatum.coffin == src)
		bloodsuckerdatum.coffin = null
		bloodsuckerdatum.bloodsucker_lair_area = null
	for(var/obj/structure/bloodsucker/bloodsucker_structure in get_area(src))
		if(bloodsucker_structure.owner == resident)
			bloodsucker_structure.unbolt()
	if(manual)
		to_chat(resident, span_cultitalic("You have unclaimed your coffin! This also unclaims all your other Bloodsucker structures!"))
	else
		to_chat(resident, span_cultitalic("You sense that the link with your coffin and your sacred lair, has been broken! You will need to seek another."))
	// Remove resident. Because this object isnt removed from the game immediately (GC?) we need to give them a way to see they don't have a home anymore.
	resident = null

/// You cannot lock in/out a coffin's owner. SORRY.
/obj/structure/closet/crate/coffin/can_open(mob/living/user)
	if(!locked)
		return ..()
	if(user == resident)
		if(welded)
			welded = FALSE
			update_appearance(UPDATE_ICON)
		locked = FALSE
		return TRUE
	playsound(get_turf(src), 'sound/machines/door_locked.ogg', 20, 1)
	to_chat(user, span_notice("[src] is locked tight from the inside."))

/obj/structure/closet/crate/coffin/close(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	// Only the User can put themself into Torpor. If already in it, you'll start to heal.
	if(user in src)
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
		if(!bloodsuckerdatum)
			return FALSE
		var/area/current_area = get_area(src)
		if(!bloodsuckerdatum.coffin && !resident)
			switch(tgui_alert(user, "Do you wish to claim this as your coffin? [current_area] will be your lair.", "Claim Lair", list("Yes", "No")))
				if("Yes")
					claim_coffin(user, current_area)
				if("No")
					return
		LockMe(user)
		//Level up if possible.
		if(!bloodsuckerdatum.my_clan)
			to_chat(user, span_notice("You must enter a Clan to rank up."))
			return
		if(bloodsuckerdatum.my_clan.rank_up_type == BLOODSUCKER_RANK_UP_NORMAL)
			bloodsuckerdatum.SpendRank()
		// You're in a Coffin, everything else is done, you're likely here to heal. Let's offer them the oppertunity to do so.
		bloodsuckerdatum.check_begin_torpor()
	return TRUE

/// You cannot weld or deconstruct an owned coffin. Only the owner can destroy their own coffin.
/obj/structure/closet/crate/coffin/welder_act(mob/living/user, obj/item/tool)
	if(user.a_intent != INTENT_HARM && resident && resident != user)
		to_chat(user, span_notice("This is a much more complex mechanical structure than you thought. You don't know where to begin cutting [src]."))
		return TRUE
	return ..()

/obj/structure/closet/crate/coffin/wirecutter_act(mob/living/user, obj/item/tool)
	if(user.a_intent != INTENT_HARM && resident && resident != user && tool.tool_behaviour == cutting_tool)
		to_chat(user, span_notice("This is a much more complex mechanical structure than you thought. You don't know where to begin cutting [src]."))
		return TRUE
	return ..()

/obj/structure/closet/crate/coffin/crowbar_act(mob/living/user, obj/item/tool)
	if(locked && resident)
		user.visible_message(
			span_notice("[user] tries to pry the lid off of [src] with [tool]."),
			span_notice("You begin prying the lid off of [src] with [tool]. This should take about [DisplayTimeText(pry_lid_timer)]."))
		if(!tool.use_tool(src, user, pry_lid_timer)) // Pry speed must be affected by the speed of the tool.
			return TRUE
		bust_open()
		user.visible_message(
			span_notice("[user] snaps the door of [src] wide open."),
			span_notice("The door of [src] snaps open."))
		return TRUE
	return FALSE

/obj/structure/closet/crate/coffin/wrench_act(mob/living/user, obj/item/tool)
	if(anchored && resident)
		to_chat(user, span_danger("The coffin won't come unanchored from the floor.[user == resident ? " You can Alt-Click to unclaim and unwrench your Coffin." : ""]"))
		return TRUE
	return ..()

/// Distance Check (Inside Of)
/obj/structure/closet/crate/coffin/AltClick(mob/user)
	. = ..()
	if(user in src)
		LockMe(user, !locked)
		return

	if(user == resident && user.Adjacent(src))
		balloon_alert(user, "unclaim coffin?")
		var/static/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/mob/radial.dmi', icon_state = "radial_no"))
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				unclaim_coffin(TRUE)
	
/obj/structure/closet/crate/proc/LockMe(mob/user, inLocked = TRUE)
	if(user == resident)
		if(!broken)
			locked = inLocked
			to_chat(user, span_notice("You flip a secret latch and [locked?"":"un"]lock yourself inside [src]."))
			return
		// Broken? Let's fix it.
		to_chat(resident, span_notice("The secret latch to lock [src] from the inside is broken. You set it back into place..."))
		if(!do_after(resident, 5 SECONDS, src))
			to_chat(resident, span_notice("You fail to fix [src]'s mechanism."))
			return
		to_chat(resident, span_notice("You fix the mechanism and lock it."))
		broken = FALSE
		locked = TRUE
