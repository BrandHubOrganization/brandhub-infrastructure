--
-- PostgreSQL database dump
--

\restrict kUhJCCOGB8xnsPrBjIhcuYmokGcT4bYn20kr0EWMcoyrue0rWJQobhhszk1uID8

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: agency_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agency_category AS ENUM (
    'MARKETING',
    'FNB',
    'FASHION',
    'BEAUTY',
    'TECHNOLOGY',
    'REAL_ESTATE',
    'EDUCATION',
    'HEALTHCARE',
    'RETAIL',
    'FINANCE',
    'ENTERTAINMENT',
    'OTHER'
);


--
-- Name: agency_member_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agency_member_role AS ENUM (
    'OWNER',
    'MEMBER',
    'CLIENT'
);


--
-- Name: agencycategory; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agencycategory AS ENUM (
    'BEAUTY',
    'EDUCATION',
    'ENTERTAINMENT',
    'FASHION',
    'FINANCE',
    'FNB',
    'HEALTHCARE',
    'MARKETING',
    'OTHER',
    'REAL_ESTATE',
    'RETAIL',
    'TECHNOLOGY'
);


--
-- Name: agencymemberrole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.agencymemberrole AS ENUM (
    'CLIENT',
    'MEMBER',
    'OWNER'
);


--
-- Name: audit_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.audit_action AS ENUM (
    'LOGIN',
    'LOGOUT',
    'TOKEN_REFRESH',
    'PASSWORD_RESET',
    'CREATE',
    'UPDATE',
    'DELETE',
    'ROLE_CHANGE',
    'PERMISSION_CHANGE',
    'VIEW',
    'EXPORT'
);


--
-- Name: auditaction; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.auditaction AS ENUM (
    'CREATE',
    'DELETE',
    'EXPORT',
    'LOGIN',
    'LOGOUT',
    'PASSWORD_RESET',
    'PERMISSION_CHANGE',
    'ROLE_CHANGE',
    'TOKEN_REFRESH',
    'UPDATE',
    'VIEW'
);


--
-- Name: campaign_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.campaign_status AS ENUM (
    'DRAFT',
    'APPROVED',
    'IN_PROGRESS',
    'COMPLETED'
);


--
-- Name: campaignstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.campaignstatus AS ENUM (
    'APPROVED',
    'COMPLETED',
    'DRAFT',
    'IN_PROGRESS'
);


--
-- Name: collaborator_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collaborator_type AS ENUM (
    'NEWSPAPER',
    'BANNER',
    'TV',
    'OTHER'
);


--
-- Name: collaboratortype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collaboratortype AS ENUM (
    'BANNER',
    'NEWSPAPER',
    'OTHER',
    'TV'
);


--
-- Name: company_size; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.company_size AS ENUM (
    'SIZE_1_10',
    'SIZE_11_50',
    'SIZE_51_200',
    'SIZE_201_500',
    'SIZE_500_PLUS'
);


--
-- Name: companysize; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.companysize AS ENUM (
    'SIZE_11_50',
    'SIZE_1_10',
    'SIZE_201_500',
    'SIZE_500_PLUS',
    'SIZE_51_200'
);


--
-- Name: cooperation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cooperation_status AS ENUM (
    'CONTACTED',
    'NEGOTIATING',
    'CONFIRMED',
    'LIVE'
);


--
-- Name: cooperationstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.cooperationstatus AS ENUM (
    'CONFIRMED',
    'CONTACTED',
    'LIVE',
    'NEGOTIATING'
);


--
-- Name: entity_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entity_status AS ENUM (
    'ACTIVE',
    'SOFT_DELETED',
    'INACTIVE'
);


--
-- Name: entitystatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.entitystatus AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SOFT_DELETED'
);


--
-- Name: invitation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invitation_status AS ENUM (
    'PENDING',
    'ACCEPTED',
    'EXPIRED',
    'REVOKED'
);


--
-- Name: invitationstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.invitationstatus AS ENUM (
    'ACCEPTED',
    'EXPIRED',
    'PENDING',
    'REVOKED'
);


--
-- Name: memberrole; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.memberrole AS ENUM (
    'CLIENT',
    'CREATOR',
    'MANAGER',
    'OWNER'
);


--
-- Name: oauth_provider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oauth_provider AS ENUM (
    'GOOGLE',
    'FACEBOOK'
);


--
-- Name: oauthprovider; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oauthprovider AS ENUM (
    'GOOGLE'
);


--
-- Name: package_negotiation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.package_negotiation_status AS ENUM (
    'DRAFT',
    'CLIENT_REQUESTED_CHANGE',
    'AGENCY_COUNTERED',
    'APPROVED'
);


--
-- Name: packagenegotiationstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.packagenegotiationstatus AS ENUM (
    'AGENCY_COUNTERED',
    'APPROVED',
    'CLIENT_REQUESTED_CHANGE',
    'DRAFT'
);


--
-- Name: packagetype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.packagetype AS ENUM (
    'BY_BUDGET',
    'BY_DURATION',
    'FULL_DELEGATION'
);


--
-- Name: subscription_plan_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_plan_name AS ENUM (
    'BASIC',
    'PRO',
    'ENTERPRISE'
);


--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscription_status AS ENUM (
    'ACTIVE',
    'EXPIRED',
    'CANCELLED',
    'TRIALING'
);


--
-- Name: subscriptionplanname; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscriptionplanname AS ENUM (
    'BASIC',
    'ENTERPRISE',
    'PRO'
);


--
-- Name: subscriptionstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.subscriptionstatus AS ENUM (
    'ACTIVE',
    'CANCELLED',
    'EXPIRED',
    'TRIALING'
);


--
-- Name: task_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.task_type AS ENUM (
    'POST'
);


--
-- Name: tasktype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tasktype AS ENUM (
    'EVENT_PLAN',
    'LIVESTREAM',
    'POST',
    'PRESS_RECOMMENDATION',
    'SURVEY'
);


--
-- Name: transaction_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transaction_status AS ENUM (
    'PENDING',
    'COMPLETED',
    'FAILED',
    'REFUNDED'
);


--
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transaction_type AS ENUM (
    'UPGRADE_PLAN',
    'BUY_CREDIT'
);


--
-- Name: transactionstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactionstatus AS ENUM (
    'COMPLETED',
    'FAILED',
    'PENDING',
    'REFUNDED'
);


--
-- Name: transactiontype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.transactiontype AS ENUM (
    'BUY_CREDIT',
    'UPGRADE_PLAN'
);


--
-- Name: user_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_status AS ENUM (
    'ACTIVE',
    'SUSPENDED',
    'DELETED',
    'DEACTIVATED',
    'FLAGGED',
    'PENDING_VERIFICATION'
);


--
-- Name: userstatus; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.userstatus AS ENUM (
    'ACTIVE',
    'DEACTIVATED',
    'DELETED',
    'FLAGGED',
    'PENDING_VERIFICATION',
    'SUSPENDED'
);


--
-- Name: workspace_industry; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspace_industry AS ENUM (
    'FNB',
    'FASHION',
    'BEAUTY',
    'TECHNOLOGY',
    'REAL_ESTATE',
    'EDUCATION',
    'HEALTHCARE',
    'SERVICES',
    'RETAIL',
    'OTHER'
);


--
-- Name: workspace_member_role; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspace_member_role AS ENUM (
    'MANAGER',
    'CREATOR',
    'CLIENT'
);


--
-- Name: workspaceindustry; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.workspaceindustry AS ENUM (
    'BEAUTY',
    'EDUCATION',
    'FASHION',
    'FNB',
    'HEALTHCARE',
    'OTHER',
    'REAL_ESTATE',
    'RETAIL',
    'SERVICES',
    'TECHNOLOGY'
);


--
-- Name: CAST (public.agencycategory AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.agencycategory AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.agencymemberrole AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.agencymemberrole AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.auditaction AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.auditaction AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.campaignstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.campaignstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.collaboratortype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.collaboratortype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.companysize AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.companysize AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.cooperationstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.cooperationstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.entitystatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.entitystatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.invitationstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.invitationstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.memberrole AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.memberrole AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.oauthprovider AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.oauthprovider AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.packagenegotiationstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.packagenegotiationstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.packagetype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.packagetype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.subscriptionplanname AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.subscriptionplanname AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.subscriptionstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.subscriptionstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.tasktype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.tasktype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.transactionstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.transactionstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.transactiontype AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.transactiontype AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.userstatus AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.userstatus AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.agencycategory); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.agencycategory) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.agencymemberrole); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.agencymemberrole) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.auditaction); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.auditaction) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.campaignstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.campaignstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.collaboratortype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.collaboratortype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.companysize); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.companysize) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.cooperationstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.cooperationstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.entitystatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.entitystatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.invitationstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.invitationstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.memberrole); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.memberrole) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.oauthprovider); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.oauthprovider) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.packagenegotiationstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.packagenegotiationstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.packagetype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.packagetype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.subscriptionplanname); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.subscriptionplanname) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.subscriptionstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.subscriptionstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.tasktype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.tasktype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.transactionstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.transactionstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.transactiontype); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.transactiontype) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.userstatus); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.userstatus) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (character varying AS public.workspaceindustry); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (character varying AS public.workspaceindustry) WITH INOUT AS IMPLICIT;


--
-- Name: CAST (public.workspaceindustry AS character varying); Type: CAST; Schema: -; Owner: -
--

CREATE CAST (public.workspaceindustry AS character varying) WITH INOUT AS IMPLICIT;


--
-- Name: guard_campaign_partner_usage(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.guard_campaign_partner_usage() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE partner_active BOOLEAN;
BEGIN
    IF TG_OP = 'UPDATE' AND NEW.collaborator_id = OLD.collaborator_id THEN
        RETURN NEW;
    END IF;
    SELECT is_active INTO partner_active FROM third_party_collaborators
    WHERE id = NEW.collaborator_id FOR UPDATE;
    IF partner_active IS FALSE THEN
        RAISE EXCEPTION 'Inactive collaborator cannot be assigned' USING ERRCODE = '23514';
    END IF;
    UPDATE third_party_collaborators
    SET first_used_at = CURRENT_TIMESTAMP, version = version + 1
    WHERE id = NEW.collaborator_id AND first_used_at IS NULL;
    RETURN NEW;
END;
$$;


--
-- Name: guard_package_negotiation_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.guard_package_negotiation_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Preserve existing parent hard-delete cascades without opening direct event deletion.
    IF TG_OP = 'DELETE' AND pg_trigger_depth() > 1 THEN RETURN OLD; END IF;
    RAISE EXCEPTION 'Package negotiation history is append-only' USING ERRCODE = '23514';
END;
$$;


--
-- Name: mark_collaborator_usage_on_link(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mark_collaborator_usage_on_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE active BOOLEAN;
BEGIN
    SELECT is_active INTO active
      FROM third_party_collaborators
     WHERE id = NEW.collaborator_id
     FOR UPDATE;
    IF active IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = '23503', MESSAGE = 'collaborator does not exist';
    END IF;
    IF NOT active THEN
        RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'collaborator is inactive';
    END IF;
    UPDATE third_party_collaborators
       SET first_used_at = COALESCE(first_used_at, NOW()),
           version = version + 1
     WHERE id = NEW.collaborator_id;
    RETURN NEW;
END;
$$;


--
-- Name: prevent_audit_log_mutation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_audit_log_mutation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'audit_logs is append-only and cannot be updated or deleted';
END;
$$;


--
-- Name: protect_package_negotiation_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.protect_package_negotiation_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE parent_exists BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Permit FK cascade only after the parent selection has been deleted.
        EXECUTE format('SELECT EXISTS (SELECT 1 FROM %I.workspace_media_packages WHERE id = $1)',
                       TG_TABLE_SCHEMA)
            INTO parent_exists USING OLD.workspace_media_package_id;
        IF NOT parent_exists THEN
            RETURN OLD;
        END IF;
    END IF;
    RAISE EXCEPTION 'package_negotiation_events is append-only';
END;
$_$;


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_activation_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_activation_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_hash character(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    revoked_at timestamp with time zone,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT account_activation_tokens_check CHECK ((expires_at > created_at))
);


--
-- Name: admin_account_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_account_operations (
    user_id uuid NOT NULL,
    operation_id uuid NOT NULL,
    payload_hash character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: admin_email_outbox; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_email_outbox (
    id uuid NOT NULL,
    event_key character varying(150) NOT NULL,
    recipient character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sent_at timestamp with time zone,
    next_attempt_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    notification_id uuid,
    failed_at timestamp with time zone,
    last_error character varying(255)
);


--
-- Name: admin_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_notifications (
    id uuid NOT NULL,
    title character varying(200) NOT NULL,
    content character varying(5000) NOT NULL,
    type character varying(20) NOT NULL,
    target_type character varying(10) NOT NULL,
    target_values text[] DEFAULT '{}'::text[] NOT NULL,
    action_url character varying(500),
    status character varying(12) NOT NULL,
    scheduled_at timestamp with time zone,
    sent_at timestamp with time zone,
    recipient_count integer,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT admin_notifications_check CHECK ((((status)::text <> 'SCHEDULED'::text) OR (scheduled_at IS NOT NULL))),
    CONSTRAINT admin_notifications_check1 CHECK ((((target_type)::text = 'ALL'::text) OR (cardinality(target_values) > 0))),
    CONSTRAINT admin_notifications_content_check CHECK (((char_length(btrim((content)::text)) >= 10) AND (char_length(btrim((content)::text)) <= 5000))),
    CONSTRAINT admin_notifications_status_check CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'SCHEDULED'::character varying, 'SENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT admin_notifications_target_type_check CHECK (((target_type)::text = ANY ((ARRAY['ALL'::character varying, 'BY_PLAN'::character varying, 'BY_ROLE'::character varying])::text[]))),
    CONSTRAINT admin_notifications_title_check CHECK (((char_length(btrim((title)::text)) >= 5) AND (char_length(btrim((title)::text)) <= 200))),
    CONSTRAINT admin_notifications_type_check CHECK (((type)::text = ANY ((ARRAY['SYSTEM'::character varying, 'MAINTENANCE'::character varying, 'UPDATE'::character varying, 'PROMOTION'::character varying])::text[])))
);


--
-- Name: admin_report_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_report_exports (
    id uuid NOT NULL,
    report_type character varying(20) NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    timezone character varying(40) NOT NULL,
    as_of timestamp with time zone NOT NULL,
    row_count integer NOT NULL,
    file_name character varying(120) NOT NULL,
    file_size integer NOT NULL,
    content bytea,
    token_hash character(64) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT admin_report_exports_check CHECK ((period_end >= period_start)),
    CONSTRAINT admin_report_exports_check1 CHECK ((expires_at > created_at)),
    CONSTRAINT admin_report_exports_report_type_check CHECK (((report_type)::text = ANY ((ARRAY['REVENUE'::character varying, 'USER'::character varying, 'PLATFORM'::character varying])::text[])))
);


--
-- Name: agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agencies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    owner_id uuid NOT NULL,
    logo_url character varying(255),
    banner_url character varying(255),
    description text,
    category public.agency_category,
    company_size public.company_size,
    website character varying(255),
    phone character varying(30),
    location character varying(255),
    brand_color character varying(9),
    logo_icon character varying(50),
    tagline character varying(140),
    founded_year integer,
    facebook_url character varying(255),
    linkedin_url character varying(255),
    instagram_url character varying(255),
    status public.entity_status DEFAULT 'ACTIVE'::public.entity_status NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agency_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    invited_email character varying(255) NOT NULL,
    invited_by uuid NOT NULL,
    token character varying(255) NOT NULL,
    note character varying(500),
    workspace_id uuid,
    role public.workspace_member_role,
    status public.invitation_status DEFAULT 'PENDING'::public.invitation_status NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agency_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agency_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role public.agency_member_role DEFAULT 'MEMBER'::public.agency_member_role NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_credit_creator_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_creator_limits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    monthly_limit integer NOT NULL,
    set_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ai_credit_ledgers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_credit_ledgers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    month character varying(7) NOT NULL,
    used_amount integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    agency_id uuid,
    user_id uuid NOT NULL,
    action public.audit_action NOT NULL,
    resource_type character varying(50) NOT NULL,
    resource_id character varying(255),
    ip_address character varying(45),
    user_agent character varying(512),
    old_value jsonb,
    new_value jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: campaign_collaborators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_collaborators (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    media_campaign_id uuid NOT NULL,
    collaborator_id uuid NOT NULL,
    cooperation_status public.cooperation_status DEFAULT 'CONTACTED'::public.cooperation_status NOT NULL,
    updated_by uuid,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: campaign_deployments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_deployments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    content_version integer NOT NULL,
    requested_by uuid NOT NULL,
    status character varying(16) DEFAULT 'PENDING'::character varying NOT NULL,
    attempt_count integer DEFAULT 0 NOT NULL,
    last_error_code character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT campaign_deployments_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'FAILED'::character varying, 'SUCCEEDED'::character varying])::text[])))
);


--
-- Name: campaign_review_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_review_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    content_version integer NOT NULL,
    actor_id uuid NOT NULL,
    actor_side character varying(16) NOT NULL,
    event_type character varying(16) NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT campaign_review_events_actor_side_check CHECK (((actor_side)::text = ANY ((ARRAY['AGENCY'::character varying, 'CLIENT'::character varying])::text[]))),
    CONSTRAINT campaign_review_events_event_type_check CHECK (((event_type)::text = ANY ((ARRAY['FEEDBACK'::character varying, 'APPROVE'::character varying])::text[])))
);


--
-- Name: campaign_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_versions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    content_version integer NOT NULL,
    snapshot jsonb NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: client_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_profiles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    display_name character varying(255) NOT NULL,
    company character varying(255),
    industry character varying(100),
    logo_url character varying(500),
    banner_url character varying(500),
    phone character varying(50),
    website character varying(255),
    location character varying(255),
    description text,
    social_links jsonb,
    note text,
    contact_name character varying(255),
    contact_email character varying(255),
    company_size character varying(50),
    instagram_url character varying(500),
    tax_code character varying(50),
    address character varying(500),
    tagline character varying(255),
    founded_year integer,
    budget_range character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: content_moderation_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_moderation_reviews (
    id uuid NOT NULL,
    post_id character varying(64) NOT NULL,
    content_version bigint NOT NULL,
    content_hash character(64) NOT NULL,
    workspace_id uuid,
    author_id uuid NOT NULL,
    source character varying(20) NOT NULL,
    reason character varying(2000) NOT NULL,
    status character varying(10) DEFAULT 'PENDING'::character varying NOT NULL,
    decision_note character varying(2000),
    strike_level character varying(10),
    strike_category character varying(100),
    reviewed_by uuid,
    reviewed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    row_version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT content_moderation_reviews_check CHECK ((((status)::text = 'PENDING'::text) = ((reviewed_at IS NULL) AND (reviewed_by IS NULL)))),
    CONSTRAINT content_moderation_reviews_check1 CHECK ((((status)::text <> 'APPROVED'::text) OR (char_length(btrim((decision_note)::text)) >= 10))),
    CONSTRAINT content_moderation_reviews_check2 CHECK ((((status)::text <> 'BLOCKED'::text) OR ((strike_level IS NOT NULL) AND (decision_note IS NOT NULL)))),
    CONSTRAINT content_moderation_reviews_content_version_check CHECK ((content_version > 0)),
    CONSTRAINT content_moderation_reviews_source_check CHECK (((source)::text = ANY ((ARRAY['FLAGGED_AUTHOR'::character varying, 'COMPLIANCE'::character varying, 'COPYRIGHT'::character varying])::text[]))),
    CONSTRAINT content_moderation_reviews_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'BLOCKED'::character varying])::text[]))),
    CONSTRAINT content_moderation_reviews_strike_level_check CHECK (((strike_level)::text = ANY ((ARRAY['YELLOW'::character varying, 'ORANGE'::character varying, 'RED'::character varying])::text[])))
);


--
-- Name: TABLE content_moderation_reviews; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.content_moderation_reviews IS 'FR 3.10.4. BLOCK records the strike through the admin account journal with operation id = review id, so retries never add a second strike.';


