GLOBAL_VAR(thebattlebus)
GLOBAL_LIST_EMPTY(battleroyale_players) //reduce iteration cost
GLOBAL_VAR(stormdamage)
GLOBAL_VAR(final_zone)

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
	var/list/roundstart_traits = list(TRAIT_XRAY_VISION, TRAIT_NOHUNGER, TRAIT_NOBREATH, TRAIT_NOSOFTCRIT, TRAIT_NOHARDCRIT, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_SAFEWELD, TRAIT_HARDLY_WOUNDED)
	var/list/randomweathers = list("royale science", "royale medbay", "royale service", "royale cargo", "royale security", "royale engineering", "royale the bridge")
	var/list/weathered = list() //list of all the places currently covered by weather
	var/stage_interval = 3 MINUTES
	var/loot_interval = 75 SECONDS //roughly the time between loot drops
	var/borderstage = 0
	var/weightcull = 5 //anything above this gets culled
	var/can_end = FALSE //so it doesn't end during setup somehow
	var/finished = FALSE
	var/original_num = 0
	var/mob/living/winner // Holds the wiener of the victory royale battle fortnight.
	title_icon = "ss13"

/datum/game_mode/fortnite/pre_setup()
	GLOB.stormdamage = 3
	INVOKE_ASYNC(src, PROC_REF(spawn_bus))//so if a runtime happens with the spawn_bus proc, the rest of pre_setup still happens
	for(var/mob/L in GLOB.player_list)
		if(!L.mind || !L.client || isobserver(L))
			continue
		var/datum/mind/virgin = L.mind
		queued += virgin
	return TRUE

/datum/game_mode/fortnite/proc/spawn_bus()
	var/obj/effect/landmark/observer_start/center = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list //observer start is usually in the middle
	var/turf/turf = get_ranged_target_turf(get_turf(center), prob(50) ? NORTH : SOUTH, rand(0,30)) //get a random spot above or below the middle
	var/turf/target = get_ranged_target_turf(get_edge_target_turf(turf, WEST), EAST, 15) //almost all the way at the edge of the map
	if(target)
		new /obj/structure/battle_bus(target)
	else //please don't ever happen
		message_admins("Something has gone terribly wrong and the bus couldn't spawn, please alert a maintainer or someone comparable.")

/datum/game_mode/fortnite/post_setup() //now add a place for them to spawn :)
	GLOB.enter_allowed = FALSE
	message_admins("Battle Royale Mode has disabled late-joining. If you re-enable it you will break everything.")
	for(var/datum/mind/virgin in queued)
		if(!(virgin.current) || !ishuman(virgin.current))//don't put ghosts, borgs, or ai in the battle bus
			continue
		SEND_SOUND(virgin.current, 'yogstation/sound/effects/battleroyale/battlebus.ogg')
		virgin.current.set_species(/datum/species/human) //Fuck plasmamen -- before giving datum so species without shoes still get them
		virgin.add_antag_datum(antag_datum_type)
		if(!GLOB.thebattlebus) //Ruhoh.
			virgin.current.forceMove(pick(GLOB.start_landmarks_list))
			message_admins("There is no battle bus! Attempting to spawn players at random.")
			log_game("There is no battle bus! Attempting to spawn players at random.")
			continue
		virgin.current.forceMove(GLOB.thebattlebus)
		original_num ++
		virgin.current.apply_status_effect(STATUS_EFFECT_DODGING_GAMER) //to prevent space from hurting
		for(var/i in roundstart_traits)
			ADD_TRAIT(virgin.current, i, "battleroyale")
		REMOVE_TRAIT(virgin.current, TRAIT_PACIFISM, ROUNDSTART_TRAIT) //FINE, i guess pacifists get to fight too
		virgin.current.update_sight()
		to_chat(virgin.current, "<font_color='red'><b> You are now in the battle bus! Click it to exit.</b></font>")
		GLOB.battleroyale_players += virgin.current
    
	if(!LAZYLEN(GLOB.battleroyale_players))
		message_admins("Somehow no one has been properly signed up to battle royale despite the round just starting, please contact someone to fix it.")
		log_game("Somehow no one has been properly signed up to battle royale despite the round just starting, please contact someone to fix it.")

	for(var/obj/machinery/door/W in GLOB.machines)//set all doors to all access
		W.req_access = list()
		W.req_one_access = list()
		W.locked = FALSE //no bolted either
	addtimer(VARSET_CALLBACK(src, can_end, TRUE), 29 SECONDS) //let ending be possible
	addtimer(CALLBACK(src, PROC_REF(check_win)), 30 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(loot_spawn)), 0.5 SECONDS)//make sure this happens before shrinkborders
	addtimer(CALLBACK(src, PROC_REF(shrinkborders)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(subvert_ai)), 1.5 SECONDS)//funny gamemaster rules
	addtimer(CALLBACK(src, PROC_REF(delete_armoury)), 2 SECONDS)//so shitters don't immediately rush everything
	addtimer(CALLBACK(src, PROC_REF(delete_armoury)), 2.5 SECONDS)//do it twice because lockers protect the things inside
	addtimer(CALLBACK(src, PROC_REF(loot_drop)), loot_interval)//literally just keep calling it
	set_observer_default_invisibility(0) //so ghosts can feel like they're included
	return ..()

