/** liters in a normal breath. note that breaths are taken once every 4 life ticks, which is 8 seconds
 * Addendum for people tweaking this value in the future.
 * Because o2 tank release values/human o2 requirements are very strictly set to the same pressure, small errors can cause breakage
 * This comes from QUANTIZE being used in /datum/gas_mixture.remove(), forming a slight sawtooth pattern of the added/removed gas, centered on the actual pressure
 * Changing BREATH_VOLUME can set us on the lower half of this sawtooth, making humans unable to breath at standard pressure.
 * There's no good way I can come up with to hardcode a fix for this. So if you're going to change this variable
 * graph the functions that describe how it is used/how it interacts with breath code, and pick something on the upper half of the sawtooth
 *
**/
#define BREATH_VOLUME 1.99
/// Amount of air to take a from a tile
#define BREATH_PERCENTAGE (BREATH_VOLUME/CELL_VOLUME)

#define QUANTIZE(variable) (round((variable), (MOLAR_ACCURACY)))

/// Return this from a while_present proc to call its on_loss version, if one exists
/// Useful for doing "we're done" effects without duped code
#define BREATH_LOST 1

//Defines for N2O and Healium euphoria moodlets
#define EUPHORIA_INACTIVE 0
#define EUPHORIA_ACTIVE 1
#define EUPHORIA_LAST_FLAG 2

#define MIASMA_CORPSE_MOLES 0.03
#define MIASMA_GIBS_MOLES 0.008

#define MIN_TOXIC_GAS_DAMAGE 1
#define MAX_TOXIC_GAS_DAMAGE 10

// Pressure limits.
/// This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define HAZARD_HIGH_PRESSURE 550
/// This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_HIGH_PRESSURE 325
/// This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define WARNING_LOW_PRESSURE 50
/// This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)
#define HAZARD_LOW_PRESSURE 20

/// This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5

// Defines the cap on fast your body normalizes to the environment
/// Max negative change in temperature during natural body temperature stabilization
#define BODYTEMP_ENVIRONMENT_COOLING_MAX -30 KELVIN // needs to be relatively high, as otherwise you will make space not deadly
/// Max positive change in temperature during natural body temperature stabilization
#define BODYTEMP_ENVIRONMENT_HEATING_MAX 20 KELVIN // should not be too high, as otherwise atmos meme fires will be extremely deadly

/// Default maximum body temperature mobs can exist in before taking damage
#define NPC_DEFAULT_MAX_TEMP CELCIUS_TO_KELVIN(76.85 CELCIUS)// 350 KELVIN
/// Default minimum body temperature mobs can exist in before taking damage
#define NPC_DEFAULT_MIN_TEMP CELCIUS_TO_KELVIN(-23.15 CELCIUS)// 250 KELVIN

// Helpers for temperature conversion
#define FAHRENHEIT_TO_KELVIN(x) (((x) + 459.67) * 5 / 9)
#define KELVIN_TO_FAHRENHEIT(x) (((x) * 9 / 5) - 459.67)
#define CELCIUS_TO_KELVIN(x) ((x) + 273.15)
#define KELVIN_TO_CELCIUS(x) ((x) - 273.15)
#define CELCIUS_TO_FAHRENHEIT(x) (((x) * 9 / 5) + 32)
#define FAHRENHEIT_TO_CELSIUS(x) (((x) - 32) * 5 / 9)

// These defines do nothing but can be used to make the code more readable by indicating temperature units
#define CELCIUS * 1
#define FAHRENHEIT * 1
#define KELVIN * 1

/// Max change in temperature during natural body temperature stabilization
#define BODYTEMP_HOMEOSTASIS_COOLING_MAX (BODYTEMP_ENVIRONMENT_COOLING_MAX / 10)
/// Max change in temperature during natural body temperature stabilization
#define BODYTEMP_HOMEOSTASIS_HEATING_MAX (BODYTEMP_ENVIRONMENT_HEATING_MAX / 8)

// These defines are DEFAULTS for most mobs
// Mobs can override these to have whatever they want
// That means in a lot of situations (namely mob code) you should not directly use these,
// and instead use the relevant mob vars UNLESS you intentionally are using defaults over reality

/// The natural temperature for a body
#define BODYTEMP_NORMAL CELCIUS_TO_KELVIN(37 CELCIUS)
/// Beyond this point a mob is considered hyperthermic
#define HYPERTHERMIA (BODYTEMP_NORMAL + 10 CELCIUS)
/// Beyond this point a mob is considered hypothermic
#define HYPOTHERMIA (BODYTEMP_NORMAL - 10 CELCIUS)

/// The body temperature limit the human body can take before it starts taking damage from heat.
/// This also affects how fast the body normalises it's temperature when hot.
#define BODYTEMP_HEAT_DAMAGE_LIMIT CELCIUS_TO_KELVIN(45 CELCIUS)
/// The body temperature limit the human body can take before it starts taking damage from cold.
/// This also affects how fast the body normalises it's temperature when cold.
#define BODYTEMP_COLD_DAMAGE_LIMIT CELCIUS_TO_KELVIN(-0.5 CELCIUS)

