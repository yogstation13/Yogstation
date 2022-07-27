#define BREAK_FREE_TIME 7 ///7 minutes

/obj/structure/destructible/hog_structure/lance/nexus
	name = "\improper Nexus"
	desc = "There is a god's soul inside. Kill it, and the god will die."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "nexus"
	anchored = TRUE
	density = TRUE
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield, /datum/hog_god_interaction/structure/mass_recall)
	max_integrity = 500
	break_message = span_cultlarge("The nexus explodes in a bright flash of light!") 
	var/last_scream
	var/mob/camera/hog_god/god
	var/active = FALSE
	var/progress = 0
	var/estimated_time = BREAK_FREE_TIME
	constructor_range = 20

/obj/structure/destructible/hog_structure/lance/nexus/Initialize()
	. = ..()

/obj/structure/destructible/hog_structure/lance/nexus/Destroy()
	if(cult && cult.state != HOG_TEAM_SUMMONED)
		cult.die()
	. = ..()

/obj/structure/destructible/hog_structure/lance/nexus/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.)
		if(last_scream < world.time)
			cult.message_all_dudes("<span class='cultlarge'><b>Your nexus is under attack! Defend it, or your cult will perish!</b></span>", FALSE)
			last_scream = world.time + 10 SECONDS

/obj/structure/destructible/hog_structure/lance/nexus/proc/Activate()
	active = TRUE
	priority_announce("An unknown bluespace entity is being summoned in [get_area(src)]. All crew are directed to \
	@!$, stop this rituall at all cost to prevent further damage to corporate property and save the station from destruction. This is \
	not a drill. Estimated time of the rituall completion - [BREAK_FREE_TIME] minutes.", \
	"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg') ///I don't have any my own sounds, so... you know.
	set_security_level(SEC_LEVEL_GAMMA)
	addtimer(CALLBACK(src, .proc/Sex), 1 MINUTES)	
	cult.message_all_dudes("<span class='cultlarge'><b>Servants of [god.name]! Our time has come! Defend the nexus at all costs!</b></span>", TRUE)
	cult.state = HOG_TEAM_SUMMONING
	for(var/V in cult.members)
		var/datum/mind/M = V
		if(!M || !M.current)
			continue
		if(ishuman(M.current))
			M.current.add_overlay(mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER))  //I will change this when i will get sprites

/obj/structure/destructible/hog_structure/lance/nexus/proc/Sex()
	if(progress == BREAK_FREE_TIME)	
		max_integrity = INFINITY
		cult.state = HOG_TEAM_SUMMONED
		SSshuttle.emergencyCallTime = 1800
		SSshuttle.emergency.request(null, 0.3)
		SSshuttle.emergencyNoRecall = TRUE
		SSticker.force_ending = TRUE
		priority_announce("A powerfull bluespace emanation has been detected in [get_area(src)]. It seems that you have failed to stop the ritual. Any remaining surviours \
		are ordered to immidiately head to the emergency shuttle in order to escape the station and save their lifes.", \
		"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
		cult.message_all_dudes("<span class='cultlarge'><b>[god.name] has breaked into this plane! It is time to show those heretics, who's faith was true!</b></span>", TRUE)
		to_chat(cult.god, span_cultlarge("You feel gaining more power then you ever have! It is now your time to..."))
		send_to_playing_players(span_cultlarge("MY TIME HAS COME! PREPARE TO MEET YOUR FATE, HERETICS!"))
		var/mob/camera/hog_god/goddie = cult.god
		goddie.forceMove(get_turf(src))
		var/mob/living/simple_animal/hostile/hog/free_god/dungeon_master = new(get_turf(src))
		dungeon_master.cult = src.cult
		god.mind.transfer_to(dungeon_master)
		qdel(src)
	progress += 1
	priority_announce("Time untill the rituall completion - [progress] minutes.", \
	"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
	addtimer(CALLBACK(src, .proc/Sex), 1 MINUTES)
	
	
