/atom
	var/image/demo_last_appearance

/atom/Destroy(force)
	demo_last_appearance = null
	return ..()

/atom/movable
	var/atom/demo_last_loc

/atom/movable/Destroy(force)
	demo_last_loc = null
	return ..()

/client/New()
	SSdemo.write_event_line("login [ckey]")
	return ..()

/client/Destroy()
	. = ..()
	SSdemo.write_event_line("logout [ckey]")

/turf/setDir()
	. = ..()
	SSdemo.marked_turfs?[src] = TRUE

/atom/movable/setDir()
	. = ..()
	SSdemo.mark_dirty(src)

/mob/dview
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/mob/oranges_ear
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/mob/living/carbon/human/dummy
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/spawner
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/turf_decal
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/mapping_helpers
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/abstract/name_tag
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/abstract/marker
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/abstract/info
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1

/obj/effect/abstract/chasm_storage
	flags_1 = parent_type::flags_1 | DEMO_IGNORE_1
