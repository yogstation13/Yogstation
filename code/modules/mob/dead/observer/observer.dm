GLOBAL_LIST_EMPTY(ghost_images_default) //this is a list of the default (non-accessorized, non-dir) images of the ghosts themselves
GLOBAL_LIST_EMPTY(ghost_images_simple) //this is a list of all ghost images as the simple white ghost

GLOBAL_VAR_INIT(observer_default_invisibility, INVISIBILITY_OBSERVER)

/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	plane = GHOST_PLANE
	stat = DEAD
	density = FALSE
	see_invisible = SEE_INVISIBLE_OBSERVER
	invisibility = INVISIBILITY_OBSERVER
	hud_type = /datum/hud/ghost
	movement_type = GROUND | FLYING
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_power = 2
	light_on = FALSE
	shift_to_open_context_menu = FALSE
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	pass_flags = PASSFLOOR
	var/can_reenter_corpse
	var/bootime = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/atom/movable/following = null
	var/fun_verbs = FALSE
	var/image/ghostimage_default = null //this mobs ghost image without accessories and dirs
	var/image/ghostimage_simple = null //this mob with the simple white ghost sprite
	var/ghostvision = TRUE //is the ghost able to see things humans can't?
	var/mob/observetarget = null	//The target mob that the ghost is observing. Used as a reference in logout()
	var/ghost_hud_enabled = TRUE //did this ghost disable the on-screen HUD?
	var/data_huds_on = FALSE //Are data HUDs currently enabled?

	var/scanmode = 0
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED) //list of data HUDs shown to ghosts.
	var/ghost_orbit = GHOST_ORBIT_CIRCLE

	//These variables store hair data if the ghost originates from a species with head and/or facial hair.
	var/hair_style
	var/hair_color
	var/mutable_appearance/hair_overlay
	var/facial_hair_style
	var/facial_hair_color
	var/mutable_appearance/facial_hair_overlay

	var/updatedir = 1	//Do we have to update our dir as the ghost moves around?
	var/lastsetting = null	//Stores the last setting that ghost_others was set to, for a little more efficiency when we update ghost images. Null means no update is necessary

	//We store copies of the ghost display preferences locally so they can be referred to even if no client is connected.
	//If there's a bug with changing your ghost settings, it's probably related to this.
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	// Used for displaying in ghost chat, without changing the actual name
	// of the mob
	var/deadchat_name
	var/datum/orbit_menu/orbit_ui
	var/datum/jump_menu/jump_ui
	var/datum/spawners_menu/spawners_menu

	///Action to quickly unobserve someone
	var/datum/action/innate/unobserve/unobserve_button

	// Current Viewrange
	var/view = 0

/mob/dead/observer/Initialize(mapload)
	set_invisibility(GLOB.observer_default_invisibility)

	add_verb(src, list(
		/mob/dead/observer/proc/dead_tele,
		/mob/dead/observer/proc/open_spawners_menu,
		/mob/dead/observer/proc/tray_view,
		/mob/dead/observer/proc/possess_mouse_verb))

	if(icon_state in GLOB.ghost_forms_with_directions_list)
		ghostimage_default = image(src.icon,src,src.icon_state + "_nodir")
	else
		ghostimage_default = image(src.icon,src,src.icon_state)
	ghostimage_default.override = TRUE
	GLOB.ghost_images_default |= ghostimage_default

	ghostimage_simple = image(src.icon,src,"ghost_nodir")
	ghostimage_simple.override = TRUE
	GLOB.ghost_images_simple |= ghostimage_simple

	updateallghostimages()

	var/turf/T
	var/mob/body = loc
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				name = random_unique_name(gender)

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

		set_suicide(body.suiciding) // Transfer whether they committed suicide.

		if(ishuman(body))
			var/mob/living/carbon/human/body_human = body
			if(HAIR in body_human.dna.species.species_traits)
				hair_style = body_human.hair_style
				hair_color = brighten_color(body_human.hair_color)
			if(FACEHAIR in body_human.dna.species.species_traits)
				facial_hair_style = body_human.facial_hair_style
				facial_hair_color = brighten_color(body_human.facial_hair_color)

	update_appearance()

	if(!T || is_secret_level(T.z))
		var/list/turfs = get_area_turfs(/area/shuttle/arrival)
		if(turfs.len)
			T = pick(turfs)
		else
			T = SSmapping.get_station_center()

	abstract_move(T)

	if(!name)							//To prevent nameless ghosts
		name = random_unique_name(gender)
	real_name = name

	if(!fun_verbs)
		remove_verb(src, /mob/dead/observer/verb/boo)
		remove_verb(src, /mob/dead/observer/verb/possess)

	animate(src, pixel_y = 2, time = 1 SECONDS, loop = -1)

	add_to_dead_mob_list()

	for(var/v in GLOB.active_alternate_appearances)
		if(!v)
			continue
		var/datum/atom_hud/alternate_appearance/AA = v
		AA.onNewMob(src)

	. = ..()

	grant_all_languages()
	show_data_huds()
	data_huds_on = 1

