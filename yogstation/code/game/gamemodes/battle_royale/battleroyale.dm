GLOBAL_VAR(thebattlebus)
GLOBAL_LIST_EMPTY(battleroyale_players) //reduce iteration cost

/datum/game_mode/fortnite
	name = "battle royale"
	config_tag = "battleroyale"
	report_type = "battleroyale"
	false_report_weight = 0
	required_players = 1 //Everyone is an antag in this mode
	required_enemies = 1
	recommended_enemies = 1
	antag_flag = ROLE_BATTLEROYALE
	enemy_minimum_age = 0

	announce_span = "warning"
	announce_text = "Attention ALL space station 13 crewmembers,\n\
	<span class='danger'><b>John wick</b></span> is in grave danger and he NEEDS your help to wipe all the squads in the tilted towers. To do this, he'll need\n\
	<span class='notice'><i>your credit card number, the three numbers on the back and the expiration month <b> AND </b> year</i></span>. But you gotta be <b>quick</b>, so that John can secure the bag and achieve the epic victory ROYAL.\n\
	<i>Be the last man standing at the end of the game to win</i>"
	var/antag_datum_type = /datum/antagonist/battleroyale
	var/list/queued = list() //Who is queued to enter?
	var/list/randomweathers = list("royale north", "royale south", "royale east")
	var/stage_interval = 3000 //Copied from Nich's homework. Storm shrinks every 3 minutes
	var/borderstage = 0

/datum/game_mode/fortnite/pre_setup()
	var/fortnite_gamers = GLOB.player_list.len //How many fortnut gamers are there
	var/virgins = GLOB.player_list.Copy() //List of all players
	for(var/i = 0, i < fortnite_gamers, ++i) //Iterate for number of lobby-ers
		var/mob/dead/new_player/newvirgin = pick(virgins)
		if(isobserver(newvirgin) || !newvirgin.mind || !newvirgin.client)
			virgins -= newvirgin //No ghosts or AFKS please
			continue
		var/datum/mind/virgin = newvirgin.mind
		queued += virgin
		virgin.assigned_role = ROLE_BATTLEROYALE
		virgin.special_role = ROLE_BATTLEROYALE
		log_game("[key_name(virgin)] has been forcibly conscripted into battle royale.")
	var/area/hallway/secondary/A = locate(/area/hallway/secondary) in GLOB.sortedAreas //Assuming we've gotten this far, let's spawn the battle bus.
	if(A)
		var/turf/T = safepick(get_area_turfs(A)) //Move to a random turf in arrivals. Please ensure there are no space turfs in arrivals!!!
		new /obj/structure/battle_bus(T)
	var/num = (fortnite_gamers * 3) //Multiple crates per person due to the erratic nature of their spawn
	for(var/I = 0, I < num, I++)
		var/area/AA = pick(GLOB.teleportlocs)
		var/list/turfs = list()
		for(var/turf/open/TT in get_area_turfs(AA))
			if(!is_blocked_turf(TT))
				turfs += TT
		if(turfs.len)
			var/turf/turfy = pick(turfs)
			new /obj/structure/closet/crate/battleroyale(turfy)
	return TRUE

/datum/game_mode/fortnite/post_setup() //now add a place for them to spawn :)
	GLOB.enter_allowed = FALSE
	message_admins("Battle Royale Mode has disabled late-joining. If you re-enable it you will break everything.")
	for(var/i = 1 to queued.len)
		var/datum/mind/virgin = queued[i]
		SEND_SOUND(virgin.current, 'yogstation/sound/effects/battleroyale/battlebus.ogg')
		virgin.add_antag_datum(antag_datum_type)
		if(!GLOB.thebattlebus) //Ruhoh.
			virgin.current.forceMove(pick(GLOB.start_landmarks_list))
			message_admins("There is no battle bus! Attempting to spawn players at random.")
			continue
		virgin.current.forceMove(GLOB.thebattlebus)
		virgin.current.add_trait(TRAIT_XRAY_VISION) //so they can see where theyre dropping
		virgin.current.update_sight()
		to_chat(virgin.current, "<font_color='red'><b> You are now in the battle bus! Click it to exit </b></font>")
		GLOB.battleroyale_players += virgin.current
	addtimer(CALLBACK(src, .proc/check_win), 300)
	addtimer(CALLBACK(src, .proc/shrinkborders), 10)
	return ..()

