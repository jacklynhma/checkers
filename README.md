![Build Status](https://codeship.com/projects/68475c30-56db-0135-3fa1-7e1de17b1d2f/status?branch=master)
![Code Climate](https://codeclimate.com/github/jacklynhma/checkers.png)
[![Coverage Status](https://coveralls.io/repos/github/jacklynhma/checkers/badge.svg)](https://coveralls.io/github/jacklynhma/checkers)

# README

Team Checkers
========================

Contributors:
- Jacklyn Ma
Link to app: http://team-checkers.herokuapp.com/

Description:

Team Checkers is a react on rails app, that allows users to create teams and play checkers. When a user enters a site, they will see a list of games and they have the option of being a spectator or joining a game. After the user has joined a game, a team will automatically be assigned to them

There is logic in the backend that checks if the user is making any illegal moves, has any required moves, and if they have won.

Users can click on a piece and the board will highlight any possible moves for that certain piece

After the game is over, if the players wish to review the game, there is a replay button below the chat forum

Technologies:
====
- Backend Rails 5.1.2
- Frontend: React.js, CSS, Bootstrap
- User Auth: Devise
- Database: Postgres
- Testing: RSpec, Capybara, Jasmine, Karma, Enzyme

Setup
======
git clone https://github.com/jacklynhma/checkers.git
``
bundle install
npm install
rake db:migrate
rails s
``
In another window, run:
`````
npm start
```
