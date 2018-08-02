include("matlabobjects.jl") # results to be compared with; estimated from the original MATLAB code

## Unit tests for algebraic solution for stationary cases in the simple model
# Generate default parameters.
simple_algebraic_params = @with_kw (γ = 0.005, σ = 0.02, α = 2.1, r = 0.05, ζ = 14.5)

# Test them
results = stationary_algebraic_simple(simple_algebraic_params());
@test results.g ≈ 0.0211182826;
@test results.ν ≈ 1.75369955156;
@test results.v(0) ≈ 35.04962283;
@test results.v(2) ≈ 165.31581267;
@test results.v(5) ≈ 3312.7957099;


## Unit tests for numerical solution for stationary cases in the simple model
# Generate default parameters.
simple_numerical_params = @with_kw (γ = 0.005, σ = 0.02, α = 2.1, r = 0.05, ζ = 14.5, ξ=1)

# Test for one particular grid. MATLAB solve_nonlinear_system = false.
z = unique([linspace(0.0, 1.0, 500)' linspace(1.0, 5.0, 201)'])
results = stationary_numerical_simple(simple_numerical_params(), z)
@test results.g ≈ 0.0204899363906 # Growth rate

# Test for a third grid.
z = unique([linspace(0.0, 1.0, 1000)' linspace(1.0, 2.0, 11)' linspace(2.0, 5.0, 20)'])
results = stationary_numerical_simple(simple_numerical_params(), z)
@test results.g ≈ 0.02058576255994 # Growth rate

# Test for change zbar for grid and add points.
z = unique([linspace(0.0, 1.0, 1000)' linspace(1.0, 2.0, 60)' linspace(2.0, 8.0, 40)'])
results = stationary_numerical_simple(simple_numerical_params(), z)
@test results.g ≈ 0.0211796240274 # Growth rate

# Test for change zbar for grid and add points.
z = unique([linspace(0.0, 1.0, 1000)' linspace(1.0, 2.0, 60)' linspace(2.0, 10.0, 40)'])
results = stationary_numerical_simple(simple_numerical_params(), z)
@test results.g ≈ 0.02123967993879092 # Growth rate

# a baseline grid z
z = unique([linspace(0.0, 1.0, 300)' linspace(1.0, 2.0, 50)' linspace(2.0, 7.0, 50)'])
results = stationary_numerical_simple(simple_numerical_params(), z)
@test results.g ≈ 0.0211710310711 # Growth rate
