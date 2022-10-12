/obj/item/clothing/under/yogs/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche_s"
	item_state = "rainbow"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/scaryclown
	name = "scary clown suit"
	desc = "Often worn by sewer clowns."
	icon_state = "scaryclownuniform"
	item_state = "scaryclownuniform"
	can_adjust = FALSE

/obj/item/clothing/under/rank/yogs/scaryclown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)

/obj/item/clothing/under/yogs/harveyflint
	name = "black and red suit"
	desc = "Two faces, two colors."
	icon_state = "harvey_flint_s"
	item_state = "harvey_flint"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/thejester
	name = "jester suit"
	desc = "You can never catch me, spaceman!"
	icon_state = "the_jester_s"
	item_state = "the_jester"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/trickster
	name = "trickster suit"
	desc = "HAHAHA! I love riddles!"
	icon_state = "trickster_s"
	item_state = "trickster"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/penguinsuit
	name = "penguin suit"
	desc = "How fancy!"
	icon_state = "penguin_s"
	item_state = "penguin"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/barber
	name = "barber suit"
	desc = "The perfect suit for singing in a quartet."
	icon_state = "barber_s"
	item_state = "barber"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/dresdenunder
	name = "dresden suit"
	desc = "Generic nerd by day, evil super villian by night."
	icon_state = "dresdenunder_s"
	item_state = "dresdenunder"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/relaxedwearm
	name = "relaxed suit"
	desc = "Perfect for hosting that evening bbq!"
	icon_state = "relaxedwearm_s"
	item_state = "relaxedwearm"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/springm
	name = "relaxed spring suit"
	desc = "Perfect for relaxing under the spring sun!"
	icon_state = "springm_s"
	item_state = "springm"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/pinstripe
	name = "pinstripe suit"
	desc = "This suit screams rich mafia boss."
	icon_state = "pinstripe_s"
	item_state = "pinstripe"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/treasure
	name = "treasure hunter suit"
	desc = "This suit belongs in a museum!"
	icon_state = "doctor_s"
	item_state = "doctor"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/doomsday
	name = "doomsday suit"
	desc = "The end times are here!"
	icon_state = "doomsday_s"
	item_state = "doomsday"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/rycliesuni
	name = "aluminum foil coated suit"
	desc = "Protects your body from mental brainwashing. Too bad there is no brain inside of your chest."
	icon_state = "rycliesuni_s"
	item_state = "rycliesuni"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/oliveoutfit
	name = "olive suit"
	desc = "For people who want to look like they are in the army without actually being in the army."
	icon_state = "oliveoutfit_s"
	item_state = "oliveoutfit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/plaidoutfit
	name = "plaid suit"
	desc = "The most boring of suits."
	icon_state = "plaidoutfit_s"
	item_state = "plaidoutfit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/moutfit
	name = "casual red suit"
	desc = "The most casual of suits."
	icon_state = "moutfit_s"
	item_state = "moutfit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/luna
	name = "work suit"
	desc = "So about that football team..."
	icon_state = "luna_s"
	item_state = "luna"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/altshield
	name = "electronic store work suit"
	desc = "The name tag has the name 'Joe From Accounting' on it."
	icon_state = "altshield_s"
	item_state = "altshield"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/namjumpsuit
	name = "nam jumpsuit"
	desc = "Welcome to nam, soldier. Now let's go arrest some greytide!"
	icon_state = "namjumpsuit_s"
	item_state = "namjumpsuit"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = TRUE

/obj/item/clothing/under/yogs/ocelot
	name = "gulag officer uniform"
	desc = "For wardens particular to the use of the gulag."
	icon_state = "gru_officer_s"
	item_state = "gru_officer"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/lieutgeneral
	name = "security general uniform"
	desc = "As long as you protect your men and arrest the greytide you should be fine. God speed."
	icon_state = "Lieut_General_US_s"
	item_state = "Lieut_General_US"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/captainartillery
	name = "captain artillery uniform"
	desc = "You are the commander of your men and the top of the top, dont let them down!"
	icon_state = "Captain_Artillery_CS_s"
	item_state = "Captain_Artillery_CS"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/bluecoatuniform
	name = "bluecoat uniform"
	desc = "Darn yankees."
	icon_state = "blue_coat_uniform_s"
	item_state = "blue_coat_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/redcoatuniform
	name = "redcoat uniform"
	desc = "Security is coming! Security is coming!"
	icon_state = "red_coat_uniform_s"
	item_state = "red_coat_uniform"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 30, ACID = 30)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/hamiltonuniform
	name = "hamilton uniform"
	desc = "Time to be the leader of your own musical!"
	icon_state = "hamilton_uniform_s"
	item_state = "hamilton_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/cowboy2
	name = "cowboy uniform"
	desc = "Welcome to the wild west partner."
	icon_state = "cowboy2_s"
	item_state = "cowboy2"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/cowboy
	name = "fancy cowboy uniform"
	desc = "Welcome to the wild west partner. Now slightly more fancy!"
	icon_state = "cowboy_s"
	item_state = "cowboy"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/bluedetective
	name = "blue detective suit"
	desc = "A suit often worn by those detective types. Now in blue!"
	icon_state = "blue_detective"
	item_state = "blue_detective"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/golddetective
	name = "gold detective suit"
	desc = "A suit often worn by those detective types. Now in gold!"
	icon_state = "gold_detective"
	item_state = "gold_detective"

