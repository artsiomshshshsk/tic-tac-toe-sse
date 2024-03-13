package com.artsiomshshshsk.tictactoebackend;

public class IllegalMoveException extends RuntimeException{
    public IllegalMoveException(String message) {
        super(message);
    }
}
