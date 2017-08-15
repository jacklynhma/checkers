import React, { Component } from 'react';
import NavBar from '../components/NavBar';
import PieceTile from '../components/PieceTile'
import CommentsIndexContainer from './CommentsIndexContainer'


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
      blackplayers: [],
      name: null,
      currentuser: null,
      gameid: null,
      history: [],
      possible: [],
      replayStep: 0,
      watchingReplay: false,
      paused: false,
      lastMouseMove: 0

    }
    this.startreplay = this.startreplay.bind(this)
    this.addAMove = this.addAMove.bind(this)
    this.handleChange = this.handleChange.bind(this)
    setInterval(this.getGame.bind(this), 1000)
    setInterval(this.checkMouseMove.bind(this), 1000)
    this.stepReplay = this.stepReplay.bind(this)
    this.togglePaused = this.togglePaused.bind(this)
    this.handleMouseMove = this.handleMouseMove.bind(this)
  }
  checkMouseMove() {
    if (Math.round((new Date()).getTime() / 1000) - this.state.lastMouseMove > 6){
      this.setState({paused: true})
    }
  }
  handleMouseMove() {
    // save the last time the mouse has moved
    let time = Math.round((new Date()).getTime() / 1000)
    this.setState({lastMouseMove: time, paused: false})

  }

  togglePaused() {
    // if clicked  then pause is true, run set interval
    let pausedState = !this.state.paused
    this.setState({paused: pausedState})
    // if clicked again then pause is false, then do not run set interval
  }

  startreplay() {
    this.setState({replayStep: 0, watchingReplay: true}, this.stepReplay)
  }

  stepReplay() {
    fetch(`/api/v1/games/${this.props.params.id}/history?turn=${this.state.replayStep}`)
    .then(response => { return response.json()})
    .then(body => {
      this.setState({board: body.game.state_of_piece, replayStep: this.state.replayStep + 1})
      if (this.state.replayStep <= this.state.history.length) {
        setTimeout(this.stepReplay, 1000)
      } else {
        this.setState({watchingReplay: false})
      }

    })
  }


  componentDidMount(){
    this.getGame()
  }
  getGame() {
    if (this.state.watchingReplay || this.state.paused ){
      return
    }
    fetch(`/api/v1/games/${this.props.params.id}`, {
      credentials: "same-origin"
    })
    .then(response => { return response.json()})
    .then(body => {
      this.setState({ gameid: body.game.id, board: body.game.state_of_piece,
        turn: body.game.turn,
        winner: body.winner, team: body.team, redplayers: body.redplayers,
        blackplayers: body.blackplayers, name: body.game.name,
        currentuser: body.currentuser, history: body.history})
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
      this.setState({ piece: responseData.piece,
        possible: responseData.possible,
        board: responseData.game.state_of_piece,
        message: responseData.message,
        turn: responseData.turn})
    })
    .catch(error => console.error(`Error in fetch: ${error.message}`));
  }

  handleChange(rowNumber, columnNumber){

    let teamTurn = this.state.turn % 2
    if ((teamTurn == 1 && this.state.team == "black" ) || (teamTurn == 0 && this.state.team == "red")){
      let coordinate = [rowNumber, columnNumber]
      let piece = this.state.board[coordinate[0]][coordinate[1]]
      let formPayload = ""

      // if the coordinates is two it will grab another the same one and return the possible movesdispla
      // if the coordintes is four, it will check if it is valid
      // if the coordinates is greater than 4, then it is invalid so it should be cleared
      if ((coordinate.length == 2 && (piece !== null )) && (this.state.team == "red" && (piece === "R" || piece === "RK")) || (this.state.team == "black" && (piece === "B" || piece === "BK"))) {

        this.state.coordinates = coordinate
        formPayload = {
        coordinates: this.state.coordinates
        }
        this.addAMove(formPayload)

      }
      else if (coordinate.length == 2 && piece === null && this.state.coordinates.length == 2){

        this.state.coordinates = this.state.coordinates.concat(coordinate)
        formPayload = {
          coordinates: this.state.coordinates
        }
        //  need to clear the coordinates array
        this.setState({coordinates: []})
        this.addAMove(formPayload)
      }


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
      let redTeam = ""
      let displayPlayer = ""
      if (this.state.redplayers != []){
        redTeam = this.state.redplayers.map((player) => {
          if (this.state.currentuser.id == player.id) {
            displayPlayer = <div className="bgcurrentUser"> {player.first_name}</div>
          } else {
            displayPlayer = <div> {player.first_name}</div>
          }
          return (
            <div key={`players-${player.id}`}>{displayPlayer}</div>
          )
        })
      }
      let team = ""
      if (this.state.team == "none"){
        team = <h3>You are a spectator</h3>
      } else if (this.state.team != "none"){
        team = <h3> </h3>
      }
      let blackTeam = ""
      let displayblackplayer = ""
      if (this.state.blackplayers != []){
        blackTeam = this.state.blackplayers.map((player) => {
          if (this.state.currentuser.id == player.id) {
            displayblackplayer = <div className="bgcurrentUser"> {player.first_name}</div>
          } else {
            displayblackplayer = <div> {player.first_name}</div>
          }
          return (
            <div key={`player-${player.first_name}`}>{displayblackplayer}</div>
          )
        })
      }
      let board = ""
        board = this.state.board.map((row, rowNumber)=> {
        return(
          <div key={`row-${rowNumber}`}className="row">
            {
              row.map((piece, columnNumber)=>{
                return (
                  <PieceTile
                    key={`piece-${columnNumber}`}
                    columnNumber = {columnNumber}
                    rowNumber = {rowNumber}
                    handleChange = {this.handleChange}
                    piece = {piece}
                    possible = {this.state.possible}
                  />
                )
              })
            }
          </div>
        )
      })

      return (
        <div onMouseMove={this.handleMouseMove} className="board">
          <div className="display row">
            <div className="messages col-xs-8">
              <h2>
                {this.state.message != null &&
                  this.state.message
                }
              </h2>
              <h1>
                {this.state.name != null &&
                  this.state.name
                }
              </h1>
              <div>
                <h2>
                {winner}
                {turn}
              </h2>
              </div>
              <div className="playingboard">
                {board}
                {team}
                <div className="row callout">
                  <div className="col-xs-4">
                    <h4>Red team:</h4>
                    {redTeam}
                  </div>
                  <div className="col-xs-4">
                    <h4>Black team:</h4>
                    {blackTeam}
                  </div>
                </div>
              </div>
            </div>
            <div className="col-xs-4">
              <div className="chat vertical-center">
                {this.state.gameid != null &&
                <CommentsIndexContainer
                  key={this.state.gameid}
                  paused={this.state.paused}
                  gameid={this.state.gameid}
                  />
                }
              </div>
              <div >
                <button onClick={this.startreplay}>Replay</button>

                {this.state.paused ? (
                  <span>updates paused </span>
                ) : (
                  <span> </span>
                )}
              </div>
            </div>
          </div>
        </div>
      )
    }
  }

  export default GamesShowContainer
