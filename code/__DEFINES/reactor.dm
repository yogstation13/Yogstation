// Index of each node in the list of nodes the reactor has
#define COOLANT_INPUT_GATE 1
#define MODERATOR_INPUT_GATE 2
#define COOLANT_OUTPUT_GATE 3

#define REACTOR_TEMPERATURE_MINIMUM 400 // Minimum temperature needed to run normally
#define REACTOR_TEMPERATURE_OPERATING 800 //Kelvin
#define REACTOR_TEMPERATURE_CRITICAL 1000 //At this point the entire station is alerted to a meltdown. This may need altering
#define REACTOR_TEMPERATURE_MELTDOWN 1200

#define REACTOR_HEAT_CAPACITY 6000 //How much thermal energy it takes to cool the reactor
#define REACTOR_ROD_HEAT_CAPACITY 400 //How much thermal energy it takes to cool each reactor rod
#define REACTOR_HEAT_EXPONENT 1.5 // The exponent used for the function for K heating
#define REACTOR_HEAT_FACTOR (20 / (REACTOR_HEAT_EXPONENT**2)) //How much heat from K

#define REACTOR_MODERATOR_DECAY_RATE 0.1 //Don't use up ALL of the moderator, engineers need it to last a full round

#define REACTOR_PRESSURE_OPERATING 6000 //Kilopascals
#define REACTOR_PRESSURE_CRITICAL 10000

#define REACTOR_MAX_CRITICALITY 5 //No more criticality than N for now.
#define REACTOR_MAX_FUEL_RODS 5 //Maximum number of fuel rods that can fit in the reactor

#define REACTOR_POWER_FLAVOURISER 1000 //To turn those KWs into something usable
#define REACTOR_PERMEABILITY_FACTOR 500 // How effective permeability-type moderators are
#define REACTOR_CONTROL_FACTOR 250 // How effective control-type moderators are


/// Moderator effects, must be added to the moderator input for them to do anything

// Fuel types: increases power, at the cost of making K harder to control
#define PLASMA_FUEL_POWER 1 // baseline fuel
#define TRITIUM_FUEL_POWER 10 // woah there
#define ANTINOBLIUM_FUEL_POWER 100 // oh god oh fuck

// Power types: makes the fuel have more of an effect
#define OXYGEN_POWER_MOD 1 // baseline power modifier gas, optimal plasma/O2 ratio is 50/50 if you can handle the K increase from the plasma
#define HYDROGEN_POWER_MOD 10 // far superior power moderator gas, if you can handle the rads

// Control types: increases the effectiveness of control rods, makes K easier to control
#define NITROGEN_CONTROL_MOD 1 // good at controlling the reaction, but deadly rads
#define CARBON_CONTROL_MOD 2 // even better control, but even worse rads
#define PLUOXIUM_CONTROL_MOD 3 // best control gas, no rads!

// Cooling types: increases the effectiveness of coolant, exchanges more heat per process
#define BZ_PERMEABILITY_MOD 1 // makes cooling more effective
#define WATER_PERMEABILITY_MOD 2 // even better than BZ
#define NOBLIUM_PERMEABILITY_MOD 10 // best gas for cooling

// Radiation types: increases radiation, lower is better
#define NITROGEN_RAD_MOD 0.04 // mmm radiation
#define CARBON_RAD_MOD 0.08 // even higher
#define HYDROGEN_RAD_MOD 0.12 // getting a bit spicy there
#define TRITIUM_RAD_MOD 0.2 // fuck that's a lot
#define ANTINOBLIUM_RAD_MOD 10 // AAAAAAAAAAAAAAAAAAAA
