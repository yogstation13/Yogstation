#define CULT_SCALING_COEFFICIENT 9.3 //Roughly one new cultist at roundstart per this many players

/datum/game_mode
	var/list/datum/mind/cult = list()
	var/list/bloodstone_list = list()
	var/anchor_bloodstone
	var/anchor_time2kill = 5 MINUTES
	var/bloodstone_cooldown = FALSE

/proc/iscultist(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/cult)

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/proc/is_convertable_to_cult(mob/living/M,datum/team/cult/specific_cult)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.holy_role))
			return FALSE
		if(specific_cult && specific_cult.is_sacrifice_target(M.mind))
			return FALSE
		if(M.mind.enslaved_to && !iscultist(M.mind.enslaved_to))
			return FALSE
		if(M.mind.unconvertable)
			return FALSE
	else
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD) || issilicon(M) || isbot(M) || isdrone(M) || ismouse(M) || is_servant_of_ratvar(M) || !M.client)
		return FALSE //can't convert machines, shielded, braindead, mice, or ratvar's dogs
	return TRUE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	report_type = "cult"
	antag_flag = ROLE_CULTIST
	false_report_weight = 10
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 29
	required_enemies = 4
	recommended_enemies = 4
	enemy_minimum_age = 14

	announce_span = "cult"
	announce_text = "Some crew members are trying to start a cult to Nar-Sie!\n\
	<span class='cult'>Cultists</span>: Carry out Nar-Sie's will.\n\
	<span class='notice'>Crew</span>: Prevent the cult from expanding and drive it out."

	var/finished = 0

	var/acolytes_needed = 10 //for the survive objective
	var/acolytes_survived = 0

	var/list/cultists_to_cult = list() //the cultists we'll convert

	var/datum/team/cult/main_cult


/datum/game_mode/cult/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	//cult scaling goes here
	recommended_enemies = 1 + round(num_players()/CULT_SCALING_COEFFICIENT)
	var/remaining = (num_players() % CULT_SCALING_COEFFICIENT) * 10 //Basically the % of how close the population is toward adding another cultis
	if(prob(remaining))
		recommended_enemies++


	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = antag_pick(antag_candidates)
		antag_candidates -= cultist
		cultists_to_cult += cultist
		cultist.special_role = ROLE_CULTIST
		cultist.restricted_roles = restricted_jobs
		//log_game("[key_name(cultist)] has been selected as a cultist") | yogs - redundant

	if(cultists_to_cult.len>=required_enemies)
		return TRUE
	else
		setup_error = "Not enough cultist candidates"
		return FALSE


/datum/game_mode/cult/post_setup()
	main_cult = new

	for(var/datum/mind/cult_mind in cultists_to_cult)
		add_cultist(cult_mind, 0, equip=TRUE, cult_team = main_cult)

	main_cult.setup_objectives() //Wait until all cultists are assigned to make sure none will be chosen as sacrifice.

	. = ..()

/datum/game_mode/cult/check_finished(force_ending)
	if (..())
		return TRUE

	return 1 - main_cult.check_sacrifice_status()

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind, stun , equip = FALSE, datum/team/cult/cult_team = null)
	if (!istype(cult_mind))
		return FALSE

	var/datum/antagonist/cult/new_cultist = new()
	new_cultist.give_equipment = equip

	if(cult_mind.add_antag_datum(new_cultist,cult_team))
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, silent, stun)
	if(cult_mind.current)
		var/datum/antagonist/cult/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/cult)
		if(!cult_datum)
			return FALSE
		cult_datum.silent = silent
		cult_datum.on_removal()
		if(stun)
			cult_mind.current.Unconscious(100)
		return TRUE

/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "cult")

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = GLOB.huds[ANTAG_HUD_CULT]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

/datum/game_mode/cult/proc/check_cult_victory()
	return main_cult.check_cult_victory()


/datum/game_mode/cult/set_round_result()
	..()
	if(check_cult_victory())
		SSticker.mode_result = "win - cult win"
		SSticker.news_report = CULT_SUMMON
	else
		SSticker.mode_result = "loss - staff stopped the cult"
		SSticker.news_report = CULT_FAILURE

/datum/game_mode/cult/proc/check_survive()
	var/acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if (cult_mind.current && cult_mind.current.stat != DEAD)
			if(cult_mind.current.onCentCom() || cult_mind.current.onSyndieBase())
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/datum/game_mode/cult/generate_report()
	return "Some stations in your sector have reported evidence of blood sacrifice and strange magic. Ties to the Wizards' Federation have been proven not to exist, and many employees \
			have disappeared; even Central Command employees light-years away have felt strange presences and at times hysterical compulsions. Interrogations point towards this being the work of \
			the cult of Nar-Sie. If evidence of this cult is discovered aboard your station, extreme caution and extreme vigilance must be taken going forward, and all resources should be \
			devoted to stopping this cult. Note that holy water seems to weaken and eventually return the minds of cultists that ingest it, and mindshield implants will prevent conversion \
			altogether."

