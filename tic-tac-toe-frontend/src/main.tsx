import ErrorPage from '@/error-page.tsx';
import ConfirmCode from '@/routes/ConfirmCode.tsx';
import Login from '@/routes/Login.tsx';
import Register from '@/routes/Register.tsx';
import { Amplify } from 'aws-amplify';
import React from 'react'
import ReactDOM from 'react-dom/client'
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import App from './routes/App.tsx'
import './index.css'

Amplify.configure({
   Auth: {
     Cognito: {
        userPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID,
        userPoolClientId: import.meta.env.VITE_COGNITO_CLIENT_ID,
     }
   }
})

const router = createBrowserRouter([
  {
    path: "/game",
    element: <App />,
    errorElement: <ErrorPage />,
  },
  {
    path: "/register",
    element: <Register />,
  },
  {
    path: "/confirm",
    element: <ConfirmCode />,
  },
  {
    path: 'login',
    element: <Login />,
  },
]);

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <RouterProvider router={router} />
  </React.StrictMode>,
)
