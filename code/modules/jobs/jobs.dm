GLOBAL_LIST_INIT(command_positions, list(
	"Captain", "Station Commander", "Facility Overseer",
	"Head of Personnel", "Chief of Staff", "Head of Internal Affairs",
	"Head of Security", "Security Commander", "Security Chief",
	"Chief Engineer", "Head of Engineering", "Engineering Director",
	"Research Director", "Chief Science Officer", "Head of Research",
	"Chief Medical Officer", "Medical Director", "Head of Medical"))


GLOBAL_LIST_INIT(engineering_positions, list(
	"Chief Engineer", "Head of Engineering", "Engineering Director",
	"Station Engineer", "Engine Technician", "Solar Engineer", "Project Engineer", "Junior Engineer", "Construction Specialist",
	"Atmospheric Technician", "Breach Fixer", "Habitation Technician", "Fire Supression Technician", "Atmospherics Trainee", "Environmental Maintainer",
	"Signal Technician", "NTSL Programmer", "Comms Tech", "Station IT Support"
	))


GLOBAL_LIST_INIT(medical_positions, list(
	"Chief Medical Officer", "Medical Director", "Head of Medical",
	"Medical Doctor", "Physician", "Surgeon", "Nurse", "Medical Resident", "Attending Physician", "Chief Surgeon", "Attending Physician", "Chief Surgeon", "Medical Subdirector", "General Practitioner",
	"Geneticist", "DNA Mechanic", "Bioengineer", "Junior Geneticist", "Gene Splicer",
	"Virologist", "Microbiologist", "Pathologist", "Junior Disease Researcher", "Epidemiologist",
	"Chemist", "Pharmacist", "Chemical Analyst", "Chemistry Lab Technician", "Chemical Specialist",
	"Paramedic", "EMT", "Paramedic Trainee", "Rapid Response Medic",
	"Psychiatrist", "Councilor", "Therapist", "Mentalist",
	"Mining Medic", "Mining Medical Support", "Lavaland Medical Care Unit", "Junior Mining Medic", "Planetside Health Officer"))


GLOBAL_LIST_INIT(science_positions, list(
	"Research Director", "Chief Science Officer", "Head of Research",
	"Scientist", "Researcher", "Toxins Specialist", "Physicist", "Science Intern", "Anomalist", "Quantum Physicist", "Xenobiologist", "Bomb Specialist",
	"Roboticist", "Augmentation Theorist", "Cyborg Maintainer", "Robotics Intern", "Biomechanical Engineer", "Mechatronic Engineer"))


GLOBAL_LIST_INIT(supply_positions, list(
	"Head of Personnel", "Chief of Staff", "Head of Internal Affairs",
	"Quartermaster", "Stock Controller", "Cargo Coordinator", "Shipping Overseer",
	"Cargo Technician", "Deliveryperson", "Mail Service", "Exports Handler", "Cargo Trainee", "Crate Pusher",
	"Shaft Miner", "Lavaland Scout", "Prospector", "Junior Miner", "Major Miner"))


GLOBAL_LIST_INIT(civilian_positions, list(
	"Bartender", "Barkeep", "Tapster", "Barista", "Mixologist",
	"Botanist", "Ecologist", "Agriculturist", "Botany Greenhorn", "Hydroponicist",
	"Cook", "Chef", "Hash Slinger", "Sous-chef", "Culinary Artist",
	"Janitor", "Custodian", "Sanitation Worker", "Cleaner", "Caretaker",
	"Curator", "Librarian", "Journalist", "Archivist",
	"Lawyer", "Prosecutor", "Defense Attorney", "Paralegal", "Ace Attorney",
	"Chaplain", "Priest", "Preacher", "Cleric",
	"Clown", "Entertainer", "Comedian", "Jester",
	"Mime", "Mute Entertainer", "Silent Jokester", "Pantomimist",
	"Assistant", "Intern", "Apprentice", "Subordinate", "Temporary Worker", "Colleague", "Associate",
	"Clerk", "Salesman", "Gift Shop Attendent", "Retail Worker",
	"Tourist", "Visitor", "Traveler", "Siteseer",
	"Artist", "Composer", "Artisan"
	))


GLOBAL_LIST_INIT(security_positions, list(
	"Head of Security", "Security Commander", "Security Chief",
	"Warden", "Security Overseer", "Brig Superintendent", "Security Lt. Commander",
	"Detective", "Investigator", "Forensic Analyst", "Investigative Cadet", "Private Eye", "Inspector",
	"Security Officer", "Security Guard", "Threat Response Officer", "Civilan Protection Officer", "Security Cadet", "Security Staff Sergeant",))


