// simple is_type and similar inline helpers

#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

/// Within given range, but not counting z-levels
#define IN_GIVEN_RANGE(source, other, given_range) (get_dist(source, other) <= given_range && (get_step(source, 0)?:z) == (get_step(other, 0)?:z))

#define isatom(A) (isloc(A))

#define isweakref(D) (istype(D, /datum/weakref))

#define isdatum(thing) (istype(thing, /datum))

#define isappearance(A) (!isnum(A) && copytext("\ref[A]", 4, 6) == "3a")

#define isnan(x) ( isnum((x)) && ((x) != (x)) )

//#define isinternalorgan(A) (istype(A, /obj/item/organ/internal)) uncomment if we port tg organ code

//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

GLOBAL_LIST_INIT(turfs_without_ground, typecacheof(list(
	/turf/open/space,
	/turf/open/chasm,
	/turf/open/lava,
	/turf/open/water,
	/turf/open/openspace,
	/turf/open/space/openspace
	)))

#define isgroundlessturf(A) (is_type_in_typecache(A, GLOB.turfs_without_ground))

#define isopenturf(A) (istype(A, /turf/open))

#define isindestructiblefloor(A) (istype(A, /turf/open/indestructible))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define isindestructiblewall(A) (istype(A, /turf/closed/indestructible))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define islava(A) (istype(A, /turf/open/lava))

#define ischasm(A) (istype(A, /turf/open/chasm))

#define isplatingturf(A) (istype(A, /turf/open/floor/plating))

#define isaicore(A) (istype(A, /obj/machinery/ai/data_core))

#define isvalidAIloc(A) ((isturf(A) || isaicore(A)))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define ispolysmorph(A) (is_species(A, /datum/species/polysmorph))
#define ispodperson(A) (is_species(A, /datum/species/pod))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define isjellyperson(A) (is_species(A, /datum/species/jelly))
#define isslimeperson(A) (is_species(A, /datum/species/jelly/slime))
#define isluminescent(A) (is_species(A, /datum/species/jelly/luminescent))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define isinfectedzombie(A) (is_species(A, /datum/species/zombie/infectious/gamemode))
#define isspitter(A) (is_species(A, /datum/species/zombie/infectious/gamemode/spitter))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ismoth(A) (is_species(A, /datum/species/moth))
#define ishumanbasic(A) (is_species(A, /datum/species/human))
#define iscatperson(A) (is_species(A, /datum/species/human/felinid))
#define isethereal(A) (is_species(A, /datum/species/ethereal))
#define isvampire(A) (is_species(A,/datum/species/vampire))
#define ispreternis(A) (is_species(A,/datum/species/preternis))
#define isszlachta(A) (is_species(A, /datum/species/szlachta))
#define isipc(A) (is_species(A, /datum/species/ipc))
#define isinsurgent(A) (is_species(A, /datum/species/ipc/self/insurgent))
#define issnail(A) (is_species(A, /datum/species/snail))
#define isandroid(A) (is_species(A, /datum/species/android))
#define isshadowperson(A) (is_species(A, /datum/species/shadow))
#define is_synth(A) (is_species(A,/datum/species/wy_synth))
#define isdummy(A) (istype(A, /mob/living/carbon/human/dummy))

//more carbon mobs
#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid) || istype(A, /mob/living/simple_animal/hostile/alien))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienroyal(A) (istype(A, /mob/living/carbon/alien/humanoid/royal))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/royal/queen))

#define isdevil(A) (istype(A, /mob/living/carbon/true_devil))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

#define issiliconoradminghost(A) (istype(A, /mob/living/silicon) || IsAdminGhost(A))

#define iscyborg(A) (istype(A, /mob/living/silicon/robot))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define isAIShell(A) (istype(A, /mob/living/silicon/robot/shell))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isrevenant(A) (istype(A, /mob/living/simple_animal/revenant))

#define ishorror(A) (istype(A, /mob/living/simple_animal/horror))

#define isbot(A) (istype(A, /mob/living/simple_animal/bot))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define iscow(A) (istype(A, /mob/living/simple_animal/cow))

#define isslime(A) (istype(A, /mob/living/simple_animal/slime))

