//range artifacts require stimuli to fall within a range between amount and upper range
// hint range and hint chance are added onto range to see if something we should pull a hint for the user

/datum/artifact_activator/range
	name = "Generic Range Trigger"

	var/upper_range = 0
	///Hint range goes like amount - hint_range to upper_range + hint_range
	var/hint_range = 0
	///if we are in the hint range the odds of pulling a hint out.
	var/hint_prob = 15

/datum/artifact_activator/range/setup(potency)
	. = ..()

/datum/artifact_activator/range/force
	name = "Physical Trauma"
	required_stimuli = STIMULUS_FORCE
	highest_trigger_amount = 10 //*meaty thwack* *both chuckle*
	hint_prob = 50
	hint_range = 5
	hint_texts = list("You almost want to start hitting things.", "A good whack might fix this.")
	discovered_text = "Activated by Kinetic Energy"

/datum/artifact_activator/range/force/New()
	base_trigger_amount = rand(2,highest_trigger_amount)

/datum/artifact_activator/range/heat
	name = "Heat Sensisty"
	required_stimuli = STIMULUS_HEAT
	hint_range = 20
	highest_trigger_amount = 750
	hint_texts = list("It feels like someone messed with the thermostat.", "It feels unpleasent being near")
	discovered_text = "Activated by Thermal Energy"

/datum/artifact_activator/range/heat/New()
	base_trigger_amount = rand(350, highest_trigger_amount)

/datum/artifact_activator/range/shock
	name = "Electrical Charged"
	required_stimuli = STIMULUS_SHOCK
	highest_trigger_amount = 1200
	hint_range = 500
	hint_texts = list("You can feel the static in the air", "Your hairs stand on their ends")
	discovered_text = "Activated by Electrical Energy"

/datum/artifact_activator/range/shock/New()
	base_trigger_amount = rand(400, highest_trigger_amount)

/datum/artifact_activator/range/radiation
	name = "Radioactivity"
	required_stimuli = STIMULUS_RADIATION
	highest_trigger_amount = 5
	hint_range = 2
	base_trigger_amount = 1 //x-ray machine goes from 1-10
	hint_texts = list("Emits a hum that resembles the Super Matter", "You could swear you saw your bones for a second")
	discovered_text = "Activated by Radiation"
