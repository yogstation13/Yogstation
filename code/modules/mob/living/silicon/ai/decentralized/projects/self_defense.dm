/datum/ai_project/shock_defense
	name = "Shock Defense"
	description = "This research enables the option to shock people within 2 tiles of all of your data cores."
	research_cost = 3000
	ram_required = 0
	research_requirements_text = "Bluespace Induction Basics"
	research_requirements = list(/datum/ai_project/induction_basic)
	can_be_run = FALSE

	category = AI_PROJECT_INDUCTION

	ability_path = /datum/action/innate/ai/shock_defense
	ability_recharge_cost = 2000

/datum/ai_project/shock_defense/finish()
	add_ability(/datum/action/innate/ai/shock_defense)

/datum/action/innate/ai/shock_defense
	name = "Shock Defense"
	desc = "Shocks anyone within 2 tiles of your data cores."
	button_icon_state = "emergency_lights"
	uses = 2
	delete_on_empty = FALSE

/datum/action/innate/ai/shock_defense/Activate()
	if(!isaicore(owner.loc))
		to_chat(owner, span_warning("You must be in your core to do this!"))
		return
	for(var/obj/machinery/ai/data_core/core in owner.ai_network.get_all_nodes())
		tesla_zap(core, 2, 15000, (TESLA_MOB_DAMAGE | TESLA_MOB_STUN))
		core.use_power(5000)
