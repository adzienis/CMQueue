# Summary

This is a Ruby on Rails powered office hours queue. The website allows multiple
courses to create and manage their office hours queues. The main motivation of this
project is to allow better insight and transparency with the analysis of office
hours. To that end, the "queue" is built with many features in order to better
track and augment office hours.

# Features

1. A traditional office hours queue, where students can ask questions, and TA's
   can answer them.

2. Tracking entire life cycle of question (when it was created, when/why was it
   frozen, split/categorize questions based on content).

3. Summarize data from across entire semesters/multiple courses.

4. REST based API to allow course authorized applications to access data to enable
   further, independent features.

5. Course management of semesters, roles, rosters, tags, and questions.

6. Importing and exporting data from CSV files.

## Motivation

The goal is to have a website, that doesn't necessarily do everything, but has
enough features for us to pull out information to summarize office hours
performance (and hopefully try to make 90 student long office hours not so
unbearable for everyone). The website has some basic course management, with an
emphasis on being able to export the data through the REST API or manually, to
perform more analytics somewhere else.

Currently, very general insight on course performance comes from an integration
with Metabase, which gives a pretty good "no-code" solution to interpreting the
data, but it is still general, and its probably better to get more specific
information.

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
at the `/swagger` endpoint.

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

### Course Management

The course can be managed directly from the course settings.

### Site Management

Overall site management is provided through `Rails Admin`. This gives a lot of
access and control over the entire site. This looks ok, but this apparently has
problems with joins over models.

### Models

There is an included entity relation diagram that helps clear up the relations.


# Commands

## Development

Run `make run_dev` to run the development environment. This uses docker compose
under the hood, which sets up Postgres and Redis. Run `make stop_dev` to stop
the containers. Run `make down_dev` to bring it down. 
To run the server, `cd` into the server folder, and run `bundle exec rails s`.

## Production

Run `make run_prod`. Run `make stop_prod` to stop the containers. 
Run `make down_prod` to bring it down.

## Tests

Run `make run_test`. Run `make stop_test` to stop the containers.
Run `make down_test` to bring it down.