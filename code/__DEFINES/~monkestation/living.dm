///from base of living/set_pull_offset(): (mob/living/pull_target, grab_state)
#define COMSIG_LIVING_SET_PULL_OFFSET "living_set_pull_offset"
///from base of living/reset_pull_offsets(): (mob/living/pull_target, override)
#define COMSIG_LIVING_RESET_PULL_OFFSETS "living_reset_pull_offsets"
///from base of living/CanAllowThrough(): (atom/movable/mover, border_dir)
#define COMSIG_LIVING_CAN_ALLOW_THROUGH "living_can_allow_through"
	/// Allow to movable atoms to pass through this living mob
	#define COMPONENT_LIVING_PASSABLE (1<<0)

/// Checks if the value is "left"
/// Used primarily for hand or foot indexes
#define IS_RIGHT(value) (value % 2 == 0)
/// Checks if the value is "right"
/// Used primarily for hand or foot indexes
#define IS_LEFT(value) (value % 2 != 0)
/// Helper for picking between left or right when given a value
/// Used primarily for hand or foot indexes
#define SELECT_LEFT_OR_RIGHT(value, left, right) (IS_LEFT(value) ? left : right)


/// Calculates oxyloss cap
#define MAX_OXYLOSS(maxHealth) (maxHealth * 2)

// Some source defines for pain and consciousness
// Consciousness ones are human readable because of laziness (they are shown in cause of death)
#define PAINSHOCK "neurological shock"
#define PAINCRIT "paincrit"
#define PAIN "pain"
#define HUNGER "starvation"
#define BRAIN_DAMAGE "brain damage"
#define BLOOD_LOSS "blood loss"
#define BLUNT_DAMAGE "blunt force trauma"
#define BURN_DAMAGE "severe burns"
#define OXY_DAMAGE "suffocation"
#define TOX_DAMAGE "toxic poisoning"

#define SKIP_INTERNALS "skip_internals"
