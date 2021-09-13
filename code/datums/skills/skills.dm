GLOBAL_LIST_INIT(all_skills, list(
	/datum/skill/strength,
	/datum/skill/dexterity,
	/datum/skill/endurance,
	/datum/skill/botany,
	/datum/skill/cooking,
	/datum/skill/creativity,
	/datum/skill/survival,
	/datum/skill/forensics,
	/datum/skill/hand_to_hand,
	/datum/skill/melee,
	/datum/skill/ranged,
	/datum/skill/medicine,
	/datum/skill/anatomy,
	/datum/skill/chemistry,
	/datum/skill/psychology,
	/datum/skill/design,
	/datum/skill/robotics,
	/datum/skill/biology,
	/datum/skill/mechanics,
	/datum/skill/it,
	/datum/skill/atmospherics))

/datum/skill
	var/id
	var/name
	var/desc
	var/current_level = SKILLLEVEL_UNSKILLED
	var/datum/skillset/parent
	var/list/level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")
	var/experience = 0
	var/difficulty = 1
	var/max_starting
	var/list/proficient_jobs
	var/list/unproficient_jobs

/datum/skill/New(var/datum/skillset/new_parent)
	..()

/datum/skill/proc/get_cost(level)
	var/active_difficulty = find_active_difficulty()
	switch(level)
		if(SKILLLEVEL_UNSKILLED, SKILLLEVEL_BASIC)
			return active_difficulty
		if(SKILLLEVEL_TRAINED, SKILLLEVEL_EXPERIENCED)
			return 2 * active_difficulty
		if(SKILLLEVEL_MASTER)
			return 3 * active_difficulty
		else
			return 0

/datum/skill/proc/update_experience_level()
	switch(experience)
		if(8 * difficulty * 100 to INFINITY)
			current_level = SKILLLEVEL_MASTER
		if(4 * difficulty * 100 to 8 * difficulty * 100 )
			current_level = SKILLLEVEL_EXPERIENCED
		if(2 * difficulty * 100 to 4 * difficulty * 100)
			current_level = SKILLLEVEL_TRAINED
		if(difficulty * 100 to 2 * difficulty * 100)
			current_level = SKILLLEVEL_BASIC
		else
			current_level = SKILLLEVEL_UNSKILLED

/datum/skill/proc/find_active_difficulty()
	var/active_difficulty = difficulty
	return active_difficulty


/datum/skill/strength
	id = SKILL_STRENGHT
	name = "Strength"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/dexterity
	id = SKILL_DEXTERITY
	name = "Dexterity"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/endurance
	id = SKILL_ENDURANCE
	name = "Endurance"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/botany
	id = SKILL_BOTANY
	name = "Botany"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/cooking
	id = SKILL_COOKING
	name = "Cooking"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/creativity
	id = SKILL_CREATIVITY
	name = "Creativity"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/survival
	id = SKILL_SURVIVAL
	name = "Survival"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/forensics
	id = SKILL_FORENSICS	
	name = "Forensics"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/hand_to_hand
	id = SKILL_HAND_TO_HAND
	name = "Hand-to-Hand"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/melee
	id = SKILL_MELEE_WEAPONS	
	name = "Melee Weapons"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/ranged
	id = SKILL_RANGED_WEAPONS
	name = "Ranged Weapons"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/medicine
	id = SKILL_MEDICINE
	name = "Medicine"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/anatomy
	id = SKILL_ANATOMY
	name = "Anatomy"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/chemistry
	id = SKILL_CHEMISTRY
	name = "Chemistry"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/psychology
	id = SKILL_PHSYCHOLOGY
	name = "Psychology"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/design
	id = SKILL_DESIGN
	name = "Design"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/robotics
	id = SKILL_ROBOTICS
	name = "Robotics"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/biology
	id = SKILL_BIOLOGY
	name = "Biology"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/mechanics
	id = SKILL_MECHANICS
	name = "Mechanics"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/it
	id = SKILL_IT
	name = "Information Technology"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")

/datum/skill/atmospherics
	id = SKILL_ATMOSPHERICS
	name = "Atmospherics"
	desc = "TODO"
	level_descriptions = list(
							SKILLLEVEL_UNSKILLED	= "Unskilled Description",
							SKILLLEVEL_BASIC		= "Basic Description",
							SKILLLEVEL_TRAINED		= "Trained Description",
							SKILLLEVEL_EXPERIENCED	= "Experienced Description",
							SKILLLEVEL_MASTER		= "Professional Description")
