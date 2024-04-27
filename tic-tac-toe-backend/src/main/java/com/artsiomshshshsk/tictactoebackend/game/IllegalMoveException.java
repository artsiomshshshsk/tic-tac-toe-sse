package com.artsiomshshshsk.tictactoebackend.game;

public class IllegalMoveException extends RuntimeException{
    public IllegalMoveException(String message) {
        super(message);
    }
}
