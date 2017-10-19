push!(LOAD_PATH, ".");

using DisplayState;
using Scenarios;

d, o, e = Scenarios.entranceTubeTwoExits(50);

d[:, 1:30] = 0;
d[15:50, :] = 0;

d[:, :] = 0;

d[2:6, 20:25] = 1;


d, o, e = Scenarios.shortWayLongWay(50);


World.main(d, o, e)
