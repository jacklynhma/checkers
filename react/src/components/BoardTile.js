import React from 'react'
import PieceTile from './PieceTile'

const BoardTile = (props) => {

  let piece  = <div> </div>
  const colors = ["redBG", "blackBG"]
  let colorIndex = (props.columnNumber+props.rowNumber) % 2;
  let squareclicked = () => props.handleChange(props.rowNumber, props.columnNumber)

  // highlights any of the possible moves on the board
  // triggered by clicking on one of the user's piece
  let tileColor = colors[colorIndex] + " square"
  if (props.possible !== null) {
    if (props.possible.length > 0){
      props.possible.forEach((tile) => {
        if (tile.length === 4) {
          if (tile[2] === props.rowNumber && tile[3] === props.columnNumber){
            tileColor = "possiblechoices" + " square"
          }
        } else {
          if (tile[0] === props.rowNumber && tile[1] === props.columnNumber){
            tileColor = "possiblechoices" + " square"
          }

        }
      })
    }
  }
  let boardpiece = <PieceTile piece={props.piece} />

  return (
    <div key={`${props.rowNumber},${props.columnNumber}`} className={tileColor} onClick={squareclicked}>
      {boardpiece}
     </div>
  )
}

export default BoardTile
