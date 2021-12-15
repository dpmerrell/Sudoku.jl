module Sudoku

using ROBDD

export generate_indicator, exclusive_group 


function generate_indicator(vars::Vector{Symbol}, idx::Int)
    
    atom = vars[1]
    if idx == 1
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
        return vars[1]
    end

    # Recursive case
    return Expr(:call, :|, generate_indicator(vars, idx),
                           _rec_exclusive_group(vars, idx+1))
end


function exclusive_group(vars::Vector{Symbol})

    return _rec_exclusive_group(vars,1)
end


end # module