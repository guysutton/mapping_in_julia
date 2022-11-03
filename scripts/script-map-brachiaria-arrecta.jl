# Plot map with GPS points using AlgebraOfGraphics.jl and Makie.jl

######################################
# Session setup
###################################### 

# Setup using DrWatson
using Pkg, DrWatson
@quickactivate "mapping_in_julia" 

# Install required packages 
Pkg.add(["AlgebraOfGraphics", "CairoMakie", "DataFrames", "Shapefile"])

# Load required packages 
using Shapefile, GBIF, CairoMakie, DataFrames, AlgebraOfGraphics

######################################
# Download GBIF occurrences
###################################### 

# Download occurences data from GBIF - 
# - Can use bounding box to only extract data from the native range of Brachiaria arrecta (Africa)
lat, lon = (-35, 10), (0, 45)
observations = GBIF.occurrences(
    GBIF.taxon("Brachiaria arrecta"; strict = false),
    "hasCoordinate" => "true",
    "decimalLatitude" => lat,
    "decimalLongitude" => lon,
    "limit" => 300,
)

# Loop through all of the occurrences available in GBIF, not just n = 300 limit from above 
while length(observations) < size(observations)
    occurrences!(observations)
end
@info observations

# Convert GBIF observations to Dataframe object
df = DataFrames.DataFrame(observations)

######################################
# Load shapefiles - Africa 
###################################### 

# Import the .shp file using Shapefile.jl
# Downloaded from: https://geoportal.icpac.net/layers/geonode%3Aafr_g2014_2013_0
table = Shapefile.Table("./shapefiles/afr_g2014_2013_0.shp")

######################################
# Make map
###################################### 

# Set map theme for AlgebraOfGraphics.jl
set_aog_theme!() 
update_theme!(   
    Axis = (
        topspinevisible = true, 
        rightspinevisible = true,
        bottomspinecolor = :black,
        leftspinecolor = :black,
        xtickcolor =:black,
        ytickcolor =:black
       )
)
# Plot map 

# Step 1: Create a raster layer with the African shapefile (.shp)
layer_map = geodata(table) * 
        mapping(
            :geometry
            ) * 
        visual(
            Poly,
            strokecolor = :black,
            strokewidth = 1,
            linestyle = :solid,
            color = "white"
            )      

# Step 2: Create a layer with points for the GPS data 
layer_gps = data(df) * 
        mapping(  
            :longitude,
            :latitude,
            # Changes the legend name 
            color = :name => "Species"
        ) * 
        visual(
            Scatter,
            marker = :circle,
            markersize = 12.5,
        )    

# Step 3: Combine layers to make map 
map = draw(
    layer_map + layer_gps, 
    axis = (
        limits = ((-20, 55), (-38, 40)),
        xticks = -20:10:55,
        yticks = -38:10:40,
        aspect = 1, 
        xlabel = "Longitude",
        ylabel = "Latitude", 
    ),
    figure = (
        resolution = (750, 750),
    ), 
    legend = (position = :top, titleposition = :left, ),
)

# Save high quality figure 
save("./figures/figure_brachiaria_arrecta.png", px_per_unit = 6, map)














######################################
# Load shapefiles - South Africa 
###################################### 

# Import RSA shapefile 
# table = Shapefile.Table("C:/Users/s1900332/Desktop/shapefiles/zaf_adm_sadb_ocha_20201109_SHP/zaf_admbnda_adm0_sadb_ocha_20201109.shp")
table = Shapefile.Table("C:/Users/s1900332/Desktop/shapefiles/zaf_adm_sadb_ocha_20201109_SHP/PR_SA_2011.shp")


######################################
# Plot
###################################### 

# Set map theme
set_aog_theme!() 
update_theme!(   
    Axis = (
        topspinevisible = true, 
        rightspinevisible = true,
        bottomspinecolor = :black,
        leftspinecolor = :black,
        xtickcolor =:black,
        ytickcolor =:black
       )
)

# Plot map 
layer_map = geodata(table) * 
        mapping(
            :geometry
            ) * 
        visual(
            Poly,
            strokecolor = :black,
            strokewidth = 1,
            linestyle = :solid,
            color = "white"
            )      
layer_gps = data(df) * 
        mapping(  
            :longitude,
            :latitude
        ) * 
        visual(
            Scatter
        )    
draw(layer_map + layer_gps; 
    axis = (
        aspect = 1, 
        xlabel = "Longitude",
        ylabel = "Latitude"
    ),
    figure = (resolution = (750, 750),)
)
save("figure_brachiaria_arrecta_RSA.png", px_per_unit = 6, map)





######################################
# Load shapefiles - Africa 
###################################### 

# Import RSA shapefile 
# table = Shapefile.Table("C:/Users/s1900332/Desktop/shapefiles/zaf_adm_sadb_ocha_20201109_SHP/zaf_admbnda_adm0_sadb_ocha_20201109.shp")
table = Shapefile.Table("C:/Users/s1900332/Desktop/shapefiles/zaf_adm_sadb_ocha_20201109_SHP/afr_g2014_2013_0.shp")


######################################
# Plot
###################################### 

# Set map theme
set_aog_theme!() 
update_theme!(   
    Axis = (
        topspinevisible = true, 
        rightspinevisible = true,
        bottomspinecolor = :black,
        leftspinecolor = :black,
        xtickcolor =:black,
        ytickcolor =:black
       )
)

# Set all points labelled as Eragrostis curvula to black colour
colors = ["Eragrostis curvula" => colorant"#000000"]

# Plot map 
layer_map = geodata(table) * 
        mapping(
            :geometry
            ) * 
        visual(
            Poly,
            strokecolor = :black,
            strokewidth = 1,
            linestyle = :solid,
            color = "white"
            )      
layer_gps = data(df) * 
        mapping(  
            :longitude,
            :latitude,
            color = :name => "Species"
        ) * 
        visual(
            Scatter,
            marker = :circle,
            markersize = 12.5,
        )    
map = draw(
    layer_map + layer_gps, 
    axis = (
        limits = ((-20, 55), (-38, 40)),
        xticks = -20:10:55,
        yticks = -38:10:40,
        aspect = 1, 
        xlabel = "Longitude",
        ylabel = "Latitude", 
    ),
    figure = (
        resolution = (750, 750),
    ), 
    legend = (position = :top, titleposition = :left, ), 
    # palettes = (color = colors, )
)

# Save high quality figure 
save("figure_brachiaria_arrecta.png", px_per_unit = 6, map)

# Save GPS data as .csv 
CSV.write("./brachiara_arrecta_gbif_gps.csv", df)