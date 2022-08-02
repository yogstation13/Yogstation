#define COMSIG_ALT_CLICK_ON "alt_click_on" 						//from base of mob/AltClickOn(): (atom/A)
#define COMSIG_ATOM_POINTED_AT "atom_pointed_at"				//from base of atom/pointed_at(): (mob/user)
#define COMSIG_PROCESS_MOVE "process_move"						//from base of client/Move(): (num/direction)
#define COMSIG_STORAGE_INSERTED "storage_inserted"				//from base of /datum/component/storage/handle_item_insertion(): (obj/item/I, mob/M)
#define COMSIG_STORAGE_REMOVED "storage_removed"				//from base of /datum/component/storage/remove_from_storage(): (atom/movable/AM, atom/new_location)

#define COMSIG_CHANGE_COMPUTE "change_flock_compute"				//used by flockmind related shit to change the amount of compute produced