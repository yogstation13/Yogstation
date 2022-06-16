/obj/structure/hog_structure/fountain
	name = "Fountain"
	desc = "A fountain, containing some magical reagents in it."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 50
	cost = 175
	time_builded = 10 SECONDS
    var/max_reagents = 30
    var/reagents_amount = 0
    var/production_amount = 5
    var/production_cooldown = 35 SECONDS
    var/last_time_produced
    var/reagent_type

/obj/structure/hog_structure/fountain/Initialize()
	. = ..()
    reagents_amount = max_reagents/2
    last_time_produced = world.time
	START_PROCESSING(SSfastprocess, src)

/obj/structure/hog_structure/fountain/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
    . = ..()

/obj/structure/hog_structure/fountain/process()
    if(last_time_produced + production_cooldown < world.time && reagents_amount < max_reagents)
        reagents_amount += production_amount
        last_time_produced = world.time
        if(reagents_amount < 0)
            reagents_amount = 0
        if(reagents_amount > max_reagents)
            reagents_amount = max_reagents
        
        


