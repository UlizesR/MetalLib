

class ChessBoard {
  constructor() {
    this.board = {
      "a8": "B_R", "b8": "B_N", "c8": "B_B", "d8": "B_Q", "e8": "B_K", "f8": "B_B", "g8": "B_N", "h8": "B_R",
      "a7": "B_P", "b7": "B_P", "c7": "B_P", "d7": "B_P", "e7": "B_P", "f7": "B_P", "g7": "B_P", "h7": "B_P",
      "a6": null, "b6": null, "c6": null, "d6": null, "e6": null, "f6": null, "g6": null, "h6": null,
      "a5": null, "b5": null, "c5": null, "d5": null, "e5": null, "f5": null, "g5": null, "h5": null,
      "a4": null, "b4": null, "c4": null, "d4": null, "e4": null, "f4": null, "g4": null, "h4": null,
      "a3": null, "b3": null, "c3": null, "d3": null, "e3": null, "f3": null, "g3": null, "h3": null,
      "a2": "W_P", "b2": "W_P", "c2": "W_P", "d2": "W_P", "e2": "W_P", "f2": "W_P", "g2": "W_P", "h2": "W_P",
      "a1": "W_R", "b1": "W_N", "c1": "W_B", "d1": "W_Q", "e1": "W_K", "f1": "W_B", "g1": "W_N", "h1": "W_R"
    }
    this.positions = [
      "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",
      "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
      "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
      "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
      "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
      "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
      "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
      "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1"
    ]
    this.enPassantTarget = null;
  }

  /**
   * Takes the from and to Position of the form 'colrow' and moves the piece at the from position to the to position 
   * @param  {string} position
   * @throws {Error} No piece at position
   * @throws {Error} Illegal move
   */
  movePiece(from, to) {
    // check if there is a piece at the to position
    if (this.board[to] && this.board[from][0] === this.board[to][0]) {
      throw new Error("Illegal move");
    }

    // move piece
    this.setPiece(this.getPiece(from), to);
    this.deletePiece(from);

  }
  
  /**
   * Takes Position of the form 'colrow' and returns the piece at that position
   * @param   {string} position 
   * @throws  {Error} Invalid position
   * @returns {string} piece_abr or null
   */
  getPiece(position) {
    // check if position is valid
    if (!this.positions.includes(position)) {
      throw new Error(`Invalid position: ${position}`);
    }
    // will return null if position is empty or will return the piece value
    return this.board[position] || null;
  }

  /**
   * Takes Position of the form 'colrow' and sets the piece at that position
   * @param {Piece} piece 
   * @param {Array} position 
   * @throws {Error} Invalid position
   */
  setPiece(piece_abr, position) {
      // check if position is valid
      if (!this.positions.includes(position)) {
        throw new Error(`Invalid position: ${position}`);
      }
      // set piece to board
      this.board[position] = piece_abr;
  }

  /**
   * Takes Position of the form [col, row] and deletes the piece at that position
   * @param   {Array} position
   * @returns {string}
   * @throws  {Error} Invalid position
   * @throws  {Error} No piece at position
  */
  deletePiece(position) {
      // check if position is valid
      if (!this.positions.includes(position)) {
        throw new Error(`Invalid position: ${position}`);
      }
      if (!(this.board[position])) {
          throw new Error("No piece at position"); 
      }
      // delete piece from board and sets to null
      this.board[position] = null;
  }
  
  printBoard() {
    const rows = ['8', '7', '6', '5', '4', '3', '2', '1'];
    const cols = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    const squareWidth = 3;
    let boardStr = '';
  
    for (let row of rows) {
      boardStr += row + ' ';
      for (let col of cols) {
        const piece = this.getPiece(col + row);
        const square = piece ? piece : ' . ';
        const padding = ' '.repeat(squareWidth - square.length);
        boardStr += square + ' ' + padding;
      }
      boardStr += '\n';
    }
  
    boardStr += '   ' + cols.join(' '.repeat(squareWidth)) + '\n';
    console.log(boardStr);
  }
}

module.exports = { ChessBoard };