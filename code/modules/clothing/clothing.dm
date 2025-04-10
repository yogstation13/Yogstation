/obj/item/clothing
	name = "clothing"
	resistance_flags = FLAMMABLE
	max_integrity = 200
	integrity_failure = 80
	fryable = TRUE
	var/damaged_clothes = CLOTHING_PRISTINE //similar to machine's BROKEN stat and structure's broken var
	var/flash_protect = 0		//What level of bright light protection item has. 1 = Flashers, Flashes, & Flashbangs | 2 = Welding | -1 = OH GOD WELDING BURNT OUT MY RETINAS
	var/tint = 0				//Sets the item's level of visual impairment tint, normally set to the same as flash_protect
	var/up = 0					//but separated to allow items to protect but not impair vision, like space helmets
	var/visor_flags = 0			//flags that are added/removed when an item is adjusted up/down
	var/visor_flags_inv = 0		//same as visor_flags, but for flags_inv
	var/visor_flags_cover = 0	//same as above, but for flags_cover
//what to toggle when toggled with weldingvisortoggle()
	var/visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_VISIONFLAGS | VISOR_INVISVIEW
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/alt_desc = null
	var/toggle_message = null
	var/alt_toggle_message = null
	var/active_sound = null
	var/toggle_cooldown = null
	var/cooldown = 0

	var/blocks_shove_knockdown = FALSE //Whether wearing the clothing item blocks the ability for shove to knock down.

	var/clothing_flags = NONE

	var/can_be_bloody = TRUE

	/// What items can be consumed to repair this clothing (must by an /obj/item/stack)
	var/repairable_by = /obj/item/stack/sheet/cloth

	//Var modification - PLEASE be careful with this I know who you are and where you live
	var/list/user_vars_to_edit //VARNAME = VARVALUE eg: "name" = "butts"
	var/list/user_vars_remembered //Auto built by the above + dropped() + equipped()

	/// Trait modification, lazylist of traits to add/take away, on equipment/drop in the correct slot
	var/list/clothing_traits

	var/pocket_storage_component_path

	//These allow head/mask items to dynamically alter the user's hair
	// and facial hair, checking hair_extensions.dmi and facialhair_extensions.dmi
	// for a state matching hair_state+dynamic_hair_suffix
	// THESE OVERRIDE THE HIDEHAIR FLAGS
	var/dynamic_hair_suffix = ""//head > mask for head hair
	var/dynamic_fhair_suffix = ""//mask > head for facial hair

	var/tearable //can this particular item be torn down to be used for cloth? | yogs
	var/tearhealth = 100 //health regarding tearing clothes to get torn cloth | yogs //why is this so bad

	/// How much clothing damage has been dealt to each of the limbs of the clothing, assuming it covers more than one limb
	var/list/damage_by_parts
	/// How much integrity is in a specific limb before that limb is disabled (for use in [/obj/item/clothing/proc/take_damage_zone], and only if we cover multiple zones.) Set to 0 to disable shredding.
	var/limb_integrity = 0
	/// How many zones (body parts, not precise) we have disabled so far, for naming purposes
	var/zones_disabled

/obj/item/clothing/Initialize(mapload)
	if(CHECK_BITFIELD(clothing_flags, VOICEBOX_TOGGLABLE))
		actions_types += /datum/action/item_action/toggle_voice_box
	. = ..()
	if(ispath(pocket_storage_component_path))
		LoadComponent(pocket_storage_component_path)
	if(can_be_bloody && ((body_parts_covered & FEET) || (flags_inv & HIDESHOES)))
		LoadComponent(/datum/component/bloodysoles)

