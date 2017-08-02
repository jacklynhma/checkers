import React from 'react';
import { Link } from 'react-router'

const NavBar = props => {
  return(
    <div>
    nav
      {props.children}
    </div>
  )
}

export default NavBar;
