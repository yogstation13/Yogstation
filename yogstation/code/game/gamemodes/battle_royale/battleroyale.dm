GLOBAL_VAR(thebattlebus)
GLOBAL_LIST_EMPTY(battleroyale_players) //reduce iteration cost

/datum/game_mode/fortnite
	name = "battle royale"
	config_tag = "battleroyale"
	report_type = "battleroyale"
	false_report_weight = 0
	required_players = 1 //Everyone is an antag in this mode
	recommended_enemies = 1
	enemy_minimum_age = 0
	announce_span = "warning"
	announce_text = "Attention ALL space station 13 crewmembers,\n\
	<span class='danger'><b>John Wick</b></span> is in grave danger and he NEEDS your help to wipe all the squads in the tilted towers. To do this, he'll need\n\
	<span class='notice'><i>your credit card number, the three numbers on the back and the expiration month <b> AND </b> year</i></span>. But you gotta be <b>quick</b>, so that John can secure the bag and achieve the epic victory ROYAL.\n\
	<i>Be the last man standing at the end of the game to win.</i>"
	var/antag_datum_type = /datum/antagonist/battleroyale
	var/list/queued = list() //Who is queued to enter?
	var/list/randomweathers = list("royale science", "royale medbay", "royale service", "royale cargo", "royale security", "royale engineering")
	var/stage_interval = 2 MINUTES //Copied from Nich's homework. Storm shrinks every 2 minutes (changed for testing, don't forget to change back)
	var/loot_interval = 1 MINUTES
	var/borderstage = 0
	var/weightcull = 5 //anything above this gets culled
	var/finished = FALSE
	var/mob/living/winner // Holds the wiener of the victory royale battle fortnight.
	title_icon = "ss13"

/datum/game_mode/fortnite/pre_setup()
	var/area/hallway/secondary/A = locate(/area/hallway/secondary) in GLOB.areas //Assuming we've gotten this far, let's spawn the battle bus.
	if(A)
		var/turf/T = safepick(get_area_turfs(A)) //Move to a random turf in arrivals. Please ensure there are no space turfs in arrivals!!!
		new /obj/structure/battle_bus(T)
	else //please don't ever happen
		message_admins("Something has gone terribly wrong and the bus couldn't spawn, please alert a maintainer or someone comparable.")
	for(var/mob/L in GLOB.player_list)//fix this it spawns them with gear on
		if(!L.mind || !L.client)
			if(isobserver(L) || !L.mind || !L.client)
				continue
		var/datum/mind/virgin = L.mind
		queued += virgin
	return TRUE

/datum/game_mode/fortnite/post_setup() //now add a place for them to spawn :)
	GLOB.enter_allowed = FALSE
	message_admins("Battle Royale Mode has disabled late-joining. If you re-enable it you will break everything.")
	for(var/datum/mind/virgin in queued)
		SEND_SOUND(virgin.current, 'yogstation/sound/effects/battleroyale/battlebus.ogg')
		virgin.current.set_species(/datum/species/human) //Fuck plasmamen -- before giving datum so species without shoes still get them
		virgin.add_antag_datum(antag_datum_type)
		if(!GLOB.thebattlebus) //Ruhoh.
			virgin.current.forceMove(pick(GLOB.start_landmarks_list))
			message_admins("There is no battle bus! Attempting to spawn players at random.")
			continue
		virgin.current.forceMove(GLOB.thebattlebus)
		ADD_TRAIT(virgin.current, TRAIT_XRAY_VISION, "virginity") //so they can see where theyre dropping
		virgin.current.status_flags |= GODMODE //to prevent space from hurting
		ADD_TRAIT(virgin.current, TRAIT_NOHUNGER, "getthatbreadgamers") //so they don't need to worry about annoyingly running out of food
		virgin.current.update_sight()
		to_chat(virgin.current, "<font_color='red'><b> You are now in the battle bus! Click it to exit.</b></font>")
		GLOB.battleroyale_players += virgin.current
		
	if(!GLOB.battleroyale_players.len)
		message_admins("Somehow no one has been properly signed up to battle royale despite the round just starting, please contact someone to fix it.")

	for(var/obj/machinery/door/airlock/W in GLOB.machines)//set all doors to all access
		W.req_access = list()
	addtimer(CALLBACK(src, PROC_REF(check_win)), 30 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(loot_spawn)), 0.5 SECONDS)//make sure this happens before shrinkborders
	addtimer(CALLBACK(src, PROC_REF(shrinkborders)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(loot_drop)), loot_interval, TIMER_STOPPABLE | TIMER_UNIQUE | TIMER_LOOP)//literally just keep calling it
	return ..()

