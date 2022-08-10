//rare and valulable gems- designed to eventually be used for archeology, or to be given as opposed to money as loot. Auctioned off at export, or kept as a trophy. -MemedHams

/obj/item/gem
	name = "\improper Gem"
	icon = 'icons/obj/gems.dmi'
	icon_state = "rupee"

	///Have we been analysed with a mining scanner?
	var/analysed = FALSE
	///How many points we grant to whoever discovers us
	var/point_value = 100
	///what's our real name that will show upon discovery? null to do nothing
	var/true_name
	///the message given when you discover this geyser.
	var/analysed_message = null
	///the thing that spawns in the item.
	var/sheet_type = null

/obj/item/gem/attackby(obj/item/item, mob/living/user, params) //Stolen directly from geysers, removed the internal gps
	if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
		return ..()

	if(analysed)
		to_chat(user, span_warning("This gem has already been analysed!"))
		return

	to_chat(user, span_notice("You analyse the precious gemstone!"))
	if(analysed_message)
		to_chat(user, analysed_message)

	analysed = TRUE
	if(true_name)
		name = true_name

	if(isliving(user))
		var/mob/living/living = user

		var/obj/item/card/id/card = living.get_idcard()
		if(card)
			to_chat(user, span_notice("[point_value] mining points have been paid out!"))
			card.mining_points += point_value
			playsound(src, 'sound/machines/ping.ogg', 15, TRUE)

/obj/item/gem/welder_act(mob/living/user, obj/item/I) //Jank code that detects if the gem in question has a sheet_type and spawns the items specifed in it
	if(I.use_tool(src, user, 0, volume=50))
		if(src.sheet_type)
			new src.sheet_type(user.loc)
			to_chat(user, span_notice("You carefully cut [src]."))
			qdel(src)
		else
			to_chat(user, span_notice("You can't seem to cut [src]."))
	return TRUE

/obj/item/gem/rupee
	name = "\improper Ruperium Crystal"
	desc = "An exotic radioactive crystalline compound rarely found in the guts of goldgrubs of lavaland. It looks like you can cut it to obtain usable uranium. Its resonating properties make it highly valued in the creation of niche designer instruments."
	icon = 'icons/obj/gems.dmi'
	icon_state = "rupee"
	materials = list(/datum/material/uranium=20000)
	sheet_type = /obj/item/stack/sheet/mineral/uranium{amount = 10}
	point_value = 300
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/fdiamond
	name = "\improper Frost Diamond"
	desc = "A rare form of crystallized carbon created through the sheer cold and physiology of icewing watchers, an exclusive yet useless form of diamond coveted by those who fancy rarity above all. It looks like its able to be cut into smaller, less valued diamonds."
	icon = 'icons/obj/gems.dmi'
	icon_state = "diamond"
	materials = list(/datum/material/diamond=30000)
	sheet_type = /obj/item/stack/sheet/mineral/diamond{amount = 15}
	point_value = 750
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/amber
	name = "\improper Draconic Amber"
	desc = "The final decompositional result of a dragon's white-hot blood. Cherished by inner-world gemcutters for its soft warmth and faint glow."
	icon = 'icons/obj/gems.dmi'
	icon_state = "amber"
	point_value = 1600
	light_range = 2
	light_power = 2
	light_color = "#FFBF00"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/bloodstone
	name = "\improper Ichorium"
	desc = "A strange substance, known to coalesce in the presence of otherwordly phenomena. Could probably fetch a good price for this."
	icon = 'icons/obj/gems.dmi'
	icon_state = "red"
	point_value = 2000
	light_range = 2
	light_power = 3
	light_color = "#800000"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/phoron
	name = "\improper Stabilized Phoron"
	desc = "An incredibly rare form of crystal that's formed through immense pressure. Famed for its exceptional durability and uncommon beauty. It looks like it could be destructively analyzed to extract the materials within."
	icon = 'icons/obj/gems.dmi'
	icon_state = "phoron"
	materials = list(/datum/material/plasma=80000)
	point_value = 1200
	light_range = 2
	light_power = 2
	light_color = "#62326a"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/void
	name = "\improper Null Crystal"
	desc = "A shard of stellar energy, shaped into crystal. These strange objects occasionally appear spontaneously in the deepest, darkest depths of space. Despite it's incredible value, it seems far lighter than it should be."
	icon = 'icons/obj/gems.dmi'
	icon_state ="void"
	point_value = 1800
	light_range = 2
	light_power = 1
	light_color = "#4785a4"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/dark
	name = "\improper Dark Cube"
	desc = "An ominous cube that glows with power theorized to have been an ancient salt lick that the king keeps in his pockets. It appears to repel magic around it."
	icon = 'icons/obj/gems.dmi'
	icon_state = "dark"
	point_value = 3000
	light_range = 3
	light_power = 3
	light_color = "#380a41"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gem/dark/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, null, null, FALSE)


