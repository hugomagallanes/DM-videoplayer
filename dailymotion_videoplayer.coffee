
###

###

###  ===================================================================
     1 || GLOBAL VARIABLES ||
==================================================================== ###


playerDimensions =
  small:
      width: 552
      height: 310
  medium:
      width: 576
      height: 324
  large:
      width: 773
      height: 435

info =
  channel:
      fontSize: 18

fontSizesInfo = [
  ["infoChannel" , 18],
  ["infoHeader" , 24],
  ["timeCurrent", 14],
  ["timeDuration", 14]
]


#--> SVG FILES
SVG_playButton = """
<svg viewBox="0 0 17 17" >
    <g stroke="none" stroke-width="1" fill-rule="evenodd">
        <g transform="translate(-90.000000, -25.000000)">
            <g transform="translate(90.000000, 25.000000)">
                <rect fill="none" opacity="0" x="0" y="0" width="17" height="17"></rect>
                <polygon points="2.5 0 14.5 8.5 2.5 17"></polygon>
            </g>
        </g>
    </g>
</svg>

"""

SVG_pauseButton = """
<svg viewBox="0 0 17 17">
    <g stroke="none" stroke-width="1" fill-rule="evenodd">
        <g transform="translate(-58.000000, -25.000000)">
            <g transform="translate(58.000000, 25.000000)">
                <rect fill="none" opacity="0" x="0" y="0" width="17" height="17"></rect>
                <path d="M11.0035525,0 L15.5,0 L15.5,17 L11.0035525,17 L11.0035525,0 Z M1.5,0 L5.99644748,0 L5.99644748,17 L1.5,17 L1.5,0 Z" ></path>
            </g>
        </g>
    </g>
</svg>


"""

SVG_skipButton = """
<svg viewBox="0 0 17 17">
    <g stroke="none" stroke-width="1" fill-rule="evenodd">
        <g transform="translate(-25.000000, -25.000000)">
            <g transform="translate(25.000000, 25.000000)">
                <path d="M14,0 L17,0 L17,17 L14,17 L14,0 Z M0,0 L12,8.5 L0,17 L0,0 Z"></path>
            </g>
        </g>
    </g>
</svg>
"""





