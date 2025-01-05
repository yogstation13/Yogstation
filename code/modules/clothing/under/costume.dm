/obj/item/clothing/under/costume
	worn_icon = 'icons/mob/clothing/uniform/costume.dmi'

/obj/item/clothing/under/costume/jabroni
	name = "Jabroni Outfit"
	desc = "The leather club is two sectors down."
	icon_state = "darkholme"
	item_state = "darkholme"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/patriotsuit
	name = "Patriotic Suit"
	desc = "Motorcycle not included."
	icon_state = "ek"
	item_state = "ek"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/roman
	name = "\improper Roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	item_state = "armor"
	can_adjust = FALSE
	strip_delay = 100
	resistance_flags = NONE

/obj/item/clothing/under/costume/owl
	name = "owl uniform"
	desc = "A soft brown jumpsuit made of synthetic feathers and strong conviction."
	icon_state = "owl"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/griffin
	name = "griffon uniform"
	desc = "A soft brown jumpsuit with a white feather collar made of synthetic feathers and a lust for mayhem."
	icon_state = "griffin"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/cloud
	name = "cloud"
	desc = "Cloud."
	icon_state = "cloud"
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl
	name = "blue schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl/red
	name = "red schoolgirl uniform"
	icon_state = "schoolgirlred"
	item_state = "schoolgirlred"

/obj/item/clothing/under/costume/schoolgirl/green
	name = "green schoolgirl uniform"
	icon_state = "schoolgirlgreen"
	item_state = "schoolgirlgreen"

/obj/item/clothing/under/costume/schoolgirl/orange
	name = "orange schoolgirl uniform"
	icon_state = "schoolgirlorange"
	item_state = "schoolgirlorange"

/obj/item/clothing/under/costume/pirate
	name = "pirate outfit"
	desc = "Yarr! A fine shirt and pants for the enterprising corsair."
	icon_state = "pirate"
	item_state = "pirate"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/pirate/space
	name = "syndicate pirate outfit"
	desc = "Yarr! A set of reinforced pirate clothing worn by boney Syndicate privateers."
	has_sensor = NO_SENSORS
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 40)

/obj/item/clothing/under/costume/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state = "soviet"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state = "redcoat"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	item_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/kilt/highlander
	desc = "You're the only one worthy of this kilt."

/obj/item/clothing/under/costume/kilt/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/under/costume/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state = "gladiator"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/gladiator/ash_walker
	desc = "This gladiator uniform appears to be covered in ash and fairly dated."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/maid
	name = "maid costume"
	desc = "Maid in China."
	icon_state = "maid"
	item_state = "maid"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/maid/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/maidapron/A = new (src)
	attach_accessory(A)

/obj/item/clothing/under/costume/singery
	name = "yellow performer's outfit"
	desc = "Just looking at this makes you want to sing."
	icon_state = "ysing"
	item_state = "ysing"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/singerb
	name = "blue performer's outfit"
	desc = "Just looking at this makes you want to sing."
	icon_state = "bsing"
	item_state = "bsing"
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/jester
	name = "jester suit"
	desc = "A jolly dress, well suited to entertain your master, nuncle."
	icon_state = "jester"
	can_adjust = FALSE

/obj/item/clothing/under/costume/geisha
	name = "geisha suit"
	desc = "Cute space ninja senpai not included."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/villain
	name = "villain suit"
	desc = "A change of wardrobe is necessary if you ever want to catch a real superhero."
	icon_state = "villain"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/sailor
	name = "sailor suit"
	desc = "Skipper's in the wardroom drinkin' gin."
	icon_state = "sailor"
	item_state = "b_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	item_state = "mummy"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	item_state = "scarecrow"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient \"Victorian\" era."
	icon_state = "draculass"
	item_state = "draculass"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/drfreeze
	name = "doctor freeze's jumpsuit"
	desc = "A modified scientist jumpsuit to look extra cool."
	icon_state = "drfreeze"
	item_state = "drfreeze"
	can_adjust = FALSE

/obj/item/clothing/under/costume/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	item_state = "lobster"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gondola
	name = "gondola hide suit"
	desc = "Now you're cooking."
	icon_state = "gondola"
	item_state = "lb_suit"
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/skeleton
	name = "skeleton jumpsuit"
	desc = "A black jumpsuit with a white bone pattern printed on it. Spooky!"
	icon_state = "skeleton"
	item_state = "skeleton"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/mech_suit
	name = "red mech pilot's suit"
	desc = "A red mech pilot's suit. Might make your butt look big."
	icon_state = "red_mech_suit"
	item_state = "red_mech_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE
	clothing_traits = list(TRAIT_SKILLED_PILOT)

/obj/item/clothing/under/costume/mech_suit/white
	name = "white mech pilot's suit"
	desc = "A white mech pilot's suit. Very fetching."
	icon_state = "white_mech_suit"
	item_state = "white_mech_suit"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/mech_suit/blue
	name = "blue mech pilot's suit"
	desc = "A blue mech pilot's suit. For the more reluctant mech pilots."
	icon_state = "blue_mech_suit"
	item_state = "blue_mech_suit"
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/mech_suit/cybersun
	name = "Cybersun mech pilot's suit"
	desc = "An armored mech pilot suit, used exclusively by Cybersun mech agents."
	icon_state = "black_mech_suit"
	item_state = "black_mech_suit"
	armor = list(MELEE = 15, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 50, BIO = 50, RAD = 20, FIRE = 50, ACID = 50, WOUND = 5)
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/lampskirt
	name = "lamp dress"
	desc = "A peculier garment woven in silk; under the lower dress appears to be a lamp and a switch."
	icon_state = "lampskirt_male"
	item_state = "lampskirt_male"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	can_adjust = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_on = FALSE
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/under/costume/lampskirt/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_w_uniform() //So the mob overlay updates

	if(on)
		set_light_on(TRUE)
		user.visible_message(span_notice("[user] discreetly pulls a cord for the bulbs under [user.p_their()] skirt, turning [user.p_them()] on."))
	else
		set_light_on(FALSE)

	for(var/X in actions)
		var/datum/action/A=X
		A.build_all_button_icons()

/obj/item/clothing/under/costume/lampskirt/female
	icon_state = "lampskirt_female"
	item_state = "lampskirt_female"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/costume/weiner
	name = "weiner outfit"
	desc = "The meat part of a hot dog costume. People may think you're trying to compensate for something."
	icon_state = "weiner"
	item_state = "weiner"
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/costume/drip
	name = "incredibly fashionable outfit"
	desc = "Expensive-looking designer vest. It radiates an aggressively attractive aura. You feel putting this on would change you forever."
	icon_state = "SwagOutfit"
	item_state = "SwagOutfit"
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, RAD = 10, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF//Miners Bizzare Adventure Drip is Unbreakable
	can_adjust = FALSE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/drip/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_ICLOTHING)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drippy", /datum/mood_event/drippy)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "dripless", /datum/mood_event/drippy)
		if(user && ishuman(user) && !user.GetComponent(/datum/component/mood))
			to_chat(user, span_danger("As you put on the drip, you have an overwhelming sense of superiority shape your soul!"))
			user.AddComponent(/datum/component/mood) //The drips curse, mood.

/obj/item/clothing/under/costume/drip/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_ICLOTHING) == src)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "drippy")
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "dripless", /datum/mood_event/dripless)

/* Commented out in favor of yogstation custom content
/obj/item/clothing/under/costume/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state = "p_suit"
	mutantrace_variation = DIGITIGRADE_VARIATION
*/
