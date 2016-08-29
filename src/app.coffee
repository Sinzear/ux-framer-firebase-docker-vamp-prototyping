
{Firebase} = require 'firebase'

device = new Framer.DeviceView();

device.setupContext()
device.deviceType = "google-nexus-6p"
device.contentScale = 1

deviceHeight = device.screen.height
deviceWidth = device.screen.width

# variables to hold a scale value we’ll use later
initialScale = 0.2

# The required information is located at https://firebase.google.com → Console → YourProject → ...
demoDB = new Firebase
  projectID: "frameronfire" # ... Database → first part of URL
  secret: "mAcwiwHCHee7OnAZFVYEGPg5PhAJu2Y6H0mg5PVd" # ... Project Settings → Database → Database Secrets
  server: 's-usc1c-nss-102.firebaseio.com'


cards = []
proxies = []
cardCount = 3



# Layers ----------------------------------


popSFX = new VideoLayer
  video: "blop.mp3" # by Mark DiAngelo
  visible: false


# Create card- and proxy-layers
for i in [0...cardCount]

  card = cards[i] = new Layer
    image: "https://unsplash.it/#{Screen.width}/#{Screen.height/cardCount}?image=#{i+229}"
    width: Screen.width
    height: Screen.height/cardCount
    y: Screen.height/cardCount * i
    name: "card#{i}"
    html: "0"
    rotationX: -45
    opacity: 0
    style:
      fontFamily: "Helvetica Neue"
      fontSize: "120px"
      fontWeight: "100"
      textAlign : "center"
      lineHeight: "#{Screen.height/cardCount}px"
      textShadow: "0px 2px 8px rgba(0, 0, 0, 0.25)"

  card.animate
    properties:
      rotationX: 0
      opacity: 1
    curve: "spring(50,10,0)"
    delay: i / 2 + .5

  card.onTouchStart ->
    @.animate
      properties:
        saturate: 0
      curve: "ease-in"
      time: .2

  # Add a Like onTouchEnd
  card.onTouchEnd ->

    index = _.indexOf(cards, @) # Get index of the tapped card

    # Add a new child-node at
    demoDB.post("/likeCounts/#{index}", 0) # `post´-method can´t be null, undefined or empty, hence `0´

    # We'll later count all the child-nodes at that path, which is our Like-count (1 child-node = 1 like)

    @.animate
      properties:
        saturate: 100
      curve: "ease-in"
      time: .2


  # Proxy layers are used to `fade´-in Like-counts
  proxy = proxies[i] = new Layer
    parent: card
    visible: false
    name: "proxy#{i}"

  # Proxy is later animated when loading data from Firebase
  proxy.onChange "x", -> @.parent.html = Math.floor(@.x)


# Update ----------------------------------

response = (data, method, path, breadCrumb) ->

# If the database at `/likeCounts´ is null/empty, create a child for each card
  if data is null
    for i in [0...cardCount]
      demoDB.put("/likeCounts/#{i}", 0)


  if path is "/" # euqals, we´re loading the whole dataset onLoad (fires only once)
    if data? # make sure some data exists

      for card,i in cards
        likes = _.toArray(data[i]).length # convert the `data´-response to an array; get its length

        # This causes the Like count to `fade´-in
        proxies[i].animate
          properties:
            x: likes
          curve: "cubic-bezier(0.86, 0, 0.07, 1)"
          delay: i / 2
          time: .5

  else # euqals, a new like was added (to any card)

# Let's find out, to wich card the like was added by
    index = breadCrumb[0]

    # Now that we know to which card the like was added, we check how many
    # child-nodes are at that path, which is our Like-count (1 child-node = 1 like)
    demoDB.get "/likeCounts/#{index}", (likes) ->

      cards[index].html = _.toArray(likes).length

      popSFX.player.play() # Play sound effect

      # Heart animation
      heart = new Layer
        parent: cards[index]
        size: cards[index].size
        backgroundColor: ""
        html: "❤"
        style:
          fontSize: "200px"
          fontWeight: "100"
          textAlign : "center"
          lineHeight: "#{Screen.height/cardCount-10}px"

      heart.animate
        properties:
          scale: 2
          opacity: 0
        curve: "cubic-bezier(0.215, 0.61, 0.355, 1)"
        time: .5

      heart.onAnimationEnd -> @.destroy()



demoDB.onChange("/likeCounts", response) #
# **Please deactivate Auto Refresh and reload manually using CMD+R!**