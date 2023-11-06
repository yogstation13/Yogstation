/datum/eldritch_transmutation/void_knife
	name = "Frozen Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/shard) 
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	required_shit_list = "A clear shard of glass and a knife."

/datum/eldritch_transmutation/void_cloak
	name = "Void Cloak"
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/cultrobes/void)
	required_shit_list = "glass shard, clothing, bedsheet"

/datum/eldritch_transmutation/rune_carver
	name = "Carving Knife"
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/paper = 1
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	required_shit_list = "glass shard, piece of paper"

/datum/eldritch_transmutation/lionhunter
	name = "Lionhunter Rifle"
	required_atoms = list(
		/obj/item/gun = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/camera,
		/obj/item/stack/sheet/mineral/gold

	)
	result_atoms = list(/obj/item/gun/ballistic/rifle/boltaction/lionhunter)
	required_shit_list = "A gun, a piece of wood, a camera, and a piece of gold"


/datum/eldritch_transmutation/lionhunter_ammo
	name = "Lionhunter Rifle Ammo"
	required_atoms = list(
		/obj/item/ammo_casing = 3,
		/obj/item/stack/sheet/mineral/silver = 5

	)
	result_atoms = list(/obj/item/ammo_casing/strilka310/lionhunter)
	required_shit_list = "Three ammo casings and five bars of silver."

/datum/eldritch_transmutation/rune_carver
	name = "Carving Knife"
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/paper = 1
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	required_shit_list = "glass shard, piece of paper"


/datum/eldritch_transmutation/final/void_final
	name = "Waltz at the End of Time"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/void_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	var/datum/weather/void_storm/storm
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.AddComponent(/datum/component/ice_walk)
	
	ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, MAGIC_TRAIT)
	
	SIGNAL_HANDLER

	for(var/mob/living/carbon/close_carbon in view(5, user))
		if(IS_HERETIC_OR_MONSTER(close_carbon))
			continue
		close_carbon.adjust_silence_up_to(2 SECONDS, 20 SECONDS)

	// Telegraph the storm in every area on the station.
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!storm)
		storm = new /datum/weather/void_storm(station_levels)
		storm.telegraph()

	// When the heretic enters a new area, intensify the storm in the new area,
	// and lessen the intensity in the former area.
	var/area/source_area = get_area(user)
	if(!storm.impacted_areas[source_area])
		storm.former_impacted_areas |= storm.impacted_areas
		storm.impacted_areas = list(source_area)
		storm.update_areas()
		
	priority_announce("Immense destabilization of the bluespace veil has been observed. @&#^$&#^@# The nobleman of void [user.real_name] has arrived, stepping along the Waltz that ends worlds!  $&#^@#@&#^ Immediate evacuation is advised.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
		
	return ..()
