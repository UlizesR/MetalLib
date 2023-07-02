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
            if (row === '2') {
                moves.push([col, row + 2]);
            }
            moves.push([col, row + 1]);
        } else {}
        
        return moves;
    }
}

class Rook extends Piece {
    constructor(board, color) {
        super(board, color);
        if (this.color === 'white') {
            this.abr = 'W_R';
        } else {
            this.abr = 'B_R';
        }
    }

    legalMoves() {

    }
}

class Knight extends Piece {
    constructor(board, color) {
        super(board, color);
        if (this.color === 'white') {
            this.abr = 'W_K';
        } else {
            this.abr = 'B_K';
        }
    }

    legalMoves() {

    }
}

class Bishop extends Piece {
    constructor(board, color) {
        super(board, color);
        if (this.color === 'white') {
            this.abr = 'W_B';
        } else {
            this.abr = 'B_B';
        }
    }

    legalMoves() {

    }
}

class Queen extends Piece {
    constructor(board, color) {
        super(board, color);
        if (this.color === 'white') {
            this.abr = 'W_Q';
        } else {
            this.abr = 'B_Q';
        }
    }

    legalMoves() {

    }
}

class King extends Piece {
    constructor(board, color) {
        super(board, color);
        if (this.color === 'white') {
            this.abr = 'W_K';
        } else {
            this.abr = 'B_K';
        }
    }

    legalMoves() {

    }
}