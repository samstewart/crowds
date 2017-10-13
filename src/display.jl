module Display
	using GR;
	using World;

	export plotState;

	function computeArrowTail(p, v)

		normalizedVelocity = v / norm(v);

		epsilon = .0001;

		p + epsilon * normalizedVelocity;
	end

	function drawGuy(idx, s)

		p = s.x[idx, :];
		v = s.v[idx, :];

		tail = computeArrowTail(p, v);

		drawarrow(p[1], p[2], tail[1], tail[2]);

	end

	function plotState(s) 

		for i = guys(s) 

			drawGuy(s.x[i, :], s.v[i, :])

		end

	end
end
