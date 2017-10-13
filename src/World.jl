module World
	function guys(s)
		1:size(s.x, 1);
	end

	function add_line_obstacle(s, p1, p2)

	    d = p2 - p1

	    # the spacing is chosen so that the disks can't pass through the obstacle. 
	    t = linspace(0, 1, UInt32(ceil(norm(d) / obstacle_sample_spacing)) + 1)
	    
	    ps = p1' .+ t * d' # generate the points along the line
	    
	    # insert the obstacles into the world
	    x = vcat(x, ps)
	    v = vcat(v, zeros(size(ps, 1), 2))
	    
	    radii = vcat(radii, zeros(size(ps, 1), 1))

	    bins = zeros(Bool, size(bins, 1), size(x, 1))
	    
	    closest_agents = vcat(closest_agents, zeros(size(ps, 1), size(closest_agents, 2)))
	end


end
