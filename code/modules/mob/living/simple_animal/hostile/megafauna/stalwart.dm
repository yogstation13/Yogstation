/mob/living/simple_animal/hostile/megafauna/stalwart
	name = "stalwart"
	desc = "A graceful, floating automaton. It emits a soft hum."
	health = "3000"
	maxHealth = "3000"
	attacktext = "zaps"
	attacksound = 'sound/effects/empulse.ogg'
	icon_state = "stalwart"
	icon_living = "stalwart"
	icon_dead = ""
	friendly = "scans"
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	speak_emote = list("screeches")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	move_to_delay = 5
	ranged = TRUE
	del_on_death = TRUE
	pixel_x = -16
	internal_type = /obj/item/gps/internal/stalwart
	loot = list(/obj/structure/closet/crate/sphere/stalwart)
	deathmessage = "erupts into blue flame, and screeches before violently shattering."
	deathsound = 'borg_deathsound.ogg'
	internal_type = /obj/item/gps/internal/stalwart

	attack_action_types = list(/datum/action/innate/megafauna_attack/lava_nade,
							   /datum/action/innate/megafauna_attack/energy_pike,
							   /datum/action/innate/megafauna_attack/charge,
							   /datum/action/innate/megafauna_attack/backup)


//Projectiles and such

/obj/item/gps/internal/stalwart
	icon_state = null
	gpstag = "Ancient Signal"
	desc = "Bzz bizzop boop blip beep"
	invisibility = 100

/obj/item/projectile/stalpike
	name = "energy pike"
	icon_state = "arcane_barrage"
	damage = 20
	armour_penetration = 100
	speed = 5
	eyeblur = 0
	damage_type = BURN
	pass_flags = PASSTABLE
	color = "#6CA4E3"

/obj/item/projectile/stalnade
	name = "volatile orb"
	icon_state = "wipe"
	damage = 0

/mob/living/simple_animal/hostile/megafauna/stalwart/devour(mob/living/L)
	visible_message("<span class='danger'>[src] melts [L]!</span>")
	L.dust()

/obj/item/gun/energy/plasmacutter/adv/robocutter
	name = "energized powercutter"
	desc = "Ripped out of an ancient machine, this self-recharging cutter is unmatched."
	fire_delay = 4
	icon_state = "robocutter"
	selfcharge = 1