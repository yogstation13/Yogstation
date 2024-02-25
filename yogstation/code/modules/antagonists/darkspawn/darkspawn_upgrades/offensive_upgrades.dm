////////////////////////////////////////////////////////////////////////////////////
//---------------------------Fighter only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/shadow_crash
	name = "Shadow crash"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_crash)

/datum/psi_web/demented_outburst
	name = "Demented outburst"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/demented_outburst)

//Using shadow tendrils will now form two tendrils if possible.
//Attacking with one set of tendrils will attack with the other.
//This also speeds up most actions they have.
//Check fighter_abilities.dm for the effect.
/datum/psi_web/twin_tendrils
	name = "\'Duality\' Sigils"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_OFFENSE

	var/datum/action/cooldown/spell/toggle/shadow_tendril/spell

/datum/psi_web/twin_tendrils/on_gain()
	spell = locate() in owner.actions
	if(spell)
		spell.twin = TRUE
	else
		remove(TRUE)

/datum/psi_web/twin_tendrils/on_loss()
	if(spell)
		spell.twin = FALSE
		spell = null

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Scout only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/permafrost
	name = "permafrost"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/permafrost)
	
/datum/psi_web/shadow_caster
	name = "shadow caster"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_caster)

/datum/psi_web/damage_Trap
	name = "damage trap"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/damage)
	
/datum/psi_web/cuff_trap
	name = "cuff trap"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/legcuff)
	
/datum/psi_web/nausea_trap
	name = "nausea trap"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/nausea)
	
/datum/psi_web/teleport_trap
	name = "teleport trap"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/teleport)	

////////////////////////////////////////////////////////////////////////////////////
//---------------------------Warlock only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/mass_hallucination
	name = "mass hallucination"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/mass_hallucination)
	
/datum/psi_web/mindblast
	name = "mindblast"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/mindblast)
	
/datum/psi_web/extract
	name = "extract"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/extract)

/datum/psi_web/dabyssal_call
	name = "abyssal call"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/abyssal_call)
	
/datum/psi_web/seize
	name = "seize"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/seize)
	
/datum/psi_web/shadow_beam
	name = "shadow beam"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_beam)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Mixed abilities-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////

/datum/psi_web/icyveins
	name = "icyveins"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT | WARLOCK
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/icyveins)
