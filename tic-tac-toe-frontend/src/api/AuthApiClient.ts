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
  localStorage.setItem('username', username);
}

export async function confirm({ username, confirmationCode }: { username: string; confirmationCode: string }): Promise<void> {
  await apiClient.post('/confirm-sign-up', { username, confirmationCode });
}


export const logout = async () => {
  const accessToken = localStorage.getItem('accessToken');
  localStorage.removeItem('accessToken');
  localStorage.removeItem('refreshToken');
  localStorage.removeItem('username');
  if(!accessToken) return;
  await apiClient.post('/sign-out', { accessToken });
};


export const refreshToken = async () => {
  const refreshToken = localStorage.getItem('refreshToken');
  if (!refreshToken) {
    return;
  }
  
  console.log('Refreshing token');
  
  try {
    const response = await api.post('/refresh-token', { refreshToken });
    const { accessToken, refreshToken } = response.data;
    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', refreshToken);
  } catch (error) {
    console.error('Token refresh failed:', error);
    // handle logout or redirect to login
  }
};

