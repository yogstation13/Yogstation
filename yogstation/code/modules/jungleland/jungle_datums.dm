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
	icon_state = "trip"
	layer = TRIP_LAYER
	alpha = 0 //we animate it ourselves

//floor trip
/obj/screen/fullscreen/ftrip
	icon_state = "ftrip"
	icon = 'yogstation/icons/mob/screen_full_big.dmi'
	screen_loc = "CENTER-9,CENTER-7"
	appearance_flags = TILE_BOUND
	layer = ABOVE_OPEN_TURF_LAYER
	plane = BLACKNESS_PLANE
	alpha = 0 //we animate it ourselves

//wall trip
/obj/screen/fullscreen/gtrip
	icon_state = "gtrip"
	icon = 'yogstation/icons/mob/screen_full_big.dmi'	
	screen_loc = "CENTER-9,CENTER-7"
	appearance_flags = TILE_BOUND
	layer = BELOW_MOB_LAYER
	plane = BLACKNESS_PLANE 
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
	var/obj/screen/fullscreen/ftrip/cached_screen_floor
	var/obj/screen/fullscreen/gtrip/cached_screen_game

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
	if(!L.hud_used || !L.client)
		return

	var/obj/screen/plane_master/game_world/game_plane =  L.hud_used.plane_masters["[GAME_PLANE]"]
	var/obj/screen/plane_master/floor/floor_plane  = L.hud_used.plane_masters["[FLOOR_PLANE]"]

	cached_screen = L.overlay_fullscreen("polycybin_trip",/obj/screen/fullscreen/trip)
	cached_screen_floor = L.overlay_fullscreen("polycybin_ftrip",/obj/screen/fullscreen/ftrip)
	cached_screen_game = L.overlay_fullscreen("polycybin_gtrip",/obj/screen/fullscreen/gtrip)

	cached_screen_floor.add_filter("polycybin_ftrip",1,list("type"="alpha","render_source"=floor_plane.get_render_target()))
	cached_screen_game.add_filter("polycybin_gtrip",1,list("type"="alpha","render_source"=game_plane.get_render_target()))

/datum/reagent/jungle/polybycin/proc/remove_filters(mob/living/L)
	if(!L.client)
		return
	
	cached_screen = null
	cached_screen_floor = null
	cached_screen_game = null
	
	L.clear_fullscreen("polycybin_trip")
	L.clear_fullscreen("polycybin_ftrip")
	L.clear_fullscreen("polycybin_gtrip")
	

/datum/reagent/jungle/polybycin/proc/update_filters(mob/living/L)
	if(!L.client)
		return
	
	animate(cached_screen, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
	animate(cached_screen_floor, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
	animate(cached_screen_game, alpha = min(min(current_cycle,volume)/25,1)*255, time = 2 SECONDS)
