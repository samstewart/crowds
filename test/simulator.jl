using Base.Test

# TODO: figure out how to run the unit tests. It's really dumb that it's so difficult!!!

# spatial hashing

@testset "initialize x,v,radii, simulation region, obstacle_sampling_space" begin
    initSimulation([.3 .3; .2 .2], [0 0; 0 1], [.5, .4], region=[0 0; 2.0 2.0], obstacle_interpolation=.00125, mesh_width=2e-2, number_of_bins=5)

    @test_approx_eq_eps(x, [.3 .3; .2 .2], 1e-5)
    @test_approx_eq_eps(v, [0 0; 0 1], 1e-5)
    @test_approx_eq_eps(radii, [.5, .4], 1e-5)
    @test_approx_eq_eps(obstacle_sample_spacing, .00125, 1e-5)
    @test_approx_eq_eps(mesh_size, 2e-2, 1e-4)
    @test_approx_eq_eps(simulation_region, [0 0; 2 2], 1e-4)

    @test size(bins) == (5, 2)
    @test size(closest_agents) == (2, 10)

    # now test the default values
    initSimulation([.3 .1; .2 .2], [0 0; 1 1], [.3, .4])
    @test_approx_eq_eps(x, [.3 .1; .2 .2], 1e-5)
    @test_approx_eq_eps(v, [0 0; 1 1], 1e-5)
    @test_approx_eq_eps(radii, [.3, .4], 1e-5)
    
    @test_approx_eq_eps(obstacle_sample_spacing, .0125, 1e-5)
    @test_approx_eq_eps(mesh_size, 6e-2, 1e-4)
    @test_approx_eq_eps(simulation_region, [0 0; 1 1], 1e-4)

    @test size(bins) == (4, 2)
    @test size(closest_agents) == (2, 10)    
end

# bins numbered from left to right, bottom to top
@testset "spatial hashing" begin
    initSimulation([.3 .3; .7 .7; 2 2], zeros(3,2), [.05; .05; .05])

    @test compute_bin_indices_for_disk( x[1, :], radii[1] ) == [1]
    @test compute_bin_indices_for_disk( x[2, :], radii[2] ) == [4]
    @test isempty( compute_bin_indices_for_disk( x[3, :], radii[3] ) ) # doesn't fit into bin

    # test the cases near boundaries of bins
    initSimulation([.47 .05; .5 .5], zeros(2,2), [.05; .05])

    @test compute_bin_indices_for_disk( x[1, :], radii[1] ) == [ 1, 2 ] # if straddling two lower boxes
    @test compute_bin_indices_for_disk( x[2, :], radii[2] ) == [1,2,3,4] # if right in the middle of the domain, we should belong to all

    # make sure obstacle points get classified
    initSimulation([.3 .3; ], [0 0; ], [0; ])

    @test compute_bin_indices_for_disk(x[1, :], radii[1] ) == [1 ]

    initSimulation([.3 .3; .6 0], [0 0; 0 0], [0; .05])

    @test compute_bin_indices_for_disk(x[1, :], radii[1] ) == [ 1 ]
    @test compute_bin_indices_for_disk(x[2, :], radii[2] ) == [ 2 ]
end

@testset "update bins" begin

    initSimulation([.3 .3; .7 .7; 2 2; .47 .05], zeros(4,2), [.05; .05; .05; .05])

    update_bins()


    @test compute_bin_indices_for_disk(x[4, :], radii[4]) == [1,2]
    @test bins[1, :] == [true, false, false, true]
    @test bins[2, :] == [false, false, false, true]
    @test bins[3, :] == [false, false, false, false]
    @test bins[4, :] == [false, true, false, false]

end

@testset "convert bins to agents" begin

    initSimulation([.3 .3; .7 .7; 2 2; .47 .05], [.1 .1; 0.0 0.0; 0 0; 0 0], [.05; .05; .05; .05])

    update_bins()

    # use the precomputed bin indices to find the indices for the agent
    @test bin_indices_for_agent( 1 ) == [1]
    @test bin_indices_for_agent( 2 ) == [4]
    @test isempty( bin_indices_for_agent( 3 ) ) # doesn't fit into bin
    @test compute_bin_indices_for_disk(x[4, :], radii[4]) == [1,2]
    @test bin_indices_for_agent( 4 ) == [1,2]
end

@testset "take and pad method" begin

    @test takeAndPad([1,2], 3) == [1,2,0]
    @test takeAndPad([1,2], 4) == [1,2,0,0]
    @test takeAndPad([], 3) == [0, 0, 0]

end

