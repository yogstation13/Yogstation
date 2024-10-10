
#define sequential_id(key) GLOB.uniqueness_repository.Generate(/datum/uniqueness_generator/id_sequential, key)
#define random_id(key,min_id,max_id) GLOB.uniqueness_repository.Generate(/datum/uniqueness_generator/id_random, key, min_id, max_id)

//#define CHEWIN_DEBUG 1

//Step classifications, for easy reference later.
//If something falls outside these classifications, why would it?
#define CHEWIN_START 					1		//Default step to construct the list.
#define CHEWIN_ADD_ITEM 				2		//Adding an item to a recipe (Ex- adding a slice of bread)
#define CHEWIN_ADD_REAGENT 				3		//Adding a reagent to a recipe (Ex- Adding salt)
#define CHEWIN_USE_ITEM 				4 		//Using an item in a recipe (Ex- cutting bread with a knife)
#define CHEWIN_USE_TOOL					5
#define CHEWIN_ADD_PRODUCE				6		//Adding Produce to a recipe
#define CHEWIN_USE_STOVE	 			7 		//Using a stove in a recipe
#define CHEWIN_USE_GRILL	 			8 		//Using a stove in a recipe
#define CHEWIN_USE_OVEN	 				9 		//Using a stove in a recipe
#define CHEWIN_USE_FRYER				10
#define CHEWIN_ADD_REAGENT_CHOICE		11
#define CHEWIN_ADD_PRODUCE_CHOICE		12
#define CHEWIN_USE_OTHER 				13 	//Custom Command flag, will take in argument lists.

//Optional flags
#define CHEWIN_ADD_ITEM_OPTIONAL		200
#define CHEWIN_ADD_REAGENT_OPTIONAL		300
#define CHEWIN_USE_ITEM_OPTIONAL		400
#define CHEWIN_USE_TOOL_OPTIONAL		500
#define CHEWIN_ADD_PRODUCE_OPTIONAL		600
#define CHEWIN_USE_STOVE_OPTIONAL		700
#define CHEWIN_USE_GRILL_OPTIONAL		800
#define CHEWIN_USE_OVEN_OPTIONAL		900
#define CHEWIN_ADD_REAGENT_CHOICE_OPTIONAL		1000
#define CHEWIN_ADD_PRODUCE_CHOICE_OPTIONAL		1100
#define CHEWIN_OTHER_OPTIONAL 			1200


#define CHEWIN_BEGIN_EXCLUSIVE_OPTIONS 10000	//Beginning an exclusive option list
#define CHEWIN_END_EXCLUSIVE_OPTIONS 	20000	//Ending an exclusive option list
#define CHEWIN_BEGIN_OPTION_CHAIN 		30000	//Beginning an option chain
#define CHEWIN_END_OPTION_CHAIN 		40000	//Ending an option chain

//Recipe state flags
#define CHEWIN_IS_LAST_STEP 			1		//If the step in the recipe is marked as the last step
#define CHEWIN_IS_OPTIONAL 			2		//If the step in the recipe is marked as 'Optional'
#define CHEWIN_IS_OPTION_CHAIN 		4		//If the step in the recipe is marked to be part of an option chain.
#define CHEWIN_IS_EXCLUSIVE 			8		//If the step in the recipe is marked to exclude other options when followed.
#define CHEWIN_BASE_QUALITY_ENABLED 	16
#define CHEWIN_MAX_QUALITY_ENABLED 	32

//Check item use flags
#define CHEWIN_NO_STEPS  	  	1 //The used object has no valid recipe uses
#define CHEWIN_CHOICE_CANCEL 	2 //The user opted to cancel when given a choice
#define CHEWIN_SUCCESS 		3 //The user decided to use the item and the step was followed
#define CHEWIN_PARTIAL_SUCCESS	4 //The user decided to use the item but the qualifications for the step was not fulfilled
#define CHEWIN_COMPLETE		5 //The meal has been completed!
#define CHEWIN_LOCKOUT			6 //Someone tried starting the function while a prompt was running. Jerk.
#define CHEWIN_BURNT			7 //The meal was ruined by burning the food somehow.

#define CHEWIN_CHECK_INVALID	0
#define CHEWIN_CHECK_VALID		1
#define CHEWIN_CHECK_FULL		2 //For reagents, nothing can be added to

//Cooking container types
#define PLATE 			"plate"
#define CUTTING_BOARD	"cutting board"
#define PAN				"pan"
#define POT				"cooking pot"
#define BOWL			"mixing bowl"
#define DF_BASKET		"deep fryer basket"
#define AF_BASKET		"air fryer basket"
#define OVEN			"oven"
#define GRILL			"grill grate"

//Stove temp settings.
#define J_LO "Low"
#define J_MED "Medium"
#define J_HI "High"

//Burn times for cooking things on a stove.
//Anything put on a stove for this long becomes a burned mess.
#define CHEWIN_BURN_TIME_LOW		15 MINUTES
#define CHEWIN_BURN_TIME_MEDIUM	10 MINUTES
#define CHEWIN_BURN_TIME_HIGH		5 MINUTES

//Ignite times for reagents interacting with a stove.
//The stove will catch fire if left on too long with flammable reagents in any of its holders.
#define CHEWIN_IGNITE_TIME_LOW		1 HOUR
#define CHEWIN_IGNITE_TIME_MEDIUM	30 MINUTES
#define CHEWIN_IGNITE_TIME_HIGH	15 MINUTES

//Determines how much quality is taken from a food each tick when a 'no recipe' response is made.
#define CHEWIN_BASE_QUAL_REDUCTION 5

//A dictionary of unique step ids that point to other step IDs that should be EXCLUDED if it is present in a recipe_pointer's list of possible steps.
GLOBAL_LIST_EMPTY(chewin_optional_step_exclusion_dictionary)

//A dictionary of all recipes by the basic ingredient
//Format: {base_ingedient_type:{unique_id:recipe}}
GLOBAL_LIST_EMPTY(chewin_recipe_dictionary)

//A dictionary of all recipes full_stop. Used later for assembling the HTML list.
//Format: {recipe_type:{unique_id:recipe}}
GLOBAL_LIST_EMPTY(chewin_recipe_list)

//A dictionary of all steps held within all recipes
//Format: {unique_id:step}
GLOBAL_LIST_EMPTY(chewin_step_dictionary)

//An organized heap of recipes by class and grouping.
//Format: {class_of_step:{step_group_identifier:{unique_id:step}}}
GLOBAL_LIST_EMPTY(chewin_step_dictionary_ordered)

#define COMSIG_STOVE_PROCESS "comsig_stove_process"

#define CAT_BULK "Bulk Recipes"
#define CAT_STOVETOP "Stovetop Recipes"
#define CAT_OVEN "Oven Recipes"
