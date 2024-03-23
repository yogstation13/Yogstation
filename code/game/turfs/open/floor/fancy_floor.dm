/* In this file:
 * Wood floor
 * Grass floor
 * Fake Basalt
 * Carpet floor
 * Fake pits
 * Fake space
 */

/turf/open/floor/wood
	desc = "Stylish dark wood."
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	turf_flags = NO_RUST
	flammability = 3 // yikes, better put that out quick

/turf/open/floor/wood/broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/open/floor/wood/examine(mob/user)
	. = ..()
	. += span_notice("There's a few <b>screws</b> and a <b>small crack</b> visible.")

/turf/open/floor/wood/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	return pry_tile(I, user)

/turf/open/floor/wood/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/tool = user.is_holding_item_of_type(/obj/item/screwdriver)
	if(!tool)
		tool = user.is_holding_item_of_type(/obj/item/crowbar)
	if(!tool)
		return
	var/turf/open/floor/plating/P = pry_tile(tool, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/wood/pry_tile(obj/item/C, mob/user, silent = FALSE)
	C.play_tool_sound(src, 80)
	return remove_tile(user, silent, (C.tool_behaviour == TOOL_SCREWDRIVER))

/turf/open/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE, force_plating)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken planks."))
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, span_notice("You unscrew the planks."))
			spawn_tile()
		else
			if(user && !silent)
				to_chat(user, span_notice("You forcefully pry off the planks, destroying them in the process."))
	return make_plating(force_plating)

/turf/open/floor/wood/parquet
	icon_state = "wood-parquet"
	floor_tile = /obj/item/stack/tile/wood/parquet

/turf/open/floor/wood/parquet/broken_states()
	return list("wood-parquet-broken", "wood-parquet-broken2", "wood-parquet-broken3", "wood-parquet-broken4", "wood-parquet-broken5", "wood-parquet-broken6", "wood-parquet-broken7")

/turf/open/floor/wood/tile
	icon_state = "wood-tile"
	floor_tile = /obj/item/stack/tile/wood/tile

/turf/open/floor/wood/tile/broken_states()
	return list("wood-tile-broken", "wood-tile-broken2", "wood-tile-broken3")

/turf/open/floor/wood/large
	icon_state = "wood-large"
	floor_tile = /obj/item/stack/tile/wood/large

/turf/open/floor/wood/large/broken_states()
	return list("wood-tile-broken", "wood-tile-broken2", "wood-tile-broken3")

/turf/open/floor/wood/cold
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS

/turf/open/floor/wood/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/wood/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/wood/broken
	icon_state = "wood-broken"
	broken = TRUE

/turf/open/floor/wood/broken/two
	icon_state = "wood-broken2"

/turf/open/floor/wood/broken/three
	icon_state = "wood-broken3"

/turf/open/floor/wood/broken/four
	icon_state = "wood-broken4"

/turf/open/floor/wood/broken/five
	icon_state = "wood-broken5"

/turf/open/floor/wood/broken/six
	icon_state = "wood-broken6"

/turf/open/floor/wood/broken/seven
	icon_state = "wood-broken7"

/turf/open/floor/wood/lavaland/broken
	icon_state = "wood-broken"
	broken = TRUE

/turf/open/floor/wood/lavaland/broken/two
	icon_state = "wood-broken2"

/turf/open/floor/wood/lavaland/broken/three
	icon_state = "wood-broken3"

/turf/open/floor/wood/lavaland/broken/four
	icon_state = "wood-broken4"

/turf/open/floor/wood/lavaland/broken/five
	icon_state = "wood-broken5"

/turf/open/floor/wood/lavaland/broken/six
	icon_state = "wood-broken6"

/turf/open/floor/wood/lavaland/broken/seven
	icon_state = "wood-broken7"

/turf/open/floor/wood/airless/broken
	icon_state = "wood-broken"
	broken = TRUE

/turf/open/floor/wood/airless/broken/two
	icon_state = "wood-broken2"

/turf/open/floor/wood/airless/broken/three
	icon_state = "wood-broken3"

/turf/open/floor/wood/airless/broken/four
	icon_state = "wood-broken4"

/turf/open/floor/wood/airless/broken/five
	icon_state = "wood-broken5"

/turf/open/floor/wood/airless/broken/six
	icon_state = "wood-broken6"

/turf/open/floor/wood/airless/broken/seven
	icon_state = "wood-broken7"

/turf/open/floor/wood/cold/broken
	icon_state = "wood-broken"
	broken = TRUE

