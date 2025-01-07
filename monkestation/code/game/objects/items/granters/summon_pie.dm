/obj/item/book/granter/action/spell/summon_pie
	name = "Mythical pies and where to find them, a compendium."
	desc = "Let them eat pie!"
	icon_state = "bookpie"
	action_name = "summon pies"
	granted_action = /datum/action/cooldown/spell/conjure/pie
	remarks = list(
		"Ooh tasty!",
		"Raspberries, rhubarb...",
		"Kiwano?",
		"Leave clumps of butter on purpose in the dough...",
		"3.1415926535897932384626433832795028841971693993751058209749445923078",
		"Promises and pie-crust are made to be broken.",
		"Time is an artificial construct...",
		"Zucchini does not belong here.",

	)

/obj/item/book/granter/action/spell/summon_pie/recoil(mob/living/user)
	to_chat(user, span_warning("\The [src] turns into a delectable pastry!"))
	var/obj/item/food/cheese/wedge/book_cheese = new
	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	user.put_in_hands(book_cheese)
	qdel(src)
