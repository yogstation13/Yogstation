/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/friendlyName
	var/savedName
	var/active = FALSE
	var/activationCost = 300
	var/activationUpkeep = 50
	var/mob/listeningTo
	var/static/list/signalCache = list( // list here all signals that should break the camouflage
			COMSIG_ATOM_ATTACKBY,
			COMSIG_ATOM_ATTACK_HAND,
			COMSIG_MOVABLE_IMPACT_ZONE,
			COMSIG_ATOM_BULLET_ACT,
			COMSIG_ATOM_EX_ACT,
			COMSIG_ATOM_FIRE_ACT,
			COMSIG_ATOM_EMP_ACT,
			)
	var/mob/living/silicon/robot/user // needed for process()
	var/animation_playing = FALSE

/obj/item/borg_chameleon/Initialize(mapload)
	. = ..()
	friendlyName = pick(GLOB.ai_names)

/obj/item/borg_chameleon/Destroy()
	listeningTo = null
	return ..()

/obj/item/borg_chameleon/dropped(mob/user)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/equipped(mob/user)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/attack_self(mob/living/silicon/robot/user)
	if (user && user.cell && user.cell.charge >  activationCost)
		if (isturf(user.loc))
			toggle(user)
		else
			to_chat(user, span_warning("You can't use [src] while inside something!"))
	else
		to_chat(user, span_warning("You need at least [activationCost] charge in your cell to use [src]!"))

/obj/item/borg_chameleon/AltClick(mob/living/silicon/robot/user)
	friendlyName = pick(GLOB.ai_names)
	to_chat(user, span_notice("The next disguised name will be: [friendlyName]."))

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/user)
	if(active)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, -6)
		to_chat(user, span_notice("You deactivate \the [src]."))
		deactivate(user)
		return
	if(animation_playing)
		to_chat(user, span_notice("[src] is recharging."))
		return
	animation_playing = TRUE
	to_chat(user, span_notice("You activate \the [src]."))
	playsound(src, 'sound/effects/seedling_chargeup.ogg', 100, 1, -6)

	var/start = user.filters.len
	var/X,Y,rsq,i,f
	for(i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		user.filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	for(i=1, i<=7, ++i)
		f = user.filters[start+i]
		animate(f, offset=f:offset, time=0, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=rand()*20+(1 SECONDS))
	if (do_after(user, 5 SECONDS, user) && user.cell.use(activationCost))
		activate(user)
	else	
		to_chat(user, span_warning("The chameleon field fizzles."))
		do_sparks(3, FALSE, user)
		for(i=1, i<=min(7, user.filters.len), ++i) // removing filters that are animating does nothing, we gotta stop the animations first
			f = user.filters[start+i]
			animate(f)
	user.filters = null
	animation_playing = FALSE

/obj/item/borg_chameleon/process()
	if (user)
		if (!user.cell || !user.cell.use(activationUpkeep))
			disrupt(user)
	else
		return PROCESS_KILL

/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/user)
	// All selectable modules
	var/list/modulelist = list("Standard" = /obj/item/robot_module/standard, \
	"Engineering" = /obj/item/robot_module/engineering, \
	"Medical" = /obj/item/robot_module/medical, \
	"Miner" = /obj/item/robot_module/miner, \
	"Janitor" = /obj/item/robot_module/janitor, \
	"Service" = /obj/item/robot_module/service)
	if(!CONFIG_GET(flag/disable_peaceborg))
		modulelist["Peacekeeper"] = /obj/item/robot_module/peacekeeper
	if(!CONFIG_GET(flag/disable_secborg))
		modulelist["Security"] = /obj/item/robot_module/security

	// Radical of selectable modules
	var/list/moduleicons = list()
	for(var/option in modulelist)
		var/obj/item/robot_module/M = modulelist[option]
		var/is = initial(M.cyborg_base_icon)
		moduleicons[option] = image(icon = 'icons/mob/robots.dmi', icon_state = is)
	var/input_module = show_radial_menu(usr, usr, moduleicons, radius = 42, custom_check = CALLBACK(src, PROC_REF(cancel_radical_on_move), usr,  user.loc))
	
	// Sanity
	if(!input_module || active)
		return

	var/obj/item/robot_module/selected_module = modulelist[input_module]
	if(!selected_module)
		return

	// Disguising
	START_PROCESSING(SSobj, src)
	src.user = user
	savedName = user.name
	user.name = friendlyName
	user.module.cyborg_base_icon = initial(selected_module.cyborg_base_icon)
	user.bubble_icon = BUBBLE_ROBOT
	user.module.name = input_module
	active = TRUE
	user.update_icons()
	
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, signalCache)
	RegisterSignal(user, signalCache, PROC_REF(disrupt))
	listeningTo = user

	playsound(src, 'sound/effects/bamf.ogg', 100, 1, -6)
	to_chat(user, span_notice("You are now disguised as the Nanotrasen [input_module] cyborg \"[friendlyName]\"."))

/obj/item/borg_chameleon/proc/deactivate(mob/living/silicon/robot/user)
	STOP_PROCESSING(SSobj, src)
	if(listeningTo)
		UnregisterSignal(listeningTo, signalCache)
		listeningTo = null
	do_sparks(5, FALSE, user)
	user.name = savedName
	user.module.cyborg_base_icon = initial(user.module.cyborg_base_icon)
	user.bubble_icon = initial(user.bubble_icon)
	user.module.name = initial(user.module.name)
	active = FALSE
	user.update_icons()
	src.user = user

/obj/item/borg_chameleon/proc/disrupt(mob/living/silicon/robot/user)
	if(active)
		to_chat(user, span_danger("Your chameleon field deactivates."))
		deactivate(user)

// Checks if cyborg moved from their position and cancels the radical menu if they did.
/obj/item/borg_chameleon/proc/cancel_radical_on_move(mob/living/silicon/robot/user, atom/last_loc)
	if(user.loc != last_loc)
		return FALSE
	return TRUE
