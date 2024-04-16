/obj/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	armor_flag = ENERGY
	damage_type = BRUTE
	damage = 5
	range = 4
	dismemberment = 20
	demolition_mod = 2 // industrial strength plasma cutter designed to cut things
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/mine_range = 3 //mines this many additional tiles of rock
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter
	impact_type = /obj/effect/projectile/impact/plasma_cutter
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_PURPLE
	light_range = 2

	var/obj/item/gun/energy/plasmacutter/gun
	var/defuse = FALSE
	var/explosive = FALSE

/obj/projectile/plasma/weak
	name = "weak plasma blast"
	icon_state = "plasmacutter_weak"
	damage = 3
	dismemberment = 5
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	mine_range = 0

//yogs begin
/obj/projectile/plasma/Move(atom/newloc, dir)
	. = ..()
	if(istype(newloc,/turf/open/floor/plating/dirt/jungleland))
		var/turf/open/floor/plating/dirt/jungleland/JG = newloc
		JG.spawn_rock()

//yogs end
/obj/projectile/plasma/on_hit(atom/target)
	. = ..()
	if(defuse && istype(target, /turf/closed/mineral/gibtonite))
		var/turf/closed/mineral/gibtonite/gib = target
		gib.defuse()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.attempt_drill(firer, explosive)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE
// yogs begin
	if(istype(target,/obj/structure/flora))
		qdel(target)
		if(mine_range)
			mine_range--
			range++
		if(range > 0)
			return BULLET_ACT_FORCE_PIERCE
// yogs end

/obj/projectile/plasma/adv
	damage = 7
	range = 5
	mine_range = 5

/obj/projectile/plasma/adv/malf
	damage = 20

/obj/projectile/plasma/adv/mega
	range = 7
	mine_range = 7

/obj/projectile/plasma/scatter
	damage = 2
	range = 5
	mine_range = 2
	dismemberment = 0

// Same as the scatter but with automatic defusing
/obj/projectile/plasma/scatter/adv
	defuse = TRUE

// Megafauna loot, possibly best cutter?
/obj/projectile/plasma/scatter/adv/stalwart
	name = "plasma beam"
	icon_state = "plasmacutter_stalwart"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue
	light_color = LIGHT_COLOR_BLUE
	damage_type = STAMINA
	damage = 5
	range = 4
	mine_range = 6
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	var/fauna_damage_bonus = 10
	var/fauna_damage_type = BRUTE

/obj/projectile/plasma/scatter/adv/stalwart/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
			L.apply_damage(fauna_damage_bonus,fauna_damage_type)
			playsound(L, 'sound/weapons/resonator_blast.ogg', 100, 1)

//mega plasma shotgun auto defuses
/obj/projectile/plasma/scatter/adv/mega
	range = 7
	mine_range = 3

/obj/projectile/plasma/adv/mech
	damage = 10
	range = 9
	mine_range = 3

/obj/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 24
	range = 7
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
