# 0 = for no button pressed, 1 for main button, 3 for secondary button
button_down = BUTTON_NOT_PRESSED
# Preload audio
success_audio     = new Audio()
success_audio.src = '/audio/beep-good.ogg'

solution = player = board = time = x0 = y0 = maximum_board_size_in_pixels = paper = null

###
 Converts time in microseconds to HH:MM:SS format
###
secondsToHms = (d) ->
  d = Number d
  h = Math.floor d / 3600
  m = Math.floor d % 3600 / 60
  s = Math.floor d % 3600 % 60
  return (h > 0 ? h + ":" : "") + (m > 0 ? (h > 0 and m < 10 ? "0" : "") + m + ":" : "0:") + (s < 10 ? "0" : "") + s

###
 Initialise common game variables used all over the code
###
init = (data) ->
  # The board's array is represented as a single-dimensional one, streamlined from
  # left to right and from top to bottom
  solution = new Nonogram data
  # Initialize the user's solution array with EMPTY CELL's
  player = (EMPTY_CELL for num in [0...data.length])
  board = new Board paper, x0, y0, maximum_board_size_in_pixels, solution
  board.render solution.getHintValues()
  # Initialize timer
  time = new Date().getTime()

###
 Shows a dialog with the time needed to solve the nonogram
###
resolved = ->
  button_down = BUTTON_NOT_PRESSED
  # Calculate total resolution time
  final_time  = new Date().getTime()
  time        = (final_time-time)/1000
  time        = secondsToHms time
  $("#dialog").text "Your time: #{time}"
  success_audio.play()
  
  $("#dialog").dialog
    modal:         true
    resizable:     false
    closeOnEscape: false
    title:         'Success!'
    buttons:       
      'Try another one': ->
        $(@).dialog 'close'
    beforeClose:   -> 
      paper.clear()
      $.ajax
        url: '/random'
      .done (data) ->
        init data
      .fail ->
        alert 'error'

###
 MAIN
###
$('document').ready ->
  # Initialize a Raphael canvas to fit the whole viewport
  viewport_width  = $(window).width()
  viewport_height = $(window).height()
  paper = Raphael 0, 0, viewport_width-1, viewport_height-1
  if paper.width < paper.height
    # We reserve 1/2.4 of the viewing area for the hints information
    # TODO center the board including the hints info
    margin = Math.floor paper.width/2.4
    maximum_board_size_in_pixels = paper.width-margin
  else
    margin = Math.floor paper.height/2.4
    maximum_board_size_in_pixels = paper.height-margin

  # Center the board both vertically and horizontally
  x0 = Math.floor (viewport_width/2)  - Math.floor (maximum_board_size_in_pixels/2)
  y0 = Math.floor (viewport_height/2) - Math.floor (maximum_board_size_in_pixels/2)

  # Get a random puzzle from server
  $.ajax
    url: '/random'
  .done (data) ->
    init data
    # Prevent accidental dragging of the SVG layer
    # TODO do also for VML
    $('svg').bind 'dragstart', (event) -> event.preventDefault()
    # Disable context menu, so the user can use mouse's secondary button normally
    $(document).bind "contextmenu", -> false

    ###
     Resize elements on screen to fit the new window size if it changes
    ###
    $(window).resize ->
      paper.setSize $(window).width(), $(window).height()
      paper.setViewBox 0, 0, viewport_width-1, viewport_height-1, true

    $('body').on 'mousedown', '[id^="cell"], [id^="tile"], [id^="mark"]', (e) ->
      button_down = e.which
      # Capture the position of the cell being handled
      # For that, we get rid of the non-numeric part of the element's id
      pos = $(@).data 'pos'
      $(@).attr 'fill', '#'+EMPTY_CELL_COLOR
      if button_down is MAIN_BUTTON
        if player[pos] is MARKED_CELL
          $("[id^='mark#{pos}']").remove()
          # Update the solution array
          player[pos] = FILLED_CELL
          board.putTile pos
        else if player[pos] is FILLED_CELL
          # If there's a tile in that position, remove it
          $("[id^='tile#{pos}']").remove()
          player[pos] = EMPTY_CELL
        else
          board.putTile pos
          player[pos] = FILLED_CELL

      if button_down is SECONDARY_BUTTON
        if player[pos] is MARKED_CELL
          # If there's a mark in that position, remove it
          $("[id^='mark#{pos}']").remove()
          player[pos] = EMPTY_CELL
        else if player[pos] is FILLED_CELL
          $("[id^='tile#{pos}']").remove()
          player[pos] = MARKED_CELL
          board.putMark pos
        else
          board.putMark pos
          player[pos] = MARKED_CELL
        
      resolved() if solution.isSolution player

    # As we're using JQuery to capture events, we also use its attr() method
    # instead Raphael's one
    # TODO REWRITE AS ABOVE
    $('body').on 'mouseover', '[id^="cell"], [id^="tile"], [id^="mark"]',  ->
      pos = $(@).data 'pos'

      if button_down is MAIN_BUTTON and player[pos] isnt FILLED_CELL
        if player[pos] is MARKED_CELL
          $("[id^='mark#{pos}']").remove()
        player[pos] = FILLED_CELL
        board.putTile pos
        resolved() if solution.isSolution player
          
      if button_down is SECONDARY_BUTTON and player[pos] isnt MARKED_CELL
        if player[pos] is FILLED_CELL
          $("[id^='tile#{pos}']").remove()
        player[pos] = MARKED_CELL
        board.putMark pos
        resolved() if solution.isSolution player
      
      if not button_down and player[pos] is EMPTY_CELL
        # Highligth the cell if the mouse cursor is over it
        $(@).attr 'fill', '#'+HIGHLIGHTED_CELL_COLOR
        
    $('body').on 'mouseup', '[id^="cell"], [id^="tile"], [id^="mark"]', ->
      button_down = BUTTON_NOT_PRESSED

    $('body').on 'mouseout', '[id^="cell"]', -> 
      pos = $(@).data 'pos'
      if not button_down
        $(@).attr 'fill', '#'+EMPTY_CELL_COLOR

  .fail ->
    # The script couldn't fetch a random puzzle, exiting
    alert 'error'
