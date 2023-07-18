use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, PartialEq)]
enum PieceColor {
    White: (),
    Black: (),
}

impl PieceColorSerdeLen of dojo::SerdeLen<PieceColor> {
    #[inline(always)]
    fn len() -> usize {
        1
    }
}

impl OptionPieceColorSerdeLen of dojo::SerdeLen<Option<PieceColor>> {
    #[inline(always)]
    fn len() -> usize {
        1
    }
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Piece {
    color: PieceColor,
    crowned: bool,
    piece_id: felt252,
}

#[derive(Component, Copy, Drop, Serde, SerdeLen, PartialEq)]
struct Cells {
    x: u32,
    y: u32
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct PlayersId {
    white: ContractAddress,
    black: ContractAddress,
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Game {
    status: bool,
    winner: Option<PieceColor>,
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct GameTurn {
    turn: PieceColor, 
}