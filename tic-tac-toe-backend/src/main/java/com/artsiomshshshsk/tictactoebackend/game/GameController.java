package com.artsiomshshshsk.tictactoebackend.game;

import com.artsiomshshshsk.tictactoebackend.auth.AuthAcknowledged;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequiredArgsConstructor
@Slf4j
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@CrossOrigin(origins = "*", allowedHeaders = "*", methods = {RequestMethod.GET, RequestMethod.POST})
public class GameController implements AuthAcknowledged {

    Map<String, SseEmitter> emitters = new ConcurrentHashMap<>();
    Set<String> waitingPlayers = ConcurrentHashMap.newKeySet();
    Map<Long, Game> games = new ConcurrentHashMap<>();


    @GetMapping("/subscribe")
    public SseEmitter subscribe() {

        var username = getUserName();
        System.out.println("username: " + username);

        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
        emitters.put(username, emitter);
        waitingPlayers.add(username);

        emitter.onCompletion(() -> emitters.remove(username));
        emitter.onTimeout(() -> emitters.remove(username));
        emitter.onError((e) -> emitters.remove(username));


        if(waitingPlayers.size() >= 2) {
            String player1 = waitingPlayers.iterator().next();
            waitingPlayers.remove(player1);
            String player2 = waitingPlayers.iterator().next();
            waitingPlayers.remove(player2);

            Game game = new Game(player1, player2, gameEvent -> {
                var firstEmitter = emitters.get(player1);
                var secondEmitter = emitters.get(player2);

                try {
                    firstEmitter.send(gameEvent);
                    secondEmitter.send(gameEvent);
                } catch (IOException e) {
                    log.info("Something bad happened while emitting events");
                }
            });
            games.put(game.getGameId(), game);
        }
        return emitter;
    }


    @PostMapping("/move/{gameId}")
    public ResponseEntity<?> move(@PathVariable long gameId, @RequestBody MoveRequest request) {
        log.info("Move request: {}, gameID: {}", request, gameId);
        Game game = games.get(gameId);
        String username = getUserName();
        try {
            game.makeMove(request.y(),request.x(), username);
        } catch (IllegalMoveException e) {
            log.info("Illegal move: {}", e.getMessage());
            return new ResponseEntity<>(new ErrorResponse(e.getMessage()), org.springframework.http.HttpStatus.BAD_REQUEST);
        }
        return ResponseEntity.ok().build();
    }

    public record GameEvent(GameStatus event, Game.Cell[][] board, String winner, String currentPlayer, long gameId) {}

    public record MoveRequest(int x, int y) { }

    public enum GameStatus {GAME_STARTED, GAME_UPDATED, GAME_ENDED, ILLEGAL_MOVE}

    public record ErrorResponse(String message) { }
}
