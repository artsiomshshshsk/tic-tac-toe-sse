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

const Register = () => {
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
              alert(JSON.stringify(values, null, 2));
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
