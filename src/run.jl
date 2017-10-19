push!(LOAD_PATH, ".");

using Display;
using Scenarios;

d, o, e = Scenarios.maze(20);

Display.plotState(o);