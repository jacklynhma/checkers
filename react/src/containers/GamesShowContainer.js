import React, { Component } from 'react';
import NavBar from '../components/NavBar'

class GamesShowContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      board: [],
      coordinates: [],
      message: null,
      turn: null,
      winner: null,
      team: null
    }
    this.addAMove = this.addAMove.bind(this)
    this.handleChange = this.handleChange.bind(this)
    setInterval(this.getGame.bind(this), 1000)
  }
  componentDidMount(){
    this.getGame()
  }
  getGame() {
    fetch(`/api/v1/games/${this.props.params.id}`, {
      credentials: "same-origin"
    })
    .then(response => { return response.json()})
    .then(body => {

      this.setState({ board: body.game.state_of_piece, turn: body.game.turn, winner: body.winner, team: body.team})
    })
  }

  addAMove(formPayload){
    fetch(`/api/v1/games/${this.props.params.id}`,{
      method: "PATCH",
      credentials: "same-origin",
      headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(formPayload)
    })
    .then(response => {
    if (response.ok) {
      return response;
  } else {
      let errorMessage = `${response.status} (${response.statusText})`;
      let error = new Error(errorMessage);
      throw(error);
    }
    })
    .then(response => response.json())
    .then(responseData => {
      this.setState({ board: responseData.game.state_of_piece, message: responseData.message, turn: responseData.turn})
    })
    .catch(error => console.error(`Error in fetch: ${error.message}`));
  }

  handleChange(rowNumber, columnNumber){
    let newcoordinates = this.state.coordinates.concat([rowNumber, columnNumber])
    this.setState({coordinates: newcoordinates})
  }

  componentDidUpdate () {
    if (this.state.coordinates.length == 4)
     {
      let formPayload = {
        coordinates: this.state.coordinates
      }
     //  need to clear the coordinates array
     this.setState({coordinates: []})
     this.addAMove(formPayload)
    }
  }
  render(){
    let winner = "";
      if (this.state.winner == "no one"){
        winner == ""
      } else {
        winner = this.state.winner
      }
    let turn = "";
      if (this.state.turn % 2 == 1 && this.state.winner == "no one") {
        turn = "It is black's turn"
      }
      else if (this.state.turn % 2 == 0 && this.state.winner == "no one"){
        turn = "It is red's turn"
      }
      const colors = ["redBG", "blackBG"]
      let board = this.state.board.map((row, rowNumber)=> {
        return(
          <div key={`row-${rowNumber}`}className="row">
            {
              row.map((piece, columnNumber)=>{
                let pieceDesign = ""
                let colorIndex = (columnNumber+rowNumber) % 2;
                let squareclicked = () => this.handleChange(rowNumber, columnNumber)
                if (piece == null){
                  pieceDesign = ""
                } else if (piece == "B") {
                  pieceDesign = "blackpiece"
                } else if (piece == "R"){
                  pieceDesign = "redpiece"
                }
                return (<div  key={`${rowNumber},${columnNumber}`} className={colors[colorIndex] + " square"} onClick={() => this.handleChange(rowNumber, columnNumber)}>
                  <div className={pieceDesign}>{piece}</div>
                  &nbsp;
                </div>
                )
              })
            }
          </div>
        )
      })

      return (
        <div className="messages">
          <h1>
          {this.state.message != null &&
            this.state.message
          }
          </h1>
          <div>
            <h1>
            {winner}
            {turn}
            </h1>
          </div>
          <div>
            {board}
            <h3>You are on team {this.state.team}</h3>
          </div>
        </div>
      )
    }
  }

  export default GamesShowContainer
