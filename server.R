#############################################################################################################################################
# packages
#############################################################################################################################################

library(shiny)
library(leaflet)
library(rgdal)
library(ggplot2)
library(artyfarty)
require(dplyr)
require(data.table)

#############################################################################################################################################
# SERVER
#############################################################################################################################################


shinyServer(
  function(input, output, session){
    
    
    setwd("C:/Users/akruse/Documents/R/CDV/CDV_final/")
    ger_plz <- readOGR(dsn = ".", layer = "gerplz2")
    schools <- read.table("SchulenPLZ.csv", header = T, sep = ";")
    artmus <- read.table("museen_liste2.txt", header = T, sep = ",")
    mydata <- read.table("mydata.csv", header = T, sep = ";")
    
    ####observer is used to maintain the circle size. 
    
    observe({
      #####this connects selectInput and assigns the radius value
      kennzahl_label <- input$kennzahl
      radius <- ger_plz@data[[kennzahl_label]]
      
      # continous colour palette
      pal <- colorNumeric(
        palette = "RdYlGn",
        domain = radius
      )
      
      # load custom icon
      #museumIcon <- makeIcon(
       # iconUrl = "museum_icon.png",
        #iconWidth = 20, iconHeight = 20,
        #popupAnchorX = 0,
        #popupAnchorY = 0
        #iconAnchorX = 22, iconAnchorY = 94,
        #shadowUrl = "http://leafletjs.com/docs/images/leaf-shadow.png",
        #shadowWidth = 50, shadowHeight = 64,
        #shadowAnchorX = 4, shadowAnchorY = 62
      #)
      
      # load custom icon
      #schoolIcon <- makeIcon(
       # iconUrl = "school_icon.png",
        #iconWidth = 20, iconHeight = 20,
        #popupAnchorX = 0,
        #popupAnchorY = 0
        #iconAnchorX = 22, iconAnchorY = 94,
        #shadowUrl = "http://leafletjs.com/docs/images/leaf-shadow.png",
        #shadowWidth = 50, shadowHeight = 64,
        #shadowAnchorX = 4, shadowAnchorY = 62
      #)
      
      # create pop ups
      state_popup <- paste0("<strong>Postleitzahl: </strong>", 
                            ger_plz@data$note, 
                            "<br><strong>Gruppenbuchungen: </strong>", 
                            ger_plz@data$zipcnt,
                            "<br><strong>Schüler: </strong>", 
                            ger_plz@data$stcnt,
                            "<br><strong>Schüler pro Gruppenbuchung: </strong>", 
                            ger_plz@data$zpcnt_s)
      
      # create pop ups
      schule_popup <- paste0("<strong>Schule: </strong>", 
                            schools$Schulname, 
                            "<br><strong>Schüler: </strong>", 
                            schools$Ergebnis)
      
      # create pop ups
      artmus_popup <- paste0("<strong>Museum: </strong>", 
                             artmus$museums_name, 
                             "<br><strong>Gruppenbuchungen: </strong>", 
                             artmus$count)
      
      
      output$ger_plz.map <-  renderLeaflet({
        ger_plz.map <- leaflet(ger_plz) %>% 
          addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
                   attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>')
        ger_plz.map %>% addPolygons(stroke = T, smoothFactor = 0.2, fillOpacity = 0.7, color = "black", weight = 2,
                                    fillColor = ~pal(radius),
                                    popup = state_popup) %>%
          addCircles(lng = schools$longitude, lat = schools$latitude, popup = schule_popup, fillOpacity = 100, fillColor = "#0000CD", stroke = F, radius = 100, group = "locations") %>%
          #addMarkers(lng = schools$longitude, lat = schools$latitude, popup = schools$Schulname,ic, group = "locations") %>%
          #addMarkers(lng = artmus$longitude, lat = artmus$latitude, popup = artmus$museums_name, group = "locations_2", icon = museumIcon)
          addCircles(lng = artmus$longitude, lat = artmus$latitude, popup = artmus_popup, fillOpacity = 100, fillColor = "#000000", stroke = F, radius = 200, group = "locations_2")
        
      
        
      })
      
      output$plzPlot <- renderPlot({
        
        # load data
        mydata <- read.table("mydata.csv", header = T, sep = ";")
        
        # Render a barplot
        check <- filter(mydata, PLZ == paste(input$plz))
        
        check <- check %>% group_by(Schulform) %>% summarise(Buchungen = n())
        ggplot(check, aes(x = Schulform, y = Buchungen)) +
          geom_bar(stat = "identity", aes(fill = Schulform)) +
          theme_monokai_full() +
          ggtitle("") +
          #scale_fill_manual(values = pal("monokai")) +
          theme(axis.text.x = element_text(angle = 90, hjust = 1))
      
      })
      
      
      # display 10 rows initially
      
      check1 <- filter(schools, Schule.PLZ == paste(input$plz))
      check1 <- select(check1, Schulname, Schule.Strasse, Schule.Hausnr, Schule.PLZ, Ergebnis)
      check1$Strasse <- paste(check1$Schule.Strasse,check1$Schule.Hausnr, sep = " ")
      check1 <- select(check1, Schulname, Strasse, Schule.PLZ, Ergebnis)
      colnames(check1) <- c("Schulname","Strasse","PLZ","Schüler")
      
      output$ex1 <- renderTable(
        as.data.table(check1, options = list(pageLength = 25))
      )
      
    })
    
    
    # Use a separate observer to recreate the legend as needed.
    observe({
      #####this connects selectInput and assigns the radius value
      kennzahl_label <- input$kennzahl
      radius <- ger_plz@data[[kennzahl_label]]
      
      # continous colour palette
      pal <- colorNumeric(
        palette = "RdYlGn",
        domain = radius
      )
      proxy <- leafletProxy("ger_plz.map", data = ger_plz)
      
      # Remove any existing legend, and only if the legend is
      # enabled, create a new one.
      proxy %>% clearControls()
      if (input$legend) {
        
        proxy %>% addLegend(position = "bottomright", title = ifelse(input$kennzahl == "stcnt", paste("Schüler"), ifelse(input$kennzahl == "zipcnt", paste("Buchungen"), paste("Schüler pro Gruppenbuchung"))),
                            pal = pal, values = ~radius)
        
        proxy %>% addLegend(
          position = 'topright',
          colors = c("#0000CD","#000000"),
          labels = c("Schulen","Museen"),
          title = '',
          opacity = 100
        )
      }
    })         
    

    
    
  })