/mob/dead/observer/get_photo_description(obj/item/camera/camera)
	if(!invisibility || camera.see_ghosts)
		return "You can also see a g-g-g-g-ghooooost!"

/mob/dead/observer/narsie_act()
	var/old_color = color
	color = "#960000"
	animate(src, color = old_color, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 10)

/mob/dead/observer/ratvar_act()
	var/old_color = color
	color = "#FAE48C"
	animate(src, color = old_color, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 10)

/mob/dead/observer/Destroy()
	if(data_huds_on)
		remove_data_huds()
	
	// Update our old body's medhud since we're abandoning it
	if(isliving(mind?.current))
		mind.current.med_hud_set_status()

	GLOB.ghost_images_default -= ghostimage_default
	QDEL_NULL(ghostimage_default)

	GLOB.ghost_images_simple -= ghostimage_simple
	QDEL_NULL(ghostimage_simple)

	updateallghostimages()

	QDEL_NULL(orbit_ui)
	QDEL_NULL(jump_ui)
	QDEL_NULL(spawners_menu)
	return ..()

/*
 * This proc will update the icon of the ghost itself, with hair overlays, as well as the ghost image.
 * Please call update_icon(icon_state) from now on when you want to update the icon_state of the ghost,
 * or you might end up with hair on a sprite that's not supposed to get it.
 * Hair will always update its dir, so if your sprite has no dirs the haircut will go all over the place.
 * |- Ricotez
 */
/mob/dead/observer/update_icon(updates=ALL, new_form)
	. = ..()

	if(client) //We update our preferences in case they changed right before update_icon was called.
		ghost_accs = client.prefs.read_preference(/datum/preference/choiced/ghost_accessories)
		ghost_others = client.prefs.read_preference(/datum/preference/choiced/ghost_others)

	if(hair_overlay)
		cut_overlay(hair_overlay)
		hair_overlay = null

	if(facial_hair_overlay)
		cut_overlay(facial_hair_overlay)
		facial_hair_overlay = null


	if(new_form)
		icon_state = new_form
		if(icon_state in GLOB.ghost_forms_with_directions_list)
			ghostimage_default.icon_state = new_form + "_nodir" //if this icon has dirs, the default ghostimage must use its nodir version or clients with the preference set to default sprites only will see the dirs
		else
			ghostimage_default.icon_state = new_form

	if((ghost_accs == GHOST_ACCS_DIR || ghost_accs == GHOST_ACCS_FULL) && (icon_state in GLOB.ghost_forms_with_directions_list)) //if this icon has dirs AND the client wants to show them, we make sure we update the dir on movement
		updatedir = 1
	else
		updatedir = 0	//stop updating the dir in case we want to show accessories with dirs on a ghost sprite without dirs
		setDir(2 		)//reset the dir to its default so the sprites all properly align up

	if(ghost_accs == GHOST_ACCS_FULL && (icon_state in GLOB.ghost_forms_with_accessories_list)) //check if this form supports accessories and if the client wants to show them
		var/datum/sprite_accessory/S
		if(facial_hair_style)
			S = GLOB.facial_hair_styles_list[facial_hair_style]
			if(S)
				facial_hair_overlay = mutable_appearance(S.icon, "[S.icon_state]", -HAIR_LAYER)
				if(facial_hair_color)
					facial_hair_overlay.color = facial_hair_color
				facial_hair_overlay.alpha = 200
				add_overlay(facial_hair_overlay)
		if(hair_style)
			S = GLOB.hair_styles_list[hair_style]
			if(S)
				hair_overlay = mutable_appearance(S.icon, "[S.icon_state]", -HAIR_LAYER)
				if(hair_color)
					hair_overlay.color = hair_color
				hair_overlay.alpha = 200
				add_overlay(hair_overlay)

/*
 * Increase the brightness of a color by calculating the average distance between the R, G and B values,
 * and maximum brightness, then adding 30% of that average to R, G and B.
 *
 * I'll make this proc global and move it to its own file in a future update. |- Ricotez
 */
