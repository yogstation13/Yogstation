/mob/living/simple_animal/hostile/retaliate/goat/clown
	name = "Gary the Goat"
	desc = "Rather kick your butt then tell jokes."
	icon = 'yogstation/icons/mob/clownpets.dmi'
	icon_state = "clown_goat"
	icon_living = "clown_goat"
	icon_dead = "clown_goat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/clothing/mask/gas/clown_hat = 1)

/mob/living/simple_animal/hostile/retaliate/goat/ras
	name = "Ralsei Goat"
	desc = "It just wants to give you a hug!"
	icon = 'yogstation/icons/mob/goats/ras_goat.dmi'
	icon_state = "rasgoat"
	icon_living = "rasgoat"
	icon_dead = "rasgoat_dead"
	attacktext = "''hugs''"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/toy/plush/goatplushie/angry = 1)

/mob/living/simple_animal/hostile/retaliate/goat/blue
	name = "Blue Goat"
	desc = "Im blue da da di da da bahhhh."
	icon = 'yogstation/icons/mob/goats/blue_goat.dmi'
	icon_state = "bluegoat"
	icon_living = "bluegoat"
	icon_dead = "bluegoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/chocolate
	name = "Chocolate Goat"
	desc = "Actually just a goat with dark brown fur but I can see why you would think its made of chocolate though."
	icon = 'yogstation/icons/mob/goats/chocolate_goat.dmi'
	icon_state = "chocolategoat"
	icon_living = "chocolategoat"
	icon_dead = "chocolategoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/christmas
	name = "Christmas Goat"
	desc = "Even goats can enjoy christimas!"
	icon = 'yogstation/icons/mob/goats/christmas_goat.dmi'
	icon_state = "christmasgoat"
	icon_living = "christmasgoat"
	icon_dead = "christmasgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/confetti
	name = "Confetti Goat"
	desc = "Someone has been partying a bit too hard I see."
	icon = 'yogstation/icons/mob/goats/confetti_goat.dmi'
	icon_state = "confettigoat"
	icon_living = "confettigoat"
	icon_dead = "confettigoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/cottoncandy
	name = "Cottoncandy Goat"
	desc = "Unlike the Chocolate Goat this goat is made of real cottoncandy."
	icon = 'yogstation/icons/mob/goats/cottoncandy_goat.dmi'
	icon_state = "cottoncandygoat"
	icon_living = "cottoncandygoat"
	icon_dead = "cottoncandygoat_dead"
	gold_core_spawnable = NO_SPAWN
	response_harm = "takes a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/candy = 3)

/mob/living/simple_animal/hostile/retaliate/goat/cottoncandy/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-8) //Fast life regen

/mob/living/simple_animal/hostile/retaliate/goat/cottoncandy/attack_hand(mob/living/L)
	..()
	if(L.a_intent == INTENT_HARM && L.reagents && !stat)
		L.reagents.add_reagent("nutriment", 0.4)
		L.reagents.add_reagent("vitamin", 0.4)

/mob/living/simple_animal/hostile/retaliate/goat/glowing
	name = "Glowing Goat"
	desc = "It seems this goat is glowing for some reason."
	icon = 'yogstation/icons/mob/goats/glowing_goat.dmi'
	icon_state = "glowinggoat"
	icon_living = "glowinggoat"
	icon_dead = "glowinggoat_dead"
	gold_core_spawnable = NO_SPAWN
	light_power = 5
	light_range = 4

/mob/living/simple_animal/hostile/retaliate/goat/goatgoat
	name = "Goat Goat Goat"
	desc = "What the hell is that?"
	icon = 'yogstation/icons/mob/goats/goatgoat_goat.dmi'
	icon_state = "goatgoat"
	icon_living = "goatgoat"
	icon_dead = "goatgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/horror
	name = "Horror Goat"
	desc = "WHAT THE HELL IS THAT!"
	icon = 'yogstation/icons/mob/goats/horror_goat.dmi'
	icon_state = "horrorgoat"
	icon_living = "horrorgoat"
	icon_dead = "horrorgoat_dead"
	gold_core_spawnable = NO_SPAWN
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attacktext = "lacerates"

