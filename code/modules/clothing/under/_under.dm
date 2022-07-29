/obj/item/clothing/under
	icon = 'icons/obj/clothing/uniforms.dmi'
	name = "under"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	permeability_coefficient = 0.9
	slot_flags = ITEM_SLOT_ICLOTHING
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, WOUND = 5)
	equip_sound = 'sound/items/handling/jumpsuit_equip.ogg'
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	limb_integrity = 30
	var/fitted = FEMALE_UNIFORM_FULL // For use in alternate clothing styles for women
	var/has_sensor = HAS_SENSORS // For the crew computer
	var/random_sensor = TRUE
	var/sensor_mode = NO_SENSORS
	var/can_adjust = TRUE
	var/adjusted = NORMAL_STYLE
	var/alt_covers_chest = FALSE // for adjusted/rolled-down jumpsuits, FALSE = exposes chest and arms, TRUE = exposes arms only
	var/obj/item/clothing/accessory/attached_accessory
	var/mutable_appearance/accessory_overlay
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION //Are there special sprites for specific situations? Don't use this unless you need to.
	var/freshly_laundered = FALSE
	tearable = TRUE //all jumpsuits can be torn down and used for cloth in an emergency | yogs

/obj/item/clothing/under/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform")
		if(HAS_BLOOD_DNA(src))
			. += mutable_appearance('icons/effects/blood.dmi', "uniformblood")
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

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_w_uniform()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS

/obj/item/clothing/under/Initialize()
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
		sensor_mode = pick(SENSOR_OFF, SENSOR_OFF, SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS)
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M,span_warning("The sensors on the [src] change rapidly!"))

/obj/item/clothing/under/equipped(mob/user, slot)
	..()
	if(adjusted)
		adjusted = NORMAL_STYLE
		fitted = initial(fitted)
		if(!alt_covers_chest)
			body_parts_covered |= CHEST

	if(slot == SLOT_W_UNIFORM && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

	if(!ishuman(user)) //Yogs Start: Reorganized to reduce repetition
		return
	var/mob/living/carbon/human/H = user
	
	if(mutantrace_variation == MUTANTRACE_VARIATION)
		var/is_digi = FALSE
		if(DIGITIGRADE in H.dna.species.species_traits)
			is_digi = TRUE
		
		if(is_digi && !adjusted == ALT_STYLE && mutantrace_variation)
			adjusted = DIGITIGRADE_STYLE
		else if(is_digi && adjusted == ALT_STYLE && mutantrace_variation) //Handles when you are using an alternate style while having digi legs
			adjusted = DIGIALT_STYLE
		else if(!is_digi && adjusted == DIGITIGRADE_STYLE)
			adjusted = NORMAL_STYLE
		else if(!is_digi && adjusted == DIGIALT_STYLE)
			adjusted = ALT_STYLE
		H.update_inv_w_uniform()
//Yogs End
	if(attached_accessory && slot != SLOT_HANDS)
		attached_accessory.on_clothing_equip(src, user)
		if(attached_accessory.above_suit)
			H.update_inv_wear_suit()

/obj/item/clothing/under/dropped(mob/user)
	if(attached_accessory)
		attached_accessory.on_clothing_dropped(src, user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(attached_accessory.above_suit)
				H.update_inv_wear_suit()
	..()

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
			accessory_overlay = mutable_appearance(attached_accessory.mob_overlay_icon, "[accessory_color]")
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
		if(adjusted == ALT_STYLE || adjusted == DIGIALT_STYLE)
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
