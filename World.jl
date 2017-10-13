module World
	using CA.Grid;
	using CA.ShortestPaths;
	using CA.Display;
	using GR;

	import Base: isless;
	import Base.Iterators: product, length;

	export main

	# to find best neighbor, we need a total ordering
	function Base.isless(e1 :: Tuple{Float64, NTuple{2}}, e2 :: Tuple{Float64, NTuple{2}})

		e1[1] <= e2[1];

	end

	function bestNeighbor(scores, density, obstacles, p :: NTuple{2})

		let scoredNeighbors = [(scores[g], g) for g in nonObstacleNeighbors(p, density, obstacles)] 
			# randomly break ties
			last(minimum(shuffle!(scoredNeighbors)));

		end
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

		density[exits .& peopledCells(density)] -= 1;

	end

	function update(density :: Array{Int64, 2}, obstacles :: BitArray{2}, exits :: BitArray{2})
		newdensity = density[:, :];
		
		# compute cost function for each cell 
		scores = computeScores(density, obstacles, exits);

		peopled = peopledCells(density);

		for x = randperm(width(density))
			for y = randperm(height(density)) 

				p = (x,y);
				
				# todo: will have double counting of exits and those guys exiting
				if peopled[p] && ! obstacles[p] 

					movePeopleBetweenCells!(newdensity, p, bestNeighbor(scores, density, obstacles, p));		

				end

				makePeopleExit!(newdensity, exits);
			end
		end

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
			
			if time_ns() - refresh > 1e8 # 200 ms

				plotState(density, obstacles, exits);

				density = update(density, obstacles, exits);

				t += dt;

				refresh = time_ns();
			end
			
			# wait to sync time with simulator time
			now = (time_ns() - start) / 1e9

			if t > now
				sleep(t - now)
			end

		end

		
	end
end
