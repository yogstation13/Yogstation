/obj/item/mutant_hand/zombie
	///can we infect living people or not
	var/highly_infecious = TRUE

/obj/item/mutant_hand/zombie/low_infection
	highly_infecious = FALSE

/obj/item/mutant_hand/zombie/low_infection/weak
	force = 17
