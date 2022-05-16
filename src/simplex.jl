


# Construct 
function construct_Ab(sudoku_cube::Array{Bool})

    N = size(sudoku_cube,1)

    # Find the un-assigned Sudoku entries
    decision_var_cube = one(sudoku_cube)
    for i=1:N
        for j=1:N
            for k=1:N
                if sudoku_cube[i,j,k]
                    # Everywhere an entry is assigned a value,
                    # the entire row/col/pipe/quadrant is also
                    # resolved.
                    decision_var_cube[:,j,k] .= false
                    decision_var_cube[i,:,k] .= false
                    decision_var_cube[i,j,:] .= false
                    q_i, q_j = get_quadrant_idx((i,j); N=N)
                    decision_var_cube[q_i, q_j, k] .= false 
                end
            end
        end
    end
    n_variables = sum(decision_var_cube)

    # Assign an order to these decision variables
    decision_variables = Tuple{Int,Int,Int}[]
    for i=1:N
        for j=1:N
            for k=1:N
                if decision_var_cube[i,j,k]
                    push!(decision_variables, (i,j,k))
                end
            end
        end
    end
    dec_var_to_idx = Dict(v => i for (i,v) in enumerate(decision_variables))

    # For each decision variable, we have a slack variable
    # to model the upper bounds
    slack_variables = deepcopy(decision_variables)

end


function pivot!(basis_idx::Vector{<:Integer}, x::Vector{<:Number}, 
                A::Matrix{<:Number}, b::Vector{<:Number}, c::Vector{<:Number};
                mode="optimize")
    
    n = length(x)
    basis_idx_set = Set(basis_idx)
    nonbasis_idx = [i for i=1:n if !in(i, basis_idx_set)]

    B = view(A, :, basis_idx)
    N = view(A, :, nonbasis_idx)

    lambda = transpose(B) \ c[basis_idx]

    # Select entry index!
    q = -1 

    if (mode == "optimize")
        s_N = c[nonbasis_idx] .- transpose(N)*lambda
        if all(s_N .>= 0)
            return 0 # Code for "optimum found!"
        end

        # Find the index, q, of the most negative s_N
        # (I.e., Dantzig's rule)
        min_sN_idx = argmin(s_N)
        q = nonbasis_idx[min_sN_idx]
    else 
        # If we're just "exploring" the feasible set, then
        # return a random non-basis index
        q = rand(nonbasis_idx) 
    end

    d = B\A[:,q]

    pos_idx = findall(d .> 0)

    if length(pos_idx) == 0
        return 1 # Code for "unbounded problem!"
    end

    r = x[basis_idx] ./ d 
    min_idx = argmin(r[pos_idx])
    x_q_next = r[pos_idx[min_idx]]
    p = basis_idx[pos_idx[min_idx]]

    x[basis_idx] .-= (d .* x_q_next)
    x[nonbasis_idx] .= 0
    x[q] = x_q_next

    deleteat!(basis_idx, searchsorted(basis_idx,p).start)
    insert!(basis_idx, searchsorted(basis_idx,q).start, q)

    return 2
end