/datum/game_mode/fortnite/check_win()
	. = ..()
	if(finished)
		return
	var/list/royalers = list()
	if(GLOB.player_list.len <= 1) //It's a localhost testing
		return
	if(!LAZYLEN(GLOB.battleroyale_players)) //sanity check for if this gets called before people are added to the list somehow
		message_admins("Somehow no one is signed up to battle royale but check_win has been called, please contact someone to fix it.")
		return

	for(var/mob/living/player in GLOB.battleroyale_players)
		if(player.stat == DEAD)
			GLOB.battleroyale_players -= player
			continue
		if(!player.client)
			GLOB.battleroyale_players -= player
			continue //No AFKS allowed!!!
		if(player.onCentCom())
			GLOB.battleroyale_players -= player
			to_chat(player, "You left the station! You have been disqualified from battle royale.")
			continue
		else if(player.onSyndieBase())
			GLOB.battleroyale_players -= player
			to_chat(player, "You left the station! You have been disqualified from battle royale.")
			continue
		if(!is_station_level(player.z))
			GLOB.battleroyale_players -= player
			to_chat(player, "You left the station! You have been disqualified from battle royale.")
			continue
		royalers += player

	if(!royalers.len)
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		to_chat(world, "<span_class='ratvar'>L. Nobody wins!</span>")
		SEND_SOUND(world, 'yogstation/sound/effects/battleroyale/L.ogg')
		finished = TRUE
		return
	if(royalers.len == 1) //We have a wiener!
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		winner = pick(royalers)
		to_chat(world, "<img src='https://cdn.discordapp.com/attachments/351367327184584704/539903688857092106/victoryroyale.png'>")
		to_chat(world, "<span_class='bigbold'>#1 VICTORY ROYALE: [winner] </span>")
		SEND_SOUND(world, 'yogstation/sound/effects/battleroyale/greet_br.ogg')
		finished = TRUE
		return
	addtimer(CALLBACK(src, PROC_REF(check_win)), 300) //Check win every 30 seconds. This is so it doesn't fuck the processing time up

/datum/game_mode/fortnite/set_round_result()
	..()
	if(winner)
		SSticker.mode_result = "win - [winner] won the battle royale"
	else
		SSticker.mode_result = "loss - nobody won the battle royale!"

/datum/game_mode/fortnite/proc/shrinkborders()
	switch(borderstage)
		if(0)
			SSweather.run_weather("royale start",2)
		if(1)//get them out of maints
			SSweather.run_weather("royale maint", 2)
		if(2 to 7)//close off the map
			var/weather = pick(randomweathers)
			SSweather.run_weather(weather, 2)
			randomweathers -= weather
		if(8)
			SSweather.run_weather("royale hallway", 2)//force them to bridge
		if(9)//finish it
			SSweather.run_weather("royale centre", 2)

	if(borderstage)//doesn't cull during round start
		ItemCull()

	borderstage++

	if(borderstage <= 9)
		addtimer(CALLBACK(src, PROC_REF(shrinkborders)), stage_interval)

/datum/game_mode/fortnite/proc/ItemCull()//removes items that are too weak, adds stronger items into the loot pool
	for(var/item in GLOB.battleroyale_armour)
		GLOB.battleroyale_armour[item] ++
		if(GLOB.battleroyale_armour[item] > weightcull)
			GLOB.battleroyale_armour -= item

	for(var/item in GLOB.battleroyale_weapon)
		GLOB.battleroyale_weapon[item] ++
		if(GLOB.battleroyale_weapon[item] > weightcull)
			GLOB.battleroyale_weapon -= item

	//healing doesn't scale because max health doesn't scale

	for(var/item in GLOB.battleroyale_utility)
		GLOB.battleroyale_utility[item] ++
		if(GLOB.battleroyale_utility[item] > weightcull)
			GLOB.battleroyale_utility -= item

	if(!GLOB.battleroyale_armour.len || !GLOB.battleroyale_weapon.len || !GLOB.battleroyale_healing.len || !GLOB.battleroyale_utility.len)
		message_admins("battle royale loot drop lists have been depleted somehow, PANIC")

