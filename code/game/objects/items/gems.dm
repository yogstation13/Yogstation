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
	desc = "A radioactive, crystalline compound rarely found in the goldgrubs. While able to be cut into sheets of uranium, the mineral's true value is in its resonating, humming properties, often sought out by ethereal musicians to work into their gem-encrusted instruments. As a result, they fetch a fine price in most exchanges."
	icon = 'icons/obj/gems.dmi'
	icon_state = "rupee"
	materials = list(/datum/material/uranium=20000)
	sheet_type = /obj/item/stack/sheet/mineral/uranium{amount = 10}
	point_value = 300
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/fdiamond
	name = "\improper Frost Diamond"
	desc = "A unique diamond that is produced within icewing watchers. Rarely used in traditional marriage bands, various gemstone companies now try to effect a monopoly on it, to little success. It looks like it can be cut into smaller sheets of diamond ore."
	icon = 'icons/obj/gems.dmi'
	icon_state = "diamond"
	materials = list(/datum/material/diamond=30000)
	sheet_type = /obj/item/stack/sheet/mineral/diamond{amount = 15}
	point_value = 750
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/amber
	name = "\improper Draconic Amber"
	desc = "A brittle, strange mineral that forms when an ash drake's blood hardens after death. Cherished by gemcutters for its faint glow and unique, soft warmth. Poacher tales whisper of the dragon's strength being bestowed to one that wears a necklace of this amber, though such rumors are fictitious."
	icon = 'icons/obj/gems.dmi'
	icon_state = "amber"
	point_value = 1600
	light_range = 2
	light_power = 2
	light_color = "#FFBF00"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/bloodstone
	name = "\improper Ichorium"
	desc = "A weird, sticky substance, known to coalesce in the presence of otherwordly phenomena. While shunned by most spiritual groups, this gemstone has unique ties to the occult which find it handsomely valued by mysterious patrons."
	icon = 'icons/obj/gems.dmi'
	icon_state = "red"
	point_value = 2000
	light_range = 2
	light_power = 3
	light_color = "#800000"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/gem/phoron
	name = "\improper Stabilized Phoron"
	desc = "A soft, glowing crystal only found in the deepest veins of plasma. Famed for its exceptional durability and uncommon beauty: widely considered to be a jackpot by mining crews. It looks like it could be destructively analyzed to extract the condensed materials within."
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
	desc = "A shard of stellar, crystallized energy. These strange objects occasionally appear spontaneously in areas where the bluespace fabric is largely unstable. Its surface gives a light jolt to those who touch it. Despite its size, it's absurdly light."
	icon = 'icons/obj/gems.dmi'
	icon_state ="void"
	point_value = 1800
	light_range = 2
	light_power = 1
	light_color = "#4785a4"
	w_class = WEIGHT_CLASS_TINY

/obj/item/gem/dark
	name = "\improper Dark Cube"
	desc = "An ominous cube that glows with an unnerving aura, seeming to hungrily draw in the space around it. Its only known property is that of anti-magic."
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


