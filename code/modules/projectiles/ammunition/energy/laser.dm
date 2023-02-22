/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/item/projectile/beam/laser
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/hellfire
	projectile_type = /obj/item/projectile/beam/laser/hellfire
	e_cost = 130
	select_name = "maim"

/obj/item/ammo_casing/energy/lasergun
	projectile_type = /obj/item/projectile/beam/laser
	e_cost = 83
	select_name = "kill"

/obj/item/ammo_casing/energy/lasergun/old
	projectile_type = /obj/item/projectile/beam/laser
	e_cost = 200
	select_name = "kill"

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/item/projectile/beam/practice
	select_name = "practice"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/item/projectile/beam/scatter
	pellets = 5
	variance = 25
	select_name = "scatter"

/obj/item/ammo_casing/energy/laser/scatter/disabler
	projectile_type = /obj/item/projectile/beam/disabler
	pellets = 3
	variance = 15
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/cyborg
	projectile_type = /obj/item/projectile/beam/laser
	select_name = "kill"
	e_cost = 125

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/item/projectile/beam/laser/heavylaser
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/item/projectile/beam/pulse
	e_cost = 200
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/item/projectile/beam/lasertag/bluetag
	select_name = "bluetag"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/bluetag/hitscan
	projectile_type = /obj/item/projectile/beam/lasertag/bluetag/hitscan

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/item/projectile/beam/lasertag/redtag
	select_name = "redtag"
	harmful = FALSE

/obj/item/ammo_casing/energy/laser/redtag/hitscan
	projectile_type = /obj/item/projectile/beam/lasertag/redtag/hitscan

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/item/projectile/beam/xray
	select_name = "irradiate"
	e_cost = 100
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/xray/optimized
	e_cost = 70 //14 shots

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/item/projectile/beam/anoxia/mindflayer
	select_name = "MINDFUCK"
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/ammo_casing/energy/anoxia
	projectile_type = /obj/item/projectile/beam/anoxia
	select_name = "suffocate"
	e_cost = 50
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/ammo_casing/energy/anoxia/bounce
	projectile_type = /obj/item/projectile/beam/anoxia/bounce
	e_cost = 62