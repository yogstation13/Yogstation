/obj/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	armor_flag = BULLET
	hitsound_wall = SFX_RICOCHET
	sharpness = SHARP_POINTY
	impact_effect_type = /obj/effect/temp_visual/impact_effect
	shrapnel_type = /obj/item/shrapnel/bullet
	embedding = list(embed_chance=20, fall_chance=2, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=3, rip_time=10)
	wound_bonus = 0
	wound_falloff_tile = -5
	embed_falloff_tile = -3

	light_system = OVERLAY_LIGHT
	light_outer_range = 1.25
	light_power = 1
	light_color = COLOR_VERY_SOFT_YELLOW
	light_on = TRUE

	speed = 0.4 //twice as fast

/obj/projectile/bullet/smite
	name = "divine retribution"
	damage = 10
