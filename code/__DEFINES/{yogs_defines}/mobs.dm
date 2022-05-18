#define PRETERNIS_LEVEL_FULL 550
#define PRETERNIS_LEVEL_WELL_FED 450
#define PRETERNIS_LEVEL_FED 350
#define PRETERNIS_LEVEL_HUNGRY 250
#define PRETERNIS_LEVEL_STARVING 150
#define PRETERNIS_LEVEL_NONE 0

#define ELECTRICITY_TO_NUTRIMENT_FACTOR 0.44 //1 power unit to 44 preternis charge they can uncharge an apc to 50% at most

#define PRETERNIS_NV_OFF 2 //numbers of tile they can see
#define PRETERNIS_NV_ON 8

#define BODYPART_ANY -1 //use this when healing with something that needs a specefied bodypart type for all

#define REGEN_BLOOD_REQUIREMENT 40 // The amount of "blood" that a slimeperson consumes when regenerating a single limb.

#define DARKSPAWN_DIM_LIGHT 0.2 //light of this intensity suppresses healing and causes very slow burn damage
#define DARKSPAWN_BRIGHT_LIGHT 0.3 //light of this intensity causes rapid burn damage

 #define DARKSPAWN_DARK_HEAL 5 //how much damage of each type (with fire damage half rate) is healed in the dark
#define DARKSPAWN_LIGHT_BURN 7 //how much damage the darkspawn receives per tick in lit areas

#define MONKIFY_BLOOD_COEFFICIENT (BLOOD_VOLUME_MONKEY/BLOOD_VOLUME_GENERIC) //the ratio of monkey to human blood volume so a 100% blood volume monkey will not instantly die when you turn it into a human with ~58% blood volume
