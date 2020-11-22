import React from 'react';
import { Router, Redirect, browserHistory, Route, IndexRoute } from 'react-router';
import NavBar from '../components/NavBar'
import GamesShowContainer from './GamesShowContainer'
import CommentsIndexContainer from './CommentsIndexContainer'
import HomePageContainer from './HomePageContainer'

const App = props => {
  return (
    <Router history={browserHistory}>
      <Route path='/games/:id' component={GamesShowContainer} />
      <Route path='/games/:game_id/comments' component={CommentsIndexContainer} />
      <Route path='*' component={HomePageContainer} />
    </Router>
  )
}

export default App
