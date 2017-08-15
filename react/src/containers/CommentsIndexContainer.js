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
    setInterval(this.getComment.bind(this), 1000)
  }
  componentDidMount() {
    this.getComment()
  }

  getComment() {
    if (this.props.paused){
      return
    }
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

  let listofcomments = ""

  let post = ""
  let comments = this.state.comments.map((comment, commentIndex)=> {
    this.state.arrayOfUsers.map((user)=> {
      if ( user.id == comment.user_id){
        post = <div>{user.first_name}: {comment.body}</div>
      }
    })
    return (
      <div key={`comment-${comment.id}`}>{post}</div>
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
