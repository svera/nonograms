# 0 = for no button pressed, 1 for main button, 3 for secondary button
button_down = BUTTON_NOT_PRESSED

###
 MAIN
###
$('document').ready ->
  # Initialize a Raphael canvas to fit the whole viewport
  viewport_width  = $(window).width()
  viewport_height = $(window).height()
  paper = Raphael 0, 0, viewport_width-1, viewport_height-1
  if paper.width < paper.height
    # We reserve 1/3 of the viewing area for the hints information
    # TODO center the board including the hints info
    margin = Math.floor paper.width/3
    board_size_in_pixels = paper.width-margin
  else
    margin = Math.floor paper.height/3
    board_size_in_pixels = paper.height-margin

  # Center the board both vertically and horizontally
  x0 = Math.floor (viewport_width/2)  - Math.floor (board_size_in_pixels/2)
  y0 = Math.floor (viewport_height/2) - Math.floor (board_size_in_pixels/2)

  # Get a random puzzle from server
  $.ajax
    url: '/random'
  .done (data) ->
    # The board's array is represented as a single-dimensional one, streamlined from
    # left to right and from top to bottom
    solution = new Nonogram data
    # Initialize the user's solution array with EMPTY CELL's
    player = (EMPTY_CELL for num in [0...data.length])
    board = new Board paper, x0, y0, board_size_in_pixels, solution
    board.render solution.getHintValues()

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

    $('body').on 'mousedown', '[id^="cell"], [id^="tile"]', (e) ->
      button_down = e.which
      # Capture the position of the cell being handled
      # For that, we get rid of the non-numeric part of the element's id
      # All interactive elements have an id 4 chars long
      pos = $(@).data 'pos'
      $(@).attr 'fill', '#'+EMPTY_CELL_COLOR
      if button_down is MAIN_BUTTON and player[pos] is (EMPTY_CELL or MARKED_CELL)
        board.putTile pos
        if player[pos] is MARKED_CELL
          $("[id^='mark#{pos}']").remove()
        # Mark the tile in the solution array, too
        player[pos] = FILLED_CELL
      else if button_down is MAIN_BUTTON and player[pos] is FILLED_CELL
        # If you click on a tile, remove it
        $(@).remove()
        player[pos] = EMPTY_CELL
      else if button_down is SECONDARY_BUTTON and player[pos] isnt MARKED_CELL
        board.putMark pos
        if player[pos] isnt EMPTY_CELL
          $(@).remove()
        player[pos] = MARKED_CELL
        
      if solution.isSolution player
        console.log 'resuelto'

    $('body').on 'mouseup', '[id^="cell"], [id^="tile"], [id^="mark"]', ->
      button_down = BUTTON_NOT_PRESSED

    # Highligth the cell if the mouse cursor is over it
    # As we're using JQuery to capture events, we also use its attr() method
    # instead Raphael's one
    $('body').on 'mouseover', '[id^="cell"], [id^="tile"]',  ->
      pos = $(@).data 'pos'
      if button_down is MAIN_BUTTON and player[pos] is (EMPTY_CELL or MARKED_CELL)
        board.putTile pos
        if player[pos] is MARKED_CELL
          $("[id^='mark#{pos}']").remove()
        player[pos] = FILLED_CELL
      else if button_down is SECONDARY_BUTTON and player[pos] isnt MARKED_CELL
        board.putMark pos
        if player[pos] isnt EMPTY_CELL
          $("[id^='tile#{pos}']").remove()
        player[pos] = MARKED_CELL
      else if not button_down and player[pos] is EMPTY_CELL
        # Highlight the cell
        $(@).attr 'fill', '#'+HIGHLIGHTED_CELL_COLOR

    $('body').on 'mouseout', '[id^="cell"], [id^="tile"]', -> 
      pos = $(@).data 'pos'
      if not button_down and player[pos] is EMPTY_CELL
        $(@).attr 'fill', '#'+EMPTY_CELL_COLOR

  .fail ->
    # The script couldn't fetch a random puzzle, exiting
    alert 'error'
