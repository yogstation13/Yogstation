/obj/structure/destructible/clockwork/anchor
	name = "Anchor"
	desc = "" //A aaaaaaaaaaaaaa
	clockwork_desc = "Abscond next to this or hit it with your slab to warp back to Reebe."
	icon_state = "mania_motor"
	break_message = "<span class='warning'>The antenna break off, leaving a pile of shards!</span>"
	max_integrity = 100
	light_color = "#AF0AAF"

	var/datum/mind/owner

/obj/structure/destructible/clockwork/anchor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/slab) && is_servant_of_ratvar(user))
		if(owner != user.mind)
			to_chat(user, "<span class='danger'>You need to use your own anchor.</span>") // Remind me to make a pointer to their anchor
			return FALSE
		var/obj/item/clockwork/slab/s = I
		return s.recite_scripture(/datum/clockwork_scripture/abscond, user)
	return ..()

/obj/structure/destructible/clockwork/anchor/proc/disable() // Called when our owner is deconverted
	animate(src, alpha = 0, 50)
	QDEL_IN(src, 50)
	for(var/mob/m in view(7, src))
		if(is_servant_of_ratvar(m))
			to_chat(m, "<span class='notice'>The anchor fades out of existence, as its connection to its owner has been severed.</span>")
		else
			to_chat(m, "<span class='notice'>The anchor fades out of existence.</span>")

/obj/structure/destructible/clockwork/anchor/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living) && is_servant_of_ratvar(mover))
		return TRUE
	return ..()
