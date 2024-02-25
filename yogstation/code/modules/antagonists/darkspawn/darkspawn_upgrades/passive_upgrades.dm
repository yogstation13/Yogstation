////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Passive Upgrades--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//Increases max Psi by 25.
/datum/psi_web/psi_cap
	name = "\'Psi\' Sigils"
	desc = "The Atlwjz sigils, representing Psi, are etched onto the forehead. Unlocking these sigils increases your maximum Psi by 100."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/psi_cap/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/psi_cap/on_loss()
	darkspawn.psi_cap -= 100

//Decreases the delay before psi starts regenerating
/datum/psi_web/psi_regen_delay
	name = "\'Relief\' Sigil"
	desc = "The Mqeygjao sigil, representing swiftness, is etched onto the forehead. Unlocking this sigil causes your Psi to start regenerating 5 seconds sooner."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen_delay/on_gain()
	darkspawn.psi_regen_delay -= 5 SECONDS

/datum/psi_web/psi_regen_delay/on_loss()
	darkspawn.psi_regen_delay += 5 SECONDS

//increase the speed at which psi regenerates when it does start
/datum/psi_web/psi_regen_speed
	name = "\'Recovery\' Sigil"
	desc = "The Mqeygjao sigil, representing swiftness, is etched onto the forehead. Unlocking this sigil causes your Psi to regenerate twice as quickly."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen_speed/on_gain()
	darkspawn.psi_per_second *= 2

/datum/psi_web/psi_regen_speed/on_loss()
	darkspawn.psi_per_second /= 2

//Increases healing in darkness by 25%.
/datum/psi_web/dark_healing
	name = "\'Mending\' Sigil"
	desc = "The Naykranu sigil, representing perseverence, is etched onto the back. Unlocking this sigil increases your healing in darkness by 25%."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing *= 1.25

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing /= 1.25

//Halves lightburn damage and gives resistance to dim light.
/datum/psi_web/light_resistance
	name = "\'Lightward\' Sigil"
	desc = "The Lnkpayp sigil, representing imperviousness, is etched onto the abdomen. Unlocking this sigil halves light damage taken and protects from dim light."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/light_resistance/on_gain()
	darkspawn.light_burning /= 2
	ADD_TRAIT(owner, TRAIT_DARKSPAWN_LIGHTRES, src)

/datum/psi_web/light_resistance/on_loss()
	darkspawn.light_burning *= 2
	REMOVE_TRAIT(owner, TRAIT_DARKSPAWN_LIGHTRES, src)

/datum/psi_web/brute_res
	name = "fighter innate abilities"
	desc = "me no think so good"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/brute_res/on_gain()
	owner.physiology.brute_mod /= 2

/datum/psi_web/brute_res/on_loss()
	owner.physiology.brute_mod *= 2

/datum/psi_web/burn_res
	name = "fighter innate abilities"
	desc = "me no think so good"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/brute_res/on_gain()
	owner.physiology.burn_mod /= 2

/datum/psi_web/brute_res/on_loss()
	owner.physiology.burn_mod *= 2