/datum/game_mode/fortnite/check_win()
	. = ..()
	if(finished)
		return
	if(!can_end)
		return
	if(LAZYLEN(GLOB.player_list) <= 1) //It's a localhost testing
		return
	if(!LAZYLEN(GLOB.battleroyale_players)) //sanity check for if this gets called before people are added to the list somehow
		message_admins("Somehow no one is signed up to battle royale but check_win has been called, please contact someone to fix it.")
		return

	var/list/royalers = list() //make a new list
	var/disqualified = 0 //keep track of everyone disqualified for log reasons

	for(var/mob/living/player in GLOB.battleroyale_players)
		if(QDELETED(player) || (player.stat == DEAD))
			disqualified++
			continue
		var/turf/place = get_turf(player)
		if(!is_station_level(place.z) || player.onCentCom() || player.onSyndieBase())
			disqualified++
			to_chat(player, "You left the station! You have been disqualified from battle royale.")
			player.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY) //ya blew it
			continue
		royalers += player //add everyone not disqualified for one reason or another to the new list

	log_game("DQ'd ([disqualified]) people, From ([LAZYLEN(GLOB.battleroyale_players)]) to ([LAZYLEN(royalers)])")

	GLOB.battleroyale_players = royalers //replace the old list with the new list

	if(!LAZYLEN(GLOB.battleroyale_players))
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		to_chat(world, "<span_class='ratvar'>L. Nobody wins!</span>")
		SEND_SOUND(world, 'yogstation/sound/effects/battleroyale/L.ogg')
		finished = TRUE
		return
	if(LAZYLEN(GLOB.battleroyale_players) == 1) //We have a wiener!
		SSticker.mode.check_finished(TRUE)
		SSticker.force_ending = 1
		winner = pick(GLOB.battleroyale_players)
		to_chat(world, "<img src='https://cdn.discordapp.com/attachments/351367327184584704/539903688857092106/victoryroyale.png'>")
		to_chat(world, "<span_class='bigbold'>#1 VICTORY ROYALE: [winner] </span>")
		SEND_SOUND(world, 'yogstation/sound/effects/battleroyale/greet_br.ogg')
		finished = TRUE
		return
	addtimer(CALLBACK(src, PROC_REF(check_win)), 300) //Check win every 30 seconds. This is so it doesn't fuck the processing time up

/datum/game_mode/fortnite/set_round_result()
	..()
	if(winner)
		SSticker.mode_result = span_green(span_extremelybig("win - [winner] won the battle royale"))
	else
		SSticker.mode_result = span_narsiesmall("loss - nobody won the battle royale!")