/datum/game_mode/fortnite/check_win()
	. = ..()
	var/list/royalers = list()
	var/area/hallway/secondary/A = locate(/area/hallway/secondary) in GLOB.sortedAreas
	var/turf/T = pick(get_area_turfs(A)) //Work out the station's Z based on arrivals. Don't want people running off now!
	var/station_z = T.z
	if(GLOB.player_list.len <= 1) //It's a localhost testing
		return
	for(var/mob/living/player in GLOB.battleroyale_players)
		if(player.stat == DEAD)
			GLOB.battleroyale_players -= player
		if(!player.client)
			GLOB.battleroyale_players -= player
			continue //No AFKS allowed!!!
		if(player.onCentCom())
			GLOB.battleroyale_players -= player
			to_chat(player, "You left the station Z-level! You have been disqualified from battle royale.")
			continue
		else if(player.onSyndieBase())
			GLOB.battleroyale_players -= player
			to_chat(player, "You left the station Z-level! You have been disqualified from battle royale.")
			continue
		if(player.z != station_z)
			GLOB.battleroyale_players -= player
			to_chat(player, "You left the station Z-level! You have been disqualified from battle royale.")
			continue
		royalers += player

	if(!royalers.len)
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		to_chat(world, "<span_class='ratvar'>L. Nobody wins!</span>")
		SEND_SOUND(world, 'yogstation/sound/effects/battleroyale/L.ogg')
		return
	if(royalers.len == 1) //We have a wiener!
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		var/mob/living/dub = pick(royalers)
		to_chat(world, "<img src='https://cdn.discordapp.com/attachments/351367327184584704/539903688857092106/victoryroyale.png'>")
		to_chat(world, "<span_class='bigbold'>#1 VICTORY ROYALE: [dub] </span>")
		SEND_SOUND(world, 'yogstation/sound/effects/battleroyale/greet_br.ogg')
		return
	addtimer(CALLBACK(src, .proc/check_win), 300) //Check win every 30 seconds. This is so it doesn't fuck the processing time up

/datum/game_mode/fortnite/proc/shrinkborders()
	switch(borderstage)
		if(0)
			SSweather.run_weather("royale start",2)
		if(1)
			SSweather.run_weather("royale maint", 2)
		if(2 to 4)
			var/weather = pick(randomweathers)
			SSweather.run_weather(weather, 2)
			randomweathers -= weather

		if(5)
			SSweather.run_weather("royale west", 2)
		if(6)
			SSweather.run_weather("royale centre", 2)

	borderstage++
	if(borderstage <= 6)
		addtimer(CALLBACK(src, .proc/shrinkborders), stage_interval)


//Antag and items

/datum/antagonist/battleroyale
	name = "Battle Royale Contestant"
	antagpanel_category = "Default Skin"
	job_rank = "Battle Royale Contestant"
	show_name_in_check_antagonists = TRUE
	antag_moodlet = /datum/mood_event/focused

/datum/antagonist/battleroyale/on_gain()
	. = ..()
	var/datum/objective/O = new /datum/objective/survive() //SURVIVE.
	O.owner = owner
	objectives += O
	var/mob/living/carbon/human/tfue = owner.current
	tfue.equipOutfit(/datum/outfit/battleroyale, visualsOnly = FALSE)

/datum/antagonist/battleroyale/greet()
	SEND_SOUND(owner.current, 'yogstation/sound/effects/battleroyale/greet_br.ogg')
	to_chat(owner.current, "<span_class='bigbold'>Welcome contestant!</span>")
	to_chat(owner.current, "<span_class='danger'>You have been entered into nanotrasen's up and coming TV show! : <b> LAST MAN STANDING </b>. \n\ KILL YOUR COWORKERS TO ACHIEVE THE VICTORY ROYALE!. Attempting to leave the station will disqualify you from the round!</span>")
	owner.announce_objectives()

/datum/outfit/battleroyale
	name = "Default Skin"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset
	r_pocket = /obj/item/bikehorn
	l_pocket = /obj/item/crowbar
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/syndicate

/obj/structure/battle_bus
	name = "The battle bus"
	desc = "Quit screwin' around!. Can we get some of that jumping music?. Click it to exit!"
	icon = 'yogstation/icons/battleroyale/battlebus.dmi'
	icon_state = "battlebus"
	density = FALSE
	opacity = FALSE
	alpha = 185 //So you can see under it when it moves
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_range = 10 //light up the darkness, oh battle bus.
	layer = 4 //Above everything

/obj/structure/battle_bus/attack_hand(mob/user)
	if(!user in contents)
		return
	var/mob/living/carbon/human/Ltaker = user
	user.forceMove(get_turf(src))
	Ltaker.remove_trait(TRAIT_XRAY_VISION)
	Ltaker.update_sight()
	SEND_SOUND(user, 'yogstation/sound/effects/battleroyale/exitbus.ogg')

/obj/structure/battle_bus/Initialize()
	. = ..()
	if(GLOB.thebattlebus)
		qdel(src) //There can be ONLY ONE
	START_PROCESSING(SSfastprocess, src)
	GLOB.thebattlebus = src //So the GM code knows where to move people to!

/obj/structure/battle_bus/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.thebattlebus = null
	. = ..()

/obj/structure/battle_bus/process()
	forceMove(get_step(src, EAST)) //Move right.
	if(x >= 256) //Bigger than the maximum size of a byond map, so we'd best die so we don't loop on FOREVER and EVER.
		for(var/mob/M in contents)
			to_chat(M, "You feel your insides churn as the battle bus explosively decompresses.")
			M.gib()
		qdel(src) // Thank you for your service

/obj/structure/battle_bus/CanPass(atom/movable/mover, turf/target)
	return TRUE