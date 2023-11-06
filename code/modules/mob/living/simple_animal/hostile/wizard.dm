/mob/living/simple_animal/hostile/wizard
	name = "Space Wizard"
	desc = "EI NATH?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
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
	del_on_death = TRUE
	footstep_type = FOOTSTEP_MOB_SHOE
	loot = list(
		/obj/effect/mob_spawn/human/corpse/wizard,
		/obj/item/staff,
	)

	var/datum/action/cooldown/spell/pointed/projectile/fireball/fireball
	var/datum/action/cooldown/spell/teleport/radius_turf/blink/blink
	var/datum/action/cooldown/spell/aoe/magic_missile/magic_missile

	var/next_cast = 0

/mob/living/simple_animal/hostile/wizard/Initialize(mapload)
	. = ..()
	var/obj/item/implant/exile/exiled = new /obj/item/implant/exile(src)
	exiled.implant(src)

	fireball = new(src)
	fireball.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	fireball.Grant(src)

	magic_missile = new(src)
	magic_missile.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	magic_missile.Grant(src)

	blink = new(src)
	blink.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	blink.outer_tele_radius = 3
	blink.Grant(src)

/mob/living/simple_animal/hostile/wizard/Destroy()
	QDEL_NULL(fireball)
	QDEL_NULL(magic_missile)
	QDEL_NULL(blink)
	return ..()

/mob/living/simple_animal/hostile/wizard/handle_automated_action()
	. = ..()
	if(target && next_cast < world.time)
		if((get_dir(src, target) in list(SOUTH, EAST, WEST, NORTH)) && fireball.can_cast_spell(FALSE))
			setDir(get_dir(src, target))
			fireball.Trigger(null, target)
			next_cast = world.time + 1 SECONDS
			return

		if(magic_missile.IsAvailable(feedback = FALSE))
			magic_missile.Trigger(null, target)
			next_cast = world.time + 1 SECONDS
			return

		if(blink.IsAvailable(feedback = FALSE)) // Spam Blink when you can
			blink.Trigger(null, src)
			next_cast = world.time + 1 SECONDS
			return

/mob/living/simple_animal/hostile/academywizard //weaker wizard, only knows arcane barrage.
	name = "Academy Student"
	desc = "EI NATH?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
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
	projectiletype = /obj/projectile/magic/arcane_barrage
	projectilesound = 'sound/weapons/emitter.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/wizard, /obj/item/staff)
	del_on_death = 1


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
	projectiletype = /obj/projectile/magic
	var/allowed_projectile_types = list(/obj/projectile/magic/animate, /obj/projectile/magic/runic_honk,
	/obj/projectile/magic/teleport, /obj/projectile/magic/door,
	/obj/projectile/magic/spellblade, /obj/projectile/magic/arcane_barrage)

/mob/living/simple_animal/hostile/academywizard/chaos/Initialize(mapload)
	projectiletype = pick(allowed_projectile_types)
	. = ..()

/mob/living/simple_animal/hostile/academywizard/chaos/Shoot()
	projectiletype = pick(allowed_projectile_types)
	..()

/mob/living/simple_animal/hostile/academywizard/botanist //super weak garbage wizard, for memes
	name = "Academy Botanist"
	desc = "Will destroy you with the power of... making you grow larger?"
	projectiletype = /obj/projectile/magic/runic_resizement
