///called when /datum/element/turf_checker detects a new state on constant checking (new_state) TRUE for a valid turf FALSE for an invalid
#define COMSIG_TURF_CHECKER_UPDATE_STATE "turf_checker_update_state"
#define COMPONENT_CHECKER_VALID_TURF (1<<0)
#define COMPONENT_CHECKER_INVALID_TURF (2<<0)

/// Used to externally force /datum/element/light_eater to handle eating a light without physical contact. Used by nightmares. (food, eater, silent)
#define COMSIG_LIGHT_EATER_EAT "light_eater_eat"
