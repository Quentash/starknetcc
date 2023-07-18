#[system]
mod generate_moves {
    use array::ArrayTrait;
    use dojo_chess::components::{Piece, Position, PieceColor};

    fn is_out_of_bounds(new_pos: Position) -> bool {
        if new_pos.x > 7 || new_pos.x < 0 {
            return true;
        }
        if new_pos.y > 7 || new_pos.y < 0 {
            return true;
        }
        false
    }

    fn is_occupied_by_ally(
        new_pos: Position, board: Span<Span<Option<Piece>>>, player_color: PieceColor
    ) -> bool {
        let maybe_piece = *(*board.at(new_pos.x)).at(new_pos.y);
        let piece_color = match maybe_piece {
            Option::Some(piece) => piece.color,
            Option::None(_) => {
                return false;
            },
        };
        let is_occupied = match piece_color {
            PieceColor::White(_) => {
                match player_color {
                    PieceColor::White(_) => true,
                    PieceColor::Black(_) => false,
                }
            },
            PieceColor::Black(_) => {
                match player_color {
                    PieceColor::White(_) => false,
                    PieceColor::Black(_) => true,
                }
            },
        };
        is_occupied
    }

    fn is_occupied_by_enemy(
        new_pos: Position, board: Span<Span<Option<Piece>>>, player_color: PieceColor
    ) -> bool {
        return !is_occupied_by_ally(new_pos, board, player_color);
    }

    fn is_occupied(new_pos: Position, board: Span<Span<Option<Piece>>>) -> bool {
        let piece = *(*board.at(new_pos.x)).at(new_pos.y);
        return piece.is_some();
    }


    fn possible_moves(
    piece: Piece, position: Position, board: Span<Span<Option<Piece>>>
) -> Span<(Position, Option<felt252>)> {
    let mut moves = array::ArrayTrait::new();
    let is_white = match piece.color {
        PieceColor::White(_) => 1_u32,
        PieceColor::Black(_) => 0_u32,
    };
    
    let directions: [(i32, i32); 2] = if piece.crowned {
        [(1, 1), (1, -1), (-1, 1), (-1, -1)] // Crowned pieces can move both forward and backward diagonally
    } else {
        if is_white == 1_u32 {
            [(1, -1), (1, 1)] // White pieces move upwards on the board, which can be (1, -1) or (1, 1)
        } else {
            [(-1, -1), (-1, 1)] // Black pieces move downwards on the board, which can be (-1, -1) or (-1, 1)
        }
    };

    for direction in directions.iter() {
        let new_pos = Position {
            x: position.x + direction.0, 
            y: position.y + direction.1,
        };
        if !is_out_of_bounds(new_pos) && !is_occupied(new_pos, board) {
            moves.append((new_pos, Option::None(())));
        }
        
        // Here we are assuming that the capturing move in checkers is done by skipping over the enemy piece
        // to the immediate next square (which should be empty for the capturing move to be valid).
        let new_pos_capture = Position {
            x: position.x + 2 * direction.0, 
            y: position.y + 2 * direction.1,
        };
        if !is_out_of_bounds(new_pos_capture) && !is_occupied(new_pos_capture, board) && is_occupied_by_enemy(new_pos, board, piece.color) {
            moves.append((new_pos_capture, Option::Some(piece.piece_id)));
        }
    }

    return moves.span();
}


#[cfg(test)]
mod tests {
    use dojo_chess::components::{Piece, Position, PieceColor};
    use super::generate_moves;
    use array::ArrayTrait;
    use array::SpanTrait;

    fn fixture_board() -> Span<Span<Option<Piece>>> {
        let mut board: Array<Span<Option<Piece>>> = array::ArrayTrait::new();
        // loop 64 times to create a 8x8 board
        let mut i = 0_usize;
        let mut arr: Array<Option<Piece>> = array::ArrayTrait::new();
        loop {
            if i == 64 {
                break;
            }
            if i % 8 == 0 && i > 0 {
                board.append(arr.span());
                arr = array::ArrayTrait::new();
            }
            arr.append(Option::None(()));
            i += 1;
        };
        board.span()
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_possible_simple_piece_moves() {
        let piece = Piece {
            color: PieceColor::White(()),
            is_alive: true,
            piece_id: 'white_1',
            crowned: false,
        };
        let position = Position { x: 0, y: 5 };
        // TODO: Replace empty board with Fixture Board
        let board = fixture_board();
        let moves = generate_moves::possible_moves(piece, position, board);
        let (move, _) = *moves.at(0);
        assert(move == Position { x: 0, y: 6 }, 'White Piece step 1 forward');
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_possible_crowned_piece_moves() {
        let piece = Piece {
            color: PieceColor::White(()),
            is_alive: true,
            piece_id: 'white_crowned_1',
            crowned: true,
        };
        let position = Position { x: 1, y: 2 };
        // TODO: Replace empty board with Fixture Board
        let board = fixture_board();
        let moves = generate_moves::possible_moves(piece, position, board);
        let (move, _) = *moves.at(0);
        assert(move == Position { x: 1, y: 4 }, 'White Crowned Piece step 2 forward');
    }
}