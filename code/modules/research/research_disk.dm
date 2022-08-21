
/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk0"
	materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/datum/techweb/stored_research

/obj/item/disk/tech_disk/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	stored_research = new /datum/techweb

/obj/item/disk/tech_disk/debug
	name = "\improper CentCom technology disk"
	desc = "A debug item for research"
	materials = list()

/obj/item/disk/tech_disk/debug/Initialize()
	. = ..()
	stored_research = new /datum/techweb/admin

/obj/item/research_notes
	name = "research notes"
	desc = "Valuable scientific data. Use it in a research console to scan it."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	w_class = WEIGHT_CLASS_SMALL
	/// What research points it holds
	var/list/points = 0
	/// What type of research points it holds, only used for mapping
	var/list/point_type = TECHWEB_POINT_TYPE_GENERIC
	///origin of the research
	var/origin_type = "shit code"
	///if it ws merged with different origins to apply a bonus
	var/mixed = FALSE

/obj/item/research_notes/Initialize(mapload, _points, _point_type, _origin_type)
	. = ..()
	if(_points)
		points = _points
	if(_point_type)
		point_type = _point_type
	if(points && !islist(points))
		points = list("[point_type]" = points)
	if(_origin_type)
		origin_type = _origin_type
	change_vol()

/obj/item/research_notes/examine(mob/user)
	. = ..()
	. += span_notice("It is worth [get_value()] research points.")

/// proc that changes name and icon depending on value
/obj/item/research_notes/proc/change_vol()
	var/value = get_value()
	if(value >= 10000)
		name = "revolutionary discovery in the field of [origin_type]"
		icon_state = "docs_verified"
		return
	else if(value >= 2500)
		name = "essay about [origin_type]"
		icon_state = "paper_words"
		return
	else if(value >= 100)
		name = "notes of [origin_type]"
		icon_state = "paperslip_words"
		return
	else
		name = "fragmentary data of [origin_type]"
		icon_state = "scrap"
		return

/// proc that returns the total amount of points
/obj/item/research_notes/proc/get_value()
	var/value
	for(var/point_type in points)
		value += points[point_type]
	return value

/// proc when you slap research notes into another one
/obj/item/research_notes/proc/merge(obj/item/research_notes/new_paper)
	for(var/point_type in TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES) // Closest thing I can find to a list of all point types
		var/new_value = points[point_type] + new_paper.points[point_type]
		if(new_value)
			points[point_type] = new_value
	if(origin_type != new_paper.origin_type)
		origin_type = "[origin_type] and [new_paper.origin_type]"
	change_vol()
	qdel(new_paper)

/obj/item/research_notes/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/research_notes))
		var/obj/item/research_notes/R = I
		merge(R)
		return TRUE
