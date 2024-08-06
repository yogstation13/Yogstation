
/// returns TRUE if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return TRUE
	if(issilicon(M))
		if(ispAI(M))
			return FALSE
		return TRUE	//AI can do whatever it wants
	if(IsAdminGhost(M))
		//Access can't stop the abuse
		return TRUE
	if(HAS_TRAIT(M, TRAIT_ALWAYS_NO_ACCESS))
		return FALSE
	else if(istype(M) && SEND_SIGNAL(M, COMSIG_MOB_ALLOWED, src))
		return TRUE
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(check_access(H.get_active_held_item()) || src.check_access(H.wear_id))
			return TRUE
	else if(ismonkey(M) || isalienadult(M))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(check_access(george.get_active_held_item()))
			return TRUE
	else if(isanimal(M))
		var/mob/living/simple_animal/A = M
		if(check_access(A.get_active_held_item()) || check_access(A.access_card))
			return TRUE
	return FALSE

/// Get the accesses on the item
/obj/item/proc/GetAccess()
	return list()

/// Get the ID in the object, used for PDAs
/obj/item/proc/GetID()
	return null

/obj/item/proc/RemoveID()
	return null

/obj/item/proc/InsertID()
	return FALSE

/// Convert a text string to a list of accesses
/obj/proc/text2access(access_text)
	. = list()
	if(!access_text)
		return
	var/list/split = splittext(access_text,";")
	for(var/x in split)
		var/n = text2num(x)
		if(n)
			. += n

/// Generates access from strings, Call this before using req_access or req_one_access directly
/obj/proc/gen_access()
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!req_access)
		req_access = list()
		for(var/a in text2access(req_access_txt))
			req_access += a
	if(!req_one_access)
		req_one_access = list()
		for(var/b in text2access(req_one_access_txt))
			req_one_access += b

/// Check if an item has access to this object
/obj/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : null)

/// Check if an access list has sufficient access
/obj/proc/check_access_list(list/access_list)
	gen_access()

	if(!islist(req_access)) //something's very wrong
		return TRUE

	if(!req_access.len && !length(req_one_access))
		return TRUE

	if(!length(access_list) || !islist(access_list))
		return FALSE

	for(var/req in req_access)
		if(!(req in access_list)) //doesn't have this access
			return FALSE

	if(length(req_one_access))
		for(var/req in req_one_access)
			if(req in access_list) //has an access from the single access list
				return TRUE
		return FALSE
	return TRUE

/// Get access for centcom job
/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(ACCESS_CENT_GENERAL)
		if("Custodian")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Thunderdome Overseer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
		if("CentCom Official")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("Medical Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
		if("Death Commando")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Research Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTER, ACCESS_CENT_STORAGE)
		if("Special Ops Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Admiral")
			return get_all_centcom_access()
		if("CentCom Commander")
			return get_all_centcom_access()
		if("Emergency Response Team Commander")
			return get_ert_access("commander")
		if("Security Response Officer")
			return get_ert_access("sec")
		if("Engineer Response Officer")
			return get_ert_access("eng")
		if("Medical Response Officer")
			return get_ert_access("med")
		if("CentCom Bartender")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_BAR)
		if("Comedy Response Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("HONK Squad Trooper")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)

/// Gets all station access
/proc/get_all_accesses()
	return list(
		// Service/Civilian
		ACCESS_SERVICE, ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_LAWYER, ACCESS_CLERK, ACCESS_HOP,
		// Security
		ACCESS_SECURITY, ACCESS_SEC_BASIC, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_DETECTIVE, ACCESS_BRIG_PHYS, ACCESS_WEAPONS_PERMIT, ACCESS_MECH_SECURITY, ACCESS_HOS,
		// Medical
		ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_PARAMEDIC, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_PSYCHOLOGY, ACCESS_MECH_MEDICAL, ACCESS_CMO,
		// Science
		ACCESS_SCIENCE, ACCESS_RESEARCH, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_EXPERIMENTATION, ACCESS_GENETICS, ACCESS_ROBOTICS, ACCESS_ROBO_CONTROL, ACCESS_XENOBIOLOGY, ACCESS_RND_SERVERS, ACCESS_MECH_SCIENCE, ACCESS_RD,
		// Engineering
		ACCESS_ENGINEERING, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ENGINE_EQUIP, ACCESS_CONSTRUCTION, ACCESS_TECH_STORAGE, ACCESS_SECURE_TECH, ACCESS_TCOMMS, ACCESS_TCOMMS_ADMIN, ACCESS_AUX_BASE, ACCESS_MECH_ENGINE, ACCESS_CE,
		// Supply
		ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_QM,
		// Command
		ACCESS_COMMAND, ACCESS_AI_MASTER, ACCESS_AI_SAT, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_VAULT, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_PERSONAL_LOCKERS, ACCESS_CHANGE_IDS, ACCESS_CAPTAIN)

/// Gets all centcom accesses
/proc/get_all_centcom_access()
	return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_TELEPORTER, ACCESS_CENT_CAPTAIN)

