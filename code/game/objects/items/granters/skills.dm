/// Grants experience to the reader.
/obj/item/book/granter/skill
	name = "skill guide"
	desc = "A guide to getting good, whatever that means."
	remarks = list(
		"Skill issue...?",
	)
	/// Experience gains from reading this book.
	var/list/exp_gain = list(
		SKILL_PHYSIOLOGY = EXPERIENCE_PER_LEVEL,
		SKILL_MECHANICAL = EXPERIENCE_PER_LEVEL,
		SKILL_TECHNICAL = EXPERIENCE_PER_LEVEL,
		SKILL_SCIENCE = EXPERIENCE_PER_LEVEL,
		SKILL_PHYSIOLOGY = EXPERIENCE_PER_LEVEL,
	)

/obj/item/book/granter/skill/can_learn(mob/living/user)
	return !user.has_exp("[type]_[exp_gain[1]]")

/obj/item/book/granter/skill/on_reading_finished(mob/living/user)
	. = ..()
	if(!user.mind)
		CRASH("[user.type] somehow read [type] without a mind!")
	for(var/skill in exp_gain)
		user.add_exp(skill, exp_gain[skill], "[type]_[skill]")

/obj/item/book/granter/skill/physiology
	name = "\improper Guide to First Aid"
	desc = "This book teaches basic first aid information."
	remarks = list(
		"Dying is bad..?",
		"Suture or cauterize open wounds to prevent bleeding out...",
		"Apply ointment or regenerative mesh to sterilize infected burns...",
		"Move critical patients on rolling beds or over your shoulder..."
	)
	exp_gain = list(
		SKILL_PHYSIOLOGY = EXP_REQ_CALC(EXP_HIGH),
	)

/obj/item/book/granter/skill/mechanics
	name = "Nuclear Engineering for Dummies"
	desc = "A step-by-step guide to operating a nuclear reactor."
	remarks = list(
		"Wear radiation protection during maintenance...",
		"Adjust control rods to moderate the temperature...",
		"High temperatures generate more power...",
		"Don't press AZ-5..?",
	)
	exp_gain = list(
		SKILL_MECHANICAL = EXP_REQ_CALC(EXP_HIGH),
	)

/obj/item/book/granter/skill/technical
	name = "Hacking 101"
	desc = "Contains detailed information on airlock maintenance."
	remarks = list(
		"Wear insulated gloves for protection...",
		"Pulse wires twice to avoid changing settings...",
		"Pry open unpowered doors with a crowbar...",
		"Bolt an open door to prevent it closing behind you...",
	)
	exp_gain = list(
		SKILL_TECHNICAL = EXP_REQ_CALC(EXP_HIGH),
	)

/obj/item/book/granter/skill/science
	name = "Statistical Mechanics and Thermodynamics"
	desc = "Perhaps it will be wise to approach this subject cautiously."
	remarks = list(
		"Ludwig Boltzmann, who spent much of his life studying statistical mechanics, died in 1906, by his own hand...",
		"Paul Ehrenfest, carrying on the work, died similarly in 1933...",
		"Now it is our turn to study statistical mechanics...",
	)
	ordered_remarks = TRUE
	exp_gain = list(
		SKILL_SCIENCE = EXP_REQ_CALC(EXP_HIGH),
	)