/turf/open/floor/wood/cold/broken/two
	icon_state = "wood-broken2"

/turf/open/floor/wood/cold/broken/three
	icon_state = "wood-broken3"

/turf/open/floor/wood/cold/broken/four
	icon_state = "wood-broken4"

/turf/open/floor/wood/cold/broken/five
	icon_state = "wood-broken5"

/turf/open/floor/wood/cold/broken/six
	icon_state = "wood-broken6"

/turf/open/floor/wood/cold/broken/seven
	icon_state = "wood-broken7"

/turf/open/floor/wood/parquet/broken
	icon_state = "wood-parquet-broken"
	broken = TRUE

/turf/open/floor/wood/parquet/broken/two
	icon_state = "wood-parquet-broken2"

/turf/open/floor/wood/parquet/broken/three
	icon_state = "wood-parquet-broken3"

/turf/open/floor/wood/parquet/broken/four
	icon_state = "wood-parquet-broken4"

/turf/open/floor/wood/parquet/broken/five
	icon_state = "wood-parquet-broken5"

/turf/open/floor/wood/parquet/broken/six
	icon_state = "wood-parquet-broken6"

/turf/open/floor/wood/parquet/broken/seven
	icon_state = "wood-parquet-broken7"

/turf/open/floor/wood/tile/broken
	icon_state = "wood-tile-broken"
	broken = TRUE

/turf/open/floor/wood/tile/broken/two
	icon_state = "wood-tile-broken2"

/turf/open/floor/wood/tile/broken/three
	icon_state = "wood-tile-broken3"

/turf/open/floor/wood/large/broken
	icon_state = "wood-large-broken"
	broken = TRUE

/turf/open/floor/wood/large/broken/two
	icon_state = "wood-large-broken2"

/turf/open/floor/wood/large/broken/three
	icon_state = "wood-large-broken3"

/turf/open/floor/bamboo
	desc = "A bamboo mat with a decorative trim."
	icon = 'icons/turf/floors/bamboo_mat.dmi'
	icon_state = "mat-255"
	base_icon_state = "mat"
	floor_tile = /obj/item/stack/tile/bamboo
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_BAMBOO_FLOOR
	canSmoothWith = SMOOTH_GROUP_BAMBOO_FLOOR
	flags_1 = NONE
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/floor/bamboo/broken_states()
	return list("bamboodamaged")

/turf/open/floor/bamboo/broken
	icon_state = "damaged"
	broken = TRUE

/turf/open/floor/grass
	name = "grass patch"
	desc = "You can't tell if this is real grass or just cheap plastic imitation."
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/ore_type = /obj/item/stack/ore/glass
	var/turfverb = "uproot"
	tiled_dirt = FALSE
	flammability = 2 // california simulator

/turf/open/floor/grass/broken_states()
	return list("sand")

/turf/open/floor/grass/Initialize(mapload)
	. = ..()
	if(src.type == /turf/open/floor/grass) //don't want grass subtypes getting the icon state,
		icon_state = "grass[rand(1,4)]"
		update_appearance()

/turf/open/floor/grass/attackby(obj/item/C, mob/user, params)
	if((C.tool_behaviour == TOOL_SHOVEL) && params)
		new ore_type(src, 2)
		user.visible_message("[user] digs up [src].", span_notice("You [turfverb] [src]."))
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		make_plating()
	if(..())
		return

/turf/open/floor/grass/snow
	gender = PLURAL
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	desc = "Looks cold."
	icon_state = "snow"
	ore_type = /obj/item/stack/sheet/mineral/snow
	planetary_atmos = TRUE
	floor_tile = null
	initial_gas_mix = FROZEN_ATMOS
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	flammability = -5 // negative flammability, makes fires deplete much faster

/turf/open/floor/grass/snow/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/grass/snow/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/grass/snow/basalt //By your powers combined, I am captain planet
	gender = NEUTER
	name = "volcanic floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	ore_type = /obj/item/stack/ore/glass/basalt
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	slowdown = 0

/turf/open/floor/grass/snow/basalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)

/turf/open/floor/grass/snow/safe
	planetary_atmos = FALSE


/turf/open/floor/grass/fakebasalt //Heart is not a real planeteer power
	name = "aesthetic volcanic flooring"
	desc = "Safely recreated turf for your hellplanet-scaping."
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	floor_tile = /obj/item/stack/tile/basalt
	ore_type = /obj/item/stack/ore/glass/basalt
	turfverb = "dig up"
	slowdown = 0
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/grass/fakebasalt/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		set_basalt_light(src)


