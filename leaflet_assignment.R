library(leaflet)

df <- data.frame(
  lat = c(
    50.593608,
    50.579862,
    50.579590,
    50.584867,
    50.579583,
    50.575179,
    50.574136,
    50.591865,
    50.607821,
    50.630026,
    50.616893,
    50.607954,
    50.600832
  ),
  lng = c(
    -3.9133286,
    -3.9393139,
    -3.9611793,
    -3.9668620,
    -3.9711517,
    -3.9925575,
    -4.0311688,
    -4.0225697,
    -4.0298501,
    -3.9985604,
    -3.9673671,
    -3.9431620,
    -3.9301264
  )
)

place_names <- c(
  '<p><b>Postbridge Visitor Centre</b></p>Car park, pub nearby',
  '<p><b>Powder Mills</b></p>Interesting historic industrial site',
  '<p><b>Wistman\'s Wood National Nature Reserve</b></p>Ancient stunted oaks',
  '<p><b>Weir</b></p>Good place for river crossing',
  '<p><b>Beardown Tors</b></p>Good views to east and southeast',
  '<b>Holming Beam</b>',
  '<p><b>Great Mis Tor</b></p>Good views to south and southwest',
  '<b>Cocks Hill</b>',
  '<p><b>Lynch Tor</b></p>Good views to west',
  '<p><b>Fur Tor</b></p>Great secluded spot for camping',
  '<p><b>Flat Tor</b></p>Pretty uninteresting',
  '<b>Broad Down</b>',
  '<p><b>Footbridge</b></p>Good place for river crossing'
)

leg_details <- c(
  'Walk along forest track, then pick up Lich Way',
  'Large tussocks near the top of the hill',
  'Boggy',
  'Good path',
  'Good path',
  'Usual moorland terrain',
  'Usual moorland terrain',
  'Usual moorland terrain',
  'Very boggy on higher ground',
  'Very boggy',
  'Very boggy',
  'Good path',
  'Good path through farmland, pub soon'
)

my_map <- df %>%
  leaflet() %>%
  addProviderTiles('Thunderforest.Outdoors', group = 'Topographical') %>%
  addMarkers(popup = place_names)

for(i in 1:(nrow(df) - 1)) {
  my_map <- addPolylines(
    my_map,
    lat = c(df$lat[i], df$lat[i + 1]),
    lng = c(df$lng[i], df$lng[i + 1]),
    popup = leg_details[i]
  )
}

my_map <- addPolylines(
  my_map,
  lat = c(df$lat[nrow(df)], df$lat[1]),
  lng = c(df$lng[nrow(df)], df$lng[1]),
  popup = leg_details[nrow(df)]
)

my_map