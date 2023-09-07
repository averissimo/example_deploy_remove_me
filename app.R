otions("teal.bs_theme" = bslib::bs_theme(version = 3))
library(teal.slice)
library(teal)
library(scda)

funny_module <- function (label = "Filter states", datanames = "all") {
  checkmate::assert_string(label)
  module(
    label = label,
    datanames = datanames,
    ui = function(id, ...) {
      ns <- NS(id)
      div(
        h2("The following filter calls are generated:"),
        verbatimTextOutput(ns("filter_states")),
        verbatimTextOutput(ns("filter_calls")),
        actionButton(ns("reset"), "reset_to_default")
      )
    },
    server = function(input, output, session, data, filter_panel_api) {
      checkmate::assert_class(data, "tdata")
      observeEvent(input$reset, set_filter_state(filter_panel_api, default_filters))
      output$filter_states <- renderText({
        logger::log_trace("rendering text1")
        stage1 <- filter_panel_api |> get_filter_state()
        stage2 <- lapply(stage1, as.list)
        stage3 <- yaml::as.yaml(stage2)
        stage3
      })
      output$filter_calls <- renderText({
        logger::log_trace("rendering text2")
        attr(data, "code")()
      })
    }
  )
}

Iris <- iris
levels(Iris$Species) #%<>% toupper()
Iris$Species2 <- Iris$Species
Iris$Species3 <- Iris$Species
Iris$Sepal.Length[1] <- NA
Iris$Sepal.Length[2] <- Inf
Iris$Species3[2] <- NA
attr(Iris[[1]], "label") <- "variable label"
attr(Iris[[2]], "label") <- "variable label"
attr(Iris[[3]], "label") <- "variable label"
attr(Iris[[4]], "label") <- "variable label"
data <- teal_data(
  dataset("iris", Iris),
  dataset("mtcars", mtcars)
)

default_filters <- teal_slices(
  teal_slice("iris", "Sepal.Length", fixed = FALSE, anchored = FALSE),
  teal_slice("iris", "Sepal.Width", sel = c(2.5, 4.0), fixed = FALSE, anchored = TRUE),
  teal_slice("iris", "Petal.Length", sel = c(4.5, 5.1), fixed = TRUE, anchored = FALSE),
  teal_slice("iris", "Petal.Width", sel = c(0.3, 1.8), fixed = TRUE, anchored = TRUE),
  count_type = NULL
)

app <- init(
  data = data,
  modules = list(funny_module(), funny_module("module2")), filter = default_filters
)

runApp(app, launch.browser = TRUE)
