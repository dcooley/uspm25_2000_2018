library(mapdeck)
library(sf)

set_token( read.dcf(".mapbox", fields = "MAPBOX") )


server <- function(input, output, session) {

	sf <- readRDS("./data/sf.rds")
  js_legend <- readRDS("./data/legend.rds")

  min_year <- min( sf$year )
  max_year <- max( sf$year )

	output$ui_year <- renderUI({
		sliderInput(
			inputId = "year"
			, label = "Year"
			, min = min_year
			, max = max_year
			, value = min_year
			, step = 1
			, animate = animationOptions(interval = 1000, loop = TRUE)
		)
	})

	output$map <- mapdeck::renderMapdeck({
		mapdeck(
			style = mapdeck_style("dark")
		) %>%
			add_polygon(
				data = sf[ sf$year == min_year , ]
				, fill_colour = "colour"
				, legend = js_legend
				, tooltip = "info"
			)
	})

	observeEvent({input$year},{
		y <- input$year
		mapdeck::mapdeck_update(
			map_id = "map"
			) %>%
			add_polygon(
				data = sf[ sf$year == y, ]
				, fill_colour = "colour"
				, legend = js_legend
				, tooltip = "info"
				, update_view = FALSE
				, transitions = list(fill_colour = 1000)
			) %>%
			add_title(
				title = paste0("year ", y)
			)
	})

}