/obj/item/clothing/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr

	if(ismecha(M.loc)) // stops inventory actions in a mech
		return

	if(!M.incapacitated() && loc == M && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
			add_fingerprint(usr)

/obj/item/reagent_containers/food/snacks/clothing
	name = "temporary moth clothing snack item"
	desc = "If you're reading this it means I messed up. This is related to moths eating clothes and I didn't know a better way to do it than making a new food object."
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	tastes = list("dust" = 1, "lint" = 1)
	foodtype = CLOTH

/obj/item/clothing/attack(mob/M, mob/living/user, params)
	if(!user.combat_mode && ismoth(M))
		var/obj/item/reagent_containers/food/snacks/clothing/clothing_as_food = new
		clothing_as_food.name = name
		if(clothing_as_food.attack(M, user, params))
			take_damage(15, sound_effect=FALSE)
		qdel(clothing_as_food)
	else
		return ..()

/obj/item/clothing/attackby(obj/item/W, mob/user, params)
	if(damaged_clothes && istype(W, repairable_by))
		var/obj/item/stack/S = W
		switch(damaged_clothes)
			if(CLOTHING_DAMAGED)
				S.use(1)
				repair(user, params)
			if(CLOTHING_SHREDDED)
				if(S.amount < 3)
					to_chat(user, span_warning("You require 3 [S.name] to repair [src]."))
					return
				to_chat(user, span_notice("You begin fixing the damage to [src] with [S]..."))
				if(do_after(user, 6 SECONDS, src))
					if(S.use(3))
						repair(user, params)
		return 1
	return ..()

/// Set the clothing's integrity back to 100%, remove all damage to bodyparts, and generally fix it up
/obj/item/clothing/proc/repair(mob/user, params)
	damaged_clothes = CLOTHING_PRISTINE
	update_clothes_damaged_state(FALSE)
	update_integrity(max_integrity)
	name = initial(name) // remove "tattered" or "shredded" if there's a prefix
	body_parts_covered = initial(body_parts_covered)
	slot_flags = initial(slot_flags)
	damage_by_parts = null
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		to_chat(user, span_notice("You fix the damage on [src]."))

/**
  * take_damage_zone() is used for dealing damage to specific bodyparts on a worn piece of clothing, meant to be called from [/obj/item/bodypart/proc/check_woundings_mods()]
  *
  *	This proc only matters when a bodypart that this clothing is covering is harmed by a direct attack (being on fire or in space need not apply), and only if this clothing covers
  * more than one bodypart to begin with. No point in tracking damage by zone for a hat, and I'm not cruel enough to let you fully break them in a few shots.
  * Also if limb_integrity is 0, then this clothing doesn't have bodypart damage enabled so skip it.
  *
  * Arguments:
  * * def_zone: The bodypart zone in question
  * * damage_amount: Incoming damage
  * * damage_type: BRUTE or BURN
  * * armour_penetration: If the attack had armour_penetration
  */
/obj/item/clothing/proc/take_damage_zone(def_zone, damage_amount, damage_type, armour_penetration)
	if(!def_zone || !limb_integrity || (initial(body_parts_covered) in GLOB.bitflags)) // the second check sees if we only cover one bodypart anyway and don't need to bother with this
		return
	var/list/covered_limbs = cover_flags2body_zones(body_parts_covered) // what do we actually cover?
	if(!(def_zone in covered_limbs))
		return

	var/damage_dealt = take_damage(damage_amount * 0.1, damage_type, armour_penetration, FALSE) * 10 // only deal 10% of the damage to the general integrity damage, then multiply it by 10 so we know how much to deal to limb
	LAZYINITLIST(damage_by_parts)
	damage_by_parts[def_zone] += damage_dealt
	if(damage_by_parts[def_zone] > limb_integrity)
		disable_zone(def_zone, damage_type)

/**
  * disable_zone() is used to disable a given bodypart's protection on our clothing item, mainly from [/obj/item/clothing/proc/take_damage_zone()]
  *
  * This proc disables all protection on the specified bodypart for this piece of clothing: it'll be as if it doesn't cover it at all anymore (because it won't!)
  * If every possible bodypart has been disabled on the clothing, we put it out of commission entirely and mark it as shredded, whereby it will have to be repaired in
  * order to equip it again. Also note we only consider it damaged if there's more than one bodypart disabled.
  *
  * Arguments:
  * * def_zone: The bodypart zone we're disabling
  * * damage_type: Only really relevant for the verb for describing the breaking, and maybe atom_destruction()
  */
/obj/item/clothing/proc/disable_zone(def_zone, damage_type)
	var/list/covered_limbs = cover_flags2body_zones(body_parts_covered)
	if(!(def_zone in covered_limbs))
		return

	var/zone_name = parse_zone(def_zone)
	var/break_verb = ((damage_type == BRUTE) ? "torn" : "burned")

	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.visible_message(span_danger("The [zone_name] on [C]'s [src.name] is [break_verb] away!"), span_userdanger("The [zone_name] on your [src.name] is [break_verb] away!"), vision_distance = COMBAT_MESSAGE_RANGE)
		RegisterSignal(C, COMSIG_MOVABLE_MOVED, PROC_REF(bristle), override = TRUE)

	zones_disabled++
	for(var/i in body_zone2cover_flags(def_zone))
		body_parts_covered &= ~i

	if(body_parts_covered == NONE) // if there are no more parts to break then the whole thing is kaput
		atom_destruction((damage_type == BRUTE ? MELEE : LASER)) // melee/laser is good enough since this only procs from direct attacks anyway and not from fire/bombs
		return

	damaged_clothes = CLOTHING_DAMAGED
	switch(zones_disabled)
		if(1)
			name = "damaged [initial(name)]"
		if(2)
			name = "mangy [initial(name)]"
		if(3 to INFINITY) // take better care of your shit, dude
			name = "tattered [initial(name)]"

	update_clothes_damaged_state()

/obj/item/clothing/Destroy()
	user_vars_remembered = null //Oh god somebody put REFERENCES in here? not to worry, we'll clean it up
	return ..()

/obj/item/clothing/dropped(mob/user)
	..()
	if(!istype(user))
		return
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	for(var/trait in clothing_traits)
		REMOVE_CLOTHING_TRAIT(user, trait)
	if(LAZYLEN(user_vars_remembered))
		for(var/variable in user_vars_remembered)
			if(variable in user.vars)
				if(user.vars[variable] == user_vars_to_edit[variable]) //Is it still what we set it to? (if not we best not change it)
					user.vars[variable] = user_vars_remembered[variable]
		user_vars_remembered = initial(user_vars_remembered) // Effectively this sets it to null.

/obj/item/clothing/equipped(mob/user, slot)
	. = ..()
	if (!istype(user))
		return
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		if(iscarbon(user) && LAZYLEN(zones_disabled))
			RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(bristle))
		for(var/trait in clothing_traits)
			ADD_CLOTHING_TRAIT(user, trait)
		if (LAZYLEN(user_vars_to_edit))
			for(var/variable in user_vars_to_edit)
				if(variable in user.vars)
					LAZYSET(user_vars_remembered, variable, user.vars[variable])
					user.vv_edit_var(variable, user_vars_to_edit[variable])

