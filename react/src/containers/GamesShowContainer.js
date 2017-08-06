import React, { Component } from 'react';
import NavBar from '../components/NavBar';
import PieceTile from '../components/PieceTile'

class GamesShowContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      board: [],
      coordinates: [],
      message: null,
      turn: null,
      winner: null,
      team: null,
      redplayers: [],
      blackplayers: []
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

      this.setState({ board: body.game.state_of_piece, turn: body.game.turn,
        winner: body.winner, team: body.team, redplayers: body.redplayers,
        blackplayers: body.blackplayers})
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
      let redTeam = ''
      if (this.state.redplayers != []){
        redTeam = this.state.redplayers.map((player) => {
          return (
            <div> {player}</div>
          )
        })
      }
      let team =""
      if (this.state.team == "none"){
        team = <h3>You are a spectator</h3>
      } else if (this.state.team != "none"){
        team = <h3> You are on team {this.state.team}</h3>
      }
      let blackTeam = ''
      if (this.state.blackplayers != []){
        blackTeam = this.state.blackplayers.map((player) => {
          return (
            <div> {player}</div>
          )
        })
      }

      let board = this.state.board.map((row, rowNumber)=> {
        return(
          <div key={`row-${rowNumber}`}className="row">
            {
              row.map((piece, columnNumber)=>{
                return (
                  <PieceTile
                    columnNumber = {columnNumber}
                    rowNumber = {rowNumber}
                    handleChange = {this.handleChange}
                    piece = {piece}
                  />
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
            {team}
            <div className="row">
              <div className="col-xs-6">
                <h4>Red team:</h4>
                {redTeam}
              </div>
              <div className="col-xs-6">
                <h4>Black team:</h4>
                {blackTeam}
              </div>
            </div>
          </div>
        </div>
      )
    }
  }

  export default GamesShowContainer
