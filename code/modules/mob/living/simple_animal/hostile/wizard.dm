/mob/living/simple_animal/hostile/wizard
	name = "Space Wizard"
	desc = "EI NATH?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 3
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg' // this is only here so i can recommit this
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	faction = list(ROLE_WIZARD)
	sentience_type = SENTIENCE_BOSS
	status_flags = CANPUSH
	
	retreat_distance = 3 //out of fireball range
	minimum_distance = 3
	del_on_ = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/wizard,
				/obj/item/staff)

	var/obj/effect/proc_holder/spell/aimed/fireball/fireball = null
	var/obj/effect/proc_holder/spell/targeted/turf_teleport/blink/blink = null
	var/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/mm = null

	var/next_cast = 0

	do_footstep = TRUE

/mob/living/simple_animal/hostile/wizard/Initialize()
	. = ..()
	fireball = new /obj/effect/proc_holder/spell/aimed/fireball
	fireball.clothes_req = 0
	fireball.human_req = 0
	fireball.player_lock = 0
	AddSpell(fireball)
	implants += new /obj/item/implant/exile(src)

	mm = new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	mm.clothes_req = 0
	mm.human_req = 0
	mm.player_lock = 0
	AddSpell(mm)

	blink = new /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	blink.clothes_req = 0
	blink.human_req = 0
	blink.player_lock = 0
	blink.outer_tele_radius = 3
	AddSpell(blink)

/mob/living/simple_animal/hostile/wizard/handle_automated_action()
	. = ..()
	if(target && next_cast < world.time)
		if((get_dir(src,target) in list(SOUTH,EAST,WEST,NORTH)) && fireball.cast_check(0,src)) //Lined up for fireball
			src.setDir(get_dir(src,target))
			fireball.perform(list(target), user = src)
			next_cast = world.time + 10 //One spell per second
			return .
		if(mm.cast_check(0,src))
			mm.choose_targets(src)
			next_cast = world.time + 10
			return .
		if(blink.cast_check(0,src)) //Spam Blink when you can
			blink.choose_targets(src)
			next_cast = world.time + 10
			return .

/mob/living/simple_animal/hostile/academywizard //weaker wizard, only knows arcane barrage.
	name = "Academy Student"
	desc = "EI NATH?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speak_chance = 0
	turns_per_move = 3
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg' 
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	faction = list(ROLE_WIZARD)
	sentience_type = SENTIENCE_BOSS
	status_flags = CANPUSH
	ranged = 1
	retreat_distance = 4
	minimum_distance = 4
	projectiletype = /obj/item/projectile/magic/arcane_barrage
	projectilesound = 'sound/weapons/emitter.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/wizard, /obj/item/staff)
	del_on_ = 1


/mob/living/simple_animal/hostile/academywizard/soldier //tougher than students, and their bullets go through anti-magic, but still can't use any real spells.
	name = "Wizard Soldier"
	desc = "A wizard with a gun?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "wizardsoldier"
	icon_living = "wizardsoldier"
	icon_dead = "wizard_dead"
	maxHealth = 125
	health = 125
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 10
	retreat_distance = 1
	minimum_distance = 1
	projectiletype = null
	casingtype = /obj/item/ammo_casing/a762/enchanted
	projectilesound = 'sound/weapons/rifleshot.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/wizard, /obj/item/gun/ballistic/rifle/boltaction/enchanted/oneuse)

/mob/living/simple_animal/hostile/academywizard/chaos //chaotic wizard, not too powerful overall
	name = "Chaos Wizard"
	desc = "Unfortunately, he cannot Chaos Control."
	projectiletype = /obj/item/projectile/magic
	var/allowed_projectile_types = list(/obj/item/projectile/magic/animate, /obj/item/projectile/magic/runic_honk,
	/obj/item/projectile/magic/teleport, /obj/item/projectile/magic/door,
	/obj/item/projectile/magic/spellblade, /obj/item/projectile/magic/arcane_barrage)

/mob/living/simple_animal/hostile/academywizard/chaos/Initialize()
	projectiletype = pick(allowed_projectile_types)
	. = ..()

/mob/living/simple_animal/hostile/academywizard/chaos/Shoot()
	projectiletype = pick(allowed_projectile_types)
	..()

/mob/living/simple_animal/hostile/academywizard/botanist //super weak garbage wizard, for memes
	name = "Academy Botanist"
	desc = "Will destroy you with the power of... making you grow larger?"
	projectiletype = /obj/item/projectile/magic/runic_resizement
