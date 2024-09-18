#define ELECTRICITY_TO_NUTRIMENT_FACTOR 0.22 //100 power unit to 22 preternis charge, they can suck an apc dry if hungry enough and the apc isn't upgraded

#define PRETERNIS_NV_OFF 2 //numbers of tile they can see
#define PRETERNIS_NV_ON 8

#define BODYPART_ANY -1 //use this when healing with something that needs a specefied bodypart type for all

#define REGEN_BLOOD_REQUIREMENT 40 // The amount of "blood" that a slimeperson consumes when regenerating a single limb.

#define MONKIFY_BLOOD_COEFFICIENT (BLOOD_VOLUME_MONKEY/BLOOD_VOLUME_GENERIC) //the ratio of monkey to human blood volume so a 100% blood volume monkey will not instantly die when you turn it into a human with ~58% blood volume

#define SPECIES_DARKSPAWN "darkspawn"
#define SPECIES_IPC "ipc"
#define SPECIES_POLYSMORPH "polysmorph"
#define SPECIES_PRETERNIS "preternis"
#define SPECIES_VOX "vox"

#define BUTT_SPRITE_VOX "vox"


GLOBAL_REAL_VAR(list/voice_type2sound = list(
	"1" = list(
		"1" = sound('goon/sound/speak_1.ogg'),
		"!" = sound('goon/sound/speak_1_exclaim.ogg'),
		"?" = sound('goon/sound/speak_1_ask.ogg')
	),
	"2" = list(
		"2" = sound('goon/sound/speak_2.ogg'),
		"!" = sound('goon/sound/speak_2_exclaim.ogg'),
		"?" = sound('goon/sound/speak_2_ask.ogg')
	),
	"3" = list(
		"3" = sound('goon/sound/speak_3.ogg'),
		"!" = sound('goon/sound/speak_3_exclaim.ogg'),
		"?" = sound('goon/sound/speak_3_ask.ogg')
	),
	"4" = list(
		"4" = sound('goon/sound/speak_4.ogg'),
		"!" = sound('goon/sound/speak_4_exclaim.ogg'),
		"?" = sound('goon/sound/speak_4_ask.ogg')
	),
))
