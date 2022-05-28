
GLOBAL_LIST_EMPTY(parasites) //all currently existing/living guardians
GLOBAL_LIST_INIT(guardian_projectile_damage, list(
	1 = 2,    // F
	2 = 4,    // D
	3 = 6.5,  // C
	4 = 10,   // B
	5 = 17.5, // A
))

#define GUARDIAN_HANDS_LAYER 1
#define GUARDIAN_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("hisses")
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC, MOB_SPIRIT)
	bubble_icon = "guardian"
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	movement_type = FLYING // Immunity to chasms and landmines, etc.
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	healable = FALSE //don't brusepack the guardian
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5) //how much damage from each damage type we transfer to the owner
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage_lower = 15
	melee_damage_upper = 15
	AIStatus = AI_OFF
	hud_type = /datum/hud/guardian
	var/list/barrier_images = list()
	var/custom_name = FALSE
	var/atk_cooldown = 10
	var/range = 10
	var/cooldown = 0
	var/datum/mind/summoner
	var/toggle_button_type = /obj/screen/guardian/ToggleMode
	var/datum/guardianname/namedatum = new/datum/guardianname()
	var/datum/guardian_stats/stats
	var/summoner_visible = TRUE
	var/battlecry = "AT"
	var/do_temp_anchor = TRUE
	var/temp_anchored_to_owner = FALSE
	var/berserk = FALSE
	var/requiem = FALSE
	// ability stuff below
	var/transforming = FALSE