/turf/open/floor/carpet
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET
	canSmoothWith = SMOOTH_GROUP_CARPET
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	flammability = 3 // this will be abused and i am all for it

/turf/open/floor/carpet/examine(mob/user)
	. = ..()
	. += span_notice("There's a <b>small crack</b> on the edge of it.")

/turf/open/floor/carpet/Initialize(mapload)
	. = ..()
	update_appearance()

/turf/open/floor/carpet/update_icon(updates=ALL)
	. = ..()
	if(!. || !(updates & UPDATE_SMOOTHING))
		return
	if(!broken && !burnt)
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
	else
		make_plating()
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH_NEIGHBORS(src)


/turf/open/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	floor_tile = /obj/item/stack/tile/carpet/black
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_BLACK

/turf/open/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	floor_tile = /obj/item/stack/tile/carpet/blue
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_BLUE

/turf/open/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	floor_tile = /obj/item/stack/tile/carpet/cyan
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_CYAN
	canSmoothWith = SMOOTH_GROUP_CARPET_CYAN

/turf/open/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	floor_tile = /obj/item/stack/tile/carpet/green
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_GREEN
	canSmoothWith = SMOOTH_GROUP_CARPET_GREEN

/turf/open/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	floor_tile = /obj/item/stack/tile/carpet/orange
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ORANGE
	canSmoothWith = SMOOTH_GROUP_CARPET_ORANGE

/turf/open/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	floor_tile = /obj/item/stack/tile/carpet/purple
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_PURPLE
	canSmoothWith = SMOOTH_GROUP_CARPET_PURPLE

/turf/open/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	floor_tile = /obj/item/stack/tile/carpet/red
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_RED
	canSmoothWith = SMOOTH_GROUP_CARPET_RED

/turf/open/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	floor_tile = /obj/item/stack/tile/carpet/royalblack
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLACK

/turf/open/floor/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	floor_tile = /obj/item/stack/tile/carpet/royalblue
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLUE

/turf/open/floor/carpet/executive
	name = "executive carpet"
	icon = 'icons/turf/floors/carpet_executive.dmi'
	icon_state = "executive_carpet-255"
	base_icon_state = "executive_carpet"
	floor_tile = /obj/item/stack/tile/carpet/executive
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_EXECUTIVE
	canSmoothWith = SMOOTH_GROUP_CARPET_EXECUTIVE

/turf/open/floor/carpet/stellar
	name = "stellar carpet"
	icon = 'icons/turf/floors/carpet_stellar.dmi'
	icon_state = "stellar_carpet-255"
	base_icon_state = "stellar_carpet"
	floor_tile = /obj/item/stack/tile/carpet/stellar
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_STELLAR
	canSmoothWith = SMOOTH_GROUP_CARPET_STELLAR

/turf/open/floor/carpet/donk
	name = "Donk Co. carpet"
	icon = 'icons/turf/floors/carpet_donk.dmi'
	icon_state = "donk_carpet-255"
	base_icon_state = "donk_carpet"
	floor_tile = /obj/item/stack/tile/carpet/donk
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_DONK
	canSmoothWith = SMOOTH_GROUP_CARPET_DONK

/turf/open/floor/carpet/narsie_act(force, ignore_mobs, probability = 20)
	. = (prob(probability) || force)
	for(var/I in src)
		var/atom/A = I
		if(ignore_mobs && ismob(A))
			continue
		if(ismob(A) || .)
			A.narsie_act()

/turf/open/floor/carpet/break_tile()
	broken = TRUE
	update_appearance()

/turf/open/floor/carpet/burn_tile()
	burnt = TRUE
	update_appearance()

/turf/open/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE


/turf/open/floor/fakepit
	desc = "A clever illusion designed to look like a bottomless pit."
	icon = 'icons/turf/floors/chasms.dmi'
	icon_state = "chasms-0"
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_TURF_CHASM
	canSmoothWith = SMOOTH_GROUP_TURF_CHASM
	tiled_dirt = FALSE

/turf/open/floor/fakepit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	plane = PLANE_SPACE
	tiled_dirt = FALSE
	damaged_dmi = 'icons/turf/space.dmi'

/turf/open/floor/fakespace/broken_states()
	return list("damaged")

/turf/open/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	generate_space_underlay(underlay_appearance, asking_turf)
	return TRUE
