package com.artsiomshshshsk.tictactoebackend.user;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class GameUser {

    @Id
    private String username;
    private String avatarUrl;
}
