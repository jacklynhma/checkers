import React, { Component } from 'react';
import NavBar from '../components/NavBar'

class GamesShowContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      board: [],
    }
  }
  componentDidMount(){
    fetch(`/api/v1/games/${this.props.params.id}`)
    .then(response => {
      return response.json()
    })
    .then(body => {
      this.setState({ board: body.game.state_of_piece})
    })
  }
  render(){
    const colors = ["redBG", "blackBG"]
    let board = this.state.board.map((row, rowNumber)=> {
      return(
        <div className="row">
          {
            row.map((piece, columnNumber)=>{
              let colorIndex = (columnNumber+rowNumber) % 2;

              if (piece == null){
                return (<div className={colors[colorIndex] + " square"}>
                  <div>{piece}</div>
                  &nbsp;
                </div>
                )
              }
              else {
                return(
                <div className={colors[colorIndex] + " square"}>
                  <div className="piece">{piece}</div>
                  &nbsp;
                </div>
                )
              }
            })
          }
        </div>
      )
    })
    return (
      <div>
        {board}
      </div>

    )
  }
}

export default GamesShowContainer
