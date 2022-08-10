/obj/item/clothing/under/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/patriotsuit
	name = "Patriotic Suit"
	desc = "Motorcycle not included."
	icon_state = "ek"
	item_state = "ek"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host."
	icon_state = "scratch"
	item_state = "scratch"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/scratch/skirt
	name = "white suitskirt"
	desc = "A white suitskirt, suitable for an excellent host."
	icon_state = "white_suit_skirt"
	item_state = "scratch"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/sl_suit
	desc = "It's a very amish looking suit."
	name = "amish suit"
	icon_state = "sl_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/roman
	name = "\improper Roman armor"
	desc = "Ancient Roman armor. Made of metallic and leather straps."
	icon_state = "roman"
	item_state = "armor"
	can_adjust = FALSE
	strip_delay = 100
	resistance_flags = NONE

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tips."
	icon_state = "waiter"
	item_state = "waiter"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/prisoner
	name = "prison jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	item_state = "o_suit"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/prisoner/skirt
	name = "prison jumpskirt"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner_skirt"
	item_state = "o_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	mutantrace_variation = MUTANTRACE_VARIATION

/* Commented out in favor of yogstation custom content
/obj/item/clothing/under/rank/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state = "p_suit"
	mutantrace_variation = MUTANTRACE_VARIATION
*/

/obj/item/clothing/under/rank/clown/sexy
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/jabroni
	name = "Jabroni Outfit"
	desc = "The leather club is two sectors down."
	icon_state = "darkholme"
	item_state = "darkholme"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "gy_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/rank/centcom_officer
	desc = "It's a jumpsuit worn by CentCom Officers."
	name = "\improper CentCom officer's jumpsuit"
	icon_state = "officer"
	item_state = "g_suit"
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/centcom_commander
	desc = "It's a jumpsuit with gold markings worn by CentCom's highest-tier commanders."
	name = "\improper CentCom officer's jumpsuit"
	icon_state = "centcom"
	item_state = "dg_suit"
	alt_covers_chest = TRUE
	mutantrace_variation = MUTANTRACE_VARIATION
	can_adjust = TRUE //too important to look unimportant.

/obj/item/clothing/under/rank/centcom_admiral
	desc = "It's a jumpsuit with gold markings worn by CentCom High Command."
	name = "\improper CentCom admiral's jumpsuit"
	icon_state = "admiral"
	item_state = "admiral"
	can_adjust = FALSE //too important to look unimportant.

/obj/item/clothing/under/rank/centcom_admiral/grand
	desc = "It's a jumpsuit with gold markings worn by CentCom's highest-ranking officer."
	name = "\improper CentCom grand admiral's jumpsuit"
	icon_state = "grandadmiral"
	item_state = "grandadmiral"

/obj/item/clothing/under/space
	name = "\improper NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon_state = "black"
	item_state = "bl_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	desc = "A cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 100, BULLET = 100, LASER = 100,ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/owl
	name = "owl uniform"
	desc = "A soft brown jumpsuit made of synthetic feathers and strong conviction."
	icon_state = "owl"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/griffin
	name = "griffon uniform"
	desc = "A soft brown jumpsuit with a white feather collar made of synthetic feathers and a lust for mayhem."
	icon_state = "griffin"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/cloud
	name = "cloud"
	desc = "cloud"
	icon_state = "cloud"
	can_adjust = FALSE

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/gimmick/rank/captain/suit/skirt
	name = "green suitskirt"
	desc = "A green suitskirt and yellow necktie. Exemplifies authority."
	icon_state = "green_suit_skirt"
	item_state = "dg_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "g_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit/skirt
	name = "teal suitskirt"
	desc = "A teal suitskirt and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit_skirt"
	item_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = NO_MUTANTRACE_VARIATION

/obj/item/clothing/under/suit_jacket
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state = "bl_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/suit_jacket/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"
	item_state = "bl_suit"

/obj/item/clothing/under/suit_jacket/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the station's finest."
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"

/obj/item/clothing/under/suit_jacket/green
	name = "green suit"
	desc = "A green suit and yellow necktie. Baller."
	icon_state = "green_suit"
	item_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/suit_jacket/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	item_state = "r_suit"

/obj/item/clothing/under/suit_jacket/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit and red tie. Very professional."
	icon_state = "charcoal_suit"
	item_state = "charcoal_suit"

/obj/item/clothing/under/suit_jacket/navy
	name = "navy suit"
	desc = "A navy suit and red tie, intended for the station's finest."
	icon_state = "navy_suit"
	item_state = "navy_suit"

/obj/item/clothing/under/suit_jacket/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"
	item_state = "burgundy_suit"

/obj/item/clothing/under/suit_jacket/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"
	item_state = "checkered_suit"

