/obj/structure/test_boulder_spawner
	name = "DEBUG BOULDER SPAWNER"
	desc = "... Why? How?"

	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "unloader-corner"

	var/spawn_dir = EAST

	var/processing = FALSE

/obj/structure/test_boulder_spawner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!processing)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/structure/test_boulder_spawner/process(seconds_per_tick)
	var/atom/movable/new_item = new /obj/item/boulder/gulag_expanded(get_turf(src))
	new_item.forceMove(get_step(src, spawn_dir))
