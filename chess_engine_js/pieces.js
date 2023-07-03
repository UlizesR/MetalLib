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
        let col = this.position[0];
        let col_num = this.position.charCodeAt(0) - 97;
        let row = this.position[1];

        if (this.color === 'white') {
            // check for pawn at starting position (row 2) and no pieces in front of it
            // if so, add the position two spaces in front of the pawn to the moves array
            if (row === 2 && !this.board.getPiece(`${col}${row + 1}`) && !this.board.getPiece(`${col}${row + 2}`)) {
                moves.push(`${col}${row + 2}`);
            }
            // check if there is a piece in front of the pawn
            // if not, add the position to the moves array
            if (!this.board.getPiece(`${col}${row + 1}`)) {
                moves.push(`${col}${row + 1}`);
            }
            // check if there is an opponent piece diagonally to the right of the pawn
            // if so, add the position to the moves array
            if (this.board.getPiece(`${String.fromCharCode(col_num + 1)}${row + 1}`) && 
                this.board.getPiece(`${String.fromCharCode(col_num + 1)}${row + 1}`)[0] === 'B') {
                moves.push(`${String.fromCharCode(col_num + 1)}${row + 1}`);
            }
            // check if there is an opponent piece diagonally to the left of the pawn
            // if so, add the position to the moves array
            if (this.board.getPiece(`${String.fromCharCode(col_num - 1)}${row + 1}`) && 
                this.board.getPiece(`${String.fromCharCode(col_num - 1)}${row + 1}`)[0] === 'B') {
                moves.push(`${String.fromCharCode(col_num - 1)}${row + 1}`);
            }
            // check if there is an opponent piece en passant to the right of the pawn
            // if so, add the position to the moves array


            moves.push(`${col}${row + 1}`);
        } else {
            if (row === 7) {
                moves.push(`${col}${row - 2}`);
            }
            // check if there is a piece in front of the pawn
            // if not, add the position to the moves array
            if (!this.board.getPiece(`${col}${row - 1}`)) {
                moves.push(`${col}${row - 1}`);
            }
            // check if there is an opponent piece diagonally to the right of the pawn
            // if so, add the position to the moves array
            if (this.board.getPiece(`${String.fromCharCode(col_num + 1)}${row - 1}`) &&
                this.board.getPiece(`${String.fromCharCode(col_num + 1)}${row - 1}`)[0] === 'W') {
                moves.push(`${String.fromCharCode(col_num + 1)}${row - 1}`);
            }
            // check if there is an opponent piece diagonally to the left of the pawn   
            // if so, add the position to the moves array
            if (this.board.getPiece(`${String.fromCharCode(col_num - 1)}${row - 1}`) &&
                this.board.getPiece(`${String.fromCharCode(col_num - 1)}${row - 1}`)[0] === 'W') {
                moves.push(`${String.fromCharCode(col_num - 1)}${row - 1}`);
            }
        }
        
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
        let moves = [];
        let col = this.position[0];
        let col_num = this.position.charCodeAt(0) - 97;
        let row_num = parseInt(this.position[1]);

        if (this.color === 'white') {
            // check for moves to the right
            for (let i = col_num + 1; i < 8; i++) {
                if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)) {
                    if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)[0] === 'B') {
                        moves.push(`${String.fromCharCode(i)}${row_num}`);
                    }
                    break;
                }
                moves.push(`${String.fromCharCode(i)}${row_num}`);
            }

            // check for moves to the left
            for (let i = col_num - 1; i >= 0; i--) {
                if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)) {
                    if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)[0] === 'B') {
                        moves.push(`${String.fromCharCode(i)}${row_num}`);
                    }
                    break;
                }
                moves.push(`${String.fromCharCode(i)}${row_num}`);
            }

            // check for moves to the top
            for (let i = row_num + 1; i < 9; i++) {
                if (this.board.getPiece(`${col}${i}`)) {
                    if (this.board.getPiece(`${col}${i}`)[0] === 'B') {
                        moves.push(`${col}${i}`);
                    }
                    break;
                }
                moves.push(`${col}${i}`);
            }

            // check for moves to the bottom
            for (let i = row_num - 1; i >= 0; i--) {
                if (this.board.getPiece(`${col}${i}`)) {
                    if (this.board.getPiece(`${col}${i}`)[0] === 'B') {
                        moves.push(`${col}${i}`);
                    }
                    break;
                }
                moves.push(`${col}${i}`);
            }
        } else {
            // check for moves to the right
            for (let i = col_num + 1; i < 8; i++) {
                if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)) {
                    if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)[0] === 'W') {
                        moves.push(`${String.fromCharCode(i)}${row_num}`);
                    }
                    break;
                }
                moves.push(`${String.fromCharCode(i)}${row_num}`);
            }

            // check for moves to the left
            for (let i = col_num - 1; i >= 0; i--) {
                if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)) {
                    if (this.board.getPiece(`${String.fromCharCode(i)}${row_num}`)[0] === 'W') {
                        moves.push(`${String.fromCharCode(i)}${row_num}`);
                    }
                    break;
                }
                moves.push(`${String.fromCharCode(i)}${row_num}`);
            }

            // check for moves to the top
            for (let i = row_num + 1; i < 9; i++) {
                if (this.board.getPiece(`${col}${i}`)) {
                    if (this.board.getPiece(`${col}${i}`)[0] === 'W') {
                        moves.push(`${col}${i}`);
                    }
                    break;
                }
                moves.push(`${col}${i}`);
            }

            // check for moves to the bottom
            for (let i = row_num - 1; i >= 0; i--) {
                if (this.board.getPiece(`${col}${i}`)) {
                    if (this.board.getPiece(`${col}${i}`)[0] === 'W') {
                        moves.push(`${col}${i}`);
                    }
                    break;
                }
                moves.push(`${col}${i}`);
            }
        }  

        return moves;
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
        let moves = [];
        let col = this.position[0];
        let col_num = this.position.charCodeAt(0) - 97;
        let row_num = parseInt(this.position[1]);

        let upsideDownL_R = this.board.getPiece(`${String.fromCharCode(col_num + 1)}${row_num + 2}`) // 2 up 1 right
        let upsideDownL_L = this.board.getPiece(`${String.fromCharCode(col_num - 1)}${row_num + 2}`) // 2 up 1 left
        let flatL_U_R     = this.board.getPiece(`${String.fromCharCode(col_num + 2)}${row_num + 1}`) // 1 up 2 right
        let flatL_U_L     = this.board.getPiece(`${String.fromCharCode(col_num - 2)}${row_num + 1}`) // 1 up 2 left
        let flatL_D_R     = this.board.getPiece(`${String.fromCharCode(col_num + 2)}${row_num - 1}`) // 1 down 2 right
        let flatL_D_L     = this.board.getPiece(`${String.fromCharCode(col_num - 2)}${row_num - 1}`) // 1 down 2 left
        let regularL_R    = this.board.getPiece(`${String.fromCharCode(col_num + 1)}${row_num - 2}`) // 2 down 1 right
        let regularL_L    = this.board.getPiece(`${String.fromCharCode(col_num - 1)}${row_num - 2}`) // 2 down 1 left



        if (this.color === 'white') {
            // check for moves to the top
            if ((!upsideDownL_R || upsideDownL_R[0] === 'B') && upsideDownL_R !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num + 1)}${row_num + 2}`);
            }
            if ((!upsideDownL_L || upsideDownL_L[0] === 'B') && upsideDownL_L !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num - 1)}${row_num + 2}`);
            }
            if ((!flatL_U_R || flatL_U_R[0] === 'B') && flatL_U_R !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num + 2)}${row_num + 1}`);
            }
            if ((!flatL_U_L || flatL_U_L[0] === 'B') && flatL_U_L !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num - 2)}${row_num + 1}`);
            }
            if ((!flatL_D_R || flatL_D_R[0] === 'B') && flatL_D_R !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num + 2)}${row_num - 1}`);
            }
            if ((!flatL_D_L || flatL_D_L[0] === 'B') && flatL_D_L !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num - 2)}${row_num - 1}`);
            }
            if ((!regularL_R || regularL_R[0] === 'B') && regularL_R !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num + 1)}${row_num - 2}`);
            }
            if ((!regularL_L || regularL_L[0] === 'B') && regularL_L !== "Invalid Position") {
                moves.push(`${String.fromCharCode(col_num - 1)}${row_num - 2}`);
            }
            
        } else {

        }

        return moves;
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