/mob/proc/brighten_color(input_color)
	var/r_val
	var/b_val
	var/g_val
	var/color_format = length(input_color)
	if(color_format != length_char(input_color))
		return 0
	if(color_format == 3)
		r_val = hex2num(copytext(input_color, 1, 2)) * 16
		g_val = hex2num(copytext(input_color, 2, 3)) * 16
		b_val = hex2num(copytext(input_color, 3, 4)) * 16
	else if(color_format == 6)
		r_val = hex2num(copytext(input_color, 1, 3))
		g_val = hex2num(copytext(input_color, 3, 5))
		b_val = hex2num(copytext(input_color, 5, 7))
	else
		return 0 //If the color format is not 3 or 6, you're using an unexpected way to represent a color.

	r_val += (255 - r_val) * 0.4
	if(r_val > 255)
		r_val = 255
	g_val += (255 - g_val) * 0.4
	if(g_val > 255)
		g_val = 255
	b_val += (255 - b_val) * 0.4
	if(b_val > 255)
		b_val = 255

	return copytext(rgb(r_val, g_val, b_val), 2)

/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/proc/ghostize(can_reenter_corpse = 1)
	if(!key)
		return
	if(key[1] == "@") // Skip aghosts.
		return

	if(HAS_TRAIT(src, TRAIT_CORPSELOCKED))
		if(can_reenter_corpse) //If you can re-enter the corpse you can't leave when corpselocked
			return
		if(ishuman(usr)) //following code only applies to those capable of having an ethereal heart, ie humans
			var/mob/living/carbon/human/crystal_fella = usr
			var/our_heart = crystal_fella.getorganslot(ORGAN_SLOT_HEART)
			if(istype(our_heart, /obj/item/organ/heart/ethereal)) //so you got the heart?
				var/obj/item/organ/heart/ethereal/ethereal_heart = our_heart
				ethereal_heart.stop_crystalization_process(crystal_fella) //stops the crystallization process

	if(isgolem(usr))
		var/mob/living/carbon/human/H = usr
		var/datum/species/golem/golem = H.dna.species
		if(golem && golem.owner)
			GLOB.servant_golem_users[usr.ckey] = world.time + (golem.ghost_cooldown ? golem.ghost_cooldown : 0)
	stop_sound_channel(CHANNEL_HEARTBEAT) //Stop heartbeat sounds because You Are A Ghost Now
	if(can_reenter_corpse && client) //yogs start
		oobe_client = client //yogs end
	var/mob/dead/observer/ghost = new(src)	// Transfer safety to observer spawning proc.
	SStgui.on_transfer(src, ghost) // Transfer NanoUIs.
	ghost.can_reenter_corpse = can_reenter_corpse
	ghost.key = key
	if(ghost?.client)
		ghost.client.init_verbs()
	if(ghost?.client?.holder?.fakekey)
		ghost.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
		ghost.alpha = 0 //JUUUUST IN CASE
		ghost.name = " "
		ghost.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(stat != DEAD)
		succumb()
	if(stat == DEAD)
		ghostize(TRUE)
		return TRUE
	var/response = tgui_alert(usr, "Are you -sure- you want to ghost?\n(You are alive. If you ghost whilst still alive you may not play again this round! You can't change your mind so choose wisely!!)","Are you sure you want to ghost?",list("Ghost","Stay in body"))
	if(response != "Ghost")
		return FALSE//didn't want to ghost after-all
	ghostize(FALSE) // FALSE parameter is so we can never re-enter our body. U ded.
	return TRUE

/mob/camera/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	var/response = tgui_alert(usr, "Are you -sure- you want to ghost?\n(You are alive. If you ghost whilst still alive you may not play again this round! You can't change your mind so choose wisely!!)","Are you sure you want to ghost?",list("Ghost","Stay in body"))
	if(response != "Ghost")
		return
	ghostize(FALSE)

/mob/dead/observer/Move(NewLoc, direct, glide_size_override = 32)
	if(updatedir)
		setDir(direct)//only update dir if we actually need it, so overlays won't spin on base sprites that don't have directions of their own

	if(glide_size_override)
		set_glide_size(glide_size_override)
	if(NewLoc)
		abstract_move(NewLoc)
		update_parallax_contents()
	else
		var/turf/destination = get_turf(src)

		if((direct & NORTH) && y < world.maxy)
			destination = get_step(destination, NORTH)

		else if((direct & SOUTH) && y > 1)
			destination = get_step(destination, SOUTH)

		if((direct & EAST) && x < world.maxx)
			destination = get_step(destination, EAST)

		else if((direct & WEST) && x > 1)
			destination = get_step(destination, WEST)

		abstract_move(destination)//Get out of closets and such as a ghost

