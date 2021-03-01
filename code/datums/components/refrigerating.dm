/datum/component/refrigerating
    var/list/datum/component/spoiling/linked = list()

/datum/component/refrigerating/Initialize(...)
	. = ..()
	for(var/atom/things in src)
		var/datum/component/spoiling/thing = atom.GetComponent(/datum/component/spoiling)
		if(thing)
			thing.cold = TRUE
