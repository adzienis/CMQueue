SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: course_1; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA course_1;


--
-- Name: course_2; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA course_2;


--
-- Name: course_3; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA course_3;


--
-- Name: course_6; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA course_6;


--
-- Name: check_duplicate_question(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_duplicate_question() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            DECLARE
              state integer;
            BEGIN
              state := (select question_states.state from question_states where question_states.id = 
              (select max(question_states.id) from question_states 
                inner join questions on questions.id = question_states.question_id 
                inner join enrollments on enrollments.id = questions.enrollment_id
                where enrollments.id = NEW.enrollment_id and questions.discarded_at is null));
            
            if state IS NULL OR (state in (2,4))  then
            return NEW;
            end if;
            
            raise exception 'question already exists';
            
            
            END
            $$;


--
-- Name: check_state_constraint(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.check_state_constraint() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                  DECLARE
                    state bigint;
                  BEGIN
LOCK question_states IN ACCESS EXCLUSIVE MODE;
                    state := (select question_states.state from question_states where question_states.id = 
                    (select max(question_states.id) from question_states
                      inner join questions on questions.id = NEW.question_id
                      WHERE questions.discarded_at IS NOT NULL));
                  if state IS NULL OR (state != NEW.state)  then
                  return NEW;
                  end if;
                  raise exception 'question already transitioned to same state';
                  END
                  $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses (
    id bigint NOT NULL,
    name character varying,
    course_code character varying,
    student_code character varying,
    ta_code character varying,
    instructor_code character varying,
    open boolean DEFAULT false,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: courses; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.courses AS
 SELECT courses.id,
    courses.name,
    courses.course_code,
    courses.student_code,
    courses.ta_code,
    courses.instructor_code,
    courses.open,
    courses.created_at,
    courses.updated_at
   FROM public.courses
  WHERE (courses.id = 1);


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollments (
    id bigint NOT NULL,
    user_id bigint,
    role_id bigint,
    semester character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    discarded_at timestamp without time zone,
    section character varying,
    archived_at timestamp without time zone
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    name character varying,
    resource_type character varying,
    resource_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: enrollments; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.enrollments AS
 SELECT enrollments.id,
    enrollments.user_id,
    enrollments.role_id,
    enrollments.semester,
    enrollments.created_at,
    enrollments.updated_at,
    enrollments.discarded_at,
    enrollments.section
   FROM (public.enrollments
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 1);


--
-- Name: question_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_states (
    id bigint NOT NULL,
    question_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    description text,
    state integer NOT NULL,
    enrollment_id bigint NOT NULL,
    acknowledged_at timestamp with time zone
);


--
-- Name: question_states; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.question_states AS
 SELECT question_states.id,
    question_states.question_id,
    question_states.created_at,
    question_states.updated_at,
    question_states.description,
    question_states.state,
    question_states.enrollment_id,
    question_states.acknowledged_at
   FROM ((public.question_states
     JOIN public.enrollments ON ((question_states.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 1));


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    title text,
    tried text,
    description text,
    notes text,
    location text,
    discarded_at timestamp without time zone,
    enrollment_id bigint NOT NULL
);


--
-- Name: questions; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.questions AS
 SELECT questions.id,
    questions.created_at,
    questions.updated_at,
    questions.title,
    questions.tried,
    questions.description,
    questions.notes,
    questions.location,
    questions.discarded_at,
    questions.enrollment_id
   FROM ((public.questions
     JOIN public.enrollments ON ((enrollments.id = questions.enrollment_id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE ((roles.resource_id = 1) AND ((roles.resource_type)::text = 'Course'::text));


--
-- Name: questions_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.questions_tags (
    id bigint NOT NULL,
    question_id bigint,
    tag_id bigint
);


--
-- Name: questions_tags; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.questions_tags AS
 SELECT questions_tags.id,
    questions_tags.question_id,
    questions_tags.tag_id
   FROM (((public.questions_tags
     JOIN public.questions ON ((questions_tags.question_id = questions.id)))
     JOIN public.enrollments ON ((questions.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 1);


--
-- Name: roles; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.roles AS
 SELECT roles.id,
    roles.name,
    roles.resource_type,
    roles.resource_id,
    roles.created_at,
    roles.updated_at
   FROM public.roles
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 1));


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    course_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    archived boolean DEFAULT true,
    name text DEFAULT ''::text,
    description text DEFAULT ''::text,
    discarded_at timestamp without time zone
);


--
-- Name: tags; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.tags AS
 SELECT tags.id,
    tags.course_id,
    tags.created_at,
    tags.updated_at,
    tags.archived,
    tags.name,
    tags.description,
    tags.discarded_at
   FROM public.tags
  WHERE (tags.course_id = 1);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    given_name text,
    family_name text,
    email text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: users; Type: VIEW; Schema: course_1; Owner: -
--

CREATE VIEW course_1.users AS
 SELECT users.id,
    users.given_name,
    users.family_name,
    users.email,
    users.created_at,
    users.updated_at
   FROM ((public.users
     JOIN public.enrollments ON ((users.id = enrollments.user_id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 1));


--
-- Name: question_states; Type: VIEW; Schema: course_2; Owner: -
--

CREATE VIEW course_2.question_states AS
 SELECT question_states.id,
    question_states.question_id,
    question_states.created_at,
    question_states.updated_at,
    question_states.description,
    question_states.state,
    question_states.enrollment_id,
    question_states.acknowledged_at
   FROM ((public.question_states
     JOIN public.enrollments ON ((question_states.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 2));


--
-- Name: questions_tags; Type: VIEW; Schema: course_2; Owner: -
--

CREATE VIEW course_2.questions_tags AS
 SELECT questions_tags.id,
    questions_tags.question_id,
    questions_tags.tag_id
   FROM (((public.questions_tags
     JOIN public.questions ON ((questions_tags.question_id = questions.id)))
     JOIN public.enrollments ON ((questions.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 2);


--
-- Name: roles; Type: VIEW; Schema: course_2; Owner: -
--

CREATE VIEW course_2.roles AS
 SELECT roles.id,
    roles.name,
    roles.resource_type,
    roles.resource_id,
    roles.created_at,
    roles.updated_at
   FROM public.roles
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 2));


--
-- Name: users; Type: VIEW; Schema: course_2; Owner: -
--

CREATE VIEW course_2.users AS
 SELECT users.id,
    users.given_name,
    users.family_name,
    users.email,
    users.created_at,
    users.updated_at
   FROM ((public.users
     JOIN public.enrollments ON ((users.id = enrollments.user_id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 2));


--
-- Name: courses; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.courses AS
 SELECT courses.id,
    courses.name,
    courses.course_code,
    courses.student_code,
    courses.ta_code,
    courses.instructor_code,
    courses.open,
    courses.created_at,
    courses.updated_at
   FROM public.courses
  WHERE (courses.id = 3);


--
-- Name: enrollments; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.enrollments AS
 SELECT enrollments.id,
    enrollments.user_id,
    enrollments.role_id,
    enrollments.semester,
    enrollments.created_at,
    enrollments.updated_at,
    enrollments.discarded_at,
    enrollments.section
   FROM (public.enrollments
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 3);


--
-- Name: question_states; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.question_states AS
 SELECT question_states.id,
    question_states.question_id,
    question_states.created_at,
    question_states.updated_at,
    question_states.description,
    question_states.state,
    question_states.enrollment_id,
    question_states.acknowledged_at
   FROM ((public.question_states
     JOIN public.enrollments ON ((question_states.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 3));


--
-- Name: questions; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.questions AS
 SELECT questions.id,
    questions.created_at,
    questions.updated_at,
    questions.title,
    questions.tried,
    questions.description,
    questions.notes,
    questions.location,
    questions.discarded_at,
    questions.enrollment_id
   FROM ((public.questions
     JOIN public.enrollments ON ((enrollments.id = questions.enrollment_id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE ((roles.resource_id = 3) AND ((roles.resource_type)::text = 'Course'::text));


--
-- Name: questions_tags; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.questions_tags AS
 SELECT questions_tags.id,
    questions_tags.question_id,
    questions_tags.tag_id
   FROM (((public.questions_tags
     JOIN public.questions ON ((questions_tags.question_id = questions.id)))
     JOIN public.enrollments ON ((questions.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 3);


--
-- Name: roles; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.roles AS
 SELECT roles.id,
    roles.name,
    roles.resource_type,
    roles.resource_id,
    roles.created_at,
    roles.updated_at
   FROM public.roles
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 3));


--
-- Name: tags; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.tags AS
 SELECT tags.id,
    tags.course_id,
    tags.created_at,
    tags.updated_at,
    tags.archived,
    tags.name,
    tags.description,
    tags.discarded_at
   FROM public.tags
  WHERE (tags.course_id = 3);


--
-- Name: users; Type: VIEW; Schema: course_3; Owner: -
--

CREATE VIEW course_3.users AS
 SELECT users.id,
    users.given_name,
    users.family_name,
    users.email,
    users.created_at,
    users.updated_at
   FROM ((public.users
     JOIN public.enrollments ON ((users.id = enrollments.user_id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 3));


--
-- Name: courses; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.courses AS
 SELECT courses.id,
    courses.name,
    courses.course_code,
    courses.student_code,
    courses.ta_code,
    courses.instructor_code,
    courses.open,
    courses.created_at,
    courses.updated_at
   FROM public.courses
  WHERE (courses.id = 6);


--
-- Name: enrollments; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.enrollments AS
 SELECT enrollments.id,
    enrollments.user_id,
    enrollments.role_id,
    enrollments.semester,
    enrollments.created_at,
    enrollments.updated_at,
    enrollments.discarded_at,
    enrollments.section
   FROM (public.enrollments
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 6);


--
-- Name: question_states; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.question_states AS
 SELECT question_states.id,
    question_states.question_id,
    question_states.created_at,
    question_states.updated_at,
    question_states.description,
    question_states.state,
    question_states.enrollment_id,
    question_states.acknowledged_at
   FROM ((public.question_states
     JOIN public.enrollments ON ((question_states.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 6));


--
-- Name: questions; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.questions AS
 SELECT questions.id,
    questions.created_at,
    questions.updated_at,
    questions.title,
    questions.tried,
    questions.description,
    questions.notes,
    questions.location,
    questions.discarded_at,
    questions.enrollment_id
   FROM ((public.questions
     JOIN public.enrollments ON ((enrollments.id = questions.enrollment_id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE ((roles.resource_id = 6) AND ((roles.resource_type)::text = 'Course'::text));


--
-- Name: questions_tags; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.questions_tags AS
 SELECT questions_tags.id,
    questions_tags.question_id,
    questions_tags.tag_id
   FROM (((public.questions_tags
     JOIN public.questions ON ((questions_tags.question_id = questions.id)))
     JOIN public.enrollments ON ((questions.enrollment_id = enrollments.id)))
     JOIN public.roles ON ((roles.id = enrollments.role_id)))
  WHERE (roles.resource_id = 6);


--
-- Name: roles; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.roles AS
 SELECT roles.id,
    roles.name,
    roles.resource_type,
    roles.resource_id,
    roles.created_at,
    roles.updated_at
   FROM public.roles
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 6));


--
-- Name: tags; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.tags AS
 SELECT tags.id,
    tags.course_id,
    tags.created_at,
    tags.updated_at,
    tags.archived,
    tags.name,
    tags.description,
    tags.discarded_at
   FROM public.tags
  WHERE (tags.course_id = 6);


--
-- Name: users; Type: VIEW; Schema: course_6; Owner: -
--

CREATE VIEW course_6.users AS
 SELECT users.id,
    users.given_name,
    users.family_name,
    users.email,
    users.created_at,
    users.updated_at
   FROM ((public.users
     JOIN public.enrollments ON ((users.id = enrollments.user_id)))
     JOIN public.roles ON ((enrollments.role_id = roles.id)))
  WHERE (((roles.resource_type)::text = 'Course'::text) AND (roles.resource_id = 6));


--
-- Name: analytics_dashboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_dashboards (
    id bigint NOT NULL,
    data jsonb,
    course_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: analytics_dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analytics_dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analytics_dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analytics_dashboards_id_seq OWNED BY public.analytics_dashboards.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id bigint NOT NULL,
    title character varying DEFAULT ''::character varying,
    description text DEFAULT ''::text,
    visible boolean DEFAULT true,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    data bytea,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificates_id_seq OWNED BY public.certificates.id;


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.courses_id_seq OWNED BY public.courses.id;


--
-- Name: courses_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses_questions (
    course_id bigint,
    question_id bigint
);


--
-- Name: courses_registrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses_registrations (
    id bigint NOT NULL,
    name text NOT NULL,
    approved boolean DEFAULT false,
    instructor_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: courses_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.courses_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.courses_registrations_id_seq OWNED BY public.courses_registrations.id;


--
-- Name: courses_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses_sections (
    id bigint NOT NULL,
    course_id bigint,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: courses_sections_enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.courses_sections_enrollments (
    courses_section_id bigint,
    enrollment_id bigint
);


--
-- Name: courses_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.courses_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.courses_sections_id_seq OWNED BY public.courses_sections.id;


--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_members (
    id bigint NOT NULL,
    individual_id integer,
    individual_type character varying,
    group_id integer,
    group_type character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.group_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.group_members_id_seq OWNED BY public.group_members.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    recipient_type character varying NOT NULL,
    recipient_id bigint NOT NULL,
    type character varying NOT NULL,
    params jsonb,
    read_at timestamp without time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id bigint NOT NULL,
    resource_owner_id bigint NOT NULL,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    resource_owner_type character varying NOT NULL
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_grants_id_seq OWNED BY public.oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id bigint NOT NULL,
    resource_owner_id bigint,
    application_id bigint NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL,
    resource_owner_type character varying
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_access_tokens_id_seq OWNED BY public.oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    owner_id bigint,
    owner_type character varying
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oauth_applications_id_seq OWNED BY public.oauth_applications.id;


--
-- Name: question_queues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.question_queues (
    id bigint NOT NULL,
    course_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    archived boolean DEFAULT true
);


--
-- Name: question_queues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.question_queues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_queues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.question_queues_id_seq OWNED BY public.question_queues.id;


--
-- Name: question_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.question_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.question_states_id_seq OWNED BY public.question_states.id;


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.questions_id_seq OWNED BY public.questions.id;


--
-- Name: questions_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.questions_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.questions_tags_id_seq OWNED BY public.questions_tags.id;


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    resource_type character varying,
    resource_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    bag jsonb DEFAULT '{}'::jsonb
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: tag_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_groups (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    name character varying NOT NULL,
    description text DEFAULT ''::text,
    validations jsonb,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: tag_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_groups_id_seq OWNED BY public.tag_groups.id;


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_roles (
    user_id bigint,
    role_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: analytics_dashboards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_dashboards ALTER COLUMN id SET DEFAULT nextval('public.analytics_dashboards_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates ALTER COLUMN id SET DEFAULT nextval('public.certificates_id_seq'::regclass);


--
-- Name: courses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses ALTER COLUMN id SET DEFAULT nextval('public.courses_id_seq'::regclass);


--
-- Name: courses_registrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses_registrations ALTER COLUMN id SET DEFAULT nextval('public.courses_registrations_id_seq'::regclass);


--
-- Name: courses_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses_sections ALTER COLUMN id SET DEFAULT nextval('public.courses_sections_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: group_members id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members ALTER COLUMN id SET DEFAULT nextval('public.group_members_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: oauth_access_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_grants_id_seq'::regclass);


--
-- Name: oauth_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.oauth_access_tokens_id_seq'::regclass);


--
-- Name: oauth_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications ALTER COLUMN id SET DEFAULT nextval('public.oauth_applications_id_seq'::regclass);


--
-- Name: question_queues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_queues ALTER COLUMN id SET DEFAULT nextval('public.question_queues_id_seq'::regclass);


--
-- Name: question_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_states ALTER COLUMN id SET DEFAULT nextval('public.question_states_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions ALTER COLUMN id SET DEFAULT nextval('public.questions_id_seq'::regclass);


--
-- Name: questions_tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions_tags ALTER COLUMN id SET DEFAULT nextval('public.questions_tags_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: tag_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_groups ALTER COLUMN id SET DEFAULT nextval('public.tag_groups_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: analytics_dashboards analytics_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_dashboards
    ADD CONSTRAINT analytics_dashboards_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: courses_registrations courses_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses_registrations
    ADD CONSTRAINT courses_registrations_pkey PRIMARY KEY (id);


--
-- Name: courses_sections courses_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses_sections
    ADD CONSTRAINT courses_sections_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: question_queues question_queues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_queues
    ADD CONSTRAINT question_queues_pkey PRIMARY KEY (id);


--
-- Name: question_states question_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_states
    ADD CONSTRAINT question_states_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: questions_tags questions_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions_tags
    ADD CONSTRAINT questions_tags_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: tag_groups tag_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_groups
    ADD CONSTRAINT tag_groups_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_analytics_dashboards_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_analytics_dashboards_on_course_id ON public.analytics_dashboards USING btree (course_id);


--
-- Name: index_certificates_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_certificates_on_course_id ON public.certificates USING btree (course_id);


--
-- Name: index_courses_questions_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_questions_on_course_id ON public.courses_questions USING btree (course_id);


--
-- Name: index_courses_questions_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_questions_on_question_id ON public.courses_questions USING btree (question_id);


--
-- Name: index_courses_sections_enrollments_on_courses_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_sections_enrollments_on_courses_section_id ON public.courses_sections_enrollments USING btree (courses_section_id);


--
-- Name: index_courses_sections_enrollments_on_enrollment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_sections_enrollments_on_enrollment_id ON public.courses_sections_enrollments USING btree (enrollment_id);


--
-- Name: index_courses_sections_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_courses_sections_on_course_id ON public.courses_sections USING btree (course_id);


--
-- Name: index_enrollments_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_discarded_at ON public.enrollments USING btree (discarded_at);


--
-- Name: index_enrollments_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_role_id ON public.enrollments USING btree (role_id);


--
-- Name: index_enrollments_on_semester; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_semester ON public.enrollments USING btree (semester);


--
-- Name: index_enrollments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_user_id ON public.enrollments USING btree (user_id);


--
-- Name: index_notifications_on_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_read_at ON public.notifications USING btree (read_at);


--
-- Name: index_notifications_on_recipient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_recipient ON public.notifications USING btree (recipient_type, recipient_id);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_question_queues_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_queues_on_course_id ON public.question_queues USING btree (course_id);


--
-- Name: index_question_states_on_enrollment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_states_on_enrollment_id ON public.question_states USING btree (enrollment_id);


--
-- Name: index_question_states_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_states_on_question_id ON public.question_states USING btree (question_id);


--
-- Name: index_questions_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_on_discarded_at ON public.questions USING btree (discarded_at);


--
-- Name: index_questions_on_enrollment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_on_enrollment_id ON public.questions USING btree (enrollment_id);


--
-- Name: index_questions_tags_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_tags_on_question_id ON public.questions_tags USING btree (question_id);


--
-- Name: index_questions_tags_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_tags_on_tag_id ON public.questions_tags USING btree (tag_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_roles_on_name_and_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_name_and_resource_type_and_resource_id ON public.roles USING btree (name, resource_type, resource_id);


--
-- Name: index_roles_on_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_resource ON public.roles USING btree (resource_type, resource_id);


--
-- Name: index_settings_on_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_settings_on_resource ON public.settings USING btree (resource_type, resource_id);


--
-- Name: index_tag_groups_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_groups_on_course_id ON public.tag_groups USING btree (course_id);


--
-- Name: index_tags_on_course_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_course_id ON public.tags USING btree (course_id);


--
-- Name: index_tags_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_discarded_at ON public.tags USING btree (discarded_at);


--
-- Name: index_users_roles_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_role_id ON public.users_roles USING btree (role_id);


--
-- Name: index_users_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id ON public.users_roles USING btree (user_id);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON public.users_roles USING btree (user_id, role_id);


--
-- Name: polymorphic_owner_oauth_access_grants; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX polymorphic_owner_oauth_access_grants ON public.oauth_access_grants USING btree (resource_owner_id, resource_owner_type);


--
-- Name: polymorphic_owner_oauth_access_tokens; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX polymorphic_owner_oauth_access_tokens ON public.oauth_access_tokens USING btree (resource_owner_id, resource_owner_type);


--
-- Name: questions check_duplicate_question_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_duplicate_question_trigger BEFORE INSERT ON public.questions FOR EACH ROW EXECUTE FUNCTION public.check_duplicate_question();


--
-- Name: question_states check_state_constraint_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_state_constraint_trigger BEFORE INSERT ON public.question_states FOR EACH ROW EXECUTE FUNCTION public.check_state_constraint();


--
-- Name: courses_questions fk_rails_025040746f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses_questions
    ADD CONSTRAINT fk_rails_025040746f FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: question_states fk_rails_0b8ad6b6fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_states
    ADD CONSTRAINT fk_rails_0b8ad6b6fb FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: tag_groups fk_rails_3f646a74cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_groups
    ADD CONSTRAINT fk_rails_3f646a74cf FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: questions_tags fk_rails_3fd077fb33; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions_tags
    ADD CONSTRAINT fk_rails_3fd077fb33 FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: certificates fk_rails_4affdaec3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT fk_rails_4affdaec3e FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: analytics_dashboards fk_rails_601e18b240; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_dashboards
    ADD CONSTRAINT fk_rails_601e18b240 FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- Name: question_states fk_rails_70d06a7903; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.question_states
    ADD CONSTRAINT fk_rails_70d06a7903 FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: courses_questions fk_rails_8afe15e6d2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.courses_questions
    ADD CONSTRAINT fk_rails_8afe15e6d2 FOREIGN KEY (question_id) REFERENCES public.questions(id);


--
-- Name: questions_tags fk_rails_98659cdfc1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions_tags
    ADD CONSTRAINT fk_rails_98659cdfc1 FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: questions fk_rails_c35c43e10f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT fk_rails_c35c43e10f FOREIGN KEY (enrollment_id) REFERENCES public.enrollments(id);


--
-- Name: enrollments fk_rails_d1e7d10c0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_d1e7d10c0a FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: enrollments fk_rails_e860e0e46b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_e860e0e46b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tags fk_rails_f5f6cbb85f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT fk_rails_f5f6cbb85f FOREIGN KEY (course_id) REFERENCES public.courses(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210407025550'),
('20210407025620'),
('20210407223036'),
('20210407224612'),
('20210407224826'),
('20210414234259'),
('20210415165206'),
('20210415171742'),
('20210429033320'),
('20210429173311'),
('20210523033554'),
('20210608212307'),
('20210613181243'),
('20210616164906'),
('20210621015845'),
('20210622014443'),
('20210624051801'),
('20210624144957'),
('20210627150537'),
('20210627202209'),
('20210701224331'),
('20210701224457'),
('20210703035725'),
('20210711051202'),
('20210712150707'),
('20210816184122'),
('20210917210147'),
('20210917210227'),
('20210928053422'),
('20210928145344'),
('20211003204929'),
('20211016001702'),
('20211017222247'),
('20211114044300'),
('20211118074023'),
('20211119031040'),
('20211119032313'),
('20211211052838'),
('20211223235232'),
('20220105043704');


