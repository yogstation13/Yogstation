/obj/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY
	var/show_alpha = 255
	var/hide_alpha = 0
	var/is_multiz_plane = TRUE
	var/multiz_level = 0
	var/multiz_tint_factor = 0.75 // making lower z-levels darker than higher ones is like a depth cue or something I think.
	var/multiz_scale = 1

/obj/screen/plane_master/proc/Show(override)
	alpha = override || show_alpha

/obj/screen/plane_master/proc/Hide(override)
	alpha = override || hide_alpha

//Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/obj/screen/plane_master/proc/backdrop(mob/mymob)

/obj/screen/plane_master/proc/set_level(level_num = 0, appearance_only = FALSE)
	if(!appearance_only)
		plane = ADJUSTED_PLANE(initial(plane), level_num)
	var/scale = 1 - (level_num / 16)
	var/tint = 255 * (multiz_tint_factor ** level_num)
	color = rgb(tint,tint,tint)
	transform = matrix(scale,0,0,0,scale,0)
	if(!appearance_only)
		multiz_scale = scale
		multiz_level = level_num

/obj/screen/plane_master/proc/animate_level_change(level_offset_from = 0, delay = 10)
	if(!is_multiz_plane)
		return
	var/to_appearance = appearance
	set_level(multiz_level + level_offset_from, TRUE)
	var/from_appearance = appearance
	if(to_appearance == from_appearance)
		appearance = to_appearance
		return
	animate(src, appearance = to_appearance, time = delay) 

/obj/screen/plane_master/proc/apply_lighting(mob/mymob)
	var/obj/screen/S = mymob.overlay_fullscreen("lighting_proxy_p[plane]", /obj/screen/fullscreen/lighting_proxy)
	S.transform = matrix(1/multiz_scale,0,0,0,1/multiz_scale,0)
	// Each plane that's lit gets a lighting proxy. This is to make sure that the lighting of different z-levels don't interfere with each other.
	S.plane = plane
	S.render_source = "*light_[multiz_level]"

/*/obj/screen/plane_master/openspace
	name = "open space plane master"
	plane = FLOOR_OPENSPACE_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_MULTIPLY
	alpha = 255

/obj/screen/plane_master/openspace/backdrop(mob/mymob)
	filters = list()
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -10)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -15)
	filters += filter(type = "drop_shadow", color = "#04080FAA", size = -20)*/

/obj/screen/plane_master/proc/outline(_size, _color)
	filters += filter(type = "outline", size = _size, color = _color)

/obj/screen/plane_master/proc/shadow(_size, _border, _offset = 0, _x = 0, _y = 0, _color = "#04080FAA")
	filters += filter(type = "drop_shadow", x = _x, y = _y, color = _color, size = _size, offset = _offset)

/obj/screen/plane_master/proc/clear_filters()
	filters = list()

/obj/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/floor/backdrop(mob/mymob)
	filters = list()
	// floors get AO too I guess. It's such an important depth cue as well, so I'm not gonna give you the option to turn it off. (also because I want this AO but not the other AO)
	filters += AMBIENT_OCCLUSION
	if(istype(mymob) && mymob.eye_blurry)
		filters += GAUSSIAN_BLUR(clamp(mymob.eye_blurry*0.1,0.6,3))
	apply_lighting(mymob)

/obj/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/obj/screen/plane_master/game_world/backdrop(mob/mymob)
	filters = list()
	if(istype(mymob) && mymob.client && mymob.client.prefs && mymob.client.prefs.ambientocclusion)
		filters += AMBIENT_OCCLUSION
	if(istype(mymob) && mymob.eye_blurry)
		filters += GAUSSIAN_BLUR(clamp(mymob.eye_blurry*0.1,0.6,3))
	apply_lighting(mymob)

/obj/screen/plane_master/above_lighting
	name = "above lighting plane master"
	plane = ABOVE_LIGHTING_PLANE

/obj/screen/plane_master/blackness
	name = "blackness plane master"
	plane = BLACKNESS_PLANE

/obj/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	//blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/plane_master/lighting/animate_level_change()
	return

/obj/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	is_multiz_plane = FALSE

/obj/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE
	multiz_tint_factor = 1 // space should always show through

/obj/screen/plane_master/lighting/set_level(level_num)
	. = ..()
	render_target = "*light_[level_num]"

/obj/screen/plane_master/lighting/backdrop(mob/mymob)
	var/obj/screen/S = mymob.overlay_fullscreen("lighting_backdrop_lit_l[multiz_level]", /obj/screen/fullscreen/lighting_backdrop/lit)
	S.plane = plane
	S = mymob.overlay_fullscreen("lighting_backdrop_unlit_l[multiz_level]", /obj/screen/fullscreen/lighting_backdrop/unlit)
	S.plane = plane

/obj/screen/plane_master/camera_static
	name = "camera static plane master"
	plane = CAMERA_STATIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