/mob/dead/observer/forceMove(atom/destination)
	abstract_move(destination) // move like the wind
	return TRUE

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"
	if(!client)
		return
	if(!mind || QDELETED(mind.current))
		to_chat(src, span_warning("You have no body."))
		return
	if(!can_reenter_corpse)
		to_chat(src, span_warning("You cannot re-enter your body."))
		return
	if(mind.current.key && mind.current.key[1] != "@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, span_warning("Another consciousness is in your body...It is resisting you."))
		return
	client.view_size.setDefault(getScreenSize(client.prefs.read_preference(/datum/preference/toggle/widescreen)))//Let's reset so people can't become allseeing gods
	SStgui.on_transfer(src, mind.current) // Transfer NanoUIs.
	mind.current.key = key
	mind.current.oobe_client = null //yogs
	mind.current.client.init_verbs()
	return TRUE

/mob/dead/observer/verb/stay_dead()
	set category = "Ghost"
	set name = "Do Not Resuscitate"
	if(!client)
		return
	if(!can_reenter_corpse)
		to_chat(usr, span_warning("You're already stuck out of your body!"))
		return FALSE

	var/response = tgui_alert(usr, "Are you sure you want to prevent (almost) all means of resuscitation? This cannot be undone. ","Are you sure you want to stay dead?",list("DNR","Save Me"))
	if(response != "DNR")
		return

	can_reenter_corpse = FALSE
	to_chat(src, "You can no longer be brought back into your body.")
	return TRUE

/mob/dead/observer/proc/notify_cloning(message, sound, atom/source, flashwindow = TRUE)
	if(flashwindow)
		window_flash(client)
	if(message)
		to_chat(src, span_ghostalert("[message]"))
		if(source)
			var/atom/movable/screen/alert/A = throw_alert("[REF(source)]_notify_cloning", /atom/movable/screen/alert/notify_cloning)
			if(A)
				var/ui_style = client?.prefs?.read_preference(/datum/preference/choiced/ui_style)
				if(ui_style)
					A.icon = ui_style2icon(ui_style)
				A.desc = message
				var/old_layer = source.layer
				var/old_plane = source.plane
				source.layer = FLOAT_LAYER
				source.plane = FLOAT_PLANE
				A.add_overlay(source)
				source.layer = old_layer
				source.plane = old_plane
	to_chat(src, span_ghostalert("<a href=byond://?src=[REF(src)];reenter=1>(Click to re-enter)</a>"))
	if(sound)
		SEND_SOUND(src, sound(sound))

/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Ghostly Magic"

	if(!jump_ui)
		jump_ui = new(src)

	jump_ui.ui_interact(src)

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Orbit" // "Haunt"
	set desc = "Follow and orbit a mob."

	if(!orbit_ui)
		orbit_ui = new(src)

	orbit_ui.ui_interact(src)

// This is the ghost's follow verb with an argument
/mob/dead/observer/proc/ManualFollow(atom/movable/target)
	if (!istype(target) || (is_secret_level(target.z) && !client?.holder))
		return

	//shitcode override so that if you try to follow the AI, you'll get redirected to the AI eye where they're actually looking
	if(isAI(target))
		var/mob/living/silicon/ai/ai_target = target
		if(ai_target.eyeobj)
			target = ai_target.eyeobj
	
	var/icon/I = icon(target.icon,target.icon_state,target.dir)

	var/orbitsize = (I.Width()+I.Height())*0.5
	orbitsize -= (orbitsize/world.icon_size)*(world.icon_size*0.25)

	var/rot_seg

	switch(ghost_orbit)
		if(GHOST_ORBIT_TRIANGLE)
			rot_seg = 3
		if(GHOST_ORBIT_SQUARE)
			rot_seg = 4
		if(GHOST_ORBIT_PENTAGON)
			rot_seg = 5
		if(GHOST_ORBIT_HEXAGON)
			rot_seg = 6
		else //Circular
			rot_seg = 36 //360/10 bby, smooth enough aproximation of a circle

	orbit(target,orbitsize, FALSE, 20, rot_seg)

/mob/dead/observer/orbit()
	setDir(2)//reset dir so the right directional sprites show up
	return ..()

/mob/dead/observer/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	//restart our floating animation after orbit is done.
	pixel_y = 0
	animate(src, pixel_y = 2, time = 1 SECONDS, loop = -1)

/mob/dead/observer/verb/change_view_range()
	set category = "Ghost"
	set name = "View Range"
	set desc = "Change your view range."

	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !is_admin(usr))
		to_chat(usr, span_warning("Observer view range is disabled due to performance concerns."))
		return
	//yogs start -- Divert this verb to the admin variant if this guy has it
	if(is_admin(usr) && hascall(usr.client,"toggle_view_range"))
		call(usr.client,"toggle_view_range")()
		return
	//yogs end
	var/max_view = client.prefs.unlock_content ? GHOST_MAX_VIEW_RANGE_MEMBER : GHOST_MAX_VIEW_RANGE_DEFAULT
	if(client.view_size.getView() == client.view_size.default)
		var/list/views = list()
		for(var/i in 7 to max_view)
			views |= i
		var/new_view = tgui_input_list(usr, "Choose your new view", "Modify view range", views)
		if(new_view)
			client.rescale_view(new_view, 0, ((max_view*2)+1) - 15)
	else
		client.view_size.resetToDefault()

