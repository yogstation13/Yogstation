/mob/living/carbon/alien
	name = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = FEMALE //All xenos are girls!!
	dna = null
	faction = list(ROLE_ALIEN)
	ventcrawler = VENTCRAWLER_ALWAYS
	sight = SEE_MOBS
	see_in_dark = 4
	verb_say = "hisses"
	initial_language_holder = /datum/language_holder/alien
	bubble_icon = "alien"
	type_of_meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = 0
	status_flags = CANUNCONSCIOUS|CANPUSH

	var/heat_protection = 0.5
	gib_type = /obj/effect/decal/cleanable/xenoblood/xgibs
	unique_name = 1

	/// Determines whether or not the alien is leaping.  Currently only used by the hunter.
	var/leaping = FALSE
	/// Used to detmine how to name the alien.
	var/static/regex/alien_name_regex = new("alien (larva|sentinel|drone|hunter|praetorian|queen)( \\(\\d+\\))?")
	blood_volume = BLOOD_VOLUME_XENO //Yogs -- Makes monkeys/xenos have different amounts of blood from normal carbonbois

	var/melee_damage_lower = 20
	var/melee_damage_upper = 20

/mob/living/carbon/alien/Initialize()
	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/lay_down)

	create_bodyparts() //initialize bodyparts

	create_internal_organs()

	. = ..()

/mob/living/carbon/alien/create_internal_organs()
	internal_organs += new /obj/item/organ/brain/alien
	internal_organs += new /obj/item/organ/alien/hivenode
	internal_organs += new /obj/item/organ/tongue/alien
	internal_organs += new /obj/item/organ/eyes/night_vision/alien
	internal_organs += new /obj/item/organ/liver/alien
	internal_organs += new /obj/item/organ/ears
	..()

/mob/living/carbon/alien/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/alien/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)
	var/heat_capacity_factor = min(1, environment.heat_capacity() / environment.return_volume())

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of heat protection.
			if(thermal_protection < 1)
				adjust_bodytemperature((1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR) * heat_capacity_factor)
		else
			adjust_bodytemperature(heat_capacity_factor * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR))

	if(bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
		//Body temperature is too hot.
		throw_alert("alien_fire", /obj/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
	else
		clear_alert("alien_fire")

/mob/living/carbon/alien/reagent_check(datum/reagent/R) //can metabolize all reagents
	return 0

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/alien/get_status_tab_items()
	. = ..()
	. += "Intent: [a_intent]"

/mob/living/carbon/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))

/mob/living/carbon/alien/canBeHandcuffed()
	return 1


/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()

/mob/living/carbon/alien/on_standing_up()
	. = ..()
	update_icons()

/**
 * Renders an icon on mobs with alien embryos inside them.
 *
 * Renders an icon on mobs with alien embryos inside them for the client.
 * Only aliens can see these, with others not seeing anything at all.
 */
/mob/living/carbon/alien/proc/AddInfectionImages()
	if(!client)
		return
	for(var/lb in GLOB.mob_living_list)
		var/mob/living/livingbeing = lb
		if(!HAS_TRAIT(livingbeing, TRAIT_XENO_HOST))
			return
		var/obj/item/organ/body_egg/alien_embryo/embryo = livingbeing.getorgan(/obj/item/organ/body_egg/alien_embryo)
		if(!embryo)
			return
		var/embryo_image = image('icons/mob/alien.dmi', loc = livingbeing, icon_state = "infected[embryo.stage]")
		client.images += embryo_image

/**
 * Removes all client embryo displays.
 *
 * Removes the embryo icon visuals from the client controlling the alien.
 */
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(!client)
		return
	for(var/i in client.images)
		var/image/image = i
		var/searchfor = "infected"
		if(findtext(image.icon_state, searchfor, 1, length(searchfor) + 1))
			qdel(image)

/**
 * Handles the transformations of one alien type to another.
 *
 * Handles the transformation of an alien into another type of alien.
 * Gives them some message fluff, transfers their mind (important as to transfer other antag statuses)
 * and then also transfers their nanites should the original body have them.
 * Arguments:
 * * new_xeno - The new body of the alien.
 */

/mob/living/carbon/alien/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/carbon/alien/proc/alien_evolve(mob/living/carbon/alien/new_xeno)
	to_chat(src, span_noticealien("You begin to evolve!"))
	visible_message(span_alertalien("[src] begins to twist and contort!"))
	new_xeno.setDir(dir)
	if(!alien_name_regex.Find(name))
		new_xeno.name = name
		new_xeno.real_name = real_name
	if(mind)
		mind.transfer_to(new_xeno)
	qdel(src)

/mob/living/carbon/alien/can_hold_items()
	return has_fine_manipulation
