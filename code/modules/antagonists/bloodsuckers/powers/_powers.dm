/datum/action/cooldown/bloodsucker
	name = "Vampiric Gift"
	desc = "A vampiric gift."
	background_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	button_icon_state = "power_feed"
	buttontooltipstyle = "cult"
	transparent_when_unavailable = TRUE

	/// Cooldown you'll have to wait between each use, decreases depending on level.
	cooldown_time = 2 SECONDS

	///Background icon when the Power is active.
	active_background_icon_state = "vamp_power_on"
	///Background icon when the Power is NOT active.
	base_background_icon_state = "vamp_power_off"

	/// The text that appears when using the help verb, meant to explain how the Power changes when ranking up.
	var/power_explanation = ""
	///The owner's stored Bloodsucker datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum_power

	// FLAGS //
	/// The effects on this Power (Toggled/Single Use/Static Cooldown)
	var/power_flags = BP_AM_TOGGLE|BP_AM_SINGLEUSE|BP_AM_STATIC_COOLDOWN|BP_AM_COSTLESS_UNCONSCIOUS
	/// Requirement flags for checks
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	/// Who can purchase the Power
	var/purchase_flags = NONE // BLOODSUCKER_CAN_BUY|LASOMBRA_CAN_BUY|GANGREL_CAN_BUY|VASSAL_CAN_BUY|HUNTER_CAN_BUY

	// VARS //
	/// If the Power is currently active.
	var/active = FALSE
	///Can increase to yield new abilities - Each Power ranks up each Rank
	var/level_current = 0
	///The cost to ACTIVATE this Power
	var/bloodcost = 0
	///The cost to MAINTAIN this Power - Only used for Constant Cost Powers
	var/constant_bloodcost = 0
	///If the Power has any additional descriptions coming from either 3rd partys or the power itself
	var/additional_text = ""
	///Path to the ascended version of the power. For Lasombra bloodsucker powers
	var/ascended_power = null

/datum/bloodsucker_power
	var/ability_path
	var/datum/action/cooldown/spell/instance
