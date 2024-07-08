/datum/psionic_faculty/psychokinesis
	id = PSI_PSYCHOKINESIS
	name = "Psychokinesis"
	armour_types = list("melee", "bullet")

/datum/psionic_power/psychokinesis
	faculty = PSI_PSYCHOKINESIS
	use_sound = null

/datum/psionic_power/psychokinesis/psiblade
	name =            "Psiblade"
	cost =            10
	cooldown =        3 SECONDS
	min_rank =        PSI_RANK_OPERANT
	use_description = "Click on or otherwise activate an empty hand while on harm intent to manifest a psychokinetic cutting blade. The power the blade will vary based on your mastery of the faculty."
	use_sound = 'sound/effects/psi/power_fabrication.ogg'
	use_manifest = TRUE
	admin_log = FALSE

/datum/psionic_power/psychokinesis/psiblade/invoke(var/mob/living/user, var/mob/living/target)
	if((target && user != target) || !user.combat_mode)
		return FALSE
	. = ..()
	if(.)
		var/obj/item/psychic_power/psiblade/blade = new /obj/item/psychic_power/psiblade(user, user)
		switch(user.psi.get_rank(faculty))
			if(PSI_RANK_PARAMOUNT)
				blade.force = 40
			if(PSI_RANK_GRANDMASTER)
				blade.force = 24
				blade.armour_penetration = 25
				blade.AddComponent(/datum/component/cleave_attack, arc_size=180)
			if(PSI_RANK_MASTER)
				blade.force = 18
			else
				blade.force = 12
		return blade

/datum/psionic_power/psychokinesis/tinker
	name = "Tinker"
	cost = 5
	cooldown = 10
	min_rank = PSI_RANK_OPERANT
	use_description = "Click on or otherwise activate an empty hand while on help intent to manifest a psychokinetic tool. Use it in-hand to switch between tool types."
	use_sound = 'sound/effects/psi/power_fabrication.ogg'
	use_manifest = TRUE
	admin_log = FALSE

/datum/psionic_power/psychokinesis/tinker/invoke(var/mob/living/user, var/mob/living/target)
	if((target && user != target) || user.combat_mode)
		return FALSE
	. = ..()
	if(.)
		var/obj/item/psychic_power/tinker/tool = new(user)
		switch(user.psi.get_rank(faculty))
			if(PSI_RANK_PARAMOUNT)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_WELDER, TOOL_MULTITOOL, TOOL_SCALPEL, TOOL_SAW, TOOL_RETRACTOR, TOOL_HEMOSTAT, TOOL_DRILL, TOOL_CAUTERY, TOOL_BONESET, TOOL_MINING, TOOL_SHOVEL, TOOL_HATCHET)
				tool.toolspeed = 0.25
			if(PSI_RANK_GRANDMASTER)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_WELDER, TOOL_SCALPEL, TOOL_SAW, TOOL_RETRACTOR, TOOL_HEMOSTAT, TOOL_DRILL, TOOL_CAUTERY, TOOL_MINING, TOOL_SHOVEL, TOOL_HATCHET)
				tool.toolspeed = 0.5
			if(PSI_RANK_MASTER)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WIRECUTTER, TOOL_WRENCH, TOOL_SCALPEL, TOOL_RETRACTOR, TOOL_HEMOSTAT, TOOL_MINING, TOOL_SHOVEL, TOOL_HATCHET)
				tool.toolspeed = 1
			if(PSI_RANK_OPERANT)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH, TOOL_MINING)
				tool.toolspeed = 1.5
		return tool

/datum/psionic_power/psychokinesis/telekinesis
	name = "Telekinesis"
	cost = 5
	cooldown = 1 SECONDS
	min_rank = PSI_RANK_OPERANT
	use_description = "Grants the ability to telepathically move and access objects. Upgrades with your Psi Rank."
	
