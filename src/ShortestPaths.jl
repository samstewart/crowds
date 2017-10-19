module ShortestPaths
	
	export computeScores;
	
	import Base.Iterators: filter;
	
	using Grid;
	using World;

	function scoreAdjacent(src, dst, scores, density)
		# we add +1 for physical distance
		scores[src] + 10 * density[dst] + 1;
	end

	function explored(c, scores)
		scores[c] < typemax(Int64);
	end
	
	function isWavefrontCell(c, density, scores, obstacles)

		!obstacles[c] && explored(c, scores) && hasNeighbor(c, density, c -> !explored(c, scores));

	end


	function computeScores(density :: Array{Int64,2}, obstacles :: BitArray{2}, exits :: BitArray{2})

		INF =	typemax(Int64);

		distances 	= INF * ones(Int64, size(obstacles)); 

		distances[exits] = 0;

		distances[obstacles] = 0;


		while any(distances .== INF)
		
			# key that we cache these *before* we start updating the distances in the inner loop. 
			wavefront = collect(Iterators.filter(x -> isWavefrontCell(x, density, distances, obstacles), cells(density)))

			for c in wavefront			
				for n in nonObstacleNeighbors(density, obstacles, c)
					# maybe we found a new, shorter path?
					distances[n] = min(distances[n], scoreAdjacent(c, n, distances, density));	

				end
			end
		end
		
		distances;
	end

end
