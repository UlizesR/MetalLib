import { ChessBoard } from "./chessBoard";
import { Piece } from "./pieces";

export interface Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    getColor(): string;
    getPosition(): string;
    setPosition(position: string): void;
    movePiece(to: string): void;
}

export interface Pawn extends Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    legalMoves(): string[];
}

export interface Rook extends Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    legalMoves(): string[];
}

export interface Knight extends Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    legalMoves(): string[];
}

export interface Bishop extends Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    legalMoves(): string[];
}

export interface Queen extends Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    legalMoves(): string[];
}

export interface King extends Piece {
    board: ChessBoard;
    color: string;
    position: string | null;
    name: string | null;
    abr: string | null;

    legalMoves(): string[];
}