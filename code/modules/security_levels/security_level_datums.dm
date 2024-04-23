/**
 * Security levels
 *
 * These are used by the security level subsystem. Each one of these represents a security level that a player can set.
 *
 * Base type is abstract
 */

/datum/security_level
	/// The name of this security level.
	var/name = "not set"
	/// The color of our announcement divider.
	var/announcement_color = "default"
	/// The numerical level of this security level, see defines for more information.
	var/number_level = -1
	/// The sound that we will play when this security level is set
	var/sound
	/// The looping sound that will be played while the security level is set
	var/looping_sound
	/// The looping sound interval
	var/looping_sound_interval
	/// The shuttle call time modification of this security level
	var/shuttle_call_time_mod = 0
	/// Our announcement when lowering to this level
	var/lowering_to_announcement
	/// Our announcement when elevating to this level
	var/elevating_to_announcement
	/// Our configuration key for lowering to text, if set, will override the default lowering to announcement.
	var/lowering_to_configuration_key
	/// Our configuration key for elevating to text, if set, will override the default elevating to announcement.
	var/elevating_to_configuration_key
	/// Custom title to use for announcement messages
	var/custom_title
	/// If the alert level should disable night mode
	var/disable_night_mode = FALSE
	/// If the emergency lights should be activiated
	var/area_alarm = FALSE
	/// If pods should be available for player launch
	var/pod_access = FALSE
	/// If red alert access doors should be unlocked
	var/emergency_doors = FALSE
	/// Are players allowed to cryo
	var/allow_cryo = TRUE
	/// Require providing a reason for a shuttle call at this alert level
	var/require_call_reason = TRUE

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key) // I'm not sure about you, but isn't there an easier way to do this?
		lowering_to_announcement = global.config.Get(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_to_announcement = global.config.Get(elevating_to_configuration_key)

/datum/security_level/proc/on_activate(previous_level)

/**
 * GREEN
 *
 * No threats
 */
/datum/security_level/green
	name = "green"
	announcement_color = "green"
	sound = 'sound/misc/notice2.ogg' // Friendly beep
	number_level = SEC_LEVEL_GREEN
	lowering_to_configuration_key = /datum/config_entry/string/alert_green
	shuttle_call_time_mod = ALERT_COEFF_GREEN
	require_call_reason = FALSE

/**
 * BLUE
 *
 * Caution advised
 */
/datum/security_level/blue
	name = "blue"
	announcement_color = "blue"
	sound = 'sound/misc/notice1.ogg' // Angry alarm
	number_level = SEC_LEVEL_BLUE
	lowering_to_configuration_key = /datum/config_entry/string/alert_blue_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_blue_upto
	shuttle_call_time_mod = ALERT_COEFF_BLUE

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	announcement_color = "red"
	sound = 'sound/misc/notice4.ogg' // More angry alarm
	number_level = SEC_LEVEL_RED
	lowering_to_configuration_key = /datum/config_entry/string/alert_red_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_red_upto
	shuttle_call_time_mod = ALERT_COEFF_RED
	disable_night_mode = TRUE
	pod_access = TRUE
	emergency_doors = TRUE

/**
 * GAMMA
 *
 * Station is under severe threat, but not threat of immediate destruction
 */
/datum/security_level/gamma
	name = "gamma"
	announcement_color = "orange"
	sound = 'sound/misc/gamma_alert.ogg'
	number_level = SEC_LEVEL_GAMMA
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	lowering_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = ALERT_COEFF_DELTA
	disable_night_mode = TRUE
	pod_access = TRUE
	emergency_doors = TRUE
	allow_cryo = FALSE

/**
 * EPSILON
 *
 * Death squad alert
 */
/datum/security_level/epsilon
	name = "epsilon"
	announcement_color = "grey"
	sound = 'sound/misc/epsilon_alert.ogg'
	number_level = SEC_LEVEL_EPSILON
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	lowering_to_configuration_key = /datum/config_entry/string/alert_epsilon
	custom_title = "Epsilon Protocol Activated"
	shuttle_call_time_mod = ALERT_COEFF_EPSILON
	disable_night_mode = TRUE
	pod_access = TRUE
	emergency_doors = TRUE
	allow_cryo = FALSE

/datum/security_level/epsilon/on_activate(previous_level)
	send_to_playing_players(span_notice("You get a bad feeling as you hear the Epsilon alert siren."))

/**
 * DELTA
 *
 * Station destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	announcement_color = "purple"
	sound = 'sound/misc/delta_alert.ogg'
	number_level = SEC_LEVEL_DELTA
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
	shuttle_call_time_mod = ALERT_COEFF_DELTA
	disable_night_mode = TRUE
	area_alarm = TRUE
	pod_access = TRUE
	emergency_doors = TRUE
	allow_cryo = FALSE
