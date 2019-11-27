exports.WINDOW = 1;
exports.RWINDOW = 2;
exports.WINDOWS = exports.WINDOW | exports.RWINDOW;

exports.WALL = 4;
exports.RWALL = 8;
exports.WALLS = exports.WALL | exports.RWALL;

exports.FLOOR = 16;
exports.SPACE = 32;

exports.WINDOW_HALLWAY = 64; // Allow hallway/department windows
exports.WINDOW_SPACE = 128; // Allow space windows
exports.WINDOW_DEPARTMENT = 256; // Allow windows within department
exports.WINDOW_NOCABLE = 512; // Allow window without a cable
exports.WINDOW_ALL = exports.WINDOW_HALLWAY | exports.WINDOW_SPACE | exports.WINDOW_DEPARTMENT | exports.WINDOW_NOCABLE;