#define isdrone(A) (istype(A, /mob/living/simple_animal/drone))

#define iscat(A) (istype(A, /mob/living/simple_animal/pet/cat))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/pet/dog/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isswarmer(A) (istype(A, /mob/living/simple_animal/hostile/swarmer))

#define isguardian(A) (istype(A, /mob/living/simple_animal/hostile/guardian))

#define isclockmob(A) (istype(A, /mob/living/simple_animal/hostile/clockwork))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define isfauna(A) (istype(A, /mob/living/simple_animal/hostile/asteroid))

#define ismegafauna(A) (istype(A, /mob/living/simple_animal/hostile/megafauna))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))

#define issupplypod(A) (istype(A, /obj/structure/closet/supplypod))

//Misc mobs
#define isobserver(A) (istype(A, /mob/dead/observer))

#define isdead(A) (istype(A, /mob/dead))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define iscameramob(A) (istype(A, /mob/camera))

#define isaicamera(A) (istype(A, /mob/camera/ai_eye))

#define iseminence(A) (istype(A, /mob/camera/eminence))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isstack(A) (istype(A, /obj/item/stack))

#define isidcard(I) (istype(I, /obj/item/card/id))

#define isstructure(A) (istype(A, /obj/structure))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ismecha(A) (istype(A, /obj/mecha))

#define ismopable(A) (A && (A.layer <= FLOOR_CLEAN_LAYER)) //If something can be cleaned by floor-cleaning devices such as mops or clean bots

#define isorgan(A) (istype(A, /obj/item/organ))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define iscash(A) (istype(A, /obj/item/coin) || istype(A, /obj/item/stack/spacecash) || istype(A, /obj/item/holochip))

#define isbodypart(A) (istype(A, /obj/item/bodypart))

#define isprojectile(A) (istype(A, /obj/projectile))

#define isgun(A) (istype(A, /obj/item/gun))

#define is_reagent_container(O) (istype(O, /obj/item/reagent_containers))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/assembly))

#define isigniter(O) (istype(O, /obj/item/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/assembly/signaler))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/plastitaniumglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

#define iseffect(O) (istype(O, /obj/effect))

#define isblobmonster(O) (istype(O, /mob/living/simple_animal/hostile/blob))

#define isshuttleturf(T) (!isnull(T.depth_to_find_baseturf(/turf/baseturf_skipover/shuttle)))

//Fugitive
#define isfugitive(M) (istype(M) && M.mind?.has_antag_datum(/datum/antagonist/fugitive))

#define isProbablyWallMounted(O) (O.pixel_x > 20 || O.pixel_x < -20 || O.pixel_y > 20 || O.pixel_y < -20)

GLOBAL_LIST_INIT(turfs_openspace, typecacheof(list(
	/turf/open/openspace,
	/turf/open/space/openspace
	)))

#define istransparentturf(A) (HAS_TRAIT(A, TURF_Z_TRANSPARENT_TRAIT))

#define isopenspaceturf(A) (is_type_in_typecache(A, GLOB.turfs_openspace))

// Jobs
#define is_job(job_type)  (istype(job_type, /datum/job))
#define is_assistant_job(job_type) (istype(job_type, /datum/job/assistant))
#define is_bartender_job(job_type) (istype(job_type, /datum/job/bartender))
#define is_captain_job(job_type) (istype(job_type, /datum/job/captain))
#define is_chaplain_job(job_type) (istype(job_type, /datum/job/chaplain))
#define is_clown_job(job_type) (istype(job_type, /datum/job/clown))
#define is_detective_job(job_type) (istype(job_type, /datum/job/detective))
#define is_scientist_job(job_type) (istype(job_type, /datum/job/scientist))
#define is_security_officer_job(job_type) (istype(job_type, /datum/job/security_officer))
#define is_research_director_job(job_type) (istype(job_type, /datum/job/research_director))
#define is_unassigned_job(job_type) (istype(job_type, /datum/job/unassigned))

#define isprojectilespell(thing) (istype(thing, /datum/action/cooldown/spell/pointed/projectile))
#define is_multi_tile_object(atom) (atom.bound_width > world.icon_size || atom.bound_height > world.icon_size)
