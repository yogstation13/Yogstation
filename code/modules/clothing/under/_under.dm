/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/uniforms.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	slot_flags = ITEM_SLOT_ICLOTHING
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 5, RAD = 0, FIRE = 0, ACID = 0, WOUND = 5)
	equip_sound = 'sound/items/handling/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	limb_integrity = 30
	tearable = TRUE //all jumpsuits can be torn down and used for cloth in an emergency | yogs

	var/fitted = FEMALE_UNIFORM_FULL // For use in alternate clothing styles for women
	var/has_sensor = HAS_SENSORS // For the crew computer
	var/random_sensor = TRUE
	var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	var/adjusted = FALSE
	var/alt_covers_chest = FALSE // for adjusted/rolled-down jumpsuits, FALSE = exposes chest and arms, TRUE = exposes arms only
	var/mutantrace_variation = NONE //Are there special sprites for specific situations? Don't use this unless you need to.
	var/freshly_laundered = FALSE

	var/obj/item/clothing/accessory/attached_accessory
	var/mutable_appearance/accessory_overlay

/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return
	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
	if(HAS_BLOOD_DNA(src))
		var/mutable_appearance/bloody_uniform = mutable_appearance('icons/effects/blood.dmi', "uniformblood")
		if(species_fitted && icon_exists(bloody_uniform.icon, "uniformblood_[species_fitted]")) 
			bloody_uniform.icon_state = "uniformblood_[species_fitted]"
		else if(HAS_TRAIT(loc, TRAIT_DIGITIGRADE) && !HAS_TRAIT(loc, TRAIT_DIGI_SQUISH))
			bloody_uniform.icon_state = "uniformblood_digi" // not using species_id because other digi legs exist
		bloody_uniform.color = get_blood_dna_color(return_blood_DNA())
		. += bloody_uniform
	if(accessory_overlay)
		. += accessory_overlay

/obj/item/clothing/under/attackby(obj/item/I, mob/user, params)
	if((has_sensor == BROKEN_SENSORS) && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		C.use(1)
		has_sensor = HAS_SENSORS
		to_chat(user,span_notice("You repair the suit sensors on [src] with [C]."))
		return 1
	if(!attach_accessory(I, user))
		return ..()

/obj/item/clothing/under/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	toggle()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS, SENSOR_COORDS)

/obj/item/clothing/under/Destroy()
	if(attached_accessory)
		remove_accessory(loc, TRUE)
	return ..()

/obj/item/clothing/under/emp_act()
	. = ..()
	if(has_sensor > NO_SENSORS)
		sensor_mode = min(pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_VITALS, SENSOR_COORDS), max(sensor_mode - 1, SENSOR_OFF))//pick a random sensor level below the current one
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M,span_warning("The sensors on the [src] change rapidly!"))

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = FALSE
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(slot == ITEM_SLOT_ICLOTHING && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

	if(!ishuman(user)) //Yogs Start: Reorganized to reduce repetition
		return
	var/update_suit = FALSE
	var/mob/living/carbon/human/human_user = user
	if(!(mutantrace_variation & DIGITIGRADE_VARIATION) && (body_parts_covered & LEGS))
		if(slot_flags & slot)
			ADD_TRAIT(user, TRAIT_DIGI_SQUISH, REF(src))
		else
			REMOVE_TRAIT(user, TRAIT_DIGI_SQUISH, REF(src))
		human_user.update_inv_shoes()
		human_user.update_body_parts()
		update_suit = TRUE
//Yogs End
	if(attached_accessory && slot != ITEM_SLOT_HANDS)
		attached_accessory.on_clothing_equip(src, user)
		if(attached_accessory.above_suit)
			update_suit = TRUE
	if(update_suit)
		human_user.update_inv_wear_suit()
	if(is_synth(user) && has_sensor)
		to_chat(user, span_notice("Suit sensors disabled due to non-compatible user."))
		sensor_mode = SENSOR_OFF

/obj/item/clothing/under/dropped(mob/user)
	if(ishuman(user))
		var/update_suit = FALSE
		var/mob/living/carbon/human/human_user = user
		if(!(mutantrace_variation & DIGITIGRADE_VARIATION) && (body_parts_covered & LEGS))
			REMOVE_TRAIT(user, TRAIT_DIGI_SQUISH, REF(src))
			human_user.update_inv_shoes()
			human_user.update_body_parts()
			update_suit = TRUE
		if(attached_accessory)
			attached_accessory.on_clothing_dropped(src, user)
			if(attached_accessory.above_suit)
				update_suit = TRUE
		if(update_suit)
			human_user.update_inv_wear_suit()
	return ..()

/obj/item/clothing/under/proc/attach_accessory(obj/item/I, mob/user, notifyAttach = 1)
	. = FALSE
	if(istype(I, /obj/item/clothing/accessory))
		var/obj/item/clothing/accessory/A = I
		if(attached_accessory)
			if(user)
				to_chat(user, span_warning("[src] already has an accessory."))
			return
		else

			if(!A.can_attach_accessory(src, user)) //Make sure the suit has a place to put the accessory.
				return
			if(user && !user.temporarilyRemoveItemFromInventory(I))
				return
			if(!A.attach(src, user))
				return

			if(user && notifyAttach)
				to_chat(user, span_notice("You attach [I] to [src]."))

			var/accessory_color = attached_accessory.icon_state
			accessory_overlay = mutable_appearance(attached_accessory.worn_icon, "[accessory_color]")
			accessory_overlay.alpha = attached_accessory.alpha
			accessory_overlay.color = attached_accessory.color

			if(ishuman(loc))
				var/mob/living/carbon/human/H = loc
				H.update_inv_w_uniform()
				H.update_inv_wear_suit()

			return TRUE

/obj/item/clothing/under/proc/remove_accessory(mob/user, forced)
	if(!isliving(user) && !forced)
		return
	if(!can_use(user) && !forced)
		return

	if(attached_accessory)
		var/obj/item/clothing/accessory/A = attached_accessory
		attached_accessory.detach(src, user)
		if(user.put_in_hands(A) && !forced)
			to_chat(user, span_notice("You detach [A] from [src]."))
		else
			to_chat(user, span_notice("You detach [A] from [src] and it falls on the floor."))
			var/turf/T = get_turf(src)
			if(!T)
				T = get_turf(user)
			if(T)
				A.forceMove(T)
		
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			H.update_inv_w_uniform()
			H.update_inv_wear_suit()


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(freshly_laundered)
		. += "It looks fresh and clean."
	if(can_adjust)
		if(adjusted)
			. += "Alt-click on [src] to wear it normally."
		else
			. += "Alt-click on [src] to wear it casually."
	if (has_sensor == BROKEN_SENSORS)
		. += "Its sensors appear to be shorted out."
	else if(has_sensor > NO_SENSORS)
		switch(sensor_mode)
			if(SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SENSOR_LIVING)
				. += "Its binary life sensors appear to be enabled."
			if(SENSOR_VITALS)
				. += "Its vital tracker appears to be enabled."
			if(SENSOR_COORDS)
				. += "Its vital tracker and tracking beacon appear to be enabled."
	if(attached_accessory)
		. += "\A [attached_accessory] is attached to it."

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER
