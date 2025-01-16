/// We only want chunk sizes that are to the power of 2. E.g: 2, 4, 8, 16, etc..
#define CHUNK_SIZE 16
/// Takes a position, transforms it into a chunk bounded position. Indexes at 1 so it'll land on actual turfs always
#define GET_CHUNK_COORD(v) (max((FLOOR(v, CHUNK_SIZE)), 1))

//List of different camera nets, cameras are given this in the map and camera consoles can only view them if
//they share this network with them.
#define CAMERANET_NETWORK_CURATOR "curator"
