
/// Medicine and surgery.
#define SKILL_PHYSIOLOGY "physiology"
/// Construction and repair of structures and machinery.
#define SKILL_MECHANICAL "mechanics"
/// Hacking, piloting, and robotic maintenance.
#define SKILL_TECHNICAL "technical"
/// Chemistry, botany, physics, and other sciences.
#define SKILL_SCIENCE "science"
/// Strength, endurance, accuracy.
#define SKILL_FITNESS "fitness"

/// No experience whatsoever.
#define EXP_NONE 0
/// Some experience, but not much.
#define EXP_LOW 1
/// Enough experience to do a decent job.
#define EXP_MID 2
/// Above average skill level.
#define EXP_HIGH 3
/// Exceptionally skilled.
#define EXP_MASTER 4
/// Uniquely gifted. Not obtainable through normal means.
#define EXP_GENIUS 5

/// Experience required to increase your skills by one level. Increases exponentially the higher your level already is.
#define EXPERIENCE_PER_LEVEL 500

/// Calculates how much experience is required to reach a given level.
#define EXP_REQ_CALC(level) (EXPERIENCE_PER_LEVEL * (((2**(level + 1)) / 2) - 1))
