package com.artsiomshshshsk.tictactoebackend.user;

import org.springframework.stereotype.Service;

public interface GameUserService {
    void saveGameUser(GameUser gameUser);
    GameUser findByUsername(String username);
}
