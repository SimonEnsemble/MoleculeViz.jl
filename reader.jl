using CSV
using DataFrames

"""
    atoms, x = read_xyz(filename::AbstractString)

Return the list of `atoms` (Array{AbstractString}) and their Cartesian coordinates 
`x::Array{Float64, 2}` as stored in the .xyz file. `x[:, k]` will return Cartesian
coords of the kth atom.
"""
function read_xyz(filename::AbstractString)
    f = open(filename)
    lines = readlines(f)
    if length(lines) == 0
        return AbstractString[], Float64[]
    end
    n = parse(Int, lines[1]) # get number of atoms
    atoms = AbstractString[]
    x = zeros(Float64, 3, n)
    for i = 1:n
        push!(atoms, split(lines[i + 2])[1])
        for j = 1:3
            x[j, i] = parse(Float64, split(lines[i + 2])[1 + j])
        end
    end
    close(f)
    return atoms, x
end

"""
    atom_colors = read_cpk_colors() # atom_colors["C"] gives Hex color.

Read in CPK color scheme for atoms. Return `atom_colors::Dict{String, Tuple{Int, Int, Int}}` such that
`atom_colors["C"]` gives RGB code for carbon as a tuple, `(144, 144, 144)`.
https://en.wikipedia.org/wiki/CPK_coloring
"""
function read_cpk_colors()
    atom_dict = Dict{AbstractString, Tuple{Int64, Int64, Int64}}()
    df_colors = CSV.read("cpk_atom_colors.csv")
    for row in eachrow(df_colors)
        atom_dict[row[:atom]] = (row[:R], row[:G], row[:B])
    end
    return atom_dict
end

"""
    atomic_radii = read_atomic_radii() # atomic_masses["C"] gives 10.87 

Return `atomic_radii::Dict{AbstractString, Float64}`, where `atom_masses["C"]` gives 
atomic radii of carbon in Angstrom.
"""
function read_atomic_radii()
    atomic_radii = Dict{AbstractString, Float64}()
    df_props = CSV.read("atom_properties.csv", nullable=true)
    for row in eachrow(df_props)
        if ! ismissing(row[Symbol("atomicradius[Angstrom]")])
            atomic_radii[row[:atom]] = row[Symbol("atomicradius[Angstrom]")]
        end
    end
    return atomic_radii
end

# dictionaries
atom_colors_dict = read_cpk_colors()
atom_radii_dict = read_atomic_radii()

# atoms[i] gives element
# x[:, i] gives Cartesian coordinate of element i
# atom_colors[i] gives colors of atom i
# atom_radii[i] gives radius of atom i
atoms, x = read_xyz("SBMOF1.xyz")
atom_colors = [atom_colors_dict[atoms[i]] for i = 1:length(atoms)]
atom_radii = [atom_radii_dict[atoms[i]] for i = 1:length(atoms)]
