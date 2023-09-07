options("teal.bs_theme" = bslib::bs_theme(version = 3))

library(teal.slice)
library(teal)
library(teal.modules.general)
ADSL <- teal.modules.general::rADSL
ADAE <- teal.modules.general::rADAE

app <- teal::init(
  data = teal.data::cdisc_data(
    teal.data::cdisc_dataset("ADSL", ADSL, code = "ADSL <- teal.modules.general::rADSL"),
    teal.data::cdisc_dataset("ADAE", ADAE, code = "ADSL <- teal.modules.general::rADAE"),
    check = TRUE
  ),
  modules = teal::modules(
    teal.modules.general::tm_data_table(
      label = "ADS Data Table",
      variables_selected = list(ADSL = c("STUDYID", "USUBJID", "SUBJID", "SITEID", "AGE", "SEX", "COUNTRY")),
      dt_args = list(caption = "ADSL Table Caption")
    ),
    teal.modules.general::tm_missing_data(
      label = "ADS Missing Data",
      ggplot2_args = list(
        "Combinations Hist" = teal.widgets::ggplot2_args(
          labs = list(subtitle = "Plot produced by Missing Data Module", caption = NULL)
        ),
        "Combinations Main" = teal.widgets::ggplot2_args(labs = list(title = NULL))
      )
    )
  ),
  filter = teal_slices(
    teal_slice("ADSL", "COUNTRY", "country", selected = "USA", fixed = TRUE),
    teal_slice("ADSL", "RACE", "race", selected = "ASIAN"),
    teal_slice("ADSL", id = "custom1", title = "Adult Female", expr = "SEX == 'F' & AGE >= 18"),
    teal_slice("ADSL", "ETHNIC", "ethnic", anchored = TRUE),
    module_specific = TRUE,
    mapping = list(
      "ADS Data Table" = c("country", "ethnic"),
      "ADS Missing Data" = c("race"),
      global_filters = "custom1"
    ),
    count_type = "all"
  )
)

shinyApp(app$ui, app$server)
