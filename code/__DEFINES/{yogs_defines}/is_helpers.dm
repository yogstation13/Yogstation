#define isdarkspawn(A) (A?.mind?.has_antag_datum(/datum/antagonist/darkspawn))
#define isthrall(A) (A?.mind?.has_antag_datum(/datum/antagonist/thrall))
#define ispsyche(A) (A?.mind?.has_antag_datum(/datum/antagonist/psyche)) //non thrall teammates
#define is_darkspawn_or_thrall(A) (A.mind && isdarkspawn(A) || isthrall(A))
#define is_team_darkspawn(A) ((A.mind && isdarkspawn(A) || isthrall(A)) || ispsyche(A) || (ROLE_DARKSPAWN in A.faction)) //also checks factions, so things can be immune to darkspawn spells without needing an antag datum

#define is_clockcult(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/clockcult))

#define is_sinfuldemon(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/sinfuldemon))

#define is_mindslaved(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/mindslave))
#define is_traitor(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/traitor) || is_mindslaved(M))
#define is_blood_brother(M) (istype(M, /mob/living) && M.mind && M.mind.has_antag_datum(/datum/antagonist/brother))
#define is_nukeop(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/nukeop)) // also detects clownOP
#define is_infiltrator(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/infiltrator))
#define is_syndicate(M) (istype(M, /mob/living) && is_traitor(M) || is_blood_brother(M) || is_nukeop(M) || is_infiltrator(M))
#define is_battleroyale(M) (M.mind && M.mind.has_antag_datum(/datum/antagonist/battleroyale))

#define isspacepod(A) (istype(A, /obj/spacepod))

#define ismineralturf_inclusive(A) (istype(A, /turf/closed/mineral) || istype(A,/turf/open/floor/plating/dirt/jungleland))
