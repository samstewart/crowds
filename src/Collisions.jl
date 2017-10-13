module Collisions
	using World

	export project_to_legal

	import Base.isless

	function is_legal_position(indexOfGuy, proposedPosition, s)
		# todo: if too slow, filter by bins
		for i in guys(s)

			if dist(s.x[i, :], s.x[indexOfGuy]) < s.radii[i] + s.radii[indexOfGuy]
				return false
			end

		end

		return true;
	end

	function dist(p, q)
		norm(p - q)
	end

	function project_to_legal(idx, s)
		
		# closest legal point on 21x21 grid
		dist = q -> norm(q - p)
		isLegal = is_legal_position(idx, q, s)

		minScored(filter(isLegal, mesh_grid(p, 10)), dist)	

	end
	
	function is_legal_point()

	end

	function Base.isless(e1 :: NTuple{2}, e2 :: NTuple{2})
		e1[2] <= e2[2]
	end

	function minScored(ls, f)

		first(minimum([(l, f(l)) for l in ls]))

	end

	function project_to_legal(players :: BitArray{1}, s)
		
		newx = s.x[:, :]

	    for i in find(players)

		    project_to_legal(i, s)

	    end

	end

	function mesh_grid(p, n)

		lattice = product(0:(2*n), 0:(2*n));
		
	end

end
