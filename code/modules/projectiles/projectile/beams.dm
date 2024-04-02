/obj/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	wound_bonus = -20
	bare_wound_bonus = 10
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	armor_flag = LASER
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_color = LIGHT_COLOR_RED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80
	reflectable = REFLECT_NORMAL

/obj/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser
	wound_bonus = -30
	bare_wound_bonus = 40
	var/fire_hazard = FALSE

//overclocked laser, does a bit more damage but has much higher wound power (-0 vs -20)
/obj/projectile/beam/laser/hellfire
	name = "hellfire laser"
	damage = 25
	wound_bonus = 0
	speed = 0.6 // higher power = faster, that's how light works right
	fire_hazard = TRUE

/obj/projectile/beam/laser/hellfire/Initialize(mapload)
	. = ..()
	transform *= 2

/obj/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	wound_bonus = 10
	fire_hazard = TRUE
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/M = target
		M.ignite_mob()
	else if(isturf(target))
		impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall
	if(fire_hazard)
		var/turf/open/target_turf = get_turf(target)
		if(istype(target_turf))
			target_turf.ignite_turf(rand(8, 16))
	return ..()

/obj/projectile/beam/weak
	damage = 15
	armour_penetration = 50

/obj/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = TRUE

/obj/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 5

/obj/projectile/beam/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	damage = 10
	irradiate = 300
	range = 15
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINES | PASSSTRUCTURE | PASSDOOR

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 30
	damage_type = STAMINA
	armor_flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/projectile/beam/disabler/bounce
	name = "bouncing disabler ball"
	icon_state = "omnibouncer"
	damage = 20
	ricochets_max = 5
	ricochet_chance = 100

/obj/projectile/beam/disabler/bounce/check_ricochet_flag(atom/A)
	return TRUE //whatever it is, we bounce on it

/obj/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	demolition_mod = 6 // it has three settings, and they are all DESTROY.
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/beam/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/turf/open/target_turf = get_turf(target)
	if(istype(target_turf))
		target_turf.ignite_turf(rand(8, 22), "blue")

/obj/projectile/beam/pulse/shotgun
	damage = 40

/obj/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = FALSE)
	life -= 10
	if(life > 0)
		. = BULLET_ACT_FORCE_PIERCE
	..()

/obj/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	wound_bonus = -40
	bare_wound_bonus = 70
	demolition_mod = 2.4 // industrial laser, strong but not quite enough for reinforced walls
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/projectile/beam/emitter/singularity_pull()
	return //don't want the emitters to miss

/obj/projectile/beam/emitter/pulse
	name = "overcharged emitter beam"
	icon_state = "u_laser"
	damage = 50 // EVEN MORE power for the SM
	range = 250 // More power means longer range
	demolition_mod = 4 // too powerful for its own good, CAN destroy reinforced walls
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	armor_flag = LASER
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/lasertag/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && ishuman(target)) //Anyone who knows the cheaters that held up objects to block their tag position knows that adding the block check to this is valid
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)
	return ..()

/obj/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

/obj/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message(span_danger("[M] explodes into a shower of gibs!"))
		M.gib()

/obj/projectile/beam/grimdark
	pass_flags = NONE
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	name = "plasma blast"
	icon_state = "blue_laser"
	damage = 50
	wound_bonus = 0
	speed = 1.4 // plasma ball slow

/obj/projectile/beam/grimdark/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

/obj/projectile/beam/grimdark/pistol
	damage = 35

/obj/projectile/beam/laser/lasgun
	name = "Las bolt"
	icon_state = "las_laser"
	speed = 0.8

/obj/projectile/beam/laser/lasgun/longlas
	damage = 25

/obj/projectile/beam/laser/lasgun/laspistol
	damage = 15

/obj/projectile/beam/laser/lasgun/hotshot
	damage = 30
	wound_bonus = -5

/// BFG
/obj/projectile/beam/bfg
	name = "searing rod"
	icon_state = "lava"
	damage = 35
	light_power = 2
	light_color = "#ffff00"
	speed = 1

/obj/projectile/beam/bfg/Range()
	. = ..()
	for(var/atom/movable/passed in range(1, src))
		if(passed == src)
			continue
		if(isliving(passed))
			var/mob/living/m_passed = passed
			m_passed.apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
			new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(m_passed))
		else
			passed.fire_act(460, 100)
