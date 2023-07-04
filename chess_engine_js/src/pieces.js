// board = new ChessBoard();

class Piece {
  constructor(board, color, position) {
    this.board = board;     // ChessBoard object
    this.color = color;     // "W" or "B"
    this.abr = null;        // "W_P" or "B_P"
    this.name = null;       // "Pawn" or "Rook"
    this.position = position;   // "a1" or "h8"
  }

  /**
   * Returns the color of the piece
   * @returns {string} color
   */
  getColor() {
    return this.color;
  }
  
  /**
   * Returns the position of the piece
   * @returns {string} position
   */
  getPosition() {
    return this.position;
  }

  /**
   * Sets the position of the piece
   * @param {string} position
   */
  setPosition(position) {
    this.position = position;
  }

  /**
   * Returns the abbreviation of the piece
   * @returns {string} to position
   */ 
  movePiece(to) {
    this.board.movePiece(this.position, to);
    this.position = to;
  }
}

class Pawn extends Piece {
    constructor(board, color, position) {
        super(board, color, position);
        this.name = 'Pawn';
        if (this.color === 'W') {
            this.abr = 'W_P';
        } else {
            this.abr = 'B_P';
        }
    }

    legalMoves() {
        const moves = [];
        const row_num = parseInt(this.position[1]);
        const charCode = this.position.charCodeAt(0);
        
        if (this.color === 'W') {
          // check for front position moves
          if (!this.board.getPiece(`${this.position[0]}${row_num + 1}`)) {
            moves.push(`${this.position[0]}${row_num + 1}`);
            // check for starting position moves
            if (row_num === 2 && !this.board.getPiece(`${this.position[0]}${row_num + 2}`)) {
              moves.push(`${this.position[0]}${row_num + 2}`);
            }
          }
          // check for diagonal position moves
          // check for left diagonal
          if (this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num + 1}`)?.[0] === 'B') {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num + 1}`);
          }
          // check for right diagonal
          if (this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num + 1}`)?.[0] === 'B') {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num + 1}`);
          }
          // check for en passant
          const leftPiece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num}`);
          const rightPiece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num}`);
          if (leftPiece?.[0] === 'B' && leftPiece[1] === 7) {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num + 1}`);
          }
          if (rightPiece?.[0] === 'B' && rightPiece[1] === 7) {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num + 1}`);
          }
        } else {
          // check for front position moves
          if (!this.board.getPiece(`${this.position[0]}${row_num - 1}`)) {
            moves.push(`${this.position[0]}${row_num - 1}`);
            // check for starting position moves
            if (row_num === 7 && !this.board.getPiece(`${this.position[0]}${row_num - 2}`)) {
              moves.push(`${this.position[0]}${row_num - 2}`);
            }
          }
          // check for diagonal position moves
          // check for left diagonal
          if (this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num - 1}`)?.[0] === 'W') {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num - 1}`);
          }
          // check for right diagonal
          if (this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num - 1}`)?.[0] === 'W') {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num - 1}`);
          }
          // check for en passant
          const leftPiece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num}`);
          const rightPiece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num}`);
          if (leftPiece?.[0] === 'W' && leftPiece[1] === 2) {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num - 1}`);
          }
          if (rightPiece?.[0] === 'W' && rightPiece[1] === 2) {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num - 1}`);
          }
        }

        return moves;
    }
}

class Rook extends Piece {
    constructor(board, color, position) {
        super(board, color, position);
        this.name = 'Rook';
        if (this.color === 'W') {
            this.abr = 'W_R';
        } else {
            this.abr = 'B_R';
        }
    }

