### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 8accd050-17b5-11eb-380a-e35a46533ab0
begin
	#import packages in julia
	using Plots
	using CSV
	using Statistics
end

# ╔═╡ dd880350-17b5-11eb-2781-47d55edf9234
#Load our data in to a variable
data = CSV.read("ckd.csv");

# ╔═╡ 0d821e10-17b6-11eb-2e23-49bf0642e381
#make a vector standardize function 
function stanard_units(x)
    """
    Convert an array of numbers into standard units 
   
    Args:
        x ([array]):    input of an array from a dataframe to convert units
    
    Output:
                        transformed data values
    """
    array = []
    for i = 1:length(x)
        a = (x[i] - mean(x))/std(x)
        append!(array,a)
        end 
    return array
    end 

# ╔═╡ 133b1d1e-17b6-11eb-0f53-d1d0b4c58dda
begin
	# Here, we select our columns that we will use for the model. the selected data will go into the standardize function that we created
	Hemoglobin = stanard_units(data.Hemoglobin)
	Glucose = stanard_units(data."Blood Glucose Random")
	WhiteBB = stanard_units(data."White Blood Cell Count")
	Class = data.Class;
end

# ╔═╡ 29bc11d0-17b6-11eb-1f58-7714b2cbe02b
begin
	#Splitting up our data to select a mixture of data for input in our model
	x_data = [x for x in zip(Hemoglobin[1:43], Glucose[1:43], WhiteBB[1:43])]
	for i in 81:110
	    push!(x_data, (Hemoglobin[i], Glucose[i], WhiteBB[i]))
	    end 
	y_data = Class[1:43]
	for i = 44:73
	    push!(y_data, 0)
	    end 
end

# ╔═╡ 350a3440-17b6-11eb-23a6-b592f77e56d8
begin
	#We can plot the selected data into a 3D scatter plot here with classifications
	theme(:ggplot2)
	scatter(xaxis = "Hemoglobin",
	        yaxis = "Glucose", 
	        zaxis = "White Blood Count",
	        title = "CKD Scatter Plot data")
	
	scatter!(x_data[1:44], 
	        label = "CKD Present", 
	        color = "salmon")
	
	scatter!(x_data[44:73], 
	        label = "No CKD Present", 
	        color = "lightBlue")
	
end

# ╔═╡ 742d61b0-17b6-11eb-23c9-2f7da5564be2
begin
	#Create a distance function and create a KNN algorithm
	function distance(p1, p2)
	    """
	    Input of 2 points and their locations to find the distance between the points using the distance formula. We can apply this function to n size data points. 
	   
	    Args:
	        p1 ([tuple]):    input of a tuple and the values of location of the points in n size
	        p2 ([tuple]):    input of a tuple and the values of location of the points in n size
	    
	    Output:
	                        distances between two points 
	    """
	    return sqrt(sum([(p1[i] - p2[i])^2 for i = 1:length(p1)]))
	end
	
	function KNN(target, feature_array, label_array, k)
	    """
	    Using distance formula to apply the K-Nearest-neighbors and output the k amount of closest points
	   
	    Args:
	        target ([Array (tuple)]):    input of the array of the targeted point from our x data 
	        feature_array ([tuple]):     input of a tuple of the data that we will be finding distances of 
	        Label_array ([tuple]):       input of a tuple that has the correct classification of our data 
	        k ([int]):                   input of the k - nearest neighbors amount that we want return 
	    
	    Output:
	                        distances between two points 
	    """
	    distance_array = [(feature_array[i], label_array[i], distance(target, feature_array[i]))
	                        for i = 1:length(feature_array)
	                        if target != feature_array[i]]
	    sort!(distance_array, by = x -> x[3])
	    
	    return distance_array[1:k]
	end
end

# ╔═╡ a02729e2-17b6-11eb-1272-ebf9732eae7c
#function to create a point that we are able to test
test_point(i) = (Hemoglobin[i], Glucose[i],WhiteBB[i])