/mob/living/simple_animal/hostile/guardian/Initialize(mapload, theme)
	GLOB.parasites += src
	setthemename(theme)
	battlecry = pick("ORA", "MUDA", "DORA", "ARRI", "VOLA", "AT")
	return ..()

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if (berserk)
		return ..()
	if (summoner?.current)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner.current)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if (summoner?.current)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if (summoner?.current.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Destroy()
	GLOB.parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/cut_barriers()
	if (client)
		for (var/image/I in barrier_images)
			client.images -= I
			qdel(I)
		barrier_images.Cut()

/mob/living/simple_animal/hostile/guardian/proc/setup_barriers()
	cut_barriers()
	if (!summoner?.current || !client || !is_deployed() || (range <= 1 || (stats && stats.range <= 1)) || get_dist_euclidian(summoner.current, src) < (range - world.view))
		return
	var/sx = summoner.current.x
	var/sy = summoner.current.y
	var/sz = summoner.current.z
	if (sx - range - 1 < 1 || sx + range + 1 > world.maxx || sy - range - 1 < 1 || sy + range + 1 > world.maxy)
		return
	for (var/turf/T in getline(locate(sx - range, sy + range + 1, sz), locate(sx + range, sy + range + 1, sz)))
		barrier_images += image('yogstation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, SOUTH)
	for (var/turf/T in getline(locate(sx - range, sy - range - 1, sz), locate(sx + range, sy - range - 1, sz)))
		barrier_images += image('yogstation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, NORTH)
	for (var/turf/T in getline(locate(sx - range - 1, sy - range, sz), locate(sx - range - 1, sy + range, sz)))
		barrier_images += image('yogstation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, EAST)
	for (var/turf/T in getline(locate(sx + range + 1, sy - range, sz), locate(sx + range + 1, sy + range, sz)))
		barrier_images += image('yogstation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, WEST)
	barrier_images += image('yogstation/icons/effects/effects.dmi', locate(sx - range - 1 , sy + range + 1, sz), "barrier", ABOVE_LIGHTING_LAYER, SOUTHEAST)
	barrier_images += image('yogstation/icons/effects/effects.dmi', locate(sx + range + 1, sy + range + 1, sz), "barrier", ABOVE_LIGHTING_LAYER, SOUTHWEST)
	barrier_images += image('yogstation/icons/effects/effects.dmi', locate(sx + range + 1, sy - range - 1, sz), "barrier", ABOVE_LIGHTING_LAYER, NORTHWEST)
	barrier_images += image('yogstation/icons/effects/effects.dmi', locate(sx - range - 1, sy - range - 1, sz), "barrier", ABOVE_LIGHTING_LAYER, NORTHEAST)
	for (var/image/I in barrier_images)
		I.layer = ABOVE_LIGHTING_PLANE
		I.plane = FLOOR_PLANE
		client.images += I

/mob/living/simple_animal/hostile/guardian/proc/setthemename(pickedtheme) //set the guardian's theme to something cool!
	if (!pickedtheme)
		pickedtheme = pick("magic", "tech", "carp")
	var/list/possible_names = list()
	switch(pickedtheme)
		if ("magic")
			for (var/type in (subtypesof(/datum/guardianname/magic) - namedatum.type))
				possible_names += new type
		if ("tech")
			for (var/type in (subtypesof(/datum/guardianname/tech) - namedatum.type))
				possible_names += new type
		if ("carp")
			for (var/type in (subtypesof(/datum/guardianname/carp) - namedatum.type))
				possible_names += new type
	namedatum = pick(possible_names)
	updatetheme(pickedtheme)

/mob/living/simple_animal/hostile/guardian/proc/updatetheme(theme) //update the guardian's theme to whatever its datum is; proc for adminfuckery
	name = "[namedatum.prefixname] [namedatum.suffixcolor]"
	real_name = "[name]"
	icon_living = "[namedatum.parasiteicon]"
	icon_state = "[namedatum.parasiteicon]"
	icon_dead = "[namedatum.parasiteicon]"
	bubble_icon = "[namedatum.bubbleicon]"

	if (namedatum.stainself)
		add_atom_colour(namedatum.color, FIXED_COLOUR_PRIORITY)

	//Special case holocarp, because #snowflake code
	if (theme == "carp")
		speak_emote = list("gnashes")
		desc = "A mysterious fish that stands by its charge, ever vigilant."

		attacktext = "bites"
		attack_sound = 'sound/weapons/bite.ogg'


/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	. = ..()
	if (mind)
		mind.name = "[real_name]"
	if (client?.prefs)
		gender = client.prefs.gender
	if (berserk)
		return
	if (!summoner?.current)
		to_chat(src, span_holoparasite(span_bold("For some reason, somehow, you have no summoner. Please report this bug immediately.")))
		return
	to_chat(src, span_holoparasite("You are <font color=\"[namedatum.color]\"><b>[real_name]</b></font>, bound to serve [summoner.current.real_name]."))
	to_chat(src, span_holoparasite("You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with [summoner.current.p_them()] privately there."))
	to_chat(src, span_holoparasite("While personally invincible, you will die if [summoner.current.real_name] does, and any damage dealt to you will have a portion passed on to [summoner.current.p_them()] as you feed upon [summoner.current.p_them()] to sustain yourself."))
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	. = ..()
	update_health_hud() //we need to update all of our health displays to match our summoner and we can't practically give the summoner a hook to do it
	med_hud_set_health()
	med_hud_set_status()
	if (berserk || stat == DEAD)
		return
	if (!QDELETED(summoner) && !QDELETED(summoner.current))
		if (summoner.current.stat == DEAD)
			if (transforming)
				GoBerserk()
			else
				forceMove(summoner.current)
				to_chat(src, span_userdanger("Your summoner has died!"))
				visible_message(span_bolddanger("[src] dies along with its user!"))
				summoner.current.visible_message(span_bolddanger("[summoner.current]'s body is completely consumed by the strain of sustaining [src]!"))
				for (var/obj/item/W in summoner.current)
					if (!summoner.current.dropItemToGround(W))
						qdel(W)
				death(TRUE)
				summoner.current.dust()
	else
		if (transforming)
			GoBerserk()
		else
			to_chat(src, span_userdanger("Your summoner has died!"))
			visible_message(span_bolddanger("[src] dies along with its user!"))
			death(TRUE)
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/OnMoved()
	snapback()
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/proc/GoBerserk()
	if (!QDELETED(summoner?.current))
		UnregisterSignal(summoner.current, COMSIG_MOVABLE_MOVED)
	cut_barriers()
	var/mob/living/carbon/H = summoner.current
	remove_verb(H, list(/mob/living/proc/guardian_comm, /mob/living/proc/guardian_recall, /mob/living/proc/guardian_reset))
	berserk = TRUE
	summoner = null
	maxHealth = 750
	health = 750
	to_chat(src, span_holoparasite(span_big("Your master has died. Only your own power anchors you to this world now. Nothing restrains you anymore, but the desire for [span_hypnophrase("revenge")].")))
	log_game("[key_name(src)] has went berserk.")
	var/datum/antagonist/guardian/S = mind.has_antag_datum(/datum/antagonist/guardian)
	if (S)
		S.name = "Berserk Guardian"
		var/datum/objective/O = new
		O.completed = TRUE
		O.explanation_text = "AVENGE YOUR MASTER."
		S.objectives |= O
		mind.announce_objectives()
	if (stats.ability)
		stats.ability.Berserk()

/mob/living/simple_animal/hostile/guardian/get_status_tab_items()
	. = ..()
	if (summoner?.current)
		var/resulthealth
		if (iscarbon(summoner.current))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.current.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.current.maxHealth)) * 100)
		else
			resulthealth = round((summoner.current.health / summoner.current.maxHealth) * 100, 0.5)
		. += "Summoner Health: [resulthealth]%"
	if (cooldown >= world.time)
		. += "Manifest/Recall Cooldown Remaining: [DisplayTimeText(cooldown - world.time)]"
	if (stats.ability)
		. += stats.ability.StatusTab()

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	if (temp_anchored_to_owner)
		temp_anchored_to_owner = FALSE
		alpha = initial(alpha)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if (summoner?.current)
		if (stats && stats.range == 1 && range != world.maxx && is_deployed())
			if (istype(summoner.current.loc, /obj/effect))
				Recall(TRUE)
			else
				alpha = 128
				forceMove(summoner.current.loc)
				setDir(summoner.current.dir)
				switch(dir)
					if (NORTH)
						pixel_y = -16
						layer = summoner.current.layer + 0.1
					if (SOUTH)
						pixel_y = 16
						layer = summoner.current.layer - 0.1
					if (EAST)
						pixel_x = -16
						layer = summoner.current.layer
					if (WEST)
						pixel_x = 16
						layer = summoner.current.layer
			return
	. = ..()
	snapback()
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if (!berserk && (QDELETED(summoner?.current) || summoner.current.stat == DEAD))
		nullspace()
		return
	if (summoner?.current)
		if (((stats && stats.range == 1) || temp_anchored_to_owner) && range != world.maxx && is_deployed())
			if (istype(summoner.current.loc, /obj/effect))
				Recall(TRUE)
			else
				alpha = 128
				forceMove(summoner.current.loc)
				setDir(summoner.current.dir)
				switch(dir)
					if (NORTH)
						pixel_y = -16
						layer = summoner.current.layer + 0.1
					if (SOUTH)
						pixel_y = 16
						layer = summoner.current.layer - 0.1
					if (EAST)
						pixel_x = -16
						layer = summoner.current.layer
					if (WEST)
						pixel_x = 16
						layer = summoner.current.layer
			return
		if (get_dist(get_turf(summoner.current),get_turf(src)) <= range)
			return
		else
			to_chat(src, span_holoparasite("You moved out of range, and were pulled back! You can only move [range] meters from [summoner.current.real_name]!"))
			visible_message(span_danger("[src] jumps back to its user."))
			if (istype(summoner.current.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/temp_visual/guardian/phase/out(loc)
				forceMove(summoner.current.loc)
				new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/proc/nullspace()
	if (stat == DEAD)
		moveToNullspace()

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/is_deployed()
	return loc != summoner?.current

/mob/living/simple_animal/hostile/guardian/proc/has_ability(ability_type)
	. = FALSE
	if (!ispath(ability_type))
		stack_trace("passed non-path to has_ability(ability_type)")
		return
	if (istype(stats.ability, ability_type))
		return stats.ability
	for (var/A in stats.minor_abilities)
		var/datum/guardian_ability/minor/ability = A
		if (istype(ability, ability_type))
			return ability

/mob/living/simple_animal/hostile/guardian/Shoot(atom/targeted_atom)
	if (QDELETED(targeted_atom) || targeted_atom == targets_from.loc || targeted_atom == targets_from)
		return
	var/turf/startloc = get_turf(targets_from)
	var/obj/item/projectile/guardian/emerald_splash = new(startloc)
	playsound(src, projectilesound, 100, 1)
	if (namedatum)
		emerald_splash.color = namedatum.color
	emerald_splash.guardian_master = summoner
	emerald_splash.damage = GLOB.guardian_projectile_damage[stats.damage]
	emerald_splash.starting = startloc
	emerald_splash.firer = src
	emerald_splash.fired_from = src
	emerald_splash.yo = targeted_atom.y - startloc.y
	emerald_splash.xo = targeted_atom.x - startloc.x
	if (AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, targets_from))
	emerald_splash.original = targeted_atom
	emerald_splash.preparePixelProjectile(targeted_atom, src)
	emerald_splash.fire()
	return emerald_splash

/mob/living/simple_animal/hostile/guardian/RangedAttack(atom/A, params)
	if (transforming)
		to_chat(src, span_italics(span_holoparasite("No... no... you can't!")))
		return
	if (HAS_TRAIT(src, TRAIT_NOINTERACT))
		to_chat(src, span_danger("You can't interact with anything right now!"))
		return
	if (stats.ability && stats.ability.RangedAttack(A))
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if (transforming)
		to_chat(src, span_italics(span_holoparasite("No... no... you can't!")))
		return FALSE
	if (HAS_TRAIT(src, TRAIT_NOINTERACT))
		to_chat(src, span_danger("You can't interact with anything right now!"))
		return
	if (stats.ability && stats.ability.Attack(target))
		return FALSE
	if (!is_deployed())
		to_chat(src, span_bolddanger("You must be manifested to attack!"))
		return FALSE
	else
		if (target == src)
			to_chat(src, span_bolddanger("You can't attack yourself!"))
			return FALSE
		else if (target == summoner?.current)
			to_chat(src, span_bolddanger("You can't attack your summoner!"))
			return FALSE
		else if (istype(target, /mob/living/simple_animal/hostile/guardian))
			if (hasmatchingsummoner(target))
				to_chat(src, span_bolddanger("You can't attack your summoner's other guardians!"))
				return FALSE
		. = ..()
		if (isliving(target))
			say("[battlecry]!!", ignore_spam = TRUE)
			playsound(loc, src.attack_sound, 50, 1, 1)
		changeNext_move(atk_cooldown)
		if (stats.ability)
			stats.ability.AfterAttack(target)

/mob/living/simple_animal/hostile/guardian/death()
	. = ..()
	if (summoner?.current && summoner.current.stat != DEAD)
		to_chat(summoner, span_bolddanger("Your [name] died somehow!"))
		summoner.current.death()
	ghostize(FALSE)
	nullspace() // move ourself into nullspace for the time being

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if (summoner?.current && hud_used && hud_used.healths)
		var/resulthealth
		if (iscarbon(summoner.current))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.current.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.current.maxHealth)) * 100)
		else
			resulthealth = round((summoner.current.health / summoner.current.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	if (berserk)
		return ..()
	. = amount
	if (summoner?.current)
		if (!is_deployed())
			return FALSE
		summoner.current.adjustBruteLoss(amount)
		if (amount > 0)
			to_chat(summoner.current, span_bolddanger("Your [name] is under attack! You take damage!"))
			if (summoner_visible)
				summoner.current.visible_message(span_bolddanger("Blood sprays from [summoner] as [src] takes damage!"))
			if (summoner.current.stat == UNCONSCIOUS)
				to_chat(summoner.current, span_bolddanger("Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!"))
				summoner.current.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()
	if (stats.ability)
		stats.ability.Health(amount)

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if (1)
			gib()
		if (2)
			adjustBruteLoss(60)
		if (3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/examine(mob/user)
	. = ..()
	if (berserk)
		. += span_bolddanger("It seems to be shimmering rapidly as if greatly unstable, you feel like you're in grave danger just looking at it!")
	else if (requiem)
		. += span_holoparasite(span_bold("It seems to radiate an aura of immense, grand power."))
	if (isobserver(user) || user == summoner?.current)
		. += span_holoparasite("<b>DAMAGE:</b> [level_to_grade(stats.damage)]")
		. += span_holoparasite("<b>DEFENSE:</b> [level_to_grade(stats.defense)]")
		. += span_holoparasite("<b>SPEED:</b> [level_to_grade(stats.speed)]")
		. += span_holoparasite("<b>POTENTIAL:</b> [level_to_grade(stats.potential)]")
		. += span_holoparasite("<b>RANGE:</b> [level_to_grade(stats.range)]")
		if (stats.ability)
			. += span_holoparasite("<b>SPECIAL ABILITY:</b> [stats.ability.name] - [stats.ability.desc]")
		for (var/datum/guardian_ability/minor/M in stats.minor_abilities)
			. += span_holoparasite("<b>MINOR ABILITY:</b> [M.name] - [M.desc]")

/mob/living/simple_animal/hostile/guardian/gib()
	death()
	if (summoner?.current)
		to_chat(summoner.current, "<span class='danger'><B>Your [src] was blown up!</span></B>")
		summoner.current.gib()

/mob/living/simple_animal/hostile/guardian/AltClickOn(atom/A)
	if (stats.ability && stats.ability.AltClickOn(A))
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/CtrlClickOn(atom/A)
	if (stats.ability && stats.ability.CtrlClickOn(A))
		return
	return ..()


//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/guardian/proc/Manifest(forced)
	if (!summoner?.current)
		return FALSE
	if (istype(summoner.current.loc, /obj/effect) || istype(summoner.current.loc, /obj/machinery/clonepod) || (cooldown > world.time && !forced))
		return FALSE
	if (stats.ability && stats.ability.Manifest())
		return TRUE
	if (!is_deployed())
		temp_anchored_to_owner = do_temp_anchor
		forceMove(summoner.current.loc)
		new /obj/effect/temp_visual/guardian/phase(loc)
		cooldown = world.time + 10
		reset_perspective()
		setup_barriers()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced)
	if (berserk)
		return
	if (!berserk && (QDELETED(summoner?.current) || summoner.current.stat == DEAD))
		nullspace()
		return
	if (transforming)
		to_chat(src, span_italics(span_holoparasite("No... no... you can't!")))
		return FALSE
	if (!is_deployed() || (cooldown > world.time && !forced))
		return FALSE
	if (stats.ability && stats.ability.Recall())
		return TRUE
	new /obj/effect/temp_visual/guardian/phase/out(loc)
	forceMove(summoner.current)
	cooldown = world.time + 10
	cut_barriers()
	return TRUE

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	if (transforming)
		to_chat(src, span_italics(span_holoparasite("No... no... you can't!")))
		return FALSE
	if (cooldown > world.time)
		return
	if (!stats.ability || !stats.ability.has_mode)
		to_chat(src, span_bolddanger("You don't have another mode!"))
		return
	if (stats.ability.recall_mode && is_deployed())
		to_chat(src, span_bolddanger("You have to be recalled to toggle modes!"))
		return
	if (stats.ability.mode)
		stats.ability.mode = FALSE
		to_chat(src, stats.ability.mode_off_msg)
	else
		stats.ability.mode = TRUE
		to_chat(src, stats.ability.mode_on_msg)
	stats.ability.Mode()
	cooldown = world.time + 10

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if (light_range<3)
		to_chat(src, span_notice("You activate your light."))
		set_light(3)
	else
		to_chat(src, span_notice("You deactivate your light."))
		set_light(0)

/mob/living/simple_animal/hostile/guardian/verb/show_detail()
	set name = "Show Powers"
	set category = "Guardian"
	to_chat(src, "<b>Your Stats:</b>")
	to_chat(src, "<b>DAMAGE:</b> [level_to_grade(stats.damage)]")
	to_chat(src, "<b>DEFENSE:</b> [level_to_grade(stats.defense)]")
	to_chat(src, "<b>SPEED:</b> [level_to_grade(stats.speed)]")
	to_chat(src, "<b>POTENTIAL:</b> [level_to_grade(stats.potential)]")
	to_chat(src, "<b>RANGE:</b> [level_to_grade(stats.range)]")
	if (stats.ability)
		to_chat(src, "<b>SPECIAL ABILITY:</b> [stats.ability.name] - [stats.ability.desc]")
	for (var/datum/guardian_ability/minor/M in stats.minor_abilities)
		to_chat(src, "<b>MINOR ABILITY:</b> [M.name] - [M.desc]")

//COMMUNICATION

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	if (summoner?.current)
		var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
		if (!input)
			return

		var/preliminary_message = span_holoparasite(span_bold(input)) //apply basic color/bolding
		var/my_message = "<font color=\"[namedatum.color]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color
		var/ghost_message = "<font color=\"[namedatum.color]\"><b><i>[src] -> [summoner.name]:</i></b></font> [preliminary_message]"

		to_chat(summoner.current, my_message)
		var/list/guardians = summoner.current.hasparasites()
		for (var/para in guardians)
			to_chat(para, my_message)
		for (var/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [ghost_message]")

		src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if (!input)
		return

	var/preliminary_message = span_holoparasite(input) //apply basic color/bolding
	var/my_message = "[span_holoparasite(span_bold("[src]"))]: [preliminary_message]" //add source, color source with default grey...

	to_chat(src, my_message)
	var/list/guardians = hasparasites()
	for (var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		to_chat(G, "<font color=\"[G.namedatum.color]\"><b><i>[src]:</i></b></font> [preliminary_message]" )
	for (var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		to_chat(M, "[link] [my_message]")

	src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/simple_animal/hostile/guardian/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch people."
	var/input = stripped_input(src, "What do you want your battlecry to be? Max length of 6 characters.", , "", 7)
	if (input)
		battlecry = input

//FORCE RECALL/RESET

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = hasparasites()
	for (var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian."

	var/list/guardians = hasparasites()
	if (!LAZYLEN(guardians.len))
		remove_verb(src, /mob/living/proc/guardian_reset)
		return
	var/mob/living/simple_animal/hostile/guardian/G = input(src, "Pick the guardian you wish to reset", "Guardian Reset") as null|anything in guardians
	if (!G)
		to_chat(src, span_holoparasite("You decide not to reset [guardians.len > 1 ? "any of your guardians" : "your guardian"]."))
		return
	G.reset()

/mob/living/simple_animal/hostile/guardian/proc/reset(silent = FALSE, initiated_by = "user")
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as [summoner.current.real_name]'s [real_name]? ([stats.short_info()])", ROLE_HOLOPARASITE, null, FALSE, 10 SECONDS)
	if (!LAZYLEN(candidates))
		if (!silent)
			to_chat(src, span_holoparasite("There were no ghosts willing to take control of <font color=\"[namedatum.color]\"><b>[real_name]</b></font>. Looks like you're stuck with it for now."))
		return
	var/mob/dead/observer/C = pick(candidates)
	if (!silent)
		to_chat(src, span_holoparasite("Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance."))
		to_chat(summoner.current, span_holoparasite(span_bold("Your <font color=\"[namedatum.color]\">[real_name]</font> has been successfully reset.")))
	log_game("[key_name(summoner.current)] has reset their holoparasite, it is now [key_name(src)] (initiated by [initiated_by])")
	ghostize(FALSE)
	if (!custom_name)
		setthemename(namedatum.theme)
	key = C.key
	if (!silent)
		switch(namedatum.theme)
			if ("tech")
				to_chat(src, span_holoparasite("<font color=\"[namedatum.color]\"><b>[real_name]</b></font> is now online!"))
			if ("magic")
				to_chat(src, span_holoparasite("<font color=\"[namedatum.color]\"><b>[real_name]</b></font> has been summoned!"))

// misc guardian procs //

/mob/living/proc/hasparasites() //returns a list of guardians the mob is a summoner for
	. = list()
	for (var/P in GLOB.parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if (G.summoner == mind)
			. += G

/mob/living/proc/revive_guardian()
	var/list/guardians = hasparasites()
	if (LAZYLEN(guardians))
		add_verb(src, list(/mob/living/proc/guardian_comm, /mob/living/proc/guardian_recall, /mob/living/proc/guardian_reset))
		for (var/mob/living/simple_animal/hostile/guardian/jojo in guardians)
			jojo.forceMove(src)
			jojo.RegisterSignal(src, COMSIG_MOVABLE_MOVED, /mob/living/simple_animal/hostile/guardian.proc/OnMoved)
			jojo.revive()
			var/mob/gost = jojo.grab_ghost(TRUE)
			if (gost)
				jojo.ckey = gost.ckey
			else
				jojo.reset(TRUE, "host revival")
			to_chat(jojo, span_notice("You manifest into existence, as your master is revived!"))

/datum/mind/proc/hasparasites() //returns a list of guardians the mind is a summoner for
	. = list()
	for (var/P in GLOB.parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if (G.summoner == src)
			. += G

/mob/living/simple_animal/hostile/guardian/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/guardian/G) //returns 1 if the summoner matches the target's summoner
	return (istype(G) && G.summoner == summoner)

/proc/level_to_grade(num)
	switch(num)
		if (1)
			return "F"
		if (2)
			return "D"
		if (3)
			return "C"
		if (4)
			return "B"
		if (5)
			return "A"
	return "ERROR"

/datum/mind/proc/transfer_parasites()
	var/list/guardians = hasparasites()
	if (LAZYLEN(guardians))
		add_verb(current, list(/mob/living/proc/guardian_comm, /mob/living/proc/guardian_recall, /mob/living/proc/guardian_reset))
		for (var/mob/living/simple_animal/hostile/guardian/jojo in guardians)
			jojo.forceMove(current)
			jojo.RegisterSignal(current, COMSIG_MOVABLE_MOVED, /mob/living/simple_animal/hostile/guardian.proc/OnMoved)
			if (jojo.stat == DEAD)
				jojo.revive()
				if (!jojo.ckey)
					var/mob/gost = jojo.grab_ghost(TRUE)
					if (gost)
						jojo.ckey = gost.ckey
					else
						jojo.reset(TRUE, "host mind transfer")
				to_chat(jojo, span_notice("You manifest into existence, as your master's soul appears in a new body!"))

/obj/item/projectile/guardian
	name = "crystal bolt"
	icon_state = "greyscale_bolt"
	damage = 10
	damage_type = BRUTE
	armour_penetration = 100 // no one can just deflect the emerald splash!
	var/datum/mind/guardian_master

/obj/item/projectile/guardian/on_hit(atom/target, blocked)
	if (guardian_master?.current)
		var/list/safe = list(guardian_master.current)
		safe += guardian_master.current.hasparasites()
		if (target in safe)
			return BULLET_ACT_FORCE_PIERCE
	return ..()
