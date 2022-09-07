/obj/structure/sign/plaques/cave
	name = "Cave Johnson portrait"
	desc = "Hey! You're not supposed to see this!"
	icon = 'yogstation/icons/obj/decals.dmi'
	icon_state = "cave"

/obj/structure/sign/plaques/cave/Initialize()
	. = ..()
	desc = pick("Greetings, friend. I'm Cave Johnson, CEO of Nanotrasen Science - you might know us as a vital participant in the 2548 Board Hearings on missing crewmembers. And you've most likely used one of the many products we invented. But that other people have somehow managed to steal from us.", "So. Welcome to Nanotrasen. You're here because we want the best, and you're it. Nope. Couldn't keep a straight face.", "All right, I've been thinking. When life gives you lemons? Don't make lemonade. Make life take the lemons back! Get mad! 'I don't want your damn lemons! What am I supposed to do with these?", "Brain Mapping. Artificial Intelligence. We should have been working on it thirty years ago.", "Science isn't about WHY. It's about WHY NOT. Why is so much of our science dangerous? Why not marry safe science if you love it so much. In fact, why not invent a special safety door that won't hit you on the butt on the way out, because you are fired!", "The bean counters told me we literally could not afford to buy seven dollars worth of plasma rocks, much less seventy million. Bought 'em anyway. Engineers said the plasma rocks were too volatile to experiment on. Tested on 'em anyway. Ground 'em up, mixed em into a gel. And guess what? Ground up plasma rocks are pure poison. I am ly ill. Still, it turns out they're a great fire hazard. We're done here.")