/obj/item/clothing/under/suit_jacket/tan
	name = "tan suit"
	desc = "A tan suit with a yellow tie. Smart, but casual."
	icon_state = "tan_suit"
	item_state = "tan_suit"

/obj/item/clothing/under/suit_jacket/white
	name = "white suit"
	desc = "A white suit and jacket with a blue shirt. You wanna play rough? OKAY!"
	icon_state = "white_suit"
	item_state = "white_suit"

/obj/item/clothing/under/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	item_state = "burial"
	has_sensor = NO_SENSORS
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/skirt/black
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/skirt/blue
	name = "blue skirt"
	desc = "A blue, casual skirt."
	icon_state = "blueskirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	custom_price = 25

/obj/item/clothing/under/skirt/red
	name = "red skirt"
	desc = "A red, casual skirt."
	icon_state = "redskirt"
	item_state = "r_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	custom_price = 25

/obj/item/clothing/under/skirt/purple
	name = "purple skirt"
	desc = "A purple, casual skirt."
	icon_state = "purpleskirt"
	item_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	custom_price = 25


/obj/item/clothing/under/schoolgirl
	name = "blue schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/schoolgirl/red
	name = "red schoolgirl uniform"
	icon_state = "schoolgirlred"
	item_state = "schoolgirlred"

/obj/item/clothing/under/schoolgirl/green
	name = "green schoolgirl uniform"
	icon_state = "schoolgirlgreen"
	item_state = "schoolgirlgreen"

/obj/item/clothing/under/schoolgirl/orange
	name = "orange schoolgirl uniform"
	icon_state = "schoolgirlorange"
	item_state = "schoolgirlorange"

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	can_adjust = FALSE
	custom_price = 20
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/pirate
	name = "pirate outfit"
	desc = "Yarr! A fine shirt and pants for the enterprising corsair."
	icon_state = "pirate"
	item_state = "pirate"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/pirate/space
	name = "syndicate pirate outfit"
	desc = "Yarr! A set of reinforced pirate clothing worn by boney Syndicate privateers."
	has_sensor = NO_SENSORS
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 40)

/obj/item/clothing/under/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state = "soviet"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state = "redcoat"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	item_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/kilt/highlander
	desc = "You're the only one worthy of this kilt."

/obj/item/clothing/under/kilt/highlander/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/under/sexymime
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	body_parts_covered = CHEST|GROIN|LEGS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state = "gladiator"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/gladiator/ash_walker
	desc = "This gladiator uniform appears to be covered in ash and fairly dated."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	item_state = "sundress"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/captainparade
	name = "captain's parade uniform"
	desc = "A captain's luxury-wear, for special occasions."
	icon_state = "captain_parade"
	item_state = "by_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/hosparademale
	name = "head of security's parade uniform"
	desc = "A male head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_male"
	item_state = "r_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/hosparadefem
	name = "head of security's parade uniform"
	desc = "A female head of security's luxury-wear, for special occasions."
	icon_state = "hos_parade_fem"
	item_state = "r_suit"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/blacktango
	name = "black tango dress"
	desc = "Filled with Latin fire."
	icon_state = "black_tango"
	item_state = "wcoat"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/stripeddress
	name = "striped dress"
	desc = "Fashion in space."
	icon_state = "striped_dress"
	item_state = "stripeddress"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_FULL
	can_adjust = FALSE

/obj/item/clothing/under/sailordress
	name = "sailor dress"
	desc = "Formal wear for a leading lady."
	icon_state = "sailor_dress"
	item_state = "sailordress"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/redeveninggown
	name = "red evening gown"
	desc = "Fancy dress for space bar singers."
	icon_state = "red_evening_gown"
	item_state = "redeveninggown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/maid
	name = "maid costume"
	desc = "Maid in China."
	icon_state = "maid"
	item_state = "maid"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/maid/Initialize()
	. = ..()
	var/obj/item/clothing/accessory/maidapron/A = new (src)
	attach_accessory(A)

/obj/item/clothing/under/janimaid
	name = "maid uniform"
	desc = "A simple maid uniform for housekeeping."
	icon_state = "janimaid"
	item_state = "janimaid"
	body_parts_covered = CHEST|GROIN|FEET|LEGS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/plaid_skirt
	name = "red plaid skirt"
	desc = "A preppy red skirt with a white blouse."
	icon_state = "plaid_red"
	item_state = "plaid_red"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = TRUE
	alt_covers_chest = TRUE
	custom_price = 25