/datum/game_mode/fortnite/proc/shrinkborders()
	switch(borderstage)//to keep it seperate and not fuck with weather selection
		if(1)
			SSsecurity_level.set_level(SEC_LEVEL_BLUE)
		if(4)
			SSsecurity_level.set_level(SEC_LEVEL_RED)
		if(7)
			SSsecurity_level.set_level(SEC_LEVEL_GAMMA)
		if(9)
			SSsecurity_level.set_level(SEC_LEVEL_EPSILON)

	var/datum/weather/royale/W
	switch(borderstage)
		if(0)
			W = SSweather.run_weather("royale start",2)
		if(1)
			W = SSweather.run_weather("royale maint",2)
		if(2 to 7)//close off the map
			var/weather = pick(randomweathers)
			W = SSweather.run_weather(weather, 2)
			randomweathers -= weather
		if(8)
			GLOB.final_zone = replacetext(pick(randomweathers), "royale ", "")
			W = SSweather.run_weather("royale hallway", 2)//force them to the final department
		if(9)//finish it
			SSweather.run_weather("royale centre", 2)

	if(W && istype(W))
		weathered |= W.areasToWeather

	if(borderstage)//doesn't cull during round start
		ItemCull()

	GLOB.stormdamage *= 1.1
	borderstage++
	
	if(borderstage <= 9)
		var/remainingpercent = LAZYLEN(GLOB.battleroyale_players) / original_num
		stage_interval = max(1 MINUTES, initial(stage_interval) * remainingpercent) //intervals get faster as people die
		loot_interval = min(stage_interval / 2, initial(loot_interval)) //loot spawns faster as more die, but won't ever take longer than base
		if(borderstage == 9)//final collapse takes the full time but still spawns loot faster
			stage_interval = initial(stage_interval)
		addtimer(CALLBACK(src, PROC_REF(shrinkborders)), stage_interval)

/datum/game_mode/fortnite/proc/delete_armoury()
	var/area/to_clear = list(//clear out any place that might have gamer loot that creates a meta of "rush immediately"
		/area/ai_monitored/security/armory, 
		/area/security/warden, 
		/area/security/main, 
		/area/crew_quarters/heads/hos,
		/area/crew_quarters/heads/captain//sword
		)

	to_clear |= typesof(/area/bridge) //fireaxe
	to_clear |= typesof(/area/engine/atmos) //also fireaxe

	var/list/removals = typecacheof(list( //remove non-standard things in this list
		/obj/structure/fireaxecabinet, 
		/obj/machinery/suit_storage_unit, 
		/obj/machinery/atmospherics/miner/toxins, //no plasmaflood, sleepflood is fine because no one needs to breathe
		))

	for(var/place in to_clear)
		var/area/actual = locate(place) in GLOB.areas
		for(var/obj/thing in actual)
			if(QDELETED(thing))
				continue
			if(!thing.anchored || is_type_in_typecache(thing, removals))//only target something that is possibly a weapon or gear
				QDEL_NULL(thing)
	
	for(var/target in GLOB.mob_living_list)
		if(istype(target, /mob/living/simple_animal/bot))//no beepsky
			qdel(target)

/datum/game_mode/fortnite/proc/subvert_ai()//to do: make spawned borgs follow this law too
	var/mob/selfinsert = new(src)
	selfinsert.name = "Molti" //lol it me
	var/obj/item/aiModule/core/full/gamemaster/lollmaoeven = new(src)
	for(var/mob/living/silicon/borg in GLOB.silicon_mobs)
		lollmaoeven.install(borg.laws, selfinsert)
	qdel(selfinsert) //wait, no, NO, YOU CAN'T DO THIS TO ME, I OWN THIS CODEBASE
	qdel(lollmaoeven)

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
	loot_spawn()
	addtimer(CALLBACK(src, PROC_REF(loot_drop)), loot_interval)//literally just keep calling it