/// Every access in the game, temp solution
/proc/get_debug_access()
	return list(
		ACCESS_SERVICE, ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_LAWYER, ACCESS_CLERK, ACCESS_HOP,
		ACCESS_SECURITY, ACCESS_SEC_BASIC, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_DETECTIVE, ACCESS_BRIG_PHYS, ACCESS_WEAPONS_PERMIT, ACCESS_MECH_SECURITY, ACCESS_HOS,
		ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_PARAMEDIC, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_PSYCHOLOGY, ACCESS_MECH_MEDICAL, ACCESS_CMO,
		ACCESS_SCIENCE, ACCESS_RESEARCH, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_EXPERIMENTATION, ACCESS_GENETICS, ACCESS_ROBOTICS, ACCESS_ROBO_CONTROL, ACCESS_XENOBIOLOGY, ACCESS_RND_SERVERS, ACCESS_MECH_SCIENCE, ACCESS_RD,
		ACCESS_ENGINEERING, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ENGINE_EQUIP, ACCESS_CONSTRUCTION, ACCESS_TECH_STORAGE, ACCESS_SECURE_TECH, ACCESS_TCOMMS, ACCESS_TCOMMS_ADMIN, ACCESS_AUX_BASE, ACCESS_MECH_ENGINE, ACCESS_CE,
		ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MECH_MINING, ACCESS_QM,
		ACCESS_COMMAND, ACCESS_AI_MASTER, ACCESS_AI_SAT, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_VAULT, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_PERSONAL_LOCKERS, ACCESS_CHANGE_IDS, ACCESS_CAPTAIN,
		ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_TELEPORTER, ACCESS_CENT_CAPTAIN,
		ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_BLOODCULT, ACCESS_CLOCKCULT,
		ACCESS_RUINS_GENERAL, ACCESS_RUINS_COMMAND, ACCESS_RUINS_SECURITY, ACCESS_RUINS_ENGINEERING, ACCESS_RUINS_MEDICAL, ACCESS_RUINS_SUPPLY, ACCESS_RUINS_SCIENCE, ACCESS_RUINS_MAINTENANCE, ACCESS_RUINS_MATERIALS, ACCESS_RUINS_GENERIC1, ACCESS_RUINS_GENERIC2, ACCESS_RUINS_GENERIC3, ACCESS_RUINS_GENERIC4, ACCESS_MECH_RUINS,
		ACCESS_INACCESSIBLE) // Killing myself

/// Gets access for ERT
/proc/get_ert_access(class)
	switch(class)
		if("commander")
			return get_all_centcom_access()
		if("sec")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING)
		if("eng")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("med")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING)

/// Gets all syndicate access
/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER)