/mob/dead/observer/verb/add_view_range(input as num)
	set name = "Add View Range"
	set hidden = TRUE
	var/max_view = client.prefs.unlock_content ? GHOST_MAX_VIEW_RANGE_MEMBER : GHOST_MAX_VIEW_RANGE_DEFAULT
	if(input)
		client.rescale_view(input, 0, ((max_view*2)+1) - 15)

/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time)
		return
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
		bootime = world.time + 600
		return
	//Maybe in the future we can add more <i>spooky</i> code here!
	return


/mob/dead/observer/memory()
	set hidden = TRUE
	to_chat(src, span_danger("You are dead! You have no mind to store memory!"))

/mob/dead/observer/add_memory()
	set hidden = TRUE
	to_chat(src, span_danger("You are dead! You have no mind to store memory!"))

/mob/dead/observer/verb/toggle_ghostsee()
	set name = "Toggle Ghost Vision"
	set desc = "Toggles your ability to see things only ghosts can see, like other ghosts"
	set category = "Ghost"
	ghostvision = !(ghostvision)
	update_sight()
	to_chat(usr, "You [ghostvision ? "now" : "no longer"] have ghost vision.")

/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	switch(lighting_cutoff)
		if (LIGHTING_CUTOFF_VISIBLE)
			lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
		if (LIGHTING_CUTOFF_MEDIUM)
			lighting_cutoff = 50
		if (50)
			lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
		else
			lighting_cutoff = LIGHTING_CUTOFF_VISIBLE

	update_sight()

/mob/dead/observer/update_sight()
	if(client)
		ghost_others = client.prefs.read_preference(/datum/preference/choiced/ghost_others) //A quick update just in case this setting was changed right before calling the proc

	if (!ghostvision)
		set_invis_see(SEE_INVISIBLE_LIVING)
	else
		set_invis_see(SEE_INVISIBLE_OBSERVER)


	updateghostimages()
	..()

/proc/updateallghostimages()
	listclearnulls(GLOB.ghost_images_default)
	listclearnulls(GLOB.ghost_images_simple)

	for (var/mob/dead/observer/O in GLOB.player_list)
		O.updateghostimages()

/mob/dead/observer/proc/updateghostimages()
	if (!client)
		return

	if(lastsetting)
		switch(lastsetting) //checks the setting we last came from, for a little efficiency so we don't try to delete images from the client that it doesn't have anyway
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client.images -= GLOB.ghost_images_default
			if(GHOST_OTHERS_SIMPLE)
				client.images -= GLOB.ghost_images_simple
	lastsetting = client.prefs.read_preference(/datum/preference/choiced/ghost_others)
	if(!ghostvision)
		return
	if(lastsetting != GHOST_OTHERS_THEIR_SETTING)
		switch(lastsetting)
			if(GHOST_OTHERS_DEFAULT_SPRITE)
				client.images |= (GLOB.ghost_images_default-ghostimage_default)
			if(GHOST_OTHERS_SIMPLE)
				client.images |= (GLOB.ghost_images_simple-ghostimage_simple)

/mob/dead/observer/verb/possess()
	set category = "Ghost"
	set name = "Possess!"
	set desc= "Take over the body of a mindless creature!"

	var/list/possessible = list()
	for(var/mob/living/L in GLOB.alive_mob_list)
		if(istype(L,/mob/living/carbon/human/dummy) || !get_turf(L)) //Haha no.
			continue
		if(!(L in GLOB.player_list) && !L.mind)
			possessible += L

	var/mob/living/target = tgui_input_list(usr, "Your new life begins today!", "Possess Mob", sortUsernames(possessible))

	if(!target)
		return 0

	if(ismegafauna(target) || (target.status_flags & GODMODE))
		to_chat(src, span_warning("This creature is too powerful for you to possess!"))
		return 0

	if(can_reenter_corpse && mind?.current)
		if(tgui_alert(usr, "Your soul is still tied to your former life as [mind.current.name], if you go forward there is no going back to that life. Are you sure you wish to continue?", "Move On", list("Yes", "No")) == "No")
			return FALSE
	if(target.key)
		to_chat(src, span_warning("Someone has taken this body while you were choosing!"))
		return 0

	target.key = key
	target.faction = list("neutral")
	return 1

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overridden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message(span_deadsay("<b>[src]</b> points to [A]."))
	return 1

