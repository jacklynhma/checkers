import React from 'react'

const PieceTile = (props) => {
  let colors = ["redBG", "blackBG"]
  let colorIndex = (props.columnNumber+props.rowNumber) % 2;
  return(
    <div className={colors[colorIndex] + " square"}>
      <div >{props.piece} &nbsp;</div>
    </div>
  )
}

export default PieceTile
