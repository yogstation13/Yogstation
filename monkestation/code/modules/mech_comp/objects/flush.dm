/obj/item/mcobject/flusher
	name = "Flusher Component"
	icon_state = "comp_flush"
	base_icon_state = "comp_flush"

	COOLDOWN_DECLARE(flush_cd)

	///the trunk located below this object
	var/obj/structure/disposalpipe/trunk/trunk = null
	///the max amount of items we can flush at once
	var/max_capacity = 100
	/// Typecache of things that the flusher will ignore.
	var/static/list/flush_blacklist

/obj/item/mcobject/flusher/Initialize(mapload)
	. = ..()
	if(isnull(flush_blacklist))
		// keeping this as minimal as possible because it's kinda funny - only non-living mobs (i.e ghosts or camera eyes) and abstract effects are ignored.
		flush_blacklist = zebra_typecacheof(list(
			/mob = TRUE,
			/mob/living = FALSE,
			/obj/effect/abstract = TRUE,
		))
	MC_ADD_INPUT("flush", flush)

/obj/item/mcobject/flusher/Destroy(force)
	trunk = null
	return ..()

/obj/item/mcobject/flusher/default_unfasten_wrench(mob/user, obj/item/wrench, time)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			trunk_check()
		else
			trunk = null

/obj/item/mcobject/flusher/proc/flush(datum/mcmessage/input)
	if(!trunk_check() || !COOLDOWN_FINISHED(src, flush_cd) || !input?.cmd)
		return

	var/count = 0
	for(var/atom/movable/thing in loc)
		if(thing.anchored || is_type_in_typecache(thing, flush_blacklist))
			continue
		if(count == max_capacity)
			break
		count++
		thing.forceMove(src)

	flick("comp_flush1", src)
	COOLDOWN_START(src, flush_cd, 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_flush)), 0.5 SECONDS)

/obj/item/mcobject/flusher/proc/finish_flush()
	var/obj/structure/disposalholder/holder = new(src)
	holder.init(src)
	holder.forceMove(trunk)
	holder.active = TRUE
	holder.setDir(DOWN)
	holder.start_moving()

/obj/item/mcobject/flusher/proc/expel(obj/structure/disposalholder/holder)
	playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)
	flick("comp_flush1", src)
	pipe_eject(holder)

	holder.vent_gas(loc)
	qdel(holder)

/obj/item/mcobject/flusher/proc/trunk_check()
	trunk = locate() in loc
	if(QDELETED(trunk))
		trunk = null
		return FALSE
	else
		trunk.linked = src
		return TRUE
