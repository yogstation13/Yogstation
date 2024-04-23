
//other construction-related things

//windows affected by Nar'sie turn this color.
#define NARSIE_WINDOW_COLOUR "#7D1919"

//let's just pretend fulltile windows being children of border windows is fine
#define FULLTILE_WINDOW_DIR NORTHEAST

//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MINERAL_MATERIAL_AMOUNT 2000

// Crafting defines.
// When adding new defines, please make sure to also add them to the encompassing list.
#define CAT_WEAPON_RANGED "Weapons: Ranged"
#define CAT_WEAPON_MELEE "Weapons: Melee"
#define CAT_WEAPON_AMMO "Weapon Ammo"
#define CAT_TOOLS "Tools"
#define CAT_ROBOT "Robotics"
#define CAT_CLOTHING "Clothing"
#define CAT_ARMOR "Armor"
#define CAT_EQUIPMENT "Equipment"
#define CAT_STRUCTURES "Structures"
#define CAT_PRIMAL "Tribal"
#define CAT_BAIT "Fishing Bait"
#define CAT_MEDICAL "Medical"
#define CAT_MISC "Misc"

GLOBAL_LIST_INIT(crafting_category, list(
	CAT_WEAPON_RANGED,
	CAT_WEAPON_MELEE,
	CAT_WEAPON_AMMO,
	CAT_TOOLS,
	CAT_ROBOT,
	CAT_CLOTHING,
	CAT_ARMOR,
	CAT_STRUCTURES,
	CAT_EQUIPMENT,
	CAT_PRIMAL,
	CAT_BAIT,
	CAT_MEDICAL,
	CAT_MISC
))

// Food/Drink crafting defines.
// When adding new defines, please make sure to also add them to the encompassing list.
#define CAT_FOOD	"Foods"
#define CAT_BREAD	"Breads"
#define CAT_BURGER	"Burgers"
#define CAT_CAKE	"Cakes"
#define CAT_EGG	"Egg-Based Food"
#define CAT_MEAT	"Meats"
#define CAT_MISCFOOD	"Misc. Food"
#define CAT_PASTRY	"Pastries"
#define CAT_PIE	"Pies"
#define CAT_PIZZA	"Pizzas"
#define CAT_SALAD	"Salads"
#define CAT_SANDWICH	"Sandwiches"
#define CAT_SOUP	"Soups"
#define CAT_SPAGHETTI	"Spaghettis"
#define CAT_ICE	"Frozen"
#define CAT_DRINK   "Drinks"
#define CAT_SEAFOOD   "Seafood"

GLOBAL_LIST_INIT(crafting_category_food, list(
	CAT_FOOD,
	CAT_BREAD,
	CAT_BURGER,
	CAT_CAKE,
	CAT_EGG,
	CAT_MEAT,
	CAT_SEAFOOD,
	CAT_MISCFOOD,
	CAT_PASTRY,
	CAT_PIE,
	CAT_PIZZA,
	CAT_SALAD,
	CAT_SANDWICH,
	CAT_SOUP,
	CAT_SPAGHETTI,
	CAT_ICE,
	CAT_DRINK,
))



#define RCD_WINDOW_FULLTILE "full tile"
#define RCD_WINDOW_DIRECTIONAL "directional"
#define RCD_WINDOW_NORMAL "glass"
#define RCD_WINDOW_REINFORCED "reinforced glass"
