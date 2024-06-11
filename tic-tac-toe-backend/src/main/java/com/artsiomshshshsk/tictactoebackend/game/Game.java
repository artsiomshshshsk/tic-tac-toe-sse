package com.artsiomshshshsk.tictactoebackend.game;

import com.artsiomshshshsk.tictactoebackend.user.GameUser;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;

import java.util.Random;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

@Getter
@Setter
@Slf4j
@FieldDefaults(level = lombok.AccessLevel.PRIVATE)
public class Game {

    final String firstPlayer;
    final String secondPlayer;
    final GameController.GameUserResponse firstPlayerResponse;
    final GameController.GameUserResponse secondPlayerResponse;
    String currentPlayer;
    Move allowedCurrentMove = Move.X;
    Cell[][] board = new Cell[3][3];
    static long id = 0;
    long gameId;
    Consumer<GameController.GameEvent> gameEventConsumer;

    public Game(String firstPlayer, String secondPlayer, Consumer<GameController.GameEvent> gameEventConsumer, Function<String, GameUser> gameUserSupplier) {
        this.firstPlayer = firstPlayer;
        this.secondPlayer = secondPlayer;

        var gameUser1 = gameUserSupplier.apply(firstPlayer);
        var gameUser2 = gameUserSupplier.apply(secondPlayer);

        firstPlayerResponse = new GameController.GameUserResponse(gameUser1.getUsername(), gameUser1.getAvatarUrl());
        secondPlayerResponse = new GameController.GameUserResponse(gameUser2.getUsername(), gameUser2.getAvatarUrl());

        this.currentPlayer = new Random().nextBoolean() ? firstPlayer : secondPlayer;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                board[i][j] = Cell.EMPTY;
            }
        }
        gameId = id++;
        this.gameEventConsumer = gameEventConsumer;
        gameEventConsumer.accept(new GameController.GameEvent(GameController.GameStatus.GAME_STARTED, board, null, currentPlayer, gameId,
                firstPlayerResponse,
                secondPlayerResponse)
        );
    }



    public void makeMove(int x, int y, String playerName) {
        prettyPrintBoard();

        if(!playerName.equals(firstPlayer) && !playerName.equals(secondPlayer)) {
            throw new IllegalMoveException("Invalid player");
        }
        if (!playerName.equals(currentPlayer)) {
            throw new IllegalMoveException("It's not your turn");
        }
        if (board[x][y] != Cell.EMPTY) {
            throw new IllegalMoveException("Cell is already occupied");
        }
        if(x > 2 || y > 2) {
            throw new IllegalMoveException("Invalid cell");
        }

        board[x][y] = allowedCurrentMove == Move.X ? Cell.X : Cell.O;

        if(isWinningMove()) {
            gameEventConsumer.accept(new GameController.GameEvent(GameController.GameStatus.GAME_ENDED, board, playerName, currentPlayer, gameId,firstPlayerResponse, secondPlayerResponse));
            return;
        }

        if(isBoardFull()) {
            gameEventConsumer.accept(new GameController.GameEvent(GameController.GameStatus.GAME_ENDED, board, null, currentPlayer, gameId, firstPlayerResponse, secondPlayerResponse));
            return;
        }

        allowedCurrentMove = allowedCurrentMove == Move.X ? Move.O : Move.X;
        currentPlayer = currentPlayer.equals(firstPlayer) ? secondPlayer : firstPlayer;
        gameEventConsumer.accept(new GameController.GameEvent(GameController.GameStatus.GAME_UPDATED, board, null, currentPlayer, gameId, firstPlayerResponse, secondPlayerResponse));
    }


    public boolean isWinningMove() {
        return checkRows() || checkColumns() || checkDiagonals();
    }

    private boolean checkRows() {
        for (int i = 0; i < 3; i++) {
            if (board[i][0] != Cell.EMPTY && board[i][0] == board[i][1] && board[i][0] == board[i][2]) {
                return true;
            }
        }
        return false;
    }

    private boolean checkColumns() {
        for (int i = 0; i < 3; i++) {
            if (board[0][i] != Cell.EMPTY && board[0][i] == board[1][i] && board[0][i] == board[2][i]) {
                return true;
            }
        }
        return false;
    }

    private void prettyPrintBoard() {
        for (int i = 0; i < 3; i++) {
            System.out.println(board[i][0] + " " + board[i][1] + " " + board[i][2]);
        }
    }

    private boolean checkDiagonals() {
        if (board[0][0] != Cell.EMPTY && board[0][0] == board[1][1] && board[0][0] == board[2][2]) {
            return true;
        }
        return board[0][2] != Cell.EMPTY && board[0][2] == board[1][1] && board[0][2] == board[2][0];
    }

    private boolean isBoardFull() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                if(board[i][j] == Cell.EMPTY) {
                    return false;
                }
            }
        }
        return true;
    }

    enum Move {X, O}
    public enum Cell {EMPTY, X, O}
}

