// board = new ChessBoard();

class Piece {
    constructor(board, color) {
        this.board = board;
        this.color = color;
        this.abr = null;
        this.position = null;
    }

    getColor() {
        return this.color;
    }

    getPosition() {
        return this.position;
    }

    setPosition(position) {
        this.position = position;
    }

    legalMoves() {
        return [];
    }
}

class Pawn extends Piece {
    constructor(board, color) {
        super(board, color);
        if (this.color === 'white') {
            this.abr = 'W_P';
        } else {
            this.abr = 'B_P';
        }
    }

    legalMoves() {
        let moves = [];
        let col = this.position.charCodeAt(0) - 97;
        let row = this.position[1];

        if (this.color === 'white') {
            if (row === 6) {
                moves.push([row - 2, col]);
            }
            if (this.board.getPiece([row - 1, col]) === null) {
                moves.push([row - 1, col]);
            }
            // if right front position is occupied by a black piece, add it to moves
            // check if right front position if empty ignore, otherwise check if it is occupied by a black piece
            if (this.board.getPiece([row - 1, col + 1]) && this.board.getPiece([row - 1, col + 1]).getColor() !== this.color) {
                moves.push([row - 1, col + 1]);
            }
            // if left front position is occupied by a black piece, add it to moves
            // check if left front position if empty ignore, otherwise check if it is occupied by a black piece
            if (this.board.getPiece([row - 1, col - 1]) && this.board.getPiece([row - 1, col - 1]).getColor() !== this.color) {
                moves.push([row - 1, col - 1]);
            }
        } else {
            if (row === 1) {
                moves.push([row + 2, col]);
            }
            if (this.board.getPiece([row + 1, col]) === null) {
                moves.push([row + 1, col]);
            }
            // if right front position is occupied by a white piece, add it to moves
            // check if right front position if empty ignore, otherwise check if it is occupied by a white piece
            if (this.board.getPiece([row + 1, col + 1]) && this.board.getPiece([row + 1, col + 1]).getColor() !== this.color) {
                moves.push([row + 1, col + 1]);
            }
            // if left front position is occupied by a white piece, add it to moves
            // check if left front position if empty ignore, otherwise check if it is occupied by a white piece
            if (this.board.getPiece([row + 1, col - 1]) && this.board.getPiece([row + 1, col - 1]).getColor() !== this.color) {
                moves.push([row + 1, col - 1]);
            }
        }
        
        return moves;
    }
}

class Rook extends Piece {
    constructor(board, color) {
        super(board, color);
    }

    legalMoves() {

    }
}

class Knight extends Piece {
    constructor(board, color) {
        super(board, color);
    }

    legalMoves() {

    }
}

class Bishop extends Piece {
    constructor(board, color) {
        super(board, color);
    }

    legalMoves() {

    }
}

class Queen extends Piece {
    constructor(board, color) {
        super(board, color);
    }

    legalMoves() {

    }
}

class King extends Piece {
    constructor(board, color) {
        super(board, color);
    }

    legalMoves() {

    }
}