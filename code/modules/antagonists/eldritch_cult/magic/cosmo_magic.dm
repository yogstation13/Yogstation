/datum/action/cooldown/spell/jaunt/ethereal_jaunt/cosmic
	name = "Cosmic Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "space_crawl"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	exit_jaunt_sound = null
	jaunt_duration = 1.5 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/space_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/space_shift/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/cosmic/do_steam_effects()
	return

/obj/effect/temp_visual/dir_setting/space_shift
	name = "space_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "space_explosion"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/dir_setting/space_shift/out
	icon_state = "space_explosion"

/datum/action/cooldown/spell/cosmic_rune
	name = "Cosmic Rune"
	desc = "Creates a cosmic rune at your position, only two can exist at a time. Invoking one rune transports you to the other."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_rune"

	sound = 'sound/magic/forcewall.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	invocation = "ST'R R'N'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	/// Storage for the first rune.
	var/datum/weakref/first_rune
	/// Storage for the second rune.
	var/datum/weakref/second_rune
	/// Rune removal effect.
	var/obj/effect/rune_remove_effect = /obj/effect/temp_visual/cosmic_rune_fade

/datum/action/cooldown/spell/cosmic_rune/cast(atom/cast_on)
	. = ..()
	var/obj/effect/cosmic_rune/first_rune_resolved = first_rune?.resolve()
	var/obj/effect/cosmic_rune/second_rune_resolved = second_rune?.resolve()
	if(first_rune_resolved && second_rune_resolved)
		var/obj/effect/cosmic_rune/new_rune = new /obj/effect/cosmic_rune(get_turf(cast_on))
		new rune_remove_effect(get_turf(first_rune_resolved))
		QDEL_NULL(first_rune_resolved)
		first_rune = WEAKREF(second_rune_resolved)
		second_rune = WEAKREF(new_rune)
		second_rune_resolved.link_rune(new_rune)
		new_rune.link_rune(second_rune_resolved)
		return
	if(!first_rune_resolved)
		first_rune = make_new_rune(get_turf(cast_on), second_rune_resolved)
		return
	if(!second_rune_resolved)
		second_rune = make_new_rune(get_turf(cast_on), first_rune_resolved)

/// Returns a weak reference to a new rune, linked to an existing rune if provided
/datum/action/cooldown/spell/cosmic_rune/proc/make_new_rune(turf/target_turf, obj/effect/cosmic_rune/other_rune)
	var/obj/effect/cosmic_rune/new_rune = new /obj/effect/cosmic_rune(target_turf)
	if(other_rune)
		other_rune.link_rune(new_rune)
		new_rune.link_rune(other_rune)
	return WEAKREF(new_rune)

/// A rune that allows you to teleport to the location of a linked rune.
/obj/effect/cosmic_rune
	name = "cosmic rune"
	desc = "A strange rune, that can instantly transport people to another location."
	anchored = TRUE
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "cosmic_rune"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	/// The other rune this rune is linked with
	var/datum/weakref/linked_rune
	/// Effect for when someone teleports
	var/obj/effect/rune_effect = /obj/effect/temp_visual/rune_light

/obj/effect/cosmic_rune/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/hand_of_god_structures.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cosmic", silicon_image)

/obj/effect/cosmic_rune/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/effect/cosmic_rune/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!linked_rune)
		balloon_alert(user, "no linked rune!")
		fail_invoke()
		return
	if(!(user in get_turf(src)))
		balloon_alert(user, "not close enough!")
		fail_invoke()
		return
	if(user.has_status_effect(/datum/status_effect/star_mark))
		balloon_alert(user, "blocked by star mark!")
		fail_invoke()
		return
	invoke(user)

/// For invoking the rune
/obj/effect/cosmic_rune/proc/invoke(mob/living/user)
	var/obj/effect/cosmic_rune/linked_rune_resolved = linked_rune?.resolve()
	new rune_effect(get_turf(src))
	do_teleport(
		user,
		get_turf(linked_rune_resolved),
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
		asoundin = 'sound/magic/cosmic_energy.ogg',
		asoundout = 'sound/magic/cosmic_energy.ogg',
	)
	for(var/mob/living/person_on_rune in get_turf(src))
		if(person_on_rune.has_status_effect(/datum/status_effect/star_mark))
			do_teleport(person_on_rune, get_turf(linked_rune_resolved), no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	new rune_effect(get_turf(linked_rune_resolved))

/// For if someone failed to invoke the rune
/obj/effect/cosmic_rune/proc/fail_invoke()
	visible_message(span_warning("The rune pulses with a small flash of purple light, then returns to normal."))
	var/oldcolor = rgb(255, 255, 255)
	color = rgb(150, 50, 200)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 5)

