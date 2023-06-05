#define CHANGETURF_DEFER_CHANGE (1<<0)
#define CHANGETURF_IGNORE_AIR (1<<1) // This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_FORCEOP (1<<2)
#define CHANGETURF_SKIP (1<<3) // A flag for PlaceOnTop to just instance the new turf instead of calling ChangeTurf. Used for uninitialized turfs NOTHING ELSE
#define CHANGETURF_INHERIT_AIR (1<<4) // Inherit air from previous turf. Implies CHANGETURF_IGNORE_AIR
#define CHANGETURF_RECALC_ADJACENT (1<<5) //Immediately recalc adjacent atmos turfs instead of queuing.
#define CHANGETURF_TRAPDOOR_INDUCED (1<<6) // Caused by a trapdoor, for trapdoor to know that this changeturf was caused by itself

///Returns all currently loaded turfs
#define ALL_TURFS(...) block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
