/obj/item/book/granter/martial/flyingfang
	martial = /datum/martial_art/flyingfang
	name = "strange tablet"
	martial_name = "Flying Fang"
	desc = "A tablet with strange pictograms that appear to detail some kind of fighting technique."
	force = 10
	greet = "<span class='sciradio'>You have learned the ancient martial art of Flying Fang! Your unarmed attacks have become somewhat more effective,  \
	and you are more resistant to damage and stun-based weaponry. However, you are also unable to use any ranged weaponry or armor. You can learn more about your newfound art by using the Recall Teachings verb in the Flying Fang tab.</span>"
	icon = 'icons/obj/library.dmi'
	icon_state = "stone_tablet"
	remarks = list("Feasting on the insides of your enemies...", "Some of these techniques look a bit dizzying...", "Not like I need armor anyways...", "Don't get shot, whatever that means...")

/obj/item/book/granter/martial/flyingfang/can_learn(mob/user)
	if(!islizard(user))
		to_chat(user, span_warning("You can't tell if this is some poorly written fanfiction or an actual guide to something."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/flyingfang/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It's completely blank."
		name = "blank tablet"
		icon_state = "stone_tablet_blank"

/obj/item/book/granter/martial/preternis_stealth
	martial = /datum/martial_art/stealth
	name = "strange electronic board"
	martial_name = "Stealth"
	desc = "A strange electronic board, containing some sort of software."
	greet = "<span class='sciradio'>You have uploaded some combat modules into yourself. Your combos will now have special effects on your enemies, and mostly are not obvious to other people. \
	You can check what combos can you do, and their effect by using Refresh Data verb in Combat Modules tab.</span>"
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	remarks = list("Processing data...")

/obj/item/book/granter/martial/preternis_stealth/can_learn(mob/user)
	if(!ispreternis(user))
		to_chat(user, span_warning("You don't understand what to do with this strange electronic device."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/preternis_stealth/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It looks like it doesn't contain any data no more."

/obj/item/book/granter/martial/garden_warfare
	martial = /datum/martial_art/gardern_warfare
	name = "mysterious scroll"
	martial_name = "Garden Warfare"
	desc = "A scroll, filled with a tone of text. Looks like it says something about combat and... plants?"
	greet = "<span class='sciradio'>You know the martial art of Garden Warfare! Now you control your body better, then other phytosians do, allowing you to extend vines from your body and impale people with splinters. \
	You can check what combos can you do, and their effect by using Remember the basics verb in Garden Warfare tab.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("I didn't know that my body grows sprinklers...", "I am able to snatch people with vines? Interesting.", "Wow, strangling people is brutal.")   ///Kill me please for this cringe

/obj/item/book/granter/martial/garden_warfare/can_learn(mob/user)
	if(!ispodperson(user))
		to_chat(user, span_warning("You see that this scroll says something about natural abilitites of podpeople, but, unfortunately, you are not one of them."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/garden_warfare/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It's completely blank."

/obj/item/book/granter/martial/explosive_fist
	martial = /datum/martial_art/explosive_fist
	name = "burnt scroll"
	martial_name = "Explosive Fist"
	desc = "A burnt scroll, that glorifies plasmamen, and also says a lot things of explosions."
	greet = "<span class='sciradio'>You know the martial art of Explosive Fist. Now your attacks deal brute and burn damage, while your combos are able to set people on fire, explode them, or all at once. \
	You can check what combos can you do, and their effect by using Remember the basics verb in Explosive Fist tab.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("Set them on fire...", "Show the punny humans who is here the supreme race...", "Make them burn...", "Explosion are cool!")

/obj/item/book/granter/martial/explosive_fist/can_learn(mob/living/user)
	if(!isplasmaman(user))
		to_chat(user, span_warning("You burn your hand slightly on the scroll, better not to mess with it."))
		user.apply_damage(5, BURN, rand(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		return FALSE
	return ..()

/obj/item/book/granter/martial/explosive_fist/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It's completely blank."

/obj/item/book/granter/martial/ultra_violence
	martial = /datum/martial_art/ultra_violence
	name = "Version one upgrade module"
	martial_name = "Ultra Violence"
	desc = "A module full of forbidden techniques from a horrific event long since passed, or perhaps yet to come."
	greet = span_sciradio("You have installed how to perform Ultra Violence! You are able to redirect electromagnetic pulses, \
		blood heals you, and you CANNOT BE STOPPED. You can mentally practice by using Cyber Grind in the Ultra Violence tab.")
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	remarks = list("MANKIND IS DEAD.", "BLOOD IS FUEL.", "HELL IS FULL.")

/obj/item/book/granter/martial/ultra_violence/can_learn(mob/user)
	if(!isipc(user))
		to_chat(user, span_warning("A nice looking piece of scrap, would make a fine trade offer."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/ultra_violence/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It's a damaged upgrade module."
		name = "damaged board"

// I did not include mushpunch's grant, it is not a book and the item does it just fine.

/obj/item/book/granter/martial/worldbreaker
	martial = /datum/martial_art/worldbreaker
	name = "prototype worldbreaker compound"
	martial_name = "Worldbreaker"
	desc = "A foul concoction made by reverse engineering chemicals compounds found in an ancient Vxtrin military outpost."
	greet = span_sciradio("You feel weirdly good, good enough to shake the world to it's very core. \
	Your plates feel like they are growing past their normal limits. The protection will come in handy, but it will eventually slow you down.\
	You can think about all the things you are now capable of by using the Worldbreaker tab.")
	icon = 'icons/obj/drinks.dmi'
	icon_state = "flaming_moe"
	remarks = list(
		"Is... it bubbling?", 
		"What's that gross residue on the sides of the vial?", 
		"Am I really considering drinking this?", 
		"I'm pretty sure I just saw a dead fly dissolve in it.", 
		"This is temporary, right?", 
		"I sure hope someone's tested this.")
	book_sounds = list('sound/items/drink.ogg') //it's a drink, not a book

/obj/item/book/granter/martial/worldbreaker/can_learn(mob/user)
	if(!ispreternis(user))
		to_chat(user, span_warning("There is no way in hell i'm drinking this."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/worldbreaker/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		var/obj/item/reagent_containers/glass/bottle/vial/empty = new(get_turf(user))
		qdel(src)
		user.put_in_active_hand(empty)
