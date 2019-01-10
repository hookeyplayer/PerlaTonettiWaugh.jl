module PerlaTonettiWaugh

# Dependencies.
using DifferentialEquations, Sundials, LinearAlgebra, DataFrames, DataFramesMeta, DiffEqCallbacks, Interpolations, QuadGK, NLopt, ForwardDiff, LeastSquaresOptim, BlackBoxOptim
using NLSolversBase
import Parameters: @with_kw, @unpack
import DFOLS

# General utilities files.
include("utils/params.jl")
include("utils/diffusionoperators.jl")
include("utils/quadrature.jl")
include("utils/solve-system.jl")
include("utils/consumption-equivalent.jl")
include("utils/display_stationary_sol.jl")
# Simple model.
include("simple/dynamic.jl")
include("simple/stationary.jl")
include("simple/residuals.jl")
# Full model.
include("full/stationary.jl")
include("full/dynamic.jl")
include("full/transition.jl")

export parameter_defaults, settings_defaults, settings_simple_defaults, parameter_simple_stationary_defaults, parameter_simple_transition_defaults
export stationary_algebraic, stationary_numerical, simpleODE, simpleDAE, stationary_algebraic_simple, stationary_numerical_simple, ω_weights, calculate_residuals, rescaled_diffusionoperators, diffusionoperators, solve_dynamics, welfare
export minimize_residuals, residuals_given_E_nodes_interior
export solve_full_model_global, solve_full_model, solve_full_model_dfols, solve_continuation
export consumption_equivalent, display_stationary_sol
export f!, f!_simple, f_simple, solve_system

end # module