    legalMoves() {
        const moves = [];
        const row_num = parseInt(this.position[1]);
        const charCode = this.position.charCodeAt(0);

        // check for moves to the right
        for (let i = charCode + 1; i <= 104; i++) {
            const piece = this.board.getPiece(`${String.fromCharCode(i)}${row_num}`);
            if (piece && piece[0] === this.color) {
                break;
            } else if (piece && piece[0] !== this.color) {
                moves.push(`${String.fromCharCode(i)}${row_num}`);
                break;
            } else {
                moves.push(`${String.fromCharCode(i)}${row_num}`);
            }
        }
        // check for moves to the left
        for (let i = charCode - 1; i >= 97; i--) {
            const piece = this.board.getPiece(`${String.fromCharCode(i)}${row_num}`);
            if (piece && piece[0] === this.color) {
                break;
            } else if (piece && piece[0] !== this.color) {
                moves.push(`${String.fromCharCode(i)}${row_num}`);
                break;
            } else {
                moves.push(`${String.fromCharCode(i)}${row_num}`);
            }
        }
        // check for moves to the top
        for (let i = row_num + 1; i <= 8; i++) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode)}${i}`);
            if (piece && piece[0] === this.color) {
                break;
            } else if (piece && piece[0] !== this.color) {
                moves.push(`${String.fromCharCode(charCode)}${i}`);
                break;
            } else {
                moves.push(`${String.fromCharCode(charCode)}${i}`);
            }
        }
        // check for moves to the bottom
        for (let i = row_num - 1; i >= 1; i--) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode)}${i}`);
            if (piece && piece[0] === this.color) {
                break;
            } else if (piece && piece[0] !== this.color) {
                moves.push(`${String.fromCharCode(charCode)}${i}`);
                break;
            } else {
                moves.push(`${String.fromCharCode(charCode)}${i}`);
            }
        }

        return moves;
    }
}

class Knight extends Piece {
    constructor(board, color, position) {
        super(board, color, position);
        this.name = 'Knight';
        if (this.color === 'W') {
            this.abr = 'W_K';
        } else {
            this.abr = 'B_K';
        }
    }

