import React from 'react'

const PieceTile = (props) => {

  let piece  = <div> </div>
  const colors = ["redBG", "blackBG"]
  let colorIndex = (props.columnNumber+props.rowNumber) % 2;
  let tileColor = ""
  let squareclicked = () => props.handleChange(props.rowNumber, props.columnNumber)


  // if (props.possible != []){
  //   props.possible.map((tile) => {
  //     if (tile == [props.rowNumber, props.columnNumber]) {
  //       tileColor = "possiblechoices"
  //     } else {
  //       tileColor = colors[colorIndex]
  //     }
  //   })
  // }

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

  return (
    <div  key={`${props.rowNumber},${props.columnNumber}`}
    className={ colors[colorIndex] + " square"} onClick={squareclicked}>
      {piece}
    </div>
  )
}

export default PieceTile