# ╔═╡ 909458e0-17b6-11eb-0fef-f31586a63514
function show_neighbors(i,k)
    """
    Display details of KNN function, including Distance and labels. This will also provide a plot with the targeted points and the k nearest connecting points
   
    Args:
        i ([int]):    the point that we would like to find the nearest points to
        k ([int]):    input of the k - nearest neighbors amount that we want return 
    
    Output:
                        Details of KNN and plot
    """

    println("")
    println("Taret Point P = ", test_point(i))
    println("Target Label = ", Class[i])
    println("k = ", k)
    println("____________________________________________________________________________")
    test = KNN(test_point(i), x_data, y_data, k)
    for i = 1:k
        println("Point $i = ", test[i][1])
        println("Point Label =", test[i][2])
        println("Distance =", test[i][3])
        println("")
    end

    println("____________________________________________________________________________")
    println("")
    
    scatter(xaxis = "Hemoglobin",
            yaxis = "Glucose", 
            zaxis = "White Blood Count",
            title = "CKD Scatter Plot data")

    scatter(xaxis = "Hemoglobin",
            yaxis = "Glucose", 
            zaxis = "White Blood Count",
            title = "CKD Scatter Plot data")

    scatter!(x_data[1:44], 
            label = "CKD Present", 
            color = "salmon")

    scatter!(x_data[44:73], 
            label = "No CKD Present", 
            color = "lightBlue")
    scatter!([test_point(i)], 
            label = "test point",
            color = "red")

    for j in 1:length(test)
        plot!([test_point(i), test[j][1]],
                label = false,
                color = "red")
       end 
    scatter!()
end



# ╔═╡ b129b780-17b6-11eb-33b8-ebd627e616ae
a = @bind a html"<input type=range>"

# ╔═╡ 978f4dd0-17b6-11eb-2ab1-11253da64e39
show_neighbors(50, a)

# ╔═╡ e75fbcf0-17b6-11eb-0612-6f55487cb844
a

# ╔═╡ fba67910-17b6-11eb-170e-334ada28ce94
function predict(i, feature_array, label_array, k)
    """
    Using the last function, we print out the predicted classification of the given point
   
    Args:
        target ([Array (tuple)]):    input of the array of the targeted point from our x data 
        feature_array ([tuple]):     input of a tuple of the data that we will be finding distances of 
        Label_array ([tuple]):       input of a tuple that has the correct classification of our data 
        k ([int]):                   input of the k - nearest neighbors amount that we want return 
    
    
    Output:
                        Predicted class for the given point
    
    """
    point = test_point(i)
    KNN_array = KNN(point, feature_array, label_array, k)
    Present = sum([1 for x in KNN_array if x[2] == 1])
    NotPresent = sum([1 for x in KNN_array if x[2] == 0])
    count_array = [(1, Present), (0, NotPresent)]
    
    sort!(count_array, by = x -> x[2])
    return count_array[end][1]
end

# ╔═╡ fb866df0-17b6-11eb-189a-b543687480db
predict(33, x_data, y_data, a)

# ╔═╡ 0239f9a0-17b7-11eb-384b-85b526cdbf12
function K_value(x_data, y_data, s)
    error_measures = []
    k = []
    for j = 1:s
        wrong = 0
        error_rate = 0
        for i =1:length(x_data)
            if predict(i, x_data, y_data, j) != y_data[i]
                wrong += 1
                end 
            error_rate = wrong/length(x_data)

            end 
        push!(error_measures, error_rate)
        push!(k, j)
        end 
    scatter(k, error_measures, 
        title = "Error rate vs K Value ", 
        xaxis = "K",
        yaxis = "Error rate",
        color = "red", 
        label = false)
    plot!(k, error_measures, 
        color = "blue", 
        linestyle = :dash, 
        label = false)
end

# ╔═╡ 237e0ed0-17b7-11eb-024b-634d5a97fdba
#below is finding the error rate of k at point 14 in out data set.
K_value(x_data, y_data, a)

# ╔═╡ 27e316a0-17b7-11eb-2519-5f699b3c0669


# ╔═╡ Cell order:
# ╠═8accd050-17b5-11eb-380a-e35a46533ab0
# ╠═dd880350-17b5-11eb-2781-47d55edf9234
# ╟─0d821e10-17b6-11eb-2e23-49bf0642e381
# ╟─133b1d1e-17b6-11eb-0f53-d1d0b4c58dda
# ╟─29bc11d0-17b6-11eb-1f58-7714b2cbe02b
# ╟─350a3440-17b6-11eb-23a6-b592f77e56d8
# ╟─742d61b0-17b6-11eb-23c9-2f7da5564be2
# ╠═a02729e2-17b6-11eb-1272-ebf9732eae7c
# ╟─909458e0-17b6-11eb-0fef-f31586a63514
# ╠═978f4dd0-17b6-11eb-2ab1-11253da64e39
# ╠═b129b780-17b6-11eb-33b8-ebd627e616ae
# ╠═e75fbcf0-17b6-11eb-0612-6f55487cb844
# ╟─fba67910-17b6-11eb-170e-334ada28ce94
# ╠═fb866df0-17b6-11eb-189a-b543687480db
# ╟─0239f9a0-17b7-11eb-384b-85b526cdbf12
# ╠═237e0ed0-17b7-11eb-024b-634d5a97fdba
# ╠═27e316a0-17b7-11eb-2519-5f699b3c0669
