/turf/open/misc/asteroid/airless/tospace
	explodable = TRUE
	baseturfs = /turf/baseturf_bottom
	turf_type = /turf/open/misc/asteroid/airless/tospace
/// Breaks down to an asteroid floor that breaks down to space
/turf/closed/mineral/random/asteroid/tospace
	baseturfs = /turf/open/misc/asteroid/airless/tospace

/turf/closed/mineral/random/asteroid/tospace/highchance
	mineralChance = 26

/turf/closed/mineral/random/asteroid/tospace/lowchance
	mineralChance = 6

/turf/closed/mineral/random/asteroid/tospace/mineral_chances()
	return list(
		/obj/item/stack/ore/diamond = 2.5,
		/obj/item/stack/ore/gold = 5,
		/obj/item/stack/ore/iron = 15,
		/obj/item/stack/ore/plasma = 2.5,
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stack/ore/silver = 6,
		/obj/item/stack/ore/titanium = 8,
		/obj/item/stack/ore/uranium = 5,
		/turf/closed/mineral/artifact = 5,
		/turf/closed/mineral/mineral_sample = 5,
	)
/// Mapping Stuff
/turf/closed/mineral/asteroid/tospace
	baseturfs = /turf/open/misc/asteroid/airless/tospace
	name = "rock"
	icon = MAP_SWITCH('icons/turf/smoothrocks.dmi', 'icons/turf/mining.dmi')
	icon_state = "rock"

/turf/closed/mineral/asteroid/tospace/uranium
	mineralType = /obj/item/stack/ore/uranium
	scan_state = "rock_Uranium"

/turf/closed/mineral/asteroid/tospace/diamond
	mineralType = /obj/item/stack/ore/diamond
	scan_state = "rock_Diamond"

/turf/closed/mineral/asteroid/tospace/gold
	mineralType = /obj/item/stack/ore/gold
	scan_state = "rock_Gold"

/turf/closed/mineral/asteroid/tospace/silver
	mineralType = /obj/item/stack/ore/silver
	scan_state = "rock_Silver"

/turf/closed/mineral/asteroid/tospace/titanium
	mineralType = /obj/item/stack/ore/titanium
	scan_state = "rock_Titanium"

/turf/closed/mineral/asteroid/tospace/plasma
	mineralType = /obj/item/stack/ore/plasma
	scan_state = "rock_Plasma"

/turf/closed/mineral/asteroid/tospace/bananium
	mineralType = /obj/item/stack/ore/bananium
	mineralAmt = 3
	scan_state = "rock_Bananium"

/turf/closed/mineral/asteroid/tospace/bscrystal
	mineralType = /obj/item/stack/ore/bluespace_crystal
	mineralAmt = 1
	scan_state = "rock_BScrystal"

/obj/effect/forcefield/asteroid_magnet
	name = "magnetic field"
	desc = "This looks dangerous."
	icon = 'goon/icons/obj/effects.dmi'
	icon_state = "forcefield"

	initial_duration = 0
	opacity = TRUE


/proc/button_element(trg, text, action, class, style)
	return "<a href='byond://?src=\ref[trg];[action]'[class ? "class='[class]'" : ""][style ? "style='[style]'" : ""]>[text]</a>"

/proc/color_button_element(trg, color, action)
	return "<a href='byond://?src=\ref[trg];[action]' class='box' style='background-color: [color]'></a>"

/// Inline script for an animated ellipsis
/proc/ellipsis(number_of_dots = 3, millisecond_delay = 500)
	var/static/unique_id = 0
	unique_id++
	return {"<span id='[unique_id]' style='display: inline-block'></span>
			<script>
			var count = 0;
			document.addEventListener("DOMContentLoaded", function() {
				setInterval(function(){
					count++;
					document.getElementById('[unique_id]').innerHTML = new Array(count % [number_of_dots + 2]).join('.');
				}, [millisecond_delay]);
			});
			</script>
	"}
/// Cleanup our currently loaded mining template
/proc/CleanupAsteroidMagnet(turf/center, size)
	var/list/turfs_to_destroy = ReserveTurfsForAsteroidGeneration(center, size, baseturf_only = FALSE)
	for(var/turf/turf as anything in turfs_to_destroy)
		CHECK_TICK

		for(var/atom/movable/AM as anything in turf)
			CHECK_TICK
			if(isdead(AM) || iscameramob(AM) || iseffect(AM) || iseminence(AM) || ismob(AM))
				continue
			qdel(AM)

		turf.ChangeTurf(/turf/baseturf_bottom)

/// Sanitizes a block of turfs to prevent writing over undesired locations
/proc/ReserveTurfsForAsteroidGeneration(turf/center, size, baseturf_only = TRUE)
	. = list()

	var/list/turfs = RANGE_TURFS(size, center)
	for(var/turf/turf as anything in turfs)
		if(baseturf_only && !islevelbaseturf(turf))
			continue
		if(!(istype(get_area(turf.loc), /area/station/cargo/mining/asteroid_magnet)))
			continue
		. += turf
		CHECK_TICK
