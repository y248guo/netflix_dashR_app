# Modifed based on given demo from class
# Source: https://github.com/UBC-MDS/dashr-heroku-deployment-demo


library(dash)
#library(dashCoreComponents)
library(dashHtmlComponents)
#library(dashBootstrapComponents)
library(ggplot2)
library(plotly)

app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

df <- readr::read_csv(here::here('data', 'processed', 'netflix_movies_genres.csv'))

app$layout(
  dbcContainer(
    dbcRow(
      list(
        dbcCol(
          list(
            dccDropdown(
              id = 'dropdown',
              options = df$genre %>% 
                unique %>% 
                purrr::map(function(col) list(label = col, value = col)),
              clearable = F,
              value = list('Comedies')),
            dashDataTable(
              id = "table",
              style_cell = list(
                overflow = 'hidden',
                textOverflow = 'ellipsis',
                maxWidth = 0
              ),
              page_size = 10)
          )
        )
      )
    ), style = list('max-width' = '85%')  # Change left/right whitespace for the container
  )
)

# Set up callbacks/backend
app$callback(
  list(output('table', 'data'),
       output('table', 'columns'),
       output('table', 'tooltip_data')),
  list(input('dropdown', 'value')),
  function(genre) {
    data <- df[df$genre == genre, ]
    cols <- c("title", "description", "director")
    data <- data[, cols]
    data <- data[order(data$title),]
    columns <- cols %>%
      purrr::map(function(col) list(name = col, id = col))
    tooltip_data <- apply(data, 1, function(x) purrr::map(x, function(row) list(label = row, value = row)))
    
    list(data, columns, tooltip_data)
  }
)
app$run_server(host = '0.0.0.0')