/// For linking a new rune
/obj/effect/cosmic_rune/proc/link_rune(datum/weakref/new_rune)
	linked_rune = WEAKREF(new_rune)

/obj/effect/cosmic_rune/Destroy()
	var/obj/effect/cosmic_rune/linked_rune_resolved = linked_rune?.resolve()
	if(linked_rune_resolved)
		linked_rune_resolved.unlink_rune()
	return ..()

/// Used for unlinking the other rune if this rune gets destroyed
/obj/effect/cosmic_rune/proc/unlink_rune()
	linked_rune = null

/obj/effect/temp_visual/cosmic_rune_fade
	name = "cosmic rune"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "cosmic_rune_fade"
	layer = SIGIL_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/cosmic_rune_fade/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/hand_of_god_structures.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cosmic", silicon_image)

/obj/effect/temp_visual/rune_light
	name = "cosmic rune"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "cosmic_rune_light"
	layer = SIGIL_LAYER
	anchored = TRUE
	duration = 5

/obj/effect/temp_visual/rune_light/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/obj/hand_of_god_structures.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cosmic", silicon_image)


/datum/action/cooldown/spell/pointed/projectile/star_blast
	name = "Star Blast"
	desc = "This spell fires a disk with cosmic energies at a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_blast"

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to cast your star blast!"
	deactive_msg = "You stop swirling cosmic energies from the palm of your hand... for now."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball

/obj/projectile/magic/star_ball
	name = "star ball"
	icon_state = "star_ball"
	damage = 20
	damage_type = BURN
	speed = 1
	range = 100
	knockdown = 4 SECONDS
	/// Effect for when the ball hits something
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3

/obj/projectile/magic/star_ball/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)

/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)

/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	for(var/turf/cast_turf as anything in get_turfs())
		new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

/obj/projectile/magic/star_ball/proc/get_turfs()
	return list(get_turf(src), pick(get_step(src, NORTH), get_step(src, SOUTH)), pick(get_step(src, EAST), get_step(src, WEST)))

/datum/action/cooldown/spell/conjure/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "This spell generates a 3x3 domain of cosmic fields. \
		Creatures up to 7 tiles away will also receive a star mark."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_domain"

	sound = 'sound/magic/cosmic_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 45 SECONDS

	invocation = "C'SM'S 'XP'ND"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	summon_amount = 9
	summon_radius = 1
	summon_type = list(/obj/effect/forcefield/cosmic_field)
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 7
	/// Effect for when the spell triggers
	var/obj/effect/expansion_effect = /obj/effect/temp_visual/cosmic_domain
	/// If the heretic is ascended or not
	var/ascended = FALSE

/datum/action/cooldown/spell/conjure/cosmic_expansion/cast(mob/living/cast_on)
	new expansion_effect(get_turf(cast_on))
	for(var/mob/living/nearby_mob in range(star_mark_range, cast_on))
		if(cast_on == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)
	if (ascended)
		for(var/turf/cast_turf as anything in get_turfs(get_turf(cast_on)))
			new /obj/effect/forcefield/cosmic_field(cast_turf)
	return ..()

/datum/action/cooldown/spell/conjure/cosmic_expansion/proc/get_turfs(turf/target_turf)
	var/list/target_turfs = list()
	for (var/direction as anything in GLOB.cardinals)
		target_turfs += get_ranged_target_turf(target_turf, direction, 2)
		target_turfs += get_ranged_target_turf(target_turf, direction, 3)
	return target_turfs


/datum/action/cooldown/spell/conjure/cosmic_expansion/large

	name = "Cosmic Domain"
	desc = "This spell generates a domain of cosmic fields. \
		Creatures up to 7 tiles away will also receive a star mark."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "cosmic_domain"

	sound = 'sound/magic/cosmic_expansion.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "C'SM'S 'XP'ND"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	summon_amount = 24
	summon_radius = 2
	summon_type = list(/obj/effect/forcefield/cosmic_field)


/datum/action/cooldown/spell/pointed/projectile/star_blast/ascended

	name = "Celestial Blast"
	desc = "This spell fires a disk with cosmic energies at a target."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_blast"

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 10 SECONDS

	invocation = "R'T'T' ST'R!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to cast your celestial blast!"
	deactive_msg = "You stop swirling cosmic energies from the palm of your hand... for now."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball/ascended


/obj/projectile/magic/star_ball/ascended
	name = "celestial ball"
	icon_state = "star_ball"
	damage = 40
	damage_type = BURN
	speed = 1
	range = 100
	knockdown = 8 SECONDS
