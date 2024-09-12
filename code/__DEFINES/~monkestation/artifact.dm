
//size
#define ARTIFACT_SIZE_TINY 0 //items
#define ARTIFACT_SIZE_SMALL 1 //big items
#define ARTIFACT_SIZE_LARGE 2 //not items

// origins
#define ORIGIN_NARSIE "narnar"
#define ORIGIN_SILICON "silicon"
#define ORIGIN_WIZARD "wiznerd"
#define ORIGIN_PRECURSOR "precursor"
#define ORIGIN_MARTIAN "martian"
// rarities
#define ARTIFACT_COMMON 500
#define ARTIFACT_UNCOMMON 400
#define ARTIFACT_VERYUNCOMMON 300
#define ARTIFACT_RARE 250
#define ARTIFACT_VERYRARE 125

//cuts down on boiler plate code, last 3 args can be null.
#define ARTIFACT_SETUP(X,subsystem,forced_origin,forced_effect,forced_size) ##X/Initialize(mapload){\
	. = ..();\
	START_PROCESSING(subsystem, src);\
	if(assoc_comp) {\
		assoc_comp = AddComponent(assoc_comp, forced_origin, forced_effect, forced_size);\
		RegisterSignal(src, COMSIG_QDELETING, PROC_REF(on_delete));\
		if(isitem(src)) {\
			RegisterSignal(src,COMSIG_ITEM_POST_EQUIPPED,PROC_REF(on_artifact_touched));\
			RegisterSignal(src,COMSIG_MOB_ITEM_ATTACK,PROC_REF(on_artifact_attack));\
		}\
	}\
} \
##X/proc/on_delete(atom/source){\
	SIGNAL_HANDLER;\
	assoc_comp = null;\
} \
##X/process(){\
	assoc_comp?.stimulate_from_turf_heat(get_turf(src));\
	if(assoc_comp?.active) {\
		for(var/datum/artifact_effect/eff in assoc_comp.artifact_effects) {\
			eff.effect_process();\
		}\
	}\
} \
##X/proc/on_artifact_touched(obj/item/the_item,mob/toucher,slot){ \
	SIGNAL_HANDLER; \
	if(assoc_comp) { \
		for(var/datum/artifact_effect/eff in assoc_comp.artifact_effects) {\
			eff.effect_touched(toucher);\
		}\
	}\
}\
##X/proc/on_artifact_attack(mob/target, mob/user, params){ \
	SIGNAL_HANDLER; \
	if(assoc_comp) { \
		for(var/datum/artifact_effect/eff in assoc_comp.artifact_effects) {\
			eff.effect_touched(target);\
			if(prob(10)){ \
				eff.effect_touched(user);\
			} \
		}\
	}\
} \
##X/rad_act(intensity){\
	assoc_comp?.stimulate_from_rad_act(intensity)\
}


#define STIMULUS_CARBON_TOUCH (1<<1)
#define STIMULUS_SILICON_TOUCH (1<<2)
#define STIMULUS_FORCE (1<<3)
#define STIMULUS_HEAT (1<<4)
#define STIMULUS_SHOCK (1<<5)
#define STIMULUS_RADIATION (1<<6)
#define STIMULUS_DATA (1<<7)
