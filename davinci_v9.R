#############################################################################################################################################
# PACKAGES & WD
#############################################################################################################################################

# load packages
require(leaflet)
require(rgdal)
require(dplyr)
require(shiny)
require(reshape2)

# set wd
setwd("C:/Users/AKRUSE/Documents/R/CDV")

#############################################################################################################################################
# GET BOOKING DATA
#############################################################################################################################################

# get booking data
dataset <- read.table("bookings.txt", header = T, sep = ",", encoding = "UTF-8")
dataset$X <- NULL
dataset$id <- NULL

# format features
dataset$start_time <- as.POSIXct(dataset$start_time,format = "%Y-%m-%d %H:%M:%S")
dataset$created_at <- as.POSIXct(dataset$created_at,format = "%Y-%m-%d %H:%M:%S")
dataset$updated_at <- as.POSIXct(dataset$updated_at,format = "%Y-%m-%d %H:%M:%S")
dataset$participant_count <- as.integer(as.character(dataset$participant_count))
dataset$museum_id <- as.factor(dataset$museum_id)
dataset$product_id <- as.factor(dataset$product_id)

# paste table name to features
colnames(dataset) <- paste("bookings",colnames(dataset), sep = "_")

#############################################################################################################################################
# ADD CUSTOMER ADRESS
#############################################################################################################################################

# get data
customer_adresses <- read.table("customer_adresses.txt", header = T, sep = ",", encoding = "UTF-8")
customer_adresses$X <- NULL
customer_adresses$id <- NULL
customer_adresses$customer_category_id <- NULL

# format features
customer_adresses$customer_id <- as.factor(customer_adresses$customer_id)

# paste table name to features
colnames(customer_adresses) <- paste("customer_adresses",colnames(customer_adresses), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, customer_adresses, by.x = "bookings_customer_id", by.y = "customer_adresses_customer_id")
rm(customer_adresses)

#############################################################################################################################################
# ADD CUSTOMER INFORMATION
#############################################################################################################################################

# get data
customers <- read.table("customers.txt", header = T, sep = ",", encoding = "UTF-8")
customers$X <- NULL

# format features
customers$id <- as.factor(customers$id)

# paste table name to features
colnames(customers) <- paste("customers",colnames(customers), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, customers, by.x = "bookings_customer_id", by.y = "customers_id")
rm(customers)

#############################################################################################################################################
# ADD CUSTOMER CATEGORIES
#############################################################################################################################################

# get data
customer_categories <- read.table("customer_categories.txt", header = T, sep = ",", encoding = "UTF-8")
customer_categories$X <- NULL

# format features
customer_categories$id <- as.factor(customer_categories$id)

# paste table name to features
colnames(customer_categories) <- paste("customer_categories",colnames(customer_categories), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, customer_categories, by.x = "customers_customer_category_id", by.y = "customer_categories_id")
rm(customer_categories)

#############################################################################################################################################
# ADD MUSEUM INFORMATION
#############################################################################################################################################

# get data
museums <- read.table("museums.txt", header = T, sep = ",", encoding = "UTF-8")
museums$X <- NULL

# format features
museums$id <- as.factor(museums$id)

# paste table name to features
colnames(museums) <- paste("museums",colnames(museums), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, museums, by.x = "bookings_museum_id", by.y = "museums_id")
rm(museums)

#############################################################################################################################################
# ADD EXHIBITIONS
#############################################################################################################################################

# get data
exhibitions <- read.table("exhibitions.txt", header = T, sep = ",", quote = "'", fill = T, encoding = "UTF-8")
exhibitions$X <- NULL

# format features
exhibitions$id <- as.factor(exhibitions$id)

# paste table name to features
colnames(exhibitions) <- paste("exhibitions",colnames(exhibitions), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, exhibitions, by.x = "bookings_exhibition_id", by.y = "exhibitions_id")
rm(exhibitions)

#############################################################################################################################################
# ADD PRODUCTS
#############################################################################################################################################

# get data
products <- read.table("products.txt", header = T, sep = ",", quote = "'", fill = T, encoding = "UTF-8")
products$X <- NULL

# format features
products$id <- as.factor(products$id)

# paste table name to features
colnames(products) <- paste("products",colnames(products), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, products, by.x = "bookings_product_id", by.y = "products_id")
rm(products)

#############################################################################################################################################
# ADD AGE GROUP
#############################################################################################################################################

# get data
age_groups <- read.table("age_groups.txt", header = T, sep = ",", encoding = "UTF-8")
age_groups$X <- NULL

# format features
age_groups$id <- as.factor(age_groups$id)

# paste table name to features
colnames(age_groups) <- paste("age_groups",colnames(age_groups), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, age_groups, by.x = "bookings_age_group_id", by.y = "age_groups_id")
rm(age_groups)

#############################################################################################################################################
# ADD LANGUAGE
#############################################################################################################################################

# get data
languages <- read.table("languages.txt", header = T, sep = ",", encoding = "UTF-8")
languages$X <- NULL

# format features
languages$id <- as.factor(languages$id)

# paste table name to features
colnames(languages) <- paste("languages",colnames(languages), sep = "_")

# add customer information to bookings
dataset <- merge(dataset, languages, by.x = "bookings_language_id", by.y = "languages_id")
rm(languages)

#############################################################################################################################################
# CLEAN UP FINAL DATASET I
#############################################################################################################################################

