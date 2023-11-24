/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "void progenitor"
	desc = "..."

	//icons
	icon = 'yogstation/icons/mob/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	pixel_x = -48 //offset so the mob collision is roughly the middle of the sprite
	pixel_y = -32
	layer = LARGE_MOB_LAYER

	//combat stats
	health = INFINITY
	maxHealth = INFINITY
	melee_damage_lower = 40
	melee_damage_upper = 40
	armour_penetration = 100
	obj_damage = 100
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	weather_immunities = list("lava", "ash")

	//movement stats
	speed = -0.5 //just about the same speed as a person
	movement_type = FLYING
	move_force = INFINITY
	move_resist = INFINITY //hmm yes, surely this won't cause bugs *clueless*
	pull_force = INFINITY
	mob_size = MOB_SIZE_HUGE

	//light
	light_system = MOVABLE_LIGHT
	light_power = -0.1
	light_range = 0 //so they can be seen in the dark at a distance
	light_color = COLOR_VELVET
	see_in_dark = INFINITY
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	//flavour
	attack_sound = 'yogstation/sound/creatures/progenitor_attack.ogg'
	attacktext = "rends"
	friendly = "stares down"
	speak_emote = list("roars")
	speech_span = SPAN_PROGENITOR //pretty sure this is how i'd go about doing this, hopefully

	//progenitor specific variables
	var/time_to_next_roar = 0
	var/roar_cooldown = 20 SECONDS
	
	///Innate spells that are added when a progenitor is created
	var/list/actions_to_add = list( //can be modified for each progenitor
		/datum/action/cooldown/spell/pointed/progenitor_curse
	)

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize(mapload, darkspawn_name, outline_colour = COLOR_DARKSPAWN_PSI)
	. = ..()
	sound_to_playing_players('yogstation/sound/magic/sacrament_complete.ogg', 50, FALSE, pressure_affected = FALSE) //announce the beginning of the end
	time_to_next_roar = world.time + roar_cooldown //prevent immediate roaring causing sound overlap

	for(var/spell in actions_to_add)
		var/datum/action/cooldown/spell/new_spell = new spell(src)
		new_spell.Grant(src)

	//have them fade into existence
	alpha = 0
	animate(src, alpha = 255, time = 2 SECONDS) 

	ADD_TRAIT(src, TRAIT_HOLY, INNATE_TRAIT) //sorry no magic
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT) //so people can actually look at the sprite without the weird bobbing up and down
	AddElement(/datum/element/death_explosion, 10, 20, 40) //with INFINITY health, they're not likely do die, but IF THEY DO

	//so the progenitor can hear people's screams over radio
	var/obj/item/radio/headset/silicon/ai/radio = new(src) 
	radio.wires.cut(WIRE_TX) //but not talk over it

	//give them a fancy name (and help the darkspawn tell where they are in the dark)
	var/prefix = pick("Ancestral", "Void", "Cosmic", "Shadow", "Darkspawn", "Veil")
	var/suffix = pick("Progenitor", "Ascended")
	if(rand(0, 10000) == 0)
		prefix = "Vxtrin"
	name = "[prefix] [suffix][darkspawn_name ? " [darkspawn_name]":""]"

	//to show the class of the darkspawn
	add_filter("outline_filter", 2, list("type" = "outline", "color" = outline_colour, "alpha" = 0, "size" = 1))
	var/filter = get_filter("outline_filter")
	animate(filter, alpha = 200, time = 1 SECONDS, loop = -1, easing = EASE_OUT | SINE_EASING)
	animate(alpha = 100, time = 1 SECONDS, easing = EASE_OUT | SINE_EASING)

	var/datum/component/overlay_lighting/light = GetComponent(/datum/component/overlay_lighting)
	if(light?.visible_mask) //give the light the same offset
		light.visible_mask.pixel_x = pixel_x
		light.visible_mask.pixel_y = pixel_y

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'yogstation/sound/magic/pass_smash_door.ogg', 100, FALSE)
	. = ..()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	..()
	var/image/I = image(icon = 'yogstation/icons/mob/mob.dmi' , icon_state = "smol_progenitor", loc = src)
	I.override = 1
	I.pixel_x -= pixel_x
	I.pixel_y -= pixel_y
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smolgenitor", I)
	time_to_next_roar = world.time + roar_cooldown

/mob/living/simple_animal/hostile/darkspawn_progenitor/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(time_to_next_roar + roar_cooldown <= world.time) //gives time to roar manually if you want to
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(time_to_next_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Process_Spacemove()
	return TRUE

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'yogstation/sound/creatures/progenitor_roar.ogg', 50, TRUE)
	for(var/mob/M in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'yogstation/sound/creatures/progenitor_distant.ogg', 25, FALSE, falloff_exponent = 5)
		else if(is_darkspawn_or_veil(M) || M==src) //the progenitor is PROBABLY a darkspawn, but just in case
			continue
		else if(isliving(M))
			var/mob/living/L = M
			to_chat(M, span_boldannounce("You stand paralyzed in the shadow of the cold as it descends from on high."))
			L.Stun(20)
	time_to_next_roar = world.time + roar_cooldown


/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ratvar_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ex_act() //sorry no bombs
	return

//////////////////////////////////////////////////////////////////////////
//--------------------------Progenitor attack---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/progenitor_curse
	name = "Viscerate Mind"
	desc = "Unleash a powerful psionic barrage into the mind of the target."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "veil_mind"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'

	panel = null
	spell_requirements = NONE
	cast_range = 10

/datum/action/cooldown/spell/pointed/progenitor_curse/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/progenitor_curse/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on)) //sanity check
		return
	var/mob/living/target = cast_on
	if(is_darkspawn_or_veil(target))
		return
	var/zoinks = rand(1, 10) / 10 //like, this isn't even my final form!
	owner.visible_message(span_warning("[owner]'s sigils flare as it glances at [target]!"), span_velvet("You direct [zoinks]% of your psionic power into [target]'s mind!."))
	target.apply_status_effect(STATUS_EFFECT_PROGENITORCURSE)
