parameter_defaults = @with_kw (ρ = 0.02,
                                σ = 3.9896,
                                N = 10,
                                θ = 4.7060,
                                γ = 1.00,
                                κ = 0.0103,
                                ζ = 1.,
                                η = 0.,
                                Theta = 1,
                                χ = 0.4631,
                                υ = 0.0755,
                                μ = 0.,
                                δ = 0.053,
                                d = 2.5019,
                                d0 = 3.07)

# some default settings
settings_defaults = @with_kw (z_max = 5,
                                z = unique([range(0., 0.1, length = 400)' range(0.1, 1., length = 400)' range(1., z_max, length = 100)']),
                                E_node_count = 15,
                                entry_residuals_nodes_count = 15,
                                Δ_E = 1e-4,
                                weights = [fill(entry_residuals_nodes_count, 3); fill(1, entry_residuals_nodes_count-3)],
                                iterations = 2,
                                ode_solve_algorithm = CVODE_BDF(),
                                g_node_count = 30,
                                T = 100.
                                t = range(0.0, T, length = 10),
                                g = LinearInterpolation(t, stationary_numerical(parameter_defaults(), z).g .+ 0.01*t))
