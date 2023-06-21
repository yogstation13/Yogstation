/obj/effect/spawner/trap
	name = "random trap"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap_rand"

/obj/effect/spawner/trap/Initialize(mapload)
	..()
	var/new_type = pick(subtypesof(/obj/structure/trap) - typesof(/obj/structure/trap/ctf))
	new new_type(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/wire_splicing
	name = "wiring splicing spawner"
	icon = 'icons/obj/structures_spawners.dmi'
	icon_state = "wire_splicing"

/obj/effect/spawner/wire_splicing/Initialize(mapload)
	. = ..()
	new/obj/structure/wire_splicing(get_turf(src))
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/wire_splicing/thirty //70% chance to be nothing
	name = "wiring splicing spawner 30%"

/obj/effect/spawner/wire_splicing/thirty/Initialize(mapload)
	if (prob(70)) 
		return INITIALIZE_HINT_QDEL
	. = ..()
	