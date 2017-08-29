import React from 'react';

const PieceTile = (props) => {
  let piece = "";
  // assigns the color of the piece
  if (props.piece === "B") {
    piece = <div className="blackpiece"></div>
  } else if (props.piece === "R"){
    piece = <div className="redpiece"></div>
  } else if (props.piece === "RK"){
    piece =
    <div className="kingredpiece" >
      <img src="http://icons.iconarchive.com/icons/pino/peanuts/32/King-Snoopy-icon.png"></img>
    </div>
  } else if (props.piece === "BK"){
    piece =
    <div className="kingblackpiece">
      <img src="http://icons.iconarchive.com/icons/pino/peanuts/32/King-Snoopy-icon.png"></img>
    </div>
  }
  return (
    <div>{piece}</div>
  )
}

export default PieceTile
