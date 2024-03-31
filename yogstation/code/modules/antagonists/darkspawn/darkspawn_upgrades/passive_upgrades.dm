//mixed is at the top here because mixed abilities are probably more versatile and wanted before the specialized ones
////////////////////////////////////////////////////////////////////////////////////
//------------------------------Mixed abilities-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//medhud, duh
/datum/psi_web/medhud
	name = "Medical Sigil"
	desc = "Provides you with a medical hud."
	lore_description = "The Vxt sigils, representing knowledge, are etched underneath the eyes."
	icon_state = "medical"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES

/datum/psi_web/medhud/on_gain()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.show_to(shadowhuman)

/datum/psi_web/medhud/on_loss()
	var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	H.hide_from(shadowhuman)

//xray vision, duh
/datum/psi_web/xray
	name = "X-Ray Sigil"
	desc = "Allows you to see through solid objects."
	lore_description = "The Akvryt sigils, representing pierce, are etched underneath the eyes."
	icon_state = "xray"
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES
	var/obj/item/organ/eyes/eyes

/datum/psi_web/xray/on_gain()
	eyes = shadowhuman.getorganslot(ORGAN_SLOT_EYES)
	if(eyes && istype(eyes))
		eyes.sight_flags |= SEE_OBJS | SEE_TURFS
		shadowhuman.update_sight()

/datum/psi_web/xray/on_loss()
	if(eyes)
		eyes.sight_flags &= ~(SEE_OBJS | SEE_TURFS)
		shadowhuman.update_sight()

//Increases max Psi by 100.
/datum/psi_web/psi_cap
	name = "Psionic Reserve Sigils"
	desc = "Unlocking these sigils increases your maximum Psi by 100."
	lore_description = "The Trin sigil, representing mind, is etched onto the forehead."
	icon_state = "psi_reserve"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = ALL_DARKSPAWN_CLASSES
	infinite = TRUE

/datum/psi_web/psi_cap/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/psi_cap/on_loss()
	darkspawn.psi_cap -= 100

/datum/psi_web/stamina_res
	name = "Vigor Sigils"
	desc = "Unlocking this sigil halves stamina damage taken."
	lore_description = "The Kalak sigils, representing eternity, are etched onto the legs."
	icon_state = "vigor"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_SCOUT | DARKSPAWN_FIGHTER

/datum/psi_web/stamina_res/on_gain()
	darkspawn.stam_mod *= 0.5

/datum/psi_web/stamina_res/on_loss()
	darkspawn.stam_mod /= 0.5
	
//Increases healing in darkness.
/datum/psi_web/dark_healing
	name = "Mending Sigil"
	desc = "Unlocking this sigil increases your healing in darkness."
	lore_description = "The Kalak sigil, representing eternity, is etched onto the back."
	icon_state = "mending"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER | DARKSPAWN_SCOUT
	infinite = TRUE

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing *= 1.25

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing /= 1.25

//gives resistance to dim light
/datum/psi_web/low_light_resistance
	name = "Lightward Sigil"
	desc = "Unlocking this sigil protects from dim light."
	lore_description = "The Vvkatkz sigil, representing warding, is etched onto the back."
	icon_state = "light_ward"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER | DARKSPAWN_SCOUT

/datum/psi_web/low_light_resistance/on_gain()
	ADD_TRAIT(darkspawn, TRAIT_DARKSPAWN_LIGHTRES, src)

/datum/psi_web/low_light_resistance/on_loss()
	REMOVE_TRAIT(darkspawn, TRAIT_DARKSPAWN_LIGHTRES, src)
	
/datum/psi_web/noslip
	name = "Stability Sigil"
	desc = "Unlocking this sigil prevents loss of footing."
	lore_description = "The Tr'bxv sigils, representing stability, are etched onto the legs."
	icon_state = "stability"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER | DARKSPAWN_SCOUT

/datum/psi_web/noslip/on_gain()
	ADD_TRAIT(shadowhuman, TRAIT_NO_SLIP_ALL, type)

/datum/psi_web/noslip/on_loss()
	REMOVE_TRAIT(shadowhuman, TRAIT_NO_SLIP_ALL, type)

//reduces spell cooldowns
/datum/psi_web/fast_cooldown
	name = "Storm Sigil"
	desc = "Unlocking this sigil causes your spells to have shorter cooldowns."
	lore_description = "The Zeras sigil, representing storm, is etched onto the forehead."
	icon_state = "storm"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK | DARKSPAWN_SCOUT

/datum/psi_web/fast_cooldown/on_gain()
	ADD_TRAIT(shadowhuman, TRAIT_FAST_COOLDOWNS, type)

/datum/psi_web/fast_cooldown/on_loss()
	REMOVE_TRAIT(shadowhuman, TRAIT_FAST_COOLDOWNS, type)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Fighter Passive Upgrades------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/sunglasses
	name = "Lightblind Sigil"
	desc = "Protects you from strong flashes of light."
	lore_description = "The Vvkatkz sigils, representing warding, are etched underneath the eyes."
	icon_state = "light_blind"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER

/datum/psi_web/sunglasses/on_gain()
	ADD_TRAIT(shadowhuman, TRAIT_NOFLASH, type)