/// Gets access from region ID - Overlap between departments for the sake of ID Console and door remote grouping
/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) // Service/Civilian
			return list(ACCESS_SERVICE,
						ACCESS_THEATRE,
						ACCESS_CHAPEL_OFFICE,
						ACCESS_CREMATORIUM,
						ACCESS_LIBRARY,
						ACCESS_BAR,
						ACCESS_KITCHEN,
						ACCESS_HYDROPONICS,
						ACCESS_JANITOR,
						ACCESS_LAWYER,
						ACCESS_CLERK,
						ACCESS_HOP)
		if(2) // Security
			return list(ACCESS_SECURITY,
						ACCESS_SEC_BASIC,
						ACCESS_BRIG,
						ACCESS_ARMORY,
						ACCESS_DETECTIVE,
						ACCESS_BRIG_PHYS,
						ACCESS_WEAPONS_PERMIT,
						ACCESS_LAWYER,
						ACCESS_MECH_SECURITY,
						ACCESS_HOS)
		if(3) // Medical
			return list(ACCESS_MEDICAL,
						ACCESS_SURGERY,
						ACCESS_PARAMEDIC,
						ACCESS_MORGUE,
						ACCESS_CHEMISTRY,
						ACCESS_CLONING,
						ACCESS_VIROLOGY,
						ACCESS_PSYCHOLOGY,
						ACCESS_GENETICS,
						ACCESS_BRIG_PHYS,
						ACCESS_MECH_MEDICAL,
						ACCESS_CMO)
		if(4) // Science
			return list(ACCESS_SCIENCE,
						ACCESS_RESEARCH,
						ACCESS_TOXINS,
						ACCESS_TOXINS_STORAGE,
						ACCESS_EXPERIMENTATION,
						ACCESS_GENETICS,
						ACCESS_ROBOTICS,
						ACCESS_ROBO_CONTROL,
						ACCESS_XENOBIOLOGY,
						ACCESS_RND_SERVERS,
						ACCESS_AI_MASTER,
						ACCESS_AI_SAT,
						ACCESS_MECH_SCIENCE,
						ACCESS_RD)
		if(5) // Engineering
			return list(ACCESS_ENGINEERING,
						ACCESS_ATMOSPHERICS,
						ACCESS_MAINT_TUNNELS,
						ACCESS_EXTERNAL_AIRLOCKS,
						ACCESS_ENGINE_EQUIP,
						ACCESS_CONSTRUCTION,
						ACCESS_TECH_STORAGE,
						ACCESS_SECURE_TECH,
						ACCESS_TCOMMS,
						ACCESS_TCOMMS_ADMIN,
						ACCESS_AUX_BASE,
						ACCESS_AI_SAT,
						ACCESS_MECH_ENGINE,
						ACCESS_CE)
		if(6) // Supply
			return list(ACCESS_CARGO,
						ACCESS_CARGO_BAY,
						ACCESS_MINING,
						ACCESS_MINING_STATION,
						ACCESS_VAULT,
						ACCESS_MECH_MINING,
						ACCESS_QM)
		if(7) // Command
			return list(ACCESS_COMMAND,
						ACCESS_AI_MASTER,
						ACCESS_AI_SAT,
						ACCESS_TELEPORTER,
						ACCESS_EVA,
						ACCESS_VAULT,
						ACCESS_SECURE_TECH,
						ACCESS_RND_SERVERS,
						ACCESS_RC_ANNOUNCE,
						ACCESS_KEYCARD_AUTH,
						ACCESS_TCOMMS_ADMIN,
						ACCESS_PERSONAL_LOCKERS,
						ACCESS_CHANGE_IDS,
						ACCESS_HOP,
						ACCESS_CAPTAIN)

/// Gets the name from region ID
/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "All"
		if(1) // Service/Civilian
			return "Service"
		if(2) // Security
			return "Security"
		if(3) // Medical
			return "Medbay"
		if(4) // Science
			return "Science"
		if(5) // Engineering
			return "Engineering"
		if(6) // Supply
			return "Supply"
		if(7) // Command
			return "Command"

