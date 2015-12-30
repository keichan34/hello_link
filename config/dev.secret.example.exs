use Mix.Config

config :hello_link,
  instagram_client_id: "",
  instagram_client_secret: "",
  adn_client_id: "",
  adn_client_secret: ""

config :hello_link, HelloLink.Endpoint,
  secret_key_base: "xYAwE6HDsdjr0x0kUfapkM7qalO0aDCmmydk5b+aHShvjpTXemjLC4ph3arrmnOG"

# config :hello_link, HelloLink.Endpoint,
#   url: [host: "XXXXXX.localtunnel.me", port: 443, scheme: "https"]
