//These are gravestones for mappers, they are decorations. Nothing more
/obj/structure/gravestone
	name = "gravestone"
	desc = "Rest in piss..."
	icon = 'monkestation/icons/obj/structures/gravestones.dmi'
	icon_state = "gravestone"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	anchored = TRUE
	receive_ricochet_chance_mod = 1 // Bullets CANNOT harm the dead
	max_integrity = 30
	density = 1
	var/gravestoneHasRandDesc = TRUE
	var/list/gravestoneRandList = list(
		"Got romantic with the supermatter crystal...",
		"Suffocated in their own piss cube...",
		"Was wrastled by Hulk Hogan...",
		"Was turned into a felinid...",
		"Tripped on their shoelaces setting up the singularity...",
		"Rode the whip straight into a vending machine...",
		"Tried to bodyblock the escape shuttle...",
		"Was a victim of a mild clown prank...",
		"Was ordered to bite the curb by the Head of Security...",
		"Gored by a hog...",
		"Romanced a goliath...",
		"Tried eating twelve hotdogs at once...",
		"Stole the captain's spare ID...",
		"Tied the HoS' shoes together one too many times...",
		"Hated father, divorced thrice...",
		"Slipped on a bluespace banana peel, ended up in space...",
		"Didn't understand what the 'lusty xenomorph maid' was...",
		"Failed self surgery...",
		"Let the clown do surgery on them...",
		"Ate too many maint pills...",
		"Got locked in the shitter...",
		"Tried to build a jetpack with a plasma tank...",
		"Won a drinking contest...",
		"Didn't realize what 'mass driver' meant...",
		"Got their head crushed by a blast door...",
		"Face tanked an RPG...",
		"Asked the nice man in a red space suit for cash for the vending machine...",
		"Rocked the vending machine too hard...",
		"Forgot to eat one apple a day...",
		"Didn't eat enough fiber...",
		"Drank the entire contents of the pool...",
		"Caught a space carp...",
		"Failed to climb on a table, smashing their head on on the leg...",
		"Didn't realize 'DANGER:RADIOACTIVE' isn't the name of a band...",
		"Face-farted the captain in front of the blueshield...",
		"Dropped a deuce in the captain's bathroom...",
		"Lubed outside the warden's office...",
		"Picked a fight with the wrong chicken...",
		"Thought the crematorium was a tanning booth...",
		"Suffocated in mime jail...",
		"Stuck his face over the air supply pipe...",
		"Got ran over by the MULE bot...",
		"Lost a boxing match with an APLU mech...",
		"Put a single toe into cargo...",
		"Jumped the table into the kitchen...",
		"Stole from gary...",
		"Shoved a crayon up their nose...",
		"Joined a cult...",
		"Drowned in a piss cube...",
		"Pissed off the bartender...",
		"Was devoured by a plushie...",
		"Was eaten by a grue...",
		"Didn't know what they wanted before going up to the hopdesk...",
		"Didn't take a ticket...",
		"Pulled the tag off a mattress...",
		"Got shoved in a washing machine...",
		"Learned what 'ordnance' meant...",
		"Tried making a meth factory...",
		"Successfully made a meth factory...",
		"Made fun of the detective's hat...",
		"Slipped on a banana peel...",
		"Played chicken with the escape shuttle...",
		"Fed the deep fryer a 20 pound bag of ice...",
		"Had their eyes pecked out by a chicken...",
		"Killed Poly...",
		"Was used as target practice by security...",
		"Stubbed their toe...",
		"Took a nap in a coffin, was fed into the incinerator...",
		"Wasn't read their last rites...",
		"Took too long of a shower...",
		"Slipped and smashed their head into the bathroom sink...",
		"Ate all the communal donk pockets...",
		"Got trapped in the morgue tray...",
		"Got spooked...",
		"Became friends with the clown...",
		"Met jeff...",
		"Ignored the OSHA warnings...",
		"Is the reason safety standards were written...",
		"Wrote most of these lines...",
		"HELP IM STUCK IN THE HEADSTONE FACTORY!!!"
		)

/obj/structure/gravestone/Initialize(mapload)
	. = ..()
	if(gravestoneHasRandDesc==TRUE)
		var/deadGender = pick("male","female")
		if(deadGender == "male")
			desc = pick(GLOB.first_names_male) + " " + capitalize(pick(GLOB.last_names) + " : " + pick(gravestoneRandList))
		else
			desc = pick(GLOB.first_names_female) + " " + capitalize(pick(GLOB.last_names) + " : " + pick(gravestoneRandList))

/obj/structure/gravestone/one
	icon_state = "gravestone1"
	desc = "Mai waife..."

/obj/structure/gravestone/two
	icon_state = "gravestone2"
	desc = "It's Pee Puddle Pendrick! The infamous bandit..."
