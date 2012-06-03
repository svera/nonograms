class Board
  HEADER_MARGIN              = 5
  BOARD_BORDER_COLOR         = '999'
  BOARD_SHADOW_COLOR         = '000'
  BOARD_SHADOW_X_OFFSET      = 8 
  BOARD_SHADOW_Y_OFFSET      = 8
  BOARD_SHADOW_SIZE          = 2
  BOARD_SHADOW_RADIUS        = 0
  ODD_HINT_BACKGROUND_COLOR  = 'fff'
  EVEN_HINT_BACKGROUND_COLOR = 'ccc'


  ###
   x0, y0 = Origin coordinates of board (top left corner)
  ###
  constructor: (@paper, @x0, @y0, @maximum_board_size_in_pixels, @nonogram) ->

  ###
   Put a tile on the specified cell of the board with the current color
  ###
  putTile: (pos, color='000') ->
    [x, y] = @._pos2Coord pos
    # If we click on a board cell, create a tile and put it on it
    tile = @paper.rect x, y, @tile_size, @tile_size
    tile.attr 'fill', '#'+color
    # Bug in chrome that ignores stroke-width = 0
    tile.attr 'stroke-width', 0.01
    tile.node.id = "tile#{pos}"
    # Custom attributes to identify the tile
    # We use HTML5 'data-' attributes
    $(tile.node).attr 'data-pos', pos

  ###
   Put a mark on the specified cell of the board
  ###
  putMark: (pos) ->
    [x, y] = @._pos2Coord pos
    delta = Math.floor (@cell_size-@mark_size)/2
    x = x+delta
    y = y+delta
    mark = @paper.path("M#{x},#{y}L#{x+@mark_size},#{y+@mark_size}M#{x},#{y+@mark_size}L#{x+@mark_size},#{y}").attr({'fill': "none", 'stroke-width': 6, 'stroke-linecap': 'round'})
    mark.node.id = "mark#{pos}"
    # Custom attribute to identify the mark
    $(mark.node).attr 'data-pos', pos

  ###
   Draw board
  ###
  render: (hints=null, show_solution=false) ->
    @._calculateSizes()
    # Draw an empty box that casts the board's shadow
    shadow_caster = @paper.rect @x0, @y0, @board_size_in_pixels, @board_size_in_pixels
    shadow_caster.attr 'fill', '#fff'
    shadow_caster.shadow BOARD_SHADOW_X_OFFSET, BOARD_SHADOW_Y_OFFSET, BOARD_SHADOW_SIZE, BOARD_SHADOW_COLOR, BOARD_SHADOW_RADIUS
    # Draw board's cells
    for y in [0...@nonogram.side]
      for x in [0...@nonogram.side]
        pos = (y*@nonogram.side)+x
        cell = @paper.rect (x*@cell_size)+@x0, (y*@cell_size)+@y0, @cell_size, @cell_size
        # We use custom attributes to identify what is the position of the cell in the array
        cell.node.id = "cell#{pos}"
        $(cell.node).attr 'data-pos', pos
        # Click event only works if rect has a fill set
        # We use the attr() method of Raphael to set that property
        cell.attr 'fill', '#fff'
        cell.attr 'stroke', '#'+BOARD_BORDER_COLOR
        if show_solution and @nonogram.data[pos] isnt EMPTY_CELL
          @.putTile pos, @nonogram.data[pos]

        # Put a stronger line every X lines to help an easier visualization of the board
        v_separator = @paper.path "M #{(x*@cell_size)+@x0} #{@y0} l 0 #{@board_size_in_pixels}" if x > 0 and x%5 is 0
        h_separator = @paper.path "M #{@x0} #{(y*@cell_size)+@y0} l #{@board_size_in_pixels} 0" if y > 0 and y%5 is 0
      if hints
        background_color = if y%2 > 0 then EVEN_HINT_BACKGROUND_COLOR else ODD_HINT_BACKGROUND_COLOR
        @._drawRowHints    hints.h[y], y*@cell_size, background_color
        @._drawColumnHints hints.v[y], y*@cell_size, background_color

    # Finally, we put a border on the board
    border = @paper.rect @x0, @y0, @board_size_in_pixels, @board_size_in_pixels


  ###
   Draw header with the hints for the rows
   hints = array with the values to write on the row
  ###
  _drawRowHints: (hints, y, background_color) ->
    # The we create the hints row on top of the rect
    text = @paper.text @x0-HEADER_MARGIN, y+@y0+(Math.ceil(@tile_size)/2), hints
    # We align the row hints to the right
    text.attr {'text-anchor': 'end'}
    text.attr {'font-size': "#{@hint_font_size}px"}
    if background_color isnt 'fff'
      back = @._setHintBackground @x0-@hint_background_size, y+@y0, @hint_background_size, @cell_size, background_color
      # Put the text back to the foreground
      back.toBack()

  ###
   Draw header with the hints for the columns
   hints = array with the values to write on the column
  ###
  _drawColumnHints: (hints, x, background_color) ->
    text       = @paper.text x+@x0+(Math.ceil(@tile_size)/2), @y0-HEADER_MARGIN, hints
    text.attr {'font-size': "#{@hint_font_size}px"}
    # We align the column hints to the bottom
    dimensions = text.getBBox()
    offset     = dimensions.height/2
    text.transform "t0, -#{offset}"
    if background_color isnt 'fff'
      back = @._setHintBackground x+@x0, @y0-@hint_background_size, @cell_size, @hint_background_size, background_color
      # Put the text back to the foreground
      back.toBack()

  ###
   Calculate the coordinates of a board cell from its position in the array
  ###
  _pos2Coord: (pos) ->
    # We put the tile centered on the board cell
    # to do that, we must calculate how many pixels we should offset from the cell's origin coordinates
    offset = (@cell_size-@tile_size) / 2
    # Calc the coordinates of the cell being handled from its position
    x = ((pos%@nonogram.side)*@cell_size)+@x0+offset
    y = (Math.floor(pos/@nonogram.side)*@cell_size)+@y0+offset
    return [x, y]

  ###
   Calculate the sizes of all the elements that are in the board
  ###
  _calculateSizes: ->
    # Board cell size (in pixels)
    @cell_size = Math.floor @maximum_board_size_in_pixels/@nonogram.side
    @board_size_in_pixels = @cell_size*@nonogram.side
    # Tile size (in pixels)
    @tile_size = @cell_size-2
    # Tile size (in pixels)
    @mark_size = @cell_size-16
    # Hint font size (in pixels)
    @hint_font_size = Math.floor @cell_size/2
    # Calculate the hint background length based on a certain percentage of the board size
    @hint_background_size =  Math.floor @board_size_in_pixels*.60

  ###
   Puts a color background under the hints
  ###
  _setHintBackground: (x, y, width, height, color) ->
    # Background for horizontal text (rows)
    background = @paper.rect x, y, width, height
    background.attr {'stroke': 'none'}
    # Depending on rectangle's orientation, we set a gradient type or another
    if width > height
      background.attr {'fill': '0-#fff-#'+color}
    else
      background.attr {'fill': '270-#fff-#'+color}

   
window.Board = Board