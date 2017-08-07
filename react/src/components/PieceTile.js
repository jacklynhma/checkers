import React from 'react'

const PieceTile = (props) => {
  let pieceDesign = ""
  const colors = ["redBG", "blackBG"]
  let colorIndex = (props.columnNumber+props.rowNumber) % 2;
  let squareclicked = () => props.handleChange(props.rowNumber, props.columnNumber)
  if (props.piece == null){
    pieceDesign = ""
  } else if (props.piece == "B") {
    pieceDesign = "blackpiece"
  } else if (props.piece == "R"){
    pieceDesign = "redpiece"
  }

  return (<div  key={`${props.rowNumber},${props.columnNumber}`}
    className={colors[colorIndex] + " square"} onClick={squareclicked}>
    <div className={pieceDesign}><p>{props.piece}</p></div>
    &nbsp;
  </div>
  )
}

export default PieceTile
