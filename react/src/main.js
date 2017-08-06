import 'babel-polyfill';
import React from 'react';
import ReactDOM from 'react-dom';
import App from './containers/App'

document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('app')){
    ReactDOM.render(
      <App />,
      document.getElementById('app')
    )
  }
})
