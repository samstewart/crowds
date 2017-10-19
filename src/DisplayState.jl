module DisplayState
	using GR;
	using Colors;

	export plotState;

	function matrixPlot(A, colors)
		i = 0;

		for c in colors
			setcolorrep(i, c.r, c.g, c.b);
			i += 1;
		end 
		cellarray(0, 1, 0, 1, size(A, 2), size(A, 1), A);

		updatews();
	end

	function plotState(M :: BitArray{2})

		matrixPlot(M, [colorant"white", colorant"black"]);
	end

	function plotState(density :: Array{Int64, 2})
		
		matrixPlot(density, rangeOfColors(maximum(density), colorant"red"));

	end

	function rangeOfColors(maxVal, baseColor)

		if 0 < maxVal 
			brightnessRange = range(0, .8 / maxVal, maxVal + 1);
			baseColor = convert(HSL, baseColor);
			map(b -> convert(RGB, HSL(baseColor.h, baseColor.s, b)), brightnessRange);
		else
			[colorant"black"];
		end

	end

	function plotState(density, obstacles, exits)

		rendered = density[:,:];
		
		maxVal = maximum(density);
		
		# color obstacles green and exits blue
		rendered[obstacles] = maxVal + 1;
		rendered[exits] = maxVal + 2;

		colors = vcat(rangeOfColors(maxVal, colorant"black"), [colorant"green", colorant"blue"]);
		
		matrixPlot(rendered, colors);
	end
end