/obj/item/clothing/under/yogs/greydetective
	name = "grey detective suit"
	desc = "A suit often worn by those detective types. Now in boring old grey!"
	icon_state = "grey_detective"
	item_state = "grey_detective"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/blackdetective
	name = "black detective suit"
	desc = "A suit often worn by those detective types. Now in black!"
	icon_state = "black_detective"
	item_state = "black_detective"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/whitetuxedo
	name = "white tuxedo"
	desc = "The perfect suit for almost any occasion, just make sure to wash it down once you're done with it."
	icon_state = "white_tuxedo"
	item_state = "white_tuxedo"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/ceturtleneck
	name = "chief engineer turtleneck"
	desc = "How cozy!"
	icon_state = "ce_turtleneck"
	item_state = "ce_turtleneck"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 80, ACID = 40)
	resistance_flags = NONE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/whitedress
	name = "white dress"
	desc = "The perfect dress for almost any ball."
	icon_state = "white_dress"
	item_state = "white_dress"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/nursedress
	name = "nurse dress"
	desc = "Nurse, stop standing there and help me! I am dying!"
	icon_state = "nurse_dress"
	item_state = "nurse_dress"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/prosecutorsuit
	name = "prosecutor suit"
	desc = "GUILTY! LET'S GO GET SOME DONUTS!"
	icon_state = "prosecutor_suit"
	item_state = "prosecutor_suit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/dictatorhos
	name = "dictator head of security suit"
	desc = "The leader the station does not need or want."
	icon_state = "uniform_two"
	item_state = "uniform_two"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/botanyuniform
	name = "botany yellow uniform"
	desc = "Are we making meth or growing plants?"
	icon_state = "botany_uniform"
	item_state = "botany_uniform"
	permeability_coefficient = 0.5
	can_adjust = FALSE

/obj/item/clothing/under/yogs/casualcaptain
	name = "casual captain uniform"
	desc = "Even the captain has to let loose on this metal death trap every now and then."
	icon_state = "casual_captain"
	item_state = "casual_captain"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/fancysuit
	name = "fancy suit"
	desc = "What a fancy suit!"
	icon_state = "fancy_suit"
	item_state = "fancy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/redcamo
	name = "red camo uniform"
	desc = "Kinda ruins the whole point of camouflage in the first place to be honest."
	icon_state = "red_camo"
	item_state = "red_camo"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/whitecaptainsuit
	name = "white captain suit"
	desc = "For captains who want to pretend they are a boat captain and not a space station captain."
	icon_state = "captain_suit"
	item_state = "captain_suit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/armyuniform
	name = "army uniform"
	desc = "Often seen being worn by the space army."
	icon_state = "army_uniform"
	item_state = "army_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/work_suit
	name = "workout suit"
	desc = "Perfect for that 24/7 workout with all the running you do around the station."
	icon_state = "work_suit"
	item_state = "work_suit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/colony
	name = "colonial suit"
	desc = "Nothing like exploring the great jungles of watabaga and fighting the great lumbarian wombo in the morning."
	icon_state = "colony_longsleeve"
	item_state = "colony_longsleeve"

/obj/item/clothing/under/yogs/hoslatenight
	name = "late night head of security uniform"
	desc = "For those more quiet shifts."
	icon_state = "hos1_suit"
	item_state = "hos1_suit"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/cecasual
	name = "casual chief engineer uniform"
	desc = "Even the CE has to take a break from setting up the engine somet- and the singlo is loose."
	icon_state = "ce_suit"
	item_state = "ce_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 80, ACID = 40)
	resistance_flags = NONE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/hoscasual
	name = "casual head of security uniform"
	desc = "Even the HoS has to take a break from beating the clown sometimes."
	icon_state = "hos_suit"
	item_state = "hos_suit"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	alt_covers_chest = TRUE
	sensor_mode = 3
	random_sensor = FALSE
	can_adjust = FALSE

