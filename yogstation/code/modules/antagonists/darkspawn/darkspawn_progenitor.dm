/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "void progenitor"
	desc = "..."

	//icons
	icon = 'yogstation/icons/mob/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	health_doll_icon = "smolgenitor"
	pixel_x = -48 //offset so the mob collision is roughly the middle of the sprite
	pixel_y = -32
	layer = LARGE_MOB_LAYER

	//combat stats
	health = 100000 //functionally immortal, but still killable
	maxHealth = 100000
	melee_damage_lower = 40
	melee_damage_upper = 40
	armour_penetration = 100
	obj_damage = INFINITY
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	weather_immunities = list("lava", "ash")
	status_flags = NONE	
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0) //Leaving something at 0 means it's off - has no maximum
	unsuitable_atmos_damage = 0	

	//movement stats
	speed = 0 //slower than a person, RUN RUN RUN RUN
	movement_type = FLYING
	move_force = INFINITY
	move_resist = INFINITY //hmm yes, surely this won't cause bugs *clueless*
	pull_force = INFINITY
	mob_size = MOB_SIZE_HUGE

	//night vision
	lighting_cutoff_red = 12
	lighting_cutoff_green = 0
	lighting_cutoff_blue = 50
	lighting_cutoff = (LIGHTING_CUTOFF_HIGH + 10) //could set it at 40, but i explicitly want it to be higher than the highest lighting cutoff
	sight = SEE_MOBS | SEE_TURFS | SEE_OBJS

	//flavour
	attack_sound = 'yogstation/sound/creatures/progenitor_attack.ogg'
	attacktext = "rends"
	friendly = "stares down"
	speak_emote = list("roars")
	speech_span = SPAN_PROGENITOR //pretty sure this is how i'd go about doing this, hopefully
	faction = list("darkspawn")

	//progenitor specific variables
	var/time_to_next_roar = 0
	var/roar_cooldown = 30 SECONDS
	var/list/roar_text = list( //picks a random line each time the target is stunned by a roar (a rough mix of psychotic ramblings, poetic waxings, and white noise)
		"You stand paralyzed in the shadow of the cold as it descends from on high.",
		"The end times the end times the end times the end times the end times",
		"Its in your mind, your mind? it's mind? who's mind?",
		"You legs refuse to move as you hear the cry of the unknown.",
		"You have barely yet stared into the abyss, yet it gazes back in full force",
		"I can't i can't i can't i can't i can't i can't i can't i can't i can't i can't",
		"Your brain begins to turn on your body as there is naught else it can do.",
		"You fail to muster the strength to move as the weight of your circumstances crush you.",
		"This is all a dream, that has to be it, I've just fallen asleep on the job.",
		"AHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAH",
		"________________________________________________________________________________",
		"Let me out. Let me out. Let me out. Let me out. Let me out. Let me out. Let me out.",
		"^$#%*^&($^%&($^^!#%#@~!$#@*)&)_*_*)&+(&+*@#$%!@#$!~@%&^%*^&)(&*_((_+*(!#$@!@!))",
		"********************************************************************************",
		"The beauty of the end, it captivates you, but only for a moment.",
		"To once again live in blissful ignorance, what a treat that would be.",
		"They've returned... who?",
		"Never left, unseen, ancient, original, unending, fleeting, have always been here.",
		"The height of hubris to believe one was invited, mere stowaways.",
		"How quick the turn from serene to chaos, a thin divide between.",
		"The cacophony of sounds assault you from all directions."
		)

	///Innate spells that are added when a progenitor is created
	var/list/actions_to_add = list( //can be modified for each progenitor
		/datum/action/cooldown/spell/pointed/progenitor_curse
	)

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize(mapload, darkspawn_name, class_colour = COLOR_DARKSPAWN_PSI)
	. = ..()
	//add_atom_colour(class_colour, FIXED_COLOUR_PRIORITY)

	//give them all the class specific spells
	for(var/spell in actions_to_add)
		var/datum/action/cooldown/spell/new_spell = new spell(src)
		new_spell.Grant(src)

	//add passive traits, elements, and components
	ADD_TRAIT(src, TRAIT_HOLY, INNATE_TRAIT) //sorry no magic
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT) //so people can actually look at the sprite without the weird bobbing up and down
	AddElement(/datum/element/death_explosion, 20, 20, 20) //with INFINITY health, they're not really able to die, but IF THEY DO
	AddComponent(/datum/component/light_eater)

	//so the progenitor can hear people's screams over radio
	var/obj/item/radio/headset/silicon/ai/radio = new(src) 
	radio.wires.cut(WIRE_TX) //but not talk over it

	//give them a fancy name (and help the darkspawn tell where they are in the dark)
	var/prefix = pick("Ancestral", "Void", "Cosmic", "Shadow", "Darkspawn", "Veil")
	var/suffix = pick("Progenitor", "Ascended")
	if(rand(0, 10000) == 0)
		prefix = "Vxtrin"
	name = "[prefix] [suffix][darkspawn_name ? " [darkspawn_name]":""]"

	//have them fade into existence and play a sound cry when they finish fading in
	alpha = 0
	animate(src, alpha = 255, time = 4 SECONDS) 
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(sound_to_playing_players), 'yogstation/sound/magic/sacrament_complete.ogg', 50), 4 SECONDS, TIMER_UNIQUE)
	time_to_next_roar = world.time + roar_cooldown //prevent immediate roaring causing sound overlap
	update_appearance(UPDATE_OVERLAYS)

