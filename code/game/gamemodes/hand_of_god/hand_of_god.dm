/*Hand of God
its the silly little gamemode where two cults are vying to summon their respective gods ratvar or nar'sie
pulls stuff from clock_cult and eldritch_cult mostly items
the silliest part is BOTH gods can be summoned at once
Antag role is split into servant or cultist*/


/* unnesscesary procs, here for reference for the moment
//Procs Clockcult
/proc/is_servant_of_ratvar(mob/M)
	if(!istype(M))
		return FALSE
	return M?.mind?.has_antag_datum(/datum/antagonist/clockcult)

/proc/is_eligible_servant(mob/M)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		var/mob/living/master = M.mind.enslaved_to?.resolve()
		if(master && !iscultist(master))
			return FALSE
		if(M.mind.unconvertable)
			return FALSE
	else
		return FALSE
	if(iscultist(M) || isconstruct(M) || ispAI(M))
		return FALSE
	if(isliving(M))
		var/mob/living/L = M
		if(HAS_TRAIT(L, TRAIT_MINDSHIELD))
			return FALSE
	if(ishuman(M) || isbrain(M) || isguardian(M) || issilicon(M) || isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab) || istype(M, /mob/camera/eminence))
		return TRUE
	return FALSE

/proc/add_servant_of_ratvar(mob/L, silent = FALSE, create_team = TRUE)
	if(!L || !L.mind)
		return
	var/update_type = /datum/antagonist/clockcult
	if(silent)
		update_type = /datum/antagonist/clockcult/silent
	var/datum/antagonist/clockcult/C = new update_type(L.mind)
	C.make_team = create_team
	C.show_in_roundend = create_team //tutorial scarabs begone

	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		if(R.deployed)
			var/mob/living/silicon/ai/AI = R.mainframe
			R.undeploy()
			to_chat(AI, span_userdanger("Anomaly Detected. Returned to core!")) //The AI needs to be in its core to properly be converted

	. = L.mind.add_antag_datum(C)

	if(.)
		var/datum/antagonist/clockcult/servant = .
		var/datum/team/clockcult/cult = servant.get_team()
		cult.check_size()
	
	if(!silent && L)
		if(.)
			to_chat(L, "<span class='heavy_brass'>The world before you suddenly glows a brilliant yellow. [issilicon(L) ? "You cannot compute this truth!" : \
			"Your mind is racing!"] You hear the whooshing steam and cl[pick("ank", "ink", "unk", "ang")]ing cogs of a billion billion machines, and all at once it comes to you.<br>\
			Ratvar, the Clockwork Justiciar, [GLOB.ratvar_awakens ? "has been freed from his eternal prison" : "lies in exile, derelict and forgotten in an unseen realm"].</span>")
			flash_color(L, flash_color = list("#BE8700", "#BE8700", "#BE8700", rgb(0,0,0)), flash_time = 50)
		else
			L.visible_message(span_boldwarning("[L] seems to resist an unseen force!"), null, null, 7, L)
			to_chat(L, "<span class='heavy_brass'>The world before you suddenly glows a brilliant yellow. [issilicon(L) ? "You cannot compute this truth!" : \
			"Your mind is racing!"] You hear the whooshing steam and cl[pick("ank", "ink", "unk", "ang")]ing cogs of a billion billion machines, and the sound</span> <span class='boldwarning'>\
			is a meaningless cacophony.</span><br>\
			<span class='userdanger'>You see an abomination of rusting parts[GLOB.ratvar_awakens ? ", and it is here.<br>It is too late" : \
			" in an endless grey void.<br>It cannot be allowed to escape"].</span>")
			L.playsound_local(get_turf(L), 'sound/ambience/antag/clockcultalr.ogg', 40, TRUE, frequency = 100000, pressure_affected = FALSE)
			flash_color(L, flash_color = list("#BE8700", "#BE8700", "#BE8700", rgb(0,0,0)), flash_time = 5)

/proc/remove_servant_of_ratvar(mob/L, silent = FALSE)
	if(!L || !L.mind)
		return
	var/datum/antagonist/clockcult/clock_datum = L.mind.has_antag_datum(/datum/antagonist/clockcult)
	if(!clock_datum)
		return FALSE
	clock_datum.silent = silent
	clock_datum.on_removal()
	return TRUE

//procs bloodcult
/proc/iscultist(mob/living/M)
	if(istype(M, /mob/living/carbon/human/dummy))
		return TRUE
	return M?.mind?.has_antag_datum(/datum/antagonist/cult)

/proc/is_convertable_to_cult(mob/living/M,datum/team/cult/specific_cult)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.holy_role))
			return FALSE
		if(specific_cult && specific_cult.is_sacrifice_target(M.mind))
			return FALSE
		var/mob/living/master = M.mind.enslaved_to?.resolve()
		if(master && !iscultist(master))
			return FALSE
		if(M.mind.unconvertable)
			return FALSE
		if(M.is_convert_antag())
			return FALSE
	else
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD) || issilicon(M) || isbot(M) || isdrone(M) || ismouse(M) || is_servant_of_ratvar(M) || !M.client)
		return FALSE //can't convert machines, shielded, braindead, mice, or ratvar's dogs
	return TRUE
*/
/datum/game_mode
	var/list/hog_clockcult = list() //The Enlightened servants of Ratvar
	var/list/hog_cult = list() //The devoted cult of Nar'sie

