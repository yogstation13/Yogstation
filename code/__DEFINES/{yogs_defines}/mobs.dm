#define ELECTRICITY_TO_NUTRIMENT_FACTOR 0.22 //100 power unit to 22 preternis charge, they can suck an apc dry if hungry enough and the apc isn't upgraded

#define PRETERNIS_NV_OFF 2 //numbers of tile they can see
#define PRETERNIS_NV_ON 8

#define BODYPART_ANY -1 //use this when healing with something that needs a specefied bodypart type for all

#define REGEN_BLOOD_REQUIREMENT 40 // The amount of "blood" that a slimeperson consumes when regenerating a single limb.

#define DARKSPAWN_DIM_LIGHT 0.2 //light of this intensity suppresses healing and causes very slow burn damage
#define DARKSPAWN_BRIGHT_LIGHT 0.6 //light of this intensity causes rapid burn damage (high number because movable lights are weird)
//so the problem is that movable lights ALWAYS have a luminosity of 0.5, regardless of power or distance, so even outside of the overlay they still do damage
//at 0.6 being bright they'll still do damage and disable some abilities, but it won't be weaponized

#define MONKIFY_BLOOD_COEFFICIENT (BLOOD_VOLUME_MONKEY/BLOOD_VOLUME_GENERIC) //the ratio of monkey to human blood volume so a 100% blood volume monkey will not instantly die when you turn it into a human with ~58% blood volume