// Adds a trait to the clothing traits list, and adds it to the wearer
/obj/item/clothing/proc/attach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYOR(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer) && (wearer.get_slot_by_item(src) & slot_flags))
		for(var/new_trait in trait_or_traits)
			ADD_CLOTHING_TRAIT(wearer, new_trait)

// Removes a trait from the clothing traits list, and removes it from the wearer
/obj/item/clothing/proc/detach_clothing_traits(trait_or_traits)
	if(!islist(trait_or_traits))
		trait_or_traits = list(trait_or_traits)

	LAZYREMOVE(clothing_traits, trait_or_traits)
	var/mob/wearer = loc
	if(istype(wearer))
		for(var/new_trait in trait_or_traits)
			REMOVE_CLOTHING_TRAIT(wearer, new_trait)

/obj/item/clothing/examine(mob/user)
	. = ..()
	if(damaged_clothes == CLOTHING_SHREDDED)
		. += span_warning("<b>It is completely shredded and requires mending before it can be worn again!</b>")
		return
	for(var/zone in damage_by_parts)
		var/pct_damage_part = damage_by_parts[zone] / limb_integrity * 100
		var/zone_name = parse_zone(zone)
		switch(pct_damage_part)
			if(100 to INFINITY)
				. += span_warning("<b>The [zone_name] is useless and requires mending!</b>")
			if(60 to 99)
				. += span_warning("The [zone_name] is heavily shredded!")
			if(30 to 59)
				. += span_danger("The [zone_name] is partially shredded.")
	var/datum/component/storage/pockets = GetComponent(/datum/component/storage)
	if(pockets)
		var/list/how_cool_are_your_threads = list("<span class='notice'>")
		if(pockets.attack_hand_interact)
			how_cool_are_your_threads += "[src]'s storage opens when clicked.\n"
		else
			how_cool_are_your_threads += "[src]'s storage opens when dragged to yourself.\n"
		if (pockets.can_hold?.len) // If pocket type can hold anything, vs only specific items
			how_cool_are_your_threads += "[src] can store [pockets.max_items] <a href='byond://?src=[REF(src)];show_valid_pocket_items=1'>item\s</a>.\n"
		else
			how_cool_are_your_threads += "[src] can store [pockets.max_items] item\s that are [weightclass2text(pockets.max_w_class)] or smaller.\n"
		if(pockets.quickdraw)
			how_cool_are_your_threads += "You can quickly remove an item from [src] using Alt-Click.\n"
		if(pockets.silent)
			how_cool_are_your_threads += "Adding or removing items from [src] makes no noise.\n"
		how_cool_are_your_threads += "</span>"
		. += how_cool_are_your_threads.Join()

	if(armor.bio || armor.bomb || armor.bullet || armor.energy || armor.laser || armor.melee || armor.fire || armor.acid|| flags_cover & HEADCOVERSMOUTH || flags_cover & HEADCOVERSEYES)
		. += "<span class='notice'>It has a <a href='byond://?src=[REF(src)];list_armor=1'>tag</a> listing its protection classes.</span>"