/* cogcult
	var/list/datum/mind/servant = list()
	var/list/cogpillar_list = list()
	var/anchor_cogpillar
	var/anchor_time2kill = 3 MINUTES
	var/cogpillar_cooldown = FALSE
*/
/datum/game_mode/hand_of_god
	name = "Hand Of God"
	config_tag = "hand_of_god"
	antag_flag = ROLE_HOG_CULT
	restricted_jobs = list("Security Officer", "Warden", "Detective", "AI", "Cyborg","Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer", "Brig Physician", "Chaplain") 
	required_players = 43
	required_enemies = 6
	recommended_enemies = 6
	enemy_minimum_age = 14
	var/servants_to_blood = list() //the blood cult we'll convert
	var/servants_to_cog = list() //the clockies we'll convert
	var/roundstart_player_count
	title_icon = "hand_of_god"
	announce_span = "danger"
	announce_text = "A violent war between cults has errupted on the station!\n\
	<span class='danger'>Cults</span>: Free your god into the mortal realm.\n\
	<span class='notice'>Crew</span>: Prevent the cults from summonning their god."

	var/datum/team/clockcult/hand_of_ratvar
	var/datum/team/cult/hand_of_narsie

//Presetup
/datum/game_mode/hand_of_god/pre_setup()
//bloodcult
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	var/starter_hog_blood = 3 //Guaranteed 3 yummy souls
	var/number_players = num_players()
	roundstart_player_count = number_players
	starter_hog_blood = min(starter_hog_blood, 3) //max 3 
	while(starter_hog_blood)
		var/datum/mind/cultist = antag_pick(antag_candidates)
		servants_to_blood += cultist
		antag_candidates -= cultist
		cultist.special_role = ROLE_HOG_CULT
		starter_hog_blood--
	return 1

//clockcult
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	var/starter_hog_cog = 3 //Guaranteed 3 tasty bodies
	number_players = num_players()
	roundstart_player_count = number_players
	starter_hog_cog = min(starter_hog_cog, 3) //max 3 
	while(starter_hog_cog)
		var/datum/mind/servant = antag_pick(antag_candidates)
		servants_to_cog += servant
		antag_candidates -= servant
		servant.special_role = ROLE_HOG_CULT
		starter_hog_cog--
	return 1
	//is check cults
	if(servants_to_blood + servants_to_cog>=required_enemies )
		return TRUE
	else
		setup_error = "Not enough hands for the gods"
		return FALSE

//postsetup - copies the basics from respective gamemodes, modified to balance the cults

//bloodcult

/datum/game_mode/hand_of_god/post_setup()


	for(var/datum/mind/cult_mind in servants_to_blood)
		add_cultist(cult_mind, 0, equip=TRUE, cult_team = hand_of_narsie)
	hand_of_narsie.setup_objectives() //Wait until all cultists are assigned to make sure none will be chosen as sacrifice.
	return ..()

/datum/game_mode/hand_of_god/check_finished(force_ending)
	if (..())
		return TRUE
	return !hand_of_narsie.check_sacrifice_status() //we should remove this any time soon

//clockcult

	for(var/datum/mind/servant)
		log_game("[key_name(servant)] has been selected as a hand of god clock cultist")
		var/mob/living/L = servant.current
		greet_cogger(L)
		equip_cogger(L)
		add_servant_of_ratvar(L, TRUE)
		GLOB.data_core.manifest_inject(L)

/datum/game_mode/hand_of_god/proc/greet_cogger(mob/M) //Description of their role
	if(!M)
		return 0
	to_chat(M, "<span class='bold large_brass'>You are a servant of Ratvar, the Clockwork Justiciar!</span>")
	to_chat(M, span_brass("He came to you in a dream, whispering softly in your ear, showing you visions of a majestic city, covered in brass. You were not the first to be reached out to by him, and you will not be the last."))
	to_chat(M, span_brass("<span class='bold large_brass'>The hand of your god has reached you.</span>"))
	to_chat(M, span_brass("One last trial remains. Build the ark to weaken the veil and ensure the return of your lord; but beware, as there are those that seek to hinder you. They are unenlightened, show them Ratvars light to help them gain understanding and join your cause."))
	to_chat(M, span_brass("Soon, Ratvar shall create a new City of Cogs, and forge a golden age for all sentient beings."))
	M.playsound_local(get_turf(M), 'sound/ambience/antag/clockcultalr.ogg', 100, FALSE, pressure_affected = FALSE)
	return 1

