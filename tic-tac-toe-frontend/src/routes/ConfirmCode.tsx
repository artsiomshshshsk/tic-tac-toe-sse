import { Button } from '@/components/ui/button.tsx';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";


import { confirmSignUp, type ConfirmSignUpInput } from 'aws-amplify/auth';


import {
  InputOTP,
  InputOTPGroup,
  InputOTPSeparator,
  InputOTPSlot,
} from "@/components/ui/input-otp"
import { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';


async function handleSignUpConfirmation({
                                          username,
                                          confirmationCode
                                        }: ConfirmSignUpInput) {
  try {
    const { isSignUpComplete, nextStep } = await confirmSignUp({
      username,
      confirmationCode
    });
    
    console.log(isSignUpComplete);
    console.log(nextStep);
    
  } catch (error) {
    console.log('error confirming sign up', error);
  }
}


const ConfirmCode = () => {
  
  const location = useLocation();
  const { username } = location.state || {};
  
  const navigate = useNavigate();
  
  
  const [confirmationCode, setConfirmationCode] = useState('');
  const [confirmationCodeReady, setConfirmationCodeReady] = useState(false);
  
  const handleCodeChange = (code: string) => {
    setConfirmationCode(code);
    setConfirmationCodeReady(code.length === 6);
  }
  
  const handleConfirm = () => {
    handleSignUpConfirmation({username, confirmationCode})
      .then(
        () => navigate('/login')
      )
  }
  
  
  return (
    <div className={'flex justify-center'}>
      <Card className="flex justify-center flex-col w-[450px] my-52">
        <CardHeader>
          <CardTitle>Confirm Email</CardTitle>
          <CardDescription>You need to confirm sign up, a code has been sent to their email</CardDescription>
        </CardHeader>
        <CardContent className={'flex justify-center'}>
          <InputOTP maxLength={6} onChange={handleCodeChange} value={confirmationCode}>
            <InputOTPGroup>
              <InputOTPSlot index={0} />
              <InputOTPSlot index={1} />
              <InputOTPSlot index={2} />
            </InputOTPGroup>
            <InputOTPSeparator />
            <InputOTPGroup>
              <InputOTPSlot index={3} />
              <InputOTPSlot index={4} />
              <InputOTPSlot index={5} />
            </InputOTPGroup>
          </InputOTP>
          <Button className={'ml-5'} disabled={!confirmationCodeReady} onClick={handleConfirm}>Confirm</Button>
        </CardContent>
      </Card>
    </div>
  );
};

export default ConfirmCode;
