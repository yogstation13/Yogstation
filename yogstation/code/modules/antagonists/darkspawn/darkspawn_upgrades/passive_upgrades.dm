//mixed is at the top here because mixed abilities are probably more versatile and wanted before the specialized ones
////////////////////////////////////////////////////////////////////////////////////
//------------------------------Mixed abilities-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//medhud, duh
/datum/psi_web/medhud
	name = "Medical Sigil"
	desc = "Provides you with a medical hud."
	lore_description = "The ______ sigils, representing knowledge, are etched underneath the eyes."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES

/datum/psi_web/medhud/on_gain()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.show_to(owner)

/datum/psi_web/medhud/on_loss()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.hide_from(owner)

//xray vision, duh
/datum/psi_web/xray
	name = "X-Ray Sigil"
	desc = "Allows you to see through solid objects."
	lore_description = "The ______ sigils, representing pierce, are etched underneath the eyes."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES
	var/obj/item/organ/eyes/eyes

/datum/psi_web/xray/on_gain()
	eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && istype(eyes))
		eyes.sight_flags |= SEE_OBJS | SEE_TURFS
		owner.update_sight()

/datum/psi_web/xray/on_loss()
	if(eyes)
		eyes.sight_flags &= ~(SEE_OBJS | SEE_TURFS)
		owner.update_sight()

/datum/psi_web/sunglasses
	name = "Lightblind Sigil"
	desc = "Protects you from strong flashes of light."
	lore_description = "The ______ sigils, representing warding, are etched underneath the eyes."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT
	var/obj/item/organ/eyes/eyes

/datum/psi_web/sunglasses/on_gain()
	eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && istype(eyes))
		eyes.flash_protect += 2

/datum/psi_web/sunglasses/on_loss()
	if(eyes)
		eyes.flash_protect -= 2

//Increases max Psi by 25.
/datum/psi_web/psi_cap
	name = "Psionic Reserve Sigils"
	desc = "Unlocking these sigils increases your maximum Psi by 100."
	lore_description = "The _______ sigils, representing Psi, are etched onto the forehead."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT
	infinite = TRUE

/datum/psi_web/psi_cap/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/psi_cap/on_loss()
	darkspawn.psi_cap -= 100

//Increases healing in darkness by 25%.
/datum/psi_web/dark_healing
	name = "Mending Sigil"
	desc = "Unlocking this sigil increases your healing in darkness by 25%."
	lore_description = "The _______ sigil, representing perseverence, is etched onto the back."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT
	infinite = TRUE

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing *= 1.25

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing /= 1.25

//gives resistance to dim light
/datum/psi_web/low_light_resistance
	name = "Lightward Sigil"
	desc = "Unlocking this sigil protects from dim light."
	lore_description = "The _______ sigil, representing voiding, is etched onto the back."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/low_light_resistance/on_gain()
	ADD_TRAIT(owner, TRAIT_DARKSPAWN_LIGHTRES, src)

/datum/psi_web/low_light_resistance/on_loss()
	REMOVE_TRAIT(owner, TRAIT_DARKSPAWN_LIGHTRES, src)
	
////////////////////////////////////////////////////////////////////////////////////
//--------------------------Fighter Passive Upgrades------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//Halves lightburn damage.
/datum/psi_web/light_resistance
	name = "Shadowskin Sigil"
	desc = "Unlocking this sigil halves light damage taken."
	lore_description = "The _______ sigil, representing refraction, is etched onto the abdomen."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/light_resistance/on_gain()
	darkspawn.light_burning /= 2

/datum/psi_web/light_resistance/on_loss()
	darkspawn.light_burning *= 2

/datum/psi_web/brute_res
	name = "Callous Sigil"
	desc = "Unlocking this sigil reduces brute damage taken."
	lore_description = "The _____ sigil, representing imperviousness, is etched onto the abdomen."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER
	infinite = TRUE

/datum/psi_web/brute_res/on_gain()
	if(istype(owner))
		owner.physiology.brute_mod *= 0.8

/datum/psi_web/brute_res/on_loss()
	if(istype(owner))
		owner.physiology.brute_mod /= 0.8

