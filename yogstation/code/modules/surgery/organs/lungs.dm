/obj/item/organ/lungs/cybernetic/military
	name = "military cybernetic lungs"
	desc = "Military-grade cybernetic lungs. Features the ability to filter out low levels of all harmful gases, as well as tolerating more extreme temperature ranges."
	icon_state = "lungs-c-m"

	cold_level_1_threshold = 160
	cold_level_2_threshold = 120
	cold_level_3_threshold = 80

	heat_level_1_threshold = 400
	heat_level_2_threshold = 440
	heat_level_3_threshold = 1000 //Not changed, but looks prettier that way

	SA_para_min = 10 //Stuns aren't fun, right?
	SA_sleep_min = 20 //Wake up, Mr. Freeman
	BZ_trip_balls_min = 20 //Down with hallucinogens!
	safe_toxins_max = 30
	safe_co2_max = 30
	lung_melty_min = 80 //These are military grade lungs. Not some chump lungs that let themselves get melted by some half-baked acid gas.
