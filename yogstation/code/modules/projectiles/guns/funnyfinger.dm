/obj/item/gun/magic/funnyfinger
	name = "Funny finger"
	desc = "For telling people just how much you like them."
	icon = 'yogstation/icons/obj/projectiles.dmi'
	icon_state = "funnyfinger"
	force = 0
	item_flags = DROPDEL
	max_charges = 1
	recharge_rate = 4
	ammo_type = /obj/item/ammo_casing/magic/funnyfinger
	fire_sound_volume = 0
	suppressed = TRUE
	suppressed_sound = null
	attack_verb = list("insulted", "cursed at", "swore at")

/obj/item/gun/magic/funnyfinger/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='warning'>Slow down. Your kind words lose their meaning if you use them too often.</span>")

/obj/item/ammo_casing/magic/funnyfinger
	projectile_type = /obj/item/projectile/magic/funnyfinger
	firing_effect_type = null

/obj/item/projectile/magic/funnyfinger
	name = "funny finger"
	icon = 'yogstation/icons/obj/projectiles.dmi'
	icon_state = "funnyfinger"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	suppressed = TRUE
	damage = 0
	nodamage = TRUE
	speed = 4
	nondirectional_sprite = TRUE

/obj/item/projectile/magic/funnyfinger/on_hit(atom/target, blocked = FALSE)
	var/mob/living/L = target
	to_chat(L, "<span class='userdanger'>Someone wanted you to know just how much they appreciate what you're doing!</span>")