@testset "update closest neighbors" begin
    
    initSimulation([.3 .3; .7 .7; .2 .2; .15 .15], zeros(4,2), [.05; .05; .05; .05])

    # keep only the top four closest agents
    closest_agents = zeros(UInt32, size(x,1), 4)

    update_bins()
    update_closest_neighbors()

    @test bin_indices_for_agent(1) == [1]
    @test bin_indices_for_agent(2) == [4]
    @test bin_indices_for_agent(3) == [1]
    @test bin_indices_for_agent(4) == [1]

    @test closest_agents[1, :] == [3, 4, 0, 0]
    @test closest_agents[2, :] == [0, 0, 0, 0]
    @test closest_agents[3, :] == [4, 1, 0, 0]
    @test closest_agents[4, :] == [3, 1, 0, 0]

    # now try when agents overlap multiple bins
    initSimulation([.3 .3; .47 .05; .2 .2; .15 .15], zeros(4,2), [.05; .05; .05; .05])
    closest_agents = zeros(UInt32, size(x,1), 4)

    update_bins()
    update_closest_neighbors()

    @test bin_indices_for_agent(1) == [1]
    @test bin_indices_for_agent(2) == [1,2]
    @test bin_indices_for_agent(3) == [1]
    @test bin_indices_for_agent(4) == [1]  

    @test closest_agents[1, :] == [3, 4, 2, 0]
    @test closest_agents[2, :] == [1, 3, 4, 0]
    @test closest_agents[3, :] == [4, 1, 2, 0]
    @test closest_agents[4, :] == [3, 1, 2, 0]

    # now try when one agent overlaps all bins
    initSimulation([.3 .3; .5 .5; .2 .2; .15 .15], zeros(4,2), [.05; .05; .05; .05])
    closest_agents = zeros(UInt32, size(x,1), 4)

    update_bins()
    update_closest_neighbors()

    @test compute_bin_indices_for_disk(x[2, :], radii[2]) == [1,2,3,4]
    @test bin_indices_for_agent(1) == [1]
    @test bin_indices_for_agent(2) == [1,2,3,4]
    @test bin_indices_for_agent(3) == [1]
    @test bin_indices_for_agent(4) == [1]  

    @test closest_agents[1, :] == [3, 4, 2, 0]
    @test closest_agents[2, :] == [1, 3, 4, 0]
    @test closest_agents[3, :] == [4, 1, 2, 0]
    @test closest_agents[4, :] == [3, 1, 2, 0]
end

@testset "point allowed" begin
    # check to make sure allowed points are allowed    
    # two overlapping neighbors
    # just touching on x axis (note: exactly touching introduces rounding error)
    
    initSimulation([.25 .25; .36 .25], zeros(2,2), [.05; .05])

    @test point_allowed(x[1, :], radii[1], [2]) == true

    # check when two points overlapping
    # just touching on x axis
    initSimulation([.25 .25; .29 .25] , zeros(2,2), [.05; .05])

    @test point_allowed(x[1, :], radii[1], [2]) == false
    @test point_allowed(x[2, :], radii[2], [1]) == false

    # check multiple intersections
    initSimulation([.25 .25; .29 .25; .25 .29], zeros(3,2), [.05; .05; .05])

    @test point_allowed(x[1, :], radii[1], [2, 3]) == false
    @test point_allowed(x[2, :], radii[2], [1, 3]) == false
    @test point_allowed(x[3, :], radii[3], [1, 2]) == false

    # line intersection
    
    initSimulation([.16 .25; .25 .28; .34 .25], zeros(3,2), [.05; .05; .05])

    @test point_allowed([.25, .30], radii[2], [1,3]) == true
    @test point_allowed([.25, .27], radii[2], [1,3]) == false
    @test point_allowed([.25, .295], radii[2], [1,3]) == true
    @test point_allowed([.25, .31], radii[2], [1,3]) == true
    @test point_allowed([.25, .28], radii[2], [1,3]) == false
end

@testset "find intersecting neighbors" begin
    # two overlapping neighbors
    

    initSimulation([.25 .25; .27 .25], zeros(2,2), [.05; .05])

    @test norm(x[1, :] - x[2, :]) < radii[1] + radii[2]

    closest_agents = zeros(UInt32, size(x, 1), 3)

    update_bins()
    update_closest_neighbors()

    @test size(closest_agents) == (2, 3)
    @test closest_agents[1, :] == [2, 0, 0]
    @test closest_agents[2, :] == [1, 0, 0]

    @test find_intersecting_neighbors(1) == [2]
    @test find_intersecting_neighbors(2) == [1]


end

