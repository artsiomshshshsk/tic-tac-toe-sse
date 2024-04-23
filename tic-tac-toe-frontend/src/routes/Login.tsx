import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Formik, Form, Field } from 'formik';
import { signIn, type SignInInput } from 'aws-amplify/auth';
import { useNavigate } from 'react-router-dom';

async function handleSignIn({ username, password }: SignInInput) {
  try {
    const { isSignedIn, nextStep } = await signIn({ username, password });
    
    console.log(isSignedIn);
    console.log(nextStep);
  } catch (error) {
    console.log('error signing in', error);
  }
}

const Login = () => {
  
  const navigate = useNavigate();
  
  
  return (
    <div className={'flex justify-center'}>
      <Card className="w-[450px] my-52">
        <CardHeader>
          <CardTitle>Sign-in</CardTitle>
          <CardDescription>Sign-in to play Tic Tac Toe!</CardDescription>
        </CardHeader>
        <CardContent>
          <Formik
            initialValues={{ username: '', password: '' }}
            onSubmit={(values, { setSubmitting }) => {
              handleSignIn({
                username: values.username,
                password: values.password
              }).then(() => {
                navigate('/game', {state: {username: values.username}});
              })
              setSubmitting(false);
            }}
          >
            {({ isSubmitting }) => (
              <Form>
                <div className="grid w-full items-center gap-4">
                  <div className="flex flex-col space-y-1.5">
                    <Label htmlFor="username">Username</Label>
                    <Field as={Input} id="username" name="username" placeholder="Your username"/>
                  </div>
                  <div className="flex flex-col space-y-1.5">
                    <Label htmlFor="password">Password</Label>
                    <Field as={Input} id="password" name="password" type="password" placeholder="Your password"/>
                  </div>
                </div>
                <CardFooter className="flex justify-center">
                  <div className={'flex items-center space-x-2.5 my-5 mb-0'}>
                    <Button type="submit" disabled={isSubmitting}>Sign-in</Button>
                    <span>
                      Not a member yet? <a href="/register" className="text-blue-500">Sign-up</a>
                    </span>
                  </div>
                </CardFooter>
              </Form>
            )}
          </Formik>
        </CardContent>
      </Card>
    </div>
  );
};

export default Login;
