GLOBAL_LIST_EMPTY(vertical_parallax_objects)
/datum/component/vertical_parallax

/datum/component/vertical_parallax/Initialize()
	. = ..()
	GLOB.vertical_parallax_objects += src

/datum/component/vertical_parallax/Destroy()
	GLOB.vertical_parallax_objects -= src
	return ..()

/datum/component/vertical_parallax/proc/get_images(turf/viewer)
	return null

//   viewer    - the turf that views it
//   I         - an image or a mutable appearance or whatever - this is modified
//   dir       - the direction in which to offset the vertical sprite
//   ramp      - Makes it so that the top edge is in the opposite direction of dir
//   dir_depth - The offset in pixels to offset the image
//   pixel_x   - The pixel_x of the PARENT
//   pixel_y   - The pixel_y of the PARENT
// Returns TRUE if the player is looking at the front face and FALSE if the player is looking at the back face
// return value can be used for basic backface culling to avoid clipping artifacts.
// Note - you can modify the transform of the passed image object before passing it
/datum/component/vertical_parallax/proc/transform_image(turf/viewer, image/I, dir = 2, ramp = FALSE, dir_depth = 16, pixel_x = 0, pixel_y = 0)
	var/atom/A = parent
	var/dx = (A.x - viewer.x) + (pixel_x/32)
	var/dy = (A.y - viewer.y) + (pixel_y/32)
	var/x1
	var/y1
	if(dir & 1)
		x1 = -dx
		y1 = -dy
	else if(dir & 2)
		x1 = dx
		y1 = dy
	else if(dir & 4)
		x1 = dy
		y1 = -dx
	else
		x1 = -dy
		y1 = dx
	var/x2 = x1
	var/y2 = y1
	y1 -= dir_depth/32
	if(ramp)
		y2 += dir_depth/32
	else
		y2 -= dir_depth/32
		// do some really basic distance sorting so farther-away shit displays under closer shit. only really necessary for pipes for now.
		// this will break for layers 32 and above, so uhhh if you plan to use vertical parallax on something that's layer 32 or higher, consider not doing so, thanks you and have a day.
		I.layer += 0.0005 - (0.00006103515625 * (abs(x1)+abs(y1)))
	x2 *= (16/15)
	y2 *= (16/15)
	var/matrix/M = I.transform
	M.Translate(0,16)
	M.Multiply(matrix(1, (x2-x1), 0, 0, (y2-y1), 0))
	M.Translate(0,-dir_depth)
	M.Turn(180 + dir2angle(dir))
	I.transform = M
	return (y2 > y1)

/datum/component/vertical_parallax/stairs/get_images(turf/viewer)
	var/atom/A = parent
	var/list/L = list()

	var/mutable_appearance/MP = mutable_appearance(A.icon, A.icon_state, A.layer)
	transform_image(viewer, MP, turn(A.dir, 180), TRUE)
	L += MP

	MP = mutable_appearance(A.icon, "left", A.layer - 0.01)
	if(transform_image(viewer, MP, turn(A.dir, 90)))
		L += MP
	
	MP = mutable_appearance(A.icon, "right", A.layer - 0.01)
	if(transform_image(viewer, MP, turn(A.dir, -90)))
		L += MP
	
	MP = mutable_appearance(A.icon, "back", A.layer - 0.01)
	if(transform_image(viewer, MP, A.dir))
		L += MP

	var/image/I = image(loc = A, dir = NORTH)
	I.overlays = L
	I.override = TRUE

	return I

/datum/component/vertical_parallax/disposal/get_images(turf/viewer)
	var/atom/A = parent
	var/list/L = list()

	for(var/dir in GLOB.cardinals)
		var/mutable_appearance/MP = mutable_appearance('icons/obj/atmospherics/pipes/disposal.dmi', "pipe-vertical", ABOVE_OBJ_LAYER)
		if(transform_image(viewer, MP, dir, dir_depth = 7))
			L += MP
	L += mutable_appearance('icons/obj/atmospherics/pipes/disposal.dmi', "cap", BELOW_SPACE_LAYER, OVERLAY_PLANE(FLOOR_PLANE + PLANE_ZLEVEL_OFFSET, GAME_PLANE))
	
	var/image/I = image(loc = A)
	I.overlays = L
	I.appearance_flags |= RESET_ALPHA | KEEP_APART // no transparency please
	I.plane = OVERLAY_PLANE(GAME_PLANE, A.plane)

	return I

/datum/component/vertical_parallax/pipe/get_images(turf/viewer)
	var/obj/machinery/atmospherics/pipe/A = parent
	var/list/L = list()
	
	var/image/I = image(loc = A)
	I.plane = OVERLAY_PLANE(GAME_PLANE, A.plane)
	I.appearance_flags |= RESET_ALPHA | KEEP_APART // no transparency please
	PIPING_LAYER_DOUBLE_SHIFT(I, A.piping_layer) // hah my multiz pipes support pipe layers.

	for(var/dir in GLOB.cardinals)
		var/use_b = (dir == NORTH || dir == EAST)
		var/mutable_appearance/MP = mutable_appearance('icons/obj/atmospherics/pipes/multiz.dmi', "pipe11-v[use_b ? "b" : "a"]", ABOVE_OBJ_LAYER)
		if(transform_image(viewer, MP, dir, dir_depth = (dir == NORTH || dir == WEST) ? 3 : 2, pixel_x = I.pixel_x, pixel_y = I.pixel_y))
			L += MP
	L += mutable_appearance('icons/obj/atmospherics/pipes/multiz.dmi', "cap", BELOW_SPACE_LAYER, OVERLAY_PLANE(FLOOR_PLANE + PLANE_ZLEVEL_OFFSET, GAME_PLANE))
	
	I.overlays = L

	return I

/datum/component/vertical_parallax/cable/get_images(turf/viewer)
	var/obj/structure/cable/A = parent
	var/mutable_appearance/MP = mutable_appearance('icons/obj/power_cond/cables.dmi', (A.d1 == SOUTH || A.d2 == WEST) ? "vertical-SW" : "vertical-NE", ABOVE_OBJ_LAYER, OVERLAY_PLANE(GAME_PLANE, A.plane))
	if(transform_image(viewer, MP, turn(A.d1, 180), dir_depth = -16))
		MP.appearance_flags |= RESET_ALPHA | KEEP_APART // no transparency please
		var/image/I = image(loc = A)
		I.appearance = MP
		return I
