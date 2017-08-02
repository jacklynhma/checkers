import React from 'react';
import { Router, browserHistory, Route, IndexRoute } from 'react-router';
import NavBar from '../components/NavBar'
import GamesShowContainer from './GamesShowContainer'

const App = props => {
  return (
    <Router history={browserHistory}>
      <Route path='/' component={NavBar}>
        <Route path='/games/:id' component={GamesShowContainer} />
      </Route>
    </Router>
  )
}

export default App
