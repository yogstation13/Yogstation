/**
 * Drops and deletes all items in the mob's inventory.
 *
 * Argument(s):
 * * Optional - include_pockets (TRUE/FALSE), whether or not to also clear items in their pockets and suit storage.
 * * Optional - include_held_items (TRUE/FALSE), whether or not to also clear any held items.
 */
/mob/living/proc/clear_inventory(include_pockets = TRUE, include_held_items = TRUE)
	var/list/items = get_equipped_items(include_pockets = include_pockets)
	if(include_held_items)
		items |= held_items
	for(var/item in items)
		dropItemToGround(item, force = TRUE, silent = TRUE, invdrop = FALSE)
		qdel(item)