/mob/dead/observer/verb/view_manifest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	if(!client)
		return
	if(world.time < client.crew_manifest_delay)
		return
	client.crew_manifest_delay = world.time + (1 SECONDS)

	var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"
	dat += "<h4>Crew Manifest</h4>"
	dat += GLOB.data_core.get_manifest_html()
	dat += "</BODY></HTML>"

	src << browse(dat, "window=manifest;size=387x420;can_close=1")

//this is called when a ghost is drag clicked to something.
/mob/dead/observer/MouseDrop(atom/over)
	if(!usr || !over)
		return
	if (isobserver(usr) && usr.client.holder && (isliving(over) || iscameramob(over)) )
		if (usr.client.holder.cmd_ghost_drag(src,over))
			return

	return ..()

/mob/dead/observer/Topic(href, href_list)
	..()
	if(usr == src)
		if(href_list["follow"])
			var/atom/movable/target = locate(href_list["follow"])
			if(istype(target) && (target != src))
				ManualFollow(target)
				return
		if(href_list["x"] && href_list["y"] && href_list["z"])
			var/tx = text2num(href_list["x"])
			var/ty = text2num(href_list["y"])
			var/tz = text2num(href_list["z"])
			var/turf/target = locate(tx, ty, tz)
			if(istype(target))
				forceMove(target)
				return
		if(href_list["reenter"])
			reenter_corpse()
			return

//We don't want to update the current var
//But we will still carry a mind.
/mob/dead/observer/mind_initialize()
	return

/mob/dead/observer/proc/show_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = GLOB.huds[hudtype]
		H.show_to(src)

/mob/dead/observer/proc/remove_data_huds()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = GLOB.huds[hudtype]
		H.hide_from(src)

/mob/dead/observer/verb/toggle_data_huds()
	set name = "Toggle Sec/Med/Diag HUD"
	set desc = "Toggles whether you see medical/security/diagnostic HUDs"
	set category = "Ghost"

	if(data_huds_on) //remove old huds
		remove_data_huds()
	else
		show_data_huds()

	data_huds_on = !data_huds_on
	to_chat(src, span_notice("Data HUDs [data_huds_on ? "enabled" : "disabled"]."))

/mob/dead/observer/verb/toggle_health_scan()
	set name = "Toggle Health Scan"
	set desc = "Toggles whether you health-scan living beings on click"
	set category = "Ghost"

	scanmode ^= SCAN_HEALTH
	to_chat(src, span_notice("Health scan [scanmode & SCAN_HEALTH ? "enabled" : "disabled"]."))

/mob/dead/observer/verb/toggle_chemical_scan()
	set name = "Toggle Chemical Scan"
	set desc = "Toggles whether you chem-scan living beings on click"
	set category = "Ghost"

	scanmode ^= SCAN_CHEM
	to_chat(src, span_notice("Chemical scan [scanmode & SCAN_CHEM ? "enabled" : "disabled"]."))

/mob/dead/observer/verb/toggle_nanite_scan()
	set name = "Toggle Nanite Scan"
	set desc = "Toggles scanning of nanites"
	set category = "Ghost"

	scanmode ^= SCAN_NANITE
	to_chat(src, span_notice("Nanite scan [scanmode & SCAN_NANITE ? "enabled" : "disabled"]."))

/mob/dead/observer/verb/toggle_wound_scan()
	set name = "Toggle Wound Scan"
	set desc = "Toggles scanning of wounds"
	set category = "Ghost"

	scanmode ^= SCAN_WOUND
	to_chat(src, span_notice("Wound scan [scanmode & SCAN_WOUND ? "enabled" : "disabled"]."))

/mob/dead/observer/verb/toggle_gas_scan()
	set name = "Toggle Gas Scan"
	set desc = "Toggles whether you analyze gas contents on click"
	set category = "Ghost"

	scanmode ^= SCAN_GAS
	to_chat(src, span_notice("Gas scan [scanmode & SCAN_GAS ? "enabled" : "disabled"]."))

/mob/dead/observer/verb/restore_ghost_appearance()
	set name = "Restore Ghost Character"
	set desc = "Sets your deadchat name and ghost appearance to your \
		roundstart character."
	set category = "Ghost"

	set_ghost_appearance()
	if(client?.prefs)
		var/real_name = client.prefs.read_preference(/datum/preference/name/real_name)
		deadchat_name = real_name
		if(mind)
			mind.name = real_name
		name = real_name

/mob/dead/observer/proc/set_ghost_appearance()
	if((!client) || (!client.prefs))
		return

	client.prefs.apply_character_randomization_prefs()

	var/species_type = client.prefs.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type

	if(HAIR in species.species_traits)
		hair_style = client.prefs.read_preference(/datum/preference/choiced/hairstyle)
		hair_color = brighten_color(client.prefs.read_preference(/datum/preference/color/hair_color))

	if(FACEHAIR in species.species_traits)
		facial_hair_style = client.prefs.read_preference(/datum/preference/choiced/facial_hairstyle)
		facial_hair_color = brighten_color(client.prefs.read_preference(/datum/preference/color/facial_hair_color))
	
	qdel(species)

	update_appearance()

