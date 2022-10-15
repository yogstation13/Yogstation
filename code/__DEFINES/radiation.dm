/*
These defines are the balancing points of various parts of the radiation system.
Changes here can have widespread effects: make sure you test well.
Ask ninjanomnom if they're around
*/

/// How much radiation is harmless to a mob, this is also when radiation waves stop spreading
#define RAD_BACKGROUND_RADIATION 9
/* WARNING: Lowering this value significantly increases SSradiation load */

// apply_effect((amount*RAD_MOB_COEFFICIENT)/max(1, (radiation**2)*RAD_OVERDOSE_REDUCTION), IRRADIATE, blocked)
/// Radiation applied is multiplied by this
#define RAD_MOB_COEFFICIENT 0.20
#define RAD_MOB_SKIN_PROTECTION ((1/RAD_MOB_COEFFICIENT)+RAD_BACKGROUND_RADIATION)

#define RAD_LOSS_PER_TICK 0.5
/// Toxin damage per tick coefficient
#define RAD_TOX_COEFFICIENT 0.08
/// Coefficient to the reduction in applied rads once the thing, usualy mob, has too much radiation
#define RAD_OVERDOSE_REDUCTION 0.000001	

/* WARNING: This number is highly sensitive to change, graph is first for best results */
/// Applied radiation must be over this to burn
#define RAD_BURN_THRESHOLD 1000	
/// How much stored radiation in a mob with no ill effects
#define RAD_MOB_SAFE 500
/// How much stored radiation to check for hair loss
#define RAD_MOB_HAIRLOSS 800
/// How much stored radiation to check for mutation
#define RAD_MOB_MUTATE 1250
/// The amount of radiation to check for vomitting
#define RAD_MOB_VOMIT 2000
/// Chance per tick of vomitting
#define RAD_MOB_VOMIT_PROB 1
/// How much stored radiation to check for stunning
#define RAD_MOB_KNOCKDOWN 2000						
/// Chance of knockdown per tick when over threshold
#define RAD_MOB_KNOCKDOWN_PROB 1
/// Amount of knockdown when it occurs
#define RAD_MOB_KNOCKDOWN_AMOUNT 3					

/// For things that shouldn't become irradiated for whatever reason
#define RAD_NO_INSULATION 1.0
/// What girders have						
#define RAD_VERY_LIGHT_INSULATION 0.9				
#define RAD_LIGHT_INSULATION 0.8
/// What common walls have
#define RAD_MEDIUM_INSULATION  0.7
/// What reinforced walls have
#define RAD_HEAVY_INSULATION 0.6
/// What rad collectors have
#define RAD_EXTREME_INSULATION 0.5
/// Unused
#define RAD_FULL_INSULATION 0

/// The default chance something can be irradiated
#define DEFAULT_RADIATION_CHANCE 10

/// The default chance for uranium structures to irradiate
#define URANIUM_IRRADIATION_CHANCE DEFAULT_RADIATION_CHANCE

/// The minimum exposure time before uranium structures can irradiate
#define URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME (3 SECONDS)

/// Return values of [proc/get_perceived_radiation_danger]
// If you change these, update /datum/looping_sound/geiger as well.
#define PERCEIVED_RADIATION_DANGER_LOW 1
#define PERCEIVED_RADIATION_DANGER_MEDIUM 2
#define PERCEIVED_RADIATION_DANGER_HIGH 3
#define PERCEIVED_RADIATION_DANGER_EXTREME 4

/// The time before geiger counters reset back to normal without any radiation pulses
#define TIME_WITHOUT_RADIATION_BEFORE_RESET (5 SECONDS)

// WARNING: The defines below could have disastrous consequences if tweaked incorrectly. See: The great SM purge of Oct.6.2017
// contamination_chance		=	(strength-RAD_MINIMUM_CONTAMINATION) * RAD_CONTAMINATION_CHANCE_COEFFICIENT * min(1/(steps*RAD_DISTANCE_COEFFICIENT), 1))
// contamination_strength	=	log(strength/RAD_MINIMUM_CONTAMINATION) * RAD_MINIMUM_CONTAMINATION * RAD_CONTAMINATION_STR_COEFFICIENT
#define RAD_MINIMUM_CONTAMINATION 1000				// How strong does a radiation wave have to be to contaminate objects
#define RAD_CONTAMINATION_CHANCE_COEFFICIENT 0.01	// Higher means higher strength scaling contamination chance
#define RAD_CONTAMINATION_STR_COEFFICIENT 0.6		// Higher means higher strength scaling contamination strength
#define RAD_DISTANCE_COEFFICIENT 1					// Lower means further rad spread

#define RAD_HALF_LIFE 30							// The half-life of contaminated objects
