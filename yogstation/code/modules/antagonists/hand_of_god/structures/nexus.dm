#define BREAK_FREE_TIME 7 ///7 minutes

/obj/structure/destructible/hog_structure/lance/nexus
	name = "\improper Nexus"
	desc = "There is a god's soul inside. Kill it, and the god will die."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	icon_originalname = "nexus"
	anchored = TRUE
	density = TRUE
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge)
	max_integrity = 500
	cost = 0
	time_builded = 0
	break_message = span_cultlarge("The nexus explodes in a bright flash of light!") 
	var/last_scream
	var/mob/camera/hog_god/god
	var/active = FALSE
	var/progress = 0
	var/estimated_time = BREAK_FREE_TIME

/obj/structure/destructible/hog_structure/lance/nexus/Initialize()
	. = ..()

/obj/structure/destructible/hog_structure/lance/nexus/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.)
		if(last_scream < world.time)
			cult.message_all_dudes("Your nexus is under attack! Defend it, or your cult will perish!", FALSE)
			last_scream = world.time + ARK_SCREAM_COOLDOWN

/obj/structure/destructible/hog_structure/lance/nexus/proc/Activate()
	active = TRUE
	priority_announce("An unknown bluespace entity is being summoned in [get_area(src)]. All crew are directed to \
	@!$, stop this rituall at all cost to prevent further damage to corporate property and save the station from destruction. This is \
	not a drill. Estimated time of the rituall completion - [BREAK_FREE_TIME] minutes.", \
	"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg') ///I don't have any my own sounds, so... you know.
	set_security_level(SEC_LEVEL_GAMMA)
	addtimer(CALLBACK(src, .proc/Sex), 1 MINUTES)	
	cult.message_all_dudes("Servants of [god.name]! Our time has come! Defend the nexus at all costs!", TRUE)
	cult.state = HOG_TEAM_SUMMONING

/obj/structure/destructible/hog_structure/lance/nexus/proc/Sex()
	if(progress == BREAK_FREE_TIME)	
		return /// Not coded yet!
	progress += 1
	priority_announce("Time untill the rituall completion - [progress] minutes.", \
	"Central Command Higher Dimensional Affairs", 'sound/magic/clockwork/ark_activation.ogg')
	addtimer(CALLBACK(src, .proc/Sex), 1 MINUTES)
	
	
