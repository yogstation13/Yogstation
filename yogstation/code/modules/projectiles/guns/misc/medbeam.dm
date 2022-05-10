/obj/item/gun/medbeam
    clumsy_check = FALSE

/obj/item/gun/medbeam/check_botched(mob/living/user, params) // The clown can't shoot themself in the foot with a medical device. Ever.
	return