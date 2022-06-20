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

/datum/hog_god_interaction/structure/fountain/on_called(mob/camera/hog_god/user)
    if(!istype(owner, /obj/structure/destructible/hog_structure/fountain))
        to_chat(user,span_danger("Not a valid target!"))
        return
    var/obj/structure/destructible/hog_structure/fountain/fountain = owner 
    description = initial(description)
    description = "[description] Currently, this [fountain] has [fountain.reagents_amount]u of godblood."
	. = ..()

#define MAX_REFILL_AMOUNT 15

/datum/hog_god_interaction/structure/fountain/on_use(mob/camera/hog_god/user) ///Calling this proc is made in attack_god()
    if(!istype(owner, /obj/structure/destructible/hog_structure/fountain))
        to_chat(user,span_danger("Not a valid target!"))
        return
    var/obj/structure/destructible/hog_structure/fountain/fountain = owner     
    var/amount = min(MAX_REFILL_AMOUNT, (fountain.max_reagents - fountain.reagents_amount))
    if(!amount)
        to_chat(user,span_danger("You can't refill the [fountain]!"))
        return
    fountain.change_reagents(amount)
    to_chat(user,span_danger("You refill the fountain with [amount] amount of godblood."))
	. = ..()

#undef MAX_REFILL_AMOUNT

/datum/hog_god_interaction/structure/mass_recall
	name = "Mass recall"
	description = "Recalls all of your living servants to your nexus. Note, that using this ability requires mass recall charges, and normally you have only one!"
	cost = 250
	cooldown = 2 MINUTES

/datum/hog_god_interaction/structure/mass_recall/on_use(mob/camera/hog_god/user)
    if(!user.cult.recalls)
		to_chat(user,span_danger("You don't have any mass recalls left!"))
		return
    if(!cult.nexus)
		to_chat(user,span_danger("You don't have any nexus to recall to!"))
		return
    if(!user.mass_recall)
        return
	. = ..()