    legalMoves() {
        const moves = [];
        const row_num = parseInt(this.position[1]);
        const charCode = this.position.charCodeAt(0);
      
        // check for moves to the right
        if (charCode <= 102) {
          // check for moves to the right and up
          if (row_num <= 6) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num + 2}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode + 1)}${row_num + 2}`);
            }
          }
          // check for moves to the right and down
          if (row_num >= 3) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num - 2}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode + 1)}${row_num - 2}`);
            }
          }
          // check for moves to the right and up
          if (row_num <= 7) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode + 2)}${row_num + 1}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode + 2)}${row_num + 1}`);
            }
          }
          // check for moves to the right and down
          if (row_num >= 2) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode + 2)}${row_num - 1}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode + 2)}${row_num - 1}`);
            }
          }
        }
        // check for moves to the left
        if (charCode >= 99) {
          // check for moves to the left and up
          if (row_num <= 6) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num + 2}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode - 1)}${row_num + 2}`);
            }
          }
          // check for moves to the left and down
          if (row_num >= 3) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num - 2}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode - 1)}${row_num - 2}`);
            }
          }
          // check for moves to the left and up
          if (row_num <= 7) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode - 2)}${row_num + 1}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode - 2)}${row_num + 1}`);
            }
          }
          // check for moves to the left and down
          if (row_num >= 2) {
            const piece = this.board.getPiece(`${String.fromCharCode(charCode - 2)}${row_num - 1}`);
            if (!piece || piece[0] !== this.color[0]) {
              moves.push(`${String.fromCharCode(charCode - 2)}${row_num - 1}`);
            }
          }
        }
      
        return moves;
    }
}

class Bishop extends Piece {
    constructor(board, color, position) {
        super(board, color, position);
        this.name = 'Bishop';
        if (this.color === 'W') {
            this.abr = 'W_B';
        } else {
            this.abr = 'B_B';
        }
    }

    legalMoves() {
        const moves = [];
        const row_num = parseInt(this.position[1]);
        const charCode = this.position.charCodeAt(0);
      
        // check for moves to the top-right
        for (let i = 1; i <= Math.min(8 - row_num, 104 - charCode); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + i)}${row_num + i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num + i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num + i}`);
          }
        }
        // check for moves to the top-left
        for (let i = 1; i <= Math.min(8 - row_num, charCode - 97); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - i)}${row_num + i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num + i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num + i}`);
          }
        }
        // check for moves to the bottom-right
        for (let i = 1; i <= Math.min(row_num - 1, 104 - charCode); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + i)}${row_num - i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num - i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num - i}`);
          }
        }
        // check for moves to the bottom-left
        for (let i = 1; i <= Math.min(row_num - 1, charCode - 97); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - i)}${row_num - i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num - i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num - i}`);
          }
        }
      
        return moves;
    }
}

class Queen extends Piece {
    constructor(board, color, position) {
        super(board, color, position);
        this.name = 'Queen';
        if (this.color === 'W') {
            this.abr = 'W_Q';
        } else {
            this.abr = 'B_Q';
        }
    }

    legalMoves() {
        const moves = [];
        const row_num = parseInt(this.position[1]);
        const charCode = this.position.charCodeAt(0);
      
        // check for moves to the right
        for (let i = charCode + 1; i <= 104; i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(i)}${row_num}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(i)}${row_num}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(i)}${row_num}`);
          }
        }
        // check for moves to the left
        for (let i = charCode - 1; i >= 97; i--) {
          const piece = this.board.getPiece(`${String.fromCharCode(i)}${row_num}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(i)}${row_num}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(i)}${row_num}`);
          }
        }
        // check for moves to the top
        for (let i = row_num + 1; i <= 8; i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode)}${i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode)}${i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode)}${i}`);
          }
        }
        // check for moves to the bottom
        for (let i = row_num - 1; i >= 1; i--) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode)}${i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode)}${i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode)}${i}`);
          }
        }
        // check for moves to the top-right
        for (let i = 1; i <= Math.min(8 - row_num, 104 - charCode); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + i)}${row_num + i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num + i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num + i}`);
          }
        }
        // check for moves to the top-left
        for (let i = 1; i <= Math.min(8 - row_num, charCode - 97); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - i)}${row_num + i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num + i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num + i}`);
          }
        }
        // check for moves to the bottom-right
        for (let i = 1; i <= Math.min(row_num - 1, 104 - charCode); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + i)}${row_num - i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num - i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode + i)}${row_num - i}`);
          }
        }
        // check for moves to the bottom-left
        for (let i = 1; i <= Math.min(row_num - 1, charCode - 97); i++) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - i)}${row_num - i}`);
          if (piece && piece[0] === this.color[0]) {
            break;
          } else if (piece && piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num - i}`);
            break;
          } else {
            moves.push(`${String.fromCharCode(charCode - i)}${row_num - i}`);
          }
        }
      
        return moves;
    }
}

class King extends Piece {
    constructor(board, color, position) {
        super(board, color, position);
        this.name = 'King';
        if (this.color === 'W') {
            this.abr = 'W_K';
        } else {
            this.abr = 'B_K';
        }
    }

    legalMoves() {
        const moves = [];
        const row_num = parseInt(this.position[1]);
        const charCode = this.position.charCodeAt(0);
      
        // check for moves to the right
        if (charCode < 104) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num}`);
          }
        }
        // check for moves to the left
        if (charCode > 97) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num}`);
          }
        }
        // check for moves to the top
        if (row_num < 8) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode)}${row_num + 1}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode)}${row_num + 1}`);
          }
        }
        // check for moves to the bottom
        if (row_num > 1) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode)}${row_num - 1}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode)}${row_num - 1}`);
          }
        }
        // check for moves to the top-right
        if (charCode < 104 && row_num < 8) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num + 1}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num + 1}`);
          }
        }
        // check for moves to the top-left
        if (charCode > 97 && row_num < 8) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num + 1}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num + 1}`);
          }
        }
        // check for moves to the bottom-right
        if (charCode < 104 && row_num > 1) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode + 1)}${row_num - 1}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode + 1)}${row_num - 1}`);
          }
        }
        // check for moves to the bottom-left
        if (charCode > 97 && row_num > 1) {
          const piece = this.board.getPiece(`${String.fromCharCode(charCode - 1)}${row_num - 1}`);
          if (!piece || piece[0] !== this.color[0]) {
            moves.push(`${String.fromCharCode(charCode - 1)}${row_num - 1}`);
          }
        }
      
        return moves;
    }
}

module.exports = {
    Pawn,
    Rook,
    Knight,
    Bishop,
    Queen,
    King
};