/mob/living/simple_animal/hostile/darkspawn_progenitor/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src)

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'yogstation/sound/magic/pass_smash_door.ogg', 100, FALSE)
	. = ..()

//////////////////////////////////////////////////////////////////////////
//-------------------------------Smol-----------------------------------//
//////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	..()
	var/image/I = image(icon = 'yogstation/icons/mob/darkspawn.dmi' , icon_state = "smol_progenitor", loc = src)
	I.override = 1
	I.pixel_x -= pixel_x
	I.pixel_y -= pixel_y
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smolgenitor", I)
	time_to_next_roar = world.time + roar_cooldown

//////////////////////////////////////////////////////////////////////////
//-------------------------------Roar-----------------------------------//
//////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/darkspawn_progenitor/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(time_to_next_roar + roar_cooldown <= world.time) //gives time to roar manually if you want to
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(time_to_next_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'yogstation/sound/creatures/progenitor_roar.ogg', 70, TRUE)
	for(var/mob/M in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'yogstation/sound/creatures/progenitor_distant.ogg', 35, FALSE, falloff_exponent = 5)
		else if(is_darkspawn_or_thrall(M) || M==src) //the progenitor is PROBABLY a darkspawn, but just in case
			continue
		else if(isliving(M))
			var/mob/living/L = M
			if(prob(1) && isethereal(L))
				to_chat(M, span_boldannounce("They weren't just a story to keep us in line..."))
			else
				to_chat(M, span_boldannounce(pick(roar_text)))
			L.Immobilize(3 SECONDS)
	time_to_next_roar = world.time + roar_cooldown

//////////////////////////////////////////////////////////////////////////
//--------------------------Ignoring physics----------------------------//
//////////////////////////////////////////////////////////////////////////
/mob/living/simple_animal/hostile/darkspawn_progenitor/Process_Spacemove()
	return TRUE

/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ratvar_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ex_act() //sorry no bombs
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/gib() //no shuttlegib either
	return
	
//////////////////////////////////////////////////////////////////////////
//--------------------------Progenitor attack---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/progenitor_curse
	name = "Viscerate Mind"
	desc = "Unleash a powerful psionic barrage into the mind of the target."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "sacrament(old)"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'

	panel = "Darkspawn"
	spell_requirements = NONE
	cast_range = 10

/datum/action/cooldown/spell/pointed/progenitor_curse/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/progenitor_curse/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on)) //sanity check
		return
	var/mob/living/target = cast_on
	if(is_darkspawn_or_thrall(target))
		return
	var/zoinks = rand(1, 50) / 100 //like, this isn't even my final form!
	owner.visible_message(span_warning("[owner]'s sigils flare as it glances at [target]!"), span_velvet("You direct [zoinks]% of your psionic power into [target]'s mind!."))
	target.apply_status_effect(STATUS_EFFECT_PROGENITORCURSE)