GLOBAL_LIST_INIT(nonhuman_positions, list(
	"AI", "Station Central Processor", "Central Silicon Intelligence", "Cyborg Overlord",
	"Cyborg", "Android", "Robot",
	ROLE_PAI))

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_CREW = list("titles" = command_positions | engineering_positions | medical_positions | science_positions | supply_positions | security_positions | civilian_positions | nonhuman_positions), // crew positions
	EXP_TYPE_COMMAND = list("titles" = command_positions),
	EXP_TYPE_ENGINEERING = list("titles" = engineering_positions),
	EXP_TYPE_MEDICAL = list("titles" = medical_positions),
	EXP_TYPE_SCIENCE = list("titles" = science_positions),
	EXP_TYPE_SUPPLY = list("titles" = supply_positions),
	EXP_TYPE_SECURITY = list("titles" = security_positions),
	EXP_TYPE_SILICON = list("titles" = nonhuman_positions),
	EXP_TYPE_SERVICE = list("titles" = civilian_positions)
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_SPECIAL = list("Lifebringer","Ash Walker","Exile","Servant Golem","Free Golem","Hermit","Translocated Vet","Escaped Prisoner","Hotel Staff","SuperFriend","Space Syndicate","Ancient Crew","Space Doctor","Space Bartender","Beach Bum","Skeleton","Zombie","Space Bar Patron","Lavaland Syndicate","Ghost Role","Innkeeper"), // Ghost roles
	EXP_TYPE_GHOST = list() // dead people, observers
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)

/proc/guest_jobbans(job)
	return ((job in GLOB.command_positions) || (job in GLOB.nonhuman_positions) || (job in GLOB.security_positions))



//this is necessary because antags happen before job datums are handed out, but NOT before they come into existence
//so I can't simply use job datum.department_head straight from the mind datum, laaaaame.
/proc/get_department_heads(var/job_title)
	if(!job_title)
		return list()

	for(var/datum/job/J in SSjob.occupations)
		if(J.title == job_title)
			return J.department_head //this is a list

/proc/get_full_job_name(job)
	var/static/regex/cap_expand = new("cap(?!tain)")
	var/static/regex/cmo_expand = new("cmo")
	var/static/regex/hos_expand = new("hos")
	var/static/regex/hop_expand = new("hop")
	var/static/regex/rd_expand = new("rd")
	var/static/regex/ce_expand = new("ce")
	var/static/regex/qm_expand = new("qm")
	var/static/regex/sec_expand = new("(?<!security )officer")
	var/static/regex/engi_expand = new("(?<!station )engineer")
	var/static/regex/atmos_expand = new("atmos tech")
	var/static/regex/doc_expand = new("(?<!medical )doctor|medic(?!al)")
	var/static/regex/mine_expand = new("(?<!shaft )miner")
	var/static/regex/chef_expand = new("chef")
	var/static/regex/borg_expand = new("(?<!cy)borg")
	// yogs start - Yog jobs
	var/static/regex/tour_expand = new("tourist")
	var/static/regex/mm_expand = new("mining medic")
	var/static/regex/psych_expand = new("psychiatrist")
	var/static/regex/clerk_expand = new("clerk")
	var/static/regex/para_expand = new("paramedic")
	// yogs end

	job = lowertext(job)
	job = cap_expand.Replace(job, "captain")
	job = cmo_expand.Replace(job, "chief medical officer")
	job = hos_expand.Replace(job, "head of security")
	job = hop_expand.Replace(job, "head of personnel")
	job = rd_expand.Replace(job, "research director")
	job = ce_expand.Replace(job, "chief engineer")
	job = qm_expand.Replace(job, "quartermaster")
	job = sec_expand.Replace(job, "security officer")
	job = engi_expand.Replace(job, "station engineer")
	job = atmos_expand.Replace(job, "atmospheric technician")
	job = doc_expand.Replace(job, "medical doctor")
	job = mine_expand.Replace(job, "shaft miner")
	job = chef_expand.Replace(job, "cook")
	job = borg_expand.Replace(job, "cyborg")
	// yogs start - Yog jobs
	job = tour_expand.Replace(job, "tourist")
	job = mm_expand.Replace(job, "mining medic")
	job = psych_expand.Replace(job, "psychiatrist")
	job = clerk_expand.Replace(job, "clerk")
	job = para_expand.Replace(job, "paramedic")
	// yogs end
	return job

/proc/get_alternate_titles(var/job)
	var/list/jobs = SSjob.occupations
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			titles = J.alt_titles

	return titles
