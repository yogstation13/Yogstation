
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
#define SYNTHETIC_JF	(1<<11)


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

/// Used when the `get_job_unavailable_error_message` proc can't make sense of a given code.
#define GENERIC_JOB_UNAVAILABLE_ERROR "Error: Unknown job availability."

#define DEFAULT_RELIGION "Christianity"
#define DEFAULT_DEITY "Space Jesus"

#define JOB_DISPLAY_ORDER_DEFAULT 0

#define JOB_DISPLAY_ORDER_ASSISTANT 1
#define JOB_DISPLAY_ORDER_CAPTAIN 2
#define JOB_DISPLAY_ORDER_HEAD_OF_SECURITY 3
#define JOB_DISPLAY_ORDER_WARDEN 4
#define JOB_DISPLAY_ORDER_SECURITY_OFFICER 5
#define JOB_DISPLAY_ORDER_DETECTIVE 6
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 7
#define JOB_DISPLAY_ORDER_STATION_ENGINEER 8
#define JOB_DISPLAY_ORDER_ATMOSPHERIC_TECHNICIAN 9
#define JOB_DISPLAY_ORDER_AI 10
#define JOB_DISPLAY_ORDER_CYBORG 11
#define JOB_DISPLAY_ORDER_SYNTHETIC 12
#define JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR 13
#define JOB_DISPLAY_ORDER_SCIENTIST 14
#define JOB_DISPLAY_ORDER_ROBOTICIST 15
#define JOB_DISPLAY_ORDER_NETWORK_ADMIN 16
#define JOB_DISPLAY_ORDER_QUARTERMASTER 17
#define JOB_DISPLAY_ORDER_CARGO_TECHNICIAN 18
#define JOB_DISPLAY_ORDER_SHAFT_MINER 19
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 20
#define JOB_DISPLAY_ORDER_MEDICAL_DOCTOR 21
#define JOB_DISPLAY_ORDER_CHEMIST 22
#define JOB_DISPLAY_ORDER_GENETICIST 23
#define JOB_DISPLAY_ORDER_VIROLOGIST 24
#define JOB_DISPLAY_ORDER_MINING_MEDIC 25
#define JOB_DISPLAY_ORDER_PARAMEDIC 26
#define JOB_DISPLAY_ORDER_PSYCHIATRIST 27
#define JOB_DISPLAY_ORDER_BRIG_PHYSICIAN 28
#define JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL 29
#define JOB_DISPLAY_ORDER_BARTENDER 30
#define JOB_DISPLAY_ORDER_COOK 31
#define JOB_DISPLAY_ORDER_BOTANIST 32
#define JOB_DISPLAY_ORDER_JANITOR 33
#define JOB_DISPLAY_ORDER_CLOWN 34
#define JOB_DISPLAY_ORDER_MIME 35
#define JOB_DISPLAY_ORDER_CURATOR 36
#define JOB_DISPLAY_ORDER_LAWYER 37
#define JOB_DISPLAY_ORDER_ARTIST 38
#define JOB_DISPLAY_ORDER_TOURIST 39
#define JOB_DISPLAY_ORDER_CLERK 40
#define JOB_DISPLAY_ORDER_CHAPLAIN 41

#define DEPARTMENT_UNASSIGNED "No Department"
#define DEPARTMENT_BITFLAG_SECURITY (1<<0)
#define DEPARTMENT_SECURITY "Security"
#define DEPARTMENT_BITFLAG_COMMAND (1<<1)
#define DEPARTMENT_COMMAND "Command"
#define DEPARTMENT_BITFLAG_SERVICE (1<<2)
#define DEPARTMENT_SERVICE "Service"
#define DEPARTMENT_BITFLAG_CARGO (1<<3)
#define DEPARTMENT_CARGO "Cargo"
#define DEPARTMENT_BITFLAG_ENGINEERING (1<<4)
#define DEPARTMENT_ENGINEERING "Engineering"
#define DEPARTMENT_BITFLAG_SCIENCE (1<<5)
#define DEPARTMENT_SCIENCE "Science"
#define DEPARTMENT_BITFLAG_MEDICAL (1<<6)
#define DEPARTMENT_MEDICAL "Medical"
#define DEPARTMENT_BITFLAG_SILICON (1<<7)
#define DEPARTMENT_SILICON "Silicon"
#define DEPARTMENT_BITFLAG_ASSISTANT (1<<8)
#define DEPARTMENT_ASSISTANT "Assistant"
#define DEPARTMENT_BITFLAG_CAPTAIN (1<<9)
#define DEPARTMENT_CAPTAIN "Captain"

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
