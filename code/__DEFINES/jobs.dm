
#define ENGSEC			(1<<0)

#define CAPTAIN			(1<<0)
#define HOS				(1<<1)
#define WARDEN			(1<<2)
#define DETECTIVE		(1<<3)
#define OFFICER			(1<<4)
#define CHIEF			(1<<5)
#define ENGINEER		(1<<6)
#define ATMOSTECH		(1<<7)
#define ROBOTICIST		(1<<8)
#define AI_JF			(1<<9)
#define CYBORG			(1<<10)


#define MEDSCI			(1<<1)

#define RD_JF			(1<<0)
#define SCIENTIST		(1<<1)
#define CHEMIST			(1<<2)
#define CMO_JF			(1<<3)
#define DOCTOR			(1<<4)
#define GENETICIST		(1<<5)
#define VIROLOGIST		(1<<6)
#define BRIGPHYS       (1<<7)


#define CIVILIAN		(1<<2)

#define HOP				(1<<0)
#define BARTENDER		(1<<1)
#define BOTANIST		(1<<2)
#define COOK			(1<<3)
#define JANITOR			(1<<4)
#define CURATOR			(1<<5)
#define QUARTERMASTER	(1<<6)
#define CARGOTECH		(1<<7)
#define MINER			(1<<8)
#define LAWYER			(1<<9)
#define CHAPLAIN		(1<<10)
#define CLOWN			(1<<11)
#define MIME			(1<<12)
#define ARTIST			(1<<13)
#define ASSISTANT		(1<<14)

#define JOB_AVAILABLE 0
#define JOB_UNAVAILABLE_GENERIC 1
#define JOB_UNAVAILABLE_BANNED 2
#define JOB_UNAVAILABLE_PLAYTIME 3
#define JOB_UNAVAILABLE_ACCOUNTAGE 4
#define JOB_UNAVAILABLE_SLOTFULL 5
/// Job unavailable due to incompatibility with an antag role.
#define JOB_UNAVAILABLE_ANTAG_INCOMPAT 6

#define DEFAULT_RELIGION "Christianity"
#define DEFAULT_DEITY "Space Jesus"
#define DEFAULT_BIBLE "Default Bible Name"
#define DEFAULT_BIBLE_REPLACE(religion) "The Holy Book of [religion]"

#define JOB_DISPLAY_ORDER_DEFAULT 0

/**
 * =======================
 * WARNING WARNING WARNING
 * WARNING WARNING WARNING
 * WARNING WARNING WARNING
 * =======================
 * These names are used as keys in many locations in the database
 * you cannot change them trivially without breaking job bans and
 * role time tracking, if you do this and get it wrong you will die
 * and it will hurt the entire time
 */

//No department
#define JOB_ASSISTANT "Assistant"
#define JOB_PRISONER "Prisoner"
//Command
#define JOB_CAPTAIN "Captain"
#define JOB_HEAD_OF_PERSONNEL "Head of Personnel"
#define JOB_HEAD_OF_SECURITY "Head of Security"
#define JOB_RESEARCH_DIRECTOR "Research Director"
#define JOB_CHIEF_ENGINEER "Chief Engineer"
#define JOB_CHIEF_MEDICAL_OFFICER "Chief Medical Officer"
//Silicon
#define JOB_AI "AI"
#define JOB_CYBORG "Cyborg"
#define JOB_PERSONAL_AI "Personal AI"
//Security
#define JOB_WARDEN "Warden"
#define JOB_DETECTIVE "Detective"
#define JOB_SECURITY_OFFICER "Security Officer"
#define JOB_SECURITY_OFFICER_MEDICAL "Security Officer (Medical)"
#define JOB_SECURITY_OFFICER_ENGINEERING "Security Officer (Engineering)"
#define JOB_SECURITY_OFFICER_SCIENCE "Security Officer (Science)"
#define JOB_SECURITY_OFFICER_SUPPLY "Security Officer (Cargo)"
//Engineering
#define JOB_STATION_ENGINEER "Station Engineer"
#define JOB_ATMOSPHERIC_TECHNICIAN "Atmospheric Technician"
//Medical
#define JOB_MEDICAL_DOCTOR "Medical Doctor"
#define JOB_PARAMEDIC "Paramedic"
#define JOB_CHEMIST "Chemist"
#define JOB_VIROLOGIST "Virologist"
//Science
#define JOB_SCIENTIST "Scientist"
#define JOB_ROBOTICIST "Roboticist"
#define JOB_GENETICIST "Geneticist"
//Supply
#define JOB_QUARTERMASTER "Quartermaster"
#define JOB_CARGO_TECHNICIAN "Cargo Technician"
#define JOB_SHAFT_MINER "Shaft Miner"
//Service
#define JOB_BARTENDER "Bartender"
#define JOB_BOTANIST "Botanist"
#define JOB_COOK "Cook"
#define JOB_JANITOR "Janitor"
#define JOB_CLOWN "Clown"
#define JOB_MIME "Mime"
#define JOB_CURATOR "Curator"
#define JOB_LAWYER "Lawyer"
#define JOB_CHAPLAIN "Chaplain"
#define JOB_PSYCHOLOGIST "Psychologist"
//ERTs
#define JOB_ERT_DEATHSQUAD "Death Commando"
#define JOB_ERT_COMMANDER "Emergency Response Team Commander"
#define JOB_ERT_OFFICER "Security Response Officer"
#define JOB_ERT_ENGINEER "Engineering Response Officer"
#define JOB_ERT_MEDICAL_DOCTOR "Medical Response Officer"
#define JOB_ERT_CHAPLAIN "Religious Response Officer"
#define JOB_ERT_JANITOR "Janitorial Response Officer"
#define JOB_ERT_CLOWN "Entertainment Response Officer"
//CentCom
#define JOB_CENTCOM "Central Command"
#define JOB_CENTCOM_OFFICIAL "CentCom Official"
#define JOB_CENTCOM_ADMIRAL "Admiral"
#define JOB_CENTCOM_COMMANDER "CentCom Commander"
#define JOB_CENTCOM_VIP "VIP Guest"
#define JOB_CENTCOM_BARTENDER "CentCom Bartender"
#define JOB_CENTCOM_CUSTODIAN "Custodian"
#define JOB_CENTCOM_THUNDERDOME_OVERSEER "Thunderdome Overseer"
#define JOB_CENTCOM_MEDICAL_DOCTOR "Medical Officer"
#define JOB_CENTCOM_RESEARCH_OFFICER "Research Officer"
#define JOB_CENTCOM_SPECIAL_OFFICER "Special Ops Officer"
#define JOB_CENTCOM_PRIVATE_SECURITY "Private Security Force"

