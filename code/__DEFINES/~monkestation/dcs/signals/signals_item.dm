/// Sent when an item is stashed in Gary's hideout.
#define COMSIG_ITEM_GARY_STASHED "gary_stashed"

/// Sent when an item is taken/looted from Gary's hideout.
#define COMSIG_ITEM_GARY_LOOTED "gary_looted"

/// Called before an item is compressed by a bluespace compression kit: (mob/user, obj/item/compression_kit/kit)
#define COMSIG_ITEM_PRE_COMPRESS		"item_pre_compress"
	#define COMPONENT_STOP_COMPRESSION	(1 << 0)
	#define COMPONENT_HANDLED_MESSAGE	(1 << 1)
/// Called after an item is compressed by a bluespace compression kit: (mob/user, obj/item/compression_kit/kit)
#define COMSIG_ITEM_COMPRESSED			"item_compressed"

/// Called when a clock cultist uses a clockwork slab: (obj/item/clockwork/clockwork_slab/slab)
#define COMSIG_CLOCKWORK_SLAB_USED "clockwork_slab_used"

/// the comsig for clockwork items checking turf
#define COMSIG_CHECK_TURF_CLOCKWORK "check_turf_clockwork"

#define COMSIG_ITEM_DAMAGE_MULTIPLIER "damage_multi_item"

///Sent by a tumor when its removed
#define COMSIG_ZOMBIE_TUMOR_REMOVED "zombie_tumor_removed"