/datum/game_mode/proc/begin_bloodstone_phase()
	for(var/i = 0, i < 4, i++) //four bloodstones
		var/spawnpoint = get_turf(pick(GLOB.generic_event_spawns))
		new /obj/structure/destructible/cult/bloodstone(spawnpoint)
	var/list/bloodstone_areas = list()
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		var/area/A = get_area(B)
		bloodstone_areas.Add(A.map_name)
	priority_announce("Figments of an eldritch god are being pulled through the veil anomaly in [bloodstone_areas[1]], [bloodstone_areas[2]], [bloodstone_areas[3]], and [bloodstone_areas[4]]! Destroy any occult structures located in those areas!","Central Command Higher Dimensional Affairs")
	addtimer(CALLBACK(src, .proc/increase_bloodstone_power), 30 SECONDS)

/datum/game_mode/proc/increase_bloodstone_power()
	if(!bloodstone_list.len) //check if we somehow ran out of bloodstones
		return
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		if(B.current_fullness == 9)
			create_anchor_bloodstone()
			return //We're done here
		else
			B.current_fullness++
		B.update_icon()
	addtimer(CALLBACK(src, .proc/increase_bloodstone_power), 30 SECONDS)

/datum/game_mode/proc/create_anchor_bloodstone()
	if(SSticker.mode.anchor_bloodstone)
		return
	var/obj/structure/destructible/cult/bloodstone/anchor_target = bloodstone_list[1] //which bloodstone is the current cantidate for anchorship
	var/anchor_power = 0 //anchor will be faster if there are more stones
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		anchor_power++
		if(B.obj_integrity > anchor_target.obj_integrity)
			anchor_target = B
	SSticker.mode.anchor_bloodstone = anchor_target
	anchor_target.name = "anchor bloodstone"
	anchor_target.desc = "It pulses rythmetically with migrane-inducing light. Something is being reflected on every surface, something that isn't quite there..."
	anchor_target.anchor = TRUE
	anchor_target.max_integrity = 1200
	anchor_target.obj_integrity = 1200
	anchor_time2kill -= anchor_power * 1 MINUTES //one minute of bloodfuckery shaved off per surviving bloodstone.
	anchor_target.set_animate()
	var/area/A = get_area(anchor_target)
	addtimer(CALLBACK(anchor_target, /obj/structure/destructible/cult/bloodstone.proc/summon), anchor_time2kill)
	priority_announce("The anomaly has weakened the veil to a hazardous level in [A.map_name]! Destroy whatever is causing it before something gets through!","Central Command Higher Dimensional Affairs")

/datum/game_mode/proc/cult_loss_bloodstones()
	priority_announce("The veil anomaly appears to have been destroyed, shuttle locks have been lifted.","Central Command Higher Dimensional Affairs")
	bloodstone_cooldown = TRUE
	addtimer(CALLBACK(src, .proc/disable_bloodstone_cooldown), 5 MINUTES) //5 minutes
	for(var/datum/mind/M in cult)
		var/mob/living/cultist = M.current
		if(!cultist)
			continue
		cultist.playsound_local(cultist, 'sound/magic/demon_dies.ogg', 75, FALSE)
		if(isconstruct(cultist))
			to_chat(cultist, "<span class='cultbold'>You feel your form lose some of its density, becoming more fragile!</span>")
			cultist.maxHealth *= 0.75
			cultist.health *= 0.75
		else
			cultist.Stun(20)
			cultist.confused += 15 //30 seconds of confusion
		to_chat(cultist, "<span class='narsiesmall'>Your mind is flooded with pain as the last bloodstone is destroyed!</span>")

/datum/game_mode/proc/cult_loss_anchor()
	priority_announce("Whatever you did worked. Veil density has returned to a safe level. Shuttle locks lifted.","Central Command Higher Dimensional Affairs")
	bloodstone_cooldown = TRUE
	addtimer(CALLBACK(src, .proc/disable_bloodstone_cooldown), 7 MINUTES) //7 minutes
	for(var/obj/structure/destructible/cult/bloodstone/B in bloodstone_list)
		qdel(B)
		for(var/datum/mind/M in cult)
			var/mob/living/cultist = M.current
			if(!cultist)
				continue
			cultist.playsound_local(cultist, 'sound/effects/screech.ogg', 75, FALSE)
			if(isconstruct(cultist))
				to_chat(cultist, "<span class='cultbold'>You feel your form lose most of its density, becoming incredibly fragile!</span>")
				cultist.maxHealth *= 0.5
				cultist.health *= 0.5
			else
				cultist.Stun(40)
				cultist.confused += 30 //one minute of confusion
			to_chat(cultist, "<span class='narsiesmall'>You feel a bleakness as the destruction of the anchor cuts off your connection to Nar-Sie!</span>")

/datum/game_mode/proc/disable_bloodstone_cooldown()
	bloodstone_cooldown = FALSE
	for(var/datum/mind/M in cult)
		var/mob/living/L = M.current
		if(L)
			to_chat(M, "<span class='narsiesmall'>The veil has weakened enough for another attempt, prepare the summoning!</span>")
		if(isconstruct(L))
			L.maxHealth = initial(L.maxHealth)
			to_chat(L, "<span class='cult'>Your form regains its original durability!</span>")
	//send message to cultists saying they can do stuff again

#undef CULT_SCALING_COEFFICIENT
