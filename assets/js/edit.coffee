HEADER_HEIGHT = 75
FOOTER_HEIGHT = 75
BOARD_MARGIN  = 20
# 0 = for no button pressed, 1 for main button, 3 for secondary button
button_down = BUTTON_NOT_PRESSED
color       = '555555'
# ID of the current nonogram
current_id  = null

###
 MAIN
###
$('document').ready ->
  nonogram = new Nonogram $('#nonogram_data').val().split ','
  # Initialize a Raphael canvas to fit the whole viewport
  viewport_width  = $(window).width()
  # The viewport height fits the whole browser's height except the height
  # reserved for the page's header
  viewport_height = $(window).height()-HEADER_HEIGHT-FOOTER_HEIGHT
  # The drawing area starts just after the header one, and fits the whole
  # browser's width
  paper = Raphael 0, HEADER_HEIGHT, viewport_width-1, viewport_height-1
  # We take the lessest dimension of the window as the reference for the board size
  if paper.width < paper.height
    board_size_in_pixels = paper.width-BOARD_MARGIN
  else
    board_size_in_pixels = paper.height-BOARD_MARGIN

  # Center the board both vertically and horizontally
  x0 = Math.floor (viewport_width/2) - Math.floor (board_size_in_pixels/2)
  y0 = Math.floor (viewport_height/2) - Math.floor (board_size_in_pixels/2)
  board = new Board paper, x0, y0, board_size_in_pixels, nonogram
  board.render null, true

  ###
   Prevent accidental dragging of the SVG layer
   TODO do also for VML
  ###
  $('svg').bind 'dragstart', (event) -> event.preventDefault()
  # Disable context menu, so the user can use mouse's secondary button normally
  $(document).bind "contextmenu", -> false
  # Colorpicker
  $('#colorSelector').ColorPicker
    color: '#'+color,
    onShow: (colpkr) ->
      $(colpkr).fadeIn 500
      return false
    onHide: (colpkr) ->
      $(colpkr).fadeOut 500
      return false
    onChange: (hsb, hex, rgb) ->
      $('#colorSelector div').css 'backgroundColor', '#' + hex
      color = hex

  ###
   Resize elements on screen to fit the new window size if it changes
   Due to how Raphael's setViewBox() method works (as a zoom tool), we
   need to resize the drawing area to its new dimensions, and later
   set its viewing box to the window's original dimensions 
  ###
  $(window).resize ->
    paper.setSize $(window).width(), $(window).height()-HEADER_HEIGHT-FOOTER_HEIGHT
    paper.setViewBox 0, 0, viewport_width-1, viewport_height-1, true

  $('body').on 'mousedown', '[id^="cell"], [id^="tile"]', (e) ->
    button_down = e.which
    pos = $(@).data 'pos'
    if button_down is MAIN_BUTTON and nonogram.data[pos] is EMPTY_CELL
      $(@).attr 'fill', '#'+EMPTY_CELL_COLOR
      board.putTile pos, color
      # Mark the tile in the nonogram array, too
      nonogram.data[pos] = color
    else if nonogram.data[pos] isnt (EMPTY_CELL or MARKED_CELL)
      # If you click on a tile, remove it
      $(@).remove()
      nonogram.data[pos] = EMPTY_CELL

    $('#nonogram_data').val nonogram.data.join(',')

  $('body').on 'mouseup', '[id^="cell"], [id^="tile"]', ->
    button_down = BUTTON_NOT_PRESSED

  ###
   Highligth the cell if the mouse cursor is over it
   As we're using JQuery to capture events, we also use its attr() method
   instead Raphael's one
  ###
  $('body').on 'mouseover', '[id^="cell"], [id^="tile"]', ->
    # Capture the position of the cell being handled
    pos = $(@).data 'pos'
    if button_down is MAIN_BUTTON and nonogram.data[pos] is EMPTY_CELL
      board.putTile pos, color
      nonogram.data[pos] = color
      $('#nonogram_data').val nonogram.data.join(',')
    else if nonogram.data[pos] is EMPTY_CELL
      # Highlight the cell
      $(@).attr 'fill', '#'+HIGHLIGHTED_CELL_COLOR

  $('body').on 'mouseout', '[id^="cell"], [id^="tile"]', -> 
    pos = $(@).data 'pos'
    if button_down isnt MAIN_BUTTON and nonogram.data[pos] is EMPTY_CELL
      $(@).attr 'fill', '#'+EMPTY_CELL_COLOR

  ###
   When the user wants to change the nonogram's size
  ###
  $('#size_selector').change ->
    paper.clear()
    board.board_size_in_tiles = $(@).val()
    nonogram.setSize $(@).val()
    board.render()
    $('#nonogram_data').val nonogram.data.join(',')

  $('#edit_form').submit (ev) ->
    ev.preventDefault()
    $.ajax
      url: '/save',
      type: 'POST',
      data:
        nonogram_title:  $('#nonogram_title').val()
        nonogram_size:   parseInt $('#nonogram_size').val()
        nonogram_data:   nonogram.data.join(',')
        nonogram_author: $('#nonogram_author').val()
        nonogram_level:  parseInt $('#nonogram_level').val()
        id:              $('#nonogram_id').val()
    .done (res) ->
      $('#nonogram_id').val res unless res is 'err'
      $('#messages').text 'Nonogram saved succesfully'
    .fail ->
      $('#messages').text 'Error, nonogram not saved'

    return false

