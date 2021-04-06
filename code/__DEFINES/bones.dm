#define NO_FRACTURE 0
#define HAIRLINE_FRACTURE 1
#define FRACTURE 2
#define COMPOUND_FRACTURE 3
///1 bodypart health = X bone health
#define BODYPART_TO_BONE_RATIO 1
///How much damages does a splint remove per Life()?
#define SPLINT_HEALING_POWER 2
///At what damage does our fractures heal?
#define FRACTURE_HEALING_CUTOFF 10
///How much damage to apply when we move, multiplied by severity
#define MOVING_DAMAGE 0.2
///How much slowdown does a fracture give, multiplied by severity and LEG_BONE_SLOWDOWN_MULTIPLIER if it's a leg?
#define FRACTURE_SLOWDOWN_BASE 0.1
///Fracture slowdown is multiplied by this when it is the legs
#define LEG_BONE_SLOWDOWN_MULTIPLIER 2