/// job subsystem has spawned and equipped a new mob
#define COMSIG_GLOB_JOB_AFTER_SPAWN "!job_after_spawn"

///Subsystem signals
///From base of datum/controller/subsystem/Initialize: (start_timeofday)
#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

///Called when an object is grilled ontop of a griddle
#define COMSIG_ITEM_GRILLED "item_griddled"
#define COMPONENT_HANDLED_GRILLING (1<<0)
///Called when an object is turned into another item through grilling ontop of a griddle
#define COMSIG_GRILL_COMPLETED "item_grill_completed"
//Called when an object is in an oven
#define COMSIG_ITEM_BAKED "item_baked"
#define COMPONENT_HANDLED_BAKING (1<<0)
#define COMPONENT_BAKING_GOOD_RESULT (1<<1)
#define COMPONENT_BAKING_BAD_RESULT (1<<2)
///Called when an object is turned into another item through baking in an oven
#define COMSIG_BAKE_COMPLETED "item_bake_completed"
