module Simulator

	# simulation occurs in region [0, 1]^2
	type State
		x :: Array{Float32, 2}
		v :: Array{Float32, 2}
		radii :: Array{Float32, 1}

		goals :: Array{Float32, 2}
		teams :: BitArray{2}
	end
	
	function update(s, dt)

		s.x 	        += dt * s.v

		s.x[radii .> 0] = project_to_legal(radii .> 0, s)
	end

end
