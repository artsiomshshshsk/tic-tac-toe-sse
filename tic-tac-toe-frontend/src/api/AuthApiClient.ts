import axios, { AxiosResponse } from 'axios';


const apiClient = axios.create({
  baseURL: '/api/auth',
});


export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
}

export async function signUp(username: string, email: string, password: string): Promise<void> {
  await apiClient.post('/sign-up', { username, email, password });
}

export async function signIn(username: string, password: string): Promise<void> {
  const response: AxiosResponse<AuthResponse> = await apiClient.post('/sign-in', { username, password });
  const { accessToken, refreshToken } = response.data;
  localStorage.setItem('accessToken', accessToken);
  localStorage.setItem('refreshToken', refreshToken);
}

export async function confirm({ username, confirmationCode }: { username: string; confirmationCode: string }): Promise<void> {
  await apiClient.post('/confirm-sign-up', { username, confirmationCode });
}
