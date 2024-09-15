/datum/action/cooldown/spell/pointed/projectile/fireball/bouncy
	name = "Fire Ball"
	desc = "This spell fires a ball of fire at a target. Watch out for collateral."
	button_icon = 'monkestation/icons/obj/weapons/guns/projectiles.dmi'
	button_icon_state = "fire_ball"

	active_msg = "You prepare to cast your fire ball spell!"
	deactive_msg = "You extinguish your fire ball... for now."
	cooldown_reduction_per_rank = -1 SECONDS //bit too strong otherwise
	spell_max_level = 3
	projectile_type = /obj/projectile/magic/fire_ball

/datum/action/cooldown/spell/pointed/projectile/fireball/bouncy/level_spell(bypass_cap)
	. = ..()
	projectile_amount++ //become the schoolyard bully
	unset_after_click = FALSE
	if(spell_level == spell_max_level)
		projectiles_per_fire++

/datum/action/cooldown/spell/pointed/projectile/fireball/bouncy/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	to_fire.ricochets_max += spell_level - 1
	if(iteration > 1)
		to_fire.set_angle(dir2angle(user.dir) + rand(-15, 15))
