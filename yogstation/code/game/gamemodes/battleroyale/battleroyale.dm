/datum/game_mode/battleroyale
	name = "battle royale"
	config_tag = "battleroyale"
	antag_flag = ROLE_PUBG
	required_players = 20 // should be 100 tbh
	enemy_minimum_age = 0
	protected_jobs = list()
	restricted_jobs = list()
	announce_span = "danger"
	announce_text = "A full blown royale is going on station!"

/datum/game_mode/battleroyale/post_setup()
	for(var/X in GLOB.alive_mob_list)
		var/mob/living/carbon/P = X
			if(!istype(P.mind))
				return
			P.mind.add_antag_datum(ANTAG_DATUM_PUBG)
			drop_player(P) // where we dropping boys
			//something about an immovable rod every minute here

/datum/game_mode/battleroyale/proc/drop_player(mob/living/carbon/P)

