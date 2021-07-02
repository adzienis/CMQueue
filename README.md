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

# Development

## Motivation

The goal is to have a website, that doesn't necessarily do everything, but has
enough features for us to pull out information to summarize office hours
performance (and hopefully try to make 90 student long office hours not so
unbearable for everyone). The website has some basic course management, with an
emphasis on being able to export the data through the REST api or manually, to
perform more analytics somewhere else.

Currently, very general insight on course performance comes from an integration
with Metabase, which gives a pretty good "no-code" solution to interpreting the
data, but it is still general, and its probably better to get more specific
information.

## Summary

### Views

The website mainly consists of traditional server side templates, but some components
are written in React for the more interactive parts of the site that would be
unbearable to write server side (such as question answering and waiting).

The React components are either used in other components, or are directly
rendered to the DOM. The components heavily dependent on `react-query` to
fetch data from the REST api, and declaratively render it.

### REST api

The REST api is used for both the the various React components scattered about,
as well as for applications authorized by the course. The endpoints are documented
at the `/swagger` endpoint.



### Models