/mob/dead/observer/canUseTopic(atom/movable/M, be_close=FALSE, no_dexterity=FALSE, no_tk=FALSE)
	return IsAdminGhost(usr)

/mob/dead/observer/is_literate()
	return TRUE

/mob/dead/observer/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if("icon")
			ghostimage_default.icon = icon
			ghostimage_simple.icon = icon
		if("icon_state")
			ghostimage_default.icon_state = icon_state
			ghostimage_simple.icon_state = icon_state
		if("fun_verbs")
			if(fun_verbs)
				add_verb(src, /mob/dead/observer/verb/boo)
				add_verb(src, /mob/dead/observer/verb/possess)
			else
				remove_verb(src, /mob/dead/observer/verb/boo)
				remove_verb(src, /mob/dead/observer/verb/possess)

/mob/dead/observer/reset_perspective(atom/A)
	unobserve_button?.Remove(src)
	if(client)
		if(ismob(client.eye) && (client.eye != src))
			cleanup_observe()
	if(..())
		if(hud_used)
			client.clear_screen()
			hud_used.show_hud(hud_used.hud_version)


/mob/dead/observer/proc/cleanup_observe()
	if(isnull(observetarget))
		return
	var/mob/target = observetarget
	observetarget = null
	client?.perspective = initial(client.perspective)
	set_sight(initial(sight))
	if(target)
		UnregisterSignal(target, COMSIG_MOVABLE_Z_CHANGED)
		hide_other_mob_action_buttons(target)
		LAZYREMOVE(target.observers, src)
	unobserve_button.Remove(src)
	update_action_buttons()

/mob/dead/observer/verb/observe()
	set name = "Observe"
	set category = "Ghost"

	if(!isobserver(usr)) //Make sure they're an observer!
		return

	reset_perspective(null)

	var/list/possible_destinations = getpois()
	var/target = null

	target = tgui_input_list(usr, "Please, select a player!", "Jump to Mob", possible_destinations)
	if(isnull(target))
		return
	if(!isobserver(usr))
		return

	// In nullspace, invalid as a POI. provisonary till we get new POI system
	if(ismob(target))
		var/mob/mob_target = target
		if(!mob_target.loc)
			return

	reset_perspective(null)

	var/mob/chosen_target = possible_destinations[target]

	do_observe(chosen_target)

/mob/dead/observer/proc/do_observe(mob/mob_eye)
	if(isnewplayer(mob_eye))
		stack_trace("/mob/dead/new_player: \[[mob_eye]\] is being observed by [key_name(src)]. This should never happen and has been blocked.")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone in the lobby: [ADMIN_LOOKUPFLW(mob_eye)]. This should not be possible and has been blocked.")
		return
	
	if(!isnull(observetarget))
		stack_trace("do_observe called on an observer ([src]) who was already observing something! (observing: [observetarget], new target: [mob_eye])")
		message_admins("[ADMIN_LOOKUPFLW(src)] attempted to observe someone while already observing someone, \
			this is a bug (and a past exploit) and should be investigated.")
		return

	//Istype so we filter out points of interest that are not mobs
	if(client && mob_eye && istype(mob_eye))
		client.set_eye(mob_eye)
		client.perspective = EYE_PERSPECTIVE
		if(is_secret_level(mob_eye.z) && !client?.holder)
			set_sight(null) //we dont want ghosts to see through walls in secret areas
		RegisterSignal(mob_eye, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_observing_z_changed), TRUE)
		if(!unobserve_button)
			unobserve_button = new(src)
		unobserve_button.Grant(src)
		if(mob_eye.hud_used)
			client.clear_screen()
			LAZYOR(mob_eye.observers, src)
			mob_eye.hud_used.show_hud(mob_eye.hud_used.hud_version, src)
			observetarget = mob_eye