--
-- Name: content_request_completion_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_request_completion_jobs (
    campaign_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: mail_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_attachments (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    uploaded_by uuid NOT NULL,
    name character varying(255) NOT NULL,
    content_type character varying(100) NOT NULL,
    size bigint NOT NULL,
    s3_key character varying(500) NOT NULL,
    kind character varying(16) DEFAULT 'FILE'::character varying NOT NULL,
    bound boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mail_attachments_kind_check CHECK (((kind)::text = ANY ((ARRAY['FILE'::character varying, 'IMAGE'::character varying])::text[])))
);


--
-- Name: mail_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_batches (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    workspace_name character varying(255),
    template_id character varying(64) NOT NULL,
    template_name character varying(120) NOT NULL,
    sent_by uuid NOT NULL,
    sender_email character varying(255) NOT NULL,
    sender_name character varying(255),
    kind character varying(16) DEFAULT 'SEND'::character varying NOT NULL,
    status character varying(16) NOT NULL,
    subject character varying(200) NOT NULL,
    body_html text NOT NULL,
    attachments jsonb,
    scheduled_at timestamp with time zone,
    timezone character varying(64) DEFAULT 'Asia/Ho_Chi_Minh'::character varying NOT NULL,
    total integer NOT NULL,
    accepted integer NOT NULL,
    rejected_count integer DEFAULT 0 NOT NULL,
    sent_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    suppressed_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT mail_batches_kind_check CHECK (((kind)::text = ANY ((ARRAY['SEND'::character varying, 'TEST'::character varying])::text[]))),
    CONSTRAINT mail_batches_status_check CHECK (((status)::text = ANY ((ARRAY['SCHEDULED'::character varying, 'QUEUED'::character varying, 'SENDING'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying, 'FAILED'::character varying])::text[])))
);


--
-- Name: mail_deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_deliveries (
    id uuid NOT NULL,
    batch_id uuid NOT NULL,
    recipient character varying(255) NOT NULL,
    recipient_name character varying(255),
    variables jsonb,
    rendered_subject character varying(255) NOT NULL,
    rendered_body_html text NOT NULL,
    external_audience boolean DEFAULT false NOT NULL,
    status character varying(16) DEFAULT 'PENDING'::character varying NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    last_error character varying(500),
    next_attempt_at timestamp with time zone DEFAULT now() NOT NULL,
    sent_at timestamp with time zone,
    event_key character varying(300) NOT NULL,
    CONSTRAINT mail_deliveries_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'SUPPRESSED'::character varying])::text[])))
);


--
-- Name: mail_send_quota; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_send_quota (
    day date NOT NULL,
    scope character varying(16) NOT NULL,
    scope_id character varying(64) NOT NULL,
    sent_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT mail_send_quota_scope_check CHECK (((scope)::text = ANY ((ARRAY['SYSTEM'::character varying, 'WORKSPACE'::character varying])::text[])))
);


--
-- Name: mail_suppressions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_suppressions (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    email_lower character varying(255) NOT NULL,
    reason character varying(32) DEFAULT 'UNSUBSCRIBED'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: media_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_campaigns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_media_package_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    strategy_detail text,
    package_terms_snapshot jsonb,
    package_terms_version integer,
    allocation_period character varying(7),
    allocations jsonb DEFAULT '[]'::jsonb NOT NULL,
    deliverable_plan jsonb DEFAULT '[]'::jsonb NOT NULL,
    work_items jsonb DEFAULT '[]'::jsonb NOT NULL,
    content_version integer DEFAULT 1 NOT NULL,
    row_version bigint DEFAULT 0 NOT NULL,
    brand_guideline text,
    timeline jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.campaign_status DEFAULT 'DRAFT'::public.campaign_status NOT NULL,
    approved_by_agency_at timestamp with time zone,
    approved_by_agency_id uuid,
    approved_by_agency_version integer,
    approved_by_client_at timestamp with time zone,
    approved_by_client_id uuid,
    approved_by_client_version integer,
    completed_at timestamp with time zone,
    completed_by uuid,
    completion_reason character varying(2000),
    completion_task_summary jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: media_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    is_template boolean DEFAULT false NOT NULL,
    agency_id uuid,
    source_template_id uuid,
    is_available_to_workspaces boolean DEFAULT true NOT NULL,
    duration_weeks integer,
    budget_amount numeric(14,2),
    scope_description text,
    offering_details jsonb,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_media_packages_template_agency_scope CHECK (((is_template AND (agency_id IS NULL)) OR ((NOT is_template) AND (agency_id IS NOT NULL)))),
    CONSTRAINT chk_media_packages_template_source CHECK (((source_template_id IS NULL) OR (NOT is_template)))
);


--
-- Name: monitoring_collectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_collectors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    server_id uuid,
    token_hash character varying(255) NOT NULL,
    last_seen_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT monitoring_collectors_name_check CHECK ((btrim((name)::text) <> ''::text)),
    CONSTRAINT monitoring_collectors_token_hash_check CHECK ((btrim((token_hash)::text) <> ''::text))
);


--
-- Name: TABLE monitoring_collectors; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_collectors IS 'Operator-provisioned sources; heartbeat independent of probes. API collectorId maps to id.';


--
-- Name: monitoring_enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_enrollments (
    token_hash character(64) NOT NULL,
    name character varying(255) NOT NULL,
    environment character varying(50) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT monitoring_enrollments_environment_check CHECK ((btrim((environment)::text) <> ''::text)),
    CONSTRAINT monitoring_enrollments_name_check CHECK ((btrim((name)::text) <> ''::text))
);


--
-- Name: TABLE monitoring_enrollments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_enrollments IS 'Single-use admin-issued host enrollment; only token digests are stored. Claimed atomically.';


--
-- Name: monitoring_health_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_health_results (
    target_id uuid NOT NULL,
    collector_id uuid NOT NULL,
    check_id uuid NOT NULL,
    outcome character varying(255) NOT NULL,
    checked_at timestamp with time zone NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    latency_ms numeric(38,2),
    reason_code character varying(255),
    http_status smallint,
    runtime_state character varying(255),
    runtime_health character varying(255),
    CONSTRAINT chk_monitoring_result_clock CHECK ((checked_at <= (received_at + '00:00:10'::interval))),
    CONSTRAINT chk_monitoring_result_reason CHECK (((((outcome)::text = 'PASS'::text) AND (reason_code IS NULL)) OR (((outcome)::text = ANY (ARRAY[('FAIL'::character varying)::text, ('ERROR'::character varying)::text])) AND (reason_code IS NOT NULL) AND (btrim((reason_code)::text) <> ''::text)))),
    CONSTRAINT monitoring_health_results_http_status_check CHECK (((http_status >= 100) AND (http_status <= 599))),
    CONSTRAINT monitoring_health_results_latency_ms_check CHECK (((latency_ms >= (0)::numeric) AND (latency_ms < 'Infinity'::numeric))),
    CONSTRAINT monitoring_health_results_outcome_check CHECK (((outcome)::text = ANY (ARRAY[('PASS'::character varying)::text, ('FAIL'::character varying)::text, ('ERROR'::character varying)::text])))
);


--
-- Name: TABLE monitoring_health_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_health_results IS 'Exactly zero or one latest result per target. No history or persisted freshness status.';


--
-- Name: COLUMN monitoring_health_results.collector_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_results.collector_id IS 'Result provenance; FK prevents retaining old result under a new assignment. Clear result before reassignment in same transaction.';


--
-- Name: COLUMN monitoring_health_results.check_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_results.check_id IS 'Idempotency key scoped to target. Same current checkId is a no-op; do not update received_at.';


--
-- Name: COLUMN monitoring_health_results.received_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_results.received_at IS 'Backend-assigned; never trust client timestamp. Application enforces ordering and past-age window atomically.';


--
-- Name: monitoring_health_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_health_targets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    kind character varying(255) NOT NULL,
    environment character varying(255) NOT NULL,
    server_id uuid,
    service_name character varying(255),
    instance_id character varying(255),
    collector_id uuid NOT NULL,
    check_scope character varying(255) NOT NULL,
    probe_type character varying(255) NOT NULL,
    probe_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    assertion jsonb DEFAULT '{}'::jsonb NOT NULL,
    credential_ref character varying(255),
    interval_seconds integer DEFAULT 30 NOT NULL,
    timeout_seconds integer DEFAULT 5 NOT NULL,
    stale_after_seconds integer DEFAULT 90 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_monitoring_target_probe CHECK (((((kind)::text = ANY (ARRAY[('SERVICE'::character varying)::text, ('ENDPOINT'::character varying)::text])) AND ((probe_type)::text = 'HTTP'::text)) OR (((kind)::text = 'CONTAINER'::text) AND ((probe_type)::text = 'DOCKER'::text) AND (server_id IS NOT NULL)) OR (((kind)::text = 'DATABASE'::text) AND ((probe_type)::text = ANY (ARRAY[('HTTP'::character varying)::text, ('POSTGRESQL'::character varying)::text, ('REDIS'::character varying)::text, ('MONGODB'::character varying)::text, ('NEO4J'::character varying)::text]))))),
    CONSTRAINT chk_monitoring_target_timing CHECK (((timeout_seconds < interval_seconds) AND (interval_seconds < stale_after_seconds))),
    CONSTRAINT monitoring_health_targets_assertion_check CHECK ((jsonb_typeof(assertion) = 'object'::text)),
    CONSTRAINT monitoring_health_targets_check_scope_check CHECK ((btrim((check_scope)::text) <> ''::text)),
    CONSTRAINT monitoring_health_targets_credential_ref_check CHECK (((credential_ref IS NULL) OR (btrim((credential_ref)::text) <> ''::text))),
    CONSTRAINT monitoring_health_targets_environment_check CHECK ((btrim((environment)::text) <> ''::text)),
    CONSTRAINT monitoring_health_targets_interval_seconds_check CHECK ((interval_seconds > 0)),
    CONSTRAINT monitoring_health_targets_kind_check CHECK (((kind)::text = ANY (ARRAY[('SERVICE'::character varying)::text, ('CONTAINER'::character varying)::text, ('DATABASE'::character varying)::text, ('ENDPOINT'::character varying)::text]))),
    CONSTRAINT monitoring_health_targets_name_check CHECK ((btrim((name)::text) <> ''::text)),
    CONSTRAINT monitoring_health_targets_probe_config_check CHECK ((jsonb_typeof(probe_config) = 'object'::text)),
    CONSTRAINT monitoring_health_targets_probe_type_check CHECK (((probe_type)::text = ANY (ARRAY[('HTTP'::character varying)::text, ('DOCKER'::character varying)::text, ('POSTGRESQL'::character varying)::text, ('REDIS'::character varying)::text, ('MONGODB'::character varying)::text, ('NEO4J'::character varying)::text]))),
    CONSTRAINT monitoring_health_targets_stale_after_seconds_check CHECK ((stale_after_seconds > 0)),
    CONSTRAINT monitoring_health_targets_timeout_seconds_check CHECK ((timeout_seconds > 0))
);


--
-- Name: TABLE monitoring_health_targets; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_health_targets IS 'Persistent allowlist, including targets with no result. Never auto-create from submitted samples.';


--
-- Name: COLUMN monitoring_health_targets.server_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.server_id IS 'NULL for managed/external targets; must not fabricate host metrics.';


--
-- Name: COLUMN monitoring_health_targets.check_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.check_scope IS 'READINESS/LIVENESS for services; documented scope for other probes. Validate contract in application.';


--
-- Name: COLUMN monitoring_health_targets.probe_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.probe_config IS 'Operator-only address/selector configuration. No plaintext secrets or raw response; omit from public DTOs.';


--
-- Name: COLUMN monitoring_health_targets.credential_ref; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.credential_ref IS 'Reference resolved by worker secret provider; never a password, bearer token, or secret-bearing URI.';


--
-- Name: COLUMN monitoring_health_targets.stale_after_seconds; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_health_targets.stale_after_seconds IS 'Also used by ingestion as maximum past sample age; compare against backend time.';


--
-- Name: monitoring_servers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.monitoring_servers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    ip_address inet NOT NULL,
    environment character varying(255) NOT NULL,
    deployed_services text[] DEFAULT '{}'::text[] NOT NULL,
    agent_token_hash character varying(255) NOT NULL,
    cpu_percent numeric(38,2),
    ram_percent numeric(38,2),
    disk_percent numeric(38,2),
    uptime_seconds bigint,
    last_seen_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_monitoring_server_ip CHECK ((masklen(ip_address) =
CASE family(ip_address)
    WHEN 4 THEN 32
    ELSE 128
END)),
    CONSTRAINT chk_monitoring_server_no_sample CHECK (((last_seen_at IS NOT NULL) OR ((cpu_percent IS NULL) AND (ram_percent IS NULL) AND (disk_percent IS NULL) AND (uptime_seconds IS NULL)))),
    CONSTRAINT monitoring_servers_agent_token_hash_check CHECK ((btrim((agent_token_hash)::text) <> ''::text)),
    CONSTRAINT monitoring_servers_cpu_percent_check CHECK (((cpu_percent >= (0)::numeric) AND (cpu_percent <= (100)::numeric))),
    CONSTRAINT monitoring_servers_disk_percent_check CHECK (((disk_percent >= (0)::numeric) AND (disk_percent <= (100)::numeric))),
    CONSTRAINT monitoring_servers_environment_check CHECK ((btrim((environment)::text) <> ''::text)),
    CONSTRAINT monitoring_servers_name_check CHECK ((btrim((name)::text) <> ''::text)),
    CONSTRAINT monitoring_servers_ram_percent_check CHECK (((ram_percent >= (0)::numeric) AND (ram_percent <= (100)::numeric))),
    CONSTRAINT monitoring_servers_uptime_seconds_check CHECK ((uptime_seconds >= 0))
);


--
-- Name: TABLE monitoring_servers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.monitoring_servers IS 'Operator-managed physical hosts; one latest sample per host, no history. API serverId maps to id.';


--
-- Name: COLUMN monitoring_servers.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.id IS 'Stable across container redeploys; replacement host gets a new UUID. IP is not identity.';


--
-- Name: COLUMN monitoring_servers.agent_token_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.agent_token_hash IS 'Hash only; never expose via API/logs. Provision a separate random agent credential.';


--
-- Name: COLUMN monitoring_servers.last_seen_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.last_seen_at IS 'Backend receipt time of valid heartbeat; update atomically with all metrics. NULL means NO_DATA.';


--
-- Name: COLUMN monitoring_servers.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.monitoring_servers.updated_at IS 'Application-maintained metadata update time; heartbeat must not overwrite operator metadata.';


--
-- Name: package_negotiation_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package_negotiation_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_media_package_id uuid NOT NULL,
    terms_version integer NOT NULL,
    action character varying(30) NOT NULL,
    actor_id uuid,
    actor_role character varying(20),
    note character varying(2000),
    terms_snapshot jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT package_negotiation_events_action_check CHECK (((action)::text = ANY ((ARRAY['BASELINE'::character varying, 'REQUEST_CHANGE'::character varying, 'COUNTER_OFFER'::character varying])::text[]))),
    CONSTRAINT package_negotiation_events_check CHECK (((((action)::text = 'BASELINE'::text) AND (actor_id IS NULL) AND (actor_role IS NULL)) OR (((action)::text = 'REQUEST_CHANGE'::text) AND (actor_id IS NOT NULL) AND ((actor_role)::text = 'CLIENT'::text)) OR (((action)::text = 'COUNTER_OFFER'::text) AND (actor_id IS NOT NULL) AND ((actor_role)::text = ANY ((ARRAY['OWNER'::character varying, 'MANAGER'::character varying])::text[]))))),
    CONSTRAINT package_negotiation_events_terms_snapshot_check CHECK ((jsonb_typeof(terms_snapshot) = 'object'::text)),
    CONSTRAINT package_negotiation_events_terms_version_check CHECK ((terms_version > 0))
);


--
-- Name: sanction_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sanction_reviews (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    resolved_at timestamp with time zone,
    resolved_by uuid,
    reason character varying(2000),
    CONSTRAINT sanction_reviews_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'CLOSED'::character varying])::text[])))
);


--
-- Name: seed_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seed_runs (
    dataset character varying(100) NOT NULL,
    dataset_version integer NOT NULL,
    run_id uuid NOT NULL,
    status character varying(16) NOT NULL,
    last_stage character varying(64),
    record_counts jsonb DEFAULT '{}'::jsonb NOT NULL,
    manifest jsonb DEFAULT '{}'::jsonb NOT NULL,
    failure_summary character varying(255),
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    failed_at timestamp with time zone,
    CONSTRAINT seed_runs_check CHECK ((((status)::text = 'complete'::text) = (completed_at IS NOT NULL))),
    CONSTRAINT seed_runs_check1 CHECK ((((status)::text = 'failed'::text) = (failed_at IS NOT NULL))),
    CONSTRAINT seed_runs_dataset_version_check CHECK ((dataset_version > 0)),
    CONSTRAINT seed_runs_status_check CHECK (((status)::text = ANY ((ARRAY['running'::character varying, 'complete'::character varying, 'failed'::character varying])::text[])))
);


--
-- Name: subscription_plan_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plan_changes (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status character varying(10) DEFAULT 'PENDING'::character varying NOT NULL,
    effective_at timestamp with time zone,
    payment_required boolean DEFAULT true NOT NULL,
    requested_by uuid NOT NULL,
    reason character varying(2000) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT subscription_plan_changes_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPLIED'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: subscription_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscription_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name public.subscription_plan_name NOT NULL,
    display_name character varying(100) NOT NULL,
    price_monthly numeric(12,2) NOT NULL,
    max_workspaces integer NOT NULL,
    ai_credits_month integer NOT NULL,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: task_content_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_content_operations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    sequence_number bigint NOT NULL,
    yjs_update text NOT NULL,
    edited_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: task_content_snapshots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_content_snapshots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_id uuid NOT NULL,
    sequence_number bigint NOT NULL,
    yjs_state text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    type public.task_type DEFAULT 'POST'::public.task_type NOT NULL,
    title character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: third_party_collaborators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.third_party_collaborators (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    partner_name character varying(255) NOT NULL,
    partner_type public.collaborator_type NOT NULL,
    contact_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    first_used_at timestamp with time zone,
    usage_history_verified boolean DEFAULT false NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type public.transaction_type NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'VND'::character varying NOT NULL,
    status public.transaction_status DEFAULT 'PENDING'::public.transaction_status NOT NULL,
    ref_id character varying(255),
    payos_tx_id character varying(255),
    paid_at timestamp with time zone,
    failed_reason character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_notifications (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    notification_id uuid,
    type character varying(20) NOT NULL,
    title character varying(200) NOT NULL,
    content character varying(5000) NOT NULL,
    action_url character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone
);


--
-- Name: user_oauth_providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    provider public.oauth_provider NOT NULL,
    provider_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_refresh_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token_hash character varying(255) NOT NULL,
    jti character varying(255) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    ip_address character varying(45),
    user_agent character varying(255),
    device_info jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_strikes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_strikes (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    level character varying(10) NOT NULL,
    category character varying(100) NOT NULL,
    reason character varying(2000) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    converted_to_id uuid,
    removed_by uuid,
    removed_at timestamp with time zone,
    removal_reason character varying(2000),
    CONSTRAINT user_strikes_check CHECK ((expires_at > created_at)),
    CONSTRAINT user_strikes_check1 CHECK (((removed_at IS NULL) = (removed_by IS NULL))),
    CONSTRAINT user_strikes_check2 CHECK (((converted_to_id IS NULL) OR ((level)::text = 'YELLOW'::text))),
    CONSTRAINT user_strikes_level_check CHECK (((level)::text = ANY ((ARRAY['YELLOW'::character varying, 'ORANGE'::character varying, 'RED'::character varying])::text[])))
);


--
-- Name: user_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status public.subscription_status DEFAULT 'TRIALING'::public.subscription_status NOT NULL,
    current_period_start timestamp with time zone NOT NULL,
    current_period_end timestamp with time zone NOT NULL,
    cancelled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_system_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_system_roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    system_role character varying(50) DEFAULT 'USER'::character varying NOT NULL,
    granted_by uuid,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_user_system_roles_role CHECK (((system_role)::text = ANY ((ARRAY['ADMIN'::character varying, 'USER'::character varying])::text[])))
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(20),
    password_hash character varying(255),
    full_name character varying(255) NOT NULL,
    avatar_url character varying(255),
    professional_title character varying(255),
    bio text,
    portfolio_urls jsonb DEFAULT '[]'::jsonb NOT NULL,
    working_language character varying(50),
    skills jsonb DEFAULT '[]'::jsonb NOT NULL,
    location character varying(255),
    years_of_experience integer,
    linkedin_url character varying(255),
    facebook_url character varying(255),
    instagram_url character varying(255),
    tiktok_url character varying(255),
    website character varying(255),
    banner_url character varying(255),
    status public.user_status DEFAULT 'ACTIVE'::public.user_status NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_banned_at timestamp with time zone,
    preferences jsonb DEFAULT '{}'::jsonb NOT NULL,
    last_login_at timestamp with time zone,
    last_password_change timestamp with time zone,
    otp_code character varying(6),
    otp_expiry timestamp with time zone,
    email_verified_at timestamp with time zone,
    two_factor_enabled boolean DEFAULT false NOT NULL,
    totp_secret character varying(64),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    clean_period_ends_at timestamp with time zone,
    reactivate_at timestamp with time zone,
    tokens_revoked_before timestamp with time zone,
    row_version bigint DEFAULT 0 NOT NULL,
    session_version bigint DEFAULT 0 NOT NULL,
    require_password_reset boolean DEFAULT false NOT NULL
);


--
-- Name: workspace_hashtags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_hashtags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    tag character varying(100) NOT NULL,
    normalized_tag character varying(100) NOT NULL,
    purpose character varying(30) NOT NULL,
    added_by uuid NOT NULL,
    added_by_name character varying(255) NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    campaign_id uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    version bigint DEFAULT 0 NOT NULL,
    CONSTRAINT workspace_hashtags_purpose_check CHECK (((purpose)::text = ANY ((ARRAY['BRAND'::character varying, 'CAMPAIGN'::character varying, 'TRENDING'::character varying, 'EVENT_SPECIFIC'::character varying])::text[])))
);


