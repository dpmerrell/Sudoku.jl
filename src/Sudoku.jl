module Sudoku

using ROBDD, LRUCache

export generate_indicator, generate_exclusive_group 


function generate_indicator(vars::Vector{Symbol}, idx::Int)
   
    # Determine whether this is the index 
    if idx == 1
        atom = vars[1]
    else
        atom = Expr(:call, :!, vars[1])
    end

    # Base case
    if length(vars) == 1
        return atom
    end

    # Recursive case
    return Expr(:call, :&, atom, generate_indicator(vars[2:end], idx-1)) 

end


function _rec_exclusive_group(vars::Vector{Symbol}, idx::Int)
    
    # Base case
    if idx == length(vars)
        return generate_indicator(vars, idx)
    end

    # Recursive case
    return Expr(:call, :|, generate_indicator(vars, idx),
                           _rec_exclusive_group(vars, idx+1))
end


function big_conjunct(exprs::Vector{Expr})
    if length(exprs) == 1
        return exprs[1]
    end

    return Expr(:call, :&, exprs[1], big_conjunct(exprs[2:end]))
end


function generate_exclusive_group(vars::Vector{Symbol})
    return _rec_exclusive_group(vars,1)
end


# Convert between coordinates and variable names
function to_symbol(coords::Tuple{Int,Int,Int})
    return Symbol(string("x_", coords[1], "_", coords[2], "_", coords[3]))
end


function to_coords(sym::Symbol)
    return Tuple([parse(Int, num) for num in split(string(sym),"_")[2:end]])
end


function build_sudoku_expr()

    exclusive_groups = Expr[]
    # Build entry-wise exclusive groups (89)
    for row=1:9
        for col=1:9
            vars = [to_symbol((row,col,k)) for k=1:9]
            push!(exclusive_groups, generate_exclusive_group(vars))
        end
    end 

    # Build row-wise exclusive groups (89)
    for row=1:9
        for k=1:9
            vars = [to_symbol((row,col,k)) for col=1:9]
            push!(exclusive_groups, generate_exclusive_group(vars)) 
        end
    end 

    # Build column-wise exclusive groups (89)
    for col=1:9
        for k=1:9
            vars = [to_symbol((row,col,k)) for row=1:9]
            push!(exclusive_groups, generate_exclusive_group(vars)) 
        end
    end 


    # Build sector-wise exclusive groups (89)
    sectors = [1:3, 4:6, 7:9]
    for rs=1:3
        for cs=1:3
            for k=1:9
                vars = [to_symbol((row,col,k)) for row in sectors[rs] for col in sectors[cs]]
                push!(exclusive_groups, generate_exclusive_group(vars))
            end
        end
    end
 
    # Form the conjunct of all exclusive groups
    return big_conjunct(exclusive_groups)
end


function sudoku_variables()
    return [to_symbol((i,j,k)) for i=1:9 for j=1:9 for k=1:9]
end


function build_sudoku_robdd()

    sudoku_expr = build_sudoku_expr()
    sudoku_vars = sudoku_variables()

    my_table = ROBDDTable(sudoku_vars)
    start_idx = build_robdd(my_table, sudoku_expr; memo=LRU{Tuple{Function,Vararg{UInt32}},UInt32}(maxsize=80000000,by=sizeof))

    clean_table, clean_idx = clean_table(my_table, start_idx)

    return clean_table, clean_idx

end



end # module
