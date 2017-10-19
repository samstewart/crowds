module World
	push!(LOAD_PATH, "/home/ubuntu/workspace/crowds/src/");
	
	using Grid;
	using ShortestPaths;
	using .Display;
	using GR;

	import Base: isless;
	import Base.Iterators: product, length, filter, isempty;

	export main, legalNeighbors, nonObstacleNeighbors

	# to find best neighbor, we need a total ordering
	function Base.isless(e1 :: Tuple{Float64, NTuple{2}}, e2 :: Tuple{Float64, NTuple{2}})

		e1[1] <= e2[1];

	end

	function scoredNeighbors(scores, density, obstacles, p)
	
		[(scores[q], q) for q in legalNeighbors(density, obstacles, p)]

	end
	
	function legalNeighbors(density, obstacles, p)
	
		filter(q -> isLegalNeighbor(density, obstacles, q), neighbors(p, density))
		
	end
	
	function nonObstacleNeighbors(density, obstacles, p)
	
		filter(q -> ! obstacles[q], neighbors(p, density))
		
	end
	
	function hasLegalNeighbors(density, obstacles, p)
		
		! isempty(legalNeighbors(density, obstacles, p));
		
	end
	
	function hasPeopleAndNotObstacle(density, obstacles, p)
	
		density[p] > 0 && ! obstacles[p];
		
	end
	
	function isLegalNeighbor(density, obstacles, q)
	
		! obstacles[q] && density[q] == 0;
		
	end
	
	function movePeopleBetweenCells!(density, p1 :: NTuple{2}, p2 :: NTuple{2})

		density[p1] -= 1;

		density[p2] += 1;

	end

	function peopledCells(density)
		0 .< density;		
	end

	function maxPeople(density)
	
		maximum(density);
		
	end

	function makePeopleExit!(density, exits)

		density[exits .& peopledCells(density)] = 0;

	end

	function update(density :: Array{Int64, 2}, obstacles :: BitArray{2}, exits :: BitArray{2})
		newdensity = density[:, :];
		
		# compute cost function for each cell 
		scores = computeScores(density, obstacles, exits);

		peopled = World.peopledCells(density);

		peopledCells = filter(p -> hasPeopleAndNotObstacle(density, obstacles, p), cells(density));
		
		cellsWithLegalMoves = filter(p -> hasLegalNeighbors(density, obstacles, p), peopledCells);
		
		for p in cellsWithLegalMoves
				
			# find the cheapest neighbor (one is gauranteed to exist) and break ties randomly (shuffle!)
			dst = last(minimum(shuffle!(scoredNeighbors(scores, density, obstacles, p))));
			
			movePeopleBetweenCells!(newdensity, p, dst);		
			
		end

		makePeopleExit!(newdensity, exits);
		
		newdensity;
	end	

	function main(density, obstacles, exits)

		t = 0.0 # in seconds
		dt = 0.001
		start = refresh = time_ns()

		setviewport(0, 1, 0, 1);
		updatews()
		clearws()
		
		while any(peopledCells(density))
			
			if time_ns() - refresh > 1e11 # 200 ms

				plotState(density, obstacles, exits);

				density = update(density, obstacles, exits);

				t += dt;

				refresh = time_ns();
			end
			
			# wait to sync time with simulator time
			now = (time_ns() - start) / 1e11

			if t > now
				sleep(t - now)
			end

		end

		
	end
end