--
-- Name: workspace_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_invitations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    invited_email character varying(255) NOT NULL,
    invited_by uuid NOT NULL,
    token character varying(255) NOT NULL,
    role public.workspace_member_role,
    status public.invitation_status DEFAULT 'PENDING'::public.invitation_status NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_media_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_media_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    package_id uuid NOT NULL,
    negotiation_status public.package_negotiation_status DEFAULT 'DRAFT'::public.package_negotiation_status NOT NULL,
    final_terms jsonb DEFAULT '{}'::jsonb NOT NULL,
    previous_terms jsonb,
    terms_version integer DEFAULT 1 NOT NULL,
    client_proposal_count integer DEFAULT 0 NOT NULL,
    approved_by_agency_at timestamp with time zone,
    approved_by_client_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_workspace_media_packages_client_proposal_count CHECK ((client_proposal_count >= 0)),
    CONSTRAINT chk_workspace_media_packages_terms_version_positive CHECK ((terms_version > 0))
);


--
-- Name: workspace_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid NOT NULL,
    user_id uuid,
    client_profile_id uuid,
    role public.workspace_member_role NOT NULL,
    added_by uuid,
    joined_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_workspace_members_identity CHECK ((((role = 'CLIENT'::public.workspace_member_role) AND (client_profile_id IS NOT NULL)) OR ((role <> 'CLIENT'::public.workspace_member_role) AND (user_id IS NOT NULL) AND (client_profile_id IS NULL))))
);


