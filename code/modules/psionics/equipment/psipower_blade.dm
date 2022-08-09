/obj/item/psychic_power/psiblade
	name = "psychokinetic slash"
	force = 10
	sharpness = SHARP_EDGED
	icon_state = "psiblade_short"
	item_state = "psiblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/psisword.ogg'
	var/can_break_wall = FALSE
	var/wall_break_time = 6 SECONDS

/obj/item/psychic_power/psiblade/dropped(var/mob/living/user)
	..()
	playsound(loc, 'sound/effects/psi/power_fail.ogg', 30, 1)
	QDEL_IN(src, 1)
