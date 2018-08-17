
# Implementation of the simple model with time-varying objects. 
function simpleODE(params, settings)
    # Unpack necessary objects. 
    @unpack γ, σ, α, r, x, ξ, π_tilde = params
    @unpack z, T, g = settings 
    M = length(z)

    # Discretize the operator. 
    z, L_1_minus, L_1_plus, L_2 = rescaled_diffusionoperators(z, ξ) # L_1_minus ≡ L_1 is the only one we use. 

    # Calculate the stationary solution.
    r_T = r(T)
    g_T = g(T)
    π_tilde_T = z -> π_tilde(T, z)

    # NOTE: the following two lines overlap with stationary solution
    L_T = (r_T - g_T - ξ*(γ - g_T) - σ^2/2*ξ^2)*I - (γ - g_T + σ^2*ξ)*L_1_minus - σ^2/2 * L_2 # Construct the aggregate operator.
    v_T = L_T \ π_tilde_T.(z) # Solution to the rescaled differential equation.

    # Bundle as before. 
    p = @NT(L_1 = L_1_minus, L_2 = L_2, z = z, g = g, r = r, σ = σ, π_tilde = π_tilde, T = T, γ = γ, g_T = g_T) #Named tuple for parameters.

    # Dynamic calculations, defined for each time ∈ t.  
    function f(du,u,p,t)
        @unpack L_1, L_2, z, r, γ, g, σ, π_tilde, T = p 
        # Validate upwind scheme direction. 
        (γ - g(t)) < 0 || error("μ - g must be strictly negative at all times")
        # Carry out calculations. 
        L = (r(t) - g(t) - ξ*(γ - g(t)) - σ^2/2*ξ^2)*I - (γ - g(t) + σ^2*ξ)*L_1 - σ^2/2 * L_2
        A_mul_B!(du,L,u)
        du .-= π_tilde.(t, z)
    end

    return ODEProblem(f, v_T, (T, 0.0), p)
end

# Implementation of the simple model with time-varying objects, represented by DAE
function simpleDAE(params, settings)
    # Unpack necessary objects. 
    @unpack γ, σ, α, r, x, ξ, π_tilde = params
    @unpack z, T, g = settings 
    M = length(z)

    # Quadrature weighting
    ω = ω_weights(z, α, ξ)

    # Discretize the operator. 
    z, L_1_minus, L_1_plus, L_2 = rescaled_diffusionoperators(z, ξ) # L_1_minus ≡ L_1 is the only one we use. 

    # Calculate the stationary solution.
    r_T = r(T)
    g_T = g(T)
    π_tilde_T = z -> π_tilde(T, z)

    # NOTE: the following two lines overlap with stationary solution
    L_T = (r_T - g_T - ξ*(γ - g_T) - σ^2/2*ξ^2)*I - (γ - g_T + σ^2*ξ)*L_1_minus - σ^2/2 * L_2 # Construct the aggregate operator.
    v_T = L_T \ π_tilde_T.(z) # Solution to the rescaled differential equation.

    # Bundle as before. 
    p = @NT(L_1 = L_1_minus, L_2 = L_2, z = z, g = g, r = r, σ = σ, π_tilde = π_tilde, T = T, γ = γ, g_T = g_T, M = M) #Named tuple for parameters.

    # Dynamic calculations, defined for each time ∈ t.  
    function f!(resid,dv,v,p,t)
        @unpack L_1, L_2, z, r, γ, g, σ, π_tilde, T, M = p 
        # Carry out calculations. 
        L = (r(t) - g(t) - ξ*(γ - g(t)) - σ^2/2*ξ^2)*I - (γ - g(t) + σ^2*ξ)*L_1 - σ^2/2 * L_2        
        v_interior = v[1:p.M]
        resid[1:M] = L * v_interior - π_tilde.(t, z) 
        resid[M+1] = v_interior[1] + x.(t) - dot(ω, v_interior)
        resid .-= dv
    end

    v_M1 = [v_T; 1.0]
    dv_M1 = zeros(M+1)
    resid_M1 = zeros(M+1)
    

    return DAEProblem(f!, resid_M1, v_M1, (T, 0.0), differential_vars = [trues(v_T); false], p)
end