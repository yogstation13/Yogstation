// CHAPLAIN CUSTOM ARMORS //
/obj/item/choice_beacon/holy
	name = "armaments beacon"
	desc = "Contains a set of armaments for the chaplain."

/obj/item/choice_beacon/holy/canUseBeacon(mob/living/user)
	if(user.mind && user.mind.holy_role)
		return ..()
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return FALSE

/obj/item/choice_beacon/holy/generate_display_names()
	var/static/list/holy_item_list
	if(!holy_item_list)
		holy_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/holy)
		for(var/V in templist)
			var/atom/A = V
			holy_item_list[initial(A.name)] = A
	return holy_item_list

/obj/item/choice_beacon/holy/spawn_option(obj/choice,mob/living/M)
	if(!GLOB.holy_armor_type)
		..()
		playsound(src, 'sound/effects/pray_chaplain.ogg', 40, 1)
		SSblackbox.record_feedback("tally", "chaplain_armor", 1, "[choice]")
		GLOB.holy_armor_type = choice
	else
		to_chat(M, span_warning("A selection has already been made. Self-Destructing..."))
		return

/obj/item/storage/box/holy
	name = "Templar Kit"

/obj/item/storage/box/holy/PopulateContents()
	new /obj/item/clothing/head/helmet/chaplain(src)
	new /obj/item/clothing/suit/armor/riot/chaplain(src)

/obj/item/clothing/suit/armor/riot/chaplain
	name = "crusader armour"
	desc = "A maintained, full set of plate armor, complete with a tabard. Heavy, but robust."
	icon_state = "knight_templar"
	item_state = "knight_templar"
	armor = list(MELEE = 60, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 2, RAD = 0, FIRE = 0, ACID = 50) //Medieval armor was exceptional against melee weaponry and shrapnel, as highlighted by breastplate usage during the Napoleonic Wars, but suffered against ballistics
	slowdown = 0.3 //Have you ever worn full plate armor before
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/box/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	blocks_shove_knockdown = FALSE

/obj/item/clothing/head/helmet/chaplain
	name = "crusader helmet"
	desc = "A steel helmet that was often worn by religious knights of ages past. Deus Vult!"
	icon_state = "knight_templar"
	item_state = "knight_templar"
	armor = list(MELEE = 45, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 30, BIO = 2, RAD = 0, FIRE = 0, ACID = 50)
	slowdown = 0.05 //See above
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null

/obj/item/storage/box/holy/student
	name = "Profane Scholar Kit"

/obj/item/storage/box/holy/student/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/studentuni(src)
	new /obj/item/clothing/head/helmet/chaplain/cage(src)

/obj/item/clothing/suit/armor/riot/chaplain/studentuni
	name = "student robe"
	desc = "The uniform of a bygone institute of learning. These robes whip the user into a speedy fervour at the cost of making them more vulnerable to damage."
	icon_state = "studentuni"
	item_state = "studentuni"
	armor = list(MELEE = -25, BULLET = -15, LASER = -15, ENERGY = -10, BOMB = -10, BIO = -2, RAD = 0, FIRE = 0, ACID = 0) //Speed-inspiring robes
	slowdown = -0.2
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/head/helmet/chaplain/cage
	name = "insightful cage"
	desc = "A cage that restrains the will of the self, allowing one to see the profane world for what it is. The user will be more vulnerable but move slightly faster."
	mob_overlay_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "cage"
	item_state = "cage"
	armor = list(MELEE = -15, BULLET = -10, LASER = -10, ENERGY = -5, BOMB = -5, BIO = -2, RAD = 0, FIRE = 0, ACID = 0)
	slowdown = -0.1 //very statistically significant
	worn_x_dimension = 64
	worn_y_dimension = 64
	dynamic_hair_suffix = ""

/obj/item/storage/box/holy/sentinel
	name = "Stone Sentinel Kit"

/obj/item/storage/box/holy/sentinel/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/ancient(src)
	new /obj/item/clothing/head/helmet/chaplain/ancient(src)

/obj/item/clothing/suit/armor/riot/chaplain/ancient
	name = "ancient armour"
	desc = "Armor worn by ancient ethereal protectors, covered head to toe in the stone of Borealia's cavernous walls. Tiny holes in the armor permit the light of their skin to peer through."
	icon_state = "knight_ancient"
	item_state = "knight_ancient"
	armor = list(MELEE = 65, BULLET = 20, LASER = 15, ENERGY = 15, BOMB = 20, BIO = 4, RAD = 0, FIRE = 40, ACID = 60) //LITERALLY made of stone; this is BASICALLY miner armor with HARD slowdown
	slowdown = 0.4 //ROCK; full set is slowdown equal to firesuit

/obj/item/clothing/head/helmet/chaplain/ancient
	name = "ancient helmet"
	desc = "A helmet worn by a relict ethereal knight."
	icon_state = "knight_ancient"
	item_state = "knight_ancient"
	armor = list(MELEE = 50, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 15, BIO = 4, RAD = 0, FIRE = 40, ACID = 60)
	slowdown = 0.1 //Pretty sure riot is just strictly better because lmao

