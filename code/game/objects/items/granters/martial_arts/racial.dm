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

/obj/item/book/granter/martial/liquidator
	martial = /datum/martial_art/liquidator
	name = "strange electronic board"
	martial_name = "Remnant Liquidator"
	desc = "A strange electronic board, containing some sort of software."
	greet = "<span class='sciradio'>You have uploaded covert combat tactics to your data banks. Your in-built combat tools have been enabled without authorization. \
	You have become proficient in disposing malcontents without so much as a commotion. \
	You can check what combos you have, and their effect by using Refresh Data verb in the Remnant Liquidator tab.</span>"
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	remarks = list("Processing data...")

/obj/item/book/granter/martial/liquidator/can_learn(mob/user)
	if(!ispreternis(user))
		to_chat(user, span_warning("You don't understand what to do with this strange electronic device."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/liquidator/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It looks like the board has been damaged to erase the data."

/obj/item/book/granter/martial/garden_warfare
	martial = /datum/martial_art/gardern_warfare
	name = "vegetable parchment"
	martial_name = "Garden Warfare"
	desc = "A scroll, filled with a ton of text. Looks like it says something about combat and... plants?"
	greet = "<span class='sciradio'>You know the martial art of Garden Warfare! Now you control your body better, then other phytosians do, allowing you to extend vines from your body and impale people with splinters. \
	You can check what combos can you do, and their effect by using Remember the basics verb in Garden Warfare tab.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("I didn't know that my body grows sprinklers...", "I am able to snatch people with vines? Interesting.", "Wow, strangling people is brutal.")   ///Kill me please for this cringe // I hate you

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
	name = "version one upgrade module"
	martial_name = "Ultra Violence"
	desc = "A module full of forbidden techniques from a horrific event long since passed, or perhaps yet to come."
	greet = span_sciradio("You have installed Ultra Violence! You are able to redirect electromagnetic pulses with throwmode, \
		blood heals you, and you CANNOT BE STOPPED. You can mentally practice by using Cyber Grind in the Ultra Violence tab.")
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	remarks = list("MANKIND IS DEAD.", "BLOOD IS FUEL.", "HELL IS FULL.")

/obj/item/book/granter/martial/ultra_violence/on_reading_start(mob/user)
	to_chat(user, span_notice("You plug \the [src] in and begin loading PRG$[martial_name]."))

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

/obj/item/book/granter/martial/worldbreaker/on_reading_start(mob/user)
	to_chat(user, span_notice("You raise \the [src] to your lips and take a sip..."))

/obj/item/book/granter/martial/worldbreaker/can_learn(mob/user)
	if(!ispreternis(user))
		to_chat(user, span_warning("There is no way in hell I'm drinking this."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/worldbreaker/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		var/obj/item/reagent_containers/glass/bottle/vial/empty = new(get_turf(user))
		qdel(src)
		user.put_in_active_hand(empty)

/obj/item/book/granter/martial/lightning_flow
	name = "glowing parchment"
	desc = "A scroll made of unusual paper, written for ethereals looking to defend themselves while exploring the material world."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	martial = /datum/martial_art/lightning_flow
	martial_name = "Lightning Flow"
	greet = span_sciradio("You have learned lightning flow. Weave through your enemies like a bolt of lightning.\
		Use Focus in the Lightning Flow tab to remember the moves.")
	remarks = list(
		"I can't quite make out the signature.", 
		"Hold on, it's just that easy?", 
		"Why am I feeling nostalgia?", 
		"The paper feels weirdly... tense?",
		"I had no clue this was possible here."
	)

/obj/item/book/granter/martial/lightning_flow/can_learn(mob/user)
	if(!isethereal(user))
		if(user.get_selected_language())
			to_chat(user, span_warning("This language looks nothing like [user.get_selected_language()]."))
		else
			to_chat(user, span_warning("I can't understand a word of this."))
		return FALSE
	return ..()

/obj/item/book/granter/martial/lightning_flow/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		desc = "It's completely blank."

/obj/item/book/granter/action/wirecrawl
	name = "modified yellow slime extract"
	desc = "An experimental yellow slime extract that when absorbed by an Ethereal, grants control over electrical powers."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	granted_action = /datum/action/cooldown/spell/jaunt/wirecrawl
	action_name = "Wirecrawling"
	drop_sound = null
	pickup_sound = null
	remarks = list("Shock...", "Zap...", "High Voltage...", "Dissolve...", "Dissipate...", "Disperse...", "Red Hot...", "Spiral...", "Electro-magnetic...", "Turbo...")
	book_sounds = list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg')
	var/admin = FALSE

/obj/item/book/granter/action/wirecrawl/on_reading_start(mob/user)
	to_chat(user, span_notice("You hold \the [src] directly to your chest..."))

/obj/item/book/granter/action/wirecrawl/can_learn(mob/user)
	if(isethereal(user) || admin)
		return ..()
	to_chat(user, span_warning("Yup, that's a slime extract alright."))
	return FALSE

/obj/item/book/granter/action/wirecrawl/on_reading_finished(mob/living/carbon/user)
	..()
	if(!uses)
		name = "grey slime extract"
		desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
		icon_state = "grey slime extract"

/obj/item/book/granter/action/wirecrawl/admin //if someone wants to spawn it in
	admin = TRUE
