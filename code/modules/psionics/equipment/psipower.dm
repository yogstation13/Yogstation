/obj/item/psychic_power
	name = "psychic power"
	icon = 'icons/obj/psychic_powers.dmi'
	anchored = TRUE
	var/maintain_cost = 3
	var/mob/living/owner
	item_flags = DROPDEL

/obj/item/psychic_power/New(mob/living/L)
	owner = L
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/psychic_power/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/psychic_power/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	SEND_SOUND(thrower, sound('sound/effects/psi/power_fail.ogg', volume = 50))
	qdel(src)

/obj/item/psychic_power/attack_self(mob/user)
	SEND_SOUND(user, sound('sound/effects/psi/power_fail.ogg', volume = 50))
	user.dropItemToGround(src)

/obj/item/psychic_power/process()
	if(istype(owner))
		owner.psi.spend_power(maintain_cost)
	if(!owner || loc != owner || !(src in owner.held_items))
		if(ishuman(loc))
			var/mob/living/carbon/human/host = loc
			host.remove_embedded_object(src)
			host.dropItemToGround(src)
		else
			qdel(src)
