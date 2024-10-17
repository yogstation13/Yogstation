///Defines for anomaly types
#define ANOMALY_FLUX "flux_anomaly"
#define ANOMALY_FLUX_EXPLOSIVE "flux_explosive_anomaly"
#define ANOMALY_GRAVITATIONAL "gravitational_anomaly"
#define ANOMALY_HALLUCINATION "hallucination_anomaly"
#define ANOMALY_PYRO "pyro_anomaly"
#define ANOMALY_BLUESPACE "bluespace_anomaly"
#define ANOMALY_VORTEX "vortex_anomaly"
#define ANOMALY_RADIATION "radiation_anomaly"
#define ANOMALY_RADIATION_X "radiation_goat_anomaly"

///Defines for area allowances
#define ANOMALY_AREA_BLACKLIST list(/area/ai_monitored/turret_protected/ai,/area/ai_monitored/turret_protected/ai_upload,/area/engine,/area/solar,/area/holodeck,/area/shuttle)
#define ANOMALY_AREA_SUBTYPE_WHITELIST list(/area/engine/break_room)

///Defines for the different types of explosion a flux anomaly can have
#define ANOMALY_FLUX_NO_EXPLOSION 0
#define ANOMALY_FLUX_EXPLOSION 1

///Defines if rad anomaly can spawn rad goat can have
#define ANOMALY_RADIATION_NO_GOAT 0
#define ANOMALY_RADIATION_YES_GOAT 1

/**
 *  # Anomaly Defines
 *  This file contains defines for the random event anomaly subtypes.
 */

///Time in ticks before the anomaly goes poof/explodes depending on type.
#define ANOMALY_COUNTDOWN_TIMER (200 SECONDS) // monke edit: 99 seconds -> 200 seconds

/**
 * Nuisance/funny anomalies
 */

///Time in seconds before anomaly spawns
#define ANOMALY_START_MEDIUM_TIME (6 EVENT_SECONDS)
///Time in seconds before anomaly is announced
#define ANOMALY_ANNOUNCE_MEDIUM_TIME (2 EVENT_SECONDS)
///Let them know how far away the anomaly is
#define ANOMALY_ANNOUNCE_MEDIUM_TEXT "long range scanners. Expected location:"

/**
 * Chaotic but not harmful anomalies. Give the station a chance to find it on their own.
 */

///Time in seconds before anomaly spawns
#define ANOMALY_START_HARMFUL_TIME (2 EVENT_SECONDS)
///Time in seconds before anomaly is announced
#define ANOMALY_ANNOUNCE_HARMFUL_TIME (30 EVENT_SECONDS)
///Let them know how far away the anomaly is
#define ANOMALY_ANNOUNCE_HARMFUL_TEXT "localized scanners. Detected location:"

/**
 * Anomalies that can fuck you up. Give them a bit of warning.
 */

///Time in seconds before anomaly spawns
#define ANOMALY_START_DANGEROUS_TIME (2 EVENT_SECONDS)
///Time in seconds before anomaly is announced
#define ANOMALY_ANNOUNCE_DANGEROUS_TIME (30 EVENT_SECONDS)
///Let them know how far away the anomaly is
#define ANOMALY_ANNOUNCE_DANGEROUS_TEXT "localized scanners. Detected location:"
