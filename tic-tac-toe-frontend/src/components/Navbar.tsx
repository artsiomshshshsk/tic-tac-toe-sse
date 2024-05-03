import {
  NavigationMenu,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from "@/components/ui/navigation-menu";
import { Link } from 'react-router-dom';

const Navbar = () => {
  return <NavigationMenu>
    <div className={'flex justify-between'}>
      <NavigationMenuList>
        <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/">Home</Link>
        </NavigationMenuLink>
        <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/game">Game</Link>
        </NavigationMenuLink>
        <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/login">Sign-in</Link>
        </NavigationMenuLink>
      </NavigationMenuList>
      <NavigationMenuList>
        <NavigationMenuLink className={navigationMenuTriggerStyle()}>
          <Link to="/logout">Logout</Link>
        </NavigationMenuLink>
      </NavigationMenuList>
    </div>
  </NavigationMenu>;
};

export default Navbar;