/datum/psi_web/burn_res
	name = "Stifle Sigil"
	desc = "Unlocking this sigil reduces burn damage taken."
	lore_description = "The _______ sigil, representing suffocation, is etched onto the abdomen."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER
	infinite = TRUE

/datum/psi_web/brute_res/on_gain()
	if(istype(owner))
		owner.physiology.burn_mod *= 0.8

/datum/psi_web/brute_res/on_loss()
	if(istype(owner))
		owner.physiology.burn_mod /= 0.8

/datum/psi_web/noslip
	name = "Stability Sigil"
	desc = "Unlocking this sigil prevents loss of footing."
	lore_description = "The _______ sigils, representing stability, are etched onto the legs."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/noslip/on_gain()
	ADD_TRAIT(owner, TRAIT_NO_SLIP_ALL, type)

/datum/psi_web/noslip/on_loss()
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_ALL, type)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Scout Passive Upgrades------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/stamina_res
	name = "Vigor Sigils"
	desc = "Unlocking this sigil halves stamina damage taken."
	lore_description = "The _______ sigils, representing vigor, are etched onto the legs."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = SCOUT

/datum/psi_web/stamina_res/on_gain()
	if(istype(owner))
		owner.physiology.stamina_mod /= 2

/datum/psi_web/stamina_res/on_loss()
	if(istype(owner))
		owner.physiology.stamina_mod *= 2

/datum/psi_web/shadow_walk
	name = "Shadowwalk sigils"
	desc = "Unlocking this sigil greatly increases speed in the dark."
	lore_description = "The _______ sigils, representing speed, are etched onto the legs."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = SCOUT

/datum/psi_web/shadow_walk/on_gain()
	owner.AddComponent(/datum/component/shadow_step)

/datum/psi_web/shadow_walk/on_loss()
	qdel(owner.GetComponent(/datum/component/shadow_step))

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Warlock Passive Upgrades------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//Decreases the delay before psi starts regenerating
/datum/psi_web/psi_regen_delay
	name = "Psionic Relief Sigil"
	desc = "Unlocking this sigil causes your Psi to start regenerating 5 seconds sooner."
	lore_description = "The _______ sigil, representing relief, is etched onto the forehead."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen_delay/on_gain()
	darkspawn.psi_regen_delay -= 5 SECONDS

/datum/psi_web/psi_regen_delay/on_loss()
	darkspawn.psi_regen_delay += 5 SECONDS

//increase the speed at which psi regenerates when it does start
/datum/psi_web/psi_regen_speed
	name = "Psionic Recovery Sigil"
	desc = "Unlocking this sigil causes your Psi to regenerate twice as quickly."
	lore_description = "The _______ sigil, representing swiftness, is etched onto the forehead. "
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen_speed/on_gain()
	darkspawn.psi_per_second *= 2

/datum/psi_web/psi_regen_speed/on_loss()
	darkspawn.psi_per_second /= 2

//reduces spell cooldowns
/datum/psi_web/fast_cooldown
	name = "Storm Sigil"
	desc = "Unlocking this sigil causes your spells to have shorter cooldowns."
	lore_description = "The _______ sigil, representing storm, is etched onto the forehead."
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/fast_cooldown/on_gain()
	ADD_TRAIT(owner, TRAIT_FAST_COOLDOWNS, type)

/datum/psi_web/fast_cooldown/on_loss()
	REMOVE_TRAIT(owner, TRAIT_FAST_COOLDOWNS, type)

//adds an additional thrall
/datum/psi_web/more_thralls
	name = "Control Sigil"
	desc = "Unlocking this sigil allows control of two additional veils."
	lore_description = "The _______ sigils, representing control, are etched onto the arms."
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/more_thralls/on_gain()
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_veils += 2

/datum/psi_web/more_thralls/on_loss()
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_veils += 2

//buff allied darkspawns
/datum/psi_web/buff_allies
	name = "Unity Sigil"
	desc = "Unlocking this sigil allows your veil support abilities to also affect allied darkspawns."
	lore_description = "The ______ sigils, representing unity, are etched onto the hands."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/buff_allies/on_gain()
	ADD_TRAIT(owner, TRAIT_DARKSPAWN_BUFFALLIES, type)

/datum/psi_web/buff_allies/on_loss()
	REMOVE_TRAIT(owner, TRAIT_DARKSPAWN_BUFFALLIES, type)
