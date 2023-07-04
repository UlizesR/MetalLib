import { ChessBoard } from "./chessBoard";

export interface ChessBoard {
    board: Record<string, string | null>;
    positions: string[];
    moves: string[];

    movePiece(from: string, to: string): string;
    getPiece(position: string): string | null;
    setPiece(piece_abr: string, position: string): void;
    deletePiece(position: string): void;
    history(): string[];
    printBoard(): void;
}