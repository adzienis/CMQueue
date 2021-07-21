

# Development

### How to Run

Run: `bundle exec rails s` to run the server. Since this project uses Postgres and Redis,
make sure that there is a Postgres instance running at port 5433, and Redis instance running
at 6380.

### Initialization/Authentication

The server uses OAuth2.0 through Google in order to authenticate users.
Therefore, this application requires secrets to be defined for the Google
credentials, among others.

Make sure to generate the `config/master.key`. Secrets are stored in
`config/credentials.yml.enc`. Secrets that must be defined to run are:

```
google:
  secret: "fill in"
  client_id: "fill in"
devise:
  secret: "fill in"
```

The `google[:secret]` is the app's secret as defined in Google's API
credentials. `google[:client_id]` is the app's client id, and isn't
really secret (in there to keep the two together).

`devise[:secret]` is Devise's base key, and needs to be defined to maintain
the session.


### Views

The website mainly consists of traditional server side templates, but some components
are written in React for the more interactive parts of the site that would be
unbearable to write server side (such as question answering and waiting).

The React components are either used in other components, or are directly
rendered to the DOM. The components heavily dependent on `react-query` to
fetch data from the REST API, and declaratively render it.

### Authentication and Authorization

Authentication is done using `Devise` and Google sign in using `Omniauth`.
Authorization is done using `CanCanCan`, with roles for courses powered by `Rolify`.

### REST API

The REST API is used for both the the various React components scattered about,
as well as for applications authorized by the course. The endpoints are documented
at the `/api/swagger` endpoint.

The REST API is built using `Grape`, with authorization through either `Devise`
when a request comes from a signed in user, and with `Doorkeeper` when done with
a course authorized application.

### `Doorkeeper`/Authorized Applications

In order to help extend the capabilities of the website, without needing to
know all the internals, it is possible for a course to allow an independent
application to query the REST API to get back information about the course. 

`Doorkeeper` allows the website act as a OAuth provider, and enable token based
authentication for REST API. The instructor of a course can create a new 
authorization for an application. The instructor can then use the corresponding
secret and uid to allow another application to use the OAuth 2.0 credentials
based authentication flow to gain access.

Ideally, this would be used by slackbots/hooks/smaller pieces of
functionality.

## Adding an application

An instructor will have access to an applications section, where they
can create new ones. A client UID and secret, will be created, and one
can create a POST with the following format to `/oauth/token` to
get a bearer token;

```
{
   "grant_type": "string",
   "client_id": "string",
   "client_secret": "string",
   "scope": {
      "type": "array",
      "items": {
         "type": "number"
      }
   }
}
```

`grant_type` should be set to `client_credentials`. 

It is important to add an appropriate set of scopes (`public` by default).

### Course Management

The course can be managed directly from the course page. It is possible to import/export a variety
models associated with the course such as questions, tags, and enrollments. 

### Site Management

Overall site management is provided through `Rails Admin`. This gives a lot of
access and control over the entire site. This looks ok, but this apparently has
problems with joins over models.

### Models

There is an included entity relation diagram [erd.pdf](./erd.pdf) that helps clear up the relations.


### Testing

Since development and production both use Postgres, and there is SQL written in the migrations,
such as for triggers, the test database also uses Postgres. Make sure that the test database
is up.
