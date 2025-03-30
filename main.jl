using ImageView
# Quick and dirty, don't judge


# Build the x
s = zeros(Bool, 17, 17)
for i = 5:size(s, 1)-4
	s[i, i] = true
	s[i, size(s, 1)-i+1] = true
	for j in CartesianIndices((3, 3))
		k = CartesianIndex(i, i) + j - 2 * one(CartesianIndex{2})
		if checkbounds(Bool, s, k)
			s[k] = true
		end
		k = CartesianIndex(i, size(s, 1)-i+1) + j - 2 * one(CartesianIndex{2})
		if checkbounds(Bool, s, k)
			s[k] = true
		end
	end
end
s = repeat(s, inner=(2, 1))
imshow(s)


# Function to swap the tiles
function swap(a, b)
	c = zeros(size(a))
	c[size(a, 1)÷2+1:end, :] = a[size(a, 1)÷2+1:end, :]
	c[1:size(a, 1)÷2, 1:size(a, 2)-b] = a[1:size(a, 1)÷2, end-size(a, 2)+b+1:end]
	c[1:size(a, 1)÷2, end-b+1:end] = a[1:size(a, 1)÷2, 1:b]
	c[1:size(a, 1)÷2, end] .= 0
	c[1:size(a, 1)÷2, size(a, 2)-b] .= 1
	return c
end


# Calculate coordinates of objects on the tiles after swapping
function get_upper_coord(x, bigleft)
	if bigleft
		if x < b
			x += bb
		else
			x -= b
		end
	else
		if x < bb
			x += b
		else
			x -= bb
		end
	end
	return x
end


# Generate locations of xs
# Gut feeling says this can be improved, top and bottom contain practically the same values
function advance(top, bottom, xtop, xbottom)
	xtop, xbottom = get_upper_coord(xbottom, false), get_upper_coord(xtop, true)
	push!(bottom, xbottom)
	push!(top, xtop)
	xtop, xbottom = xbottom, xtop
	push!(bottom, xbottom)
	push!(top, xtop)
	return xtop, xbottom
end


# Draw x into array 
function stamp!(a::AbstractArray{<: Number, N}, mask::AbstractArray{Bool, N}, position::NTuple{N, Real}) where N
	position = position .- (size(mask) .÷ 2)
	for i in CartesianIndices(mask)
		j = CartesianIndex{N}(floor.(Int, Tuple(i) .+ position))
		!checkbounds(Bool, a, j) && continue
		a[j] = a[j] == 1 || mask[i]
	end
	return a
end


# Calculate locations of xs
top = []
bottom = []
xbottom = 24
xtop = 24
push!(bottom, xbottom)
push!(top, xtop)
offset = -1
a = zeros(128, 500)
g = 1/1.61 # Is the golden ratio needed here?
b = floor(Int, g * size(a, 2))
bb = size(a, 2) - b
for i = 1:6
	xtop, xbottom = advance(top, bottom, xtop, xbottom)
end

# Draw into array a
for i in 1:length(top)
	offset += 1
	j = isodd(i)
	@views stamp!(a, s, (size(a, 1) ÷ 2 + (2 * j - 1) * offset, top[i]))
end
a[1:size(a, 1)÷2, b] .= 1
a[size(a, 1)÷2, :] .= 1
imshow(-1 * a .+ eps()) # eps() because of "bug" in ImageView
c = swap(a, b)
c[size(a, 1)÷2, :] .= 1
imshow(-1 * c .+ eps())

