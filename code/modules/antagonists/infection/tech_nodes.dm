//infra, 5x5 passive buff structures for the crew, have ocular warden esque anti-overlap and can't be placed behind the current combat zone
// energy pylons that recharge guns in their range
// turret pylons that passively damages nearby infection
//

//bio, gives buffs to crew health sustainability with new or improved medical equipment
// sleeper upgrade that makes sleepers heal 6 points instead of 2
// syringe gun that fires pre-loaded piercing syringes of reskinned syndicate nanites, cooldown per shot is both global per person and per gun
//

GLOBAL_LIST_EMPTY(infection_techs)

/datum/techweb_node/infection //infra 1 (also used for the base techweb node so there isnt one sitting around awkwardly)
	id = "infection_base"
	display_name = "Infected Crystalline Research (Charging Pylon)"
	description = "Basic research into infected crystalline structures, specifically the energy distributing behavior of node crystals."
	research_costs = list(TECHWEB_POINT_TYPE_INFECTION = 2500)
	design_ids = list("infection_charger")
	category = list("equipment")
	hidden = TRUE

/datum/techweb_node/infection/New()
	..()
	GLOB.infection_techs += id

/datum/techweb_node/infection/turret //infra 2
	id = "infection_turret"
	display_name = "Infected Crystalline Research (Disruptor Turret)"
	description = "Advanced research into infested crystalline structures, creating an experimental disruptor 'turret' which destroys nearby creep."
	prereq_ids = list("infection_base")
	design_ids = list("infection_turret")
	category = list("equipment")

/datum/techweb_node/infection/sleeper //bio 1
	id = "infection_sleeper"
	display_name = "Infected Biomass Research (Sleeper Enhancement)"
	description = "Basic research into infected creep and its replication. Advances here will have applications with conventional medical technology."
	design_ids = list("infection_sleeper_upgrade")
	category = list("Medical Designs")

/datum/techweb_node/infection/syringegun //bio 2
	id = "infection_injector"
	display_name = "Infected Biomass Research (Compact Medical Apparatus)"
	description = "Advanced research into infected creep, exploiting the replicating nature of infected biomass to create a fast acting medical apparatus."
	prereq_ids = list("infection_sleeper")
	design_ids = list("infection_injector")
	category = list("Medical Designs")
