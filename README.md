# KCC Rails App

This repository stores the code for the KCC Rails app.
Currently all code is still related to the non-profit this app was originally for

The stack is:

- Ruby on Rails 6.0 with react-on-rails/webpacker
- Tailwind CSS (for now..)
- Postgres

# Running app locally

## Dependencies

- ruby `2.6.3`
- bundler `2.1.4`
- postgres

## Installation

Install and start postgresql:
- On macOS, you can use `pg_ctl -D /usr/local/var/postgres start`
- (To stop postgres use `pg_ctl -D /usr/local/var/postgres stop`)

Install dependencies:

```
bundle install
yarn install
```

Setup the database:

```
rails db:setup
rails db:migrate
```

## Configuration

Check config/initializers to edit coaches(admins), team, and email settings. All other settings can be configured in settings.yml

Devs can add their email to the coaches.rb initializer to see the admin view.

## Launch app

start dev server
```
./bin/webpack-dev-server
```
in separate terminal
```
rails server
```

Then go to [http://localhost:3000](http://localhost:3000) to view app.


## Installation

See THEMING.md.

# Contributing

1. Fork the project
1. Create a branch with your changes
1. Submit a pull request

# License

MIT
