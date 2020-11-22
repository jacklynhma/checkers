import React, { Component } from 'react';



class HomePageContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      board: [],
   

    }
    this.redirectToGameList = this.redirectToGameList.bind(this)
    this.redirectToNewGame = this.redirectToNewGame.bind(this)
  }

  redirectToGameList() {
    location.href = '/games';
  }

  redirectToNewGame() {
    location.href = '/games/new';
  }

  render(){
    
    return(
      <div>
        <div  onClick={this.redirectToGameList}>
          Join a Game 
        </div>
        <div onClick={this.redirectToNewGame}>
          Create a game
        </div>
      </div>
    )
  }
}

export default HomePageContainer