/// The maximum temperature of Lavaland
#define LAVALAND_MAX_TEMPERATURE CELCIUS_TO_KELVIN(76.85 CELCIUS)// 350 KELVIN
#define ICEBOX_MIN_TEMPERATURE CELCIUS_TO_KELVIN(-93.15 CELCIUS)

/// A temperature limit which is above the maximum lavaland temperature
#define BODYTEMP_HEAT_LAVALAND_SAFE (LAVALAND_MAX_TEMPERATURE + 5 KELVIN)
/// A temperature limit which is above the minimum icebox temperature
#define BODYTEMP_COLD_ICEBOX_SAFE (ICEBOX_MIN_TEMPERATURE - 5 KELVIN)

/// The temperature the red icon is displayed.
#define BODYTEMP_HEAT_WARNING_3 (BODYTEMP_NORMAL + 23 CELCIUS) // CELCIUS_TO_KELVIN(60 CELCIUS)
/// The temperature the orange icon is displayed.
#define BODYTEMP_HEAT_WARNING_2 (BODYTEMP_NORMAL + 13 CELCIUS) // CELCIUS_TO_KELVIN(50 CELCIUS)
/// The temperature the yellow icon is displayed.
#define BODYTEMP_HEAT_WARNING_1 (BODYTEMP_NORMAL + 3 CELCIUS) // CELCIUS_TO_KELVIN(40 CELCIUS)
/// The temperature the light green icon is displayed.
#define BODYTEMP_COLD_WARNING_1 (BODYTEMP_NORMAL - 7 CELCIUS) // CELCIUS_TO_KELVIN(30 CELCIUS)
/// The temperature the cyan icon is displayed.
#define BODYTEMP_COLD_WARNING_2 (BODYTEMP_NORMAL - 17 CELCIUS) // CELCIUS_TO_KELVIN(20 CELCIUS)
/// The temperature the blue icon is displayed.
#define BODYTEMP_COLD_WARNING_3 (BODYTEMP_NORMAL - 27 CELCIUS) // CELCIUS_TO_KELVIN(10 CELCIUS)

// Ok defaults over

/// Beyond this body temperature, being on fire will increase body temperature by less and less
#define BODYTEMP_FIRE_TEMP_SOFTCAP 600 KELVIN

/// Amount of heating applied per fire stack per tick while on fire
#define HEAT_PER_FIRE_STACK 0.075 KELVIN
/// Amount of direct damage applied per fire stack per tick while on fire
#define BURN_DAMAGE_PER_FIRE_STACK 0.1

/// A warm drink will increase body temperature by this much
#define WARM_DRINK 0.25 KELVIN
/// A cold drink will decrease body temperature by this much
#define COLD_DRINK -0.25 KELVIN

/// The modifier on cold damage limit hulks get ontop of their regular limit
#define BODYTEMP_HULK_COLD_DAMAGE_LIMIT_MODIFIER 25 KELVIN
/// The modifier on cold damage hulks get.
#define HULK_COLD_DAMAGE_MOD 2

/// The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define PRESSURE_DAMAGE_COEFFICIENT 2
#define MAX_HIGH_PRESSURE_DAMAGE 2
/// The amount of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).
#define LOW_PRESSURE_DAMAGE 2

/// Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this
#define COLD_SLOWDOWN_FACTOR 20


//CLOTHES

/// what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MIN_TEMP_PROTECT 2.0 KELVIN
/// Thermal insulation works both ways /Malkevin
#define SPACE_HELM_MAX_TEMP_PROTECT 1500 KELVIN
/// what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MIN_TEMP_PROTECT 2.0 KELVIN
/// The min cold protection of a space suit without the heater active
#define SPACE_SUIT_MIN_TEMP_PROTECT_OFF 72 KELVIN
#define SPACE_SUIT_MAX_TEMP_PROTECT 1500 KELVIN

/// Cold protection for firesuits
#define FIRE_SUIT_MIN_TEMP_PROTECT 60 KELVIN
/// what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_SUIT_MAX_TEMP_PROTECT 30000 KELVIN
/// Cold protection for fire helmets
#define FIRE_HELM_MIN_TEMP_PROTECT 60 KELVIN
/// for fire helmet quality items (red and white hardhats)
#define FIRE_HELM_MAX_TEMP_PROTECT 30000 KELVIN

/// what max_heat_protection_temperature is set to for firesuit quality suits and helmets. MUST NOT BE 0.
#define FIRE_IMMUNITY_MAX_TEMP_PROTECT 35000 KELVIN

/// For normal helmets
#define HELMET_MIN_TEMP_PROTECT 160 KELVIN
/// For normal helmets
#define HELMET_MAX_TEMP_PROTECT 600 KELVIN
/// For armor
#define ARMOR_MIN_TEMP_PROTECT 160 KELVIN
/// For armor
#define ARMOR_MAX_TEMP_PROTECT 600 KELVIN

/// For some gloves (black and)
#define GLOVES_MIN_TEMP_PROTECT 2.0 KELVIN
/// For some gloves
#define GLOVES_MAX_TEMP_PROTECT 1500 KELVIN
/// For gloves
#define SHOES_MIN_TEMP_PROTECT 2.0 KELVIN
/// For gloves
#define SHOES_MAX_TEMP_PROTECT 1500 KELVIN
