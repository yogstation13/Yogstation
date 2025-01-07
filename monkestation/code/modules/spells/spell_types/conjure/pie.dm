/datum/action/cooldown/spell/conjure/pie
	name = "Summon Pie"
	desc = "This spell conjures many a pie, sliced and otherwise."
	sound = 'sound/magic/summonitems_generic.ogg'
	button_icon_state = "pie"

	school = SCHOOL_CONJURATION
	cooldown_time = 1 MINUTES
	spell_requirements = null

	invocation = "L'T TH'M E'T CAY K" //let them eat cake
	invocation_type = INVOCATION_SHOUT
	garbled_invocation_prob = 0 //i'd rather it remain like this

	summon_radius = 2
	summon_amount = 5
	summon_type = list(
		/obj/item/food/pie/asdfpie,
		/obj/item/food/pie/shepherds_pie,
		/obj/item/food/pie/frenchsilkpie,
		/obj/item/food/pie/baklava,
		/obj/item/food/pie/frostypie,
		/obj/item/food/pie/dulcedebatata,
		/obj/item/food/pie/blumpkinpie,
		/obj/item/food/pie/cocolavatart,
		/obj/item/food/pie/berrytart,
		/obj/item/food/pie/mimetart,
		/obj/item/food/pie/grapetart,
		/obj/item/food/pie/appletart,
		/obj/item/food/pie/pumpkinpie,
		/obj/item/food/pie/cherrypie,
		/obj/item/food/pie/applepie,
		/obj/item/food/pie/xemeatpie,
		/obj/item/food/pie/plump_pie,
		/obj/item/food/pie/amanita_pie,
		/obj/item/food/pie/tofupie,
		/obj/item/food/pie/meatpie,
		/obj/item/food/pie/bearypie,
		/obj/item/food/pie/berryclafoutis,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/plain,
	)
