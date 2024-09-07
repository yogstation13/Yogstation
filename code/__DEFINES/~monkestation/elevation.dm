#define GIVE_TURF_ELEVATED_TRAIT(X) ##X/Initialize(mapload){\
	. = ..();\
	var/static/list/give_turf_traits = list(TRAIT_TURF_HAS_ELEVATED_STRUCTURE);\
	AddElement(/datum/element/give_turf_traits, give_turf_traits);\
}
