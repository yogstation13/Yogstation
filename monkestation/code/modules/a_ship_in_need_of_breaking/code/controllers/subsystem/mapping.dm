/datum/controller/subsystem/mapping
	var/list/shipbreaker_templates = list()

/datum/controller/subsystem/mapping/Recover()
	. = ..()
	shipbreaker_templates = SSmapping.shipbreaker_templates

/datum/controller/subsystem/mapping/preloadTemplates()
	. = ..()
	preloadShipbreakerTemplates()

/datum/controller/subsystem/mapping/proc/preloadShipbreakerTemplates()
	for(var/item in subtypesof(/datum/map_template/shipbreaker))
		var/datum/map_template/shipbreaker/shipbroken_type = item
		if(!(initial(shipbroken_type.mappath)))
			continue
		var/datum/map_template/shipbreaker/S = new shipbroken_type()

		shipbreaker_templates[S.template_id] = S
