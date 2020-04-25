


library(data.table)
library(mapdeck)
library(sf)
library(geojsonsf)
library(rmapshaper)

dt <- data.table::fread("https://raw.githubusercontent.com/maurosc3ner/uspm25_2000_2018/master/data/pm2.5byCounty.csv")
sf <- geojsonsf::geojson_sf( "https://eric.clst.org/assets/wiki/uploads/Stuff/gz_2010_us_050_00_500k.json" )

sf$fips <- paste0(sf$STATE, sf$COUNTY)

## I'm simplifying the polygons so there are fewer vertices to plot
## which will make the map more responsive
## I've excluded the 'NAME' field because it has an invalid char
## I'll put it back on after the simplification
sf2 <- sf[, c("fips", "geometry") ]
geo <- geojsonsf::sf_geojson( sf2 )
attr(geo, "class") <- c("geo_json")
geo <- rmapshaper::ms_simplify( geo, sys = TRUE )
sf2 <- geojsonsf::geojson_sf( geo )

dt <- data.table::melt(data = dt, id.vars = "fips")
dt[, fips := sprintf("%05s", fips) ]
dt[, variable := as.numeric(substr(variable,6,9))]
setnames( dt, "variable","year" )

setDT( sf2 )
dt <- dt[
	sf2
	, on = "fips"
	, nomatch = 0
]

setDT( sf )
sf[, geometry := NULL ]

dt[
	sf
	, on = "fips"
	, county := NAME
]

sf <- sf::st_as_sf( dt )

## because the animation is split by each year, we want the legend and the colours
## to be consistent across the animation, so the colour scale doesn't change.
## therefore we need to make the legend static
colours <- colourvalues::color_values( sf$value, n_summaries = 5 )
sf$colour <- colours$colours

legend <- mapdeck::legend_element(
	variables = colours$summary_values
	, colours = colours$summary_colours
	, colour_type = "fill"
	, variable_type = "gradient"
)

js_legend <- mapdeck::mapdeck_legend(legend)

sf$info <- paste0("county ", sf$county, "<br>", "year ,", sf$year, "<br>","pm: ", sf$value)

## save the objects for the shiny
saveRDS(sf, file = "./shinydashboard/data/sf.rds")
saveRDS(js_legend, file = "./shinydashboard/data/legend.rds")

mapdeck() %>%
	add_polygon(
		data = sf[ sf$year == 2015, ]
		, fill_colour = "colour"
		, legend = js_legend
		, tooltip = "info"
	)