--
-- Name: workspace_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid,
    name character varying(255) NOT NULL,
    source_workspace_id uuid,
    config_snapshot jsonb NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    agency_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    created_by uuid NOT NULL,
    workspace_media_package_id uuid,
    source_workspace_id uuid,
    duplication_request_id uuid,
    duplication_fingerprint uuid,
    timezone_config character varying(100) DEFAULT 'Asia/Ho_Chi_Minh'::character varying NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    industry public.workspace_industry,
    company_size public.company_size,
    website character varying(255),
    phone character varying(30),
    location character varying(255),
    description character varying(500),
    brand_color character varying(9),
    logo_icon character varying(50),
    logo_url character varying(255),
    banner_url character varying(255),
    tagline character varying(140),
    founded_year integer,
    facebook_url character varying(255),
    linkedin_url character varying(255),
    instagram_url character varying(255),
    status public.entity_status DEFAULT 'ACTIVE'::public.entity_status NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Data for Name: account_activation_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.account_activation_tokens (id, user_id, token_hash, expires_at, used_at, revoked_at, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: admin_account_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_account_operations (user_id, operation_id, payload_hash, created_at) FROM stdin;
\.


--
-- Data for Name: admin_email_outbox; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_email_outbox (id, event_key, recipient, subject, body, created_at, sent_at, next_attempt_at, attempts, notification_id, failed_at, last_error) FROM stdin;
\.


--
-- Data for Name: admin_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_notifications (id, title, content, type, target_type, target_values, action_url, status, scheduled_at, sent_at, recipient_count, created_by, created_at, updated_at, row_version) FROM stdin;
\.


--
-- Data for Name: admin_report_exports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_report_exports (id, report_type, period_start, period_end, timezone, as_of, row_count, file_name, file_size, content, token_hash, expires_at, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: agencies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agencies (id, name, owner_id, logo_url, banner_url, description, category, company_size, website, phone, location, brand_color, logo_icon, tagline, founded_year, facebook_url, linkedin_url, instagram_url, status, deleted_at, created_at, updated_at) FROM stdin;
5e52a493-ce6e-48c8-bae7-827e3972d10c	AIM Academy Agency	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	Secured explicit function	ENTERTAINMENT	SIZE_201_500	https://www.venice-rau.net:2128/?sit=ut&amet=quaerat	\N	East Lufort	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.7333+00	2026-10-15 13:02:14.733315+00
fdc4d009-16bb-498c-988a-bf5cccb6992e	Saatchi & Saatchi Vietnam Agency	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	Quality-focused methodical solution	FNB	SIZE_201_500	https://www.horacio-gutkowski.biz/vel/possimus?eius=facere&tempora=reprehenderit	\N	Caseytown	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.733862+00	2026-10-15 13:02:14.733864+00
f2101bc2-7286-472a-b7e6-a99c49faf9a8	Ogilvy Vietnam Agency	48a76a32-50b1-4860-899c-0f549cc49fda	\N	\N	Multi-channelled hybrid emulation	RETAIL	SIZE_11_50	https://www.lavinia-jones.name/assumenda/ducimus	\N	Stellafort	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.736874+00	2026-10-15 13:02:14.736874+00
fb06ce2b-6c58-43d8-8f6a-f650f314c2da	Demo Agency	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	seed:rocket:#2563eb	https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1400&auto=format&fit=crop&q=80	\N	FASHION	SIZE_1_10	\N	\N	Tỉnh Hà Giang	#2563eb	\N	No pain no gain	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:30:13.071722+00	2026-10-15 13:30:13.071722+00
\.


--
-- Data for Name: agency_invitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_invitations (id, agency_id, invited_email, invited_by, token, note, workspace_id, role, status, expires_at, accepted_at, created_at) FROM stdin;
\.


--
-- Data for Name: agency_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.agency_members (id, agency_id, user_id, role, joined_at) FROM stdin;
2d6e04cd-5543-4203-8f52-ff00541e338f	5e52a493-ce6e-48c8-bae7-827e3972d10c	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	OWNER	2026-10-15 13:02:14.766365+00
6dceac13-615a-4a1e-8b00-17278e981308	fb06ce2b-6c58-43d8-8f6a-f650f314c2da	678b53b7-8ce5-49a7-99d9-683888ecdd86	CLIENT	2026-10-18 16:32:21.981124+00
ffa5885c-6f5a-4223-9900-f18778ac4454	fdc4d009-16bb-498c-988a-bf5cccb6992e	678b53b7-8ce5-49a7-99d9-683888ecdd86	CLIENT	2026-10-18 16:32:21.981124+00
4dd34b59-eef0-49bb-a738-1b3f6936e414	5e52a493-ce6e-48c8-bae7-827e3972d10c	678b53b7-8ce5-49a7-99d9-683888ecdd86	CLIENT	2026-10-18 16:32:21.981124+00
4f370d28-1f7d-445d-91b7-57cc5c695d5d	5e52a493-ce6e-48c8-bae7-827e3972d10c	09100a6a-650a-4447-bfd2-9b69c6414a17	MEMBER	2026-10-15 13:02:14.766394+00
ea20b5af-7546-4d14-a535-0739580d0ac0	fdc4d009-16bb-498c-988a-bf5cccb6992e	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	OWNER	2026-10-15 13:02:14.766395+00
5deee543-97aa-4a71-85cb-6cbd0ab4c537	fdc4d009-16bb-498c-988a-bf5cccb6992e	308fec0e-308b-4b71-bf8f-7f6fb73998c4	MEMBER	2026-10-15 13:02:14.766397+00
e9f380ae-52b1-4b2e-b33e-280c67a21dcc	f2101bc2-7286-472a-b7e6-a99c49faf9a8	48a76a32-50b1-4860-899c-0f549cc49fda	OWNER	2026-10-15 13:02:14.766857+00
7e4d6982-e5dc-4b01-9759-e58926a2e3d5	fdc4d009-16bb-498c-988a-bf5cccb6992e	749743be-c9d0-40ac-89ba-eaa354a65779	MEMBER	2026-10-15 13:02:14.994708+00
107bacc2-40e5-4b2e-9c66-e59ab568e6c1	5e52a493-ce6e-48c8-bae7-827e3972d10c	1d1da7bf-24f8-412e-8ac7-7f0196e2c948	MEMBER	2026-10-15 13:02:14.99669+00
ca6b0cdd-d9b7-4373-afd8-8ea25906a43c	5e52a493-ce6e-48c8-bae7-827e3972d10c	f00da3f2-9c63-4c5a-8e5c-ff08f37812ec	MEMBER	2026-10-15 13:02:14.996694+00
7600e599-4fbb-4df0-a56d-e879cbc23c6f	f2101bc2-7286-472a-b7e6-a99c49faf9a8	5c31518f-e781-4c68-9ca9-30cc5bc0c373	MEMBER	2026-10-15 13:02:14.996828+00
703cd6f3-fca3-425d-8313-8882651b18cc	fb06ce2b-6c58-43d8-8f6a-f650f314c2da	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	OWNER	2026-10-15 13:30:13.074724+00
7c0b9b5d-7b13-4b32-a327-99d689c59a42	fb06ce2b-6c58-43d8-8f6a-f650f314c2da	5c31518f-e781-4c68-9ca9-30cc5bc0c373	MEMBER	2026-10-15 13:31:52.667436+00
\.


--
-- Data for Name: ai_credit_creator_limits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_creator_limits (id, agency_id, creator_id, monthly_limit, set_by, created_at, updated_at) FROM stdin;
e9bbe10f-9031-462d-a3b6-f8c8e0bebe8b	5e52a493-ce6e-48c8-bae7-827e3972d10c	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	167	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.888824+00	2026-10-15 13:02:14.888825+00
a0bdab9e-e56a-49f9-a337-db5341d0ab99	fdc4d009-16bb-498c-988a-bf5cccb6992e	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	256	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.88883+00	2026-10-15 13:02:14.88883+00
1ee2f695-d1c5-40dd-8864-854a3db9d2d9	f2101bc2-7286-472a-b7e6-a99c49faf9a8	48a76a32-50b1-4860-899c-0f549cc49fda	218	48a76a32-50b1-4860-899c-0f549cc49fda	2026-10-15 13:02:14.888908+00	2026-10-15 13:02:14.888908+00
\.


--
-- Data for Name: ai_credit_ledgers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ai_credit_ledgers (id, agency_id, month, used_amount, created_at, updated_at) FROM stdin;
9988a73b-fab5-4c9c-b47d-d2248d1f51dc	5e52a493-ce6e-48c8-bae7-827e3972d10c	2026-10	284	2026-10-15 13:02:14.888789+00	2026-10-15 13:02:14.88879+00
0137bb2f-ae77-47c2-b3de-ac0ab83f25e3	fdc4d009-16bb-498c-988a-bf5cccb6992e	2026-10	83	2026-10-15 13:02:14.888829+00	2026-10-15 13:02:14.888829+00
69c373ec-946b-4ebf-b493-86b995d96b77	f2101bc2-7286-472a-b7e6-a99c49faf9a8	2026-10	448	2026-10-15 13:02:14.888907+00	2026-10-15 13:02:14.888908+00
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, agency_id, user_id, action, resource_type, resource_id, ip_address, user_agent, old_value, new_value, created_at) FROM stdin;
1	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	LOGIN	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	\N	\N	\N	\N	2026-10-15 13:04:26.377163+00
2	\N	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	LOGIN	USER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	2026-10-15 13:04:27.297904+00
3	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:05:33.438915+00
4	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:20:35.059727+00
5	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:25:32.126987+00
6	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 13:25:32.1693+00
7	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:25:44.307096+00
8	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:26:24.820949+00
9	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 13:26:24.863243+00
10	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:26:26.86731+00
11	\N	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	LOGIN	USER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	2026-10-15 13:28:22.351797+00
12	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:50:14.04727+00
13	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 13:50:16.478253+00
14	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 13:50:16.511785+00
15	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	LOGIN	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	\N	\N	\N	\N	2026-10-15 13:50:19.715027+00
16	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	VIEW	ADMIN_REVENUE	\N	\N	\N	\N	{"to": "2026-10-15", "from": "2026-10-01", "timezone": "Asia/Ho_Chi_Minh"}	2026-10-15 13:50:25.274356+00
17	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	TOKEN_REFRESH	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	\N	\N	\N	\N	2026-10-15 14:16:04.735539+00
18	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	TOKEN_REFRESH	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	\N	\N	\N	\N	2026-10-15 14:16:08.639247+00
19	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	LOGOUT	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 14:16:08.681819+00
20	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 14:16:11.306241+00
21	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 14:31:12.12297+00
22	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 14:46:20.577351+00
23	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGIN	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:05:52.689395+00
24	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	TOKEN_REFRESH	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:06:11.468214+00
25	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGOUT	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 16:06:11.511413+00
26	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 16:06:13.542759+00
27	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 16:06:17.733094+00
28	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 16:06:17.770887+00
29	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGIN	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:06:22.382313+00
30	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	TOKEN_REFRESH	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:06:44.457948+00
31	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGOUT	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 16:06:44.499407+00
32	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 16:06:48.264143+00
33	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 16:07:56.211356+00
34	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 16:07:56.246173+00
35	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGIN	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:12:10.75817+00
36	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	TOKEN_REFRESH	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:29:02.809271+00
37	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGIN	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:35:55.011143+00
38	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	TOKEN_REFRESH	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:38:03.32711+00
39	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGOUT	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 16:38:03.367712+00
40	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 16:38:04.86344+00
41	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-15 16:38:23.218802+00
42	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-15 16:38:23.24881+00
43	\N	f676f1ca-0fa0-4aac-a920-45efea23b126	LOGIN	USER	f676f1ca-0fa0-4aac-a920-45efea23b126	\N	\N	\N	\N	2026-10-15 16:39:37.235195+00
44	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	TOKEN_REFRESH	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-15 16:45:46.883296+00
45	\N	f676f1ca-0fa0-4aac-a920-45efea23b126	TOKEN_REFRESH	USER	f676f1ca-0fa0-4aac-a920-45efea23b126	\N	\N	\N	\N	2026-10-15 16:56:37.870275+00
46	\N	f676f1ca-0fa0-4aac-a920-45efea23b126	TOKEN_REFRESH	USER	f676f1ca-0fa0-4aac-a920-45efea23b126	\N	\N	\N	\N	2026-10-15 17:11:57.804491+00
47	\N	f676f1ca-0fa0-4aac-a920-45efea23b126	TOKEN_REFRESH	USER	f676f1ca-0fa0-4aac-a920-45efea23b126	\N	\N	\N	\N	2026-10-15 17:29:06.088214+00
48	\N	f676f1ca-0fa0-4aac-a920-45efea23b126	TOKEN_REFRESH	USER	f676f1ca-0fa0-4aac-a920-45efea23b126	\N	\N	\N	\N	2026-10-16 02:47:56.735717+00
49	\N	f676f1ca-0fa0-4aac-a920-45efea23b126	TOKEN_REFRESH	USER	f676f1ca-0fa0-4aac-a920-45efea23b126	\N	\N	\N	\N	2026-10-16 03:03:05.876855+00
50	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGIN	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-18 13:51:33.456824+00
51	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	TOKEN_REFRESH	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	\N	\N	\N	\N	2026-10-18 13:51:41.151485+00
52	\N	678b53b7-8ce5-49a7-99d9-683888ecdd86	LOGOUT	USER	678b53b7-8ce5-49a7-99d9-683888ecdd86	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-18 13:51:41.197425+00
53	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-18 13:51:44.360838+00
54	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-18 14:06:46.118239+00
55	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-18 14:21:46.386092+00
56	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-18 14:42:23.897327+00
57	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-19 05:39:18.594856+00
58	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-19 05:42:11.941342+00
61	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	TOKEN_REFRESH	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	\N	\N	\N	\N	2026-10-19 05:42:16.268953+00
59	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGOUT	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-19 05:42:12.006579+00
60	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	LOGIN	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	\N	\N	\N	\N	2026-10-19 05:42:13.971531+00
62	\N	80baa35d-db56-467f-a2b1-7b00a8e1267d	LOGOUT	USER	80baa35d-db56-467f-a2b1-7b00a8e1267d	0:0:0:0:0:0:0:1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	\N	\N	2026-10-19 05:42:16.310924+00
63	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	LOGIN	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-19 05:42:17.775471+00
64	\N	5c31518f-e781-4c68-9ca9-30cc5bc0c373	TOKEN_REFRESH	USER	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	\N	\N	\N	2026-10-19 05:57:17.387895+00
\.


--
-- Data for Name: campaign_collaborators; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_collaborators (id, media_campaign_id, collaborator_id, cooperation_status, updated_by, updated_at) FROM stdin;
\.


--
-- Data for Name: campaign_deployments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_deployments (id, campaign_id, content_version, requested_by, status, attempt_count, last_error_code, created_at, updated_at, completed_at) FROM stdin;
\.


--
-- Data for Name: campaign_review_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_review_events (id, campaign_id, content_version, actor_id, actor_side, event_type, comment, created_at) FROM stdin;
\.


--
-- Data for Name: campaign_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campaign_versions (id, campaign_id, content_version, snapshot, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: client_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_profiles (id, user_id, display_name, company, industry, logo_url, banner_url, phone, website, location, description, social_links, note, contact_name, contact_email, company_size, instagram_url, tax_code, address, tagline, founded_year, budget_range, created_at, updated_at) FROM stdin;
50a84552-870f-4ba7-946f-9b695ef54242	09100a6a-650a-4447-bfd2-9b69c6414a17	Toyota Vietnam	Toyota Vietnam	BEAUTY	https://placehold.co/200x200	\N	8681072777	https://toyota-vietnam.example.com	Haneview	Advanced zero tolerance support. repurpose web-enabled communities.	{"facebook": "https://facebook.com/toyota-vietnam", "linkedin": "https://linkedin.com/company/toyota-vietnam"}	Quidem dicta suscipit architecto velit.	Waneta Gerhold	user1@gmail.com	SIZE_500_PLUS	https://instagram.com/toyota-vietnam	7972686842	69208 Magaret Union, North Markus	Profound full-range firmware	2004	RANGE_200M_500M	2026-10-15 13:02:14.841218+00	2026-10-15 13:02:14.841222+00
6611bdde-bf2e-4699-a478-2f59fb852326	5c31518f-e781-4c68-9ca9-30cc5bc0c373	IKEA	IKEA	OTHER	https://placehold.co/200x200	\N	1875044560	https://ikea.example.com	South Fermin	Seamless reciprocal access. streamline best-of-breed portals.	{"facebook": "https://facebook.com/ikea", "linkedin": "https://linkedin.com/company/ikea"}	Consequuntur iusto odit aliquam reiciendis fugiat.	Man Koss	user59@gmail.com	SIZE_201_500	https://instagram.com/ikea	5268390218	0996 Sawayn Track, Ezequielhaven	Open-source human-resource ability	2010	RANGE_50M_200M	2026-10-15 13:02:14.841462+00	2026-10-15 13:02:14.841463+00
ab6d588d-5e5b-411f-9d5a-df401793a150	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	Traveloka	Traveloka	SERVICES	https://placehold.co/200x200	\N	4076801723	https://traveloka.example.com	East Morgan	Monitored systemic hierarchy. redefine compelling communities.	{"facebook": "https://facebook.com/traveloka", "linkedin": "https://linkedin.com/company/traveloka"}	Explicabo illum nesciunt distinctio nihil.	Dr. Era Konopelski	user177@hotmail.com	SIZE_51_200	https://instagram.com/traveloka	7945389829	0708 Ritchie Tunnel, Tamerahaven	Future-proofed object-oriented approach	1991	RANGE_500M_1B	2026-10-15 13:02:14.841537+00	2026-10-15 13:02:14.841537+00
2dd7226a-6970-4507-ba0f-089f14aa188f	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	Samsung	Samsung	OTHER	https://placehold.co/200x200	\N	5379050779	https://samsung.example.com	Port Janay	Networked static paradigm. reinvent interactive action-items.	{"facebook": "https://facebook.com/samsung", "linkedin": "https://linkedin.com/company/samsung"}	Adipisci unde dolorum dolorem quo nisi voluptatem temporibus.	Dr. Era Konopelski	user177@hotmail.com	SIZE_201_500	https://instagram.com/samsung	8774941591	817 Hills Circle, South Pearlie	Monitored zero defect system engine	2002	UNDER_50M	2026-10-15 13:02:14.841842+00	2026-10-15 13:02:14.841843+00
0abbfba8-a254-41ea-ab92-83c2f89c7247	d315f0c5-ff9f-4027-80f6-2f5cecea1933	Nestlé	Nestlé	OTHER	https://placehold.co/200x200	\N	0360872837	https://nestl.example.com	Marvintown	Horizontal zero administration alliance. orchestrate impactful web services.	{"facebook": "https://facebook.com/nestl", "linkedin": "https://linkedin.com/company/nestl"}	Accusantium distinctio dolorem molestiae minima.	Lourdes Kilback PhD	user20@hotmail.com	SIZE_500_PLUS	https://instagram.com/nestl	9727707432	3111 Gusikowski Branch, Grahamville	Expanded transitional process improvement	1991	OVER_5B	2026-10-15 13:02:14.842299+00	2026-10-15 13:02:14.8423+00
96ccd1a9-aad6-4118-a18b-29351fbd2e80	f00da3f2-9c63-4c5a-8e5c-ff08f37812ec	Tiki	Tiki	BEAUTY	https://placehold.co/200x200	\N	9253474870	https://tiki.example.com	New Cristina	Grass-roots holistic challenge. incubate interactive supply-chains.	{"facebook": "https://facebook.com/tiki", "linkedin": "https://linkedin.com/company/tiki"}	Laborum maxime reprehenderit suscipit similique.	Kali Reichel MD	user14@yahoo.com	SIZE_51_200	https://instagram.com/tiki	8053340966	7259 Zachery Shoal, Schillerbury	Open-source maximized architecture	2023	OVER_5B	2026-10-15 13:02:14.844262+00	2026-10-15 13:02:14.844263+00
eaa9cdf1-2550-4d91-bd92-d132aaefed14	678b53b7-8ce5-49a7-99d9-683888ecdd86	Nguyễn Tuấn	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	Nguyễn Tuấn	winhtuan@gmail.com	\N	\N	\N	\N	\N	\N	\N	2026-10-15 16:11:55.356745+00	2026-10-15 16:11:55.356745+00
\.


--
-- Data for Name: content_moderation_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_moderation_reviews (id, post_id, content_version, content_hash, workspace_id, author_id, source, reason, status, decision_note, strike_level, strike_category, reviewed_by, reviewed_at, created_at, row_version) FROM stdin;
\.


--
-- Data for Name: content_request_completion_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.content_request_completion_jobs (campaign_id, workspace_id, actor_id, created_at) FROM stdin;
\.


--
-- Data for Name: mail_attachments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_attachments (id, workspace_id, uploaded_by, name, content_type, size, s3_key, kind, bound, created_at) FROM stdin;
\.


--
-- Data for Name: mail_batches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_batches (id, workspace_id, workspace_name, template_id, template_name, sent_by, sender_email, sender_name, kind, status, subject, body_html, attachments, scheduled_at, timezone, total, accepted, rejected_count, sent_count, failed_count, suppressed_count, created_at, completed_at) FROM stdin;
\.


--
-- Data for Name: mail_deliveries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_deliveries (id, batch_id, recipient, recipient_name, variables, rendered_subject, rendered_body_html, external_audience, status, attempts, last_error, next_attempt_at, sent_at, event_key) FROM stdin;
\.


--
-- Data for Name: mail_send_quota; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_send_quota (day, scope, scope_id, sent_count) FROM stdin;
\.


--
-- Data for Name: mail_suppressions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.mail_suppressions (id, workspace_id, email_lower, reason, created_at) FROM stdin;
\.


--
-- Data for Name: media_campaigns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.media_campaigns (id, workspace_media_package_id, name, strategy_detail, package_terms_snapshot, package_terms_version, allocation_period, allocations, deliverable_plan, work_items, content_version, row_version, brand_guideline, timeline, status, approved_by_agency_at, approved_by_agency_id, approved_by_agency_version, approved_by_client_at, approved_by_client_id, approved_by_client_version, completed_at, completed_by, completion_reason, completion_task_summary, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: media_packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.media_packages (id, name, is_template, agency_id, source_template_id, is_available_to_workspaces, duration_weeks, budget_amount, scope_description, offering_details, created_by, created_at, updated_at) FROM stdin;
d1999e40-8e37-4b9c-bd98-69fb37fabe2c	Chiến dịch ra mắt sản phẩm	t	\N	\N	t	6	18000000.00	Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.	{"maxChanges": 2, "deliverables": [{"id": "e30c97fa-29a3-4e78-8848-dfbe9f55adc8", "name": "Bài đăng ra mắt", "unit": "bài", "quantity": 12, "description": "Lập kế hoạch và bàn giao nội dung truyền thông cho một chiến dịch ra mắt sản phẩm.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.482797+00	2026-10-15 13:02:15.48285+00
b82375a4-46c7-4644-8c1e-8ef96c9db6df	Chiến dịch truyền thông sự kiện	t	\N	\N	t	8	24000000.00	Bàn giao kế hoạch sự kiện và nội dung truyền thông; không bao gồm quản lý hậu cần sự kiện.	{"maxChanges": 2, "deliverables": [{"id": "e86ec616-869b-4e5d-b316-692d3d36499b", "name": "Kế hoạch truyền thông sự kiện", "unit": "bản kế hoạch", "quantity": 1, "description": "Bàn giao kế hoạch sự kiện và nội dung truyền thông; không bao gồm quản lý hậu cần sự kiện.", "serviceType": "EVENT_PLANNING", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.501026+00	2026-10-15 13:02:15.501034+00
b24db443-21bc-4fb7-acd6-dcea462dade4	Chiến dịch livestream giới thiệu sản phẩm	t	\N	\N	t	6	22000000.00	Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.	{"maxChanges": 2, "deliverables": [{"id": "319be32f-6bd8-4031-bfd3-e7da36d3634f", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 2, "description": "Hỗ trợ lên kế hoạch và chuẩn bị livestream; không trực tiếp vận hành phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.5018+00	2026-10-15 13:02:15.501805+00
a9a96baa-aece-443d-90ae-1780e978a625	Chiến dịch truyền thông báo điện tử	t	\N	\N	t	8	30000000.00	Gợi ý các bên báo điện tử phù hợp; không bao gồm booking hoặc quản lý đối tác.	{"maxChanges": 2, "deliverables": [{"id": "b4c61983-d7e6-4fb5-aa82-169c996fdeb2", "name": "Danh sách đối tác báo điện tử đề xuất", "unit": "danh sách", "quantity": 1, "description": "Gợi ý các bên báo điện tử phù hợp; không bao gồm booking hoặc quản lý đối tác.", "serviceType": "PRESS_RECOMMENDATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.502427+00	2026-10-15 13:02:15.50243+00
f822c6a0-8fa5-4db5-8198-0fe3369f2f8b	Chăm sóc kênh mạng xã hội hàng tháng	t	\N	\N	t	4	12000000.00	Sản lượng tính riêng từng tháng, không chuyển phần chưa dùng sang tháng sau.	{"maxChanges": 2, "deliverables": [{"id": "0bff6dfc-7dfe-481f-b7ac-d1b2284a826f", "name": "Bài đăng mạng xã hội mỗi tháng", "unit": "bài/tháng", "quantity": 12, "description": "Sản lượng tính riêng từng tháng, không chuyển phần chưa dùng sang tháng sau.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.502989+00	2026-10-15 13:02:15.502992+00
6a9e1fe1-d4d6-4738-b9a7-7fdf9a39be27	Nội dung thương hiệu hàng tháng	t	\N	\N	t	4	15000000.00	Manager chủ động tạo Campaign theo tháng; sản lượng tháng trước không được cộng dồn.	{"maxChanges": 2, "deliverables": [{"id": "c6cc022f-1ee7-4b5e-a6c4-17c598b8751f", "name": "Bài nội dung thương hiệu mỗi tháng", "unit": "bài/tháng", "quantity": 16, "description": "Manager chủ động tạo Campaign theo tháng; sản lượng tháng trước không được cộng dồn.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.503593+00	2026-10-15 13:02:15.503596+00
9f509759-13bf-4cc9-8869-164ef8e2f9ea	Hỗ trợ workshop hàng tháng	t	\N	\N	t	4	10000000.00	Hỗ trợ tạo link Meet và survey; không quản lý agenda hoặc hậu cần sự kiện.	{"maxChanges": 2, "deliverables": [{"id": "79a403b5-ca37-4ef2-ac16-fed917ba98fd", "name": "Buổi workshop hỗ trợ mỗi tháng", "unit": "buổi/tháng", "quantity": 2, "description": "Hỗ trợ tạo link Meet và survey; không quản lý agenda hoặc hậu cần sự kiện.", "serviceType": "WORKSHOP_SUPPORT", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.504106+00	2026-10-15 13:02:15.504108+00
439153d3-6282-4e76-8151-c5b52b58895b	Bộ 20 bài đăng mạng xã hội	t	\N	\N	t	12	16000000.00	Phân bổ số bài vào từng Campaign; tổng phân bổ không vượt sản lượng gói.	{"maxChanges": 2, "deliverables": [{"id": "483fcf06-72d4-4b02-949a-db544d794536", "name": "Bài đăng mạng xã hội", "unit": "bài", "quantity": 20, "description": "Phân bổ số bài vào từng Campaign; tổng phân bổ không vượt sản lượng gói.", "serviceType": "SOCIAL_POST", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.504444+00	2026-10-15 13:02:15.504445+00
c38c7bb8-dd31-4e37-9c98-dbb1fdd4d099	Bộ hỗ trợ 4 buổi livestream	t	\N	\N	t	12	20000000.00	Phân bổ số buổi vào từng Campaign; chỉ hỗ trợ chuẩn bị, không trực tiếp phát sóng.	{"maxChanges": 2, "deliverables": [{"id": "af4a41c6-ca3d-4afe-b320-f8b87cca939f", "name": "Bộ tài liệu chuẩn bị livestream", "unit": "buổi", "quantity": 4, "description": "Phân bổ số buổi vào từng Campaign; chỉ hỗ trợ chuẩn bị, không trực tiếp phát sóng.", "serviceType": "LIVESTREAM_PREPARATION", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.504928+00	2026-10-15 13:02:15.504931+00
236d3651-55e5-4544-945b-06da86143a6a	Bộ kế hoạch 3 sự kiện	t	\N	\N	t	12	21000000.00	Phân bổ kế hoạch vào từng Campaign; không bao gồm module hậu cần hay vận hành sự kiện.	{"maxChanges": 2, "deliverables": [{"id": "5c965936-72f1-4f5b-b63a-5eb495ae41fc", "name": "Kế hoạch sự kiện bàn giao", "unit": "bản kế hoạch", "quantity": 3, "description": "Phân bổ kế hoạch vào từng Campaign; không bao gồm module hậu cần hay vận hành sự kiện.", "serviceType": "EVENT_PLANNING", "revisionLimit": null, "acceptanceCriteria": "Bàn giao và được khách hàng xác nhận"}]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.505331+00	2026-10-15 13:02:15.505333+00
\.


--
-- Data for Name: monitoring_collectors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_collectors (id, name, server_id, token_hash, last_seen_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: monitoring_enrollments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_enrollments (token_hash, name, environment, expires_at) FROM stdin;
\.


--
-- Data for Name: monitoring_health_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_health_results (target_id, collector_id, check_id, outcome, checked_at, received_at, latency_ms, reason_code, http_status, runtime_state, runtime_health) FROM stdin;
\.


--
-- Data for Name: monitoring_health_targets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_health_targets (id, name, kind, environment, server_id, service_name, instance_id, collector_id, check_scope, probe_type, probe_config, assertion, credential_ref, interval_seconds, timeout_seconds, stale_after_seconds, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: monitoring_servers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.monitoring_servers (id, name, ip_address, environment, deployed_services, agent_token_hash, cpu_percent, ram_percent, disk_percent, uptime_seconds, last_seen_at, created_at, updated_at) FROM stdin;
11111111-1111-4111-8111-111111111111	business-service	10.0.0.11	development	{business-service}	0000000000000000000000000000000000000000000000000000000000000000	42.50	61.30	38.00	259200	2026-10-15 13:53:44.715881+00	2026-10-15 13:53:44.715881+00	2026-10-15 13:53:44.715881+00
22222222-2222-4222-8222-222222222222	api-gateway	10.0.0.12	development	{api-gateway}	1111111111111111111111111111111111111111111111111111111111111111	18.20	35.70	22.40	86400	2026-10-15 13:53:44.715881+00	2026-10-15 13:53:44.715881+00	2026-10-15 13:53:44.715881+00
\.


--
-- Data for Name: package_negotiation_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.package_negotiation_events (id, workspace_media_package_id, terms_version, action, actor_id, actor_role, note, terms_snapshot, created_at) FROM stdin;
1aa2c2be-7317-41fb-933b-8c5a8ec03bc4	ab486006-0d52-41a4-939d-6a3c70fd6f5e	1	BASELINE	\N	\N	\N	{}	2026-10-18 15:01:43.374518+00
4e394947-3afd-458d-8177-c05ab07dda4b	24c89d13-888b-4520-8bb5-556800111ea8	1	BASELINE	\N	\N	\N	{}	2026-10-18 15:01:43.374518+00
e6d128fc-a51e-40bb-bdc9-58fa5fca6c5b	dbbfeff8-6c1b-4103-97f3-e8936f6803e0	1	BASELINE	\N	\N	\N	{}	2026-10-18 15:01:43.374518+00
\.


--
-- Data for Name: sanction_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sanction_reviews (id, user_id, status, created_at, resolved_at, resolved_by, reason) FROM stdin;
\.


--
-- Data for Name: seed_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.seed_runs (dataset, dataset_version, run_id, status, last_stage, record_counts, manifest, failure_summary, started_at, completed_at, failed_at) FROM stdin;
\.


--
-- Data for Name: subscription_plan_changes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_plan_changes (id, user_id, plan_id, status, effective_at, payment_required, requested_by, reason, created_at) FROM stdin;
\.


--
-- Data for Name: subscription_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_plans (id, name, display_name, price_monthly, max_workspaces, ai_credits_month, features, is_active, created_at) FROM stdin;
57744897-d1dd-40af-b966-dda454c5ede1	BASIC	Basic	490000.00	3	200	["scheduling", "approval_workflow"]	t	2026-10-15 12:00:06.299874+00
705f8cde-1243-4c98-a484-44798b5ee0a3	PRO	Pro	990000.00	10	1000	["scheduling", "approval_workflow", "ai_content", "analytics"]	t	2026-10-15 12:00:06.299874+00
0fc26db2-a313-4d62-b038-6e5d5dde210f	ENTERPRISE	Enterprise	2990000.00	-1	5000	["all_features", "unlimited_workspaces", "dedicated_support"]	t	2026-10-15 12:00:06.299874+00
\.


--
-- Data for Name: task_content_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_content_operations (id, task_id, sequence_number, yjs_update, edited_by, created_at) FROM stdin;
\.


--
-- Data for Name: task_content_snapshots; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.task_content_snapshots (id, task_id, sequence_number, yjs_state, created_at) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tasks (id, workspace_id, type, title, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: third_party_collaborators; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.third_party_collaborators (id, agency_id, partner_name, partner_type, contact_info, notes, is_active, first_used_at, usage_history_verified, version, created_by, created_at, updated_at) FROM stdin;
ba0fcd56-2232-4494-994b-a0a1ce2bfa1a	fdc4d009-16bb-498c-988a-bf5cccb6992e	Hermann Inc	BANNER	{}	\N	t	\N	f	0	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.877969+00	2026-10-15 13:02:14.877973+00
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, user_id, type, amount, currency, status, ref_id, payos_tx_id, paid_at, failed_reason, created_at, updated_at) FROM stdin;
749186cc-186f-4eea-9a8c-64270c6c4445	80baa35d-db56-467f-a2b1-7b00a8e1267d	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-09-14 13:02:14.563261+00	\N	2026-10-15 13:02:14.563419+00	2026-10-15 13:02:14.563421+00
658d7887-f2f0-4103-8872-8a20bc3abb9b	09100a6a-650a-4447-bfd2-9b69c6414a17	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-08-11 13:02:14.563426+00	\N	2026-10-15 13:02:14.563435+00	2026-10-15 13:02:14.563435+00
fef1ec7d-5407-4dc2-88ea-a5ade48a0b44	70e9c6e4-d61d-4873-871d-60c2245b2535	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-09-22 13:02:14.563443+00	\N	2026-10-15 13:02:14.563446+00	2026-10-15 13:02:14.563446+00
e3c7e61b-160c-4190-8c6e-f8f2363ce07a	8d7452b9-ea9b-45fa-a4dd-98957181551e	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-08-16 13:02:14.56345+00	\N	2026-10-15 13:02:14.563484+00	2026-10-15 13:02:14.563485+00
ab855da8-99bb-46bc-ad60-acfe194bf42d	d0cb9330-14c1-4754-9426-26cf2704af23	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-09-25 13:02:14.563487+00	\N	2026-10-15 13:02:14.563491+00	2026-10-15 13:02:14.563491+00
242e7726-81f3-490a-81e9-d4904061fa86	5dbbc0d6-be78-4a24-8031-72758db2ad15	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-07-24 13:02:14.563492+00	\N	2026-10-15 13:02:14.563495+00	2026-10-15 13:02:14.563495+00
47b3ae70-f8bc-4bce-b1fe-3e44c51ccc31	66803ff6-926b-483c-a248-53d377e93c08	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-10-14 13:02:14.563496+00	\N	2026-10-15 13:02:14.563499+00	2026-10-15 13:02:14.563499+00
498cb684-1fe0-4b6e-9cd9-91047fd1dd48	c488c93c-04d5-491c-81ff-6fefd585e4ba	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-07-31 13:02:14.5635+00	\N	2026-10-15 13:02:14.563502+00	2026-10-15 13:02:14.563503+00
152093c3-c67e-4960-aab0-2612a2c098d5	72d80126-9326-4bb9-8859-dc3ae6d49c6f	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-08-15 13:02:14.563503+00	\N	2026-10-15 13:02:14.563505+00	2026-10-15 13:02:14.563506+00
a84404e2-24be-44fd-b9f8-69c995deb135	308fec0e-308b-4b71-bf8f-7f6fb73998c4	UPGRADE_PLAN	2990000.00	VND	COMPLETED	\N	\N	2026-09-28 13:02:14.563521+00	\N	2026-10-15 13:02:14.563524+00	2026-10-15 13:02:14.563524+00
602cd4ed-422b-4e8a-ac5a-2a4998e97629	1d1da7bf-24f8-412e-8ac7-7f0196e2c948	UPGRADE_PLAN	990000.00	VND	COMPLETED	\N	\N	2026-09-26 13:02:14.563527+00	\N	2026-10-15 13:02:14.563544+00	2026-10-15 13:02:14.563545+00
\.


--
-- Data for Name: user_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_notifications (id, user_id, notification_id, type, title, content, action_url, created_at, read_at) FROM stdin;
\.


--
-- Data for Name: user_oauth_providers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_oauth_providers (id, user_id, provider, provider_id, created_at) FROM stdin;
8aa1d144-96dd-4df6-b8c3-cae2ad1362ba	c488c93c-04d5-491c-81ff-6fefd585e4ba	GOOGLE	03c1731b-ecfc-40bb-bf23-62733f20465a	2026-10-15 13:02:14.514887+00
b515e671-574e-4ec8-a26e-1e189069b8d5	effdb285-3ac6-49f6-84f5-7de361b2a917	GOOGLE	845e8b43-72f2-4908-a448-559d9dcbb46c	2026-10-15 13:02:14.514905+00
4443c251-5433-49cc-9bff-11e23cd04253	effdb285-3ac6-49f6-84f5-7de361b2a917	GOOGLE	e20bf23e-541e-4480-bb40-6bb3bb45430b	2026-10-15 13:02:14.515437+00
8fc1d1da-a8cf-4779-9059-f83cdfc60ab3	678b53b7-8ce5-49a7-99d9-683888ecdd86	GOOGLE	110504591541054906407	2026-10-15 16:05:52.643587+00
\.


--
-- Data for Name: user_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_refresh_tokens (id, user_id, token_hash, jti, expires_at, ip_address, user_agent, device_info, created_at) FROM stdin;
\.


--
-- Data for Name: user_strikes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_strikes (id, user_id, level, category, reason, created_by, created_at, expires_at, converted_to_id, removed_by, removed_at, removal_reason) FROM stdin;
\.


--
-- Data for Name: user_subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_subscriptions (id, user_id, plan_id, status, current_period_start, current_period_end, cancelled_at, created_at, updated_at) FROM stdin;
b146dd1c-3bd7-46a4-a2bb-6b981a0c8726	80baa35d-db56-467f-a2b1-7b00a8e1267d	705f8cde-1243-4c98-a484-44798b5ee0a3	ACTIVE	2026-09-14 13:02:14.563261+00	2026-10-14 13:02:14.563261+00	\N	2026-10-15 13:02:14.56335+00	2026-10-15 13:02:14.563352+00
0dff2dad-e6cd-46ec-8c73-09641c3d6ab9	09100a6a-650a-4447-bfd2-9b69c6414a17	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-08-11 13:02:14.563426+00	2026-09-11 13:02:14.563426+00	\N	2026-10-15 13:02:14.563432+00	2026-10-15 13:02:14.563433+00
7057735b-9715-4f53-aa70-ae611a428db6	effdb285-3ac6-49f6-84f5-7de361b2a917	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-10-10 13:02:14.563437+00	2026-11-10 13:02:14.563437+00	\N	2026-10-15 13:02:14.563439+00	2026-10-15 13:02:14.56344+00
558440dc-3967-47d2-844d-d09ef12cbf8f	ff5ef145-66ee-48ad-be5b-04584666614c	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-09-12 13:02:14.563441+00	2026-10-12 13:02:14.563441+00	\N	2026-10-15 13:02:14.563442+00	2026-10-15 13:02:14.563442+00
d647ee34-56da-4a6c-ab74-2cbd7aabc19b	70e9c6e4-d61d-4873-871d-60c2245b2535	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-09-22 13:02:14.563443+00	2026-10-22 13:02:14.563443+00	\N	2026-10-15 13:02:14.563444+00	2026-10-15 13:02:14.563445+00
75c0e41a-fa73-4a00-96cd-10669f0eb7fa	8331dbad-2d99-4384-a786-28f5f8c055d5	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-09-14 13:02:14.563447+00	2026-10-14 13:02:14.563447+00	\N	2026-10-15 13:02:14.563448+00	2026-10-15 13:02:14.563449+00
5f8a79dc-375b-420d-a557-03c6be7ee284	8d7452b9-ea9b-45fa-a4dd-98957181551e	705f8cde-1243-4c98-a484-44798b5ee0a3	ACTIVE	2026-08-16 13:02:14.56345+00	2026-09-16 13:02:14.56345+00	\N	2026-10-15 13:02:14.563482+00	2026-10-15 13:02:14.563482+00
b7966d07-0f90-4e1f-ac13-3c1b4b7339e2	d0cb9330-14c1-4754-9426-26cf2704af23	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-09-25 13:02:14.563487+00	2026-10-25 13:02:14.563487+00	\N	2026-10-15 13:02:14.563489+00	2026-10-15 13:02:14.563489+00
e8c08f96-b408-4bdb-b5b5-f1d9b5237fbc	5dbbc0d6-be78-4a24-8031-72758db2ad15	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-07-24 13:02:14.563492+00	2026-08-24 13:02:14.563492+00	\N	2026-10-15 13:02:14.563494+00	2026-10-15 13:02:14.563494+00
a98270c8-cb6f-4c89-af3d-40746cac52f2	66803ff6-926b-483c-a248-53d377e93c08	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-10-14 13:02:14.563496+00	2026-11-14 13:02:14.563496+00	\N	2026-10-15 13:02:14.563498+00	2026-10-15 13:02:14.563498+00
72bbf135-6ae7-461f-b354-35bc05f5b353	c488c93c-04d5-491c-81ff-6fefd585e4ba	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-07-31 13:02:14.5635+00	2026-08-31 13:02:14.5635+00	\N	2026-10-15 13:02:14.563501+00	2026-10-15 13:02:14.563501+00
43fe0188-a2f2-47cb-98d8-d6f1ee71c005	72d80126-9326-4bb9-8859-dc3ae6d49c6f	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-08-15 13:02:14.563503+00	2026-09-15 13:02:14.563503+00	\N	2026-10-15 13:02:14.563504+00	2026-10-15 13:02:14.563505+00
ffb02ffc-abf6-4c21-9f38-63b3bd3f5036	d315f0c5-ff9f-4027-80f6-2f5cecea1933	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-09-10 13:02:14.563506+00	2026-10-10 13:02:14.563506+00	\N	2026-10-15 13:02:14.56352+00	2026-10-15 13:02:14.56352+00
0336bb24-b6fd-4333-a1b0-ac766ebb0931	308fec0e-308b-4b71-bf8f-7f6fb73998c4	0fc26db2-a313-4d62-b038-6e5d5dde210f	ACTIVE	2026-09-28 13:02:14.563521+00	2026-10-28 13:02:14.563521+00	\N	2026-10-15 13:02:14.563523+00	2026-10-15 13:02:14.563523+00
75418ad3-5387-4c12-8654-55e75b47600a	586202fc-923b-4dbf-b344-4bf9e8420786	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-08-05 13:02:14.563525+00	2026-09-05 13:02:14.563525+00	\N	2026-10-15 13:02:14.563526+00	2026-10-15 13:02:14.563526+00
adfce0bd-8422-4d69-8276-8cf8ab46f2fb	1d1da7bf-24f8-412e-8ac7-7f0196e2c948	705f8cde-1243-4c98-a484-44798b5ee0a3	ACTIVE	2026-09-26 13:02:14.563527+00	2026-10-26 13:02:14.563527+00	\N	2026-10-15 13:02:14.563528+00	2026-10-15 13:02:14.563529+00
211b4b22-8b09-448c-be47-5947cabda3c4	5c31518f-e781-4c68-9ca9-30cc5bc0c373	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-10-07 13:02:14.563617+00	2026-11-07 13:02:14.563617+00	\N	2026-10-15 13:02:14.563619+00	2026-10-15 13:02:14.563619+00
6db5b3d8-6d78-42b3-99ac-bc3a2523f036	48a76a32-50b1-4860-899c-0f549cc49fda	57744897-d1dd-40af-b966-dda454c5ede1	ACTIVE	2026-08-15 13:02:14.56377+00	2026-09-15 13:02:14.56377+00	\N	2026-10-15 13:02:14.563771+00	2026-10-15 13:02:14.563771+00
\.


--
-- Data for Name: user_system_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_system_roles (id, user_id, system_role, granted_by, granted_at) FROM stdin;
46eca7a0-dc73-40da-a7d4-97b8dd3794e8	80baa35d-db56-467f-a2b1-7b00a8e1267d	ADMIN	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:14.508453+00
e17b47ce-0117-4689-b380-9837bcfed044	678b53b7-8ce5-49a7-99d9-683888ecdd86	USER	\N	2026-10-15 16:05:52.641567+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, phone, password_hash, full_name, avatar_url, professional_title, bio, portfolio_urls, working_language, skills, location, years_of_experience, linkedin_url, facebook_url, instagram_url, tiktok_url, website, banner_url, status, is_active, last_banned_at, preferences, last_login_at, last_password_change, otp_code, otp_expiry, email_verified_at, two_factor_enabled, totp_secret, created_at, updated_at, clean_period_ends_at, reactivate_at, tokens_revoked_before, row_version, session_version, require_password_reset) FROM stdin;
09100a6a-650a-4447-bfd2-9b69c6414a17	user1@gmail.com	5478835842	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Waneta Gerhold	\N	Consultant	Maiores natus cupiditate laudantium ad repellat accusantium qui saepe numquam ut odit rerum fugit magni corrupti.	["https://klein.io/case-study", "https://ortiz.org/portfolio"]	id,th	["video-editing", "event-marketing", "market-research"]	South Jonah, Việt Nam	8	https://linkedin.com/in/cordie.upton	https://facebook.com/billie.rogahn	\N	https://tiktok.com/@sandie.oreilly	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-11-21 13:02:14.041762+00	f	\N	2026-10-15 13:02:14.245052+00	2026-10-15 13:02:14.245074+00	\N	\N	\N	0	0	f
effdb285-3ac6-49f6-84f5-7de361b2a917	user2@yahoo.com	8827542897	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Valerie Collier	\N	Social Media Manager	Ea culpa aliquam vero asperiores soluta rerum reiciendis vel molestiae id harum ullam consectetur dolores numquam.	["https://bechtelar.org/work"]	es	["campaign-management", "photography"]	Waltershire, Việt Nam	11	https://linkedin.com/in/darrin.kihn	https://facebook.com/myron.wisoky	\N	\N	https://hansen.info	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-11-24 13:02:14.044795+00	f	\N	2026-10-15 13:02:14.247231+00	2026-10-15 13:02:14.247253+00	\N	\N	\N	0	0	f
ff5ef145-66ee-48ad-be5b-04584666614c	user3@hotmail.com	5069374222	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Marylyn Kohler V	\N	Content Manager	\N	["https://glover.name/case-study", "https://graham.org/portfolio"]	th,en	["paid-ads", "ai-tools", "analytics", "video-editing"]	Isaacview, Việt Nam	1	\N	https://facebook.com/jared.wiza	\N	https://tiktok.com/@julio.greenfelder	https://waters.io	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-11-09 13:02:14.045658+00	f	\N	2026-10-15 13:02:14.249075+00	2026-10-15 13:02:14.249101+00	\N	\N	\N	0	0	f
70e9c6e4-d61d-4873-871d-60c2245b2535	user4@yahoo.com	3112284118	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Mr. Anderson Yundt	\N	Brand Manager	Nobis illo esse explicabo saepe nobis inventore quo delectus unde ullam sint aut odit reiciendis corporis soluta fugiat iusto aliquam.	["https://cremin.com/case-study", "https://okon.net/portfolio"]	id,th	["social-media", "event-marketing"]	Lake Joleen, Việt Nam	15	\N	\N	\N	https://tiktok.com/@gerard.bernhard	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-03-22 13:02:14.046265+00	f	\N	2026-10-15 13:02:14.250528+00	2026-10-15 13:02:14.250546+00	\N	\N	\N	0	0	f
000ef324-12e6-4285-a065-5dfedec456d4	user5@yahoo.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Juliet Kautzer	\N	Content Creator	Consequatur voluptates perspiciatis odit saepe dolor molestias doloribus blanditiis deleniti et fuga sunt enim corporis nam voluptas nihil consectetur.	["https://damore.biz/portfolio", "https://hyatt.io/work"]	hi,id	["graphic-design", "project-management", "video-editing", "market-research"]	Dickimouth, Việt Nam	\N	\N	https://facebook.com/reyes.gaylord	https://instagram.com/yasmin.conn	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-12-11 13:02:14.046574+00	f	\N	2026-10-15 13:02:14.25204+00	2026-10-15 13:02:14.252071+00	\N	\N	\N	0	0	f
5cf43ea3-549b-4862-a6e3-0a08593c1284	user6@yahoo.com	3336995961	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Nanci Jacobs	\N	Content Creator	\N	[]	pt	["campaign-management", "event-marketing", "market-research"]	Reingerland, Việt Nam	5	\N	\N	\N	\N	https://sipes.co	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-09-05 13:02:14.046759+00	f	\N	2026-10-15 13:02:14.252856+00	2026-10-15 13:02:14.252862+00	\N	\N	\N	0	0	f
7b0135b2-7c9b-42a7-aa98-f29942b46789	user7@yahoo.com	4521224329	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Mr. Kendrick Schowalter	\N	Agency Owner	\N	[]	pt	["graphic-design", "pr-communications"]	Jonathanmouth, Việt Nam	\N	https://linkedin.com/in/archie.fadel	https://facebook.com/kristopher.reinger	\N	\N	https://mcdermott.io	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-05-20 13:02:14.047296+00	f	\N	2026-10-15 13:02:14.254179+00	2026-10-15 13:02:14.254186+00	\N	\N	\N	0	0	f
29588313-9422-442b-b86a-0064a95bed02	user8@gmail.com	3929602111	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Antoine Feeney PhD	\N	Consultant	\N	["https://purdy.net/work", "https://koepp.io/portfolio"]	en	["project-management", "branding", "ecommerce"]	Marceloburgh, Việt Nam	\N	\N	https://facebook.com/pamala.stroman	https://instagram.com/natalia.wilkinson	https://tiktok.com/@linsey.bins	https://moen.biz	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-06-28 13:02:14.047567+00	f	\N	2026-10-15 13:02:14.255111+00	2026-10-15 13:02:14.255117+00	\N	\N	\N	0	0	f
8331dbad-2d99-4384-a786-28f5f8c055d5	user9@yahoo.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Jeff Veum	\N	Photographer	\N	["https://nitzsche.info/case-study", "https://shields.net/portfolio"]	zh,fr	["community-management", "campaign-management", "paid-ads", "market-research"]	Byrontown, Việt Nam	\N	https://linkedin.com/in/garfield.homenick	\N	\N	https://tiktok.com/@yang.russel	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-11-03 13:02:14.047763+00	f	\N	2026-10-15 13:02:14.255893+00	2026-10-15 13:02:14.255902+00	\N	\N	\N	0	0	f
8d7452b9-ea9b-45fa-a4dd-98957181551e	user10@hotmail.com	1640775403	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Mitch Haley	\N	Content Manager	\N	["https://gulgowski.info/work", "https://howe.name/portfolio"]	zh,it	["motion-graphics", "market-research", "graphic-design", "ui-ux", "analytics"]	Conroyport, Việt Nam	\N	\N	\N	https://instagram.com/marc.johnston	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-03-02 13:02:14.047931+00	f	\N	2026-10-15 13:02:14.25647+00	2026-10-15 13:02:14.256504+00	\N	\N	\N	0	0	f
5fc15832-6725-41b2-9922-f7b8e5730e8d	user11@yahoo.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Elias Zieme	\N	Consultant	\N	[]	fr	["influencer-marketing", "motion-graphics", "account-management", "campaign-management", "ecommerce"]	West Timothyview, Việt Nam	13	https://linkedin.com/in/orville.veum	https://facebook.com/jacquelynn.okuneva	\N	\N	https://walker.org	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-04-22 13:02:14.048813+00	f	\N	2026-10-15 13:02:14.25731+00	2026-10-15 13:02:14.25732+00	\N	\N	\N	0	0	f
d99c85b0-cca2-469a-a688-22aa2072362b	user12@hotmail.com	9441214140	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Mrs. Izola Cremin	\N	Social Media Manager	\N	["https://farrell.name/work", "https://little.biz/case-study"]	zh,vi	["paid-ads", "ai-tools"]	South Rolf, Việt Nam	7	\N	https://facebook.com/keith.zboncak	\N	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-10-19 13:02:14.048998+00	f	\N	2026-10-15 13:02:14.258059+00	2026-10-15 13:02:14.258065+00	\N	\N	\N	0	0	f
d0cb9330-14c1-4754-9426-26cf2704af23	user13@yahoo.com	9649662268	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Mr. Nathaniel Russel	\N	Product Manager	\N	[]	ru	["video-editing", "project-management", "event-marketing", "analytics"]	North Karyntown, Việt Nam	\N	\N	https://facebook.com/salome.langworth	https://instagram.com/kina.feeney	https://tiktok.com/@roman.wolff	https://hackett.io	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-10-04 13:02:14.049165+00	f	\N	2026-10-15 13:02:14.258566+00	2026-10-15 13:02:14.258571+00	\N	\N	\N	0	0	f
f00da3f2-9c63-4c5a-8e5c-ff08f37812ec	user14@yahoo.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Kali Reichel MD	\N	Copywriter	\N	["https://moore.info/case-study", "https://skiles.co/work"]	vi,pt	["paid-ads", "photography", "influencer-marketing"]	Wiegandfort, Việt Nam	13	\N	\N	https://instagram.com/derek.lesch	\N	https://koelpin.name	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-12-21 13:02:14.049343+00	f	\N	2026-10-15 13:02:14.259072+00	2026-10-15 13:02:14.259077+00	\N	\N	\N	0	0	f
6e50e113-f871-45db-bdf5-1de09f968fb4	user15@gmail.com	1695962467	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Ms. Conrad Gutmann	\N	Freelancer	Expedita nesciunt ratione ex asperiores voluptatem asperiores accusamus nesciunt ullam illo nam ducimus fuga ut accusamus laboriosam at repellendus.	[]	it,id	["community-management", "campaign-management", "paid-ads", "video-editing"]	Ignaciotown, Việt Nam	1	https://linkedin.com/in/fernando.douglas	\N	\N	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-11-29 13:02:14.049564+00	f	\N	2026-10-15 13:02:14.259589+00	2026-10-15 13:02:14.259594+00	\N	\N	\N	0	0	f
5dbbc0d6-be78-4a24-8031-72758db2ad15	user16@hotmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Giuseppe Gutkowski	\N	Marketing Manager	\N	["https://trantow.name/portfolio", "https://nienow.net/case-study"]	es,en	["seo", "graphic-design", "analytics", "ui-ux"]	Schillerview, Việt Nam	3	https://linkedin.com/in/shirlee.marks	https://facebook.com/julietta.okeefe	https://instagram.com/angie.gottlieb	\N	https://cummerata.co	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-04-16 13:02:14.05028+00	f	\N	2026-10-15 13:02:14.260097+00	2026-10-15 13:02:14.260101+00	\N	\N	\N	0	0	f
66803ff6-926b-483c-a248-53d377e93c08	user17@hotmail.com	7904720605	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Pablo Bruen Sr.	\N	Consultant	Cupiditate eius est quae minus tempore nemo impedit natus dignissimos voluptatibus sed deleniti expedita molestias sequi id dolore.	["https://lubowitz.biz/case-study", "https://mertz.co/portfolio"]	th	["graphic-design", "paid-ads", "email-marketing", "event-marketing"]	New Jeanellechester, Việt Nam	\N	https://linkedin.com/in/gerry.cormier	https://facebook.com/mose.weissnat	\N	https://tiktok.com/@sau.little	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-05-18 13:02:14.051119+00	f	\N	2026-10-15 13:02:14.260821+00	2026-10-15 13:02:14.260826+00	\N	\N	\N	0	0	f
c488c93c-04d5-491c-81ff-6fefd585e4ba	user18@gmail.com	3884448212	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Louis Satterfield	\N	Videographer	Eveniet repudiandae veniam inventore delectus quaerat veritatis explicabo fugiat quidem minima minus maiores recusandae sequi.	["https://borer.io/case-study"]	de,pt	["project-management", "video-editing"]	Geneton, Việt Nam	1	https://linkedin.com/in/luis.hessel	https://facebook.com/minda.sanford	https://instagram.com/dan.conn	\N	https://schowalter.net	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-10-24 13:02:14.051495+00	f	\N	2026-10-15 13:02:14.261385+00	2026-10-15 13:02:14.261392+00	\N	\N	\N	0	0	f
72d80126-9326-4bb9-8859-dc3ae6d49c6f	user19@hotmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Shenita Stamm	\N	Content Creator	Officia rerum quod perspiciatis tenetur incidunt iure quasi repudiandae tenetur eos rem ut velit qui voluptas cumque.	["https://labadie.com/case-study", "https://shields.name/portfolio"]	ko	["event-marketing", "seo"]	Thanhhaven, Việt Nam	\N	https://linkedin.com/in/lakeesha.jerde	\N	https://instagram.com/guadalupe.king	https://tiktok.com/@norman.haley	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-02-09 13:02:14.051962+00	f	\N	2026-10-15 13:02:14.261935+00	2026-10-15 13:02:14.26194+00	\N	\N	\N	0	0	f
d315f0c5-ff9f-4027-80f6-2f5cecea1933	user20@hotmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Lourdes Kilback PhD	\N	Account Manager	\N	["https://shields.name/portfolio", "https://trantow.co/work"]	fr,id	["email-marketing", "graphic-design", "storytelling", "ai-tools", "copywriting"]	South Meefort, Việt Nam	6	\N	\N	\N	https://tiktok.com/@shayna.windler	https://monahan.net	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-02-14 13:02:14.052371+00	f	\N	2026-10-15 13:02:14.262491+00	2026-10-15 13:02:14.262497+00	\N	\N	\N	0	0	f
308fec0e-308b-4b71-bf8f-7f6fb73998c4	user21@hotmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Pasquale Kris V	\N	Social Media Manager	Ullam amet id nostrum quis dicta nulla iste inventore cupiditate beatae nostrum vitae dicta ipsum rerum.	["https://kris.info/portfolio"]	ar,ko	["pr-communications", "copywriting", "storytelling", "video-editing"]	Strackeland, Việt Nam	3	https://linkedin.com/in/tobias.schulist	https://facebook.com/rayford.padberg	https://instagram.com/kellee.legros	\N	https://altenwerth.name	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-08-07 13:02:14.052563+00	f	\N	2026-10-15 13:02:14.26311+00	2026-10-15 13:02:14.263117+00	\N	\N	\N	0	0	f
749743be-c9d0-40ac-89ba-eaa354a65779	user22@yahoo.com	1543657684	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Leonida Johnston I	\N	Photographer	Sapiente aut veritatis optio sint expedita reprehenderit amet eos quia culpa ipsa necessitatibus aliquid praesentium deleniti maxime veniam dolorum.	["https://walter.name/portfolio", "https://hand.info/case-study"]	id,th	["ai-tools", "social-media", "project-management", "content-strategy"]	New Kaylaville, Việt Nam	11	\N	\N	\N	\N	https://reichert.io	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-06-16 13:02:14.052726+00	f	\N	2026-10-15 13:02:14.263806+00	2026-10-15 13:02:14.263813+00	\N	\N	\N	0	0	f
586202fc-923b-4dbf-b344-4bf9e8420786	user23@gmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Lorinda Simonis	\N	Consultant	Accusantium dolorum consectetur occaecati voluptate culpa fugiat commodi assumenda dolorem incidunt nulla enim reiciendis magnam corporis provident ullam doloribus ea.	[]	hi,it	["ui-ux", "storytelling", "branding"]	Silasfort, Việt Nam	\N	\N	https://facebook.com/sharell.schimmel	https://instagram.com/arcelia.simonis	https://tiktok.com/@olinda.wyman	https://jacobi.com	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-09-10 13:02:14.052863+00	f	\N	2026-10-15 13:02:14.264368+00	2026-10-15 13:02:14.264373+00	\N	\N	\N	0	0	f
835dc862-53f4-4fb1-8931-4236bc44668e	user24@yahoo.com	9194028556	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Shon Becker	\N	Photographer	Magnam omnis ut facere aliquam animi recusandae repudiandae maiores veniam sed occaecati consequuntur quod cum explicabo.	["https://swift.co/portfolio", "https://luettgen.info/case-study"]	vi	["content-strategy", "community-management", "ai-tools"]	Frankieburgh, Việt Nam	\N	https://linkedin.com/in/tommie.cartwright	\N	https://instagram.com/elmo.berge	\N	https://lehner.org	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2026-07-26 13:02:14.053045+00	f	\N	2026-10-15 13:02:14.264868+00	2026-10-15 13:02:14.264873+00	\N	\N	\N	0	0	f
1d1da7bf-24f8-412e-8ac7-7f0196e2c948	user25@yahoo.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Laurie Collier	\N	Product Manager	Iusto ad soluta pariatur ducimus deserunt suscipit beatae expedita quasi cumque earum neque totam deleniti quasi aut.	["https://langworth.org/portfolio", "https://spinka.info/case-study"]	ar	["ecommerce", "campaign-management", "market-research", "influencer-marketing", "content-strategy"]	Hartmannstad, Việt Nam	\N	\N	https://facebook.com/tommye.dickinson	\N	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-12-30 13:02:14.053241+00	f	\N	2026-10-15 13:02:14.265416+00	2026-10-15 13:02:14.265422+00	\N	\N	\N	0	0	f
48a76a32-50b1-4860-899c-0f549cc49fda	user91@gmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Dewayne Bechtelar DDS	\N	Agency Owner	\N	["https://mosciski.name/portfolio", "https://shanahan.info/case-study"]	es,it	["content-strategy", "market-research", "seo", "event-marketing"]	Lake Ramonamouth, Việt Nam	3	\N	\N	https://instagram.com/corinna.johnston	\N	\N	\N	ACTIVE	t	\N	{}	\N	\N	\N	\N	2025-11-26 13:02:14.073188+00	f	\N	2026-10-15 13:02:14.303096+00	2026-10-15 13:02:14.303101+00	\N	\N	\N	0	0	f
80baa35d-db56-467f-a2b1-7b00a8e1267d	admin@brandhub.dev	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	BrandHub Admin	\N	\N	\N	[]	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	t	\N	{}	2026-10-19 05:42:13.937082+00	\N	\N	\N	2026-10-15 13:02:13.805926+00	f	\N	2026-10-15 13:02:14.226959+00	2026-10-19 05:42:13.961919+00	\N	\N	\N	3	0	f
5c31518f-e781-4c68-9ca9-30cc5bc0c373	user59@gmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Man Koss	\N	Agency Owner	Sapiente aut laborum libero error deleniti accusantium itaque fugit neque deleniti suscipit illo autem laborum ut debitis quos.	["https://abernathy.biz/case-study", "https://nikolaus.biz/work"]	en,pt	["social-media", "motion-graphics"]	Estelaburgh, Việt Nam	15	https://linkedin.com/in/edra.sauer	\N	\N	https://tiktok.com/@verla.corkery	\N	\N	ACTIVE	t	\N	{}	2026-10-19 05:42:17.769285+00	\N	\N	\N	2026-08-12 13:02:14.06419+00	f	\N	2026-10-15 13:02:14.283072+00	2026-10-19 05:42:17.770205+00	\N	\N	\N	9	0	f
aaa8d970-45ce-45e7-b3b5-e7b48e87412f	user177@hotmail.com	\N	$2a$12$SdbfQ0xXoNga8x1kz/A9Q.HW2azRAju5kRwhceZ3rJDUNZiIWNVn6	Dr. Era Konopelski	\N	Social Media Manager	Occaecati mollitia culpa molestiae quasi cumque deleniti eligendi voluptas voluptatem dolor laboriosam occaecati magnam provident esse.	[]	ar	["ui-ux", "influencer-marketing", "ecommerce", "campaign-management"]	Rendachester, Việt Nam	8	https://linkedin.com/in/danna.koss	\N	\N	\N	\N	\N	ACTIVE	t	\N	{}	2026-10-15 13:28:22.347047+00	\N	\N	\N	2026-09-10 13:02:14.085818+00	f	\N	2026-10-15 13:02:14.357246+00	2026-10-15 13:28:22.348466+00	\N	\N	\N	2	0	f
678b53b7-8ce5-49a7-99d9-683888ecdd86	winhtuan@gmail.com	\N	\N	Nguyễn Tuấn	https://lh3.googleusercontent.com/a/ACg8ocLe7Ln71VvMyD6pxzhUdJFwU2cHN72YAgABnG4FJVUg6UlE05o=s96-c	\N	\N	[]	\N	[]	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	t	\N	{}	2026-10-18 13:51:33.451431+00	\N	\N	\N	2026-10-15 16:05:52.606649+00	f	\N	2026-10-15 16:05:52.658639+00	2026-10-18 13:51:33.400792+00	\N	\N	\N	5	0	f
\.


--
-- Data for Name: workspace_hashtags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_hashtags (id, workspace_id, tag, normalized_tag, purpose, added_by, added_by_name, is_required, campaign_id, deleted_at, deleted_by, created_at, updated_at, version) FROM stdin;
25cba92f-8010-4a6a-b669-74b2e248c095	0358c9db-9d5a-44c6-afad-1ef1b1bae674	Fashion2026	fashion2026	BRAND	5c31518f-e781-4c68-9ca9-30cc5bc0c373	Man Koss	f	\N	\N	\N	2026-10-18 13:59:36.395238+00	2026-10-18 13:59:36.395238+00	0
\.


--
-- Data for Name: workspace_invitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_invitations (id, workspace_id, invited_email, invited_by, token, role, status, expires_at, accepted_at, created_at) FROM stdin;
ade6f66c-637b-46d2-a659-a9429026c4b8	2d6e3b79-7a19-43bd-9f19-a8d0c5cd8862	lakeesha.dooley@hotmail.com	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	907a25ff-81f8-44c6-b6eb-f3d1dd9cafb6	CREATOR	PENDING	2026-10-22 13:02:15.373583+00	\N	2026-10-15 13:02:15.373583+00
a4998793-4503-4c50-945d-ecbd75234155	ccf99099-9791-43d8-8312-1538f014b0d4	chara.koelpin@gmail.com	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2d15b3fb-0e4b-46e6-8393-e749e66510f1	CREATOR	PENDING	2026-10-22 13:02:15.373686+00	\N	2026-10-15 13:02:15.373686+00
c1cbfe15-fe35-416f-aa21-cdb69488b576	491b128a-a08b-4d5b-ae3e-6dbcc48b00cb	user59@gmail.com	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	1932a2b0-716f-4902-a755-a95ee9bebf96	CREATOR	ACCEPTED	2026-10-22 13:31:49.449921+00	2026-10-15 13:31:52.667945+00	2026-10-15 13:31:49.449921+00
\.


--
-- Data for Name: workspace_media_packages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_media_packages (id, workspace_id, package_id, negotiation_status, final_terms, previous_terms, terms_version, client_proposal_count, approved_by_agency_at, approved_by_client_at, created_at, updated_at) FROM stdin;
ab486006-0d52-41a4-939d-6a3c70fd6f5e	51b87487-e35a-4867-9344-8fdfa8f488b1	a9a96baa-aece-443d-90ae-1780e978a625	AGENCY_COUNTERED	{}	\N	1	0	\N	\N	2026-10-15 13:02:15.517259+00	2026-10-15 13:02:15.51726+00
e1ed86da-3981-432c-a99e-d7a0fc30485b	9a463854-77c3-4699-ba6d-69d41c92423d	d1999e40-8e37-4b9c-bd98-69fb37fabe2c	DRAFT	{}	\N	1	0	\N	\N	2026-10-15 13:02:15.519156+00	2026-10-15 13:02:15.519158+00
24c89d13-888b-4520-8bb5-556800111ea8	ee0c3aa9-405a-4c4d-8909-dfd9f573487a	b24db443-21bc-4fb7-acd6-dcea462dade4	AGENCY_COUNTERED	{}	\N	1	0	\N	\N	2026-10-15 13:02:15.530842+00	2026-10-15 13:02:15.530844+00
dbbfeff8-6c1b-4103-97f3-e8936f6803e0	3fa21b85-107a-4564-b0e3-315882687c93	c38c7bb8-dd31-4e37-9c98-dbb1fdd4d099	APPROVED	{}	\N	1	0	\N	\N	2026-10-15 13:02:15.53123+00	2026-10-15 13:02:15.531232+00
\.


--
-- Data for Name: workspace_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_members (id, workspace_id, user_id, client_profile_id, role, added_by, joined_at, is_active, created_at, updated_at) FROM stdin;
06d13ade-be2f-4bf8-9901-51b81d86ec07	51b87487-e35a-4867-9344-8fdfa8f488b1	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	MANAGER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.994703+00	t	2026-10-15 13:02:14.994704+00	2026-10-15 13:02:14.994704+00
29c4c964-5b3a-4a5a-ac6e-499cefab106d	51b87487-e35a-4867-9344-8fdfa8f488b1	749743be-c9d0-40ac-89ba-eaa354a65779	\N	CREATOR	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-09-30 13:02:14.994707+00	t	2026-10-15 13:02:14.994708+00	2026-10-15 13:02:14.994709+00
950ff7fa-5b88-438f-83ff-845351afac6f	9a463854-77c3-4699-ba6d-69d41c92423d	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	MANAGER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.994953+00	t	2026-10-15 13:02:14.994953+00	2026-10-15 13:02:14.994953+00
cae51abc-8a51-4a6c-b20b-175e7528346b	2d6e3b79-7a19-43bd-9f19-a8d0c5cd8862	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	MANAGER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.996504+00	t	2026-10-15 13:02:14.996504+00	2026-10-15 13:02:14.996504+00
a174af15-f03f-42f3-8581-3a8bcd59a8cd	18d14f61-7973-45d5-a433-c4c7316d5a75	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	MANAGER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.996567+00	t	2026-10-15 13:02:14.996567+00	2026-10-15 13:02:14.996567+00
48dda21e-5ef3-459f-8b49-48d816e4f61b	79d109ae-1837-444b-9d83-d3bbc9596a09	48a76a32-50b1-4860-899c-0f549cc49fda	\N	MANAGER	48a76a32-50b1-4860-899c-0f549cc49fda	2026-10-15 13:02:14.996601+00	t	2026-10-15 13:02:14.996602+00	2026-10-15 13:02:14.996602+00
cb816281-27d5-4aec-8e90-052bc6aab4c8	79d109ae-1837-444b-9d83-d3bbc9596a09	\N	0abbfba8-a254-41ea-ab92-83c2f89c7247	CLIENT	48a76a32-50b1-4860-899c-0f549cc49fda	2026-10-13 13:02:14.996608+00	t	2026-10-15 13:02:14.996609+00	2026-10-15 13:02:14.996609+00
7006f302-accc-4bd6-bc18-2744e2b9ee52	ccf99099-9791-43d8-8312-1538f014b0d4	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	MANAGER	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:02:14.996688+00	t	2026-10-15 13:02:14.996688+00	2026-10-15 13:02:14.996688+00
af70ba69-5b5d-4d93-9800-6cbeac6df1f3	ccf99099-9791-43d8-8312-1538f014b0d4	1d1da7bf-24f8-412e-8ac7-7f0196e2c948	\N	CREATOR	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-08-30 13:02:14.996689+00	t	2026-10-15 13:02:14.99669+00	2026-10-15 13:02:14.99669+00
23d4dd6d-8e23-4fc2-a677-46c2d91add33	ccf99099-9791-43d8-8312-1538f014b0d4	\N	ab6d588d-5e5b-411f-9d5a-df401793a150	CLIENT	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-09-16 13:02:14.99669+00	t	2026-10-15 13:02:14.996691+00	2026-10-15 13:02:14.996691+00
043cce0b-206b-4595-b1bf-8417a194f5d8	ccf99099-9791-43d8-8312-1538f014b0d4	f00da3f2-9c63-4c5a-8e5c-ff08f37812ec	\N	CREATOR	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-08-27 13:02:14.996693+00	t	2026-10-15 13:02:14.996694+00	2026-10-15 13:02:14.996694+00
becbb476-516e-4ec5-9891-3e7c94fc608a	ee0c3aa9-405a-4c4d-8909-dfd9f573487a	48a76a32-50b1-4860-899c-0f549cc49fda	\N	MANAGER	48a76a32-50b1-4860-899c-0f549cc49fda	2026-10-15 13:02:14.996773+00	t	2026-10-15 13:02:14.996773+00	2026-10-15 13:02:14.996773+00
34976c85-5151-42f2-b410-e134052714dc	3fa21b85-107a-4564-b0e3-315882687c93	48a76a32-50b1-4860-899c-0f549cc49fda	\N	MANAGER	48a76a32-50b1-4860-899c-0f549cc49fda	2026-10-15 13:02:14.996793+00	t	2026-10-15 13:02:14.996794+00	2026-10-15 13:02:14.996794+00
16b4dafa-3a78-451c-a8a0-55e48b409521	0358c9db-9d5a-44c6-afad-1ef1b1bae674	48a76a32-50b1-4860-899c-0f549cc49fda	\N	MANAGER	48a76a32-50b1-4860-899c-0f549cc49fda	2026-10-15 13:02:14.996824+00	t	2026-10-15 13:02:14.996824+00	2026-10-15 13:02:14.996824+00
4cba1aed-7e2b-4bea-b601-5ebdaa0971d6	0358c9db-9d5a-44c6-afad-1ef1b1bae674	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	CREATOR	48a76a32-50b1-4860-899c-0f549cc49fda	2026-09-07 13:02:14.996827+00	t	2026-10-15 13:02:14.996842+00	2026-10-15 13:02:14.996855+00
fd43228f-2612-4e73-9454-1f9519f915a6	491b128a-a08b-4d5b-ae3e-6dbcc48b00cb	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	MANAGER	\N	2026-10-15 13:31:19.859074+00	t	2026-10-15 13:31:19.859074+00	2026-10-15 13:31:19.859074+00
25ca55d8-00b1-46c8-b6db-3419e3d1277e	491b128a-a08b-4d5b-ae3e-6dbcc48b00cb	5c31518f-e781-4c68-9ca9-30cc5bc0c373	\N	CREATOR	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	2026-10-15 13:31:52.66472+00	f	2026-10-15 13:31:52.66472+00	2026-10-15 13:33:05.163289+00
\.


--
-- Data for Name: workspace_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspace_templates (id, agency_id, name, source_workspace_id, config_snapshot, created_by, created_at) FROM stdin;
3f676950-85ed-4d9a-ae0a-aad270346f51	\N	FnB Khởi nghiệp	\N	{"phone": "(914) 442-0106", "tagline": "grid-enabled", "website": "https://www.scotty-halvorson.io/enim/ab?delectus=harum&laudantium=iste", "industry": "FNB", "location": "Reingerland", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_11_50", "description": "User-friendly coherent hierarchy", "facebookUrl": "https://facebook.com/recusandae_beatae", "foundedYear": 2005, "linkedinUrl": "https://linkedin.com/company/soluta_corporis", "instagramUrl": "https://instagram.com/doloremque_consequuntur", "industryFields": {"cuisineType": "Cauliflower Penne", "seatingCapacity": "67", "deliveryPlatforms": "GrabFood, ShopeeFood"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.475107+00
007f490d-6e8a-493f-9130-0c3e725e55d9	\N	FnB Chuỗi nhà hàng	\N	{"phone": "(505) 401-3140", "tagline": "background", "website": "https://www.sherise-beahan.net/#nisi", "industry": "FNB", "location": "Bobbiehaven", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_11_50", "description": "Cloned tertiary project", "facebookUrl": "https://facebook.com/culpa_reprehenderit", "foundedYear": 1999, "linkedinUrl": "https://linkedin.com/company/perspiciatis_ex", "instagramUrl": "https://instagram.com/tempore_eum", "industryFields": {"cuisineType": "Chicken Fajitas", "seatingCapacity": "65", "deliveryPlatforms": "GrabFood, ShopeeFood"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.47534+00
aa0b9d2a-10aa-408f-a9bd-81f5b4053b43	\N	FnB Quán cà phê	\N	{"phone": "(983) 950-2253", "tagline": "throughput", "website": "http://www.adolph-moore.biz:35242/?aperiam=quod&quod=dolorem", "industry": "FNB", "location": "New Loydview", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_201_500", "description": "Down-sized interactive info-mediaries", "facebookUrl": "https://facebook.com/pariatur_ea", "foundedYear": 2014, "linkedinUrl": "https://linkedin.com/company/iusto_esse", "instagramUrl": "https://instagram.com/temporibus_maxime", "industryFields": {"cuisineType": "Pierogi", "seatingCapacity": "42", "deliveryPlatforms": "GrabFood, ShopeeFood"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.475729+00
26f44cb8-7cc5-483e-aa46-683f8ddd518e	\N	Fashion Local Brand	\N	{"phone": "(903) 523-1853", "tagline": "hierarchy", "website": "https://www.brice-schoen.name/perferendis/quidem#sit", "industry": "FASHION", "location": "South Wondatown", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_201_500", "description": "Triple-buffered optimal knowledge base", "facebookUrl": "https://facebook.com/quasi_vel", "foundedYear": 2000, "linkedinUrl": "https://linkedin.com/company/quis_maxime", "instagramUrl": "https://instagram.com/at_similique", "industryFields": {"productCategories": "Áo, Quần, Phụ kiện", "seasonalCollections": "Xuân Hè, Thu Đông"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.475934+00
009f3438-f458-478b-a51d-2656339775b3	\N	Fashion Boutique	\N	{"phone": "(730) 679-3975", "tagline": "Phased", "website": "https://www.ruben-mitchell.net:52981/cumque", "industry": "FASHION", "location": "McDermottstad", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_1_10", "description": "Versatile local capacity", "facebookUrl": "https://facebook.com/eos_fugit", "foundedYear": 2022, "linkedinUrl": "https://linkedin.com/company/laborum_optio", "instagramUrl": "https://instagram.com/earum_neque", "industryFields": {"productCategories": "Áo, Quần, Phụ kiện", "seasonalCollections": "Xuân Hè, Thu Đông"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.476092+00
3e33437a-d8c3-41ac-88b4-04fd48a73e73	\N	Tech Startup SaaS	\N	{"phone": "(730) 246-4252", "tagline": "6th generation", "website": "https://www.codi-walsh.com/optio#iste", "industry": "TECHNOLOGY", "location": "North Remaside", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_201_500", "description": "Managed heuristic product", "facebookUrl": "https://facebook.com/fuga_at", "foundedYear": 2011, "linkedinUrl": "https://linkedin.com/company/recusandae_dignissimos", "instagramUrl": "https://instagram.com/itaque_nostrum", "industryFields": {"techStack": "React, Spring Boot", "productType": "SaaS"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.476252+00
8aef9349-3f7f-4a20-ba51-00e0d6e9ff25	\N	Tech Mobile App	\N	{"phone": "(730) 663-3156", "tagline": "Multi-channelled", "website": "https://www.ezekiel-gutmann.biz/", "industry": "TECHNOLOGY", "location": "North Lupe", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_1_10", "description": "Cloned asymmetric application", "facebookUrl": "https://facebook.com/nam_quis", "foundedYear": 2015, "linkedinUrl": "https://linkedin.com/company/perferendis_asperiores", "instagramUrl": "https://instagram.com/aperiam_rerum", "industryFields": {"techStack": "React, Spring Boot", "productType": "SaaS"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.476361+00
dec3c95b-f11e-4eb1-bf82-c7072fc40bd9	\N	Beauty Spa & Salon	\N	{"phone": "(505) 422-0325", "tagline": "Polarised", "website": "https://www.tracy-lockman.com/?tenetur=nulla&fugit=sequi#pariatur", "industry": "BEAUTY", "location": "Hammesland", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_1_10", "description": "Front-line static internet solution", "facebookUrl": "https://facebook.com/ex_rerum", "foundedYear": 1995, "linkedinUrl": "https://linkedin.com/company/doloribus_eligendi", "instagramUrl": "https://instagram.com/velit_error", "industryFields": {"serviceTypes": "Chăm sóc da, Trang điểm", "certifications": "ISO 22716"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.476505+00
888003de-e12c-4671-8774-a35821cdf4a2	\N	Beauty Skincare Brand	\N	{"phone": "(730) 220-8900", "tagline": "Front-line", "website": "https://www.ethelene-moore.name/aspernatur/minus?minima=dignissimos&impedit=in#nesciunt", "industry": "BEAUTY", "location": "Cassinmouth", "logoIcon": "briefcase", "timezone": "Asia/Ho_Chi_Minh", "brandColor": "#f05a28", "companySize": "SIZE_500_PLUS", "description": "Re-engineered cohesive ability", "facebookUrl": "https://facebook.com/optio_quam", "foundedYear": 2006, "linkedinUrl": "https://linkedin.com/company/sunt_dolores", "instagramUrl": "https://instagram.com/suscipit_dolore", "industryFields": {"serviceTypes": "Chăm sóc da, Trang điểm", "certifications": "ISO 22716"}, "reportFrequency": "WEEKLY", "defaultPlatforms": ["facebook", "instagram"]}	80baa35d-db56-467f-a2b1-7b00a8e1267d	2026-10-15 13:02:15.476688+00
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspaces (id, agency_id, name, created_by, workspace_media_package_id, source_workspace_id, duplication_request_id, duplication_fingerprint, timezone_config, settings, industry, company_size, website, phone, location, description, brand_color, logo_icon, logo_url, banner_url, tagline, founded_year, facebook_url, linkedin_url, instagram_url, status, deleted_at, created_at, updated_at) FROM stdin;
51b87487-e35a-4867-9344-8fdfa8f488b1	fdc4d009-16bb-498c-988a-bf5cccb6992e	Vietjet Air x Saatchi & Saatchi Vietnam	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	HEALTHCARE	SIZE_201_500	https://www.winnie-gibson.io:25883/cum/voluptatem?ut=similique&sequi=facilis	\N	New Wilfredton	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.919161+00	2026-10-15 13:02:14.919162+00
9a463854-77c3-4699-ba6d-69d41c92423d	fdc4d009-16bb-498c-988a-bf5cccb6992e	L'Oréal Paris x Saatchi & Saatchi Vietnam	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	OTHER	SIZE_201_500	https://www.nicolas-wolf.co/delectus/voluptatem?voluptatem=praesentium&perspiciatis=fugiat	\N	West Jesshaven	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.919311+00	2026-10-15 13:02:14.919311+00
2d6e3b79-7a19-43bd-9f19-a8d0c5cd8862	fdc4d009-16bb-498c-988a-bf5cccb6992e	Panasonic x Saatchi & Saatchi Vietnam	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	TECHNOLOGY	SIZE_201_500	https://www.jesus-kihn.co:53047/corporis/accusantiumsint?necessitatibus=distinctio&eius=reiciendis	\N	North Wiley	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.920877+00	2026-10-15 13:02:14.920878+00
18d14f61-7973-45d5-a433-c4c7316d5a75	5e52a493-ce6e-48c8-bae7-827e3972d10c	Traveloka x AIM Academy	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	HEALTHCARE	SIZE_11_50	https://www.adena-mraz.co:36369/suscipit/labore	\N	North Kourtneyview	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.921091+00	2026-10-15 13:02:14.921091+00
79d109ae-1837-444b-9d83-d3bbc9596a09	f2101bc2-7286-472a-b7e6-a99c49faf9a8	Kinh Do x Ogilvy Vietnam	48a76a32-50b1-4860-899c-0f549cc49fda	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	BEAUTY	SIZE_1_10	https://www.staci-russel.io/?molestias=saepe&distinctio=nemo#eos	\N	Schulistshire	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.921242+00	2026-10-15 13:02:14.921242+00
ccf99099-9791-43d8-8312-1538f014b0d4	5e52a493-ce6e-48c8-bae7-827e3972d10c	Sunhouse x AIM Academy	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	FASHION	SIZE_11_50	https://www.gil-skiles.co:47135/in/esse	\N	Lake Rigobertofort	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.921348+00	2026-10-15 13:02:14.921349+00
ee0c3aa9-405a-4c4d-8909-dfd9f573487a	f2101bc2-7286-472a-b7e6-a99c49faf9a8	Vinamilk x Ogilvy Vietnam	48a76a32-50b1-4860-899c-0f549cc49fda	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	REAL_ESTATE	SIZE_500_PLUS	https://www.charis-mayer.biz/autem/quilaborum?blanditiis=ex&assumenda=voluptas	\N	Titusberg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.921444+00	2026-10-15 13:02:14.921444+00
3fa21b85-107a-4564-b0e3-315882687c93	f2101bc2-7286-472a-b7e6-a99c49faf9a8	Coca-Cola x Ogilvy Vietnam	48a76a32-50b1-4860-899c-0f549cc49fda	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	HEALTHCARE	SIZE_1_10	https://www.issac-hamill.biz:26679/laudantium/perspiciatis?earum=eveniet&tenetur=perferendis#dolores	\N	Lake Rollandside	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.92156+00	2026-10-15 13:02:14.921561+00
0358c9db-9d5a-44c6-afad-1ef1b1bae674	f2101bc2-7286-472a-b7e6-a99c49faf9a8	VinFast Auto x Ogilvy Vietnam	48a76a32-50b1-4860-899c-0f549cc49fda	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{}	OTHER	SIZE_51_200	https://www.norman-jerde.biz/tenetur/perspiciatistenetur	\N	North Ben	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:02:14.921853+00	2026-10-15 13:02:14.921854+00
491b128a-a08b-4d5b-ae3e-6dbcc48b00cb	fb06ce2b-6c58-43d8-8f6a-f650f314c2da	Demo Workspace	aaa8d970-45ce-45e7-b3b5-e7b48e87412f	\N	\N	\N	\N	Asia/Ho_Chi_Minh	{"timezone": null, "industryFields": null, "defaultPlatforms": null}	\N	\N	\N	\N	\N	\N	#f05a28	megaphone	\N	\N	\N	\N	\N	\N	\N	ACTIVE	\N	2026-10-15 13:31:19.857071+00	2026-10-15 13:31:19.857071+00
\.


--
-- Name: audit_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_logs_id_seq', 64, true);


--
-- Name: account_activation_tokens account_activation_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_pkey PRIMARY KEY (id);


--
-- Name: account_activation_tokens account_activation_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: admin_account_operations admin_account_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_account_operations
    ADD CONSTRAINT admin_account_operations_pkey PRIMARY KEY (user_id, operation_id);


--
-- Name: admin_email_outbox admin_email_outbox_event_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_email_outbox
    ADD CONSTRAINT admin_email_outbox_event_key_key UNIQUE (event_key);


--
-- Name: admin_email_outbox admin_email_outbox_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_email_outbox
    ADD CONSTRAINT admin_email_outbox_pkey PRIMARY KEY (id);


--
-- Name: admin_notifications admin_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_notifications
    ADD CONSTRAINT admin_notifications_pkey PRIMARY KEY (id);


--
-- Name: admin_report_exports admin_report_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_report_exports
    ADD CONSTRAINT admin_report_exports_pkey PRIMARY KEY (id);


--
-- Name: agencies agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_pkey PRIMARY KEY (id);


--
-- Name: agency_invitations agency_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_pkey PRIMARY KEY (id);


--
-- Name: agency_invitations agency_invitations_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_token_key UNIQUE (token);


--
-- Name: agency_members agency_members_agency_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_agency_id_user_id_key UNIQUE (agency_id, user_id);


--
-- Name: agency_members agency_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_agency_id_creator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_agency_id_creator_id_key UNIQUE (agency_id, creator_id);


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_pkey PRIMARY KEY (id);


--
-- Name: ai_credit_ledgers ai_credit_ledgers_agency_id_month_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_ledgers
    ADD CONSTRAINT ai_credit_ledgers_agency_id_month_key UNIQUE (agency_id, month);


--
-- Name: ai_credit_ledgers ai_credit_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_ledgers
    ADD CONSTRAINT ai_credit_ledgers_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: campaign_collaborators campaign_collaborators_media_campaign_id_collaborator_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_media_campaign_id_collaborator_id_key UNIQUE (media_campaign_id, collaborator_id);


--
-- Name: campaign_collaborators campaign_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_pkey PRIMARY KEY (id);


--
-- Name: campaign_deployments campaign_deployments_campaign_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_campaign_id_key UNIQUE (campaign_id);


--
-- Name: campaign_deployments campaign_deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_pkey PRIMARY KEY (id);


--
-- Name: campaign_review_events campaign_review_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_review_events
    ADD CONSTRAINT campaign_review_events_pkey PRIMARY KEY (id);


--
-- Name: campaign_versions campaign_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT campaign_versions_pkey PRIMARY KEY (id);


--
-- Name: client_profiles client_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_profiles
    ADD CONSTRAINT client_profiles_pkey PRIMARY KEY (id);


--
-- Name: content_moderation_reviews content_moderation_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT content_moderation_reviews_pkey PRIMARY KEY (id);


--
-- Name: content_request_completion_jobs content_request_completion_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_request_completion_jobs
    ADD CONSTRAINT content_request_completion_jobs_pkey PRIMARY KEY (campaign_id);


--
-- Name: mail_attachments mail_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_attachments
    ADD CONSTRAINT mail_attachments_pkey PRIMARY KEY (id);


--
-- Name: mail_batches mail_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_pkey PRIMARY KEY (id);


--
-- Name: mail_deliveries mail_deliveries_event_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_deliveries
    ADD CONSTRAINT mail_deliveries_event_key_key UNIQUE (event_key);


--
-- Name: mail_deliveries mail_deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_deliveries
    ADD CONSTRAINT mail_deliveries_pkey PRIMARY KEY (id);


--
-- Name: mail_send_quota mail_send_quota_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_send_quota
    ADD CONSTRAINT mail_send_quota_pkey PRIMARY KEY (day, scope, scope_id);


--
-- Name: mail_suppressions mail_suppressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_pkey PRIMARY KEY (id);


--
-- Name: mail_suppressions mail_suppressions_workspace_id_email_lower_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_workspace_id_email_lower_key UNIQUE (workspace_id, email_lower);


--
-- Name: media_campaigns media_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_campaigns
    ADD CONSTRAINT media_campaigns_pkey PRIMARY KEY (id);


--
-- Name: media_packages media_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT media_packages_pkey PRIMARY KEY (id);


--
-- Name: monitoring_collectors monitoring_collectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_collectors
    ADD CONSTRAINT monitoring_collectors_pkey PRIMARY KEY (id);


--
-- Name: monitoring_enrollments monitoring_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_enrollments
    ADD CONSTRAINT monitoring_enrollments_pkey PRIMARY KEY (token_hash);


--
-- Name: monitoring_health_results monitoring_health_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_results
    ADD CONSTRAINT monitoring_health_results_pkey PRIMARY KEY (target_id);


--
-- Name: monitoring_health_targets monitoring_health_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT monitoring_health_targets_pkey PRIMARY KEY (id);


--
-- Name: monitoring_servers monitoring_servers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_servers
    ADD CONSTRAINT monitoring_servers_pkey PRIMARY KEY (id);


--
-- Name: package_negotiation_events package_negotiation_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_negotiation_events
    ADD CONSTRAINT package_negotiation_events_pkey PRIMARY KEY (id);


--
-- Name: sanction_reviews sanction_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sanction_reviews
    ADD CONSTRAINT sanction_reviews_pkey PRIMARY KEY (id);


--
-- Name: seed_runs seed_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seed_runs
    ADD CONSTRAINT seed_runs_pkey PRIMARY KEY (dataset, dataset_version);


--
-- Name: seed_runs seed_runs_run_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seed_runs
    ADD CONSTRAINT seed_runs_run_id_key UNIQUE (run_id);


--
-- Name: subscription_plan_changes subscription_plan_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_pkey PRIMARY KEY (id);


--
-- Name: subscription_plans subscription_plans_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_name_key UNIQUE (name);


--
-- Name: subscription_plans subscription_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plans
    ADD CONSTRAINT subscription_plans_pkey PRIMARY KEY (id);


--
-- Name: task_content_operations task_content_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_operations
    ADD CONSTRAINT task_content_operations_pkey PRIMARY KEY (id);


--
-- Name: task_content_operations task_content_operations_task_id_sequence_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_operations
    ADD CONSTRAINT task_content_operations_task_id_sequence_number_key UNIQUE (task_id, sequence_number);


--
-- Name: task_content_snapshots task_content_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_snapshots
    ADD CONSTRAINT task_content_snapshots_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: third_party_collaborators third_party_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.third_party_collaborators
    ADD CONSTRAINT third_party_collaborators_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_payos_tx_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_payos_tx_id_key UNIQUE (payos_tx_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: campaign_versions ukk0pnt9rnkhmegtd08lnloiscq; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT ukk0pnt9rnkhmegtd08lnloiscq UNIQUE (campaign_id, content_version);


--
-- Name: campaign_versions uq_campaign_versions_campaign_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT uq_campaign_versions_campaign_version UNIQUE (campaign_id, content_version);


--
-- Name: content_moderation_reviews uq_moderation_post_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT uq_moderation_post_version UNIQUE (post_id, content_version);


--
-- Name: monitoring_health_targets uq_monitoring_target_collector; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT uq_monitoring_target_collector UNIQUE (id, collector_id);


--
-- Name: package_negotiation_events uq_package_negotiation_events_version; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_negotiation_events
    ADD CONSTRAINT uq_package_negotiation_events_version UNIQUE (workspace_media_package_id, terms_version);


--
-- Name: user_notifications uq_user_notification; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT uq_user_notification UNIQUE (notification_id, user_id);


--
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- Name: user_oauth_providers user_oauth_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_oauth_providers
    ADD CONSTRAINT user_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: user_oauth_providers user_oauth_providers_provider_provider_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_oauth_providers
    ADD CONSTRAINT user_oauth_providers_provider_provider_id_key UNIQUE (provider, provider_id);


--
-- Name: user_refresh_tokens user_refresh_tokens_jti_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_jti_key UNIQUE (jti);


--
-- Name: user_refresh_tokens user_refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: user_refresh_tokens user_refresh_tokens_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_token_hash_key UNIQUE (token_hash);


--
-- Name: user_strikes user_strikes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_pkey PRIMARY KEY (id);


--
-- Name: user_subscriptions user_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: user_subscriptions user_subscriptions_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_key UNIQUE (user_id);


--
-- Name: user_system_roles user_system_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_pkey PRIMARY KEY (id);


--
-- Name: user_system_roles user_system_roles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_user_id_key UNIQUE (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workspace_hashtags workspace_hashtags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_pkey PRIMARY KEY (id);


--
-- Name: workspace_invitations workspace_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_pkey PRIMARY KEY (id);


--
-- Name: workspace_invitations workspace_invitations_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_token_key UNIQUE (token);


--
-- Name: workspace_invitations workspace_invitations_workspace_id_invited_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_workspace_id_invited_email_key UNIQUE (workspace_id, invited_email);


--
-- Name: workspace_media_packages workspace_media_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_pkey PRIMARY KEY (id);


--
-- Name: workspace_media_packages workspace_media_packages_workspace_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_workspace_id_key UNIQUE (workspace_id);


--
-- Name: workspace_members workspace_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_pkey PRIMARY KEY (id);


--
-- Name: workspace_templates workspace_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: idx_activation_tokens_open; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activation_tokens_open ON public.account_activation_tokens USING btree (user_id) WHERE ((used_at IS NULL) AND (revoked_at IS NULL));


--
-- Name: idx_admin_email_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_email_due ON public.admin_email_outbox USING btree (next_attempt_at) WHERE (sent_at IS NULL);


--
-- Name: idx_admin_email_outbox_notification; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_email_outbox_notification ON public.admin_email_outbox USING btree (notification_id) WHERE (notification_id IS NOT NULL);


--
-- Name: idx_admin_notifications_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_notifications_due ON public.admin_notifications USING btree (scheduled_at) WHERE ((status)::text = 'SCHEDULED'::text);


--
-- Name: idx_admin_notifications_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_notifications_history ON public.admin_notifications USING btree (created_at DESC, id DESC);


--
-- Name: idx_admin_report_exports_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_admin_report_exports_expiry ON public.admin_report_exports USING btree (expires_at) WHERE (content IS NOT NULL);


--
-- Name: idx_agencies_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agencies_owner_id ON public.agencies USING btree (owner_id);


--
-- Name: idx_agency_inv_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agency_inv_agency_id ON public.agency_invitations USING btree (agency_id);


--
-- Name: idx_agency_inv_unique_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_agency_inv_unique_pending ON public.agency_invitations USING btree (agency_id, invited_email) WHERE (status = 'PENDING'::public.invitation_status);


--
-- Name: idx_agency_members_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_agency_members_agency_id ON public.agency_members USING btree (agency_id);


--
-- Name: idx_audit_agency_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_agency_time ON public.audit_logs USING btree (agency_id, created_at DESC);


--
-- Name: idx_audit_resource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_resource ON public.audit_logs USING btree (resource_type, resource_id);


--
-- Name: idx_audit_user_time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_user_time ON public.audit_logs USING btree (user_id, created_at DESC);


--
-- Name: idx_campaign_deployments_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_campaign_deployments_status_created ON public.campaign_deployments USING btree (status, created_at);


--
-- Name: idx_campaign_review_events_campaign_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_campaign_review_events_campaign_created ON public.campaign_review_events USING btree (campaign_id, created_at DESC);


--
-- Name: idx_client_profiles_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_client_profiles_user_id ON public.client_profiles USING btree (user_id);


--
-- Name: idx_collaborators_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_collaborators_agency_id ON public.third_party_collaborators USING btree (agency_id);


--
-- Name: idx_content_req_completion_jobs_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_content_req_completion_jobs_created ON public.content_request_completion_jobs USING btree (created_at);


--
-- Name: idx_mail_attachments_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_attachments_workspace ON public.mail_attachments USING btree (workspace_id, bound, created_at);


--
-- Name: idx_mail_batches_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_batches_due ON public.mail_batches USING btree (status, scheduled_at);


--
-- Name: idx_mail_batches_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_batches_workspace ON public.mail_batches USING btree (workspace_id, created_at DESC);


--
-- Name: idx_mail_deliveries_batch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_deliveries_batch ON public.mail_deliveries USING btree (batch_id);


--
-- Name: idx_mail_deliveries_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mail_deliveries_due ON public.mail_deliveries USING btree (status, next_attempt_at);


--
-- Name: idx_media_campaigns_wmp_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_campaigns_wmp_id ON public.media_campaigns USING btree (workspace_media_package_id);


--
-- Name: idx_media_packages_agency_available; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_packages_agency_available ON public.media_packages USING btree (agency_id, is_available_to_workspaces) WHERE (NOT is_template);


--
-- Name: idx_media_packages_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_packages_agency_id ON public.media_packages USING btree (agency_id);


--
-- Name: idx_media_packages_is_template; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_media_packages_is_template ON public.media_packages USING btree (is_template);


--
-- Name: idx_moderation_author; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_moderation_author ON public.content_moderation_reviews USING btree (author_id);


--
-- Name: idx_moderation_queue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_moderation_queue ON public.content_moderation_reviews USING btree (status, created_at, id);


--
-- Name: idx_monitoring_collectors_server; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_collectors_server ON public.monitoring_collectors USING btree (server_id);


--
-- Name: idx_monitoring_enrollments_expiry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_enrollments_expiry ON public.monitoring_enrollments USING btree (expires_at);


--
-- Name: idx_monitoring_servers_environment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_servers_environment ON public.monitoring_servers USING btree (environment, name, id);


--
-- Name: idx_monitoring_targets_collector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_collector ON public.monitoring_health_targets USING btree (collector_id);


--
-- Name: idx_monitoring_targets_environment_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_environment_kind ON public.monitoring_health_targets USING btree (environment, kind);


--
-- Name: idx_monitoring_targets_server; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_server ON public.monitoring_health_targets USING btree (server_id);


--
-- Name: idx_monitoring_targets_service; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_monitoring_targets_service ON public.monitoring_health_targets USING btree (environment, service_name, instance_id);


--
-- Name: idx_oauth_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_oauth_user_id ON public.user_oauth_providers USING btree (user_id);


--
-- Name: idx_package_negotiation_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_package_negotiation_history ON public.package_negotiation_events USING btree (workspace_media_package_id, terms_version DESC);


--
-- Name: idx_rt_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rt_expires_at ON public.user_refresh_tokens USING btree (expires_at);


--
-- Name: idx_rt_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rt_user_id ON public.user_refresh_tokens USING btree (user_id);


--
-- Name: idx_sanction_one_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_sanction_one_pending ON public.sanction_reviews USING btree (user_id) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: idx_task_content_operations_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_content_operations_task_id ON public.task_content_operations USING btree (task_id);


--
-- Name: idx_task_content_snapshots_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_content_snapshots_task_id ON public.task_content_snapshots USING btree (task_id, sequence_number DESC);


--
-- Name: idx_tasks_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tasks_workspace_id ON public.tasks USING btree (workspace_id);


--
-- Name: idx_transactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_transactions_user_id ON public.transactions USING btree (user_id);


--
-- Name: idx_user_notifications_inbox; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_notifications_inbox ON public.user_notifications USING btree (user_id, created_at DESC, id DESC);


--
-- Name: idx_user_notifications_unread; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_notifications_unread ON public.user_notifications USING btree (user_id) WHERE (read_at IS NULL);


--
-- Name: idx_user_strikes_history; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_strikes_history ON public.user_strikes USING btree (user_id, created_at DESC, id DESC);


--
-- Name: idx_user_strikes_live; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_strikes_live ON public.user_strikes USING btree (user_id, expires_at) WHERE (removed_at IS NULL);


--
-- Name: idx_user_sub_status_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_sub_status_period ON public.user_subscriptions USING btree (status, current_period_end);


--
-- Name: idx_users_clean_period; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_clean_period ON public.users USING btree (clean_period_ends_at) WHERE (clean_period_ends_at IS NOT NULL);


--
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- Name: idx_users_reactivate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_reactivate ON public.users USING btree (reactivate_at) WHERE (reactivate_at IS NOT NULL);


--
-- Name: idx_wm_one_manager; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_wm_one_manager ON public.workspace_members USING btree (workspace_id) WHERE ((role = 'MANAGER'::public.workspace_member_role) AND (is_active = true));


--
-- Name: idx_wm_unique_client; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_wm_unique_client ON public.workspace_members USING btree (workspace_id, client_profile_id) WHERE (client_profile_id IS NOT NULL);


--
-- Name: idx_wm_unique_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_wm_unique_user ON public.workspace_members USING btree (workspace_id, user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_wm_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wm_workspace_id ON public.workspace_members USING btree (workspace_id);


--
-- Name: idx_workspace_inv_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_inv_workspace_id ON public.workspace_invitations USING btree (workspace_id);


--
-- Name: idx_workspace_templates_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspace_templates_agency_id ON public.workspace_templates USING btree (agency_id);


--
-- Name: idx_workspaces_agency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspaces_agency_id ON public.workspaces USING btree (agency_id);


--
-- Name: idx_workspaces_source_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_workspaces_source_workspace ON public.workspaces USING btree (source_workspace_id) WHERE (source_workspace_id IS NOT NULL);


--
-- Name: ix_workspace_hashtags_list; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_workspace_hashtags_list ON public.workspace_hashtags USING btree (workspace_id, created_at DESC, id DESC) WHERE (deleted_at IS NULL);


--
-- Name: uq_media_campaigns_agreement; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_media_campaigns_agreement ON public.media_campaigns USING btree (workspace_media_package_id);


--
-- Name: uq_plan_change_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_plan_change_pending ON public.subscription_plan_changes USING btree (user_id) WHERE ((status)::text = 'PENDING'::text);


--
-- Name: uq_workspace_hashtags_active_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspace_hashtags_active_tag ON public.workspace_hashtags USING btree (workspace_id, normalized_tag) WHERE (deleted_at IS NULL);


--
-- Name: uq_workspaces_duplication_request; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_workspaces_duplication_request ON public.workspaces USING btree (agency_id, duplication_request_id) WHERE (duplication_request_id IS NOT NULL);


--
-- Name: agencies trg_agencies_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_agencies_updated_at BEFORE UPDATE ON public.agencies FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: ai_credit_creator_limits trg_ai_credit_creator_limits_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ai_credit_creator_limits_updated_at BEFORE UPDATE ON public.ai_credit_creator_limits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: ai_credit_ledgers trg_ai_credit_ledgers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ai_credit_ledgers_updated_at BEFORE UPDATE ON public.ai_credit_ledgers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: audit_logs trg_audit_logs_no_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_audit_logs_no_delete BEFORE DELETE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_log_mutation();


--
-- Name: audit_logs trg_audit_logs_no_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_audit_logs_no_update BEFORE UPDATE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION public.prevent_audit_log_mutation();


--
-- Name: campaign_collaborators trg_campaign_collaborator_mark_used; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_campaign_collaborator_mark_used BEFORE INSERT ON public.campaign_collaborators FOR EACH ROW EXECUTE FUNCTION public.mark_collaborator_usage_on_link();


--
-- Name: campaign_collaborators trg_campaign_partner_usage; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_campaign_partner_usage BEFORE INSERT OR UPDATE OF collaborator_id ON public.campaign_collaborators FOR EACH ROW EXECUTE FUNCTION public.guard_campaign_partner_usage();


--
-- Name: client_profiles trg_client_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_client_profiles_updated_at BEFORE UPDATE ON public.client_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: third_party_collaborators trg_collaborators_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_collaborators_updated_at BEFORE UPDATE ON public.third_party_collaborators FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: media_campaigns trg_media_campaigns_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_media_campaigns_updated_at BEFORE UPDATE ON public.media_campaigns FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: media_packages trg_media_packages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_media_packages_updated_at BEFORE UPDATE ON public.media_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: package_negotiation_events trg_package_negotiation_events_append_only; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_package_negotiation_events_append_only BEFORE DELETE OR UPDATE ON public.package_negotiation_events FOR EACH ROW EXECUTE FUNCTION public.protect_package_negotiation_history();


--
-- Name: package_negotiation_events trg_package_negotiation_immutable; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_package_negotiation_immutable BEFORE DELETE OR UPDATE ON public.package_negotiation_events FOR EACH ROW EXECUTE FUNCTION public.guard_package_negotiation_history();


--
-- Name: transactions trg_transactions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_transactions_updated_at BEFORE UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: user_subscriptions trg_user_subscriptions_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_user_subscriptions_updated_at BEFORE UPDATE ON public.user_subscriptions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: workspace_media_packages trg_workspace_media_packages_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_workspace_media_packages_updated_at BEFORE UPDATE ON public.workspace_media_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: workspace_members trg_workspace_members_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_workspace_members_updated_at BEFORE UPDATE ON public.workspace_members FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: workspaces trg_workspaces_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_workspaces_updated_at BEFORE UPDATE ON public.workspaces FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: account_activation_tokens account_activation_tokens_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: account_activation_tokens account_activation_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_activation_tokens
    ADD CONSTRAINT account_activation_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: admin_account_operations admin_account_operations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_account_operations
    ADD CONSTRAINT admin_account_operations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: admin_email_outbox admin_email_outbox_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_email_outbox
    ADD CONSTRAINT admin_email_outbox_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.admin_notifications(id);


--
-- Name: admin_notifications admin_notifications_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_notifications
    ADD CONSTRAINT admin_notifications_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: admin_report_exports admin_report_exports_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_report_exports
    ADD CONSTRAINT admin_report_exports_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: agencies agencies_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agencies
    ADD CONSTRAINT agencies_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_invitations agency_invitations_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: agency_invitations agency_invitations_invited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT agency_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: agency_members agency_members_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: agency_members agency_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_members
    ADD CONSTRAINT agency_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: ai_credit_creator_limits ai_credit_creator_limits_set_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_creator_limits
    ADD CONSTRAINT ai_credit_creator_limits_set_by_fkey FOREIGN KEY (set_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: ai_credit_ledgers ai_credit_ledgers_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_credit_ledgers
    ADD CONSTRAINT ai_credit_ledgers_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: audit_logs audit_logs_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE SET NULL;


--
-- Name: campaign_collaborators campaign_collaborators_collaborator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_collaborator_id_fkey FOREIGN KEY (collaborator_id) REFERENCES public.third_party_collaborators(id) ON DELETE RESTRICT;


--
-- Name: campaign_collaborators campaign_collaborators_media_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_media_campaign_id_fkey FOREIGN KEY (media_campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_collaborators campaign_collaborators_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_collaborators
    ADD CONSTRAINT campaign_collaborators_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: campaign_deployments campaign_deployments_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_deployments campaign_deployments_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_deployments
    ADD CONSTRAINT campaign_deployments_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: campaign_review_events campaign_review_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_review_events
    ADD CONSTRAINT campaign_review_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: campaign_review_events campaign_review_events_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_review_events
    ADD CONSTRAINT campaign_review_events_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_versions campaign_versions_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT campaign_versions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: campaign_versions campaign_versions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_versions
    ADD CONSTRAINT campaign_versions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: client_profiles client_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_profiles
    ADD CONSTRAINT client_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: content_moderation_reviews content_moderation_reviews_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT content_moderation_reviews_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: content_moderation_reviews content_moderation_reviews_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_moderation_reviews
    ADD CONSTRAINT content_moderation_reviews_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id);


--
-- Name: agency_invitations fk_agency_inv_workspace_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agency_invitations
    ADD CONSTRAINT fk_agency_inv_workspace_id FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: content_request_completion_jobs fk_crcj_campaign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_request_completion_jobs
    ADD CONSTRAINT fk_crcj_campaign FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id) ON DELETE CASCADE;


--
-- Name: content_request_completion_jobs fk_crcj_workspace; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_request_completion_jobs
    ADD CONSTRAINT fk_crcj_workspace FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: media_packages fk_media_packages_agency; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT fk_media_packages_agency FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: media_packages fk_media_packages_source_template; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT fk_media_packages_source_template FOREIGN KEY (source_template_id) REFERENCES public.media_packages(id) ON DELETE SET NULL;


--
-- Name: monitoring_health_results fk_monitoring_result_owner; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_results
    ADD CONSTRAINT fk_monitoring_result_owner FOREIGN KEY (target_id, collector_id) REFERENCES public.monitoring_health_targets(id, collector_id) ON DELETE RESTRICT;


--
-- Name: workspaces fk_workspaces_media_package; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT fk_workspaces_media_package FOREIGN KEY (workspace_media_package_id) REFERENCES public.workspace_media_packages(id) ON DELETE SET NULL;


--
-- Name: mail_attachments mail_attachments_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_attachments
    ADD CONSTRAINT mail_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: mail_attachments mail_attachments_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_attachments
    ADD CONSTRAINT mail_attachments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: mail_batches mail_batches_sent_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_sent_by_fkey FOREIGN KEY (sent_by) REFERENCES public.users(id);


--
-- Name: mail_batches mail_batches_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_batches
    ADD CONSTRAINT mail_batches_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: mail_deliveries mail_deliveries_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_deliveries
    ADD CONSTRAINT mail_deliveries_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.mail_batches(id) ON DELETE CASCADE;


--
-- Name: mail_suppressions mail_suppressions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_suppressions
    ADD CONSTRAINT mail_suppressions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: media_campaigns media_campaigns_workspace_media_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_campaigns
    ADD CONSTRAINT media_campaigns_workspace_media_package_id_fkey FOREIGN KEY (workspace_media_package_id) REFERENCES public.workspace_media_packages(id) ON DELETE RESTRICT;


--
-- Name: media_packages media_packages_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.media_packages
    ADD CONSTRAINT media_packages_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: monitoring_collectors monitoring_collectors_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_collectors
    ADD CONSTRAINT monitoring_collectors_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.monitoring_servers(id) ON DELETE RESTRICT;


--
-- Name: monitoring_health_targets monitoring_health_targets_collector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT monitoring_health_targets_collector_id_fkey FOREIGN KEY (collector_id) REFERENCES public.monitoring_collectors(id) ON DELETE RESTRICT;


--
-- Name: monitoring_health_targets monitoring_health_targets_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.monitoring_health_targets
    ADD CONSTRAINT monitoring_health_targets_server_id_fkey FOREIGN KEY (server_id) REFERENCES public.monitoring_servers(id) ON DELETE RESTRICT;


--
-- Name: package_negotiation_events package_negotiation_events_workspace_media_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package_negotiation_events
    ADD CONSTRAINT package_negotiation_events_workspace_media_package_id_fkey FOREIGN KEY (workspace_media_package_id) REFERENCES public.workspace_media_packages(id) ON DELETE CASCADE;


--
-- Name: sanction_reviews sanction_reviews_resolved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sanction_reviews
    ADD CONSTRAINT sanction_reviews_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES public.users(id);


--
-- Name: sanction_reviews sanction_reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sanction_reviews
    ADD CONSTRAINT sanction_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: subscription_plan_changes subscription_plan_changes_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id);


--
-- Name: subscription_plan_changes subscription_plan_changes_requested_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES public.users(id);


--
-- Name: subscription_plan_changes subscription_plan_changes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscription_plan_changes
    ADD CONSTRAINT subscription_plan_changes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: task_content_operations task_content_operations_edited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_operations
    ADD CONSTRAINT task_content_operations_edited_by_fkey FOREIGN KEY (edited_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: third_party_collaborators third_party_collaborators_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.third_party_collaborators
    ADD CONSTRAINT third_party_collaborators_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: third_party_collaborators third_party_collaborators_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.third_party_collaborators
    ADD CONSTRAINT third_party_collaborators_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: transactions transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: user_notifications user_notifications_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.admin_notifications(id);


--
-- Name: user_notifications user_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_oauth_providers user_oauth_providers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_oauth_providers
    ADD CONSTRAINT user_oauth_providers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_refresh_tokens user_refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_refresh_tokens
    ADD CONSTRAINT user_refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_strikes user_strikes_converted_to_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_converted_to_id_fkey FOREIGN KEY (converted_to_id) REFERENCES public.user_strikes(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_strikes user_strikes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: user_strikes user_strikes_removed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_removed_by_fkey FOREIGN KEY (removed_by) REFERENCES public.users(id);


--
-- Name: user_strikes user_strikes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_strikes
    ADD CONSTRAINT user_strikes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_subscriptions user_subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id) ON DELETE RESTRICT;


--
-- Name: user_subscriptions user_subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_subscriptions
    ADD CONSTRAINT user_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: user_system_roles user_system_roles_granted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_system_roles user_system_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_system_roles
    ADD CONSTRAINT user_system_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workspace_hashtags workspace_hashtags_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id);


--
-- Name: workspace_hashtags workspace_hashtags_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.media_campaigns(id);


--
-- Name: workspace_hashtags workspace_hashtags_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: workspace_hashtags workspace_hashtags_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_hashtags
    ADD CONSTRAINT workspace_hashtags_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id);


--
-- Name: workspace_invitations workspace_invitations_invited_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_invited_by_fkey FOREIGN KEY (invited_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_invitations workspace_invitations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_invitations
    ADD CONSTRAINT workspace_invitations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspace_media_packages workspace_media_packages_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.media_packages(id) ON DELETE RESTRICT;


--
-- Name: workspace_media_packages workspace_media_packages_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_media_packages
    ADD CONSTRAINT workspace_media_packages_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE RESTRICT;


--
-- Name: workspace_members workspace_members_added_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_added_by_fkey FOREIGN KEY (added_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workspace_members workspace_members_client_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_client_profile_id_fkey FOREIGN KEY (client_profile_id) REFERENCES public.client_profiles(id) ON DELETE RESTRICT;


--
-- Name: workspace_members workspace_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_members workspace_members_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE RESTRICT;


--
-- Name: workspace_templates workspace_templates_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE CASCADE;


--
-- Name: workspace_templates workspace_templates_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: workspace_templates workspace_templates_source_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_templates
    ADD CONSTRAINT workspace_templates_source_workspace_id_fkey FOREIGN KEY (source_workspace_id) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: workspaces workspaces_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.agencies(id) ON DELETE RESTRICT;


--
-- Name: workspaces workspaces_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict kUhJCCOGB8xnsPrBjIhcuYmokGcT4bYn20kr0EWMcoyrue0rWJQobhhszk1uID8

