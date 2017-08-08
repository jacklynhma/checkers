import React, { Component } from 'react';
import NavBar from '../components/NavBar';
import TextField from '../components/TextField'


class CommentsFormContainer extends Component {
  constructor(props){
    super(props);
    this.state = {
      body: ''
    }
    this.handleCommentSubmit = this.handleCommentSubmit.bind(this)
    this.handleChange = this.handleChange.bind(this)
    this.handleClearForm = this.handleClearForm.bind(this)
  }

  handleChange(event) {
    const name = event.target.name
    const value = event.target.value
    this.setState({ [name]: value })
  }

  handleClearForm(event) {
  event.preventDefault();
  this.setState({body: ""})
}

  handleCommentSubmit(event){
    event.preventDefault();
    let formPayload = {
      body: this.state.body
    }
    this.props.addAComment(formPayload);
    this.handleClearForm(event)
  }

  render() {
// on click i would like you to make this change

    return(
      <form onSubmit={this.handleCommentSubmit}>
        <div>
          Add a comment:
          <TextField
            content={this.state.body}
            label=""
            name="body"
            handleChange={this.handleChange}
          />
        <input className="button" type="submit" value="Submit" />
        </div>
      </form>

    )
  }
}

export default CommentsFormContainer
