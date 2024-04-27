const API_URL = '/api/auth';

export interface AuthResponse {
    accessToken: string;
    refreshToken: string;
}

export async function signUp(username: string, email: string, password: string): Promise<void> {
    await fetch(`${API_URL}/sign-up`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, email, password }),
    });
    return new Promise<void>((resolve) => resolve());
}


export async function signIn(username: string, password: string): Promise<void> {
    const response = await fetch(`${API_URL}/sign-in`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, password }),
    });
    
    const { accessToken, refreshToken } = await response.json() as AuthResponse;
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
    return new Promise<void>((resolve) => resolve());
}


export async function confirm({username, confirmationCode}: {username: string, confirmationCode: string}): Promise<void> {
    await fetch(`${API_URL}/confirm-sign-up`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ username, confirmationCode }),
    });
    return new Promise<void>((resolve) => resolve());
}