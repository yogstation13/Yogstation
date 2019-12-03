//Cold Fusion
#define FUSION_TEMPERATURE_THRESHOLD_MINIMUM 4000 // This is the minimum possible required temperature that dilithium can lower fusion to.
#define DILITHIUM_LAMBDA 0.0087 // Affects how much Dilithium is required to get the required fusion temperature down to FUSION_TEMPERATURE_THRESHOLD_MINIMUM

//BZ Stuff
#define BZ_MAX_HALLUCINATION 20 // The maximum amount of hallucination stacks that BZ can give to a mob per life tick.
#define BZ_LAMBDA 0.0364 // Affects how quickly BZ reaches its maximum

#define HYDROGEN_BURN_OXY_FACTOR			100
#define HYDROGEN_BURN_HYDROGEN_FACTOR		10
#define MINIMUM_HYDROGEN_OXYBURN_ENERGY 	2000000	//This is calculated to help prevent singlecap bombs(Overpowered tritium/oxygen single tank bombs)