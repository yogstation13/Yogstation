/obj/item/organ/internal/appendix/fidgetappendix
	name = "fidget spinner appendix"
	icon_state = "fidgetappendix"
	base_icon_state = "fidgetappendix"
	food_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin/bad_food = 10)
	var/spinresetter = 0

/obj/item/organ/internal/appendix/fidgetappendix/on_life(seconds_per_tick, times_fired)
	..()
	spinresetter++
	if(spinresetter == 10)
		implantspin()
		spinresetter = 0

/obj/item/organ/internal/appendix/fidgetappendix/proc/implantspin()
	src.owner.SpinAnimation(speed = 150, loops = 10)
