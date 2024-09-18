/obj/structure/halflife/road_barrier
	name = "road barrier"
	desc = "A light and portable road barrier, used to direct traffic and stop people from going to dead ends."
	icon = 'icons/obj/halflife/barriers.dmi'
	icon_state = "road_barrier"
	density = TRUE
	max_integrity = 150
	projectile_passchance = 85
	var/hasaltstates = FALSE
	var/altstates = 0
	var/climbable = FALSE

/obj/structure/halflife/road_barrier/Initialize()
	. = ..()
	if(climbable)
		AddElement(/datum/element/climbable)
	if(!hasaltstates)
		return
	if(prob(45))
		icon_state = "[initial(icon_state)]_[rand(1,(altstates))]"

/obj/structure/halflife/road_barrier/concrete
	desc = "A heavy duty concrete road barrier, used to direct traffic and prevent going off the lane. Great to take cover behind."
	icon_state = "concrete_barrier"
	anchored = TRUE
	hasaltstates = TRUE
	climbable = TRUE
	max_integrity = 550
	altstates = 5
	projectile_passchance = 40

/obj/structure/halflife/road_barrier/concrete/alt
	desc = "A heavy duty concrete road barrier featuring a pattern that to this day is still somewhat vibrant. Used to direct traffic and prevent going off the lane."
	icon_state = "concrete_barrier_alt"
	altstates = 1
