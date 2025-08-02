# WXLOOKUP

This is a simple project for retrieving weather information from weatherapi.com and
displaying the results in a browser window.

## Requirements
For this project, I used:
* Ruby 3.4.4
* Rails 8.0.2
* RSpec 3.13
* Turbo 2.0.16
* Tailwind CSS 4.1.11

## Installation and Setup
For setup in a development environment, clone this Git repo. Assuming you have a
Ruby and Bundler environment already setup, all that's needed to start the webapp
is to run:
* `bundle install`
* `export WEATHER_API_KEY='$YOUR_API_KEY_HERE'`
* `bin/dev`

weatherapi.com requires an API key in order to do weather queries. If the 
`$WEATHER_API_KEY` environment variable is not set, the webapp will stop with an error.


## Design Discussion
This project is done entirely using Ruby on Rails. There is no JavaScript aspect
to it. The webapp is a single page application, utilizing Turbo to replace a DOM
node with the weather query results. (Turbo replaced the older Rails UJS library,
also known as Unobtrusive JavaScript. Turbo is the supported library in Rails 7/8,
and has the added benefit of not requiring jQuery.)

The queries to weatherapi.com are done using an external service object called
`WeatherApi`. There are separate implementations for getting *current observations*
and *forecasts*. For both methods, the service object deals with querying of the
API and caching the results for 30 minutes. The service object response will show
if the data being returned is cached or not.

Queries to weatherapi.com are done using RESTful calls to their openapi interface,
retrieving results in JSON format. The results are cached using Rails' built-in
cache store. In the development environment, this cache is configured to be
written out to the `tmp/cache/` subdirectory.

Originally, I had planned to use a SQLite3 datastore for this, but then discovered
that `Rails.cache` would be easiest. It wasn't necessary for me to create a
relational database schema to store weather data; only that it needed to be "keyed"
based on the location. This saved me time.

The "key" isn't perfect. The original requirements said to cache results based on
ZIP codes. But in my implementation, I was completely relying on the weatherapi.com
interface to do location validation. It wasn't possible for me to get a ZIP code or
latitude/longitude information without actually doing the API call... and that wouldn't
be caching. So, I created my own cache key. It handles whitespace and capitalization
variations, but cannot tell if "Toronto", "Toronto Ontario", and "Toronto Canada" are
the same location or not.

The cached weather information automatically expires in 30 minutes.

Interactions with Weather API are configured by `config/initializers/weather_api.rb`.



## Developer Comments
I did some formatting of the current temperature, but ran out of time with doing
the rest. I had hoped to do a nice rendering of most all the JSON fields returned
by the API. (I may continue on this in the future). This assignment was focused
on the backend work, so I trust that anyone reviewing this will be comfortable
with reading JSON directly. ;)

For formatting, I used the TailWind CSS framework.

Testing is done using the RSpec behaviour-driven test framework. (The one I've used
the most). And I've configured simplecov to generate a test code coverage report.
At time of writing, I have >98% test coverage. The automated tests can be executed
by running `bin/rails spec`.


## Thanks!
Thanks for the opportunity to do this! It was a fun little project, and I enjoyed
working on it. If you have any questions for me, please contact me. I'd love to
talk to you.

Kind regards, \
Paul

Paul Walrath \
paul@walrath.ca \
https://github.com/paulwalrath \
https://www.linkedin.com/in/paulwalrath/ 