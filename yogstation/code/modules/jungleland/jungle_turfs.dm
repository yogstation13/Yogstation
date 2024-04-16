/* JUNGLELAND ATMOS REFERENCE FROM IN GAME
Moles: 208 mol
Volume: 2500 L
Pressure: 276.56 kPa
Oxygen: 21.15 % (44 mol)
Nitrogen: 78.85 % (164 mol)
Temperature: 126.85 °C (400 K)
*/


/area/pregen
	name = "Pregenerated Space"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "pregen"
	map_generator = /datum/map_generator/jungleland
	static_lighting = FALSE

	base_lighting_alpha = 255
	has_gravity = TRUE

/area/jungleland
	name = "Jungleland"
	static_lighting = FALSE

	base_lighting_alpha = 255
	outdoors = TRUE
	has_gravity = TRUE
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	outdoors = TRUE
	mining_speed = TRUE

/area/jungleland/explored
	name = "Explored Jungle"

/area/jungleland/ocean
	name = "Toxic Ocean"

/area/jungleland/proper 
	name = "Jungle"

/area/jungleland/toxic_pit 
	name = "Toxic Pit"

/area/jungleland/barren_rocks 
	name = "Barren Rocks"

/area/jungleland/dry_swamp 
	name = "Rocky Beach"

/area/jungleland/dying_forest
	name = "Dying Jungle"

/area/ruin/powered/sinden
	name = "Den of Sin"
	icon_state = "dk_yellow"

/turf/open/floor/plating/dirt/jungleland
	name = "generic jungle land turf"
	desc = "pain"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "jungle"
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/toxic_pit
	icon_state_regular_floor = "jungle" //used to remember what icon state the tile should have by default
	icon_regular_floor = 'yogstation/icons/turf/floors/jungle.dmi' //used to remember what icon the tile should have by default
	icon_plating = "jungle"
	var/can_spawn_ore = TRUE
	var/ore_present = ORE_EMPTY
	var/spawn_overlay = TRUE
	var/can_mine = TRUE 

/turf/open/floor/plating/dirt/jungleland/drill_act(obj/item/mecha_parts/mecha_equipment/drill/drill)
	if(drill.do_after_mecha(src, 10 / drill.drill_level))
		spawn_rock()
		drill.move_ores()

/turf/open/floor/plating/dirt/jungleland/proc/spawn_rock()
	if(ore_present == ORE_EMPTY || !can_spawn_ore)
		return
	can_spawn_ore = FALSE
	if(spawn_overlay)
		add_overlay(image(icon='yogstation/icons/obj/jungle.dmi',icon_state="dug_spot",layer=BELOW_OBJ_LAYER))
	var/datum/ore_patch/ore = GLOB.jungle_ores[ ore_present ]
	if(ore)
		ore.spawn_at(src)
		for(var/i in 0 to 2)
			new /obj/item/stack/ore/glass(src)

/turf/open/floor/plating/dirt/jungleland/tool_act(mob/living/user, obj/item/I, tool_type)
	if(tool_type != TOOL_MINING && tool_type != TOOL_SHOVEL)
		return ..()
	
	if(ore_present == ORE_EMPTY)
		return ..()

	if(!can_spawn_ore)
		return ..()
	
	if(!can_mine)
		return

	can_mine = FALSE
	I.play_tool_sound(user)	
	if(!do_after(user,10 SECONDS * I.toolspeed,src))
		can_mine = TRUE
		return ..()
	can_mine = TRUE
	spawn_rock()
	
/turf/open/floor/plating/dirt/jungleland/ex_act(severity, target)
	if(can_spawn_ore && prob( (severity/3)*100  ))	
		spawn_rock()
/turf/open/floor/plating/dirt/jungleland/barren_rocks
	name = "rocky surface"
	desc = "Surface covered by rocks, pebbles and stones."
	icon_state = "barren_rocks"
	icon_plating = "barren_rocks"
	icon_state_regular_floor = "barren_rocks" 

