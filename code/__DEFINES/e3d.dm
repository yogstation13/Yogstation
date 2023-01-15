// This defines the various rendery types you can use to display icons in 3D when using the 3d webclient
// characters 9,10,11,12,13 are whitespace and can be use in screen_loc without breaking things
// set this as your screen_loc or put it at the end. This uses screen_loc because it is sent to clients always.

// Note that because turfs can't access screen_loc, they are handled via plane: -1 is walls, -2 is floors.

// E3D_TYPE_BILLBOARD is the default type.

#define E3D_TYPE_BILLBOARD "\x09"
#define E3D_TYPE_FLOOR "\x0A"
#define E3D_TYPE_WALLMOUNT "\x0B"
#define E3D_TYPE_WALLMOUNT_SIGN "\x0C"
#define E3D_TYPE_SMOOTHWALL "\x0D"
#define E3D_TYPE_FALSEWALL "\x09\x09"
#define E3D_TYPE_ITEM "\x09\x0A"
#define E3D_TYPE_DOOR "\x09\x0B"
#define E3D_TYPE_LIGHTFIXTURE "\x09\x0C"
#define E3D_TYPE_TABLE "\x09\x0D"
#define E3D_TYPE_BASICWALL "\x0A\x09"
#define E3D_TYPE_EDGE "\x0A\x0A"
#define E3D_TYPE_EDGEFIREDOOR "\x0A\x0B"
#define E3D_TYPE_EDGEWINDOOR "\x0A\x0C"
#define E3D_TYPE_GAS_OVERLAY "\x0A\x0D"

#define E3D_SEE_ZOOM 0x8000

#define SET_SCREEN_LOC(thing, new_screen_loc) thing.screen_loc = "[new_screen_loc][extract_e3d_tag(thing.screen_loc)]"
#define CLEAR_SCREEN_LOC(thing) thing.screen_loc = extract_e3d_tag(thing.screen_loc)