class exports.DMVideoPlayer extends VideoLayer

    constructor: (@options={}) ->

      #--> Unchangeable defaults
      # ↳ They still can be changed using a notation system
      @options.width = playerDimensions.large.width
      @options.height = playerDimensions.large.height
      @options.format ?= "large"

      #--> Changeable defaults
      _.defaults @options,
        backgroundColor: null
        video: "http://hugomagalhaes.design/framer/videos/neymar_training_2.mp4"

      @overlay = new Layer
        name: "overlay"
        backgroundColor: "rgba(0,0,0,.6)"

      @controls = new Layer
        name: "controls"
        backgroundColor: null

      @videoInfo = new Layer
        name: "videoInfo"
        backgroundColor: null

      @playButton = new Layer
        name: "playButton"
        backgroundColor: "rgba(255,255,255,.4)"

      @playButtonIcon = new SVGLayer
        name: "playButtonIcon"
        backgroundColor: null
        svg: SVG_playButton

      @infoHeader = new TextLayer
        name: "videoHeader"
        text: "Lady Gaga surprises fans"

      @infoChannel = new TextLayer
        name: "infoChannel"
        text: "Channel name"

      @timeline = new Layer
        name: "timeline"
        backgroundColor: "rgba(255,255,255,.25)"

      @progressBar = new Layer
        name: "progressBar"
        backgroundColor: "#00D2F3"

      @timeCurrent = new TextLayer
        name: "timeCurrent"
        text: "0:00"

      @timeDuration = new TextLayer
        name: "timeDuration"
        text: "0:00"









      # 🚩 INITIATES COMPONENT
      super @options

      #--> Overlay
      @overlay.parent = @
      @overlay.size = @size

      #--> Controls
      @controls.parent = @.overlay
      @controls.size = @.overlay.size

      @videoInfo.parent = @.overlay
      @videoInfo.size = @.overlay.size


      #-->  Play/Pause button
      @playButton.parent = @.videoInfo
      @playButton.size = 80
      @playButton.borderRadius = 100
      @playButton.x = 60
      @playButton.y = Align.center

      #--> Play/Pause button icon
      @playButtonIcon.parent = @.playButton
      @playButtonIcon.size = 28
      @playButtonIcon.fill = "white"
      @playButtonIcon.point = Align.center

      #--> Timeline
      @timeline.parent = @.controls
      @timeline.width = @width
      @timeline.height = 5
      @timeline.y = Align.bottom

      #--> Progress Bar
      @progressBar.parent = @.timeline
      @progressBar.width = 0
      @progressBar.height = @.timeline.height


      #--> Information (TextLayers)
      textlayersArr = [@infoChannel, @infoHeader, @timeCurrent, @timeDuration]

      @infoChannel.parent = @.videoInfo
      @infoHeader.parent = @.videoInfo
      @timeDuration.parent = @.controls
      @timeCurrent.parent = @.controls

      # Loop throught array and assign defaults
      for layer, i in textlayersArr
        @SetDefaultFont(layer, fontSizesInfo[i][1])

      @infoHeader.fontWeight = "500"
      @timeCurrent.fontWeight = "500"
      @timeDuration.fontWeight = "500"


      @infoChannel.x = @.playButton.maxX + 30
      @infoChannel.y = Align.center(-14)
      @infoHeader.x = @.playButton.maxX + 30
      @infoHeader.y = Align.center(14)
      @timeCurrent.x = 24
      @timeCurrent.y = Align.bottom(-20)
      @timeDuration.x = @timeCurrent.maxX + 5
      @timeDuration.y = Align.bottom(-20)



      #--> EVENTS
      @.onClick @TogglePlayPause

      #--> FUNCTIONS
      @FetchVideoDuration()
      @TimeUpdate()


    #--> 🔧 GETTERS & SETTERS DEFINITION


    #--> 🔧 SUPPORTING FUNCTIONS DEFINITION

    ConvertIntoSecondsMinutes: (value) =>

      # Transforms currentTime into minutes and seconds
      minutes = Math.floor(value / 60)
      seconds = Math.round(value % 60)

      # Converts seconds into 2 digits if there are less than 10 seconds
      if seconds < 10
        seconds = "0#{seconds}"

      return "#{minutes}:#{seconds}"

    SetDefaultFont: (layer, val) =>
      layer.fontFamily = "Retina"
      layer.fontSize = val
      layer.color = "white"


    #--> 🔧 EVENT FUNCTIONS DEFINITION


    TogglePlayPause: =>
        if @.player.paused is true
          # Plays video
          @.player.play()

          # Changes player icon to Play
          @.playButtonIcon.svg = SVG_playButton
        else
          # Pauses video
          @.player.pause()

          # Changes player icon to Play
          @.playButtonIcon.svg = SVG_pauseButton

    TimeUpdate: =>
      Events.wrap(@.player).on "timeupdate", =>

        # Stores video current time
        currrentTime = Math.round(@.player.currentTime)

        #--> Update timeline
        # Stores current time of the video divided by the width of timeline
        newPos = (@.timeline.width / @.player.duration) * currrentTime

        # Changes timeline width accordingly
        @.progressBar.width = newPos

        #--> Update currentTime
        @.timeCurrent.text = @ConvertIntoSecondsMinutes(currrentTime)



    FetchVideoDuration: =>
      Events.wrap(@.player).on "canplay", =>

        # Fetches video total duration (in seconds)
        duration = Math.round(@.player.duration)

        # Updates TextLayer
        @.timeDuration.text = "/" + "  " + @ConvertIntoSecondsMinutes(duration)