/mob/living/simple_animal/hostile/retaliate/goat/inverted
	name = "Inverted Goat"
	desc = "This goat seems to be from the 4th Dimension."
	icon = 'yogstation/icons/mob/goats/inverted_goat.dmi'
	icon_state = "invertedgoat"
	icon_living = "invertedgoat"
	icon_dead = "invertedgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/memory
	name = "Goat of your Past"
	desc = "It feels like you seen this goat before but you cant place where..."
	icon = 'yogstation/icons/mob/goats/memory_goat.dmi'
	icon_state = "memorygoat"
	icon_living = "memorygoat"
	icon_dead = "memorygoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/mirrored
	name = "taoG derorriM"
	desc = ".noitisopsid tnasaelp rieht rof nwonk toN"
	icon = 'yogstation/icons/mob/goats/mirrored_goat.dmi'
	icon_state = "mirroredgoat"
	icon_living = "mirroredgoat"
	icon_dead = "mirroredgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/paper
	name = "Paper Goat"
	desc = "Careful not to get a papercut!"
	icon = 'yogstation/icons/mob/goats/paper_goat.dmi'
	icon_state = "papergoat"
	icon_living = "papergoat"
	icon_dead = "papergoat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/paper = 3)

/mob/living/simple_animal/hostile/retaliate/goat/pixel
	name = "Pixel Goat"
	desc = "How pixelated can we get?!?"
	icon = 'yogstation/icons/mob/goats/pixel_goat.dmi'
	icon_state = "pixelgoat"
	icon_living = "pixelgoat"
	icon_dead = "pixelgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/radioactive
	name = "Radioactive Goat"
	desc = "I would not get near this goat if I were you"
	icon = 'yogstation/icons/mob/goats/radioactive_goat.dmi'
	icon_state = "radioactivegoat"
	icon_living = "radioactivegoat"
	icon_dead = "radioactivegoat_dead"
	gold_core_spawnable = NO_SPAWN
	light_power = 5
	light_range = 4
	light_color = LIGHT_COLOR_GREEN

/mob/living/simple_animal/hostile/retaliate/goat/radioactive/Life()
	radiation_pulse(src, 200) // It gets stronker as time passes

/mob/living/simple_animal/hostile/retaliate/goat/rainbow
	name = "Rainbow Goat"
	desc = "WHAT DOES IT MEANNNNNNN!"
	icon = 'yogstation/icons/mob/goats/rainbow_goat.dmi'
	icon_state = "rainbowgoat"
	icon_living = "rainbowgoat"
	icon_dead = "rainbowgoat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/storage/crayons = 1)

/mob/living/simple_animal/hostile/retaliate/goat/spiffles
	name = "Spiffles"
	desc = "Be careful he is a feisty one!"
	icon = 'yogstation/icons/mob/goats/Spiffles.dmi'
	icon_state = "spiffles"
	icon_living = "spiffles"
	icon_dead = "spiffles_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/star
	name = "Star Goat"
	desc = "It stares into your soul."
	icon = 'yogstation/icons/mob/goats/star_goat.dmi'
	icon_state = "stargoat"
	icon_living = "stargoat"
	icon_dead = "stargoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/twisted
	name = "Twisted Goat"
	desc = "Has science gone to far?"
	icon = 'yogstation/icons/mob/goats/twisted_goat.dmi'
	icon_state = "twistedgoat"
	icon_living = "twistedgoat"
	icon_dead = "twistedgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/huge
	name = "Huge Goat"
	desc = "Jesus thats a big goat."
	melee_damage_lower = 10
	melee_damage_upper = 20
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/huge/Initialize()
	transform *= 2

/mob/living/simple_animal/hostile/retaliate/goat/tiny
	name = "Tiny Goat"
	desc = "Awww what a tiny goat."
	melee_damage_lower = 1
	melee_damage_upper = 1
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/tiny/Initialize()
	transform *= 0.5

/mob/living/simple_animal/hostile/retaliate/goat/ghost
	name = "Ghost Goat"
	desc = "Just cause he is a ghost does not mean he cant still kick butt."
	gold_core_spawnable = NO_SPAWN
	color = "#FFFFFF77"
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	butcher_results = list(/obj/item/ectoplasm = 1)

/mob/living/simple_animal/hostile/retaliate/goat/brick
	name = "Brick Goat"
	desc = "I would avoid getting hit by this goat if I were you"
	icon = 'yogstation/icons/mob/goats/brick_goat.dmi'
	icon_state = "brickgoat"
	icon_living = "brickgoat"
	icon_dead = "brickgoat_dead"
	health = 200
	maxHealth = 200
	gold_core_spawnable = NO_SPAWN
	melee_damage_lower = 50
	melee_damage_upper = 60

/mob/living/simple_animal/hostile/retaliate/goat/watercolor
	name = "Watercolor Goat"
	desc = "Its so pretty!"
	icon = 'yogstation/icons/mob/goats/watercolor_goat.dmi'
	icon_state = "watercolorgoat"
	icon_living = "watercolorgoat"
	icon_dead = "watercolorgoat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/paint/anycolor = 1)