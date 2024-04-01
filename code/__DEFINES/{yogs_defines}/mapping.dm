/** Defines for the Dungeon Generator.
 * These bitflags control which elements are present in each room theme so the parent room of the theme knows which furnishing procs it needs to call
 */
///If the room has specific floor tiles
#define ROOM_HAS_FLOORS 			(1<<0)
///If the room has specific wall tiles
#define ROOM_HAS_WALLS 				(1<<1)
///If the room has windows and specific window type
#define ROOM_HAS_WINDOWS 			(1<<2)
///If the room has windows and specific window type, but no walls to spawn, so this room should just be a glass box
#define ROOM_HAS_ONLY_WINDOWS 		(1<<3)
///If the room has specific door type
#define ROOM_HAS_DOORS 				(1<<4)
///If we want the room shape, but then the room to do something very specific. This is how I handle ruin spawning
#define ROOM_HAS_SPECIAL_FEATURES 	(1<<5)
///If the room has specific decorative features like blood splatters or loot spawners
#define ROOM_HAS_FEATURES 			(1<<6)
///If the room has mobs to spawn, whether they're hostile spiders or harmless rats
#define ROOM_HAS_MOBS 				(1<<7)

//The danger the room presents ranging from always safe to you should die NOW
#define ROOM_RATING_SAFE 					(1<<0)
#define ROOM_RATING_HOSTILE 				(1<<1)
#define ROOM_RATING_EXTREMELY_HOSTILE 		(1<<2)
#define ROOM_RATING_DEATH 					(1<<3)

//For categorizing rooms 
#define ROOM_TYPE_RANDOM 			"random"
#define ROOM_TYPE_SPACE 			"space"
#define ROOM_TYPE_RUIN 				"ruin"
#define ROOM_TYPE_SECRET 			"secret"

#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define ALGORITHM_BSP "Binary Search Partition"
#define ALGORITHM_RRP "Random Room Placement"
