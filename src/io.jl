


function read_sudoku_str(table_str::AbstractString; N=9)

    table = zeros(UInt8, N, N)
    
    i,j = 1,1

    for ch in table_str

        if isnumeric(ch)
            table[i,j] = parse(UInt8, ch)
        elseif ch != '_'
            continue
        end

        if j == N
            j = 1
            i += 1
        else
            j += 1
        end
    end

    return table
end


function read_sudoku_file(filename)

    lines = open(filename, "r") do f
        readlines(f)
    end

    table = read_sudoku_str(join(lines, "\n"))

    return table
end


function table_to_str(table::Matrix{UInt8})

    s = ""
    M,N = size(table)
    M_sqrt = Int(sqrt(M))
    N_sqrt = Int(sqrt(N))

    for i=1:M
        for j=1:N
            s *= string(Integer(table[i,j]))
            if j < N
                if mod(j, N_sqrt) == 0
                    s *= "|"
                else
                    s *= " "
                end
            end
        end

        if i < M
            if mod(i, M_sqrt) == 0
                s *= "\n"
                s *= ("_"^(2*N -1))
            end 
            s *= "\n"
        end
    end

    return s
end