/obj/item/clothing/Topic(href, href_list)
	. = ..()
	if(href_list["list_armor"])
		var/additional_info = ""
		if(flags_cover & HEADCOVERSMOUTH || flags_cover & HEADCOVERSEYES)
			var/list/things_blocked = list()
			if(flags_cover & HEADCOVERSMOUTH)
				things_blocked += "facehuggers"
			if(flags_cover & HEADCOVERSEYES)
				things_blocked += "pepperspray"
			if(length(things_blocked))
				additional_info += "\n<b>COVERAGE</b>"
				additional_info += "\nIt will block [english_list(things_blocked)]."
		to_chat(usr, "[armor.show_protection_classes(additional_info)]")

/obj/item/clothing/atom_break(damage_flag)
	. = ..()
	damaged_clothes = CLOTHING_DAMAGED
	update_clothes_damaged_state()
	if(ismob(loc)) //It's not important enough to warrant a message if nobody's wearing it
		var/mob/M = loc
		to_chat(M, span_warning("Your [name] starts to fall apart!"))

/obj/item/clothing/proc/update_clothes_damaged_state(damaging = TRUE)
	var/index = "[REF(initial(icon))]-[initial(icon_state)]"
	var/static/list/damaged_clothes_icons = list()
	if(damaging)
		damaged_clothes = 1
		var/icon/damaged_clothes_icon = damaged_clothes_icons[index]
		if(!damaged_clothes_icon)
			damaged_clothes_icon = icon(initial(icon), initial(icon_state), , 1)	//we only want to apply damaged effect to the initial icon_state for each object
			damaged_clothes_icon.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
			damaged_clothes_icon.Blend(icon('icons/effects/item_damage.dmi', "itemdamaged"), ICON_MULTIPLY) //adds damage effect and the remaining white areas become transparant
			damaged_clothes_icon = fcopy_rsc(damaged_clothes_icon)
			damaged_clothes_icons[index] = damaged_clothes_icon
		add_overlay(damaged_clothes_icon, 1)
	else
		damaged_clothes = 0
		cut_overlay(damaged_clothes_icons[index], TRUE)


