////////////////////////////////////////////////////////////////////////////////////
//---------------------------Fighter only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/shadow_crash
	name = "Shadow Crash"
	desc = "Charge in a direction, knock back and briefly paralyze anyone you collide with."
	lore_description = ""
	icon_state = "shadow_crash"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_crash)

/datum/psi_web/demented_outburst
	name = "Demented Outburst"
	desc = "Deafens and confuses listeners after a five-second charge period, knocking away everyone nearby.."
	lore_description = ""
	icon_state = "demented_outburst"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/demented_outburst)

/datum/psi_web/taunt
	name = "Incite"
	desc = "Force everyone nearby to walk towards you, but disables your ability to attack for a time."
	lore_description = ""
	icon_state = "incite"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/taunt)

//Using shadow tendrils will now form two tendrils if possible.
//Attacking with one set of tendrils will attack with the other.
//This also speeds up most actions they have.
//Check fighter_abilities.dm for the effect.
/datum/psi_web/ability_upgrade/twin_tendrils
	name = "Duality Sigils"
	desc = "Unlocking these sigils causes tendrils to form in both hands if possible, empowering both."
	lore_description = "The Kqx'xpk sigils, representing duality, are etched onto the arms."
	icon_state = "duality"
	willpower_cost = 4
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	flag_to_add = TENDRIL_UPGRADE_TWIN

/datum/psi_web/ability_upgrade/cleaving_tendrils
	name = "Cleaving Sigils"
	desc = "Unlocking these sigils causes tendrils to cleave through enemies."
	lore_description = "The Akvryt sigils, representing pierce, are etched onto the arms."
	icon_state = "cleave"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_OFFENSE
	flag_to_add = TENDRIL_UPGRADE_CLEAVE

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Scout only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/permafrost
	name = "Permafrost"
	desc = "Banish heat from the surrounding terrain, freezing it instantly."
	lore_description = "Opens a pinhole to the veil, rapidly draining heat from the surrounding area."
	icon_state = "permafrost"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/permafrost)
	
/datum/psi_web/shadow_caster
	name = "Shadow Caster"
	desc = "Twists an active arm into a bow that shoots arrows made of solid darkness."
	lore_description = ""
	icon_state = "shadow_caster"
	willpower_cost = 4 //easily one of the strongest and most reliable abilities
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_caster)

/datum/psi_web/damage_Trap
	name = "Psi Trap (damage)"
	desc = "Place a trap that deals damage to non-ally that crosses it."
	lore_description = "The Shash sigil, representing danger, is carved on the ground."
	icon_state = "psi_trap_damage"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/damage)
	
/datum/psi_web/cuff_trap
	name = "Psi Trap (restrain)"
	desc = "Place a trap that restrains the legs of any non-ally that crosses it."
	lore_description = "The Hh'rt sigil, representing restraint, is carved on the ground."
	icon_state = "psi_trap_bear"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/legcuff)
	
/datum/psi_web/nausea_trap
	name = "Psi Trap (nausea)"
	desc = "Place a trap that makes any non-ally that crosses it sick to their stomach."
	lore_description = "The Vxb'rt sigil, representing disruption, is carved on the ground."
	icon_state = "psi_trap_nausea"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/nausea)
	
/datum/psi_web/teleport_trap
	name = "Psi Trap (teleport)"
	desc = "Place a trap that teleports any non-ally to a random location on the station."
	lore_description = "The Vxb'xki sigil, representing displacement, is carved on the ground."
	icon_state = "psi_trap_teleport"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/trap/teleport)	

////////////////////////////////////////////////////////////////////////////////////
//---------------------------Warlock only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/seize
	name = "Seize"
	desc = "Restrain a target's mental faculties, preventing speech and actions of any kind for a moderate duration."
	lore_description = ""
	icon_state = "seize"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/seize)
	
//staff upgrades
/datum/psi_web/ability_upgrade/staff_confusion
	name = "Confusion Sign"
	desc = "Empower your staff with the ability to confuse any enemy shot."
	lore_description = "The Vxb'rt sigil, representing disruption, is etched onto the staff."
	icon_state = "confusion_sign"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	flag_to_add = STAFF_UPGRADE_CONFUSION

/datum/psi_web/ability_upgrade/staff_light_eater
	name = "Light Eater Sign"
	desc = "Empower your staff with the ability to consume the light of anything shot."
	lore_description = "The Aaah'ryt sigil, representing consumption, is etched onto the staff."
	icon_state = "lighteater_sign"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	flag_to_add = STAFF_UPGRADE_LIGHTEATER

//no more staff upgrades
/datum/psi_web/mass_hallucination
	name = "Mass Hallucination"
	desc = "Forces brief delirium on all nearby enemies."
	lore_description = ""
	icon_state = "mass_hallucination"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/mass_hallucination)
	
/datum/psi_web/mindblast
	name = "Mind blast"
	desc = "Focus your psionic energy into a blast that deals physical damage. Can also be projected from the minds of allies."
	lore_description = ""
	icon_state = "mind_blast"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/mindblast)
	
/datum/psi_web/extract
	name = "Extract"
	desc = "Drain a target's life force or bestow it to an ally."
	lore_description = ""
	icon_state = "extract"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/extract)

/datum/psi_web/abyssal_call
	name = "Abyssal Call"
	desc = "Call a tendril at a targeted location to grasp an enemy."
	lore_description = "Summon abyssal tendrils from beyond the veil."
	icon_state = "abyssal_call"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call)
	
/datum/psi_web/shadow_beam
	name = "Void Beam"
	desc = "After a short delay, fire a huge beam of void terrain across the entire station."
	lore_description = "Tears a strip of reality into the void for a short duration."
	icon_state = "shadow_beam"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_beam)

/datum/psi_web/null_burst
	name = "Null Burst"
	desc = "After a short delay, create an explosion of void terrain at the targeted location."
	lore_description = "Tears a portion of reality into the void for a short duration."
	icon_state = "null_burst" //needs an icon
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/null_burst)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Mixed abilities-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/icyveins
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, slowing them and rapidly chilling their body."
	lore_description = ""
	icon_state = "icy_veins"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT | DARKSPAWN_WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/icyveins)
