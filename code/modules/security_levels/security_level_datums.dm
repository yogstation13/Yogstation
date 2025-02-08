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
	/// If TRUE, then a comms console can directly set this alert.
	var/can_set_via_comms_console = FALSE
	/// If FALSE, then the crew cannot change the alert during this alert.
	var/can_crew_change_alert = TRUE

/datum/security_level/New()
	. = ..()
	if(lowering_to_configuration_key) // I'm not sure about you, but isn't there an easier way to do this?
		lowering_to_announcement = global.config.Get(lowering_to_configuration_key)
	if(elevating_to_configuration_key)
		elevating_to_announcement = global.config.Get(elevating_to_configuration_key)

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
	shuttle_call_time_mod = 2
	can_set_via_comms_console = TRUE

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
	shuttle_call_time_mod = 1
	can_set_via_comms_console = TRUE

/**
 * RED
 *
 * Hostile threats
 */
/datum/security_level/red
	name = "red"
	announcement_color = "red"
	sound = 'sound/misc/notice3.ogg' // More angry alarm
	number_level = SEC_LEVEL_RED
	lowering_to_configuration_key = /datum/config_entry/string/alert_red_downto
	elevating_to_configuration_key = /datum/config_entry/string/alert_red_upto
	shuttle_call_time_mod = 0.5

/**
 * DELTA
 *
 * Station destruction is imminent
 */
/datum/security_level/delta
	name = "delta"
	announcement_color = "purple"
	sound = 'sound/misc/airraid.ogg' // Air alarm to signify importance
	number_level = SEC_LEVEL_DELTA
	elevating_to_configuration_key = /datum/config_entry/string/alert_delta
	shuttle_call_time_mod = 0.25
	can_crew_change_alert = FALSE

// monkestation start
/**
 * EPSILON
 *
 * Central Command is fed up with the station
 */
/datum/security_level/epsilon
	name = "epsilon"
	announcement_color = "grey" //this was painful
	number_level = SEC_LEVEL_EPSILON
	sound = 'monkestation/sound/misc/epsilon.ogg'
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	shuttle_call_time_mod = 10 //nobody escapes the station
	can_crew_change_alert = FALSE

/**
 * YELLOW
 *
 * There's a Giant hole somewhere, ENGINEERING FIX IT!!!
 */
/datum/security_level/yellow
	name = "yellow"
	announcement_color = "yellow"
	number_level = SEC_LEVEL_YELLOW
	sound = 'sound/misc/notice1.ogg' // Its just a more spesific blue alert
	lowering_to_configuration_key = /datum/config_entry/string/alert_yellow
	elevating_to_configuration_key = /datum/config_entry/string/alert_yellow
	shuttle_call_time_mod = /datum/security_level/blue::shuttle_call_time_mod
	can_set_via_comms_console = TRUE

/**
 * AMBER
 *
 * Biological issues. Zombies, blobs, and bloodlings oh my!
 */
/datum/security_level/amber
	name = "amber"
	announcement_color = "amber" //I see now why adding grey was painful. WATER IN THE FIRE, WHY?! (Thank you Absolucy for helping add more colors)
	number_level = SEC_LEVEL_AMBER
	sound = 'sound/misc/notice1.ogg' // Its just a more spesific blue alert v2
	lowering_to_configuration_key = /datum/config_entry/string/alert_amber
	elevating_to_configuration_key = /datum/config_entry/string/alert_amber
	shuttle_call_time_mod = /datum/security_level/blue::shuttle_call_time_mod
	can_set_via_comms_console = TRUE

/**
 * GAMMA
 *
 * The CentCom Flavor of Red Alert. Usually used for events.
 */
/datum/security_level/gamma
	name = "gamma"
	announcement_color = "pink" //Its like red, but diffrent.
	number_level = SEC_LEVEL_GAMMA
	sound = 'monkestation/sound/misc/gamma.ogg' // Its just the star wars death star alert, but pitched lower and slowed down ever so slightly.
	lowering_to_configuration_key = /datum/config_entry/string/alert_gamma
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = 0.5 //Oh god oh fuck things aint looking good.
	can_crew_change_alert = FALSE

/**
 * LAMBDA
 *
 * Pants are gonna be turning brown if this activates.
 */
/datum/security_level/lambda
	name = "lambda"
	announcement_color = "crimson" //Thanking Absolucy for having a bigger brain than me in figuring out colors.
	number_level = SEC_LEVEL_LAMBDA
	sound = 'monkestation/sound/misc/lambda.ogg' // Ported over the current (as of this codes time) ss14 gamma alert, renamed because it fits better. Old gamma was better :(
	elevating_to_configuration_key = /datum/config_entry/string/alert_lambda
	shuttle_call_time_mod = 0.25 //This is as bad as the nuke going off. Everyone is fucked.
	can_crew_change_alert = FALSE
// monkestation end
