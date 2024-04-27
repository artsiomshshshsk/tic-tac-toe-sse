import { EventSourcePolyfill } from 'ng-event-source';

const API_URL = '/api';

export type GameStatus = "GAME_STARTED" | "GAME_UPDATED" | "GAME_ENDED"

export type Cell = "EMPTY" | "X" | "O"

export interface GameEvent {
    event: GameStatus;
    board: Cell[][];
    winner: string;
    currentPlayer: string;
    gameId: number;
}
export const subscribe = (onEvent: (event: GameEvent) => void) => {
    const token = getAuthToken();
    const eventSource = new EventSourcePolyfill(`${API_URL}/subscribe`,
      {
          headers: { Authorization: `Bearer ${token}`}
      });
    eventSource.onmessage = (event) => {
        const data = JSON.parse(event.data);
        onEvent(data);
    }
    return eventSource;
}

interface MoveRequest {
    x: number;
    y: number;
    playerName: string;
}

export async function makeMove(gameId: number, move: MoveRequest): Promise<void> {
    const token = getAuthToken();
    console.log("token", token);
    const response = await fetch(`${API_URL}/move/${gameId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify(move),
    });

    if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
    }
}



function getAuthToken() {
    return localStorage.getItem('accessToken');
}