/obj/item/clothing/under/yogs/hopcasual
	name = "casual head of personnel uniform"
	desc = "Even the HoP has to take a break from giving all access to the crew sometimes."
	icon_state = "hop_suit"
	item_state = "hop_suit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/forensictech
	name = "forensic technician suit"
	desc = "Hmm, this bloody toolbox has insulated fibers on it..."
	icon_state = "forensic_tech"
	item_state = "forensic_tech"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/bluetunic
	name = "blue tunic"
	desc = "Perfect for relaxing in a bath house. Too bad there isn't one on the station."
	icon_state = "bluetunic_s"
	item_state = "bluetunic"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/caretaker
	name = "caretaker suit"
	desc = "Yeah, he will 'take care' of you alright."
	icon_state = "caretaker_s"
	item_state = "caretaker"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/familiartunic
	name = "familiar tunic"
	desc = "You swear you've seen this tunic before, but you can't place where..."
	icon_state = "familiartunic_s"
	item_state = "familiartunic"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/fiendsuit
	name = "fiend suit"
	desc = "Named so because only a really bad person would wear such a suit."
	icon_state = "fiendsuit_s"
	item_state = "fiendsuit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/grimhoodie
	name = "grim hoodie"
	desc = "A hoodie without a hood... how grim."
	icon_state = "grimhoodie_s"
	item_state = "grimhoodie"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/infmob
	name = "russian gangster uniform"
	desc = "So you wanna be a classy gangster, ay?"
	icon_state = "inf_mob_s"
	item_state = "inf_mob"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/persskinsuit
	name = "blue skinsuit"
	desc = "Pretty uncomfortable but at least it looks cool."
	icon_state = "pers_skinsuit_s"
	item_state = "pers_skinsuit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/soldieruniform
	name = "soldier uniform"
	desc = "Are you a man or a mouse?"
	icon_state = "soldier_uniform_s"
	item_state = "soldier_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/lightpink
	name = "light pink jumpsuit"
	desc = "A jumpsuit. Now in light pink."
	icon_state = "lightpink_s"
	item_state = "lightpink"

/obj/item/clothing/under/yogs/rdema
	name = "pink research directors uniform"
	desc = "What relaxing colors."
	icon_state = "rdema_s"
	item_state = "rdema"
	can_adjust = FALSE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 10, RAD = 0, FIRE = 0, ACID = 35)

/obj/item/clothing/under/yogs/billydonka
	name = "billy donka uniform"
	desc = "Candy is dandy, but liquor is quicker!"
	icon_state = "billydonka_s"
	item_state = "billydonka"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/brownoveralls
	name = "brown overalls"
	desc = "The perfect uniform for coal mining."
	icon_state = "b-overalls_s"
	item_state = "b-overalls"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/redoveralls
	name = "red overalls"
	desc = "The perfect uniform for lumberjacks."
	icon_state = "r-overalls_s"
	item_state = "r-overalls"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/casualjanitorsuit
	name = "casual janitor suit"
	desc = "Even the janitor has to take a break from slipping the crew sometimes."
	icon_state = "janitor_suit"
	item_state = "janitor_suit"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	can_adjust = FALSE

/obj/item/clothing/under/yogs/callumsuit
	name = "casual bartender suit"
	desc = "Even the bartender has to take a break from protecting Pun Pun sometimes."
	icon_state = "callum_suit_s"
	item_state = "callum_suit"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/saaland
	name = "golden jumpsuit"
	desc = "Made from 0.01% real gold!"
	icon_state = "saaland_s"
	item_state = "saaland"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/victorianblred
	name = "victorian black and red suit"
	desc = "Oh how eighteen hundreds!"
	icon_state = "victorianblred"
	item_state = "victorianblred"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/victorianredvest
	name = "victorian red and black suit"
	desc = "Oh how eighteen hundreds!"
	icon_state = "victorianredvest"
	item_state = "victorianredvest"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/victorianvest
	name = "victorian black suit"
	desc = "Oh how eighteen hundreds!"
	icon_state = "victorianvest"
	item_state = "victorianvest"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/victorianblackdress
	name = "victorian black dress"
	desc = "Oh how eighteen hundreds!"
	icon_state = "victorianblackdress"
	item_state = "victorianblackdress"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/victorianreddress
	name = "victorian red dress"
	desc = "Oh how eighteen hundreds!"
	icon_state = "victorianreddress"
	item_state = "victorianreddress"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/shitcurity
	name = "shitcurity uniform"
	desc = "For the security members that want to show their true colors."
	icon_state = "altsecurity"
	item_state = "altsecurity"

/obj/item/clothing/under/yogs/victoriouscaptainuniform
	name = "very fancy captain uniform"
	desc = "Ask not the sparrow how the eagle soars!"
	icon_state = "captainfemaleformal_s"
	item_state = "captainfemaleformal"

/obj/item/clothing/under/yogs/zootsuit
	name = "zoot suit"
	desc = "A snazzy purple zoot suit. The name 'Big Papa' is stitched on the inside of the collar."
	icon_state = "zootsuit"
	item_state = "zootsuit"
	can_adjust = 0

/obj/item/clothing/under/yogs/cosby
	name = "tacky sweater"
	desc = "Zip zap zoobity bap!"
	icon_state = "cosby"
	item_state = "cosby"
	can_adjust = 0
