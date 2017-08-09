import React from 'react'

const PieceTile = (props) => {

  let piece  = <div> </div>
  const colors = ["redBG", "blackBG"]
  let colorIndex = (props.columnNumber+props.rowNumber) % 2;
  let squareclicked = () => props.handleChange(props.rowNumber, props.columnNumber)

  if (props.piece == null){
  } else if (props.piece == "B") {
    piece = <div className="blackpiece"></div>
  } else if (props.piece == "R"){
    piece = <div className="redpiece"></div>
  } else if (props.piece == "RK"){
    piece =
    <div className="kingredpiece" >
      <img src="http://icons.iconarchive.com/icons/pino/peanuts/32/King-Snoopy-icon.png"></img>
    </div>
  } else if (props.piece == "BK"){
    piece =
    <div className="kingblackpiece">
      <img src="http://icons.iconarchive.com/icons/pino/peanuts/32/King-Snoopy-icon.png"></img>
    </div>
  }

  let tileColor = colors[colorIndex] + " square"


  if (props.possible.length > 0){
    debugger
    props.possible.forEach((tile) => {
      if (tile[0] === props.rowNumber && tile[1] === props.columnNumber){
        tileColor = "possiblechoices" + " square"
      }
    })
  }
  return (
    <div key={`${props.rowNumber},${props.columnNumber}`} className={tileColor} onClick={squareclicked}>
      {piece}
     </div>
  )
}

export default PieceTile
