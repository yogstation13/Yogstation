#define MIN_REPLACEMENT 2
#define MAX_REPLACEMENT 7
#define MAX_RANGE 7

//THE STATION MUST SURVIVE
/obj/effect/anomaly/frost
	name = "glacial anomaly"
	icon_state = "impact_laser_blue"
	/// How many seconds between each gas release
	var/releasedelay = 10

/obj/effect/anomaly/frost/anomalyEffect(seconds_per_tick)
	..()

	if(isspaceturf(src) || !isopenturf(get_turf(src)))
		return

	var/turf/current_location = get_turf(src)
	var/list/valid_turfs = list()
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/closed,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm,
		/turf/open/floor/iron/snowed))

	current_location.atmos_spawn_air ("o2=2;freon=1;water_vapor=8;TEMP=180")

	for(var/searched_turfs in circle_view_turfs(src, MAX_RANGE))
		if(is_type_in_typecache(searched_turfs, blacklisted_turfs))
			continue
		else
			valid_turfs |= searched_turfs
	for(var/i = 1 to min(rand(MIN_REPLACEMENT, MAX_REPLACEMENT), length(valid_turfs)))//Replace 2-7 tiles with snow
		var/turf/searched_turfs = pick(valid_turfs)
		if(searched_turfs)
			if(istype(searched_turfs, /turf/open/floor/plating))
				searched_turfs.PlaceOnTop(/turf/open/floor/iron/snowed)
			else
				searched_turfs.ChangeTurf(/turf/open/floor/iron/snowed)

/obj/effect/anomaly/frost/detonate()
	//The station holds its breath, waiting for whatever the end will bring.
	if(isinspace(src) || !isopenturf(get_turf(src)))
		return
	var/turf/current_location = get_turf(src)
	current_location.atmos_spawn_air("water_vapor=200;freon=100;o2=100;TEMP=140") //The cold will be brutal. The water in hydroponics will freeze. We'll have to make do with the food we've stockpiled.

#undef MIN_REPLACEMENT
#undef MAX_REPLACEMENT
#undef MAX_RANGE
