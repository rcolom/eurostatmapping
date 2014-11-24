



x <-searchTwitter("#dataanalysis", n=100)
y <- lapply(x, function(x) {c(x$screenName)})
start <- lapply(y, lookupUsers)
start <- unlist(start)
geoloc <- lapply(start, function(x) {c(x$location)})
geoloc <- unname(geoloc)
geoloc <- unlist(geoloc)
geo <- lapply(geoloc, gGeoCode)
geo2 <- do.call(rbind.data.frame, geo)
colnames(geo2) <- c("lat", "lon")

worldMap <- map_data("world")
ggplot(worldMap) 
+ geom_polygon(aes(x = long, y = lat, group = group), fill="gray") 
+ geom_point(data=geo2, aes(x = lon, y = lat),colour = "blue", alpha = 1/2, size = 2)
+ ggtitle("Who talks about #dataanalysis? 100 random tweets") 
+ xlab("Longitude") + ylab("Latitude")