/// Gets teh description for an access
/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_COMMAND)
			return "Command General"
		if(ACCESS_AI_MASTER) // Yog
			return "AI Master Access"
		if(ACCESS_AI_SAT) // Yog
			return "AI Satellite"
		if(ACCESS_TELEPORTER)
			return "Teleporter"
		if(ACCESS_EVA)
			return "EVA"
		if(ACCESS_VAULT)
			return "Vault"
		if(ACCESS_RC_ANNOUNCE)
			return "RC Announcements"
		if(ACCESS_KEYCARD_AUTH)
			return "Keycode Auth."
		if(ACCESS_PERSONAL_LOCKERS)
			return "Personal Lockers"
		if(ACCESS_CHANGE_IDS)
			return "ID Console"
		if(ACCESS_CAPTAIN)
			return "Captain's Quarters"
		if(ACCESS_SECURITY)
			return "Security General"
		if(ACCESS_SEC_BASIC)
			return "Security Basic"
		if(ACCESS_BRIG)
			return "Brig"
		if(ACCESS_ARMORY)
			return "Armory"
		if(ACCESS_DETECTIVE)
			return "Detective's Office"
		if(ACCESS_BRIG_PHYS) // Yog
			return "Brig Infirmary"
		if(ACCESS_WEAPONS_PERMIT)
			return "Weapons Permit"
		if(ACCESS_HOS)
			return "HoS Office"
		if(ACCESS_ENGINEERING)
			return "Engineering General"
		if(ACCESS_ATMOSPHERICS)
			return "Atmospherics"
		if(ACCESS_MAINT_TUNNELS)
			return "Maintenance Tunnels"
		if(ACCESS_EXTERNAL_AIRLOCKS)
			return "External Airlocks"
		if(ACCESS_ENGINE_EQUIP)
			return "Power & Engineering Equipment"
		if(ACCESS_CONSTRUCTION)
			return "Construction"
		if(ACCESS_TECH_STORAGE)
			return "Tech Storage"
		if(ACCESS_SECURE_TECH)
			return "Secure Tech Storage"
		if(ACCESS_TCOMMS)
			return "Telecommunications"
		if(ACCESS_TCOMMS_ADMIN) // Yog
			return "Telecomms. Systems Admin"
		if(ACCESS_AUX_BASE)
			return "Auxiliary Base"
		if(ACCESS_CE)
			return "CE Office"
		if(ACCESS_MEDICAL)
			return "Medbay General"
		if(ACCESS_SURGERY)
			return "Surgery"
		if(ACCESS_PARAMEDIC) // Yog
			return "Paramedic Staging"
		if(ACCESS_MORGUE)
			return "Morgue"
		if(ACCESS_CHEMISTRY)
			return "Chemistry Lab"
		if(ACCESS_CLONING)
			return "Cloning Lab"
		if(ACCESS_VIROLOGY)
			return "Virology Lab"
		if(ACCESS_PSYCHOLOGY)
			return "Psychiatrist's Office"
		if(ACCESS_CMO)
			return "CMO Office"
		if(ACCESS_CARGO)
			return "Cargo General"
		if(ACCESS_CARGO_BAY)
			return "Cargo Bay"
		if(ACCESS_MINING)
			return "Mining"
		if(ACCESS_MINING_STATION)
			return "Mining Station"
		if(ACCESS_QM)
			return "QM Office"
		if(ACCESS_SCIENCE)
			return "Science General"
		if(ACCESS_RESEARCH)
			return "Research Console"
		if(ACCESS_TOXINS)
			return "Toxins Lab"
		if(ACCESS_TOXINS_STORAGE)
			return "Toxins Storage"
		if(ACCESS_EXPERIMENTATION) // Yog
			return "Experimentation Lab"
		if(ACCESS_GENETICS)
			return "Genetics Lab"
		if(ACCESS_ROBOTICS)
			return "Robotics Lab"
		if(ACCESS_ROBO_CONTROL)
			return "Robotics Bot Control"
		if(ACCESS_XENOBIOLOGY)
			return "Xenobiology Lab"
		if(ACCESS_RND_SERVERS) // Yog
			return "R&D Server Room"
		if(ACCESS_RD)
			return "RD Office"
		if(ACCESS_SERVICE)
			return "Service General"
		if(ACCESS_THEATRE)
			return "Theatre Backstage"
		if(ACCESS_CHAPEL_OFFICE)
			return "Chapel Office"
		if(ACCESS_CREMATORIUM)
			return "Crematorium"
		if(ACCESS_LIBRARY)
			return "Library"
		if(ACCESS_BAR)
			return "Bar"
		if(ACCESS_KITCHEN)
			return "Kitchen"
		if(ACCESS_HYDROPONICS)
			return "Hydroponics"
		if(ACCESS_JANITOR)
			return "Janitor's Closet"
		if(ACCESS_LAWYER)
			return "Law Office"
		if(ACCESS_CLERK) // Yog
			return "Gift Shop"
		if(ACCESS_HOP)
			return "HoP Office"
		if(ACCESS_MECH_SECURITY)
			return "Security Mech Access"	
		if(ACCESS_MECH_ENGINE)
			return "Engineering Mech Access"			
		if(ACCESS_MECH_MEDICAL)
			return "Medical Mech Access"
		if(ACCESS_MECH_MINING)
			return "Mining Mech Access"
		if(ACCESS_MECH_SCIENCE)
			return "Science Mech Access"

