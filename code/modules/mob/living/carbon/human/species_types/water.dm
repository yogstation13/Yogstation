#define WATER_VOLUME_MAXIMUM 1000
#define WATER_VOLUME_LIMB_LOSS (WATER_VOLUME_MAXIMUM / 4)
#define WATER_VOLUME_LIMB_LOSS_THRESHOLD (WATER_VOLUME_MAXIMUM - WATER_VOLUME_LIMB_LOSS)

/obj/item/organ/lungs/water
	name = "vile sponge"
	desc = "A spongy mass that looks like it is designed to carbonate water, what is it doing in a body?"

	safe_oxygen_min = 0
	safe_co2_min = 16 
	safe_co2_max = 0

/datum/species/water
	name = "placeholder water race"
	id = "water"
	rare_say_mod = list("gushes" = 10, "slushes" = 10, "spits" = 10, "splutters" = 10, "slobbers" = 10)
	default_color = "56CACE"
	species_traits = list(MUTCOLORS, HAS_FLESH, NOSTOMACH, NOLIVER, TRAIT_NOHUNGER, NOTRANSSTING, NO_DNA_COPY, NOBLOOD) // "blood" will be handled seperately
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RADIMMUNE,TRAIT_GENELESS,TRAIT_NOHUNGER,TRAIT_HARDLY_WOUNDED, TRAIT_VIRUSIMMUNE, TRAIT_NODISMEMBER, TRAIT_RESISTHIGHPRESSURE) //can't compress water
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutantlungs = /obj/item/organ/lungs/water
	payday_modifier = 0.3
	burnmod = 1.5 //Water heats easily
	heatmod = 1.5 //Water heats easily
	brutemod = 1.1 //Ever hit water?
	coldmod = 2 // Water freezes quite easily due to less metabolic processes
	speedmod = 0.5
	breathid = "co2"
	var/falling_apart = FALSE
	var/water_volume = WATER_VOLUME_MAXIMUM 
	var/water_blob = /mob/living/simple_animal/waterblob

/datum/species/water/proc/fall_apart(mob/living/carbon/human/H)
	. = ..()
	falling_apart = TRUE
	H.visible_message(span_danger("[H] begins to drip..."), span_danger("You can feel yourself dripping..."))
	spawn(40)
		if (!should_fall_apart(H))
			falling_apart = FALSE
			return
		//actually fall apart
		H.visible_message(span_danger("[H] falls apart!"), span_danger("You fall apart!"))

	
		for(var/obj/item/W in H.get_equipped_items(TRUE))
			H.dropItemToGround(W)
		for(var/obj/item/I in H.held_items)
			H.dropItemToGround(I)

		var/mob/living/new_mob = new water_blob(H.loc)
		if(istype(new_mob))
			if(H.mind)
				H.mind.transfer_to(new_mob)
			else
				new_mob.key = H.key

		new_mob.name = H.real_name
		new_mob.real_name = new_mob.name
		
		qdel(H)

		falling_apart = FALSE

/datum/species/water/proc/should_fall_apart(mob/living/carbon/human/H)
	if (!istype(H.w_uniform) || !istype(H.head))
		return TRUE

	var/datum/component/wetsuit_holder/body_component = H.w_uniform.GetComponent(/datum/component/wetsuit_holder)
	var/datum/component/wetsuit_holder/head_component = H.head.GetComponent(/datum/component/wetsuit_holder)
	if(!istype(body_component) || !istype(head_component))
		if (istype(H.wear_suit) && istype(H.head))
			if (H.head.clothing_flags & STOPSPRESSUREDAMAGE && H.wear_suit.clothing_flags & STOPSPRESSUREDAMAGE)
				return FALSE
		return TRUE


	return FALSE

/datum/species/water/proc/remove_limb(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!limbs_to_consume.len)
		return FALSE

	if(H.get_num_legs(FALSE)) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, span_userdanger("Your [consumed_limb] is subsumed into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	water_volume += 20

/datum/species/water/spec_life(mob/living/carbon/human/H)
	if(should_fall_apart(H) && falling_apart == FALSE)
		INVOKE_ASYNC(src, .proc/fall_apart, H)
	
	if (water_volume < WATER_VOLUME_LIMB_LOSS_THRESHOLD)
		var/limb_to_remove = floor(water_volume / WATER_VOLUME_LIMB_LOSS)
		var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
		
		

		remove_limb(H)
	

/datum/species/water/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()
	H.visible_message(span_danger("[H] turns into a fine blue mist!"), span_danger("You evaporate!"))
	return H.gib(TRUE, TRUE, TRUE) // HARD MODE: You're not coming back from this one

/datum/component/wetsuit_holder
	var/integrity = 100

/obj/item/clothing/under/wetsuit
	name = "bodily integrity wetsuit"
	desc = "The suit that holds placeholder water races together. Without a suit compatible of contorting them, they would quickly fall apart."
	icon_state = "plasmaman"
	item_state = "plasmaman"
	item_color = "plasmaman"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE

/obj/item/clothing/under/wetsuit/Initialize()
	AddComponent(/datum/component/wetsuit_holder)
	. = ..()

/obj/item/clothing/head/helmet/space/plasmaman/wetsuit
	name = "bodily integrity wetsuit helmet"
	desc = "The head for the wetsuit; one of the only things keeping a placeholder water race from disintegrating."

/obj/item/clothing/head/helmet/space/plasmaman/wetsuit/Initialize()
	AddComponent(/datum/component/wetsuit_holder)
	. = ..()

/mob/living/simple_animal/waterblob
	name = "slobbery mess"
	desc = "Something that can only be described as a bubbling viscous puddle extending tendrils to wherever it moves."
