////////////////////////////////////////////////////////////////////////////////////
//---------------------------Fighter only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/deluge
	name = "Deluge"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/aoe/deluge)

/datum/psi_web/creep
	name = "creep"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/toggle/creep)
	
/datum/psi_web/time_dilation
	name = "time dilation"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/time_dilation)
	
/datum/psi_web/indomitable
	name = "indomitable"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/toggle/indomitable)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Scout only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/void_jump
	name = "void jump"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/phase_jump/void_jump)

/datum/psi_web/void_jaunt
	name = "void jaunt"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 2
	shadow_flags = SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt)
	
/datum/psi_web/darkness_smoke
	name = "darkness smoke"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/darkness_smoke)

////////////////////////////////////////////////////////////////////////////////////
//---------------------------Warlock only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/staff_upgrade/heal
	name = "\'heal\' Sigils"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	flag_to_add = STAFF_UPGRADE_HEAL
	
/datum/psi_web/staff_upgrade/extinguish
	name = "\'Extinguish\' Sigils"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	flag_to_add = STAFF_UPGRADE_EXTINGUISH
	
/datum/psi_web/extinguish
	name = "extinguish"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/aoe/extinguish)
	
/datum/psi_web/panopticon
	name = "panopticon"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/darkspawn_build/veil_cam)
	
/datum/psi_web/veil_heal
	name = "veil heal"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/veilbuff/heal)
	
/datum/psi_web/veil_speed
	name = "veil speed"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/veilbuff/speed)
	
/datum/psi_web/elucidate
	name = "elucidate"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/elucidate)
	
/datum/psi_web/null_charge
	name = "null charge"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/null_charge)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Mixed abilities-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/quantum_disruption
	name = "quantum disruption"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT | WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/erase_time/darkspawn)
	
/datum/psi_web/umbral_trespass
	name = "umbral trespass"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = SCOUT | WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/umbral_trespass)

/datum/psi_web/simulacrum
	name = "simulacrum"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/simulacrum)
	
/datum/psi_web/crawling_shadows
	name = "crawling shadows"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/shapeshift/crawling_shadows)

/datum/psi_web/silver_tongue
	name = "silver tongue"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/silver_tongue)
