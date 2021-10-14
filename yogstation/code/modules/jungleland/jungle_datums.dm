GLOBAL_DATUM_INIT(herb_manager,/datum/herb_manager,new)

/datum/herb_manager
	var/list/possible_chems
	var/list/herb_chems
	
/datum/herb_manager/New()
	. = ..()
	initialize_herb_chems()

/datum/herb_manager/Destroy(force, ...)
	message_admins("For some reason herb manager is being deleted, it will SEVERELY fuck up jungleland herb system, what are you even doing?")
	return ..()
	
/datum/herb_manager/proc/initialize_herb_chems()
	var/list/herbs = subtypesof(/obj/structure/herb)
	var/picked_chem = pick(possible_chems)
	herb_chems[pick(herbs)] = picked_chem
	possible_chems -= picked_chem

/datum/herb_manager/proc/get_chem(type)
	return herb_chems[type]

//screen shit

/obj/screen/fullscreen/trip
	icon_state = "trip0"
	layer = TRIP_LAYER
	plane = FULLSCREEN_PLANE
	alpha = 0 //we animate it ourselves


// reagents

/datum/reagent/jungle
	name = "Impossible Jungle Chem"
	description = "A reagent that is impossible to make in the jungle."
	can_synth = FALSE
	taste_description = "jungle"

/datum/reagent/jungle/retrosacharide
	name = "Retrosacharide"
	description = "Sacharide with a twisting structure that resembles the golden spiral."
	taste_description = "starch"

/datum/reagent/jungle/retrosacharide/on_mob_metabolize(mob/living/L)
	. = ..()
	

/datum/reagent/jungle/retrosacharide/on_mob_life(mob/living/L)
	. = ..()
	

/datum/reagent/jungle/retrosacharide/on_mob_end_metabolize(mob/living/L)
	. = ..()

/datum/reagent/jungle/polybycin
	name = "Polybycin"
	description = "An unknown molecule with simmiliar structure to psychodelics found on terra, effects unknown."
	taste_description = "madness"
	metabolization_rate = REAGENTS_METABOLISM / 2

	var/offset = 0;
	var/obj/screen/fullscreen/trip/cached_screen

/datum/reagent/jungle/polybycin/on_mob_metabolize(mob/living/L)
	. = ..()
	add_filters(L)
	
/datum/reagent/jungle/polybycin/on_mob_life(mob/living/L)
	. = ..()
	update_filters(L)

/datum/reagent/jungle/polybycin/on_mob_end_metabolize(mob/living/L)
	remove_filters(L)
	. = ..()

// I seperated these functions from the ones right above this comment for clarity, and because i wanted to seperate visual stuff from effects stuff, makes it easier to understand.
/datum/reagent/jungle/polybycin/proc/add_filters(mob/living/L)
	if(!L.client)
		return
	//get all relevant planes
	var/obj/screen/plane_master/game_world/game_plane = locate(/obj/screen/plane_master/game_world) in L.client.screen
	var/obj/screen/plane_master/floor/floor_plane  = locate(/obj/screen/plane_master/floor) in L.client.screen
	var/obj/screen/plane_master/lighting/light_plane  = locate(/obj/screen/plane_master/lighting) in L.client.screen

	//add our shit
	game_plane.add_filter("polybycin_wave",1,list("type"="wave", "x"=64, "y"=64, "size"=0, "offset"=offset, "flags" = WAVE_BOUNDED))
	floor_plane.add_filter("polybycin_wave",1,list("type"="wave", "x"=64, "y"=64, "size"=0, "offset"=offset, "flags" = WAVE_BOUNDED))
	light_plane.add_filter("polybycin_wave",1,list("type"="wave", "x"=64, "y"=64, "size"=0, "offset"=offset, "flags" = WAVE_BOUNDED))
	cached_screen = L.overlay_fullscreen("polycybin_trip",/obj/screen/fullscreen/trip)

/datum/reagent/jungle/polybycin/proc/remove_filters(mob/living/L)
	if(!L.client)
		return
	//get all relevant planes
	var/obj/screen/plane_master/game_world/game_plane = locate(/obj/screen/plane_master/game_world) in L.client.screen
	var/obj/screen/plane_master/floor/floor_plane  = locate(/obj/screen/plane_master/floor) in L.client.screen
	var/obj/screen/plane_master/lighting/light_plane  = locate(/obj/screen/plane_master/lighting) in L.client.screen

	//remove our shit
	game_plane.remove_filter("polybycin_wave")
	floor_plane.remove_filter("polybycin_wave")
	light_plane.remove_filter("polybycin_wave")
	cached_screen = null
	L.clear_fullscreen("polycybin_trip")
	

/datum/reagent/jungle/polybycin/proc/update_filters(mob/living/L)
	if(!L.client)
		return
	//we have to do this way, otherwise simple log-relog would cause all of filters to vanish into the void
	var/obj/screen/plane_master/game_world/game_plane = locate(/obj/screen/plane_master/game_world) in L.client.screen
	var/obj/screen/plane_master/floor/floor_plane  = locate(/obj/screen/plane_master/floor) in L.client.screen
	var/obj/screen/plane_master/lighting/light_plane  = locate(/obj/screen/plane_master/lighting) in L.client.screen
	if(!game_plane.get_filter("polybycin_wave") || !floor_plane.get_filter("polybycin_wave") || !light_plane.get_filter("polybycin_wave") )
		add_filters(L)

	//update the variables required for the filters
	offset++
	var/new_x = game_plane.get_filter("polybycin_wave"):x + rand(-1,1)
	var/new_y = game_plane.get_filter("polybycin_wave"):y + rand(-1,1)

	//animate filters
	animate(game_plane.get_filter("polybycin_wave"), offset=offset, size = min(current_cycle,volume)/3, x = new_x, y = new_y , time = 2 SECONDS)
	animate(floor_plane.get_filter("polybycin_wave"), offset=offset, size = min(current_cycle,volume)/3,x = new_x, y = new_y , time = 2 SECONDS)
	animate(light_plane.get_filter("polybycin_wave"), offset=offset, size = min(current_cycle,volume)/3,x = new_x, y = new_y , time = 2 SECONDS)
	animate(cached_screen, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
