/datum/component/see_as_something
	var/datum/weakref/creature
	var/image_icon_state
	var/image_icon
	var/image/funny_image
	var/delusion_name

/datum/component/see_as_something/Initialize(atom/movable/seer, image_icon_state, image_icon, create_name)
	. = ..()
	if(!seer)
		return
	creature = WEAKREF(seer)
	src.image_icon_state = image_icon_state
	src.image_icon = image_icon
	delusion_name = create_name

	setup_image()

/datum/component/see_as_something/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_CLEAR_SEE, PROC_REF(remove))

/datum/component/see_as_something/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_CLEAR_SEE)

/datum/component/see_as_something/Destroy(force, silent)
	. = ..()
	remove_image()


/datum/component/see_as_something/proc/setup_image()
	var/atom/movable/resolved = creature.resolve()

	funny_image = image(image_icon, resolved, image_icon_state)
	funny_image.name = delusion_name
	funny_image.override = TRUE

	var/mob/parent_mob = parent

	parent_mob.client?.images += funny_image

/datum/component/see_as_something/proc/remove()
	qdel(src)

/datum/component/see_as_something/proc/remove_image()
	var/mob/parent_mob = parent
	parent_mob.client?.images -= funny_image
