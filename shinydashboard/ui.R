library(shiny)
library(shinydashboard)

ui <- dashboardPage(
    dashboardHeader(
      disable = TRUE
    )
    , dashboardSidebar(
      width = 150
      , tags$a(href='symbolix.com.au',
             tags$img(src='SymbolixLogo.png')
             )
    )
    , dashboardBody(
        tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css"))

        , mapdeck::mapdeckOutput(
          outputId = "map"
          , height = "600"
        )
        , uiOutput(
          outputId = "ui_year"
        )
        , p("adaptation of maurosc3ner's work - https://github.com/maurosc3ner/uspm25_2000_2018")
      )
)
