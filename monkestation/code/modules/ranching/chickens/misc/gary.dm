///gary is gonna have nothing to do with other crows because of how much unique code it has
/mob/living/basic/chicken/gary
	worn_slot_flags = null
	breed_name_male = "Gary"
	breed_name_female = "Gary"
	desc = "Gary the Crow. An inquisitive, yet cruel barterer."
	icon_suffix = "crow_gary"
	icon_state = "crow_gary"
	pass_flags = parent_type::pass_flags | PASSGRILLE | PASSFLAPS | PASSDOORS
	ai_controller = /datum/ai_controller/chicken/gary

	mutation_list = list()

	///birb can hold smoll item
	var/obj/item/held_item

	///read our memories for setting up
	var/fully_setup = FALSE
	///have we saved our memory
	var/memory_saved = FALSE
	///rounds since last death
	var/rounds_survived = 0
	///largest concurrent rounds survived
	var/longest_survival = 0
	///largest concurrent rounds died
	var/longest_deathstreak = 0
	///list of held shinies
	var/list/held_shinies = list()

	var/datum/hideout/hideout
	var/datum/callback/roundend_callback = null

	var/max_w_class = WEIGHT_CLASS_SMALL

/mob/living/basic/chicken/gary/Initialize(mapload, turf/open/home)
	. = ..()
	if(!memory_saved)
		roundend_callback = CALLBACK(src, PROC_REF(Write_Memory))
		SSticker.OnRoundend(roundend_callback)
	Read_Memory()
	AddComponent(/datum/component/regenerator)
	add_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_GOES_THROUGH_WOODEN_BARRICADES, TRAIT_WATER_BREATHING), INNATE_TRAIT) // gary REALLY balls (also gary making a hideout in a pool is funny)
	set_home(home)
	// remove unused chicken components for gary
	qdel(GetComponent(/datum/component/aging))
	qdel(GetComponent(/datum/component/hovering_information))

/mob/living/basic/chicken/gary/Destroy()
	drop_held_item()
	LAZYREMOVE(SSticker.round_end_events, roundend_callback)
	roundend_callback = null //This ought to free the callback datum, and prevent us from harddeling
	QDEL_NULL(hideout)
	return ..()

/mob/living/basic/chicken/gary/death(gibbed)
	drop_held_item()
	. = ..()
	Write_Memory(TRUE)

/mob/living/basic/chicken/gary/unhappy_death()
	return

/mob/living/basic/chicken/gary/proc/drop_held_item()
	if(QDELETED(held_item))
		return
	held_item.forceMove(drop_location())
	held_item = null

/mob/living/basic/chicken/gary/proc/set_home(turf/open/new_home)
	var/datum/ai_controller/chicken/gary/gary_controller = ai_controller
	gary_controller.set_home(new_home)

/mob/living/basic/chicken/gary/proc/Read_Memory()
	if(fexists("data/npc_saves/Gary.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Gary.sav")
		S["roundssurvived"]		>> rounds_survived
		S["longestsurvival"]	>> longest_survival
		S["longestdeathstreak"] >> longest_deathstreak
		S["heldshines"] 			>> held_shinies
		fdel("data/npc_saves/Gary.sav")
	else
		var/json_file = file("data/npc_saves/Gary.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		rounds_survived = json["roundssurvived"]
		longest_survival = json["longestsurvival"]
		longest_deathstreak = json["longestdeathstreak"]
		held_shinies = json["heldshines"]
		sanitize_shinies()

/mob/living/basic/chicken/gary/Write_Memory(dead, gibbed)
	. = ..()
	if(!.)
		return
	memory_saved = TRUE
	var/json_file = file("data/npc_saves/Gary.json")
	var/list/file_data = list()
	if(dead)
		file_data["roundssurvived"] = min(rounds_survived - 1, 0)
		file_data["longestsurvival"] = longest_survival
		file_data["heldshines"] = list() //punished for killing
		if(rounds_survived - 1 < longest_deathstreak)
			file_data["longestdeathstreak"] = rounds_survived - 1
		else
			file_data["longestdeathstreak"] = longest_deathstreak
	else
		file_data["roundssurvived"] = rounds_survived + 1
		if(rounds_survived + 1 > longest_survival)
			file_data["longestsurvival"] = rounds_survived + 1
		else
			file_data["longestsurvival"] = longest_survival
		file_data["longestdeathstreak"] = longest_deathstreak
	file_data["heldshines"] = held_shinies + file_data["heldshines"]
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/basic/chicken/gary/proc/sanitize_shinies()
	var/list/uncleaned = held_shinies.Copy()
	held_shinies.Cut()
	for(var/dirty in uncleaned)
		held_shinies += text2path(dirty)
	list_clear_nulls(held_shinies)

/mob/living/basic/chicken/gary/proc/return_stored_items()
	if(!fully_setup)
		Read_Memory()
	return held_shinies

/mob/living/basic/chicken/gary/attackby(obj/item/attacking_item, mob/living/user)
	if(stat != CONSCIOUS || (user.istate & ISTATE_HARM) || !user.Adjacent(src) || (attacking_item.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM)))
		return ..()
	if(attacking_item.w_class <= max_w_class)
		if(!QDELETED(held_item))
			to_chat(user, span_warning("[src] is already holding [held_item]!"))
			return TRUE
		if(!user.transferItemToLoc(attacking_item, src))
			return TRUE
		if(istype(attacking_item, /obj/item/knife))
			attack_sound = 'sound/weapons/bladeslice.ogg'
			melee_damage_upper = attacking_item.force //attack dmg inherits knife dmg
			melee_damage_lower = attacking_item.force
			icon_state = "crow_gary_knife"
			qdel(attacking_item)
			return TRUE
		else
			if(SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHECK_LEVEL, user, FRIENDSHIP_BESTFRIEND))
				var/barter_choice = show_radial_menu(user, src, hideout.stored_items, autopick_single_option = FALSE)
				if(barter_choice)
					ai_controller.blackboard[BB_GARY_BARTERING] = TRUE
					ai_controller.blackboard[BB_GARY_BARTER_TARGET] = WEAKREF(user)
					ai_controller.blackboard[BB_GARY_BARTER_ITEM] = barter_choice
					ai_controller.blackboard[BB_GARY_BARTER_STEP] = 1

			held_item = attacking_item
			ai_controller.blackboard[BB_GARY_COME_HOME] = TRUE
			ai_controller.blackboard[BB_GARY_HAS_SHINY] = TRUE
			SEND_SIGNAL(src, COMSIG_MOB_ADJUST_HUNGER, 200) //gary hungers for trinkets and baubles.
			return TRUE
	else
		to_chat(user, span_warning("[attacking_item] is too big for [src] to hold!"))
		return TRUE