/datum/game_mode/proc/equip_cogger(mob/living/M) //Grants a clockwork slab to the mob, with one of each component
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	var/obj/item/clockwork/slab/S = new
	var/slot = "At your feet"
	var/list/slots = list("In your left pocket" = ITEM_SLOT_LPOCKET, "In your right pocket" = ITEM_SLOT_RPOCKET, "In your backpack" = ITEM_SLOT_BACKPACK, "On your belt" = ITEM_SLOT_BELT)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		slot = H.equip_in_one_of_slots(S, slots)
		if(slot == "In your backpack")
			slot = "In your [H.back.name]"
	if(S && !QDELETED(S))
		to_chat(L, "<span class='bold large_brass'>There is a paper in your backpack! It'll tell you if anything's changed, as well as what to expect.</span>")
		to_chat(L, "<span class='alloy'>[slot] is a <b>clockwork slab</b>, a multipurpose tool used to construct machines and invoke ancient words of power. If this is your first time \
		as a servant, you can find a concise tutorial in the Recollection category of its interface.</span>")
		to_chat(L, "<span class='alloy italics'>If you want more information, you can read <a href=\"https://wiki.yogstation.net/wiki/Clockwork_Cult\">the wiki page</a> to learn more.</span>")
		return TRUE
	return FALSE


/datum/game_mode/hand_of_god/generate_report()   //placeholder!!!!!!!!!!!!!!!
	return "Bluespace monitors near your sector have detected multiple streams of patterned fluctuations eminating from the station. It is most probable that powerful entities \
	are using to the station as a vector to cross through ["REDACTED"]. if these entities are hostile, prevent said entities from causing harm to company personnel or property.\
	<br><br>Keep a sharp on any crew that appear to be oddly-dressed or using what appear to be magical powers, as these crew may be defectors \
	working for these entities. If they should turn out to be a credible threat, divert all avaliable assets to preventing their summoning. "