/turf/open/floor/plating/dirt/jungleland/toxic_rocks
	name = "mud"
	desc = "Liquid mixed with dirt"
	icon_state = "toxic_rocks"
	icon_plating = "toxic_rocks"
	icon_state_regular_floor = "toxic_rocks" 

/turf/open/floor/plating/dirt/jungleland/dry_swamp
	name = "sand"
	desc = "mounds upon mounds of sand"
	icon_state = "dry_swamp"
	icon_plating = "dry_swamp"
	icon_state_regular_floor = "dry_swamp" 

/turf/open/floor/plating/dirt/jungleland/toxic_pit
	name = "shallow mud"
	desc = "pit of shallow mud"
	icon_state = "toxic_pit"
	icon_plating = "toxic_pit"
	icon_state_regular_floor = "toxic_pit" 

/turf/open/floor/plating/dirt/jungleland/dry_swamp1
	name = "dried surface"
	desc = "it used to be a riverbed"
	icon_state = "dry_swamp1"
	icon_plating = "dry_swamp1"
	icon_state_regular_floor = "dry_swamp1" 

/turf/open/floor/plating/dirt/jungleland/dying_forest
	name = "deep sand"
	desc = "this sand runs deep into the earth"
	icon_state = "dying_forest"
	icon_plating = "dying_forest"
	icon_state_regular_floor = "dying_forest" 

/turf/open/floor/plating/dirt/jungleland/jungle
	name = "forest litter"
	desc = "rich in minerals, this feeds the flora and fauna of the jungle"
	icon_state = "jungle"
	icon_plating = "jungle"
	icon_state_regular_floor = "jungle" 

/turf/open/floor/plating/dirt/jungleland/quarry
	name = "loose quarry stones"
	desc = "there are some mineral underneath"
	icon_state = "quarry"
	icon_plating = "quarry"
	icon_state_regular_floor = "quarry"
	spawn_overlay = FALSE

/turf/open/floor/plating/dirt/jungleland/quarry/Initialize()
	. = ..()
	ore_present = pick(GLOB.quarry_ores)

/turf/open/floor/plating/dirt/jungleland/quarry/spawn_rock()
	if(prob(75))
		for(var/i in 2 to rand(4,10))
			new /obj/item/stack/ore/glass/basalt()
	else 
		. = ..()
		ore_present = pick(GLOB.quarry_ores)
	can_spawn_ore = TRUE

/turf/open/water/toxic_pit
	name = "sulphuric pit"
	desc = "Very toxic"
	color = "#00c167"
	slowdown = 2
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/toxic_pit