/// How many tiles in a given room gives a 100% guaranteed crate
#define ROOMSIZESCALING 60
/datum/game_mode/fortnite/proc/loot_spawn()
	for(var/area/lootlake as anything in GLOB.areas)
		if(!is_station_level(lootlake.z))//don't spawn it if it isn't a station level
			continue
		if(istype(lootlake, /area/space))//no nearspace
			continue
		if(istype(lootlake, /area/solar))//no solars
			continue
		if(istype(lootlake, /area/maintenance))//no maintenance, it's too large, it'd lag the hell out of the server and it's not as popular as main hallways
			continue //also, ideally keeps people out of maints, and in larger open areas that are more interesting
		if(is_type_in_list(lootlake, weathered))
			continue //if the area is covered with a storm, don't spawn loot (less lag)
		var/number = LAZYLEN(lootlake.get_contained_turfs())//so bigger areas spawn more crates
		var/amount = round(number / ROOMSIZESCALING) + prob(((number % ROOMSIZESCALING)/ROOMSIZESCALING)*100) //any remaining tiles gives a probability to have an extra crate
		for(var/I = 0, I < amount, I++)
			var/turf/turfy = pick(get_area_turfs(lootlake))
			for(var/L = 0, L < 15, L++)//cap so it doesn't somehow end in an infinite loop
				if(!turfy.density)//so it doesn't spawn inside walls
					break
				turfy = pick(get_area_turfs(lootlake))
			addtimer(CALLBACK(src, PROC_REF(drop_pod), turfy), rand(1,50))//to even out the lag that creating a drop pod causes

#undef ROOMSIZESCALING

/datum/game_mode/fortnite/proc/drop_pod(turf/turfy)
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
	var/killed = 0

/datum/antagonist/battleroyale/on_gain()
	. = ..()
	var/datum/objective/O = new /datum/objective/survive() //SURVIVE.
	O.owner = owner
	objectives += O
	var/mob/living/carbon/human/tfue = owner.current
	for(var/obj/item/I in tfue.get_equipped_items(TRUE))//remove all clothes before giving the antag clothes
		qdel(I)
	for(var/obj/item/I in tfue.held_items)//remove held items (mining medic i'm looking at you)
		qdel(I)
	tfue.equipOutfit(/datum/outfit/battleroyale, visualsOnly = FALSE)

/datum/antagonist/battleroyale/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	handle_clown_mutation(current_mob, mob_override ? null : "Your overwhelming swagness allows you to wield weapons!")
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(gamer_life))
	RegisterSignal(current_mob, COMSIG_LIVING_DEATH, PROC_REF(gamer_death))

/datum/antagonist/battleroyale/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, COMSIG_LIVING_LIFE)
	UnregisterSignal(current_mob, COMSIG_LIVING_DEATH)
	return ..()

/datum/antagonist/battleroyale/proc/gamer_life(mob/living/source, seconds_per_tick, times_fired)
	var/mob/living/carbon/human/tfue = source
	if(tfue && isspaceturf(tfue.loc))
		tfue.adjustFireLoss(GLOB.stormdamage, TRUE, TRUE) //no hiding in space

/datum/antagonist/battleroyale/proc/gamer_death()//you live by the game, you die by the game
	to_chat(owner, span_userdanger("Oh dear, you are dead! "))
	to_chat(owner, span_notice("You may be revived during the events of the round, but you can no longer win."))
	owner.current?.unequip_everything()
	owner.current?.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY) //ya blew it

/datum/antagonist/battleroyale/greet()
	SEND_SOUND(owner.current, 'yogstation/sound/effects/battleroyale/greet_br.ogg')
	to_chat(owner.current, "<span_class='bigbold'>Welcome contestant!</span>")
	to_chat(owner.current, "<span_class='danger'>You have been entered into Nanotrasen's up and coming TV show! : <b> LAST MAN STANDING </b>. \n\ KILL YOUR COWORKERS TO ACHIEVE THE VICTORY ROYALE! Attempting to leave the station will disqualify you from the round!</span>")
	owner.announce_objectives()

/datum/antagonist/battleroyale/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	var/text = "<b>[owner.key]</b> was <b>[owner.name]</b> and"
	if(owner.current)
		var/datum/game_mode/fortnite/fortnut = SSticker.mode 
		if(istype(fortnut))
			if(owner?.current == fortnut.winner)
				text += " [span_greentext("won")]"
			else
				text += " [span_redtext("lost")]"
		if(owner.current.real_name != owner.name)
			text += " as <b>[owner.current.real_name]</b>"
	else
		text += " [span_redtext("lost while having their body destroyed")]"

	report += text
	report += "They killed a total of [killed ? killed : "0" ] competitors"

	return report.Join("<br>")

