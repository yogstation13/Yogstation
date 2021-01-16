/mob/living/simple_animal/hostile/retaliate/goat/clown
	name = "Gary the Goat"
	desc = "Rather kick your butt than tell jokes."
	icon = 'yogstation/icons/mob/goats/clown_goat.dmi'
	icon_state = "clowngoat"
	icon_living = "clowngoat"
	icon_dead = "clowngoat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/clothing/mask/gas/clown_hat = 1, /obj/item/clothing/head/yogs/goatpelt = 1)

/mob/living/simple_animal/hostile/retaliate/goat/ras
	name = "Ralsei Goat"
	desc = "It just wants to give you a hug!"
	icon = 'yogstation/icons/mob/goats/ras_goat.dmi'
	icon_state = "rasgoat"
	icon_living = "rasgoat"
	icon_dead = "rasgoat_dead"
	attacktext = "''hugs''"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/toy/plush/goatplushie/angry = 1, /obj/item/clothing/head/yogs/goatpelt = 1)

/mob/living/simple_animal/hostile/retaliate/goat/blue
	name = "Blue Goat"
	desc = "I'm blue da baah dee da baah daa."
	icon = 'yogstation/icons/mob/goats/blue_goat.dmi'
	icon_state = "bluegoat"
	icon_living = "bluegoat"
	icon_dead = "bluegoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/chocolate
	name = "Chocolate Goat"
	desc = "Actually just a goat with dark brown fur, but I can see why you would think it's made of chocolate."
	icon = 'yogstation/icons/mob/goats/chocolate_goat.dmi'
	icon_state = "chocolategoat"
	icon_living = "chocolategoat"
	icon_dead = "chocolategoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/christmas
	name = "Christmas Goat"
	desc = "Even goats can enjoy Christmas!"
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
	name = "Cotton Candy Goat"
	desc = "Unlike the Chocolate Goat, this goat is made of real cotton candy."
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
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)

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
	desc = "It feels like you have seen this goat before, but you can't place where..."
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
	desc = "I would not get near this goat if I were you."
	icon = 'yogstation/icons/mob/goats/radioactive_goat.dmi'
	icon_state = "radioactivegoat"
	icon_living = "radioactivegoat"
	icon_dead = "radioactivegoat_dead"
	gold_core_spawnable = NO_SPAWN
	light_power = 5
	light_range = 4
	light_color = LIGHT_COLOR_GREEN

/mob/living/simple_animal/hostile/retaliate/goat/radioactive/Life()
	radiation_pulse(src, 600) // It gets stronker as time passes

/mob/living/simple_animal/hostile/retaliate/goat/rainbow
	name = "Rainbow Goat"
	desc = "WHAT DOES IT MEANNNNNNN!"
	icon = 'yogstation/icons/mob/goats/rainbow_goat.dmi'
	icon_state = "rainbowgoat"
	icon_living = "rainbowgoat"
	icon_dead = "rainbowgoat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/storage/crayons = 1, /obj/item/clothing/head/yogs/goatpelt = 1)

/mob/living/simple_animal/hostile/retaliate/goat/cute
	name = "Cute Goat"
	desc = "Be careful, he is a feisty one!"
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
	desc = "Has science gone too far?"
	icon = 'yogstation/icons/mob/goats/twisted_goat.dmi'
	icon_state = "twistedgoat"
	icon_living = "twistedgoat"
	icon_dead = "twistedgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/huge
	name = "Giant Goat"
	desc = "Space Jesus, that's a big goat."
	melee_damage_lower = 10
	melee_damage_upper = 20
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/huge/Initialize()
	. = ..()
	transform *= 2

/mob/living/simple_animal/hostile/retaliate/goat/tiny
	name = "Tiny Goat"
	desc = "Awww, what a tiny goat."
	melee_damage_lower = 1
	melee_damage_upper = 1
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/tiny/Initialize()
	. = ..()
	transform *= 0.5

/mob/living/simple_animal/hostile/retaliate/goat/ghost
	name = "Ghost Goat"
	desc = "Being a ghost doesn't mean he can't kick butt."
	gold_core_spawnable = NO_SPAWN
	color = "#FFFFFF77"
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	butcher_results = list(/obj/item/ectoplasm = 1)

/mob/living/simple_animal/hostile/retaliate/goat/brick
	name = "Brick Goat"
	desc = "I would avoid getting hit by this goat if I were you."
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
	desc = "It's so pretty!"
	icon = 'yogstation/icons/mob/goats/watercolor_goat.dmi'
	icon_state = "watercolorgoat"
	icon_living = "watercolorgoat"
	icon_dead = "watercolorgoat_dead"
	gold_core_spawnable = NO_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3, /obj/item/paint/anycolor = 1, /obj/item/clothing/head/yogs/goatpelt = 1)

