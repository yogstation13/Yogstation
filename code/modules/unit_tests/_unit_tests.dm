//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

#define UNIT_TEST_PASSED 0
#define UNIT_TEST_FAILED 1
#define UNIT_TEST_SKIPPED 2

#define TEST_DEFAULT 1
#define TEST_DEL_WORLD INFINITY


#include "anchored_mobs.dm"
#include "component_tests.dm"
#include "dynamic_ruleset_sanity.dm"
#include "create_and_destroy.dm"
#include "reagent_id_typos.dm"
#include "reagent_recipe_collisions.dm"
#include "spawn_humans.dm"
#include "species_whitelists.dm"
#include "subsystem_init.dm"
#include "timer_sanity.dm"
#include "unit_test.dm"


#endif
