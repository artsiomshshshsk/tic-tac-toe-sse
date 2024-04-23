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
import { signUp } from 'aws-amplify/auth';
import { useNavigate } from 'react-router-dom';

type SignUpParameters = {
  username: string;
  password: string;
  email: string;
};

async function handleSignUp({
                              username,
                              password,
                              email
                            }: SignUpParameters) {
  try {
    const { isSignUpComplete, userId, nextStep } = await signUp({
      username,
      password,
      options: {
        userAttributes: {
          email
        },
        autoSignIn: true
      }
    });
    
    console.log(userId);
    console.log(isSignUpComplete);
    console.log(nextStep);
    
    switch (nextStep.signUpStep) {
      case 'CONFIRM_SIGN_UP':
        console.log('User needs to confirm sign up, a code has been sent to their email');
        break;
      case 'DONE':
        console.log('Sign up process is complete');
        break;
      case 'COMPLETE_AUTO_SIGN_IN':
        console.log('Sign up process is complete, user has been automatically signed in');
        break;
      default:
        console.log('Unhandled sign up step');
    }
    
  } catch (error) {
    console.log('error signing up:', error);
  }
}

const Register = () => {
  
  
  const navigate = useNavigate();
  
  return (
    <div className={'flex justify-center'}>
      <Card className="w-[450px] my-52">
        <CardHeader>
          <CardTitle>Sign-up</CardTitle>
          <CardDescription>Sign-up in order to play Tic Tac Toe.</CardDescription>
        </CardHeader>
        <CardContent>
          <Formik
            initialValues={{ username: '', email: '', password: '' }}
            onSubmit={(values, { setSubmitting }) => {
              console.log(values);
              handleSignUp({
                username: values.username,
                email: values.email,
                password: values.password
              })
                .then(() =>         navigate('/confirm', { state: { username : values.username} }))
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
                    <Label htmlFor="email">Email</Label>
                    <Field as={Input} id="email" name="email" type="email" placeholder="Your email"/>
                  </div>
                  <div className="flex flex-col space-y-1.5">
                    <Label htmlFor="password">Password</Label>
                    <Field as={Input} id="password" name="password" type="password" placeholder="Your password"/>
                  </div>
                </div>
                <CardFooter className="flex justify-center">
                  <div className={'flex items-center space-x-2.5 my-5 mb-0'}>
                    <Button type="submit" disabled={isSubmitting}>Sign-up</Button>
                    <span>
                      Already a member? <a href="/login" className="text-blue-500">Login</a>
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

export default Register;
