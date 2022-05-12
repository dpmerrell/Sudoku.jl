

"""
   Return a vector of feasible values 
   for a given location in the table 
"""
function feasible_values(idx::Tuple, table::Matrix{<:Integer})

    N = 9

    feasible = ones(Bool, N)
    
    # Eliminate existing column values
    for v in table[:,idx[2]]
        if v != 0 
            feasible[v] = false
        end
    end
    
    # Eliminate existing row values
    for v in table[idx[1],:]
        if v != 0 
            feasible[v] = false
        end
    end 

    # Eliminate existing quadrant values
    for v in get_quadrant_values(idx,table)
        if v != 0
            feasible[v] = false
        end
    end

    return findall(feasible)
end



function get_unknown_idx(table::Matrix)
    unknown_idx = findall(table .== 0)
    return map(Tuple, unknown_idx)
end


function get_quadrant_values(idx::Tuple, table::Matrix{T}) where T <: Number

    N = 9
    N_sqrt = 3

    start_i = div(idx[1]-1,N_sqrt)*N_sqrt
    start_j = div(idx[2]-1,N_sqrt)*N_sqrt

    quadrant_values = zeros(T, N)
    for i=1:N_sqrt
        for j=1:N_sqrt
            quadrant_values[(i-1)*N_sqrt + j] = table[start_i+i,start_j+j]  
        end
    end 

    return quadrant_values
end


function is_valid_table(table::Matrix{<:Integer})

    N = size(table, 1)
    N_sqrt = Int(sqrt(N))

    # rows
    for i=1:N
        nz_idx = table[i,:] .!= 0
        nz_vals = table[i,nz_idx]
        nnz = sum(nz_idx)
        if length(unique(nz_vals)) != nnz
            return false
        end
    end

    # columns
    for i=1:N
        nz_idx = table[:,i] .!= 0
        nz_vals = table[nz_idx,i]
        nnz = sum(nz_idx)
        if length(unique(nz_vals)) != nnz
            return false
        end
    end

    # quadrants   
    for i=1:N
        row = (div(i-1, N_sqrt)+1)*N_sqrt
        col = (mod(i-1, N_sqrt)+1)*N_sqrt
        qv = get_quadrant_values((row, col), table)
        nz_idx = qv .!= 0
        nz_vals = qv[nz_idx]
        nnz = sum(nz_idx)
        if length(unique(nz_vals)) != nnz
            return false
        end
    end

    return true
end