/datum/psi_web/sunglasses/on_loss()
	REMOVE_TRAIT(shadowhuman, TRAIT_NOFLASH, type)
		
//Halves lightburn damage.
/datum/psi_web/light_resistance
	name = "Shadowskin Sigil"
	desc = "Unlocking this sigil reduces light damage taken."
	lore_description = "The Xlynsh sigil, representing refraction, is etched onto the abdomen."
	icon_state = "shadow_skin"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	infinite = TRUE

/datum/psi_web/light_resistance/on_gain()
	darkspawn.light_burning *= 0.8

/datum/psi_web/light_resistance/on_loss()
	darkspawn.light_burning /= 0.8

/datum/psi_web/brute_res
	name = "Callous Sigil"
	desc = "Unlocking this sigil reduces brute damage taken."
	lore_description = "The Hh'sha sigil, representing perserverance, is etched onto the abdomen."
	icon_state = "callous"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	infinite = TRUE

/datum/psi_web/brute_res/on_gain()
	darkspawn.brute_mod *= 0.8

/datum/psi_web/brute_res/on_loss()
	darkspawn.brute_mod /= 0.8

/datum/psi_web/burn_res
	name = "Stifle Sigil"
	desc = "Unlocking this sigil reduces burn damage taken."
	lore_description = "The Khophg sigil, representing suffocation, is etched onto the abdomen."
	icon_state = "stifle"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER
	infinite = TRUE

/datum/psi_web/burn_res/on_gain()
	darkspawn.burn_mod *= 0.85

/datum/psi_web/burn_res/on_loss()
	darkspawn.burn_mod /= 0.85

/datum/psi_web/undying
	name = "Undying Sigils"
	desc = "Unlocking this sigil will revive you upon death after some time spent in darkness."
	lore_description = "The Kalak sigil, representing eternity, is etched onto the abdomen."
	icon_state = "undying"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_FIGHTER

/datum/psi_web/undying/on_gain()
	ADD_TRAIT(darkspawn, TRAIT_DARKSPAWN_UNDYING, type)

/datum/psi_web/undying/on_loss()
	REMOVE_TRAIT(darkspawn, TRAIT_DARKSPAWN_UNDYING, type)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Scout Passive Upgrades------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/shadow_walk
	name = "Shadowwalk Sigils"
	desc = "Unlocking this sigil greatly increases speed in the dark."
	lore_description = "The Mehlak sigils, representing journey, are etched onto the legs."
	icon_state = "shadow_walk"
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_SCOUT

/datum/psi_web/shadow_walk/on_gain()
	shadowhuman.AddComponent(/datum/component/shadow_step)

/datum/psi_web/shadow_walk/on_loss()
	qdel(shadowhuman.GetComponent(/datum/component/shadow_step))

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Warlock Passive Upgrades------------------------------//
////////////////////////////////////////////////////////////////////////////////////
//Decreases the delay before psi starts regenerating
/datum/psi_web/psi_regen_delay
	name = "Psionic Relief Sigil"
	desc = "Unlocking this sigil causes your Psi to start regenerating 5 seconds sooner."
	lore_description = "The Kalak sigil, representing eternity, is etched onto the forehead."
	icon_state = "psi_relief"
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK

/datum/psi_web/psi_regen_delay/on_gain()
	darkspawn.psi_regen_delay -= 5 SECONDS

/datum/psi_web/psi_regen_delay/on_loss()
	darkspawn.psi_regen_delay += 5 SECONDS

//increase the speed at which psi regenerates when it does start
/datum/psi_web/psi_regen_speed
	name = "Psionic Recovery Sigil"
	desc = "Unlocking this sigil causes your Psi to regenerate twice as quickly."
	lore_description = "The Ieaxki sigil, representing swiftness, is etched onto the forehead."
	icon_state = "psi_recovery"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK
	infinite = TRUE

/datum/psi_web/psi_regen_speed/on_gain()
	darkspawn.psi_per_second *= 2

/datum/psi_web/psi_regen_speed/on_loss()
	darkspawn.psi_per_second /= 2

//adds an additional thrall
/datum/psi_web/more_thralls
	name = "Control Sigil"
	desc = "Unlocking this sigil allows control of two additional thralls."
	lore_description = "The Gryxah sigils, representing control, are etched onto the arms."
	icon_state = "control"
	willpower_cost = 3
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK

/datum/psi_web/more_thralls/on_gain()
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls += 2

/datum/psi_web/more_thralls/on_loss()
	var/datum/team/darkspawn/team = darkspawn.get_team()
	if(team)
		team.max_thralls += 2

//buff allied darkspawns
/datum/psi_web/buff_allies
	name = "Unity Sigil"
	desc = "Unlocking this sigil allows your thrall support abilities to also affect allied darkspawns."
	lore_description = "The Ahwelhe sigils, representing unity, are etched onto the hands."
	icon_state = "unity"
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = DARKSPAWN_WARLOCK

/datum/psi_web/buff_allies/on_gain()
	ADD_TRAIT(darkspawn, TRAIT_DARKSPAWN_BUFFALLIES, type)

/datum/psi_web/buff_allies/on_loss()
	REMOVE_TRAIT(darkspawn, TRAIT_DARKSPAWN_BUFFALLIES, type)