/mob/dead/observer/proc/on_observing_z_changed(datum/source, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(is_secret_level(new_turf.z) && !client?.holder)
		set_sight(null) //we dont want ghosts to see through walls in secret areas
	else
		set_sight(initial(sight))

/datum/action/innate/unobserve
	name = "Stop Observing"
	desc = "Stops observing the person."
	button_icon = 'icons/mob/mob.dmi'
	button_icon_state = "ghost_nodir"
	show_to_observers = FALSE

/datum/action/innate/unobserve/Activate()
	owner.reset_perspective(null)

/datum/action/innate/unobserve/IsAvailable(feedback = FALSE)
	return TRUE

/mob/dead/observer/verb/register_pai_candidate()
	set category = "Ghost"
	set name = "pAI Setup"
	set desc = "Upload a fragment of your personality to the global pAI databanks"

	register_pai()

/mob/dead/observer/proc/register_pai()
	if(isobserver(src))
		SSpai.recruitWindow(src)
	else
		to_chat(usr, "Can't become a pAI candidate while not dead!")

/mob/dead/observer/CtrlShiftClick(mob/user)
	if(isobserver(user) && check_rights(R_SPAWN))
		change_mob_type( /mob/living/carbon/human , null, null, TRUE) //always delmob, ghosts shouldn't be left lingering

/mob/dead/observer/examine(mob/user)
	. = ..()
	if(!invisibility)
		. += "It seems extremely obvious."

/mob/dead/observer/proc/set_invisibility(value)
	invisibility = value
	set_light_on(!value ? TRUE : FALSE)

// Ghosts have no momentum, being massless ectoplasm
/mob/dead/observer/Process_Spacemove(movement_dir)
	return 1

/mob/dead/observer/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, invisibility))
		set_invisibility(invisibility) // updates light

/proc/set_observer_default_invisibility(amount, message=null)
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.set_invisibility(amount)
		if(message)
			to_chat(G, message)
	GLOB.observer_default_invisibility = amount

/mob/dead/observer/proc/open_spawners_menu()
	set name = "Spawners Menu"
	set desc = "See all currently available spawners"
	set category = "Ghost"
	if(!spawners_menu)
		spawners_menu = new(src)

	spawners_menu.ui_interact(src)

/mob/dead/observer/proc/tray_view()
	set category = "Ghost"
	set name = "T-ray view"
	set desc = "Toggles a view of sub-floor objects"
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !is_admin(usr))
		to_chat(usr, span_warning("Observer T-ray view is disabled due to performance concerns."))
		return

	var/static/t_ray_view = FALSE
	t_ray_view = !t_ray_view

	var/list/t_ray_images = list()
	var/static/list/stored_t_ray_images = list()
	for(var/obj/O in orange(client.view, src) )
		if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	stored_t_ray_images += t_ray_images
	if(length(t_ray_images))
		if(t_ray_view)
			client.images += t_ray_images
		else
			client.images -= stored_t_ray_images

/mob/dead/observer/proc/possess_mouse_verb()
	set category = "Ghost"
	set name = "Possess a mouse"
	set desc = "Possess a mouse to haunt the station.... and their food!"

	var/list/possessible = list()

	for(var/mob/living/simple_animal/mouse/M in GLOB.alive_mob_list)
		if(M.stat != CONSCIOUS) continue
		if(M.key) continue
		if(M in GLOB.player_list) continue
		if(M.mind) continue
		if(!is_station_level(M.z)) continue

		possessible += M

	if(!possessible.len)
		to_chat(src, span_warning("There are currently no mice able to be possessed!"))
		return FALSE

	var/mob/living/simple_animal/mouse/M = pick(possessible)

	possess_mouse(M)


/mob/dead/observer/proc/possess_mouse(mob/living/simple_animal/mouse/M)
	if(!M)
		return FALSE

	if(!SSticker.HasRoundStarted())
		to_chat(usr, span_warning("The round hasn't started yet!"))
		return FALSE

	if(is_banned_from(key, ROLE_MOUSE))
		to_chat(src, span_warning("You are banned from being a mouse!"))
		return FALSE

	if(alert("Are you sure you want to become a mouse? (Warning, you can no longer be cloned!)",,"Yes","No") != "Yes")
		return FALSE

	if(M.key || (M.stat != CONSCIOUS) || (M in GLOB.player_list) || M.mind || QDELETED(src) || QDELETED(M))
		to_chat(src, "<span class='warning'>This mouse is unable to be controlled, please try again!")
		return FALSE

	log_game("[key_name(src)] has became a mouse")

	M.key = key
	M.faction = list("neutral")
	M.chew_probability = 0 //so they cant pull off a big brain play by ghosting somewhere or idk
	M.layer = BELOW_OPEN_DOOR_LAYER //ENGAGE ADVANCED HIDING BRAIN FUNCTIONS
	M.language_holder = new /datum/language_holder/mouse(M)
	M.pass_flags |= PASSDOOR
	M.sentience_act()
	M.maxHealth = 15
	M.health = M.maxHealth

	to_chat(M , "<span class='warning'>You are now possessing a mouse. \
				You do not remember your previous life. You can eat trash and \
				food on the floor to gain health and help create new mice. Mouse traps will hurt your fragile body \
				and so will any kind of weapons. You can control click food and trash items in order to eat them. Get. That. Cheese.")
	return TRUE