/obj/item/clothing/under/plaid_skirt/blue
	name = "blue plaid skirt"
	desc = "A preppy blue skirt with a white blouse."
	icon_state = "plaid_blue"
	item_state = "plaid_blue"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/plaid_skirt/purple
	name = "purple plaid skirt"
	desc = "A preppy purple skirt with a white blouse."
	icon_state = "plaid_purple"
	item_state = "plaid_purple"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/singery
	name = "yellow performer's outfit"
	desc = "Just looking at this makes you want to sing."
	icon_state = "ysing"
	item_state = "ysing"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/singerb
	name = "blue performer's outfit"
	desc = "Just looking at this makes you want to sing."
	icon_state = "bsing"
	item_state = "bsing"
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/plaid_skirt/green
	name = "green plaid skirt"
	desc = "A preppy green skirt with a white blouse."
	icon_state = "plaid_green"
	item_state = "plaid_green"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/jester
	name = "jester suit"
	desc = "A jolly dress, well suited to entertain your master, nuncle."
	icon_state = "jester"
	can_adjust = FALSE

/obj/item/clothing/under/geisha
	name = "geisha suit"
	desc = "Cute space ninja senpai not included."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/villain
	name = "villain suit"
	desc = "A change of wardrobe is necessary if you ever want to catch a real superhero."
	icon_state = "villain"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/sailor
	name = "sailor suit"
	desc = "Skipper's in the wardroom drinkin' gin."
	icon_state = "sailor"
	item_state = "b_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/plasmaman
	name = "envirosuit"
	desc = "The latest generation of Nanotrasen-designed plasmamen envirosuits. This new version has an extinguisher built into the uniform's workings. While airtight, the suit is not EVA-rated."
	icon_state = "plasmaman"
	item_state = "plasmaman"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 95, ACID = 95)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 80
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5


/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += span_notice("There are [extinguishes_left] extinguisher charges left in this suit.")

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit automatically extinguishes [H.p_them()]!"),span_warning("Your suit automatically extinguishes you."))
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return 0

/obj/item/clothing/under/plasmaman/attackby(obj/item/E, mob/user, params)
	..()
	if (istype(E, /obj/item/extinguisher_refill))
		if (extinguishes_left == 5)
			to_chat(user, span_notice("The inbuilt extinguisher is full."))
		else
			extinguishes_left = 5
			to_chat(user, span_notice("You refill the suit's built-in extinguisher, using up the cartridge."))
			qdel(E)

/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "A cartridge loaded with a compressed extinguisher mix, used to refill the automatic extinguisher on plasma envirosuits."
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'

/obj/item/clothing/under/rank/security/navyblue/russian
	name = "\improper Russian officer's uniform"
	desc = "The latest in fashionable Russian outfits."
	icon_state = "hostanclothes"
	item_state = "hostanclothes"
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/mummy
	name = "mummy wrapping"
	desc = "Return the slab or suffer my stale references."
	icon_state = "mummy"
	item_state = "mummy"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/scarecrow
	name = "scarecrow clothes"
	desc = "Perfect camouflage for hiding in botany."
	icon_state = "scarecrow"
	item_state = "scarecrow"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/draculass
	name = "draculass coat"
	desc = "A dress inspired by the ancient \"Victorian\" era."
	icon_state = "draculass"
	item_state = "draculass"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/drfreeze
	name = "doctor freeze's jumpsuit"
	desc = "A modified scientist jumpsuit to look extra cool."
	icon_state = "drfreeze"
	item_state = "drfreeze"
	can_adjust = FALSE

/obj/item/clothing/under/lobster
	name = "foam lobster suit"
	desc = "Who beheaded the college mascot?"
	icon_state = "lobster"
	item_state = "lobster"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/gondola
	name = "gondola hide suit"
	desc = "Now you're cooking."
	icon_state = "gondola"
	item_state = "lb_suit"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/skeleton
	name = "skeleton jumpsuit"
	desc = "A black jumpsuit with a white bone pattern printed on it. Spooky!"
	icon_state = "skeleton"
	item_state = "skeleton"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	item_state = "durathread"
	can_adjust = FALSE
	armor = list(MELEE = 10, LASER = 10, FIRE = 40, ACID = 10, BOMB = 5)
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/mech_suit
	name = "red mech pilot's suit"
	desc = "A red mech pilot's suit. Might make your butt look big."
	icon_state = "red_mech_suit"
	item_state = "red_mech_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE

