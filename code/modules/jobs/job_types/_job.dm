/datum/job
	/// The name of the job used for preferences, bans, etc.
	var/title = "NOPE"
	/// This job comes with these accesses by default
	var/list/base_access = list()
	/// Additional accesses for the job if config.jobs_have_minimal_access is set to false
	var/list/added_access = list()
	/// Who is responsible for demoting them
	var/department_head = list()
	/// Tells the given channels that the given mob is the new department head. See communications.dm for valid channels.
	var/list/head_announce = null
	// Used for something in preferences_savefile.dm
	var/department_flag = NONE
	var/flag = NONE //Deprecated
	/// Automatic deadmin for a job. Usually head/security positions
	var/auto_deadmin_role_flags = NONE
	// Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"
	/// How many max open slots for this job
	var/total_positions = 0
	/// How many can start the round as this job
	var/spawn_positions = 0
	/// How many players have this job
	var/current_positions = 0
	/// Supervisors, who this person answers to directly
	var/supervisors = ""
	/// Selection Color for job preferences
	var/selection_color = "#ffffff"
	/// Alternate titles for the job
	var/list/alt_titles
	/// If this is set to TRUE, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify
	/// If this is set to 1, a text is printed to the player when jobs are assigned, telling them that space law has been updated.
	var/space_law_notify
	/// If you have the use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0
	/// This is the IC age requirement for the players character in order to be this job.
	var/minimal_character_age = 0
	/// Outfit of the job
	var/outfit = null
	/// How many minutes are required to unlock this job
	var/exp_requirements = 0
	/// Which type of XP is required see `EXP_TYPE_` in __DEFINES/preferences.dm
	var/exp_type = ""
	/// Department XP required
	var/exp_type_department = ""
	/// How much antag rep this job gets increase antag chances next round unless its overriden in antag_rep.txt
	var/antag_rep = 10
	/// Base pay of the job
	var/paycheck = PAYCHECK_MINIMAL
	/// Where to pull money to pay people
	var/paycheck_department = ACCOUNT_CIV
	/// Traits assigned from jobs
	var/list/mind_traits
	/// Display order of the job
	var/display_order = JOB_DISPLAY_ORDER_DEFAULT
	/// Map Specific changes
	var/list/changed_maps = list()
	/*
		If you want to change a job on a specific map with this system, you will want to go onto that job datum
		and add said map's name to the changed_maps list, like so:

		changed_maps = list("OmegaStation")

		Then, you're going to want to make a proc called "OmegaStationChanges" on the job, which will be the one
		actually making the changes, like so:

		/datum/job/miner/proc/OmegaStationChanges()

		If you want to remove the job from said map, you will return TRUE in the proc, otherwise you can make
		whatever changes to the job datum you need to make. For example, say we want to make it so 2 wardens spawn
		on OmegaStation, we'd do the following:

		/datum/job/warden
			changed_maps = list("OmegaStation")

		/datum/job/warden/proc/OmegaStationChanges()
			total_positions = 2
			spawn_positions = 2
	*/

/datum/job/New()
	.=..()
	if(changed_maps.len)
		for(var/map in changed_maps)
			RegisterSignal(src, map, text2path("[type]/proc/[map]Changes"))

//Only override this proc
//H is usually a human unless an /equip override transformed it
/datum/job/proc/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	//do actions on H but send messages to M as the key may not have been transferred_yet
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JOB_AFTER_SPAWN, src, H, M, latejoin)
	if(mind_traits)
		for(var/t in mind_traits)
			ADD_TRAIT(H.mind, t, JOB_TRAIT)
	H.mind.add_employee(/datum/corporation/nanotrasen)

/datum/job/proc/announce(mob/living/carbon/human/H)
	if(head_announce)
		announce_head(H, head_announce)

/datum/job/proc/override_latejoin_spawn(mob/living/carbon/human/H)		//Return TRUE to force latejoining to not automatically place the person in latejoin shuttle/whatever.
	return FALSE

//Used for a special check of whether to allow a client to latejoin as this job.
/datum/job/proc/special_check_latejoin(client/C)
	return TRUE

/datum/job/proc/GetAntagRep()
	. = CONFIG_GET(keyed_list/antag_rep)[lowertext(title)]
	if(. == null)
		return antag_rep

//Don't override this unless the job transforms into a non-human (Silicons do this for example)
/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	if(!H)
		return FALSE

//This reads Command placement exceptions in code/controllers/configuration/entries/game_options to allow non-Humans in specified Command roles. If the combination of species and command role is invalid, default to Human.
	if(CONFIG_GET(keyed_list/job_species_whitelist)[type] && !splittext(CONFIG_GET(keyed_list/job_species_whitelist)[type], ",").Find(H.dna.species.id))
		if(H.dna.species.id != "human")
			H.set_species(/datum/species/human)
			H.apply_pref_name("human", preference_source)

	if(!visualsOnly)
		var/datum/bank_account/bank_account = new(H.real_name, src, H.dna.species.payday_modifier)
		bank_account.adjust_money(rand(STARTING_PAYCHECKS_MIN, STARTING_PAYCHECKS_MAX), TRUE)
		H.account_id = bank_account.account_id

	//Equip the rest of the gear
	H.dna.species.before_equip_job(src, H, visualsOnly)

	if(outfit_override || outfit)
		H.equipOutfit(outfit_override ? outfit_override : outfit, visualsOnly)

	H.dna.species.after_equip_job(src, H, visualsOnly)

	if(!visualsOnly && announce)
		announce(H)

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return src.base_access.Copy()

	. = src.base_access.Copy()

	if(!CONFIG_GET(flag/jobs_have_minimal_access)) // If we should give players extra access
		. |= src.added_access.Copy()

	if(CONFIG_GET(flag/everyone_has_maint_access)) //Config has global maint access set
		. |= list(ACCESS_MAINT_TUNNELS)

