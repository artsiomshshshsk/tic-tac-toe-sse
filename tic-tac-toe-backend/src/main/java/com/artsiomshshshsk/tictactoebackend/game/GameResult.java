package com.artsiomshshshsk.tictactoebackend.game;

import com.artsiomshshshsk.tictactoebackend.user.GameUser;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class GameResult {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private GameUser firstPlayer;

    @ManyToOne
    private GameUser secondPlayer;

    @ManyToOne
    private GameUser winner;

    LocalDate playedAt;

    public GameResult(GameUser firstPlayer, GameUser secondPlayer, GameUser winner) {
        this.firstPlayer = firstPlayer;
        this.secondPlayer = secondPlayer;
        this.winner = winner;
        this.playedAt = LocalDate.now();
    }
}