/// Get descriptions for centcom accesses
/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_CENT_GENERAL)
			return "Code Grey"
		if(ACCESS_CENT_THUNDER)
			return "Code Yellow"
		if(ACCESS_CENT_STORAGE)
			return "Code Orange"
		if(ACCESS_CENT_LIVING)
			return "Code Green"
		if(ACCESS_CENT_MEDICAL)
			return "Code White"
		if(ACCESS_CENT_TELEPORTER)
			return "Code Blue"
		if(ACCESS_CENT_SPECOPS)
			return "Code Black"
		if(ACCESS_CENT_CAPTAIN)
			return "Code Gold"
		if(ACCESS_CENT_BAR)
			return "Code Scotch"

/// Gets all jobs
/proc/get_all_jobs()
	return list("Assistant", "Captain", "Head of Personnel", "Bartender", "Cook", "Botanist", "Quartermaster", "Cargo Technician",
				"Shaft Miner", "Clown", "Mime", "Janitor", "Curator", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer",
				"Atmospheric Technician", "Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist",
				// yogs start - Yog jobs
				"Research Director", "Scientist", "Roboticist", "Head of Security", "Warden", "Detective", "Security Officer",
				"Network Admin", "Mining Medic", "Paramedic", "Psychiatrist", "Clerk", "Tourist", "Space Bartender", "Artist", "Brig Physician", "Synthetic")
				// yogs end

/// Gets all jobs with hud icons
/proc/get_all_job_icons() //For all existing HUD icons
	return get_all_jobs() + list("Prisoner")

/// Gets all centcom jobs
/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","CentCom Official","Medical Officer","Research Officer","Special Ops Officer","Admiral","CentCom Commander","Emergency Response Team Commander","Security Response Officer","Engineer Response Officer", "Medical Response Officer","CentCom Bartender", "Janitorial Response Officer", "Religious Response Officer", "CentCom Captain", "CentCom Major", "CentCom Commodore", "CentCom Colonel", "CentCom Rear-Admiral", "CentCom Admiral", "CentCom Executive Admiral", "Comedy Response Officer", "HONK Squad Trooper")

/// Gets all task for jobs
/proc/get_all_task_force_jobs()
	return list("Amber Soldier","Amber Commander","Amber Medic","Amber Task Force")

/// Gets the name of a job from the ID
/obj/item/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/card/id/I = GetID()
	if(!I)
		return
	var/jobName = I.assignment
	if(I.originalassignment)
		jobName = I.originalassignment
	if(jobName in get_all_job_icons()) //Check if the job has a hud icon
		return jobName
	if(jobName in get_all_centcom_jobs()) //Return with the NT logo if it is a CentCom job
		return "CentCom"
	if(jobName in get_all_task_force_jobs())
		return "ambertaskforce"
	return "Unknown" //Return unknown if none of the above apply