#define JOB_DISPLAY_ORDER_ASSISTANT 1
#define JOB_DISPLAY_ORDER_CAPTAIN 2
#define JOB_DISPLAY_ORDER_HEAD_OF_SECURITY 3
#define JOB_DISPLAY_ORDER_WARDEN 4
#define JOB_DISPLAY_ORDER_SECURITY_OFFICER 5
#define JOB_DISPLAY_ORDER_DETECTIVE 6
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 7
#define JOB_DISPLAY_ORDER_STATION_ENGINEER 8
#define JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN 9
#define JOB_DISPLAY_ORDER_NETWORK_ADMIN 10
#define JOB_DISPLAY_ORDER_AI 11
#define JOB_DISPLAY_ORDER_CYBORG 12
#define JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR 13
#define JOB_DISPLAY_ORDER_SCIENTIST 14
#define JOB_DISPLAY_ORDER_ROBOTICIST 15
#define JOB_DISPLAY_ORDER_QUARTERMASTER 16
#define JOB_DISPLAY_ORDER_CARGO_TECHNICIAN 17
#define JOB_DISPLAY_ORDER_SHAFT_MINER 18
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 19
#define JOB_DISPLAY_ORDER_MEDICAL_DOCTOR 20
#define JOB_DISPLAY_ORDER_CHEMIST 21
#define JOB_DISPLAY_ORDER_GENETICIST 22
#define JOB_DISPLAY_ORDER_VIROLOGIST 23
#define JOB_DISPLAY_ORDER_MINING_MEDIC 24
#define JOB_DISPLAY_ORDER_PARAMEDIC 25
#define JOB_DISPLAY_ORDER_PSYCHIATRIST 26
#define JOB_DISPLAY_ORDER_BRIG_PHYSICIAN 27
#define JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL 28
#define JOB_DISPLAY_ORDER_BARTENDER 29
#define JOB_DISPLAY_ORDER_COOK 30
#define JOB_DISPLAY_ORDER_BOTANIST 31
#define JOB_DISPLAY_ORDER_JANITOR 32
#define JOB_DISPLAY_ORDER_CLOWN 33
#define JOB_DISPLAY_ORDER_MIME 34
#define JOB_DISPLAY_ORDER_CURATOR 35
#define JOB_DISPLAY_ORDER_LAWYER 36
#define JOB_DISPLAY_ORDER_ARTIST 37
#define JOB_DISPLAY_ORDER_TOURIST 38
#define JOB_DISPLAY_ORDER_CLERK 39
#define JOB_DISPLAY_ORDER_CHAPLAIN 40


/proc/find_job(target)
	//Get the job from the mind
	if(istype(target, /datum/mind))
		var/datum/mind/M = target
		return M.assigned_role

	//Alive mob, get it from the mind if possible
	if(isliving(target))
		var/mob/living/L = target
		return L.mind?.assigned_role

	//I swear to god, if you passing me a string, im going to assume you passed me the job directly and you want it compared
	if(istext(target))
		return target

	//No match
	return null

#define IS_JOB(target, job) (find_job(target) == job)
#define IS_COMMAND(target) (find_job(target) in GLOB.command_positions)
#define IS_ENGINEERING(target) (find_job(target) in GLOB.engineering_positions)
#define IS_MEDICAL(target) (find_job(target) in GLOB.medical_positions)
#define IS_SCIENCE(target) (find_job(target) in GLOB.science_positions)
#define IS_CARGO(target) (find_job(target) in GLOB.supply_positions)
#define IS_SECURITY(target) (find_job(target) in GLOB.security_positions)
