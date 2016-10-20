#############################################################################################################################################
# packages
#############################################################################################################################################

library(shiny)
library(leaflet)
library(rgdal)
require(shinythemes)

#############################################################################################################################################
# UI
#############################################################################################################################################

vars <- c(
  "Schüler" = "stcnt",
  "Gruppenbuchungen" = "zipcnt",
  "Schüler pro Gruppenbuchung" = "zpcnt_s")

setwd("C:/Users/akruse/Documents/R/CDV/CDV_final/")
mydata <- read.table("mydata.csv", header = T, sep = ";")

shinyUI(
  bootstrapPage(theme = shinytheme("flatly"),div(class="outer",includeCSS("style.css"),
                    

  navbarPage(title="Hamburger Schüler im Museum", inverse = T,
             
             tabPanel("Karte",
                      sidebarLayout( 
  mainPanel(leafletOutput("ger_plz.map", height = "750")),
  
  sidebarPanel(h3("Was geht hier App?"),
               p("Moinsen! Diese App zeigt an, wie häufig die Schüler aus den verschiedenen Stadteilen einen Schulausflug in die hamburger Museen gemacht haben. Folgende Funktionen hat diese interaktive Karte:"),
               
               HTML("<ul><li>Die Karte kann die Anzahl der Schüler oder die Anzahl der Gruppenbuchungen pro Postleitzahl anzeigen. Darüber hinaus kann man sich das Verhältnis (Schüler pro Gruppenbuchung) anzeigen lassen.</li><li>Klickt man auf einen Stadtteil erhält man alle Informationen im Überblick. Man kann jederzeit weiter herein oder heraus zoomen.</li><li>Weiterhin zeigen die blauen Kreise die Schulen und die schwarzen Kreise die Museen an. Klickt man auf diese erhält man Informationen zu den Objekten.</li></ul>"),
               HTML("<strong>Ein Bespiel:</strong> In 20355 Hamburg (im Zentrum von Hamburg) gibt es zwar viele Schüler, aber vergleichsweise wenige Gruppenbuchungen (Tipp: Klicke auf Schüler pro Gruppenbuchung), obwohl die Schulen in 20355 sogar nahe an den Museen liegen :("),
               br(),
               br(),
               p("Viel Spaß mit der App!"),
               br(),
    
    
               #selectInput("kennzahl", "Kennzahl", vars, selected = "zipcnt"),
               radioButtons("kennzahl", "Was soll auf der Karte angezeigt werden?", vars),
               checkboxInput("legend", "Legenden", TRUE), 
               width = 3
  ), position = "right"
  )
),

tabPanel("Daten", 
         # Use a fluid Bootstrap layout
         fluidPage(    
           
           # Give the page a title
           titlePanel(""),
           
           # Generate a row with a sidebar
           sidebarLayout(      
             
             # Define the sidebar with one input
             sidebarPanel(h3("Und was geht in deiner Hood so?"),
               selectInput("plz", "Postleitzahl:", 
                           choices=unique(mydata$PLZ)),
               hr(),
               helpText("Die Gruppenbuchungen pro Schule können leider nicht angegeben werden, weil diese nur auf Postleitzahlen-Ebene erfasst werden."),
               br(),
               tableOutput('ex1'),width = 4
             ),
             
             # Create a spot for the barplot
             mainPanel(
               plotOutput("plzPlot")
             )
             
           )
         )),
tabPanel("About",sidebarPanel(
  HTML('
              

<p style="text-align:justify"><strong>Allgemeines:</strong> Diese Web-App wurde mit 
<a href="http://shiny.rstudio.com/", target="_blank">Shiny</a> im Rahmen des 
<a href="https://codingdavinci.de", target="_blank">Coding Da Vinci</a> Kultur-Hackathons gebaut. 

<p style="text-align:justify"><strong>Code:</strong> Den Code für die Shiny-App findet man
              <a href="https://github.com/kruse-alex", target="_blank">hier</a>.
              
              <p style="text-align:justify"><strong>Daten:</strong> Die Buchungsdaten der Museen in Hamburg wurde im Rahmen von Coding Da
Vinci durch die <a href="https://codingdavinci.de/daten", target="_blank">Giant Monkey Software Engineering GmbH</a> zur Verfügung gestellt. Die schulstatistischen Daten kommen von der 
              <a href="http://www.hamburg.de/schulstatistiken", target="_blank">Behörde für Schule und Berufsbildung</a>. Die Daten zu den Postleitzahlen-Grenzen findet man <a href="https://www.suche-postleitzahl.org/downloads", target="_blank">hier</a>.
       
   <p style="text-align:justify"><strong>Datenaufbereitung:</strong> Die Schulstatistischen Daten berücksichtigen die Anzahl der Schüler von Förderschulen, Gemeinschaftsschulen, Grundschulen, Gymnasien, Sonderschulen und Stadtteilschulen (Gesamtschulen, Realschulen, Hauptschulen). Die Gruppenbuchungen berücksichtigen dementsprechend nur Buchungen von diesen Schulformen. Die Gruppenbuchungen pro Schule können leider nicht angegeben werden, weil diese nur auf Postleitzahlen-Ebene erfasst werden.   
       
       </p>'),
  

  
  HTML('
              <p>Cheers!<br/>


              </p>'),
  
  value="about"
))

))))