mydata <- select(dataset,
                 bookings_customer_id,
                 bookings_payment_mode_name,
                 bookings_canceled,
                 bookings_start_time,
                 bookings_participant_count,
                 bookings_created_at,
                 bookings_storno_regulation_type,
                 customer_adresses_zip,
                 customer_adresses_city,
                 customer_adresses_country,
                 customers_newsletter,
                 customer_categories_name,
                 museums_name,
                 exhibitions_name,
                 products_title,
                 products_product_category,
                 age_groups_name,
                 languages_name)

#############################################################################################################################################
# FILTER FINAL DATASET
#############################################################################################################################################

# read hh zips
setwd("C:/Users/akruse/Documents/R/CDV/")
plz <- read.table("plz_hamburg.csv", sep = ";", header = F)
plz <- as.vector(as.matrix(plz[2:length(plz)]))
plz <- plz[!is.na(plz)]
plz <- as.factor(plz)
plz <- unique(plz)
plz <- as.data.frame(plz)

# filter on hh zips
mydata <- subset(mydata, mydata$customer_adresses_zip %in% plz$plz)

# filter out cancelations
mydata <- filter(mydata, bookings_canceled == 0)

# filter out privat booking
Schule <- c("Grundschule","Gymnasium","Stadtteilschule","Gesamtschule","Realschule","Hauptschule","Sonderschule","Gemeinschaftsschule","Sonderschule","Förderschule")
mydata <- filter(mydata, customer_categories_name %in% Schule)
rm(Schule)

#############################################################################################################################################
# CLEAN UP FINAL DATASET II
#############################################################################################################################################

mydata <- select(mydata,
                 bookings_customer_id,
                 #bookings_payment_mode_name,
                 #bookings_canceled,
                 bookings_start_time,
                 #bookings_participant_count,
                 #bookings_created_at,
                 #bookings_storno_regulation_type,
                 customer_adresses_zip,
                 #customer_adresses_city,
                 #customer_adresses_country,
                 #customers_newsletter,
                 customer_categories_name,
                 #exhibitions_name,
                 #products_title,
                 #products_product_category,
                 #age_groups_name,
                 #languages_name,
                 museums_name)

#############################################################################################################################################
# LOAD SHAPEFILE FOR ZIPs
#############################################################################################################################################

# load data
setwd("C:/Users/akruse/Documents/R/CDV/")
ger_plz <- readOGR(dsn = ".", layer = "plz-gebiete")

# filter on hamburg
mydata_zip <- mydata %>%
  group_by(customer_adresses_zip) %>%
  summarise(zipcnt = n())
ger_plz <- ger_plz[ger_plz@data$plz %in% unique(droplevels(plz$plz)),]

#############################################################################################################################################
# ADD DATA TO POLYGONS
#############################################################################################################################################

# add museums data
test <- merge(ger_plz@data, mydata_zip, by.x = "plz", by.y = "customer_adresses_zip", all.x = TRUE)
test[is.na(test)] <- 0
correct.ordering <- match(ger_plz@data$plz, test$plz)
ger_plz@data <- test[correct.ordering, ]
rm(correct.ordering,test,plz)

# add student data
#schools <- read.table("SchulenPLZ.csv", sep = ",", header = T)
#schools$Schulname <- sub("^$", NA, schools$Schulname)
#schools$Schule.Strasse <- sub("^$", NA, schools$Schule.Strasse)
#schools <- na.locf(schools)
#write.table(schools, "schools.csv", sep = ",", row.names = F)

schools <- read.table("SchulenPLZ.csv", sep = ";", header = T, encoding = "UTF-8")
schools <- schools %>% group_by(Schule.PLZ) %>% summarise(stcnt = sum(Ergebnis))

test <- merge(ger_plz@data, schools, by.x = "plz", by.y = "Schule.PLZ", all.x = TRUE)
test[is.na(test)] <- 0
correct.ordering <- match(ger_plz@data$plz, test$plz)
ger_plz@data <- test[correct.ordering, ]
rm(correct.ordering,test,schools, mydata_zip, dataset)

# filter out zero-zeros
ger_plz <- ger_plz[ger_plz@data$stcnt > 0 | ger_plz@data$zipcnt > 0,]

# create new kpi
ger_plz@data$zipcnt_stcnt <- ger_plz@data$stcnt/ger_plz@data$zipcnt
ger_plz@data$zipcnt_stcnt <- round(ger_plz@data$zipcnt_stcnt, 1)

ger_plz <- ger_plz[ger_plz@data$stcnt > 0 | ger_plz@data$zipcnt > 0,]

ger_plz@data$zipcnt_stcnt[ger_plz@data$zipcnt_stcnt == Inf] <- 0

#############################################################################################################################################
# WRITE OUT FINAL SHAPEFILE
#############################################################################################################################################

writeOGR(ger_plz, ".", "gerplz", driver="ESRI Shapefile")

#############################################################################################################################################
# PLOT DATA
#############################################################################################################################################

# continous colour palette
pal <- colorNumeric(
  palette = "Blues",
  domain = ger_plz@data$stcnt
)

# create pop ups
state_popup <- paste0("<strong>Postleitzahl: </strong>", 
                      ger_plz@data$note, 
                      "<br><strong>Museumsbuchungen: </strong>", 
                      ger_plz@data$zipcnt,
                      "<br><strong>Schueler: </strong>", 
                      ger_plz@data$stcnt)

# plot data
leaflet() %>%
  addTiles() %>%
  addCircles(lng = schools$longitude, lat = schools$latitude, popup = schools$Schulname, color="#000000", fillColor="#000000", fillOpacity = 100, opacity = 100, stroke = T) %>%
  addLegend("bottomright", pal = pal, values = ger_plz@data$stcnt,
            title = "Anzahl der Museumsbuchungen",
            opacity = 1)
rm(pal,state_popup)
  




