/obj/item/melee/classic_baton/psibaton
	name = "psychokinetic bash"
	desc = "A psiokenetic truncheon for beating psycho scum."
	force = 0
	stamina_damage = 10
	icon = 'icons/obj/psychic_powers.dmi'
	icon_state = "psibaton"
	item_state = "psibaton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	hitsound = 'sound/effects/psi/psisword.ogg'
	drop_sound = 'sound/effects/psi/power_fail.ogg'
	item_flags = DROPDEL
	var/maintain_cost = 3
	var/mob/living/owner

/obj/item/melee/classic_baton/psibaton/New(mob/living/L)
	owner = L
	if(!istype(owner))
		qdel(src)
		return
	START_PROCESSING(SSprocessing, src)
	..()

/obj/item/melee/classic_baton/psibaton/Destroy()
	if(istype(owner) && owner.psi)
		LAZYREMOVE(owner.psi.manifested_items, src)
		UNSETEMPTY(owner.psi.manifested_items)
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/item/melee/classic_baton/psibaton/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	SEND_SOUND(thrower, sound('sound/effects/psi/power_fail.ogg', volume = 50))
	qdel(src)

/obj/item/melee/classic_baton/psibaton/attack_self(mob/user)
	SEND_SOUND(user, sound('sound/effects/psi/power_fail.ogg', volume = 50))
	user.dropItemToGround(src)

/obj/item/melee/classic_baton/psibaton/process()
	if(istype(owner))
		if(!owner.psi.spend_power(maintain_cost))
			qdel(src)
	if(!owner || loc != owner || !(src in owner.held_items))
		if(ishuman(loc))
			var/mob/living/carbon/human/host = loc
			host.remove_embedded_object(src)
			host.dropItemToGround(src)
		else
			qdel(src)
