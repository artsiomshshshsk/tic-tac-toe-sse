import { refreshToken } from '@/api/AuthApiClient.ts';
import { EventSourcePolyfill } from 'ng-event-source';

const API_URL = '/api';

export type GameStatus = "GAME_STARTED" | "GAME_UPDATED" | "GAME_ENDED"

export type Cell = "EMPTY" | "X" | "O"

export type GameUser = {
    username: string;
    avatarUrl: string;
}

export interface GameEvent {
    event: GameStatus;
    board: Cell[][];
    winner: string;
    currentPlayer: string;
    gameId: number;
    user1: GameUser;
    user2: GameUser;
}

interface EventSourceErrorEvent extends Event {
    errorCode: number;
    errorMessage: string;
}

export interface GameResult {
    id: number;
    firstPlayer: GameUser;
    secondPlayer: GameUser;
    winner: GameUser;
    playedAt: string;
}

export const subscribe = (onEvent: (event: GameEvent) => void, retries = 0) => {
    const eventSource = new EventSourcePolyfill(`${API_URL}/subscribe`, {
        headers: { Authorization: `Bearer ${getAuthToken()}` }
    });
    
    eventSource.onmessage = (event) => {
        const data = JSON.parse(event.data);
        onEvent(data);
    }
    
    eventSource.onerror = (error: EventSourceErrorEvent) => {
        if (error.errorCode === 401 && retries < 3) { // Limit to 3 retries
            refreshToken()
              .then(() => {
                  eventSource.close();
                  setTimeout(() => subscribe(onEvent, retries + 1), 1000 * retries); // Exponential backoff
              })
              .catch((error) => {
                  console.error('Failed to refresh token:', error);
              });
        } else {
            console.error('Non-retryable error or max retries reached', error);
            eventSource.close();
        }
    }
    return eventSource;
}


interface MoveRequest {
    x: number;
    y: number;
    playerName: string;
}


export async function getUserData(): Promise<{username:string, avatarUrl: string}> {
    const token = getAuthToken();
    const response = await fetch(`${API_URL}/user-data`, {
        headers: {
            'Authorization': `Bearer ${token}`,
        },
    });

    if (!response.ok) {
        if (response.status === 401) {
            try {
                await refreshToken();
                // Retry the request with the new access token
                return getUserData();
            } catch (error) {
                // Handle failed token refresh
                throw new Error('Failed to refresh token');
            }
        } else {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
    }
    return response.json();
}


export async function getGameHistory(): Promise<GameResult[]> {
    const token = getAuthToken();
    const response = await fetch(`${API_URL}/gameResults`, {
        headers: {
            'Authorization': `Bearer ${token}`,
        },
    });

    if (!response.ok) {
        if (response.status === 401) {
            try {
                await refreshToken();
                // Retry the request with the new access token
                return getGameHistory();
            } catch (error) {
                // Handle failed token refresh
                throw new Error('Failed to refresh token');
            }
        } else {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
    }
    return response.json();
}


export async function makeMove(gameId: number, move: MoveRequest): Promise<void> {
    const token = getAuthToken();
    const response = await fetch(`${API_URL}/move/${gameId}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify(move),
    });
    
    if (!response.ok) {
        if (response.status === 401) {
            try {
                await refreshToken();
                // Retry the request with the new access token
                return makeMove(gameId, move);
            } catch (error) {
                // Handle failed token refresh
                throw new Error('Failed to refresh token');
            }
        } else {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
    }
}


function getAuthToken() {
    return localStorage.getItem('accessToken');
}