/obj/item/storage/box/holy/witchhunter
	name = "Witchhunter Kit"

/obj/item/storage/box/holy/witchhunter/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/witchhunter(src)
	new /obj/item/clothing/head/helmet/chaplain/witchunter_hat(src)

/obj/item/clothing/suit/armor/riot/chaplain/witchhunter
	name = "witch hunter garb"
	desc = "An armored coat sported by the Inquisition, a holy organization that arose in response to humanity's contact with the otherworldly supernatural."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	armor = list(MELEE = 40, BULLET = 10, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 40) //Basically faster Dark Templar but you lose out on a lot of the non-melee armor
	slowdown = 0.1
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/head/helmet/chaplain/witchunter_hat
	name = "witch hunter hat"
	desc = "The hat of a respected inquisitor, layered with protective plating."
	icon_state = "witchhunterhat"
	item_state = "witchhunterhat"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 40)
	slowdown = 0
	flags_cover = HEADCOVERSEYES

/obj/item/storage/box/holy/follower
	name = "Followers of the Chaplain Kit"

/obj/item/storage/box/holy/follower/PopulateContents()
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/leader(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)

/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "follower hoodie"
	desc = "Hoodie made for acolytes of the chaplain."
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/box/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant)
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood

/obj/item/clothing/head/hooded/chaplain_hood
	name = "follower hood"
	desc = "Hood made for acolytes of the chaplain."
	icon_state = "chaplain_hood"
	armor = list(MELEE = 5, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD //Is this redundant?
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/chaplain_hoodie/leader
	name = "leader hoodie"
	desc = "Hoodie worn by apocalyptic cult leaders. Bling water not included."
	icon_state = "chaplain_hoodie_leader"
	item_state = "chaplain_hoodie_leader"
	armor = list(MELEE = 25, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 25) //I don't know specially layered clothing?
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood/leader

/obj/item/clothing/head/hooded/chaplain_hood/leader
	name = "leader hood"
	desc = "The cowl of a fanatical prodigy."
	icon_state = "chaplain_hood_leader"
	armor = list(MELEE = 15, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 25)

/obj/item/storage/box/holy/darktemplar
	name = "Founder Kit of the Black Templars"

/obj/item/storage/box/holy/darktemplar/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar/chap(src)

/obj/item/clothing/suit/space/hardsuit/darktemplar
	name = "Black Templar armor"
	desc = "Apprentice-rated power armor developed by the Black Templars, a Confederate militant group that cuts out corruption and treachery without mercy."
	icon_state = "darktemplar-follower0"
	item_state = "darktemplar-follower0"
	cold_protection = null
	min_cold_protection_temperature = null
	heat_protection = null
	max_heat_protection_temperature = null
	clothing_flags = null
	armor = list(MELEE = 25, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 15, BIO = 30, RAD = 30, FIRE = 70, ACID = 50) //Crappier version of the standard armor
	slowdown = 0.25 //No sir you are NOT a space marine you are in CHUNKY power armor
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/box/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/darktemplar

/obj/item/clothing/suit/space/hardsuit/darktemplar/chap
	name = "Black Templar chaplain battle armor"
	desc = "A suit of power armor worn by the zealous Black Templars. A fear-inspiring sight for heretics and dissenters."
	icon_state = "darktemplar-chaplain0"
	item_state = "darktemplar-chaplain0"
	armor = list(MELEE = 40, BULLET = 15, LASER = 25, ENERGY = 15, BOMB = 25, BIO = 60, RAD = 40, FIRE = 90, ACID = 80) //Hilariously similar to the goliath cloak but with slowdown because lmao; ultimately made of more advanced, sci-fi materials
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/darktemplar

/obj/item/clothing/head/helmet/space/hardsuit/darktemplar
	name = "Black Templar helmet"
	desc = "A custom-made Black Templar helmet. The words 'Contempt is Armour' and 'Purge Heresy' are written on the side."
	icon_state = "darktemplar-follower1"
	item_state = "darktemplar-follower1"
	armor = list(MELEE = 20, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 30, RAD = 30, FIRE = 70, ACID = 50)
	cold_protection = null
	min_cold_protection_temperature = null
	heat_protection = null
	max_heat_protection_temperature = null
	flash_protect = 0 //We are not giving four mfers free flash protection
	clothing_flags = null
	strip_delay = 50
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/darktemplar/chap
	name = "Black Templar chaplain battle helmet"
	desc = "A custom-made Black Templar chaplain battle helmet. The words 'Excise Corruption' and 'The Razebringer Protects' are written on the side."
	icon_state = "darktemplar-chaplain1"
	item_state = "darktemplar-chaplain1"
	armor = list(MELEE = 30, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 20, BIO = 60, RAD = 40, FIRE = 90, ACID = 80)
