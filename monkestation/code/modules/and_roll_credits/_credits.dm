#define CREDIT_ROLL_SPEED 18 SECONDS
#define CREDIT_SPAWN_SPEED 1 SECONDS
#define CREDIT_ANIMATE_HEIGHT (32 * world.icon_size)
#define CREDIT_EASE_DURATION 2.2 SECONDS
#define CREDITS_PATH "[global.config.directory]/contributors.dmi"

/proc/RollCredits()
	set waitfor = FALSE

	if(!fexists(CREDITS_PATH))
		return

	if(!SScredits.credit_order)
		SScredits.generate_credits()

	for(var/client/client in GLOB.clients)
		add_verb(client, /client/proc/ClearCredits)

	var/count = 0

	for(var/credit in SScredits.credit_order)
		if(istype(credit, /obj/effect/title_card_object)) //huge image sleep
			sleep(CREDIT_SPAWN_SPEED * 3.3)
			count = 0

		if(count && !istype(credit, /atom/movable/screen/map_view/char_preview))
			sleep(CREDIT_SPAWN_SPEED)

		new /atom/movable/screen/credit(null, credit)

		if(istype(credit, /atom/movable/screen/map_view/char_preview))
			count++
			if(count >= 8)
				count = 0
				sleep(CREDIT_SPAWN_SPEED)

		if(!istype(credit, /atom/movable/screen/map_view/char_preview))
			sleep(CREDIT_SPAWN_SPEED)
			count = 0

	sleep(CREDIT_ROLL_SPEED - CREDIT_SPAWN_SPEED)

	for(var/client/client in GLOB.clients)
		remove_verb(client, /client/proc/ClearCredits)

	LAZYNULL(SScredits.ignored_clients)

/client/proc/ClearCredits()
	set name = "Hide Credits"
	set category = "OOC"
	remove_verb(src, /client/proc/ClearCredits)

	LAZYADDASSOC(SScredits.ignored_clients, src, TRUE)

	for(var/atom/movable/screen/credit/credit in src.screen)
		src.screen -= credit

/atom/movable/screen/credit
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0
	plane = SPLASHSCREEN_PLANE
	screen_loc = "CENTER-6:16,BOTTOM"

	var/matrix/target

/atom/movable/screen/credit/Initialize(mapload, credited)
	. = ..()
	icon = CREDITS_PATH

	if(istype(credited, /atom/movable/screen/map_view/char_preview))
		var/atom/movable/screen/map_view/char_preview/choice = credited
		choice.plane = plane
		choice.alpha = alpha
		maptext_width = choice.maptext_width
		maptext = choice.maptext
		screen_loc = choice.screen_loc
		appearance = choice.appearance
		choice.screen_loc = null
		add_overlay(choice)

	if(istype(credited, /mutable_appearance))
		var/mutable_appearance/choice = credited
		choice.plane = plane
		choice.alpha = alpha
		maptext_width = choice.maptext_width
		maptext = choice.maptext
		screen_loc = choice.screen_loc
		appearance = choice.appearance
		choice.screen_loc = null
		add_overlay(choice)

	if(istype(credited, /obj/effect/title_card_object))
		var/obj/effect/title_card_object/choice = credited
		choice.plane = plane
		choice.alpha = alpha
		maptext_width = choice.maptext_width
		maptext = choice.maptext
		screen_loc = choice.screen_loc
		appearance = choice.appearance
		choice.screen_loc = null
		add_overlay(choice)

	if(istext(credited))
		maptext = MAPTEXT_PIXELLARI(credited)
		maptext_width = world.icon_size * 12
		maptext_height = world.icon_size * 2

	var/matrix/M = matrix(transform)
	M.Translate(0, CREDIT_ANIMATE_HEIGHT)
	animate(src, transform = M, time = CREDIT_ROLL_SPEED)
	target = M
	animate(src, alpha = 255, time = CREDIT_EASE_DURATION, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(fadeout)), CREDIT_ROLL_SPEED - CREDIT_EASE_DURATION)
	INVOKE_ASYNC(src, PROC_REF(show_to_players))
	QDEL_IN(src, CREDIT_ROLL_SPEED)

/atom/movable/screen/credit/Destroy()
	screen_loc = null
	target = null
	return ..()

/atom/movable/screen/credit/proc/fadeout()
	animate(src, alpha = 0, transform = target, time = CREDIT_EASE_DURATION)

/atom/movable/screen/credit/proc/show_to_players()
	for(var/client/client in GLOB.clients)
		if(LAZYACCESS(SScredits.ignored_clients, client) || !client?.prefs?.read_preference(/datum/preference/toggle/show_roundend_credits))
			continue
		client.screen += src

#undef CREDIT_ANIMATE_HEIGHT
#undef CREDIT_EASE_DURATION
#undef CREDIT_ROLL_SPEED
#undef CREDIT_SPAWN_SPEED
#undef CREDITS_PATH
