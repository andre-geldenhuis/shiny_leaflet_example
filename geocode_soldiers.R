library(tidyverse)
library(sf)
library(tmaptools)

soldier_df <- read.csv("test_soldiers.csv")
places <- as.character(unique(soldier_df$non_effective_place)) #get unique places


places_lookup <- geocode_OSM(places) #geocode those places, once each. Returns query       lat      lon   lat_min   lat_max  lon_min  lon_max
places_lookup = places_lookup[c('query','lat','lon')]  #drop extraneous columns like lat_min lat_max etc 

#the geocoding returns the cities under a column name "query", rename that to non_effective_place to match soldier_df
places_lookup = rename(places_lookup, non_effective_place = query)

#join our solders_df and places_lookup, this adds a lat lon column for each row corresponding to the non_effective_place
soldier_df = inner_join(places_lookup,soldier_df)

projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
df = st_as_sf(x=soldier_df,
              coords=c("lon","lat"),
              crs = projcrs)    #Note that coords are x-y THEREFORE lon lat, not lat,lon

st_write(df,"geocoded_soldiers.geojson")