//Coggers point defense mode (to do, icons, cogpillar stuff )
//Bloodcult point defense is handled in cod/game/gamemodes/cult/cult.dm
/*
/datum/game_mode/proc/begin_cogpillar_phase()
	var/list/stone_spawns = GLOB.generic_event_spawns.Copy()
	var/list/cogpillar_areas = list()
	for(var/i = 0, i < 4, i++) //four cogpillars
		var/stone_spawn = pick_n_take(stone_spawns)
		if(!stone_spawn)
			stone_spawn = pick(GLOB.generic_event_spawns) // Fallback on all spawns
		var/spawnpoint = get_turf(stone_spawn)
		var/stone = new /obj/structure/destructible/clock_cult/cogpillar(spawnpoint)
		notify_ghosts("Bloodcult has an object of interest: [stone]!", source=stone, action=NOTIFY_ORBIT, header="Praise the Geometer!")
		var/area/A = get_area(stone)
		cogpillar_areas.Add(A.map_name)

	priority_announce("Figments of a mechanical god are being pulled through the veil anomaly in [cogpillar_areas[1]], [cogpillar_areas[2]], [cogpillar_areas[3]], and [cogpillar_areas[4]]! Destroy any non-Nanotrasen sanctioned technological structures located in those areas!","Central Command Higher Dimensional Affairs")
	addtimer(CALLBACK(src, PROC_REF(increase_cogpillar_power)), 30 SECONDS)
	set_security_level(SEC_LEVEL_GAMMA)

/datum/game_mode/proc/increase_cogpillar_power()
	if(!cogpillar_list.len) //check if we somehow ran out of cogpillars
		return
	for(var/obj/structure/destructible/clock_cult/cogpillar/B in cogpillar_list)
		if(B.current_fullness == 9)
			create_anchor_cogpillar()
			return //We're done here
		else
			B.current_fullness++
		B.update_icon()
	addtimer(CALLBACK(src, PROC_REF(increase_cogpillar_power)), 30 SECONDS)

/datum/game_mode/proc/create_anchor_cogpillar()
	if(SSticker.mode.anchor_cogpillar)
		return
	var/obj/structure/destructible/clock_cult/cogpillar/anchor_target = cogpillar_list[1] //which cogpillar is the current cantidate for anchorship
	var/anchor_power = 0 //anchor will be faster if there are more stones
	for(var/obj/structure/destructible/clock_cult/cogpillar/B in cogpillar_list)
		anchor_power++
		if(B.obj_integrity > anchor_target.obj_integrity)
			anchor_target = B
	SSticker.mode.anchor_cogpillar = anchor_target
	anchor_target.name = "anchor cogpillar"
	anchor_target.desc = "It rhythmically cl[pick("ank", "ink", "unk", "ang")] with golden light. Something is being reflected on every surface, something that isn't quite there..."
	anchor_target.anchor = TRUE
	anchor_target.max_integrity = 1200
	anchor_target.obj_integrity = 1200
	anchor_time2kill -= anchor_power * 1 MINUTES //one minute of bloodfuckery shaved off per surviving cogpillar.
	anchor_target.set_animate()
	var/area/A = get_area(anchor_target)
	addtimer(CALLBACK(anchor_target, TYPE_PROC_REF(/obj/structure/destructible/clock_cult/cogpillar, summon)), anchor_time2kill)
	priority_announce("The anomaly has weakened the veil to a hazardous level in [A.map_name]! Destroy whatever is causing it before something gets through!","Central Command Higher Dimensional Affairs")

/datum/game_mode/proc/clock_cult_loss_cogpillars()
	priority_announce("The veil anomaly appears to have been destroyed, shuttle locks have been lifted.","Central Command Higher Dimensional Affairs")
	cogpillar_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(disable_cogpillar_cooldown)), 5 MINUTES) //5 minutes
	for(var/datum/mind/M in cult)
		var/mob/living/cultist = M.current
		if(!cultist)
			continue
		cultist.playsound_local(cultist, 'sound/magic/demon_dies.ogg', 75, FALSE)
		if(isconstruct(cultist))
			to_chat(cultist, span_cultbold("You feel your form lose some of its density, becoming more fragile!"))
			cultist.maxHealth *= 0.75
			cultist.health *= 0.75
		else
			cultist.Stun(20)
			cultist.adjust_confusion(15 SECONDS)
		to_chat(cultist, span_narsiesmall("Your mind is flooded with pain as the last cogpillar is destroyed!"))

/datum/game_mode/proc/clock_cult_loss_anchor()
	priority_announce("Whatever you did worked. Veil density has returned to a safe level. Shuttle locks lifted.","Central Command Higher Dimensional Affairs")
	cogpillar_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(disable_cogpillar_cooldown)), 7 MINUTES) //7 minutes
	for(var/obj/structure/destructible/clock_cult/cogpillar/B in cogpillar_list)
		qdel(B)
		for(var/datum/mind/M in cult)
			var/mob/living/cultist = M.current
			if(!cultist)
				continue
			cultist.playsound_local(cultist, 'sound/effects/screech.ogg', 75, FALSE)
			if(isconstruct(cultist))
				to_chat(cultist, span_cultbold("You feel your form lose most of its density, becoming incredibly fragile!"))
				cultist.maxHealth *= 0.5
				cultist.health *= 0.5
			else
				cultist.Stun(4 SECONDS)
				cultist.adjust_confusion(1 MINUTES)
			to_chat(cultist, span_narsiesmall("You feel a bleakness as the destruction of the anchor cuts off your connection to Nar-Sie!"))

/datum/game_mode/proc/disable_cogpillar_cooldown()
	cogpillar_cooldown = FALSE
	for(var/datum/mind/M in cult)
		var/mob/living/L = M.current
		if(L)
			to_chat(M, span_narsiesmall("The veil has weakened enough for another attempt, prepare the summoning!"))
		if(isconstruct(L))
			L.maxHealth = initial(L.maxHealth)
			to_chat(L, span_cult("Your form regains its original durability!"))
	//send message to coggers saying they can do stuff again
*/

/datum/game_mode/hand_of_god/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Servants of Ratvar:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/servant in servants_of_ratvar)
		round_credits += "<center><h2>[servant.name] as a faithful servant of Ratvar</h2>"
	if(GLOB.ratvar_awakens)
		round_credits += "<center><h2>Ratvar as himself, returned at last</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The servants were cast astray in the void!</h2>", "<center><h2>None shall remember their names!</h2>")
	round_credits += "<br>"

	round_credits += "<center><h1>The Cult of Nar'sie:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/cultist in cult)
		round_credits += "<center><h2>[cultist.name] as a cult fanatic</h2>"
	var/datum/objective/eldergod/summon_objective = locate() in hand_of_narsie.objectives
	if(summon_objective && summon_objective.summoned)
		round_credits += "<center><h2>Nar'sie as herself, in all her glory</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The cultists have learned the danger of eldritch magic!</h2>", "<center><h2>They all disappeared!</h2>")
		round_credits += "<br>"


	round_credits += ..()
	return round_credits





