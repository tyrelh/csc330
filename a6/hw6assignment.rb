# Tyrel Hiebert
# Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in,
# so do not modify the other files as
# part of your solution.

require_relative './hw6graphics' # used only for challenge question

class MyPiece < Piece

  @@cheat_flag = false
  # The constant All_My_Pieces should be declared here:
  All_My_Pieces = [
    [[[0, 0], [1, 0], [0, 1], [1, 1]]],  # square (only needs one)
    rotations([[0, 0], [-1, 0], [1, 0], [0, -1]]), # T
    [
      [[0, 0], [-1, 0], [1, 0], [2, 0]], # long (only needs two)
      [[0, 0], [0, -1], [0, 1], [0, 2]]
    ],
    rotations([[0, 0], [0, -1], [0, 1], [1, 1]]), # L
    rotations([[0, 0], [0, -1], [0, 1], [-1, 1]]), # inverted L
    rotations([[0, 0], [-1, 0], [0, -1], [1, -1]]), # S
    rotations([[0, 0], [1, 0], [0, -1], [-1, -1]]), # Z
    rotations([[0, 0], [-1, 0], [-2, 0], [1, 0], [2, 0]]), # extra long
    rotations([[0, 0], [0, 1], [1, 0]]), # small L
    rotations([[0, 0], [-1, 0], [1, 0], [-1, 1], [0, 1]]) # snail
    ] 

  # Your Enhancements here

  def self.next_piece (board)
    if @@cheat_flag
      @@cheat_flag = false
      MyPiece.new([[[0, 0]]], board)
    else
      MyPiece.new(All_My_Pieces.sample, board)
    end
  end

  def self.set_cheat
    if @@cheat_flag
      @@cheat_flag = false
    else
      @@cheat_flag = true
    end
  end

  def self.cheat?
    @@cheat_flag
  end

end

class MyBoard < Board
  # Your Enhancements here:

  def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block = MyPiece.next_piece(self)
    @score = 0
    @game = game
    @delay = 500
  end

  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    (0..locations.length - 1).each{|index| 
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] = 
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end

  # rotates the current piece 180 degrees
  def rotate_180
    if !game_over? and @game.is_running?
      @current_block.move(0, 0, 2)
    end
    draw
  end

  def next_piece
    @current_block = MyPiece.next_piece(self)
    @current_pos = nil
  end

  def set_cheat
    if not MyPiece.cheat? and @score >= 100
      MyPiece.set_cheat
      @score -= 100
    end
  end

end

class MyTetris < Tetris
  # Your Enhancements here:

  def key_bindings  
    super
    @root.bind('u' , proc {@board.rotate_180})
    @root.bind('c', proc {@board.set_cheat})
  end

   # creates a canvas and the board that interacts with it
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(
      @board.block_size * @board.num_rows + 3,
      @board.block_size * @board.num_columns + 6,
      24,
      80
    )
    @board.draw
  end

  # creates and adds controls
  def buttons
    super

    cheat = TetrisButton.new('c', 'green'){@board.set_cheat}
    cheat.place(35, 50, 27, 571)

    u_turn = TetrisButton.new('u', 'green'){@board.rotate_180}
    u_turn.place(35, 50, 127, 571)
  end
end







# Challenge question section

class MyPieceChallenge < MyPiece

  def self.next_piece (board)
    MyPieceChallenge.new(All_My_Pieces.sample, board)
  end

  def cells_in_block
    @all_rotations[0].size
  end

end


class MyBoardChallenge < MyBoard

  def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block = MyPieceChallenge.next_piece(self)
    @next_block = MyPieceChallenge.next_piece(self)
    @score = 0
    @game = game
    @delay = 500
  end

  # gets the next piece
  def next_piece
    @current_block = @next_block
    if MyPiece.cheat?
      MyPiece.set_cheat
    end 
    @next_block = MyPieceChallenge.next_piece(self)
    @current_pos = nil
  end

  def draw
    @current_pos = @game.draw_piece(@current_block, @current_pos)
    @game.draw_next_piece(@next_block)
  end

  def set_cheat
    if not MyPiece.cheat? and @score >= 100
      MyPiece.set_cheat
      @score -= 100
      @next_block = MyPiece.new([[[0,0]]], self)
    end
  end

end


class MyTetrisChallenge < MyTetris

  def initialize
    @root = MyTetrisRoot.new # overrode TetrisRoot to make a larger window
    @timer = TetrisTimer.new
    set_board
    @running = true
    key_bindings
    buttons
    run_game
  end

  def self.frame_size_offset
    120
  end

  def buttons
    pause = TetrisButton.new('pause', 'lightcoral'){self.pause}
    pause.place(35, 50, 90, 7)

    new_game = TetrisButton.new('new game', 'lightcoral'){self.new_game}
    new_game.place(35, 75, 15, 7)
    
    quit = TetrisButton.new('quit', 'lightcoral'){exitProgram}
    quit.place(35, 50, 140, 7)
    
    move_left = TetrisButton.new('left', 'lightgreen'){@board.move_left}
    move_left.place(35, 50, 27, 536 + MyTetrisChallenge.frame_size_offset)
    
    move_right = TetrisButton.new('right', 'lightgreen'){@board.move_right}
    move_right.place(35, 50, 127, 536 + MyTetrisChallenge.frame_size_offset)
    
    rotate_clock = TetrisButton.new('^_)', 'lightgreen'){@board.rotate_clockwise}
    rotate_clock.place(35, 50, 77, 501 + MyTetrisChallenge.frame_size_offset)

    rotate_counter = TetrisButton.new('(_^', 'lightgreen'){
      @board.rotate_counter_clockwise}
    rotate_counter.place(35, 50, 77, 571 + MyTetrisChallenge.frame_size_offset)
    
    drop = TetrisButton.new('drop', 'lightgreen'){@board.drop_all_the_way}
    drop.place(35, 50, 77, 536 + MyTetrisChallenge.frame_size_offset)

    cheat = TetrisButton.new('c', 'green'){@board.set_cheat}
    cheat.place(35, 50, 27, 571 + MyTetrisChallenge.frame_size_offset)

    u_turn = TetrisButton.new('u', 'green'){@board.rotate_180}
    u_turn.place(35, 50, 127, 571 + MyTetrisChallenge.frame_size_offset)

    score_label = TetrisLabel.new(@root) do
      text 'Current Score: '   
      background 'lightblue'
    end
    score_label.place(35, 100, 26, 45)

    @score = TetrisLabel.new(@root) do
      background 'lightblue'
    end
    @score.text(@board.score)
    @score.place(35, 50, 126, 45)

    next_label = TetrisLabel.new(@root) do
      text 'Next Piece: '   
      background 'lightblue'
    end
    next_label.place(35, 150, 26, 45 + 35)

  end

  # creates a canvas and the board that interacts with it
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoardChallenge.new(self)
    @canvas.place(
      @board.block_size * @board.num_rows + 3,
      @board.block_size * @board.num_columns + 6,
      24,
      80 + MyTetrisChallenge.frame_size_offset
    )
    @board.draw
  end

  def canvas
    @canvas
  end

  def next_canvas
    @next_canvas
  end

  def draw_piece (piece, old=nil)
    if old != nil and piece.moved
      old.each{|block| block.remove}
    end
    size = @board.block_size
    blocks = piece.current_rotation
    start = piece.position
    blocks.map{|block| 
      TetrisRect.new(
        @canvas,
        start[0]*size + block[0]*size + 3, 
        start[1]*size + block[1]*size,
        start[0]*size + size + block[0]*size + 3, 
        start[1]*size + size + block[1]*size, 
        piece.color
      )
    }
  end

  def draw_next_piece (piece)
    # just re-place next_canvas each draw loop, yolo
    @next_canvas = TetrisCanvas.new
    @next_canvas.place(
      @board.block_size * 5,
      @board.block_size * 5,
      @board.block_size * 4,
      45 + 35 + 35
    )
    size = @board.block_size
    blocks = piece.current_rotation
    start = [2,2]
    blocks.map{|block| 
      TetrisRect.new(
        @next_canvas,
        start[0]*size + block[0]*size + 3, 
        start[1]*size + block[1]*size,
        start[0]*size + size + block[0]*size + 3, 
        start[1]*size + size + block[1]*size, 
        piece.color
      )
    }
  end
end


# Needed to override TetrisRoot to change the window dimention
# so that I could add new GUI elements
class MyTetrisRoot < TetrisRoot
  def initialize

    @root = TkRoot.new(
      'height' => 615 + MyTetrisChallenge.frame_size_offset,
      'width' => 205, 
      'background' => 'lightblue'
    ) {title "Tetris"}

    def bind(char, callback)
      @root.bind(char, callback)
    end
  
    # Necessary so we can unwrap before passing to Tk in some instances.
    # Student code MUST NOT CALL THIS.
    # attr_reader :root  # had to remove, was getting an undefined method error
  end
end