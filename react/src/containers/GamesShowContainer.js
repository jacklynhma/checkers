import React, { Component } from 'react';
import NavBar from '../components/NavBar'

class GamesShowContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      board: [],
      coordinates: []
    }
    this.addAMove = this.addAMove.bind(this)
    this.handleChange = this.handleChange.bind(this)
  }
  componentDidMount(){
    fetch(`/api/v1/games/${this.props.params.id}`)
    .then(response => { return response.json()})
    .then(body => {
      this.setState({ board: body.game.state_of_piece})
    })
  }

  addAMove(formPayload){
    debugger
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
      this.setState({ board: responseData})
    })
    .catch(error => console.error(`Error in fetch: ${error.message}`));
  }

  handleChange(rowNumber, columnNumber){
    let newcoordinates = this.state.coordinates.concat([rowNumber, columnNumber])
    this.setState({coordinates: newcoordinates})
    // this.handleMove(event)
  }

  componentDidUpdate () {
    if (this.state.coordinates.length == 4)
     {
     //  times coordinates by board
      let formPayload = {
        coordinates: this.state.coordinates
      }
     //  need to clear the coordinates array
     this.setState({coordinates: []})
     this.addAMove(formPayload)
    }
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

                let squareclicked = () => this.handleChange(rowNumber, columnNumber)

                return (<div className={colors[colorIndex] + " square"} onClick={() => this.handleChange(rowNumber, columnNumber)}>
                  <div>{piece}</div>
                  &nbsp;
                </div>
                )
              }
              else {
                return(
                <div className={colors[colorIndex] + " square"} onClick={() => this.handleChange(rowNumber, columnNumber)}>
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
