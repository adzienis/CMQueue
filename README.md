# Summary

This is a Ruby on Rails powered office hours queue. This is the continuation of a pre-existing
office hours queue for [CMQueue](https://cmqueue.xyz) that was written primarily with Node.js, and React.
The website allows multiple courses to create and manage their office hours queues. The main motivation of this
project is to allow better insight and transparency with the analysis of office
hours. To that end, the "queue" is built with many features in order to better
track and augment office hours.

### Features

1. A traditional office hours queue, where students can ask questions, and TA's
   can answer them.

2. Tracking entire life cycle of question (when it was created, when/why was it
   frozen, split/categorize questions based on content).

3. REST based API to allow course authorized applications to access data to enable
   further, independent features.

4. Course management of semesters, roles, rosters, tags, and questions.

5. Importing and exporting data from CSV files.

6. Ability for students, and TA's to review their own questions/interactions from
   across courses/semesters.
   
8. Can integrate with third party tools such as PowerBI/Tableau/any other analysis tool
  that can connect to PostgreSQL (database is exposed in a secure manner using TLS certificate
   authentication, as well as restricted to read only views of secured schemas with strict
   permissions)

### Motivation

The goal is to have a website, that doesn't necessarily do everything, but has
enough features for to pull out information to summarize office hours
performance (and hopefully try to make 90 student long office hours not so
unbearable for everyone). The website has some basic course management, with an
emphasis on being able to export the data through the REST API or manually, to
perform more analytics somewhere else.

Currently, very general insight on course performance comes from an integration
with Metabase, which gives a pretty good "no-code" solution to interpreting the
data, but it is still general, and its probably better to get more specific
information.

### Future Features

* Make this into a PaaS with strict multi-tenancy, or as a self-hosted version.

* While the REST API exists with a large number of endpoints, it would be interesting to have it
  entirely fleshed out so that it is possible to get a large amount of functionality through
  separate applications (maybe overzealous, but to enable the development of an app).
  
* Flesh out both course and user settings.

* Currently, to manage multiple courses, they are all separated out by explicit endpoints (must go
  to `...courses/1/questions` to get questions for a particular course, even if you manage multiple
  courses). Possibly may look into `hotwire` to get this working, but it would be interesting to see
  if it can be done with just passing an array of course id's into the url (so it would be
  `...courses/questions?course_ids=[1,2]`)

* Flesh out analytics: the data is there, and there are sections in the code for embedding
  external graphs. But not sure whether it would be better to spend effort on statistics on
  the site, vs investing time into a proper analytics tool (PowerBI/Excel sheets?).


# Summary

See [parent repo](https://github.com/adzienis/OH-Queuing) for a more general description.

# Future

* It would be great to offer a combination of a self hosted version as well as a more general,
  hardened, multi-tenancy PaaS; ideally using subdomains.
* Analytics currently somewhat manually done with [Metabase](https://www.metabase.com/).
Current system is currently headed towards decoupling of the analysis, with the instructor able
  to hook in their own third-party analytics tool (Metabase, Google Data Studio...). Possibly may
  look into a more dedicated, but effort intensive, direct integration.

# Demo

[Demo](https://cmqueue-demo.herokuapp.com)

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
