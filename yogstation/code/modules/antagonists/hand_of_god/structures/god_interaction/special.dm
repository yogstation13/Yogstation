//////////////////////////////////
/*
	Special interactions - This are specific actions unique to certain buildings.
*/
//////////////////////////////////

/datum/hog_god_interaction/structure/fountain
	name = "Refill"
	description = "Refills the fountain with new godblood, through you can't refill it with more than 15u by one cast."
	cost = 70
	cooldown = 35 SECONDS

/datum/hog_god_interaction/structure/fountain/on_called(var/mob/camera/hog_god/user)
    if(!istype(owner, /obj/structure/destructible/hog_structure/fountain))
        to_chat(user,span_danger("Not a valid target!"))
        return
    var//obj/structure/destructible/hog_structure/fountain/fountain = owner 
    description = initial(description)
    description = "[description] Currently, this [fountain] has [fountain.reagents_amount]u of godblood."
	. = ..()