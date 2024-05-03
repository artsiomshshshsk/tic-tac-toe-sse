import { confirm } from '@/api/AuthApiClient.ts';
import ConfirmCodeForm from '@/components/form/ConfirmCodeForm.tsx';
import { useLocation, useNavigate } from 'react-router-dom';
import { useToast } from "@/components/ui/use-toast"

const ConfirmCode = () => {
  
  const location = useLocation();
  const { username } = location.state || {};
  const navigate = useNavigate();
  const { toast } = useToast()
  
  const handleConfirm = (confirmationCode: string) => {
    confirm({username, confirmationCode})
      .then(
        () => navigate('/login')
      ).catch(() => {
        toast({
          title: "Something went wrong",
          description: "Please try again",
        })
      }
    )
  }
  
  return <ConfirmCodeForm onSubmit={handleConfirm}/>
};

export default ConfirmCode;
