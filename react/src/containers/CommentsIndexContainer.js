import React, { Component } from 'react';
import NavBar from '../components/NavBar';
import CommentsFormContainer from './CommentsFormContainer'

class CommentsIndexContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      comments: [],
      game: null,
      currentuser: null,
      currentUserteam: null,
      arrayOfUsers: [],
      teamMembers: [],
      redteamMembers: [],
      blackteamMembers: []
    }
    this.addAComment = this.addAComment.bind(this)
  }
  componentDidMount() {
    fetch(`/api/v1/games/${this.props.gameid}/comments`, {
      credentials: "same-origin"
    })
    .then(response => { return response.json()})
    .then(body => {
      
      this.setState({  game: body.game, comments: body.comments,
        arrayOfUsers: body.users, currentuser: body.user,
        redteamMembers: body.redteamMembers, blackteamMembers: body.blackteamMembers})
    })
  }

  addAComment(formPayload){
    fetch(`/api/v1/games/${this.props.gameid}/comments`,{
      method: "POST",
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

      let newcomments = this.state.comments.concat(responseData.comment)
      if (!this.state.arrayOfUsers.includes(responseData.user)) {
        let newuser = this.state.arrayOfUsers.concat(responseData.user)
        this.setState({ comments: newcomments, currentuser: responseData.user})
      } else {this.setState({ comments: newcomments})
      }
    })
    .catch(error => console.error(`Error in fetch: ${error.message}`));
  }


  render(){
  // if the users leaving comments are attached to the game, display the game
  // make sure that people of that team can only see it
  let listofcomments = ""
//   let comments = ""
// // only the people who joined the game can view the comments
//   if (this.state.game != null && this.state.arrayOfUsers != [] && this.state.blackteamMembers != []){
//     let ifUserIsInGame = this.state.arrayOfUsers.map((user)=> {
//       if (user.id == this.state.currentuser.id){
//         return true
//       }
//     })
//     if (ifUserIsInGame){
//       let seperatedComments = this.state.comments.map((comment) => {
//         this.state.blackteamMembers.map((bteam)=> {
//           if (comment.user_id == bteam.id){
//             listofcomments = <div>these comments can only be seen by black team</div>
//           }
//         })
  let post = ""
      let comments = this.state.comments.map((comment)=> {

        this.state.arrayOfUsers.map((user)=> {
          if ( user.id == comment.user_id){

            post = <div>{user.first_name}: {comment.body}</div>
          }
        })
        return (
          <div>{post}</div>
        )
      })


    return (

      <div >
        <div className="gamelist">
          Comments:
          {comments}

        </div>
        <CommentsFormContainer
          addAComment={this.addAComment}
          />
      </div>
    )
  }
}

export default CommentsIndexContainer
