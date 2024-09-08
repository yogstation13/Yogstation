// Metal Smoothing Tables //

/obj/structure/table/halflife
	name = "table"
	desc = "Scream at the coders if you see this."
	buildstack = null
	custom_materials = null
	frame = /obj/item/stack/sheet/metal
	framestack = /obj/item/stack/sheet/metal
	framestackamount = 2
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ

/obj/structure/table/halflife/deconstruction_hints(mob/user)
	return span_notice("You could use a <b>screwdriver</b> or a <b>wrench</b> to take apart [src].")

/obj/structure/table/halflife/metal
	name = "metal table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/halflife/tables/table_metal.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	max_integrity = 225
	smoothing_groups = list(SMOOTH_GROUP_HLTABLES_METAL) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_HLTABLES_METAL)
	frame = /obj/item/stack/sheet/metal

/obj/structure/table/halflife/metal/alt
	desc = "A rounded piece of metal standing on a set of metal legs. It can not move."
	icon = 'icons/obj/halflife/tables/table_metal_alt.dmi'

/obj/structure/table/halflife/metal/grate
	desc = "A grated metal table, like a normal table but can't hold small stuff! Super industrial-y"
	smoothing_groups = list(SMOOTH_GROUP_HLTABLES_METAL) 
	icon = 'icons/obj/halflife/tables/table_metal_grate.dmi'
	max_integrity = 200

/obj/structure/table/halflife/metal/small
	desc = "A small, low down metal table. God only knows why these were sought out after in the old days."
	icon = 'icons/obj/halflife/tables/table_metal_small.dmi'
	smoothing_groups = list(SMOOTH_GROUP_HLTABLES_SMALL)
	canSmoothWith = list(SMOOTH_GROUP_HLTABLES_SMALL)

/obj/structure/table/halflife/metal/heavy
	name = "heavy-duty metal table"
	desc = "A heavy duty metal table, held together by strong rivets and expert engineering, built to hold up to the heaviest of tools."
	icon = 'icons/obj/halflife/tables/table_metal_heavy.dmi'
	max_integrity = 300
	integrity_failure = 0.25
	frame = /obj/item/stack/sheet/metal

// Wooden Smoothing Tables //

/obj/structure/table/halflife/wood
	name = "wood table"
	desc = "A simple wooden table. Good for propping your feet up on dramatically."
	icon = 'icons/obj/halflife/tables/table_wood.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	max_integrity = 150
	smoothing_groups = list(SMOOTH_GROUP_HLTABLES_WOOD)
	canSmoothWith = list(SMOOTH_GROUP_HLTABLES_WOOD)
	frame = /obj/item/stack/sheet/mineral/wood
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2

/obj/structure/table/halflife/wood/bar
	desc = "A somewhat fancy table used at restauraunts of the past. Featuring a simplistic anchored leg design, wow!"
	icon = 'icons/obj/halflife/tables/table_wood_bar.dmi'
	max_integrity = 200

// Table Frames //

/obj/structure/table_frame/halflife
	name = "metal table frame"
	desc = "Four metal legs with four framing rods for a table."
	icon = 'icons/obj/halflife/standalone_tables.dmi'
	icon_state = "tableframe_metal"
	density = TRUE
	anchored = FALSE
	max_integrity = 20
	framestack = /obj/item/stack/sheet/metal
	framestackamount = 2

/obj/structure/table_frame/halflife/wood
	name = "wood table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "tableframe_wood"
	resistance_flags = FLAMMABLE
	framestack = /obj/item/stack/sheet/mineral/wood
	framestackamount = 2

// Player-Made tables //

/obj/structure/table/halflife/metal/constructed
	name = "crude metal table"
	desc = "A crude table made of quality metal. Not too bad, as far as post apocalyptic furniture goes."
	icon = 'icons/obj/halflife/tables/table_metal_built.dmi'
	max_integrity = 140
	smoothing_groups = list(SMOOTH_GROUP_HLTABLES_PLAYER) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_HLTABLES_PLAYER)

/obj/structure/table/halflife/metal/constructed/cobbled
	name = "crude scrap metal table"
	desc = "A crude table made of scrap metal. Doesn't look pretty and seems barely finished, but it does it's job."
	icon = 'icons/obj/halflife/tables/table_metal_built_LQ.dmi'
	max_integrity = 110

/obj/structure/table/halflife/wood/constructed
	name = "crude wood table"
	desc = "A crude wood table of decent quality. It probably won't fall apart any time soon."
	icon = 'icons/obj/halflife/tables/table_wood_built.dmi'
	max_integrity = 120
	smoothing_groups = list(SMOOTH_GROUP_HLTABLES_PLAYER)
	canSmoothWith = list(SMOOTH_GROUP_HLTABLES_PLAYER)

/obj/structure/table/halflife/wood/constructed/cobbled
	name = "crude scrap wood table"
	desc = "A crude wood table made of scrap, low quality wood. About as rickety as you'd expect."
	icon = 'icons/obj/halflife/tables/table_wood_built_LQ.dmi'
	max_integrity = 90

// Metal Non-Smoothing tables //

/obj/structure/table/halflife/no_smooth
	name = "non-smoothing wasteland table"
	desc = "Much like a regular table, except it doesn't smooth. Revolutionary, I know."
	icon = 'icons/obj/halflife/standalone_tables.dmi'
	smoothing_flags = NONE
	canSmoothWith = null

/obj/structure/table/halflife/no_smooth/metal
	name = "metal table"
	desc = "A table, masterfully designed with high-tech to become... round."
	icon_state = "table_metal_round"
	max_integrity = 225

