
using Test, Sudoku

Su = Sudoku


function run_io_tests()

    @testset "IO" begin

        table_str = """1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                       1 _ 2 3 _ 4 _ 5 _
                    """
       test_table = zeros(UInt8, 9, 9)
       for i=1:9
           test_table[i,[1,3,4,6,8]] .= [1,2,3,4,5]
       end

       table = Su.read_sudoku_str(table_str)
       @test table == test_table 

       @test Su.read_sudoku_file("test_file.txt") == test_table
    end
end

function tree_search_tests()

    @testset "Tree Search" begin

        test_table_str = """6 5 _ _ _ 7 9 _ 3
                            _ _ 2 1 _ _ 6 _ _
                            9 _ _ _ 6 3 _ _ 4
                            1 2 9 _ _ _ _ _ _ 
                            3 _ 4 9 _ 8 1 _ _ 
                            _ _ _ 3 _ _ 4 7 9
                            _ _ 6 _ 8 _ 3 _ 5
                            7 4 _ 5 _ _ _ _ 1
                            5 8 1 4 _ _ _ 2 6
                         """
        table = Su.read_sudoku_str(test_table_str)

        @test Su.is_valid_table(table) == true

        solutions = Su.solve_tree_search(table)
        sol_str = Su.table_to_str(solutions[1])

        print(sol_str)
        println("\n")
        
        test_table_str_2 = """_ _ _ _ _ _ _ _ 3
                              _ _ 8 7 _ _ _ _ _
                              _ 6 _ _ 4 _ 2 9 _ 
                              _ 9 _ _ 2 _ 5 4 _
                              _ _ _ _ _ _ _ 1 _
                              6 _ _ _ _ 9 _ _ _ 
                              _ 5 _ _ _ _ _ _ 1
                              7 _ _ 4 _ _ 3 5 _
                              _ _ _ _ 3 _ _ _ 6
                           """
        table = Su.read_sudoku_str(test_table_str_2)
        solutions = Su.solve_tree_search(table)
        sol_str = Su.table_to_str(solutions[1])

        print(sol_str)
        println()

    end

end


function main()
    run_io_tests()
    tree_search_tests()

end

main()


