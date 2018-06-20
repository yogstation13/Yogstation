#define is_thrall(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/thrall))
#define is_shadow(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/shadowling))
#define is_shadow_or_thrall(M) (is_thrall(M) || is_shadow(M))
#define is_shadowwalkable(T) (isturf(T) && T.get_lumcount()==null || T.get_rgb_lumcount(r_mul = LIGHT_RED_MULTIPLIER, g_mul = LIGHT_GREEN_MULTIPLIER, b_mul = LIGHT_BLUE_MULTIPLIER) <= MAX_SW_LUMS)