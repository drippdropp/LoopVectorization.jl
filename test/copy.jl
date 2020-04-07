using LoopVectorization, Test


@testset "copy" begin

    function copyavx1!(x, y)
        @avx for i ∈ eachindex(x)
            x[i] = y[i]
        end
    end
    function copy_avx1!(x, y)
        @_avx for i ∈ eachindex(x)
            x[i] = y[i]
        end
    end
    function copyavx2!(x, y)
        @avx for i ∈ eachindex(x)
            yᵢ = y[i]
            x[i] = yᵢ
        end
    end
    function copy_avx2!(x, y)
        @_avx for i ∈ eachindex(x)
            yᵢ = y[i]
            x[i] = yᵢ
        end
    end
    function offset_copy!(A, B)
        @inbounds for i=1:size(A,1), j=1:size(B,2)
	    A[i,j+2] = B[i,j]
        end
    end
    function offset_copyavx1!(A, B)
        @avx for i=1:size(A,1), j=1:size(B,2)
	    A[i,j+2] = B[i,j]
        end
    end
    function offset_copy_avx1!(A, B)
        @_avx for i=1:size(A,1), j=1:size(B,2)
	    @inbounds A[i,j+2] = B[i,j]
        end
    end
    function offset_copyavx2!(A, B)
        @avx for i=1:size(A,1), j=1:size(B,2)
            Bᵢⱼ = B[i,j]
	    A[i,j+2] = Bᵢⱼ
        end
    end
    function offset_copy_avx2!(A, B)
        @_avx for i=1:size(A,1), j=1:size(B,2)
            Bᵢⱼ = B[i,j]
	    A[i,j+2] = Bᵢⱼ
        end
    end
    function make2point3avx!(x)
        @avx for i ∈ eachindex(x)
            x[i] = 2.3
        end
    end
    function make2point3_avx!(x)
        @_avx for i ∈ eachindex(x)
            x[i] = 2.3
        end
    end
    function make23avx!(x)
        @avx for i ∈ eachindex(x)
            @inbounds x[i] = 23
        end
    end
    function make23_avx!(x)
        @_avx for i ∈ eachindex(x)
            x[i] = 23
        end
    end
    function myfillavx!(x, a)
        @avx for i ∈ eachindex(x)
            x[i] = a
        end
    end
    function myfill_avx!(x, a)
        @_avx for i ∈ eachindex(x)
            x[i] = a
        end
    end
    

    for T ∈ (Float32, Float64, Int32, Int64)
        @show T, @__LINE__
        R = T <: Integer ? (-T(100):T(100)) : T 
        x = rand(R, 237);
        q1 = similar(x); q2 = similar(x);
        
        fill!(q2, -999999); copyavx1!(q2, x);
        @test x == q2
        fill!(q2, -999999); copy_avx1!(q2, x);
        @test x == q2
        fill!(q2, -999999); copyavx2!(q2, x);
        @test x == q2
        fill!(q2, -999999); copy_avx2!(q2, x);
        @test x == q2
        fill!(q2, -999999); @avx q2 .= x;
        @test x == q2

        B = rand(R, 79, 83);
        A1 = zeros(T, 79, 85);
        A2 = zeros(T, 79, 85);
        offset_copy!(A1, B);
        fill!(A2, 0); offset_copyavx1!(A2, B);
        @test A1 == A2
        fill!(A2, 0); offset_copyavx2!(A2, B);
        @test A1 == A2
        fill!(A2, 0); offset_copy_avx1!(A2, B);
        @test A1 == A2
        fill!(A2, 0); offset_copy_avx2!(A2, B);
        @test A1 == A2
        
        a = rand(R)
        myfillavx!(x, a);
        fill!(q2, a);
        @test x == q2
        a = rand(R)
        myfill_avx!(x, a);
        fill!(q2, a);
        @test x == q2
        a = rand(R)
        myfill_avx!(x, a);
        fill!(q2, a);
        @test x == q2
        a = rand(R)
        myfillavx!(x, a);
        fill!(q2, a);
        @test x == q2
        q2 .= 23;
        fill!(q1, -99999); make23_avx!(q1);
        @test q2 == q1
        fill!(q1, -99999); make23avx!(q1);
        @test q2 == q1
        if T <: Union{Float32,Float64}
            make2point3avx!(x)
            fill!(q2, 2.3)
            @test x == q2
            fill!(x, -999999); make2point3_avx!(x)
            @test x == q2
        end
        a = rand(R)
        @avx x .= a;
        fill!(q2, a);
        @test x == q2
        a = rand(R)
        @avx x .= a;
        fill!(q2, a);
        @test x == q2
        
    end
end
