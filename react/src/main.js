import 'babel-polyfill';
import React from 'react';
import ReactDOM from 'react-dom';
// need to remove event listener
$(function() {
  ReactDOM.render(
    <h1>Boo yaa</h1>,
    document.getElementById('app')
  );
});
// document.addEventListener('DOMContentLoaded', function() {
//   ReactDOM.render(
//     <App />,
//     document.getElementById('app')
//   )
// })
