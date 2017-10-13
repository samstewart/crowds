module Main
	using GR;
	using Display;

	function main()

		t = 0.0 # in seconds
		dt = 0.01
		start = refresh = time_ns()

		setviewport(0, 1, 0, 1);
		updatews()
		clearws()

		setarrowsize(2);

		setcolorrep(2, 1, 1, 1);
		setfillintstyle(1);
		setfillcolorind(2);


		n = 3;
		s = State(max.(min.(1, randn(n, 2) * .3  + .5), 0),
			 randn(n, 2) * .4,
			ones(n) * .018,
			max.(min.(1, randn(n, 2) * .3  + .5), 0),
			zeros(Bool, 2, n))

		while true 
			if time_ns() - refresh > 1e5 # 200 ms
				
				clearws();
				setfillcolorind(1)

				plotState(s)	
				s = update(.01, s);

				t += dt;
				refresh = time_ns();
			end
			
			now = (time_ns() - start) / 1e9

			if t > now
				sleep(t - now)
			end

		end
	end
e
end
