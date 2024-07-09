/obj/item/melee/classic_baton/psychic_power/psibaton
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

/obj/item/melee/classic_baton/psychic_power/psibaton/dropped(var/mob/living/user)
	..()
	playsound(loc, 'sound/effects/psi/power_fail.ogg', 30, 1)
	QDEL_IN(src, 1)
