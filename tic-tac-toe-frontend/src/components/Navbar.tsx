import { logout } from '@/api/AuthApiClient.ts';
import { Button } from '@/components/ui/button.tsx';
import {
  NavigationMenu,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from "@/components/ui/navigation-menu";
import { toast } from '@/components/ui/use-toast.ts';
import { Link, useNavigate } from 'react-router-dom';

const Navbar = () => {
  
  const navigate = useNavigate();
  
  const accessToken = localStorage.getItem('accessToken');
  const authenticated = !!accessToken;
  
  const handleLoadCPU = async () => {
    await fetch(`api/load-cpu`, {
      method: 'GET'
    });
    console.log('CPU loaded');
  }
  
  return <NavigationMenu>
    <div className={'flex justify-between'}>
      <Button className={'mr-14'} onClick={handleLoadCPU}>Load CPU</Button>
      <NavigationMenuList>
        <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/">Home</Link>
        </NavigationMenuLink>
        { authenticated && <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/game">Game</Link>
        </NavigationMenuLink>}
        {!authenticated && <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/login">Sign-in</Link>
        </NavigationMenuLink>}
      </NavigationMenuList>
      {authenticated && <Button onClick={() => {
        logout().then(() => {
          navigate('/login');
        }).catch((error: Error) => {
          toast({
            title: "Something went wrong. Please try again",
            description: error.message,
          })
        })
      }}>Logout</Button>}
    </div>
  </NavigationMenu>;
};

export default Navbar;