/*
SEE_SELF  // can see self, no matter what
SEE_MOBS  // can see all mobs, no matter what
SEE_OBJS  // can see all objs, no matter what
SEE_TURFS // can see all turfs (and areas), no matter what
SEE_PIXELS// if an object is located on an unlit area, but some of its pixels are
		  // in a lit area (via pixel_x,y or smooth movement), can see those pixels
BLIND     // can't see anything
*/

/proc/generate_female_clothing(index, t_color, icon, type = FEMALE_UNIFORM_FULL, flat = FALSE) //In a shellnut, blends the uniform sprite with a pre-made sprite in uniform.dmi that's mostly white pixels with a few empty ones to trim off the pixels in the empty spots
	var/icon/female_clothing_icon = icon("icon" = icon, "icon_state" = t_color) // and make the uniform the "female" shape. female_s is either the top-only one (for jumpskirts and the like) or the full one (for jumpsuits)
	var/icon/female_s = icon("icon" = 'icons/effects/clothing.dmi', "icon_state" = "[(type == FEMALE_UNIFORM_FULL) ? "female_full" : "female_top"]_[flat]")
	female_clothing_icon.Blend(female_s, ICON_MULTIPLY)
	female_clothing_icon = fcopy_rsc(female_clothing_icon)
	GLOB.female_clothing_icons[index] = female_clothing_icon //Then it saves the icon in a global list so it doesn't have to make it again

/proc/generate_skinny_clothing(index, t_color, icon, type) //Works the exact same as above but for skinny people
	var/icon/skinny_clothing_icon = icon(icon, t_color)
	var/icon/skinny_s = icon("icon" = 'icons/effects/clothing.dmi', "icon_state" = "[(type == FEMALE_UNIFORM_FULL) ? "skinny_full" : "skinny_top"]") //Hooks into same check to see if it's eligible
	skinny_clothing_icon.Blend(skinny_s, ICON_MULTIPLY)
	skinny_clothing_icon = fcopy_rsc(skinny_clothing_icon)
	GLOB.skinny_clothing_icons[index] = skinny_clothing_icon

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	var/mob/user_mob = usr
	if(!can_toggle_sensors(user_mob))
		return

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = tgui_input_list(user_mob, "Select a sensor mode", "Suit Sensors", modes, modes[sensor_mode + 1])
	if(isnull(switchMode))
		return
	if(!can_toggle_sensors(user_mob))
		return

	sensor_mode = modes.Find(switchMode) - 1
	if (loc == user_mob)
		switch(sensor_mode)
			if(SENSOR_OFF)
				to_chat(usr, span_notice("You disable your suit's remote sensing equipment."))
			if(SENSOR_LIVING)
				to_chat(usr, span_notice("Your suit will now only report whether you are alive or dead."))
			if(SENSOR_VITALS)
				to_chat(usr, span_notice("Your suit will now only report your exact vital lifesigns."))
			if(SENSOR_COORDS)
				to_chat(usr, span_notice("Your suit will now report your exact vital lifesigns as well as your coordinate position."))

	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.w_uniform == src)
			human_wearer.update_suit_sensors()

/obj/item/clothing/under/proc/can_toggle_sensors(mob/toggler)
	if(!can_use(toggler) || toggler.stat == DEAD) //make sure they didn't hold the window open.
		return FALSE
	if(!toggler.CanReach(src))
		balloon_alert(toggler, "can't reach!")
		return FALSE
	if(is_synth(toggler))
		to_chat(usr, "You're unable to use suit sensors as a synthetic!")
		return

	switch(has_sensor)
		if(LOCKED_SENSORS)
			balloon_alert(toggler, "sensor controls locked!")
			return FALSE
		if(BROKEN_SENSORS)
			balloon_alert(toggler, "sensors shorted!")
			return FALSE
		if(NO_SENSORS)
			balloon_alert(toggler, "no sensors to ajdust!")
			return FALSE

	return TRUE

