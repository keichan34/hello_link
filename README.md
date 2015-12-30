# HelloLink

HelloLink uses Instagram's streaming API. In order to enable it, Instagram's servers
need to be able to access your localhost. Use something like [localtunnel](http://localtunnel.me)
to proxy your port 4000 (Phoenix default) to the world, and set the URL accordingly in
`config/dev.secret.exs`.

Please note that you will need to set up both App.Net and Instagram apps to retrieve
the necessary OAuth client ID and secrets.

## Preparation

  1. Configure your Instagram and App.Net tokens in `config/dev.secret.exs` (use `dev.secret.example.exs` as a template)
  2. Install dependencies with `mix deps.get`
  3. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  4. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
