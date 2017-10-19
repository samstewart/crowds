
module Grid

	import Base: getindex, setindex!
	import Base.Iterators: product, filter

	export
	getindex, setindex!,

	makeExit!,

	width, height,

	neighbors,

	cells, wallCells, hasNeighbor

	

	
	function Base.getindex(grid :: AbstractArray, p :: Tuple{Int64, Int64})
		
		grid[p[1], p[2]];

	end

	function Base.setindex!(grid :: AbstractArray, v, p :: Tuple{Int64, Int64})

		grid[p[1], p[2]] = v;

	end

	function makeExit!(exits, obstacles, p :: NTuple{2})
		exits[p] = true;
		obstacles[p] = false;
	end

	function width(grid)

		size(grid, 2);

	end

	function height(grid)

		size(grid, 1);

	end

	function isNeighbor(p, q)
	
		q in [right(p), up(p), left(p), down(p)];
		
	end
	
	# neighbors of single cell
	function neighbors(p :: NTuple{2}, density)
		[n  for n in [up(p), down(p), left(p), right(p)] if all(0 .< n .<= size(density))]	
	end


	# neighbors of all cells marked 'true'
	function neighbors(P :: BitArray{2}, density)

		neighborsP = zeros(Bool, size(P));
		n,m = size(density);	

		for x in 1:n
			for y in 1:m
				if P[x,y]
					for n in neighbors((x,y), density)
						neighborsP[n] = true;
					end
				end
			end
		end

		neighborsP;
	end

	# sees if 'p' has neighbor that satisfies predicate f
	function hasNeighbor(p :: NTuple{2}, density, f)

		! isempty( filter(f, neighbors(p, density)) );

	end

	function cells(density)
		
		product(1:size(density, 1), 1:size(density, 2));

	end

	function wallCells(density)

		wallCells = BitArray(zeros(Bool, size(density)));
		n,m = size(density);

		for x in 1:n 
			for y in 1:m 
				wallCells[x,y] = (x in [1, n] || y in [1, m]);
			end
		end

		wallCells;
	end


	function up(p :: NTuple{2})

		(p[1], p[2] - 1);

	end	


	function down(p :: NTuple{2})

		(p[1], p[2] + 1);

	end

	function left(p :: NTuple{2})
		
		(p[1] - 1, p[2] );

	end

	function right(p :: NTuple{2})

		(p[1] + 1, p[2]);
	end
end
