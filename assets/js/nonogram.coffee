class Nonogram

  ###
   The constructor data param can be either an array containing the nonogram's values
   or an integer telling with the size per side of the empty nonogram to be created
   (for the nonogram editor)
  ###
  constructor: (input) ->
    if $.isArray input
      @data = input
      # Nonograms are always squared, so we can calculate
      # its side sizes using a square root
      @side = Math.sqrt @data.length
    else
      @.setSize(input)

  ###
   Compare a single-dimension array with the solution and check it they're equal or not
  ###
  isSolution: (arr) ->
    return false if arr.length isnt @data.length
    for i in [0...arr.length]
      # Because @data contains not only if there's a block in the position, but also its color information
      # we consider any value greather than 1 to be 1
      return false if (arr[i] is (EMPTY_CELL or MARKED_CELL) and @data[i] isnt (EMPTY_CELL or MARKED_CELL)) or (arr[i] isnt (EMPTY_CELL or MARKED_CELL) and @data[i] is EMPTY_CELL)
    true

  ###
   Return an object with the hint values both for rows and columns
   See _consecutives() method for more details
  ###
  getHintValues: ->
    h_consecutives = @._consecutives 'horizontal', ' '
    v_consecutives = @._consecutives 'vertical', '\n'

    consecutives = {h: h_consecutives, v: v_consecutives}

  ###
   Initializes the nonogram's data filling it with zeros
  ###
  setSize: (@side) ->
    @data = (EMPTY_CELL for num in [0...@side*@side])

  ###
   Calculate the consecutive tiles that are shown as hints to the player
   in each row and column at the top and left sides
   of the board
  ###
  _consecutives: (type, separator) ->
    consecutives = ('0' for num in [0...@side])
    for y in [0...@side]
      sequence_length = 0
      row = []
      # The inner loop's limits are different
      # depending if we want the hints for rows (horizontal)
      # or columns (vertical)
      start = if type is 'horizontal' then y*@side else y
      end   = if type is 'horizontal' then (y+1)*@side else @data.length
      step  = if type is 'horizontal' then 1 else @side
      for x in [start...end] by step
        if @data[x] isnt (EMPTY_CELL or MARKED_CELL)
          sequence_length++
        else
          row.push sequence_length if sequence_length > 0
          sequence_length = 0
      # If sequence_length > 0 we push its value
      # because there were tiles at the end of the row and 
      # the loop ended before adding them
      row.push sequence_length if sequence_length > 0
      consecutives[y] = row.join separator if row.length > 0

    return consecutives

window.Nonogram = Nonogram