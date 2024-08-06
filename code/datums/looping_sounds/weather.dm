/datum/looping_sound/active_outside_ashstorm
	mid_sounds = list(
		'sound/weather/ashstorm/outside/active_mid1.ogg'=1,
		'sound/weather/ashstorm/outside/active_mid1.ogg'=1,
		'sound/weather/ashstorm/outside/active_mid1.ogg'=1
		)
	mid_length = 80
	start_sound = 'sound/weather/ashstorm/outside/active_start.ogg'
	start_length = 130
	end_sound = 'sound/weather/ashstorm/outside/active_end.ogg'
	volume = 60

/datum/looping_sound/active_inside_ashstorm
	mid_sounds = list(
		'sound/weather/ashstorm/inside/active_mid1.ogg'=1,
		'sound/weather/ashstorm/inside/active_mid2.ogg'=1,
		'sound/weather/ashstorm/inside/active_mid3.ogg'=1
		)
	mid_length = 80
	start_sound = 'sound/weather/ashstorm/inside/active_start.ogg'
	start_length = 130
	end_sound = 'sound/weather/ashstorm/inside/active_end.ogg'
	volume = 40

/datum/looping_sound/weak_outside_ashstorm
	mid_sounds = list(
		'sound/weather/ashstorm/outside/weak_mid1.ogg'=1,
		'sound/weather/ashstorm/outside/weak_mid2.ogg'=1,
		'sound/weather/ashstorm/outside/weak_mid3.ogg'=1
		)
	mid_length = 80
	start_sound = 'sound/weather/ashstorm/outside/weak_start.ogg'
	start_length = 130
	end_sound = 'sound/weather/ashstorm/outside/weak_end.ogg'
	volume = 40

/datum/looping_sound/weak_inside_ashstorm
	mid_sounds = list(
		'sound/weather/ashstorm/inside/weak_mid1.ogg'=1,
		'sound/weather/ashstorm/inside/weak_mid2.ogg'=1,
		'sound/weather/ashstorm/inside/weak_mid3.ogg'=1
		)
	mid_length = 80
	start_sound = 'sound/weather/ashstorm/inside/weak_start.ogg'
	start_length = 130
	end_sound = 'sound/weather/ashstorm/inside/weak_end.ogg'
	volume = 20


/datum/looping_sound/outside_acid_rain
	start_sound = 'sound/weather/acidrain/outside/acidrain_outside_start.ogg'
	start_length = 12 SECONDS

	mid_sounds = list(
		'sound/weather/acidrain/outside/acidrain_outside_mid1.ogg'=1,
		'sound/weather/acidrain/outside/acidrain_outside_mid2.ogg'=1,
		'sound/weather/acidrain/outside/acidrain_outside_mid3.ogg'=1,
		'sound/weather/acidrain/outside/acidrain_outside_mid4.ogg'=1
		)
	mid_length = 12 SECONDS

	end_sound = 'sound/weather/acidrain/outside/acidrain_outside_end.ogg'
	volume = 55

/datum/looping_sound/inside_acid_rain
	start_sound = 'sound/weather/acidrain/inside/acidrain_inside_start.ogg'
	start_length = 12 SECONDS

	mid_sounds = list(
		'sound/weather/acidrain/inside/acidrain_inside_mid1.ogg'=1,
		'sound/weather/acidrain/inside/acidrain_inside_mid2.ogg'=1,
		'sound/weather/acidrain/inside/acidrain_inside_mid3.ogg'=1,
		'sound/weather/acidrain/inside/acidrain_inside_mid4.ogg'=1
		)
	mid_length = 12 SECONDS

	end_sound = 'sound/weather/acidrain/inside/acidrain_inside_end.ogg'

	volume = 35 //the audio files are already just a bit quieter than the outside ones, but it should still be notably quieter
