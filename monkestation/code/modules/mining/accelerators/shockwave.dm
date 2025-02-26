/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "Quite frankly, we have no idea how the Mining Research and Development team came up with this one, all we know is that alot of \
	beer was involved. This proto-kinetic design will slam the ground, creating a shockwave around the user, with the same power as the base PKA.\
	The only downside is the lowered mod capacity, the lack of range it offers, and the higher cooldown, but its pretty good for clearing rocks."
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "kineticshockwave"
	base_icon_state = "kineticshockwave"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	can_bayonet = FALSE
	max_mod_capacity = 60
	pin = /obj/item/firing_pin/explorer/unremovable

/obj/item/ammo_casing/energy/kinetic/shockwave
	projectile_type = /obj/projectile/kinetic/shockwave
	pellets = 8
	variance = 360
	fire_sound = 'sound/weapons/gun/general/cannon.ogg'

/obj/projectile/kinetic/shockwave
	name = "concussive kinetic force"
	damage = 5 //turning this down since miners are using it to point blank enemies. might not be enough damage to break walls anymore but /shrug. until we can fix shitcode to prevent the shockwave from being able to do a point blank, this is all I can do.
	range = 1

/obj/item/firing_pin/explorer/unremovable
	pin_removable = FALSE