/turf/open/water/toxic_pit/Entered(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return
		
	var/mob/living/carbon/human/humie = AM
	var/chance = (100 - humie.getarmor(null,BIO)) * 0.33

	if(AM.movement_type & (FLYING|FLOATING) || !AM.has_gravity() || HAS_TRAIT(AM,TRAIT_SULPH_PIT_IMMUNE))
		return

	if(isipc(humie) && prob(chance))
		humie.adjustFireLoss(33)
		to_chat(humie,span_danger("the sulphuric solution burns and singes into your plating!"))
		return 

	if(HAS_TRAIT(humie,TRAIT_TOXIMMUNE) || HAS_TRAIT(humie,TRAIT_TOXINLOVER))
		return
	
	if(prob(chance * 0.33))
		humie.reagents.add_reagent(/datum/reagent/toxic_metabolities,7.5)
	
	if(prob((chance * 0.15 ) + 10 ))
		humie.acid_act(5,7.5)

/turf/open/water/safe/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/water/deep_toxic_pit
	name = "deep sulphuric pit"
	desc = "Extraordinarly toxic"
	color = "#004700"
	slowdown = 4
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/deep_toxic_pit

/turf/open/water/deep_toxic_pit/Entered(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return

	var/mob/living/carbon/human/humie = AM
	
	if(AM.movement_type & (FLYING|FLOATING) || !AM.has_gravity())
		return

	if(isipc(humie))
		humie.adjustFireLoss(33)
		to_chat(humie,span_danger("the sulphuric solution burns and singes into your plating!"))
		return

	if(HAS_TRAIT(humie,TRAIT_TOXIMMUNE) || HAS_TRAIT(humie,TRAIT_TOXINLOVER))
		return
	
	humie.reagents.add_reagent(/datum/reagent/toxic_metabolities,15)
	humie.adjustFireLoss(33)
	humie.acid_act(15,15)

/turf/open/floor/wood/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plating/ashplanet/rocky/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plating/jungle_baseturf
	baseturfs = /turf/open/floor/plating/dirt/jungleland/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plating/jungle_baseturf/dying
	baseturfs = /turf/open/floor/plating/dirt/jungleland/dying_forest

/turf/open/indestructible/grass/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plasteel/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/closed/mineral/ash_rock/jungle
	turf_type = /turf/open/floor/plating/jungle_baseturf
	baseturfs = /turf/open/floor/plating/jungle_baseturf
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/closed/mineral/ash_rock/jungle/deepjungle
	turf_type = /turf/open/floor/plating/dirt/jungleland/jungle
	baseturfs = /turf/open/floor/plating/dirt/jungleland/jungle

/turf/closed/mineral/ash_rock/jungle/swamp
	turf_type = /turf/open/floor/plating/dirt/jungleland/toxic_pit
	baseturfs = /turf/open/floor/plating/dirt/jungleland/toxic_pit

/turf/open/water/tar_basin
	name = "tar basin"
	color = "#680047"
	slowdown = 4
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/tar_basin


/turf/open/floor/plating/dirt/jungleland/obsidian 
	name =	"obsidian ground"
	desc = "Dark crystaline flooring"
	icon_state = "obsidian"

/turf/closed/obsidian
	name = "obsidian wall"
	desc = "Obsidian wal tearing out of the earth, it reflects light in all the colours you could ever imagine, and you can see something shining brightly within it. You can't quite seem to destroy it with a pickaxe, but maybe an explosion mau suffice?"
	icon = 'yogstation/icons/turf/walls/obsidian.dmi'	
	icon_state = "wall"
	smoothing_groups = SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MINERAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	var/list/explosion_threshold = list(EXPLODE_DEVASTATE, EXPLODE_HEAVY, EXPLODE_LIGHT)
	var/list/droppable_gems = list(
		null = 25,
		/obj/item/gem/topaz = 5,
		/obj/item/gem/emerald = 5,
		/obj/item/gem/sapphire = 5,
		/obj/item/gem/ruby = 5,
		/obj/item/gem/purple = 2,
		/obj/item/gem/phoron = 1
	)

/turf/closed/obsidian/ex_act(severity, target)
	. = ..()
	if(severity in explosion_threshold)
		drop_gems()
		ChangeTurf(/turf/open/floor/plating/dirt/jungleland/obsidian)

/turf/closed/obsidian/proc/drop_gems()
	var/type = pickweight(droppable_gems)
	if(type)
		new type(src)

/turf/closed/obsidian/hard 
	name = "tough obsidian wall"
	icon = 'yogstation/icons/turf/walls/obsidian_hard.dmi'
	explosion_threshold = list(EXPLODE_DEVASTATE, EXPLODE_HEAVY)
	droppable_gems = list (
		/obj/item/gem/topaz = 1,
		/obj/item/gem/emerald = 2,
		/obj/item/gem/sapphire = 3,
		/obj/item/gem/ruby = 4,
		/obj/item/gem/purple = 5,
		/obj/item/gem/phoron = 5
	)

/turf/open/lava/smooth/jungle_surface
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/jungle_surface
