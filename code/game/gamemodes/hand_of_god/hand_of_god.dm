/*Hand of God
its the silly little gamemode where two cults are vying to summon their respective gods ratvar or nar'sie
pulls stuff from clock_cult and eldritch_cult mostly items
the silliest part is BOTH gods can be summoned at once*/

/datum/game_mode
	var/list/hand_of_ratvar = list() //The Enlightened servants of Ratvar
	var/list/hand_of_narsie = list() //The devoted cult of Nar'sie

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

	var/datum/team/clockcult/hog_clockcult
	var/datum/team/cult/hog_cult

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
	var/number_players = num_players()
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
	if(servants_to_blood.len + servants_to_cog.len>=required_enemies )
		return TRUE
	else
		setup_error = "Not enough hands for the gods"
		return FALSE

//postsetup - copies the basics from respective gamemodes, modified to balance the cults

//bloodcult

/datum/game_mode/hand_of_god/post_setup()
	hand_of_narsie = new
	hand_of_ratvar = new

	for(var/datum/mind/cult_mind in servants_to_blood)
		add_cultist(cult_mind, 0, equip=TRUE, cult_team = hog_cult)
	main_cult.setup_objectives() //Wait until all cultists are assigned to make sure none will be chosen as sacrifice.
	return ..()

/datum/game_mode/hand_of_god/check_finished(force_ending)
	if (..())
		return TRUE
	return !hog_cult.check_sacrifice_status()

//clockcult

	for(var/datum/mind/servant)
		var/datum/mind/servant = S
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
	working for this entity. If they should turn out to be a credible threat, the task falls on you and your crew to dispatch it in a timely manner. "


//Coggers point defense mode








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
	var/datum/objective/eldergod/summon_objective = locate() in main_cult.objectives
	if(summon_objective && summon_objective.summoned)
		round_credits += "<center><h2>Nar'sie as herself, in all her glory</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>The cultists have learned the danger of eldritch magic!</h2>", "<center><h2>They all disappeared!</h2>")
		round_credits += "<br>"


	round_credits += ..()
	return round_credits





