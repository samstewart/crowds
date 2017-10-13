# 04/13/2017

Wrestled for most of the day with an annoying bug in PyCharm and Julia. After extensive testing, I have realized that PyCharm crashes when an object has too many methods. Of course, the Julia binding fills the object with 1392 entries from the Base library. Normal IPython can handle this, but there is a memory leak error for PyCharm. I have not yet filed a bug. My temporary workaround is to disable the method name import feature and instead rely on Julia.eval(..) method.

# 04/27/17
Goals:
1. Find the parts of the code that are slowest (find some kind of Julia profiler?)
2. Add the collision detection for obstacles (with tests)
3. Binary search for binning algorithm (with tests)
4. Add the obstacles to the visualization library.

Long term goals:
1. Refactor the code for the state machine event handling to an external library?
2. Read configuration from SVG or EPS file?

Todo: 
Handle scaling consistently between the simulator and the graphical interface