/obj/item/clothing/under/AltClick(mob/user)
	if(..())
		return 1

	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		if(attached_accessory)
			remove_accessory(user)
		else
			rolldown()

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr
	rolldown()

/obj/item/clothing/under/proc/rolldown(bypass = FALSE)
	if(bypass)
		toggle_jumpsuit_adjust()
		if(usr)
			var/mob/living/carbon/human/H = usr
			H.update_inv_w_uniform()
			H.update_body()
		return
	if(!can_use(usr))
		return
	if(!can_adjust)
		to_chat(usr, span_warning("You cannot wear this suit any differently!"))
		return
	if(toggle_jumpsuit_adjust())
		to_chat(usr, span_notice("You adjust the suit to wear it more casually."))
	else
		to_chat(usr, span_notice("You adjust the suit back to normal."))
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.update_inv_w_uniform()
		H.update_body()

/obj/item/clothing/under/proc/toggle_jumpsuit_adjust() //Yogs Start: Reworking this to allow for Digialt to function
	adjusted = !adjusted
	if(adjusted) //Yogs End
		if(fitted != FEMALE_UNIFORM_TOP)
			fitted = NO_FEMALE_UNIFORM
		if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted (and also the arms, realistically)
			body_parts_covered &= ~CHEST
			body_parts_covered &= ~ARMS
	else
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST
			body_parts_covered |= ARMS
			if(!LAZYLEN(damage_by_parts))
				return adjusted
			for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) // ugly check to make sure we don't reenable protection on a disabled part
				if(damage_by_parts[zone] > limb_integrity)
					for(var/part in body_zone2cover_flags(zone))
						body_parts_covered &= part
	return adjusted

/obj/item/clothing/proc/weldingvisortoggle(mob/user) //proc to toggle welding visors on helmets, masks, goggles, etc.
	if(!can_use(user))
		return FALSE

	visor_toggling()

	to_chat(user, span_notice("You adjust \the [src] [up ? "up" : "down"]."))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()
	return TRUE

/obj/item/clothing/proc/visor_toggling() //handles all the actual toggling of flags
	up = !up
	clothing_flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	flags_cover ^= initial(flags_cover)
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)

/obj/item/clothing/proc/can_use(mob/user)
	if(user && ismob(user))
		if(!user.incapacitated())
			return TRUE
	return FALSE

/obj/item/clothing/atom_destruction(damage_flag, total_destruction=FALSE)
	if(damage_flag == BOMB)
		var/turf/T = get_turf(src)
		spawn(1) //so the shred survives potential turf change from the explosion.
			var/obj/effect/decal/cleanable/shreds/Shreds = new(T)
			Shreds.desc = "The sad remains of what used to be [name]."
		deconstruct(FALSE)
	else if(!(damage_flag in list(ACID, FIRE)))
		damaged_clothes = CLOTHING_SHREDDED
		body_parts_covered = NONE
		name = "shredded [initial(name)]"
		slot_flags = NONE
		update_clothes_damaged_state()
		if(ismob(loc))
			var/mob/M = loc
			M.visible_message(span_danger("[M]'s [src.name] falls off, completely shredded!"), span_warning("<b>Your [src.name] falls off, completely shredded!</b>"), vision_distance = COMBAT_MESSAGE_RANGE)
			M.dropItemToGround(src)
	else
		..()

/// If we're a clothing with at least 1 shredded/disabled zone, give the wearer a periodic heads up letting them know their clothes are damaged
/obj/item/clothing/proc/bristle(mob/living/L)
	if(!istype(L))
		return
	if(prob(0.2))
		to_chat(L, span_warning("The damaged threads on your [src.name] chafe!"))

/*obj/item/clothing/proc/set_sensor_glob()
	var/mob/living/carbon/human/H = src.loc

	if (istype(H.w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/U = H.w_uniform
		if (U.has_sensor && U.sensor_mode && U.has_sensor != BROKEN_SENSORS)
			GLOB.suit_sensors_list |= H

		else
			GLOB.suit_sensors_list -= H

	else
		GLOB.suit_sensors_list -= H	*/
