/datum/mood_event/nanite_happiness
	description = "<span class='nicegreen robot'>+++++++HAPPINESS ENHANCEMENT+++++++</span>"
	mood_change = 7

/datum/mood_event/nanite_happiness/add_effects(message)
	description = "<span class='nicegreen robot'>+++++++[message]+++++++</span>"

/datum/mood_event/monster_hunter
	description = "Glory to the hunt."
	mood_change = 10
	hidden = TRUE

/datum/mood_event/pride_pin
	description = "I love showing off my pride pin!"
	mood_change = 1

/datum/mood_event/jazzy
	description = "Oooh, jazzy!"
	mood_change = 2
	timeout = 1 MINUTE

/datum/mood_event/delightful_symptom
	description = "Everything feels so nice and wonderful!"
	mood_change = 50
