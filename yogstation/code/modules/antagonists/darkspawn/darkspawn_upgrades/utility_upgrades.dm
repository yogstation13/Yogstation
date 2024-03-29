////////////////////////////////////////////////////////////////////////////////////
//---------------------------Fighter only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/deluge
	name = "Deluge"
	desc = "Douses all nearby creatures with water, extinguishing them and protecting from fire."
	lore_description = "Calls upon the endless depths to douse all with the beyond."
	icon_state = "deluge"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/aoe/deluge)

/datum/psi_web/creep
	name = "Encroach"
	desc = "Grants immunity to lightburn while active. Can be toggled on and off."
	lore_description = "Mold the darkness into an ephemeral cloak using psionic power."
	icon_state = "encroach"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/toggle/creep)
	
/datum/psi_web/time_dilation
	name = "Time Dilation"
	desc = "Greatly increases reaction times and action speed, and provides immunity to slowdown."
	lore_description = "Directly control your physical form using psionic power rather than relying on brutish biology."
	icon_state = "time_dilation"
	willpower_cost = 4
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/time_dilation)
	
/datum/psi_web/indomitable
	name = "Indomitable"
	desc = "Grants immunity to all CC effects, but locks the user into walking."
	lore_description = "Stitch yourself to the ground using shadows themselves."
	icon_state = "indomitable"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_FIGHTER
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/toggle/indomitable)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Scout only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/void_jump
	name = "Void Jump"
	desc = "A short range targeted teleport."
	lore_description = "Take a single step through the veil."
	icon_state = "shadow_jump"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/phase_jump/void_jump)

/datum/psi_web/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the veil for a time, avoiding mortal eyes and lights."
	lore_description = "The veil can be treacherous for those unprepared, however it can give reprieve."
	icon_state = "void_jaunt"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt)
	
/datum/psi_web/darkness_smoke
	name = "Blinding Miasma"
	desc = "Spews a cloud of smoke which will blind enemies and provide cover from light."
	lore_description = "Release a pocket of darkness nestled within your body."
	icon_state = "blinding_miasma"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_SCOUT
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/darkness_smoke)

////////////////////////////////////////////////////////////////////////////////////
//---------------------------Warlock only abilities-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/ability_upgrade/efficiency
	name = "Efficiency Sign"
	desc = "Optimize your staff to reduce the Psi cost to shoot."
	lore_description = "The Akylia sigil, representing efficiency, is etched onto the staff."
	icon_state = "efficiency_sign"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	flag_to_add = STAFF_UPGRADE_EFFICIENCY

/datum/psi_web/ability_upgrade/heal
	name = "Recovery Sign"
	desc = "Empower your staff with the ability to heal allies shot."
	lore_description = "The Kalak sigil, representing eternity, is etched onto the staff."
	icon_state = "recovery_sign"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	flag_to_add = STAFF_UPGRADE_HEAL
	
/datum/psi_web/ability_upgrade/extinguish
	name = "Stifle Sign"
	desc = "Empower your staff with the ability to extinguish the fire on allies shot."
	lore_description = "The Khophg sigil, representing suffocation, is etched onto the staff."
	icon_state = "extinguish_sign"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	flag_to_add = STAFF_UPGRADE_EXTINGUISH
	
/datum/psi_web/extinguish
	name = "Extinguish"
	desc = "Extinguish all light around you."
	lore_description = "Remind all that glows, that it is but a small part of reality."
	icon_state = "extinguish"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/aoe/extinguish)
	
/datum/psi_web/thrall_heal
	name = "Thrall Recovery"
	desc = "Heals all vthralls for an amount of brute and burn."
	lore_description = "While thralls are expendable, they do have their use."
	icon_state = "heal_veils"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/thrallbuff/heal)
	
/datum/psi_web/thrall_speed
	name = "Thrall Envigorate"
	desc = "Give all thralls a temporary movespeed bonus."
	lore_description = "Thralls are expendable, push them until they break."
	icon_state = "speedboost_veils"
	willpower_cost = 1
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/thrallbuff/speed)
	
/datum/psi_web/elucidate
	name = "Elucidate"
	desc = "Channel significant power through an ally, greatly healing them, cleansing all CC and providing a speed boost."
	lore_description = ""
	icon_state = "elucidate"
	willpower_cost = 2
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/pointed/elucidate)
	
/datum/psi_web/null_charge
	name = "Null Charge"
	desc = "Meddle with the powergrid via a functioning APC, causing a temporary stationwide power outage. Breaks the APC in the process."
	lore_description = ""
	icon_state = "null_charge"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/null_charge)

/datum/psi_web/quantum_disruption //basically just a worse jaunt
	name = "Quantum Disruption"
	desc = "Bend the laws of reality to allow free passage all through-out spacetime for a short duration."
	lore_description = "Disrupt the flow of possibilities, where you are, where you could be."
	icon_state = "quantum_disruption"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/erase_time/darkspawn)

/datum/psi_web/fray_self
	name = "Fray self"
	desc = "Attemps to split a piece of your psyche into a sentient copy of yourself that lasts until destroyed."
	lore_description = ""
	icon_state = "fray_self"
	willpower_cost = 3
	shadow_flags = DARKSPAWN_WARLOCK
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/fray_self)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Mixed abilities-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/umbral_trespass
	name = "Umbral Trespass"
	desc = "Melds with a target's shadow, causing you to invisibly follow them."
	lore_description = ""
	icon_state = "umbral_trespass"
	willpower_cost = 2
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/umbral_trespass)

/datum/psi_web/simulacrum
	name = "Simulacrum"
	desc = "Creates an illusion that closely resembles you. The illusion will fight nearby enemies in your stead for 10 seconds."
	lore_description = ""
	icon_state = "simulacrum"
	willpower_cost = 2
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/simulacrum)
	
/datum/psi_web/crawling_shadows
	name = "Crawling Shadows"
	desc = "Assumes a shadowy form that can crawl through vents and squeeze through the cracks in doors."
	lore_description = ""
	icon_state = "crawling_shadows"
	willpower_cost = 3
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/shapeshift/crawling_shadows)

/datum/psi_web/silver_tongue
	name = "Silver Tongue"
	desc = "When used near a communications console, allows you to forcefully transmit a message to Central Command, initiating a shuttle recall."
	lore_description = ""
	icon_state = "silver_tongue"
	willpower_cost = 2
	shadow_flags = ALL_DARKSPAWN_CLASSES
	menu_tab = STORE_UTILITY
	learned_abilities = list(/datum/action/cooldown/spell/touch/silver_tongue)
