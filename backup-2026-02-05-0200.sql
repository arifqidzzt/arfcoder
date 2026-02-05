--
-- PostgreSQL database dump
--

\restrict f72R2n7acrgkD1Jnaq9FRIEWE1vAPAS7XCiBz3uuTXjuqRWrQtmdAH4dK4aF5wX

-- Dumped from database version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.11 (Ubuntu 16.11-0ubuntu0.24.04.1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: arfcoder_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO arfcoder_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: arfcoder_user
--

COMMENT ON SCHEMA public IS '';


--
-- Name: DiscountType; Type: TYPE; Schema: public; Owner: arfcoder_user
--

CREATE TYPE public."DiscountType" AS ENUM (
    'PERCENT',
    'FIXED'
);


ALTER TYPE public."DiscountType" OWNER TO arfcoder_user;

--
-- Name: OrderStatus; Type: TYPE; Schema: public; Owner: arfcoder_user
--

CREATE TYPE public."OrderStatus" AS ENUM (
    'PENDING',
    'PAID',
    'PROCESSING',
    'COMPLETED',
    'CANCELLED',
    'SHIPPED',
    'REFUND_REQUESTED',
    'REFUND_APPROVED',
    'REFUND_COMPLETED',
    'REFUND_REJECTED'
);


ALTER TYPE public."OrderStatus" OWNER TO arfcoder_user;

--
-- Name: ProductType; Type: TYPE; Schema: public; Owner: arfcoder_user
--

CREATE TYPE public."ProductType" AS ENUM (
    'BARANG',
    'JASA'
);


ALTER TYPE public."ProductType" OWNER TO arfcoder_user;

--
-- Name: Role; Type: TYPE; Schema: public; Owner: arfcoder_user
--

CREATE TYPE public."Role" AS ENUM (
    'USER',
    'ADMIN',
    'SUPER_ADMIN'
);


ALTER TYPE public."Role" OWNER TO arfcoder_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ActivityLog; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."ActivityLog" (
    id text NOT NULL,
    "userId" text NOT NULL,
    action text NOT NULL,
    details text,
    "ipAddress" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ActivityLog" OWNER TO arfcoder_user;

--
-- Name: CartItem; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."CartItem" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "productId" text NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."CartItem" OWNER TO arfcoder_user;

--
-- Name: Category; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Category" (
    id text NOT NULL,
    name text NOT NULL
);


ALTER TABLE public."Category" OWNER TO arfcoder_user;

--
-- Name: FlashSale; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."FlashSale" (
    id text NOT NULL,
    "productId" text NOT NULL,
    "discountPrice" double precision NOT NULL,
    "startTime" timestamp(3) without time zone NOT NULL,
    "endTime" timestamp(3) without time zone NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."FlashSale" OWNER TO arfcoder_user;

--
-- Name: Message; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Message" (
    id text NOT NULL,
    content text NOT NULL,
    "senderId" text NOT NULL,
    "isAdmin" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "targetUserId" text
);


ALTER TABLE public."Message" OWNER TO arfcoder_user;

--
-- Name: Order; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Order" (
    id text NOT NULL,
    "invoiceNumber" text NOT NULL,
    "userId" text NOT NULL,
    "totalAmount" double precision NOT NULL,
    status public."OrderStatus" DEFAULT 'PENDING'::public."OrderStatus" NOT NULL,
    "paymentType" text,
    "snapToken" text,
    "snapUrl" text,
    address text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deliveryInfo" text,
    "refundAccount" text,
    "refundProof" text,
    "refundReason" text,
    "discountApplied" double precision DEFAULT 0 NOT NULL,
    "voucherCode" text
);


ALTER TABLE public."Order" OWNER TO arfcoder_user;

--
-- Name: OrderItem; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."OrderItem" (
    id text NOT NULL,
    "orderId" text NOT NULL,
    "productId" text NOT NULL,
    quantity integer NOT NULL,
    price double precision NOT NULL
);


ALTER TABLE public."OrderItem" OWNER TO arfcoder_user;

--
-- Name: OrderTimeline; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."OrderTimeline" (
    id text NOT NULL,
    "orderId" text NOT NULL,
    title text NOT NULL,
    description text,
    "timestamp" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."OrderTimeline" OWNER TO arfcoder_user;

--
-- Name: Otp; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Otp" (
    id text NOT NULL,
    code text NOT NULL,
    email text NOT NULL,
    "userId" text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Otp" OWNER TO arfcoder_user;

--
-- Name: Product; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Product" (
    id text NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    price double precision NOT NULL,
    discount double precision DEFAULT 0 NOT NULL,
    stock integer DEFAULT 0 NOT NULL,
    type public."ProductType" DEFAULT 'BARANG'::public."ProductType" NOT NULL,
    images text[],
    "categoryId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Product" OWNER TO arfcoder_user;

--
-- Name: Review; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Review" (
    id text NOT NULL,
    "userId" text NOT NULL,
    "productId" text NOT NULL,
    rating integer NOT NULL,
    comment text,
    "isVisible" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Review" OWNER TO arfcoder_user;

--
-- Name: Service; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Service" (
    id text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    price text NOT NULL,
    icon text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Service" OWNER TO arfcoder_user;

--
-- Name: User; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."User" (
    id text NOT NULL,
    email text NOT NULL,
    password text,
    name text,
    role public."Role" DEFAULT 'USER'::public."Role" NOT NULL,
    "isVerified" boolean DEFAULT false NOT NULL,
    "googleId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    avatar text,
    "phoneNumber" text,
    "resetToken" text,
    "resetTokenExpiry" timestamp(3) without time zone,
    "twoFactorEnabled" boolean DEFAULT false NOT NULL,
    "twoFactorSecret" text,
    "waBotNumber" text
);


ALTER TABLE public."User" OWNER TO arfcoder_user;

--
-- Name: Voucher; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public."Voucher" (
    id text NOT NULL,
    code text NOT NULL,
    type public."DiscountType" DEFAULT 'FIXED'::public."DiscountType" NOT NULL,
    value double precision NOT NULL,
    "minPurchase" double precision DEFAULT 0 NOT NULL,
    "maxDiscount" double precision,
    "startDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "usageLimit" integer DEFAULT 0 NOT NULL,
    "usedCount" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Voucher" OWNER TO arfcoder_user;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO arfcoder_user;

--
-- Name: whatsmeow_app_state_mutation_macs; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_app_state_mutation_macs (
    jid text NOT NULL,
    name text NOT NULL,
    version bigint NOT NULL,
    index_mac bytea NOT NULL,
    value_mac bytea NOT NULL,
    CONSTRAINT whatsmeow_app_state_mutation_macs_index_mac_check CHECK ((length(index_mac) = 32)),
    CONSTRAINT whatsmeow_app_state_mutation_macs_value_mac_check CHECK ((length(value_mac) = 32))
);


ALTER TABLE public.whatsmeow_app_state_mutation_macs OWNER TO arfcoder_user;

--
-- Name: whatsmeow_app_state_sync_keys; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_app_state_sync_keys (
    jid text NOT NULL,
    key_id bytea NOT NULL,
    key_data bytea NOT NULL,
    "timestamp" bigint NOT NULL,
    fingerprint bytea NOT NULL
);


ALTER TABLE public.whatsmeow_app_state_sync_keys OWNER TO arfcoder_user;

--
-- Name: whatsmeow_app_state_version; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_app_state_version (
    jid text NOT NULL,
    name text NOT NULL,
    version bigint NOT NULL,
    hash bytea NOT NULL,
    CONSTRAINT whatsmeow_app_state_version_hash_check CHECK ((length(hash) = 128))
);


ALTER TABLE public.whatsmeow_app_state_version OWNER TO arfcoder_user;

--
-- Name: whatsmeow_chat_settings; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_chat_settings (
    our_jid text NOT NULL,
    chat_jid text NOT NULL,
    muted_until bigint DEFAULT 0 NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL
);


ALTER TABLE public.whatsmeow_chat_settings OWNER TO arfcoder_user;

--
-- Name: whatsmeow_contacts; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_contacts (
    our_jid text NOT NULL,
    their_jid text NOT NULL,
    first_name text,
    full_name text,
    push_name text,
    business_name text,
    redacted_phone text
);


ALTER TABLE public.whatsmeow_contacts OWNER TO arfcoder_user;

--
-- Name: whatsmeow_device; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_device (
    jid text NOT NULL,
    lid text,
    facebook_uuid uuid,
    registration_id bigint NOT NULL,
    noise_key bytea NOT NULL,
    identity_key bytea NOT NULL,
    signed_pre_key bytea NOT NULL,
    signed_pre_key_id integer NOT NULL,
    signed_pre_key_sig bytea NOT NULL,
    adv_key bytea NOT NULL,
    adv_details bytea NOT NULL,
    adv_account_sig bytea NOT NULL,
    adv_account_sig_key bytea NOT NULL,
    adv_device_sig bytea NOT NULL,
    platform text DEFAULT ''::text NOT NULL,
    business_name text DEFAULT ''::text NOT NULL,
    push_name text DEFAULT ''::text NOT NULL,
    lid_migration_ts bigint DEFAULT 0 NOT NULL,
    CONSTRAINT whatsmeow_device_adv_account_sig_check CHECK ((length(adv_account_sig) = 64)),
    CONSTRAINT whatsmeow_device_adv_account_sig_key_check CHECK ((length(adv_account_sig_key) = 32)),
    CONSTRAINT whatsmeow_device_adv_device_sig_check CHECK ((length(adv_device_sig) = 64)),
    CONSTRAINT whatsmeow_device_identity_key_check CHECK ((length(identity_key) = 32)),
    CONSTRAINT whatsmeow_device_noise_key_check CHECK ((length(noise_key) = 32)),
    CONSTRAINT whatsmeow_device_registration_id_check CHECK (((registration_id >= 0) AND (registration_id < '4294967296'::bigint))),
    CONSTRAINT whatsmeow_device_signed_pre_key_check CHECK ((length(signed_pre_key) = 32)),
    CONSTRAINT whatsmeow_device_signed_pre_key_id_check CHECK (((signed_pre_key_id >= 0) AND (signed_pre_key_id < 16777216))),
    CONSTRAINT whatsmeow_device_signed_pre_key_sig_check CHECK ((length(signed_pre_key_sig) = 64))
);


ALTER TABLE public.whatsmeow_device OWNER TO arfcoder_user;

--
-- Name: whatsmeow_event_buffer; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_event_buffer (
    our_jid text NOT NULL,
    ciphertext_hash bytea NOT NULL,
    plaintext bytea,
    server_timestamp bigint NOT NULL,
    insert_timestamp bigint NOT NULL,
    CONSTRAINT whatsmeow_event_buffer_ciphertext_hash_check CHECK ((length(ciphertext_hash) = 32))
);


ALTER TABLE public.whatsmeow_event_buffer OWNER TO arfcoder_user;

--
-- Name: whatsmeow_identity_keys; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_identity_keys (
    our_jid text NOT NULL,
    their_id text NOT NULL,
    identity bytea NOT NULL,
    CONSTRAINT whatsmeow_identity_keys_identity_check CHECK ((length(identity) = 32))
);


ALTER TABLE public.whatsmeow_identity_keys OWNER TO arfcoder_user;

--
-- Name: whatsmeow_lid_map; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_lid_map (
    lid text NOT NULL,
    pn text NOT NULL
);


ALTER TABLE public.whatsmeow_lid_map OWNER TO arfcoder_user;

--
-- Name: whatsmeow_message_secrets; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_message_secrets (
    our_jid text NOT NULL,
    chat_jid text NOT NULL,
    sender_jid text NOT NULL,
    message_id text NOT NULL,
    key bytea NOT NULL
);


ALTER TABLE public.whatsmeow_message_secrets OWNER TO arfcoder_user;

--
-- Name: whatsmeow_pre_keys; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_pre_keys (
    jid text NOT NULL,
    key_id integer NOT NULL,
    key bytea NOT NULL,
    uploaded boolean NOT NULL,
    CONSTRAINT whatsmeow_pre_keys_key_check CHECK ((length(key) = 32)),
    CONSTRAINT whatsmeow_pre_keys_key_id_check CHECK (((key_id >= 0) AND (key_id < 16777216)))
);


ALTER TABLE public.whatsmeow_pre_keys OWNER TO arfcoder_user;

--
-- Name: whatsmeow_privacy_tokens; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_privacy_tokens (
    our_jid text NOT NULL,
    their_jid text NOT NULL,
    token bytea NOT NULL,
    "timestamp" bigint NOT NULL
);


ALTER TABLE public.whatsmeow_privacy_tokens OWNER TO arfcoder_user;

--
-- Name: whatsmeow_sender_keys; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_sender_keys (
    our_jid text NOT NULL,
    chat_id text NOT NULL,
    sender_id text NOT NULL,
    sender_key bytea NOT NULL
);


ALTER TABLE public.whatsmeow_sender_keys OWNER TO arfcoder_user;

--
-- Name: whatsmeow_sessions; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_sessions (
    our_jid text NOT NULL,
    their_id text NOT NULL,
    session bytea
);


ALTER TABLE public.whatsmeow_sessions OWNER TO arfcoder_user;

--
-- Name: whatsmeow_version; Type: TABLE; Schema: public; Owner: arfcoder_user
--

CREATE TABLE public.whatsmeow_version (
    version integer,
    compat integer
);


ALTER TABLE public.whatsmeow_version OWNER TO arfcoder_user;

--
-- Data for Name: ActivityLog; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."ActivityLog" (id, "userId", action, details, "ipAddress", "createdAt") FROM stdin;
cml1j65oh0003pd1fi3lqa6ez	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	\N	2026-01-30 23:45:05.345
cml1x6e2m0005ceqwyubojtk8	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (email)	\N	2026-01-31 06:17:10.847
cml1xru7e0003y61iwrybot7s	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	\N	2026-01-31 06:33:51.53
cml1xsjko0005y61iae396if7	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	\N	2026-01-31 06:34:24.409
cml1y1v6e000hy61i6nnbyiye	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (whatsapp)	\N	2026-01-31 06:41:39.35
cml1yykcn0001zdzrc1tuhku0	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	\N	2026-01-31 07:07:04.966
cml1z27hn0005zdzrpavximj0	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (email)	\N	2026-01-31 07:09:54.923
cml3cccel000179id1eac52yd	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	\N	2026-02-01 06:09:29.036
3d883602b72914721b4c3454	cmkwffyhs0008t467cf2df2nu	LOGIN	Login via Google	127.0.0.1	2026-02-01 18:38:58.95
180194e9911e8d51dab94f49	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (email)	127.0.0.1	2026-02-01 18:59:17.438
c4d14f2b89095c516e60c9cc	cmkwffyhs0008t467cf2df2nu	LOGIN	Login via Google	127.0.0.1	2026-02-01 19:02:29.822
beda43bf8a38ec1e1b1f4269	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (email)	127.0.0.1	2026-02-01 19:22:23.213
9ac129efadd5d4640209c198	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	127.0.0.1	2026-02-01 21:46:24.146
09259c57fc9d1a1a24593fb3	cml0pxf1r0000g35055prf02w	LOGIN	Login via Google	127.0.0.1	2026-02-02 17:33:39.775
057b16be159506978ee418e5	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	127.0.0.1	2026-02-03 19:11:54.493
a25400ef547ff15f1952ab97	cmkwd1cmj0000lr1j5c7nuudu	LOGIN	Login via 2FA (authenticator)	127.0.0.1	2026-02-04 01:08:23.92
\.


--
-- Data for Name: CartItem; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."CartItem" (id, "userId", "productId", quantity, "createdAt", "updatedAt") FROM stdin;
497b94fe363c91caf58b81e5	cmkwd1cmj0000lr1j5c7nuudu	cmkwcwsbn000111918u4ajdq9	1	2026-02-01 20:44:50.343	2026-02-02 01:43:57.242
\.


--
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Category" (id, name) FROM stdin;
cmkwcwsbg00001191b3fsrigl	Software
\.


--
-- Data for Name: FlashSale; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."FlashSale" (id, "productId", "discountPrice", "startTime", "endTime", "isActive", "createdAt") FROM stdin;
\.


--
-- Data for Name: Message; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Message" (id, content, "senderId", "isAdmin", "createdAt", "isRead", "targetUserId") FROM stdin;
9dbdd58460d7a2479b0c513b	P	cmkwd1cmj0000lr1j5c7nuudu	t	2026-02-01 20:16:42.656	f	cmkwffyhs0008t467cf2df2nu
\.


--
-- Data for Name: Order; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Order" (id, "invoiceNumber", "userId", "totalAmount", status, "paymentType", "snapToken", "snapUrl", address, "createdAt", "updatedAt", "deliveryInfo", "refundAccount", "refundProof", "refundReason", "discountApplied", "voucherCode") FROM stdin;
cmkwfegsg0001t467g6gz8rul	INV-1769508043635-767	cmkwd1cmj0000lr1j5c7nuudu	900000	PAID	\N	24f0a832-d8a3-4a92-98bc-ec609ec3a339	https://app.sandbox.midtrans.com/snap/v4/redirection/24f0a832-d8a3-4a92-98bc-ec609ec3a339	Ambatukanmm	2026-01-27 10:00:43.648	2026-01-27 10:00:53.592	\N	\N	\N	\N	0	\N
cmkwffasz0005t467nr0nez4c	INV-1769508082532-588	cmkwd1cmj0000lr1j5c7nuudu	900000	CANCELLED	\N	0d9ff6c2-9368-40ed-baf7-e6052a0077c4	https://app.sandbox.midtrans.com/snap/v4/redirection/0d9ff6c2-9368-40ed-baf7-e6052a0077c4	Xx	2026-01-27 10:01:22.547	2026-01-29 08:59:28.964	\N	\N	\N	\N	0	\N
cmkwm4rui0001q8sxrghs4i00	INV-1769519348729-329	cmkwd1cmj0000lr1j5c7nuudu	900000	CANCELLED	\N	d8cd3fd4-c351-458c-91cd-4bc0a6e037fd	https://app.sandbox.midtrans.com/snap/v4/redirection/d8cd3fd4-c351-458c-91cd-4bc0a6e037fd	a	2026-01-27 13:09:08.73	2026-01-29 08:59:28.964	\N	\N	\N	\N	0	\N
cml2b3jpj00016lwfzv0skpi6	INV-1769863612805-338	cmkwd1cmj0000lr1j5c7nuudu	900000	CANCELLED	\N	06d65686-5dd4-4275-8ddb-ee2dc2c80e25	https://app.midtrans.com/snap/v4/redirection/06d65686-5dd4-4275-8ddb-ee2dc2c80e25	A	2026-01-31 12:46:52.806	2026-02-01 14:28:37.464	\N	\N	\N	\N	0	\N
cmkwfgfi2000at4678o6h3ozr	INV-1769508135275-475	cmkwffyhs0008t467cf2df2nu	1500000	SHIPPED	\N	76106f90-a169-47e1-8a76-1c640c166303	https://app.sandbox.midtrans.com/snap/v4/redirection/76106f90-a169-47e1-8a76-1c640c166303	X	2026-01-27 10:02:15.291	2026-02-01 20:19:21.493	a	\N	\N	\N	0	\N
0e414a5349c090262d5abb21	INV-1769945820661-520	cmkwd1cmj0000lr1j5c7nuudu	1500000	CANCELLED		f1ac7e47-b8ab-4023-839c-24690f78683d	https://app.midtrans.com/snap/v4/redirection/f1ac7e47-b8ab-4023-839c-24690f78683d	A	2026-02-01 18:37:00.662	2026-02-03 06:04:01.309					0	KODE100
cfbed194e37803cf8ecf0638	INV-1769949135863-235	cmkwd1cmj0000lr1j5c7nuudu	1499900	CANCELLED		8cb30741-b375-4d50-96dd-8a2660ea16be	https://app.midtrans.com/snap/v4/redirection/8cb30741-b375-4d50-96dd-8a2660ea16be	Q	2026-02-01 19:32:15.864	2026-02-03 06:04:01.309					100	HEMAT100
8ba4e8db43ab1b0baf4e5930	INV-1769957311755-311	cmkwd1cmj0000lr1j5c7nuudu	1500000	CANCELLED		345cf5a9-e700-4bd0-8366-2e1385fb53e0	https://app.midtrans.com/snap/v4/redirection/345cf5a9-e700-4bd0-8366-2e1385fb53e0	q	2026-02-01 21:48:31.756	2026-02-03 06:04:01.309					0	
8a44a7c89ccf6c573c30a8ad	INV-1770106896727-496	cmkwd1cmj0000lr1j5c7nuudu	1500000	PENDING		2b2711b1-4b1a-4b7c-8597-fc95c945b6d9	https://app.midtrans.com/snap/v4/redirection/2b2711b1-4b1a-4b7c-8597-fc95c945b6d9	A	2026-02-03 15:21:36.728	2026-02-03 15:21:36.852					0	
f1987dabc7dc7e4d89dc2e68	INV-1770106943321-543	cmkwd1cmj0000lr1j5c7nuudu	1500000	PENDING		23413252-eb25-421b-beae-91891894f50f	https://app.midtrans.com/snap/v4/redirection/23413252-eb25-421b-beae-91891894f50f	A	2026-02-03 15:22:23.321	2026-02-03 15:22:23.395					0	
\.


--
-- Data for Name: OrderItem; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."OrderItem" (id, "orderId", "productId", quantity, price) FROM stdin;
cmkwfegsg0003t4672dpxihrg	cmkwfegsg0001t467g6gz8rul	cmkwcwsbn00021191wcugrbpn	1	900000
cmkwffasz0007t467aiidfg3x	cmkwffasz0005t467nr0nez4c	cmkwcwsbn00021191wcugrbpn	1	900000
cmkwfgfi3000ct46746rg4kzk	cmkwfgfi2000at4678o6h3ozr	cmkwcwsbn000111918u4ajdq9	1	1500000
cmkwm4rui0003q8sxkkunj1vu	cmkwm4rui0001q8sxrghs4i00	cmkwcwsbn00021191wcugrbpn	1	900000
cml2b3jpk00036lwfllxh8xpl	cml2b3jpj00016lwfzv0skpi6	cmkwcwsbn00021191wcugrbpn	1	900000
19a25c77e7dac6e613d96a4f	0e414a5349c090262d5abb21	cmkwcwsbn000111918u4ajdq9	1	1500000
80a2ee662e1af3f979e5b797	cfbed194e37803cf8ecf0638	cmkwcwsbn000111918u4ajdq9	1	1500000
50e7e0a68603a6c1d32e452b	8ba4e8db43ab1b0baf4e5930	cmkwcwsbn000111918u4ajdq9	1	1500000
0b3e6e63264a02c4e6a3633b	8a44a7c89ccf6c573c30a8ad	cmkwcwsbn000111918u4ajdq9	1	1500000
5a56bfcf0abcb78c9f4b0a3f	f1987dabc7dc7e4d89dc2e68	cmkwcwsbn000111918u4ajdq9	1	1500000
\.


--
-- Data for Name: OrderTimeline; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."OrderTimeline" (id, "orderId", title, description, "timestamp") FROM stdin;
\.


--
-- Data for Name: Otp; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Otp" (id, code, email, "userId", "expiresAt", "createdAt") FROM stdin;
15c8d4fbffb66570fa1ff921	963747	arfzxcoder@gmail.com	cmkwd1cmj0000lr1j5c7nuudu	2026-02-01 21:50:47.517	2026-02-01 21:45:47.517
af0043119b5b10a6fb73c8c3	821344	admin@arfzxdev.com	cmkwdc5lv0000k3gkceyylgu2	2026-02-03 19:15:39.237	2026-02-03 19:10:39.237
\.


--
-- Data for Name: Product; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Product" (id, name, description, price, discount, stock, type, images, "categoryId", "createdAt", "updatedAt") FROM stdin;
cmkwcwsbn000111918u4ajdq9	ArfCoder E-Commerce Template	Template e-commerce siap pakai dengan desain minimalis.	1500000	0	99	JASA	{https://images.unsplash.com/photo-1593720213428-28a5b9e94613?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D}	cmkwcwsbg00001191b3fsrigl	2026-01-27 08:50:59.556	2026-01-27 10:02:15.327
cmkwcwsbn00021191wcugrbpn	Custom Web Development	Jasa pembuatan website kustom sesuai kebutuhan Anda.	1000000	10	995	JASA	{https://images.unsplash.com/photo-1593720213428-28a5b9e94613?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D}	cmkwcwsbg00001191b3fsrigl	2026-01-27 08:50:59.556	2026-01-31 12:46:52.836
\.


--
-- Data for Name: Review; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Review" (id, "userId", "productId", rating, comment, "isVisible", "createdAt") FROM stdin;
\.


--
-- Data for Name: Service; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Service" (id, title, description, price, icon, "createdAt", "updatedAt") FROM stdin;
web-development	Web Development	Pembuatan website profesional (Company Profile, Toko Online, Dashboard) dengan teknologi modern seperti Next.js, React, dan Tailwind CSS.	Mulai Rp 1.500.000	Globe	2026-01-27 09:47:29.733	2026-01-27 09:47:29.733
mobile-app-development	Mobile App Development	Pengembangan aplikasi mobile Android & iOS kustom yang responsif, cepat, dan memiliki pengalaman pengguna terbaik.	Mulai Rp 5.000.000	Smartphone	2026-01-27 09:47:29.74	2026-01-27 09:47:29.74
backend-system-&-api	Backend System & API	Pembangunan arsitektur server yang aman, scalable, dan terintegrasi dengan database PostgreSQL atau MySQL.	Mulai Rp 2.000.000	Database	2026-01-27 09:47:29.744	2026-01-27 09:47:29.744
whatsapp-bot-integration	WhatsApp Bot Integration	Integrasi chatbot WhatsApp otomatis untuk notifikasi OTP, customer service, atau sistem manajemen inventaris.	Mulai Rp 1.000.000	MessageSquare	2026-01-27 09:47:29.748	2026-01-27 09:47:29.748
ui/ux-design	UI/UX Design	Desain tampilan antarmuka aplikasi yang modern, elegan, dan fokus pada kemudahan penggunaan bagi pelanggan Anda.	Mulai Rp 800.000	Palette	2026-01-27 09:47:29.752	2026-01-27 09:47:29.752
seo-&-digital-marketing	SEO & Digital Marketing	Optimasi mesin pencari agar website Anda muncul di halaman pertama Google dan meningkatkan trafik pengunjung organik.	Mulai Rp 500.000	Search	2026-01-27 09:47:29.757	2026-01-27 09:47:29.757
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."User" (id, email, password, name, role, "isVerified", "googleId", "createdAt", "updatedAt", avatar, "phoneNumber", "resetToken", "resetTokenExpiry", "twoFactorEnabled", "twoFactorSecret", "waBotNumber") FROM stdin;
cmkwdc5lv0000k3gkceyylgu2	admin@arfzxdev.com	$2b$10$cOpwECrZ3LC2Bzzy8/POuucLDMWGa8kwSHvC3Ij4ibtVRsm8TAOWu	Super Admin	SUPER_ADMIN	t	\N	2026-01-27 09:02:56.611	2026-01-27 09:46:05.139	data:image/x-icon;base64,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	\N	\N	\N	f	\N	\N
cmkwffyhs0008t467cf2df2nu	arifqidzzt@gmail.com	\N	ARIFQI_ Edzzt	USER	t	103160917197960782955	2026-01-27 10:01:53.249	2026-01-27 10:01:53.249	\N	\N	\N	\N	f	\N	\N
cml0pxf1r0000g35055prf02w	antonutama05@gmail.com	\N	Anton Utama	USER	t	103879533059102878408	2026-01-30 10:06:28.72	2026-01-30 10:06:28.72	\N	\N	\N	\N	f	\N	\N
cmkwd1cmj0000lr1j5c7nuudu	arfzxcoder@gmail.com	$2b$10$fd7RzdlvOG0dB6Jq.n9siOJR/afdrcrEgHXmDmJEX3MBZeAeJGKji	ArfZX	SUPER_ADMIN	t	\N	2026-01-27 08:54:32.491	2026-02-01 21:37:58.702	data:image/png;base64,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	083127378535	\N	\N	t	FRKFKNBYLMYXGWTCOISG6PSOPNBSUPS5HZMEOOKJNNVXSZ3YJETA	151612429475900
\.


--
-- Data for Name: Voucher; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public."Voucher" (id, code, type, value, "minPurchase", "maxDiscount", "startDate", "expiresAt", "usageLimit", "usedCount", "isActive", "createdAt") FROM stdin;
cml0zkirh0000gz21fatbrh33	HEMAT100	FIXED	100	100	\N	2026-01-30 14:36:23.165	2026-02-28 00:00:00	1	1	t	2026-01-30 14:36:23.165
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
eaa3c49c-cbf3-4e38-8c70-30aa2da47077	a278c4cd9c248a88852988b8b35ffc04b43cb82f65799d3fc8d70d2bb959a73c	2026-01-27 08:50:55.153854+00	20260123160022_init	\N	\N	2026-01-27 08:50:55.097067+00	1
718c0aad-b5ed-4d50-92e0-64e60f4f9efa	3f008d6048d58a83bf011e50062896dca23c424bcb9be555fd5f079a0a9b564c	2026-01-27 08:54:00.932552+00	20260127085400_add_avatar_phone	\N	\N	2026-01-27 08:54:00.916008+00	1
\.


--
-- Data for Name: whatsmeow_app_state_mutation_macs; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_app_state_mutation_macs (jid, name, version, index_mac, value_mac) FROM stdin;
6283143886518:7@s.whatsapp.net	regular_high	17	\\xf39049aaf055a70934121baf4690302af091b045d55f6e53df4d2d2a7c07d05e	\\xe6f10378736caeb15676f3c53ed48d83b8be548b540e0249b2b2c05d948a403b
6283143886518:7@s.whatsapp.net	regular_high	17	\\x0cdd1cc74e7febeef02e0a9449dcf53729b642457527e07e1e33f834c7327b20	\\x4055f093b898354e113ffdebd4a2a76d2f9ee546b077f1443edecfefa8de1944
6283143886518:7@s.whatsapp.net	regular_low	15	\\x252ec8f2f63e6a44043e636261dd0a299abe51ffceac21cb490b9e439c29e53f	\\x521e0d209f004e2191d47390fed7f5f73955eab2f3608beba2d22e931fe16207
6283143886518:7@s.whatsapp.net	regular_high	17	\\x389fccdb6bdcd46a28d536f8f0fe672bad0dfd34d5ccaf8d3e3f5ab0ae54ad8a	\\x57fb0a979e751b4b8e2128fedfb8d0b64f6afa5e7604d751325eca01aea7c1db
6283143886518:7@s.whatsapp.net	regular_low	15	\\x3d57385d566e66dd971da457f9d5c0a6bc6bcb589a9ec23ddce12c18eb43002a	\\xf4081df7d9b62c8b1933927d5f7ca8c60fde56a28647b08e1ec20a81b4d725ee
6283143886518:7@s.whatsapp.net	regular_low	15	\\x581e961fcfae1be3bdfac6ff2d7f23b3ba84d4fdf1eba8a9d0927f0f31ce78a4	\\xf3d44bc4fc4459ed22e410d10e72fff4d524236ea696181180bd86584a2a624e
6283143886518:7@s.whatsapp.net	regular_high	17	\\x884947fa8020ba30312d585b5f0278de212fa831caba8f66d20043f46dac6d61	\\x51ef3dd942bc5b8271c77296c275bd5a6781b212be10de58c7547695240abb96
6283143886518:7@s.whatsapp.net	regular_low	15	\\x6a09309e1a16d78ee4728986908c3997b16fbdfbf1f33c9ac564c13595a0894c	\\xd411de186b73192911bbfd131db1c56a7f73b2f229fe7eeecb600c5d68c932fb
6283143886518:7@s.whatsapp.net	regular_low	15	\\x90fd9e90ad5ac592269d13c288c68cdd6500356ccc15b2d364c84a2c7546172d	\\x5108a4213409600a15f4d146344dabe91416b8a2d70a8a85099106aea3ddca6b
6283143886518:7@s.whatsapp.net	regular_low	15	\\xc78c9e735c90431fbec30c4ff1dece16a450a76f748be61f432f30557b0d4764	\\x2df690fb60f1f0d2c18254df5b1de2af172df712a79d6982ca739b29bbf3d4b6
6283143886518:7@s.whatsapp.net	regular_low	15	\\xda43eb0c2eb7d6b18a36f5399cb1285903009ea918eb0f5eb36449450c824752	\\x8298ae410351875968efbaa0ea90dd231840b8d0d40590259e948ad78978816f
6283143886518:7@s.whatsapp.net	regular_low	16	\\xc0ded82e79b63335508e03d8db94b9469da5a2efde143ed0bc5c2c22d0c459c7	\\x95188b1c52d18286dad814f8005c41a0a66a659abca16d02d42154c088e03726
6283143886518:7@s.whatsapp.net	regular_low	17	\\x4c0cd6375d8d8623d8421897feed8be8cddc99d83fcded6843452050a078aa71	\\x92fe9d8d9a0cce207de9b67d77d27a43ef635a67a20ca196546ecc8e4bbc8ab6
6283143886518:7@s.whatsapp.net	regular_low	18	\\x682c6166747669a807b6d07841fef888048bc6089577377ac6c388f86221c504	\\xc7fc218feeb8afad2b229be568750bad2d0145f3c2f3bde7ffddcadb740125e8
6283143886518:7@s.whatsapp.net	regular_low	18	\\x233664c8816a4fc10441e8a6f43fe23c055977ed755d8e35ab68e16998d2e9ca	\\x23ddf9117f4ed1d1336f1562035b382172fab4783abc7dc9ce9aae6b29fc99ae
6283143886518:7@s.whatsapp.net	regular_low	19	\\xe22deedc3802391fdde3c4e285686720fd27c8c4c75debdfe70fb58ee247cb4f	\\x2e86c991e82818de0ced863eb1dff241325d541d033d36cad85e7fdd83eeb605
6283143886518:7@s.whatsapp.net	regular_low	20	\\x6171d6d6e7083612757552013859057aea4f2a90b506c4d27a9b0191e99aee68	\\xb3d52016b0975e3fd7e1637374125b1ec89290b1b10791449e6858c1c81bb84d
6283143886518:7@s.whatsapp.net	regular_low	20	\\x98d746e3d166f2e40bb4d490498fab867355867837ca6e0c78ae3a2384108a70	\\xb846f14e63fec6a6d49064b085845e14a7f87df12b71e3d169f43d8b4b5ba09a
6283143886518:7@s.whatsapp.net	critical_block	3	\\x99aac93d2a7c5e89c1f1df4125adc4f0434fcbf54621e8a8ee01da4c2e6326c8	\\xc35fe7fd50b9e24eec8371884eba65d5224f08b932f9c1d3b77c52687eb2359e
6283143886518:7@s.whatsapp.net	critical_block	4	\\xc8f51c35027ff3917a20c93ba93d8245cddb6a7d6fb62560017c86d88f380257	\\x818ff9cfc4b1d8a6626f584176da0dfaf51140f0abd925a886bdf409ccfb91e5
6283143886518:7@s.whatsapp.net	critical_block	4	\\x972bcc858db6e5bff72e062b519686f45ec867158606e06ab3f520ffaaf075b9	\\x8561c192ecd787acdc3b252b389e2cf012a59f9e1aa91648926a7da8e6ca607e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0022b04f70532af957c281af263c452c426308eb719cc66b9f1f4144a202cfe6	\\x77c4771bbf153a109f8590cddd862c1c87ebb8810c20337622aa75620f4ee415
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0029035b92b13308adb87db4d59ebae120142d91ed48c639b5b6349b98cd611d	\\xec19ec99df812d2ffdb1848b21c463bdf0c7e5388ea47a1c7a34a98fdd798093
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x007383050974560a97579aa308fc5a29b47e576425c3cccaf0426ac43994584f	\\x9f704e40e29c4b41ec6afa2b5f0dc3dc0950b98eab2c256b77b639cb96c3f310
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x00a540b11e9470e8b997a8ea24f02d5495dc87f15b492fce772866375ad2934a	\\x3df2616f9a51efc196620a3df56e1429619198b7fdb923267b3a0a0983234aa5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0149f3e800c45643aa5dad3f1ab3f342a8cd6358f8570cd920edf5bb5a206a1e	\\x82bbd551231809c47b05a49a522bc6f8fa535c2c91de1bc44d0081e8072ec2ae
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x018936dbeb08f53fa5ee8686d4e6555f9e96b101cf72dddc062197b742973339	\\x5fcc4ea9b481491b9d0d874fe8c74c31cdd2781e48b58cd21ae70bfa60e0af79
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0196c8071be4a577b1791936c67b2543eb95ad8fb94d45aeb331d06b7072b7d7	\\x13914de522421772a195dab0b9e2c6c9931fc81de590047d567bc09e7f4f3033
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x022c64ced40074c8c6d2f0fac0186a22f9f4848770141880f92e0d2d11fa8c6a	\\xd7ba9e119584000331dfea4161769cf5dab9d2ffe1beee71ee808b5c26711a85
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x024e644d5c84392768d054076131ef775e88605d71b7ff0940235e9901ed376c	\\xf431463318ca1639423bf8ffad89cf1420f35fd5bfe44429fb176f7fedaa64d5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x02ba78658ef60b5c1ccb412b3c25dc823f38d252df66748c14f99182452bb1b9	\\x82a1b9b63310c4e0be6deab367787b8e0747fb653a84cf741294b5df6fd3d3e6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x036c798594a7c7f4ac17ea8fa9d3d98edca132de938d894abbd1c036f20ce97b	\\xdf9bd4fa1862fd211c543e220bd0c0e53f57830c82b2976de34a1691115d2550
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x036f559c3b90679a613f4f7307a31fde3af112c0f9a10aab41d2b188c67e5a53	\\x0a88e3db72876a3a0c004f1cee70e36da9c068a2c1b00ceab7d5ef015f9d8801
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x042c7685a54edf2b2a6e056a108b7543c48009ba0c0581edf856e3ea647c8426	\\xe7207d7e223125b62fbecb5233e0995077d9f66ec9cc822ec5d5f966f72ce34e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0450dee3d375f72c242a9fcd23993eb6ea21a5ec6432dc220f481a12981c790f	\\x8e7f36944b798cbe5ee7233f41ad5bdadef14983a5ca6494f04dc8816a973bd4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x047b633c31063de0f1da41f7f1485585736b8c756a748c259e99b224ab7b596b	\\xf9fa2afa466314d912a36c1c9326e6bc78f52e48078a37b10d63742b61a1cda6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x04c671aa80f0b4ea5b57dba3c734a6cee92bf27878cd616941066e1b95a88db3	\\x01a41200075761ba191dad82c6f8672a1f736dc97a1bcf4077aa8ae1bff8ed89
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x05420a6fd8bf8122402b3279468de98f9567ebd519ef7795c340b036752380ac	\\x17ed20d48f642b9d4ca5094b7cb916ca44deb919891d8381aeef570ff81c7c8b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x05777b73f0ec780679508e8f730fcd4dcb4e663525056298463c161031d2df1f	\\xee1e258193c356854852897c1b5d68900484c453d66a4dc246310d610636698c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0581bf9dccba16bd2c849467b164540343354e45e10e44cbdbd73a8c8a33921e	\\x9e838afb3090a24a48b7f644c00c6fdb8b06d506404c87c62124053472f2fd6e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x058512a5bce04284e311e4f2641d539445380f2913737c67b92c14e049eeb5fd	\\x494fb97cf9a38bf70d53139a7f939192735c3a84a429c17a581387c548d7b796
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x059dc433693e6667d500b80c13b94389bf1ca8dcadc6ee794f535f95162c351d	\\xe795a0ca0997a7969c3a27fbeab859421d696cb55bb40d887cad90f07aa07f32
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x05aa4a262269ae48090e713c57f183071c9bbec4143307e181578205c274fe14	\\x260405f686f2ea45550b9c4f4d60d463a413c7510f75623fe99f7fc55fe53f03
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x05abaf6db910f971932bf73ebf296808fd7bb8b8a90c0f13fa52adaf733b77d6	\\xb091069fb32bff2a59338b38fdb7665219508c5755def08d690cdfa696cf3e30
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x05cf77e2c6827f242bc3cc9418d853105ddbf9edcfce5d555e2822b414568b03	\\x37b9085eedb72b7cac426ba6ee7413024f12a1a3341e9b63b59cd64a49c62dbb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x05fab57f6be09612ac1a9690f784ef3fdae2c7a230bde66ccbe043e28986ab75	\\x5a5162b07a8bdcc101374549bb86a78715afdbcdcb7c5030ca8c00bf760cfc4d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x06791dce6a3d10e95d780985ad0d106048a7e9beaefd3a122370625d28a76000	\\x9f2d3765c0e99017aadfdbdaba36657a047268bbcf903eb82514860829aa980c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x06fb7ba060a429fb5bd00ce57debf3b2eac20d108fd04715d1f1524339689bd0	\\x25080d0b852b614371fd264c4d88c27ad5cc303797ed078849b6da79da674e28
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x07a1ae6bc0ff61fdcaed79327b714173388833b83f32c8210bb0adb74dd903da	\\x0ee5aa2510b6daef47d2bae5c1346f3acef8d453f0a41f3a7dd3e13498476f7a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x07cdd71806cf1378148db2c997d7cd08ad7464939ec77515c9a448b3b779f286	\\xce6bee7c6a7a43b8eb9b1360acbd6b98622213878d655051bb6c0c2a6ddb8179
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x07d28cde31d467f3c87e97f2c81fab7c40de6226e595b8fea62366736d18f04f	\\xc9563f3d40161c71a7099d1585af8d6b89e943ad16c549ec07d2ae38e10664ee
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0871511292817da170da92b187fb299557356576f4e407577219781fd3eea537	\\x55ee941917bc9a5439dece524e57e8673e649e6d3bb4801de9e7ecaf7e2aca4e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x08f6b3f6c1457bad367956acddd88011c98d31fdf31f9a50658a656bb9a5c4e1	\\xe02216d464c28f2546702b39ed5c79182e620bf04df05347625f85d015c58451
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x092cc604a92ef2dfff0d0d971f326b88951d8f17cc794745a19df9937826031f	\\x1e36933377e14477522685bd3e56157772b44b9948024c63df6601e0083aee49
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x094a76aada1a546736eb1884bc1818a442b52386a50c5bff3de6bc9faee1db8b	\\x8a45449c5067a63f140eed65bef556814c03ab3586d74ddb51c726c3bca66f69
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x09663d225d2e7ccc26efbe1bde70ce1454b217c1a48dad32a6edeae1a4ed99c2	\\x51e710224873c894416aae30d2032e128bdee88b5823a4e647f10a9da49db603
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x099b1d5ef210e96dc01aa9e67daadb34d0457938fcb98c00ceae7275515eba88	\\x37cfa545fe7587f10d01f5d1dc07c3431f7ce0c3bbde14a419346a666d0a884d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0a67fd05d40397c89a2595c1b42236ec75eb345cb26b8dbc902db37bc2b842b1	\\x18f5a14b4c2145028ecfa2b4550efd9818ff73c08a8793607d8e7fbf0cddf84a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0a86b60747f18dcfbb9e339a021a15b750e7d7c1c27a0c6036643a905a68afc5	\\x15e791d5a3152b1f80900da4ff6d07335bb14d87f4f7204fb08dca6aa44455c1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0aa2eec17ccd48bb8fdde8250e8508b9c6b40725a767f9e6e5cfd663a260fba1	\\x86aa0143598d8bbf7f08d584bee10591f38d7627b8aae3fb4d7b2f60d1795ba4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ab92c7125386847e132c8e3fa5ffa849f83469068e6d6b537660e7f1f6e5b3a	\\x620832f75b01ad92d0a0f908b6be05655a3b307d6b0101ccb4325f787a221f8b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0abff44c80388590e0d407eeef9f5a055bd1f0293de843e3d8a5040afbdc9b49	\\xc35e9ee1c9d413b311da55e441e1be770cd7cd6bf72d0746e24b13edba360fe9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ad77e32c1b6d075d49b67d779d1d88db5d66201e1eab30088fb771cde54d4f1	\\x1f1d98550bb17dc774ea498ee5a708c03ca4ed03165ac1c14a8326246b2bfd9d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0afd00b9e691b6963cdd7183c6bc1b3944a316e706cc8cea2557d8b22547dce7	\\x2c8157df07be8ff405afdc2406a145d36a1295bf23e73c1804fcf69993cca5d3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0b17ab0971258e256671440c13097fc96b83ac0d5ba013672d5bfc6f4be2965f	\\xd3b71f97781450d86ea759c9df0f2c8c20c171cdfb388cddb6b3911da7712d0c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0b4239049d091c195c68c1f7315029d88180f0450d428b4c7dd5093156894f6d	\\x9024b3764f1da9f136d66ae0f4606dd212e3ff3f2140e4ea643351b483fc0407
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0bc607ff76b726ff8c7a701a3aefb34c2d55526cc1b957df0db87a7def290bc6	\\x04edc0a309b8a2c1a0333e3e39feb7c60666c65155c6826b3724e8d45274f0f3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0c12f254035515021a4aa7d134f82ee6bd79d0cab4e38b2c0888d38902721f72	\\x1cb73f3e85441c7ea8b3de14b4e03ad60bbab731a7dd5d11a4e551902df60462
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0c424a4ffc552ec515c07df66dcca91ef3f73e83e1ecb949794a60b2bcac898f	\\xd6d07f11b027b628d5183e42bf6843061a0eb7ef29fe4f5dd013dfa6bb60ffbb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0c64af7b3c74b123e5157ecf825a018eaf85bc88b95d010b5d0a380ece0d0447	\\xfd50243807dc6721a9c9392b03e1d35482b9a4e44ca1f37f374ec1fcf0f32194
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0c9da64893e6d524535bc54d06ec139af1f84d04fa8c40e1b8c2c6ea00cf7def	\\x17d5a01bbcaf45a3488ec03f67ce152f01ec00cc4b15ea2a150e20c6fb097cf6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0d337efc9110ce85c002cbe868e98f9a2695c6ef8b57426648e23fa21e5faea5	\\xefb191e4785bb9e546f65d1fd92daed9f05da70deb56514aa95e451649c34955
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0d39eed5282eddf4f899b0a5fca4c79f6976c8bc173cfdd09a818b8452f4b993	\\xcb0d30b771c85fce4444501fba184ee3b4d8ad177924f30c7a9b1fe922447b6f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0d80469a98b42ab996807d6c4a4943d38da6d8bed7194b4c22644b30d6785d1e	\\xea99640542eb4e40c11a1cc6a16dd307fa5ecc4020a2037b02b691fd4de0f8d7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0d87412191f31ce0a26be96cb29643fa5fabaf6b1cb49d57c53f148f5ead80f0	\\x2faac1663f654c8b6cc3ee44a78cb3da8cd0a862bab5232bd911dacf6af5e4a9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0de11e6addd6628b68593b2d49897eceadc1fdd3ef6d417ba3b4548d175802d1	\\xeab8e6f306fc13766acbbecb1e11a7dffd3153505ce009896f4c100c0ce9f733
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ecf614a1105c8854727a03a06beb6b6647646544d67ff88c0a9e822c7464077	\\x0814e465226f2d17173fb01c9d62599918dc92199564c4d8f02f042feff59070
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ed0d7cdc068af7d2cc99c047a522f1aa5c954e1b59277dd2f6589dd76b1d8a4	\\xf85a00540fb35dec56ad2d541133de4ae2aec183760a6448c77af2a08ed0444b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ef13e03253e8bcb769f18d111b91bc2bb2accc36da9de795116993839ab9f91	\\xed51113220a361c8a6fe1375d06cf350a84ac2efd934bd7e2771c8143b509354
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ef778daf5814e1bd508d9a6f87c0045d857373b85f51df3513e7e563c674a8d	\\xb91116203648db2021d4658d19616f231509c31e4562500d93753fca6c401a8f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0ef94181987373f6ddffadc303fc60d04843a7a59d016fbe08e9df44f86e7ec2	\\x04b775f919556859df8b9f215f13a3f0c269be03c32a04643dbbbcce6c3d88b7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0f5fd1f1ac2e7e6539970a64dca7c6e9cf8783482a4fd8b7a506e6e6f6547c8a	\\xa7ca15e6ee5551ee113695218c84c8fa1228a5e856c94f7431abfa549f83d9f8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x0fae3a28e3002663c76f9f509fd6844aa1677fccd73bd8d783ceeef19d25cdc8	\\x84fb9d4ee60bc59c5abbf18e144fac22f3cbb18538ccba81ea48a23e37d4df58
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1052551a769e4177715c3756ce0c5c53c847832688e413a6dbbf75fe77720ece	\\x9f15ab9225317a79c5f93f692eb62f60006f7a7fd4bd5dd7af4ad82b3093f154
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x10530e7e40fb2cb9afe717e791614c79e9602ff11d3ca42f5612b12c4d8ee1f1	\\x0be79539b2ef9eb6ef1d1c32db7c75297b71caea8690e451f0f08c2f1116c02c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x107b2f6f44785fc00fb3b73e76a811fab02c7d61a6443aff4f87df750ab70014	\\x6341aab3f1ad0a5dffa8d0d2a47aab00bcf943aaf1a54f4cefa8f1ef6f0d0bdb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x10d10adce3cd86c5f9540cb631111721f04c6cb35f337b741ab7cefdc472d20a	\\xad55f58a5a994ffc066cb62139d1c946ad1782be0c9adea4f545a7d8c70acdab
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1112a7b5f9989566e14efc7f9b6ab73bf51a6f8d19efdb0f547ff1a7295398a7	\\x5b63746e46d201d2f72ef8c9deeb1b368a233b477327e08869cb617e916a9894
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1130a78afe409148bb3c648967c0fdd57d133f4a0d5b4641e6bcaa84460fd2f7	\\xb93f94dcf6e34599f859a1d4473c986a16079c2bd2b7b6a0eb68210220a45dc4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x11d1a63d7335099fb0d6b7060e9a65b07c6b65a97e3449ef2ab0247d21b3fcbb	\\x230bdf9fd146560c7e38f192c577a10ffad3d7530238119a5d27d330cc6e8e1d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x124cb35c8c973448bb44d3b4dd33657c8ed03ee19957c0d0582dfa0fd0110cff	\\x0935ab7148de0c77d7dffe97d8ef8e5b7c7e69c5f966bea6aa27c1d605351ceb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x126ee3b9b7a47ab7098ea1eb08e0df1d91dc08f44b398e2b51e91741b15f01a5	\\x52c1dc6bd2cdd331847ed36b49d8d311f2d927297b979c7f54883c2ff45495ec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x12ab28f3485b936ea6261134fd73cbfd885528155b4348712bef327ea2d47ac0	\\xbf7e73756ca35ffeedb0366d158fe510db2241b6118e26a40b9736578664940e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x131379a5dc6c400ec8b1027559c46dc6402eec91135dc44c46f8e40a13228130	\\x76dc95233b47d49333b5fde49839c3719bebae3a56f79287bc593e7e6a13838d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1325861ac2d039842aef7f12a1bbd728fbf130b290fb573e4918e57aa71729c3	\\x2d413b4aa6e350bfeb4a7f6ea0fca7b6053463611574407d12494e3925132cec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x133bbfebd6310f2a32f6636fb06d66bca3f4d932e8cd64a3a01956b3191ec15e	\\x75af9d9452e3a3056ba6daa6363446a4837fe687c4500debb52ebd415d302c48
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x13536cf44d3395342fd523d09ce7c3972f1d3933b904c8d77942688c380b3334	\\x54cc575c92bd0db029aee3b61889dfcf63657b221a196665095ba352a802ab83
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x13683a73da0f827101a6c7c6593c1d55aea8bc310d913a165cf645899d416d54	\\x7bda63e26641c680cc2a743c593abcc8f96bf2916e5cf2f76273a50f89931adf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x137e928e12a1bc7d2f2c541d37c3faa115709d1cb9f691df7d41e7eb0003b0cf	\\x87ea7a6d62e68c17618a776feff5c43b4bf2fbf86209b7318b14a09fd6f43673
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1389d3163dd594ec5858b0e36d53f52307eed7f170c1bd3489cebbf8bcfad135	\\x0d5b643617ea0f9adc482519b1cf799b6ce84e95da7507840581363ac508537b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x13b30103b02ddca5e4444b08e25038550910c22cc00b642f00d4e4af09e16b2c	\\xe47a50cfb9c47407758f63a6c8c66109b4c001b03ef39cf9e412e99104fee85e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x144574b4f21bbe8ac619e5d52752fe2b886f47c05a4dfa1be771b728b16f5c41	\\x5c72acd0b54f61d9acef559b53ce756cfaf2e5847f0ed7439324c75acefcc4f9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1488488e8aa4b978302c0f857f7d64156f589fac969857d6b665c45df6556280	\\xb05b9815caec277789a15a91970d222a1e071e4ea187ca9421df62ce0d80e3ee
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x14baf90622fb22f0e559150c639b13638e40082f6a2dadd390962492d7e4c333	\\xd1d74091a34cd895a122ba754d1c736aaf38154add05fe967de587eb19ec021d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x14c801b0ba4b85a6643832f313f3b31d16ed08d5ed50383c0885b330e870499e	\\x7dde7d5c49ebd91fac0ad4806688d69ed766060ff2a381408a0a317a67589dc0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x14ca6cff00a8dfd8a86deb6c0fb0046a70cd3dc5addbb88fb97edc81f3d966c4	\\x7ab129a62cb24e4dba361d9c268553b675369d191456d3b2af9cf08da7f42946
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x14e1574a1e247f0ce7bec901ad44002a8d28758e0ee1a4ac29a210a717c65c7a	\\xfd7d5e27cea39aa9004a6ad943ac76f2da97b9e5304e6dfd518702de8bf23154
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x14ff610503e7cec0f7464fa5e9212d516a617043c4a88fe296266a9c652159cc	\\x2bcd8bd1ebceaa9a4ed9118fe879363db7ca03d1f551dfa7591dc5f42ff6fb3b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1530adf0fef53cc830051df7c581bba22d19308b81f5dce5f0b6448f74d5bf7e	\\xf72115363f8c79b83f2898b9f33b3c9b326f4f6e64e74f9ed0182957c5227285
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x15606713fe879d53c9ca855b5bc4bec4c1ab4c909f7d775f5def0855a7b837c2	\\x57364fbdf903259c108f6c975990a4e7ebeacea2c443be16df8838483cba1c3f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1586daeaee2570b4f621c3a0e86bc43a51a887d9c281928dd31b9aef6ac5ebc0	\\xa1bfd82cf5688369cccfa4506ce9f6ce141cd18035e8811e696edf440b9896c0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x15903f2861ea3f1d67694c4fac34cf115ad1f4f04ce4191bc668d7e6f732e38e	\\xd065a3b86515e0fa06d4425630f3de6068871f8545beecd1f69c44908938ebec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x159bf97548c4463bfd6abe25f87a37980b8f1a7187f88c8d97d8bc73593e2bb9	\\xd763293e5a5ac61c290cbb9a6dabd286c925a935a907b6c0ef443620f6b1aba6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x15f1f804e66174dcd6c737549ca9db38957cf3ef507725660821d10c26d053ab	\\x8f04f06d3ca06fcbef884316a08006fcceff3335db71a84a1e4173b1ce86acb4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1925f232d3942c9016205da079f834bd0bac41575cb5f7e101ccf9ce9bbbe11f	\\xb52d94251e82c2834376cb439e8931ee35164ee0deb4b2a8cf4bdac229618f9c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x19608161f2cfc1a78dde02095fb2686b3c658ec28a6110b078c2e87c95bc2cb7	\\x6071351a6016cad5c799cf08270b551ff5eac60f7d7434f17c1a55fa80384a4e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x19a7a6d590717406fd3f02bfd995501205934eebc7996c521534606bdb5e0305	\\x980e8dba080ff80b23672169ee316bd81d2a25cd269a2fd743fdff77730ab419
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x19c7420309d38cff6c7ef6584bef4a041ec4bd7af436250864d124dc9dea159f	\\xdc94a56efb3bdc7ef31f6c16dc520b728344759e6cd7cc933a5bfa8b32730620
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x19e46dc90c1a4024f339d005ab1885593dd9e5e7054e612370a5d004158e5d85	\\x7efa857eac630aa943389d8998ef1b195443a718c00641902ae2aa99fbbf860f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x19e8a5eb43db2255bffbf1bacc0f5e0c3798d2a8b833ce9557976bfe90e8d747	\\x064a893b432d58f9e10b1cfa5e5cb798b7386b216f18e13e6094d7122e0e7216
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1a16f4533be074b9aa3d25218935acee00dbcd0877e6a6660d3c0c648458037b	\\x2b200d69b03faa46d6a44b9fcbe00d73ca09bb4bcab77a78331bb588b9bfe07a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1a74c9417aac242f6ea593f75dd02ab69b742de8112d75edf53bd58795d9175f	\\x595b9e7a34872386f8b10ca7e64513516327ec87fa0e4c3001bbdba92a1ba136
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1a86bb53a3b35adcf425cfc789b69eb2cd3c27d52c7a484fcd1d5da58da557e1	\\x9c6e313fc202dd49768b0a41eb30d37fb8ec30b7d54aa8752b9603de32f37be9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1aa05cd4a4d5639f61d7eff83fa72f58391f7b236fa21a43a550fa9e5029efbe	\\xb3ae0684c9f04f36fa86b343bc66bd7762e01ab7f2e4510b86820517194b9444
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1b217f75462058b23454052e51439e86aabbbdd3602c64668f64bacb8b79f348	\\xd9539050c669591cb6566af7a04afe71a47d448ed2c929202c53a1f7246b713e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1b3921aa0ad867e5d888a0d7cdea48a776d8fb02c974afa089bd836f90277cfc	\\x4d45fbc7121a125077072b361cc98475b063c087e6d9103e9dc730930d248987
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1b40f6c139db7946f495ec73bd9a05a7f2d422e79b06642f4be799ab4fc75f1b	\\xd5cb73868bfcbec671b83bfcbbe05ef9d5263d45ccf261f8f195dfa3d68ae16b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1b77ca484a491892b26029f3add70dd11f1637ae74b3311c89ad8f4b03b43686	\\x2cf0a693912f261e8f95dcb7489a0c7b243d54a08981b8ead450bd4a2f1d2167
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1bf24d41faa04c011bb239190b3da14a517d494cc3581228927fa257e01f2d85	\\xf25c7c291212aec0ff395a1f21932343113e6497e6de827ea0a52f801d0deae9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1c0f21572607b511076ffb9c668658bc8472175690ba0bc5253d5b1ae8811b7e	\\x9f7a15fc83099e19502187029547fe211ffcf5dc228d78b0c6c6a91340753125
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1c2dff49addae0a13bc36a2f0616dd5dc6ffcc2b69aed447af675078e912d4c0	\\xcb6509306d6aa2347c555cfc107c84a9fccc004610af317039bd635aa1c9d8be
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1c429efd5c6a3722ab2b6b1771cdddd6649965ad4539cc2d02d00e1975ad566f	\\x1f7c205c0dcb7d3ce8046acedcaacfb64c32714020b0b5adfdd871c16e1040eb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1c56439bf7bc60e83ea8981743e11eab0dadbddcf5cf7231adb2bf2ec4adcb8a	\\x3fc4f3b78a55ce671ff059bfefb31053a54c31b8554893b6acde853cac7b3ae0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1cdd1d7e2ca4f0fe25f1316792d86f4596c72bfdf27d6b45912592e3a2956ab6	\\x9c18198761b34d629088e3c8b969702a090b258af75f9dded5553298fafbfd7e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1ceafc5cf3d907ca04db34dcce45115c9d002400dfcdb7c49bb523a3016127da	\\x35576bda2a127700cd3f0250950c134b18c4c0f34f635ede15dfad2cdf12c4f1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1d40f35863f5cc028d632752d040550e1374f36bc0deb1f0b2c315fd8f19b7d8	\\x234e0358f98624d1d5e8785cd24d48b7de4f025d24f2a9f4cd909e1948e959f4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1d8c4549f6b9765eb0d751114ef5419ed0ab0304e7a0b46eb61b520749c2a24e	\\x9ed99f60ca1aafac545f174488779d5b79da3e6e66f0ff40110d3fb6cf50f45d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1db2b3ea9c6ccebd405caa866469923742613dd3f5db9e18910f1961090f3ca9	\\xbc44bdadefd92dca78ff9474507b5783ae5a26f11f64ee35457acd20f83065a1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1db49d6ff492137f94afc5a44e3e13aeee8c9c5a73f710c6a32a70d80e91ffa2	\\x0a6cd38dc9d28e81c4b90de2f71b982369562740c05702c4c884deb464633114
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1dedd70806683cbee200e7a0d86be499a741184a5004a40cb76bc8f1d4ad8110	\\x4c4f8746d8f974b9b3a6931a1471f776059645e7d755d0e8152f822aa65e903c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1df9649be9b77e747eebd99ed619eead2c6eacc07ca9532c2a8432fea2c58ab1	\\x68feac9741c0a251b24567142f6967dc9da1aa95a730b2ccf7adac1976fec34e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1e2987f2e87b948f81cd736ea5a486970d8f8682eb73d2de67d48355c6d68a1b	\\x0ab11aa20968132b9869f1c00b805d1a4f0188d4079a2bfc3f72f6d874159ab4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1e58a1983ce91c00364955ea29f0e70289eed04f1d3d771a5b3c4811d0d62b49	\\x9389993cd2da160e2c5227ba09e8bfe73012f021c27f5a6343dc862abe8958da
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1e8e1616e705a482ba482983ea5f50d7e0dafc77053254d8b05076fb0d0411a2	\\x9c25154854283525f14d8dd68916b73da359132f4d8cd59c21bec025786c42ef
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1ee22b2f962cb5fa785cff57d046e5ed28981d482d3686760c791320dd716adb	\\x717216c20a6d8110b5232d5fd148b145a9eae95fcef739b8215c12d7352147b3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1efd0206d0c133810245a14df24a3c0a9c9ff2e4a8fca9b641a0160e6b6bbca1	\\x2e9924ce447b3bed68f536e8e957010d3d95e4d5bc156e7d6877e9aef2db4d1a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1f38f4786f86f4d40b55511c4824d1717976deb5eb2d82779498b7a5dd0a75de	\\xc360ca53affd1ae9e5093140b8a11a903d2c63876049bc6c9be79306001ddac3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1f4e1421534304008630551003a327c836f75651c9e405724ac70f7f6faca3f6	\\x4615407e2bb5a59d7d43a305c3665a5a705c1a6457a42f8f25e9e54a564ebe98
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x1fc715cb538a9c08f7dc221ecfc9621528500ec6aa4b79898eaaa0f5c8de84b4	\\xfc9487a68b087f722a344522d1e86a43b82ca6126b8cc9c9aeb5fa66a675924a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2022ae36ca79d27ddb70d49cd7fb96a6f9066716b5da66596d40355b1ce6b29f	\\x5348596edfa24efdab17d92d917dd463fe23d236ff18893ab90ad0520d77bb3d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2034f4bf3fca79aac53f6f4aaa6563ceed7855fb50509e6d6a781ef71a2a1c2d	\\xe30dd7653fd6df129631b55d2920f68698bd1b1e1ecdc056fb86522c5c6b57ed
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x204cec8662fabf705194b3157da6675d215dc2099a3122570c7f9489fe5d9af1	\\xa2130b0464f35b6303e2859e46716ffd3b9595b6e6a64db1135b34da4f32a2e0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x20a1aa95b8ec6d57ae2acee94465fdbe6da4e7cd9af6c9b8e493860b6525b3df	\\xa77ae0759bfc49faa70a5934913f78184e2e806dd34ec1c185d97938246ca6d0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x20a6bb3c5639a2d0cad682bc485877f82d8f554c0a1e58b8ab0d275b572ac131	\\x6275e7fff65c9c13885d247aaf7816a8c80caaf258aca9e724ab34852f3e5c4c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2136848f549cc72f4128e51f122dcbe0d283476852744579a7c0e440336b83ae	\\x2f5332d1ffc786c8026c8168701748a1a06520deb6203e8b4f381f2a155b3616
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x214d0faae7af89405c08945dd28c810a813afe97f39c491dd4836ad2785ab0ba	\\xe0530b1edaf5c161bb563d4a48aa3d98c6abd3233ae6d72b3ba575bdd3536bd3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x214ef6e9b487464c815aed81f82de3132e5f1f419bcdf9ceece4ce770afa49ba	\\xc05516ca36b949ef83d22087e9dd13c6d1fc7405f75727b68556cf97c730597a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2160170cd950e32416f700bd94c358dd4870bbed4f349202d05aa774f7aa76e9	\\x523472c29b2c625f9c734128226f8e6dc7cfa38e3d9bf59642b6a47775b1f714
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x21702a966b6b63e9b01240987dfccfa421b43319401c5dac661869700d11afe8	\\x442bcdd02cd5248807a5426a080a45d5e7314bf610f4186df2686be03b90760c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x21a3ef0cb8983e2f06bcea20d06b730b7626d806e56ea73974a08b21293fe390	\\x5a2ca0ea1396683a17e908ce59638fb980a14be54450c7618620a95cd3ec6fae
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x21c3a4440f8b3adc055a4d128ecc48b17a5c0b4bdf66d2c61b040bcbb3ae1a10	\\xf2206dad97c2e9290d5ece02758b519c8ef584ee8c4403d788e6595a1e49560b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x223fc8a80e161c11716c6eafa742fc0be8b9c712aab7f5d0ff779628e19b0d3d	\\x46a1977a1fef8458418799c329a34c7f77a9c176882d00c915ffbcb514c71d1a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x22434489c0f8af4d88ed8478a89487486dc9c2669d4184b749a54acb203e0d0f	\\xc90f3f73823063166b7c4b756917ebfc365632cd290d8b2763622d2dc584c5d6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2247f90e23247d45738cd0e85957fe06173d05283ae561540a3a5e83873cf2d0	\\x7ee51bd83994638d6f328637d93cfe62e80f5530053c816cea7a7000db590d2b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x226a241bdbffd7c11c9481fc474d0ee64aaf7376865861b47c788f5907baed9f	\\x6659e85f8cd950ea694d21286d43980dc034dac63a521e407d4daf8db98858f1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x22a4fec9acc4d149fd8e1f87d0a11312a3aa830d075479d7fd9aeb300f259240	\\x9e84c43443e3be7da428b92e4b35a827e1c5a21c90940b74268692f12583bb9b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x22f7f96bdc3d948e96bc905779e18ad5ac58aaec1d69bdccfadafb72f76a5fc4	\\x5f0197783552daf1197034e0a0f6b11fea04cc91f45f63aa0ecfc0a3bdfd31c8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2324deb8db309b855d5ee1b08030273511816efa7817404303ac3bddb11f11d9	\\xfa5a7c7dbb934a4a6778b1b8e6f8f6a9d48cf46db0e3ddc14bc045fd7b88b78a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x234f7ce45252ef07fa1de8637a0e4977d1df537f8154df291a867e339749ed8e	\\x8141fd531b2b6e625cbf0d0fae598cdf8b5c4c7157f518188022330655816dec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x23660124efc45d208bfece2648fbee8166fff22730c0393e3c9abc01df71e90e	\\xcd92f7a470198de99f7b659f19ba1ea49fe1a51c7bf0cd5129e4da1bc6369de4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x23c04172e05571a987c830874b4685a14d496c43e2f14c5bf7032c27ec910c84	\\x5e04a333c06ae38c9c42db2f26dc2ff60cad85fd46f1e285359de5735752b25b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2438bfbedb1acef4f6bedd86d8c68c312119fac16a4baf49eaa49bc9b85f8457	\\x83ed117323cd0c4477aac6bbb20bf269abe0c9c6b6d4d3f15d531e241b44d632
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2470034a571f7deefd18705cbf74d8e6fc118e423bca2ae1c2273382e5f10523	\\x4976a96db67b5d67ac43eb56bf97723ea9182940ffc0f38079864dcff8d17a2f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x24dbf1a2f10c2f0714cbbe3b44aea6b3c2252e13796ca4d0e7cb023ae490f9f7	\\x25b41fb35edaf640d805290c3bd4912d690b2084975556f2bc457b7efa7a5388
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x24ec45f927211fe78b7cce6f38d2088e8d939c9eaacfaf54fb9cee293f55b6b7	\\x6234e38184e1a1913f0d3eccdf84c333c7e55da774fa4e0aacff3c16640ec290
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x25145ec05c5a45d439ba3aa84cb3c222222619a2bf44585bd7f8bf007c92ebe1	\\xbe4500d28bf02ff0d7ed8fbe00652fa4c08386b5de8a14e5594481cc56bc311d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2557a3b64327de93b068b22c7523c4b2d05f79cf90c6cfa87e7cdcfbdda0b6c5	\\x77f3abf787735ea4dc5f4d073e2c922cdd0088ccbab2bd4c160d3acfdc33a801
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x25915284c5eb032303cc6c8d1cb93c0d52c3a9b8b7eaa2b150f46510a99abc84	\\x91900949603e608db1cd1f464cbf829cf4f53aa48ecc0524b7c5819733608171
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x25b57c9a5428f1b1ace322d3168c750bc94fa9d17868c684b0e61450563a62d8	\\x486f35f949bb0dde7a6c33a083d3c04461f106ed12e8dd0d1d1b00f7175f9f50
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x25ca7c437be7ab4ac5cb5708100f7b485caab5bdf116d834f8b0669b77dbad98	\\xda114af647690c22a7e0fb49d7327b01690b701b0dd9b2e696f1a42e98abbdc3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x261ebaf172e1965c811a33e4008a7efed5bd1ec78bb2c5e974d8d98ad7cd3f44	\\xae54776ae8c632cc0633ea63f80c959ae34384c425016859e4616ac0872ecf0d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2643fa18b852682828db25c2ba44d33d144528029fc69f4930cee5171628c589	\\x0be5ff76ac63ca1a3339296671b58985106bddecb4513389d7caba94821ff86d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2655d1be7d9cbba9deb0084d11e55379d9e6ff4c4a94f0ac7f3786c912ce67f7	\\x66bc0e981ff3a7e6b79c17c796d552e307fdbee614250e6211d24beb93b767e6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x27534daa6baabe51d3ceafe5f78b3cf3757fbdfd5543b6424c4b0cfc60a45699	\\xb3e6264b8526a7bc2c9b9b1c50300b8b916de1fd3df1ba11eaceb981293165e1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x279500a8afdbe492adf0335e50a43dee77b62f269bb2ec9056ede75db6d1c274	\\x247cd0dc9bdba350f503be65697991611e1eb55ae310fd0ab6ba04d084a152e2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x279f30a52d72f29344be8b8b30640ef9c9313bdaa86b7de98abbcbfe830b56df	\\x97b887414713063402c9f99c6a2b953e728a7ff0082b30192bd0b1240f9e62ef
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x27a8e65f436845c95ffe187d92ff9e02eb6da3f36fbee05e26da77fdebc64a21	\\x63c913e4418ded250cf911133db10ed1e78d8892b617ee30c2c39accc2e17b4c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x28378dd76018249802e45bb86b08caefb3b6d05f1b1293fbf75ee4de99b12f94	\\xc97576d8b97e16bcb6344e553c400b6d81be469bbc373d579d875743fbc0b50f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2884c266f9dbcba8becebc4a6ae12281815b7c9bd79c19111cb74c221dd51bb7	\\xccdf21a654b318b507c664297316902cc702608e1a26aba9a671511c57033ee5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x28b331f0599b675754bbf4aa22886ab27e8384ceeac96b7254671bd359b482ac	\\xe8a84f8957433d32d85ab6f75649d33eb43d4af87130e1b5a6fcfcb2988d1bdf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x28b76a40bfc3d95fa85bec8d5660d594e943523215bd52c959ddf7c03a6004f1	\\x978836692016d27ca59a150140c8c9ae2057d45f1cb6ac2425985099ca5ee88b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x28e68080ecd39a800f1969fd866a498dba9382b403c5209cd13f9416e67e8f4d	\\x82a70a20dde8c44cdd9b0631e3cc067aa89c71b21d10ce71e3cd3c49eeb0cd06
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x28fa5a1d23e488ae8f30a2f3e5f2cd0fbd2fd6420b7b5908f9067a1a519a91eb	\\xcf98f4a5f514e26f915ffca1aa776ae62c0ffbf4c8ae777c86e443463ee698c3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x290866ef471604d92dfeb7e3d5ff525ab98a42eec3d184d819be1bb1462ad68f	\\xadd0001d92212f710a0fe782b7a6af19177f5486484f852a37d73e3d4d925064
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2925077045d471af01529ad30b49dcbbff9a8ae2a28aec69d12c3a5a1b6e4992	\\x852198a76aeea95f1847fe9dfc4e95caf108b69224ad0bafb2d0fd3115b80ba2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x29509c5d39dec6072d7378f4b5047b5c53cddacbed01e96d872525e5a64dfb94	\\xb61f6562f7ca46610cce14642acdaf0d9c62f467f4558d9e26cda32e8f1ce2d4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x295ce9202c64cedcea05ad894e8cd4eaf1525a44b1606a6ae057911136bd6102	\\xd80db623495ea1d2f4183d97154b3931d63e6fcabedba81dd37a66fbb2b062e7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2987d01bca3fb34cc6639188c24bc938588eb7baf16fdf6d6d81354f3a187dc9	\\x9466888ff2db95c10ee03af51c38d3b087983d63b1500614bc7cf09c7f5e4e6f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x29b76cee0733e36c9e3854591354d11b676106a40c1f09cca19aae62388f5e35	\\x05f5a2c778af081024b55ee33f3b3f63140a83a7f4db2931613a61c103acc010
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2a7cfa8cf84743c3b41f26ddc1fd37eca1429eea24a2a71ce800f93b926df1b2	\\xb993ae1af9f67415e1dd4d21edb0260bd2237576839061d152e5f39816cfe268
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2abd0e4884998a3930a60fb853ff81be7e8b3602468feee2de9ca64def39565a	\\xc9abb2aa8781a69a886a23483fed4f069b848347c93ecf8d650bc316c80bd293
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2ad14c711c20ac526e1c08bb366fbe2e3c3477510b71b6a107ed089faff3dc9b	\\xa9615a512a6afae932197daaf314c700e3beb66c789a8c63a1c7a3aab13fc24a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2afc165720d428763416ef3ec6c3b38338197634fa57f153f8d49a3fbe69b689	\\xda9297b50c33b26de41f88d44f5d56f25cac69e32befc5df4c2a0e7abab589e8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2b0bfd3a9266262b6f1cdd8eae69cfe7e1cedca9c10067831abe3f90ca09c53e	\\x2128b8ce99fc9097cc8d27b43ec53e968ce1d2a2847eea9a634479ddfe82a9b1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2b1d3ff877f83a83be1becdb16f05d53ea9d5b557b5ae4e24f5050833bd04568	\\x607cca86a0eb55df53035ad3fc859225169ac1465a13d03d6ffebf8cb78fdbd4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2b504eea67f0dcdd45b90104b0b2afc082c9649e5b3cb9ce2c2765c5b78bd099	\\xce157269f5c0e854bc0ec052a34942bb1909800c7c17b073f52c9d8755df2a3f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2babb24f0b13f510f8e262ac15b1278b1c18b1bedc65d03f274b9b2363224733	\\x2c1fa1cbb76f854215308d44758c79aa53f430b945749c45f53132d39172be5a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2bcb69facda46755e84a126608a23158fe936cf78cba18900537ab50bde89373	\\xd7b307126f1e5d763937bfbebcdcf8821cc165e43c264019cf387b2ec9599330
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2c372f4ca67237b8f579b1880521220b57912fbabe7f468b0b8f82791a8dde47	\\xc566a7f29c55359e513ba4769197b63e4d89fc0627edf0389cc76c3a99830395
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2c6044e1251019c3fb73ce5bf8a5d2c6b70bf45dfd3e70d654741195d0e51feb	\\xea7605e3393f0596793513d3764f18344d0271d63d05f49f14df625ba0fe4eec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2c61a0e323075f8c4775ecddd46e2057bf85bd8eff5c7dd44a24159c965f7bc4	\\x5f195d71926ce3f58b5d1b8de352e718ed6876e38cfb49b1cbe908505f539f00
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2c6f725a492e60fe2fffcff3c333662f185d13540d844153a2635f2c37b14d62	\\x10c05b15e80077614c5eb5f83b3665c805ac98135a779c36a6459475be1e6d5f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2cba1207d8074d85a4eaf922fe884a14039450b3d43aa7d3dad4c84f07e4ea39	\\x64856f91960020945b71779c748f5f68419ba31f454d2b838e15822e37572fa2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2d2918d20c6a6bd0f5bc58af7c586fbdc7e3160347e6ae0e2c8954f105f54fc9	\\x50cd8b7da829ea7bf84a7cbc1780793821cd5572143d03875923c5e51f34aba9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2d63de40106e0ac7efb96bbdbc703c70f8958930296c2f8b38e622be8e49a906	\\xec755b747ad834b7d601e99c998517be7347e7ac81f8bc4445f5a3aa71ced570
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2d6f3fbdfca1b68e69ba6d754b1f30629df8f3c67ba434dee3a6b3b282f35e46	\\x69e9cdd3739c1d92c5e4a05d8aaf7eed0366791dbf67d7b0eaf07c4d89108b23
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2d8b9f9a5b68ed06784229e9a620f2c078479f29ab707a2458df99fa589793d1	\\xe65129176940ba0329baff60d669dd1289b1d2fa7f71d131d28d66559992d206
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2d9cfc4d2be55b74a964ebcc8134f2b2acd4ea84cc7fe1429fa07b78eef494d0	\\x104e4e34de0496b8b912ce5f448ac239ba91822fbb6c49eb082096b86bdafc4e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2de5e371d155188099c2d32ade1862b53c21cd5ceb3ef886c6724fe6d03ce81c	\\x324251a6595559fa4b2dcf5ce3961755d738cbdbd536fa5985c95e159e59e589
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2df1ab73f6cf300c7d0e3baaa4f0046a3c2701b5aa3565d94c1d3d4f78b41574	\\x72b648ae932bd2da8ad053b3c30ee0467805a2610f9eedbf63800fe2ed95ef9e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2e28d75d6823aa6501bd7815abe3c695d72f25b4b2eb9cc2ec1cb12e0d9e2e46	\\x08fe7204846c11a0b9e199867b34a1be6ce795bb5ca916092d2f4f34fc8d71e7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2e59f61bb18ebd7106aa9d5ffc7e483f1a6d68310416a21133943ab68ca0e5dd	\\xda372c464b0cec5f67f6ff576936c8e0dff2701545057347eb84acadf380c6c6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2ec392767db530b7e76e560197a7c3f289a8fc354f9bfb6aedeb58335a6524b9	\\xbbaefa29bc19caf0edd6eb5a6195a5838aa4859495e80710c275197b38930c26
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2ee69e855b3adf07c8f0b61fa5489474ace302da5df920fbb2e3c8a0b5171aa3	\\xcc486757900779cc0f7e4283c9d05323eb5b2745811ce387a781217cf2e8ba1c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2f10cfb2ce9dbc46e68f8450d35384dd0646f2239783add28972336ebc5cb967	\\x35dcc42596add8a1aa23ef447a33fdac09cd6eaf0155a501ef9dbdd041c03276
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2f4b653ec002058906fec553a7be969f69768a70cc0d20600945d88f3b23a490	\\xdbf3e2335b4d6f99ee3f835897e5acd588751e0b1f59e961e49a3947b65ff695
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2f695f77af2537ac28bf9949048a413f18220ca50ca3a7fb5c2f8c70f60a25fb	\\xf93081a22b8e6152b4d1976bcf5499135e9b4e0b3ad09c49124ff05d840558c0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2f9de5281941c7bfd6f842f13e8f99e30874f79320ef05b4f2e5eb3f24f48081	\\x93b555020b37138ca47e66c10c1046750c19f7517dc0a31b5f72610b50a051de
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2f9f65d542d19c9d32d05d7c338eced46ecc61f29639ff2f4763c8eff5d9f013	\\x22f1766822921604d81a976d42c6a57453a440427bbfe3ff1a065618c689f70f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x2fd9b957e878dfa0aedea338d48910eb5f84b275e30435249758aaf2789052d7	\\x9f419e907e6ae194428080c60d99230619cee639df9c469142329047cf023fa4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x30120c2f1c0fe6da43b289b334e2fd6a4f49171f39687c6a3cc0401e7fd18e2a	\\xf61fbfb448aa69400ad7ebb48fdfbdefba920c258063f4a7b2a3717864cdd3f1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x30a9b937a983648d4ea724ae37c8c28575b1c1f997f77a8aaef3362c6828997c	\\xe55830c19b98da3cc8d1211fb6107425f3bb63d88a0dbfa89b435345be6127f3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x317ed1a3808eb3525616d1863e8da2ac0b451fffa7d8cd5f1a832fef281e6fa4	\\xab21603e79af9d968d89817e6f79e3f7130bc11f914bbbb38918908e98e8aefb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x31900eb3fd38879b5ac43d441013862ec8e393be7e2eeaa3df47edf5f0d9e237	\\x347d6ba9ef23c3c2775bd1e69cfbea77f9b9bd00f9475be42a0a60feeb05c5be
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x320b65520580c518e3dc86001e471d1d46c4ad9d9df1d7bfaa9855a461f94db8	\\x9873147344c8b0a8cf2811016e48c82d74381d2f40ea3576734d6d92095e44a7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x321afe77a6ad0b9dc37a6038f7b720b3b3f98477e00a3a97ed2aa1a6198b1e5b	\\x82d09084c3022735439e9badf401c285453054ba10ed73a8687432c59eda2e9a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x32435dd00a335dfb3e1d814bbde6d1855be1d0b6250f59a4677ab2646ae4001c	\\x92f80208ed4cf648c9de706bb3af7c901d6c8362add4b1e41793285fac3d3f14
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3244cb78757f224ba1ffe1664fbde311ed801a72a3ce467a2086ac8ae57c55d7	\\xf4e1f65ee637079f59f21265d75211a3e6ff3d93201385a9bc4c435ca8cb67dd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x32e90387a35eacba5bdcfbdbcc1580f6034423c7ae0c53bf3255d3e34a996f98	\\x1dab04fad646e44b9e34a3ebfad3c2ea729002242666a13d9583a88cc35b775e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x337b1f7cfcad9f6ec9d3022baec80a2ae69021729459159b57c1b2406c9f2347	\\x9a758e875f59211c53da03910454bc8bc7f9860f99b20e5d2b4d369d05a4a94b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3393995cca9614a56fc50cef536e6f3bc9c6e08c8394466b19b5f2b4751517db	\\x6560c78b06942d770c188c95d377dbf08c64259b75485c8f2479a22c8417dece
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x33b253b593a0495d73522c38c24a155f2ba725248a44c9c86e97b3612931cb91	\\x68a03dcd23f5a6738ba930d2e0e32dde8b81ced0845a988a07118e64a127c1af
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x33caf8afd9c38a431656f990a7e23fe3ca2a4f558d89f48c044d5bdc85153ba3	\\xa030ca25cd831bcd9ec3e461e4630bc4153b09122e6edef2803723d90298e85f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x33dd18d4708ead6fa0bb0ad6c165b0a36a93e704d37c247a2c2f96cc1aeb4190	\\x5c904dc35a76f70510b99028c13cb77ec3ce1c9a498d6798b2f88165ff3af3b9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x341956ef27fcda239077df87bb122fd308c3405a2a52390729a9dd40ebd3b89b	\\x3bccd980b4afe3690ee7875feb17bd91ceec440a8ca1343050ae1c6f74472953
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x345ee66aabd42acce6db309511a14649484e8a78dbde6f1d1faae626106345cd	\\x60c65e7f80c0cd775b425572c8e113d6d3142422e0d5df0ccc487dd37a5220fe
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x347519416678ad852fe99e7ecf70f7e62bc456ae7f4f3a6fcf8155d10579bd97	\\x8733c07895433b329d8b76ea462bd5dfd1bd4964264344d333b225f96e569593
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x34980088a05b4c54fe7696ff485920e8a6d522cd391b2b20c84e8754582008a8	\\x60459639059183035b896ebafc84c338aa4ad3450cddf5465558b40bd65eddfe
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x34d7d43a24d8d1a5aebe0a6f585a043b926b608e089ea353ebcf0e2f765f80bc	\\x0dbe7961f3d0347870b7b5eae8add6a8ca192770de21c1633983f0b5efd98760
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x34f0d9bd7b45f01194188ef477a2df5fd33cdb5554e56dd829efad08a91e475f	\\xd58e726830ba33a7439204d547e059e99ba991b487834b4c684690ba768f8802
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x352996c47367a54036372a686b4a3ab56c38d184a986e7113b654f5c677751cf	\\xed058a99df3007ce7d34235208b6f00c5cbba1c0622f8d4933acf28f914b4508
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x35606c520362be0e8e251de845007171eafe98579c15a9dc725a7f3e30c07207	\\x7ad1b264f35eed2c524f678c153e5de1025e8ee2920790c9682eb2db1fb22e5c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3598653c32b43fd0ef7dd943c177bda7d052b2065cd9ce3da985caeb42fbd0ac	\\xdec8e9867835f568ae8b6ae43ec6a1365175de5c8b89c16945efc67b081c0489
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x35f8bf2232d9b3e738b605f3c0693b95a0d7d072d682a7e657d3d3da8d8ee895	\\x6eb57409e01bbc1780942fe3cf347266a02bfdb437e1f0a88acade0bba3019b0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x361c4964b48a84e4dd34665dae252312e4fcebaa40c21bbfb9deae11d4e34303	\\x5efc1b3e5e3cbf1d3b2e691e7fa5427eb3e16c76a38698e201247421504ffa0e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x36cbcaa85591fa2adcead63ca010fd9fa8903a3962cc08e025b563118fec6c33	\\x53e8cbdd227a5c258304941b43fd4a684abfc4d99f0bbde24a69bf35ad9a9876
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3758f29c2fcc3c9c5815548f2baf2abbd8a2e3e409e7d61c79d9ddca8a31cb4e	\\x73a2b9018e962d909040438130c0f0af4fb2020090980077ab7b1eed367a3a64
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x375b88ec8fb5c9d30e22ff2abe09abd52667c27afaf121a68f72e2794f595da4	\\x4c57d6c6011ff6a1e5526c2f32d2254401acb4084ca78380e430bd9a49c0944f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3774f61ad719a99e185d10f5b9da0aa604a0b42e95d0f915f64c0696b441228a	\\xd4ea9cc29458d6fd40dd72da5955fb428f1172f9604643caef6f11f16dbb5b28
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x378c2b0e067ebf251e9a78f40a973d8667197db4a24a926ea1a2ba964a27768d	\\x1d52fa0ea4c6bcd24931e58d1f40235331048dc042e6087be5c16b529b45fe18
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3790c6b4fb6ce41eca54b1dddbf6bce2bf5356519a8c33eb66fb6d205b46ef8a	\\xfecaa8605a5d207f38a4480c48bf7138c360dc0e58ebc0081688e423c077b7ed
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x37971b6dc685c2caed0e288db42dedf7aef89cb346084bd8ec43429bf3607efe	\\x9d52e866124052d2b93e720917b4372d98a06f304aac45f249d81c6e42344461
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x379b7a876bac078df7fb7c2700f8ae18dd1d041d0f9be883305bd460b6d21341	\\xc84b99e31589d2e0a264807aafb36f50e31f189b2621fd257c528590a7d807b0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x379f02a7e5bfd2df1ac0534fb7e1506e2be533ff8f07b082ff5dea504f896f5f	\\xacec2ddee295c391f3cf196175ac67b9bf7caebca0a1c3f64be3c63f70190395
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x37c855e8aeb573f7a9fe9b07cc77adb5660dde21d7d023bb7e52525e989a3f2e	\\xdea42ec535a8538e6eb6f36080baa4f900940e1c2202705b1101904066ec0004
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x380a6bbb69847a524b7e67bfc7f32081fed1bdfdebd75f5e4c4904e197beae08	\\xb734ee4859ba5b31e5d5ca11337f22a417d6f8db818300e1800dce02a9802a61
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x38470c58df9f1cf23a59bf4c108f05d184f1fa75156819b70fce1659193ba081	\\xaf93277328bd427bb6bd5a956594f22988dc8839af0a81463573fea3ed33c1ad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3865bf0f56bbb89bce2ee72fc18054fa2409b74add2a2ad0d6d8e2fd81fb52db	\\xb02731066d6497e82fd25fb36f067d2f1d22d7ad576bab2afce6cf2dc4d76239
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3868357d4e17638f1a61d360c084db756683864afdb89a5d59ac7d6ddcc56a96	\\xa6ae18524f9138cd4ea464a39b2cd725b70d8212958af21e5f2e633261b3d656
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x38a567dd8556bfc3a70c6644fa073fdd14a4fa3acca55f7c458c7856e02a68c6	\\xcfe0d8a41ad81b4106df400bce8e9fa9bdf155ef75b856e37106f187f1bf8af7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x38f81587924a3f573f5c8d11ae6d0a11f8177163a3a68711e220f6f9e01c30e0	\\x1dc96988811848bcfa379a5f25d4faaa4a5cbd522ad2424fc983c1fedcc97092
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x39014f0034acd1bbc986afaee2b41650eb9eb15c6225721f13b938633a2dcc55	\\x8b4a0e986dfa74163f66f2784ef5478d41b104278952910768bdba2f5c3e91fa
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x39492bdc3f8275a3b19ddfd8573b5e71e7283395064333cbca2399d0a37ed748	\\x6c6aa629fbc261ccf8a502c2c471cf8efe57a112b048bca883e235597dc9fa5c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x396fe39042c6957bbbb475c226573ed5b90d3017bfbbfe3bdf2f06e42aef3a71	\\x30271c88bbb6847da0e2cb40e63d66400579903fda19dba41bec96dd8ff88996
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x39d97807b156794992232dde78a36a368236c865cb613f68dac392b535bbcd15	\\x01e2e1e9a28b01f947ce3f354a165e4ba49789f3bd3948d893446f8ccaf88b2d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x39dcdda157fcae15abdce4732745001f9711bd5b131115e136070c9316c98393	\\xb3149f7d17cd0cdf24acda28584b0fa22364682e2fdca9ff76666c6089e87b2a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3a69af2f5c4201dd85de6a83d34bb7a108a08a2f50a381adb85962d845a2fef0	\\x5098b3dbb2c34ff27197aabc303d5708ceb5d24783b69e6e1398c1d1f7c0067c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3aaecc04572323229e6f90d789a5d837e42d5770acd0b8d13c29185b3ec04117	\\xbb45e0146d69d65202fc5807a4ec86a5815b23acefc29c4a10b68585d243f726
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3ad85c97710e4c661977cb55aff88855a4565aad9c1841ad4d1be5cb2cffe6be	\\xe55c35dbc283bc401dec831f56c238947f6bd7d118a4edfa668778272e6eb4e1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3aed9e651e82f247562f6bbf5a6727f808c43fcf4a8bcd28e9dfc9a606272744	\\xb6674d7c4c70f2168e4e17358838b473a12568be9cfe44ef106f86f516f52809
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3b0d3460f882e97a510ce19d8d9fc8a64bdd1f87cd40a733f4e431b725b64fa7	\\x90bce2d3f1d53a87e8a79916c5dc1b55b5142406e025f13927d783a76d243e81
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3b95ba13296082ab745582b2c1265e240af735ee4b4140699d079619407f98f0	\\xa7c9c14cff646ecbe763cde4209ac0fbf934062b2ba267b9b027da7e589c3ec6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3ba3b88174ebe78d3c15af58b14a87a208b3e6e02894dca4cdd0ab1dc90082c8	\\xd010b888f525523b19419047f9b84bf00d376be5b74a4de4dfc9ffd667559dea
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3c227b01286ebf6d5b3b7dd0caf2e6c5f3477cc6fa08d43e392b6fcad8acbaa3	\\x972635cb027c507f2a085ec5a0182bac3394b415491950eb2711272a887de58c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3c2bf04c90bd22eea75f1c6379aea751296175828cf8a76d8e2a26a1cc28d37d	\\xdce647ab3e548b0be9bfedc822fd58743d1cd84e3ffe7b9090364bea07c335ed
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3c62a68f71abcb3fc6f031ca90ecb7809ea685841746a0f3ad3ce180105313c2	\\xde64ff8eb402126f1552cba9bc34d50aff039b1c81c04d2c7f38fd41f23dc28d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3c95de9a0cff6756100d74c6d0dd8d110cb38e6d9924c6cadf4cdc042531c50e	\\x2b8023c443a1b7cf1a3a9138cd8f74d05c2404423d7f4b9dbfdbcc55645eca38
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3d7a9d8ca32348e4beb5f8152ba315efe2ca3a01c5e583057ebbc4be8b812a4f	\\x12995dfee1fafdef80446d2045278f3e7e35c1ec2cddb00727b9c8f1d4e5ebc4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3da2ab2fb060ba3cb3cb0093affcd24ea6941a01b71d08234645ffdc705f114b	\\x5c6a8237ecd8456c31ef8339769dcc58af8d5a3f47107fb9d5127e02e03f2e56
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3db0d38393f0e9dbf4afc27e7ea79dac88c95f5e2f31b9d79c87335f392578d8	\\x6d25402ace9b43c1f6ebf90110d3e8bc44800f0f02ac2a311a8d9376f53bf99e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3db5522f923afec4e22f9e8747f9140ed4566dcb7f0342a4f9db92d61a093dae	\\xadb0c1b3f1b39de93b1ab077ac05bd790385f948e992c0654cd449c5135649c7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3dbadb8ab766fece71eeb012059ecfc18d67ba0850a4bc04e820a40c2870cd1f	\\xd08cd69ce5ee548a764e8c50ac48bf677f3efee8ad67cdfa1467d7e3eb6c3797
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3e7fa259620ad30217f87a36ba12214ebb9cc9b6af40c0c3ada3d1161c1742cf	\\x51d8d6913af267a16aa6d50a2e18ff23f0c09736fb53664aca85bdb2e851fcdb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3eef8617c96ff777f5fa9e6bf5be4ea45ca503ad71f08177210dd4f1293cdd22	\\xf129e0a1e572016033eb84519506522730607912e306319117693fe052da24ec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3ef4187a4be9703bc357b1594337f54c982849002380a55e2b87285fea354b17	\\x7f435bd0936f0a83882e227e90d170886fcdf35216ff59c536199d09b6397682
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3ef7a9332fd1a696b8cc044c32dbea66dabd3c0fb3352ba3f083d9a780b35a3e	\\x4920bcfaccf41369e44b7afa01f94377f7ded838f21da08eb74ea7636e211a42
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3f3e5a69ca7dfbb996b77550b8867545bdadc318b6dd994381645ad95f3c1313	\\xac11a405e99169ff69dbcfc6617589359e4feb5dbbff142ea36362d31e37406d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3f4fe4ef70657a42802827445225d269ac075b278dd0a1747cc78818d7942478	\\xf70c33c0c7965d808a47c350b93ce668444de2e08fec478aa8754513a724c8dc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x3f548607a41eca6d2b085de0caf8d136378169155f205a69b3628bb8b91c7a98	\\xe1646d35d23adee08347194326d2fe55b8d60be9cfc52929086da106fe2e6987
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x402d6a440c77d826248911424060b1497884c3080e6887fe6167d733af76456c	\\xef6ca0859df3d7a711091a2734e13b8605b0eddef21dc36eea6e5cefaa5a11cc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x40382979a6561857530ccea0fff2c303d5a3e1c6cc99434baa1e0b0818a2d4dc	\\x63e6371c94a1a67822f05eb3113bd6ea3b17e2aa30558eeb7fa09f234ec701d2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x407302b444063468abad45be0e2e8739bcf4aacafa7736fa81b2e5eed36b3b1c	\\x1d3799e488edb948a1b96c3c1ba42bf3b2cee9726bd77e70f59a33e92fa4696f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x40a3deca9d401c5026f084c18792e5bd3b36315c8c19f79a99ce911edc9a4535	\\x6a3b63bc0f94217ced22538a1bbd58186ce51ca4d6bd7daa48f6ac238850247e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x40bfec0f16426ee6ec464751f89e51ba04342cda015424e574b81f693365c992	\\xe31f6bfc179d7ab6303820d8d83ef50e3b359471265647abe4ec937568599cb9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x40e85b70d85baf0dd3c5caa9c8033567c06f115e72c57109c2180c7afe768dd4	\\x75cb76c81ac90e1b1183f7db3c4197a0ccc2e7b880bffef9d0477556ca01419c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x40f4f121be218559c1e743174a91af2bef5a430162e8dcfc21c7a29db64be4f8	\\xeb013d196035087724ed4c9cd4b2c3da08dd35256ce1700f5250d6618a6ba7fb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x410d7993163c34c2b94d77796c84af8e5333f3c5ae8c0b8fcaeaaac8e65e5ebf	\\x18e1649a15c82e781054d326eed8ac7a82c27dbfaff82e05aa9768f47b38b5d2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4157c169409aa75cdce44f0e3feb4de9ec317d093347072eef2b25c085406036	\\xdda068416d8c3ce8855093477537e811ea4c5d445727e494304f7e39a70e97f0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x418b289822ff3c55cb7522058a1e29e41eba9ee14c2ff04e4b0682aa378c8143	\\xab92a73472896e9bd72752950810710cf3903c7cc799ac00f8c3bcfd44c169e2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x423e9985193ec39554cebf0d0d2e900f96cca67b577a5455e2b14adbbb63f7a9	\\x99f2373b47a16acc191fa519aa4b5d0c7fda8c2221274b128cb0cc542ebf9b5a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x42a2942c7c2fee50f94290957398d390e6f7f5c17cf8f220c23c2838fd9ba742	\\xd3d5736a3504a17e85f4efcf75186aefd458475c60d1691c34f6adbb84f51031
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x42b2f3408c53f6593ff3e13cd570e73085836e110059b78133684e1c333e4e82	\\xa30becd79ef03dc1da9fc155b24358c3952e876a8a7cb3a97c168aa27ad37157
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x435139bb36527622509a52b604e840543cb329cdc9c03710aeca611bd5ba6c25	\\x571fa30ea726793b485bee2832de8bea215ca2db6f45304432e724ea90fa6396
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x43bb02fb9dfa4d0e1ac86ac918af7fa44bb8a3d37a0d4922fd526d1fdca32375	\\xcaf839d94a06fa43e9b67bff3573594f3662af635ef174b62723321ae1b018f0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x43cc43013291f6a0d8185d4076f3a3adbeac7780e9e554a85e39282f03a24b48	\\xedf5b333f1bb7612ce6727e4f02893b0221cec9e46cc112af93e32d96b861015
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4406b60655c0f326a041ba79dfdd389037fc774215bfcf5a9cb9b48f6f557f82	\\xcc81dd67f335eb07f639fafc42fb4bdb3bb082b520f85c7a507885f18c35cd39
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x441112c4930a7accb56adf3b264370a55a563825fa56b9fb9d5f19b8add33887	\\x8e0bad1e7745cc3e45d9c69287475335f3efd5b12d8cf9c1a0553a5274683666
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4436f2824896a527c3ab6379bd621dfd2cdacdca686c2b6e882d0cb89cf585c9	\\x81b6328a227e7697debf804fbb83b78a75d5eee2aff2338cce8150d09792b5c8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x44c49a3e0ea30887c5eefeb87fcc3efe18870a0807483979dc7afd4ba4d345d8	\\xd8852f01881f7e46eff4a279870eb59ca03c336ce5bf391e6e5d76f30f9a9bc8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x45265c6fba4b2f83c9c9a6f4c854aa35043b064df4c8f06d8372237873aba119	\\x90f156734c033afd3cad335641ac52ddad2ae7c146cecf15f95756b1ddf4fd09
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x456986ba6fc4c1d6be4b0ca8a9439c54f52abb9e59428c1f048d6f1c239ccfbc	\\x9bf7319990441257aaaabbd4ace3ecfc58f9b3c9f2746ae4100d1bb25730735e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x45d5870ae8123832f935af25071105aec644e8096a4fd51d9be6aeaae11b7c5e	\\x6f360049755f7f786bc3ea392b4738966f6058e07d40fab6f45f51d34a63ab0f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x45dc8fb78bbd4e85422f56f0657db1b908e3ad9a4f27777103cdf547c1516f97	\\xce4a68f01067f9a032d848ebb2a6ae75683a75dede63fbca863c00fd8f0ed5aa
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x45f9551ceb8db5dcbdbcafb20332394205a147a1abff234bf020201fcd3b7a46	\\x43f9f4237162bad9726def5fdcc2832514c7a361569fe89d7b4fc56594603cdf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x45faf521127a60f3cb78fac64cb17aa0945903284feadea8fdff9d19728ad82a	\\x21ccda7aa8539dd0663619ff518155854a274d2d1bd49fc4ddf2a5858b06bd06
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4600eb0018f42fced2e2cc02c5d078c07137f5e86c887be05249ca2814376a79	\\xcedb478fcbe194329aa480f1ec14a830a41b2366493831f16ab28789d114d76a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x475224827ac88057b6009d14823e5be7859fbced95d586d7116a21de89630cbb	\\xd8260476502ce5455611b0ee3a19585e2ee0764c801a418d09e9673463977559
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4806a1726e17fea295e031568a423a25001d32bbed4e7bea9c4a4c3b6c8b09de	\\xed4ffaeaf8dba64fd43c67e548b5664b0617116be6f78503e97af58bce2656ba
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x482ac0f842ef1f20c12bf85d0ad3325e510dda44816b5191db80f393e105e95e	\\x23376ef167e81ca516e262410abdaee5a1f89cfbfcc500b3c76c0c67b5b300f5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x48cf2d416b14176b3a43fbd6d19cc74703de2529d4185a8b29e2b7d1599280d5	\\x68e825d4e5aa37e2cf0fb67a83911e6ada7b661647ebb76b178a892de4d55113
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x48df020c8ef3bda22fca29c9465a5eb4c97a130cfb27c581d80120c77e1f524b	\\x41b53af261a3c78d05c118e1e019b6898b8ff81957c597a3f146a557c67e2487
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x48e06e8ae18cdab989c4aa7bd380d28145cda5d258ba76da5eb881c9af7394a0	\\x5cdb9ea2305c5b956069d3a4faefc623408b4cadee002ffe917fc7ad747f5ea8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x48ef850aed05300c9a6f1050de92bc8478e9ba4e39d9d517ee74038a16eb23c0	\\xc4f5fce6a05a25ea7df9688df1fe324cc8277ccb9d527459aea4320430d2640e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4915a5d08df80c19917d24eeac7a7bfc8f1eea9cf03b5304c5a788d3903b920f	\\x6fa1de3a7a5a0e7a438e40c7b66add59bb819bbef8886fd123813cabb95a7bfb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x492c5ff7a6655d98ae768caf979f9c4390980bcf9485f0ebb2fde8e7dba2170e	\\x79f1db94d47f0f4bd14621f458fc2fe612074a645bcb36884dd44e73f9ca4cf5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x495513c63db7af580b9814636470a3a4481f07f94cc698ce9156e1f3be3c3b14	\\x7b04809bf081cc64d4c00fe1c67c56cb66147965c6765e49c24cb8113b8f9d51
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x49ba292ba6e6f10d93f8b13c34ece1c26f2adbf1870efd597f6c3b6e9f0adb23	\\x73ee7021b6a6d7b10a4ddb120a2255fb69bbb2d16c57d0d91bdd5d7dc25966fd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x49cb43f93b47270fa867a7bf763d33829f7168818aa7f2cb8f2fd86997844602	\\xf45e72de6047a8e45726d15c9c2970bc4ee15330bd00c75eff64a3916339f5c4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x49e4bc29efecaf0af7d7acbe0969425150a9fb2af2fd650c69ccaa3df06949f4	\\xf39b385e4eb5b1da4ba0e635000a486f5e32284b906954a5085267862dc00c4a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4a9a145a56fcca1966c0cf064bd578721e548b8ce0e9d002e982982934834a1b	\\xe4d129d851d8456f6e8cac5caef3f6daa73dcdc53fdd5e3dfa6d3a75ab22921b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4ad1030e8c248dc0f4098ee6a662dc799ce7e1744def75f2e574a188eab7d944	\\x5247a80dad33a7aa5ed5abde3dfc7726e714668c1cc87e38b67a8ce4dafd436a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4bb4ad259f9eaba11027ed92676254ea80dbbdfb41efa23ec066d3851458909d	\\x94f6f6b8387e31662e46fce0cc5c751ec0e884d0e8395b42bede21ca26e11ed6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4c3b4168a7cb3bc51992f17c6f8bc927a48547f02d200d0c967852fe3e131d7d	\\x28e4837faf29a6252e869c7a96cb0c059c5116368c66a51627bb4e51c179165f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4c5a43183c558a6f98d8b1967054d59fa688aaa57f2f366d6180a9deefddf285	\\x83627da955738a43b2ff7b23ed1173b5c431dadf2079e7f229f70e8d687b5299
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4cad023c56595a415beb95f47df91aec6d3d6419189886b47813e023fe07b560	\\x1e97b6e265efda66495bbe0cd2ed5f601da651d9a92ba5b70d10c0806dd028cb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4d060c8ae176bfe592b922fabeb52a372148296b9fe554fe9fed683420c1f1ea	\\x5d6616d2cb230949ba8ad5840d8ed117bbfe30ab46426421222c97a0e3b38a4f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4d97cff1c0f047fadf0f1ec9e75572e56cff6871614a579ccc0bead9173da3c1	\\x3b2c0ff1a3b832738e1a40251e8644a41b8228f127f511b5d92343429af190e4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4daac5c5748d237127b72a7fbfe1055505f1ae73644d0b1903e0a3dd9413d09d	\\xc801f72f95c6abfabc4b8766d3224cc322db8caaed83e25be7f1dc4b574f09bd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4deeacf58c93f8a16125ffbb6b75ecebb521a08d1be621b644a4a93b98bcf7e9	\\x472ec60f740c41504110ba3b886eee163fffcefc5e3ba15554e5b518db2839c7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4e0bdaf4cfedf642875d6245585a78c972fa6f082d54e40d50740d6b28e07f85	\\xd701341ccfbcd08e3b3224be9d9f9d57535b54fac52da9e20202b82afc545eef
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4e3611cd174efbd51aa2fb8c18a70a1f1d2ae6f0235a7ce8a9d041cc9945e0d1	\\x55fa5e22ffad4f2710548bbf6ddeaf6e3045f48e3349f15ed1554c37a7008d18
6283143886518:7@s.whatsapp.net	critical_unblock_low	18	\\x9f779ec1f6fc43d0632fe493a3c4156c17a19eec9faaba538e89f3d4989c6aa1	\\xabd6d92c56445ca3292f3d1a1a400036af82e727224554ebc027d87b65b66942
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4ebb5b9c65f31b0340011fcede2b4d91a1261e095f7698767b5a12f0ae559782	\\xd1aa35df37487b97c4c187876b7da9655e69bf63a1f03ab7753daa9bdbf92686
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4ec28a887b9e6bad94faaa78ccb4416805de4162231d9280eef070059768bd1d	\\xaae1b952879fb31405317d614b95bdc7fb153a8ac68a5a8e1d5d19e98360fcac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4edf48ea35a20a03f6e3c487a6966f6e0076abe0f876e721e946081b3add40b9	\\x3d2235b1a8e9a9d8d8984a84019187e60602eef675299dad3184e889ffd5b81e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4ef3fa61f1f3920faad659fb7be1da8438cf483387be63254b68ed3a62687907	\\xaa48a19fee1fa1846578c59facbc68a0eca1885605ea4b0388fd28343c403116
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4ef91c20f67d13e316d40625005bf5457565cce517e0b27ed2c88589c30cb0d0	\\xf895a59fce5b0d7cccc1c1d13b15d181de7a630295597485bf9b48dc64d16571
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4f333e17bab69d28b9c4ee7369500269453f4dbcb452062cd3673f58ed0873e2	\\x0773ea3311a07c674169456eaa9e72d936ebea5d4b6849d317798ff56420c4de
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4f6655cb4addd9dc33ce09957b1481fe180affb26d9a4e578850033ebd0549d8	\\xc7066f84010b1252e6fc4413d567ffb53d4a8ccad5ca3a368752f1c52367554e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4fa641a078d9fb95ca937096b9a7b910e8d37f3e68f84ef34a573df6b023c238	\\xab1e205c5529f494fb7dca6268aa34fe2d93486246741c8bb593a7bbfaf5cde2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4fceadfb54aeea48bd3c544e88cd3359e25019f421937a50cc17920ba7ac1760	\\x120a6c3aac1f98b8bd4baf2a5bdb50f57d043defc7189305d2e856e3eedb568c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4fee9367ceb072cd6a4333bab3b84913a1811581a6e2ee22d3e727171e2235e4	\\x13eafc6cc03ed70b46517a1022609ac1ed273b5aca4c188e7829ac07274c3991
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x4ff4a50ac3cf2dcd6c4303084800d33aa7c1af8cf729a554492c876c7364f4bb	\\x070585e9d7ff325809caf1586b266cb3a15578a39318e249180981f0512da308
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5051322e80c8bbb8a1bf2033a2be5dca63e8f025e84e1cd444c988c5fa6ac2f8	\\x68894b133803a0604e808fc408f8c8e23ec47da1669dc6dfe01847d186d8ff3b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x50afeb22cf626126e89b22cde9163f6309c921aa7aa22d6a7296a282fa733235	\\x6daf277b606889377118e690170ab58ad59189a7e1dea03eaa00fcdb1742263e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x50cec82af12d22429abcf34346d1639f2b6c98f1f7f3c848f7c4eb402ca3180b	\\xddd385f746d22c50283b9d602cdeaa5273a4e75f06480e29e252e230757962b7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x50d81318718f078632010865052e5b5781107acb19c318a382df49fb08b918e3	\\xd7c6f1cb9010fb623b7a42ed7bf690f6adcb80924943c0cde5ac4fbc75bf6180
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x50e028191068db8c938f39138f2d9938811f4da7571cd5cb492d33bc60138c9b	\\xd3409ba2b1eecffe8586262b622749d40153b6c4e29a8b3f0e1fd8b4d15ca51b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x50e3b6627c68af4f199a248fd3e6c9b1a86ab0b58a860f22ba2c3e71dfda686e	\\xa7568c04ba694e7be9c156f52b022f90a58df8e821a9ddcf7a3626c596545b87
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x512f07b421f98b4261f74347ee9a7da3007d964ce54d8d6e8c7f7176053dc267	\\xc4e81c85e5fd9f7e30167fbb8f7db156997f43d484d391d33a368b858f6ad03a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x51324b5d5822241e0090981949c6a098fccb50172d8340114ef4267f61b0a242	\\x293175238307f70eb1af2789cdd2ce9a4fd6bba64619bd457c4a70f09f3bcb04
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x514267e9b2b0ad9196ba6c221f11ab96fea65388e4c5f0893f45c19635285e46	\\xeff21da3820291d3018d8c5496626b828447768beb4de309d84134c11ac4db04
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x51545cba9feae7ad70725b073c05d36d8358c29d48db68777f6c37c0552f9d4f	\\xb010ef1dbc47b2db2d701bf1084521c7c80c314c07befba2d596dde945ba2928
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5191c9a38f8e6682a73fa6067d1dbcbd280e7484934bd4e679ef9c4c11678127	\\x77bef675d480b60461289183737b13051cc51066bb8c80766e6dc4249c215808
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x51cb7d48a8f35720948e98b66023f2155498f1e6378f4d97fc626695d24bc3c1	\\x2cc6cfda2aa811739da1fee5ed90e7a9941487d762b43037b5cde0ac6e20d0ad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x51e8077009b8d2d2fbbcf3df659477a3dad738ba34cd31c8eb34520cdf9f0cb8	\\x3ca3c4446a3d0c202d847fab133eb87ebd873c5a9a7d50cf43c96cf62867ef64
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x51f1716996f158ccf839a2d2125f07fad065bae451dcd9a454e7d0247f2f067a	\\x85122233515773c6f10c0efc1866d44acf63e2e045664cfe30c10082527c6ffd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x529c16cfaa58e0f32afa82cacac01b7f10ec80291c815491c880346a9e23cd61	\\x662ba82acc840751f93b700a5f39d5af682d7fcfbe2a15c439c55a6264ab87ad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x52bd698869f8f04c0b1fefc89ec62ab73834d221ff7c392a5dbb341f52cbcf33	\\x7b9ac7736b0d87c2361ae453ae466a2c4eff02ae2945a7355cf241f1d8b8998b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x52d81ec237e21f8f9b0d5dd2017b770835e345405942226dd1f3b0bbdad1d6b8	\\x7544b42f0b193e7710ee4efb651c0939872bfe56b0960db8a2901319fad3739d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x52e08b67d815372dac1c86701100c7ec95b3461ad44dca43296804ba43b43437	\\x1343f871390d49132d5cce1e6638b53badd4f6cdaeaa9ec5b85ac2239599cdda
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x530163e4deff36ab34fc397db9ab38108b67d6e4d06b91e1032915759a986753	\\x1ceeaf0cb07f6a5ee9f51fb6ada3c7674827e75c8446cb7a2e871fa5de044a44
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5368bdd090cbd3dc53ec89b45271ef49f74973be71569c65ff04cc60096586aa	\\xa553c91e7b7c28af4b72eb021bd422839d2730bb8eee6ce02fa602a444ea4b2c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x53d3046a539dc2936437238d3cd2d2a98c6798190b6c6f5463ba839ae7b74464	\\xd4564bc051fee48808060fb8805b4e7393d4e99794366c7555da495a3fb6bf43
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x53e470b1a5381418d9912808909e5b604659100f5703ad784d40efaf91855abf	\\x8949794181c90d227a98f3c6008cf741be7943e24cff69a55eb4211b9a12e5a7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5417694f8224883d7234341492d76a54e2627cb0864c669706072bb631c229ba	\\xadb0644b164921e4c3594e10401eafdd70573f0902c09b4aa9633768a36426e2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5456f0d4dab0e367665208825dae64564141a26256f78a7b0151fdb76b49f4a2	\\x38db6fc5dc963d2165b4b277102ee2ec47c1a5fcb076f19d3e9d5c0820beec68
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x545799500254935b59cfdcf4748e4784554f2affe4f799cee234005ab181541c	\\x3f9980b4ceca0a91f3dcda4ab2871418996322d691b51b6f29c22f1d0cd66eac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5489cfaa468db473c15fbd869f92247c49ecc04ab45bb64a209cb951e715e69d	\\xc75697054e180e2942e445b8e32c04b226e9b00c1d8d873302e42009a2420d25
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x54bf83b41732360f5e2da33cce91af20050d336f7e9c7bd294aae745aeb46d35	\\xe859b8b5884aa492e8fa65411269c06211d5861c89b0cf89d236c0f9abbaaf90
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x54e5efbc3502eafbfad0347ed2117cdf486cd914f050c7221bd43483fff2ff24	\\x713bf399f79a81f29325cd6366696367d8f95299a19cd79cf1edb74aeb4a31db
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x54f985666d0ee7842823f372d0e24d49095354ff1c1282434ea83ee70b962eb9	\\xb8687b7a39b9aad821dd78b496f606bee6cf3f30075fafc132928266137764c4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x55337cacb22e7fe11b57f9ac85d903a5f41a168a8104991f771cb002ea40940f	\\xfc03d6c4a3f349f16183cd19ae109b65cbb3f69b36dba62c014eb19f4fc087cb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x554972c761673b10c3b5f7171da18dc68b3bcc9cfd6794e894595c228eda7c34	\\xcee35f26c5df8252d90095a615a3b02c33337165d71aa43a4b2aef2ac8f2770b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x55b4bd5ba4cd760a85c9cf6dac7b902c255eb3f083291721b37af506885339f7	\\xbb0e48c63d7edfbfcb07aa2a3575226bb3d029485c5e1534c6d1b8e2cca72646
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x55c41f6176731c84b2967ba829360e074410bff09f2484b71cf497f4ec8df7ff	\\xfec7ee120982c3aa2959adefc36e36cdd0d08a0b504d62768db0ac55916767e6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x55e4a3b8ebb8d7dafe3fec26b038493dbe83af9c6ea6655cd674533a42fe3934	\\xc41148c197c9fde153882cbf35742811c237650dd932c1ec4d857759474cb13a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x562cb336971d7b5d7989d76bf59ff5de4e22a870506a3e459d45fb956b7b7a12	\\x2f26f9252cd5b80c677810e1f9a0f49e7b1f5f1981f679f7f8e7aad71e036e63
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x563855ad3258bea425ffd8fc31c458977768f13b6efe3bdbc820d07277199954	\\x70557637a7c06a67cb65dd12ecdb1c837aad42434b4aa4630a0d290e86e1ce02
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5690a23bdfe8e018e0143ce60e8af2cc3f51d776345df66ce63bc0726f86220a	\\x29cf98155348424e3fd1ba30f52efff2a71cd06ae9d7f097516c4bbfa8b40fd3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5695777894f5f30155ce616c2c3c99cca0423849a5abd78e29016571de10c367	\\xab59712574c699b8e9b3b78e1041b7fbb6196b520a325357200337b830f4406e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x56e2f37114cacf0f6bd7526f94fed4c11e29cb98a41f79bb5ce0bf92a01792aa	\\xc7e500837ae016732c3f815d151c34a6c7409bf0ab69684d7f61fe3d495deeac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x56fcbfbd998fbe39ecfeca29371c5849c8915a0676831a3a5f7fb09e3f114f53	\\xc0ca98c39c6e748edab6d247e52d5d788ebf5937a12e52fb9b201f47713dd0d2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x57126f02db3d4503866721567a0765c3d1828201c4bc288a75597ff3d42c2b01	\\xe00121a041a01f067acf28d26516a3e409264108908a8a213db2d6c59c2510fa
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x57557a69500e3daf825d3a3f8f58d581171d6d3a05f4ed67c7998587d53a61af	\\xc63fc7fc959283e3d908d80406e51041e08a01afdc4f725b90b05863e07a689f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x579978194b79d8b398f52a5ce15e65256e5578f544b936173b959b434453b6d7	\\x0a320e25725bc439d754b0494d97c931586ac5974d168ef56843ec97fb974188
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x57b6508b770fe9f74a34b5264f8dd69c2552b3eb1589e7581542b00f42c18b1b	\\xcbbb7bdab901c37a788a898fd804603a24f29dbe1e09a1619d7c0b47146df1f1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x57be9efd16ff0ad165f7c320eb66c39ce9175dfdbd7de3addb9e115274cc28c3	\\x61636077ee6e621c621e2cf3adce9a91d275653c2c8b8e9ddce0d40d7c6ecc33
6283143886518:7@s.whatsapp.net	critical_unblock_low	18	\\xd75ae68165a58d1bef1ef4451b21eff766e51ff8146353c736dc2fb797e99ee6	\\x210095e026f7169b9e3b322ac68c127850a02a737f1b40600851159e0ff5fdb7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x586fd4196a414f366daf5912645f8fe41cac17c020afca920905cae17f602d5c	\\x64169ce1f73b0613065f43a697849944d3b741f2c5af07fef182c2794bd7dcf3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5897fa9627238f08483e7592349437b7c79f500e0350447a500727fa783b90f0	\\x5cb5350b2448b57ea244795ff466157525b6ec767ad3877743cbfe92d1a385ac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x58a56f27331a9ab3e946ea0b6fc33f2cfae95a98d9f5a19679946042719e230d	\\x840d330453fcd1bf6d140e0cf3915e7b99d466351d1de6b6a115daad9cb7a98e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x597a3b92af27a7fe8c0ceee5154026dd2010995d183b680d2ab30b57aff21198	\\x697e759aa6560e337f2fae40e6ef4eb1c0c683c18df2cc8b8684a026282c836c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x59e415730c19d31d8e6cc6bb1c961a9a8f5b8e490f04da9ac08b4ef00a42f3ba	\\x75aa3083555a22841f0131dd3dc8f41dad61b0ea7256bd05792c9633fcda68af
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5a13d02b89f6398fdfef6f490acbbf9bc30904b32cb22a5bd0000b374caf0db1	\\x4e65adc76894559779d67fa98dd9789bb41b83fb6b6fa59b137fcf0f5ea16515
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5a29df5152df002d8f193004b9f773acfff01ace9904e6a47be7cdb37b9f1cd6	\\x6c27175548faef7b762fd46dead6a9c8ce1b5286c847d39c25bdbec32610a2a2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5a2fd3e03387286e0f1250cf62e0ce467b2ebd51456d39993fd0baf8fc1ff7d8	\\x8d50b27202fb7ebd7ec58b5ee41c1ab8a19f22b95ef152549094e61dc5060f9f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5ad259508615a8d69ee6c888a162a444ba82cf8934ddfd1448b96a1a5b7fb99e	\\x20bad875f9a25a1b02cec9a4e93d883664ec61423a932e712344a5d26cd1491d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5b478bdf9391bd2f8d886954b576bcb36cf2361376f67bfc0fbdcd851ad7a637	\\xf92a0921fdecef4bfb31c59c7ee3237473bee927940082a3d508b9b7ea91a780
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5b62727443e02afdeb0400246723dfe2c45216dd11406e7ff62e135756ca866a	\\x8350b3314d4720113c8e4e578f33903140117846f970737a97e1567f747ed101
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5b7d1e8ca4eadbf66f4f4a2926693a443cef23c6fc5dcf4019ab1c9ba001140a	\\xf6ac391862140d7937306a7e28471ba1d4c446e8c985d2cbd1daae05cb36be56
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5ba232eb44df5cc704c6e07581f354a7290cd0e4ee3da0cac4696d40b3971a92	\\x6d8889e6d9e5062f8216ca8e5aaa963f11b535da5b0772c1db1d0b0c815b0419
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5bcf2048ff5bc303a22d856558aa4e5c19de20a451d80ed6c110b0096d0f494b	\\xb895781c8477519b92e18c146a47063b20b5272f9d68b612bb6f86599d75078b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5c10e967d015c912dfca4f182243bb951de1e785ebbab862d9df737676e46c39	\\xd6aa56c2ad987fb9aeb78df03bf8f15b19f65a415b580c0634fb1a9315d28d2c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5c3feb1728cd9fce434dda4ab3ab6011c02e968d053ea462f9aa8fc734a128e2	\\x61ded6e2d461019439e97987e95d990af3b81231b70d7a5913ec76103b27a072
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5cb9d8ffdd3863acfb68e76df536d0d39f0b118e936e900a80faf7537f4196fc	\\xb9ac6a12260878661689cd520e7c384be853883b3e6021fdf0695ff57f990b5d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5cba0fc208440dbe6b6246d31c47aa20ed56e53d4c3258698568ef6328e210ec	\\x7f6053b943dd95aa73e2e867d55f080ecb86f3410a2fc9d9dd4fb5849a8522a8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5cdaf5252540ae4ff45264c84312b3bee902c5f71c97859194ae6640094a09d4	\\x508142bbd089aee6124af86b0e66383fbe265fecbcd7f5e398ebb57d37be6cd7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5cf3521a825f5d608e049356f16977fa6690367d8d12488adb03b0795b8d49a9	\\x04a5ebf796a7669174616d642c41b3e1d957ea749415bf94de2f120d9f1fd0ba
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5d4ea1c7bf05b5a3935c4f06262ec78d2bda48e7c27ed0ea05e6f6bfaeaacfb3	\\x070ddd2c84516c125ef763b754d29cbddbeec9d6a4dc5f7d9613e9b958238e9e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5d5b191b4a91ad051d2adf51ddad1c670128316d67df67921bda91d2d8b403be	\\xa0611e44e46038fdebfd21c840331cdd25fa2557daec01c4f27b529a989b207f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5e642720c5fc0927605e9fb583672cf1acbde7a5fc29f024dff9418de5aa9ebc	\\x9c40bf37ae4269c36579217458bc700b2aca5638798d46dcf0eb9d792225b789
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5e9661333e01d120cff3ba36f5ef9424ec85863182585817f0adc5bb6822bbe6	\\xcb153b6de1169f02001ae0b444837f79b732f052bf3c96317afea63dc24f353e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x5fa60bbd3e53736199ab936cf76bf0b4a877eaf651030bf1f3ccf1aa6af1415a	\\x6b1a282f0f2143cf8a3d4d80dd6d7584a6ce37f9056d9c4351a8bb061f2b1aad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x601e84eadd92a6646babbdae063ced3b991d5700704e6045c7b1e3ab1808234f	\\x3dd3e12da748664a2e3c0e83bf88ea3a059b43362a9b1c97784ca9b7e48535e3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x60df3b8b97fee569841be3bacd44870b7b9dcaf9b12bc1c015d7ca9ae0acda95	\\x3f9826606fc48fd4334d858755dbff1c263569a9051310ab9120bd580cc0a8e9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6128a79d8e3243ae99a505d487df500ab4a0ddcf175eb2f388467cc1cf939e7f	\\xb13536e5510011d5016c78ab6fec4ab9b580f358b7eaff5363a9dbc1d2102975
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x61ab0811fa89a0c2c18dde8adc6df033c5e2df5c2fb8105663197ef0dfbfd1f6	\\x71266bb2fd55e2f6c38bb3fa22dc47ae1ceb555187d78766e73f7b224a33f945
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x61c27a7d32ca092bd6dd776be525513adadda76257a9ebba0ac8f2f176eec51b	\\xc83943b06070d432c22daf3c047772f552fbeabbcf041ce6380ec0eb9c2ba3ec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x61efe8e4322c6ca8924b08f2e3ba42b823cdb5e74427e7ccee322752a3eaf635	\\x5ed1a117697d29519293b7d6d0c47f17dc9fb75f290b697c7a66edb3be716177
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6206373c5fe38334ed5d6a784ca5b8035ac8486fe164fc2816acb729acc62d7a	\\x52aa19d9968660316aa6003498702720c0a145709f27f5f061e529946918bfef
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x620f759a03e5ebca6a3c6065148b87c0a238cf0dafddd9909b3e032d9679711f	\\x573a29ff1e5295adba40b62706773008f4a2b4a29603927d3c8051c0a430dc7d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x625cba13d265bc0f64a7673445d8a59e6233c76d36cb6b888eac81e652d34e60	\\x32bd08a6d55ee8c90743fcb5dee0f72391d25ece6a3173a380186e22472dc3ee
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x62b37f899f7a1b1fd1df24ed7bc31950deac8085b55e1e812e7abafceb7f711d	\\x722f99425440b461684ef409bd0f74c93d663971dbb54d3328e17ad5fb24a81e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63633cc43b108dbd1ea89d73f901d1cbb8283432efb2bf29fa30be3027e53e8c	\\x4cc5c739a5b389fdc900aca586c879557f786842d612835690cdf63ba6178a51
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63ae7dc4c011bd4454884dce267539f3cc5fdf9eb99329d215ee6906257196ea	\\x483224c1a3dfc0f9665129b02b477ce1d624282f0f0a3733fdbec75157f6c436
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63af67ec06d9a6e0f53f26ab789a195e67679e492c3fd239186ac247176c37ef	\\xe2618b5bb193ddd9af23502a5c9ed55ed8f12788c70f2727d019db7ab5ace51e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63be938b77718bd7414c7a04aef6d435750efaa57c9a44b78fd2d6c092210218	\\x1d5e79b66dc90cd668c8e3e68cf3c56a21fea31497e2052002057260f7c061eb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63ca99d1270d5644753a9222a14c157b785103e2e6746ba27d08d29e5a2cb23f	\\xca994938c6e6f69d8fe027c1e440037da9a2760c79e4ae34a6a8314c99ffe13a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63ed498f0971dd339c1dc26af07f52be9ff27160db33b4fac33f5058d5a4291f	\\x6c3f6b59aa99ec673ed3a02d02e64dd6c2f0fe461cc13f95b66cda36070ab23f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x63ef3dcc1dc780e38bf7f2cc8b1d5aab87fb8bfca874ec5acf266ac45a124ab8	\\x2ea7d2ab457a78e7b8e95310b39d52e98ae80ed91b8e4064f88dbc56bde2cd9b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x641c1569c86231d542cdf372c18fb3ad848997f75a403d1e6d6529d3d6f798ab	\\x94e6643ea568e340762563497d57b9ca2642aef30605091bfb9ce752323d8c38
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x646c1b9f691d36644b0126f260a3a3e50b9538f49c8248a145381b27ae8d95cd	\\x2d0996159db5a72d38bb4407f92ab54f5760275b2c49939825e92950b2ee8e3a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x647a8c8c5f489ebfced8a825960c451799772fc3ae101bb57248e190308da768	\\x50f9b9ed611fb0eb075123adab57cd0ec00e555f388d0b67cf8d27f8e9598706
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x651db3be76f4096f5e263464d002ed09cd29e4e614c775ec2dbcdf53ea0b0a17	\\x86e5c58c7e92eda8e8ffdfd4b775024221343c6d1feb5c56ac250bcb57566a9e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6553332bed63698596e5453883f7664112b3b53b6a6d18b010ef00dd9b1a3a87	\\x506f13a058ad94cb1ab4394a044ee1a8d4f7cacf4af06943c9b704b4718bdf80
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6588ce219baa8a4221425bdbb3cc720af6d1a2b84f695d3358359e64054a9d1d	\\xbdf9351a7983c7df9d872793f3205d9d76250917a687b2c4a6828e7b72e85b01
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x65b49dd24a11b03d8607f6609361c6eab6d031622999aa988cef64c83e71c5f5	\\xa70db475b76c50009c5abe81be50be7cbe3c619bf142ae31b4d4cfc907b10159
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x65bc7f48f0d3cbf074af879aee6a7964fb5e490efac96d27f7283a8cdec92d9f	\\x2715c55cd472bfeeef87bf856aa948a507f0844de385b9f98bee48808eb4d266
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6671fe9c418704b1a37eaaacb4496e562be9b22053f84ce21726d1b27e874faf	\\xe76d6d42dbb34b8998e8a99c78522604f61787a6a272266672582b8e80c4745f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x66cc940a5351021aa11bb1106cfa73c802e217758c29d7907cf974f77617da33	\\xfd5b21936809030d22e774113b123d56903765570082a6af593e438d93f5deba
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x66da92f440e82363c31a198142216ff70fc97eb43a007024219dc448f9e52562	\\x2d1c1e56f3a2b8cb018f8ab91f3b3f80b931f71ab2cf5cbcaf72f20dbc58073f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x66e3682941db04a00b6c6d79dbb546dc7cfbbf29f17073f55c1301f101e4660d	\\x9bafd107cb613f7dc7bc1632c3743df1b71ed0a758cc26a63666c32c7efdae60
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x66ea56b8628997d6ded80338eb994b85374556ef6dd15630ab79dad372b18689	\\x770d7acf7d5f1f76f4ea42dd7cc13730d8abfe8b92ece64c0cf0bf48ca88c723
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x670ed0fed49ec636dde6db82ad0f492d4f26b4b7096c55b0d569221a777a7ff5	\\xb5e7780c49aaf7f5802c9edd10f5fe23c5d99bf7a974432b2d771f86d0f8ef5e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x681fb08dfa81225762dce96f9cf99fdaa7c2b0bda075daf861f35d3009b4727e	\\x4bef713ebd58e285eb9b32a7b875838b79aba8f9a5f1566ed465b48ae79e80ad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6830cdc0a5868286546ebc18ef40a0df69c64cab238351876ce016cace2f3bc0	\\xfc1d945ccb2bbeb68446b641bda77d973d4493c3c7cdf82fda760180d73399be
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x68903638ac1257539f745eb5cc731a6dfbd48de51fe3a3d5282a20eb25742bad	\\x81f4710555454b13267b74b8955f1fc20c3a7fb0014d51599f0d3bcac46af32e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x69128f34a37085c8c7d526a5b5caf26c64d773edda30e55d1b8c5645455b0eba	\\xe7cfba91a0423639bf4df0bf68093c4cdea05df2f892010dc07ecf648be27f46
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x691643c8ed76070b954d45f6da44d1c631cab4f54a2ebb56e9d90eaee21f22ef	\\x5fddefce0e792724665d92ab15907eb620544d74c14438216656e787c7fd8966
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x692faa98bd2a3791e80d185562638b541edcae3bb89b36538b023ae18c6b5410	\\x49e4f4b857a4863367d392317a4a080f53e9fbc5137cb20795a27cfe38f71dab
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6957d5008624682ecc2d8dc029443bad7403e6231085fa8d7b4d70ccdc5ef2f0	\\xbfd8bb71c1538660dcab0fe0cf71786e226ec5f31af4abe9a3d46a3f2eb5b19b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x696737bfb4276f99d1913b9a24d2ff827c707d55404ff4ea3a62c53ebc021f1c	\\x75815bbf662f322ec7a01669f8d3364ea7602ba33b92ff3332d8aeb1321a160f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x69897daab8f3cb8de605d6204f45a93540c29ede7db372c741a825239a35f7dd	\\xd5faf8073bb498937f489f527956920dec57ad841f824e0aafc522aaadbe82a1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6a3dd1b5af92f109e77712b57f02f7e994d7cc3599291f414484e1a15d440b1d	\\x789da0c1c8e986bd8c86a5a7b1212b464b3d2c19690a48de75bc66a73bd95b19
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6a7bbfd3c18cb88d8b3cbcad66036b09b1ccee373a8c82a66e7c6cf38b283ef8	\\xe98b164b144cbbd7a32989030b821a1732398955771b0791184174d79d2f2330
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6a9d1be130411766d7d9d0c8b06ecad23d949e75574bd23ee5f98a73292c3986	\\x52275c3b279c89aeb225f108392b2c8f1ccd9b35bb2b1278562bd766cc772d09
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6aba08eaaaf5e69d021242f8e9a86412f7e12568ebe907a1ce6bfa889c443344	\\xff6e0c7a5c6dfa12c5d3a29af7e04ca145121b0ad0824a340d4c1d484c5ce046
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6b0d63a92f208785fb31f30c46ec1d299106a4ad82d1a4bcb0639959cf36c6cd	\\x981764b5885ee4567c843148d819bb006eb60306f6fa9d4efef8de132312f81e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6b78b806bfd031dad9e8494f4938b4fb08d3a61909acb37ea017cf637553f791	\\xc663d584633f62b10d7f99442261246735e96e60a129e8eaf63ff3acccbabb2d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6b82055e69d7a12c5bc7d7b201c21decfbc343a8f529be461eefe33cf1db2a0f	\\x8c999dc24a986cd4b95010ee0f2a4f4affffa06608a89b7a57af2136470d067b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6ba46d7dbf5bbdbefe0ca6dc8199bbd7d6cb27f5687a92df29ca29a5ab7214a7	\\x667fcb46a4b1c275a62477f64d2a6e5307e67852a51505cee21975367b7c5698
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6bcb47ed265f452500586791946888d36a5adc2ae1cbe16b00e428d8b3f735bf	\\x2f9f7a12546a0415ef9d97d8b3d4b540bb525d2c6ad7b0bb6fb9fc758e72bd44
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6bcc6616b121c5b98d266fade40cf1e6edb86c76e17be32b4bf5df7d9442a89f	\\xe3e1807be9932e9bcc961d405e3948d71f4d23bf56f43a37377c0df5142f7d46
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6caea0eb104bc38ce3d375e8e7a560180f7bd2e944ff2bdda3ca11650de050d3	\\x9b2849738b0b5cb55b0eb931a5cdc0b3d66ad16fba075edb70a7ab89b66c4a07
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6d6a2b85b849f3bfe5073032dd38d423a3edccc8e6d6b4d8c9ba05a9c714e133	\\xfd1fdd33175c88e073927092d68172c34cff22542c583bb068171b6e1aad9438
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6d77152dbaf3d44083f48e5ddd29a9ebb1d7fed01ec24a68d2549add9d0aef76	\\xfdabb6773294427353ffd2cac63bbde637ba75f29575ddd6b046902226b07a3d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6e623d18bef7a827d602ef0f0e3318ad7fa0e07b5e55a93d4a3c3e9e4d690c49	\\x4f0c5faee88e24494eeb65a52c8b723c612b90c6bd0294c53511072bd45c398c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6e648d5d6ae1fecf18bbebe5a8ea39f5e5de639e36e6925138cd720cdd05c87f	\\xbb53f4778c919a7342a4ae79d2326e54e3d9deab3879db1bf7786d41c4cf6ccd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6e969bee919ad5d206fab367fd63560434a20e22375ee4ae55ae7f11f044ac33	\\x1a0e293871a8c0e6300da773cfb485961a50d1e0efa2d4e741a501b29241ad6c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6f86ba3c496f809d327538305f8390c916542d5c8d20dc99d9092b16b440f817	\\x18727257d924ce7de94d7ca7899ee597e275be56bc939e7158266af29a3d71be
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6f89ba73e2b911afa373cfd80a96ab808cbe71fc715ef7889590cf3503ecc650	\\xc67e6274832b7d640d23ebe853f7bc742b0be6abbcfa2eb61d9c1bd6dd597145
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6fac704379931f33158f54e0ab2f6c9ccdc367f23ba9a4dbd01a8a55a9c12381	\\xcdd1e1588a0aa0d950847663c2b9454d0f5cb54f3c43cf0a134133b92a80e31b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x6fbfe5a0461d188a082eb96f16f19dcec8993b6453e36ec18d3091154d15dce7	\\x8fafe27b1c29b5dcbb2edc417d642d4b028deceeda6289a9ecfc9da4bbc08e68
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x70ae740152b0869a6e4d7ed23c5645165d0a02a1cc3221e510b87a293f56fd13	\\xb9529899a68c331dfbb4ccdc41bb50ed0a9bea52f45506cfef954f9180c37306
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x714fe91c43c8f2426dd649e82b45521076f5e7ef34508400965c9cfb8c3c42d8	\\x859cacbb621a16ab4406d396078f82eee13e086f53fb5914a50b3a9fba1cd347
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x718688c607407d8be58e516a59d188346bce97cc7b75932627da25451557a522	\\x06277da07dc6578ff63df83f66773a25a200f3f95d98b36ddcc9b1c7c8bc44b9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x723302290e2e87824c20e5499960f04971bdb5139c68ff0c6c61e3bbc012fc49	\\xe91699b59538bd6b9001c2321c323454426e3bf861df7f82426cdaec7ea936c9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x723c46e9dd4d60d3780a7d48b0e9c759d00f6e0d397f5096c12c8de9841d7f2e	\\x5af762f4aa613e5936df4470372111872e812def13fd6727d862661d15676c8d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x725d5a24536da25c5468094cd1f175c8b121caea62abde24eac58136cc8d6589	\\x0dff37f30b281318e9213570929eb042b6d02c2f7828295af9c43f8e521ef9a1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7290f09549a65e0df9263e50e4ba39665fc58b42657355917003c8127837ae5b	\\x78ca2cd99350e478b7ae073de049f1fae850e3b89cceeb926d386d3cfbe03e48
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x72a7e9bdac64f3a10b9be75fcdc563a5bb7b1feab8615d38495421586f68cd79	\\xe9081ba2a82fb78eb6524afb8ffc679ed033b74c5f9c49b73a967dad298d2d74
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x72ae4dea8eb829716003470a99ee9fb009cb8b91bf719f2200c24bb53bc65752	\\xcd8f0bdf520df2695936df3c7bf54dde34a2ed434b445e37f835b3901f80f31b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x733ee5c97dbb222bc8f383cb49cd7797cf98e9d62024c512dcb601101166332c	\\xa8d1c7e40d8c5c1e558f74cd090a97a61ed2c4b37fbbea14cb1b4fe97224f71a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x73710c1cc3af0f67e9e7455e4b73f47b9e37fce02d20e0717a6e67ab8cd01090	\\x3ee6a1e5f1bafd5b74c793358a7013b5a282c6008826b5a5eb4d4782a0c3bdfa
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x738fbdfb968128efd96c2b03268640408934d5cf938f8be6aad84f74199a8458	\\x9eb33a473329f5312547f45c16a529e55c984a1530102c385bb47944c792748e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7391f0fa40c105a1e7c4d489d5848f87a84d8e045242764870d0defa847dafef	\\x6a59a10e22486fb6246a5d2d0006da9a76df544c8c7a5968b077a4fade1dd846
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x73a4f2c711432423eea693e9d776ccc0c0bf69825021814d41df336c38557121	\\x76441eeafd9ba833dc3d2fc5f22f58a89071ab1a35f49e90ce2de4ea0a3139a4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x742b35daa00ced4a4f44638891b804fea8e4478c287d9a8024dc6ec3af0420e1	\\x7f95ae6f9cdcea9c1fe6856e5f485e62a4bfc6344bd4de4bd8c619635806cf2a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x74313551c89d51400a3189a83d059abe21fd5ff3b363fedd843c48a06d50f632	\\x00e60767283675bfc72532d8581a2cded532da149a0a9b0c7d55e73046f4dfd8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x745858fb192a9ff1613cdc85f9a397b15f008d3b0487ef3c5f5b0b55305d3106	\\xc2a0dbe9344e0baea10cded81812c1fa3251d188c9b88c3f16906afeddf07033
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x74d2b6b8b3b3bbd78653909ba00a0996389160dd30912d04c7a0602d102c604d	\\xa124205fff078fa0dd9c5e58b057f6ce82834c4f0d753becdaa84061f96d3f92
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x74e2ddbbfc369c24059bad929cbc33362007b5b0b68b18147c8400ad59be5ca2	\\x97702e790093027c600d4a2e1a80d787f4b61850caecae41bf403115ea70525f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7503d71f1c6bd533d3ec6890da95ba6194f0668c0b5838850bed1fd141b3ea78	\\x34a77579fcc389c948f2bc943ba839376a3185951532f66253157e6dd5e26a9a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7512508e01ca2be3756a97b1818e89d846906fdc9bb55764109407b64b601a2e	\\xdbbf3e6cf96294710875696a90e60d65e15af7bdef6262f7af6b7657d6b8d42c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x75365636b70ff27f8a64b91661dd3f936071a1799ea4363da4d65abff48874bf	\\x641c91de3d05b3f48008e7bc10460d8f07b9e4a8769d56436b06ef3090e5330d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7546bbfc1162d7c58f50cc2c143de0bdbaf10c777ed3a47cd40bf8015957bd3f	\\xfc170d5ea295a0edf6e270b3e3bffc2592a9b65420e1e7a257777cdf00ce5c87
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x755dd1e3ca168a24b3b068702d5e2ffed5c854f2d0351497823515d6cd63c28a	\\x3e1157750067978c72a49adf6866f1daa57150e55e70d2304a194a98596ae79e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7656406948660410e98d4f0be9d4674de9e6292ee7560368ba6e0fded5f13cdf	\\xa543e2089de25191d929f5cadc5936f6171622ddc3b094d29ae74c645e816994
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x76e0128a3171d3bb9e1f178cefbdc1919a97ac9ee493a53c71a56cfcbaa50164	\\xc59b5c580dd37db4c1d73fc64310eb9342ce3ef53308b83a2f8f8b7fd9d671b4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x76ec7b0cec564cb825ee2b9f396f260920aa63cd2d523576e83edf2f487cb5d1	\\x5dd3677eb0776c364d6236095b362dfbd03f334b3d3bbe737dc3a78ba5c361dd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x770c655d640bb276033daf59b14121a0075155edcb80468739245265b2f25f3a	\\x4f725e7a58927ef2bdf549e64553ff2dc30581a6930dd44baa0f7db29f93127c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7714195ae12dda725f1002c58a89fae258bbad00738def39011d2f5b7d982e3e	\\x2a4a99bc7c43d75815bafa1588ae4866b58f7f2fdce4ac331cce4777511a35b4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x77646ed3c817e3e1c45249d8aa3d9adf8d2e9ed3dfab78823cc98c57f9f2cd89	\\x36b5541df8ec001ff230a6c52911846d68d52557ebe74591e3b882f0f0ec9534
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x77827fc3daf322e107da2d645d87ac1741d74ccba512311064b1c7d5dadee397	\\x738ec2d3f8abc4800fe75703a786d38290911298e1f94aeb17aa2cc1d4826674
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x778d01f98eb7edca2f9874541215c70425c026f0896566eb01aa4b6745da6d5a	\\x25fbc1461e54a9d7cef72fbd98fb39209b7585684b3e23815a71bcd3ee1e517a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x77987cc9bbc89f9f5fbfd5881530c209d9822097a143ec6c7bcc8bd9ffcf770d	\\x6c1da386212e032aac62c38b4167fdc340e1013eb0dabcd99bbf63ec74932523
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x781c7b3fcb6e3ba2b03cea521b93712a81fc41aebd79a7589e0543fb1f5a6604	\\x1b5306994542cf156171eee29f4a0133f7f27e5e02a9c512d3564235b299dfe3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7892c0d7226428fcd469502886fa7a34de1f421b0e1ae5a6f19fe306584d9018	\\xdbf055f37d26eb5d17d39ee89d87110460bb6fe493914f3571f49dd8547add01
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x78ac5f58cf88f740c9136ed70a588133d5e64dfbdd93c8ea54ea4faa03123913	\\x569846ff102617ade764564b82dfba77bbdc74f27790182e1b8056857759173b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x78d8d9b2911e4978dcf6eb9847e86f30109295352d298f39c8ef5fd4ec138083	\\xac2627afe56ea94e115b5257d78cce1659b3ffa0e83920c1289a8f97fc16bc98
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x78f89d118d4aacba02f4694a72a9d3f066ac083edf619fc8f9ae21e1d8f8851c	\\x606df265ff9582c620e66223eddfeec2b226d765a7e535157c2f18591284a686
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x796762a23d1ccb55d2eeea4847fca7e1e67523bbeb245aa5011294619b5353b8	\\x32c031b2eb46f42c0896bbc8ed19f0e961b980a192cab11c5a6b774c0235b345
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x79ef4b090a5f57b566acfff056f0cfde6996a481323eaaff4d3f55ec236510bf	\\xed835e672df87e949f0520ccd62bb99cb139ebf6048cdedf45de0f089faf024c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x79fcb8a147a166d7ec250452a1dd7a8851331811d1a111b954d865a08975325a	\\xff23f75c08b6e8c2b278bfdf93176bbecb151d660d4437ee9cfd79f330cc88fd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7a8ca16b7087fd388bbf6bbe0065df5dc58c3d15052b7945dfa94a90eda2e8b5	\\xe16f46007f0632d99edb0aeb6254e0118615bbfd004cb7332c6aee0c25d2390b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7b232950b4f4770a433a29838dd723fbec7c11c40499899a37e49069f52cf77b	\\x2d8f66d722185e64eb5947333b6f6433ce114688c7fd5205098eea0fadf24dbb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7b94775b7ef5857a10face604a9af0011512a7991bafd13bc4939761867fa229	\\x5ef4e47ec5be9c5efa9f72e639abbeb958ac411d44b0deb0078a5edc8955d504
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7bd88bac96d94feb7b761ed4290d9c3c2cf285e40b384a27322bc7a5c95b1456	\\x63866cd9354227775e8377b3c04df666626e6867768c09ce3d0055443b823e6b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7c5561bcd61ee2db2aa173c5312618f2de0a625d9c3d3a9af755561a79641ee0	\\x39537fa345c15b060411df644563578657c8841f8b1da285189227571d89a5ca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7c78b818e25a491087a35e99f628bf53fd00046a8b2f42651a595c68a73c739b	\\xab4c379aff1af7ff3ca849f521179710661ba18e825dc642642338a65b597d98
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7c7ddda9af45cc26668dc9a8b26eea87f594d42e0ea9d6cc5a610f604e85692d	\\x4dd1db81478db31ca9efff8366c8234d27279ee09d53bbd7a3d4e4fa02080247
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7c81d1c009f7796f94b59d1f90c6b0f08443c89f64c123d62784f1c529213be2	\\x4a0b05129accc5593a8b70eafca67425aeb3785b270a476ac3e2e1341288e7ac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7ca80d59f9f8189056665337808d2bce045e1b6ffa3807e600eaa0aedd945ded	\\xffe1543de9611c8e7ea7be6d5f0718e18fd74930c1d6a991f57bfebf46d65c3f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7cdd786d42ae5698d038b9d7deec837e3a4a2177d1a5ba0780cfaf278e74ee20	\\x82bd47c8780dc3b5cfccd7c751cbc4317928d7288fa397d9cff8498de5910393
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7d271b94263c400cd816339958647d5c042b57b6656aa6f430f9d1f71ab2ebb4	\\xe28bd5ab494a99efe28c57e19352da9d80d3fe8bc5525177dd483bc00409a023
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7d487210436c6888d83e3b60b7d3306584eb609e076861e25aa2b43603bce05c	\\xba054c3f32eadebb6e7aed6e99efa712b3bbe41b49c2188f4c2b8564ef58c4eb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7d4dea1452e385fbc3a727ebe10230f2b5d525a24c729b3c30da3cc5c6909a4a	\\x78c813e988b751242c69cd096b971d257ae60d47274d124d3a0227edb01ad99a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7db401429eb0c2a30fdf6b6dfbfc612360007bd3226204b322f811a8bf55af21	\\x1aeb5a789a267e2421b3cece96431fa769d2df76542b294585d02a0e765fc187
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7e0e23ca7ae868bd454f706a411836aaa5acd550c031e0cf16ad0e6573ac9b9b	\\x8e325ae90ed81a43af7dc133f9c349956bf15a4c67ded17f497fbae927c4c957
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7e5487cd5c7b659254cb850fcec37affb58d36e6a2a6057f5f4c790824cdf9bd	\\x042a925b94971965caf75bdfb262dd4988a8e6d0e10e28357b85477a2b0689d0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7e549f3d1a1aa2a7593956600ec9503c05f1c339cf16f64a49625aa406f71525	\\x0f78c70855cb329ad88dcfbe19a19498f1adefeddaf25b3e03affabb73e37352
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7ea9ca6a3730f2d1cb9ac8e02c3ccac85a99856f6dbbbc4cc868710fd18d6555	\\x5ed9b734ce4c653147d30867facefe8b3664b183e87ee9c2ad3f87ec59922bdd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7ecfe373e8a80d6557369bdb04d9e39e49cc0a05591f1386643dcc766f7ab6d3	\\xc9c8ba4269eda5eb29b441d8e28eeb6362daa95c0dd5cdf09eb112e339f85539
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7f09b6332286d294776b351c02c60e93d1d08798bc9c93d9bcc6b3240c8bd87e	\\xf4bf6318ee837bd2b9cb35a2ce945e67968b376ce733631b43793dbc7c27a70a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7f2506732ad637b5d7ba5ea37a4dec3bbcc55726b9e79055443f191508fe3956	\\x287ec54fac3e3af8216c05027270393170127793c697c60277eec80425392a89
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7f26e375ac46c8647d843250e9e63c311144396d1ddbb35787d913c5b7e502d1	\\x3255ed25cb2a49128bc8881f5f5732b8dd0b4162702d55c7e34327f3ed89b37a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7f2956a4c215b5c0eaf5225b10d96be6b94a7d9644eafef63553d17e21e1182d	\\xa4bc8b9da53afb50f58380f02ad22421d9d10394e43c0733f951ace3f914613a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7f2ad291b807cc1f62cad0313d0fb67eaa3238bfc8304a5856cd2d6645019479	\\x831f8e98c91861e813a06ee04f15b8c44b23dccf84d5d371291c5c307ad9ee85
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7f316c61dd8d4d57b98080e82336f27a28815873c5faa80f7c96c9243349e4b8	\\x4b66aa7ce8de0a5e2773a04f6968bd079cf9848438b1bc25f14b55863755a035
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7fd3c8a8cce1bc993bbb23056a83266b6ffa8809821e1c72f1afc52bb46468ce	\\x8f1c316766bb860553b5fa955410aefb6cbaf4d89bce35b76b6e77d39eef3500
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7ff60d18a5277616aa33e5ae931c547b09c3eb5c452ce7d8887d7cb1875fe086	\\xa939ce8320a75da1e8e1c16f7cbe380cd41dd7c36ebec560f621ad938a57740d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x7ff8b29520628c01f7e8ab3bdfc0bd5f78898c361c6f254be99864bf57657a25	\\x76a743bc3652b2647be4a2cfd4c4f6bc88096906c98b0044c41f8848c4e35b03
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x803cbaf950eb08e339ae10d9a06b6d2d2568f8af1c60a77017350d998eac98c0	\\x4c8c95d323482f6e8370b11e19cb93cf7db0c656145dbdec55e939a7f095d2a9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x80432ef3d29cbf2d8dc72575e436552b8b0d6821ed1d4bda1a26f11d9691cb31	\\x9f0e55d32960e2df0a509f81cd071c8e33b20a0092cbec834aba6527df4ee598
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x804b129e1a176a1d0d076460cab2c0244ff6efecb397d7e5fb5b789203b615d4	\\xfc261d08a8e2c62e4ea43a3a0b463d39fca29566e558afbe235aa60bdf612014
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x80b311e536564e09402d532cdf1423eac544f318f4e98f55fe5c0861bada19c1	\\xa59bfcf09ff9537029dc2d1381f000961a95b6ad4d7334fcaca156226691dcf0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x812fe83f2357b4ee52fecd115202dd705f7657322e4f1aa27bb392c1fbd392d2	\\x43ab834e481634f110ccea37edb5c21bce5cbd435b47675270946239a708612f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x81632359f5ef75bea24292db103444504dcfa0bc2d0bed7369f97b4292d6cd12	\\xf84c2a0cbecef3efb492015845bdde146bc3f3669a2630197c0b0002b3494a0a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8166f22407780d9a29922eac17277fe804605bbfcdc3bc425d035319c38a1333	\\x030ef2dff52d26dc5d2a62fd8d723019ccc7a463b30c96112701a0f2191b22c0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x81c31ea9348858bb72a08211dd4f50e6cceb103d5ef5948683d09448550ae3bb	\\xe9dc15924b413093f9fb18f74a1321429d980716c6e1b1b628cd5a6815b61f7d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8241752b1e34e37e7e852650205e2dd8db3e1e3b8ad43634e346cf7647d573ff	\\x09d4d1fc6e17768dc824bc13c61ff242e804c5c468330ac0498a9317770b0ee4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8286b8f55dbb839de8867e3709a670f41eaea2e5ddf8d3de1470bc941197ac26	\\xa6b98fb2903fe29f2a33117e1d61f12767cdbbbcb3e10033d9de6d0700af2fac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x82cf8b044909733bce1b85d791e22d1266035f4d7fd7dce1e2a2bd028f685eec	\\x6c8ee35e31396925d61590f6977e77657c18b2133fae9b74beb6ef883c82ae28
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x82d567927793f7c390622e850fee9fc656dec1cc33962dc19ff5208db1ff5e67	\\xd91782660520606340596cd9a0d7f22caaa67caa6fcf24d7e818dccf24e3f5b6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x834490575be4b6a00acc17cbb17ea3f9c5d29cd82d693b7fffba0a347bc7758c	\\x9e29aa270f6dac50fdd3ef99fc9fffd2db7428f079a83dc9fa9e8daf5034f318
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x83674f4614cb29375b7d5ee09956d8f6769bf93d1b9c9979dec5174c368dfc0d	\\x9c60650f6b0f88b65d29294bb90e79092a080fade80bd707320582716faff2e4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x839221e92f23da21c1bea99d3b76660b7396ad04fa4228ccbcc050b2a46b0a4a	\\x0b34d63146b789d3b1c10265fe8b6ce5f9965988bf4ac1a3f6e6ef304bf67739
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x83ca8bdb7b9ad0463de51f6b898d242a869d19420fa959c825614a31fd835632	\\x6b87fce8d50a9cacc42fdd216ad6edb247996ed18ba4b6aaa453dcaf1a196189
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x84161534be91a19e9a863c382522970672a939607075b42dbaf466464aa709a1	\\xd538cde7bd5cbafe5045525197ad695da9f2f6a02e7ae7484971a67a703a7e71
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x844ad6c99e52aecdc195c0ff40b5963e1690c453b82b6b58354ccd318f05e38e	\\x7379a376a20e5e183e855eea8fe22eb725638dbbb0c42d3d5f7a6a65f47aba7d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x848ffacd267ef7b6a07edf0c33acb34d17f77185cf7b5485e4fec437b8e89d27	\\x7cfdaeae48719fa99eb91808b75d4c5a0b7b32bc8c06b8fbd3444dfaf96af501
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8509b044ff664c736d852c4219fc6b1004cc775ea8a8077ad5977405f876ae22	\\x5cce276d81f6218e4410efbe00633c1cda08e2f27018586e0f5698305d25c23d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8529826f8593b53687c6c7ae8e1e7b2c2236271daa026ed3f3aedf03b0758019	\\x0a1133b35cb4440df3576a7ca460f7f5462deec401b8147d72f1fbed7ee8ba1b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x85357a12f2446c62d4d9a74d1064485916ffcca878c19dcb5e0f4a67916fdac0	\\x59e7e2e05ab671424824329d47a029a4e245635d6ccb591a5a7b2ae3aa5020e9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x85380968152f70929ad900fb6ab21075a9b1604031457b52aa0d0c0676670e10	\\xb52ae8b001eb3a6efc190e6f5a16975760e6bd03720d40b9e2555522ce345058
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8563fdfa920891f15430ba5434089033211d0b79ce159cc2ec1663d82477640b	\\x1e28c81d0a8706fb360c0c4b219727978efef29f8706c4b40115b0de2f670a95
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8575b35b23952a7bbb20824c5537adc177c2338b7f6217e26759f2263c61e477	\\x8bb219ae5918a2f0b654bcb9ab75a23005e13db7571eee186fc56c8c2442d784
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8591223cbd8962912a840083ea935f5a2b56526ca8479fa7c844a43bf541e4fc	\\x9a19dc4b79f5c12df6f7906829a7089282a45d7cd7fd1ac0de8cd7dfe5b888a5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x863caafcac84a6f0f1c927f0380c1e0277260e169f40ab39904e68106cc7bac8	\\xb29953a0963526165d586312ca41dc176133dc00a755ccac5f87b07e04604307
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8678a1204a1c1c9e4ae76b88b31a442543c91b680d5f0ee56be264ee412583ef	\\xa80e22d5b8a8f854c391e3bdb3743f12fec26a253791f2991413d5d06cb23019
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x86de69e07c95797c90b6c5d8c4aa081f7b37aea1e12293baeebeec3cfd4a4ad9	\\xe98d114e709b12d1af4586040686da662819157d0055d1eb5058f647467d0719
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x87014cf5b35037abc2f2a3c2acd902864ca8f16117b2a276cf35d33c1673c8db	\\x97018e59b393d4d81d24549d676b82da7f1f71b0c710dc5d459e5fbf5c4899b0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x872cfb0da6dfa6d1efda7da9c5285b6a14afa1191da48ed8498fdf3803e31a44	\\x855c60e4172782ceac0000bd3c3eec2fbc1e747758041783bf250a23baa0d8be
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8746d5a06a20691becb90ee17d1d10083b5df975db83e28d6f52b4fb64517471	\\x5d07ff99ee45d1ba47a10bdabc4ebf52472ec40e6291fe724a38fb9077f457bc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x87692837c223c16526d387aeb2cdbbc7ad2c2445c89c4b6d8405aaa33c72c77a	\\x0a32cc00c4ab2c0a4d216c180d55533b36eb28b61ab0f564f706206861d8e667
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x87811b5e8a5ae2603f5388939476a06622f1b926285c1daf7ddec01a0b94c02c	\\x808e26733650960a598151d474b600babf8ed40532483a0331484ea04db39e37
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8815e0769ce6113d44786861e24350bb580a688f56f1494b48b05b35175fb959	\\xddaaf95e35456f1f4bd12d7caca404eed4de978db3b535200d095219d5862e1d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8894271553d7a4f815ac6913aa86e3d8388ce4ef52cf06f8e0c80a4247f22aa5	\\x0a238e439c2c6c76ef40168919957985dade1ffd933fce20d246cf89ad6a5822
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x88a27a1b8bc5ea68ee7f618eca4733a8917b69638b4066417d3f87ef5c3052ad	\\x875f2a245fb8d6a57455c8d83027f16d6680af1ccf3d11fb57056a94a322de67
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x88cce34d76c581d9784255d078ca6510091415d3f7904159f2d743e3e4ecd63d	\\xe1c4219f11e2e023c94f65996c6551a1ceb4bfcc716e49d1eb8fe31bab9d762b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x88d8ad23f10520d1e749b07e8d247bd6f2eca1e40a3ed5d660674abf5fe37dda	\\x6d214bd90863149c3d277b8d11b43a4c4ecebd2a8d6c3794e793c324f8efa59e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x894d7cdccb79c3467c620b0a865d0282db13fcd15c46fe5541a0277b468cc510	\\x10b6cf433c602121696b9910939dc4ed8d369f69f6385c063c450f3f00550661
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x89b0998e4ebd3144333265be18f3b7079802408114c1600bb2ebb0db8fc04de6	\\xd40fc8eb2373bd568f584061f0a4238dc1c9490d32b437a5419a4384767a35b9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8a08aad8fd5b7b77cec2f2cef9ef099e279cde93f2b905c0d782782c4a7c27c1	\\x4504d8588e5547a5816cd9d64a8390195f90ad5be6d93e5317aab62bed251d5d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8a367e51ccd8315dbcf18a610d8d147d10731c585800c5b3bade89370744e3c5	\\x62e27d305876a76bd04c28672f92c0458c13867937f5455f1029551a3a8b880d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8aaa5127fd899fc077cd7858d88fd0771f022b198b425293a6bdd0c764ad8967	\\x956e0a3e220dbc54cf31a6693d7ab0d595cbb92ba8bba4079a2de20913ccc332
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8ae281b231106bdecff4ee477599fa4a64d9898219deb4e0845509c46c958f4f	\\x310508cdac1c6184c1d9bb0077000b34d40834fc73e3ef0f87522caf79390270
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8ae4c5f791dc2739291dbd98df92db80215407cb546442089fa925e71ee64880	\\x7977fafc01f5e8f862d865b31d0c61c57163c4ca87072931c795bcbc5d0d7bf8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8b0ce9317211f3b2fff23d2dab2e6ae57229356d94281f8f18a955301a80ede9	\\x55924e19ae5399b19efaf1e768e0d69fcd8910bcb08648e234a898ece94b1d0c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8b45648417d5d1c1283ba8aa41bc6a5f203544d7e2f62ff95fd52762db2ba4cc	\\x5410ad584b8a17f84aff936bd39f0329626198cec45774e8c9b1fdbd43f55ee4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8b5ecdc158abeca6a85b70cceb40b754ac95deeb6516ec6df1674668c379ed25	\\x0fb5744ad9d3b05a02e85569b4e7c83e9351a5ec3bb0e9e74f4836fa74f02bca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8bfcb63f617472676722f39129e2cc7396715fcda166c1ee749610f1bb9ea455	\\xc8cb349a978e92defa711f3678c8f29af7c4dfa5e4dabdae6aa1be70649387f0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8c0f17de5565966a1d82ff61213e66595375ce67a9df8b07f449652f3eaea7ea	\\xbb93bf3297af370870499aa373e2fac74b3f51b5deec2972c3170b2a865b18d9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8c1f7839cc30156a57140383a18b5e79e3803341f8e32acd3f01366746445849	\\x05ba39c91b5c5e33327831bdc37f8187b1745a08db81a4db425a3c42637d4b30
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8c979c609e602c63b7f21a27845fdc68523ca4bffd5d6de1dc8a92ddd682b238	\\xfda575d31bdd11c01608727741ad2b90d4021b8ee0ab7f091490ff93475471f5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8c9bb60cd77c528644b7256018ac647a7f8ce4117a420d088ab8eba61addf0ba	\\x28b7527c7326e3e914760a166401c4eb9a2d917125160173de7865428b52108b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8cd545f8a7469ee30e0295b7eea2cdf367939bf5c574d5ab57c0dacf8a03c188	\\x4c4d167f61eff9b9fedd88103343f05df6a40fabef29f467e5e0b880f538e1af
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8d532e2bd7f5dff9c253e65c9f016f9a2802fa4a5899824d6fda516453bca799	\\xaa1b864b6672ac25065cfc732a351984b344a6f8c4dd7bfe5f56b981bd79669d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8de0f61300ade1a1efe47677be2c098360fb46574deac3add327ea52e079b3d1	\\xc3edd28a393296a511e72115f4cdaaa828c281901580f7d16c51fc1146c2aff8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8e13c8a972b3fb69e1a7058e8070f81a0e20a6062d62e1b0a00d71f853d98500	\\x41a2cbaa330fd31925c7814f2dc01c4585c97dfb83cfa79d5df55d5db0635f6a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8e2ca710c84e5247314925bab04917c35b943885bc8964bdac7c55531447fd66	\\xebbf5cc3a0c4f1ab1b85cdf083daa33b5159caa57cfb062976e615861c62f979
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8e41810544b5c234458be9ce45f48aa807861e5693b9577528f31792cd91cd3e	\\x20708ccf7c68edaacd56ef74cf5ee75613aeb03a455e7ae92a7f600140801bad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8e6f31d9687ace6ac83e338eb0cafde8a2a8a2ba3e4aec2a7dac8176801e5abf	\\x000a93cc707652397a033a9dc4e8f584c47558c7af0bdf18a92c8cb57379a80b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8e8e891f926169e9edd436dca4e13582c80a798c68b5b8e178b6a34befe4cf4f	\\x3de13524bdf444a1d80ae7e983d77ffd92133efea0c49b310961dbdd3d31603a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8eb51028c1095b044b902e6c981f251755afe6bd17aee441831ed6dd28e71793	\\xe41eb58af0ee11688c65886a12dc61b21c02c7f03a1745e91b7adea9e4c5aa14
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8ebaf1bedae1ac43f102e33f3900bedf9aa7f8bf5b093336922490177216cac6	\\x092f2df31595d3821a30ba33df2df559ea80e4ee329f60afe632051510a6c3e2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8ebff4c970ce64e895d054e0f65f1299fca19d5566d8c9fd9a6853c794330542	\\xbe93eade2282a175a2ea67e2ffb45b3fb3579a9b76f43743fea764a631b69faf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8ef0aae54b8b16e11cf9f14b3ba65a2098c6b5055f6796660cd9bafba5482e8f	\\x0570eda329bd920004712c54d88f6187e7df6899c7582492d895d70edbffcd8e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8f0bfd03b903d8ff1c31f352fa5a8f8e3a4a1cee8885b240008beb31635bc38e	\\x6cf7fe653be9b26984643f51c33b798e0a0e877d4b23afb12b2dccb7f50af08a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8f508be4c3e5881875d81209a23bd07fc0963a05f9ad44af8bf63af35e2f5554	\\x58514ed6ce450bf00da8664054c8a117824570fc0727fd7dd645aad6112e7edd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8f7359c959cd0d203c92f14e3054eac87616eebf2023a18a79f2a8b6110cfccc	\\x4608c3dc853bd16ac2e06c86fd002a33964393bf5897b469ed8ea9210e95bc4d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8f75c48e964d64bb52281e026946fcf625552e498f6864907d0e6d8f3bdd6004	\\x60dfa7ce51e998f5ffc5766fde1c0ed3a904ecc6d643bd44649365eb86529253
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8fb4dae8c47db4d55ad7b84abb849f7652b9ce704cc1e9455a28be5a1389b43e	\\x9de9bee4ab203a2cc02017aca0928e62b517eb32d0e6f91cc1e1f39a1078dbd1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x8fc3e3e1a7c5bc02329516f88c8fb6584f9a0cc79941159a39928d8417bdaf8b	\\x3e0ff0ea2cbc1a91fe48efc610293fb22d140cd020d3a263df4a642d5c4409ac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x90017387f8669a4be3184436ea3232a562c393d461646840a72c323ae5bfe49e	\\xdefddff8d3dd032d7d3f325d81d9e60500a9345a89ba54278684f2127326e933
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9011357e4a681b89f1c947cb46f6320daaa5f5fd28459135b184fa59b1cb15d5	\\xd182e37f1e633cafee1598974f8ea1dff247b44dc1ad216a9234ec7c1d0b701d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x90281fd95495809f7b5e04191ad908570165250fb260f191c4de813d082fbd29	\\xe5e9eabdd8d65e1090e3730177995ad6997dcb69d6f990289424542d4caa4735
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9037c45ea763074d59e5c57e5ddf0a57abedac6270963ec83a1798b2121dcac9	\\xe1a058a920064d489afe8015174cc80f52046eb9ec502ae88ca04de6fab158c3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x906bf44165746906452bfe6ff17628e2a400b49a8ff9dcbb461c9af16397ab87	\\x6569d67a3f1d4736e703a7d9b64de8b6d06e2b11652815c23fba681cf21c089f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x90ada1b8cd84322412b98806dbd563a6d7c4feaff41fe1fe55910ecbf74d4ca4	\\x7f1e223d723801d56eb4123abc534ba9106b0a0cffbc5c019aee810201f217fb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x911f400970300466d7442badfa446edf8a3800061988b0b897f93a2bd3872879	\\x111582ae2278a2bb5963ff361ee1148c71e2ea75db9ba45e55e91ff2a860d4a8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x91371fcb3ec9bf9178ccd2a3bd17e69626034dfa5e6f120016fd5f07f6bd665d	\\x31240cd7de8e2ea876280b27d95f29ce38e4cd1e1e7154f92c3c26d795947c9e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x918775ccf5775b5ccbadf30f60478573e1ca01236fb633b207ced3c64100e0d5	\\x877acd42da0e9eff43c9b41ec6fd9efe3d7bc650a60d2c86102be56c52594a88
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x91b7d63a61f2fb42a711bea2de8ecbc5440c8041d1d3dd00c7be674d8370288c	\\xdd9a2ed3b91d605e02ac1155727b977486c26a9d43aa11cb4f0442200d73e525
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x91e02072f1af3aa43c169639a0cdd9a6b05000eb3e2c19c001fa880b7809979e	\\x95c6c548e621c8383d6739aab635e007d8b48c6ff86a1af2a5f2666caec275cd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9218ae6675f3b977728663ccf4eb825f135587e9d55911d4fbae37ba2dac9cbb	\\xf530b1bb4031fc2bad5985b4d56a7873a13faace4cfab9eb6972d9155df1774d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9218ecd9a6feb5bb59814c6d1eb4c836907e72bd203f64eb24f746ace84b555f	\\xab4bf193c56808a271c2246b02922d7689b81654257a45c70d8f421e4fbaf5a6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x925984178f4a8e2cad15806e941e71e369b00e2a11e9cb83e5847bf9284de0b4	\\x54cb4a2cc9783b7a787e895dfd14d45109889120bf15dd0dccdbf5872755d690
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x92e7cb338f6731be39f78a5dbfe03fc528a16de2285f752c0d37e259c7b2c227	\\x13d9c8dee0e504c42acef12ffc6cdae63ee9e5d1f8f1c9cbb47fa8e2398e7f51
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9315a16143c9ec5e1459b4c111655a7efe938de6ba433651633ad89220ab63b6	\\xdf7b6a5774060f42bb6c8d565aa7bb2b07df9b5d6378499024921edebff942bc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x931b9c2f6f64b65eb7193ebc77ace0db4342acdb51169cace3fa07b1f65704fc	\\x294a32feb69fdd6e6233b28ba42c35d99cf43ea8890fe59edb0683c283672978
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x93b466cfe6a97023281c608d2408eb044760f74aa791697ff3f4f967fb50d10b	\\x0175756fc89db712d6e8f9082fc5ce50c04ff9757b38a205ec656b89193cc910
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x93b60d39f3986cf0554c46b503b6273f7e73cd7e8a6cb7636a983b3208e87b17	\\x3bf5c251ec4a4ec20eb87e1061b50c02fd000380bb135a505f2dfe186020eeb3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9419df1f7e954cdef2cb45479a87c753e5b095d0fb6efe5a632372177c3e9ae0	\\x5a5c154ebc23063026ea337fb8511ecfe7cf59c6eb41ed0de6586485ae3b1012
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9422e8622e2a8f09292dfe59e79c6fa6bdbc4fd481cd375cfa8a6dfd4fde3026	\\xbea2968f07aaaf843e91b3d754098c8a58cad0ef7b148b6f08de90df63d907d4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9471e501d823c2e11947446ce44de4f621b424a2c357b1166ebdafd35411cc3d	\\xa266436d73f7148842eb42d09ab4570d36a4ad0ecfbcd5f10ed9b4db325d3a4d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x94d074d24afd7a8800def66316a92e7941efd7cf6622aa2476d69e59ab803e96	\\x5bb5ac4e4f857eb44875d7d2b1fa5da6b7b4ec83f033eae9ec4e95a9eeff1bc5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9550e1881e472da821a4c77c6541d41dbdccbb2e3f583dfeeafa1d263bfe1b27	\\x7794a6a840480d713111d3813e5ccea043dd6597718a481b1f0fadc61a1b272b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x956aec19a0f3d3cbcd2b1dd07dd48349509d1736a51aa99b26d25b5a6d29b923	\\xf00b702cf8c03b351d23e0e4da9e153b29c1d4e8d95a654bd4d4dec95129074e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x956ebe5f6cd60575185769a954cf6bda17562f957f68ee5b84520ad2ed83b9db	\\x64acb81a16feb57f872c28027f75697dadad223ba598c7b0c860e9887e980801
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x957a2bee8fe2e9756f4c1cf9aa0c78ade2ac5583075390c1c8508652b8166350	\\xcd5b75e1b246831b792172d66c22cafdc94e5e93ffaadaa2464f6a8a4b84003b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x957f170b2d2aa526d4ef7e60266e2f2efc8d05327329342ddc7144d7d8a8f33d	\\xb3733a25e3eb82ff486ed24821afc6764bd4dffff46bd4090e4e238fdb356dd5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9590af43aab96a21976dae7c04f2f1922fc61633bef640f4ad18cb457c3aece5	\\xb603e8ce0801356476cff420543e104a1c1214e2696ea34501e5483b74fe3117
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x95c6beab4480b86034c12a0e23c993da84a6f2284277733f35b815e49041273b	\\xeff3a0fdef721139d4f15867e111cac8d3d40a6a16ab0688ebc2012cd235efd1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9610812e30f6a69ed2784ad18f7a1d42330450c4c2052b37352b45b08aee52ea	\\xc2a7de465495f4b9dde4cc95de6dd47863397d525dfd2b54cec442d0f7c003b6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96449b1d0b766dbb951de0b8e16c3f9b986864165ca2faa0fed9ac0c2e9977c8	\\x9b9862579b3ecbb864b3382ed9824d4607907adf9423c4e04fbe35fe7eeac1ca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x966bc3a212d497ea8928ed6121afd3eb4fd116dfd28b9c7e7bec9cb94eb7c328	\\x3d917bfadd35af6b14125a942565c39fc6c2d26d7cce793b3161fb26a0fb9ac0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96799fd32566319521a1612868829f99ce66e55e07827d1a88500535d2b1d372	\\x31e2a95faf4dcb080bbb6445ac9c6a8425a5c5bb3f2152f588a30ff0aa0df85b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9688fafd9df9a38e2cc67f4184af25897a83a8b51e944273661b2383cef8e3a9	\\xda67f97f7d5b1ef0925f93e8bf79bae90eca57839558a3dbcb56d16de06f3051
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96929983dc3ae49a90102dae0c5533d594f5ff17d36bd7e33935b0d731b3fb4c	\\x84bc5b4d6c20ce4e4679f9ae0b648408b9c9804ddcd88b2a329a9738cb48dec7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x969cd2ef13267a01b655b14a089c8f213c77ab606c138941f4d75f27117edad7	\\x6708d93948730cfae1de0a28996cc699599a92d4e283049664933ce613af7e06
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96af2a2940920174391bfe8fd1bcbf885155bd52f18945b4613fc1c5f7e11725	\\x52fea7a329ea8edd10d8088ae7ced4e1437d94633fa1058e6e174992e9f700ae
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96bc336860dd988de78d2d9dedce8c0f9ceb795f4c49fa3123f1465b8f3379ee	\\x6429c7942e7b750e745e18463f00cfc84da3d25097149dbdc7f66988d0b91181
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96c82bad7dfe6f43d8d56c70d5cf1bf3e5f8e4762a1d91b3ed89e548808de77e	\\x82e9ac8d88031c678333d3e9d52dc267a6a8780b7c6c47438173ae68564ad3bf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x96d2e25cd4fa2cc0b7f30b4763a64f145dd19cc00fc4666d6e3a6c881c9acf4a	\\x06b49718cea334ec26591f5dc0af510793abf676d70f7a5b96d58b070f25c5f8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9725f2fcfb437b1e95fddd3ef23d2093b08c230f539d431a9a3dde74e987fdf5	\\xde46219522ae775c0d7642c2b0235ed72bf963409def88f0b7ce9bf1290fa393
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x97a79ad73243c0655932efb22285a80c6f51a3cc9d4329fb4e35cca72ebdb58e	\\xcf2989ba9364c0cbe032c063b520d4f79cb659c71756bbc5c038b72681dfb736
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x97c359eb9636b38cd39170ec401abbb9478580f4a12ad160117fea2db43ebbd6	\\xfd424265cc56cd5b6a030b72c88bbb3ecb107d097e26cb6524a782ba60c240ac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9808fc5021b3957f03653d36d64c6df81cd78e636eea7beac82693db4fd4dccc	\\x938dde735d70e187e0dde19cd3a22ed4c1bef3936ac009cb6f8804254479ddd1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x981c3c0605c0f983d0cc2be4da204b5899b6ecca5812a1cf36d76057d3dbcb8f	\\x03dd045320bed811845135b9e2ba3663b24db8699733817d4155ec46b9441fa4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9879b5ad7d7200748d23fcbd9e6914e6b13efb7017498451eaaff2011bfc2019	\\x30e7ef00430b8ed8bcb7e7d85e34d6d0b964228d7f932e726b4359b1e96cdc17
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x987f6e455b1e0eca5c49ead2723cadfc7cd27f993cddc4ad639f3104accbf192	\\x1926e0e2b9353abb73a99dbb44e86cde4a353d980b0ed3ead99266df79735768
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x990488e94fca4bfcc0ff27d92e815210555fa58938743f941b7acdca3891fe01	\\xc7c77be32f12d80fefa04e8040003ac34ee25aef808428017925eaa35a6792cf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x998b4420590f259d5e2dc5b9754481ea50dd6b73092b51d5c92073a2e831762f	\\x5770a8dcffc4a7e2c73bd8712a67c6e16783c8245e91783fc832dee2fbf2d527
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x99a5121702c62187b3b09d1dfc7523cf0b185b7634284bef71f7d5be5cd15d2f	\\x086615001adce3b145e49a8e76df7ae1b17b97374ec121e70d26cf4e4110031d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x99dc4cd2e23cfd280a36a6fc1c1d1ebe6f3f317181bd4bdc27972293aa2c68da	\\x774bd4f2bbe57879c018508d7cae9b43e0def87a10088f4fc8871e3e3e8da963
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9a220c943c0161b5f7323662bc4b86db6c7e2fecd1a731e07ebef09d9593bafe	\\xaebb9ad41ca4160d5da3b59e4bd2c97ced62757476b044239791b535162cdd8e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9a2e15f9b56f3cbad7883ea5877afcd737c90fde6e1e32240b4daaf6efe236aa	\\x3c91826926b77c5d6090d79f0e5beb856d97dc83bf511e3e129df3a729666cd0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9a5aa8aa8a551fd6d034287d02685f9a1175913ddebe4432bed6f722de394a7a	\\xcdf7fc53651ae8216461796aff9385725dcb1dd51746816c165ae25fc8717d55
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9aedeb94b36c77b3523483284f719e6ff789124893f041d311cd2195d3d97404	\\x60550712d17703b04b8389ee3ea0654e684674402d00570e04d77c357f5acf33
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9b2d4cd38336838c568d8df38b514008af039246a10cefd419275febfb315d85	\\xa38ce32d2274d16c0954db27a706800147c4b2a35a340ce13d022534a1e38cbd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9bb4976123a7bd0425385a9fba862940bfde66890cbac5b5b62730aaee985759	\\x427e86fd80cc290fe82ff9c296c742b358e491a371cfc096b8b6425184494ad1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9bbf4676af8769dbfd21499edc48fe4ebaecf7581954ed49bc0b22ed1b7dbb9c	\\x7842bcc9a460004b9113e6402a71d39e819003e17da51912d47c3135d72e8d13
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9bcbed5ebcfd4564ae1bc61cdab3875d02497308f5952a7a13fe3b40f955bc3b	\\x514268958ad363c0a5c80e62a147099485c134611d6499e2a987ff6f378e3e3d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9c6d8d5bc7bdb1b3df1f341e215f6162ae878e4dc918d7d0daa0d50743fbaf09	\\x50b68756a72fa8a6d0a6ad372facfcab0879313ed476260fc62c8b86b87547f1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9c88f77d5b04dd92137bd56deec32de42b9f3e2ac20b349675d93f02652119fb	\\x08065ad950ae19e504c84776a13a4cd0d79afaf22f2da42fc335774266417af2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9cdf7030bb7f6f389aa37a95f60b929487c55d1bfeaa2b30a1747a863b034b3f	\\x7f24cfabafa52e6b9bb7d9c5dc2f5a7b300b16aff42ed91c7c9f8944faaae341
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d0bed44fdbe1f1a91dfc730fc5c97f23e727d5d2c704a249ecd564fce9595ea	\\x3bac6a0cd22b0908149baaeddbe6f3bb3d39edf2e93422f42be9a94dfe3d2b3e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d265deb4b10ed46523c3057c4b22d1f529b7229cce9ba0beb1093eadd0ff9f5	\\xb32dc1dc141c4493cd9b8d765ad13bbc2e3c4f575b44b63f4c8b06dbe22d1c52
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d40bc334812ba4a2e4649a8e7a36f4cba391d9ed1b7bb37bbf6a309499656a4	\\x36763b546dca52fc1c197d88865057eb0d63fa6aa90ea3238ed061e493e77034
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d41298576df62d0a52c315537a46112ca16396dd2ed88d0271a7c0f5ba67166	\\xa624f2108ad88636053de6608b4ee6668b4549241bef095846a41714869c762f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d46ec6f1b1abbdc1b01ba13a500f6d64caf9dbfe4e5300830785487179ffe81	\\x85ccdb13c0e32f181bc53a4fc274ffed68fa2f8383eaf79a11e18d12b6a7213b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d6902f343bf56466df9884626abda92cfadefbd830ce12067d546c277bbb737	\\x1fcb527a9bc7c8c5234d61a41b7f9a14546aa9ddeb507cd51882372aacf0b824
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d7592eb769d71f2332b388c8e3b10ae1858142a16a1ba5bb59f256bcaa759b7	\\xf875b6285b6ee1f9233762ba66194276899aa9787838a15bc1c395387eda50f4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d7680a3885a2217d6678d15e232b1c5540dbeff8f1d36797ce7fbed9d35488f	\\x7c5e1ad46b9bb61e02892b298b422e92aaad562e9a4fb3de37cb1ff234223932
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9d81424bac6e946880982f13112c51c599185265a3bd572c6ffe45484c21dcba	\\xf9cfb69f0e17c31f4022329ea38b6f93806e1113a0e40bb422f4f36307863a7c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9dabb3b02ba67e675b74aecac5329ce3560b7953f887ce11513a175ff1a8041b	\\x742266297d96b5a1a2e49f0740345d992cb4d280683e26cce19da313bfdb098f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9dadd15e9d03f152731e121bcf57deccaddd9d15135b364fb95c63b5744664c1	\\x73187d9d006de30dd44a221cb2bf166e365b8e2105a5af1932548d6d1c290a3b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9ddcb6abb0f69239911af3116e5f9600063f6aa6e4aae9c4378bb19a07dd5e15	\\x679c7cc75e1cb39e81e0e737621a9bb37ca921d86b6a0f9958c96eb674e2492f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9e0e8558d4ad439ea59a4b7053c55325828bdf3d7a0d3d644f88efafae7c3ce9	\\x21c85b773c10de20ae7c5e6a023623cacea92bba3c9f27ebfc853d9b6ce1cd77
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9e32b57401cd54af1f6e8a870f5cf6bc7efd6a8bb9c779efef5ab6980a94d6e1	\\xc0d96f17a277bd756be260ab6a90c386e1b1ad0153ca5eb644528e50d038d765
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9e3b6d0d73582aa0a0feb7e800006a7e29f849048b520daae6bbabaa12f4b85f	\\x38f2170848e8e94175db473f00022a382ac2173b8301899222bb08d40fddaed0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9e74dd769494e36d5faa7be630b6e26bbd92b72e8724999249407f1ebefd2325	\\xf51c26bdfd0ecee7e1b52dfc61559ad64eac65757bfbdcbc701878d45e9c4a59
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9ef49c15e97688566dd5a6e59883e32fe26d6917058676f5789986ee48ae6778	\\x328e9aa3836b96a01341f4ca2f5254ddcf12efa5e70158dfb30bc2d656221f69
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9f821fe86c37da430764a349fe8d0c7ae581ff6479e527a7628f88813daf8434	\\xe868cbfa6b9fa321ddaf194c7f47b1e7727d27c30940403784886ee2665871b8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9f9ca2a68fc1e02410f2654cfc144b46a5352194ef6d74c9b8308848f5a73b5d	\\x13662d4e2b99263a6bdc9cbabf7d8e042d11e6ba735001f0b2de7540782d6b24
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9ff410d30dd5667a53524922c54d1d6de927d8f2899a1bfcdfc9d3e45d7e4141	\\x8628822b318c0a750a96773374d4cfa3806af58a52f22ae2c85904b3257f0c64
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\x9ff93a47b9dbf62a758a21aa40c348494102f099e1fb5a50a6737d0eb80d1da2	\\x8e55e8260261c39bb8e50b7be2728a03cc6cf69166a8a45bd1d8023f4d3e0bd6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa000b42d5a0f6b22781c6baf746c2c0e82067e98b5fe98889f87a98cdc45ee44	\\xb97f381b791d5f20a85295086b533aca4e6ae093159bae26c4d8e337aaa82436
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa00ab6d69f9ab52b2f99b09a604239256271e8e936e3f624d927aab54291ad72	\\x885cbe5be9515fd961d45356291c9a1ea06a58abf72ab4d1a413ea840f8b9f22
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa05ef3f3ff850efb08d4e12501126353fd7effc8df2a076cc335dc560dea2f72	\\x7a87954f9204d7d3319ac203855fa2bbfcd715d2d4702c05baffa8f6afcda2d2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa138d31e5f36eeae3a729fba233e81647fb138873fc6a9fd7a5710174f3b736f	\\x0e091584d40f5b72411e8c8c805778619348005f040b8fb01bf4d83f05751aea
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa168d2e68c847454dd613c908b3daf5defdfe3a24d1bcaaf2114df35de9dbf68	\\xbeb8ef5886e5ab7d37c154372682218ddd43be06bb07832140447d1ba3a85c3e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa194b6852f821eb5b1c17d130ec7e3c6faff5b0abc13c76b96cd2f3a21f2f2d5	\\x8114011ca1b1eb09720ca35dfdb13ab66f69727acd6c52b85b4fa857c498abce
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa1cd96390e97e2a0ab2d002ef18e99767a27e30797d255f20d3e6b20c42e3166	\\x284457974e692cc2abb0c537d297e08c1dd138b412c44d6627c921b07dbb9082
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa210eb662bfbe3bf96f379ddb061c16d0ad99e99332263bbe0c33ca80ae440bf	\\x9265028eaf11473cca0f8ca63d17a9120f9a62c98bc54e29733a123a8d631cbd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa2468e14451e3830e43a92743dcbe633c010f628073e50f30a9a84d0cc90db3d	\\xd1ce75de24e56a1e1758c0dd8ca97aa37189a325813ed30202c3ccd5d7f38325
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa253f6926d6066f7deca80f3eec7406fc18e1cfad88e97a6673ed62909d83bcc	\\x47f7820c6fcb6864f99f800088d2bf0b04529b8e21cb78b41c5e4af909281700
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa29c2675985d1a5d4c3a5bc7685a596335bd6f9259d89afefed69eb02c4faa42	\\x725e481d006ad3f3c4dff4377ef55de1b27622792de60c6857530afc018bd725
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa313324846d98c50fbaeab8a6ab227adc23d1fca2cd793d9974217eb50cbbef6	\\x68a86e047bcbd369d6eb6eb62dc7ffda35687059a4c37d6399f1a67b7007bf69
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa36aca8d46c3ce9202094c4625b15c3c32811d58fb489c6d8ccc45fdbcead134	\\xd4625b1c175befdee53edb70d81004466b676d01542126d12b0e8e7cf1e5cf20
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa38496a1737b86444bc626864b5e0023e163d305d094924be7af4a8ced4955ac	\\x4b09bbdfb10e567821199b038080fcde040c265316ce4183d2857f4e1476d52d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa3918bbddd208715ca91832ffe5df813b5902073d05e5df599ddf1bdc5c941b7	\\x874b736b38ea35635e2bd7f3884c2e16165b30de7c9eba94395af4686f2123f1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa3a26dbe29013947dc93f6caa5bd9119b2f0ce02345de0444c79a45b0be6a3b9	\\xfe6cf4d7079eaa0f2d3d47773221fc813b42826e727edeee0a4010cd5929debf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa3bb36f8935694b4a4a35441a4401c9c231c3e1a7faf1e9cae39baf7086a253d	\\x2caabb3520f6e35f31084c6b4b6f1e9bc92b7e38d107a4cbcfa49ac65760ee86
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa484df9ecabbe707cdd7aa1a61ed06894a8dcd3e4b57a9858ada63b0a33651e4	\\x8afe8343e9d004afc080d0ef1357454fefb9b4111c1047801a15999a6a096543
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa525314fc76456a069b67476030ab173194bd27722a74f582eb7cf23fec40d63	\\xe459d3ef7187aed8488ff3ff00dbccfa4beb7c2662a8e6cfb44e1d61157d0b5c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa550e13b923b2ca1421d675140dec8ed7a2181ae4ddfddb3f34f22d3a1fbd056	\\xc347cbc4e1d7e153bdee46c44b5d8fffc830cec12bc0f4d1fed8a6df271f8a48
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa587b40eca8a2235e2c9bbc38e420421c91aa045561fd2cdda58c23b61229e4b	\\xa142939a94f33057649b908a722568dc7b58ddb594242123ded1c616d3434ce8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa61165800c74d5bf27c2e07a003dd2694bb708b76d861f73f17176ece75832c0	\\x7589c92b3f5fc9b64ea5ec03e07f3e118bedb4e6fec54e764bac514826eaea7c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa61566274f6e8f27052783e74ba65ebb06efdaaa5bd1bd023f4962af9acba2b7	\\x307197b663847fc433ed60f3fa2f731a54be29bce50ef1a2a401503a8eda7a20
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa64d8e1238de384d4d8d6e3be9f7160474daad6ddb416f27c62c2cc8c1583e78	\\x4906c5d73818877e051f8aea761341bc2f2d5d6f86bcacac4cd0552f665b9aec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa6537697da2cbac171d71e8e885b707cb4a8b5e0a7aedb2b8448bd1804a1bd4c	\\x5b7163ff8f8db74f6b4a15ae6d2440fa8e36f538e9278984bef4f9b4c056b5b4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa67b97d56c2dc53c09f9824f65ddcad20ade3bdb0879c7671fa3ad1f5114ed40	\\x1b0cd0941e6b11ebd0e295e8ab19556c0b745efc0c342cf5ac3187f4b614920b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa685a5b2e649216081b97c4b898828f8907ae87bbb3c8a86b00b092fa49fbdfb	\\x1264834e7ebbc90f45be56f3056654724de45b3436a6a9e2eb3105eca5ea3283
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa6927220b0d3d3e7b08ec8d44d19d8490e9fd40446d1bdef7d422c4c36e8da48	\\xacee6c8e4964449d60dcf52f1ba61078a8992633962fb30a699a55db577d49ec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa69cce3adf9b3c4cacfd8ad898880de5403710dcdfab012c7307f11f310c9a32	\\xab5033bd6f0f3fb4b851f7389ac59d8b1f34541183d24c82606116156fde28d2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa6e5b25306a81114c6d84455de50522723c05748682d9e0bf4b55ebe135e5127	\\xc44acf27baee0d9c3a2500b3c255bd26b746c2dd21759f9938888fd3cefda8a2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa73631efb70d5ad8d89424125302c4bac53ebadbc7508e2ca1be8b3e2e7fb1cb	\\xea5c13be5bf0911dfbf811033091e62af6bb9883f53e05cf9eaddde9486a97fe
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa73c7468b368030e0fd96f1abdffd95f22b7604b093a0e6f07aedf79f5df67cf	\\x6c01227cc2c9e94caab77640d2b4b4ee8c8fcf35ce2f5107ad0524adc1002738
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa77fd2a31fd3cad0922be4950b0983ca78b1993aa9757f53b0f7a44b38f86e4e	\\x8be2923619dec5a31c6ef4e1343d8253bb736cfae85c96a267523a0a8272124b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa7822b13194df7c287010e64bb14058fd6f67162f7933c1db699a40d2e143982	\\x868a3161611b5959e8143b286292fd91f96b1ca12095b5ebcf14847a88f0355d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa7ba3b9b4815d275df46fe361678df9c878ebb71e7ebf5e300ddb949414daf2c	\\x250b70a3ed5a7eaa6cd610aaed933257407eeb204449bd63d41eb76e6247068b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa7d449d51d7c7b92b8cae4a9b51b78050a08c64e5ddd3c266d19a3d4f1c5efb9	\\xc57bda9be46522878517b69d710111037cfeb08c1a3da2ad3355d48edb7437cc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa85b885c9be88d6978ce59cfe72bfe7a06cfa31abc85120ae4b10d3892c760a9	\\xbcc5890f01bb56d1a1b210a818aad6a42bcd9617b5e9181bb99d9c203bcf72ca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa87994ea13ea67f08502e1d1c7ad2d623b47c535f713d944ccb3f5827ed36830	\\x550cd22ab79cc47a5362d94bc9d9374f193c4a935207e290ef004112b015afc5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa8c46c27577fde5d6fb5c1a2847b014534433a8cb298b25273db44df91bc131d	\\x9b5bf8e66ba172a1754fb4777330b0087575a446b0588b03de8d524c71a7f845
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa8d68472ce2538c50c386f6bbfb6171f2f2bb43becea078024af0095fd65c366	\\x2ce52661083e238aefaad16aacddcd64e4c9361c45c44b15e7488a99f43e1b30
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa9046771d9edbc746cd45a95624c995ff2aaa390ca509f62da01fc393f90e054	\\xee07ac3de3a1efc1248084716ef8ae7648f4ff37add87004b5cd80dd602bcdec
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa917fe5a3a778cfdec09b82e0e226881852ffcc6bca89e03dbd0307a8afee9ab	\\x5d71948c541073c0f02b40caa7253924c0b8846560ca6d084d38313114da9720
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa945537282a86aa2d0da1a5df95798ff0748f87b940712d1a6f43d38899882bb	\\xb72e9d4c80d3eeefc2948e5d79197ac18c7c4675a19191eb838b036ec5be3e59
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa9641fce7c6eb3210fc26aa5239bef7f2e8569233c1417420ece2baa9ddee0e7	\\x451f540dd685179ad8717f1779c7c25e7410b61b7349392d1274344fb46299cb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xa9c1623b9694d57dc038cf4cd2b2aa8ed417c3083ca7dc543cd3a9d5e7fad586	\\x6944a1c214e37645ddeee55700a734823a97f1c599e94850e99fb180a2ad9974
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa1d6be6120ce5fdbf8942564934a23da97e5da799e2184dbac7bb2368dd36c4	\\xd8992e62469665f5beda3de1c96b927166f0e6b6325f574afca04167488dc793
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa2909cf4b9ca6eee1ab978fddc4f86d205b84ada72a20a526bd47eaf8aa679f	\\xe8e990d52f467a88c79fde1cc94de01ab0bc50dfa25359e0c67d849e3d07831f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa3c62bc9de8a6cd5b95e6e42c8682f931c8063707983862acfdf591585a6044	\\xf9188ce110da9e503d7b6e23ab6c2a6d8e620be2bed40f4cf122fedb5efdd386
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa49ea2bfb91ece6c5ea0b74b6a3a16e83f9c7d6d73c0b8238a8a9ec65c35df7	\\xdee513af67dccc77a03442620944d22e5b3f9881e63bb5b0ebc08e9c3ba6886c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa6119fe9731fa20183a81329f70bdbcc8b9d847f8aa86020353078e7d309d04	\\xf18a90e1782589638cc37334b11a20e90f6da839deed61309faa30fd85cf0fe7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa7e7ce26b61d5513174041888c90b7813a276901f6f77a07f88425df5fc6307	\\x47e82fb062e56380534e4a3593996bfda6a07fe755b55afbce7c7f25abbc2681
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaa81305110c83d8c96546cada99a3a2a7f21a8a24206a28ffc9c24aa8a3dde86	\\x3edb3098eed4506764e50c81272243fbf1bef7cd8f84e8fbcd56dff6e2f222ee
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaadd7107334910b1aeba2c8a60aa522ba187372ae08ef0d2c38771df3fdbcc9a	\\xd86fbee613ec82fbf644bb870ceab93e9920baf2ad73c53088af7d2b88e8ef7c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaaf9d010e033aa8b2ec4eeba12ef144043c5bef5cd511b44905d9f6bb80c09de	\\x1712ef5ae24642d90f6c88c46757953c1f0e54891e26f20802a95ca5abd05a89
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xab12d261fceea9278688eaac31b871cca1f043260584e075c66b72dc1ef78bcd	\\x5d7e8d02f430625bb6aed45dc12e43e5cf33b379ebe4687480d3a89f436666d8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xab1a4319bab4a7570c4ecc7cb2b373ef0f7e02411551cb1f0e94757e2c784b3c	\\xef3c87d9e254ee439734d5c14b81bb00e28ddda9651f113e51cfcbfea8f41e5b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xab2446c359dae7be8bb94f93a678843a49feba3147eeb37f89cdc13890ae99d5	\\xeccd09638232c6edd71a76fbdd85f4e468e172382f398162d8aff889c372dbbf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xab430fb5d713fe33dd9edd3154ce2867e52ee1a9fc543869d34dc4fb4ff6ec3a	\\xc941654cf1f6a5fb01dcc80fed7a8b5ad41943351e8cae6bac4cc6deec499577
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xabaeede823c763807867e3c11a74b0c2c9abb2ff80e4cc0bd00151a9f4493aea	\\x262b7be4e39282df64c5f8363432f56926e01fce45f4fa9b42f99d0bdc679e53
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xabb66bab78891003b68fbc2adf9ab09b19e3cc715700dcc5eb38426162b96186	\\x694ccfb4535dd4b299a754c6ce213d384a3d9d3fc20e70bf535b634dbf104d93
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xac48af9afcff8f96a738176a4aadb834f221c539eccf4eff27d70f3a07d976a1	\\x4bac6fad074e393828230abcfb2a602b30d4dfad047902e4204bda8df9557961
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xacfab91d2c98919f9817d5a21e13b33d9b2d7c2881d947cea626cccfecaafa94	\\xb079646e7b913b3c21a7f15a0a969752793bc25d750185a168583e3a550b3fba
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xacfd979fa83887ffcbb32f85171024717c879f2897dec516e7ee8b8edb3d9fdc	\\x463d8a4f24fc8d960be3f6e1fb4ec88fbba6bcb99c5413159131cb69ebe6b1be
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xacff5e01ecaaef36880ba6e07591cd117132baf1b63b729757b00e6d6f747cf3	\\xaf601e1712e28093e07377757037b64be345303592ce80e0633a1969e68cbe44
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xad164b5f577114cf60f8748bd10592ec5cd9dd948b96b1fd1167cf3b79822a75	\\x22ca80f2eb0356b7e13c528384d184a5344429e7330cfd5faa3323234604a4ef
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xad45771275cd20d13970ed7e6935417c2a5da4cc86bee46f1afbdbbb44b41841	\\xfb43fdb4334b6f593413c87b4d0fe363fa02ea5a1c531ed2dd44d3e0a7a1beb6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xadd3ec6201d1587ae88245135fa5ac8b9b06550eef8e8ec57bd789efacad9771	\\x9d23b44b9a955a96d8b4231060b8a84f5acda0212953f9dc3391abe2255356b8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xaf26e250caa48f3aeebec86a21c9cc67b58872db08fa7c9713ece36b7fbec9e1	\\xa8990381e32f4dbb8b5dec8c3fda5c1278cdcb6c9003888f4bc85f399363fe57
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xafc9cf876f081210b44b3771d21fb0e2837a73146fe34fbe86491339f715d863	\\xc5927dc541108a41222c0564ae670f4356872f25505275ee36950e1f8c52fbca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb00c5ed78ecf61a524f8c558e5eec62d12b4d80544d74a82faa7eb64c4c65b29	\\x724ff60288ba758d9a1c6c8e954a2b1473aae867b4963062df258e04b576ed46
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb08f973840246742a7520274cb13338e27be015ddb0761ad042b36f4a716c012	\\x2203029cf1872d6c59952c41bda04f64a16af8c1a489b1ecbee6066a38cd818e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb09757f123a63d334e395a201f0f84d7f8659575f97ce4aa1f8f9258c362f8ee	\\xaeabb53cd33800c38a1fdee45f1cefff7640792eda5a28ed4372e1a308e5b186
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb0d32d8ef27b5d91575257c127584d24190cb08902f78b42e297fd47516c4ebf	\\xf0bb5063b6799e857b4855e5569cdf891e07e063886b47079537628787ef4f6b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb1527ab2dde6029f82025f6b9d0640166fd35f346487571198bd9e4fada64494	\\x73c7bd9ade2eb368c2796571b23a2149686874587a19acdb353740753638a47a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb1997d4b2172bcb573ad0403326032a795ac0e43f9f1cbe46d121e74c2d91ad6	\\x143a986744ac1c743194107b612a46362b8ec681a4bb66cee0e7b407675ead21
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb1aaa46936c93a2fe308099e4d8b7b80a5a119ee02f3fe632e95f3b7b07a43f3	\\x86e906e8d2181f5921ffbc99749a437070f82464ab40086d8b0a6629484b4dff
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb20ce0c251e58cc3e144ac44d6e84ea7cf5732d8ec0f54967c6b581c6b686b4b	\\x0deee20023ae793545b65065735064dce719d963e97f8ae327d931dfadbcec8b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb271d269eaec469488d29a2bc334c7c2946d57e75b63665f883b69fce55c6631	\\x1decdeeadccb14d11703d41b40cce4152aeaa3342e2d7f1331a650d6d05610b8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb2c317752a2e75b76ae3ef107f99eaa7ca8cf7175d592718111d4d455164a376	\\x3cf6a847d8495d337e8837dab187648150d53d135a358bfbf5a2880fc7f870b3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb3f38f2c182b8f15d4513413e67dc6634541c46eb240de8158b9fa004018b82e	\\x0efd2958c077f0e2d9071d411f43b8768cb795060311bda8e50fa2af8a0c7b0c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb41bb93f1415127b3f18d06c61ba040f01adf0ddab46c6beb2c3ea619c13b5b2	\\x09e06dafaa3ccc6ba161ee1d6b1055623e97acb9d91058c909dc4acc347014f2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb4701305c9bc95a9038cc563dad8aa8e37de33154850af643f9bb64fa4957aec	\\xb5d4eb9494e235b7568f064e57aa167bfe315d202fd591c574bde9e1438fd834
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb4768c19111b289134af45ba7c05861b160756c1b5b62645b9a0dc1528f10331	\\x59100f6213d9e0f93d2012a6c709c4932b5fd74d576fefd357c4fd1e0511210c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb491599aecd2cb588c789d1cd74d45e13732b136ac6fa468079f7c2efc4ae2bf	\\x682330c9a4ffcf7b5e4269d60347f50178127aa62601fe5d2b8398e07192cc4a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb4a8f7536d87d0fde1eb49c81ae28811e63113c80922fe2e4c639452cb67d96d	\\x2512558a514020a2bae72dbe9da30d07b14cabc6a5c3662a014298055cd3f41e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb4ec711ee43793c74ddf3d170a1d8b1e5477426583d1e23a73011420db5e3e24	\\xfe55e923df26d50d313607599430c456da62555f03b8b7d5d9ba26aea089a6e5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb4f163a5a80fc0d142365a697a90c925a0bafded4f7084bb9f6f7049fdc6293b	\\xd86a636e0498d90c66b4f29b3d9827cca7589d9fc69112e8dc80018ce39534fc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb4fcb878e8882f21ccbfe8f100159709bff422b1ee06b7b66c09d56ff936aaf3	\\xd84234693aaf6185c2848321e97a787c95c5e10378cd64a8b2e865cd477bd2b9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb506e1b763c054f6542bc9d36420c83c8b9bc09f5e6755c50a28a08940489e07	\\xb415858e12c4acf60a2a174ae13449598e1d0d6425dc2286bad2dd56617ed0d5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb5418c475f9f3e9b772d5d1a7ef321d0433cdfc86debb7dd4c29889ca91c2fad	\\xda19cfce4caeaa536127ebf7d3ca0224c345d6b926f9a3509b41f645b312fc70
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb5478c5890a69ddb061f6b3ecc91e75457f36b856762d781595b34a206437644	\\x36a6b5161c1507195cd400e4ce3fec90da5a7f31bc9c6bf546ccf5c106140d6b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb552913dfb181d8453fcf5aeb24c9b71c921046263ccc53955a55f8a5a8c9c44	\\x93264305e6f7bde708c9512b3acd36569e2282debb05e85818126190993b3b33
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb5d7d20c512a82daa7b6046ad914dfc2e46fa96e8645ec2ca0d9503cc146d7f4	\\x119d5623e4a1dd209aed2ec20c0be3f30adfd949c80b4bd01ed190903197ab4c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb619a17f59adf2fa555dbef19098d144f7d8b7329380b8cac262ef5e26cdeb53	\\x62c16bebfb2518c74deed74c0d9e17b412ca30dbd64225dacc5280a474ef8f07
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb6272af35c2f3c676f33f5bf8345a65c82ae3c9fd463bd243349904517d75e23	\\xb4245a01c5a66ae0cab5a7026875be87cd4ccaecffb5f13728ca490ed9cdf6b1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb6ca3ad04408ae72897be0151b4d72b2b253513e5516c4422eddb655f76a0c19	\\x6ff8640e1584b159f3edc4bd93983e41f10162ca1d0bb8af0099e1fdcae73d8a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb6d3ff504b21e562820cfc998267392103f8495fda3ddbd6d8c9841ed757f9ee	\\xe1dcfb109ca976a342a647f2b76cd154be4576c53b80461155c09183ea220dd4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb75292cafca9a3683fe46b7c392e4974f2e17bd1e8d232e9361eb19646b6432f	\\xf9bf4a81d1598d5394d3090d7d76e2ddffd9171a37df0bb26d0eda7abe31f8f2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb8205ec20a31a2c8dbbffa9881b1659d2327319417f21fe982c9c13430799416	\\x89f8627b026d0a9747f03e9d08f1ad1d3bd873951d5f3521fbb907dec02be7e0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb83ac9bf53190d744d5a864c6a3c473850b045ed5a41d16c922f513329afee34	\\x92c9f4b51e018fb7816dc63ead29dcfce6c5bd52d42380452b053d6076a938a9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb87a7f3c727ac42a2a5a5a7e7bfb5d855ef6ba9b6ce4392929d833837bd3ed6e	\\x36764fd38fa3dc6941b54d1fff4088e5235230dca3a432167c4b98351b85961d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb8a3004c6843332e18c3dea13f925c73af52c43f5a4884c793964846bf4ce8c0	\\x7bb6b2f511aa65976aa0445223ad00a5de25f151e3e6e2f8e4348c2dedfa2c0d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb8a6d8a715c72e43a6cf4610d89228cc8a168047fc85006a7c00db1834f0449f	\\xf8f4bc571a0d6823507d0691d0092c07e604e557889aedbfa5bcc68dfcce8d62
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb8a735e14005078eebe2f4ab20ba02d508dbe28f48b44fe2cb4ab429ffe67404	\\x7900084a458d847d8cb1248307f4d0b291f2378b4c63183ba9a62b03737b91d9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb8ae5967b9fb51d515beb6e0426f80daafb547ffeb666abfa39956c58a8a0586	\\x491710e19051ee4026aac26e68282d5a4b6be3bf70982ba119c535f611f124b8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb8dce8432fcec414d16a933fb9d893f739f19f23df72c9d82663844ebce3f18a	\\xd50a2997ea4eb9d52b4cdbbfc24514559df92e208034bec8d29c1e0d032e8016
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xb92d3d64c3e3b64975d4c51e1ac56d3215e8d015344ef12852c866c3441e78fa	\\xf6ffac69b586be4bd54f2177a33eaf58b71a261da011c206c42911878a0c662d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xba36bf6f47455c3757bc42fc09b3142a1779fdd5ea933728eebc462b037484d7	\\xe51d722a95c662fcded17e51c09bfc32b4421444be16af4f40608c42248d7887
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xba798e83e8d818fda81cdf6909c88460414df222a9ac0e5c34eb845ceca6f779	\\x923c0d693bc8eef3e27cb6b3a730fec8232ea8c4b0630e79b4e35c16a13de071
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbadbe8543b91ff8c759fc3e2732507cbf39f951b4d4f3d8d60dfbc56803396df	\\xfd904a339f06982ad6d85a42e4a0d2b7182c678347bc774dea9e388feafaf1ea
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbc285e924211bb8efe4d39b969de1db7122861cd74f6fc467276ac5af48543e4	\\x57a4d0dca31147c69c3b5153e3e0963ae27a30337e9445933031671de2108520
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbc4e022f04660658cf359696fc7283717f673cbcdb3fd3f38b5e89acae36ecc1	\\x74873651be18c8ec436abd3f327c857bd12d260e79a5ab37ced55c52a0152915
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbc8cf802cc867fccce4c9d0e7121a193d65cd03f21c1347cdff4e0109be82d57	\\x915520d8420e5908b56dd2f778e135f7571ea56dd77189a49fe4efd92ba2ab6b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbc9707c1fdbf5e82cbc641c3910c1f6ebe4ace0c8e0682f6cca30b38b5599f57	\\xb6a4d903bf500483c0dc0c605664484acc4a91f07a579de1f1289134248fc0c5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbc9ff9b65cbcbb005edc075b040a1df7648df3046a5ec7e1e5ef691e93868a9b	\\x306fd129ee1612164b64c243e1dc6683554858859d4c682e269335865f9c060b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbcc01ea23f0fc8a991dd8b3a87f86b927a2151a8cc7a69165d6c59efda8478da	\\x4eae76760eabbe801a92daabf26928cdd866c3dbc817a1d119efce7cf34682ea
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbcd22b219c9c6238aaef7dc8d809be6c56f7be2fd01b901a909d3294c876b3e5	\\x3b848fded78f4ab9364ac431cc8eff6a4496055212229d17010708c8056ccd40
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbcdaa0fd2713b5b4ce1b143bf8fec44c4b11e7c81f6765f772481557c4a68ae7	\\x74b48a7b8c0c4d41dcaa30ea159f269fc6f71a9b4244cbe6ed1c46f21bc80611
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbce183cfdb2db0976475e708b53adcf85d308c77af80c97b078b3e73338d9493	\\xdc59d94c4fe6c363e0a762a7222361c84c401ef1531a65ff895f7c54fa51ebcd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbd08161e63a3d9bb8fef43b43bded1c46ae81696bf25c6f4a7638f237935fc22	\\xcda03c4a250de531460150f3a84cdf57e7c9793e025a9d83cd1a32841d2bd4f0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbd49f4a116319755ba619b4f1f00493b04451fc6956a996553df2c6d25d9acd4	\\x06b794546fd5441c0ae606e841c196b8768b03c4241beb22b18bf772988a1e99
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbdf86f39c125fbf20c34316415f857600e6df4d220ed79e06b03d957f6423f9c	\\xf7f9fc8d997513dbdcf95986f080a064838c706acc929514403ec08160eba2ba
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbdfceff0cb3981e6f44fb798f60602e264d979e66bd27d1f5cbba358123fbf4b	\\x997406f93f9f55c5421aae0fd89c8b4a4d498fdfd2616e78e94425156f9d5dd5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbe0ef1968ffb3139ef27ad2988ad4943b69a1ffeb9875a424889ffcba856c8db	\\xc05ca4d460ff2e020408e339cbb37e3095e23c8c3984809effdda06ab8985372
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbe105189809263507d0e366701fc0773da6ec805e0b27ee2239828fb78ac106d	\\x204cc04c4a2d72dca3476ac11c2036566ed325556dc8e91636b8239844310aeb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbe9f2ff437e209f4afbfb2e47e166d1552e0d230c1a532d74b6e4eb7e86a86ba	\\xdcf9fc7e134f97e999dfbc0bf9a280943f3ca0d1465bbde89350a634356a134c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbea12cf17ca713a6e8dd092b16b25fce905dabce560be63376c813df331bd503	\\xb8740d4fb1ffcdce5f52091efe4aca06eb135833504c44c50d32d383bdabd8c3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbeadb46b94436bf541523884f98c995cc73f3dee5489bb5c0911099f25ea9c78	\\x7b891975370804a720402760e58c4d288df2261eb29fd0ecea2ea1a7a58104d9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbeb4b45b2664cba3b712afcd6c31475db2a695b9eba2c9bcceb458ae1c461f99	\\x52a2b17d353ea112fbbb435f2335c2013f7c294e5e766bcbae69b65c7f3d97d2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbeb62ff33c45ba034eabefcebff7950421726558a6d407cf80abdb7c2caf4079	\\xda1874f162ee885af73cf00269472ffc0f1dea3486e48901618a5065abd784ab
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbf232d7b371a4cdf78ccabad93a368a47814fd2650687d648a98385301deef34	\\x2a795d2ab771192429aae7d6077cb9b8159d8fd5d291b41771b7b6204ef1f32c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbf6a2175ec556a31ff3ba5a11055e460e54fd9b69b498ebd72c8691dd3fdafd2	\\x7cce833f4b7bf62454ac8fe775038c669ae05b17d1b2648681b15f5117a9120b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbf91f3890916e79f3f051a0f5be3b99e23274cb83f669bff9e80ac3ef57f3944	\\x62bed5f904970b5d7e28edbf70b80feed31f97216954d330141c947341486a6f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbfd8870dd1751597b6dd2b4fb4155995b92e8cc0d54ac2699a40116c6a67bfe3	\\xd3c6335b165493d1f04e10df9c791bf28d90fcebd625695c7d2dc6147715a1f8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xbfdc2807f7834c5b0dbacb9148ddb7fd14d5b64cefb58dc27bf29d6726f7ae82	\\xedbc577a1bdffb376f59bedec2e0842c58b42d0e8063e481ae271add6784587c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc02b37cf98d887194cd1ef5482b9198897837649cea0e58156545be80c2f3265	\\xe8eb13761324d7d414f117543c00a76dc08bdd7f514e2662d761552644a59315
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc08c196bff1a749df609fd61c3fb32514b1b84142b368d50e85ca0115489e046	\\x8c69d1fb05a1bf6436cbc9ada673246b17eb8897de38942440d54657e7aa0711
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc0caa985d2cbc5b769b4fcc6c61c74b7bcd7a8de39762eb3cc741db75e80e0db	\\x09080cd5e5f84342d9aef4f910e90fcc3ebbaeda7be844d28d28ba87cb5b0143
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc1004bad0b245b1e91bcb1c08fe223b863526f715e5d2395197b24f62cdccca7	\\x6fa48518cfc9c775bccfd06234b5965da0e86d2e7b73724fff957406a679c2ca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc186db558a2a533e4ad0b7090041ea4e157437bc81d101de08359419376e0e52	\\x6ef5a47968d3ef29b9b5535f2a205f5291c8c91241effde6b648357c3498e3e1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc1c449cfd7f61306f583c18cb23b28d23d1e4194eedd51200c2982679ca5fccf	\\x2a29a2dc5cdb07e07613379b3c897fbca6c82f9173b107a8c9333cf51fe81682
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc1cdae26e56f0c4dce8005e574678f9b29b0328205e774da962a560bf3cd9647	\\xe2e1a734b7e6ffa9785f5399fe8872b4e805064c8216bc3fca2a94bf14431c11
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc1f9751dbe01a5188d9ea0e7d9d7a21ac256d664a8a518a1efeb3a1c985e717a	\\xd4f390d373b3d85d03f8b9066c9139352e47cd94df6f4533d62f9efddb48fcc3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc1fa50b901dce1341edc9804ff4529fa7509022fe5e284d4f1f6d88aceb615ea	\\xd684b30a654cb8566c774960514dc4015f44b3d6a038b297c85533b11307a3fc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc208c76f0307b88f57578b6623b07e613922663c05415ae1488404a90f9bb663	\\x9c9b9662430c36395c3009c74c5672cc42f0115de9aad052af82d163d7a46a94
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc2298fd89935794957e959ec1b5a3fad3079d5732c315e2610b939fd742d5bcc	\\x71894b38a20a6272c2c946ada7d7f475bc1c8be464109bef589272d6c0652ce7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc28b09719054587109c32c7332cb5f69c2d69db0b7d90fcf1a5fb702eda1953e	\\xe5d04fa28d6645a8f835c8b618a080be47c9e963c4678df2dfb586a8cef52429
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc28ed3785880bcb5b178af6202bd0c8feb1f13c2939cb2c5459928496f86bb24	\\x5237dc2c897372528439fe9b42b208872c4872fe8e12383c8d6081af1f076d38
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc2ca439a16cc2f1a369af8ca945c58aa0b29cf824edeef35efbaad0a5bb82b5d	\\xe4351e39bc25a6b4d10cc5ad7b929d4d20819b5450106e818c67cf27d2745e7d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc2d65a15e523e21d973ea21a53d82229e92cf459959caa23cb340fc57c2da06b	\\x4cf45c3e50d68bfe19163f9a8f92dad9400702ee6203c13d2f9b5084a9785298
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc2fc142065f640126cb158ecb01648eb997df8c6f6319010ff941e143e991d1a	\\xd06d62344c47ffb943e29ef259639a321351667bef4a820a7a314727c50f5e1c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc35f608419526fe3a8ca060d54d4b4f5a09da2638b9322868dd69f7060cb582b	\\x176d8ccc6e514389367b256407e95f236f688a86850e601b41b7292da92e8f0a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc372c1d979ed035811a05af64bf52d1c6ee439c00620f1ca22a587d040020c70	\\xc77f3d17053308bc13550787374c1bcdcb3c30b5c1561bb41909703898cdf562
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc373737eb8bb9c5be74d94d5da78334c0c2ffec12dace6dec8fedfe1905482ce	\\x837be5e98bb5bd327332fc96c5f284371b5af6cf7aa2872cf36da291081c9830
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc37a7f7e758c760c03c05c21697f52d0e00811a43b0a08c6c5f8ed6e48a1ee1b	\\x68f0e92efffa1faf666d91af99b2bd1493a54478771b6569cfeef2e9d04d1612
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc38661df0c147e99d87997edc6f4f8f1c43125218736847871d25f6361a68761	\\x11c095713ccee7ffa748e026029ccc09398d5fa8993d7ea295efb8ca464250c1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc392a9e2289b979a1c975e1529213ce77eb0562cb43362b3fbd7fb10a86af70e	\\x729701083109203e3ce86ad48ca30d41bfbb661e40d056e42e9e0957fc95e607
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc3b97ad26b8617253cb2130bb086efc1df94c97960998de600436fa5262d5a93	\\x24783e3dbcfa2a7f4b42c56813e960ae91f98187bb73e741ecda5ea5ef714e5e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc3d1434b73ac366b6a30a6a36523c30ee54fc3d83be5a0dc18cc873ac112c65a	\\x43455db05688dd387f569b12e5dfb1c2c59addc21f6619db4167cafa1b1f9b1c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc3e8f8ffd795412dcc137d72fffe25dd56ad0a7e05881c07cb55a3520c4d405f	\\x7259ae70b542707a0dab23b2fa6600081ee7c95808bf256b75ce57ab8ba9e595
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc4acb18f9fcb575e5dab6d0e9300c94404149d7cbfe2733922b3ce8728f48cd9	\\x3e482b3bfe60f801f54199505a374fdade667e588857055a47c2d276f0db1f3c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc4c436c3beedb95b2950e94572202e1b2ab161642be9429981b8e1748a900080	\\x4ec48427bd0de27ff00587eb918d6ff1908e817120e16de1faf842113ef89bac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc4c72eae78ad68faca321bff7e5795b623eb3046ce3550c7ed8005f782bd092a	\\x3061a30fe3b6ac6d61b4c5a97be77eed7981a7b1126e639a3957f0d0d7492bdc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc50559bbb4bfa03cc6a33226bb4bfc4222970fb11b24698145c8460ced1b7cfc	\\xeb33be91005f83460b1ffaa9079ea77dc53ed9a0fa09639a4fae370aeacf0654
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc511041597fb731bced08d7b6dd41cdfd6448e760c1c055a2121727655f9af76	\\x5092a56852acfd399d4f6aeec492b3fa9c696d23b7af0244c6fe011d94efef66
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc51adf916d67b63117a64f77cffa32824e4799eaeb18b9a14fb86747a4b6608d	\\x1b9cdde9447502dd36cf7f9778ce2faabb7c93a203bd99c579cbf5e95ebaee64
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc5356908b0d6ce59915ecb513c4f558adb89caf11774a8464fa588d59cdeb0ed	\\x28501b03acba0d8ca30935d5ec5d4eae385e3e57c1f93ae17d95832e5c885824
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc57d3210209774bb214b0f907620477eabbb52c1cd73f359dd83962b4b2f0a5c	\\x8bea6a406b32d152eefb2ff37e8847f784103ad2af3374d35a1767233696d17a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc62209f8a120d0c0287140e1d4839867f2d80e625cbf3c25db93c10e5dbf7aed	\\x04e54ba6cbbc169d02996c7ef1b5551bc7f10bf594dde0c4d9e33918b4d59edf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc622b04a95253cb039d959132e0c1d80abdbab711f032044d322137988b51c3f	\\x8c31e2118c7786fba6f5b8e0aed2c1a28b9cd4b50486f86d9dac5a37e923d4a6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc634feabeee965f93789b62ce54f8c810df6d0f0d7138ce016085ef0f3737bc1	\\xa61257ed43b4e55b39d4a0ad3a75cd6bf3df9022b4e2d7d159cff9040f7af8e0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc643a282f4668e01510a5ae977a2666e768ad78a9b27fa298fbeeee3694d196c	\\xda3ef6d1be10df3ee14a2a30b4b09143876c3dd66742b53a06deaebe83f61817
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc67e41df0c3b973513ca660631ab08777ecc444b4660a1a4bc17357250e8df84	\\xf4a599d34cc162990b0d39028c88091f9cd98931bfea014a837de57efb9c468e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc68f0df807d120286389630f543b34a84193d71a02ae8b0c6f38f263f91adb39	\\x0a6e40ffea5565d5cc439e79e8175a84d8a536b3e0eefc3c9fd38670a7fd75bb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc7172edd977ea0b3e126b0fbaf0eb9d5d96f02eecd7e105c3f0192f2298bc607	\\xc28c0f705fbc00b5cc56e16e4c6d39c831b000b2b857c5567ac56e6008268ed7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc7be16a02df291bc805c15d9a2b9b9bf13aa5264f6514a34ffc129f910e8d4d0	\\x4de0043d17578658f2643bf7ee8198fb4ab6ea4f4b02cc8d6ec937986a147dc6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc7f73b35a136213b1305f907fcade49483073a123e07e3848ad26df96d2af6e7	\\x862b9f4491ace6622210cd43869b51bde79e5312b14a54c04c6c2935298332e5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc831a4e3171646d0bca562008df0fcf270fdcb908507573ae2c38b788cf8c968	\\x360af73db9bff49b5917e65b200320725e7eb855ae1e96bcbdc8c40c9d694868
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc834289441eb2187f8582fce08c4857852c0d7fdf239b0aa7f2de12cd4c2457f	\\xc2955d82163034b8511cf5424ee0e3f7916ed4b38d8e2ee1a298a02218e96748
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc8ae5b32c40ca61d4255324b886bd68fa8e8a367d33b59b0a1c00a8f02a400a8	\\x584b3ee981043d14c4fa080e12eccf5cb58c7e99b5754831c744ec21297820ca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc8e1d7037d6ea984b00bf95cc1ad4f08b5d37fe35cda298dbc1a01f52b9cc728	\\x3f5d2d75abfb8acc4d06927701f64d91e0cfd0e515b7f6f4c915d4539589f0b6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc910034c3d344f9ed5a8df0dc03ef75c953089085e044f30a4476b2f20af83f8	\\x1de35196bfc404bf57a384b87c9eda192144f7c1cfd2d012b038e0701cc92cf8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc96e99061cfc4aed2b3e703a200dd90e967e39a421e3930a23fee61d05af6a9f	\\x1fbd24d8539bd0cab7b711b1a85997ca2668a4ef7091017f94ad31818ba4ba95
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xc984a33693b348f6ec6d9b12a22db67eb8609801aba090abe62f984a3c9bc1c6	\\x6d30ee9fcf09c3879c20fcf16269b4996873f2b94b9f77aee43f19bc932174f9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xca1f18eb27dd7f80c8638be1653bbf42a14ffe0e66a5fead431e3708c5a80c1e	\\x1f3bb235937797396fe7f8553a9d2e7a3b0ca76325fb383d6be6a226c407cd89
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xca4e62bf5ce74865cd10916e69123bc30981a88d9bcb36cc3e5202c4c9b353cf	\\xfa707fdc5dca3ebf190e99eb5280ffed25b83e1b6895f416af2e71ac6cd28b6b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcab825821ef6fb365b43a255e4e3d5fb3080947e43a0f4a3d919ae8d7a6abeba	\\x3ffcd04e88866e6572a99c5cb1d4e8eeabce30427973085005282e2bddddcdc2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcad8f0b3969362af533da5fadc95a72ec14ad2d27787b79f7755a68b44d2e1e0	\\x9af6ea8d8d7f052f68637920e3eff13294bbe4ed7ad260de006fbc9fe6aabd89
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcb63b579c9f2a7d668407f00bbefb79c3b9b1576571480ddedc4bf3617a3917a	\\xf1446a0ca1f1d9cc6e655caee0ef8713ea27dea849f3cc53868d3a6c0df7ab7a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcc0a0c5eb334f5c87b66ca578f0967ba703cfa896e386e470c59efaedee2f153	\\x5ea5d316a3aa22aee05adc87e1792d5b736c2122d72f146d59fab72a6fd656e4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcc29113d93e877526bca021b5fa6a141cbd403e744f00589e8ba55514aa11782	\\x252da6a4412abf42a3212593e9bcb5d52f9fb383b6088d69f2230893f958bfdd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcc2a2776752f37d8f2789b0869337a6c491ad273ed500950e23aac59efafe317	\\xa287a8a1e2fec06df27bd23cb504695c7a2b08d44d9bdba0780785185307841a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcc41145374c56a65b4f8e5807f489e67bc0cf83f40df4e6a89ac45aaad5a5e28	\\xbfa33cec14a376260c7e2b5b9d7616e6942f3319719c89957ed0c7043c586929
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcc4dbf9ab1929df02fa44cf3b1661aaccc704d4db3bc8cac3fe56a6c53e02e8a	\\x3971095a638f5293ca21f9ec8b5f72fa0eafb62195b96b89726e3f9f8c281fad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xccbbcbe4f4a459f485404df5ab584861698577ad85b04317cea9bb8aff6e2d42	\\x9dc2d87dd087f4c304b76c52fb928ec7e81defef075533b92598b01e6769bf86
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcd886029986148ee1608bdccf60acc1a2ec1af9f857ae384e8b3427c686b471d	\\x990db2696eadd8d5bd2c66eac1d38a655538739dcf89bc196a3bdf2064205bfd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcd90c8e15497f2dcf623ff147f41a28f54d8aa4159ad62dc41d55b734064e8b1	\\xec01242a8d094134727ff503dd80f27b53a5ce76dd8eca99d35a953b8c94a9e6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcdb304e7f7be6bcaf9cd09bea5eb165d58dd644f7eaaa42a98efefceb8414e0e	\\x00ff2d279ca8c2a7cc08c7c56ce8a3c074255f4f5fcf11f4b17941cc5ba33457
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcde59d827744dd034572ff707fcfc4292c324e178dde2b7a35f5cba967c56ea3	\\x296f31d7e4122749224091c0ecf434af9fefa8df945446da3b2fde4c50326dcf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xce2c5209df708d143c3ce19d6004c978ab724f96f734b2c426a244b5659e98bd	\\x03b2a385f00154ff021f3d26beec0cc1280a621ec3fd99d76bff8bf5564a5fed
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xce2f9b32cf00a274c857c252236e4f0b3df695f98948b67ac7430154e0daa4d7	\\xf4420da778383b29ab2ddf0c800e8b63a1121ed18966e99b00f2a99e538e930b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xce41628cc3cfb2fc6368172224b81fef78302a580f37ec4d22edfbc6d30a0344	\\x2f2525171244af1a338518f43955e30af42115bb6acc3a618018d9b11b7471e5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xceb4862536c1ddca638663a417b5c0c4e8bd71a0b9f370ceba86526ff0f6e787	\\x34b6ca140c03d2d0d89433802b87c06ed577cb3aa558d38607c6f78b109de894
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcedc09b755f53eb26176e98e668b85343488c54a35444395f608eae5b76c0abb	\\x9eef225ccda2f958d487376bad112c1ec8c1ed52fd2ab63fa73921cfd6126429
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcf30dcc151768ad04fc34c660219ee29e8a5e3ec4a713e2b498ebf349d49751c	\\xf2fb8714391082235249bc8b3b1bfa3c017d4de19b20f6cb6dd4f35cf54496e7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcf62d4ddbdd5bbddd0bb3f169673f395d62e89b1226aba224ddfd75f8ef82c5b	\\xf70a11accee57a1ba2de3131317dc245edc12322ca473152d898f5b09640c03c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcf66dbaefdf34121035597c1c1c589b9d392713cc8ef712853802493106424a6	\\xa9682a5a9a237336acdef31037eb2aeadf3caf82ac2f668e1a74dc547f9a09c3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcf9cbc01790408734b73f9dc3f09a262e85ed4c306e404861769d5fde7d1e353	\\x9c686342f66d4154bf94685b9a1e8b8c3272fa3e4bda24641a39ec6e07c9751b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xcfec7f85f8f7575c33b5a67001bed4908c06c07e753337dec0fccce8efa27b49	\\xe74e8a6746678ddb012c4c503ff46b049ad88e17cbb60f2895f30882d072aa9b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd1501d50f6694669266e72221baa9edd29b017b774eb15527d7f08ffbc136d00	\\x19672e991d8f556326e0faadd272b6331e456df2cbe5ef726ba64ac3d4cbb999
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd180fb59f3d52e3573727aaf44618d815a4b35708e300ac80d95582c11972351	\\x83a0f3a68f2d8705a4f6dadd70191f4fba815a7261463345eb20bb2475eda773
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd18447fe7d8f4bb29a007030a8b7d60c92d7e1dc3fc6eb84aa72caef03fd8b97	\\x9b569bcee52778d2a894295a82b5e6876822f408c547914a124909621bed9c70
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd1c39c4705a2f999286394314efdbd533ada4cbd0f7a47b07488efff089773d5	\\xb99f3b3e9ccf2086e3c30101a13984fed17f6182ac8ee8d69db1afd6ccdbb410
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd1cedf66e36b05acd4cb0785999329f3f7ff162a6d9e1bb4f52b651a7ec287ed	\\x74933a69693d1b226ca0297532dfe7ce8adaec9d971cac8cac78c2bdca8c5308
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd2019a62f8fc00e0ff683f8a3faf0acfe45401d25b04ece6f10b57d69bee1eed	\\x9d14d88a3b5fb19168a5bb2be7c342ad9d7cd3e61c3d6303c82c02dbe43432b6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd24e9d8f652a8f1bca852c3ac30daf3eafd35953da8384ac04a9924c09935d8d	\\x65a7b3227122b089c4b4f104128368b912229c70b1e3e9b43339a2121298da47
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd27c0546e26d6ccda3030795f838652b98233e46b9b35cdf7600f676b04bd1e6	\\x2eebe022ca464ffe370bf15f5c09beff800fdbb4e86ff769a691c82627d8197a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd2e7a0b8eafbf45a550b8c3eb69195348428b8ee45da5cbacec4edcca3a4ab07	\\x9074251cb193e00e2509ac81ecd6abfb85212ac0805ce27bb58ddbfbb16646d5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd31cf8064c7353c7864ff80b166079ac5970961167d0472f645fb8dc89dd9647	\\x537f412bc494f89c98df3a0b4ebf585153971530a1f60160482e53ce44b32aef
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd32cdde404a35e828029e409bf70b361e08996c062f3ef95056a4518b690046a	\\x283274115f2b4e434958ae1517ddda5adf183501f36b5f062120d1d189203196
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd32f41d5f453aaf71553edd85b3fc50054e920e3eb7586ca6d083b978f2d8f84	\\xb464deafc8c62acb301b4a48f201b2661ecda1f0d0be79af9dacf4f6e9ac07e1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd3b36d49e4dfe9c92dbff8ac3327f40304a278662db4c13527a150981061f902	\\x50a07f3a02034a80616d4d8765536580f38e1b091ca6a26f2efff76692d508c3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd40d6e0af0802a148d6f056ea49d0a34d74575103c66f1e76b18a0a80561f1cd	\\x1809834d14570522ed1e0f3453de7c9cd2c6f3d75946d956fbf42084bd488e72
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd40df8798b0812f989512518123f6a6c71c62cf1a6a8b026de8b347a6f3e9086	\\x4154ed6910f6df658bf9fbbb72fe32aafee500440ce4d368d3a2b6fc0561f4d5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd4100a190716b7714c4400de85a968a8d0fb053b0e16ff8ada2c8deaa541243e	\\xa423b5e106a0e51a3ce1bc0b2f2dfa3b7a3a1b24f82cfc52b79e73a0ed03d0f7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd41446a1ba53a84370f6203149370c1a57c4e0feaa7dee87d81733d3437baef1	\\xd268f885d44636ba45dae126cb8f0e6d341ba89145a4cc62011fe4f93172c1fb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd47958ae38ada895832088bbe6bbe2d147c193fbbbd95141d557031a97521287	\\x24c58b4caec6691835fd9566dd511fec09f5489afc1ddf9f6bb618a7c6978b4c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd47d25f2e9f8a543b48a0d1e2aa4026caaad3b638cd6d7d4927ed0768ae114a1	\\x3b0805210af5812292a1d9b04ec7b62ae510ab915fbcaabf50d5d31eb7355e3b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd52611d10069bbc39b4d8b62cbff09b1fd8aea3d80814b8423e7e511613fb6ec	\\xb5f94cf5471f66e4a0b04f8f980f85f006610534ddf597e0561d7942453b2683
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd55b1ba4616729a7a457d4b5768001b42f23f8414d1bdcb969aeb8d59397938f	\\x05a7419f777e177cd5ffdd82b059fe4aa2a020d8f28106000475ed6442d493c8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd5acc0a77e81cda94d521b35646ab557605d58d8178457045de8eb0038818202	\\x1afa8f9e897cad69165ad1d7def7ab60850b9706cc1bb34a58c3c8dd7b0a12f8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd5d61ffccd5a3f203ac2f900fa08a299d3821406aafe70689a16035491c324f4	\\xb4591bca63c105c897873b61fe46b199516e8e800b8b846ac8c27ada373891ca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd688e6d7bb7a36f35bd728ff8b1f880f975a53aab5fa4515f2f290f1724d790a	\\xce36bb9be89f1fad5ebc114a635b4e9b4a15f176611df51b45aaca244eb0c111
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd6b1b8a215cc640a66f9f216265d5cd516993a1fa088ac559ab0ee3b21bea546	\\xe91b462296ca7b4e9f2815f57df28a9c7980506d37c73cfbceccf35956215236
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd6bafce2bdfed7334c64e3c6a86a8b2bd2834ce4557e0e4fb5a6931def317bd1	\\x60f53b3b0a7b6fe95df6e93670846e6de2c6b8080b6defd8816d18f9968514c4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd6da915eb936513400f4b9a26dfd8a35619f135c41e15916bb5d8963f39e40ae	\\x6be9a2c87c8253b35b33d8db5bfc837dfd906085ed88c1828c4202d9a8e74406
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd7042fb41311f14e2e078f8ebedf4c3cba3149656879083f59d6ba6cd08d062a	\\x76cb5fdc8f8cdbdb95fa04ebc9d75b4c40a4313214ed2ed04c446b9c9ed438f9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd71a783314604bef7b1c2f069a270448b6430ecec35edf71123df779a7ce6b16	\\xa30892d87eca2bf01efceb25c264fbc7790cccee524246b438dc360c74173fb2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd73b50558e9ff909f9b52650b34a7da201fe710211f8315f65b91d0482602442	\\xcfeab9864cfc3df9962556de6a9348603179568110a166d58308a1dde99e6325
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd7f62e6c558818b6922b27111a7bc5f013c4b462ccae0098904dd19c34e1eca5	\\x2774431122bbb357e9a66992032b13f7eebaba7d11f91136ee9dfac0a5128518
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd7fe14197892b9ee6e21d96a0ef1e8f1988449038d716f6fa60ac0824821aad0	\\xab3c93c1fd7db0de79bd1ecd3b053102ce63eba5f834f3d5f9724c90cabb8578
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd80fc8a6e205150abcafe7e13461973934596792bf9c9f31fc9f4f047aebd6a5	\\x422abdc0a3f7aab4e4e4f9447196db7d5f0cf338908298d86415ae46a037f74c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd83e6dc005c712e0689557ee37fc59449c378842476ea94b35810f1f7beb7439	\\x179070e525f5d9c07103df83419f72bc6725a0f2ab042e44e929e9369012758b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd858b2ad4d61c94805fb2b09a9c25c082e975d0a308bde7ffd117d346314a3ce	\\x4ff77deb9831c4322edec7f87bdc35b5283182d5958b06869b8701e59fee40b0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd8737321a5926a08c1342040a7d581bede1216b3ae78d43d466e6fbae475c55c	\\x237c9b2086c8ba651a952d50378d8b1cd59f218ffa7ce264554e393c6c690e42
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd8c4919a600f8d2bb2c9aa06d80096d5d8530ff20ca116941b9c9da0a267ffd2	\\xed9c1dfe3bb6c4b2eef441942251b2e4295b4c09993385bfbdaf1cf5f80374ab
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd8f41825843b993b7acb5f7dff2cb55892411c0340e3dae5c67c554a42acdb5f	\\xd735b329a8500771d28a00375ed43b595f6a87d0c0eab4dc03f7534c3490ddf3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd9245cddc3e739b7cbded610b7f2f6330e2b1b2fb58c9672703977b654035472	\\xdeff486dba4a28a41612aa0c78c34132f33d535544c6ef4bbbcdc663315b038b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd9702f6aea34bd8f86e2683f241cdeabd61f3980901d003f5c5b4b2e19d33108	\\xd12d510dbd7805ee97a6d56cd1ce61c32d1a6ceb0598a974c937db64ed96ff5c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xd9e99407fa310ed62cf880a1dd19b515f52f112b377ca29a6da71f5e8bd89ca3	\\x474179b4fd7b4dfb610282273b6bc4982137f3001677286184334c8dbd466607
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xda07baead283702015e0cc4437f761566d4406c94e151b0de1a106d17bfdaf8f	\\x6f7c158b8ea83f94ff01b0966ee32f8434d388ce8ea0eb3d72e6fa136d20890d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xda2c9e3560b391592227e59e18ae8ab042dc2ea4742e071aa374f74c155f7998	\\x3ec7340070187605d436aac63632e67dd1bff76e0c87a8bedab0a2e91e6b82bb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xda31c07637253028c264ca62ed1e5f5bacf69727ede309eaddf6d78919bb15ef	\\xffc34f7040a245e1ee13ffa3b0c758a58c0e6abd0062ba008644737189405e75
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xda617aadf98f8d80144934fdfc484fabcea804166905255e022a888d588d9a39	\\xb241c44bad15b63b8280354aafa98899f2a7ad5630d8f0787e82fc359634b68d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xda8fbad7711a680768688e34701cee3c0a1d29d704204245afe1043e715cf477	\\xb1ab1a3342705db32dd6debfa3a8d3252dd5967cbe431264900e14c789338496
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdb1d2afdbd570e97205e34d3a998dff6b6a7b893cc4cb42f7e9b0a039379ee06	\\x6e3133808ec0c00aa7508e21f19179b0a730030e65b33d4a8f034e156847e12a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdb2c357254135e37bca9373da95b70462813d0e2471e2a7c67f9a946867b4b46	\\xa8316ba17d7cda05a233160bf19756b611051c969803928b79a0b7c24fd68085
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdb3d1e99c3e0a186070b7a43112aef4d02c35d235f5c7687eb6bf3d7c5536993	\\x6d0f5f98af66ff3caa00f8325ffc2ababc9a9ed74e42c60f4bc3e80b3a459db0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdba5ee894959ea24480f393520426c93b2af6ab58f7a870f8ba0a2a2f6b5a7fd	\\x81e7b52bff263cce440d13e235c611672112e082b9bf392a2bd1f69aac8d2f0c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdbdec7ba77d832ee55b8a64ece2351a0e01308c55bf7e540f1f86d689fc6928e	\\x88b956632c09c8049d19e55f72c3cceb2de8c533b722d950a6361a7d361f605e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdbe9bef5d1da86948d544945bc82c96fcfc6b1cc2d5befc207baf9ef94694061	\\x3b0c3212cfacfa5fa534b88e97b51ac179be61e7e2b617d8c7020e870dc4e623
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdc7c5068b792a7108908f3358ce147082666c6aab42f28c6487948e3691da1b8	\\xbac7b52e6dec48670aecd8faa4b2d157863fbecc78b63cb0c41aa8ff0f888a9d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdc8068f41bca925ebf4afcb4db9d0b0551e16d4ad6d048aab1561d9e771dde2a	\\xfdfb86c1e46b378edb1d465a3f686e7ba5d3852b4961db9bc132fff0027819bc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdc9efd568758202577a2a0c024ca0e94b98efd07b32646fa5d92f76352cc22b6	\\x5e18681ba5892c5ad09519436b437207809169f05b06d978f0de8c1152b2b1f9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdd165ffa6caa9c5a66bace352d8a9c580cb6de47d2e65b8c5bacea9bdd5b3754	\\x859975270387d27027bae8662ebfdd45621cdc72d0fc178c0b925c51475856fb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdd2fab48c204e35d386e0164cb2f9462fd5d0370fbe98ac0f650af096ecbbd4e	\\x6255a5d2552d8e6b425d7a5769aa765da58ed1973b684d6e1c08c2572f04734d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdd3ad5f832a6379b3e5967e0386ae3e85be310c17c6b6408654b28f91235fd7d	\\x76d4995180abad8650fef975919efc41ddc2474b8b2b1365279103c1c5836fbe
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xddda6cceec0f04d7fd23d5dfa431e9d0d36baa265ffdae49c889f27bdb7adf9a	\\x49c22cac899472f8b45fc6a70beef63ba8d949dcea42685f091948ff01d24529
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xddf0b3453a03d9f7cd841d7d6ef2eb30f70d7091aff9856a9c5a514fbffd7997	\\x28dff4709296fd660a96e715ad0e9f632a4c2c51c457d9997c79a84e266d0632
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xddf1df10b6e475d3e4474ae0d90c5bb69de67eac293775771cc721382259b6ff	\\xc40a738a8bc90594f1297e72751e97b372de0507cea055d36961bea62fd6a0d5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xde08806e87fe7d1bd976b27c95fb0fdaf2dffadb563000a79e653e72e9cc3169	\\xbde8eed01dc301ffaab31c5eb8baa4212870ba0a4fb5eefa8ef6717f2932db8a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xde0e642ff5d43f74808560dbaa857578ecc4f6b2697fad548c982055224916a6	\\x3044479427ace5a644091a744b5d9756f19e0495fc42251a91860bc98d86e0f5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xde2919167e16009fb0e4b1eca77df8d1743e17338f914699521b05f71acb621e	\\x63230f169ba282b5906e85c1bf1c5b31950fac6da455eb67e7e45a4f5ac685ee
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xde29f0f11ca559e7357df570b7d4a9ed67fc22549e3cb56603315f6267e4eb72	\\x1775bdf12e674e8fa4b024b088e682120345884ce6f93b1a77a1e1cb23938b46
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdecce8eeff49093de2e815cf99085a541330152adefc47890c859d04ec3e17bd	\\xb966db5bbb26b4c0a34b8802e5304c0200d37b0c06effca3df83e3bd9da5bd61
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xded48ecdfa98bb7a95fa91b6c7b64aeb22faf195a9267c0409508e4b6e0ef5c0	\\x470765aab49ef3ba104877c8e0ac62dd3e04d34a6c18eb2c279dae1a2f38c3a9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdf2b1dd849cbf6961a71d0c5966ad2baadb194609476ed99b629e1004e52622e	\\x37ad62902023322b3298ce85c3ac10a1573857c8cdfa105ff1fa3c7a8b2581df
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdf3aaf5a47200460707061c0b259b9988207d30fa110a754e86760f7a8aa7e86	\\x5ce441670040e7d61204cbbe6dc5603ad56e69cad1741594a54c643e41256584
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdfcb43f1a9c109193f925e940b6db033e4251ee794057c3e7fbb9739d7d2c29e	\\x203cd8ac35d2b3ae0a295f412ce7345afbcc04a54031b64b40a557eddd70b5f4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xdfd833884c10ee16c4065713bf3eac508fcf6c4d4efac1dfea75da7253e8878b	\\x5b6092a2735e2decee9a0dd56223744805225395619d00b4aea5df02e92c6291
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe025e7ddda62de2e047d2d066558478499efdeb25a5a97c064cb00df33b625f6	\\x2f2610c35060ec05db71f87266f04142ec327d2c3d76d466d75d76005d85f95f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe105f0f9620498622d9ef29ab2f87f83758fcac0a334aeee473dbe568a72bed4	\\xa8b2dca8c6e7d0d3991ef3f6465469cf8430b367df702c03c600cb6d7e63064a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe109ae758fe4a821e0125b08099c44c6a84bcb07d8ea7da31e8b1ac3111b0a4d	\\xe991fdcba360f3cabe72856a599538fecc27114c525b1e59d1938c8324eb2ca9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe10cedd89c2da8b478898b4400088f6e5ebbc50210812d0f83fe2d738f2bc1e3	\\x0a322be074e6bafe0cbdbfe4bf95c7d2592ab41ef715a165d6f1d0ed3bcef4b6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe1572b915b2921e54b30eeebbf6c6488af94a1703ef8dffb830e789c7477ccae	\\x3392465a7672e522f837aea469135b1d80f20613ac853e3c7a2e64a7300a6436
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe19eec40e446ea7d7085b11b1e3502ba1e5829abb699c4d4a7f0cf431995bfc1	\\xd71de150e14d72c1a8a72d692ac79a61aaa914cbdcf93adb8268c23a37829f9a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe1d47f3df9a8d233aa41409eb408f1dabd7d1dfbca43c670cc67337bdc2ac9ae	\\x3aa7a2c718d2ed334bdfc48f4cb3aa3a99bec20680cd75674947ce378d4917a8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe1d917ac0ecb29637c5e8696bfbeeb27f692e99f945b6d7cc4b4fb1f348c4f97	\\x752deb502b6837e3dd5a5cb4a3fc0906ef9db2cf4c7efa6833c278eac13b54d1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe26e8e41d4a11e3c688ded9820c1114b04e9298ab9389606f0667b71075c5d41	\\x4d86ff4e912eb2c72c3bb1f5724cee0ed1580ec013804bdce6ffe1f39db1b619
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe2b71d1254d00e5015709f3e168654c804f252f863cf1d70cb92bac4bff6175b	\\xfb3b427bc8e82e96c1dc13dae9d89041b3a1124565d251825f0c5cbfdae42467
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe2e90302bed4af1c85ad849eba263032c5c80eb701b1505196f075342bbcbfaa	\\x5d17180f86274e117591b1671f638f885dc8c2cdd49c0dcbb5093e52c6d7bf57
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe38e79dbc88a6a330709b47ab59b9660e149470f355fd1de6a6e40eba615690a	\\x8742e62d83b6df2fd8b88d5f1804f821fc8c186e485d5189a5dd86c04b7e80a2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe4923ce85841af52e1949ae00d254b47cebdeb1e56f92ff88796eafbcb0e1d78	\\xa12a3d1f86d226d64c30a9eeb1d0f371535edbcc288da6c4c7ba07aaf019118e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe49c57c4f89d49889f52f57a2f2b0232b540ae69c81b68758409412c38bbc612	\\x611a6d5823f527787216543b0d7748f8a7f1f5fe0e320b6516c7b465bd37bc89
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe49de59eedef0b8a6620e56610b9b82d83710931bafc982888244fb82fb2d1d2	\\xb96d0e0c78689756900e1db78df6dbebd01a7482c75f6fe8549655ac24d0fc0f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe49f7f03d0e48b52b2e7928d4e8b5c28de3fd22ca4d240fa1397531a11eed15b	\\x4653bf3fed9907336653d31b7445787f74dad749e0fdeb59f210d0ada0b22b49
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe4a3d5071d7871774e6989a432a8e039b2eea66134990d9f9a49592d2b5d6e3b	\\xd2ac32050dc9c096bb2f5c89658660ad717c62127403a01167d984e839fb308a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe5424f546befecf7681035e045df0a7d9b2276d7356ce630f2e80c3eb9360445	\\x71a39610ecd7599cb2311a214fe9ed59d0044430da811b3ebcc0fe99d33c347b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe56aae64043ce8f96af02cb09294d98ada955d1743bdb56a33ec700788097573	\\xf7cc5126b6d85d20c94ba47ec994f351f6c216864f195918c8218192db500cc9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe56fa2f34b57371eb6d87cc482aacb6b7fa31ea81f1862433c6eb33f9dbff111	\\xa56d375c0bfcc61f8f58ee56e430624928dc45e1f325143201f6c01fc1698351
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe5b49824d4c293cc9888aa80f9a2031f02e157bada6bb3f457f8bb9fb6ba318a	\\x4b0e2a98e33d186cc0a682f1fe3542e0bf2232a564eb122651b70383a8eb1217
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe5faf5696b7de46f060e9a904d27314cd8b7fbd6ba6d1375be71359e7b372f56	\\x96afb992344c44542d50f554a653509c6d6cd8072f95b124708d3782e2bacec8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe6c4ee8f7ecaf1d0a0211b0cc7d5a6d094eeebc7eb0e6b7d630df315221fe515	\\xddfa9bd25298f4dcb882b7b3790b578ebbda8a020fc9c3f59f521a8ed103122a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe6cfc306f39f8ccb37e6160653fbe52796e0c3533096e42d4fa76038c2901b53	\\xa8a8a428178c89c55ac9697ec58c793b395606f750ea076f153e3665e902c31a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe6ea953be1f79bb6fc8a84371426f1113b89aa4524c3d6fded7a690247be9daf	\\x2dabffff816aa3dc2efa97524704172db8bd5a2f5630fa0b7e1b242fc0d6fab7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe6ec5fa4f53426f4cf98b8ffe6074edbfb9de9bb257f77f44e017ab3f40e7580	\\x042c2af73b9fd3e82445245613439d1c77c45342ec11c1450fbd4a08bb0064d0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe7244b51c380f54ad0043cc527ef08644abf3275d5ce4fd35e6eda19d63368fc	\\x45adfd2e6a1e9545b66a69bed216d22d3cc055f19a9835a6b91e204f72284ea2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe729d49f24a2af79cd91c54020cdb27d5874eefaf8c3627a2eaeb200c8db3789	\\xb893473679cc0de96f427d856e092a10a94c56bd90fc0e2b81485c20c73efd63
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe75168db6f9a6a6715c50ab8e009f024d9448103a63c7860a8a99f0cd3a5bf80	\\x1d1b408c428a47bb161fd817fe12343dd699bf00a08549efa95a3698a86e6d71
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe7c189b0ea9a3f194a78f99d292ea62f96f0266accb797e5eb35f351b9249bdb	\\x43a81c1d9ee2c9acce42417580144a979f1c8ef293380aebcd22a267801b4765
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe7d6f5a3a32883b714c185f2f68b48cfe0c59e7d582cd1d1831606e8695d8323	\\x1cdb8ce4a84f5361d31da4792550451bfbcd3305abeb20df361734ec90d32d11
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe80452bb7f482a6a4cc3e311c11e0fff308a7989f0fb8d70d00192fdb8b54246	\\x81874a6e45b0cf1275366c9a2b330ba38314ee74bfadaaf2e7517b16014e0646
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe872ca13af8708a2cde95544457f0e4664d5ea1338a19d9531b2fb4e717a9baf	\\xd24f89fb6640b2438c973b335090585e42e5a56352ae1110c38d56f00806f5e0
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe8962ac2c90f566c23167da96e5868ba794dad9012ad2a819188a5cc1fc0d429	\\x8043e0dc255f9d163934b38e05b562a03639101b8aea9d099cb3531b36e58937
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe8a67f8dde007145d0486997f670d38df181b3145bf2101fa4807677894a3942	\\xa0f079fc28c3b218e77d03ae3962a9001270de066a7dfda55fb7ca706326ed08
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe8f89d1df7a30c09f18c8f95036bd509cc8691575cb825c976edbac17d0ff8b0	\\xa0e7922b1312a0e280e2045ecb704b1b8a7d9ecb830db305f19ba6890f29924b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe978d0f99449044cab38bb26298533b9810aebe914124cf12c4f4d9bf8ee54ec	\\x21148ed5be388dbbf569864e084328d6d9bb67b0d9df36b4a8eb1a4cbd1ff46c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe9858c10fe34b1dc850152ce13b1509efc64e9b764e3142039aeeb758edc24ea	\\x8f87bf8c388bc9da2637f75c782a88a161a56b7b8dfcac36c0468198c86b57a3
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe98a345fbc62da2088986b59794ba3fdc6b2f611a0d2e5b29b9bf2c56ad6628f	\\xe3cc9c8864cff358800ad185c8ef128580ead9cb21efff030efa2daaa39eafb9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe9bf0e86739a30233da624ec77f132c343a6a6cca40d85635c0ca9fc0dca7236	\\x756742152ea7df8daf264686dce7574acbb699fa1eeecfc8bc7385bbad5fc611
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe9c912941e9acff2484a5ac3997a80eced2c96e714a1be97e7e90e543fd8312f	\\xad5ee2c3adbdbc66fb63442a4830b13ecaa457fb11f88a942909f20e8c991b7d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xe9f5b140e3b423cf955eac79d5e9ec28f7978081d40b6b9c7dee082d930012b9	\\xb6a075a4401be878d6f216855983773eb96139c4967873e6cd2cc23ce975b4fd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xea11102364edc6af2afbe568a01fb1f16899542a1cca42eacc6a34d6b3e00572	\\x26e067af5e9ed93d63b97308b8a64f85d9f63a4310632d1fa92766629dfa37a5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xead7a966e64557e050245d1d6713882038087f5b82cf5b1bdb6946177cac2403	\\x40ecebe56c69a915af666110faf6d493a50abd3106047175198af1391b522102
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeae6bb8ea81e7fad474b4f1cc69dd6407ca963d7e3b9e273f2e605aae08582e7	\\x49acc2361dc51e2eef116a275d45fc160490054b58c5152d40d49d3dc795b37a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeb05a3fd25a7a50299441b2504a5d4c1b1776fc7714b4a2d1b258fa4a6fe58b5	\\x7b8be70cb06c395ec3f668e52e42ee79afe33d420a1af4d06091d306aca9fe42
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeb97549c2815aaa6cf9bb457929515c43817bfbf1fcee6dade714795464d98dc	\\x83c7b7f20a10e3e43934689e062a9522fb09641a5cb4d4ba317fea37f93a8bc8
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xec0e89682fa3a16d92fcbcfd6470098a8cd57a76e0466ce6d2d38e264635b318	\\x4b3ea5ab7c511d55b8bc3408a43a7beb2972d6cb98815ca7871d40f9fb7c85b2
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xec163844fca9414a3a6e4bf4b187b0183d88e0f51cefeaf36395ee5031643fc9	\\x241296ea902229679663d3a749d63e67a88e84d2eed29538e3907637affe317f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xec94480e2b9227e7687fdd47d4bb3b7ea7a10f12a511ce43ca8ad70822aab1fb	\\xf52d7a08ad8a90fd6fa4934632f431757d80b42cc7582a2e854d534b135467ac
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xecbee8b8d2a25cd8ceedc81d7048ea4ed6847ec64256fa96c48b348891017902	\\x601d10e930bf9067b550a912f47f1d4220aab8cae751a76e9d9f28f7f234aa62
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xecc133193e7dbce2c055286137b17427d47c7e69b975572fcdde74ae8b34dab5	\\xe0597979e99fa931932a183f626e22410217d3d4070f3173fd744278f37612c5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xecd2ad6e4cf870edddf63342db716bdd35b5998eaf209f58a79a12873c1912f1	\\x9f91d6c6ed7fc03765bf592c36fa25d9b52863448dc548c8773d7ff737828882
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xecdefad492f61fd969c56401d1e9214a32adc1aedf1a330040e5acba1c023296	\\xa35a26c2183bc835c6289c35cc2f7292599f224abfdddc0a91fb1cd5fd3230eb
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xed4db45228fc5d6ad3937ed15a4a69e2b924983bb5d4b9472f2ef167d4abef25	\\x5f25cb46c6a5e6261139bb1c38ea93686050c42b5546a70bab5715a178f40e2d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xed5481dbd30b2426c8b1f4a8ee19089725e9bc297772f5081ad2ad2483e991b5	\\x7a470fa2c38059d16878669b9fffc629422af22bb187e0154c4c9cb53d2ad392
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xed62b640287f84e3898572fe7ce4ce20c644ea3680a09e563afecfc2dd1cb427	\\x0c47c55c121098db3e98e60b9c1762582383fbfba0835f951b8e982e852eef04
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xedb7795dc6a9087648169782b05d87080891c8bbd2130ab4e1becfaf77117037	\\x00e58042b590f0f511066f04a41147149f1d9a7857a4477ae4d9b2b7daaecf37
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xedcac4598812a22e3653bcb865332d88d8d3c88433a20ab3b766059577dfb241	\\xad81ff7567cf63648632fdfab17cd22c708a21466372e203fbf53e7ae8f0c086
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xee54967b5c4935b8945c451130ccb956e5d2d7e40422b92fdc2ae033a7f462d2	\\x12ef32f6481bd20f4157ef2d1bbd56b87b126ea59c2da023a3954e5c992c1ec6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeec35eac6e98da057ec9841431919d37d4721dbb98b8ddf3ffe55010a6b5c34e	\\x0e58aef839c8ff84495f458840cf35ac35f41e7436af2e512b2c677c94575443
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeec8bcecad6cb2e3d5040422ba8d8a3c756ce6fb13ab8f276c3f7470c80a4749	\\x34ffa32fca8712ce991800d53cd782a5dab418904c0e79658eb0cfc817215dcc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeee92ebe5b3e3384865eb1053f98fc21a378eca4a32e61efafe5b9127dcf8ba4	\\x96e176a50ad61f6e12e1ce5a7f2ab15f9c89daba5cad32e5a23ab3c388244ca9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xeef86f4849e4619620d211cdc7fafe608c551060ff05a150bde8bed66523264a	\\x48eeabd120f113652e538ce0617528c4db42fffb23e64042163127debd04ea35
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xef5db86329c63a86da05a0305c00248198234458c51d47d96425ed716e4dd3ee	\\x1b8b6988da1e940a432b4a24f1c6782f8cc7796d6ab7bb635dc0f47456b4b076
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xefcb885c4d3c06333a4ffad7776b1ae1f521cd502999d89cf6a6a7143844216d	\\x13645e91c59b58e24358b5b18b382d0181cd4689b4e39d5c63c4f69e701ef970
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf0488b5bd927f96af500d0627e935d914338d05e17130ff367d9b0350f470729	\\xa23deccc2fa938a9740876a46b4e59e0e35e0bef6a763c37d3156e126cd3f455
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf0ba54b1f730ff315ead42bcd0e73c27419e52217db3f9b5797ec28642e47356	\\x59562b941d387edf8c6cf99cf042faf110a52cb772371448174f96797e968c6e
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf0dae6336951692804254cc6d24a0122c93d4c100c569a798c33635b71260813	\\x8a00feba99030561dcfcccff66111469b8ba902a0669809487660b2ffffe7c04
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf124c64011d797ba982fc9043f090b200c44a96ef6cafa8da588a43fbb240d6e	\\x6157105074a6012566b7843e69a281337ec8e999be0553a6ddcab35de4fa0bea
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf1286f75e9ba8652beefc1fd58cb9ff468314acc94fad91a6538af679cec0933	\\x983bab4ee0991377d7858895b777e5f98bc71905b722afc5a924f78ee7a5f536
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf1903669e4d6c3a16fcd5617c3ef5c4c3beb87492cc32919c78bdd3421a916fd	\\x7abd2c5d17e56747a6529b0f209378666a27dfbb3adba28c19610adf7049cd4d
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf24bb2d4ac4ba49dc217b891ecbeb03a8bb48e8274957702385d4d566e8d3b5a	\\x385538d638cb012b7b1c207ef67cd89e3b942793d533a9892e2399279c90e907
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf2e12feee028ff1169a695df7240d1a3438dfe6d9d65911e3f6be2593ba26716	\\xee4dc767a1f156a85398fb7ecd669794b34e4a345053fff4714133d167378c98
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf305e216a112fcb68262ef00d48045d85fac17542d428c3f0c89684cd8a7de07	\\x8639ba27795532cbde74e8eb370cf9887f6565ac00c004436fbb50e1fcb859fc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf3147b087a1b5ebd0c704fb36655e606066c896618946d03ba065a4061ec4a40	\\x6b13e6cea29cb7c501965f5231edb105fc0d3bf7f9d122aff1f67d4cccdb7343
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf35b406405aeb2d89a37deb7a43ef87aacfbfdffe26b970fb6fa6adebcfa29bf	\\x3716d8ba52ef2fe46c88600a7cef8e765e6ef56028e23ef4a0518208103175fd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf43725de8562d51047819b3909fa8cb689381c5214ccbfd92ef81c20fd32a6fb	\\x255818bcaecb2c8d08ab43b08211aa65e568d04c92b412fb3750517d255c8fdd
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf4378346f167a3ecbc194efabe0ee147e1163f034b03c53c1c01539748e746d7	\\xf521b07acb8cd3638b0b033026ee81a62462dfbaca0e7c634edd939275c9be40
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf482e8accb20f7d4cb03efac5f70ed21b3ea872a8daf447d5f2c83c79f00689e	\\xce61b814b5d36487408afd57527892c65808a8b652b0ed77dae19fbd63c47c43
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf52cc88b681e66342f992b92386a67d98e565a8226d959acec1de860544d994e	\\x5b8d7be12442d9c7fafa1508e97351fbf87269f8e78dfa1ee74f51fd17687437
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf5c1485168e9ebf0913237d0989c883293913027bde3a02db1c028a793c80f49	\\xd3c5eccf43b6d2e75c9d6227ef1bff9f295a2c24967c026e01a55fc5b9bee9c6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf5d8fd9e19b79d514eec51f2b21e021c53183f713bdc50b125b5acdbfe632607	\\x8a72ffeff94494a9ea7f43d8d6d8dcddb9f8a17c3d56652375cae041edf820b9
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf614caa324c0fc5a93598bf278109b7f31baad3b04a7bfdbe88120de1b3ab706	\\x623f17c4b3ac0aebd81638fd83c00333794b0f1ea1a836ba4b159eb5e19eca09
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf6367de992bffcd1082b18c11ac5386c846e5701e6caa5e5e609086446ac29e2	\\xea2aa9757d4d54d7b4c49d9d66c805cf01a2ddaf4245433cb5d407cd4ace3bce
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf69c3a56c2f859362852c3a16b730dbafad8150623c3f67d2a535928ce463da8	\\x9244a52f4505532d8fdfd0cecca3056d93b4b66e6dca1730ec74bf73fd771108
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf86ada38249c9530d0ca48fd9e85d0cfc9910b2cf93fe4f638d32408210e391d	\\xd903d74cb850c48b7146d3058317ba97fdc2fb66e4ec53463498fc0fb00d805a
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf879d7d2de353e644a1c20b8c6297166215672e1cc3858f2a72741b0d92445df	\\xb70ac86f770db4399a19da9e8628c7ef6807acb9c48efdcd9c5351675164a2e5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf87e70e62fef22338120dd7baa79487e810aa740d3aa0010d8b9666dcb72cf40	\\xfffa974f1c4ce5c9e3d49df328d21c4262c791fb884cea66fe090f82f5adfade
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf880fa57129a33713326c028d91a066f690e63d7afd18a9e4ea8665ea33cccf4	\\x960bcfd53eda3b4bc6f3fd18ca6335938210be3ceb6a4d7b814bf2bd6d42c1cc
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf8907ed09af8dd23a108bff2134445118bcb22839786fbf5e23ede1e97dc36d7	\\xbb8e9ab9e589c2926ca8d8233415daec0595f01bd3a880e6461136ba0d25dbf7
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf919d622589babfdf8860d7485bbbb46cbe2c273b891992b58d6b9aef626e9eb	\\x4160f9da49deae0f0ec215aa76d4f3e7635fe6a8ddd735761f0b41e652a88c05
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xf96c8487d536baabda55f753c9bf143e1671db6d97a983b2e21edb7741f9f45d	\\x82ff9c36eda4bef4abee2e27356685534ec08678ca5132761dc0e81fe2b49525
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfa3a72e5dfa331d8e39198a6dc52c8c42e2306a01f137018523327a966b93d42	\\x81c50d3f46ceee5fa978b4d8ab551df926915c02ead286c0bee74e3096348174
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfad80d566a7cc3a77e790c7a79fc9da663e2048ddf3cbe466c68d85d6a57a44e	\\x1e27acdc37455df697032e9dd33ddfc63cef05cdd71a6c524d56db18eb5941b6
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfaf86c37a6d553075ce72a7224fb903dfc3e0a8711fc8ea8135e5580f76b32f0	\\x845a7bbe0f539051e414d4f73550280be16d64981ce0b48c347bab09fe7b3e86
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfb013c5d9e1f65c346f5b427984212e1a94a45282644948d8e97af5169a5f382	\\x4ae2536f503270ff5af1dc9e6b8f960c543ceee1591e37299d9688946e5c6d93
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfb41f0c07238188504720eeaa1d2ac3531e04218f7e7dfc3b35651d3b5f52ed2	\\xee4cc74a9f93c108dad2614a763c805bde91484f8ecd41e625ceddd6d109b8ad
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfb42571a5b7049da936bf53bc37256ea03f29a135a61cd48c39d201201ab1152	\\x1395af002ca061962c2049e3cecb21a39566d9fc6f8c907acf8ee19e526fc549
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfb5164191516d78d9bddf7b93d8e0c0c93ec5b81edfac3148be302ab89a61b37	\\x5e97a3168f4412c3d1dd8d85b0b12a210ceb178ce2c3f0ee55495d5986a834fa
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfb5fdfa79407f1b72f64ddca2cceda6ab58154258e1c0ae18ec16c7c9de793f6	\\x5a32defdc7a96e6b3440e9bb2269fef393c830bcf920fed473d14563face051f
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfb94d747ab285ca1476a5473fa26bb35a19a5284b44a443e30d2a4fbb68b162f	\\x2adb6073c98e26890366eeaa40134c0141547286a161c9aca69dcaeff5a9ecd1
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfbd9d2f8a154b812880ba32f44956b306beb5e2e69a57913209dbfc2de48603e	\\x8882c1a4ce681389f3daa9e6a565bc2280deb55841e82d4694a7d5d9c7a8f2bf
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfc32dc59fbaa41bfc6d52333367e5c50a1c26b52488ca6188d2f7708273c0d12	\\xa69811295d14c3c88704140cf33dd315cdb1f75e8501c4a3a92dab0a878d1438
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfc5074b09fe1a456cf1958dac6f73091ad8f6536dc0919ea28715b6eb5bbf9de	\\x5998681cc29ac78db6e357aa72da3c586dd23d40f66323915bbf7eca8dc79cc4
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfd41ff5f9df3f78fd7d59f9e9f0eb525c13437c1a2e975786f9d52ed6455b077	\\x1850933e728d71a331c3ec5a0b10f7330b97bbc3c4e6d3ab6743b8a0cbc86cd5
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfde67d7c4fe7d0fe11c72a788648ba9086e1a1d3e9b76d4b2215ef6d93e58b31	\\xe2287bf52422dd95b3355232c148856324caa566b87d67c64646a08f43a2c727
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfe4a5bf82efebe22fa0e60033eae936710280f79f0b54b027071e9a765fde8ac	\\xc80e7679a394d66498d032ba4e8a1f9da22ae7a970f7d14bff3f7fb0daa0d816
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfe79600450ed889bc5a0a18766c9db2eb0266dd02b13977ed258bf8330bc905f	\\xb9d13db39a74d2399d959f7a01d1ae7cb7550f2dd49c77a07989fa7f4ab51b73
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfea64de19578f8a97702356b8221005cde8e587655df8a924f19097b0147947f	\\x0a4cfbf4315f069a1ea9eccfad677b521e4cbf761bb52d3e5147d28c4793b90c
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xff3863d0dfeedf9790b145e731be419243e6b1379576d834c6417b025ae8b66f	\\x06fd5e6f099b2fca638035f6145fe5ab83ba7f586a14e92525f494b211f5e2ff
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xff9b67b12491cc4e92462c6bb006b896dbd945a18b1420db55c7d5d46c343910	\\x90f3752fd775e1309e882269b13e428631bd93dd3544d37f47ab376ea23debca
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xffa8e076e89cf9b3ec89177601cc39280bc9cf213900452143ae1163fdbf896c	\\x209a023ccb2e2ad1ac6ef0989bb63d770df72f33dea5082aff29c91b7357f51b
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xffc3206a6f91746d5306f00bf99905f2512979683774da12b3935dc33a00a5e3	\\x469b54ff727c82f12fcb072e05ec93ad932e689fdc26b20511f35195db941b22
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfffde1302cbee048d43dc8d94082eb66fc853642a410695b5b2efc9859f1573e	\\x4edf4503b85bb8f1601a93af9d7941a7c5db845a838fa065710b0a49217de282
6283143886518:7@s.whatsapp.net	critical_unblock_low	12	\\xfffe30652f3ce2e5d4b1ff1992caa64ad47c9aa16b8addae4481dd06dfb40c60	\\x95ad7541a52b0cce76d72816db67e18ea6dacea4403a4946f7172af458f25032
6283143886518:7@s.whatsapp.net	critical_unblock_low	13	\\xc508046d40555e5249da20938d612bbdfd38ddc41f9a5a1ebe9ca536afbc97cb	\\x035adf37c5187141b93ef32951ce569dd449e48895403c02ea0aabc7335ef8ed
6283143886518:7@s.whatsapp.net	critical_unblock_low	13	\\x4ee09367795a62fd8ff74c488c2ec31e1f0d6dd0c541fcd3c2172ee77d85acf4	\\x3b60e9f54790e9c606e321c1f9ba7eebbb79fd8d634808ee98255450f6d60f4d
6283143886518:7@s.whatsapp.net	critical_unblock_low	13	\\x49a4ac8c0f8fc5bcbe14e08912e7a1bddae0c61e1353fcb7542cae2aac0d4a2a	\\xd4a9bee7513db1bb6e2c8d6d36b24a76feb577a98ad7fd97b393cb006cfab469
6283143886518:7@s.whatsapp.net	critical_unblock_low	14	\\x226a241bdbffd7c11c9481fc474d0ee64aaf7376865861b47c788f5907baed9f	\\xa2d19c6d49fc57751f2a1663e72ad3502472d744bee877dc782f9da97a23b892
6283143886518:7@s.whatsapp.net	critical_unblock_low	14	\\x0eb1e1aee0c0865cee7c71dbf9e873a71ab23fc336c6a12d6bafc7be91249cfc	\\x3fbac986a640b631984ae75499a0cceb5725e25e7cd009f8f327c4633f48871a
6283143886518:7@s.whatsapp.net	critical_unblock_low	14	\\x7ecfe373e8a80d6557369bdb04d9e39e49cc0a05591f1386643dcc766f7ab6d3	\\x17ef00a74a7cdfde0f4929e2a0ed4de8fbb441c0967b119587fd23042624c593
6283143886518:7@s.whatsapp.net	critical_unblock_low	14	\\x177abc1d0fba39d7d6150a71066b14a1b3738ec3fac34580f7d9051bd3d0a99e	\\xca4420ce788e838e2a9cae069361f6534b9c84be43de03de54fdc61ac8b5324b
6283143886518:7@s.whatsapp.net	critical_unblock_low	15	\\x6230e995ac01583c012a1eec9d4bafd8ad3178067bdea5adf47fd2de5f9c9405	\\x31c76989c3902124e289e511173b987fd02fc948da42a1cd48b52b669e97f4db
6283143886518:7@s.whatsapp.net	critical_unblock_low	15	\\xc4183632db963e6edfadc882a8b20790c853c9c3109febdb11955e3d0162001e	\\xaff711ad69a0639d02acd5a7308adc2828f4bbfda22b7731d5bb444b56710977
6283143886518:7@s.whatsapp.net	critical_unblock_low	16	\\xc8bdbfdc6ca12601d45e6f107c0355b3f0233a429c5849eff317a5dc02555196	\\xe24b0285dafe1a6ba9c90ed9a1deed19f3df76ca78cfc4874a065a3ee45aebc7
6283143886518:7@s.whatsapp.net	critical_unblock_low	17	\\x31a39066da19e446e3fdc572db61c699190b710d9d1292a43eab6e9242a49a23	\\xc6fdcc0a9371604f364e081801b7d072d9e332d370e9e6a02d2b8d86e031fab7
6283143886518:7@s.whatsapp.net	critical_unblock_low	17	\\x130a6047045ef8356a5938d61a4f73683dc6a8a82abf88217b1a3724fea216ca	\\x78c52c01288207a3f9d9c9f23159e9c0d26b1e925efc8855c809f3816e659d42
6283143886518:7@s.whatsapp.net	regular_high	14	\\x0919726c3308287eefd05dc1b4c43d0e4855862300535df069c6191bcf102464	\\xf3c8e9de89a4af815967283203db5c5b404fd9a44aaf424d5392d430429aa838
6283143886518:7@s.whatsapp.net	regular_high	14	\\x22c96b4dd67864e559ee2bfc140fff1f76053bb1c22971019615a916e31df7b3	\\x19f21ea640f191aba9831435502aa2e9a996aaf604a859ed731a96733a06084c
6283143886518:7@s.whatsapp.net	regular_high	14	\\x24b61536aec6a9a0d8a1f935125137c6c040916be9c72850d42c647cbdcabd9e	\\x8f5786e009ec34fc8a73546d07555cc2f9d604ac8613e9d7ee6ab56f2b271756
6283143886518:7@s.whatsapp.net	regular_high	14	\\x4567f835ef5bb902aed3f4d59a10d7ca9fae5e4b326646c4db5ac1f780124745	\\xcd590363f7fa0e32fd984b92783a120fdf2bfbaf5182e278e65da64da5c03f09
6283143886518:7@s.whatsapp.net	regular_high	14	\\x5776eae516467aec5a417bb9aefe374d97df8015458afd704a29a91cab1bd9cf	\\x30526c9022ec303717c9c76189c3f51308c2526a21c9963dd06443d793283cde
6283143886518:7@s.whatsapp.net	regular_high	14	\\x5d24a3aa0185a225efd7b97e7b0d6e340cea3c5755ac43b2b01379304d618b30	\\xa542fa0f2b7b49344dcb493377f6d94cac27a9387a2d39a4f6a7ad485ec0126b
6283143886518:7@s.whatsapp.net	regular_high	14	\\x7f74c58fd315d551d2411945aa3b92681a7e15ac586dc262a866b09597155e18	\\x3586ea0792dda638538050e31543f5afb3fcb6925a98a4052eeabb8b82c3527c
6283143886518:7@s.whatsapp.net	regular_high	14	\\x8b99a06047fc1e3835afbbfd75c16dd3a61577bd8769acb3113e17eba9976a60	\\x71c8eecb83a6be961588f3b50e3e002f597dd198fef6ee78081513585fc7a521
6283143886518:7@s.whatsapp.net	regular_high	14	\\x8dd0d83be1ce798c3576aec86a39429b39991f64e4886a2f6a7878edc0cb6701	\\xd5eef0a275a8b5c1ccc2e148e939bc1c964f5da7ed7db7c839abb23704a3af29
6283143886518:7@s.whatsapp.net	regular_high	14	\\x9a7a4b3238b3d04228582e6c469dbb60f1aad37b25d483c7c287717999387cd5	\\xd769b6ac4de278b6451d0a4d69d10ea8112ec05ca4c29c124e3917660b05fd38
6283143886518:7@s.whatsapp.net	regular_high	14	\\xaf53534f7f0a464fbd2b62dd462be010fca15b15e0aa55c44286856ec5496aee	\\x7451aeebcaf83fcad1143fb3209d15d5b91177ac9422190c1ae04ccab2d2609c
6283143886518:7@s.whatsapp.net	regular_high	14	\\xcc5d22d7c2a0b834be9b319b3b61d3871c5677852fb40afcffd2a691722cda31	\\x16e99f02f91de289a21e45a9725ac049dce91fe79c3e7b670e919dec4bf1c8a9
6283143886518:7@s.whatsapp.net	regular_high	15	\\x748350687d3f290e364344e1a9fdc444b1d99bca195467fad12f5bbe08b6edb0	\\xd9664ab85c0da464c563f81776090112071788534bec8dc88d4528cd40f539ad
6283143886518:7@s.whatsapp.net	regular_high	16	\\xd3447de241510f99c1fe1797d753ecfc9c944eed287ec12d52c6701487302b91	\\x3e2004b3c1a8f720e0cac04bc924019ea6b52ec85c77bf7e56918b7f994bd779
6283143886518:7@s.whatsapp.net	regular_high	16	\\x7bab773b1c87776626cde958c361ffa7b25f16a1948a7a3f8b36cd745d1bb904	\\x973cbe8660c750c756a608834a79e50beecf792098291bd81293dbadb1660867
6283143886518:7@s.whatsapp.net	regular	4	\\x12f78bf569cb6b58cdb5bd2c5ca1acd59bd988815432ec33ebddc7aa3cec3f90	\\x50a38df0efd316b11eb04469c9f4a7915e5bb95076caa890bcbaafdef79a35a1
6283143886518:7@s.whatsapp.net	regular	4	\\x16a33ba42ce0dc9d418bd31cf3ce9a6b1a97cf81516b4c166d7aa231d2512194	\\x536982a34d1d9173e18cebabd9e02801ac7d1af2cceb70832451816befa6f68f
6283143886518:7@s.whatsapp.net	regular	4	\\x25a13321007085d184efd399a9a70b150890885fcd1be61c5f7a45f28875c4de	\\xa8edb0a40b2c9bcebcf40cea6e391e885ceae36778192a21e7f3b6a67c36dcf7
6283143886518:7@s.whatsapp.net	regular	4	\\x28e34543644870327bd36e318c11127ffae140f4252759fec56237000cb3333e	\\x4cf7d831a17f655b9121aa0da808ff186a26a7b66227e377f06538444af3865e
6283143886518:7@s.whatsapp.net	regular	4	\\x29fd97ea10c765322f7379a2880fdafd5030a539f9b48ae62fbe7e2ef03cb6fe	\\xd8761552c30fef9b92da6835fa74707d2072ac4777196ef2bc3aa3fcc4b01699
6283143886518:7@s.whatsapp.net	regular	4	\\x3395d79e9dc956ff0278ab572551fb59cc3ca5563aad70422aa8c35ff7bdc563	\\xfd220597068df9b1600a110c94f815a6c1405fb37af27c4230a8b7e16dea5e30
6283143886518:7@s.whatsapp.net	regular	4	\\x347c6bb9adb6cd26ec4646149910737abd0126d4eac6df38694c1c692a13927d	\\x499026e0d8f74b20bb76ac6c2a4a5843f0fafdd578bfde13298d578859efcc83
6283143886518:7@s.whatsapp.net	regular	4	\\x53da343330bd7cdd95b43e421b17ecb0cadc611a226185704d0d77b2b2c5c2f7	\\xcd851ffdc0ca9ffb75b6517f25e99b54739900f233468f161e7d7df77447cec4
6283143886518:7@s.whatsapp.net	regular	4	\\x585089070b1685e5758bfa3ca4e6137d12f1b27b0678be0e391a4827bf60c032	\\x512d57d03c38ad7e971f9a6658acc2ec95f2652b94d1b34307f81342190d1418
6283143886518:7@s.whatsapp.net	regular	4	\\x6391a0922cc95a75309aa9fac7352b81c102eb044c1b0d4f5bca1438fe8967a2	\\x42348e674489804ca59a2fcd41670feb106de83fb9e6c4ba0c08fdeba9098db7
6283143886518:7@s.whatsapp.net	regular	4	\\x6534c85be03db73a60ec1d385ce95a2fe0b5cede7b40f54c7ace455a4905fcb5	\\xc47ad58603abc9b5037907081fafd0f488a560e641db6d3682274b7d4e8cb321
6283143886518:7@s.whatsapp.net	regular	4	\\x691083afc505a2c10f8f1cf66ad18ecfde7526510cddeedf275bfc59ec3dc1b1	\\xd02d958c258310825e20b603b62e10ab2cfada4f07f9be5fae98abaf2d591adb
6283143886518:7@s.whatsapp.net	regular	4	\\x95e198783447700d3ea29e774a221a71552cd8abe36d251e1dea21c4ef752dcc	\\xf12acead7c29ecd0fbce18585097a0af9d29e2aed1a559ff86f859637b26cffd
6283143886518:7@s.whatsapp.net	regular	4	\\xaa862ff68cc7dcc4681522bc905a4fdbbb17fc0beb2e396a71d69c3bdeea9bc5	\\x4e0bf9b1e1cdd9fa242ce89adcac1043e6ac1fc7229d31405a04e7345d6c0442
6283143886518:7@s.whatsapp.net	regular	4	\\xdc37ce4818a40de4e2373d57ee41876b73519b9d2dd23d286e9e82173a0f68a3	\\x3aaecbb45bf934ab3e2c202b72edcd66f44f99d27af5809352db38fd54b36f5b
6283143886518:7@s.whatsapp.net	regular	5	\\x44d079847386dc4b38c04686c27cf5e906029b77efb112437aa0595b731a8a25	\\xc176f97d00423823b749e3a12f12f35b45682b280fad1be73ba63f4f2c8ef23e
6283143886518:7@s.whatsapp.net	regular	6	\\xccdf4293cd2e3352d568bf5d36b4d50f08ac5c07655a875ee4509af0159dd07c	\\x5a489cca97b6c56a51e6ac69aa1d34495d19b95b77da07b99fd5393823c02db2
6283143886518:7@s.whatsapp.net	regular	6	\\x3b45ac4dbac2094bfa39d9560ff78410755eb699b94d787daeebc5c6c965a642	\\x6de2d2545eb28333a85d35f67e85e24fa8fc1d34fe8c86b45fa4ce2171915317
\.


--
-- Data for Name: whatsmeow_app_state_sync_keys; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_app_state_sync_keys (jid, key_id, key_data, "timestamp", fingerprint) FROM stdin;
6283143886518:7@s.whatsapp.net	\\x00000000a310	\\x89302b1f9b9691d49ce91b5dcfb783fff4e2bb6d7c5abbec0077c951755a78a6	0	\\x08ffc1d0990710041a0400010304
6283143886518:7@s.whatsapp.net	\\x00000000a311	\\xf2fd9db6f5a3cc23a3711c2db0bafdb4d223778409914bd6effad1f36cee1c7f	0	\\x08ffc1d0990710051a0400010304
6283143886518:7@s.whatsapp.net	\\x00000000a30f	\\x0da9ec1b5f6d31a920087a74686fb45f67da2a3447dcb9076de468f71cdcecd1	0	\\x08ffc1d0990710011a020001
6283143886518:7@s.whatsapp.net	\\x00000000a312	\\x2eabca01018184d85c5ba88c48bfad7186b5f53c768125f3622e8036303543e8	1769948637635	\\x08ffc1d0990710051a03000104
\.


--
-- Data for Name: whatsmeow_app_state_version; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_app_state_version (jid, name, version, hash) FROM stdin;
6283143886518:7@s.whatsapp.net	regular_low	20	\\x6a287933d3ac01ce19aea37ae9e59e64edb69142a71c1c95f3e06ba0033a1c508a41bdb92e85a4ccd346d003eb446736bd2b9a64851d24cab6b64da20b9403b642eefb2dd0435ce4cdbb3eea3df8e0d8bc4fd92ce275f8d84a1c53cd94af80ca8246b05ab0e674bb104a2891a7adab6e24814fb81cf81b2753cb685ae2f1e750
6283143886518:7@s.whatsapp.net	critical_block	4	\\x81e074e16f50d46e2d251ae5f51b84ee902ce4df4896f7465d154afe4d6389e989914311f71fb9c741dbed3cc42d186a5279592b32bde8a33d1811d31160fbc2af141fdc091d97a69369b1e746f22802d0539b93617007b1bc483f1e307c24690995701c8e42c5093ef65318feecddf2be5309d9ba16bb2a6d951a7fe2d6d342
6283143886518:7@s.whatsapp.net	regular	6	\\xc6b818ddce0cd4718bfbed78f8b49ef3c7e15eb89a479fefb3834a2797e352f0f7ed9eb37197c0d635bbdd491533900d59dfbab48df1e48dfabd63bb1dd2b0df4a94644739040acfcdb2c3cce4259d25aff68b595d10ecb15b59e91686b5e350c3f94d803efd80e02c15d0f90648b747198e6d552e041969ed8dc18b0f09de69
6283143886518:7@s.whatsapp.net	regular_high	17	\\xdb197722993cf2a3321f3533896de886fab7f9f88f2744c518d5c25333c8ffc3c995e6ca3b945f981bd6b8359fb8e2961c187e7d3f596a18b6f10bb2dc5001fce6a4aa04325913fb43364c43f2e43dcf47b51638cc4a2c57e810949e78b14b2c2fbab6430b511677a126b5e5fb188bc32cf817778f5ac81ca9d10ea690a6fb0a
6283143886518:7@s.whatsapp.net	critical_unblock_low	18	\\xc7553a3075b29f625f9830c51f245db7310e447d9f2200cec69d43b5cbd504533a3eca94809cdb03caa0ed411635d01e74ed78dbbbdc13d8aa0a8d246970ca0687c5a0c26d7251b0b3a42617087edb3562b202b527e9d807fb09348b23e7afd73917ce18c62ae4cf4c60cc23fc15f530b040f7f7e76db69fbfa60aca96bc544e
\.


--
-- Data for Name: whatsmeow_chat_settings; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_chat_settings (our_jid, chat_jid, muted_until, pinned, archived) FROM stdin;
6283143886518:7@s.whatsapp.net	280349896638608@lid	0	f	f
6283143886518:7@s.whatsapp.net	172374368489545@lid	0	f	f
6283143886518:7@s.whatsapp.net	79152120086550@lid	0	f	f
6283143886518:7@s.whatsapp.net	15169992265770@lid	0	f	f
6283143886518:7@s.whatsapp.net	76420520894495@lid	0	f	t
\.


--
-- Data for Name: whatsmeow_contacts; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_contacts (our_jid, their_jid, first_name, full_name, push_name, business_name, redacted_phone) FROM stdin;
6283143886518:7@s.whatsapp.net	177679206723839@lid	\N	\N	S	\N	\N
6283143886518:7@s.whatsapp.net	6283143886518@s.whatsapp.net		Arifqi Noufal Akbar	S	\N	\N
6283143886518:7@s.whatsapp.net	132272191709432@lid	\N	\N	Gpp	\N	\N
6283143886518:7@s.whatsapp.net	6285730817354@s.whatsapp.net	\N	\N	Gpp	\N	\N
6283143886518:7@s.whatsapp.net	262104842035423@lid	\N	\N	UchuL🇸🇩	\N	\N
6283143886518:7@s.whatsapp.net	6289674978606@s.whatsapp.net	\N	\N	UchuL🇸🇩	\N	\N
6283143886518:7@s.whatsapp.net	122033006465061@lid	\N	\N	Ike Setiawati	\N	\N
6283143886518:7@s.whatsapp.net	91221296955604@lid	\N	\N	ID	\N	\N
6283143886518:7@s.whatsapp.net	6285714278212@s.whatsapp.net	\N	\N	ID	\N	\N
6283143886518:7@s.whatsapp.net	185014457217030@lid	\N	\N	iliyas pangabskiy	\N	\N
6283143886518:7@s.whatsapp.net	62816293565@s.whatsapp.net	\N	\N	Heru	\N	\N
6283143886518:7@s.whatsapp.net	6282271466106@s.whatsapp.net	\N	\N	Dewa Alief	\N	\N
6283143886518:7@s.whatsapp.net	6282132250072@s.whatsapp.net	\N	\N	A R ?	\N	\N
6283143886518:7@s.whatsapp.net	6285278527256@s.whatsapp.net	\N	\N	Moslem Digital	\N	\N
6283143886518:7@s.whatsapp.net	6288222041978@s.whatsapp.net	\N	\N	OmDi	\N	\N
6283143886518:7@s.whatsapp.net	6282396223054@s.whatsapp.net	\N	\N	mahfud alie	\N	\N
6283143886518:7@s.whatsapp.net	6281332094866@s.whatsapp.net	\N	\N	SBP	\N	\N
6283143886518:7@s.whatsapp.net	6289698749009@s.whatsapp.net	\N	\N	~ Bram	\N	\N
6283143886518:7@s.whatsapp.net	628999994929@s.whatsapp.net	\N	\N	ABD MUHAIMIN	\N	\N
6283143886518:7@s.whatsapp.net	6281265647421@s.whatsapp.net	\N	\N	Warung Bu Bejo Vegetarian	\N	\N
6283143886518:7@s.whatsapp.net	6283141226693@s.whatsapp.net	\N	\N	Wiwin	\N	\N
6283143886518:7@s.whatsapp.net	6283801542834@s.whatsapp.net	\N	\N	Bois	\N	\N
6283143886518:7@s.whatsapp.net	6283159777775@s.whatsapp.net	\N	\N	airin sedia n.8d	\N	\N
6283143886518:7@s.whatsapp.net	6281212561332@s.whatsapp.net	\N	\N	.	\N	\N
6283143886518:7@s.whatsapp.net	6282319671785@s.whatsapp.net	\N	\N	W̶i̶s̶n̶u̶	\N	\N
6283143886518:7@s.whatsapp.net	628977021403@s.whatsapp.net	\N	\N	Susan Al el	\N	\N
6283143886518:7@s.whatsapp.net	6283144561650@s.whatsapp.net	\N	\N	albinurako 123	\N	\N
6283143886518:7@s.whatsapp.net	6285322009792@s.whatsapp.net	\N	\N	mesya	\N	\N
6283143886518:7@s.whatsapp.net	6283844071256@s.whatsapp.net	\N	\N	gtw	\N	\N
6283143886518:7@s.whatsapp.net	6285724450830@s.whatsapp.net	\N	\N	jm	\N	\N
6283143886518:7@s.whatsapp.net	62882000007228@s.whatsapp.net	\N	\N	/\\/	\N	\N
6283143886518:7@s.whatsapp.net	6281224499143@s.whatsapp.net	\N	\N	Alsyavi	\N	\N
6283143886518:7@s.whatsapp.net	6285224821723@s.whatsapp.net	\N	\N	.	\N	\N
6283143886518:7@s.whatsapp.net	6282297875521@s.whatsapp.net	\N	\N	.	\N	\N
6283143886518:7@s.whatsapp.net	6283115373566@s.whatsapp.net	\N	\N	ㅤㅤ	\N	\N
6283143886518:7@s.whatsapp.net	6283151984898@s.whatsapp.net	\N	\N	_	\N	\N
6283143886518:7@s.whatsapp.net	6289670700444@s.whatsapp.net	\N	\N	👍	\N	\N
6283143886518:7@s.whatsapp.net	6283111350073@s.whatsapp.net	\N	\N	reisya putri  8D	\N	\N
6283143886518:7@s.whatsapp.net	6283830162393@s.whatsapp.net	\N	\N	putri syifatul maulida 8d	\N	\N
6283143886518:7@s.whatsapp.net	6283127394499@s.whatsapp.net	\N	\N	dys	\N	\N
6283143886518:7@s.whatsapp.net	6283182013384@s.whatsapp.net	\N	\N	deadea,,,	\N	\N
6283143886518:7@s.whatsapp.net	6283195949522@s.whatsapp.net	\N	\N	Gii Makeup&Olshop	\N	\N
6283143886518:7@s.whatsapp.net	6281222721111@s.whatsapp.net	\N	\N	​🇳​​🇪​​🇾​	\N	\N
6283143886518:7@s.whatsapp.net	6283148042375@s.whatsapp.net	\N	\N	.....	\N	\N
6283143886518:7@s.whatsapp.net	6289635531490@s.whatsapp.net	\N	\N	Ce Rini	\N	\N
6283143886518:7@s.whatsapp.net	62895326554201@s.whatsapp.net	\N	\N	Mom a reVan & de wafiq🥰	\N	\N
6283143886518:7@s.whatsapp.net	6289660132919@s.whatsapp.net	\N	\N	Ike Setiawati	\N	\N
6283143886518:7@s.whatsapp.net	6285353297365@s.whatsapp.net	\N	\N	enci 3 01 2025	\N	\N
6283143886518:7@s.whatsapp.net	6281646883409@s.whatsapp.net	\N	\N	glngrmdhn	\N	\N
6283143886518:7@s.whatsapp.net	6281262222186@s.whatsapp.net	\N	\N	nuraenimurni9	\N	\N
6283143886518:7@s.whatsapp.net	6285147730251@s.whatsapp.net	\N	\N	~	\N	\N
6283143886518:7@s.whatsapp.net	6282316667655@s.whatsapp.net	\N	\N	Rianti Putri gunawan	\N	\N
6283143886518:7@s.whatsapp.net	6281280797100@s.whatsapp.net	\N	\N	Sri Yuniari	\N	\N
6283143886518:7@s.whatsapp.net	6289655078473@s.whatsapp.net	\N	\N	Mmh Huzni	\N	\N
6283143886518:7@s.whatsapp.net	6281320551386@s.whatsapp.net	\N	\N	~rvn:(	\N	\N
6283143886518:7@s.whatsapp.net	6282298397870@s.whatsapp.net	\N	\N	bl	\N	\N
6283143886518:7@s.whatsapp.net	6282295348964@s.whatsapp.net	\N	\N	didiss	\N	\N
6283143886518:7@s.whatsapp.net	6282230010574@s.whatsapp.net	\N	\N	iliyas pangabskiy	\N	\N
6283143886518:7@s.whatsapp.net	6281311966864@s.whatsapp.net	\N	\N	mesya (reply soon)	\N	\N
6283143886518:7@s.whatsapp.net	6282234506553@s.whatsapp.net	\N	\N	Al'syavi020785	\N	\N
6283143886518:7@s.whatsapp.net	6285215399783@s.whatsapp.net	\N	\N	Salman Alfarisi	\N	\N
6283143886518:7@s.whatsapp.net	628889365470@s.whatsapp.net	\N	\N	PT	\N	\N
6283143886518:7@s.whatsapp.net	628886600551@s.whatsapp.net	\N	\N	Alwaheeda	\N	\N
6283143886518:7@s.whatsapp.net	6281290908782@s.whatsapp.net	\N	\N	Martin	\N	\N
6283143886518:7@s.whatsapp.net	6281212747118@s.whatsapp.net	\N	\N	Kabariyanto	\N	\N
6283143886518:7@s.whatsapp.net	6285156281880@s.whatsapp.net	\N	\N	Sugiri80	\N	\N
6283143886518:7@s.whatsapp.net	6282110965290@s.whatsapp.net	\N	\N	Dr Anton Dwi Fitriyanto	\N	\N
6283143886518:7@s.whatsapp.net	23910267531496@lid	\N	\N	aku	\N	\N
6283143886518:7@s.whatsapp.net	6289655354485@s.whatsapp.net	\N	\N	.·:*¨Deddy_N¨*:·.	\N	\N
6283143886518:7@s.whatsapp.net	6289637056867@s.whatsapp.net	\N	\N	Dia	\N	\N
6283143886518:7@s.whatsapp.net	919699552608@s.whatsapp.net		QB17	\N	\N	\N
6283143886518:7@s.whatsapp.net	919990220002@s.whatsapp.net		QB32	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289643425730@s.whatsapp.net		Elin Q	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796058551@s.whatsapp.net		XOO-107	\N	\N	\N
6283143886518:7@s.whatsapp.net	919835140779@s.whatsapp.net		QA193	\N	\N	\N
6283143886518:7@s.whatsapp.net	601111749195@s.whatsapp.net		101	\N	\N	\N
6283143886518:7@s.whatsapp.net	919247579805@s.whatsapp.net		XC319	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804789797@s.whatsapp.net		UJ278	\N	\N	\N
6283143886518:7@s.whatsapp.net	919922170477@s.whatsapp.net		XC306	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285273411778@s.whatsapp.net	\N	\N	aku	\N	\N
6283143886518:7@s.whatsapp.net	60183238128@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60124678596@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919725512277@s.whatsapp.net		QA167	\N	\N	\N
6283143886518:7@s.whatsapp.net	919699024743@s.whatsapp.net		XC381	\N	\N	\N
6283143886518:7@s.whatsapp.net	60178662629@s.whatsapp.net		1.29下午马来2721	\N	\N	\N
6283143886518:7@s.whatsapp.net	6288704403389@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	60133596515@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919566435947@s.whatsapp.net		XA293	\N	\N	\N
6283143886518:7@s.whatsapp.net	601114863557@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281296999398@s.whatsapp.net		Deniz Adiguna	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797412652@s.whatsapp.net		XOO-59	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281217558367@s.whatsapp.net		P56	\N	\N	\N
6283143886518:7@s.whatsapp.net	17873263129@s.whatsapp.net		BU-A129	\N	\N	\N
6283143886518:7@s.whatsapp.net	919828242261@s.whatsapp.net		XA267	\N	\N	\N
6283143886518:7@s.whatsapp.net	41795331235@s.whatsapp.net		XOO-10	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281291662227@s.whatsapp.net	Paisal. Gred	Paisal. Gred	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163089012@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60183199425@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164448664@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763471934@s.whatsapp.net		XOO-74	\N	\N	\N
6283143886518:7@s.whatsapp.net	601131632588@s.whatsapp.net		+601131632588	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810368372@s.whatsapp.net		QA130	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820104698@s.whatsapp.net		UJ255	\N	\N	\N
6283143886518:7@s.whatsapp.net	918528501522@s.whatsapp.net		XA254	\N	\N	\N
6283143886518:7@s.whatsapp.net	919737679313@s.whatsapp.net		XC373	\N	\N	\N
6283143886518:7@s.whatsapp.net	17028302358@s.whatsapp.net		BU-A171	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285770878223@s.whatsapp.net		Komar	\N	\N	\N
6283143886518:7@s.whatsapp.net	917300307709@s.whatsapp.net		UJ213	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162174641@s.whatsapp.net		1.29下午马来2786	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285797769139@s.whatsapp.net		Ridwan	\N	\N	\N
6283143886518:7@s.whatsapp.net	919928171289@s.whatsapp.net		QA128	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285217382750@s.whatsapp.net	Yani Krwng	Yani Krwng	\N	\N	\N
6283143886518:7@s.whatsapp.net	41791551055@s.whatsapp.net		XOO-7	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283806576244@s.whatsapp.net		MuL Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	13072236003@s.whatsapp.net		BU-A101	\N	\N	\N
6283143886518:7@s.whatsapp.net	916301900483@s.whatsapp.net		XC321	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831273391@s.whatsapp.net		XC389	\N	\N	\N
6283143886518:7@s.whatsapp.net	919502886603@s.whatsapp.net		XC399	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281918012703@s.whatsapp.net		95	\N	\N	\N
6283143886518:7@s.whatsapp.net	60137048366@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919602864836@s.whatsapp.net		XC367	\N	\N	\N
6283143886518:7@s.whatsapp.net	919790029270@s.whatsapp.net		XC341	\N	\N	\N
6283143886518:7@s.whatsapp.net	919894475686@s.whatsapp.net		QB56	\N	\N	\N
6283143886518:7@s.whatsapp.net	41767099357@s.whatsapp.net		XOO-82	\N	\N	\N
6283143886518:7@s.whatsapp.net	60138196428@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919849713815@s.whatsapp.net		QA187	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281319597090@s.whatsapp.net		Bag Joni	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282217874652@s.whatsapp.net		Zivanna	\N	\N	\N
6283143886518:7@s.whatsapp.net	601114932208@s.whatsapp.net		M	\N	\N	\N
6283143886518:7@s.whatsapp.net	601112978355@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	628997773903@s.whatsapp.net	Si Mon	Si Mon Simon	\N	\N	\N
6283143886518:7@s.whatsapp.net	919830529791@s.whatsapp.net		UJ271	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281284423891@s.whatsapp.net		P69	\N	\N	\N
6283143886518:7@s.whatsapp.net	919821256999@s.whatsapp.net		QA138	\N	\N	\N
6283143886518:7@s.whatsapp.net	60173107571@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798912947@s.whatsapp.net		XOO-40	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281318558636@s.whatsapp.net		Bpkb	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283871576795@s.whatsapp.net		Jueoo	\N	\N	\N
6283143886518:7@s.whatsapp.net	601129314148@s.whatsapp.net		+601129314148	\N	\N	\N
6283143886518:7@s.whatsapp.net	919958618058@s.whatsapp.net		QA177	\N	\N	\N
6283143886518:7@s.whatsapp.net	919740390937@s.whatsapp.net		QA110	\N	\N	\N
6283143886518:7@s.whatsapp.net	919930987119@s.whatsapp.net		XC376	\N	\N	\N
6283143886518:7@s.whatsapp.net	919650682982@s.whatsapp.net		QA148	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289519338425@s.whatsapp.net		yoseu2	\N	\N	\N
6283143886518:7@s.whatsapp.net	919029628107@s.whatsapp.net		UJ286	\N	\N	\N
6283143886518:7@s.whatsapp.net	919422101940@s.whatsapp.net		XA222	\N	\N	\N
6283143886518:7@s.whatsapp.net	60194926311@s.whatsapp.net		1.29下午马来2772	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163302600@s.whatsapp.net		1.29下午马来2755	\N	\N	\N
6283143886518:7@s.whatsapp.net	919429298592@s.whatsapp.net		XC353	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281381292714@s.whatsapp.net		86	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831362947@s.whatsapp.net		XA231	\N	\N	\N
6283143886518:7@s.whatsapp.net	919766663379@s.whatsapp.net		QA198	\N	\N	\N
6283143886518:7@s.whatsapp.net	918569924240@s.whatsapp.net		UJ245	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831842069@s.whatsapp.net		XA215	\N	\N	\N
6283143886518:7@s.whatsapp.net	60122502645@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41795128765@s.whatsapp.net		XOO-33	\N	\N	\N
6283143886518:7@s.whatsapp.net	919860855005@s.whatsapp.net		UJ297	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281281172627@s.whatsapp.net		P67	\N	\N	\N
6283143886518:7@s.whatsapp.net	17276678770@s.whatsapp.net		BU-A178	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820237314@s.whatsapp.net		QA191	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148482070@s.whatsapp.net		1.29下午马来2792	\N	\N	\N
6283143886518:7@s.whatsapp.net	41791374729@s.whatsapp.net		XOO-46	\N	\N	\N
6283143886518:7@s.whatsapp.net	18085611634@s.whatsapp.net		BU-A126	\N	\N	\N
6283143886518:7@s.whatsapp.net	919840710291@s.whatsapp.net		QB91	\N	\N	\N
6283143886518:7@s.whatsapp.net	60123356949@s.whatsapp.net		1.29下午马来2785	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895619188604@s.whatsapp.net		MIRAH	mirasumirah986	\N	\N
6283143886518:7@s.whatsapp.net	918985087933@s.whatsapp.net		XC392	\N	\N	\N
6283143886518:7@s.whatsapp.net	60146317703@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285771746432@s.whatsapp.net		Popay Cakra	\N	\N	\N
6283143886518:7@s.whatsapp.net	15037408194@s.whatsapp.net		BU-A197	\N	\N	\N
6283143886518:7@s.whatsapp.net	919840667642@s.whatsapp.net		QA140	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038877926@s.whatsapp.net		XC314	\N	\N	\N
6283143886518:7@s.whatsapp.net	60146314177@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	918910110654@s.whatsapp.net		UJ239	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282113449882@s.whatsapp.net		Ami Aidil Fah	\N	\N	\N
6283143886518:7@s.whatsapp.net	60122049008@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796375644@s.whatsapp.net		XOO-98	\N	\N	\N
6283143886518:7@s.whatsapp.net	60182050353@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285930246027@s.whatsapp.net		ManG Tarno. 11	\N	\N	\N
6283143886518:7@s.whatsapp.net	919699113980@s.whatsapp.net		QA156	\N	\N	\N
6283143886518:7@s.whatsapp.net	919492924808@s.whatsapp.net		UJ236	\N	\N	\N
6283143886518:7@s.whatsapp.net	12155780145@s.whatsapp.net		BU-A148	\N	\N	\N
6283143886518:7@s.whatsapp.net	919301681819@s.whatsapp.net		QB93	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163281171@s.whatsapp.net		1.29下午马来2745	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820245421@s.whatsapp.net		QA141	\N	\N	\N
6283143886518:7@s.whatsapp.net	628974035173@s.whatsapp.net		Jahara	\N	\N	\N
6283143886518:7@s.whatsapp.net	16264076266@s.whatsapp.net		BU-A191	\N	\N	\N
6283143886518:7@s.whatsapp.net	41788088674@s.whatsapp.net		XOO-13	\N	\N	\N
6283143886518:7@s.whatsapp.net	60138777990@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281290380518@s.whatsapp.net	Taruna Jaya Motor Jago	Taruna Jaya Motor Jago	\N	\N	\N
6283143886518:7@s.whatsapp.net	601126561823@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895347168951@s.whatsapp.net		P40	\N	\N	\N
6283143886518:7@s.whatsapp.net	41779426423@s.whatsapp.net		XOO-58	\N	\N	\N
6283143886518:7@s.whatsapp.net	41766801491@s.whatsapp.net		XOO-23	\N	\N	\N
6283143886518:7@s.whatsapp.net	918200502496@s.whatsapp.net		XA263	\N	\N	\N
6283143886518:7@s.whatsapp.net	601119886007@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281293168221@s.whatsapp.net		Dimas	\N	\N	\N
6283143886518:7@s.whatsapp.net	60126058722@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287841500669@s.whatsapp.net		P13	\N	\N	\N
6283143886518:7@s.whatsapp.net	918793863124@s.whatsapp.net		navy46 n46	\N	\N	\N
6283143886518:7@s.whatsapp.net	18594890949@s.whatsapp.net		BU-A104	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831354722@s.whatsapp.net		XC396	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285772994332@s.whatsapp.net		Mul 378	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281320937164@s.whatsapp.net		74	\N	\N	\N
6283143886518:7@s.whatsapp.net	919592504982@s.whatsapp.net		UJ279	\N	\N	\N
6283143886518:7@s.whatsapp.net	919988091244@s.whatsapp.net		QB74	\N	\N	\N
6283143886518:7@s.whatsapp.net	919376225513@s.whatsapp.net		QA113	\N	\N	\N
6283143886518:7@s.whatsapp.net	60197827950@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283824890437@s.whatsapp.net	Anto Jepang	Anto Jepang	\N	\N	\N
6283143886518:7@s.whatsapp.net	917680090257@s.whatsapp.net		XC361	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287765505967@s.whatsapp.net		P2	\N	\N	\N
6283143886518:7@s.whatsapp.net	601133228085@s.whatsapp.net		1.29下午马来2771	\N	\N	\N
6283143886518:7@s.whatsapp.net	919525309733@s.whatsapp.net		XC372	\N	\N	\N
6283143886518:7@s.whatsapp.net	60133019818@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919717038440@s.whatsapp.net		UJ294	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282298465507@s.whatsapp.net		Iwan Bote	\N	\N	\N
6283143886518:7@s.whatsapp.net	919876265611@s.whatsapp.net		XA202	\N	\N	\N
6283143886518:7@s.whatsapp.net	919398339364@s.whatsapp.net		navy49 n49	\N	\N	\N
6283143886518:7@s.whatsapp.net	60168721929@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919047020300@s.whatsapp.net		QB78	\N	\N	\N
6283143886518:7@s.whatsapp.net	919879431983@s.whatsapp.net		QA132	\N	\N	\N
6283143886518:7@s.whatsapp.net	919343827403@s.whatsapp.net		UJ228	\N	\N	\N
6283143886518:7@s.whatsapp.net	919111019389@s.whatsapp.net		XC335	\N	\N	\N
6283143886518:7@s.whatsapp.net	919923002405@s.whatsapp.net		QA142	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819487829@s.whatsapp.net		QA186	\N	\N	\N
6283143886518:7@s.whatsapp.net	601115303310@s.whatsapp.net		1.29下午马来2754	\N	\N	\N
6283143886518:7@s.whatsapp.net	919413660154@s.whatsapp.net		QB71	\N	\N	\N
6283143886518:7@s.whatsapp.net	601129672280@s.whatsapp.net		+601129672280	\N	\N	\N
6283143886518:7@s.whatsapp.net	601161712906@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41766813301@s.whatsapp.net		XOO-2	\N	\N	\N
6283143886518:7@s.whatsapp.net	919602504669@s.whatsapp.net		XC374	\N	\N	\N
6283143886518:7@s.whatsapp.net	919327733737@s.whatsapp.net		XA207	\N	\N	\N
6283143886518:7@s.whatsapp.net	919811841334@s.whatsapp.net		UJ237	\N	\N	\N
6283143886518:7@s.whatsapp.net	60198363299@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919920456985@s.whatsapp.net		QA117	\N	\N	\N
6283143886518:7@s.whatsapp.net	601117037247@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919850953620@s.whatsapp.net		QA162	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895346447500@s.whatsapp.net	 C Wati	C Wati	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819585820@s.whatsapp.net		QB72	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038792527@s.whatsapp.net		XC366	\N	\N	\N
6283143886518:7@s.whatsapp.net	60139772660@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919972014938@s.whatsapp.net		QB30	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831452069@s.whatsapp.net		UJ218	\N	\N	\N
6283143886518:7@s.whatsapp.net	60123870256@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162867717@s.whatsapp.net		1.29下午马来2756	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285850767416@s.whatsapp.net	Yanto Mentromini	Yanto Mentromini	\N	\N	\N
6283143886518:7@s.whatsapp.net	919840120628@s.whatsapp.net		QA143	\N	\N	\N
6283143886518:7@s.whatsapp.net	919838102014@s.whatsapp.net		QA200	\N	\N	\N
6283143886518:7@s.whatsapp.net	60193870797@s.whatsapp.net		1.29下午马来2736	\N	\N	\N
6283143886518:7@s.whatsapp.net	917984657723@s.whatsapp.net		XC345	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285882999492@s.whatsapp.net		BABAs	\N	\N	\N
6283143886518:7@s.whatsapp.net	919812000583@s.whatsapp.net		UJ295	\N	\N	\N
6283143886518:7@s.whatsapp.net	919400126800@s.whatsapp.net		UJ290	\N	\N	\N
6283143886518:7@s.whatsapp.net	41799000252@s.whatsapp.net		XOO-28	\N	\N	\N
6283143886518:7@s.whatsapp.net	601131701074@s.whatsapp.net		+601131701074	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804749060@s.whatsapp.net		XA288	\N	\N	\N
6283143886518:7@s.whatsapp.net	60165234885@s.whatsapp.net		1.29下午马来2774	\N	\N	\N
6283143886518:7@s.whatsapp.net	916206330297@s.whatsapp.net		XC356	\N	\N	\N
6283143886518:7@s.whatsapp.net	918223876466@s.whatsapp.net		XC315	\N	\N	\N
6283143886518:7@s.whatsapp.net	918454841369@s.whatsapp.net		XA234	\N	\N	\N
6283143886518:7@s.whatsapp.net	12536704454@s.whatsapp.net		BU-A125	\N	\N	\N
6283143886518:7@s.whatsapp.net	13476106461@s.whatsapp.net		BU-A127	\N	\N	\N
6283143886518:7@s.whatsapp.net	60127097972@s.whatsapp.net		1.29下午马来2726	\N	\N	\N
6283143886518:7@s.whatsapp.net	60102224484@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810828315@s.whatsapp.net		QB13	\N	\N	\N
6283143886518:7@s.whatsapp.net	919999039476@s.whatsapp.net		QB61	\N	\N	\N
6283143886518:7@s.whatsapp.net	919849044415@s.whatsapp.net		XA297	\N	\N	\N
6283143886518:7@s.whatsapp.net	919507681741@s.whatsapp.net		XA218	\N	\N	\N
6283143886518:7@s.whatsapp.net	919823438966@s.whatsapp.net		XC358	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895351342080@s.whatsapp.net		P17	\N	\N	\N
6283143886518:7@s.whatsapp.net	41795313450@s.whatsapp.net		XOO-106	\N	\N	\N
6283143886518:7@s.whatsapp.net	916309269778@s.whatsapp.net		XC346	\N	\N	\N
6283143886518:7@s.whatsapp.net	918734814134@s.whatsapp.net		navy28 n28	\N	\N	\N
6283143886518:7@s.whatsapp.net	919811901711@s.whatsapp.net		XC320	\N	\N	\N
6283143886518:7@s.whatsapp.net	919711370336@s.whatsapp.net		QB46	\N	\N	\N
6283143886518:7@s.whatsapp.net	41787738987@s.whatsapp.net		XOO-96	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281280928747@s.whatsapp.net		Jaenuri Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289612101693@s.whatsapp.net		Teteh Nisa	\N	\N	\N
6283143886518:7@s.whatsapp.net	41768052584@s.whatsapp.net		XOO-56	\N	\N	\N
6283143886518:7@s.whatsapp.net	919948199202@s.whatsapp.net		QB96	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831767205@s.whatsapp.net		XA233	\N	\N	\N
6283143886518:7@s.whatsapp.net	919552263755@s.whatsapp.net		UJ232	\N	\N	\N
6283143886518:7@s.whatsapp.net	917349189345@s.whatsapp.net		UJ269	\N	\N	\N
6283143886518:7@s.whatsapp.net	919300711640@s.whatsapp.net		XA289	\N	\N	\N
6283143886518:7@s.whatsapp.net	60178459058@s.whatsapp.net		Malaysia5	\N	\N	\N
6283143886518:7@s.whatsapp.net	601121072031@s.whatsapp.net		1.29下午马来2741	\N	\N	\N
6283143886518:7@s.whatsapp.net	919900907136@s.whatsapp.net		QB24	\N	\N	\N
6283143886518:7@s.whatsapp.net	601111749196@s.whatsapp.net		100	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282192429599@s.whatsapp.net		P8	\N	\N	\N
6283143886518:7@s.whatsapp.net	919823388002@s.whatsapp.net		QB75	\N	\N	\N
6283143886518:7@s.whatsapp.net	15164987318@s.whatsapp.net		BU-A177	\N	\N	\N
6283143886518:7@s.whatsapp.net	41786485133@s.whatsapp.net		XOO-75	\N	\N	\N
6283143886518:7@s.whatsapp.net	917008995847@s.whatsapp.net		XA292	\N	\N	\N
6283143886518:7@s.whatsapp.net	919824388727@s.whatsapp.net		QB15	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289655109902@s.whatsapp.net		Arya	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287885847447@s.whatsapp.net		Kacung	\N	\N	\N
6283143886518:7@s.whatsapp.net	12147737375@s.whatsapp.net		BU-A149	\N	\N	\N
6283143886518:7@s.whatsapp.net	60183920427@s.whatsapp.net		1.29下午马来2743	\N	\N	\N
6283143886518:7@s.whatsapp.net	919920171559@s.whatsapp.net		QA112	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810552208@s.whatsapp.net		QB95	\N	\N	\N
6283143886518:7@s.whatsapp.net	918144066532@s.whatsapp.net		XA237	\N	\N	\N
6283143886518:7@s.whatsapp.net	919073152623@s.whatsapp.net		UJ242	\N	\N	\N
6283143886518:7@s.whatsapp.net	919416700045@s.whatsapp.net		QB90	\N	\N	\N
6283143886518:7@s.whatsapp.net	13312013588@s.whatsapp.net		BU-A170	\N	\N	\N
6283143886518:7@s.whatsapp.net	919599399081@s.whatsapp.net		UJ288	\N	\N	\N
6283143886518:7@s.whatsapp.net	919422954095@s.whatsapp.net		XA225	\N	\N	\N
6283143886518:7@s.whatsapp.net	919871173721@s.whatsapp.net		QB98	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163365750@s.whatsapp.net		1.29下午马来2744	\N	\N	\N
6283143886518:7@s.whatsapp.net	601110706008@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919331039104@s.whatsapp.net		QB36	\N	\N	\N
6283143886518:7@s.whatsapp.net	13129190910@s.whatsapp.net		BU-A143	\N	\N	\N
6283143886518:7@s.whatsapp.net	919321458180@s.whatsapp.net		QA146	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289630298119@s.whatsapp.net		Ustdz Zein	\N	\N	\N
6283143886518:7@s.whatsapp.net	919216709460@s.whatsapp.net		QA180	\N	\N	\N
6283143886518:7@s.whatsapp.net	41792812398@s.whatsapp.net		XOO-1	\N	\N	\N
6283143886518:7@s.whatsapp.net	919841246929@s.whatsapp.net		QB5	\N	\N	\N
6283143886518:7@s.whatsapp.net	919824793074@s.whatsapp.net		QB50	\N	\N	\N
6283143886518:7@s.whatsapp.net	919825600386@s.whatsapp.net		QB73	\N	\N	\N
6283143886518:7@s.whatsapp.net	60139878027@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804621435@s.whatsapp.net		XA296	\N	\N	\N
6283143886518:7@s.whatsapp.net	919892742337@s.whatsapp.net		QB31	\N	\N	\N
6283143886518:7@s.whatsapp.net	60132308071@s.whatsapp.net		1.29下午马来2791	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804062523@s.whatsapp.net		XC348	\N	\N	\N
6283143886518:7@s.whatsapp.net	41766801906@s.whatsapp.net		XOO-105	\N	\N	\N
6283143886518:7@s.whatsapp.net	41787606378@s.whatsapp.net		XOO-20	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281393259172@s.whatsapp.net		90	\N	\N	\N
6283143886518:7@s.whatsapp.net	919377467225@s.whatsapp.net		XA248	\N	\N	\N
6283143886518:7@s.whatsapp.net	919230772832@s.whatsapp.net		XA209	\N	\N	\N
6283143886518:7@s.whatsapp.net	919840318520@s.whatsapp.net		QA106	\N	\N	\N
6283143886518:7@s.whatsapp.net	60126329172@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919567350670@s.whatsapp.net		XA278	\N	\N	\N
6283143886518:7@s.whatsapp.net	919894161111@s.whatsapp.net		QB84	\N	\N	\N
6283143886518:7@s.whatsapp.net	60146598223@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919322728426@s.whatsapp.net		XA269	\N	\N	\N
6283143886518:7@s.whatsapp.net	919490428888@s.whatsapp.net		UJ256	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283823190241@s.whatsapp.net	A Rio	A Rio	🚀Kang Cukur💈	\N	\N
6283143886518:7@s.whatsapp.net	601110311761@s.whatsapp.net		1.29下午马来2738	\N	\N	\N
6283143886518:7@s.whatsapp.net	60129526883@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285888448229@s.whatsapp.net		Suryanto	\N	\N	\N
6283143886518:7@s.whatsapp.net	919762218230@s.whatsapp.net		XC334	\N	\N	\N
6283143886518:7@s.whatsapp.net	919884311273@s.whatsapp.net		QA119	\N	\N	\N
6283143886518:7@s.whatsapp.net	60139075001@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	60133782440@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289601766884@s.whatsapp.net		Basit	\N	\N	\N
6283143886518:7@s.whatsapp.net	60165047860@s.whatsapp.net		1.29下午马来2730	\N	\N	\N
6283143886518:7@s.whatsapp.net	60172462641@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41799440012@s.whatsapp.net		XOO-70	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281290983204@s.whatsapp.net		Boy Tpu	\N	\N	\N
6283143886518:7@s.whatsapp.net	918401602719@s.whatsapp.net		navy22 n22	\N	\N	\N
6283143886518:7@s.whatsapp.net	919351409237@s.whatsapp.net		QB44	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797747225@s.whatsapp.net		XOO-43	\N	\N	\N
6283143886518:7@s.whatsapp.net	601121290813@s.whatsapp.net		1.29下午马来2758	\N	\N	\N
6283143886518:7@s.whatsapp.net	60105419263@s.whatsapp.net	Malaysia 12	Malaysia 12	\N	\N	\N
6283143886518:7@s.whatsapp.net	41765381031@s.whatsapp.net		XOO-29	\N	\N	\N
6283143886518:7@s.whatsapp.net	919821570496@s.whatsapp.net		QB37	\N	\N	\N
6283143886518:7@s.whatsapp.net	41794792254@s.whatsapp.net		XOO-4	\N	\N	\N
6283143886518:7@s.whatsapp.net	17868518158@s.whatsapp.net		BU-A146	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763397952@s.whatsapp.net		XOO-89	\N	\N	\N
6283143886518:7@s.whatsapp.net	919515469600@s.whatsapp.net		UJ285	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285874062331@s.whatsapp.net		P42	\N	\N	\N
6283143886518:7@s.whatsapp.net	60168184969@s.whatsapp.net		Malaysia3	\N	\N	\N
6283143886518:7@s.whatsapp.net	919334200606@s.whatsapp.net		XA213	\N	\N	\N
6283143886518:7@s.whatsapp.net	41774471387@s.whatsapp.net		XOO-53	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281510226669@s.whatsapp.net	💫Om AdinG⚽☕ 1zf	💫Om AdinG⚽☕ 1zf 7c 🚬	\N	\N	\N
6283143886518:7@s.whatsapp.net	919765361147@s.whatsapp.net		QB76	\N	\N	\N
6283143886518:7@s.whatsapp.net	919884146750@s.whatsapp.net		QB58	\N	\N	\N
6283143886518:7@s.whatsapp.net	919958095210@s.whatsapp.net		XA214	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285714394151@s.whatsapp.net		Kecu	\N	\N	\N
6283143886518:7@s.whatsapp.net	919008490942@s.whatsapp.net		XA270	\N	\N	\N
6283143886518:7@s.whatsapp.net	60139850029@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281399264270@s.whatsapp.net		Wodus 378	\N	\N	\N
6283143886518:7@s.whatsapp.net	919000121070@s.whatsapp.net		UJ211	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285158897122@s.whatsapp.net		BOGOR	\N	\N	\N
6283143886518:7@s.whatsapp.net	16035589396@s.whatsapp.net		BU-A109	\N	\N	\N
6283143886518:7@s.whatsapp.net	919600198472@s.whatsapp.net		QA152	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149061217@s.whatsapp.net		1.29下午马来2746	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282241900998@s.whatsapp.net	B0t3 Tegal	B0t3 Tegal ꦧ꧀ꦭꦼꦝꦺꦒ꧀ ꦕꦶꦭꦶꦏ꧀	\N	\N	\N
6283143886518:7@s.whatsapp.net	918870130293@s.whatsapp.net		XA220	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285183282200@s.whatsapp.net		Gadai	\N	\N	\N
6283143886518:7@s.whatsapp.net	41793219396@s.whatsapp.net		XOO-88	\N	\N	\N
6283143886518:7@s.whatsapp.net	60168449060@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	601123739736@s.whatsapp.net		1.29下午马来2773	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281617174016@s.whatsapp.net		Iboy	\N	\N	\N
6283143886518:7@s.whatsapp.net	917263047964@s.whatsapp.net		UJ219	\N	\N	\N
6283143886518:7@s.whatsapp.net	918179051359@s.whatsapp.net		XA265	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148654461@s.whatsapp.net		1.29下午马来2735	\N	\N	\N
6283143886518:7@s.whatsapp.net	919843167092@s.whatsapp.net		XC360	\N	\N	\N
6283143886518:7@s.whatsapp.net	15738816307@s.whatsapp.net		BU-A181	\N	\N	\N
6283143886518:7@s.whatsapp.net	628129235673@s.whatsapp.net	BIG B0s	BIG B0s Acen	\N	\N	\N
6283143886518:7@s.whatsapp.net	13012660603@s.whatsapp.net		BU-A132	\N	\N	\N
6283143886518:7@s.whatsapp.net	15612998839@s.whatsapp.net		BU-A199	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281217247489@s.whatsapp.net		P52	\N	\N	\N
6283143886518:7@s.whatsapp.net	60102594980@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282297377214@s.whatsapp.net	Yudi Setu	Yudi Setu	\N	\N	\N
6283143886518:7@s.whatsapp.net	918282928013@s.whatsapp.net		XC304	\N	\N	\N
6283143886518:7@s.whatsapp.net	41791548385@s.whatsapp.net		XOO-102	\N	\N	\N
6283143886518:7@s.whatsapp.net	919322262116@s.whatsapp.net		QA174	\N	\N	\N
6283143886518:7@s.whatsapp.net	18307395703@s.whatsapp.net		BU-A179	\N	\N	\N
6283143886518:7@s.whatsapp.net	919176621136@s.whatsapp.net		XA221	\N	\N	\N
6283143886518:7@s.whatsapp.net	60175850191@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285860548516@s.whatsapp.net		P44	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285330785084@s.whatsapp.net		92	\N	\N	\N
6283143886518:7@s.whatsapp.net	919214837757@s.whatsapp.net		UJ275	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164097093@s.whatsapp.net		1.29下午马来2750	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287777792428@s.whatsapp.net		Bengkel	\N	\N	\N
6283143886518:7@s.whatsapp.net	919346849593@s.whatsapp.net		XC313	\N	\N	\N
6283143886518:7@s.whatsapp.net	60193233039@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	62817771711@s.whatsapp.net	Pak RT Sunter	Pak RT Sunter	\N	\N	\N
6283143886518:7@s.whatsapp.net	601119793595@s.whatsapp.net		1.29下午马来2760	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285124494102@s.whatsapp.net		Bapak	ye0tkqmiv4	\N	\N
6283143886518:7@s.whatsapp.net	6285714062254@s.whatsapp.net		Wiwin Once	\N	\N	\N
6283143886518:7@s.whatsapp.net	919868339048@s.whatsapp.net		UJ273	\N	\N	\N
6283143886518:7@s.whatsapp.net	919000194183@s.whatsapp.net		UJ292	\N	\N	\N
6283143886518:7@s.whatsapp.net	60138691261@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919899003040@s.whatsapp.net		QA185	\N	\N	\N
6283143886518:7@s.whatsapp.net	60139139055@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41792988497@s.whatsapp.net		XOO-79	\N	\N	\N
6283143886518:7@s.whatsapp.net	919870227291@s.whatsapp.net		QA147	\N	\N	\N
6283143886518:7@s.whatsapp.net	919011234772@s.whatsapp.net		UJ225	\N	\N	\N
6283143886518:7@s.whatsapp.net	41786258666@s.whatsapp.net		XOO-34	\N	\N	\N
6283143886518:7@s.whatsapp.net	919885235602@s.whatsapp.net		XC336	\N	\N	\N
6283143886518:7@s.whatsapp.net	919910049656@s.whatsapp.net		QB70	\N	\N	\N
6283143886518:7@s.whatsapp.net	919943990703@s.whatsapp.net		QA139	\N	\N	\N
6283143886518:7@s.whatsapp.net	919821882721@s.whatsapp.net		QB45	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810918757@s.whatsapp.net		QA127	\N	\N	\N
6283143886518:7@s.whatsapp.net	60122626939@s.whatsapp.net		1.29下午马来2798	\N	\N	\N
6283143886518:7@s.whatsapp.net	919915772884@s.whatsapp.net		QB2	\N	\N	\N
6283143886518:7@s.whatsapp.net	41792397296@s.whatsapp.net		XOO-60	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819613241@s.whatsapp.net		QB48	\N	\N	\N
6283143886518:7@s.whatsapp.net	41766235861@s.whatsapp.net		XOO-67	\N	\N	\N
6283143886518:7@s.whatsapp.net	919962531313@s.whatsapp.net		XA262	\N	\N	\N
6283143886518:7@s.whatsapp.net	919960500523@s.whatsapp.net		QA175	\N	\N	\N
6283143886518:7@s.whatsapp.net	601110970531@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283871962992@s.whatsapp.net		tukang Balon	\N	\N	\N
6283143886518:7@s.whatsapp.net	601127066163@s.whatsapp.net		1.29下午马来2797	\N	\N	\N
6283143886518:7@s.whatsapp.net	60143084827@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	918207065812@s.whatsapp.net		XA259	\N	\N	\N
6283143886518:7@s.whatsapp.net	918961313982@s.whatsapp.net		XA252	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285182550467@s.whatsapp.net	Ari 	Ari Ambulance	\N	\N	\N
6283143886518:7@s.whatsapp.net	60193805425@s.whatsapp.net		1.29下午马来2778	\N	\N	\N
6283143886518:7@s.whatsapp.net	41765015554@s.whatsapp.net		XOO-5	\N	\N	\N
6283143886518:7@s.whatsapp.net	919427424514@s.whatsapp.net		QB88	\N	\N	\N
6283143886518:7@s.whatsapp.net	60142261622@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285322079020@s.whatsapp.net		Ibu Zahara	\N	\N	\N
6283143886518:7@s.whatsapp.net	19257279624@s.whatsapp.net		BU-A113	\N	\N	\N
6283143886518:7@s.whatsapp.net	60194500102@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	628159929046@s.whatsapp.net		0m DEDE Muntir	\N	\N	\N
6283143886518:7@s.whatsapp.net	919434672759@s.whatsapp.net		QB69	\N	\N	\N
6283143886518:7@s.whatsapp.net	17873542883@s.whatsapp.net		BU-A121	\N	\N	\N
6283143886518:7@s.whatsapp.net	919985012334@s.whatsapp.net		QA179	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283114994512@s.whatsapp.net		P16	\N	\N	\N
6283143886518:7@s.whatsapp.net	919884358878@s.whatsapp.net		QB7	\N	\N	\N
6283143886518:7@s.whatsapp.net	918369948858@s.whatsapp.net		XC311	\N	\N	\N
6283143886518:7@s.whatsapp.net	60173520715@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919073479818@s.whatsapp.net		UJ270	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162563594@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285182607835@s.whatsapp.net		Al	\N	\N	\N
6283143886518:7@s.whatsapp.net	918621041000@s.whatsapp.net		XA255	\N	\N	\N
6283143886518:7@s.whatsapp.net	60122858204@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	601111968407@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919891577333@s.whatsapp.net		QB68	\N	\N	\N
6283143886518:7@s.whatsapp.net	919986236092@s.whatsapp.net		QB67	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281549756656@s.whatsapp.net		96	\N	\N	\N
6283143886518:7@s.whatsapp.net	919876424563@s.whatsapp.net		QB49	\N	\N	\N
6283143886518:7@s.whatsapp.net	919975885836@s.whatsapp.net		QA197	\N	\N	\N
6283143886518:7@s.whatsapp.net	60142579959@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919000169587@s.whatsapp.net		UJ216	\N	\N	\N
6283143886518:7@s.whatsapp.net	628176588676@s.whatsapp.net	Amir JNT	Amir JNT	\N	\N	\N
6283143886518:7@s.whatsapp.net	918961308522@s.whatsapp.net		XA260	\N	\N	\N
6283143886518:7@s.whatsapp.net	919691718596@s.whatsapp.net		UJ240	\N	\N	\N
6283143886518:7@s.whatsapp.net	19545515899@s.whatsapp.net		BU-A167	\N	\N	\N
6283143886518:7@s.whatsapp.net	919850025466@s.whatsapp.net		QB38	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285702028651@s.whatsapp.net		PEpen	\N	\N	\N
6283143886518:7@s.whatsapp.net	60195198405@s.whatsapp.net		1.29下午马来2766	\N	\N	\N
6283143886518:7@s.whatsapp.net	41788599073@s.whatsapp.net		XOO-15	\N	\N	\N
6283143886518:7@s.whatsapp.net	919719358064@s.whatsapp.net		XA228	\N	\N	\N
6283143886518:7@s.whatsapp.net	60194015988@s.whatsapp.net		Maysia6	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819098460@s.whatsapp.net		QB10	\N	\N	\N
6283143886518:7@s.whatsapp.net	919949351359@s.whatsapp.net		UJ272	\N	\N	\N
6283143886518:7@s.whatsapp.net	919000220243@s.whatsapp.net		XC386	\N	\N	\N
6283143886518:7@s.whatsapp.net	919892940905@s.whatsapp.net		QB29	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281394323020@s.whatsapp.net	Bi Haji	Bi Haji	\N	\N	\N
6283143886518:7@s.whatsapp.net	16317477045@s.whatsapp.net		BU-A166	\N	\N	\N
6283143886518:7@s.whatsapp.net	14074932483@s.whatsapp.net		BU-A151	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163977818@s.whatsapp.net		1.29下午马来2732	\N	\N	\N
6283143886518:7@s.whatsapp.net	919815246657@s.whatsapp.net		QB25	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281317297770@s.whatsapp.net		Pedok Cakung	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282112410806@s.whatsapp.net		Irwan Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	41788887720@s.whatsapp.net		XOO-22	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831971861@s.whatsapp.net		XC328	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148158938@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281381638363@s.whatsapp.net		Husen greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819446448@s.whatsapp.net		QB16	\N	\N	\N
6283143886518:7@s.whatsapp.net	601131725694@s.whatsapp.net		+601131725694	\N	\N	\N
6283143886518:7@s.whatsapp.net	15185698190@s.whatsapp.net		BU-A192	\N	\N	\N
6283143886518:7@s.whatsapp.net	601162232611@s.whatsapp.net		A3.admin3 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281212556772@s.whatsapp.net		Wawa Enju	𝕁𝕠𝕖𝕡𝕦𝕝𝕝𝕚𝕟𝕘𝕔𝕒𝕓𝕝𝕖	\N	\N
6283143886518:7@s.whatsapp.net	916005278396@s.whatsapp.net		XC342	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797344207@s.whatsapp.net		XOO-101	\N	\N	\N
6283143886518:7@s.whatsapp.net	41789766343@s.whatsapp.net		XOO-11	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285713300137@s.whatsapp.net		Agus P11	\N	\N	\N
6283143886518:7@s.whatsapp.net	919549819049@s.whatsapp.net		XA276	\N	\N	\N
6283143886518:7@s.whatsapp.net	19259677694@s.whatsapp.net		BU-A162	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289618114309@s.whatsapp.net		wito	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831335404@s.whatsapp.net		XC364	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281398176842@s.whatsapp.net		Regal.Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831349692@s.whatsapp.net		XC383	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281808004555@s.whatsapp.net		ABAh SuNar	\N	\N	\N
6283143886518:7@s.whatsapp.net	919032446365@s.whatsapp.net		UJ217	\N	\N	\N
6283143886518:7@s.whatsapp.net	19392099780@s.whatsapp.net		BU-A141	\N	\N	\N
6283143886518:7@s.whatsapp.net	919844885645@s.whatsapp.net		QB23	\N	\N	\N
6283143886518:7@s.whatsapp.net	601112931152@s.whatsapp.net		Malaysia2	\N	\N	\N
6283143886518:7@s.whatsapp.net	60145070349@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	17183140628@s.whatsapp.net		BU-A156	\N	\N	\N
6283143886518:7@s.whatsapp.net	919906754270@s.whatsapp.net		UJ208	\N	\N	\N
6283143886518:7@s.whatsapp.net	14253209126@s.whatsapp.net		BU-A175	\N	\N	\N
6283143886518:7@s.whatsapp.net	919666450433@s.whatsapp.net		UJ287	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285156275598@s.whatsapp.net		Kion	\N	\N	\N
6283143886518:7@s.whatsapp.net	6288211847262@s.whatsapp.net		Entong Ayah	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820319002@s.whatsapp.net		QA181	\N	\N	\N
6283143886518:7@s.whatsapp.net	919403773005@s.whatsapp.net		UJ233	\N	\N	\N
6283143886518:7@s.whatsapp.net	60176826175@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	918930058981@s.whatsapp.net		XA250	\N	\N	\N
6283143886518:7@s.whatsapp.net	19784434524@s.whatsapp.net		BU-A145	\N	\N	\N
6283143886518:7@s.whatsapp.net	917617505918@s.whatsapp.net		UJ291	\N	\N	\N
6283143886518:7@s.whatsapp.net	60165582507@s.whatsapp.net		1.29下午马来2781	\N	\N	\N
6283143886518:7@s.whatsapp.net	41774007520@s.whatsapp.net		XOO-6	\N	\N	\N
6283143886518:7@s.whatsapp.net	919994997599@s.whatsapp.net		QA126	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287700101063@s.whatsapp.net	Simpati FM	Simpati FM	\N	\N	\N
6283143886518:7@s.whatsapp.net	60102013227@s.whatsapp.net		1.29下午马来2782	\N	\N	\N
6283143886518:7@s.whatsapp.net	918487963706@s.whatsapp.net		navy11 n11	\N	\N	\N
6283143886518:7@s.whatsapp.net	919028595404@s.whatsapp.net		UJ227	\N	\N	\N
6283143886518:7@s.whatsapp.net	60176053789@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919881107645@s.whatsapp.net		QB43	\N	\N	\N
6283143886518:7@s.whatsapp.net	17863855756@s.whatsapp.net		BU-A118	\N	\N	\N
6283143886518:7@s.whatsapp.net	919920389474@s.whatsapp.net		UJ280	\N	\N	\N
6283143886518:7@s.whatsapp.net	918340761236@s.whatsapp.net		XC303	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289649769286@s.whatsapp.net		Denu Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162671128@s.whatsapp.net		1.29下午马来2794	\N	\N	\N
6283143886518:7@s.whatsapp.net	60145080420@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	17329868552@s.whatsapp.net		BU-A137	\N	\N	\N
6283143886518:7@s.whatsapp.net	919324031216@s.whatsapp.net		QB34	\N	\N	\N
6283143886518:7@s.whatsapp.net	60197913178@s.whatsapp.net		1.29下午马来2767	\N	\N	\N
6283143886518:7@s.whatsapp.net	918891965942@s.whatsapp.net		navy54 n54	\N	\N	\N
6283143886518:7@s.whatsapp.net	919270702921@s.whatsapp.net		QB33	\N	\N	\N
6283143886518:7@s.whatsapp.net	60126046889@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	917038399937@s.whatsapp.net		XA283	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281294449374@s.whatsapp.net		Gondrong	\N	\N	\N
6283143886518:7@s.whatsapp.net	41764026277@s.whatsapp.net		XOO-83	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285810105638@s.whatsapp.net	Ateu Aan	Ateu Aan	mama baim n aulia	\N	\N
6283143886518:7@s.whatsapp.net	919143259945@s.whatsapp.net		XA243	\N	\N	\N
6283143886518:7@s.whatsapp.net	60176015933@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	918470060724@s.whatsapp.net		XA268	\N	\N	\N
6283143886518:7@s.whatsapp.net	601130795183@s.whatsapp.net		+601130795183	\N	\N	\N
6283143886518:7@s.whatsapp.net	12762023075@s.whatsapp.net		BU-A157	\N	\N	\N
6283143886518:7@s.whatsapp.net	60176706858@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	19399690369@s.whatsapp.net		BU-A123	\N	\N	\N
6283143886518:7@s.whatsapp.net	41764236363@s.whatsapp.net		XOO-85	\N	\N	\N
6283143886518:7@s.whatsapp.net	19176830738@s.whatsapp.net		BU-A116	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281385597200@s.whatsapp.net		Bang Maul	\N	\N	\N
6283143886518:7@s.whatsapp.net	13126590995@s.whatsapp.net		BU-A128	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285778473628@s.whatsapp.net	Ibnu Marga Jaya	Ibnu Marga Jaya	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281383490396@s.whatsapp.net	Uwa Tinggal	Uwa Tinggal	\N	\N	\N
6283143886518:7@s.whatsapp.net	919899363833@s.whatsapp.net		XC331	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831819405@s.whatsapp.net		XA249	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282216863355@s.whatsapp.net		Aka Priatna	priatnafazka	\N	\N
6283143886518:7@s.whatsapp.net	919743866234@s.whatsapp.net		QB62	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804998688@s.whatsapp.net		UJ298	\N	\N	\N
6283143886518:7@s.whatsapp.net	60127830049@s.whatsapp.net		1.29下午马来2799	\N	\N	\N
6283143886518:7@s.whatsapp.net	919995677170@s.whatsapp.net		QA150	\N	\N	\N
6283143886518:7@s.whatsapp.net	919896208604@s.whatsapp.net		XC369	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820571593@s.whatsapp.net		QB92	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281331189503@s.whatsapp.net		P25	\N	\N	\N
6283143886518:7@s.whatsapp.net	60193644867@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41789230397@s.whatsapp.net		XOO-14	\N	\N	\N
6283143886518:7@s.whatsapp.net	13474971110@s.whatsapp.net		BU-A196	\N	\N	\N
6283143886518:7@s.whatsapp.net	6288214023658@s.whatsapp.net		Blanck 2	\N	\N	\N
6283143886518:7@s.whatsapp.net	41786938212@s.whatsapp.net		XOO-64	\N	\N	\N
6283143886518:7@s.whatsapp.net	41787518002@s.whatsapp.net		XOO-72	\N	\N	\N
6283143886518:7@s.whatsapp.net	14022175600@s.whatsapp.net		BU-A136	\N	\N	\N
6283143886518:7@s.whatsapp.net	41795586708@s.whatsapp.net		XOO-49	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282180026931@s.whatsapp.net		P26	\N	\N	\N
6283143886518:7@s.whatsapp.net	12423761619@s.whatsapp.net		BU-A195	\N	\N	\N
6283143886518:7@s.whatsapp.net	41791915370@s.whatsapp.net		XOO-19	\N	\N	\N
6283143886518:7@s.whatsapp.net	919833272403@s.whatsapp.net		XC349	\N	\N	\N
6283143886518:7@s.whatsapp.net	919964076407@s.whatsapp.net		UJ274	\N	\N	\N
6283143886518:7@s.whatsapp.net	15418915400@s.whatsapp.net		BU-A138	\N	\N	\N
6283143886518:7@s.whatsapp.net	60189184593@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	918115883392@s.whatsapp.net		UJ289	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281243295071@s.whatsapp.net		P43	\N	\N	\N
6283143886518:7@s.whatsapp.net	919925245977@s.whatsapp.net		XA238	\N	\N	\N
6283143886518:7@s.whatsapp.net	601133501030@s.whatsapp.net		1.29下午马来2751	\N	\N	\N
6283143886518:7@s.whatsapp.net	601127712970@s.whatsapp.net		+601127712970	\N	\N	\N
6283143886518:7@s.whatsapp.net	60133418696@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41787931731@s.whatsapp.net		XOO-44	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285750888385@s.whatsapp.net		Maul2	\N	\N	\N
6283143886518:7@s.whatsapp.net	918976141788@s.whatsapp.net		UJ277	\N	\N	\N
6283143886518:7@s.whatsapp.net	601119951805@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820935848@s.whatsapp.net		QA107	\N	\N	\N
6283143886518:7@s.whatsapp.net	60169626601@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919945538433@s.whatsapp.net		XA266	\N	\N	\N
6283143886518:7@s.whatsapp.net	919304483782@s.whatsapp.net		UJ260	\N	\N	\N
6283143886518:7@s.whatsapp.net	919811938829@s.whatsapp.net		QA171	\N	\N	\N
6283143886518:7@s.whatsapp.net	919873112129@s.whatsapp.net		QA102	\N	\N	\N
6283143886518:7@s.whatsapp.net	919967377504@s.whatsapp.net		QA155	\N	\N	\N
6283143886518:7@s.whatsapp.net	60138469487@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281246128945@s.whatsapp.net		P63	\N	\N	\N
6283143886518:7@s.whatsapp.net	60124331405@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281806310668@s.whatsapp.net		Ajong123	\N	\N	\N
6283143886518:7@s.whatsapp.net	60194157639@s.whatsapp.net		1.29下午马来2789	\N	\N	\N
6283143886518:7@s.whatsapp.net	919850896224@s.whatsapp.net		XA204	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285955164742@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763800429@s.whatsapp.net		XOO-57	\N	\N	\N
6283143886518:7@s.whatsapp.net	919006183211@s.whatsapp.net		XA271	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162568114@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919971353728@s.whatsapp.net		QA169	\N	\N	\N
6283143886518:7@s.whatsapp.net	919341841223@s.whatsapp.net		QA103	\N	\N	\N
6283143886518:7@s.whatsapp.net	601162233175@s.whatsapp.net		05/02M2管理admin	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162200239@s.whatsapp.net		1.29下午马来2776	\N	\N	\N
6283143886518:7@s.whatsapp.net	917735878535@s.whatsapp.net		UJ224	\N	\N	\N
6283143886518:7@s.whatsapp.net	919953555158@s.whatsapp.net		XC391	\N	\N	\N
6283143886518:7@s.whatsapp.net	919886838311@s.whatsapp.net		XA258	\N	\N	\N
6283143886518:7@s.whatsapp.net	19047191588@s.whatsapp.net		BU-A168	\N	\N	\N
6283143886518:7@s.whatsapp.net	919866492168@s.whatsapp.net		XC365	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164902077@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	601128709137@s.whatsapp.net		1.29下午马来2764	\N	\N	\N
6283143886518:7@s.whatsapp.net	919552522394@s.whatsapp.net		XC395	\N	\N	\N
6283143886518:7@s.whatsapp.net	919916578177@s.whatsapp.net		QB94	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199053508@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41762315933@s.whatsapp.net		XOO-35	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281344137514@s.whatsapp.net		Di2t	\N	\N	\N
6283143886518:7@s.whatsapp.net	919225532949@s.whatsapp.net		QA105	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148657179@s.whatsapp.net		1.29下午马来2731	\N	\N	\N
6283143886518:7@s.whatsapp.net	919899628181@s.whatsapp.net		QA170	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282123073379@s.whatsapp.net		ADadat New	\N	\N	\N
6283143886518:7@s.whatsapp.net	919673106905@s.whatsapp.net		XA219	\N	\N	\N
6283143886518:7@s.whatsapp.net	919989397229@s.whatsapp.net		XC307	\N	\N	\N
6283143886518:7@s.whatsapp.net	919773713808@s.whatsapp.net		QA124	\N	\N	\N
6283143886518:7@s.whatsapp.net	919873560522@s.whatsapp.net		QB99	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281280004280@s.whatsapp.net	Steven Greb	Steven Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	60182688939@s.whatsapp.net		1.29下午马来2725	\N	\N	\N
6283143886518:7@s.whatsapp.net	919939383375@s.whatsapp.net		XA286	\N	\N	\N
6283143886518:7@s.whatsapp.net	41787429838@s.whatsapp.net		XOO-84	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149852257@s.whatsapp.net		1.29下午马来2783	\N	\N	\N
6283143886518:7@s.whatsapp.net	601110926050@s.whatsapp.net		1.29下午马来2770	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281290678551@s.whatsapp.net	Cahaya Narogong	Cahaya Narogong	\N	\N	\N
6283143886518:7@s.whatsapp.net	15747271554@s.whatsapp.net		BU-A194	\N	\N	\N
6283143886518:7@s.whatsapp.net	919879874470@s.whatsapp.net		QB14	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149488936@s.whatsapp.net		1.29下午马来2761	\N	\N	\N
6283143886518:7@s.whatsapp.net	60166671837@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285721434307@s.whatsapp.net		Mang nono	\N	\N	\N
6283143886518:7@s.whatsapp.net	919824406929@s.whatsapp.net		QA182	\N	\N	\N
6283143886518:7@s.whatsapp.net	919711025987@s.whatsapp.net		QB64	\N	\N	\N
6283143886518:7@s.whatsapp.net	919823101477@s.whatsapp.net		QB81	\N	\N	\N
6283143886518:7@s.whatsapp.net	919730356761@s.whatsapp.net		XA284	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289517751884@s.whatsapp.net		☕iyan	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831471414@s.whatsapp.net		UJ258	\N	\N	\N
6283143886518:7@s.whatsapp.net	917071439044@s.whatsapp.net		UJ264	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810499686@s.whatsapp.net		XC357	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282362290111@s.whatsapp.net	Himalayang TaNggeRan	Himalayang TaNggeRan	\N	\N	\N
6283143886518:7@s.whatsapp.net	18052945612@s.whatsapp.net		BU-A117	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281238691528@s.whatsapp.net		P61	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810403457@s.whatsapp.net		QA134	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285810033500@s.whatsapp.net		Kerupuk 085810033500	\N	\N	\N
6283143886518:7@s.whatsapp.net	919949503777@s.whatsapp.net		QA135	\N	\N	\N
6283143886518:7@s.whatsapp.net	15593269340@s.whatsapp.net		BU-A163	\N	\N	\N
6283143886518:7@s.whatsapp.net	918792255508@s.whatsapp.net		XC355	\N	\N	\N
6283143886518:7@s.whatsapp.net	917006447514@s.whatsapp.net		UJ243	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798799606@s.whatsapp.net		XOO-95	\N	\N	\N
6283143886518:7@s.whatsapp.net	919944086981@s.whatsapp.net		XA298	\N	\N	\N
6283143886518:7@s.whatsapp.net	919980873719@s.whatsapp.net		QB63	\N	\N	\N
6283143886518:7@s.whatsapp.net	919876058009@s.whatsapp.net		QA164	\N	\N	\N
6283143886518:7@s.whatsapp.net	919899995085@s.whatsapp.net		QB18	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038790596@s.whatsapp.net		UJ251	\N	\N	\N
6283143886518:7@s.whatsapp.net	919824251135@s.whatsapp.net		QA137	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798132067@s.whatsapp.net		XOO-86	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287734759404@s.whatsapp.net	Sodik Brebes	Sodik Brebes	\N	\N	\N
6283143886518:7@s.whatsapp.net	919514455661@s.whatsapp.net		XA208	\N	\N	\N
6283143886518:7@s.whatsapp.net	919730422001@s.whatsapp.net		QB77	\N	\N	\N
6283143886518:7@s.whatsapp.net	41799512150@s.whatsapp.net		XOO-41	\N	\N	\N
6283143886518:7@s.whatsapp.net	41799509508@s.whatsapp.net		XOO-42	\N	\N	\N
6283143886518:7@s.whatsapp.net	919143008935@s.whatsapp.net		XA210	\N	\N	\N
6283143886518:7@s.whatsapp.net	919830221966@s.whatsapp.net		XA287	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281617520801@s.whatsapp.net		Veri	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281289712268@s.whatsapp.net		Kemtom	\N	\N	\N
6283143886518:7@s.whatsapp.net	919000124496@s.whatsapp.net		XC382	\N	\N	\N
6283143886518:7@s.whatsapp.net	919582393588@s.whatsapp.net		XC359	\N	\N	\N
6283143886518:7@s.whatsapp.net	919892627648@s.whatsapp.net		QA131	\N	\N	\N
6283143886518:7@s.whatsapp.net	601121925911@s.whatsapp.net		1.29下午马来2788	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281564920309@s.whatsapp.net	Bpk Zki	Bpk Zki	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038403985@s.whatsapp.net		UJ214	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289676298813@s.whatsapp.net		Rheno Kebo	\N	\N	\N
6283143886518:7@s.whatsapp.net	919810581303@s.whatsapp.net		QB65	\N	\N	\N
6283143886518:7@s.whatsapp.net	41793698872@s.whatsapp.net		XOO-50	\N	\N	\N
6283143886518:7@s.whatsapp.net	41765587009@s.whatsapp.net		XOO-45	\N	\N	\N
6283143886518:7@s.whatsapp.net	60109531178@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	41791746459@s.whatsapp.net		XOO-26	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289629332933@s.whatsapp.net	Dian obras	Dian obras	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281312339799@s.whatsapp.net		bowo333	\N	\N	\N
6283143886518:7@s.whatsapp.net	918105240577@s.whatsapp.net		UJ230	\N	\N	\N
6283143886518:7@s.whatsapp.net	919988904848@s.whatsapp.net		QB3	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763493123@s.whatsapp.net		XOO-103	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287716954097@s.whatsapp.net		Mang Kirman	\N	\N	\N
6283143886518:7@s.whatsapp.net	60173594539@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163378080@s.whatsapp.net		1.29下午马来2748	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831957783@s.whatsapp.net		XC343	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895413224772@s.whatsapp.net		Abah Oii	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796456726@s.whatsapp.net		XOO-93	\N	\N	\N
6283143886518:7@s.whatsapp.net	16034012452@s.whatsapp.net		BU-A106	\N	\N	\N
6283143886518:7@s.whatsapp.net	919912415870@s.whatsapp.net		QA199	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281291604011@s.whatsapp.net	Ambon Marga	Ambon Marga Marga	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831303728@s.whatsapp.net		XC387	\N	\N	\N
6283143886518:7@s.whatsapp.net	919246523655@s.whatsapp.net		XC380	\N	\N	\N
6283143886518:7@s.whatsapp.net	41791928995@s.whatsapp.net		XOO-71	\N	\N	\N
6283143886518:7@s.whatsapp.net	919890320619@s.whatsapp.net		QB80	\N	\N	\N
6283143886518:7@s.whatsapp.net	41765046532@s.whatsapp.net		XOO-81	\N	\N	\N
6283143886518:7@s.whatsapp.net	919740606728@s.whatsapp.net		XA275	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287780429069@s.whatsapp.net		Iyan Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763199390@s.whatsapp.net		XOO-38	\N	\N	\N
6283143886518:7@s.whatsapp.net	18045089708@s.whatsapp.net		BU-A161	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164492498@s.whatsapp.net		1.29下午马来2763	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289654030320@s.whatsapp.net		ipay Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819302048@s.whatsapp.net		QA114	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281381705869@s.whatsapp.net		HENGKI Promalin	\N	\N	\N
6283143886518:7@s.whatsapp.net	919896991083@s.whatsapp.net		XC375	\N	\N	\N
6283143886518:7@s.whatsapp.net	919890933623@s.whatsapp.net		QA118	\N	\N	\N
6283143886518:7@s.whatsapp.net	18567960178@s.whatsapp.net		BU-A134	\N	\N	\N
6283143886518:7@s.whatsapp.net	919925232974@s.whatsapp.net		QB12	\N	\N	\N
6283143886518:7@s.whatsapp.net	919415712122@s.whatsapp.net		UJ299	\N	\N	\N
6283143886518:7@s.whatsapp.net	919839985073@s.whatsapp.net		XC370	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285693600184@s.whatsapp.net	Hendro Brebes	Hendro Brebes	\N	\N	\N
6283143886518:7@s.whatsapp.net	919881074250@s.whatsapp.net		XC339	\N	\N	\N
6283143886518:7@s.whatsapp.net	918296417061@s.whatsapp.net		navy70 n70	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283139844802@s.whatsapp.net		Sinarto	S*****O	\N	\N
6283143886518:7@s.whatsapp.net	919968420350@s.whatsapp.net		QA154	\N	\N	\N
6283143886518:7@s.whatsapp.net	601119048289@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	60102035609@s.whatsapp.net	Malaysia 9	Malaysia 9	\N	\N	\N
6283143886518:7@s.whatsapp.net	919987613616@s.whatsapp.net		UJ248	\N	\N	\N
6283143886518:7@s.whatsapp.net	16137967179@s.whatsapp.net		BU-A159	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283153221030@s.whatsapp.net		Mamah Ro	\N	\N	\N
6283143886518:7@s.whatsapp.net	919326840015@s.whatsapp.net		XC330	\N	\N	\N
6283143886518:7@s.whatsapp.net	919898854062@s.whatsapp.net		QB6	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281281476139@s.whatsapp.net		P68	\N	\N	\N
6283143886518:7@s.whatsapp.net	918638743565@s.whatsapp.net		XA281	\N	\N	\N
6283143886518:7@s.whatsapp.net	919620201363@s.whatsapp.net		UJ205	\N	\N	\N
6283143886518:7@s.whatsapp.net	918817905574@s.whatsapp.net		XC301	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199351272@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199435920@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919818189518@s.whatsapp.net		QA168	\N	\N	\N
6283143886518:7@s.whatsapp.net	919825068446@s.whatsapp.net		QB4	\N	\N	\N
6283143886518:7@s.whatsapp.net	919940635275@s.whatsapp.net		QA160	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199984173@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281320149084@s.whatsapp.net	Mmh Fhm	Mmh Fhm	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164521208@s.whatsapp.net		1.29下午马来2747	\N	\N	\N
6283143886518:7@s.whatsapp.net	919892542662@s.whatsapp.net		QB39	\N	\N	\N
6283143886518:7@s.whatsapp.net	919766658628@s.whatsapp.net		XC388	\N	\N	\N
6283143886518:7@s.whatsapp.net	918073900857@s.whatsapp.net		UJ283	\N	\N	\N
6283143886518:7@s.whatsapp.net	919575474605@s.whatsapp.net		UJ206	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285811360572@s.whatsapp.net		Yuni Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	6288809850475@s.whatsapp.net		Leny	\N	\N	\N
6283143886518:7@s.whatsapp.net	19014685732@s.whatsapp.net		BU-A144	\N	\N	\N
6283143886518:7@s.whatsapp.net	601161485854@s.whatsapp.net		1.29下午马来2765	\N	\N	\N
6283143886518:7@s.whatsapp.net	60173900849@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41774071117@s.whatsapp.net		XOO-17	\N	\N	\N
6283143886518:7@s.whatsapp.net	601121933552@s.whatsapp.net		+601121933552	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163615618@s.whatsapp.net		1.29下午马来2777	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163768966@s.whatsapp.net		1.29下午马来2784	\N	\N	\N
6283143886518:7@s.whatsapp.net	60136360258@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798662292@s.whatsapp.net		XOO-100	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895635955630@s.whatsapp.net		Putri	\N	\N	\N
6283143886518:7@s.whatsapp.net	601133872987@s.whatsapp.net		1.29下午马来2769	\N	\N	\N
6283143886518:7@s.whatsapp.net	60123862411@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	601131726725@s.whatsapp.net		+601131726725	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148187024@s.whatsapp.net		1.29下午马来2775	\N	\N	\N
6283143886518:7@s.whatsapp.net	916206329051@s.whatsapp.net		XA279	\N	\N	\N
6283143886518:7@s.whatsapp.net	917994715488@s.whatsapp.net		UJ284	\N	\N	\N
6283143886518:7@s.whatsapp.net	919833910999@s.whatsapp.net		QB60	\N	\N	\N
6283143886518:7@s.whatsapp.net	916206433302@s.whatsapp.net		XC378	\N	\N	\N
6283143886518:7@s.whatsapp.net	60193192199@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	601127805924@s.whatsapp.net		+601127805924	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820559741@s.whatsapp.net		QA188	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163647730@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919874096465@s.whatsapp.net		QA194	\N	\N	\N
6283143886518:7@s.whatsapp.net	919824171560@s.whatsapp.net		XC344	\N	\N	\N
6283143886518:7@s.whatsapp.net	13129299768@s.whatsapp.net		BU-A172	\N	\N	\N
6283143886518:7@s.whatsapp.net	919909234034@s.whatsapp.net		QA122	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831922717@s.whatsapp.net		XC325	\N	\N	\N
6283143886518:7@s.whatsapp.net	601161711807@s.whatsapp.net		05/02M2管理admin	\N	\N	\N
6283143886518:7@s.whatsapp.net	919542861653@s.whatsapp.net		XA212	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820874820@s.whatsapp.net		QB47	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281288808678@s.whatsapp.net		Orng	\N	\N	\N
6283143886518:7@s.whatsapp.net	19099258947@s.whatsapp.net		BU-A174	\N	\N	\N
6283143886518:7@s.whatsapp.net	919843009808@s.whatsapp.net		QB11	\N	\N	\N
6283143886518:7@s.whatsapp.net	919717170070@s.whatsapp.net		QB83	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net		Nazwa	nzw	\N	\N
6283143886518:7@s.whatsapp.net	60166276829@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41787920666@s.whatsapp.net		XOO-16	\N	\N	\N
6283143886518:7@s.whatsapp.net	919979369041@s.whatsapp.net		QA166	\N	\N	\N
6283143886518:7@s.whatsapp.net	919908908057@s.whatsapp.net		XA226	\N	\N	\N
6283143886518:7@s.whatsapp.net	60182551800@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919747382293@s.whatsapp.net		UJ250	\N	\N	\N
6283143886518:7@s.whatsapp.net	41774711357@s.whatsapp.net		XOO-31	\N	\N	\N
6283143886518:7@s.whatsapp.net	919885744657@s.whatsapp.net		QA144	\N	\N	\N
6283143886518:7@s.whatsapp.net	917973356102@s.whatsapp.net		UJ210	\N	\N	\N
6283143886518:7@s.whatsapp.net	919111023412@s.whatsapp.net		UJ238	\N	\N	\N
6283143886518:7@s.whatsapp.net	60123432302@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	15853090723@s.whatsapp.net		BU-A198	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281379128061@s.whatsapp.net		83	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831618757@s.whatsapp.net		XA244	\N	\N	\N
6283143886518:7@s.whatsapp.net	919811452221@s.whatsapp.net		QA115	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283845052997@s.whatsapp.net	Tukang Jahit	Tukang Jahit	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199353871@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804673965@s.whatsapp.net		XA274	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895619611487@s.whatsapp.net		P14	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804611309@s.whatsapp.net		XA273	\N	\N	\N
6283143886518:7@s.whatsapp.net	601138513458@s.whatsapp.net		1.29下午马来2779	\N	\N	\N
6283143886518:7@s.whatsapp.net	60182625955@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819650047@s.whatsapp.net		QB28	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281938207114@s.whatsapp.net		EKa Ckung	\N	\N	\N
6283143886518:7@s.whatsapp.net	41762819218@s.whatsapp.net		XOO-18	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281291868684@s.whatsapp.net		Angun	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798269053@s.whatsapp.net		XOO-12	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285692592363@s.whatsapp.net	Metro Tocer	Metro Tocer	\N	\N	\N
6283143886518:7@s.whatsapp.net	917560935962@s.whatsapp.net		XC362	\N	\N	\N
6283143886518:7@s.whatsapp.net	918274802309@s.whatsapp.net		UJ282	\N	\N	\N
6283143886518:7@s.whatsapp.net	18323315969@s.whatsapp.net		BU-A184	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798154497@s.whatsapp.net		XOO-51	\N	\N	\N
6283143886518:7@s.whatsapp.net	41766930863@s.whatsapp.net		XOO-77	\N	\N	\N
6283143886518:7@s.whatsapp.net	919848422249@s.whatsapp.net		UJ222	\N	\N	\N
6283143886518:7@s.whatsapp.net	919323430677@s.whatsapp.net		XC322	\N	\N	\N
6283143886518:7@s.whatsapp.net	628979553892@s.whatsapp.net	Chika 7E	Chika 7E	\N	\N	\N
6283143886518:7@s.whatsapp.net	60139172836@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282111094439@s.whatsapp.net		Pak Budi	\N	\N	\N
6283143886518:7@s.whatsapp.net	60196421792@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199752648@s.whatsapp.net		1.29下午马来2724	\N	\N	\N
6283143886518:7@s.whatsapp.net	919969676456@s.whatsapp.net		QA176	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164377234@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282129838388@s.whatsapp.net	Rian Mobil	Rian Mobil	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282310737835@s.whatsapp.net		Ade Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	918152816742@s.whatsapp.net		XC318	\N	\N	\N
6283143886518:7@s.whatsapp.net	60164976939@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831569889@s.whatsapp.net		UJ223	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831429068@s.whatsapp.net		XA253	\N	\N	\N
6283143886518:7@s.whatsapp.net	919631668188@s.whatsapp.net		QA189	\N	\N	\N
6283143886518:7@s.whatsapp.net	919845441163@s.whatsapp.net		QB59	\N	\N	\N
6283143886518:7@s.whatsapp.net	41789071066@s.whatsapp.net		XOO-62	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199262968@s.whatsapp.net		1.29下午马来2752	\N	\N	\N
6283143886518:7@s.whatsapp.net	628988289551@s.whatsapp.net		myphone	..	\N	\N
6283143886518:7@s.whatsapp.net	919833594029@s.whatsapp.net		QA104	\N	\N	\N
6283143886518:7@s.whatsapp.net	919850512111@s.whatsapp.net		QA151	\N	\N	\N
6283143886518:7@s.whatsapp.net	60109618768@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919444962683@s.whatsapp.net		QA108	\N	\N	\N
6283143886518:7@s.whatsapp.net	19174426752@s.whatsapp.net		BU-A122	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281253635580@s.whatsapp.net		P65	\N	\N	\N
6283143886518:7@s.whatsapp.net	919879277328@s.whatsapp.net		XA261	\N	\N	\N
6283143886518:7@s.whatsapp.net	601125259591@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	917223070767@s.whatsapp.net		XA205	\N	\N	\N
6283143886518:7@s.whatsapp.net	60168359759@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919008055552@s.whatsapp.net		UJ207	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831385883@s.whatsapp.net		XC308	\N	\N	\N
6283143886518:7@s.whatsapp.net	17812586139@s.whatsapp.net		BU-A140	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831349366@s.whatsapp.net		XC305	\N	\N	\N
6283143886518:7@s.whatsapp.net	919925011534@s.whatsapp.net		QB19	\N	\N	\N
6283143886518:7@s.whatsapp.net	919216363611@s.whatsapp.net		XA239	\N	\N	\N
6283143886518:7@s.whatsapp.net	917895081222@s.whatsapp.net		XC337	\N	\N	\N
6283143886518:7@s.whatsapp.net	918274812260@s.whatsapp.net		XC368	\N	\N	\N
6283143886518:7@s.whatsapp.net	918723949846@s.whatsapp.net		XA224	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831886898@s.whatsapp.net		UJ276	\N	\N	\N
6283143886518:7@s.whatsapp.net	41764705233@s.whatsapp.net		XOO-94	\N	\N	\N
6283143886518:7@s.whatsapp.net	60165216659@s.whatsapp.net		1.29下午马来2757	\N	\N	\N
6283143886518:7@s.whatsapp.net	919030252397@s.whatsapp.net		XA294	\N	\N	\N
6283143886518:7@s.whatsapp.net	60193132043@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919426362553@s.whatsapp.net		XC332	\N	\N	\N
6283143886518:7@s.whatsapp.net	919867384646@s.whatsapp.net		QB40	\N	\N	\N
6283143886518:7@s.whatsapp.net	41794813357@s.whatsapp.net		XOO-68	\N	\N	\N
6283143886518:7@s.whatsapp.net	919999916698@s.whatsapp.net		QB9	\N	\N	\N
6283143886518:7@s.whatsapp.net	18328165102@s.whatsapp.net		BU-A169	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831346481@s.whatsapp.net		XA203	\N	\N	\N
6283143886518:7@s.whatsapp.net	919860836655@s.whatsapp.net		QB42	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831798496@s.whatsapp.net		UJ266	\N	\N	\N
6283143886518:7@s.whatsapp.net	917875744924@s.whatsapp.net		XC329	\N	\N	\N
6283143886518:7@s.whatsapp.net	919892651144@s.whatsapp.net		QA165	\N	\N	\N
6283143886518:7@s.whatsapp.net	919427753406@s.whatsapp.net		QB97	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819707249@s.whatsapp.net		QA196	\N	\N	\N
6283143886518:7@s.whatsapp.net	18473545695@s.whatsapp.net		BU-A107	\N	\N	\N
6283143886518:7@s.whatsapp.net	60136245334@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282210676509@s.whatsapp.net	Ipay Greb 22	Ipay Greb 22	\N	\N	\N
6283143886518:7@s.whatsapp.net	919829525255@s.whatsapp.net		QB66	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285256317885@s.whatsapp.net		P4	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285691658794@s.whatsapp.net	Bengkel Topik	Bengkel Topik	\N	\N	\N
6283143886518:7@s.whatsapp.net	15307014022@s.whatsapp.net		BU-A165	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282124018872@s.whatsapp.net		Riko Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	19285832015@s.whatsapp.net		BU-A120	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287804020444@s.whatsapp.net	Ez hamster Farm	Ez hamster Farm	\N	\N	\N
6283143886518:7@s.whatsapp.net	917038410916@s.whatsapp.net		XC309	\N	\N	\N
6283143886518:7@s.whatsapp.net	601116198776@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831680946@s.whatsapp.net		XA251	\N	\N	\N
6283143886518:7@s.whatsapp.net	60177474557@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	916300812950@s.whatsapp.net		XC333	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831854832@s.whatsapp.net		UJ202	\N	\N	\N
6283143886518:7@s.whatsapp.net	41764152991@s.whatsapp.net		XOO-78	\N	\N	\N
6283143886518:7@s.whatsapp.net	60172774137@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281370579503@s.whatsapp.net		BUYUNG	\N	\N	\N
6283143886518:7@s.whatsapp.net	917045489727@s.whatsapp.net		UJ234	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287779959454@s.whatsapp.net		Ara	\N	\N	\N
6283143886518:7@s.whatsapp.net	19295310107@s.whatsapp.net		BU-A108	\N	\N	\N
6283143886518:7@s.whatsapp.net	18324889214@s.whatsapp.net		BU-A193	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283893296858@s.whatsapp.net		ADi Ambulan	\N	\N	\N
6283143886518:7@s.whatsapp.net	60126838181@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	918621829072@s.whatsapp.net		UJ263	\N	\N	\N
6283143886518:7@s.whatsapp.net	60192048839@s.whatsapp.net		1.29下午马来2739	\N	\N	\N
6283143886518:7@s.whatsapp.net	919841161933@s.whatsapp.net		XA280	\N	\N	\N
6283143886518:7@s.whatsapp.net	601119013845@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	919980143010@s.whatsapp.net		QA195	\N	\N	\N
6283143886518:7@s.whatsapp.net	41764763499@s.whatsapp.net		XOO-48	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289515839249@s.whatsapp.net		Zidan	\N	\N	\N
6283143886518:7@s.whatsapp.net	60163187632@s.whatsapp.net		1.29下午马来2728	\N	\N	\N
6283143886518:7@s.whatsapp.net	41799330068@s.whatsapp.net		XOO-32	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796828973@s.whatsapp.net		XOO-54	\N	\N	\N
6283143886518:7@s.whatsapp.net	919920165277@s.whatsapp.net		QB8	\N	\N	\N
6283143886518:7@s.whatsapp.net	919097378406@s.whatsapp.net		XA299	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796406155@s.whatsapp.net		XOO-47	\N	\N	\N
6283143886518:7@s.whatsapp.net	919904081315@s.whatsapp.net		QB100	\N	\N	\N
6283143886518:7@s.whatsapp.net	919619538846@s.whatsapp.net		XC326	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819082733@s.whatsapp.net		QA125	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831473500@s.whatsapp.net		XA217	\N	\N	\N
6283143886518:7@s.whatsapp.net	17873912257@s.whatsapp.net		BU-A185	\N	\N	\N
6283143886518:7@s.whatsapp.net	919818291028@s.whatsapp.net		QB82	\N	\N	\N
6283143886518:7@s.whatsapp.net	18298024119@s.whatsapp.net		BU-A186	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797246068@s.whatsapp.net		XOO-52	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038706697@s.whatsapp.net		XC324	\N	\N	\N
6283143886518:7@s.whatsapp.net	917890883389@s.whatsapp.net		UJ259	\N	\N	\N
6283143886518:7@s.whatsapp.net	16198059150@s.whatsapp.net		BU-A173	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798547731@s.whatsapp.net		XOO-27	\N	\N	\N
6283143886518:7@s.whatsapp.net	919313585050@s.whatsapp.net		XA290	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831365125@s.whatsapp.net		QA111	\N	\N	\N
6283143886518:7@s.whatsapp.net	919730220668@s.whatsapp.net		XA232	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281511100689@s.whatsapp.net	Big B000s	Big B000s	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281511798120@s.whatsapp.net	Gempol Pak	Gempol Pak Said Metrominj	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287764515703@s.whatsapp.net	Kang GC	Kang GC	\N	\N	\N
6283143886518:7@s.whatsapp.net	919933863848@s.whatsapp.net		QB79	\N	\N	\N
6283143886518:7@s.whatsapp.net	919416230938@s.whatsapp.net		XA227	\N	\N	\N
6283143886518:7@s.whatsapp.net	41779837478@s.whatsapp.net		XOO-30	\N	\N	\N
6283143886518:7@s.whatsapp.net	41793314426@s.whatsapp.net		XOO-36	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282113454512@s.whatsapp.net		Windi Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831769162@s.whatsapp.net		UJ257	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831306328@s.whatsapp.net		XC385	\N	\N	\N
6283143886518:7@s.whatsapp.net	60196897890@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60165356653@s.whatsapp.net		1.29下午马来2780	\N	\N	\N
6283143886518:7@s.whatsapp.net	917381774737@s.whatsapp.net		XC363	\N	\N	\N
6283143886518:7@s.whatsapp.net	919143022537@s.whatsapp.net		UJ296	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281285320689@s.whatsapp.net		Pak MAN Samsat	\N	\N	\N
6283143886518:7@s.whatsapp.net	919849384984@s.whatsapp.net		QB85	\N	\N	\N
6283143886518:7@s.whatsapp.net	919780232271@s.whatsapp.net		XC384	\N	\N	\N
6283143886518:7@s.whatsapp.net	919886428255@s.whatsapp.net		QA123	\N	\N	\N
6283143886518:7@s.whatsapp.net	41774016301@s.whatsapp.net		XOO-99	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	Anak.Q	+6283127378535	Masa Ha'khalal Ha'insufi	\N	\N
6283143886518:7@s.whatsapp.net	601139833596@s.whatsapp.net		A3.admin1 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	18057295587@s.whatsapp.net		BU-A119	\N	\N	\N
6283143886518:7@s.whatsapp.net	919953616654@s.whatsapp.net		QA133	\N	\N	\N
6283143886518:7@s.whatsapp.net	919888713600@s.whatsapp.net		XC352	\N	\N	\N
6283143886518:7@s.whatsapp.net	14845139498@s.whatsapp.net		BU-A152	\N	\N	\N
6283143886518:7@s.whatsapp.net	919849030600@s.whatsapp.net		QB21	\N	\N	\N
6283143886518:7@s.whatsapp.net	12105056442@s.whatsapp.net		BU-A139	\N	\N	\N
6283143886518:7@s.whatsapp.net	601125176372@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	6288299493944@s.whatsapp.net	Paus Ahmed	Paus Ahmed	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895329549314@s.whatsapp.net		P29	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797771000@s.whatsapp.net		XOO-76	\N	\N	\N
6283143886518:7@s.whatsapp.net	919414211197@s.whatsapp.net		XA291	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831215115@s.whatsapp.net		XC323	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149960699@s.whatsapp.net		1.29下午马来2768	\N	\N	\N
6283143886518:7@s.whatsapp.net	60109676167@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	918597086934@s.whatsapp.net		XA216	\N	\N	\N
6283143886518:7@s.whatsapp.net	919819195731@s.whatsapp.net		QA163	\N	\N	\N
6283143886518:7@s.whatsapp.net	15164626005@s.whatsapp.net		BU-A133	\N	\N	\N
6283143886518:7@s.whatsapp.net	919248022730@s.whatsapp.net		XC310	\N	\N	\N
6283143886518:7@s.whatsapp.net	919995231229@s.whatsapp.net		QA159	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281235742179@s.whatsapp.net		P10	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281221832146@s.whatsapp.net		Ibu Titin	\N	\N	\N
6283143886518:7@s.whatsapp.net	919884210230@s.whatsapp.net		QA129	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148816156@s.whatsapp.net		1.29下午马来2762	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804085441@s.whatsapp.net		XA257	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281380605365@s.whatsapp.net		Budi GREB	\N	\N	\N
6283143886518:7@s.whatsapp.net	919494127787@s.whatsapp.net		XC302	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281292282922@s.whatsapp.net		d0d0 22	\N	\N	\N
6283143886518:7@s.whatsapp.net	6289671440569@s.whatsapp.net		A UU	\N	\N	\N
6283143886518:7@s.whatsapp.net	60136177907@s.whatsapp.net		1.29下午马来2734	\N	\N	\N
6283143886518:7@s.whatsapp.net	919552492002@s.whatsapp.net		UJ293	\N	\N	\N
6283143886518:7@s.whatsapp.net	918978365022@s.whatsapp.net		XC371	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796878113@s.whatsapp.net		XOO-66	\N	\N	\N
6283143886518:7@s.whatsapp.net	60134429950@s.whatsapp.net		1.29下午马来2795	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797269686@s.whatsapp.net		XOO-87	\N	\N	\N
6283143886518:7@s.whatsapp.net	918002967450@s.whatsapp.net		XA201	\N	\N	\N
6283143886518:7@s.whatsapp.net	919460302280@s.whatsapp.net		XA295	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895342429810@s.whatsapp.net		Tomo	\N	\N	\N
6283143886518:7@s.whatsapp.net	919780683133@s.whatsapp.net		UJ253	\N	\N	\N
6283143886518:7@s.whatsapp.net	60192824149@s.whatsapp.net		1.29下午马来2720	\N	\N	\N
6283143886518:7@s.whatsapp.net	918668133485@s.whatsapp.net		XA230	\N	\N	\N
6283143886518:7@s.whatsapp.net	601110621016@s.whatsapp.net		1.29下午马来2793	\N	\N	\N
6283143886518:7@s.whatsapp.net	919820155103@s.whatsapp.net		QB86	\N	\N	\N
6283143886518:7@s.whatsapp.net	601112364640@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	601133860795@s.whatsapp.net		1.29下午马来2753	\N	\N	\N
6283143886518:7@s.whatsapp.net	919373477328@s.whatsapp.net		UJ252	\N	\N	\N
6283143886518:7@s.whatsapp.net	41792746438@s.whatsapp.net		XOO-104	\N	\N	\N
6283143886518:7@s.whatsapp.net	919916842253@s.whatsapp.net		QA136	\N	\N	\N
6283143886518:7@s.whatsapp.net	919540149629@s.whatsapp.net		QB54	\N	\N	\N
6283143886518:7@s.whatsapp.net	60168550442@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	601125724801@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	60107810342@s.whatsapp.net		Malaisia1	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796640106@s.whatsapp.net		XOO-9	\N	\N	\N
6283143886518:7@s.whatsapp.net	601131651756@s.whatsapp.net		+601131651756	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149334217@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281378465590@s.whatsapp.net		80	\N	\N	\N
6283143886518:7@s.whatsapp.net	60148079967@s.whatsapp.net		1.29下午马来2733	\N	\N	\N
6283143886518:7@s.whatsapp.net	919111033498@s.whatsapp.net		UJ204	\N	\N	\N
6283143886518:7@s.whatsapp.net	919967420071@s.whatsapp.net		QB53	\N	\N	\N
6283143886518:7@s.whatsapp.net	60133316416@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	17134436872@s.whatsapp.net		BU-A142	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149098136@s.whatsapp.net		1.29下午马来2759	\N	\N	\N
6283143886518:7@s.whatsapp.net	919109321991@s.whatsapp.net		UJ221	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285667632700@s.whatsapp.net		P50	\N	\N	\N
6283143886518:7@s.whatsapp.net	919813477977@s.whatsapp.net		QA184	\N	\N	\N
6283143886518:7@s.whatsapp.net	919704260940@s.whatsapp.net		UJ212	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287738672104@s.whatsapp.net	WiwiT 22	WiwiT 22	\N	\N	\N
6283143886518:7@s.whatsapp.net	19099738476@s.whatsapp.net		BU-A131	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831631689@s.whatsapp.net		XC377	\N	\N	\N
6283143886518:7@s.whatsapp.net	601127876755@s.whatsapp.net		1.29下午马来2787	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285778283804@s.whatsapp.net		Mas Baim	suswandibaim	\N	\N
6283143886518:7@s.whatsapp.net	19498726295@s.whatsapp.net		BU-A190	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281325505803@s.whatsapp.net		75	\N	\N	\N
6283143886518:7@s.whatsapp.net	60102115098@s.whatsapp.net		Malaysia1	\N	\N	\N
6283143886518:7@s.whatsapp.net	919924305179@s.whatsapp.net		XC397	\N	\N	\N
6283143886518:7@s.whatsapp.net	918602376461@s.whatsapp.net		UJ300	\N	\N	\N
6283143886518:7@s.whatsapp.net	60198762167@s.whatsapp.net		1.29下午马来2790	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038926132@s.whatsapp.net		XA277	\N	\N	\N
6283143886518:7@s.whatsapp.net	18296516155@s.whatsapp.net		BU-A111	\N	\N	\N
6283143886518:7@s.whatsapp.net	60182851356@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919890491504@s.whatsapp.net		QA109	\N	\N	\N
6283143886518:7@s.whatsapp.net	60103022014@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41794202135@s.whatsapp.net		XOO-108	\N	\N	\N
6283143886518:7@s.whatsapp.net	919302487961@s.whatsapp.net		UJ231	\N	\N	\N
6283143886518:7@s.whatsapp.net	14848370477@s.whatsapp.net		BU-A110	\N	\N	\N
6283143886518:7@s.whatsapp.net	60192320727@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	918806895694@s.whatsapp.net		XC312	\N	\N	\N
6283143886518:7@s.whatsapp.net	628156855248@s.whatsapp.net		94	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162639769@s.whatsapp.net		1.29下午马来2742	\N	\N	\N
6283143886518:7@s.whatsapp.net	919896607600@s.whatsapp.net		QB41	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831641872@s.whatsapp.net		XA272	\N	\N	\N
6283143886518:7@s.whatsapp.net	919109527228@s.whatsapp.net		XA241	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797426912@s.whatsapp.net		XOO-8	\N	\N	\N
6283143886518:7@s.whatsapp.net	919925040467@s.whatsapp.net		QA158	\N	\N	\N
6283143886518:7@s.whatsapp.net	919082529254@s.whatsapp.net		XC317	\N	\N	\N
6283143886518:7@s.whatsapp.net	19196458419@s.whatsapp.net		BU-A176	\N	\N	\N
6283143886518:7@s.whatsapp.net	919899397516@s.whatsapp.net		XA282	\N	\N	\N
6283143886518:7@s.whatsapp.net	60199445745@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41798831435@s.whatsapp.net		XOO-110	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283107846415@s.whatsapp.net		Duren	Aira Alya	\N	\N
6283143886518:7@s.whatsapp.net	41794525471@s.whatsapp.net		XOO-73	\N	\N	\N
6283143886518:7@s.whatsapp.net	918621869496@s.whatsapp.net		UJ267	\N	\N	\N
6283143886518:7@s.whatsapp.net	919701333177@s.whatsapp.net		QA161	\N	\N	\N
6283143886518:7@s.whatsapp.net	41793790678@s.whatsapp.net		XOO-109	\N	\N	\N
6283143886518:7@s.whatsapp.net	41796297063@s.whatsapp.net		XOO-24	\N	\N	\N
6283143886518:7@s.whatsapp.net	919112692621@s.whatsapp.net		XC327	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285273001945@s.whatsapp.net	Unlock tool	Unlock tool	\N	\N	\N
6283143886518:7@s.whatsapp.net	919493041477@s.whatsapp.net		XC393	\N	\N	\N
6283143886518:7@s.whatsapp.net	919825710473@s.whatsapp.net		QA120	\N	\N	\N
6283143886518:7@s.whatsapp.net	919911597650@s.whatsapp.net		XC350	\N	\N	\N
6283143886518:7@s.whatsapp.net	60126719091@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919870169843@s.whatsapp.net		QA121	\N	\N	\N
6283143886518:7@s.whatsapp.net	919350649595@s.whatsapp.net		QB27	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763970972@s.whatsapp.net		XOO-69	\N	\N	\N
6283143886518:7@s.whatsapp.net	919844981096@s.whatsapp.net		XA223	\N	\N	\N
6283143886518:7@s.whatsapp.net	15208095830@s.whatsapp.net		BU-A135	\N	\N	\N
6283143886518:7@s.whatsapp.net	919987815072@s.whatsapp.net		XC351	\N	\N	\N
6283143886518:7@s.whatsapp.net	919444446067@s.whatsapp.net		QA149	\N	\N	\N
6283143886518:7@s.whatsapp.net	13142161688@s.whatsapp.net		BU-A112	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895327643450@s.whatsapp.net		P22	\N	\N	\N
6283143886518:7@s.whatsapp.net	60109191024@s.whatsapp.net		Am	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281256754103@s.whatsapp.net		P36	\N	\N	\N
6283143886518:7@s.whatsapp.net	919773574981@s.whatsapp.net		QA116	\N	\N	\N
6283143886518:7@s.whatsapp.net	919899250511@s.whatsapp.net		QA157	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831595150@s.whatsapp.net		XA240	\N	\N	\N
6283143886518:7@s.whatsapp.net	41789555075@s.whatsapp.net		XOO-65	\N	\N	\N
6283143886518:7@s.whatsapp.net	18437937610@s.whatsapp.net		BU-A180	\N	\N	\N
6283143886518:7@s.whatsapp.net	919167172803@s.whatsapp.net		XC338	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285931023017@s.whatsapp.net		Wiwit	\N	\N	\N
6283143886518:7@s.whatsapp.net	918131846207@s.whatsapp.net		XC354	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831935460@s.whatsapp.net		UJ268	\N	\N	\N
6283143886518:7@s.whatsapp.net	60169846188@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	18322070323@s.whatsapp.net		BU-A105	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282150707050@s.whatsapp.net		Ckw	\N	\N	\N
6283143886518:7@s.whatsapp.net	601120642377@s.whatsapp.net		A	\N	\N	\N
6283143886518:7@s.whatsapp.net	917350115131@s.whatsapp.net		XA245	\N	\N	\N
6283143886518:7@s.whatsapp.net	18064735309@s.whatsapp.net		BU-A102	\N	\N	\N
6283143886518:7@s.whatsapp.net	919999414955@s.whatsapp.net		XC390	\N	\N	\N
6283143886518:7@s.whatsapp.net	919967313206@s.whatsapp.net		UJ229	\N	\N	\N
6283143886518:7@s.whatsapp.net	919491217978@s.whatsapp.net		XA246	\N	\N	\N
6283143886518:7@s.whatsapp.net	919874278097@s.whatsapp.net		QB55	\N	\N	\N
6283143886518:7@s.whatsapp.net	16233308123@s.whatsapp.net		BU-A189	\N	\N	\N
6283143886518:7@s.whatsapp.net	41765891908@s.whatsapp.net		XOO-80	\N	\N	\N
6283143886518:7@s.whatsapp.net	919835353125@s.whatsapp.net		QA183	\N	\N	\N
6283143886518:7@s.whatsapp.net	919433089131@s.whatsapp.net		QA178	\N	\N	\N
6283143886518:7@s.whatsapp.net	60132767765@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919965009629@s.whatsapp.net		QA145	\N	\N	\N
6283143886518:7@s.whatsapp.net	919923314320@s.whatsapp.net		UJ209	\N	\N	\N
6283143886518:7@s.whatsapp.net	919814060667@s.whatsapp.net		XC398	\N	\N	\N
6283143886518:7@s.whatsapp.net	60167678461@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	919833841083@s.whatsapp.net		QB52	\N	\N	\N
6283143886518:7@s.whatsapp.net	60124522057@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797954649@s.whatsapp.net		XOO-91	\N	\N	\N
6283143886518:7@s.whatsapp.net	919773468988@s.whatsapp.net		QB89	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281288930267@s.whatsapp.net		ALi PeTi	\N	\N	\N
6283143886518:7@s.whatsapp.net	41797702209@s.whatsapp.net		XOO-63	\N	\N	\N
6283143886518:7@s.whatsapp.net	60198592035@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	18326186395@s.whatsapp.net		BU-A124	\N	\N	\N
6283143886518:7@s.whatsapp.net	60192570571@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281381810681@s.whatsapp.net		JAliiiii	\N	\N	\N
6283143886518:7@s.whatsapp.net	15412809597@s.whatsapp.net		BU-A115	\N	\N	\N
6283143886518:7@s.whatsapp.net	919851028065@s.whatsapp.net		QA192	\N	\N	\N
6283143886518:7@s.whatsapp.net	919833116462@s.whatsapp.net		XA242	\N	\N	\N
6283143886518:7@s.whatsapp.net	41765611177@s.whatsapp.net		XOO-39	\N	\N	\N
6283143886518:7@s.whatsapp.net	62895389538438@s.whatsapp.net		Ari Greb	\N	\N	\N
6283143886518:7@s.whatsapp.net	60162732726@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285973975100@s.whatsapp.net		Whilly	\N	\N	\N
6283143886518:7@s.whatsapp.net	6287814410181@s.whatsapp.net		P3	\N	\N	\N
6283143886518:7@s.whatsapp.net	628159739419@s.whatsapp.net		YONo AmbuLan	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831673487@s.whatsapp.net		UJ215	\N	\N	\N
6283143886518:7@s.whatsapp.net	919989256586@s.whatsapp.net		QB87	\N	\N	\N
6283143886518:7@s.whatsapp.net	601127524465@s.whatsapp.net		+601127524465	\N	\N	\N
6283143886518:7@s.whatsapp.net	41794516786@s.whatsapp.net		XOO-37	\N	\N	\N
6283143886518:7@s.whatsapp.net	60147738953@s.whatsapp.net		1.29下午马来2740	\N	\N	\N
6283143886518:7@s.whatsapp.net	60192876356@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	60123326018@s.whatsapp.net		A3.0203 A	\N	\N	\N
6283143886518:7@s.whatsapp.net	41764030454@s.whatsapp.net		XOO-90	\N	\N	\N
6283143886518:7@s.whatsapp.net	919062137326@s.whatsapp.net		XA264	\N	\N	\N
6283143886518:7@s.whatsapp.net	6283847545078@s.whatsapp.net		+6283847545078	\N	\N	\N
6283143886518:7@s.whatsapp.net	919575763022@s.whatsapp.net		XC316	\N	\N	\N
6283143886518:7@s.whatsapp.net	41763356801@s.whatsapp.net		XOO-25	\N	\N	\N
6283143886518:7@s.whatsapp.net	6285794305964@s.whatsapp.net		ZhRaaa	\N	\N	\N
6283143886518:7@s.whatsapp.net	601136098864@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	41795579900@s.whatsapp.net		XOO-61	\N	\N	\N
6283143886518:7@s.whatsapp.net	919825251626@s.whatsapp.net		QA173	\N	\N	\N
6283143886518:7@s.whatsapp.net	919999012331@s.whatsapp.net		QB26	\N	\N	\N
6283143886518:7@s.whatsapp.net	6282113970070@s.whatsapp.net		Bunia	\N	\N	\N
6283143886518:7@s.whatsapp.net	60182000145@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	19567015429@s.whatsapp.net		BU-A150	\N	\N	\N
6283143886518:7@s.whatsapp.net	41786175749@s.whatsapp.net		XOO-3	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281324715600@s.whatsapp.net		Baron Once	\N	\N	\N
6283143886518:7@s.whatsapp.net	60134083330@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	60172114215@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919560626041@s.whatsapp.net		UJ281	\N	\N	\N
6283143886518:7@s.whatsapp.net	919821640978@s.whatsapp.net		QA172	\N	\N	\N
6283143886518:7@s.whatsapp.net	60179518402@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919862303730@s.whatsapp.net		UJ244	\N	\N	\N
6283143886518:7@s.whatsapp.net	60109714378@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919824326807@s.whatsapp.net		QB57	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281316089491@s.whatsapp.net		Reot	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804070757@s.whatsapp.net		UJ262	\N	\N	\N
6283143886518:7@s.whatsapp.net	919843283868@s.whatsapp.net		XA285	\N	\N	\N
6283143886518:7@s.whatsapp.net	918908986768@s.whatsapp.net		UJ249	\N	\N	\N
6283143886518:7@s.whatsapp.net	60135869026@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919887224117@s.whatsapp.net		UJ254	\N	\N	\N
6283143886518:7@s.whatsapp.net	919833740814@s.whatsapp.net		QB51	\N	\N	\N
6283143886518:7@s.whatsapp.net	918621944158@s.whatsapp.net		UJ261	\N	\N	\N
6283143886518:7@s.whatsapp.net	6281617917692@s.whatsapp.net		99	\N	\N	\N
6283143886518:7@s.whatsapp.net	41788881170@s.whatsapp.net		XOO-55	\N	\N	\N
6283143886518:7@s.whatsapp.net	60173557428@s.whatsapp.net		05/02M2水军navy	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831462671@s.whatsapp.net		UJ235	\N	\N	\N
6283143886518:7@s.whatsapp.net	919804009838@s.whatsapp.net		XA206	\N	\N	\N
6283143886518:7@s.whatsapp.net	919902098011@s.whatsapp.net		XA236	\N	\N	\N
6283143886518:7@s.whatsapp.net	919831801713@s.whatsapp.net		XA247	\N	\N	\N
6283143886518:7@s.whatsapp.net	60149707930@s.whatsapp.net		05/02kw数据ctc	\N	\N	\N
6283143886518:7@s.whatsapp.net	919038610677@s.whatsapp.net		UJ203	\N	\N	\N
6283143886518:7@s.whatsapp.net	151612429475900@lid	\N	\N	Masa Ha'khalal Ha'insufi	\N	\N
6283143886518:7@s.whatsapp.net	150822088396920@lid	\N	\N	ABD MUHAIMIN	\N	\N
6283143886518:7@s.whatsapp.net	105488691757238@lid	\N	\N	tisna1899	\N	\N
6283143886518:7@s.whatsapp.net	6289605794912@s.whatsapp.net	\N	\N	tisna1899	\N	\N
6283143886518:7@s.whatsapp.net	115895447896078@lid	\N	\N	88f	88f	\N
6283143886518:7@s.whatsapp.net	6287898987797@s.whatsapp.net	\N	\N	88f	88f	\N
6283143886518:7@s.whatsapp.net	139432053207269@lid	\N	\N	nuraenimurni9	\N	\N
6283143886518:7@s.whatsapp.net	200858524491833@lid	\N	\N	Bois	\N	\N
6283143886518:7@s.whatsapp.net	206545447084155@lid	\N	\N	/\\/	\N	\N
6283143886518:7@s.whatsapp.net	227964465754319@lid	\N	\N	.	\N	\N
6283143886518:7@s.whatsapp.net	6285399647421@s.whatsapp.net	\N	\N	.	\N	\N
6283143886518:7@s.whatsapp.net	59425402433630@lid	\N	\N	..	\N	\N
\.


--
-- Data for Name: whatsmeow_device; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_device (jid, lid, facebook_uuid, registration_id, noise_key, identity_key, signed_pre_key, signed_pre_key_id, signed_pre_key_sig, adv_key, adv_details, adv_account_sig, adv_account_sig_key, adv_device_sig, platform, business_name, push_name, lid_migration_ts) FROM stdin;
6283143886518:7@s.whatsapp.net	177679206723839:7@lid	\N	3487821366	\\xb036c45f1620694d74d1caefc56d4423496ecb874130720affa4a9b1deee1f79	\\x48f7826257e9f85768ac201c2716352cbef8f16bbb04e7595b18aa3d54e42348	\\xc8e1b0fadcc0f43f9ff90f6f0d1f2bd5dd9686761d593b3b96c455663ceaff52	1	\\x045c79fe8473b1aa193a1f036899207b778e382052a0367685bfb0292191154bc18c29928357b7b9823c740afb89af72c584bd82779a396104f9d0e0da946802	\\x2a279fb68f4c9fac892a74aaf6d99e1a1ae72ca43795d0f769bff8dca9c7a546	\\x08ffc1d0990710ce9cfdcb06180620002800	\\xd318c98c3da1e8bea68bbf9b1f01fb926a5a05d6603400513e777adb2ce2768675b481b21557416d7893ad52939388e8a6f2dbdd802cfe94f1c77ea13952560e	\\x5bea72cb62b2a8b121af69ecda52ed69bb1823cea4adf7b467068274cae29053	\\x56edf773b98155b7dde831cf5645bc58782f19d735045c8fb94bab1bec431831eae33e36a419a291a26c24ff69f427512ade896974a2250402c927256e2d3c07	android		S	0
\.


--
-- Data for Name: whatsmeow_event_buffer; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_event_buffer (our_jid, ciphertext_hash, plaintext, server_timestamp, insert_timestamp) FROM stdin;
\.


--
-- Data for Name: whatsmeow_identity_keys; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_identity_keys (our_jid, their_id, identity) FROM stdin;
6283143886518:7@s.whatsapp.net	105488691757238_1:0	\\xd5ca7c6ca7145fb794f3130c89c7486fe5045049e33af934a24bf2c3abb1c266
6283143886518:7@s.whatsapp.net	115895447896078_1:0	\\x70a40b24dfe9bcac4bd6ebb9bc6a85fb85c1ced6a3b2c345dc4fd8174affeb01
6283143886518:7@s.whatsapp.net	132272191709432_1:0	\\x7c006548db395d50bea295072a8d266550ffb8b3ffa30cb1324f0e976c46df10
6283143886518:7@s.whatsapp.net	262104842035423_1:0	\\xa1672f3735b12c75172ccb2b69fff7f7edf99333f066ecbb57c86d430f1e2c31
6283143886518:7@s.whatsapp.net	122033006465061_1:0	\\x6eeab5e84a9e9488553a7d537e034ef4fa59a5bfee6c2c335edb016330968a12
6283143886518:7@s.whatsapp.net	151612429475900_1:0	\\xd86689b9fb2349d8c7869d535d2a80c21de707f878936218eec3547e25f43830
6283143886518:7@s.whatsapp.net	91221296955604_1:0	\\xb1ccb35f420569b6b6393083b252fc80b43799fb222eab16ce9e35bfa751a435
6283143886518:7@s.whatsapp.net	21148653883564_1:0	\\xb3099e38c11f703bd0f1e849ed75b47ba513cb24b80f7f904eecea4bb8a41864
6283143886518:7@s.whatsapp.net	150822088396920_1:34	\\xd48a21db1d22026658488626bae30a1338d13cb1211be5114c1f6c8d6f081375
6283143886518:7@s.whatsapp.net	185014457217030_1:0	\\x19df8b7287c00ee77457ab33bbebb9be431d824a449578c60fa0473e51550b22
6283143886518:7@s.whatsapp.net	139432053207269_1:0	\\x0561cf0dc38869c7cc2ad2cd67a7516a24bf661250bcde38e7ba0f04ecb3f417
6283143886518:7@s.whatsapp.net	200858524491833_1:0	\\x36672c28c7872ab9794978cfcdfada084810af4230cbf65d663dc17f11447e64
6283143886518:7@s.whatsapp.net	146025264197707_1:0	\\xcf8eb563e3c2d2e84f81c47ab23aa17528e61c3eeb8263ef72fe62d6e8dd5d07
6283143886518:7@s.whatsapp.net	206545447084155_1:0	\\x9a1288899de7856675978258a8ca6aadf2d3c61b41334396fa87b9622b70c020
6283143886518:7@s.whatsapp.net	227964465754319_1:0	\\xd256f98bdb14da5a1991df39b63855805664902dba957ab5b0cc01ffd616335d
6283143886518:7@s.whatsapp.net	17253017845988_1:0	\\x1e87fad5ae1241f6aa6604f920fca76df6e4fd08be876abe6b8faf5fc84dd826
6283143886518:7@s.whatsapp.net	59425402433630_1:0	\\xa72fe45962c19d7b347c669b78469173ba085921db8dbfdf1012c4687613c877
6283143886518:7@s.whatsapp.net	177679206723839_1:2	\\x6a6e793f268ae60c17d9ed578d4caa18c775b2e8cfbb0b363d6ea72d34f1072a
6283143886518:7@s.whatsapp.net	177679206723839_1:5	\\xda43838c527771d5681863e0c8a3b6f303512a36c8d88216932b2c9cc097f236
6283143886518:7@s.whatsapp.net	177679206723839_1:0	\\x5bea72cb62b2a8b121af69ecda52ed69bb1823cea4adf7b467068274cae29053
\.


--
-- Data for Name: whatsmeow_lid_map; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_lid_map (lid, pn) FROM stdin;
177679206723839	6283143886518
93991165026534	6281703703110
257638226985109	6281273605579
236047543881763	6282295599866
51424264233136	6288215779362
65210605944998	6281313468757
34926791491750	6281224347007
240509662564566	6281293090022
72796038234229	6289699810412
254743284863003	6282124741368
241665444987131	6283190169324
202151225737285	6285646856784
224717134925839	6282139469489
75552887197906	62895343978033
188794364002438	6285183792033
83241449029747	6285810558470
53755911344218	6281340040783
200330780348593	62895402418193
113709359841505	6282196119216
44178251755523	6282213070455
234235218681965	6282156341443
249932753707255	6285862840374
44672105844779	6281311018640
203779790094561	6285166659784
120332149116948	6281287466577
249022723960884	6288973380122
39561447100632	6288226488976
117352129626359	62881010730965
273134334775424	6282271590662
243546539974782	6282170082110
99472197607454	6282177554650
182587851055118	6285828387858
71297228881974	6289666666632
2929201266856	6285640537307
30980203139078	6285242288096
235042169159905	628976596001
163204663640074	6281904784281
97977062428735	6285155121883
153137193177343	6281325494987
202254791508194	6285739168418
187737365840073	6282118331556
223798532010014	6281977777422
66761391100033	6282119574925
133874180984950	6281372063925
117102384001123	6282298315508
215366991106196	6285234116455
167916175659084	6285156103523
124026290700500	6285157770338
53872462663842	50490444857
213142684627080	6282133604698
217900904361989	6281244431397
151930257051651	6282223536291
86393653080129	6283844628930
251122795200577	6282141999642
157213452689540	6285720763946
228290447020143	6285745113682
256126633385985	6283142012869
127500415975627	6282341053080
180435887865997	6285161655667
14547507257501	6282129897268
9500971016395	6285840136235
136580077514845	6282282215533
269372362878985	6285124291972
203697447510096	6281365962500
176347196473558	6281361233474
103788438384666	6287777222944
199128206287087	6283172288127
130915065946140	6285774254450
227156961538217	6289636594456
201254231908442	6283830641788
212184839786724	6285257574646
207305572413449	6282154704994
1920068514008	628123229166
108924732764303	6281219888023
237460789440644	6285707023181
235712234393696	6281218141828
58893044572240	6283872533447
44242625888470	6281258502837
56114368536630	62811140139
34011980288248	6289508657624
54654062878763	6289517100709
276690517377156	628156943967
9049781354744	6282113511404
67246890168355	6287788430845
124425672380558	6281573178167
72932923560185	62818100830
17562188439578	6285750572760
50234155597837	6289501913441
55903797694498	6281271786665
237516171010286	6285229456452
272683480657990	6281387210711
169591733018746	6285117230665
176454973292553	6285180734678
106695963447550	6285700479316
82558062706725	6281234399559
134943694950439	6281214254566
175707632181271	6282180525885
182807229943915	6285393686565
244903648960608	6285156890696
27758541422660	62882008708787
1190192533661	6287792983050
214611093672092	6285695023888
194841828941858	628819964461
210693915681011	6283852139479
93313164136448	62881012198482
58841605640361	6281460379454
180959991316490	6282121594697
164218494054654	6282226619130
255241534619890	6282123523657
17253017845988	6283823190241
1095300567119	16074994993
125400797732889	6285185905040
67345137553485	6285224821723
59425402433630	628988289551
269689620062249	6289604336460
178284243452073	6285215399783
14826831102005	622150996528
150822088396920	628999994929
30193821454414	6281223076295
65842469404740	6281519312933
131030996496505	6287804020444
210750253564096	628988385588
147695402545308	6283107846415
151612429475900	6283127378535
76759672352781	628889365470
163672680870072	62895619188604
47403721875605	6281946946333
161667031769191	6285810105638
146025264197707	6285124494102
252342800806012	6281211500668
84808944332925	6282128494199
216341948706906	6282219174732
141807086247951	628116500668
185366560653562	6285778283804
37156248637653	6287881286103
76420520894495	6289637056867
271648594870461	601111968407
83945253249104	6285322009792
41875947970622	6281320551386
195185459908781	6282234506553
62182637232222	6282316667655
65945078882381	6283127394499
234595442233587	628886600551
139432053207269	6281262222186
225610806874124	6289670700444
62895668887674	6281224499143
144564790812713	6283111350073
253656574259244	6289698749009
216733210161333	6288222041978
200858524491833	6283801542834
281002681336059	6281212747118
181694397153283	6281290908782
143726819180601	6282132250072
78439071674460	6282110965290
79598729576466	62895326554201
117038378922227	6283830162393
144277195780225	6283159777775
188197246111833	6283141226693
155714559426771	6283844071256
226744812486679	6282297875521
145067369058424	6283182013384
122033006465061	6289660132919
13451904708797	6281332094866
206545447084155	62882000007228
76433372225702	628977021403
142374021935218	6281212561332
181140346421313	62816293565
107619096244266	6281280797100
62470618087672	6285724450830
217836496642156	6289655078473
126169093505225	6289635531490
189773146771614	6289655354485
20736169218303	6285353297365
113065148330081	6283148042375
163067073683522	6282319671785
74509646360714	6285147730251
250813624668335	6282295348964
51170542375131	6281646883409
98892326641673	6282298397870
132658805924064	6282271466106
58463195504656	6282216863355
3011376095373	6283115373566
2199040045253	6283144561650
191246588981288	6283139844802
260515855073287	6281222721111
141150476325102	6282396223054
165940373246166	6285156281880
144306790748350	6281311966864
261705493909588	6285278527256
28282829467689	6283151984898
68307227009209	6283195949522
106648400089119	6281265647421
21148653883564	6281212556772
133075468046553	919810403457
182798237327437	6282336490599
136730971762827	601164058260
192710954762359	6282341222122
225593325031553	6287850014037
217840808386587	60193132043
219717725888646	601110706008
8517490598102	6283143546143
35485674147932	918817905574
244465411317939	6281381664166
249962952691829	628122821603
167950686392365	6282219441875
161306506195133	6281120026241
201670508191903	6285942276024
148812429529342	6285746418032
219413101940749	919873112129
59090260770964	6287881248288
64631406096388	14066474906
190318825701437	6285145471638
36674910310509	62895347168951
4196317319240	41798912947
166348512567465	6285232829959
26427487473798	919871173721
194768713871504	6281617577036
37040334889214	6285360353490
280848565841951	6283899617601
147704059527313	6289678015954
200128698802230	6282122516497
67899356143715	18085611634
229007824031853	6281210215611
179852426649768	41792746438
167397038284940	6289526918178
68367440466022	916005278396
22209930252358	601111215643
66258628264097	41762315933
164102278221889	919899003040
158964138102	6281298415840
205840820736157	62895711439020
30077773471823	6281334595476
165971109142571	6287757406134
230081934946481	6281779318452
26762612363382	601161712906
38504432144506	6281804832307
191959972978808	6285799012026
107331534753865	6287753556141
241991493410983	919810499686
250684406509602	6281338642037
63952247586851	601131632588
201300989997145	919326840015
172344303722700	6289605612906
207318507642924	6289512243889
48644866756676	6281931332240
186569688399914	628995910909
109663685206241	6283151652670
19989180461059	6283141618332
105488691757238	6289605794912
211274407370874	6285213998858
115895447896078	6287898987797
132272191709432	6285730817354
262104842035423	6289674978606
242794601951306	6289626905896
84988980625431	6282227652277
20933821628476	6281617111805
197182569361634	6285189978118
91221296955604	6285714278212
267602400141356	6282217921308
135940144103444	62895607822020
185014457217030	6282230010574
156766675410962	6282125774952
68805409640641	6281232279320
273869025886234	6285819000981
23910267531496	6285273411778
218034182582481	6282288184498
140673198100609	6289602793722
227964465754319	6285399647421
26581804314653	6285107725888
97135685025878	84925258531
164764021981243	6287823249335
\.


--
-- Data for Name: whatsmeow_message_secrets; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_message_secrets (our_jid, chat_jid, sender_jid, message_id, key) FROM stdin;
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC2401FE28075A9D8C9A6891C8079BAD	\\xc823a9bb029d7ca78601ad2e447db8e397402665f866ee65a1ffaf42b5aabe9d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC5D3CBE4E23D3409F6EBCE96E5058AD	\\x6c97764fc82ca020e28e9c60c14fd6f6b2dee8e836d5ac6331d96eec532c006e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC8AD5F3EF4A05B531447AFADA5C76FC	\\xdd32c1a255191e8e8e024f2b60b8515bd3bb4e5c7505df2cd6a14bce06a89830
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACFCAFF4D5C7D704032944A1A570DE43	\\xfffd32c91a51cb22263661a75aee80874d59a03f4ec59acfbc847cb614926b45
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACF2F7264419F4C1DF31CD686F55BA15	\\xff6f16a80a8798720fec62491c6279b91581d0e3f05b582df83c8c63f3f1e7c1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACF58027F1108B3B1FE3E07491E69772	\\x0b51d3aab4456a8068cc1102d2cfc866d3ebef0cc63649d61264ecd670dcdfd3
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC29ECF4D2A9625C5D45212ED876C068	\\x58c7a5bf55f78e736b34541ff374df446252fc3ab1a15a57eabd8dc389a53b71
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC089B8E05301F31E8636D019D9DB064	\\x204c5da647eace6ac223c0638a6459ee7ef7e10d5a64311f928d4ffc6f8260d1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC316F84FCA4A434130122F962BD62DC	\\xe9c5faa464938c0614f1e9902f83d3ce1e947d3c2ec8dc2f5820d9a2535dd7ca
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACB0D729FF4AFD10D95A24C72C9E7CFD	\\xc9571f081d147cc2e4cb42c72a01142798e47dc9101c9d6d5c12cd1c51e0ec1b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACC1D2A56DE6F37ECD7E7A6909C2A8E7	\\x56f0421e8bc9c079776647e0bf0e080ab9e9e55d216e9b9a444f850206d0a2f8
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC551EC0B0B118F433C9A9E55AC7EB52	\\x838d8593440a9605754cc90e395aeff755137eeb21c91c4de8ab109d3beb8f3f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC35A8224947FC7B22D905381F3EDA3B	\\x6cf8eec43d112416b2cc494597406227471fa9789c45e09d9a0d1f246439e73f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACC505ADEA21F03855FE361050F98640	\\x86e64a8f8ec6c2616aefa8fab501fc50d22c1007e9f4672c28e6684b6fd94b83
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC6FA2671294BF2E34B3FD1D9B61425E	\\x680b391c554c56214091a398913602a2ff27b67dda4dbde299297bc5b9a46fd2
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC595CDB4099489B3F7A92FBC06287C0	\\x0066d260e8f85f9b13f2b0437aacedd31fb81f87d78e927632f5cf1d9a12a0f3
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACD86274BC1B964E30EE83575118AD7E	\\xb73fd3492f76edea325aa2cc854f5ee1947917a39a36ad70425c01234bef630e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD1F4AA4AB2CA9549606189BE1CDA8B	\\xc237244a5c8de81e77610ad950349cae50d907ac63a40dba99efb6bcafc32496
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC87BB110CB95139692A286134798524	\\xd0fe8adb371e9be09208923f1dd46ac6aa6e9aa8341d472fede6bfbb178a10af
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACF7A7C064E775FDEA41EC0C8A9A5C19	\\x397aa1f3db6dd9ad8e4f9dc8cf700989ebb1baf82f5d2ce95617344238d9e6d3
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6283143886518@s.whatsapp.net	ACEA494B0755B146A04381EA54BE81A8	\\x8831231572e1e6dbdc4e84f1455a3e24c32f9e1a1822fa1d4839c6a65dc1b10b
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6289604336460@s.whatsapp.net	AC41997254B015FC5E82FE9C3885B5AB	\\x2f691cd209acdba6918e8e72a247ed500d02131ce52836e4fc4d9c87c6e7ed39
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6283143886518@s.whatsapp.net	AC79E182737FD86370A941794FFFEECF	\\xcf59cbb0ca14ab950e86e818762958241f7c0242b72a2e924dc67b32869e3e98
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6289604336460@s.whatsapp.net	ACCD36D8432BE39DF93CACCA73B292CC	\\x1f911436073cb38eefc2524b55e6f411fa2462d5411fb736fb7ccee96b7532fc
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6283143886518@s.whatsapp.net	ACCD2AF30265F075117894A978BC0CA8	\\x0863285b6d84d34e09f7225e859d64f858184b07149cb803ea6d571c72dc3f0c
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6289604336460@s.whatsapp.net	ACD299BE380D3B7017BE0287E1D1EA02	\\x4695b53f22b04880b545650301fb9ad6dfb70fdfdf4d069760be30fd100b6886
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6283143886518@s.whatsapp.net	AC066C2CBD29FC863D3319E0A4896D3C	\\xf8f035ebfe33a7815eb6c1b0f3834a79dbdb284e21472eac2636a2928c73e71c
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6289604336460@s.whatsapp.net	AC9D09FD4009C86274620C88C1C69ABE	\\x0decab107a4142748903e7c518947809fa536ffebd79066d2ab5d30b77fa377b
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6283143886518@s.whatsapp.net	AC9C3BFF9002AA29171AD1A64920E978	\\x721e924cce1a48d4b459ecd5f75a7ff9e2700d5d49d3abb823be0287d26f7122
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	6283143886518@s.whatsapp.net	AC7EBBB795727EA4EB35BBA3FAB86BBA	\\xd9f0427aca03f7b4aedd0892ffa0b559eaa5eba7a20f9897f167a6030e0a6ccc
6283143886518:7@s.whatsapp.net	6283143886518@s.whatsapp.net	6283143886518@s.whatsapp.net	AC2BA63EDAFD90D210AF000A343B32F3	\\xef85c6f67e94535b5fae8128abe97dfc4c8ffcba4cdb60ea7c194da38d7dc197
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	67345137553485@lid	AC40D7CC0328D52AF65F13E6C282103F	\\xb856cde5106d91eb8798f533be1093654c0d73d350a838649bb60513e545a56f
6283143886518:7@s.whatsapp.net	146025264197707@lid	6283143886518@s.whatsapp.net	AC76D998A140254B6AA1CBA1535BB0BA	\\x68a1090da998dd46bf8be0fc95097b2b310675d381dab456532b0dcc64ce7b08
6283143886518:7@s.whatsapp.net	0@s.whatsapp.net	0@s.whatsapp.net	1189864089268953-1	\\x2e12504e0d2274af2439f634abfb13bbdcc1dd73904e8c8a412de89450f85a10
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACF27E1698589072AA14796A664E2893	\\x0ea567a3ff1a42ed77f0739d0def52cbf559def64aaafd68b4a5fde580d7b398
6283143886518:7@s.whatsapp.net	30193821454414@lid	6283143886518@s.whatsapp.net	AC69A894DF33556D7B56E335821DF08D	\\x77f0968adc611178456848e7489ae5ae428f7fff32da53bf9d0f7a8c298f2014
6283143886518:7@s.whatsapp.net	62895619188604@s.whatsapp.net	62895619188604@s.whatsapp.net	AC3B23C637E68C4B86F78ADC1C9B5C1E	\\x1b452e224abb84407da340f9e0cd746e6028f9114724c2397e4e3ad4e0edbb76
6283143886518:7@s.whatsapp.net	6285224821723@s.whatsapp.net	6283143886518@s.whatsapp.net	AC1ACBC6AD1C50C75342C8ECB03D72C2	\\x574e1cc944cf52bca4c7c5836f36b100fb4c229d9bf72003efbe9dc78d19e8e8
6283143886518:7@s.whatsapp.net	628889365470@s.whatsapp.net	6283143886518@s.whatsapp.net	AC4F228DA741411271B6A4431EBEFA84	\\x7c6c9f78d24dd5475d0f3114f4120cee3f4501a9079b56edd50d79e0b45b6929
6283143886518:7@s.whatsapp.net	6282128494199@s.whatsapp.net	6283143886518@s.whatsapp.net	AC80D06F666D03DED725C1250FC4F7F4	\\xb01675ca6fdc24f7f540ffe053d85893c2a4396dc2831bd4b09dc4279489d4dd
6283143886518:7@s.whatsapp.net	6283823190241@s.whatsapp.net	6283143886518@s.whatsapp.net	AC76295844EA981F6FFB7485FB6F72D2	\\xbd3ab7d04e2bda60bccc6bdaeae77ab78f6b4375b6f5b34022691286f33fbdc5
6283143886518:7@s.whatsapp.net	6285185905040@s.whatsapp.net	6285185905040@s.whatsapp.net	A5E02F976918AE3FC9FC3AF0283295B9	\\x58e5df7ae97aa9065304cb803b1d4bbd6420bf45aeb2c3167a1d482789e7d0c9
6283143886518:7@s.whatsapp.net	6285215399783@s.whatsapp.net	6285215399783@s.whatsapp.net	AC60F39752A6ACCF1FE267A5A28BEF8F	\\x7aec34a7869911986e6d05aaab5a0ada6a7642445804289a87145dbd388f1f47
6283143886518:7@s.whatsapp.net	628999994929@s.whatsapp.net	628999994929@s.whatsapp.net	3EB051C07B81562B261E4A	\\x4467d418498ad5f2f21538034bdbca258b46bd87a44fa6eb61cf918ee4beec10
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC1A7E7E36917E2FDFECF3303D1C0B71	\\xf87f61cdff69958cecb32410e6eff0c7a8fef14c16c1a36c75c486b0f658f99f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC55FF894350898BE2188052153C2825	\\x7ef82809fd924efdee9714a07569a9457f7a8fa9e40a49469c903e1bcdf00a38
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC45760596AC660F0AD2D0AC11C84BE4	\\xed4d139a1cef30d8415203c87777b3e9e530edbf65e837fa61f32f29d3e4e42d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD795B321F83C34B4917FBDB9151460	\\x6eb4706a51320850aaedc70c24cf4daba2d1912fdce77c3adde7ea98b9950554
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC46C12C7C8BEC4F3B913602F5B90CCD	\\x8d34d07925ebf9fea53054710d8e437e43676dbcb64772da084928180a71a59a
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACF7E18E9F8FB8426A765FC4A43DE7A1	\\xe90768aea5473fb4a9fd15b42c19aa9e561ec31e04c650520dd3783edbaf19c6
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC9F3844E0B696BECDE490F58832AB06	\\xf9e6478694145467a8a6d928ca38e7d682892732da59c218c086169f96d90cb7
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACB83EDB800D96CA9A58867E1553149E	\\x86ae691a9022bacb198a16b97c31c5d9878e32dcc1d4aaf666b64f38ff8d4548
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC78E7EA457E906B80537CCFF9F86E8A	\\x806b31163fd847db747ba5d08a46ca2d44bd294644d2a896fc857ad344fca871
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACFBB12874AE1E26FF9740E756C87857	\\xc8bbdbe3c35a1ebc170e75e464854d6d8e6d22e013b08e395ea87dd7638fb9b2
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACCDCCC8D188BC837267B6BEDC4714D3	\\xe409f81954566f66923f35c1ec338900e1d3dae351e9f31a8cf980a86fa87b91
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACDA7BDCF478EDA24D7465AF9142543A	\\x1b3f53ba500c026a5f6cc56b9b39300fe25021fe78c8184bc32dfc98d2959bb2
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC710CC534C066D0445FCDFFF8ED8A23	\\x3dc99add01b4209fe49d929d6699e15d7daf69e5e1be4997f33df51a2f1d2dd9
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC1E0668D7111A50A63DA2A239CAB719	\\x7c3d6d357bb7c29d1a1c80109e31e7438072419eabee267df2260abd9cdefa20
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACE2C20F9936FEBBA52329865F78D946	\\xaa971211182a8c5bccb54b938b3b2d8bef1394b1acf50d502232e2b0effbe5a1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC7B0B6CDB9AD7AA6B18FC8842AE7E32	\\xdc229400436985f1c296b90d0d99f4295a56664c49fed387cbce5ec612082e3e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD4C8C8E19D0483CA5F15CD7E105755	\\x28a6982cb678fb28fdb0f1005bde4cc55d60827bfec126729a6a9b55466b1b2b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC09A7DA5EE38343F0D0D512446907CA	\\x0c2836636b0ae7f178ca2123657b4391e7f3fec7b8d69e6e4c5f45ad2522c123
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC21918BD6DD2057533EDF5E5D306432	\\x615622096758277576220a7001c815fd578ddd4348c7074cbf4cce4d3d7d2f6f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACA6675F92AD5258A3ED941C6168C716	\\xb37a45b3a779dee159a788fc2a09c91a1707eb709bcdfdc73b073c1dfb53433b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC69896226DA2D56189AA5FCCE409039	\\xc322228ba6f8d4744faaa56823fd4df8f4c85433e916b2b2daeeb12988f35aaf
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC27BB4A0CD0189E2F5B4A8332BC5DBC	\\x30456a8eb59d9393bcabe81f21d4be6cd38ce81cd53efcbe0a11dea49f57fc93
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC200A6839E87706B1293DF0847F782C	\\x4ccdc8c996e47d5b75cf3987e6ebe5d726402f0c755572e53b67101493509463
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC5D4DCCD488243AF61E5260A29624CD	\\x8f2d1219a2f5d61c9cc9b34834614a5d6f6a28102e0ad63c48533eae84ac5279
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACA17779908EFBBC465E23051D40C0AF	\\x8ae2e9cc1e52a0bebdea1d4c2ac3a7d0fa5dbe3d08c44a8c6d7101e6eb7b0bc1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC378DD058C959C22D1D82170E6D5088	\\x83ff2982ea06a9086e7e09ff15327462a26abba459333f9b4c70a4f6961f7f9a
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC084BE61E78F646866CA4A93843381D	\\x09bd645c3753c0d72cb9cd94e272e2a126e09026953f3f73bc479eb6cb2507f0
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC177812141A125B6D34D074158444E7	\\xd3de84056380c80af662a6dd9f100ad25044eb616b2cf7ff69515fb423fd0465
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC0AF9F9970160135EB61F6DDC217B5D	\\x4f023319cd27cc6fbbda694cf1ed91d0e5a6ad92989e8ef233401afafcffe9d3
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACDF51674B9E59EA7AC7EAB4BB8F9F6C	\\xe0d261ff292a78959ea055a4dd10ab596f5b81009eac921c06fd5c7bfa436e98
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC04F019D041D9B932631B38773B6365	\\x9eeb025b4ac49a278b687dc9978003423a1189b0516bffdeb6d146fdc45a4223
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC3D809B71C1B3F5225C2F09342B94C1	\\x7a0df286cd9dd74bd5164065b18a0c645dafa2ad73cdabea846c26653a0cc944
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC7547C0690479B909D86C92031A208A	\\x9caad40d3ca4db9fd7d49f32feafc68b6118ae743c7aa97f698a7a7d7388fbee
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC411CB6459B633590EE5474FA40F268	\\xc4938690e5765462997fd018ffb71c45dde381dd651753eeddc8be0901f04bf0
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC9B55B38A67526146AD42286B9595C6	\\x1e89689efd1143d025ffd2c67a43b8249b1329a65767b754131853f06674dbd0
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC166D91398769BB48FC975F9BD0968F	\\xe86e0579c7e1f5abc14715e0482468f7f4d1aa2f1c28dce5998570a780d952d8
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC71432EC23AAFA0747D857C07A2666B	\\x30aeece06e76d5428ef458f633f6060458a4f47ccb93ce8f930fc1faf87b7d88
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACF917EDA1C39C5A3E1B61273A1B23FE	\\xd0c5fd1bd5e0b4149fe905490a24f748855486983a1d76e1b299b0aafc8c648b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC922AD213C1BC5A23CE3603F7DDB928	\\x0ff47e70725c33e8e98bf1ab4eb75a0230fff3a3a84ced62ac787ac18b56de87
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC5B5B5D3B97398C6CB478D0789CD06F	\\x7552b6e5fa61a18771999d353f31394013f5952ec03748b0652ce8140d35bf62
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC3F21F20989D7A341B17AE237D3EBDA	\\x2eb4abe0b3bf995cfe409bfa8640d3a489a50c93594a04cc3d0356862b2c8635
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC83086D529A1353297E02FEE1C0F83E	\\x0175662992b86ca381b50f6b8cb4940c0f2ef34d049328364019b1e795aece97
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACA6173AC02F3C696152D37696EA6577	\\x67c99eafd44650bfb505b4815c2e2a1d171a195aa9597883f2022db29095929a
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC7F3CB56C15064BE2D4F3CCE7721795	\\xb6f6e7c933dbf10223cdf7c0f25f90f1871ed0f908a2d08a567523a4eb08414e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC1264CC25B63FBFAA089CE17B379741	\\xf95e641e8b11460f966bc9ded1172c6e81fa2a254ac2683e3c5c6189c8c0ec3b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACA586CDFF703E2A892B79D8677FCF1C	\\x3ad4bac3a62a09a7f690808780970d57f80f3cf4b33c0cff24b880a4f616af5b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD8CDB25894E3731F69894CA7815E2A	\\xd89d696786d3e05c0a9f2895a9573a2055617d326377dc51b69897e2e5c3e34f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACCBC3F67443E0FF392E9F8D51DD3B65	\\x0cd36e0584ff71aaa15fc1edb6f0699300b2779dd445a80cb7e9b71c209e1d92
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACB02871EE957B5E8B3B136866356428	\\x64870797d8277d2bb9b6b134bbb98d648f97da84ab3d24b72e951f0b77942f88
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACDD53E0EC24308EE39C637D122CBBE9	\\x80e938e3ce0f26cb9ae0fad07eeb320c87db4b395163289e810fb18bf09560c1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC310679FE2C847907C7CBCA6D4A0929	\\x941f8dd242f074d0d649486c1f2583bae9be3cff7a542a8f4ec4e37886085273
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACB1B9BAC7E534F5103D5DE3DA3C8920	\\xddb7c18f4d64b5383c7992c1dc33bfbdb13b51c1d73e4fef08b1603d3ceb3368
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC4FD8FE882205A26A83F2B5777CC704	\\xf07a5b4e6fa5d01a4d416f254e6e0c0b36bfdd101018ee778465d28046f655cf
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC69AE78DAB64C733209CCF6B7E923EA	\\x8d2c6469716a20fd8c0745e1f8b50a44ca8fc1c17e040224c88ee41303c4d36a
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC10C22291C25DAEB3E095492A531047	\\x222987cbbb28f9d2409a90e6998324a87d92c44e8d9f734f06eafca472855218
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC7FFA371FA9282A291C545A456BE12F	\\xacbf5d40936256de3c7c23f2ee6204d1b0cbadf3266c9926ce788ee74940a55d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC40EC847CB82A7E27CA266DBF1CE7C5	\\xe3ddef35d6f74f855a46a52cdf9858178dab66e80d80afc191f22c0170ac0ad6
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC34EB3891E0C5BE02D33C1F2594A461	\\x4048950ff5ba3d0a96b48891cc77e410c3a65a40a7f18e41919dcf1c6238ca58
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACDF9F152724366F15D3A74F28B3C4FB	\\x64ce28745f1853aad19a56ed39e6b264f0db6f225337bbb72e78c172bcb358d3
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC5051CA47B0BB73E165929E68B17B2A	\\x086b0554dc0a1d7f8938bdcca69406ba6146751702cb75ba3c05d440351f3ec9
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC5E3130706A0EE856CD486526E89114	\\x654a002c4b6520e2a8de5dc4284a86de0554b0bfad6340e0129ab4fca1b59869
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC69680312D2DB5C7D8EF6F17DF363C1	\\x4198fa66db24c863e1728a10b56fcef0edf43a2eff382f5672a1497dd0459156
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC54C690BDB8DCAE76C5CE9C9FEA1294	\\xf7e8eb806ebdf103e16efe9e29e32f6fa84c0225f607155558b7f1a19617a8d2
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC4C4809F9CAB64CB2BD6AE48F6749AD	\\x27ef6bf512b6cfbe4e2d3e15943e4eae9ea784ac58007dfdf5c7be1b21e18c14
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC1E080EEC0AB8AA81586DC692587EF9	\\x5356862304bb598e2a89e24df87a066b957f99de9c220dfc0908d441acdbd4df
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACBE44F9A4A438D0F7365C1B6A6525FB	\\x214b2fe1f820be2d7f0832b33c412b90ad599514a15c2bd4d5a1129ca7d0a3a9
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACBF354F81505CEB3B97E3188BB88CAE	\\x41e0168f32e007066940d6fe14c755bfab6827035682ba1d01356a1417ed466f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACFF46A8AAE946500C3443D9D9FF9BDB	\\x88fa765edcac568b6480e96fe1de62813b4897e9594016b07c2854331aaead03
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC35F7632A292F598A2ECEB80E3F0359	\\xb869c3e58725be0f41dd7609bf4ba4a00b98c11b0e9abe9b0de1eed8781d6ca0
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACF99C912FFA8AF99391A9DA24FDAC6D	\\xff6ae6a8e9cd00e584cba7fd2338e8317a0c777becd8661cb59333f4ca032cb4
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACEFE2FE1B386CBF9BD98A17F107F7DE	\\xa03b5da8ab56569350ff54eb0699f8ec41b15a396bebcbfe5c710406546cd0ab
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACCBB83B4D9E91A59DC41F1CE901D3D0	\\xbca627f52a41871b2e2fbde59bc5f0c75af05876b6b8253edda2822a46722129
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACE1EB9F8BAA8AA3E4689F6CAEC4CC3E	\\x27fa4d0f87847509daa45062cf24c4becec07b23d331c699c98569e14c36f53d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC80D0E5E763A44FD1CC436CCA80A3E2	\\x1c3b22f4876be06e31e851e57d375c17b5e9e09fe55bbbe82fae31e18b1d6271
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACDA302ABD076DFF0AD540A99B2CAAE1	\\x9368c35a699f529faac01ef73446059695adfdaac65ece78b8199a06b7cc3037
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACE688408570E542959A7A090F73E51A	\\xf7c5b0a7ab1dd70b152bfbd2294a57a9da14fe8b5aecc2ec2c7441d3a285323e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC95DAD008CCA8451A869612B03C77C0	\\xbb74a19f9649395b47fcc9736593852a8493eea5c54dd7337a55d9547266536d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC6F24ED27D4C3307026F6A1D11B0FA3	\\x2fe9a1dbffd5f0bbff7a302245881372b31f066b4a88921149db66cd449ee31c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC1C70F018112CD670AF0096C4BDEC99	\\x2892819e4554ff6a8c6fe1b899fa869efc5b822676172c7d6216f3311c0b8c98
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACFD9A1169C662E689164A32A2501DF3	\\x901511cc43ade17be129c9b92e2b53b3727545c0fc0bbf5642eb9a3f0bb448a9
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACAF8CE9B88FB0B8C617DBDBC59D9662	\\x504f4779bd8d54b6b2bebbd4516af68ad63bc874b6f69314145357e0b6e27884
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC52910C8795501BBEC76B5B60933185	\\xa10bba75f4e957a022df9a1838987abe4d948e4eeb485dbafe38676ad1090be1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC411929604090FFD6810B1D21195408	\\x514d593d18775477e97273c179eb48dddbe4fb708cf4c31054168816a5993e25
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC011FE4DFAE81ABEF9998C31E6C0C97	\\x7fe11997af34db264a62219dda15a0cd748cb865240de23d7431b4e7be548320
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC47F4347D47BD76B6E4E5A6C9F2D5CC	\\x99f2370cdeb677d986e4000f1d3dd83af5e90884e4973883926c8ce17043f25c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACE85A24C7CC92CBCC86EA05D5556F4D	\\xf1012bdb3bef706230d786fb4ea911e4a65033cd40b11c684a9c3738c0e6d816
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACDE64B5B296FBEB68AF0068020BE9C9	\\x30e3fa0ec2322656797eb6d555df72044745ddc27e2afc6a9f5c392df67b99c0
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACA320959E4FACCC97EA2DFB8A4A313E	\\x6a8ec86df31e3d57eff9741dc7aecdc2fdbf21c17a1ee9002fe4453017767dd7
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC922B2B19A4D42FBD421E7B569C7F73	\\xfcdd7a0070e90b336c2fd64a417b294a80803548aa5896b338a1fb571d2fab9a
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD2892C4646C898C5F4FEEE096EC642	\\xb52f5caf919ee46235299c9a440d701a72d4fbe794e19e97c675b233a5a11701
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACFA52BD26AAB8622E3B248BFE5AB2D4	\\xb366cacba42a88ac7245c84a81df0f963e0b301e9f2422c3aaabbb14dbc13272
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC8F35741B87446526FC3AB69B8E8AAF	\\x30fd561d3a4d34149a25a42c07968e7d5c740e537f131f89462acaf5fa6f3fd8
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACA7E5392CCED34FBCD580A924A1EAAF	\\x8e5a55e5c71e193d66d8f7e1351bf8c64a3384bb132e2358df574b59f4f34705
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC0368FE5BA955D66124E1651DB17848	\\x94ceafe57672462c78e28171ebeedd7866a2379f3814b0b8a4c5900c4bb2f952
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC0AFE72A85942C9C9FC75161ADBB715	\\x57202d1017ca7b9e4b5564a40da231a6e3845e01e1180537fedc655820f373c6
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACEF6A8333DCAE2A96B25E286691EBDD	\\x17e1a85c9187cd0d58f4b1196b99086c66557499e2a246677008d6be4707f6d3
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC17287CA3E16B84BA93816229D2FBD0	\\xbaffbd4004322a9e91dda03f0ee8b30ca311ab4be183c9aca33b4c684e674426
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC9D21E0F92401C42A11FD585492A8B9	\\xd4b5ebb00b25bd697b665cb513c1969729fa645c7b53b42d435866e40dc77b43
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC08D97A56E00279FD7096D90505D4C8	\\xe9ed75913df3919d1d32638f0d124072129a9d7467d3e86c644edb74ecec8958
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACBB9DC9F5E4ECA6CF620F3EAC902CFF	\\xea300b578b447372a3775fd8f2b7a6cc1d8a1720bca3e51ea51d9fbab7c9745f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC16D103722A1AD302A7E258AA3B7A01	\\x7625186dcb1b9c4aa0dde7179316039c1de6d408a12e5b467bc6d1d489b5fc92
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC3DB86EB6928E3B70467101DE991723	\\xe2e7d02d427996771482c543649dc3744897b7eb63eeb3fc684fdc0d30a4cbac
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC92BA55BC872E51EDDE9A177940D9CD	\\xfd8836b674c562a546fb62eac63ff0a2691ddbd5f826e205c5f10c5de5335f07
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD70AD2DA136ED6210646999473E008	\\xe394a6c022751b26fb456971c01e1581e0b6b105e56c94b93c2e6650dd4ea674
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC5BC3CE38F0B084006907532FD15F19	\\x22fa8853ef3a02714a0b631dd745b1c42b0479c2f4d02e2bac5917fd6fda88bc
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC57F0DBFF8F8F144555BCCB1F403BE8	\\x7fb150babea75cfe58e072273113aef6c7258c38756e8a9ade41e1aa35200bb5
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC620E59E9F145DF6A68BFF59D64611A	\\xde0469e68a46c8bb6cb9b77cf40d0852b00b4420493a74cd066d61b99985b159
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC7AE1BACD77FDE0758103DC0EFD3FEF	\\xdc38726b198d82c4567e74532fbe9a131322f6648addeabbeb63b4ea3e44a28c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC53EC0B0F7BB8A8E1223642A6603F4A	\\xe19a681d310a3aa864a0ba1509750239b18ac44ea19c06d53e393ce15c267f9e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACB92DCFD324AB7D499644D4AC9CFD36	\\xc42268bb384a46be59cfdd0a674eb538feea5bddae2001952b698854f7185d92
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC6388D3F3FBA8A893ADE8AFA7AA706B	\\xe5a3ffb7aac4875734ac19acb08c60f409643c595491cd06652a1683f267641c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACFCD2EC71DF17862A030F25C7D9AAE2	\\xf13cb96d047f76c34ce8b371e26ba9fa847746cc2df16038e02b9f39449bd765
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC9BCFF9FB9D713C995EB26BDAE71709	\\x87b30f45752d731fc35f099283f6f1f901e21c4f4e7aafbaa93dbac4f9a4b7a8
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC090827D33871BF4D96F4A03B8A026F	\\x05badb419c526bb15bad7d326c656f65289079c1c75d6d3e7ef48f1a64c61cf0
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC7DCA21B35F0D0C6BF2CD937732F4B5	\\x3c0502b534cd8ba550bd501d01150e612c60e74cc12f3a8e92a607feecad6fe7
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACC8AB77E5D257B15A29405EEF121413	\\xb0edfaf6f276f2485b457407bad06307e302830972368cbb576ecf14c41555e5
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACF6D96AC5BA6EA006EBC26047F8F12D	\\x650461863b0539f42c8d77d01a30655a738e8009f94fe2a312dec17929e62ff5
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC73F34DD5110490DEF5B8F9613185B4	\\x100da860e2425387878a60d2317093c3480c768d517cab164d6b90fb6ff0645c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACC40B954CE13D09C7585FC029108B60	\\x50150cbfbd5e548a95cd0572cf7245daa25c481efba9f2ea9abcffabede5c0c5
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD7A56FB627427DEF2C7FBAE077D37E	\\x569561f02760b780ad7a627ee81bc934df55ac16659cbee5a45a8d82f01538df
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC816467CFC4099E4E1F3A13EC67FE4C	\\x0199665f7a73b2f0997f90ab6d99e6e17de53a7943f78c67e399a78406261954
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACB47ADD899C090D696D8014326B300E	\\x9e60f06d6af79263130544cf0f583744339768ff35935e0f0b30eb0cca29db88
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC2BD6C54A04B6D78DB6FE7B3037AA3E	\\x64037af67ba655fb15998ea7a7ccfe043b1c12ca744c2326d6cf8f60064adb9f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC70653B74D3D2774DBB163DDCC13BAB	\\xed5eda5e841bf2376738c50438a678363dc3a2d4924f16af3457a4cf82f4c75d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACF5626FB485B167871C107ED7BDBF55	\\xb3dd6f86c6e72524e5210e6f151c90f3d1d94c7d17932a2d2749108a7d4aaa07
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACCFE6FED3D519CDB5C34BFE91F078FE	\\xe8f20985497041c41bf09bcca1a67ce3b1f8f014fe7c8ff001c5435c001bc513
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD85F122EBA26BD2176C6274A2020D7	\\x1b3b107508f76d0087e18eb6890533f45b960e7860103c0637d44c4697f27596
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC52F861C44D0C174A8B55B167EC71DF	\\xb030d7be119d1539db3426e15c2426848a11962769949f07022f796a3bf6f5d1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACD86862C94FB7E8370A693F603A26FB	\\xf0902b85b4631e9d1264561cfda4b9a77bf76c8e84728fb7fb46a098f367438e
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	ACE7021A535778689780033CFBEA36E8	\\x8ddc60d8cd63dea9ccd643ed4cb9e9350f66b4fbac8f7705bb89dc0358d0c58a
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283127378535@s.whatsapp.net	AC38B72142DC0298449A1E71E7F47F57	\\xc75a2dc449824989c33f2c3a4545b353c8ed25b3c034cc6861c1c2b2b1b47cb9
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC21A5D34A48DAD9BCB6F75202B0A393	\\xb6ff61e92da2fa9b8f931b219fae3d51c7c15fcf5c02f02c26bbea5ef45bbd7b
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC9F9CE7E44212DB60988D4FF2C5B4EE	\\x39f8d05e486f3e1d9de3c3d361157387d4792ea93f0216a3520fee82dec2d61c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC0A8CC7D71DF8510BF15A7E8CF00AF6	\\x6a10f98ceccd42c37debadb8beb16955df5213366896103209b8d3d67592a607
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC5136EA520CBF9F2BE0FAD5EB3064E7	\\xa1f8d158bd444e0892508e311e381e0a3100d65b7b8bb27f24ef585fa2fdd59c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC1BFC7AB13BAFDBBB58079DB9AF0C5F	\\x63fb392b84e5be28b88eec4f6995eef3dda275d68c4a1e07e54ad3e6bf63ae2c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC7F9951EC5E754DF1FB8D882F14C595	\\xebdafab3687158233b77c2db152680b66a847802b9355e76cd7e20b8b624626d
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACDD63631B105978C5E10567A93F41A9	\\x0132dba7d916d5e5bf51f5063d2c4987ca69146ee2238a873bef60a9140c5764
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACDC97DA99545F9568BC2A9BDC02219B	\\x4f1d1bb1507c35367e008c698e6f29822fa69e18aead89dc1098a308baeee0a9
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACC09E1218C631B0C406B17B23B02117	\\xbc2031dc34964489ff27cca592d5dc80a8d9ea00954ea090e148a5e1627ba1a7
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC1ADD3AF98389D0C817D1B9878A0648	\\x6bb21f766b8e9025354e9205f7d69576c1fef67a08f8d95ac607aa3e2a8eef2f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACC32C232B9A8782B877C1753EFF1C7F	\\x5cfed91ecdc1ad2e17842f7362b67a83a31c9daceea4674d7710b865d6508d47
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACC8A2DB53B255E80D895A080F239255	\\x0f53412de1edc03c8df1a6667d5409c4dd12bb9c0aab1cf1bfc6740dd733e6ed
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC44552356807A41ED78FD50310EFDF2	\\xa61d10e52aebadcade26c692ab64578578d144ee6a063df93ce27cf20a07d9d5
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC608E17BBD93E3F9B058A5381927D12	\\xc684de09f10c44ecfb0be4379bb6ad4177c9fd28308c22b738136ac1a55f58d1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACA55E87582C4F255F21E9187B623A75	\\x5d7ecd9d708b19b6b8206121d18b73a0957c1da156b32d416b705923d8db1f52
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACC003EA0A7363B13CEBE571176402A7	\\x3a0832997277abef051f1011fd5695fdf6a87c15a2de2563819a3004080e7552
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC5193367FE710B071DCFF007FA45F5F	\\x54b79bf69cabc57eac894840a43ebe123dbbd2eef73a5ed0d842468c892b99b1
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC3FEF8AF075AF7BF8D1F289EFCAB6EA	\\x65c0312679197fc14d6ada1d148b9d9ae1405305d9e397211940b0c020a20fee
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC09245A20A8184C1F94E3538A1C40C8	\\xe7d88acaf16388e44f89e7524eb67691ff80aba428dc610c52dceafb1ee2cb71
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACAA753DFC3A2825DD75A3E681269DA7	\\x987b4c4b606abeda976317f6602125585502e6720e1f55326059fd85ddfa6114
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC6C8397DFDFB1BE7EF7F88286B7A69F	\\x1c695c9afc33bd8c10755c7a32aa5fa3449859590a90c8e6371a29a7d976b54f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACD8E5F00B0E71A5D37CE4F16E075E79	\\xdaf0d1582d055e50c280a5e9dd52863e731684996368f539876c2b1c4c45175f
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC2B717425C39B26DA577076764CAABF	\\x270f34344472ae801028f8db8ae7b28d6c3f9090f2bea82c8c7fa65cc1f80cb4
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACDA8CCC99A21E817D448B5C5F1B33AB	\\x7530473d467c98d1da643efd4bbdfb781f48d341ebec28f80c94909ce79ccf4c
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	ACEA56D14E0EEB374EA68C32EF63C32E	\\x4973ef4a9ef6244cab9009dd254bcd2994a0bb518dae502b65ba14dde23832a3
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC24165D184428050D935C13BF883587	\\xf8e4f6f24db58829e55145719fab6b133019dcc5bccef641053efae73517ebf4
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	6283143886518@s.whatsapp.net	AC21953D362C1B267BA78BB927F59AD7	\\xaf825c8ca3af2f411955ca9d9b5379e6e51d0956b6b10fe2aed2cdb796ed7fc8
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	ACAB75E5CA4B9BD921C9E26F31C33D1B	\\x9d0d702c3dee8afc1bd569983341b6436718478e23eabbbfcfb4748207b431bc
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	ACD9289F6724DBFC9CA829D0B4B49A70	\\x88c9b4f129673bcd053eb56db2a7a4f0644f90bb554d5399ec4c2a278fa49c46
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB0876A6F633E69763F4A	\\x2e2f1e051dad45e868c62c62fa551d910f00ce55e618427bb3e2339140032640
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB0CC5F76ADB906623AC4	\\xa0af41c26d74d0a4fb0972a87865d3603917aef65ace5c246fbe20063ea0b34c
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB06B09CC20A55834F463	\\xbca899e26d718d82a2839aa62cc51ef2cca762f964004d5c14d70fd69c4d6bf3
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB0DBCE6FD45FA6E4D524	\\xc6f4ae25f34152e8ba9cfe2864308311f39190af4a6b2a2bc43b10be6420fd68
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB09DB3DAE45C13559A29	\\xd838a3e253404b3c47b9a3dc3f776215bf6df755c3798a09197d61d7e0ad2728
6283143886518:7@s.whatsapp.net	6283143886518@s.whatsapp.net	6283143886518@s.whatsapp.net	AC2C755BF0ED10EE01DFA1897F2CCA38	\\xf9d87b17a7dbe8244801536276603719359fcf8f5a1fb243820372a28e9ebcb2
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	20736169218303@lid	AC2A966699873144220CCFCF305A867E	\\xbaf84ff9a051527da3789cccb6598cde86839afbbd8acba68a934beacb6d1b4a
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	139432053207269@lid	AC5BC18C0595CDD82D7CDF102F6A872C	\\x0ff99804673942c8ad568539bdf0e0fcb0e4dbb6d81130976c5971762e21b387
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	28282829467689@lid	AC74767C7C5DEBA77B62C7F6A46CA4EC	\\x3d3f78d313090c4a4801c2f5f6e891db384bb014c93c26de8509979ef9941fd3
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	155714559426771@lid	AC261985BFC15BFD8A5CE5C7EC1481AC	\\x7b8ca512fc3b05e49feb4565b9789891f4da412dcf5fe53f41c3ad81c94ed3d0
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	163067073683522@lid	AC9B42B92DE7F76B561EE033BE516150	\\x2cc52f639d79b5cbf4f9e216edb1ab68a90ec78b2d61b4f8fbae892ea4f38598
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	200858524491833@lid	AC25401F4EFEF41E0A15E09375E74F9A	\\x628ea1e0ada948392ce6f0ae5599ae68b930e8753b321ad8f6275af1b7a599dc
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	217836496642156@lid	AC7AE396B5411D9E8E6957233300C4C3	\\xe8b9cf33ab9b745088858961b980e349af19a5c715e1bf591adbe101c42bffdf
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	206545447084155@lid	AC98608F5374119A90E5D1D1222201F8	\\x357977e37aeefbc3accadb6776ed6a51e83fd6d3bdc961d444e661d790f5a967
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	41875947970622@lid	ACD447DA25B63F6ACD6106F6A7A544AE	\\x8fc46352c490e559125ae74ec53f3157556bce7e93e612aefa551a20b8c30dc1
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	188197246111833@lid	AC0B6F5BC4A0708D309A49455AADA351	\\xcf420d84810b36e743838d63dae74a2d082077012ee0ed00d935d5d92d240e76
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	62182637232222@lid	ACE5CDF72FD126D673AB12A2DBDB7D3B	\\x005d66ae77d203ccbe4496aa45e72585a6607b0a4f958abfcd2c6c6a84140e8f
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	3011376095373@lid	AC43E5823E92FE9A9A020A14C7BCA6EA	\\x18bd87667053a2eb66352e9e541f40c5fe8de67d371443e6140c9b37195a7844
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	98892326641673@lid	AC30C940653A846CA887AD55905CF9D6	\\x61192f63f31b9b0a633fd84ded040daad7e07efbf25c4cb072401767041f6b5d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	67345137553485@lid	ACFB9BB803C5486389E7512655FA583C	\\x2464e932d78db0ad758a05cc90047348d9f54195f3ff3f7370b3259dc22c284d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	117038378922227@lid	AC7C8EC36FDCD94C9042F678E4224682	\\xf051a219d18f1166c09b53563bb413789459361bc7520fe2d28c0d9c5b3a50d6
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	83945253249104@lid	ACBC5540C1A4AC3A885246A6B4309723	\\x35b332c3e8547e4117e58300d1ceaeab6978d79d2e5c55271e6c0bdbce58bca5
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	195185459908781@lid	ACB1A9F1B76F2EA9053A4A8F30568D4C	\\x76a7f02b2dd3be4c19a8578ba56a8bc2c577564493c0893f9998f06b6d449dd6
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	139432053207269@lid	AC8D93CAF1AD15165FAD2D0663DB1501	\\xaa2eb5c02ee52ffccb21804d73cd89772f2c0cd673a1f0b1bc16e8e806a14c69
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	67345137553485@lid	ACF801F3702077508104BB7130AA54C9	\\xccd3dac93b170b973ce155f868aa6d11daace71ca2f99b9e346821fcc3f499c4
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	163067073683522@lid	AC7BD5146B7EA2A0B7ABB6DDDD8C2F41	\\xf1889cea5561806b1bc99f9efcc965468b8335c49de5029389bb8b9400efee18
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	226744812486679@lid	AC1399E50191615FE94D5FE023742A2C	\\x2fffba1b2a8e9c8117b1df9a13719e52f88203277c003741c3f9202ee2998844
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	68307227009209@lid	AC7076E4F76B943C5CF9C7F40B718EA3	\\x5c14a6b80eaa7f13c995ac979e7b0ffa8dc966bb4aefb23dd23bb48897da9ce9
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	200858524491833@lid	AC985C2BE8575596718268F36B9C9BE3	\\x3b51d02e8c8838f0422916dbc66de09f7b1b9df8b3ce5990962d5ebecc1ac617
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	155714559426771@lid	AC682E38CA2101399ED46DD0E9DCBE7F	\\x6974843248f536d23e1a2d0aa0088edf1b09f326e71440112aa8bf7f7545bb00
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	206545447084155@lid	AC5ECF8E8EB060558CC4BECA6E4A8940	\\x37f3a3e0af6016324c3f636bfd0c6b9c0c00cc90395489967095d909db38e57c
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	62182637232222@lid	ACA61BC4E66067F2E97C47DFCB8D0C7E	\\x9170980be17c8f296a89fe1d3eed5db687ea6aeb03add27307303846689132f3
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	67345137553485@lid	AC9893384F838397EBC9151657F82CC5	\\x40dc824a1761787d56e94746e23faa59cb7f25e4906b84e2d91577513230be9d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	139432053207269@lid	AC621D219E09139686BB9C3B4BFD08D3	\\x598473e9a0892d773641c008860b98c5fab0d5f35f47bfca4d13c656fe1a593e
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	122033006465061@lid	AC1C61DE62624316B14E9AF353736D6A	\\x01308b459f8c88896603c2dc0fe450a2730b8fa386b8532b4da6995f7d6dfd42
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	200858524491833@lid	ACA487D693190E86B3AF3A24B5E8BADA	\\xa379a104d6fa64d5390103b6ccebebce4d527ed566000d3cb5fef69b1042722e
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	67345137553485@lid	AC4F3B29E2FF33FC31DA694B7EDA1E4F	\\x2a154917659587eb3f523b405ff0c9be91eac00f5ad59cc9f85300907a3bca10
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	142374021935218@lid	ACB9B65C1ED9E032930602DEDF431BE9	\\x3dce3b6ded8a87052a098f49e8e9187e54c3d9f5213fb35532a52f08a33283d1
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	6283143886518@s.whatsapp.net	AC3DAECB3EBDEFC2F73B0CF3893D7275	\\x5ebaf34ce3cdfda1fdda93e2ca03d5454ea86e37939c3f4d04625d06b8fdb256
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	20736169218303@lid	AC727C6C9AE1BC3B1C46AD2763B8C62E	\\x01aa7a4c7627f2e1d29d527ed4ba70ccc4cf90d3b5ff7d319032c61293615cc3
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	206545447084155@lid	AC2E9195BBBF656A53E31AFF3C4B8564	\\x3c22fcc7154e55e1d8fa88b114ac85fcdf1fd555586596fd2587b33f95ae1339
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	225610806874124@lid	ACE375D45C9BCEBBA925013043C31F31	\\xd5765d30fa40dcea7236b955342d23534d50c8c93b95e6b68289590a0f7cc1fb
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	3011376095373@lid	ACE1E7067BFC8E917AB1340A0803935B	\\x244159e50ce5bb5c0910b7b0b35639f226a605d2203d94ef7ec92ac0f2f59042
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	76433372225702@lid	ACF9B1FD79F437B195064D849170DE49	\\x07adc29ac4910bb6e32ff4fee8f80ab1599b337c86d63d0e178bc308dfe6cd5d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	206545447084155@lid	AC90FA1AA38F6E8E1C8F40B0A82C7799	\\x836e5e37f31e8474ded18c10b5370c81ee2fadf4a1c40f1ff8f5ccc6f85e1578
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	2199040045253@lid	AC5C62B3FF62DF751C561580BB06D03B	\\xff5792bc0707df167e28d15cb52fb0e911f3ae375bf547d0767985ce6c343dbc
6283143886518:7@s.whatsapp.net	628988289551@s.whatsapp.net	628988289551@s.whatsapp.net	AC9A53E8B2FDDCA4AADEDE0A4F05ECCD	\\xe4bd2d8f1a409c08e231a6cb6cfd10f19e3080d8b81b3433d3be20957a2ffd93
6283143886518:7@s.whatsapp.net	76420520894495@lid	6283143886518@s.whatsapp.net	AC4346F2E1FF9E095D020DD767A67322	\\xbbf248ccf40b0442653de908932cfbdfadb68f20b619bc801113946ae8eee77d
6283143886518:7@s.whatsapp.net	76420520894495@lid	6283143886518@s.whatsapp.net	ACAC11CC8C55B07B7A691F7C3630A90C	\\x4345ac6340c678dda66e1628058117001dba8f882989f52e619b11b5bf0ab97a
6283143886518:7@s.whatsapp.net	76420520894495@lid	6283143886518@s.whatsapp.net	AC8564BB938BDA8ED3AE643BC8F3FC6F	\\x543883c7024bab05cc11ae10be5dbb8a3577ec32754894942996c200749fa619
6283143886518:7@s.whatsapp.net	76420520894495@lid	6283143886518@s.whatsapp.net	AC6FD2CF8FC0A54AD5029789B5B0C7AF	\\x305d221a21be75d2cecf814c8426a8e7594eb1159713c3448bc743380208e665
6283143886518:7@s.whatsapp.net	76420520894495@lid	6283143886518@s.whatsapp.net	ACC72FC20A9C2CF64D40DFFE1FDE1E92	\\xb915f25169b6fef9ca91446ea7f34e583476f776fbd72055699fae18239609e0
6283143886518:7@s.whatsapp.net	76420520894495@lid	6283143886518@s.whatsapp.net	AC3D789F423996A9B95EB181BDBF9561	\\x041f581eac3af5645b1bf1a8a713477edd1a1aa4dae285c308bf0b03a0a839ba
6283143886518:7@s.whatsapp.net	216341948706906@lid	6283143886518@s.whatsapp.net	AC618A5A6195590372A0A7F1796C1E34	\\x8b7602d2e91bca510474b9a6f88474d20dd27b103bc6e03228032bc18c0e5d3a
6283143886518:7@s.whatsapp.net	146025264197707@lid	6283143886518@s.whatsapp.net	AC3C13A05AC1723CC76942A7C19FBAE8	\\x611eb0c81b93f1a9b83046ad9b6146f5667cf731f0894d544105abdfb3ed9479
6283143886518:7@s.whatsapp.net	141807086247951@lid	6283143886518@s.whatsapp.net	AC7499BFEB1904EFD5E372E7029E5157	\\x372d8cddc3f25bb75e96856590f7dc6fd425848b17433491b0d520a5057c849b
6283143886518:7@s.whatsapp.net	141807086247951@lid	6283143886518@s.whatsapp.net	ACB610E5444416FB2B72C6290B296958	\\xb50f54b696f2a203ec42f3ca02e4dec6f87362d85e0aeeead4800e62265be962
6283143886518:7@s.whatsapp.net	141807086247951@lid	6283143886518@s.whatsapp.net	ACC4B62A095C0930C48973D1BA9161B1	\\x718391ddced86e34f4c6f1908afbed9b2c8b7d7d4e2f24daa2d4a9281fd0a6a7
6283143886518:7@s.whatsapp.net	141807086247951@lid	6283143886518@s.whatsapp.net	AC91F7CE8A902B59D5A52979763DA455	\\xa29c4c2e0eabc3c87ce286bcf3c329e6200098f0a1450fab3bdd204f9ebd6c0d
6283143886518:7@s.whatsapp.net	141807086247951@lid	6283143886518@s.whatsapp.net	AC4337C08C2C0C92527DBA63D4A102F1	\\xe7ab896a786dae4b24d7de490cf62cee90531951bce7be7fd546f9cae59c2c88
6283143886518:7@s.whatsapp.net	141807086247951@lid	6283143886518@s.whatsapp.net	ACCDD23B4E290DB297203BC907EA6776	\\x80a2ce96877e2240e1cfa96134ba4e568e79cdefd0cea6e11d8abc3663fe77f6
6283143886518:7@s.whatsapp.net	0@s.whatsapp.net	0@s.whatsapp.net	1251224280149080-1	\\xd3e2a999c4e032ec26d8a9f7c161591f740f3cd2f2f2cd7360f5ec56b412bea5
6283143886518:7@s.whatsapp.net	47403721875605@lid	6283143886518@s.whatsapp.net	AC997B3EA1DD8F3D383EC74763470222	\\x30b6ae72cb493dca6cd2178f48bfbad90f2ae8e364cb85d4120bb34efa3e5c8c
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC7D216549A78E187C31C92C747278A1	\\x3a0b40f17baf4b3d9c1b48c1d138d137cba13318bd53e4ebbf4f576257859429
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACCA3783229B362D44A25E627D442EA3	\\xb98bbca8155bd0a8519a335d1cd0fd157bbb5e830bc9bf986fb460201d1c35a8
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC42CBAF0146B40F156A8E67B279CD75	\\x4b6cff903222658d67d898bebf64423db6c4d0e68ede4775042f037fbe339554
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC558FEA9D201A9175153B7A90A46B45	\\x01e4817b6922162f02b4da66012eb0c946ea2801179f0a0f47a1c03d820c49bb
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC53D2C757BCD0A3B932C8C82AC77D38	\\x858d630312f5601fab955cc14315ced0863b39c7470890701411aef6631d7ae2
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACF88F4415228A064DC45F6F2DBC3C54	\\x548fa95b4df70b12401f16d600717eba7db22eb9050c592369ade8de99257f1f
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACFD12A91FBF7505D56B029A442DA07F	\\x5de6e5cc2976197bea550ca049d07a2b5380568636521a649588e2f339c7e4aa
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC46BA4722C577B838B0F02871A9FF8D	\\x90ebed9828aec6b56fa8cd4030b210168f0786d7d41c6576af5b322dfe4c8d71
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC319B2D774E4D80D51B617371905AEE	\\xdf76cbe88dcc3288dfa9fe3d11e5ee66d6c90eb5f348f8156aaee9278b7cde47
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC3858FAADF48F691F80F2F7E39DEC32	\\xe4f25da2f8cd0dd8622ff983a0ab14708b670bba29df33f1ad9772481a75afb6
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC47627CEA18E05354ECED101B5D4263	\\x85664ff90e476554412d6c93a28ef870936f60c6ceea111ae303ee875282243f
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC3AC28C46D1624F8CFB09AA82170F61	\\x3b846314450efb8ba81af6caa05ec546bfbd598539f4421f7ca20c5739f23770
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC8D4ECD92F96913E5B571AD30742925	\\xabd85c655137d250e5cc6de2b9cdcecc79c04f079964b972b1b4628c988a6ae7
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC2EAADE84F5882C056D1A67257CA0CF	\\xfb82c1edb8faff3afe31954a07b72cee13ac07065e5272edc11be572571eab87
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACDAD7135D5AFC81C2CE97260A9EA1AB	\\x0c37178c75972cfbbe92d1509c9d4ba27ace11f5efcf389c6e122945ace27e71
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACE81AF02294CD4867FDDEFE8049A7E3	\\x0939acfda8906f7ee58b3e3d5e9acddabc057b5bea786cd82fe8cdde1ec17526
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC27C0600A1F221597C1A0010A6658F9	\\x65e742c09fb16a06ae858da58dcc6a25f8b9c0cae921373d6d57955dd2d74cb8
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC49EE8EF42F16F772AA2FAED6CB7202	\\xd219c3feb0e221ac2821dc5d0b638511f0572ed81a3e53b97c19e2e182b2b04a
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACDAF8E61F2A88FBAD5E6A731D1436B3	\\xbb1f2d09a4a44d9fae4024f1ea029c9ffc59f343d9ce572ab30e8f615d885b23
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACC4926247B54EDB45D451D9AABA1C3A	\\x4438381a78037db5fbb6190ba6435b559a2b8a2c76a05fb913a8143056915852
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC658A384E6BD132480D5130697F540C	\\x2eae77a641f7b53018edc30f00de8b0660c5bd09c1ec9448e316b2ffb3605ba0
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACAAFEF82450DBC1426451DA2B27B569	\\xf25725d223d2a24c4fcdba7fb2c8935b0a3e1d4359b506d8a0f6288ef0d59672
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACC3AE00BFD0FBAEBCF7DAC7522FECEA	\\x88ffd26dde0d7cdd66b6c6e3cc986ab44e717063b9dfd940dc4d45ee9748fb6a
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC965D147278D6CBF99DB4A9EBE20269	\\xa6f3c1941e2c0f7aedbd291ee4f61117458ba6658560e4ec5d9a6c76b26b070c
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC936381C07B9862D060522A8F75C94C	\\x82f0004e1ca9c487ddcebfc2ef4326657f74b5bf642e9a6e1ce46c737c019549
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC25C00E4B94B043603FB0A2C76BD6FF	\\xd563aa5a91b519a49c7eb255edc5ce175fe25e9ab5d8ec3c1e39d8bc3ef8b293
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC55A45D801C78DBF397ADB28E3E36D0	\\xc39ee7142d7b5f06d57bd3dbef7d3ec59132a8ee6cdfc5dcb0fe6c62e940e072
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC9E91736C71033AFEAC4832B8D22B6C	\\x25f967ecf48dffdce945fb0a6d7cd47dd3c828230a5fc9c5080f91ade1fd77fb
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACE3706F9BC002E164C36D25219CAD7C	\\x25616e0e28c0145da6482e471cbcaa22f7438fe9851d7125700f62ee8c92c2d9
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC0A46F24555E1F0A1E107E0F5474076	\\xc7cb9284b275143fa8bf79f3c85d4a5d97e99d4151d15146527cb119bd8a5767
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACC3020E5FDC797A772AA8F86FBC9108	\\xdec4cb08a619ece8ff70ea92454cb4b9ccfb52bbe20d6255be057558d90245d3
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACBC8C0992E317F6668FB44051ED85BB	\\x9369658c2087ebb5145246441adfc68d6f61d71e51872d1d6ddb50de224b33f7
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACBADC06996407E2D687BFADF4C3F669	\\x7c5819a4631cca3998f0d44b7c1259c592b72f21d92aafcea64c0aea4dd5578b
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACBF3A113AAC1C3D4F9CA8F2C2D77204	\\xa4489c2a17f2c6b6d3dcdc1d3d5a48042a7b40d8d93d67ef889eb34b459f9dd8
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC774BB9C93A49A39E13F0F15826424E	\\xec05fcd354b8ca5d74dbed9d3db2de1446512f88ab9d32ae5f85a3ceea595660
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC9CBC74C9C52E4136B0BC634F2D2384	\\xe40e99595b7cbd6c541c07db95c36d2b3cef0f72747cbb262df6b350031d2c20
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC5B008122703AF439F71712D5AB8051	\\x31f81e98fe607f42dca8da23a4d680fc8af83c0a611265808afdc564d455a5b4
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC47B80CCC70396E66E8E57604C49C01	\\x5707202d0174fe7bcc7b193f99b8c569f583d62b4c07744d983585b6e091f69a
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC67B7D7C848BC18F4FF61B604390C01	\\xad3b4de9420c3552c805112d3d1e7ccc3ba5c2cd81bc935d6b22853f7ea71ce8
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC1E5C194BABE7C5FDFDAC7D7B67C0DE	\\xecdd4527e37a84c628be3b9faf9aab06f34672db9595a458fda9ff1fdc522baa
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACF0E4A8364AA1E805AC9E6F8DD5DFAF	\\x748e706cde2a67e8e8b4f74d494c0cc5d37e2b8b39a048bc56d44fccfd81c47f
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACEC7404CC17BF80191201EE137A96D8	\\x8822e712e50b0c05068665964087add816ee54c594ab5ed357697dc4bbd0ac46
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACCE8E0D1E84EC5742E4D08495722EB7	\\xda1263e6ef24a0f90237d0ffe4567710f727d8e66590cd8181845c7f85125178
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC0C14BE4A27BC086EF9FF03BB2C588C	\\xcbb54f41a583ce6e41c012b702ba5c6e743df19621bc7bb6d4380b1d236e7ab5
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC813B5E48324CF5EFBFBA7E67C42184	\\xa497edb75d6652bc3a1494eeb3542963c336119f69180b8fd91e026620833d12
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACBEEB1799EE76EB9B02A862E241E310	\\xba81d5e604a9ee76a689c3c82f8175cacf2018f80fe79f95e1caf9e6162d0811
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC938F3F12DD4E06275080C4A3047F2B	\\xb9f0005402dc18a4b7ae7d7cf2108af81161e857951d238bacf1c921a3ca464c
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC3396BA59A25F71E603917EC64B9891	\\xefe969b6cd2b3d7d7bb4bff724a0ac15a20874a252af80e3179db7668d525501
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACC6EF59D1035D868460D533C569B669	\\x475b83a159df8e10f9285049c2552cdfcfed2cea5850d73cf594e933b58a8572
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC7967E4C5A10AE766D4D9EA65D018E2	\\x498c7f0264c803c1eafa5ff075a8640051c2b1a07592db61dc9d8dccf3d09cb8
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	ACE266D92754E21075C0F6B5ED29A8DA	\\xbc7702ce1baedca179a674ec855226957ea48e310f437c751410e055ec027bb8
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC27F7C1643EFA5AC80D98D8E873613E	\\x0a7b1f5bb003739cb892897f541dbfd908d8f11771cade17a1a54053da817d97
6283143886518:7@s.whatsapp.net	131030996496505@lid	6283143886518@s.whatsapp.net	AC4846A8C05351B70DCAB92ABE0236D3	\\x2cfd142c29f450bad49484dfe7b293fdf8deb44adc6ad40aa32d0e4b0e2965d0
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC77C96E5AE69530D3D97F043631456B	\\x199215f796cf9eb7116c75fe54782a493cddb01f089a4b86bfc439894bf656b2
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	ACA17DA36908792B7A66F3E2BD4D6D98	\\x452df65e551e56ac9adcba4ed874748515c3c159e3697da50324058699530f2f
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC7950B5D044082532EFB33D3C3BB96C	\\x54cd53ea7146fe46b075b2c4c7ef4bb054c0aeaefd2d2ab4ae8b6bfef498d0c2
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC1944C0F006EDB3C94F13BEFFBBE87D	\\x72d041c7f0785bbc65fc316ef4f22f0f13a1f6b3b106ce2b841353bd3f655fc9
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC48579DA7021078BFBA3BD0F0BA61FB	\\x3df163c4d66258360414ec3270fa7a61692aee0a750f25982a94f4679d90e45d
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC2E1A6C112303DCBE9BC3B0E575FEE1	\\xb6cf9f197a585c0092a4dd741256ab2115e38e9b4e241a8782d96944f6598b14
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC49A276BA8ABBCEA7C2126B97CEB4ED	\\x59610e8b77613ea0b8bceb0ccd33358b67e88683ea6c2b4dcda5e86bdbbe5681
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC43BB650A388BA6D237014A04CCE156	\\xa00b481f6601206736f94e809febe0cda59f25bff25ed07d66673594c8cc3f14
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	ACA27DEC1B74B10801B482BB77E7F531	\\x9368ba5467152fae00096b39c9b5b36f2c01424c7b2ad67718515dfad897d442
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC7F15A73291E042C3C676CB2F9A8EDD	\\x58efb10ff55f0a1202c56eda0bcff6086eaa75d71499269ede20ec5800d06b0b
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	ACD4FD1C9739DEADACF10E9D4D61E2C0	\\xc8492f7101f5d99c8b029294a50185d92c0ae9a29bdbf1b4dc29378a5e7da022
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC888A6593EDED73EFA76858E3E0F21D	\\xb5d4f7b504f4c99679568c5dca71c367fe27ed4b5803e60f7dfad3452377485c
6283143886518:7@s.whatsapp.net	6285124494102@s.whatsapp.net	6285124494102@s.whatsapp.net	AC9049CC5B80CBBD7CCBC7F5334D3F78	\\x3e964df06be181232b6d0db8a673ffb4e209b718ac4375afd122401cfa2b6b3e
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	ACEF7F77C645E086EECFC79A7C9ABF3A	\\x504a1f753757a3429f5c2ec90c163c188a03a402822baf213e32140849214374
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC5EEB70F9ABDECD6E29D1FEF8F2DDA6	\\xd9034d484da515dcade0641a65f28920ebb9e542f3c8cce85c3e4c4cc4ff83cc
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC36300DC167122140C291A3393FDF55	\\xb05a93c033767ba382f5b643e139f60a7932a0d4adb91d700ed5bdfe949410d0
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC3A5955AC4A042229ABAF4F80C9B5A8	\\xbae428f8cd05877cb41c22e5bdf43ce0e56063f507bcf7f5ebef5a8cab7e3b1d
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	ACF02FB44DE09B2442EF4F9D51F247D6	\\xe9feb9ee1c8600eddde860f76902fc172ecda08e83d1a280dfda05391121e904
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB04CBAA9E9346AEF144D	\\xe5b2774a3829c55e9ccfcbc5ccfddb68a69742d16de1408c295a6e1b601c35b0
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	AC8524240DFC6058EF970A2FBB2C150C	\\xa651b9454dc77e22367f1dd6567295bd576a90ceee781b41d0ecb3496a115aba
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	AC5E75B99189C75895F61B6B35BB93B3	\\x9f20f80533dd91b53fa1d0a51e1c387604b0b5f2ac76fd04858d60ed4efe98d6
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	122033006465061@lid	AC43CD68757FC18C551D7FE143987FCF	\\x3921c591a5eb3dda30bcc3aefdb01061171ba4410fd88d8b175034fec5242c82
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	ACA8F069BEB952FD7AEE4BBF48B37BD2	\\x503cbf379f50fe9d2a58e4198b6f715234738531b74614a19ab4565937a07c8a
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC2198390E081FAA4284C4C7F7733C0F	\\x7a2f36ac0a164963870422e32e78b64e95c166d0c56da1a274bd4bf8a8ae8705
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	ACFE216AC89FB1E44A287AFC16DC8A30	\\x621e55fb71512e3839bf8248b6e6cbad709483f575d313b082f5df8abc05dad2
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC831360DACD19884145805F868FE65A	\\x315d4b10967f4e9c663a32bc33a759be55976ca46a446e2913d6accfb2c92357
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC0F8D2FAB95FB26A5C6273CF6C245CF	\\x474c4cb4ffe4d3386393a9ab26e39c096a9fddedc1b3edd93f9a6d7759513742
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	ACA20A7A73C2AD0AE71E2A0FFB27E3E6	\\x768581b44fbe5f7c0052a80a0a009f8278c3d75d52bb39c71a3ff7a980769a1e
6283143886518:7@s.whatsapp.net	151612429475900@lid	151612429475900@lid	AC7713A3A4C808DEAD6633C323EAA75A	\\x9e1da05549aab2f95d067aae8e304dabe34d6209bc095fa5a8c44f7d895ab25f
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC557EF7173CFE5FC943471A092A7104	\\x0fa09f8bb1cf8a8be8bf0b13503abc6d38392e941faabd51654c15edc6543df9
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	AC21E5A4B627AA78074F482C2F0D871D	\\xfc38d46747639c9b17b8771111808fab120f7034c5b70f17a8f72ecd75280c4e
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	AC3B8AB5EDEE02E1A71AE7A918F7EBA2	\\xb9026e96d5739138b35d10966ffef8d31ef200ad4e0af1ea56d3bd52e543de7b
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	AC2C3E6ADCDDAF1436D7C1040F633DAC	\\x19e1150bddeb85099064bd29e1c7d37d35ba5964309c4c2a3d91bb9bceb9c1be
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	ACBBC2A6404F808214EE9C8E2BD35B6C	\\x6c03c39a473600d6f9e90df99060f2df4971e96813feeb0058f1f6643ede63c5
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	ACD1ECE044E7B0B257BF5C3490025C22	\\xdb5064d338decef81096b1330a129183402f34bf4c1f23b1bd0c9952df6390bb
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920@lid	3EB0D623C1D5B2427E99C2	\\xf8e7e2ec08323ca7078896429155f14b86f4be847630542395ecb63b241c4545
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	185014457217030@lid	3A3A53E88B53F70E417A	\\xf595cbede9fd67b846bb527b3d61718c6bcf6a3295f04381cf17a60b5298a6e6
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	ACEA262E0A7CF83D29F12F03B8CECACF	\\xa494c907f73596397ce45fcd52cefc7eabd641bbb4b7e007cb3539ef9f5301df
6283143886518:7@s.whatsapp.net	status@broadcast	6281212556772@s.whatsapp.net	ACC7878773CF2EC575B8421315FDBE98	\\x36dd5a9dcba74918cffa1abee26b15424e46eaa7b5c776fed19009cc5f1b93d9
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC68BEF2D60E2B59B0EAC1069379B4B5	\\x3d2986049a267af24c8e054c22a579e287f637341a9f7717dcaab5f10ec765d6
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	139432053207269@lid	AC61D5C45F0C663864F4F2EF3FAEE3D1	\\xe4bc2c353dda9bfdbf93d9d55c033578844074dd4df93c879318994c13bcfb35
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	200858524491833@lid	AC12244DB68BF798BEACC17AFB37D87A	\\x1a06c665fde326fe4f75e8423e8d124ea850966e6ffdb0bd2c58237ef8329ef4
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	206545447084155@lid	AC17B9B824DE31996DB6725069A3CF97	\\xf147aabbdcbde6189a3e40225ce060cab932b166579baee3e7f95e0737d19bde
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	ACB9648ECD482D9F8E7FF5AD0EA761AB	\\x7e926d44c020f3d1a928b19c7cc3c45891c5f354dc4b2ff21f808a102faff690
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC790DFC12BB05C2944D9E503306A186	\\x145d57deea75b3cec943bbd4dc86a3e3f009e786496fae05458d0f336ffb8c01
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC2943590577D169470A45D64E2AD466	\\x7eb11021e7a37dffdb847583732ce916fb0422313f800b19b5cbea2ccb9a1e0c
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC6216628C49ED9C7AAC4CAE238EE17A	\\x76e6582a0f696f58ed08ccbf2d85409f14332099542328fdc11685e6bca11b0b
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC4B6E842647538F03C818130C552960	\\x77adf7fe00ffc1418bfb487de0e1090d62a0a45f48a13cdabb3d5a7416579fac
6283143886518:7@s.whatsapp.net	status@broadcast	6283823190241@s.whatsapp.net	AC36558909C25C097C80F046B6DE659F	\\xeb4b453c876cec81ee8fe773bcb951c48df0d60f59abc804a6849739008066c7
6283143886518:7@s.whatsapp.net	59425402433630@lid	59425402433630@lid	AC07D9028FC4AB353D960E95FDBBF3F2	\\xcf28898802a5a3e27f036c2c80a64dbf5be2532b1434ea6d63cc2e2fbcb88161
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC6268D3563A3142608F9CCCCBC233BA	\\x5257395d1088b51d618b9caec4bddf7b90201856c4d4dc7c23c2356f5594fdce
6283143886518:7@s.whatsapp.net	151612429475900@lid	177679206723839@lid	AC2B7862650E46269FB7E746D508809F	\\x8b8b29a9f86fb8bfa57b86ede53892e85b03ae8ffa4324108dffbff29e942cfa
\.


--
-- Data for Name: whatsmeow_pre_keys; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_pre_keys (jid, key_id, key, uploaded) FROM stdin;
6283143886518:7@s.whatsapp.net	813	\\x506d8782ccadd4975db3ec83135191f021c623236abf8eea0932fefdb5536f52	t
6283143886518:7@s.whatsapp.net	1	\\x607fe793e65079ed644a0a8da3cb1fa31e931b94e561344c77b53a4545e86540	t
6283143886518:7@s.whatsapp.net	2	\\x28bfb0e4270119752db0f75a80378efeb27585525b083b49ee99c25740f01142	t
6283143886518:7@s.whatsapp.net	4	\\x703c309055fc2184925df0344fd22d576af323a27fe284a925b32933758a4d4d	t
6283143886518:7@s.whatsapp.net	5	\\x7833f36d36f0c41da9b7d12065f09a5f566499a32f21a925db3c0c7800597a7e	t
6283143886518:7@s.whatsapp.net	6	\\xe00d4c829bf2cd91185f2b12c805372cd3ae9083888b95460b9e9d05d1144277	t
6283143886518:7@s.whatsapp.net	7	\\x90009e9ca3ac472a6b887c3edcf1e557e2d4f8f1ef2230b8a787e03169855a47	t
6283143886518:7@s.whatsapp.net	8	\\xb83f23f414b0e6d5e95174a757bf6c0ea5f3250cf9aafda646ac6b72d4815b5b	t
6283143886518:7@s.whatsapp.net	10	\\x488d2dbc70d33b512b88d74316399f417702c387de636f6a4e4c0e3c75aab96a	t
6283143886518:7@s.whatsapp.net	11	\\x78719dd32af24b4c40929e3bb95a2fb64717e6e2932e43c57ad6a7ddda78b27b	t
6283143886518:7@s.whatsapp.net	12	\\xd8d721774ef98ed8565795e53eaea8fb7d0ac36ab07409111c84a84ae76b0a7c	t
6283143886518:7@s.whatsapp.net	13	\\x70bc4ed035c8b5566505e1f07c416c2a51395594deda89df94729f11daa5926f	t
6283143886518:7@s.whatsapp.net	14	\\x38337f2e7760cbabd1f16cca324b39440a108a821a3ce5ef3e0e00cc2689957f	t
6283143886518:7@s.whatsapp.net	15	\\x8868405b25b9f3af10cd7c0ecb302373c89f5d9d57bff88e10b209346ad0255b	t
6283143886518:7@s.whatsapp.net	16	\\xe8335418ef27cfc6d9e7e5061a65edd30df601636b02f1f45126190fea8f9245	t
6283143886518:7@s.whatsapp.net	17	\\x38423e6b51888b2a229a0829f0da26c4b0d75bc1392aa308cab12bc1f687e552	t
6283143886518:7@s.whatsapp.net	18	\\x00fb1ff28ab4fe41d11251ea24870f1100008a84d2e177f0a5706a5490e4275c	t
6283143886518:7@s.whatsapp.net	19	\\x10b029cbe26bc336c77ad3f50aef9c6b6c03f5637749568fbff95a28d8d49467	t
6283143886518:7@s.whatsapp.net	20	\\xa01185044d2b55ff307790ad664afb5904e36b659cf0822e01354b0c202a5679	t
6283143886518:7@s.whatsapp.net	21	\\x2093e3aa33d5e6370afd598c4583eb77c4e45292a7dd16a189f2fa9e45b9ee4a	t
6283143886518:7@s.whatsapp.net	22	\\xe81ecaa5edf91a2db4476694ef7a82d6e3f63fb365794c9ee0b84d001412625b	t
6283143886518:7@s.whatsapp.net	24	\\xa882050a127d752fabd0deb69d2dc8f02823fe9ec2fde6ce6ba126ce0f041472	t
6283143886518:7@s.whatsapp.net	25	\\xe031934c07df2da4620d88599cb2cc0e5a1caaa38c83d74df54c13064576067b	t
6283143886518:7@s.whatsapp.net	26	\\x18eeb25201069ef3e4e2b77f519513baa5063119202072cf3c1f767c61656b75	t
6283143886518:7@s.whatsapp.net	27	\\xe83c867d867a3dcd55949ac11055acf3c84da286305201b503db2e9273d38155	t
6283143886518:7@s.whatsapp.net	28	\\x000e0ba58191a587f399a6caa6c29aa3db69a8f3654f45312921860825adf776	t
6283143886518:7@s.whatsapp.net	29	\\x4848a2e1e3e65af93e78add2266c49dc7cd49732593c8af5087798078e1b545c	t
6283143886518:7@s.whatsapp.net	30	\\x5011fdd7c2c1683554e8fae16197b6d90433b7e926aec4ce183f87cae467ac47	t
6283143886518:7@s.whatsapp.net	31	\\x10cfdf1d95b6dd26ec6c992f003248cfd107f096df19453a22a3933067ff824f	t
6283143886518:7@s.whatsapp.net	32	\\x385a3108254c03a3cbb1e00f403e96453637c9a2807d691c30caf801a0282656	t
6283143886518:7@s.whatsapp.net	33	\\x40afabdcdd7df4fa96e6318e993ab8455da6b55aee40dd83ae3424e038c80546	t
6283143886518:7@s.whatsapp.net	34	\\xa0df6d7e21953afeeaba6a2575d476bea748567d8f118f4af26fd1d751ce0e50	t
6283143886518:7@s.whatsapp.net	35	\\x7052e6d03d7f092468f4c296c6734fb7d227d89a85731f53043fa8e82cb8fe5f	t
6283143886518:7@s.whatsapp.net	36	\\x08c959b2af9fd27f5daaeed2c869ba09080a08406b51140a2485d146fc289461	t
6283143886518:7@s.whatsapp.net	37	\\x38506efb361536505a718dd97a024e23042729e88ba9b28373cc4b9fc10acd61	t
6283143886518:7@s.whatsapp.net	38	\\x280bb6314262364317580358d59a84e4ad8310d9efaccaa62768715acc51b942	t
6283143886518:7@s.whatsapp.net	39	\\x8877a5e261d67bd82938d8f84121ea25a821f474fca2a87bcd6c7c558156b366	t
6283143886518:7@s.whatsapp.net	42	\\xd8eb2499cdb88fd9777cf6e5e496b26b6bfc0be99ae87e76d27e91385531d970	t
6283143886518:7@s.whatsapp.net	43	\\x18b43715d76d9e1d7e79cee98f88d1e18aef47ce42246b0d7e726a43124bd546	t
6283143886518:7@s.whatsapp.net	45	\\xe8da245ffef05bc100e2088e442437b91756fe73bd6d4dde59e36d92ecfc925b	t
6283143886518:7@s.whatsapp.net	46	\\xe07a40f98e97f3277ae5a66a338453f07a211960b6d670edafe4ffe068611d40	t
6283143886518:7@s.whatsapp.net	47	\\x10f8acc00814925260a825aadf17d46b0995e8e77423127b498a47f6f4d39461	t
6283143886518:7@s.whatsapp.net	48	\\xb0198fff75395dece313510a8974bad72bb47e41626bc5ac9b69ff1e5cf3d368	t
6283143886518:7@s.whatsapp.net	49	\\x88228ebf440d18465b369b2a6e46746df5a48700f1b0a8374a2994d843712868	t
6283143886518:7@s.whatsapp.net	50	\\xb0bf1efe518dfab9fd852543db82f8e6e9410d95f5b94f2110a0544f7c744342	t
6283143886518:7@s.whatsapp.net	51	\\xe884a28f84a85c833f9f74ccc28926d9500381dab9b00ed361992104e4e64d56	t
6283143886518:7@s.whatsapp.net	52	\\xd85a22e761c31d3d1175a887ee76a5e54b9ee7e2b77204b4d3938ee0fcf81c77	t
6283143886518:7@s.whatsapp.net	53	\\x3003269cf35e970679404011a68cae3cf704e6b8ca3b57e42224a500200b4a6c	t
6283143886518:7@s.whatsapp.net	56	\\x20c356c5b6458b879e832e7f14fd631adae92571b742f01670aac2850c53ea6d	t
6283143886518:7@s.whatsapp.net	57	\\x685ce2685c9f738d4f6e0793ed9b77ac9f11efab99a31846e64b5adbda775944	t
6283143886518:7@s.whatsapp.net	58	\\x88398f4753e2e9697907afa0400fe634c3e2d12c356810a36f0f591579412062	t
6283143886518:7@s.whatsapp.net	59	\\xe8cd602430fb06d07c642958895d6bdc8938e832f6089641eaacf9c0d25f0f4b	t
6283143886518:7@s.whatsapp.net	60	\\xf043b44e04dfad7b5623703c064cbe2defaf67480c7061508de9646e46200662	t
6283143886518:7@s.whatsapp.net	61	\\x900decd0d85e9ab6cc2fb365d469d901e1fb06bc388b986c49f64a4609268a71	t
6283143886518:7@s.whatsapp.net	62	\\x5089e77b4bf20739e96dd25805b54a82ca5bec65f0a8a49e24ebd9c229591f48	t
6283143886518:7@s.whatsapp.net	63	\\x50694bc46b57e93dee57a154c960d6a032655af6d7c4fcf4b19b12636f88be61	t
6283143886518:7@s.whatsapp.net	64	\\x3884887e04a1443c7baf8fa2972d97b2b3f1a7f15a3cdc9fa984a5260e10055b	t
6283143886518:7@s.whatsapp.net	65	\\x982d5cf67abce0cb9a7eccc5350ade9f377d933a521cc763168f012cb2ee5056	t
6283143886518:7@s.whatsapp.net	66	\\x581c1bd0f39d28ae6ad3e8b98d623612fe8dfc99b7a9411073099922a5b4f07c	t
6283143886518:7@s.whatsapp.net	67	\\x507bef6a9e4ec44bbd8ece074fc83ccc55bede1796a8df1197f724b1918eca79	t
6283143886518:7@s.whatsapp.net	68	\\x30712863e30fe91fa8453ca78673ff89b7821b0b1eefc90c3dcfdace0dd4c46f	t
6283143886518:7@s.whatsapp.net	69	\\x004fb39620d3dcb12910bbabe4323b364f4e5e2ecd55a24d00a47c7f1b37907a	t
6283143886518:7@s.whatsapp.net	70	\\xe84e910867e4b5926ae452f80d9591e085b35017a8e4c83bde930671c7847c41	t
6283143886518:7@s.whatsapp.net	71	\\x38fbbc566bacef166a1ea5ddd8823d920ec7c9f7158472adc684f3b4b0b09e61	t
6283143886518:7@s.whatsapp.net	72	\\x50eea5a2454684889cdab5aae483f0a600350beaf83f312d019d069707f16661	t
6283143886518:7@s.whatsapp.net	73	\\x1809fe36ffa9ea1553a29a12c282fecc1211568794c1592dbdb2fa684fa4986f	t
6283143886518:7@s.whatsapp.net	74	\\x28d20f39cba5f67514bffbcd5f5887a5e76e5cb48813b3dc07dc53ae73daab7e	t
6283143886518:7@s.whatsapp.net	75	\\xa01b7fe3c0f53bc804a6f67bc07d9275b13b4372e15cef2b538a54782593345b	t
6283143886518:7@s.whatsapp.net	76	\\xc89f4f19b2322430f6d6e7ab1e5653861bece4ac75de53c52b676b80ab6d274b	t
6283143886518:7@s.whatsapp.net	77	\\x60a0c3b75ccf51a58b6c4dda2dcd1dfb82a51ddb67298412bcf1947fb2c2e06d	t
6283143886518:7@s.whatsapp.net	78	\\xe0ce63a4e64f079e5a4d8370fe90044fc2497e4c1cf81fbf7c3ccdcd15006e4d	t
6283143886518:7@s.whatsapp.net	79	\\xe0792ad065ba224106754a20908c0a6059abde6dc7b3b24deaf40a9b47665d57	t
6283143886518:7@s.whatsapp.net	80	\\x4055652c4c2cd79744a85ff433bc23e4835ac26f49e0bbb64bcc32f138f82d54	t
6283143886518:7@s.whatsapp.net	81	\\x8896c0c29a98ed1a6967e04b97463c1fca11df6ed719d39c1241821f5f3cb34a	t
6283143886518:7@s.whatsapp.net	82	\\xa0bd6e68c1fb0e252dede575420fba626dd7299916331ee4b678106b83ab527e	t
6283143886518:7@s.whatsapp.net	83	\\x78b4c4b74752cd630493a8ae6aa9eddeb1493121c59e6dbed5f772a98d3ec772	t
6283143886518:7@s.whatsapp.net	84	\\x88770da776a550fe154c71f62b9c3d884f112288f005863b62a6d56f5e60b07e	t
6283143886518:7@s.whatsapp.net	85	\\x10c86247aae266a65c86516c82660f1719dec2b3c4f6e46b9d46f2513772cc7f	t
6283143886518:7@s.whatsapp.net	87	\\x3057360e58986ff8531cc7738595522ace3c96e8f2dbe41622b4d789e9bc4242	t
6283143886518:7@s.whatsapp.net	88	\\x389afebdefcc4157fb2d6b3b27cef7a0495b42981021f0bf1275249f328c9f43	t
6283143886518:7@s.whatsapp.net	89	\\xd895437190657abf30d4aeb94873514c924a3c013f10876a24b532e4f9c8ba59	t
6283143886518:7@s.whatsapp.net	91	\\x9822325c84fcb763d101f5312de2a07db74cea49b6c81ba68ec37c69f9477e4e	t
6283143886518:7@s.whatsapp.net	92	\\xa854518d6ce9f1535daaa3a7778f7898e95536a34bdca735ccbaaede7eb2796d	t
6283143886518:7@s.whatsapp.net	93	\\xe00f5dd9767d70aacbcfa3c1d225f99abf3daaaa4ba3e7c1e786065d5c46db6d	t
6283143886518:7@s.whatsapp.net	94	\\x58f2f60c48403ac4fd1158d078a4ee2319a1aa0e848b82c2bb8d2fe66af88c6a	t
6283143886518:7@s.whatsapp.net	95	\\x588de0a7176a77fc22c63e5b9e11ccdf3a2937ec798d58c0fe386b8dc2509c5f	t
6283143886518:7@s.whatsapp.net	96	\\x9025ec03bdb77cafa19e27c9bb844181012a863dcce4b9ab6c4088a31fa91e7f	t
6283143886518:7@s.whatsapp.net	97	\\xb0d07a4f1232d445ded6cb6f98e5c23fc092bcd647f5930df3aee56b7c3a8f7d	t
6283143886518:7@s.whatsapp.net	98	\\x608c88c7c60c4b92539718c4e549aaf17d28f39550b6b83f61c33c6b7771994d	t
6283143886518:7@s.whatsapp.net	99	\\x5076dd1ee3645acf8b52bd547a0e5f7b432c43a14d871fca330427d6d0ec8365	t
6283143886518:7@s.whatsapp.net	100	\\xd8551a177f3f725b2b780fbf2ef8ee6af0860e0e3f2658ab1bdc02a50a57ad5d	t
6283143886518:7@s.whatsapp.net	101	\\x7880b772f8fc4cd1f92301908e9bece39c1aacb1268c79b046d5e6b82178ab4c	t
6283143886518:7@s.whatsapp.net	102	\\x8892e85b1da4a6de9db65283a6b285bb34e8d736c4f3dc9c4cbd42952e899055	t
6283143886518:7@s.whatsapp.net	103	\\x30d1af34cb006f063b66509369f23cbeb6b37b69d501ae924c0bd9e521ac2d42	t
6283143886518:7@s.whatsapp.net	104	\\x501cf9b813e02450d807f9a05163abcd847ad1dc57a0889fd2141207742e7c4a	t
6283143886518:7@s.whatsapp.net	105	\\x588ec49efa918b95e216c8e4c3073deaa51040044a6faec1efafa2fcb51eb66e	t
6283143886518:7@s.whatsapp.net	106	\\xc042f2677ee187cb3f45ac52131d6c63f66748dc0165766fe53095dfc3d5ec4e	t
6283143886518:7@s.whatsapp.net	107	\\xc88e5258b1f6de8fff05b9106111aebff955b29ebf500622d485d1464267ef4a	t
6283143886518:7@s.whatsapp.net	108	\\x509e3294cbb1d0494d42d57b1ec41e7cda0099c10c564566e468c4930838e652	t
6283143886518:7@s.whatsapp.net	109	\\x208ba04d083703432798f9e896fab0e5a55f9b9ce671cd6e6566f0d9837ab96f	t
6283143886518:7@s.whatsapp.net	110	\\xd0a5047d8ad5b0805d113372786d88c1ee1dd9c46b4a00fdeef8627919b5305c	t
6283143886518:7@s.whatsapp.net	111	\\x2816e291687f8714984e9967f8e6016c44d0a1de1922f36a6b9c85865b281d6d	t
6283143886518:7@s.whatsapp.net	112	\\x2097bc2e3cfab338725e3026d496e0d88989e1b2745c484ff60f45513542c141	t
6283143886518:7@s.whatsapp.net	113	\\x00e2defd55cf644f13f4db4120a617efd962e3799b26dfd808aece4c4a4b4d5e	t
6283143886518:7@s.whatsapp.net	114	\\x10ff6f3743993b0e782c3e177c2317bf2ba46b63ad23e021099de5aec234a475	t
6283143886518:7@s.whatsapp.net	115	\\xb83d7a5e9e8ae3e88ba5b93db94ed6c34d49f4c2edf0777688c8980cfdbed178	t
6283143886518:7@s.whatsapp.net	116	\\xd0e088ef120c4567de9d810ef6ba1d2205232b2e75eb711c4f31508a4a5fa448	t
6283143886518:7@s.whatsapp.net	117	\\x0873e1fdbbc84e65e295b98c2d8391d3341e6720a60ee37ac0a87dd97778fe5b	t
6283143886518:7@s.whatsapp.net	118	\\xf813af949b6439b3f7e61bfb1d06c458789d122d7c4bd76598049aaee98fb656	t
6283143886518:7@s.whatsapp.net	119	\\xd084dba2de69604cdc9c4b1011176a8dc0795074353d15a8ccffe152715c4d4f	t
6283143886518:7@s.whatsapp.net	120	\\x90892dfd3bb3ffc3fc887218facc31104d9a4d4dee73d2d0045eb41cefa1a14c	t
6283143886518:7@s.whatsapp.net	121	\\xb821b1f38fe572572d75f2d347f892e17610a2d64b5e7125c2f7f12bfe427856	t
6283143886518:7@s.whatsapp.net	122	\\x806c7a33552a67d14fb302951fec569c299c4af0f66054936c01e7d96a2cb46b	t
6283143886518:7@s.whatsapp.net	123	\\x5889e3fe6e03a91a241920cf2774982fcfc27fa35e76a2d85b5002d6dc42bd7f	t
6283143886518:7@s.whatsapp.net	124	\\xe0c63ce78f5491d759adabed48cdb675d6e9d6f9652b9568a7c0ad4ab8d04658	t
6283143886518:7@s.whatsapp.net	125	\\xf8dbb55f2fbefb6e703d57a2dba94e51f07f4076805f3b2fc2b5bb946d41e37e	t
6283143886518:7@s.whatsapp.net	126	\\xd02ba8e717ba398537c1615227a7a82ad8b5450d14a847aab003294cc305777f	t
6283143886518:7@s.whatsapp.net	127	\\x103e133aee02aaee4c88bd33502b5a178cb8d17d1f0554d51ddfed2cbc7e3d50	t
6283143886518:7@s.whatsapp.net	128	\\x98ed819738a22c8ba4e641ff14aefd6492d360b524162d7baaccc4bf43d9b256	t
6283143886518:7@s.whatsapp.net	129	\\x3002ee2d7d846d9ac003993453cf4f9a06fbede98bafd5e9647648c4c7b68b6b	t
6283143886518:7@s.whatsapp.net	130	\\x408c6732279566e277a547469403c77f5c5fe5a13288ce47b18e2e7b24c27b6c	t
6283143886518:7@s.whatsapp.net	131	\\x4868484858c1faf37628fc882a15ea6f207be6ce9865dac7c1e0f7c07cdac45a	t
6283143886518:7@s.whatsapp.net	132	\\x4887324902d1d4a24ee9ffd0b58c7cb9427b2c7c82269f68ff893bf391fa5757	t
6283143886518:7@s.whatsapp.net	133	\\x685fa49c319d85befebe9b54a3ca86600ce875455952da08ca449a3c4861ac47	t
6283143886518:7@s.whatsapp.net	134	\\x087c7ac5f85d355519ae11a1fb8446ca8dfbb935d968f5d6338fc74b43bc6877	t
6283143886518:7@s.whatsapp.net	135	\\x505867711daf4e2a82a829d123051b09be6b5c4c1364f34e84bfdc8e81d0d640	t
6283143886518:7@s.whatsapp.net	136	\\x7804530b07e4fd3b7ac35d756723a3537299a052769913b05e9ce268e7df3360	t
6283143886518:7@s.whatsapp.net	137	\\x00524de1972fee98c52360c4961ac84db5417f124a9912b91e82691d91314b78	t
6283143886518:7@s.whatsapp.net	138	\\x10b4a90d658ba69f5f1dcc9eb919dad495eca6230e299a980abbe0a5af08fc54	t
6283143886518:7@s.whatsapp.net	139	\\x9832a9edbca67b8db22820b8e8cad8a3080ea9604e1343274cc5ca1b515dd571	t
6283143886518:7@s.whatsapp.net	140	\\xf0626becf44910556ea27bf480e8a4c6b8f525a8aabe24635ef61a1fe1605b61	t
6283143886518:7@s.whatsapp.net	141	\\x605202b869a65dcb88d663f2d8653c55241d0d28a887955b1ab5b57bfc61077f	t
6283143886518:7@s.whatsapp.net	142	\\xf807a37beaed95dfd4351e153b361f5b9d94beacf30814441ee2781f14662148	t
6283143886518:7@s.whatsapp.net	143	\\xd01e44c9787b2660f478f5c7a87d665e54c25eb444c0b0565991d22bd0ade36f	t
6283143886518:7@s.whatsapp.net	144	\\xa0e02918b60cf8762cf81f8c749cd81390f1293df248f33440e83846fbb3d861	t
6283143886518:7@s.whatsapp.net	145	\\x70e6b3bd072adc8191db5623a4e0083ba0edb5a24791bf837d5b438b56d37150	t
6283143886518:7@s.whatsapp.net	146	\\xf8dec907153f89e3312715551ea8f53b90e822909a49df3004cbdb6ef1d95969	t
6283143886518:7@s.whatsapp.net	147	\\xa017127466101ebd1a9864b61c1fe9b67efc3a90f27189aac900214a54430d60	t
6283143886518:7@s.whatsapp.net	148	\\xc845b8add5faf361e0a31b226b6af386eac96b454a0e1f8d12a0518b389ad04f	t
6283143886518:7@s.whatsapp.net	149	\\x583cc5b60f758b028e9defb6aa379ff5e93d42032b2d45d74382cd3df651e650	t
6283143886518:7@s.whatsapp.net	150	\\xa0474e9b385c96255562f3142746cbab33c7db95275a7e9b9245adb214259160	t
6283143886518:7@s.whatsapp.net	151	\\x601d8c22802946957cf76f88e7d4ba2b34ac849d28e5be6506a0c86ea3f69152	t
6283143886518:7@s.whatsapp.net	152	\\x8811a0acc20af23a1f79b6d41002ebbb681e29509ca9541b2bedf3c8883d4146	t
6283143886518:7@s.whatsapp.net	153	\\x184bed8d15d54ca80d9d5fe5efc3063a27dda284e42531f87e7a885e0257105f	t
6283143886518:7@s.whatsapp.net	154	\\x68638da91d214f279ed16973d3f433ce7751a6032019f998b8646dc0cf21bf6c	t
6283143886518:7@s.whatsapp.net	155	\\xa8a0bd0a883c7c2cd1202ae7bb730e39603b455b027e999e3764c10d7167057a	t
6283143886518:7@s.whatsapp.net	156	\\x800e2c1cb469793dbca8a6fc1a1cfb042b992013e8412d8ac7aaee0556300155	t
6283143886518:7@s.whatsapp.net	157	\\x4037c634c267db99f8b5d761efa5311dcf569e90fe395f953f873d3f844e4e46	t
6283143886518:7@s.whatsapp.net	158	\\x4042a21a14fb2ff84f94eb5c7eeff51d8e60558b09f563e97c05e0f6df9a3764	t
6283143886518:7@s.whatsapp.net	159	\\xc83a9fc5586eb3813d1688c7d0f9727001571c0abbf78432e2b834f664c9f957	t
6283143886518:7@s.whatsapp.net	160	\\xc02a0a984d78c8123b6e11b34b68c262c54bed7fc257739dc9c9b749e4463379	t
6283143886518:7@s.whatsapp.net	161	\\xa832e4e2082a7a63af9e25a8f15a5335d4f2916aa075491c6826adecda9abf79	t
6283143886518:7@s.whatsapp.net	162	\\x40189d67dff067a325f5482ba6dd96e25e4e1ec337d57034e2e09440b2dd2e42	t
6283143886518:7@s.whatsapp.net	163	\\x08753370dad138b947c59fd2c125809c0bb713f578abe4d03c6e1ffeb879e65c	t
6283143886518:7@s.whatsapp.net	164	\\xd8a7d449986dca698208cdc980747194ee74d3bce39214cfe124a4d74da5c55f	t
6283143886518:7@s.whatsapp.net	165	\\x6080b0ff173c26a4ad8be214bb0227bf288aec6a406c8e76a4fe2c546b140667	t
6283143886518:7@s.whatsapp.net	166	\\x28641837d6310d5e32d9b1133e63eca78fbb37c96fd0fcb38c755032c2d63f4e	t
6283143886518:7@s.whatsapp.net	167	\\x80cc32ab6b8c1319e4d2ab1e5503bf39715b2b763872c52fe9e045a2e9d75976	t
6283143886518:7@s.whatsapp.net	168	\\xf8aaa9e7ac433ea004d166518cd2cd0dc6fe8985b9aa1fccb2525eaab8e7be4d	t
6283143886518:7@s.whatsapp.net	169	\\x288a6c6a4badcbe9aebbcdbc1beccd3608d31e5acc2d1efc891f341c1b231643	t
6283143886518:7@s.whatsapp.net	170	\\x5096df53a058030a382e2312e5cf422a074ce17b87b5adb92cb99ff4a363524f	t
6283143886518:7@s.whatsapp.net	171	\\x8057bd03bfdceb27f6798b3191ad238902c92da58e0e03a41d6dabbaddff8c53	t
6283143886518:7@s.whatsapp.net	172	\\x383923d394fc77ccfc8ec8ec8146eb7674066e554cf5ddeea56469ca32744b5b	t
6283143886518:7@s.whatsapp.net	173	\\x6804a8b9c43d47f6f4cd8488ea1fa64bf8b6c409d81fd6485de21cbb8794956f	t
6283143886518:7@s.whatsapp.net	174	\\xe82d9015c881d63c7009677be6a58eae19d9c783062bc8f5628f6fa432f74150	t
6283143886518:7@s.whatsapp.net	175	\\xb0860fac03de76916d121b987395a60d7b261e22a4b008571e6073a8c4e87044	t
6283143886518:7@s.whatsapp.net	176	\\x306abeaa1bf6d1ce09e1b3c820c1bcaabf08c6fbdcad24e2da90734758f78d57	t
6283143886518:7@s.whatsapp.net	177	\\x7020cd439ed45064685225c61c9b2e1a8fe1c7bd888265d39682268e9ccc197c	t
6283143886518:7@s.whatsapp.net	178	\\x2854d34348bf901b49399195e6749d5b28d14d0e94da9816996518bd53c65d7b	t
6283143886518:7@s.whatsapp.net	179	\\x20b8fa086bcb3a5794a5cd5b4344f44363883357f97c062840c40a1f8b98b258	t
6283143886518:7@s.whatsapp.net	180	\\x88e2eee85bdff76eb1b1cb43407793814e46cd9a7dfe686cc65ebd4423213571	t
6283143886518:7@s.whatsapp.net	181	\\xd010fa16329bd78a8bc8b287107021285d8f36cbc51a4c351d4dd1275162b667	t
6283143886518:7@s.whatsapp.net	182	\\x90ac9a947c419e04d2f812adb360a58affd0c89a2079ec6b4f6e5ba265b2f058	t
6283143886518:7@s.whatsapp.net	183	\\xf8ba3442aa95dae0f8fe00d6e4617daad5830d0aa93854dd71518cc49401c94a	t
6283143886518:7@s.whatsapp.net	184	\\xa8ceb40213b0fcd8a87c6e7eb3c92c1937c65b7fca827c0599b91b91d1d15272	t
6283143886518:7@s.whatsapp.net	185	\\xc0c18b44ed2d4eb83ba96b64b790c83721edc2e9835362dc54fd78d8a652e079	t
6283143886518:7@s.whatsapp.net	186	\\x18e3db967d61ae76ed84ceb0061788fdd68f72059e0ffe82942798a0fba3f952	t
6283143886518:7@s.whatsapp.net	187	\\x0005d1e6e9fe0d018eeb055b611fa689c86232992279cc81ac1fe791dfbd6d4d	t
6283143886518:7@s.whatsapp.net	188	\\x88cd244fa2150011e933a01c04266f0029be3b4ac8ca8dc0e9d4005edd50e642	t
6283143886518:7@s.whatsapp.net	189	\\xc8da4ac0c9fb69b3fc3683d139fc9c1f6326a6649e58944f8129ec9cf24a5b6f	t
6283143886518:7@s.whatsapp.net	190	\\x2865e5a7e17704adbc8f4632d2d9660b8603196660e78dc7cd87c31a21803059	t
6283143886518:7@s.whatsapp.net	191	\\x982d8c312ebfca8801ab38cc9172a8e97024ae64685494b7d14430d5069f4a5b	t
6283143886518:7@s.whatsapp.net	192	\\x286e00ecb87169d0d9221768105a2114efa51712719e53e499659b9c24b42271	t
6283143886518:7@s.whatsapp.net	193	\\xb89beba32ec55257a8ae2f8806493585eab02d756ece2ee7a532fa2c23dbac59	t
6283143886518:7@s.whatsapp.net	194	\\xa0e3aa3f6d21a9b693161ccd8d73a1215554f45605b8f5d6ea242b90239c3a59	t
6283143886518:7@s.whatsapp.net	195	\\x3007242c0d1059a5f3557ab450a34cefb1134baf0011741fa8f663d81e4d244a	t
6283143886518:7@s.whatsapp.net	196	\\x4867bf3273849ef92d3a37cb1dc335c55473c371709d3c196603d2969bae7a45	t
6283143886518:7@s.whatsapp.net	197	\\xb02a67a67472c232e83be681f159307f90375133eb74c9b3e0a55765882dc579	t
6283143886518:7@s.whatsapp.net	198	\\x40fd8f4a181ecd1e7ecf79b688953094aaa949bdade32abaae39e672f49fc371	t
6283143886518:7@s.whatsapp.net	199	\\x707513b8cd3e99701dcfe13e7cbb9cd52bcf5705fbc105653fef7419afaa6872	t
6283143886518:7@s.whatsapp.net	200	\\xe8e7dd6c267c72ce522eef7d3019be0bd17c01d399882fe96ae53936531f0745	t
6283143886518:7@s.whatsapp.net	201	\\x28719fb138098f871d982d044e57ae72b3b2ace337a6207fa98f7fab761b9e5f	t
6283143886518:7@s.whatsapp.net	202	\\xc0de027b8e9202363396b7f9f4f3cb834ee5cf35d66f73e85da6ef5f6859e552	t
6283143886518:7@s.whatsapp.net	203	\\x30a4213a03d17a3ad98ff9668a2c4421d6f67b5e1da3f5e2ac957b71a0c85a45	t
6283143886518:7@s.whatsapp.net	204	\\xf025a76c86d9238bccebde9ad4bfca006f9ab2030c679ef0f01f4c15a4e90570	t
6283143886518:7@s.whatsapp.net	205	\\xc8b1f01db3ab540a08680187ca904b07bb3327e7861af84d9ab1f90ff258c75c	t
6283143886518:7@s.whatsapp.net	206	\\xf8797fb5014ed1b759a99bb3896bd8582d76acb2093180b37e5da7c8251b995a	t
6283143886518:7@s.whatsapp.net	207	\\x305e27658a66a2759499d0ec4b4f55538052a5c7416ae569200f5a35f105216b	t
6283143886518:7@s.whatsapp.net	208	\\x903f3d58f1a4542149aabeb3671ef82d08e5ec2631c53b3c52bfa8f22b587661	t
6283143886518:7@s.whatsapp.net	209	\\x406b13bc55c3a56ba0b4189319eba580b9a3a36b0fd6b21115765a311d32d34b	t
6283143886518:7@s.whatsapp.net	210	\\x60df69a118d8c8bed3b0666f84a94c6af22c516bfedfab90f3095657753fb05c	t
6283143886518:7@s.whatsapp.net	211	\\x3877b51e0f48bd9562671bcc0424fefe9335be11ca6ec52e9216452dea72287b	t
6283143886518:7@s.whatsapp.net	212	\\x50ea46595e0d4b57e4908b35c9d387d365699ad33ca64e19bc8d817ed7493a6c	t
6283143886518:7@s.whatsapp.net	213	\\xe052b02d92097cdfedfcc965d7839ba469c7ef43343213c32a729be89b409379	t
6283143886518:7@s.whatsapp.net	214	\\x602f98ffed3a75a90ee1e0b07645e5bbd580d8e65ce8d6b1adbb298a19b17c5a	t
6283143886518:7@s.whatsapp.net	215	\\x401b0a8917bbe1306db4caa7cc8e62ac8e15475beb00ac4973e72c58de6ac97d	t
6283143886518:7@s.whatsapp.net	216	\\xc894cd06f3205d048a55136fe37b16ba25b85f6bab327239b63599ed6e26fc7d	t
6283143886518:7@s.whatsapp.net	217	\\xf08b39cfafb09d6257e064d8ea02ac22f1ed6105c572fb5518b453fd9fb5c46a	t
6283143886518:7@s.whatsapp.net	218	\\x8095f3b9275f5aa95c186c12cb385e9dab116f3fe81b00f8c87c8b1467f33c74	t
6283143886518:7@s.whatsapp.net	219	\\x107fb8c3a7b82359620e559705ea426611c9c0a8a076d0f989b42f8fe62d5751	t
6283143886518:7@s.whatsapp.net	220	\\x50a20dc62c5ada54cf6c98f6bed456043327ac079e60b7f77f72ec17ea49995b	t
6283143886518:7@s.whatsapp.net	221	\\x88353bba47f646278417f74c08ab9ddf890dfbc293c34c88b25bd8cd6046896f	t
6283143886518:7@s.whatsapp.net	222	\\x68e2cb943a5485be7b8cb1c05984f2a36d15765db76ab376c23f62f508857855	t
6283143886518:7@s.whatsapp.net	223	\\x68a868acf5428f4b39800df54a926abb8c9aad8bea24c69195ea9de7f0b64c45	t
6283143886518:7@s.whatsapp.net	224	\\x780821385f58b7efbe1d55eedd0d67919e01abada6c7a7ca521a0e86b087bd50	t
6283143886518:7@s.whatsapp.net	225	\\xe01874fe85114fe0e75795ad8bc3bb7647f262f6d8eefb5363cbb37bd0132140	t
6283143886518:7@s.whatsapp.net	226	\\x90b392f7d5f2eb66fcef2d38984ffddd72042a98ba38e32620e02d228fb7914a	t
6283143886518:7@s.whatsapp.net	227	\\x10cb7f51f67da2a707dea90d470cf3db8827ce280a553714c8fb54cba4dad740	t
6283143886518:7@s.whatsapp.net	228	\\xf03d761303ffea58ad399e3ff1d278b098e6983041346c3f0c075a0c44712669	t
6283143886518:7@s.whatsapp.net	229	\\x78511059cf499406e8cea3c794f3ce2a1c6989ed337f0bb3ad2a63d3967a0e53	t
6283143886518:7@s.whatsapp.net	230	\\xb88223a58a6668f3a6ee60696b99f6f4b626ea48664757cd88d9dfd87a8b1276	t
6283143886518:7@s.whatsapp.net	231	\\x98926b21387f165765083d045394db980bc3415f73e3719d90485ed008fa2c56	t
6283143886518:7@s.whatsapp.net	232	\\x60b731728a71744f9db306f786de20f53f0160e48854d8b14700229314f7474c	t
6283143886518:7@s.whatsapp.net	233	\\x582f330b96ad3217e094d9973f971e3bdc58fc89cdd00bb08fcf48307c3a9942	t
6283143886518:7@s.whatsapp.net	234	\\xd0b6f196be1aacce3b292ecdf9e5e2073e97a12a198e84b0bc682b4845dff27e	t
6283143886518:7@s.whatsapp.net	235	\\xe8be49e961109437d340871d056508dfeb722418c599ba67dad6b21dfc7d6e43	t
6283143886518:7@s.whatsapp.net	236	\\xb846bcf16a5c621e183ea92ad26d2cc5ee65b118a7da61b1ba38f164eb212a4a	t
6283143886518:7@s.whatsapp.net	237	\\x80dda6642fcbec8ca22d0d09a18ebb873ad9bb90eae5e9d44668442cd2086d7d	t
6283143886518:7@s.whatsapp.net	238	\\x7000c329fdf137193afa3df1a1bddd86368b5380b2756f477b1d1bbba7b00364	t
6283143886518:7@s.whatsapp.net	239	\\xf0424c77c5f3410c12223b24a8e68c8a51d4a4726cd50b59837e22e794a1d94e	t
6283143886518:7@s.whatsapp.net	240	\\x482fff4f365aed153f3a7c59ed3d211ac2e86b87525b58950be1a5a1fbe9d970	t
6283143886518:7@s.whatsapp.net	241	\\x889162a68697747425fec0a26615854ec40364a505b26301da34b5f628ac7173	t
6283143886518:7@s.whatsapp.net	242	\\x28b2e2a193236548981eecb8448dd0cdf0fa4c2761ce3dd917977ff35a1a874a	t
6283143886518:7@s.whatsapp.net	243	\\xe032aa7ab2cde570397e9a38eadb1445a17afaf06170b3507652b30b8cdbac54	t
6283143886518:7@s.whatsapp.net	244	\\x183ad8627e5efe38f249cd6d2d7e18fb24f83ce291b01aaaf44a3df2a07e2c5b	t
6283143886518:7@s.whatsapp.net	245	\\x3865ab28a1232e260b586f9e253479096c856979d82d38d2a63e54594242d75d	t
6283143886518:7@s.whatsapp.net	246	\\x00ba8a513db52d89a07b5fa1c75dd3f34d3ebf0f66e6150b1db2fe7cb23e216e	t
6283143886518:7@s.whatsapp.net	247	\\x90de499f400fa99cecf494c265aadcb2b9a291e970e28671d2950e6f0d97f042	t
6283143886518:7@s.whatsapp.net	248	\\x70b82257d3126a90ce29961b29f60ada9dd88f1094b6fd71764f2bfa672c724f	t
6283143886518:7@s.whatsapp.net	249	\\x78cbfca5a056252a52421ef1924b8d11606731f114755c1a3b333f79c5b46b6f	t
6283143886518:7@s.whatsapp.net	250	\\x6040a43e3342724882a3393a06d1b612c9fe0146d9dfa23aa2316c1bca4d745d	t
6283143886518:7@s.whatsapp.net	251	\\xd88ce9374447eb6d6b9f608ccfa45f60098d5f1569549f917c36a9b6c407fe7d	t
6283143886518:7@s.whatsapp.net	252	\\x683ada402a3a56a83963da7cd900747db0d8857667f5680137ffe78f13ce277d	t
6283143886518:7@s.whatsapp.net	253	\\xc0d4913a012eed70b0fe63772894668b36b043bcba0439ad9627f9694c92ee6f	t
6283143886518:7@s.whatsapp.net	254	\\x10e1665e387f46e67d3d0cd65d8f2c2915a50326273096ef1038e045a2704b67	t
6283143886518:7@s.whatsapp.net	255	\\xe885167a5a5d7dea6c65b8a59876e957397208f6ef06b8c31ad7727bc6570973	t
6283143886518:7@s.whatsapp.net	256	\\x1892c63b466c363e09054a71c10ae1dfb53872106d329e1c62881d3f4ff6555b	t
6283143886518:7@s.whatsapp.net	257	\\x884050b3e0b9adc7d0263487ecf39e12c80e50ab47027d1805348c26f2763a69	t
6283143886518:7@s.whatsapp.net	258	\\xf8f4a9df061f8c975737b759c19f70c07a85b8f1ca8f34eb47cfd17ff60a2d45	t
6283143886518:7@s.whatsapp.net	259	\\xa02299978eef8d7f43043f69cb1f7574c54794b57f8c81f4a0a45ce9e3b78e6a	t
6283143886518:7@s.whatsapp.net	260	\\x7814be41586fd2ae44fa29d1b52c8c17c6a4ac75fa4de3ac813add6f62bccf44	t
6283143886518:7@s.whatsapp.net	261	\\xe0807499449e7fc04ea7f6aa09eec42cffa0bd5093a548eb416a5c9e8a309d48	t
6283143886518:7@s.whatsapp.net	262	\\x0065bae5d3ad4da6ee46878648daa7fde74f995a3906416d1d4c3b11963fb274	t
6283143886518:7@s.whatsapp.net	263	\\xd820c02df72999d6e2c4b6db947c957fc63f22ddd7f1cb485ce4166df4db7b7d	t
6283143886518:7@s.whatsapp.net	264	\\x50fd882f3b44ea31a861a1566fd2b5ab3248c50e5150394877cdbe87ecdc4a6c	t
6283143886518:7@s.whatsapp.net	265	\\xe8c3da6f859da81e51f81b993c7b28fc252484bb0e45b9cdb064d81bdf3dff79	t
6283143886518:7@s.whatsapp.net	266	\\x109c0443b0f6c479eacf965ddb4bc4990ab0d7cdaecb6492646c95e6f3233064	t
6283143886518:7@s.whatsapp.net	267	\\x38109ffee79e3a18258833b996661598b07203eb6882907e6bc8fb40d1007b5e	t
6283143886518:7@s.whatsapp.net	268	\\xf05bbe0c1e2924d6667146f22c6f14e500359599d7aa81988be52bd84dbba573	t
6283143886518:7@s.whatsapp.net	269	\\xf0d6378a2e29ad5dbf9d6af9882a867bd093d2f0892ff4c6adbc6992c2a9d94d	t
6283143886518:7@s.whatsapp.net	270	\\x58e509775227ddf015123a52beb8987d4b7534303b787d256820f7f61f9af653	t
6283143886518:7@s.whatsapp.net	271	\\x483574ca6f16ab95d9be95c6c24849e1ad3c3ead7900b7602612245e707a735e	t
6283143886518:7@s.whatsapp.net	272	\\x8818cc7b7995be90f4a845cab63b07a095ebd33b0707fad1aa2715a0d3cdbb63	t
6283143886518:7@s.whatsapp.net	273	\\x300b8436f9c78531e9732e09814af277603fe5fecbbe51ef010baf66fc49c549	t
6283143886518:7@s.whatsapp.net	274	\\xa078dcc2027cf917bd8b5b8a0cee0064f20443280000a87d42224d7884c8bc71	t
6283143886518:7@s.whatsapp.net	275	\\xd09a1c718c7b97e5347a9463c99b3a852fff505297bac6840e401af592c23046	t
6283143886518:7@s.whatsapp.net	276	\\x70a4abc45d37250cf16900cb4150afcb61ee4072a3545359950bc24bb8220151	t
6283143886518:7@s.whatsapp.net	277	\\xc806e3c2bbfe7720a4d3d1fe0d1b4efe0f493783484175c95466a728b59a1276	t
6283143886518:7@s.whatsapp.net	278	\\x304ced71ed1db6308cc5d611051bee45252fccb9becf2176e9018db4a1cf9b76	t
6283143886518:7@s.whatsapp.net	279	\\x2052065e9e4af952d672b7242732560b68e283b56e1af10b240aad1b73e74757	t
6283143886518:7@s.whatsapp.net	280	\\xd88252a8f2bad4b865c41eac7242e7ed0276047eb1de4cc8fbf7f1926a48127a	t
6283143886518:7@s.whatsapp.net	281	\\x488d1f92fb841cc41578158b73d594ca360a8d7f147e1e9eb77551e64b743353	t
6283143886518:7@s.whatsapp.net	282	\\x30693ea820b4aa21599465c9936d928b19d019b3c89f4a48ad6250298ffda148	t
6283143886518:7@s.whatsapp.net	283	\\x301f7d4798a345da3689caedd1aa8fa20525c3c2328f15f5a1f06f0bbbef9170	t
6283143886518:7@s.whatsapp.net	284	\\x90341774c8b8695f7e420d499fe79bb6021375ab22a5002be81689beadd5fc64	t
6283143886518:7@s.whatsapp.net	285	\\xa83953ba8be9fa07232a5c3c3f44710157f55a05e60bd9d51d28b4c29d419774	t
6283143886518:7@s.whatsapp.net	286	\\x50428f169f271da7bc04dccfa4a133c198fe59dbffe547c338049815dcd1f46d	t
6283143886518:7@s.whatsapp.net	287	\\x90883bdcff3ec046c0f466f45015cb683180fbb7a81e4c6429d4038856a71a61	t
6283143886518:7@s.whatsapp.net	288	\\xd0cb6fd92393cb3724681fa25a0574b9a468a67d18e9b39d185cf8660b2ca04d	t
6283143886518:7@s.whatsapp.net	289	\\x204f6f11a1eb7e0dcb437c0058632e8120f6161519e401147c1f431bf326f252	t
6283143886518:7@s.whatsapp.net	290	\\x00e0efceb462f3a6bf7a10becd4f38ac493c14619385cae395bdfcc178743e69	t
6283143886518:7@s.whatsapp.net	291	\\x18bbb9f5e9cc629a8c4d7b070720c4d6329a29ac330da41e9cb40a655fd3404d	t
6283143886518:7@s.whatsapp.net	292	\\xe037d536b1387e92dec122fb15d8ddcbf44a05c7fb723d3ebb9c20b1a7801353	t
6283143886518:7@s.whatsapp.net	293	\\x60374e3a07132e6801951143629cd0fddea4fdfdbbcbbead92299b918c7fb55b	t
6283143886518:7@s.whatsapp.net	294	\\x185c02534b3086b1c1c927bb188258b8082ae548f0b739c0102f8c76e5b4bf7a	t
6283143886518:7@s.whatsapp.net	295	\\x4842aa100d7d895ce5ca2c549a324459d41e585feefa06617768295d150c5860	t
6283143886518:7@s.whatsapp.net	296	\\x30ab8608308ed4561950287142a33cd7ca0e3818e8f922735c7533bda00b905f	t
6283143886518:7@s.whatsapp.net	297	\\x2003b8d808137910adc192427b34a3038dbb29c411bc0d68169232bab560c84c	t
6283143886518:7@s.whatsapp.net	298	\\xe8409651279fb52bb3a5a6c8c65b8defaf2f821945c049f9f4c1fb0089a81048	t
6283143886518:7@s.whatsapp.net	299	\\x90077be9ab73452c7c5a8e082b201d06e90517664af9e2ca4bbf4b84f818a462	t
6283143886518:7@s.whatsapp.net	300	\\x00e418e2884214e57e1c57e8ea6f03aa24994533720eece13c0f515a6105e36c	t
6283143886518:7@s.whatsapp.net	301	\\x783dabfdeeee7eb84c4ed7d16a3087487f93cb048a2cae8f211c39c7f0ee6652	t
6283143886518:7@s.whatsapp.net	302	\\x70b30f65cd26e11c4f36b102d189b2613504416ea66e128fa303adf6c201a943	t
6283143886518:7@s.whatsapp.net	303	\\x90bdc1987c8a9aadc26278ca059250511b8fe26f4269fe6b327e2e6d34f51652	t
6283143886518:7@s.whatsapp.net	304	\\x28f6e56ec7d15612d1ef6ec4b466a792217e906ee352773cee79f5c128318778	t
6283143886518:7@s.whatsapp.net	305	\\xc8871e1b801cd33ec746795a78393028b891746d7f27a24b8d08bef22545e751	t
6283143886518:7@s.whatsapp.net	306	\\xf08ade18dae4f706bbd650bffcea1817967edf9861a0116de387b1018d8f3343	t
6283143886518:7@s.whatsapp.net	307	\\x40e66eefed73801beefab90a575841c5498c66363d5fb5cf4b37e970cc90ac72	t
6283143886518:7@s.whatsapp.net	308	\\xb84cc37763e9f500aaaf8d5bf948d520af5841e7d9a4dab5223cd94e08254f6a	t
6283143886518:7@s.whatsapp.net	309	\\x5868a2cc9c7b8fefc65718d52acef2f2c1034e8b16a24627192a730b28f4ac4b	t
6283143886518:7@s.whatsapp.net	310	\\xa0d4a19c6f6b28d3f6c495a7449c94a4081958b4f3a292a2b3b21b8024717d7f	t
6283143886518:7@s.whatsapp.net	311	\\x48ac98f0e716cf2e58aa74dccba3cbb043200ada3569a42a1ac3dbb29003025b	t
6283143886518:7@s.whatsapp.net	312	\\x580b80a76d72faf5bcdb600f12b9c531ac8c4e73635ac53d5888793c809c657b	t
6283143886518:7@s.whatsapp.net	313	\\x5057e5650e3ce936b49bf9f8e9166bfed5a6067496bd2fd0b19afb7e0789a65c	t
6283143886518:7@s.whatsapp.net	314	\\xb0d752bcf08040e5f2a1534bb991625759427dd32a7539d56a4f826f90c87c62	t
6283143886518:7@s.whatsapp.net	315	\\xf8e54f6a0874c4d31260cabcad7221f14869654bf498bb5cf5c85a46f5619360	t
6283143886518:7@s.whatsapp.net	316	\\x6039368b863d603aeb04f0c77dba8fb2bae00e86f87eabe231d279a82b88d458	t
6283143886518:7@s.whatsapp.net	317	\\xd00d5ddb86280029e29fb2451a593b683a8efa80653ebf6e605f9b5095d09164	t
6283143886518:7@s.whatsapp.net	318	\\x508de75d78180da01914b4d3447039c92094c725b19ff13ed0ddfdd36b2e4f72	t
6283143886518:7@s.whatsapp.net	319	\\xa8a8680936e623981d4b1735cf7a2a13776197fa574e2c2403b8a2f4ced8477d	t
6283143886518:7@s.whatsapp.net	320	\\x98d8eb97fad5b9ef525bb7e8b7da6f4d2b6990bd78630ea162c931a03bef865e	t
6283143886518:7@s.whatsapp.net	321	\\x2077682870a3a5ccd801c997b9db8673548a9156f3fe8c3fca8a0fb5d5d9197e	t
6283143886518:7@s.whatsapp.net	322	\\xe812cffd8a8dfe16d7560a5c64ec06a601d387016681c4700781a3e54b023066	t
6283143886518:7@s.whatsapp.net	323	\\x382dec00ec276e9c2cdb40899e6d1f7f94349d35bb6842ffbfd4ba05e709366d	t
6283143886518:7@s.whatsapp.net	324	\\xe0eb43f184643325b56e63e9aac066664d0fda86b7b8a2bebcc2399c4d272643	t
6283143886518:7@s.whatsapp.net	325	\\x909c13f68a85f2ed60f89315fc6161ba52a35d03a9705bf8d0dc469efde19658	t
6283143886518:7@s.whatsapp.net	326	\\xd008ce803bdffe847e8a97c6d1cfa0d0fb0218d13d158eac92135f5d62b9a77d	t
6283143886518:7@s.whatsapp.net	327	\\x905afd73e7fc26d6a06ec22724751a3b3a0e8ad6c849df5a56818d2e52c6107e	t
6283143886518:7@s.whatsapp.net	328	\\x98cb040deef0bdd6ccd1848b313dde60d9108bf6de2e9d1b71cb4e1df7fc635d	t
6283143886518:7@s.whatsapp.net	329	\\x685712b325950c2f9a2a9295ced8b53549f42b98eab2450538c9ee5442247266	t
6283143886518:7@s.whatsapp.net	330	\\x4087321d46ad8229e4db6571d4874da74c7af33f748668f6598e12062afddb5f	t
6283143886518:7@s.whatsapp.net	331	\\x8000ecfcd9946f3d9c161369a94583efbf012c3072f89811ba8349ebbe19b65b	t
6283143886518:7@s.whatsapp.net	332	\\x88ff949d05cc5a1f6b91fb7c58434867f50ce7901d24429b1217ec125c407a46	t
6283143886518:7@s.whatsapp.net	333	\\x383424e6a5bf0fecc352be5bff9f7457805f25005ace9fcb8a55c864ef083459	t
6283143886518:7@s.whatsapp.net	334	\\x3826521e37fc99423b5ddeedf0280e4a032873aeecf3cb2d578207e7dca59b6b	t
6283143886518:7@s.whatsapp.net	335	\\x30fe703783447c863536aa6ae06ab8ad49dc0a7f154e091c030627d0d1a08360	t
6283143886518:7@s.whatsapp.net	336	\\xb0b832670739640f58477af4eaf49e97322a26e791e5cacfc9facba31a6ad948	t
6283143886518:7@s.whatsapp.net	337	\\x8892b198576d6e01a5eca67e2ffc1288092734d30bb9ef75d84583e548d65b4f	t
6283143886518:7@s.whatsapp.net	338	\\x80bd09ac460b77da8acc038b76064ecc5c1fc836735fcf783d1352db7bff7479	t
6283143886518:7@s.whatsapp.net	339	\\x483680e51de0a33e9778d4a1c1c7d9606c3b65b9560eff6a7624820157c8a37e	t
6283143886518:7@s.whatsapp.net	340	\\x703ca99184a4a06ccafdc37a22290a0a78f50fae798defc90919130b68a2dc4f	t
6283143886518:7@s.whatsapp.net	341	\\x3894c9d0be5c8b0f5b9ab9a84187222d1b798d4f2cf6775be8e101a65fa7875f	t
6283143886518:7@s.whatsapp.net	342	\\x50caf13cbae20eca108501808317a860924da54c6d84f430010f31f662583c64	t
6283143886518:7@s.whatsapp.net	343	\\x986e7029bd0f9e023c3e20f487d1e97b2277d132f020b32ee4ce4e746c502465	t
6283143886518:7@s.whatsapp.net	344	\\x982e9c7ad57cf7ae0de8078d1273350f91469d1321c242b7aff3f5fc97d58466	t
6283143886518:7@s.whatsapp.net	345	\\x005ff923ad9772766a34b94ebdec2f9655b16000b4c8d9270c9090a2f3e4f87b	t
6283143886518:7@s.whatsapp.net	346	\\xe854faff6b5bb801db5c5351d039712a998e0ad1544146b9f36c0795625a4576	t
6283143886518:7@s.whatsapp.net	347	\\x08eed8d7825f722c4700103c42cd3ad2e06c44f3fda68525ad23ae254199826e	t
6283143886518:7@s.whatsapp.net	348	\\x58a4be29df21317252287abbc781e50d8247f05b01b489fee27b30e899873e56	t
6283143886518:7@s.whatsapp.net	349	\\xb0befc2f75177ec012975ac425a09b61aa9215b8bb08fc9e727cc78a7d01454e	t
6283143886518:7@s.whatsapp.net	350	\\x08dd6df98280649cc394163f457c2bd15b8c28c1e7f646f7bf45afabb417c661	t
6283143886518:7@s.whatsapp.net	351	\\x78881a6317b86adab4c1232fdf4e48cac98fe3af8eeee4a2de485686ab7df06b	t
6283143886518:7@s.whatsapp.net	352	\\x38c223f711405a0c463be1db77b1b877289aed3d2dfb43f00f7a76ae329f5b4d	t
6283143886518:7@s.whatsapp.net	353	\\x90673122442c4f256241614f011ca289e2304079a0da05ab08a0d4a420988547	t
6283143886518:7@s.whatsapp.net	354	\\x1898cce69f31b1e32b04dd13b296ad7e904e518a7db4754a75176e59203edf5d	t
6283143886518:7@s.whatsapp.net	355	\\x2031fc414a6f785c783ddb04ce6a466bbaa8bb05fd1754929ab12a11020b9255	t
6283143886518:7@s.whatsapp.net	356	\\x6808dbaeaad59da8d69ecb57e7b0f79badb3387fe4c37a4a4a679f40cf339c48	t
6283143886518:7@s.whatsapp.net	357	\\x083227e322575b6cd935bbcf11ee0b4319a3d4d1c2659bf0fe4d90a4d57cfc52	t
6283143886518:7@s.whatsapp.net	358	\\x908df36ecbb062dd6f55d72b30f7a00c3b3bd5256baea21830a2072485dcd440	t
6283143886518:7@s.whatsapp.net	359	\\x1851e348cee10c8e550d1af3c48a15fa69fcf050ff9296f8141d0933a9359e7a	t
6283143886518:7@s.whatsapp.net	360	\\xd00d0a9f8c7fbdcf8f0193ab88158b1ec3f9eeab47cfe8fda6a0fa25cad9617b	t
6283143886518:7@s.whatsapp.net	361	\\x181ae87296935a5a5e7ec3204bfc60ee925376246612b0f23f336fc610bf0740	t
6283143886518:7@s.whatsapp.net	362	\\x00a269b8f00e1419c2ff11d50e477ce2922ff1c9dd0186d70cc4f5047356ea68	t
6283143886518:7@s.whatsapp.net	363	\\xb0268bc9832bcc2096bbc89a1724f84635f03fa24007db61b66f15a2bb351777	t
6283143886518:7@s.whatsapp.net	364	\\x78245fad7f964bfb07798e0cc8be8e3632572114f5748286ab02781f56da074c	t
6283143886518:7@s.whatsapp.net	365	\\xe8afebf42459de2404d990f5e199b6952e00a3268a75b5c14975c11b826fa860	t
6283143886518:7@s.whatsapp.net	366	\\x10801db05aaced9854fe3898bc5654a0b894349b6ee4de39c91422385f87bb59	t
6283143886518:7@s.whatsapp.net	367	\\x00523c0477bdbcd8822fb516584c43780549312f8623b24d1555a240a90b6951	t
6283143886518:7@s.whatsapp.net	368	\\xe01d66b6d2dad536584a013f8a2961acfe711838111fc8f65cb7b068bd3b1e43	t
6283143886518:7@s.whatsapp.net	369	\\x90b6e141ba0e0cedf50f50d93c6b86cf85e5cdd7546d2acb4c42308abd23884f	t
6283143886518:7@s.whatsapp.net	370	\\xa83c48845c3617c69fa24fff1ae986f35643ab3ac8f155dba891edd45a3ab068	t
6283143886518:7@s.whatsapp.net	371	\\x602c7aa66f1243acefa3f03fe12d7bcfdb050916489b169b84d146e256bb0943	t
6283143886518:7@s.whatsapp.net	372	\\x6870674aea016e4d39f257487754e7c129dbd93cb88cd7177c034d1c5b6c9543	t
6283143886518:7@s.whatsapp.net	373	\\xc82a0ed9cf32789374e63466848171971ee94dfb4d03959c5e6c26a7f233aa66	t
6283143886518:7@s.whatsapp.net	374	\\x5830f29d50412c06b018fed8ad8b03698e5e78e478c67dd51b8fc3a5872fe242	t
6283143886518:7@s.whatsapp.net	375	\\x50605abf72aa3cf36b03586ff7d3a11dfd9bc5937aac392d40aa7c1b9ee6844b	t
6283143886518:7@s.whatsapp.net	376	\\x60da81938682db23b7bb299e57663f6d9cccf0770a5954b59ad23d242960e042	t
6283143886518:7@s.whatsapp.net	377	\\x78bbe453f136237efd785876cccea5af17f06afe73f5f506ecd068e0415bff47	t
6283143886518:7@s.whatsapp.net	378	\\x406fa3fd419c1415ae696c21975887b8dcf32dc561bd9b2960c2034b992d9b69	t
6283143886518:7@s.whatsapp.net	379	\\x60a1fc463a5c26e851339be446246b70c6bd1d64a228321a78bbaed2cbca325e	t
6283143886518:7@s.whatsapp.net	380	\\x50665857abf21809e93231b4614567c622ac4361993ae11c4f0aacce1bb2f97b	t
6283143886518:7@s.whatsapp.net	381	\\x5884f391a15d7fd7138cb4abac589e19f4ff2b1e254f8786aeba9ed16dabc24b	t
6283143886518:7@s.whatsapp.net	382	\\xf8766c3ab406fe183efc513d6866f62a8c0a47f1e43fd292d7bcd69f9314884e	t
6283143886518:7@s.whatsapp.net	383	\\x288407ba52cb3eba94b73e79c1f5b88c4a1448669d94609782ec85be5af01659	t
6283143886518:7@s.whatsapp.net	384	\\xe0b51f18263a3be684a9342439cc6526c4aa7c006cc5d075e1a320eb18d6da57	t
6283143886518:7@s.whatsapp.net	385	\\xa8b1150c9f1b44d0f088dac88a8c1223def68d4b3db3559d35a52b54fee06179	t
6283143886518:7@s.whatsapp.net	386	\\x98ab63e852c7cea035a4148bf813e2b0f6ae2a45648181d71f68d57787642f6d	t
6283143886518:7@s.whatsapp.net	387	\\x4025e6c4dffecd1adb3ecf4bb861d9b3c7fc14a3049265e3d7c88ad81d888e42	t
6283143886518:7@s.whatsapp.net	388	\\x8890a470e392d2d4683fc439e409a675ed8f6e217c8b879cd31da204b72bee7d	t
6283143886518:7@s.whatsapp.net	389	\\xc0a6a34ec37d83fcbc440c01c4bbeb21051bb7cb000fb8ada0b37561f07b8645	t
6283143886518:7@s.whatsapp.net	390	\\x805b6c90aaa962f9d57b33936a7448af297123a2b9d3869c3752ed548602ad52	t
6283143886518:7@s.whatsapp.net	391	\\x184ab2adad41c6d8d57f3d257d777b8d3d55024007579e5c769a43573ae3a957	t
6283143886518:7@s.whatsapp.net	392	\\xf0885111ed7d7263ff9de3e44cfe0f6134b87b4cbc3bdf834b81929742b5f970	t
6283143886518:7@s.whatsapp.net	393	\\xd8a822b49ec2eae31e398912bb7304d0229ffb5db753b5ad027bd841c9d3ab60	t
6283143886518:7@s.whatsapp.net	394	\\x18e7fdfb1fa9b9f73508095ef92d6c5b9b8fafb2d9cd10e243a58b5db3bf0270	t
6283143886518:7@s.whatsapp.net	395	\\xe863eee84c3cae2a5ab8aa38767449c656a3a39c133bf3a3fe807f66518dd16d	t
6283143886518:7@s.whatsapp.net	396	\\xa0dfeaf99ee4e4e0bb1976d527afbbee73d386074fb7b7840bc9e70cd94db253	t
6283143886518:7@s.whatsapp.net	397	\\x481e313bab1b1ef44a00db458bae1bba2b444c4ab971d6d8bb082689cff8135d	t
6283143886518:7@s.whatsapp.net	398	\\xc0d447dc23f431dff37e59d6ab5275868f98d78650d3465ece6f344161523864	t
6283143886518:7@s.whatsapp.net	399	\\xc0ed96e141b3a956d16a0fbbe3be628f87192e60b7ad5d68d3c8546aa552bc5d	t
6283143886518:7@s.whatsapp.net	400	\\x3045b5757ad5595f5927ea7570de87f7ada5d9010754379c79b30a91c5ecb54a	t
6283143886518:7@s.whatsapp.net	401	\\xd066b6936f4899970355fc9b2d1e6466102bda20714ece8f0b46533d3d04504f	t
6283143886518:7@s.whatsapp.net	402	\\x70f6b9dc1e793de1dd3259a7a5b3fcd283a817a63d7a0a07f0b7cbee4b23ac7d	t
6283143886518:7@s.whatsapp.net	403	\\xe0ae23b1907ba8b222089d4b0d429de5345e1f4b79b13122a6e6aabacc42c259	t
6283143886518:7@s.whatsapp.net	404	\\xd038a2676da4f41ec8ec20194dc1350faa6da7d3841f10907ff104254a75cf7a	t
6283143886518:7@s.whatsapp.net	405	\\xb841f60d9c251cd72801d33a7947ee534a888d97ba7148ad74de1ff9a6becd54	t
6283143886518:7@s.whatsapp.net	406	\\x40a4dcb3725ec5c4c3ee81169b46148729a6ef7b0d0b012b8ef1159fcef3dc7c	t
6283143886518:7@s.whatsapp.net	407	\\x303bdae4e958349a0070db952d5473282fb025039409b1f3527de97b212db352	t
6283143886518:7@s.whatsapp.net	408	\\xe0738b9b539b4206b088e1876e217bc1acf592fcdf82dfe1fd15b55a6f772540	t
6283143886518:7@s.whatsapp.net	409	\\x28426c36de14257475f5ff449a3276c920f4afa353239e8d77dfebf3cdb9075c	t
6283143886518:7@s.whatsapp.net	410	\\x80e221ad06d43b6518e7de539de8341f1f8d6d308d164c9aa53ae362521fb849	t
6283143886518:7@s.whatsapp.net	411	\\xa01fba93306aaf6d3847f13d0712bce20967e46f87378175d2b8b01403b23f51	t
6283143886518:7@s.whatsapp.net	412	\\x10d5c2140652f925d49a8518c72faced9238509490bbaa66775ce586a5a68470	t
6283143886518:7@s.whatsapp.net	413	\\x1050b8586817f19aa883ac3c6032cc19c2f3ea3a6eb1ef5823f502bc89b9f848	t
6283143886518:7@s.whatsapp.net	414	\\xe8bcfe943e4cb78fc8c21ae04cfda1079df1df0510658d48fcd7a739b536cc7b	t
6283143886518:7@s.whatsapp.net	415	\\x9065a5f3e7d536959a75d549c01af0743bd33731dc6d914e58b71a716d451452	t
6283143886518:7@s.whatsapp.net	416	\\x20ba292c8ec8a25e717321d0851615b64ad1396c98b29ba1cc7605fad420867f	t
6283143886518:7@s.whatsapp.net	417	\\xe0e77e5bc47e96303f303a5363b164e10b63d40e324f2cafe4c8741c8eb4605c	t
6283143886518:7@s.whatsapp.net	418	\\x8878e26f4a9ab8d4e6d7dd7ef8855654c6c254360237ce2eff59c4e0e5361f61	t
6283143886518:7@s.whatsapp.net	419	\\xf0517fe85baa1ed77bab968978c602238c0c0c091999ac7055184c15a019434e	t
6283143886518:7@s.whatsapp.net	420	\\x289d72cb537dbe9210e48ddf05e88fc45f8dfbf3cced4f0b30330c1d5cb05f59	t
6283143886518:7@s.whatsapp.net	421	\\xd8616125f153cba72d9ccaba99a957f0fb0363ee59048d5dcf7feb8388661560	t
6283143886518:7@s.whatsapp.net	422	\\x088978a97ad167c07a420e9376551e3279ff377c11e21118264211cd8808485e	t
6283143886518:7@s.whatsapp.net	423	\\x48faf916f821b06328c5b904b5f2ac7a4c1c643df3bd0ab74a7a8c5e838c7256	t
6283143886518:7@s.whatsapp.net	424	\\xe0ad4076b72850e49743eab8f7c80c2de4c82ffd23e2faac8d97b4c06b86a148	t
6283143886518:7@s.whatsapp.net	425	\\xd8415c80b10e5cc573f59dd2d9b60b94ce4aa485072ae9712861cc9ba6d93a53	t
6283143886518:7@s.whatsapp.net	426	\\x18f6b5a4d29397c189d92e1603a3aa07d1329325d0fbffd32c881aba8301a244	t
6283143886518:7@s.whatsapp.net	427	\\xf8ded39bcd5f0b67f7f3ec8e36bcae2c13cf67325183655f3167181627caa770	t
6283143886518:7@s.whatsapp.net	428	\\xd8ebf785dcd1c2eb73c0f289c24fb8cf4662a1d23fea61832d27346888fc3459	t
6283143886518:7@s.whatsapp.net	429	\\x182f5b1af4cc32d972e449233d3ff27f61c0b4aa43b0760269e61a175e398959	t
6283143886518:7@s.whatsapp.net	430	\\x701c2642d5c086d1efbe6a4ec74f8b5facd83a5cb611ea8ca77743e1e0741240	t
6283143886518:7@s.whatsapp.net	431	\\x48c4a1597cea4820ee3a0b4aa2b4a18c624d0a14dd7c94965b28714b3b5b1466	t
6283143886518:7@s.whatsapp.net	432	\\x7832cdf346eaf7b178c9fc698bcb1cc1e8ca9dd79034f8b4c968e236b5306858	t
6283143886518:7@s.whatsapp.net	433	\\x2076eee497ef15da621aba18aa9e1caca90c8bda20aebad0f02512ef0b7bd752	t
6283143886518:7@s.whatsapp.net	434	\\x40c4a069ad3e58aea158eebaa334671b2a89614dab1f6cf4b1cd432938d15661	t
6283143886518:7@s.whatsapp.net	435	\\xe0336504c4924ac72d99034574ca73e53d57cef73867a883e2d732cca7421571	t
6283143886518:7@s.whatsapp.net	436	\\x907d043122c2c070e2582374f07888934a61d0049893b9a2a593e1a3c0ab6b56	t
6283143886518:7@s.whatsapp.net	437	\\x48907c59c7a25f7201ec89be83d06c249961ab3e41181deeb87e22ca4a773d72	t
6283143886518:7@s.whatsapp.net	438	\\x4000b522250ea26bdbbb3337ff55142c439e48fb1fac3de095c82e83b95a7f47	t
6283143886518:7@s.whatsapp.net	439	\\xb027b5b97d811e2c9916208c1e3f9579d7c69dc1a23273a5a0b10fe1e0c20f66	t
6283143886518:7@s.whatsapp.net	440	\\x084d898388ad78fce8ef8eb55974ad50fdaa00f0b1c5703aa2ee73a8020a4578	t
6283143886518:7@s.whatsapp.net	441	\\x78d75c103cb7f80c46d02cdf59ef5f06566803fbd7f5b112476bf4236d8f026d	t
6283143886518:7@s.whatsapp.net	442	\\xd0931d407526e2a83ab4069cc6c7b382f761cb126f4f46203c9c9cd658f29865	t
6283143886518:7@s.whatsapp.net	443	\\x6832d952400e9f0a8697f57962638ecbadfed84f62da2fe4a8c927405a3c4d45	t
6283143886518:7@s.whatsapp.net	444	\\x982d512e4d4b195c11154f574d2e1bb881c55f52e17fe8c9a4cb875c4874ce49	t
6283143886518:7@s.whatsapp.net	445	\\x60ee285091048f58d27045cf9e0810527cbf2e48cfdc72d29749d95d2cd6bf78	t
6283143886518:7@s.whatsapp.net	446	\\xa0741332d3270ae8663afaac534c6163555ac7ca6715508614047e006c7a996e	t
6283143886518:7@s.whatsapp.net	447	\\x38bcd1a7e6a927c8077a16ae5d543b24dcebd63687b04e4dbe47b8f73619d378	t
6283143886518:7@s.whatsapp.net	448	\\x98b73348021ef1d5bf501abd6b26c023b1253ceeea5998c43f13c9a0658d977c	t
6283143886518:7@s.whatsapp.net	449	\\x588247544b77fd3f4a32be930660919b49a7fcdf2ca1d5d864b338164e507f7a	t
6283143886518:7@s.whatsapp.net	450	\\x08e0629684b58454bd9ff984fe37ed3488d06e98032b8ea2855a67a68b8d2f40	t
6283143886518:7@s.whatsapp.net	451	\\x403bf730448f2894c633cd06e7e1d5a9971c0f49be276818528a957d1bb77a41	t
6283143886518:7@s.whatsapp.net	452	\\x18a48003fb664c95ce3db1b5f01f09bc39938c0093153f1ab17c4d07f1efa55e	t
6283143886518:7@s.whatsapp.net	453	\\x208c25990190785aefd25b3525ea4cf81109f440386db8f80bd61379df435d63	t
6283143886518:7@s.whatsapp.net	454	\\xd03f69112cc2f86659659dba13e4c124ac210058288146e71530b9ef60fcfe6c	t
6283143886518:7@s.whatsapp.net	455	\\x70f9b6ab7d95bab2e27b1acbecc788552af7cf166ceba804d60fd27e71dfb053	t
6283143886518:7@s.whatsapp.net	456	\\x105293e48ef83f2b2eb08cd93cbd8ca375129ab655be0044ce48127ae60f6363	t
6283143886518:7@s.whatsapp.net	457	\\x38d18eb4d5ba6b56c09a0ba748c9366601226fa9481263197afe69bd92e19a7e	t
6283143886518:7@s.whatsapp.net	458	\\xf0b781530e556c45b7936a15b2c22d137c0b32922806d1191deaa829e81c656a	t
6283143886518:7@s.whatsapp.net	459	\\xe8e20addb064776489e136b2300939c540b56a174bd849ce6b59f624c5a8e87c	t
6283143886518:7@s.whatsapp.net	460	\\xd05f56b5b2ff56f57dd70512eb2b61dfe09c960e7bc6e3dbe698bf056e1c407d	t
6283143886518:7@s.whatsapp.net	461	\\x103c62a0f5ceafa8b8e1cde8d6acdbb003bf86ff0fef490e30fe00ef4f55776a	t
6283143886518:7@s.whatsapp.net	462	\\x6873728a274010057386ac978201794c7885d87f2240d5383d57fe56d535fc58	t
6283143886518:7@s.whatsapp.net	463	\\x90f713fe4f3cee3f55a0a3f1e363eaf1c94bbe0f17031c5b143f0584d9147052	t
6283143886518:7@s.whatsapp.net	464	\\xb09bcff9d538b6efdce5d891bc3781449cb06f110c248ba377537a0cac3bcb4e	t
6283143886518:7@s.whatsapp.net	465	\\x48628d4dae20e4e51e01d6986a1796ea997f9e89733e3e14f84978c96335f368	t
6283143886518:7@s.whatsapp.net	466	\\x30d257d018b573816f2c39da9b507b60ce6acf9950b8709881ff0ea24e8ab37c	t
6283143886518:7@s.whatsapp.net	467	\\x50ac08069f41dc6ddff7ca2cb899df6bbc6d0ec4b6fa3641e84d3e46e42b6468	t
6283143886518:7@s.whatsapp.net	468	\\x10498637377792db613f02814f69d1e2457eee65440b21602693fe7ec302007a	t
6283143886518:7@s.whatsapp.net	469	\\x90d526cfc2a35a8f0107c4fbd55d66ad05d4e9b8afcc087a732360fcd280074d	t
6283143886518:7@s.whatsapp.net	470	\\x404ea8e6d413b60eb10fb9f7704d5da165452f7e8c67f6b4447e60b748de2e4b	t
6283143886518:7@s.whatsapp.net	471	\\xa84504d1fdcdc3fc8e0830e5afd7070cbd9884e0ce5af6b12bc745321528897c	t
6283143886518:7@s.whatsapp.net	472	\\xd0d1c5809e4d8cc4ece386c784274d60786086d5ac112dbdc7e00af403a71041	t
6283143886518:7@s.whatsapp.net	473	\\x88366066019e3d246b9326aead368717a642dec1579e86e7254693cfb2d71d77	t
6283143886518:7@s.whatsapp.net	474	\\x682a977ce654fccecb852e16d1c1ea2032443ec3e2a5d4df265ed3592d8df645	t
6283143886518:7@s.whatsapp.net	475	\\x30377182ccd5b7e5d321b9affbbfcfa3758197ba9947e3578d15cbda78b4766c	t
6283143886518:7@s.whatsapp.net	476	\\x10095e69ea1d0401b86bd5b5cb89dea14acebaf78848ddea91107ae45a147f60	t
6283143886518:7@s.whatsapp.net	477	\\xf8e5da65dbe85b998891f7dc57daebe5238d564133fb4bb4bcaf69133a294856	t
6283143886518:7@s.whatsapp.net	478	\\xb8de80b18f65625bf5af2b47093b7e89a5818d84a9343ab6b5f897cb8dfe8073	t
6283143886518:7@s.whatsapp.net	479	\\x2007c0ecb1ec4feb987cf443b02bfba4cf56b313b45967b51eab0fa78e39d544	t
6283143886518:7@s.whatsapp.net	480	\\x0809d22c920d573e3686bf678a91c87a205777a6700cdc8e91b07aae1615564e	t
6283143886518:7@s.whatsapp.net	481	\\x986ca377228760f3b82e47b9d1fcc06c67738568f27329caf801716b32bf994b	t
6283143886518:7@s.whatsapp.net	482	\\xa00c2f5463a415557cc82e48bc2538185edd0448c16997f3fa730452e7269158	t
6283143886518:7@s.whatsapp.net	483	\\xd8ad98f8b531b2020a2e084cdfb53904ccd0d7a1d3456f1ebf16ad89ebdc6950	t
6283143886518:7@s.whatsapp.net	484	\\xd8a578e8eea56d2eb97715b30c47733509acc9462840569c81fd865396a9dd58	t
6283143886518:7@s.whatsapp.net	485	\\x6849a51c570936338dd386d7f73c4d411eb49538e9ce5a373d62265a8ec63763	t
6283143886518:7@s.whatsapp.net	486	\\xc054a4d57724eb5cc71b947038f6e7d8837c3bc22036eab03582b8fb6d29a566	t
6283143886518:7@s.whatsapp.net	487	\\xf07b46427b2a3c421176e775367a9f09d8c0e1ae16710d80c64711743fcb3c53	t
6283143886518:7@s.whatsapp.net	488	\\xa09cc93b00cddcab75d8b90dc7951a21867d3d72c0fd3f6a48aba4cbe5605c4c	t
6283143886518:7@s.whatsapp.net	489	\\xf09a93f1e49f830e548951708e391e150fc6e6a08a895df250e55fa47ce62165	t
6283143886518:7@s.whatsapp.net	490	\\xd8deb0b2902acd285020de4f46d30b3ed68d89edb5ae5f83d44030458da23c7b	t
6283143886518:7@s.whatsapp.net	491	\\x28b46d0b5e7aa935ce46553e5906c2974fe430cc11c5ce72c3eba5c62d7bb24f	t
6283143886518:7@s.whatsapp.net	492	\\xf0ed391afd7d211efd16071f4763872cec97d5345d24e9bb857eb7b5443aeb40	t
6283143886518:7@s.whatsapp.net	493	\\x7090462087f48443b8f734faef11640ee9a5ae1b23baf36593a491c659e4e840	t
6283143886518:7@s.whatsapp.net	494	\\x302b11863a9636cb01a73e162bd83ffb659660bac1c5e74080ec0acb5c808842	t
6283143886518:7@s.whatsapp.net	495	\\x00629bce87e70a3d776d2854ccef8218d22a1cfa7f2093d2aca04c015d33f04e	t
6283143886518:7@s.whatsapp.net	496	\\x385c1568a1d8df6abef56fdc172c90c8a83b226301e74049e08abb946d05bf64	t
6283143886518:7@s.whatsapp.net	497	\\x581cf1eca67301c815c1fac75c3234264f2d404380cd4f3e60e860204af75466	t
6283143886518:7@s.whatsapp.net	498	\\x38b51d38d035402bddf2c34bc0a7ad7ecc2921d9f3a7dc992147ea70b7cfc378	t
6283143886518:7@s.whatsapp.net	499	\\xe8102acb3e3eab401f87499769b0798d5e95fc467e34ebae7fc9d4f7b8835c5d	t
6283143886518:7@s.whatsapp.net	500	\\xe876a36e122f808ead95b0d81956748f7c3d1d1ed830d81ffde152f85c5ff87d	t
6283143886518:7@s.whatsapp.net	501	\\x987f8dbfbb5d304078cb9c62acb0fcbf35e8c3ca38d1ae147a47c0485339b15c	t
6283143886518:7@s.whatsapp.net	502	\\xd022bf0add37e6a955412816f754a9546e4b6252dbc7fff2a4bdbac615bca54a	t
6283143886518:7@s.whatsapp.net	503	\\xb0617b90b3d21a1c6cbd0daa7c7fc494abcd7c6b204d32f0d97cdd7316017d7b	t
6283143886518:7@s.whatsapp.net	504	\\x784261f49cdb97b9798c071921cbdffc86e36985407aa6818f40f81124d0226d	t
6283143886518:7@s.whatsapp.net	505	\\xb83bc9d5c6c84b33bab856db5c5b226141184b1c46e787c16353c8a7c8cd547c	t
6283143886518:7@s.whatsapp.net	506	\\x0892570b7bc376c3b878d6b10ca1ce297e61faea03eb96f62ec0690ac1197870	t
6283143886518:7@s.whatsapp.net	507	\\xc0d69bcfca9ddba94330d36949a1e462b90f4172a40ddf4841a545f40fdfba7f	t
6283143886518:7@s.whatsapp.net	508	\\xf04f803a82c5159d4333c91c7819499aaf339076044d4779fd8905b74ce80940	t
6283143886518:7@s.whatsapp.net	509	\\xf8d89a62af0f664c641ec12f73f254d5b598ba9d52d6a7ad53187cbd428b4344	t
6283143886518:7@s.whatsapp.net	510	\\x38eba75ab8ccbe990edfe66824ba2d6e1e93c25561764de4463b9fb595a58d41	t
6283143886518:7@s.whatsapp.net	511	\\xe0fcf0056e9a87d9e095acf65e4c99f816f183560cce21060c933ff708692444	t
6283143886518:7@s.whatsapp.net	512	\\x48b7ed588a7cef1bbd41332cf09ba8eb31e9409ebb89b1439a85421dc5e85355	t
6283143886518:7@s.whatsapp.net	513	\\x689c9f79dc7bb7e7a7c162a352f212c6d843da0211b69ff11cc9f0ebb90df26f	t
6283143886518:7@s.whatsapp.net	514	\\x403d12a1960c180c3ea57be32f76d9c1c1e049d01da308b88dd0106730367f54	t
6283143886518:7@s.whatsapp.net	515	\\x30ec46dd3ba2ab546d85e261c3faf7be3d92a29c97388451222329c0a13afa72	t
6283143886518:7@s.whatsapp.net	516	\\xe8a835977885c761b0fd4ff838df7185dbaf31f33bed067520f7a5fe4945cb5d	t
6283143886518:7@s.whatsapp.net	517	\\x1015323283ec494923d6e2817b0f8d715b86320ee8e4d520b84bd0421ef0c670	t
6283143886518:7@s.whatsapp.net	518	\\x787dcda90c12378d3fadaabbe06c6764fcc9b8d7c57cebd8db0c9192dcbd5a68	t
6283143886518:7@s.whatsapp.net	519	\\x80148a285a440a3372d9d305ea4468826b576b76d24a53c89590257ef1408f41	t
6283143886518:7@s.whatsapp.net	520	\\x78879e607bef885dbe33bb00b539abf854c2c1e0be4b2695f7ce9e03862e7672	t
6283143886518:7@s.whatsapp.net	521	\\x48fc6663a308efcb86ba50270a3a955c70749503656fce98ecd5e6c38f9f8271	t
6283143886518:7@s.whatsapp.net	522	\\x608a86f7a433ad5f221ce3aa0b3957d8e94a241b6194b854d0702975a65e976f	t
6283143886518:7@s.whatsapp.net	523	\\x6873dad2cfb419f79b256e7f3dc7d22a5f4b565b8c5e1af7b231283a3e5e6058	t
6283143886518:7@s.whatsapp.net	524	\\xe08169e96d77b93554be1c31e0fe411d20080a03552324a3518063c9b72d295b	t
6283143886518:7@s.whatsapp.net	525	\\x88763bfca5a479fad2f399a58b32dad61427165921b20a8dcc524012ee591a41	t
6283143886518:7@s.whatsapp.net	526	\\x90d2f7e3dcf1c876fcdd399a98ed6a808f350c727f8b73cefb9e6d2a3b841a58	t
6283143886518:7@s.whatsapp.net	527	\\xf8353ea0bd1ba06dceae4fa86495089b135803acdc3af3c6d73703dc455b454f	t
6283143886518:7@s.whatsapp.net	528	\\x700b6aac600bcd10599fbb61f40739df90142e7602d5fcb093329a0bd2d5667c	t
6283143886518:7@s.whatsapp.net	529	\\x1008658f7074e04e7faf4adfb1a893d3c328436ae96c9973f3ed65673b2ec96d	t
6283143886518:7@s.whatsapp.net	530	\\x18b12fdfab735bfb04d649e5a4812dee00a243cc16713dbb9a77ec711029105e	t
6283143886518:7@s.whatsapp.net	531	\\x28ba9a2206edd1787f1fa54d8db4fc80276b47bc39aa2d2dd0625483772b274b	t
6283143886518:7@s.whatsapp.net	532	\\xb865caea13d0509e54240d58f1e5a44ae96709b2ea4f357e8685b9541eec534e	t
6283143886518:7@s.whatsapp.net	533	\\x98bf375905932db4fad46b271c407ce95357d16b195990035a0debe54fe1a77a	t
6283143886518:7@s.whatsapp.net	534	\\x3896cd9dabc638f2dfe800f086072a3561aeb5f8a2322f97ac8971b31f2f7a6b	t
6283143886518:7@s.whatsapp.net	535	\\x9850b6bb4eb214a188353085611a17cb8aea425d24261c423bf9f6cfb7fe2254	t
6283143886518:7@s.whatsapp.net	536	\\xd04be3165d73a140e4c495e863d5e29e40f6c1aa4f4b15458f0ddc27f2fe2169	t
6283143886518:7@s.whatsapp.net	537	\\xd09ffa582cc5f51deec574c9400936ca35e5e6df1d29bf2668bc582fe83cd674	t
6283143886518:7@s.whatsapp.net	538	\\x3053bd5085ad43f449f886f86c89d522d4fc6925b7470c513c9c640d6c246c60	t
6283143886518:7@s.whatsapp.net	539	\\xb066f9e57fd6ce10dc25361d8dcfc6cf6d05c43315f981fa6e7f390207da5256	t
6283143886518:7@s.whatsapp.net	540	\\x68df271a1d2551bc15fdcdfa4a68e50b0025521f86b85677432baf176e20f04a	t
6283143886518:7@s.whatsapp.net	541	\\xe0282ed1f0134777c862b99fb2bfe90a613d12798b777753be00938496329840	t
6283143886518:7@s.whatsapp.net	542	\\x6861dae6e0c7cbd827afff59bd4379bf24b3703b40d68dbd3934ebb18e81297e	t
6283143886518:7@s.whatsapp.net	543	\\x9804e3123d0f2ebcfa9f95df288da8f0a107d5bf73e9a9e1823d3e2812a2975a	t
6283143886518:7@s.whatsapp.net	544	\\x480def2547e2ac5388ec25851e466f4bd6f5e657c0b080d9fd1e70d41fa0ae5c	t
6283143886518:7@s.whatsapp.net	545	\\x387b26ef5cebea79e9572f653210bc060446bfbc26c053323e9c702617a2cb4a	t
6283143886518:7@s.whatsapp.net	546	\\x40be01981bb29d0f7a523a56af2b4095dfdc8f46819f18e670bc6105df253e59	t
6283143886518:7@s.whatsapp.net	547	\\x90d2bd3cb1795d3ac5823cbd141cdb2c2e0ee7db9b41f496313351183d790a5d	t
6283143886518:7@s.whatsapp.net	548	\\xd8a6061a691bd14767cd060d6fcfe46a56e40158abc504dc9ffc016b8a0bc46a	t
6283143886518:7@s.whatsapp.net	549	\\xf87956799954f5faff5b81d6607ed78bb2ca58f8b95e413d8c26eeb66e3cfa45	t
6283143886518:7@s.whatsapp.net	550	\\x585818ea62f39dad8e484093d8e29d0065bb475046e111f3b7d2752bb8c3d36d	t
6283143886518:7@s.whatsapp.net	551	\\x88c7b2649e2a2369bc6f7ca3b75c6c5cefff2ee665a8ae5f85cf0c7d10216378	t
6283143886518:7@s.whatsapp.net	552	\\xc88a441ae691e8c5e79a1a1a9cd7090afd6d9e6feeb7f5018bd227f8a3fd5c51	t
6283143886518:7@s.whatsapp.net	553	\\x084cc12d8005e1fd5a9d1b4b3dea7b63521850374b84587193964247db4bcd75	t
6283143886518:7@s.whatsapp.net	554	\\xa8df3fd95c190647dd84619bc85d4db80de9e2a8209220a62652febdff9ec464	t
6283143886518:7@s.whatsapp.net	555	\\xc8a97770cd6e4035b30f5198dd0a45cb2058037bb3cd96beb6289b44ca659970	t
6283143886518:7@s.whatsapp.net	556	\\xc01ea1f4133733654c68faa24acb5b92083bfe0fb0cdfb9277686f7101548a43	t
6283143886518:7@s.whatsapp.net	557	\\x2040ab57c1e5195126c5b34bd5d7486ef494fca4073b17db73c08c3a2e15117a	t
6283143886518:7@s.whatsapp.net	558	\\xc8a6a9e1bde2e2589002b21d9e6e5608e08be41bfa266aa4795d1b0548eac556	t
6283143886518:7@s.whatsapp.net	559	\\x488de058952c23cc3bc4383edbec69dfe5e3e83d6dd0a29cf659fbe3eaec3960	t
6283143886518:7@s.whatsapp.net	560	\\xe876a1e88a455b394b0f0f05c8928f9a1e98a017b1a9281b4e34639ad6563943	t
6283143886518:7@s.whatsapp.net	561	\\x985977c066180a48d21f8e51a7ff548cbe02d38f337b3549a4014d9d0f50ec60	t
6283143886518:7@s.whatsapp.net	562	\\x703acdaefc90b89a6a44fafd76855e1ec8b73397c65946ccfa9f1186c1213f78	t
6283143886518:7@s.whatsapp.net	563	\\x58891288c5e7e2222cbfc22e926a189dfd1c0979fa65f164ff10f6f1b5b53c5e	t
6283143886518:7@s.whatsapp.net	564	\\x18cee47ae70ca92bd838b850a2f24bc4d11542e865142600048d540b95895e42	t
6283143886518:7@s.whatsapp.net	565	\\xb8d4fde0c2cd3ef7bccdd18aa57fc7c4d1756ec31212a750135632a63bd1f466	t
6283143886518:7@s.whatsapp.net	566	\\x205ad6a77ebcdb1b7e01b76b0db8e174ffd6d7a5676500328822b7cb3ff47253	t
6283143886518:7@s.whatsapp.net	567	\\xf87f8df754d1dcb8ffb06dc9e639f8f85f387caf7da02acd293314395a3c8e47	t
6283143886518:7@s.whatsapp.net	568	\\x68459273133cde6dee72dd35c8d21647fffc7af8a9a61bec88d17c7b7b656868	t
6283143886518:7@s.whatsapp.net	569	\\xb0faf6cc256ef5fcc499348075f8abf1470cd5d4427209daafda36bb831c6677	t
6283143886518:7@s.whatsapp.net	570	\\xf0f52bbf6879895a1f5ee0a6e5ae826f529716a2405c26834d21e86fc2744b53	t
6283143886518:7@s.whatsapp.net	571	\\x587954c1ec8b66729b66ea3f03f0b3413c8d5d87a0cbe88824fd8e5b2ba75f52	t
6283143886518:7@s.whatsapp.net	572	\\x68adccc8aba003245f274ef254439b49182bac9ea64aafd05a8842a2dc8c8f5c	t
6283143886518:7@s.whatsapp.net	573	\\x088b1b1522d4552d8448a8cdae449ed54db05fc38e945f9b0eb98d5398b19479	t
6283143886518:7@s.whatsapp.net	574	\\x2048e374da54ee0800963e61d2179ca8e6ddf4bbd1beac2e3c6197018e616d59	t
6283143886518:7@s.whatsapp.net	575	\\x40022bf21f885113210f3beb42006aff2f33036f91549a8c57c0b932c94ba870	t
6283143886518:7@s.whatsapp.net	576	\\x006d31ac697e4934e738e489836fb368dfc75340075b5c11e35fb8a49054916e	t
6283143886518:7@s.whatsapp.net	577	\\xd8833ec2c19e34d317c68ecc793cfbd88a984c9ab1e2fb63c4cb1749257f4c5f	t
6283143886518:7@s.whatsapp.net	578	\\x286d05f4a329470d21a2c98d56030a00aa5b5e737fd75b4735b903ff7fd3195c	t
6283143886518:7@s.whatsapp.net	579	\\x80a6f3ca397dbf588725ecd38ff758cd2a19932351777ffb559acf9d44335d77	t
6283143886518:7@s.whatsapp.net	580	\\x406763cb8295231be8ace84cfeabb80bd11123ab2d99b4c0dc9c8ccd201b0372	t
6283143886518:7@s.whatsapp.net	581	\\x4043d7f87bf0e33bf2950aa098a16bc5407aefadf01111722d3cec1abca1925d	t
6283143886518:7@s.whatsapp.net	582	\\xd0c6aae1bdaa99e4e193c8bb738dd076b46be58d62d0235b4de6ec365fd5317e	t
6283143886518:7@s.whatsapp.net	583	\\x08ee5f0f3b5b7dd205dff948863cc2b1d745ca9b5fda49128c2f757d34f23954	t
6283143886518:7@s.whatsapp.net	584	\\x7000c46645985d96c557f004c90fa63da9ddb61a247e9554f453243b9bc37958	t
6283143886518:7@s.whatsapp.net	585	\\x882ee8f8caf0750ecebfedbb298ee31c396e1f52039d931904cb6de317bbf067	t
6283143886518:7@s.whatsapp.net	586	\\xf09702f950487df0179883a0d54a7b62cda13f0a932ade7b07eabd46d8239a54	t
6283143886518:7@s.whatsapp.net	587	\\xb8cf0fe6046ef7af08157ec5444a7257ea5f2f90643d7a365daaa15c4345f045	t
6283143886518:7@s.whatsapp.net	588	\\xd063438419d7765b90a1dbf9ae9c82eae80bd9f53146516328c69bd47abdbf44	t
6283143886518:7@s.whatsapp.net	589	\\xe8623325b1850669c7636f7d74cdf073364c6307f316a2fb196485e3c1f7ab54	t
6283143886518:7@s.whatsapp.net	590	\\x5837a069ab06d719c355124eb22549b44da1524789b3d36826b4aedc4d890d72	t
6283143886518:7@s.whatsapp.net	591	\\x803c9c1654e21d194cc970c16b3b2b4063636cacb3d1444575651917a8be324a	t
6283143886518:7@s.whatsapp.net	592	\\x480f090151d8a46b0279ef43603b5cfa26965bcfa0bc67d49f94b6ab1d503659	t
6283143886518:7@s.whatsapp.net	593	\\x5006ae7d7b8220f6bd9425a54cfb37398f71444fcdfa247a3f9e0e6143311a60	t
6283143886518:7@s.whatsapp.net	594	\\xb03c263c8e4b07018eff40fedc46384c2205f7fcccea111bd1f3a410a4851f6f	t
6283143886518:7@s.whatsapp.net	595	\\x0847b435409af186527b5829e5dc4b467ff0a4eea7e06da87109b470d850a057	t
6283143886518:7@s.whatsapp.net	596	\\x38b550898df1e85c27374a3d86f34117884cd4adf3a5e42671baebbb3e3fc173	t
6283143886518:7@s.whatsapp.net	597	\\x8832fe4997898438075a7bf3fba47e1e6799677b3d51c0ae4127e9089b0c816b	t
6283143886518:7@s.whatsapp.net	598	\\x70dbcf687d91f2a8316b557b613d4eeeb5ee20f68b6ff0eb1bb25aaaec21e17d	t
6283143886518:7@s.whatsapp.net	599	\\xf049fd4d83c8ad491bf62dd93428abb5604c225d7217635dc03ed0ca251af477	t
6283143886518:7@s.whatsapp.net	600	\\x380fccaa5b8488335c91edaa4e14b45eb4a7ad7bfb0380a2fdea2942f06e6d7b	t
6283143886518:7@s.whatsapp.net	601	\\x38379851905c334dd538219e979f9d1516ed01b88098b5c317457566d3517c71	t
6283143886518:7@s.whatsapp.net	602	\\xc80d9dbad3fe94e6a5b17cef3053d84d8368829e1fecb89e68f920d3b0731e63	t
6283143886518:7@s.whatsapp.net	603	\\x8066103c205c0874aad4e53ad2ecc7dcbe683938def11fdfa207f326ef4f1740	t
6283143886518:7@s.whatsapp.net	604	\\x401bd1b10f39338c3a95c5cd37080954ce95821a76ec96bf280b027649962d4e	t
6283143886518:7@s.whatsapp.net	605	\\xc85eda4b44980e017ddd969d983076d9dbc5499f5e8b6f9dbaa6a31cbf2b8763	t
6283143886518:7@s.whatsapp.net	606	\\xb87493deee10b71aa0548d0590523bccb3b840a2a4de7bf10b4c3ff65d546d6f	t
6283143886518:7@s.whatsapp.net	607	\\x581096a4edf62993228433d19aca9cfe46b794e61f9b14fa1fc950d1db069565	t
6283143886518:7@s.whatsapp.net	608	\\x688e6ca1a0dddbf890a5458a8d292ddd2d290e3e17db45a1c2d22cfccc7ea144	t
6283143886518:7@s.whatsapp.net	609	\\x58292082b9c62d10d7778a2e9ad732694aa13482a5b3948099b652ee4e938454	t
6283143886518:7@s.whatsapp.net	610	\\x305d39a50f97dd061d0de5fb230bb689319e5cb6f0b83ee0d0e2763ea58d0e59	t
6283143886518:7@s.whatsapp.net	611	\\x60bd20080027de20decf89f7ea6cca3dc14be2156c9481e8617fb926e7077b41	t
6283143886518:7@s.whatsapp.net	612	\\x00f291f167c041d664c948f4f56d2556573d95daab9f604b0daa51cd911c736e	t
6283143886518:7@s.whatsapp.net	613	\\x38027c0e780399d46e7085336b4336ffe8b5a6c33a627cc4e13487d10d4e8b7a	t
6283143886518:7@s.whatsapp.net	614	\\xb07d6c232fdc96b1aaff00bf981563398ae3962ace3181b27111603ec6649e53	t
6283143886518:7@s.whatsapp.net	615	\\xc0d0fab845e6ae5f1dce8230483ebf2d3ea4d6262123c7b0949230e97c0e5d6d	t
6283143886518:7@s.whatsapp.net	616	\\x6800dc517a60c161269715c6d2170d442b1607f6993ab9dc45a7596578d5f56b	t
6283143886518:7@s.whatsapp.net	617	\\xa0d299b6dbae6b6ff26cfb4f09f8b6bb33716d409967f818970e634236f1475c	t
6283143886518:7@s.whatsapp.net	618	\\x0034a274a76474d8fdd7f5c8ee1fff85b8c0614b7e63548e56ffacc306ee0b5a	t
6283143886518:7@s.whatsapp.net	619	\\x486777f7ec66b44fd81a311bb61b9792f40fd34a35bafa227742864080938074	t
6283143886518:7@s.whatsapp.net	620	\\x88f6ac48245cbafc6702406bd61c3acfbca7c838260e13fc49ff5f44aaec1359	t
6283143886518:7@s.whatsapp.net	621	\\xb06dc058575ad6b7b85e76b18b4d916ffd67387805cfbb7b8b61ff76d8bb0368	t
6283143886518:7@s.whatsapp.net	622	\\x28b4bf9278ea124cb58258424b5fef9a5fae307544266ae38f1e1c79b0057256	t
6283143886518:7@s.whatsapp.net	623	\\xc8d502a6ef6475a27677cd406160f3fbf46a9131171875746c7881601cbb4169	t
6283143886518:7@s.whatsapp.net	624	\\xb8a972cddbddcbbf073ca68df714785de6c096702da700b1f7f1535c91283966	t
6283143886518:7@s.whatsapp.net	625	\\xb82974946343c0ec92d16389eec643222e596823ba499771b614d7cb9c9bc278	t
6283143886518:7@s.whatsapp.net	626	\\xc030091210ae2557e12543210433d5f43307923cd2db4ff2934acc5bfb74d744	t
6283143886518:7@s.whatsapp.net	627	\\x608440d80245815ae2d04e8f07e3b91972726508fde3f8e536212f2ade480160	t
6283143886518:7@s.whatsapp.net	628	\\xd8dd42c433a7ea4e4fa1206f2114fc57af6737ec45d10a34bec00342c2ea8853	t
6283143886518:7@s.whatsapp.net	629	\\x28aab19a4ee96a5bc8717c14b596ae77083c6d2c49bba6a77d09b58cb1359d51	t
6283143886518:7@s.whatsapp.net	630	\\x302ad3df6b70fbb3294ffc3a6df446e690c67e0aa894fab54854c58496ff8759	t
6283143886518:7@s.whatsapp.net	631	\\x88283b25096e0c709f0852a503f3e1b1093ed1a25af4e6f2e421e0a56a68ef59	t
6283143886518:7@s.whatsapp.net	632	\\x5847a11e318615b02e973128aef40bf8755f8942b07ca19578dee83c714e525f	t
6283143886518:7@s.whatsapp.net	633	\\x581b011716d805d5dc31447de957ba997d2e85d643920b20c7a18b620f837852	t
6283143886518:7@s.whatsapp.net	634	\\x08d677047164abb6b24197095b7e73b0fddb419a76ead5d2afab79aebb9b0e7d	t
6283143886518:7@s.whatsapp.net	635	\\x906cc5e9b03742617f47c60cccd9b7424cdd473b854c2c73a2b4d91fd74cb066	t
6283143886518:7@s.whatsapp.net	636	\\x1015fa2c0bf2f26077e58c6ac3235e7278863fadaddb8b8daa9ad1ab7e6d327b	t
6283143886518:7@s.whatsapp.net	637	\\x4042b43d9c6c9ce6337c58ba3c4cff5ee32ca3e2840930c81c07e15cdabf3851	t
6283143886518:7@s.whatsapp.net	638	\\x6044bb6678f6168bab9f84c06e33f51618781e3e35bde13d857570e1f0363f61	t
6283143886518:7@s.whatsapp.net	639	\\x80fd7cb599f816387e32f3e32d3eb74a6431f6f890dc949d2cf2ebc7e694fd77	t
6283143886518:7@s.whatsapp.net	640	\\x10ed3108d11f459eb25f8e8f25e5263cbfb1490ccd1cba3491e5fd2bdd141c73	t
6283143886518:7@s.whatsapp.net	641	\\x70e3a16c2dbefb9928a9195fd8ef7172d5d62a33b612ac89dfd58feb01d0d672	t
6283143886518:7@s.whatsapp.net	642	\\x68ca7d1a3c35422d549689fa8ecbe49c06e8cbc3301ea04e325f3e93a936484f	t
6283143886518:7@s.whatsapp.net	643	\\x2807c1ba23c82682fb6f7272706cdc200b226d095de4837acfd00636691fbd4b	t
6283143886518:7@s.whatsapp.net	644	\\x687f8ad882bf3a545ee1a5684ea68dedb8ad7a3baf5759b3908a267f46f8787d	t
6283143886518:7@s.whatsapp.net	645	\\x187f936e5820c26bb0bc8b577d8db1f55b89efe16e855162774d4efaf5d19047	t
6283143886518:7@s.whatsapp.net	646	\\x4037e0184a088bc0d73b2d4726cd0b76a7aaa9ffde88059b2d6adb7046c7224e	t
6283143886518:7@s.whatsapp.net	647	\\x48936a124d234deece1c6a86a36a33a81ec43ad18d5fea917c1e940983eb6572	t
6283143886518:7@s.whatsapp.net	648	\\xc8a042ae8947a090ddf2604584f743437ec35e7957a14ac572431e3c793f2654	t
6283143886518:7@s.whatsapp.net	649	\\x981e76e5ac9d247b30614ef2d7d1d7372b8b2f2963c102ba64c7a050425a6e7a	t
6283143886518:7@s.whatsapp.net	650	\\x907dff214d8e89041c22c7d048abc0fcdf84b9692feb13d642b066a69ccd3971	t
6283143886518:7@s.whatsapp.net	651	\\x504d5f5e08ad6c694c5a2a38eb2d29c1304451d1d9e873a7b8e0cb6ef7dfd173	t
6283143886518:7@s.whatsapp.net	652	\\xd044da819b69572ad956f1ded4b60ff43880dfa3464b9b76fcd4ee1b7d31df40	t
6283143886518:7@s.whatsapp.net	653	\\x103dfb2a67a067f67a660f601e884a255c2a11644a02590d464d044e4c9c3348	t
6283143886518:7@s.whatsapp.net	654	\\xc04f1859a5fbe09f2eb803573bd9a405f5a2fe4bbc77957d66f3a4d911388974	t
6283143886518:7@s.whatsapp.net	655	\\xd8a2329c8f0604e26adf50877d96c06e30b54d833caec1d24340229d2f1e984d	t
6283143886518:7@s.whatsapp.net	656	\\x68f0cf6b3f260305953ab5423a2ecaf0c359ef814bdeda697aab3d1873ec3d6f	t
6283143886518:7@s.whatsapp.net	657	\\xc0b9fd795f8e45a72eba322a40e074eee700178df847179baef350acaf806e47	t
6283143886518:7@s.whatsapp.net	658	\\x789feab88616ee68288b7070dc44148e6652ff981c828483286c2180eb615e72	t
6283143886518:7@s.whatsapp.net	659	\\x587bccaa23b038b42dd1802332f5e2a497df7d5a8713b54b5758d85bbced3b7b	t
6283143886518:7@s.whatsapp.net	660	\\x40cc86ffd30f76be92fc74259b934311fed0046d095320c886a4948fa1d7d45c	t
6283143886518:7@s.whatsapp.net	661	\\x60df1fda2278b46d97213dcafefbdefe407e2dc31f677c4f2e433b817284b550	t
6283143886518:7@s.whatsapp.net	662	\\x28020f1ec1a656a1c54da2d43cd18069ebc0b567fe9a20bc7a2084c3e6d8604a	t
6283143886518:7@s.whatsapp.net	663	\\x40fdf7fc1b5607eb666bcb4df2fa70983151ce66d0ce2d1d62039e924c30b54d	t
6283143886518:7@s.whatsapp.net	664	\\x605cc183e8abfea1c198fd5697f6bacf173b745b197dc04c0a9bbfed6faa3662	t
6283143886518:7@s.whatsapp.net	665	\\x30e47c5f4c07f3b0259e30ac59ccb37ace8f11fa28e97f855d20d82dc8ba6576	t
6283143886518:7@s.whatsapp.net	666	\\x7081ee37f68bae4b9f97cf9564eb1169bc7232f315882de35ab162d7ba8f7d69	t
6283143886518:7@s.whatsapp.net	667	\\xe06792ad2cb81dc0ca9a50b7c8c29922731348861129a62f576a14e6ac064a7a	t
6283143886518:7@s.whatsapp.net	668	\\x703b440cf5544ba0ae4a3786dd4129b88140abd96d437200abc0e35b1097b372	t
6283143886518:7@s.whatsapp.net	669	\\xb0d50dad0681c7acb95d622e6a1b56c53442871b2fde9bf565eb7a9ad2d83870	t
6283143886518:7@s.whatsapp.net	670	\\x005d9645e075ad424d80007a960d4a1564c00107119f7ea0ce44f0d4f6a76f6e	t
6283143886518:7@s.whatsapp.net	671	\\x8816a09d149ce0d30f6f9081fcbdb988e5322e131be8179cb59be396e9965769	t
6283143886518:7@s.whatsapp.net	672	\\x48715c5a469494c42c8b30c974dc38e26524f91d37d422597799cd7fa6210a76	t
6283143886518:7@s.whatsapp.net	673	\\x68d4912a417365acef55adfe01811a7776a8a06df87a63bb84421aaad34b445b	t
6283143886518:7@s.whatsapp.net	674	\\x380dbef51be626995cc3205d58dd51df115b5ddc464b3bd35a5c9490755adf42	t
6283143886518:7@s.whatsapp.net	675	\\x10e92c0ec55b1eb6a963d154a56871af48893a5e7e8386d5f3dd6a005d1f774e	t
6283143886518:7@s.whatsapp.net	676	\\xc057a6980550a5ec684102aea0b44a9075e600e5c530d9c9ac2c4f3539bc7b6c	t
6283143886518:7@s.whatsapp.net	677	\\xa0bdcce0d586842f030c7133b04c31ead874cf1b2e5b99ecedf3612254cdb56b	t
6283143886518:7@s.whatsapp.net	678	\\xa803e495bb5c6c32e807f706f980c4acc8ac7a1117ebf9358bce76100230e370	t
6283143886518:7@s.whatsapp.net	679	\\x08bcb859b1f75fe3faf530e26d5cff43d58b51c4015b6a2e232c672bbb61fc44	t
6283143886518:7@s.whatsapp.net	680	\\x804a63e1feaaa75f1698a09b9c1ae8227ae6f3860eb3dd7922e7202d7da19265	t
6283143886518:7@s.whatsapp.net	681	\\xe83a79a12560d4551d8d2512eeca9686a9cdf7cb626a93c79f91627cd9312965	t
6283143886518:7@s.whatsapp.net	682	\\xe8f44fef92ff86246d7bd981031ae7862038fc9918f4d4a7034dc69526376f57	t
6283143886518:7@s.whatsapp.net	683	\\x2873f16e26d5a1a5629ff9e5e062ddb4e4352dc258f5d981f5f0671ecbfbf35f	t
6283143886518:7@s.whatsapp.net	684	\\xe0aff063e0c123088c9a057f20ec14576edc4a9752bfb1fd122f51540a686c62	t
6283143886518:7@s.whatsapp.net	685	\\x289bc8d148d5ae9d5f4f07b0b20b80286819404718759d238b0040736025245e	t
6283143886518:7@s.whatsapp.net	686	\\x888952af4be8ac85dc0eb2b1741f0bad534303771d555d6a0402d782acff3668	t
6283143886518:7@s.whatsapp.net	687	\\xb83a15cca3f8a9629b7f37599bf7af4eea48f1449c9a95a9e2e8eb84fe1d3465	t
6283143886518:7@s.whatsapp.net	688	\\xe8ce7cdafb07b2c86ab7b5a381b9da7bffa427877f53fe2878b9becee1f7236a	t
6283143886518:7@s.whatsapp.net	689	\\x586883c21cb7713007b11c1a23c805524d5990ac0517655fb1d2bd27d16b4f60	t
6283143886518:7@s.whatsapp.net	690	\\x60a28b054cc3d2abeb39b396e25a1e40dc9635aa1f0222d1983aece1dc289468	t
6283143886518:7@s.whatsapp.net	691	\\x487dc47c0b8ef91288be1a495d30047b4c64eff781c8289b1f89509e56d39574	t
6283143886518:7@s.whatsapp.net	692	\\xf0c89e44c42ad8a686662e93f989a9f7e03f5fe1264290496f2cffd75aed4d49	t
6283143886518:7@s.whatsapp.net	693	\\x482093ed2215356871c36696a8e37ee403706ddb3240958783222305e9ed4d5a	t
6283143886518:7@s.whatsapp.net	694	\\x189269470a572e1283c8053445d09b17e6466b43e24089d38ad35ec6e2fcfa59	t
6283143886518:7@s.whatsapp.net	695	\\x10e7e7f17ce6dc41bbaeb1342f33fced27e163b38199bd0f670feaa219fddc7a	t
6283143886518:7@s.whatsapp.net	696	\\xd0bd102f0096fce38dfcbfa34d6ccea136baef2562f4e2f22286f4f812ebdf7b	t
6283143886518:7@s.whatsapp.net	697	\\xb8e73c5840afc16d6add5b3ed725c5f0ce767f23b7583e5808e151bcf4599f68	t
6283143886518:7@s.whatsapp.net	698	\\xb8d8b633461b767cd1804b19d3ef70115bc981414110250ffa75994482161141	t
6283143886518:7@s.whatsapp.net	699	\\x48ad74ff20bf8a2a59b2eacde067fe17640c7785ce2b2a27ec7a5d1fe5465571	t
6283143886518:7@s.whatsapp.net	700	\\x10df009c7f75493c6ea50b35a3c95a7acd1dede8d0c7f944ab483ff58dd07359	t
6283143886518:7@s.whatsapp.net	701	\\x805ebaadcc0dca4d64f934b9fbd2fa092fdd92825550989bde66688433c26572	t
6283143886518:7@s.whatsapp.net	702	\\x40fb8867829ed30388ba003497dd713911b818f6a1266b77533c91158c797e50	t
6283143886518:7@s.whatsapp.net	703	\\x487df24b8a76cbf792d931978e7bfb1e6a7401cb92197e234ecec0a5f127774d	t
6283143886518:7@s.whatsapp.net	704	\\xd88f1eb8e9cf2b273fef8e408a2abff873be59c4573dcd25384614ce24f92a70	t
6283143886518:7@s.whatsapp.net	705	\\x20225c169c7a3906e2d22853477c2e0d23eb15ef6087717cce68c5ddc8d91763	t
6283143886518:7@s.whatsapp.net	706	\\x88b801994477cabdd7cee641ee661ff3090dc4df1e7b0e39c0931d3207aee373	t
6283143886518:7@s.whatsapp.net	707	\\x20f997242f69123d6096b22d71cda5873fde95c195c7efc908f224a9b798496b	t
6283143886518:7@s.whatsapp.net	708	\\x28c6949a4b2c23273a2cb6f59096d185a5b9461cf601656d226ec58017fceb7f	t
6283143886518:7@s.whatsapp.net	709	\\xd8aec661c4393b9a4e6e75d3e56c241c3f97ca38a67e4e1cdef1fca5cb4a1d58	t
6283143886518:7@s.whatsapp.net	710	\\x80631c8f30ff31f57a8c06aacf7011ea662dd028c0d8cb313e29b7e8fc61506f	t
6283143886518:7@s.whatsapp.net	711	\\x002f74460fd46b9b03ada6521ddfa138f7e2690afafafecc8c434411a204795b	t
6283143886518:7@s.whatsapp.net	712	\\xa0cdb4c9764455931e8b6b26a04c73dfac973c89e34cec6d9a9aebdd8359dd6c	t
6283143886518:7@s.whatsapp.net	713	\\xa03bff5166db32d8e3999e2c0a69ddbd196e56987be25fd3c087afab909e4878	t
6283143886518:7@s.whatsapp.net	714	\\xd808677611582e4e03f637cde6f44a64bac09b425be43beef3137c0a91e7637c	t
6283143886518:7@s.whatsapp.net	715	\\x40f171b876de0d1f01cd408925db8a09681c6ee4eb646b9fd1e2521ed736cb42	t
6283143886518:7@s.whatsapp.net	716	\\xf8439d41dcd69d21239e96a18b357e946cda41e119d3e93daa50b1b205e69b50	t
6283143886518:7@s.whatsapp.net	717	\\x784bfd35d2c20833dacc18131fffc11885221c0b6969f2d99d186614a05a3965	t
6283143886518:7@s.whatsapp.net	718	\\xd8be1cd61c2999fd0718cefd7d4c06ade67f7ba62c029f155da55019bea77b79	t
6283143886518:7@s.whatsapp.net	719	\\x885cb4a43eec54a998924610abe4874b0cf180e81ccb95de1b1d842d2497587f	t
6283143886518:7@s.whatsapp.net	720	\\x78c9b15ff23bba97ba3b463457049431c58853630d17560355e0f00024960a5f	t
6283143886518:7@s.whatsapp.net	721	\\x305f881b9829d309658efb62c096407cefacb718ef979c44bef5a5171b877644	t
6283143886518:7@s.whatsapp.net	722	\\x084df559b0f1d5432a290d65069a58ea4b35b7d033c8470483430502670f3d54	t
6283143886518:7@s.whatsapp.net	723	\\xa8f26033007b0e582c60c608138929b5f9bd27cd8a251e7e9d7a7db359f59458	t
6283143886518:7@s.whatsapp.net	725	\\xb044340df370924c18734fb002310815cbd0b40c049d145b157266c1bbb1bd66	t
6283143886518:7@s.whatsapp.net	726	\\xb03fcf11147c6642bf7899de3e001b480f6bf160e554f4cf1c1eb16030a67a47	t
6283143886518:7@s.whatsapp.net	727	\\x60c04805cfdd9ffcc2d035dbd97965ba91f79b64c41ba8a443910b3f5c02a645	t
6283143886518:7@s.whatsapp.net	728	\\x30e43cfd295a926824c42f69ce4d4d054aac9e86a61815597fc2f5bdbfc70a51	t
6283143886518:7@s.whatsapp.net	729	\\xd08497b245b82817d7929727b035032fdfc02fa6f7574ba52fdf7a4ec6eea862	t
6283143886518:7@s.whatsapp.net	730	\\x98d7cf0fa934d0cc9094abd6a2e4a396d61307be55d7d093bbc60f8426dbc17e	t
6283143886518:7@s.whatsapp.net	731	\\xa8cfc9b88fe6f91826b76ee7b999edbced12dd555b62d5f69b119973bbeb6c49	t
6283143886518:7@s.whatsapp.net	732	\\xf017b41b07cb643167cac8eb34eef66f949ca9ce3416d6bc5b47617782261c57	t
6283143886518:7@s.whatsapp.net	733	\\x207d5038cb9bfa56aca784ef490e4c470c4f11dfaa31918db69ef3bc7ac52271	t
6283143886518:7@s.whatsapp.net	735	\\x9817148f455f65325721891b9f0699b2f66c4d6bf822059c8063ac927a10c548	t
6283143886518:7@s.whatsapp.net	736	\\x78f47f3ce941f65eb5d33c305bbf54c1443d35be46f33f42b5bd415828924742	t
6283143886518:7@s.whatsapp.net	737	\\x4059b0bfaeb254ccd577c490c34d7d9096c259168a21a8503b958f93292efb57	t
6283143886518:7@s.whatsapp.net	738	\\xa0bad31adefc72f9fca6e17cbf011a114b0b8c814b24cb2f6eb2bde0cac38350	t
6283143886518:7@s.whatsapp.net	739	\\x78d25e04f3d6cb7169b8de6d3cccd9716a3326a6d853e0345ff5d597bee33c45	t
6283143886518:7@s.whatsapp.net	740	\\xe0a1e789600f882c916bd119848d59ef620e470d10a3fca5a17b14d60b093c50	t
6283143886518:7@s.whatsapp.net	741	\\x5013fec33901cb9dd86d6dc07409883f6fe11a49466809b9b8bbb51be36d4940	t
6283143886518:7@s.whatsapp.net	742	\\x701aaef302155ca15488c1290c96a69a890cb31aad39fe00a66d11453c7c1d68	t
6283143886518:7@s.whatsapp.net	743	\\x382f1f926d24a2f7f0e43232a03e9617717d96d9ae1ec3099eb89821f6f31b43	t
6283143886518:7@s.whatsapp.net	744	\\x4885d6ddc94ccd0408b921866232ecc2a4abb45cb0e9a4fbed15de157ec71368	t
6283143886518:7@s.whatsapp.net	745	\\x88aae65ae757cd6e6d6b1e752450f5d4434dbbb2a1bb73280b4d306680211368	t
6283143886518:7@s.whatsapp.net	746	\\xf88d99e91bdf86eae6c3b388a56c20a5f16dc3dec0b5e042fa6051af8d1c2049	t
6283143886518:7@s.whatsapp.net	747	\\xf86a34a568bb66aba96256e1382ddcb8ea8de8c5591d9c6bd88e2f7c569bcb4a	t
6283143886518:7@s.whatsapp.net	748	\\xc04c46bf7bd3d937dc01b8cf76f789bb076111eab782fc25b86a497be6308d4b	t
6283143886518:7@s.whatsapp.net	749	\\x1874461d6b876dd49d438848327777a368d4dbf9c75358fdeecb1f91d1630d41	t
6283143886518:7@s.whatsapp.net	750	\\x308dab8648d8ec74778684d5e3fa948b1755e1e0c9901bc818c6bbfd47205a5b	t
6283143886518:7@s.whatsapp.net	751	\\x30ee1bdb6a0f909dbe77fa25f3f3f2d77854af0b4be90e7c33c6e4937c1bd75a	t
6283143886518:7@s.whatsapp.net	752	\\x585db9bf3e83c1bcf679f23f9ad075b6b8c6c14f42857d39188b9011fe9dc94f	t
6283143886518:7@s.whatsapp.net	753	\\x90c8fd9e50de9d395d98e2c4eb8b66ec56749cfd8fcff9fd821e27700a8ccd48	t
6283143886518:7@s.whatsapp.net	754	\\x287388a7d54d01732353eb4ac52111f3d9f7c824feb3d93458a3851e00fc725a	t
6283143886518:7@s.whatsapp.net	755	\\x10174779876babcb42f9cb53b24a5b3f3b058c33fede229cfe0223785d9fd06d	t
6283143886518:7@s.whatsapp.net	756	\\xe01f0dba7e8d7053080206678b02293307967bfc6b731b28b656512ad5889457	t
6283143886518:7@s.whatsapp.net	757	\\x4086dfef746de58c2a3d106fe9ce268b971f6d391e48d2d89c82ad2ce2c28243	t
6283143886518:7@s.whatsapp.net	758	\\x780d9f5c6ce6592410b2ac8ffbc089285aa4ee83190dd715ee0832dfc2c86f77	t
6283143886518:7@s.whatsapp.net	759	\\x38183960548e8578a4f3180952c02034fdf7e31e7aa4bbee4b13e1b72719614c	t
6283143886518:7@s.whatsapp.net	760	\\x9841cfacba51612d0b7134307887dc96fb1d9c96c96d8df9aaa44b204c76934b	t
6283143886518:7@s.whatsapp.net	761	\\xa8bf79d6e66d425746ab0122d2a5a56eddfe55c031dcb7218f51ace05a5f266d	t
6283143886518:7@s.whatsapp.net	762	\\x30eb77bc56fe6d383e0815415e1f3f4b71ddb60560b92d86985a2d0d25171255	t
6283143886518:7@s.whatsapp.net	763	\\xa0114f275c0e2815fa1b11b5722837d670018f9b1a1b2cb2b392638e0298c972	t
6283143886518:7@s.whatsapp.net	764	\\x50ad7e8308008aef4ce583aa67d62c0206c375f2dcf175b76e6b03109264b476	t
6283143886518:7@s.whatsapp.net	765	\\x30828fdde8c997c8aec56fbd728295c53f0fa43496598a148f4b8a308215c566	t
6283143886518:7@s.whatsapp.net	766	\\xb0ae54f59557010fb81d5ab0f6526365736ccee70adfaf800c6e80781eea175e	t
6283143886518:7@s.whatsapp.net	767	\\xd0ad08248e90ca9c683c987313bfc2dd799de2a2a1e4bd638a1627c0141fdd76	t
6283143886518:7@s.whatsapp.net	768	\\x50a20991cf07cebb64cc19752c054da00282bbf86c0ba0fbc51152384fe85c72	t
6283143886518:7@s.whatsapp.net	769	\\x8847163a2ad098eddb89141d2a3560d78001de6c67457eb0ba9d6f0112103a48	t
6283143886518:7@s.whatsapp.net	770	\\xb8f82dadea9b14667d42f2e7dbd9b959204524e953251a8ea1ca3cb68e596d6b	t
6283143886518:7@s.whatsapp.net	771	\\xf814a5d53f02f291b75763fe08855ede7e223be012de3b50a16cd50265ce1573	t
6283143886518:7@s.whatsapp.net	773	\\xb89c1b36fc1680839545eacddb45261f2daff693e61c15fcdcf0a64e888b8c7c	t
6283143886518:7@s.whatsapp.net	774	\\xf01c4db7c98c297fec028886c2cde24fe41b329599c0328a02f5e94bcebcfd74	t
6283143886518:7@s.whatsapp.net	775	\\x80a9eeaefe5c976553b0d25940b7a32505d65e53c0f4917d1ccce415069f7741	t
6283143886518:7@s.whatsapp.net	776	\\x40eba27e32717ae342854a1e732be03b113fbbe9f63040fd84825a0678aee54f	t
6283143886518:7@s.whatsapp.net	777	\\xb05a3a7447b89398594ee9011bd698a890613ad4454684607b5e6cdbf3411546	t
6283143886518:7@s.whatsapp.net	778	\\x80d56e9fea62aab9b59d469334b8ffb5ad963e475f93bfec3cc8d21023b10941	t
6283143886518:7@s.whatsapp.net	779	\\x78ceebcdab03dd9669b924c1b586c9e0cb97118dbacd0bd467427109d2061c56	t
6283143886518:7@s.whatsapp.net	782	\\xb805028f92d8437648d1a55aea29e1dca2de777e492882b2e2b6d5c1261f7769	t
6283143886518:7@s.whatsapp.net	783	\\x1093e7ca7a0e40c95c43bd5f03182f95b6ccc5aa4342d3dfd1b64cee3cd0c951	t
6283143886518:7@s.whatsapp.net	784	\\x308347e6c72cf42127ac5d970340ee3dfe24e61868e2d41ec29c29f0d1d30a56	t
6283143886518:7@s.whatsapp.net	785	\\xc0f451af4ab09db72dbfebec586dcbbadfa4077cb711d7a3035e32a9d433c066	t
6283143886518:7@s.whatsapp.net	786	\\x8812ba73a483f25599c5204921c2374b50af7831ab924a3efc1cbbe5503b0162	t
6283143886518:7@s.whatsapp.net	787	\\xb8985d4169539bae1fef1acf32b8012c9037b6d6079930939576cddfec5acc6d	t
6283143886518:7@s.whatsapp.net	788	\\x583762cc0f989cbb3ccefe466ae35953cff9244bfa9aa8fd704ef737dd4f474f	t
6283143886518:7@s.whatsapp.net	789	\\x90db6effb2fe20acbfb85a6d47922fe9da06e911e4d1ad6593dc820c3607ac4f	t
6283143886518:7@s.whatsapp.net	790	\\x381be8e242191aa9b0dd8aeba4046ed35bd5e686b3aa5bba377449625a82a447	t
6283143886518:7@s.whatsapp.net	791	\\x781de4884b418737697b67428d4e1d96ed3164eefc6851dbc75ea5562671ee53	t
6283143886518:7@s.whatsapp.net	792	\\x4052d953a638c8bc38864a9122e1bedbbf4ad143a6f69784157bf59e60652c5f	t
6283143886518:7@s.whatsapp.net	793	\\x487f74a23af9aae218631ba572698c0af30584ec58002cf4034207ee00a33c74	t
6283143886518:7@s.whatsapp.net	794	\\x585e755fcb6d534213d8805153aefa36a7519b25330cabe0abb8c9f8c49dad64	t
6283143886518:7@s.whatsapp.net	795	\\x0027135a4b908e43bae50a032b72222ce9c2b085bf0f0baea044cb69408c7268	t
6283143886518:7@s.whatsapp.net	796	\\x680010d2acd9c535dcfe42295c8eeae0e79a840b8d86cfe6a2c52df6b4ed9b41	t
6283143886518:7@s.whatsapp.net	797	\\x987df9f266ed2f790c64f55ae23cd3ae11f471c0224940aa84bee937e2a8d46f	t
6283143886518:7@s.whatsapp.net	798	\\xb8ea8912ca7bde66b03014069d667954a9d366afe75c318f7053e0f39f6a175f	t
6283143886518:7@s.whatsapp.net	799	\\xd831ea7c0997a21cbd3dacc2637443888ef257b4d44f128fe21c3bf292da2862	t
6283143886518:7@s.whatsapp.net	801	\\x200414cce7b0a99d611e5aa949393da7d86b375e85838aa76febf92102af456b	t
6283143886518:7@s.whatsapp.net	803	\\xa04276fda1a3949f31dfc02f66ffa18ae9ed4bf56b172320e587da532a01af40	t
6283143886518:7@s.whatsapp.net	804	\\x20c282391d742625459a9a45eac90b7725b0f8d52055ed5ee9f9fb08d7482846	t
6283143886518:7@s.whatsapp.net	805	\\x08d9f93ded897fbff04be74c163ee6baea4c473d1ecc0867a4c74245883f927f	t
6283143886518:7@s.whatsapp.net	806	\\x98e4823ff2f673e47249d1c0522351d31aac702c43611839406360cae703ab66	t
6283143886518:7@s.whatsapp.net	807	\\x38c28852da201c47e29723fc15c8ca774bec9764250a9157cdc24e9b0e118f66	t
6283143886518:7@s.whatsapp.net	808	\\x90cb1b71f8ac8e3f6ab25cc2f500450f7b8df39c0bb2098fd6082b07a17d3248	t
6283143886518:7@s.whatsapp.net	809	\\x80aafb9fe1cfc63a54345004d294e1f52fec61cc6ccc8b28248fdbf5a9709d75	t
6283143886518:7@s.whatsapp.net	810	\\xa0a1de4a719f553a81cdbf3ef6ac197647254a84633772893a031a511247ba48	t
6283143886518:7@s.whatsapp.net	811	\\xf8fc55a79c0dd98536ba04deccea84d8b365148e1e5000a27e2d56f0932e9454	t
6283143886518:7@s.whatsapp.net	812	\\xe8c4e646f1b73f26e5941ef5c275ca8a600615d4e39d1643de0c03963081ba70	t
\.


--
-- Data for Name: whatsmeow_privacy_tokens; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_privacy_tokens (our_jid, their_jid, token, "timestamp") FROM stdin;
6283143886518:7@s.whatsapp.net	6285778283804@s.whatsapp.net	\\x040120a85e821648c38b34	1767621436
6283143886518:7@s.whatsapp.net	6285810105638@s.whatsapp.net	\\x04011b03457288eeef0ddd	1766803013
6283143886518:7@s.whatsapp.net	62895619188604@s.whatsapp.net	\\x04011c0a876a9d1e4057d8	1765884494
6283143886518:7@s.whatsapp.net	6285224821723@s.whatsapp.net	\\x04011c283fb53bc8e99f80	1765857788
6283143886518:7@s.whatsapp.net	628889365470@s.whatsapp.net	\\x04011b10dc53c42c48d352	1765616310
6283143886518:7@s.whatsapp.net	6283823190241@s.whatsapp.net	\\x04011ba8e0ccab0cbaf6db	1764932278
6283143886518:7@s.whatsapp.net	622150996528@s.whatsapp.net	\\x0401181f207cb54bbb7b1a	1763085069
6283143886518:7@s.whatsapp.net	16074994993@s.whatsapp.net	\\x04011860dff95f1859f02a	1763016957
6283143886518:7@s.whatsapp.net	6285185905040@s.whatsapp.net	\\x0401189e1e687b1ce98a80	1762821434
6283143886518:7@s.whatsapp.net	6285215399783@s.whatsapp.net	\\x04011803ec5d3119714ea9	1762505804
6283143886518:7@s.whatsapp.net	628999994929@s.whatsapp.net	\\x04011504519c7ba115355d	1760102551
6283143886518:7@s.whatsapp.net	6289604336460@s.whatsapp.net	\\x04011e2cb261b127111b19	1769905067
6283143886518:7@s.whatsapp.net	6283143886518@s.whatsapp.net	\\x04012020d6600cbc9687ff	1769816747
6283143886518:7@s.whatsapp.net	628988289551@s.whatsapp.net	\\x0401203613918521b8a05a	1769817112
6283143886518:7@s.whatsapp.net	6283127378535@s.whatsapp.net	\\x04012063b04c28afd6d0c9	1769729801
6283143886518:7@s.whatsapp.net	59425402433630@lid	\\x0401212321c980305eab0d	1770120534
\.


--
-- Data for Name: whatsmeow_sender_keys; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_sender_keys (our_jid, chat_id, sender_id, sender_key) FROM stdin;
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	185014457217030_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a3437303632363238332c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a2267532b52524b7a697152515578564b75464139574c4b654f45747a4d2f6166445342645064776b535550673d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224259306e5a2f4356767657434c30432f56552b7470624f36554b684838786c5966376671394271484e687075227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	105488691757238_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a3630353737363938332c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a22723054306b683471746f4b61696a52516738384636757441746d49472f4e506d574a7431652b68723366383d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224264454b754266696c71366f6d4d56714a4b6336305854796d6b6f3230313265486e486d434b694a2f4c494a227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	115895447896078_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a3632343135363533302c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a322c22436861696e4b6579223a226264645a53325a364653447730385768624d716c427a376f36545933384a71436f6b5866574d474131676b3d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224252666831736e675879785947516a35422f48454d326154744f2b336633694e787271696e4d62306e6d3459227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	132272191709432_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a3238353038393737322c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a224c30315934633767364431344547417743724449507458766355494b79702b6e4334726d66515971724c673d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a2242575249522f6a4c4a4462435a545074765a536c2f5a63336534557947457845394e73454541456933444e34227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	262104842035423_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313639373838373139362c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a22585152385542524775706a2b2f675a5a484c544e43586756566b494f7a68504661326666316b42666133383d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22426267544d57396e3032745a6b4d474d484a796f65436b612f774c3875566162526d506f6e73574a32575963227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	91221296955604_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313333383736343032312c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a2238366f4d7a387448782b3474736537556d55315842703676664b434b50704142394966716473314e4e6f733d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224257646d78504331476f52796846446679775137343745685051306d757a4275433744507a6c467732636757227d5d7d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	122033006465061_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313938323931343330352c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a2267636e634d7230596f42476b4b722b694a4c312b64526e3451585330452b656c6c2b7a715846315a4338633d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a2242667478374d5a336f346b49393772695679502b6b7179455433667473663646476147635470546266765932227d5d7d
6283143886518:7@s.whatsapp.net	status@broadcast	21148653883564_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313837353937353630312c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a392c22436861696e4b6579223a224175317445625074356846392b39665a637839776a526e6a415447557264314e4e55702b397a42694265773d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425377567832784d353042472b4e4d57436c56696f696f7a49526a596972537a415270615943544935565552227d2c7b224b657973223a5b5d2c224b65794944223a313837353937353630312c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a332c22436861696e4b6579223a225962426c69724b4244717346344a75412b744e634361743364342b49537430686874745073414e6c6773493d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425377567832784d353042472b4e4d57436c56696f696f7a49526a596972537a415270615943544935565552227d2c7b224b657973223a5b5d2c224b65794944223a313837353937353630312c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a322c22436861696e4b6579223a226f337164415a59755178644d616f4332396d76656e394c4b646e2f6f33636f566f6472356a2b6145534c6b3d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425377567832784d353042472b4e4d57436c56696f696f7a49526a596972537a415270615943544935565552227d5d7d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	139432053207269_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a32393839353330352c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a362c22436861696e4b6579223a223071706761623346625a346f6e6e66546d337752595842664a366a6b6f587145623069646b39564d4f7a633d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425237717172676c2b69337237794f536255442f7a2b6f4b415033484a2f64536e2f46373565696b764e5532227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	150822088396920_1:34	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313135393732303139332c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a372c22436861696e4b6579223a225a776e44735936656b64705354625436336f792f4d746836695a43684e7037745562314b4f553765454b513d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425274546d4250496372754733684d416e6d522b426d6c5a57686f396f38556f64506d52623351536d46526f227d2c7b224b657973223a5b5d2c224b65794944223a313135393732303139332c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a362c22436861696e4b6579223a2249502b4d71746a67346e69626b732b36424432635948424932456f7338633154467a6a766f72302f52526f3d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425274546d4250496372754733684d416e6d522b426d6c5a57686f396f38556f64506d52623351536d46526f227d5d7d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	206545447084155_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313333393236303433372c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a382c22436861696e4b6579223a224f434754515151316b423775354e664a715879576a6f3255636433696856454556474657475137726363673d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224258437130726a342f34496c30634e7171334b6238305a6b5150596b464d486469563677497551444a77785a227d5d7d
6283143886518:7@s.whatsapp.net	120363421543564458@g.us	200858524491833_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a313836333034373535352c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a342c22436861696e4b6579223a22334e4d5275774d634642624e2f7550754342535975334d4e72534c55347a554a4e51597a796b6138435a553d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a2242644c7776354a71755931584231744b67627150566f64795848315079556f4433674d6a626d336e432b6431227d5d7d
6283143886518:7@s.whatsapp.net	120363388270690670@g.us	227964465754319_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a3937333238353437352c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a227845746a4b6e4f7151346474584c46364231617a69684c315a7741514674516245374f7163514a57726e553d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224251474d6a4a524163567765687658624b3548436a3679367a487237482b6144654d594a2f64336251594167227d5d7d
6283143886518:7@s.whatsapp.net	status@broadcast	17253017845988_1:0	\\x7b2253656e6465724b6579537461746573223a5b7b224b657973223a5b5d2c224b65794944223a3939393035313434372c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a22746975397241756f3978545371636a5255555862446a5869576a5735495a467474654737383868654e50453d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224265522b594632636d2f482f6f766d367659572f592f345a48644931526b4e5562325a79315674362b543854227d2c7b224b657973223a5b5d2c224b65794944223a313034323631363736342c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a223668474865415a525a416948414a3646396f2f37746d7536676f2b3459717147547a74766f41764f3043453d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224265514c5834636b745a64654d6235684c664e51336f4c57544577437549526f4243696e536a6a337072776d227d2c7b224b657973223a5b5d2c224b65794944223a3235393635333830322c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a224a4c327375417043675a6267416645685353384b5978327535485544756b756a4867326b635675793637633d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a224262704b4c36613868754b4974423571666a4c6d624567555238517856712f68774359302f6d5649442b4674227d2c7b224b657973223a5b5d2c224b65794944223a323031393237353038392c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a312c22436861696e4b6579223a22634e567a4f702b594f4142673176775065434b57594a6f4152756c6e6e6d784672514d657876697a7154733d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a22425545347346426b4c6a2b506239415678337739304943566a7a5741505a78714e6f4961566953594d734e4a227d2c7b224b657973223a5b5d2c224b65794944223a34343034313934382c2253656e646572436861696e4b6579223a7b22497465726174696f6e223a322c22436861696e4b6579223a2249716a434c495644676652626c7a2f4b544c72394246574747436b6b69674d4271326e393049596a4931593d227d2c225369676e696e674b657950726976617465223a22414141414141414141414141414141414141414141414141414141414141414141414141414141414141413d222c225369676e696e674b65795075626c6963223a2242534e704d49454c61445a47376e682f4d4b6f49707653594a69346a66372f2b783778506635314337387741227d5d7d
\.


--
-- Data for Name: whatsmeow_sessions; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_sessions (our_jid, their_id, session) FROM stdin;
6283143886518:7@s.whatsapp.net	122033006465061_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22426666556667704e676c62723647344c7437693964702b32732b61626f6f5a427a7738587375643442354d65222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a223767562f543032376c753154386b3953306f6745636563615a6473793936675556357433594164635144453d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a22425737717465684b6e7053495654703955333444547654365761572f376d77734d31376241574d776c6f6f53222c2252656d6f7465526567697374726174696f6e4944223a313630363634363334392c22526f6f744b6579223a2264755a584a6347396a653033453468536d756a386345527042647972735739523872325945564b50594c413d222c2253656e646572426173654b6579223a22426135535446345836494132306c634372706a6963775570456c426c353344742b4136495a706f57332b6c41222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a22426153526a48435267475571495a37426757645958754e434f482f4344446a6a793871344c7533737a48786a222c2253656e646572526174636865744b657950726976617465223a2232413078683038426c45334b4c774c6c47773336526e6e715147766d5638516b336e5658706653386546733d222c22436861696e4b6579223a7b224b6579223a22537138692f684e4d585a33353637452f2f42333052796975334158363832645377754e7a457a4b6b6970553d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	146025264197707_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224263366c4a336959533566424f79747a45686930636a6e68355831497643394c47342f766665365063725677222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22386a6a4a766151654f446c5059613758426b68505738426343576f2f65384c556c4c6c67497671754136413d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a2242632b4f7457506a77744c6f54344845657249366f58556f3568772b36344a6a37334c2b5974626f33563048222c2252656d6f7465526567697374726174696f6e4944223a31353132373239362c22526f6f744b6579223a225856646430362b434e5842754b474462396641316a7a7a774669656e486f50516b5255782b6932596949593d222c2253656e646572426173654b6579223a22425650544266394c2b2f78643470544479425a5972417565636d483245356e5236705257714f575475686c53222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224256366d612f744f43393275536255386f6e66734b6c79686656356e724f5467356d79472b624a4773614a62222c2253656e646572526174636865744b657950726976617465223a2269487a526d52773761756d74716756505441766d5a7955794551586e425a32657a676570315049484e454d3d222c22436861696e4b6579223a7b224b6579223a2255596a2b5257644772427a5576736d752f5667785278774a34436d454579763675726670546c4c537858343d222c22496e646578223a327d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	132272191709432_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22425145364e4146694e54463276686d75497a67324a316337614b2b476d5241537662772b6546347158586b41222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22555873724b54344d6939447142577a5645344a68474174337444364c39426348755a43362f424b714c4e6b3d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a22425877415a556a624f56315176714b564279714e4a6d56512f37697a2f364d4d73544a504470647352743851222c2252656d6f7465526567697374726174696f6e4944223a3935373233383237342c22526f6f744b6579223a226f32632f6132745753322f456b457a57545342354138694f523854384a527a76494458677232584c794e673d222c2253656e646572426173654b6579223a2242583334453963465a745664754d32694c4a32785a424c6250466a6f5548794e3236764c795a3063676e346d222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242594b6530426e636f524d6d54396a596e4c72693571377a6b47494d314b636d3970326456736455694e3176222c2253656e646572526174636865744b657950726976617465223a2263495434442b5770566439437635444a5162543454734b6861384673654173767943585075486e476230733d222c22436861696e4b6579223a7b224b6579223a227a51776373695361794d706a7352734b7265554f3771723975796a7038456e464a4b76475a415977344b673d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	262104842035423_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22426572643649696b4e6664724637696d6f366b424c652b413457664d4d4d4f67386976553955503050473849222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a226a57526b482f5a69654a475577425372315956744b414d323243594c68437431584a42517245764c4762593d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224261466e4c7a63317353783146797a4c4b326e2f392f66742b5a4d7a384762737531664962554d5048697778222c2252656d6f7465526567697374726174696f6e4944223a323034323533363935322c22526f6f744b6579223a22366550314e494a3552372f6c4d7734734e35734731616741353047715641676c6f4c4f7170784d6f7663343d222c2253656e646572426173654b6579223a224255364c4e64653344534d364130466d51586e357347447470515a444546534f483062396344364c7637526d222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242563244585a7838522f35456f51362f753474425443647a756342394135546a516745676e74356f32633044222c2253656e646572526174636865744b657950726976617465223a225349657137554c4d6942636e366976514b315a6b6a596863476f59795066414f59304b4833314a694c474d3d222c22436861696e4b6579223a7b224b6579223a224e785744565372344630374c6f79386b542f73675253543042544d733036625a4964454337646e387430593d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	21148653883564_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224266465a6351767a4231615278636b5267354e5156507272584a6235657a5a79466f49685452536b4733777a222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2232526865334444435868442b456b73697637702f7a34632f7856755947342b4e73667447496f4f62594a633d222c22496e646578223a337d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a2242624d4a6e6a6a42483341373050486f536531317448756c4538736b7541392f6b453773366b75347042686b222c2252656d6f7465526567697374726174696f6e4944223a3735343536303131342c22526f6f744b6579223a22383069696e45546d7948735a545641684f714164732f7849476748456c37484c654836356a58556f30336b3d222c2253656e646572426173654b6579223a224259425874385a55354e76527757594d63472f49394e6875496e4765336857657a78414a734b58704436356f222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242665149475537774e7650787a36575a6e58427745763072583163716f4165673067657956435a3372504171222c2253656e646572526174636865744b657950726976617465223a2255505455684b527854553570726b4259484859634337327a4b576a344942337164566a6f673858513155733d222c22436861696e4b6579223a7b224b6579223a224b7155394d4c4f366d7165556c74745050556443544c5449416f344134542f714c333032496551545557383d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	150822088396920_1:34	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224253413235467442676d545430616d7a36736e517872786e372f43644c6d3666636558686f6a703764586b57222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a226b41706250684a737945396c4c666c493453726e4d4d53324c6c6d76694d4534354e776a344e676b5851493d222c22496e646578223a327d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224264534b4964736449674a6d574569474a72726a43684d34305479784952766c455577666249317643424e31222c2252656d6f7465526567697374726174696f6e4944223a31313734322c22526f6f744b6579223a22476c3679426651704e2b307a45444f763775713075744652556e32463164476455466677646f32337651773d222c2253656e646572426173654b6579223a2242667070384b72394637726f46767142474737676c714138345457503330702b554f3139767941772f757835222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242525a666a786e6d724d444f4349454575436b6f364349485a7a6f3566374162514861664c39784c5a714933222c2253656e646572526174636865744b657950726976617465223a22514338476c696d6f71664b58666363705430764571716b4a70366b6f537239516c4e474f2f4257665556673d222c22436861696e4b6579223a7b224b6579223a227073386167426152516570596b2b75566234325454792b485866354130555759766d534d556f762b504e593d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	105488691757238_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224261503458677071736b59764d4458346934414f4a6f796e4a4342785030654976654975543553616b413168222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22422b3476764974686d64684b7a767a484e68736b6158626f66644637447646656664685a6f6e4f4a7758493d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224264584b6647796e46462b336c504d5444496e4853472f6c4246424a347a72354e4b4a4c38734f7273634a6d222c2252656d6f7465526567697374726174696f6e4944223a3738303939343132362c22526f6f744b6579223a22434f475a344f6b74633848367266534936694d75734f535448366369745a616562376442353839484935493d222c2253656e646572426173654b6579223a22425430584737434470703449302f646e3732475a366a515244694d41354d6b6d4161664a6a79473335644e6a222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a22426351777a637872445a7333435459744246374f3161394142374c6a646e313278566b6d39734e6577415631222c2253656e646572526174636865744b657950726976617465223a22634b56544a4266614f32676535316f2f426c694c3969386755496f6c6936527034727443453852353756673d222c22436861696e4b6579223a7b224b6579223a224f7667426d466671582f4254656a4c77746c2f325752485632552f4e6b6130344d796d37614777616135303d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	115895447896078_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22426545644e6a74757770466e366168442f794e47335871355875713341766a445739746e6746384338447334222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a226453792f4a4f374b6c387239792f614b64636b746343542b3678552f796e4f426b446b47343549535461553d222c22496e646578223a327d2c224d6573736167654b657973223a5b7b224369706865724b6579223a2268577777456b394d617670364141492f32392f55764f344e50304e596e502b3853354f724c3934317871773d222c224d61634b6579223a22346a502b504162582b395661424234684c434a5347686275664e4e4537475a33777934394a5a472b6949633d222c224956223a225467376e41694c4966565257776e7145366469792f773d3d222c22496e646578223a307d5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224258436b4379546636627973533962727562787168667546776337576f374c44526478503242644b2f2b7342222c2252656d6f7465526567697374726174696f6e4944223a3932353239383035302c22526f6f744b6579223a226b5162316b415a2f7838505167776c356239684f75743874352f6d364a6a524d2f75485638766836514b4d3d222c2253656e646572426173654b6579223a224255624a7638395561467564516f7a323742725065646c374b504f4f6e3650714e6d2f5a652b454b394e594b222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224252506669336461387373363744524d51614564417771427677644c79366f4f41312f4d4f777636594f356f222c2253656e646572526174636865744b657950726976617465223a222b4375314d4f7a6e436e6f6656385154353647455465364f31645157386d7152305a4e35636534764a32593d222c22436861696e4b6579223a7b224b6579223a22304d4b366935613468546a5a6263777567576e68564f3670504661382b6a793846304e48394535303850343d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	200858524491833_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22425455797949655054496833783969664f4453744244796c6c486931636a37504e38676e716259544e49354d222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22537552722f4b6e75615742355634737a4f617350614b325a375367766c3846647433525276744c535276493d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a2242545a6e4c436a486879713565556c347a38333632676849454b39434d4d763258575939775838525248356b222c2252656d6f7465526567697374726174696f6e4944223a313637383638383131322c22526f6f744b6579223a22444a56375a7331732f6a2b353444664e5456646559345546677376642b54725143393046546256415669343d222c2253656e646572426173654b6579223a224254552f782f753657783552654d43425154526d677148516e4c694b4a65444e466c6c4f68586e6a45696c35222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224263417334626c466a505746366c526b386866554b39734d476e735671435667645771484a4d496575687378222c2253656e646572526174636865744b657950726976617465223a2261444b55416f6541486e4f335079382b457354656d42634f5144644f4f635643772b67456c6b5a3975556f3d222c22436861696e4b6579223a7b224b6579223a227a475362617a6564394c7742485864755837777472762b614f4b6f413853416d587243345230664a786b343d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	206545447084155_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a2242564e422b42687058504744343166346f6666616a5148757050764b3248475a623735356f4c4b624d563852222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22724f6d707a35593354533857706e77776845676b59636270557467584d3248686b3536306b305168466c773d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a22425a6f5369496d643534566d645a6543574b6a4b617133793038596251544e446c76714875574972634d4167222c2252656d6f7465526567697374726174696f6e4944223a313736363435393234382c22526f6f744b6579223a223853645046792f7a536e37565a672f677973756e4744445a34674b367a427378596355622b37782b4341773d222c2253656e646572426173654b6579223a2242516355496c686b6c463476365841696c69514e66756c49346256586c434e75546e6b6f565473764f535973222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242663761594c4b5a4f486a37514667746c6a3471494963645456556c306d38736d4e32494756465351684670222c2253656e646572526174636865744b657950726976617465223a2236446f4c66675a514a6b586d526d564435302b70746f764d4c7a2b364665636849794f652f6a3351576b413d222c22436861696e4b6579223a7b224b6579223a22657a6e4d6b37783769684c353074304465487a3158766b383261384d4c67724442417174326550714658773d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	151612429475900_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a322c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224254642f546a4a567450444b7a785a495a494570744e434d70412b464c6e4f686e4e364b586155387a664d39222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22794f6f794f69774f317265564275544249364d474d712b495469514359714339486f63467053332b3172673d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a22425246536a34352f6c564470624c59362f53423564496e2f684e4c706e38505458746163507672622b6b4646222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2269424a437247737a4545666b594e4873367a6d44784d4b74565059627856796f763870444e414e776f6d413d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a224258505a61522b753032323847672f6d4f45624975744955564775375a316e2f582b365a61694b54702b4558222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22782b3571312b51743937556241584b676e597174372b634d76694139704d42636a7145446a65434f525a413d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a224262706f7650353177444f443661475939545339645248564e4c5052644f77634e796265734b7263744c6734222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22774c4d596154377a586d662f586f766d3076556b73747034444d534b4d6b656b66784474354576364c2b383d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a2242655a51562f6c652f34584f6f53366133524e655657526e64377843626d724677756f52694d636946415230222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2250696e347a53314855796b6776305437575135787a346e5a484a356b75444143316667746f6674417131553d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224264686d69626e3749306e597834616455313071674d496435776634654a4e69474f37445648346c39446777222c2252656d6f7465526567697374726174696f6e4944223a313433323137373930332c22526f6f744b6579223a2255665676502f65442f3444522f48656d6778427654446c537064332b3958774c436e386558326165477a633d222c2253656e646572426173654b6579223a2242537970354c46372f574c726c5636366e4935342b71795567644e4873307476386e4b7775676a4d56483039222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224258736d79733969395a4b417534456265426454313264796c6a4131456558722b354b4b656e665a427a5555222c2253656e646572526174636865744b657950726976617465223a22554145616c567247517172525335507a74716c4b3243506842302b4d6c6b532f4355533655706b305657593d222c22436861696e4b6579223a7b224b6579223a224635363479794a363278594d7435524f5842644f33753574435a384150386a4c58546c2f726f2b47552b6f3d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	139432053207269_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22425279597148713537354a3263364e427a675148525864354762453442315949685155723879357635384d47222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a225a74767a565873564d6e5935517573736d5932535148704e676f54374a49422f425057586350364e5377593d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a22425156687a77334469476e487a4372537a57656e55576f6b76325953554c7a654f4f653644775473732f5158222c2252656d6f7465526567697374726174696f6e4944223a3835303636323335352c22526f6f744b6579223a22736e45436e376273386d3971492f6c727239537255795079784e524c52684253704f4d33784a49446466553d222c2253656e646572426173654b6579223a2242544a6f52314e3056795271686453794c4a5545714c7a385555346c776e346f4d58466d4c78496b7451686e222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242543448593746714f594359397943465278787235426e6c4a4951786e4e77525171316f75564f4832426735222c2253656e646572526174636865744b657950726976617465223a224f4263705275356b6766423362536b74424b444a55662f5975336734655157737a4c4d5933313039396c413d222c22436861696e4b6579223a7b224b6579223a2256644b643241645647366e714e47636e676e50674248764b7472472f334578437968794a76722f6378374d3d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	91221296955604_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a2242576c2f3573696f633932724c33425a77464c74724c61324938472f484d7343364e6c494d50476a636c6863222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a224a49434a61524872326e31365a324972324b4b6f624b6b755a3348546e39624f4358326c684677546667553d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224262484d7331394342576d32746a6b7767374a532f4943304e356e3749693672467336654e622b6e55615131222c2252656d6f7465526567697374726174696f6e4944223a3536313739383639342c22526f6f744b6579223a22304a4243766b4473537447396437316134494f35305162543970695765744c693769597267584c354963513d222c2253656e646572426173654b6579223a2242654a64464b64325365334547734f4e2b443574512b7055674651584d777367734a4e4d613866302b634665222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242647036506a547442313767657050573064744f50437364447a795a3769333879696c536a732b4766384e6c222c2253656e646572526174636865744b657950726976617465223a224b44366272775576676f5978374f5732377758646c312f4e72624a4e6233657154346433337941764e476b3d222c22436861696e4b6579223a7b224b6579223a22556f343279616466475232773769365937443955734457753865587834766c5152724b556c4f64414f6c633d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	185014457217030_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224256773369477746743733616469634571466e3837694c4f7071646c436e596879436964513976735677395a222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22355158353074685970762f3933586c534b75546d37614c36375155726f4f78327554777270542b715a2b513d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a2242526e6669334b487741376e644665724d3776727562354448594a4b524a563478672b67527a355256517369222c2252656d6f7465526567697374726174696f6e4944223a313437303339313434362c22526f6f744b6579223a226f48484658727370416b724347674a374e7a67377373595a736571456736664e69635443584656304679673d222c2253656e646572426173654b6579223a224262764e306e7248446e4173376d3859336476582b7737656f6468676b3057476f4858644948417061516c58222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242654c416f41736b63306b44446e6c4d454a73727a326874654d7a75697a617a6949515343774337354c6372222c2253656e646572526174636865744b657950726976617465223a22325061307237586b6d78734d6244667243464a72343444424d41634b38367370772b42527a6a4863506b453d222c22436861696e4b6579223a7b224b6579223a2257693163753464734455342b794a5431414c4659733034333962487a65477731564f61376d63736f4b75773d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	227964465754319_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224253472f67455a775757797a7843702f324c6667375a773467775847634e2f4a6468322f56696d6341313939222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22617162714f735146677671694b395478734b4e2f464d6676314f37627a43624753613749734930736f796f3d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a2242644a572b597662464e7061475a48664f625934565942575a4a4174757056367462444d41662f57466a4e64222c2252656d6f7465526567697374726174696f6e4944223a313230353539393434372c22526f6f744b6579223a2269397853734d61516b5a387a5674394b4b41484154556663545a62347237366e4a65375a3873677968494d3d222c2253656e646572426173654b6579223a224255776e476171303363505a7a75764354764941514e312b6d6b2f57692f6e7a773741624676433050565250222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224258357747454c38734b6b3837372b52356f6c3258635336447a31657058577276694e32652f776155797736222c2253656e646572526174636865744b657950726976617465223a22384b76594a763356426f6547735a6e726464417a4a456b4c6a46656d5a30684f3047316f7a6f506a3445633d222c22436861696e4b6579223a7b224b6579223a227865746f2f7477446445776f4b39543932683677694263762f6d747a434b2b46365073327631346c4d4a593d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	17253017845988_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a224265735a43786630346b3374437659534f597a515538705758343171736d434e6d52754855695647704f646d222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22733266535242562b65343763574946766b5661637a45766973434667373836542f72433269507a636574513d222c22496e646578223a397d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a22425236482b745775456b4832716d59452b5344387032333235503049766f6471766d755072312f495464676d222c2252656d6f7465526567697374726174696f6e4944223a32383330323335302c22526f6f744b6579223a227936525a576a4e764b7651374151324e6f5a572f455a433930636a4445385a5454454c67423249612f63493d222c2253656e646572426173654b6579223a224254682b342f6b62706c2f5550366b7564796e44497832434433512b2b7547744f366f54552b775a6b4d3545222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242557149566663434a74487137434c763878576b6e453652534d5938617a6652694b523547576c7269667746222c2253656e646572526174636865744b657950726976617465223a22414c6956584d3334462f6446436b7130675859426b556b4c3238547a655a41667237376f6e7443762f58593d222c22436861696e4b6579223a7b224b6579223a22574177774366464242624e57785642716d2b7347786e4d56584239773832465052555358336d34306836453d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	177679206723839_1:2	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a7b225072654b65794944223a7b2256616c7565223a332c224973456d707479223a66616c73657d2c225369676e65645072654b65794944223a312c22426173654b6579223a2242513259354e38777a77424a4d732b70316373687768462f6e305a6d497757385a4e667a694462726c774931227d2c2250726576696f7573436f756e746572223a302c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a2242526d6a59737062535972686b38644a6e473550434c34594753527058306a6362632b6f4471385346625663222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a227a464c475366306a6d706549454a3871336e37506e4134305244586c3938356955754d6b646170776742303d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a22425770756554386d6975594d46396e745634314d71686a4864624c6f7a37734c4e6a31757079303038516371222c2252656d6f7465526567697374726174696f6e4944223a313932323130343737322c22526f6f744b6579223a2261386c696769527166394b7a43783661662f6b43354b46696975662b7678677168466168615a4e5337436f3d222c2253656e646572426173654b6579223a2242513259354e38777a77424a4d732b70316373687768462f6e305a6d497757385a4e667a694462726c774931222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224251532b4374662b454b71634234484353374b4d556131706b6a717838646766454c477a6466367664505177222c2253656e646572526174636865744b657950726976617465223a224150736e2f575133556a7a412f65506e687a664b792b4767474256756c37304f713332646839307277314d3d222c22436861696e4b6579223a7b224b6579223a2254674454512f6234746a4b395536444f49776b415a4348587030766d385373506461416247497477484c773d222c22496e646578223a32347d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	177679206723839_1:5	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a7b225072654b65794944223a7b2256616c7565223a3733372c224973456d707479223a66616c73657d2c225369676e65645072654b65794944223a312c22426173654b6579223a22425641644a494d45737a68394e4b69596335664172576c683678593572482f6d4b4c44634e726770686d566b227d2c2250726576696f7573436f756e746572223a302c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22425a35657761524570716b4b703235775847463775635a306c6d66456d7771613539714a554349525571354d222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2230583661374a45434f5153564346596d5467724c663477624678596532316b455a3273426c36566b4977633d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224264704467347853643348566142686a344d696a74764d4455536f32794e694346704d724c4a7a416c2f4932222c2252656d6f7465526567697374726174696f6e4944223a3233342c22526f6f744b6579223a22345a7a332f616469573458714b4a6b4a6e54614b5a6139796a2b306f5853505053674d70427946744c57513d222c2253656e646572426173654b6579223a22425641644a494d45737a68394e4b69596335664172576c683678593572482f6d4b4c44634e726770686d566b222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224266795242414878514c366849724a53596a7a58772b4b3666706831737a7a416f50574c3978776f4a686b4f222c2253656e646572526174636865744b657950726976617465223a22734f2b67374278336163345a2f2f7a68476c4b5747627633724254503677684b4c35355161416d536f30453d222c22436861696e4b6579223a7b224b6579223a222b30574372686c624c6835564a69317a2f614d5a31667969475469732b784c5a32415636776a5842674d343d222c22496e646578223a32347d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	59425402433630_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a343239343936373239352c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a2242574365685865334f70634d4b4379755577473779727a693932316974636a6b444c5a57416d564632437862222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22765968324c67526b524b65433052694f73484f6e73506e453350454c2b337a445039795a4a766a48674d6f3d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a224261637635466c69775a31374e48786d6d3368476b584f3643466b683234322f337841537847683245386833222c2252656d6f7465526567697374726174696f6e4944223a313139323333363032382c22526f6f744b6579223a2239783636314870566f4e4648496a4d447736395353303975524347314d62557155616b4a64762b3542324d3d222c2253656e646572426173654b6579223a2242564a62496d31744d456835662b4b715a50703142316c70436e58626b30776a2b4371716e51783447314e44222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a224261414831627a694364586d567a6744517a687156596b3231516c307537436f6b30593232563854524a7477222c2253656e646572526174636865744b657950726976617465223a226d4c52444178576763446e617877794e377161664f6f4441517841587059315a6c587a334d446c4d776d303d222c22436861696e4b6579223a7b224b6579223a22792b737a45304f51524b6f6f5963354f6337574d2f56436733762b67725a4f2f31334c58444b4e684245773d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
6283143886518:7@s.whatsapp.net	177679206723839_1:0	\\x7b2253657373696f6e5374617465223a7b224c6f63616c4964656e746974795075626c6963223a2242582b6e786d477133585134395748314a476c4c4f743576597138716257743171455351713062524a6b5153222c224c6f63616c526567697374726174696f6e4944223a333438373832313336362c224e6565647352656672657368223a66616c73652c2250656e64696e674b657945786368616e6765223a6e756c6c2c2250656e64696e675072654b6579223a6e756c6c2c2250726576696f7573436f756e746572223a302c225265636569766572436861696e73223a5b7b2253656e646572526174636865744b65795075626c6963223a22425a7670676e424855716d486e4b717566676a5874447638694f2b64594d47614e455445684f2b4d7359416f222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2255585859365a637538572b364a51763432767a3347656748465872653463484637494847663176495669343d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a224258766531314c55514d35667942544964486e2b484f3563723648462f4a444a364761354454695642634542222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2272395949685664583846797573725032656e3068375650313843524643437979782b7267524e38584439383d222c22496e646578223a317d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a2242592f43616b6949777241414e6e4b7663616d6c4362736c464a6b7a524158324c7432477330515948344e78222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a2266377936643037706e66524d7457456d315341703774484c6c57457177417243784a545539666d686e78633d222c22496e646578223a327d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a22426170714d556f7a51396a2f4e6570387439457175394452416f6c4548495955365a6b4b736f713745764e67222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a226e495477385339753546776a55384f64415566696f706e624232465833425450532f506b4d707a694769513d222c22496e646578223a357d2c224d6573736167654b657973223a5b5d7d2c7b2253656e646572526174636865744b65795075626c6963223a22425376696f4b36754447586f796d48632b797174726d396f38527030692b36694a54516f334e337734736767222c2253656e646572526174636865744b657950726976617465223a6e756c6c2c22436861696e4b6579223a7b224b6579223a22356939304b2f6e536a534175696265386a6959784e702b2b6f2b68354c64376b2b6c6a597554686d3438553d222c22496e646578223a327d2c224d6573736167654b657973223a5b5d7d5d2c2252656d6f74654964656e746974795075626c6963223a2242567671637374697371697849613970374e705337576d374743504f704b333374476347676e544b34704254222c2252656d6f7465526567697374726174696f6e4944223a313832303538353831302c22526f6f744b6579223a22626d774f4c4c347742554266745a543446706d382f42664b775a31316670493839366d4f686b62686938413d222c2253656e646572426173654b6579223a224252357770576f4e6879417547556f46484e34574743667848466a7371676d4a4e436177642f347a62705237222c2253656e646572436861696e223a7b2253656e646572526174636865744b65795075626c6963223a2242577271654a5133746b536565646f4266693449335a41746c4a6268464867594c415731473139484b395541222c2253656e646572526174636865744b657950726976617465223a22754c4c573679345a3066684a2f35436b525773635165332f5878424146636330626843747751766d7458343d222c22436861696e4b6579223a7b224b6579223a224a52706d667a49735834524d42376d783964756b4d474a4d6c7a2f5374595568634c572b397977674545453d222c22496e646578223a307d2c224d6573736167654b657973223a5b5d7d2c2253657373696f6e56657273696f6e223a337d2c2250726576696f7573537461746573223a5b5d7d
\.


--
-- Data for Name: whatsmeow_version; Type: TABLE DATA; Schema: public; Owner: arfcoder_user
--

COPY public.whatsmeow_version (version, compat) FROM stdin;
11	8
\.


--
-- Name: ActivityLog ActivityLog_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."ActivityLog"
    ADD CONSTRAINT "ActivityLog_pkey" PRIMARY KEY (id);


--
-- Name: CartItem CartItem_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."CartItem"
    ADD CONSTRAINT "CartItem_pkey" PRIMARY KEY (id);


--
-- Name: Category Category_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY (id);


--
-- Name: FlashSale FlashSale_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."FlashSale"
    ADD CONSTRAINT "FlashSale_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: OrderItem OrderItem_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_pkey" PRIMARY KEY (id);


--
-- Name: OrderTimeline OrderTimeline_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."OrderTimeline"
    ADD CONSTRAINT "OrderTimeline_pkey" PRIMARY KEY (id);


--
-- Name: Order Order_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_pkey" PRIMARY KEY (id);


--
-- Name: Otp Otp_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Otp"
    ADD CONSTRAINT "Otp_pkey" PRIMARY KEY (id);


--
-- Name: Product Product_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_pkey" PRIMARY KEY (id);


--
-- Name: Review Review_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_pkey" PRIMARY KEY (id);


--
-- Name: Service Service_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Service"
    ADD CONSTRAINT "Service_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: Voucher Voucher_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Voucher"
    ADD CONSTRAINT "Voucher_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: whatsmeow_app_state_mutation_macs whatsmeow_app_state_mutation_macs_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_app_state_mutation_macs
    ADD CONSTRAINT whatsmeow_app_state_mutation_macs_pkey PRIMARY KEY (jid, name, version, index_mac);


--
-- Name: whatsmeow_app_state_sync_keys whatsmeow_app_state_sync_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_app_state_sync_keys
    ADD CONSTRAINT whatsmeow_app_state_sync_keys_pkey PRIMARY KEY (jid, key_id);


--
-- Name: whatsmeow_app_state_version whatsmeow_app_state_version_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_app_state_version
    ADD CONSTRAINT whatsmeow_app_state_version_pkey PRIMARY KEY (jid, name);


--
-- Name: whatsmeow_chat_settings whatsmeow_chat_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_chat_settings
    ADD CONSTRAINT whatsmeow_chat_settings_pkey PRIMARY KEY (our_jid, chat_jid);


--
-- Name: whatsmeow_contacts whatsmeow_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_contacts
    ADD CONSTRAINT whatsmeow_contacts_pkey PRIMARY KEY (our_jid, their_jid);


--
-- Name: whatsmeow_device whatsmeow_device_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_device
    ADD CONSTRAINT whatsmeow_device_pkey PRIMARY KEY (jid);


--
-- Name: whatsmeow_event_buffer whatsmeow_event_buffer_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_event_buffer
    ADD CONSTRAINT whatsmeow_event_buffer_pkey PRIMARY KEY (our_jid, ciphertext_hash);


--
-- Name: whatsmeow_identity_keys whatsmeow_identity_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_identity_keys
    ADD CONSTRAINT whatsmeow_identity_keys_pkey PRIMARY KEY (our_jid, their_id);


--
-- Name: whatsmeow_lid_map whatsmeow_lid_map_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_lid_map
    ADD CONSTRAINT whatsmeow_lid_map_pkey PRIMARY KEY (lid);


--
-- Name: whatsmeow_lid_map whatsmeow_lid_map_pn_key; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_lid_map
    ADD CONSTRAINT whatsmeow_lid_map_pn_key UNIQUE (pn);


--
-- Name: whatsmeow_message_secrets whatsmeow_message_secrets_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_message_secrets
    ADD CONSTRAINT whatsmeow_message_secrets_pkey PRIMARY KEY (our_jid, chat_jid, sender_jid, message_id);


--
-- Name: whatsmeow_pre_keys whatsmeow_pre_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_pre_keys
    ADD CONSTRAINT whatsmeow_pre_keys_pkey PRIMARY KEY (jid, key_id);


--
-- Name: whatsmeow_privacy_tokens whatsmeow_privacy_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_privacy_tokens
    ADD CONSTRAINT whatsmeow_privacy_tokens_pkey PRIMARY KEY (our_jid, their_jid);


--
-- Name: whatsmeow_sender_keys whatsmeow_sender_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_sender_keys
    ADD CONSTRAINT whatsmeow_sender_keys_pkey PRIMARY KEY (our_jid, chat_id, sender_id);


--
-- Name: whatsmeow_sessions whatsmeow_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_sessions
    ADD CONSTRAINT whatsmeow_sessions_pkey PRIMARY KEY (our_jid, their_id);


--
-- Name: CartItem_userId_productId_key; Type: INDEX; Schema: public; Owner: arfcoder_user
--

CREATE UNIQUE INDEX "CartItem_userId_productId_key" ON public."CartItem" USING btree ("userId", "productId");


--
-- Name: Category_name_key; Type: INDEX; Schema: public; Owner: arfcoder_user
--

CREATE UNIQUE INDEX "Category_name_key" ON public."Category" USING btree (name);


--
-- Name: Order_invoiceNumber_key; Type: INDEX; Schema: public; Owner: arfcoder_user
--

CREATE UNIQUE INDEX "Order_invoiceNumber_key" ON public."Order" USING btree ("invoiceNumber");


--
-- Name: User_email_key; Type: INDEX; Schema: public; Owner: arfcoder_user
--

CREATE UNIQUE INDEX "User_email_key" ON public."User" USING btree (email);


--
-- Name: User_googleId_key; Type: INDEX; Schema: public; Owner: arfcoder_user
--

CREATE UNIQUE INDEX "User_googleId_key" ON public."User" USING btree ("googleId");


--
-- Name: Voucher_code_key; Type: INDEX; Schema: public; Owner: arfcoder_user
--

CREATE UNIQUE INDEX "Voucher_code_key" ON public."Voucher" USING btree (code);


--
-- Name: ActivityLog ActivityLog_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."ActivityLog"
    ADD CONSTRAINT "ActivityLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CartItem CartItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."CartItem"
    ADD CONSTRAINT "CartItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: CartItem CartItem_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."CartItem"
    ADD CONSTRAINT "CartItem_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: FlashSale FlashSale_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."FlashSale"
    ADD CONSTRAINT "FlashSale_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Message Message_senderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OrderItem OrderItem_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."Order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: OrderItem OrderItem_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."OrderItem"
    ADD CONSTRAINT "OrderItem_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: OrderTimeline OrderTimeline_orderId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."OrderTimeline"
    ADD CONSTRAINT "OrderTimeline_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES public."Order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Order Order_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Order"
    ADD CONSTRAINT "Order_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Otp Otp_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Otp"
    ADD CONSTRAINT "Otp_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Product Product_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Product"
    ADD CONSTRAINT "Product_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public."Category"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Review Review_productId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_productId_fkey" FOREIGN KEY ("productId") REFERENCES public."Product"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Review Review_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public."Review"
    ADD CONSTRAINT "Review_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."User"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: whatsmeow_app_state_mutation_macs whatsmeow_app_state_mutation_macs_jid_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_app_state_mutation_macs
    ADD CONSTRAINT whatsmeow_app_state_mutation_macs_jid_name_fkey FOREIGN KEY (jid, name) REFERENCES public.whatsmeow_app_state_version(jid, name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_app_state_sync_keys whatsmeow_app_state_sync_keys_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_app_state_sync_keys
    ADD CONSTRAINT whatsmeow_app_state_sync_keys_jid_fkey FOREIGN KEY (jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_app_state_version whatsmeow_app_state_version_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_app_state_version
    ADD CONSTRAINT whatsmeow_app_state_version_jid_fkey FOREIGN KEY (jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_chat_settings whatsmeow_chat_settings_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_chat_settings
    ADD CONSTRAINT whatsmeow_chat_settings_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_contacts whatsmeow_contacts_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_contacts
    ADD CONSTRAINT whatsmeow_contacts_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_event_buffer whatsmeow_event_buffer_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_event_buffer
    ADD CONSTRAINT whatsmeow_event_buffer_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_identity_keys whatsmeow_identity_keys_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_identity_keys
    ADD CONSTRAINT whatsmeow_identity_keys_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_message_secrets whatsmeow_message_secrets_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_message_secrets
    ADD CONSTRAINT whatsmeow_message_secrets_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_pre_keys whatsmeow_pre_keys_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_pre_keys
    ADD CONSTRAINT whatsmeow_pre_keys_jid_fkey FOREIGN KEY (jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_sender_keys whatsmeow_sender_keys_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_sender_keys
    ADD CONSTRAINT whatsmeow_sender_keys_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: whatsmeow_sessions whatsmeow_sessions_our_jid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arfcoder_user
--

ALTER TABLE ONLY public.whatsmeow_sessions
    ADD CONSTRAINT whatsmeow_sessions_our_jid_fkey FOREIGN KEY (our_jid) REFERENCES public.whatsmeow_device(jid) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: arfcoder_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict f72R2n7acrgkD1Jnaq9FRIEWE1vAPAS7XCiBz3uuTXjuqRWrQtmdAH4dK4aF5wX