/datum/game_mode/fortnite/proc/loot_drop()
	loot_spawn(rand(1, 2))

/datum/game_mode/fortnite/proc/loot_spawn(amount = 3)
	for(var/obj/effect/landmark/event_spawn/es in GLOB.landmarks_list)
		var/area/AR = get_area(es)
		for(var/I = 0, I < amount, I++)
			var/turf/turfy = pick(get_area_turfs(AR))
			while(turfy.density)//so it doesn't spawn inside walls
				turfy = pick(get_area_turfs(AR))
			var/obj/structure/closet/supplypod/centcompod/pod = new()
			new /obj/structure/closet/crate/battleroyale(pod)
			new /obj/effect/DPtarget(turfy, pod)

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
	START_PROCESSING(SSprocessing, src)

/datum/antagonist/battleroyale/on_removal()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/datum/antagonist/battleroyale/process(delta_time)
	. = ..()
	var/mob/living/carbon/human/tfue = owner.current
	if(tfue && isspaceturf(get_turf(tfue)))//to account for not being able to put the storm on space turf tiles (if someone reviewing this knows how, please tell me)
		tfue.adjustFireLoss(4) //no hiding in space

/datum/antagonist/battleroyale/greet()
	SEND_SOUND(owner.current, 'yogstation/sound/effects/battleroyale/greet_br.ogg')
	to_chat(owner.current, "<span_class='bigbold'>Welcome contestant!</span>")
	to_chat(owner.current, "<span_class='danger'>You have been entered into Nanotrasen's up and coming TV show! : <b> LAST MAN STANDING </b>. \n\ KILL YOUR COWORKERS TO ACHIEVE THE VICTORY ROYALE! Attempting to leave the station will disqualify you from the round!</span>")
	owner.announce_objectives()

/datum/outfit/battleroyale
	name = "Default Skin"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset
	r_pocket = /obj/item/bikehorn
	l_pocket = /obj/item/crowbar
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/captains_spare

/obj/structure/battle_bus
	name = "The battle bus"
	desc = "Quit screwin' around!. Can we get some of that jumping music? Click it to exit!"
	icon = 'yogstation/icons/battleroyale/battlebus.dmi'
	icon_state = "battlebus"
	density = FALSE
	opacity = FALSE
	alpha = 185 //So you can see under it when it moves
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_range = 10 //light up the darkness, oh battle bus.
	layer = 4 //Above everything
	var/starter_z = 0 //What Z level did we start on?

/obj/structure/battle_bus/attack_hand(mob/user)
	if(!(user in contents))
		return
	exit(user)

/obj/structure/battle_bus/Initialize()
	. = ..()
	if(GLOB.thebattlebus)
		qdel(src) //There can be ONLY ONE
	START_PROCESSING(SSfastprocess, src)
	GLOB.thebattlebus = src //So the GM code knows where to move people to!
	starter_z = z

/obj/structure/battle_bus/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.thebattlebus = null
	. = ..()

/obj/structure/battle_bus/relaymove(mob/living/user, direction)
	exit(user)

/obj/structure/battle_bus/proc/exit(var/mob/living/carbon/human/Ltaker)
	Ltaker.forceMove(get_turf(src))
	REMOVE_TRAIT(Ltaker, TRAIT_XRAY_VISION, "virginity")
	Ltaker.status_flags &= ~GODMODE //to make shit hurt again
	Ltaker.update_sight()
	SEND_SOUND(Ltaker, 'yogstation/sound/effects/battleroyale/exitbus.ogg')

/obj/structure/battle_bus/process()
	forceMove(get_step(src, EAST)) //Move right.
	if(z != starter_z)
		for(var/mob/M in contents)
			to_chat(M, "You feel your insides churn as the battle bus throws you out forcefully!")
			var/obj/effect/landmark/observer_start/L = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
			M.forceMove(get_turf(L))
		qdel(src) // Thank you for your service
	if(!contents)//in case Z-level loops
		QDEL_IN(src, 10 SECONDS)

/obj/structure/battle_bus/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE
