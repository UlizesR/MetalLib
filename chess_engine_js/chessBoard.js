

class ChessBoard {
    constructor() {
        // 0 = white, 1 = black
        this.board = [
            ["B_R", "B_N", "B_B", "B_Q", "B_K", "B_B", "B_N", "B_R"],
            ["B_P", "B_P", "B_P", "B_P", "B_P", "B_P", "B_P", "B_P"],
            [null, null, null, null, null, null, null, null],
            [null, null, null, null, null, null, null, null],
            [null, null, null, null, null, null, null, null],
            [null, null, null, null, null, null, null, null],
            ["W_P", "W_P", "W_P", "W_P", "W_P", "W_P", "W_P", "W_P"],
            ["W_R", "W_N", "W_B", "W_Q", "W_K", "W_B", "W_N", "W_R"]
        ];
        this.enPassantTarget = null;
    }

    /**
     * Takes the from and to Position of the form 'colrow' and moves the piece at the from position to the to position 
     * @param {string} position
     * @throws {Error} No piece at position
     * @throws {Error} Illegal move
     */

    movePiece(from, to) {
        const piece = this.getPiece(from);
    
        if (!piece) {
          throw new Error("No piece at position");
        }
    
        const legalMoves = piece.legalMoves();
    
        if (!legalMoves.some(move => move[0] === to[0] && move[1] === to[1])) {
          throw new Error("Illegal move");
        }
    
        // Check for en passant capture
        if (piece instanceof Pawn && Math.abs(from[1] - to[1]) === 2) {
          this.enPassantTarget = [(from[0] + to[0]) / 2, from[1]];
        } else {
          this.enPassantTarget = null;
        }
    
        // Move the piece
        this.setPiece(piece, to);
        this.deletePiece(from);
    
        // Check for pawn promotion
        if (piece instanceof Pawn && (to[1] === 0 || to[1] === 7)) {
          this.setPiece(new Queen(piece.getColor(), to), to);
        }
      }

    /**
     * Takes Position of the form 'colrow' and returns the piece at that position
     * @param {string} position 
     * @returns {string}
     */
    getPiece(position) {
        const col = position.charCodeAt(0) - 97; // Convert column character to numeric index
        const row = position[1] - 1; // Convert row character to numeric index

        if (!(row >= 0 && row < 8 && col >= 0 && col < 8)) {
            throw new Error("Invalid position"); // Throw an exception for invalid positions
        }

        // will return null if position is empty or will return the piece value
        return this.board[row][col];
    }

    /**
     * Takes Position of the form 'colrow' and sets the piece at that position
     * @param {Piece} piece 
     * @param {Array} position 
     */
    setPiece(piece_abr, position) {
        const col = position.charCodeAt(0) - 97; // Convert column character to numeric index
        const row = position[1] - 1; // Convert row character to numeric index

        if (!(row >= 0 && row < 8 && col >= 0 && col < 8)) {
            throw new Error("Invalid position"); // Throw an exception for invalid positions
        }

        // set piece to board
        this.board[row][col] = piece_abr;
    }

    /**
     * Takes Position of the form [col, row] and deletes the piece at that position
     * @param {Array} position
     * @returns {string}
     * @throws {Error} Invalid position
     * @throws {Error} No piece at position
    */
    deletePiece(position) {
        const col = position.charCodeAt(0) - 97; // Convert column character to numeric index
        const row = position[1] - 1; // Convert row character to numeric index

        if (!(row >= 0 && row < 8 && col >= 0 && col < 8)) {
            throw new Error("Invalid position"); // Throw an exception for invalid positions
        }
        if (!(this.board[row][col])) {
            throw new Error("No piece at position"); // Throw an exception for invalid positions
        }
        // delete piece from board and sets to null
        this.board[row][col] = null;
    }
  
    printBoard() {
      for (let i = 0; i < this.board.length; i++) {
        console.log(this.board[i]);
      }
    }
  }
  