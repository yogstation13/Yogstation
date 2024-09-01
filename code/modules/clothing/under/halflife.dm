/obj/item/clothing/under/combine
	armor = list(MELEE = 20, BULLET = 20, LASER = 20,ENERGY = 20, BOMB = 20, BIO = 20, RAD = 20, FIRE = 30, ACID = 30, WOUND = 10)
	strip_delay = 50
	can_adjust = FALSE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	worn_icon = 'icons/mob/clothing/uniform/halflife.dmi'

/obj/item/clothing/under/combine/civilprotection
	name = "civil protection jumpsuit"
	desc = "Full-body suit which includes light kevlar weaving to provide extra protection."
	icon_state = "civilprotection"
	item_state = "syndicate-black"

/obj/item/clothing/under/combine/civilprotection/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/movement/civilprotection/gear1.ogg',\
												'sound/movement/civilprotection/gear2.ogg',\
												'sound/movement/civilprotection/gear3.ogg',\
												'sound/movement/civilprotection/gear4.ogg',\
												'sound/movement/civilprotection/gear5.ogg',\
												'sound/movement/civilprotection/gear6.ogg'), 75)

/obj/item/clothing/under/combine/overwatch
	name = "overwatch jumpsuit"
	desc = "Full-body suit which includes kevlar weaving to provide extra protection."
	icon_state = "rsecurity"
	item_state = "r_suit"
	armor = list(MELEE = 25, BULLET = 25, LASER = 25,ENERGY = 25, BOMB = 25, BIO = 30, RAD = 30, FIRE = 30, ACID = 30, WOUND = 15)

/obj/item/clothing/under/combine/overwatch/red
	name = "overwatch jumpsuit"
	desc = "Red full-body suit which includes kevlar weaving to provide extra protection."
	icon_state = "rsecurity"
	item_state = "r_suit"

/obj/item/clothing/under/combine/overwatch/elite
	name = "overwatch jumpsuit"
	desc = "Full-body reinforced suit which includes kevlar weaving to provide extra protection."
	icon_state = "rsecurity"
	item_state = "r_suit"
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 30, BIO =40, RAD = 40, FIRE = 40, ACID = 30, WOUND = 15)

/obj/item/clothing/under/citizen
	name = "citizen jumpsuit"
	desc = "Full-body blue suit for the common citizen."
	icon_state = "rsecurity"
	item_state = "r_suit"
	can_adjust = FALSE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	worn_icon = 'icons/mob/clothing/uniform/security.dmi'