@testset "add line obstacle" begin
    # adds a line obstacle

    initSimulation([.1 .1; ], [.1 .1; ], [.05; ], obstacle_interpolation=.05)

    closest_agents = zeros(UInt32, size(x, 1), 3)

    @test compute_bin_indices_for_disk(x[1, :], radii[1]) == [1]

    add_line_obstacle([0, 0], [.1, 0])

    @test_approx_eq_eps(x, [.1 .1; 0 0; .05 0; .1 0], 1e-5)
    @test_approx_eq_eps(v, [.1 .1; 0 0; 0 0; 0 0], 1e-5)
    @test_approx_eq_eps(radii, [.05; 0; 0; 0], 1e-5)
    @test size(closest_agents) == (4, 3)
    @test closest_agents[1, :] == [4, 3, 2]
    @test closest_agents[2, :] == [3, 4, 1]
    @test closest_agents[3, :] == [2, 4, 1]
    @test closest_agents[4, :] == [3, 1, 2]

    # testing if we add to an empty array
    initSimulation(Array{Float32, 2}(0, 2), Array{Float32, 2}(0, 2),  Array{Float32, 1}(0), obstacle_interpolation=.05)
    
    closest_agents = zeros(UInt32, size(x, 1), 2)

    

    add_line_obstacle([0, 0], [.1, 0])

    @test_approx_eq_eps(x, [0 0; .05 0; .1 0], 1e-5)
    @test_approx_eq_eps(v, [0 0; 0 0; 0 0], 1e-5)
    @test_approx_eq_eps(radii, [0; 0; 0], 1e-5)

    @test size(closest_agents) == (3, 2)
    @test closest_agents[1, :] == [2, 3]
    @test closest_agents[2, :] == [1, 3]
    @test closest_agents[3, :] == [2, 1]
    
end

@testset "nearest legal point" begin
    # everything overlapping should be something close to the identity
    
    initSimulation([.25 .25; .6 .6], zeros(2,2), [.05; .05])

    @test_approx_eq_eps(nearest_legal_point(1, [2]), [.25, .25], mesh_size)
    @test_approx_eq_eps(nearest_legal_point(2, [1]), [.6, .6], mesh_size)

    # already overlapping two circles
    initSimulation([.25 .25; .34 .25], zeros(2,2), [.05; .05])

    @test_approx_eq_eps(nearest_legal_point(1, [2]), [.24, .25], mesh_size)
    @test_approx_eq_eps(nearest_legal_point(2, [1]), [.35, .25], mesh_size)
    
    # test three overlapping circles
    initSimulation([.16 .25; .25 .28; .34 .25], zeros(3,2), [.05; .05; .05])

    @test_approx_eq_eps(nearest_legal_point(1, [2]), [.15, .25], mesh_size)
    # this one is hard to see. should move the circle up or down
    @test_approx_eq_eps(nearest_legal_point(2, [1, 3]), [.25, .29], mesh_size)
    @test_approx_eq_eps(nearest_legal_point(3, [2]), [.35, .25], mesh_size)

    # test four overlapping circles
    initSimulation([.16 .25; .25 .28; .34 .25; .25 .22], zeros(4,2), [.05; .05; .05; .05])

    @test_approx_eq_eps(nearest_legal_point(1, [2,4]), [.15, .25], mesh_size)

    # this one is hard to see. should move the circle up or down
    @test_approx_eq_eps(nearest_legal_point(2, [1,3]), [.25, .29], mesh_size)
    @test_approx_eq_eps(nearest_legal_point(3, [2,4]), [.35, .25], mesh_size)
    @test_approx_eq_eps(nearest_legal_point(4, [1,3]), [.25, .21], mesh_size)

    # test an agent and an obstacle
    initSimulation([.05 .04;], [0 0;], [.05;])

    # add line on the ground
    add_line_obstacle([0, 0], [.1, 0])

    # now verify that moving up is the right option
    @test size(x) == (10, 2)
    @test_approx_eq_eps(nearest_legal_point(1, [2,3,4,5,6,7,8,9,10]), [.05, .05], mesh_size)
end

@testset "move agent to nearest legal position" begin
    # already overlapping two circles
    initSimulation([.25 .25; .34 .25], [0 0; 0 0], [.05; .05])

    closest_agents = zeros(UInt32, size(x, 1), 3)

    update_bins()
    update_closest_neighbors()

    @test find_intersecting_neighbors(1) == [2]
    @test find_intersecting_neighbors(2) == [1]
    @test_approx_eq_eps(nearest_legal_point(1, [2]), [.23, .25], mesh_size)

    move_agent_to_nearest_legal_position(1, find_intersecting_neighbors(1))

    @test_approx_eq_eps(x[1, :], [.23, .25], mesh_size)
end

@testset "project to legal configuration" begin
    
    initSimulation([.25 .25; .34 .25], [0 0; 0 0], [.05; .05])

    closest_agents = zeros(UInt32, size(x, 1), 3)

    project_to_legal_position()

    @test_approx_eq_eps(x, [.238 .25; .34 .25], mesh_size)
    
end
