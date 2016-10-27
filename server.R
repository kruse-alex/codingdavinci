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
    
    #setwd("C:/Users/akruse/Documents/R/CDV/CDV/")
    ger_plz <- readOGR(dsn = ".", layer = "gerplz3")
    schools <- read.table("SchulenPLZfull2.csv", header = T, sep = ";")
    schools2 <- read.table("SchulenPLZfull3.csv", header = T, sep = ";")
    artmus <- read.table("museen_liste2.txt", header = T, sep = ",")
    mydata <- read.table("mydatafull.csv", header = T, sep = ";")
    
    observe({
      kennzahl_label <- input$kennzahl
      radius <- ger_plz@data[[kennzahl_label]]
      
      # continous colour palette
      pal <- colorNumeric(
        palette = "RdYlGn",
        domain = radius
      )
      
      # create pop ups
      state_popup <- paste0("<strong>Postleitzahl: </strong>", 
                            ger_plz@data$note, 
                            "<br><strong>Musuemsausflüge: </strong>", 
                            ger_plz@data$zipcnt,
                            "<br><strong>Schüler: </strong>", 
                            ger_plz@data$stcnt,
                            "<br><strong>Museumsausflüge/Schüler: </strong>", 
                            ger_plz@data$zpcnt_s)
      
      # create pop ups
      schule_popup <- paste0("<strong>Schüler: </strong>", 
                            schools2$Schueler,
                            "<br><strong>Grundschulen: </strong>", 
                            schools2$gru,
                            "<br><strong>Stadtteilschulen: </strong>", 
                            schools2$std,
                            "<br><strong>Sonderschulen: </strong>", 
                            schools2$son,
                            "<br><strong>Gymnasien: </strong>", 
                            schools2$gym)
                   
      # create pop ups
      artmus_popup <- paste0("<strong>Museum: </strong>", 
                             artmus$museums_name, 
                             "<br><strong>Musuemsausflüge: </strong>", 
                             artmus$count)
      
      
      output$ger_plz.map <-  renderLeaflet({
        ger_plz.map <- leaflet(ger_plz) %>% 
          addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
                   attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>')
        ger_plz.map %>% addPolygons(stroke = T, smoothFactor = 0.2, fillOpacity = 0.7, color = "black", weight = 2,
                                    fillColor = ~pal(radius),
                                    popup = state_popup) %>%
          addCircles(lng = artmus$longitude, lat = artmus$latitude, popup = artmus_popup, fillOpacity = 100, fillColor = "#000000", stroke = F, radius = 170, group = "locations_2") %>%
          addCircles(lng = schools2$longitude, lat = schools2$latitude, popup = schule_popup, fillOpacity = 100, fillColor = "#0000CD", stroke = F, radius = 100, group = "locations")
        
      })
      
      output$plzPlot <- renderPlot({
        
        # load data
        mydata <- read.table("mydatafull.csv", header = T, sep = ";")
        
        # Render a barplot
        empty <- mydata %>% group_by(Schulform) %>% summarise(Buchungen = n())
        empty$Buchungen[empty$Buchungen > 0] <- 0
        
        check <- filter(mydata, PLZ == paste(input$plz))
        check <- check %>% group_by(Schulform) %>% summarise(Buchungen = n())
        
        check <- rbind(empty,check)
        check <- check %>% group_by(Schulform) %>% summarise(Buchungen = sum(Buchungen))
        
        ggplot(check, aes(x = Schulform, y = Buchungen)) +
          geom_bar(stat = "identity", aes(fill = Schulform)) +
          theme_monokai_full() +
          ggtitle("Museumsausflüge pro Schulform") +
          theme(legend.position="none")
      
      })
      
      output$schulPlot <- renderPlot({
        
        # Render a barplot
        empty <- schools %>% group_by(Schulform) %>% summarise(Schueler = sum(Schueler))
        empty$Schueler[empty$Schueler > 0] <- 0
        
        check1 <- filter(schools, Schule.PLZ == paste(input$plz))
        check1 <- check1 %>% group_by(Schulform) %>% summarise(Schueler = sum(Schueler))
        
        check1 <- rbind(empty,check1)
        check1 <- check1 %>% group_by(Schulform) %>% summarise(Schueler = sum(Schueler))
        
        ggplot(check1, aes(x = Schulform, y = Schueler)) +
          geom_bar(stat = "identity", aes(fill = Schulform)) +
          theme_monokai_full() +
          ggtitle("Schüler pro Schulform") +
          theme(legend.position="none")
        
      })
      
      check1 <- filter(schools, Schule.PLZ == paste(input$plz))
      check1 <- select(check1, Schulname, Schulform, Schule.PLZ, Schueler)
      colnames(check1) <- c("Schule","Schulform","PLZ","Schüler")
      
      output$ex1 <- renderTable(
        as.data.table(check1, options = list(pageLength = 25))
      )

    })
    
    
    # Use a separate observer to recreate the legend as needed.
    observe({
      kennzahl_label <- input$kennzahl
      radius <- ger_plz@data[[kennzahl_label]]
      
      
      
      proxy <- leafletProxy("ger_plz.map", data = ger_plz)
      
      # legend
      proxy %>% clearControls()
      if (input$legende) {
        
        # continous colour palette
        pal <- colorNumeric(
          palette = "RdYlGn",
          domain = radius
        )
        
        proxy %>% addLegend(position = "bottomright", title = ifelse(input$kennzahl == "stcnt", paste("Schüler"), ifelse(input$kennzahl == "zipcnt", paste("Musuemsausflüge"), paste("Musuemsausflüge/Schüler"))),
                            pal = pal, values = ~radius)
        
        proxy %>% addLegend(position = 'topright',colors = c("#0000CD","#000000"),labels = c("Schulen","Museen"),title = '',opacity = 100)
        
      }
    })         

  })