/obj/item/clothing/under/mech_suit/white
	name = "white mech pilot's suit"
	desc = "A white mech pilot's suit. Very fetching."
	icon_state = "white_mech_suit"
	item_state = "white_mech_suit"
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/mech_suit/blue
	name = "blue mech pilot's suit"
	desc = "A blue mech pilot's suit. For the more reluctant mech pilots."
	icon_state = "blue_mech_suit"
	item_state = "blue_mech_suit"
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/lampskirt
	name = "lamp dress"
	desc = "A peculier garment woven in silk; under the lower dress appears to be a lamp and a switch."
	icon_state = "lampskirt_male"
	item_state = "lampskirt_male"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	can_adjust = FALSE
	var/brightness_on = 1 //luminosity when the light is on
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/under/lampskirt/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_w_uniform() //So the mob overlay updates

	if(on)
		set_light(brightness_on)
		user.visible_message(span_notice("[user] discreetly pulls a cord for the bulbs under [user.p_their()] skirt, turning [user.p_them()] on."))
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/under/lampskirt/female
	icon_state = "lampskirt_female"
	item_state = "lampskirt_female"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/weiner
	name = "weiner outfit"
	desc = "The meat part of a hot dog costume. People may think you're trying to compensate for something."
	icon_state = "weiner"
	item_state = "weiner"
	can_adjust = FALSE

// Ashwalker Clothes
/obj/item/clothing/under/chestwrap
	name = "loincloth and chestwrap"
	desc = "A poorly sewn dress made of leather."
	icon_state = "chestwrap"
	has_sensor = NO_SENSORS
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/under/raider_leather
	name = "scavenged rags"
	desc = "A porly made outfit made of scrapped materials."
	icon_state = "raider_leather"
	item_state = "raider_leather"
	armor = list(MELEE = 5, FIRE = 5)
	has_sensor = NO_SENSORS
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION

/obj/item/clothing/under/tribal
	name = "metal plated rags"
	desc = "Thin metal bolted over poorly tanned leather."
	icon_state = "tribal"
	item_state = "tribal"
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list(MELEE = 5)
	has_sensor = NO_SENSORS
	can_adjust = FALSE

/obj/item/clothing/under/ash_robe
	name = "tribal robes"
	desc = "A robe from the ashlands. This one seems to be for common tribespeople."
	icon_state = "robe_liz"
	item_state = "robe_liz"
	fitted = NO_FEMALE_UNIFORM
	body_parts_covered = CHEST|GROIN
	has_sensor = NO_SENSORS
	can_adjust = FALSE
	fitted = NO_FEMALE_UNIFORM

/obj/item/clothing/under/ash_robe/young
	name = "tribal rags"
	desc = "Rags from Lavaland, coated with light ash. This one seems to be for the juniors of a tribe."
	icon_state = "tribalrags"

/obj/item/clothing/under/ash_robe/hunter
	name = "hunter tribal rags"
	desc = "A robe from the ashlands. This one seems to be for hunters."
	icon_state = "hhunterrags"
	item_state = "hhunterrags"

/obj/item/clothing/under/ash_robe/chief
	name = "chief tribal rags"
	desc = "Rags from Lavaland, coated with heavy ash. This one seems to be for the elders of a tribe."
	icon_state = "chiefrags"
	item_state = "chiefrags"

/obj/item/clothing/under/ash_robe/shaman
	name = "shaman tribal rags"
	desc = "Rags from Lavaland, drenched with ash, it has fine jewel coated bones sewn around the neck. This one seems to be for the shaman of a tribe."
	icon_state = "shamanrags"
	item_state = "shamanrags"

/obj/item/clothing/under/ash_robe/tunic
	name = "tribal tunic"
	desc = "A tattered red tunic of reddened fabric."
	icon_state = "caesar_clothes"
	item_state = "caesar_clothes"

/obj/item/clothing/under/ash_robe/dress
	name = "tribal dress"
	desc = "A tattered dress of white fabric."
	icon_state = "cheongsam_s"
	item_state = "cheongsam_s"

/obj/item/clothing/under/drip
	name = "incredibly fashionable outfit"
	desc = "Expensive-looking designer vest. It radiates an aggressively attractive aura. You feel putting this on would change you forever."
	icon = 'icons/obj/clothing/uniforms.dmi'
	mob_overlay_icon = 'icons/mob/clothing/uniform/uniform.dmi'
	icon_state = "drippy"
	item_state = "drippy"
	armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, RAD = 10, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF//Miners Bizzare Adventure Drip is Unbreakable
	can_adjust = FALSE

/obj/item/clothing/under/drip/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_W_UNIFORM)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drippy", /datum/mood_event/drippy)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "dripless", /datum/mood_event/drippy)
		if(user && ishuman(user) && !user.GetComponent(/datum/component/mood))
			to_chat(user, span_danger("As you put on the drip, you have an overwhelming sense of superiority shape your soul!"))
			user.AddComponent(/datum/component/mood) //The drips curse, mood.

/obj/item/clothing/under/drip/dropped(mob/user)
	. = ..()
	SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "drippy")
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "dripless", /datum/mood_event/dripless)