/obj/structure/table/halflife/no_smooth/metal/Initialize(mapload)
	. = ..()
	if(prob(35))
		icon_state = "[initial(icon_state)]-[rand(1,2)]"

// Large tables //

/obj/structure/table/halflife/no_smooth/large
	name = "base class large halflife table"
	desc = "CALL A CODER, CALL A CODER. For ME!"
	icon = 'icons/obj/halflife/64x64_large_furniture.dmi'

/obj/structure/table/halflife/no_smooth/large/Initialize(mapload)
	. = ..()
	if(dir == NORTH)
		bound_width = 64

	if(dir == EAST)
		bound_height = 64

	if(dir == SOUTH)
		bound_width = 64

	if(dir == WEST)
		bound_height = 64

// Metal Large tables /

/obj/structure/table/halflife/no_smooth/large/metal
	name = "metal table"
	desc = "A solid, wide metal table. Nothing about it stands out in particular."
	icon_state = "table_metal_wide"
	max_integrity = 300
	frame = /obj/item/stack/sheet/metal

/obj/structure/table/halflife/no_smooth/large/metal/desk
	name = "metal desk"
	desc = "A solid, wide metal table. Nothing about it stands out in particular."
	icon_state = "desk_metal"

/obj/structure/table/halflife/no_smooth/large/metal/desk/alt
	name = "metal desk"
	desc = "A compact metal desk, used by a wide variety of individuals before the war, once upon a time."
	icon_state = "desk_metal_small"

// Wood Non-Smoothing tables //

/obj/structure/table/halflife/no_smooth/wood
	name = "wood table"
	desc = "A simple round wooden table. You wish you could make something this nice."
	icon_state = "table_wood_round"
	max_integrity = 150
	frame = /obj/item/stack/sheet/mineral/wood

/obj/structure/table/halflife/no_smooth/wood/square
	name = "wood table"
	desc = "A simple squared wooden table. You wish you could make something this nice."
	icon_state = "table_wood_square"

/obj/structure/table/halflife/no_smooth/wood/low
	name = "coffee table"
	desc = "A table that is relatively low to the ground, designed to prop things up on while you sit on your sofa."
	icon_state = "table_wood_low"

/obj/structure/table/halflife/no_smooth/wood/stand
	name = "bed stand"
	desc = "A tall table that is often found beside beds. This one is wood with a basic finish on it. Minimal mold on the inside, impressive!"
	icon_state = "table_wood_stand"

/obj/structure/table/halflife/no_smooth/wood/end
	name = "console end"
	desc = "A separate optional add-on for your Vault-Tec console. More storage for books you never read!"
	icon_state = "table_wood_end"

// Wood Large tables //

/obj/structure/table/halflife/no_smooth/large/wood
	name = "wood table"
	desc = "A large oval shaped wood table. Perfect for displaying the 200 year old family photos you found."
	icon_state = "table_wood_wide_oval"
	max_integrity = 200
	frame = /obj/item/stack/sheet/mineral/wood

/obj/structure/table/halflife/no_smooth/large/wood/square
	desc = "A large rectangular wood table. Very sturdy."
	icon_state = "table_wood_wide_square"

/obj/structure/table/halflife/no_smooth/large/wood/desk
	name = "wood desk"
	desc = "A full size wood desk, used by the pre-war soul lackers of the working world that once was."
	icon_state = "desk_wood"

/obj/structure/table/halflife/no_smooth/large/wood/desk/alt
	name = "wood desk"
	desc = "A compact wood desk, used by a wide variety of individuals before the war, once upon a time."
	icon_state = "desk_wood_small"

/obj/structure/table/halflife/no_smooth/large/wood/stand
	name = "wood console"
	desc = "A smooth Vault-Tec branded console, designed specifically in mind for your brand new Radiation King! But those days are now over. Mostly just looks good in a room."
	icon_state = "stand_wood"

/obj/structure/table/halflife/no_smooth/large/wood/stand/alt
	icon_state = "stand_wood_small"

//Misc tables //

/obj/structure/table/halflife/no_smooth/dice
	name = "dice table"
	desc = "Shoot the dice with your friends. Preferably not literally."
	icon_state = "dice_dirty"
	max_integrity = 150
	frame = /obj/item/stack/sheet/mineral/wood

/obj/structure/table/halflife/no_smooth/dice/pristine
	icon_state = "dice_clean"
	max_integrity = 200

/obj/structure/table/halflife/no_smooth/cable_reel
	name = "cable reel"
	desc = "An old cable reel for holding, you guessed it, cable. Now all it's good for though is holding your stuff."
	icon_state = "cable_reel"
	frame = /obj/item/stack/sheet/mineral/wood

// Misc Large tables //

/obj/structure/table/halflife/no_smooth/large/pool
	name = "pool table"
	desc = "A favourite of students and drunkards alike. Watch out for sharks!"
	icon_state = "table_pool"
	max_integrity = 200
	frame = /obj/item/stack/sheet/mineral/wood

/obj/structure/table/halflife/no_smooth/large/cards
	name = "cards table"
	desc = "Very classy. Reminds you of that time in New Reno..."
	icon_state = "table_cards"

/obj/structure/table/rolling/halflife
	name = "rolling table"
	desc = "A rolling medical table. Extremely useful in a surgical environment."
	icon = 'icons/obj/halflife/standalone_tables.dmi'
	icon_state = "table_rolling"
	max_integrity = 200
	buildstack = null
	custom_materials = null
	frame = /obj/item/stack/sheet/metal
	framestack = /obj/item/stack/sheet/metal
	framestackamount = 2

/obj/structure/table/rolling/halflife/deconstruction_hints(mob/user)
	return
