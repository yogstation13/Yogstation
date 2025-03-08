#define NAME_TAG_WIDTH (world.icon_size * 5)

/datum/keybinding/mob/show_names
	hotkey_keys = list("Ctrl")
	name = "show_names"
	full_name = "Show Names"
	description = "Lets you see peoples names."
	keybind_signal = COMSIG_KB_MOB_SHOW_NAMES_DOWN

/datum/keybinding/mob/show_names/down(client/user)
	. = ..()
	if(.)
		return
	for(var/atom/movable/screen/plane_master/name_tags/name_tag as anything in user.mob?.hud_used.get_true_plane_masters(PLANE_NAME_TAGS))
		name_tag.alpha = 255

/datum/keybinding/mob/show_names/up(client/user)
	. = ..()
	if(.)
		return
	for(var/atom/movable/screen/plane_master/name_tags/name_tag as anything in user.mob?.hud_used.get_true_plane_masters(PLANE_NAME_TAGS))
		name_tag.alpha = 0

/mob
	var/obj/effect/abstract/name_tag/name_tag
	var/atom/movable/screen/name_shadow/shadow

/mob/Initialize(mapload)
	. = ..()
	name_tag = new(src)
	//SET_PLANE_EXPLICIT(name_tag, PLANE_NAME_TAGS, src)
	update_name_tag()

/mob/Login()
	. = ..()
	if(client && isliving(src) && (!iscyborg(src) && !isaicamera(src) && !isAI(src)))
		shadow = new(src)
		SET_PLANE_EXPLICIT(shadow, PLANE_NAME_TAGS_BLOCKER, src)
		client.screen += shadow
		hud_used.always_visible_inventory += shadow

/mob/Logout()
	if(client && isliving(src) && (!iscyborg(src) && !isaicamera(src) && !isAI(src)))
		client.screen -= shadow
		shadow.UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
		hud_used?.always_visible_inventory -= shadow
		QDEL_NULL(shadow)
	return ..()

/mob/Destroy()
	QDEL_NULL(name_tag)
	if(shadow)
		client?.screen -= shadow
		shadow.UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
		hud_used.always_visible_inventory -= shadow
		QDEL_NULL(shadow)
	return ..()

/mob/proc/update_name_tag(passed_name)
	if(QDELETED(name_tag))
		return
	if(!passed_name)
		passed_name = name

	var/the_check = findtext(passed_name, " the")
	if(the_check)
		passed_name = copytext(passed_name, 1, the_check)
	name_tag.set_name(name)

/mob/fully_replace_character_name(oldname, newname)
	. = ..()
	if(oldname != real_name)
		update_name_tag(real_name)

/mob/living/set_name()
	. = ..()
	update_name_tag()

/mob/living/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, name) || var_name == NAMEOF(src, real_name))
		update_name_tag()

/obj/effect/abstract/name_tag
	name = ""
	icon = null // we want nothing
	alpha = 180
	plane = PLANE_NAME_TAGS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	maptext_y = -13 //directly below characters
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_TRANSFORM

/obj/effect/abstract/name_tag/Initialize(mapload)
	. = ..()
	if(!ismovable(loc) || QDELING(loc))
		return INITIALIZE_HINT_QDEL
	var/atom/movable/movable_loc = loc
	movable_loc.vis_contents += src
	var/bound_width = movable_loc.bound_width || world.icon_size
	maptext_width = NAME_TAG_WIDTH
	maptext_height = world.icon_size * 1.5
	maptext_x = ((NAME_TAG_WIDTH - bound_width) * -0.5) - loc.base_pixel_x
	maptext_y = src::maptext_y - loc.base_pixel_y
	RegisterSignal(loc, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z))

/obj/effect/abstract/name_tag/Destroy(force)
	if(ismovable(loc))
		var/atom/movable/movable_loc = loc
		movable_loc.vis_contents -= src
	UnregisterSignal(loc, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/obj/effect/abstract/name_tag/forceMove(atom/destination, no_tp = FALSE, harderforce = FALSE)
	if(harderforce)
		return ..()

/obj/effect/abstract/name_tag/proc/hide()
	alpha = 0

/obj/effect/abstract/name_tag/proc/show()
	alpha = 255

/obj/effect/abstract/name_tag/proc/set_name(incoming_name)
	maptext = MAPTEXT_GRAND9K("<span style='text-align: center'>[incoming_name]</span>")

/obj/effect/abstract/name_tag/proc/update_z(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SET_PLANE(src, PLANE_TO_TRUE(src.plane), new_turf)

/atom/movable/screen/plane_master/name_tags
	name = "name tag plane"
	plane = PLANE_NAME_TAGS
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)
	alpha = 0

/atom/movable/screen/plane_master/name_tags/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(NAME_TAG_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/name_tag_blocker
	name = "name tag blocker blocker"
	documentation = "This is one of those planes that's only used as a filter. It masks out things that want to be hidden by fov.\
		<br>Literally just contains FOV images, or masks."
	plane = PLANE_NAME_TAGS_BLOCKER
	render_target = NAME_TAG_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/name_shadow
	icon = 'monkestation/code/modules/ranching/name_tags/covers.dmi'
	icon_state = "alpha-blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = PLANE_NAME_TAGS_BLOCKER
	screen_loc = "BOTTOM,LEFT"

#undef NAME_TAG_WIDTH