/datum/job/proc/announce_head(var/mob/living/carbon/human/H, var/channels) //tells the given channel that the given mob is the new department head. See communications.dm for valid channels.
	if(H && GLOB.announcement_systems.len)
		//timer because these should come after the captain announcement
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/addtimer, CALLBACK(pick(GLOB.announcement_systems), /obj/machinery/announcement_system/proc/announce, "NEWHEAD", H.real_name, H.job, channels), 1))

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return TRUE	//Available in 0 days = available right now = player is old enough to play.
	return FALSE


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return 0
	if(!SSdbcore.Connect())
		return 0 //Without a database connection we can't get a player's age so we'll assume they're old enough for all jobs
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/config_check()
	return TRUE

/datum/job/proc/map_check()
	return TRUE

/datum/job/proc/radio_help_message(mob/M)
	to_chat(M, "<b>Prefix your message with :h to speak on your department's radio. To see other prefixes, look closely at your headset.</b>")

/datum/outfit/job
	name = "Standard Gear"

	var/jobtype = null

	uniform = /obj/item/clothing/under/color/grey
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	box = /obj/item/storage/box/survival

	var/obj/item/id_type = /obj/item/card/id
	var/obj/item/pda_type = /obj/item/pda
	var/backpack = /obj/item/storage/backpack
	var/satchel  = /obj/item/storage/backpack/satchel
	var/duffelbag = /obj/item/storage/backpack/duffelbag

	var/uniform_skirt = null

	/// Which slot the PDA defaults to
	var/pda_slot = SLOT_BELT

	/// What shoes digitgrade crew should wear
	var/digitigrade_shoes

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	switch(H.backbag)
		if(GBACKPACK)
			back = /obj/item/storage/backpack //Grey backpack
		if(GSATCHEL)
			back = /obj/item/storage/backpack/satchel //Grey satchel
		if(GDUFFELBAG)
			back = /obj/item/storage/backpack/duffelbag //Grey Duffel bag
		if(LSATCHEL)
			back = /obj/item/storage/backpack/satchel/leather //Leather Satchel
		if(DSATCHEL)
			back = satchel //Department satchel
		if(DDUFFELBAG)
			back = duffelbag //Department duffel bag
		else
			back = backpack //Department backpack

	if (H.jumpsuit_style == PREF_SKIRT && uniform_skirt)
		uniform = uniform_skirt

	if (isplasmaman(H) && !(visualsOnly)) //this is a plasmaman fix to stop having two boxes
		box = null

	if((DIGITIGRADE in H.dna.species.species_traits) && digitigrade_shoes) 
		shoes = digitigrade_shoes

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/datum/job/J = SSjob.GetJobType(jobtype)
	if(!J)
		J = SSjob.GetJob(H.job)

	var/obj/item/card/id/C = new id_type()
	if(istype(C))
		C.access = J.get_access()
		shuffle_inplace(C.access) // Shuffle access list to make NTNet passkeys less predictable
		C.registered_name = H.real_name
		if(H.mind?.role_alt_title)
			C.assignment = H.mind.role_alt_title
		else
			C.assignment = J.title
		C.originalassignment = J.title
		if(H.age)
			C.registered_age = H.age
		C.update_label()
		var/acc_id = "[H.account_id]"
		if(acc_id in SSeconomy.bank_accounts)
			var/datum/bank_account/B = SSeconomy.bank_accounts[acc_id]
			C.registered_account = B
			B.bank_cards += C
		H.sec_hud_set_ID()

	var/obj/item/pda/PDA = new pda_type()
	if(istype(PDA))
		PDA.owner = H.real_name
		if(H.mind?.role_alt_title)
			PDA.ownjob = H.mind.role_alt_title
		else
			PDA.ownjob = J.title

		if (H.id_in_pda)
			PDA.InsertID(C)
			H.equip_to_slot_if_possible(PDA, SLOT_WEAR_ID)
		else // just in case you hate change
			H.equip_to_slot_if_possible(PDA, pda_slot)
			H.equip_to_slot_if_possible(C, SLOT_WEAR_ID)
		
		PDA.update_label()
		PDA.update_icon()
		PDA.update_filters()
		
	else
		H.equip_to_slot_if_possible(C, SLOT_WEAR_ID)

/datum/outfit/job/get_chameleon_disguise_info()
	var/list/types = ..()
	types -= /obj/item/storage/backpack //otherwise this will override the actual backpacks
	types += backpack
	types += satchel
	types += duffelbag
	return types

//Warden and regular officers add this result to their get_access()
/datum/job/proc/check_config_for_sec_maint()
	if(CONFIG_GET(flag/security_has_maint_access))
		return list(ACCESS_MAINT_TUNNELS)
	return list()