/mob/living/simple_animal/hostile/retaliate/goat/brown
	name = "Chestnut Goat"
	desc = "A pretty fine looking goat."
	icon = 'yogstation/icons/mob/goats/brown_goat.dmi'
	icon_state = "browngoat"
	icon_living = "browngoat"
	icon_dead = "browngoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/panda
	name = "Panda Goat"
	desc = "The result of crossing panda DNA with goat DNA."
	icon = 'yogstation/icons/mob/goats/panda_goat.dmi'
	icon_state = "pandagoat"
	icon_living = "pandagoat"
	icon_dead = "pandagoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/stack
	name = "Goat Stack"
	desc = "Seems some goats have decided to stack up to increase attack power. Worked out surprisingly well."
	icon = 'yogstation/icons/mob/goats/stack_goat.dmi'
	icon_state = "goatstack"
	icon_living = "goatstack"
	del_on_death = TRUE
	loot = list(/mob/living/simple_animal/hostile/retaliate/goat,/mob/living/simple_animal/hostile/retaliate/goat/panda,/mob/living/simple_animal/hostile/retaliate/goat/brown)
	health = 100
	maxHealth = 100
	melee_damage_lower = 35
	melee_damage_upper = 40
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/black
	name = "Black Goat"
	desc = "This goat has black fur. Not much else to say."
	icon = 'yogstation/icons/mob/goats/black_goat.dmi'
	icon_state = "blackgoat"
	icon_living = "blackgoat"
	icon_dead = "blackgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/green
	name = "Green Goat"
	desc = "Reminds me of my front lawn."
	icon = 'yogstation/icons/mob/goats/green_goat.dmi'
	icon_state = "greengoat"
	icon_living = "greengoat"
	icon_dead = "greengoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/orange
	name = "Orange Goat"
	desc = "The most tasty of colors."
	icon = 'yogstation/icons/mob/goats/orange_goat.dmi'
	icon_state = "orangegoat"
	icon_living = "orangegoat"
	icon_dead = "orangegoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/purple
	name = "Purple Goat"
	desc = "Why purple?"
	icon = 'yogstation/icons/mob/goats/purple_goat.dmi'
	icon_state = "goatpurple"
	icon_living = "goatpurple"
	icon_dead = "goatpurple_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/red
	name = "Red Goat"
	desc = "Redder than Ragnar." // just make a nerd culture reference smh
	icon = 'yogstation/icons/mob/goats/red_goat.dmi'
	icon_state = "redgoat"
	icon_living = "redgoat"
	icon_dead = "redgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/yellow
	name = "Yellow Goat"
	desc = "MY EYES, THEY BURN."
	icon = 'yogstation/icons/mob/goats/goat_yellow.dmi'
	icon_state = "yellowgoat"
	icon_living = "yellowgoat"
	icon_dead = "yellowgoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/legitgoat // sprite from https://forums.terraria.org/index.php?threads/derpos-magnificent-sprites.9091
	name = "Totally Legit Goat"
	desc = "Yes I am goat would you like to go skateboards?"
	icon = 'yogstation/icons/mob/goats/legit_goat.dmi'
	icon_state = "legitgoat"
	icon_living = "legitgoat"
	icon_dead = "legitgoat_dead"
	can_buckle = 1
	buckle_lying = 0
	tame = 1
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/legitgoat/Initialize()
	. = ..()
	AddComponent(/datum/component/waddling)
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(6, 8, MOB_LAYER), TEXT_SOUTH = list(6, 8, MOB_LAYER), TEXT_EAST = list(4, 8, MOB_LAYER), TEXT_WEST = list( 6, 8, MOB_LAYER)))
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)

/mob/living/simple_animal/hostile/retaliate/goat/skiddo // sprite from https://community.playstarbound.com/threads/goat-retextures-gogoat-and-skiddo-pok%C3%A9mon.110152/
	name = "Skiddo"
	desc = "May or may not be a reference to a certain game involving catching virtual creatures. Also cute as heck."
	icon = 'yogstation/icons/mob/goats/Skiddo.dmi'
	icon_state = "skiddo"
	icon_living = "skiddo"
	icon_dead = "skiddo_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/gogoat // sprite from https://community.playstarbound.com/threads/goat-retextures-gogoat-and-skiddo-pok%C3%A9mon.110152/
	name = "Gogoat"
	desc = "May or may not be a reference to a certain game involving catching virtual creatures. Also, what type of name is Gogoat?!?"
	icon = 'yogstation/icons/mob/goats/Gogoat.dmi'
	icon_state = "gogoat"
	icon_living = "gogoat"
	icon_dead = "gogoat_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/sanic
	name = "Sonic Goat"
	desc = "Gotta go fast!!!"
	icon = 'yogstation/icons/mob/goats/sonic_goat.dmi'
	icon_state = "sonicgoat"
	icon_living = "sonicgoat"
	icon_dead = "sonicgoat_dead"
	move_to_delay = 1
	melee_damage_lower = 10
	melee_damage_upper = 15
	health = 100
	maxHealth = 100
	speak = list("YOUR TOO SLOW!","GOTTA GO FAST!","COME ON KEEP IT UP!")
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/hostile/retaliate/goat/plunger
	name = "Goat with plunger on his head"
	desc = "Not the smartest goat in the barn."
	icon = 'yogstation/icons/mob/goats/plunger_goat.dmi'
	icon_state = "plungergoat"
	icon_living = "plungergoat"
	icon_dead = "plungergoat_dead"
	speak = list("HoW I eAt gRaSS?!?","iS pLaNT gOoD fOr gOaT!?","wHy hOMmOnS sO mEaN!?")
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/spiffles
	name = "Spiffles"
	desc = "Unlike most goats this one has been raised to be as docile as possible making it the perfect pet!"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays.")
	emote_see = list("shakes its head.", "stamps a foot.", "looks around.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 4, /obj/item/clothing/head/yogs/goatpelt = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	icon = 'yogstation/icons/mob/goats/Spiffles.dmi'
	icon_state = "spiffles"
	icon_living = "spiffles"
	icon_dead = "spiffles_dead"
	faction = list("goat")
	gold_core_spawnable = NO_SPAWN
