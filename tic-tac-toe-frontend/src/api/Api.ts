
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
export const subscribe = (username: string, onEvent: (event: GameEvent) => void) => {
    const eventSource = new EventSource(`${API_URL}/subscribe/${username}`);
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
    const response = await fetch(`${API_URL}/move/${gameId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(move),
    });

    if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
    }
}
