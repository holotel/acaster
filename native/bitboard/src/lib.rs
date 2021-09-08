use std::convert::TryFrom;

use magpie::othello::{OthelloBoard, Stone};
use rustler::{Atom, NifStruct};

mod atoms {
    rustler::atoms! {
        ok,
        error,
        black,
        white
    }
}

#[derive(NifStruct, Clone)]
#[module = "Bitboard"]
pub struct Board {
    pub blacks: u64,
    pub whites: u64,
}

impl From<OthelloBoard> for Board {
    fn from(ob: OthelloBoard) -> Self {
        Board {
            blacks: ob.bits_for(Stone::Black),
            whites: ob.bits_for(Stone::White),
        }
    }
}

impl From<Board> for OthelloBoard {
    fn from(b: Board) -> Self {
        OthelloBoard::try_from((b.blacks, b.whites)).unwrap()
    }
}

#[rustler::nif]
fn empty() -> Board {
    OthelloBoard::empty().into()
}

#[rustler::nif]
fn standard() -> Board {
    OthelloBoard::standard().into()
}

fn emplace(board: Board, pos: u64, s: Stone) -> (Atom, Board) {
    let mut board: OthelloBoard = board.clone().into();
    match board.place_stone(s, pos) {
        Ok(()) => (atoms::ok(), board.into()),
        Err(_) => (atoms::error(), board.into()),
    }
}

#[rustler::nif]
fn emplace_black(board: Board, pos: u64) -> (Atom, Board) {
    emplace(board, pos, Stone::Black)
}

#[rustler::nif]
fn emplace_white(board: Board, pos: u64) -> (Atom, Board) {
    emplace(board, pos, Stone::White)
}

fn put(board: Board, pos: u64, s: Stone) -> (Atom, Board) {
    let mut board: OthelloBoard = board.clone().into();
    match board.place_stone_unchecked(s, pos) {
        Ok(()) => (atoms::ok(), board.into()),
        Err(_) => (atoms::error(), board.into()),
    }
}

#[rustler::nif]
fn put_black(board: Board, pos: u64) -> (Atom, Board) {
    put(board, pos, Stone::Black)
}

#[rustler::nif]
fn put_white(board: Board, pos: u64) -> (Atom, Board) {
    put(board, pos, Stone::White)
}

#[rustler::nif]
fn remove(board: Board, pos: u64) -> (Atom, Board) {
    let mut board: OthelloBoard = board.clone().into();
    board.remove_stone_unchecked(Stone::Black, pos);
    board.remove_stone_unchecked(Stone::White, pos);
    (atoms::ok(), board.into())
}

fn moves_for(board: Board, s: Stone) -> u64 {
    let board: OthelloBoard = board.into();
    board.moves_for(s)
}

#[rustler::nif]
fn moves_for_black(board: Board) -> u64 {
    moves_for(board, Stone::Black)
}

#[rustler::nif]
fn moves_for_white(board: Board) -> u64 {
    moves_for(board, Stone::White)
}

fn is_legal_move(board: Board, pos: u64, s: Stone) -> bool {
    let board: OthelloBoard = board.into();
    board.is_legal_move(s, pos)
}

#[rustler::nif]
fn is_legal_move_black(board: Board, pos: u64) -> bool {
    is_legal_move(board, pos, Stone::Black)
}

#[rustler::nif]
fn is_legal_move_white(board: Board, pos: u64) -> bool {
    is_legal_move(board, pos, Stone::White)
}

rustler::init!(
    "Elixir.Bitboard",
    [
        empty,
        standard,
        emplace_black,
        emplace_white,
        put_black,
        put_white,
        remove,
        moves_for_black,
        moves_for_white,
        is_legal_move_black,
        is_legal_move_white,
    ]
);
