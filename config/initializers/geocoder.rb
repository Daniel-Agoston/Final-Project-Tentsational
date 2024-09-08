Geocoder.configure(
  # Geocoding options
  timeout: 5,                     # geocoding service timeout (secs)
  lookup: :mapbox,                # set the geocoding service to Mapbox
  api_key: ENV['MAPBOX_API_KEY'], # use the API key from the environment variable
  use_https: true,                # ensure requests are made over HTTPS
  units: :km,                     # set units to kilometers

  # Distance Calculation
  distances: :spherical,          # Use Haversine formula for distance calculations

  # IP address geocoding service
  ip_lookup: :ipinfo_io,          # optional, only if you want to configure IP geolocation separately

  # Exception handling
  always_raise: [Geocoder::OverQueryLimitError, Geocoder::RequestDenied, Geocoder::InvalidRequest],

  # Cache configuration (optional)
  # cache: Redis.new,               # specify a Redis cache instance
  # cache_prefix: 'geocoder:',      # prefix for cache keys
  # cache_options: { expiration: 1.day } # set cache expiration

  # Language configuration (optional)
  language: :en                   # ISO-639 language code, if needed
)
