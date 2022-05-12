
export solve

"""
    Given a table, order the unknown entries by 
    greedily finding the entry with smallest degree of freedom. 
    For our purposes, we only need to know
    which entries are filled/empty.
    
    This ordering heuristic is based on the idea
    of first filling the entries that are most 
    tightly constrained -- hopefully reducing the number
    of times we'll revisit an entry.
"""
function greedy_dof_ordering(table::Matrix{<:Integer})

    N = 9

    unknown_idx = get_unknown_idx(table)
    n_unknown = length(unknown_idx)

    # Base case
    if n_unknown == 1
        return [unknown_idx[1]]
    end

    # Recursive case
    dof = zeros(Int, n_unknown)
    
    for idx in unknown_idx
        col_dof = N - sum(table[:,idx[2]]) 
        row_dof = N - sum(table[idx[1],:])
        quadrant_dof = N - sum(get_quadrant_values(idx,table)) 
        comb_dof = min(col_dof, col_dof, quadrant_dof)
    end 
    min_idx = unknown_idx[argmin(dof)]

    table[min_idx...] = 1 

    # Now compute the ordering for the remaining
    # empty entries
    ordering = greedy_dof_ordering(table)
    pushfirst!(ordering, min_idx)

    # Restore the table -- shouldn't be mutating it
    table[min_idx...] = 0

    return ordering
end



"""
    Recursive DFS method. Assigns a value to 
    the first variable and then recurses to 
    the remaining variables.

    May return a single solution (`solutions=="first"`), 
    or the vector of all solutions (`solutions`=="all"`).
"""
function tree_search(table::Matrix{UInt8}, var_ordering::Vector{<:Tuple};
                     solutions="first")

    if length(var_ordering) == 0
        return Matrix{UInt8}[copy(table)]
    end

    first_var = var_ordering[1]
    solutions = Matrix{UInt8}[]
    for v in feasible_values(first_var, table) 
    
        table[first_var...] = UInt8(v)
        sols = tree_search(table, var_ordering[2:end]; solutions=solutions)

        if length(sols) > 0
            if solutions == "first"
                return sols
            end

            solutions = vcat(solutions, sols)
        end
    end

    # Reset the table 
    table[first_var...] = 0x00

    return solutions
end


function solve_tree_search(table::Matrix{UInt8}; solutions="first",
                           var_ordering="dof")
    
    if var_ordering == "dof"
        var_ordering = greedy_dof_ordering(table)
    else
        var_ordering = get_unknown_idx(table) 
    end

    solutions = tree_search(table, var_ordering; solutions=solutions)

    return solutions
end 


"""
    Receives the path to a .txt file containing the
    Sudoku puzzle, and prints the solutions to stdout.
"""
function solve(table_file::AbstractString; solutions="first")
    
    table = read_sudoku_file(table_file)

    solutions = solve_tree_search(table; solutions=solutions)

    for (i, sol) in enumerate(solutions)
        println(string("#"^5, " Solution ", i ," ", "#"^5))
        print(table_to_str(sol))

        println("\n")
    end
 
end



