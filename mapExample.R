# Load the libraries

library(maptools)
library(ggplot2)
library(RColorBrewer)
library(ggmap)
library(plyr)
library(extrafont)
loadfonts()

# Read the shapefile from Eurostat

EuropeMap <- readShapePoly("NUTS_2010_10M_SH/data/NUTS_RG_10M_2010")

# If you want to subset the map there is an example commented below
# EuroMapES <- subset(EuropeMap, grepl("ES", EuropeMap@data$NUTS_ID))

# Convert the file to a dataframe

EuropeMapDataFrame <- fortify (EuropeMap)

# Add the column id to the EuropeMapDataFrame@data section

EuropeMap@data$id <- rownames(EuropeMap@data)
EuropeMapDataFrame <- merge(EuropeMapDataFrame, EuropeMap@data, by="id")

# I recomment having the id as a factor

EuropeMapDataFrame$id <- as.factor(EuropeMapDataFrame$id)

# Load the data and merge with the dataframe. In this example case, I am using as a link
# the table I created with the contry and its NUTS code, you can find it in the repo

Bmi <- read.csv("hlth_ehis_de2_1_Data.csv")
LinkTable <- read.csv("NUTeqcount.csv")
LinkTableData <- merge(Bmi, LinkTable, by.x="GEO", by.y="Country")

# The number of rows increases substantially. This is due to the multiple categories in
# the data. We need to choose only the catgeory we want to plot.

LinkTableData <- subset(LinkTableData, BMI=="Obese" & SEX=="Total" & AGE=="Total")

# We must join completely (all.x=T) as the data we are plotting is incomplete.

LinkTableData <- merge(EuropeMapDataFrame, LinkableData, 
                      by.x="NUTS_ID", by.y="Scountry", all.x=T)

# We only want to plot the country borders

LinkTableData <- subset(LinkableData, STAT_LEVL_=="0")

# If you want a zoomed map of Europe
# SmallMapDataFrame <- subset(EuropeMapDataFrame, 
# EuropeMapDataFrame$lat > 30 & 
# EuropeMapDataFrame$long > -10 & EuropeMapDataFrame$long < 50)

# Convert the data into numberic

LinkableData$Value <- as.character(LinkableData$Value)
LinkableData$Value <- as.numeric(LinkableData$Value)

# Always order or polygons will look weird

LinkableData <- LinkableData[order(LinkableData$order),]
# 
# Creating and centering labels
CountryLabel <- ddply(LinkableData,"GEO", summarise, long = mean(long), lat = mean(lat))
CountryLabel <- na.omit(CountryLabel)

# Plot

ggplot(LinkableData) + geom_polygon(aes(x=long, y=lat, group=group, fill=Value)) 
+ geom_path(aes(x=long, y=lat, group=group), color="white") 
+  coord_map("gilbert") 
+ scale_fill_gradientn(colours=brewer.pal(9,"Purples"))
+ geom_text(aes(x=long, y=lat, label=GEO), data=CountryLabel, col="black", cex=2)