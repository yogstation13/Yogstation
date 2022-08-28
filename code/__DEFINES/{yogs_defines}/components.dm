#define COMSIG_ALT_CLICK_ON "alt_click_on" 						//from base of mob/AltClickOn(): (atom/A)
#define COMSIG_ATOM_POINTED_AT "atom_pointed_at"				//from base of atom/pointed_at(): (mob/user)
#define COMSIG_PROCESS_MOVE "process_move"						//from base of client/Move(): (num/direction)
#define COMSIG_STORAGE_INSERTED "storage_inserted"				//from base of /datum/component/storage/handle_item_insertion(): (obj/item/I, mob/M)
#define COMSIG_STORAGE_REMOVED "storage_removed"				//from base of /datum/component/storage/remove_from_storage(): (atom/movable/AM, atom/new_location)

//FISHING COMSIGS
#define COMSIG_FISHING_INTERRUPT "fishing_interrupt"			//from base of /datum/component/fishable/interrupt
#define COMSIG_CHUM_ATTEMPT "chum_attempt"
#define COMSIG_FISH_FINDER_EXAMINE "fish_finder_examine"
