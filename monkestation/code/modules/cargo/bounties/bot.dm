/datum/bounty/item/bot/cleanbot_jr //JR. models to prevent them from mass selling station cleanbots
	name = "Scrubs Junior., PA"
	description = "Medical is looking worse than the kitchen cold room and janitors are nowhere to be found. We need a cleanbot for medical before the Chief Medical Officer has a breakdown."
	reward = CARGO_CRATE_VALUE * 2.5
	wanted_types = list(/mob/living/basic/bot/cleanbot/medbay/jr = TRUE)

/datum/bounty/item/bot/floorbot
	name = "Floorbot"
	description = "Out last floorbot went haywire and removed all our floors. So we need another floorbot to replace the priors issues."
	reward = CARGO_CRATE_VALUE * 3
	wanted_types = list(/mob/living/simple_animal/bot/floorbot = TRUE)

/datum/bounty/item/bot/honkbot
	name = "Honkbot"
	description = "Mr. Gigglesworth birthday is around the corner and we didn't get a present. Ship us off a honkbot to giftwrap please."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/mob/living/simple_animal/bot/secbot/honkbot = TRUE)

/datum/bounty/item/bot/firebot
	name = "Firebot"
	description = "An assistant waving around some license broke into atmospherics and its now all on fire. Send us a Firebot before the gas fire leaks further."
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/mob/living/simple_animal/bot/firebot = TRUE)
