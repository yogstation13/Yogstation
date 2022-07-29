#define is_thrall(M) (istype(M, /mob/living) && M.mind?.has_antag_datum(/datum/antagonist/thrall))
#define is_shadow(M) (istype(M, /mob/living) && M.mind?.has_antag_datum(/datum/antagonist/shadowling))
#define is_shadow_or_thrall(M) (is_thrall(M) || is_shadow(M))

#define isdarkspawn(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define isveil(A) (A?.mind?.has_antag_datum(/datum/antagonist/veil))
#define is_darkspawn_or_veil(A) (A.mind && isdarkspawn(A) || isveil(A))

#define is_clockcult(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/clockcult))

#define is_sinfuldemon(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/sinfuldemon))

#define is_mindslaved(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/mindslave))
#define is_traitor(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/traitor) || is_mindslaved(M))
#define is_blood_brother(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/brother))
#define is_nukeop(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/nukeop)) // also detects clownOP
#define is_infiltrator(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/infiltrator))
#define is_syndicate(M) (istype(M, /mob/living) && is_traitor(M) || is_blood_brother(M) || is_nukeop(M) || is_infiltrator(M))

#define isspacepod(A) (istype(A, /obj/spacepod))
