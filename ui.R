#############################################################################################################################################
# packages
#############################################################################################################################################

require(shiny)
require(leaflet)
require(rgdal)
require(artyfarty)
require(shinythemes)

#############################################################################################################################################
# ui
#############################################################################################################################################

# value for select button
vars <- c("Schüler" = "stcnt",
          "Museumsausflüge" = "zipcnt",
          "Museumsausflüge/Schüler" = "zpcnt_s")

# load data
setwd("C:/Users/akruse/Documents/R/CDV/hhmuseum")
mydata <- read.table("mydatafull.csv", header = T, sep = ";")

# ui
shinyUI(
  bootstrapPage(theme = shinytheme("flatly"),div(class="outer",includeCSS("style.css"),
                                                 
 navbarPage(title="Hamburger Schüler im Museum", inverse = T,
            tabPanel("Karte",
                     sidebarLayout(
                       mainPanel(leafletOutput("ger_plz.map", height = "820")),
                       sidebarPanel(h3("Was geht hier ab?"),
                                    p("Moin! Diese App zeigt an, wie häufig Schüler aus verschiedenen Stadteilen zwischen Januar 2013 und September 2016 einen Schulausflug in die Hamburger Museen gemacht haben. Folgende Funktionen hat diese interaktive Karte:"),
                                    HTML("<ul><li>Die Karte kann die Anzahl der Schüler oder die Anzahl der Museumsausflüge pro Postleitzahl anzeigen. Darüber hinaus kann man sich das Verhältnis (Musuemsausflüge/Schüler) anzeigen lassen.</li><li>Klickt man auf einen Stadtteil erhält man alle Informationen im Überblick. Man kann jederzeit weiter herein oder heraus zoomen.</li><li>Weiterhin zeigen die blauen Kreise die Schulen und die schwarzen Kreise die Museen an. Klickt man auf diese erhält man Informationen zu den Objekten.</li></ul>"),
                                    HTML("<strong>Ein Beispiel:</strong> Lasse Dir zunächst die Karte mit dem Verhältnis Museumsausflüge/Schüler anzeigen. Im Zentrum von Hamburg siehst du den grün eingefärbten Stadtteil 20146 HH-Rotherbaum. Schüler aus dieser Gegend gehen besonders oft ins Museum :) Wenn Du wissen möchtest welche Schulen in dieser Gegend liegen, gehe auf den TAB SCHULEN und suche nach 20146."),
                                    br(),
                                    br(),
                                    p("Und was geht in Deiner Hood? Finde es heraus!"),
                                    br(),
                                    radioButtons("kennzahl", "Was soll auf der Karte angezeigt werden?", vars),
                                    checkboxInput("legende", "Legenden", T),
                                    width = 3
                                    ),
                       position = "right"
                       )
                     ),
            tabPanel("Schulen",
                     fluidPage(
                       titlePanel(""),
                       sidebarLayout(
                         sidebarPanel(h3("Und was geht in deiner Hood so?"),
                                      selectInput("plz", "Postleitzahl:",
                                                  choices=unique(mydata$PLZ)),
                                      hr(),
                                      helpText("Die Gruppenbuchungen pro Schule können leider nicht angegeben werden, weil diese nur auf Postleitzahlen-Ebene erfasst werden."),
                                      br(),
                                      tableOutput('ex1'),
                                      width = 4
                                      ),
                         mainPanel(
                           plotOutput("plzPlot"),
                           br(),
                           plotOutput("schulPlot")
                           )
                         )
                       )
                     ),
            tabPanel("About",
                     sidebarPanel(
                               HTML('<p style="text-align:justify"><strong>Allgemeines:</strong> Diese Web-App wurde mit <a href="http://shiny.rstudio.com/", target="_blank">Shiny</a> im Rahmen des <a href="https://codingdavinci.de", target="_blank">Coding Da Vinci</a> Kultur-Hackathons gebaut.<p style="text-align:justify"><strong>Code:</strong> Den Code für die Shiny-App findet man <a href="https://github.com/kruse-alex", target="_blank">hier</a>.<p style="text-align:justify"><strong>Daten:</strong> Die Buchungsdaten der Museen in Hamburg wurden im Rahmen von Coding Da Vinci durch die <a href="https://codingdavinci.de/daten", target="_blank">Giant Monkey Software Engineering GmbH</a> zur Verfügung gestellt. Die schulstatistischen Daten kommen von der <a href="http://www.hamburg.de/schulstatistiken", target="_blank">Behörde für Schule und Berufsbildung</a>. Die Daten zu den Postleitzahlen-Grenzen findet man <a href="https://www.suche-postleitzahl.org/downloads", target="_blank">hier</a>.<p style="text-align:justify"><strong>Datenaufbereitung:</strong> Die schulstatistischen Daten berücksichtigen die Anzahl der Schüler von Grundschulen, Gymnasien, Sonderschulen und Stadtteilschulen (Gesamtschulen, Realschulen, Hauptschulen) und stammen aus 2015/2016. Für die einzelnen Stadtteile werden dementsprechend nur Museumsausflüge von diesen Schulformen berücksichtigt. Es werden Museumsausflüge von Januar 2013 bis Septmber 2016 berücksichtigt. Die Museumsausflüge pro Schule können leider nicht angegeben werden, weil diese nur auf Postleitzahlen-Ebene erfasst werden.</p>'),
                               HTML('<p>Cheers!<br/></p>'),
                               value="about"
                     )
                    )
           )
                                                )
               )
)