/datum/outfit/battleroyale
	name = "Default Skin"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	neck = /obj/item/clothing/neck/tie/gamer //glorified kill tracker
	r_pocket = /obj/item/bikehorn
	l_pocket = /obj/item/crowbar
	id = /obj/item/card/id/captains_spare

/obj/item/clothing/neck/tie/gamer
	name = "very cool tie (do not remove)"
	desc = "Totally not just here for keeping track of kills."
	var/datum/antagonist/battleroyale/last_hit
	resistance_flags = INDESTRUCTIBLE //no escaping

/obj/item/clothing/neck/tie/gamer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "I will kill you if you take this off somehow") //can't be a clothing trait because those get applied to the mob, not the item
	
/obj/item/clothing/neck/tie/gamer/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_DEATH, PROC_REF(death))

/obj/item/clothing/neck/tie/gamer/proc/death()
	if(last_hit)
		last_hit.killed++
	qdel(src)//so reviving them doesn't give the necklace back

/obj/item/clothing/neck/tie/gamer/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	. = ..()
	var/mob/living/culprit

	if(isprojectile(hitby))//get the person that shot the projectile
		var/obj/projectile/thing
		if(thing?.firer && isliving(thing.firer))
			culprit = thing.firer
	else if(isitem(hitby))//get the person holding the item
		var/obj/item/thing = hitby
		if(isliving(thing.loc))
			culprit = thing.loc
	else if(isliving(hitby))//get the person
		culprit = hitby

	if(!culprit)
		return
	if(culprit.mind?.has_antag_datum(/datum/antagonist/battleroyale))
		last_hit = culprit.mind.has_antag_datum(/datum/antagonist/battleroyale)


/obj/structure/battle_bus
	name = "The battle bus"
	desc = "Quit screwin' around!. Can we get some of that jumping music? Click it to exit!"
	icon = 'yogstation/icons/battleroyale/battlebus.dmi'
	icon_state = "battlebus"
	density = FALSE
	opacity = FALSE
	alpha = 170 //So you can see under it when it moves
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 20 //light up the darkness, oh battle bus.
	light_power = 2
	layer = 4 //Above everything
	var/starter_z = 0 //What Z level did we start on?
	var/can_leave = FALSE //so people don't immediately walk out into space by accident

/obj/structure/battle_bus/attack_hand(mob/user)
	if(!(user in contents))
		return
	exit(user)

/obj/structure/battle_bus/Initialize(mapload)
	. = ..()
	if(GLOB.thebattlebus)
		qdel(src) //There can be ONLY ONE
	START_PROCESSING(SSfastprocess, src)
	GLOB.thebattlebus = src //So the GM code knows where to move people to!
	starter_z = z
	addtimer(CALLBACK(src, PROC_REF(cleanup)), 2 MINUTES)
	addtimer(VARSET_CALLBACK(src, can_leave, TRUE), 20 SECONDS) //let people leave contingency

/obj/structure/battle_bus/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.thebattlebus = null
	. = ..()

/obj/structure/battle_bus/relaymove(mob/living/user, direction)
	if(can_leave)
		exit(user)

/obj/structure/battle_bus/proc/exit(mob/living/carbon/human/Ltaker)
	Ltaker.forceMove(get_turf(src))
	REMOVE_TRAIT(Ltaker, TRAIT_XRAY_VISION, "battleroyale")
	Ltaker.update_sight()
	SEND_SOUND(Ltaker, 'yogstation/sound/effects/battleroyale/exitbus.ogg')

/obj/structure/battle_bus/process()
	var/turf/target = get_step(src, EAST)
	if(!isspaceturf(get_turf(target)))
		can_leave = TRUE
	forceMove(target) //Move right.
	if(z != starter_z)
		for(var/mob/M in contents)
			to_chat(M, "You feel your insides churn as the battle bus throws you out forcefully!")
			var/turf/destination = find_safe_turf(starter_z, dense_atoms = FALSE)
			M.forceMove(destination)
		qdel(src) // Thank you for your service

/obj/structure/battle_bus/proc/cleanup()
	if(!QDELETED(src))
		qdel(src)

/obj/structure/battle_bus/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(FALSE)
	return TRUE
