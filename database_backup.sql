--
-- PostgreSQL database dump
--

\restrict s7I7wQuesVwcJEvcx7XAtooOG8VhYf65EIPkkKLVePiYZzGmQWrBc86IXtNj88I

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

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
-- Name: timescaledb; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS timescaledb WITH SCHEMA public;


--
-- Name: EXTENSION timescaledb; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION timescaledb IS 'Enables scalable inserts and complex queries for time-series data (Community Edition)';


--
-- Name: reset_paper_trading_account(numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.reset_paper_trading_account(IN new_balance numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- 1. Kembalikan kas ke nominal parameter baru pada user_id = 1
    UPDATE virtual_account 
    SET cash_balance_idr = new_balance, updated_at = NOW()
    WHERE user_id = 1;
    
    -- Jika user belum ada (inisialisasi awal), buat baris baru
    IF NOT FOUND THEN
        INSERT INTO virtual_account (user_id, cash_balance_idr) VALUES (1, new_balance);
    END IF;

    -- 2. Bersihkan seluruh kepemilikan saham dari simulasi sebelumnya
    DELETE FROM virtual_portfolio;
    
    -- 3. Catat aksi pembersihan sistem ke log audit bursa
    INSERT INTO bot_orders (ticker, side, price, quantity_lot, trigger_reason, status, broker_order_ref)
    VALUES ('SYSTEM', 'NONE', 0, 0, CONCAT('[RESET] Akun simulasi disetel ulang dengan modal awal baru: Rp ', new_balance), 'SUCCESS', 'SYSTEM_RESET');
END;
$$;


ALTER PROCEDURE public.reset_paper_trading_account(IN new_balance numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: market_trades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.market_trades (
    "time" timestamp with time zone NOT NULL,
    ticker character varying(10) NOT NULL,
    price numeric NOT NULL,
    volume integer NOT NULL,
    buyer_broker character varying(5),
    seller_broker character varying(5),
    trade_type character varying(10)
);


ALTER TABLE public.market_trades OWNER TO postgres;

--
-- Name: _hyper_1_3_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_1_3_chunk (
    CONSTRAINT constraint_3 CHECK ((("time" >= '2026-06-11 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-06-18 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.market_trades);


ALTER TABLE _timescaledb_internal._hyper_1_3_chunk OWNER TO postgres;

--
-- Name: _hyper_1_4_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_1_4_chunk (
    CONSTRAINT constraint_4 CHECK ((("time" >= '2026-06-18 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-06-25 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.market_trades);


ALTER TABLE _timescaledb_internal._hyper_1_4_chunk OWNER TO postgres;

--
-- Name: _hyper_1_5_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_1_5_chunk (
    CONSTRAINT constraint_5 CHECK ((("time" >= '2026-06-25 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-07-02 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.market_trades);


ALTER TABLE _timescaledb_internal._hyper_1_5_chunk OWNER TO postgres;

--
-- Name: _hyper_1_6_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_1_6_chunk (
    CONSTRAINT constraint_6 CHECK ((("time" >= '2026-07-02 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-07-09 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.market_trades);


ALTER TABLE _timescaledb_internal._hyper_1_6_chunk OWNER TO postgres;

--
-- Name: _hyper_1_7_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_1_7_chunk (
    CONSTRAINT constraint_7 CHECK ((("time" >= '2026-07-09 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-07-16 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.market_trades);


ALTER TABLE _timescaledb_internal._hyper_1_7_chunk OWNER TO postgres;

--
-- Name: order_book_snapshots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_book_snapshots (
    "time" timestamp with time zone NOT NULL,
    ticker character varying(10) NOT NULL,
    price numeric NOT NULL,
    type character varying(4) NOT NULL,
    total_volume_lot integer NOT NULL,
    queue_count integer NOT NULL
);


ALTER TABLE public.order_book_snapshots OWNER TO postgres;

--
-- Name: _hyper_2_8_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_2_8_chunk (
    CONSTRAINT constraint_8 CHECK ((("time" >= '2026-07-09 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-07-16 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.order_book_snapshots);


ALTER TABLE _timescaledb_internal._hyper_2_8_chunk OWNER TO postgres;

--
-- Name: global_sentiment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.global_sentiment (
    "time" timestamp with time zone NOT NULL,
    index_name character varying(20) NOT NULL,
    last_price numeric NOT NULL,
    daily_change_percent numeric NOT NULL
);


ALTER TABLE public.global_sentiment OWNER TO postgres;

--
-- Name: _hyper_3_1_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_3_1_chunk (
    CONSTRAINT constraint_1 CHECK ((("time" >= '2026-07-09 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-07-16 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.global_sentiment);


ALTER TABLE _timescaledb_internal._hyper_3_1_chunk OWNER TO postgres;

--
-- Name: foreign_flow_ihsg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.foreign_flow_ihsg (
    "time" timestamp with time zone NOT NULL,
    ticker character varying(10) NOT NULL,
    foreign_buy_volume integer NOT NULL,
    foreign_sell_volume integer NOT NULL,
    net_foreign_val_idr bigint NOT NULL
);


ALTER TABLE public.foreign_flow_ihsg OWNER TO postgres;

--
-- Name: _hyper_4_2_chunk; Type: TABLE; Schema: _timescaledb_internal; Owner: postgres
--

CREATE TABLE _timescaledb_internal._hyper_4_2_chunk (
    CONSTRAINT constraint_2 CHECK ((("time" >= '2026-07-09 07:00:00+07'::timestamp with time zone) AND ("time" < '2026-07-16 07:00:00+07'::timestamp with time zone)))
)
INHERITS (public.foreign_flow_ihsg);


ALTER TABLE _timescaledb_internal._hyper_4_2_chunk OWNER TO postgres;

--
-- Name: app_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_notifications (
    id integer NOT NULL,
    "time" timestamp with time zone DEFAULT now() NOT NULL,
    title character varying(100) NOT NULL,
    message text NOT NULL,
    type character varying(20) NOT NULL,
    is_read boolean DEFAULT false
);


ALTER TABLE public.app_notifications OWNER TO postgres;

--
-- Name: app_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_notifications_id_seq OWNER TO postgres;

--
-- Name: app_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_notifications_id_seq OWNED BY public.app_notifications.id;


--
-- Name: bot_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bot_orders (
    order_id integer NOT NULL,
    "time" timestamp with time zone DEFAULT now() NOT NULL,
    ticker character varying(10) NOT NULL,
    side character varying(4) NOT NULL,
    price numeric NOT NULL,
    quantity_lot integer NOT NULL,
    trigger_reason text,
    status character varying(15) NOT NULL,
    broker_order_ref character varying(50)
);


ALTER TABLE public.bot_orders OWNER TO postgres;

--
-- Name: bot_orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bot_orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bot_orders_order_id_seq OWNER TO postgres;

--
-- Name: bot_orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bot_orders_order_id_seq OWNED BY public.bot_orders.order_id;


--
-- Name: equity_performance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equity_performance (
    date date NOT NULL,
    total_equity numeric NOT NULL,
    daily_pnl numeric NOT NULL,
    daily_pnl_percent numeric NOT NULL,
    total_trades integer NOT NULL,
    winning_trades integer NOT NULL,
    losing_trades integer NOT NULL,
    win_rate numeric NOT NULL,
    profit_factor numeric NOT NULL,
    max_drawdown numeric NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.equity_performance OWNER TO postgres;

--
-- Name: idx_holidays; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.idx_holidays (
    holiday_date date NOT NULL,
    description character varying(100) NOT NULL
);


ALTER TABLE public.idx_holidays OWNER TO postgres;

--
-- Name: negotiated_market_trades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.negotiated_market_trades (
    "time" timestamp with time zone NOT NULL,
    ticker character varying(10) NOT NULL,
    price numeric NOT NULL,
    volume integer NOT NULL,
    buyer_broker character varying(5),
    seller_broker character varying(5),
    total_value_idr bigint NOT NULL
);


ALTER TABLE public.negotiated_market_trades OWNER TO postgres;

--
-- Name: stress_test_scenarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stress_test_scenarios (
    scenario_id integer NOT NULL,
    scenario_name character varying(50) NOT NULL,
    price_drop_multiplier numeric NOT NULL,
    liquidity_drain_ratio numeric NOT NULL,
    volume_spike_multiplier integer NOT NULL
);


ALTER TABLE public.stress_test_scenarios OWNER TO postgres;

--
-- Name: stress_test_scenarios_scenario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stress_test_scenarios_scenario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stress_test_scenarios_scenario_id_seq OWNER TO postgres;

--
-- Name: stress_test_scenarios_scenario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stress_test_scenarios_scenario_id_seq OWNED BY public.stress_test_scenarios.scenario_id;


--
-- Name: user_portfolio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_portfolio (
    ticker character varying(10) NOT NULL,
    avg_buy_price numeric NOT NULL,
    current_lot_qty integer DEFAULT 0 NOT NULL,
    total_invested_idr bigint DEFAULT 0 NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_portfolio OWNER TO postgres;

--
-- Name: virtual_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.virtual_account (
    user_id integer NOT NULL,
    cash_balance_idr numeric DEFAULT 100000000.00 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.virtual_account OWNER TO postgres;

--
-- Name: virtual_account_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.virtual_account_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.virtual_account_user_id_seq OWNER TO postgres;

--
-- Name: virtual_account_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.virtual_account_user_id_seq OWNED BY public.virtual_account.user_id;


--
-- Name: virtual_portfolio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.virtual_portfolio (
    ticker character varying(10) NOT NULL,
    avg_buy_price numeric NOT NULL,
    current_lot_qty integer NOT NULL,
    total_value_idr numeric NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.virtual_portfolio OWNER TO postgres;

--
-- Name: app_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_notifications ALTER COLUMN id SET DEFAULT nextval('public.app_notifications_id_seq'::regclass);


--
-- Name: bot_orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_orders ALTER COLUMN order_id SET DEFAULT nextval('public.bot_orders_order_id_seq'::regclass);


--
-- Name: stress_test_scenarios scenario_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stress_test_scenarios ALTER COLUMN scenario_id SET DEFAULT nextval('public.stress_test_scenarios_scenario_id_seq'::regclass);


--
-- Name: virtual_account user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.virtual_account ALTER COLUMN user_id SET DEFAULT nextval('public.virtual_account_user_id_seq'::regclass);


--
-- Data for Name: hypertable; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.hypertable (id, schema_name, table_name, associated_schema_name, associated_table_prefix, num_dimensions, chunk_sizing_func_schema, chunk_sizing_func_name, chunk_target_size, compression_state, compressed_hypertable_id, status) FROM stdin;
1	public	market_trades	_timescaledb_internal	_hyper_1	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
2	public	order_book_snapshots	_timescaledb_internal	_hyper_2	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
3	public	global_sentiment	_timescaledb_internal	_hyper_3	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
4	public	foreign_flow_ihsg	_timescaledb_internal	_hyper_4	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
5	public	negotiated_market_trades	_timescaledb_internal	_hyper_5	1	_timescaledb_functions	calculate_chunk_interval	0	0	\N	0
\.


--
-- Data for Name: bgw_job; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.bgw_job (id, application_name, schedule_interval, max_runtime, max_retries, retry_period, proc_schema, proc_name, owner, scheduled, fixed_schedule, initial_start, hypertable_id, config, check_schema, check_name, timezone) FROM stdin;
\.


--
-- Data for Name: chunk; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk (id, hypertable_id, schema_name, table_name, compressed_chunk_id, status, osm_chunk, creation_time) FROM stdin;
1	3	_timescaledb_internal	_hyper_3_1_chunk	\N	0	f	2026-07-15 01:29:50.825327+07
2	4	_timescaledb_internal	_hyper_4_2_chunk	\N	0	f	2026-07-15 01:29:50.846081+07
3	1	_timescaledb_internal	_hyper_1_3_chunk	\N	0	f	2026-07-15 01:30:01.920265+07
4	1	_timescaledb_internal	_hyper_1_4_chunk	\N	0	f	2026-07-15 01:30:01.94316+07
5	1	_timescaledb_internal	_hyper_1_5_chunk	\N	0	f	2026-07-15 01:30:01.959934+07
6	1	_timescaledb_internal	_hyper_1_6_chunk	\N	0	f	2026-07-15 01:30:01.978355+07
7	1	_timescaledb_internal	_hyper_1_7_chunk	\N	0	f	2026-07-15 01:30:01.997886+07
8	2	_timescaledb_internal	_hyper_2_8_chunk	\N	0	f	2026-07-15 01:30:02.019995+07
\.


--
-- Data for Name: chunk_column_stats; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.chunk_column_stats (id, hypertable_id, chunk_id, column_name, range_start, range_end, valid) FROM stdin;
\.


--
-- Data for Name: compression_chunk_size; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.compression_chunk_size (chunk_id, compressed_chunk_id, uncompressed_heap_size, uncompressed_toast_size, uncompressed_index_size, compressed_heap_size, compressed_toast_size, compressed_index_size, numrows_pre_compression, numrows_post_compression, numrows_frozen_immediately) FROM stdin;
\.


--
-- Data for Name: compression_settings; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.compression_settings (relid, compress_relid, segmentby, orderby, orderby_desc, orderby_nullsfirst, index) FROM stdin;
\.


--
-- Data for Name: continuous_agg; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_agg (mat_hypertable_id, raw_hypertable_id, parent_mat_hypertable_id, user_view_schema, user_view_name, partial_view_schema, partial_view_name, direct_view_schema, direct_view_name, materialized_only, schema_change_timestamp) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_bucket_function; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_bucket_function (mat_hypertable_id, bucket_func, bucket_width, bucket_origin, bucket_offset, bucket_timezone, bucket_fixed_width) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_hypertable_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_hypertable_invalidation_log (hypertable_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_invalidation_threshold; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_invalidation_threshold (hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_jobs_refresh_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_jobs_refresh_ranges (materialization_id, start_range, end_range, pid, job_id, created_at) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_invalidation_log; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_materialization_invalidation_log (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_materialization_ranges; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_materialization_ranges (materialization_id, lowest_modified_value, greatest_modified_value) FROM stdin;
\.


--
-- Data for Name: continuous_aggs_watermark; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.continuous_aggs_watermark (mat_hypertable_id, watermark) FROM stdin;
\.


--
-- Data for Name: dimension; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.dimension (id, hypertable_id, column_name, column_type, aligned, num_slices, partitioning_func_schema, partitioning_func, interval_length, compress_interval_length, integer_now_func_schema, integer_now_func) FROM stdin;
1	1	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
2	2	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
3	3	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
4	4	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
5	5	time	timestamp with time zone	t	\N	\N	\N	604800000000	\N	\N	\N
\.


--
-- Data for Name: dimension_slice; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.dimension_slice (id, chunk_id, dimension_id, range_start, range_end) FROM stdin;
1	1	3	1783555200000000	1784160000000000
2	2	4	1783555200000000	1784160000000000
3	3	1	1781136000000000	1781740800000000
4	4	1	1781740800000000	1782345600000000
5	5	1	1782345600000000	1782950400000000
6	6	1	1782950400000000	1783555200000000
7	7	1	1783555200000000	1784160000000000
8	8	2	1783555200000000	1784160000000000
\.


--
-- Data for Name: metadata; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.metadata (key, value, include_in_telemetry) FROM stdin;
install_timestamp	2026-07-15 00:11:06.212533+07	t
timescaledb_version	2.28.2	f
exported_uuid	c9fa53a9-9014-4a27-aa1c-d85198506520	t
\.


--
-- Data for Name: tablespace; Type: TABLE DATA; Schema: _timescaledb_catalog; Owner: postgres
--

COPY _timescaledb_catalog.tablespace (id, hypertable_id, tablespace_name) FROM stdin;
\.


--
-- Data for Name: _hyper_1_3_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_1_3_chunk ("time", ticker, price, volume, buyer_broker, seller_broker, trade_type) FROM stdin;
2026-06-16 01:30:01.914253+07	BBCA	2256.38657622666	637383	BBRI	BBNI	HAKA
2026-06-17 01:30:01.914253+07	BBCA	2218.498694107549	926532	BBRI	BBNI	HAKI
2026-06-18 01:30:01.914253+07	BBCA	2255.6239814610826	1212329	BBRI	BBNI	HAKA
2026-06-16 01:30:02.04616+07	BBRI	5480.656187921415	760742	BBRI	BBNI	HAKI
2026-06-17 01:30:02.04616+07	BBRI	5650.605989781882	1242235	BBRI	BBNI	HAKA
2026-06-18 01:30:02.04616+07	BBRI	5521.655512928598	1043732	BBRI	BBNI	HAKI
2026-06-16 01:30:02.098339+07	BMRI	1254.3484224034037	1047843	BBRI	BBNI	HAKA
2026-06-17 01:30:02.098339+07	BMRI	1236.176158536416	1218773	BBRI	BBNI	HAKI
2026-06-18 01:30:02.098339+07	BMRI	1238.65039774577	578094	BBRI	BBNI	HAKA
2026-06-16 01:30:02.137016+07	TLKM	4342.300787205278	895208	BBRI	BBNI	HAKI
2026-06-17 01:30:02.137016+07	TLKM	4497.517299499368	864026	BBRI	BBNI	HAKA
2026-06-18 01:30:02.137016+07	TLKM	4413.937385643568	896385	BBRI	BBNI	HAKI
2026-06-16 01:30:02.179406+07	ASII	3952.7553865561936	1264744	BBRI	BBNI	HAKI
2026-06-17 01:30:02.179406+07	ASII	3945.104281930851	1178399	BBRI	BBNI	HAKI
2026-06-18 01:30:02.179406+07	ASII	3954.090202327476	902011	BBRI	BBNI	HAKA
\.


--
-- Data for Name: _hyper_1_4_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_1_4_chunk ("time", ticker, price, volume, buyer_broker, seller_broker, trade_type) FROM stdin;
2026-06-19 01:30:01.914253+07	BBCA	2277.6962706380586	726669	BBRI	BBNI	HAKA
2026-06-22 01:30:01.914253+07	BBCA	2367.896361076863	1299375	BBRI	BBNI	HAKA
2026-06-23 01:30:01.914253+07	BBCA	2373.214182297264	1183147	BBRI	BBNI	HAKA
2026-06-24 01:30:01.914253+07	BBCA	2333.6819150785755	740630	BBRI	BBNI	HAKI
2026-06-25 01:30:01.914253+07	BBCA	2244.0813514530987	1243362	BBRI	BBNI	HAKI
2026-06-19 01:30:02.04616+07	BBRI	5574.753408475629	1194066	BBRI	BBNI	HAKA
2026-06-22 01:30:02.04616+07	BBRI	5624.41718761148	895775	BBRI	BBNI	HAKA
2026-06-23 01:30:02.04616+07	BBRI	5749.845055653426	1053727	BBRI	BBNI	HAKA
2026-06-24 01:30:02.04616+07	BBRI	5712.503650696975	979283	BBRI	BBNI	HAKI
2026-06-25 01:30:02.04616+07	BBRI	5707.566796059808	949747	BBRI	BBNI	HAKI
2026-06-19 01:30:02.098339+07	BMRI	1251.2870184258165	824691	BBRI	BBNI	HAKA
2026-06-22 01:30:02.098339+07	BMRI	1281.6446288149375	768055	BBRI	BBNI	HAKA
2026-06-23 01:30:02.098339+07	BMRI	1276.6052890216058	815763	BBRI	BBNI	HAKI
2026-06-24 01:30:02.098339+07	BMRI	1302.6365886409567	1316277	BBRI	BBNI	HAKA
2026-06-25 01:30:02.098339+07	BMRI	1344.4930305750358	1049895	BBRI	BBNI	HAKA
2026-06-19 01:30:02.137016+07	TLKM	4400.027546610233	1119641	BBRI	BBNI	HAKI
2026-06-22 01:30:02.137016+07	TLKM	4490.08508936258	887494	BBRI	BBNI	HAKA
2026-06-23 01:30:02.137016+07	TLKM	4490.630648411882	949031	BBRI	BBNI	HAKA
2026-06-24 01:30:02.137016+07	TLKM	4506.288652812208	1101293	BBRI	BBNI	HAKA
2026-06-25 01:30:02.137016+07	TLKM	4531.456890083386	845438	BBRI	BBNI	HAKA
2026-06-19 01:30:02.179406+07	ASII	3876.659893537065	965480	BBRI	BBNI	HAKI
2026-06-22 01:30:02.179406+07	ASII	3866.3593945236917	1052158	BBRI	BBNI	HAKI
2026-06-23 01:30:02.179406+07	ASII	3677.5696566883767	1029483	BBRI	BBNI	HAKI
2026-06-24 01:30:02.179406+07	ASII	3636.4081683723475	912208	BBRI	BBNI	HAKI
2026-06-25 01:30:02.179406+07	ASII	3717.907635009231	1044899	BBRI	BBNI	HAKA
\.


--
-- Data for Name: _hyper_1_5_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_1_5_chunk ("time", ticker, price, volume, buyer_broker, seller_broker, trade_type) FROM stdin;
2026-06-26 01:30:01.914253+07	BBCA	2172.449694653545	1132952	BBRI	BBNI	HAKI
2026-06-29 01:30:01.914253+07	BBCA	2163.05293791151	1243268	BBRI	BBNI	HAKI
2026-06-30 01:30:01.914253+07	BBCA	2214.2950455701034	990005	BBRI	BBNI	HAKA
2026-07-01 01:30:01.914253+07	BBCA	2256.0662338097345	1066653	BBRI	BBNI	HAKA
2026-07-02 01:30:01.914253+07	BBCA	2243.5882534325283	1126594	BBRI	BBNI	HAKI
2026-06-26 01:30:02.04616+07	BBRI	5579.634498313838	1400868	BBRI	BBNI	HAKI
2026-06-29 01:30:02.04616+07	BBRI	5423.170824381699	864722	BBRI	BBNI	HAKI
2026-06-30 01:30:02.04616+07	BBRI	5556.567857259085	770631	BBRI	BBNI	HAKA
2026-07-01 01:30:02.04616+07	BBRI	5422.976473577394	1365500	BBRI	BBNI	HAKI
2026-07-02 01:30:02.04616+07	BBRI	5470.163895841421	1198607	BBRI	BBNI	HAKA
2026-06-26 01:30:02.098339+07	BMRI	1392.3830211471243	899531	BBRI	BBNI	HAKA
2026-06-29 01:30:02.098339+07	BMRI	1424.2747808988483	981874	BBRI	BBNI	HAKA
2026-06-30 01:30:02.098339+07	BMRI	1386.6580314713308	807675	BBRI	BBNI	HAKI
2026-07-01 01:30:02.098339+07	BMRI	1378.1602000660798	1104337	BBRI	BBNI	HAKI
2026-07-02 01:30:02.098339+07	BMRI	1390.1473755832585	1084731	BBRI	BBNI	HAKA
2026-06-26 01:30:02.137016+07	TLKM	4391.996841345724	937086	BBRI	BBNI	HAKI
2026-06-29 01:30:02.137016+07	TLKM	4385.288118258822	1054003	BBRI	BBNI	HAKI
2026-06-30 01:30:02.137016+07	TLKM	4528.382320419623	1248526	BBRI	BBNI	HAKA
2026-07-01 01:30:02.137016+07	TLKM	4526.363427358681	891789	BBRI	BBNI	HAKI
2026-07-02 01:30:02.137016+07	TLKM	4618.828202583232	855559	BBRI	BBNI	HAKA
2026-06-26 01:30:02.179406+07	ASII	3768.410868181149	1087288	BBRI	BBNI	HAKA
2026-06-29 01:30:02.179406+07	ASII	3678.5369699140483	1054252	BBRI	BBNI	HAKI
2026-06-30 01:30:02.179406+07	ASII	3656.6314622870073	1212116	BBRI	BBNI	HAKI
2026-07-01 01:30:02.179406+07	ASII	3689.350193247111	913625	BBRI	BBNI	HAKA
2026-07-02 01:30:02.179406+07	ASII	3738.5753870845338	1117834	BBRI	BBNI	HAKA
2026-06-27 10:37:55.029475+07	BBCA	4101.007322523643	52279	BBCA	BMRI	HAKI
2026-06-27 09:37:55.029475+07	BBCA	4091.6302104897704	63415	BBCA	BMRI	HAKI
2026-06-27 08:24:55.029475+07	BBCA	4112.300088601487	34613	BBCA	BMRI	HAKA
2026-06-27 07:46:55.029475+07	BBCA	4117.003786954577	41932	BBCA	BMRI	HAKA
2026-06-27 06:08:55.029475+07	BBCA	4123.435564213835	35902	BBCA	BMRI	HAKA
2026-06-27 05:57:55.029475+07	BBCA	4131.49670657384	55215	BBCA	BMRI	HAKA
2026-06-27 05:04:55.029475+07	BBCA	4127.1892804667295	56745	BBCA	BMRI	HAKI
2026-06-27 03:49:55.029475+07	BBCA	4119.0529092443685	37940	BBCA	BMRI	HAKI
2026-06-27 02:48:55.029475+07	BBCA	4118.9082194317525	35680	BBCA	BMRI	HAKI
2026-06-27 01:57:55.029475+07	BBCA	4110.186514434866	66344	BBCA	BMRI	HAKI
2026-06-27 00:30:55.029475+07	BBCA	4103.985112921655	35773	BBCA	BMRI	HAKI
2026-06-26 23:41:55.029475+07	BBCA	4104.560108128476	49098	BBCA	BMRI	HAKA
2026-06-26 22:28:55.029475+07	BBCA	4123.340540085461	51687	BBCA	BMRI	HAKA
2026-06-26 21:05:55.029475+07	BBCA	4114.726882719024	48043	BBCA	BMRI	HAKI
2026-06-26 20:27:55.029475+07	BBCA	4124.284447468789	53252	BBCA	BMRI	HAKA
2026-06-26 19:46:55.029475+07	BBCA	4119.714085096792	66779	BBCA	BMRI	HAKI
2026-06-26 18:06:55.029475+07	BBCA	4109.980908176	52542	BBCA	BMRI	HAKI
2026-06-26 17:43:55.029475+07	BBCA	4123.313999868238	38709	BBCA	BMRI	HAKA
2026-06-26 16:16:55.029475+07	BBCA	4124.690348666785	53566	BBCA	BMRI	HAKA
2026-06-26 15:14:55.029475+07	BBCA	4121.806722914339	50887	BBCA	BMRI	HAKI
2026-06-28 10:27:55.029475+07	BBCA	4130.928385155997	51021	BBCA	BMRI	HAKA
2026-06-28 09:12:55.029475+07	BBCA	4119.074821318572	35225	BBCA	BMRI	HAKI
2026-06-28 08:31:55.029475+07	BBCA	4103.7490293274395	58408	BBCA	BMRI	HAKI
2026-06-28 08:01:55.029475+07	BBCA	4099.845016892304	59943	BBCA	BMRI	HAKI
2026-06-28 06:09:55.029475+07	BBCA	4107.116997700082	57677	BBCA	BMRI	HAKA
2026-06-28 05:34:55.029475+07	BBCA	4089.2217721010384	33063	BBCA	BMRI	HAKI
2026-06-28 04:48:55.029475+07	BBCA	4091.8794664177854	51846	BBCA	BMRI	HAKA
2026-06-28 03:16:55.029475+07	BBCA	4099.921668482319	45003	BBCA	BMRI	HAKA
2026-06-28 02:54:55.029475+07	BBCA	4098.112459095156	50916	BBCA	BMRI	HAKI
2026-06-28 01:37:55.029475+07	BBCA	4101.970353733986	52125	BBCA	BMRI	HAKA
2026-06-28 00:51:55.029475+07	BBCA	4103.612163836941	49278	BBCA	BMRI	HAKA
2026-06-27 23:55:55.029475+07	BBCA	4113.416139782406	62558	BBCA	BMRI	HAKA
2026-06-27 22:50:55.029475+07	BBCA	4115.457548496441	56315	BBCA	BMRI	HAKA
2026-06-27 21:08:55.029475+07	BBCA	4123.618765372031	27792	BBCA	BMRI	HAKA
2026-06-27 20:21:55.029475+07	BBCA	4121.0831448542085	45109	BBCA	BMRI	HAKI
2026-06-27 19:33:55.029475+07	BBCA	4131.317910194503	46534	BBCA	BMRI	HAKA
2026-06-27 18:58:55.029475+07	BBCA	4132.980368431755	65501	BBCA	BMRI	HAKA
2026-06-27 17:28:55.029475+07	BBCA	4127.740259189116	43062	BBCA	BMRI	HAKI
2026-06-27 16:13:55.029475+07	BBCA	4131.671599781096	34093	BBCA	BMRI	HAKA
2026-06-27 15:51:55.029475+07	BBCA	4128.664429171819	60620	BBCA	BMRI	HAKI
2026-06-29 10:41:55.029475+07	BBCA	4127.17413106836	58235	BBCA	BMRI	HAKI
2026-06-29 09:57:55.029475+07	BBCA	4119.73417544825	48002	BBCA	BMRI	HAKI
2026-06-29 08:34:55.029475+07	BBCA	4124.208549132536	38595	BBCA	BMRI	HAKA
2026-06-29 07:40:55.029475+07	BBCA	4118.26956141336	54919	BBCA	BMRI	HAKI
2026-06-29 06:05:55.029475+07	BBCA	4118.350637941219	48632	BBCA	BMRI	HAKA
2026-06-29 05:28:55.029475+07	BBCA	4115.679166146612	56972	BBCA	BMRI	HAKI
2026-06-29 04:13:55.029475+07	BBCA	4102.351120378409	63037	BBCA	BMRI	HAKI
2026-06-29 03:30:55.029475+07	BBCA	4104.269263671736	47157	BBCA	BMRI	HAKA
2026-06-29 02:56:55.029475+07	BBCA	4110.68342804918	39795	BBCA	BMRI	HAKA
2026-06-29 01:19:55.029475+07	BBCA	4119.775310110615	53830	BBCA	BMRI	HAKA
2026-06-29 01:04:55.029475+07	BBCA	4125.9794443120045	44495	BBCA	BMRI	HAKA
2026-06-28 23:05:55.029475+07	BBCA	4131.929554736253	59812	BBCA	BMRI	HAKA
2026-06-28 22:41:55.029475+07	BBCA	4119.935708572816	42797	BBCA	BMRI	HAKI
2026-06-28 21:12:55.029475+07	BBCA	4124.425663294069	42865	BBCA	BMRI	HAKA
2026-06-28 20:37:55.029475+07	BBCA	4120.733968134591	55600	BBCA	BMRI	HAKI
2026-06-28 19:18:55.029475+07	BBCA	4117.041651107665	44786	BBCA	BMRI	HAKI
2026-06-28 18:31:55.029475+07	BBCA	4111.941540941346	44901	BBCA	BMRI	HAKI
2026-06-28 17:07:55.029475+07	BBCA	4124.444853197473	55853	BBCA	BMRI	HAKA
2026-06-28 16:32:55.029475+07	BBCA	4126.519305530316	46843	BBCA	BMRI	HAKA
2026-06-28 15:07:55.029475+07	BBCA	4127.646322166377	55568	BBCA	BMRI	HAKA
2026-06-30 10:58:55.029475+07	BBCA	4134.094886124877	37807	BBCA	BMRI	HAKA
2026-06-30 10:01:55.029475+07	BBCA	4127.212067513743	54647	BBCA	BMRI	HAKI
2026-06-30 08:35:55.029475+07	BBCA	4129.821121593246	34911	BBCA	BMRI	HAKA
2026-06-30 07:51:55.029475+07	BBCA	4120.220964047952	48494	BBCA	BMRI	HAKI
2026-06-30 06:15:55.029475+07	BBCA	4120.9511673493935	59335	BBCA	BMRI	HAKA
2026-06-30 05:26:55.029475+07	BBCA	4117.166030825949	37852	BBCA	BMRI	HAKI
2026-06-30 04:49:55.029475+07	BBCA	4109.708962433602	46084	BBCA	BMRI	HAKI
2026-06-30 03:22:55.029475+07	BBCA	4121.59381401536	42960	BBCA	BMRI	HAKA
2026-06-30 02:11:55.029475+07	BBCA	4125.030367188394	58692	BBCA	BMRI	HAKA
2026-06-30 01:15:55.029475+07	BBCA	4121.106997670045	65837	BBCA	BMRI	HAKI
2026-06-30 01:00:55.029475+07	BBCA	4122.6173895346465	71987	BBCA	BMRI	HAKA
2026-06-29 23:30:55.029475+07	BBCA	4123.114444272742	71631	BBCA	BMRI	HAKA
2026-06-29 22:12:55.029475+07	BBCA	4122.4691614750045	52765	BBCA	BMRI	HAKI
2026-06-29 21:10:55.029475+07	BBCA	4120.319258685486	50176	BBCA	BMRI	HAKI
2026-06-29 21:04:55.029475+07	BBCA	4115.567827898279	37858	BBCA	BMRI	HAKI
2026-06-29 20:01:55.029475+07	BBCA	4120.043284305291	54263	BBCA	BMRI	HAKA
2026-06-29 18:40:55.029475+07	BBCA	4123.638119586801	52707	BBCA	BMRI	HAKA
2026-06-29 17:40:55.029475+07	BBCA	4102.447152258283	55830	BBCA	BMRI	HAKI
2026-06-29 16:13:55.029475+07	BBCA	4100.127038032219	51377	BBCA	BMRI	HAKI
2026-06-29 15:50:55.029475+07	BBCA	4105.067149622478	65592	BBCA	BMRI	HAKA
2026-07-01 10:23:55.029475+07	BBCA	4126.376194668473	63665	BBCA	BMRI	HAKA
2026-07-01 09:13:55.029475+07	BBCA	4126.111429150038	51960	BBCA	BMRI	HAKI
2026-07-01 08:43:55.029475+07	BBCA	4129.775344958205	47396	BBCA	BMRI	HAKA
2026-07-01 07:25:55.029475+07	BBCA	4131.343325557887	58819	BBCA	BMRI	HAKA
2026-07-01 06:21:55.029475+07	BBCA	4135.369793834086	53194	BBCA	BMRI	HAKA
2026-07-01 05:16:55.029475+07	BBCA	4139.110381541823	44645	BBCA	BMRI	HAKA
2026-07-01 04:45:55.029475+07	BBCA	4125.0325652367555	74776	BBCA	BMRI	HAKI
2026-07-01 03:32:55.029475+07	BBCA	4122.1048582676885	58906	BBCA	BMRI	HAKI
2026-07-01 02:15:55.029475+07	BBCA	4108.870443091097	36547	BBCA	BMRI	HAKI
2026-07-01 02:02:55.029475+07	BBCA	4093.809311066657	45924	BBCA	BMRI	HAKI
2026-07-01 00:27:55.029475+07	BBCA	4104.974726528087	37877	BBCA	BMRI	HAKA
2026-06-30 23:47:55.029475+07	BBCA	4102.391931746303	62015	BBCA	BMRI	HAKI
2026-06-30 22:07:55.029475+07	BBCA	4110.025588639193	68301	BBCA	BMRI	HAKA
2026-06-30 21:33:55.029475+07	BBCA	4100.978366624992	81979	BBCA	BMRI	HAKI
2026-06-30 20:46:55.029475+07	BBCA	4103.857256777504	58462	BBCA	BMRI	HAKA
2026-06-30 19:24:55.029475+07	BBCA	4096.6120304610595	57548	BBCA	BMRI	HAKI
2026-06-30 18:27:55.029475+07	BBCA	4100.329627607922	39735	BBCA	BMRI	HAKA
2026-06-30 17:45:55.029475+07	BBCA	4091.7282803594976	37543	BBCA	BMRI	HAKI
2026-06-30 16:29:55.029475+07	BBCA	4103.025946489813	41941	BBCA	BMRI	HAKA
2026-06-30 15:23:55.029475+07	BBCA	4106.262647290753	45479	BBCA	BMRI	HAKA
2026-07-02 06:31:55.029475+07	BBCA	4118.073782571599	63613	BBCA	BMRI	HAKA
2026-07-02 05:13:55.029475+07	BBCA	4122.341651184814	58854	BBCA	BMRI	HAKA
2026-07-02 04:41:55.029475+07	BBCA	4133.322813443625	44146	BBCA	BMRI	HAKA
2026-07-02 03:56:55.029475+07	BBCA	4128.137708039821	45985	BBCA	BMRI	HAKI
2026-07-02 02:46:55.029475+07	BBCA	4116.533707212123	35508	BBCA	BMRI	HAKI
2026-07-02 01:20:55.029475+07	BBCA	4114.674276879563	60473	BBCA	BMRI	HAKI
2026-07-02 00:24:55.029475+07	BBCA	4112.183712250145	42133	BBCA	BMRI	HAKI
2026-07-01 23:49:55.029475+07	BBCA	4093.7989298690622	37686	BBCA	BMRI	HAKI
2026-07-01 22:22:55.029475+07	BBCA	4082.550041999167	35080	BBCA	BMRI	HAKI
2026-07-01 21:29:55.029475+07	BBCA	4095.8092053943783	57679	BBCA	BMRI	HAKA
2026-07-01 20:32:55.029475+07	BBCA	4094.759157140584	49870	BBCA	BMRI	HAKI
2026-07-01 19:45:55.029475+07	BBCA	4081.4827061544534	49560	BBCA	BMRI	HAKI
2026-07-01 18:20:55.029475+07	BBCA	4078.965037152152	42237	BBCA	BMRI	HAKI
2026-07-01 17:33:55.029475+07	BBCA	4059.47752814923	44950	BBCA	BMRI	HAKI
2026-07-01 16:31:55.029475+07	BBCA	4055.7509705031807	40561	BBCA	BMRI	HAKI
2026-07-01 15:17:55.029475+07	BBCA	4051.8086183174373	47515	BBCA	BMRI	HAKI
2026-06-27 10:38:56.369997+07	BBRI	1653.6096968072375	41134	BBCA	BMRI	HAKI
2026-06-27 09:33:56.369997+07	BBRI	1659.7585748226122	40960	BBCA	BMRI	HAKA
2026-06-27 08:49:56.369997+07	BBRI	1654.7762198597216	47849	BBCA	BMRI	HAKI
2026-06-27 07:51:56.369997+07	BBRI	1649.3465355502826	48068	BBCA	BMRI	HAKI
2026-06-27 06:36:56.369997+07	BBRI	1646.5331181056345	50258	BBCA	BMRI	HAKI
2026-06-27 05:20:56.369997+07	BBRI	1642.5053144598962	50098	BBCA	BMRI	HAKI
2026-06-27 04:11:56.369997+07	BBRI	1644.3192879360784	55860	BBCA	BMRI	HAKA
2026-06-27 03:35:56.369997+07	BBRI	1637.3250738596469	52710	BBCA	BMRI	HAKI
2026-06-27 02:29:56.369997+07	BBRI	1644.8658354282297	47555	BBCA	BMRI	HAKA
2026-06-27 01:21:56.369997+07	BBRI	1645.3485795308611	60166	BBCA	BMRI	HAKA
2026-06-27 00:42:56.369997+07	BBRI	1645.6820310966573	46827	BBCA	BMRI	HAKA
2026-06-26 23:15:56.369997+07	BBRI	1640.5029908704778	60293	BBCA	BMRI	HAKI
2026-06-26 22:50:56.369997+07	BBRI	1640.4224116357143	22565	BBCA	BMRI	HAKI
2026-06-26 21:54:56.369997+07	BBRI	1638.884019197942	51024	BBCA	BMRI	HAKI
2026-06-26 20:39:56.369997+07	BBRI	1637.7569028181167	39747	BBCA	BMRI	HAKI
2026-06-26 19:22:56.369997+07	BBRI	1637.6348230838603	37900	BBCA	BMRI	HAKI
2026-06-26 18:47:56.369997+07	BBRI	1639.0653773385136	61643	BBCA	BMRI	HAKA
2026-06-26 17:39:56.369997+07	BBRI	1636.5230016225914	48336	BBCA	BMRI	HAKI
2026-06-26 16:40:56.369997+07	BBRI	1639.191214456623	48973	BBCA	BMRI	HAKA
2026-06-26 15:10:56.369997+07	BBRI	1633.8352382831015	29966	BBCA	BMRI	HAKI
2026-06-28 10:44:56.369997+07	BBRI	1629.0425362072003	31671	BBCA	BMRI	HAKI
2026-06-28 09:34:56.369997+07	BBRI	1626.2096912738232	49502	BBCA	BMRI	HAKI
2026-06-28 08:42:56.369997+07	BBRI	1626.3553053624369	52450	BBCA	BMRI	HAKA
2026-06-28 07:40:56.369997+07	BBRI	1631.1323614761898	60504	BBCA	BMRI	HAKA
2026-06-28 06:50:56.369997+07	BBRI	1635.921809312767	41140	BBCA	BMRI	HAKA
2026-06-28 06:02:56.369997+07	BBRI	1637.5848621020693	44417	BBCA	BMRI	HAKA
2026-06-28 04:09:56.369997+07	BBRI	1637.6701501047494	56376	BBCA	BMRI	HAKA
2026-06-28 03:46:56.369997+07	BBRI	1634.586097761383	71035	BBCA	BMRI	HAKI
2026-06-28 02:44:56.369997+07	BBRI	1627.456215886603	42380	BBCA	BMRI	HAKI
2026-06-28 01:17:56.369997+07	BBRI	1624.8844977658664	31895	BBCA	BMRI	HAKI
2026-06-28 00:28:56.369997+07	BBRI	1624.2721222394216	36898	BBCA	BMRI	HAKI
2026-06-27 23:25:56.369997+07	BBRI	1625.6923679899958	42728	BBCA	BMRI	HAKA
2026-06-27 22:41:56.369997+07	BBRI	1628.8467651842434	57828	BBCA	BMRI	HAKA
2026-06-27 21:44:56.369997+07	BBRI	1622.7250719663064	46236	BBCA	BMRI	HAKI
2026-06-27 20:28:56.369997+07	BBRI	1620.1282814355702	39159	BBCA	BMRI	HAKI
2026-06-27 19:13:56.369997+07	BBRI	1625.8628120708624	36892	BBCA	BMRI	HAKA
2026-06-27 18:10:56.369997+07	BBRI	1624.0343714260769	70388	BBCA	BMRI	HAKI
2026-06-27 17:51:56.369997+07	BBRI	1621.2581824632514	53855	BBCA	BMRI	HAKI
2026-06-27 16:31:56.369997+07	BBRI	1630.0311024206553	63800	BBCA	BMRI	HAKA
2026-06-27 15:36:56.369997+07	BBRI	1630.7337549929239	58037	BBCA	BMRI	HAKA
2026-06-29 10:19:56.369997+07	BBRI	1629.9034192765232	54917	BBCA	BMRI	HAKI
2026-06-29 09:06:56.369997+07	BBRI	1628.6516596148297	48219	BBCA	BMRI	HAKI
2026-06-29 08:46:56.369997+07	BBRI	1627.6368268264537	52742	BBCA	BMRI	HAKI
2026-06-29 07:36:56.369997+07	BBRI	1630.3366807007835	47660	BBCA	BMRI	HAKA
2026-06-29 06:23:56.369997+07	BBRI	1627.465724297797	47624	BBCA	BMRI	HAKI
2026-06-29 05:48:56.369997+07	BBRI	1630.0173451095486	46178	BBCA	BMRI	HAKA
2026-06-29 04:22:56.369997+07	BBRI	1632.7956660445034	45843	BBCA	BMRI	HAKA
2026-06-29 03:21:56.369997+07	BBRI	1634.8464790868034	68321	BBCA	BMRI	HAKA
2026-06-29 02:16:56.369997+07	BBRI	1634.1121384905216	47785	BBCA	BMRI	HAKI
2026-06-29 01:59:56.369997+07	BBRI	1637.4269574739662	63136	BBCA	BMRI	HAKA
2026-06-29 00:13:56.369997+07	BBRI	1636.9504541872436	42527	BBCA	BMRI	HAKI
2026-06-28 23:09:56.369997+07	BBRI	1628.5146947250773	52560	BBCA	BMRI	HAKI
2026-06-28 22:51:56.369997+07	BBRI	1630.1347216323545	41821	BBCA	BMRI	HAKA
2026-06-28 22:00:56.369997+07	BBRI	1626.4585375475087	44799	BBCA	BMRI	HAKI
2026-06-28 20:06:56.369997+07	BBRI	1628.4907679639466	36435	BBCA	BMRI	HAKA
2026-06-28 19:49:56.369997+07	BBRI	1627.638362622439	28191	BBCA	BMRI	HAKI
2026-06-28 18:56:56.369997+07	BBRI	1635.8497831235313	43250	BBCA	BMRI	HAKA
2026-06-28 17:51:56.369997+07	BBRI	1636.9023707036001	44367	BBCA	BMRI	HAKA
2026-06-28 16:33:56.369997+07	BBRI	1632.6594455997329	43395	BBCA	BMRI	HAKI
2026-06-28 16:04:56.369997+07	BBRI	1626.8554208598107	46479	BBCA	BMRI	HAKI
2026-06-30 10:35:56.369997+07	BBRI	1632.0611249688566	52930	BBCA	BMRI	HAKA
2026-06-30 09:58:56.369997+07	BBRI	1633.0853278403931	40214	BBCA	BMRI	HAKA
2026-06-30 08:57:56.369997+07	BBRI	1633.2255767973943	59468	BBCA	BMRI	HAKA
2026-06-30 08:04:56.369997+07	BBRI	1630.7789989625526	45920	BBCA	BMRI	HAKI
2026-06-30 06:21:56.369997+07	BBRI	1633.8573964273917	36781	BBCA	BMRI	HAKA
2026-06-30 05:44:56.369997+07	BBRI	1639.0371750029294	55377	BBCA	BMRI	HAKA
2026-06-30 04:32:56.369997+07	BBRI	1643.3624251564809	32266	BBCA	BMRI	HAKA
2026-06-30 03:37:56.369997+07	BBRI	1641.1587608286213	40645	BBCA	BMRI	HAKI
2026-06-30 02:13:56.369997+07	BBRI	1640.9786095199363	40529	BBCA	BMRI	HAKI
2026-06-30 01:48:56.369997+07	BBRI	1642.622018565296	60157	BBCA	BMRI	HAKA
2026-06-30 00:58:56.369997+07	BBRI	1641.285488123259	57817	BBCA	BMRI	HAKI
2026-06-29 23:22:56.369997+07	BBRI	1648.0666656525264	48702	BBCA	BMRI	HAKA
2026-06-29 22:49:56.369997+07	BBRI	1653.9481784373163	23396	BBCA	BMRI	HAKA
2026-06-29 21:37:56.369997+07	BBRI	1659.6187221179757	36963	BBCA	BMRI	HAKA
2026-06-29 20:40:56.369997+07	BBRI	1655.6350823875248	55031	BBCA	BMRI	HAKI
2026-06-29 19:31:56.369997+07	BBRI	1665.9763437572642	43970	BBCA	BMRI	HAKA
2026-06-29 18:28:56.369997+07	BBRI	1666.0544454089231	50632	BBCA	BMRI	HAKA
2026-06-29 17:06:56.369997+07	BBRI	1658.5896347367977	45728	BBCA	BMRI	HAKI
2026-06-29 16:39:56.369997+07	BBRI	1650.9071638782216	56323	BBCA	BMRI	HAKI
2026-06-29 15:09:56.369997+07	BBRI	1655.62445528837	57062	BBCA	BMRI	HAKA
2026-07-01 10:37:56.369997+07	BBRI	1653.2193261194745	49204	BBCA	BMRI	HAKI
2026-07-01 09:09:56.369997+07	BBRI	1653.573642047066	52178	BBCA	BMRI	HAKA
2026-07-01 08:35:56.369997+07	BBRI	1646.081631327154	59793	BBCA	BMRI	HAKI
2026-07-01 07:21:56.369997+07	BBRI	1649.9523764157145	57248	BBCA	BMRI	HAKA
2026-07-01 07:04:56.369997+07	BBRI	1649.6707228153712	22585	BBCA	BMRI	HAKI
2026-07-01 06:04:56.369997+07	BBRI	1650.235104405311	51786	BBCA	BMRI	HAKA
2026-07-01 04:41:56.369997+07	BBRI	1650.0234687107513	43198	BBCA	BMRI	HAKI
2026-07-01 03:36:56.369997+07	BBRI	1650.9801579771554	67466	BBCA	BMRI	HAKA
2026-07-01 02:46:56.369997+07	BBRI	1653.8244405724458	48193	BBCA	BMRI	HAKA
2026-07-01 01:12:56.369997+07	BBRI	1648.7617741726265	51509	BBCA	BMRI	HAKI
2026-07-01 00:07:56.369997+07	BBRI	1642.2192723508272	45600	BBCA	BMRI	HAKI
2026-06-30 23:24:56.369997+07	BBRI	1647.347672037735	55875	BBCA	BMRI	HAKA
2026-06-30 22:50:56.369997+07	BBRI	1641.975928379196	51370	BBCA	BMRI	HAKI
2026-06-30 21:55:56.369997+07	BBRI	1633.251019194135	63054	BBCA	BMRI	HAKI
2026-06-30 20:20:56.369997+07	BBRI	1632.6840821766557	58392	BBCA	BMRI	HAKI
2026-06-30 19:34:56.369997+07	BBRI	1624.5889615659678	41861	BBCA	BMRI	HAKI
2026-06-30 18:35:56.369997+07	BBRI	1629.9536993569461	44328	BBCA	BMRI	HAKA
2026-06-30 17:53:56.369997+07	BBRI	1627.8351816251409	45350	BBCA	BMRI	HAKI
2026-06-30 17:03:56.369997+07	BBRI	1624.023784442573	60199	BBCA	BMRI	HAKI
2026-06-30 15:48:56.369997+07	BBRI	1625.2291237141449	61131	BBCA	BMRI	HAKA
2026-07-02 06:51:56.369997+07	BBRI	1632.3978792616242	28073	BBCA	BMRI	HAKI
2026-07-02 05:47:56.369997+07	BBRI	1630.110080795943	60832	BBCA	BMRI	HAKI
2026-07-02 04:59:56.369997+07	BBRI	1627.2202264820035	45405	BBCA	BMRI	HAKI
2026-07-02 04:03:56.369997+07	BBRI	1629.6943154983987	64867	BBCA	BMRI	HAKA
2026-07-02 02:54:56.369997+07	BBRI	1628.4723938105574	45287	BBCA	BMRI	HAKI
2026-07-02 01:12:56.369997+07	BBRI	1631.2085455138488	33277	BBCA	BMRI	HAKA
2026-07-02 00:31:56.369997+07	BBRI	1627.0749477841766	45753	BBCA	BMRI	HAKI
2026-07-01 23:44:56.369997+07	BBRI	1625.4796842912206	47779	BBCA	BMRI	HAKI
2026-07-01 22:56:56.369997+07	BBRI	1623.0606732828946	61771	BBCA	BMRI	HAKI
2026-07-01 21:10:56.369997+07	BBRI	1627.5922234915702	65081	BBCA	BMRI	HAKA
2026-07-01 20:13:56.369997+07	BBRI	1626.096093306508	41088	BBCA	BMRI	HAKI
2026-07-01 20:03:56.369997+07	BBRI	1623.5890106211255	58093	BBCA	BMRI	HAKI
2026-07-01 18:37:56.369997+07	BBRI	1624.7323375474937	62184	BBCA	BMRI	HAKA
2026-07-01 17:31:56.369997+07	BBRI	1624.1617829451939	44501	BBCA	BMRI	HAKI
2026-07-01 16:08:56.369997+07	BBRI	1628.8324312685318	43568	BBCA	BMRI	HAKA
2026-07-01 15:44:56.369997+07	BBRI	1628.928606095824	46232	BBCA	BMRI	HAKA
2026-06-27 10:12:57.706842+07	BMRI	2951.229259838394	44926	BBCA	BMRI	HAKA
2026-06-27 09:58:57.706842+07	BMRI	2950.098106333266	43610	BBCA	BMRI	HAKI
2026-06-27 09:00:57.706842+07	BMRI	2954.136634441704	60525	BBCA	BMRI	HAKA
2026-06-27 07:56:57.706842+07	BMRI	2945.156226146877	47374	BBCA	BMRI	HAKI
2026-06-27 06:23:57.706842+07	BMRI	2944.938561952371	47505	BBCA	BMRI	HAKI
2026-06-27 05:51:57.706842+07	BMRI	2935.986636072969	49296	BBCA	BMRI	HAKI
2026-06-27 04:36:57.706842+07	BMRI	2939.3895630132142	62607	BBCA	BMRI	HAKA
2026-06-27 03:45:57.706842+07	BMRI	2941.1988194084315	48613	BBCA	BMRI	HAKA
2026-06-27 02:10:57.706842+07	BMRI	2929.3360898777405	45795	BBCA	BMRI	HAKI
2026-06-27 01:27:57.706842+07	BMRI	2931.5797430537023	53652	BBCA	BMRI	HAKA
2026-06-27 00:37:57.706842+07	BMRI	2931.601794074168	41153	BBCA	BMRI	HAKA
2026-06-26 23:22:57.706842+07	BMRI	2922.855817276911	48671	BBCA	BMRI	HAKI
2026-06-26 22:22:57.706842+07	BMRI	2922.202981819321	46382	BBCA	BMRI	HAKI
2026-06-26 21:51:57.706842+07	BMRI	2921.2908524663007	49852	BBCA	BMRI	HAKI
2026-06-26 20:07:57.706842+07	BMRI	2923.4236725869723	66265	BBCA	BMRI	HAKA
2026-06-26 19:58:57.706842+07	BMRI	2923.4444962141165	49150	BBCA	BMRI	HAKA
2026-06-26 18:40:57.706842+07	BMRI	2921.9802249275467	24339	BBCA	BMRI	HAKI
2026-06-26 17:15:57.706842+07	BMRI	2929.400666050211	66083	BBCA	BMRI	HAKA
2026-06-26 16:17:57.706842+07	BMRI	2936.527133334188	64570	BBCA	BMRI	HAKA
2026-06-26 15:13:57.706842+07	BMRI	2922.8598257420854	57806	BBCA	BMRI	HAKI
2026-06-28 10:19:57.706842+07	BMRI	2918.8770708750126	38581	BBCA	BMRI	HAKI
2026-06-28 09:33:57.706842+07	BMRI	2920.52342274757	42405	BBCA	BMRI	HAKA
2026-06-28 08:39:57.706842+07	BMRI	2918.3123571398232	51790	BBCA	BMRI	HAKI
2026-06-28 07:45:57.706842+07	BMRI	2929.3060845117325	32335	BBCA	BMRI	HAKA
2026-06-28 06:38:57.706842+07	BMRI	2918.561134632704	50212	BBCA	BMRI	HAKI
2026-06-28 05:05:57.706842+07	BMRI	2921.437778281125	59450	BBCA	BMRI	HAKA
2026-06-28 04:23:57.706842+07	BMRI	2922.250879897679	65059	BBCA	BMRI	HAKA
2026-06-28 03:51:57.706842+07	BMRI	2924.570153785986	43061	BBCA	BMRI	HAKA
2026-06-28 02:31:57.706842+07	BMRI	2914.002932973863	69742	BBCA	BMRI	HAKI
2026-06-28 01:17:57.706842+07	BMRI	2909.2385769145512	55595	BBCA	BMRI	HAKI
2026-06-28 00:27:57.706842+07	BMRI	2913.4899220967563	76174	BBCA	BMRI	HAKA
2026-06-27 23:22:57.706842+07	BMRI	2917.9205461281585	46353	BBCA	BMRI	HAKA
2026-06-27 22:40:57.706842+07	BMRI	2903.440713368635	40758	BBCA	BMRI	HAKI
2026-06-27 21:44:57.706842+07	BMRI	2904.7357876326223	39061	BBCA	BMRI	HAKA
2026-06-27 20:07:57.706842+07	BMRI	2908.0535624137447	38357	BBCA	BMRI	HAKA
2026-06-27 20:03:57.706842+07	BMRI	2909.1073595215753	59823	BBCA	BMRI	HAKA
2026-06-27 18:51:57.706842+07	BMRI	2916.5583103302824	68648	BBCA	BMRI	HAKA
2026-06-27 17:13:57.706842+07	BMRI	2901.1118296372274	44510	BBCA	BMRI	HAKI
2026-06-27 16:20:57.706842+07	BMRI	2914.658929806837	49281	BBCA	BMRI	HAKA
2026-06-27 15:16:57.706842+07	BMRI	2913.2388792513316	47789	BBCA	BMRI	HAKI
2026-06-29 10:26:57.706842+07	BMRI	2911.1284794619655	38417	BBCA	BMRI	HAKI
2026-06-29 09:16:57.706842+07	BMRI	2909.8891005015375	46760	BBCA	BMRI	HAKI
2026-06-29 08:18:57.706842+07	BMRI	2897.9127283084235	48858	BBCA	BMRI	HAKI
2026-06-29 07:34:57.706842+07	BMRI	2898.7915287589726	72318	BBCA	BMRI	HAKA
2026-06-29 06:36:57.706842+07	BMRI	2902.3628690175337	50667	BBCA	BMRI	HAKA
2026-06-29 05:40:57.706842+07	BMRI	2889.9361973934565	46505	BBCA	BMRI	HAKI
2026-06-29 04:57:57.706842+07	BMRI	2887.3938785713485	63704	BBCA	BMRI	HAKI
2026-06-29 03:15:57.706842+07	BMRI	2882.180896675042	60258	BBCA	BMRI	HAKI
2026-06-29 02:36:57.706842+07	BMRI	2882.002408695496	45115	BBCA	BMRI	HAKI
2026-06-29 01:41:57.706842+07	BMRI	2883.6411599500802	37783	BBCA	BMRI	HAKA
2026-06-29 00:07:57.706842+07	BMRI	2885.1569726758944	48061	BBCA	BMRI	HAKA
2026-06-28 23:06:57.706842+07	BMRI	2887.3507787968765	60411	BBCA	BMRI	HAKA
2026-06-28 22:19:57.706842+07	BMRI	2881.4749233354005	48609	BBCA	BMRI	HAKI
2026-06-28 21:55:57.706842+07	BMRI	2879.977558246455	47797	BBCA	BMRI	HAKI
2026-06-28 20:54:57.706842+07	BMRI	2876.813335696979	70462	BBCA	BMRI	HAKI
2026-06-28 19:30:57.706842+07	BMRI	2879.7221087115436	68153	BBCA	BMRI	HAKA
2026-06-28 18:25:57.706842+07	BMRI	2883.1321903765133	48023	BBCA	BMRI	HAKA
2026-06-28 17:20:57.706842+07	BMRI	2883.69096152436	52820	BBCA	BMRI	HAKA
2026-06-28 16:53:57.706842+07	BMRI	2879.4909676758625	57881	BBCA	BMRI	HAKI
2026-06-28 15:40:57.706842+07	BMRI	2880.0584041379343	48535	BBCA	BMRI	HAKA
2026-06-30 10:59:57.706842+07	BMRI	2875.135784352838	56196	BBCA	BMRI	HAKI
2026-06-30 09:22:57.706842+07	BMRI	2873.071515161938	49445	BBCA	BMRI	HAKI
2026-06-30 08:16:57.706842+07	BMRI	2875.8033566887566	51704	BBCA	BMRI	HAKA
2026-06-30 07:25:57.706842+07	BMRI	2871.6670774921868	53312	BBCA	BMRI	HAKI
2026-06-30 06:57:57.706842+07	BMRI	2868.7845591128357	47009	BBCA	BMRI	HAKI
2026-06-30 05:32:57.706842+07	BMRI	2874.4638726205403	57862	BBCA	BMRI	HAKA
2026-06-30 04:50:57.706842+07	BMRI	2878.906834851793	52588	BBCA	BMRI	HAKA
2026-06-30 03:56:57.706842+07	BMRI	2879.36507776322	70139	BBCA	BMRI	HAKA
2026-06-30 02:20:57.706842+07	BMRI	2876.081037291113	57502	BBCA	BMRI	HAKI
2026-06-30 01:29:57.706842+07	BMRI	2866.2272684608965	62342	BBCA	BMRI	HAKI
2026-06-30 00:28:57.706842+07	BMRI	2859.293980411737	42941	BBCA	BMRI	HAKI
2026-06-29 23:09:57.706842+07	BMRI	2850.45494051368	51689	BBCA	BMRI	HAKI
2026-06-29 22:23:57.706842+07	BMRI	2850.5548568034283	50982	BBCA	BMRI	HAKA
2026-06-29 21:49:57.706842+07	BMRI	2847.064018658106	55529	BBCA	BMRI	HAKI
2026-06-29 20:40:57.706842+07	BMRI	2840.2072091429177	54063	BBCA	BMRI	HAKI
2026-06-29 19:51:57.706842+07	BMRI	2835.7496746579827	49879	BBCA	BMRI	HAKI
2026-06-29 18:47:57.706842+07	BMRI	2840.6879309295896	59303	BBCA	BMRI	HAKA
2026-06-29 17:49:57.706842+07	BMRI	2849.373201874731	63027	BBCA	BMRI	HAKA
2026-06-29 16:45:57.706842+07	BMRI	2855.4825116913994	52293	BBCA	BMRI	HAKA
2026-06-29 15:39:57.706842+07	BMRI	2849.6954011725243	53279	BBCA	BMRI	HAKI
2026-07-01 10:57:57.706842+07	BMRI	2837.127897506525	46055	BBCA	BMRI	HAKI
2026-07-01 09:31:57.706842+07	BMRI	2836.4300662829964	54361	BBCA	BMRI	HAKI
2026-07-01 08:32:57.706842+07	BMRI	2832.7082125179472	40817	BBCA	BMRI	HAKI
2026-07-01 07:54:57.706842+07	BMRI	2828.850260094883	54187	BBCA	BMRI	HAKI
2026-07-01 06:29:57.706842+07	BMRI	2829.0691382989075	50980	BBCA	BMRI	HAKA
2026-07-01 05:52:57.706842+07	BMRI	2830.264048912745	55044	BBCA	BMRI	HAKA
2026-07-01 05:03:57.706842+07	BMRI	2828.9424833602448	48699	BBCA	BMRI	HAKI
2026-07-01 04:04:57.706842+07	BMRI	2837.715955232675	39527	BBCA	BMRI	HAKA
2026-07-01 02:35:57.706842+07	BMRI	2835.3787669063786	37399	BBCA	BMRI	HAKI
2026-07-01 01:43:57.706842+07	BMRI	2828.206495388	71460	BBCA	BMRI	HAKI
2026-07-01 01:00:57.706842+07	BMRI	2831.0476101541853	47575	BBCA	BMRI	HAKA
2026-06-30 23:34:57.706842+07	BMRI	2823.501928132844	36571	BBCA	BMRI	HAKI
2026-06-30 22:27:57.706842+07	BMRI	2821.4274277266404	64335	BBCA	BMRI	HAKI
2026-06-30 21:16:57.706842+07	BMRI	2833.35074333772	28943	BBCA	BMRI	HAKA
2026-06-30 21:00:57.706842+07	BMRI	2833.922009970344	33000	BBCA	BMRI	HAKA
2026-06-30 19:17:57.706842+07	BMRI	2831.819563077197	41431	BBCA	BMRI	HAKI
2026-06-30 18:17:57.706842+07	BMRI	2839.792087010283	52942	BBCA	BMRI	HAKA
2026-06-30 17:22:57.706842+07	BMRI	2837.7459216481366	39851	BBCA	BMRI	HAKI
2026-06-30 16:48:57.706842+07	BMRI	2836.0879658987615	65476	BBCA	BMRI	HAKI
2026-06-30 15:41:57.706842+07	BMRI	2828.4906119369407	49951	BBCA	BMRI	HAKI
2026-07-02 06:20:57.706842+07	BMRI	2819.675756661942	56750	BBCA	BMRI	HAKI
2026-07-02 05:20:57.706842+07	BMRI	2820.4155294166685	36988	BBCA	BMRI	HAKA
2026-07-02 04:44:57.706842+07	BMRI	2818.3895661915167	49572	BBCA	BMRI	HAKI
2026-07-02 03:23:57.706842+07	BMRI	2820.757133104736	50942	BBCA	BMRI	HAKA
2026-07-02 02:24:57.706842+07	BMRI	2818.6536393617776	58580	BBCA	BMRI	HAKI
2026-07-02 02:02:57.706842+07	BMRI	2823.476792562306	47189	BBCA	BMRI	HAKA
2026-07-02 00:41:57.706842+07	BMRI	2826.245951603041	69785	BBCA	BMRI	HAKA
2026-07-01 23:34:57.706842+07	BMRI	2825.469502926202	50603	BBCA	BMRI	HAKI
2026-07-01 22:23:57.706842+07	BMRI	2829.4279296925433	58548	BBCA	BMRI	HAKA
2026-07-01 21:46:57.706842+07	BMRI	2831.864189267896	54692	BBCA	BMRI	HAKA
2026-07-01 21:02:57.706842+07	BMRI	2834.705521258538	55908	BBCA	BMRI	HAKA
2026-07-01 19:43:57.706842+07	BMRI	2830.4493570573686	43424	BBCA	BMRI	HAKI
2026-07-01 18:23:57.706842+07	BMRI	2827.0357490835204	48726	BBCA	BMRI	HAKI
2026-07-01 17:15:57.706842+07	BMRI	2818.965029903577	45361	BBCA	BMRI	HAKI
2026-07-01 16:13:57.706842+07	BMRI	2819.000202895951	54986	BBCA	BMRI	HAKA
2026-07-01 16:01:57.706842+07	BMRI	2814.0058970424575	45626	BBCA	BMRI	HAKI
2026-06-27 10:46:59.012754+07	TLKM	5774.426272988491	71678	BBCA	BMRI	HAKI
2026-06-27 09:26:59.012754+07	TLKM	5776.932895198835	53074	BBCA	BMRI	HAKA
2026-06-27 08:33:59.012754+07	TLKM	5782.074002189531	43490	BBCA	BMRI	HAKA
2026-06-27 07:40:59.012754+07	TLKM	5796.433124816166	41917	BBCA	BMRI	HAKA
2026-06-27 06:59:59.012754+07	TLKM	5779.606721826535	44556	BBCA	BMRI	HAKI
2026-06-27 05:26:59.012754+07	TLKM	5767.3025919919755	54960	BBCA	BMRI	HAKI
2026-06-27 04:09:59.012754+07	TLKM	5770.285944665734	40170	BBCA	BMRI	HAKA
2026-06-27 04:04:59.012754+07	TLKM	5759.02956543725	49672	BBCA	BMRI	HAKI
2026-06-27 03:04:59.012754+07	TLKM	5776.237916057482	36185	BBCA	BMRI	HAKA
2026-06-27 01:33:59.012754+07	TLKM	5768.376260959392	45952	BBCA	BMRI	HAKI
2026-06-27 00:42:59.012754+07	TLKM	5783.575792283227	51974	BBCA	BMRI	HAKA
2026-06-26 23:10:59.012754+07	TLKM	5769.809433096293	49661	BBCA	BMRI	HAKI
2026-06-26 22:48:59.012754+07	TLKM	5746.3297732375595	62619	BBCA	BMRI	HAKI
2026-06-26 21:23:59.012754+07	TLKM	5728.007284494325	43338	BBCA	BMRI	HAKI
2026-06-26 20:25:59.012754+07	TLKM	5719.170160962048	39242	BBCA	BMRI	HAKI
2026-06-26 19:23:59.012754+07	TLKM	5699.325613839898	50658	BBCA	BMRI	HAKI
2026-06-26 18:28:59.012754+07	TLKM	5695.927770696209	65247	BBCA	BMRI	HAKI
2026-06-26 18:01:59.012754+07	TLKM	5700.221834037397	58781	BBCA	BMRI	HAKA
2026-06-26 16:21:59.012754+07	TLKM	5708.86592467776	50115	BBCA	BMRI	HAKA
2026-06-26 15:33:59.012754+07	TLKM	5696.038323141268	51275	BBCA	BMRI	HAKI
2026-06-28 10:48:59.012754+07	TLKM	5696.244465358683	49974	BBCA	BMRI	HAKA
2026-06-28 09:31:59.012754+07	TLKM	5704.139650451104	59109	BBCA	BMRI	HAKA
2026-06-28 08:30:59.012754+07	TLKM	5702.852048290587	49426	BBCA	BMRI	HAKI
2026-06-28 07:24:59.012754+07	TLKM	5700.349893687773	63460	BBCA	BMRI	HAKI
2026-06-28 06:08:59.012754+07	TLKM	5694.126960585933	58952	BBCA	BMRI	HAKI
2026-06-28 05:08:59.012754+07	TLKM	5684.505875385099	52181	BBCA	BMRI	HAKI
2026-06-28 04:50:59.012754+07	TLKM	5685.227947567516	49609	BBCA	BMRI	HAKA
2026-06-28 03:28:59.012754+07	TLKM	5666.134100744663	53128	BBCA	BMRI	HAKI
2026-06-28 02:20:59.012754+07	TLKM	5644.686153064925	49662	BBCA	BMRI	HAKI
2026-06-28 01:07:59.012754+07	TLKM	5662.563192986811	64737	BBCA	BMRI	HAKA
2026-06-28 01:01:59.012754+07	TLKM	5657.484739598649	47605	BBCA	BMRI	HAKI
2026-06-27 23:09:59.012754+07	TLKM	5652.706284365715	62373	BBCA	BMRI	HAKI
2026-06-27 23:03:59.012754+07	TLKM	5665.2128255127	47421	BBCA	BMRI	HAKA
2026-06-27 21:28:59.012754+07	TLKM	5678.174066109335	46734	BBCA	BMRI	HAKA
2026-06-27 20:37:59.012754+07	TLKM	5697.04949033914	73826	BBCA	BMRI	HAKA
2026-06-27 19:08:59.012754+07	TLKM	5693.652818336632	57135	BBCA	BMRI	HAKI
2026-06-27 18:32:59.012754+07	TLKM	5701.623541106852	53007	BBCA	BMRI	HAKA
2026-06-27 17:06:59.012754+07	TLKM	5701.824225233874	32586	BBCA	BMRI	HAKA
2026-06-27 16:53:59.012754+07	TLKM	5698.328236238518	49261	BBCA	BMRI	HAKI
2026-06-27 15:52:59.012754+07	TLKM	5697.852199588127	41794	BBCA	BMRI	HAKI
2026-06-29 10:51:59.012754+07	TLKM	5714.459804752215	37194	BBCA	BMRI	HAKA
2026-06-29 09:31:59.012754+07	TLKM	5713.4070860966585	60744	BBCA	BMRI	HAKI
2026-06-29 08:16:59.012754+07	TLKM	5711.3157908044295	53853	BBCA	BMRI	HAKI
2026-06-29 07:57:59.012754+07	TLKM	5711.611936582259	30878	BBCA	BMRI	HAKA
2026-06-29 06:59:59.012754+07	TLKM	5689.792109258057	63129	BBCA	BMRI	HAKI
2026-06-29 05:24:59.012754+07	TLKM	5690.455330505126	44786	BBCA	BMRI	HAKA
2026-06-29 04:23:59.012754+07	TLKM	5688.997177377082	48537	BBCA	BMRI	HAKI
2026-06-29 03:48:59.012754+07	TLKM	5691.108376480293	65126	BBCA	BMRI	HAKA
2026-06-29 02:53:59.012754+07	TLKM	5698.045244031486	46702	BBCA	BMRI	HAKA
2026-06-29 01:35:59.012754+07	TLKM	5701.429952241399	50830	BBCA	BMRI	HAKA
2026-06-29 00:10:59.012754+07	TLKM	5706.756304989325	57290	BBCA	BMRI	HAKA
2026-06-28 23:34:59.012754+07	TLKM	5715.129065154098	42120	BBCA	BMRI	HAKA
2026-06-28 22:05:59.012754+07	TLKM	5692.920961056098	46139	BBCA	BMRI	HAKI
2026-06-28 21:05:59.012754+07	TLKM	5680.336787873477	45449	BBCA	BMRI	HAKI
2026-06-28 21:03:59.012754+07	TLKM	5686.093331708358	48770	BBCA	BMRI	HAKA
2026-06-28 19:07:59.012754+07	TLKM	5698.701256046481	69554	BBCA	BMRI	HAKA
2026-06-28 18:17:59.012754+07	TLKM	5684.9426611153385	32048	BBCA	BMRI	HAKI
2026-06-28 17:20:59.012754+07	TLKM	5693.034068497958	59425	BBCA	BMRI	HAKA
2026-06-28 16:22:59.012754+07	TLKM	5705.520738336511	42392	BBCA	BMRI	HAKA
2026-06-28 15:10:59.012754+07	TLKM	5709.764724008125	55545	BBCA	BMRI	HAKA
2026-06-30 10:33:59.012754+07	TLKM	5690.2191274541665	53053	BBCA	BMRI	HAKI
2026-06-30 09:35:59.012754+07	TLKM	5672.848149228439	73181	BBCA	BMRI	HAKI
2026-06-30 08:42:59.012754+07	TLKM	5672.171337780568	40792	BBCA	BMRI	HAKI
2026-06-30 07:15:59.012754+07	TLKM	5671.946486490647	47770	BBCA	BMRI	HAKI
2026-06-30 06:12:59.012754+07	TLKM	5678.136474308477	52672	BBCA	BMRI	HAKA
2026-06-30 05:47:59.012754+07	TLKM	5677.4541730478395	44797	BBCA	BMRI	HAKI
2026-06-30 04:32:59.012754+07	TLKM	5686.620857365012	51119	BBCA	BMRI	HAKA
2026-06-30 03:29:59.012754+07	TLKM	5693.447501826231	54485	BBCA	BMRI	HAKA
2026-06-30 02:11:59.012754+07	TLKM	5696.975552206978	58747	BBCA	BMRI	HAKA
2026-06-30 01:51:59.012754+07	TLKM	5697.285834320575	53974	BBCA	BMRI	HAKA
2026-06-30 00:34:59.012754+07	TLKM	5706.175089129366	67507	BBCA	BMRI	HAKA
2026-06-29 23:54:59.012754+07	TLKM	5722.052541496095	61443	BBCA	BMRI	HAKA
2026-06-29 22:26:59.012754+07	TLKM	5734.5853822489535	55288	BBCA	BMRI	HAKA
2026-06-29 21:37:59.012754+07	TLKM	5735.58236268601	53715	BBCA	BMRI	HAKA
2026-06-29 21:01:59.012754+07	TLKM	5717.818624118398	53283	BBCA	BMRI	HAKI
2026-06-29 19:42:59.012754+07	TLKM	5716.236883926576	36146	BBCA	BMRI	HAKI
2026-06-29 18:18:59.012754+07	TLKM	5716.704141956582	49923	BBCA	BMRI	HAKA
2026-06-29 17:55:59.012754+07	TLKM	5692.822326068775	58697	BBCA	BMRI	HAKI
2026-06-29 16:05:59.012754+07	TLKM	5684.249384043619	45011	BBCA	BMRI	HAKI
2026-06-29 15:14:59.012754+07	TLKM	5668.621984174176	44754	BBCA	BMRI	HAKI
2026-07-01 10:12:59.012754+07	TLKM	5660.981237493444	41302	BBCA	BMRI	HAKI
2026-07-01 09:25:59.012754+07	TLKM	5673.655655021248	41089	BBCA	BMRI	HAKA
2026-07-01 08:51:59.012754+07	TLKM	5672.899254263765	45942	BBCA	BMRI	HAKI
2026-07-01 07:08:59.012754+07	TLKM	5685.7709213093285	61982	BBCA	BMRI	HAKA
2026-07-01 06:43:59.012754+07	TLKM	5688.095322496341	26576	BBCA	BMRI	HAKA
2026-07-01 05:40:59.012754+07	TLKM	5678.526388332344	47877	BBCA	BMRI	HAKI
2026-07-01 04:59:59.012754+07	TLKM	5693.080836205418	48974	BBCA	BMRI	HAKA
2026-07-01 03:34:59.012754+07	TLKM	5696.672849258255	46848	BBCA	BMRI	HAKA
2026-07-01 02:08:59.012754+07	TLKM	5708.035999022361	37799	BBCA	BMRI	HAKA
2026-07-01 01:53:59.012754+07	TLKM	5692.659541195016	47732	BBCA	BMRI	HAKI
2026-07-01 00:23:59.012754+07	TLKM	5693.692529667062	47307	BBCA	BMRI	HAKA
2026-06-30 23:32:59.012754+07	TLKM	5704.019246390352	50460	BBCA	BMRI	HAKA
2026-06-30 22:39:59.012754+07	TLKM	5722.961689978843	52724	BBCA	BMRI	HAKA
2026-06-30 22:04:59.012754+07	TLKM	5733.8548232828225	27620	BBCA	BMRI	HAKA
2026-06-30 20:15:59.012754+07	TLKM	5741.4220105066815	45045	BBCA	BMRI	HAKA
2026-06-30 19:25:59.012754+07	TLKM	5746.242771665753	56305	BBCA	BMRI	HAKA
2026-06-30 18:51:59.012754+07	TLKM	5761.904219131969	47417	BBCA	BMRI	HAKA
2026-06-30 17:32:59.012754+07	TLKM	5743.458522890438	29093	BBCA	BMRI	HAKI
2026-06-30 16:07:59.012754+07	TLKM	5760.0017752116055	45871	BBCA	BMRI	HAKA
2026-06-30 15:23:59.012754+07	TLKM	5764.091945837452	56496	BBCA	BMRI	HAKA
2026-07-02 06:16:59.012754+07	TLKM	5725.694873034037	52746	BBCA	BMRI	HAKA
2026-07-02 05:39:59.012754+07	TLKM	5739.808898957076	36258	BBCA	BMRI	HAKA
2026-07-02 04:59:59.012754+07	TLKM	5746.460548303048	39916	BBCA	BMRI	HAKA
2026-07-02 04:02:59.012754+07	TLKM	5736.974778085541	56196	BBCA	BMRI	HAKI
2026-07-02 02:24:59.012754+07	TLKM	5738.095502683134	49223	BBCA	BMRI	HAKA
2026-07-02 01:05:59.012754+07	TLKM	5741.50264498876	44188	BBCA	BMRI	HAKA
2026-07-02 00:05:59.012754+07	TLKM	5718.371261119303	49534	BBCA	BMRI	HAKI
2026-07-01 23:05:59.012754+07	TLKM	5731.620363368939	41637	BBCA	BMRI	HAKA
2026-07-01 23:03:59.012754+07	TLKM	5737.2079591885395	71461	BBCA	BMRI	HAKA
2026-07-01 21:40:59.012754+07	TLKM	5750.464389839639	47174	BBCA	BMRI	HAKA
2026-07-01 20:36:59.012754+07	TLKM	5767.5905478198965	46206	BBCA	BMRI	HAKA
2026-07-01 19:40:59.012754+07	TLKM	5779.271197649733	71919	BBCA	BMRI	HAKA
2026-07-01 18:56:59.012754+07	TLKM	5781.832459088089	38612	BBCA	BMRI	HAKA
2026-07-01 18:00:59.012754+07	TLKM	5800.767709110946	52493	BBCA	BMRI	HAKA
2026-07-01 16:55:59.012754+07	TLKM	5803.428221295297	40375	BBCA	BMRI	HAKA
2026-07-01 15:14:59.012754+07	TLKM	5806.821898903391	58047	BBCA	BMRI	HAKA
2026-06-27 10:14:00.280677+07	ASII	2078.362361139072	69684	BBCA	BMRI	HAKA
2026-06-27 09:21:00.280677+07	ASII	2070.2562943239486	38013	BBCA	BMRI	HAKI
2026-06-27 08:14:00.280677+07	ASII	2061.8282089928707	43016	BBCA	BMRI	HAKI
2026-06-27 07:06:00.280677+07	ASII	2061.7245284995447	50461	BBCA	BMRI	HAKI
2026-06-27 06:28:00.280677+07	ASII	2067.5006530407186	60733	BBCA	BMRI	HAKA
2026-06-27 05:51:00.280677+07	ASII	2073.3210432780497	46306	BBCA	BMRI	HAKA
2026-06-27 05:03:00.280677+07	ASII	2074.29834335045	43099	BBCA	BMRI	HAKA
2026-06-27 03:07:00.280677+07	ASII	2073.4228567908253	54136	BBCA	BMRI	HAKI
2026-06-27 02:57:00.280677+07	ASII	2071.4016396824068	60189	BBCA	BMRI	HAKI
2026-06-27 01:22:00.280677+07	ASII	2069.7692061074413	37931	BBCA	BMRI	HAKI
2026-06-27 01:04:00.280677+07	ASII	2069.7588876865175	47377	BBCA	BMRI	HAKI
2026-06-26 23:24:00.280677+07	ASII	2073.3643525354355	35690	BBCA	BMRI	HAKA
2026-06-26 22:23:00.280677+07	ASII	2070.0253536143346	49982	BBCA	BMRI	HAKI
2026-06-26 21:36:00.280677+07	ASII	2074.8685612997165	43877	BBCA	BMRI	HAKA
2026-06-26 20:24:00.280677+07	ASII	2062.7820199795497	58403	BBCA	BMRI	HAKI
2026-06-26 19:29:00.280677+07	ASII	2065.122946978784	66071	BBCA	BMRI	HAKA
2026-06-26 18:17:00.280677+07	ASII	2060.1684245501015	58779	BBCA	BMRI	HAKI
2026-06-26 17:53:00.280677+07	ASII	2056.3106924449735	65084	BBCA	BMRI	HAKI
2026-06-26 16:22:00.280677+07	ASII	2050.2902406329176	58449	BBCA	BMRI	HAKI
2026-06-26 15:15:00.280677+07	ASII	2049.876728402387	47124	BBCA	BMRI	HAKI
2026-06-28 10:24:00.280677+07	ASII	2046.960789415472	55464	BBCA	BMRI	HAKI
2026-06-28 09:12:00.280677+07	ASII	2050.7178261096383	63619	BBCA	BMRI	HAKA
2026-06-28 08:55:00.280677+07	ASII	2044.7252851777519	64599	BBCA	BMRI	HAKI
2026-06-28 07:15:00.280677+07	ASII	2039.7258429799167	48503	BBCA	BMRI	HAKI
2026-06-28 06:42:00.280677+07	ASII	2040.8897975947293	41789	BBCA	BMRI	HAKA
2026-06-28 05:57:00.280677+07	ASII	2044.3421682042126	67887	BBCA	BMRI	HAKA
2026-06-28 04:55:00.280677+07	ASII	2050.3342977538514	58928	BBCA	BMRI	HAKA
2026-06-28 03:54:00.280677+07	ASII	2052.7095137321603	42588	BBCA	BMRI	HAKA
2026-06-28 02:08:00.280677+07	ASII	2051.2987580794934	27710	BBCA	BMRI	HAKI
2026-06-28 01:19:00.280677+07	ASII	2044.6467643526562	54678	BBCA	BMRI	HAKI
2026-06-28 00:50:00.280677+07	ASII	2046.7754206371687	41921	BBCA	BMRI	HAKA
2026-06-27 23:56:00.280677+07	ASII	2038.7335795735783	51306	BBCA	BMRI	HAKI
2026-06-27 22:11:00.280677+07	ASII	2033.9618958070569	51987	BBCA	BMRI	HAKI
2026-06-27 21:38:00.280677+07	ASII	2032.4968703895058	32395	BBCA	BMRI	HAKI
2026-06-27 20:06:00.280677+07	ASII	2026.846867770595	44991	BBCA	BMRI	HAKI
2026-06-27 19:53:00.280677+07	ASII	2020.8603841629297	33670	BBCA	BMRI	HAKI
2026-06-27 19:03:00.280677+07	ASII	2016.4590157555788	55297	BBCA	BMRI	HAKI
2026-06-27 18:00:00.280677+07	ASII	2015.1136748986435	40580	BBCA	BMRI	HAKI
2026-06-27 16:20:00.280677+07	ASII	2008.183207111761	44725	BBCA	BMRI	HAKI
2026-06-27 15:56:00.280677+07	ASII	2007.7795386427206	38747	BBCA	BMRI	HAKI
2026-06-29 10:28:00.280677+07	ASII	2005.4465431743122	60251	BBCA	BMRI	HAKI
2026-06-29 10:03:00.280677+07	ASII	2001.3540977130604	56846	BBCA	BMRI	HAKI
2026-06-29 08:43:00.280677+07	ASII	2009.8917318637532	23792	BBCA	BMRI	HAKA
2026-06-29 08:03:00.280677+07	ASII	2015.6121268157858	27455	BBCA	BMRI	HAKA
2026-06-29 06:11:00.280677+07	ASII	2015.7733958045828	56844	BBCA	BMRI	HAKA
2026-06-29 05:28:00.280677+07	ASII	2021.4863116561494	49060	BBCA	BMRI	HAKA
2026-06-29 04:44:00.280677+07	ASII	2018.1435887401851	46019	BBCA	BMRI	HAKI
2026-06-29 03:12:00.280677+07	ASII	2015.7646327063433	46527	BBCA	BMRI	HAKI
2026-06-29 02:08:00.280677+07	ASII	2019.2587668672916	61285	BBCA	BMRI	HAKA
2026-06-29 01:45:00.280677+07	ASII	2017.5269592625973	48009	BBCA	BMRI	HAKI
2026-06-29 00:30:00.280677+07	ASII	2018.237390883279	48426	BBCA	BMRI	HAKA
2026-06-29 00:05:00.280677+07	ASII	2012.606785080287	44307	BBCA	BMRI	HAKI
2026-06-28 22:10:00.280677+07	ASII	2017.74408235304	51603	BBCA	BMRI	HAKA
2026-06-28 21:33:00.280677+07	ASII	2017.3163611532063	60598	BBCA	BMRI	HAKI
2026-06-28 20:09:00.280677+07	ASII	2018.798400031941	61022	BBCA	BMRI	HAKA
2026-06-28 19:47:00.280677+07	ASII	2017.6374577108268	62489	BBCA	BMRI	HAKI
2026-06-28 18:26:00.280677+07	ASII	2011.950635012706	48745	BBCA	BMRI	HAKI
2026-06-28 17:06:00.280677+07	ASII	2019.549153424545	60014	BBCA	BMRI	HAKA
2026-06-28 16:44:00.280677+07	ASII	2017.1288722907402	42678	BBCA	BMRI	HAKI
2026-06-28 15:44:00.280677+07	ASII	2017.1577849075204	51955	BBCA	BMRI	HAKA
2026-06-30 10:20:00.280677+07	ASII	2018.2079808868352	39148	BBCA	BMRI	HAKA
2026-06-30 10:05:00.280677+07	ASII	2009.4087299078865	50393	BBCA	BMRI	HAKI
2026-06-30 08:21:00.280677+07	ASII	2008.3865037125897	64865	BBCA	BMRI	HAKI
2026-06-30 07:59:00.280677+07	ASII	2014.0905595907009	48634	BBCA	BMRI	HAKA
2026-06-30 06:06:00.280677+07	ASII	2011.4276679322973	37216	BBCA	BMRI	HAKI
2026-06-30 05:48:00.280677+07	ASII	2002.309290022522	58310	BBCA	BMRI	HAKI
2026-06-30 04:12:00.280677+07	ASII	2002.9583000644416	47814	BBCA	BMRI	HAKA
2026-06-30 03:20:00.280677+07	ASII	1998.1622581410763	45720	BBCA	BMRI	HAKI
2026-06-30 02:10:00.280677+07	ASII	1999.4415881293905	37330	BBCA	BMRI	HAKA
2026-06-30 01:09:00.280677+07	ASII	1993.5620355044273	51888	BBCA	BMRI	HAKI
2026-06-30 00:07:00.280677+07	ASII	2001.5962291049943	36955	BBCA	BMRI	HAKA
2026-06-30 00:04:00.280677+07	ASII	2007.6881774550698	39524	BBCA	BMRI	HAKA
2026-06-29 22:35:00.280677+07	ASII	1999.748506523381	58563	BBCA	BMRI	HAKI
2026-06-29 21:22:00.280677+07	ASII	2001.8014157969978	61226	BBCA	BMRI	HAKA
2026-06-29 20:56:00.280677+07	ASII	2003.4156551357298	58629	BBCA	BMRI	HAKA
2026-06-29 20:01:00.280677+07	ASII	2007.7686694342995	47172	BBCA	BMRI	HAKA
2026-06-29 18:47:00.280677+07	ASII	2005.5892122629411	39238	BBCA	BMRI	HAKI
2026-06-29 18:05:00.280677+07	ASII	2004.3053450806076	39285	BBCA	BMRI	HAKI
2026-06-29 16:41:00.280677+07	ASII	2007.7877325961315	52251	BBCA	BMRI	HAKA
2026-06-29 15:10:00.280677+07	ASII	2010.60440526043	48819	BBCA	BMRI	HAKA
2026-07-01 10:26:00.280677+07	ASII	2007.4462747015111	46663	BBCA	BMRI	HAKI
2026-07-01 09:29:00.280677+07	ASII	2007.492363577793	34595	BBCA	BMRI	HAKA
2026-07-01 08:54:00.280677+07	ASII	2004.0936923858021	48649	BBCA	BMRI	HAKI
2026-07-01 07:11:00.280677+07	ASII	2003.5470440746992	50642	BBCA	BMRI	HAKI
2026-07-01 07:04:00.280677+07	ASII	2008.2594700023913	69580	BBCA	BMRI	HAKA
2026-07-01 05:40:00.280677+07	ASII	2014.7591266017214	44504	BBCA	BMRI	HAKA
2026-07-01 04:21:00.280677+07	ASII	2016.6421255733826	50609	BBCA	BMRI	HAKA
2026-07-01 03:15:00.280677+07	ASII	2023.6994132017849	52231	BBCA	BMRI	HAKA
2026-07-01 02:56:00.280677+07	ASII	2021.1983517135268	37391	BBCA	BMRI	HAKI
2026-07-01 01:17:00.280677+07	ASII	2027.860797526325	59882	BBCA	BMRI	HAKA
2026-07-01 00:54:00.280677+07	ASII	2025.5639135640515	44634	BBCA	BMRI	HAKI
2026-07-01 00:01:00.280677+07	ASII	2023.0123539291287	52485	BBCA	BMRI	HAKI
2026-06-30 22:29:00.280677+07	ASII	2017.5103450620825	48065	BBCA	BMRI	HAKI
2026-06-30 21:22:00.280677+07	ASII	2014.659527561787	67101	BBCA	BMRI	HAKI
2026-06-30 20:57:00.280677+07	ASII	2018.4011526890238	53775	BBCA	BMRI	HAKA
2026-06-30 19:11:00.280677+07	ASII	2014.598573583867	36754	BBCA	BMRI	HAKI
2026-06-30 18:07:00.280677+07	ASII	2014.0914630781806	57505	BBCA	BMRI	HAKI
2026-06-30 18:02:00.280677+07	ASII	2014.8673702779274	64185	BBCA	BMRI	HAKA
2026-06-30 16:55:00.280677+07	ASII	2017.3111418592046	50007	BBCA	BMRI	HAKA
2026-06-30 16:03:00.280677+07	ASII	2020.5402658920896	34575	BBCA	BMRI	HAKA
2026-07-02 06:06:00.280677+07	ASII	2016.6878950971313	61418	BBCA	BMRI	HAKI
2026-07-02 05:31:00.280677+07	ASII	2017.298300492464	38921	BBCA	BMRI	HAKA
2026-07-02 04:28:00.280677+07	ASII	2026.6161979588026	51332	BBCA	BMRI	HAKA
2026-07-02 03:43:00.280677+07	ASII	2025.5649925541072	45482	BBCA	BMRI	HAKI
2026-07-02 02:58:00.280677+07	ASII	2028.2689986044459	58280	BBCA	BMRI	HAKA
2026-07-02 01:59:00.280677+07	ASII	2036.1718032470112	38472	BBCA	BMRI	HAKA
2026-07-02 00:28:00.280677+07	ASII	2035.3070763162068	57720	BBCA	BMRI	HAKI
2026-07-01 23:19:00.280677+07	ASII	2041.9400378367284	35463	BBCA	BMRI	HAKA
2026-07-01 23:05:00.280677+07	ASII	2044.1553045395578	51638	BBCA	BMRI	HAKA
2026-07-01 21:12:00.280677+07	ASII	2051.6000246254093	51215	BBCA	BMRI	HAKA
2026-07-01 20:23:00.280677+07	ASII	2051.6988605289534	62645	BBCA	BMRI	HAKA
2026-07-01 19:32:00.280677+07	ASII	2051.7260809072945	69622	BBCA	BMRI	HAKA
2026-07-01 18:37:00.280677+07	ASII	2052.027581715351	49072	BBCA	BMRI	HAKA
2026-07-01 17:14:00.280677+07	ASII	2052.5942654202017	56081	BBCA	BMRI	HAKA
2026-07-01 16:36:00.280677+07	ASII	2052.4761045458004	63343	BBCA	BMRI	HAKI
2026-07-01 15:45:00.280677+07	ASII	2045.808643846136	39902	BBCA	BMRI	HAKI
2026-06-27 10:15:19.336736+07	BBCA	4041.373905521344	46654	BBCA	BMRI	HAKI
2026-06-27 09:54:19.336736+07	BBCA	4049.042109867415	38611	BBCA	BMRI	HAKA
2026-06-27 08:15:19.336736+07	BBCA	4058.9852281954877	52905	BBCA	BMRI	HAKA
2026-06-27 07:54:19.336736+07	BBCA	4053.5099516012856	63253	BBCA	BMRI	HAKI
2026-06-27 06:56:19.336736+07	BBCA	4054.6128282338345	53544	BBCA	BMRI	HAKA
2026-06-27 05:30:19.336736+07	BBCA	4057.938865665124	39591	BBCA	BMRI	HAKA
2026-06-27 04:58:19.336736+07	BBCA	4043.3553968275983	56256	BBCA	BMRI	HAKI
2026-06-27 03:20:19.336736+07	BBCA	4045.2453373051553	33612	BBCA	BMRI	HAKA
2026-06-27 03:01:19.336736+07	BBCA	4048.101746085653	42374	BBCA	BMRI	HAKA
2026-06-27 01:23:19.336736+07	BBCA	4044.1516470566717	61450	BBCA	BMRI	HAKI
2026-06-27 00:13:19.336736+07	BBCA	4035.3549773826057	48736	BBCA	BMRI	HAKI
2026-06-27 00:04:19.336736+07	BBCA	4028.8361433643236	50180	BBCA	BMRI	HAKI
2026-06-26 23:05:19.336736+07	BBCA	4036.7664590773375	47867	BBCA	BMRI	HAKA
2026-06-26 21:21:19.336736+07	BBCA	4048.370173739704	52395	BBCA	BMRI	HAKA
2026-06-26 20:22:19.336736+07	BBCA	4040.594970414041	73629	BBCA	BMRI	HAKI
2026-06-26 19:37:19.336736+07	BBCA	4031.2141014082936	60442	BBCA	BMRI	HAKI
2026-06-26 19:03:19.336736+07	BBCA	4027.391813340397	48143	BBCA	BMRI	HAKI
2026-06-26 17:36:19.336736+07	BBCA	4025.596889502149	51724	BBCA	BMRI	HAKI
2026-06-26 16:49:19.336736+07	BBCA	4026.44037655523	60060	BBCA	BMRI	HAKA
2026-06-26 15:41:19.336736+07	BBCA	4017.911325676632	26174	BBCA	BMRI	HAKI
2026-06-28 11:01:19.336736+07	BBCA	4009.302522866935	46096	BBCA	BMRI	HAKI
2026-06-28 09:16:19.336736+07	BBCA	4004.6218462951865	43655	BBCA	BMRI	HAKI
2026-06-28 08:10:19.336736+07	BBCA	4007.8314506202864	45794	BBCA	BMRI	HAKA
2026-06-28 07:22:19.336736+07	BBCA	4011.840402564402	56475	BBCA	BMRI	HAKA
2026-06-28 06:25:19.336736+07	BBCA	4005.80396344557	52813	BBCA	BMRI	HAKI
2026-06-28 05:36:19.336736+07	BBCA	4007.315786768256	56440	BBCA	BMRI	HAKA
2026-06-28 04:49:19.336736+07	BBCA	4007.2299057112095	63102	BBCA	BMRI	HAKI
2026-06-28 03:34:19.336736+07	BBCA	4001.2356392039705	32211	BBCA	BMRI	HAKI
2026-06-28 02:48:19.336736+07	BBCA	3996.6573053552543	50803	BBCA	BMRI	HAKI
2026-06-28 02:02:19.336736+07	BBCA	3991.2841456917704	39044	BBCA	BMRI	HAKI
2026-06-28 00:19:19.336736+07	BBCA	3983.2808518068955	42110	BBCA	BMRI	HAKI
2026-06-27 23:38:19.336736+07	BBCA	3985.879801341781	55649	BBCA	BMRI	HAKA
2026-06-27 22:15:19.336736+07	BBCA	3980.7729821453077	48883	BBCA	BMRI	HAKI
2026-06-27 21:14:19.336736+07	BBCA	3984.5114413927104	44216	BBCA	BMRI	HAKA
2026-06-27 20:54:19.336736+07	BBCA	3986.787858703043	54383	BBCA	BMRI	HAKA
2026-06-27 19:14:19.336736+07	BBCA	3988.2366315052413	39213	BBCA	BMRI	HAKA
2026-06-27 18:37:19.336736+07	BBCA	3994.881720870119	51748	BBCA	BMRI	HAKA
2026-06-27 17:32:19.336736+07	BBCA	3994.5100415157563	37105	BBCA	BMRI	HAKI
2026-06-27 16:08:19.336736+07	BBCA	4002.177404756239	56336	BBCA	BMRI	HAKA
2026-06-27 15:15:19.336736+07	BBCA	4015.685794480683	45636	BBCA	BMRI	HAKA
2026-06-29 10:44:19.336736+07	BBCA	3998.168518043543	55440	BBCA	BMRI	HAKI
2026-06-29 09:39:19.336736+07	BBCA	4003.782486655041	50320	BBCA	BMRI	HAKA
2026-06-29 08:46:19.336736+07	BBCA	4007.389046603829	56719	BBCA	BMRI	HAKA
2026-06-29 07:36:19.336736+07	BBCA	4002.602108336135	35905	BBCA	BMRI	HAKI
2026-06-29 06:53:19.336736+07	BBCA	3996.2873753276695	38219	BBCA	BMRI	HAKI
2026-06-29 05:36:19.336736+07	BBCA	3987.2103979073177	52185	BBCA	BMRI	HAKI
2026-06-29 04:57:19.336736+07	BBCA	3985.1011268637576	62390	BBCA	BMRI	HAKI
2026-06-29 03:24:19.336736+07	BBCA	3978.251451346343	38735	BBCA	BMRI	HAKI
2026-06-29 03:01:19.336736+07	BBCA	3971.4783178757493	52890	BBCA	BMRI	HAKI
2026-06-29 01:41:19.336736+07	BBCA	3957.4856286087215	55902	BBCA	BMRI	HAKI
2026-06-29 00:57:19.336736+07	BBCA	3945.1868146114543	55831	BBCA	BMRI	HAKI
2026-06-28 23:06:19.336736+07	BBCA	3950.594784808666	57612	BBCA	BMRI	HAKA
2026-06-28 22:31:19.336736+07	BBCA	3945.1057054138605	57464	BBCA	BMRI	HAKI
2026-06-28 21:46:19.336736+07	BBCA	3960.7311957298516	58252	BBCA	BMRI	HAKA
2026-06-28 20:34:19.336736+07	BBCA	3957.0137429539554	44009	BBCA	BMRI	HAKI
2026-06-28 19:42:19.336736+07	BBCA	3956.04244179988	37997	BBCA	BMRI	HAKI
2026-06-28 18:42:19.336736+07	BBCA	3960.4546442662163	46054	BBCA	BMRI	HAKA
2026-06-28 17:15:19.336736+07	BBCA	3962.5637652800065	68981	BBCA	BMRI	HAKA
2026-06-28 16:19:19.336736+07	BBCA	3981.6417257810344	62243	BBCA	BMRI	HAKA
2026-06-28 15:14:19.336736+07	BBCA	3967.2221044617186	52678	BBCA	BMRI	HAKI
2026-06-30 10:29:19.336736+07	BBCA	3975.707102964781	50968	BBCA	BMRI	HAKA
2026-06-30 10:00:19.336736+07	BBCA	3980.3195625013104	38431	BBCA	BMRI	HAKA
2026-06-30 08:48:19.336736+07	BBCA	3987.1358844458764	71058	BBCA	BMRI	HAKA
2026-06-30 07:22:19.336736+07	BBCA	3985.799517841963	49983	BBCA	BMRI	HAKI
2026-06-30 07:05:19.336736+07	BBCA	3974.4150501288764	67008	BBCA	BMRI	HAKI
2026-06-30 05:55:19.336736+07	BBCA	3972.5649148296843	46996	BBCA	BMRI	HAKI
2026-06-30 04:08:19.336736+07	BBCA	3983.815228049964	48988	BBCA	BMRI	HAKA
2026-06-30 03:44:19.336736+07	BBCA	3971.4013765756213	25269	BBCA	BMRI	HAKI
2026-06-30 02:31:19.336736+07	BBCA	3965.220292940294	47088	BBCA	BMRI	HAKI
2026-06-30 01:56:19.336736+07	BBCA	3968.339854921442	32487	BBCA	BMRI	HAKA
2026-06-30 00:32:19.336736+07	BBCA	3957.95293544232	55769	BBCA	BMRI	HAKI
2026-06-29 23:08:19.336736+07	BBCA	3943.697853206245	62672	BBCA	BMRI	HAKI
2026-06-29 22:58:19.336736+07	BBCA	3960.245558580861	40678	BBCA	BMRI	HAKA
2026-06-29 21:33:19.336736+07	BBCA	3969.287064217286	57572	BBCA	BMRI	HAKA
2026-06-29 21:02:19.336736+07	BBCA	3959.4297877272516	57651	BBCA	BMRI	HAKI
2026-06-29 19:27:19.336736+07	BBCA	3966.743595660249	67047	BBCA	BMRI	HAKA
2026-06-29 18:15:19.336736+07	BBCA	3955.0883562339545	40107	BBCA	BMRI	HAKI
2026-06-29 17:19:19.336736+07	BBCA	3953.910629513843	45042	BBCA	BMRI	HAKI
2026-06-29 16:59:19.336736+07	BBCA	3966.586145844479	56259	BBCA	BMRI	HAKA
2026-06-29 15:14:19.336736+07	BBCA	3965.2700287824528	34810	BBCA	BMRI	HAKI
2026-07-01 10:09:19.336736+07	BBCA	3959.243341346951	56807	BBCA	BMRI	HAKI
2026-07-01 09:56:19.336736+07	BBCA	3977.567748701235	56652	BBCA	BMRI	HAKA
2026-07-01 08:28:19.336736+07	BBCA	3971.2231109029403	61352	BBCA	BMRI	HAKI
2026-07-01 07:30:19.336736+07	BBCA	3960.26910070112	49535	BBCA	BMRI	HAKI
2026-07-01 06:20:19.336736+07	BBCA	3968.587368345652	44495	BBCA	BMRI	HAKA
2026-07-01 05:13:19.336736+07	BBCA	3976.793083619812	70379	BBCA	BMRI	HAKA
2026-07-01 04:27:19.336736+07	BBCA	3980.9509543356107	65805	BBCA	BMRI	HAKA
2026-07-01 03:29:19.336736+07	BBCA	3983.0613936632467	63809	BBCA	BMRI	HAKA
2026-07-01 02:11:19.336736+07	BBCA	3991.277164464654	35419	BBCA	BMRI	HAKA
2026-07-01 01:49:19.336736+07	BBCA	3970.7857516104327	41701	BBCA	BMRI	HAKI
2026-07-01 00:28:19.336736+07	BBCA	3954.068117745047	45864	BBCA	BMRI	HAKI
2026-06-30 23:47:19.336736+07	BBCA	3954.3762363778765	45547	BBCA	BMRI	HAKA
2026-06-30 22:11:19.336736+07	BBCA	3962.501139828334	47504	BBCA	BMRI	HAKA
2026-06-30 21:43:19.336736+07	BBCA	3963.2694050552727	54412	BBCA	BMRI	HAKA
2026-06-30 20:52:19.336736+07	BBCA	3950.5935843503075	52599	BBCA	BMRI	HAKI
2026-06-30 19:28:19.336736+07	BBCA	3948.0539784829016	49688	BBCA	BMRI	HAKI
2026-06-30 18:20:19.336736+07	BBCA	3944.875795106449	26442	BBCA	BMRI	HAKI
2026-06-30 17:23:19.336736+07	BBCA	3924.4512840515954	46002	BBCA	BMRI	HAKI
2026-06-30 16:27:19.336736+07	BBCA	3924.2485486683586	52447	BBCA	BMRI	HAKI
2026-06-30 15:42:19.336736+07	BBCA	3915.3106310262224	53053	BBCA	BMRI	HAKI
2026-07-02 06:40:19.336736+07	BBCA	3917.3257535141015	47498	BBCA	BMRI	HAKI
2026-07-02 05:37:19.336736+07	BBCA	3914.1051596977645	52274	BBCA	BMRI	HAKI
2026-07-02 04:53:19.336736+07	BBCA	3903.051445202789	61879	BBCA	BMRI	HAKI
2026-07-02 03:31:19.336736+07	BBCA	3896.318100272059	35148	BBCA	BMRI	HAKI
2026-07-02 02:25:19.336736+07	BBCA	3899.1754197731375	51417	BBCA	BMRI	HAKA
2026-07-02 01:26:19.336736+07	BBCA	3895.5097422349286	58737	BBCA	BMRI	HAKI
2026-07-02 00:22:19.336736+07	BBCA	3898.485287357621	55007	BBCA	BMRI	HAKA
2026-07-01 23:11:19.336736+07	BBCA	3893.712956711151	46964	BBCA	BMRI	HAKI
2026-07-01 23:02:19.336736+07	BBCA	3900.8536484174942	47667	BBCA	BMRI	HAKA
2026-07-01 21:38:19.336736+07	BBCA	3894.9856890136903	45731	BBCA	BMRI	HAKI
2026-07-01 21:04:19.336736+07	BBCA	3900.8819736977694	42983	BBCA	BMRI	HAKA
2026-07-01 19:11:19.336736+07	BBCA	3902.3707158904494	40313	BBCA	BMRI	HAKA
2026-07-01 18:15:19.336736+07	BBCA	3897.8899570804842	57155	BBCA	BMRI	HAKI
2026-07-01 17:44:19.336736+07	BBCA	3894.4470334695247	57881	BBCA	BMRI	HAKI
2026-07-01 16:15:19.336736+07	BBCA	3884.3225790052425	47972	BBCA	BMRI	HAKI
2026-07-01 15:35:19.336736+07	BBCA	3882.5335419245657	41994	BBCA	BMRI	HAKI
2026-06-27 10:18:20.623551+07	BBRI	2131.83445006702	58705	BBCA	BMRI	HAKI
2026-06-27 09:30:20.623551+07	BBRI	2128.0126309314574	41398	BBCA	BMRI	HAKI
2026-06-27 08:30:20.623551+07	BBRI	2121.611424764932	48198	BBCA	BMRI	HAKI
2026-06-27 07:17:20.623551+07	BBRI	2126.6280738880587	46293	BBCA	BMRI	HAKA
2026-06-27 06:36:20.623551+07	BBRI	2124.1464838307675	63562	BBCA	BMRI	HAKI
2026-06-27 05:12:20.623551+07	BBRI	2123.316744821746	54360	BBCA	BMRI	HAKI
2026-06-27 04:56:20.623551+07	BBRI	2119.523035658486	42442	BBCA	BMRI	HAKI
2026-06-27 03:13:20.623551+07	BBRI	2118.8597179680382	55332	BBCA	BMRI	HAKI
2026-06-27 02:06:20.623551+07	BBRI	2120.765551119105	40349	BBCA	BMRI	HAKA
2026-06-27 01:52:20.623551+07	BBRI	2118.300077820899	47101	BBCA	BMRI	HAKI
2026-06-27 00:59:20.623551+07	BBRI	2122.0058089382933	35603	BBCA	BMRI	HAKA
2026-06-26 23:43:20.623551+07	BBRI	2126.732694495997	54556	BBCA	BMRI	HAKA
2026-06-26 22:21:20.623551+07	BBRI	2127.072670900036	57895	BBCA	BMRI	HAKA
2026-06-26 21:09:20.623551+07	BBRI	2117.48765773868	49323	BBCA	BMRI	HAKI
2026-06-26 20:53:20.623551+07	BBRI	2119.1654437181637	47217	BBCA	BMRI	HAKA
2026-06-26 19:34:20.623551+07	BBRI	2120.566189218452	33612	BBCA	BMRI	HAKA
2026-06-26 19:00:20.623551+07	BBRI	2124.850564753444	47750	BBCA	BMRI	HAKA
2026-06-26 17:08:20.623551+07	BBRI	2119.5837244757745	46146	BBCA	BMRI	HAKI
2026-06-26 17:05:20.623551+07	BBRI	2115.5562915880682	70757	BBCA	BMRI	HAKI
2026-06-26 15:11:20.623551+07	BBRI	2112.153475714909	41521	BBCA	BMRI	HAKI
2026-06-28 10:48:20.623551+07	BBRI	2109.5716100168656	52259	BBCA	BMRI	HAKI
2026-06-28 10:04:20.623551+07	BBRI	2110.652760791078	56570	BBCA	BMRI	HAKA
2026-06-28 08:07:20.623551+07	BBRI	2102.6808735775335	41756	BBCA	BMRI	HAKI
2026-06-28 07:24:20.623551+07	BBRI	2097.030283938724	46194	BBCA	BMRI	HAKI
2026-06-28 06:52:20.623551+07	BBRI	2102.313737148198	29267	BBCA	BMRI	HAKA
2026-06-28 06:00:20.623551+07	BBRI	2107.154190664258	32073	BBCA	BMRI	HAKA
2026-06-28 04:48:20.623551+07	BBRI	2106.775213789081	65553	BBCA	BMRI	HAKI
2026-06-28 03:42:20.623551+07	BBRI	2109.327991465869	43259	BBCA	BMRI	HAKA
2026-06-28 02:32:20.623551+07	BBRI	2103.6245246868552	40041	BBCA	BMRI	HAKI
2026-06-28 01:41:20.623551+07	BBRI	2098.827392298621	42803	BBCA	BMRI	HAKI
2026-06-28 00:31:20.623551+07	BBRI	2093.580651505984	53230	BBCA	BMRI	HAKI
2026-06-27 23:55:20.623551+07	BBRI	2093.217785442234	49541	BBCA	BMRI	HAKI
2026-06-27 23:03:20.623551+07	BBRI	2098.4461801255993	48874	BBCA	BMRI	HAKA
2026-06-27 21:32:20.623551+07	BBRI	2098.425438691445	64217	BBCA	BMRI	HAKI
2026-06-27 20:15:20.623551+07	BBRI	2095.508865120203	48604	BBCA	BMRI	HAKI
2026-06-27 20:01:20.623551+07	BBRI	2090.644415247474	47186	BBCA	BMRI	HAKI
2026-06-27 18:19:20.623551+07	BBRI	2091.7014932786874	53054	BBCA	BMRI	HAKA
2026-06-27 17:36:20.623551+07	BBRI	2091.9794393476504	48918	BBCA	BMRI	HAKA
2026-06-27 16:50:20.623551+07	BBRI	2094.8585280138186	60860	BBCA	BMRI	HAKA
2026-06-27 15:12:20.623551+07	BBRI	2100.534330748948	68751	BBCA	BMRI	HAKA
2026-06-29 10:45:20.623551+07	BBRI	2105.053620115395	52158	BBCA	BMRI	HAKA
2026-06-29 10:00:20.623551+07	BBRI	2105.6503896364757	59260	BBCA	BMRI	HAKA
2026-06-29 08:52:20.623551+07	BBRI	2104.661093825846	55274	BBCA	BMRI	HAKI
2026-06-29 08:01:20.623551+07	BBRI	2110.757600739562	41272	BBCA	BMRI	HAKA
2026-06-29 06:16:20.623551+07	BBRI	2112.459924639727	45734	BBCA	BMRI	HAKA
2026-06-29 05:52:20.623551+07	BBRI	2114.0936432963367	47820	BBCA	BMRI	HAKA
2026-06-29 04:58:20.623551+07	BBRI	2112.1123811857938	60679	BBCA	BMRI	HAKI
2026-06-29 03:56:20.623551+07	BBRI	2112.148285151153	59836	BBCA	BMRI	HAKA
2026-06-29 02:17:20.623551+07	BBRI	2113.423500686067	49693	BBCA	BMRI	HAKA
2026-06-29 01:12:20.623551+07	BBRI	2103.1663530572396	62438	BBCA	BMRI	HAKI
2026-06-29 00:31:20.623551+07	BBRI	2112.3515914496247	41707	BBCA	BMRI	HAKA
2026-06-28 23:42:20.623551+07	BBRI	2121.063671954209	71577	BBCA	BMRI	HAKA
2026-06-28 22:39:20.623551+07	BBRI	2121.565504304656	55535	BBCA	BMRI	HAKA
2026-06-28 21:09:20.623551+07	BBRI	2119.805778978061	63426	BBCA	BMRI	HAKI
2026-06-28 20:18:20.623551+07	BBRI	2118.0278157235807	55386	BBCA	BMRI	HAKI
2026-06-28 19:12:20.623551+07	BBRI	2116.6037435737876	38080	BBCA	BMRI	HAKI
2026-06-28 18:32:20.623551+07	BBRI	2115.543189647548	82243	BBCA	BMRI	HAKI
2026-06-28 17:36:20.623551+07	BBRI	2119.2964600920145	51264	BBCA	BMRI	HAKA
2026-06-28 16:06:20.623551+07	BBRI	2117.110209172685	54163	BBCA	BMRI	HAKI
2026-06-28 15:15:20.623551+07	BBRI	2119.8745756012586	60013	BBCA	BMRI	HAKA
2026-06-30 10:42:20.623551+07	BBRI	2114.265256896341	46159	BBCA	BMRI	HAKI
2026-06-30 09:41:20.623551+07	BBRI	2110.7465012658286	37535	BBCA	BMRI	HAKI
2026-06-30 08:36:20.623551+07	BBRI	2109.395535639781	47377	BBCA	BMRI	HAKI
2026-06-30 07:10:20.623551+07	BBRI	2105.449496345575	61455	BBCA	BMRI	HAKI
2026-06-30 06:24:20.623551+07	BBRI	2107.267820441206	49815	BBCA	BMRI	HAKA
2026-06-30 05:14:20.623551+07	BBRI	2108.630527707645	41386	BBCA	BMRI	HAKA
2026-06-30 04:18:20.623551+07	BBRI	2110.4205403210544	52041	BBCA	BMRI	HAKA
2026-06-30 04:01:20.623551+07	BBRI	2106.084477202112	59779	BBCA	BMRI	HAKI
2026-06-30 02:54:20.623551+07	BBRI	2096.1164951567243	39737	BBCA	BMRI	HAKI
2026-06-30 01:53:20.623551+07	BBRI	2099.150417328	48908	BBCA	BMRI	HAKA
2026-06-30 00:57:20.623551+07	BBRI	2095.8579346752504	52224	BBCA	BMRI	HAKI
2026-06-29 23:43:20.623551+07	BBRI	2100.088820900872	56389	BBCA	BMRI	HAKA
2026-06-29 22:14:20.623551+07	BBRI	2097.7115477354027	40035	BBCA	BMRI	HAKI
2026-06-29 21:33:20.623551+07	BBRI	2095.0916188295337	54399	BBCA	BMRI	HAKI
2026-06-29 20:17:20.623551+07	BBRI	2090.359859194067	38627	BBCA	BMRI	HAKI
2026-06-29 19:54:20.623551+07	BBRI	2095.5571507020773	38094	BBCA	BMRI	HAKA
2026-06-29 18:54:20.623551+07	BBRI	2093.5619656491526	55048	BBCA	BMRI	HAKI
2026-06-29 17:53:20.623551+07	BBRI	2095.777594735356	40935	BBCA	BMRI	HAKA
2026-06-29 16:37:20.623551+07	BBRI	2095.1631437327505	43640	BBCA	BMRI	HAKI
2026-06-29 15:37:20.623551+07	BBRI	2086.3042703146025	76720	BBCA	BMRI	HAKI
2026-07-01 10:33:20.623551+07	BBRI	2084.524032199411	66667	BBCA	BMRI	HAKI
2026-07-01 10:04:20.623551+07	BBRI	2080.7934648521727	38800	BBCA	BMRI	HAKI
2026-07-01 08:46:20.623551+07	BBRI	2087.6174004878426	64988	BBCA	BMRI	HAKA
2026-07-01 07:50:20.623551+07	BBRI	2085.6229135206036	44649	BBCA	BMRI	HAKI
2026-07-01 06:35:20.623551+07	BBRI	2087.2658206188366	28772	BBCA	BMRI	HAKA
2026-07-01 05:36:20.623551+07	BBRI	2090.0936818382315	54635	BBCA	BMRI	HAKA
2026-07-01 04:24:20.623551+07	BBRI	2095.165807764754	36872	BBCA	BMRI	HAKA
2026-07-01 04:05:20.623551+07	BBRI	2094.995706326064	40934	BBCA	BMRI	HAKI
2026-07-01 02:28:20.623551+07	BBRI	2095.724159146504	48412	BBCA	BMRI	HAKA
2026-07-01 01:31:20.623551+07	BBRI	2101.3574017773512	61049	BBCA	BMRI	HAKA
2026-07-01 00:53:20.623551+07	BBRI	2097.0746164673374	64976	BBCA	BMRI	HAKI
2026-07-01 00:02:20.623551+07	BBRI	2098.8132921340516	53843	BBCA	BMRI	HAKA
2026-06-30 22:27:20.623551+07	BBRI	2094.0618803806133	52341	BBCA	BMRI	HAKI
2026-06-30 21:43:20.623551+07	BBRI	2097.803050973405	44685	BBCA	BMRI	HAKA
2026-06-30 20:25:20.623551+07	BBRI	2094.8363245371843	42117	BBCA	BMRI	HAKI
2026-06-30 19:19:20.623551+07	BBRI	2092.6723887602743	38207	BBCA	BMRI	HAKI
2026-06-30 18:53:20.623551+07	BBRI	2093.727580790652	55790	BBCA	BMRI	HAKA
2026-06-30 17:21:20.623551+07	BBRI	2087.761218642907	30216	BBCA	BMRI	HAKI
2026-06-30 16:37:20.623551+07	BBRI	2087.9471015768677	41963	BBCA	BMRI	HAKA
2026-06-30 15:23:20.623551+07	BBRI	2085.53911855946	60942	BBCA	BMRI	HAKI
2026-07-02 06:10:20.623551+07	BBRI	2084.7454861592028	50300	BBCA	BMRI	HAKA
2026-07-02 05:51:20.623551+07	BBRI	2080.356879770777	51373	BBCA	BMRI	HAKI
2026-07-02 05:01:20.623551+07	BBRI	2074.3643081783744	58151	BBCA	BMRI	HAKI
2026-07-02 03:52:20.623551+07	BBRI	2067.5831927074028	35447	BBCA	BMRI	HAKI
2026-07-02 02:07:20.623551+07	BBRI	2072.6288231419935	49891	BBCA	BMRI	HAKA
2026-07-02 01:22:20.623551+07	BBRI	2072.0469582323226	65722	BBCA	BMRI	HAKI
2026-07-02 01:03:20.623551+07	BBRI	2075.817045920346	49075	BBCA	BMRI	HAKA
2026-07-01 23:25:20.623551+07	BBRI	2074.6377925393726	56833	BBCA	BMRI	HAKI
2026-07-01 22:39:20.623551+07	BBRI	2070.669727928876	42443	BBCA	BMRI	HAKI
2026-07-01 22:04:20.623551+07	BBRI	2068.4794210910813	57369	BBCA	BMRI	HAKI
2026-07-01 20:33:20.623551+07	BBRI	2063.009408358553	58242	BBCA	BMRI	HAKI
2026-07-01 19:11:20.623551+07	BBRI	2060.0352360418087	69801	BBCA	BMRI	HAKI
2026-07-01 18:44:20.623551+07	BBRI	2063.506495097355	37014	BBCA	BMRI	HAKA
2026-07-01 17:50:20.623551+07	BBRI	2058.2741589853617	30431	BBCA	BMRI	HAKI
2026-07-01 16:36:20.623551+07	BBRI	2054.9704999714027	33831	BBCA	BMRI	HAKI
2026-07-01 15:14:20.623551+07	BBRI	2055.4182488771135	33431	BBCA	BMRI	HAKA
2026-06-27 10:36:21.902439+07	BMRI	5583.00325517379	60147	BBCA	BMRI	HAKA
2026-06-27 09:06:21.902439+07	BMRI	5552.987372284581	49720	BBCA	BMRI	HAKI
2026-06-27 08:22:21.902439+07	BMRI	5534.806105477757	51089	BBCA	BMRI	HAKI
2026-06-27 07:57:21.902439+07	BMRI	5537.292250834056	50195	BBCA	BMRI	HAKA
2026-06-27 06:52:21.902439+07	BMRI	5529.481425158674	65329	BBCA	BMRI	HAKI
2026-06-27 06:00:21.902439+07	BMRI	5537.135780546751	55366	BBCA	BMRI	HAKA
2026-06-27 04:41:21.902439+07	BMRI	5536.3994182576635	28662	BBCA	BMRI	HAKI
2026-06-27 03:48:21.902439+07	BMRI	5535.640006960022	53981	BBCA	BMRI	HAKI
2026-06-27 02:59:21.902439+07	BMRI	5536.810889947207	43770	BBCA	BMRI	HAKA
2026-06-27 01:49:21.902439+07	BMRI	5527.276237258569	71142	BBCA	BMRI	HAKI
2026-06-27 00:20:21.902439+07	BMRI	5548.552956036129	42820	BBCA	BMRI	HAKA
2026-06-26 23:14:21.902439+07	BMRI	5558.276841936297	66710	BBCA	BMRI	HAKA
2026-06-26 22:58:21.902439+07	BMRI	5566.726422602776	53920	BBCA	BMRI	HAKA
2026-06-26 21:54:21.902439+07	BMRI	5582.782702845849	38582	BBCA	BMRI	HAKA
2026-06-26 20:22:21.902439+07	BMRI	5582.197602439644	53722	BBCA	BMRI	HAKI
2026-06-26 19:08:21.902439+07	BMRI	5578.030300950784	39757	BBCA	BMRI	HAKI
2026-06-26 18:39:21.902439+07	BMRI	5559.114440994381	48644	BBCA	BMRI	HAKI
2026-06-26 17:14:21.902439+07	BMRI	5553.76624734367	52747	BBCA	BMRI	HAKI
2026-06-26 16:57:21.902439+07	BMRI	5558.134335158307	41844	BBCA	BMRI	HAKA
2026-06-26 15:25:21.902439+07	BMRI	5572.959594234598	37190	BBCA	BMRI	HAKA
2026-06-28 10:41:21.902439+07	BMRI	5573.500779499044	52863	BBCA	BMRI	HAKA
2026-06-28 10:02:21.902439+07	BMRI	5571.858688655557	53263	BBCA	BMRI	HAKI
2026-06-28 08:17:21.902439+07	BMRI	5562.37844827391	61102	BBCA	BMRI	HAKI
2026-06-28 07:40:21.902439+07	BMRI	5581.073854623676	53617	BBCA	BMRI	HAKA
2026-06-28 06:49:21.902439+07	BMRI	5585.882591850844	30615	BBCA	BMRI	HAKA
2026-06-28 05:42:21.902439+07	BMRI	5606.87013798627	43168	BBCA	BMRI	HAKA
2026-06-28 04:56:21.902439+07	BMRI	5604.225391810609	47223	BBCA	BMRI	HAKI
2026-06-28 03:26:21.902439+07	BMRI	5617.942527817815	50789	BBCA	BMRI	HAKA
2026-06-28 02:37:21.902439+07	BMRI	5606.173637827023	48453	BBCA	BMRI	HAKI
2026-06-28 02:00:21.902439+07	BMRI	5607.4892993562735	50690	BBCA	BMRI	HAKA
2026-06-28 00:10:21.902439+07	BMRI	5602.875809404148	53720	BBCA	BMRI	HAKI
2026-06-27 23:23:21.902439+07	BMRI	5622.084343005711	59960	BBCA	BMRI	HAKA
2026-06-27 22:07:21.902439+07	BMRI	5638.763736350448	65783	BBCA	BMRI	HAKA
2026-06-27 21:29:21.902439+07	BMRI	5650.589984799049	60421	BBCA	BMRI	HAKA
2026-06-27 20:33:21.902439+07	BMRI	5644.6396425528155	37712	BBCA	BMRI	HAKI
2026-06-27 19:19:21.902439+07	BMRI	5664.774151546739	43878	BBCA	BMRI	HAKA
2026-06-27 18:06:21.902439+07	BMRI	5656.942565723042	29911	BBCA	BMRI	HAKI
2026-06-27 17:13:21.902439+07	BMRI	5666.003292246135	45310	BBCA	BMRI	HAKA
2026-06-27 16:46:21.902439+07	BMRI	5667.03935401299	45217	BBCA	BMRI	HAKA
2026-06-27 15:30:21.902439+07	BMRI	5652.478311983006	50683	BBCA	BMRI	HAKI
2026-06-29 10:30:21.902439+07	BMRI	5658.80958741963	40990	BBCA	BMRI	HAKA
2026-06-29 09:34:21.902439+07	BMRI	5670.92685604096	53155	BBCA	BMRI	HAKA
2026-06-29 08:20:21.902439+07	BMRI	5672.4658178282	52024	BBCA	BMRI	HAKA
2026-06-29 07:19:21.902439+07	BMRI	5658.856607027943	46005	BBCA	BMRI	HAKI
2026-06-29 06:55:21.902439+07	BMRI	5649.223502320739	39085	BBCA	BMRI	HAKI
2026-06-29 05:58:21.902439+07	BMRI	5653.195618712018	38853	BBCA	BMRI	HAKA
2026-06-29 04:33:21.902439+07	BMRI	5635.750038719346	57199	BBCA	BMRI	HAKI
2026-06-29 04:01:21.902439+07	BMRI	5634.077186438965	52388	BBCA	BMRI	HAKI
2026-06-29 02:13:21.902439+07	BMRI	5632.471205031986	33121	BBCA	BMRI	HAKI
2026-06-29 01:12:21.902439+07	BMRI	5652.846250803933	66728	BBCA	BMRI	HAKA
2026-06-29 00:24:21.902439+07	BMRI	5643.699434266648	52720	BBCA	BMRI	HAKI
2026-06-28 23:37:21.902439+07	BMRI	5639.038611071017	40863	BBCA	BMRI	HAKI
2026-06-28 22:53:21.902439+07	BMRI	5644.634631216165	38573	BBCA	BMRI	HAKA
2026-06-28 21:55:21.902439+07	BMRI	5658.176659298719	57227	BBCA	BMRI	HAKA
2026-06-28 20:07:21.902439+07	BMRI	5656.055903215016	56218	BBCA	BMRI	HAKI
2026-06-28 19:34:21.902439+07	BMRI	5652.964726641499	56411	BBCA	BMRI	HAKI
2026-06-28 19:02:21.902439+07	BMRI	5626.835080137231	59153	BBCA	BMRI	HAKI
2026-06-28 17:07:21.902439+07	BMRI	5641.401511353883	65390	BBCA	BMRI	HAKA
2026-06-28 16:38:21.902439+07	BMRI	5652.3784262506	55671	BBCA	BMRI	HAKA
2026-06-28 15:21:21.902439+07	BMRI	5671.132224015015	48284	BBCA	BMRI	HAKA
2026-06-30 10:18:21.902439+07	BMRI	5671.98786097524	36990	BBCA	BMRI	HAKA
2026-06-30 09:40:21.902439+07	BMRI	5687.901933993867	42192	BBCA	BMRI	HAKA
2026-06-30 08:53:21.902439+07	BMRI	5703.119447451043	48006	BBCA	BMRI	HAKA
2026-06-30 07:52:21.902439+07	BMRI	5703.043147299793	41499	BBCA	BMRI	HAKI
2026-06-30 06:36:21.902439+07	BMRI	5713.91423549041	26185	BBCA	BMRI	HAKA
2026-06-30 05:21:21.902439+07	BMRI	5704.761127819199	54173	BBCA	BMRI	HAKI
2026-06-30 04:52:21.902439+07	BMRI	5700.562934168345	48616	BBCA	BMRI	HAKI
2026-06-30 03:59:21.902439+07	BMRI	5722.782516528184	55649	BBCA	BMRI	HAKA
2026-06-30 02:36:21.902439+07	BMRI	5736.637265862817	49059	BBCA	BMRI	HAKA
2026-06-30 01:24:21.902439+07	BMRI	5763.71623564743	37725	BBCA	BMRI	HAKA
2026-06-30 00:09:21.902439+07	BMRI	5763.2210529169815	57492	BBCA	BMRI	HAKI
2026-06-29 23:51:21.902439+07	BMRI	5759.9371072866725	41508	BBCA	BMRI	HAKI
2026-06-29 22:49:21.902439+07	BMRI	5770.596584677107	36453	BBCA	BMRI	HAKA
2026-06-29 21:09:21.902439+07	BMRI	5761.400976638696	50283	BBCA	BMRI	HAKI
2026-06-29 20:13:21.902439+07	BMRI	5763.265183612268	36101	BBCA	BMRI	HAKA
2026-06-29 19:46:21.902439+07	BMRI	5740.043264000591	47911	BBCA	BMRI	HAKI
2026-06-29 18:21:21.902439+07	BMRI	5731.450778662764	49730	BBCA	BMRI	HAKI
2026-06-29 17:09:21.902439+07	BMRI	5727.718195928434	40575	BBCA	BMRI	HAKI
2026-06-29 16:34:21.902439+07	BMRI	5722.056505377329	33700	BBCA	BMRI	HAKI
2026-06-29 15:40:21.902439+07	BMRI	5737.391734150156	70981	BBCA	BMRI	HAKA
2026-07-01 11:05:21.902439+07	BMRI	5744.6514922300885	38344	BBCA	BMRI	HAKA
2026-07-01 09:40:21.902439+07	BMRI	5744.83470290555	53171	BBCA	BMRI	HAKA
2026-07-01 08:16:21.902439+07	BMRI	5734.7018567101495	38514	BBCA	BMRI	HAKI
2026-07-01 07:15:21.902439+07	BMRI	5723.460898867865	40965	BBCA	BMRI	HAKI
2026-07-01 06:25:21.902439+07	BMRI	5730.753314493258	51277	BBCA	BMRI	HAKA
2026-07-01 05:57:21.902439+07	BMRI	5742.742331426645	68660	BBCA	BMRI	HAKA
2026-07-01 04:53:21.902439+07	BMRI	5744.52994645934	51193	BBCA	BMRI	HAKA
2026-07-01 03:22:21.902439+07	BMRI	5752.271347985591	45262	BBCA	BMRI	HAKA
2026-07-01 02:59:21.902439+07	BMRI	5735.279674428543	52917	BBCA	BMRI	HAKI
2026-07-01 01:22:21.902439+07	BMRI	5736.86526791123	35938	BBCA	BMRI	HAKA
2026-07-01 01:03:21.902439+07	BMRI	5734.537481906839	49012	BBCA	BMRI	HAKI
2026-06-30 23:09:21.902439+07	BMRI	5739.053736160886	33512	BBCA	BMRI	HAKA
2026-06-30 22:22:21.902439+07	BMRI	5758.349609777616	39568	BBCA	BMRI	HAKA
2026-06-30 21:20:21.902439+07	BMRI	5753.727841101542	55828	BBCA	BMRI	HAKI
2026-06-30 20:56:21.902439+07	BMRI	5727.242542144442	50538	BBCA	BMRI	HAKI
2026-06-30 19:09:21.902439+07	BMRI	5736.5752072415125	50863	BBCA	BMRI	HAKA
2026-06-30 18:45:21.902439+07	BMRI	5750.215878539283	56746	BBCA	BMRI	HAKA
2026-06-30 17:35:21.902439+07	BMRI	5770.239939333607	51263	BBCA	BMRI	HAKA
2026-06-30 16:29:21.902439+07	BMRI	5789.850762179143	42820	BBCA	BMRI	HAKA
2026-06-30 15:52:21.902439+07	BMRI	5762.324146759129	57232	BBCA	BMRI	HAKI
2026-07-02 05:26:21.902439+07	BMRI	5732.2159834346185	51503	BBCA	BMRI	HAKA
2026-07-02 04:26:21.902439+07	BMRI	5749.1652646554885	35282	BBCA	BMRI	HAKA
2026-07-02 03:45:21.902439+07	BMRI	5759.464365110102	55060	BBCA	BMRI	HAKA
2026-07-02 02:23:21.902439+07	BMRI	5775.186068354071	58598	BBCA	BMRI	HAKA
2026-07-02 01:24:21.902439+07	BMRI	5796.000857405144	53654	BBCA	BMRI	HAKA
2026-07-02 01:01:21.902439+07	BMRI	5784.777132332314	53020	BBCA	BMRI	HAKI
2026-07-01 23:45:21.902439+07	BMRI	5789.709865666326	46220	BBCA	BMRI	HAKA
2026-07-01 22:41:21.902439+07	BMRI	5781.872828903191	50826	BBCA	BMRI	HAKI
2026-07-01 21:24:21.902439+07	BMRI	5777.206627248461	40142	BBCA	BMRI	HAKI
2026-07-01 20:20:21.902439+07	BMRI	5775.365172356749	52466	BBCA	BMRI	HAKI
2026-07-01 19:56:21.902439+07	BMRI	5781.249191972693	49204	BBCA	BMRI	HAKA
2026-07-01 18:21:21.902439+07	BMRI	5783.225179717864	39940	BBCA	BMRI	HAKA
2026-07-01 17:33:21.902439+07	BMRI	5793.1021305196855	39972	BBCA	BMRI	HAKA
2026-07-01 16:30:21.902439+07	BMRI	5782.735163326626	40948	BBCA	BMRI	HAKI
2026-07-01 15:06:21.902439+07	BMRI	5763.360839349564	32517	BBCA	BMRI	HAKI
2026-06-27 10:15:23.294413+07	TLKM	1512.9411375349011	48141	BBCA	BMRI	HAKA
2026-06-27 10:02:23.294413+07	TLKM	1510.4665187550097	43115	BBCA	BMRI	HAKI
2026-06-27 08:30:23.294413+07	TLKM	1511.4010443593802	60615	BBCA	BMRI	HAKA
2026-06-27 07:40:23.294413+07	TLKM	1511.0828226579474	42602	BBCA	BMRI	HAKI
2026-06-27 06:38:23.294413+07	TLKM	1513.7076129532654	27811	BBCA	BMRI	HAKA
2026-06-27 05:31:23.294413+07	TLKM	1517.6829637115254	43196	BBCA	BMRI	HAKA
2026-06-27 04:45:23.294413+07	TLKM	1518.5779495107054	35782	BBCA	BMRI	HAKA
2026-06-27 03:57:23.294413+07	TLKM	1517.7838751823906	52312	BBCA	BMRI	HAKI
2026-06-27 02:26:23.294413+07	TLKM	1515.498992733917	63075	BBCA	BMRI	HAKI
2026-06-27 01:24:23.294413+07	TLKM	1513.4680450693106	63315	BBCA	BMRI	HAKI
2026-06-27 00:19:23.294413+07	TLKM	1509.7216918719857	57109	BBCA	BMRI	HAKI
2026-06-26 23:59:23.294413+07	TLKM	1511.101316908146	64226	BBCA	BMRI	HAKA
2026-06-26 22:51:23.294413+07	TLKM	1510.5657285475982	49722	BBCA	BMRI	HAKI
2026-06-26 21:29:23.294413+07	TLKM	1508.9001027876427	49606	BBCA	BMRI	HAKI
2026-06-26 20:15:23.294413+07	TLKM	1508.1849991737206	59546	BBCA	BMRI	HAKI
2026-06-26 19:40:23.294413+07	TLKM	1508.4605464498745	45704	BBCA	BMRI	HAKA
2026-06-26 18:46:23.294413+07	TLKM	1508.4843355793057	55047	BBCA	BMRI	HAKA
2026-06-26 17:55:23.294413+07	TLKM	1505.4348950675387	43667	BBCA	BMRI	HAKI
2026-06-26 16:13:23.294413+07	TLKM	1508.6768726954515	54370	BBCA	BMRI	HAKA
2026-06-26 15:23:23.294413+07	TLKM	1509.4048819368995	59346	BBCA	BMRI	HAKA
2026-06-28 10:34:23.294413+07	TLKM	1500.1887759988226	53656	BBCA	BMRI	HAKI
2026-06-28 09:32:23.294413+07	TLKM	1500.9134126171086	38431	BBCA	BMRI	HAKA
2026-06-28 08:34:23.294413+07	TLKM	1500.0649133642778	61981	BBCA	BMRI	HAKI
2026-06-28 07:11:23.294413+07	TLKM	1496.7226222390468	59286	BBCA	BMRI	HAKI
2026-06-28 06:06:23.294413+07	TLKM	1499.7959298405947	51747	BBCA	BMRI	HAKA
2026-06-28 05:41:23.294413+07	TLKM	1501.9353018296915	50302	BBCA	BMRI	HAKA
2026-06-28 04:54:23.294413+07	TLKM	1500.830540358226	45064	BBCA	BMRI	HAKI
2026-06-28 03:11:23.294413+07	TLKM	1501.2998866457476	53686	BBCA	BMRI	HAKA
2026-06-28 02:44:23.294413+07	TLKM	1502.5688603531707	33173	BBCA	BMRI	HAKA
2026-06-28 01:40:23.294413+07	TLKM	1505.5572585024502	27260	BBCA	BMRI	HAKA
2026-06-28 00:49:23.294413+07	TLKM	1507.5053875181695	61918	BBCA	BMRI	HAKA
2026-06-27 23:48:23.294413+07	TLKM	1512.8695252951288	53304	BBCA	BMRI	HAKA
2026-06-27 22:57:23.294413+07	TLKM	1511.4783905449701	44777	BBCA	BMRI	HAKI
2026-06-27 21:27:23.294413+07	TLKM	1515.210193851679	45340	BBCA	BMRI	HAKA
2026-06-27 20:50:23.294413+07	TLKM	1510.963386110442	53524	BBCA	BMRI	HAKI
2026-06-27 19:42:23.294413+07	TLKM	1508.9185713401241	60791	BBCA	BMRI	HAKI
2026-06-27 18:10:23.294413+07	TLKM	1511.6947381685839	52805	BBCA	BMRI	HAKA
2026-06-27 17:40:23.294413+07	TLKM	1513.6523772620437	55458	BBCA	BMRI	HAKA
2026-06-27 16:44:23.294413+07	TLKM	1511.0330562774595	63817	BBCA	BMRI	HAKI
2026-06-27 15:54:23.294413+07	TLKM	1512.50961481754	51945	BBCA	BMRI	HAKA
2026-06-29 10:57:23.294413+07	TLKM	1512.086013012351	49022	BBCA	BMRI	HAKI
2026-06-29 09:32:23.294413+07	TLKM	1503.4466018813164	55862	BBCA	BMRI	HAKI
2026-06-29 08:57:23.294413+07	TLKM	1500.4105476091631	74985	BBCA	BMRI	HAKI
2026-06-29 07:29:23.294413+07	TLKM	1500.0428681725577	64699	BBCA	BMRI	HAKI
2026-06-29 06:35:23.294413+07	TLKM	1503.5258833471723	44354	BBCA	BMRI	HAKA
2026-06-29 05:28:23.294413+07	TLKM	1499.4469797179388	52251	BBCA	BMRI	HAKI
2026-06-29 05:02:23.294413+07	TLKM	1499.7115981403304	46543	BBCA	BMRI	HAKA
2026-06-29 03:39:23.294413+07	TLKM	1500.2469268261848	38449	BBCA	BMRI	HAKA
2026-06-29 03:00:23.294413+07	TLKM	1502.6572168987	39376	BBCA	BMRI	HAKA
2026-06-29 01:10:23.294413+07	TLKM	1508.6642677266905	53890	BBCA	BMRI	HAKA
2026-06-29 00:18:23.294413+07	TLKM	1503.499157253247	34775	BBCA	BMRI	HAKI
2026-06-28 23:26:23.294413+07	TLKM	1501.8830509183394	62283	BBCA	BMRI	HAKI
2026-06-28 22:48:23.294413+07	TLKM	1507.5904987583363	50713	BBCA	BMRI	HAKA
2026-06-28 21:50:23.294413+07	TLKM	1504.9789393102565	60320	BBCA	BMRI	HAKI
2026-06-28 20:44:23.294413+07	TLKM	1501.8145795477913	43029	BBCA	BMRI	HAKI
2026-06-28 19:41:23.294413+07	TLKM	1496.1316475738342	50377	BBCA	BMRI	HAKI
2026-06-28 18:20:23.294413+07	TLKM	1497.3878584327983	44006	BBCA	BMRI	HAKA
2026-06-28 17:20:23.294413+07	TLKM	1497.112724499109	71650	BBCA	BMRI	HAKI
2026-06-28 16:19:23.294413+07	TLKM	1492.8026141375153	60274	BBCA	BMRI	HAKI
2026-06-28 15:59:23.294413+07	TLKM	1493.2867013407797	58045	BBCA	BMRI	HAKA
2026-06-30 10:46:23.294413+07	TLKM	1497.294721645082	30756	BBCA	BMRI	HAKA
2026-06-30 09:18:23.294413+07	TLKM	1497.6057644312273	48944	BBCA	BMRI	HAKA
2026-06-30 08:21:23.294413+07	TLKM	1497.7906174474804	59118	BBCA	BMRI	HAKA
2026-06-30 07:26:23.294413+07	TLKM	1495.8960673685183	58052	BBCA	BMRI	HAKI
2026-06-30 06:20:23.294413+07	TLKM	1490.9982869947457	34257	BBCA	BMRI	HAKI
2026-06-30 05:53:23.294413+07	TLKM	1492.2761562673	64187	BBCA	BMRI	HAKA
2026-06-30 04:57:23.294413+07	TLKM	1490.02332436493	66693	BBCA	BMRI	HAKI
2026-06-30 03:26:23.294413+07	TLKM	1488.4539269173472	64324	BBCA	BMRI	HAKI
2026-06-30 02:34:23.294413+07	TLKM	1493.7268075101194	42637	BBCA	BMRI	HAKA
2026-06-30 01:50:23.294413+07	TLKM	1491.9876509731696	33244	BBCA	BMRI	HAKI
2026-06-30 00:50:23.294413+07	TLKM	1496.5007600543217	39743	BBCA	BMRI	HAKA
2026-06-30 00:01:23.294413+07	TLKM	1499.239751393876	49739	BBCA	BMRI	HAKA
2026-06-29 22:51:23.294413+07	TLKM	1501.5466298526685	66058	BBCA	BMRI	HAKA
2026-06-29 21:57:23.294413+07	TLKM	1503.8535314900216	50782	BBCA	BMRI	HAKA
2026-06-29 20:11:23.294413+07	TLKM	1500.1722604130302	58307	BBCA	BMRI	HAKI
2026-06-29 19:20:23.294413+07	TLKM	1494.6259674912344	58571	BBCA	BMRI	HAKI
2026-06-29 18:31:23.294413+07	TLKM	1497.3671799106253	64921	BBCA	BMRI	HAKA
2026-06-29 17:41:23.294413+07	TLKM	1496.1321123514363	57771	BBCA	BMRI	HAKI
2026-06-29 17:02:23.294413+07	TLKM	1497.6993326105026	33943	BBCA	BMRI	HAKA
2026-06-29 15:09:23.294413+07	TLKM	1502.5391764148806	40134	BBCA	BMRI	HAKA
2026-07-01 10:46:23.294413+07	TLKM	1506.8855645703647	62030	BBCA	BMRI	HAKA
2026-07-01 09:37:23.294413+07	TLKM	1503.9559544993738	34476	BBCA	BMRI	HAKI
2026-07-01 08:40:23.294413+07	TLKM	1503.4107284286276	59739	BBCA	BMRI	HAKI
2026-07-01 07:31:23.294413+07	TLKM	1505.8010952338432	39993	BBCA	BMRI	HAKA
2026-07-01 06:56:23.294413+07	TLKM	1507.1579785075721	53428	BBCA	BMRI	HAKA
2026-07-01 05:21:23.294413+07	TLKM	1507.3268181050623	46036	BBCA	BMRI	HAKA
2026-07-01 04:29:23.294413+07	TLKM	1499.1637419672952	53909	BBCA	BMRI	HAKI
2026-07-01 03:56:23.294413+07	TLKM	1496.2853655792305	37181	BBCA	BMRI	HAKI
2026-07-01 03:00:23.294413+07	TLKM	1497.3276760764063	45632	BBCA	BMRI	HAKA
2026-07-01 01:57:23.294413+07	TLKM	1500.1038832429965	35215	BBCA	BMRI	HAKA
2026-07-01 00:32:23.294413+07	TLKM	1497.751782187603	42759	BBCA	BMRI	HAKI
2026-06-30 23:44:23.294413+07	TLKM	1500.2339135508319	49963	BBCA	BMRI	HAKA
2026-06-30 22:55:23.294413+07	TLKM	1499.997031227761	25957	BBCA	BMRI	HAKI
2026-06-30 21:44:23.294413+07	TLKM	1503.4563147235992	49108	BBCA	BMRI	HAKA
2026-06-30 20:44:23.294413+07	TLKM	1506.8968836155238	41199	BBCA	BMRI	HAKA
2026-06-30 19:48:23.294413+07	TLKM	1509.903314410283	50219	BBCA	BMRI	HAKA
2026-06-30 18:31:23.294413+07	TLKM	1510.634713814872	39166	BBCA	BMRI	HAKA
2026-06-30 17:06:23.294413+07	TLKM	1507.7649334866587	32484	BBCA	BMRI	HAKI
2026-06-30 17:01:23.294413+07	TLKM	1507.9893382836387	57783	BBCA	BMRI	HAKA
2026-06-30 15:42:23.294413+07	TLKM	1507.1442300293734	46499	BBCA	BMRI	HAKI
2026-07-02 06:25:23.294413+07	TLKM	1512.977912300197	55873	BBCA	BMRI	HAKA
2026-07-02 05:56:23.294413+07	TLKM	1512.3980549812243	42694	BBCA	BMRI	HAKI
2026-07-02 04:46:23.294413+07	TLKM	1506.717504063316	46719	BBCA	BMRI	HAKI
2026-07-02 03:16:23.294413+07	TLKM	1514.479555141258	44369	BBCA	BMRI	HAKA
2026-07-02 02:51:23.294413+07	TLKM	1518.6648036132347	70477	BBCA	BMRI	HAKA
2026-07-02 01:13:23.294413+07	TLKM	1517.1515777424697	43766	BBCA	BMRI	HAKI
2026-07-02 00:38:23.294413+07	TLKM	1516.934934309328	56825	BBCA	BMRI	HAKI
2026-07-01 23:25:23.294413+07	TLKM	1512.6493838060455	42325	BBCA	BMRI	HAKI
2026-07-01 22:50:23.294413+07	TLKM	1515.8634734729694	76093	BBCA	BMRI	HAKA
2026-07-01 21:51:23.294413+07	TLKM	1514.0675714532285	47356	BBCA	BMRI	HAKI
2026-07-01 20:12:23.294413+07	TLKM	1513.4133754810493	55798	BBCA	BMRI	HAKI
2026-07-01 19:24:23.294413+07	TLKM	1511.986501057139	44125	BBCA	BMRI	HAKI
2026-07-01 18:22:23.294413+07	TLKM	1504.6996483187986	41502	BBCA	BMRI	HAKI
2026-07-01 17:29:23.294413+07	TLKM	1503.1882970137228	54794	BBCA	BMRI	HAKI
2026-07-01 17:02:23.294413+07	TLKM	1502.8161382517076	42428	BBCA	BMRI	HAKI
2026-07-01 15:47:23.294413+07	TLKM	1509.146660989475	52785	BBCA	BMRI	HAKA
2026-06-27 10:43:24.552408+07	ASII	3880.060310931742	39279	BBCA	BMRI	HAKI
2026-06-27 09:48:24.552408+07	ASII	3862.823677633462	32099	BBCA	BMRI	HAKI
2026-06-27 08:46:24.552408+07	ASII	3858.296557955445	55807	BBCA	BMRI	HAKI
2026-06-27 07:35:24.552408+07	ASII	3839.176459764293	47670	BBCA	BMRI	HAKI
2026-06-27 06:29:24.552408+07	ASII	3838.8228244988136	56339	BBCA	BMRI	HAKI
2026-06-27 06:00:24.552408+07	ASII	3850.2694860685465	53771	BBCA	BMRI	HAKA
2026-06-27 04:18:24.552408+07	ASII	3850.8728488150596	59544	BBCA	BMRI	HAKA
2026-06-27 04:02:24.552408+07	ASII	3853.0900738188934	52851	BBCA	BMRI	HAKA
2026-06-27 02:20:24.552408+07	ASII	3849.2477257343503	41823	BBCA	BMRI	HAKI
2026-06-27 01:50:24.552408+07	ASII	3841.771702320296	70861	BBCA	BMRI	HAKI
2026-06-27 00:46:24.552408+07	ASII	3850.459473994559	42275	BBCA	BMRI	HAKA
2026-06-26 23:16:24.552408+07	ASII	3858.6267866279295	52277	BBCA	BMRI	HAKA
2026-06-26 22:51:24.552408+07	ASII	3866.229149279202	50113	BBCA	BMRI	HAKA
2026-06-26 22:04:24.552408+07	ASII	3876.7687501355217	67365	BBCA	BMRI	HAKA
2026-06-26 20:44:24.552408+07	ASII	3884.7637696999127	46905	BBCA	BMRI	HAKA
2026-06-26 19:56:24.552408+07	ASII	3874.489440579818	51874	BBCA	BMRI	HAKI
2026-06-26 18:37:24.552408+07	ASII	3885.3974508199653	35088	BBCA	BMRI	HAKA
2026-06-26 17:37:24.552408+07	ASII	3888.5756492151813	47155	BBCA	BMRI	HAKA
2026-06-26 16:26:24.552408+07	ASII	3877.279971635004	46998	BBCA	BMRI	HAKI
2026-06-26 15:55:24.552408+07	ASII	3869.2608972636963	51588	BBCA	BMRI	HAKI
2026-06-28 10:55:24.552408+07	ASII	3866.223604994854	69310	BBCA	BMRI	HAKI
2026-06-28 09:35:24.552408+07	ASII	3865.0998871323036	36917	BBCA	BMRI	HAKI
2026-06-28 08:53:24.552408+07	ASII	3871.7548880271365	67730	BBCA	BMRI	HAKA
2026-06-28 07:37:24.552408+07	ASII	3866.863679470462	43703	BBCA	BMRI	HAKI
2026-06-28 06:14:24.552408+07	ASII	3868.4844247099004	54704	BBCA	BMRI	HAKA
2026-06-28 06:01:24.552408+07	ASII	3861.9577137404435	64021	BBCA	BMRI	HAKI
2026-06-28 05:00:24.552408+07	ASII	3877.90543144605	57399	BBCA	BMRI	HAKA
2026-06-28 03:26:24.552408+07	ASII	3894.695571169265	46095	BBCA	BMRI	HAKA
2026-06-28 02:53:24.552408+07	ASII	3907.454357221406	40136	BBCA	BMRI	HAKA
2026-06-28 01:10:24.552408+07	ASII	3914.027800629198	58823	BBCA	BMRI	HAKA
2026-06-28 00:34:24.552408+07	ASII	3913.616311817546	45011	BBCA	BMRI	HAKI
2026-06-27 23:27:24.552408+07	ASII	3910.6043210895486	45445	BBCA	BMRI	HAKI
2026-06-27 22:36:24.552408+07	ASII	3909.2901681767203	56652	BBCA	BMRI	HAKI
2026-06-27 21:44:24.552408+07	ASII	3909.175098882252	43282	BBCA	BMRI	HAKI
2026-06-27 20:36:24.552408+07	ASII	3899.154474665166	35321	BBCA	BMRI	HAKI
2026-06-27 19:28:24.552408+07	ASII	3894.841913945007	43592	BBCA	BMRI	HAKI
2026-06-27 18:55:24.552408+07	ASII	3900.775728092294	27806	BBCA	BMRI	HAKA
2026-06-27 17:25:24.552408+07	ASII	3881.4306665374766	33165	BBCA	BMRI	HAKI
2026-06-27 16:11:24.552408+07	ASII	3891.0560756702316	50976	BBCA	BMRI	HAKA
2026-06-27 15:12:24.552408+07	ASII	3891.1182070685927	46030	BBCA	BMRI	HAKA
2026-06-29 10:48:24.552408+07	ASII	3902.1385656181014	63670	BBCA	BMRI	HAKA
2026-06-29 09:34:24.552408+07	ASII	3900.8243018904827	43234	BBCA	BMRI	HAKI
2026-06-29 08:17:24.552408+07	ASII	3910.302576722667	37235	BBCA	BMRI	HAKA
2026-06-29 07:18:24.552408+07	ASII	3911.5676639539943	42495	BBCA	BMRI	HAKA
2026-06-29 06:53:24.552408+07	ASII	3905.7278807063713	34016	BBCA	BMRI	HAKI
2026-06-29 05:08:24.552408+07	ASII	3898.0280378104426	63859	BBCA	BMRI	HAKI
2026-06-29 04:58:24.552408+07	ASII	3901.288150091775	59284	BBCA	BMRI	HAKA
2026-06-29 03:37:24.552408+07	ASII	3900.2711459797188	62446	BBCA	BMRI	HAKI
2026-06-29 02:13:24.552408+07	ASII	3914.3244523721414	39202	BBCA	BMRI	HAKA
2026-06-29 01:48:24.552408+07	ASII	3913.206048903126	47611	BBCA	BMRI	HAKI
2026-06-29 00:56:24.552408+07	ASII	3916.554844390809	33101	BBCA	BMRI	HAKA
2026-06-28 23:23:24.552408+07	ASII	3923.390113386165	39209	BBCA	BMRI	HAKA
2026-06-28 22:40:24.552408+07	ASII	3917.2040135343354	51636	BBCA	BMRI	HAKI
2026-06-28 21:27:24.552408+07	ASII	3921.415277447494	34658	BBCA	BMRI	HAKA
2026-06-28 20:46:24.552408+07	ASII	3914.115530252907	30642	BBCA	BMRI	HAKI
2026-06-28 19:33:24.552408+07	ASII	3911.402369513964	56463	BBCA	BMRI	HAKI
2026-06-28 18:54:24.552408+07	ASII	3911.733105222433	37385	BBCA	BMRI	HAKA
2026-06-28 17:13:24.552408+07	ASII	3906.037782287082	37732	BBCA	BMRI	HAKI
2026-06-28 16:23:24.552408+07	ASII	3913.9559527935126	23491	BBCA	BMRI	HAKA
2026-06-28 15:07:24.552408+07	ASII	3915.4949777455217	47904	BBCA	BMRI	HAKA
2026-06-30 11:02:24.552408+07	ASII	3918.7222495423434	53990	BBCA	BMRI	HAKA
2026-06-30 09:54:24.552408+07	ASII	3918.824923355886	47658	BBCA	BMRI	HAKA
2026-06-30 08:08:24.552408+07	ASII	3923.787272490597	47400	BBCA	BMRI	HAKA
2026-06-30 07:18:24.552408+07	ASII	3933.9143109005167	45051	BBCA	BMRI	HAKA
2026-06-30 06:39:24.552408+07	ASII	3937.8215194783743	63683	BBCA	BMRI	HAKA
2026-06-30 05:51:24.552408+07	ASII	3960.3125604519782	56973	BBCA	BMRI	HAKA
2026-06-30 04:55:24.552408+07	ASII	3964.476065903166	60680	BBCA	BMRI	HAKA
2026-06-30 03:22:24.552408+07	ASII	3957.3004220090697	46125	BBCA	BMRI	HAKI
2026-06-30 02:24:24.552408+07	ASII	3954.901215127022	49491	BBCA	BMRI	HAKI
2026-06-30 01:24:24.552408+07	ASII	3977.3074989421657	43700	BBCA	BMRI	HAKA
2026-06-30 01:03:24.552408+07	ASII	3978.5130378176327	43458	BBCA	BMRI	HAKA
2026-06-29 23:55:24.552408+07	ASII	3973.670041819892	58996	BBCA	BMRI	HAKI
2026-06-29 23:00:24.552408+07	ASII	3972.431644437915	45886	BBCA	BMRI	HAKI
2026-06-29 21:40:24.552408+07	ASII	3976.5688130915523	43321	BBCA	BMRI	HAKA
2026-06-29 20:10:24.552408+07	ASII	3971.9286974197666	36506	BBCA	BMRI	HAKI
2026-06-29 19:15:24.552408+07	ASII	3968.7317181899425	50054	BBCA	BMRI	HAKI
2026-06-29 18:20:24.552408+07	ASII	3970.3999267057375	36000	BBCA	BMRI	HAKA
2026-06-29 17:59:24.552408+07	ASII	3981.369076861107	30775	BBCA	BMRI	HAKA
2026-06-29 16:50:24.552408+07	ASII	3992.5479159396573	45335	BBCA	BMRI	HAKA
2026-06-29 16:04:24.552408+07	ASII	3978.5365986209595	55492	BBCA	BMRI	HAKI
2026-07-01 10:56:24.552408+07	ASII	3991.2717580228414	48811	BBCA	BMRI	HAKA
2026-07-01 09:59:24.552408+07	ASII	3988.576140912577	57772	BBCA	BMRI	HAKI
2026-07-01 08:32:24.552408+07	ASII	3986.532537833799	39175	BBCA	BMRI	HAKI
2026-07-01 07:46:24.552408+07	ASII	3976.43392229316	53506	BBCA	BMRI	HAKI
2026-07-01 07:00:24.552408+07	ASII	3998.9720850959184	40667	BBCA	BMRI	HAKA
2026-07-01 05:55:24.552408+07	ASII	3987.0005565464403	68548	BBCA	BMRI	HAKI
2026-07-01 05:03:24.552408+07	ASII	3991.002949286977	41868	BBCA	BMRI	HAKA
2026-07-01 04:01:24.552408+07	ASII	3988.1299301563145	57320	BBCA	BMRI	HAKI
2026-07-01 02:52:24.552408+07	ASII	3982.7429443743677	61844	BBCA	BMRI	HAKI
2026-07-01 01:24:24.552408+07	ASII	3979.4293605700605	58200	BBCA	BMRI	HAKI
2026-07-01 00:53:24.552408+07	ASII	3977.3837365015065	41701	BBCA	BMRI	HAKI
2026-06-30 23:26:24.552408+07	ASII	3975.6781019689215	37105	BBCA	BMRI	HAKI
2026-06-30 22:46:24.552408+07	ASII	3971.290497871875	62976	BBCA	BMRI	HAKI
2026-06-30 21:47:24.552408+07	ASII	3987.1433059897963	49036	BBCA	BMRI	HAKA
2026-06-30 21:00:24.552408+07	ASII	3994.3615342318785	65930	BBCA	BMRI	HAKA
2026-06-30 19:06:24.552408+07	ASII	3990.8747692312836	56490	BBCA	BMRI	HAKI
2026-06-30 19:05:24.552408+07	ASII	3996.2979880639446	60474	BBCA	BMRI	HAKA
2026-06-30 17:17:24.552408+07	ASII	3990.3668180515174	45852	BBCA	BMRI	HAKI
2026-06-30 16:35:24.552408+07	ASII	3980.794248295238	54336	BBCA	BMRI	HAKI
2026-06-30 15:55:24.552408+07	ASII	3990.2044206479304	53908	BBCA	BMRI	HAKA
2026-07-02 06:10:24.552408+07	ASII	3990.686754737254	28176	BBCA	BMRI	HAKA
2026-07-02 05:06:24.552408+07	ASII	4002.309742975784	66835	BBCA	BMRI	HAKA
2026-07-02 04:35:24.552408+07	ASII	3998.687363862026	42775	BBCA	BMRI	HAKI
2026-07-02 04:04:24.552408+07	ASII	4010.3529839159246	36188	BBCA	BMRI	HAKA
2026-07-02 02:10:24.552408+07	ASII	4014.3930965807867	27605	BBCA	BMRI	HAKA
2026-07-02 01:16:24.552408+07	ASII	4022.5515096296563	39045	BBCA	BMRI	HAKA
2026-07-02 00:28:24.552408+07	ASII	4009.360049004446	47074	BBCA	BMRI	HAKI
2026-07-01 23:44:24.552408+07	ASII	3998.894424137383	48123	BBCA	BMRI	HAKI
2026-07-01 22:58:24.552408+07	ASII	4005.493338203475	51993	BBCA	BMRI	HAKA
2026-07-01 21:49:24.552408+07	ASII	4001.0693313369115	50681	BBCA	BMRI	HAKI
2026-07-01 20:12:24.552408+07	ASII	4001.9119352617836	43618	BBCA	BMRI	HAKA
2026-07-01 19:32:24.552408+07	ASII	3993.29720747337	55570	BBCA	BMRI	HAKI
2026-07-01 18:08:24.552408+07	ASII	4001.6917707647644	43998	BBCA	BMRI	HAKA
2026-07-01 17:26:24.552408+07	ASII	3999.146743345801	44282	BBCA	BMRI	HAKI
2026-07-01 16:29:24.552408+07	ASII	3988.0031001828293	57560	BBCA	BMRI	HAKI
2026-07-01 15:59:24.552408+07	ASII	3995.9073737694575	61508	BBCA	BMRI	HAKA
\.


--
-- Data for Name: _hyper_1_6_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_1_6_chunk ("time", ticker, price, volume, buyer_broker, seller_broker, trade_type) FROM stdin;
2026-07-03 01:30:01.914253+07	BBCA	2262.333424240506	961785	BBRI	BBNI	HAKA
2026-07-06 01:30:01.914253+07	BBCA	2241.783001503858	785663	BBRI	BBNI	HAKI
2026-07-07 01:30:01.914253+07	BBCA	2226.0579316943754	1118255	BBRI	BBNI	HAKI
2026-07-08 01:30:01.914253+07	BBCA	2140.948448598493	854122	BBRI	BBNI	HAKI
2026-07-09 01:30:01.914253+07	BBCA	2131.749459012619	935817	BBRI	BBNI	HAKI
2026-07-03 01:30:02.04616+07	BBRI	5509.747932387363	1231627	BBRI	BBNI	HAKA
2026-07-06 01:30:02.04616+07	BBRI	5587.425472506732	1106356	BBRI	BBNI	HAKA
2026-07-07 01:30:02.04616+07	BBRI	5794.67632771156	614833	BBRI	BBNI	HAKA
2026-07-08 01:30:02.04616+07	BBRI	5950.549764044479	763689	BBRI	BBNI	HAKA
2026-07-09 01:30:02.04616+07	BBRI	5899.072490635334	900670	BBRI	BBNI	HAKI
2026-07-03 01:30:02.098339+07	BMRI	1392.2001491914566	1351278	BBRI	BBNI	HAKA
2026-07-06 01:30:02.098339+07	BMRI	1398.8679777982709	753117	BBRI	BBNI	HAKA
2026-07-07 01:30:02.098339+07	BMRI	1390.6573012849203	1001218	BBRI	BBNI	HAKI
2026-07-08 01:30:02.098339+07	BMRI	1400.4403373065938	770689	BBRI	BBNI	HAKA
2026-07-09 01:30:02.098339+07	BMRI	1429.5826217407769	1011267	BBRI	BBNI	HAKA
2026-07-03 01:30:02.137016+07	TLKM	4625.316511070117	986577	BBRI	BBNI	HAKA
2026-07-06 01:30:02.137016+07	TLKM	4592.31969048525	1001164	BBRI	BBNI	HAKI
2026-07-07 01:30:02.137016+07	TLKM	4614.330168095706	816977	BBRI	BBNI	HAKA
2026-07-08 01:30:02.137016+07	TLKM	4659.911564632741	1187870	BBRI	BBNI	HAKA
2026-07-09 01:30:02.137016+07	TLKM	4754.607993896979	1329567	BBRI	BBNI	HAKA
2026-07-03 01:30:02.179406+07	ASII	3675.109367604972	1274104	BBRI	BBNI	HAKI
2026-07-06 01:30:02.179406+07	ASII	3720.3943534522487	736853	BBRI	BBNI	HAKA
2026-07-07 01:30:02.179406+07	ASII	3653.467313159954	1225250	BBRI	BBNI	HAKI
2026-07-08 01:30:02.179406+07	ASII	3524.5331515169655	1458270	BBRI	BBNI	HAKI
2026-07-09 01:30:02.179406+07	ASII	3560.341487899066	980352	BBRI	BBNI	HAKA
2026-07-02 10:22:55.029475+07	BBCA	4115.830666334445	52020	BBCA	BMRI	HAKA
2026-07-02 09:48:55.029475+07	BBCA	4108.281206924063	42332	BBCA	BMRI	HAKI
2026-07-02 08:59:55.029475+07	BBCA	4126.4063052845395	38175	BBCA	BMRI	HAKA
2026-07-02 07:08:55.029475+07	BBCA	4116.72130041564	34125	BBCA	BMRI	HAKI
2026-07-03 10:48:55.029475+07	BBCA	4051.244786183357	60887	BBCA	BMRI	HAKI
2026-07-03 09:21:55.029475+07	BBCA	4046.3644604078404	65785	BBCA	BMRI	HAKI
2026-07-03 08:29:55.029475+07	BBCA	4046.8360315868426	44663	BBCA	BMRI	HAKA
2026-07-03 07:05:55.029475+07	BBCA	4056.8461138903745	47070	BBCA	BMRI	HAKA
2026-07-03 06:57:55.029475+07	BBCA	4065.0687983559974	44938	BBCA	BMRI	HAKA
2026-07-03 05:58:55.029475+07	BBCA	4058.3325750871277	35194	BBCA	BMRI	HAKI
2026-07-03 04:08:55.029475+07	BBCA	4069.5785622179806	47546	BBCA	BMRI	HAKA
2026-07-03 03:57:55.029475+07	BBCA	4074.414301113871	57071	BBCA	BMRI	HAKA
2026-07-03 02:08:55.029475+07	BBCA	4073.2609681125	52198	BBCA	BMRI	HAKI
2026-07-03 01:32:55.029475+07	BBCA	4059.422825788893	43147	BBCA	BMRI	HAKI
2026-07-03 00:07:55.029475+07	BBCA	4050.22525587263	32126	BBCA	BMRI	HAKI
2026-07-02 23:33:55.029475+07	BBCA	4061.7950801778934	66168	BBCA	BMRI	HAKA
2026-07-02 22:26:55.029475+07	BBCA	4059.0179423869677	32646	BBCA	BMRI	HAKI
2026-07-02 21:18:55.029475+07	BBCA	4058.879523631124	43427	BBCA	BMRI	HAKI
2026-07-02 20:36:55.029475+07	BBCA	4061.599272165654	51503	BBCA	BMRI	HAKA
2026-07-02 19:15:55.029475+07	BBCA	4063.3456458737023	52792	BBCA	BMRI	HAKA
2026-07-02 18:40:55.029475+07	BBCA	4063.4749188333576	44848	BBCA	BMRI	HAKA
2026-07-02 17:49:55.029475+07	BBCA	4057.1370638646217	39960	BBCA	BMRI	HAKI
2026-07-02 16:11:55.029475+07	BBCA	4059.729739567286	33370	BBCA	BMRI	HAKA
2026-07-02 16:02:55.029475+07	BBCA	4048.9701120108693	37735	BBCA	BMRI	HAKI
2026-07-04 10:15:55.029475+07	BBCA	4043.1135900047284	58335	BBCA	BMRI	HAKI
2026-07-04 09:09:55.029475+07	BBCA	4043.749819905398	35920	BBCA	BMRI	HAKA
2026-07-04 08:47:55.029475+07	BBCA	4062.5402420554447	39094	BBCA	BMRI	HAKA
2026-07-04 07:08:55.029475+07	BBCA	4068.9057563160277	61490	BBCA	BMRI	HAKA
2026-07-04 06:07:55.029475+07	BBCA	4082.2391694633493	36689	BBCA	BMRI	HAKA
2026-07-04 05:27:55.029475+07	BBCA	4083.725745491254	24788	BBCA	BMRI	HAKA
2026-07-04 04:22:55.029475+07	BBCA	4090.4258186831044	36116	BBCA	BMRI	HAKA
2026-07-04 03:27:55.029475+07	BBCA	4090.4663918155547	47178	BBCA	BMRI	HAKA
2026-07-04 02:50:55.029475+07	BBCA	4101.625008775366	55084	BBCA	BMRI	HAKA
2026-07-04 01:29:55.029475+07	BBCA	4093.490115589288	36359	BBCA	BMRI	HAKI
2026-07-04 01:00:55.029475+07	BBCA	4081.1964650304167	44041	BBCA	BMRI	HAKI
2026-07-03 23:58:55.029475+07	BBCA	4085.9177607655124	33664	BBCA	BMRI	HAKA
2026-07-03 22:53:55.029475+07	BBCA	4083.4830038995906	46593	BBCA	BMRI	HAKI
2026-07-03 21:20:55.029475+07	BBCA	4069.9287328121927	57541	BBCA	BMRI	HAKI
2026-07-03 20:53:55.029475+07	BBCA	4056.9747527394475	43505	BBCA	BMRI	HAKI
2026-07-03 19:49:55.029475+07	BBCA	4056.7903975024665	57293	BBCA	BMRI	HAKI
2026-07-03 18:24:55.029475+07	BBCA	4077.9652141213896	49303	BBCA	BMRI	HAKA
2026-07-03 17:46:55.029475+07	BBCA	4080.222062339329	48419	BBCA	BMRI	HAKA
2026-07-03 16:56:55.029475+07	BBCA	4076.2202655688857	56651	BBCA	BMRI	HAKI
2026-07-03 15:32:55.029475+07	BBCA	4075.2321145064393	48307	BBCA	BMRI	HAKI
2026-07-05 11:03:55.029475+07	BBCA	4077.8330435886737	47824	BBCA	BMRI	HAKA
2026-07-05 09:42:55.029475+07	BBCA	4063.2553861667275	49224	BBCA	BMRI	HAKI
2026-07-05 08:26:55.029475+07	BBCA	4059.407513860592	38843	BBCA	BMRI	HAKI
2026-07-05 07:59:55.029475+07	BBCA	4062.3475985758096	54148	BBCA	BMRI	HAKA
2026-07-05 06:13:55.029475+07	BBCA	4064.4652540691663	61999	BBCA	BMRI	HAKA
2026-07-05 05:08:55.029475+07	BBCA	4068.547459483334	41202	BBCA	BMRI	HAKA
2026-07-05 04:22:55.029475+07	BBCA	4068.054104734381	42502	BBCA	BMRI	HAKI
2026-07-05 03:48:55.029475+07	BBCA	4058.8464111444423	61452	BBCA	BMRI	HAKI
2026-07-05 02:19:55.029475+07	BBCA	4046.9297662185913	54115	BBCA	BMRI	HAKI
2026-07-05 01:29:55.029475+07	BBCA	4032.9381621422312	63305	BBCA	BMRI	HAKI
2026-07-05 00:44:55.029475+07	BBCA	4045.7123238820486	76519	BBCA	BMRI	HAKA
2026-07-04 23:19:55.029475+07	BBCA	4052.0204754889546	58578	BBCA	BMRI	HAKA
2026-07-04 22:46:55.029475+07	BBCA	4059.215454234746	55454	BBCA	BMRI	HAKA
2026-07-04 21:15:55.029475+07	BBCA	4053.560250316878	18821	BBCA	BMRI	HAKI
2026-07-04 20:50:55.029475+07	BBCA	4061.279823162548	33749	BBCA	BMRI	HAKA
2026-07-04 19:30:55.029475+07	BBCA	4053.7452000711523	42059	BBCA	BMRI	HAKI
2026-07-04 18:39:55.029475+07	BBCA	4050.0282618588312	64513	BBCA	BMRI	HAKI
2026-07-04 17:25:55.029475+07	BBCA	4040.0789037108657	41507	BBCA	BMRI	HAKI
2026-07-04 16:31:55.029475+07	BBCA	4035.017556476726	50834	BBCA	BMRI	HAKI
2026-07-04 15:07:55.029475+07	BBCA	4031.6414565949344	63286	BBCA	BMRI	HAKI
2026-07-06 10:31:55.029475+07	BBCA	4041.6328820166154	67327	BBCA	BMRI	HAKA
2026-07-06 09:34:55.029475+07	BBCA	4040.8071461729382	47858	BBCA	BMRI	HAKI
2026-07-06 08:50:55.029475+07	BBCA	4043.9424988983856	65549	BBCA	BMRI	HAKA
2026-07-06 07:46:55.029475+07	BBCA	4043.402178062451	39629	BBCA	BMRI	HAKI
2026-07-06 06:43:55.029475+07	BBCA	4048.481868035682	64372	BBCA	BMRI	HAKA
2026-07-06 05:56:55.029475+07	BBCA	4064.0936542211507	43214	BBCA	BMRI	HAKA
2026-07-06 04:11:55.029475+07	BBCA	4060.823474473555	45995	BBCA	BMRI	HAKI
2026-07-06 03:17:55.029475+07	BBCA	4074.808826611706	57825	BBCA	BMRI	HAKA
2026-07-06 02:09:55.029475+07	BBCA	4059.204408212777	50260	BBCA	BMRI	HAKI
2026-07-06 01:48:55.029475+07	BBCA	4050.5204017005253	38087	BBCA	BMRI	HAKI
2026-07-06 00:09:55.029475+07	BBCA	4043.2784703913803	65172	BBCA	BMRI	HAKI
2026-07-05 23:32:55.029475+07	BBCA	4041.885528208069	54057	BBCA	BMRI	HAKI
2026-07-05 22:39:55.029475+07	BBCA	4028.067718463775	52191	BBCA	BMRI	HAKI
2026-07-05 21:36:55.029475+07	BBCA	4027.8311530896226	46444	BBCA	BMRI	HAKI
2026-07-05 20:46:55.029475+07	BBCA	4034.98728027653	66634	BBCA	BMRI	HAKA
2026-07-05 19:21:55.029475+07	BBCA	4040.198134553916	36381	BBCA	BMRI	HAKA
2026-07-05 18:59:55.029475+07	BBCA	4048.200049538679	39452	BBCA	BMRI	HAKA
2026-07-05 18:02:55.029475+07	BBCA	4035.4680802293947	50677	BBCA	BMRI	HAKI
2026-07-05 16:56:55.029475+07	BBCA	4038.5622897244743	36604	BBCA	BMRI	HAKA
2026-07-05 15:08:55.029475+07	BBCA	4028.1059056461863	64845	BBCA	BMRI	HAKI
2026-07-07 10:44:55.029475+07	BBCA	4028.4465842221425	50418	BBCA	BMRI	HAKA
2026-07-07 10:00:55.029475+07	BBCA	4029.386530790063	61033	BBCA	BMRI	HAKA
2026-07-07 08:52:55.029475+07	BBCA	4029.2970523460945	49019	BBCA	BMRI	HAKI
2026-07-07 07:39:55.029475+07	BBCA	4056.9103008519396	51072	BBCA	BMRI	HAKA
2026-07-07 06:40:55.029475+07	BBCA	4064.5041671863078	52454	BBCA	BMRI	HAKA
2026-07-07 05:23:55.029475+07	BBCA	4061.1011126082853	38353	BBCA	BMRI	HAKI
2026-07-07 04:14:55.029475+07	BBCA	4069.59927487766	57866	BBCA	BMRI	HAKA
2026-07-07 03:48:55.029475+07	BBCA	4060.033863269561	52580	BBCA	BMRI	HAKI
2026-07-07 02:30:55.029475+07	BBCA	4052.236338539423	49036	BBCA	BMRI	HAKI
2026-07-07 01:53:55.029475+07	BBCA	4059.867899520575	55797	BBCA	BMRI	HAKA
2026-07-07 00:23:55.029475+07	BBCA	4058.2553414722215	59533	BBCA	BMRI	HAKI
2026-07-06 23:26:55.029475+07	BBCA	4062.892662951565	52364	BBCA	BMRI	HAKA
2026-07-06 22:30:55.029475+07	BBCA	4046.570762811702	37522	BBCA	BMRI	HAKI
2026-07-06 21:32:55.029475+07	BBCA	4035.9543687818264	66153	BBCA	BMRI	HAKI
2026-07-06 20:29:55.029475+07	BBCA	4039.335292619353	64620	BBCA	BMRI	HAKA
2026-07-06 19:43:55.029475+07	BBCA	4020.1505163671004	39140	BBCA	BMRI	HAKI
2026-07-06 18:14:55.029475+07	BBCA	4014.0276504203352	55739	BBCA	BMRI	HAKI
2026-07-06 17:16:55.029475+07	BBCA	4012.105776654829	55205	BBCA	BMRI	HAKI
2026-07-06 16:58:55.029475+07	BBCA	4023.479212283095	66033	BBCA	BMRI	HAKA
2026-07-06 15:54:55.029475+07	BBCA	4030.6603321411867	68256	BBCA	BMRI	HAKA
2026-07-08 10:13:55.029475+07	BBCA	4024.5652467852838	32230	BBCA	BMRI	HAKI
2026-07-08 09:41:55.029475+07	BBCA	4039.4787195891636	63545	BBCA	BMRI	HAKA
2026-07-08 08:39:55.029475+07	BBCA	4031.896604698458	45200	BBCA	BMRI	HAKI
2026-07-08 07:35:55.029475+07	BBCA	4024.257246037021	27577	BBCA	BMRI	HAKI
2026-07-08 06:51:55.029475+07	BBCA	4018.368723701009	56225	BBCA	BMRI	HAKI
2026-07-08 05:57:55.029475+07	BBCA	4025.4534186057645	42241	BBCA	BMRI	HAKA
2026-07-08 04:48:55.029475+07	BBCA	4016.4473169442354	53952	BBCA	BMRI	HAKI
2026-07-08 03:55:55.029475+07	BBCA	4021.567202281945	28363	BBCA	BMRI	HAKA
2026-07-08 02:14:55.029475+07	BBCA	4024.853947567761	47059	BBCA	BMRI	HAKA
2026-07-08 01:55:55.029475+07	BBCA	4030.7720443498874	52087	BBCA	BMRI	HAKA
2026-07-08 00:42:55.029475+07	BBCA	4034.6152971721854	50570	BBCA	BMRI	HAKA
2026-07-07 23:41:55.029475+07	BBCA	4032.19138805258	58736	BBCA	BMRI	HAKI
2026-07-07 22:36:55.029475+07	BBCA	4052.6113948609154	46940	BBCA	BMRI	HAKA
2026-07-07 21:09:55.029475+07	BBCA	4052.0792109499703	29974	BBCA	BMRI	HAKI
2026-07-07 20:57:55.029475+07	BBCA	4050.2016583919694	49084	BBCA	BMRI	HAKI
2026-07-07 19:47:55.029475+07	BBCA	4057.273318316863	40544	BBCA	BMRI	HAKA
2026-07-07 18:11:55.029475+07	BBCA	4044.436136341484	37617	BBCA	BMRI	HAKI
2026-07-07 17:40:55.029475+07	BBCA	4038.8719470038654	60058	BBCA	BMRI	HAKI
2026-07-07 17:02:55.029475+07	BBCA	4022.5758836192445	58790	BBCA	BMRI	HAKI
2026-07-07 15:22:55.029475+07	BBCA	4015.9073192399746	52623	BBCA	BMRI	HAKI
2026-07-09 06:22:55.029475+07	BBCA	4004.481694717425	47589	BBCA	BMRI	HAKA
2026-07-09 05:22:55.029475+07	BBCA	4008.349380370636	48320	BBCA	BMRI	HAKA
2026-07-09 04:59:55.029475+07	BBCA	4019.2709625374673	62195	BBCA	BMRI	HAKA
2026-07-09 03:35:55.029475+07	BBCA	4005.3909559185076	40883	BBCA	BMRI	HAKI
2026-07-09 02:05:55.029475+07	BBCA	3983.3321475345338	50748	BBCA	BMRI	HAKI
2026-07-09 01:14:55.029475+07	BBCA	3977.363634598019	64026	BBCA	BMRI	HAKI
2026-07-09 00:52:55.029475+07	BBCA	3971.795677287774	64406	BBCA	BMRI	HAKI
2026-07-08 23:31:55.029475+07	BBCA	3978.6945439933747	37258	BBCA	BMRI	HAKA
2026-07-08 22:56:55.029475+07	BBCA	3960.3574696120795	55384	BBCA	BMRI	HAKI
2026-07-08 22:02:55.029475+07	BBCA	3947.493329350347	57268	BBCA	BMRI	HAKI
2026-07-08 20:25:55.029475+07	BBCA	3946.7107574286415	29037	BBCA	BMRI	HAKI
2026-07-08 19:11:55.029475+07	BBCA	3948.503203950941	75712	BBCA	BMRI	HAKA
2026-07-08 18:45:55.029475+07	BBCA	3957.420595540838	38197	BBCA	BMRI	HAKA
2026-07-08 17:44:55.029475+07	BBCA	3959.6689775321406	45852	BBCA	BMRI	HAKA
2026-07-08 16:29:55.029475+07	BBCA	3961.7955027976186	35677	BBCA	BMRI	HAKA
2026-07-08 15:09:55.029475+07	BBCA	3963.7019863317596	28805	BBCA	BMRI	HAKA
2026-07-02 10:17:56.369997+07	BBRI	1624.6684818609665	49945	BBCA	BMRI	HAKI
2026-07-02 09:46:56.369997+07	BBRI	1627.209189875317	42236	BBCA	BMRI	HAKA
2026-07-02 08:25:56.369997+07	BBRI	1629.765974289191	65213	BBCA	BMRI	HAKA
2026-07-02 07:50:56.369997+07	BBRI	1633.6021381310873	38377	BBCA	BMRI	HAKA
2026-07-03 10:31:56.369997+07	BBRI	1628.6086608457094	59420	BBCA	BMRI	HAKI
2026-07-03 09:31:56.369997+07	BBRI	1622.8817604386145	52300	BBCA	BMRI	HAKI
2026-07-03 08:20:56.369997+07	BBRI	1623.4207963984998	52466	BBCA	BMRI	HAKA
2026-07-03 07:37:56.369997+07	BBRI	1624.7083475296918	48362	BBCA	BMRI	HAKA
2026-07-03 06:05:56.369997+07	BBRI	1627.522367928337	31388	BBCA	BMRI	HAKA
2026-07-03 05:43:56.369997+07	BBRI	1623.2648358644556	63899	BBCA	BMRI	HAKI
2026-07-03 04:26:56.369997+07	BBRI	1620.6127281998067	63768	BBCA	BMRI	HAKI
2026-07-03 03:53:56.369997+07	BBRI	1622.4669154074147	68485	BBCA	BMRI	HAKA
2026-07-03 02:52:56.369997+07	BBRI	1627.960174347389	49803	BBCA	BMRI	HAKA
2026-07-03 01:07:56.369997+07	BBRI	1633.2246636933007	41852	BBCA	BMRI	HAKA
2026-07-03 00:33:56.369997+07	BBRI	1633.784937604945	60264	BBCA	BMRI	HAKA
2026-07-02 23:39:56.369997+07	BBRI	1632.1353380214334	52119	BBCA	BMRI	HAKI
2026-07-02 22:14:56.369997+07	BBRI	1628.4738319260907	38809	BBCA	BMRI	HAKI
2026-07-02 21:44:56.369997+07	BBRI	1626.8490650660692	63261	BBCA	BMRI	HAKI
2026-07-02 20:31:56.369997+07	BBRI	1626.5000256695118	58639	BBCA	BMRI	HAKI
2026-07-02 19:22:56.369997+07	BBRI	1629.6291676010762	58241	BBCA	BMRI	HAKA
2026-07-02 18:51:56.369997+07	BBRI	1625.6205906220362	37465	BBCA	BMRI	HAKI
2026-07-02 17:06:56.369997+07	BBRI	1624.9069394575927	33517	BBCA	BMRI	HAKI
2026-07-02 16:47:56.369997+07	BBRI	1623.3727041411573	41993	BBCA	BMRI	HAKI
2026-07-02 15:33:56.369997+07	BBRI	1623.9962704906873	60908	BBCA	BMRI	HAKA
2026-07-04 10:28:56.369997+07	BBRI	1624.4423425683858	61758	BBCA	BMRI	HAKA
2026-07-04 09:09:56.369997+07	BBRI	1623.269617824982	50277	BBCA	BMRI	HAKI
2026-07-04 08:09:56.369997+07	BBRI	1622.7976216492357	46425	BBCA	BMRI	HAKI
2026-07-04 07:44:56.369997+07	BBRI	1620.4892907830724	53727	BBCA	BMRI	HAKI
2026-07-04 06:28:56.369997+07	BBRI	1616.835106540678	46901	BBCA	BMRI	HAKI
2026-07-04 05:57:56.369997+07	BBRI	1617.8015594518922	40470	BBCA	BMRI	HAKA
2026-07-04 04:39:56.369997+07	BBRI	1622.3266469533864	53920	BBCA	BMRI	HAKA
2026-07-04 03:07:56.369997+07	BBRI	1618.5561497191668	49644	BBCA	BMRI	HAKI
2026-07-04 02:39:56.369997+07	BBRI	1620.6711522766748	43453	BBCA	BMRI	HAKA
2026-07-04 01:22:56.369997+07	BBRI	1617.0125885316265	56545	BBCA	BMRI	HAKI
2026-07-04 00:30:56.369997+07	BBRI	1614.9048570135265	46494	BBCA	BMRI	HAKI
2026-07-04 00:04:56.369997+07	BBRI	1618.8759855657252	41449	BBCA	BMRI	HAKA
2026-07-03 22:47:56.369997+07	BBRI	1619.4982622909142	47996	BBCA	BMRI	HAKA
2026-07-03 21:40:56.369997+07	BBRI	1616.3248713865912	44287	BBCA	BMRI	HAKI
2026-07-03 20:09:56.369997+07	BBRI	1615.8703434434158	50073	BBCA	BMRI	HAKI
2026-07-03 19:58:56.369997+07	BBRI	1619.5175571470304	59107	BBCA	BMRI	HAKA
2026-07-03 18:14:56.369997+07	BBRI	1618.3254717043758	55824	BBCA	BMRI	HAKI
2026-07-03 17:47:56.369997+07	BBRI	1618.644449732614	47251	BBCA	BMRI	HAKA
2026-07-03 16:48:56.369997+07	BBRI	1617.7211703247574	51468	BBCA	BMRI	HAKI
2026-07-03 15:28:56.369997+07	BBRI	1619.453258209912	61584	BBCA	BMRI	HAKA
2026-07-05 10:07:56.369997+07	BBRI	1621.9327250760364	42622	BBCA	BMRI	HAKA
2026-07-05 09:43:56.369997+07	BBRI	1611.8734425441567	53290	BBCA	BMRI	HAKI
2026-07-05 08:32:56.369997+07	BBRI	1607.9469877100582	69707	BBCA	BMRI	HAKI
2026-07-05 07:42:56.369997+07	BBRI	1607.229167076127	63630	BBCA	BMRI	HAKI
2026-07-05 06:15:56.369997+07	BBRI	1606.9725703793786	32910	BBCA	BMRI	HAKI
2026-07-05 05:14:56.369997+07	BBRI	1607.7173699845573	38592	BBCA	BMRI	HAKA
2026-07-05 04:27:56.369997+07	BBRI	1604.4471140505188	38983	BBCA	BMRI	HAKI
2026-07-05 03:06:56.369997+07	BBRI	1603.757515987206	52590	BBCA	BMRI	HAKI
2026-07-05 02:38:56.369997+07	BBRI	1601.712567063039	61795	BBCA	BMRI	HAKI
2026-07-05 01:11:56.369997+07	BBRI	1601.5587360461498	36751	BBCA	BMRI	HAKI
2026-07-05 00:12:56.369997+07	BBRI	1599.7146377006536	46275	BBCA	BMRI	HAKI
2026-07-04 23:24:56.369997+07	BBRI	1604.370129865516	50401	BBCA	BMRI	HAKA
2026-07-04 22:29:56.369997+07	BBRI	1603.0505349383996	45163	BBCA	BMRI	HAKI
2026-07-04 22:02:56.369997+07	BBRI	1609.5443109866503	41845	BBCA	BMRI	HAKA
2026-07-04 20:42:56.369997+07	BBRI	1610.3763307528077	42085	BBCA	BMRI	HAKA
2026-07-04 19:57:56.369997+07	BBRI	1607.7082572580514	29738	BBCA	BMRI	HAKI
2026-07-04 18:08:56.369997+07	BBRI	1612.7896197282346	43144	BBCA	BMRI	HAKA
2026-07-04 17:18:56.369997+07	BBRI	1611.3767759748118	52061	BBCA	BMRI	HAKI
2026-07-04 16:34:56.369997+07	BBRI	1604.0693890173613	47329	BBCA	BMRI	HAKI
2026-07-04 15:42:56.369997+07	BBRI	1605.5520929605227	35882	BBCA	BMRI	HAKA
2026-07-06 10:18:56.369997+07	BBRI	1605.3115353283465	46014	BBCA	BMRI	HAKI
2026-07-06 09:26:56.369997+07	BBRI	1604.1265875202475	36768	BBCA	BMRI	HAKI
2026-07-06 08:36:56.369997+07	BBRI	1604.364021455847	45666	BBCA	BMRI	HAKA
2026-07-06 07:21:56.369997+07	BBRI	1601.551601084386	52638	BBCA	BMRI	HAKI
2026-07-06 06:14:56.369997+07	BBRI	1602.0435782604525	16352	BBCA	BMRI	HAKA
2026-07-06 05:21:56.369997+07	BBRI	1600.3321455432815	56483	BBCA	BMRI	HAKI
2026-07-06 04:22:56.369997+07	BBRI	1593.7332007524474	58028	BBCA	BMRI	HAKI
2026-07-06 03:29:56.369997+07	BBRI	1589.8613652699871	53440	BBCA	BMRI	HAKI
2026-07-06 02:35:56.369997+07	BBRI	1590.0073501000531	53908	BBCA	BMRI	HAKA
2026-07-06 01:33:56.369997+07	BBRI	1591.559968873727	42625	BBCA	BMRI	HAKA
2026-07-06 00:50:56.369997+07	BBRI	1592.7054580176948	54755	BBCA	BMRI	HAKA
2026-07-06 00:01:56.369997+07	BBRI	1586.9867018301195	39010	BBCA	BMRI	HAKI
2026-07-05 22:42:56.369997+07	BBRI	1588.4573260206744	53567	BBCA	BMRI	HAKA
2026-07-05 21:30:56.369997+07	BBRI	1590.5815869637006	49622	BBCA	BMRI	HAKA
2026-07-05 20:33:56.369997+07	BBRI	1590.9252200001818	35570	BBCA	BMRI	HAKA
2026-07-05 19:31:56.369997+07	BBRI	1588.3828366689863	22063	BBCA	BMRI	HAKI
2026-07-05 18:36:56.369997+07	BBRI	1586.227344647952	60018	BBCA	BMRI	HAKI
2026-07-05 17:49:56.369997+07	BBRI	1588.3621791998326	50710	BBCA	BMRI	HAKA
2026-07-05 16:50:56.369997+07	BBRI	1588.532313509557	68359	BBCA	BMRI	HAKA
2026-07-05 15:07:56.369997+07	BBRI	1593.3863643139366	38035	BBCA	BMRI	HAKA
2026-07-07 10:21:56.369997+07	BBRI	1592.5018359993123	54453	BBCA	BMRI	HAKI
2026-07-07 09:57:56.369997+07	BBRI	1594.152207734968	28630	BBCA	BMRI	HAKA
2026-07-07 08:28:56.369997+07	BBRI	1596.169609169154	48321	BBCA	BMRI	HAKA
2026-07-07 07:15:56.369997+07	BBRI	1588.2538429350086	53589	BBCA	BMRI	HAKI
2026-07-07 06:51:56.369997+07	BBRI	1591.6826544479384	49903	BBCA	BMRI	HAKA
2026-07-07 05:19:56.369997+07	BBRI	1591.99713647798	38985	BBCA	BMRI	HAKA
2026-07-07 04:32:56.369997+07	BBRI	1583.5281837122536	40952	BBCA	BMRI	HAKI
2026-07-07 03:36:56.369997+07	BBRI	1587.362832394059	44143	BBCA	BMRI	HAKA
2026-07-07 02:38:56.369997+07	BBRI	1586.7625467198432	54691	BBCA	BMRI	HAKI
2026-07-07 01:57:56.369997+07	BBRI	1582.8678896099311	65729	BBCA	BMRI	HAKI
2026-07-07 01:01:56.369997+07	BBRI	1579.5713036046723	30758	BBCA	BMRI	HAKI
2026-07-06 23:37:56.369997+07	BBRI	1574.2750849719398	42872	BBCA	BMRI	HAKI
2026-07-06 22:12:56.369997+07	BBRI	1575.1160482252462	64963	BBCA	BMRI	HAKA
2026-07-06 21:40:56.369997+07	BBRI	1576.269987344009	26090	BBCA	BMRI	HAKA
2026-07-06 20:55:56.369997+07	BBRI	1574.8286366156406	67379	BBCA	BMRI	HAKI
2026-07-06 19:07:56.369997+07	BBRI	1573.50591595193	53024	BBCA	BMRI	HAKI
2026-07-06 18:43:56.369997+07	BBRI	1572.3495596277598	49195	BBCA	BMRI	HAKI
2026-07-06 17:39:56.369997+07	BBRI	1577.1079528719001	22973	BBCA	BMRI	HAKA
2026-07-06 16:37:56.369997+07	BBRI	1571.5897446488834	42876	BBCA	BMRI	HAKI
2026-07-06 15:48:56.369997+07	BBRI	1571.6176888726136	39017	BBCA	BMRI	HAKA
2026-07-08 10:18:56.369997+07	BBRI	1572.4024504757488	60295	BBCA	BMRI	HAKA
2026-07-08 09:22:56.369997+07	BBRI	1571.2068257386445	43900	BBCA	BMRI	HAKI
2026-07-08 08:41:56.369997+07	BBRI	1571.2693944095265	26689	BBCA	BMRI	HAKA
2026-07-08 07:14:56.369997+07	BBRI	1576.2828428876123	46627	BBCA	BMRI	HAKA
2026-07-08 06:37:56.369997+07	BBRI	1574.538030908981	42893	BBCA	BMRI	HAKI
2026-07-08 05:29:56.369997+07	BBRI	1574.445376430402	45350	BBCA	BMRI	HAKI
2026-07-08 04:56:56.369997+07	BBRI	1575.7883209225342	69794	BBCA	BMRI	HAKA
2026-07-08 03:31:56.369997+07	BBRI	1582.1551221009947	38031	BBCA	BMRI	HAKA
2026-07-08 02:37:56.369997+07	BBRI	1580.2514319122802	42799	BBCA	BMRI	HAKI
2026-07-08 01:50:56.369997+07	BBRI	1581.8245274700823	49637	BBCA	BMRI	HAKA
2026-07-08 00:16:56.369997+07	BBRI	1579.6804046498057	44105	BBCA	BMRI	HAKI
2026-07-07 23:10:56.369997+07	BBRI	1578.013879265271	65984	BBCA	BMRI	HAKI
2026-07-07 22:14:56.369997+07	BBRI	1574.3144026272666	54659	BBCA	BMRI	HAKI
2026-07-07 21:53:56.369997+07	BBRI	1576.1357566395752	52179	BBCA	BMRI	HAKA
2026-07-07 20:31:56.369997+07	BBRI	1570.8224167407577	47693	BBCA	BMRI	HAKI
2026-07-07 19:11:56.369997+07	BBRI	1574.9395027522644	57313	BBCA	BMRI	HAKA
2026-07-07 18:22:56.369997+07	BBRI	1574.191287394967	67907	BBCA	BMRI	HAKI
2026-07-07 17:41:56.369997+07	BBRI	1576.8408831698243	40791	BBCA	BMRI	HAKA
2026-07-07 16:43:56.369997+07	BBRI	1570.7570343452526	63437	BBCA	BMRI	HAKI
2026-07-07 15:29:56.369997+07	BBRI	1573.025376076001	78799	BBCA	BMRI	HAKA
2026-07-09 06:20:56.369997+07	BBRI	1570.887255750067	46908	BBCA	BMRI	HAKA
2026-07-09 05:29:56.369997+07	BBRI	1570.7490494709261	55788	BBCA	BMRI	HAKI
2026-07-09 04:59:56.369997+07	BBRI	1570.7465027966978	53218	BBCA	BMRI	HAKI
2026-07-09 03:21:56.369997+07	BBRI	1572.9340840092998	44858	BBCA	BMRI	HAKA
2026-07-09 02:32:56.369997+07	BBRI	1573.5664366844592	53019	BBCA	BMRI	HAKA
2026-07-09 01:44:56.369997+07	BBRI	1574.819498576603	34745	BBCA	BMRI	HAKA
2026-07-09 00:16:56.369997+07	BBRI	1574.9530170102953	67822	BBCA	BMRI	HAKA
2026-07-08 23:58:56.369997+07	BBRI	1578.0286458513872	60447	BBCA	BMRI	HAKA
2026-07-08 22:41:56.369997+07	BBRI	1576.9092716005478	67577	BBCA	BMRI	HAKI
2026-07-08 21:48:56.369997+07	BBRI	1585.6555641095097	58186	BBCA	BMRI	HAKA
2026-07-08 20:24:56.369997+07	BBRI	1581.9205786679631	57431	BBCA	BMRI	HAKI
2026-07-08 19:05:56.369997+07	BBRI	1578.6592906595379	59200	BBCA	BMRI	HAKI
2026-07-08 18:42:56.369997+07	BBRI	1579.2878253501226	45115	BBCA	BMRI	HAKA
2026-07-08 17:11:56.369997+07	BBRI	1575.7771830606393	32280	BBCA	BMRI	HAKI
2026-07-08 16:58:56.369997+07	BBRI	1574.8526669031314	54584	BBCA	BMRI	HAKI
2026-07-08 15:19:56.369997+07	BBRI	1574.965872787056	38530	BBCA	BMRI	HAKA
2026-07-02 10:15:57.706842+07	BMRI	2827.8460096131353	46896	BBCA	BMRI	HAKI
2026-07-02 09:40:57.706842+07	BMRI	2834.5850853495913	47726	BBCA	BMRI	HAKA
2026-07-02 08:12:57.706842+07	BMRI	2825.05977685612	51027	BBCA	BMRI	HAKI
2026-07-02 07:54:57.706842+07	BMRI	2826.0995082806494	54479	BBCA	BMRI	HAKA
2026-07-03 10:38:57.706842+07	BMRI	2820.083481405553	40584	BBCA	BMRI	HAKA
2026-07-03 09:05:57.706842+07	BMRI	2821.7672589130175	54185	BBCA	BMRI	HAKA
2026-07-03 08:22:57.706842+07	BMRI	2829.5903660274353	39148	BBCA	BMRI	HAKA
2026-07-03 07:25:57.706842+07	BMRI	2821.721898651412	47655	BBCA	BMRI	HAKI
2026-07-03 06:36:57.706842+07	BMRI	2819.5713792389583	50716	BBCA	BMRI	HAKI
2026-07-03 05:43:57.706842+07	BMRI	2810.961457403307	56725	BBCA	BMRI	HAKI
2026-07-03 04:30:57.706842+07	BMRI	2821.4219434289594	57063	BBCA	BMRI	HAKA
2026-07-03 03:45:57.706842+07	BMRI	2818.783240996751	55669	BBCA	BMRI	HAKI
2026-07-03 02:14:57.706842+07	BMRI	2819.6298460746993	34020	BBCA	BMRI	HAKA
2026-07-03 01:39:57.706842+07	BMRI	2813.9590938783176	53108	BBCA	BMRI	HAKI
2026-07-03 01:03:57.706842+07	BMRI	2814.7724389444998	53730	BBCA	BMRI	HAKA
2026-07-02 23:08:57.706842+07	BMRI	2805.4558502714717	57246	BBCA	BMRI	HAKI
2026-07-02 22:50:57.706842+07	BMRI	2803.4260828811134	41237	BBCA	BMRI	HAKI
2026-07-02 21:30:57.706842+07	BMRI	2805.8739641874363	61489	BBCA	BMRI	HAKA
2026-07-02 20:43:57.706842+07	BMRI	2805.960184405948	42296	BBCA	BMRI	HAKA
2026-07-02 19:56:57.706842+07	BMRI	2801.517534705862	48067	BBCA	BMRI	HAKI
2026-07-02 18:08:57.706842+07	BMRI	2815.4351125507765	24525	BBCA	BMRI	HAKA
2026-07-02 17:53:57.706842+07	BMRI	2810.9925348239294	47805	BBCA	BMRI	HAKI
2026-07-02 16:28:57.706842+07	BMRI	2812.5617902874696	48228	BBCA	BMRI	HAKA
2026-07-02 15:11:57.706842+07	BMRI	2810.845267201467	66557	BBCA	BMRI	HAKI
2026-07-04 10:19:57.706842+07	BMRI	2805.3529395573732	36434	BBCA	BMRI	HAKI
2026-07-04 09:34:57.706842+07	BMRI	2799.6035795310177	42678	BBCA	BMRI	HAKI
2026-07-04 08:32:57.706842+07	BMRI	2809.2922791084425	57625	BBCA	BMRI	HAKA
2026-07-04 08:03:57.706842+07	BMRI	2798.147646357881	65108	BBCA	BMRI	HAKI
2026-07-04 06:46:57.706842+07	BMRI	2802.5617242400454	30572	BBCA	BMRI	HAKA
2026-07-04 05:18:57.706842+07	BMRI	2811.828893651676	58092	BBCA	BMRI	HAKA
2026-07-04 04:57:57.706842+07	BMRI	2814.205858459878	46871	BBCA	BMRI	HAKA
2026-07-04 03:49:57.706842+07	BMRI	2818.9481768690293	57289	BBCA	BMRI	HAKA
2026-07-04 03:04:57.706842+07	BMRI	2823.0680848720244	41723	BBCA	BMRI	HAKA
2026-07-04 01:54:57.706842+07	BMRI	2818.0085734574213	40785	BBCA	BMRI	HAKI
2026-07-04 00:15:57.706842+07	BMRI	2821.037189068887	58476	BBCA	BMRI	HAKA
2026-07-03 23:44:57.706842+07	BMRI	2816.2189898766696	59499	BBCA	BMRI	HAKI
2026-07-03 22:17:57.706842+07	BMRI	2818.1682148261	42749	BBCA	BMRI	HAKA
2026-07-03 21:33:57.706842+07	BMRI	2807.818713675061	35971	BBCA	BMRI	HAKI
2026-07-03 21:01:57.706842+07	BMRI	2804.2789916873226	36778	BBCA	BMRI	HAKI
2026-07-03 19:54:57.706842+07	BMRI	2809.4321955559108	43924	BBCA	BMRI	HAKA
2026-07-03 18:16:57.706842+07	BMRI	2811.4853747704865	58883	BBCA	BMRI	HAKA
2026-07-03 17:26:57.706842+07	BMRI	2811.206438183926	55321	BBCA	BMRI	HAKI
2026-07-03 16:43:57.706842+07	BMRI	2814.268478049739	39965	BBCA	BMRI	HAKA
2026-07-03 15:59:57.706842+07	BMRI	2815.1582135153412	39852	BBCA	BMRI	HAKA
2026-07-05 10:15:57.706842+07	BMRI	2818.481182412422	40207	BBCA	BMRI	HAKA
2026-07-05 09:21:57.706842+07	BMRI	2818.36660695207	56896	BBCA	BMRI	HAKI
2026-07-05 08:48:57.706842+07	BMRI	2808.901068477051	45769	BBCA	BMRI	HAKI
2026-07-05 07:07:57.706842+07	BMRI	2811.9363381804455	53948	BBCA	BMRI	HAKA
2026-07-05 06:29:57.706842+07	BMRI	2815.4611396726386	57363	BBCA	BMRI	HAKA
2026-07-05 05:12:57.706842+07	BMRI	2809.834579838832	57427	BBCA	BMRI	HAKI
2026-07-05 04:54:57.706842+07	BMRI	2815.4431310796544	38127	BBCA	BMRI	HAKA
2026-07-05 03:23:57.706842+07	BMRI	2820.838739482964	60161	BBCA	BMRI	HAKA
2026-07-05 02:17:57.706842+07	BMRI	2816.572915426877	52967	BBCA	BMRI	HAKI
2026-07-05 01:22:57.706842+07	BMRI	2812.9200812108547	31151	BBCA	BMRI	HAKI
2026-07-05 00:42:57.706842+07	BMRI	2820.319812245028	62353	BBCA	BMRI	HAKA
2026-07-04 23:42:57.706842+07	BMRI	2820.773742616122	59771	BBCA	BMRI	HAKA
2026-07-04 22:48:57.706842+07	BMRI	2830.3412022924686	40051	BBCA	BMRI	HAKA
2026-07-04 21:30:57.706842+07	BMRI	2828.713833355462	58408	BBCA	BMRI	HAKI
2026-07-04 20:25:57.706842+07	BMRI	2822.514772615168	65369	BBCA	BMRI	HAKI
2026-07-04 19:05:57.706842+07	BMRI	2829.1933655344064	51781	BBCA	BMRI	HAKA
2026-07-04 18:44:57.706842+07	BMRI	2833.3656315659305	45189	BBCA	BMRI	HAKA
2026-07-04 17:34:57.706842+07	BMRI	2834.995955945872	46723	BBCA	BMRI	HAKA
2026-07-04 16:09:57.706842+07	BMRI	2823.37261391339	34622	BBCA	BMRI	HAKI
2026-07-04 15:54:57.706842+07	BMRI	2816.448161825606	49153	BBCA	BMRI	HAKI
2026-07-06 10:11:57.706842+07	BMRI	2812.8868356800235	33374	BBCA	BMRI	HAKI
2026-07-06 09:05:57.706842+07	BMRI	2808.014144011344	36966	BBCA	BMRI	HAKI
2026-07-06 08:49:57.706842+07	BMRI	2803.412078198928	45733	BBCA	BMRI	HAKI
2026-07-06 07:40:57.706842+07	BMRI	2799.885296363549	74300	BBCA	BMRI	HAKI
2026-07-06 06:58:57.706842+07	BMRI	2802.4406039481596	44831	BBCA	BMRI	HAKA
2026-07-06 05:56:57.706842+07	BMRI	2798.5675541715095	32766	BBCA	BMRI	HAKI
2026-07-06 04:42:57.706842+07	BMRI	2804.5178254313296	42175	BBCA	BMRI	HAKA
2026-07-06 03:16:57.706842+07	BMRI	2807.1112213241786	49022	BBCA	BMRI	HAKA
2026-07-06 02:07:57.706842+07	BMRI	2800.516302459274	41936	BBCA	BMRI	HAKI
2026-07-06 01:58:57.706842+07	BMRI	2795.659354649039	48075	BBCA	BMRI	HAKI
2026-07-06 00:39:57.706842+07	BMRI	2801.3517388572363	43132	BBCA	BMRI	HAKA
2026-07-05 23:57:57.706842+07	BMRI	2796.620245383706	64366	BBCA	BMRI	HAKI
2026-07-05 22:25:57.706842+07	BMRI	2800.6666831463936	51873	BBCA	BMRI	HAKA
2026-07-05 21:42:57.706842+07	BMRI	2799.2986684606753	50337	BBCA	BMRI	HAKI
2026-07-05 20:58:57.706842+07	BMRI	2792.410913763278	34467	BBCA	BMRI	HAKI
2026-07-05 19:25:57.706842+07	BMRI	2784.5311542004856	46153	BBCA	BMRI	HAKI
2026-07-05 18:15:57.706842+07	BMRI	2787.158228229399	52773	BBCA	BMRI	HAKA
2026-07-05 17:18:57.706842+07	BMRI	2792.392038402781	41763	BBCA	BMRI	HAKA
2026-07-05 16:06:57.706842+07	BMRI	2783.584725578022	57108	BBCA	BMRI	HAKI
2026-07-05 15:26:57.706842+07	BMRI	2781.2956738541643	72719	BBCA	BMRI	HAKI
2026-07-07 10:30:57.706842+07	BMRI	2785.5711600224095	37283	BBCA	BMRI	HAKA
2026-07-07 09:58:57.706842+07	BMRI	2780.9005338016304	36504	BBCA	BMRI	HAKI
2026-07-07 08:09:57.706842+07	BMRI	2784.8406143493253	44198	BBCA	BMRI	HAKA
2026-07-07 07:41:57.706842+07	BMRI	2796.5434624605764	63880	BBCA	BMRI	HAKA
2026-07-07 06:49:57.706842+07	BMRI	2800.124716391387	56932	BBCA	BMRI	HAKA
2026-07-07 05:23:57.706842+07	BMRI	2800.8843359749617	49023	BBCA	BMRI	HAKA
2026-07-07 04:49:57.706842+07	BMRI	2792.459503473583	36297	BBCA	BMRI	HAKI
2026-07-07 03:27:57.706842+07	BMRI	2786.191015536893	46113	BBCA	BMRI	HAKI
2026-07-07 03:01:57.706842+07	BMRI	2785.2028796278128	61949	BBCA	BMRI	HAKI
2026-07-07 01:53:57.706842+07	BMRI	2794.0652699647585	54607	BBCA	BMRI	HAKA
2026-07-07 00:21:57.706842+07	BMRI	2796.0516910072524	46157	BBCA	BMRI	HAKA
2026-07-06 23:47:57.706842+07	BMRI	2800.7239714771176	50749	BBCA	BMRI	HAKA
2026-07-06 22:22:57.706842+07	BMRI	2799.8091943422164	57209	BBCA	BMRI	HAKI
2026-07-06 21:34:57.706842+07	BMRI	2799.5957304238627	52039	BBCA	BMRI	HAKI
2026-07-06 21:01:57.706842+07	BMRI	2788.0062238109276	42607	BBCA	BMRI	HAKI
2026-07-06 20:04:57.706842+07	BMRI	2786.7301200860425	49379	BBCA	BMRI	HAKI
2026-07-06 18:33:57.706842+07	BMRI	2783.424651722451	47390	BBCA	BMRI	HAKI
2026-07-06 17:31:57.706842+07	BMRI	2790.3180500033222	53724	BBCA	BMRI	HAKA
2026-07-06 17:04:57.706842+07	BMRI	2790.6200229897872	42646	BBCA	BMRI	HAKA
2026-07-06 15:53:57.706842+07	BMRI	2785.573922689346	41145	BBCA	BMRI	HAKI
2026-07-08 10:06:57.706842+07	BMRI	2793.2564410584446	75306	BBCA	BMRI	HAKA
2026-07-08 09:31:57.706842+07	BMRI	2799.3225592209956	43549	BBCA	BMRI	HAKA
2026-07-08 08:44:57.706842+07	BMRI	2803.7247449081824	42742	BBCA	BMRI	HAKA
2026-07-08 07:12:57.706842+07	BMRI	2804.691608547691	41998	BBCA	BMRI	HAKA
2026-07-08 06:10:57.706842+07	BMRI	2802.5405448478473	66821	BBCA	BMRI	HAKI
2026-07-08 05:35:57.706842+07	BMRI	2807.6174108962537	56208	BBCA	BMRI	HAKA
2026-07-08 04:06:57.706842+07	BMRI	2803.19713524885	41401	BBCA	BMRI	HAKI
2026-07-08 03:22:57.706842+07	BMRI	2804.839009016698	43659	BBCA	BMRI	HAKA
2026-07-08 02:45:57.706842+07	BMRI	2800.539838402611	56229	BBCA	BMRI	HAKI
2026-07-08 01:15:57.706842+07	BMRI	2796.0469988560494	50410	BBCA	BMRI	HAKI
2026-07-08 00:27:57.706842+07	BMRI	2800.0426893700037	72532	BBCA	BMRI	HAKA
2026-07-07 23:14:57.706842+07	BMRI	2787.4192466498803	55996	BBCA	BMRI	HAKI
2026-07-07 22:13:57.706842+07	BMRI	2794.3275330550387	41850	BBCA	BMRI	HAKA
2026-07-07 22:01:57.706842+07	BMRI	2796.9358852884684	38179	BBCA	BMRI	HAKA
2026-07-07 20:10:57.706842+07	BMRI	2804.4633345972934	25088	BBCA	BMRI	HAKA
2026-07-07 19:20:57.706842+07	BMRI	2796.6153200128974	47638	BBCA	BMRI	HAKI
2026-07-07 18:29:57.706842+07	BMRI	2801.8446598360615	50263	BBCA	BMRI	HAKA
2026-07-07 18:02:57.706842+07	BMRI	2792.0247553086715	64311	BBCA	BMRI	HAKI
2026-07-07 16:24:57.706842+07	BMRI	2783.6840547040747	34845	BBCA	BMRI	HAKI
2026-07-07 15:30:57.706842+07	BMRI	2793.63612802892	38059	BBCA	BMRI	HAKA
2026-07-09 06:31:57.706842+07	BMRI	2812.542698858678	48317	BBCA	BMRI	HAKA
2026-07-09 05:49:57.706842+07	BMRI	2818.077761618473	60207	BBCA	BMRI	HAKA
2026-07-09 04:56:57.706842+07	BMRI	2820.9710346162233	26657	BBCA	BMRI	HAKA
2026-07-09 03:41:57.706842+07	BMRI	2815.153905208803	39162	BBCA	BMRI	HAKI
2026-07-09 02:26:57.706842+07	BMRI	2804.5749193872366	35273	BBCA	BMRI	HAKI
2026-07-09 01:32:57.706842+07	BMRI	2797.608503953351	47000	BBCA	BMRI	HAKI
2026-07-09 00:37:57.706842+07	BMRI	2795.6058697359376	44450	BBCA	BMRI	HAKI
2026-07-08 23:38:57.706842+07	BMRI	2803.410164308444	42904	BBCA	BMRI	HAKA
2026-07-08 22:43:57.706842+07	BMRI	2803.9612441488534	64151	BBCA	BMRI	HAKA
2026-07-08 21:38:57.706842+07	BMRI	2810.163958489145	56632	BBCA	BMRI	HAKA
2026-07-08 20:16:57.706842+07	BMRI	2813.087174261091	52544	BBCA	BMRI	HAKA
2026-07-08 19:54:57.706842+07	BMRI	2807.721377938901	57710	BBCA	BMRI	HAKI
2026-07-08 18:49:57.706842+07	BMRI	2814.810182301758	25159	BBCA	BMRI	HAKA
2026-07-08 17:58:57.706842+07	BMRI	2812.535724087864	51920	BBCA	BMRI	HAKI
2026-07-08 17:04:57.706842+07	BMRI	2806.976100578078	46533	BBCA	BMRI	HAKI
2026-07-08 15:05:57.706842+07	BMRI	2802.4589868232533	49282	BBCA	BMRI	HAKI
2026-07-02 10:50:59.012754+07	TLKM	5755.034836916992	31393	BBCA	BMRI	HAKI
2026-07-02 09:55:59.012754+07	TLKM	5748.226260514616	52618	BBCA	BMRI	HAKI
2026-07-02 08:43:59.012754+07	TLKM	5732.806215860672	23821	BBCA	BMRI	HAKI
2026-07-02 07:36:59.012754+07	TLKM	5720.415928832068	38318	BBCA	BMRI	HAKI
2026-07-03 10:12:59.012754+07	TLKM	5796.868116376278	51177	BBCA	BMRI	HAKI
2026-07-03 09:59:59.012754+07	TLKM	5787.85074308803	56912	BBCA	BMRI	HAKI
2026-07-03 08:39:59.012754+07	TLKM	5785.717670884494	36615	BBCA	BMRI	HAKI
2026-07-03 08:01:59.012754+07	TLKM	5770.977927530996	48280	BBCA	BMRI	HAKI
2026-07-03 06:32:59.012754+07	TLKM	5778.109937785316	48292	BBCA	BMRI	HAKA
2026-07-03 05:14:59.012754+07	TLKM	5791.501500871627	40368	BBCA	BMRI	HAKA
2026-07-03 04:34:59.012754+07	TLKM	5790.759833297136	26025	BBCA	BMRI	HAKI
2026-07-03 03:25:59.012754+07	TLKM	5795.457047002862	62148	BBCA	BMRI	HAKA
2026-07-03 02:56:59.012754+07	TLKM	5782.715793046187	55982	BBCA	BMRI	HAKI
2026-07-03 01:30:59.012754+07	TLKM	5794.893814247179	51081	BBCA	BMRI	HAKA
2026-07-03 00:11:59.012754+07	TLKM	5809.311904900205	50183	BBCA	BMRI	HAKA
2026-07-02 23:45:59.012754+07	TLKM	5807.661722995414	49904	BBCA	BMRI	HAKI
2026-07-02 22:55:59.012754+07	TLKM	5811.797312603938	60968	BBCA	BMRI	HAKA
2026-07-02 21:43:59.012754+07	TLKM	5800.306747552172	44652	BBCA	BMRI	HAKI
2026-07-02 20:38:59.012754+07	TLKM	5817.128676295764	54652	BBCA	BMRI	HAKA
2026-07-02 19:22:59.012754+07	TLKM	5821.304249132504	54216	BBCA	BMRI	HAKA
2026-07-02 18:31:59.012754+07	TLKM	5820.369106179957	66445	BBCA	BMRI	HAKI
2026-07-02 17:34:59.012754+07	TLKM	5825.713231864603	46636	BBCA	BMRI	HAKA
2026-07-02 16:12:59.012754+07	TLKM	5818.169370195722	56736	BBCA	BMRI	HAKI
2026-07-02 15:30:59.012754+07	TLKM	5806.082687374518	46867	BBCA	BMRI	HAKI
2026-07-04 10:37:59.012754+07	TLKM	5813.864415587376	43458	BBCA	BMRI	HAKA
2026-07-04 10:01:59.012754+07	TLKM	5819.4624597213815	52044	BBCA	BMRI	HAKA
2026-07-04 08:54:59.012754+07	TLKM	5838.085826279446	54127	BBCA	BMRI	HAKA
2026-07-04 08:03:59.012754+07	TLKM	5843.985752217212	56456	BBCA	BMRI	HAKA
2026-07-04 06:30:59.012754+07	TLKM	5853.02155177368	39942	BBCA	BMRI	HAKA
2026-07-04 05:56:59.012754+07	TLKM	5858.7437690559045	43219	BBCA	BMRI	HAKA
2026-07-04 05:02:59.012754+07	TLKM	5865.836799506204	58211	BBCA	BMRI	HAKA
2026-07-04 03:28:59.012754+07	TLKM	5870.753227020882	46086	BBCA	BMRI	HAKA
2026-07-04 02:53:59.012754+07	TLKM	5882.392603119866	69672	BBCA	BMRI	HAKA
2026-07-04 01:09:59.012754+07	TLKM	5879.882388848204	41642	BBCA	BMRI	HAKI
2026-07-04 00:16:59.012754+07	TLKM	5875.085407501087	46255	BBCA	BMRI	HAKI
2026-07-03 23:15:59.012754+07	TLKM	5875.9691100063865	51352	BBCA	BMRI	HAKA
2026-07-03 22:21:59.012754+07	TLKM	5865.2567920877045	47847	BBCA	BMRI	HAKI
2026-07-03 21:55:59.012754+07	TLKM	5856.661901491224	47283	BBCA	BMRI	HAKI
2026-07-03 20:40:59.012754+07	TLKM	5874.566275229167	64185	BBCA	BMRI	HAKA
2026-07-03 19:50:59.012754+07	TLKM	5882.675527791491	50004	BBCA	BMRI	HAKA
2026-07-03 18:50:59.012754+07	TLKM	5891.105447184361	33451	BBCA	BMRI	HAKA
2026-07-03 17:20:59.012754+07	TLKM	5881.892583582024	45587	BBCA	BMRI	HAKI
2026-07-03 16:32:59.012754+07	TLKM	5879.642783306783	41790	BBCA	BMRI	HAKI
2026-07-03 15:16:59.012754+07	TLKM	5896.9426652563225	54264	BBCA	BMRI	HAKA
2026-07-05 10:50:59.012754+07	TLKM	5912.802137481495	59994	BBCA	BMRI	HAKA
2026-07-05 09:42:59.012754+07	TLKM	5912.007478995296	28133	BBCA	BMRI	HAKI
2026-07-05 08:56:59.012754+07	TLKM	5921.728196698302	45539	BBCA	BMRI	HAKA
2026-07-05 07:36:59.012754+07	TLKM	5913.268924330923	50201	BBCA	BMRI	HAKI
2026-07-05 06:24:59.012754+07	TLKM	5906.744667131811	56660	BBCA	BMRI	HAKI
2026-07-05 05:05:59.012754+07	TLKM	5892.95033316211	58208	BBCA	BMRI	HAKI
2026-07-05 04:12:59.012754+07	TLKM	5894.0709393821	47705	BBCA	BMRI	HAKA
2026-07-05 03:33:59.012754+07	TLKM	5877.516489287845	28967	BBCA	BMRI	HAKI
2026-07-05 03:02:59.012754+07	TLKM	5895.082393405579	49834	BBCA	BMRI	HAKA
2026-07-05 02:00:59.012754+07	TLKM	5895.1073779655235	65160	BBCA	BMRI	HAKA
2026-07-05 00:16:59.012754+07	TLKM	5888.754963432088	46062	BBCA	BMRI	HAKI
2026-07-04 23:58:59.012754+07	TLKM	5880.3974334310515	48248	BBCA	BMRI	HAKI
2026-07-04 22:35:59.012754+07	TLKM	5892.141323396609	63966	BBCA	BMRI	HAKA
2026-07-04 22:02:59.012754+07	TLKM	5869.015480904904	51003	BBCA	BMRI	HAKI
2026-07-04 20:08:59.012754+07	TLKM	5861.332818205703	37217	BBCA	BMRI	HAKI
2026-07-04 20:02:59.012754+07	TLKM	5872.639349454278	43397	BBCA	BMRI	HAKA
2026-07-04 18:37:59.012754+07	TLKM	5869.437913984506	50567	BBCA	BMRI	HAKI
2026-07-04 17:39:59.012754+07	TLKM	5893.757100209427	39327	BBCA	BMRI	HAKA
2026-07-04 16:10:59.012754+07	TLKM	5897.6542076468995	48815	BBCA	BMRI	HAKA
2026-07-04 15:26:59.012754+07	TLKM	5903.170257671019	50486	BBCA	BMRI	HAKA
2026-07-06 10:51:59.012754+07	TLKM	5893.9663166584705	50447	BBCA	BMRI	HAKI
2026-07-06 09:48:59.012754+07	TLKM	5902.039161910736	30843	BBCA	BMRI	HAKA
2026-07-06 08:56:59.012754+07	TLKM	5899.602450556882	42335	BBCA	BMRI	HAKI
2026-07-06 07:05:59.012754+07	TLKM	5921.566988313975	60944	BBCA	BMRI	HAKA
2026-07-06 06:37:59.012754+07	TLKM	5934.909921938054	65365	BBCA	BMRI	HAKA
2026-07-06 05:08:59.012754+07	TLKM	5946.8997835744985	39675	BBCA	BMRI	HAKA
2026-07-06 04:14:59.012754+07	TLKM	5946.662645626274	43707	BBCA	BMRI	HAKI
2026-07-06 03:48:59.012754+07	TLKM	5953.738552901942	37477	BBCA	BMRI	HAKA
2026-07-06 02:24:59.012754+07	TLKM	5941.400684573869	58760	BBCA	BMRI	HAKI
2026-07-06 01:28:59.012754+07	TLKM	5954.226074117577	45877	BBCA	BMRI	HAKA
2026-07-06 00:18:59.012754+07	TLKM	5957.8481605829	53618	BBCA	BMRI	HAKA
2026-07-05 23:44:59.012754+07	TLKM	5958.650926804118	54364	BBCA	BMRI	HAKA
2026-07-05 22:46:59.012754+07	TLKM	5952.958752170401	53979	BBCA	BMRI	HAKI
2026-07-05 21:42:59.012754+07	TLKM	5948.846469733403	42292	BBCA	BMRI	HAKI
2026-07-05 21:00:59.012754+07	TLKM	5958.017419611673	61872	BBCA	BMRI	HAKA
2026-07-05 19:27:59.012754+07	TLKM	5957.924564851485	51847	BBCA	BMRI	HAKI
2026-07-05 18:16:59.012754+07	TLKM	5967.724407478009	64407	BBCA	BMRI	HAKA
2026-07-05 17:24:59.012754+07	TLKM	5979.575239180374	43838	BBCA	BMRI	HAKA
2026-07-05 16:09:59.012754+07	TLKM	5972.229029753286	64630	BBCA	BMRI	HAKI
2026-07-05 15:46:59.012754+07	TLKM	5962.350673792104	43293	BBCA	BMRI	HAKI
2026-07-07 10:07:59.012754+07	TLKM	5963.309740676705	58937	BBCA	BMRI	HAKA
2026-07-07 10:00:59.012754+07	TLKM	5968.990632652537	32959	BBCA	BMRI	HAKA
2026-07-07 08:09:59.012754+07	TLKM	5979.247438686678	52046	BBCA	BMRI	HAKA
2026-07-07 07:57:59.012754+07	TLKM	5981.596828642186	63809	BBCA	BMRI	HAKA
2026-07-07 06:39:59.012754+07	TLKM	5983.340855723336	52052	BBCA	BMRI	HAKA
2026-07-07 05:44:59.012754+07	TLKM	5959.964734557837	55066	BBCA	BMRI	HAKI
2026-07-07 04:13:59.012754+07	TLKM	5956.182730790341	54296	BBCA	BMRI	HAKI
2026-07-07 03:05:59.012754+07	TLKM	5962.030091507937	53538	BBCA	BMRI	HAKA
2026-07-07 02:37:59.012754+07	TLKM	5973.577707045286	46928	BBCA	BMRI	HAKA
2026-07-07 02:04:59.012754+07	TLKM	5980.09824403671	47085	BBCA	BMRI	HAKA
2026-07-07 00:36:59.012754+07	TLKM	6001.260953499235	69959	BBCA	BMRI	HAKA
2026-07-06 23:27:59.012754+07	TLKM	5995.951962427399	51440	BBCA	BMRI	HAKI
2026-07-06 22:15:59.012754+07	TLKM	5989.035408686658	62782	BBCA	BMRI	HAKI
2026-07-06 21:41:59.012754+07	TLKM	5980.441868470372	36381	BBCA	BMRI	HAKI
2026-07-06 20:10:59.012754+07	TLKM	5977.597553688391	45847	BBCA	BMRI	HAKI
2026-07-06 19:56:59.012754+07	TLKM	5967.659779182921	33194	BBCA	BMRI	HAKI
2026-07-06 18:33:59.012754+07	TLKM	5966.941900593522	46441	BBCA	BMRI	HAKI
2026-07-06 17:08:59.012754+07	TLKM	5961.398646936079	52919	BBCA	BMRI	HAKI
2026-07-06 16:28:59.012754+07	TLKM	5962.8496848842415	41732	BBCA	BMRI	HAKA
2026-07-06 15:13:59.012754+07	TLKM	5949.917804970792	39007	BBCA	BMRI	HAKI
2026-07-08 10:55:59.012754+07	TLKM	5961.705609489156	51625	BBCA	BMRI	HAKA
2026-07-08 09:36:59.012754+07	TLKM	5948.808267718468	34273	BBCA	BMRI	HAKI
2026-07-08 09:01:59.012754+07	TLKM	5943.655966414591	51590	BBCA	BMRI	HAKI
2026-07-08 07:31:59.012754+07	TLKM	5941.59484021315	42528	BBCA	BMRI	HAKI
2026-07-08 06:36:59.012754+07	TLKM	5948.11212877733	43750	BBCA	BMRI	HAKA
2026-07-08 05:36:59.012754+07	TLKM	5942.8146013083	50958	BBCA	BMRI	HAKI
2026-07-08 04:21:59.012754+07	TLKM	5934.536290947502	39188	BBCA	BMRI	HAKI
2026-07-08 03:23:59.012754+07	TLKM	5945.202274517985	52195	BBCA	BMRI	HAKA
2026-07-08 02:15:59.012754+07	TLKM	5957.929636243324	34266	BBCA	BMRI	HAKA
2026-07-08 01:40:59.012754+07	TLKM	5956.6896969338695	61961	BBCA	BMRI	HAKI
2026-07-08 00:54:59.012754+07	TLKM	5931.604235335103	70293	BBCA	BMRI	HAKI
2026-07-07 23:16:59.012754+07	TLKM	5928.975015967781	43423	BBCA	BMRI	HAKI
2026-07-07 23:00:59.012754+07	TLKM	5940.80908884582	36736	BBCA	BMRI	HAKA
2026-07-07 22:04:59.012754+07	TLKM	5925.2936378911445	58616	BBCA	BMRI	HAKI
2026-07-07 20:34:59.012754+07	TLKM	5921.637859593505	44413	BBCA	BMRI	HAKI
2026-07-07 19:27:59.012754+07	TLKM	5921.2974893181445	66896	BBCA	BMRI	HAKI
2026-07-07 18:53:59.012754+07	TLKM	5927.696938587817	60856	BBCA	BMRI	HAKA
2026-07-07 17:11:59.012754+07	TLKM	5920.19695224305	49360	BBCA	BMRI	HAKI
2026-07-07 16:35:59.012754+07	TLKM	5896.2975842008245	46166	BBCA	BMRI	HAKI
2026-07-07 15:23:59.012754+07	TLKM	5873.230899055878	44066	BBCA	BMRI	HAKI
2026-07-09 06:06:59.012754+07	TLKM	5864.343010797275	46719	BBCA	BMRI	HAKI
2026-07-09 05:07:59.012754+07	TLKM	5869.330856377169	58849	BBCA	BMRI	HAKA
2026-07-09 04:31:59.012754+07	TLKM	5865.982116956801	56644	BBCA	BMRI	HAKI
2026-07-09 03:25:59.012754+07	TLKM	5844.209273677886	69507	BBCA	BMRI	HAKI
2026-07-09 02:47:59.012754+07	TLKM	5854.084794108399	39158	BBCA	BMRI	HAKA
2026-07-09 02:04:59.012754+07	TLKM	5846.939632174782	52509	BBCA	BMRI	HAKI
2026-07-09 00:37:59.012754+07	TLKM	5837.549862805786	40592	BBCA	BMRI	HAKI
2026-07-09 00:04:59.012754+07	TLKM	5844.646991952266	44410	BBCA	BMRI	HAKA
2026-07-08 22:15:59.012754+07	TLKM	5849.49497778971	37336	BBCA	BMRI	HAKA
2026-07-08 21:24:59.012754+07	TLKM	5868.824233050192	33996	BBCA	BMRI	HAKA
2026-07-08 20:52:59.012754+07	TLKM	5883.654320160311	66495	BBCA	BMRI	HAKA
2026-07-08 19:48:59.012754+07	TLKM	5906.244905444528	55475	BBCA	BMRI	HAKA
2026-07-08 18:54:59.012754+07	TLKM	5883.66561379622	50633	BBCA	BMRI	HAKI
2026-07-08 17:44:59.012754+07	TLKM	5900.206002018587	43023	BBCA	BMRI	HAKA
2026-07-08 16:09:59.012754+07	TLKM	5904.243128071407	56382	BBCA	BMRI	HAKA
2026-07-08 15:42:59.012754+07	TLKM	5914.454775133738	60527	BBCA	BMRI	HAKA
2026-07-02 10:06:00.280677+07	ASII	2016.4652883631766	70504	BBCA	BMRI	HAKI
2026-07-02 09:34:00.280677+07	ASII	2017.2941332838561	52413	BBCA	BMRI	HAKA
2026-07-02 08:08:00.280677+07	ASII	2020.3297716000452	58783	BBCA	BMRI	HAKA
2026-07-02 07:38:00.280677+07	ASII	2020.902102500215	52095	BBCA	BMRI	HAKA
2026-07-03 11:05:00.280677+07	ASII	2050.879877695944	29385	BBCA	BMRI	HAKA
2026-07-03 09:39:00.280677+07	ASII	2051.1825501338235	65443	BBCA	BMRI	HAKA
2026-07-03 08:39:00.280677+07	ASII	2045.6542622239276	45263	BBCA	BMRI	HAKI
2026-07-03 07:08:00.280677+07	ASII	2047.4967707830983	56934	BBCA	BMRI	HAKA
2026-07-03 06:14:00.280677+07	ASII	2050.485107816796	46784	BBCA	BMRI	HAKA
2026-07-03 05:20:00.280677+07	ASII	2045.6560274249089	64083	BBCA	BMRI	HAKI
2026-07-03 05:02:00.280677+07	ASII	2046.5158928406593	36189	BBCA	BMRI	HAKA
2026-07-03 04:03:00.280677+07	ASII	2044.1268948738682	43785	BBCA	BMRI	HAKI
2026-07-03 02:14:00.280677+07	ASII	2040.3185092195677	50948	BBCA	BMRI	HAKI
2026-07-03 01:45:00.280677+07	ASII	2041.2876787420653	37746	BBCA	BMRI	HAKA
2026-07-03 00:58:00.280677+07	ASII	2039.223942627947	62151	BBCA	BMRI	HAKI
2026-07-02 23:21:00.280677+07	ASII	2044.6924639505553	47797	BBCA	BMRI	HAKA
2026-07-02 22:12:00.280677+07	ASII	2043.996440482821	69440	BBCA	BMRI	HAKI
2026-07-02 22:04:00.280677+07	ASII	2043.1219655994103	37590	BBCA	BMRI	HAKI
2026-07-02 20:35:00.280677+07	ASII	2047.9335606182044	41074	BBCA	BMRI	HAKA
2026-07-02 20:03:00.280677+07	ASII	2052.1914114890787	55951	BBCA	BMRI	HAKA
2026-07-02 18:42:00.280677+07	ASII	2051.7763290169337	55216	BBCA	BMRI	HAKI
2026-07-02 17:24:00.280677+07	ASII	2060.1251547305806	49306	BBCA	BMRI	HAKA
2026-07-02 16:17:00.280677+07	ASII	2059.8118430901973	53746	BBCA	BMRI	HAKI
2026-07-02 15:28:00.280677+07	ASII	2061.225710641635	44831	BBCA	BMRI	HAKA
2026-07-04 10:30:00.280677+07	ASII	2057.284157947383	37166	BBCA	BMRI	HAKI
2026-07-04 09:23:00.280677+07	ASII	2052.7528792053363	49625	BBCA	BMRI	HAKI
2026-07-04 08:53:00.280677+07	ASII	2051.9769307193746	52333	BBCA	BMRI	HAKI
2026-07-04 08:01:00.280677+07	ASII	2056.6476627107522	59782	BBCA	BMRI	HAKA
2026-07-04 06:09:00.280677+07	ASII	2063.4339776130055	51856	BBCA	BMRI	HAKA
2026-07-04 05:39:00.280677+07	ASII	2064.85088686765	46669	BBCA	BMRI	HAKA
2026-07-04 04:20:00.280677+07	ASII	2061.0871780409493	45430	BBCA	BMRI	HAKI
2026-07-04 03:38:00.280677+07	ASII	2061.371848995279	36132	BBCA	BMRI	HAKA
2026-07-04 02:16:00.280677+07	ASII	2053.9667088721294	23206	BBCA	BMRI	HAKI
2026-07-04 01:08:00.280677+07	ASII	2058.3098788753255	57172	BBCA	BMRI	HAKA
2026-07-04 00:32:00.280677+07	ASII	2061.563643949959	60736	BBCA	BMRI	HAKA
2026-07-03 23:44:00.280677+07	ASII	2059.842358534099	42851	BBCA	BMRI	HAKI
2026-07-03 22:24:00.280677+07	ASII	2051.530864348308	44516	BBCA	BMRI	HAKI
2026-07-03 21:42:00.280677+07	ASII	2050.7827990408778	50278	BBCA	BMRI	HAKI
2026-07-03 20:40:00.280677+07	ASII	2047.4057847219115	36776	BBCA	BMRI	HAKI
2026-07-03 19:07:00.280677+07	ASII	2042.1846280629957	40593	BBCA	BMRI	HAKI
2026-07-03 18:56:00.280677+07	ASII	2037.5301901983846	48852	BBCA	BMRI	HAKI
2026-07-03 17:18:00.280677+07	ASII	2044.2499573203152	47538	BBCA	BMRI	HAKA
2026-07-03 17:05:00.280677+07	ASII	2045.597534202987	50615	BBCA	BMRI	HAKA
2026-07-03 15:48:00.280677+07	ASII	2051.78631190942	50569	BBCA	BMRI	HAKA
2026-07-05 10:12:00.280677+07	ASII	2050.214698926536	43796	BBCA	BMRI	HAKI
2026-07-05 09:11:00.280677+07	ASII	2046.480310060243	54272	BBCA	BMRI	HAKI
2026-07-05 08:58:00.280677+07	ASII	2046.7382926632076	52163	BBCA	BMRI	HAKA
2026-07-05 08:04:00.280677+07	ASII	2050.972287722296	30345	BBCA	BMRI	HAKA
2026-07-05 06:51:00.280677+07	ASII	2042.662510627791	41975	BBCA	BMRI	HAKI
2026-07-05 05:24:00.280677+07	ASII	2040.1775550271814	44157	BBCA	BMRI	HAKI
2026-07-05 04:40:00.280677+07	ASII	2040.2778101792735	49575	BBCA	BMRI	HAKA
2026-07-05 03:59:00.280677+07	ASII	2044.053969481504	59760	BBCA	BMRI	HAKA
2026-07-05 02:20:00.280677+07	ASII	2037.2986262542315	44736	BBCA	BMRI	HAKI
2026-07-05 01:41:00.280677+07	ASII	2041.398123147471	48598	BBCA	BMRI	HAKA
2026-07-05 00:34:00.280677+07	ASII	2038.271054636033	63563	BBCA	BMRI	HAKI
2026-07-04 23:43:00.280677+07	ASII	2036.885324297643	56417	BBCA	BMRI	HAKI
2026-07-04 22:38:00.280677+07	ASII	2041.0845323441192	32864	BBCA	BMRI	HAKA
2026-07-04 21:41:00.280677+07	ASII	2040.7093921103906	45707	BBCA	BMRI	HAKI
2026-07-04 20:57:00.280677+07	ASII	2035.797159219568	43835	BBCA	BMRI	HAKI
2026-07-04 20:02:00.280677+07	ASII	2041.3876736979748	47084	BBCA	BMRI	HAKA
2026-07-04 18:08:00.280677+07	ASII	2035.1366007958557	63335	BBCA	BMRI	HAKI
2026-07-04 17:43:00.280677+07	ASII	2031.5615580431472	54539	BBCA	BMRI	HAKI
2026-07-04 16:21:00.280677+07	ASII	2041.1362298851366	36066	BBCA	BMRI	HAKA
2026-07-04 15:51:00.280677+07	ASII	2041.4585887262865	62467	BBCA	BMRI	HAKA
2026-07-06 10:34:00.280677+07	ASII	2041.1414421682014	31232	BBCA	BMRI	HAKI
2026-07-06 09:41:00.280677+07	ASII	2036.9777395384024	48393	BBCA	BMRI	HAKI
2026-07-06 08:59:00.280677+07	ASII	2039.2389184336762	57560	BBCA	BMRI	HAKA
2026-07-06 07:18:00.280677+07	ASII	2044.5956039006876	60197	BBCA	BMRI	HAKA
2026-07-06 07:00:00.280677+07	ASII	2043.3030524870858	46592	BBCA	BMRI	HAKI
2026-07-06 05:21:00.280677+07	ASII	2046.1948239852077	45516	BBCA	BMRI	HAKA
2026-07-06 04:21:00.280677+07	ASII	2040.378460574343	57706	BBCA	BMRI	HAKI
2026-07-06 03:08:00.280677+07	ASII	2043.1557555678278	48663	BBCA	BMRI	HAKA
2026-07-06 02:38:00.280677+07	ASII	2041.3307193087269	55742	BBCA	BMRI	HAKI
2026-07-06 01:52:00.280677+07	ASII	2040.6423630343986	60401	BBCA	BMRI	HAKI
2026-07-06 00:11:00.280677+07	ASII	2037.9684158552036	54106	BBCA	BMRI	HAKI
2026-07-05 23:08:00.280677+07	ASII	2045.0631070309914	58898	BBCA	BMRI	HAKA
2026-07-05 22:44:00.280677+07	ASII	2050.1508490177093	47940	BBCA	BMRI	HAKA
2026-07-05 21:49:00.280677+07	ASII	2051.8664955656413	52896	BBCA	BMRI	HAKA
2026-07-05 20:37:00.280677+07	ASII	2049.6650883887028	46211	BBCA	BMRI	HAKI
2026-07-05 19:37:00.280677+07	ASII	2048.9965504519705	37172	BBCA	BMRI	HAKI
2026-07-05 18:12:00.280677+07	ASII	2043.3367068269158	45655	BBCA	BMRI	HAKI
2026-07-05 17:20:00.280677+07	ASII	2048.4898952993735	43885	BBCA	BMRI	HAKA
2026-07-05 16:26:00.280677+07	ASII	2051.9558468317264	44984	BBCA	BMRI	HAKA
2026-07-05 15:48:00.280677+07	ASII	2049.7947582461948	61297	BBCA	BMRI	HAKI
2026-07-07 10:42:00.280677+07	ASII	2053.178813507428	62970	BBCA	BMRI	HAKA
2026-07-07 09:56:00.280677+07	ASII	2050.690164310782	54726	BBCA	BMRI	HAKI
2026-07-07 08:20:00.280677+07	ASII	2049.377810315893	38445	BBCA	BMRI	HAKI
2026-07-07 07:32:00.280677+07	ASII	2051.5963138358297	54942	BBCA	BMRI	HAKA
2026-07-07 06:24:00.280677+07	ASII	2048.20644254603	54993	BBCA	BMRI	HAKI
2026-07-07 05:36:00.280677+07	ASII	2048.24980553903	53905	BBCA	BMRI	HAKA
2026-07-07 05:02:00.280677+07	ASII	2049.0050440089785	57151	BBCA	BMRI	HAKA
2026-07-07 03:49:00.280677+07	ASII	2039.7838820532265	59288	BBCA	BMRI	HAKI
2026-07-07 02:15:00.280677+07	ASII	2038.337647690917	64780	BBCA	BMRI	HAKI
2026-07-07 01:32:00.280677+07	ASII	2039.3846196842997	51585	BBCA	BMRI	HAKA
2026-07-07 00:21:00.280677+07	ASII	2040.0757597436032	60032	BBCA	BMRI	HAKA
2026-07-06 23:40:00.280677+07	ASII	2044.6873781364166	63375	BBCA	BMRI	HAKA
2026-07-06 22:26:00.280677+07	ASII	2048.7900313930577	47083	BBCA	BMRI	HAKA
2026-07-06 21:22:00.280677+07	ASII	2048.454533008941	56946	BBCA	BMRI	HAKI
2026-07-06 20:32:00.280677+07	ASII	2041.5829177799314	57703	BBCA	BMRI	HAKI
2026-07-06 19:07:00.280677+07	ASII	2041.0691519580066	52413	BBCA	BMRI	HAKI
2026-07-06 18:31:00.280677+07	ASII	2044.9664255297373	45021	BBCA	BMRI	HAKA
2026-07-06 17:33:00.280677+07	ASII	2043.8591883211977	67325	BBCA	BMRI	HAKI
2026-07-06 16:34:00.280677+07	ASII	2045.1351523895446	39952	BBCA	BMRI	HAKA
2026-07-06 15:19:00.280677+07	ASII	2044.7554910774245	55254	BBCA	BMRI	HAKI
2026-07-08 10:34:00.280677+07	ASII	2044.1428314846025	52657	BBCA	BMRI	HAKI
2026-07-08 10:04:00.280677+07	ASII	2044.7584273737464	53316	BBCA	BMRI	HAKA
2026-07-08 08:56:00.280677+07	ASII	2049.62957778349	42831	BBCA	BMRI	HAKA
2026-07-08 07:36:00.280677+07	ASII	2045.0977421562936	56568	BBCA	BMRI	HAKI
2026-07-08 06:57:00.280677+07	ASII	2046.9743230470997	46635	BBCA	BMRI	HAKA
2026-07-08 05:34:00.280677+07	ASII	2049.2339612731116	40856	BBCA	BMRI	HAKA
2026-07-08 04:26:00.280677+07	ASII	2054.5242635520394	56620	BBCA	BMRI	HAKA
2026-07-08 03:37:00.280677+07	ASII	2061.993041464601	55362	BBCA	BMRI	HAKA
2026-07-08 02:29:00.280677+07	ASII	2061.0951150812502	41792	BBCA	BMRI	HAKI
2026-07-08 01:55:00.280677+07	ASII	2057.052490607462	40568	BBCA	BMRI	HAKI
2026-07-08 00:28:00.280677+07	ASII	2050.2454141254716	40510	BBCA	BMRI	HAKI
2026-07-07 23:16:00.280677+07	ASII	2048.4711053471933	37135	BBCA	BMRI	HAKI
2026-07-07 22:54:00.280677+07	ASII	2051.28088627223	60060	BBCA	BMRI	HAKA
2026-07-07 22:02:00.280677+07	ASII	2053.2873763531047	60595	BBCA	BMRI	HAKA
2026-07-07 20:18:00.280677+07	ASII	2053.011766537956	45438	BBCA	BMRI	HAKI
2026-07-07 19:27:00.280677+07	ASII	2052.085232511356	38977	BBCA	BMRI	HAKI
2026-07-07 18:10:00.280677+07	ASII	2059.0766774578315	57601	BBCA	BMRI	HAKA
2026-07-07 17:06:00.280677+07	ASII	2055.7254673066673	38548	BBCA	BMRI	HAKI
2026-07-07 16:27:00.280677+07	ASII	2057.9553757165913	34947	BBCA	BMRI	HAKA
2026-07-07 15:30:00.280677+07	ASII	2057.1273286917763	47091	BBCA	BMRI	HAKI
2026-07-09 06:23:00.280677+07	ASII	2068.301355106481	58132	BBCA	BMRI	HAKI
2026-07-09 05:46:00.280677+07	ASII	2056.801809701039	32205	BBCA	BMRI	HAKI
2026-07-09 04:42:00.280677+07	ASII	2061.350574095915	48446	BBCA	BMRI	HAKA
2026-07-09 03:53:00.280677+07	ASII	2058.497070837077	39720	BBCA	BMRI	HAKI
2026-07-09 02:34:00.280677+07	ASII	2059.168653293232	53984	BBCA	BMRI	HAKA
2026-07-09 01:08:00.280677+07	ASII	2052.1417157624533	55350	BBCA	BMRI	HAKI
2026-07-09 00:55:00.280677+07	ASII	2050.4321853156816	52089	BBCA	BMRI	HAKI
2026-07-08 23:34:00.280677+07	ASII	2047.2596491231582	36265	BBCA	BMRI	HAKI
2026-07-08 22:36:00.280677+07	ASII	2039.7180074253877	69548	BBCA	BMRI	HAKI
2026-07-08 21:08:00.280677+07	ASII	2037.6501409176265	62372	BBCA	BMRI	HAKI
2026-07-08 20:47:00.280677+07	ASII	2035.590590000871	49958	BBCA	BMRI	HAKI
2026-07-08 19:33:00.280677+07	ASII	2035.1183896668583	59883	BBCA	BMRI	HAKI
2026-07-08 18:22:00.280677+07	ASII	2034.1374254499437	36129	BBCA	BMRI	HAKI
2026-07-08 18:03:00.280677+07	ASII	2032.4662612677068	60475	BBCA	BMRI	HAKI
2026-07-08 16:16:00.280677+07	ASII	2030.3857309834498	44291	BBCA	BMRI	HAKI
2026-07-08 15:24:00.280677+07	ASII	2027.2491073061638	67279	BBCA	BMRI	HAKI
2026-07-02 10:32:19.336736+07	BBCA	3917.4814857447577	49073	BBCA	BMRI	HAKA
2026-07-02 09:21:19.336736+07	BBCA	3917.5767584819364	40684	BBCA	BMRI	HAKA
2026-07-02 08:57:19.336736+07	BBCA	3920.138936616583	68535	BBCA	BMRI	HAKA
2026-07-02 07:25:19.336736+07	BBCA	3918.6855488283823	51936	BBCA	BMRI	HAKI
2026-07-03 10:23:19.336736+07	BBCA	3874.935197572175	28756	BBCA	BMRI	HAKI
2026-07-03 10:04:19.336736+07	BBCA	3864.347906132216	50462	BBCA	BMRI	HAKI
2026-07-03 08:54:19.336736+07	BBCA	3881.045380985264	41301	BBCA	BMRI	HAKA
2026-07-03 07:49:19.336736+07	BBCA	3889.702305965383	47439	BBCA	BMRI	HAKA
2026-07-03 06:44:19.336736+07	BBCA	3883.104982761133	41870	BBCA	BMRI	HAKI
2026-07-03 05:09:19.336736+07	BBCA	3896.08999581561	53111	BBCA	BMRI	HAKA
2026-07-03 04:37:19.336736+07	BBCA	3892.199095258885	38607	BBCA	BMRI	HAKI
2026-07-03 03:41:19.336736+07	BBCA	3885.177177272327	38423	BBCA	BMRI	HAKI
2026-07-03 02:56:19.336736+07	BBCA	3889.385662482041	48753	BBCA	BMRI	HAKA
2026-07-03 01:55:19.336736+07	BBCA	3896.2776527784017	44031	BBCA	BMRI	HAKA
2026-07-03 00:07:19.336736+07	BBCA	3892.04069131049	53379	BBCA	BMRI	HAKI
2026-07-02 23:15:19.336736+07	BBCA	3887.461123016312	62823	BBCA	BMRI	HAKI
2026-07-02 22:21:19.336736+07	BBCA	3892.172877107959	41855	BBCA	BMRI	HAKA
2026-07-02 21:49:19.336736+07	BBCA	3899.0227678497276	45268	BBCA	BMRI	HAKA
2026-07-02 21:03:19.336736+07	BBCA	3895.872893398396	54476	BBCA	BMRI	HAKI
2026-07-02 20:00:19.336736+07	BBCA	3886.4188698167127	43671	BBCA	BMRI	HAKI
2026-07-02 18:19:19.336736+07	BBCA	3865.2475638216874	54613	BBCA	BMRI	HAKI
2026-07-02 17:17:19.336736+07	BBCA	3875.0998370317325	35196	BBCA	BMRI	HAKA
2026-07-02 16:17:19.336736+07	BBCA	3874.2966429060075	43670	BBCA	BMRI	HAKI
2026-07-02 16:04:19.336736+07	BBCA	3869.2700627930276	53704	BBCA	BMRI	HAKI
2026-07-04 10:10:19.336736+07	BBCA	3863.273752908731	30569	BBCA	BMRI	HAKI
2026-07-04 09:26:19.336736+07	BBCA	3862.465979665761	48430	BBCA	BMRI	HAKI
2026-07-04 08:18:19.336736+07	BBCA	3865.1228296791314	31278	BBCA	BMRI	HAKA
2026-07-04 07:31:19.336736+07	BBCA	3868.8493878709614	28007	BBCA	BMRI	HAKA
2026-07-04 06:10:19.336736+07	BBCA	3860.7904742411256	43496	BBCA	BMRI	HAKI
2026-07-04 06:00:19.336736+07	BBCA	3868.236121625037	31694	BBCA	BMRI	HAKA
2026-07-04 04:38:19.336736+07	BBCA	3874.048448311317	26835	BBCA	BMRI	HAKA
2026-07-04 03:22:19.336736+07	BBCA	3879.593937186522	53254	BBCA	BMRI	HAKA
2026-07-04 02:49:19.336736+07	BBCA	3876.5861528161417	43655	BBCA	BMRI	HAKI
2026-07-04 01:12:19.336736+07	BBCA	3901.081984083293	40210	BBCA	BMRI	HAKA
2026-07-04 00:45:19.336736+07	BBCA	3900.589962580164	48610	BBCA	BMRI	HAKI
2026-07-03 23:26:19.336736+07	BBCA	3910.1032834033554	57728	BBCA	BMRI	HAKA
2026-07-03 22:18:19.336736+07	BBCA	3917.081971144605	54337	BBCA	BMRI	HAKA
2026-07-03 21:50:19.336736+07	BBCA	3915.5000441170455	47517	BBCA	BMRI	HAKI
2026-07-03 20:33:19.336736+07	BBCA	3916.2832982485725	48193	BBCA	BMRI	HAKA
2026-07-03 19:33:19.336736+07	BBCA	3925.6885913311785	55324	BBCA	BMRI	HAKA
2026-07-03 18:45:19.336736+07	BBCA	3923.536004414852	52026	BBCA	BMRI	HAKI
2026-07-03 17:13:19.336736+07	BBCA	3936.7723340271573	51069	BBCA	BMRI	HAKA
2026-07-03 16:24:19.336736+07	BBCA	3933.066123041435	54289	BBCA	BMRI	HAKI
2026-07-03 15:17:19.336736+07	BBCA	3920.5575143673755	49320	BBCA	BMRI	HAKI
2026-07-05 10:40:19.336736+07	BBCA	3913.7084909191735	50661	BBCA	BMRI	HAKI
2026-07-05 09:07:19.336736+07	BBCA	3915.658292003444	51980	BBCA	BMRI	HAKA
2026-07-05 08:19:19.336736+07	BBCA	3924.5033146010446	57901	BBCA	BMRI	HAKA
2026-07-05 07:51:19.336736+07	BBCA	3943.420562494155	50320	BBCA	BMRI	HAKA
2026-07-05 07:00:19.336736+07	BBCA	3949.021574820143	44771	BBCA	BMRI	HAKA
2026-07-05 05:57:19.336736+07	BBCA	3959.0333052487435	68823	BBCA	BMRI	HAKA
2026-07-05 04:34:19.336736+07	BBCA	3955.2758293603515	63291	BBCA	BMRI	HAKI
2026-07-05 03:58:19.336736+07	BBCA	3963.3116052177397	53532	BBCA	BMRI	HAKA
2026-07-05 02:20:19.336736+07	BBCA	3962.3603289549633	42453	BBCA	BMRI	HAKI
2026-07-05 01:34:19.336736+07	BBCA	3966.133287769506	56390	BBCA	BMRI	HAKA
2026-07-05 00:44:19.336736+07	BBCA	3965.19030290001	58699	BBCA	BMRI	HAKI
2026-07-04 23:59:19.336736+07	BBCA	3982.4817253489136	52852	BBCA	BMRI	HAKA
2026-07-04 22:25:19.336736+07	BBCA	3985.6790284339595	55942	BBCA	BMRI	HAKA
2026-07-04 21:43:19.336736+07	BBCA	4001.0189502647954	56436	BBCA	BMRI	HAKA
2026-07-04 20:18:19.336736+07	BBCA	4003.783723434711	58399	BBCA	BMRI	HAKA
2026-07-04 19:46:19.336736+07	BBCA	4001.053052726144	58756	BBCA	BMRI	HAKI
2026-07-04 19:04:19.336736+07	BBCA	3999.164577220545	38552	BBCA	BMRI	HAKI
2026-07-04 17:51:19.336736+07	BBCA	3987.098802927501	55436	BBCA	BMRI	HAKI
2026-07-04 16:46:19.336736+07	BBCA	3983.5786762890166	48229	BBCA	BMRI	HAKI
2026-07-04 15:27:19.336736+07	BBCA	3974.446803266047	34590	BBCA	BMRI	HAKI
2026-07-06 10:58:19.336736+07	BBCA	3981.7369274256225	37606	BBCA	BMRI	HAKA
2026-07-06 09:50:19.336736+07	BBCA	3983.7045522094577	46401	BBCA	BMRI	HAKA
2026-07-06 08:28:19.336736+07	BBCA	3976.084936789886	54441	BBCA	BMRI	HAKI
2026-07-06 08:03:19.336736+07	BBCA	3969.3562130900464	66343	BBCA	BMRI	HAKI
2026-07-06 06:38:19.336736+07	BBCA	3979.3709295235494	50679	BBCA	BMRI	HAKA
2026-07-06 05:43:19.336736+07	BBCA	3994.5178513308047	52241	BBCA	BMRI	HAKA
2026-07-06 04:30:19.336736+07	BBCA	3990.2073533965518	40583	BBCA	BMRI	HAKI
2026-07-06 03:15:19.336736+07	BBCA	3993.4036938122163	62729	BBCA	BMRI	HAKA
2026-07-06 02:24:19.336736+07	BBCA	4007.7486264679783	50074	BBCA	BMRI	HAKA
2026-07-06 01:22:19.336736+07	BBCA	4010.597925553024	44800	BBCA	BMRI	HAKA
2026-07-06 00:13:19.336736+07	BBCA	4007.0846286120677	46201	BBCA	BMRI	HAKI
2026-07-05 23:17:19.336736+07	BBCA	4014.3457724538644	55055	BBCA	BMRI	HAKA
2026-07-05 22:46:19.336736+07	BBCA	4026.7416043462617	44583	BBCA	BMRI	HAKA
2026-07-05 21:41:19.336736+07	BBCA	4011.419302917735	50968	BBCA	BMRI	HAKI
2026-07-05 21:00:19.336736+07	BBCA	4010.80855019139	42964	BBCA	BMRI	HAKI
2026-07-05 19:42:19.336736+07	BBCA	4013.012900331999	49365	BBCA	BMRI	HAKA
2026-07-05 18:38:19.336736+07	BBCA	4015.5811253277234	65033	BBCA	BMRI	HAKA
2026-07-05 17:46:19.336736+07	BBCA	4022.0349289674677	48761	BBCA	BMRI	HAKA
2026-07-05 16:24:19.336736+07	BBCA	4029.1690548472825	57044	BBCA	BMRI	HAKA
2026-07-05 15:24:19.336736+07	BBCA	4033.227328279678	47726	BBCA	BMRI	HAKA
2026-07-07 10:53:19.336736+07	BBCA	4034.558904067459	63995	BBCA	BMRI	HAKA
2026-07-07 09:24:19.336736+07	BBCA	4026.3652218383872	45102	BBCA	BMRI	HAKI
2026-07-07 08:51:19.336736+07	BBCA	4022.537200764608	63842	BBCA	BMRI	HAKI
2026-07-07 07:13:19.336736+07	BBCA	4028.1781242871157	59908	BBCA	BMRI	HAKA
2026-07-07 06:27:19.336736+07	BBCA	4014.023044929687	48006	BBCA	BMRI	HAKI
2026-07-07 05:06:19.336736+07	BBCA	4020.569453705701	50060	BBCA	BMRI	HAKA
2026-07-07 04:18:19.336736+07	BBCA	4017.564695419858	56292	BBCA	BMRI	HAKI
2026-07-07 03:35:19.336736+07	BBCA	4022.266982848506	58515	BBCA	BMRI	HAKA
2026-07-07 02:58:19.336736+07	BBCA	4011.0299577064134	40838	BBCA	BMRI	HAKI
2026-07-07 01:52:19.336736+07	BBCA	4009.08167931459	42304	BBCA	BMRI	HAKI
2026-07-07 00:25:19.336736+07	BBCA	4013.6405652754815	61108	BBCA	BMRI	HAKA
2026-07-07 00:02:19.336736+07	BBCA	4013.8787319315625	71874	BBCA	BMRI	HAKA
2026-07-06 22:49:19.336736+07	BBCA	4017.6800128715518	43469	BBCA	BMRI	HAKA
2026-07-06 21:56:19.336736+07	BBCA	4015.125046528274	37797	BBCA	BMRI	HAKI
2026-07-06 20:29:19.336736+07	BBCA	4008.643768126982	53200	BBCA	BMRI	HAKI
2026-07-06 19:27:19.336736+07	BBCA	4014.6892422643364	52820	BBCA	BMRI	HAKA
2026-07-06 18:53:19.336736+07	BBCA	4019.6429124807546	49492	BBCA	BMRI	HAKA
2026-07-06 17:10:19.336736+07	BBCA	4028.4968488994236	55312	BBCA	BMRI	HAKA
2026-07-06 17:01:19.336736+07	BBCA	4028.5449880040546	36873	BBCA	BMRI	HAKA
2026-07-06 15:59:19.336736+07	BBCA	4024.897557693239	27753	BBCA	BMRI	HAKI
2026-07-08 10:22:19.336736+07	BBCA	4023.252126731512	36445	BBCA	BMRI	HAKI
2026-07-08 09:48:19.336736+07	BBCA	4008.2056581978068	51223	BBCA	BMRI	HAKI
2026-07-08 08:22:19.336736+07	BBCA	4005.4236258240835	63848	BBCA	BMRI	HAKI
2026-07-08 07:31:19.336736+07	BBCA	4016.5569426785523	45412	BBCA	BMRI	HAKA
2026-07-08 06:24:19.336736+07	BBCA	4015.357867053203	36168	BBCA	BMRI	HAKI
2026-07-08 05:25:19.336736+07	BBCA	4028.272634283712	53618	BBCA	BMRI	HAKA
2026-07-08 04:41:19.336736+07	BBCA	4024.81067385401	60340	BBCA	BMRI	HAKI
2026-07-08 03:40:19.336736+07	BBCA	4029.2382052411426	40667	BBCA	BMRI	HAKA
2026-07-08 02:19:19.336736+07	BBCA	4025.570683249842	55545	BBCA	BMRI	HAKI
2026-07-08 01:34:19.336736+07	BBCA	4035.788133721426	53240	BBCA	BMRI	HAKA
2026-07-08 00:26:19.336736+07	BBCA	4028.0003182862088	71777	BBCA	BMRI	HAKI
2026-07-07 23:37:19.336736+07	BBCA	4016.9267395151405	45251	BBCA	BMRI	HAKI
2026-07-07 23:02:19.336736+07	BBCA	4031.9883369910353	45030	BBCA	BMRI	HAKA
2026-07-07 21:10:19.336736+07	BBCA	4044.4044419140128	63400	BBCA	BMRI	HAKA
2026-07-07 20:37:19.336736+07	BBCA	4060.2281979543327	67557	BBCA	BMRI	HAKA
2026-07-07 19:18:19.336736+07	BBCA	4054.108532763618	34427	BBCA	BMRI	HAKI
2026-07-07 18:07:19.336736+07	BBCA	4054.0482264448356	63554	BBCA	BMRI	HAKI
2026-07-07 17:15:19.336736+07	BBCA	4050.0206831641403	53910	BBCA	BMRI	HAKI
2026-07-07 16:14:19.336736+07	BBCA	4049.050397469521	57724	BBCA	BMRI	HAKI
2026-07-07 15:55:19.336736+07	BBCA	4044.4598223067114	57219	BBCA	BMRI	HAKI
2026-07-09 06:42:19.336736+07	BBCA	4084.3716462800694	57938	BBCA	BMRI	HAKA
2026-07-09 06:01:19.336736+07	BBCA	4077.275016024379	35899	BBCA	BMRI	HAKI
2026-07-09 04:11:19.336736+07	BBCA	4080.4967672197336	56055	BBCA	BMRI	HAKA
2026-07-09 03:44:19.336736+07	BBCA	4088.900207283569	52133	BBCA	BMRI	HAKA
2026-07-09 02:16:19.336736+07	BBCA	4084.942443197693	54498	BBCA	BMRI	HAKI
2026-07-09 01:18:19.336736+07	BBCA	4092.8653373468787	48823	BBCA	BMRI	HAKA
2026-07-09 00:34:19.336736+07	BBCA	4092.0371663285964	60853	BBCA	BMRI	HAKI
2026-07-08 23:44:19.336736+07	BBCA	4091.425306597216	55337	BBCA	BMRI	HAKI
2026-07-08 22:56:19.336736+07	BBCA	4098.473027592078	59730	BBCA	BMRI	HAKA
2026-07-08 21:49:19.336736+07	BBCA	4094.6106556623195	38587	BBCA	BMRI	HAKI
2026-07-08 21:05:19.336736+07	BBCA	4082.533493675747	55556	BBCA	BMRI	HAKI
2026-07-08 19:07:19.336736+07	BBCA	4081.1034513233335	56306	BBCA	BMRI	HAKI
2026-07-08 18:38:19.336736+07	BBCA	4071.720142638778	46116	BBCA	BMRI	HAKI
2026-07-08 17:33:19.336736+07	BBCA	4061.4797515773776	41910	BBCA	BMRI	HAKI
2026-07-08 16:27:19.336736+07	BBCA	4058.956832136404	46410	BBCA	BMRI	HAKI
2026-07-08 15:25:19.336736+07	BBCA	4055.1534326343813	51484	BBCA	BMRI	HAKI
2026-07-02 10:34:20.623551+07	BBRI	2083.5487800251203	46645	BBCA	BMRI	HAKI
2026-07-02 10:00:20.623551+07	BBRI	2077.6435523220266	46675	BBCA	BMRI	HAKI
2026-07-02 08:59:20.623551+07	BBRI	2081.551548401166	66691	BBCA	BMRI	HAKA
2026-07-02 07:34:20.623551+07	BBRI	2084.1853969496055	61396	BBCA	BMRI	HAKA
2026-07-03 10:39:20.623551+07	BBRI	2056.540083538286	46647	BBCA	BMRI	HAKA
2026-07-03 09:56:20.623551+07	BBRI	2051.030739231187	45144	BBCA	BMRI	HAKI
2026-07-03 08:18:20.623551+07	BBRI	2048.5166022418325	46252	BBCA	BMRI	HAKI
2026-07-03 07:15:20.623551+07	BBRI	2048.446367471026	55763	BBCA	BMRI	HAKI
2026-07-03 06:34:20.623551+07	BBRI	2046.3255846577526	43186	BBCA	BMRI	HAKI
2026-07-03 05:53:20.623551+07	BBRI	2049.031191995903	45114	BBCA	BMRI	HAKA
2026-07-03 04:17:20.623551+07	BBRI	2055.158826183429	50318	BBCA	BMRI	HAKA
2026-07-03 04:00:20.623551+07	BBRI	2049.5252945501666	51064	BBCA	BMRI	HAKI
2026-07-03 02:13:20.623551+07	BBRI	2052.203727492132	50867	BBCA	BMRI	HAKA
2026-07-03 01:10:20.623551+07	BBRI	2049.6638722723314	42826	BBCA	BMRI	HAKI
2026-07-03 00:10:20.623551+07	BBRI	2051.0969980974396	58440	BBCA	BMRI	HAKA
2026-07-02 23:15:20.623551+07	BBRI	2053.0307607948807	63235	BBCA	BMRI	HAKA
2026-07-02 23:00:20.623551+07	BBRI	2053.46200130144	44104	BBCA	BMRI	HAKA
2026-07-02 21:13:20.623551+07	BBRI	2052.4747334878307	47231	BBCA	BMRI	HAKI
2026-07-02 20:55:20.623551+07	BBRI	2054.138412287745	36954	BBCA	BMRI	HAKA
2026-07-02 19:50:20.623551+07	BBRI	2055.2121294907647	65483	BBCA	BMRI	HAKA
2026-07-02 18:55:20.623551+07	BBRI	2057.0327314802544	49843	BBCA	BMRI	HAKA
2026-07-02 17:20:20.623551+07	BBRI	2055.3885639017644	40412	BBCA	BMRI	HAKI
2026-07-02 16:25:20.623551+07	BBRI	2048.822259579793	30181	BBCA	BMRI	HAKI
2026-07-02 15:58:20.623551+07	BBRI	2055.4746177475863	62449	BBCA	BMRI	HAKA
2026-07-04 10:55:20.623551+07	BBRI	2045.9167790124297	55392	BBCA	BMRI	HAKI
2026-07-04 09:39:20.623551+07	BBRI	2052.5942694685923	66878	BBCA	BMRI	HAKA
2026-07-04 09:02:20.623551+07	BBRI	2053.547505637062	75064	BBCA	BMRI	HAKA
2026-07-04 07:21:20.623551+07	BBRI	2053.850097637845	49666	BBCA	BMRI	HAKA
2026-07-04 06:40:20.623551+07	BBRI	2048.2973774988805	58219	BBCA	BMRI	HAKI
2026-07-04 05:09:20.623551+07	BBRI	2050.158204355471	29241	BBCA	BMRI	HAKA
2026-07-04 04:07:20.623551+07	BBRI	2051.765554228523	41115	BBCA	BMRI	HAKA
2026-07-04 03:25:20.623551+07	BBRI	2048.3136029945586	41228	BBCA	BMRI	HAKI
2026-07-04 03:05:20.623551+07	BBRI	2042.2835282708375	50809	BBCA	BMRI	HAKI
2026-07-04 01:27:20.623551+07	BBRI	2040.1381859169705	47544	BBCA	BMRI	HAKI
2026-07-04 00:54:20.623551+07	BBRI	2037.6107197563376	52025	BBCA	BMRI	HAKI
2026-07-03 23:42:20.623551+07	BBRI	2029.4593909305243	39040	BBCA	BMRI	HAKI
2026-07-03 22:23:20.623551+07	BBRI	2026.209895664398	47778	BBCA	BMRI	HAKI
2026-07-03 21:07:20.623551+07	BBRI	2018.8306784266435	64436	BBCA	BMRI	HAKI
2026-07-03 20:25:20.623551+07	BBRI	2007.5071241766468	76585	BBCA	BMRI	HAKI
2026-07-03 19:16:20.623551+07	BBRI	2007.1820101324515	53610	BBCA	BMRI	HAKI
2026-07-03 18:54:20.623551+07	BBRI	2006.4167937181683	54993	BBCA	BMRI	HAKI
2026-07-03 17:16:20.623551+07	BBRI	2006.3835138800823	68909	BBCA	BMRI	HAKI
2026-07-03 16:56:20.623551+07	BBRI	2005.5944180693355	51424	BBCA	BMRI	HAKI
2026-07-03 15:18:20.623551+07	BBRI	2009.2592865643342	55123	BBCA	BMRI	HAKA
2026-07-05 10:57:20.623551+07	BBRI	2012.4466304652708	43593	BBCA	BMRI	HAKA
2026-07-05 09:11:20.623551+07	BBRI	2016.7526971326834	57850	BBCA	BMRI	HAKA
2026-07-05 09:02:20.623551+07	BBRI	2020.873919628148	53089	BBCA	BMRI	HAKA
2026-07-05 07:20:20.623551+07	BBRI	2014.6681993802863	43010	BBCA	BMRI	HAKI
2026-07-05 06:39:20.623551+07	BBRI	2016.9127162226455	61482	BBCA	BMRI	HAKA
2026-07-05 05:38:20.623551+07	BBRI	2012.602577264328	56823	BBCA	BMRI	HAKI
2026-07-05 04:16:20.623551+07	BBRI	2010.0383856755866	41479	BBCA	BMRI	HAKI
2026-07-05 03:13:20.623551+07	BBRI	2003.151741990232	55470	BBCA	BMRI	HAKI
2026-07-05 02:17:20.623551+07	BBRI	2003.3912724749703	59341	BBCA	BMRI	HAKA
2026-07-05 01:20:20.623551+07	BBRI	2004.4622893973465	36751	BBCA	BMRI	HAKA
2026-07-05 00:18:20.623551+07	BBRI	2006.3336671763498	45283	BBCA	BMRI	HAKA
2026-07-04 23:07:20.623551+07	BBRI	2007.203410788826	60245	BBCA	BMRI	HAKA
2026-07-04 22:59:20.623551+07	BBRI	2011.42233798894	61912	BBCA	BMRI	HAKA
2026-07-04 21:34:20.623551+07	BBRI	2016.4583843571186	52954	BBCA	BMRI	HAKA
2026-07-04 20:33:20.623551+07	BBRI	2020.7266092242	49574	BBCA	BMRI	HAKA
2026-07-04 19:37:20.623551+07	BBRI	2023.2291554014423	46425	BBCA	BMRI	HAKA
2026-07-04 18:15:20.623551+07	BBRI	2020.7152335958442	45085	BBCA	BMRI	HAKI
2026-07-04 17:17:20.623551+07	BBRI	2021.7968297920663	49670	BBCA	BMRI	HAKA
2026-07-04 16:08:20.623551+07	BBRI	2019.277419537923	52796	BBCA	BMRI	HAKI
2026-07-04 15:19:20.623551+07	BBRI	2020.4807750687403	49331	BBCA	BMRI	HAKA
2026-07-06 10:10:20.623551+07	BBRI	2018.7556202438893	51889	BBCA	BMRI	HAKI
2026-07-06 09:54:20.623551+07	BBRI	2017.636312322764	51260	BBCA	BMRI	HAKI
2026-07-06 08:27:20.623551+07	BBRI	2016.0228128422425	45250	BBCA	BMRI	HAKI
2026-07-06 07:49:20.623551+07	BBRI	2016.993273209239	48398	BBCA	BMRI	HAKA
2026-07-06 06:49:20.623551+07	BBRI	2023.8321241495478	48428	BBCA	BMRI	HAKA
2026-07-06 05:49:20.623551+07	BBRI	2031.283952552701	50152	BBCA	BMRI	HAKA
2026-07-06 04:41:20.623551+07	BBRI	2029.625376105778	42565	BBCA	BMRI	HAKI
2026-07-06 03:30:20.623551+07	BBRI	2026.2499774102967	52030	BBCA	BMRI	HAKI
2026-07-06 02:12:20.623551+07	BBRI	2033.1505040691438	61929	BBCA	BMRI	HAKA
2026-07-06 01:55:20.623551+07	BBRI	2028.311139561296	42388	BBCA	BMRI	HAKI
2026-07-06 00:26:20.623551+07	BBRI	2029.2522185140986	60320	BBCA	BMRI	HAKA
2026-07-05 23:57:20.623551+07	BBRI	2024.9329958151488	25800	BBCA	BMRI	HAKI
2026-07-05 22:51:20.623551+07	BBRI	2023.831011709357	45959	BBCA	BMRI	HAKI
2026-07-05 21:09:20.623551+07	BBRI	2018.072650329354	57434	BBCA	BMRI	HAKI
2026-07-05 20:58:20.623551+07	BBRI	2016.6544235212866	49754	BBCA	BMRI	HAKI
2026-07-05 19:32:20.623551+07	BBRI	2017.5762977887243	47213	BBCA	BMRI	HAKA
2026-07-05 19:05:20.623551+07	BBRI	2018.2194825866245	53134	BBCA	BMRI	HAKA
2026-07-05 17:45:20.623551+07	BBRI	2020.3547708058352	51591	BBCA	BMRI	HAKA
2026-07-05 16:43:20.623551+07	BBRI	2023.4021603654983	35662	BBCA	BMRI	HAKA
2026-07-05 15:43:20.623551+07	BBRI	2022.7415070835198	38775	BBCA	BMRI	HAKI
2026-07-07 10:14:20.623551+07	BBRI	2018.25591055511	55724	BBCA	BMRI	HAKI
2026-07-07 09:28:20.623551+07	BBRI	2014.0446877008742	27396	BBCA	BMRI	HAKI
2026-07-07 08:54:20.623551+07	BBRI	2012.2083953226627	52555	BBCA	BMRI	HAKI
2026-07-07 07:08:20.623551+07	BBRI	2008.0410548164955	51252	BBCA	BMRI	HAKI
2026-07-07 06:12:20.623551+07	BBRI	2011.0826862912263	61901	BBCA	BMRI	HAKA
2026-07-07 05:53:20.623551+07	BBRI	2011.3596223504187	54691	BBCA	BMRI	HAKA
2026-07-07 05:03:20.623551+07	BBRI	2014.7323654700797	44870	BBCA	BMRI	HAKA
2026-07-07 04:02:20.623551+07	BBRI	2014.3708074980539	24229	BBCA	BMRI	HAKI
2026-07-07 02:51:20.623551+07	BBRI	2013.7551255549997	54272	BBCA	BMRI	HAKI
2026-07-07 01:53:20.623551+07	BBRI	2011.903230669892	41212	BBCA	BMRI	HAKI
2026-07-07 00:38:20.623551+07	BBRI	2009.5582261951938	58853	BBCA	BMRI	HAKI
2026-07-06 23:37:20.623551+07	BBRI	2014.0111231070262	60144	BBCA	BMRI	HAKA
2026-07-06 22:40:20.623551+07	BBRI	2014.5158337517084	39106	BBCA	BMRI	HAKA
2026-07-06 21:37:20.623551+07	BBRI	2015.959082264091	43032	BBCA	BMRI	HAKA
2026-07-06 20:49:20.623551+07	BBRI	2017.1066826457845	47752	BBCA	BMRI	HAKA
2026-07-06 19:38:20.623551+07	BBRI	2016.3258623837287	46436	BBCA	BMRI	HAKI
2026-07-06 18:30:20.623551+07	BBRI	2017.97632154056	38144	BBCA	BMRI	HAKA
2026-07-06 17:43:20.623551+07	BBRI	2017.9750857081365	56676	BBCA	BMRI	HAKI
2026-07-06 16:37:20.623551+07	BBRI	2016.3049697475149	49584	BBCA	BMRI	HAKI
2026-07-06 15:38:20.623551+07	BBRI	2018.5463574992282	51816	BBCA	BMRI	HAKA
2026-07-08 10:51:20.623551+07	BBRI	2019.4312853409501	46038	BBCA	BMRI	HAKA
2026-07-08 09:31:20.623551+07	BBRI	2023.5016002243929	45664	BBCA	BMRI	HAKA
2026-07-08 08:37:20.623551+07	BBRI	2034.3816033420785	56290	BBCA	BMRI	HAKA
2026-07-08 07:06:20.623551+07	BBRI	2035.6540552780964	55158	BBCA	BMRI	HAKA
2026-07-08 06:22:20.623551+07	BBRI	2039.6459684583301	61275	BBCA	BMRI	HAKA
2026-07-08 06:04:20.623551+07	BBRI	2047.2940949800425	33489	BBCA	BMRI	HAKA
2026-07-08 04:39:20.623551+07	BBRI	2047.0403569666814	61972	BBCA	BMRI	HAKI
2026-07-08 03:09:20.623551+07	BBRI	2046.9023245024932	31729	BBCA	BMRI	HAKI
2026-07-08 03:00:20.623551+07	BBRI	2047.7287150209095	39085	BBCA	BMRI	HAKA
2026-07-08 01:26:20.623551+07	BBRI	2046.7166218542793	72846	BBCA	BMRI	HAKI
2026-07-08 00:35:20.623551+07	BBRI	2043.7661284444246	69069	BBCA	BMRI	HAKI
2026-07-07 23:46:20.623551+07	BBRI	2049.5851772468386	49254	BBCA	BMRI	HAKA
2026-07-07 22:32:20.623551+07	BBRI	2045.4511443100375	46954	BBCA	BMRI	HAKI
2026-07-07 22:01:20.623551+07	BBRI	2043.5106143151431	35099	BBCA	BMRI	HAKI
2026-07-07 20:49:20.623551+07	BBRI	2044.1892726413164	45897	BBCA	BMRI	HAKA
2026-07-07 19:41:20.623551+07	BBRI	2040.3246241807758	51615	BBCA	BMRI	HAKI
2026-07-07 18:27:20.623551+07	BBRI	2038.7220498872025	33350	BBCA	BMRI	HAKI
2026-07-07 17:48:20.623551+07	BBRI	2038.9675802432416	51199	BBCA	BMRI	HAKA
2026-07-07 16:45:20.623551+07	BBRI	2036.384180010971	54076	BBCA	BMRI	HAKI
2026-07-07 15:42:20.623551+07	BBRI	2039.2589111462719	57691	BBCA	BMRI	HAKA
2026-07-09 06:55:20.623551+07	BBRI	2032.7017929792648	55215	BBCA	BMRI	HAKI
2026-07-09 05:07:20.623551+07	BBRI	2031.5093155229117	60391	BBCA	BMRI	HAKI
2026-07-09 04:53:20.623551+07	BBRI	2029.7151150678937	66553	BBCA	BMRI	HAKI
2026-07-09 03:10:20.623551+07	BBRI	2027.6822967203818	39743	BBCA	BMRI	HAKI
2026-07-09 02:29:20.623551+07	BBRI	2026.2700949755867	63690	BBCA	BMRI	HAKI
2026-07-09 01:53:20.623551+07	BBRI	2027.391007581511	37759	BBCA	BMRI	HAKA
2026-07-09 00:31:20.623551+07	BBRI	2028.2867125298526	45210	BBCA	BMRI	HAKA
2026-07-09 00:02:20.623551+07	BBRI	2030.3629144360557	42415	BBCA	BMRI	HAKA
2026-07-08 22:52:20.623551+07	BBRI	2024.8931255489995	46396	BBCA	BMRI	HAKI
2026-07-08 21:18:20.623551+07	BBRI	2022.5521612404764	62205	BBCA	BMRI	HAKI
2026-07-08 20:15:20.623551+07	BBRI	2026.0064090583749	29328	BBCA	BMRI	HAKA
2026-07-08 20:04:20.623551+07	BBRI	2027.8649955648584	54485	BBCA	BMRI	HAKA
2026-07-08 18:37:20.623551+07	BBRI	2028.6318793894532	31891	BBCA	BMRI	HAKA
2026-07-08 17:40:20.623551+07	BBRI	2029.9032841054236	44500	BBCA	BMRI	HAKA
2026-07-08 16:33:20.623551+07	BBRI	2031.0527210953646	60889	BBCA	BMRI	HAKA
2026-07-08 15:20:20.623551+07	BBRI	2028.6464546341783	36882	BBCA	BMRI	HAKI
2026-07-02 10:56:21.902439+07	BMRI	5759.2915627611865	60672	BBCA	BMRI	HAKI
2026-07-02 09:41:21.902439+07	BMRI	5742.421957188384	49796	BBCA	BMRI	HAKI
2026-07-02 08:13:21.902439+07	BMRI	5739.550520173855	62676	BBCA	BMRI	HAKI
2026-07-02 07:27:21.902439+07	BMRI	5722.763377152258	60091	BBCA	BMRI	HAKI
2026-07-02 07:03:21.902439+07	BMRI	5720.640424196473	45447	BBCA	BMRI	HAKI
2026-07-03 10:23:21.902439+07	BMRI	5790.123811338896	61052	BBCA	BMRI	HAKA
2026-07-03 09:29:21.902439+07	BMRI	5789.3650501693655	64656	BBCA	BMRI	HAKI
2026-07-03 08:12:21.902439+07	BMRI	5759.774592329705	45828	BBCA	BMRI	HAKI
2026-07-03 07:47:21.902439+07	BMRI	5751.850222718181	60100	BBCA	BMRI	HAKI
2026-07-03 07:05:21.902439+07	BMRI	5759.1802804540675	43581	BBCA	BMRI	HAKA
2026-07-03 06:03:21.902439+07	BMRI	5764.530295917459	53850	BBCA	BMRI	HAKA
2026-07-03 04:36:21.902439+07	BMRI	5761.361343830402	42644	BBCA	BMRI	HAKI
2026-07-03 03:12:21.902439+07	BMRI	5762.306985116144	44989	BBCA	BMRI	HAKA
2026-07-03 02:22:21.902439+07	BMRI	5753.551903368425	45540	BBCA	BMRI	HAKI
2026-07-03 01:52:21.902439+07	BMRI	5749.724567631856	34388	BBCA	BMRI	HAKI
2026-07-03 00:31:21.902439+07	BMRI	5728.66307734299	49815	BBCA	BMRI	HAKI
2026-07-02 23:40:21.902439+07	BMRI	5722.3447223410385	44871	BBCA	BMRI	HAKI
2026-07-02 22:39:21.902439+07	BMRI	5712.757073007113	43424	BBCA	BMRI	HAKI
2026-07-02 22:00:21.902439+07	BMRI	5707.759540567386	46235	BBCA	BMRI	HAKI
2026-07-02 21:03:21.902439+07	BMRI	5718.1730714315445	52275	BBCA	BMRI	HAKA
2026-07-02 19:15:21.902439+07	BMRI	5723.0301866563705	58433	BBCA	BMRI	HAKA
2026-07-02 18:16:21.902439+07	BMRI	5720.250406397538	57044	BBCA	BMRI	HAKI
2026-07-02 17:07:21.902439+07	BMRI	5718.940453056614	48907	BBCA	BMRI	HAKI
2026-07-02 16:28:21.902439+07	BMRI	5734.12069163894	51952	BBCA	BMRI	HAKA
2026-07-02 15:29:21.902439+07	BMRI	5739.6802075421265	57155	BBCA	BMRI	HAKA
2026-07-04 11:04:21.902439+07	BMRI	5725.841713819389	66740	BBCA	BMRI	HAKI
2026-07-04 09:17:21.902439+07	BMRI	5732.426825518778	37342	BBCA	BMRI	HAKA
2026-07-04 08:09:21.902439+07	BMRI	5740.222239678482	52677	BBCA	BMRI	HAKA
2026-07-04 07:12:21.902439+07	BMRI	5719.558476084355	47521	BBCA	BMRI	HAKI
2026-07-04 06:24:21.902439+07	BMRI	5706.835654117947	47813	BBCA	BMRI	HAKI
2026-07-04 05:49:21.902439+07	BMRI	5670.6474299548145	31202	BBCA	BMRI	HAKI
2026-07-04 04:38:21.902439+07	BMRI	5659.237041530702	43169	BBCA	BMRI	HAKI
2026-07-04 03:06:21.902439+07	BMRI	5664.018565899295	53723	BBCA	BMRI	HAKA
2026-07-04 02:36:21.902439+07	BMRI	5667.601890467119	64389	BBCA	BMRI	HAKA
2026-07-04 02:02:21.902439+07	BMRI	5693.400733662259	53402	BBCA	BMRI	HAKA
2026-07-04 00:59:21.902439+07	BMRI	5686.63576629487	38994	BBCA	BMRI	HAKI
2026-07-03 23:29:21.902439+07	BMRI	5696.898950602567	46560	BBCA	BMRI	HAKA
2026-07-03 22:06:21.902439+07	BMRI	5710.850883783703	52768	BBCA	BMRI	HAKA
2026-07-03 21:43:21.902439+07	BMRI	5714.437670440567	54947	BBCA	BMRI	HAKA
2026-07-03 20:51:21.902439+07	BMRI	5709.610678170704	48729	BBCA	BMRI	HAKI
2026-07-03 19:23:21.902439+07	BMRI	5702.841391940323	56812	BBCA	BMRI	HAKI
2026-07-03 18:54:21.902439+07	BMRI	5706.809811777388	52780	BBCA	BMRI	HAKA
2026-07-03 17:08:21.902439+07	BMRI	5725.429976724042	54740	BBCA	BMRI	HAKA
2026-07-03 16:23:21.902439+07	BMRI	5729.585860043769	66907	BBCA	BMRI	HAKA
2026-07-03 15:58:21.902439+07	BMRI	5722.281532761529	43942	BBCA	BMRI	HAKI
2026-07-05 10:44:21.902439+07	BMRI	5727.715582945343	44137	BBCA	BMRI	HAKA
2026-07-05 09:16:21.902439+07	BMRI	5743.253127121961	54797	BBCA	BMRI	HAKA
2026-07-05 08:20:21.902439+07	BMRI	5737.685170031932	46124	BBCA	BMRI	HAKI
2026-07-05 07:14:21.902439+07	BMRI	5737.884521195252	43614	BBCA	BMRI	HAKA
2026-07-05 06:20:21.902439+07	BMRI	5728.4798146875455	58807	BBCA	BMRI	HAKI
2026-07-05 05:35:21.902439+07	BMRI	5723.514198569495	63538	BBCA	BMRI	HAKI
2026-07-05 04:41:21.902439+07	BMRI	5702.294481849708	43302	BBCA	BMRI	HAKI
2026-07-05 03:58:21.902439+07	BMRI	5714.172335547775	46103	BBCA	BMRI	HAKA
2026-07-05 02:40:21.902439+07	BMRI	5726.866370899127	69252	BBCA	BMRI	HAKA
2026-07-05 01:06:21.902439+07	BMRI	5740.464399458442	42308	BBCA	BMRI	HAKA
2026-07-05 00:37:21.902439+07	BMRI	5741.53132728912	49956	BBCA	BMRI	HAKA
2026-07-04 23:57:21.902439+07	BMRI	5746.862967812597	46124	BBCA	BMRI	HAKA
2026-07-04 22:28:21.902439+07	BMRI	5743.6160359452115	58772	BBCA	BMRI	HAKI
2026-07-04 21:36:21.902439+07	BMRI	5742.418382795065	51178	BBCA	BMRI	HAKI
2026-07-04 20:21:21.902439+07	BMRI	5745.884960547774	50266	BBCA	BMRI	HAKA
2026-07-04 19:43:21.902439+07	BMRI	5751.967257320548	35562	BBCA	BMRI	HAKA
2026-07-04 18:38:21.902439+07	BMRI	5747.68372139042	52906	BBCA	BMRI	HAKI
2026-07-04 17:24:21.902439+07	BMRI	5761.447244943611	36130	BBCA	BMRI	HAKA
2026-07-04 16:53:21.902439+07	BMRI	5748.802262120346	35391	BBCA	BMRI	HAKI
2026-07-04 15:25:21.902439+07	BMRI	5750.726022325658	52141	BBCA	BMRI	HAKA
2026-07-06 10:32:21.902439+07	BMRI	5753.586902650892	40461	BBCA	BMRI	HAKA
2026-07-06 09:12:21.902439+07	BMRI	5747.288828313822	48378	BBCA	BMRI	HAKI
2026-07-06 08:15:21.902439+07	BMRI	5746.323784444406	44166	BBCA	BMRI	HAKI
2026-07-06 07:50:21.902439+07	BMRI	5746.064926463911	42855	BBCA	BMRI	HAKI
2026-07-06 06:24:21.902439+07	BMRI	5765.374774981632	70113	BBCA	BMRI	HAKA
2026-07-06 05:51:21.902439+07	BMRI	5771.650107550046	59437	BBCA	BMRI	HAKA
2026-07-06 04:56:21.902439+07	BMRI	5789.697580517121	48505	BBCA	BMRI	HAKA
2026-07-06 03:52:21.902439+07	BMRI	5787.269591252139	52749	BBCA	BMRI	HAKI
2026-07-06 02:09:21.902439+07	BMRI	5780.606682692827	70098	BBCA	BMRI	HAKI
2026-07-06 01:22:21.902439+07	BMRI	5799.178064250581	43317	BBCA	BMRI	HAKA
2026-07-06 00:49:21.902439+07	BMRI	5806.685017367976	47945	BBCA	BMRI	HAKA
2026-07-05 23:49:21.902439+07	BMRI	5815.696922824616	58141	BBCA	BMRI	HAKA
2026-07-05 22:28:21.902439+07	BMRI	5832.114325134806	49472	BBCA	BMRI	HAKA
2026-07-05 21:21:21.902439+07	BMRI	5818.491284038932	62139	BBCA	BMRI	HAKI
2026-07-05 20:11:21.902439+07	BMRI	5822.80487307291	48247	BBCA	BMRI	HAKA
2026-07-05 19:38:21.902439+07	BMRI	5823.464223812599	56057	BBCA	BMRI	HAKA
2026-07-05 18:48:21.902439+07	BMRI	5828.741426389712	61331	BBCA	BMRI	HAKA
2026-07-05 17:48:21.902439+07	BMRI	5848.168601393145	64484	BBCA	BMRI	HAKA
2026-07-05 16:12:21.902439+07	BMRI	5866.827512168676	37451	BBCA	BMRI	HAKA
2026-07-05 15:43:21.902439+07	BMRI	5876.656259235364	61689	BBCA	BMRI	HAKA
2026-07-07 10:37:21.902439+07	BMRI	5869.779847803885	50397	BBCA	BMRI	HAKI
2026-07-07 09:41:21.902439+07	BMRI	5892.372461140109	41113	BBCA	BMRI	HAKA
2026-07-07 08:52:21.902439+07	BMRI	5886.747291788091	51292	BBCA	BMRI	HAKI
2026-07-07 07:17:21.902439+07	BMRI	5885.680165551935	43566	BBCA	BMRI	HAKI
2026-07-07 06:37:21.902439+07	BMRI	5921.227204700688	52013	BBCA	BMRI	HAKA
2026-07-07 05:38:21.902439+07	BMRI	5938.012799258149	46652	BBCA	BMRI	HAKA
2026-07-07 04:15:21.902439+07	BMRI	5948.601717276812	50339	BBCA	BMRI	HAKA
2026-07-07 03:52:21.902439+07	BMRI	5939.0680761516405	28207	BBCA	BMRI	HAKI
2026-07-07 02:38:21.902439+07	BMRI	5931.159070206265	32016	BBCA	BMRI	HAKI
2026-07-07 01:16:21.902439+07	BMRI	5929.856572853067	50671	BBCA	BMRI	HAKI
2026-07-07 00:54:21.902439+07	BMRI	5934.997190692259	45638	BBCA	BMRI	HAKA
2026-07-06 23:34:21.902439+07	BMRI	5949.119277283823	51404	BBCA	BMRI	HAKA
2026-07-06 22:30:21.902439+07	BMRI	5973.771601548785	47940	BBCA	BMRI	HAKA
2026-07-06 21:34:21.902439+07	BMRI	5972.024135204117	48875	BBCA	BMRI	HAKI
2026-07-06 20:08:21.902439+07	BMRI	5958.031013662023	69864	BBCA	BMRI	HAKI
2026-07-06 19:24:21.902439+07	BMRI	5946.03243366969	32307	BBCA	BMRI	HAKI
2026-07-06 18:14:21.902439+07	BMRI	5937.27985558873	39700	BBCA	BMRI	HAKI
2026-07-06 17:18:21.902439+07	BMRI	5932.796948129971	45884	BBCA	BMRI	HAKI
2026-07-06 16:36:21.902439+07	BMRI	5958.016498914271	45052	BBCA	BMRI	HAKA
2026-07-06 15:29:21.902439+07	BMRI	5957.7362655548495	38085	BBCA	BMRI	HAKI
2026-07-08 10:25:21.902439+07	BMRI	5978.403671236626	52095	BBCA	BMRI	HAKA
2026-07-08 09:58:21.902439+07	BMRI	5962.654335413759	56161	BBCA	BMRI	HAKI
2026-07-08 08:31:21.902439+07	BMRI	5952.545400903828	70920	BBCA	BMRI	HAKI
2026-07-08 07:48:21.902439+07	BMRI	5965.082652829472	55188	BBCA	BMRI	HAKA
2026-07-08 07:03:21.902439+07	BMRI	5965.290964191139	51495	BBCA	BMRI	HAKA
2026-07-08 05:55:21.902439+07	BMRI	5953.854290805428	53380	BBCA	BMRI	HAKI
2026-07-08 04:52:21.902439+07	BMRI	5953.174353338959	54282	BBCA	BMRI	HAKI
2026-07-08 03:08:21.902439+07	BMRI	5956.412878372262	36756	BBCA	BMRI	HAKA
2026-07-08 02:36:21.902439+07	BMRI	5952.061576013615	46679	BBCA	BMRI	HAKI
2026-07-08 01:53:21.902439+07	BMRI	5946.910183874143	64951	BBCA	BMRI	HAKI
2026-07-08 00:26:21.902439+07	BMRI	5935.500150522401	60559	BBCA	BMRI	HAKI
2026-07-07 23:31:21.902439+07	BMRI	5945.653038198865	40461	BBCA	BMRI	HAKA
2026-07-07 22:13:21.902439+07	BMRI	5946.699539198074	40236	BBCA	BMRI	HAKA
2026-07-07 21:11:21.902439+07	BMRI	5947.691570165264	36462	BBCA	BMRI	HAKA
2026-07-07 20:13:21.902439+07	BMRI	5921.79346943372	38247	BBCA	BMRI	HAKI
2026-07-07 19:29:21.902439+07	BMRI	5945.524389100434	63118	BBCA	BMRI	HAKA
2026-07-07 18:49:21.902439+07	BMRI	5949.081755451519	58830	BBCA	BMRI	HAKA
2026-07-07 17:33:21.902439+07	BMRI	5932.340615163902	48429	BBCA	BMRI	HAKI
2026-07-07 16:40:21.902439+07	BMRI	5935.90435728296	42641	BBCA	BMRI	HAKA
2026-07-07 16:02:21.902439+07	BMRI	5937.463319217213	41733	BBCA	BMRI	HAKA
2026-07-09 06:27:21.902439+07	BMRI	5927.903504841936	47524	BBCA	BMRI	HAKI
2026-07-09 05:09:21.902439+07	BMRI	5940.453866511292	48899	BBCA	BMRI	HAKA
2026-07-09 04:42:21.902439+07	BMRI	5951.987157220371	46505	BBCA	BMRI	HAKA
2026-07-09 03:59:21.902439+07	BMRI	5955.268784518435	32071	BBCA	BMRI	HAKA
2026-07-09 02:12:21.902439+07	BMRI	5950.393987060616	23057	BBCA	BMRI	HAKI
2026-07-09 01:51:21.902439+07	BMRI	5953.605505242469	46746	BBCA	BMRI	HAKA
2026-07-09 00:22:21.902439+07	BMRI	5943.2876553884125	73936	BBCA	BMRI	HAKI
2026-07-08 23:52:21.902439+07	BMRI	5936.675787750693	50441	BBCA	BMRI	HAKI
2026-07-08 22:26:21.902439+07	BMRI	5958.626245524531	49861	BBCA	BMRI	HAKA
2026-07-08 21:32:21.902439+07	BMRI	5940.935181889514	35589	BBCA	BMRI	HAKI
2026-07-08 20:09:21.902439+07	BMRI	5933.236998314071	40644	BBCA	BMRI	HAKI
2026-07-08 19:27:21.902439+07	BMRI	5936.022101596024	48964	BBCA	BMRI	HAKA
2026-07-08 18:44:21.902439+07	BMRI	5932.82541237526	62859	BBCA	BMRI	HAKI
2026-07-08 17:27:21.902439+07	BMRI	5929.619141353848	49300	BBCA	BMRI	HAKI
2026-07-08 16:36:21.902439+07	BMRI	5951.078173099667	55739	BBCA	BMRI	HAKA
2026-07-08 15:59:21.902439+07	BMRI	5964.114359126766	46640	BBCA	BMRI	HAKA
2026-07-02 10:48:23.294413+07	TLKM	1512.262048466663	57382	BBCA	BMRI	HAKA
2026-07-02 09:12:23.294413+07	TLKM	1516.5880505590303	43940	BBCA	BMRI	HAKA
2026-07-02 08:08:23.294413+07	TLKM	1516.8418921876064	80745	BBCA	BMRI	HAKA
2026-07-02 07:27:23.294413+07	TLKM	1512.9310478810212	43265	BBCA	BMRI	HAKI
2026-07-03 10:33:23.294413+07	TLKM	1516.461965869301	45989	BBCA	BMRI	HAKA
2026-07-03 09:33:23.294413+07	TLKM	1515.549950553197	48232	BBCA	BMRI	HAKI
2026-07-03 08:24:23.294413+07	TLKM	1514.575976026426	47197	BBCA	BMRI	HAKI
2026-07-03 07:18:23.294413+07	TLKM	1510.8093662246883	56073	BBCA	BMRI	HAKI
2026-07-03 06:06:23.294413+07	TLKM	1509.0979276983287	76461	BBCA	BMRI	HAKI
2026-07-03 05:11:23.294413+07	TLKM	1505.3351558231925	29590	BBCA	BMRI	HAKI
2026-07-03 04:45:23.294413+07	TLKM	1505.838843045294	34491	BBCA	BMRI	HAKA
2026-07-03 03:48:23.294413+07	TLKM	1504.7959120361431	52105	BBCA	BMRI	HAKI
2026-07-03 02:15:23.294413+07	TLKM	1505.9913370849774	47481	BBCA	BMRI	HAKA
2026-07-03 01:59:23.294413+07	TLKM	1509.0504498112764	43257	BBCA	BMRI	HAKA
2026-07-03 00:30:23.294413+07	TLKM	1509.2676455558449	57572	BBCA	BMRI	HAKA
2026-07-02 23:44:23.294413+07	TLKM	1506.8432099360653	58493	BBCA	BMRI	HAKI
2026-07-02 22:34:23.294413+07	TLKM	1510.5893176314062	46944	BBCA	BMRI	HAKA
2026-07-02 21:55:23.294413+07	TLKM	1513.629172356017	50169	BBCA	BMRI	HAKA
2026-07-02 20:38:23.294413+07	TLKM	1508.494896641979	48532	BBCA	BMRI	HAKI
2026-07-02 19:39:23.294413+07	TLKM	1507.6315322126889	56904	BBCA	BMRI	HAKI
2026-07-02 18:32:23.294413+07	TLKM	1506.2416284697692	58441	BBCA	BMRI	HAKI
2026-07-02 17:41:23.294413+07	TLKM	1508.6408130669379	50574	BBCA	BMRI	HAKA
2026-07-02 16:56:23.294413+07	TLKM	1507.1596303251345	53587	BBCA	BMRI	HAKI
2026-07-02 15:47:23.294413+07	TLKM	1504.5716342650594	39883	BBCA	BMRI	HAKI
2026-07-04 10:17:23.294413+07	TLKM	1498.6533548805037	51091	BBCA	BMRI	HAKI
2026-07-04 10:02:23.294413+07	TLKM	1498.524379586709	61623	BBCA	BMRI	HAKI
2026-07-04 08:50:23.294413+07	TLKM	1498.3020116488997	55129	BBCA	BMRI	HAKI
2026-07-04 07:43:23.294413+07	TLKM	1499.4270921684267	66039	BBCA	BMRI	HAKA
2026-07-04 06:39:23.294413+07	TLKM	1496.0362802072336	53917	BBCA	BMRI	HAKI
2026-07-04 05:58:23.294413+07	TLKM	1494.2535999623985	31353	BBCA	BMRI	HAKI
2026-07-04 04:52:23.294413+07	TLKM	1494.0745007974303	62334	BBCA	BMRI	HAKI
2026-07-04 03:57:23.294413+07	TLKM	1494.4330007533044	44004	BBCA	BMRI	HAKA
2026-07-04 02:30:23.294413+07	TLKM	1490.9300622474882	61137	BBCA	BMRI	HAKI
2026-07-04 01:14:23.294413+07	TLKM	1492.2630995366399	44843	BBCA	BMRI	HAKA
2026-07-04 00:49:23.294413+07	TLKM	1496.9757478928211	45511	BBCA	BMRI	HAKA
2026-07-03 23:22:23.294413+07	TLKM	1495.9939061072841	28849	BBCA	BMRI	HAKI
2026-07-03 22:18:23.294413+07	TLKM	1492.7715871827322	45665	BBCA	BMRI	HAKI
2026-07-03 21:06:23.294413+07	TLKM	1499.6089591257073	45499	BBCA	BMRI	HAKA
2026-07-03 20:59:23.294413+07	TLKM	1501.939735926661	51144	BBCA	BMRI	HAKA
2026-07-03 19:11:23.294413+07	TLKM	1502.2562019533639	49494	BBCA	BMRI	HAKA
2026-07-03 18:49:23.294413+07	TLKM	1507.13970646813	45731	BBCA	BMRI	HAKA
2026-07-03 17:29:23.294413+07	TLKM	1504.806535101396	47473	BBCA	BMRI	HAKI
2026-07-03 16:49:23.294413+07	TLKM	1501.4676925858978	53186	BBCA	BMRI	HAKI
2026-07-03 15:57:23.294413+07	TLKM	1501.9564277061206	38103	BBCA	BMRI	HAKA
2026-07-05 10:52:23.294413+07	TLKM	1504.5613944156896	47358	BBCA	BMRI	HAKA
2026-07-05 09:10:23.294413+07	TLKM	1505.0749304261954	58022	BBCA	BMRI	HAKA
2026-07-05 08:42:23.294413+07	TLKM	1504.8950806196162	72658	BBCA	BMRI	HAKI
2026-07-05 07:50:23.294413+07	TLKM	1504.7866895823165	48990	BBCA	BMRI	HAKI
2026-07-05 06:57:23.294413+07	TLKM	1500.8836150225102	60155	BBCA	BMRI	HAKI
2026-07-05 06:01:23.294413+07	TLKM	1500.6507698755213	63070	BBCA	BMRI	HAKI
2026-07-05 04:33:23.294413+07	TLKM	1497.6792587093137	45428	BBCA	BMRI	HAKI
2026-07-05 03:14:23.294413+07	TLKM	1497.9097638173132	53147	BBCA	BMRI	HAKA
2026-07-05 02:50:23.294413+07	TLKM	1497.7511393536263	48000	BBCA	BMRI	HAKI
2026-07-05 01:15:23.294413+07	TLKM	1497.5061831932444	49188	BBCA	BMRI	HAKI
2026-07-05 00:35:23.294413+07	TLKM	1498.9679548019656	58502	BBCA	BMRI	HAKA
2026-07-04 23:42:23.294413+07	TLKM	1498.1069546291635	51021	BBCA	BMRI	HAKI
2026-07-04 22:41:23.294413+07	TLKM	1498.4535987015377	66222	BBCA	BMRI	HAKA
2026-07-04 21:33:23.294413+07	TLKM	1499.6561226221827	57227	BBCA	BMRI	HAKA
2026-07-04 20:07:23.294413+07	TLKM	1500.7422960669346	64483	BBCA	BMRI	HAKA
2026-07-04 19:16:23.294413+07	TLKM	1499.8850468187206	45001	BBCA	BMRI	HAKI
2026-07-04 18:29:23.294413+07	TLKM	1495.7668408617585	74446	BBCA	BMRI	HAKI
2026-07-04 17:32:23.294413+07	TLKM	1493.6881879711866	35561	BBCA	BMRI	HAKI
2026-07-04 16:58:23.294413+07	TLKM	1493.2515733959704	47770	BBCA	BMRI	HAKI
2026-07-04 15:07:23.294413+07	TLKM	1491.8601011883225	54275	BBCA	BMRI	HAKI
2026-07-06 10:09:23.294413+07	TLKM	1491.0568908043715	42321	BBCA	BMRI	HAKI
2026-07-06 09:43:23.294413+07	TLKM	1488.314064988411	66511	BBCA	BMRI	HAKI
2026-07-06 08:56:23.294413+07	TLKM	1491.4351697047366	52435	BBCA	BMRI	HAKA
2026-07-06 07:35:23.294413+07	TLKM	1495.4211836584211	51417	BBCA	BMRI	HAKA
2026-07-06 06:43:23.294413+07	TLKM	1498.4589546709467	71968	BBCA	BMRI	HAKA
2026-07-06 05:08:23.294413+07	TLKM	1493.4223603201199	49691	BBCA	BMRI	HAKI
2026-07-06 05:04:23.294413+07	TLKM	1495.095601775563	48240	BBCA	BMRI	HAKA
2026-07-06 03:16:23.294413+07	TLKM	1491.9759630550639	49079	BBCA	BMRI	HAKI
2026-07-06 02:06:23.294413+07	TLKM	1490.9568580155533	63236	BBCA	BMRI	HAKI
2026-07-06 01:15:23.294413+07	TLKM	1492.283445791303	37136	BBCA	BMRI	HAKA
2026-07-06 00:38:23.294413+07	TLKM	1491.8429072871718	40545	BBCA	BMRI	HAKI
2026-07-06 00:04:23.294413+07	TLKM	1491.4461385077877	52802	BBCA	BMRI	HAKI
2026-07-05 22:45:23.294413+07	TLKM	1495.1174814918168	33354	BBCA	BMRI	HAKA
2026-07-05 21:36:23.294413+07	TLKM	1501.1658532523315	76477	BBCA	BMRI	HAKA
2026-07-05 20:18:23.294413+07	TLKM	1501.0770604197423	49620	BBCA	BMRI	HAKI
2026-07-05 19:52:23.294413+07	TLKM	1503.2972976049955	46794	BBCA	BMRI	HAKA
2026-07-05 18:55:23.294413+07	TLKM	1503.7711053532953	49725	BBCA	BMRI	HAKA
2026-07-05 17:16:23.294413+07	TLKM	1506.84873131995	48534	BBCA	BMRI	HAKA
2026-07-05 16:21:23.294413+07	TLKM	1500.917392862133	60374	BBCA	BMRI	HAKI
2026-07-05 15:36:23.294413+07	TLKM	1500.364678158427	60842	BBCA	BMRI	HAKI
2026-07-07 11:02:23.294413+07	TLKM	1497.2886736253467	55726	BBCA	BMRI	HAKI
2026-07-07 09:35:23.294413+07	TLKM	1496.8465821291652	70459	BBCA	BMRI	HAKI
2026-07-07 08:58:23.294413+07	TLKM	1491.5291269093289	54834	BBCA	BMRI	HAKI
2026-07-07 07:14:23.294413+07	TLKM	1491.2535202696838	40336	BBCA	BMRI	HAKI
2026-07-07 06:16:23.294413+07	TLKM	1492.1747319395233	49462	BBCA	BMRI	HAKA
2026-07-07 05:07:23.294413+07	TLKM	1487.4943526363998	38556	BBCA	BMRI	HAKI
2026-07-07 05:03:23.294413+07	TLKM	1487.1050969372027	48182	BBCA	BMRI	HAKI
2026-07-07 03:25:23.294413+07	TLKM	1485.844182770805	53680	BBCA	BMRI	HAKI
2026-07-07 02:26:23.294413+07	TLKM	1483.4536091342045	58442	BBCA	BMRI	HAKI
2026-07-07 01:32:23.294413+07	TLKM	1486.532708977257	59161	BBCA	BMRI	HAKA
2026-07-07 00:20:23.294413+07	TLKM	1480.6320036535906	36848	BBCA	BMRI	HAKI
2026-07-06 23:07:23.294413+07	TLKM	1482.174902034238	53459	BBCA	BMRI	HAKA
2026-07-06 22:38:23.294413+07	TLKM	1486.8984810253753	48894	BBCA	BMRI	HAKA
2026-07-06 21:35:23.294413+07	TLKM	1486.5860586070562	57805	BBCA	BMRI	HAKI
2026-07-06 20:34:23.294413+07	TLKM	1487.3955519808544	47319	BBCA	BMRI	HAKA
2026-07-06 19:14:23.294413+07	TLKM	1489.4891061010637	62713	BBCA	BMRI	HAKA
2026-07-06 18:55:23.294413+07	TLKM	1491.9168866160435	59528	BBCA	BMRI	HAKA
2026-07-06 18:03:23.294413+07	TLKM	1491.771185326852	71679	BBCA	BMRI	HAKI
2026-07-06 16:12:23.294413+07	TLKM	1493.361355192631	40168	BBCA	BMRI	HAKA
2026-07-06 15:47:23.294413+07	TLKM	1489.7361699511011	61940	BBCA	BMRI	HAKI
2026-07-08 10:27:23.294413+07	TLKM	1490.1857652709255	66531	BBCA	BMRI	HAKA
2026-07-08 10:02:23.294413+07	TLKM	1488.3196181915828	56200	BBCA	BMRI	HAKI
2026-07-08 08:48:23.294413+07	TLKM	1486.348327056896	43669	BBCA	BMRI	HAKI
2026-07-08 07:14:23.294413+07	TLKM	1487.834482862163	40470	BBCA	BMRI	HAKA
2026-07-08 07:04:23.294413+07	TLKM	1484.1636616646642	49485	BBCA	BMRI	HAKI
2026-07-08 05:57:23.294413+07	TLKM	1483.8297686220344	59726	BBCA	BMRI	HAKI
2026-07-08 04:22:23.294413+07	TLKM	1488.0430325645748	31319	BBCA	BMRI	HAKA
2026-07-08 04:05:23.294413+07	TLKM	1485.849118141449	49942	BBCA	BMRI	HAKI
2026-07-08 02:39:23.294413+07	TLKM	1487.2068633802096	35463	BBCA	BMRI	HAKA
2026-07-08 01:48:23.294413+07	TLKM	1490.5400694592909	49948	BBCA	BMRI	HAKA
2026-07-08 00:50:23.294413+07	TLKM	1490.0285078615532	59881	BBCA	BMRI	HAKI
2026-07-08 00:04:23.294413+07	TLKM	1488.1443353694224	56134	BBCA	BMRI	HAKI
2026-07-07 22:17:23.294413+07	TLKM	1487.140298226443	49064	BBCA	BMRI	HAKI
2026-07-07 21:47:23.294413+07	TLKM	1488.7964064750918	25572	BBCA	BMRI	HAKA
2026-07-07 20:55:23.294413+07	TLKM	1485.2669301344774	56258	BBCA	BMRI	HAKI
2026-07-07 19:44:23.294413+07	TLKM	1488.4938022722426	55928	BBCA	BMRI	HAKA
2026-07-07 18:41:23.294413+07	TLKM	1483.0810476665163	58109	BBCA	BMRI	HAKI
2026-07-07 17:45:23.294413+07	TLKM	1481.106181134843	47798	BBCA	BMRI	HAKI
2026-07-07 16:56:23.294413+07	TLKM	1474.89729159376	41288	BBCA	BMRI	HAKI
2026-07-07 15:35:23.294413+07	TLKM	1473.3230156505936	49460	BBCA	BMRI	HAKI
2026-07-09 05:38:23.294413+07	TLKM	1470.8733823948392	60897	BBCA	BMRI	HAKA
2026-07-09 04:31:23.294413+07	TLKM	1469.465190966849	26059	BBCA	BMRI	HAKI
2026-07-09 03:57:23.294413+07	TLKM	1468.479055853642	50661	BBCA	BMRI	HAKI
2026-07-09 02:50:23.294413+07	TLKM	1469.0906674810542	57204	BBCA	BMRI	HAKA
2026-07-09 01:34:23.294413+07	TLKM	1466.7952551513454	59868	BBCA	BMRI	HAKI
2026-07-09 00:41:23.294413+07	TLKM	1466.456084969164	53316	BBCA	BMRI	HAKI
2026-07-08 23:54:23.294413+07	TLKM	1464.8163855227806	57093	BBCA	BMRI	HAKI
2026-07-08 22:47:23.294413+07	TLKM	1462.5199838952592	48924	BBCA	BMRI	HAKI
2026-07-08 21:31:23.294413+07	TLKM	1460.36854423397	49205	BBCA	BMRI	HAKI
2026-07-08 21:03:23.294413+07	TLKM	1460.1189286612487	46887	BBCA	BMRI	HAKI
2026-07-08 19:40:23.294413+07	TLKM	1463.7747777281763	65911	BBCA	BMRI	HAKA
2026-07-08 18:19:23.294413+07	TLKM	1466.6129611543572	62313	BBCA	BMRI	HAKA
2026-07-08 17:31:23.294413+07	TLKM	1461.7894632107812	45538	BBCA	BMRI	HAKI
2026-07-08 16:43:23.294413+07	TLKM	1460.6376357575982	52328	BBCA	BMRI	HAKI
2026-07-08 15:54:23.294413+07	TLKM	1458.9786107421746	55973	BBCA	BMRI	HAKI
2026-07-02 10:36:24.552408+07	ASII	3986.329534348716	31412	BBCA	BMRI	HAKI
2026-07-02 09:23:24.552408+07	ASII	3987.7604517840527	47023	BBCA	BMRI	HAKA
2026-07-02 08:08:24.552408+07	ASII	3985.6027263741803	53161	BBCA	BMRI	HAKI
2026-07-02 07:53:24.552408+07	ASII	3989.5782837756933	57321	BBCA	BMRI	HAKA
2026-07-03 10:58:24.552408+07	ASII	3998.7473902094175	39416	BBCA	BMRI	HAKA
2026-07-03 09:23:24.552408+07	ASII	4006.9626149302894	55457	BBCA	BMRI	HAKA
2026-07-03 08:08:24.552408+07	ASII	4004.532311191512	47550	BBCA	BMRI	HAKI
2026-07-03 07:40:24.552408+07	ASII	4006.4530759493114	49083	BBCA	BMRI	HAKA
2026-07-03 06:56:24.552408+07	ASII	4025.3382968713936	57916	BBCA	BMRI	HAKA
2026-07-03 05:36:24.552408+07	ASII	4026.234747796924	52184	BBCA	BMRI	HAKA
2026-07-03 04:56:24.552408+07	ASII	4028.6329742964904	33697	BBCA	BMRI	HAKA
2026-07-03 03:58:24.552408+07	ASII	4027.8198778002684	48622	BBCA	BMRI	HAKI
2026-07-03 02:43:24.552408+07	ASII	4031.691292801896	51095	BBCA	BMRI	HAKA
2026-07-03 01:17:24.552408+07	ASII	4042.7624142949967	54188	BBCA	BMRI	HAKA
2026-07-03 00:32:24.552408+07	ASII	4043.6103037026437	50067	BBCA	BMRI	HAKA
2026-07-02 23:20:24.552408+07	ASII	4049.1933349981155	54840	BBCA	BMRI	HAKA
2026-07-02 22:13:24.552408+07	ASII	4049.635800689236	53973	BBCA	BMRI	HAKA
2026-07-02 21:25:24.552408+07	ASII	4052.531107997277	53608	BBCA	BMRI	HAKA
2026-07-02 21:04:24.552408+07	ASII	4055.7421409293092	53003	BBCA	BMRI	HAKA
2026-07-02 19:13:24.552408+07	ASII	4070.6114117109987	60769	BBCA	BMRI	HAKA
2026-07-02 18:11:24.552408+07	ASII	4075.2591525877233	62631	BBCA	BMRI	HAKA
2026-07-02 18:05:24.552408+07	ASII	4077.0583313568504	40820	BBCA	BMRI	HAKA
2026-07-02 16:23:24.552408+07	ASII	4077.1571237394583	48191	BBCA	BMRI	HAKA
2026-07-02 15:32:24.552408+07	ASII	4078.596477653717	52375	BBCA	BMRI	HAKA
2026-07-04 11:00:24.552408+07	ASII	4087.2666723320067	63226	BBCA	BMRI	HAKA
2026-07-04 09:17:24.552408+07	ASII	4087.9054819160624	48650	BBCA	BMRI	HAKA
2026-07-04 08:48:24.552408+07	ASII	4085.0287381765834	55531	BBCA	BMRI	HAKI
2026-07-04 08:01:24.552408+07	ASII	4096.4292796219725	39540	BBCA	BMRI	HAKA
2026-07-04 06:10:24.552408+07	ASII	4095.5575254742434	44489	BBCA	BMRI	HAKI
2026-07-04 05:11:24.552408+07	ASII	4095.1789258630015	69558	BBCA	BMRI	HAKI
2026-07-04 04:34:24.552408+07	ASII	4081.034714308545	54421	BBCA	BMRI	HAKI
2026-07-04 03:30:24.552408+07	ASII	4083.313166659813	43192	BBCA	BMRI	HAKA
2026-07-04 02:15:24.552408+07	ASII	4084.2792311750623	47895	BBCA	BMRI	HAKA
2026-07-04 01:28:24.552408+07	ASII	4076.9331352531394	64994	BBCA	BMRI	HAKI
2026-07-04 00:07:24.552408+07	ASII	4085.4400156234683	69924	BBCA	BMRI	HAKA
2026-07-03 23:35:24.552408+07	ASII	4084.4829910489248	48323	BBCA	BMRI	HAKI
2026-07-03 22:16:24.552408+07	ASII	4075.399155020221	57570	BBCA	BMRI	HAKI
2026-07-03 21:18:24.552408+07	ASII	4079.0845916500552	62513	BBCA	BMRI	HAKA
2026-07-03 20:17:24.552408+07	ASII	4071.9071595822616	64865	BBCA	BMRI	HAKI
2026-07-03 19:59:24.552408+07	ASII	4068.2456453363316	22102	BBCA	BMRI	HAKI
2026-07-03 18:24:24.552408+07	ASII	4085.803424909938	56084	BBCA	BMRI	HAKA
2026-07-03 17:35:24.552408+07	ASII	4097.294121985631	48251	BBCA	BMRI	HAKA
2026-07-03 16:32:24.552408+07	ASII	4082.95390344018	60095	BBCA	BMRI	HAKI
2026-07-03 15:28:24.552408+07	ASII	4083.427596645559	60810	BBCA	BMRI	HAKA
2026-07-05 10:42:24.552408+07	ASII	4075.505739359036	40881	BBCA	BMRI	HAKI
2026-07-05 09:57:24.552408+07	ASII	4084.2130793932056	55404	BBCA	BMRI	HAKA
2026-07-05 08:10:24.552408+07	ASII	4069.009242616087	25796	BBCA	BMRI	HAKI
2026-07-05 08:03:24.552408+07	ASII	4066.196485921385	27232	BBCA	BMRI	HAKI
2026-07-05 06:14:24.552408+07	ASII	4066.7200225981396	52081	BBCA	BMRI	HAKA
2026-07-05 05:14:24.552408+07	ASII	4064.04088741192	51494	BBCA	BMRI	HAKI
2026-07-05 04:43:24.552408+07	ASII	4060.344657800038	49849	BBCA	BMRI	HAKI
2026-07-05 03:13:24.552408+07	ASII	4047.374109290063	37165	BBCA	BMRI	HAKI
2026-07-05 02:42:24.552408+07	ASII	4039.2654484193336	58169	BBCA	BMRI	HAKI
2026-07-05 01:51:24.552408+07	ASII	4045.1119283465705	61343	BBCA	BMRI	HAKA
2026-07-05 00:36:24.552408+07	ASII	4043.3148966281087	56319	BBCA	BMRI	HAKI
2026-07-04 23:26:24.552408+07	ASII	4057.8648830685115	57714	BBCA	BMRI	HAKA
2026-07-04 22:48:24.552408+07	ASII	4049.521203451097	36812	BBCA	BMRI	HAKI
2026-07-04 21:08:24.552408+07	ASII	4032.8041860569824	42324	BBCA	BMRI	HAKI
2026-07-04 20:34:24.552408+07	ASII	4037.63323425117	49995	BBCA	BMRI	HAKA
2026-07-04 19:25:24.552408+07	ASII	4043.117659618228	43725	BBCA	BMRI	HAKA
2026-07-04 18:18:24.552408+07	ASII	4034.071271094348	46391	BBCA	BMRI	HAKI
2026-07-04 18:05:24.552408+07	ASII	4028.6361568294715	37145	BBCA	BMRI	HAKI
2026-07-04 16:23:24.552408+07	ASII	4011.622940203982	46173	BBCA	BMRI	HAKI
2026-07-04 16:01:24.552408+07	ASII	4011.7541213621935	39428	BBCA	BMRI	HAKA
2026-07-06 10:42:24.552408+07	ASII	4019.364821524814	63009	BBCA	BMRI	HAKA
2026-07-06 09:12:24.552408+07	ASII	4023.0920731948295	44778	BBCA	BMRI	HAKA
2026-07-06 08:37:24.552408+07	ASII	4025.8816852345417	55336	BBCA	BMRI	HAKA
2026-07-06 08:05:24.552408+07	ASII	4027.8308268684564	33287	BBCA	BMRI	HAKA
2026-07-06 06:16:24.552408+07	ASII	4030.4499169632195	44660	BBCA	BMRI	HAKA
2026-07-06 05:07:24.552408+07	ASII	4032.494928360778	38618	BBCA	BMRI	HAKA
2026-07-06 04:12:24.552408+07	ASII	4038.704106321865	52978	BBCA	BMRI	HAKA
2026-07-06 03:18:24.552408+07	ASII	4051.9423862282097	42495	BBCA	BMRI	HAKA
2026-07-06 02:40:24.552408+07	ASII	4042.5690811083973	47546	BBCA	BMRI	HAKI
2026-07-06 01:07:24.552408+07	ASII	4039.668871188859	57898	BBCA	BMRI	HAKI
2026-07-06 00:52:24.552408+07	ASII	4040.9698429033374	73610	BBCA	BMRI	HAKA
2026-07-05 23:12:24.552408+07	ASII	4038.651355506188	53608	BBCA	BMRI	HAKI
2026-07-05 22:11:24.552408+07	ASII	4044.5427688760474	54674	BBCA	BMRI	HAKA
2026-07-05 21:26:24.552408+07	ASII	4051.760716399969	52619	BBCA	BMRI	HAKA
2026-07-05 20:09:24.552408+07	ASII	4059.255614192702	41686	BBCA	BMRI	HAKA
2026-07-05 19:25:24.552408+07	ASII	4054.953102764626	62119	BBCA	BMRI	HAKI
2026-07-05 18:39:24.552408+07	ASII	4058.561656322948	49405	BBCA	BMRI	HAKA
2026-07-05 17:16:24.552408+07	ASII	4048.5281686079793	39011	BBCA	BMRI	HAKI
2026-07-05 16:28:24.552408+07	ASII	4057.330759948694	47460	BBCA	BMRI	HAKA
2026-07-05 15:37:24.552408+07	ASII	4055.6078735841584	54602	BBCA	BMRI	HAKI
2026-07-07 10:16:24.552408+07	ASII	4049.831426941421	45316	BBCA	BMRI	HAKI
2026-07-07 09:45:24.552408+07	ASII	4043.2924850531986	64041	BBCA	BMRI	HAKI
2026-07-07 08:54:24.552408+07	ASII	4065.878691504704	51657	BBCA	BMRI	HAKA
2026-07-07 07:15:24.552408+07	ASII	4063.4610339851224	46335	BBCA	BMRI	HAKI
2026-07-07 06:33:24.552408+07	ASII	4065.156546070822	49127	BBCA	BMRI	HAKA
2026-07-07 05:59:24.552408+07	ASII	4067.825687010664	62840	BBCA	BMRI	HAKA
2026-07-07 04:55:24.552408+07	ASII	4077.3629209884357	47505	BBCA	BMRI	HAKA
2026-07-07 04:01:24.552408+07	ASII	4078.25990877471	44056	BBCA	BMRI	HAKA
2026-07-07 02:51:24.552408+07	ASII	4062.1392584959626	48896	BBCA	BMRI	HAKI
2026-07-07 01:45:24.552408+07	ASII	4067.4993720023763	47654	BBCA	BMRI	HAKA
2026-07-07 00:27:24.552408+07	ASII	4065.0621522224264	45807	BBCA	BMRI	HAKI
2026-07-06 23:46:24.552408+07	ASII	4065.579258966567	45512	BBCA	BMRI	HAKA
2026-07-06 23:05:24.552408+07	ASII	4077.3197314437084	39237	BBCA	BMRI	HAKA
2026-07-06 21:44:24.552408+07	ASII	4085.1182615813104	33939	BBCA	BMRI	HAKA
2026-07-06 20:24:24.552408+07	ASII	4069.2979101915307	36964	BBCA	BMRI	HAKI
2026-07-06 19:40:24.552408+07	ASII	4077.110724443412	70122	BBCA	BMRI	HAKA
2026-07-06 18:32:24.552408+07	ASII	4077.104717440133	38719	BBCA	BMRI	HAKI
2026-07-06 17:15:24.552408+07	ASII	4074.9556413445735	52737	BBCA	BMRI	HAKI
2026-07-06 16:44:24.552408+07	ASII	4071.9925552551463	61364	BBCA	BMRI	HAKI
2026-07-06 15:13:24.552408+07	ASII	4071.0620390361273	49494	BBCA	BMRI	HAKI
2026-07-08 10:25:24.552408+07	ASII	4078.5619291009925	47744	BBCA	BMRI	HAKA
2026-07-08 09:24:24.552408+07	ASII	4080.9866570100426	47687	BBCA	BMRI	HAKA
2026-07-08 08:45:24.552408+07	ASII	4080.611576989571	43348	BBCA	BMRI	HAKI
2026-07-08 07:36:24.552408+07	ASII	4086.2354137452253	37375	BBCA	BMRI	HAKA
2026-07-08 06:17:24.552408+07	ASII	4076.94532823496	29836	BBCA	BMRI	HAKI
2026-07-08 05:09:24.552408+07	ASII	4079.5153290421854	37239	BBCA	BMRI	HAKA
2026-07-08 04:48:24.552408+07	ASII	4098.33867687764	52721	BBCA	BMRI	HAKA
2026-07-08 03:35:24.552408+07	ASII	4095.82411162204	48381	BBCA	BMRI	HAKI
2026-07-08 02:50:24.552408+07	ASII	4090.081815757232	63601	BBCA	BMRI	HAKI
2026-07-08 01:45:24.552408+07	ASII	4077.7914889298945	50709	BBCA	BMRI	HAKI
2026-07-08 00:06:24.552408+07	ASII	4078.969133131688	50900	BBCA	BMRI	HAKA
2026-07-07 23:59:24.552408+07	ASII	4070.6737605783815	44353	BBCA	BMRI	HAKI
2026-07-07 22:56:24.552408+07	ASII	4072.9801663437934	56182	BBCA	BMRI	HAKA
2026-07-07 21:11:24.552408+07	ASII	4073.7789740916987	59463	BBCA	BMRI	HAKA
2026-07-07 20:31:24.552408+07	ASII	4066.7453565228016	46541	BBCA	BMRI	HAKI
2026-07-07 19:21:24.552408+07	ASII	4063.8238234567575	26749	BBCA	BMRI	HAKI
2026-07-07 18:26:24.552408+07	ASII	4063.9594393918032	49078	BBCA	BMRI	HAKA
2026-07-07 18:05:24.552408+07	ASII	4059.2469829943293	44960	BBCA	BMRI	HAKI
2026-07-07 16:16:24.552408+07	ASII	4057.908867052279	41245	BBCA	BMRI	HAKI
2026-07-07 15:35:24.552408+07	ASII	4062.4652980344054	34744	BBCA	BMRI	HAKA
2026-07-09 06:17:24.552408+07	ASII	4068.6194611169026	53534	BBCA	BMRI	HAKI
2026-07-09 05:41:24.552408+07	ASII	4072.304054101097	50004	BBCA	BMRI	HAKA
2026-07-09 04:32:24.552408+07	ASII	4102.302804187606	80233	BBCA	BMRI	HAKA
2026-07-09 03:39:24.552408+07	ASII	4106.540004514905	35990	BBCA	BMRI	HAKA
2026-07-09 02:43:24.552408+07	ASII	4123.0377289140015	34451	BBCA	BMRI	HAKA
2026-07-09 01:50:24.552408+07	ASII	4116.548730882585	45290	BBCA	BMRI	HAKI
2026-07-09 00:10:24.552408+07	ASII	4115.75052657437	62404	BBCA	BMRI	HAKI
2026-07-09 00:05:24.552408+07	ASII	4112.227325902824	48856	BBCA	BMRI	HAKI
2026-07-08 22:57:24.552408+07	ASII	4106.711344825912	40697	BBCA	BMRI	HAKI
2026-07-08 21:43:24.552408+07	ASII	4115.807248969357	63050	BBCA	BMRI	HAKA
2026-07-08 20:44:24.552408+07	ASII	4103.975121731832	43842	BBCA	BMRI	HAKI
2026-07-08 19:17:24.552408+07	ASII	4115.043661883834	51886	BBCA	BMRI	HAKA
2026-07-08 18:19:24.552408+07	ASII	4104.132120780824	39638	BBCA	BMRI	HAKI
2026-07-08 17:41:24.552408+07	ASII	4109.788007740026	63156	BBCA	BMRI	HAKA
2026-07-08 16:39:24.552408+07	ASII	4122.438076177633	41486	BBCA	BMRI	HAKA
2026-07-08 15:38:24.552408+07	ASII	4111.556995447201	52286	BBCA	BMRI	HAKI
\.


--
-- Data for Name: _hyper_1_7_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_1_7_chunk ("time", ticker, price, volume, buyer_broker, seller_broker, trade_type) FROM stdin;
2026-07-10 01:30:01.914253+07	BBCA	2099.8408746833716	782482	BBRI	BBNI	HAKI
2026-07-13 01:30:01.914253+07	BBCA	2085.1436571324593	1217008	BBRI	BBNI	HAKI
2026-07-14 01:30:01.914253+07	BBCA	2113.593726334268	902163	BBRI	BBNI	HAKA
2026-07-15 01:30:01.914253+07	BBCA	2136.8425184994276	792905	BBRI	BBNI	HAKA
2026-07-10 01:30:02.04616+07	BBRI	5841.937182098434	1262122	BBRI	BBNI	HAKI
2026-07-13 01:30:02.04616+07	BBRI	5830.774633897781	1267520	BBRI	BBNI	HAKI
2026-07-14 01:30:02.04616+07	BBRI	5889.488741879118	1016998	BBRI	BBNI	HAKA
2026-07-15 01:30:02.04616+07	BBRI	5757.301852865528	923387	BBRI	BBNI	HAKI
2026-07-10 01:30:02.098339+07	BMRI	1448.0595741643638	1235802	BBRI	BBNI	HAKA
2026-07-13 01:30:02.098339+07	BMRI	1424.1986601228618	1246945	BBRI	BBNI	HAKI
2026-07-14 01:30:02.098339+07	BMRI	1441.737531592318	621051	BBRI	BBNI	HAKA
2026-07-15 01:30:02.098339+07	BMRI	1393.912230587306	1065018	BBRI	BBNI	HAKI
2026-07-10 01:30:02.137016+07	TLKM	4743.64948552273	718025	BBRI	BBNI	HAKI
2026-07-13 01:30:02.137016+07	TLKM	4598.410483171521	1071999	BBRI	BBNI	HAKI
2026-07-14 01:30:02.137016+07	TLKM	4573.716663715396	810106	BBRI	BBNI	HAKI
2026-07-15 01:30:02.137016+07	TLKM	4612.143653493429	883002	BBRI	BBNI	HAKA
2026-07-10 01:30:02.179406+07	ASII	3503.115393279608	1056789	BBRI	BBNI	HAKI
2026-07-13 01:30:02.179406+07	ASII	3401.056339595642	1261831	BBRI	BBNI	HAKI
2026-07-14 01:30:02.179406+07	ASII	3442.3550784107024	866283	BBRI	BBNI	HAKA
2026-07-15 01:30:02.179406+07	ASII	3406.325891605251	1683081	BBRI	BBNI	HAKI
2026-07-09 10:28:55.029475+07	BBCA	4021.8128705295344	47424	BBCA	BMRI	HAKA
2026-07-09 09:18:55.029475+07	BBCA	4018.632168993636	43378	BBCA	BMRI	HAKI
2026-07-09 08:24:55.029475+07	BBCA	4019.3730653118555	30404	BBCA	BMRI	HAKA
2026-07-09 07:34:55.029475+07	BBCA	4001.6681468953375	51792	BBCA	BMRI	HAKI
2026-07-10 10:22:55.029475+07	BBCA	3966.182847497474	67546	BBCA	BMRI	HAKA
2026-07-10 09:12:55.029475+07	BBCA	3970.96009910542	44166	BBCA	BMRI	HAKA
2026-07-10 08:55:55.029475+07	BBCA	3969.2478907075315	57190	BBCA	BMRI	HAKI
2026-07-10 07:29:55.029475+07	BBCA	3956.326045539552	50527	BBCA	BMRI	HAKI
2026-07-10 06:20:55.029475+07	BBCA	3964.717927483462	46639	BBCA	BMRI	HAKA
2026-07-10 05:57:55.029475+07	BBCA	3959.8518161414067	45383	BBCA	BMRI	HAKI
2026-07-10 04:53:55.029475+07	BBCA	3959.0474633952454	59029	BBCA	BMRI	HAKI
2026-07-10 03:21:55.029475+07	BBCA	3965.35037346457	47156	BBCA	BMRI	HAKA
2026-07-10 02:40:55.029475+07	BBCA	3977.5014306200505	40741	BBCA	BMRI	HAKA
2026-07-10 01:09:55.029475+07	BBCA	3972.637394108397	42789	BBCA	BMRI	HAKI
2026-07-10 00:19:55.029475+07	BBCA	3965.3695128035847	52185	BBCA	BMRI	HAKI
2026-07-09 23:39:55.029475+07	BBCA	3961.1296519773255	50178	BBCA	BMRI	HAKI
2026-07-09 22:41:55.029475+07	BBCA	3954.747687634554	42082	BBCA	BMRI	HAKI
2026-07-09 21:11:55.029475+07	BBCA	3972.5383599327033	58825	BBCA	BMRI	HAKA
2026-07-09 20:32:55.029475+07	BBCA	3975.510277012796	43673	BBCA	BMRI	HAKA
2026-07-09 19:24:55.029475+07	BBCA	3974.3927243419016	44356	BBCA	BMRI	HAKI
2026-07-09 18:14:55.029475+07	BBCA	3979.217929223659	76498	BBCA	BMRI	HAKA
2026-07-09 17:56:55.029475+07	BBCA	3978.914295404049	31915	BBCA	BMRI	HAKI
2026-07-09 16:34:55.029475+07	BBCA	3977.0329604107874	50817	BBCA	BMRI	HAKI
2026-07-09 15:16:55.029475+07	BBCA	3977.949792441014	54796	BBCA	BMRI	HAKA
2026-07-11 10:59:55.029475+07	BBCA	3981.7028367196467	57639	BBCA	BMRI	HAKA
2026-07-11 09:56:55.029475+07	BBCA	3986.4457701486235	63874	BBCA	BMRI	HAKA
2026-07-11 08:58:55.029475+07	BBCA	3991.439316652684	45986	BBCA	BMRI	HAKA
2026-07-11 07:27:55.029475+07	BBCA	3979.6772833948135	56475	BBCA	BMRI	HAKI
2026-07-11 07:03:55.029475+07	BBCA	3974.0673206944484	54886	BBCA	BMRI	HAKI
2026-07-11 05:20:55.029475+07	BBCA	3966.4375896245415	53884	BBCA	BMRI	HAKI
2026-07-11 04:32:55.029475+07	BBCA	3973.764090048019	45996	BBCA	BMRI	HAKA
2026-07-11 03:09:55.029475+07	BBCA	3974.398703395325	64466	BBCA	BMRI	HAKA
2026-07-11 02:38:55.029475+07	BBCA	3983.794289476751	35471	BBCA	BMRI	HAKA
2026-07-11 01:41:55.029475+07	BBCA	3984.1441169138916	39019	BBCA	BMRI	HAKA
2026-07-11 00:42:55.029475+07	BBCA	3988.1830716230884	29508	BBCA	BMRI	HAKA
2026-07-10 23:58:55.029475+07	BBCA	3968.1162856912347	65927	BBCA	BMRI	HAKI
2026-07-10 22:38:55.029475+07	BBCA	3966.9759197370886	63145	BBCA	BMRI	HAKI
2026-07-10 21:25:55.029475+07	BBCA	3968.458113776166	62002	BBCA	BMRI	HAKA
2026-07-10 20:39:55.029475+07	BBCA	3980.904060525671	44275	BBCA	BMRI	HAKA
2026-07-10 19:34:55.029475+07	BBCA	3983.1001308102745	59957	BBCA	BMRI	HAKA
2026-07-10 18:44:55.029475+07	BBCA	3986.1266765653145	36925	BBCA	BMRI	HAKA
2026-07-10 17:54:55.029475+07	BBCA	3983.7843836575757	57064	BBCA	BMRI	HAKI
2026-07-10 16:13:55.029475+07	BBCA	3974.4805169466895	59436	BBCA	BMRI	HAKI
2026-07-10 16:03:55.029475+07	BBCA	3976.3688199197154	43825	BBCA	BMRI	HAKA
2026-07-12 10:45:55.029475+07	BBCA	3971.304155938387	36118	BBCA	BMRI	HAKI
2026-07-12 09:36:55.029475+07	BBCA	3962.5468425396857	36067	BBCA	BMRI	HAKI
2026-07-12 08:06:55.029475+07	BBCA	3955.114090333267	49502	BBCA	BMRI	HAKI
2026-07-12 07:32:55.029475+07	BBCA	3963.529822002582	50889	BBCA	BMRI	HAKA
2026-07-12 06:38:55.029475+07	BBCA	3963.410938795758	31426	BBCA	BMRI	HAKI
2026-07-12 05:53:55.029475+07	BBCA	3961.659607209622	54314	BBCA	BMRI	HAKI
2026-07-12 04:27:55.029475+07	BBCA	3962.571296905016	41261	BBCA	BMRI	HAKA
2026-07-12 03:27:55.029475+07	BBCA	3961.346638334982	55527	BBCA	BMRI	HAKI
2026-07-12 02:56:55.029475+07	BBCA	3949.9159561290157	46612	BBCA	BMRI	HAKI
2026-07-12 01:29:55.029475+07	BBCA	3944.6653684101534	49017	BBCA	BMRI	HAKI
2026-07-12 00:24:55.029475+07	BBCA	3943.338561836939	50118	BBCA	BMRI	HAKI
2026-07-12 00:02:55.029475+07	BBCA	3961.510432748118	58113	BBCA	BMRI	HAKA
2026-07-11 22:12:55.029475+07	BBCA	3960.9055168317373	41551	BBCA	BMRI	HAKI
2026-07-11 22:02:55.029475+07	BBCA	3947.7010998451015	50523	BBCA	BMRI	HAKI
2026-07-11 20:06:55.029475+07	BBCA	3940.8509996236676	54588	BBCA	BMRI	HAKI
2026-07-11 19:52:55.029475+07	BBCA	3944.210391378278	43046	BBCA	BMRI	HAKA
2026-07-11 18:19:55.029475+07	BBCA	3945.8569205997524	62233	BBCA	BMRI	HAKA
2026-07-11 17:47:55.029475+07	BBCA	3933.814621129426	45559	BBCA	BMRI	HAKI
2026-07-11 16:56:55.029475+07	BBCA	3903.963339397932	57091	BBCA	BMRI	HAKI
2026-07-11 15:27:55.029475+07	BBCA	3901.4857381138563	63629	BBCA	BMRI	HAKI
2026-07-13 10:40:55.029475+07	BBCA	3899.3216047982223	40567	BBCA	BMRI	HAKI
2026-07-13 10:04:55.029475+07	BBCA	3900.0459575182936	32662	BBCA	BMRI	HAKA
2026-07-13 08:37:55.029475+07	BBCA	3900.0122165963603	46258	BBCA	BMRI	HAKI
2026-07-13 07:31:55.029475+07	BBCA	3895.2681106758973	50932	BBCA	BMRI	HAKI
2026-07-13 06:31:55.029475+07	BBCA	3897.863916853915	61722	BBCA	BMRI	HAKA
2026-07-13 05:22:55.029475+07	BBCA	3887.394454015622	50738	BBCA	BMRI	HAKI
2026-07-13 04:43:55.029475+07	BBCA	3889.1245064081513	37653	BBCA	BMRI	HAKA
2026-07-13 03:37:55.029475+07	BBCA	3892.8203330628535	56164	BBCA	BMRI	HAKA
2026-07-13 02:39:55.029475+07	BBCA	3895.2610385785033	49396	BBCA	BMRI	HAKA
2026-07-13 01:59:55.029475+07	BBCA	3904.5618950502785	50931	BBCA	BMRI	HAKA
2026-07-13 00:05:55.029475+07	BBCA	3892.301918832701	56169	BBCA	BMRI	HAKI
2026-07-12 23:45:55.029475+07	BBCA	3887.7741259653044	34971	BBCA	BMRI	HAKI
2026-07-12 22:17:55.029475+07	BBCA	3884.1699667122275	45485	BBCA	BMRI	HAKI
2026-07-12 21:23:55.029475+07	BBCA	3878.654622076645	53232	BBCA	BMRI	HAKI
2026-07-12 20:59:55.029475+07	BBCA	3859.8765384488834	53082	BBCA	BMRI	HAKI
2026-07-12 19:41:55.029475+07	BBCA	3861.6321710889115	71396	BBCA	BMRI	HAKA
2026-07-12 18:15:55.029475+07	BBCA	3855.508916075538	76020	BBCA	BMRI	HAKI
2026-07-12 17:21:55.029475+07	BBCA	3859.1120983426276	74556	BBCA	BMRI	HAKA
2026-07-12 16:17:55.029475+07	BBCA	3866.5491691571183	56313	BBCA	BMRI	HAKA
2026-07-12 15:55:55.029475+07	BBCA	3884.5982492542894	53009	BBCA	BMRI	HAKA
2026-07-14 10:23:55.029475+07	BBCA	3878.800964345648	43176	BBCA	BMRI	HAKI
2026-07-14 09:06:55.029475+07	BBCA	3868.392211307327	33725	BBCA	BMRI	HAKI
2026-07-14 08:07:55.029475+07	BBCA	3881.142160630448	51964	BBCA	BMRI	HAKA
2026-07-14 08:03:55.029475+07	BBCA	3874.2497860132034	48017	BBCA	BMRI	HAKI
2026-07-14 06:12:55.029475+07	BBCA	3869.0447779632723	41524	BBCA	BMRI	HAKI
2026-07-14 05:08:55.029475+07	BBCA	3886.589553733181	52913	BBCA	BMRI	HAKA
2026-07-14 04:59:55.029475+07	BBCA	3883.4616986718024	44181	BBCA	BMRI	HAKI
2026-07-14 03:48:55.029475+07	BBCA	3888.6764268040733	70523	BBCA	BMRI	HAKA
2026-07-14 02:52:55.029475+07	BBCA	3879.129375852452	48220	BBCA	BMRI	HAKI
2026-07-14 01:41:55.029475+07	BBCA	3874.72712554747	41571	BBCA	BMRI	HAKI
2026-07-14 00:05:55.029475+07	BBCA	3856.588500366572	51010	BBCA	BMRI	HAKI
2026-07-13 23:40:55.029475+07	BBCA	3847.8368806771573	54341	BBCA	BMRI	HAKI
2026-07-13 22:49:55.029475+07	BBCA	3828.4842671148854	55191	BBCA	BMRI	HAKI
2026-07-13 21:59:55.029475+07	BBCA	3824.439338376368	52838	BBCA	BMRI	HAKI
2026-07-13 20:54:55.029475+07	BBCA	3829.158339775328	53874	BBCA	BMRI	HAKA
2026-07-13 19:35:55.029475+07	BBCA	3829.998674319751	54402	BBCA	BMRI	HAKA
2026-07-13 18:55:55.029475+07	BBCA	3823.319753207963	49656	BBCA	BMRI	HAKI
2026-07-13 17:49:55.029475+07	BBCA	3827.2894529758687	36714	BBCA	BMRI	HAKA
2026-07-13 16:27:55.029475+07	BBCA	3829.5039066598506	63410	BBCA	BMRI	HAKA
2026-07-13 15:32:55.029475+07	BBCA	3829.7022988302656	36010	BBCA	BMRI	HAKA
2026-07-09 10:36:56.369997+07	BBRI	1575.5627365814164	49708	BBCA	BMRI	HAKA
2026-07-09 09:15:56.369997+07	BBRI	1573.505342553938	49805	BBCA	BMRI	HAKI
2026-07-09 08:13:56.369997+07	BBRI	1573.752815458375	47939	BBCA	BMRI	HAKA
2026-07-09 07:34:56.369997+07	BBRI	1570.616953265376	66969	BBCA	BMRI	HAKI
2026-07-10 10:20:56.369997+07	BBRI	1573.0531366492517	61410	BBCA	BMRI	HAKI
2026-07-10 09:53:56.369997+07	BBRI	1571.5338664072965	40282	BBCA	BMRI	HAKI
2026-07-10 08:52:56.369997+07	BBRI	1562.6251316042697	59872	BBCA	BMRI	HAKI
2026-07-10 07:42:56.369997+07	BBRI	1561.8082282723335	41833	BBCA	BMRI	HAKI
2026-07-10 06:19:56.369997+07	BBRI	1563.8896961767912	47230	BBCA	BMRI	HAKA
2026-07-10 05:25:56.369997+07	BBRI	1558.6407389695394	42440	BBCA	BMRI	HAKI
2026-07-10 04:53:56.369997+07	BBRI	1558.333141092457	53337	BBCA	BMRI	HAKI
2026-07-10 03:15:56.369997+07	BBRI	1558.5816985101194	43614	BBCA	BMRI	HAKA
2026-07-10 02:16:56.369997+07	BBRI	1562.1129803138454	41976	BBCA	BMRI	HAKA
2026-07-10 01:22:56.369997+07	BBRI	1565.4394920034874	20030	BBCA	BMRI	HAKA
2026-07-10 00:53:56.369997+07	BBRI	1568.9595178074544	54209	BBCA	BMRI	HAKA
2026-07-09 23:07:56.369997+07	BBRI	1569.0063087347587	41752	BBCA	BMRI	HAKA
2026-07-09 22:56:56.369997+07	BBRI	1568.9636865952448	55386	BBCA	BMRI	HAKI
2026-07-09 21:41:56.369997+07	BBRI	1568.26985697342	52497	BBCA	BMRI	HAKI
2026-07-09 20:56:56.369997+07	BBRI	1571.3865892619951	36344	BBCA	BMRI	HAKA
2026-07-09 19:30:56.369997+07	BBRI	1576.4557304081973	48927	BBCA	BMRI	HAKA
2026-07-09 18:38:56.369997+07	BBRI	1569.935112577808	37159	BBCA	BMRI	HAKI
2026-07-09 17:42:56.369997+07	BBRI	1573.1987374252367	72825	BBCA	BMRI	HAKA
2026-07-09 16:23:56.369997+07	BBRI	1577.770327206152	56359	BBCA	BMRI	HAKA
2026-07-09 15:48:56.369997+07	BBRI	1573.9822437918879	40656	BBCA	BMRI	HAKI
2026-07-11 10:10:56.369997+07	BBRI	1574.4789414061913	71812	BBCA	BMRI	HAKA
2026-07-11 09:28:56.369997+07	BBRI	1583.7981307138987	43504	BBCA	BMRI	HAKA
2026-07-11 08:51:56.369997+07	BBRI	1583.5356279000762	28926	BBCA	BMRI	HAKI
2026-07-11 07:17:56.369997+07	BBRI	1581.3195912884466	50007	BBCA	BMRI	HAKI
2026-07-11 06:59:56.369997+07	BBRI	1578.3474054146104	46436	BBCA	BMRI	HAKI
2026-07-11 05:43:56.369997+07	BBRI	1579.880854627014	46141	BBCA	BMRI	HAKA
2026-07-11 04:33:56.369997+07	BBRI	1577.1660172727718	43554	BBCA	BMRI	HAKI
2026-07-11 03:32:56.369997+07	BBRI	1575.9503128384004	19888	BBCA	BMRI	HAKI
2026-07-11 03:02:56.369997+07	BBRI	1577.8901386640875	48406	BBCA	BMRI	HAKA
2026-07-11 01:41:56.369997+07	BBRI	1579.397693753643	36093	BBCA	BMRI	HAKA
2026-07-11 00:52:56.369997+07	BBRI	1579.0514431313138	54816	BBCA	BMRI	HAKI
2026-07-10 23:44:56.369997+07	BBRI	1578.7041706488153	54319	BBCA	BMRI	HAKI
2026-07-10 22:16:56.369997+07	BBRI	1575.0509062232152	33254	BBCA	BMRI	HAKI
2026-07-10 21:42:56.369997+07	BBRI	1575.1210452235937	63146	BBCA	BMRI	HAKA
2026-07-10 20:13:56.369997+07	BBRI	1575.1565858251106	45098	BBCA	BMRI	HAKA
2026-07-10 19:28:56.369997+07	BBRI	1570.5725931926959	54049	BBCA	BMRI	HAKI
2026-07-10 18:49:56.369997+07	BBRI	1569.6545117746564	77625	BBCA	BMRI	HAKI
2026-07-10 17:21:56.369997+07	BBRI	1565.6423560429264	58218	BBCA	BMRI	HAKI
2026-07-10 16:05:56.369997+07	BBRI	1568.746446123782	43758	BBCA	BMRI	HAKA
2026-07-10 15:08:56.369997+07	BBRI	1570.301329742915	30689	BBCA	BMRI	HAKA
2026-07-12 10:21:56.369997+07	BBRI	1571.7013930398095	59414	BBCA	BMRI	HAKA
2026-07-12 09:24:56.369997+07	BBRI	1565.1039246540697	28487	BBCA	BMRI	HAKI
2026-07-12 08:32:56.369997+07	BBRI	1562.8522143177188	76353	BBCA	BMRI	HAKI
2026-07-12 07:22:56.369997+07	BBRI	1565.6062677193427	65564	BBCA	BMRI	HAKA
2026-07-12 06:42:56.369997+07	BBRI	1564.0475850983753	58660	BBCA	BMRI	HAKI
2026-07-12 06:02:56.369997+07	BBRI	1559.915616406482	66580	BBCA	BMRI	HAKI
2026-07-12 04:16:56.369997+07	BBRI	1559.3416443745937	53301	BBCA	BMRI	HAKI
2026-07-12 03:15:56.369997+07	BBRI	1559.316511508574	53594	BBCA	BMRI	HAKI
2026-07-12 02:05:56.369997+07	BBRI	1564.3234988096765	26495	BBCA	BMRI	HAKA
2026-07-12 01:58:56.369997+07	BBRI	1565.0039823582117	52863	BBCA	BMRI	HAKA
2026-07-12 00:13:56.369997+07	BBRI	1564.087582858006	57726	BBCA	BMRI	HAKI
2026-07-12 00:01:56.369997+07	BBRI	1561.8741489704196	66388	BBCA	BMRI	HAKI
2026-07-11 22:42:56.369997+07	BBRI	1560.1882771317041	30868	BBCA	BMRI	HAKI
2026-07-11 22:03:56.369997+07	BBRI	1560.8548120737773	49405	BBCA	BMRI	HAKA
2026-07-11 20:09:56.369997+07	BBRI	1563.331661491899	70615	BBCA	BMRI	HAKA
2026-07-11 19:46:56.369997+07	BBRI	1560.8888064703017	42364	BBCA	BMRI	HAKI
2026-07-11 18:11:56.369997+07	BBRI	1557.9140997050847	33028	BBCA	BMRI	HAKI
2026-07-11 17:20:56.369997+07	BBRI	1563.2268539507033	53908	BBCA	BMRI	HAKA
2026-07-11 17:02:56.369997+07	BBRI	1562.0402834367053	53452	BBCA	BMRI	HAKI
2026-07-11 16:03:56.369997+07	BBRI	1559.127650243528	50427	BBCA	BMRI	HAKI
2026-07-13 10:53:56.369997+07	BBRI	1560.1408353435218	51719	BBCA	BMRI	HAKA
2026-07-13 09:37:56.369997+07	BBRI	1559.0135258743567	45446	BBCA	BMRI	HAKI
2026-07-13 08:46:56.369997+07	BBRI	1556.6184856558143	64845	BBCA	BMRI	HAKI
2026-07-13 08:03:56.369997+07	BBRI	1556.6264960692515	55841	BBCA	BMRI	HAKA
2026-07-13 06:58:56.369997+07	BBRI	1558.862943533123	56592	BBCA	BMRI	HAKA
2026-07-13 05:35:56.369997+07	BBRI	1556.928649545599	41901	BBCA	BMRI	HAKI
2026-07-13 04:33:56.369997+07	BBRI	1559.5952406427152	35987	BBCA	BMRI	HAKA
2026-07-13 04:02:56.369997+07	BBRI	1562.157735654821	39479	BBCA	BMRI	HAKA
2026-07-13 02:33:56.369997+07	BBRI	1561.9636227745407	39534	BBCA	BMRI	HAKI
2026-07-13 01:34:56.369997+07	BBRI	1564.9070833675923	66798	BBCA	BMRI	HAKA
2026-07-13 00:50:56.369997+07	BBRI	1560.5200826975943	37074	BBCA	BMRI	HAKI
2026-07-12 23:07:56.369997+07	BBRI	1558.2369766147679	59133	BBCA	BMRI	HAKI
2026-07-12 22:28:56.369997+07	BBRI	1560.8996205155702	52028	BBCA	BMRI	HAKA
2026-07-12 22:00:56.369997+07	BBRI	1558.6509683052973	48564	BBCA	BMRI	HAKI
2026-07-12 20:59:56.369997+07	BBRI	1560.805753439357	53301	BBCA	BMRI	HAKA
2026-07-12 19:17:56.369997+07	BBRI	1561.1412212582957	49810	BBCA	BMRI	HAKA
2026-07-12 18:31:56.369997+07	BBRI	1555.8298498032323	51768	BBCA	BMRI	HAKI
2026-07-12 17:46:56.369997+07	BBRI	1558.5561935306648	53103	BBCA	BMRI	HAKA
2026-07-12 16:14:56.369997+07	BBRI	1557.7706732730724	60177	BBCA	BMRI	HAKI
2026-07-12 15:56:56.369997+07	BBRI	1557.0964624973274	45982	BBCA	BMRI	HAKI
2026-07-14 10:53:56.369997+07	BBRI	1556.6731905532877	48658	BBCA	BMRI	HAKI
2026-07-14 10:04:56.369997+07	BBRI	1558.368689820905	39522	BBCA	BMRI	HAKA
2026-07-14 08:05:56.369997+07	BBRI	1559.3959164985208	63192	BBCA	BMRI	HAKA
2026-07-14 07:45:56.369997+07	BBRI	1554.327372309507	55366	BBCA	BMRI	HAKI
2026-07-14 06:17:56.369997+07	BBRI	1550.21317906434	61110	BBCA	BMRI	HAKI
2026-07-14 05:42:56.369997+07	BBRI	1550.07133809363	59444	BBCA	BMRI	HAKI
2026-07-14 04:31:56.369997+07	BBRI	1552.49974288473	50141	BBCA	BMRI	HAKA
2026-07-14 03:20:56.369997+07	BBRI	1553.6777046279924	45036	BBCA	BMRI	HAKA
2026-07-14 02:23:56.369997+07	BBRI	1553.8915237936842	67586	BBCA	BMRI	HAKA
2026-07-14 01:36:56.369997+07	BBRI	1558.3378042353277	44843	BBCA	BMRI	HAKA
2026-07-14 00:08:56.369997+07	BBRI	1556.6723927719836	41329	BBCA	BMRI	HAKI
2026-07-13 23:27:56.369997+07	BBRI	1556.7174844267645	30660	BBCA	BMRI	HAKA
2026-07-13 22:16:56.369997+07	BBRI	1555.1869987100258	48752	BBCA	BMRI	HAKI
2026-07-13 21:35:56.369997+07	BBRI	1556.8653255433135	68353	BBCA	BMRI	HAKA
2026-07-13 20:29:56.369997+07	BBRI	1555.5948753049665	47417	BBCA	BMRI	HAKI
2026-07-13 20:01:56.369997+07	BBRI	1554.5014207696395	64883	BBCA	BMRI	HAKI
2026-07-13 18:10:56.369997+07	BBRI	1550.768053236771	50044	BBCA	BMRI	HAKI
2026-07-13 17:42:56.369997+07	BBRI	1551.3099635048545	39953	BBCA	BMRI	HAKA
2026-07-13 16:40:56.369997+07	BBRI	1552.2337510543684	62132	BBCA	BMRI	HAKA
2026-07-13 15:21:56.369997+07	BBRI	1551.6122090023787	63879	BBCA	BMRI	HAKI
2026-07-09 10:32:57.706842+07	BMRI	2799.2449714449654	47382	BBCA	BMRI	HAKA
2026-07-09 09:06:57.706842+07	BMRI	2809.1009648586064	59046	BBCA	BMRI	HAKA
2026-07-09 08:50:57.706842+07	BMRI	2811.40100478902	51399	BBCA	BMRI	HAKA
2026-07-09 07:26:57.706842+07	BMRI	2806.2642602302317	37656	BBCA	BMRI	HAKI
2026-07-10 10:46:57.706842+07	BMRI	2801.023509546249	37607	BBCA	BMRI	HAKI
2026-07-10 09:16:57.706842+07	BMRI	2803.6808726750915	41193	BBCA	BMRI	HAKA
2026-07-10 08:25:57.706842+07	BMRI	2795.63269716524	46986	BBCA	BMRI	HAKI
2026-07-10 07:49:57.706842+07	BMRI	2799.605981588933	32891	BBCA	BMRI	HAKA
2026-07-10 06:15:57.706842+07	BMRI	2804.2774216178213	30551	BBCA	BMRI	HAKA
2026-07-10 05:49:57.706842+07	BMRI	2799.184684898302	42958	BBCA	BMRI	HAKI
2026-07-10 04:57:57.706842+07	BMRI	2803.1925818829664	67072	BBCA	BMRI	HAKA
2026-07-10 04:03:57.706842+07	BMRI	2797.753325478282	49016	BBCA	BMRI	HAKI
2026-07-10 02:07:57.706842+07	BMRI	2791.9747810304516	43456	BBCA	BMRI	HAKI
2026-07-10 01:46:57.706842+07	BMRI	2791.6217607530834	47598	BBCA	BMRI	HAKI
2026-07-10 00:35:57.706842+07	BMRI	2786.3513793001352	50074	BBCA	BMRI	HAKI
2026-07-09 23:20:57.706842+07	BMRI	2789.1603310336995	48285	BBCA	BMRI	HAKA
2026-07-09 22:15:57.706842+07	BMRI	2791.608486269974	56677	BBCA	BMRI	HAKA
2026-07-09 21:26:57.706842+07	BMRI	2792.4440434164076	38373	BBCA	BMRI	HAKA
2026-07-09 21:00:57.706842+07	BMRI	2794.792839115842	51266	BBCA	BMRI	HAKA
2026-07-09 19:22:57.706842+07	BMRI	2791.9395467399822	23364	BBCA	BMRI	HAKI
2026-07-09 18:23:57.706842+07	BMRI	2773.7968996705135	25498	BBCA	BMRI	HAKI
2026-07-09 17:45:57.706842+07	BMRI	2772.04013406328	36695	BBCA	BMRI	HAKI
2026-07-09 16:33:57.706842+07	BMRI	2763.6836149535256	37287	BBCA	BMRI	HAKI
2026-07-09 15:48:57.706842+07	BMRI	2765.7903237052155	59599	BBCA	BMRI	HAKA
2026-07-11 10:46:57.706842+07	BMRI	2770.844725365911	54722	BBCA	BMRI	HAKA
2026-07-11 09:09:57.706842+07	BMRI	2770.243172324682	45137	BBCA	BMRI	HAKI
2026-07-11 08:17:57.706842+07	BMRI	2772.398531699485	51805	BBCA	BMRI	HAKA
2026-07-11 07:41:57.706842+07	BMRI	2778.8310124387967	63163	BBCA	BMRI	HAKA
2026-07-11 06:11:57.706842+07	BMRI	2773.665230220395	47242	BBCA	BMRI	HAKI
2026-07-11 05:15:57.706842+07	BMRI	2775.0917584703357	47474	BBCA	BMRI	HAKA
2026-07-11 04:37:57.706842+07	BMRI	2765.10325106972	64753	BBCA	BMRI	HAKI
2026-07-11 03:27:57.706842+07	BMRI	2761.7492113914573	41695	BBCA	BMRI	HAKI
2026-07-11 02:15:57.706842+07	BMRI	2773.586464505965	57730	BBCA	BMRI	HAKA
2026-07-11 01:44:57.706842+07	BMRI	2769.4502507127027	44915	BBCA	BMRI	HAKI
2026-07-11 00:39:57.706842+07	BMRI	2759.8156518792066	41804	BBCA	BMRI	HAKI
2026-07-10 23:11:57.706842+07	BMRI	2758.640955534316	55313	BBCA	BMRI	HAKI
2026-07-10 22:36:57.706842+07	BMRI	2749.0821859835846	60930	BBCA	BMRI	HAKI
2026-07-10 21:51:57.706842+07	BMRI	2752.782082023251	43659	BBCA	BMRI	HAKA
2026-07-10 20:13:57.706842+07	BMRI	2753.080978259282	58781	BBCA	BMRI	HAKA
2026-07-10 19:40:57.706842+07	BMRI	2753.9497589794155	61419	BBCA	BMRI	HAKA
2026-07-10 18:14:57.706842+07	BMRI	2752.4498215990443	58300	BBCA	BMRI	HAKI
2026-07-10 17:10:57.706842+07	BMRI	2753.804202811701	50396	BBCA	BMRI	HAKA
2026-07-10 16:27:57.706842+07	BMRI	2753.8311484008295	59205	BBCA	BMRI	HAKA
2026-07-10 15:40:57.706842+07	BMRI	2743.4937181182586	64731	BBCA	BMRI	HAKI
2026-07-12 10:58:57.706842+07	BMRI	2738.6996097633964	45300	BBCA	BMRI	HAKI
2026-07-12 10:02:57.706842+07	BMRI	2747.9853822637724	47201	BBCA	BMRI	HAKA
2026-07-12 08:38:57.706842+07	BMRI	2750.0580823349246	49807	BBCA	BMRI	HAKA
2026-07-12 07:24:57.706842+07	BMRI	2758.07961799274	42977	BBCA	BMRI	HAKA
2026-07-12 06:50:57.706842+07	BMRI	2760.344816988033	57681	BBCA	BMRI	HAKA
2026-07-12 05:40:57.706842+07	BMRI	2756.7911351446915	50241	BBCA	BMRI	HAKI
2026-07-12 04:09:57.706842+07	BMRI	2754.435739233509	40834	BBCA	BMRI	HAKI
2026-07-12 03:07:57.706842+07	BMRI	2748.6777422201376	45820	BBCA	BMRI	HAKI
2026-07-12 02:26:57.706842+07	BMRI	2748.9416690039106	69599	BBCA	BMRI	HAKA
2026-07-12 01:23:57.706842+07	BMRI	2740.035409561258	56655	BBCA	BMRI	HAKI
2026-07-12 00:27:57.706842+07	BMRI	2745.4998732272834	36601	BBCA	BMRI	HAKA
2026-07-11 23:41:57.706842+07	BMRI	2752.410116516106	58684	BBCA	BMRI	HAKA
2026-07-11 22:40:57.706842+07	BMRI	2758.587753627049	66945	BBCA	BMRI	HAKA
2026-07-11 21:21:57.706842+07	BMRI	2765.7796763765627	43987	BBCA	BMRI	HAKA
2026-07-11 20:48:57.706842+07	BMRI	2766.371953970025	62592	BBCA	BMRI	HAKA
2026-07-11 19:35:57.706842+07	BMRI	2771.4904525404377	44175	BBCA	BMRI	HAKA
2026-07-11 18:49:57.706842+07	BMRI	2774.793211598215	51281	BBCA	BMRI	HAKA
2026-07-11 17:09:57.706842+07	BMRI	2774.143368684817	66550	BBCA	BMRI	HAKI
2026-07-11 16:11:57.706842+07	BMRI	2779.583882883027	39942	BBCA	BMRI	HAKA
2026-07-11 15:20:57.706842+07	BMRI	2790.241131173169	62091	BBCA	BMRI	HAKA
2026-07-13 10:19:57.706842+07	BMRI	2781.3803255603284	49693	BBCA	BMRI	HAKI
2026-07-13 09:52:57.706842+07	BMRI	2782.1716145413743	41501	BBCA	BMRI	HAKA
2026-07-13 09:03:57.706842+07	BMRI	2774.259786160529	54361	BBCA	BMRI	HAKI
2026-07-13 07:39:57.706842+07	BMRI	2772.0633761995887	36593	BBCA	BMRI	HAKI
2026-07-13 06:38:57.706842+07	BMRI	2769.078974195226	48548	BBCA	BMRI	HAKI
2026-07-13 05:39:57.706842+07	BMRI	2775.591469197998	57797	BBCA	BMRI	HAKA
2026-07-13 04:18:57.706842+07	BMRI	2771.585970089502	42396	BBCA	BMRI	HAKI
2026-07-13 03:49:57.706842+07	BMRI	2774.3770497425767	41520	BBCA	BMRI	HAKA
2026-07-13 02:30:57.706842+07	BMRI	2772.3526600922387	44177	BBCA	BMRI	HAKI
2026-07-13 01:48:57.706842+07	BMRI	2777.186238604707	61133	BBCA	BMRI	HAKA
2026-07-13 00:29:57.706842+07	BMRI	2772.7159810652624	46533	BBCA	BMRI	HAKI
2026-07-12 23:45:57.706842+07	BMRI	2772.6136226872673	65249	BBCA	BMRI	HAKI
2026-07-12 22:49:57.706842+07	BMRI	2777.4599944104375	56269	BBCA	BMRI	HAKA
2026-07-12 21:36:57.706842+07	BMRI	2782.443566459044	38395	BBCA	BMRI	HAKA
2026-07-12 20:11:57.706842+07	BMRI	2776.8728216602626	42527	BBCA	BMRI	HAKI
2026-07-12 19:10:57.706842+07	BMRI	2771.5933214548922	44096	BBCA	BMRI	HAKI
2026-07-12 18:25:57.706842+07	BMRI	2776.0132175177228	42444	BBCA	BMRI	HAKA
2026-07-12 17:58:57.706842+07	BMRI	2774.436834839713	58466	BBCA	BMRI	HAKI
2026-07-12 16:54:57.706842+07	BMRI	2770.015455959575	51763	BBCA	BMRI	HAKI
2026-07-12 16:01:57.706842+07	BMRI	2775.6620389850605	54215	BBCA	BMRI	HAKA
2026-07-14 10:13:57.706842+07	BMRI	2776.449098196711	56375	BBCA	BMRI	HAKA
2026-07-14 09:27:57.706842+07	BMRI	2780.0213094298915	41024	BBCA	BMRI	HAKA
2026-07-14 08:33:57.706842+07	BMRI	2782.721363555685	57015	BBCA	BMRI	HAKA
2026-07-14 07:23:57.706842+07	BMRI	2775.2374232183024	61589	BBCA	BMRI	HAKI
2026-07-14 06:09:57.706842+07	BMRI	2772.426284900904	60292	BBCA	BMRI	HAKI
2026-07-14 05:48:57.706842+07	BMRI	2774.9047342573267	48426	BBCA	BMRI	HAKA
2026-07-14 04:48:57.706842+07	BMRI	2773.1200234775733	49500	BBCA	BMRI	HAKI
2026-07-14 03:50:57.706842+07	BMRI	2761.050752011138	54177	BBCA	BMRI	HAKI
2026-07-14 02:37:57.706842+07	BMRI	2755.52378046493	52475	BBCA	BMRI	HAKI
2026-07-14 01:59:57.706842+07	BMRI	2776.7912397890204	67187	BBCA	BMRI	HAKA
2026-07-14 00:20:57.706842+07	BMRI	2776.387471071606	60513	BBCA	BMRI	HAKI
2026-07-13 23:45:57.706842+07	BMRI	2775.6937734933	42367	BBCA	BMRI	HAKI
2026-07-13 23:01:57.706842+07	BMRI	2772.3275499132037	68100	BBCA	BMRI	HAKI
2026-07-13 21:08:57.706842+07	BMRI	2768.658838302161	53485	BBCA	BMRI	HAKI
2026-07-13 20:26:57.706842+07	BMRI	2769.676361775368	46300	BBCA	BMRI	HAKA
2026-07-13 19:17:57.706842+07	BMRI	2757.1690828861424	29767	BBCA	BMRI	HAKI
2026-07-13 18:58:57.706842+07	BMRI	2762.1547688807477	60631	BBCA	BMRI	HAKA
2026-07-13 18:01:57.706842+07	BMRI	2763.7690911401583	49862	BBCA	BMRI	HAKA
2026-07-13 16:48:57.706842+07	BMRI	2752.916148940079	45842	BBCA	BMRI	HAKI
2026-07-13 15:57:57.706842+07	BMRI	2754.681353729849	40750	BBCA	BMRI	HAKA
2026-07-09 10:26:59.012754+07	TLKM	5860.574723160495	50064	BBCA	BMRI	HAKI
2026-07-09 09:44:59.012754+07	TLKM	5858.111451083707	42440	BBCA	BMRI	HAKI
2026-07-09 08:38:59.012754+07	TLKM	5867.68732615189	55511	BBCA	BMRI	HAKA
2026-07-09 08:04:59.012754+07	TLKM	5866.356331909125	46016	BBCA	BMRI	HAKI
2026-07-10 10:39:59.012754+07	TLKM	5917.14875271381	29621	BBCA	BMRI	HAKA
2026-07-10 09:21:59.012754+07	TLKM	5885.9005540094795	47068	BBCA	BMRI	HAKI
2026-07-10 08:13:59.012754+07	TLKM	5888.281384530482	72415	BBCA	BMRI	HAKA
2026-07-10 07:35:59.012754+07	TLKM	5869.450174736351	55472	BBCA	BMRI	HAKI
2026-07-10 06:50:59.012754+07	TLKM	5862.793967077008	43338	BBCA	BMRI	HAKI
2026-07-10 05:15:59.012754+07	TLKM	5881.1060965054785	52492	BBCA	BMRI	HAKA
2026-07-10 04:06:59.012754+07	TLKM	5893.073198096467	46124	BBCA	BMRI	HAKA
2026-07-10 03:35:59.012754+07	TLKM	5900.468678477156	47551	BBCA	BMRI	HAKA
2026-07-10 02:27:59.012754+07	TLKM	5915.452499438761	41205	BBCA	BMRI	HAKA
2026-07-10 01:30:59.012754+07	TLKM	5917.956807149881	45257	BBCA	BMRI	HAKA
2026-07-10 00:11:59.012754+07	TLKM	5915.498597923774	48810	BBCA	BMRI	HAKI
2026-07-09 23:50:59.012754+07	TLKM	5906.671251742284	68588	BBCA	BMRI	HAKI
2026-07-09 22:35:59.012754+07	TLKM	5915.850404234928	58368	BBCA	BMRI	HAKA
2026-07-09 21:44:59.012754+07	TLKM	5931.865012632703	62564	BBCA	BMRI	HAKA
2026-07-09 20:44:59.012754+07	TLKM	5929.467872959775	52312	BBCA	BMRI	HAKI
2026-07-09 19:48:59.012754+07	TLKM	5907.957771395918	55906	BBCA	BMRI	HAKI
2026-07-09 18:20:59.012754+07	TLKM	5897.644217542372	46795	BBCA	BMRI	HAKI
2026-07-09 17:34:59.012754+07	TLKM	5895.415670406336	40007	BBCA	BMRI	HAKI
2026-07-09 16:51:59.012754+07	TLKM	5908.0736140919	33446	BBCA	BMRI	HAKA
2026-07-09 15:22:59.012754+07	TLKM	5896.853297776512	57638	BBCA	BMRI	HAKI
2026-07-11 10:36:59.012754+07	TLKM	5878.079082085269	62245	BBCA	BMRI	HAKI
2026-07-11 10:03:59.012754+07	TLKM	5877.731996780684	72243	BBCA	BMRI	HAKI
2026-07-11 08:19:59.012754+07	TLKM	5880.533715043714	63234	BBCA	BMRI	HAKA
2026-07-11 07:30:59.012754+07	TLKM	5871.057738591468	46696	BBCA	BMRI	HAKI
2026-07-11 06:53:59.012754+07	TLKM	5839.1025931786635	60098	BBCA	BMRI	HAKI
2026-07-11 05:48:59.012754+07	TLKM	5822.6435940935025	66071	BBCA	BMRI	HAKI
2026-07-11 04:36:59.012754+07	TLKM	5828.810935523931	47011	BBCA	BMRI	HAKA
2026-07-11 03:32:59.012754+07	TLKM	5812.916347444235	71182	BBCA	BMRI	HAKI
2026-07-11 02:51:59.012754+07	TLKM	5805.726997106065	60832	BBCA	BMRI	HAKI
2026-07-11 01:11:59.012754+07	TLKM	5824.3624950575395	61408	BBCA	BMRI	HAKA
2026-07-11 00:26:59.012754+07	TLKM	5838.561151339406	40039	BBCA	BMRI	HAKA
2026-07-10 23:56:59.012754+07	TLKM	5839.2955487728705	50815	BBCA	BMRI	HAKA
2026-07-10 22:42:59.012754+07	TLKM	5848.716133142875	47677	BBCA	BMRI	HAKA
2026-07-10 21:13:59.012754+07	TLKM	5845.877784913924	56230	BBCA	BMRI	HAKI
2026-07-10 20:06:59.012754+07	TLKM	5858.454830492038	43909	BBCA	BMRI	HAKA
2026-07-10 19:27:59.012754+07	TLKM	5877.717050508243	69519	BBCA	BMRI	HAKA
2026-07-10 18:53:59.012754+07	TLKM	5882.690723038517	72399	BBCA	BMRI	HAKA
2026-07-10 17:21:59.012754+07	TLKM	5874.300367070264	41973	BBCA	BMRI	HAKI
2026-07-10 16:27:59.012754+07	TLKM	5862.502504551555	59725	BBCA	BMRI	HAKI
2026-07-10 15:56:59.012754+07	TLKM	5862.789919996462	44678	BBCA	BMRI	HAKA
2026-07-12 10:31:59.012754+07	TLKM	5855.915600457681	43245	BBCA	BMRI	HAKI
2026-07-12 09:52:59.012754+07	TLKM	5835.504827812498	28168	BBCA	BMRI	HAKI
2026-07-12 08:31:59.012754+07	TLKM	5844.201755277593	57455	BBCA	BMRI	HAKA
2026-07-12 07:05:59.012754+07	TLKM	5875.518118699989	40752	BBCA	BMRI	HAKA
2026-07-12 06:46:59.012754+07	TLKM	5866.647585592687	58431	BBCA	BMRI	HAKI
2026-07-12 06:03:59.012754+07	TLKM	5859.395494719455	39911	BBCA	BMRI	HAKI
2026-07-12 04:41:59.012754+07	TLKM	5859.7039208959395	40952	BBCA	BMRI	HAKA
2026-07-12 03:37:59.012754+07	TLKM	5862.902950984391	43918	BBCA	BMRI	HAKA
2026-07-12 02:12:59.012754+07	TLKM	5854.4511282662725	52080	BBCA	BMRI	HAKI
2026-07-12 01:51:59.012754+07	TLKM	5863.943721781373	37210	BBCA	BMRI	HAKA
2026-07-12 00:06:59.012754+07	TLKM	5874.51953019812	45086	BBCA	BMRI	HAKA
2026-07-11 23:50:59.012754+07	TLKM	5879.671575408932	41968	BBCA	BMRI	HAKA
2026-07-11 22:36:59.012754+07	TLKM	5890.5022454216305	32577	BBCA	BMRI	HAKA
2026-07-11 21:58:59.012754+07	TLKM	5926.44148914318	53755	BBCA	BMRI	HAKA
2026-07-11 20:40:59.012754+07	TLKM	5919.702733236804	45427	BBCA	BMRI	HAKI
2026-07-11 19:24:59.012754+07	TLKM	5915.504626437214	42083	BBCA	BMRI	HAKI
2026-07-11 18:30:59.012754+07	TLKM	5912.015236099533	45987	BBCA	BMRI	HAKI
2026-07-11 17:15:59.012754+07	TLKM	5897.602951429837	50900	BBCA	BMRI	HAKI
2026-07-11 16:58:59.012754+07	TLKM	5906.854721439492	57290	BBCA	BMRI	HAKA
2026-07-11 15:29:59.012754+07	TLKM	5898.986010493356	41845	BBCA	BMRI	HAKI
2026-07-13 10:16:59.012754+07	TLKM	5888.089829277386	51227	BBCA	BMRI	HAKI
2026-07-13 09:22:59.012754+07	TLKM	5877.7013567140475	64062	BBCA	BMRI	HAKI
2026-07-13 09:02:59.012754+07	TLKM	5883.92882235316	61026	BBCA	BMRI	HAKA
2026-07-13 07:46:59.012754+07	TLKM	5884.604206380194	51551	BBCA	BMRI	HAKA
2026-07-13 06:32:59.012754+07	TLKM	5904.46103076119	48453	BBCA	BMRI	HAKA
2026-07-13 05:55:59.012754+07	TLKM	5907.658406144656	49791	BBCA	BMRI	HAKA
2026-07-13 04:57:59.012754+07	TLKM	5919.502929427902	55272	BBCA	BMRI	HAKA
2026-07-13 03:07:59.012754+07	TLKM	5895.720536480379	57578	BBCA	BMRI	HAKI
2026-07-13 02:32:59.012754+07	TLKM	5898.041111672207	56182	BBCA	BMRI	HAKA
2026-07-13 01:46:59.012754+07	TLKM	5878.422595496067	56621	BBCA	BMRI	HAKI
2026-07-13 00:14:59.012754+07	TLKM	5879.59821306344	65038	BBCA	BMRI	HAKA
2026-07-13 00:01:59.012754+07	TLKM	5874.264398108986	41649	BBCA	BMRI	HAKI
2026-07-12 22:05:59.012754+07	TLKM	5879.4039685384105	50025	BBCA	BMRI	HAKA
2026-07-12 21:30:59.012754+07	TLKM	5890.955182795466	44485	BBCA	BMRI	HAKA
2026-07-12 20:35:59.012754+07	TLKM	5890.996791602581	55082	BBCA	BMRI	HAKA
2026-07-12 20:01:59.012754+07	TLKM	5907.034055511123	54376	BBCA	BMRI	HAKA
2026-07-12 18:53:59.012754+07	TLKM	5912.490315702705	56822	BBCA	BMRI	HAKA
2026-07-12 17:12:59.012754+07	TLKM	5901.287339721557	57537	BBCA	BMRI	HAKI
2026-07-12 16:14:59.012754+07	TLKM	5888.768326573693	36308	BBCA	BMRI	HAKI
2026-07-12 15:05:59.012754+07	TLKM	5888.448250580318	48880	BBCA	BMRI	HAKI
2026-07-14 10:10:59.012754+07	TLKM	5884.079838200479	48037	BBCA	BMRI	HAKI
2026-07-14 09:48:59.012754+07	TLKM	5905.6631873401075	37595	BBCA	BMRI	HAKA
2026-07-14 08:25:59.012754+07	TLKM	5918.476785935717	46220	BBCA	BMRI	HAKA
2026-07-14 07:50:59.012754+07	TLKM	5904.80162326855	60037	BBCA	BMRI	HAKI
2026-07-14 06:26:59.012754+07	TLKM	5902.5076910475245	34782	BBCA	BMRI	HAKI
2026-07-14 06:04:59.012754+07	TLKM	5891.014887757273	79012	BBCA	BMRI	HAKI
2026-07-14 04:44:59.012754+07	TLKM	5894.32085857801	38661	BBCA	BMRI	HAKA
2026-07-14 03:23:59.012754+07	TLKM	5915.376243228653	58531	BBCA	BMRI	HAKA
2026-07-14 02:43:59.012754+07	TLKM	5907.401684841657	37566	BBCA	BMRI	HAKI
2026-07-14 01:29:59.012754+07	TLKM	5927.037283417605	52635	BBCA	BMRI	HAKA
2026-07-14 01:04:59.012754+07	TLKM	5930.487257922542	46905	BBCA	BMRI	HAKA
2026-07-13 23:44:59.012754+07	TLKM	5928.816458759065	56122	BBCA	BMRI	HAKI
2026-07-13 22:36:59.012754+07	TLKM	5940.056777706639	43535	BBCA	BMRI	HAKA
2026-07-13 21:06:59.012754+07	TLKM	5930.098986983562	45370	BBCA	BMRI	HAKI
2026-07-13 20:36:59.012754+07	TLKM	5922.1452663054715	49059	BBCA	BMRI	HAKI
2026-07-13 19:33:59.012754+07	TLKM	5918.785346901452	40454	BBCA	BMRI	HAKI
2026-07-13 18:43:59.012754+07	TLKM	5922.634263468157	36442	BBCA	BMRI	HAKA
2026-07-13 17:12:59.012754+07	TLKM	5927.163593268642	43751	BBCA	BMRI	HAKA
2026-07-13 16:37:59.012754+07	TLKM	5913.601291499023	48676	BBCA	BMRI	HAKI
2026-07-13 15:30:59.012754+07	TLKM	5903.086234368157	58453	BBCA	BMRI	HAKI
2026-07-09 10:50:00.280677+07	ASII	2059.0765019135088	45812	BBCA	BMRI	HAKA
2026-07-09 09:53:00.280677+07	ASII	2060.480733299992	57274	BBCA	BMRI	HAKA
2026-07-09 08:44:00.280677+07	ASII	2066.991743365431	40262	BBCA	BMRI	HAKA
2026-07-09 07:19:00.280677+07	ASII	2068.4024931846984	46502	BBCA	BMRI	HAKA
2026-07-10 10:52:00.280677+07	ASII	2025.0325121788087	43729	BBCA	BMRI	HAKI
2026-07-10 10:00:00.280677+07	ASII	2015.9513205818564	51702	BBCA	BMRI	HAKI
2026-07-10 08:17:00.280677+07	ASII	2019.5773961611364	51998	BBCA	BMRI	HAKA
2026-07-10 07:28:00.280677+07	ASII	2022.7077088441172	53116	BBCA	BMRI	HAKA
2026-07-10 06:21:00.280677+07	ASII	2030.2298641502634	55628	BBCA	BMRI	HAKA
2026-07-10 05:33:00.280677+07	ASII	2022.8349470479345	53703	BBCA	BMRI	HAKI
2026-07-10 04:17:00.280677+07	ASII	2019.8462322786063	40710	BBCA	BMRI	HAKI
2026-07-10 03:48:00.280677+07	ASII	2011.711010326487	57485	BBCA	BMRI	HAKI
2026-07-10 02:32:00.280677+07	ASII	2013.1216373713041	49095	BBCA	BMRI	HAKA
2026-07-10 01:33:00.280677+07	ASII	2009.4191831391329	73903	BBCA	BMRI	HAKI
2026-07-10 01:04:00.280677+07	ASII	2005.377554063723	53668	BBCA	BMRI	HAKI
2026-07-09 23:30:00.280677+07	ASII	2004.5247810865892	42826	BBCA	BMRI	HAKI
2026-07-09 22:39:00.280677+07	ASII	2005.2554378989203	37877	BBCA	BMRI	HAKA
2026-07-09 21:08:00.280677+07	ASII	2009.490817679687	35075	BBCA	BMRI	HAKA
2026-07-09 21:00:00.280677+07	ASII	2013.9063499994654	46670	BBCA	BMRI	HAKA
2026-07-09 19:58:00.280677+07	ASII	2019.0057324466911	28847	BBCA	BMRI	HAKA
2026-07-09 18:53:00.280677+07	ASII	2020.2460327320086	40116	BBCA	BMRI	HAKA
2026-07-09 17:37:00.280677+07	ASII	2017.8336708211282	45582	BBCA	BMRI	HAKI
2026-07-09 16:36:00.280677+07	ASII	2014.7198090111353	41467	BBCA	BMRI	HAKI
2026-07-09 15:52:00.280677+07	ASII	2019.0426748642114	33509	BBCA	BMRI	HAKA
2026-07-11 10:18:00.280677+07	ASII	2018.4152982327512	54227	BBCA	BMRI	HAKI
2026-07-11 09:34:00.280677+07	ASII	2011.049520202628	43232	BBCA	BMRI	HAKI
2026-07-11 08:37:00.280677+07	ASII	2015.4911041170349	43843	BBCA	BMRI	HAKA
2026-07-11 07:37:00.280677+07	ASII	2012.5345678746496	65902	BBCA	BMRI	HAKI
2026-07-11 06:33:00.280677+07	ASII	2015.5565261360427	41860	BBCA	BMRI	HAKA
2026-07-11 05:40:00.280677+07	ASII	2012.5933796237077	47108	BBCA	BMRI	HAKI
2026-07-11 04:35:00.280677+07	ASII	2013.8622824956474	54445	BBCA	BMRI	HAKA
2026-07-11 03:47:00.280677+07	ASII	2012.784022684181	59568	BBCA	BMRI	HAKI
2026-07-11 02:31:00.280677+07	ASII	2010.8947806112521	33744	BBCA	BMRI	HAKI
2026-07-11 01:23:00.280677+07	ASII	2007.160749097234	42045	BBCA	BMRI	HAKI
2026-07-11 00:33:00.280677+07	ASII	2011.7374228497335	46516	BBCA	BMRI	HAKA
2026-07-10 23:38:00.280677+07	ASII	2021.0415698652614	57883	BBCA	BMRI	HAKA
2026-07-10 22:12:00.280677+07	ASII	2024.4355740216026	25227	BBCA	BMRI	HAKA
2026-07-10 21:32:00.280677+07	ASII	2023.8067366000346	60810	BBCA	BMRI	HAKI
2026-07-10 20:29:00.280677+07	ASII	2021.661303911136	71847	BBCA	BMRI	HAKI
2026-07-10 19:55:00.280677+07	ASII	2020.7011922296763	46950	BBCA	BMRI	HAKI
2026-07-10 18:24:00.280677+07	ASII	2014.659079623075	45365	BBCA	BMRI	HAKI
2026-07-10 17:38:00.280677+07	ASII	2015.7970043982086	59807	BBCA	BMRI	HAKA
2026-07-10 16:14:00.280677+07	ASII	2010.278505119023	35411	BBCA	BMRI	HAKI
2026-07-10 15:59:00.280677+07	ASII	2006.8676694420537	28531	BBCA	BMRI	HAKI
2026-07-12 10:28:00.280677+07	ASII	2002.3201343892151	41647	BBCA	BMRI	HAKI
2026-07-12 10:00:00.280677+07	ASII	2002.9772152546539	36201	BBCA	BMRI	HAKA
2026-07-12 08:16:00.280677+07	ASII	2003.6880693521323	57269	BBCA	BMRI	HAKA
2026-07-12 07:11:00.280677+07	ASII	2003.2809254955068	50845	BBCA	BMRI	HAKI
2026-07-12 07:02:00.280677+07	ASII	1997.47136866088	57721	BBCA	BMRI	HAKI
2026-07-12 05:58:00.280677+07	ASII	1990.735937269862	69766	BBCA	BMRI	HAKI
2026-07-12 04:51:00.280677+07	ASII	1991.9085424635837	59467	BBCA	BMRI	HAKA
2026-07-12 03:09:00.280677+07	ASII	1994.0195905777477	52986	BBCA	BMRI	HAKA
2026-07-12 02:39:00.280677+07	ASII	1996.704708052138	37483	BBCA	BMRI	HAKA
2026-07-12 01:26:00.280677+07	ASII	1993.8406001173735	42270	BBCA	BMRI	HAKI
2026-07-12 00:32:00.280677+07	ASII	1992.3290786499372	51919	BBCA	BMRI	HAKI
2026-07-11 23:57:00.280677+07	ASII	1992.0037523087349	49393	BBCA	BMRI	HAKI
2026-07-11 22:13:00.280677+07	ASII	1996.2151293617956	56486	BBCA	BMRI	HAKA
2026-07-11 21:26:00.280677+07	ASII	2001.99761490695	44126	BBCA	BMRI	HAKA
2026-07-11 20:09:00.280677+07	ASII	2005.7479931952764	66240	BBCA	BMRI	HAKA
2026-07-11 19:11:00.280677+07	ASII	2002.011088748525	43723	BBCA	BMRI	HAKI
2026-07-11 19:00:00.280677+07	ASII	1996.8261021439548	55796	BBCA	BMRI	HAKI
2026-07-11 17:35:00.280677+07	ASII	1997.4487486141536	43716	BBCA	BMRI	HAKA
2026-07-11 16:54:00.280677+07	ASII	1999.0398258426344	33385	BBCA	BMRI	HAKA
2026-07-11 16:04:00.280677+07	ASII	1996.5298949662786	35345	BBCA	BMRI	HAKI
2026-07-13 10:54:00.280677+07	ASII	1987.2955823351501	48960	BBCA	BMRI	HAKI
2026-07-13 10:04:00.280677+07	ASII	1989.4670795865006	49372	BBCA	BMRI	HAKA
2026-07-13 08:44:00.280677+07	ASII	1987.9913120430588	47447	BBCA	BMRI	HAKI
2026-07-13 07:25:00.280677+07	ASII	1994.6595333822165	46161	BBCA	BMRI	HAKA
2026-07-13 06:09:00.280677+07	ASII	1990.781550455259	44492	BBCA	BMRI	HAKI
2026-07-13 05:38:00.280677+07	ASII	1990.5994785832202	36132	BBCA	BMRI	HAKI
2026-07-13 04:49:00.280677+07	ASII	1985.9201559264654	65725	BBCA	BMRI	HAKI
2026-07-13 03:42:00.280677+07	ASII	1989.7042562063623	52549	BBCA	BMRI	HAKA
2026-07-13 02:52:00.280677+07	ASII	1993.8023711926883	58159	BBCA	BMRI	HAKA
2026-07-13 01:20:00.280677+07	ASII	1996.774106093231	59002	BBCA	BMRI	HAKA
2026-07-13 00:55:00.280677+07	ASII	1992.5418888301338	41515	BBCA	BMRI	HAKI
2026-07-12 23:49:00.280677+07	ASII	1993.7531117745007	30410	BBCA	BMRI	HAKA
2026-07-12 22:22:00.280677+07	ASII	1991.4303086040306	34492	BBCA	BMRI	HAKI
2026-07-12 21:48:00.280677+07	ASII	1995.1975792162436	51884	BBCA	BMRI	HAKA
2026-07-12 20:52:00.280677+07	ASII	1994.9311185289887	69374	BBCA	BMRI	HAKI
2026-07-12 19:14:00.280677+07	ASII	1989.321626319806	42897	BBCA	BMRI	HAKI
2026-07-12 19:04:00.280677+07	ASII	1987.0045022769216	49651	BBCA	BMRI	HAKI
2026-07-12 17:54:00.280677+07	ASII	1984.191127547399	58672	BBCA	BMRI	HAKI
2026-07-12 16:28:00.280677+07	ASII	1982.3584494216695	46908	BBCA	BMRI	HAKI
2026-07-12 15:09:00.280677+07	ASII	1983.456326629825	52207	BBCA	BMRI	HAKA
2026-07-14 10:14:00.280677+07	ASII	1986.7125992610527	57442	BBCA	BMRI	HAKA
2026-07-14 09:20:00.280677+07	ASII	1981.722139296731	56059	BBCA	BMRI	HAKI
2026-07-14 08:30:00.280677+07	ASII	1987.583233487641	41370	BBCA	BMRI	HAKA
2026-07-14 07:22:00.280677+07	ASII	1985.1466441462521	43546	BBCA	BMRI	HAKI
2026-07-14 07:02:00.280677+07	ASII	1982.1298886317431	52690	BBCA	BMRI	HAKI
2026-07-14 05:56:00.280677+07	ASII	1985.5702860706454	32419	BBCA	BMRI	HAKA
2026-07-14 04:33:00.280677+07	ASII	1979.8114449077877	37542	BBCA	BMRI	HAKI
2026-07-14 04:01:00.280677+07	ASII	1983.113732155956	45826	BBCA	BMRI	HAKA
2026-07-14 02:19:00.280677+07	ASII	1984.8445753817737	45888	BBCA	BMRI	HAKA
2026-07-14 01:31:00.280677+07	ASII	1984.6310978013128	46495	BBCA	BMRI	HAKI
2026-07-14 00:48:00.280677+07	ASII	1981.0619793927028	51523	BBCA	BMRI	HAKI
2026-07-13 23:37:00.280677+07	ASII	1982.3166757995707	52354	BBCA	BMRI	HAKA
2026-07-13 22:13:00.280677+07	ASII	1981.8177276814986	60821	BBCA	BMRI	HAKI
2026-07-13 21:17:00.280677+07	ASII	1984.2538861382923	39425	BBCA	BMRI	HAKA
2026-07-13 20:44:00.280677+07	ASII	1981.680938533186	59425	BBCA	BMRI	HAKI
2026-07-13 19:28:00.280677+07	ASII	1975.8486315713963	25297	BBCA	BMRI	HAKI
2026-07-13 18:58:00.280677+07	ASII	1976.2721934974224	38696	BBCA	BMRI	HAKA
2026-07-13 17:43:00.280677+07	ASII	1976.5158439405557	41496	BBCA	BMRI	HAKA
2026-07-13 16:45:00.280677+07	ASII	1973.1740665551679	49137	BBCA	BMRI	HAKI
2026-07-13 16:03:00.280677+07	ASII	1979.175056764387	60732	BBCA	BMRI	HAKA
2026-07-09 10:13:19.336736+07	BBCA	4055.087930031655	57487	BBCA	BMRI	HAKA
2026-07-09 09:10:19.336736+07	BBCA	4058.99997987875	61489	BBCA	BMRI	HAKA
2026-07-09 09:05:19.336736+07	BBCA	4077.650494294626	51261	BBCA	BMRI	HAKA
2026-07-09 08:02:19.336736+07	BBCA	4075.2194410271045	57607	BBCA	BMRI	HAKI
2026-07-10 10:32:19.336736+07	BBCA	4061.151631292293	61131	BBCA	BMRI	HAKA
2026-07-10 09:39:19.336736+07	BBCA	4058.216545089174	44156	BBCA	BMRI	HAKI
2026-07-10 08:30:19.336736+07	BBCA	4069.4403846482687	44604	BBCA	BMRI	HAKA
2026-07-10 08:02:19.336736+07	BBCA	4086.5883203074814	54285	BBCA	BMRI	HAKA
2026-07-10 06:44:19.336736+07	BBCA	4085.0872606147095	59689	BBCA	BMRI	HAKI
2026-07-10 05:32:19.336736+07	BBCA	4076.7562612561164	37187	BBCA	BMRI	HAKI
2026-07-10 04:07:19.336736+07	BBCA	4074.947876744412	69710	BBCA	BMRI	HAKI
2026-07-10 03:57:19.336736+07	BBCA	4082.0178861284244	62319	BBCA	BMRI	HAKA
2026-07-10 02:55:19.336736+07	BBCA	4090.6314303226554	71770	BBCA	BMRI	HAKA
2026-07-10 01:32:19.336736+07	BBCA	4096.28576126051	61517	BBCA	BMRI	HAKA
2026-07-10 00:15:19.336736+07	BBCA	4087.725305538182	53109	BBCA	BMRI	HAKI
2026-07-09 23:15:19.336736+07	BBCA	4102.689028132397	41908	BBCA	BMRI	HAKA
2026-07-09 22:24:19.336736+07	BBCA	4095.641484755823	61087	BBCA	BMRI	HAKI
2026-07-09 21:36:19.336736+07	BBCA	4097.253182400324	47090	BBCA	BMRI	HAKA
2026-07-09 21:04:19.336736+07	BBCA	4110.741084305291	52899	BBCA	BMRI	HAKA
2026-07-09 19:40:19.336736+07	BBCA	4115.000842316028	59071	BBCA	BMRI	HAKA
2026-07-09 18:57:19.336736+07	BBCA	4115.543262375965	46555	BBCA	BMRI	HAKA
2026-07-09 17:29:19.336736+07	BBCA	4122.757767358728	52341	BBCA	BMRI	HAKA
2026-07-09 16:41:19.336736+07	BBCA	4113.6923229259955	43397	BBCA	BMRI	HAKI
2026-07-09 15:16:19.336736+07	BBCA	4110.634045749544	51926	BBCA	BMRI	HAKI
2026-07-11 10:42:19.336736+07	BBCA	4118.084693434093	40563	BBCA	BMRI	HAKA
2026-07-11 09:48:19.336736+07	BBCA	4119.584150308317	41137	BBCA	BMRI	HAKA
2026-07-11 09:05:19.336736+07	BBCA	4116.326508971683	44386	BBCA	BMRI	HAKI
2026-07-11 07:51:19.336736+07	BBCA	4120.113434473874	49646	BBCA	BMRI	HAKA
2026-07-11 06:16:19.336736+07	BBCA	4127.101467554937	40211	BBCA	BMRI	HAKA
2026-07-11 05:32:19.336736+07	BBCA	4116.9278042908845	57887	BBCA	BMRI	HAKI
2026-07-11 04:11:19.336736+07	BBCA	4121.428837876775	48365	BBCA	BMRI	HAKA
2026-07-11 03:43:19.336736+07	BBCA	4117.625886495599	53164	BBCA	BMRI	HAKI
2026-07-11 02:28:19.336736+07	BBCA	4116.381241566916	55453	BBCA	BMRI	HAKI
2026-07-11 01:45:19.336736+07	BBCA	4126.100748588737	48582	BBCA	BMRI	HAKA
2026-07-11 00:31:19.336736+07	BBCA	4126.2636495967545	48244	BBCA	BMRI	HAKA
2026-07-10 23:13:19.336736+07	BBCA	4139.889810721334	56506	BBCA	BMRI	HAKA
2026-07-10 22:12:19.336736+07	BBCA	4138.058698401809	52626	BBCA	BMRI	HAKI
2026-07-10 21:06:19.336736+07	BBCA	4126.918676056146	45397	BBCA	BMRI	HAKI
2026-07-10 20:08:19.336736+07	BBCA	4133.844772055634	45945	BBCA	BMRI	HAKA
2026-07-10 19:22:19.336736+07	BBCA	4129.3014502800115	42580	BBCA	BMRI	HAKI
2026-07-10 18:09:19.336736+07	BBCA	4136.6519808157345	47836	BBCA	BMRI	HAKA
2026-07-10 17:09:19.336736+07	BBCA	4150.661282567177	47155	BBCA	BMRI	HAKA
2026-07-10 16:07:19.336736+07	BBCA	4148.161271433344	68940	BBCA	BMRI	HAKI
2026-07-10 15:28:19.336736+07	BBCA	4151.564459474833	53599	BBCA	BMRI	HAKA
2026-07-12 10:30:19.336736+07	BBCA	4149.823566924136	56273	BBCA	BMRI	HAKI
2026-07-12 10:04:19.336736+07	BBCA	4146.496951646757	47188	BBCA	BMRI	HAKI
2026-07-12 08:20:19.336736+07	BBCA	4135.416455058718	57135	BBCA	BMRI	HAKI
2026-07-12 07:17:19.336736+07	BBCA	4126.915521346678	52817	BBCA	BMRI	HAKI
2026-07-12 06:10:19.336736+07	BBCA	4126.9996514562745	54467	BBCA	BMRI	HAKA
2026-07-12 05:48:19.336736+07	BBCA	4138.901115510703	56406	BBCA	BMRI	HAKA
2026-07-12 05:03:19.336736+07	BBCA	4132.800598935823	60877	BBCA	BMRI	HAKI
2026-07-12 03:31:19.336736+07	BBCA	4142.85078249192	35791	BBCA	BMRI	HAKA
2026-07-12 02:30:19.336736+07	BBCA	4135.6403740383275	44634	BBCA	BMRI	HAKI
2026-07-12 01:39:19.336736+07	BBCA	4152.067563128897	35491	BBCA	BMRI	HAKA
2026-07-12 00:16:19.336736+07	BBCA	4146.839570698144	53472	BBCA	BMRI	HAKI
2026-07-11 23:22:19.336736+07	BBCA	4150.394324931513	56975	BBCA	BMRI	HAKA
2026-07-11 22:26:19.336736+07	BBCA	4150.0720275717495	53355	BBCA	BMRI	HAKI
2026-07-11 21:59:19.336736+07	BBCA	4159.103794796718	55861	BBCA	BMRI	HAKA
2026-07-11 20:48:19.336736+07	BBCA	4154.959273790692	52215	BBCA	BMRI	HAKI
2026-07-11 19:55:19.336736+07	BBCA	4167.62198038326	47678	BBCA	BMRI	HAKA
2026-07-11 18:27:19.336736+07	BBCA	4173.82000057543	57539	BBCA	BMRI	HAKA
2026-07-11 17:36:19.336736+07	BBCA	4184.30982584667	42262	BBCA	BMRI	HAKA
2026-07-11 16:26:19.336736+07	BBCA	4180.966227672712	37786	BBCA	BMRI	HAKI
2026-07-11 15:13:19.336736+07	BBCA	4172.520207189578	55152	BBCA	BMRI	HAKI
2026-07-13 10:16:19.336736+07	BBCA	4181.413171304222	39257	BBCA	BMRI	HAKA
2026-07-13 09:54:19.336736+07	BBCA	4195.26948230023	38877	BBCA	BMRI	HAKA
2026-07-13 09:00:19.336736+07	BBCA	4186.566684677868	47249	BBCA	BMRI	HAKI
2026-07-13 08:01:19.336736+07	BBCA	4183.338794731505	40015	BBCA	BMRI	HAKI
2026-07-13 06:16:19.336736+07	BBCA	4177.886405307323	43851	BBCA	BMRI	HAKI
2026-07-13 05:45:19.336736+07	BBCA	4157.641404174148	49419	BBCA	BMRI	HAKI
2026-07-13 04:53:19.336736+07	BBCA	4161.265357827223	41451	BBCA	BMRI	HAKA
2026-07-13 03:37:19.336736+07	BBCA	4172.939131946291	63520	BBCA	BMRI	HAKA
2026-07-13 02:56:19.336736+07	BBCA	4177.539899530471	36160	BBCA	BMRI	HAKA
2026-07-13 01:25:19.336736+07	BBCA	4181.800197482453	49598	BBCA	BMRI	HAKA
2026-07-13 00:24:19.336736+07	BBCA	4188.322613661007	57263	BBCA	BMRI	HAKA
2026-07-12 23:33:19.336736+07	BBCA	4181.458048647956	61828	BBCA	BMRI	HAKI
2026-07-12 22:13:19.336736+07	BBCA	4164.898085548627	51413	BBCA	BMRI	HAKI
2026-07-12 21:25:19.336736+07	BBCA	4166.599784321889	60076	BBCA	BMRI	HAKA
2026-07-12 20:40:19.336736+07	BBCA	4168.762434610721	45376	BBCA	BMRI	HAKA
2026-07-12 19:33:19.336736+07	BBCA	4158.57126588863	44443	BBCA	BMRI	HAKI
2026-07-12 18:50:19.336736+07	BBCA	4168.768570131875	66764	BBCA	BMRI	HAKA
2026-07-12 17:52:19.336736+07	BBCA	4178.739609291003	31501	BBCA	BMRI	HAKA
2026-07-12 16:37:19.336736+07	BBCA	4176.295567349796	65499	BBCA	BMRI	HAKI
2026-07-12 15:36:19.336736+07	BBCA	4184.984656859271	47914	BBCA	BMRI	HAKA
2026-07-14 10:15:19.336736+07	BBCA	4183.725130204711	33796	BBCA	BMRI	HAKI
2026-07-14 09:22:19.336736+07	BBCA	4178.438743238116	41726	BBCA	BMRI	HAKI
2026-07-14 08:16:19.336736+07	BBCA	4182.10466425302	46331	BBCA	BMRI	HAKA
2026-07-14 07:11:19.336736+07	BBCA	4182.305519320587	50840	BBCA	BMRI	HAKA
2026-07-14 06:27:19.336736+07	BBCA	4176.815186459797	44698	BBCA	BMRI	HAKI
2026-07-14 05:52:19.336736+07	BBCA	4174.485215954729	39523	BBCA	BMRI	HAKI
2026-07-14 04:30:19.336736+07	BBCA	4183.033657768078	45658	BBCA	BMRI	HAKA
2026-07-14 03:26:19.336736+07	BBCA	4184.995073520096	52880	BBCA	BMRI	HAKA
2026-07-14 02:56:19.336736+07	BBCA	4197.937412489685	51074	BBCA	BMRI	HAKA
2026-07-14 01:28:19.336736+07	BBCA	4197.555357476211	48058	BBCA	BMRI	HAKI
2026-07-14 01:03:19.336736+07	BBCA	4205.251178704974	60332	BBCA	BMRI	HAKA
2026-07-13 23:56:19.336736+07	BBCA	4200.449895078432	53957	BBCA	BMRI	HAKI
2026-07-13 22:16:19.336736+07	BBCA	4204.443315382055	61615	BBCA	BMRI	HAKA
2026-07-13 21:11:19.336736+07	BBCA	4200.5565089205975	56965	BBCA	BMRI	HAKI
2026-07-13 20:59:19.336736+07	BBCA	4208.403298681185	51369	BBCA	BMRI	HAKA
2026-07-13 19:29:19.336736+07	BBCA	4200.570194117542	52940	BBCA	BMRI	HAKI
2026-07-13 18:57:19.336736+07	BBCA	4202.785550481159	54750	BBCA	BMRI	HAKA
2026-07-13 17:23:19.336736+07	BBCA	4188.42666199415	62641	BBCA	BMRI	HAKI
2026-07-13 16:35:19.336736+07	BBCA	4188.428029587171	46169	BBCA	BMRI	HAKA
2026-07-13 16:05:19.336736+07	BBCA	4202.4457356160865	46527	BBCA	BMRI	HAKA
2026-07-09 10:43:20.623551+07	BBRI	2040.4668230142881	40029	BBCA	BMRI	HAKA
2026-07-09 09:37:20.623551+07	BBRI	2035.008598860167	51958	BBCA	BMRI	HAKI
2026-07-09 08:21:20.623551+07	BBRI	2038.6225390156771	23172	BBCA	BMRI	HAKA
2026-07-09 07:13:20.623551+07	BBRI	2038.2030997076065	35688	BBCA	BMRI	HAKI
2026-07-10 10:19:20.623551+07	BBRI	2023.9846809568512	47069	BBCA	BMRI	HAKI
2026-07-10 09:53:20.623551+07	BBRI	2029.7722137956448	66387	BBCA	BMRI	HAKA
2026-07-10 08:39:20.623551+07	BBRI	2028.9504226163472	48488	BBCA	BMRI	HAKI
2026-07-10 07:48:20.623551+07	BBRI	2034.449344708723	48115	BBCA	BMRI	HAKA
2026-07-10 06:28:20.623551+07	BBRI	2034.9763893231707	79930	BBCA	BMRI	HAKA
2026-07-10 06:01:20.623551+07	BBRI	2038.4135438588023	59385	BBCA	BMRI	HAKA
2026-07-10 04:53:20.623551+07	BBRI	2046.2642977454148	63381	BBCA	BMRI	HAKA
2026-07-10 03:46:20.623551+07	BBRI	2051.9094838345213	56495	BBCA	BMRI	HAKA
2026-07-10 02:20:20.623551+07	BBRI	2045.2794490662343	37712	BBCA	BMRI	HAKI
2026-07-10 02:02:20.623551+07	BBRI	2050.0693072528097	54743	BBCA	BMRI	HAKA
2026-07-10 00:12:20.623551+07	BBRI	2054.638367661855	57922	BBCA	BMRI	HAKA
2026-07-09 23:25:20.623551+07	BBRI	2051.9819266319105	57764	BBCA	BMRI	HAKI
2026-07-09 22:37:20.623551+07	BBRI	2051.067551534638	30052	BBCA	BMRI	HAKI
2026-07-09 21:24:20.623551+07	BBRI	2048.4368791802362	58677	BBCA	BMRI	HAKI
2026-07-09 20:57:20.623551+07	BBRI	2045.8641626092067	66185	BBCA	BMRI	HAKI
2026-07-09 20:02:20.623551+07	BBRI	2045.991471689446	50044	BBCA	BMRI	HAKA
2026-07-09 18:40:20.623551+07	BBRI	2040.7573963534917	33121	BBCA	BMRI	HAKI
2026-07-09 17:25:20.623551+07	BBRI	2038.6079505112382	64940	BBCA	BMRI	HAKI
2026-07-09 16:29:20.623551+07	BBRI	2045.645775316331	44757	BBCA	BMRI	HAKA
2026-07-09 15:25:20.623551+07	BBRI	2047.861744368292	52806	BBCA	BMRI	HAKA
2026-07-11 10:48:20.623551+07	BBRI	2050.692024563276	64350	BBCA	BMRI	HAKA
2026-07-11 09:17:20.623551+07	BBRI	2053.7669952418073	47234	BBCA	BMRI	HAKA
2026-07-11 08:54:20.623551+07	BBRI	2057.673287496265	45179	BBCA	BMRI	HAKA
2026-07-11 07:35:20.623551+07	BBRI	2059.425699901102	48157	BBCA	BMRI	HAKA
2026-07-11 07:04:20.623551+07	BBRI	2052.224383331258	58675	BBCA	BMRI	HAKI
2026-07-11 05:48:20.623551+07	BBRI	2047.821775021005	36776	BBCA	BMRI	HAKI
2026-07-11 04:07:20.623551+07	BBRI	2047.9575278465377	54921	BBCA	BMRI	HAKA
2026-07-11 03:59:20.623551+07	BBRI	2047.882415569831	39369	BBCA	BMRI	HAKI
2026-07-11 02:58:20.623551+07	BBRI	2045.574862931366	42390	BBCA	BMRI	HAKI
2026-07-11 01:53:20.623551+07	BBRI	2047.5717875747994	43130	BBCA	BMRI	HAKA
2026-07-11 01:00:20.623551+07	BBRI	2042.4119654788774	66632	BBCA	BMRI	HAKI
2026-07-10 23:40:20.623551+07	BBRI	2037.9648682372642	50472	BBCA	BMRI	HAKI
2026-07-10 22:19:20.623551+07	BBRI	2035.088646665343	63102	BBCA	BMRI	HAKI
2026-07-10 21:23:20.623551+07	BBRI	2030.1222972813007	50875	BBCA	BMRI	HAKI
2026-07-10 20:30:20.623551+07	BBRI	2030.0501655020535	57403	BBCA	BMRI	HAKI
2026-07-10 19:58:20.623551+07	BBRI	2024.9528852881356	61427	BBCA	BMRI	HAKI
2026-07-10 18:50:20.623551+07	BBRI	2018.6779778776395	53756	BBCA	BMRI	HAKI
2026-07-10 17:16:20.623551+07	BBRI	2012.0862106265924	55331	BBCA	BMRI	HAKI
2026-07-10 16:09:20.623551+07	BBRI	2015.1965358974667	44981	BBCA	BMRI	HAKA
2026-07-10 15:07:20.623551+07	BBRI	2018.3140449205584	31163	BBCA	BMRI	HAKA
2026-07-12 10:37:20.623551+07	BBRI	2021.2914507985956	55133	BBCA	BMRI	HAKA
2026-07-12 09:16:20.623551+07	BBRI	2024.4357557763633	45752	BBCA	BMRI	HAKA
2026-07-12 08:07:20.623551+07	BBRI	2020.3469186090997	42508	BBCA	BMRI	HAKI
2026-07-12 07:59:20.623551+07	BBRI	2022.1059783984597	54910	BBCA	BMRI	HAKA
2026-07-12 06:06:20.623551+07	BBRI	2025.0758682030735	51488	BBCA	BMRI	HAKA
2026-07-12 05:20:20.623551+07	BBRI	2026.674192080794	69917	BBCA	BMRI	HAKA
2026-07-12 04:49:20.623551+07	BBRI	2023.0647093361283	46432	BBCA	BMRI	HAKI
2026-07-12 03:38:20.623551+07	BBRI	2026.174664966095	51673	BBCA	BMRI	HAKA
2026-07-12 02:52:20.623551+07	BBRI	2026.7249347980787	45532	BBCA	BMRI	HAKA
2026-07-12 01:39:20.623551+07	BBRI	2032.5176056733744	44903	BBCA	BMRI	HAKA
2026-07-12 00:58:20.623551+07	BBRI	2033.5723727793622	52401	BBCA	BMRI	HAKA
2026-07-11 23:56:20.623551+07	BBRI	2033.813519047065	48702	BBCA	BMRI	HAKA
2026-07-11 22:46:20.623551+07	BBRI	2039.116922690929	46074	BBCA	BMRI	HAKA
2026-07-11 21:21:20.623551+07	BBRI	2042.691580850143	42765	BBCA	BMRI	HAKA
2026-07-11 20:30:20.623551+07	BBRI	2044.57699668746	39790	BBCA	BMRI	HAKA
2026-07-11 19:55:20.623551+07	BBRI	2045.2634797962417	57686	BBCA	BMRI	HAKA
2026-07-11 18:30:20.623551+07	BBRI	2045.7348919645906	51932	BBCA	BMRI	HAKA
2026-07-11 18:05:20.623551+07	BBRI	2042.5201709437017	33552	BBCA	BMRI	HAKI
2026-07-11 16:22:20.623551+07	BBRI	2052.3147096595562	62995	BBCA	BMRI	HAKA
2026-07-11 15:48:20.623551+07	BBRI	2056.7648290749657	25780	BBCA	BMRI	HAKA
2026-07-13 10:46:20.623551+07	BBRI	2052.355249344864	58427	BBCA	BMRI	HAKI
2026-07-13 09:27:20.623551+07	BBRI	2057.0502261556094	45612	BBCA	BMRI	HAKA
2026-07-13 08:26:20.623551+07	BBRI	2059.7039674196317	56240	BBCA	BMRI	HAKA
2026-07-13 07:07:20.623551+07	BBRI	2053.370144754019	46658	BBCA	BMRI	HAKI
2026-07-13 06:59:20.623551+07	BBRI	2052.785294444246	44070	BBCA	BMRI	HAKI
2026-07-13 05:51:20.623551+07	BBRI	2049.5401031966853	42966	BBCA	BMRI	HAKI
2026-07-13 04:16:20.623551+07	BBRI	2047.8324331986632	59090	BBCA	BMRI	HAKI
2026-07-13 03:08:20.623551+07	BBRI	2050.1260971273173	36331	BBCA	BMRI	HAKA
2026-07-13 02:35:20.623551+07	BBRI	2047.7935829524306	76925	BBCA	BMRI	HAKI
2026-07-13 01:40:20.623551+07	BBRI	2049.7828331094447	47778	BBCA	BMRI	HAKA
2026-07-13 00:59:20.623551+07	BBRI	2062.3143985402107	47353	BBCA	BMRI	HAKA
2026-07-12 23:33:20.623551+07	BBRI	2058.7035236746924	63034	BBCA	BMRI	HAKI
2026-07-12 22:39:20.623551+07	BBRI	2054.4104148709716	64082	BBCA	BMRI	HAKI
2026-07-12 21:39:20.623551+07	BBRI	2047.5346055743778	63071	BBCA	BMRI	HAKI
2026-07-12 20:37:20.623551+07	BBRI	2043.0142386254925	40609	BBCA	BMRI	HAKI
2026-07-12 19:32:20.623551+07	BBRI	2042.2062370027127	36696	BBCA	BMRI	HAKI
2026-07-12 18:10:20.623551+07	BBRI	2046.1102308732625	35288	BBCA	BMRI	HAKA
2026-07-12 17:53:20.623551+07	BBRI	2044.0530769429947	49449	BBCA	BMRI	HAKI
2026-07-12 16:33:20.623551+07	BBRI	2046.299020459652	50616	BBCA	BMRI	HAKA
2026-07-12 15:48:20.623551+07	BBRI	2053.2924017935998	45907	BBCA	BMRI	HAKA
2026-07-14 10:29:20.623551+07	BBRI	2051.5857137699413	31311	BBCA	BMRI	HAKI
2026-07-14 09:50:20.623551+07	BBRI	2048.393387005333	56817	BBCA	BMRI	HAKI
2026-07-14 08:25:20.623551+07	BBRI	2052.689261987644	47424	BBCA	BMRI	HAKA
2026-07-14 07:39:20.623551+07	BBRI	2050.6003685129695	55652	BBCA	BMRI	HAKI
2026-07-14 06:36:20.623551+07	BBRI	2049.6790826839306	39114	BBCA	BMRI	HAKI
2026-07-14 05:08:20.623551+07	BBRI	2056.2779045135244	49305	BBCA	BMRI	HAKA
2026-07-14 04:08:20.623551+07	BBRI	2056.2380711334326	60187	BBCA	BMRI	HAKI
2026-07-14 03:51:20.623551+07	BBRI	2057.6615073007283	49083	BBCA	BMRI	HAKA
2026-07-14 02:44:20.623551+07	BBRI	2054.782307750731	53248	BBCA	BMRI	HAKI
2026-07-14 02:05:20.623551+07	BBRI	2048.3557222239024	47280	BBCA	BMRI	HAKI
2026-07-14 00:51:20.623551+07	BBRI	2048.1658325919466	59045	BBCA	BMRI	HAKI
2026-07-13 23:35:20.623551+07	BBRI	2040.7147336592423	47023	BBCA	BMRI	HAKI
2026-07-13 22:30:20.623551+07	BBRI	2044.8365787750192	51834	BBCA	BMRI	HAKA
2026-07-13 21:25:20.623551+07	BBRI	2044.9441648234456	37439	BBCA	BMRI	HAKA
2026-07-13 20:54:20.623551+07	BBRI	2047.3439801332875	63548	BBCA	BMRI	HAKA
2026-07-13 19:58:20.623551+07	BBRI	2042.3841108225306	47350	BBCA	BMRI	HAKI
2026-07-13 18:38:20.623551+07	BBRI	2041.486961752089	55892	BBCA	BMRI	HAKI
2026-07-13 17:53:20.623551+07	BBRI	2044.2577590273593	55862	BBCA	BMRI	HAKA
2026-07-13 16:15:20.623551+07	BBRI	2051.972226573882	49828	BBCA	BMRI	HAKA
2026-07-13 15:10:20.623551+07	BBRI	2052.3976916543384	52257	BBCA	BMRI	HAKA
2026-07-09 10:35:21.902439+07	BMRI	5934.22614035071	60017	BBCA	BMRI	HAKI
2026-07-09 10:02:21.902439+07	BMRI	5935.868317637111	46902	BBCA	BMRI	HAKA
2026-07-09 08:22:21.902439+07	BMRI	5934.611587271323	54301	BBCA	BMRI	HAKI
2026-07-09 07:15:21.902439+07	BMRI	5946.058000145852	56095	BBCA	BMRI	HAKA
2026-07-10 10:47:21.902439+07	BMRI	5939.801063299299	58399	BBCA	BMRI	HAKI
2026-07-10 10:02:21.902439+07	BMRI	5934.333476478173	19058	BBCA	BMRI	HAKI
2026-07-10 08:55:21.902439+07	BMRI	5951.843198354054	72077	BBCA	BMRI	HAKA
2026-07-10 07:24:21.902439+07	BMRI	5963.513359139166	43872	BBCA	BMRI	HAKA
2026-07-10 06:58:21.902439+07	BMRI	5948.723387363104	62841	BBCA	BMRI	HAKI
2026-07-10 05:45:21.902439+07	BMRI	5951.638124103234	66877	BBCA	BMRI	HAKA
2026-07-10 04:44:21.902439+07	BMRI	5953.817257707585	53390	BBCA	BMRI	HAKA
2026-07-10 03:26:21.902439+07	BMRI	5960.715189175644	54285	BBCA	BMRI	HAKA
2026-07-10 02:51:21.902439+07	BMRI	5943.654564635749	57026	BBCA	BMRI	HAKI
2026-07-10 01:45:21.902439+07	BMRI	5957.55255481925	44664	BBCA	BMRI	HAKA
2026-07-10 00:42:21.902439+07	BMRI	5937.702146369538	56683	BBCA	BMRI	HAKI
2026-07-09 23:58:21.902439+07	BMRI	5929.279108387388	48705	BBCA	BMRI	HAKI
2026-07-09 22:30:21.902439+07	BMRI	5937.413220586199	38589	BBCA	BMRI	HAKA
2026-07-09 21:57:21.902439+07	BMRI	5929.735553137786	58290	BBCA	BMRI	HAKI
2026-07-09 20:24:21.902439+07	BMRI	5945.371584623597	51030	BBCA	BMRI	HAKA
2026-07-09 19:12:21.902439+07	BMRI	5939.612629382447	56651	BBCA	BMRI	HAKI
2026-07-09 18:24:21.902439+07	BMRI	5925.0669992678995	36772	BBCA	BMRI	HAKI
2026-07-09 17:33:21.902439+07	BMRI	5925.831346298004	59407	BBCA	BMRI	HAKA
2026-07-09 16:12:21.902439+07	BMRI	5903.22099978051	35735	BBCA	BMRI	HAKI
2026-07-09 15:52:21.902439+07	BMRI	5907.844195747459	50905	BBCA	BMRI	HAKA
2026-07-11 10:32:21.902439+07	BMRI	5877.737660955167	56450	BBCA	BMRI	HAKI
2026-07-11 09:38:21.902439+07	BMRI	5872.3978273629755	59154	BBCA	BMRI	HAKI
2026-07-11 08:29:21.902439+07	BMRI	5857.134612335449	49467	BBCA	BMRI	HAKI
2026-07-11 07:52:21.902439+07	BMRI	5863.292615318181	58466	BBCA	BMRI	HAKA
2026-07-11 06:35:21.902439+07	BMRI	5850.040028891487	48331	BBCA	BMRI	HAKI
2026-07-11 05:10:21.902439+07	BMRI	5832.971656752654	48896	BBCA	BMRI	HAKI
2026-07-11 04:52:21.902439+07	BMRI	5829.336389335327	62828	BBCA	BMRI	HAKI
2026-07-11 03:26:21.902439+07	BMRI	5850.292373853755	53830	BBCA	BMRI	HAKA
2026-07-11 02:35:21.902439+07	BMRI	5844.665650055442	52347	BBCA	BMRI	HAKI
2026-07-11 01:29:21.902439+07	BMRI	5852.486534838508	53191	BBCA	BMRI	HAKA
2026-07-11 00:50:21.902439+07	BMRI	5859.313842335791	36084	BBCA	BMRI	HAKA
2026-07-10 23:54:21.902439+07	BMRI	5854.1427728932595	37238	BBCA	BMRI	HAKI
2026-07-10 22:58:21.902439+07	BMRI	5855.215393317588	29701	BBCA	BMRI	HAKA
2026-07-10 21:27:21.902439+07	BMRI	5852.720966685745	42275	BBCA	BMRI	HAKI
2026-07-10 20:46:21.902439+07	BMRI	5814.695567931306	67561	BBCA	BMRI	HAKI
2026-07-10 19:34:21.902439+07	BMRI	5824.045560526558	48322	BBCA	BMRI	HAKA
2026-07-10 18:34:21.902439+07	BMRI	5840.30780690407	56723	BBCA	BMRI	HAKA
2026-07-10 17:46:21.902439+07	BMRI	5839.1675713004315	38953	BBCA	BMRI	HAKI
2026-07-10 16:29:21.902439+07	BMRI	5854.639476591808	45847	BBCA	BMRI	HAKA
2026-07-10 15:53:21.902439+07	BMRI	5855.760791615291	36476	BBCA	BMRI	HAKA
2026-07-12 10:09:21.902439+07	BMRI	5859.615088672953	48289	BBCA	BMRI	HAKA
2026-07-12 09:23:21.902439+07	BMRI	5866.395244071181	37199	BBCA	BMRI	HAKA
2026-07-12 08:30:21.902439+07	BMRI	5864.885023196555	47103	BBCA	BMRI	HAKI
2026-07-12 07:52:21.902439+07	BMRI	5855.0514233611	39316	BBCA	BMRI	HAKI
2026-07-12 06:16:21.902439+07	BMRI	5857.457417933864	46538	BBCA	BMRI	HAKA
2026-07-12 05:37:21.902439+07	BMRI	5861.605341984186	24197	BBCA	BMRI	HAKA
2026-07-12 04:27:21.902439+07	BMRI	5866.505568375869	42917	BBCA	BMRI	HAKA
2026-07-12 03:57:21.902439+07	BMRI	5868.107540025405	38402	BBCA	BMRI	HAKA
2026-07-12 02:52:21.902439+07	BMRI	5887.5458523802945	45466	BBCA	BMRI	HAKA
2026-07-12 01:10:21.902439+07	BMRI	5900.459063458315	62024	BBCA	BMRI	HAKA
2026-07-12 00:52:21.902439+07	BMRI	5901.432798611476	64424	BBCA	BMRI	HAKA
2026-07-11 23:21:21.902439+07	BMRI	5913.127439452432	54205	BBCA	BMRI	HAKA
2026-07-11 23:01:21.902439+07	BMRI	5896.28337293586	65159	BBCA	BMRI	HAKI
2026-07-11 21:43:21.902439+07	BMRI	5892.7409877355085	62060	BBCA	BMRI	HAKI
2026-07-11 20:51:21.902439+07	BMRI	5884.889491332939	53681	BBCA	BMRI	HAKI
2026-07-11 19:58:21.902439+07	BMRI	5890.753202698208	49239	BBCA	BMRI	HAKA
2026-07-11 18:44:21.902439+07	BMRI	5899.666275724994	70651	BBCA	BMRI	HAKA
2026-07-11 17:28:21.902439+07	BMRI	5909.308023891838	60419	BBCA	BMRI	HAKA
2026-07-11 17:00:21.902439+07	BMRI	5916.953073768943	56324	BBCA	BMRI	HAKA
2026-07-11 15:09:21.902439+07	BMRI	5910.765309114627	41608	BBCA	BMRI	HAKI
2026-07-13 10:24:21.902439+07	BMRI	5901.444033590497	44777	BBCA	BMRI	HAKI
2026-07-13 09:55:21.902439+07	BMRI	5891.267396058911	37209	BBCA	BMRI	HAKI
2026-07-13 08:56:21.902439+07	BMRI	5883.965463587516	52594	BBCA	BMRI	HAKI
2026-07-13 07:59:21.902439+07	BMRI	5883.9794829660295	29519	BBCA	BMRI	HAKA
2026-07-13 06:17:21.902439+07	BMRI	5865.736774165334	45389	BBCA	BMRI	HAKI
2026-07-13 05:42:21.902439+07	BMRI	5860.769215918721	45095	BBCA	BMRI	HAKI
2026-07-13 05:01:21.902439+07	BMRI	5869.4534388812235	57094	BBCA	BMRI	HAKA
2026-07-13 03:31:21.902439+07	BMRI	5882.593973920152	41518	BBCA	BMRI	HAKA
2026-07-13 02:57:21.902439+07	BMRI	5885.7113889481925	48772	BBCA	BMRI	HAKA
2026-07-13 01:37:21.902439+07	BMRI	5874.591957212991	45593	BBCA	BMRI	HAKI
2026-07-13 00:10:21.902439+07	BMRI	5872.697943892861	41365	BBCA	BMRI	HAKI
2026-07-12 23:58:21.902439+07	BMRI	5865.001093147091	36768	BBCA	BMRI	HAKI
2026-07-12 22:14:21.902439+07	BMRI	5888.204741815645	54776	BBCA	BMRI	HAKA
2026-07-12 21:27:21.902439+07	BMRI	5899.598733808794	51734	BBCA	BMRI	HAKA
2026-07-12 20:53:21.902439+07	BMRI	5892.311308911782	50585	BBCA	BMRI	HAKI
2026-07-12 19:16:21.902439+07	BMRI	5901.978634380609	42299	BBCA	BMRI	HAKA
2026-07-12 18:24:21.902439+07	BMRI	5915.766993141819	33787	BBCA	BMRI	HAKA
2026-07-12 17:09:21.902439+07	BMRI	5916.802123030992	43272	BBCA	BMRI	HAKA
2026-07-12 16:25:21.902439+07	BMRI	5923.631085889642	49663	BBCA	BMRI	HAKA
2026-07-12 15:15:21.902439+07	BMRI	5914.262827705574	46272	BBCA	BMRI	HAKI
2026-07-14 11:01:21.902439+07	BMRI	5934.401144993778	65666	BBCA	BMRI	HAKA
2026-07-14 10:04:21.902439+07	BMRI	5935.972836631797	51391	BBCA	BMRI	HAKA
2026-07-14 09:04:21.902439+07	BMRI	5924.6701870353445	54187	BBCA	BMRI	HAKI
2026-07-14 07:26:21.902439+07	BMRI	5920.995786776464	57472	BBCA	BMRI	HAKI
2026-07-14 06:17:21.902439+07	BMRI	5908.5643528692035	70303	BBCA	BMRI	HAKI
2026-07-14 05:12:21.902439+07	BMRI	5893.91478696296	49027	BBCA	BMRI	HAKI
2026-07-14 04:49:21.902439+07	BMRI	5902.5505002676555	70406	BBCA	BMRI	HAKA
2026-07-14 03:54:21.902439+07	BMRI	5911.602625611055	65583	BBCA	BMRI	HAKA
2026-07-14 02:17:21.902439+07	BMRI	5898.2574915064215	44299	BBCA	BMRI	HAKI
2026-07-14 01:30:21.902439+07	BMRI	5905.284778078085	48925	BBCA	BMRI	HAKA
2026-07-14 01:00:21.902439+07	BMRI	5908.428387964312	58770	BBCA	BMRI	HAKA
2026-07-13 23:57:21.902439+07	BMRI	5917.851326252434	27725	BBCA	BMRI	HAKA
2026-07-13 22:46:21.902439+07	BMRI	5895.053326626191	59625	BBCA	BMRI	HAKI
2026-07-13 21:25:21.902439+07	BMRI	5902.742350933892	55920	BBCA	BMRI	HAKA
2026-07-13 20:19:21.902439+07	BMRI	5901.560594198581	60139	BBCA	BMRI	HAKI
2026-07-13 20:00:21.902439+07	BMRI	5903.308931175808	45347	BBCA	BMRI	HAKA
2026-07-13 18:20:21.902439+07	BMRI	5910.456335163453	59295	BBCA	BMRI	HAKA
2026-07-13 18:05:21.902439+07	BMRI	5923.677068220895	53066	BBCA	BMRI	HAKA
2026-07-13 16:27:21.902439+07	BMRI	5909.5927693553895	34749	BBCA	BMRI	HAKI
2026-07-13 15:58:21.902439+07	BMRI	5888.406199180318	53455	BBCA	BMRI	HAKI
2026-07-09 10:38:23.294413+07	TLKM	1476.6496811983382	51724	BBCA	BMRI	HAKA
2026-07-09 09:33:23.294413+07	TLKM	1475.0029587280412	21327	BBCA	BMRI	HAKI
2026-07-09 08:42:23.294413+07	TLKM	1473.6360963655957	54680	BBCA	BMRI	HAKI
2026-07-09 07:33:23.294413+07	TLKM	1473.39577130715	43010	BBCA	BMRI	HAKI
2026-07-09 07:02:23.294413+07	TLKM	1468.218049484249	59969	BBCA	BMRI	HAKI
2026-07-10 10:30:23.294413+07	TLKM	1459.3156145596802	37201	BBCA	BMRI	HAKA
2026-07-10 09:12:23.294413+07	TLKM	1460.9353846918377	40370	BBCA	BMRI	HAKA
2026-07-10 08:40:23.294413+07	TLKM	1459.2871797030919	55450	BBCA	BMRI	HAKI
2026-07-10 07:34:23.294413+07	TLKM	1459.408030866926	50550	BBCA	BMRI	HAKA
2026-07-10 06:32:23.294413+07	TLKM	1458.0655796490678	64151	BBCA	BMRI	HAKI
2026-07-10 05:17:23.294413+07	TLKM	1459.2954897593654	50526	BBCA	BMRI	HAKA
2026-07-10 04:52:23.294413+07	TLKM	1458.2015583184514	56597	BBCA	BMRI	HAKI
2026-07-10 03:13:23.294413+07	TLKM	1456.540660173284	43973	BBCA	BMRI	HAKI
2026-07-10 02:40:23.294413+07	TLKM	1456.5977461116431	46012	BBCA	BMRI	HAKA
2026-07-10 02:05:23.294413+07	TLKM	1457.322955363024	57882	BBCA	BMRI	HAKA
2026-07-10 00:16:23.294413+07	TLKM	1455.691309286965	49530	BBCA	BMRI	HAKI
2026-07-09 23:15:23.294413+07	TLKM	1455.2570357691493	66576	BBCA	BMRI	HAKI
2026-07-09 22:27:23.294413+07	TLKM	1456.03468718495	39967	BBCA	BMRI	HAKA
2026-07-09 21:17:23.294413+07	TLKM	1459.3167807879731	63956	BBCA	BMRI	HAKA
2026-07-09 20:15:23.294413+07	TLKM	1459.4762739007847	73131	BBCA	BMRI	HAKA
2026-07-09 19:06:23.294413+07	TLKM	1454.593947248934	65257	BBCA	BMRI	HAKI
2026-07-09 18:15:23.294413+07	TLKM	1452.7189559974995	44544	BBCA	BMRI	HAKI
2026-07-09 17:30:23.294413+07	TLKM	1454.6931638288447	47258	BBCA	BMRI	HAKA
2026-07-09 16:24:23.294413+07	TLKM	1462.5229709855312	54117	BBCA	BMRI	HAKA
2026-07-09 15:56:23.294413+07	TLKM	1459.3190235738302	48537	BBCA	BMRI	HAKI
2026-07-11 10:37:23.294413+07	TLKM	1462.6032371363754	30835	BBCA	BMRI	HAKA
2026-07-11 10:00:23.294413+07	TLKM	1463.2561410027722	58941	BBCA	BMRI	HAKA
2026-07-11 09:02:23.294413+07	TLKM	1461.795312972541	57211	BBCA	BMRI	HAKI
2026-07-11 07:10:23.294413+07	TLKM	1459.9723721579026	55346	BBCA	BMRI	HAKI
2026-07-11 06:53:23.294413+07	TLKM	1461.595922139434	49834	BBCA	BMRI	HAKA
2026-07-11 05:07:23.294413+07	TLKM	1461.8084527409846	63203	BBCA	BMRI	HAKA
2026-07-11 04:59:23.294413+07	TLKM	1455.9333128943495	64410	BBCA	BMRI	HAKI
2026-07-11 03:41:23.294413+07	TLKM	1460.7961029832761	54350	BBCA	BMRI	HAKA
2026-07-11 02:31:23.294413+07	TLKM	1461.442132667604	54384	BBCA	BMRI	HAKA
2026-07-11 01:46:23.294413+07	TLKM	1460.2488260304308	75905	BBCA	BMRI	HAKI
2026-07-11 00:56:23.294413+07	TLKM	1462.064188988821	58258	BBCA	BMRI	HAKA
2026-07-10 23:58:23.294413+07	TLKM	1462.8209671267555	70740	BBCA	BMRI	HAKA
2026-07-10 22:27:23.294413+07	TLKM	1464.9779557180614	50481	BBCA	BMRI	HAKA
2026-07-10 21:14:23.294413+07	TLKM	1463.7241360145038	52157	BBCA	BMRI	HAKI
2026-07-10 20:26:23.294413+07	TLKM	1463.8130969705	53217	BBCA	BMRI	HAKA
2026-07-10 19:58:23.294413+07	TLKM	1465.141484302501	45190	BBCA	BMRI	HAKA
2026-07-10 18:43:23.294413+07	TLKM	1463.0149941662219	54274	BBCA	BMRI	HAKI
2026-07-10 17:31:23.294413+07	TLKM	1466.7804609207137	41936	BBCA	BMRI	HAKA
2026-07-10 16:07:23.294413+07	TLKM	1467.8079829975547	51955	BBCA	BMRI	HAKA
2026-07-10 15:10:23.294413+07	TLKM	1468.1479132624486	45544	BBCA	BMRI	HAKA
2026-07-12 10:53:23.294413+07	TLKM	1466.0334720579183	57898	BBCA	BMRI	HAKI
2026-07-12 09:59:23.294413+07	TLKM	1465.7157897351392	58294	BBCA	BMRI	HAKI
2026-07-12 08:29:23.294413+07	TLKM	1469.5216527272346	65387	BBCA	BMRI	HAKA
2026-07-12 07:26:23.294413+07	TLKM	1465.5932419217143	38924	BBCA	BMRI	HAKI
2026-07-12 06:36:23.294413+07	TLKM	1470.3101224080297	60231	BBCA	BMRI	HAKA
2026-07-12 05:46:23.294413+07	TLKM	1472.1349197774798	51098	BBCA	BMRI	HAKA
2026-07-12 04:40:23.294413+07	TLKM	1465.4954775820445	54656	BBCA	BMRI	HAKI
2026-07-12 03:40:23.294413+07	TLKM	1462.5844574356354	51004	BBCA	BMRI	HAKI
2026-07-12 02:19:23.294413+07	TLKM	1464.9402829818266	62439	BBCA	BMRI	HAKA
2026-07-12 01:27:23.294413+07	TLKM	1467.6071717999894	54647	BBCA	BMRI	HAKA
2026-07-12 00:09:23.294413+07	TLKM	1464.364500330108	56732	BBCA	BMRI	HAKI
2026-07-11 23:51:23.294413+07	TLKM	1462.4200001243746	55314	BBCA	BMRI	HAKI
2026-07-11 22:37:23.294413+07	TLKM	1463.2726808604368	64781	BBCA	BMRI	HAKA
2026-07-11 21:18:23.294413+07	TLKM	1460.053525631337	52705	BBCA	BMRI	HAKI
2026-07-11 20:35:23.294413+07	TLKM	1461.6995620890136	32119	BBCA	BMRI	HAKA
2026-07-11 19:06:23.294413+07	TLKM	1459.635134358051	39439	BBCA	BMRI	HAKI
2026-07-11 18:22:23.294413+07	TLKM	1456.798946202924	72014	BBCA	BMRI	HAKI
2026-07-11 17:11:23.294413+07	TLKM	1457.0587931042976	44315	BBCA	BMRI	HAKA
2026-07-11 16:47:23.294413+07	TLKM	1454.1356217524958	41723	BBCA	BMRI	HAKI
2026-07-11 15:13:23.294413+07	TLKM	1449.1718689312502	59284	BBCA	BMRI	HAKI
2026-07-13 10:48:23.294413+07	TLKM	1451.4118462391473	58404	BBCA	BMRI	HAKA
2026-07-13 09:21:23.294413+07	TLKM	1450.06543568857	48780	BBCA	BMRI	HAKI
2026-07-13 09:05:23.294413+07	TLKM	1453.592537194623	56991	BBCA	BMRI	HAKA
2026-07-13 07:25:23.294413+07	TLKM	1451.3820158670233	42154	BBCA	BMRI	HAKI
2026-07-13 06:07:23.294413+07	TLKM	1455.0420124546902	38343	BBCA	BMRI	HAKA
2026-07-13 05:58:23.294413+07	TLKM	1451.9299172004712	37556	BBCA	BMRI	HAKI
2026-07-13 05:04:23.294413+07	TLKM	1452.722410390061	66143	BBCA	BMRI	HAKA
2026-07-13 03:12:23.294413+07	TLKM	1453.2667232317276	42821	BBCA	BMRI	HAKA
2026-07-13 02:39:23.294413+07	TLKM	1452.9874770439137	50553	BBCA	BMRI	HAKI
2026-07-13 01:34:23.294413+07	TLKM	1453.5019520026578	57226	BBCA	BMRI	HAKA
2026-07-13 00:26:23.294413+07	TLKM	1454.85915855238	52745	BBCA	BMRI	HAKA
2026-07-12 23:59:23.294413+07	TLKM	1455.0146489681513	59627	BBCA	BMRI	HAKA
2026-07-12 22:24:23.294413+07	TLKM	1454.8672343151218	56284	BBCA	BMRI	HAKI
2026-07-12 21:22:23.294413+07	TLKM	1452.4091784928626	47579	BBCA	BMRI	HAKI
2026-07-12 20:34:23.294413+07	TLKM	1453.1868688076154	44458	BBCA	BMRI	HAKA
2026-07-12 20:00:23.294413+07	TLKM	1452.4410857677524	60699	BBCA	BMRI	HAKI
2026-07-12 18:55:23.294413+07	TLKM	1453.5505172570881	48016	BBCA	BMRI	HAKA
2026-07-12 17:54:23.294413+07	TLKM	1453.5068318384376	42345	BBCA	BMRI	HAKI
2026-07-12 16:45:23.294413+07	TLKM	1453.4821223664571	52676	BBCA	BMRI	HAKI
2026-07-12 15:28:23.294413+07	TLKM	1452.6906150042848	63650	BBCA	BMRI	HAKI
2026-07-14 10:28:23.294413+07	TLKM	1452.955669290278	44121	BBCA	BMRI	HAKA
2026-07-14 09:43:23.294413+07	TLKM	1458.2872164152327	48271	BBCA	BMRI	HAKA
2026-07-14 08:37:23.294413+07	TLKM	1462.0982494007112	32430	BBCA	BMRI	HAKA
2026-07-14 07:07:23.294413+07	TLKM	1463.6720356722317	47485	BBCA	BMRI	HAKA
2026-07-14 06:49:23.294413+07	TLKM	1467.1472281516985	40864	BBCA	BMRI	HAKA
2026-07-14 06:02:23.294413+07	TLKM	1469.949227782363	52776	BBCA	BMRI	HAKA
2026-07-14 04:24:23.294413+07	TLKM	1472.4603117919241	28009	BBCA	BMRI	HAKA
2026-07-14 03:26:23.294413+07	TLKM	1470.9862218360313	39953	BBCA	BMRI	HAKI
2026-07-14 02:42:23.294413+07	TLKM	1470.4083182261375	50798	BBCA	BMRI	HAKI
2026-07-14 02:03:23.294413+07	TLKM	1475.2712626832142	50100	BBCA	BMRI	HAKA
2026-07-14 00:37:23.294413+07	TLKM	1474.4217031584092	40180	BBCA	BMRI	HAKI
2026-07-13 23:21:23.294413+07	TLKM	1474.159712735617	44034	BBCA	BMRI	HAKI
2026-07-13 22:13:23.294413+07	TLKM	1475.5983576255558	38025	BBCA	BMRI	HAKA
2026-07-13 21:07:23.294413+07	TLKM	1477.8907365095297	32936	BBCA	BMRI	HAKA
2026-07-13 20:17:23.294413+07	TLKM	1478.575884411902	39004	BBCA	BMRI	HAKA
2026-07-13 19:35:23.294413+07	TLKM	1476.4989765982084	41605	BBCA	BMRI	HAKI
2026-07-13 18:29:23.294413+07	TLKM	1473.4899445124456	64483	BBCA	BMRI	HAKI
2026-07-13 17:40:23.294413+07	TLKM	1474.312234703155	67860	BBCA	BMRI	HAKA
2026-07-13 16:59:23.294413+07	TLKM	1474.1681303888074	57980	BBCA	BMRI	HAKI
2026-07-13 15:17:23.294413+07	TLKM	1475.1572079900347	73039	BBCA	BMRI	HAKA
2026-07-09 10:38:24.552408+07	ASII	4055.0158206457495	65200	BBCA	BMRI	HAKI
2026-07-09 09:15:24.552408+07	ASII	4057.7384702910804	42186	BBCA	BMRI	HAKA
2026-07-09 08:07:24.552408+07	ASII	4076.19800512673	58007	BBCA	BMRI	HAKA
2026-07-09 07:58:24.552408+07	ASII	4076.865411201602	88424	BBCA	BMRI	HAKA
2026-07-10 10:56:24.552408+07	ASII	4104.029407917588	55184	BBCA	BMRI	HAKI
2026-07-10 09:47:24.552408+07	ASII	4102.075284204796	46702	BBCA	BMRI	HAKI
2026-07-10 08:50:24.552408+07	ASII	4104.219881094596	53720	BBCA	BMRI	HAKA
2026-07-10 07:16:24.552408+07	ASII	4114.059288583415	53547	BBCA	BMRI	HAKA
2026-07-10 06:29:24.552408+07	ASII	4107.407312824063	32046	BBCA	BMRI	HAKI
2026-07-10 05:24:24.552408+07	ASII	4107.36911468598	44413	BBCA	BMRI	HAKI
2026-07-10 04:48:24.552408+07	ASII	4112.47886583143	55248	BBCA	BMRI	HAKA
2026-07-10 03:52:24.552408+07	ASII	4112.849741925667	53697	BBCA	BMRI	HAKA
2026-07-10 02:43:24.552408+07	ASII	4110.549648066601	60503	BBCA	BMRI	HAKI
2026-07-10 02:00:24.552408+07	ASII	4111.83272983851	54733	BBCA	BMRI	HAKA
2026-07-10 00:27:24.552408+07	ASII	4108.807776598188	46151	BBCA	BMRI	HAKI
2026-07-09 23:52:24.552408+07	ASII	4115.281358083855	54392	BBCA	BMRI	HAKA
2026-07-09 22:25:24.552408+07	ASII	4110.64505657465	54249	BBCA	BMRI	HAKI
2026-07-09 21:33:24.552408+07	ASII	4116.6445120665885	53798	BBCA	BMRI	HAKA
2026-07-09 20:35:24.552408+07	ASII	4112.5963897928905	40219	BBCA	BMRI	HAKI
2026-07-09 20:00:24.552408+07	ASII	4109.553385437679	45738	BBCA	BMRI	HAKI
2026-07-09 18:53:24.552408+07	ASII	4101.492450589839	60658	BBCA	BMRI	HAKI
2026-07-09 17:12:24.552408+07	ASII	4106.265231048945	49976	BBCA	BMRI	HAKA
2026-07-09 16:56:24.552408+07	ASII	4100.020680069087	44446	BBCA	BMRI	HAKI
2026-07-09 15:44:24.552408+07	ASII	4093.2174476375926	50990	BBCA	BMRI	HAKI
2026-07-11 10:28:24.552408+07	ASII	4085.818223423702	46445	BBCA	BMRI	HAKI
2026-07-11 09:17:24.552408+07	ASII	4087.161990862386	42494	BBCA	BMRI	HAKA
2026-07-11 08:08:24.552408+07	ASII	4093.65026889189	47784	BBCA	BMRI	HAKA
2026-07-11 07:49:24.552408+07	ASII	4100.749844862711	45757	BBCA	BMRI	HAKA
2026-07-11 06:11:24.552408+07	ASII	4112.402762343633	51699	BBCA	BMRI	HAKA
2026-07-11 05:41:24.552408+07	ASII	4099.625737275631	47895	BBCA	BMRI	HAKI
2026-07-11 04:42:24.552408+07	ASII	4091.165260046733	51305	BBCA	BMRI	HAKI
2026-07-11 03:32:24.552408+07	ASII	4093.2475537968226	40683	BBCA	BMRI	HAKA
2026-07-11 02:08:24.552408+07	ASII	4098.398809539865	59177	BBCA	BMRI	HAKA
2026-07-11 02:00:24.552408+07	ASII	4107.542921406248	26086	BBCA	BMRI	HAKA
2026-07-11 00:22:24.552408+07	ASII	4104.511239174822	50426	BBCA	BMRI	HAKI
2026-07-10 23:21:24.552408+07	ASII	4100.399184537149	43389	BBCA	BMRI	HAKI
2026-07-10 22:50:24.552408+07	ASII	4102.792497682358	48489	BBCA	BMRI	HAKA
2026-07-10 21:51:24.552408+07	ASII	4092.8724587248757	40110	BBCA	BMRI	HAKI
2026-07-10 20:32:24.552408+07	ASII	4087.8229508962504	54566	BBCA	BMRI	HAKI
2026-07-10 19:27:24.552408+07	ASII	4098.336962337268	55246	BBCA	BMRI	HAKA
2026-07-10 19:04:24.552408+07	ASII	4099.523482583901	44407	BBCA	BMRI	HAKA
2026-07-10 17:09:24.552408+07	ASII	4101.381357536084	45400	BBCA	BMRI	HAKA
2026-07-10 16:20:24.552408+07	ASII	4096.764194434912	60995	BBCA	BMRI	HAKI
2026-07-10 15:10:24.552408+07	ASII	4097.732766976103	59187	BBCA	BMRI	HAKA
2026-07-12 10:47:24.552408+07	ASII	4087.038860978452	43887	BBCA	BMRI	HAKI
2026-07-12 09:40:24.552408+07	ASII	4084.910538385238	47764	BBCA	BMRI	HAKI
2026-07-12 08:15:24.552408+07	ASII	4094.4211152679923	46735	BBCA	BMRI	HAKA
2026-07-12 07:16:24.552408+07	ASII	4095.3676358812386	44729	BBCA	BMRI	HAKA
2026-07-12 06:17:24.552408+07	ASII	4095.38355630972	48434	BBCA	BMRI	HAKA
2026-07-12 05:44:24.552408+07	ASII	4110.4442372362255	45419	BBCA	BMRI	HAKA
2026-07-12 04:33:24.552408+07	ASII	4106.6129436074025	38245	BBCA	BMRI	HAKI
2026-07-12 03:56:24.552408+07	ASII	4119.694468182206	39783	BBCA	BMRI	HAKA
2026-07-12 02:22:24.552408+07	ASII	4120.124200575016	38258	BBCA	BMRI	HAKA
2026-07-12 01:31:24.552408+07	ASII	4122.509773170375	42514	BBCA	BMRI	HAKA
2026-07-12 00:18:24.552408+07	ASII	4126.8129791885085	51489	BBCA	BMRI	HAKA
2026-07-11 23:14:24.552408+07	ASII	4116.251728680738	37483	BBCA	BMRI	HAKI
2026-07-11 22:43:24.552408+07	ASII	4110.033174798956	49391	BBCA	BMRI	HAKI
2026-07-11 21:43:24.552408+07	ASII	4111.296176311105	48842	BBCA	BMRI	HAKA
2026-07-11 20:51:24.552408+07	ASII	4112.65431894307	39666	BBCA	BMRI	HAKA
2026-07-11 19:16:24.552408+07	ASII	4104.482874859892	43258	BBCA	BMRI	HAKI
2026-07-11 18:51:24.552408+07	ASII	4113.724614458821	46537	BBCA	BMRI	HAKA
2026-07-11 17:51:24.552408+07	ASII	4107.983983541842	74270	BBCA	BMRI	HAKI
2026-07-11 16:21:24.552408+07	ASII	4091.9254530060134	60230	BBCA	BMRI	HAKI
2026-07-11 15:26:24.552408+07	ASII	4094.620345988039	38375	BBCA	BMRI	HAKA
2026-07-13 10:45:24.552408+07	ASII	4078.9671377986106	51973	BBCA	BMRI	HAKI
2026-07-13 09:37:24.552408+07	ASII	4074.8037439555706	16109	BBCA	BMRI	HAKI
2026-07-13 09:01:24.552408+07	ASII	4079.268638193629	49109	BBCA	BMRI	HAKA
2026-07-13 07:11:24.552408+07	ASII	4089.3468579902787	64350	BBCA	BMRI	HAKA
2026-07-13 06:51:24.552408+07	ASII	4107.923486788343	59817	BBCA	BMRI	HAKA
2026-07-13 05:48:24.552408+07	ASII	4093.670158457131	58792	BBCA	BMRI	HAKI
2026-07-13 04:37:24.552408+07	ASII	4094.6091767156486	60013	BBCA	BMRI	HAKA
2026-07-13 03:18:24.552408+07	ASII	4096.470759685843	47664	BBCA	BMRI	HAKA
2026-07-13 02:37:24.552408+07	ASII	4098.417187916126	36195	BBCA	BMRI	HAKA
2026-07-13 01:39:24.552408+07	ASII	4101.046215384348	48242	BBCA	BMRI	HAKA
2026-07-13 00:31:24.552408+07	ASII	4109.033594860733	46620	BBCA	BMRI	HAKA
2026-07-12 23:17:24.552408+07	ASII	4112.377248939785	42485	BBCA	BMRI	HAKA
2026-07-12 22:52:24.552408+07	ASII	4121.014535551691	65431	BBCA	BMRI	HAKA
2026-07-12 22:01:24.552408+07	ASII	4112.869642542826	63893	BBCA	BMRI	HAKI
2026-07-12 20:42:24.552408+07	ASII	4117.613773319253	60191	BBCA	BMRI	HAKA
2026-07-12 20:05:24.552408+07	ASII	4122.77375224763	71241	BBCA	BMRI	HAKA
2026-07-12 18:26:24.552408+07	ASII	4122.276163359883	48166	BBCA	BMRI	HAKI
2026-07-12 17:45:24.552408+07	ASII	4131.52323578506	44380	BBCA	BMRI	HAKA
2026-07-12 16:46:24.552408+07	ASII	4148.2368944664395	41699	BBCA	BMRI	HAKA
2026-07-12 15:51:24.552408+07	ASII	4150.6719122596005	46224	BBCA	BMRI	HAKA
2026-07-14 10:28:24.552408+07	ASII	4136.106256431874	75589	BBCA	BMRI	HAKI
2026-07-14 09:12:24.552408+07	ASII	4148.832610444556	54482	BBCA	BMRI	HAKA
2026-07-14 09:02:24.552408+07	ASII	4144.893746346816	53152	BBCA	BMRI	HAKI
2026-07-14 07:35:24.552408+07	ASII	4123.804983287046	27023	BBCA	BMRI	HAKI
2026-07-14 06:37:24.552408+07	ASII	4123.408540695145	53213	BBCA	BMRI	HAKI
2026-07-14 05:20:24.552408+07	ASII	4120.196884713367	57785	BBCA	BMRI	HAKI
2026-07-14 04:33:24.552408+07	ASII	4122.8269296599665	60036	BBCA	BMRI	HAKA
2026-07-14 03:10:24.552408+07	ASII	4131.679235908124	49813	BBCA	BMRI	HAKA
2026-07-14 02:06:24.552408+07	ASII	4142.0081527298225	39608	BBCA	BMRI	HAKA
2026-07-14 01:38:24.552408+07	ASII	4145.493171040817	35140	BBCA	BMRI	HAKA
2026-07-14 00:50:24.552408+07	ASII	4138.083355332201	56555	BBCA	BMRI	HAKI
2026-07-13 23:43:24.552408+07	ASII	4131.505994114392	51515	BBCA	BMRI	HAKI
2026-07-13 22:27:24.552408+07	ASII	4126.235356349803	47963	BBCA	BMRI	HAKI
2026-07-13 21:23:24.552408+07	ASII	4116.790734794819	43331	BBCA	BMRI	HAKI
2026-07-13 20:44:24.552408+07	ASII	4116.101522357022	50080	BBCA	BMRI	HAKI
2026-07-13 19:43:24.552408+07	ASII	4105.9650669554	46550	BBCA	BMRI	HAKI
2026-07-13 18:22:24.552408+07	ASII	4109.13802822456	58274	BBCA	BMRI	HAKA
2026-07-13 17:45:24.552408+07	ASII	4100.616404173046	46711	BBCA	BMRI	HAKI
2026-07-13 16:14:24.552408+07	ASII	4093.681274334874	58466	BBCA	BMRI	HAKI
2026-07-13 15:43:24.552408+07	ASII	4092.843825578719	61635	BBCA	BMRI	HAKI
\.


--
-- Data for Name: _hyper_2_8_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_2_8_chunk ("time", ticker, price, type, total_volume_lot, queue_count) FROM stdin;
2026-07-15 01:30:02.018945+07	BBCA	1000	BID	1000	5
2026-07-15 01:30:02.018945+07	BBCA	990	BID	1100	6
2026-07-15 01:30:02.018945+07	BBCA	980	BID	1200	7
2026-07-15 01:30:02.018945+07	BBCA	970	BID	1300	8
2026-07-15 01:30:02.018945+07	BBCA	960	BID	1400	9
2026-07-15 01:30:02.018945+07	BBCA	1000	ASK	1000	5
2026-07-15 01:30:02.018945+07	BBCA	1010	ASK	1100	6
2026-07-15 01:30:02.018945+07	BBCA	1020	ASK	1200	7
2026-07-15 01:30:02.018945+07	BBCA	1030	ASK	1300	8
2026-07-15 01:30:02.018945+07	BBCA	1040	ASK	1400	9
2026-07-15 01:30:02.087349+07	BBRI	1000	BID	1000	5
2026-07-15 01:30:02.087349+07	BBRI	990	BID	1100	6
2026-07-15 01:30:02.087349+07	BBRI	980	BID	1200	7
2026-07-15 01:30:02.087349+07	BBRI	970	BID	1300	8
2026-07-15 01:30:02.087349+07	BBRI	960	BID	1400	9
2026-07-15 01:30:02.087349+07	BBRI	1000	ASK	1000	5
2026-07-15 01:30:02.087349+07	BBRI	1010	ASK	1100	6
2026-07-15 01:30:02.087349+07	BBRI	1020	ASK	1200	7
2026-07-15 01:30:02.087349+07	BBRI	1030	ASK	1300	8
2026-07-15 01:30:02.087349+07	BBRI	1040	ASK	1400	9
2026-07-15 01:30:02.127778+07	BMRI	1000	BID	1000	5
2026-07-15 01:30:02.127778+07	BMRI	990	BID	1100	6
2026-07-15 01:30:02.127778+07	BMRI	980	BID	1200	7
2026-07-15 01:30:02.127778+07	BMRI	970	BID	1300	8
2026-07-15 01:30:02.127778+07	BMRI	960	BID	1400	9
2026-07-15 01:30:02.127778+07	BMRI	1000	ASK	1000	5
2026-07-15 01:30:02.127778+07	BMRI	1010	ASK	1100	6
2026-07-15 01:30:02.127778+07	BMRI	1020	ASK	1200	7
2026-07-15 01:30:02.127778+07	BMRI	1030	ASK	1300	8
2026-07-15 01:30:02.127778+07	BMRI	1040	ASK	1400	9
2026-07-15 01:30:02.169197+07	TLKM	1000	BID	1000	5
2026-07-15 01:30:02.169197+07	TLKM	990	BID	1100	6
2026-07-15 01:30:02.169197+07	TLKM	980	BID	1200	7
2026-07-15 01:30:02.169197+07	TLKM	970	BID	1300	8
2026-07-15 01:30:02.169197+07	TLKM	960	BID	1400	9
2026-07-15 01:30:02.169197+07	TLKM	1000	ASK	1000	5
2026-07-15 01:30:02.169197+07	TLKM	1010	ASK	1100	6
2026-07-15 01:30:02.169197+07	TLKM	1020	ASK	1200	7
2026-07-15 01:30:02.169197+07	TLKM	1030	ASK	1300	8
2026-07-15 01:30:02.169197+07	TLKM	1040	ASK	1400	9
2026-07-15 01:30:02.197913+07	ASII	1000	BID	1000	5
2026-07-15 01:30:02.197913+07	ASII	990	BID	1100	6
2026-07-15 01:30:02.197913+07	ASII	980	BID	1200	7
2026-07-15 01:30:02.197913+07	ASII	970	BID	1300	8
2026-07-15 01:30:02.197913+07	ASII	960	BID	1400	9
2026-07-15 01:30:02.197913+07	ASII	1000	ASK	1000	5
2026-07-15 01:30:02.197913+07	ASII	1010	ASK	1100	6
2026-07-15 01:30:02.197913+07	ASII	1020	ASK	1200	7
2026-07-15 01:30:02.197913+07	ASII	1030	ASK	1300	8
2026-07-15 01:30:02.197913+07	ASII	1040	ASK	1400	9
2026-07-15 20:03:15.474274+07	BBCA	4108	BID	1109	5
2026-07-15 20:03:15.474274+07	BBCA	4098	BID	1360	6
2026-07-15 20:03:15.474274+07	BBCA	4088	BID	1634	7
2026-07-15 20:03:15.474274+07	BBCA	4078	BID	1435	8
2026-07-15 20:03:15.474274+07	BBCA	4068	BID	1608	9
2026-07-15 20:03:15.474274+07	BBCA	4108	ASK	1441	5
2026-07-15 20:03:15.474274+07	BBCA	4118	ASK	1538	6
2026-07-15 20:03:15.474274+07	BBCA	4128	ASK	1672	7
2026-07-15 20:03:15.474274+07	BBCA	4138	ASK	1624	8
2026-07-15 20:03:15.474274+07	BBCA	4148	ASK	1596	9
2026-07-15 20:03:16.486724+07	BBCA	4108	BID	1183	5
2026-07-15 20:03:16.486724+07	BBCA	4098	BID	1564	6
2026-07-15 20:03:16.486724+07	BBCA	4088	BID	1632	7
2026-07-15 20:03:16.486724+07	BBCA	4078	BID	1563	8
2026-07-15 20:03:16.486724+07	BBCA	4068	BID	1701	9
2026-07-15 20:03:16.486724+07	BBCA	4108	ASK	1446	5
2026-07-15 20:03:16.486724+07	BBCA	4118	ASK	1463	6
2026-07-15 20:03:16.486724+07	BBCA	4128	ASK	1273	7
2026-07-15 20:03:16.486724+07	BBCA	4138	ASK	1321	8
2026-07-15 20:03:16.486724+07	BBCA	4148	ASK	1487	9
2026-07-15 20:03:17.493039+07	BBCA	4108	BID	1223	5
2026-07-15 20:03:17.493039+07	BBCA	4098	BID	1387	6
2026-07-15 20:03:17.493039+07	BBCA	4088	BID	1375	7
2026-07-15 20:03:17.493039+07	BBCA	4078	BID	1471	8
2026-07-15 20:03:17.493039+07	BBCA	4068	BID	1805	9
2026-07-15 20:03:17.493039+07	BBCA	4108	ASK	1000	5
2026-07-15 20:03:17.493039+07	BBCA	4118	ASK	1403	6
2026-07-15 20:03:17.493039+07	BBCA	4128	ASK	1264	7
2026-07-15 20:03:17.493039+07	BBCA	4138	ASK	1427	8
2026-07-15 20:03:17.493039+07	BBCA	4148	ASK	1678	9
2026-07-15 20:03:18.503559+07	BBCA	4108	BID	1309	5
2026-07-15 20:03:18.503559+07	BBCA	4098	BID	1356	6
2026-07-15 20:03:18.503559+07	BBCA	4088	BID	1383	7
2026-07-15 20:03:18.503559+07	BBCA	4078	BID	1511	8
2026-07-15 20:03:18.503559+07	BBCA	4068	BID	1528	9
2026-07-15 20:03:18.503559+07	BBCA	4108	ASK	1061	5
2026-07-15 20:03:18.503559+07	BBCA	4118	ASK	1511	6
2026-07-15 20:03:18.503559+07	BBCA	4128	ASK	1552	7
2026-07-15 20:03:18.503559+07	BBCA	4138	ASK	1309	8
2026-07-15 20:03:18.503559+07	BBCA	4148	ASK	1695	9
2026-07-15 20:03:19.510191+07	BBCA	4108	BID	1025	5
2026-07-15 20:03:19.510191+07	BBCA	4098	BID	1169	6
2026-07-15 20:03:19.510191+07	BBCA	4088	BID	1651	7
2026-07-15 20:03:19.510191+07	BBCA	4078	BID	1339	8
2026-07-15 20:03:19.510191+07	BBCA	4068	BID	1844	9
2026-07-15 20:03:19.510191+07	BBCA	4108	ASK	1334	5
2026-07-15 20:03:19.510191+07	BBCA	4118	ASK	1402	6
2026-07-15 20:03:19.510191+07	BBCA	4128	ASK	1476	7
2026-07-15 20:03:19.510191+07	BBCA	4138	ASK	1408	8
2026-07-15 20:03:19.510191+07	BBCA	4148	ASK	1771	9
2026-07-15 20:03:20.52058+07	BBCA	4108	BID	1167	5
2026-07-15 20:03:20.52058+07	BBCA	4098	BID	1275	6
2026-07-15 20:03:20.52058+07	BBCA	4088	BID	1414	7
2026-07-15 20:03:20.52058+07	BBCA	4078	BID	1433	8
2026-07-15 20:03:20.52058+07	BBCA	4068	BID	1875	9
2026-07-15 20:03:20.52058+07	BBCA	4108	ASK	1107	5
2026-07-15 20:03:20.52058+07	BBCA	4118	ASK	1246	6
2026-07-15 20:03:20.52058+07	BBCA	4128	ASK	1528	7
2026-07-15 20:03:20.52058+07	BBCA	4138	ASK	1533	8
2026-07-15 20:03:20.52058+07	BBCA	4148	ASK	1726	9
2026-07-15 20:03:21.53068+07	BBCA	4108	BID	1035	5
2026-07-15 20:03:21.53068+07	BBCA	4098	BID	1262	6
2026-07-15 20:03:21.53068+07	BBCA	4088	BID	1322	7
2026-07-15 20:03:21.53068+07	BBCA	4078	BID	1527	8
2026-07-15 20:03:21.53068+07	BBCA	4068	BID	1837	9
2026-07-15 20:03:21.53068+07	BBCA	4108	ASK	1447	5
2026-07-15 20:03:21.53068+07	BBCA	4118	ASK	1598	6
2026-07-15 20:03:21.53068+07	BBCA	4128	ASK	1401	7
2026-07-15 20:03:21.53068+07	BBCA	4138	ASK	1319	8
2026-07-15 20:03:21.53068+07	BBCA	4148	ASK	1609	9
2026-07-15 20:03:22.539859+07	BBCA	4108	BID	1142	5
2026-07-15 20:03:22.539859+07	BBCA	4098	BID	1415	6
2026-07-15 20:03:22.539859+07	BBCA	4088	BID	1363	7
2026-07-15 20:03:22.539859+07	BBCA	4078	BID	1593	8
2026-07-15 20:03:22.539859+07	BBCA	4068	BID	1709	9
2026-07-15 20:03:22.539859+07	BBCA	4108	ASK	1085	5
2026-07-15 20:03:22.539859+07	BBCA	4118	ASK	1390	6
2026-07-15 20:03:22.539859+07	BBCA	4128	ASK	1342	7
2026-07-15 20:03:22.539859+07	BBCA	4138	ASK	1372	8
2026-07-15 20:03:22.539859+07	BBCA	4148	ASK	1848	9
2026-07-15 20:03:23.553539+07	BBCA	4108	BID	1001	5
2026-07-15 20:03:23.553539+07	BBCA	4098	BID	1138	6
2026-07-15 20:03:23.553539+07	BBCA	4088	BID	1540	7
2026-07-15 20:03:23.553539+07	BBCA	4078	BID	1780	8
2026-07-15 20:03:23.553539+07	BBCA	4068	BID	1864	9
2026-07-15 20:03:23.553539+07	BBCA	4108	ASK	1473	5
2026-07-15 20:03:23.553539+07	BBCA	4118	ASK	1313	6
2026-07-15 20:03:23.553539+07	BBCA	4128	ASK	1443	7
2026-07-15 20:03:23.553539+07	BBCA	4138	ASK	1518	8
2026-07-15 20:03:23.553539+07	BBCA	4148	ASK	1777	9
2026-07-15 20:03:24.56312+07	BBCA	4108	BID	1263	5
2026-07-15 20:03:24.56312+07	BBCA	4098	BID	1555	6
2026-07-15 20:03:24.56312+07	BBCA	4088	BID	1564	7
2026-07-15 20:03:24.56312+07	BBCA	4078	BID	1409	8
2026-07-15 20:03:24.56312+07	BBCA	4068	BID	1533	9
2026-07-15 20:03:24.56312+07	BBCA	4108	ASK	1407	5
2026-07-15 20:03:24.56312+07	BBCA	4118	ASK	1292	6
2026-07-15 20:03:24.56312+07	BBCA	4128	ASK	1441	7
2026-07-15 20:03:24.56312+07	BBCA	4138	ASK	1682	8
2026-07-15 20:03:24.56312+07	BBCA	4148	ASK	1873	9
2026-07-15 20:03:25.573174+07	BBCA	4108	BID	1381	5
2026-07-15 20:03:25.573174+07	BBCA	4098	BID	1371	6
2026-07-15 20:03:25.573174+07	BBCA	4088	BID	1560	7
2026-07-15 20:03:25.573174+07	BBCA	4078	BID	1633	8
2026-07-15 20:03:25.573174+07	BBCA	4068	BID	1742	9
2026-07-15 20:03:25.573174+07	BBCA	4108	ASK	1404	5
2026-07-15 20:03:25.573174+07	BBCA	4118	ASK	1372	6
2026-07-15 20:03:25.573174+07	BBCA	4128	ASK	1545	7
2026-07-15 20:03:25.573174+07	BBCA	4138	ASK	1576	8
2026-07-15 20:03:25.573174+07	BBCA	4148	ASK	1444	9
2026-07-15 20:03:26.585169+07	BBCA	4108	BID	1380	5
2026-07-15 20:03:26.585169+07	BBCA	4098	BID	1519	6
2026-07-15 20:03:26.585169+07	BBCA	4088	BID	1395	7
2026-07-15 20:03:26.585169+07	BBCA	4078	BID	1736	8
2026-07-15 20:03:26.585169+07	BBCA	4068	BID	1886	9
2026-07-15 20:03:26.585169+07	BBCA	4108	ASK	1230	5
2026-07-15 20:03:26.585169+07	BBCA	4118	ASK	1502	6
2026-07-15 20:03:26.585169+07	BBCA	4128	ASK	1474	7
2026-07-15 20:03:26.585169+07	BBCA	4138	ASK	1494	8
2026-07-15 20:03:26.585169+07	BBCA	4148	ASK	1768	9
2026-07-15 20:03:27.592157+07	BBCA	4108	BID	1032	5
2026-07-15 20:03:27.592157+07	BBCA	4098	BID	1580	6
2026-07-15 20:03:27.592157+07	BBCA	4088	BID	1675	7
2026-07-15 20:03:27.592157+07	BBCA	4078	BID	1664	8
2026-07-15 20:03:27.592157+07	BBCA	4068	BID	1425	9
2026-07-15 20:03:27.592157+07	BBCA	4108	ASK	1480	5
2026-07-15 20:03:27.592157+07	BBCA	4118	ASK	1518	6
2026-07-15 20:03:27.592157+07	BBCA	4128	ASK	1229	7
2026-07-15 20:03:27.592157+07	BBCA	4138	ASK	1638	8
2026-07-15 20:03:27.592157+07	BBCA	4148	ASK	1760	9
2026-07-15 20:03:28.607517+07	BBCA	4108	BID	1372	5
2026-07-15 20:03:28.607517+07	BBCA	4098	BID	1318	6
2026-07-15 20:03:28.607517+07	BBCA	4088	BID	1632	7
2026-07-15 20:03:28.607517+07	BBCA	4078	BID	1410	8
2026-07-15 20:03:28.607517+07	BBCA	4068	BID	1832	9
2026-07-15 20:03:28.607517+07	BBCA	4108	ASK	1478	5
2026-07-15 20:03:28.607517+07	BBCA	4118	ASK	1287	6
2026-07-15 20:03:28.607517+07	BBCA	4128	ASK	1277	7
2026-07-15 20:03:28.607517+07	BBCA	4138	ASK	1568	8
2026-07-15 20:03:28.607517+07	BBCA	4148	ASK	1445	9
2026-07-15 20:03:29.616692+07	BBCA	4108	BID	1288	5
2026-07-15 20:03:29.616692+07	BBCA	4098	BID	1460	6
2026-07-15 20:03:29.616692+07	BBCA	4088	BID	1244	7
2026-07-15 20:03:29.616692+07	BBCA	4078	BID	1387	8
2026-07-15 20:03:29.616692+07	BBCA	4068	BID	1797	9
2026-07-15 20:03:29.616692+07	BBCA	4108	ASK	1202	5
2026-07-15 20:03:29.616692+07	BBCA	4118	ASK	1208	6
2026-07-15 20:03:29.616692+07	BBCA	4128	ASK	1599	7
2026-07-15 20:03:29.616692+07	BBCA	4138	ASK	1586	8
2026-07-15 20:03:29.616692+07	BBCA	4148	ASK	1787	9
2026-07-15 20:03:30.623274+07	BBCA	4108	BID	1490	5
2026-07-15 20:03:30.623274+07	BBCA	4098	BID	1578	6
2026-07-15 20:03:30.623274+07	BBCA	4088	BID	1421	7
2026-07-15 20:03:30.623274+07	BBCA	4078	BID	1348	8
2026-07-15 20:03:30.623274+07	BBCA	4068	BID	1601	9
2026-07-15 20:03:30.623274+07	BBCA	4108	ASK	1196	5
2026-07-15 20:03:30.623274+07	BBCA	4118	ASK	1382	6
2026-07-15 20:03:30.623274+07	BBCA	4128	ASK	1568	7
2026-07-15 20:03:30.623274+07	BBCA	4138	ASK	1541	8
2026-07-15 20:03:30.623274+07	BBCA	4148	ASK	1613	9
2026-07-15 20:03:31.629527+07	BBCA	4108	BID	1040	5
2026-07-15 20:03:31.629527+07	BBCA	4098	BID	1469	6
2026-07-15 20:03:31.629527+07	BBCA	4088	BID	1330	7
2026-07-15 20:03:31.629527+07	BBCA	4078	BID	1376	8
2026-07-15 20:03:31.629527+07	BBCA	4068	BID	1500	9
2026-07-15 20:03:31.629527+07	BBCA	4108	ASK	1395	5
2026-07-15 20:03:31.629527+07	BBCA	4118	ASK	1339	6
2026-07-15 20:03:31.629527+07	BBCA	4128	ASK	1423	7
2026-07-15 20:03:31.629527+07	BBCA	4138	ASK	1502	8
2026-07-15 20:03:31.629527+07	BBCA	4148	ASK	1765	9
2026-07-15 20:03:32.635817+07	BBCA	4108	BID	1355	5
2026-07-15 20:03:32.635817+07	BBCA	4098	BID	1400	6
2026-07-15 20:03:32.635817+07	BBCA	4088	BID	1303	7
2026-07-15 20:03:32.635817+07	BBCA	4078	BID	1315	8
2026-07-15 20:03:32.635817+07	BBCA	4068	BID	1783	9
2026-07-15 20:03:32.635817+07	BBCA	4108	ASK	1385	5
2026-07-15 20:03:32.635817+07	BBCA	4118	ASK	1519	6
2026-07-15 20:03:32.635817+07	BBCA	4128	ASK	1672	7
2026-07-15 20:03:32.635817+07	BBCA	4138	ASK	1425	8
2026-07-15 20:03:32.635817+07	BBCA	4148	ASK	1834	9
2026-07-15 20:03:33.642051+07	BBCA	4108	BID	1194	5
2026-07-15 20:03:33.642051+07	BBCA	4098	BID	1272	6
2026-07-15 20:03:33.642051+07	BBCA	4088	BID	1288	7
2026-07-15 20:03:33.642051+07	BBCA	4078	BID	1521	8
2026-07-15 20:03:33.642051+07	BBCA	4068	BID	1868	9
2026-07-15 20:03:33.642051+07	BBCA	4108	ASK	1336	5
2026-07-15 20:03:33.642051+07	BBCA	4118	ASK	1577	6
2026-07-15 20:03:33.642051+07	BBCA	4128	ASK	1484	7
2026-07-15 20:03:33.642051+07	BBCA	4138	ASK	1398	8
2026-07-15 20:03:33.642051+07	BBCA	4148	ASK	1631	9
2026-07-15 20:03:34.648637+07	BBCA	4108	BID	1435	5
2026-07-15 20:03:34.648637+07	BBCA	4098	BID	1100	6
2026-07-15 20:03:34.648637+07	BBCA	4088	BID	1629	7
2026-07-15 20:03:34.648637+07	BBCA	4078	BID	1302	8
2026-07-15 20:03:34.648637+07	BBCA	4068	BID	1718	9
2026-07-15 20:03:34.648637+07	BBCA	4108	ASK	1088	5
2026-07-15 20:03:34.648637+07	BBCA	4118	ASK	1278	6
2026-07-15 20:03:34.648637+07	BBCA	4128	ASK	1638	7
2026-07-15 20:03:34.648637+07	BBCA	4138	ASK	1778	8
2026-07-15 20:03:34.648637+07	BBCA	4148	ASK	1823	9
2026-07-15 20:03:35.655137+07	BBCA	4108	BID	1317	5
2026-07-15 20:03:35.655137+07	BBCA	4098	BID	1177	6
2026-07-15 20:03:35.655137+07	BBCA	4088	BID	1478	7
2026-07-15 20:03:35.655137+07	BBCA	4078	BID	1629	8
2026-07-15 20:03:35.655137+07	BBCA	4068	BID	1433	9
2026-07-15 20:03:35.655137+07	BBCA	4108	ASK	1324	5
2026-07-15 20:03:35.655137+07	BBCA	4118	ASK	1534	6
2026-07-15 20:03:35.655137+07	BBCA	4128	ASK	1451	7
2026-07-15 20:03:35.655137+07	BBCA	4138	ASK	1515	8
2026-07-15 20:03:35.655137+07	BBCA	4148	ASK	1734	9
2026-07-15 20:03:36.661221+07	BBCA	4108	BID	1051	5
2026-07-15 20:03:36.661221+07	BBCA	4098	BID	1392	6
2026-07-15 20:03:36.661221+07	BBCA	4088	BID	1474	7
2026-07-15 20:03:36.661221+07	BBCA	4078	BID	1385	8
2026-07-15 20:03:36.661221+07	BBCA	4068	BID	1447	9
2026-07-15 20:03:36.661221+07	BBCA	4108	ASK	1375	5
2026-07-15 20:03:36.661221+07	BBCA	4118	ASK	1227	6
2026-07-15 20:03:36.661221+07	BBCA	4128	ASK	1252	7
2026-07-15 20:03:36.661221+07	BBCA	4138	ASK	1538	8
2026-07-15 20:03:36.661221+07	BBCA	4148	ASK	1483	9
2026-07-15 20:03:37.667439+07	BBCA	4108	BID	1396	5
2026-07-15 20:03:37.667439+07	BBCA	4098	BID	1330	6
2026-07-15 20:03:37.667439+07	BBCA	4088	BID	1377	7
2026-07-15 20:03:37.667439+07	BBCA	4078	BID	1457	8
2026-07-15 20:03:37.667439+07	BBCA	4068	BID	1657	9
2026-07-15 20:03:37.667439+07	BBCA	4108	ASK	1374	5
2026-07-15 20:03:37.667439+07	BBCA	4118	ASK	1597	6
2026-07-15 20:03:37.667439+07	BBCA	4128	ASK	1293	7
2026-07-15 20:03:37.667439+07	BBCA	4138	ASK	1552	8
2026-07-15 20:03:37.667439+07	BBCA	4148	ASK	1482	9
2026-07-15 20:03:38.673991+07	BBCA	4108	BID	1297	5
2026-07-15 20:03:38.673991+07	BBCA	4098	BID	1519	6
2026-07-15 20:03:38.673991+07	BBCA	4088	BID	1415	7
2026-07-15 20:03:38.673991+07	BBCA	4078	BID	1621	8
2026-07-15 20:03:38.673991+07	BBCA	4068	BID	1605	9
2026-07-15 20:03:38.673991+07	BBCA	4108	ASK	1139	5
2026-07-15 20:03:38.673991+07	BBCA	4118	ASK	1256	6
2026-07-15 20:03:38.673991+07	BBCA	4128	ASK	1276	7
2026-07-15 20:03:38.673991+07	BBCA	4138	ASK	1530	8
2026-07-15 20:03:38.673991+07	BBCA	4148	ASK	1538	9
2026-07-15 20:03:39.68328+07	BBCA	4108	BID	1271	5
2026-07-15 20:03:39.68328+07	BBCA	4098	BID	1590	6
2026-07-15 20:03:39.68328+07	BBCA	4088	BID	1592	7
2026-07-15 20:03:39.68328+07	BBCA	4078	BID	1773	8
2026-07-15 20:03:39.68328+07	BBCA	4068	BID	1572	9
2026-07-15 20:03:39.68328+07	BBCA	4108	ASK	1253	5
2026-07-15 20:03:39.68328+07	BBCA	4118	ASK	1394	6
2026-07-15 20:03:39.68328+07	BBCA	4128	ASK	1560	7
2026-07-15 20:03:39.68328+07	BBCA	4138	ASK	1380	8
2026-07-15 20:03:39.68328+07	BBCA	4148	ASK	1844	9
2026-07-15 20:03:40.694222+07	BBCA	4108	BID	1371	5
2026-07-15 20:03:40.694222+07	BBCA	4098	BID	1215	6
2026-07-15 20:03:40.694222+07	BBCA	4088	BID	1410	7
2026-07-15 20:03:40.694222+07	BBCA	4078	BID	1676	8
2026-07-15 20:03:40.694222+07	BBCA	4068	BID	1634	9
2026-07-15 20:03:40.694222+07	BBCA	4108	ASK	1036	5
2026-07-15 20:03:40.694222+07	BBCA	4118	ASK	1177	6
2026-07-15 20:03:40.694222+07	BBCA	4128	ASK	1503	7
2026-07-15 20:03:40.694222+07	BBCA	4138	ASK	1628	8
2026-07-15 20:03:40.694222+07	BBCA	4148	ASK	1701	9
2026-07-15 20:03:41.705215+07	BBCA	4108	BID	1441	5
2026-07-15 20:03:41.705215+07	BBCA	4098	BID	1540	6
2026-07-15 20:03:41.705215+07	BBCA	4088	BID	1616	7
2026-07-15 20:03:41.705215+07	BBCA	4078	BID	1366	8
2026-07-15 20:03:41.705215+07	BBCA	4068	BID	1737	9
2026-07-15 20:03:41.705215+07	BBCA	4108	ASK	1467	5
2026-07-15 20:03:41.705215+07	BBCA	4118	ASK	1208	6
2026-07-15 20:03:41.705215+07	BBCA	4128	ASK	1562	7
2026-07-15 20:03:41.705215+07	BBCA	4138	ASK	1768	8
2026-07-15 20:03:41.705215+07	BBCA	4148	ASK	1432	9
2026-07-15 20:03:42.712872+07	BBCA	4108	BID	1459	5
2026-07-15 20:03:42.712872+07	BBCA	4098	BID	1338	6
2026-07-15 20:03:42.712872+07	BBCA	4088	BID	1362	7
2026-07-15 20:03:42.712872+07	BBCA	4078	BID	1583	8
2026-07-15 20:03:42.712872+07	BBCA	4068	BID	1863	9
2026-07-15 20:03:42.712872+07	BBCA	4108	ASK	1475	5
2026-07-15 20:03:42.712872+07	BBCA	4118	ASK	1358	6
2026-07-15 20:03:42.712872+07	BBCA	4128	ASK	1205	7
2026-07-15 20:03:42.712872+07	BBCA	4138	ASK	1368	8
2026-07-15 20:03:42.712872+07	BBCA	4148	ASK	1815	9
2026-07-15 20:03:43.723409+07	BBCA	4108	BID	1383	5
2026-07-15 20:03:43.723409+07	BBCA	4098	BID	1575	6
2026-07-15 20:03:43.723409+07	BBCA	4088	BID	1663	7
2026-07-15 20:03:43.723409+07	BBCA	4078	BID	1475	8
2026-07-15 20:03:43.723409+07	BBCA	4068	BID	1886	9
2026-07-15 20:03:43.723409+07	BBCA	4108	ASK	1026	5
2026-07-15 20:03:43.723409+07	BBCA	4118	ASK	1231	6
2026-07-15 20:03:43.723409+07	BBCA	4128	ASK	1380	7
2026-07-15 20:03:43.723409+07	BBCA	4138	ASK	1556	8
2026-07-15 20:03:43.723409+07	BBCA	4148	ASK	1832	9
2026-07-15 20:03:44.732853+07	BBCA	4108	BID	1156	5
2026-07-15 20:03:44.732853+07	BBCA	4098	BID	1406	6
2026-07-15 20:03:44.732853+07	BBCA	4088	BID	1600	7
2026-07-15 20:03:44.732853+07	BBCA	4078	BID	1603	8
2026-07-15 20:03:44.732853+07	BBCA	4068	BID	1409	9
2026-07-15 20:03:44.732853+07	BBCA	4108	ASK	1372	5
2026-07-15 20:03:44.732853+07	BBCA	4118	ASK	1357	6
2026-07-15 20:03:44.732853+07	BBCA	4128	ASK	1680	7
2026-07-15 20:03:44.732853+07	BBCA	4138	ASK	1333	8
2026-07-15 20:03:44.732853+07	BBCA	4148	ASK	1889	9
2026-07-15 20:03:45.741055+07	BBCA	4108	BID	1072	5
2026-07-15 20:03:45.741055+07	BBCA	4098	BID	1244	6
2026-07-15 20:03:45.741055+07	BBCA	4088	BID	1217	7
2026-07-15 20:03:45.741055+07	BBCA	4078	BID	1612	8
2026-07-15 20:03:45.741055+07	BBCA	4068	BID	1640	9
2026-07-15 20:03:45.741055+07	BBCA	4108	ASK	1260	5
2026-07-15 20:03:45.741055+07	BBCA	4118	ASK	1157	6
2026-07-15 20:03:45.741055+07	BBCA	4128	ASK	1240	7
2026-07-15 20:03:45.741055+07	BBCA	4138	ASK	1774	8
2026-07-15 20:03:45.741055+07	BBCA	4148	ASK	1553	9
2026-07-15 20:03:46.751322+07	BBCA	4108	BID	1276	5
2026-07-15 20:03:46.751322+07	BBCA	4098	BID	1560	6
2026-07-15 20:03:46.751322+07	BBCA	4088	BID	1555	7
2026-07-15 20:03:46.751322+07	BBCA	4078	BID	1423	8
2026-07-15 20:03:46.751322+07	BBCA	4068	BID	1755	9
2026-07-15 20:03:46.751322+07	BBCA	4108	ASK	1308	5
2026-07-15 20:03:46.751322+07	BBCA	4118	ASK	1508	6
2026-07-15 20:03:46.751322+07	BBCA	4128	ASK	1645	7
2026-07-15 20:03:46.751322+07	BBCA	4138	ASK	1690	8
2026-07-15 20:03:46.751322+07	BBCA	4148	ASK	1555	9
2026-07-15 20:03:47.759143+07	BBCA	4108	BID	1169	5
2026-07-15 20:03:47.759143+07	BBCA	4098	BID	1494	6
2026-07-15 20:03:47.759143+07	BBCA	4088	BID	1278	7
2026-07-15 20:03:47.759143+07	BBCA	4078	BID	1719	8
2026-07-15 20:03:47.759143+07	BBCA	4068	BID	1723	9
2026-07-15 20:03:47.759143+07	BBCA	4108	ASK	1128	5
2026-07-15 20:03:47.759143+07	BBCA	4118	ASK	1375	6
2026-07-15 20:03:47.759143+07	BBCA	4128	ASK	1206	7
2026-07-15 20:03:47.759143+07	BBCA	4138	ASK	1493	8
2026-07-15 20:03:47.759143+07	BBCA	4148	ASK	1600	9
2026-07-15 20:03:48.770625+07	BBCA	4108	BID	1482	5
2026-07-15 20:03:48.770625+07	BBCA	4098	BID	1332	6
2026-07-15 20:03:48.770625+07	BBCA	4088	BID	1655	7
2026-07-15 20:03:48.770625+07	BBCA	4078	BID	1311	8
2026-07-15 20:03:48.770625+07	BBCA	4068	BID	1575	9
2026-07-15 20:03:48.770625+07	BBCA	4108	ASK	1499	5
2026-07-15 20:03:48.770625+07	BBCA	4118	ASK	1210	6
2026-07-15 20:03:48.770625+07	BBCA	4128	ASK	1544	7
2026-07-15 20:03:48.770625+07	BBCA	4138	ASK	1647	8
2026-07-15 20:03:48.770625+07	BBCA	4148	ASK	1857	9
2026-07-15 20:03:49.778105+07	BBCA	4108	BID	1430	5
2026-07-15 20:03:49.778105+07	BBCA	4098	BID	1359	6
2026-07-15 20:03:49.778105+07	BBCA	4088	BID	1279	7
2026-07-15 20:03:49.778105+07	BBCA	4078	BID	1607	8
2026-07-15 20:03:49.778105+07	BBCA	4068	BID	1612	9
2026-07-15 20:03:49.778105+07	BBCA	4108	ASK	1440	5
2026-07-15 20:03:49.778105+07	BBCA	4118	ASK	1161	6
2026-07-15 20:03:49.778105+07	BBCA	4128	ASK	1392	7
2026-07-15 20:03:49.778105+07	BBCA	4138	ASK	1342	8
2026-07-15 20:03:49.778105+07	BBCA	4148	ASK	1507	9
2026-07-15 20:03:50.788741+07	BBCA	4108	BID	1039	5
2026-07-15 20:03:50.788741+07	BBCA	4098	BID	1186	6
2026-07-15 20:03:50.788741+07	BBCA	4088	BID	1610	7
2026-07-15 20:03:50.788741+07	BBCA	4078	BID	1545	8
2026-07-15 20:03:50.788741+07	BBCA	4068	BID	1770	9
2026-07-15 20:03:50.788741+07	BBCA	4108	ASK	1266	5
2026-07-15 20:03:50.788741+07	BBCA	4118	ASK	1203	6
2026-07-15 20:03:50.788741+07	BBCA	4128	ASK	1297	7
2026-07-15 20:03:50.788741+07	BBCA	4138	ASK	1698	8
2026-07-15 20:03:50.788741+07	BBCA	4148	ASK	1435	9
2026-07-15 20:03:51.797341+07	BBCA	4108	BID	1097	5
2026-07-15 20:03:51.797341+07	BBCA	4098	BID	1370	6
2026-07-15 20:03:51.797341+07	BBCA	4088	BID	1275	7
2026-07-15 20:03:51.797341+07	BBCA	4078	BID	1354	8
2026-07-15 20:03:51.797341+07	BBCA	4068	BID	1444	9
2026-07-15 20:03:51.797341+07	BBCA	4108	ASK	1445	5
2026-07-15 20:03:51.797341+07	BBCA	4118	ASK	1501	6
2026-07-15 20:03:51.797341+07	BBCA	4128	ASK	1398	7
2026-07-15 20:03:51.797341+07	BBCA	4138	ASK	1686	8
2026-07-15 20:03:51.797341+07	BBCA	4148	ASK	1569	9
2026-07-15 20:03:52.805518+07	BBCA	4108	BID	1374	5
2026-07-15 20:03:52.805518+07	BBCA	4098	BID	1142	6
2026-07-15 20:03:52.805518+07	BBCA	4088	BID	1498	7
2026-07-15 20:03:52.805518+07	BBCA	4078	BID	1363	8
2026-07-15 20:03:52.805518+07	BBCA	4068	BID	1867	9
2026-07-15 20:03:52.805518+07	BBCA	4108	ASK	1374	5
2026-07-15 20:03:52.805518+07	BBCA	4118	ASK	1478	6
2026-07-15 20:03:52.805518+07	BBCA	4128	ASK	1290	7
2026-07-15 20:03:52.805518+07	BBCA	4138	ASK	1349	8
2026-07-15 20:03:52.805518+07	BBCA	4148	ASK	1775	9
2026-07-15 20:03:53.815034+07	BBCA	4108	BID	1189	5
2026-07-15 20:03:53.815034+07	BBCA	4098	BID	1290	6
2026-07-15 20:03:53.815034+07	BBCA	4088	BID	1467	7
2026-07-15 20:03:53.815034+07	BBCA	4078	BID	1405	8
2026-07-15 20:03:53.815034+07	BBCA	4068	BID	1712	9
2026-07-15 20:03:53.815034+07	BBCA	4108	ASK	1259	5
2026-07-15 20:03:53.815034+07	BBCA	4118	ASK	1400	6
2026-07-15 20:03:53.815034+07	BBCA	4128	ASK	1355	7
2026-07-15 20:03:53.815034+07	BBCA	4138	ASK	1331	8
2026-07-15 20:03:53.815034+07	BBCA	4148	ASK	1570	9
2026-07-15 20:03:54.825252+07	BBCA	4108	BID	1080	5
2026-07-15 20:03:54.825252+07	BBCA	4098	BID	1535	6
2026-07-15 20:03:54.825252+07	BBCA	4088	BID	1204	7
2026-07-15 20:03:54.825252+07	BBCA	4078	BID	1593	8
2026-07-15 20:03:54.825252+07	BBCA	4068	BID	1899	9
2026-07-15 20:03:54.825252+07	BBCA	4108	ASK	1312	5
2026-07-15 20:03:54.825252+07	BBCA	4118	ASK	1564	6
2026-07-15 20:03:54.825252+07	BBCA	4128	ASK	1289	7
2026-07-15 20:03:54.825252+07	BBCA	4138	ASK	1732	8
2026-07-15 20:03:54.825252+07	BBCA	4148	ASK	1454	9
2026-07-15 20:03:55.835492+07	BBCA	4108	BID	1412	5
2026-07-15 20:03:55.835492+07	BBCA	4098	BID	1208	6
2026-07-15 20:03:55.835492+07	BBCA	4088	BID	1470	7
2026-07-15 20:03:55.835492+07	BBCA	4078	BID	1537	8
2026-07-15 20:03:55.835492+07	BBCA	4068	BID	1617	9
2026-07-15 20:03:55.835492+07	BBCA	4108	ASK	1394	5
2026-07-15 20:03:55.835492+07	BBCA	4118	ASK	1231	6
2026-07-15 20:03:55.835492+07	BBCA	4128	ASK	1542	7
2026-07-15 20:03:55.835492+07	BBCA	4138	ASK	1564	8
2026-07-15 20:03:55.835492+07	BBCA	4148	ASK	1533	9
2026-07-15 20:03:56.84573+07	BBCA	4108	BID	1272	5
2026-07-15 20:03:56.84573+07	BBCA	4098	BID	1336	6
2026-07-15 20:03:56.84573+07	BBCA	4088	BID	1588	7
2026-07-15 20:03:56.84573+07	BBCA	4078	BID	1547	8
2026-07-15 20:03:56.84573+07	BBCA	4068	BID	1443	9
2026-07-15 20:03:56.84573+07	BBCA	4108	ASK	1151	5
2026-07-15 20:03:56.84573+07	BBCA	4118	ASK	1506	6
2026-07-15 20:03:56.84573+07	BBCA	4128	ASK	1522	7
2026-07-15 20:03:56.84573+07	BBCA	4138	ASK	1769	8
2026-07-15 20:03:56.84573+07	BBCA	4148	ASK	1494	9
2026-07-15 20:03:57.858189+07	BBCA	4108	BID	1324	5
2026-07-15 20:03:57.858189+07	BBCA	4098	BID	1523	6
2026-07-15 20:03:57.858189+07	BBCA	4088	BID	1642	7
2026-07-15 20:03:57.858189+07	BBCA	4078	BID	1371	8
2026-07-15 20:03:57.858189+07	BBCA	4068	BID	1426	9
2026-07-15 20:03:57.858189+07	BBCA	4108	ASK	1468	5
2026-07-15 20:03:57.858189+07	BBCA	4118	ASK	1563	6
2026-07-15 20:03:57.858189+07	BBCA	4128	ASK	1321	7
2026-07-15 20:03:57.858189+07	BBCA	4138	ASK	1788	8
2026-07-15 20:03:57.858189+07	BBCA	4148	ASK	1739	9
2026-07-15 20:03:58.866542+07	BBCA	4108	BID	1171	5
2026-07-15 20:03:58.866542+07	BBCA	4098	BID	1127	6
2026-07-15 20:03:58.866542+07	BBCA	4088	BID	1617	7
2026-07-15 20:03:58.866542+07	BBCA	4078	BID	1398	8
2026-07-15 20:03:58.866542+07	BBCA	4068	BID	1860	9
2026-07-15 20:03:58.866542+07	BBCA	4108	ASK	1390	5
2026-07-15 20:03:58.866542+07	BBCA	4118	ASK	1125	6
2026-07-15 20:03:58.866542+07	BBCA	4128	ASK	1444	7
2026-07-15 20:03:58.866542+07	BBCA	4138	ASK	1771	8
2026-07-15 20:03:58.866542+07	BBCA	4148	ASK	1767	9
2026-07-15 20:03:59.87799+07	BBCA	4108	BID	1079	5
2026-07-15 20:03:59.87799+07	BBCA	4098	BID	1248	6
2026-07-15 20:03:59.87799+07	BBCA	4088	BID	1407	7
2026-07-15 20:03:59.87799+07	BBCA	4078	BID	1719	8
2026-07-15 20:03:59.87799+07	BBCA	4068	BID	1449	9
2026-07-15 20:03:59.87799+07	BBCA	4108	ASK	1084	5
2026-07-15 20:03:59.87799+07	BBCA	4118	ASK	1188	6
2026-07-15 20:03:59.87799+07	BBCA	4128	ASK	1671	7
2026-07-15 20:03:59.87799+07	BBCA	4138	ASK	1506	8
2026-07-15 20:03:59.87799+07	BBCA	4148	ASK	1575	9
2026-07-15 20:04:00.889092+07	BBCA	4108	BID	1049	5
2026-07-15 20:04:00.889092+07	BBCA	4098	BID	1540	6
2026-07-15 20:04:00.889092+07	BBCA	4088	BID	1295	7
2026-07-15 20:04:00.889092+07	BBCA	4078	BID	1540	8
2026-07-15 20:04:00.889092+07	BBCA	4068	BID	1857	9
2026-07-15 20:04:00.889092+07	BBCA	4108	ASK	1084	5
2026-07-15 20:04:00.889092+07	BBCA	4118	ASK	1108	6
2026-07-15 20:04:00.889092+07	BBCA	4128	ASK	1690	7
2026-07-15 20:04:00.889092+07	BBCA	4138	ASK	1669	8
2026-07-15 20:04:00.889092+07	BBCA	4148	ASK	1454	9
2026-07-15 20:04:01.898555+07	BBCA	4108	BID	1491	5
2026-07-15 20:04:01.898555+07	BBCA	4098	BID	1293	6
2026-07-15 20:04:01.898555+07	BBCA	4088	BID	1569	7
2026-07-15 20:04:01.898555+07	BBCA	4078	BID	1389	8
2026-07-15 20:04:01.898555+07	BBCA	4068	BID	1573	9
2026-07-15 20:04:01.898555+07	BBCA	4108	ASK	1083	5
2026-07-15 20:04:01.898555+07	BBCA	4118	ASK	1285	6
2026-07-15 20:04:01.898555+07	BBCA	4128	ASK	1475	7
2026-07-15 20:04:01.898555+07	BBCA	4138	ASK	1435	8
2026-07-15 20:04:01.898555+07	BBCA	4148	ASK	1877	9
2026-07-15 20:04:02.909024+07	BBCA	4108	BID	1299	5
2026-07-15 20:04:02.909024+07	BBCA	4098	BID	1408	6
2026-07-15 20:04:02.909024+07	BBCA	4088	BID	1377	7
2026-07-15 20:04:02.909024+07	BBCA	4078	BID	1401	8
2026-07-15 20:04:02.909024+07	BBCA	4068	BID	1769	9
2026-07-15 20:04:02.909024+07	BBCA	4108	ASK	1166	5
2026-07-15 20:04:02.909024+07	BBCA	4118	ASK	1171	6
2026-07-15 20:04:02.909024+07	BBCA	4128	ASK	1442	7
2026-07-15 20:04:02.909024+07	BBCA	4138	ASK	1791	8
2026-07-15 20:04:02.909024+07	BBCA	4148	ASK	1755	9
2026-07-15 20:04:03.920218+07	BBCA	4108	BID	1495	5
2026-07-15 20:04:03.920218+07	BBCA	4098	BID	1305	6
2026-07-15 20:04:03.920218+07	BBCA	4088	BID	1533	7
2026-07-15 20:04:03.920218+07	BBCA	4078	BID	1681	8
2026-07-15 20:04:03.920218+07	BBCA	4068	BID	1733	9
2026-07-15 20:04:03.920218+07	BBCA	4108	ASK	1341	5
2026-07-15 20:04:03.920218+07	BBCA	4118	ASK	1522	6
2026-07-15 20:04:03.920218+07	BBCA	4128	ASK	1656	7
2026-07-15 20:04:03.920218+07	BBCA	4138	ASK	1673	8
2026-07-15 20:04:03.920218+07	BBCA	4148	ASK	1763	9
2026-07-15 20:04:04.931131+07	BBCA	4108	BID	1136	5
2026-07-15 20:04:04.931131+07	BBCA	4098	BID	1137	6
2026-07-15 20:04:04.931131+07	BBCA	4088	BID	1584	7
2026-07-15 20:04:04.931131+07	BBCA	4078	BID	1776	8
2026-07-15 20:04:04.931131+07	BBCA	4068	BID	1760	9
2026-07-15 20:04:04.931131+07	BBCA	4108	ASK	1297	5
2026-07-15 20:04:04.931131+07	BBCA	4118	ASK	1180	6
2026-07-15 20:04:04.931131+07	BBCA	4128	ASK	1284	7
2026-07-15 20:04:04.931131+07	BBCA	4138	ASK	1395	8
2026-07-15 20:04:04.931131+07	BBCA	4148	ASK	1480	9
2026-07-15 20:04:05.940829+07	BBCA	4108	BID	1277	5
2026-07-15 20:04:05.940829+07	BBCA	4098	BID	1139	6
2026-07-15 20:04:05.940829+07	BBCA	4088	BID	1691	7
2026-07-15 20:04:05.940829+07	BBCA	4078	BID	1518	8
2026-07-15 20:04:05.940829+07	BBCA	4068	BID	1508	9
2026-07-15 20:04:05.940829+07	BBCA	4108	ASK	1297	5
2026-07-15 20:04:05.940829+07	BBCA	4118	ASK	1186	6
2026-07-15 20:04:05.940829+07	BBCA	4128	ASK	1650	7
2026-07-15 20:04:05.940829+07	BBCA	4138	ASK	1782	8
2026-07-15 20:04:05.940829+07	BBCA	4148	ASK	1535	9
2026-07-15 20:04:06.95106+07	BBCA	4108	BID	58584	5
2026-07-15 20:04:06.95106+07	BBCA	4098	BID	1180	6
2026-07-15 20:04:06.95106+07	BBCA	4088	BID	1261	7
2026-07-15 20:04:06.95106+07	BBCA	4078	BID	1760	8
2026-07-15 20:04:06.95106+07	BBCA	4068	BID	1631	9
2026-07-15 20:04:06.95106+07	BBCA	4108	ASK	1065	5
2026-07-15 20:04:06.95106+07	BBCA	4118	ASK	1329	6
2026-07-15 20:04:06.95106+07	BBCA	4128	ASK	1274	7
2026-07-15 20:04:06.95106+07	BBCA	4138	ASK	1533	8
2026-07-15 20:04:06.95106+07	BBCA	4148	ASK	1567	9
2026-07-15 20:04:07.959681+07	BBCA	4108	BID	54239	5
2026-07-15 20:04:07.959681+07	BBCA	4098	BID	1138	6
2026-07-15 20:04:07.959681+07	BBCA	4088	BID	1299	7
2026-07-15 20:04:07.959681+07	BBCA	4078	BID	1514	8
2026-07-15 20:04:07.959681+07	BBCA	4068	BID	1458	9
2026-07-15 20:04:07.959681+07	BBCA	4108	ASK	1326	5
2026-07-15 20:04:07.959681+07	BBCA	4118	ASK	1377	6
2026-07-15 20:04:07.959681+07	BBCA	4128	ASK	1459	7
2026-07-15 20:04:07.959681+07	BBCA	4138	ASK	1770	8
2026-07-15 20:04:07.959681+07	BBCA	4148	ASK	1773	9
2026-07-15 20:04:08.972546+07	BBCA	4108	BID	58998	5
2026-07-15 20:04:08.972546+07	BBCA	4098	BID	1314	6
2026-07-15 20:04:08.972546+07	BBCA	4088	BID	1389	7
2026-07-15 20:04:08.972546+07	BBCA	4078	BID	1320	8
2026-07-15 20:04:08.972546+07	BBCA	4068	BID	1855	9
2026-07-15 20:04:08.972546+07	BBCA	4108	ASK	1250	5
2026-07-15 20:04:08.972546+07	BBCA	4118	ASK	1100	6
2026-07-15 20:04:08.972546+07	BBCA	4128	ASK	1252	7
2026-07-15 20:04:08.972546+07	BBCA	4138	ASK	1536	8
2026-07-15 20:04:08.972546+07	BBCA	4148	ASK	1493	9
2026-07-15 20:04:09.979979+07	BBCA	4108	BID	56069	5
2026-07-15 20:04:09.979979+07	BBCA	4098	BID	1286	6
2026-07-15 20:04:09.979979+07	BBCA	4088	BID	1224	7
2026-07-15 20:04:09.979979+07	BBCA	4078	BID	1477	8
2026-07-15 20:04:09.979979+07	BBCA	4068	BID	1630	9
2026-07-15 20:04:09.979979+07	BBCA	4108	ASK	1117	5
2026-07-15 20:04:09.979979+07	BBCA	4118	ASK	1276	6
2026-07-15 20:04:09.979979+07	BBCA	4128	ASK	1629	7
2026-07-15 20:04:09.979979+07	BBCA	4138	ASK	1551	8
2026-07-15 20:04:09.979979+07	BBCA	4148	ASK	1573	9
2026-07-15 20:04:10.989865+07	BBCA	4108	BID	52670	5
2026-07-15 20:04:10.989865+07	BBCA	4098	BID	1438	6
2026-07-15 20:04:10.989865+07	BBCA	4088	BID	1650	7
2026-07-15 20:04:10.989865+07	BBCA	4078	BID	1562	8
2026-07-15 20:04:10.989865+07	BBCA	4068	BID	1725	9
2026-07-15 20:04:10.989865+07	BBCA	4108	ASK	1165	5
2026-07-15 20:04:10.989865+07	BBCA	4118	ASK	1123	6
2026-07-15 20:04:10.989865+07	BBCA	4128	ASK	1641	7
2026-07-15 20:04:10.989865+07	BBCA	4138	ASK	1617	8
2026-07-15 20:04:10.989865+07	BBCA	4148	ASK	1517	9
2026-07-15 20:04:11.997016+07	BBCA	4108	BID	55760	5
2026-07-15 20:04:11.997016+07	BBCA	4098	BID	1309	6
2026-07-15 20:04:11.997016+07	BBCA	4088	BID	1270	7
2026-07-15 20:04:11.997016+07	BBCA	4078	BID	1474	8
2026-07-15 20:04:11.997016+07	BBCA	4068	BID	1821	9
2026-07-15 20:04:11.997016+07	BBCA	4108	ASK	1131	5
2026-07-15 20:04:11.997016+07	BBCA	4118	ASK	1379	6
2026-07-15 20:04:11.997016+07	BBCA	4128	ASK	1592	7
2026-07-15 20:04:11.997016+07	BBCA	4138	ASK	1485	8
2026-07-15 20:04:11.997016+07	BBCA	4148	ASK	1528	9
2026-07-15 20:04:13.00624+07	BBCA	4108	BID	53776	5
2026-07-15 20:04:13.00624+07	BBCA	4098	BID	1491	6
2026-07-15 20:04:13.00624+07	BBCA	4088	BID	1253	7
2026-07-15 20:04:13.00624+07	BBCA	4078	BID	1636	8
2026-07-15 20:04:13.00624+07	BBCA	4068	BID	1488	9
2026-07-15 20:04:13.00624+07	BBCA	4108	ASK	1489	5
2026-07-15 20:04:13.00624+07	BBCA	4118	ASK	1385	6
2026-07-15 20:04:13.00624+07	BBCA	4128	ASK	1526	7
2026-07-15 20:04:13.00624+07	BBCA	4138	ASK	1486	8
2026-07-15 20:04:13.00624+07	BBCA	4148	ASK	1402	9
2026-07-15 20:04:14.013462+07	BBCA	4108	BID	53285	5
2026-07-15 20:04:14.013462+07	BBCA	4098	BID	1148	6
2026-07-15 20:04:14.013462+07	BBCA	4088	BID	1490	7
2026-07-15 20:04:14.013462+07	BBCA	4078	BID	1429	8
2026-07-15 20:04:14.013462+07	BBCA	4068	BID	1607	9
2026-07-15 20:04:14.013462+07	BBCA	4108	ASK	1052	5
2026-07-15 20:04:14.013462+07	BBCA	4118	ASK	1484	6
2026-07-15 20:04:14.013462+07	BBCA	4128	ASK	1549	7
2026-07-15 20:04:14.013462+07	BBCA	4138	ASK	1611	8
2026-07-15 20:04:14.013462+07	BBCA	4148	ASK	1547	9
2026-07-15 20:04:15.027453+07	BBCA	4108	BID	56014	5
2026-07-15 20:04:15.027453+07	BBCA	4098	BID	1245	6
2026-07-15 20:04:15.027453+07	BBCA	4088	BID	1381	7
2026-07-15 20:04:15.027453+07	BBCA	4078	BID	1792	8
2026-07-15 20:04:15.027453+07	BBCA	4068	BID	1565	9
2026-07-15 20:04:15.027453+07	BBCA	4108	ASK	1288	5
2026-07-15 20:04:15.027453+07	BBCA	4118	ASK	1296	6
2026-07-15 20:04:15.027453+07	BBCA	4128	ASK	1478	7
2026-07-15 20:04:15.027453+07	BBCA	4138	ASK	1391	8
2026-07-15 20:04:15.027453+07	BBCA	4148	ASK	1523	9
2026-07-15 20:04:16.040598+07	BBCA	4108	BID	52408	5
2026-07-15 20:04:16.040598+07	BBCA	4098	BID	1476	6
2026-07-15 20:04:16.040598+07	BBCA	4088	BID	1460	7
2026-07-15 20:04:16.040598+07	BBCA	4078	BID	1563	8
2026-07-15 20:04:16.040598+07	BBCA	4068	BID	1796	9
2026-07-15 20:04:16.040598+07	BBCA	4108	ASK	1391	5
2026-07-15 20:04:16.040598+07	BBCA	4118	ASK	1323	6
2026-07-15 20:04:16.040598+07	BBCA	4128	ASK	1206	7
2026-07-15 20:04:16.040598+07	BBCA	4138	ASK	1592	8
2026-07-15 20:04:16.040598+07	BBCA	4148	ASK	1896	9
2026-07-15 20:04:17.050778+07	BBCA	4108	BID	53664	5
2026-07-15 20:04:17.050778+07	BBCA	4098	BID	1541	6
2026-07-15 20:04:17.050778+07	BBCA	4088	BID	1483	7
2026-07-15 20:04:17.050778+07	BBCA	4078	BID	1619	8
2026-07-15 20:04:17.050778+07	BBCA	4068	BID	1825	9
2026-07-15 20:04:17.050778+07	BBCA	4108	ASK	1226	5
2026-07-15 20:04:17.050778+07	BBCA	4118	ASK	1562	6
2026-07-15 20:04:17.050778+07	BBCA	4128	ASK	1247	7
2026-07-15 20:04:17.050778+07	BBCA	4138	ASK	1782	8
2026-07-15 20:04:17.050778+07	BBCA	4148	ASK	1477	9
2026-07-15 20:04:18.057366+07	BBCA	4108	BID	51834	5
2026-07-15 20:04:18.057366+07	BBCA	4098	BID	1162	6
2026-07-15 20:04:18.057366+07	BBCA	4088	BID	1400	7
2026-07-15 20:04:18.057366+07	BBCA	4078	BID	1703	8
2026-07-15 20:04:18.057366+07	BBCA	4068	BID	1441	9
2026-07-15 20:04:18.057366+07	BBCA	4108	ASK	1235	5
2026-07-15 20:04:18.057366+07	BBCA	4118	ASK	1393	6
2026-07-15 20:04:18.057366+07	BBCA	4128	ASK	1205	7
2026-07-15 20:04:18.057366+07	BBCA	4138	ASK	1397	8
2026-07-15 20:04:18.057366+07	BBCA	4148	ASK	1680	9
2026-07-15 20:04:19.066686+07	BBCA	4108	BID	56805	5
2026-07-15 20:04:19.066686+07	BBCA	4098	BID	1334	6
2026-07-15 20:04:19.066686+07	BBCA	4088	BID	1658	7
2026-07-15 20:04:19.066686+07	BBCA	4078	BID	1304	8
2026-07-15 20:04:19.066686+07	BBCA	4068	BID	1648	9
2026-07-15 20:04:19.066686+07	BBCA	4108	ASK	1140	5
2026-07-15 20:04:19.066686+07	BBCA	4118	ASK	1420	6
2026-07-15 20:04:19.066686+07	BBCA	4128	ASK	1286	7
2026-07-15 20:04:19.066686+07	BBCA	4138	ASK	1671	8
2026-07-15 20:04:19.066686+07	BBCA	4148	ASK	1682	9
2026-07-15 20:04:20.073466+07	BBCA	4108	BID	54278	5
2026-07-15 20:04:20.073466+07	BBCA	4098	BID	1323	6
2026-07-15 20:04:20.073466+07	BBCA	4088	BID	1499	7
2026-07-15 20:04:20.073466+07	BBCA	4078	BID	1630	8
2026-07-15 20:04:20.073466+07	BBCA	4068	BID	1526	9
2026-07-15 20:04:20.073466+07	BBCA	4108	ASK	1412	5
2026-07-15 20:04:20.073466+07	BBCA	4118	ASK	1522	6
2026-07-15 20:04:20.073466+07	BBCA	4128	ASK	1548	7
2026-07-15 20:04:20.073466+07	BBCA	4138	ASK	1631	8
2026-07-15 20:04:20.073466+07	BBCA	4148	ASK	1419	9
2026-07-15 20:04:21.081859+07	BBCA	4108	BID	52008	5
2026-07-15 20:04:21.081859+07	BBCA	4098	BID	1334	6
2026-07-15 20:04:21.081859+07	BBCA	4088	BID	1619	7
2026-07-15 20:04:21.081859+07	BBCA	4078	BID	1563	8
2026-07-15 20:04:21.081859+07	BBCA	4068	BID	1611	9
2026-07-15 20:04:21.081859+07	BBCA	4108	ASK	1021	5
2026-07-15 20:04:21.081859+07	BBCA	4118	ASK	1435	6
2026-07-15 20:04:21.081859+07	BBCA	4128	ASK	1580	7
2026-07-15 20:04:21.081859+07	BBCA	4138	ASK	1532	8
2026-07-15 20:04:21.081859+07	BBCA	4148	ASK	1440	9
2026-07-15 20:04:22.0889+07	BBCA	4108	BID	56821	5
2026-07-15 20:04:22.0889+07	BBCA	4098	BID	1459	6
2026-07-15 20:04:22.0889+07	BBCA	4088	BID	1414	7
2026-07-15 20:04:22.0889+07	BBCA	4078	BID	1714	8
2026-07-15 20:04:22.0889+07	BBCA	4068	BID	1511	9
2026-07-15 20:04:22.0889+07	BBCA	4108	ASK	1455	5
2026-07-15 20:04:22.0889+07	BBCA	4118	ASK	1114	6
2026-07-15 20:04:22.0889+07	BBCA	4128	ASK	1384	7
2026-07-15 20:04:22.0889+07	BBCA	4138	ASK	1330	8
2026-07-15 20:04:22.0889+07	BBCA	4148	ASK	1518	9
2026-07-15 20:04:23.095148+07	BBCA	4108	BID	58614	5
2026-07-15 20:04:23.095148+07	BBCA	4098	BID	1578	6
2026-07-15 20:04:23.095148+07	BBCA	4088	BID	1324	7
2026-07-15 20:04:23.095148+07	BBCA	4078	BID	1726	8
2026-07-15 20:04:23.095148+07	BBCA	4068	BID	1493	9
2026-07-15 20:04:23.095148+07	BBCA	4108	ASK	1306	5
2026-07-15 20:04:23.095148+07	BBCA	4118	ASK	1404	6
2026-07-15 20:04:23.095148+07	BBCA	4128	ASK	1646	7
2026-07-15 20:04:23.095148+07	BBCA	4138	ASK	1742	8
2026-07-15 20:04:23.095148+07	BBCA	4148	ASK	1540	9
2026-07-15 20:04:24.104932+07	BBCA	4108	BID	51100	5
2026-07-15 20:04:24.104932+07	BBCA	4098	BID	1523	6
2026-07-15 20:04:24.104932+07	BBCA	4088	BID	1569	7
2026-07-15 20:04:24.104932+07	BBCA	4078	BID	1693	8
2026-07-15 20:04:24.104932+07	BBCA	4068	BID	1644	9
2026-07-15 20:04:24.104932+07	BBCA	4108	ASK	1139	5
2026-07-15 20:04:24.104932+07	BBCA	4118	ASK	1257	6
2026-07-15 20:04:24.104932+07	BBCA	4128	ASK	1483	7
2026-07-15 20:04:24.104932+07	BBCA	4138	ASK	1710	8
2026-07-15 20:04:24.104932+07	BBCA	4148	ASK	1610	9
2026-07-15 20:04:25.113264+07	BBCA	4108	BID	52293	5
2026-07-15 20:04:25.113264+07	BBCA	4098	BID	1468	6
2026-07-15 20:04:25.113264+07	BBCA	4088	BID	1276	7
2026-07-15 20:04:25.113264+07	BBCA	4078	BID	1703	8
2026-07-15 20:04:25.113264+07	BBCA	4068	BID	1884	9
2026-07-15 20:04:25.113264+07	BBCA	4108	ASK	1027	5
2026-07-15 20:04:25.113264+07	BBCA	4118	ASK	1368	6
2026-07-15 20:04:25.113264+07	BBCA	4128	ASK	1361	7
2026-07-15 20:04:25.113264+07	BBCA	4138	ASK	1460	8
2026-07-15 20:04:25.113264+07	BBCA	4148	ASK	1445	9
2026-07-15 20:04:26.122647+07	BBCA	4108	BID	50874	5
2026-07-15 20:04:26.122647+07	BBCA	4098	BID	1192	6
2026-07-15 20:04:26.122647+07	BBCA	4088	BID	1480	7
2026-07-15 20:04:26.122647+07	BBCA	4078	BID	1320	8
2026-07-15 20:04:26.122647+07	BBCA	4068	BID	1798	9
2026-07-15 20:04:26.122647+07	BBCA	4108	ASK	1145	5
2026-07-15 20:04:26.122647+07	BBCA	4118	ASK	1540	6
2026-07-15 20:04:26.122647+07	BBCA	4128	ASK	1222	7
2026-07-15 20:04:26.122647+07	BBCA	4138	ASK	1487	8
2026-07-15 20:04:26.122647+07	BBCA	4148	ASK	1849	9
2026-07-15 20:04:27.130393+07	BBCA	4108	BID	50691	5
2026-07-15 20:04:27.130393+07	BBCA	4098	BID	1413	6
2026-07-15 20:04:27.130393+07	BBCA	4088	BID	1267	7
2026-07-15 20:04:27.130393+07	BBCA	4078	BID	1370	8
2026-07-15 20:04:27.130393+07	BBCA	4068	BID	1771	9
2026-07-15 20:04:27.130393+07	BBCA	4108	ASK	1396	5
2026-07-15 20:04:27.130393+07	BBCA	4118	ASK	1370	6
2026-07-15 20:04:27.130393+07	BBCA	4128	ASK	1535	7
2026-07-15 20:04:27.130393+07	BBCA	4138	ASK	1628	8
2026-07-15 20:04:27.130393+07	BBCA	4148	ASK	1718	9
2026-07-15 20:04:28.140185+07	BBCA	4108	BID	55509	5
2026-07-15 20:04:28.140185+07	BBCA	4098	BID	1390	6
2026-07-15 20:04:28.140185+07	BBCA	4088	BID	1681	7
2026-07-15 20:04:28.140185+07	BBCA	4078	BID	1536	8
2026-07-15 20:04:28.140185+07	BBCA	4068	BID	1424	9
2026-07-15 20:04:28.140185+07	BBCA	4108	ASK	1058	5
2026-07-15 20:04:28.140185+07	BBCA	4118	ASK	1547	6
2026-07-15 20:04:28.140185+07	BBCA	4128	ASK	1404	7
2026-07-15 20:04:28.140185+07	BBCA	4138	ASK	1413	8
2026-07-15 20:04:28.140185+07	BBCA	4148	ASK	1408	9
2026-07-15 20:04:29.147486+07	BBCA	4108	BID	54254	5
2026-07-15 20:04:29.147486+07	BBCA	4098	BID	1240	6
2026-07-15 20:04:29.147486+07	BBCA	4088	BID	1698	7
2026-07-15 20:04:29.147486+07	BBCA	4078	BID	1558	8
2026-07-15 20:04:29.147486+07	BBCA	4068	BID	1595	9
2026-07-15 20:04:29.147486+07	BBCA	4108	ASK	1060	5
2026-07-15 20:04:29.147486+07	BBCA	4118	ASK	1164	6
2026-07-15 20:04:29.147486+07	BBCA	4128	ASK	1228	7
2026-07-15 20:04:29.147486+07	BBCA	4138	ASK	1647	8
2026-07-15 20:04:29.147486+07	BBCA	4148	ASK	1484	9
2026-07-15 20:04:30.157671+07	BBCA	4108	BID	55020	5
2026-07-15 20:04:30.157671+07	BBCA	4098	BID	1158	6
2026-07-15 20:04:30.157671+07	BBCA	4088	BID	1292	7
2026-07-15 20:04:30.157671+07	BBCA	4078	BID	1608	8
2026-07-15 20:04:30.157671+07	BBCA	4068	BID	1497	9
2026-07-15 20:04:30.157671+07	BBCA	4108	ASK	1202	5
2026-07-15 20:04:30.157671+07	BBCA	4118	ASK	1243	6
2026-07-15 20:04:30.157671+07	BBCA	4128	ASK	1590	7
2026-07-15 20:04:30.157671+07	BBCA	4138	ASK	1668	8
2026-07-15 20:04:30.157671+07	BBCA	4148	ASK	1503	9
2026-07-15 20:04:31.164937+07	BBCA	4108	BID	50122	5
2026-07-15 20:04:31.164937+07	BBCA	4098	BID	1272	6
2026-07-15 20:04:31.164937+07	BBCA	4088	BID	1627	7
2026-07-15 20:04:31.164937+07	BBCA	4078	BID	1674	8
2026-07-15 20:04:31.164937+07	BBCA	4068	BID	1730	9
2026-07-15 20:04:31.164937+07	BBCA	4108	ASK	1019	5
2026-07-15 20:04:31.164937+07	BBCA	4118	ASK	1142	6
2026-07-15 20:04:31.164937+07	BBCA	4128	ASK	1660	7
2026-07-15 20:04:31.164937+07	BBCA	4138	ASK	1603	8
2026-07-15 20:04:31.164937+07	BBCA	4148	ASK	1891	9
2026-07-15 20:04:32.173187+07	BBCA	4108	BID	58320	5
2026-07-15 20:04:32.173187+07	BBCA	4098	BID	1210	6
2026-07-15 20:04:32.173187+07	BBCA	4088	BID	1372	7
2026-07-15 20:04:32.173187+07	BBCA	4078	BID	1623	8
2026-07-15 20:04:32.173187+07	BBCA	4068	BID	1485	9
2026-07-15 20:04:32.173187+07	BBCA	4108	ASK	1461	5
2026-07-15 20:04:32.173187+07	BBCA	4118	ASK	1503	6
2026-07-15 20:04:32.173187+07	BBCA	4128	ASK	1423	7
2026-07-15 20:04:32.173187+07	BBCA	4138	ASK	1712	8
2026-07-15 20:04:32.173187+07	BBCA	4148	ASK	1660	9
2026-07-15 20:04:33.180456+07	BBCA	4108	BID	54069	5
2026-07-15 20:04:33.180456+07	BBCA	4098	BID	1435	6
2026-07-15 20:04:33.180456+07	BBCA	4088	BID	1655	7
2026-07-15 20:04:33.180456+07	BBCA	4078	BID	1500	8
2026-07-15 20:04:33.180456+07	BBCA	4068	BID	1673	9
2026-07-15 20:04:33.180456+07	BBCA	4108	ASK	1318	5
2026-07-15 20:04:33.180456+07	BBCA	4118	ASK	1433	6
2026-07-15 20:04:33.180456+07	BBCA	4128	ASK	1595	7
2026-07-15 20:04:33.180456+07	BBCA	4138	ASK	1771	8
2026-07-15 20:04:33.180456+07	BBCA	4148	ASK	1729	9
2026-07-15 20:04:34.18835+07	BBCA	4108	BID	53678	5
2026-07-15 20:04:34.18835+07	BBCA	4098	BID	1357	6
2026-07-15 20:04:34.18835+07	BBCA	4088	BID	1207	7
2026-07-15 20:04:34.18835+07	BBCA	4078	BID	1715	8
2026-07-15 20:04:34.18835+07	BBCA	4068	BID	1768	9
2026-07-15 20:04:34.18835+07	BBCA	4108	ASK	1229	5
2026-07-15 20:04:34.18835+07	BBCA	4118	ASK	1350	6
2026-07-15 20:04:34.18835+07	BBCA	4128	ASK	1662	7
2026-07-15 20:04:34.18835+07	BBCA	4138	ASK	1689	8
2026-07-15 20:04:34.18835+07	BBCA	4148	ASK	1463	9
2026-07-15 20:04:35.192943+07	BBCA	4108	BID	57885	5
2026-07-15 20:04:35.192943+07	BBCA	4098	BID	1419	6
2026-07-15 20:04:35.192943+07	BBCA	4088	BID	1600	7
2026-07-15 20:04:35.192943+07	BBCA	4078	BID	1334	8
2026-07-15 20:04:35.192943+07	BBCA	4068	BID	1536	9
2026-07-15 20:04:35.192943+07	BBCA	4108	ASK	1358	5
2026-07-15 20:04:35.192943+07	BBCA	4118	ASK	1232	6
2026-07-15 20:04:35.192943+07	BBCA	4128	ASK	1442	7
2026-07-15 20:04:35.192943+07	BBCA	4138	ASK	1415	8
2026-07-15 20:04:35.192943+07	BBCA	4148	ASK	1663	9
2026-07-15 20:04:36.200138+07	BBCA	4108	BID	53043	5
2026-07-15 20:04:36.200138+07	BBCA	4098	BID	1346	6
2026-07-15 20:04:36.200138+07	BBCA	4088	BID	1690	7
2026-07-15 20:04:36.200138+07	BBCA	4078	BID	1546	8
2026-07-15 20:04:36.200138+07	BBCA	4068	BID	1719	9
2026-07-15 20:04:36.200138+07	BBCA	4108	ASK	1436	5
2026-07-15 20:04:36.200138+07	BBCA	4118	ASK	1354	6
2026-07-15 20:04:36.200138+07	BBCA	4128	ASK	1677	7
2026-07-15 20:04:36.200138+07	BBCA	4138	ASK	1553	8
2026-07-15 20:04:36.200138+07	BBCA	4148	ASK	1602	9
2026-07-15 20:04:37.207406+07	BBCA	4108	BID	57473	5
2026-07-15 20:04:37.207406+07	BBCA	4098	BID	1241	6
2026-07-15 20:04:37.207406+07	BBCA	4088	BID	1443	7
2026-07-15 20:04:37.207406+07	BBCA	4078	BID	1303	8
2026-07-15 20:04:37.207406+07	BBCA	4068	BID	1547	9
2026-07-15 20:04:37.207406+07	BBCA	4108	ASK	1451	5
2026-07-15 20:04:37.207406+07	BBCA	4118	ASK	1124	6
2026-07-15 20:04:37.207406+07	BBCA	4128	ASK	1317	7
2026-07-15 20:04:37.207406+07	BBCA	4138	ASK	1393	8
2026-07-15 20:04:37.207406+07	BBCA	4148	ASK	1886	9
2026-07-15 20:04:38.211079+07	BBCA	4108	BID	59519	5
2026-07-15 20:04:38.211079+07	BBCA	4098	BID	1501	6
2026-07-15 20:04:38.211079+07	BBCA	4088	BID	1330	7
2026-07-15 20:04:38.211079+07	BBCA	4078	BID	1521	8
2026-07-15 20:04:38.211079+07	BBCA	4068	BID	1456	9
2026-07-15 20:04:38.211079+07	BBCA	4108	ASK	1453	5
2026-07-15 20:04:38.211079+07	BBCA	4118	ASK	1189	6
2026-07-15 20:04:38.211079+07	BBCA	4128	ASK	1563	7
2026-07-15 20:04:38.211079+07	BBCA	4138	ASK	1401	8
2026-07-15 20:04:38.211079+07	BBCA	4148	ASK	1681	9
2026-07-15 20:04:39.219837+07	BBCA	4108	BID	51474	5
2026-07-15 20:04:39.219837+07	BBCA	4098	BID	1289	6
2026-07-15 20:04:39.219837+07	BBCA	4088	BID	1320	7
2026-07-15 20:04:39.219837+07	BBCA	4078	BID	1436	8
2026-07-15 20:04:39.219837+07	BBCA	4068	BID	1891	9
2026-07-15 20:04:39.219837+07	BBCA	4108	ASK	1075	5
2026-07-15 20:04:39.219837+07	BBCA	4118	ASK	1519	6
2026-07-15 20:04:39.219837+07	BBCA	4128	ASK	1564	7
2026-07-15 20:04:39.219837+07	BBCA	4138	ASK	1667	8
2026-07-15 20:04:39.219837+07	BBCA	4148	ASK	1586	9
2026-07-15 20:04:40.223867+07	BBCA	4108	BID	55282	5
2026-07-15 20:04:40.223867+07	BBCA	4098	BID	1182	6
2026-07-15 20:04:40.223867+07	BBCA	4088	BID	1319	7
2026-07-15 20:04:40.223867+07	BBCA	4078	BID	1556	8
2026-07-15 20:04:40.223867+07	BBCA	4068	BID	1479	9
2026-07-15 20:04:40.223867+07	BBCA	4108	ASK	1039	5
2026-07-15 20:04:40.223867+07	BBCA	4118	ASK	1595	6
2026-07-15 20:04:40.223867+07	BBCA	4128	ASK	1433	7
2026-07-15 20:04:40.223867+07	BBCA	4138	ASK	1352	8
2026-07-15 20:04:40.223867+07	BBCA	4148	ASK	1487	9
2026-07-15 20:04:41.228725+07	BBCA	4108	BID	51981	5
2026-07-15 20:04:41.228725+07	BBCA	4098	BID	1200	6
2026-07-15 20:04:41.228725+07	BBCA	4088	BID	1541	7
2026-07-15 20:04:41.228725+07	BBCA	4078	BID	1692	8
2026-07-15 20:04:41.228725+07	BBCA	4068	BID	1793	9
2026-07-15 20:04:41.228725+07	BBCA	4108	ASK	1219	5
2026-07-15 20:04:41.228725+07	BBCA	4118	ASK	1185	6
2026-07-15 20:04:41.228725+07	BBCA	4128	ASK	1593	7
2026-07-15 20:04:41.228725+07	BBCA	4138	ASK	1414	8
2026-07-15 20:04:41.228725+07	BBCA	4148	ASK	1816	9
2026-07-15 20:04:42.238177+07	BBCA	4108	BID	51889	5
2026-07-15 20:04:42.238177+07	BBCA	4098	BID	1484	6
2026-07-15 20:04:42.238177+07	BBCA	4088	BID	1410	7
2026-07-15 20:04:42.238177+07	BBCA	4078	BID	1630	8
2026-07-15 20:04:42.238177+07	BBCA	4068	BID	1567	9
2026-07-15 20:04:42.238177+07	BBCA	4108	ASK	1260	5
2026-07-15 20:04:42.238177+07	BBCA	4118	ASK	1155	6
2026-07-15 20:04:42.238177+07	BBCA	4128	ASK	1258	7
2026-07-15 20:04:42.238177+07	BBCA	4138	ASK	1533	8
2026-07-15 20:04:42.238177+07	BBCA	4148	ASK	1616	9
2026-07-15 20:04:43.242115+07	BBCA	4108	BID	56912	5
2026-07-15 20:04:43.242115+07	BBCA	4098	BID	1432	6
2026-07-15 20:04:43.242115+07	BBCA	4088	BID	1370	7
2026-07-15 20:04:43.242115+07	BBCA	4078	BID	1388	8
2026-07-15 20:04:43.242115+07	BBCA	4068	BID	1600	9
2026-07-15 20:04:43.242115+07	BBCA	4108	ASK	1252	5
2026-07-15 20:04:43.242115+07	BBCA	4118	ASK	1287	6
2026-07-15 20:04:43.242115+07	BBCA	4128	ASK	1495	7
2026-07-15 20:04:43.242115+07	BBCA	4138	ASK	1433	8
2026-07-15 20:04:43.242115+07	BBCA	4148	ASK	1644	9
2026-07-15 20:04:44.249884+07	BBCA	4108	BID	55657	5
2026-07-15 20:04:44.249884+07	BBCA	4098	BID	1571	6
2026-07-15 20:04:44.249884+07	BBCA	4088	BID	1345	7
2026-07-15 20:04:44.249884+07	BBCA	4078	BID	1352	8
2026-07-15 20:04:44.249884+07	BBCA	4068	BID	1674	9
2026-07-15 20:04:44.249884+07	BBCA	4108	ASK	1331	5
2026-07-15 20:04:44.249884+07	BBCA	4118	ASK	1315	6
2026-07-15 20:04:44.249884+07	BBCA	4128	ASK	1430	7
2026-07-15 20:04:44.249884+07	BBCA	4138	ASK	1431	8
2026-07-15 20:04:44.249884+07	BBCA	4148	ASK	1573	9
2026-07-15 20:04:45.256699+07	BBCA	4108	BID	52464	5
2026-07-15 20:04:45.256699+07	BBCA	4098	BID	1494	6
2026-07-15 20:04:45.256699+07	BBCA	4088	BID	1647	7
2026-07-15 20:04:45.256699+07	BBCA	4078	BID	1492	8
2026-07-15 20:04:45.256699+07	BBCA	4068	BID	1660	9
2026-07-15 20:04:45.256699+07	BBCA	4108	ASK	1123	5
2026-07-15 20:04:45.256699+07	BBCA	4118	ASK	1389	6
2026-07-15 20:04:45.256699+07	BBCA	4128	ASK	1373	7
2026-07-15 20:04:45.256699+07	BBCA	4138	ASK	1701	8
2026-07-15 20:04:45.256699+07	BBCA	4148	ASK	1610	9
2026-07-15 20:04:46.260822+07	BBCA	4108	BID	56193	5
2026-07-15 20:04:46.260822+07	BBCA	4098	BID	1420	6
2026-07-15 20:04:46.260822+07	BBCA	4088	BID	1259	7
2026-07-15 20:04:46.260822+07	BBCA	4078	BID	1542	8
2026-07-15 20:04:46.260822+07	BBCA	4068	BID	1737	9
2026-07-15 20:04:46.260822+07	BBCA	4108	ASK	1131	5
2026-07-15 20:04:46.260822+07	BBCA	4118	ASK	1355	6
2026-07-15 20:04:46.260822+07	BBCA	4128	ASK	1581	7
2026-07-15 20:04:46.260822+07	BBCA	4138	ASK	1780	8
2026-07-15 20:04:46.260822+07	BBCA	4148	ASK	1517	9
2026-07-15 20:04:47.268657+07	BBCA	4108	BID	51195	5
2026-07-15 20:04:47.268657+07	BBCA	4098	BID	1463	6
2026-07-15 20:04:47.268657+07	BBCA	4088	BID	1213	7
2026-07-15 20:04:47.268657+07	BBCA	4078	BID	1707	8
2026-07-15 20:04:47.268657+07	BBCA	4068	BID	1482	9
2026-07-15 20:04:47.268657+07	BBCA	4108	ASK	1228	5
2026-07-15 20:04:47.268657+07	BBCA	4118	ASK	1546	6
2026-07-15 20:04:47.268657+07	BBCA	4128	ASK	1330	7
2026-07-15 20:04:47.268657+07	BBCA	4138	ASK	1576	8
2026-07-15 20:04:47.268657+07	BBCA	4148	ASK	1875	9
2026-07-15 20:04:48.275597+07	BBCA	4108	BID	55029	5
2026-07-15 20:04:48.275597+07	BBCA	4098	BID	1242	6
2026-07-15 20:04:48.275597+07	BBCA	4088	BID	1443	7
2026-07-15 20:04:48.275597+07	BBCA	4078	BID	1746	8
2026-07-15 20:04:48.275597+07	BBCA	4068	BID	1892	9
2026-07-15 20:04:48.275597+07	BBCA	4108	ASK	1166	5
2026-07-15 20:04:48.275597+07	BBCA	4118	ASK	1168	6
2026-07-15 20:04:48.275597+07	BBCA	4128	ASK	1259	7
2026-07-15 20:04:48.275597+07	BBCA	4138	ASK	1509	8
2026-07-15 20:04:48.275597+07	BBCA	4148	ASK	1507	9
2026-07-15 20:04:49.283579+07	BBCA	4108	BID	58154	5
2026-07-15 20:04:49.283579+07	BBCA	4098	BID	1307	6
2026-07-15 20:04:49.283579+07	BBCA	4088	BID	1516	7
2026-07-15 20:04:49.283579+07	BBCA	4078	BID	1739	8
2026-07-15 20:04:49.283579+07	BBCA	4068	BID	1482	9
2026-07-15 20:04:49.283579+07	BBCA	4108	ASK	1056	5
2026-07-15 20:04:49.283579+07	BBCA	4118	ASK	1388	6
2026-07-15 20:04:49.283579+07	BBCA	4128	ASK	1561	7
2026-07-15 20:04:49.283579+07	BBCA	4138	ASK	1673	8
2026-07-15 20:04:49.283579+07	BBCA	4148	ASK	1661	9
2026-07-15 20:04:50.287644+07	BBCA	4108	BID	52351	5
2026-07-15 20:04:50.287644+07	BBCA	4098	BID	1400	6
2026-07-15 20:04:50.287644+07	BBCA	4088	BID	1266	7
2026-07-15 20:04:50.287644+07	BBCA	4078	BID	1492	8
2026-07-15 20:04:50.287644+07	BBCA	4068	BID	1881	9
2026-07-15 20:04:50.287644+07	BBCA	4108	ASK	1168	5
2026-07-15 20:04:50.287644+07	BBCA	4118	ASK	1153	6
2026-07-15 20:04:50.287644+07	BBCA	4128	ASK	1569	7
2026-07-15 20:04:50.287644+07	BBCA	4138	ASK	1532	8
2026-07-15 20:04:50.287644+07	BBCA	4148	ASK	1579	9
2026-07-15 20:04:51.29505+07	BBCA	4108	BID	53997	5
2026-07-15 20:04:51.29505+07	BBCA	4098	BID	1126	6
2026-07-15 20:04:51.29505+07	BBCA	4088	BID	1460	7
2026-07-15 20:04:51.29505+07	BBCA	4078	BID	1680	8
2026-07-15 20:04:51.29505+07	BBCA	4068	BID	1831	9
2026-07-15 20:04:51.29505+07	BBCA	4108	ASK	1467	5
2026-07-15 20:04:51.29505+07	BBCA	4118	ASK	1468	6
2026-07-15 20:04:51.29505+07	BBCA	4128	ASK	1699	7
2026-07-15 20:04:51.29505+07	BBCA	4138	ASK	1655	8
2026-07-15 20:04:51.29505+07	BBCA	4148	ASK	1497	9
2026-07-15 20:04:52.30407+07	BBCA	4108	BID	55785	5
2026-07-15 20:04:52.30407+07	BBCA	4098	BID	1507	6
2026-07-15 20:04:52.30407+07	BBCA	4088	BID	1636	7
2026-07-15 20:04:52.30407+07	BBCA	4078	BID	1748	8
2026-07-15 20:04:52.30407+07	BBCA	4068	BID	1817	9
2026-07-15 20:04:52.30407+07	BBCA	4108	ASK	1106	5
2026-07-15 20:04:52.30407+07	BBCA	4118	ASK	1480	6
2026-07-15 20:04:52.30407+07	BBCA	4128	ASK	1524	7
2026-07-15 20:04:52.30407+07	BBCA	4138	ASK	1618	8
2026-07-15 20:04:52.30407+07	BBCA	4148	ASK	1518	9
2026-07-15 20:04:53.31096+07	BBCA	4108	BID	57067	5
2026-07-15 20:04:53.31096+07	BBCA	4098	BID	1351	6
2026-07-15 20:04:53.31096+07	BBCA	4088	BID	1448	7
2026-07-15 20:04:53.31096+07	BBCA	4078	BID	1361	8
2026-07-15 20:04:53.31096+07	BBCA	4068	BID	1691	9
2026-07-15 20:04:53.31096+07	BBCA	4108	ASK	1075	5
2026-07-15 20:04:53.31096+07	BBCA	4118	ASK	1409	6
2026-07-15 20:04:53.31096+07	BBCA	4128	ASK	1530	7
2026-07-15 20:04:53.31096+07	BBCA	4138	ASK	1332	8
2026-07-15 20:04:53.31096+07	BBCA	4148	ASK	1674	9
2026-07-15 20:04:54.321606+07	BBCA	4108	BID	52182	5
2026-07-15 20:04:54.321606+07	BBCA	4098	BID	1121	6
2026-07-15 20:04:54.321606+07	BBCA	4088	BID	1479	7
2026-07-15 20:04:54.321606+07	BBCA	4078	BID	1336	8
2026-07-15 20:04:54.321606+07	BBCA	4068	BID	1578	9
2026-07-15 20:04:54.321606+07	BBCA	4108	ASK	1420	5
2026-07-15 20:04:54.321606+07	BBCA	4118	ASK	1138	6
2026-07-15 20:04:54.321606+07	BBCA	4128	ASK	1293	7
2026-07-15 20:04:54.321606+07	BBCA	4138	ASK	1726	8
2026-07-15 20:04:54.321606+07	BBCA	4148	ASK	1603	9
2026-07-15 20:04:55.327706+07	BBCA	4108	BID	53337	5
2026-07-15 20:04:55.327706+07	BBCA	4098	BID	1549	6
2026-07-15 20:04:55.327706+07	BBCA	4088	BID	1552	7
2026-07-15 20:04:55.327706+07	BBCA	4078	BID	1737	8
2026-07-15 20:04:55.327706+07	BBCA	4068	BID	1605	9
2026-07-15 20:04:55.327706+07	BBCA	4108	ASK	1373	5
2026-07-15 20:04:55.327706+07	BBCA	4118	ASK	1246	6
2026-07-15 20:04:55.327706+07	BBCA	4128	ASK	1246	7
2026-07-15 20:04:55.327706+07	BBCA	4138	ASK	1511	8
2026-07-15 20:04:55.327706+07	BBCA	4148	ASK	1873	9
2026-07-15 20:03:16.828316+07	BBRI	1661	BID	1248	5
2026-07-15 20:03:16.828316+07	BBRI	1651	BID	1154	6
2026-07-15 20:03:16.828316+07	BBRI	1641	BID	1566	7
2026-07-15 20:03:16.828316+07	BBRI	1631	BID	1439	8
2026-07-15 20:03:16.828316+07	BBRI	1621	BID	1407	9
2026-07-15 20:03:16.828316+07	BBRI	1661	ASK	1475	5
2026-07-15 20:03:16.828316+07	BBRI	1671	ASK	1297	6
2026-07-15 20:03:16.828316+07	BBRI	1681	ASK	1569	7
2026-07-15 20:03:16.828316+07	BBRI	1691	ASK	1333	8
2026-07-15 20:03:16.828316+07	BBRI	1701	ASK	1693	9
2026-07-15 20:03:17.837674+07	BBRI	1661	BID	1204	5
2026-07-15 20:03:17.837674+07	BBRI	1651	BID	1385	6
2026-07-15 20:03:17.837674+07	BBRI	1641	BID	1601	7
2026-07-15 20:03:17.837674+07	BBRI	1631	BID	1584	8
2026-07-15 20:03:17.837674+07	BBRI	1621	BID	1776	9
2026-07-15 20:03:17.837674+07	BBRI	1661	ASK	1090	5
2026-07-15 20:03:17.837674+07	BBRI	1671	ASK	1271	6
2026-07-15 20:03:17.837674+07	BBRI	1681	ASK	1334	7
2026-07-15 20:03:17.837674+07	BBRI	1691	ASK	1670	8
2026-07-15 20:03:17.837674+07	BBRI	1701	ASK	1594	9
2026-07-15 20:03:18.842603+07	BBRI	1661	BID	1447	5
2026-07-15 20:03:18.842603+07	BBRI	1651	BID	1385	6
2026-07-15 20:03:18.842603+07	BBRI	1641	BID	1567	7
2026-07-15 20:03:18.842603+07	BBRI	1631	BID	1597	8
2026-07-15 20:03:18.842603+07	BBRI	1621	BID	1751	9
2026-07-15 20:03:18.842603+07	BBRI	1661	ASK	1005	5
2026-07-15 20:03:18.842603+07	BBRI	1671	ASK	1485	6
2026-07-15 20:03:18.842603+07	BBRI	1681	ASK	1212	7
2026-07-15 20:03:18.842603+07	BBRI	1691	ASK	1549	8
2026-07-15 20:03:18.842603+07	BBRI	1701	ASK	1425	9
2026-07-15 20:03:19.850223+07	BBRI	1661	BID	1093	5
2026-07-15 20:03:19.850223+07	BBRI	1651	BID	1418	6
2026-07-15 20:03:19.850223+07	BBRI	1641	BID	1562	7
2026-07-15 20:03:19.850223+07	BBRI	1631	BID	1411	8
2026-07-15 20:03:19.850223+07	BBRI	1621	BID	1527	9
2026-07-15 20:03:19.850223+07	BBRI	1661	ASK	1192	5
2026-07-15 20:03:19.850223+07	BBRI	1671	ASK	1594	6
2026-07-15 20:03:19.850223+07	BBRI	1681	ASK	1682	7
2026-07-15 20:03:19.850223+07	BBRI	1691	ASK	1496	8
2026-07-15 20:03:19.850223+07	BBRI	1701	ASK	1820	9
2026-07-15 20:03:20.858603+07	BBRI	1661	BID	1141	5
2026-07-15 20:03:20.858603+07	BBRI	1651	BID	1404	6
2026-07-15 20:03:20.858603+07	BBRI	1641	BID	1434	7
2026-07-15 20:03:20.858603+07	BBRI	1631	BID	1710	8
2026-07-15 20:03:20.858603+07	BBRI	1621	BID	1544	9
2026-07-15 20:03:20.858603+07	BBRI	1661	ASK	1083	5
2026-07-15 20:03:20.858603+07	BBRI	1671	ASK	1375	6
2026-07-15 20:03:20.858603+07	BBRI	1681	ASK	1326	7
2026-07-15 20:03:20.858603+07	BBRI	1691	ASK	1381	8
2026-07-15 20:03:20.858603+07	BBRI	1701	ASK	1453	9
2026-07-15 20:03:21.864752+07	BBRI	1661	BID	1296	5
2026-07-15 20:03:21.864752+07	BBRI	1651	BID	1346	6
2026-07-15 20:03:21.864752+07	BBRI	1641	BID	1308	7
2026-07-15 20:03:21.864752+07	BBRI	1631	BID	1552	8
2026-07-15 20:03:21.864752+07	BBRI	1621	BID	1882	9
2026-07-15 20:03:21.864752+07	BBRI	1661	ASK	1476	5
2026-07-15 20:03:21.864752+07	BBRI	1671	ASK	1535	6
2026-07-15 20:03:21.864752+07	BBRI	1681	ASK	1511	7
2026-07-15 20:03:21.864752+07	BBRI	1691	ASK	1787	8
2026-07-15 20:03:21.864752+07	BBRI	1701	ASK	1721	9
2026-07-15 20:03:22.874044+07	BBRI	1661	BID	1004	5
2026-07-15 20:03:22.874044+07	BBRI	1651	BID	1120	6
2026-07-15 20:03:22.874044+07	BBRI	1641	BID	1390	7
2026-07-15 20:03:22.874044+07	BBRI	1631	BID	1625	8
2026-07-15 20:03:22.874044+07	BBRI	1621	BID	1695	9
2026-07-15 20:03:22.874044+07	BBRI	1661	ASK	1032	5
2026-07-15 20:03:22.874044+07	BBRI	1671	ASK	1594	6
2026-07-15 20:03:22.874044+07	BBRI	1681	ASK	1312	7
2026-07-15 20:03:22.874044+07	BBRI	1691	ASK	1487	8
2026-07-15 20:03:22.874044+07	BBRI	1701	ASK	1668	9
2026-07-15 20:03:23.878692+07	BBRI	1661	BID	1434	5
2026-07-15 20:03:23.878692+07	BBRI	1651	BID	1226	6
2026-07-15 20:03:23.878692+07	BBRI	1641	BID	1271	7
2026-07-15 20:03:23.878692+07	BBRI	1631	BID	1384	8
2026-07-15 20:03:23.878692+07	BBRI	1621	BID	1739	9
2026-07-15 20:03:23.878692+07	BBRI	1661	ASK	1467	5
2026-07-15 20:03:23.878692+07	BBRI	1671	ASK	1329	6
2026-07-15 20:03:23.878692+07	BBRI	1681	ASK	1348	7
2026-07-15 20:03:23.878692+07	BBRI	1691	ASK	1304	8
2026-07-15 20:03:23.878692+07	BBRI	1701	ASK	1883	9
2026-07-15 20:03:24.888011+07	BBRI	1661	BID	1272	5
2026-07-15 20:03:24.888011+07	BBRI	1651	BID	1270	6
2026-07-15 20:03:24.888011+07	BBRI	1641	BID	1249	7
2026-07-15 20:03:24.888011+07	BBRI	1631	BID	1594	8
2026-07-15 20:03:24.888011+07	BBRI	1621	BID	1683	9
2026-07-15 20:03:24.888011+07	BBRI	1661	ASK	1477	5
2026-07-15 20:03:24.888011+07	BBRI	1671	ASK	1169	6
2026-07-15 20:03:24.888011+07	BBRI	1681	ASK	1505	7
2026-07-15 20:03:24.888011+07	BBRI	1691	ASK	1492	8
2026-07-15 20:03:24.888011+07	BBRI	1701	ASK	1727	9
2026-07-15 20:03:25.894414+07	BBRI	1661	BID	1353	5
2026-07-15 20:03:25.894414+07	BBRI	1651	BID	1350	6
2026-07-15 20:03:25.894414+07	BBRI	1641	BID	1205	7
2026-07-15 20:03:25.894414+07	BBRI	1631	BID	1763	8
2026-07-15 20:03:25.894414+07	BBRI	1621	BID	1461	9
2026-07-15 20:03:25.894414+07	BBRI	1661	ASK	1222	5
2026-07-15 20:03:25.894414+07	BBRI	1671	ASK	1133	6
2026-07-15 20:03:25.894414+07	BBRI	1681	ASK	1562	7
2026-07-15 20:03:25.894414+07	BBRI	1691	ASK	1603	8
2026-07-15 20:03:25.894414+07	BBRI	1701	ASK	1451	9
2026-07-15 20:03:26.90421+07	BBRI	1661	BID	1030	5
2026-07-15 20:03:26.90421+07	BBRI	1651	BID	1563	6
2026-07-15 20:03:26.90421+07	BBRI	1641	BID	1634	7
2026-07-15 20:03:26.90421+07	BBRI	1631	BID	1668	8
2026-07-15 20:03:26.90421+07	BBRI	1621	BID	1885	9
2026-07-15 20:03:26.90421+07	BBRI	1661	ASK	1432	5
2026-07-15 20:03:26.90421+07	BBRI	1671	ASK	1516	6
2026-07-15 20:03:26.90421+07	BBRI	1681	ASK	1405	7
2026-07-15 20:03:26.90421+07	BBRI	1691	ASK	1587	8
2026-07-15 20:03:26.90421+07	BBRI	1701	ASK	1882	9
2026-07-15 20:03:27.910664+07	BBRI	1661	BID	1407	5
2026-07-15 20:03:27.910664+07	BBRI	1651	BID	1461	6
2026-07-15 20:03:27.910664+07	BBRI	1641	BID	1368	7
2026-07-15 20:03:27.910664+07	BBRI	1631	BID	1322	8
2026-07-15 20:03:27.910664+07	BBRI	1621	BID	1632	9
2026-07-15 20:03:27.910664+07	BBRI	1661	ASK	1305	5
2026-07-15 20:03:27.910664+07	BBRI	1671	ASK	1423	6
2026-07-15 20:03:27.910664+07	BBRI	1681	ASK	1286	7
2026-07-15 20:03:27.910664+07	BBRI	1691	ASK	1377	8
2026-07-15 20:03:27.910664+07	BBRI	1701	ASK	1502	9
2026-07-15 20:03:28.919222+07	BBRI	1661	BID	1175	5
2026-07-15 20:03:28.919222+07	BBRI	1651	BID	1129	6
2026-07-15 20:03:28.919222+07	BBRI	1641	BID	1370	7
2026-07-15 20:03:28.919222+07	BBRI	1631	BID	1587	8
2026-07-15 20:03:28.919222+07	BBRI	1621	BID	1577	9
2026-07-15 20:03:28.919222+07	BBRI	1661	ASK	1081	5
2026-07-15 20:03:28.919222+07	BBRI	1671	ASK	1355	6
2026-07-15 20:03:28.919222+07	BBRI	1681	ASK	1494	7
2026-07-15 20:03:28.919222+07	BBRI	1691	ASK	1389	8
2026-07-15 20:03:28.919222+07	BBRI	1701	ASK	1654	9
2026-07-15 20:03:29.926005+07	BBRI	1661	BID	1185	5
2026-07-15 20:03:29.926005+07	BBRI	1651	BID	1231	6
2026-07-15 20:03:29.926005+07	BBRI	1641	BID	1649	7
2026-07-15 20:03:29.926005+07	BBRI	1631	BID	1495	8
2026-07-15 20:03:29.926005+07	BBRI	1621	BID	1527	9
2026-07-15 20:03:29.926005+07	BBRI	1661	ASK	1007	5
2026-07-15 20:03:29.926005+07	BBRI	1671	ASK	1110	6
2026-07-15 20:03:29.926005+07	BBRI	1681	ASK	1311	7
2026-07-15 20:03:29.926005+07	BBRI	1691	ASK	1619	8
2026-07-15 20:03:29.926005+07	BBRI	1701	ASK	1766	9
2026-07-15 20:03:30.931647+07	BBRI	1661	BID	1149	5
2026-07-15 20:03:30.931647+07	BBRI	1651	BID	1293	6
2026-07-15 20:03:30.931647+07	BBRI	1641	BID	1275	7
2026-07-15 20:03:30.931647+07	BBRI	1631	BID	1786	8
2026-07-15 20:03:30.931647+07	BBRI	1621	BID	1815	9
2026-07-15 20:03:30.931647+07	BBRI	1661	ASK	1039	5
2026-07-15 20:03:30.931647+07	BBRI	1671	ASK	1344	6
2026-07-15 20:03:30.931647+07	BBRI	1681	ASK	1634	7
2026-07-15 20:03:30.931647+07	BBRI	1691	ASK	1418	8
2026-07-15 20:03:30.931647+07	BBRI	1701	ASK	1534	9
2026-07-15 20:03:31.941608+07	BBRI	1661	BID	1076	5
2026-07-15 20:03:31.941608+07	BBRI	1651	BID	1384	6
2026-07-15 20:03:31.941608+07	BBRI	1641	BID	1574	7
2026-07-15 20:03:31.941608+07	BBRI	1631	BID	1726	8
2026-07-15 20:03:31.941608+07	BBRI	1621	BID	1494	9
2026-07-15 20:03:31.941608+07	BBRI	1661	ASK	1249	5
2026-07-15 20:03:31.941608+07	BBRI	1671	ASK	1384	6
2026-07-15 20:03:31.941608+07	BBRI	1681	ASK	1476	7
2026-07-15 20:03:31.941608+07	BBRI	1691	ASK	1482	8
2026-07-15 20:03:31.941608+07	BBRI	1701	ASK	1611	9
2026-07-15 20:03:32.946821+07	BBRI	1661	BID	1247	5
2026-07-15 20:03:32.946821+07	BBRI	1651	BID	1452	6
2026-07-15 20:03:32.946821+07	BBRI	1641	BID	1590	7
2026-07-15 20:03:32.946821+07	BBRI	1631	BID	1744	8
2026-07-15 20:03:32.946821+07	BBRI	1621	BID	1496	9
2026-07-15 20:03:32.946821+07	BBRI	1661	ASK	1230	5
2026-07-15 20:03:32.946821+07	BBRI	1671	ASK	1550	6
2026-07-15 20:03:32.946821+07	BBRI	1681	ASK	1381	7
2026-07-15 20:03:32.946821+07	BBRI	1691	ASK	1762	8
2026-07-15 20:03:32.946821+07	BBRI	1701	ASK	1882	9
2026-07-15 20:03:33.957768+07	BBRI	1661	BID	1189	5
2026-07-15 20:03:33.957768+07	BBRI	1651	BID	1365	6
2026-07-15 20:03:33.957768+07	BBRI	1641	BID	1439	7
2026-07-15 20:03:33.957768+07	BBRI	1631	BID	1707	8
2026-07-15 20:03:33.957768+07	BBRI	1621	BID	1767	9
2026-07-15 20:03:33.957768+07	BBRI	1661	ASK	1491	5
2026-07-15 20:03:33.957768+07	BBRI	1671	ASK	1201	6
2026-07-15 20:03:33.957768+07	BBRI	1681	ASK	1204	7
2026-07-15 20:03:33.957768+07	BBRI	1691	ASK	1723	8
2026-07-15 20:03:33.957768+07	BBRI	1701	ASK	1420	9
2026-07-15 20:03:34.962824+07	BBRI	1661	BID	1204	5
2026-07-15 20:03:34.962824+07	BBRI	1651	BID	1338	6
2026-07-15 20:03:34.962824+07	BBRI	1641	BID	1254	7
2026-07-15 20:03:34.962824+07	BBRI	1631	BID	1509	8
2026-07-15 20:03:34.962824+07	BBRI	1621	BID	1416	9
2026-07-15 20:03:34.962824+07	BBRI	1661	ASK	1213	5
2026-07-15 20:03:34.962824+07	BBRI	1671	ASK	1263	6
2026-07-15 20:03:34.962824+07	BBRI	1681	ASK	1588	7
2026-07-15 20:03:34.962824+07	BBRI	1691	ASK	1369	8
2026-07-15 20:03:34.962824+07	BBRI	1701	ASK	1630	9
2026-07-15 20:03:35.97407+07	BBRI	1661	BID	1338	5
2026-07-15 20:03:35.97407+07	BBRI	1651	BID	1599	6
2026-07-15 20:03:35.97407+07	BBRI	1641	BID	1460	7
2026-07-15 20:03:35.97407+07	BBRI	1631	BID	1598	8
2026-07-15 20:03:35.97407+07	BBRI	1621	BID	1808	9
2026-07-15 20:03:35.97407+07	BBRI	1661	ASK	1443	5
2026-07-15 20:03:35.97407+07	BBRI	1671	ASK	1141	6
2026-07-15 20:03:35.97407+07	BBRI	1681	ASK	1244	7
2026-07-15 20:03:35.97407+07	BBRI	1691	ASK	1616	8
2026-07-15 20:03:35.97407+07	BBRI	1701	ASK	1767	9
2026-07-15 20:03:36.979081+07	BBRI	1661	BID	1088	5
2026-07-15 20:03:36.979081+07	BBRI	1651	BID	1106	6
2026-07-15 20:03:36.979081+07	BBRI	1641	BID	1616	7
2026-07-15 20:03:36.979081+07	BBRI	1631	BID	1341	8
2026-07-15 20:03:36.979081+07	BBRI	1621	BID	1728	9
2026-07-15 20:03:36.979081+07	BBRI	1661	ASK	1319	5
2026-07-15 20:03:36.979081+07	BBRI	1671	ASK	1206	6
2026-07-15 20:03:36.979081+07	BBRI	1681	ASK	1368	7
2026-07-15 20:03:36.979081+07	BBRI	1691	ASK	1316	8
2026-07-15 20:03:36.979081+07	BBRI	1701	ASK	1667	9
2026-07-15 20:03:37.99038+07	BBRI	1661	BID	1372	5
2026-07-15 20:03:37.99038+07	BBRI	1651	BID	1482	6
2026-07-15 20:03:37.99038+07	BBRI	1641	BID	1600	7
2026-07-15 20:03:37.99038+07	BBRI	1631	BID	1516	8
2026-07-15 20:03:37.99038+07	BBRI	1621	BID	1679	9
2026-07-15 20:03:37.99038+07	BBRI	1661	ASK	1090	5
2026-07-15 20:03:37.99038+07	BBRI	1671	ASK	1157	6
2026-07-15 20:03:37.99038+07	BBRI	1681	ASK	1486	7
2026-07-15 20:03:37.99038+07	BBRI	1691	ASK	1351	8
2026-07-15 20:03:37.99038+07	BBRI	1701	ASK	1886	9
2026-07-15 20:03:38.996359+07	BBRI	1661	BID	1158	5
2026-07-15 20:03:38.996359+07	BBRI	1651	BID	1335	6
2026-07-15 20:03:38.996359+07	BBRI	1641	BID	1469	7
2026-07-15 20:03:38.996359+07	BBRI	1631	BID	1672	8
2026-07-15 20:03:38.996359+07	BBRI	1621	BID	1691	9
2026-07-15 20:03:38.996359+07	BBRI	1661	ASK	1124	5
2026-07-15 20:03:38.996359+07	BBRI	1671	ASK	1288	6
2026-07-15 20:03:38.996359+07	BBRI	1681	ASK	1383	7
2026-07-15 20:03:38.996359+07	BBRI	1691	ASK	1503	8
2026-07-15 20:03:38.996359+07	BBRI	1701	ASK	1815	9
2026-07-15 20:03:40.007902+07	BBRI	1661	BID	1462	5
2026-07-15 20:03:40.007902+07	BBRI	1651	BID	1293	6
2026-07-15 20:03:40.007902+07	BBRI	1641	BID	1229	7
2026-07-15 20:03:40.007902+07	BBRI	1631	BID	1634	8
2026-07-15 20:03:40.007902+07	BBRI	1621	BID	1683	9
2026-07-15 20:03:40.007902+07	BBRI	1661	ASK	1415	5
2026-07-15 20:03:40.007902+07	BBRI	1671	ASK	1297	6
2026-07-15 20:03:40.007902+07	BBRI	1681	ASK	1408	7
2026-07-15 20:03:40.007902+07	BBRI	1691	ASK	1454	8
2026-07-15 20:03:40.007902+07	BBRI	1701	ASK	1637	9
2026-07-15 20:03:41.014783+07	BBRI	1661	BID	1485	5
2026-07-15 20:03:41.014783+07	BBRI	1651	BID	1459	6
2026-07-15 20:03:41.014783+07	BBRI	1641	BID	1455	7
2026-07-15 20:03:41.014783+07	BBRI	1631	BID	1485	8
2026-07-15 20:03:41.014783+07	BBRI	1621	BID	1783	9
2026-07-15 20:03:41.014783+07	BBRI	1661	ASK	1424	5
2026-07-15 20:03:41.014783+07	BBRI	1671	ASK	1540	6
2026-07-15 20:03:41.014783+07	BBRI	1681	ASK	1595	7
2026-07-15 20:03:41.014783+07	BBRI	1691	ASK	1369	8
2026-07-15 20:03:41.014783+07	BBRI	1701	ASK	1814	9
2026-07-15 20:03:42.025911+07	BBRI	1661	BID	1151	5
2026-07-15 20:03:42.025911+07	BBRI	1651	BID	1157	6
2026-07-15 20:03:42.025911+07	BBRI	1641	BID	1506	7
2026-07-15 20:03:42.025911+07	BBRI	1631	BID	1310	8
2026-07-15 20:03:42.025911+07	BBRI	1621	BID	1590	9
2026-07-15 20:03:42.025911+07	BBRI	1661	ASK	1325	5
2026-07-15 20:03:42.025911+07	BBRI	1671	ASK	1384	6
2026-07-15 20:03:42.025911+07	BBRI	1681	ASK	1423	7
2026-07-15 20:03:42.025911+07	BBRI	1691	ASK	1667	8
2026-07-15 20:03:42.025911+07	BBRI	1701	ASK	1793	9
2026-07-15 20:03:43.032449+07	BBRI	1661	BID	1258	5
2026-07-15 20:03:43.032449+07	BBRI	1651	BID	1146	6
2026-07-15 20:03:43.032449+07	BBRI	1641	BID	1566	7
2026-07-15 20:03:43.032449+07	BBRI	1631	BID	1403	8
2026-07-15 20:03:43.032449+07	BBRI	1621	BID	1438	9
2026-07-15 20:03:43.032449+07	BBRI	1661	ASK	1322	5
2026-07-15 20:03:43.032449+07	BBRI	1671	ASK	1456	6
2026-07-15 20:03:43.032449+07	BBRI	1681	ASK	1439	7
2026-07-15 20:03:43.032449+07	BBRI	1691	ASK	1682	8
2026-07-15 20:03:43.032449+07	BBRI	1701	ASK	1526	9
2026-07-15 20:03:44.043106+07	BBRI	1661	BID	1144	5
2026-07-15 20:03:44.043106+07	BBRI	1651	BID	1267	6
2026-07-15 20:03:44.043106+07	BBRI	1641	BID	1668	7
2026-07-15 20:03:44.043106+07	BBRI	1631	BID	1504	8
2026-07-15 20:03:44.043106+07	BBRI	1621	BID	1864	9
2026-07-15 20:03:44.043106+07	BBRI	1661	ASK	1273	5
2026-07-15 20:03:44.043106+07	BBRI	1671	ASK	1516	6
2026-07-15 20:03:44.043106+07	BBRI	1681	ASK	1251	7
2026-07-15 20:03:44.043106+07	BBRI	1691	ASK	1566	8
2026-07-15 20:03:44.043106+07	BBRI	1701	ASK	1417	9
2026-07-15 20:03:45.051136+07	BBRI	1661	BID	1082	5
2026-07-15 20:03:45.051136+07	BBRI	1651	BID	1394	6
2026-07-15 20:03:45.051136+07	BBRI	1641	BID	1304	7
2026-07-15 20:03:45.051136+07	BBRI	1631	BID	1539	8
2026-07-15 20:03:45.051136+07	BBRI	1621	BID	1818	9
2026-07-15 20:03:45.051136+07	BBRI	1661	ASK	1062	5
2026-07-15 20:03:45.051136+07	BBRI	1671	ASK	1193	6
2026-07-15 20:03:45.051136+07	BBRI	1681	ASK	1330	7
2026-07-15 20:03:45.051136+07	BBRI	1691	ASK	1489	8
2026-07-15 20:03:45.051136+07	BBRI	1701	ASK	1803	9
2026-07-15 20:03:46.059736+07	BBRI	1661	BID	1415	5
2026-07-15 20:03:46.059736+07	BBRI	1651	BID	1314	6
2026-07-15 20:03:46.059736+07	BBRI	1641	BID	1415	7
2026-07-15 20:03:46.059736+07	BBRI	1631	BID	1346	8
2026-07-15 20:03:46.059736+07	BBRI	1621	BID	1401	9
2026-07-15 20:03:46.059736+07	BBRI	1661	ASK	1387	5
2026-07-15 20:03:46.059736+07	BBRI	1671	ASK	1397	6
2026-07-15 20:03:46.059736+07	BBRI	1681	ASK	1345	7
2026-07-15 20:03:46.059736+07	BBRI	1691	ASK	1315	8
2026-07-15 20:03:46.059736+07	BBRI	1701	ASK	1857	9
2026-07-15 20:03:47.065783+07	BBRI	1661	BID	1177	5
2026-07-15 20:03:47.065783+07	BBRI	1651	BID	1563	6
2026-07-15 20:03:47.065783+07	BBRI	1641	BID	1403	7
2026-07-15 20:03:47.065783+07	BBRI	1631	BID	1354	8
2026-07-15 20:03:47.065783+07	BBRI	1621	BID	1488	9
2026-07-15 20:03:47.065783+07	BBRI	1661	ASK	1413	5
2026-07-15 20:03:47.065783+07	BBRI	1671	ASK	1470	6
2026-07-15 20:03:47.065783+07	BBRI	1681	ASK	1369	7
2026-07-15 20:03:47.065783+07	BBRI	1691	ASK	1584	8
2026-07-15 20:03:47.065783+07	BBRI	1701	ASK	1467	9
2026-07-15 20:03:48.075337+07	BBRI	1661	BID	1306	5
2026-07-15 20:03:48.075337+07	BBRI	1651	BID	1348	6
2026-07-15 20:03:48.075337+07	BBRI	1641	BID	1561	7
2026-07-15 20:03:48.075337+07	BBRI	1631	BID	1469	8
2026-07-15 20:03:48.075337+07	BBRI	1621	BID	1686	9
2026-07-15 20:03:48.075337+07	BBRI	1661	ASK	1414	5
2026-07-15 20:03:48.075337+07	BBRI	1671	ASK	1313	6
2026-07-15 20:03:48.075337+07	BBRI	1681	ASK	1261	7
2026-07-15 20:03:48.075337+07	BBRI	1691	ASK	1391	8
2026-07-15 20:03:48.075337+07	BBRI	1701	ASK	1580	9
2026-07-15 20:03:49.079592+07	BBRI	1661	BID	1184	5
2026-07-15 20:03:49.079592+07	BBRI	1651	BID	1154	6
2026-07-15 20:03:49.079592+07	BBRI	1641	BID	1512	7
2026-07-15 20:03:49.079592+07	BBRI	1631	BID	1594	8
2026-07-15 20:03:49.079592+07	BBRI	1621	BID	1598	9
2026-07-15 20:03:49.079592+07	BBRI	1661	ASK	1423	5
2026-07-15 20:03:49.079592+07	BBRI	1671	ASK	1392	6
2026-07-15 20:03:49.079592+07	BBRI	1681	ASK	1689	7
2026-07-15 20:03:49.079592+07	BBRI	1691	ASK	1677	8
2026-07-15 20:03:49.079592+07	BBRI	1701	ASK	1643	9
2026-07-15 20:03:50.089778+07	BBRI	1661	BID	1309	5
2026-07-15 20:03:50.089778+07	BBRI	1651	BID	1102	6
2026-07-15 20:03:50.089778+07	BBRI	1641	BID	1258	7
2026-07-15 20:03:50.089778+07	BBRI	1631	BID	1351	8
2026-07-15 20:03:50.089778+07	BBRI	1621	BID	1560	9
2026-07-15 20:03:50.089778+07	BBRI	1661	ASK	1174	5
2026-07-15 20:03:50.089778+07	BBRI	1671	ASK	1336	6
2026-07-15 20:03:50.089778+07	BBRI	1681	ASK	1500	7
2026-07-15 20:03:50.089778+07	BBRI	1691	ASK	1478	8
2026-07-15 20:03:50.089778+07	BBRI	1701	ASK	1665	9
2026-07-15 20:03:51.095092+07	BBRI	1661	BID	1184	5
2026-07-15 20:03:51.095092+07	BBRI	1651	BID	1141	6
2026-07-15 20:03:51.095092+07	BBRI	1641	BID	1611	7
2026-07-15 20:03:51.095092+07	BBRI	1631	BID	1605	8
2026-07-15 20:03:51.095092+07	BBRI	1621	BID	1792	9
2026-07-15 20:03:51.095092+07	BBRI	1661	ASK	1018	5
2026-07-15 20:03:51.095092+07	BBRI	1671	ASK	1274	6
2026-07-15 20:03:51.095092+07	BBRI	1681	ASK	1213	7
2026-07-15 20:03:51.095092+07	BBRI	1691	ASK	1775	8
2026-07-15 20:03:51.095092+07	BBRI	1701	ASK	1611	9
2026-07-15 20:03:52.106709+07	BBRI	1661	BID	1489	5
2026-07-15 20:03:52.106709+07	BBRI	1651	BID	1432	6
2026-07-15 20:03:52.106709+07	BBRI	1641	BID	1444	7
2026-07-15 20:03:52.106709+07	BBRI	1631	BID	1430	8
2026-07-15 20:03:52.106709+07	BBRI	1621	BID	1640	9
2026-07-15 20:03:52.106709+07	BBRI	1661	ASK	1011	5
2026-07-15 20:03:52.106709+07	BBRI	1671	ASK	1471	6
2026-07-15 20:03:52.106709+07	BBRI	1681	ASK	1333	7
2026-07-15 20:03:52.106709+07	BBRI	1691	ASK	1652	8
2026-07-15 20:03:52.106709+07	BBRI	1701	ASK	1866	9
2026-07-15 20:03:53.111133+07	BBRI	1661	BID	1405	5
2026-07-15 20:03:53.111133+07	BBRI	1651	BID	1553	6
2026-07-15 20:03:53.111133+07	BBRI	1641	BID	1203	7
2026-07-15 20:03:53.111133+07	BBRI	1631	BID	1318	8
2026-07-15 20:03:53.111133+07	BBRI	1621	BID	1876	9
2026-07-15 20:03:53.111133+07	BBRI	1661	ASK	1448	5
2026-07-15 20:03:53.111133+07	BBRI	1671	ASK	1345	6
2026-07-15 20:03:53.111133+07	BBRI	1681	ASK	1586	7
2026-07-15 20:03:53.111133+07	BBRI	1691	ASK	1356	8
2026-07-15 20:03:53.111133+07	BBRI	1701	ASK	1779	9
2026-07-15 20:03:54.117096+07	BBRI	1661	BID	1152	5
2026-07-15 20:03:54.117096+07	BBRI	1651	BID	1100	6
2026-07-15 20:03:54.117096+07	BBRI	1641	BID	1570	7
2026-07-15 20:03:54.117096+07	BBRI	1631	BID	1611	8
2026-07-15 20:03:54.117096+07	BBRI	1621	BID	1796	9
2026-07-15 20:03:54.117096+07	BBRI	1661	ASK	1413	5
2026-07-15 20:03:54.117096+07	BBRI	1671	ASK	1263	6
2026-07-15 20:03:54.117096+07	BBRI	1681	ASK	1413	7
2026-07-15 20:03:54.117096+07	BBRI	1691	ASK	1496	8
2026-07-15 20:03:54.117096+07	BBRI	1701	ASK	1713	9
2026-07-15 20:03:55.12551+07	BBRI	1661	BID	1287	5
2026-07-15 20:03:55.12551+07	BBRI	1651	BID	1163	6
2026-07-15 20:03:55.12551+07	BBRI	1641	BID	1365	7
2026-07-15 20:03:55.12551+07	BBRI	1631	BID	1641	8
2026-07-15 20:03:55.12551+07	BBRI	1621	BID	1705	9
2026-07-15 20:03:55.12551+07	BBRI	1661	ASK	1163	5
2026-07-15 20:03:55.12551+07	BBRI	1671	ASK	1558	6
2026-07-15 20:03:55.12551+07	BBRI	1681	ASK	1471	7
2026-07-15 20:03:55.12551+07	BBRI	1691	ASK	1478	8
2026-07-15 20:03:55.12551+07	BBRI	1701	ASK	1401	9
2026-07-15 20:03:56.129116+07	BBRI	1661	BID	1319	5
2026-07-15 20:03:56.129116+07	BBRI	1651	BID	1140	6
2026-07-15 20:03:56.129116+07	BBRI	1641	BID	1660	7
2026-07-15 20:03:56.129116+07	BBRI	1631	BID	1778	8
2026-07-15 20:03:56.129116+07	BBRI	1621	BID	1620	9
2026-07-15 20:03:56.129116+07	BBRI	1661	ASK	1494	5
2026-07-15 20:03:56.129116+07	BBRI	1671	ASK	1412	6
2026-07-15 20:03:56.129116+07	BBRI	1681	ASK	1476	7
2026-07-15 20:03:56.129116+07	BBRI	1691	ASK	1449	8
2026-07-15 20:03:56.129116+07	BBRI	1701	ASK	1736	9
2026-07-15 20:03:57.136982+07	BBRI	1661	BID	1443	5
2026-07-15 20:03:57.136982+07	BBRI	1651	BID	1575	6
2026-07-15 20:03:57.136982+07	BBRI	1641	BID	1317	7
2026-07-15 20:03:57.136982+07	BBRI	1631	BID	1671	8
2026-07-15 20:03:57.136982+07	BBRI	1621	BID	1688	9
2026-07-15 20:03:57.136982+07	BBRI	1661	ASK	1496	5
2026-07-15 20:03:57.136982+07	BBRI	1671	ASK	1338	6
2026-07-15 20:03:57.136982+07	BBRI	1681	ASK	1251	7
2026-07-15 20:03:57.136982+07	BBRI	1691	ASK	1577	8
2026-07-15 20:03:57.136982+07	BBRI	1701	ASK	1682	9
2026-07-15 20:03:58.143644+07	BBRI	1661	BID	1151	5
2026-07-15 20:03:58.143644+07	BBRI	1651	BID	1277	6
2026-07-15 20:03:58.143644+07	BBRI	1641	BID	1230	7
2026-07-15 20:03:58.143644+07	BBRI	1631	BID	1648	8
2026-07-15 20:03:58.143644+07	BBRI	1621	BID	1745	9
2026-07-15 20:03:58.143644+07	BBRI	1661	ASK	1098	5
2026-07-15 20:03:58.143644+07	BBRI	1671	ASK	1518	6
2026-07-15 20:03:58.143644+07	BBRI	1681	ASK	1535	7
2026-07-15 20:03:58.143644+07	BBRI	1691	ASK	1303	8
2026-07-15 20:03:58.143644+07	BBRI	1701	ASK	1696	9
2026-07-15 20:03:59.1505+07	BBRI	1661	BID	1265	5
2026-07-15 20:03:59.1505+07	BBRI	1651	BID	1490	6
2026-07-15 20:03:59.1505+07	BBRI	1641	BID	1311	7
2026-07-15 20:03:59.1505+07	BBRI	1631	BID	1567	8
2026-07-15 20:03:59.1505+07	BBRI	1621	BID	1532	9
2026-07-15 20:03:59.1505+07	BBRI	1661	ASK	1022	5
2026-07-15 20:03:59.1505+07	BBRI	1671	ASK	1409	6
2026-07-15 20:03:59.1505+07	BBRI	1681	ASK	1351	7
2026-07-15 20:03:59.1505+07	BBRI	1691	ASK	1446	8
2026-07-15 20:03:59.1505+07	BBRI	1701	ASK	1891	9
2026-07-15 20:04:00.158698+07	BBRI	1661	BID	1017	5
2026-07-15 20:04:00.158698+07	BBRI	1651	BID	1153	6
2026-07-15 20:04:00.158698+07	BBRI	1641	BID	1323	7
2026-07-15 20:04:00.158698+07	BBRI	1631	BID	1759	8
2026-07-15 20:04:00.158698+07	BBRI	1621	BID	1559	9
2026-07-15 20:04:00.158698+07	BBRI	1661	ASK	1409	5
2026-07-15 20:04:00.158698+07	BBRI	1671	ASK	1163	6
2026-07-15 20:04:00.158698+07	BBRI	1681	ASK	1640	7
2026-07-15 20:04:00.158698+07	BBRI	1691	ASK	1460	8
2026-07-15 20:04:00.158698+07	BBRI	1701	ASK	1432	9
2026-07-15 20:04:01.163484+07	BBRI	1661	BID	1472	5
2026-07-15 20:04:01.163484+07	BBRI	1651	BID	1529	6
2026-07-15 20:04:01.163484+07	BBRI	1641	BID	1314	7
2026-07-15 20:04:01.163484+07	BBRI	1631	BID	1304	8
2026-07-15 20:04:01.163484+07	BBRI	1621	BID	1859	9
2026-07-15 20:04:01.163484+07	BBRI	1661	ASK	1047	5
2026-07-15 20:04:01.163484+07	BBRI	1671	ASK	1359	6
2026-07-15 20:04:01.163484+07	BBRI	1681	ASK	1363	7
2026-07-15 20:04:01.163484+07	BBRI	1691	ASK	1633	8
2026-07-15 20:04:01.163484+07	BBRI	1701	ASK	1675	9
2026-07-15 20:04:02.173372+07	BBRI	1661	BID	1280	5
2026-07-15 20:04:02.173372+07	BBRI	1651	BID	1149	6
2026-07-15 20:04:02.173372+07	BBRI	1641	BID	1508	7
2026-07-15 20:04:02.173372+07	BBRI	1631	BID	1378	8
2026-07-15 20:04:02.173372+07	BBRI	1621	BID	1706	9
2026-07-15 20:04:02.173372+07	BBRI	1661	ASK	1121	5
2026-07-15 20:04:02.173372+07	BBRI	1671	ASK	1224	6
2026-07-15 20:04:02.173372+07	BBRI	1681	ASK	1325	7
2026-07-15 20:04:02.173372+07	BBRI	1691	ASK	1577	8
2026-07-15 20:04:02.173372+07	BBRI	1701	ASK	1738	9
2026-07-15 20:04:03.177682+07	BBRI	1661	BID	1090	5
2026-07-15 20:04:03.177682+07	BBRI	1651	BID	1518	6
2026-07-15 20:04:03.177682+07	BBRI	1641	BID	1535	7
2026-07-15 20:04:03.177682+07	BBRI	1631	BID	1333	8
2026-07-15 20:04:03.177682+07	BBRI	1621	BID	1868	9
2026-07-15 20:04:03.177682+07	BBRI	1661	ASK	1296	5
2026-07-15 20:04:03.177682+07	BBRI	1671	ASK	1280	6
2026-07-15 20:04:03.177682+07	BBRI	1681	ASK	1240	7
2026-07-15 20:04:03.177682+07	BBRI	1691	ASK	1545	8
2026-07-15 20:04:03.177682+07	BBRI	1701	ASK	1712	9
2026-07-15 20:04:04.18565+07	BBRI	1661	BID	1304	5
2026-07-15 20:04:04.18565+07	BBRI	1651	BID	1532	6
2026-07-15 20:04:04.18565+07	BBRI	1641	BID	1606	7
2026-07-15 20:04:04.18565+07	BBRI	1631	BID	1601	8
2026-07-15 20:04:04.18565+07	BBRI	1621	BID	1587	9
2026-07-15 20:04:04.18565+07	BBRI	1661	ASK	1013	5
2026-07-15 20:04:04.18565+07	BBRI	1671	ASK	1130	6
2026-07-15 20:04:04.18565+07	BBRI	1681	ASK	1692	7
2026-07-15 20:04:04.18565+07	BBRI	1691	ASK	1744	8
2026-07-15 20:04:04.18565+07	BBRI	1701	ASK	1774	9
2026-07-15 20:04:05.192745+07	BBRI	1661	BID	1384	5
2026-07-15 20:04:05.192745+07	BBRI	1651	BID	1300	6
2026-07-15 20:04:05.192745+07	BBRI	1641	BID	1452	7
2026-07-15 20:04:05.192745+07	BBRI	1631	BID	1662	8
2026-07-15 20:04:05.192745+07	BBRI	1621	BID	1619	9
2026-07-15 20:04:05.192745+07	BBRI	1661	ASK	1225	5
2026-07-15 20:04:05.192745+07	BBRI	1671	ASK	1537	6
2026-07-15 20:04:05.192745+07	BBRI	1681	ASK	1662	7
2026-07-15 20:04:05.192745+07	BBRI	1691	ASK	1652	8
2026-07-15 20:04:05.192745+07	BBRI	1701	ASK	1563	9
2026-07-15 20:04:06.196808+07	BBRI	1661	BID	1227	5
2026-07-15 20:04:06.196808+07	BBRI	1651	BID	1513	6
2026-07-15 20:04:06.196808+07	BBRI	1641	BID	1448	7
2026-07-15 20:04:06.196808+07	BBRI	1631	BID	1400	8
2026-07-15 20:04:06.196808+07	BBRI	1621	BID	1851	9
2026-07-15 20:04:06.196808+07	BBRI	1661	ASK	1460	5
2026-07-15 20:04:06.196808+07	BBRI	1671	ASK	1361	6
2026-07-15 20:04:06.196808+07	BBRI	1681	ASK	1649	7
2026-07-15 20:04:06.196808+07	BBRI	1691	ASK	1742	8
2026-07-15 20:04:06.196808+07	BBRI	1701	ASK	1671	9
2026-07-15 20:04:07.205127+07	BBRI	1661	BID	1412	5
2026-07-15 20:04:07.205127+07	BBRI	1651	BID	1461	6
2026-07-15 20:04:07.205127+07	BBRI	1641	BID	1497	7
2026-07-15 20:04:07.205127+07	BBRI	1631	BID	1395	8
2026-07-15 20:04:07.205127+07	BBRI	1621	BID	1892	9
2026-07-15 20:04:07.205127+07	BBRI	1661	ASK	1350	5
2026-07-15 20:04:07.205127+07	BBRI	1671	ASK	1445	6
2026-07-15 20:04:07.205127+07	BBRI	1681	ASK	1212	7
2026-07-15 20:04:07.205127+07	BBRI	1691	ASK	1527	8
2026-07-15 20:04:07.205127+07	BBRI	1701	ASK	1554	9
2026-07-15 20:04:08.213208+07	BBRI	1661	BID	58338	5
2026-07-15 20:04:08.213208+07	BBRI	1651	BID	1520	6
2026-07-15 20:04:08.213208+07	BBRI	1641	BID	1599	7
2026-07-15 20:04:08.213208+07	BBRI	1631	BID	1542	8
2026-07-15 20:04:08.213208+07	BBRI	1621	BID	1488	9
2026-07-15 20:04:08.213208+07	BBRI	1661	ASK	1323	5
2026-07-15 20:04:08.213208+07	BBRI	1671	ASK	1445	6
2026-07-15 20:04:08.213208+07	BBRI	1681	ASK	1687	7
2026-07-15 20:04:08.213208+07	BBRI	1691	ASK	1615	8
2026-07-15 20:04:08.213208+07	BBRI	1701	ASK	1629	9
2026-07-15 20:04:09.218981+07	BBRI	1661	BID	55768	5
2026-07-15 20:04:09.218981+07	BBRI	1651	BID	1104	6
2026-07-15 20:04:09.218981+07	BBRI	1641	BID	1415	7
2026-07-15 20:04:09.218981+07	BBRI	1631	BID	1506	8
2026-07-15 20:04:09.218981+07	BBRI	1621	BID	1758	9
2026-07-15 20:04:09.218981+07	BBRI	1661	ASK	1280	5
2026-07-15 20:04:09.218981+07	BBRI	1671	ASK	1468	6
2026-07-15 20:04:09.218981+07	BBRI	1681	ASK	1385	7
2026-07-15 20:04:09.218981+07	BBRI	1691	ASK	1471	8
2026-07-15 20:04:09.218981+07	BBRI	1701	ASK	1597	9
2026-07-15 20:04:10.225614+07	BBRI	1661	BID	57780	5
2026-07-15 20:04:10.225614+07	BBRI	1651	BID	1353	6
2026-07-15 20:04:10.225614+07	BBRI	1641	BID	1306	7
2026-07-15 20:04:10.225614+07	BBRI	1631	BID	1607	8
2026-07-15 20:04:10.225614+07	BBRI	1621	BID	1764	9
2026-07-15 20:04:10.225614+07	BBRI	1661	ASK	1329	5
2026-07-15 20:04:10.225614+07	BBRI	1671	ASK	1149	6
2026-07-15 20:04:10.225614+07	BBRI	1681	ASK	1643	7
2026-07-15 20:04:10.225614+07	BBRI	1691	ASK	1558	8
2026-07-15 20:04:10.225614+07	BBRI	1701	ASK	1550	9
2026-07-15 20:04:11.229537+07	BBRI	1661	BID	56272	5
2026-07-15 20:04:11.229537+07	BBRI	1651	BID	1485	6
2026-07-15 20:04:11.229537+07	BBRI	1641	BID	1431	7
2026-07-15 20:04:11.229537+07	BBRI	1631	BID	1397	8
2026-07-15 20:04:11.229537+07	BBRI	1621	BID	1448	9
2026-07-15 20:04:11.229537+07	BBRI	1661	ASK	1234	5
2026-07-15 20:04:11.229537+07	BBRI	1671	ASK	1234	6
2026-07-15 20:04:11.229537+07	BBRI	1681	ASK	1254	7
2026-07-15 20:04:11.229537+07	BBRI	1691	ASK	1648	8
2026-07-15 20:04:11.229537+07	BBRI	1701	ASK	1457	9
2026-07-15 20:04:12.237997+07	BBRI	1661	BID	54106	5
2026-07-15 20:04:12.237997+07	BBRI	1651	BID	1318	6
2026-07-15 20:04:12.237997+07	BBRI	1641	BID	1383	7
2026-07-15 20:04:12.237997+07	BBRI	1631	BID	1574	8
2026-07-15 20:04:12.237997+07	BBRI	1621	BID	1606	9
2026-07-15 20:04:12.237997+07	BBRI	1661	ASK	1197	5
2026-07-15 20:04:12.237997+07	BBRI	1671	ASK	1156	6
2026-07-15 20:04:12.237997+07	BBRI	1681	ASK	1285	7
2026-07-15 20:04:12.237997+07	BBRI	1691	ASK	1339	8
2026-07-15 20:04:12.237997+07	BBRI	1701	ASK	1415	9
2026-07-15 20:04:13.24604+07	BBRI	1661	BID	53077	5
2026-07-15 20:04:13.24604+07	BBRI	1651	BID	1362	6
2026-07-15 20:04:13.24604+07	BBRI	1641	BID	1387	7
2026-07-15 20:04:13.24604+07	BBRI	1631	BID	1507	8
2026-07-15 20:04:13.24604+07	BBRI	1621	BID	1534	9
2026-07-15 20:04:13.24604+07	BBRI	1661	ASK	1332	5
2026-07-15 20:04:13.24604+07	BBRI	1671	ASK	1466	6
2026-07-15 20:04:13.24604+07	BBRI	1681	ASK	1566	7
2026-07-15 20:04:13.24604+07	BBRI	1691	ASK	1602	8
2026-07-15 20:04:13.24604+07	BBRI	1701	ASK	1642	9
2026-07-15 20:04:14.254614+07	BBRI	1661	BID	53856	5
2026-07-15 20:04:14.254614+07	BBRI	1651	BID	1563	6
2026-07-15 20:04:14.254614+07	BBRI	1641	BID	1293	7
2026-07-15 20:04:14.254614+07	BBRI	1631	BID	1638	8
2026-07-15 20:04:14.254614+07	BBRI	1621	BID	1530	9
2026-07-15 20:04:14.254614+07	BBRI	1661	ASK	1407	5
2026-07-15 20:04:14.254614+07	BBRI	1671	ASK	1127	6
2026-07-15 20:04:14.254614+07	BBRI	1681	ASK	1438	7
2026-07-15 20:04:14.254614+07	BBRI	1691	ASK	1675	8
2026-07-15 20:04:14.254614+07	BBRI	1701	ASK	1745	9
2026-07-15 20:04:15.26154+07	BBRI	1661	BID	50172	5
2026-07-15 20:04:15.26154+07	BBRI	1651	BID	1384	6
2026-07-15 20:04:15.26154+07	BBRI	1641	BID	1636	7
2026-07-15 20:04:15.26154+07	BBRI	1631	BID	1613	8
2026-07-15 20:04:15.26154+07	BBRI	1621	BID	1899	9
2026-07-15 20:04:15.26154+07	BBRI	1661	ASK	1211	5
2026-07-15 20:04:15.26154+07	BBRI	1671	ASK	1555	6
2026-07-15 20:04:15.26154+07	BBRI	1681	ASK	1387	7
2026-07-15 20:04:15.26154+07	BBRI	1691	ASK	1688	8
2026-07-15 20:04:15.26154+07	BBRI	1701	ASK	1408	9
2026-07-15 20:04:16.271036+07	BBRI	1661	BID	58613	5
2026-07-15 20:04:16.271036+07	BBRI	1651	BID	1441	6
2026-07-15 20:04:16.271036+07	BBRI	1641	BID	1219	7
2026-07-15 20:04:16.271036+07	BBRI	1631	BID	1366	8
2026-07-15 20:04:16.271036+07	BBRI	1621	BID	1463	9
2026-07-15 20:04:16.271036+07	BBRI	1661	ASK	1107	5
2026-07-15 20:04:16.271036+07	BBRI	1671	ASK	1120	6
2026-07-15 20:04:16.271036+07	BBRI	1681	ASK	1298	7
2026-07-15 20:04:16.271036+07	BBRI	1691	ASK	1775	8
2026-07-15 20:04:16.271036+07	BBRI	1701	ASK	1434	9
2026-07-15 20:04:17.279566+07	BBRI	1661	BID	57873	5
2026-07-15 20:04:17.279566+07	BBRI	1651	BID	1179	6
2026-07-15 20:04:17.279566+07	BBRI	1641	BID	1448	7
2026-07-15 20:04:17.279566+07	BBRI	1631	BID	1650	8
2026-07-15 20:04:17.279566+07	BBRI	1621	BID	1888	9
2026-07-15 20:04:17.279566+07	BBRI	1661	ASK	1177	5
2026-07-15 20:04:17.279566+07	BBRI	1671	ASK	1524	6
2026-07-15 20:04:17.279566+07	BBRI	1681	ASK	1551	7
2026-07-15 20:04:17.279566+07	BBRI	1691	ASK	1454	8
2026-07-15 20:04:17.279566+07	BBRI	1701	ASK	1850	9
2026-07-15 20:04:18.289268+07	BBRI	1661	BID	58978	5
2026-07-15 20:04:18.289268+07	BBRI	1651	BID	1565	6
2026-07-15 20:04:18.289268+07	BBRI	1641	BID	1641	7
2026-07-15 20:04:18.289268+07	BBRI	1631	BID	1354	8
2026-07-15 20:04:18.289268+07	BBRI	1621	BID	1491	9
2026-07-15 20:04:18.289268+07	BBRI	1661	ASK	1070	5
2026-07-15 20:04:18.289268+07	BBRI	1671	ASK	1516	6
2026-07-15 20:04:18.289268+07	BBRI	1681	ASK	1572	7
2026-07-15 20:04:18.289268+07	BBRI	1691	ASK	1374	8
2026-07-15 20:04:18.289268+07	BBRI	1701	ASK	1486	9
2026-07-15 20:04:19.298047+07	BBRI	1661	BID	55109	5
2026-07-15 20:04:19.298047+07	BBRI	1651	BID	1565	6
2026-07-15 20:04:19.298047+07	BBRI	1641	BID	1632	7
2026-07-15 20:04:19.298047+07	BBRI	1631	BID	1629	8
2026-07-15 20:04:19.298047+07	BBRI	1621	BID	1567	9
2026-07-15 20:04:19.298047+07	BBRI	1661	ASK	1308	5
2026-07-15 20:04:19.298047+07	BBRI	1671	ASK	1446	6
2026-07-15 20:04:19.298047+07	BBRI	1681	ASK	1234	7
2026-07-15 20:04:19.298047+07	BBRI	1691	ASK	1384	8
2026-07-15 20:04:19.298047+07	BBRI	1701	ASK	1570	9
2026-07-15 20:04:20.307601+07	BBRI	1661	BID	58994	5
2026-07-15 20:04:20.307601+07	BBRI	1651	BID	1250	6
2026-07-15 20:04:20.307601+07	BBRI	1641	BID	1494	7
2026-07-15 20:04:20.307601+07	BBRI	1631	BID	1634	8
2026-07-15 20:04:20.307601+07	BBRI	1621	BID	1629	9
2026-07-15 20:04:20.307601+07	BBRI	1661	ASK	1383	5
2026-07-15 20:04:20.307601+07	BBRI	1671	ASK	1142	6
2026-07-15 20:04:20.307601+07	BBRI	1681	ASK	1471	7
2026-07-15 20:04:20.307601+07	BBRI	1691	ASK	1776	8
2026-07-15 20:04:20.307601+07	BBRI	1701	ASK	1630	9
2026-07-15 20:04:21.316689+07	BBRI	1661	BID	59918	5
2026-07-15 20:04:21.316689+07	BBRI	1651	BID	1565	6
2026-07-15 20:04:21.316689+07	BBRI	1641	BID	1688	7
2026-07-15 20:04:21.316689+07	BBRI	1631	BID	1571	8
2026-07-15 20:04:21.316689+07	BBRI	1621	BID	1685	9
2026-07-15 20:04:21.316689+07	BBRI	1661	ASK	1449	5
2026-07-15 20:04:21.316689+07	BBRI	1671	ASK	1358	6
2026-07-15 20:04:21.316689+07	BBRI	1681	ASK	1556	7
2026-07-15 20:04:21.316689+07	BBRI	1691	ASK	1440	8
2026-07-15 20:04:21.316689+07	BBRI	1701	ASK	1844	9
2026-07-15 20:04:22.326413+07	BBRI	1661	BID	58272	5
2026-07-15 20:04:22.326413+07	BBRI	1651	BID	1550	6
2026-07-15 20:04:22.326413+07	BBRI	1641	BID	1383	7
2026-07-15 20:04:22.326413+07	BBRI	1631	BID	1717	8
2026-07-15 20:04:22.326413+07	BBRI	1621	BID	1477	9
2026-07-15 20:04:22.326413+07	BBRI	1661	ASK	1166	5
2026-07-15 20:04:22.326413+07	BBRI	1671	ASK	1582	6
2026-07-15 20:04:22.326413+07	BBRI	1681	ASK	1576	7
2026-07-15 20:04:22.326413+07	BBRI	1691	ASK	1649	8
2026-07-15 20:04:22.326413+07	BBRI	1701	ASK	1756	9
2026-07-15 20:04:23.335243+07	BBRI	1661	BID	50068	5
2026-07-15 20:04:23.335243+07	BBRI	1651	BID	1295	6
2026-07-15 20:04:23.335243+07	BBRI	1641	BID	1651	7
2026-07-15 20:04:23.335243+07	BBRI	1631	BID	1731	8
2026-07-15 20:04:23.335243+07	BBRI	1621	BID	1784	9
2026-07-15 20:04:23.335243+07	BBRI	1661	ASK	1138	5
2026-07-15 20:04:23.335243+07	BBRI	1671	ASK	1510	6
2026-07-15 20:04:23.335243+07	BBRI	1681	ASK	1301	7
2026-07-15 20:04:23.335243+07	BBRI	1691	ASK	1784	8
2026-07-15 20:04:23.335243+07	BBRI	1701	ASK	1538	9
2026-07-15 20:04:24.345976+07	BBRI	1661	BID	59429	5
2026-07-15 20:04:24.345976+07	BBRI	1651	BID	1356	6
2026-07-15 20:04:24.345976+07	BBRI	1641	BID	1243	7
2026-07-15 20:04:24.345976+07	BBRI	1631	BID	1492	8
2026-07-15 20:04:24.345976+07	BBRI	1621	BID	1473	9
2026-07-15 20:04:24.345976+07	BBRI	1661	ASK	1419	5
2026-07-15 20:04:24.345976+07	BBRI	1671	ASK	1473	6
2026-07-15 20:04:24.345976+07	BBRI	1681	ASK	1650	7
2026-07-15 20:04:24.345976+07	BBRI	1691	ASK	1559	8
2026-07-15 20:04:24.345976+07	BBRI	1701	ASK	1594	9
2026-07-15 20:04:25.35528+07	BBRI	1661	BID	55035	5
2026-07-15 20:04:25.35528+07	BBRI	1651	BID	1593	6
2026-07-15 20:04:25.35528+07	BBRI	1641	BID	1349	7
2026-07-15 20:04:25.35528+07	BBRI	1631	BID	1733	8
2026-07-15 20:04:25.35528+07	BBRI	1621	BID	1734	9
2026-07-15 20:04:25.35528+07	BBRI	1661	ASK	1277	5
2026-07-15 20:04:25.35528+07	BBRI	1671	ASK	1207	6
2026-07-15 20:04:25.35528+07	BBRI	1681	ASK	1415	7
2026-07-15 20:04:25.35528+07	BBRI	1691	ASK	1646	8
2026-07-15 20:04:25.35528+07	BBRI	1701	ASK	1617	9
2026-07-15 20:04:26.363971+07	BBRI	1661	BID	50405	5
2026-07-15 20:04:26.363971+07	BBRI	1651	BID	1561	6
2026-07-15 20:04:26.363971+07	BBRI	1641	BID	1470	7
2026-07-15 20:04:26.363971+07	BBRI	1631	BID	1377	8
2026-07-15 20:04:26.363971+07	BBRI	1621	BID	1824	9
2026-07-15 20:04:26.363971+07	BBRI	1661	ASK	1249	5
2026-07-15 20:04:26.363971+07	BBRI	1671	ASK	1469	6
2026-07-15 20:04:26.363971+07	BBRI	1681	ASK	1511	7
2026-07-15 20:04:26.363971+07	BBRI	1691	ASK	1333	8
2026-07-15 20:04:26.363971+07	BBRI	1701	ASK	1569	9
2026-07-15 20:04:27.376644+07	BBRI	1661	BID	54334	5
2026-07-15 20:04:27.376644+07	BBRI	1651	BID	1474	6
2026-07-15 20:04:27.376644+07	BBRI	1641	BID	1464	7
2026-07-15 20:04:27.376644+07	BBRI	1631	BID	1600	8
2026-07-15 20:04:27.376644+07	BBRI	1621	BID	1785	9
2026-07-15 20:04:27.376644+07	BBRI	1661	ASK	1028	5
2026-07-15 20:04:27.376644+07	BBRI	1671	ASK	1271	6
2026-07-15 20:04:27.376644+07	BBRI	1681	ASK	1616	7
2026-07-15 20:04:27.376644+07	BBRI	1691	ASK	1763	8
2026-07-15 20:04:27.376644+07	BBRI	1701	ASK	1745	9
2026-07-15 20:04:28.385595+07	BBRI	1661	BID	53801	5
2026-07-15 20:04:28.385595+07	BBRI	1651	BID	1341	6
2026-07-15 20:04:28.385595+07	BBRI	1641	BID	1500	7
2026-07-15 20:04:28.385595+07	BBRI	1631	BID	1425	8
2026-07-15 20:04:28.385595+07	BBRI	1621	BID	1824	9
2026-07-15 20:04:28.385595+07	BBRI	1661	ASK	1357	5
2026-07-15 20:04:28.385595+07	BBRI	1671	ASK	1520	6
2026-07-15 20:04:28.385595+07	BBRI	1681	ASK	1471	7
2026-07-15 20:04:28.385595+07	BBRI	1691	ASK	1635	8
2026-07-15 20:04:28.385595+07	BBRI	1701	ASK	1625	9
2026-07-15 20:04:29.395763+07	BBRI	1661	BID	59846	5
2026-07-15 20:04:29.395763+07	BBRI	1651	BID	1441	6
2026-07-15 20:04:29.395763+07	BBRI	1641	BID	1278	7
2026-07-15 20:04:29.395763+07	BBRI	1631	BID	1733	8
2026-07-15 20:04:29.395763+07	BBRI	1621	BID	1743	9
2026-07-15 20:04:29.395763+07	BBRI	1661	ASK	1098	5
2026-07-15 20:04:29.395763+07	BBRI	1671	ASK	1179	6
2026-07-15 20:04:29.395763+07	BBRI	1681	ASK	1293	7
2026-07-15 20:04:29.395763+07	BBRI	1691	ASK	1772	8
2026-07-15 20:04:29.395763+07	BBRI	1701	ASK	1600	9
2026-07-15 20:04:30.408029+07	BBRI	1661	BID	50962	5
2026-07-15 20:04:30.408029+07	BBRI	1651	BID	1248	6
2026-07-15 20:04:30.408029+07	BBRI	1641	BID	1453	7
2026-07-15 20:04:30.408029+07	BBRI	1631	BID	1463	8
2026-07-15 20:04:30.408029+07	BBRI	1621	BID	1659	9
2026-07-15 20:04:30.408029+07	BBRI	1661	ASK	1069	5
2026-07-15 20:04:30.408029+07	BBRI	1671	ASK	1541	6
2026-07-15 20:04:30.408029+07	BBRI	1681	ASK	1390	7
2026-07-15 20:04:30.408029+07	BBRI	1691	ASK	1486	8
2026-07-15 20:04:30.408029+07	BBRI	1701	ASK	1642	9
2026-07-15 20:04:31.412387+07	BBRI	1661	BID	58083	5
2026-07-15 20:04:31.412387+07	BBRI	1651	BID	1572	6
2026-07-15 20:04:31.412387+07	BBRI	1641	BID	1524	7
2026-07-15 20:04:31.412387+07	BBRI	1631	BID	1323	8
2026-07-15 20:04:31.412387+07	BBRI	1621	BID	1836	9
2026-07-15 20:04:31.412387+07	BBRI	1661	ASK	1164	5
2026-07-15 20:04:31.412387+07	BBRI	1671	ASK	1491	6
2026-07-15 20:04:31.412387+07	BBRI	1681	ASK	1462	7
2026-07-15 20:04:31.412387+07	BBRI	1691	ASK	1440	8
2026-07-15 20:04:31.412387+07	BBRI	1701	ASK	1456	9
2026-07-15 20:04:32.420967+07	BBRI	1661	BID	52093	5
2026-07-15 20:04:32.420967+07	BBRI	1651	BID	1444	6
2026-07-15 20:04:32.420967+07	BBRI	1641	BID	1585	7
2026-07-15 20:04:32.420967+07	BBRI	1631	BID	1468	8
2026-07-15 20:04:32.420967+07	BBRI	1621	BID	1657	9
2026-07-15 20:04:32.420967+07	BBRI	1661	ASK	1003	5
2026-07-15 20:04:32.420967+07	BBRI	1671	ASK	1534	6
2026-07-15 20:04:32.420967+07	BBRI	1681	ASK	1527	7
2026-07-15 20:04:32.420967+07	BBRI	1691	ASK	1604	8
2026-07-15 20:04:32.420967+07	BBRI	1701	ASK	1773	9
2026-07-15 20:04:33.428743+07	BBRI	1661	BID	58073	5
2026-07-15 20:04:33.428743+07	BBRI	1651	BID	1285	6
2026-07-15 20:04:33.428743+07	BBRI	1641	BID	1368	7
2026-07-15 20:04:33.428743+07	BBRI	1631	BID	1571	8
2026-07-15 20:04:33.428743+07	BBRI	1621	BID	1836	9
2026-07-15 20:04:33.428743+07	BBRI	1661	ASK	1484	5
2026-07-15 20:04:33.428743+07	BBRI	1671	ASK	1432	6
2026-07-15 20:04:33.428743+07	BBRI	1681	ASK	1599	7
2026-07-15 20:04:33.428743+07	BBRI	1691	ASK	1407	8
2026-07-15 20:04:33.428743+07	BBRI	1701	ASK	1792	9
2026-07-15 20:04:34.439014+07	BBRI	1661	BID	56914	5
2026-07-15 20:04:34.439014+07	BBRI	1651	BID	1427	6
2026-07-15 20:04:34.439014+07	BBRI	1641	BID	1226	7
2026-07-15 20:04:34.439014+07	BBRI	1631	BID	1552	8
2026-07-15 20:04:34.439014+07	BBRI	1621	BID	1831	9
2026-07-15 20:04:34.439014+07	BBRI	1661	ASK	1209	5
2026-07-15 20:04:34.439014+07	BBRI	1671	ASK	1476	6
2026-07-15 20:04:34.439014+07	BBRI	1681	ASK	1462	7
2026-07-15 20:04:34.439014+07	BBRI	1691	ASK	1457	8
2026-07-15 20:04:34.439014+07	BBRI	1701	ASK	1446	9
2026-07-15 20:04:35.445065+07	BBRI	1661	BID	50755	5
2026-07-15 20:04:35.445065+07	BBRI	1651	BID	1321	6
2026-07-15 20:04:35.445065+07	BBRI	1641	BID	1423	7
2026-07-15 20:04:35.445065+07	BBRI	1631	BID	1775	8
2026-07-15 20:04:35.445065+07	BBRI	1621	BID	1855	9
2026-07-15 20:04:35.445065+07	BBRI	1661	ASK	1285	5
2026-07-15 20:04:35.445065+07	BBRI	1671	ASK	1413	6
2026-07-15 20:04:35.445065+07	BBRI	1681	ASK	1500	7
2026-07-15 20:04:35.445065+07	BBRI	1691	ASK	1395	8
2026-07-15 20:04:35.445065+07	BBRI	1701	ASK	1832	9
2026-07-15 20:04:36.451541+07	BBRI	1661	BID	50048	5
2026-07-15 20:04:36.451541+07	BBRI	1651	BID	1223	6
2026-07-15 20:04:36.451541+07	BBRI	1641	BID	1503	7
2026-07-15 20:04:36.451541+07	BBRI	1631	BID	1608	8
2026-07-15 20:04:36.451541+07	BBRI	1621	BID	1845	9
2026-07-15 20:04:36.451541+07	BBRI	1661	ASK	1032	5
2026-07-15 20:04:36.451541+07	BBRI	1671	ASK	1320	6
2026-07-15 20:04:36.451541+07	BBRI	1681	ASK	1417	7
2026-07-15 20:04:36.451541+07	BBRI	1691	ASK	1652	8
2026-07-15 20:04:36.451541+07	BBRI	1701	ASK	1699	9
2026-07-15 20:04:37.461736+07	BBRI	1661	BID	53523	5
2026-07-15 20:04:37.461736+07	BBRI	1651	BID	1461	6
2026-07-15 20:04:37.461736+07	BBRI	1641	BID	1385	7
2026-07-15 20:04:37.461736+07	BBRI	1631	BID	1765	8
2026-07-15 20:04:37.461736+07	BBRI	1621	BID	1485	9
2026-07-15 20:04:37.461736+07	BBRI	1661	ASK	1079	5
2026-07-15 20:04:37.461736+07	BBRI	1671	ASK	1554	6
2026-07-15 20:04:37.461736+07	BBRI	1681	ASK	1239	7
2026-07-15 20:04:37.461736+07	BBRI	1691	ASK	1380	8
2026-07-15 20:04:37.461736+07	BBRI	1701	ASK	1701	9
2026-07-15 20:04:38.468132+07	BBRI	1661	BID	51019	5
2026-07-15 20:04:38.468132+07	BBRI	1651	BID	1495	6
2026-07-15 20:04:38.468132+07	BBRI	1641	BID	1403	7
2026-07-15 20:04:38.468132+07	BBRI	1631	BID	1512	8
2026-07-15 20:04:38.468132+07	BBRI	1621	BID	1552	9
2026-07-15 20:04:38.468132+07	BBRI	1661	ASK	1217	5
2026-07-15 20:04:38.468132+07	BBRI	1671	ASK	1331	6
2026-07-15 20:04:38.468132+07	BBRI	1681	ASK	1646	7
2026-07-15 20:04:38.468132+07	BBRI	1691	ASK	1339	8
2026-07-15 20:04:38.468132+07	BBRI	1701	ASK	1693	9
2026-07-15 20:04:39.47845+07	BBRI	1661	BID	57580	5
2026-07-15 20:04:39.47845+07	BBRI	1651	BID	1293	6
2026-07-15 20:04:39.47845+07	BBRI	1641	BID	1332	7
2026-07-15 20:04:39.47845+07	BBRI	1631	BID	1600	8
2026-07-15 20:04:39.47845+07	BBRI	1621	BID	1633	9
2026-07-15 20:04:39.47845+07	BBRI	1661	ASK	1288	5
2026-07-15 20:04:39.47845+07	BBRI	1671	ASK	1118	6
2026-07-15 20:04:39.47845+07	BBRI	1681	ASK	1527	7
2026-07-15 20:04:39.47845+07	BBRI	1691	ASK	1460	8
2026-07-15 20:04:39.47845+07	BBRI	1701	ASK	1810	9
2026-07-15 20:04:40.485619+07	BBRI	1661	BID	58241	5
2026-07-15 20:04:40.485619+07	BBRI	1651	BID	1137	6
2026-07-15 20:04:40.485619+07	BBRI	1641	BID	1212	7
2026-07-15 20:04:40.485619+07	BBRI	1631	BID	1540	8
2026-07-15 20:04:40.485619+07	BBRI	1621	BID	1771	9
2026-07-15 20:04:40.485619+07	BBRI	1661	ASK	1467	5
2026-07-15 20:04:40.485619+07	BBRI	1671	ASK	1364	6
2026-07-15 20:04:40.485619+07	BBRI	1681	ASK	1278	7
2026-07-15 20:04:40.485619+07	BBRI	1691	ASK	1702	8
2026-07-15 20:04:40.485619+07	BBRI	1701	ASK	1527	9
2026-07-15 20:04:41.49422+07	BBRI	1661	BID	53437	5
2026-07-15 20:04:41.49422+07	BBRI	1651	BID	1275	6
2026-07-15 20:04:41.49422+07	BBRI	1641	BID	1602	7
2026-07-15 20:04:41.49422+07	BBRI	1631	BID	1381	8
2026-07-15 20:04:41.49422+07	BBRI	1621	BID	1897	9
2026-07-15 20:04:41.49422+07	BBRI	1661	ASK	1060	5
2026-07-15 20:04:41.49422+07	BBRI	1671	ASK	1451	6
2026-07-15 20:04:41.49422+07	BBRI	1681	ASK	1467	7
2026-07-15 20:04:41.49422+07	BBRI	1691	ASK	1698	8
2026-07-15 20:04:41.49422+07	BBRI	1701	ASK	1746	9
2026-07-15 20:04:42.503458+07	BBRI	1661	BID	54224	5
2026-07-15 20:04:42.503458+07	BBRI	1651	BID	1415	6
2026-07-15 20:04:42.503458+07	BBRI	1641	BID	1503	7
2026-07-15 20:04:42.503458+07	BBRI	1631	BID	1776	8
2026-07-15 20:04:42.503458+07	BBRI	1621	BID	1688	9
2026-07-15 20:04:42.503458+07	BBRI	1661	ASK	1322	5
2026-07-15 20:04:42.503458+07	BBRI	1671	ASK	1372	6
2026-07-15 20:04:42.503458+07	BBRI	1681	ASK	1627	7
2026-07-15 20:04:42.503458+07	BBRI	1691	ASK	1549	8
2026-07-15 20:04:42.503458+07	BBRI	1701	ASK	1733	9
2026-07-15 20:04:43.513766+07	BBRI	1661	BID	52734	5
2026-07-15 20:04:43.513766+07	BBRI	1651	BID	1237	6
2026-07-15 20:04:43.513766+07	BBRI	1641	BID	1640	7
2026-07-15 20:04:43.513766+07	BBRI	1631	BID	1769	8
2026-07-15 20:04:43.513766+07	BBRI	1621	BID	1467	9
2026-07-15 20:04:43.513766+07	BBRI	1661	ASK	1278	5
2026-07-15 20:04:43.513766+07	BBRI	1671	ASK	1286	6
2026-07-15 20:04:43.513766+07	BBRI	1681	ASK	1390	7
2026-07-15 20:04:43.513766+07	BBRI	1691	ASK	1559	8
2026-07-15 20:04:43.513766+07	BBRI	1701	ASK	1869	9
2026-07-15 20:04:44.52819+07	BBRI	1661	BID	51007	5
2026-07-15 20:04:44.52819+07	BBRI	1651	BID	1295	6
2026-07-15 20:04:44.52819+07	BBRI	1641	BID	1340	7
2026-07-15 20:04:44.52819+07	BBRI	1631	BID	1585	8
2026-07-15 20:04:44.52819+07	BBRI	1621	BID	1871	9
2026-07-15 20:04:44.52819+07	BBRI	1661	ASK	1326	5
2026-07-15 20:04:44.52819+07	BBRI	1671	ASK	1437	6
2026-07-15 20:04:44.52819+07	BBRI	1681	ASK	1620	7
2026-07-15 20:04:44.52819+07	BBRI	1691	ASK	1526	8
2026-07-15 20:04:44.52819+07	BBRI	1701	ASK	1615	9
2026-07-15 20:04:45.533853+07	BBRI	1661	BID	55346	5
2026-07-15 20:04:45.533853+07	BBRI	1651	BID	1255	6
2026-07-15 20:04:45.533853+07	BBRI	1641	BID	1213	7
2026-07-15 20:04:45.533853+07	BBRI	1631	BID	1736	8
2026-07-15 20:04:45.533853+07	BBRI	1621	BID	1692	9
2026-07-15 20:04:45.533853+07	BBRI	1661	ASK	1299	5
2026-07-15 20:04:45.533853+07	BBRI	1671	ASK	1212	6
2026-07-15 20:04:45.533853+07	BBRI	1681	ASK	1367	7
2026-07-15 20:04:45.533853+07	BBRI	1691	ASK	1509	8
2026-07-15 20:04:45.533853+07	BBRI	1701	ASK	1825	9
2026-07-15 20:04:46.547984+07	BBRI	1661	BID	59377	5
2026-07-15 20:04:46.547984+07	BBRI	1651	BID	1413	6
2026-07-15 20:04:46.547984+07	BBRI	1641	BID	1516	7
2026-07-15 20:04:46.547984+07	BBRI	1631	BID	1795	8
2026-07-15 20:04:46.547984+07	BBRI	1621	BID	1588	9
2026-07-15 20:04:46.547984+07	BBRI	1661	ASK	1027	5
2026-07-15 20:04:46.547984+07	BBRI	1671	ASK	1406	6
2026-07-15 20:04:46.547984+07	BBRI	1681	ASK	1310	7
2026-07-15 20:04:46.547984+07	BBRI	1691	ASK	1509	8
2026-07-15 20:04:46.547984+07	BBRI	1701	ASK	1464	9
2026-07-15 20:04:47.560686+07	BBRI	1661	BID	53313	5
2026-07-15 20:04:47.560686+07	BBRI	1651	BID	1364	6
2026-07-15 20:04:47.560686+07	BBRI	1641	BID	1275	7
2026-07-15 20:04:47.560686+07	BBRI	1631	BID	1528	8
2026-07-15 20:04:47.560686+07	BBRI	1621	BID	1780	9
2026-07-15 20:04:47.560686+07	BBRI	1661	ASK	1181	5
2026-07-15 20:04:47.560686+07	BBRI	1671	ASK	1222	6
2026-07-15 20:04:47.560686+07	BBRI	1681	ASK	1427	7
2026-07-15 20:04:47.560686+07	BBRI	1691	ASK	1766	8
2026-07-15 20:04:47.560686+07	BBRI	1701	ASK	1440	9
2026-07-15 20:04:48.571351+07	BBRI	1661	BID	53494	5
2026-07-15 20:04:48.571351+07	BBRI	1651	BID	1312	6
2026-07-15 20:04:48.571351+07	BBRI	1641	BID	1453	7
2026-07-15 20:04:48.571351+07	BBRI	1631	BID	1721	8
2026-07-15 20:04:48.571351+07	BBRI	1621	BID	1859	9
2026-07-15 20:04:48.571351+07	BBRI	1661	ASK	1420	5
2026-07-15 20:04:48.571351+07	BBRI	1671	ASK	1104	6
2026-07-15 20:04:48.571351+07	BBRI	1681	ASK	1689	7
2026-07-15 20:04:48.571351+07	BBRI	1691	ASK	1496	8
2026-07-15 20:04:48.571351+07	BBRI	1701	ASK	1678	9
2026-07-15 20:04:49.579208+07	BBRI	1661	BID	59773	5
2026-07-15 20:04:49.579208+07	BBRI	1651	BID	1337	6
2026-07-15 20:04:49.579208+07	BBRI	1641	BID	1530	7
2026-07-15 20:04:49.579208+07	BBRI	1631	BID	1424	8
2026-07-15 20:04:49.579208+07	BBRI	1621	BID	1866	9
2026-07-15 20:04:49.579208+07	BBRI	1661	ASK	1025	5
2026-07-15 20:04:49.579208+07	BBRI	1671	ASK	1497	6
2026-07-15 20:04:49.579208+07	BBRI	1681	ASK	1540	7
2026-07-15 20:04:49.579208+07	BBRI	1691	ASK	1642	8
2026-07-15 20:04:49.579208+07	BBRI	1701	ASK	1499	9
2026-07-15 20:04:50.586966+07	BBRI	1661	BID	53810	5
2026-07-15 20:04:50.586966+07	BBRI	1651	BID	1554	6
2026-07-15 20:04:50.586966+07	BBRI	1641	BID	1295	7
2026-07-15 20:04:50.586966+07	BBRI	1631	BID	1694	8
2026-07-15 20:04:50.586966+07	BBRI	1621	BID	1866	9
2026-07-15 20:04:50.586966+07	BBRI	1661	ASK	1402	5
2026-07-15 20:04:50.586966+07	BBRI	1671	ASK	1264	6
2026-07-15 20:04:50.586966+07	BBRI	1681	ASK	1520	7
2026-07-15 20:04:50.586966+07	BBRI	1691	ASK	1451	8
2026-07-15 20:04:50.586966+07	BBRI	1701	ASK	1814	9
2026-07-15 20:04:51.598089+07	BBRI	1661	BID	54167	5
2026-07-15 20:04:51.598089+07	BBRI	1651	BID	1261	6
2026-07-15 20:04:51.598089+07	BBRI	1641	BID	1292	7
2026-07-15 20:04:51.598089+07	BBRI	1631	BID	1420	8
2026-07-15 20:04:51.598089+07	BBRI	1621	BID	1535	9
2026-07-15 20:04:51.598089+07	BBRI	1661	ASK	1304	5
2026-07-15 20:04:51.598089+07	BBRI	1671	ASK	1202	6
2026-07-15 20:04:51.598089+07	BBRI	1681	ASK	1440	7
2026-07-15 20:04:51.598089+07	BBRI	1691	ASK	1732	8
2026-07-15 20:04:51.598089+07	BBRI	1701	ASK	1670	9
2026-07-15 20:04:52.609463+07	BBRI	1661	BID	53892	5
2026-07-15 20:04:52.609463+07	BBRI	1651	BID	1465	6
2026-07-15 20:04:52.609463+07	BBRI	1641	BID	1566	7
2026-07-15 20:04:52.609463+07	BBRI	1631	BID	1788	8
2026-07-15 20:04:52.609463+07	BBRI	1621	BID	1467	9
2026-07-15 20:04:52.609463+07	BBRI	1661	ASK	1041	5
2026-07-15 20:04:52.609463+07	BBRI	1671	ASK	1467	6
2026-07-15 20:04:52.609463+07	BBRI	1681	ASK	1482	7
2026-07-15 20:04:52.609463+07	BBRI	1691	ASK	1578	8
2026-07-15 20:04:52.609463+07	BBRI	1701	ASK	1573	9
2026-07-15 20:04:53.621082+07	BBRI	1661	BID	56210	5
2026-07-15 20:04:53.621082+07	BBRI	1651	BID	1415	6
2026-07-15 20:04:53.621082+07	BBRI	1641	BID	1403	7
2026-07-15 20:04:53.621082+07	BBRI	1631	BID	1361	8
2026-07-15 20:04:53.621082+07	BBRI	1621	BID	1884	9
2026-07-15 20:04:53.621082+07	BBRI	1661	ASK	1015	5
2026-07-15 20:04:53.621082+07	BBRI	1671	ASK	1248	6
2026-07-15 20:04:53.621082+07	BBRI	1681	ASK	1427	7
2026-07-15 20:04:53.621082+07	BBRI	1691	ASK	1445	8
2026-07-15 20:04:53.621082+07	BBRI	1701	ASK	1538	9
2026-07-15 20:04:54.631876+07	BBRI	1661	BID	52809	5
2026-07-15 20:04:54.631876+07	BBRI	1651	BID	1252	6
2026-07-15 20:04:54.631876+07	BBRI	1641	BID	1609	7
2026-07-15 20:04:54.631876+07	BBRI	1631	BID	1614	8
2026-07-15 20:04:54.631876+07	BBRI	1621	BID	1834	9
2026-07-15 20:04:54.631876+07	BBRI	1661	ASK	1293	5
2026-07-15 20:04:54.631876+07	BBRI	1671	ASK	1320	6
2026-07-15 20:04:54.631876+07	BBRI	1681	ASK	1509	7
2026-07-15 20:04:54.631876+07	BBRI	1691	ASK	1678	8
2026-07-15 20:04:54.631876+07	BBRI	1701	ASK	1424	9
2026-07-15 20:04:55.640829+07	BBRI	1661	BID	51971	5
2026-07-15 20:04:55.640829+07	BBRI	1651	BID	1572	6
2026-07-15 20:04:55.640829+07	BBRI	1641	BID	1434	7
2026-07-15 20:04:55.640829+07	BBRI	1631	BID	1647	8
2026-07-15 20:04:55.640829+07	BBRI	1621	BID	1789	9
2026-07-15 20:04:55.640829+07	BBRI	1661	ASK	1296	5
2026-07-15 20:04:55.640829+07	BBRI	1671	ASK	1439	6
2026-07-15 20:04:55.640829+07	BBRI	1681	ASK	1342	7
2026-07-15 20:04:55.640829+07	BBRI	1691	ASK	1655	8
2026-07-15 20:04:55.640829+07	BBRI	1701	ASK	1501	9
2026-07-15 20:04:56.650785+07	BBRI	1661	BID	50155	5
2026-07-15 20:04:56.650785+07	BBRI	1651	BID	1453	6
2026-07-15 20:04:56.650785+07	BBRI	1641	BID	1353	7
2026-07-15 20:04:56.650785+07	BBRI	1631	BID	1456	8
2026-07-15 20:04:56.650785+07	BBRI	1621	BID	1574	9
2026-07-15 20:04:56.650785+07	BBRI	1661	ASK	1250	5
2026-07-15 20:04:56.650785+07	BBRI	1671	ASK	1172	6
2026-07-15 20:04:56.650785+07	BBRI	1681	ASK	1294	7
2026-07-15 20:04:56.650785+07	BBRI	1691	ASK	1716	8
2026-07-15 20:04:56.650785+07	BBRI	1701	ASK	1714	9
2026-07-15 20:03:18.150436+07	BMRI	2951	BID	1179	5
2026-07-15 20:03:18.150436+07	BMRI	2941	BID	1326	6
2026-07-15 20:03:18.150436+07	BMRI	2931	BID	1459	7
2026-07-15 20:03:18.150436+07	BMRI	2921	BID	1400	8
2026-07-15 20:03:18.150436+07	BMRI	2911	BID	1749	9
2026-07-15 20:03:18.150436+07	BMRI	2951	ASK	1499	5
2026-07-15 20:03:18.150436+07	BMRI	2961	ASK	1228	6
2026-07-15 20:03:18.150436+07	BMRI	2971	ASK	1638	7
2026-07-15 20:03:18.150436+07	BMRI	2981	ASK	1594	8
2026-07-15 20:03:18.150436+07	BMRI	2991	ASK	1482	9
2026-07-15 20:03:19.159701+07	BMRI	2951	BID	1355	5
2026-07-15 20:03:19.159701+07	BMRI	2941	BID	1410	6
2026-07-15 20:03:19.159701+07	BMRI	2931	BID	1321	7
2026-07-15 20:03:19.159701+07	BMRI	2921	BID	1676	8
2026-07-15 20:03:19.159701+07	BMRI	2911	BID	1516	9
2026-07-15 20:03:19.159701+07	BMRI	2951	ASK	1276	5
2026-07-15 20:03:19.159701+07	BMRI	2961	ASK	1139	6
2026-07-15 20:03:19.159701+07	BMRI	2971	ASK	1514	7
2026-07-15 20:03:19.159701+07	BMRI	2981	ASK	1463	8
2026-07-15 20:03:19.159701+07	BMRI	2991	ASK	1852	9
2026-07-15 20:03:20.166503+07	BMRI	2951	BID	1201	5
2026-07-15 20:03:20.166503+07	BMRI	2941	BID	1199	6
2026-07-15 20:03:20.166503+07	BMRI	2931	BID	1613	7
2026-07-15 20:03:20.166503+07	BMRI	2921	BID	1428	8
2026-07-15 20:03:20.166503+07	BMRI	2911	BID	1400	9
2026-07-15 20:03:20.166503+07	BMRI	2951	ASK	1202	5
2026-07-15 20:03:20.166503+07	BMRI	2961	ASK	1264	6
2026-07-15 20:03:20.166503+07	BMRI	2971	ASK	1369	7
2026-07-15 20:03:20.166503+07	BMRI	2981	ASK	1304	8
2026-07-15 20:03:20.166503+07	BMRI	2991	ASK	1736	9
2026-07-15 20:03:21.175912+07	BMRI	2951	BID	1036	5
2026-07-15 20:03:21.175912+07	BMRI	2941	BID	1599	6
2026-07-15 20:03:21.175912+07	BMRI	2931	BID	1382	7
2026-07-15 20:03:21.175912+07	BMRI	2921	BID	1305	8
2026-07-15 20:03:21.175912+07	BMRI	2911	BID	1591	9
2026-07-15 20:03:21.175912+07	BMRI	2951	ASK	1040	5
2026-07-15 20:03:21.175912+07	BMRI	2961	ASK	1469	6
2026-07-15 20:03:21.175912+07	BMRI	2971	ASK	1457	7
2026-07-15 20:03:21.175912+07	BMRI	2981	ASK	1496	8
2026-07-15 20:03:21.175912+07	BMRI	2991	ASK	1686	9
2026-07-15 20:03:22.186353+07	BMRI	2951	BID	1123	5
2026-07-15 20:03:22.186353+07	BMRI	2941	BID	1566	6
2026-07-15 20:03:22.186353+07	BMRI	2931	BID	1447	7
2026-07-15 20:03:22.186353+07	BMRI	2921	BID	1368	8
2026-07-15 20:03:22.186353+07	BMRI	2911	BID	1883	9
2026-07-15 20:03:22.186353+07	BMRI	2951	ASK	1032	5
2026-07-15 20:03:22.186353+07	BMRI	2961	ASK	1324	6
2026-07-15 20:03:22.186353+07	BMRI	2971	ASK	1418	7
2026-07-15 20:03:22.186353+07	BMRI	2981	ASK	1333	8
2026-07-15 20:03:22.186353+07	BMRI	2991	ASK	1559	9
2026-07-15 20:03:23.196504+07	BMRI	2951	BID	1023	5
2026-07-15 20:03:23.196504+07	BMRI	2941	BID	1413	6
2026-07-15 20:03:23.196504+07	BMRI	2931	BID	1536	7
2026-07-15 20:03:23.196504+07	BMRI	2921	BID	1541	8
2026-07-15 20:03:23.196504+07	BMRI	2911	BID	1631	9
2026-07-15 20:03:23.196504+07	BMRI	2951	ASK	1263	5
2026-07-15 20:03:23.196504+07	BMRI	2961	ASK	1510	6
2026-07-15 20:03:23.196504+07	BMRI	2971	ASK	1589	7
2026-07-15 20:03:23.196504+07	BMRI	2981	ASK	1487	8
2026-07-15 20:03:23.196504+07	BMRI	2991	ASK	1493	9
2026-07-15 20:03:24.20655+07	BMRI	2951	BID	1064	5
2026-07-15 20:03:24.20655+07	BMRI	2941	BID	1211	6
2026-07-15 20:03:24.20655+07	BMRI	2931	BID	1319	7
2026-07-15 20:03:24.20655+07	BMRI	2921	BID	1316	8
2026-07-15 20:03:24.20655+07	BMRI	2911	BID	1588	9
2026-07-15 20:03:24.20655+07	BMRI	2951	ASK	1130	5
2026-07-15 20:03:24.20655+07	BMRI	2961	ASK	1260	6
2026-07-15 20:03:24.20655+07	BMRI	2971	ASK	1437	7
2026-07-15 20:03:24.20655+07	BMRI	2981	ASK	1330	8
2026-07-15 20:03:24.20655+07	BMRI	2991	ASK	1788	9
2026-07-15 20:03:25.216029+07	BMRI	2951	BID	1045	5
2026-07-15 20:03:25.216029+07	BMRI	2941	BID	1459	6
2026-07-15 20:03:25.216029+07	BMRI	2931	BID	1570	7
2026-07-15 20:03:25.216029+07	BMRI	2921	BID	1433	8
2026-07-15 20:03:25.216029+07	BMRI	2911	BID	1401	9
2026-07-15 20:03:25.216029+07	BMRI	2951	ASK	1324	5
2026-07-15 20:03:25.216029+07	BMRI	2961	ASK	1100	6
2026-07-15 20:03:25.216029+07	BMRI	2971	ASK	1665	7
2026-07-15 20:03:25.216029+07	BMRI	2981	ASK	1370	8
2026-07-15 20:03:25.216029+07	BMRI	2991	ASK	1876	9
2026-07-15 20:03:26.223693+07	BMRI	2951	BID	1279	5
2026-07-15 20:03:26.223693+07	BMRI	2941	BID	1570	6
2026-07-15 20:03:26.223693+07	BMRI	2931	BID	1485	7
2026-07-15 20:03:26.223693+07	BMRI	2921	BID	1565	8
2026-07-15 20:03:26.223693+07	BMRI	2911	BID	1566	9
2026-07-15 20:03:26.223693+07	BMRI	2951	ASK	1442	5
2026-07-15 20:03:26.223693+07	BMRI	2961	ASK	1225	6
2026-07-15 20:03:26.223693+07	BMRI	2971	ASK	1474	7
2026-07-15 20:03:26.223693+07	BMRI	2981	ASK	1797	8
2026-07-15 20:03:26.223693+07	BMRI	2991	ASK	1535	9
2026-07-15 20:03:27.234127+07	BMRI	2951	BID	1459	5
2026-07-15 20:03:27.234127+07	BMRI	2941	BID	1483	6
2026-07-15 20:03:27.234127+07	BMRI	2931	BID	1445	7
2026-07-15 20:03:27.234127+07	BMRI	2921	BID	1618	8
2026-07-15 20:03:27.234127+07	BMRI	2911	BID	1694	9
2026-07-15 20:03:27.234127+07	BMRI	2951	ASK	1443	5
2026-07-15 20:03:27.234127+07	BMRI	2961	ASK	1180	6
2026-07-15 20:03:27.234127+07	BMRI	2971	ASK	1608	7
2026-07-15 20:03:27.234127+07	BMRI	2981	ASK	1716	8
2026-07-15 20:03:27.234127+07	BMRI	2991	ASK	1707	9
2026-07-15 20:03:28.241544+07	BMRI	2951	BID	1230	5
2026-07-15 20:03:28.241544+07	BMRI	2941	BID	1452	6
2026-07-15 20:03:28.241544+07	BMRI	2931	BID	1691	7
2026-07-15 20:03:28.241544+07	BMRI	2921	BID	1655	8
2026-07-15 20:03:28.241544+07	BMRI	2911	BID	1827	9
2026-07-15 20:03:28.241544+07	BMRI	2951	ASK	1067	5
2026-07-15 20:03:28.241544+07	BMRI	2961	ASK	1351	6
2026-07-15 20:03:28.241544+07	BMRI	2971	ASK	1215	7
2026-07-15 20:03:28.241544+07	BMRI	2981	ASK	1364	8
2026-07-15 20:03:28.241544+07	BMRI	2991	ASK	1725	9
2026-07-15 20:03:29.25134+07	BMRI	2951	BID	1100	5
2026-07-15 20:03:29.25134+07	BMRI	2941	BID	1214	6
2026-07-15 20:03:29.25134+07	BMRI	2931	BID	1699	7
2026-07-15 20:03:29.25134+07	BMRI	2921	BID	1310	8
2026-07-15 20:03:29.25134+07	BMRI	2911	BID	1807	9
2026-07-15 20:03:29.25134+07	BMRI	2951	ASK	1436	5
2026-07-15 20:03:29.25134+07	BMRI	2961	ASK	1200	6
2026-07-15 20:03:29.25134+07	BMRI	2971	ASK	1591	7
2026-07-15 20:03:29.25134+07	BMRI	2981	ASK	1731	8
2026-07-15 20:03:29.25134+07	BMRI	2991	ASK	1731	9
2026-07-15 20:03:30.257901+07	BMRI	2951	BID	1114	5
2026-07-15 20:03:30.257901+07	BMRI	2941	BID	1466	6
2026-07-15 20:03:30.257901+07	BMRI	2931	BID	1551	7
2026-07-15 20:03:30.257901+07	BMRI	2921	BID	1671	8
2026-07-15 20:03:30.257901+07	BMRI	2911	BID	1789	9
2026-07-15 20:03:30.257901+07	BMRI	2951	ASK	1421	5
2026-07-15 20:03:30.257901+07	BMRI	2961	ASK	1464	6
2026-07-15 20:03:30.257901+07	BMRI	2971	ASK	1617	7
2026-07-15 20:03:30.257901+07	BMRI	2981	ASK	1384	8
2026-07-15 20:03:30.257901+07	BMRI	2991	ASK	1577	9
2026-07-15 20:03:31.26609+07	BMRI	2951	BID	1475	5
2026-07-15 20:03:31.26609+07	BMRI	2941	BID	1240	6
2026-07-15 20:03:31.26609+07	BMRI	2931	BID	1634	7
2026-07-15 20:03:31.26609+07	BMRI	2921	BID	1530	8
2026-07-15 20:03:31.26609+07	BMRI	2911	BID	1783	9
2026-07-15 20:03:31.26609+07	BMRI	2951	ASK	1077	5
2026-07-15 20:03:31.26609+07	BMRI	2961	ASK	1574	6
2026-07-15 20:03:31.26609+07	BMRI	2971	ASK	1212	7
2026-07-15 20:03:31.26609+07	BMRI	2981	ASK	1359	8
2026-07-15 20:03:31.26609+07	BMRI	2991	ASK	1648	9
2026-07-15 20:03:32.274524+07	BMRI	2951	BID	1075	5
2026-07-15 20:03:32.274524+07	BMRI	2941	BID	1558	6
2026-07-15 20:03:32.274524+07	BMRI	2931	BID	1254	7
2026-07-15 20:03:32.274524+07	BMRI	2921	BID	1671	8
2026-07-15 20:03:32.274524+07	BMRI	2911	BID	1475	9
2026-07-15 20:03:32.274524+07	BMRI	2951	ASK	1403	5
2026-07-15 20:03:32.274524+07	BMRI	2961	ASK	1553	6
2026-07-15 20:03:32.274524+07	BMRI	2971	ASK	1528	7
2026-07-15 20:03:32.274524+07	BMRI	2981	ASK	1537	8
2026-07-15 20:03:32.274524+07	BMRI	2991	ASK	1849	9
2026-07-15 20:03:33.284305+07	BMRI	2951	BID	1023	5
2026-07-15 20:03:33.284305+07	BMRI	2941	BID	1461	6
2026-07-15 20:03:33.284305+07	BMRI	2931	BID	1269	7
2026-07-15 20:03:33.284305+07	BMRI	2921	BID	1566	8
2026-07-15 20:03:33.284305+07	BMRI	2911	BID	1585	9
2026-07-15 20:03:33.284305+07	BMRI	2951	ASK	1229	5
2026-07-15 20:03:33.284305+07	BMRI	2961	ASK	1183	6
2026-07-15 20:03:33.284305+07	BMRI	2971	ASK	1261	7
2026-07-15 20:03:33.284305+07	BMRI	2981	ASK	1688	8
2026-07-15 20:03:33.284305+07	BMRI	2991	ASK	1608	9
2026-07-15 20:03:34.291672+07	BMRI	2951	BID	1494	5
2026-07-15 20:03:34.291672+07	BMRI	2941	BID	1473	6
2026-07-15 20:03:34.291672+07	BMRI	2931	BID	1574	7
2026-07-15 20:03:34.291672+07	BMRI	2921	BID	1693	8
2026-07-15 20:03:34.291672+07	BMRI	2911	BID	1684	9
2026-07-15 20:03:34.291672+07	BMRI	2951	ASK	1358	5
2026-07-15 20:03:34.291672+07	BMRI	2961	ASK	1312	6
2026-07-15 20:03:34.291672+07	BMRI	2971	ASK	1596	7
2026-07-15 20:03:34.291672+07	BMRI	2981	ASK	1323	8
2026-07-15 20:03:34.291672+07	BMRI	2991	ASK	1881	9
2026-07-15 20:03:35.30145+07	BMRI	2951	BID	1166	5
2026-07-15 20:03:35.30145+07	BMRI	2941	BID	1473	6
2026-07-15 20:03:35.30145+07	BMRI	2931	BID	1510	7
2026-07-15 20:03:35.30145+07	BMRI	2921	BID	1737	8
2026-07-15 20:03:35.30145+07	BMRI	2911	BID	1440	9
2026-07-15 20:03:35.30145+07	BMRI	2951	ASK	1310	5
2026-07-15 20:03:35.30145+07	BMRI	2961	ASK	1254	6
2026-07-15 20:03:35.30145+07	BMRI	2971	ASK	1460	7
2026-07-15 20:03:35.30145+07	BMRI	2981	ASK	1422	8
2026-07-15 20:03:35.30145+07	BMRI	2991	ASK	1879	9
2026-07-15 20:03:36.311423+07	BMRI	2951	BID	1033	5
2026-07-15 20:03:36.311423+07	BMRI	2941	BID	1268	6
2026-07-15 20:03:36.311423+07	BMRI	2931	BID	1377	7
2026-07-15 20:03:36.311423+07	BMRI	2921	BID	1760	8
2026-07-15 20:03:36.311423+07	BMRI	2911	BID	1444	9
2026-07-15 20:03:36.311423+07	BMRI	2951	ASK	1171	5
2026-07-15 20:03:36.311423+07	BMRI	2961	ASK	1392	6
2026-07-15 20:03:36.311423+07	BMRI	2971	ASK	1658	7
2026-07-15 20:03:36.311423+07	BMRI	2981	ASK	1639	8
2026-07-15 20:03:36.311423+07	BMRI	2991	ASK	1638	9
2026-07-15 20:03:37.320256+07	BMRI	2951	BID	1444	5
2026-07-15 20:03:37.320256+07	BMRI	2941	BID	1347	6
2026-07-15 20:03:37.320256+07	BMRI	2931	BID	1470	7
2026-07-15 20:03:37.320256+07	BMRI	2921	BID	1475	8
2026-07-15 20:03:37.320256+07	BMRI	2911	BID	1868	9
2026-07-15 20:03:37.320256+07	BMRI	2951	ASK	1120	5
2026-07-15 20:03:37.320256+07	BMRI	2961	ASK	1537	6
2026-07-15 20:03:37.320256+07	BMRI	2971	ASK	1466	7
2026-07-15 20:03:37.320256+07	BMRI	2981	ASK	1514	8
2026-07-15 20:03:37.320256+07	BMRI	2991	ASK	1482	9
2026-07-15 20:03:38.327642+07	BMRI	2951	BID	1380	5
2026-07-15 20:03:38.327642+07	BMRI	2941	BID	1270	6
2026-07-15 20:03:38.327642+07	BMRI	2931	BID	1254	7
2026-07-15 20:03:38.327642+07	BMRI	2921	BID	1753	8
2026-07-15 20:03:38.327642+07	BMRI	2911	BID	1645	9
2026-07-15 20:03:38.327642+07	BMRI	2951	ASK	1372	5
2026-07-15 20:03:38.327642+07	BMRI	2961	ASK	1314	6
2026-07-15 20:03:38.327642+07	BMRI	2971	ASK	1495	7
2026-07-15 20:03:38.327642+07	BMRI	2981	ASK	1710	8
2026-07-15 20:03:38.327642+07	BMRI	2991	ASK	1561	9
2026-07-15 20:03:39.335542+07	BMRI	2951	BID	1300	5
2026-07-15 20:03:39.335542+07	BMRI	2941	BID	1238	6
2026-07-15 20:03:39.335542+07	BMRI	2931	BID	1207	7
2026-07-15 20:03:39.335542+07	BMRI	2921	BID	1588	8
2026-07-15 20:03:39.335542+07	BMRI	2911	BID	1743	9
2026-07-15 20:03:39.335542+07	BMRI	2951	ASK	1308	5
2026-07-15 20:03:39.335542+07	BMRI	2961	ASK	1474	6
2026-07-15 20:03:39.335542+07	BMRI	2971	ASK	1401	7
2026-07-15 20:03:39.335542+07	BMRI	2981	ASK	1378	8
2026-07-15 20:03:39.335542+07	BMRI	2991	ASK	1522	9
2026-07-15 20:03:40.341989+07	BMRI	2951	BID	1008	5
2026-07-15 20:03:40.341989+07	BMRI	2941	BID	1341	6
2026-07-15 20:03:40.341989+07	BMRI	2931	BID	1487	7
2026-07-15 20:03:40.341989+07	BMRI	2921	BID	1581	8
2026-07-15 20:03:40.341989+07	BMRI	2911	BID	1635	9
2026-07-15 20:03:40.341989+07	BMRI	2951	ASK	1335	5
2026-07-15 20:03:40.341989+07	BMRI	2961	ASK	1142	6
2026-07-15 20:03:40.341989+07	BMRI	2971	ASK	1240	7
2026-07-15 20:03:40.341989+07	BMRI	2981	ASK	1718	8
2026-07-15 20:03:40.341989+07	BMRI	2991	ASK	1553	9
2026-07-15 20:03:41.353806+07	BMRI	2951	BID	1336	5
2026-07-15 20:03:41.353806+07	BMRI	2941	BID	1100	6
2026-07-15 20:03:41.353806+07	BMRI	2931	BID	1221	7
2026-07-15 20:03:41.353806+07	BMRI	2921	BID	1690	8
2026-07-15 20:03:41.353806+07	BMRI	2911	BID	1860	9
2026-07-15 20:03:41.353806+07	BMRI	2951	ASK	1018	5
2026-07-15 20:03:41.353806+07	BMRI	2961	ASK	1249	6
2026-07-15 20:03:41.353806+07	BMRI	2971	ASK	1209	7
2026-07-15 20:03:41.353806+07	BMRI	2981	ASK	1691	8
2026-07-15 20:03:41.353806+07	BMRI	2991	ASK	1760	9
2026-07-15 20:03:42.364926+07	BMRI	2951	BID	1248	5
2026-07-15 20:03:42.364926+07	BMRI	2941	BID	1348	6
2026-07-15 20:03:42.364926+07	BMRI	2931	BID	1582	7
2026-07-15 20:03:42.364926+07	BMRI	2921	BID	1695	8
2026-07-15 20:03:42.364926+07	BMRI	2911	BID	1894	9
2026-07-15 20:03:42.364926+07	BMRI	2951	ASK	1193	5
2026-07-15 20:03:42.364926+07	BMRI	2961	ASK	1529	6
2026-07-15 20:03:42.364926+07	BMRI	2971	ASK	1383	7
2026-07-15 20:03:42.364926+07	BMRI	2981	ASK	1709	8
2026-07-15 20:03:42.364926+07	BMRI	2991	ASK	1560	9
2026-07-15 20:03:43.369637+07	BMRI	2951	BID	1300	5
2026-07-15 20:03:43.369637+07	BMRI	2941	BID	1349	6
2026-07-15 20:03:43.369637+07	BMRI	2931	BID	1568	7
2026-07-15 20:03:43.369637+07	BMRI	2921	BID	1347	8
2026-07-15 20:03:43.369637+07	BMRI	2911	BID	1767	9
2026-07-15 20:03:43.369637+07	BMRI	2951	ASK	1259	5
2026-07-15 20:03:43.369637+07	BMRI	2961	ASK	1326	6
2026-07-15 20:03:43.369637+07	BMRI	2971	ASK	1672	7
2026-07-15 20:03:43.369637+07	BMRI	2981	ASK	1331	8
2026-07-15 20:03:43.369637+07	BMRI	2991	ASK	1713	9
2026-07-15 20:03:44.379257+07	BMRI	2951	BID	1015	5
2026-07-15 20:03:44.379257+07	BMRI	2941	BID	1172	6
2026-07-15 20:03:44.379257+07	BMRI	2931	BID	1503	7
2026-07-15 20:03:44.379257+07	BMRI	2921	BID	1385	8
2026-07-15 20:03:44.379257+07	BMRI	2911	BID	1860	9
2026-07-15 20:03:44.379257+07	BMRI	2951	ASK	1216	5
2026-07-15 20:03:44.379257+07	BMRI	2961	ASK	1295	6
2026-07-15 20:03:44.379257+07	BMRI	2971	ASK	1651	7
2026-07-15 20:03:44.379257+07	BMRI	2981	ASK	1607	8
2026-07-15 20:03:44.379257+07	BMRI	2991	ASK	1865	9
2026-07-15 20:03:45.387131+07	BMRI	2951	BID	1366	5
2026-07-15 20:03:45.387131+07	BMRI	2941	BID	1109	6
2026-07-15 20:03:45.387131+07	BMRI	2931	BID	1228	7
2026-07-15 20:03:45.387131+07	BMRI	2921	BID	1463	8
2026-07-15 20:03:45.387131+07	BMRI	2911	BID	1427	9
2026-07-15 20:03:45.387131+07	BMRI	2951	ASK	1008	5
2026-07-15 20:03:45.387131+07	BMRI	2961	ASK	1455	6
2026-07-15 20:03:45.387131+07	BMRI	2971	ASK	1602	7
2026-07-15 20:03:45.387131+07	BMRI	2981	ASK	1760	8
2026-07-15 20:03:45.387131+07	BMRI	2991	ASK	1491	9
2026-07-15 20:03:46.397022+07	BMRI	2951	BID	1483	5
2026-07-15 20:03:46.397022+07	BMRI	2941	BID	1419	6
2026-07-15 20:03:46.397022+07	BMRI	2931	BID	1561	7
2026-07-15 20:03:46.397022+07	BMRI	2921	BID	1703	8
2026-07-15 20:03:46.397022+07	BMRI	2911	BID	1860	9
2026-07-15 20:03:46.397022+07	BMRI	2951	ASK	1201	5
2026-07-15 20:03:46.397022+07	BMRI	2961	ASK	1120	6
2026-07-15 20:03:46.397022+07	BMRI	2971	ASK	1249	7
2026-07-15 20:03:46.397022+07	BMRI	2981	ASK	1734	8
2026-07-15 20:03:46.397022+07	BMRI	2991	ASK	1710	9
2026-07-15 20:03:47.403373+07	BMRI	2951	BID	1466	5
2026-07-15 20:03:47.403373+07	BMRI	2941	BID	1482	6
2026-07-15 20:03:47.403373+07	BMRI	2931	BID	1469	7
2026-07-15 20:03:47.403373+07	BMRI	2921	BID	1744	8
2026-07-15 20:03:47.403373+07	BMRI	2911	BID	1879	9
2026-07-15 20:03:47.403373+07	BMRI	2951	ASK	1363	5
2026-07-15 20:03:47.403373+07	BMRI	2961	ASK	1149	6
2026-07-15 20:03:47.403373+07	BMRI	2971	ASK	1545	7
2026-07-15 20:03:47.403373+07	BMRI	2981	ASK	1420	8
2026-07-15 20:03:47.403373+07	BMRI	2991	ASK	1571	9
2026-07-15 20:03:48.412368+07	BMRI	2951	BID	1209	5
2026-07-15 20:03:48.412368+07	BMRI	2941	BID	1442	6
2026-07-15 20:03:48.412368+07	BMRI	2931	BID	1614	7
2026-07-15 20:03:48.412368+07	BMRI	2921	BID	1441	8
2026-07-15 20:03:48.412368+07	BMRI	2911	BID	1777	9
2026-07-15 20:03:48.412368+07	BMRI	2951	ASK	1187	5
2026-07-15 20:03:48.412368+07	BMRI	2961	ASK	1357	6
2026-07-15 20:03:48.412368+07	BMRI	2971	ASK	1349	7
2026-07-15 20:03:48.412368+07	BMRI	2981	ASK	1442	8
2026-07-15 20:03:48.412368+07	BMRI	2991	ASK	1438	9
2026-07-15 20:03:49.417586+07	BMRI	2951	BID	1314	5
2026-07-15 20:03:49.417586+07	BMRI	2941	BID	1467	6
2026-07-15 20:03:49.417586+07	BMRI	2931	BID	1325	7
2026-07-15 20:03:49.417586+07	BMRI	2921	BID	1593	8
2026-07-15 20:03:49.417586+07	BMRI	2911	BID	1760	9
2026-07-15 20:03:49.417586+07	BMRI	2951	ASK	1131	5
2026-07-15 20:03:49.417586+07	BMRI	2961	ASK	1339	6
2026-07-15 20:03:49.417586+07	BMRI	2971	ASK	1370	7
2026-07-15 20:03:49.417586+07	BMRI	2981	ASK	1369	8
2026-07-15 20:03:49.417586+07	BMRI	2991	ASK	1648	9
2026-07-15 20:03:50.422373+07	BMRI	2951	BID	1320	5
2026-07-15 20:03:50.422373+07	BMRI	2941	BID	1292	6
2026-07-15 20:03:50.422373+07	BMRI	2931	BID	1668	7
2026-07-15 20:03:50.422373+07	BMRI	2921	BID	1602	8
2026-07-15 20:03:50.422373+07	BMRI	2911	BID	1704	9
2026-07-15 20:03:50.422373+07	BMRI	2951	ASK	1268	5
2026-07-15 20:03:50.422373+07	BMRI	2961	ASK	1195	6
2026-07-15 20:03:50.422373+07	BMRI	2971	ASK	1683	7
2026-07-15 20:03:50.422373+07	BMRI	2981	ASK	1434	8
2026-07-15 20:03:50.422373+07	BMRI	2991	ASK	1512	9
2026-07-15 20:03:51.433024+07	BMRI	2951	BID	1202	5
2026-07-15 20:03:51.433024+07	BMRI	2941	BID	1591	6
2026-07-15 20:03:51.433024+07	BMRI	2931	BID	1296	7
2026-07-15 20:03:51.433024+07	BMRI	2921	BID	1587	8
2026-07-15 20:03:51.433024+07	BMRI	2911	BID	1631	9
2026-07-15 20:03:51.433024+07	BMRI	2951	ASK	1275	5
2026-07-15 20:03:51.433024+07	BMRI	2961	ASK	1487	6
2026-07-15 20:03:51.433024+07	BMRI	2971	ASK	1595	7
2026-07-15 20:03:51.433024+07	BMRI	2981	ASK	1599	8
2026-07-15 20:03:51.433024+07	BMRI	2991	ASK	1483	9
2026-07-15 20:03:52.440689+07	BMRI	2951	BID	1113	5
2026-07-15 20:03:52.440689+07	BMRI	2941	BID	1166	6
2026-07-15 20:03:52.440689+07	BMRI	2931	BID	1529	7
2026-07-15 20:03:52.440689+07	BMRI	2921	BID	1736	8
2026-07-15 20:03:52.440689+07	BMRI	2911	BID	1710	9
2026-07-15 20:03:52.440689+07	BMRI	2951	ASK	1421	5
2026-07-15 20:03:52.440689+07	BMRI	2961	ASK	1278	6
2026-07-15 20:03:52.440689+07	BMRI	2971	ASK	1581	7
2026-07-15 20:03:52.440689+07	BMRI	2981	ASK	1584	8
2026-07-15 20:03:52.440689+07	BMRI	2991	ASK	1821	9
2026-07-15 20:03:53.450492+07	BMRI	2951	BID	1261	5
2026-07-15 20:03:53.450492+07	BMRI	2941	BID	1318	6
2026-07-15 20:03:53.450492+07	BMRI	2931	BID	1296	7
2026-07-15 20:03:53.450492+07	BMRI	2921	BID	1559	8
2026-07-15 20:03:53.450492+07	BMRI	2911	BID	1423	9
2026-07-15 20:03:53.450492+07	BMRI	2951	ASK	1271	5
2026-07-15 20:03:53.450492+07	BMRI	2961	ASK	1183	6
2026-07-15 20:03:53.450492+07	BMRI	2971	ASK	1314	7
2026-07-15 20:03:53.450492+07	BMRI	2981	ASK	1673	8
2026-07-15 20:03:53.450492+07	BMRI	2991	ASK	1597	9
2026-07-15 20:03:54.456555+07	BMRI	2951	BID	1196	5
2026-07-15 20:03:54.456555+07	BMRI	2941	BID	1320	6
2026-07-15 20:03:54.456555+07	BMRI	2931	BID	1368	7
2026-07-15 20:03:54.456555+07	BMRI	2921	BID	1388	8
2026-07-15 20:03:54.456555+07	BMRI	2911	BID	1548	9
2026-07-15 20:03:54.456555+07	BMRI	2951	ASK	1180	5
2026-07-15 20:03:54.456555+07	BMRI	2961	ASK	1443	6
2026-07-15 20:03:54.456555+07	BMRI	2971	ASK	1284	7
2026-07-15 20:03:54.456555+07	BMRI	2981	ASK	1591	8
2026-07-15 20:03:54.456555+07	BMRI	2991	ASK	1712	9
2026-07-15 20:03:55.467088+07	BMRI	2951	BID	1087	5
2026-07-15 20:03:55.467088+07	BMRI	2941	BID	1470	6
2026-07-15 20:03:55.467088+07	BMRI	2931	BID	1408	7
2026-07-15 20:03:55.467088+07	BMRI	2921	BID	1508	8
2026-07-15 20:03:55.467088+07	BMRI	2911	BID	1465	9
2026-07-15 20:03:55.467088+07	BMRI	2951	ASK	1230	5
2026-07-15 20:03:55.467088+07	BMRI	2961	ASK	1222	6
2026-07-15 20:03:55.467088+07	BMRI	2971	ASK	1317	7
2026-07-15 20:03:55.467088+07	BMRI	2981	ASK	1586	8
2026-07-15 20:03:55.467088+07	BMRI	2991	ASK	1481	9
2026-07-15 20:03:56.472456+07	BMRI	2951	BID	1450	5
2026-07-15 20:03:56.472456+07	BMRI	2941	BID	1218	6
2026-07-15 20:03:56.472456+07	BMRI	2931	BID	1440	7
2026-07-15 20:03:56.472456+07	BMRI	2921	BID	1629	8
2026-07-15 20:03:56.472456+07	BMRI	2911	BID	1743	9
2026-07-15 20:03:56.472456+07	BMRI	2951	ASK	1274	5
2026-07-15 20:03:56.472456+07	BMRI	2961	ASK	1212	6
2026-07-15 20:03:56.472456+07	BMRI	2971	ASK	1370	7
2026-07-15 20:03:56.472456+07	BMRI	2981	ASK	1745	8
2026-07-15 20:03:56.472456+07	BMRI	2991	ASK	1550	9
2026-07-15 20:03:57.483187+07	BMRI	2951	BID	1434	5
2026-07-15 20:03:57.483187+07	BMRI	2941	BID	1336	6
2026-07-15 20:03:57.483187+07	BMRI	2931	BID	1472	7
2026-07-15 20:03:57.483187+07	BMRI	2921	BID	1771	8
2026-07-15 20:03:57.483187+07	BMRI	2911	BID	1508	9
2026-07-15 20:03:57.483187+07	BMRI	2951	ASK	1067	5
2026-07-15 20:03:57.483187+07	BMRI	2961	ASK	1295	6
2026-07-15 20:03:57.483187+07	BMRI	2971	ASK	1524	7
2026-07-15 20:03:57.483187+07	BMRI	2981	ASK	1382	8
2026-07-15 20:03:57.483187+07	BMRI	2991	ASK	1664	9
2026-07-15 20:03:58.489569+07	BMRI	2951	BID	1492	5
2026-07-15 20:03:58.489569+07	BMRI	2941	BID	1538	6
2026-07-15 20:03:58.489569+07	BMRI	2931	BID	1681	7
2026-07-15 20:03:58.489569+07	BMRI	2921	BID	1325	8
2026-07-15 20:03:58.489569+07	BMRI	2911	BID	1484	9
2026-07-15 20:03:58.489569+07	BMRI	2951	ASK	1441	5
2026-07-15 20:03:58.489569+07	BMRI	2961	ASK	1256	6
2026-07-15 20:03:58.489569+07	BMRI	2971	ASK	1426	7
2026-07-15 20:03:58.489569+07	BMRI	2981	ASK	1743	8
2026-07-15 20:03:58.489569+07	BMRI	2991	ASK	1440	9
2026-07-15 20:03:59.499857+07	BMRI	2951	BID	1317	5
2026-07-15 20:03:59.499857+07	BMRI	2941	BID	1368	6
2026-07-15 20:03:59.499857+07	BMRI	2931	BID	1374	7
2026-07-15 20:03:59.499857+07	BMRI	2921	BID	1645	8
2026-07-15 20:03:59.499857+07	BMRI	2911	BID	1524	9
2026-07-15 20:03:59.499857+07	BMRI	2951	ASK	1242	5
2026-07-15 20:03:59.499857+07	BMRI	2961	ASK	1467	6
2026-07-15 20:03:59.499857+07	BMRI	2971	ASK	1320	7
2026-07-15 20:03:59.499857+07	BMRI	2981	ASK	1790	8
2026-07-15 20:03:59.499857+07	BMRI	2991	ASK	1461	9
2026-07-15 20:04:00.504359+07	BMRI	2951	BID	1365	5
2026-07-15 20:04:00.504359+07	BMRI	2941	BID	1500	6
2026-07-15 20:04:00.504359+07	BMRI	2931	BID	1547	7
2026-07-15 20:04:00.504359+07	BMRI	2921	BID	1498	8
2026-07-15 20:04:00.504359+07	BMRI	2911	BID	1718	9
2026-07-15 20:04:00.504359+07	BMRI	2951	ASK	1489	5
2026-07-15 20:04:00.504359+07	BMRI	2961	ASK	1572	6
2026-07-15 20:04:00.504359+07	BMRI	2971	ASK	1278	7
2026-07-15 20:04:00.504359+07	BMRI	2981	ASK	1467	8
2026-07-15 20:04:00.504359+07	BMRI	2991	ASK	1742	9
2026-07-15 20:04:01.511166+07	BMRI	2951	BID	1186	5
2026-07-15 20:04:01.511166+07	BMRI	2941	BID	1464	6
2026-07-15 20:04:01.511166+07	BMRI	2931	BID	1428	7
2026-07-15 20:04:01.511166+07	BMRI	2921	BID	1450	8
2026-07-15 20:04:01.511166+07	BMRI	2911	BID	1632	9
2026-07-15 20:04:01.511166+07	BMRI	2951	ASK	1158	5
2026-07-15 20:04:01.511166+07	BMRI	2961	ASK	1197	6
2026-07-15 20:04:01.511166+07	BMRI	2971	ASK	1381	7
2026-07-15 20:04:01.511166+07	BMRI	2981	ASK	1462	8
2026-07-15 20:04:01.511166+07	BMRI	2991	ASK	1537	9
2026-07-15 20:04:02.520753+07	BMRI	2951	BID	1245	5
2026-07-15 20:04:02.520753+07	BMRI	2941	BID	1481	6
2026-07-15 20:04:02.520753+07	BMRI	2931	BID	1405	7
2026-07-15 20:04:02.520753+07	BMRI	2921	BID	1522	8
2026-07-15 20:04:02.520753+07	BMRI	2911	BID	1514	9
2026-07-15 20:04:02.520753+07	BMRI	2951	ASK	1206	5
2026-07-15 20:04:02.520753+07	BMRI	2961	ASK	1552	6
2026-07-15 20:04:02.520753+07	BMRI	2971	ASK	1519	7
2026-07-15 20:04:02.520753+07	BMRI	2981	ASK	1677	8
2026-07-15 20:04:02.520753+07	BMRI	2991	ASK	1525	9
2026-07-15 20:04:03.528061+07	BMRI	2951	BID	1190	5
2026-07-15 20:04:03.528061+07	BMRI	2941	BID	1420	6
2026-07-15 20:04:03.528061+07	BMRI	2931	BID	1553	7
2026-07-15 20:04:03.528061+07	BMRI	2921	BID	1324	8
2026-07-15 20:04:03.528061+07	BMRI	2911	BID	1841	9
2026-07-15 20:04:03.528061+07	BMRI	2951	ASK	1259	5
2026-07-15 20:04:03.528061+07	BMRI	2961	ASK	1561	6
2026-07-15 20:04:03.528061+07	BMRI	2971	ASK	1650	7
2026-07-15 20:04:03.528061+07	BMRI	2981	ASK	1696	8
2026-07-15 20:04:03.528061+07	BMRI	2991	ASK	1570	9
2026-07-15 20:04:04.537396+07	BMRI	2951	BID	1417	5
2026-07-15 20:04:04.537396+07	BMRI	2941	BID	1338	6
2026-07-15 20:04:04.537396+07	BMRI	2931	BID	1333	7
2026-07-15 20:04:04.537396+07	BMRI	2921	BID	1370	8
2026-07-15 20:04:04.537396+07	BMRI	2911	BID	1417	9
2026-07-15 20:04:04.537396+07	BMRI	2951	ASK	1420	5
2026-07-15 20:04:04.537396+07	BMRI	2961	ASK	1590	6
2026-07-15 20:04:04.537396+07	BMRI	2971	ASK	1587	7
2026-07-15 20:04:04.537396+07	BMRI	2981	ASK	1466	8
2026-07-15 20:04:04.537396+07	BMRI	2991	ASK	1550	9
2026-07-15 20:04:05.546493+07	BMRI	2951	BID	1462	5
2026-07-15 20:04:05.546493+07	BMRI	2941	BID	1350	6
2026-07-15 20:04:05.546493+07	BMRI	2931	BID	1597	7
2026-07-15 20:04:05.546493+07	BMRI	2921	BID	1562	8
2026-07-15 20:04:05.546493+07	BMRI	2911	BID	1593	9
2026-07-15 20:04:05.546493+07	BMRI	2951	ASK	1217	5
2026-07-15 20:04:05.546493+07	BMRI	2961	ASK	1340	6
2026-07-15 20:04:05.546493+07	BMRI	2971	ASK	1669	7
2026-07-15 20:04:05.546493+07	BMRI	2981	ASK	1551	8
2026-07-15 20:04:05.546493+07	BMRI	2991	ASK	1655	9
2026-07-15 20:04:06.55369+07	BMRI	2951	BID	1007	5
2026-07-15 20:04:06.55369+07	BMRI	2941	BID	1562	6
2026-07-15 20:04:06.55369+07	BMRI	2931	BID	1591	7
2026-07-15 20:04:06.55369+07	BMRI	2921	BID	1313	8
2026-07-15 20:04:06.55369+07	BMRI	2911	BID	1469	9
2026-07-15 20:04:06.55369+07	BMRI	2951	ASK	1045	5
2026-07-15 20:04:06.55369+07	BMRI	2961	ASK	1268	6
2026-07-15 20:04:06.55369+07	BMRI	2971	ASK	1396	7
2026-07-15 20:04:06.55369+07	BMRI	2981	ASK	1574	8
2026-07-15 20:04:06.55369+07	BMRI	2991	ASK	1860	9
2026-07-15 20:04:07.563018+07	BMRI	2951	BID	1176	5
2026-07-15 20:04:07.563018+07	BMRI	2941	BID	1243	6
2026-07-15 20:04:07.563018+07	BMRI	2931	BID	1588	7
2026-07-15 20:04:07.563018+07	BMRI	2921	BID	1306	8
2026-07-15 20:04:07.563018+07	BMRI	2911	BID	1425	9
2026-07-15 20:04:07.563018+07	BMRI	2951	ASK	1241	5
2026-07-15 20:04:07.563018+07	BMRI	2961	ASK	1339	6
2026-07-15 20:04:07.563018+07	BMRI	2971	ASK	1541	7
2026-07-15 20:04:07.563018+07	BMRI	2981	ASK	1519	8
2026-07-15 20:04:07.563018+07	BMRI	2991	ASK	1803	9
2026-07-15 20:04:08.569908+07	BMRI	2951	BID	1127	5
2026-07-15 20:04:08.569908+07	BMRI	2941	BID	1540	6
2026-07-15 20:04:08.569908+07	BMRI	2931	BID	1657	7
2026-07-15 20:04:08.569908+07	BMRI	2921	BID	1375	8
2026-07-15 20:04:08.569908+07	BMRI	2911	BID	1724	9
2026-07-15 20:04:08.569908+07	BMRI	2951	ASK	1230	5
2026-07-15 20:04:08.569908+07	BMRI	2961	ASK	1505	6
2026-07-15 20:04:08.569908+07	BMRI	2971	ASK	1681	7
2026-07-15 20:04:08.569908+07	BMRI	2981	ASK	1642	8
2026-07-15 20:04:08.569908+07	BMRI	2991	ASK	1463	9
2026-07-15 20:04:09.578988+07	BMRI	2951	BID	50427	5
2026-07-15 20:04:09.578988+07	BMRI	2941	BID	1328	6
2026-07-15 20:04:09.578988+07	BMRI	2931	BID	1264	7
2026-07-15 20:04:09.578988+07	BMRI	2921	BID	1518	8
2026-07-15 20:04:09.578988+07	BMRI	2911	BID	1404	9
2026-07-15 20:04:09.578988+07	BMRI	2951	ASK	1112	5
2026-07-15 20:04:09.578988+07	BMRI	2961	ASK	1514	6
2026-07-15 20:04:09.578988+07	BMRI	2971	ASK	1654	7
2026-07-15 20:04:09.578988+07	BMRI	2981	ASK	1768	8
2026-07-15 20:04:09.578988+07	BMRI	2991	ASK	1645	9
2026-07-15 20:04:10.588025+07	BMRI	2951	BID	58959	5
2026-07-15 20:04:10.588025+07	BMRI	2941	BID	1436	6
2026-07-15 20:04:10.588025+07	BMRI	2931	BID	1552	7
2026-07-15 20:04:10.588025+07	BMRI	2921	BID	1352	8
2026-07-15 20:04:10.588025+07	BMRI	2911	BID	1442	9
2026-07-15 20:04:10.588025+07	BMRI	2951	ASK	1306	5
2026-07-15 20:04:10.588025+07	BMRI	2961	ASK	1423	6
2026-07-15 20:04:10.588025+07	BMRI	2971	ASK	1217	7
2026-07-15 20:04:10.588025+07	BMRI	2981	ASK	1423	8
2026-07-15 20:04:10.588025+07	BMRI	2991	ASK	1449	9
2026-07-15 20:04:11.59983+07	BMRI	2951	BID	58524	5
2026-07-15 20:04:11.59983+07	BMRI	2941	BID	1507	6
2026-07-15 20:04:11.59983+07	BMRI	2931	BID	1253	7
2026-07-15 20:04:11.59983+07	BMRI	2921	BID	1708	8
2026-07-15 20:04:11.59983+07	BMRI	2911	BID	1419	9
2026-07-15 20:04:11.59983+07	BMRI	2951	ASK	1426	5
2026-07-15 20:04:11.59983+07	BMRI	2961	ASK	1457	6
2026-07-15 20:04:11.59983+07	BMRI	2971	ASK	1482	7
2026-07-15 20:04:11.59983+07	BMRI	2981	ASK	1436	8
2026-07-15 20:04:11.59983+07	BMRI	2991	ASK	1526	9
2026-07-15 20:04:12.606063+07	BMRI	2951	BID	56685	5
2026-07-15 20:04:12.606063+07	BMRI	2941	BID	1146	6
2026-07-15 20:04:12.606063+07	BMRI	2931	BID	1218	7
2026-07-15 20:04:12.606063+07	BMRI	2921	BID	1396	8
2026-07-15 20:04:12.606063+07	BMRI	2911	BID	1610	9
2026-07-15 20:04:12.606063+07	BMRI	2951	ASK	1013	5
2026-07-15 20:04:12.606063+07	BMRI	2961	ASK	1347	6
2026-07-15 20:04:12.606063+07	BMRI	2971	ASK	1408	7
2026-07-15 20:04:12.606063+07	BMRI	2981	ASK	1306	8
2026-07-15 20:04:12.606063+07	BMRI	2991	ASK	1845	9
2026-07-15 20:04:13.618271+07	BMRI	2951	BID	54943	5
2026-07-15 20:04:13.618271+07	BMRI	2941	BID	1499	6
2026-07-15 20:04:13.618271+07	BMRI	2931	BID	1530	7
2026-07-15 20:04:13.618271+07	BMRI	2921	BID	1384	8
2026-07-15 20:04:13.618271+07	BMRI	2911	BID	1639	9
2026-07-15 20:04:13.618271+07	BMRI	2951	ASK	1164	5
2026-07-15 20:04:13.618271+07	BMRI	2961	ASK	1176	6
2026-07-15 20:04:13.618271+07	BMRI	2971	ASK	1483	7
2026-07-15 20:04:13.618271+07	BMRI	2981	ASK	1655	8
2026-07-15 20:04:13.618271+07	BMRI	2991	ASK	1808	9
2026-07-15 20:04:14.623858+07	BMRI	2951	BID	50862	5
2026-07-15 20:04:14.623858+07	BMRI	2941	BID	1285	6
2026-07-15 20:04:14.623858+07	BMRI	2931	BID	1208	7
2026-07-15 20:04:14.623858+07	BMRI	2921	BID	1434	8
2026-07-15 20:04:14.623858+07	BMRI	2911	BID	1436	9
2026-07-15 20:04:14.623858+07	BMRI	2951	ASK	1309	5
2026-07-15 20:04:14.623858+07	BMRI	2961	ASK	1425	6
2026-07-15 20:04:14.623858+07	BMRI	2971	ASK	1340	7
2026-07-15 20:04:14.623858+07	BMRI	2981	ASK	1676	8
2026-07-15 20:04:14.623858+07	BMRI	2991	ASK	1713	9
2026-07-15 20:04:15.635382+07	BMRI	2951	BID	50435	5
2026-07-15 20:04:15.635382+07	BMRI	2941	BID	1509	6
2026-07-15 20:04:15.635382+07	BMRI	2931	BID	1507	7
2026-07-15 20:04:15.635382+07	BMRI	2921	BID	1311	8
2026-07-15 20:04:15.635382+07	BMRI	2911	BID	1401	9
2026-07-15 20:04:15.635382+07	BMRI	2951	ASK	1240	5
2026-07-15 20:04:15.635382+07	BMRI	2961	ASK	1354	6
2026-07-15 20:04:15.635382+07	BMRI	2971	ASK	1666	7
2026-07-15 20:04:15.635382+07	BMRI	2981	ASK	1632	8
2026-07-15 20:04:15.635382+07	BMRI	2991	ASK	1430	9
2026-07-15 20:04:16.643144+07	BMRI	2951	BID	56518	5
2026-07-15 20:04:16.643144+07	BMRI	2941	BID	1467	6
2026-07-15 20:04:16.643144+07	BMRI	2931	BID	1359	7
2026-07-15 20:04:16.643144+07	BMRI	2921	BID	1669	8
2026-07-15 20:04:16.643144+07	BMRI	2911	BID	1492	9
2026-07-15 20:04:16.643144+07	BMRI	2951	ASK	1217	5
2026-07-15 20:04:16.643144+07	BMRI	2961	ASK	1271	6
2026-07-15 20:04:16.643144+07	BMRI	2971	ASK	1249	7
2026-07-15 20:04:16.643144+07	BMRI	2981	ASK	1716	8
2026-07-15 20:04:16.643144+07	BMRI	2991	ASK	1435	9
2026-07-15 20:04:17.652801+07	BMRI	2951	BID	58038	5
2026-07-15 20:04:17.652801+07	BMRI	2941	BID	1399	6
2026-07-15 20:04:17.652801+07	BMRI	2931	BID	1515	7
2026-07-15 20:04:17.652801+07	BMRI	2921	BID	1754	8
2026-07-15 20:04:17.652801+07	BMRI	2911	BID	1815	9
2026-07-15 20:04:17.652801+07	BMRI	2951	ASK	1080	5
2026-07-15 20:04:17.652801+07	BMRI	2961	ASK	1247	6
2026-07-15 20:04:17.652801+07	BMRI	2971	ASK	1399	7
2026-07-15 20:04:17.652801+07	BMRI	2981	ASK	1575	8
2026-07-15 20:04:17.652801+07	BMRI	2991	ASK	1789	9
2026-07-15 20:04:18.658488+07	BMRI	2951	BID	56198	5
2026-07-15 20:04:18.658488+07	BMRI	2941	BID	1590	6
2026-07-15 20:04:18.658488+07	BMRI	2931	BID	1682	7
2026-07-15 20:04:18.658488+07	BMRI	2921	BID	1551	8
2026-07-15 20:04:18.658488+07	BMRI	2911	BID	1850	9
2026-07-15 20:04:18.658488+07	BMRI	2951	ASK	1417	5
2026-07-15 20:04:18.658488+07	BMRI	2961	ASK	1516	6
2026-07-15 20:04:18.658488+07	BMRI	2971	ASK	1257	7
2026-07-15 20:04:18.658488+07	BMRI	2981	ASK	1636	8
2026-07-15 20:04:18.658488+07	BMRI	2991	ASK	1654	9
2026-07-15 20:04:19.668234+07	BMRI	2951	BID	59954	5
2026-07-15 20:04:19.668234+07	BMRI	2941	BID	1114	6
2026-07-15 20:04:19.668234+07	BMRI	2931	BID	1324	7
2026-07-15 20:04:19.668234+07	BMRI	2921	BID	1457	8
2026-07-15 20:04:19.668234+07	BMRI	2911	BID	1671	9
2026-07-15 20:04:19.668234+07	BMRI	2951	ASK	1184	5
2026-07-15 20:04:19.668234+07	BMRI	2961	ASK	1264	6
2026-07-15 20:04:19.668234+07	BMRI	2971	ASK	1592	7
2026-07-15 20:04:19.668234+07	BMRI	2981	ASK	1362	8
2026-07-15 20:04:19.668234+07	BMRI	2991	ASK	1550	9
2026-07-15 20:04:20.672439+07	BMRI	2951	BID	56268	5
2026-07-15 20:04:20.672439+07	BMRI	2941	BID	1583	6
2026-07-15 20:04:20.672439+07	BMRI	2931	BID	1396	7
2026-07-15 20:04:20.672439+07	BMRI	2921	BID	1408	8
2026-07-15 20:04:20.672439+07	BMRI	2911	BID	1872	9
2026-07-15 20:04:20.672439+07	BMRI	2951	ASK	1308	5
2026-07-15 20:04:20.672439+07	BMRI	2961	ASK	1156	6
2026-07-15 20:04:20.672439+07	BMRI	2971	ASK	1339	7
2026-07-15 20:04:20.672439+07	BMRI	2981	ASK	1795	8
2026-07-15 20:04:20.672439+07	BMRI	2991	ASK	1548	9
2026-07-15 20:04:21.683213+07	BMRI	2951	BID	54277	5
2026-07-15 20:04:21.683213+07	BMRI	2941	BID	1352	6
2026-07-15 20:04:21.683213+07	BMRI	2931	BID	1544	7
2026-07-15 20:04:21.683213+07	BMRI	2921	BID	1605	8
2026-07-15 20:04:21.683213+07	BMRI	2911	BID	1814	9
2026-07-15 20:04:21.683213+07	BMRI	2951	ASK	1143	5
2026-07-15 20:04:21.683213+07	BMRI	2961	ASK	1353	6
2026-07-15 20:04:21.683213+07	BMRI	2971	ASK	1548	7
2026-07-15 20:04:21.683213+07	BMRI	2981	ASK	1652	8
2026-07-15 20:04:21.683213+07	BMRI	2991	ASK	1696	9
2026-07-15 20:04:22.687799+07	BMRI	2951	BID	56765	5
2026-07-15 20:04:22.687799+07	BMRI	2941	BID	1264	6
2026-07-15 20:04:22.687799+07	BMRI	2931	BID	1353	7
2026-07-15 20:04:22.687799+07	BMRI	2921	BID	1684	8
2026-07-15 20:04:22.687799+07	BMRI	2911	BID	1815	9
2026-07-15 20:04:22.687799+07	BMRI	2951	ASK	1354	5
2026-07-15 20:04:22.687799+07	BMRI	2961	ASK	1188	6
2026-07-15 20:04:22.687799+07	BMRI	2971	ASK	1359	7
2026-07-15 20:04:22.687799+07	BMRI	2981	ASK	1338	8
2026-07-15 20:04:22.687799+07	BMRI	2991	ASK	1460	9
2026-07-15 20:04:23.69506+07	BMRI	2951	BID	55981	5
2026-07-15 20:04:23.69506+07	BMRI	2941	BID	1222	6
2026-07-15 20:04:23.69506+07	BMRI	2931	BID	1266	7
2026-07-15 20:04:23.69506+07	BMRI	2921	BID	1414	8
2026-07-15 20:04:23.69506+07	BMRI	2911	BID	1861	9
2026-07-15 20:04:23.69506+07	BMRI	2951	ASK	1243	5
2026-07-15 20:04:23.69506+07	BMRI	2961	ASK	1442	6
2026-07-15 20:04:23.69506+07	BMRI	2971	ASK	1358	7
2026-07-15 20:04:23.69506+07	BMRI	2981	ASK	1453	8
2026-07-15 20:04:23.69506+07	BMRI	2991	ASK	1404	9
2026-07-15 20:04:24.701754+07	BMRI	2951	BID	58860	5
2026-07-15 20:04:24.701754+07	BMRI	2941	BID	1450	6
2026-07-15 20:04:24.701754+07	BMRI	2931	BID	1443	7
2026-07-15 20:04:24.701754+07	BMRI	2921	BID	1508	8
2026-07-15 20:04:24.701754+07	BMRI	2911	BID	1897	9
2026-07-15 20:04:24.701754+07	BMRI	2951	ASK	1252	5
2026-07-15 20:04:24.701754+07	BMRI	2961	ASK	1542	6
2026-07-15 20:04:24.701754+07	BMRI	2971	ASK	1280	7
2026-07-15 20:04:24.701754+07	BMRI	2981	ASK	1616	8
2026-07-15 20:04:24.701754+07	BMRI	2991	ASK	1494	9
2026-07-15 20:04:25.704949+07	BMRI	2951	BID	57682	5
2026-07-15 20:04:25.704949+07	BMRI	2941	BID	1317	6
2026-07-15 20:04:25.704949+07	BMRI	2931	BID	1486	7
2026-07-15 20:04:25.704949+07	BMRI	2921	BID	1448	8
2026-07-15 20:04:25.704949+07	BMRI	2911	BID	1661	9
2026-07-15 20:04:25.704949+07	BMRI	2951	ASK	1158	5
2026-07-15 20:04:25.704949+07	BMRI	2961	ASK	1169	6
2026-07-15 20:04:25.704949+07	BMRI	2971	ASK	1474	7
2026-07-15 20:04:25.704949+07	BMRI	2981	ASK	1407	8
2026-07-15 20:04:25.704949+07	BMRI	2991	ASK	1426	9
2026-07-15 20:04:26.712932+07	BMRI	2951	BID	58074	5
2026-07-15 20:04:26.712932+07	BMRI	2941	BID	1370	6
2026-07-15 20:04:26.712932+07	BMRI	2931	BID	1490	7
2026-07-15 20:04:26.712932+07	BMRI	2921	BID	1491	8
2026-07-15 20:04:26.712932+07	BMRI	2911	BID	1690	9
2026-07-15 20:04:26.712932+07	BMRI	2951	ASK	1225	5
2026-07-15 20:04:26.712932+07	BMRI	2961	ASK	1218	6
2026-07-15 20:04:26.712932+07	BMRI	2971	ASK	1651	7
2026-07-15 20:04:26.712932+07	BMRI	2981	ASK	1380	8
2026-07-15 20:04:26.712932+07	BMRI	2991	ASK	1676	9
2026-07-15 20:04:27.719564+07	BMRI	2951	BID	57093	5
2026-07-15 20:04:27.719564+07	BMRI	2941	BID	1517	6
2026-07-15 20:04:27.719564+07	BMRI	2931	BID	1505	7
2026-07-15 20:04:27.719564+07	BMRI	2921	BID	1593	8
2026-07-15 20:04:27.719564+07	BMRI	2911	BID	1420	9
2026-07-15 20:04:27.719564+07	BMRI	2951	ASK	1052	5
2026-07-15 20:04:27.719564+07	BMRI	2961	ASK	1394	6
2026-07-15 20:04:27.719564+07	BMRI	2971	ASK	1389	7
2026-07-15 20:04:27.719564+07	BMRI	2981	ASK	1604	8
2026-07-15 20:04:27.719564+07	BMRI	2991	ASK	1885	9
2026-07-15 20:04:28.724487+07	BMRI	2951	BID	56668	5
2026-07-15 20:04:28.724487+07	BMRI	2941	BID	1218	6
2026-07-15 20:04:28.724487+07	BMRI	2931	BID	1637	7
2026-07-15 20:04:28.724487+07	BMRI	2921	BID	1690	8
2026-07-15 20:04:28.724487+07	BMRI	2911	BID	1833	9
2026-07-15 20:04:28.724487+07	BMRI	2951	ASK	1127	5
2026-07-15 20:04:28.724487+07	BMRI	2961	ASK	1327	6
2026-07-15 20:04:28.724487+07	BMRI	2971	ASK	1408	7
2026-07-15 20:04:28.724487+07	BMRI	2981	ASK	1700	8
2026-07-15 20:04:28.724487+07	BMRI	2991	ASK	1747	9
2026-07-15 20:04:29.735563+07	BMRI	2951	BID	56956	5
2026-07-15 20:04:29.735563+07	BMRI	2941	BID	1348	6
2026-07-15 20:04:29.735563+07	BMRI	2931	BID	1695	7
2026-07-15 20:04:29.735563+07	BMRI	2921	BID	1371	8
2026-07-15 20:04:29.735563+07	BMRI	2911	BID	1716	9
2026-07-15 20:04:29.735563+07	BMRI	2951	ASK	1070	5
2026-07-15 20:04:29.735563+07	BMRI	2961	ASK	1141	6
2026-07-15 20:04:29.735563+07	BMRI	2971	ASK	1284	7
2026-07-15 20:04:29.735563+07	BMRI	2981	ASK	1778	8
2026-07-15 20:04:29.735563+07	BMRI	2991	ASK	1756	9
2026-07-15 20:04:30.741258+07	BMRI	2951	BID	56012	5
2026-07-15 20:04:30.741258+07	BMRI	2941	BID	1536	6
2026-07-15 20:04:30.741258+07	BMRI	2931	BID	1400	7
2026-07-15 20:04:30.741258+07	BMRI	2921	BID	1458	8
2026-07-15 20:04:30.741258+07	BMRI	2911	BID	1799	9
2026-07-15 20:04:30.741258+07	BMRI	2951	ASK	1293	5
2026-07-15 20:04:30.741258+07	BMRI	2961	ASK	1193	6
2026-07-15 20:04:30.741258+07	BMRI	2971	ASK	1277	7
2026-07-15 20:04:30.741258+07	BMRI	2981	ASK	1381	8
2026-07-15 20:04:30.741258+07	BMRI	2991	ASK	1619	9
2026-07-15 20:04:31.75191+07	BMRI	2951	BID	52950	5
2026-07-15 20:04:31.75191+07	BMRI	2941	BID	1361	6
2026-07-15 20:04:31.75191+07	BMRI	2931	BID	1626	7
2026-07-15 20:04:31.75191+07	BMRI	2921	BID	1627	8
2026-07-15 20:04:31.75191+07	BMRI	2911	BID	1518	9
2026-07-15 20:04:31.75191+07	BMRI	2951	ASK	1067	5
2026-07-15 20:04:31.75191+07	BMRI	2961	ASK	1332	6
2026-07-15 20:04:31.75191+07	BMRI	2971	ASK	1267	7
2026-07-15 20:04:31.75191+07	BMRI	2981	ASK	1612	8
2026-07-15 20:04:31.75191+07	BMRI	2991	ASK	1458	9
2026-07-15 20:04:32.757354+07	BMRI	2951	BID	52866	5
2026-07-15 20:04:32.757354+07	BMRI	2941	BID	1591	6
2026-07-15 20:04:32.757354+07	BMRI	2931	BID	1428	7
2026-07-15 20:04:32.757354+07	BMRI	2921	BID	1421	8
2026-07-15 20:04:32.757354+07	BMRI	2911	BID	1683	9
2026-07-15 20:04:32.757354+07	BMRI	2951	ASK	1398	5
2026-07-15 20:04:32.757354+07	BMRI	2961	ASK	1133	6
2026-07-15 20:04:32.757354+07	BMRI	2971	ASK	1343	7
2026-07-15 20:04:32.757354+07	BMRI	2981	ASK	1323	8
2026-07-15 20:04:32.757354+07	BMRI	2991	ASK	1478	9
2026-07-15 20:04:33.768268+07	BMRI	2951	BID	58629	5
2026-07-15 20:04:33.768268+07	BMRI	2941	BID	1246	6
2026-07-15 20:04:33.768268+07	BMRI	2931	BID	1605	7
2026-07-15 20:04:33.768268+07	BMRI	2921	BID	1771	8
2026-07-15 20:04:33.768268+07	BMRI	2911	BID	1423	9
2026-07-15 20:04:33.768268+07	BMRI	2951	ASK	1467	5
2026-07-15 20:04:33.768268+07	BMRI	2961	ASK	1352	6
2026-07-15 20:04:33.768268+07	BMRI	2971	ASK	1503	7
2026-07-15 20:04:33.768268+07	BMRI	2981	ASK	1689	8
2026-07-15 20:04:33.768268+07	BMRI	2991	ASK	1487	9
2026-07-15 20:04:34.773727+07	BMRI	2951	BID	51049	5
2026-07-15 20:04:34.773727+07	BMRI	2941	BID	1412	6
2026-07-15 20:04:34.773727+07	BMRI	2931	BID	1621	7
2026-07-15 20:04:34.773727+07	BMRI	2921	BID	1415	8
2026-07-15 20:04:34.773727+07	BMRI	2911	BID	1600	9
2026-07-15 20:04:34.773727+07	BMRI	2951	ASK	1281	5
2026-07-15 20:04:34.773727+07	BMRI	2961	ASK	1469	6
2026-07-15 20:04:34.773727+07	BMRI	2971	ASK	1267	7
2026-07-15 20:04:34.773727+07	BMRI	2981	ASK	1352	8
2026-07-15 20:04:34.773727+07	BMRI	2991	ASK	1643	9
2026-07-15 20:04:35.784903+07	BMRI	2951	BID	50336	5
2026-07-15 20:04:35.784903+07	BMRI	2941	BID	1145	6
2026-07-15 20:04:35.784903+07	BMRI	2931	BID	1364	7
2026-07-15 20:04:35.784903+07	BMRI	2921	BID	1569	8
2026-07-15 20:04:35.784903+07	BMRI	2911	BID	1582	9
2026-07-15 20:04:35.784903+07	BMRI	2951	ASK	1217	5
2026-07-15 20:04:35.784903+07	BMRI	2961	ASK	1461	6
2026-07-15 20:04:35.784903+07	BMRI	2971	ASK	1465	7
2026-07-15 20:04:35.784903+07	BMRI	2981	ASK	1521	8
2026-07-15 20:04:35.784903+07	BMRI	2991	ASK	1506	9
2026-07-15 20:04:36.790319+07	BMRI	2951	BID	54794	5
2026-07-15 20:04:36.790319+07	BMRI	2941	BID	1110	6
2026-07-15 20:04:36.790319+07	BMRI	2931	BID	1335	7
2026-07-15 20:04:36.790319+07	BMRI	2921	BID	1733	8
2026-07-15 20:04:36.790319+07	BMRI	2911	BID	1760	9
2026-07-15 20:04:36.790319+07	BMRI	2951	ASK	1244	5
2026-07-15 20:04:36.790319+07	BMRI	2961	ASK	1218	6
2026-07-15 20:04:36.790319+07	BMRI	2971	ASK	1654	7
2026-07-15 20:04:36.790319+07	BMRI	2981	ASK	1754	8
2026-07-15 20:04:36.790319+07	BMRI	2991	ASK	1687	9
2026-07-15 20:04:37.800006+07	BMRI	2951	BID	50649	5
2026-07-15 20:04:37.800006+07	BMRI	2941	BID	1448	6
2026-07-15 20:04:37.800006+07	BMRI	2931	BID	1214	7
2026-07-15 20:04:37.800006+07	BMRI	2921	BID	1695	8
2026-07-15 20:04:37.800006+07	BMRI	2911	BID	1664	9
2026-07-15 20:04:37.800006+07	BMRI	2951	ASK	1045	5
2026-07-15 20:04:37.800006+07	BMRI	2961	ASK	1441	6
2026-07-15 20:04:37.800006+07	BMRI	2971	ASK	1594	7
2026-07-15 20:04:37.800006+07	BMRI	2981	ASK	1311	8
2026-07-15 20:04:37.800006+07	BMRI	2991	ASK	1469	9
2026-07-15 20:04:38.807578+07	BMRI	2951	BID	59614	5
2026-07-15 20:04:38.807578+07	BMRI	2941	BID	1464	6
2026-07-15 20:04:38.807578+07	BMRI	2931	BID	1656	7
2026-07-15 20:04:38.807578+07	BMRI	2921	BID	1333	8
2026-07-15 20:04:38.807578+07	BMRI	2911	BID	1783	9
2026-07-15 20:04:38.807578+07	BMRI	2951	ASK	1294	5
2026-07-15 20:04:38.807578+07	BMRI	2961	ASK	1181	6
2026-07-15 20:04:38.807578+07	BMRI	2971	ASK	1660	7
2026-07-15 20:04:38.807578+07	BMRI	2981	ASK	1661	8
2026-07-15 20:04:38.807578+07	BMRI	2991	ASK	1551	9
2026-07-15 20:04:39.818369+07	BMRI	2951	BID	50196	5
2026-07-15 20:04:39.818369+07	BMRI	2941	BID	1433	6
2026-07-15 20:04:39.818369+07	BMRI	2931	BID	1228	7
2026-07-15 20:04:39.818369+07	BMRI	2921	BID	1677	8
2026-07-15 20:04:39.818369+07	BMRI	2911	BID	1857	9
2026-07-15 20:04:39.818369+07	BMRI	2951	ASK	1124	5
2026-07-15 20:04:39.818369+07	BMRI	2961	ASK	1434	6
2026-07-15 20:04:39.818369+07	BMRI	2971	ASK	1369	7
2026-07-15 20:04:39.818369+07	BMRI	2981	ASK	1381	8
2026-07-15 20:04:39.818369+07	BMRI	2991	ASK	1784	9
2026-07-15 20:04:40.82742+07	BMRI	2951	BID	50797	5
2026-07-15 20:04:40.82742+07	BMRI	2941	BID	1266	6
2026-07-15 20:04:40.82742+07	BMRI	2931	BID	1210	7
2026-07-15 20:04:40.82742+07	BMRI	2921	BID	1488	8
2026-07-15 20:04:40.82742+07	BMRI	2911	BID	1417	9
2026-07-15 20:04:40.82742+07	BMRI	2951	ASK	1474	5
2026-07-15 20:04:40.82742+07	BMRI	2961	ASK	1419	6
2026-07-15 20:04:40.82742+07	BMRI	2971	ASK	1347	7
2026-07-15 20:04:40.82742+07	BMRI	2981	ASK	1352	8
2026-07-15 20:04:40.82742+07	BMRI	2991	ASK	1442	9
2026-07-15 20:04:41.836117+07	BMRI	2951	BID	54459	5
2026-07-15 20:04:41.836117+07	BMRI	2941	BID	1351	6
2026-07-15 20:04:41.836117+07	BMRI	2931	BID	1341	7
2026-07-15 20:04:41.836117+07	BMRI	2921	BID	1712	8
2026-07-15 20:04:41.836117+07	BMRI	2911	BID	1637	9
2026-07-15 20:04:41.836117+07	BMRI	2951	ASK	1339	5
2026-07-15 20:04:41.836117+07	BMRI	2961	ASK	1459	6
2026-07-15 20:04:41.836117+07	BMRI	2971	ASK	1548	7
2026-07-15 20:04:41.836117+07	BMRI	2981	ASK	1615	8
2026-07-15 20:04:41.836117+07	BMRI	2991	ASK	1582	9
2026-07-15 20:04:42.843073+07	BMRI	2951	BID	52326	5
2026-07-15 20:04:42.843073+07	BMRI	2941	BID	1126	6
2026-07-15 20:04:42.843073+07	BMRI	2931	BID	1553	7
2026-07-15 20:04:42.843073+07	BMRI	2921	BID	1644	8
2026-07-15 20:04:42.843073+07	BMRI	2911	BID	1462	9
2026-07-15 20:04:42.843073+07	BMRI	2951	ASK	1273	5
2026-07-15 20:04:42.843073+07	BMRI	2961	ASK	1255	6
2026-07-15 20:04:42.843073+07	BMRI	2971	ASK	1258	7
2026-07-15 20:04:42.843073+07	BMRI	2981	ASK	1774	8
2026-07-15 20:04:42.843073+07	BMRI	2991	ASK	1853	9
2026-07-15 20:04:43.852926+07	BMRI	2951	BID	57737	5
2026-07-15 20:04:43.852926+07	BMRI	2941	BID	1109	6
2026-07-15 20:04:43.852926+07	BMRI	2931	BID	1526	7
2026-07-15 20:04:43.852926+07	BMRI	2921	BID	1565	8
2026-07-15 20:04:43.852926+07	BMRI	2911	BID	1785	9
2026-07-15 20:04:43.852926+07	BMRI	2951	ASK	1113	5
2026-07-15 20:04:43.852926+07	BMRI	2961	ASK	1233	6
2026-07-15 20:04:43.852926+07	BMRI	2971	ASK	1579	7
2026-07-15 20:04:43.852926+07	BMRI	2981	ASK	1627	8
2026-07-15 20:04:43.852926+07	BMRI	2991	ASK	1787	9
2026-07-15 20:04:44.857851+07	BMRI	2951	BID	58753	5
2026-07-15 20:04:44.857851+07	BMRI	2941	BID	1451	6
2026-07-15 20:04:44.857851+07	BMRI	2931	BID	1429	7
2026-07-15 20:04:44.857851+07	BMRI	2921	BID	1325	8
2026-07-15 20:04:44.857851+07	BMRI	2911	BID	1600	9
2026-07-15 20:04:44.857851+07	BMRI	2951	ASK	1001	5
2026-07-15 20:04:44.857851+07	BMRI	2961	ASK	1296	6
2026-07-15 20:04:44.857851+07	BMRI	2971	ASK	1252	7
2026-07-15 20:04:44.857851+07	BMRI	2981	ASK	1758	8
2026-07-15 20:04:44.857851+07	BMRI	2991	ASK	1736	9
2026-07-15 20:04:45.868656+07	BMRI	2951	BID	57531	5
2026-07-15 20:04:45.868656+07	BMRI	2941	BID	1206	6
2026-07-15 20:04:45.868656+07	BMRI	2931	BID	1662	7
2026-07-15 20:04:45.868656+07	BMRI	2921	BID	1747	8
2026-07-15 20:04:45.868656+07	BMRI	2911	BID	1660	9
2026-07-15 20:04:45.868656+07	BMRI	2951	ASK	1040	5
2026-07-15 20:04:45.868656+07	BMRI	2961	ASK	1280	6
2026-07-15 20:04:45.868656+07	BMRI	2971	ASK	1297	7
2026-07-15 20:04:45.868656+07	BMRI	2981	ASK	1507	8
2026-07-15 20:04:45.868656+07	BMRI	2991	ASK	1592	9
2026-07-15 20:04:46.873911+07	BMRI	2951	BID	58064	5
2026-07-15 20:04:46.873911+07	BMRI	2941	BID	1560	6
2026-07-15 20:04:46.873911+07	BMRI	2931	BID	1673	7
2026-07-15 20:04:46.873911+07	BMRI	2921	BID	1471	8
2026-07-15 20:04:46.873911+07	BMRI	2911	BID	1621	9
2026-07-15 20:04:46.873911+07	BMRI	2951	ASK	1170	5
2026-07-15 20:04:46.873911+07	BMRI	2961	ASK	1118	6
2026-07-15 20:04:46.873911+07	BMRI	2971	ASK	1435	7
2026-07-15 20:04:46.873911+07	BMRI	2981	ASK	1314	8
2026-07-15 20:04:46.873911+07	BMRI	2991	ASK	1865	9
2026-07-15 20:04:47.884877+07	BMRI	2951	BID	50968	5
2026-07-15 20:04:47.884877+07	BMRI	2941	BID	1103	6
2026-07-15 20:04:47.884877+07	BMRI	2931	BID	1616	7
2026-07-15 20:04:47.884877+07	BMRI	2921	BID	1459	8
2026-07-15 20:04:47.884877+07	BMRI	2911	BID	1740	9
2026-07-15 20:04:47.884877+07	BMRI	2951	ASK	1174	5
2026-07-15 20:04:47.884877+07	BMRI	2961	ASK	1432	6
2026-07-15 20:04:47.884877+07	BMRI	2971	ASK	1210	7
2026-07-15 20:04:47.884877+07	BMRI	2981	ASK	1771	8
2026-07-15 20:04:47.884877+07	BMRI	2991	ASK	1598	9
2026-07-15 20:04:48.89006+07	BMRI	2951	BID	54166	5
2026-07-15 20:04:48.89006+07	BMRI	2941	BID	1529	6
2026-07-15 20:04:48.89006+07	BMRI	2931	BID	1443	7
2026-07-15 20:04:48.89006+07	BMRI	2921	BID	1553	8
2026-07-15 20:04:48.89006+07	BMRI	2911	BID	1523	9
2026-07-15 20:04:48.89006+07	BMRI	2951	ASK	1379	5
2026-07-15 20:04:48.89006+07	BMRI	2961	ASK	1132	6
2026-07-15 20:04:48.89006+07	BMRI	2971	ASK	1396	7
2026-07-15 20:04:48.89006+07	BMRI	2981	ASK	1529	8
2026-07-15 20:04:48.89006+07	BMRI	2991	ASK	1671	9
2026-07-15 20:04:49.89995+07	BMRI	2951	BID	55407	5
2026-07-15 20:04:49.89995+07	BMRI	2941	BID	1275	6
2026-07-15 20:04:49.89995+07	BMRI	2931	BID	1516	7
2026-07-15 20:04:49.89995+07	BMRI	2921	BID	1499	8
2026-07-15 20:04:49.89995+07	BMRI	2911	BID	1425	9
2026-07-15 20:04:49.89995+07	BMRI	2951	ASK	1181	5
2026-07-15 20:04:49.89995+07	BMRI	2961	ASK	1403	6
2026-07-15 20:04:49.89995+07	BMRI	2971	ASK	1694	7
2026-07-15 20:04:49.89995+07	BMRI	2981	ASK	1522	8
2026-07-15 20:04:49.89995+07	BMRI	2991	ASK	1669	9
2026-07-15 20:04:50.908065+07	BMRI	2951	BID	55968	5
2026-07-15 20:04:50.908065+07	BMRI	2941	BID	1523	6
2026-07-15 20:04:50.908065+07	BMRI	2931	BID	1242	7
2026-07-15 20:04:50.908065+07	BMRI	2921	BID	1679	8
2026-07-15 20:04:50.908065+07	BMRI	2911	BID	1701	9
2026-07-15 20:04:50.908065+07	BMRI	2951	ASK	1178	5
2026-07-15 20:04:50.908065+07	BMRI	2961	ASK	1190	6
2026-07-15 20:04:50.908065+07	BMRI	2971	ASK	1504	7
2026-07-15 20:04:50.908065+07	BMRI	2981	ASK	1493	8
2026-07-15 20:04:50.908065+07	BMRI	2991	ASK	1522	9
2026-07-15 20:04:51.918604+07	BMRI	2951	BID	59153	5
2026-07-15 20:04:51.918604+07	BMRI	2941	BID	1566	6
2026-07-15 20:04:51.918604+07	BMRI	2931	BID	1545	7
2026-07-15 20:04:51.918604+07	BMRI	2921	BID	1703	8
2026-07-15 20:04:51.918604+07	BMRI	2911	BID	1586	9
2026-07-15 20:04:51.918604+07	BMRI	2951	ASK	1335	5
2026-07-15 20:04:51.918604+07	BMRI	2961	ASK	1170	6
2026-07-15 20:04:51.918604+07	BMRI	2971	ASK	1550	7
2026-07-15 20:04:51.918604+07	BMRI	2981	ASK	1475	8
2026-07-15 20:04:51.918604+07	BMRI	2991	ASK	1759	9
2026-07-15 20:04:52.925073+07	BMRI	2951	BID	53201	5
2026-07-15 20:04:52.925073+07	BMRI	2941	BID	1560	6
2026-07-15 20:04:52.925073+07	BMRI	2931	BID	1475	7
2026-07-15 20:04:52.925073+07	BMRI	2921	BID	1794	8
2026-07-15 20:04:52.925073+07	BMRI	2911	BID	1651	9
2026-07-15 20:04:52.925073+07	BMRI	2951	ASK	1283	5
2026-07-15 20:04:52.925073+07	BMRI	2961	ASK	1336	6
2026-07-15 20:04:52.925073+07	BMRI	2971	ASK	1689	7
2026-07-15 20:04:52.925073+07	BMRI	2981	ASK	1588	8
2026-07-15 20:04:52.925073+07	BMRI	2991	ASK	1747	9
2026-07-15 20:04:53.935882+07	BMRI	2951	BID	57583	5
2026-07-15 20:04:53.935882+07	BMRI	2941	BID	1245	6
2026-07-15 20:04:53.935882+07	BMRI	2931	BID	1592	7
2026-07-15 20:04:53.935882+07	BMRI	2921	BID	1521	8
2026-07-15 20:04:53.935882+07	BMRI	2911	BID	1479	9
2026-07-15 20:04:53.935882+07	BMRI	2951	ASK	1490	5
2026-07-15 20:04:53.935882+07	BMRI	2961	ASK	1299	6
2026-07-15 20:04:53.935882+07	BMRI	2971	ASK	1665	7
2026-07-15 20:04:53.935882+07	BMRI	2981	ASK	1387	8
2026-07-15 20:04:53.935882+07	BMRI	2991	ASK	1495	9
2026-07-15 20:04:54.939885+07	BMRI	2951	BID	51890	5
2026-07-15 20:04:54.939885+07	BMRI	2941	BID	1519	6
2026-07-15 20:04:54.939885+07	BMRI	2931	BID	1480	7
2026-07-15 20:04:54.939885+07	BMRI	2921	BID	1498	8
2026-07-15 20:04:54.939885+07	BMRI	2911	BID	1492	9
2026-07-15 20:04:54.939885+07	BMRI	2951	ASK	1413	5
2026-07-15 20:04:54.939885+07	BMRI	2961	ASK	1105	6
2026-07-15 20:04:54.939885+07	BMRI	2971	ASK	1357	7
2026-07-15 20:04:54.939885+07	BMRI	2981	ASK	1426	8
2026-07-15 20:04:54.939885+07	BMRI	2991	ASK	1668	9
2026-07-15 20:04:55.947515+07	BMRI	2951	BID	58586	5
2026-07-15 20:04:55.947515+07	BMRI	2941	BID	1558	6
2026-07-15 20:04:55.947515+07	BMRI	2931	BID	1253	7
2026-07-15 20:04:55.947515+07	BMRI	2921	BID	1324	8
2026-07-15 20:04:55.947515+07	BMRI	2911	BID	1572	9
2026-07-15 20:04:55.947515+07	BMRI	2951	ASK	1009	5
2026-07-15 20:04:55.947515+07	BMRI	2961	ASK	1206	6
2026-07-15 20:04:55.947515+07	BMRI	2971	ASK	1665	7
2026-07-15 20:04:55.947515+07	BMRI	2981	ASK	1733	8
2026-07-15 20:04:55.947515+07	BMRI	2991	ASK	1731	9
2026-07-15 20:04:56.958446+07	BMRI	2951	BID	56713	5
2026-07-15 20:04:56.958446+07	BMRI	2941	BID	1505	6
2026-07-15 20:04:56.958446+07	BMRI	2931	BID	1317	7
2026-07-15 20:04:56.958446+07	BMRI	2921	BID	1766	8
2026-07-15 20:04:56.958446+07	BMRI	2911	BID	1880	9
2026-07-15 20:04:56.958446+07	BMRI	2951	ASK	1342	5
2026-07-15 20:04:56.958446+07	BMRI	2961	ASK	1571	6
2026-07-15 20:04:56.958446+07	BMRI	2971	ASK	1381	7
2026-07-15 20:04:56.958446+07	BMRI	2981	ASK	1451	8
2026-07-15 20:04:56.958446+07	BMRI	2991	ASK	1818	9
2026-07-15 20:04:57.96608+07	BMRI	2951	BID	59479	5
2026-07-15 20:04:57.96608+07	BMRI	2941	BID	1140	6
2026-07-15 20:04:57.96608+07	BMRI	2931	BID	1347	7
2026-07-15 20:04:57.96608+07	BMRI	2921	BID	1795	8
2026-07-15 20:04:57.96608+07	BMRI	2911	BID	1451	9
2026-07-15 20:04:57.96608+07	BMRI	2951	ASK	1397	5
2026-07-15 20:04:57.96608+07	BMRI	2961	ASK	1375	6
2026-07-15 20:04:57.96608+07	BMRI	2971	ASK	1654	7
2026-07-15 20:04:57.96608+07	BMRI	2981	ASK	1489	8
2026-07-15 20:04:57.96608+07	BMRI	2991	ASK	1705	9
2026-07-15 20:03:19.459408+07	TLKM	5782	BID	1299	5
2026-07-15 20:03:19.459408+07	TLKM	5772	BID	1241	6
2026-07-15 20:03:19.459408+07	TLKM	5762	BID	1548	7
2026-07-15 20:03:19.459408+07	TLKM	5752	BID	1637	8
2026-07-15 20:03:19.459408+07	TLKM	5742	BID	1612	9
2026-07-15 20:03:19.459408+07	TLKM	5782	ASK	1177	5
2026-07-15 20:03:19.459408+07	TLKM	5792	ASK	1425	6
2026-07-15 20:03:19.459408+07	TLKM	5802	ASK	1580	7
2026-07-15 20:03:19.459408+07	TLKM	5812	ASK	1365	8
2026-07-15 20:03:19.459408+07	TLKM	5822	ASK	1412	9
2026-07-15 20:03:20.468208+07	TLKM	5782	BID	1137	5
2026-07-15 20:03:20.468208+07	TLKM	5772	BID	1559	6
2026-07-15 20:03:20.468208+07	TLKM	5762	BID	1586	7
2026-07-15 20:03:20.468208+07	TLKM	5752	BID	1725	8
2026-07-15 20:03:20.468208+07	TLKM	5742	BID	1603	9
2026-07-15 20:03:20.468208+07	TLKM	5782	ASK	1279	5
2026-07-15 20:03:20.468208+07	TLKM	5792	ASK	1172	6
2026-07-15 20:03:20.468208+07	TLKM	5802	ASK	1310	7
2026-07-15 20:03:20.468208+07	TLKM	5812	ASK	1474	8
2026-07-15 20:03:20.468208+07	TLKM	5822	ASK	1446	9
2026-07-15 20:03:21.475369+07	TLKM	5782	BID	1425	5
2026-07-15 20:03:21.475369+07	TLKM	5772	BID	1492	6
2026-07-15 20:03:21.475369+07	TLKM	5762	BID	1527	7
2026-07-15 20:03:21.475369+07	TLKM	5752	BID	1431	8
2026-07-15 20:03:21.475369+07	TLKM	5742	BID	1833	9
2026-07-15 20:03:21.475369+07	TLKM	5782	ASK	1161	5
2026-07-15 20:03:21.475369+07	TLKM	5792	ASK	1183	6
2026-07-15 20:03:21.475369+07	TLKM	5802	ASK	1371	7
2026-07-15 20:03:21.475369+07	TLKM	5812	ASK	1576	8
2026-07-15 20:03:21.475369+07	TLKM	5822	ASK	1529	9
2026-07-15 20:03:22.482613+07	TLKM	5782	BID	1136	5
2026-07-15 20:03:22.482613+07	TLKM	5772	BID	1579	6
2026-07-15 20:03:22.482613+07	TLKM	5762	BID	1335	7
2026-07-15 20:03:22.482613+07	TLKM	5752	BID	1701	8
2026-07-15 20:03:22.482613+07	TLKM	5742	BID	1412	9
2026-07-15 20:03:22.482613+07	TLKM	5782	ASK	1348	5
2026-07-15 20:03:22.482613+07	TLKM	5792	ASK	1141	6
2026-07-15 20:03:22.482613+07	TLKM	5802	ASK	1268	7
2026-07-15 20:03:22.482613+07	TLKM	5812	ASK	1611	8
2026-07-15 20:03:22.482613+07	TLKM	5822	ASK	1595	9
2026-07-15 20:03:23.490992+07	TLKM	5782	BID	1385	5
2026-07-15 20:03:23.490992+07	TLKM	5772	BID	1573	6
2026-07-15 20:03:23.490992+07	TLKM	5762	BID	1356	7
2026-07-15 20:03:23.490992+07	TLKM	5752	BID	1622	8
2026-07-15 20:03:23.490992+07	TLKM	5742	BID	1511	9
2026-07-15 20:03:23.490992+07	TLKM	5782	ASK	1475	5
2026-07-15 20:03:23.490992+07	TLKM	5792	ASK	1599	6
2026-07-15 20:03:23.490992+07	TLKM	5802	ASK	1613	7
2026-07-15 20:03:23.490992+07	TLKM	5812	ASK	1795	8
2026-07-15 20:03:23.490992+07	TLKM	5822	ASK	1460	9
2026-07-15 20:03:24.496561+07	TLKM	5782	BID	1095	5
2026-07-15 20:03:24.496561+07	TLKM	5772	BID	1586	6
2026-07-15 20:03:24.496561+07	TLKM	5762	BID	1558	7
2026-07-15 20:03:24.496561+07	TLKM	5752	BID	1530	8
2026-07-15 20:03:24.496561+07	TLKM	5742	BID	1685	9
2026-07-15 20:03:24.496561+07	TLKM	5782	ASK	1197	5
2026-07-15 20:03:24.496561+07	TLKM	5792	ASK	1106	6
2026-07-15 20:03:24.496561+07	TLKM	5802	ASK	1236	7
2026-07-15 20:03:24.496561+07	TLKM	5812	ASK	1776	8
2026-07-15 20:03:24.496561+07	TLKM	5822	ASK	1550	9
2026-07-15 20:03:25.506859+07	TLKM	5782	BID	1289	5
2026-07-15 20:03:25.506859+07	TLKM	5772	BID	1469	6
2026-07-15 20:03:25.506859+07	TLKM	5762	BID	1590	7
2026-07-15 20:03:25.506859+07	TLKM	5752	BID	1637	8
2026-07-15 20:03:25.506859+07	TLKM	5742	BID	1783	9
2026-07-15 20:03:25.506859+07	TLKM	5782	ASK	1344	5
2026-07-15 20:03:25.506859+07	TLKM	5792	ASK	1215	6
2026-07-15 20:03:25.506859+07	TLKM	5802	ASK	1699	7
2026-07-15 20:03:25.506859+07	TLKM	5812	ASK	1776	8
2026-07-15 20:03:25.506859+07	TLKM	5822	ASK	1429	9
2026-07-15 20:03:26.518018+07	TLKM	5782	BID	1271	5
2026-07-15 20:03:26.518018+07	TLKM	5772	BID	1414	6
2026-07-15 20:03:26.518018+07	TLKM	5762	BID	1620	7
2026-07-15 20:03:26.518018+07	TLKM	5752	BID	1407	8
2026-07-15 20:03:26.518018+07	TLKM	5742	BID	1696	9
2026-07-15 20:03:26.518018+07	TLKM	5782	ASK	1312	5
2026-07-15 20:03:26.518018+07	TLKM	5792	ASK	1339	6
2026-07-15 20:03:26.518018+07	TLKM	5802	ASK	1353	7
2026-07-15 20:03:26.518018+07	TLKM	5812	ASK	1477	8
2026-07-15 20:03:26.518018+07	TLKM	5822	ASK	1622	9
2026-07-15 20:03:27.524801+07	TLKM	5782	BID	1262	5
2026-07-15 20:03:27.524801+07	TLKM	5772	BID	1449	6
2026-07-15 20:03:27.524801+07	TLKM	5762	BID	1389	7
2026-07-15 20:03:27.524801+07	TLKM	5752	BID	1606	8
2026-07-15 20:03:27.524801+07	TLKM	5742	BID	1660	9
2026-07-15 20:03:27.524801+07	TLKM	5782	ASK	1133	5
2026-07-15 20:03:27.524801+07	TLKM	5792	ASK	1109	6
2026-07-15 20:03:27.524801+07	TLKM	5802	ASK	1223	7
2026-07-15 20:03:27.524801+07	TLKM	5812	ASK	1539	8
2026-07-15 20:03:27.524801+07	TLKM	5822	ASK	1810	9
2026-07-15 20:03:28.533604+07	TLKM	5782	BID	1042	5
2026-07-15 20:03:28.533604+07	TLKM	5772	BID	1112	6
2026-07-15 20:03:28.533604+07	TLKM	5762	BID	1238	7
2026-07-15 20:03:28.533604+07	TLKM	5752	BID	1355	8
2026-07-15 20:03:28.533604+07	TLKM	5742	BID	1862	9
2026-07-15 20:03:28.533604+07	TLKM	5782	ASK	1175	5
2026-07-15 20:03:28.533604+07	TLKM	5792	ASK	1275	6
2026-07-15 20:03:28.533604+07	TLKM	5802	ASK	1612	7
2026-07-15 20:03:28.533604+07	TLKM	5812	ASK	1516	8
2026-07-15 20:03:28.533604+07	TLKM	5822	ASK	1527	9
2026-07-15 20:03:29.540515+07	TLKM	5782	BID	1121	5
2026-07-15 20:03:29.540515+07	TLKM	5772	BID	1194	6
2026-07-15 20:03:29.540515+07	TLKM	5762	BID	1363	7
2026-07-15 20:03:29.540515+07	TLKM	5752	BID	1560	8
2026-07-15 20:03:29.540515+07	TLKM	5742	BID	1428	9
2026-07-15 20:03:29.540515+07	TLKM	5782	ASK	1473	5
2026-07-15 20:03:29.540515+07	TLKM	5792	ASK	1466	6
2026-07-15 20:03:29.540515+07	TLKM	5802	ASK	1342	7
2026-07-15 20:03:29.540515+07	TLKM	5812	ASK	1307	8
2026-07-15 20:03:29.540515+07	TLKM	5822	ASK	1784	9
2026-07-15 20:03:30.544438+07	TLKM	5782	BID	1373	5
2026-07-15 20:03:30.544438+07	TLKM	5772	BID	1577	6
2026-07-15 20:03:30.544438+07	TLKM	5762	BID	1407	7
2026-07-15 20:03:30.544438+07	TLKM	5752	BID	1520	8
2026-07-15 20:03:30.544438+07	TLKM	5742	BID	1744	9
2026-07-15 20:03:30.544438+07	TLKM	5782	ASK	1098	5
2026-07-15 20:03:30.544438+07	TLKM	5792	ASK	1309	6
2026-07-15 20:03:30.544438+07	TLKM	5802	ASK	1654	7
2026-07-15 20:03:30.544438+07	TLKM	5812	ASK	1785	8
2026-07-15 20:03:30.544438+07	TLKM	5822	ASK	1615	9
2026-07-15 20:03:31.555471+07	TLKM	5782	BID	1478	5
2026-07-15 20:03:31.555471+07	TLKM	5772	BID	1170	6
2026-07-15 20:03:31.555471+07	TLKM	5762	BID	1481	7
2026-07-15 20:03:31.555471+07	TLKM	5752	BID	1695	8
2026-07-15 20:03:31.555471+07	TLKM	5742	BID	1747	9
2026-07-15 20:03:31.555471+07	TLKM	5782	ASK	1088	5
2026-07-15 20:03:31.555471+07	TLKM	5792	ASK	1328	6
2026-07-15 20:03:31.555471+07	TLKM	5802	ASK	1239	7
2026-07-15 20:03:31.555471+07	TLKM	5812	ASK	1765	8
2026-07-15 20:03:31.555471+07	TLKM	5822	ASK	1601	9
2026-07-15 20:03:32.56005+07	TLKM	5782	BID	1465	5
2026-07-15 20:03:32.56005+07	TLKM	5772	BID	1223	6
2026-07-15 20:03:32.56005+07	TLKM	5762	BID	1627	7
2026-07-15 20:03:32.56005+07	TLKM	5752	BID	1660	8
2026-07-15 20:03:32.56005+07	TLKM	5742	BID	1684	9
2026-07-15 20:03:32.56005+07	TLKM	5782	ASK	1200	5
2026-07-15 20:03:32.56005+07	TLKM	5792	ASK	1503	6
2026-07-15 20:03:32.56005+07	TLKM	5802	ASK	1266	7
2026-07-15 20:03:32.56005+07	TLKM	5812	ASK	1351	8
2026-07-15 20:03:32.56005+07	TLKM	5822	ASK	1487	9
2026-07-15 20:03:33.571317+07	TLKM	5782	BID	1452	5
2026-07-15 20:03:33.571317+07	TLKM	5772	BID	1257	6
2026-07-15 20:03:33.571317+07	TLKM	5762	BID	1577	7
2026-07-15 20:03:33.571317+07	TLKM	5752	BID	1419	8
2026-07-15 20:03:33.571317+07	TLKM	5742	BID	1664	9
2026-07-15 20:03:33.571317+07	TLKM	5782	ASK	1264	5
2026-07-15 20:03:33.571317+07	TLKM	5792	ASK	1305	6
2026-07-15 20:03:33.571317+07	TLKM	5802	ASK	1318	7
2026-07-15 20:03:33.571317+07	TLKM	5812	ASK	1702	8
2026-07-15 20:03:33.571317+07	TLKM	5822	ASK	1483	9
2026-07-15 20:03:34.575567+07	TLKM	5782	BID	1397	5
2026-07-15 20:03:34.575567+07	TLKM	5772	BID	1173	6
2026-07-15 20:03:34.575567+07	TLKM	5762	BID	1570	7
2026-07-15 20:03:34.575567+07	TLKM	5752	BID	1502	8
2026-07-15 20:03:34.575567+07	TLKM	5742	BID	1693	9
2026-07-15 20:03:34.575567+07	TLKM	5782	ASK	1089	5
2026-07-15 20:03:34.575567+07	TLKM	5792	ASK	1217	6
2026-07-15 20:03:34.575567+07	TLKM	5802	ASK	1537	7
2026-07-15 20:03:34.575567+07	TLKM	5812	ASK	1642	8
2026-07-15 20:03:34.575567+07	TLKM	5822	ASK	1872	9
2026-07-15 20:03:35.581996+07	TLKM	5782	BID	1419	5
2026-07-15 20:03:35.581996+07	TLKM	5772	BID	1503	6
2026-07-15 20:03:35.581996+07	TLKM	5762	BID	1504	7
2026-07-15 20:03:35.581996+07	TLKM	5752	BID	1384	8
2026-07-15 20:03:35.581996+07	TLKM	5742	BID	1731	9
2026-07-15 20:03:35.581996+07	TLKM	5782	ASK	1120	5
2026-07-15 20:03:35.581996+07	TLKM	5792	ASK	1344	6
2026-07-15 20:03:35.581996+07	TLKM	5802	ASK	1681	7
2026-07-15 20:03:35.581996+07	TLKM	5812	ASK	1405	8
2026-07-15 20:03:35.581996+07	TLKM	5822	ASK	1728	9
2026-07-15 20:03:36.592357+07	TLKM	5782	BID	1378	5
2026-07-15 20:03:36.592357+07	TLKM	5772	BID	1232	6
2026-07-15 20:03:36.592357+07	TLKM	5762	BID	1231	7
2026-07-15 20:03:36.592357+07	TLKM	5752	BID	1428	8
2026-07-15 20:03:36.592357+07	TLKM	5742	BID	1430	9
2026-07-15 20:03:36.592357+07	TLKM	5782	ASK	1097	5
2026-07-15 20:03:36.592357+07	TLKM	5792	ASK	1586	6
2026-07-15 20:03:36.592357+07	TLKM	5802	ASK	1290	7
2026-07-15 20:03:36.592357+07	TLKM	5812	ASK	1372	8
2026-07-15 20:03:36.592357+07	TLKM	5822	ASK	1441	9
2026-07-15 20:03:37.603056+07	TLKM	5782	BID	1008	5
2026-07-15 20:03:37.603056+07	TLKM	5772	BID	1387	6
2026-07-15 20:03:37.603056+07	TLKM	5762	BID	1336	7
2026-07-15 20:03:37.603056+07	TLKM	5752	BID	1464	8
2026-07-15 20:03:37.603056+07	TLKM	5742	BID	1607	9
2026-07-15 20:03:37.603056+07	TLKM	5782	ASK	1270	5
2026-07-15 20:03:37.603056+07	TLKM	5792	ASK	1273	6
2026-07-15 20:03:37.603056+07	TLKM	5802	ASK	1464	7
2026-07-15 20:03:37.603056+07	TLKM	5812	ASK	1577	8
2026-07-15 20:03:37.603056+07	TLKM	5822	ASK	1685	9
2026-07-15 20:03:38.612852+07	TLKM	5782	BID	1281	5
2026-07-15 20:03:38.612852+07	TLKM	5772	BID	1598	6
2026-07-15 20:03:38.612852+07	TLKM	5762	BID	1539	7
2026-07-15 20:03:38.612852+07	TLKM	5752	BID	1537	8
2026-07-15 20:03:38.612852+07	TLKM	5742	BID	1715	9
2026-07-15 20:03:38.612852+07	TLKM	5782	ASK	1032	5
2026-07-15 20:03:38.612852+07	TLKM	5792	ASK	1400	6
2026-07-15 20:03:38.612852+07	TLKM	5802	ASK	1434	7
2026-07-15 20:03:38.612852+07	TLKM	5812	ASK	1729	8
2026-07-15 20:03:38.612852+07	TLKM	5822	ASK	1667	9
2026-07-15 20:03:39.623588+07	TLKM	5782	BID	1389	5
2026-07-15 20:03:39.623588+07	TLKM	5772	BID	1270	6
2026-07-15 20:03:39.623588+07	TLKM	5762	BID	1579	7
2026-07-15 20:03:39.623588+07	TLKM	5752	BID	1356	8
2026-07-15 20:03:39.623588+07	TLKM	5742	BID	1683	9
2026-07-15 20:03:39.623588+07	TLKM	5782	ASK	1114	5
2026-07-15 20:03:39.623588+07	TLKM	5792	ASK	1310	6
2026-07-15 20:03:39.623588+07	TLKM	5802	ASK	1205	7
2026-07-15 20:03:39.623588+07	TLKM	5812	ASK	1595	8
2026-07-15 20:03:39.623588+07	TLKM	5822	ASK	1697	9
2026-07-15 20:03:40.629334+07	TLKM	5782	BID	1239	5
2026-07-15 20:03:40.629334+07	TLKM	5772	BID	1322	6
2026-07-15 20:03:40.629334+07	TLKM	5762	BID	1476	7
2026-07-15 20:03:40.629334+07	TLKM	5752	BID	1309	8
2026-07-15 20:03:40.629334+07	TLKM	5742	BID	1465	9
2026-07-15 20:03:40.629334+07	TLKM	5782	ASK	1331	5
2026-07-15 20:03:40.629334+07	TLKM	5792	ASK	1369	6
2026-07-15 20:03:40.629334+07	TLKM	5802	ASK	1285	7
2026-07-15 20:03:40.629334+07	TLKM	5812	ASK	1542	8
2026-07-15 20:03:40.629334+07	TLKM	5822	ASK	1625	9
2026-07-15 20:03:41.640545+07	TLKM	5782	BID	1270	5
2026-07-15 20:03:41.640545+07	TLKM	5772	BID	1416	6
2026-07-15 20:03:41.640545+07	TLKM	5762	BID	1405	7
2026-07-15 20:03:41.640545+07	TLKM	5752	BID	1318	8
2026-07-15 20:03:41.640545+07	TLKM	5742	BID	1404	9
2026-07-15 20:03:41.640545+07	TLKM	5782	ASK	1376	5
2026-07-15 20:03:41.640545+07	TLKM	5792	ASK	1310	6
2026-07-15 20:03:41.640545+07	TLKM	5802	ASK	1322	7
2026-07-15 20:03:41.640545+07	TLKM	5812	ASK	1463	8
2026-07-15 20:03:41.640545+07	TLKM	5822	ASK	1697	9
2026-07-15 20:03:42.647488+07	TLKM	5782	BID	1091	5
2026-07-15 20:03:42.647488+07	TLKM	5772	BID	1454	6
2026-07-15 20:03:42.647488+07	TLKM	5762	BID	1451	7
2026-07-15 20:03:42.647488+07	TLKM	5752	BID	1539	8
2026-07-15 20:03:42.647488+07	TLKM	5742	BID	1740	9
2026-07-15 20:03:42.647488+07	TLKM	5782	ASK	1175	5
2026-07-15 20:03:42.647488+07	TLKM	5792	ASK	1562	6
2026-07-15 20:03:42.647488+07	TLKM	5802	ASK	1610	7
2026-07-15 20:03:42.647488+07	TLKM	5812	ASK	1427	8
2026-07-15 20:03:42.647488+07	TLKM	5822	ASK	1750	9
2026-07-15 20:03:43.657662+07	TLKM	5782	BID	1116	5
2026-07-15 20:03:43.657662+07	TLKM	5772	BID	1108	6
2026-07-15 20:03:43.657662+07	TLKM	5762	BID	1636	7
2026-07-15 20:03:43.657662+07	TLKM	5752	BID	1504	8
2026-07-15 20:03:43.657662+07	TLKM	5742	BID	1605	9
2026-07-15 20:03:43.657662+07	TLKM	5782	ASK	1448	5
2026-07-15 20:03:43.657662+07	TLKM	5792	ASK	1113	6
2026-07-15 20:03:43.657662+07	TLKM	5802	ASK	1256	7
2026-07-15 20:03:43.657662+07	TLKM	5812	ASK	1500	8
2026-07-15 20:03:43.657662+07	TLKM	5822	ASK	1574	9
2026-07-15 20:03:44.664398+07	TLKM	5782	BID	1003	5
2026-07-15 20:03:44.664398+07	TLKM	5772	BID	1362	6
2026-07-15 20:03:44.664398+07	TLKM	5762	BID	1615	7
2026-07-15 20:03:44.664398+07	TLKM	5752	BID	1680	8
2026-07-15 20:03:44.664398+07	TLKM	5742	BID	1457	9
2026-07-15 20:03:44.664398+07	TLKM	5782	ASK	1204	5
2026-07-15 20:03:44.664398+07	TLKM	5792	ASK	1420	6
2026-07-15 20:03:44.664398+07	TLKM	5802	ASK	1311	7
2026-07-15 20:03:44.664398+07	TLKM	5812	ASK	1587	8
2026-07-15 20:03:44.664398+07	TLKM	5822	ASK	1683	9
2026-07-15 20:03:45.674729+07	TLKM	5782	BID	1477	5
2026-07-15 20:03:45.674729+07	TLKM	5772	BID	1346	6
2026-07-15 20:03:45.674729+07	TLKM	5762	BID	1273	7
2026-07-15 20:03:45.674729+07	TLKM	5752	BID	1381	8
2026-07-15 20:03:45.674729+07	TLKM	5742	BID	1429	9
2026-07-15 20:03:45.674729+07	TLKM	5782	ASK	1265	5
2026-07-15 20:03:45.674729+07	TLKM	5792	ASK	1575	6
2026-07-15 20:03:45.674729+07	TLKM	5802	ASK	1514	7
2026-07-15 20:03:45.674729+07	TLKM	5812	ASK	1591	8
2026-07-15 20:03:45.674729+07	TLKM	5822	ASK	1487	9
2026-07-15 20:03:46.68003+07	TLKM	5782	BID	1379	5
2026-07-15 20:03:46.68003+07	TLKM	5772	BID	1534	6
2026-07-15 20:03:46.68003+07	TLKM	5762	BID	1455	7
2026-07-15 20:03:46.68003+07	TLKM	5752	BID	1628	8
2026-07-15 20:03:46.68003+07	TLKM	5742	BID	1627	9
2026-07-15 20:03:46.68003+07	TLKM	5782	ASK	1128	5
2026-07-15 20:03:46.68003+07	TLKM	5792	ASK	1264	6
2026-07-15 20:03:46.68003+07	TLKM	5802	ASK	1685	7
2026-07-15 20:03:46.68003+07	TLKM	5812	ASK	1649	8
2026-07-15 20:03:46.68003+07	TLKM	5822	ASK	1818	9
2026-07-15 20:03:47.689661+07	TLKM	5782	BID	1388	5
2026-07-15 20:03:47.689661+07	TLKM	5772	BID	1194	6
2026-07-15 20:03:47.689661+07	TLKM	5762	BID	1404	7
2026-07-15 20:03:47.689661+07	TLKM	5752	BID	1421	8
2026-07-15 20:03:47.689661+07	TLKM	5742	BID	1484	9
2026-07-15 20:03:47.689661+07	TLKM	5782	ASK	1131	5
2026-07-15 20:03:47.689661+07	TLKM	5792	ASK	1459	6
2026-07-15 20:03:47.689661+07	TLKM	5802	ASK	1683	7
2026-07-15 20:03:47.689661+07	TLKM	5812	ASK	1615	8
2026-07-15 20:03:47.689661+07	TLKM	5822	ASK	1703	9
2026-07-15 20:03:48.695219+07	TLKM	5782	BID	1457	5
2026-07-15 20:03:48.695219+07	TLKM	5772	BID	1377	6
2026-07-15 20:03:48.695219+07	TLKM	5762	BID	1464	7
2026-07-15 20:03:48.695219+07	TLKM	5752	BID	1427	8
2026-07-15 20:03:48.695219+07	TLKM	5742	BID	1432	9
2026-07-15 20:03:48.695219+07	TLKM	5782	ASK	1426	5
2026-07-15 20:03:48.695219+07	TLKM	5792	ASK	1115	6
2026-07-15 20:03:48.695219+07	TLKM	5802	ASK	1336	7
2026-07-15 20:03:48.695219+07	TLKM	5812	ASK	1367	8
2026-07-15 20:03:48.695219+07	TLKM	5822	ASK	1442	9
2026-07-15 20:03:49.704826+07	TLKM	5782	BID	1380	5
2026-07-15 20:03:49.704826+07	TLKM	5772	BID	1406	6
2026-07-15 20:03:49.704826+07	TLKM	5762	BID	1554	7
2026-07-15 20:03:49.704826+07	TLKM	5752	BID	1463	8
2026-07-15 20:03:49.704826+07	TLKM	5742	BID	1818	9
2026-07-15 20:03:49.704826+07	TLKM	5782	ASK	1230	5
2026-07-15 20:03:49.704826+07	TLKM	5792	ASK	1232	6
2026-07-15 20:03:49.704826+07	TLKM	5802	ASK	1409	7
2026-07-15 20:03:49.704826+07	TLKM	5812	ASK	1642	8
2026-07-15 20:03:49.704826+07	TLKM	5822	ASK	1659	9
2026-07-15 20:03:50.71144+07	TLKM	5782	BID	1092	5
2026-07-15 20:03:50.71144+07	TLKM	5772	BID	1466	6
2026-07-15 20:03:50.71144+07	TLKM	5762	BID	1243	7
2026-07-15 20:03:50.71144+07	TLKM	5752	BID	1669	8
2026-07-15 20:03:50.71144+07	TLKM	5742	BID	1489	9
2026-07-15 20:03:50.71144+07	TLKM	5782	ASK	1022	5
2026-07-15 20:03:50.71144+07	TLKM	5792	ASK	1241	6
2026-07-15 20:03:50.71144+07	TLKM	5802	ASK	1687	7
2026-07-15 20:03:50.71144+07	TLKM	5812	ASK	1740	8
2026-07-15 20:03:50.71144+07	TLKM	5822	ASK	1529	9
2026-07-15 20:03:51.719047+07	TLKM	5782	BID	1118	5
2026-07-15 20:03:51.719047+07	TLKM	5772	BID	1475	6
2026-07-15 20:03:51.719047+07	TLKM	5762	BID	1227	7
2026-07-15 20:03:51.719047+07	TLKM	5752	BID	1535	8
2026-07-15 20:03:51.719047+07	TLKM	5742	BID	1611	9
2026-07-15 20:03:51.719047+07	TLKM	5782	ASK	1493	5
2026-07-15 20:03:51.719047+07	TLKM	5792	ASK	1488	6
2026-07-15 20:03:51.719047+07	TLKM	5802	ASK	1459	7
2026-07-15 20:03:51.719047+07	TLKM	5812	ASK	1353	8
2026-07-15 20:03:51.719047+07	TLKM	5822	ASK	1704	9
2026-07-15 20:03:52.726759+07	TLKM	5782	BID	1226	5
2026-07-15 20:03:52.726759+07	TLKM	5772	BID	1274	6
2026-07-15 20:03:52.726759+07	TLKM	5762	BID	1358	7
2026-07-15 20:03:52.726759+07	TLKM	5752	BID	1364	8
2026-07-15 20:03:52.726759+07	TLKM	5742	BID	1547	9
2026-07-15 20:03:52.726759+07	TLKM	5782	ASK	1078	5
2026-07-15 20:03:52.726759+07	TLKM	5792	ASK	1596	6
2026-07-15 20:03:52.726759+07	TLKM	5802	ASK	1538	7
2026-07-15 20:03:52.726759+07	TLKM	5812	ASK	1554	8
2026-07-15 20:03:52.726759+07	TLKM	5822	ASK	1543	9
2026-07-15 20:03:53.732203+07	TLKM	5782	BID	1365	5
2026-07-15 20:03:53.732203+07	TLKM	5772	BID	1531	6
2026-07-15 20:03:53.732203+07	TLKM	5762	BID	1645	7
2026-07-15 20:03:53.732203+07	TLKM	5752	BID	1349	8
2026-07-15 20:03:53.732203+07	TLKM	5742	BID	1524	9
2026-07-15 20:03:53.732203+07	TLKM	5782	ASK	1307	5
2026-07-15 20:03:53.732203+07	TLKM	5792	ASK	1590	6
2026-07-15 20:03:53.732203+07	TLKM	5802	ASK	1384	7
2026-07-15 20:03:53.732203+07	TLKM	5812	ASK	1757	8
2026-07-15 20:03:53.732203+07	TLKM	5822	ASK	1844	9
2026-07-15 20:03:54.741134+07	TLKM	5782	BID	1456	5
2026-07-15 20:03:54.741134+07	TLKM	5772	BID	1221	6
2026-07-15 20:03:54.741134+07	TLKM	5762	BID	1663	7
2026-07-15 20:03:54.741134+07	TLKM	5752	BID	1302	8
2026-07-15 20:03:54.741134+07	TLKM	5742	BID	1610	9
2026-07-15 20:03:54.741134+07	TLKM	5782	ASK	1204	5
2026-07-15 20:03:54.741134+07	TLKM	5792	ASK	1443	6
2026-07-15 20:03:54.741134+07	TLKM	5802	ASK	1432	7
2026-07-15 20:03:54.741134+07	TLKM	5812	ASK	1396	8
2026-07-15 20:03:54.741134+07	TLKM	5822	ASK	1689	9
2026-07-15 20:03:55.745465+07	TLKM	5782	BID	1276	5
2026-07-15 20:03:55.745465+07	TLKM	5772	BID	1397	6
2026-07-15 20:03:55.745465+07	TLKM	5762	BID	1433	7
2026-07-15 20:03:55.745465+07	TLKM	5752	BID	1528	8
2026-07-15 20:03:55.745465+07	TLKM	5742	BID	1807	9
2026-07-15 20:03:55.745465+07	TLKM	5782	ASK	1436	5
2026-07-15 20:03:55.745465+07	TLKM	5792	ASK	1117	6
2026-07-15 20:03:55.745465+07	TLKM	5802	ASK	1326	7
2026-07-15 20:03:55.745465+07	TLKM	5812	ASK	1526	8
2026-07-15 20:03:55.745465+07	TLKM	5822	ASK	1597	9
2026-07-15 20:03:56.756101+07	TLKM	5782	BID	1469	5
2026-07-15 20:03:56.756101+07	TLKM	5772	BID	1333	6
2026-07-15 20:03:56.756101+07	TLKM	5762	BID	1455	7
2026-07-15 20:03:56.756101+07	TLKM	5752	BID	1753	8
2026-07-15 20:03:56.756101+07	TLKM	5742	BID	1644	9
2026-07-15 20:03:56.756101+07	TLKM	5782	ASK	1246	5
2026-07-15 20:03:56.756101+07	TLKM	5792	ASK	1352	6
2026-07-15 20:03:56.756101+07	TLKM	5802	ASK	1430	7
2026-07-15 20:03:56.756101+07	TLKM	5812	ASK	1417	8
2026-07-15 20:03:56.756101+07	TLKM	5822	ASK	1412	9
2026-07-15 20:03:57.760611+07	TLKM	5782	BID	1437	5
2026-07-15 20:03:57.760611+07	TLKM	5772	BID	1418	6
2026-07-15 20:03:57.760611+07	TLKM	5762	BID	1316	7
2026-07-15 20:03:57.760611+07	TLKM	5752	BID	1713	8
2026-07-15 20:03:57.760611+07	TLKM	5742	BID	1700	9
2026-07-15 20:03:57.760611+07	TLKM	5782	ASK	1169	5
2026-07-15 20:03:57.760611+07	TLKM	5792	ASK	1272	6
2026-07-15 20:03:57.760611+07	TLKM	5802	ASK	1387	7
2026-07-15 20:03:57.760611+07	TLKM	5812	ASK	1785	8
2026-07-15 20:03:57.760611+07	TLKM	5822	ASK	1723	9
2026-07-15 20:03:58.767615+07	TLKM	5782	BID	1493	5
2026-07-15 20:03:58.767615+07	TLKM	5772	BID	1487	6
2026-07-15 20:03:58.767615+07	TLKM	5762	BID	1527	7
2026-07-15 20:03:58.767615+07	TLKM	5752	BID	1455	8
2026-07-15 20:03:58.767615+07	TLKM	5742	BID	1727	9
2026-07-15 20:03:58.767615+07	TLKM	5782	ASK	1315	5
2026-07-15 20:03:58.767615+07	TLKM	5792	ASK	1565	6
2026-07-15 20:03:58.767615+07	TLKM	5802	ASK	1397	7
2026-07-15 20:03:58.767615+07	TLKM	5812	ASK	1773	8
2026-07-15 20:03:58.767615+07	TLKM	5822	ASK	1773	9
2026-07-15 20:03:59.775535+07	TLKM	5782	BID	1481	5
2026-07-15 20:03:59.775535+07	TLKM	5772	BID	1596	6
2026-07-15 20:03:59.775535+07	TLKM	5762	BID	1566	7
2026-07-15 20:03:59.775535+07	TLKM	5752	BID	1624	8
2026-07-15 20:03:59.775535+07	TLKM	5742	BID	1651	9
2026-07-15 20:03:59.775535+07	TLKM	5782	ASK	1311	5
2026-07-15 20:03:59.775535+07	TLKM	5792	ASK	1109	6
2026-07-15 20:03:59.775535+07	TLKM	5802	ASK	1306	7
2026-07-15 20:03:59.775535+07	TLKM	5812	ASK	1609	8
2026-07-15 20:03:59.775535+07	TLKM	5822	ASK	1638	9
2026-07-15 20:04:00.781506+07	TLKM	5782	BID	1191	5
2026-07-15 20:04:00.781506+07	TLKM	5772	BID	1184	6
2026-07-15 20:04:00.781506+07	TLKM	5762	BID	1534	7
2026-07-15 20:04:00.781506+07	TLKM	5752	BID	1741	8
2026-07-15 20:04:00.781506+07	TLKM	5742	BID	1459	9
2026-07-15 20:04:00.781506+07	TLKM	5782	ASK	1219	5
2026-07-15 20:04:00.781506+07	TLKM	5792	ASK	1221	6
2026-07-15 20:04:00.781506+07	TLKM	5802	ASK	1305	7
2026-07-15 20:04:00.781506+07	TLKM	5812	ASK	1688	8
2026-07-15 20:04:00.781506+07	TLKM	5822	ASK	1490	9
2026-07-15 20:04:01.790943+07	TLKM	5782	BID	1214	5
2026-07-15 20:04:01.790943+07	TLKM	5772	BID	1221	6
2026-07-15 20:04:01.790943+07	TLKM	5762	BID	1217	7
2026-07-15 20:04:01.790943+07	TLKM	5752	BID	1513	8
2026-07-15 20:04:01.790943+07	TLKM	5742	BID	1764	9
2026-07-15 20:04:01.790943+07	TLKM	5782	ASK	1408	5
2026-07-15 20:04:01.790943+07	TLKM	5792	ASK	1382	6
2026-07-15 20:04:01.790943+07	TLKM	5802	ASK	1381	7
2026-07-15 20:04:01.790943+07	TLKM	5812	ASK	1521	8
2026-07-15 20:04:01.790943+07	TLKM	5822	ASK	1894	9
2026-07-15 20:04:02.795037+07	TLKM	5782	BID	1482	5
2026-07-15 20:04:02.795037+07	TLKM	5772	BID	1582	6
2026-07-15 20:04:02.795037+07	TLKM	5762	BID	1427	7
2026-07-15 20:04:02.795037+07	TLKM	5752	BID	1603	8
2026-07-15 20:04:02.795037+07	TLKM	5742	BID	1530	9
2026-07-15 20:04:02.795037+07	TLKM	5782	ASK	1437	5
2026-07-15 20:04:02.795037+07	TLKM	5792	ASK	1238	6
2026-07-15 20:04:02.795037+07	TLKM	5802	ASK	1552	7
2026-07-15 20:04:02.795037+07	TLKM	5812	ASK	1624	8
2026-07-15 20:04:02.795037+07	TLKM	5822	ASK	1412	9
2026-07-15 20:04:03.804067+07	TLKM	5782	BID	1179	5
2026-07-15 20:04:03.804067+07	TLKM	5772	BID	1189	6
2026-07-15 20:04:03.804067+07	TLKM	5762	BID	1592	7
2026-07-15 20:04:03.804067+07	TLKM	5752	BID	1680	8
2026-07-15 20:04:03.804067+07	TLKM	5742	BID	1546	9
2026-07-15 20:04:03.804067+07	TLKM	5782	ASK	1281	5
2026-07-15 20:04:03.804067+07	TLKM	5792	ASK	1228	6
2026-07-15 20:04:03.804067+07	TLKM	5802	ASK	1495	7
2026-07-15 20:04:03.804067+07	TLKM	5812	ASK	1789	8
2026-07-15 20:04:03.804067+07	TLKM	5822	ASK	1480	9
2026-07-15 20:04:04.810495+07	TLKM	5782	BID	1208	5
2026-07-15 20:04:04.810495+07	TLKM	5772	BID	1458	6
2026-07-15 20:04:04.810495+07	TLKM	5762	BID	1418	7
2026-07-15 20:04:04.810495+07	TLKM	5752	BID	1654	8
2026-07-15 20:04:04.810495+07	TLKM	5742	BID	1876	9
2026-07-15 20:04:04.810495+07	TLKM	5782	ASK	1368	5
2026-07-15 20:04:04.810495+07	TLKM	5792	ASK	1192	6
2026-07-15 20:04:04.810495+07	TLKM	5802	ASK	1380	7
2026-07-15 20:04:04.810495+07	TLKM	5812	ASK	1466	8
2026-07-15 20:04:04.810495+07	TLKM	5822	ASK	1547	9
2026-07-15 20:04:05.819656+07	TLKM	5782	BID	1020	5
2026-07-15 20:04:05.819656+07	TLKM	5772	BID	1480	6
2026-07-15 20:04:05.819656+07	TLKM	5762	BID	1418	7
2026-07-15 20:04:05.819656+07	TLKM	5752	BID	1691	8
2026-07-15 20:04:05.819656+07	TLKM	5742	BID	1541	9
2026-07-15 20:04:05.819656+07	TLKM	5782	ASK	1305	5
2026-07-15 20:04:05.819656+07	TLKM	5792	ASK	1316	6
2026-07-15 20:04:05.819656+07	TLKM	5802	ASK	1660	7
2026-07-15 20:04:05.819656+07	TLKM	5812	ASK	1425	8
2026-07-15 20:04:05.819656+07	TLKM	5822	ASK	1674	9
2026-07-15 20:04:06.829578+07	TLKM	5782	BID	1259	5
2026-07-15 20:04:06.829578+07	TLKM	5772	BID	1515	6
2026-07-15 20:04:06.829578+07	TLKM	5762	BID	1300	7
2026-07-15 20:04:06.829578+07	TLKM	5752	BID	1426	8
2026-07-15 20:04:06.829578+07	TLKM	5742	BID	1421	9
2026-07-15 20:04:06.829578+07	TLKM	5782	ASK	1209	5
2026-07-15 20:04:06.829578+07	TLKM	5792	ASK	1376	6
2026-07-15 20:04:06.829578+07	TLKM	5802	ASK	1659	7
2026-07-15 20:04:06.829578+07	TLKM	5812	ASK	1321	8
2026-07-15 20:04:06.829578+07	TLKM	5822	ASK	1554	9
2026-07-15 20:04:07.839757+07	TLKM	5782	BID	1100	5
2026-07-15 20:04:07.839757+07	TLKM	5772	BID	1276	6
2026-07-15 20:04:07.839757+07	TLKM	5762	BID	1411	7
2026-07-15 20:04:07.839757+07	TLKM	5752	BID	1764	8
2026-07-15 20:04:07.839757+07	TLKM	5742	BID	1883	9
2026-07-15 20:04:07.839757+07	TLKM	5782	ASK	1186	5
2026-07-15 20:04:07.839757+07	TLKM	5792	ASK	1248	6
2026-07-15 20:04:07.839757+07	TLKM	5802	ASK	1472	7
2026-07-15 20:04:07.839757+07	TLKM	5812	ASK	1588	8
2026-07-15 20:04:07.839757+07	TLKM	5822	ASK	1600	9
2026-07-15 20:04:08.844877+07	TLKM	5782	BID	1320	5
2026-07-15 20:04:08.844877+07	TLKM	5772	BID	1122	6
2026-07-15 20:04:08.844877+07	TLKM	5762	BID	1575	7
2026-07-15 20:04:08.844877+07	TLKM	5752	BID	1383	8
2026-07-15 20:04:08.844877+07	TLKM	5742	BID	1483	9
2026-07-15 20:04:08.844877+07	TLKM	5782	ASK	1265	5
2026-07-15 20:04:08.844877+07	TLKM	5792	ASK	1358	6
2026-07-15 20:04:08.844877+07	TLKM	5802	ASK	1324	7
2026-07-15 20:04:08.844877+07	TLKM	5812	ASK	1598	8
2026-07-15 20:04:08.844877+07	TLKM	5822	ASK	1787	9
2026-07-15 20:04:09.855064+07	TLKM	5782	BID	1284	5
2026-07-15 20:04:09.855064+07	TLKM	5772	BID	1430	6
2026-07-15 20:04:09.855064+07	TLKM	5762	BID	1375	7
2026-07-15 20:04:09.855064+07	TLKM	5752	BID	1520	8
2026-07-15 20:04:09.855064+07	TLKM	5742	BID	1801	9
2026-07-15 20:04:09.855064+07	TLKM	5782	ASK	1073	5
2026-07-15 20:04:09.855064+07	TLKM	5792	ASK	1353	6
2026-07-15 20:04:09.855064+07	TLKM	5802	ASK	1292	7
2026-07-15 20:04:09.855064+07	TLKM	5812	ASK	1309	8
2026-07-15 20:04:09.855064+07	TLKM	5822	ASK	1857	9
2026-07-15 20:04:10.859957+07	TLKM	5782	BID	52461	5
2026-07-15 20:04:10.859957+07	TLKM	5772	BID	1406	6
2026-07-15 20:04:10.859957+07	TLKM	5762	BID	1317	7
2026-07-15 20:04:10.859957+07	TLKM	5752	BID	1754	8
2026-07-15 20:04:10.859957+07	TLKM	5742	BID	1653	9
2026-07-15 20:04:10.859957+07	TLKM	5782	ASK	1134	5
2026-07-15 20:04:10.859957+07	TLKM	5792	ASK	1263	6
2026-07-15 20:04:10.859957+07	TLKM	5802	ASK	1315	7
2026-07-15 20:04:10.859957+07	TLKM	5812	ASK	1469	8
2026-07-15 20:04:10.859957+07	TLKM	5822	ASK	1757	9
2026-07-15 20:04:11.866114+07	TLKM	5782	BID	54470	5
2026-07-15 20:04:11.866114+07	TLKM	5772	BID	1572	6
2026-07-15 20:04:11.866114+07	TLKM	5762	BID	1413	7
2026-07-15 20:04:11.866114+07	TLKM	5752	BID	1659	8
2026-07-15 20:04:11.866114+07	TLKM	5742	BID	1874	9
2026-07-15 20:04:11.866114+07	TLKM	5782	ASK	1383	5
2026-07-15 20:04:11.866114+07	TLKM	5792	ASK	1501	6
2026-07-15 20:04:11.866114+07	TLKM	5802	ASK	1523	7
2026-07-15 20:04:11.866114+07	TLKM	5812	ASK	1474	8
2026-07-15 20:04:11.866114+07	TLKM	5822	ASK	1672	9
2026-07-15 20:04:12.875893+07	TLKM	5782	BID	53922	5
2026-07-15 20:04:12.875893+07	TLKM	5772	BID	1253	6
2026-07-15 20:04:12.875893+07	TLKM	5762	BID	1581	7
2026-07-15 20:04:12.875893+07	TLKM	5752	BID	1672	8
2026-07-15 20:04:12.875893+07	TLKM	5742	BID	1770	9
2026-07-15 20:04:12.875893+07	TLKM	5782	ASK	1350	5
2026-07-15 20:04:12.875893+07	TLKM	5792	ASK	1219	6
2026-07-15 20:04:12.875893+07	TLKM	5802	ASK	1345	7
2026-07-15 20:04:12.875893+07	TLKM	5812	ASK	1498	8
2026-07-15 20:04:12.875893+07	TLKM	5822	ASK	1580	9
2026-07-15 20:04:13.882137+07	TLKM	5782	BID	52414	5
2026-07-15 20:04:13.882137+07	TLKM	5772	BID	1135	6
2026-07-15 20:04:13.882137+07	TLKM	5762	BID	1418	7
2026-07-15 20:04:13.882137+07	TLKM	5752	BID	1676	8
2026-07-15 20:04:13.882137+07	TLKM	5742	BID	1486	9
2026-07-15 20:04:13.882137+07	TLKM	5782	ASK	1252	5
2026-07-15 20:04:13.882137+07	TLKM	5792	ASK	1467	6
2026-07-15 20:04:13.882137+07	TLKM	5802	ASK	1424	7
2026-07-15 20:04:13.882137+07	TLKM	5812	ASK	1387	8
2026-07-15 20:04:13.882137+07	TLKM	5822	ASK	1421	9
2026-07-15 20:04:14.892084+07	TLKM	5782	BID	55344	5
2026-07-15 20:04:14.892084+07	TLKM	5772	BID	1503	6
2026-07-15 20:04:14.892084+07	TLKM	5762	BID	1520	7
2026-07-15 20:04:14.892084+07	TLKM	5752	BID	1357	8
2026-07-15 20:04:14.892084+07	TLKM	5742	BID	1840	9
2026-07-15 20:04:14.892084+07	TLKM	5782	ASK	1150	5
2026-07-15 20:04:14.892084+07	TLKM	5792	ASK	1504	6
2026-07-15 20:04:14.892084+07	TLKM	5802	ASK	1477	7
2026-07-15 20:04:14.892084+07	TLKM	5812	ASK	1348	8
2026-07-15 20:04:14.892084+07	TLKM	5822	ASK	1893	9
2026-07-15 20:04:15.898453+07	TLKM	5782	BID	52786	5
2026-07-15 20:04:15.898453+07	TLKM	5772	BID	1141	6
2026-07-15 20:04:15.898453+07	TLKM	5762	BID	1375	7
2026-07-15 20:04:15.898453+07	TLKM	5752	BID	1385	8
2026-07-15 20:04:15.898453+07	TLKM	5742	BID	1672	9
2026-07-15 20:04:15.898453+07	TLKM	5782	ASK	1423	5
2026-07-15 20:04:15.898453+07	TLKM	5792	ASK	1180	6
2026-07-15 20:04:15.898453+07	TLKM	5802	ASK	1359	7
2026-07-15 20:04:15.898453+07	TLKM	5812	ASK	1582	8
2026-07-15 20:04:15.898453+07	TLKM	5822	ASK	1622	9
2026-07-15 20:04:16.908458+07	TLKM	5782	BID	58254	5
2026-07-15 20:04:16.908458+07	TLKM	5772	BID	1480	6
2026-07-15 20:04:16.908458+07	TLKM	5762	BID	1637	7
2026-07-15 20:04:16.908458+07	TLKM	5752	BID	1387	8
2026-07-15 20:04:16.908458+07	TLKM	5742	BID	1787	9
2026-07-15 20:04:16.908458+07	TLKM	5782	ASK	1236	5
2026-07-15 20:04:16.908458+07	TLKM	5792	ASK	1364	6
2026-07-15 20:04:16.908458+07	TLKM	5802	ASK	1390	7
2026-07-15 20:04:16.908458+07	TLKM	5812	ASK	1631	8
2026-07-15 20:04:16.908458+07	TLKM	5822	ASK	1488	9
2026-07-15 20:04:17.915942+07	TLKM	5782	BID	52792	5
2026-07-15 20:04:17.915942+07	TLKM	5772	BID	1567	6
2026-07-15 20:04:17.915942+07	TLKM	5762	BID	1441	7
2026-07-15 20:04:17.915942+07	TLKM	5752	BID	1321	8
2026-07-15 20:04:17.915942+07	TLKM	5742	BID	1741	9
2026-07-15 20:04:17.915942+07	TLKM	5782	ASK	1229	5
2026-07-15 20:04:17.915942+07	TLKM	5792	ASK	1246	6
2026-07-15 20:04:17.915942+07	TLKM	5802	ASK	1619	7
2026-07-15 20:04:17.915942+07	TLKM	5812	ASK	1796	8
2026-07-15 20:04:17.915942+07	TLKM	5822	ASK	1734	9
2026-07-15 20:04:18.92635+07	TLKM	5782	BID	51794	5
2026-07-15 20:04:18.92635+07	TLKM	5772	BID	1422	6
2026-07-15 20:04:18.92635+07	TLKM	5762	BID	1665	7
2026-07-15 20:04:18.92635+07	TLKM	5752	BID	1757	8
2026-07-15 20:04:18.92635+07	TLKM	5742	BID	1895	9
2026-07-15 20:04:18.92635+07	TLKM	5782	ASK	1214	5
2026-07-15 20:04:18.92635+07	TLKM	5792	ASK	1461	6
2026-07-15 20:04:18.92635+07	TLKM	5802	ASK	1440	7
2026-07-15 20:04:18.92635+07	TLKM	5812	ASK	1595	8
2026-07-15 20:04:18.92635+07	TLKM	5822	ASK	1736	9
2026-07-15 20:04:19.9326+07	TLKM	5782	BID	51167	5
2026-07-15 20:04:19.9326+07	TLKM	5772	BID	1373	6
2026-07-15 20:04:19.9326+07	TLKM	5762	BID	1525	7
2026-07-15 20:04:19.9326+07	TLKM	5752	BID	1594	8
2026-07-15 20:04:19.9326+07	TLKM	5742	BID	1765	9
2026-07-15 20:04:19.9326+07	TLKM	5782	ASK	1099	5
2026-07-15 20:04:19.9326+07	TLKM	5792	ASK	1104	6
2026-07-15 20:04:19.9326+07	TLKM	5802	ASK	1428	7
2026-07-15 20:04:19.9326+07	TLKM	5812	ASK	1661	8
2026-07-15 20:04:19.9326+07	TLKM	5822	ASK	1518	9
2026-07-15 20:04:20.943051+07	TLKM	5782	BID	52297	5
2026-07-15 20:04:20.943051+07	TLKM	5772	BID	1209	6
2026-07-15 20:04:20.943051+07	TLKM	5762	BID	1462	7
2026-07-15 20:04:20.943051+07	TLKM	5752	BID	1413	8
2026-07-15 20:04:20.943051+07	TLKM	5742	BID	1476	9
2026-07-15 20:04:20.943051+07	TLKM	5782	ASK	1104	5
2026-07-15 20:04:20.943051+07	TLKM	5792	ASK	1127	6
2026-07-15 20:04:20.943051+07	TLKM	5802	ASK	1460	7
2026-07-15 20:04:20.943051+07	TLKM	5812	ASK	1489	8
2026-07-15 20:04:20.943051+07	TLKM	5822	ASK	1515	9
2026-07-15 20:04:21.949626+07	TLKM	5782	BID	55862	5
2026-07-15 20:04:21.949626+07	TLKM	5772	BID	1461	6
2026-07-15 20:04:21.949626+07	TLKM	5762	BID	1227	7
2026-07-15 20:04:21.949626+07	TLKM	5752	BID	1433	8
2026-07-15 20:04:21.949626+07	TLKM	5742	BID	1793	9
2026-07-15 20:04:21.949626+07	TLKM	5782	ASK	1356	5
2026-07-15 20:04:21.949626+07	TLKM	5792	ASK	1526	6
2026-07-15 20:04:21.949626+07	TLKM	5802	ASK	1617	7
2026-07-15 20:04:21.949626+07	TLKM	5812	ASK	1640	8
2026-07-15 20:04:21.949626+07	TLKM	5822	ASK	1711	9
2026-07-15 20:04:22.960071+07	TLKM	5782	BID	55471	5
2026-07-15 20:04:22.960071+07	TLKM	5772	BID	1581	6
2026-07-15 20:04:22.960071+07	TLKM	5762	BID	1665	7
2026-07-15 20:04:22.960071+07	TLKM	5752	BID	1493	8
2026-07-15 20:04:22.960071+07	TLKM	5742	BID	1512	9
2026-07-15 20:04:22.960071+07	TLKM	5782	ASK	1413	5
2026-07-15 20:04:22.960071+07	TLKM	5792	ASK	1518	6
2026-07-15 20:04:22.960071+07	TLKM	5802	ASK	1467	7
2026-07-15 20:04:22.960071+07	TLKM	5812	ASK	1709	8
2026-07-15 20:04:22.960071+07	TLKM	5822	ASK	1893	9
2026-07-15 20:04:23.966137+07	TLKM	5782	BID	50459	5
2026-07-15 20:04:23.966137+07	TLKM	5772	BID	1336	6
2026-07-15 20:04:23.966137+07	TLKM	5762	BID	1573	7
2026-07-15 20:04:23.966137+07	TLKM	5752	BID	1495	8
2026-07-15 20:04:23.966137+07	TLKM	5742	BID	1775	9
2026-07-15 20:04:23.966137+07	TLKM	5782	ASK	1025	5
2026-07-15 20:04:23.966137+07	TLKM	5792	ASK	1214	6
2026-07-15 20:04:23.966137+07	TLKM	5802	ASK	1410	7
2026-07-15 20:04:23.966137+07	TLKM	5812	ASK	1352	8
2026-07-15 20:04:23.966137+07	TLKM	5822	ASK	1425	9
2026-07-15 20:04:24.976472+07	TLKM	5782	BID	50983	5
2026-07-15 20:04:24.976472+07	TLKM	5772	BID	1279	6
2026-07-15 20:04:24.976472+07	TLKM	5762	BID	1626	7
2026-07-15 20:04:24.976472+07	TLKM	5752	BID	1740	8
2026-07-15 20:04:24.976472+07	TLKM	5742	BID	1831	9
2026-07-15 20:04:24.976472+07	TLKM	5782	ASK	1207	5
2026-07-15 20:04:24.976472+07	TLKM	5792	ASK	1258	6
2026-07-15 20:04:24.976472+07	TLKM	5802	ASK	1335	7
2026-07-15 20:04:24.976472+07	TLKM	5812	ASK	1548	8
2026-07-15 20:04:24.976472+07	TLKM	5822	ASK	1419	9
2026-07-15 20:04:25.984226+07	TLKM	5782	BID	55286	5
2026-07-15 20:04:25.984226+07	TLKM	5772	BID	1116	6
2026-07-15 20:04:25.984226+07	TLKM	5762	BID	1429	7
2026-07-15 20:04:25.984226+07	TLKM	5752	BID	1666	8
2026-07-15 20:04:25.984226+07	TLKM	5742	BID	1484	9
2026-07-15 20:04:25.984226+07	TLKM	5782	ASK	1438	5
2026-07-15 20:04:25.984226+07	TLKM	5792	ASK	1245	6
2026-07-15 20:04:25.984226+07	TLKM	5802	ASK	1367	7
2026-07-15 20:04:25.984226+07	TLKM	5812	ASK	1519	8
2026-07-15 20:04:25.984226+07	TLKM	5822	ASK	1413	9
2026-07-15 20:04:26.992784+07	TLKM	5782	BID	59725	5
2026-07-15 20:04:26.992784+07	TLKM	5772	BID	1258	6
2026-07-15 20:04:26.992784+07	TLKM	5762	BID	1626	7
2026-07-15 20:04:26.992784+07	TLKM	5752	BID	1414	8
2026-07-15 20:04:26.992784+07	TLKM	5742	BID	1464	9
2026-07-15 20:04:26.992784+07	TLKM	5782	ASK	1098	5
2026-07-15 20:04:26.992784+07	TLKM	5792	ASK	1582	6
2026-07-15 20:04:26.992784+07	TLKM	5802	ASK	1466	7
2026-07-15 20:04:26.992784+07	TLKM	5812	ASK	1458	8
2026-07-15 20:04:26.992784+07	TLKM	5822	ASK	1871	9
2026-07-15 20:04:27.996633+07	TLKM	5782	BID	53241	5
2026-07-15 20:04:27.996633+07	TLKM	5772	BID	1471	6
2026-07-15 20:04:27.996633+07	TLKM	5762	BID	1405	7
2026-07-15 20:04:27.996633+07	TLKM	5752	BID	1637	8
2026-07-15 20:04:27.996633+07	TLKM	5742	BID	1791	9
2026-07-15 20:04:27.996633+07	TLKM	5782	ASK	1200	5
2026-07-15 20:04:27.996633+07	TLKM	5792	ASK	1172	6
2026-07-15 20:04:27.996633+07	TLKM	5802	ASK	1550	7
2026-07-15 20:04:27.996633+07	TLKM	5812	ASK	1596	8
2026-07-15 20:04:27.996633+07	TLKM	5822	ASK	1495	9
2026-07-15 20:04:29.006735+07	TLKM	5782	BID	59653	5
2026-07-15 20:04:29.006735+07	TLKM	5772	BID	1388	6
2026-07-15 20:04:29.006735+07	TLKM	5762	BID	1696	7
2026-07-15 20:04:29.006735+07	TLKM	5752	BID	1330	8
2026-07-15 20:04:29.006735+07	TLKM	5742	BID	1468	9
2026-07-15 20:04:29.006735+07	TLKM	5782	ASK	1198	5
2026-07-15 20:04:29.006735+07	TLKM	5792	ASK	1295	6
2026-07-15 20:04:29.006735+07	TLKM	5802	ASK	1203	7
2026-07-15 20:04:29.006735+07	TLKM	5812	ASK	1765	8
2026-07-15 20:04:29.006735+07	TLKM	5822	ASK	1541	9
2026-07-15 20:04:30.010992+07	TLKM	5782	BID	56127	5
2026-07-15 20:04:30.010992+07	TLKM	5772	BID	1292	6
2026-07-15 20:04:30.010992+07	TLKM	5762	BID	1698	7
2026-07-15 20:04:30.010992+07	TLKM	5752	BID	1717	8
2026-07-15 20:04:30.010992+07	TLKM	5742	BID	1510	9
2026-07-15 20:04:30.010992+07	TLKM	5782	ASK	1111	5
2026-07-15 20:04:30.010992+07	TLKM	5792	ASK	1296	6
2026-07-15 20:04:30.010992+07	TLKM	5802	ASK	1439	7
2026-07-15 20:04:30.010992+07	TLKM	5812	ASK	1453	8
2026-07-15 20:04:30.010992+07	TLKM	5822	ASK	1624	9
2026-07-15 20:04:31.016717+07	TLKM	5782	BID	58821	5
2026-07-15 20:04:31.016717+07	TLKM	5772	BID	1192	6
2026-07-15 20:04:31.016717+07	TLKM	5762	BID	1599	7
2026-07-15 20:04:31.016717+07	TLKM	5752	BID	1485	8
2026-07-15 20:04:31.016717+07	TLKM	5742	BID	1581	9
2026-07-15 20:04:31.016717+07	TLKM	5782	ASK	1189	5
2026-07-15 20:04:31.016717+07	TLKM	5792	ASK	1499	6
2026-07-15 20:04:31.016717+07	TLKM	5802	ASK	1328	7
2026-07-15 20:04:31.016717+07	TLKM	5812	ASK	1348	8
2026-07-15 20:04:31.016717+07	TLKM	5822	ASK	1827	9
2026-07-15 20:04:32.026637+07	TLKM	5782	BID	50275	5
2026-07-15 20:04:32.026637+07	TLKM	5772	BID	1177	6
2026-07-15 20:04:32.026637+07	TLKM	5762	BID	1524	7
2026-07-15 20:04:32.026637+07	TLKM	5752	BID	1654	8
2026-07-15 20:04:32.026637+07	TLKM	5742	BID	1733	9
2026-07-15 20:04:32.026637+07	TLKM	5782	ASK	1415	5
2026-07-15 20:04:32.026637+07	TLKM	5792	ASK	1482	6
2026-07-15 20:04:32.026637+07	TLKM	5802	ASK	1685	7
2026-07-15 20:04:32.026637+07	TLKM	5812	ASK	1466	8
2026-07-15 20:04:32.026637+07	TLKM	5822	ASK	1819	9
2026-07-15 20:04:33.032349+07	TLKM	5782	BID	59423	5
2026-07-15 20:04:33.032349+07	TLKM	5772	BID	1383	6
2026-07-15 20:04:33.032349+07	TLKM	5762	BID	1337	7
2026-07-15 20:04:33.032349+07	TLKM	5752	BID	1690	8
2026-07-15 20:04:33.032349+07	TLKM	5742	BID	1858	9
2026-07-15 20:04:33.032349+07	TLKM	5782	ASK	1059	5
2026-07-15 20:04:33.032349+07	TLKM	5792	ASK	1358	6
2026-07-15 20:04:33.032349+07	TLKM	5802	ASK	1306	7
2026-07-15 20:04:33.032349+07	TLKM	5812	ASK	1392	8
2026-07-15 20:04:33.032349+07	TLKM	5822	ASK	1458	9
2026-07-15 20:04:34.042459+07	TLKM	5782	BID	53066	5
2026-07-15 20:04:34.042459+07	TLKM	5772	BID	1280	6
2026-07-15 20:04:34.042459+07	TLKM	5762	BID	1478	7
2026-07-15 20:04:34.042459+07	TLKM	5752	BID	1416	8
2026-07-15 20:04:34.042459+07	TLKM	5742	BID	1693	9
2026-07-15 20:04:34.042459+07	TLKM	5782	ASK	1404	5
2026-07-15 20:04:34.042459+07	TLKM	5792	ASK	1548	6
2026-07-15 20:04:34.042459+07	TLKM	5802	ASK	1349	7
2026-07-15 20:04:34.042459+07	TLKM	5812	ASK	1797	8
2026-07-15 20:04:34.042459+07	TLKM	5822	ASK	1848	9
2026-07-15 20:04:35.050982+07	TLKM	5782	BID	58881	5
2026-07-15 20:04:35.050982+07	TLKM	5772	BID	1212	6
2026-07-15 20:04:35.050982+07	TLKM	5762	BID	1438	7
2026-07-15 20:04:35.050982+07	TLKM	5752	BID	1409	8
2026-07-15 20:04:35.050982+07	TLKM	5742	BID	1878	9
2026-07-15 20:04:35.050982+07	TLKM	5782	ASK	1004	5
2026-07-15 20:04:35.050982+07	TLKM	5792	ASK	1443	6
2026-07-15 20:04:35.050982+07	TLKM	5802	ASK	1227	7
2026-07-15 20:04:35.050982+07	TLKM	5812	ASK	1471	8
2026-07-15 20:04:35.050982+07	TLKM	5822	ASK	1489	9
2026-07-15 20:04:36.05973+07	TLKM	5782	BID	53904	5
2026-07-15 20:04:36.05973+07	TLKM	5772	BID	1200	6
2026-07-15 20:04:36.05973+07	TLKM	5762	BID	1605	7
2026-07-15 20:04:36.05973+07	TLKM	5752	BID	1359	8
2026-07-15 20:04:36.05973+07	TLKM	5742	BID	1570	9
2026-07-15 20:04:36.05973+07	TLKM	5782	ASK	1483	5
2026-07-15 20:04:36.05973+07	TLKM	5792	ASK	1219	6
2026-07-15 20:04:36.05973+07	TLKM	5802	ASK	1528	7
2026-07-15 20:04:36.05973+07	TLKM	5812	ASK	1695	8
2026-07-15 20:04:36.05973+07	TLKM	5822	ASK	1721	9
2026-07-15 20:04:37.065637+07	TLKM	5782	BID	57785	5
2026-07-15 20:04:37.065637+07	TLKM	5772	BID	1249	6
2026-07-15 20:04:37.065637+07	TLKM	5762	BID	1626	7
2026-07-15 20:04:37.065637+07	TLKM	5752	BID	1674	8
2026-07-15 20:04:37.065637+07	TLKM	5742	BID	1791	9
2026-07-15 20:04:37.065637+07	TLKM	5782	ASK	1086	5
2026-07-15 20:04:37.065637+07	TLKM	5792	ASK	1152	6
2026-07-15 20:04:37.065637+07	TLKM	5802	ASK	1331	7
2026-07-15 20:04:37.065637+07	TLKM	5812	ASK	1339	8
2026-07-15 20:04:37.065637+07	TLKM	5822	ASK	1571	9
2026-07-15 20:04:38.07523+07	TLKM	5782	BID	53159	5
2026-07-15 20:04:38.07523+07	TLKM	5772	BID	1317	6
2026-07-15 20:04:38.07523+07	TLKM	5762	BID	1558	7
2026-07-15 20:04:38.07523+07	TLKM	5752	BID	1483	8
2026-07-15 20:04:38.07523+07	TLKM	5742	BID	1694	9
2026-07-15 20:04:38.07523+07	TLKM	5782	ASK	1344	5
2026-07-15 20:04:38.07523+07	TLKM	5792	ASK	1218	6
2026-07-15 20:04:38.07523+07	TLKM	5802	ASK	1301	7
2026-07-15 20:04:38.07523+07	TLKM	5812	ASK	1333	8
2026-07-15 20:04:38.07523+07	TLKM	5822	ASK	1695	9
2026-07-15 20:04:39.079908+07	TLKM	5782	BID	55454	5
2026-07-15 20:04:39.079908+07	TLKM	5772	BID	1229	6
2026-07-15 20:04:39.079908+07	TLKM	5762	BID	1475	7
2026-07-15 20:04:39.079908+07	TLKM	5752	BID	1647	8
2026-07-15 20:04:39.079908+07	TLKM	5742	BID	1750	9
2026-07-15 20:04:39.079908+07	TLKM	5782	ASK	1042	5
2026-07-15 20:04:39.079908+07	TLKM	5792	ASK	1585	6
2026-07-15 20:04:39.079908+07	TLKM	5802	ASK	1423	7
2026-07-15 20:04:39.079908+07	TLKM	5812	ASK	1775	8
2026-07-15 20:04:39.079908+07	TLKM	5822	ASK	1774	9
2026-07-15 20:04:40.091048+07	TLKM	5782	BID	52066	5
2026-07-15 20:04:40.091048+07	TLKM	5772	BID	1330	6
2026-07-15 20:04:40.091048+07	TLKM	5762	BID	1319	7
2026-07-15 20:04:40.091048+07	TLKM	5752	BID	1328	8
2026-07-15 20:04:40.091048+07	TLKM	5742	BID	1485	9
2026-07-15 20:04:40.091048+07	TLKM	5782	ASK	1350	5
2026-07-15 20:04:40.091048+07	TLKM	5792	ASK	1558	6
2026-07-15 20:04:40.091048+07	TLKM	5802	ASK	1250	7
2026-07-15 20:04:40.091048+07	TLKM	5812	ASK	1640	8
2026-07-15 20:04:40.091048+07	TLKM	5822	ASK	1608	9
2026-07-15 20:04:41.096089+07	TLKM	5782	BID	55022	5
2026-07-15 20:04:41.096089+07	TLKM	5772	BID	1468	6
2026-07-15 20:04:41.096089+07	TLKM	5762	BID	1565	7
2026-07-15 20:04:41.096089+07	TLKM	5752	BID	1786	8
2026-07-15 20:04:41.096089+07	TLKM	5742	BID	1623	9
2026-07-15 20:04:41.096089+07	TLKM	5782	ASK	1181	5
2026-07-15 20:04:41.096089+07	TLKM	5792	ASK	1447	6
2026-07-15 20:04:41.096089+07	TLKM	5802	ASK	1673	7
2026-07-15 20:04:41.096089+07	TLKM	5812	ASK	1454	8
2026-07-15 20:04:41.096089+07	TLKM	5822	ASK	1505	9
2026-07-15 20:04:42.106993+07	TLKM	5782	BID	53736	5
2026-07-15 20:04:42.106993+07	TLKM	5772	BID	1174	6
2026-07-15 20:04:42.106993+07	TLKM	5762	BID	1562	7
2026-07-15 20:04:42.106993+07	TLKM	5752	BID	1501	8
2026-07-15 20:04:42.106993+07	TLKM	5742	BID	1663	9
2026-07-15 20:04:42.106993+07	TLKM	5782	ASK	1035	5
2026-07-15 20:04:42.106993+07	TLKM	5792	ASK	1117	6
2026-07-15 20:04:42.106993+07	TLKM	5802	ASK	1491	7
2026-07-15 20:04:42.106993+07	TLKM	5812	ASK	1490	8
2026-07-15 20:04:42.106993+07	TLKM	5822	ASK	1431	9
2026-07-15 20:04:43.113411+07	TLKM	5782	BID	53804	5
2026-07-15 20:04:43.113411+07	TLKM	5772	BID	1276	6
2026-07-15 20:04:43.113411+07	TLKM	5762	BID	1244	7
2026-07-15 20:04:43.113411+07	TLKM	5752	BID	1589	8
2026-07-15 20:04:43.113411+07	TLKM	5742	BID	1641	9
2026-07-15 20:04:43.113411+07	TLKM	5782	ASK	1256	5
2026-07-15 20:04:43.113411+07	TLKM	5792	ASK	1413	6
2026-07-15 20:04:43.113411+07	TLKM	5802	ASK	1237	7
2026-07-15 20:04:43.113411+07	TLKM	5812	ASK	1521	8
2026-07-15 20:04:43.113411+07	TLKM	5822	ASK	1483	9
2026-07-15 20:04:44.123716+07	TLKM	5782	BID	59684	5
2026-07-15 20:04:44.123716+07	TLKM	5772	BID	1372	6
2026-07-15 20:04:44.123716+07	TLKM	5762	BID	1206	7
2026-07-15 20:04:44.123716+07	TLKM	5752	BID	1312	8
2026-07-15 20:04:44.123716+07	TLKM	5742	BID	1653	9
2026-07-15 20:04:44.123716+07	TLKM	5782	ASK	1132	5
2026-07-15 20:04:44.123716+07	TLKM	5792	ASK	1439	6
2026-07-15 20:04:44.123716+07	TLKM	5802	ASK	1369	7
2026-07-15 20:04:44.123716+07	TLKM	5812	ASK	1503	8
2026-07-15 20:04:44.123716+07	TLKM	5822	ASK	1551	9
2026-07-15 20:04:45.128798+07	TLKM	5782	BID	54897	5
2026-07-15 20:04:45.128798+07	TLKM	5772	BID	1134	6
2026-07-15 20:04:45.128798+07	TLKM	5762	BID	1479	7
2026-07-15 20:04:45.128798+07	TLKM	5752	BID	1458	8
2026-07-15 20:04:45.128798+07	TLKM	5742	BID	1758	9
2026-07-15 20:04:45.128798+07	TLKM	5782	ASK	1417	5
2026-07-15 20:04:45.128798+07	TLKM	5792	ASK	1175	6
2026-07-15 20:04:45.128798+07	TLKM	5802	ASK	1695	7
2026-07-15 20:04:45.128798+07	TLKM	5812	ASK	1474	8
2026-07-15 20:04:45.128798+07	TLKM	5822	ASK	1898	9
2026-07-15 20:04:46.137018+07	TLKM	5782	BID	57444	5
2026-07-15 20:04:46.137018+07	TLKM	5772	BID	1520	6
2026-07-15 20:04:46.137018+07	TLKM	5762	BID	1277	7
2026-07-15 20:04:46.137018+07	TLKM	5752	BID	1549	8
2026-07-15 20:04:46.137018+07	TLKM	5742	BID	1776	9
2026-07-15 20:04:46.137018+07	TLKM	5782	ASK	1267	5
2026-07-15 20:04:46.137018+07	TLKM	5792	ASK	1418	6
2026-07-15 20:04:46.137018+07	TLKM	5802	ASK	1335	7
2026-07-15 20:04:46.137018+07	TLKM	5812	ASK	1495	8
2026-07-15 20:04:46.137018+07	TLKM	5822	ASK	1785	9
2026-07-15 20:04:47.143891+07	TLKM	5782	BID	54702	5
2026-07-15 20:04:47.143891+07	TLKM	5772	BID	1124	6
2026-07-15 20:04:47.143891+07	TLKM	5762	BID	1334	7
2026-07-15 20:04:47.143891+07	TLKM	5752	BID	1523	8
2026-07-15 20:04:47.143891+07	TLKM	5742	BID	1538	9
2026-07-15 20:04:47.143891+07	TLKM	5782	ASK	1120	5
2026-07-15 20:04:47.143891+07	TLKM	5792	ASK	1308	6
2026-07-15 20:04:47.143891+07	TLKM	5802	ASK	1466	7
2026-07-15 20:04:47.143891+07	TLKM	5812	ASK	1452	8
2026-07-15 20:04:47.143891+07	TLKM	5822	ASK	1679	9
2026-07-15 20:04:48.149934+07	TLKM	5782	BID	59390	5
2026-07-15 20:04:48.149934+07	TLKM	5772	BID	1414	6
2026-07-15 20:04:48.149934+07	TLKM	5762	BID	1366	7
2026-07-15 20:04:48.149934+07	TLKM	5752	BID	1537	8
2026-07-15 20:04:48.149934+07	TLKM	5742	BID	1511	9
2026-07-15 20:04:48.149934+07	TLKM	5782	ASK	1315	5
2026-07-15 20:04:48.149934+07	TLKM	5792	ASK	1365	6
2026-07-15 20:04:48.149934+07	TLKM	5802	ASK	1211	7
2026-07-15 20:04:48.149934+07	TLKM	5812	ASK	1323	8
2026-07-15 20:04:48.149934+07	TLKM	5822	ASK	1792	9
2026-07-15 20:04:49.160774+07	TLKM	5782	BID	53170	5
2026-07-15 20:04:49.160774+07	TLKM	5772	BID	1272	6
2026-07-15 20:04:49.160774+07	TLKM	5762	BID	1553	7
2026-07-15 20:04:49.160774+07	TLKM	5752	BID	1518	8
2026-07-15 20:04:49.160774+07	TLKM	5742	BID	1742	9
2026-07-15 20:04:49.160774+07	TLKM	5782	ASK	1304	5
2026-07-15 20:04:49.160774+07	TLKM	5792	ASK	1298	6
2026-07-15 20:04:49.160774+07	TLKM	5802	ASK	1252	7
2026-07-15 20:04:49.160774+07	TLKM	5812	ASK	1459	8
2026-07-15 20:04:49.160774+07	TLKM	5822	ASK	1767	9
2026-07-15 20:04:50.170467+07	TLKM	5782	BID	56354	5
2026-07-15 20:04:50.170467+07	TLKM	5772	BID	1497	6
2026-07-15 20:04:50.170467+07	TLKM	5762	BID	1538	7
2026-07-15 20:04:50.170467+07	TLKM	5752	BID	1384	8
2026-07-15 20:04:50.170467+07	TLKM	5742	BID	1712	9
2026-07-15 20:04:50.170467+07	TLKM	5782	ASK	1343	5
2026-07-15 20:04:50.170467+07	TLKM	5792	ASK	1390	6
2026-07-15 20:04:50.170467+07	TLKM	5802	ASK	1365	7
2026-07-15 20:04:50.170467+07	TLKM	5812	ASK	1375	8
2026-07-15 20:04:50.170467+07	TLKM	5822	ASK	1730	9
2026-07-15 20:04:51.177239+07	TLKM	5782	BID	52029	5
2026-07-15 20:04:51.177239+07	TLKM	5772	BID	1293	6
2026-07-15 20:04:51.177239+07	TLKM	5762	BID	1417	7
2026-07-15 20:04:51.177239+07	TLKM	5752	BID	1640	8
2026-07-15 20:04:51.177239+07	TLKM	5742	BID	1410	9
2026-07-15 20:04:51.177239+07	TLKM	5782	ASK	1328	5
2026-07-15 20:04:51.177239+07	TLKM	5792	ASK	1197	6
2026-07-15 20:04:51.177239+07	TLKM	5802	ASK	1568	7
2026-07-15 20:04:51.177239+07	TLKM	5812	ASK	1569	8
2026-07-15 20:04:51.177239+07	TLKM	5822	ASK	1793	9
2026-07-15 20:04:52.18133+07	TLKM	5782	BID	51741	5
2026-07-15 20:04:52.18133+07	TLKM	5772	BID	1421	6
2026-07-15 20:04:52.18133+07	TLKM	5762	BID	1245	7
2026-07-15 20:04:52.18133+07	TLKM	5752	BID	1695	8
2026-07-15 20:04:52.18133+07	TLKM	5742	BID	1667	9
2026-07-15 20:04:52.18133+07	TLKM	5782	ASK	1455	5
2026-07-15 20:04:52.18133+07	TLKM	5792	ASK	1367	6
2026-07-15 20:04:52.18133+07	TLKM	5802	ASK	1572	7
2026-07-15 20:04:52.18133+07	TLKM	5812	ASK	1589	8
2026-07-15 20:04:52.18133+07	TLKM	5822	ASK	1667	9
2026-07-15 20:04:53.192757+07	TLKM	5782	BID	58265	5
2026-07-15 20:04:53.192757+07	TLKM	5772	BID	1172	6
2026-07-15 20:04:53.192757+07	TLKM	5762	BID	1673	7
2026-07-15 20:04:53.192757+07	TLKM	5752	BID	1484	8
2026-07-15 20:04:53.192757+07	TLKM	5742	BID	1792	9
2026-07-15 20:04:53.192757+07	TLKM	5782	ASK	1384	5
2026-07-15 20:04:53.192757+07	TLKM	5792	ASK	1371	6
2026-07-15 20:04:53.192757+07	TLKM	5802	ASK	1325	7
2026-07-15 20:04:53.192757+07	TLKM	5812	ASK	1708	8
2026-07-15 20:04:53.192757+07	TLKM	5822	ASK	1705	9
2026-07-15 20:04:54.200617+07	TLKM	5782	BID	56271	5
2026-07-15 20:04:54.200617+07	TLKM	5772	BID	1420	6
2026-07-15 20:04:54.200617+07	TLKM	5762	BID	1474	7
2026-07-15 20:04:54.200617+07	TLKM	5752	BID	1767	8
2026-07-15 20:04:54.200617+07	TLKM	5742	BID	1689	9
2026-07-15 20:04:54.200617+07	TLKM	5782	ASK	1148	5
2026-07-15 20:04:54.200617+07	TLKM	5792	ASK	1164	6
2026-07-15 20:04:54.200617+07	TLKM	5802	ASK	1248	7
2026-07-15 20:04:54.200617+07	TLKM	5812	ASK	1497	8
2026-07-15 20:04:54.200617+07	TLKM	5822	ASK	1444	9
2026-07-15 20:04:55.211005+07	TLKM	5782	BID	59942	5
2026-07-15 20:04:55.211005+07	TLKM	5772	BID	1437	6
2026-07-15 20:04:55.211005+07	TLKM	5762	BID	1347	7
2026-07-15 20:04:55.211005+07	TLKM	5752	BID	1705	8
2026-07-15 20:04:55.211005+07	TLKM	5742	BID	1861	9
2026-07-15 20:04:55.211005+07	TLKM	5782	ASK	1052	5
2026-07-15 20:04:55.211005+07	TLKM	5792	ASK	1323	6
2026-07-15 20:04:55.211005+07	TLKM	5802	ASK	1592	7
2026-07-15 20:04:55.211005+07	TLKM	5812	ASK	1683	8
2026-07-15 20:04:55.211005+07	TLKM	5822	ASK	1832	9
2026-07-15 20:04:56.217874+07	TLKM	5782	BID	52136	5
2026-07-15 20:04:56.217874+07	TLKM	5772	BID	1141	6
2026-07-15 20:04:56.217874+07	TLKM	5762	BID	1262	7
2026-07-15 20:04:56.217874+07	TLKM	5752	BID	1726	8
2026-07-15 20:04:56.217874+07	TLKM	5742	BID	1822	9
2026-07-15 20:04:56.217874+07	TLKM	5782	ASK	1000	5
2026-07-15 20:04:56.217874+07	TLKM	5792	ASK	1422	6
2026-07-15 20:04:56.217874+07	TLKM	5802	ASK	1520	7
2026-07-15 20:04:56.217874+07	TLKM	5812	ASK	1308	8
2026-07-15 20:04:56.217874+07	TLKM	5822	ASK	1728	9
2026-07-15 20:04:57.22756+07	TLKM	5782	BID	57722	5
2026-07-15 20:04:57.22756+07	TLKM	5772	BID	1448	6
2026-07-15 20:04:57.22756+07	TLKM	5762	BID	1566	7
2026-07-15 20:04:57.22756+07	TLKM	5752	BID	1462	8
2026-07-15 20:04:57.22756+07	TLKM	5742	BID	1590	9
2026-07-15 20:04:57.22756+07	TLKM	5782	ASK	1040	5
2026-07-15 20:04:57.22756+07	TLKM	5792	ASK	1410	6
2026-07-15 20:04:57.22756+07	TLKM	5802	ASK	1265	7
2026-07-15 20:04:57.22756+07	TLKM	5812	ASK	1735	8
2026-07-15 20:04:57.22756+07	TLKM	5822	ASK	1611	9
2026-07-15 20:04:58.233675+07	TLKM	5782	BID	58713	5
2026-07-15 20:04:58.233675+07	TLKM	5772	BID	1105	6
2026-07-15 20:04:58.233675+07	TLKM	5762	BID	1207	7
2026-07-15 20:04:58.233675+07	TLKM	5752	BID	1394	8
2026-07-15 20:04:58.233675+07	TLKM	5742	BID	1429	9
2026-07-15 20:04:58.233675+07	TLKM	5782	ASK	1497	5
2026-07-15 20:04:58.233675+07	TLKM	5792	ASK	1290	6
2026-07-15 20:04:58.233675+07	TLKM	5802	ASK	1269	7
2026-07-15 20:04:58.233675+07	TLKM	5812	ASK	1491	8
2026-07-15 20:04:58.233675+07	TLKM	5822	ASK	1449	9
2026-07-15 20:04:59.243573+07	TLKM	5782	BID	50439	5
2026-07-15 20:04:59.243573+07	TLKM	5772	BID	1347	6
2026-07-15 20:04:59.243573+07	TLKM	5762	BID	1353	7
2026-07-15 20:04:59.243573+07	TLKM	5752	BID	1526	8
2026-07-15 20:04:59.243573+07	TLKM	5742	BID	1590	9
2026-07-15 20:04:59.243573+07	TLKM	5782	ASK	1407	5
2026-07-15 20:04:59.243573+07	TLKM	5792	ASK	1592	6
2026-07-15 20:04:59.243573+07	TLKM	5802	ASK	1283	7
2026-07-15 20:04:59.243573+07	TLKM	5812	ASK	1347	8
2026-07-15 20:04:59.243573+07	TLKM	5822	ASK	1551	9
2026-07-15 20:03:20.702329+07	ASII	2073	BID	1051	5
2026-07-15 20:03:20.702329+07	ASII	2063	BID	1184	6
2026-07-15 20:03:20.702329+07	ASII	2053	BID	1304	7
2026-07-15 20:03:20.702329+07	ASII	2043	BID	1553	8
2026-07-15 20:03:20.702329+07	ASII	2033	BID	1786	9
2026-07-15 20:03:20.702329+07	ASII	2073	ASK	1375	5
2026-07-15 20:03:20.702329+07	ASII	2083	ASK	1458	6
2026-07-15 20:03:20.702329+07	ASII	2093	ASK	1537	7
2026-07-15 20:03:20.702329+07	ASII	2103	ASK	1700	8
2026-07-15 20:03:20.702329+07	ASII	2113	ASK	1591	9
2026-07-15 20:03:21.713392+07	ASII	2073	BID	1013	5
2026-07-15 20:03:21.713392+07	ASII	2063	BID	1445	6
2026-07-15 20:03:21.713392+07	ASII	2053	BID	1455	7
2026-07-15 20:03:21.713392+07	ASII	2043	BID	1675	8
2026-07-15 20:03:21.713392+07	ASII	2033	BID	1814	9
2026-07-15 20:03:21.713392+07	ASII	2073	ASK	1282	5
2026-07-15 20:03:21.713392+07	ASII	2083	ASK	1368	6
2026-07-15 20:03:21.713392+07	ASII	2093	ASK	1535	7
2026-07-15 20:03:21.713392+07	ASII	2103	ASK	1799	8
2026-07-15 20:03:21.713392+07	ASII	2113	ASK	1849	9
2026-07-15 20:03:22.719582+07	ASII	2073	BID	1388	5
2026-07-15 20:03:22.719582+07	ASII	2063	BID	1233	6
2026-07-15 20:03:22.719582+07	ASII	2053	BID	1237	7
2026-07-15 20:03:22.719582+07	ASII	2043	BID	1792	8
2026-07-15 20:03:22.719582+07	ASII	2033	BID	1751	9
2026-07-15 20:03:22.719582+07	ASII	2073	ASK	1097	5
2026-07-15 20:03:22.719582+07	ASII	2083	ASK	1166	6
2026-07-15 20:03:22.719582+07	ASII	2093	ASK	1528	7
2026-07-15 20:03:22.719582+07	ASII	2103	ASK	1754	8
2026-07-15 20:03:22.719582+07	ASII	2113	ASK	1707	9
2026-07-15 20:03:23.727823+07	ASII	2073	BID	1179	5
2026-07-15 20:03:23.727823+07	ASII	2063	BID	1518	6
2026-07-15 20:03:23.727823+07	ASII	2053	BID	1396	7
2026-07-15 20:03:23.727823+07	ASII	2043	BID	1708	8
2026-07-15 20:03:23.727823+07	ASII	2033	BID	1526	9
2026-07-15 20:03:23.727823+07	ASII	2073	ASK	1150	5
2026-07-15 20:03:23.727823+07	ASII	2083	ASK	1190	6
2026-07-15 20:03:23.727823+07	ASII	2093	ASK	1316	7
2026-07-15 20:03:23.727823+07	ASII	2103	ASK	1585	8
2026-07-15 20:03:23.727823+07	ASII	2113	ASK	1497	9
2026-07-15 20:03:24.740036+07	ASII	2073	BID	1119	5
2026-07-15 20:03:24.740036+07	ASII	2063	BID	1360	6
2026-07-15 20:03:24.740036+07	ASII	2053	BID	1361	7
2026-07-15 20:03:24.740036+07	ASII	2043	BID	1608	8
2026-07-15 20:03:24.740036+07	ASII	2033	BID	1662	9
2026-07-15 20:03:24.740036+07	ASII	2073	ASK	1420	5
2026-07-15 20:03:24.740036+07	ASII	2083	ASK	1273	6
2026-07-15 20:03:24.740036+07	ASII	2093	ASK	1332	7
2026-07-15 20:03:24.740036+07	ASII	2103	ASK	1327	8
2026-07-15 20:03:24.740036+07	ASII	2113	ASK	1513	9
2026-07-15 20:03:25.751904+07	ASII	2073	BID	1116	5
2026-07-15 20:03:25.751904+07	ASII	2063	BID	1147	6
2026-07-15 20:03:25.751904+07	ASII	2053	BID	1200	7
2026-07-15 20:03:25.751904+07	ASII	2043	BID	1611	8
2026-07-15 20:03:25.751904+07	ASII	2033	BID	1687	9
2026-07-15 20:03:25.751904+07	ASII	2073	ASK	1467	5
2026-07-15 20:03:25.751904+07	ASII	2083	ASK	1362	6
2026-07-15 20:03:25.751904+07	ASII	2093	ASK	1393	7
2026-07-15 20:03:25.751904+07	ASII	2103	ASK	1670	8
2026-07-15 20:03:25.751904+07	ASII	2113	ASK	1880	9
2026-07-15 20:03:26.760694+07	ASII	2073	BID	1419	5
2026-07-15 20:03:26.760694+07	ASII	2063	BID	1325	6
2026-07-15 20:03:26.760694+07	ASII	2053	BID	1488	7
2026-07-15 20:03:26.760694+07	ASII	2043	BID	1322	8
2026-07-15 20:03:26.760694+07	ASII	2033	BID	1854	9
2026-07-15 20:03:26.760694+07	ASII	2073	ASK	1351	5
2026-07-15 20:03:26.760694+07	ASII	2083	ASK	1378	6
2026-07-15 20:03:26.760694+07	ASII	2093	ASK	1519	7
2026-07-15 20:03:26.760694+07	ASII	2103	ASK	1390	8
2026-07-15 20:03:26.760694+07	ASII	2113	ASK	1841	9
2026-07-15 20:03:27.76718+07	ASII	2073	BID	1340	5
2026-07-15 20:03:27.76718+07	ASII	2063	BID	1284	6
2026-07-15 20:03:27.76718+07	ASII	2053	BID	1277	7
2026-07-15 20:03:27.76718+07	ASII	2043	BID	1621	8
2026-07-15 20:03:27.76718+07	ASII	2033	BID	1493	9
2026-07-15 20:03:27.76718+07	ASII	2073	ASK	1211	5
2026-07-15 20:03:27.76718+07	ASII	2083	ASK	1492	6
2026-07-15 20:03:27.76718+07	ASII	2093	ASK	1485	7
2026-07-15 20:03:27.76718+07	ASII	2103	ASK	1658	8
2026-07-15 20:03:27.76718+07	ASII	2113	ASK	1648	9
2026-07-15 20:03:28.776606+07	ASII	2073	BID	1012	5
2026-07-15 20:03:28.776606+07	ASII	2063	BID	1234	6
2026-07-15 20:03:28.776606+07	ASII	2053	BID	1549	7
2026-07-15 20:03:28.776606+07	ASII	2043	BID	1487	8
2026-07-15 20:03:28.776606+07	ASII	2033	BID	1695	9
2026-07-15 20:03:28.776606+07	ASII	2073	ASK	1094	5
2026-07-15 20:03:28.776606+07	ASII	2083	ASK	1542	6
2026-07-15 20:03:28.776606+07	ASII	2093	ASK	1696	7
2026-07-15 20:03:28.776606+07	ASII	2103	ASK	1476	8
2026-07-15 20:03:28.776606+07	ASII	2113	ASK	1605	9
2026-07-15 20:03:29.782139+07	ASII	2073	BID	1383	5
2026-07-15 20:03:29.782139+07	ASII	2063	BID	1389	6
2026-07-15 20:03:29.782139+07	ASII	2053	BID	1539	7
2026-07-15 20:03:29.782139+07	ASII	2043	BID	1748	8
2026-07-15 20:03:29.782139+07	ASII	2033	BID	1525	9
2026-07-15 20:03:29.782139+07	ASII	2073	ASK	1296	5
2026-07-15 20:03:29.782139+07	ASII	2083	ASK	1573	6
2026-07-15 20:03:29.782139+07	ASII	2093	ASK	1316	7
2026-07-15 20:03:29.782139+07	ASII	2103	ASK	1305	8
2026-07-15 20:03:29.782139+07	ASII	2113	ASK	1789	9
2026-07-15 20:03:30.792801+07	ASII	2073	BID	1355	5
2026-07-15 20:03:30.792801+07	ASII	2063	BID	1464	6
2026-07-15 20:03:30.792801+07	ASII	2053	BID	1242	7
2026-07-15 20:03:30.792801+07	ASII	2043	BID	1744	8
2026-07-15 20:03:30.792801+07	ASII	2033	BID	1744	9
2026-07-15 20:03:30.792801+07	ASII	2073	ASK	1225	5
2026-07-15 20:03:30.792801+07	ASII	2083	ASK	1357	6
2026-07-15 20:03:30.792801+07	ASII	2093	ASK	1316	7
2026-07-15 20:03:30.792801+07	ASII	2103	ASK	1422	8
2026-07-15 20:03:30.792801+07	ASII	2113	ASK	1443	9
2026-07-15 20:03:31.800303+07	ASII	2073	BID	1279	5
2026-07-15 20:03:31.800303+07	ASII	2063	BID	1458	6
2026-07-15 20:03:31.800303+07	ASII	2053	BID	1266	7
2026-07-15 20:03:31.800303+07	ASII	2043	BID	1489	8
2026-07-15 20:03:31.800303+07	ASII	2033	BID	1404	9
2026-07-15 20:03:31.800303+07	ASII	2073	ASK	1194	5
2026-07-15 20:03:31.800303+07	ASII	2083	ASK	1222	6
2026-07-15 20:03:31.800303+07	ASII	2093	ASK	1633	7
2026-07-15 20:03:31.800303+07	ASII	2103	ASK	1402	8
2026-07-15 20:03:31.800303+07	ASII	2113	ASK	1657	9
2026-07-15 20:03:32.810261+07	ASII	2073	BID	1254	5
2026-07-15 20:03:32.810261+07	ASII	2063	BID	1542	6
2026-07-15 20:03:32.810261+07	ASII	2053	BID	1506	7
2026-07-15 20:03:32.810261+07	ASII	2043	BID	1459	8
2026-07-15 20:03:32.810261+07	ASII	2033	BID	1731	9
2026-07-15 20:03:32.810261+07	ASII	2073	ASK	1390	5
2026-07-15 20:03:32.810261+07	ASII	2083	ASK	1492	6
2026-07-15 20:03:32.810261+07	ASII	2093	ASK	1656	7
2026-07-15 20:03:32.810261+07	ASII	2103	ASK	1521	8
2026-07-15 20:03:32.810261+07	ASII	2113	ASK	1639	9
2026-07-15 20:03:33.817586+07	ASII	2073	BID	1252	5
2026-07-15 20:03:33.817586+07	ASII	2063	BID	1388	6
2026-07-15 20:03:33.817586+07	ASII	2053	BID	1462	7
2026-07-15 20:03:33.817586+07	ASII	2043	BID	1462	8
2026-07-15 20:03:33.817586+07	ASII	2033	BID	1739	9
2026-07-15 20:03:33.817586+07	ASII	2073	ASK	1255	5
2026-07-15 20:03:33.817586+07	ASII	2083	ASK	1581	6
2026-07-15 20:03:33.817586+07	ASII	2093	ASK	1333	7
2026-07-15 20:03:33.817586+07	ASII	2103	ASK	1724	8
2026-07-15 20:03:33.817586+07	ASII	2113	ASK	1635	9
2026-07-15 20:03:34.830892+07	ASII	2073	BID	1474	5
2026-07-15 20:03:34.830892+07	ASII	2063	BID	1284	6
2026-07-15 20:03:34.830892+07	ASII	2053	BID	1551	7
2026-07-15 20:03:34.830892+07	ASII	2043	BID	1315	8
2026-07-15 20:03:34.830892+07	ASII	2033	BID	1728	9
2026-07-15 20:03:34.830892+07	ASII	2073	ASK	1354	5
2026-07-15 20:03:34.830892+07	ASII	2083	ASK	1145	6
2026-07-15 20:03:34.830892+07	ASII	2093	ASK	1473	7
2026-07-15 20:03:34.830892+07	ASII	2103	ASK	1657	8
2026-07-15 20:03:34.830892+07	ASII	2113	ASK	1467	9
2026-07-15 20:03:35.839965+07	ASII	2073	BID	1225	5
2026-07-15 20:03:35.839965+07	ASII	2063	BID	1553	6
2026-07-15 20:03:35.839965+07	ASII	2053	BID	1465	7
2026-07-15 20:03:35.839965+07	ASII	2043	BID	1445	8
2026-07-15 20:03:35.839965+07	ASII	2033	BID	1420	9
2026-07-15 20:03:35.839965+07	ASII	2073	ASK	1443	5
2026-07-15 20:03:35.839965+07	ASII	2083	ASK	1188	6
2026-07-15 20:03:35.839965+07	ASII	2093	ASK	1284	7
2026-07-15 20:03:35.839965+07	ASII	2103	ASK	1509	8
2026-07-15 20:03:35.839965+07	ASII	2113	ASK	1854	9
2026-07-15 20:03:36.845646+07	ASII	2073	BID	1127	5
2026-07-15 20:03:36.845646+07	ASII	2063	BID	1343	6
2026-07-15 20:03:36.845646+07	ASII	2053	BID	1506	7
2026-07-15 20:03:36.845646+07	ASII	2043	BID	1538	8
2026-07-15 20:03:36.845646+07	ASII	2033	BID	1746	9
2026-07-15 20:03:36.845646+07	ASII	2073	ASK	1370	5
2026-07-15 20:03:36.845646+07	ASII	2083	ASK	1321	6
2026-07-15 20:03:36.845646+07	ASII	2093	ASK	1232	7
2026-07-15 20:03:36.845646+07	ASII	2103	ASK	1484	8
2026-07-15 20:03:36.845646+07	ASII	2113	ASK	1576	9
2026-07-15 20:03:37.854985+07	ASII	2073	BID	1433	5
2026-07-15 20:03:37.854985+07	ASII	2063	BID	1344	6
2026-07-15 20:03:37.854985+07	ASII	2053	BID	1645	7
2026-07-15 20:03:37.854985+07	ASII	2043	BID	1388	8
2026-07-15 20:03:37.854985+07	ASII	2033	BID	1555	9
2026-07-15 20:03:37.854985+07	ASII	2073	ASK	1397	5
2026-07-15 20:03:37.854985+07	ASII	2083	ASK	1560	6
2026-07-15 20:03:37.854985+07	ASII	2093	ASK	1471	7
2026-07-15 20:03:37.854985+07	ASII	2103	ASK	1390	8
2026-07-15 20:03:37.854985+07	ASII	2113	ASK	1853	9
2026-07-15 20:03:38.862258+07	ASII	2073	BID	1164	5
2026-07-15 20:03:38.862258+07	ASII	2063	BID	1179	6
2026-07-15 20:03:38.862258+07	ASII	2053	BID	1338	7
2026-07-15 20:03:38.862258+07	ASII	2043	BID	1457	8
2026-07-15 20:03:38.862258+07	ASII	2033	BID	1523	9
2026-07-15 20:03:38.862258+07	ASII	2073	ASK	1437	5
2026-07-15 20:03:38.862258+07	ASII	2083	ASK	1119	6
2026-07-15 20:03:38.862258+07	ASII	2093	ASK	1252	7
2026-07-15 20:03:38.862258+07	ASII	2103	ASK	1626	8
2026-07-15 20:03:38.862258+07	ASII	2113	ASK	1587	9
2026-07-15 20:03:39.871343+07	ASII	2073	BID	1490	5
2026-07-15 20:03:39.871343+07	ASII	2063	BID	1360	6
2026-07-15 20:03:39.871343+07	ASII	2053	BID	1342	7
2026-07-15 20:03:39.871343+07	ASII	2043	BID	1377	8
2026-07-15 20:03:39.871343+07	ASII	2033	BID	1674	9
2026-07-15 20:03:39.871343+07	ASII	2073	ASK	1130	5
2026-07-15 20:03:39.871343+07	ASII	2083	ASK	1229	6
2026-07-15 20:03:39.871343+07	ASII	2093	ASK	1247	7
2026-07-15 20:03:39.871343+07	ASII	2103	ASK	1621	8
2026-07-15 20:03:39.871343+07	ASII	2113	ASK	1871	9
2026-07-15 20:03:40.878355+07	ASII	2073	BID	1013	5
2026-07-15 20:03:40.878355+07	ASII	2063	BID	1128	6
2026-07-15 20:03:40.878355+07	ASII	2053	BID	1293	7
2026-07-15 20:03:40.878355+07	ASII	2043	BID	1537	8
2026-07-15 20:03:40.878355+07	ASII	2033	BID	1761	9
2026-07-15 20:03:40.878355+07	ASII	2073	ASK	1292	5
2026-07-15 20:03:40.878355+07	ASII	2083	ASK	1453	6
2026-07-15 20:03:40.878355+07	ASII	2093	ASK	1254	7
2026-07-15 20:03:40.878355+07	ASII	2103	ASK	1734	8
2026-07-15 20:03:40.878355+07	ASII	2113	ASK	1823	9
2026-07-15 20:03:41.887162+07	ASII	2073	BID	1107	5
2026-07-15 20:03:41.887162+07	ASII	2063	BID	1503	6
2026-07-15 20:03:41.887162+07	ASII	2053	BID	1272	7
2026-07-15 20:03:41.887162+07	ASII	2043	BID	1539	8
2026-07-15 20:03:41.887162+07	ASII	2033	BID	1567	9
2026-07-15 20:03:41.887162+07	ASII	2073	ASK	1129	5
2026-07-15 20:03:41.887162+07	ASII	2083	ASK	1433	6
2026-07-15 20:03:41.887162+07	ASII	2093	ASK	1305	7
2026-07-15 20:03:41.887162+07	ASII	2103	ASK	1304	8
2026-07-15 20:03:41.887162+07	ASII	2113	ASK	1833	9
2026-07-15 20:03:42.897281+07	ASII	2073	BID	1479	5
2026-07-15 20:03:42.897281+07	ASII	2063	BID	1475	6
2026-07-15 20:03:42.897281+07	ASII	2053	BID	1259	7
2026-07-15 20:03:42.897281+07	ASII	2043	BID	1575	8
2026-07-15 20:03:42.897281+07	ASII	2033	BID	1626	9
2026-07-15 20:03:42.897281+07	ASII	2073	ASK	1387	5
2026-07-15 20:03:42.897281+07	ASII	2083	ASK	1579	6
2026-07-15 20:03:42.897281+07	ASII	2093	ASK	1647	7
2026-07-15 20:03:42.897281+07	ASII	2103	ASK	1746	8
2026-07-15 20:03:42.897281+07	ASII	2113	ASK	1454	9
2026-07-15 20:03:43.908474+07	ASII	2073	BID	1231	5
2026-07-15 20:03:43.908474+07	ASII	2063	BID	1591	6
2026-07-15 20:03:43.908474+07	ASII	2053	BID	1428	7
2026-07-15 20:03:43.908474+07	ASII	2043	BID	1411	8
2026-07-15 20:03:43.908474+07	ASII	2033	BID	1864	9
2026-07-15 20:03:43.908474+07	ASII	2073	ASK	1233	5
2026-07-15 20:03:43.908474+07	ASII	2083	ASK	1334	6
2026-07-15 20:03:43.908474+07	ASII	2093	ASK	1526	7
2026-07-15 20:03:43.908474+07	ASII	2103	ASK	1583	8
2026-07-15 20:03:43.908474+07	ASII	2113	ASK	1653	9
2026-07-15 20:03:44.917092+07	ASII	2073	BID	1236	5
2026-07-15 20:03:44.917092+07	ASII	2063	BID	1117	6
2026-07-15 20:03:44.917092+07	ASII	2053	BID	1349	7
2026-07-15 20:03:44.917092+07	ASII	2043	BID	1398	8
2026-07-15 20:03:44.917092+07	ASII	2033	BID	1622	9
2026-07-15 20:03:44.917092+07	ASII	2073	ASK	1010	5
2026-07-15 20:03:44.917092+07	ASII	2083	ASK	1456	6
2026-07-15 20:03:44.917092+07	ASII	2093	ASK	1408	7
2026-07-15 20:03:44.917092+07	ASII	2103	ASK	1565	8
2026-07-15 20:03:44.917092+07	ASII	2113	ASK	1508	9
2026-07-15 20:03:45.927421+07	ASII	2073	BID	1426	5
2026-07-15 20:03:45.927421+07	ASII	2063	BID	1375	6
2026-07-15 20:03:45.927421+07	ASII	2053	BID	1240	7
2026-07-15 20:03:45.927421+07	ASII	2043	BID	1511	8
2026-07-15 20:03:45.927421+07	ASII	2033	BID	1745	9
2026-07-15 20:03:45.927421+07	ASII	2073	ASK	1255	5
2026-07-15 20:03:45.927421+07	ASII	2083	ASK	1458	6
2026-07-15 20:03:45.927421+07	ASII	2093	ASK	1207	7
2026-07-15 20:03:45.927421+07	ASII	2103	ASK	1501	8
2026-07-15 20:03:45.927421+07	ASII	2113	ASK	1773	9
2026-07-15 20:03:46.937056+07	ASII	2073	BID	1012	5
2026-07-15 20:03:46.937056+07	ASII	2063	BID	1589	6
2026-07-15 20:03:46.937056+07	ASII	2053	BID	1440	7
2026-07-15 20:03:46.937056+07	ASII	2043	BID	1736	8
2026-07-15 20:03:46.937056+07	ASII	2033	BID	1880	9
2026-07-15 20:03:46.937056+07	ASII	2073	ASK	1174	5
2026-07-15 20:03:46.937056+07	ASII	2083	ASK	1201	6
2026-07-15 20:03:46.937056+07	ASII	2093	ASK	1341	7
2026-07-15 20:03:46.937056+07	ASII	2103	ASK	1471	8
2026-07-15 20:03:46.937056+07	ASII	2113	ASK	1765	9
2026-07-15 20:03:47.945572+07	ASII	2073	BID	1093	5
2026-07-15 20:03:47.945572+07	ASII	2063	BID	1384	6
2026-07-15 20:03:47.945572+07	ASII	2053	BID	1213	7
2026-07-15 20:03:47.945572+07	ASII	2043	BID	1573	8
2026-07-15 20:03:47.945572+07	ASII	2033	BID	1786	9
2026-07-15 20:03:47.945572+07	ASII	2073	ASK	1271	5
2026-07-15 20:03:47.945572+07	ASII	2083	ASK	1259	6
2026-07-15 20:03:47.945572+07	ASII	2093	ASK	1226	7
2026-07-15 20:03:47.945572+07	ASII	2103	ASK	1364	8
2026-07-15 20:03:47.945572+07	ASII	2113	ASK	1831	9
2026-07-15 20:03:48.954941+07	ASII	2073	BID	1093	5
2026-07-15 20:03:48.954941+07	ASII	2063	BID	1448	6
2026-07-15 20:03:48.954941+07	ASII	2053	BID	1642	7
2026-07-15 20:03:48.954941+07	ASII	2043	BID	1316	8
2026-07-15 20:03:48.954941+07	ASII	2033	BID	1670	9
2026-07-15 20:03:48.954941+07	ASII	2073	ASK	1455	5
2026-07-15 20:03:48.954941+07	ASII	2083	ASK	1122	6
2026-07-15 20:03:48.954941+07	ASII	2093	ASK	1241	7
2026-07-15 20:03:48.954941+07	ASII	2103	ASK	1727	8
2026-07-15 20:03:48.954941+07	ASII	2113	ASK	1739	9
2026-07-15 20:03:49.963831+07	ASII	2073	BID	1085	5
2026-07-15 20:03:49.963831+07	ASII	2063	BID	1405	6
2026-07-15 20:03:49.963831+07	ASII	2053	BID	1567	7
2026-07-15 20:03:49.963831+07	ASII	2043	BID	1512	8
2026-07-15 20:03:49.963831+07	ASII	2033	BID	1753	9
2026-07-15 20:03:49.963831+07	ASII	2073	ASK	1231	5
2026-07-15 20:03:49.963831+07	ASII	2083	ASK	1477	6
2026-07-15 20:03:49.963831+07	ASII	2093	ASK	1307	7
2026-07-15 20:03:49.963831+07	ASII	2103	ASK	1611	8
2026-07-15 20:03:49.963831+07	ASII	2113	ASK	1503	9
2026-07-15 20:03:50.97767+07	ASII	2073	BID	1260	5
2026-07-15 20:03:50.97767+07	ASII	2063	BID	1268	6
2026-07-15 20:03:50.97767+07	ASII	2053	BID	1568	7
2026-07-15 20:03:50.97767+07	ASII	2043	BID	1511	8
2026-07-15 20:03:50.97767+07	ASII	2033	BID	1813	9
2026-07-15 20:03:50.97767+07	ASII	2073	ASK	1171	5
2026-07-15 20:03:50.97767+07	ASII	2083	ASK	1404	6
2026-07-15 20:03:50.97767+07	ASII	2093	ASK	1335	7
2026-07-15 20:03:50.97767+07	ASII	2103	ASK	1634	8
2026-07-15 20:03:50.97767+07	ASII	2113	ASK	1517	9
2026-07-15 20:03:51.987629+07	ASII	2073	BID	1108	5
2026-07-15 20:03:51.987629+07	ASII	2063	BID	1510	6
2026-07-15 20:03:51.987629+07	ASII	2053	BID	1626	7
2026-07-15 20:03:51.987629+07	ASII	2043	BID	1764	8
2026-07-15 20:03:51.987629+07	ASII	2033	BID	1672	9
2026-07-15 20:03:51.987629+07	ASII	2073	ASK	1209	5
2026-07-15 20:03:51.987629+07	ASII	2083	ASK	1370	6
2026-07-15 20:03:51.987629+07	ASII	2093	ASK	1313	7
2026-07-15 20:03:51.987629+07	ASII	2103	ASK	1789	8
2026-07-15 20:03:51.987629+07	ASII	2113	ASK	1763	9
2026-07-15 20:03:52.997475+07	ASII	2073	BID	1407	5
2026-07-15 20:03:52.997475+07	ASII	2063	BID	1531	6
2026-07-15 20:03:52.997475+07	ASII	2053	BID	1344	7
2026-07-15 20:03:52.997475+07	ASII	2043	BID	1390	8
2026-07-15 20:03:52.997475+07	ASII	2033	BID	1543	9
2026-07-15 20:03:52.997475+07	ASII	2073	ASK	1042	5
2026-07-15 20:03:52.997475+07	ASII	2083	ASK	1354	6
2026-07-15 20:03:52.997475+07	ASII	2093	ASK	1430	7
2026-07-15 20:03:52.997475+07	ASII	2103	ASK	1307	8
2026-07-15 20:03:52.997475+07	ASII	2113	ASK	1875	9
2026-07-15 20:03:54.008919+07	ASII	2073	BID	1035	5
2026-07-15 20:03:54.008919+07	ASII	2063	BID	1284	6
2026-07-15 20:03:54.008919+07	ASII	2053	BID	1596	7
2026-07-15 20:03:54.008919+07	ASII	2043	BID	1312	8
2026-07-15 20:03:54.008919+07	ASII	2033	BID	1836	9
2026-07-15 20:03:54.008919+07	ASII	2073	ASK	1157	5
2026-07-15 20:03:54.008919+07	ASII	2083	ASK	1596	6
2026-07-15 20:03:54.008919+07	ASII	2093	ASK	1635	7
2026-07-15 20:03:54.008919+07	ASII	2103	ASK	1799	8
2026-07-15 20:03:54.008919+07	ASII	2113	ASK	1835	9
2026-07-15 20:03:55.016717+07	ASII	2073	BID	1278	5
2026-07-15 20:03:55.016717+07	ASII	2063	BID	1313	6
2026-07-15 20:03:55.016717+07	ASII	2053	BID	1683	7
2026-07-15 20:03:55.016717+07	ASII	2043	BID	1769	8
2026-07-15 20:03:55.016717+07	ASII	2033	BID	1444	9
2026-07-15 20:03:55.016717+07	ASII	2073	ASK	1353	5
2026-07-15 20:03:55.016717+07	ASII	2083	ASK	1369	6
2026-07-15 20:03:55.016717+07	ASII	2093	ASK	1387	7
2026-07-15 20:03:55.016717+07	ASII	2103	ASK	1726	8
2026-07-15 20:03:55.016717+07	ASII	2113	ASK	1858	9
2026-07-15 20:03:56.027839+07	ASII	2073	BID	1087	5
2026-07-15 20:03:56.027839+07	ASII	2063	BID	1574	6
2026-07-15 20:03:56.027839+07	ASII	2053	BID	1477	7
2026-07-15 20:03:56.027839+07	ASII	2043	BID	1768	8
2026-07-15 20:03:56.027839+07	ASII	2033	BID	1605	9
2026-07-15 20:03:56.027839+07	ASII	2073	ASK	1423	5
2026-07-15 20:03:56.027839+07	ASII	2083	ASK	1366	6
2026-07-15 20:03:56.027839+07	ASII	2093	ASK	1536	7
2026-07-15 20:03:56.027839+07	ASII	2103	ASK	1736	8
2026-07-15 20:03:56.027839+07	ASII	2113	ASK	1723	9
2026-07-15 20:03:57.033436+07	ASII	2073	BID	1089	5
2026-07-15 20:03:57.033436+07	ASII	2063	BID	1330	6
2026-07-15 20:03:57.033436+07	ASII	2053	BID	1436	7
2026-07-15 20:03:57.033436+07	ASII	2043	BID	1694	8
2026-07-15 20:03:57.033436+07	ASII	2033	BID	1585	9
2026-07-15 20:03:57.033436+07	ASII	2073	ASK	1198	5
2026-07-15 20:03:57.033436+07	ASII	2083	ASK	1228	6
2026-07-15 20:03:57.033436+07	ASII	2093	ASK	1329	7
2026-07-15 20:03:57.033436+07	ASII	2103	ASK	1751	8
2026-07-15 20:03:57.033436+07	ASII	2113	ASK	1672	9
2026-07-15 20:03:58.044016+07	ASII	2073	BID	1267	5
2026-07-15 20:03:58.044016+07	ASII	2063	BID	1513	6
2026-07-15 20:03:58.044016+07	ASII	2053	BID	1571	7
2026-07-15 20:03:58.044016+07	ASII	2043	BID	1416	8
2026-07-15 20:03:58.044016+07	ASII	2033	BID	1717	9
2026-07-15 20:03:58.044016+07	ASII	2073	ASK	1053	5
2026-07-15 20:03:58.044016+07	ASII	2083	ASK	1143	6
2026-07-15 20:03:58.044016+07	ASII	2093	ASK	1388	7
2026-07-15 20:03:58.044016+07	ASII	2103	ASK	1514	8
2026-07-15 20:03:58.044016+07	ASII	2113	ASK	1553	9
2026-07-15 20:03:59.048015+07	ASII	2073	BID	1078	5
2026-07-15 20:03:59.048015+07	ASII	2063	BID	1221	6
2026-07-15 20:03:59.048015+07	ASII	2053	BID	1617	7
2026-07-15 20:03:59.048015+07	ASII	2043	BID	1670	8
2026-07-15 20:03:59.048015+07	ASII	2033	BID	1868	9
2026-07-15 20:03:59.048015+07	ASII	2073	ASK	1270	5
2026-07-15 20:03:59.048015+07	ASII	2083	ASK	1117	6
2026-07-15 20:03:59.048015+07	ASII	2093	ASK	1444	7
2026-07-15 20:03:59.048015+07	ASII	2103	ASK	1756	8
2026-07-15 20:03:59.048015+07	ASII	2113	ASK	1841	9
2026-07-15 20:04:00.056959+07	ASII	2073	BID	1173	5
2026-07-15 20:04:00.056959+07	ASII	2063	BID	1256	6
2026-07-15 20:04:00.056959+07	ASII	2053	BID	1250	7
2026-07-15 20:04:00.056959+07	ASII	2043	BID	1529	8
2026-07-15 20:04:00.056959+07	ASII	2033	BID	1739	9
2026-07-15 20:04:00.056959+07	ASII	2073	ASK	1119	5
2026-07-15 20:04:00.056959+07	ASII	2083	ASK	1557	6
2026-07-15 20:04:00.056959+07	ASII	2093	ASK	1461	7
2026-07-15 20:04:00.056959+07	ASII	2103	ASK	1480	8
2026-07-15 20:04:00.056959+07	ASII	2113	ASK	1580	9
2026-07-15 20:04:01.066456+07	ASII	2073	BID	1236	5
2026-07-15 20:04:01.066456+07	ASII	2063	BID	1217	6
2026-07-15 20:04:01.066456+07	ASII	2053	BID	1319	7
2026-07-15 20:04:01.066456+07	ASII	2043	BID	1342	8
2026-07-15 20:04:01.066456+07	ASII	2033	BID	1629	9
2026-07-15 20:04:01.066456+07	ASII	2073	ASK	1246	5
2026-07-15 20:04:01.066456+07	ASII	2083	ASK	1138	6
2026-07-15 20:04:01.066456+07	ASII	2093	ASK	1608	7
2026-07-15 20:04:01.066456+07	ASII	2103	ASK	1520	8
2026-07-15 20:04:01.066456+07	ASII	2113	ASK	1449	9
2026-07-15 20:04:02.076396+07	ASII	2073	BID	1089	5
2026-07-15 20:04:02.076396+07	ASII	2063	BID	1291	6
2026-07-15 20:04:02.076396+07	ASII	2053	BID	1400	7
2026-07-15 20:04:02.076396+07	ASII	2043	BID	1496	8
2026-07-15 20:04:02.076396+07	ASII	2033	BID	1763	9
2026-07-15 20:04:02.076396+07	ASII	2073	ASK	1066	5
2026-07-15 20:04:02.076396+07	ASII	2083	ASK	1308	6
2026-07-15 20:04:02.076396+07	ASII	2093	ASK	1395	7
2026-07-15 20:04:02.076396+07	ASII	2103	ASK	1635	8
2026-07-15 20:04:02.076396+07	ASII	2113	ASK	1597	9
2026-07-15 20:04:03.085006+07	ASII	2073	BID	1140	5
2026-07-15 20:04:03.085006+07	ASII	2063	BID	1267	6
2026-07-15 20:04:03.085006+07	ASII	2053	BID	1362	7
2026-07-15 20:04:03.085006+07	ASII	2043	BID	1322	8
2026-07-15 20:04:03.085006+07	ASII	2033	BID	1747	9
2026-07-15 20:04:03.085006+07	ASII	2073	ASK	1147	5
2026-07-15 20:04:03.085006+07	ASII	2083	ASK	1168	6
2026-07-15 20:04:03.085006+07	ASII	2093	ASK	1370	7
2026-07-15 20:04:03.085006+07	ASII	2103	ASK	1713	8
2026-07-15 20:04:03.085006+07	ASII	2113	ASK	1423	9
2026-07-15 20:04:04.094881+07	ASII	2073	BID	1071	5
2026-07-15 20:04:04.094881+07	ASII	2063	BID	1200	6
2026-07-15 20:04:04.094881+07	ASII	2053	BID	1664	7
2026-07-15 20:04:04.094881+07	ASII	2043	BID	1448	8
2026-07-15 20:04:04.094881+07	ASII	2033	BID	1577	9
2026-07-15 20:04:04.094881+07	ASII	2073	ASK	1309	5
2026-07-15 20:04:04.094881+07	ASII	2083	ASK	1335	6
2026-07-15 20:04:04.094881+07	ASII	2093	ASK	1421	7
2026-07-15 20:04:04.094881+07	ASII	2103	ASK	1743	8
2026-07-15 20:04:04.094881+07	ASII	2113	ASK	1798	9
2026-07-15 20:04:05.103372+07	ASII	2073	BID	1053	5
2026-07-15 20:04:05.103372+07	ASII	2063	BID	1164	6
2026-07-15 20:04:05.103372+07	ASII	2053	BID	1393	7
2026-07-15 20:04:05.103372+07	ASII	2043	BID	1504	8
2026-07-15 20:04:05.103372+07	ASII	2033	BID	1761	9
2026-07-15 20:04:05.103372+07	ASII	2073	ASK	1151	5
2026-07-15 20:04:05.103372+07	ASII	2083	ASK	1189	6
2026-07-15 20:04:05.103372+07	ASII	2093	ASK	1589	7
2026-07-15 20:04:05.103372+07	ASII	2103	ASK	1468	8
2026-07-15 20:04:05.103372+07	ASII	2113	ASK	1634	9
2026-07-15 20:04:06.112508+07	ASII	2073	BID	1427	5
2026-07-15 20:04:06.112508+07	ASII	2063	BID	1496	6
2026-07-15 20:04:06.112508+07	ASII	2053	BID	1648	7
2026-07-15 20:04:06.112508+07	ASII	2043	BID	1452	8
2026-07-15 20:04:06.112508+07	ASII	2033	BID	1752	9
2026-07-15 20:04:06.112508+07	ASII	2073	ASK	1354	5
2026-07-15 20:04:06.112508+07	ASII	2083	ASK	1176	6
2026-07-15 20:04:06.112508+07	ASII	2093	ASK	1550	7
2026-07-15 20:04:06.112508+07	ASII	2103	ASK	1449	8
2026-07-15 20:04:06.112508+07	ASII	2113	ASK	1609	9
2026-07-15 20:04:07.119158+07	ASII	2073	BID	1000	5
2026-07-15 20:04:07.119158+07	ASII	2063	BID	1294	6
2026-07-15 20:04:07.119158+07	ASII	2053	BID	1533	7
2026-07-15 20:04:07.119158+07	ASII	2043	BID	1356	8
2026-07-15 20:04:07.119158+07	ASII	2033	BID	1583	9
2026-07-15 20:04:07.119158+07	ASII	2073	ASK	1172	5
2026-07-15 20:04:07.119158+07	ASII	2083	ASK	1406	6
2026-07-15 20:04:07.119158+07	ASII	2093	ASK	1590	7
2026-07-15 20:04:07.119158+07	ASII	2103	ASK	1744	8
2026-07-15 20:04:07.119158+07	ASII	2113	ASK	1877	9
2026-07-15 20:04:08.129451+07	ASII	2073	BID	1190	5
2026-07-15 20:04:08.129451+07	ASII	2063	BID	1348	6
2026-07-15 20:04:08.129451+07	ASII	2053	BID	1511	7
2026-07-15 20:04:08.129451+07	ASII	2043	BID	1424	8
2026-07-15 20:04:08.129451+07	ASII	2033	BID	1638	9
2026-07-15 20:04:08.129451+07	ASII	2073	ASK	1467	5
2026-07-15 20:04:08.129451+07	ASII	2083	ASK	1499	6
2026-07-15 20:04:08.129451+07	ASII	2093	ASK	1237	7
2026-07-15 20:04:08.129451+07	ASII	2103	ASK	1622	8
2026-07-15 20:04:08.129451+07	ASII	2113	ASK	1690	9
2026-07-15 20:04:09.134662+07	ASII	2073	BID	1165	5
2026-07-15 20:04:09.134662+07	ASII	2063	BID	1470	6
2026-07-15 20:04:09.134662+07	ASII	2053	BID	1274	7
2026-07-15 20:04:09.134662+07	ASII	2043	BID	1761	8
2026-07-15 20:04:09.134662+07	ASII	2033	BID	1507	9
2026-07-15 20:04:09.134662+07	ASII	2073	ASK	1358	5
2026-07-15 20:04:09.134662+07	ASII	2083	ASK	1316	6
2026-07-15 20:04:09.134662+07	ASII	2093	ASK	1563	7
2026-07-15 20:04:09.134662+07	ASII	2103	ASK	1393	8
2026-07-15 20:04:09.134662+07	ASII	2113	ASK	1440	9
2026-07-15 20:04:10.14499+07	ASII	2073	BID	1112	5
2026-07-15 20:04:10.14499+07	ASII	2063	BID	1527	6
2026-07-15 20:04:10.14499+07	ASII	2053	BID	1255	7
2026-07-15 20:04:10.14499+07	ASII	2043	BID	1418	8
2026-07-15 20:04:10.14499+07	ASII	2033	BID	1722	9
2026-07-15 20:04:10.14499+07	ASII	2073	ASK	1036	5
2026-07-15 20:04:10.14499+07	ASII	2083	ASK	1449	6
2026-07-15 20:04:10.14499+07	ASII	2093	ASK	1334	7
2026-07-15 20:04:10.14499+07	ASII	2103	ASK	1450	8
2026-07-15 20:04:10.14499+07	ASII	2113	ASK	1651	9
2026-07-15 20:04:11.14817+07	ASII	2073	BID	1463	5
2026-07-15 20:04:11.14817+07	ASII	2063	BID	1185	6
2026-07-15 20:04:11.14817+07	ASII	2053	BID	1393	7
2026-07-15 20:04:11.14817+07	ASII	2043	BID	1502	8
2026-07-15 20:04:11.14817+07	ASII	2033	BID	1555	9
2026-07-15 20:04:11.14817+07	ASII	2073	ASK	1139	5
2026-07-15 20:04:11.14817+07	ASII	2083	ASK	1175	6
2026-07-15 20:04:11.14817+07	ASII	2093	ASK	1315	7
2026-07-15 20:04:11.14817+07	ASII	2103	ASK	1662	8
2026-07-15 20:04:11.14817+07	ASII	2113	ASK	1413	9
2026-07-15 20:04:12.155616+07	ASII	2073	BID	59254	5
2026-07-15 20:04:12.155616+07	ASII	2063	BID	1433	6
2026-07-15 20:04:12.155616+07	ASII	2053	BID	1474	7
2026-07-15 20:04:12.155616+07	ASII	2043	BID	1419	8
2026-07-15 20:04:12.155616+07	ASII	2033	BID	1567	9
2026-07-15 20:04:12.155616+07	ASII	2073	ASK	1142	5
2026-07-15 20:04:12.155616+07	ASII	2083	ASK	1419	6
2026-07-15 20:04:12.155616+07	ASII	2093	ASK	1609	7
2026-07-15 20:04:12.155616+07	ASII	2103	ASK	1476	8
2026-07-15 20:04:12.155616+07	ASII	2113	ASK	1410	9
2026-07-15 20:04:13.162428+07	ASII	2073	BID	58749	5
2026-07-15 20:04:13.162428+07	ASII	2063	BID	1450	6
2026-07-15 20:04:13.162428+07	ASII	2053	BID	1540	7
2026-07-15 20:04:13.162428+07	ASII	2043	BID	1352	8
2026-07-15 20:04:13.162428+07	ASII	2033	BID	1844	9
2026-07-15 20:04:13.162428+07	ASII	2073	ASK	1230	5
2026-07-15 20:04:13.162428+07	ASII	2083	ASK	1337	6
2026-07-15 20:04:13.162428+07	ASII	2093	ASK	1318	7
2026-07-15 20:04:13.162428+07	ASII	2103	ASK	1700	8
2026-07-15 20:04:13.162428+07	ASII	2113	ASK	1842	9
2026-07-15 20:04:14.167982+07	ASII	2073	BID	50005	5
2026-07-15 20:04:14.167982+07	ASII	2063	BID	1177	6
2026-07-15 20:04:14.167982+07	ASII	2053	BID	1261	7
2026-07-15 20:04:14.167982+07	ASII	2043	BID	1620	8
2026-07-15 20:04:14.167982+07	ASII	2033	BID	1556	9
2026-07-15 20:04:14.167982+07	ASII	2073	ASK	1186	5
2026-07-15 20:04:14.167982+07	ASII	2083	ASK	1537	6
2026-07-15 20:04:14.167982+07	ASII	2093	ASK	1543	7
2026-07-15 20:04:14.167982+07	ASII	2103	ASK	1531	8
2026-07-15 20:04:14.167982+07	ASII	2113	ASK	1710	9
2026-07-15 20:04:15.177954+07	ASII	2073	BID	59924	5
2026-07-15 20:04:15.177954+07	ASII	2063	BID	1185	6
2026-07-15 20:04:15.177954+07	ASII	2053	BID	1626	7
2026-07-15 20:04:15.177954+07	ASII	2043	BID	1538	8
2026-07-15 20:04:15.177954+07	ASII	2033	BID	1753	9
2026-07-15 20:04:15.177954+07	ASII	2073	ASK	1145	5
2026-07-15 20:04:15.177954+07	ASII	2083	ASK	1460	6
2026-07-15 20:04:15.177954+07	ASII	2093	ASK	1292	7
2026-07-15 20:04:15.177954+07	ASII	2103	ASK	1774	8
2026-07-15 20:04:15.177954+07	ASII	2113	ASK	1739	9
2026-07-15 20:04:16.183436+07	ASII	2073	BID	56352	5
2026-07-15 20:04:16.183436+07	ASII	2063	BID	1149	6
2026-07-15 20:04:16.183436+07	ASII	2053	BID	1342	7
2026-07-15 20:04:16.183436+07	ASII	2043	BID	1714	8
2026-07-15 20:04:16.183436+07	ASII	2033	BID	1567	9
2026-07-15 20:04:16.183436+07	ASII	2073	ASK	1150	5
2026-07-15 20:04:16.183436+07	ASII	2083	ASK	1446	6
2026-07-15 20:04:16.183436+07	ASII	2093	ASK	1445	7
2026-07-15 20:04:16.183436+07	ASII	2103	ASK	1614	8
2026-07-15 20:04:16.183436+07	ASII	2113	ASK	1470	9
2026-07-15 20:04:17.193671+07	ASII	2073	BID	59128	5
2026-07-15 20:04:17.193671+07	ASII	2063	BID	1583	6
2026-07-15 20:04:17.193671+07	ASII	2053	BID	1493	7
2026-07-15 20:04:17.193671+07	ASII	2043	BID	1555	8
2026-07-15 20:04:17.193671+07	ASII	2033	BID	1806	9
2026-07-15 20:04:17.193671+07	ASII	2073	ASK	1193	5
2026-07-15 20:04:17.193671+07	ASII	2083	ASK	1227	6
2026-07-15 20:04:17.193671+07	ASII	2093	ASK	1413	7
2026-07-15 20:04:17.193671+07	ASII	2103	ASK	1632	8
2026-07-15 20:04:17.193671+07	ASII	2113	ASK	1532	9
2026-07-15 20:04:18.197644+07	ASII	2073	BID	59946	5
2026-07-15 20:04:18.197644+07	ASII	2063	BID	1150	6
2026-07-15 20:04:18.197644+07	ASII	2053	BID	1333	7
2026-07-15 20:04:18.197644+07	ASII	2043	BID	1323	8
2026-07-15 20:04:18.197644+07	ASII	2033	BID	1624	9
2026-07-15 20:04:18.197644+07	ASII	2073	ASK	1209	5
2026-07-15 20:04:18.197644+07	ASII	2083	ASK	1364	6
2026-07-15 20:04:18.197644+07	ASII	2093	ASK	1554	7
2026-07-15 20:04:18.197644+07	ASII	2103	ASK	1537	8
2026-07-15 20:04:18.197644+07	ASII	2113	ASK	1619	9
2026-07-15 20:04:19.205133+07	ASII	2073	BID	56634	5
2026-07-15 20:04:19.205133+07	ASII	2063	BID	1220	6
2026-07-15 20:04:19.205133+07	ASII	2053	BID	1257	7
2026-07-15 20:04:19.205133+07	ASII	2043	BID	1483	8
2026-07-15 20:04:19.205133+07	ASII	2033	BID	1632	9
2026-07-15 20:04:19.205133+07	ASII	2073	ASK	1306	5
2026-07-15 20:04:19.205133+07	ASII	2083	ASK	1258	6
2026-07-15 20:04:19.205133+07	ASII	2093	ASK	1534	7
2026-07-15 20:04:19.205133+07	ASII	2103	ASK	1373	8
2026-07-15 20:04:19.205133+07	ASII	2113	ASK	1523	9
2026-07-15 20:04:20.213+07	ASII	2073	BID	59961	5
2026-07-15 20:04:20.213+07	ASII	2063	BID	1117	6
2026-07-15 20:04:20.213+07	ASII	2053	BID	1602	7
2026-07-15 20:04:20.213+07	ASII	2043	BID	1314	8
2026-07-15 20:04:20.213+07	ASII	2033	BID	1438	9
2026-07-15 20:04:20.213+07	ASII	2073	ASK	1469	5
2026-07-15 20:04:20.213+07	ASII	2083	ASK	1118	6
2026-07-15 20:04:20.213+07	ASII	2093	ASK	1422	7
2026-07-15 20:04:20.213+07	ASII	2103	ASK	1681	8
2026-07-15 20:04:20.213+07	ASII	2113	ASK	1876	9
2026-07-15 20:04:21.219256+07	ASII	2073	BID	53152	5
2026-07-15 20:04:21.219256+07	ASII	2063	BID	1453	6
2026-07-15 20:04:21.219256+07	ASII	2053	BID	1602	7
2026-07-15 20:04:21.219256+07	ASII	2043	BID	1770	8
2026-07-15 20:04:21.219256+07	ASII	2033	BID	1433	9
2026-07-15 20:04:21.219256+07	ASII	2073	ASK	1111	5
2026-07-15 20:04:21.219256+07	ASII	2083	ASK	1505	6
2026-07-15 20:04:21.219256+07	ASII	2093	ASK	1415	7
2026-07-15 20:04:21.219256+07	ASII	2103	ASK	1756	8
2026-07-15 20:04:21.219256+07	ASII	2113	ASK	1883	9
2026-07-15 20:04:22.228275+07	ASII	2073	BID	58255	5
2026-07-15 20:04:22.228275+07	ASII	2063	BID	1456	6
2026-07-15 20:04:22.228275+07	ASII	2053	BID	1484	7
2026-07-15 20:04:22.228275+07	ASII	2043	BID	1390	8
2026-07-15 20:04:22.228275+07	ASII	2033	BID	1404	9
2026-07-15 20:04:22.228275+07	ASII	2073	ASK	1028	5
2026-07-15 20:04:22.228275+07	ASII	2083	ASK	1468	6
2026-07-15 20:04:22.228275+07	ASII	2093	ASK	1258	7
2026-07-15 20:04:22.228275+07	ASII	2103	ASK	1713	8
2026-07-15 20:04:22.228275+07	ASII	2113	ASK	1854	9
2026-07-15 20:04:23.232917+07	ASII	2073	BID	54575	5
2026-07-15 20:04:23.232917+07	ASII	2063	BID	1352	6
2026-07-15 20:04:23.232917+07	ASII	2053	BID	1258	7
2026-07-15 20:04:23.232917+07	ASII	2043	BID	1363	8
2026-07-15 20:04:23.232917+07	ASII	2033	BID	1542	9
2026-07-15 20:04:23.232917+07	ASII	2073	ASK	1198	5
2026-07-15 20:04:23.232917+07	ASII	2083	ASK	1225	6
2026-07-15 20:04:23.232917+07	ASII	2093	ASK	1465	7
2026-07-15 20:04:23.232917+07	ASII	2103	ASK	1633	8
2026-07-15 20:04:23.232917+07	ASII	2113	ASK	1873	9
2026-07-15 20:04:24.24336+07	ASII	2073	BID	52158	5
2026-07-15 20:04:24.24336+07	ASII	2063	BID	1210	6
2026-07-15 20:04:24.24336+07	ASII	2053	BID	1620	7
2026-07-15 20:04:24.24336+07	ASII	2043	BID	1588	8
2026-07-15 20:04:24.24336+07	ASII	2033	BID	1697	9
2026-07-15 20:04:24.24336+07	ASII	2073	ASK	1471	5
2026-07-15 20:04:24.24336+07	ASII	2083	ASK	1421	6
2026-07-15 20:04:24.24336+07	ASII	2093	ASK	1222	7
2026-07-15 20:04:24.24336+07	ASII	2103	ASK	1731	8
2026-07-15 20:04:24.24336+07	ASII	2113	ASK	1831	9
2026-07-15 20:04:25.248163+07	ASII	2073	BID	50509	5
2026-07-15 20:04:25.248163+07	ASII	2063	BID	1270	6
2026-07-15 20:04:25.248163+07	ASII	2053	BID	1660	7
2026-07-15 20:04:25.248163+07	ASII	2043	BID	1473	8
2026-07-15 20:04:25.248163+07	ASII	2033	BID	1844	9
2026-07-15 20:04:25.248163+07	ASII	2073	ASK	1491	5
2026-07-15 20:04:25.248163+07	ASII	2083	ASK	1538	6
2026-07-15 20:04:25.248163+07	ASII	2093	ASK	1388	7
2026-07-15 20:04:25.248163+07	ASII	2103	ASK	1468	8
2026-07-15 20:04:25.248163+07	ASII	2113	ASK	1875	9
2026-07-15 20:04:26.256393+07	ASII	2073	BID	58812	5
2026-07-15 20:04:26.256393+07	ASII	2063	BID	1537	6
2026-07-15 20:04:26.256393+07	ASII	2053	BID	1200	7
2026-07-15 20:04:26.256393+07	ASII	2043	BID	1352	8
2026-07-15 20:04:26.256393+07	ASII	2033	BID	1835	9
2026-07-15 20:04:26.256393+07	ASII	2073	ASK	1123	5
2026-07-15 20:04:26.256393+07	ASII	2083	ASK	1434	6
2026-07-15 20:04:26.256393+07	ASII	2093	ASK	1552	7
2026-07-15 20:04:26.256393+07	ASII	2103	ASK	1675	8
2026-07-15 20:04:26.256393+07	ASII	2113	ASK	1516	9
2026-07-15 20:04:27.26274+07	ASII	2073	BID	52503	5
2026-07-15 20:04:27.26274+07	ASII	2063	BID	1390	6
2026-07-15 20:04:27.26274+07	ASII	2053	BID	1576	7
2026-07-15 20:04:27.26274+07	ASII	2043	BID	1568	8
2026-07-15 20:04:27.26274+07	ASII	2033	BID	1822	9
2026-07-15 20:04:27.26274+07	ASII	2073	ASK	1380	5
2026-07-15 20:04:27.26274+07	ASII	2083	ASK	1192	6
2026-07-15 20:04:27.26274+07	ASII	2093	ASK	1225	7
2026-07-15 20:04:27.26274+07	ASII	2103	ASK	1719	8
2026-07-15 20:04:27.26274+07	ASII	2113	ASK	1505	9
2026-07-15 20:04:28.273386+07	ASII	2073	BID	59078	5
2026-07-15 20:04:28.273386+07	ASII	2063	BID	1580	6
2026-07-15 20:04:28.273386+07	ASII	2053	BID	1470	7
2026-07-15 20:04:28.273386+07	ASII	2043	BID	1672	8
2026-07-15 20:04:28.273386+07	ASII	2033	BID	1888	9
2026-07-15 20:04:28.273386+07	ASII	2073	ASK	1096	5
2026-07-15 20:04:28.273386+07	ASII	2083	ASK	1554	6
2026-07-15 20:04:28.273386+07	ASII	2093	ASK	1468	7
2026-07-15 20:04:28.273386+07	ASII	2103	ASK	1781	8
2026-07-15 20:04:28.273386+07	ASII	2113	ASK	1593	9
2026-07-15 20:04:29.282435+07	ASII	2073	BID	51258	5
2026-07-15 20:04:29.282435+07	ASII	2063	BID	1196	6
2026-07-15 20:04:29.282435+07	ASII	2053	BID	1257	7
2026-07-15 20:04:29.282435+07	ASII	2043	BID	1681	8
2026-07-15 20:04:29.282435+07	ASII	2033	BID	1766	9
2026-07-15 20:04:29.282435+07	ASII	2073	ASK	1294	5
2026-07-15 20:04:29.282435+07	ASII	2083	ASK	1225	6
2026-07-15 20:04:29.282435+07	ASII	2093	ASK	1655	7
2026-07-15 20:04:29.282435+07	ASII	2103	ASK	1679	8
2026-07-15 20:04:29.282435+07	ASII	2113	ASK	1719	9
2026-07-15 20:04:30.294442+07	ASII	2073	BID	56831	5
2026-07-15 20:04:30.294442+07	ASII	2063	BID	1383	6
2026-07-15 20:04:30.294442+07	ASII	2053	BID	1460	7
2026-07-15 20:04:30.294442+07	ASII	2043	BID	1549	8
2026-07-15 20:04:30.294442+07	ASII	2033	BID	1664	9
2026-07-15 20:04:30.294442+07	ASII	2073	ASK	1018	5
2026-07-15 20:04:30.294442+07	ASII	2083	ASK	1186	6
2026-07-15 20:04:30.294442+07	ASII	2093	ASK	1692	7
2026-07-15 20:04:30.294442+07	ASII	2103	ASK	1654	8
2026-07-15 20:04:30.294442+07	ASII	2113	ASK	1439	9
2026-07-15 20:04:31.30505+07	ASII	2073	BID	51081	5
2026-07-15 20:04:31.30505+07	ASII	2063	BID	1598	6
2026-07-15 20:04:31.30505+07	ASII	2053	BID	1581	7
2026-07-15 20:04:31.30505+07	ASII	2043	BID	1653	8
2026-07-15 20:04:31.30505+07	ASII	2033	BID	1586	9
2026-07-15 20:04:31.30505+07	ASII	2073	ASK	1410	5
2026-07-15 20:04:31.30505+07	ASII	2083	ASK	1334	6
2026-07-15 20:04:31.30505+07	ASII	2093	ASK	1635	7
2026-07-15 20:04:31.30505+07	ASII	2103	ASK	1626	8
2026-07-15 20:04:31.30505+07	ASII	2113	ASK	1515	9
2026-07-15 20:04:32.315125+07	ASII	2073	BID	51843	5
2026-07-15 20:04:32.315125+07	ASII	2063	BID	1323	6
2026-07-15 20:04:32.315125+07	ASII	2053	BID	1634	7
2026-07-15 20:04:32.315125+07	ASII	2043	BID	1470	8
2026-07-15 20:04:32.315125+07	ASII	2033	BID	1891	9
2026-07-15 20:04:32.315125+07	ASII	2073	ASK	1449	5
2026-07-15 20:04:32.315125+07	ASII	2083	ASK	1164	6
2026-07-15 20:04:32.315125+07	ASII	2093	ASK	1306	7
2026-07-15 20:04:32.315125+07	ASII	2103	ASK	1791	8
2026-07-15 20:04:32.315125+07	ASII	2113	ASK	1877	9
2026-07-15 20:04:33.324769+07	ASII	2073	BID	53120	5
2026-07-15 20:04:33.324769+07	ASII	2063	BID	1219	6
2026-07-15 20:04:33.324769+07	ASII	2053	BID	1312	7
2026-07-15 20:04:33.324769+07	ASII	2043	BID	1689	8
2026-07-15 20:04:33.324769+07	ASII	2033	BID	1644	9
2026-07-15 20:04:33.324769+07	ASII	2073	ASK	1125	5
2026-07-15 20:04:33.324769+07	ASII	2083	ASK	1184	6
2026-07-15 20:04:33.324769+07	ASII	2093	ASK	1270	7
2026-07-15 20:04:33.324769+07	ASII	2103	ASK	1633	8
2026-07-15 20:04:33.324769+07	ASII	2113	ASK	1404	9
2026-07-15 20:04:34.332897+07	ASII	2073	BID	53739	5
2026-07-15 20:04:34.332897+07	ASII	2063	BID	1174	6
2026-07-15 20:04:34.332897+07	ASII	2053	BID	1484	7
2026-07-15 20:04:34.332897+07	ASII	2043	BID	1538	8
2026-07-15 20:04:34.332897+07	ASII	2033	BID	1547	9
2026-07-15 20:04:34.332897+07	ASII	2073	ASK	1416	5
2026-07-15 20:04:34.332897+07	ASII	2083	ASK	1373	6
2026-07-15 20:04:34.332897+07	ASII	2093	ASK	1605	7
2026-07-15 20:04:34.332897+07	ASII	2103	ASK	1595	8
2026-07-15 20:04:34.332897+07	ASII	2113	ASK	1768	9
2026-07-15 20:04:35.342307+07	ASII	2073	BID	58942	5
2026-07-15 20:04:35.342307+07	ASII	2063	BID	1164	6
2026-07-15 20:04:35.342307+07	ASII	2053	BID	1226	7
2026-07-15 20:04:35.342307+07	ASII	2043	BID	1700	8
2026-07-15 20:04:35.342307+07	ASII	2033	BID	1824	9
2026-07-15 20:04:35.342307+07	ASII	2073	ASK	1238	5
2026-07-15 20:04:35.342307+07	ASII	2083	ASK	1125	6
2026-07-15 20:04:35.342307+07	ASII	2093	ASK	1215	7
2026-07-15 20:04:35.342307+07	ASII	2103	ASK	1648	8
2026-07-15 20:04:35.342307+07	ASII	2113	ASK	1551	9
2026-07-15 20:04:36.351302+07	ASII	2073	BID	57040	5
2026-07-15 20:04:36.351302+07	ASII	2063	BID	1153	6
2026-07-15 20:04:36.351302+07	ASII	2053	BID	1692	7
2026-07-15 20:04:36.351302+07	ASII	2043	BID	1301	8
2026-07-15 20:04:36.351302+07	ASII	2033	BID	1781	9
2026-07-15 20:04:36.351302+07	ASII	2073	ASK	1293	5
2026-07-15 20:04:36.351302+07	ASII	2083	ASK	1427	6
2026-07-15 20:04:36.351302+07	ASII	2093	ASK	1607	7
2026-07-15 20:04:36.351302+07	ASII	2103	ASK	1468	8
2026-07-15 20:04:36.351302+07	ASII	2113	ASK	1479	9
2026-07-15 20:04:37.362437+07	ASII	2073	BID	53861	5
2026-07-15 20:04:37.362437+07	ASII	2063	BID	1152	6
2026-07-15 20:04:37.362437+07	ASII	2053	BID	1242	7
2026-07-15 20:04:37.362437+07	ASII	2043	BID	1661	8
2026-07-15 20:04:37.362437+07	ASII	2033	BID	1666	9
2026-07-15 20:04:37.362437+07	ASII	2073	ASK	1179	5
2026-07-15 20:04:37.362437+07	ASII	2083	ASK	1525	6
2026-07-15 20:04:37.362437+07	ASII	2093	ASK	1204	7
2026-07-15 20:04:37.362437+07	ASII	2103	ASK	1595	8
2026-07-15 20:04:37.362437+07	ASII	2113	ASK	1735	9
2026-07-15 20:04:38.36879+07	ASII	2073	BID	56206	5
2026-07-15 20:04:38.36879+07	ASII	2063	BID	1510	6
2026-07-15 20:04:38.36879+07	ASII	2053	BID	1684	7
2026-07-15 20:04:38.36879+07	ASII	2043	BID	1545	8
2026-07-15 20:04:38.36879+07	ASII	2033	BID	1447	9
2026-07-15 20:04:38.36879+07	ASII	2073	ASK	1301	5
2026-07-15 20:04:38.36879+07	ASII	2083	ASK	1244	6
2026-07-15 20:04:38.36879+07	ASII	2093	ASK	1669	7
2026-07-15 20:04:38.36879+07	ASII	2103	ASK	1785	8
2026-07-15 20:04:38.36879+07	ASII	2113	ASK	1813	9
2026-07-15 20:04:39.379085+07	ASII	2073	BID	57408	5
2026-07-15 20:04:39.379085+07	ASII	2063	BID	1466	6
2026-07-15 20:04:39.379085+07	ASII	2053	BID	1359	7
2026-07-15 20:04:39.379085+07	ASII	2043	BID	1755	8
2026-07-15 20:04:39.379085+07	ASII	2033	BID	1696	9
2026-07-15 20:04:39.379085+07	ASII	2073	ASK	1160	5
2026-07-15 20:04:39.379085+07	ASII	2083	ASK	1417	6
2026-07-15 20:04:39.379085+07	ASII	2093	ASK	1437	7
2026-07-15 20:04:39.379085+07	ASII	2103	ASK	1546	8
2026-07-15 20:04:39.379085+07	ASII	2113	ASK	1518	9
2026-07-15 20:04:40.384396+07	ASII	2073	BID	53818	5
2026-07-15 20:04:40.384396+07	ASII	2063	BID	1305	6
2026-07-15 20:04:40.384396+07	ASII	2053	BID	1404	7
2026-07-15 20:04:40.384396+07	ASII	2043	BID	1730	8
2026-07-15 20:04:40.384396+07	ASII	2033	BID	1736	9
2026-07-15 20:04:40.384396+07	ASII	2073	ASK	1389	5
2026-07-15 20:04:40.384396+07	ASII	2083	ASK	1405	6
2026-07-15 20:04:40.384396+07	ASII	2093	ASK	1446	7
2026-07-15 20:04:40.384396+07	ASII	2103	ASK	1528	8
2026-07-15 20:04:40.384396+07	ASII	2113	ASK	1506	9
2026-07-15 20:04:41.394515+07	ASII	2073	BID	55111	5
2026-07-15 20:04:41.394515+07	ASII	2063	BID	1224	6
2026-07-15 20:04:41.394515+07	ASII	2053	BID	1687	7
2026-07-15 20:04:41.394515+07	ASII	2043	BID	1648	8
2026-07-15 20:04:41.394515+07	ASII	2033	BID	1523	9
2026-07-15 20:04:41.394515+07	ASII	2073	ASK	1222	5
2026-07-15 20:04:41.394515+07	ASII	2083	ASK	1242	6
2026-07-15 20:04:41.394515+07	ASII	2093	ASK	1414	7
2026-07-15 20:04:41.394515+07	ASII	2103	ASK	1625	8
2026-07-15 20:04:41.394515+07	ASII	2113	ASK	1450	9
2026-07-15 20:04:42.399706+07	ASII	2073	BID	55852	5
2026-07-15 20:04:42.399706+07	ASII	2063	BID	1179	6
2026-07-15 20:04:42.399706+07	ASII	2053	BID	1536	7
2026-07-15 20:04:42.399706+07	ASII	2043	BID	1464	8
2026-07-15 20:04:42.399706+07	ASII	2033	BID	1569	9
2026-07-15 20:04:42.399706+07	ASII	2073	ASK	1134	5
2026-07-15 20:04:42.399706+07	ASII	2083	ASK	1348	6
2026-07-15 20:04:42.399706+07	ASII	2093	ASK	1285	7
2026-07-15 20:04:42.399706+07	ASII	2103	ASK	1446	8
2026-07-15 20:04:42.399706+07	ASII	2113	ASK	1648	9
2026-07-15 20:04:43.412029+07	ASII	2073	BID	54282	5
2026-07-15 20:04:43.412029+07	ASII	2063	BID	1444	6
2026-07-15 20:04:43.412029+07	ASII	2053	BID	1485	7
2026-07-15 20:04:43.412029+07	ASII	2043	BID	1709	8
2026-07-15 20:04:43.412029+07	ASII	2033	BID	1536	9
2026-07-15 20:04:43.412029+07	ASII	2073	ASK	1139	5
2026-07-15 20:04:43.412029+07	ASII	2083	ASK	1347	6
2026-07-15 20:04:43.412029+07	ASII	2093	ASK	1292	7
2026-07-15 20:04:43.412029+07	ASII	2103	ASK	1667	8
2026-07-15 20:04:43.412029+07	ASII	2113	ASK	1697	9
2026-07-15 20:04:44.418479+07	ASII	2073	BID	55600	5
2026-07-15 20:04:44.418479+07	ASII	2063	BID	1206	6
2026-07-15 20:04:44.418479+07	ASII	2053	BID	1290	7
2026-07-15 20:04:44.418479+07	ASII	2043	BID	1401	8
2026-07-15 20:04:44.418479+07	ASII	2033	BID	1452	9
2026-07-15 20:04:44.418479+07	ASII	2073	ASK	1405	5
2026-07-15 20:04:44.418479+07	ASII	2083	ASK	1554	6
2026-07-15 20:04:44.418479+07	ASII	2093	ASK	1648	7
2026-07-15 20:04:44.418479+07	ASII	2103	ASK	1393	8
2026-07-15 20:04:44.418479+07	ASII	2113	ASK	1501	9
2026-07-15 20:04:45.42951+07	ASII	2073	BID	55209	5
2026-07-15 20:04:45.42951+07	ASII	2063	BID	1448	6
2026-07-15 20:04:45.42951+07	ASII	2053	BID	1427	7
2026-07-15 20:04:45.42951+07	ASII	2043	BID	1474	8
2026-07-15 20:04:45.42951+07	ASII	2033	BID	1692	9
2026-07-15 20:04:45.42951+07	ASII	2073	ASK	1433	5
2026-07-15 20:04:45.42951+07	ASII	2083	ASK	1487	6
2026-07-15 20:04:45.42951+07	ASII	2093	ASK	1500	7
2026-07-15 20:04:45.42951+07	ASII	2103	ASK	1466	8
2026-07-15 20:04:45.42951+07	ASII	2113	ASK	1745	9
2026-07-15 20:04:46.433981+07	ASII	2073	BID	51053	5
2026-07-15 20:04:46.433981+07	ASII	2063	BID	1468	6
2026-07-15 20:04:46.433981+07	ASII	2053	BID	1278	7
2026-07-15 20:04:46.433981+07	ASII	2043	BID	1548	8
2026-07-15 20:04:46.433981+07	ASII	2033	BID	1691	9
2026-07-15 20:04:46.433981+07	ASII	2073	ASK	1452	5
2026-07-15 20:04:46.433981+07	ASII	2083	ASK	1375	6
2026-07-15 20:04:46.433981+07	ASII	2093	ASK	1212	7
2026-07-15 20:04:46.433981+07	ASII	2103	ASK	1351	8
2026-07-15 20:04:46.433981+07	ASII	2113	ASK	1674	9
2026-07-15 20:04:47.443681+07	ASII	2073	BID	54239	5
2026-07-15 20:04:47.443681+07	ASII	2063	BID	1487	6
2026-07-15 20:04:47.443681+07	ASII	2053	BID	1219	7
2026-07-15 20:04:47.443681+07	ASII	2043	BID	1417	8
2026-07-15 20:04:47.443681+07	ASII	2033	BID	1439	9
2026-07-15 20:04:47.443681+07	ASII	2073	ASK	1481	5
2026-07-15 20:04:47.443681+07	ASII	2083	ASK	1236	6
2026-07-15 20:04:47.443681+07	ASII	2093	ASK	1556	7
2026-07-15 20:04:47.443681+07	ASII	2103	ASK	1484	8
2026-07-15 20:04:47.443681+07	ASII	2113	ASK	1573	9
2026-07-15 20:04:48.448718+07	ASII	2073	BID	51014	5
2026-07-15 20:04:48.448718+07	ASII	2063	BID	1496	6
2026-07-15 20:04:48.448718+07	ASII	2053	BID	1583	7
2026-07-15 20:04:48.448718+07	ASII	2043	BID	1770	8
2026-07-15 20:04:48.448718+07	ASII	2033	BID	1466	9
2026-07-15 20:04:48.448718+07	ASII	2073	ASK	1266	5
2026-07-15 20:04:48.448718+07	ASII	2083	ASK	1513	6
2026-07-15 20:04:48.448718+07	ASII	2093	ASK	1308	7
2026-07-15 20:04:48.448718+07	ASII	2103	ASK	1517	8
2026-07-15 20:04:48.448718+07	ASII	2113	ASK	1695	9
2026-07-15 20:04:49.453918+07	ASII	2073	BID	57811	5
2026-07-15 20:04:49.453918+07	ASII	2063	BID	1188	6
2026-07-15 20:04:49.453918+07	ASII	2053	BID	1404	7
2026-07-15 20:04:49.453918+07	ASII	2043	BID	1651	8
2026-07-15 20:04:49.453918+07	ASII	2033	BID	1803	9
2026-07-15 20:04:49.453918+07	ASII	2073	ASK	1406	5
2026-07-15 20:04:49.453918+07	ASII	2083	ASK	1564	6
2026-07-15 20:04:49.453918+07	ASII	2093	ASK	1300	7
2026-07-15 20:04:49.453918+07	ASII	2103	ASK	1599	8
2026-07-15 20:04:49.453918+07	ASII	2113	ASK	1655	9
2026-07-15 20:04:50.463103+07	ASII	2073	BID	52388	5
2026-07-15 20:04:50.463103+07	ASII	2063	BID	1594	6
2026-07-15 20:04:50.463103+07	ASII	2053	BID	1324	7
2026-07-15 20:04:50.463103+07	ASII	2043	BID	1550	8
2026-07-15 20:04:50.463103+07	ASII	2033	BID	1465	9
2026-07-15 20:04:50.463103+07	ASII	2073	ASK	1103	5
2026-07-15 20:04:50.463103+07	ASII	2083	ASK	1127	6
2026-07-15 20:04:50.463103+07	ASII	2093	ASK	1601	7
2026-07-15 20:04:50.463103+07	ASII	2103	ASK	1353	8
2026-07-15 20:04:50.463103+07	ASII	2113	ASK	1754	9
2026-07-15 20:04:51.467298+07	ASII	2073	BID	53289	5
2026-07-15 20:04:51.467298+07	ASII	2063	BID	1113	6
2026-07-15 20:04:51.467298+07	ASII	2053	BID	1594	7
2026-07-15 20:04:51.467298+07	ASII	2043	BID	1601	8
2026-07-15 20:04:51.467298+07	ASII	2033	BID	1729	9
2026-07-15 20:04:51.467298+07	ASII	2073	ASK	1463	5
2026-07-15 20:04:51.467298+07	ASII	2083	ASK	1466	6
2026-07-15 20:04:51.467298+07	ASII	2093	ASK	1637	7
2026-07-15 20:04:51.467298+07	ASII	2103	ASK	1413	8
2026-07-15 20:04:51.467298+07	ASII	2113	ASK	1564	9
2026-07-15 20:04:52.477104+07	ASII	2073	BID	54349	5
2026-07-15 20:04:52.477104+07	ASII	2063	BID	1239	6
2026-07-15 20:04:52.477104+07	ASII	2053	BID	1495	7
2026-07-15 20:04:52.477104+07	ASII	2043	BID	1374	8
2026-07-15 20:04:52.477104+07	ASII	2033	BID	1468	9
2026-07-15 20:04:52.477104+07	ASII	2073	ASK	1189	5
2026-07-15 20:04:52.477104+07	ASII	2083	ASK	1324	6
2026-07-15 20:04:52.477104+07	ASII	2093	ASK	1346	7
2026-07-15 20:04:52.477104+07	ASII	2103	ASK	1539	8
2026-07-15 20:04:52.477104+07	ASII	2113	ASK	1744	9
2026-07-15 20:04:53.482554+07	ASII	2073	BID	58154	5
2026-07-15 20:04:53.482554+07	ASII	2063	BID	1325	6
2026-07-15 20:04:53.482554+07	ASII	2053	BID	1317	7
2026-07-15 20:04:53.482554+07	ASII	2043	BID	1755	8
2026-07-15 20:04:53.482554+07	ASII	2033	BID	1405	9
2026-07-15 20:04:53.482554+07	ASII	2073	ASK	1369	5
2026-07-15 20:04:53.482554+07	ASII	2083	ASK	1481	6
2026-07-15 20:04:53.482554+07	ASII	2093	ASK	1403	7
2026-07-15 20:04:53.482554+07	ASII	2103	ASK	1329	8
2026-07-15 20:04:53.482554+07	ASII	2113	ASK	1699	9
2026-07-15 20:04:54.487838+07	ASII	2073	BID	53636	5
2026-07-15 20:04:54.487838+07	ASII	2063	BID	1311	6
2026-07-15 20:04:54.487838+07	ASII	2053	BID	1627	7
2026-07-15 20:04:54.487838+07	ASII	2043	BID	1462	8
2026-07-15 20:04:54.487838+07	ASII	2033	BID	1426	9
2026-07-15 20:04:54.487838+07	ASII	2073	ASK	1310	5
2026-07-15 20:04:54.487838+07	ASII	2083	ASK	1288	6
2026-07-15 20:04:54.487838+07	ASII	2093	ASK	1465	7
2026-07-15 20:04:54.487838+07	ASII	2103	ASK	1307	8
2026-07-15 20:04:54.487838+07	ASII	2113	ASK	1826	9
2026-07-15 20:04:55.496762+07	ASII	2073	BID	51742	5
2026-07-15 20:04:55.496762+07	ASII	2063	BID	1427	6
2026-07-15 20:04:55.496762+07	ASII	2053	BID	1613	7
2026-07-15 20:04:55.496762+07	ASII	2043	BID	1377	8
2026-07-15 20:04:55.496762+07	ASII	2033	BID	1561	9
2026-07-15 20:04:55.496762+07	ASII	2073	ASK	1080	5
2026-07-15 20:04:55.496762+07	ASII	2083	ASK	1295	6
2026-07-15 20:04:55.496762+07	ASII	2093	ASK	1450	7
2026-07-15 20:04:55.496762+07	ASII	2103	ASK	1407	8
2026-07-15 20:04:55.496762+07	ASII	2113	ASK	1420	9
2026-07-15 20:04:56.501026+07	ASII	2073	BID	51137	5
2026-07-15 20:04:56.501026+07	ASII	2063	BID	1356	6
2026-07-15 20:04:56.501026+07	ASII	2053	BID	1481	7
2026-07-15 20:04:56.501026+07	ASII	2043	BID	1662	8
2026-07-15 20:04:56.501026+07	ASII	2033	BID	1604	9
2026-07-15 20:04:56.501026+07	ASII	2073	ASK	1353	5
2026-07-15 20:04:56.501026+07	ASII	2083	ASK	1180	6
2026-07-15 20:04:56.501026+07	ASII	2093	ASK	1534	7
2026-07-15 20:04:56.501026+07	ASII	2103	ASK	1725	8
2026-07-15 20:04:56.501026+07	ASII	2113	ASK	1446	9
2026-07-15 20:04:57.508311+07	ASII	2073	BID	57111	5
2026-07-15 20:04:57.508311+07	ASII	2063	BID	1462	6
2026-07-15 20:04:57.508311+07	ASII	2053	BID	1412	7
2026-07-15 20:04:57.508311+07	ASII	2043	BID	1463	8
2026-07-15 20:04:57.508311+07	ASII	2033	BID	1522	9
2026-07-15 20:04:57.508311+07	ASII	2073	ASK	1099	5
2026-07-15 20:04:57.508311+07	ASII	2083	ASK	1390	6
2026-07-15 20:04:57.508311+07	ASII	2093	ASK	1491	7
2026-07-15 20:04:57.508311+07	ASII	2103	ASK	1351	8
2026-07-15 20:04:57.508311+07	ASII	2113	ASK	1880	9
2026-07-15 20:04:58.517235+07	ASII	2073	BID	56835	5
2026-07-15 20:04:58.517235+07	ASII	2063	BID	1377	6
2026-07-15 20:04:58.517235+07	ASII	2053	BID	1382	7
2026-07-15 20:04:58.517235+07	ASII	2043	BID	1719	8
2026-07-15 20:04:58.517235+07	ASII	2033	BID	1567	9
2026-07-15 20:04:58.517235+07	ASII	2073	ASK	1058	5
2026-07-15 20:04:58.517235+07	ASII	2083	ASK	1528	6
2026-07-15 20:04:58.517235+07	ASII	2093	ASK	1382	7
2026-07-15 20:04:58.517235+07	ASII	2103	ASK	1345	8
2026-07-15 20:04:58.517235+07	ASII	2113	ASK	1853	9
2026-07-15 20:04:59.526313+07	ASII	2073	BID	51489	5
2026-07-15 20:04:59.526313+07	ASII	2063	BID	1555	6
2026-07-15 20:04:59.526313+07	ASII	2053	BID	1444	7
2026-07-15 20:04:59.526313+07	ASII	2043	BID	1391	8
2026-07-15 20:04:59.526313+07	ASII	2033	BID	1416	9
2026-07-15 20:04:59.526313+07	ASII	2073	ASK	1238	5
2026-07-15 20:04:59.526313+07	ASII	2083	ASK	1218	6
2026-07-15 20:04:59.526313+07	ASII	2093	ASK	1633	7
2026-07-15 20:04:59.526313+07	ASII	2103	ASK	1624	8
2026-07-15 20:04:59.526313+07	ASII	2113	ASK	1635	9
2026-07-15 20:05:00.535166+07	ASII	2073	BID	52429	5
2026-07-15 20:05:00.535166+07	ASII	2063	BID	1596	6
2026-07-15 20:05:00.535166+07	ASII	2053	BID	1526	7
2026-07-15 20:05:00.535166+07	ASII	2043	BID	1371	8
2026-07-15 20:05:00.535166+07	ASII	2033	BID	1754	9
2026-07-15 20:05:00.535166+07	ASII	2073	ASK	1021	5
2026-07-15 20:05:00.535166+07	ASII	2083	ASK	1286	6
2026-07-15 20:05:00.535166+07	ASII	2093	ASK	1332	7
2026-07-15 20:05:00.535166+07	ASII	2103	ASK	1360	8
2026-07-15 20:05:00.535166+07	ASII	2113	ASK	1795	9
2026-07-15 20:03:39.779721+07	BBCA	4058	BID	1441	5
2026-07-15 20:03:39.779721+07	BBCA	4048	BID	1262	6
2026-07-15 20:03:39.779721+07	BBCA	4038	BID	1485	7
2026-07-15 20:03:39.779721+07	BBCA	4028	BID	1379	8
2026-07-15 20:03:39.779721+07	BBCA	4018	BID	1632	9
2026-07-15 20:03:39.779721+07	BBCA	4058	ASK	1002	5
2026-07-15 20:03:39.779721+07	BBCA	4068	ASK	1211	6
2026-07-15 20:03:39.779721+07	BBCA	4078	ASK	1630	7
2026-07-15 20:03:39.779721+07	BBCA	4088	ASK	1370	8
2026-07-15 20:03:39.779721+07	BBCA	4098	ASK	1627	9
2026-07-15 20:03:40.790075+07	BBCA	4058	BID	1267	5
2026-07-15 20:03:40.790075+07	BBCA	4048	BID	1476	6
2026-07-15 20:03:40.790075+07	BBCA	4038	BID	1344	7
2026-07-15 20:03:40.790075+07	BBCA	4028	BID	1689	8
2026-07-15 20:03:40.790075+07	BBCA	4018	BID	1719	9
2026-07-15 20:03:40.790075+07	BBCA	4058	ASK	1405	5
2026-07-15 20:03:40.790075+07	BBCA	4068	ASK	1240	6
2026-07-15 20:03:40.790075+07	BBCA	4078	ASK	1233	7
2026-07-15 20:03:40.790075+07	BBCA	4088	ASK	1582	8
2026-07-15 20:03:40.790075+07	BBCA	4098	ASK	1878	9
2026-07-15 20:03:41.803344+07	BBCA	4058	BID	1483	5
2026-07-15 20:03:41.803344+07	BBCA	4048	BID	1533	6
2026-07-15 20:03:41.803344+07	BBCA	4038	BID	1602	7
2026-07-15 20:03:41.803344+07	BBCA	4028	BID	1422	8
2026-07-15 20:03:41.803344+07	BBCA	4018	BID	1686	9
2026-07-15 20:03:41.803344+07	BBCA	4058	ASK	1362	5
2026-07-15 20:03:41.803344+07	BBCA	4068	ASK	1447	6
2026-07-15 20:03:41.803344+07	BBCA	4078	ASK	1380	7
2026-07-15 20:03:41.803344+07	BBCA	4088	ASK	1573	8
2026-07-15 20:03:41.803344+07	BBCA	4098	ASK	1448	9
2026-07-15 20:03:42.813925+07	BBCA	4058	BID	1051	5
2026-07-15 20:03:42.813925+07	BBCA	4048	BID	1425	6
2026-07-15 20:03:42.813925+07	BBCA	4038	BID	1525	7
2026-07-15 20:03:42.813925+07	BBCA	4028	BID	1792	8
2026-07-15 20:03:42.813925+07	BBCA	4018	BID	1737	9
2026-07-15 20:03:42.813925+07	BBCA	4058	ASK	1191	5
2026-07-15 20:03:42.813925+07	BBCA	4068	ASK	1122	6
2026-07-15 20:03:42.813925+07	BBCA	4078	ASK	1590	7
2026-07-15 20:03:42.813925+07	BBCA	4088	ASK	1388	8
2026-07-15 20:03:42.813925+07	BBCA	4098	ASK	1848	9
2026-07-15 20:03:43.823173+07	BBCA	4058	BID	1107	5
2026-07-15 20:03:43.823173+07	BBCA	4048	BID	1291	6
2026-07-15 20:03:43.823173+07	BBCA	4038	BID	1699	7
2026-07-15 20:03:43.823173+07	BBCA	4028	BID	1659	8
2026-07-15 20:03:43.823173+07	BBCA	4018	BID	1467	9
2026-07-15 20:03:43.823173+07	BBCA	4058	ASK	1164	5
2026-07-15 20:03:43.823173+07	BBCA	4068	ASK	1181	6
2026-07-15 20:03:43.823173+07	BBCA	4078	ASK	1588	7
2026-07-15 20:03:43.823173+07	BBCA	4088	ASK	1300	8
2026-07-15 20:03:43.823173+07	BBCA	4098	ASK	1654	9
2026-07-15 20:03:44.831465+07	BBCA	4058	BID	1223	5
2026-07-15 20:03:44.831465+07	BBCA	4048	BID	1496	6
2026-07-15 20:03:44.831465+07	BBCA	4038	BID	1597	7
2026-07-15 20:03:44.831465+07	BBCA	4028	BID	1740	8
2026-07-15 20:03:44.831465+07	BBCA	4018	BID	1785	9
2026-07-15 20:03:44.831465+07	BBCA	4058	ASK	1348	5
2026-07-15 20:03:44.831465+07	BBCA	4068	ASK	1454	6
2026-07-15 20:03:44.831465+07	BBCA	4078	ASK	1213	7
2026-07-15 20:03:44.831465+07	BBCA	4088	ASK	1429	8
2026-07-15 20:03:44.831465+07	BBCA	4098	ASK	1635	9
2026-07-15 20:03:45.841281+07	BBCA	4058	BID	1222	5
2026-07-15 20:03:45.841281+07	BBCA	4048	BID	1282	6
2026-07-15 20:03:45.841281+07	BBCA	4038	BID	1377	7
2026-07-15 20:03:45.841281+07	BBCA	4028	BID	1365	8
2026-07-15 20:03:45.841281+07	BBCA	4018	BID	1599	9
2026-07-15 20:03:45.841281+07	BBCA	4058	ASK	1072	5
2026-07-15 20:03:45.841281+07	BBCA	4068	ASK	1340	6
2026-07-15 20:03:45.841281+07	BBCA	4078	ASK	1644	7
2026-07-15 20:03:45.841281+07	BBCA	4088	ASK	1767	8
2026-07-15 20:03:45.841281+07	BBCA	4098	ASK	1417	9
2026-07-15 20:03:46.847662+07	BBCA	4058	BID	1446	5
2026-07-15 20:03:46.847662+07	BBCA	4048	BID	1131	6
2026-07-15 20:03:46.847662+07	BBCA	4038	BID	1565	7
2026-07-15 20:03:46.847662+07	BBCA	4028	BID	1308	8
2026-07-15 20:03:46.847662+07	BBCA	4018	BID	1420	9
2026-07-15 20:03:46.847662+07	BBCA	4058	ASK	1446	5
2026-07-15 20:03:46.847662+07	BBCA	4068	ASK	1443	6
2026-07-15 20:03:46.847662+07	BBCA	4078	ASK	1503	7
2026-07-15 20:03:46.847662+07	BBCA	4088	ASK	1430	8
2026-07-15 20:03:46.847662+07	BBCA	4098	ASK	1414	9
2026-07-15 20:03:47.856325+07	BBCA	4058	BID	1422	5
2026-07-15 20:03:47.856325+07	BBCA	4048	BID	1304	6
2026-07-15 20:03:47.856325+07	BBCA	4038	BID	1219	7
2026-07-15 20:03:47.856325+07	BBCA	4028	BID	1607	8
2026-07-15 20:03:47.856325+07	BBCA	4018	BID	1732	9
2026-07-15 20:03:47.856325+07	BBCA	4058	ASK	1489	5
2026-07-15 20:03:47.856325+07	BBCA	4068	ASK	1191	6
2026-07-15 20:03:47.856325+07	BBCA	4078	ASK	1539	7
2026-07-15 20:03:47.856325+07	BBCA	4088	ASK	1553	8
2026-07-15 20:03:47.856325+07	BBCA	4098	ASK	1879	9
2026-07-15 20:03:48.862804+07	BBCA	4058	BID	1278	5
2026-07-15 20:03:48.862804+07	BBCA	4048	BID	1497	6
2026-07-15 20:03:48.862804+07	BBCA	4038	BID	1688	7
2026-07-15 20:03:48.862804+07	BBCA	4028	BID	1635	8
2026-07-15 20:03:48.862804+07	BBCA	4018	BID	1857	9
2026-07-15 20:03:48.862804+07	BBCA	4058	ASK	1399	5
2026-07-15 20:03:48.862804+07	BBCA	4068	ASK	1326	6
2026-07-15 20:03:48.862804+07	BBCA	4078	ASK	1560	7
2026-07-15 20:03:48.862804+07	BBCA	4088	ASK	1623	8
2026-07-15 20:03:48.862804+07	BBCA	4098	ASK	1883	9
2026-07-15 20:03:49.870779+07	BBCA	4058	BID	1019	5
2026-07-15 20:03:49.870779+07	BBCA	4048	BID	1511	6
2026-07-15 20:03:49.870779+07	BBCA	4038	BID	1226	7
2026-07-15 20:03:49.870779+07	BBCA	4028	BID	1531	8
2026-07-15 20:03:49.870779+07	BBCA	4018	BID	1593	9
2026-07-15 20:03:49.870779+07	BBCA	4058	ASK	1219	5
2026-07-15 20:03:49.870779+07	BBCA	4068	ASK	1312	6
2026-07-15 20:03:49.870779+07	BBCA	4078	ASK	1488	7
2026-07-15 20:03:49.870779+07	BBCA	4088	ASK	1735	8
2026-07-15 20:03:49.870779+07	BBCA	4098	ASK	1501	9
2026-07-15 20:03:50.879092+07	BBCA	4058	BID	1020	5
2026-07-15 20:03:50.879092+07	BBCA	4048	BID	1399	6
2026-07-15 20:03:50.879092+07	BBCA	4038	BID	1277	7
2026-07-15 20:03:50.879092+07	BBCA	4028	BID	1689	8
2026-07-15 20:03:50.879092+07	BBCA	4018	BID	1898	9
2026-07-15 20:03:50.879092+07	BBCA	4058	ASK	1426	5
2026-07-15 20:03:50.879092+07	BBCA	4068	ASK	1488	6
2026-07-15 20:03:50.879092+07	BBCA	4078	ASK	1534	7
2026-07-15 20:03:50.879092+07	BBCA	4088	ASK	1785	8
2026-07-15 20:03:50.879092+07	BBCA	4098	ASK	1799	9
2026-07-15 20:03:51.88759+07	BBCA	4058	BID	1170	5
2026-07-15 20:03:51.88759+07	BBCA	4048	BID	1170	6
2026-07-15 20:03:51.88759+07	BBCA	4038	BID	1303	7
2026-07-15 20:03:51.88759+07	BBCA	4028	BID	1491	8
2026-07-15 20:03:51.88759+07	BBCA	4018	BID	1728	9
2026-07-15 20:03:51.88759+07	BBCA	4058	ASK	1396	5
2026-07-15 20:03:51.88759+07	BBCA	4068	ASK	1265	6
2026-07-15 20:03:51.88759+07	BBCA	4078	ASK	1398	7
2026-07-15 20:03:51.88759+07	BBCA	4088	ASK	1697	8
2026-07-15 20:03:51.88759+07	BBCA	4098	ASK	1765	9
2026-07-15 20:03:52.89519+07	BBCA	4058	BID	1443	5
2026-07-15 20:03:52.89519+07	BBCA	4048	BID	1476	6
2026-07-15 20:03:52.89519+07	BBCA	4038	BID	1573	7
2026-07-15 20:03:52.89519+07	BBCA	4028	BID	1708	8
2026-07-15 20:03:52.89519+07	BBCA	4018	BID	1404	9
2026-07-15 20:03:52.89519+07	BBCA	4058	ASK	1413	5
2026-07-15 20:03:52.89519+07	BBCA	4068	ASK	1111	6
2026-07-15 20:03:52.89519+07	BBCA	4078	ASK	1234	7
2026-07-15 20:03:52.89519+07	BBCA	4088	ASK	1687	8
2026-07-15 20:03:52.89519+07	BBCA	4098	ASK	1800	9
2026-07-15 20:03:53.903587+07	BBCA	4058	BID	1098	5
2026-07-15 20:03:53.903587+07	BBCA	4048	BID	1160	6
2026-07-15 20:03:53.903587+07	BBCA	4038	BID	1299	7
2026-07-15 20:03:53.903587+07	BBCA	4028	BID	1671	8
2026-07-15 20:03:53.903587+07	BBCA	4018	BID	1596	9
2026-07-15 20:03:53.903587+07	BBCA	4058	ASK	1321	5
2026-07-15 20:03:53.903587+07	BBCA	4068	ASK	1123	6
2026-07-15 20:03:53.903587+07	BBCA	4078	ASK	1633	7
2026-07-15 20:03:53.903587+07	BBCA	4088	ASK	1501	8
2026-07-15 20:03:53.903587+07	BBCA	4098	ASK	1740	9
2026-07-15 20:03:54.91085+07	BBCA	4058	BID	1076	5
2026-07-15 20:03:54.91085+07	BBCA	4048	BID	1223	6
2026-07-15 20:03:54.91085+07	BBCA	4038	BID	1263	7
2026-07-15 20:03:54.91085+07	BBCA	4028	BID	1666	8
2026-07-15 20:03:54.91085+07	BBCA	4018	BID	1618	9
2026-07-15 20:03:54.91085+07	BBCA	4058	ASK	1413	5
2026-07-15 20:03:54.91085+07	BBCA	4068	ASK	1475	6
2026-07-15 20:03:54.91085+07	BBCA	4078	ASK	1417	7
2026-07-15 20:03:54.91085+07	BBCA	4088	ASK	1634	8
2026-07-15 20:03:54.91085+07	BBCA	4098	ASK	1599	9
2026-07-15 20:03:55.918237+07	BBCA	4058	BID	1420	5
2026-07-15 20:03:55.918237+07	BBCA	4048	BID	1294	6
2026-07-15 20:03:55.918237+07	BBCA	4038	BID	1560	7
2026-07-15 20:03:55.918237+07	BBCA	4028	BID	1534	8
2026-07-15 20:03:55.918237+07	BBCA	4018	BID	1428	9
2026-07-15 20:03:55.918237+07	BBCA	4058	ASK	1463	5
2026-07-15 20:03:55.918237+07	BBCA	4068	ASK	1198	6
2026-07-15 20:03:55.918237+07	BBCA	4078	ASK	1345	7
2026-07-15 20:03:55.918237+07	BBCA	4088	ASK	1413	8
2026-07-15 20:03:55.918237+07	BBCA	4098	ASK	1493	9
2026-07-15 20:03:56.926514+07	BBCA	4058	BID	1003	5
2026-07-15 20:03:56.926514+07	BBCA	4048	BID	1585	6
2026-07-15 20:03:56.926514+07	BBCA	4038	BID	1537	7
2026-07-15 20:03:56.926514+07	BBCA	4028	BID	1513	8
2026-07-15 20:03:56.926514+07	BBCA	4018	BID	1612	9
2026-07-15 20:03:56.926514+07	BBCA	4058	ASK	1453	5
2026-07-15 20:03:56.926514+07	BBCA	4068	ASK	1586	6
2026-07-15 20:03:56.926514+07	BBCA	4078	ASK	1247	7
2026-07-15 20:03:56.926514+07	BBCA	4088	ASK	1458	8
2026-07-15 20:03:56.926514+07	BBCA	4098	ASK	1441	9
2026-07-15 20:03:57.933082+07	BBCA	4058	BID	1406	5
2026-07-15 20:03:57.933082+07	BBCA	4048	BID	1252	6
2026-07-15 20:03:57.933082+07	BBCA	4038	BID	1650	7
2026-07-15 20:03:57.933082+07	BBCA	4028	BID	1411	8
2026-07-15 20:03:57.933082+07	BBCA	4018	BID	1467	9
2026-07-15 20:03:57.933082+07	BBCA	4058	ASK	1271	5
2026-07-15 20:03:57.933082+07	BBCA	4068	ASK	1327	6
2026-07-15 20:03:57.933082+07	BBCA	4078	ASK	1615	7
2026-07-15 20:03:57.933082+07	BBCA	4088	ASK	1594	8
2026-07-15 20:03:57.933082+07	BBCA	4098	ASK	1761	9
2026-07-15 20:03:58.942512+07	BBCA	4058	BID	1152	5
2026-07-15 20:03:58.942512+07	BBCA	4048	BID	1564	6
2026-07-15 20:03:58.942512+07	BBCA	4038	BID	1614	7
2026-07-15 20:03:58.942512+07	BBCA	4028	BID	1764	8
2026-07-15 20:03:58.942512+07	BBCA	4018	BID	1746	9
2026-07-15 20:03:58.942512+07	BBCA	4058	ASK	1454	5
2026-07-15 20:03:58.942512+07	BBCA	4068	ASK	1449	6
2026-07-15 20:03:58.942512+07	BBCA	4078	ASK	1464	7
2026-07-15 20:03:58.942512+07	BBCA	4088	ASK	1627	8
2026-07-15 20:03:58.942512+07	BBCA	4098	ASK	1796	9
2026-07-15 20:03:59.948972+07	BBCA	4058	BID	1152	5
2026-07-15 20:03:59.948972+07	BBCA	4048	BID	1351	6
2026-07-15 20:03:59.948972+07	BBCA	4038	BID	1501	7
2026-07-15 20:03:59.948972+07	BBCA	4028	BID	1602	8
2026-07-15 20:03:59.948972+07	BBCA	4018	BID	1449	9
2026-07-15 20:03:59.948972+07	BBCA	4058	ASK	1071	5
2026-07-15 20:03:59.948972+07	BBCA	4068	ASK	1552	6
2026-07-15 20:03:59.948972+07	BBCA	4078	ASK	1670	7
2026-07-15 20:03:59.948972+07	BBCA	4088	ASK	1627	8
2026-07-15 20:03:59.948972+07	BBCA	4098	ASK	1464	9
2026-07-15 20:04:00.958493+07	BBCA	4058	BID	1103	5
2026-07-15 20:04:00.958493+07	BBCA	4048	BID	1114	6
2026-07-15 20:04:00.958493+07	BBCA	4038	BID	1253	7
2026-07-15 20:04:00.958493+07	BBCA	4028	BID	1679	8
2026-07-15 20:04:00.958493+07	BBCA	4018	BID	1863	9
2026-07-15 20:04:00.958493+07	BBCA	4058	ASK	1208	5
2026-07-15 20:04:00.958493+07	BBCA	4068	ASK	1293	6
2026-07-15 20:04:00.958493+07	BBCA	4078	ASK	1429	7
2026-07-15 20:04:00.958493+07	BBCA	4088	ASK	1356	8
2026-07-15 20:04:00.958493+07	BBCA	4098	ASK	1729	9
2026-07-15 20:04:01.964637+07	BBCA	4058	BID	1276	5
2026-07-15 20:04:01.964637+07	BBCA	4048	BID	1351	6
2026-07-15 20:04:01.964637+07	BBCA	4038	BID	1247	7
2026-07-15 20:04:01.964637+07	BBCA	4028	BID	1501	8
2026-07-15 20:04:01.964637+07	BBCA	4018	BID	1673	9
2026-07-15 20:04:01.964637+07	BBCA	4058	ASK	1140	5
2026-07-15 20:04:01.964637+07	BBCA	4068	ASK	1530	6
2026-07-15 20:04:01.964637+07	BBCA	4078	ASK	1667	7
2026-07-15 20:04:01.964637+07	BBCA	4088	ASK	1609	8
2026-07-15 20:04:01.964637+07	BBCA	4098	ASK	1481	9
2026-07-15 20:04:02.971514+07	BBCA	4058	BID	1075	5
2026-07-15 20:04:02.971514+07	BBCA	4048	BID	1519	6
2026-07-15 20:04:02.971514+07	BBCA	4038	BID	1564	7
2026-07-15 20:04:02.971514+07	BBCA	4028	BID	1629	8
2026-07-15 20:04:02.971514+07	BBCA	4018	BID	1860	9
2026-07-15 20:04:02.971514+07	BBCA	4058	ASK	1381	5
2026-07-15 20:04:02.971514+07	BBCA	4068	ASK	1242	6
2026-07-15 20:04:02.971514+07	BBCA	4078	ASK	1459	7
2026-07-15 20:04:02.971514+07	BBCA	4088	ASK	1666	8
2026-07-15 20:04:02.971514+07	BBCA	4098	ASK	1584	9
2026-07-15 20:04:03.980721+07	BBCA	4058	BID	1431	5
2026-07-15 20:04:03.980721+07	BBCA	4048	BID	1145	6
2026-07-15 20:04:03.980721+07	BBCA	4038	BID	1684	7
2026-07-15 20:04:03.980721+07	BBCA	4028	BID	1333	8
2026-07-15 20:04:03.980721+07	BBCA	4018	BID	1872	9
2026-07-15 20:04:03.980721+07	BBCA	4058	ASK	1371	5
2026-07-15 20:04:03.980721+07	BBCA	4068	ASK	1316	6
2026-07-15 20:04:03.980721+07	BBCA	4078	ASK	1367	7
2026-07-15 20:04:03.980721+07	BBCA	4088	ASK	1739	8
2026-07-15 20:04:03.980721+07	BBCA	4098	ASK	1808	9
2026-07-15 20:04:04.988017+07	BBCA	4058	BID	1091	5
2026-07-15 20:04:04.988017+07	BBCA	4048	BID	1319	6
2026-07-15 20:04:04.988017+07	BBCA	4038	BID	1347	7
2026-07-15 20:04:04.988017+07	BBCA	4028	BID	1488	8
2026-07-15 20:04:04.988017+07	BBCA	4018	BID	1699	9
2026-07-15 20:04:04.988017+07	BBCA	4058	ASK	1298	5
2026-07-15 20:04:04.988017+07	BBCA	4068	ASK	1457	6
2026-07-15 20:04:04.988017+07	BBCA	4078	ASK	1642	7
2026-07-15 20:04:04.988017+07	BBCA	4088	ASK	1783	8
2026-07-15 20:04:04.988017+07	BBCA	4098	ASK	1675	9
2026-07-15 20:04:05.995366+07	BBCA	4058	BID	1424	5
2026-07-15 20:04:05.995366+07	BBCA	4048	BID	1384	6
2026-07-15 20:04:05.995366+07	BBCA	4038	BID	1637	7
2026-07-15 20:04:05.995366+07	BBCA	4028	BID	1514	8
2026-07-15 20:04:05.995366+07	BBCA	4018	BID	1651	9
2026-07-15 20:04:05.995366+07	BBCA	4058	ASK	1420	5
2026-07-15 20:04:05.995366+07	BBCA	4068	ASK	1340	6
2026-07-15 20:04:05.995366+07	BBCA	4078	ASK	1237	7
2026-07-15 20:04:05.995366+07	BBCA	4088	ASK	1527	8
2026-07-15 20:04:05.995366+07	BBCA	4098	ASK	1610	9
2026-07-15 20:04:07.003512+07	BBCA	4058	BID	1198	5
2026-07-15 20:04:07.003512+07	BBCA	4048	BID	1121	6
2026-07-15 20:04:07.003512+07	BBCA	4038	BID	1453	7
2026-07-15 20:04:07.003512+07	BBCA	4028	BID	1772	8
2026-07-15 20:04:07.003512+07	BBCA	4018	BID	1451	9
2026-07-15 20:04:07.003512+07	BBCA	4058	ASK	1262	5
2026-07-15 20:04:07.003512+07	BBCA	4068	ASK	1239	6
2026-07-15 20:04:07.003512+07	BBCA	4078	ASK	1332	7
2026-07-15 20:04:07.003512+07	BBCA	4088	ASK	1638	8
2026-07-15 20:04:07.003512+07	BBCA	4098	ASK	1450	9
2026-07-15 20:04:08.010798+07	BBCA	4058	BID	1147	5
2026-07-15 20:04:08.010798+07	BBCA	4048	BID	1353	6
2026-07-15 20:04:08.010798+07	BBCA	4038	BID	1687	7
2026-07-15 20:04:08.010798+07	BBCA	4028	BID	1795	8
2026-07-15 20:04:08.010798+07	BBCA	4018	BID	1401	9
2026-07-15 20:04:08.010798+07	BBCA	4058	ASK	1402	5
2026-07-15 20:04:08.010798+07	BBCA	4068	ASK	1163	6
2026-07-15 20:04:08.010798+07	BBCA	4078	ASK	1435	7
2026-07-15 20:04:08.010798+07	BBCA	4088	ASK	1794	8
2026-07-15 20:04:08.010798+07	BBCA	4098	ASK	1636	9
2026-07-15 20:04:09.017458+07	BBCA	4058	BID	1259	5
2026-07-15 20:04:09.017458+07	BBCA	4048	BID	1318	6
2026-07-15 20:04:09.017458+07	BBCA	4038	BID	1304	7
2026-07-15 20:04:09.017458+07	BBCA	4028	BID	1589	8
2026-07-15 20:04:09.017458+07	BBCA	4018	BID	1686	9
2026-07-15 20:04:09.017458+07	BBCA	4058	ASK	1416	5
2026-07-15 20:04:09.017458+07	BBCA	4068	ASK	1248	6
2026-07-15 20:04:09.017458+07	BBCA	4078	ASK	1318	7
2026-07-15 20:04:09.017458+07	BBCA	4088	ASK	1779	8
2026-07-15 20:04:09.017458+07	BBCA	4098	ASK	1490	9
2026-07-15 20:04:10.026726+07	BBCA	4058	BID	1263	5
2026-07-15 20:04:10.026726+07	BBCA	4048	BID	1380	6
2026-07-15 20:04:10.026726+07	BBCA	4038	BID	1413	7
2026-07-15 20:04:10.026726+07	BBCA	4028	BID	1418	8
2026-07-15 20:04:10.026726+07	BBCA	4018	BID	1857	9
2026-07-15 20:04:10.026726+07	BBCA	4058	ASK	1330	5
2026-07-15 20:04:10.026726+07	BBCA	4068	ASK	1331	6
2026-07-15 20:04:10.026726+07	BBCA	4078	ASK	1336	7
2026-07-15 20:04:10.026726+07	BBCA	4088	ASK	1440	8
2026-07-15 20:04:10.026726+07	BBCA	4098	ASK	1661	9
2026-07-15 20:04:11.034092+07	BBCA	4058	BID	1034	5
2026-07-15 20:04:11.034092+07	BBCA	4048	BID	1485	6
2026-07-15 20:04:11.034092+07	BBCA	4038	BID	1496	7
2026-07-15 20:04:11.034092+07	BBCA	4028	BID	1753	8
2026-07-15 20:04:11.034092+07	BBCA	4018	BID	1424	9
2026-07-15 20:04:11.034092+07	BBCA	4058	ASK	1232	5
2026-07-15 20:04:11.034092+07	BBCA	4068	ASK	1581	6
2026-07-15 20:04:11.034092+07	BBCA	4078	ASK	1314	7
2026-07-15 20:04:11.034092+07	BBCA	4088	ASK	1436	8
2026-07-15 20:04:11.034092+07	BBCA	4098	ASK	1455	9
2026-07-15 20:04:12.042377+07	BBCA	4058	BID	1025	5
2026-07-15 20:04:12.042377+07	BBCA	4048	BID	1435	6
2026-07-15 20:04:12.042377+07	BBCA	4038	BID	1529	7
2026-07-15 20:04:12.042377+07	BBCA	4028	BID	1367	8
2026-07-15 20:04:12.042377+07	BBCA	4018	BID	1643	9
2026-07-15 20:04:12.042377+07	BBCA	4058	ASK	1089	5
2026-07-15 20:04:12.042377+07	BBCA	4068	ASK	1190	6
2026-07-15 20:04:12.042377+07	BBCA	4078	ASK	1285	7
2026-07-15 20:04:12.042377+07	BBCA	4088	ASK	1645	8
2026-07-15 20:04:12.042377+07	BBCA	4098	ASK	1728	9
2026-07-15 20:04:13.048636+07	BBCA	4058	BID	1244	5
2026-07-15 20:04:13.048636+07	BBCA	4048	BID	1592	6
2026-07-15 20:04:13.048636+07	BBCA	4038	BID	1231	7
2026-07-15 20:04:13.048636+07	BBCA	4028	BID	1631	8
2026-07-15 20:04:13.048636+07	BBCA	4018	BID	1859	9
2026-07-15 20:04:13.048636+07	BBCA	4058	ASK	1041	5
2026-07-15 20:04:13.048636+07	BBCA	4068	ASK	1447	6
2026-07-15 20:04:13.048636+07	BBCA	4078	ASK	1329	7
2026-07-15 20:04:13.048636+07	BBCA	4088	ASK	1418	8
2026-07-15 20:04:13.048636+07	BBCA	4098	ASK	1677	9
2026-07-15 20:04:14.058221+07	BBCA	4058	BID	1069	5
2026-07-15 20:04:14.058221+07	BBCA	4048	BID	1395	6
2026-07-15 20:04:14.058221+07	BBCA	4038	BID	1652	7
2026-07-15 20:04:14.058221+07	BBCA	4028	BID	1659	8
2026-07-15 20:04:14.058221+07	BBCA	4018	BID	1700	9
2026-07-15 20:04:14.058221+07	BBCA	4058	ASK	1381	5
2026-07-15 20:04:14.058221+07	BBCA	4068	ASK	1316	6
2026-07-15 20:04:14.058221+07	BBCA	4078	ASK	1252	7
2026-07-15 20:04:14.058221+07	BBCA	4088	ASK	1417	8
2026-07-15 20:04:14.058221+07	BBCA	4098	ASK	1764	9
2026-07-15 20:04:15.06379+07	BBCA	4058	BID	1463	5
2026-07-15 20:04:15.06379+07	BBCA	4048	BID	1159	6
2026-07-15 20:04:15.06379+07	BBCA	4038	BID	1311	7
2026-07-15 20:04:15.06379+07	BBCA	4028	BID	1477	8
2026-07-15 20:04:15.06379+07	BBCA	4018	BID	1599	9
2026-07-15 20:04:15.06379+07	BBCA	4058	ASK	1476	5
2026-07-15 20:04:15.06379+07	BBCA	4068	ASK	1537	6
2026-07-15 20:04:15.06379+07	BBCA	4078	ASK	1440	7
2026-07-15 20:04:15.06379+07	BBCA	4088	ASK	1364	8
2026-07-15 20:04:15.06379+07	BBCA	4098	ASK	1608	9
2026-07-15 20:04:16.073272+07	BBCA	4058	BID	1424	5
2026-07-15 20:04:16.073272+07	BBCA	4048	BID	1462	6
2026-07-15 20:04:16.073272+07	BBCA	4038	BID	1554	7
2026-07-15 20:04:16.073272+07	BBCA	4028	BID	1624	8
2026-07-15 20:04:16.073272+07	BBCA	4018	BID	1421	9
2026-07-15 20:04:16.073272+07	BBCA	4058	ASK	1323	5
2026-07-15 20:04:16.073272+07	BBCA	4068	ASK	1293	6
2026-07-15 20:04:16.073272+07	BBCA	4078	ASK	1272	7
2026-07-15 20:04:16.073272+07	BBCA	4088	ASK	1560	8
2026-07-15 20:04:16.073272+07	BBCA	4098	ASK	1540	9
2026-07-15 20:04:17.079674+07	BBCA	4058	BID	1351	5
2026-07-15 20:04:17.079674+07	BBCA	4048	BID	1565	6
2026-07-15 20:04:17.079674+07	BBCA	4038	BID	1675	7
2026-07-15 20:04:17.079674+07	BBCA	4028	BID	1694	8
2026-07-15 20:04:17.079674+07	BBCA	4018	BID	1626	9
2026-07-15 20:04:17.079674+07	BBCA	4058	ASK	1188	5
2026-07-15 20:04:17.079674+07	BBCA	4068	ASK	1505	6
2026-07-15 20:04:17.079674+07	BBCA	4078	ASK	1395	7
2026-07-15 20:04:17.079674+07	BBCA	4088	ASK	1355	8
2026-07-15 20:04:17.079674+07	BBCA	4098	ASK	1458	9
2026-07-15 20:04:18.088231+07	BBCA	4058	BID	1020	5
2026-07-15 20:04:18.088231+07	BBCA	4048	BID	1366	6
2026-07-15 20:04:18.088231+07	BBCA	4038	BID	1500	7
2026-07-15 20:04:18.088231+07	BBCA	4028	BID	1534	8
2026-07-15 20:04:18.088231+07	BBCA	4018	BID	1561	9
2026-07-15 20:04:18.088231+07	BBCA	4058	ASK	1162	5
2026-07-15 20:04:18.088231+07	BBCA	4068	ASK	1236	6
2026-07-15 20:04:18.088231+07	BBCA	4078	ASK	1388	7
2026-07-15 20:04:18.088231+07	BBCA	4088	ASK	1475	8
2026-07-15 20:04:18.088231+07	BBCA	4098	ASK	1658	9
2026-07-15 20:04:19.095822+07	BBCA	4058	BID	1096	5
2026-07-15 20:04:19.095822+07	BBCA	4048	BID	1338	6
2026-07-15 20:04:19.095822+07	BBCA	4038	BID	1699	7
2026-07-15 20:04:19.095822+07	BBCA	4028	BID	1780	8
2026-07-15 20:04:19.095822+07	BBCA	4018	BID	1446	9
2026-07-15 20:04:19.095822+07	BBCA	4058	ASK	1132	5
2026-07-15 20:04:19.095822+07	BBCA	4068	ASK	1123	6
2026-07-15 20:04:19.095822+07	BBCA	4078	ASK	1539	7
2026-07-15 20:04:19.095822+07	BBCA	4088	ASK	1328	8
2026-07-15 20:04:19.095822+07	BBCA	4098	ASK	1896	9
2026-07-15 20:04:20.104267+07	BBCA	4058	BID	1395	5
2026-07-15 20:04:20.104267+07	BBCA	4048	BID	1550	6
2026-07-15 20:04:20.104267+07	BBCA	4038	BID	1386	7
2026-07-15 20:04:20.104267+07	BBCA	4028	BID	1393	8
2026-07-15 20:04:20.104267+07	BBCA	4018	BID	1743	9
2026-07-15 20:04:20.104267+07	BBCA	4058	ASK	1315	5
2026-07-15 20:04:20.104267+07	BBCA	4068	ASK	1156	6
2026-07-15 20:04:20.104267+07	BBCA	4078	ASK	1364	7
2026-07-15 20:04:20.104267+07	BBCA	4088	ASK	1322	8
2026-07-15 20:04:20.104267+07	BBCA	4098	ASK	1640	9
2026-07-15 20:04:21.111578+07	BBCA	4058	BID	1042	5
2026-07-15 20:04:21.111578+07	BBCA	4048	BID	1315	6
2026-07-15 20:04:21.111578+07	BBCA	4038	BID	1262	7
2026-07-15 20:04:21.111578+07	BBCA	4028	BID	1633	8
2026-07-15 20:04:21.111578+07	BBCA	4018	BID	1869	9
2026-07-15 20:04:21.111578+07	BBCA	4058	ASK	1149	5
2026-07-15 20:04:21.111578+07	BBCA	4068	ASK	1567	6
2026-07-15 20:04:21.111578+07	BBCA	4078	ASK	1281	7
2026-07-15 20:04:21.111578+07	BBCA	4088	ASK	1443	8
2026-07-15 20:04:21.111578+07	BBCA	4098	ASK	1511	9
2026-07-15 20:04:22.120134+07	BBCA	4058	BID	1224	5
2026-07-15 20:04:22.120134+07	BBCA	4048	BID	1166	6
2026-07-15 20:04:22.120134+07	BBCA	4038	BID	1612	7
2026-07-15 20:04:22.120134+07	BBCA	4028	BID	1470	8
2026-07-15 20:04:22.120134+07	BBCA	4018	BID	1413	9
2026-07-15 20:04:22.120134+07	BBCA	4058	ASK	1355	5
2026-07-15 20:04:22.120134+07	BBCA	4068	ASK	1540	6
2026-07-15 20:04:22.120134+07	BBCA	4078	ASK	1291	7
2026-07-15 20:04:22.120134+07	BBCA	4088	ASK	1427	8
2026-07-15 20:04:22.120134+07	BBCA	4098	ASK	1410	9
2026-07-15 20:04:23.126868+07	BBCA	4058	BID	1121	5
2026-07-15 20:04:23.126868+07	BBCA	4048	BID	1268	6
2026-07-15 20:04:23.126868+07	BBCA	4038	BID	1291	7
2026-07-15 20:04:23.126868+07	BBCA	4028	BID	1557	8
2026-07-15 20:04:23.126868+07	BBCA	4018	BID	1557	9
2026-07-15 20:04:23.126868+07	BBCA	4058	ASK	1040	5
2026-07-15 20:04:23.126868+07	BBCA	4068	ASK	1120	6
2026-07-15 20:04:23.126868+07	BBCA	4078	ASK	1423	7
2026-07-15 20:04:23.126868+07	BBCA	4088	ASK	1670	8
2026-07-15 20:04:23.126868+07	BBCA	4098	ASK	1414	9
2026-07-15 20:04:24.133304+07	BBCA	4058	BID	1457	5
2026-07-15 20:04:24.133304+07	BBCA	4048	BID	1397	6
2026-07-15 20:04:24.133304+07	BBCA	4038	BID	1244	7
2026-07-15 20:04:24.133304+07	BBCA	4028	BID	1332	8
2026-07-15 20:04:24.133304+07	BBCA	4018	BID	1531	9
2026-07-15 20:04:24.133304+07	BBCA	4058	ASK	1044	5
2026-07-15 20:04:24.133304+07	BBCA	4068	ASK	1189	6
2026-07-15 20:04:24.133304+07	BBCA	4078	ASK	1651	7
2026-07-15 20:04:24.133304+07	BBCA	4088	ASK	1527	8
2026-07-15 20:04:24.133304+07	BBCA	4098	ASK	1783	9
2026-07-15 20:04:25.142398+07	BBCA	4058	BID	1088	5
2026-07-15 20:04:25.142398+07	BBCA	4048	BID	1283	6
2026-07-15 20:04:25.142398+07	BBCA	4038	BID	1621	7
2026-07-15 20:04:25.142398+07	BBCA	4028	BID	1650	8
2026-07-15 20:04:25.142398+07	BBCA	4018	BID	1497	9
2026-07-15 20:04:25.142398+07	BBCA	4058	ASK	1382	5
2026-07-15 20:04:25.142398+07	BBCA	4068	ASK	1309	6
2026-07-15 20:04:25.142398+07	BBCA	4078	ASK	1407	7
2026-07-15 20:04:25.142398+07	BBCA	4088	ASK	1707	8
2026-07-15 20:04:25.142398+07	BBCA	4098	ASK	1663	9
2026-07-15 20:04:26.14884+07	BBCA	4058	BID	1216	5
2026-07-15 20:04:26.14884+07	BBCA	4048	BID	1581	6
2026-07-15 20:04:26.14884+07	BBCA	4038	BID	1427	7
2026-07-15 20:04:26.14884+07	BBCA	4028	BID	1444	8
2026-07-15 20:04:26.14884+07	BBCA	4018	BID	1593	9
2026-07-15 20:04:26.14884+07	BBCA	4058	ASK	1167	5
2026-07-15 20:04:26.14884+07	BBCA	4068	ASK	1156	6
2026-07-15 20:04:26.14884+07	BBCA	4078	ASK	1223	7
2026-07-15 20:04:26.14884+07	BBCA	4088	ASK	1477	8
2026-07-15 20:04:26.14884+07	BBCA	4098	ASK	1697	9
2026-07-15 20:04:27.157191+07	BBCA	4058	BID	1337	5
2026-07-15 20:04:27.157191+07	BBCA	4048	BID	1546	6
2026-07-15 20:04:27.157191+07	BBCA	4038	BID	1217	7
2026-07-15 20:04:27.157191+07	BBCA	4028	BID	1624	8
2026-07-15 20:04:27.157191+07	BBCA	4018	BID	1510	9
2026-07-15 20:04:27.157191+07	BBCA	4058	ASK	1061	5
2026-07-15 20:04:27.157191+07	BBCA	4068	ASK	1372	6
2026-07-15 20:04:27.157191+07	BBCA	4078	ASK	1205	7
2026-07-15 20:04:27.157191+07	BBCA	4088	ASK	1403	8
2026-07-15 20:04:27.157191+07	BBCA	4098	ASK	1445	9
2026-07-15 20:04:28.16357+07	BBCA	4058	BID	1368	5
2026-07-15 20:04:28.16357+07	BBCA	4048	BID	1240	6
2026-07-15 20:04:28.16357+07	BBCA	4038	BID	1422	7
2026-07-15 20:04:28.16357+07	BBCA	4028	BID	1664	8
2026-07-15 20:04:28.16357+07	BBCA	4018	BID	1787	9
2026-07-15 20:04:28.16357+07	BBCA	4058	ASK	1269	5
2026-07-15 20:04:28.16357+07	BBCA	4068	ASK	1275	6
2026-07-15 20:04:28.16357+07	BBCA	4078	ASK	1234	7
2026-07-15 20:04:28.16357+07	BBCA	4088	ASK	1458	8
2026-07-15 20:04:28.16357+07	BBCA	4098	ASK	1874	9
2026-07-15 20:04:29.171631+07	BBCA	4058	BID	1440	5
2026-07-15 20:04:29.171631+07	BBCA	4048	BID	1286	6
2026-07-15 20:04:29.171631+07	BBCA	4038	BID	1642	7
2026-07-15 20:04:29.171631+07	BBCA	4028	BID	1549	8
2026-07-15 20:04:29.171631+07	BBCA	4018	BID	1818	9
2026-07-15 20:04:29.171631+07	BBCA	4058	ASK	1090	5
2026-07-15 20:04:29.171631+07	BBCA	4068	ASK	1470	6
2026-07-15 20:04:29.171631+07	BBCA	4078	ASK	1301	7
2026-07-15 20:04:29.171631+07	BBCA	4088	ASK	1560	8
2026-07-15 20:04:29.171631+07	BBCA	4098	ASK	1454	9
2026-07-15 20:04:30.179374+07	BBCA	4058	BID	1312	5
2026-07-15 20:04:30.179374+07	BBCA	4048	BID	1498	6
2026-07-15 20:04:30.179374+07	BBCA	4038	BID	1532	7
2026-07-15 20:04:30.179374+07	BBCA	4028	BID	1527	8
2026-07-15 20:04:30.179374+07	BBCA	4018	BID	1736	9
2026-07-15 20:04:30.179374+07	BBCA	4058	ASK	1168	5
2026-07-15 20:04:30.179374+07	BBCA	4068	ASK	1406	6
2026-07-15 20:04:30.179374+07	BBCA	4078	ASK	1325	7
2026-07-15 20:04:30.179374+07	BBCA	4088	ASK	1426	8
2026-07-15 20:04:30.179374+07	BBCA	4098	ASK	1418	9
2026-07-15 20:04:31.185465+07	BBCA	4058	BID	58224	5
2026-07-15 20:04:31.185465+07	BBCA	4048	BID	1384	6
2026-07-15 20:04:31.185465+07	BBCA	4038	BID	1204	7
2026-07-15 20:04:31.185465+07	BBCA	4028	BID	1721	8
2026-07-15 20:04:31.185465+07	BBCA	4018	BID	1736	9
2026-07-15 20:04:31.185465+07	BBCA	4058	ASK	1369	5
2026-07-15 20:04:31.185465+07	BBCA	4068	ASK	1599	6
2026-07-15 20:04:31.185465+07	BBCA	4078	ASK	1469	7
2026-07-15 20:04:31.185465+07	BBCA	4088	ASK	1525	8
2026-07-15 20:04:31.185465+07	BBCA	4098	ASK	1743	9
2026-07-15 20:04:32.195064+07	BBCA	4058	BID	50673	5
2026-07-15 20:04:32.195064+07	BBCA	4048	BID	1137	6
2026-07-15 20:04:32.195064+07	BBCA	4038	BID	1503	7
2026-07-15 20:04:32.195064+07	BBCA	4028	BID	1676	8
2026-07-15 20:04:32.195064+07	BBCA	4018	BID	1530	9
2026-07-15 20:04:32.195064+07	BBCA	4058	ASK	1314	5
2026-07-15 20:04:32.195064+07	BBCA	4068	ASK	1145	6
2026-07-15 20:04:32.195064+07	BBCA	4078	ASK	1651	7
2026-07-15 20:04:32.195064+07	BBCA	4088	ASK	1664	8
2026-07-15 20:04:32.195064+07	BBCA	4098	ASK	1603	9
2026-07-15 20:04:33.20119+07	BBCA	4058	BID	53123	5
2026-07-15 20:04:33.20119+07	BBCA	4048	BID	1495	6
2026-07-15 20:04:33.20119+07	BBCA	4038	BID	1267	7
2026-07-15 20:04:33.20119+07	BBCA	4028	BID	1672	8
2026-07-15 20:04:33.20119+07	BBCA	4018	BID	1896	9
2026-07-15 20:04:33.20119+07	BBCA	4058	ASK	1161	5
2026-07-15 20:04:33.20119+07	BBCA	4068	ASK	1209	6
2026-07-15 20:04:33.20119+07	BBCA	4078	ASK	1572	7
2026-07-15 20:04:33.20119+07	BBCA	4088	ASK	1361	8
2026-07-15 20:04:33.20119+07	BBCA	4098	ASK	1813	9
2026-07-15 20:04:34.210881+07	BBCA	4058	BID	52358	5
2026-07-15 20:04:34.210881+07	BBCA	4048	BID	1258	6
2026-07-15 20:04:34.210881+07	BBCA	4038	BID	1370	7
2026-07-15 20:04:34.210881+07	BBCA	4028	BID	1407	8
2026-07-15 20:04:34.210881+07	BBCA	4018	BID	1857	9
2026-07-15 20:04:34.210881+07	BBCA	4058	ASK	1272	5
2026-07-15 20:04:34.210881+07	BBCA	4068	ASK	1461	6
2026-07-15 20:04:34.210881+07	BBCA	4078	ASK	1498	7
2026-07-15 20:04:34.210881+07	BBCA	4088	ASK	1711	8
2026-07-15 20:04:34.210881+07	BBCA	4098	ASK	1613	9
2026-07-15 20:04:35.217325+07	BBCA	4058	BID	54245	5
2026-07-15 20:04:35.217325+07	BBCA	4048	BID	1183	6
2026-07-15 20:04:35.217325+07	BBCA	4038	BID	1220	7
2026-07-15 20:04:35.217325+07	BBCA	4028	BID	1494	8
2026-07-15 20:04:35.217325+07	BBCA	4018	BID	1474	9
2026-07-15 20:04:35.217325+07	BBCA	4058	ASK	1066	5
2026-07-15 20:04:35.217325+07	BBCA	4068	ASK	1287	6
2026-07-15 20:04:35.217325+07	BBCA	4078	ASK	1383	7
2026-07-15 20:04:35.217325+07	BBCA	4088	ASK	1716	8
2026-07-15 20:04:35.217325+07	BBCA	4098	ASK	1822	9
2026-07-15 20:04:36.22613+07	BBCA	4058	BID	50003	5
2026-07-15 20:04:36.22613+07	BBCA	4048	BID	1127	6
2026-07-15 20:04:36.22613+07	BBCA	4038	BID	1552	7
2026-07-15 20:04:36.22613+07	BBCA	4028	BID	1565	8
2026-07-15 20:04:36.22613+07	BBCA	4018	BID	1613	9
2026-07-15 20:04:36.22613+07	BBCA	4058	ASK	1066	5
2026-07-15 20:04:36.22613+07	BBCA	4068	ASK	1228	6
2026-07-15 20:04:36.22613+07	BBCA	4078	ASK	1284	7
2026-07-15 20:04:36.22613+07	BBCA	4088	ASK	1772	8
2026-07-15 20:04:36.22613+07	BBCA	4098	ASK	1876	9
2026-07-15 20:04:37.2313+07	BBCA	4058	BID	53882	5
2026-07-15 20:04:37.2313+07	BBCA	4048	BID	1184	6
2026-07-15 20:04:37.2313+07	BBCA	4038	BID	1481	7
2026-07-15 20:04:37.2313+07	BBCA	4028	BID	1490	8
2026-07-15 20:04:37.2313+07	BBCA	4018	BID	1782	9
2026-07-15 20:04:37.2313+07	BBCA	4058	ASK	1027	5
2026-07-15 20:04:37.2313+07	BBCA	4068	ASK	1506	6
2026-07-15 20:04:37.2313+07	BBCA	4078	ASK	1517	7
2026-07-15 20:04:37.2313+07	BBCA	4088	ASK	1382	8
2026-07-15 20:04:37.2313+07	BBCA	4098	ASK	1603	9
2026-07-15 20:04:38.240034+07	BBCA	4058	BID	57632	5
2026-07-15 20:04:38.240034+07	BBCA	4048	BID	1187	6
2026-07-15 20:04:38.240034+07	BBCA	4038	BID	1519	7
2026-07-15 20:04:38.240034+07	BBCA	4028	BID	1602	8
2026-07-15 20:04:38.240034+07	BBCA	4018	BID	1519	9
2026-07-15 20:04:38.240034+07	BBCA	4058	ASK	1064	5
2026-07-15 20:04:38.240034+07	BBCA	4068	ASK	1524	6
2026-07-15 20:04:38.240034+07	BBCA	4078	ASK	1402	7
2026-07-15 20:04:38.240034+07	BBCA	4088	ASK	1561	8
2026-07-15 20:04:38.240034+07	BBCA	4098	ASK	1431	9
2026-07-15 20:04:39.248611+07	BBCA	4058	BID	59483	5
2026-07-15 20:04:39.248611+07	BBCA	4048	BID	1169	6
2026-07-15 20:04:39.248611+07	BBCA	4038	BID	1409	7
2026-07-15 20:04:39.248611+07	BBCA	4028	BID	1591	8
2026-07-15 20:04:39.248611+07	BBCA	4018	BID	1772	9
2026-07-15 20:04:39.248611+07	BBCA	4058	ASK	1293	5
2026-07-15 20:04:39.248611+07	BBCA	4068	ASK	1180	6
2026-07-15 20:04:39.248611+07	BBCA	4078	ASK	1530	7
2026-07-15 20:04:39.248611+07	BBCA	4088	ASK	1573	8
2026-07-15 20:04:39.248611+07	BBCA	4098	ASK	1592	9
2026-07-15 20:04:40.258345+07	BBCA	4058	BID	56616	5
2026-07-15 20:04:40.258345+07	BBCA	4048	BID	1207	6
2026-07-15 20:04:40.258345+07	BBCA	4038	BID	1504	7
2026-07-15 20:04:40.258345+07	BBCA	4028	BID	1549	8
2026-07-15 20:04:40.258345+07	BBCA	4018	BID	1556	9
2026-07-15 20:04:40.258345+07	BBCA	4058	ASK	1492	5
2026-07-15 20:04:40.258345+07	BBCA	4068	ASK	1209	6
2026-07-15 20:04:40.258345+07	BBCA	4078	ASK	1233	7
2026-07-15 20:04:40.258345+07	BBCA	4088	ASK	1339	8
2026-07-15 20:04:40.258345+07	BBCA	4098	ASK	1524	9
2026-07-15 20:04:41.264324+07	BBCA	4058	BID	56387	5
2026-07-15 20:04:41.264324+07	BBCA	4048	BID	1516	6
2026-07-15 20:04:41.264324+07	BBCA	4038	BID	1441	7
2026-07-15 20:04:41.264324+07	BBCA	4028	BID	1692	8
2026-07-15 20:04:41.264324+07	BBCA	4018	BID	1448	9
2026-07-15 20:04:41.264324+07	BBCA	4058	ASK	1172	5
2026-07-15 20:04:41.264324+07	BBCA	4068	ASK	1566	6
2026-07-15 20:04:41.264324+07	BBCA	4078	ASK	1444	7
2026-07-15 20:04:41.264324+07	BBCA	4088	ASK	1437	8
2026-07-15 20:04:41.264324+07	BBCA	4098	ASK	1479	9
2026-07-15 20:04:42.274577+07	BBCA	4058	BID	53771	5
2026-07-15 20:04:42.274577+07	BBCA	4048	BID	1395	6
2026-07-15 20:04:42.274577+07	BBCA	4038	BID	1637	7
2026-07-15 20:04:42.274577+07	BBCA	4028	BID	1374	8
2026-07-15 20:04:42.274577+07	BBCA	4018	BID	1439	9
2026-07-15 20:04:42.274577+07	BBCA	4058	ASK	1007	5
2026-07-15 20:04:42.274577+07	BBCA	4068	ASK	1340	6
2026-07-15 20:04:42.274577+07	BBCA	4078	ASK	1538	7
2026-07-15 20:04:42.274577+07	BBCA	4088	ASK	1679	8
2026-07-15 20:04:42.274577+07	BBCA	4098	ASK	1691	9
2026-07-15 20:04:43.279952+07	BBCA	4058	BID	52162	5
2026-07-15 20:04:43.279952+07	BBCA	4048	BID	1492	6
2026-07-15 20:04:43.279952+07	BBCA	4038	BID	1663	7
2026-07-15 20:04:43.279952+07	BBCA	4028	BID	1354	8
2026-07-15 20:04:43.279952+07	BBCA	4018	BID	1670	9
2026-07-15 20:04:43.279952+07	BBCA	4058	ASK	1351	5
2026-07-15 20:04:43.279952+07	BBCA	4068	ASK	1219	6
2026-07-15 20:04:43.279952+07	BBCA	4078	ASK	1343	7
2026-07-15 20:04:43.279952+07	BBCA	4088	ASK	1359	8
2026-07-15 20:04:43.279952+07	BBCA	4098	ASK	1820	9
2026-07-15 20:04:44.288631+07	BBCA	4058	BID	58123	5
2026-07-15 20:04:44.288631+07	BBCA	4048	BID	1105	6
2026-07-15 20:04:44.288631+07	BBCA	4038	BID	1231	7
2026-07-15 20:04:44.288631+07	BBCA	4028	BID	1483	8
2026-07-15 20:04:44.288631+07	BBCA	4018	BID	1699	9
2026-07-15 20:04:44.288631+07	BBCA	4058	ASK	1185	5
2026-07-15 20:04:44.288631+07	BBCA	4068	ASK	1197	6
2026-07-15 20:04:44.288631+07	BBCA	4078	ASK	1499	7
2026-07-15 20:04:44.288631+07	BBCA	4088	ASK	1788	8
2026-07-15 20:04:44.288631+07	BBCA	4098	ASK	1716	9
2026-07-15 20:04:45.298012+07	BBCA	4058	BID	57804	5
2026-07-15 20:04:45.298012+07	BBCA	4048	BID	1501	6
2026-07-15 20:04:45.298012+07	BBCA	4038	BID	1595	7
2026-07-15 20:04:45.298012+07	BBCA	4028	BID	1778	8
2026-07-15 20:04:45.298012+07	BBCA	4018	BID	1650	9
2026-07-15 20:04:45.298012+07	BBCA	4058	ASK	1214	5
2026-07-15 20:04:45.298012+07	BBCA	4068	ASK	1396	6
2026-07-15 20:04:45.298012+07	BBCA	4078	ASK	1338	7
2026-07-15 20:04:45.298012+07	BBCA	4088	ASK	1660	8
2026-07-15 20:04:45.298012+07	BBCA	4098	ASK	1683	9
2026-07-15 20:04:46.307123+07	BBCA	4058	BID	59260	5
2026-07-15 20:04:46.307123+07	BBCA	4048	BID	1335	6
2026-07-15 20:04:46.307123+07	BBCA	4038	BID	1428	7
2026-07-15 20:04:46.307123+07	BBCA	4028	BID	1650	8
2026-07-15 20:04:46.307123+07	BBCA	4018	BID	1561	9
2026-07-15 20:04:46.307123+07	BBCA	4058	ASK	1478	5
2026-07-15 20:04:46.307123+07	BBCA	4068	ASK	1516	6
2026-07-15 20:04:46.307123+07	BBCA	4078	ASK	1606	7
2026-07-15 20:04:46.307123+07	BBCA	4088	ASK	1303	8
2026-07-15 20:04:46.307123+07	BBCA	4098	ASK	1478	9
2026-07-15 20:04:47.316881+07	BBCA	4058	BID	55244	5
2026-07-15 20:04:47.316881+07	BBCA	4048	BID	1128	6
2026-07-15 20:04:47.316881+07	BBCA	4038	BID	1496	7
2026-07-15 20:04:47.316881+07	BBCA	4028	BID	1690	8
2026-07-15 20:04:47.316881+07	BBCA	4018	BID	1725	9
2026-07-15 20:04:47.316881+07	BBCA	4058	ASK	1114	5
2026-07-15 20:04:47.316881+07	BBCA	4068	ASK	1305	6
2026-07-15 20:04:47.316881+07	BBCA	4078	ASK	1341	7
2026-07-15 20:04:47.316881+07	BBCA	4088	ASK	1313	8
2026-07-15 20:04:47.316881+07	BBCA	4098	ASK	1721	9
2026-07-15 20:04:48.326913+07	BBCA	4058	BID	59125	5
2026-07-15 20:04:48.326913+07	BBCA	4048	BID	1258	6
2026-07-15 20:04:48.326913+07	BBCA	4038	BID	1609	7
2026-07-15 20:04:48.326913+07	BBCA	4028	BID	1366	8
2026-07-15 20:04:48.326913+07	BBCA	4018	BID	1750	9
2026-07-15 20:04:48.326913+07	BBCA	4058	ASK	1278	5
2026-07-15 20:04:48.326913+07	BBCA	4068	ASK	1306	6
2026-07-15 20:04:48.326913+07	BBCA	4078	ASK	1586	7
2026-07-15 20:04:48.326913+07	BBCA	4088	ASK	1554	8
2026-07-15 20:04:48.326913+07	BBCA	4098	ASK	1694	9
2026-07-15 20:04:49.337936+07	BBCA	4058	BID	50425	5
2026-07-15 20:04:49.337936+07	BBCA	4048	BID	1170	6
2026-07-15 20:04:49.337936+07	BBCA	4038	BID	1539	7
2026-07-15 20:04:49.337936+07	BBCA	4028	BID	1615	8
2026-07-15 20:04:49.337936+07	BBCA	4018	BID	1421	9
2026-07-15 20:04:49.337936+07	BBCA	4058	ASK	1095	5
2026-07-15 20:04:49.337936+07	BBCA	4068	ASK	1396	6
2026-07-15 20:04:49.337936+07	BBCA	4078	ASK	1225	7
2026-07-15 20:04:49.337936+07	BBCA	4088	ASK	1518	8
2026-07-15 20:04:49.337936+07	BBCA	4098	ASK	1881	9
2026-07-15 20:04:50.347606+07	BBCA	4058	BID	57082	5
2026-07-15 20:04:50.347606+07	BBCA	4048	BID	1588	6
2026-07-15 20:04:50.347606+07	BBCA	4038	BID	1445	7
2026-07-15 20:04:50.347606+07	BBCA	4028	BID	1560	8
2026-07-15 20:04:50.347606+07	BBCA	4018	BID	1583	9
2026-07-15 20:04:50.347606+07	BBCA	4058	ASK	1351	5
2026-07-15 20:04:50.347606+07	BBCA	4068	ASK	1562	6
2026-07-15 20:04:50.347606+07	BBCA	4078	ASK	1638	7
2026-07-15 20:04:50.347606+07	BBCA	4088	ASK	1464	8
2026-07-15 20:04:50.347606+07	BBCA	4098	ASK	1513	9
2026-07-15 20:04:51.357087+07	BBCA	4058	BID	53422	5
2026-07-15 20:04:51.357087+07	BBCA	4048	BID	1542	6
2026-07-15 20:04:51.357087+07	BBCA	4038	BID	1482	7
2026-07-15 20:04:51.357087+07	BBCA	4028	BID	1481	8
2026-07-15 20:04:51.357087+07	BBCA	4018	BID	1403	9
2026-07-15 20:04:51.357087+07	BBCA	4058	ASK	1045	5
2026-07-15 20:04:51.357087+07	BBCA	4068	ASK	1167	6
2026-07-15 20:04:51.357087+07	BBCA	4078	ASK	1273	7
2026-07-15 20:04:51.357087+07	BBCA	4088	ASK	1435	8
2026-07-15 20:04:51.357087+07	BBCA	4098	ASK	1501	9
2026-07-15 20:04:52.368932+07	BBCA	4058	BID	57879	5
2026-07-15 20:04:52.368932+07	BBCA	4048	BID	1535	6
2026-07-15 20:04:52.368932+07	BBCA	4038	BID	1397	7
2026-07-15 20:04:52.368932+07	BBCA	4028	BID	1456	8
2026-07-15 20:04:52.368932+07	BBCA	4018	BID	1444	9
2026-07-15 20:04:52.368932+07	BBCA	4058	ASK	1134	5
2026-07-15 20:04:52.368932+07	BBCA	4068	ASK	1550	6
2026-07-15 20:04:52.368932+07	BBCA	4078	ASK	1680	7
2026-07-15 20:04:52.368932+07	BBCA	4088	ASK	1793	8
2026-07-15 20:04:52.368932+07	BBCA	4098	ASK	1588	9
2026-07-15 20:04:53.378541+07	BBCA	4058	BID	54520	5
2026-07-15 20:04:53.378541+07	BBCA	4048	BID	1198	6
2026-07-15 20:04:53.378541+07	BBCA	4038	BID	1627	7
2026-07-15 20:04:53.378541+07	BBCA	4028	BID	1528	8
2026-07-15 20:04:53.378541+07	BBCA	4018	BID	1706	9
2026-07-15 20:04:53.378541+07	BBCA	4058	ASK	1484	5
2026-07-15 20:04:53.378541+07	BBCA	4068	ASK	1215	6
2026-07-15 20:04:53.378541+07	BBCA	4078	ASK	1271	7
2026-07-15 20:04:53.378541+07	BBCA	4088	ASK	1351	8
2026-07-15 20:04:53.378541+07	BBCA	4098	ASK	1760	9
2026-07-15 20:04:54.386507+07	BBCA	4058	BID	51677	5
2026-07-15 20:04:54.386507+07	BBCA	4048	BID	1593	6
2026-07-15 20:04:54.386507+07	BBCA	4038	BID	1646	7
2026-07-15 20:04:54.386507+07	BBCA	4028	BID	1631	8
2026-07-15 20:04:54.386507+07	BBCA	4018	BID	1560	9
2026-07-15 20:04:54.386507+07	BBCA	4058	ASK	1263	5
2026-07-15 20:04:54.386507+07	BBCA	4068	ASK	1548	6
2026-07-15 20:04:54.386507+07	BBCA	4078	ASK	1370	7
2026-07-15 20:04:54.386507+07	BBCA	4088	ASK	1526	8
2026-07-15 20:04:54.386507+07	BBCA	4098	ASK	1840	9
2026-07-15 20:04:55.397082+07	BBCA	4058	BID	56618	5
2026-07-15 20:04:55.397082+07	BBCA	4048	BID	1322	6
2026-07-15 20:04:55.397082+07	BBCA	4038	BID	1408	7
2026-07-15 20:04:55.397082+07	BBCA	4028	BID	1708	8
2026-07-15 20:04:55.397082+07	BBCA	4018	BID	1695	9
2026-07-15 20:04:55.397082+07	BBCA	4058	ASK	1104	5
2026-07-15 20:04:55.397082+07	BBCA	4068	ASK	1121	6
2026-07-15 20:04:55.397082+07	BBCA	4078	ASK	1553	7
2026-07-15 20:04:55.397082+07	BBCA	4088	ASK	1559	8
2026-07-15 20:04:55.397082+07	BBCA	4098	ASK	1711	9
2026-07-15 20:04:56.406134+07	BBCA	4058	BID	57078	5
2026-07-15 20:04:56.406134+07	BBCA	4048	BID	1572	6
2026-07-15 20:04:56.406134+07	BBCA	4038	BID	1361	7
2026-07-15 20:04:56.406134+07	BBCA	4028	BID	1477	8
2026-07-15 20:04:56.406134+07	BBCA	4018	BID	1863	9
2026-07-15 20:04:56.406134+07	BBCA	4058	ASK	1340	5
2026-07-15 20:04:56.406134+07	BBCA	4068	ASK	1529	6
2026-07-15 20:04:56.406134+07	BBCA	4078	ASK	1202	7
2026-07-15 20:04:56.406134+07	BBCA	4088	ASK	1660	8
2026-07-15 20:04:56.406134+07	BBCA	4098	ASK	1892	9
2026-07-15 20:04:57.414217+07	BBCA	4058	BID	54285	5
2026-07-15 20:04:57.414217+07	BBCA	4048	BID	1436	6
2026-07-15 20:04:57.414217+07	BBCA	4038	BID	1411	7
2026-07-15 20:04:57.414217+07	BBCA	4028	BID	1494	8
2026-07-15 20:04:57.414217+07	BBCA	4018	BID	1888	9
2026-07-15 20:04:57.414217+07	BBCA	4058	ASK	1185	5
2026-07-15 20:04:57.414217+07	BBCA	4068	ASK	1392	6
2026-07-15 20:04:57.414217+07	BBCA	4078	ASK	1318	7
2026-07-15 20:04:57.414217+07	BBCA	4088	ASK	1535	8
2026-07-15 20:04:57.414217+07	BBCA	4098	ASK	1854	9
2026-07-15 20:04:58.423085+07	BBCA	4058	BID	55536	5
2026-07-15 20:04:58.423085+07	BBCA	4048	BID	1457	6
2026-07-15 20:04:58.423085+07	BBCA	4038	BID	1388	7
2026-07-15 20:04:58.423085+07	BBCA	4028	BID	1597	8
2026-07-15 20:04:58.423085+07	BBCA	4018	BID	1627	9
2026-07-15 20:04:58.423085+07	BBCA	4058	ASK	1412	5
2026-07-15 20:04:58.423085+07	BBCA	4068	ASK	1479	6
2026-07-15 20:04:58.423085+07	BBCA	4078	ASK	1528	7
2026-07-15 20:04:58.423085+07	BBCA	4088	ASK	1798	8
2026-07-15 20:04:58.423085+07	BBCA	4098	ASK	1663	9
2026-07-15 20:04:59.427505+07	BBCA	4058	BID	53595	5
2026-07-15 20:04:59.427505+07	BBCA	4048	BID	1141	6
2026-07-15 20:04:59.427505+07	BBCA	4038	BID	1418	7
2026-07-15 20:04:59.427505+07	BBCA	4028	BID	1717	8
2026-07-15 20:04:59.427505+07	BBCA	4018	BID	1544	9
2026-07-15 20:04:59.427505+07	BBCA	4058	ASK	1270	5
2026-07-15 20:04:59.427505+07	BBCA	4068	ASK	1413	6
2026-07-15 20:04:59.427505+07	BBCA	4078	ASK	1526	7
2026-07-15 20:04:59.427505+07	BBCA	4088	ASK	1376	8
2026-07-15 20:04:59.427505+07	BBCA	4098	ASK	1858	9
2026-07-15 20:05:00.432724+07	BBCA	4058	BID	58881	5
2026-07-15 20:05:00.432724+07	BBCA	4048	BID	1553	6
2026-07-15 20:05:00.432724+07	BBCA	4038	BID	1266	7
2026-07-15 20:05:00.432724+07	BBCA	4028	BID	1550	8
2026-07-15 20:05:00.432724+07	BBCA	4018	BID	1440	9
2026-07-15 20:05:00.432724+07	BBCA	4058	ASK	1342	5
2026-07-15 20:05:00.432724+07	BBCA	4068	ASK	1131	6
2026-07-15 20:05:00.432724+07	BBCA	4078	ASK	1488	7
2026-07-15 20:05:00.432724+07	BBCA	4088	ASK	1416	8
2026-07-15 20:05:00.432724+07	BBCA	4098	ASK	1535	9
2026-07-15 20:05:01.441732+07	BBCA	4058	BID	57080	5
2026-07-15 20:05:01.441732+07	BBCA	4048	BID	1218	6
2026-07-15 20:05:01.441732+07	BBCA	4038	BID	1690	7
2026-07-15 20:05:01.441732+07	BBCA	4028	BID	1437	8
2026-07-15 20:05:01.441732+07	BBCA	4018	BID	1447	9
2026-07-15 20:05:01.441732+07	BBCA	4058	ASK	1289	5
2026-07-15 20:05:01.441732+07	BBCA	4068	ASK	1267	6
2026-07-15 20:05:01.441732+07	BBCA	4078	ASK	1390	7
2026-07-15 20:05:01.441732+07	BBCA	4088	ASK	1621	8
2026-07-15 20:05:01.441732+07	BBCA	4098	ASK	1499	9
2026-07-15 20:05:02.446317+07	BBCA	4058	BID	54510	5
2026-07-15 20:05:02.446317+07	BBCA	4048	BID	1146	6
2026-07-15 20:05:02.446317+07	BBCA	4038	BID	1685	7
2026-07-15 20:05:02.446317+07	BBCA	4028	BID	1423	8
2026-07-15 20:05:02.446317+07	BBCA	4018	BID	1510	9
2026-07-15 20:05:02.446317+07	BBCA	4058	ASK	1063	5
2026-07-15 20:05:02.446317+07	BBCA	4068	ASK	1215	6
2026-07-15 20:05:02.446317+07	BBCA	4078	ASK	1281	7
2026-07-15 20:05:02.446317+07	BBCA	4088	ASK	1616	8
2026-07-15 20:05:02.446317+07	BBCA	4098	ASK	1776	9
2026-07-15 20:05:03.456061+07	BBCA	4058	BID	55432	5
2026-07-15 20:05:03.456061+07	BBCA	4048	BID	1228	6
2026-07-15 20:05:03.456061+07	BBCA	4038	BID	1265	7
2026-07-15 20:05:03.456061+07	BBCA	4028	BID	1442	8
2026-07-15 20:05:03.456061+07	BBCA	4018	BID	1678	9
2026-07-15 20:05:03.456061+07	BBCA	4058	ASK	1380	5
2026-07-15 20:05:03.456061+07	BBCA	4068	ASK	1197	6
2026-07-15 20:05:03.456061+07	BBCA	4078	ASK	1615	7
2026-07-15 20:05:03.456061+07	BBCA	4088	ASK	1453	8
2026-07-15 20:05:03.456061+07	BBCA	4098	ASK	1608	9
2026-07-15 20:05:04.460788+07	BBCA	4058	BID	56058	5
2026-07-15 20:05:04.460788+07	BBCA	4048	BID	1111	6
2026-07-15 20:05:04.460788+07	BBCA	4038	BID	1218	7
2026-07-15 20:05:04.460788+07	BBCA	4028	BID	1726	8
2026-07-15 20:05:04.460788+07	BBCA	4018	BID	1421	9
2026-07-15 20:05:04.460788+07	BBCA	4058	ASK	1494	5
2026-07-15 20:05:04.460788+07	BBCA	4068	ASK	1485	6
2026-07-15 20:05:04.460788+07	BBCA	4078	ASK	1410	7
2026-07-15 20:05:04.460788+07	BBCA	4088	ASK	1732	8
2026-07-15 20:05:04.460788+07	BBCA	4098	ASK	1497	9
2026-07-15 20:05:05.471853+07	BBCA	4058	BID	50224	5
2026-07-15 20:05:05.471853+07	BBCA	4048	BID	1264	6
2026-07-15 20:05:05.471853+07	BBCA	4038	BID	1553	7
2026-07-15 20:05:05.471853+07	BBCA	4028	BID	1760	8
2026-07-15 20:05:05.471853+07	BBCA	4018	BID	1888	9
2026-07-15 20:05:05.471853+07	BBCA	4058	ASK	1288	5
2026-07-15 20:05:05.471853+07	BBCA	4068	ASK	1496	6
2026-07-15 20:05:05.471853+07	BBCA	4078	ASK	1345	7
2026-07-15 20:05:05.471853+07	BBCA	4088	ASK	1322	8
2026-07-15 20:05:05.471853+07	BBCA	4098	ASK	1622	9
2026-07-15 20:05:06.478955+07	BBCA	4058	BID	53384	5
2026-07-15 20:05:06.478955+07	BBCA	4048	BID	1461	6
2026-07-15 20:05:06.478955+07	BBCA	4038	BID	1308	7
2026-07-15 20:05:06.478955+07	BBCA	4028	BID	1459	8
2026-07-15 20:05:06.478955+07	BBCA	4018	BID	1635	9
2026-07-15 20:05:06.478955+07	BBCA	4058	ASK	1461	5
2026-07-15 20:05:06.478955+07	BBCA	4068	ASK	1520	6
2026-07-15 20:05:06.478955+07	BBCA	4078	ASK	1326	7
2026-07-15 20:05:06.478955+07	BBCA	4088	ASK	1499	8
2026-07-15 20:05:06.478955+07	BBCA	4098	ASK	1438	9
2026-07-15 20:05:07.487953+07	BBCA	4058	BID	54409	5
2026-07-15 20:05:07.487953+07	BBCA	4048	BID	1277	6
2026-07-15 20:05:07.487953+07	BBCA	4038	BID	1333	7
2026-07-15 20:05:07.487953+07	BBCA	4028	BID	1329	8
2026-07-15 20:05:07.487953+07	BBCA	4018	BID	1675	9
2026-07-15 20:05:07.487953+07	BBCA	4058	ASK	1380	5
2026-07-15 20:05:07.487953+07	BBCA	4068	ASK	1467	6
2026-07-15 20:05:07.487953+07	BBCA	4078	ASK	1564	7
2026-07-15 20:05:07.487953+07	BBCA	4088	ASK	1777	8
2026-07-15 20:05:07.487953+07	BBCA	4098	ASK	1814	9
2026-07-15 20:05:08.496165+07	BBCA	4058	BID	58179	5
2026-07-15 20:05:08.496165+07	BBCA	4048	BID	1587	6
2026-07-15 20:05:08.496165+07	BBCA	4038	BID	1220	7
2026-07-15 20:05:08.496165+07	BBCA	4028	BID	1450	8
2026-07-15 20:05:08.496165+07	BBCA	4018	BID	1792	9
2026-07-15 20:05:08.496165+07	BBCA	4058	ASK	1476	5
2026-07-15 20:05:08.496165+07	BBCA	4068	ASK	1468	6
2026-07-15 20:05:08.496165+07	BBCA	4078	ASK	1336	7
2026-07-15 20:05:08.496165+07	BBCA	4088	ASK	1794	8
2026-07-15 20:05:08.496165+07	BBCA	4098	ASK	1481	9
2026-07-15 20:05:09.505374+07	BBCA	4058	BID	51666	5
2026-07-15 20:05:09.505374+07	BBCA	4048	BID	1184	6
2026-07-15 20:05:09.505374+07	BBCA	4038	BID	1239	7
2026-07-15 20:05:09.505374+07	BBCA	4028	BID	1491	8
2026-07-15 20:05:09.505374+07	BBCA	4018	BID	1805	9
2026-07-15 20:05:09.505374+07	BBCA	4058	ASK	1250	5
2026-07-15 20:05:09.505374+07	BBCA	4068	ASK	1481	6
2026-07-15 20:05:09.505374+07	BBCA	4078	ASK	1212	7
2026-07-15 20:05:09.505374+07	BBCA	4088	ASK	1600	8
2026-07-15 20:05:09.505374+07	BBCA	4098	ASK	1565	9
2026-07-15 20:05:10.515232+07	BBCA	4058	BID	56048	5
2026-07-15 20:05:10.515232+07	BBCA	4048	BID	1333	6
2026-07-15 20:05:10.515232+07	BBCA	4038	BID	1457	7
2026-07-15 20:05:10.515232+07	BBCA	4028	BID	1418	8
2026-07-15 20:05:10.515232+07	BBCA	4018	BID	1721	9
2026-07-15 20:05:10.515232+07	BBCA	4058	ASK	1303	5
2026-07-15 20:05:10.515232+07	BBCA	4068	ASK	1441	6
2026-07-15 20:05:10.515232+07	BBCA	4078	ASK	1317	7
2026-07-15 20:05:10.515232+07	BBCA	4088	ASK	1327	8
2026-07-15 20:05:10.515232+07	BBCA	4098	ASK	1560	9
2026-07-15 20:05:11.524858+07	BBCA	4058	BID	51504	5
2026-07-15 20:05:11.524858+07	BBCA	4048	BID	1312	6
2026-07-15 20:05:11.524858+07	BBCA	4038	BID	1627	7
2026-07-15 20:05:11.524858+07	BBCA	4028	BID	1771	8
2026-07-15 20:05:11.524858+07	BBCA	4018	BID	1886	9
2026-07-15 20:05:11.524858+07	BBCA	4058	ASK	1177	5
2026-07-15 20:05:11.524858+07	BBCA	4068	ASK	1400	6
2026-07-15 20:05:11.524858+07	BBCA	4078	ASK	1448	7
2026-07-15 20:05:11.524858+07	BBCA	4088	ASK	1382	8
2026-07-15 20:05:11.524858+07	BBCA	4098	ASK	1523	9
2026-07-15 20:05:12.532721+07	BBCA	4058	BID	57822	5
2026-07-15 20:05:12.532721+07	BBCA	4048	BID	1532	6
2026-07-15 20:05:12.532721+07	BBCA	4038	BID	1654	7
2026-07-15 20:05:12.532721+07	BBCA	4028	BID	1309	8
2026-07-15 20:05:12.532721+07	BBCA	4018	BID	1493	9
2026-07-15 20:05:12.532721+07	BBCA	4058	ASK	1054	5
2026-07-15 20:05:12.532721+07	BBCA	4068	ASK	1208	6
2026-07-15 20:05:12.532721+07	BBCA	4078	ASK	1464	7
2026-07-15 20:05:12.532721+07	BBCA	4088	ASK	1325	8
2026-07-15 20:05:12.532721+07	BBCA	4098	ASK	1506	9
2026-07-15 20:05:13.542183+07	BBCA	4058	BID	52531	5
2026-07-15 20:05:13.542183+07	BBCA	4048	BID	1275	6
2026-07-15 20:05:13.542183+07	BBCA	4038	BID	1535	7
2026-07-15 20:05:13.542183+07	BBCA	4028	BID	1684	8
2026-07-15 20:05:13.542183+07	BBCA	4018	BID	1548	9
2026-07-15 20:05:13.542183+07	BBCA	4058	ASK	1384	5
2026-07-15 20:05:13.542183+07	BBCA	4068	ASK	1191	6
2026-07-15 20:05:13.542183+07	BBCA	4078	ASK	1695	7
2026-07-15 20:05:13.542183+07	BBCA	4088	ASK	1439	8
2026-07-15 20:05:13.542183+07	BBCA	4098	ASK	1762	9
2026-07-15 20:05:14.548103+07	BBCA	4058	BID	55280	5
2026-07-15 20:05:14.548103+07	BBCA	4048	BID	1245	6
2026-07-15 20:05:14.548103+07	BBCA	4038	BID	1523	7
2026-07-15 20:05:14.548103+07	BBCA	4028	BID	1621	8
2026-07-15 20:05:14.548103+07	BBCA	4018	BID	1667	9
2026-07-15 20:05:14.548103+07	BBCA	4058	ASK	1362	5
2026-07-15 20:05:14.548103+07	BBCA	4068	ASK	1500	6
2026-07-15 20:05:14.548103+07	BBCA	4078	ASK	1243	7
2026-07-15 20:05:14.548103+07	BBCA	4088	ASK	1372	8
2026-07-15 20:05:14.548103+07	BBCA	4098	ASK	1603	9
2026-07-15 20:05:15.559087+07	BBCA	4058	BID	50258	5
2026-07-15 20:05:15.559087+07	BBCA	4048	BID	1171	6
2026-07-15 20:05:15.559087+07	BBCA	4038	BID	1461	7
2026-07-15 20:05:15.559087+07	BBCA	4028	BID	1313	8
2026-07-15 20:05:15.559087+07	BBCA	4018	BID	1754	9
2026-07-15 20:05:15.559087+07	BBCA	4058	ASK	1093	5
2026-07-15 20:05:15.559087+07	BBCA	4068	ASK	1143	6
2026-07-15 20:05:15.559087+07	BBCA	4078	ASK	1454	7
2026-07-15 20:05:15.559087+07	BBCA	4088	ASK	1371	8
2026-07-15 20:05:15.559087+07	BBCA	4098	ASK	1531	9
2026-07-15 20:05:16.565854+07	BBCA	4058	BID	53592	5
2026-07-15 20:05:16.565854+07	BBCA	4048	BID	1431	6
2026-07-15 20:05:16.565854+07	BBCA	4038	BID	1348	7
2026-07-15 20:05:16.565854+07	BBCA	4028	BID	1711	8
2026-07-15 20:05:16.565854+07	BBCA	4018	BID	1888	9
2026-07-15 20:05:16.565854+07	BBCA	4058	ASK	1072	5
2026-07-15 20:05:16.565854+07	BBCA	4068	ASK	1156	6
2026-07-15 20:05:16.565854+07	BBCA	4078	ASK	1438	7
2026-07-15 20:05:16.565854+07	BBCA	4088	ASK	1306	8
2026-07-15 20:05:16.565854+07	BBCA	4098	ASK	1647	9
2026-07-15 20:05:17.573153+07	BBCA	4058	BID	58869	5
2026-07-15 20:05:17.573153+07	BBCA	4048	BID	1286	6
2026-07-15 20:05:17.573153+07	BBCA	4038	BID	1394	7
2026-07-15 20:05:17.573153+07	BBCA	4028	BID	1316	8
2026-07-15 20:05:17.573153+07	BBCA	4018	BID	1550	9
2026-07-15 20:05:17.573153+07	BBCA	4058	ASK	1303	5
2026-07-15 20:05:17.573153+07	BBCA	4068	ASK	1271	6
2026-07-15 20:05:17.573153+07	BBCA	4078	ASK	1678	7
2026-07-15 20:05:17.573153+07	BBCA	4088	ASK	1766	8
2026-07-15 20:05:17.573153+07	BBCA	4098	ASK	1682	9
2026-07-15 20:05:18.576941+07	BBCA	4058	BID	57602	5
2026-07-15 20:05:18.576941+07	BBCA	4048	BID	1118	6
2026-07-15 20:05:18.576941+07	BBCA	4038	BID	1436	7
2026-07-15 20:05:18.576941+07	BBCA	4028	BID	1503	8
2026-07-15 20:05:18.576941+07	BBCA	4018	BID	1718	9
2026-07-15 20:05:18.576941+07	BBCA	4058	ASK	1085	5
2026-07-15 20:05:18.576941+07	BBCA	4068	ASK	1388	6
2026-07-15 20:05:18.576941+07	BBCA	4078	ASK	1267	7
2026-07-15 20:05:18.576941+07	BBCA	4088	ASK	1345	8
2026-07-15 20:05:18.576941+07	BBCA	4098	ASK	1590	9
2026-07-15 20:05:19.582917+07	BBCA	4058	BID	54662	5
2026-07-15 20:05:19.582917+07	BBCA	4048	BID	1256	6
2026-07-15 20:05:19.582917+07	BBCA	4038	BID	1623	7
2026-07-15 20:05:19.582917+07	BBCA	4028	BID	1495	8
2026-07-15 20:05:19.582917+07	BBCA	4018	BID	1727	9
2026-07-15 20:05:19.582917+07	BBCA	4058	ASK	1101	5
2026-07-15 20:05:19.582917+07	BBCA	4068	ASK	1208	6
2026-07-15 20:05:19.582917+07	BBCA	4078	ASK	1644	7
2026-07-15 20:05:19.582917+07	BBCA	4088	ASK	1775	8
2026-07-15 20:05:19.582917+07	BBCA	4098	ASK	1569	9
2026-07-15 20:03:41.075583+07	BBRI	2135	BID	1202	5
2026-07-15 20:03:41.075583+07	BBRI	2125	BID	1495	6
2026-07-15 20:03:41.075583+07	BBRI	2115	BID	1341	7
2026-07-15 20:03:41.075583+07	BBRI	2105	BID	1359	8
2026-07-15 20:03:41.075583+07	BBRI	2095	BID	1433	9
2026-07-15 20:03:41.075583+07	BBRI	2135	ASK	1435	5
2026-07-15 20:03:41.075583+07	BBRI	2145	ASK	1267	6
2026-07-15 20:03:41.075583+07	BBRI	2155	ASK	1208	7
2026-07-15 20:03:41.075583+07	BBRI	2165	ASK	1527	8
2026-07-15 20:03:41.075583+07	BBRI	2175	ASK	1525	9
2026-07-15 20:03:42.082727+07	BBRI	2135	BID	1330	5
2026-07-15 20:03:42.082727+07	BBRI	2125	BID	1413	6
2026-07-15 20:03:42.082727+07	BBRI	2115	BID	1291	7
2026-07-15 20:03:42.082727+07	BBRI	2105	BID	1731	8
2026-07-15 20:03:42.082727+07	BBRI	2095	BID	1766	9
2026-07-15 20:03:42.082727+07	BBRI	2135	ASK	1281	5
2026-07-15 20:03:42.082727+07	BBRI	2145	ASK	1450	6
2026-07-15 20:03:42.082727+07	BBRI	2155	ASK	1420	7
2026-07-15 20:03:42.082727+07	BBRI	2165	ASK	1653	8
2026-07-15 20:03:42.082727+07	BBRI	2175	ASK	1635	9
2026-07-15 20:03:43.093517+07	BBRI	2135	BID	1362	5
2026-07-15 20:03:43.093517+07	BBRI	2125	BID	1145	6
2026-07-15 20:03:43.093517+07	BBRI	2115	BID	1619	7
2026-07-15 20:03:43.093517+07	BBRI	2105	BID	1761	8
2026-07-15 20:03:43.093517+07	BBRI	2095	BID	1450	9
2026-07-15 20:03:43.093517+07	BBRI	2135	ASK	1437	5
2026-07-15 20:03:43.093517+07	BBRI	2145	ASK	1153	6
2026-07-15 20:03:43.093517+07	BBRI	2155	ASK	1493	7
2026-07-15 20:03:43.093517+07	BBRI	2165	ASK	1406	8
2026-07-15 20:03:43.093517+07	BBRI	2175	ASK	1417	9
2026-07-15 20:03:44.098271+07	BBRI	2135	BID	1465	5
2026-07-15 20:03:44.098271+07	BBRI	2125	BID	1316	6
2026-07-15 20:03:44.098271+07	BBRI	2115	BID	1545	7
2026-07-15 20:03:44.098271+07	BBRI	2105	BID	1610	8
2026-07-15 20:03:44.098271+07	BBRI	2095	BID	1655	9
2026-07-15 20:03:44.098271+07	BBRI	2135	ASK	1175	5
2026-07-15 20:03:44.098271+07	BBRI	2145	ASK	1554	6
2026-07-15 20:03:44.098271+07	BBRI	2155	ASK	1407	7
2026-07-15 20:03:44.098271+07	BBRI	2165	ASK	1678	8
2026-07-15 20:03:44.098271+07	BBRI	2175	ASK	1768	9
2026-07-15 20:03:45.108137+07	BBRI	2135	BID	1191	5
2026-07-15 20:03:45.108137+07	BBRI	2125	BID	1586	6
2026-07-15 20:03:45.108137+07	BBRI	2115	BID	1202	7
2026-07-15 20:03:45.108137+07	BBRI	2105	BID	1557	8
2026-07-15 20:03:45.108137+07	BBRI	2095	BID	1781	9
2026-07-15 20:03:45.108137+07	BBRI	2135	ASK	1469	5
2026-07-15 20:03:45.108137+07	BBRI	2145	ASK	1383	6
2026-07-15 20:03:45.108137+07	BBRI	2155	ASK	1388	7
2026-07-15 20:03:45.108137+07	BBRI	2165	ASK	1589	8
2026-07-15 20:03:45.108137+07	BBRI	2175	ASK	1870	9
2026-07-15 20:03:46.113583+07	BBRI	2135	BID	1469	5
2026-07-15 20:03:46.113583+07	BBRI	2125	BID	1203	6
2026-07-15 20:03:46.113583+07	BBRI	2115	BID	1447	7
2026-07-15 20:03:46.113583+07	BBRI	2105	BID	1393	8
2026-07-15 20:03:46.113583+07	BBRI	2095	BID	1638	9
2026-07-15 20:03:46.113583+07	BBRI	2135	ASK	1375	5
2026-07-15 20:03:46.113583+07	BBRI	2145	ASK	1293	6
2026-07-15 20:03:46.113583+07	BBRI	2155	ASK	1295	7
2026-07-15 20:03:46.113583+07	BBRI	2165	ASK	1795	8
2026-07-15 20:03:46.113583+07	BBRI	2175	ASK	1556	9
2026-07-15 20:03:47.11843+07	BBRI	2135	BID	1346	5
2026-07-15 20:03:47.11843+07	BBRI	2125	BID	1191	6
2026-07-15 20:03:47.11843+07	BBRI	2115	BID	1394	7
2026-07-15 20:03:47.11843+07	BBRI	2105	BID	1689	8
2026-07-15 20:03:47.11843+07	BBRI	2095	BID	1880	9
2026-07-15 20:03:47.11843+07	BBRI	2135	ASK	1340	5
2026-07-15 20:03:47.11843+07	BBRI	2145	ASK	1283	6
2026-07-15 20:03:47.11843+07	BBRI	2155	ASK	1457	7
2026-07-15 20:03:47.11843+07	BBRI	2165	ASK	1775	8
2026-07-15 20:03:47.11843+07	BBRI	2175	ASK	1453	9
2026-07-15 20:03:48.128227+07	BBRI	2135	BID	1003	5
2026-07-15 20:03:48.128227+07	BBRI	2125	BID	1310	6
2026-07-15 20:03:48.128227+07	BBRI	2115	BID	1262	7
2026-07-15 20:03:48.128227+07	BBRI	2105	BID	1456	8
2026-07-15 20:03:48.128227+07	BBRI	2095	BID	1851	9
2026-07-15 20:03:48.128227+07	BBRI	2135	ASK	1150	5
2026-07-15 20:03:48.128227+07	BBRI	2145	ASK	1454	6
2026-07-15 20:03:48.128227+07	BBRI	2155	ASK	1247	7
2026-07-15 20:03:48.128227+07	BBRI	2165	ASK	1558	8
2026-07-15 20:03:48.128227+07	BBRI	2175	ASK	1752	9
2026-07-15 20:03:49.132027+07	BBRI	2135	BID	1019	5
2026-07-15 20:03:49.132027+07	BBRI	2125	BID	1391	6
2026-07-15 20:03:49.132027+07	BBRI	2115	BID	1369	7
2026-07-15 20:03:49.132027+07	BBRI	2105	BID	1777	8
2026-07-15 20:03:49.132027+07	BBRI	2095	BID	1818	9
2026-07-15 20:03:49.132027+07	BBRI	2135	ASK	1187	5
2026-07-15 20:03:49.132027+07	BBRI	2145	ASK	1543	6
2026-07-15 20:03:49.132027+07	BBRI	2155	ASK	1236	7
2026-07-15 20:03:49.132027+07	BBRI	2165	ASK	1519	8
2026-07-15 20:03:49.132027+07	BBRI	2175	ASK	1527	9
2026-07-15 20:03:50.140272+07	BBRI	2135	BID	1083	5
2026-07-15 20:03:50.140272+07	BBRI	2125	BID	1345	6
2026-07-15 20:03:50.140272+07	BBRI	2115	BID	1374	7
2026-07-15 20:03:50.140272+07	BBRI	2105	BID	1477	8
2026-07-15 20:03:50.140272+07	BBRI	2095	BID	1613	9
2026-07-15 20:03:50.140272+07	BBRI	2135	ASK	1311	5
2026-07-15 20:03:50.140272+07	BBRI	2145	ASK	1458	6
2026-07-15 20:03:50.140272+07	BBRI	2155	ASK	1438	7
2026-07-15 20:03:50.140272+07	BBRI	2165	ASK	1539	8
2026-07-15 20:03:50.140272+07	BBRI	2175	ASK	1690	9
2026-07-15 20:03:51.146701+07	BBRI	2135	BID	1025	5
2026-07-15 20:03:51.146701+07	BBRI	2125	BID	1310	6
2026-07-15 20:03:51.146701+07	BBRI	2115	BID	1371	7
2026-07-15 20:03:51.146701+07	BBRI	2105	BID	1512	8
2026-07-15 20:03:51.146701+07	BBRI	2095	BID	1671	9
2026-07-15 20:03:51.146701+07	BBRI	2135	ASK	1193	5
2026-07-15 20:03:51.146701+07	BBRI	2145	ASK	1265	6
2026-07-15 20:03:51.146701+07	BBRI	2155	ASK	1550	7
2026-07-15 20:03:51.146701+07	BBRI	2165	ASK	1312	8
2026-07-15 20:03:51.146701+07	BBRI	2175	ASK	1720	9
2026-07-15 20:03:52.153345+07	BBRI	2135	BID	1098	5
2026-07-15 20:03:52.153345+07	BBRI	2125	BID	1411	6
2026-07-15 20:03:52.153345+07	BBRI	2115	BID	1275	7
2026-07-15 20:03:52.153345+07	BBRI	2105	BID	1630	8
2026-07-15 20:03:52.153345+07	BBRI	2095	BID	1704	9
2026-07-15 20:03:52.153345+07	BBRI	2135	ASK	1226	5
2026-07-15 20:03:52.153345+07	BBRI	2145	ASK	1216	6
2026-07-15 20:03:52.153345+07	BBRI	2155	ASK	1369	7
2026-07-15 20:03:52.153345+07	BBRI	2165	ASK	1503	8
2026-07-15 20:03:52.153345+07	BBRI	2175	ASK	1823	9
2026-07-15 20:03:53.162324+07	BBRI	2135	BID	1056	5
2026-07-15 20:03:53.162324+07	BBRI	2125	BID	1160	6
2026-07-15 20:03:53.162324+07	BBRI	2115	BID	1593	7
2026-07-15 20:03:53.162324+07	BBRI	2105	BID	1494	8
2026-07-15 20:03:53.162324+07	BBRI	2095	BID	1879	9
2026-07-15 20:03:53.162324+07	BBRI	2135	ASK	1042	5
2026-07-15 20:03:53.162324+07	BBRI	2145	ASK	1126	6
2026-07-15 20:03:53.162324+07	BBRI	2155	ASK	1665	7
2026-07-15 20:03:53.162324+07	BBRI	2165	ASK	1300	8
2026-07-15 20:03:53.162324+07	BBRI	2175	ASK	1809	9
2026-07-15 20:03:54.166835+07	BBRI	2135	BID	1240	5
2026-07-15 20:03:54.166835+07	BBRI	2125	BID	1498	6
2026-07-15 20:03:54.166835+07	BBRI	2115	BID	1397	7
2026-07-15 20:03:54.166835+07	BBRI	2105	BID	1764	8
2026-07-15 20:03:54.166835+07	BBRI	2095	BID	1746	9
2026-07-15 20:03:54.166835+07	BBRI	2135	ASK	1404	5
2026-07-15 20:03:54.166835+07	BBRI	2145	ASK	1154	6
2026-07-15 20:03:54.166835+07	BBRI	2155	ASK	1305	7
2026-07-15 20:03:54.166835+07	BBRI	2165	ASK	1766	8
2026-07-15 20:03:54.166835+07	BBRI	2175	ASK	1468	9
2026-07-15 20:03:55.177841+07	BBRI	2135	BID	1055	5
2026-07-15 20:03:55.177841+07	BBRI	2125	BID	1177	6
2026-07-15 20:03:55.177841+07	BBRI	2115	BID	1488	7
2026-07-15 20:03:55.177841+07	BBRI	2105	BID	1541	8
2026-07-15 20:03:55.177841+07	BBRI	2095	BID	1889	9
2026-07-15 20:03:55.177841+07	BBRI	2135	ASK	1015	5
2026-07-15 20:03:55.177841+07	BBRI	2145	ASK	1599	6
2026-07-15 20:03:55.177841+07	BBRI	2155	ASK	1432	7
2026-07-15 20:03:55.177841+07	BBRI	2165	ASK	1448	8
2026-07-15 20:03:55.177841+07	BBRI	2175	ASK	1511	9
2026-07-15 20:03:56.184037+07	BBRI	2135	BID	1170	5
2026-07-15 20:03:56.184037+07	BBRI	2125	BID	1515	6
2026-07-15 20:03:56.184037+07	BBRI	2115	BID	1317	7
2026-07-15 20:03:56.184037+07	BBRI	2105	BID	1759	8
2026-07-15 20:03:56.184037+07	BBRI	2095	BID	1468	9
2026-07-15 20:03:56.184037+07	BBRI	2135	ASK	1302	5
2026-07-15 20:03:56.184037+07	BBRI	2145	ASK	1490	6
2026-07-15 20:03:56.184037+07	BBRI	2155	ASK	1202	7
2026-07-15 20:03:56.184037+07	BBRI	2165	ASK	1370	8
2026-07-15 20:03:56.184037+07	BBRI	2175	ASK	1434	9
2026-07-15 20:03:57.194529+07	BBRI	2135	BID	1340	5
2026-07-15 20:03:57.194529+07	BBRI	2125	BID	1164	6
2026-07-15 20:03:57.194529+07	BBRI	2115	BID	1453	7
2026-07-15 20:03:57.194529+07	BBRI	2105	BID	1485	8
2026-07-15 20:03:57.194529+07	BBRI	2095	BID	1722	9
2026-07-15 20:03:57.194529+07	BBRI	2135	ASK	1461	5
2026-07-15 20:03:57.194529+07	BBRI	2145	ASK	1414	6
2026-07-15 20:03:57.194529+07	BBRI	2155	ASK	1308	7
2026-07-15 20:03:57.194529+07	BBRI	2165	ASK	1339	8
2026-07-15 20:03:57.194529+07	BBRI	2175	ASK	1805	9
2026-07-15 20:03:58.198011+07	BBRI	2135	BID	1424	5
2026-07-15 20:03:58.198011+07	BBRI	2125	BID	1411	6
2026-07-15 20:03:58.198011+07	BBRI	2115	BID	1493	7
2026-07-15 20:03:58.198011+07	BBRI	2105	BID	1788	8
2026-07-15 20:03:58.198011+07	BBRI	2095	BID	1755	9
2026-07-15 20:03:58.198011+07	BBRI	2135	ASK	1211	5
2026-07-15 20:03:58.198011+07	BBRI	2145	ASK	1390	6
2026-07-15 20:03:58.198011+07	BBRI	2155	ASK	1548	7
2026-07-15 20:03:58.198011+07	BBRI	2165	ASK	1377	8
2026-07-15 20:03:58.198011+07	BBRI	2175	ASK	1493	9
2026-07-15 20:03:59.204416+07	BBRI	2135	BID	1478	5
2026-07-15 20:03:59.204416+07	BBRI	2125	BID	1231	6
2026-07-15 20:03:59.204416+07	BBRI	2115	BID	1553	7
2026-07-15 20:03:59.204416+07	BBRI	2105	BID	1790	8
2026-07-15 20:03:59.204416+07	BBRI	2095	BID	1729	9
2026-07-15 20:03:59.204416+07	BBRI	2135	ASK	1447	5
2026-07-15 20:03:59.204416+07	BBRI	2145	ASK	1528	6
2026-07-15 20:03:59.204416+07	BBRI	2155	ASK	1696	7
2026-07-15 20:03:59.204416+07	BBRI	2165	ASK	1509	8
2026-07-15 20:03:59.204416+07	BBRI	2175	ASK	1873	9
2026-07-15 20:04:00.214047+07	BBRI	2135	BID	1256	5
2026-07-15 20:04:00.214047+07	BBRI	2125	BID	1180	6
2026-07-15 20:04:00.214047+07	BBRI	2115	BID	1657	7
2026-07-15 20:04:00.214047+07	BBRI	2105	BID	1396	8
2026-07-15 20:04:00.214047+07	BBRI	2095	BID	1787	9
2026-07-15 20:04:00.214047+07	BBRI	2135	ASK	1057	5
2026-07-15 20:04:00.214047+07	BBRI	2145	ASK	1520	6
2026-07-15 20:04:00.214047+07	BBRI	2155	ASK	1569	7
2026-07-15 20:04:00.214047+07	BBRI	2165	ASK	1406	8
2026-07-15 20:04:00.214047+07	BBRI	2175	ASK	1631	9
2026-07-15 20:04:01.220705+07	BBRI	2135	BID	1070	5
2026-07-15 20:04:01.220705+07	BBRI	2125	BID	1273	6
2026-07-15 20:04:01.220705+07	BBRI	2115	BID	1369	7
2026-07-15 20:04:01.220705+07	BBRI	2105	BID	1492	8
2026-07-15 20:04:01.220705+07	BBRI	2095	BID	1470	9
2026-07-15 20:04:01.220705+07	BBRI	2135	ASK	1487	5
2026-07-15 20:04:01.220705+07	BBRI	2145	ASK	1530	6
2026-07-15 20:04:01.220705+07	BBRI	2155	ASK	1554	7
2026-07-15 20:04:01.220705+07	BBRI	2165	ASK	1518	8
2026-07-15 20:04:01.220705+07	BBRI	2175	ASK	1733	9
2026-07-15 20:04:02.2288+07	BBRI	2135	BID	1268	5
2026-07-15 20:04:02.2288+07	BBRI	2125	BID	1150	6
2026-07-15 20:04:02.2288+07	BBRI	2115	BID	1269	7
2026-07-15 20:04:02.2288+07	BBRI	2105	BID	1395	8
2026-07-15 20:04:02.2288+07	BBRI	2095	BID	1858	9
2026-07-15 20:04:02.2288+07	BBRI	2135	ASK	1451	5
2026-07-15 20:04:02.2288+07	BBRI	2145	ASK	1370	6
2026-07-15 20:04:02.2288+07	BBRI	2155	ASK	1503	7
2026-07-15 20:04:02.2288+07	BBRI	2165	ASK	1503	8
2026-07-15 20:04:02.2288+07	BBRI	2175	ASK	1725	9
2026-07-15 20:04:03.232953+07	BBRI	2135	BID	1264	5
2026-07-15 20:04:03.232953+07	BBRI	2125	BID	1579	6
2026-07-15 20:04:03.232953+07	BBRI	2115	BID	1409	7
2026-07-15 20:04:03.232953+07	BBRI	2105	BID	1641	8
2026-07-15 20:04:03.232953+07	BBRI	2095	BID	1477	9
2026-07-15 20:04:03.232953+07	BBRI	2135	ASK	1232	5
2026-07-15 20:04:03.232953+07	BBRI	2145	ASK	1138	6
2026-07-15 20:04:03.232953+07	BBRI	2155	ASK	1453	7
2026-07-15 20:04:03.232953+07	BBRI	2165	ASK	1350	8
2026-07-15 20:04:03.232953+07	BBRI	2175	ASK	1441	9
2026-07-15 20:04:04.246695+07	BBRI	2135	BID	1238	5
2026-07-15 20:04:04.246695+07	BBRI	2125	BID	1332	6
2026-07-15 20:04:04.246695+07	BBRI	2115	BID	1299	7
2026-07-15 20:04:04.246695+07	BBRI	2105	BID	1488	8
2026-07-15 20:04:04.246695+07	BBRI	2095	BID	1842	9
2026-07-15 20:04:04.246695+07	BBRI	2135	ASK	1450	5
2026-07-15 20:04:04.246695+07	BBRI	2145	ASK	1183	6
2026-07-15 20:04:04.246695+07	BBRI	2155	ASK	1297	7
2026-07-15 20:04:04.246695+07	BBRI	2165	ASK	1301	8
2026-07-15 20:04:04.246695+07	BBRI	2175	ASK	1637	9
2026-07-15 20:04:05.254025+07	BBRI	2135	BID	1280	5
2026-07-15 20:04:05.254025+07	BBRI	2125	BID	1298	6
2026-07-15 20:04:05.254025+07	BBRI	2115	BID	1439	7
2026-07-15 20:04:05.254025+07	BBRI	2105	BID	1581	8
2026-07-15 20:04:05.254025+07	BBRI	2095	BID	1813	9
2026-07-15 20:04:05.254025+07	BBRI	2135	ASK	1123	5
2026-07-15 20:04:05.254025+07	BBRI	2145	ASK	1241	6
2026-07-15 20:04:05.254025+07	BBRI	2155	ASK	1313	7
2026-07-15 20:04:05.254025+07	BBRI	2165	ASK	1761	8
2026-07-15 20:04:05.254025+07	BBRI	2175	ASK	1839	9
2026-07-15 20:04:06.258356+07	BBRI	2135	BID	1094	5
2026-07-15 20:04:06.258356+07	BBRI	2125	BID	1166	6
2026-07-15 20:04:06.258356+07	BBRI	2115	BID	1432	7
2026-07-15 20:04:06.258356+07	BBRI	2105	BID	1633	8
2026-07-15 20:04:06.258356+07	BBRI	2095	BID	1853	9
2026-07-15 20:04:06.258356+07	BBRI	2135	ASK	1041	5
2026-07-15 20:04:06.258356+07	BBRI	2145	ASK	1269	6
2026-07-15 20:04:06.258356+07	BBRI	2155	ASK	1409	7
2026-07-15 20:04:06.258356+07	BBRI	2165	ASK	1495	8
2026-07-15 20:04:06.258356+07	BBRI	2175	ASK	1528	9
2026-07-15 20:04:07.261922+07	BBRI	2135	BID	1311	5
2026-07-15 20:04:07.261922+07	BBRI	2125	BID	1513	6
2026-07-15 20:04:07.261922+07	BBRI	2115	BID	1369	7
2026-07-15 20:04:07.261922+07	BBRI	2105	BID	1418	8
2026-07-15 20:04:07.261922+07	BBRI	2095	BID	1888	9
2026-07-15 20:04:07.261922+07	BBRI	2135	ASK	1290	5
2026-07-15 20:04:07.261922+07	BBRI	2145	ASK	1329	6
2026-07-15 20:04:07.261922+07	BBRI	2155	ASK	1472	7
2026-07-15 20:04:07.261922+07	BBRI	2165	ASK	1467	8
2026-07-15 20:04:07.261922+07	BBRI	2175	ASK	1780	9
2026-07-15 20:04:08.27018+07	BBRI	2135	BID	1165	5
2026-07-15 20:04:08.27018+07	BBRI	2125	BID	1342	6
2026-07-15 20:04:08.27018+07	BBRI	2115	BID	1334	7
2026-07-15 20:04:08.27018+07	BBRI	2105	BID	1777	8
2026-07-15 20:04:08.27018+07	BBRI	2095	BID	1853	9
2026-07-15 20:04:08.27018+07	BBRI	2135	ASK	1469	5
2026-07-15 20:04:08.27018+07	BBRI	2145	ASK	1220	6
2026-07-15 20:04:08.27018+07	BBRI	2155	ASK	1566	7
2026-07-15 20:04:08.27018+07	BBRI	2165	ASK	1581	8
2026-07-15 20:04:08.27018+07	BBRI	2175	ASK	1899	9
2026-07-15 20:04:09.280917+07	BBRI	2135	BID	1147	5
2026-07-15 20:04:09.280917+07	BBRI	2125	BID	1420	6
2026-07-15 20:04:09.280917+07	BBRI	2115	BID	1671	7
2026-07-15 20:04:09.280917+07	BBRI	2105	BID	1391	8
2026-07-15 20:04:09.280917+07	BBRI	2095	BID	1626	9
2026-07-15 20:04:09.280917+07	BBRI	2135	ASK	1107	5
2026-07-15 20:04:09.280917+07	BBRI	2145	ASK	1447	6
2026-07-15 20:04:09.280917+07	BBRI	2155	ASK	1242	7
2026-07-15 20:04:09.280917+07	BBRI	2165	ASK	1354	8
2026-07-15 20:04:09.280917+07	BBRI	2175	ASK	1869	9
2026-07-15 20:04:10.290367+07	BBRI	2135	BID	1334	5
2026-07-15 20:04:10.290367+07	BBRI	2125	BID	1384	6
2026-07-15 20:04:10.290367+07	BBRI	2115	BID	1696	7
2026-07-15 20:04:10.290367+07	BBRI	2105	BID	1418	8
2026-07-15 20:04:10.290367+07	BBRI	2095	BID	1774	9
2026-07-15 20:04:10.290367+07	BBRI	2135	ASK	1131	5
2026-07-15 20:04:10.290367+07	BBRI	2145	ASK	1538	6
2026-07-15 20:04:10.290367+07	BBRI	2155	ASK	1266	7
2026-07-15 20:04:10.290367+07	BBRI	2165	ASK	1543	8
2026-07-15 20:04:10.290367+07	BBRI	2175	ASK	1446	9
2026-07-15 20:04:11.302113+07	BBRI	2135	BID	1253	5
2026-07-15 20:04:11.302113+07	BBRI	2125	BID	1235	6
2026-07-15 20:04:11.302113+07	BBRI	2115	BID	1626	7
2026-07-15 20:04:11.302113+07	BBRI	2105	BID	1540	8
2026-07-15 20:04:11.302113+07	BBRI	2095	BID	1684	9
2026-07-15 20:04:11.302113+07	BBRI	2135	ASK	1471	5
2026-07-15 20:04:11.302113+07	BBRI	2145	ASK	1114	6
2026-07-15 20:04:11.302113+07	BBRI	2155	ASK	1672	7
2026-07-15 20:04:11.302113+07	BBRI	2165	ASK	1590	8
2026-07-15 20:04:11.302113+07	BBRI	2175	ASK	1482	9
2026-07-15 20:04:12.309855+07	BBRI	2135	BID	1066	5
2026-07-15 20:04:12.309855+07	BBRI	2125	BID	1322	6
2026-07-15 20:04:12.309855+07	BBRI	2115	BID	1556	7
2026-07-15 20:04:12.309855+07	BBRI	2105	BID	1636	8
2026-07-15 20:04:12.309855+07	BBRI	2095	BID	1792	9
2026-07-15 20:04:12.309855+07	BBRI	2135	ASK	1001	5
2026-07-15 20:04:12.309855+07	BBRI	2145	ASK	1390	6
2026-07-15 20:04:12.309855+07	BBRI	2155	ASK	1529	7
2026-07-15 20:04:12.309855+07	BBRI	2165	ASK	1333	8
2026-07-15 20:04:12.309855+07	BBRI	2175	ASK	1841	9
2026-07-15 20:04:13.321215+07	BBRI	2135	BID	1264	5
2026-07-15 20:04:13.321215+07	BBRI	2125	BID	1521	6
2026-07-15 20:04:13.321215+07	BBRI	2115	BID	1398	7
2026-07-15 20:04:13.321215+07	BBRI	2105	BID	1393	8
2026-07-15 20:04:13.321215+07	BBRI	2095	BID	1618	9
2026-07-15 20:04:13.321215+07	BBRI	2135	ASK	1416	5
2026-07-15 20:04:13.321215+07	BBRI	2145	ASK	1150	6
2026-07-15 20:04:13.321215+07	BBRI	2155	ASK	1385	7
2026-07-15 20:04:13.321215+07	BBRI	2165	ASK	1533	8
2026-07-15 20:04:13.321215+07	BBRI	2175	ASK	1668	9
2026-07-15 20:04:14.331514+07	BBRI	2135	BID	1387	5
2026-07-15 20:04:14.331514+07	BBRI	2125	BID	1589	6
2026-07-15 20:04:14.331514+07	BBRI	2115	BID	1432	7
2026-07-15 20:04:14.331514+07	BBRI	2105	BID	1434	8
2026-07-15 20:04:14.331514+07	BBRI	2095	BID	1636	9
2026-07-15 20:04:14.331514+07	BBRI	2135	ASK	1039	5
2026-07-15 20:04:14.331514+07	BBRI	2145	ASK	1544	6
2026-07-15 20:04:14.331514+07	BBRI	2155	ASK	1385	7
2026-07-15 20:04:14.331514+07	BBRI	2165	ASK	1558	8
2026-07-15 20:04:14.331514+07	BBRI	2175	ASK	1651	9
2026-07-15 20:04:15.33949+07	BBRI	2135	BID	1384	5
2026-07-15 20:04:15.33949+07	BBRI	2125	BID	1563	6
2026-07-15 20:04:15.33949+07	BBRI	2115	BID	1591	7
2026-07-15 20:04:15.33949+07	BBRI	2105	BID	1691	8
2026-07-15 20:04:15.33949+07	BBRI	2095	BID	1836	9
2026-07-15 20:04:15.33949+07	BBRI	2135	ASK	1107	5
2026-07-15 20:04:15.33949+07	BBRI	2145	ASK	1159	6
2026-07-15 20:04:15.33949+07	BBRI	2155	ASK	1554	7
2026-07-15 20:04:15.33949+07	BBRI	2165	ASK	1462	8
2026-07-15 20:04:15.33949+07	BBRI	2175	ASK	1666	9
2026-07-15 20:04:16.350354+07	BBRI	2135	BID	1401	5
2026-07-15 20:04:16.350354+07	BBRI	2125	BID	1228	6
2026-07-15 20:04:16.350354+07	BBRI	2115	BID	1489	7
2026-07-15 20:04:16.350354+07	BBRI	2105	BID	1481	8
2026-07-15 20:04:16.350354+07	BBRI	2095	BID	1711	9
2026-07-15 20:04:16.350354+07	BBRI	2135	ASK	1497	5
2026-07-15 20:04:16.350354+07	BBRI	2145	ASK	1577	6
2026-07-15 20:04:16.350354+07	BBRI	2155	ASK	1619	7
2026-07-15 20:04:16.350354+07	BBRI	2165	ASK	1562	8
2026-07-15 20:04:16.350354+07	BBRI	2175	ASK	1583	9
2026-07-15 20:04:17.356741+07	BBRI	2135	BID	1484	5
2026-07-15 20:04:17.356741+07	BBRI	2125	BID	1196	6
2026-07-15 20:04:17.356741+07	BBRI	2115	BID	1689	7
2026-07-15 20:04:17.356741+07	BBRI	2105	BID	1436	8
2026-07-15 20:04:17.356741+07	BBRI	2095	BID	1786	9
2026-07-15 20:04:17.356741+07	BBRI	2135	ASK	1243	5
2026-07-15 20:04:17.356741+07	BBRI	2145	ASK	1238	6
2026-07-15 20:04:17.356741+07	BBRI	2155	ASK	1257	7
2026-07-15 20:04:17.356741+07	BBRI	2165	ASK	1783	8
2026-07-15 20:04:17.356741+07	BBRI	2175	ASK	1405	9
2026-07-15 20:04:18.365588+07	BBRI	2135	BID	1333	5
2026-07-15 20:04:18.365588+07	BBRI	2125	BID	1527	6
2026-07-15 20:04:18.365588+07	BBRI	2115	BID	1566	7
2026-07-15 20:04:18.365588+07	BBRI	2105	BID	1737	8
2026-07-15 20:04:18.365588+07	BBRI	2095	BID	1470	9
2026-07-15 20:04:18.365588+07	BBRI	2135	ASK	1172	5
2026-07-15 20:04:18.365588+07	BBRI	2145	ASK	1274	6
2026-07-15 20:04:18.365588+07	BBRI	2155	ASK	1412	7
2026-07-15 20:04:18.365588+07	BBRI	2165	ASK	1568	8
2026-07-15 20:04:18.365588+07	BBRI	2175	ASK	1899	9
2026-07-15 20:04:19.368907+07	BBRI	2135	BID	1050	5
2026-07-15 20:04:19.368907+07	BBRI	2125	BID	1215	6
2026-07-15 20:04:19.368907+07	BBRI	2115	BID	1620	7
2026-07-15 20:04:19.368907+07	BBRI	2105	BID	1377	8
2026-07-15 20:04:19.368907+07	BBRI	2095	BID	1514	9
2026-07-15 20:04:19.368907+07	BBRI	2135	ASK	1212	5
2026-07-15 20:04:19.368907+07	BBRI	2145	ASK	1523	6
2026-07-15 20:04:19.368907+07	BBRI	2155	ASK	1659	7
2026-07-15 20:04:19.368907+07	BBRI	2165	ASK	1633	8
2026-07-15 20:04:19.368907+07	BBRI	2175	ASK	1797	9
2026-07-15 20:04:20.376983+07	BBRI	2135	BID	1352	5
2026-07-15 20:04:20.376983+07	BBRI	2125	BID	1250	6
2026-07-15 20:04:20.376983+07	BBRI	2115	BID	1323	7
2026-07-15 20:04:20.376983+07	BBRI	2105	BID	1606	8
2026-07-15 20:04:20.376983+07	BBRI	2095	BID	1509	9
2026-07-15 20:04:20.376983+07	BBRI	2135	ASK	1236	5
2026-07-15 20:04:20.376983+07	BBRI	2145	ASK	1270	6
2026-07-15 20:04:20.376983+07	BBRI	2155	ASK	1517	7
2026-07-15 20:04:20.376983+07	BBRI	2165	ASK	1486	8
2026-07-15 20:04:20.376983+07	BBRI	2175	ASK	1676	9
2026-07-15 20:04:21.384601+07	BBRI	2135	BID	1447	5
2026-07-15 20:04:21.384601+07	BBRI	2125	BID	1209	6
2026-07-15 20:04:21.384601+07	BBRI	2115	BID	1515	7
2026-07-15 20:04:21.384601+07	BBRI	2105	BID	1712	8
2026-07-15 20:04:21.384601+07	BBRI	2095	BID	1627	9
2026-07-15 20:04:21.384601+07	BBRI	2135	ASK	1336	5
2026-07-15 20:04:21.384601+07	BBRI	2145	ASK	1585	6
2026-07-15 20:04:21.384601+07	BBRI	2155	ASK	1314	7
2026-07-15 20:04:21.384601+07	BBRI	2165	ASK	1624	8
2026-07-15 20:04:21.384601+07	BBRI	2175	ASK	1594	9
2026-07-15 20:04:22.390346+07	BBRI	2135	BID	1217	5
2026-07-15 20:04:22.390346+07	BBRI	2125	BID	1475	6
2026-07-15 20:04:22.390346+07	BBRI	2115	BID	1516	7
2026-07-15 20:04:22.390346+07	BBRI	2105	BID	1722	8
2026-07-15 20:04:22.390346+07	BBRI	2095	BID	1526	9
2026-07-15 20:04:22.390346+07	BBRI	2135	ASK	1157	5
2026-07-15 20:04:22.390346+07	BBRI	2145	ASK	1252	6
2026-07-15 20:04:22.390346+07	BBRI	2155	ASK	1317	7
2026-07-15 20:04:22.390346+07	BBRI	2165	ASK	1373	8
2026-07-15 20:04:22.390346+07	BBRI	2175	ASK	1650	9
2026-07-15 20:04:23.400168+07	BBRI	2135	BID	1290	5
2026-07-15 20:04:23.400168+07	BBRI	2125	BID	1162	6
2026-07-15 20:04:23.400168+07	BBRI	2115	BID	1625	7
2026-07-15 20:04:23.400168+07	BBRI	2105	BID	1788	8
2026-07-15 20:04:23.400168+07	BBRI	2095	BID	1850	9
2026-07-15 20:04:23.400168+07	BBRI	2135	ASK	1245	5
2026-07-15 20:04:23.400168+07	BBRI	2145	ASK	1180	6
2026-07-15 20:04:23.400168+07	BBRI	2155	ASK	1625	7
2026-07-15 20:04:23.400168+07	BBRI	2165	ASK	1759	8
2026-07-15 20:04:23.400168+07	BBRI	2175	ASK	1779	9
2026-07-15 20:04:24.403804+07	BBRI	2135	BID	1240	5
2026-07-15 20:04:24.403804+07	BBRI	2125	BID	1265	6
2026-07-15 20:04:24.403804+07	BBRI	2115	BID	1473	7
2026-07-15 20:04:24.403804+07	BBRI	2105	BID	1719	8
2026-07-15 20:04:24.403804+07	BBRI	2095	BID	1891	9
2026-07-15 20:04:24.403804+07	BBRI	2135	ASK	1224	5
2026-07-15 20:04:24.403804+07	BBRI	2145	ASK	1280	6
2026-07-15 20:04:24.403804+07	BBRI	2155	ASK	1374	7
2026-07-15 20:04:24.403804+07	BBRI	2165	ASK	1715	8
2026-07-15 20:04:24.403804+07	BBRI	2175	ASK	1833	9
2026-07-15 20:04:25.411852+07	BBRI	2135	BID	1267	5
2026-07-15 20:04:25.411852+07	BBRI	2125	BID	1159	6
2026-07-15 20:04:25.411852+07	BBRI	2115	BID	1468	7
2026-07-15 20:04:25.411852+07	BBRI	2105	BID	1390	8
2026-07-15 20:04:25.411852+07	BBRI	2095	BID	1566	9
2026-07-15 20:04:25.411852+07	BBRI	2135	ASK	1273	5
2026-07-15 20:04:25.411852+07	BBRI	2145	ASK	1426	6
2026-07-15 20:04:25.411852+07	BBRI	2155	ASK	1625	7
2026-07-15 20:04:25.411852+07	BBRI	2165	ASK	1651	8
2026-07-15 20:04:25.411852+07	BBRI	2175	ASK	1843	9
2026-07-15 20:04:26.418513+07	BBRI	2135	BID	1031	5
2026-07-15 20:04:26.418513+07	BBRI	2125	BID	1273	6
2026-07-15 20:04:26.418513+07	BBRI	2115	BID	1666	7
2026-07-15 20:04:26.418513+07	BBRI	2105	BID	1325	8
2026-07-15 20:04:26.418513+07	BBRI	2095	BID	1777	9
2026-07-15 20:04:26.418513+07	BBRI	2135	ASK	1100	5
2026-07-15 20:04:26.418513+07	BBRI	2145	ASK	1400	6
2026-07-15 20:04:26.418513+07	BBRI	2155	ASK	1283	7
2026-07-15 20:04:26.418513+07	BBRI	2165	ASK	1696	8
2026-07-15 20:04:26.418513+07	BBRI	2175	ASK	1540	9
2026-07-15 20:04:27.426195+07	BBRI	2135	BID	1219	5
2026-07-15 20:04:27.426195+07	BBRI	2125	BID	1380	6
2026-07-15 20:04:27.426195+07	BBRI	2115	BID	1503	7
2026-07-15 20:04:27.426195+07	BBRI	2105	BID	1379	8
2026-07-15 20:04:27.426195+07	BBRI	2095	BID	1744	9
2026-07-15 20:04:27.426195+07	BBRI	2135	ASK	1315	5
2026-07-15 20:04:27.426195+07	BBRI	2145	ASK	1244	6
2026-07-15 20:04:27.426195+07	BBRI	2155	ASK	1393	7
2026-07-15 20:04:27.426195+07	BBRI	2165	ASK	1539	8
2026-07-15 20:04:27.426195+07	BBRI	2175	ASK	1587	9
2026-07-15 20:04:28.433719+07	BBRI	2135	BID	1215	5
2026-07-15 20:04:28.433719+07	BBRI	2125	BID	1232	6
2026-07-15 20:04:28.433719+07	BBRI	2115	BID	1507	7
2026-07-15 20:04:28.433719+07	BBRI	2105	BID	1477	8
2026-07-15 20:04:28.433719+07	BBRI	2095	BID	1758	9
2026-07-15 20:04:28.433719+07	BBRI	2135	ASK	1178	5
2026-07-15 20:04:28.433719+07	BBRI	2145	ASK	1375	6
2026-07-15 20:04:28.433719+07	BBRI	2155	ASK	1404	7
2026-07-15 20:04:28.433719+07	BBRI	2165	ASK	1515	8
2026-07-15 20:04:28.433719+07	BBRI	2175	ASK	1749	9
2026-07-15 20:04:29.437769+07	BBRI	2135	BID	1426	5
2026-07-15 20:04:29.437769+07	BBRI	2125	BID	1376	6
2026-07-15 20:04:29.437769+07	BBRI	2115	BID	1693	7
2026-07-15 20:04:29.437769+07	BBRI	2105	BID	1712	8
2026-07-15 20:04:29.437769+07	BBRI	2095	BID	1701	9
2026-07-15 20:04:29.437769+07	BBRI	2135	ASK	1373	5
2026-07-15 20:04:29.437769+07	BBRI	2145	ASK	1386	6
2026-07-15 20:04:29.437769+07	BBRI	2155	ASK	1204	7
2026-07-15 20:04:29.437769+07	BBRI	2165	ASK	1372	8
2026-07-15 20:04:29.437769+07	BBRI	2175	ASK	1789	9
2026-07-15 20:04:30.446701+07	BBRI	2135	BID	1315	5
2026-07-15 20:04:30.446701+07	BBRI	2125	BID	1424	6
2026-07-15 20:04:30.446701+07	BBRI	2115	BID	1421	7
2026-07-15 20:04:30.446701+07	BBRI	2105	BID	1562	8
2026-07-15 20:04:30.446701+07	BBRI	2095	BID	1739	9
2026-07-15 20:04:30.446701+07	BBRI	2135	ASK	1103	5
2026-07-15 20:04:30.446701+07	BBRI	2145	ASK	1234	6
2026-07-15 20:04:30.446701+07	BBRI	2155	ASK	1306	7
2026-07-15 20:04:30.446701+07	BBRI	2165	ASK	1720	8
2026-07-15 20:04:30.446701+07	BBRI	2175	ASK	1826	9
2026-07-15 20:04:31.453016+07	BBRI	2135	BID	1317	5
2026-07-15 20:04:31.453016+07	BBRI	2125	BID	1590	6
2026-07-15 20:04:31.453016+07	BBRI	2115	BID	1697	7
2026-07-15 20:04:31.453016+07	BBRI	2105	BID	1661	8
2026-07-15 20:04:31.453016+07	BBRI	2095	BID	1787	9
2026-07-15 20:04:31.453016+07	BBRI	2135	ASK	1297	5
2026-07-15 20:04:31.453016+07	BBRI	2145	ASK	1155	6
2026-07-15 20:04:31.453016+07	BBRI	2155	ASK	1283	7
2026-07-15 20:04:31.453016+07	BBRI	2165	ASK	1754	8
2026-07-15 20:04:31.453016+07	BBRI	2175	ASK	1473	9
2026-07-15 20:04:32.46197+07	BBRI	2135	BID	53321	5
2026-07-15 20:04:32.46197+07	BBRI	2125	BID	1456	6
2026-07-15 20:04:32.46197+07	BBRI	2115	BID	1480	7
2026-07-15 20:04:32.46197+07	BBRI	2105	BID	1468	8
2026-07-15 20:04:32.46197+07	BBRI	2095	BID	1887	9
2026-07-15 20:04:32.46197+07	BBRI	2135	ASK	1429	5
2026-07-15 20:04:32.46197+07	BBRI	2145	ASK	1151	6
2026-07-15 20:04:32.46197+07	BBRI	2155	ASK	1426	7
2026-07-15 20:04:32.46197+07	BBRI	2165	ASK	1354	8
2026-07-15 20:04:32.46197+07	BBRI	2175	ASK	1622	9
2026-07-15 20:04:33.468583+07	BBRI	2135	BID	52584	5
2026-07-15 20:04:33.468583+07	BBRI	2125	BID	1455	6
2026-07-15 20:04:33.468583+07	BBRI	2115	BID	1250	7
2026-07-15 20:04:33.468583+07	BBRI	2105	BID	1604	8
2026-07-15 20:04:33.468583+07	BBRI	2095	BID	1811	9
2026-07-15 20:04:33.468583+07	BBRI	2135	ASK	1302	5
2026-07-15 20:04:33.468583+07	BBRI	2145	ASK	1249	6
2026-07-15 20:04:33.468583+07	BBRI	2155	ASK	1597	7
2026-07-15 20:04:33.468583+07	BBRI	2165	ASK	1347	8
2026-07-15 20:04:33.468583+07	BBRI	2175	ASK	1772	9
2026-07-15 20:04:34.474675+07	BBRI	2135	BID	54382	5
2026-07-15 20:04:34.474675+07	BBRI	2125	BID	1124	6
2026-07-15 20:04:34.474675+07	BBRI	2115	BID	1505	7
2026-07-15 20:04:34.474675+07	BBRI	2105	BID	1378	8
2026-07-15 20:04:34.474675+07	BBRI	2095	BID	1486	9
2026-07-15 20:04:34.474675+07	BBRI	2135	ASK	1488	5
2026-07-15 20:04:34.474675+07	BBRI	2145	ASK	1304	6
2026-07-15 20:04:34.474675+07	BBRI	2155	ASK	1571	7
2026-07-15 20:04:34.474675+07	BBRI	2165	ASK	1334	8
2026-07-15 20:04:34.474675+07	BBRI	2175	ASK	1551	9
2026-07-15 20:04:35.483073+07	BBRI	2135	BID	55904	5
2026-07-15 20:04:35.483073+07	BBRI	2125	BID	1453	6
2026-07-15 20:04:35.483073+07	BBRI	2115	BID	1519	7
2026-07-15 20:04:35.483073+07	BBRI	2105	BID	1311	8
2026-07-15 20:04:35.483073+07	BBRI	2095	BID	1753	9
2026-07-15 20:04:35.483073+07	BBRI	2135	ASK	1389	5
2026-07-15 20:04:35.483073+07	BBRI	2145	ASK	1415	6
2026-07-15 20:04:35.483073+07	BBRI	2155	ASK	1263	7
2026-07-15 20:04:35.483073+07	BBRI	2165	ASK	1656	8
2026-07-15 20:04:35.483073+07	BBRI	2175	ASK	1730	9
2026-07-15 20:04:36.491778+07	BBRI	2135	BID	56169	5
2026-07-15 20:04:36.491778+07	BBRI	2125	BID	1574	6
2026-07-15 20:04:36.491778+07	BBRI	2115	BID	1421	7
2026-07-15 20:04:36.491778+07	BBRI	2105	BID	1595	8
2026-07-15 20:04:36.491778+07	BBRI	2095	BID	1609	9
2026-07-15 20:04:36.491778+07	BBRI	2135	ASK	1360	5
2026-07-15 20:04:36.491778+07	BBRI	2145	ASK	1523	6
2026-07-15 20:04:36.491778+07	BBRI	2155	ASK	1586	7
2026-07-15 20:04:36.491778+07	BBRI	2165	ASK	1469	8
2026-07-15 20:04:36.491778+07	BBRI	2175	ASK	1541	9
2026-07-15 20:04:37.50197+07	BBRI	2135	BID	54371	5
2026-07-15 20:04:37.50197+07	BBRI	2125	BID	1193	6
2026-07-15 20:04:37.50197+07	BBRI	2115	BID	1201	7
2026-07-15 20:04:37.50197+07	BBRI	2105	BID	1763	8
2026-07-15 20:04:37.50197+07	BBRI	2095	BID	1632	9
2026-07-15 20:04:37.50197+07	BBRI	2135	ASK	1399	5
2026-07-15 20:04:37.50197+07	BBRI	2145	ASK	1287	6
2026-07-15 20:04:37.50197+07	BBRI	2155	ASK	1471	7
2026-07-15 20:04:37.50197+07	BBRI	2165	ASK	1787	8
2026-07-15 20:04:37.50197+07	BBRI	2175	ASK	1571	9
2026-07-15 20:04:38.509863+07	BBRI	2135	BID	58849	5
2026-07-15 20:04:38.509863+07	BBRI	2125	BID	1213	6
2026-07-15 20:04:38.509863+07	BBRI	2115	BID	1676	7
2026-07-15 20:04:38.509863+07	BBRI	2105	BID	1510	8
2026-07-15 20:04:38.509863+07	BBRI	2095	BID	1790	9
2026-07-15 20:04:38.509863+07	BBRI	2135	ASK	1424	5
2026-07-15 20:04:38.509863+07	BBRI	2145	ASK	1324	6
2026-07-15 20:04:38.509863+07	BBRI	2155	ASK	1590	7
2026-07-15 20:04:38.509863+07	BBRI	2165	ASK	1404	8
2026-07-15 20:04:38.509863+07	BBRI	2175	ASK	1689	9
2026-07-15 20:04:39.517352+07	BBRI	2135	BID	56182	5
2026-07-15 20:04:39.517352+07	BBRI	2125	BID	1240	6
2026-07-15 20:04:39.517352+07	BBRI	2115	BID	1445	7
2026-07-15 20:04:39.517352+07	BBRI	2105	BID	1728	8
2026-07-15 20:04:39.517352+07	BBRI	2095	BID	1514	9
2026-07-15 20:04:39.517352+07	BBRI	2135	ASK	1266	5
2026-07-15 20:04:39.517352+07	BBRI	2145	ASK	1598	6
2026-07-15 20:04:39.517352+07	BBRI	2155	ASK	1294	7
2026-07-15 20:04:39.517352+07	BBRI	2165	ASK	1525	8
2026-07-15 20:04:39.517352+07	BBRI	2175	ASK	1560	9
2026-07-15 20:04:40.525713+07	BBRI	2135	BID	51912	5
2026-07-15 20:04:40.525713+07	BBRI	2125	BID	1527	6
2026-07-15 20:04:40.525713+07	BBRI	2115	BID	1316	7
2026-07-15 20:04:40.525713+07	BBRI	2105	BID	1610	8
2026-07-15 20:04:40.525713+07	BBRI	2095	BID	1641	9
2026-07-15 20:04:40.525713+07	BBRI	2135	ASK	1325	5
2026-07-15 20:04:40.525713+07	BBRI	2145	ASK	1335	6
2026-07-15 20:04:40.525713+07	BBRI	2155	ASK	1387	7
2026-07-15 20:04:40.525713+07	BBRI	2165	ASK	1599	8
2026-07-15 20:04:40.525713+07	BBRI	2175	ASK	1848	9
2026-07-15 20:04:41.534513+07	BBRI	2135	BID	59531	5
2026-07-15 20:04:41.534513+07	BBRI	2125	BID	1176	6
2026-07-15 20:04:41.534513+07	BBRI	2115	BID	1356	7
2026-07-15 20:04:41.534513+07	BBRI	2105	BID	1381	8
2026-07-15 20:04:41.534513+07	BBRI	2095	BID	1676	9
2026-07-15 20:04:41.534513+07	BBRI	2135	ASK	1402	5
2026-07-15 20:04:41.534513+07	BBRI	2145	ASK	1364	6
2026-07-15 20:04:41.534513+07	BBRI	2155	ASK	1472	7
2026-07-15 20:04:41.534513+07	BBRI	2165	ASK	1533	8
2026-07-15 20:04:41.534513+07	BBRI	2175	ASK	1493	9
2026-07-15 20:04:42.544781+07	BBRI	2135	BID	58922	5
2026-07-15 20:04:42.544781+07	BBRI	2125	BID	1293	6
2026-07-15 20:04:42.544781+07	BBRI	2115	BID	1239	7
2026-07-15 20:04:42.544781+07	BBRI	2105	BID	1319	8
2026-07-15 20:04:42.544781+07	BBRI	2095	BID	1883	9
2026-07-15 20:04:42.544781+07	BBRI	2135	ASK	1455	5
2026-07-15 20:04:42.544781+07	BBRI	2145	ASK	1571	6
2026-07-15 20:04:42.544781+07	BBRI	2155	ASK	1516	7
2026-07-15 20:04:42.544781+07	BBRI	2165	ASK	1357	8
2026-07-15 20:04:42.544781+07	BBRI	2175	ASK	1842	9
2026-07-15 20:04:43.548959+07	BBRI	2135	BID	57557	5
2026-07-15 20:04:43.548959+07	BBRI	2125	BID	1196	6
2026-07-15 20:04:43.548959+07	BBRI	2115	BID	1200	7
2026-07-15 20:04:43.548959+07	BBRI	2105	BID	1588	8
2026-07-15 20:04:43.548959+07	BBRI	2095	BID	1442	9
2026-07-15 20:04:43.548959+07	BBRI	2135	ASK	1467	5
2026-07-15 20:04:43.548959+07	BBRI	2145	ASK	1540	6
2026-07-15 20:04:43.548959+07	BBRI	2155	ASK	1490	7
2026-07-15 20:04:43.548959+07	BBRI	2165	ASK	1601	8
2026-07-15 20:04:43.548959+07	BBRI	2175	ASK	1642	9
2026-07-15 20:04:44.554904+07	BBRI	2135	BID	51079	5
2026-07-15 20:04:44.554904+07	BBRI	2125	BID	1381	6
2026-07-15 20:04:44.554904+07	BBRI	2115	BID	1678	7
2026-07-15 20:04:44.554904+07	BBRI	2105	BID	1682	8
2026-07-15 20:04:44.554904+07	BBRI	2095	BID	1868	9
2026-07-15 20:04:44.554904+07	BBRI	2135	ASK	1145	5
2026-07-15 20:04:44.554904+07	BBRI	2145	ASK	1522	6
2026-07-15 20:04:44.554904+07	BBRI	2155	ASK	1616	7
2026-07-15 20:04:44.554904+07	BBRI	2165	ASK	1648	8
2026-07-15 20:04:44.554904+07	BBRI	2175	ASK	1843	9
2026-07-15 20:04:45.56386+07	BBRI	2135	BID	58017	5
2026-07-15 20:04:45.56386+07	BBRI	2125	BID	1112	6
2026-07-15 20:04:45.56386+07	BBRI	2115	BID	1451	7
2026-07-15 20:04:45.56386+07	BBRI	2105	BID	1701	8
2026-07-15 20:04:45.56386+07	BBRI	2095	BID	1601	9
2026-07-15 20:04:45.56386+07	BBRI	2135	ASK	1121	5
2026-07-15 20:04:45.56386+07	BBRI	2145	ASK	1146	6
2026-07-15 20:04:45.56386+07	BBRI	2155	ASK	1319	7
2026-07-15 20:04:45.56386+07	BBRI	2165	ASK	1773	8
2026-07-15 20:04:45.56386+07	BBRI	2175	ASK	1602	9
2026-07-15 20:04:46.572476+07	BBRI	2135	BID	57201	5
2026-07-15 20:04:46.572476+07	BBRI	2125	BID	1404	6
2026-07-15 20:04:46.572476+07	BBRI	2115	BID	1254	7
2026-07-15 20:04:46.572476+07	BBRI	2105	BID	1705	8
2026-07-15 20:04:46.572476+07	BBRI	2095	BID	1790	9
2026-07-15 20:04:46.572476+07	BBRI	2135	ASK	1208	5
2026-07-15 20:04:46.572476+07	BBRI	2145	ASK	1479	6
2026-07-15 20:04:46.572476+07	BBRI	2155	ASK	1516	7
2026-07-15 20:04:46.572476+07	BBRI	2165	ASK	1676	8
2026-07-15 20:04:46.572476+07	BBRI	2175	ASK	1603	9
2026-07-15 20:04:47.580915+07	BBRI	2135	BID	52594	5
2026-07-15 20:04:47.580915+07	BBRI	2125	BID	1359	6
2026-07-15 20:04:47.580915+07	BBRI	2115	BID	1312	7
2026-07-15 20:04:47.580915+07	BBRI	2105	BID	1583	8
2026-07-15 20:04:47.580915+07	BBRI	2095	BID	1672	9
2026-07-15 20:04:47.580915+07	BBRI	2135	ASK	1460	5
2026-07-15 20:04:47.580915+07	BBRI	2145	ASK	1223	6
2026-07-15 20:04:47.580915+07	BBRI	2155	ASK	1588	7
2026-07-15 20:04:47.580915+07	BBRI	2165	ASK	1395	8
2026-07-15 20:04:47.580915+07	BBRI	2175	ASK	1606	9
2026-07-15 20:04:48.587313+07	BBRI	2135	BID	51050	5
2026-07-15 20:04:48.587313+07	BBRI	2125	BID	1499	6
2026-07-15 20:04:48.587313+07	BBRI	2115	BID	1621	7
2026-07-15 20:04:48.587313+07	BBRI	2105	BID	1712	8
2026-07-15 20:04:48.587313+07	BBRI	2095	BID	1819	9
2026-07-15 20:04:48.587313+07	BBRI	2135	ASK	1204	5
2026-07-15 20:04:48.587313+07	BBRI	2145	ASK	1184	6
2026-07-15 20:04:48.587313+07	BBRI	2155	ASK	1661	7
2026-07-15 20:04:48.587313+07	BBRI	2165	ASK	1727	8
2026-07-15 20:04:48.587313+07	BBRI	2175	ASK	1622	9
2026-07-15 20:04:49.597334+07	BBRI	2135	BID	59976	5
2026-07-15 20:04:49.597334+07	BBRI	2125	BID	1231	6
2026-07-15 20:04:49.597334+07	BBRI	2115	BID	1380	7
2026-07-15 20:04:49.597334+07	BBRI	2105	BID	1301	8
2026-07-15 20:04:49.597334+07	BBRI	2095	BID	1668	9
2026-07-15 20:04:49.597334+07	BBRI	2135	ASK	1334	5
2026-07-15 20:04:49.597334+07	BBRI	2145	ASK	1412	6
2026-07-15 20:04:49.597334+07	BBRI	2155	ASK	1328	7
2026-07-15 20:04:49.597334+07	BBRI	2165	ASK	1647	8
2026-07-15 20:04:49.597334+07	BBRI	2175	ASK	1858	9
2026-07-15 20:04:50.607099+07	BBRI	2135	BID	52934	5
2026-07-15 20:04:50.607099+07	BBRI	2125	BID	1498	6
2026-07-15 20:04:50.607099+07	BBRI	2115	BID	1338	7
2026-07-15 20:04:50.607099+07	BBRI	2105	BID	1426	8
2026-07-15 20:04:50.607099+07	BBRI	2095	BID	1545	9
2026-07-15 20:04:50.607099+07	BBRI	2135	ASK	1423	5
2026-07-15 20:04:50.607099+07	BBRI	2145	ASK	1414	6
2026-07-15 20:04:50.607099+07	BBRI	2155	ASK	1450	7
2026-07-15 20:04:50.607099+07	BBRI	2165	ASK	1544	8
2026-07-15 20:04:50.607099+07	BBRI	2175	ASK	1833	9
2026-07-15 20:04:51.61689+07	BBRI	2135	BID	54078	5
2026-07-15 20:04:51.61689+07	BBRI	2125	BID	1115	6
2026-07-15 20:04:51.61689+07	BBRI	2115	BID	1587	7
2026-07-15 20:04:51.61689+07	BBRI	2105	BID	1433	8
2026-07-15 20:04:51.61689+07	BBRI	2095	BID	1828	9
2026-07-15 20:04:51.61689+07	BBRI	2135	ASK	1492	5
2026-07-15 20:04:51.61689+07	BBRI	2145	ASK	1578	6
2026-07-15 20:04:51.61689+07	BBRI	2155	ASK	1203	7
2026-07-15 20:04:51.61689+07	BBRI	2165	ASK	1678	8
2026-07-15 20:04:51.61689+07	BBRI	2175	ASK	1491	9
2026-07-15 20:04:52.622607+07	BBRI	2135	BID	58286	5
2026-07-15 20:04:52.622607+07	BBRI	2125	BID	1193	6
2026-07-15 20:04:52.622607+07	BBRI	2115	BID	1435	7
2026-07-15 20:04:52.622607+07	BBRI	2105	BID	1487	8
2026-07-15 20:04:52.622607+07	BBRI	2095	BID	1574	9
2026-07-15 20:04:52.622607+07	BBRI	2135	ASK	1278	5
2026-07-15 20:04:52.622607+07	BBRI	2145	ASK	1485	6
2026-07-15 20:04:52.622607+07	BBRI	2155	ASK	1298	7
2026-07-15 20:04:52.622607+07	BBRI	2165	ASK	1485	8
2026-07-15 20:04:52.622607+07	BBRI	2175	ASK	1636	9
2026-07-15 20:04:53.632069+07	BBRI	2135	BID	52921	5
2026-07-15 20:04:53.632069+07	BBRI	2125	BID	1161	6
2026-07-15 20:04:53.632069+07	BBRI	2115	BID	1203	7
2026-07-15 20:04:53.632069+07	BBRI	2105	BID	1410	8
2026-07-15 20:04:53.632069+07	BBRI	2095	BID	1592	9
2026-07-15 20:04:53.632069+07	BBRI	2135	ASK	1447	5
2026-07-15 20:04:53.632069+07	BBRI	2145	ASK	1435	6
2026-07-15 20:04:53.632069+07	BBRI	2155	ASK	1544	7
2026-07-15 20:04:53.632069+07	BBRI	2165	ASK	1649	8
2026-07-15 20:04:53.632069+07	BBRI	2175	ASK	1507	9
2026-07-15 20:04:54.637331+07	BBRI	2135	BID	58829	5
2026-07-15 20:04:54.637331+07	BBRI	2125	BID	1256	6
2026-07-15 20:04:54.637331+07	BBRI	2115	BID	1322	7
2026-07-15 20:04:54.637331+07	BBRI	2105	BID	1614	8
2026-07-15 20:04:54.637331+07	BBRI	2095	BID	1465	9
2026-07-15 20:04:54.637331+07	BBRI	2135	ASK	1453	5
2026-07-15 20:04:54.637331+07	BBRI	2145	ASK	1464	6
2026-07-15 20:04:54.637331+07	BBRI	2155	ASK	1425	7
2026-07-15 20:04:54.637331+07	BBRI	2165	ASK	1401	8
2026-07-15 20:04:54.637331+07	BBRI	2175	ASK	1536	9
2026-07-15 20:04:55.649165+07	BBRI	2135	BID	54260	5
2026-07-15 20:04:55.649165+07	BBRI	2125	BID	1297	6
2026-07-15 20:04:55.649165+07	BBRI	2115	BID	1315	7
2026-07-15 20:04:55.649165+07	BBRI	2105	BID	1520	8
2026-07-15 20:04:55.649165+07	BBRI	2095	BID	1476	9
2026-07-15 20:04:55.649165+07	BBRI	2135	ASK	1251	5
2026-07-15 20:04:55.649165+07	BBRI	2145	ASK	1195	6
2026-07-15 20:04:55.649165+07	BBRI	2155	ASK	1347	7
2026-07-15 20:04:55.649165+07	BBRI	2165	ASK	1603	8
2026-07-15 20:04:55.649165+07	BBRI	2175	ASK	1580	9
2026-07-15 20:04:56.654526+07	BBRI	2135	BID	57183	5
2026-07-15 20:04:56.654526+07	BBRI	2125	BID	1595	6
2026-07-15 20:04:56.654526+07	BBRI	2115	BID	1323	7
2026-07-15 20:04:56.654526+07	BBRI	2105	BID	1438	8
2026-07-15 20:04:56.654526+07	BBRI	2095	BID	1453	9
2026-07-15 20:04:56.654526+07	BBRI	2135	ASK	1266	5
2026-07-15 20:04:56.654526+07	BBRI	2145	ASK	1491	6
2026-07-15 20:04:56.654526+07	BBRI	2155	ASK	1502	7
2026-07-15 20:04:56.654526+07	BBRI	2165	ASK	1358	8
2026-07-15 20:04:56.654526+07	BBRI	2175	ASK	1742	9
2026-07-15 20:04:57.664056+07	BBRI	2135	BID	52246	5
2026-07-15 20:04:57.664056+07	BBRI	2125	BID	1222	6
2026-07-15 20:04:57.664056+07	BBRI	2115	BID	1444	7
2026-07-15 20:04:57.664056+07	BBRI	2105	BID	1540	8
2026-07-15 20:04:57.664056+07	BBRI	2095	BID	1848	9
2026-07-15 20:04:57.664056+07	BBRI	2135	ASK	1338	5
2026-07-15 20:04:57.664056+07	BBRI	2145	ASK	1169	6
2026-07-15 20:04:57.664056+07	BBRI	2155	ASK	1319	7
2026-07-15 20:04:57.664056+07	BBRI	2165	ASK	1329	8
2026-07-15 20:04:57.664056+07	BBRI	2175	ASK	1553	9
2026-07-15 20:04:58.671066+07	BBRI	2135	BID	56414	5
2026-07-15 20:04:58.671066+07	BBRI	2125	BID	1490	6
2026-07-15 20:04:58.671066+07	BBRI	2115	BID	1399	7
2026-07-15 20:04:58.671066+07	BBRI	2105	BID	1307	8
2026-07-15 20:04:58.671066+07	BBRI	2095	BID	1663	9
2026-07-15 20:04:58.671066+07	BBRI	2135	ASK	1095	5
2026-07-15 20:04:58.671066+07	BBRI	2145	ASK	1204	6
2026-07-15 20:04:58.671066+07	BBRI	2155	ASK	1545	7
2026-07-15 20:04:58.671066+07	BBRI	2165	ASK	1472	8
2026-07-15 20:04:58.671066+07	BBRI	2175	ASK	1677	9
2026-07-15 20:04:59.681095+07	BBRI	2135	BID	58763	5
2026-07-15 20:04:59.681095+07	BBRI	2125	BID	1538	6
2026-07-15 20:04:59.681095+07	BBRI	2115	BID	1471	7
2026-07-15 20:04:59.681095+07	BBRI	2105	BID	1589	8
2026-07-15 20:04:59.681095+07	BBRI	2095	BID	1682	9
2026-07-15 20:04:59.681095+07	BBRI	2135	ASK	1267	5
2026-07-15 20:04:59.681095+07	BBRI	2145	ASK	1394	6
2026-07-15 20:04:59.681095+07	BBRI	2155	ASK	1343	7
2026-07-15 20:04:59.681095+07	BBRI	2165	ASK	1325	8
2026-07-15 20:04:59.681095+07	BBRI	2175	ASK	1762	9
2026-07-15 20:05:00.687479+07	BBRI	2135	BID	53273	5
2026-07-15 20:05:00.687479+07	BBRI	2125	BID	1409	6
2026-07-15 20:05:00.687479+07	BBRI	2115	BID	1398	7
2026-07-15 20:05:00.687479+07	BBRI	2105	BID	1377	8
2026-07-15 20:05:00.687479+07	BBRI	2095	BID	1777	9
2026-07-15 20:05:00.687479+07	BBRI	2135	ASK	1337	5
2026-07-15 20:05:00.687479+07	BBRI	2145	ASK	1349	6
2026-07-15 20:05:00.687479+07	BBRI	2155	ASK	1515	7
2026-07-15 20:05:00.687479+07	BBRI	2165	ASK	1471	8
2026-07-15 20:05:00.687479+07	BBRI	2175	ASK	1632	9
2026-07-15 20:05:01.697+07	BBRI	2135	BID	52902	5
2026-07-15 20:05:01.697+07	BBRI	2125	BID	1257	6
2026-07-15 20:05:01.697+07	BBRI	2115	BID	1690	7
2026-07-15 20:05:01.697+07	BBRI	2105	BID	1474	8
2026-07-15 20:05:01.697+07	BBRI	2095	BID	1871	9
2026-07-15 20:05:01.697+07	BBRI	2135	ASK	1060	5
2026-07-15 20:05:01.697+07	BBRI	2145	ASK	1193	6
2026-07-15 20:05:01.697+07	BBRI	2155	ASK	1502	7
2026-07-15 20:05:01.697+07	BBRI	2165	ASK	1360	8
2026-07-15 20:05:01.697+07	BBRI	2175	ASK	1545	9
2026-07-15 20:05:02.704569+07	BBRI	2135	BID	56170	5
2026-07-15 20:05:02.704569+07	BBRI	2125	BID	1352	6
2026-07-15 20:05:02.704569+07	BBRI	2115	BID	1566	7
2026-07-15 20:05:02.704569+07	BBRI	2105	BID	1630	8
2026-07-15 20:05:02.704569+07	BBRI	2095	BID	1856	9
2026-07-15 20:05:02.704569+07	BBRI	2135	ASK	1028	5
2026-07-15 20:05:02.704569+07	BBRI	2145	ASK	1499	6
2026-07-15 20:05:02.704569+07	BBRI	2155	ASK	1365	7
2026-07-15 20:05:02.704569+07	BBRI	2165	ASK	1360	8
2026-07-15 20:05:02.704569+07	BBRI	2175	ASK	1899	9
2026-07-15 20:05:03.713212+07	BBRI	2135	BID	57293	5
2026-07-15 20:05:03.713212+07	BBRI	2125	BID	1143	6
2026-07-15 20:05:03.713212+07	BBRI	2115	BID	1337	7
2026-07-15 20:05:03.713212+07	BBRI	2105	BID	1607	8
2026-07-15 20:05:03.713212+07	BBRI	2095	BID	1744	9
2026-07-15 20:05:03.713212+07	BBRI	2135	ASK	1284	5
2026-07-15 20:05:03.713212+07	BBRI	2145	ASK	1585	6
2026-07-15 20:05:03.713212+07	BBRI	2155	ASK	1659	7
2026-07-15 20:05:03.713212+07	BBRI	2165	ASK	1495	8
2026-07-15 20:05:03.713212+07	BBRI	2175	ASK	1405	9
2026-07-15 20:05:04.72098+07	BBRI	2135	BID	54752	5
2026-07-15 20:05:04.72098+07	BBRI	2125	BID	1334	6
2026-07-15 20:05:04.72098+07	BBRI	2115	BID	1680	7
2026-07-15 20:05:04.72098+07	BBRI	2105	BID	1635	8
2026-07-15 20:05:04.72098+07	BBRI	2095	BID	1870	9
2026-07-15 20:05:04.72098+07	BBRI	2135	ASK	1459	5
2026-07-15 20:05:04.72098+07	BBRI	2145	ASK	1598	6
2026-07-15 20:05:04.72098+07	BBRI	2155	ASK	1535	7
2026-07-15 20:05:04.72098+07	BBRI	2165	ASK	1440	8
2026-07-15 20:05:04.72098+07	BBRI	2175	ASK	1883	9
2026-07-15 20:05:05.729524+07	BBRI	2135	BID	55711	5
2026-07-15 20:05:05.729524+07	BBRI	2125	BID	1336	6
2026-07-15 20:05:05.729524+07	BBRI	2115	BID	1217	7
2026-07-15 20:05:05.729524+07	BBRI	2105	BID	1513	8
2026-07-15 20:05:05.729524+07	BBRI	2095	BID	1728	9
2026-07-15 20:05:05.729524+07	BBRI	2135	ASK	1092	5
2026-07-15 20:05:05.729524+07	BBRI	2145	ASK	1573	6
2026-07-15 20:05:05.729524+07	BBRI	2155	ASK	1482	7
2026-07-15 20:05:05.729524+07	BBRI	2165	ASK	1582	8
2026-07-15 20:05:05.729524+07	BBRI	2175	ASK	1623	9
2026-07-15 20:05:06.737254+07	BBRI	2135	BID	53221	5
2026-07-15 20:05:06.737254+07	BBRI	2125	BID	1385	6
2026-07-15 20:05:06.737254+07	BBRI	2115	BID	1344	7
2026-07-15 20:05:06.737254+07	BBRI	2105	BID	1731	8
2026-07-15 20:05:06.737254+07	BBRI	2095	BID	1664	9
2026-07-15 20:05:06.737254+07	BBRI	2135	ASK	1182	5
2026-07-15 20:05:06.737254+07	BBRI	2145	ASK	1501	6
2026-07-15 20:05:06.737254+07	BBRI	2155	ASK	1632	7
2026-07-15 20:05:06.737254+07	BBRI	2165	ASK	1751	8
2026-07-15 20:05:06.737254+07	BBRI	2175	ASK	1872	9
2026-07-15 20:05:07.7461+07	BBRI	2135	BID	56732	5
2026-07-15 20:05:07.7461+07	BBRI	2125	BID	1410	6
2026-07-15 20:05:07.7461+07	BBRI	2115	BID	1205	7
2026-07-15 20:05:07.7461+07	BBRI	2105	BID	1399	8
2026-07-15 20:05:07.7461+07	BBRI	2095	BID	1841	9
2026-07-15 20:05:07.7461+07	BBRI	2135	ASK	1309	5
2026-07-15 20:05:07.7461+07	BBRI	2145	ASK	1142	6
2026-07-15 20:05:07.7461+07	BBRI	2155	ASK	1244	7
2026-07-15 20:05:07.7461+07	BBRI	2165	ASK	1778	8
2026-07-15 20:05:07.7461+07	BBRI	2175	ASK	1564	9
2026-07-15 20:05:08.754619+07	BBRI	2135	BID	54091	5
2026-07-15 20:05:08.754619+07	BBRI	2125	BID	1471	6
2026-07-15 20:05:08.754619+07	BBRI	2115	BID	1576	7
2026-07-15 20:05:08.754619+07	BBRI	2105	BID	1407	8
2026-07-15 20:05:08.754619+07	BBRI	2095	BID	1497	9
2026-07-15 20:05:08.754619+07	BBRI	2135	ASK	1477	5
2026-07-15 20:05:08.754619+07	BBRI	2145	ASK	1331	6
2026-07-15 20:05:08.754619+07	BBRI	2155	ASK	1602	7
2026-07-15 20:05:08.754619+07	BBRI	2165	ASK	1530	8
2026-07-15 20:05:08.754619+07	BBRI	2175	ASK	1884	9
2026-07-15 20:05:09.763369+07	BBRI	2135	BID	59609	5
2026-07-15 20:05:09.763369+07	BBRI	2125	BID	1304	6
2026-07-15 20:05:09.763369+07	BBRI	2115	BID	1220	7
2026-07-15 20:05:09.763369+07	BBRI	2105	BID	1664	8
2026-07-15 20:05:09.763369+07	BBRI	2095	BID	1638	9
2026-07-15 20:05:09.763369+07	BBRI	2135	ASK	1071	5
2026-07-15 20:05:09.763369+07	BBRI	2145	ASK	1308	6
2026-07-15 20:05:09.763369+07	BBRI	2155	ASK	1542	7
2026-07-15 20:05:09.763369+07	BBRI	2165	ASK	1407	8
2026-07-15 20:05:09.763369+07	BBRI	2175	ASK	1749	9
2026-07-15 20:05:10.772092+07	BBRI	2135	BID	54005	5
2026-07-15 20:05:10.772092+07	BBRI	2125	BID	1599	6
2026-07-15 20:05:10.772092+07	BBRI	2115	BID	1566	7
2026-07-15 20:05:10.772092+07	BBRI	2105	BID	1326	8
2026-07-15 20:05:10.772092+07	BBRI	2095	BID	1752	9
2026-07-15 20:05:10.772092+07	BBRI	2135	ASK	1073	5
2026-07-15 20:05:10.772092+07	BBRI	2145	ASK	1428	6
2026-07-15 20:05:10.772092+07	BBRI	2155	ASK	1359	7
2026-07-15 20:05:10.772092+07	BBRI	2165	ASK	1300	8
2026-07-15 20:05:10.772092+07	BBRI	2175	ASK	1722	9
2026-07-15 20:05:11.780605+07	BBRI	2135	BID	57400	5
2026-07-15 20:05:11.780605+07	BBRI	2125	BID	1466	6
2026-07-15 20:05:11.780605+07	BBRI	2115	BID	1287	7
2026-07-15 20:05:11.780605+07	BBRI	2105	BID	1398	8
2026-07-15 20:05:11.780605+07	BBRI	2095	BID	1744	9
2026-07-15 20:05:11.780605+07	BBRI	2135	ASK	1402	5
2026-07-15 20:05:11.780605+07	BBRI	2145	ASK	1558	6
2026-07-15 20:05:11.780605+07	BBRI	2155	ASK	1209	7
2026-07-15 20:05:11.780605+07	BBRI	2165	ASK	1742	8
2026-07-15 20:05:11.780605+07	BBRI	2175	ASK	1471	9
2026-07-15 20:05:12.789031+07	BBRI	2135	BID	57823	5
2026-07-15 20:05:12.789031+07	BBRI	2125	BID	1512	6
2026-07-15 20:05:12.789031+07	BBRI	2115	BID	1618	7
2026-07-15 20:05:12.789031+07	BBRI	2105	BID	1563	8
2026-07-15 20:05:12.789031+07	BBRI	2095	BID	1516	9
2026-07-15 20:05:12.789031+07	BBRI	2135	ASK	1181	5
2026-07-15 20:05:12.789031+07	BBRI	2145	ASK	1527	6
2026-07-15 20:05:12.789031+07	BBRI	2155	ASK	1689	7
2026-07-15 20:05:12.789031+07	BBRI	2165	ASK	1365	8
2026-07-15 20:05:12.789031+07	BBRI	2175	ASK	1579	9
2026-07-15 20:05:13.795817+07	BBRI	2135	BID	56681	5
2026-07-15 20:05:13.795817+07	BBRI	2125	BID	1348	6
2026-07-15 20:05:13.795817+07	BBRI	2115	BID	1466	7
2026-07-15 20:05:13.795817+07	BBRI	2105	BID	1680	8
2026-07-15 20:05:13.795817+07	BBRI	2095	BID	1676	9
2026-07-15 20:05:13.795817+07	BBRI	2135	ASK	1251	5
2026-07-15 20:05:13.795817+07	BBRI	2145	ASK	1534	6
2026-07-15 20:05:13.795817+07	BBRI	2155	ASK	1446	7
2026-07-15 20:05:13.795817+07	BBRI	2165	ASK	1454	8
2026-07-15 20:05:13.795817+07	BBRI	2175	ASK	1651	9
2026-07-15 20:05:14.808219+07	BBRI	2135	BID	52435	5
2026-07-15 20:05:14.808219+07	BBRI	2125	BID	1360	6
2026-07-15 20:05:14.808219+07	BBRI	2115	BID	1393	7
2026-07-15 20:05:14.808219+07	BBRI	2105	BID	1693	8
2026-07-15 20:05:14.808219+07	BBRI	2095	BID	1623	9
2026-07-15 20:05:14.808219+07	BBRI	2135	ASK	1432	5
2026-07-15 20:05:14.808219+07	BBRI	2145	ASK	1476	6
2026-07-15 20:05:14.808219+07	BBRI	2155	ASK	1299	7
2026-07-15 20:05:14.808219+07	BBRI	2165	ASK	1770	8
2026-07-15 20:05:14.808219+07	BBRI	2175	ASK	1443	9
2026-07-15 20:05:15.819725+07	BBRI	2135	BID	56221	5
2026-07-15 20:05:15.819725+07	BBRI	2125	BID	1514	6
2026-07-15 20:05:15.819725+07	BBRI	2115	BID	1607	7
2026-07-15 20:05:15.819725+07	BBRI	2105	BID	1300	8
2026-07-15 20:05:15.819725+07	BBRI	2095	BID	1500	9
2026-07-15 20:05:15.819725+07	BBRI	2135	ASK	1267	5
2026-07-15 20:05:15.819725+07	BBRI	2145	ASK	1129	6
2026-07-15 20:05:15.819725+07	BBRI	2155	ASK	1563	7
2026-07-15 20:05:15.819725+07	BBRI	2165	ASK	1360	8
2026-07-15 20:05:15.819725+07	BBRI	2175	ASK	1413	9
2026-07-15 20:05:16.830347+07	BBRI	2135	BID	52202	5
2026-07-15 20:05:16.830347+07	BBRI	2125	BID	1598	6
2026-07-15 20:05:16.830347+07	BBRI	2115	BID	1336	7
2026-07-15 20:05:16.830347+07	BBRI	2105	BID	1754	8
2026-07-15 20:05:16.830347+07	BBRI	2095	BID	1887	9
2026-07-15 20:05:16.830347+07	BBRI	2135	ASK	1155	5
2026-07-15 20:05:16.830347+07	BBRI	2145	ASK	1539	6
2026-07-15 20:05:16.830347+07	BBRI	2155	ASK	1314	7
2026-07-15 20:05:16.830347+07	BBRI	2165	ASK	1646	8
2026-07-15 20:05:16.830347+07	BBRI	2175	ASK	1815	9
2026-07-15 20:05:17.837514+07	BBRI	2135	BID	52672	5
2026-07-15 20:05:17.837514+07	BBRI	2125	BID	1381	6
2026-07-15 20:05:17.837514+07	BBRI	2115	BID	1249	7
2026-07-15 20:05:17.837514+07	BBRI	2105	BID	1656	8
2026-07-15 20:05:17.837514+07	BBRI	2095	BID	1781	9
2026-07-15 20:05:17.837514+07	BBRI	2135	ASK	1035	5
2026-07-15 20:05:17.837514+07	BBRI	2145	ASK	1132	6
2026-07-15 20:05:17.837514+07	BBRI	2155	ASK	1305	7
2026-07-15 20:05:17.837514+07	BBRI	2165	ASK	1707	8
2026-07-15 20:05:17.837514+07	BBRI	2175	ASK	1884	9
2026-07-15 20:05:18.847257+07	BBRI	2135	BID	56895	5
2026-07-15 20:05:18.847257+07	BBRI	2125	BID	1180	6
2026-07-15 20:05:18.847257+07	BBRI	2115	BID	1633	7
2026-07-15 20:05:18.847257+07	BBRI	2105	BID	1564	8
2026-07-15 20:05:18.847257+07	BBRI	2095	BID	1676	9
2026-07-15 20:05:18.847257+07	BBRI	2135	ASK	1201	5
2026-07-15 20:05:18.847257+07	BBRI	2145	ASK	1479	6
2026-07-15 20:05:18.847257+07	BBRI	2155	ASK	1419	7
2026-07-15 20:05:18.847257+07	BBRI	2165	ASK	1653	8
2026-07-15 20:05:18.847257+07	BBRI	2175	ASK	1485	9
2026-07-15 20:05:19.856145+07	BBRI	2135	BID	53935	5
2026-07-15 20:05:19.856145+07	BBRI	2125	BID	1491	6
2026-07-15 20:05:19.856145+07	BBRI	2115	BID	1517	7
2026-07-15 20:05:19.856145+07	BBRI	2105	BID	1417	8
2026-07-15 20:05:19.856145+07	BBRI	2095	BID	1699	9
2026-07-15 20:05:19.856145+07	BBRI	2135	ASK	1486	5
2026-07-15 20:05:19.856145+07	BBRI	2145	ASK	1386	6
2026-07-15 20:05:19.856145+07	BBRI	2155	ASK	1482	7
2026-07-15 20:05:19.856145+07	BBRI	2165	ASK	1698	8
2026-07-15 20:05:19.856145+07	BBRI	2175	ASK	1592	9
2026-07-15 20:05:20.864208+07	BBRI	2135	BID	58596	5
2026-07-15 20:05:20.864208+07	BBRI	2125	BID	1306	6
2026-07-15 20:05:20.864208+07	BBRI	2115	BID	1650	7
2026-07-15 20:05:20.864208+07	BBRI	2105	BID	1714	8
2026-07-15 20:05:20.864208+07	BBRI	2095	BID	1709	9
2026-07-15 20:05:20.864208+07	BBRI	2135	ASK	1470	5
2026-07-15 20:05:20.864208+07	BBRI	2145	ASK	1576	6
2026-07-15 20:05:20.864208+07	BBRI	2155	ASK	1346	7
2026-07-15 20:05:20.864208+07	BBRI	2165	ASK	1619	8
2026-07-15 20:05:20.864208+07	BBRI	2175	ASK	1829	9
2026-07-15 20:03:42.328764+07	BMRI	5578	BID	1177	5
2026-07-15 20:03:42.328764+07	BMRI	5568	BID	1490	6
2026-07-15 20:03:42.328764+07	BMRI	5558	BID	1692	7
2026-07-15 20:03:42.328764+07	BMRI	5548	BID	1448	8
2026-07-15 20:03:42.328764+07	BMRI	5538	BID	1409	9
2026-07-15 20:03:42.328764+07	BMRI	5578	ASK	1402	5
2026-07-15 20:03:42.328764+07	BMRI	5588	ASK	1477	6
2026-07-15 20:03:42.328764+07	BMRI	5598	ASK	1607	7
2026-07-15 20:03:42.328764+07	BMRI	5608	ASK	1358	8
2026-07-15 20:03:42.328764+07	BMRI	5618	ASK	1573	9
2026-07-15 20:03:43.335194+07	BMRI	5578	BID	1413	5
2026-07-15 20:03:43.335194+07	BMRI	5568	BID	1494	6
2026-07-15 20:03:43.335194+07	BMRI	5558	BID	1209	7
2026-07-15 20:03:43.335194+07	BMRI	5548	BID	1756	8
2026-07-15 20:03:43.335194+07	BMRI	5538	BID	1845	9
2026-07-15 20:03:43.335194+07	BMRI	5578	ASK	1032	5
2026-07-15 20:03:43.335194+07	BMRI	5588	ASK	1364	6
2026-07-15 20:03:43.335194+07	BMRI	5598	ASK	1653	7
2026-07-15 20:03:43.335194+07	BMRI	5608	ASK	1567	8
2026-07-15 20:03:43.335194+07	BMRI	5618	ASK	1850	9
2026-07-15 20:03:44.344665+07	BMRI	5578	BID	1147	5
2026-07-15 20:03:44.344665+07	BMRI	5568	BID	1466	6
2026-07-15 20:03:44.344665+07	BMRI	5558	BID	1506	7
2026-07-15 20:03:44.344665+07	BMRI	5548	BID	1744	8
2026-07-15 20:03:44.344665+07	BMRI	5538	BID	1653	9
2026-07-15 20:03:44.344665+07	BMRI	5578	ASK	1457	5
2026-07-15 20:03:44.344665+07	BMRI	5588	ASK	1439	6
2026-07-15 20:03:44.344665+07	BMRI	5598	ASK	1262	7
2026-07-15 20:03:44.344665+07	BMRI	5608	ASK	1453	8
2026-07-15 20:03:44.344665+07	BMRI	5618	ASK	1762	9
2026-07-15 20:03:45.353455+07	BMRI	5578	BID	1346	5
2026-07-15 20:03:45.353455+07	BMRI	5568	BID	1374	6
2026-07-15 20:03:45.353455+07	BMRI	5558	BID	1549	7
2026-07-15 20:03:45.353455+07	BMRI	5548	BID	1445	8
2026-07-15 20:03:45.353455+07	BMRI	5538	BID	1788	9
2026-07-15 20:03:45.353455+07	BMRI	5578	ASK	1339	5
2026-07-15 20:03:45.353455+07	BMRI	5588	ASK	1137	6
2026-07-15 20:03:45.353455+07	BMRI	5598	ASK	1488	7
2026-07-15 20:03:45.353455+07	BMRI	5608	ASK	1615	8
2026-07-15 20:03:45.353455+07	BMRI	5618	ASK	1760	9
2026-07-15 20:03:46.362403+07	BMRI	5578	BID	1284	5
2026-07-15 20:03:46.362403+07	BMRI	5568	BID	1554	6
2026-07-15 20:03:46.362403+07	BMRI	5558	BID	1257	7
2026-07-15 20:03:46.362403+07	BMRI	5548	BID	1571	8
2026-07-15 20:03:46.362403+07	BMRI	5538	BID	1747	9
2026-07-15 20:03:46.362403+07	BMRI	5578	ASK	1115	5
2026-07-15 20:03:46.362403+07	BMRI	5588	ASK	1539	6
2026-07-15 20:03:46.362403+07	BMRI	5598	ASK	1431	7
2026-07-15 20:03:46.362403+07	BMRI	5608	ASK	1625	8
2026-07-15 20:03:46.362403+07	BMRI	5618	ASK	1638	9
2026-07-15 20:03:47.371295+07	BMRI	5578	BID	1275	5
2026-07-15 20:03:47.371295+07	BMRI	5568	BID	1586	6
2026-07-15 20:03:47.371295+07	BMRI	5558	BID	1542	7
2026-07-15 20:03:47.371295+07	BMRI	5548	BID	1753	8
2026-07-15 20:03:47.371295+07	BMRI	5538	BID	1627	9
2026-07-15 20:03:47.371295+07	BMRI	5578	ASK	1080	5
2026-07-15 20:03:47.371295+07	BMRI	5588	ASK	1185	6
2026-07-15 20:03:47.371295+07	BMRI	5598	ASK	1492	7
2026-07-15 20:03:47.371295+07	BMRI	5608	ASK	1432	8
2026-07-15 20:03:47.371295+07	BMRI	5618	ASK	1653	9
2026-07-15 20:03:48.380633+07	BMRI	5578	BID	1432	5
2026-07-15 20:03:48.380633+07	BMRI	5568	BID	1422	6
2026-07-15 20:03:48.380633+07	BMRI	5558	BID	1304	7
2026-07-15 20:03:48.380633+07	BMRI	5548	BID	1385	8
2026-07-15 20:03:48.380633+07	BMRI	5538	BID	1696	9
2026-07-15 20:03:48.380633+07	BMRI	5578	ASK	1343	5
2026-07-15 20:03:48.380633+07	BMRI	5588	ASK	1401	6
2026-07-15 20:03:48.380633+07	BMRI	5598	ASK	1495	7
2026-07-15 20:03:48.380633+07	BMRI	5608	ASK	1428	8
2026-07-15 20:03:48.380633+07	BMRI	5618	ASK	1604	9
2026-07-15 20:03:49.388066+07	BMRI	5578	BID	1000	5
2026-07-15 20:03:49.388066+07	BMRI	5568	BID	1514	6
2026-07-15 20:03:49.388066+07	BMRI	5558	BID	1428	7
2026-07-15 20:03:49.388066+07	BMRI	5548	BID	1706	8
2026-07-15 20:03:49.388066+07	BMRI	5538	BID	1705	9
2026-07-15 20:03:49.388066+07	BMRI	5578	ASK	1211	5
2026-07-15 20:03:49.388066+07	BMRI	5588	ASK	1375	6
2026-07-15 20:03:49.388066+07	BMRI	5598	ASK	1593	7
2026-07-15 20:03:49.388066+07	BMRI	5608	ASK	1456	8
2026-07-15 20:03:49.388066+07	BMRI	5618	ASK	1477	9
2026-07-15 20:03:50.396629+07	BMRI	5578	BID	1129	5
2026-07-15 20:03:50.396629+07	BMRI	5568	BID	1230	6
2026-07-15 20:03:50.396629+07	BMRI	5558	BID	1526	7
2026-07-15 20:03:50.396629+07	BMRI	5548	BID	1663	8
2026-07-15 20:03:50.396629+07	BMRI	5538	BID	1479	9
2026-07-15 20:03:50.396629+07	BMRI	5578	ASK	1013	5
2026-07-15 20:03:50.396629+07	BMRI	5588	ASK	1123	6
2026-07-15 20:03:50.396629+07	BMRI	5598	ASK	1325	7
2026-07-15 20:03:50.396629+07	BMRI	5608	ASK	1623	8
2026-07-15 20:03:50.396629+07	BMRI	5618	ASK	1535	9
2026-07-15 20:03:51.406488+07	BMRI	5578	BID	1285	5
2026-07-15 20:03:51.406488+07	BMRI	5568	BID	1107	6
2026-07-15 20:03:51.406488+07	BMRI	5558	BID	1651	7
2026-07-15 20:03:51.406488+07	BMRI	5548	BID	1665	8
2026-07-15 20:03:51.406488+07	BMRI	5538	BID	1662	9
2026-07-15 20:03:51.406488+07	BMRI	5578	ASK	1475	5
2026-07-15 20:03:51.406488+07	BMRI	5588	ASK	1284	6
2026-07-15 20:03:51.406488+07	BMRI	5598	ASK	1547	7
2026-07-15 20:03:51.406488+07	BMRI	5608	ASK	1394	8
2026-07-15 20:03:51.406488+07	BMRI	5618	ASK	1595	9
2026-07-15 20:03:52.416581+07	BMRI	5578	BID	1262	5
2026-07-15 20:03:52.416581+07	BMRI	5568	BID	1126	6
2026-07-15 20:03:52.416581+07	BMRI	5558	BID	1203	7
2026-07-15 20:03:52.416581+07	BMRI	5548	BID	1788	8
2026-07-15 20:03:52.416581+07	BMRI	5538	BID	1557	9
2026-07-15 20:03:52.416581+07	BMRI	5578	ASK	1106	5
2026-07-15 20:03:52.416581+07	BMRI	5588	ASK	1458	6
2026-07-15 20:03:52.416581+07	BMRI	5598	ASK	1255	7
2026-07-15 20:03:52.416581+07	BMRI	5608	ASK	1600	8
2026-07-15 20:03:52.416581+07	BMRI	5618	ASK	1679	9
2026-07-15 20:03:53.42118+07	BMRI	5578	BID	1344	5
2026-07-15 20:03:53.42118+07	BMRI	5568	BID	1592	6
2026-07-15 20:03:53.42118+07	BMRI	5558	BID	1628	7
2026-07-15 20:03:53.42118+07	BMRI	5548	BID	1656	8
2026-07-15 20:03:53.42118+07	BMRI	5538	BID	1497	9
2026-07-15 20:03:53.42118+07	BMRI	5578	ASK	1487	5
2026-07-15 20:03:53.42118+07	BMRI	5588	ASK	1269	6
2026-07-15 20:03:53.42118+07	BMRI	5598	ASK	1425	7
2026-07-15 20:03:53.42118+07	BMRI	5608	ASK	1406	8
2026-07-15 20:03:53.42118+07	BMRI	5618	ASK	1843	9
2026-07-15 20:03:54.431117+07	BMRI	5578	BID	1152	5
2026-07-15 20:03:54.431117+07	BMRI	5568	BID	1504	6
2026-07-15 20:03:54.431117+07	BMRI	5558	BID	1368	7
2026-07-15 20:03:54.431117+07	BMRI	5548	BID	1771	8
2026-07-15 20:03:54.431117+07	BMRI	5538	BID	1799	9
2026-07-15 20:03:54.431117+07	BMRI	5578	ASK	1326	5
2026-07-15 20:03:54.431117+07	BMRI	5588	ASK	1252	6
2026-07-15 20:03:54.431117+07	BMRI	5598	ASK	1301	7
2026-07-15 20:03:54.431117+07	BMRI	5608	ASK	1630	8
2026-07-15 20:03:54.431117+07	BMRI	5618	ASK	1506	9
2026-07-15 20:03:55.438955+07	BMRI	5578	BID	1216	5
2026-07-15 20:03:55.438955+07	BMRI	5568	BID	1190	6
2026-07-15 20:03:55.438955+07	BMRI	5558	BID	1609	7
2026-07-15 20:03:55.438955+07	BMRI	5548	BID	1682	8
2026-07-15 20:03:55.438955+07	BMRI	5538	BID	1592	9
2026-07-15 20:03:55.438955+07	BMRI	5578	ASK	1286	5
2026-07-15 20:03:55.438955+07	BMRI	5588	ASK	1268	6
2026-07-15 20:03:55.438955+07	BMRI	5598	ASK	1669	7
2026-07-15 20:03:55.438955+07	BMRI	5608	ASK	1465	8
2026-07-15 20:03:55.438955+07	BMRI	5618	ASK	1693	9
2026-07-15 20:03:56.449609+07	BMRI	5578	BID	1396	5
2026-07-15 20:03:56.449609+07	BMRI	5568	BID	1581	6
2026-07-15 20:03:56.449609+07	BMRI	5558	BID	1585	7
2026-07-15 20:03:56.449609+07	BMRI	5548	BID	1742	8
2026-07-15 20:03:56.449609+07	BMRI	5538	BID	1837	9
2026-07-15 20:03:56.449609+07	BMRI	5578	ASK	1230	5
2026-07-15 20:03:56.449609+07	BMRI	5588	ASK	1466	6
2026-07-15 20:03:56.449609+07	BMRI	5598	ASK	1502	7
2026-07-15 20:03:56.449609+07	BMRI	5608	ASK	1443	8
2026-07-15 20:03:56.449609+07	BMRI	5618	ASK	1802	9
2026-07-15 20:03:57.454766+07	BMRI	5578	BID	1410	5
2026-07-15 20:03:57.454766+07	BMRI	5568	BID	1550	6
2026-07-15 20:03:57.454766+07	BMRI	5558	BID	1518	7
2026-07-15 20:03:57.454766+07	BMRI	5548	BID	1656	8
2026-07-15 20:03:57.454766+07	BMRI	5538	BID	1609	9
2026-07-15 20:03:57.454766+07	BMRI	5578	ASK	1190	5
2026-07-15 20:03:57.454766+07	BMRI	5588	ASK	1593	6
2026-07-15 20:03:57.454766+07	BMRI	5598	ASK	1497	7
2026-07-15 20:03:57.454766+07	BMRI	5608	ASK	1389	8
2026-07-15 20:03:57.454766+07	BMRI	5618	ASK	1531	9
2026-07-15 20:03:58.46424+07	BMRI	5578	BID	1428	5
2026-07-15 20:03:58.46424+07	BMRI	5568	BID	1213	6
2026-07-15 20:03:58.46424+07	BMRI	5558	BID	1494	7
2026-07-15 20:03:58.46424+07	BMRI	5548	BID	1380	8
2026-07-15 20:03:58.46424+07	BMRI	5538	BID	1718	9
2026-07-15 20:03:58.46424+07	BMRI	5578	ASK	1412	5
2026-07-15 20:03:58.46424+07	BMRI	5588	ASK	1391	6
2026-07-15 20:03:58.46424+07	BMRI	5598	ASK	1445	7
2026-07-15 20:03:58.46424+07	BMRI	5608	ASK	1645	8
2026-07-15 20:03:58.46424+07	BMRI	5618	ASK	1814	9
2026-07-15 20:03:59.473331+07	BMRI	5578	BID	1142	5
2026-07-15 20:03:59.473331+07	BMRI	5568	BID	1199	6
2026-07-15 20:03:59.473331+07	BMRI	5558	BID	1387	7
2026-07-15 20:03:59.473331+07	BMRI	5548	BID	1473	8
2026-07-15 20:03:59.473331+07	BMRI	5538	BID	1717	9
2026-07-15 20:03:59.473331+07	BMRI	5578	ASK	1438	5
2026-07-15 20:03:59.473331+07	BMRI	5588	ASK	1539	6
2026-07-15 20:03:59.473331+07	BMRI	5598	ASK	1295	7
2026-07-15 20:03:59.473331+07	BMRI	5608	ASK	1699	8
2026-07-15 20:03:59.473331+07	BMRI	5618	ASK	1524	9
2026-07-15 20:04:00.479006+07	BMRI	5578	BID	1427	5
2026-07-15 20:04:00.479006+07	BMRI	5568	BID	1403	6
2026-07-15 20:04:00.479006+07	BMRI	5558	BID	1409	7
2026-07-15 20:04:00.479006+07	BMRI	5548	BID	1609	8
2026-07-15 20:04:00.479006+07	BMRI	5538	BID	1603	9
2026-07-15 20:04:00.479006+07	BMRI	5578	ASK	1458	5
2026-07-15 20:04:00.479006+07	BMRI	5588	ASK	1462	6
2026-07-15 20:04:00.479006+07	BMRI	5598	ASK	1376	7
2026-07-15 20:04:00.479006+07	BMRI	5608	ASK	1757	8
2026-07-15 20:04:00.479006+07	BMRI	5618	ASK	1759	9
2026-07-15 20:04:01.488748+07	BMRI	5578	BID	1360	5
2026-07-15 20:04:01.488748+07	BMRI	5568	BID	1403	6
2026-07-15 20:04:01.488748+07	BMRI	5558	BID	1392	7
2026-07-15 20:04:01.488748+07	BMRI	5548	BID	1585	8
2026-07-15 20:04:01.488748+07	BMRI	5538	BID	1883	9
2026-07-15 20:04:01.488748+07	BMRI	5578	ASK	1257	5
2026-07-15 20:04:01.488748+07	BMRI	5588	ASK	1202	6
2026-07-15 20:04:01.488748+07	BMRI	5598	ASK	1518	7
2026-07-15 20:04:01.488748+07	BMRI	5608	ASK	1574	8
2026-07-15 20:04:01.488748+07	BMRI	5618	ASK	1625	9
2026-07-15 20:04:02.494739+07	BMRI	5578	BID	1440	5
2026-07-15 20:04:02.494739+07	BMRI	5568	BID	1308	6
2026-07-15 20:04:02.494739+07	BMRI	5558	BID	1573	7
2026-07-15 20:04:02.494739+07	BMRI	5548	BID	1367	8
2026-07-15 20:04:02.494739+07	BMRI	5538	BID	1474	9
2026-07-15 20:04:02.494739+07	BMRI	5578	ASK	1020	5
2026-07-15 20:04:02.494739+07	BMRI	5588	ASK	1555	6
2026-07-15 20:04:02.494739+07	BMRI	5598	ASK	1277	7
2026-07-15 20:04:02.494739+07	BMRI	5608	ASK	1316	8
2026-07-15 20:04:02.494739+07	BMRI	5618	ASK	1891	9
2026-07-15 20:04:03.504928+07	BMRI	5578	BID	1011	5
2026-07-15 20:04:03.504928+07	BMRI	5568	BID	1123	6
2026-07-15 20:04:03.504928+07	BMRI	5558	BID	1426	7
2026-07-15 20:04:03.504928+07	BMRI	5548	BID	1575	8
2026-07-15 20:04:03.504928+07	BMRI	5538	BID	1890	9
2026-07-15 20:04:03.504928+07	BMRI	5578	ASK	1268	5
2026-07-15 20:04:03.504928+07	BMRI	5588	ASK	1117	6
2026-07-15 20:04:03.504928+07	BMRI	5598	ASK	1303	7
2026-07-15 20:04:03.504928+07	BMRI	5608	ASK	1301	8
2026-07-15 20:04:03.504928+07	BMRI	5618	ASK	1493	9
2026-07-15 20:04:04.511172+07	BMRI	5578	BID	1025	5
2026-07-15 20:04:04.511172+07	BMRI	5568	BID	1312	6
2026-07-15 20:04:04.511172+07	BMRI	5558	BID	1584	7
2026-07-15 20:04:04.511172+07	BMRI	5548	BID	1498	8
2026-07-15 20:04:04.511172+07	BMRI	5538	BID	1439	9
2026-07-15 20:04:04.511172+07	BMRI	5578	ASK	1439	5
2026-07-15 20:04:04.511172+07	BMRI	5588	ASK	1521	6
2026-07-15 20:04:04.511172+07	BMRI	5598	ASK	1463	7
2026-07-15 20:04:04.511172+07	BMRI	5608	ASK	1474	8
2026-07-15 20:04:04.511172+07	BMRI	5618	ASK	1833	9
2026-07-15 20:04:05.518482+07	BMRI	5578	BID	1125	5
2026-07-15 20:04:05.518482+07	BMRI	5568	BID	1531	6
2026-07-15 20:04:05.518482+07	BMRI	5558	BID	1264	7
2026-07-15 20:04:05.518482+07	BMRI	5548	BID	1560	8
2026-07-15 20:04:05.518482+07	BMRI	5538	BID	1751	9
2026-07-15 20:04:05.518482+07	BMRI	5578	ASK	1417	5
2026-07-15 20:04:05.518482+07	BMRI	5588	ASK	1262	6
2026-07-15 20:04:05.518482+07	BMRI	5598	ASK	1377	7
2026-07-15 20:04:05.518482+07	BMRI	5608	ASK	1679	8
2026-07-15 20:04:05.518482+07	BMRI	5618	ASK	1778	9
2026-07-15 20:04:06.526986+07	BMRI	5578	BID	1153	5
2026-07-15 20:04:06.526986+07	BMRI	5568	BID	1498	6
2026-07-15 20:04:06.526986+07	BMRI	5558	BID	1408	7
2026-07-15 20:04:06.526986+07	BMRI	5548	BID	1344	8
2026-07-15 20:04:06.526986+07	BMRI	5538	BID	1550	9
2026-07-15 20:04:06.526986+07	BMRI	5578	ASK	1422	5
2026-07-15 20:04:06.526986+07	BMRI	5588	ASK	1342	6
2026-07-15 20:04:06.526986+07	BMRI	5598	ASK	1425	7
2026-07-15 20:04:06.526986+07	BMRI	5608	ASK	1609	8
2026-07-15 20:04:06.526986+07	BMRI	5618	ASK	1897	9
2026-07-15 20:04:07.536901+07	BMRI	5578	BID	1004	5
2026-07-15 20:04:07.536901+07	BMRI	5568	BID	1197	6
2026-07-15 20:04:07.536901+07	BMRI	5558	BID	1440	7
2026-07-15 20:04:07.536901+07	BMRI	5548	BID	1306	8
2026-07-15 20:04:07.536901+07	BMRI	5538	BID	1863	9
2026-07-15 20:04:07.536901+07	BMRI	5578	ASK	1367	5
2026-07-15 20:04:07.536901+07	BMRI	5588	ASK	1116	6
2026-07-15 20:04:07.536901+07	BMRI	5598	ASK	1523	7
2026-07-15 20:04:07.536901+07	BMRI	5608	ASK	1310	8
2026-07-15 20:04:07.536901+07	BMRI	5618	ASK	1658	9
2026-07-15 20:04:08.548246+07	BMRI	5578	BID	1202	5
2026-07-15 20:04:08.548246+07	BMRI	5568	BID	1335	6
2026-07-15 20:04:08.548246+07	BMRI	5558	BID	1694	7
2026-07-15 20:04:08.548246+07	BMRI	5548	BID	1488	8
2026-07-15 20:04:08.548246+07	BMRI	5538	BID	1627	9
2026-07-15 20:04:08.548246+07	BMRI	5578	ASK	1142	5
2026-07-15 20:04:08.548246+07	BMRI	5588	ASK	1129	6
2026-07-15 20:04:08.548246+07	BMRI	5598	ASK	1384	7
2026-07-15 20:04:08.548246+07	BMRI	5608	ASK	1723	8
2026-07-15 20:04:08.548246+07	BMRI	5618	ASK	1595	9
2026-07-15 20:04:09.553239+07	BMRI	5578	BID	1013	5
2026-07-15 20:04:09.553239+07	BMRI	5568	BID	1163	6
2026-07-15 20:04:09.553239+07	BMRI	5558	BID	1413	7
2026-07-15 20:04:09.553239+07	BMRI	5548	BID	1659	8
2026-07-15 20:04:09.553239+07	BMRI	5538	BID	1835	9
2026-07-15 20:04:09.553239+07	BMRI	5578	ASK	1079	5
2026-07-15 20:04:09.553239+07	BMRI	5588	ASK	1210	6
2026-07-15 20:04:09.553239+07	BMRI	5598	ASK	1602	7
2026-07-15 20:04:09.553239+07	BMRI	5608	ASK	1568	8
2026-07-15 20:04:09.553239+07	BMRI	5618	ASK	1577	9
2026-07-15 20:04:10.558055+07	BMRI	5578	BID	1063	5
2026-07-15 20:04:10.558055+07	BMRI	5568	BID	1218	6
2026-07-15 20:04:10.558055+07	BMRI	5558	BID	1588	7
2026-07-15 20:04:10.558055+07	BMRI	5548	BID	1691	8
2026-07-15 20:04:10.558055+07	BMRI	5538	BID	1484	9
2026-07-15 20:04:10.558055+07	BMRI	5578	ASK	1389	5
2026-07-15 20:04:10.558055+07	BMRI	5588	ASK	1303	6
2026-07-15 20:04:10.558055+07	BMRI	5598	ASK	1298	7
2026-07-15 20:04:10.558055+07	BMRI	5608	ASK	1743	8
2026-07-15 20:04:10.558055+07	BMRI	5618	ASK	1587	9
2026-07-15 20:04:11.568888+07	BMRI	5578	BID	1319	5
2026-07-15 20:04:11.568888+07	BMRI	5568	BID	1553	6
2026-07-15 20:04:11.568888+07	BMRI	5558	BID	1590	7
2026-07-15 20:04:11.568888+07	BMRI	5548	BID	1363	8
2026-07-15 20:04:11.568888+07	BMRI	5538	BID	1569	9
2026-07-15 20:04:11.568888+07	BMRI	5578	ASK	1210	5
2026-07-15 20:04:11.568888+07	BMRI	5588	ASK	1415	6
2026-07-15 20:04:11.568888+07	BMRI	5598	ASK	1274	7
2026-07-15 20:04:11.568888+07	BMRI	5608	ASK	1338	8
2026-07-15 20:04:11.568888+07	BMRI	5618	ASK	1861	9
2026-07-15 20:04:12.577467+07	BMRI	5578	BID	1135	5
2026-07-15 20:04:12.577467+07	BMRI	5568	BID	1380	6
2026-07-15 20:04:12.577467+07	BMRI	5558	BID	1347	7
2026-07-15 20:04:12.577467+07	BMRI	5548	BID	1642	8
2026-07-15 20:04:12.577467+07	BMRI	5538	BID	1798	9
2026-07-15 20:04:12.577467+07	BMRI	5578	ASK	1065	5
2026-07-15 20:04:12.577467+07	BMRI	5588	ASK	1209	6
2026-07-15 20:04:12.577467+07	BMRI	5598	ASK	1263	7
2026-07-15 20:04:12.577467+07	BMRI	5608	ASK	1724	8
2026-07-15 20:04:12.577467+07	BMRI	5618	ASK	1702	9
2026-07-15 20:04:13.586028+07	BMRI	5578	BID	1291	5
2026-07-15 20:04:13.586028+07	BMRI	5568	BID	1328	6
2026-07-15 20:04:13.586028+07	BMRI	5558	BID	1463	7
2026-07-15 20:04:13.586028+07	BMRI	5548	BID	1361	8
2026-07-15 20:04:13.586028+07	BMRI	5538	BID	1694	9
2026-07-15 20:04:13.586028+07	BMRI	5578	ASK	1136	5
2026-07-15 20:04:13.586028+07	BMRI	5588	ASK	1347	6
2026-07-15 20:04:13.586028+07	BMRI	5598	ASK	1228	7
2026-07-15 20:04:13.586028+07	BMRI	5608	ASK	1343	8
2026-07-15 20:04:13.586028+07	BMRI	5618	ASK	1542	9
2026-07-15 20:04:14.594014+07	BMRI	5578	BID	1485	5
2026-07-15 20:04:14.594014+07	BMRI	5568	BID	1557	6
2026-07-15 20:04:14.594014+07	BMRI	5558	BID	1370	7
2026-07-15 20:04:14.594014+07	BMRI	5548	BID	1406	8
2026-07-15 20:04:14.594014+07	BMRI	5538	BID	1858	9
2026-07-15 20:04:14.594014+07	BMRI	5578	ASK	1253	5
2026-07-15 20:04:14.594014+07	BMRI	5588	ASK	1248	6
2026-07-15 20:04:14.594014+07	BMRI	5598	ASK	1574	7
2026-07-15 20:04:14.594014+07	BMRI	5608	ASK	1531	8
2026-07-15 20:04:14.594014+07	BMRI	5618	ASK	1609	9
2026-07-15 20:04:15.602659+07	BMRI	5578	BID	1220	5
2026-07-15 20:04:15.602659+07	BMRI	5568	BID	1589	6
2026-07-15 20:04:15.602659+07	BMRI	5558	BID	1245	7
2026-07-15 20:04:15.602659+07	BMRI	5548	BID	1506	8
2026-07-15 20:04:15.602659+07	BMRI	5538	BID	1466	9
2026-07-15 20:04:15.602659+07	BMRI	5578	ASK	1056	5
2026-07-15 20:04:15.602659+07	BMRI	5588	ASK	1125	6
2026-07-15 20:04:15.602659+07	BMRI	5598	ASK	1547	7
2026-07-15 20:04:15.602659+07	BMRI	5608	ASK	1553	8
2026-07-15 20:04:15.602659+07	BMRI	5618	ASK	1646	9
2026-07-15 20:04:16.609466+07	BMRI	5578	BID	1052	5
2026-07-15 20:04:16.609466+07	BMRI	5568	BID	1422	6
2026-07-15 20:04:16.609466+07	BMRI	5558	BID	1471	7
2026-07-15 20:04:16.609466+07	BMRI	5548	BID	1606	8
2026-07-15 20:04:16.609466+07	BMRI	5538	BID	1821	9
2026-07-15 20:04:16.609466+07	BMRI	5578	ASK	1424	5
2026-07-15 20:04:16.609466+07	BMRI	5588	ASK	1248	6
2026-07-15 20:04:16.609466+07	BMRI	5598	ASK	1432	7
2026-07-15 20:04:16.609466+07	BMRI	5608	ASK	1726	8
2026-07-15 20:04:16.609466+07	BMRI	5618	ASK	1533	9
2026-07-15 20:04:17.620328+07	BMRI	5578	BID	1096	5
2026-07-15 20:04:17.620328+07	BMRI	5568	BID	1473	6
2026-07-15 20:04:17.620328+07	BMRI	5558	BID	1655	7
2026-07-15 20:04:17.620328+07	BMRI	5548	BID	1547	8
2026-07-15 20:04:17.620328+07	BMRI	5538	BID	1683	9
2026-07-15 20:04:17.620328+07	BMRI	5578	ASK	1360	5
2026-07-15 20:04:17.620328+07	BMRI	5588	ASK	1120	6
2026-07-15 20:04:17.620328+07	BMRI	5598	ASK	1323	7
2026-07-15 20:04:17.620328+07	BMRI	5608	ASK	1312	8
2026-07-15 20:04:17.620328+07	BMRI	5618	ASK	1690	9
2026-07-15 20:04:18.627954+07	BMRI	5578	BID	1322	5
2026-07-15 20:04:18.627954+07	BMRI	5568	BID	1255	6
2026-07-15 20:04:18.627954+07	BMRI	5558	BID	1467	7
2026-07-15 20:04:18.627954+07	BMRI	5548	BID	1546	8
2026-07-15 20:04:18.627954+07	BMRI	5538	BID	1439	9
2026-07-15 20:04:18.627954+07	BMRI	5578	ASK	1125	5
2026-07-15 20:04:18.627954+07	BMRI	5588	ASK	1361	6
2026-07-15 20:04:18.627954+07	BMRI	5598	ASK	1276	7
2026-07-15 20:04:18.627954+07	BMRI	5608	ASK	1350	8
2026-07-15 20:04:18.627954+07	BMRI	5618	ASK	1770	9
2026-07-15 20:04:19.638049+07	BMRI	5578	BID	1023	5
2026-07-15 20:04:19.638049+07	BMRI	5568	BID	1271	6
2026-07-15 20:04:19.638049+07	BMRI	5558	BID	1479	7
2026-07-15 20:04:19.638049+07	BMRI	5548	BID	1693	8
2026-07-15 20:04:19.638049+07	BMRI	5538	BID	1610	9
2026-07-15 20:04:19.638049+07	BMRI	5578	ASK	1413	5
2026-07-15 20:04:19.638049+07	BMRI	5588	ASK	1534	6
2026-07-15 20:04:19.638049+07	BMRI	5598	ASK	1525	7
2026-07-15 20:04:19.638049+07	BMRI	5608	ASK	1439	8
2026-07-15 20:04:19.638049+07	BMRI	5618	ASK	1468	9
2026-07-15 20:04:20.643219+07	BMRI	5578	BID	1152	5
2026-07-15 20:04:20.643219+07	BMRI	5568	BID	1580	6
2026-07-15 20:04:20.643219+07	BMRI	5558	BID	1648	7
2026-07-15 20:04:20.643219+07	BMRI	5548	BID	1397	8
2026-07-15 20:04:20.643219+07	BMRI	5538	BID	1880	9
2026-07-15 20:04:20.643219+07	BMRI	5578	ASK	1458	5
2026-07-15 20:04:20.643219+07	BMRI	5588	ASK	1408	6
2026-07-15 20:04:20.643219+07	BMRI	5598	ASK	1363	7
2026-07-15 20:04:20.643219+07	BMRI	5608	ASK	1519	8
2026-07-15 20:04:20.643219+07	BMRI	5618	ASK	1621	9
2026-07-15 20:04:21.651527+07	BMRI	5578	BID	1083	5
2026-07-15 20:04:21.651527+07	BMRI	5568	BID	1127	6
2026-07-15 20:04:21.651527+07	BMRI	5558	BID	1384	7
2026-07-15 20:04:21.651527+07	BMRI	5548	BID	1648	8
2026-07-15 20:04:21.651527+07	BMRI	5538	BID	1875	9
2026-07-15 20:04:21.651527+07	BMRI	5578	ASK	1345	5
2026-07-15 20:04:21.651527+07	BMRI	5588	ASK	1325	6
2026-07-15 20:04:21.651527+07	BMRI	5598	ASK	1217	7
2026-07-15 20:04:21.651527+07	BMRI	5608	ASK	1491	8
2026-07-15 20:04:21.651527+07	BMRI	5618	ASK	1782	9
2026-07-15 20:04:22.660433+07	BMRI	5578	BID	1118	5
2026-07-15 20:04:22.660433+07	BMRI	5568	BID	1328	6
2026-07-15 20:04:22.660433+07	BMRI	5558	BID	1311	7
2026-07-15 20:04:22.660433+07	BMRI	5548	BID	1311	8
2026-07-15 20:04:22.660433+07	BMRI	5538	BID	1453	9
2026-07-15 20:04:22.660433+07	BMRI	5578	ASK	1027	5
2026-07-15 20:04:22.660433+07	BMRI	5588	ASK	1409	6
2026-07-15 20:04:22.660433+07	BMRI	5598	ASK	1442	7
2026-07-15 20:04:22.660433+07	BMRI	5608	ASK	1487	8
2026-07-15 20:04:22.660433+07	BMRI	5618	ASK	1814	9
2026-07-15 20:04:23.667681+07	BMRI	5578	BID	1252	5
2026-07-15 20:04:23.667681+07	BMRI	5568	BID	1478	6
2026-07-15 20:04:23.667681+07	BMRI	5558	BID	1571	7
2026-07-15 20:04:23.667681+07	BMRI	5548	BID	1452	8
2026-07-15 20:04:23.667681+07	BMRI	5538	BID	1768	9
2026-07-15 20:04:23.667681+07	BMRI	5578	ASK	1096	5
2026-07-15 20:04:23.667681+07	BMRI	5588	ASK	1472	6
2026-07-15 20:04:23.667681+07	BMRI	5598	ASK	1434	7
2026-07-15 20:04:23.667681+07	BMRI	5608	ASK	1769	8
2026-07-15 20:04:23.667681+07	BMRI	5618	ASK	1668	9
2026-07-15 20:04:24.672083+07	BMRI	5578	BID	1211	5
2026-07-15 20:04:24.672083+07	BMRI	5568	BID	1310	6
2026-07-15 20:04:24.672083+07	BMRI	5558	BID	1455	7
2026-07-15 20:04:24.672083+07	BMRI	5548	BID	1586	8
2026-07-15 20:04:24.672083+07	BMRI	5538	BID	1557	9
2026-07-15 20:04:24.672083+07	BMRI	5578	ASK	1475	5
2026-07-15 20:04:24.672083+07	BMRI	5588	ASK	1352	6
2026-07-15 20:04:24.672083+07	BMRI	5598	ASK	1513	7
2026-07-15 20:04:24.672083+07	BMRI	5608	ASK	1408	8
2026-07-15 20:04:24.672083+07	BMRI	5618	ASK	1526	9
2026-07-15 20:04:25.681333+07	BMRI	5578	BID	1432	5
2026-07-15 20:04:25.681333+07	BMRI	5568	BID	1488	6
2026-07-15 20:04:25.681333+07	BMRI	5558	BID	1367	7
2026-07-15 20:04:25.681333+07	BMRI	5548	BID	1426	8
2026-07-15 20:04:25.681333+07	BMRI	5538	BID	1898	9
2026-07-15 20:04:25.681333+07	BMRI	5578	ASK	1357	5
2026-07-15 20:04:25.681333+07	BMRI	5588	ASK	1410	6
2026-07-15 20:04:25.681333+07	BMRI	5598	ASK	1411	7
2026-07-15 20:04:25.681333+07	BMRI	5608	ASK	1389	8
2026-07-15 20:04:25.681333+07	BMRI	5618	ASK	1557	9
2026-07-15 20:04:26.690544+07	BMRI	5578	BID	1375	5
2026-07-15 20:04:26.690544+07	BMRI	5568	BID	1131	6
2026-07-15 20:04:26.690544+07	BMRI	5558	BID	1360	7
2026-07-15 20:04:26.690544+07	BMRI	5548	BID	1336	8
2026-07-15 20:04:26.690544+07	BMRI	5538	BID	1851	9
2026-07-15 20:04:26.690544+07	BMRI	5578	ASK	1268	5
2026-07-15 20:04:26.690544+07	BMRI	5588	ASK	1527	6
2026-07-15 20:04:26.690544+07	BMRI	5598	ASK	1581	7
2026-07-15 20:04:26.690544+07	BMRI	5608	ASK	1341	8
2026-07-15 20:04:26.690544+07	BMRI	5618	ASK	1431	9
2026-07-15 20:04:27.697232+07	BMRI	5578	BID	1334	5
2026-07-15 20:04:27.697232+07	BMRI	5568	BID	1590	6
2026-07-15 20:04:27.697232+07	BMRI	5558	BID	1393	7
2026-07-15 20:04:27.697232+07	BMRI	5548	BID	1680	8
2026-07-15 20:04:27.697232+07	BMRI	5538	BID	1709	9
2026-07-15 20:04:27.697232+07	BMRI	5578	ASK	1383	5
2026-07-15 20:04:27.697232+07	BMRI	5588	ASK	1395	6
2026-07-15 20:04:27.697232+07	BMRI	5598	ASK	1344	7
2026-07-15 20:04:27.697232+07	BMRI	5608	ASK	1750	8
2026-07-15 20:04:27.697232+07	BMRI	5618	ASK	1584	9
2026-07-15 20:04:28.706732+07	BMRI	5578	BID	1158	5
2026-07-15 20:04:28.706732+07	BMRI	5568	BID	1264	6
2026-07-15 20:04:28.706732+07	BMRI	5558	BID	1468	7
2026-07-15 20:04:28.706732+07	BMRI	5548	BID	1546	8
2026-07-15 20:04:28.706732+07	BMRI	5538	BID	1849	9
2026-07-15 20:04:28.706732+07	BMRI	5578	ASK	1338	5
2026-07-15 20:04:28.706732+07	BMRI	5588	ASK	1502	6
2026-07-15 20:04:28.706732+07	BMRI	5598	ASK	1267	7
2026-07-15 20:04:28.706732+07	BMRI	5608	ASK	1302	8
2026-07-15 20:04:28.706732+07	BMRI	5618	ASK	1630	9
2026-07-15 20:04:29.714352+07	BMRI	5578	BID	1302	5
2026-07-15 20:04:29.714352+07	BMRI	5568	BID	1519	6
2026-07-15 20:04:29.714352+07	BMRI	5558	BID	1302	7
2026-07-15 20:04:29.714352+07	BMRI	5548	BID	1374	8
2026-07-15 20:04:29.714352+07	BMRI	5538	BID	1565	9
2026-07-15 20:04:29.714352+07	BMRI	5578	ASK	1383	5
2026-07-15 20:04:29.714352+07	BMRI	5588	ASK	1460	6
2026-07-15 20:04:29.714352+07	BMRI	5598	ASK	1551	7
2026-07-15 20:04:29.714352+07	BMRI	5608	ASK	1495	8
2026-07-15 20:04:29.714352+07	BMRI	5618	ASK	1790	9
2026-07-15 20:04:30.722791+07	BMRI	5578	BID	1232	5
2026-07-15 20:04:30.722791+07	BMRI	5568	BID	1256	6
2026-07-15 20:04:30.722791+07	BMRI	5558	BID	1234	7
2026-07-15 20:04:30.722791+07	BMRI	5548	BID	1544	8
2026-07-15 20:04:30.722791+07	BMRI	5538	BID	1609	9
2026-07-15 20:04:30.722791+07	BMRI	5578	ASK	1385	5
2026-07-15 20:04:30.722791+07	BMRI	5588	ASK	1390	6
2026-07-15 20:04:30.722791+07	BMRI	5598	ASK	1203	7
2026-07-15 20:04:30.722791+07	BMRI	5608	ASK	1498	8
2026-07-15 20:04:30.722791+07	BMRI	5618	ASK	1707	9
2026-07-15 20:04:31.728454+07	BMRI	5578	BID	1027	5
2026-07-15 20:04:31.728454+07	BMRI	5568	BID	1343	6
2026-07-15 20:04:31.728454+07	BMRI	5558	BID	1217	7
2026-07-15 20:04:31.728454+07	BMRI	5548	BID	1770	8
2026-07-15 20:04:31.728454+07	BMRI	5538	BID	1669	9
2026-07-15 20:04:31.728454+07	BMRI	5578	ASK	1491	5
2026-07-15 20:04:31.728454+07	BMRI	5588	ASK	1502	6
2026-07-15 20:04:31.728454+07	BMRI	5598	ASK	1452	7
2026-07-15 20:04:31.728454+07	BMRI	5608	ASK	1436	8
2026-07-15 20:04:31.728454+07	BMRI	5618	ASK	1750	9
2026-07-15 20:04:32.738868+07	BMRI	5578	BID	1040	5
2026-07-15 20:04:32.738868+07	BMRI	5568	BID	1483	6
2026-07-15 20:04:32.738868+07	BMRI	5558	BID	1298	7
2026-07-15 20:04:32.738868+07	BMRI	5548	BID	1521	8
2026-07-15 20:04:32.738868+07	BMRI	5538	BID	1814	9
2026-07-15 20:04:32.738868+07	BMRI	5578	ASK	1382	5
2026-07-15 20:04:32.738868+07	BMRI	5588	ASK	1128	6
2026-07-15 20:04:32.738868+07	BMRI	5598	ASK	1453	7
2026-07-15 20:04:32.738868+07	BMRI	5608	ASK	1327	8
2026-07-15 20:04:32.738868+07	BMRI	5618	ASK	1428	9
2026-07-15 20:04:33.743226+07	BMRI	5578	BID	57981	5
2026-07-15 20:04:33.743226+07	BMRI	5568	BID	1352	6
2026-07-15 20:04:33.743226+07	BMRI	5558	BID	1302	7
2026-07-15 20:04:33.743226+07	BMRI	5548	BID	1586	8
2026-07-15 20:04:33.743226+07	BMRI	5538	BID	1865	9
2026-07-15 20:04:33.743226+07	BMRI	5578	ASK	1450	5
2026-07-15 20:04:33.743226+07	BMRI	5588	ASK	1520	6
2026-07-15 20:04:33.743226+07	BMRI	5598	ASK	1431	7
2026-07-15 20:04:33.743226+07	BMRI	5608	ASK	1744	8
2026-07-15 20:04:33.743226+07	BMRI	5618	ASK	1449	9
2026-07-15 20:04:34.753091+07	BMRI	5578	BID	55985	5
2026-07-15 20:04:34.753091+07	BMRI	5568	BID	1184	6
2026-07-15 20:04:34.753091+07	BMRI	5558	BID	1628	7
2026-07-15 20:04:34.753091+07	BMRI	5548	BID	1403	8
2026-07-15 20:04:34.753091+07	BMRI	5538	BID	1739	9
2026-07-15 20:04:34.753091+07	BMRI	5578	ASK	1430	5
2026-07-15 20:04:34.753091+07	BMRI	5588	ASK	1115	6
2026-07-15 20:04:34.753091+07	BMRI	5598	ASK	1221	7
2026-07-15 20:04:34.753091+07	BMRI	5608	ASK	1496	8
2026-07-15 20:04:34.753091+07	BMRI	5618	ASK	1495	9
2026-07-15 20:04:35.759453+07	BMRI	5578	BID	56495	5
2026-07-15 20:04:35.759453+07	BMRI	5568	BID	1156	6
2026-07-15 20:04:35.759453+07	BMRI	5558	BID	1656	7
2026-07-15 20:04:35.759453+07	BMRI	5548	BID	1383	8
2026-07-15 20:04:35.759453+07	BMRI	5538	BID	1553	9
2026-07-15 20:04:35.759453+07	BMRI	5578	ASK	1227	5
2026-07-15 20:04:35.759453+07	BMRI	5588	ASK	1201	6
2026-07-15 20:04:35.759453+07	BMRI	5598	ASK	1590	7
2026-07-15 20:04:35.759453+07	BMRI	5608	ASK	1593	8
2026-07-15 20:04:35.759453+07	BMRI	5618	ASK	1680	9
2026-07-15 20:04:36.768765+07	BMRI	5578	BID	56833	5
2026-07-15 20:04:36.768765+07	BMRI	5568	BID	1110	6
2026-07-15 20:04:36.768765+07	BMRI	5558	BID	1406	7
2026-07-15 20:04:36.768765+07	BMRI	5548	BID	1608	8
2026-07-15 20:04:36.768765+07	BMRI	5538	BID	1775	9
2026-07-15 20:04:36.768765+07	BMRI	5578	ASK	1206	5
2026-07-15 20:04:36.768765+07	BMRI	5588	ASK	1384	6
2026-07-15 20:04:36.768765+07	BMRI	5598	ASK	1464	7
2026-07-15 20:04:36.768765+07	BMRI	5608	ASK	1789	8
2026-07-15 20:04:36.768765+07	BMRI	5618	ASK	1566	9
2026-07-15 20:04:37.774672+07	BMRI	5578	BID	52233	5
2026-07-15 20:04:37.774672+07	BMRI	5568	BID	1316	6
2026-07-15 20:04:37.774672+07	BMRI	5558	BID	1345	7
2026-07-15 20:04:37.774672+07	BMRI	5548	BID	1681	8
2026-07-15 20:04:37.774672+07	BMRI	5538	BID	1447	9
2026-07-15 20:04:37.774672+07	BMRI	5578	ASK	1201	5
2026-07-15 20:04:37.774672+07	BMRI	5588	ASK	1293	6
2026-07-15 20:04:37.774672+07	BMRI	5598	ASK	1367	7
2026-07-15 20:04:37.774672+07	BMRI	5608	ASK	1465	8
2026-07-15 20:04:37.774672+07	BMRI	5618	ASK	1701	9
2026-07-15 20:04:38.779941+07	BMRI	5578	BID	57607	5
2026-07-15 20:04:38.779941+07	BMRI	5568	BID	1506	6
2026-07-15 20:04:38.779941+07	BMRI	5558	BID	1478	7
2026-07-15 20:04:38.779941+07	BMRI	5548	BID	1651	8
2026-07-15 20:04:38.779941+07	BMRI	5538	BID	1675	9
2026-07-15 20:04:38.779941+07	BMRI	5578	ASK	1184	5
2026-07-15 20:04:38.779941+07	BMRI	5588	ASK	1464	6
2026-07-15 20:04:38.779941+07	BMRI	5598	ASK	1419	7
2026-07-15 20:04:38.779941+07	BMRI	5608	ASK	1361	8
2026-07-15 20:04:38.779941+07	BMRI	5618	ASK	1714	9
2026-07-15 20:04:39.789803+07	BMRI	5578	BID	51565	5
2026-07-15 20:04:39.789803+07	BMRI	5568	BID	1192	6
2026-07-15 20:04:39.789803+07	BMRI	5558	BID	1298	7
2026-07-15 20:04:39.789803+07	BMRI	5548	BID	1635	8
2026-07-15 20:04:39.789803+07	BMRI	5538	BID	1450	9
2026-07-15 20:04:39.789803+07	BMRI	5578	ASK	1190	5
2026-07-15 20:04:39.789803+07	BMRI	5588	ASK	1132	6
2026-07-15 20:04:39.789803+07	BMRI	5598	ASK	1279	7
2026-07-15 20:04:39.789803+07	BMRI	5608	ASK	1333	8
2026-07-15 20:04:39.789803+07	BMRI	5618	ASK	1450	9
2026-07-15 20:04:40.794642+07	BMRI	5578	BID	51658	5
2026-07-15 20:04:40.794642+07	BMRI	5568	BID	1293	6
2026-07-15 20:04:40.794642+07	BMRI	5558	BID	1602	7
2026-07-15 20:04:40.794642+07	BMRI	5548	BID	1568	8
2026-07-15 20:04:40.794642+07	BMRI	5538	BID	1589	9
2026-07-15 20:04:40.794642+07	BMRI	5578	ASK	1049	5
2026-07-15 20:04:40.794642+07	BMRI	5588	ASK	1270	6
2026-07-15 20:04:40.794642+07	BMRI	5598	ASK	1589	7
2026-07-15 20:04:40.794642+07	BMRI	5608	ASK	1657	8
2026-07-15 20:04:40.794642+07	BMRI	5618	ASK	1756	9
2026-07-15 20:04:41.802507+07	BMRI	5578	BID	56597	5
2026-07-15 20:04:41.802507+07	BMRI	5568	BID	1386	6
2026-07-15 20:04:41.802507+07	BMRI	5558	BID	1353	7
2026-07-15 20:04:41.802507+07	BMRI	5548	BID	1355	8
2026-07-15 20:04:41.802507+07	BMRI	5538	BID	1755	9
2026-07-15 20:04:41.802507+07	BMRI	5578	ASK	1016	5
2026-07-15 20:04:41.802507+07	BMRI	5588	ASK	1154	6
2026-07-15 20:04:41.802507+07	BMRI	5598	ASK	1262	7
2026-07-15 20:04:41.802507+07	BMRI	5608	ASK	1474	8
2026-07-15 20:04:41.802507+07	BMRI	5618	ASK	1789	9
2026-07-15 20:04:42.812096+07	BMRI	5578	BID	51656	5
2026-07-15 20:04:42.812096+07	BMRI	5568	BID	1194	6
2026-07-15 20:04:42.812096+07	BMRI	5558	BID	1243	7
2026-07-15 20:04:42.812096+07	BMRI	5548	BID	1752	8
2026-07-15 20:04:42.812096+07	BMRI	5538	BID	1535	9
2026-07-15 20:04:42.812096+07	BMRI	5578	ASK	1473	5
2026-07-15 20:04:42.812096+07	BMRI	5588	ASK	1251	6
2026-07-15 20:04:42.812096+07	BMRI	5598	ASK	1418	7
2026-07-15 20:04:42.812096+07	BMRI	5608	ASK	1596	8
2026-07-15 20:04:42.812096+07	BMRI	5618	ASK	1830	9
2026-07-15 20:04:43.821878+07	BMRI	5578	BID	55037	5
2026-07-15 20:04:43.821878+07	BMRI	5568	BID	1565	6
2026-07-15 20:04:43.821878+07	BMRI	5558	BID	1644	7
2026-07-15 20:04:43.821878+07	BMRI	5548	BID	1413	8
2026-07-15 20:04:43.821878+07	BMRI	5538	BID	1810	9
2026-07-15 20:04:43.821878+07	BMRI	5578	ASK	1453	5
2026-07-15 20:04:43.821878+07	BMRI	5588	ASK	1312	6
2026-07-15 20:04:43.821878+07	BMRI	5598	ASK	1385	7
2026-07-15 20:04:43.821878+07	BMRI	5608	ASK	1404	8
2026-07-15 20:04:43.821878+07	BMRI	5618	ASK	1663	9
2026-07-15 20:04:44.833321+07	BMRI	5578	BID	53368	5
2026-07-15 20:04:44.833321+07	BMRI	5568	BID	1211	6
2026-07-15 20:04:44.833321+07	BMRI	5558	BID	1554	7
2026-07-15 20:04:44.833321+07	BMRI	5548	BID	1338	8
2026-07-15 20:04:44.833321+07	BMRI	5538	BID	1571	9
2026-07-15 20:04:44.833321+07	BMRI	5578	ASK	1416	5
2026-07-15 20:04:44.833321+07	BMRI	5588	ASK	1114	6
2026-07-15 20:04:44.833321+07	BMRI	5598	ASK	1621	7
2026-07-15 20:04:44.833321+07	BMRI	5608	ASK	1720	8
2026-07-15 20:04:44.833321+07	BMRI	5618	ASK	1457	9
2026-07-15 20:04:45.842818+07	BMRI	5578	BID	51146	5
2026-07-15 20:04:45.842818+07	BMRI	5568	BID	1157	6
2026-07-15 20:04:45.842818+07	BMRI	5558	BID	1522	7
2026-07-15 20:04:45.842818+07	BMRI	5548	BID	1714	8
2026-07-15 20:04:45.842818+07	BMRI	5538	BID	1666	9
2026-07-15 20:04:45.842818+07	BMRI	5578	ASK	1348	5
2026-07-15 20:04:45.842818+07	BMRI	5588	ASK	1170	6
2026-07-15 20:04:45.842818+07	BMRI	5598	ASK	1298	7
2026-07-15 20:04:45.842818+07	BMRI	5608	ASK	1519	8
2026-07-15 20:04:45.842818+07	BMRI	5618	ASK	1590	9
2026-07-15 20:04:46.85647+07	BMRI	5578	BID	54482	5
2026-07-15 20:04:46.85647+07	BMRI	5568	BID	1295	6
2026-07-15 20:04:46.85647+07	BMRI	5558	BID	1336	7
2026-07-15 20:04:46.85647+07	BMRI	5548	BID	1406	8
2026-07-15 20:04:46.85647+07	BMRI	5538	BID	1825	9
2026-07-15 20:04:46.85647+07	BMRI	5578	ASK	1157	5
2026-07-15 20:04:46.85647+07	BMRI	5588	ASK	1300	6
2026-07-15 20:04:46.85647+07	BMRI	5598	ASK	1264	7
2026-07-15 20:04:46.85647+07	BMRI	5608	ASK	1647	8
2026-07-15 20:04:46.85647+07	BMRI	5618	ASK	1495	9
2026-07-15 20:04:47.868454+07	BMRI	5578	BID	51585	5
2026-07-15 20:04:47.868454+07	BMRI	5568	BID	1217	6
2026-07-15 20:04:47.868454+07	BMRI	5558	BID	1496	7
2026-07-15 20:04:47.868454+07	BMRI	5548	BID	1461	8
2026-07-15 20:04:47.868454+07	BMRI	5538	BID	1788	9
2026-07-15 20:04:47.868454+07	BMRI	5578	ASK	1019	5
2026-07-15 20:04:47.868454+07	BMRI	5588	ASK	1229	6
2026-07-15 20:04:47.868454+07	BMRI	5598	ASK	1567	7
2026-07-15 20:04:47.868454+07	BMRI	5608	ASK	1646	8
2026-07-15 20:04:47.868454+07	BMRI	5618	ASK	1723	9
2026-07-15 20:04:48.881835+07	BMRI	5578	BID	54386	5
2026-07-15 20:04:48.881835+07	BMRI	5568	BID	1182	6
2026-07-15 20:04:48.881835+07	BMRI	5558	BID	1453	7
2026-07-15 20:04:48.881835+07	BMRI	5548	BID	1384	8
2026-07-15 20:04:48.881835+07	BMRI	5538	BID	1821	9
2026-07-15 20:04:48.881835+07	BMRI	5578	ASK	1410	5
2026-07-15 20:04:48.881835+07	BMRI	5588	ASK	1295	6
2026-07-15 20:04:48.881835+07	BMRI	5598	ASK	1558	7
2026-07-15 20:04:48.881835+07	BMRI	5608	ASK	1468	8
2026-07-15 20:04:48.881835+07	BMRI	5618	ASK	1825	9
2026-07-15 20:04:49.904993+07	BMRI	5578	BID	54639	5
2026-07-15 20:04:49.904993+07	BMRI	5568	BID	1222	6
2026-07-15 20:04:49.904993+07	BMRI	5558	BID	1482	7
2026-07-15 20:04:49.904993+07	BMRI	5548	BID	1625	8
2026-07-15 20:04:49.904993+07	BMRI	5538	BID	1472	9
2026-07-15 20:04:49.904993+07	BMRI	5578	ASK	1441	5
2026-07-15 20:04:49.904993+07	BMRI	5588	ASK	1277	6
2026-07-15 20:04:49.904993+07	BMRI	5598	ASK	1385	7
2026-07-15 20:04:49.904993+07	BMRI	5608	ASK	1660	8
2026-07-15 20:04:49.904993+07	BMRI	5618	ASK	1881	9
2026-07-15 20:04:50.920662+07	BMRI	5578	BID	53784	5
2026-07-15 20:04:50.920662+07	BMRI	5568	BID	1592	6
2026-07-15 20:04:50.920662+07	BMRI	5558	BID	1474	7
2026-07-15 20:04:50.920662+07	BMRI	5548	BID	1596	8
2026-07-15 20:04:50.920662+07	BMRI	5538	BID	1561	9
2026-07-15 20:04:50.920662+07	BMRI	5578	ASK	1123	5
2026-07-15 20:04:50.920662+07	BMRI	5588	ASK	1309	6
2026-07-15 20:04:50.920662+07	BMRI	5598	ASK	1371	7
2026-07-15 20:04:50.920662+07	BMRI	5608	ASK	1604	8
2026-07-15 20:04:50.920662+07	BMRI	5618	ASK	1434	9
2026-07-15 20:04:51.940377+07	BMRI	5578	BID	59594	5
2026-07-15 20:04:51.940377+07	BMRI	5568	BID	1279	6
2026-07-15 20:04:51.940377+07	BMRI	5558	BID	1592	7
2026-07-15 20:04:51.940377+07	BMRI	5548	BID	1505	8
2026-07-15 20:04:51.940377+07	BMRI	5538	BID	1466	9
2026-07-15 20:04:51.940377+07	BMRI	5578	ASK	1335	5
2026-07-15 20:04:51.940377+07	BMRI	5588	ASK	1388	6
2026-07-15 20:04:51.940377+07	BMRI	5598	ASK	1454	7
2026-07-15 20:04:51.940377+07	BMRI	5608	ASK	1743	8
2026-07-15 20:04:51.940377+07	BMRI	5618	ASK	1627	9
2026-07-15 20:04:52.959922+07	BMRI	5578	BID	51750	5
2026-07-15 20:04:52.959922+07	BMRI	5568	BID	1569	6
2026-07-15 20:04:52.959922+07	BMRI	5558	BID	1201	7
2026-07-15 20:04:52.959922+07	BMRI	5548	BID	1733	8
2026-07-15 20:04:52.959922+07	BMRI	5538	BID	1489	9
2026-07-15 20:04:52.959922+07	BMRI	5578	ASK	1085	5
2026-07-15 20:04:52.959922+07	BMRI	5588	ASK	1536	6
2026-07-15 20:04:52.959922+07	BMRI	5598	ASK	1256	7
2026-07-15 20:04:52.959922+07	BMRI	5608	ASK	1612	8
2026-07-15 20:04:52.959922+07	BMRI	5618	ASK	1526	9
2026-07-15 20:04:53.97441+07	BMRI	5578	BID	50331	5
2026-07-15 20:04:53.97441+07	BMRI	5568	BID	1461	6
2026-07-15 20:04:53.97441+07	BMRI	5558	BID	1448	7
2026-07-15 20:04:53.97441+07	BMRI	5548	BID	1766	8
2026-07-15 20:04:53.97441+07	BMRI	5538	BID	1739	9
2026-07-15 20:04:53.97441+07	BMRI	5578	ASK	1366	5
2026-07-15 20:04:53.97441+07	BMRI	5588	ASK	1161	6
2026-07-15 20:04:53.97441+07	BMRI	5598	ASK	1465	7
2026-07-15 20:04:53.97441+07	BMRI	5608	ASK	1763	8
2026-07-15 20:04:53.97441+07	BMRI	5618	ASK	1628	9
2026-07-15 20:04:54.995777+07	BMRI	5578	BID	51671	5
2026-07-15 20:04:54.995777+07	BMRI	5568	BID	1166	6
2026-07-15 20:04:54.995777+07	BMRI	5558	BID	1566	7
2026-07-15 20:04:54.995777+07	BMRI	5548	BID	1575	8
2026-07-15 20:04:54.995777+07	BMRI	5538	BID	1762	9
2026-07-15 20:04:54.995777+07	BMRI	5578	ASK	1295	5
2026-07-15 20:04:54.995777+07	BMRI	5588	ASK	1586	6
2026-07-15 20:04:54.995777+07	BMRI	5598	ASK	1563	7
2026-07-15 20:04:54.995777+07	BMRI	5608	ASK	1360	8
2026-07-15 20:04:54.995777+07	BMRI	5618	ASK	1852	9
2026-07-15 20:04:56.001276+07	BMRI	5578	BID	59850	5
2026-07-15 20:04:56.001276+07	BMRI	5568	BID	1466	6
2026-07-15 20:04:56.001276+07	BMRI	5558	BID	1628	7
2026-07-15 20:04:56.001276+07	BMRI	5548	BID	1477	8
2026-07-15 20:04:56.001276+07	BMRI	5538	BID	1455	9
2026-07-15 20:04:56.001276+07	BMRI	5578	ASK	1328	5
2026-07-15 20:04:56.001276+07	BMRI	5588	ASK	1588	6
2026-07-15 20:04:56.001276+07	BMRI	5598	ASK	1409	7
2026-07-15 20:04:56.001276+07	BMRI	5608	ASK	1343	8
2026-07-15 20:04:56.001276+07	BMRI	5618	ASK	1881	9
2026-07-15 20:04:57.006436+07	BMRI	5578	BID	52889	5
2026-07-15 20:04:57.006436+07	BMRI	5568	BID	1247	6
2026-07-15 20:04:57.006436+07	BMRI	5558	BID	1276	7
2026-07-15 20:04:57.006436+07	BMRI	5548	BID	1678	8
2026-07-15 20:04:57.006436+07	BMRI	5538	BID	1888	9
2026-07-15 20:04:57.006436+07	BMRI	5578	ASK	1093	5
2026-07-15 20:04:57.006436+07	BMRI	5588	ASK	1393	6
2026-07-15 20:04:57.006436+07	BMRI	5598	ASK	1248	7
2026-07-15 20:04:57.006436+07	BMRI	5608	ASK	1370	8
2026-07-15 20:04:57.006436+07	BMRI	5618	ASK	1766	9
2026-07-15 20:04:58.01976+07	BMRI	5578	BID	56673	5
2026-07-15 20:04:58.01976+07	BMRI	5568	BID	1453	6
2026-07-15 20:04:58.01976+07	BMRI	5558	BID	1351	7
2026-07-15 20:04:58.01976+07	BMRI	5548	BID	1725	8
2026-07-15 20:04:58.01976+07	BMRI	5538	BID	1667	9
2026-07-15 20:04:58.01976+07	BMRI	5578	ASK	1365	5
2026-07-15 20:04:58.01976+07	BMRI	5588	ASK	1402	6
2026-07-15 20:04:58.01976+07	BMRI	5598	ASK	1555	7
2026-07-15 20:04:58.01976+07	BMRI	5608	ASK	1566	8
2026-07-15 20:04:58.01976+07	BMRI	5618	ASK	1785	9
2026-07-15 20:04:59.037384+07	BMRI	5578	BID	55245	5
2026-07-15 20:04:59.037384+07	BMRI	5568	BID	1567	6
2026-07-15 20:04:59.037384+07	BMRI	5558	BID	1590	7
2026-07-15 20:04:59.037384+07	BMRI	5548	BID	1457	8
2026-07-15 20:04:59.037384+07	BMRI	5538	BID	1624	9
2026-07-15 20:04:59.037384+07	BMRI	5578	ASK	1205	5
2026-07-15 20:04:59.037384+07	BMRI	5588	ASK	1577	6
2026-07-15 20:04:59.037384+07	BMRI	5598	ASK	1596	7
2026-07-15 20:04:59.037384+07	BMRI	5608	ASK	1330	8
2026-07-15 20:04:59.037384+07	BMRI	5618	ASK	1681	9
2026-07-15 20:05:00.048881+07	BMRI	5578	BID	55591	5
2026-07-15 20:05:00.048881+07	BMRI	5568	BID	1127	6
2026-07-15 20:05:00.048881+07	BMRI	5558	BID	1636	7
2026-07-15 20:05:00.048881+07	BMRI	5548	BID	1588	8
2026-07-15 20:05:00.048881+07	BMRI	5538	BID	1791	9
2026-07-15 20:05:00.048881+07	BMRI	5578	ASK	1188	5
2026-07-15 20:05:00.048881+07	BMRI	5588	ASK	1270	6
2026-07-15 20:05:00.048881+07	BMRI	5598	ASK	1436	7
2026-07-15 20:05:00.048881+07	BMRI	5608	ASK	1665	8
2026-07-15 20:05:00.048881+07	BMRI	5618	ASK	1504	9
2026-07-15 20:05:01.054384+07	BMRI	5578	BID	57790	5
2026-07-15 20:05:01.054384+07	BMRI	5568	BID	1400	6
2026-07-15 20:05:01.054384+07	BMRI	5558	BID	1686	7
2026-07-15 20:05:01.054384+07	BMRI	5548	BID	1475	8
2026-07-15 20:05:01.054384+07	BMRI	5538	BID	1851	9
2026-07-15 20:05:01.054384+07	BMRI	5578	ASK	1476	5
2026-07-15 20:05:01.054384+07	BMRI	5588	ASK	1135	6
2026-07-15 20:05:01.054384+07	BMRI	5598	ASK	1570	7
2026-07-15 20:05:01.054384+07	BMRI	5608	ASK	1313	8
2026-07-15 20:05:01.054384+07	BMRI	5618	ASK	1412	9
2026-07-15 20:05:02.059189+07	BMRI	5578	BID	55023	5
2026-07-15 20:05:02.059189+07	BMRI	5568	BID	1574	6
2026-07-15 20:05:02.059189+07	BMRI	5558	BID	1250	7
2026-07-15 20:05:02.059189+07	BMRI	5548	BID	1646	8
2026-07-15 20:05:02.059189+07	BMRI	5538	BID	1702	9
2026-07-15 20:05:02.059189+07	BMRI	5578	ASK	1292	5
2026-07-15 20:05:02.059189+07	BMRI	5588	ASK	1222	6
2026-07-15 20:05:02.059189+07	BMRI	5598	ASK	1694	7
2026-07-15 20:05:02.059189+07	BMRI	5608	ASK	1304	8
2026-07-15 20:05:02.059189+07	BMRI	5618	ASK	1448	9
2026-07-15 20:05:03.064707+07	BMRI	5578	BID	57952	5
2026-07-15 20:05:03.064707+07	BMRI	5568	BID	1241	6
2026-07-15 20:05:03.064707+07	BMRI	5558	BID	1535	7
2026-07-15 20:05:03.064707+07	BMRI	5548	BID	1307	8
2026-07-15 20:05:03.064707+07	BMRI	5538	BID	1892	9
2026-07-15 20:05:03.064707+07	BMRI	5578	ASK	1388	5
2026-07-15 20:05:03.064707+07	BMRI	5588	ASK	1542	6
2026-07-15 20:05:03.064707+07	BMRI	5598	ASK	1363	7
2026-07-15 20:05:03.064707+07	BMRI	5608	ASK	1750	8
2026-07-15 20:05:03.064707+07	BMRI	5618	ASK	1827	9
2026-07-15 20:05:04.069865+07	BMRI	5578	BID	55572	5
2026-07-15 20:05:04.069865+07	BMRI	5568	BID	1350	6
2026-07-15 20:05:04.069865+07	BMRI	5558	BID	1699	7
2026-07-15 20:05:04.069865+07	BMRI	5548	BID	1305	8
2026-07-15 20:05:04.069865+07	BMRI	5538	BID	1778	9
2026-07-15 20:05:04.069865+07	BMRI	5578	ASK	1404	5
2026-07-15 20:05:04.069865+07	BMRI	5588	ASK	1223	6
2026-07-15 20:05:04.069865+07	BMRI	5598	ASK	1453	7
2026-07-15 20:05:04.069865+07	BMRI	5608	ASK	1659	8
2026-07-15 20:05:04.069865+07	BMRI	5618	ASK	1519	9
2026-07-15 20:05:05.089092+07	BMRI	5578	BID	50245	5
2026-07-15 20:05:05.089092+07	BMRI	5568	BID	1380	6
2026-07-15 20:05:05.089092+07	BMRI	5558	BID	1383	7
2026-07-15 20:05:05.089092+07	BMRI	5548	BID	1654	8
2026-07-15 20:05:05.089092+07	BMRI	5538	BID	1835	9
2026-07-15 20:05:05.089092+07	BMRI	5578	ASK	1087	5
2026-07-15 20:05:05.089092+07	BMRI	5588	ASK	1166	6
2026-07-15 20:05:05.089092+07	BMRI	5598	ASK	1274	7
2026-07-15 20:05:05.089092+07	BMRI	5608	ASK	1651	8
2026-07-15 20:05:05.089092+07	BMRI	5618	ASK	1598	9
2026-07-15 20:05:06.102044+07	BMRI	5578	BID	50087	5
2026-07-15 20:05:06.102044+07	BMRI	5568	BID	1577	6
2026-07-15 20:05:06.102044+07	BMRI	5558	BID	1638	7
2026-07-15 20:05:06.102044+07	BMRI	5548	BID	1529	8
2026-07-15 20:05:06.102044+07	BMRI	5538	BID	1595	9
2026-07-15 20:05:06.102044+07	BMRI	5578	ASK	1114	5
2026-07-15 20:05:06.102044+07	BMRI	5588	ASK	1471	6
2026-07-15 20:05:06.102044+07	BMRI	5598	ASK	1697	7
2026-07-15 20:05:06.102044+07	BMRI	5608	ASK	1467	8
2026-07-15 20:05:06.102044+07	BMRI	5618	ASK	1772	9
2026-07-15 20:05:07.111324+07	BMRI	5578	BID	55999	5
2026-07-15 20:05:07.111324+07	BMRI	5568	BID	1424	6
2026-07-15 20:05:07.111324+07	BMRI	5558	BID	1286	7
2026-07-15 20:05:07.111324+07	BMRI	5548	BID	1430	8
2026-07-15 20:05:07.111324+07	BMRI	5538	BID	1606	9
2026-07-15 20:05:07.111324+07	BMRI	5578	ASK	1253	5
2026-07-15 20:05:07.111324+07	BMRI	5588	ASK	1536	6
2026-07-15 20:05:07.111324+07	BMRI	5598	ASK	1241	7
2026-07-15 20:05:07.111324+07	BMRI	5608	ASK	1496	8
2026-07-15 20:05:07.111324+07	BMRI	5618	ASK	1859	9
2026-07-15 20:05:08.12013+07	BMRI	5578	BID	59143	5
2026-07-15 20:05:08.12013+07	BMRI	5568	BID	1190	6
2026-07-15 20:05:08.12013+07	BMRI	5558	BID	1221	7
2026-07-15 20:05:08.12013+07	BMRI	5548	BID	1764	8
2026-07-15 20:05:08.12013+07	BMRI	5538	BID	1446	9
2026-07-15 20:05:08.12013+07	BMRI	5578	ASK	1194	5
2026-07-15 20:05:08.12013+07	BMRI	5588	ASK	1491	6
2026-07-15 20:05:08.12013+07	BMRI	5598	ASK	1657	7
2026-07-15 20:05:08.12013+07	BMRI	5608	ASK	1384	8
2026-07-15 20:05:08.12013+07	BMRI	5618	ASK	1530	9
2026-07-15 20:05:09.130459+07	BMRI	5578	BID	59805	5
2026-07-15 20:05:09.130459+07	BMRI	5568	BID	1262	6
2026-07-15 20:05:09.130459+07	BMRI	5558	BID	1549	7
2026-07-15 20:05:09.130459+07	BMRI	5548	BID	1593	8
2026-07-15 20:05:09.130459+07	BMRI	5538	BID	1577	9
2026-07-15 20:05:09.130459+07	BMRI	5578	ASK	1024	5
2026-07-15 20:05:09.130459+07	BMRI	5588	ASK	1327	6
2026-07-15 20:05:09.130459+07	BMRI	5598	ASK	1546	7
2026-07-15 20:05:09.130459+07	BMRI	5608	ASK	1428	8
2026-07-15 20:05:09.130459+07	BMRI	5618	ASK	1469	9
2026-07-15 20:05:10.136978+07	BMRI	5578	BID	54715	5
2026-07-15 20:05:10.136978+07	BMRI	5568	BID	1109	6
2026-07-15 20:05:10.136978+07	BMRI	5558	BID	1533	7
2026-07-15 20:05:10.136978+07	BMRI	5548	BID	1425	8
2026-07-15 20:05:10.136978+07	BMRI	5538	BID	1490	9
2026-07-15 20:05:10.136978+07	BMRI	5578	ASK	1435	5
2026-07-15 20:05:10.136978+07	BMRI	5588	ASK	1522	6
2026-07-15 20:05:10.136978+07	BMRI	5598	ASK	1392	7
2026-07-15 20:05:10.136978+07	BMRI	5608	ASK	1475	8
2026-07-15 20:05:10.136978+07	BMRI	5618	ASK	1694	9
2026-07-15 20:05:11.142207+07	BMRI	5578	BID	57315	5
2026-07-15 20:05:11.142207+07	BMRI	5568	BID	1321	6
2026-07-15 20:05:11.142207+07	BMRI	5558	BID	1692	7
2026-07-15 20:05:11.142207+07	BMRI	5548	BID	1391	8
2026-07-15 20:05:11.142207+07	BMRI	5538	BID	1602	9
2026-07-15 20:05:11.142207+07	BMRI	5578	ASK	1309	5
2026-07-15 20:05:11.142207+07	BMRI	5588	ASK	1197	6
2026-07-15 20:05:11.142207+07	BMRI	5598	ASK	1346	7
2026-07-15 20:05:11.142207+07	BMRI	5608	ASK	1624	8
2026-07-15 20:05:11.142207+07	BMRI	5618	ASK	1713	9
2026-07-15 20:05:12.147722+07	BMRI	5578	BID	58082	5
2026-07-15 20:05:12.147722+07	BMRI	5568	BID	1369	6
2026-07-15 20:05:12.147722+07	BMRI	5558	BID	1275	7
2026-07-15 20:05:12.147722+07	BMRI	5548	BID	1484	8
2026-07-15 20:05:12.147722+07	BMRI	5538	BID	1525	9
2026-07-15 20:05:12.147722+07	BMRI	5578	ASK	1282	5
2026-07-15 20:05:12.147722+07	BMRI	5588	ASK	1554	6
2026-07-15 20:05:12.147722+07	BMRI	5598	ASK	1394	7
2026-07-15 20:05:12.147722+07	BMRI	5608	ASK	1781	8
2026-07-15 20:05:12.147722+07	BMRI	5618	ASK	1629	9
2026-07-15 20:05:13.15272+07	BMRI	5578	BID	59355	5
2026-07-15 20:05:13.15272+07	BMRI	5568	BID	1470	6
2026-07-15 20:05:13.15272+07	BMRI	5558	BID	1211	7
2026-07-15 20:05:13.15272+07	BMRI	5548	BID	1535	8
2026-07-15 20:05:13.15272+07	BMRI	5538	BID	1827	9
2026-07-15 20:05:13.15272+07	BMRI	5578	ASK	1060	5
2026-07-15 20:05:13.15272+07	BMRI	5588	ASK	1307	6
2026-07-15 20:05:13.15272+07	BMRI	5598	ASK	1474	7
2026-07-15 20:05:13.15272+07	BMRI	5608	ASK	1693	8
2026-07-15 20:05:13.15272+07	BMRI	5618	ASK	1558	9
2026-07-15 20:05:14.157942+07	BMRI	5578	BID	50968	5
2026-07-15 20:05:14.157942+07	BMRI	5568	BID	1598	6
2026-07-15 20:05:14.157942+07	BMRI	5558	BID	1650	7
2026-07-15 20:05:14.157942+07	BMRI	5548	BID	1772	8
2026-07-15 20:05:14.157942+07	BMRI	5538	BID	1541	9
2026-07-15 20:05:14.157942+07	BMRI	5578	ASK	1317	5
2026-07-15 20:05:14.157942+07	BMRI	5588	ASK	1299	6
2026-07-15 20:05:14.157942+07	BMRI	5598	ASK	1495	7
2026-07-15 20:05:14.157942+07	BMRI	5608	ASK	1608	8
2026-07-15 20:05:14.157942+07	BMRI	5618	ASK	1428	9
2026-07-15 20:05:15.163053+07	BMRI	5578	BID	50408	5
2026-07-15 20:05:15.163053+07	BMRI	5568	BID	1243	6
2026-07-15 20:05:15.163053+07	BMRI	5558	BID	1492	7
2026-07-15 20:05:15.163053+07	BMRI	5548	BID	1457	8
2026-07-15 20:05:15.163053+07	BMRI	5538	BID	1602	9
2026-07-15 20:05:15.163053+07	BMRI	5578	ASK	1157	5
2026-07-15 20:05:15.163053+07	BMRI	5588	ASK	1364	6
2026-07-15 20:05:15.163053+07	BMRI	5598	ASK	1414	7
2026-07-15 20:05:15.163053+07	BMRI	5608	ASK	1559	8
2026-07-15 20:05:15.163053+07	BMRI	5618	ASK	1841	9
2026-07-15 20:05:16.17078+07	BMRI	5578	BID	54065	5
2026-07-15 20:05:16.17078+07	BMRI	5568	BID	1578	6
2026-07-15 20:05:16.17078+07	BMRI	5558	BID	1373	7
2026-07-15 20:05:16.17078+07	BMRI	5548	BID	1549	8
2026-07-15 20:05:16.17078+07	BMRI	5538	BID	1423	9
2026-07-15 20:05:16.17078+07	BMRI	5578	ASK	1237	5
2026-07-15 20:05:16.17078+07	BMRI	5588	ASK	1222	6
2026-07-15 20:05:16.17078+07	BMRI	5598	ASK	1239	7
2026-07-15 20:05:16.17078+07	BMRI	5608	ASK	1526	8
2026-07-15 20:05:16.17078+07	BMRI	5618	ASK	1518	9
2026-07-15 20:05:17.178642+07	BMRI	5578	BID	51829	5
2026-07-15 20:05:17.178642+07	BMRI	5568	BID	1258	6
2026-07-15 20:05:17.178642+07	BMRI	5558	BID	1410	7
2026-07-15 20:05:17.178642+07	BMRI	5548	BID	1519	8
2026-07-15 20:05:17.178642+07	BMRI	5538	BID	1638	9
2026-07-15 20:05:17.178642+07	BMRI	5578	ASK	1157	5
2026-07-15 20:05:17.178642+07	BMRI	5588	ASK	1407	6
2026-07-15 20:05:17.178642+07	BMRI	5598	ASK	1263	7
2026-07-15 20:05:17.178642+07	BMRI	5608	ASK	1335	8
2026-07-15 20:05:17.178642+07	BMRI	5618	ASK	1568	9
2026-07-15 20:05:18.187053+07	BMRI	5578	BID	53708	5
2026-07-15 20:05:18.187053+07	BMRI	5568	BID	1375	6
2026-07-15 20:05:18.187053+07	BMRI	5558	BID	1426	7
2026-07-15 20:05:18.187053+07	BMRI	5548	BID	1467	8
2026-07-15 20:05:18.187053+07	BMRI	5538	BID	1411	9
2026-07-15 20:05:18.187053+07	BMRI	5578	ASK	1078	5
2026-07-15 20:05:18.187053+07	BMRI	5588	ASK	1593	6
2026-07-15 20:05:18.187053+07	BMRI	5598	ASK	1686	7
2026-07-15 20:05:18.187053+07	BMRI	5608	ASK	1317	8
2026-07-15 20:05:18.187053+07	BMRI	5618	ASK	1492	9
2026-07-15 20:05:19.195299+07	BMRI	5578	BID	56407	5
2026-07-15 20:05:19.195299+07	BMRI	5568	BID	1566	6
2026-07-15 20:05:19.195299+07	BMRI	5558	BID	1324	7
2026-07-15 20:05:19.195299+07	BMRI	5548	BID	1402	8
2026-07-15 20:05:19.195299+07	BMRI	5538	BID	1420	9
2026-07-15 20:05:19.195299+07	BMRI	5578	ASK	1161	5
2026-07-15 20:05:19.195299+07	BMRI	5588	ASK	1432	6
2026-07-15 20:05:19.195299+07	BMRI	5598	ASK	1431	7
2026-07-15 20:05:19.195299+07	BMRI	5608	ASK	1453	8
2026-07-15 20:05:19.195299+07	BMRI	5618	ASK	1665	9
2026-07-15 20:05:20.203752+07	BMRI	5578	BID	51404	5
2026-07-15 20:05:20.203752+07	BMRI	5568	BID	1453	6
2026-07-15 20:05:20.203752+07	BMRI	5558	BID	1563	7
2026-07-15 20:05:20.203752+07	BMRI	5548	BID	1644	8
2026-07-15 20:05:20.203752+07	BMRI	5538	BID	1606	9
2026-07-15 20:05:20.203752+07	BMRI	5578	ASK	1466	5
2026-07-15 20:05:20.203752+07	BMRI	5588	ASK	1449	6
2026-07-15 20:05:20.203752+07	BMRI	5598	ASK	1247	7
2026-07-15 20:05:20.203752+07	BMRI	5608	ASK	1516	8
2026-07-15 20:05:20.203752+07	BMRI	5618	ASK	1856	9
2026-07-15 20:05:21.218375+07	BMRI	5578	BID	55486	5
2026-07-15 20:05:21.218375+07	BMRI	5568	BID	1186	6
2026-07-15 20:05:21.218375+07	BMRI	5558	BID	1417	7
2026-07-15 20:05:21.218375+07	BMRI	5548	BID	1595	8
2026-07-15 20:05:21.218375+07	BMRI	5538	BID	1653	9
2026-07-15 20:05:21.218375+07	BMRI	5578	ASK	1164	5
2026-07-15 20:05:21.218375+07	BMRI	5588	ASK	1365	6
2026-07-15 20:05:21.218375+07	BMRI	5598	ASK	1634	7
2026-07-15 20:05:21.218375+07	BMRI	5608	ASK	1622	8
2026-07-15 20:05:21.218375+07	BMRI	5618	ASK	1421	9
2026-07-15 20:05:22.232478+07	BMRI	5578	BID	55896	5
2026-07-15 20:05:22.232478+07	BMRI	5568	BID	1277	6
2026-07-15 20:05:22.232478+07	BMRI	5558	BID	1434	7
2026-07-15 20:05:22.232478+07	BMRI	5548	BID	1520	8
2026-07-15 20:05:22.232478+07	BMRI	5538	BID	1695	9
2026-07-15 20:05:22.232478+07	BMRI	5578	ASK	1109	5
2026-07-15 20:05:22.232478+07	BMRI	5588	ASK	1485	6
2026-07-15 20:05:22.232478+07	BMRI	5598	ASK	1681	7
2026-07-15 20:05:22.232478+07	BMRI	5608	ASK	1690	8
2026-07-15 20:05:22.232478+07	BMRI	5618	ASK	1789	9
2026-07-15 20:03:43.746016+07	TLKM	1512	BID	1261	5
2026-07-15 20:03:43.746016+07	TLKM	1502	BID	1567	6
2026-07-15 20:03:43.746016+07	TLKM	1492	BID	1698	7
2026-07-15 20:03:43.746016+07	TLKM	1482	BID	1474	8
2026-07-15 20:03:43.746016+07	TLKM	1472	BID	1764	9
2026-07-15 20:03:43.746016+07	TLKM	1512	ASK	1288	5
2026-07-15 20:03:43.746016+07	TLKM	1522	ASK	1155	6
2026-07-15 20:03:43.746016+07	TLKM	1532	ASK	1339	7
2026-07-15 20:03:43.746016+07	TLKM	1542	ASK	1663	8
2026-07-15 20:03:43.746016+07	TLKM	1552	ASK	1863	9
2026-07-15 20:03:44.755175+07	TLKM	1512	BID	1266	5
2026-07-15 20:03:44.755175+07	TLKM	1502	BID	1196	6
2026-07-15 20:03:44.755175+07	TLKM	1492	BID	1345	7
2026-07-15 20:03:44.755175+07	TLKM	1482	BID	1733	8
2026-07-15 20:03:44.755175+07	TLKM	1472	BID	1467	9
2026-07-15 20:03:44.755175+07	TLKM	1512	ASK	1443	5
2026-07-15 20:03:44.755175+07	TLKM	1522	ASK	1411	6
2026-07-15 20:03:44.755175+07	TLKM	1532	ASK	1405	7
2026-07-15 20:03:44.755175+07	TLKM	1542	ASK	1422	8
2026-07-15 20:03:44.755175+07	TLKM	1552	ASK	1618	9
2026-07-15 20:03:45.763572+07	TLKM	1512	BID	1492	5
2026-07-15 20:03:45.763572+07	TLKM	1502	BID	1500	6
2026-07-15 20:03:45.763572+07	TLKM	1492	BID	1550	7
2026-07-15 20:03:45.763572+07	TLKM	1482	BID	1506	8
2026-07-15 20:03:45.763572+07	TLKM	1472	BID	1713	9
2026-07-15 20:03:45.763572+07	TLKM	1512	ASK	1390	5
2026-07-15 20:03:45.763572+07	TLKM	1522	ASK	1552	6
2026-07-15 20:03:45.763572+07	TLKM	1532	ASK	1669	7
2026-07-15 20:03:45.763572+07	TLKM	1542	ASK	1755	8
2026-07-15 20:03:45.763572+07	TLKM	1552	ASK	1489	9
2026-07-15 20:03:46.771028+07	TLKM	1512	BID	1083	5
2026-07-15 20:03:46.771028+07	TLKM	1502	BID	1292	6
2026-07-15 20:03:46.771028+07	TLKM	1492	BID	1653	7
2026-07-15 20:03:46.771028+07	TLKM	1482	BID	1442	8
2026-07-15 20:03:46.771028+07	TLKM	1472	BID	1685	9
2026-07-15 20:03:46.771028+07	TLKM	1512	ASK	1312	5
2026-07-15 20:03:46.771028+07	TLKM	1522	ASK	1395	6
2026-07-15 20:03:46.771028+07	TLKM	1532	ASK	1500	7
2026-07-15 20:03:46.771028+07	TLKM	1542	ASK	1757	8
2026-07-15 20:03:46.771028+07	TLKM	1552	ASK	1454	9
2026-07-15 20:03:47.779362+07	TLKM	1512	BID	1277	5
2026-07-15 20:03:47.779362+07	TLKM	1502	BID	1400	6
2026-07-15 20:03:47.779362+07	TLKM	1492	BID	1571	7
2026-07-15 20:03:47.779362+07	TLKM	1482	BID	1679	8
2026-07-15 20:03:47.779362+07	TLKM	1472	BID	1761	9
2026-07-15 20:03:47.779362+07	TLKM	1512	ASK	1074	5
2026-07-15 20:03:47.779362+07	TLKM	1522	ASK	1322	6
2026-07-15 20:03:47.779362+07	TLKM	1532	ASK	1592	7
2026-07-15 20:03:47.779362+07	TLKM	1542	ASK	1390	8
2026-07-15 20:03:47.779362+07	TLKM	1552	ASK	1403	9
2026-07-15 20:03:48.785366+07	TLKM	1512	BID	1225	5
2026-07-15 20:03:48.785366+07	TLKM	1502	BID	1249	6
2026-07-15 20:03:48.785366+07	TLKM	1492	BID	1662	7
2026-07-15 20:03:48.785366+07	TLKM	1482	BID	1676	8
2026-07-15 20:03:48.785366+07	TLKM	1472	BID	1687	9
2026-07-15 20:03:48.785366+07	TLKM	1512	ASK	1242	5
2026-07-15 20:03:48.785366+07	TLKM	1522	ASK	1103	6
2026-07-15 20:03:48.785366+07	TLKM	1532	ASK	1279	7
2026-07-15 20:03:48.785366+07	TLKM	1542	ASK	1775	8
2026-07-15 20:03:48.785366+07	TLKM	1552	ASK	1720	9
2026-07-15 20:03:49.793693+07	TLKM	1512	BID	1336	5
2026-07-15 20:03:49.793693+07	TLKM	1502	BID	1185	6
2026-07-15 20:03:49.793693+07	TLKM	1492	BID	1600	7
2026-07-15 20:03:49.793693+07	TLKM	1482	BID	1381	8
2026-07-15 20:03:49.793693+07	TLKM	1472	BID	1644	9
2026-07-15 20:03:49.793693+07	TLKM	1512	ASK	1061	5
2026-07-15 20:03:49.793693+07	TLKM	1522	ASK	1161	6
2026-07-15 20:03:49.793693+07	TLKM	1532	ASK	1251	7
2026-07-15 20:03:49.793693+07	TLKM	1542	ASK	1525	8
2026-07-15 20:03:49.793693+07	TLKM	1552	ASK	1641	9
2026-07-15 20:03:50.797126+07	TLKM	1512	BID	1164	5
2026-07-15 20:03:50.797126+07	TLKM	1502	BID	1443	6
2026-07-15 20:03:50.797126+07	TLKM	1492	BID	1332	7
2026-07-15 20:03:50.797126+07	TLKM	1482	BID	1414	8
2026-07-15 20:03:50.797126+07	TLKM	1472	BID	1759	9
2026-07-15 20:03:50.797126+07	TLKM	1512	ASK	1193	5
2026-07-15 20:03:50.797126+07	TLKM	1522	ASK	1519	6
2026-07-15 20:03:50.797126+07	TLKM	1532	ASK	1332	7
2026-07-15 20:03:50.797126+07	TLKM	1542	ASK	1539	8
2026-07-15 20:03:50.797126+07	TLKM	1552	ASK	1558	9
2026-07-15 20:03:51.806837+07	TLKM	1512	BID	1184	5
2026-07-15 20:03:51.806837+07	TLKM	1502	BID	1498	6
2026-07-15 20:03:51.806837+07	TLKM	1492	BID	1280	7
2026-07-15 20:03:51.806837+07	TLKM	1482	BID	1746	8
2026-07-15 20:03:51.806837+07	TLKM	1472	BID	1752	9
2026-07-15 20:03:51.806837+07	TLKM	1512	ASK	1077	5
2026-07-15 20:03:51.806837+07	TLKM	1522	ASK	1118	6
2026-07-15 20:03:51.806837+07	TLKM	1532	ASK	1338	7
2026-07-15 20:03:51.806837+07	TLKM	1542	ASK	1694	8
2026-07-15 20:03:51.806837+07	TLKM	1552	ASK	1801	9
2026-07-15 20:03:52.81318+07	TLKM	1512	BID	1488	5
2026-07-15 20:03:52.81318+07	TLKM	1502	BID	1326	6
2026-07-15 20:03:52.81318+07	TLKM	1492	BID	1563	7
2026-07-15 20:03:52.81318+07	TLKM	1482	BID	1547	8
2026-07-15 20:03:52.81318+07	TLKM	1472	BID	1725	9
2026-07-15 20:03:52.81318+07	TLKM	1512	ASK	1452	5
2026-07-15 20:03:52.81318+07	TLKM	1522	ASK	1311	6
2026-07-15 20:03:52.81318+07	TLKM	1532	ASK	1302	7
2026-07-15 20:03:52.81318+07	TLKM	1542	ASK	1323	8
2026-07-15 20:03:52.81318+07	TLKM	1552	ASK	1456	9
2026-07-15 20:03:53.824543+07	TLKM	1512	BID	1306	5
2026-07-15 20:03:53.824543+07	TLKM	1502	BID	1235	6
2026-07-15 20:03:53.824543+07	TLKM	1492	BID	1659	7
2026-07-15 20:03:53.824543+07	TLKM	1482	BID	1710	8
2026-07-15 20:03:53.824543+07	TLKM	1472	BID	1543	9
2026-07-15 20:03:53.824543+07	TLKM	1512	ASK	1314	5
2026-07-15 20:03:53.824543+07	TLKM	1522	ASK	1464	6
2026-07-15 20:03:53.824543+07	TLKM	1532	ASK	1654	7
2026-07-15 20:03:53.824543+07	TLKM	1542	ASK	1309	8
2026-07-15 20:03:53.824543+07	TLKM	1552	ASK	1441	9
2026-07-15 20:03:54.8316+07	TLKM	1512	BID	1105	5
2026-07-15 20:03:54.8316+07	TLKM	1502	BID	1432	6
2026-07-15 20:03:54.8316+07	TLKM	1492	BID	1386	7
2026-07-15 20:03:54.8316+07	TLKM	1482	BID	1613	8
2026-07-15 20:03:54.8316+07	TLKM	1472	BID	1757	9
2026-07-15 20:03:54.8316+07	TLKM	1512	ASK	1091	5
2026-07-15 20:03:54.8316+07	TLKM	1522	ASK	1403	6
2026-07-15 20:03:54.8316+07	TLKM	1532	ASK	1653	7
2026-07-15 20:03:54.8316+07	TLKM	1542	ASK	1322	8
2026-07-15 20:03:54.8316+07	TLKM	1552	ASK	1514	9
2026-07-15 20:03:55.842471+07	TLKM	1512	BID	1486	5
2026-07-15 20:03:55.842471+07	TLKM	1502	BID	1212	6
2026-07-15 20:03:55.842471+07	TLKM	1492	BID	1474	7
2026-07-15 20:03:55.842471+07	TLKM	1482	BID	1511	8
2026-07-15 20:03:55.842471+07	TLKM	1472	BID	1833	9
2026-07-15 20:03:55.842471+07	TLKM	1512	ASK	1046	5
2026-07-15 20:03:55.842471+07	TLKM	1522	ASK	1298	6
2026-07-15 20:03:55.842471+07	TLKM	1532	ASK	1523	7
2026-07-15 20:03:55.842471+07	TLKM	1542	ASK	1307	8
2026-07-15 20:03:55.842471+07	TLKM	1552	ASK	1734	9
2026-07-15 20:03:56.846293+07	TLKM	1512	BID	1157	5
2026-07-15 20:03:56.846293+07	TLKM	1502	BID	1194	6
2026-07-15 20:03:56.846293+07	TLKM	1492	BID	1556	7
2026-07-15 20:03:56.846293+07	TLKM	1482	BID	1679	8
2026-07-15 20:03:56.846293+07	TLKM	1472	BID	1440	9
2026-07-15 20:03:56.846293+07	TLKM	1512	ASK	1385	5
2026-07-15 20:03:56.846293+07	TLKM	1522	ASK	1244	6
2026-07-15 20:03:56.846293+07	TLKM	1532	ASK	1541	7
2026-07-15 20:03:56.846293+07	TLKM	1542	ASK	1476	8
2026-07-15 20:03:56.846293+07	TLKM	1552	ASK	1796	9
2026-07-15 20:03:57.853752+07	TLKM	1512	BID	1157	5
2026-07-15 20:03:57.853752+07	TLKM	1502	BID	1443	6
2026-07-15 20:03:57.853752+07	TLKM	1492	BID	1630	7
2026-07-15 20:03:57.853752+07	TLKM	1482	BID	1579	8
2026-07-15 20:03:57.853752+07	TLKM	1472	BID	1676	9
2026-07-15 20:03:57.853752+07	TLKM	1512	ASK	1321	5
2026-07-15 20:03:57.853752+07	TLKM	1522	ASK	1560	6
2026-07-15 20:03:57.853752+07	TLKM	1532	ASK	1205	7
2026-07-15 20:03:57.853752+07	TLKM	1542	ASK	1698	8
2026-07-15 20:03:57.853752+07	TLKM	1552	ASK	1863	9
2026-07-15 20:03:58.863833+07	TLKM	1512	BID	1433	5
2026-07-15 20:03:58.863833+07	TLKM	1502	BID	1365	6
2026-07-15 20:03:58.863833+07	TLKM	1492	BID	1398	7
2026-07-15 20:03:58.863833+07	TLKM	1482	BID	1348	8
2026-07-15 20:03:58.863833+07	TLKM	1472	BID	1548	9
2026-07-15 20:03:58.863833+07	TLKM	1512	ASK	1251	5
2026-07-15 20:03:58.863833+07	TLKM	1522	ASK	1167	6
2026-07-15 20:03:58.863833+07	TLKM	1532	ASK	1609	7
2026-07-15 20:03:58.863833+07	TLKM	1542	ASK	1776	8
2026-07-15 20:03:58.863833+07	TLKM	1552	ASK	1706	9
2026-07-15 20:03:59.873467+07	TLKM	1512	BID	1149	5
2026-07-15 20:03:59.873467+07	TLKM	1502	BID	1216	6
2026-07-15 20:03:59.873467+07	TLKM	1492	BID	1673	7
2026-07-15 20:03:59.873467+07	TLKM	1482	BID	1659	8
2026-07-15 20:03:59.873467+07	TLKM	1472	BID	1640	9
2026-07-15 20:03:59.873467+07	TLKM	1512	ASK	1481	5
2026-07-15 20:03:59.873467+07	TLKM	1522	ASK	1511	6
2026-07-15 20:03:59.873467+07	TLKM	1532	ASK	1280	7
2026-07-15 20:03:59.873467+07	TLKM	1542	ASK	1681	8
2026-07-15 20:03:59.873467+07	TLKM	1552	ASK	1695	9
2026-07-15 20:04:00.880848+07	TLKM	1512	BID	1389	5
2026-07-15 20:04:00.880848+07	TLKM	1502	BID	1234	6
2026-07-15 20:04:00.880848+07	TLKM	1492	BID	1593	7
2026-07-15 20:04:00.880848+07	TLKM	1482	BID	1740	8
2026-07-15 20:04:00.880848+07	TLKM	1472	BID	1550	9
2026-07-15 20:04:00.880848+07	TLKM	1512	ASK	1368	5
2026-07-15 20:04:00.880848+07	TLKM	1522	ASK	1108	6
2026-07-15 20:04:00.880848+07	TLKM	1532	ASK	1629	7
2026-07-15 20:04:00.880848+07	TLKM	1542	ASK	1300	8
2026-07-15 20:04:00.880848+07	TLKM	1552	ASK	1523	9
2026-07-15 20:04:01.888264+07	TLKM	1512	BID	1252	5
2026-07-15 20:04:01.888264+07	TLKM	1502	BID	1182	6
2026-07-15 20:04:01.888264+07	TLKM	1492	BID	1202	7
2026-07-15 20:04:01.888264+07	TLKM	1482	BID	1796	8
2026-07-15 20:04:01.888264+07	TLKM	1472	BID	1445	9
2026-07-15 20:04:01.888264+07	TLKM	1512	ASK	1242	5
2026-07-15 20:04:01.888264+07	TLKM	1522	ASK	1176	6
2026-07-15 20:04:01.888264+07	TLKM	1532	ASK	1663	7
2026-07-15 20:04:01.888264+07	TLKM	1542	ASK	1313	8
2026-07-15 20:04:01.888264+07	TLKM	1552	ASK	1726	9
2026-07-15 20:04:02.89706+07	TLKM	1512	BID	1068	5
2026-07-15 20:04:02.89706+07	TLKM	1502	BID	1580	6
2026-07-15 20:04:02.89706+07	TLKM	1492	BID	1277	7
2026-07-15 20:04:02.89706+07	TLKM	1482	BID	1648	8
2026-07-15 20:04:02.89706+07	TLKM	1472	BID	1619	9
2026-07-15 20:04:02.89706+07	TLKM	1512	ASK	1031	5
2026-07-15 20:04:02.89706+07	TLKM	1522	ASK	1356	6
2026-07-15 20:04:02.89706+07	TLKM	1532	ASK	1616	7
2026-07-15 20:04:02.89706+07	TLKM	1542	ASK	1407	8
2026-07-15 20:04:02.89706+07	TLKM	1552	ASK	1691	9
2026-07-15 20:04:03.90533+07	TLKM	1512	BID	1015	5
2026-07-15 20:04:03.90533+07	TLKM	1502	BID	1456	6
2026-07-15 20:04:03.90533+07	TLKM	1492	BID	1656	7
2026-07-15 20:04:03.90533+07	TLKM	1482	BID	1767	8
2026-07-15 20:04:03.90533+07	TLKM	1472	BID	1789	9
2026-07-15 20:04:03.90533+07	TLKM	1512	ASK	1129	5
2026-07-15 20:04:03.90533+07	TLKM	1522	ASK	1319	6
2026-07-15 20:04:03.90533+07	TLKM	1532	ASK	1577	7
2026-07-15 20:04:03.90533+07	TLKM	1542	ASK	1415	8
2026-07-15 20:04:03.90533+07	TLKM	1552	ASK	1409	9
2026-07-15 20:04:04.913022+07	TLKM	1512	BID	1327	5
2026-07-15 20:04:04.913022+07	TLKM	1502	BID	1422	6
2026-07-15 20:04:04.913022+07	TLKM	1492	BID	1592	7
2026-07-15 20:04:04.913022+07	TLKM	1482	BID	1791	8
2026-07-15 20:04:04.913022+07	TLKM	1472	BID	1870	9
2026-07-15 20:04:04.913022+07	TLKM	1512	ASK	1273	5
2026-07-15 20:04:04.913022+07	TLKM	1522	ASK	1104	6
2026-07-15 20:04:04.913022+07	TLKM	1532	ASK	1324	7
2026-07-15 20:04:04.913022+07	TLKM	1542	ASK	1408	8
2026-07-15 20:04:04.913022+07	TLKM	1552	ASK	1630	9
2026-07-15 20:04:05.921779+07	TLKM	1512	BID	1034	5
2026-07-15 20:04:05.921779+07	TLKM	1502	BID	1343	6
2026-07-15 20:04:05.921779+07	TLKM	1492	BID	1597	7
2026-07-15 20:04:05.921779+07	TLKM	1482	BID	1518	8
2026-07-15 20:04:05.921779+07	TLKM	1472	BID	1501	9
2026-07-15 20:04:05.921779+07	TLKM	1512	ASK	1018	5
2026-07-15 20:04:05.921779+07	TLKM	1522	ASK	1552	6
2026-07-15 20:04:05.921779+07	TLKM	1532	ASK	1443	7
2026-07-15 20:04:05.921779+07	TLKM	1542	ASK	1653	8
2026-07-15 20:04:05.921779+07	TLKM	1552	ASK	1503	9
2026-07-15 20:04:06.929458+07	TLKM	1512	BID	1457	5
2026-07-15 20:04:06.929458+07	TLKM	1502	BID	1143	6
2026-07-15 20:04:06.929458+07	TLKM	1492	BID	1383	7
2026-07-15 20:04:06.929458+07	TLKM	1482	BID	1363	8
2026-07-15 20:04:06.929458+07	TLKM	1472	BID	1603	9
2026-07-15 20:04:06.929458+07	TLKM	1512	ASK	1268	5
2026-07-15 20:04:06.929458+07	TLKM	1522	ASK	1405	6
2026-07-15 20:04:06.929458+07	TLKM	1532	ASK	1656	7
2026-07-15 20:04:06.929458+07	TLKM	1542	ASK	1631	8
2026-07-15 20:04:06.929458+07	TLKM	1552	ASK	1663	9
2026-07-15 20:04:07.936117+07	TLKM	1512	BID	1406	5
2026-07-15 20:04:07.936117+07	TLKM	1502	BID	1553	6
2026-07-15 20:04:07.936117+07	TLKM	1492	BID	1282	7
2026-07-15 20:04:07.936117+07	TLKM	1482	BID	1755	8
2026-07-15 20:04:07.936117+07	TLKM	1472	BID	1669	9
2026-07-15 20:04:07.936117+07	TLKM	1512	ASK	1478	5
2026-07-15 20:04:07.936117+07	TLKM	1522	ASK	1109	6
2026-07-15 20:04:07.936117+07	TLKM	1532	ASK	1374	7
2026-07-15 20:04:07.936117+07	TLKM	1542	ASK	1310	8
2026-07-15 20:04:07.936117+07	TLKM	1552	ASK	1414	9
2026-07-15 20:04:08.946456+07	TLKM	1512	BID	1332	5
2026-07-15 20:04:08.946456+07	TLKM	1502	BID	1559	6
2026-07-15 20:04:08.946456+07	TLKM	1492	BID	1548	7
2026-07-15 20:04:08.946456+07	TLKM	1482	BID	1325	8
2026-07-15 20:04:08.946456+07	TLKM	1472	BID	1853	9
2026-07-15 20:04:08.946456+07	TLKM	1512	ASK	1069	5
2026-07-15 20:04:08.946456+07	TLKM	1522	ASK	1391	6
2026-07-15 20:04:08.946456+07	TLKM	1532	ASK	1432	7
2026-07-15 20:04:08.946456+07	TLKM	1542	ASK	1529	8
2026-07-15 20:04:08.946456+07	TLKM	1552	ASK	1464	9
2026-07-15 20:04:09.954264+07	TLKM	1512	BID	1416	5
2026-07-15 20:04:09.954264+07	TLKM	1502	BID	1239	6
2026-07-15 20:04:09.954264+07	TLKM	1492	BID	1420	7
2026-07-15 20:04:09.954264+07	TLKM	1482	BID	1429	8
2026-07-15 20:04:09.954264+07	TLKM	1472	BID	1672	9
2026-07-15 20:04:09.954264+07	TLKM	1512	ASK	1162	5
2026-07-15 20:04:09.954264+07	TLKM	1522	ASK	1426	6
2026-07-15 20:04:09.954264+07	TLKM	1532	ASK	1328	7
2026-07-15 20:04:09.954264+07	TLKM	1542	ASK	1394	8
2026-07-15 20:04:09.954264+07	TLKM	1552	ASK	1681	9
2026-07-15 20:04:10.964545+07	TLKM	1512	BID	1473	5
2026-07-15 20:04:10.964545+07	TLKM	1502	BID	1353	6
2026-07-15 20:04:10.964545+07	TLKM	1492	BID	1378	7
2026-07-15 20:04:10.964545+07	TLKM	1482	BID	1632	8
2026-07-15 20:04:10.964545+07	TLKM	1472	BID	1603	9
2026-07-15 20:04:10.964545+07	TLKM	1512	ASK	1189	5
2026-07-15 20:04:10.964545+07	TLKM	1522	ASK	1345	6
2026-07-15 20:04:10.964545+07	TLKM	1532	ASK	1517	7
2026-07-15 20:04:10.964545+07	TLKM	1542	ASK	1547	8
2026-07-15 20:04:10.964545+07	TLKM	1552	ASK	1640	9
2026-07-15 20:04:11.972832+07	TLKM	1512	BID	1429	5
2026-07-15 20:04:11.972832+07	TLKM	1502	BID	1145	6
2026-07-15 20:04:11.972832+07	TLKM	1492	BID	1286	7
2026-07-15 20:04:11.972832+07	TLKM	1482	BID	1384	8
2026-07-15 20:04:11.972832+07	TLKM	1472	BID	1429	9
2026-07-15 20:04:11.972832+07	TLKM	1512	ASK	1144	5
2026-07-15 20:04:11.972832+07	TLKM	1522	ASK	1450	6
2026-07-15 20:04:11.972832+07	TLKM	1532	ASK	1330	7
2026-07-15 20:04:11.972832+07	TLKM	1542	ASK	1519	8
2026-07-15 20:04:11.972832+07	TLKM	1552	ASK	1518	9
2026-07-15 20:04:12.97965+07	TLKM	1512	BID	1349	5
2026-07-15 20:04:12.97965+07	TLKM	1502	BID	1374	6
2026-07-15 20:04:12.97965+07	TLKM	1492	BID	1278	7
2026-07-15 20:04:12.97965+07	TLKM	1482	BID	1514	8
2026-07-15 20:04:12.97965+07	TLKM	1472	BID	1426	9
2026-07-15 20:04:12.97965+07	TLKM	1512	ASK	1206	5
2026-07-15 20:04:12.97965+07	TLKM	1522	ASK	1350	6
2026-07-15 20:04:12.97965+07	TLKM	1532	ASK	1579	7
2026-07-15 20:04:12.97965+07	TLKM	1542	ASK	1390	8
2026-07-15 20:04:12.97965+07	TLKM	1552	ASK	1594	9
2026-07-15 20:04:13.98554+07	TLKM	1512	BID	1487	5
2026-07-15 20:04:13.98554+07	TLKM	1502	BID	1536	6
2026-07-15 20:04:13.98554+07	TLKM	1492	BID	1467	7
2026-07-15 20:04:13.98554+07	TLKM	1482	BID	1340	8
2026-07-15 20:04:13.98554+07	TLKM	1472	BID	1611	9
2026-07-15 20:04:13.98554+07	TLKM	1512	ASK	1349	5
2026-07-15 20:04:13.98554+07	TLKM	1522	ASK	1597	6
2026-07-15 20:04:13.98554+07	TLKM	1532	ASK	1396	7
2026-07-15 20:04:13.98554+07	TLKM	1542	ASK	1584	8
2026-07-15 20:04:13.98554+07	TLKM	1552	ASK	1496	9
2026-07-15 20:04:14.994643+07	TLKM	1512	BID	1284	5
2026-07-15 20:04:14.994643+07	TLKM	1502	BID	1315	6
2026-07-15 20:04:14.994643+07	TLKM	1492	BID	1469	7
2026-07-15 20:04:14.994643+07	TLKM	1482	BID	1473	8
2026-07-15 20:04:14.994643+07	TLKM	1472	BID	1525	9
2026-07-15 20:04:14.994643+07	TLKM	1512	ASK	1098	5
2026-07-15 20:04:14.994643+07	TLKM	1522	ASK	1376	6
2026-07-15 20:04:14.994643+07	TLKM	1532	ASK	1230	7
2026-07-15 20:04:14.994643+07	TLKM	1542	ASK	1584	8
2026-07-15 20:04:14.994643+07	TLKM	1552	ASK	1417	9
2026-07-15 20:04:15.999158+07	TLKM	1512	BID	1422	5
2026-07-15 20:04:15.999158+07	TLKM	1502	BID	1241	6
2026-07-15 20:04:15.999158+07	TLKM	1492	BID	1551	7
2026-07-15 20:04:15.999158+07	TLKM	1482	BID	1498	8
2026-07-15 20:04:15.999158+07	TLKM	1472	BID	1514	9
2026-07-15 20:04:15.999158+07	TLKM	1512	ASK	1371	5
2026-07-15 20:04:15.999158+07	TLKM	1522	ASK	1247	6
2026-07-15 20:04:15.999158+07	TLKM	1532	ASK	1608	7
2026-07-15 20:04:15.999158+07	TLKM	1542	ASK	1609	8
2026-07-15 20:04:15.999158+07	TLKM	1552	ASK	1559	9
2026-07-15 20:04:17.009622+07	TLKM	1512	BID	1129	5
2026-07-15 20:04:17.009622+07	TLKM	1502	BID	1350	6
2026-07-15 20:04:17.009622+07	TLKM	1492	BID	1632	7
2026-07-15 20:04:17.009622+07	TLKM	1482	BID	1721	8
2026-07-15 20:04:17.009622+07	TLKM	1472	BID	1768	9
2026-07-15 20:04:17.009622+07	TLKM	1512	ASK	1499	5
2026-07-15 20:04:17.009622+07	TLKM	1522	ASK	1299	6
2026-07-15 20:04:17.009622+07	TLKM	1532	ASK	1672	7
2026-07-15 20:04:17.009622+07	TLKM	1542	ASK	1514	8
2026-07-15 20:04:17.009622+07	TLKM	1552	ASK	1585	9
2026-07-15 20:04:18.016122+07	TLKM	1512	BID	1195	5
2026-07-15 20:04:18.016122+07	TLKM	1502	BID	1591	6
2026-07-15 20:04:18.016122+07	TLKM	1492	BID	1446	7
2026-07-15 20:04:18.016122+07	TLKM	1482	BID	1404	8
2026-07-15 20:04:18.016122+07	TLKM	1472	BID	1576	9
2026-07-15 20:04:18.016122+07	TLKM	1512	ASK	1030	5
2026-07-15 20:04:18.016122+07	TLKM	1522	ASK	1307	6
2026-07-15 20:04:18.016122+07	TLKM	1532	ASK	1562	7
2026-07-15 20:04:18.016122+07	TLKM	1542	ASK	1755	8
2026-07-15 20:04:18.016122+07	TLKM	1552	ASK	1705	9
2026-07-15 20:04:19.0262+07	TLKM	1512	BID	1464	5
2026-07-15 20:04:19.0262+07	TLKM	1502	BID	1249	6
2026-07-15 20:04:19.0262+07	TLKM	1492	BID	1440	7
2026-07-15 20:04:19.0262+07	TLKM	1482	BID	1643	8
2026-07-15 20:04:19.0262+07	TLKM	1472	BID	1502	9
2026-07-15 20:04:19.0262+07	TLKM	1512	ASK	1158	5
2026-07-15 20:04:19.0262+07	TLKM	1522	ASK	1354	6
2026-07-15 20:04:19.0262+07	TLKM	1532	ASK	1666	7
2026-07-15 20:04:19.0262+07	TLKM	1542	ASK	1639	8
2026-07-15 20:04:19.0262+07	TLKM	1552	ASK	1451	9
2026-07-15 20:04:20.035587+07	TLKM	1512	BID	1386	5
2026-07-15 20:04:20.035587+07	TLKM	1502	BID	1415	6
2026-07-15 20:04:20.035587+07	TLKM	1492	BID	1617	7
2026-07-15 20:04:20.035587+07	TLKM	1482	BID	1398	8
2026-07-15 20:04:20.035587+07	TLKM	1472	BID	1527	9
2026-07-15 20:04:20.035587+07	TLKM	1512	ASK	1111	5
2026-07-15 20:04:20.035587+07	TLKM	1522	ASK	1510	6
2026-07-15 20:04:20.035587+07	TLKM	1532	ASK	1457	7
2026-07-15 20:04:20.035587+07	TLKM	1542	ASK	1426	8
2026-07-15 20:04:20.035587+07	TLKM	1552	ASK	1432	9
2026-07-15 20:04:21.046857+07	TLKM	1512	BID	1335	5
2026-07-15 20:04:21.046857+07	TLKM	1502	BID	1555	6
2026-07-15 20:04:21.046857+07	TLKM	1492	BID	1362	7
2026-07-15 20:04:21.046857+07	TLKM	1482	BID	1726	8
2026-07-15 20:04:21.046857+07	TLKM	1472	BID	1526	9
2026-07-15 20:04:21.046857+07	TLKM	1512	ASK	1179	5
2026-07-15 20:04:21.046857+07	TLKM	1522	ASK	1400	6
2026-07-15 20:04:21.046857+07	TLKM	1532	ASK	1665	7
2026-07-15 20:04:21.046857+07	TLKM	1542	ASK	1702	8
2026-07-15 20:04:21.046857+07	TLKM	1552	ASK	1612	9
2026-07-15 20:04:22.054255+07	TLKM	1512	BID	1072	5
2026-07-15 20:04:22.054255+07	TLKM	1502	BID	1398	6
2026-07-15 20:04:22.054255+07	TLKM	1492	BID	1422	7
2026-07-15 20:04:22.054255+07	TLKM	1482	BID	1662	8
2026-07-15 20:04:22.054255+07	TLKM	1472	BID	1461	9
2026-07-15 20:04:22.054255+07	TLKM	1512	ASK	1255	5
2026-07-15 20:04:22.054255+07	TLKM	1522	ASK	1588	6
2026-07-15 20:04:22.054255+07	TLKM	1532	ASK	1324	7
2026-07-15 20:04:22.054255+07	TLKM	1542	ASK	1473	8
2026-07-15 20:04:22.054255+07	TLKM	1552	ASK	1739	9
2026-07-15 20:04:23.064503+07	TLKM	1512	BID	1176	5
2026-07-15 20:04:23.064503+07	TLKM	1502	BID	1442	6
2026-07-15 20:04:23.064503+07	TLKM	1492	BID	1489	7
2026-07-15 20:04:23.064503+07	TLKM	1482	BID	1660	8
2026-07-15 20:04:23.064503+07	TLKM	1472	BID	1882	9
2026-07-15 20:04:23.064503+07	TLKM	1512	ASK	1418	5
2026-07-15 20:04:23.064503+07	TLKM	1522	ASK	1297	6
2026-07-15 20:04:23.064503+07	TLKM	1532	ASK	1671	7
2026-07-15 20:04:23.064503+07	TLKM	1542	ASK	1718	8
2026-07-15 20:04:23.064503+07	TLKM	1552	ASK	1874	9
2026-07-15 20:04:24.07061+07	TLKM	1512	BID	1278	5
2026-07-15 20:04:24.07061+07	TLKM	1502	BID	1443	6
2026-07-15 20:04:24.07061+07	TLKM	1492	BID	1254	7
2026-07-15 20:04:24.07061+07	TLKM	1482	BID	1491	8
2026-07-15 20:04:24.07061+07	TLKM	1472	BID	1648	9
2026-07-15 20:04:24.07061+07	TLKM	1512	ASK	1352	5
2026-07-15 20:04:24.07061+07	TLKM	1522	ASK	1284	6
2026-07-15 20:04:24.07061+07	TLKM	1532	ASK	1412	7
2026-07-15 20:04:24.07061+07	TLKM	1542	ASK	1351	8
2026-07-15 20:04:24.07061+07	TLKM	1552	ASK	1623	9
2026-07-15 20:04:25.081299+07	TLKM	1512	BID	1391	5
2026-07-15 20:04:25.081299+07	TLKM	1502	BID	1522	6
2026-07-15 20:04:25.081299+07	TLKM	1492	BID	1663	7
2026-07-15 20:04:25.081299+07	TLKM	1482	BID	1670	8
2026-07-15 20:04:25.081299+07	TLKM	1472	BID	1456	9
2026-07-15 20:04:25.081299+07	TLKM	1512	ASK	1280	5
2026-07-15 20:04:25.081299+07	TLKM	1522	ASK	1182	6
2026-07-15 20:04:25.081299+07	TLKM	1532	ASK	1359	7
2026-07-15 20:04:25.081299+07	TLKM	1542	ASK	1704	8
2026-07-15 20:04:25.081299+07	TLKM	1552	ASK	1706	9
2026-07-15 20:04:26.088868+07	TLKM	1512	BID	1120	5
2026-07-15 20:04:26.088868+07	TLKM	1502	BID	1442	6
2026-07-15 20:04:26.088868+07	TLKM	1492	BID	1401	7
2026-07-15 20:04:26.088868+07	TLKM	1482	BID	1770	8
2026-07-15 20:04:26.088868+07	TLKM	1472	BID	1759	9
2026-07-15 20:04:26.088868+07	TLKM	1512	ASK	1180	5
2026-07-15 20:04:26.088868+07	TLKM	1522	ASK	1491	6
2026-07-15 20:04:26.088868+07	TLKM	1532	ASK	1600	7
2026-07-15 20:04:26.088868+07	TLKM	1542	ASK	1363	8
2026-07-15 20:04:26.088868+07	TLKM	1552	ASK	1469	9
2026-07-15 20:04:27.097784+07	TLKM	1512	BID	1123	5
2026-07-15 20:04:27.097784+07	TLKM	1502	BID	1518	6
2026-07-15 20:04:27.097784+07	TLKM	1492	BID	1281	7
2026-07-15 20:04:27.097784+07	TLKM	1482	BID	1717	8
2026-07-15 20:04:27.097784+07	TLKM	1472	BID	1680	9
2026-07-15 20:04:27.097784+07	TLKM	1512	ASK	1484	5
2026-07-15 20:04:27.097784+07	TLKM	1522	ASK	1125	6
2026-07-15 20:04:27.097784+07	TLKM	1532	ASK	1450	7
2026-07-15 20:04:27.097784+07	TLKM	1542	ASK	1589	8
2026-07-15 20:04:27.097784+07	TLKM	1552	ASK	1878	9
2026-07-15 20:04:28.102656+07	TLKM	1512	BID	1058	5
2026-07-15 20:04:28.102656+07	TLKM	1502	BID	1439	6
2026-07-15 20:04:28.102656+07	TLKM	1492	BID	1422	7
2026-07-15 20:04:28.102656+07	TLKM	1482	BID	1440	8
2026-07-15 20:04:28.102656+07	TLKM	1472	BID	1704	9
2026-07-15 20:04:28.102656+07	TLKM	1512	ASK	1012	5
2026-07-15 20:04:28.102656+07	TLKM	1522	ASK	1275	6
2026-07-15 20:04:28.102656+07	TLKM	1532	ASK	1603	7
2026-07-15 20:04:28.102656+07	TLKM	1542	ASK	1428	8
2026-07-15 20:04:28.102656+07	TLKM	1552	ASK	1436	9
2026-07-15 20:04:29.113195+07	TLKM	1512	BID	1152	5
2026-07-15 20:04:29.113195+07	TLKM	1502	BID	1434	6
2026-07-15 20:04:29.113195+07	TLKM	1492	BID	1284	7
2026-07-15 20:04:29.113195+07	TLKM	1482	BID	1399	8
2026-07-15 20:04:29.113195+07	TLKM	1472	BID	1863	9
2026-07-15 20:04:29.113195+07	TLKM	1512	ASK	1136	5
2026-07-15 20:04:29.113195+07	TLKM	1522	ASK	1579	6
2026-07-15 20:04:29.113195+07	TLKM	1532	ASK	1410	7
2026-07-15 20:04:29.113195+07	TLKM	1542	ASK	1468	8
2026-07-15 20:04:29.113195+07	TLKM	1552	ASK	1815	9
2026-07-15 20:04:30.116998+07	TLKM	1512	BID	1408	5
2026-07-15 20:04:30.116998+07	TLKM	1502	BID	1576	6
2026-07-15 20:04:30.116998+07	TLKM	1492	BID	1229	7
2026-07-15 20:04:30.116998+07	TLKM	1482	BID	1333	8
2026-07-15 20:04:30.116998+07	TLKM	1472	BID	1483	9
2026-07-15 20:04:30.116998+07	TLKM	1512	ASK	1290	5
2026-07-15 20:04:30.116998+07	TLKM	1522	ASK	1357	6
2026-07-15 20:04:30.116998+07	TLKM	1532	ASK	1223	7
2026-07-15 20:04:30.116998+07	TLKM	1542	ASK	1496	8
2026-07-15 20:04:30.116998+07	TLKM	1552	ASK	1798	9
2026-07-15 20:04:31.125191+07	TLKM	1512	BID	1486	5
2026-07-15 20:04:31.125191+07	TLKM	1502	BID	1462	6
2026-07-15 20:04:31.125191+07	TLKM	1492	BID	1555	7
2026-07-15 20:04:31.125191+07	TLKM	1482	BID	1692	8
2026-07-15 20:04:31.125191+07	TLKM	1472	BID	1716	9
2026-07-15 20:04:31.125191+07	TLKM	1512	ASK	1210	5
2026-07-15 20:04:31.125191+07	TLKM	1522	ASK	1240	6
2026-07-15 20:04:31.125191+07	TLKM	1532	ASK	1670	7
2026-07-15 20:04:31.125191+07	TLKM	1542	ASK	1435	8
2026-07-15 20:04:31.125191+07	TLKM	1552	ASK	1585	9
2026-07-15 20:04:32.131625+07	TLKM	1512	BID	1409	5
2026-07-15 20:04:32.131625+07	TLKM	1502	BID	1347	6
2026-07-15 20:04:32.131625+07	TLKM	1492	BID	1359	7
2026-07-15 20:04:32.131625+07	TLKM	1482	BID	1734	8
2026-07-15 20:04:32.131625+07	TLKM	1472	BID	1846	9
2026-07-15 20:04:32.131625+07	TLKM	1512	ASK	1461	5
2026-07-15 20:04:32.131625+07	TLKM	1522	ASK	1409	6
2026-07-15 20:04:32.131625+07	TLKM	1532	ASK	1328	7
2026-07-15 20:04:32.131625+07	TLKM	1542	ASK	1780	8
2026-07-15 20:04:32.131625+07	TLKM	1552	ASK	1455	9
2026-07-15 20:04:33.138838+07	TLKM	1512	BID	1205	5
2026-07-15 20:04:33.138838+07	TLKM	1502	BID	1325	6
2026-07-15 20:04:33.138838+07	TLKM	1492	BID	1380	7
2026-07-15 20:04:33.138838+07	TLKM	1482	BID	1482	8
2026-07-15 20:04:33.138838+07	TLKM	1472	BID	1478	9
2026-07-15 20:04:33.138838+07	TLKM	1512	ASK	1060	5
2026-07-15 20:04:33.138838+07	TLKM	1522	ASK	1535	6
2026-07-15 20:04:33.138838+07	TLKM	1532	ASK	1443	7
2026-07-15 20:04:33.138838+07	TLKM	1542	ASK	1588	8
2026-07-15 20:04:33.138838+07	TLKM	1552	ASK	1441	9
2026-07-15 20:04:34.146405+07	TLKM	1512	BID	1375	5
2026-07-15 20:04:34.146405+07	TLKM	1502	BID	1563	6
2026-07-15 20:04:34.146405+07	TLKM	1492	BID	1471	7
2026-07-15 20:04:34.146405+07	TLKM	1482	BID	1524	8
2026-07-15 20:04:34.146405+07	TLKM	1472	BID	1640	9
2026-07-15 20:04:34.146405+07	TLKM	1512	ASK	1182	5
2026-07-15 20:04:34.146405+07	TLKM	1522	ASK	1598	6
2026-07-15 20:04:34.146405+07	TLKM	1532	ASK	1570	7
2026-07-15 20:04:34.146405+07	TLKM	1542	ASK	1643	8
2026-07-15 20:04:34.146405+07	TLKM	1552	ASK	1728	9
2026-07-15 20:04:35.149622+07	TLKM	1512	BID	58830	5
2026-07-15 20:04:35.149622+07	TLKM	1502	BID	1452	6
2026-07-15 20:04:35.149622+07	TLKM	1492	BID	1505	7
2026-07-15 20:04:35.149622+07	TLKM	1482	BID	1712	8
2026-07-15 20:04:35.149622+07	TLKM	1472	BID	1482	9
2026-07-15 20:04:35.149622+07	TLKM	1512	ASK	1416	5
2026-07-15 20:04:35.149622+07	TLKM	1522	ASK	1510	6
2026-07-15 20:04:35.149622+07	TLKM	1532	ASK	1244	7
2026-07-15 20:04:35.149622+07	TLKM	1542	ASK	1364	8
2026-07-15 20:04:35.149622+07	TLKM	1552	ASK	1768	9
2026-07-15 20:04:36.158297+07	TLKM	1512	BID	51920	5
2026-07-15 20:04:36.158297+07	TLKM	1502	BID	1116	6
2026-07-15 20:04:36.158297+07	TLKM	1492	BID	1668	7
2026-07-15 20:04:36.158297+07	TLKM	1482	BID	1412	8
2026-07-15 20:04:36.158297+07	TLKM	1472	BID	1479	9
2026-07-15 20:04:36.158297+07	TLKM	1512	ASK	1314	5
2026-07-15 20:04:36.158297+07	TLKM	1522	ASK	1246	6
2026-07-15 20:04:36.158297+07	TLKM	1532	ASK	1410	7
2026-07-15 20:04:36.158297+07	TLKM	1542	ASK	1676	8
2026-07-15 20:04:36.158297+07	TLKM	1552	ASK	1880	9
2026-07-15 20:04:37.165252+07	TLKM	1512	BID	50153	5
2026-07-15 20:04:37.165252+07	TLKM	1502	BID	1428	6
2026-07-15 20:04:37.165252+07	TLKM	1492	BID	1502	7
2026-07-15 20:04:37.165252+07	TLKM	1482	BID	1403	8
2026-07-15 20:04:37.165252+07	TLKM	1472	BID	1778	9
2026-07-15 20:04:37.165252+07	TLKM	1512	ASK	1317	5
2026-07-15 20:04:37.165252+07	TLKM	1522	ASK	1479	6
2026-07-15 20:04:37.165252+07	TLKM	1532	ASK	1280	7
2026-07-15 20:04:37.165252+07	TLKM	1542	ASK	1506	8
2026-07-15 20:04:37.165252+07	TLKM	1552	ASK	1407	9
2026-07-15 20:04:38.171187+07	TLKM	1512	BID	58376	5
2026-07-15 20:04:38.171187+07	TLKM	1502	BID	1358	6
2026-07-15 20:04:38.171187+07	TLKM	1492	BID	1465	7
2026-07-15 20:04:38.171187+07	TLKM	1482	BID	1743	8
2026-07-15 20:04:38.171187+07	TLKM	1472	BID	1410	9
2026-07-15 20:04:38.171187+07	TLKM	1512	ASK	1438	5
2026-07-15 20:04:38.171187+07	TLKM	1522	ASK	1130	6
2026-07-15 20:04:38.171187+07	TLKM	1532	ASK	1521	7
2026-07-15 20:04:38.171187+07	TLKM	1542	ASK	1568	8
2026-07-15 20:04:38.171187+07	TLKM	1552	ASK	1689	9
2026-07-15 20:04:39.17945+07	TLKM	1512	BID	54469	5
2026-07-15 20:04:39.17945+07	TLKM	1502	BID	1302	6
2026-07-15 20:04:39.17945+07	TLKM	1492	BID	1234	7
2026-07-15 20:04:39.17945+07	TLKM	1482	BID	1733	8
2026-07-15 20:04:39.17945+07	TLKM	1472	BID	1620	9
2026-07-15 20:04:39.17945+07	TLKM	1512	ASK	1403	5
2026-07-15 20:04:39.17945+07	TLKM	1522	ASK	1177	6
2026-07-15 20:04:39.17945+07	TLKM	1532	ASK	1665	7
2026-07-15 20:04:39.17945+07	TLKM	1542	ASK	1759	8
2026-07-15 20:04:39.17945+07	TLKM	1552	ASK	1441	9
2026-07-15 20:04:40.186455+07	TLKM	1512	BID	51028	5
2026-07-15 20:04:40.186455+07	TLKM	1502	BID	1550	6
2026-07-15 20:04:40.186455+07	TLKM	1492	BID	1413	7
2026-07-15 20:04:40.186455+07	TLKM	1482	BID	1312	8
2026-07-15 20:04:40.186455+07	TLKM	1472	BID	1878	9
2026-07-15 20:04:40.186455+07	TLKM	1512	ASK	1064	5
2026-07-15 20:04:40.186455+07	TLKM	1522	ASK	1394	6
2026-07-15 20:04:40.186455+07	TLKM	1532	ASK	1324	7
2026-07-15 20:04:40.186455+07	TLKM	1542	ASK	1702	8
2026-07-15 20:04:40.186455+07	TLKM	1552	ASK	1430	9
2026-07-15 20:04:41.195793+07	TLKM	1512	BID	56616	5
2026-07-15 20:04:41.195793+07	TLKM	1502	BID	1405	6
2026-07-15 20:04:41.195793+07	TLKM	1492	BID	1475	7
2026-07-15 20:04:41.195793+07	TLKM	1482	BID	1655	8
2026-07-15 20:04:41.195793+07	TLKM	1472	BID	1693	9
2026-07-15 20:04:41.195793+07	TLKM	1512	ASK	1461	5
2026-07-15 20:04:41.195793+07	TLKM	1522	ASK	1125	6
2026-07-15 20:04:41.195793+07	TLKM	1532	ASK	1442	7
2026-07-15 20:04:41.195793+07	TLKM	1542	ASK	1360	8
2026-07-15 20:04:41.195793+07	TLKM	1552	ASK	1823	9
2026-07-15 20:04:42.198915+07	TLKM	1512	BID	52096	5
2026-07-15 20:04:42.198915+07	TLKM	1502	BID	1447	6
2026-07-15 20:04:42.198915+07	TLKM	1492	BID	1301	7
2026-07-15 20:04:42.198915+07	TLKM	1482	BID	1766	8
2026-07-15 20:04:42.198915+07	TLKM	1472	BID	1553	9
2026-07-15 20:04:42.198915+07	TLKM	1512	ASK	1265	5
2026-07-15 20:04:42.198915+07	TLKM	1522	ASK	1139	6
2026-07-15 20:04:42.198915+07	TLKM	1532	ASK	1547	7
2026-07-15 20:04:42.198915+07	TLKM	1542	ASK	1672	8
2026-07-15 20:04:42.198915+07	TLKM	1552	ASK	1452	9
2026-07-15 20:04:43.205587+07	TLKM	1512	BID	51055	5
2026-07-15 20:04:43.205587+07	TLKM	1502	BID	1238	6
2026-07-15 20:04:43.205587+07	TLKM	1492	BID	1292	7
2026-07-15 20:04:43.205587+07	TLKM	1482	BID	1366	8
2026-07-15 20:04:43.205587+07	TLKM	1472	BID	1735	9
2026-07-15 20:04:43.205587+07	TLKM	1512	ASK	1389	5
2026-07-15 20:04:43.205587+07	TLKM	1522	ASK	1231	6
2026-07-15 20:04:43.205587+07	TLKM	1532	ASK	1219	7
2026-07-15 20:04:43.205587+07	TLKM	1542	ASK	1518	8
2026-07-15 20:04:43.205587+07	TLKM	1552	ASK	1811	9
2026-07-15 20:04:44.214387+07	TLKM	1512	BID	51586	5
2026-07-15 20:04:44.214387+07	TLKM	1502	BID	1459	6
2026-07-15 20:04:44.214387+07	TLKM	1492	BID	1519	7
2026-07-15 20:04:44.214387+07	TLKM	1482	BID	1521	8
2026-07-15 20:04:44.214387+07	TLKM	1472	BID	1444	9
2026-07-15 20:04:44.214387+07	TLKM	1512	ASK	1407	5
2026-07-15 20:04:44.214387+07	TLKM	1522	ASK	1110	6
2026-07-15 20:04:44.214387+07	TLKM	1532	ASK	1340	7
2026-07-15 20:04:44.214387+07	TLKM	1542	ASK	1734	8
2026-07-15 20:04:44.214387+07	TLKM	1552	ASK	1871	9
2026-07-15 20:04:45.217641+07	TLKM	1512	BID	57371	5
2026-07-15 20:04:45.217641+07	TLKM	1502	BID	1418	6
2026-07-15 20:04:45.217641+07	TLKM	1492	BID	1237	7
2026-07-15 20:04:45.217641+07	TLKM	1482	BID	1641	8
2026-07-15 20:04:45.217641+07	TLKM	1472	BID	1657	9
2026-07-15 20:04:45.217641+07	TLKM	1512	ASK	1118	5
2026-07-15 20:04:45.217641+07	TLKM	1522	ASK	1355	6
2026-07-15 20:04:45.217641+07	TLKM	1532	ASK	1387	7
2026-07-15 20:04:45.217641+07	TLKM	1542	ASK	1576	8
2026-07-15 20:04:45.217641+07	TLKM	1552	ASK	1742	9
2026-07-15 20:04:46.225878+07	TLKM	1512	BID	57504	5
2026-07-15 20:04:46.225878+07	TLKM	1502	BID	1374	6
2026-07-15 20:04:46.225878+07	TLKM	1492	BID	1534	7
2026-07-15 20:04:46.225878+07	TLKM	1482	BID	1745	8
2026-07-15 20:04:46.225878+07	TLKM	1472	BID	1635	9
2026-07-15 20:04:46.225878+07	TLKM	1512	ASK	1021	5
2026-07-15 20:04:46.225878+07	TLKM	1522	ASK	1165	6
2026-07-15 20:04:46.225878+07	TLKM	1532	ASK	1587	7
2026-07-15 20:04:46.225878+07	TLKM	1542	ASK	1703	8
2026-07-15 20:04:46.225878+07	TLKM	1552	ASK	1880	9
2026-07-15 20:04:47.232189+07	TLKM	1512	BID	56466	5
2026-07-15 20:04:47.232189+07	TLKM	1502	BID	1483	6
2026-07-15 20:04:47.232189+07	TLKM	1492	BID	1212	7
2026-07-15 20:04:47.232189+07	TLKM	1482	BID	1493	8
2026-07-15 20:04:47.232189+07	TLKM	1472	BID	1718	9
2026-07-15 20:04:47.232189+07	TLKM	1512	ASK	1132	5
2026-07-15 20:04:47.232189+07	TLKM	1522	ASK	1565	6
2026-07-15 20:04:47.232189+07	TLKM	1532	ASK	1592	7
2026-07-15 20:04:47.232189+07	TLKM	1542	ASK	1606	8
2026-07-15 20:04:47.232189+07	TLKM	1552	ASK	1745	9
2026-07-15 20:04:48.239833+07	TLKM	1512	BID	51594	5
2026-07-15 20:04:48.239833+07	TLKM	1502	BID	1469	6
2026-07-15 20:04:48.239833+07	TLKM	1492	BID	1644	7
2026-07-15 20:04:48.239833+07	TLKM	1482	BID	1711	8
2026-07-15 20:04:48.239833+07	TLKM	1472	BID	1401	9
2026-07-15 20:04:48.239833+07	TLKM	1512	ASK	1103	5
2026-07-15 20:04:48.239833+07	TLKM	1522	ASK	1276	6
2026-07-15 20:04:48.239833+07	TLKM	1532	ASK	1247	7
2026-07-15 20:04:48.239833+07	TLKM	1542	ASK	1519	8
2026-07-15 20:04:48.239833+07	TLKM	1552	ASK	1620	9
2026-07-15 20:04:49.24685+07	TLKM	1512	BID	56789	5
2026-07-15 20:04:49.24685+07	TLKM	1502	BID	1475	6
2026-07-15 20:04:49.24685+07	TLKM	1492	BID	1295	7
2026-07-15 20:04:49.24685+07	TLKM	1482	BID	1597	8
2026-07-15 20:04:49.24685+07	TLKM	1472	BID	1882	9
2026-07-15 20:04:49.24685+07	TLKM	1512	ASK	1046	5
2026-07-15 20:04:49.24685+07	TLKM	1522	ASK	1303	6
2026-07-15 20:04:49.24685+07	TLKM	1532	ASK	1587	7
2026-07-15 20:04:49.24685+07	TLKM	1542	ASK	1443	8
2026-07-15 20:04:49.24685+07	TLKM	1552	ASK	1444	9
2026-07-15 20:04:50.250467+07	TLKM	1512	BID	51920	5
2026-07-15 20:04:50.250467+07	TLKM	1502	BID	1567	6
2026-07-15 20:04:50.250467+07	TLKM	1492	BID	1424	7
2026-07-15 20:04:50.250467+07	TLKM	1482	BID	1730	8
2026-07-15 20:04:50.250467+07	TLKM	1472	BID	1435	9
2026-07-15 20:04:50.250467+07	TLKM	1512	ASK	1115	5
2026-07-15 20:04:50.250467+07	TLKM	1522	ASK	1441	6
2026-07-15 20:04:50.250467+07	TLKM	1532	ASK	1467	7
2026-07-15 20:04:50.250467+07	TLKM	1542	ASK	1554	8
2026-07-15 20:04:50.250467+07	TLKM	1552	ASK	1703	9
2026-07-15 20:04:51.257199+07	TLKM	1512	BID	53158	5
2026-07-15 20:04:51.257199+07	TLKM	1502	BID	1251	6
2026-07-15 20:04:51.257199+07	TLKM	1492	BID	1632	7
2026-07-15 20:04:51.257199+07	TLKM	1482	BID	1793	8
2026-07-15 20:04:51.257199+07	TLKM	1472	BID	1495	9
2026-07-15 20:04:51.257199+07	TLKM	1512	ASK	1059	5
2026-07-15 20:04:51.257199+07	TLKM	1522	ASK	1194	6
2026-07-15 20:04:51.257199+07	TLKM	1532	ASK	1296	7
2026-07-15 20:04:51.257199+07	TLKM	1542	ASK	1323	8
2026-07-15 20:04:51.257199+07	TLKM	1552	ASK	1562	9
2026-07-15 20:04:52.26597+07	TLKM	1512	BID	58389	5
2026-07-15 20:04:52.26597+07	TLKM	1502	BID	1112	6
2026-07-15 20:04:52.26597+07	TLKM	1492	BID	1268	7
2026-07-15 20:04:52.26597+07	TLKM	1482	BID	1532	8
2026-07-15 20:04:52.26597+07	TLKM	1472	BID	1532	9
2026-07-15 20:04:52.26597+07	TLKM	1512	ASK	1279	5
2026-07-15 20:04:52.26597+07	TLKM	1522	ASK	1443	6
2026-07-15 20:04:52.26597+07	TLKM	1532	ASK	1495	7
2026-07-15 20:04:52.26597+07	TLKM	1542	ASK	1502	8
2026-07-15 20:04:52.26597+07	TLKM	1552	ASK	1611	9
2026-07-15 20:04:53.271428+07	TLKM	1512	BID	58955	5
2026-07-15 20:04:53.271428+07	TLKM	1502	BID	1303	6
2026-07-15 20:04:53.271428+07	TLKM	1492	BID	1295	7
2026-07-15 20:04:53.271428+07	TLKM	1482	BID	1639	8
2026-07-15 20:04:53.271428+07	TLKM	1472	BID	1708	9
2026-07-15 20:04:53.271428+07	TLKM	1512	ASK	1021	5
2026-07-15 20:04:53.271428+07	TLKM	1522	ASK	1186	6
2026-07-15 20:04:53.271428+07	TLKM	1532	ASK	1469	7
2026-07-15 20:04:53.271428+07	TLKM	1542	ASK	1796	8
2026-07-15 20:04:53.271428+07	TLKM	1552	ASK	1427	9
2026-07-15 20:04:54.281426+07	TLKM	1512	BID	55766	5
2026-07-15 20:04:54.281426+07	TLKM	1502	BID	1361	6
2026-07-15 20:04:54.281426+07	TLKM	1492	BID	1558	7
2026-07-15 20:04:54.281426+07	TLKM	1482	BID	1325	8
2026-07-15 20:04:54.281426+07	TLKM	1472	BID	1533	9
2026-07-15 20:04:54.281426+07	TLKM	1512	ASK	1260	5
2026-07-15 20:04:54.281426+07	TLKM	1522	ASK	1503	6
2026-07-15 20:04:54.281426+07	TLKM	1532	ASK	1210	7
2026-07-15 20:04:54.281426+07	TLKM	1542	ASK	1612	8
2026-07-15 20:04:54.281426+07	TLKM	1552	ASK	1406	9
2026-07-15 20:04:55.28781+07	TLKM	1512	BID	58675	5
2026-07-15 20:04:55.28781+07	TLKM	1502	BID	1120	6
2026-07-15 20:04:55.28781+07	TLKM	1492	BID	1260	7
2026-07-15 20:04:55.28781+07	TLKM	1482	BID	1539	8
2026-07-15 20:04:55.28781+07	TLKM	1472	BID	1413	9
2026-07-15 20:04:55.28781+07	TLKM	1512	ASK	1017	5
2026-07-15 20:04:55.28781+07	TLKM	1522	ASK	1284	6
2026-07-15 20:04:55.28781+07	TLKM	1532	ASK	1200	7
2026-07-15 20:04:55.28781+07	TLKM	1542	ASK	1353	8
2026-07-15 20:04:55.28781+07	TLKM	1552	ASK	1672	9
2026-07-15 20:04:56.295518+07	TLKM	1512	BID	58145	5
2026-07-15 20:04:56.295518+07	TLKM	1502	BID	1451	6
2026-07-15 20:04:56.295518+07	TLKM	1492	BID	1470	7
2026-07-15 20:04:56.295518+07	TLKM	1482	BID	1425	8
2026-07-15 20:04:56.295518+07	TLKM	1472	BID	1458	9
2026-07-15 20:04:56.295518+07	TLKM	1512	ASK	1335	5
2026-07-15 20:04:56.295518+07	TLKM	1522	ASK	1571	6
2026-07-15 20:04:56.295518+07	TLKM	1532	ASK	1681	7
2026-07-15 20:04:56.295518+07	TLKM	1542	ASK	1369	8
2026-07-15 20:04:56.295518+07	TLKM	1552	ASK	1681	9
2026-07-15 20:04:57.305258+07	TLKM	1512	BID	55630	5
2026-07-15 20:04:57.305258+07	TLKM	1502	BID	1459	6
2026-07-15 20:04:57.305258+07	TLKM	1492	BID	1629	7
2026-07-15 20:04:57.305258+07	TLKM	1482	BID	1560	8
2026-07-15 20:04:57.305258+07	TLKM	1472	BID	1862	9
2026-07-15 20:04:57.305258+07	TLKM	1512	ASK	1149	5
2026-07-15 20:04:57.305258+07	TLKM	1522	ASK	1290	6
2026-07-15 20:04:57.305258+07	TLKM	1532	ASK	1653	7
2026-07-15 20:04:57.305258+07	TLKM	1542	ASK	1587	8
2026-07-15 20:04:57.305258+07	TLKM	1552	ASK	1556	9
2026-07-15 20:04:58.313069+07	TLKM	1512	BID	52064	5
2026-07-15 20:04:58.313069+07	TLKM	1502	BID	1556	6
2026-07-15 20:04:58.313069+07	TLKM	1492	BID	1464	7
2026-07-15 20:04:58.313069+07	TLKM	1482	BID	1756	8
2026-07-15 20:04:58.313069+07	TLKM	1472	BID	1897	9
2026-07-15 20:04:58.313069+07	TLKM	1512	ASK	1245	5
2026-07-15 20:04:58.313069+07	TLKM	1522	ASK	1162	6
2026-07-15 20:04:58.313069+07	TLKM	1532	ASK	1372	7
2026-07-15 20:04:58.313069+07	TLKM	1542	ASK	1453	8
2026-07-15 20:04:58.313069+07	TLKM	1552	ASK	1437	9
2026-07-15 20:04:59.322195+07	TLKM	1512	BID	58889	5
2026-07-15 20:04:59.322195+07	TLKM	1502	BID	1300	6
2026-07-15 20:04:59.322195+07	TLKM	1492	BID	1569	7
2026-07-15 20:04:59.322195+07	TLKM	1482	BID	1553	8
2026-07-15 20:04:59.322195+07	TLKM	1472	BID	1839	9
2026-07-15 20:04:59.322195+07	TLKM	1512	ASK	1170	5
2026-07-15 20:04:59.322195+07	TLKM	1522	ASK	1206	6
2026-07-15 20:04:59.322195+07	TLKM	1532	ASK	1383	7
2026-07-15 20:04:59.322195+07	TLKM	1542	ASK	1728	8
2026-07-15 20:04:59.322195+07	TLKM	1552	ASK	1512	9
2026-07-15 20:05:00.331919+07	TLKM	1512	BID	53096	5
2026-07-15 20:05:00.331919+07	TLKM	1502	BID	1562	6
2026-07-15 20:05:00.331919+07	TLKM	1492	BID	1663	7
2026-07-15 20:05:00.331919+07	TLKM	1482	BID	1573	8
2026-07-15 20:05:00.331919+07	TLKM	1472	BID	1407	9
2026-07-15 20:05:00.331919+07	TLKM	1512	ASK	1318	5
2026-07-15 20:05:00.331919+07	TLKM	1522	ASK	1339	6
2026-07-15 20:05:00.331919+07	TLKM	1532	ASK	1571	7
2026-07-15 20:05:00.331919+07	TLKM	1542	ASK	1381	8
2026-07-15 20:05:00.331919+07	TLKM	1552	ASK	1557	9
2026-07-15 20:05:01.340401+07	TLKM	1512	BID	53874	5
2026-07-15 20:05:01.340401+07	TLKM	1502	BID	1439	6
2026-07-15 20:05:01.340401+07	TLKM	1492	BID	1500	7
2026-07-15 20:05:01.340401+07	TLKM	1482	BID	1345	8
2026-07-15 20:05:01.340401+07	TLKM	1472	BID	1608	9
2026-07-15 20:05:01.340401+07	TLKM	1512	ASK	1042	5
2026-07-15 20:05:01.340401+07	TLKM	1522	ASK	1197	6
2026-07-15 20:05:01.340401+07	TLKM	1532	ASK	1432	7
2026-07-15 20:05:01.340401+07	TLKM	1542	ASK	1465	8
2026-07-15 20:05:01.340401+07	TLKM	1552	ASK	1699	9
2026-07-15 20:05:02.348016+07	TLKM	1512	BID	55144	5
2026-07-15 20:05:02.348016+07	TLKM	1502	BID	1272	6
2026-07-15 20:05:02.348016+07	TLKM	1492	BID	1654	7
2026-07-15 20:05:02.348016+07	TLKM	1482	BID	1339	8
2026-07-15 20:05:02.348016+07	TLKM	1472	BID	1641	9
2026-07-15 20:05:02.348016+07	TLKM	1512	ASK	1001	5
2026-07-15 20:05:02.348016+07	TLKM	1522	ASK	1102	6
2026-07-15 20:05:02.348016+07	TLKM	1532	ASK	1674	7
2026-07-15 20:05:02.348016+07	TLKM	1542	ASK	1415	8
2026-07-15 20:05:02.348016+07	TLKM	1552	ASK	1487	9
2026-07-15 20:05:03.354125+07	TLKM	1512	BID	58358	5
2026-07-15 20:05:03.354125+07	TLKM	1502	BID	1301	6
2026-07-15 20:05:03.354125+07	TLKM	1492	BID	1344	7
2026-07-15 20:05:03.354125+07	TLKM	1482	BID	1355	8
2026-07-15 20:05:03.354125+07	TLKM	1472	BID	1864	9
2026-07-15 20:05:03.354125+07	TLKM	1512	ASK	1187	5
2026-07-15 20:05:03.354125+07	TLKM	1522	ASK	1306	6
2026-07-15 20:05:03.354125+07	TLKM	1532	ASK	1228	7
2026-07-15 20:05:03.354125+07	TLKM	1542	ASK	1367	8
2026-07-15 20:05:03.354125+07	TLKM	1552	ASK	1587	9
2026-07-15 20:05:04.363975+07	TLKM	1512	BID	55031	5
2026-07-15 20:05:04.363975+07	TLKM	1502	BID	1532	6
2026-07-15 20:05:04.363975+07	TLKM	1492	BID	1217	7
2026-07-15 20:05:04.363975+07	TLKM	1482	BID	1432	8
2026-07-15 20:05:04.363975+07	TLKM	1472	BID	1424	9
2026-07-15 20:05:04.363975+07	TLKM	1512	ASK	1442	5
2026-07-15 20:05:04.363975+07	TLKM	1522	ASK	1106	6
2026-07-15 20:05:04.363975+07	TLKM	1532	ASK	1394	7
2026-07-15 20:05:04.363975+07	TLKM	1542	ASK	1335	8
2026-07-15 20:05:04.363975+07	TLKM	1552	ASK	1738	9
2026-07-15 20:05:05.369896+07	TLKM	1512	BID	51556	5
2026-07-15 20:05:05.369896+07	TLKM	1502	BID	1122	6
2026-07-15 20:05:05.369896+07	TLKM	1492	BID	1354	7
2026-07-15 20:05:05.369896+07	TLKM	1482	BID	1544	8
2026-07-15 20:05:05.369896+07	TLKM	1472	BID	1408	9
2026-07-15 20:05:05.369896+07	TLKM	1512	ASK	1421	5
2026-07-15 20:05:05.369896+07	TLKM	1522	ASK	1181	6
2026-07-15 20:05:05.369896+07	TLKM	1532	ASK	1387	7
2026-07-15 20:05:05.369896+07	TLKM	1542	ASK	1751	8
2026-07-15 20:05:05.369896+07	TLKM	1552	ASK	1757	9
2026-07-15 20:05:06.380156+07	TLKM	1512	BID	53377	5
2026-07-15 20:05:06.380156+07	TLKM	1502	BID	1552	6
2026-07-15 20:05:06.380156+07	TLKM	1492	BID	1242	7
2026-07-15 20:05:06.380156+07	TLKM	1482	BID	1653	8
2026-07-15 20:05:06.380156+07	TLKM	1472	BID	1497	9
2026-07-15 20:05:06.380156+07	TLKM	1512	ASK	1287	5
2026-07-15 20:05:06.380156+07	TLKM	1522	ASK	1294	6
2026-07-15 20:05:06.380156+07	TLKM	1532	ASK	1448	7
2026-07-15 20:05:06.380156+07	TLKM	1542	ASK	1523	8
2026-07-15 20:05:06.380156+07	TLKM	1552	ASK	1479	9
2026-07-15 20:05:07.385548+07	TLKM	1512	BID	50903	5
2026-07-15 20:05:07.385548+07	TLKM	1502	BID	1484	6
2026-07-15 20:05:07.385548+07	TLKM	1492	BID	1339	7
2026-07-15 20:05:07.385548+07	TLKM	1482	BID	1749	8
2026-07-15 20:05:07.385548+07	TLKM	1472	BID	1859	9
2026-07-15 20:05:07.385548+07	TLKM	1512	ASK	1092	5
2026-07-15 20:05:07.385548+07	TLKM	1522	ASK	1384	6
2026-07-15 20:05:07.385548+07	TLKM	1532	ASK	1645	7
2026-07-15 20:05:07.385548+07	TLKM	1542	ASK	1737	8
2026-07-15 20:05:07.385548+07	TLKM	1552	ASK	1660	9
2026-07-15 20:05:08.396317+07	TLKM	1512	BID	50112	5
2026-07-15 20:05:08.396317+07	TLKM	1502	BID	1301	6
2026-07-15 20:05:08.396317+07	TLKM	1492	BID	1459	7
2026-07-15 20:05:08.396317+07	TLKM	1482	BID	1636	8
2026-07-15 20:05:08.396317+07	TLKM	1472	BID	1621	9
2026-07-15 20:05:08.396317+07	TLKM	1512	ASK	1190	5
2026-07-15 20:05:08.396317+07	TLKM	1522	ASK	1327	6
2026-07-15 20:05:08.396317+07	TLKM	1532	ASK	1408	7
2026-07-15 20:05:08.396317+07	TLKM	1542	ASK	1716	8
2026-07-15 20:05:08.396317+07	TLKM	1552	ASK	1744	9
2026-07-15 20:05:09.401665+07	TLKM	1512	BID	50542	5
2026-07-15 20:05:09.401665+07	TLKM	1502	BID	1505	6
2026-07-15 20:05:09.401665+07	TLKM	1492	BID	1312	7
2026-07-15 20:05:09.401665+07	TLKM	1482	BID	1619	8
2026-07-15 20:05:09.401665+07	TLKM	1472	BID	1428	9
2026-07-15 20:05:09.401665+07	TLKM	1512	ASK	1072	5
2026-07-15 20:05:09.401665+07	TLKM	1522	ASK	1284	6
2026-07-15 20:05:09.401665+07	TLKM	1532	ASK	1693	7
2026-07-15 20:05:09.401665+07	TLKM	1542	ASK	1719	8
2026-07-15 20:05:09.401665+07	TLKM	1552	ASK	1771	9
2026-07-15 20:05:10.412368+07	TLKM	1512	BID	53144	5
2026-07-15 20:05:10.412368+07	TLKM	1502	BID	1180	6
2026-07-15 20:05:10.412368+07	TLKM	1492	BID	1376	7
2026-07-15 20:05:10.412368+07	TLKM	1482	BID	1690	8
2026-07-15 20:05:10.412368+07	TLKM	1472	BID	1522	9
2026-07-15 20:05:10.412368+07	TLKM	1512	ASK	1238	5
2026-07-15 20:05:10.412368+07	TLKM	1522	ASK	1591	6
2026-07-15 20:05:10.412368+07	TLKM	1532	ASK	1241	7
2026-07-15 20:05:10.412368+07	TLKM	1542	ASK	1514	8
2026-07-15 20:05:10.412368+07	TLKM	1552	ASK	1898	9
2026-07-15 20:05:11.418141+07	TLKM	1512	BID	51116	5
2026-07-15 20:05:11.418141+07	TLKM	1502	BID	1107	6
2026-07-15 20:05:11.418141+07	TLKM	1492	BID	1497	7
2026-07-15 20:05:11.418141+07	TLKM	1482	BID	1385	8
2026-07-15 20:05:11.418141+07	TLKM	1472	BID	1612	9
2026-07-15 20:05:11.418141+07	TLKM	1512	ASK	1162	5
2026-07-15 20:05:11.418141+07	TLKM	1522	ASK	1572	6
2026-07-15 20:05:11.418141+07	TLKM	1532	ASK	1204	7
2026-07-15 20:05:11.418141+07	TLKM	1542	ASK	1393	8
2026-07-15 20:05:11.418141+07	TLKM	1552	ASK	1867	9
2026-07-15 20:05:12.428757+07	TLKM	1512	BID	58481	5
2026-07-15 20:05:12.428757+07	TLKM	1502	BID	1464	6
2026-07-15 20:05:12.428757+07	TLKM	1492	BID	1574	7
2026-07-15 20:05:12.428757+07	TLKM	1482	BID	1594	8
2026-07-15 20:05:12.428757+07	TLKM	1472	BID	1890	9
2026-07-15 20:05:12.428757+07	TLKM	1512	ASK	1163	5
2026-07-15 20:05:12.428757+07	TLKM	1522	ASK	1315	6
2026-07-15 20:05:12.428757+07	TLKM	1532	ASK	1476	7
2026-07-15 20:05:12.428757+07	TLKM	1542	ASK	1497	8
2026-07-15 20:05:12.428757+07	TLKM	1552	ASK	1671	9
2026-07-15 20:05:13.434204+07	TLKM	1512	BID	54813	5
2026-07-15 20:05:13.434204+07	TLKM	1502	BID	1310	6
2026-07-15 20:05:13.434204+07	TLKM	1492	BID	1655	7
2026-07-15 20:05:13.434204+07	TLKM	1482	BID	1486	8
2026-07-15 20:05:13.434204+07	TLKM	1472	BID	1839	9
2026-07-15 20:05:13.434204+07	TLKM	1512	ASK	1277	5
2026-07-15 20:05:13.434204+07	TLKM	1522	ASK	1484	6
2026-07-15 20:05:13.434204+07	TLKM	1532	ASK	1397	7
2026-07-15 20:05:13.434204+07	TLKM	1542	ASK	1707	8
2026-07-15 20:05:13.434204+07	TLKM	1552	ASK	1540	9
2026-07-15 20:05:14.443823+07	TLKM	1512	BID	57002	5
2026-07-15 20:05:14.443823+07	TLKM	1502	BID	1135	6
2026-07-15 20:05:14.443823+07	TLKM	1492	BID	1635	7
2026-07-15 20:05:14.443823+07	TLKM	1482	BID	1407	8
2026-07-15 20:05:14.443823+07	TLKM	1472	BID	1413	9
2026-07-15 20:05:14.443823+07	TLKM	1512	ASK	1374	5
2026-07-15 20:05:14.443823+07	TLKM	1522	ASK	1341	6
2026-07-15 20:05:14.443823+07	TLKM	1532	ASK	1391	7
2026-07-15 20:05:14.443823+07	TLKM	1542	ASK	1368	8
2026-07-15 20:05:14.443823+07	TLKM	1552	ASK	1682	9
2026-07-15 20:05:15.450347+07	TLKM	1512	BID	58195	5
2026-07-15 20:05:15.450347+07	TLKM	1502	BID	1416	6
2026-07-15 20:05:15.450347+07	TLKM	1492	BID	1462	7
2026-07-15 20:05:15.450347+07	TLKM	1482	BID	1706	8
2026-07-15 20:05:15.450347+07	TLKM	1472	BID	1430	9
2026-07-15 20:05:15.450347+07	TLKM	1512	ASK	1193	5
2026-07-15 20:05:15.450347+07	TLKM	1522	ASK	1254	6
2026-07-15 20:05:15.450347+07	TLKM	1532	ASK	1468	7
2026-07-15 20:05:15.450347+07	TLKM	1542	ASK	1738	8
2026-07-15 20:05:15.450347+07	TLKM	1552	ASK	1430	9
2026-07-15 20:05:16.460004+07	TLKM	1512	BID	50060	5
2026-07-15 20:05:16.460004+07	TLKM	1502	BID	1214	6
2026-07-15 20:05:16.460004+07	TLKM	1492	BID	1363	7
2026-07-15 20:05:16.460004+07	TLKM	1482	BID	1778	8
2026-07-15 20:05:16.460004+07	TLKM	1472	BID	1574	9
2026-07-15 20:05:16.460004+07	TLKM	1512	ASK	1231	5
2026-07-15 20:05:16.460004+07	TLKM	1522	ASK	1442	6
2026-07-15 20:05:16.460004+07	TLKM	1532	ASK	1362	7
2026-07-15 20:05:16.460004+07	TLKM	1542	ASK	1576	8
2026-07-15 20:05:16.460004+07	TLKM	1552	ASK	1543	9
2026-07-15 20:05:17.467083+07	TLKM	1512	BID	59626	5
2026-07-15 20:05:17.467083+07	TLKM	1502	BID	1144	6
2026-07-15 20:05:17.467083+07	TLKM	1492	BID	1376	7
2026-07-15 20:05:17.467083+07	TLKM	1482	BID	1669	8
2026-07-15 20:05:17.467083+07	TLKM	1472	BID	1883	9
2026-07-15 20:05:17.467083+07	TLKM	1512	ASK	1131	5
2026-07-15 20:05:17.467083+07	TLKM	1522	ASK	1475	6
2026-07-15 20:05:17.467083+07	TLKM	1532	ASK	1660	7
2026-07-15 20:05:17.467083+07	TLKM	1542	ASK	1586	8
2026-07-15 20:05:17.467083+07	TLKM	1552	ASK	1567	9
2026-07-15 20:05:18.475792+07	TLKM	1512	BID	58510	5
2026-07-15 20:05:18.475792+07	TLKM	1502	BID	1339	6
2026-07-15 20:05:18.475792+07	TLKM	1492	BID	1342	7
2026-07-15 20:05:18.475792+07	TLKM	1482	BID	1524	8
2026-07-15 20:05:18.475792+07	TLKM	1472	BID	1409	9
2026-07-15 20:05:18.475792+07	TLKM	1512	ASK	1468	5
2026-07-15 20:05:18.475792+07	TLKM	1522	ASK	1404	6
2026-07-15 20:05:18.475792+07	TLKM	1532	ASK	1294	7
2026-07-15 20:05:18.475792+07	TLKM	1542	ASK	1664	8
2026-07-15 20:05:18.475792+07	TLKM	1552	ASK	1609	9
2026-07-15 20:05:19.483374+07	TLKM	1512	BID	58976	5
2026-07-15 20:05:19.483374+07	TLKM	1502	BID	1215	6
2026-07-15 20:05:19.483374+07	TLKM	1492	BID	1537	7
2026-07-15 20:05:19.483374+07	TLKM	1482	BID	1757	8
2026-07-15 20:05:19.483374+07	TLKM	1472	BID	1536	9
2026-07-15 20:05:19.483374+07	TLKM	1512	ASK	1145	5
2026-07-15 20:05:19.483374+07	TLKM	1522	ASK	1125	6
2026-07-15 20:05:19.483374+07	TLKM	1532	ASK	1363	7
2026-07-15 20:05:19.483374+07	TLKM	1542	ASK	1506	8
2026-07-15 20:05:19.483374+07	TLKM	1552	ASK	1545	9
2026-07-15 20:05:20.492217+07	TLKM	1512	BID	53283	5
2026-07-15 20:05:20.492217+07	TLKM	1502	BID	1356	6
2026-07-15 20:05:20.492217+07	TLKM	1492	BID	1210	7
2026-07-15 20:05:20.492217+07	TLKM	1482	BID	1641	8
2026-07-15 20:05:20.492217+07	TLKM	1472	BID	1882	9
2026-07-15 20:05:20.492217+07	TLKM	1512	ASK	1060	5
2026-07-15 20:05:20.492217+07	TLKM	1522	ASK	1381	6
2026-07-15 20:05:20.492217+07	TLKM	1532	ASK	1259	7
2026-07-15 20:05:20.492217+07	TLKM	1542	ASK	1659	8
2026-07-15 20:05:20.492217+07	TLKM	1552	ASK	1707	9
2026-07-15 20:05:21.499687+07	TLKM	1512	BID	59183	5
2026-07-15 20:05:21.499687+07	TLKM	1502	BID	1568	6
2026-07-15 20:05:21.499687+07	TLKM	1492	BID	1687	7
2026-07-15 20:05:21.499687+07	TLKM	1482	BID	1647	8
2026-07-15 20:05:21.499687+07	TLKM	1472	BID	1460	9
2026-07-15 20:05:21.499687+07	TLKM	1512	ASK	1455	5
2026-07-15 20:05:21.499687+07	TLKM	1522	ASK	1495	6
2026-07-15 20:05:21.499687+07	TLKM	1532	ASK	1321	7
2026-07-15 20:05:21.499687+07	TLKM	1542	ASK	1790	8
2026-07-15 20:05:21.499687+07	TLKM	1552	ASK	1672	9
2026-07-15 20:05:22.507121+07	TLKM	1512	BID	50113	5
2026-07-15 20:05:22.507121+07	TLKM	1502	BID	1160	6
2026-07-15 20:05:22.507121+07	TLKM	1492	BID	1265	7
2026-07-15 20:05:22.507121+07	TLKM	1482	BID	1490	8
2026-07-15 20:05:22.507121+07	TLKM	1472	BID	1449	9
2026-07-15 20:05:22.507121+07	TLKM	1512	ASK	1199	5
2026-07-15 20:05:22.507121+07	TLKM	1522	ASK	1242	6
2026-07-15 20:05:22.507121+07	TLKM	1532	ASK	1470	7
2026-07-15 20:05:22.507121+07	TLKM	1542	ASK	1469	8
2026-07-15 20:05:22.507121+07	TLKM	1552	ASK	1564	9
2026-07-15 20:05:23.516048+07	TLKM	1512	BID	53849	5
2026-07-15 20:05:23.516048+07	TLKM	1502	BID	1475	6
2026-07-15 20:05:23.516048+07	TLKM	1492	BID	1316	7
2026-07-15 20:05:23.516048+07	TLKM	1482	BID	1379	8
2026-07-15 20:05:23.516048+07	TLKM	1472	BID	1660	9
2026-07-15 20:05:23.516048+07	TLKM	1512	ASK	1397	5
2026-07-15 20:05:23.516048+07	TLKM	1522	ASK	1313	6
2026-07-15 20:05:23.516048+07	TLKM	1532	ASK	1423	7
2026-07-15 20:05:23.516048+07	TLKM	1542	ASK	1642	8
2026-07-15 20:05:23.516048+07	TLKM	1552	ASK	1719	9
2026-07-15 20:03:44.969959+07	ASII	3894	BID	1378	5
2026-07-15 20:03:44.969959+07	ASII	3884	BID	1436	6
2026-07-15 20:03:44.969959+07	ASII	3874	BID	1373	7
2026-07-15 20:03:44.969959+07	ASII	3864	BID	1353	8
2026-07-15 20:03:44.969959+07	ASII	3854	BID	1642	9
2026-07-15 20:03:44.969959+07	ASII	3894	ASK	1316	5
2026-07-15 20:03:44.969959+07	ASII	3904	ASK	1550	6
2026-07-15 20:03:44.969959+07	ASII	3914	ASK	1409	7
2026-07-15 20:03:44.969959+07	ASII	3924	ASK	1717	8
2026-07-15 20:03:44.969959+07	ASII	3934	ASK	1516	9
2026-07-15 20:03:45.980991+07	ASII	3894	BID	1111	5
2026-07-15 20:03:45.980991+07	ASII	3884	BID	1481	6
2026-07-15 20:03:45.980991+07	ASII	3874	BID	1468	7
2026-07-15 20:03:45.980991+07	ASII	3864	BID	1480	8
2026-07-15 20:03:45.980991+07	ASII	3854	BID	1797	9
2026-07-15 20:03:45.980991+07	ASII	3894	ASK	1154	5
2026-07-15 20:03:45.980991+07	ASII	3904	ASK	1215	6
2026-07-15 20:03:45.980991+07	ASII	3914	ASK	1407	7
2026-07-15 20:03:45.980991+07	ASII	3924	ASK	1661	8
2026-07-15 20:03:45.980991+07	ASII	3934	ASK	1817	9
2026-07-15 20:03:46.985907+07	ASII	3894	BID	1001	5
2026-07-15 20:03:46.985907+07	ASII	3884	BID	1104	6
2026-07-15 20:03:46.985907+07	ASII	3874	BID	1602	7
2026-07-15 20:03:46.985907+07	ASII	3864	BID	1588	8
2026-07-15 20:03:46.985907+07	ASII	3854	BID	1408	9
2026-07-15 20:03:46.985907+07	ASII	3894	ASK	1422	5
2026-07-15 20:03:46.985907+07	ASII	3904	ASK	1132	6
2026-07-15 20:03:46.985907+07	ASII	3914	ASK	1470	7
2026-07-15 20:03:46.985907+07	ASII	3924	ASK	1656	8
2026-07-15 20:03:46.985907+07	ASII	3934	ASK	1759	9
2026-07-15 20:03:47.99381+07	ASII	3894	BID	1420	5
2026-07-15 20:03:47.99381+07	ASII	3884	BID	1465	6
2026-07-15 20:03:47.99381+07	ASII	3874	BID	1295	7
2026-07-15 20:03:47.99381+07	ASII	3864	BID	1493	8
2026-07-15 20:03:47.99381+07	ASII	3854	BID	1462	9
2026-07-15 20:03:47.99381+07	ASII	3894	ASK	1119	5
2026-07-15 20:03:47.99381+07	ASII	3904	ASK	1136	6
2026-07-15 20:03:47.99381+07	ASII	3914	ASK	1300	7
2026-07-15 20:03:47.99381+07	ASII	3924	ASK	1709	8
2026-07-15 20:03:47.99381+07	ASII	3934	ASK	1800	9
2026-07-15 20:03:49.000767+07	ASII	3894	BID	1108	5
2026-07-15 20:03:49.000767+07	ASII	3884	BID	1209	6
2026-07-15 20:03:49.000767+07	ASII	3874	BID	1335	7
2026-07-15 20:03:49.000767+07	ASII	3864	BID	1425	8
2026-07-15 20:03:49.000767+07	ASII	3854	BID	1492	9
2026-07-15 20:03:49.000767+07	ASII	3894	ASK	1200	5
2026-07-15 20:03:49.000767+07	ASII	3904	ASK	1440	6
2026-07-15 20:03:49.000767+07	ASII	3914	ASK	1378	7
2026-07-15 20:03:49.000767+07	ASII	3924	ASK	1527	8
2026-07-15 20:03:49.000767+07	ASII	3934	ASK	1772	9
2026-07-15 20:03:50.004846+07	ASII	3894	BID	1146	5
2026-07-15 20:03:50.004846+07	ASII	3884	BID	1574	6
2026-07-15 20:03:50.004846+07	ASII	3874	BID	1393	7
2026-07-15 20:03:50.004846+07	ASII	3864	BID	1541	8
2026-07-15 20:03:50.004846+07	ASII	3854	BID	1457	9
2026-07-15 20:03:50.004846+07	ASII	3894	ASK	1102	5
2026-07-15 20:03:50.004846+07	ASII	3904	ASK	1540	6
2026-07-15 20:03:50.004846+07	ASII	3914	ASK	1617	7
2026-07-15 20:03:50.004846+07	ASII	3924	ASK	1580	8
2026-07-15 20:03:50.004846+07	ASII	3934	ASK	1633	9
2026-07-15 20:03:51.015895+07	ASII	3894	BID	1402	5
2026-07-15 20:03:51.015895+07	ASII	3884	BID	1507	6
2026-07-15 20:03:51.015895+07	ASII	3874	BID	1630	7
2026-07-15 20:03:51.015895+07	ASII	3864	BID	1643	8
2026-07-15 20:03:51.015895+07	ASII	3854	BID	1870	9
2026-07-15 20:03:51.015895+07	ASII	3894	ASK	1051	5
2026-07-15 20:03:51.015895+07	ASII	3904	ASK	1381	6
2026-07-15 20:03:51.015895+07	ASII	3914	ASK	1645	7
2026-07-15 20:03:51.015895+07	ASII	3924	ASK	1616	8
2026-07-15 20:03:51.015895+07	ASII	3934	ASK	1456	9
2026-07-15 20:03:52.020231+07	ASII	3894	BID	1129	5
2026-07-15 20:03:52.020231+07	ASII	3884	BID	1182	6
2026-07-15 20:03:52.020231+07	ASII	3874	BID	1679	7
2026-07-15 20:03:52.020231+07	ASII	3864	BID	1321	8
2026-07-15 20:03:52.020231+07	ASII	3854	BID	1724	9
2026-07-15 20:03:52.020231+07	ASII	3894	ASK	1415	5
2026-07-15 20:03:52.020231+07	ASII	3904	ASK	1592	6
2026-07-15 20:03:52.020231+07	ASII	3914	ASK	1384	7
2026-07-15 20:03:52.020231+07	ASII	3924	ASK	1685	8
2026-07-15 20:03:52.020231+07	ASII	3934	ASK	1652	9
2026-07-15 20:03:53.028071+07	ASII	3894	BID	1334	5
2026-07-15 20:03:53.028071+07	ASII	3884	BID	1205	6
2026-07-15 20:03:53.028071+07	ASII	3874	BID	1574	7
2026-07-15 20:03:53.028071+07	ASII	3864	BID	1721	8
2026-07-15 20:03:53.028071+07	ASII	3854	BID	1420	9
2026-07-15 20:03:53.028071+07	ASII	3894	ASK	1142	5
2026-07-15 20:03:53.028071+07	ASII	3904	ASK	1328	6
2026-07-15 20:03:53.028071+07	ASII	3914	ASK	1651	7
2026-07-15 20:03:53.028071+07	ASII	3924	ASK	1795	8
2026-07-15 20:03:53.028071+07	ASII	3934	ASK	1759	9
2026-07-15 20:03:54.035346+07	ASII	3894	BID	1365	5
2026-07-15 20:03:54.035346+07	ASII	3884	BID	1461	6
2026-07-15 20:03:54.035346+07	ASII	3874	BID	1345	7
2026-07-15 20:03:54.035346+07	ASII	3864	BID	1745	8
2026-07-15 20:03:54.035346+07	ASII	3854	BID	1476	9
2026-07-15 20:03:54.035346+07	ASII	3894	ASK	1427	5
2026-07-15 20:03:54.035346+07	ASII	3904	ASK	1250	6
2026-07-15 20:03:54.035346+07	ASII	3914	ASK	1550	7
2026-07-15 20:03:54.035346+07	ASII	3924	ASK	1615	8
2026-07-15 20:03:54.035346+07	ASII	3934	ASK	1467	9
2026-07-15 20:03:55.040115+07	ASII	3894	BID	1154	5
2026-07-15 20:03:55.040115+07	ASII	3884	BID	1558	6
2026-07-15 20:03:55.040115+07	ASII	3874	BID	1664	7
2026-07-15 20:03:55.040115+07	ASII	3864	BID	1359	8
2026-07-15 20:03:55.040115+07	ASII	3854	BID	1727	9
2026-07-15 20:03:55.040115+07	ASII	3894	ASK	1293	5
2026-07-15 20:03:55.040115+07	ASII	3904	ASK	1265	6
2026-07-15 20:03:55.040115+07	ASII	3914	ASK	1264	7
2026-07-15 20:03:55.040115+07	ASII	3924	ASK	1459	8
2026-07-15 20:03:55.040115+07	ASII	3934	ASK	1854	9
2026-07-15 20:03:56.049948+07	ASII	3894	BID	1454	5
2026-07-15 20:03:56.049948+07	ASII	3884	BID	1283	6
2026-07-15 20:03:56.049948+07	ASII	3874	BID	1354	7
2026-07-15 20:03:56.049948+07	ASII	3864	BID	1697	8
2026-07-15 20:03:56.049948+07	ASII	3854	BID	1635	9
2026-07-15 20:03:56.049948+07	ASII	3894	ASK	1361	5
2026-07-15 20:03:56.049948+07	ASII	3904	ASK	1537	6
2026-07-15 20:03:56.049948+07	ASII	3914	ASK	1564	7
2026-07-15 20:03:56.049948+07	ASII	3924	ASK	1530	8
2026-07-15 20:03:56.049948+07	ASII	3934	ASK	1657	9
2026-07-15 20:03:57.054577+07	ASII	3894	BID	1409	5
2026-07-15 20:03:57.054577+07	ASII	3884	BID	1560	6
2026-07-15 20:03:57.054577+07	ASII	3874	BID	1543	7
2026-07-15 20:03:57.054577+07	ASII	3864	BID	1722	8
2026-07-15 20:03:57.054577+07	ASII	3854	BID	1407	9
2026-07-15 20:03:57.054577+07	ASII	3894	ASK	1486	5
2026-07-15 20:03:57.054577+07	ASII	3904	ASK	1322	6
2026-07-15 20:03:57.054577+07	ASII	3914	ASK	1428	7
2026-07-15 20:03:57.054577+07	ASII	3924	ASK	1421	8
2026-07-15 20:03:57.054577+07	ASII	3934	ASK	1513	9
2026-07-15 20:03:58.064915+07	ASII	3894	BID	1413	5
2026-07-15 20:03:58.064915+07	ASII	3884	BID	1492	6
2026-07-15 20:03:58.064915+07	ASII	3874	BID	1577	7
2026-07-15 20:03:58.064915+07	ASII	3864	BID	1332	8
2026-07-15 20:03:58.064915+07	ASII	3854	BID	1696	9
2026-07-15 20:03:58.064915+07	ASII	3894	ASK	1422	5
2026-07-15 20:03:58.064915+07	ASII	3904	ASK	1589	6
2026-07-15 20:03:58.064915+07	ASII	3914	ASK	1511	7
2026-07-15 20:03:58.064915+07	ASII	3924	ASK	1533	8
2026-07-15 20:03:58.064915+07	ASII	3934	ASK	1653	9
2026-07-15 20:03:59.069781+07	ASII	3894	BID	1292	5
2026-07-15 20:03:59.069781+07	ASII	3884	BID	1582	6
2026-07-15 20:03:59.069781+07	ASII	3874	BID	1417	7
2026-07-15 20:03:59.069781+07	ASII	3864	BID	1599	8
2026-07-15 20:03:59.069781+07	ASII	3854	BID	1688	9
2026-07-15 20:03:59.069781+07	ASII	3894	ASK	1031	5
2026-07-15 20:03:59.069781+07	ASII	3904	ASK	1264	6
2026-07-15 20:03:59.069781+07	ASII	3914	ASK	1596	7
2026-07-15 20:03:59.069781+07	ASII	3924	ASK	1461	8
2026-07-15 20:03:59.069781+07	ASII	3934	ASK	1449	9
2026-07-15 20:04:00.078021+07	ASII	3894	BID	1378	5
2026-07-15 20:04:00.078021+07	ASII	3884	BID	1574	6
2026-07-15 20:04:00.078021+07	ASII	3874	BID	1694	7
2026-07-15 20:04:00.078021+07	ASII	3864	BID	1377	8
2026-07-15 20:04:00.078021+07	ASII	3854	BID	1839	9
2026-07-15 20:04:00.078021+07	ASII	3894	ASK	1229	5
2026-07-15 20:04:00.078021+07	ASII	3904	ASK	1262	6
2026-07-15 20:04:00.078021+07	ASII	3914	ASK	1204	7
2026-07-15 20:04:00.078021+07	ASII	3924	ASK	1360	8
2026-07-15 20:04:00.078021+07	ASII	3934	ASK	1492	9
2026-07-15 20:04:01.08681+07	ASII	3894	BID	1061	5
2026-07-15 20:04:01.08681+07	ASII	3884	BID	1338	6
2026-07-15 20:04:01.08681+07	ASII	3874	BID	1489	7
2026-07-15 20:04:01.08681+07	ASII	3864	BID	1478	8
2026-07-15 20:04:01.08681+07	ASII	3854	BID	1619	9
2026-07-15 20:04:01.08681+07	ASII	3894	ASK	1130	5
2026-07-15 20:04:01.08681+07	ASII	3904	ASK	1478	6
2026-07-15 20:04:01.08681+07	ASII	3914	ASK	1436	7
2026-07-15 20:04:01.08681+07	ASII	3924	ASK	1352	8
2026-07-15 20:04:01.08681+07	ASII	3934	ASK	1799	9
2026-07-15 20:04:02.095795+07	ASII	3894	BID	1405	5
2026-07-15 20:04:02.095795+07	ASII	3884	BID	1314	6
2026-07-15 20:04:02.095795+07	ASII	3874	BID	1495	7
2026-07-15 20:04:02.095795+07	ASII	3864	BID	1388	8
2026-07-15 20:04:02.095795+07	ASII	3854	BID	1678	9
2026-07-15 20:04:02.095795+07	ASII	3894	ASK	1101	5
2026-07-15 20:04:02.095795+07	ASII	3904	ASK	1377	6
2026-07-15 20:04:02.095795+07	ASII	3914	ASK	1204	7
2026-07-15 20:04:02.095795+07	ASII	3924	ASK	1412	8
2026-07-15 20:04:02.095795+07	ASII	3934	ASK	1640	9
2026-07-15 20:04:03.105036+07	ASII	3894	BID	1378	5
2026-07-15 20:04:03.105036+07	ASII	3884	BID	1474	6
2026-07-15 20:04:03.105036+07	ASII	3874	BID	1341	7
2026-07-15 20:04:03.105036+07	ASII	3864	BID	1359	8
2026-07-15 20:04:03.105036+07	ASII	3854	BID	1589	9
2026-07-15 20:04:03.105036+07	ASII	3894	ASK	1382	5
2026-07-15 20:04:03.105036+07	ASII	3904	ASK	1592	6
2026-07-15 20:04:03.105036+07	ASII	3914	ASK	1211	7
2026-07-15 20:04:03.105036+07	ASII	3924	ASK	1796	8
2026-07-15 20:04:03.105036+07	ASII	3934	ASK	1693	9
2026-07-15 20:04:04.116447+07	ASII	3894	BID	1214	5
2026-07-15 20:04:04.116447+07	ASII	3884	BID	1558	6
2026-07-15 20:04:04.116447+07	ASII	3874	BID	1211	7
2026-07-15 20:04:04.116447+07	ASII	3864	BID	1559	8
2026-07-15 20:04:04.116447+07	ASII	3854	BID	1552	9
2026-07-15 20:04:04.116447+07	ASII	3894	ASK	1225	5
2026-07-15 20:04:04.116447+07	ASII	3904	ASK	1328	6
2026-07-15 20:04:04.116447+07	ASII	3914	ASK	1290	7
2026-07-15 20:04:04.116447+07	ASII	3924	ASK	1654	8
2026-07-15 20:04:04.116447+07	ASII	3934	ASK	1770	9
2026-07-15 20:04:05.122474+07	ASII	3894	BID	1167	5
2026-07-15 20:04:05.122474+07	ASII	3884	BID	1355	6
2026-07-15 20:04:05.122474+07	ASII	3874	BID	1436	7
2026-07-15 20:04:05.122474+07	ASII	3864	BID	1608	8
2026-07-15 20:04:05.122474+07	ASII	3854	BID	1633	9
2026-07-15 20:04:05.122474+07	ASII	3894	ASK	1256	5
2026-07-15 20:04:05.122474+07	ASII	3904	ASK	1367	6
2026-07-15 20:04:05.122474+07	ASII	3914	ASK	1277	7
2026-07-15 20:04:05.122474+07	ASII	3924	ASK	1345	8
2026-07-15 20:04:05.122474+07	ASII	3934	ASK	1642	9
2026-07-15 20:04:06.133201+07	ASII	3894	BID	1420	5
2026-07-15 20:04:06.133201+07	ASII	3884	BID	1214	6
2026-07-15 20:04:06.133201+07	ASII	3874	BID	1360	7
2026-07-15 20:04:06.133201+07	ASII	3864	BID	1705	8
2026-07-15 20:04:06.133201+07	ASII	3854	BID	1690	9
2026-07-15 20:04:06.133201+07	ASII	3894	ASK	1039	5
2026-07-15 20:04:06.133201+07	ASII	3904	ASK	1294	6
2026-07-15 20:04:06.133201+07	ASII	3914	ASK	1500	7
2026-07-15 20:04:06.133201+07	ASII	3924	ASK	1479	8
2026-07-15 20:04:06.133201+07	ASII	3934	ASK	1541	9
2026-07-15 20:04:07.138414+07	ASII	3894	BID	1498	5
2026-07-15 20:04:07.138414+07	ASII	3884	BID	1148	6
2026-07-15 20:04:07.138414+07	ASII	3874	BID	1622	7
2026-07-15 20:04:07.138414+07	ASII	3864	BID	1707	8
2026-07-15 20:04:07.138414+07	ASII	3854	BID	1474	9
2026-07-15 20:04:07.138414+07	ASII	3894	ASK	1431	5
2026-07-15 20:04:07.138414+07	ASII	3904	ASK	1475	6
2026-07-15 20:04:07.138414+07	ASII	3914	ASK	1438	7
2026-07-15 20:04:07.138414+07	ASII	3924	ASK	1757	8
2026-07-15 20:04:07.138414+07	ASII	3934	ASK	1872	9
2026-07-15 20:04:08.148861+07	ASII	3894	BID	1008	5
2026-07-15 20:04:08.148861+07	ASII	3884	BID	1447	6
2026-07-15 20:04:08.148861+07	ASII	3874	BID	1250	7
2026-07-15 20:04:08.148861+07	ASII	3864	BID	1567	8
2026-07-15 20:04:08.148861+07	ASII	3854	BID	1496	9
2026-07-15 20:04:08.148861+07	ASII	3894	ASK	1196	5
2026-07-15 20:04:08.148861+07	ASII	3904	ASK	1295	6
2026-07-15 20:04:08.148861+07	ASII	3914	ASK	1607	7
2026-07-15 20:04:08.148861+07	ASII	3924	ASK	1424	8
2026-07-15 20:04:08.148861+07	ASII	3934	ASK	1476	9
2026-07-15 20:04:09.154215+07	ASII	3894	BID	1355	5
2026-07-15 20:04:09.154215+07	ASII	3884	BID	1154	6
2026-07-15 20:04:09.154215+07	ASII	3874	BID	1596	7
2026-07-15 20:04:09.154215+07	ASII	3864	BID	1687	8
2026-07-15 20:04:09.154215+07	ASII	3854	BID	1442	9
2026-07-15 20:04:09.154215+07	ASII	3894	ASK	1056	5
2026-07-15 20:04:09.154215+07	ASII	3904	ASK	1546	6
2026-07-15 20:04:09.154215+07	ASII	3914	ASK	1293	7
2026-07-15 20:04:09.154215+07	ASII	3924	ASK	1428	8
2026-07-15 20:04:09.154215+07	ASII	3934	ASK	1826	9
2026-07-15 20:04:10.165045+07	ASII	3894	BID	1229	5
2026-07-15 20:04:10.165045+07	ASII	3884	BID	1394	6
2026-07-15 20:04:10.165045+07	ASII	3874	BID	1575	7
2026-07-15 20:04:10.165045+07	ASII	3864	BID	1546	8
2026-07-15 20:04:10.165045+07	ASII	3854	BID	1729	9
2026-07-15 20:04:10.165045+07	ASII	3894	ASK	1368	5
2026-07-15 20:04:10.165045+07	ASII	3904	ASK	1158	6
2026-07-15 20:04:10.165045+07	ASII	3914	ASK	1488	7
2026-07-15 20:04:10.165045+07	ASII	3924	ASK	1469	8
2026-07-15 20:04:10.165045+07	ASII	3934	ASK	1637	9
2026-07-15 20:04:11.170768+07	ASII	3894	BID	1302	5
2026-07-15 20:04:11.170768+07	ASII	3884	BID	1567	6
2026-07-15 20:04:11.170768+07	ASII	3874	BID	1244	7
2026-07-15 20:04:11.170768+07	ASII	3864	BID	1534	8
2026-07-15 20:04:11.170768+07	ASII	3854	BID	1873	9
2026-07-15 20:04:11.170768+07	ASII	3894	ASK	1245	5
2026-07-15 20:04:11.170768+07	ASII	3904	ASK	1106	6
2026-07-15 20:04:11.170768+07	ASII	3914	ASK	1689	7
2026-07-15 20:04:11.170768+07	ASII	3924	ASK	1486	8
2026-07-15 20:04:11.170768+07	ASII	3934	ASK	1624	9
2026-07-15 20:04:12.181149+07	ASII	3894	BID	1220	5
2026-07-15 20:04:12.181149+07	ASII	3884	BID	1354	6
2026-07-15 20:04:12.181149+07	ASII	3874	BID	1538	7
2026-07-15 20:04:12.181149+07	ASII	3864	BID	1529	8
2026-07-15 20:04:12.181149+07	ASII	3854	BID	1528	9
2026-07-15 20:04:12.181149+07	ASII	3894	ASK	1423	5
2026-07-15 20:04:12.181149+07	ASII	3904	ASK	1413	6
2026-07-15 20:04:12.181149+07	ASII	3914	ASK	1417	7
2026-07-15 20:04:12.181149+07	ASII	3924	ASK	1515	8
2026-07-15 20:04:12.181149+07	ASII	3934	ASK	1438	9
2026-07-15 20:04:13.187045+07	ASII	3894	BID	1003	5
2026-07-15 20:04:13.187045+07	ASII	3884	BID	1542	6
2026-07-15 20:04:13.187045+07	ASII	3874	BID	1212	7
2026-07-15 20:04:13.187045+07	ASII	3864	BID	1554	8
2026-07-15 20:04:13.187045+07	ASII	3854	BID	1726	9
2026-07-15 20:04:13.187045+07	ASII	3894	ASK	1264	5
2026-07-15 20:04:13.187045+07	ASII	3904	ASK	1190	6
2026-07-15 20:04:13.187045+07	ASII	3914	ASK	1354	7
2026-07-15 20:04:13.187045+07	ASII	3924	ASK	1740	8
2026-07-15 20:04:13.187045+07	ASII	3934	ASK	1817	9
2026-07-15 20:04:14.196564+07	ASII	3894	BID	1453	5
2026-07-15 20:04:14.196564+07	ASII	3884	BID	1144	6
2026-07-15 20:04:14.196564+07	ASII	3874	BID	1374	7
2026-07-15 20:04:14.196564+07	ASII	3864	BID	1637	8
2026-07-15 20:04:14.196564+07	ASII	3854	BID	1403	9
2026-07-15 20:04:14.196564+07	ASII	3894	ASK	1386	5
2026-07-15 20:04:14.196564+07	ASII	3904	ASK	1579	6
2026-07-15 20:04:14.196564+07	ASII	3914	ASK	1458	7
2026-07-15 20:04:14.196564+07	ASII	3924	ASK	1664	8
2026-07-15 20:04:14.196564+07	ASII	3934	ASK	1659	9
2026-07-15 20:04:15.203651+07	ASII	3894	BID	1143	5
2026-07-15 20:04:15.203651+07	ASII	3884	BID	1380	6
2026-07-15 20:04:15.203651+07	ASII	3874	BID	1426	7
2026-07-15 20:04:15.203651+07	ASII	3864	BID	1476	8
2026-07-15 20:04:15.203651+07	ASII	3854	BID	1656	9
2026-07-15 20:04:15.203651+07	ASII	3894	ASK	1263	5
2026-07-15 20:04:15.203651+07	ASII	3904	ASK	1322	6
2026-07-15 20:04:15.203651+07	ASII	3914	ASK	1242	7
2026-07-15 20:04:15.203651+07	ASII	3924	ASK	1596	8
2026-07-15 20:04:15.203651+07	ASII	3934	ASK	1633	9
2026-07-15 20:04:16.21226+07	ASII	3894	BID	1231	5
2026-07-15 20:04:16.21226+07	ASII	3884	BID	1508	6
2026-07-15 20:04:16.21226+07	ASII	3874	BID	1574	7
2026-07-15 20:04:16.21226+07	ASII	3864	BID	1438	8
2026-07-15 20:04:16.21226+07	ASII	3854	BID	1533	9
2026-07-15 20:04:16.21226+07	ASII	3894	ASK	1111	5
2026-07-15 20:04:16.21226+07	ASII	3904	ASK	1584	6
2026-07-15 20:04:16.21226+07	ASII	3914	ASK	1453	7
2026-07-15 20:04:16.21226+07	ASII	3924	ASK	1344	8
2026-07-15 20:04:16.21226+07	ASII	3934	ASK	1481	9
2026-07-15 20:04:17.220067+07	ASII	3894	BID	1458	5
2026-07-15 20:04:17.220067+07	ASII	3884	BID	1446	6
2026-07-15 20:04:17.220067+07	ASII	3874	BID	1293	7
2026-07-15 20:04:17.220067+07	ASII	3864	BID	1799	8
2026-07-15 20:04:17.220067+07	ASII	3854	BID	1641	9
2026-07-15 20:04:17.220067+07	ASII	3894	ASK	1061	5
2026-07-15 20:04:17.220067+07	ASII	3904	ASK	1133	6
2026-07-15 20:04:17.220067+07	ASII	3914	ASK	1265	7
2026-07-15 20:04:17.220067+07	ASII	3924	ASK	1783	8
2026-07-15 20:04:17.220067+07	ASII	3934	ASK	1740	9
2026-07-15 20:04:18.22683+07	ASII	3894	BID	1474	5
2026-07-15 20:04:18.22683+07	ASII	3884	BID	1329	6
2026-07-15 20:04:18.22683+07	ASII	3874	BID	1662	7
2026-07-15 20:04:18.22683+07	ASII	3864	BID	1423	8
2026-07-15 20:04:18.22683+07	ASII	3854	BID	1424	9
2026-07-15 20:04:18.22683+07	ASII	3894	ASK	1401	5
2026-07-15 20:04:18.22683+07	ASII	3904	ASK	1573	6
2026-07-15 20:04:18.22683+07	ASII	3914	ASK	1370	7
2026-07-15 20:04:18.22683+07	ASII	3924	ASK	1391	8
2026-07-15 20:04:18.22683+07	ASII	3934	ASK	1469	9
2026-07-15 20:04:19.236815+07	ASII	3894	BID	1310	5
2026-07-15 20:04:19.236815+07	ASII	3884	BID	1461	6
2026-07-15 20:04:19.236815+07	ASII	3874	BID	1686	7
2026-07-15 20:04:19.236815+07	ASII	3864	BID	1403	8
2026-07-15 20:04:19.236815+07	ASII	3854	BID	1551	9
2026-07-15 20:04:19.236815+07	ASII	3894	ASK	1135	5
2026-07-15 20:04:19.236815+07	ASII	3904	ASK	1385	6
2026-07-15 20:04:19.236815+07	ASII	3914	ASK	1403	7
2026-07-15 20:04:19.236815+07	ASII	3924	ASK	1712	8
2026-07-15 20:04:19.236815+07	ASII	3934	ASK	1720	9
2026-07-15 20:04:20.245383+07	ASII	3894	BID	1484	5
2026-07-15 20:04:20.245383+07	ASII	3884	BID	1524	6
2026-07-15 20:04:20.245383+07	ASII	3874	BID	1542	7
2026-07-15 20:04:20.245383+07	ASII	3864	BID	1774	8
2026-07-15 20:04:20.245383+07	ASII	3854	BID	1669	9
2026-07-15 20:04:20.245383+07	ASII	3894	ASK	1466	5
2026-07-15 20:04:20.245383+07	ASII	3904	ASK	1225	6
2026-07-15 20:04:20.245383+07	ASII	3914	ASK	1483	7
2026-07-15 20:04:20.245383+07	ASII	3924	ASK	1751	8
2026-07-15 20:04:20.245383+07	ASII	3934	ASK	1868	9
2026-07-15 20:04:21.253639+07	ASII	3894	BID	1202	5
2026-07-15 20:04:21.253639+07	ASII	3884	BID	1557	6
2026-07-15 20:04:21.253639+07	ASII	3874	BID	1634	7
2026-07-15 20:04:21.253639+07	ASII	3864	BID	1446	8
2026-07-15 20:04:21.253639+07	ASII	3854	BID	1586	9
2026-07-15 20:04:21.253639+07	ASII	3894	ASK	1206	5
2026-07-15 20:04:21.253639+07	ASII	3904	ASK	1377	6
2026-07-15 20:04:21.253639+07	ASII	3914	ASK	1597	7
2026-07-15 20:04:21.253639+07	ASII	3924	ASK	1443	8
2026-07-15 20:04:21.253639+07	ASII	3934	ASK	1446	9
2026-07-15 20:04:22.262452+07	ASII	3894	BID	1248	5
2026-07-15 20:04:22.262452+07	ASII	3884	BID	1254	6
2026-07-15 20:04:22.262452+07	ASII	3874	BID	1680	7
2026-07-15 20:04:22.262452+07	ASII	3864	BID	1644	8
2026-07-15 20:04:22.262452+07	ASII	3854	BID	1861	9
2026-07-15 20:04:22.262452+07	ASII	3894	ASK	1204	5
2026-07-15 20:04:22.262452+07	ASII	3904	ASK	1142	6
2026-07-15 20:04:22.262452+07	ASII	3914	ASK	1645	7
2026-07-15 20:04:22.262452+07	ASII	3924	ASK	1358	8
2026-07-15 20:04:22.262452+07	ASII	3934	ASK	1847	9
2026-07-15 20:04:23.27079+07	ASII	3894	BID	1478	5
2026-07-15 20:04:23.27079+07	ASII	3884	BID	1486	6
2026-07-15 20:04:23.27079+07	ASII	3874	BID	1207	7
2026-07-15 20:04:23.27079+07	ASII	3864	BID	1300	8
2026-07-15 20:04:23.27079+07	ASII	3854	BID	1729	9
2026-07-15 20:04:23.27079+07	ASII	3894	ASK	1003	5
2026-07-15 20:04:23.27079+07	ASII	3904	ASK	1309	6
2026-07-15 20:04:23.27079+07	ASII	3914	ASK	1559	7
2026-07-15 20:04:23.27079+07	ASII	3924	ASK	1775	8
2026-07-15 20:04:23.27079+07	ASII	3934	ASK	1541	9
2026-07-15 20:04:24.278562+07	ASII	3894	BID	1417	5
2026-07-15 20:04:24.278562+07	ASII	3884	BID	1314	6
2026-07-15 20:04:24.278562+07	ASII	3874	BID	1656	7
2026-07-15 20:04:24.278562+07	ASII	3864	BID	1742	8
2026-07-15 20:04:24.278562+07	ASII	3854	BID	1819	9
2026-07-15 20:04:24.278562+07	ASII	3894	ASK	1387	5
2026-07-15 20:04:24.278562+07	ASII	3904	ASK	1512	6
2026-07-15 20:04:24.278562+07	ASII	3914	ASK	1349	7
2026-07-15 20:04:24.278562+07	ASII	3924	ASK	1634	8
2026-07-15 20:04:24.278562+07	ASII	3934	ASK	1666	9
2026-07-15 20:04:25.287536+07	ASII	3894	BID	1274	5
2026-07-15 20:04:25.287536+07	ASII	3884	BID	1236	6
2026-07-15 20:04:25.287536+07	ASII	3874	BID	1567	7
2026-07-15 20:04:25.287536+07	ASII	3864	BID	1468	8
2026-07-15 20:04:25.287536+07	ASII	3854	BID	1659	9
2026-07-15 20:04:25.287536+07	ASII	3894	ASK	1160	5
2026-07-15 20:04:25.287536+07	ASII	3904	ASK	1124	6
2026-07-15 20:04:25.287536+07	ASII	3914	ASK	1631	7
2026-07-15 20:04:25.287536+07	ASII	3924	ASK	1796	8
2026-07-15 20:04:25.287536+07	ASII	3934	ASK	1732	9
2026-07-15 20:04:26.295893+07	ASII	3894	BID	1011	5
2026-07-15 20:04:26.295893+07	ASII	3884	BID	1594	6
2026-07-15 20:04:26.295893+07	ASII	3874	BID	1249	7
2026-07-15 20:04:26.295893+07	ASII	3864	BID	1653	8
2026-07-15 20:04:26.295893+07	ASII	3854	BID	1438	9
2026-07-15 20:04:26.295893+07	ASII	3894	ASK	1065	5
2026-07-15 20:04:26.295893+07	ASII	3904	ASK	1115	6
2026-07-15 20:04:26.295893+07	ASII	3914	ASK	1586	7
2026-07-15 20:04:26.295893+07	ASII	3924	ASK	1587	8
2026-07-15 20:04:26.295893+07	ASII	3934	ASK	1626	9
2026-07-15 20:04:27.302831+07	ASII	3894	BID	1362	5
2026-07-15 20:04:27.302831+07	ASII	3884	BID	1151	6
2026-07-15 20:04:27.302831+07	ASII	3874	BID	1421	7
2026-07-15 20:04:27.302831+07	ASII	3864	BID	1634	8
2026-07-15 20:04:27.302831+07	ASII	3854	BID	1830	9
2026-07-15 20:04:27.302831+07	ASII	3894	ASK	1174	5
2026-07-15 20:04:27.302831+07	ASII	3904	ASK	1224	6
2026-07-15 20:04:27.302831+07	ASII	3914	ASK	1615	7
2026-07-15 20:04:27.302831+07	ASII	3924	ASK	1609	8
2026-07-15 20:04:27.302831+07	ASII	3934	ASK	1675	9
2026-07-15 20:04:28.312891+07	ASII	3894	BID	1019	5
2026-07-15 20:04:28.312891+07	ASII	3884	BID	1420	6
2026-07-15 20:04:28.312891+07	ASII	3874	BID	1208	7
2026-07-15 20:04:28.312891+07	ASII	3864	BID	1719	8
2026-07-15 20:04:28.312891+07	ASII	3854	BID	1634	9
2026-07-15 20:04:28.312891+07	ASII	3894	ASK	1045	5
2026-07-15 20:04:28.312891+07	ASII	3904	ASK	1597	6
2026-07-15 20:04:28.312891+07	ASII	3914	ASK	1447	7
2026-07-15 20:04:28.312891+07	ASII	3924	ASK	1647	8
2026-07-15 20:04:28.312891+07	ASII	3934	ASK	1802	9
2026-07-15 20:04:29.323627+07	ASII	3894	BID	1203	5
2026-07-15 20:04:29.323627+07	ASII	3884	BID	1159	6
2026-07-15 20:04:29.323627+07	ASII	3874	BID	1363	7
2026-07-15 20:04:29.323627+07	ASII	3864	BID	1466	8
2026-07-15 20:04:29.323627+07	ASII	3854	BID	1838	9
2026-07-15 20:04:29.323627+07	ASII	3894	ASK	1101	5
2026-07-15 20:04:29.323627+07	ASII	3904	ASK	1481	6
2026-07-15 20:04:29.323627+07	ASII	3914	ASK	1397	7
2026-07-15 20:04:29.323627+07	ASII	3924	ASK	1488	8
2026-07-15 20:04:29.323627+07	ASII	3934	ASK	1484	9
2026-07-15 20:04:30.333183+07	ASII	3894	BID	1488	5
2026-07-15 20:04:30.333183+07	ASII	3884	BID	1437	6
2026-07-15 20:04:30.333183+07	ASII	3874	BID	1669	7
2026-07-15 20:04:30.333183+07	ASII	3864	BID	1569	8
2026-07-15 20:04:30.333183+07	ASII	3854	BID	1456	9
2026-07-15 20:04:30.333183+07	ASII	3894	ASK	1086	5
2026-07-15 20:04:30.333183+07	ASII	3904	ASK	1165	6
2026-07-15 20:04:30.333183+07	ASII	3914	ASK	1329	7
2026-07-15 20:04:30.333183+07	ASII	3924	ASK	1677	8
2026-07-15 20:04:30.333183+07	ASII	3934	ASK	1499	9
2026-07-15 20:04:31.339871+07	ASII	3894	BID	1086	5
2026-07-15 20:04:31.339871+07	ASII	3884	BID	1273	6
2026-07-15 20:04:31.339871+07	ASII	3874	BID	1252	7
2026-07-15 20:04:31.339871+07	ASII	3864	BID	1346	8
2026-07-15 20:04:31.339871+07	ASII	3854	BID	1832	9
2026-07-15 20:04:31.339871+07	ASII	3894	ASK	1268	5
2026-07-15 20:04:31.339871+07	ASII	3904	ASK	1307	6
2026-07-15 20:04:31.339871+07	ASII	3914	ASK	1374	7
2026-07-15 20:04:31.339871+07	ASII	3924	ASK	1681	8
2026-07-15 20:04:31.339871+07	ASII	3934	ASK	1552	9
2026-07-15 20:04:32.350269+07	ASII	3894	BID	1204	5
2026-07-15 20:04:32.350269+07	ASII	3884	BID	1563	6
2026-07-15 20:04:32.350269+07	ASII	3874	BID	1529	7
2026-07-15 20:04:32.350269+07	ASII	3864	BID	1452	8
2026-07-15 20:04:32.350269+07	ASII	3854	BID	1799	9
2026-07-15 20:04:32.350269+07	ASII	3894	ASK	1375	5
2026-07-15 20:04:32.350269+07	ASII	3904	ASK	1227	6
2026-07-15 20:04:32.350269+07	ASII	3914	ASK	1627	7
2026-07-15 20:04:32.350269+07	ASII	3924	ASK	1504	8
2026-07-15 20:04:32.350269+07	ASII	3934	ASK	1471	9
2026-07-15 20:04:33.356468+07	ASII	3894	BID	1247	5
2026-07-15 20:04:33.356468+07	ASII	3884	BID	1475	6
2026-07-15 20:04:33.356468+07	ASII	3874	BID	1585	7
2026-07-15 20:04:33.356468+07	ASII	3864	BID	1319	8
2026-07-15 20:04:33.356468+07	ASII	3854	BID	1411	9
2026-07-15 20:04:33.356468+07	ASII	3894	ASK	1039	5
2026-07-15 20:04:33.356468+07	ASII	3904	ASK	1574	6
2026-07-15 20:04:33.356468+07	ASII	3914	ASK	1568	7
2026-07-15 20:04:33.356468+07	ASII	3924	ASK	1417	8
2026-07-15 20:04:33.356468+07	ASII	3934	ASK	1546	9
2026-07-15 20:04:34.36687+07	ASII	3894	BID	1101	5
2026-07-15 20:04:34.36687+07	ASII	3884	BID	1467	6
2026-07-15 20:04:34.36687+07	ASII	3874	BID	1619	7
2026-07-15 20:04:34.36687+07	ASII	3864	BID	1399	8
2026-07-15 20:04:34.36687+07	ASII	3854	BID	1619	9
2026-07-15 20:04:34.36687+07	ASII	3894	ASK	1323	5
2026-07-15 20:04:34.36687+07	ASII	3904	ASK	1317	6
2026-07-15 20:04:34.36687+07	ASII	3914	ASK	1315	7
2026-07-15 20:04:34.36687+07	ASII	3924	ASK	1399	8
2026-07-15 20:04:34.36687+07	ASII	3934	ASK	1527	9
2026-07-15 20:04:35.372763+07	ASII	3894	BID	1354	5
2026-07-15 20:04:35.372763+07	ASII	3884	BID	1453	6
2026-07-15 20:04:35.372763+07	ASII	3874	BID	1238	7
2026-07-15 20:04:35.372763+07	ASII	3864	BID	1355	8
2026-07-15 20:04:35.372763+07	ASII	3854	BID	1876	9
2026-07-15 20:04:35.372763+07	ASII	3894	ASK	1210	5
2026-07-15 20:04:35.372763+07	ASII	3904	ASK	1552	6
2026-07-15 20:04:35.372763+07	ASII	3914	ASK	1622	7
2026-07-15 20:04:35.372763+07	ASII	3924	ASK	1579	8
2026-07-15 20:04:35.372763+07	ASII	3934	ASK	1477	9
2026-07-15 20:04:36.38304+07	ASII	3894	BID	55410	5
2026-07-15 20:04:36.38304+07	ASII	3884	BID	1167	6
2026-07-15 20:04:36.38304+07	ASII	3874	BID	1351	7
2026-07-15 20:04:36.38304+07	ASII	3864	BID	1508	8
2026-07-15 20:04:36.38304+07	ASII	3854	BID	1737	9
2026-07-15 20:04:36.38304+07	ASII	3894	ASK	1235	5
2026-07-15 20:04:36.38304+07	ASII	3904	ASK	1171	6
2026-07-15 20:04:36.38304+07	ASII	3914	ASK	1651	7
2026-07-15 20:04:36.38304+07	ASII	3924	ASK	1309	8
2026-07-15 20:04:36.38304+07	ASII	3934	ASK	1622	9
2026-07-15 20:04:37.388848+07	ASII	3894	BID	59351	5
2026-07-15 20:04:37.388848+07	ASII	3884	BID	1135	6
2026-07-15 20:04:37.388848+07	ASII	3874	BID	1652	7
2026-07-15 20:04:37.388848+07	ASII	3864	BID	1319	8
2026-07-15 20:04:37.388848+07	ASII	3854	BID	1793	9
2026-07-15 20:04:37.388848+07	ASII	3894	ASK	1226	5
2026-07-15 20:04:37.388848+07	ASII	3904	ASK	1106	6
2026-07-15 20:04:37.388848+07	ASII	3914	ASK	1205	7
2026-07-15 20:04:37.388848+07	ASII	3924	ASK	1420	8
2026-07-15 20:04:37.388848+07	ASII	3934	ASK	1495	9
2026-07-15 20:04:38.399064+07	ASII	3894	BID	51854	5
2026-07-15 20:04:38.399064+07	ASII	3884	BID	1293	6
2026-07-15 20:04:38.399064+07	ASII	3874	BID	1575	7
2026-07-15 20:04:38.399064+07	ASII	3864	BID	1562	8
2026-07-15 20:04:38.399064+07	ASII	3854	BID	1714	9
2026-07-15 20:04:38.399064+07	ASII	3894	ASK	1419	5
2026-07-15 20:04:38.399064+07	ASII	3904	ASK	1247	6
2026-07-15 20:04:38.399064+07	ASII	3914	ASK	1269	7
2026-07-15 20:04:38.399064+07	ASII	3924	ASK	1455	8
2026-07-15 20:04:38.399064+07	ASII	3934	ASK	1799	9
2026-07-15 20:04:39.404931+07	ASII	3894	BID	59035	5
2026-07-15 20:04:39.404931+07	ASII	3884	BID	1330	6
2026-07-15 20:04:39.404931+07	ASII	3874	BID	1486	7
2026-07-15 20:04:39.404931+07	ASII	3864	BID	1304	8
2026-07-15 20:04:39.404931+07	ASII	3854	BID	1481	9
2026-07-15 20:04:39.404931+07	ASII	3894	ASK	1418	5
2026-07-15 20:04:39.404931+07	ASII	3904	ASK	1475	6
2026-07-15 20:04:39.404931+07	ASII	3914	ASK	1446	7
2026-07-15 20:04:39.404931+07	ASII	3924	ASK	1365	8
2026-07-15 20:04:39.404931+07	ASII	3934	ASK	1645	9
2026-07-15 20:04:40.413383+07	ASII	3894	BID	54877	5
2026-07-15 20:04:40.413383+07	ASII	3884	BID	1220	6
2026-07-15 20:04:40.413383+07	ASII	3874	BID	1292	7
2026-07-15 20:04:40.413383+07	ASII	3864	BID	1483	8
2026-07-15 20:04:40.413383+07	ASII	3854	BID	1721	9
2026-07-15 20:04:40.413383+07	ASII	3894	ASK	1480	5
2026-07-15 20:04:40.413383+07	ASII	3904	ASK	1228	6
2026-07-15 20:04:40.413383+07	ASII	3914	ASK	1365	7
2026-07-15 20:04:40.413383+07	ASII	3924	ASK	1722	8
2026-07-15 20:04:40.413383+07	ASII	3934	ASK	1675	9
2026-07-15 20:04:41.421147+07	ASII	3894	BID	59124	5
2026-07-15 20:04:41.421147+07	ASII	3884	BID	1105	6
2026-07-15 20:04:41.421147+07	ASII	3874	BID	1632	7
2026-07-15 20:04:41.421147+07	ASII	3864	BID	1793	8
2026-07-15 20:04:41.421147+07	ASII	3854	BID	1827	9
2026-07-15 20:04:41.421147+07	ASII	3894	ASK	1056	5
2026-07-15 20:04:41.421147+07	ASII	3904	ASK	1378	6
2026-07-15 20:04:41.421147+07	ASII	3914	ASK	1528	7
2026-07-15 20:04:41.421147+07	ASII	3924	ASK	1524	8
2026-07-15 20:04:41.421147+07	ASII	3934	ASK	1680	9
2026-07-15 20:04:42.429786+07	ASII	3894	BID	57616	5
2026-07-15 20:04:42.429786+07	ASII	3884	BID	1226	6
2026-07-15 20:04:42.429786+07	ASII	3874	BID	1328	7
2026-07-15 20:04:42.429786+07	ASII	3864	BID	1663	8
2026-07-15 20:04:42.429786+07	ASII	3854	BID	1863	9
2026-07-15 20:04:42.429786+07	ASII	3894	ASK	1288	5
2026-07-15 20:04:42.429786+07	ASII	3904	ASK	1292	6
2026-07-15 20:04:42.429786+07	ASII	3914	ASK	1238	7
2026-07-15 20:04:42.429786+07	ASII	3924	ASK	1553	8
2026-07-15 20:04:42.429786+07	ASII	3934	ASK	1551	9
2026-07-15 20:04:43.437537+07	ASII	3894	BID	56888	5
2026-07-15 20:04:43.437537+07	ASII	3884	BID	1567	6
2026-07-15 20:04:43.437537+07	ASII	3874	BID	1570	7
2026-07-15 20:04:43.437537+07	ASII	3864	BID	1571	8
2026-07-15 20:04:43.437537+07	ASII	3854	BID	1558	9
2026-07-15 20:04:43.437537+07	ASII	3894	ASK	1235	5
2026-07-15 20:04:43.437537+07	ASII	3904	ASK	1436	6
2026-07-15 20:04:43.437537+07	ASII	3914	ASK	1595	7
2026-07-15 20:04:43.437537+07	ASII	3924	ASK	1642	8
2026-07-15 20:04:43.437537+07	ASII	3934	ASK	1519	9
2026-07-15 20:04:44.445257+07	ASII	3894	BID	54471	5
2026-07-15 20:04:44.445257+07	ASII	3884	BID	1294	6
2026-07-15 20:04:44.445257+07	ASII	3874	BID	1654	7
2026-07-15 20:04:44.445257+07	ASII	3864	BID	1774	8
2026-07-15 20:04:44.445257+07	ASII	3854	BID	1722	9
2026-07-15 20:04:44.445257+07	ASII	3894	ASK	1158	5
2026-07-15 20:04:44.445257+07	ASII	3904	ASK	1273	6
2026-07-15 20:04:44.445257+07	ASII	3914	ASK	1497	7
2026-07-15 20:04:44.445257+07	ASII	3924	ASK	1363	8
2026-07-15 20:04:44.445257+07	ASII	3934	ASK	1445	9
2026-07-15 20:04:45.453536+07	ASII	3894	BID	51652	5
2026-07-15 20:04:45.453536+07	ASII	3884	BID	1543	6
2026-07-15 20:04:45.453536+07	ASII	3874	BID	1314	7
2026-07-15 20:04:45.453536+07	ASII	3864	BID	1698	8
2026-07-15 20:04:45.453536+07	ASII	3854	BID	1857	9
2026-07-15 20:04:45.453536+07	ASII	3894	ASK	1161	5
2026-07-15 20:04:45.453536+07	ASII	3904	ASK	1187	6
2026-07-15 20:04:45.453536+07	ASII	3914	ASK	1652	7
2026-07-15 20:04:45.453536+07	ASII	3924	ASK	1301	8
2026-07-15 20:04:45.453536+07	ASII	3934	ASK	1889	9
2026-07-15 20:04:46.461456+07	ASII	3894	BID	58305	5
2026-07-15 20:04:46.461456+07	ASII	3884	BID	1116	6
2026-07-15 20:04:46.461456+07	ASII	3874	BID	1244	7
2026-07-15 20:04:46.461456+07	ASII	3864	BID	1607	8
2026-07-15 20:04:46.461456+07	ASII	3854	BID	1796	9
2026-07-15 20:04:46.461456+07	ASII	3894	ASK	1480	5
2026-07-15 20:04:46.461456+07	ASII	3904	ASK	1101	6
2026-07-15 20:04:46.461456+07	ASII	3914	ASK	1656	7
2026-07-15 20:04:46.461456+07	ASII	3924	ASK	1497	8
2026-07-15 20:04:46.461456+07	ASII	3934	ASK	1659	9
2026-07-15 20:04:47.469777+07	ASII	3894	BID	50349	5
2026-07-15 20:04:47.469777+07	ASII	3884	BID	1265	6
2026-07-15 20:04:47.469777+07	ASII	3874	BID	1553	7
2026-07-15 20:04:47.469777+07	ASII	3864	BID	1605	8
2026-07-15 20:04:47.469777+07	ASII	3854	BID	1783	9
2026-07-15 20:04:47.469777+07	ASII	3894	ASK	1158	5
2026-07-15 20:04:47.469777+07	ASII	3904	ASK	1444	6
2026-07-15 20:04:47.469777+07	ASII	3914	ASK	1412	7
2026-07-15 20:04:47.469777+07	ASII	3924	ASK	1451	8
2026-07-15 20:04:47.469777+07	ASII	3934	ASK	1629	9
2026-07-15 20:04:48.475739+07	ASII	3894	BID	56429	5
2026-07-15 20:04:48.475739+07	ASII	3884	BID	1144	6
2026-07-15 20:04:48.475739+07	ASII	3874	BID	1431	7
2026-07-15 20:04:48.475739+07	ASII	3864	BID	1740	8
2026-07-15 20:04:48.475739+07	ASII	3854	BID	1819	9
2026-07-15 20:04:48.475739+07	ASII	3894	ASK	1431	5
2026-07-15 20:04:48.475739+07	ASII	3904	ASK	1155	6
2026-07-15 20:04:48.475739+07	ASII	3914	ASK	1593	7
2026-07-15 20:04:48.475739+07	ASII	3924	ASK	1362	8
2026-07-15 20:04:48.475739+07	ASII	3934	ASK	1439	9
2026-07-15 20:04:49.486618+07	ASII	3894	BID	57389	5
2026-07-15 20:04:49.486618+07	ASII	3884	BID	1307	6
2026-07-15 20:04:49.486618+07	ASII	3874	BID	1470	7
2026-07-15 20:04:49.486618+07	ASII	3864	BID	1602	8
2026-07-15 20:04:49.486618+07	ASII	3854	BID	1644	9
2026-07-15 20:04:49.486618+07	ASII	3894	ASK	1492	5
2026-07-15 20:04:49.486618+07	ASII	3904	ASK	1533	6
2026-07-15 20:04:49.486618+07	ASII	3914	ASK	1266	7
2026-07-15 20:04:49.486618+07	ASII	3924	ASK	1763	8
2026-07-15 20:04:49.486618+07	ASII	3934	ASK	1827	9
2026-07-15 20:04:50.492405+07	ASII	3894	BID	52237	5
2026-07-15 20:04:50.492405+07	ASII	3884	BID	1162	6
2026-07-15 20:04:50.492405+07	ASII	3874	BID	1582	7
2026-07-15 20:04:50.492405+07	ASII	3864	BID	1715	8
2026-07-15 20:04:50.492405+07	ASII	3854	BID	1872	9
2026-07-15 20:04:50.492405+07	ASII	3894	ASK	1135	5
2026-07-15 20:04:50.492405+07	ASII	3904	ASK	1477	6
2026-07-15 20:04:50.492405+07	ASII	3914	ASK	1354	7
2026-07-15 20:04:50.492405+07	ASII	3924	ASK	1791	8
2026-07-15 20:04:50.492405+07	ASII	3934	ASK	1860	9
2026-07-15 20:04:51.502609+07	ASII	3894	BID	59440	5
2026-07-15 20:04:51.502609+07	ASII	3884	BID	1480	6
2026-07-15 20:04:51.502609+07	ASII	3874	BID	1597	7
2026-07-15 20:04:51.502609+07	ASII	3864	BID	1653	8
2026-07-15 20:04:51.502609+07	ASII	3854	BID	1473	9
2026-07-15 20:04:51.502609+07	ASII	3894	ASK	1380	5
2026-07-15 20:04:51.502609+07	ASII	3904	ASK	1420	6
2026-07-15 20:04:51.502609+07	ASII	3914	ASK	1420	7
2026-07-15 20:04:51.502609+07	ASII	3924	ASK	1626	8
2026-07-15 20:04:51.502609+07	ASII	3934	ASK	1817	9
2026-07-15 20:04:52.508381+07	ASII	3894	BID	53419	5
2026-07-15 20:04:52.508381+07	ASII	3884	BID	1399	6
2026-07-15 20:04:52.508381+07	ASII	3874	BID	1253	7
2026-07-15 20:04:52.508381+07	ASII	3864	BID	1785	8
2026-07-15 20:04:52.508381+07	ASII	3854	BID	1536	9
2026-07-15 20:04:52.508381+07	ASII	3894	ASK	1024	5
2026-07-15 20:04:52.508381+07	ASII	3904	ASK	1335	6
2026-07-15 20:04:52.508381+07	ASII	3914	ASK	1324	7
2026-07-15 20:04:52.508381+07	ASII	3924	ASK	1598	8
2026-07-15 20:04:52.508381+07	ASII	3934	ASK	1812	9
2026-07-15 20:04:53.518751+07	ASII	3894	BID	52363	5
2026-07-15 20:04:53.518751+07	ASII	3884	BID	1377	6
2026-07-15 20:04:53.518751+07	ASII	3874	BID	1309	7
2026-07-15 20:04:53.518751+07	ASII	3864	BID	1342	8
2026-07-15 20:04:53.518751+07	ASII	3854	BID	1757	9
2026-07-15 20:04:53.518751+07	ASII	3894	ASK	1458	5
2026-07-15 20:04:53.518751+07	ASII	3904	ASK	1536	6
2026-07-15 20:04:53.518751+07	ASII	3914	ASK	1352	7
2026-07-15 20:04:53.518751+07	ASII	3924	ASK	1363	8
2026-07-15 20:04:53.518751+07	ASII	3934	ASK	1877	9
2026-07-15 20:04:54.525098+07	ASII	3894	BID	59582	5
2026-07-15 20:04:54.525098+07	ASII	3884	BID	1433	6
2026-07-15 20:04:54.525098+07	ASII	3874	BID	1586	7
2026-07-15 20:04:54.525098+07	ASII	3864	BID	1463	8
2026-07-15 20:04:54.525098+07	ASII	3854	BID	1516	9
2026-07-15 20:04:54.525098+07	ASII	3894	ASK	1442	5
2026-07-15 20:04:54.525098+07	ASII	3904	ASK	1119	6
2026-07-15 20:04:54.525098+07	ASII	3914	ASK	1376	7
2026-07-15 20:04:54.525098+07	ASII	3924	ASK	1727	8
2026-07-15 20:04:54.525098+07	ASII	3934	ASK	1506	9
2026-07-15 20:04:55.536092+07	ASII	3894	BID	50615	5
2026-07-15 20:04:55.536092+07	ASII	3884	BID	1307	6
2026-07-15 20:04:55.536092+07	ASII	3874	BID	1365	7
2026-07-15 20:04:55.536092+07	ASII	3864	BID	1643	8
2026-07-15 20:04:55.536092+07	ASII	3854	BID	1794	9
2026-07-15 20:04:55.536092+07	ASII	3894	ASK	1284	5
2026-07-15 20:04:55.536092+07	ASII	3904	ASK	1344	6
2026-07-15 20:04:55.536092+07	ASII	3914	ASK	1262	7
2026-07-15 20:04:55.536092+07	ASII	3924	ASK	1391	8
2026-07-15 20:04:55.536092+07	ASII	3934	ASK	1443	9
2026-07-15 20:04:56.544212+07	ASII	3894	BID	54748	5
2026-07-15 20:04:56.544212+07	ASII	3884	BID	1126	6
2026-07-15 20:04:56.544212+07	ASII	3874	BID	1639	7
2026-07-15 20:04:56.544212+07	ASII	3864	BID	1358	8
2026-07-15 20:04:56.544212+07	ASII	3854	BID	1886	9
2026-07-15 20:04:56.544212+07	ASII	3894	ASK	1271	5
2026-07-15 20:04:56.544212+07	ASII	3904	ASK	1220	6
2026-07-15 20:04:56.544212+07	ASII	3914	ASK	1457	7
2026-07-15 20:04:56.544212+07	ASII	3924	ASK	1313	8
2026-07-15 20:04:56.544212+07	ASII	3934	ASK	1584	9
2026-07-15 20:04:57.552525+07	ASII	3894	BID	59844	5
2026-07-15 20:04:57.552525+07	ASII	3884	BID	1474	6
2026-07-15 20:04:57.552525+07	ASII	3874	BID	1326	7
2026-07-15 20:04:57.552525+07	ASII	3864	BID	1427	8
2026-07-15 20:04:57.552525+07	ASII	3854	BID	1743	9
2026-07-15 20:04:57.552525+07	ASII	3894	ASK	1098	5
2026-07-15 20:04:57.552525+07	ASII	3904	ASK	1220	6
2026-07-15 20:04:57.552525+07	ASII	3914	ASK	1329	7
2026-07-15 20:04:57.552525+07	ASII	3924	ASK	1469	8
2026-07-15 20:04:57.552525+07	ASII	3934	ASK	1692	9
2026-07-15 20:04:58.55753+07	ASII	3894	BID	53496	5
2026-07-15 20:04:58.55753+07	ASII	3884	BID	1504	6
2026-07-15 20:04:58.55753+07	ASII	3874	BID	1269	7
2026-07-15 20:04:58.55753+07	ASII	3864	BID	1770	8
2026-07-15 20:04:58.55753+07	ASII	3854	BID	1814	9
2026-07-15 20:04:58.55753+07	ASII	3894	ASK	1315	5
2026-07-15 20:04:58.55753+07	ASII	3904	ASK	1558	6
2026-07-15 20:04:58.55753+07	ASII	3914	ASK	1211	7
2026-07-15 20:04:58.55753+07	ASII	3924	ASK	1578	8
2026-07-15 20:04:58.55753+07	ASII	3934	ASK	1792	9
2026-07-15 20:04:59.568817+07	ASII	3894	BID	55393	5
2026-07-15 20:04:59.568817+07	ASII	3884	BID	1576	6
2026-07-15 20:04:59.568817+07	ASII	3874	BID	1481	7
2026-07-15 20:04:59.568817+07	ASII	3864	BID	1353	8
2026-07-15 20:04:59.568817+07	ASII	3854	BID	1637	9
2026-07-15 20:04:59.568817+07	ASII	3894	ASK	1184	5
2026-07-15 20:04:59.568817+07	ASII	3904	ASK	1596	6
2026-07-15 20:04:59.568817+07	ASII	3914	ASK	1600	7
2026-07-15 20:04:59.568817+07	ASII	3924	ASK	1394	8
2026-07-15 20:04:59.568817+07	ASII	3934	ASK	1794	9
2026-07-15 20:05:00.574315+07	ASII	3894	BID	57221	5
2026-07-15 20:05:00.574315+07	ASII	3884	BID	1552	6
2026-07-15 20:05:00.574315+07	ASII	3874	BID	1634	7
2026-07-15 20:05:00.574315+07	ASII	3864	BID	1652	8
2026-07-15 20:05:00.574315+07	ASII	3854	BID	1562	9
2026-07-15 20:05:00.574315+07	ASII	3894	ASK	1196	5
2026-07-15 20:05:00.574315+07	ASII	3904	ASK	1359	6
2026-07-15 20:05:00.574315+07	ASII	3914	ASK	1323	7
2026-07-15 20:05:00.574315+07	ASII	3924	ASK	1395	8
2026-07-15 20:05:00.574315+07	ASII	3934	ASK	1762	9
2026-07-15 20:05:01.58642+07	ASII	3894	BID	51707	5
2026-07-15 20:05:01.58642+07	ASII	3884	BID	1407	6
2026-07-15 20:05:01.58642+07	ASII	3874	BID	1454	7
2026-07-15 20:05:01.58642+07	ASII	3864	BID	1554	8
2026-07-15 20:05:01.58642+07	ASII	3854	BID	1504	9
2026-07-15 20:05:01.58642+07	ASII	3894	ASK	1386	5
2026-07-15 20:05:01.58642+07	ASII	3904	ASK	1452	6
2026-07-15 20:05:01.58642+07	ASII	3914	ASK	1215	7
2026-07-15 20:05:01.58642+07	ASII	3924	ASK	1617	8
2026-07-15 20:05:01.58642+07	ASII	3934	ASK	1402	9
2026-07-15 20:05:02.591245+07	ASII	3894	BID	56842	5
2026-07-15 20:05:02.591245+07	ASII	3884	BID	1309	6
2026-07-15 20:05:02.591245+07	ASII	3874	BID	1611	7
2026-07-15 20:05:02.591245+07	ASII	3864	BID	1775	8
2026-07-15 20:05:02.591245+07	ASII	3854	BID	1715	9
2026-07-15 20:05:02.591245+07	ASII	3894	ASK	1295	5
2026-07-15 20:05:02.591245+07	ASII	3904	ASK	1282	6
2026-07-15 20:05:02.591245+07	ASII	3914	ASK	1395	7
2026-07-15 20:05:02.591245+07	ASII	3924	ASK	1398	8
2026-07-15 20:05:02.591245+07	ASII	3934	ASK	1434	9
2026-07-15 20:05:03.601911+07	ASII	3894	BID	54500	5
2026-07-15 20:05:03.601911+07	ASII	3884	BID	1140	6
2026-07-15 20:05:03.601911+07	ASII	3874	BID	1294	7
2026-07-15 20:05:03.601911+07	ASII	3864	BID	1720	8
2026-07-15 20:05:03.601911+07	ASII	3854	BID	1872	9
2026-07-15 20:05:03.601911+07	ASII	3894	ASK	1138	5
2026-07-15 20:05:03.601911+07	ASII	3904	ASK	1574	6
2026-07-15 20:05:03.601911+07	ASII	3914	ASK	1479	7
2026-07-15 20:05:03.601911+07	ASII	3924	ASK	1398	8
2026-07-15 20:05:03.601911+07	ASII	3934	ASK	1748	9
2026-07-15 20:05:04.608867+07	ASII	3894	BID	57730	5
2026-07-15 20:05:04.608867+07	ASII	3884	BID	1126	6
2026-07-15 20:05:04.608867+07	ASII	3874	BID	1609	7
2026-07-15 20:05:04.608867+07	ASII	3864	BID	1362	8
2026-07-15 20:05:04.608867+07	ASII	3854	BID	1779	9
2026-07-15 20:05:04.608867+07	ASII	3894	ASK	1016	5
2026-07-15 20:05:04.608867+07	ASII	3904	ASK	1247	6
2026-07-15 20:05:04.608867+07	ASII	3914	ASK	1328	7
2026-07-15 20:05:04.608867+07	ASII	3924	ASK	1544	8
2026-07-15 20:05:04.608867+07	ASII	3934	ASK	1679	9
2026-07-15 20:05:05.61944+07	ASII	3894	BID	59639	5
2026-07-15 20:05:05.61944+07	ASII	3884	BID	1298	6
2026-07-15 20:05:05.61944+07	ASII	3874	BID	1677	7
2026-07-15 20:05:05.61944+07	ASII	3864	BID	1443	8
2026-07-15 20:05:05.61944+07	ASII	3854	BID	1519	9
2026-07-15 20:05:05.61944+07	ASII	3894	ASK	1284	5
2026-07-15 20:05:05.61944+07	ASII	3904	ASK	1489	6
2026-07-15 20:05:05.61944+07	ASII	3914	ASK	1373	7
2026-07-15 20:05:05.61944+07	ASII	3924	ASK	1467	8
2026-07-15 20:05:05.61944+07	ASII	3934	ASK	1417	9
2026-07-15 20:05:06.625512+07	ASII	3894	BID	51469	5
2026-07-15 20:05:06.625512+07	ASII	3884	BID	1406	6
2026-07-15 20:05:06.625512+07	ASII	3874	BID	1208	7
2026-07-15 20:05:06.625512+07	ASII	3864	BID	1746	8
2026-07-15 20:05:06.625512+07	ASII	3854	BID	1779	9
2026-07-15 20:05:06.625512+07	ASII	3894	ASK	1027	5
2026-07-15 20:05:06.625512+07	ASII	3904	ASK	1442	6
2026-07-15 20:05:06.625512+07	ASII	3914	ASK	1549	7
2026-07-15 20:05:06.625512+07	ASII	3924	ASK	1557	8
2026-07-15 20:05:06.625512+07	ASII	3934	ASK	1658	9
2026-07-15 20:05:07.635746+07	ASII	3894	BID	56451	5
2026-07-15 20:05:07.635746+07	ASII	3884	BID	1310	6
2026-07-15 20:05:07.635746+07	ASII	3874	BID	1239	7
2026-07-15 20:05:07.635746+07	ASII	3864	BID	1579	8
2026-07-15 20:05:07.635746+07	ASII	3854	BID	1791	9
2026-07-15 20:05:07.635746+07	ASII	3894	ASK	1273	5
2026-07-15 20:05:07.635746+07	ASII	3904	ASK	1472	6
2026-07-15 20:05:07.635746+07	ASII	3914	ASK	1314	7
2026-07-15 20:05:07.635746+07	ASII	3924	ASK	1641	8
2026-07-15 20:05:07.635746+07	ASII	3934	ASK	1763	9
2026-07-15 20:05:08.6402+07	ASII	3894	BID	55049	5
2026-07-15 20:05:08.6402+07	ASII	3884	BID	1207	6
2026-07-15 20:05:08.6402+07	ASII	3874	BID	1228	7
2026-07-15 20:05:08.6402+07	ASII	3864	BID	1553	8
2026-07-15 20:05:08.6402+07	ASII	3854	BID	1897	9
2026-07-15 20:05:08.6402+07	ASII	3894	ASK	1420	5
2026-07-15 20:05:08.6402+07	ASII	3904	ASK	1541	6
2026-07-15 20:05:08.6402+07	ASII	3914	ASK	1206	7
2026-07-15 20:05:08.6402+07	ASII	3924	ASK	1335	8
2026-07-15 20:05:08.6402+07	ASII	3934	ASK	1819	9
2026-07-15 20:05:09.648321+07	ASII	3894	BID	51012	5
2026-07-15 20:05:09.648321+07	ASII	3884	BID	1585	6
2026-07-15 20:05:09.648321+07	ASII	3874	BID	1653	7
2026-07-15 20:05:09.648321+07	ASII	3864	BID	1363	8
2026-07-15 20:05:09.648321+07	ASII	3854	BID	1585	9
2026-07-15 20:05:09.648321+07	ASII	3894	ASK	1234	5
2026-07-15 20:05:09.648321+07	ASII	3904	ASK	1376	6
2026-07-15 20:05:09.648321+07	ASII	3914	ASK	1675	7
2026-07-15 20:05:09.648321+07	ASII	3924	ASK	1455	8
2026-07-15 20:05:09.648321+07	ASII	3934	ASK	1451	9
2026-07-15 20:05:10.65613+07	ASII	3894	BID	54730	5
2026-07-15 20:05:10.65613+07	ASII	3884	BID	1125	6
2026-07-15 20:05:10.65613+07	ASII	3874	BID	1227	7
2026-07-15 20:05:10.65613+07	ASII	3864	BID	1636	8
2026-07-15 20:05:10.65613+07	ASII	3854	BID	1790	9
2026-07-15 20:05:10.65613+07	ASII	3894	ASK	1182	5
2026-07-15 20:05:10.65613+07	ASII	3904	ASK	1117	6
2026-07-15 20:05:10.65613+07	ASII	3914	ASK	1633	7
2026-07-15 20:05:10.65613+07	ASII	3924	ASK	1431	8
2026-07-15 20:05:10.65613+07	ASII	3934	ASK	1803	9
2026-07-15 20:05:11.664895+07	ASII	3894	BID	53014	5
2026-07-15 20:05:11.664895+07	ASII	3884	BID	1516	6
2026-07-15 20:05:11.664895+07	ASII	3874	BID	1572	7
2026-07-15 20:05:11.664895+07	ASII	3864	BID	1444	8
2026-07-15 20:05:11.664895+07	ASII	3854	BID	1587	9
2026-07-15 20:05:11.664895+07	ASII	3894	ASK	1297	5
2026-07-15 20:05:11.664895+07	ASII	3904	ASK	1119	6
2026-07-15 20:05:11.664895+07	ASII	3914	ASK	1313	7
2026-07-15 20:05:11.664895+07	ASII	3924	ASK	1682	8
2026-07-15 20:05:11.664895+07	ASII	3934	ASK	1784	9
2026-07-15 20:05:12.672271+07	ASII	3894	BID	57602	5
2026-07-15 20:05:12.672271+07	ASII	3884	BID	1539	6
2026-07-15 20:05:12.672271+07	ASII	3874	BID	1465	7
2026-07-15 20:05:12.672271+07	ASII	3864	BID	1369	8
2026-07-15 20:05:12.672271+07	ASII	3854	BID	1580	9
2026-07-15 20:05:12.672271+07	ASII	3894	ASK	1230	5
2026-07-15 20:05:12.672271+07	ASII	3904	ASK	1436	6
2026-07-15 20:05:12.672271+07	ASII	3914	ASK	1231	7
2026-07-15 20:05:12.672271+07	ASII	3924	ASK	1434	8
2026-07-15 20:05:12.672271+07	ASII	3934	ASK	1853	9
2026-07-15 20:05:13.678495+07	ASII	3894	BID	55092	5
2026-07-15 20:05:13.678495+07	ASII	3884	BID	1179	6
2026-07-15 20:05:13.678495+07	ASII	3874	BID	1513	7
2026-07-15 20:05:13.678495+07	ASII	3864	BID	1796	8
2026-07-15 20:05:13.678495+07	ASII	3854	BID	1820	9
2026-07-15 20:05:13.678495+07	ASII	3894	ASK	1167	5
2026-07-15 20:05:13.678495+07	ASII	3904	ASK	1487	6
2026-07-15 20:05:13.678495+07	ASII	3914	ASK	1409	7
2026-07-15 20:05:13.678495+07	ASII	3924	ASK	1522	8
2026-07-15 20:05:13.678495+07	ASII	3934	ASK	1776	9
2026-07-15 20:05:14.68811+07	ASII	3894	BID	57020	5
2026-07-15 20:05:14.68811+07	ASII	3884	BID	1221	6
2026-07-15 20:05:14.68811+07	ASII	3874	BID	1609	7
2026-07-15 20:05:14.68811+07	ASII	3864	BID	1479	8
2026-07-15 20:05:14.68811+07	ASII	3854	BID	1844	9
2026-07-15 20:05:14.68811+07	ASII	3894	ASK	1264	5
2026-07-15 20:05:14.68811+07	ASII	3904	ASK	1556	6
2026-07-15 20:05:14.68811+07	ASII	3914	ASK	1262	7
2026-07-15 20:05:14.68811+07	ASII	3924	ASK	1608	8
2026-07-15 20:05:14.68811+07	ASII	3934	ASK	1572	9
2026-07-15 20:05:15.693842+07	ASII	3894	BID	58251	5
2026-07-15 20:05:15.693842+07	ASII	3884	BID	1279	6
2026-07-15 20:05:15.693842+07	ASII	3874	BID	1387	7
2026-07-15 20:05:15.693842+07	ASII	3864	BID	1412	8
2026-07-15 20:05:15.693842+07	ASII	3854	BID	1454	9
2026-07-15 20:05:15.693842+07	ASII	3894	ASK	1192	5
2026-07-15 20:05:15.693842+07	ASII	3904	ASK	1297	6
2026-07-15 20:05:15.693842+07	ASII	3914	ASK	1424	7
2026-07-15 20:05:15.693842+07	ASII	3924	ASK	1422	8
2026-07-15 20:05:15.693842+07	ASII	3934	ASK	1444	9
2026-07-15 20:05:16.703704+07	ASII	3894	BID	51567	5
2026-07-15 20:05:16.703704+07	ASII	3884	BID	1412	6
2026-07-15 20:05:16.703704+07	ASII	3874	BID	1202	7
2026-07-15 20:05:16.703704+07	ASII	3864	BID	1487	8
2026-07-15 20:05:16.703704+07	ASII	3854	BID	1599	9
2026-07-15 20:05:16.703704+07	ASII	3894	ASK	1211	5
2026-07-15 20:05:16.703704+07	ASII	3904	ASK	1574	6
2026-07-15 20:05:16.703704+07	ASII	3914	ASK	1615	7
2026-07-15 20:05:16.703704+07	ASII	3924	ASK	1515	8
2026-07-15 20:05:16.703704+07	ASII	3934	ASK	1890	9
2026-07-15 20:05:17.708854+07	ASII	3894	BID	51514	5
2026-07-15 20:05:17.708854+07	ASII	3884	BID	1527	6
2026-07-15 20:05:17.708854+07	ASII	3874	BID	1517	7
2026-07-15 20:05:17.708854+07	ASII	3864	BID	1522	8
2026-07-15 20:05:17.708854+07	ASII	3854	BID	1638	9
2026-07-15 20:05:17.708854+07	ASII	3894	ASK	1317	5
2026-07-15 20:05:17.708854+07	ASII	3904	ASK	1366	6
2026-07-15 20:05:17.708854+07	ASII	3914	ASK	1402	7
2026-07-15 20:05:17.708854+07	ASII	3924	ASK	1476	8
2026-07-15 20:05:17.708854+07	ASII	3934	ASK	1416	9
2026-07-15 20:05:18.719457+07	ASII	3894	BID	55570	5
2026-07-15 20:05:18.719457+07	ASII	3884	BID	1348	6
2026-07-15 20:05:18.719457+07	ASII	3874	BID	1683	7
2026-07-15 20:05:18.719457+07	ASII	3864	BID	1397	8
2026-07-15 20:05:18.719457+07	ASII	3854	BID	1746	9
2026-07-15 20:05:18.719457+07	ASII	3894	ASK	1122	5
2026-07-15 20:05:18.719457+07	ASII	3904	ASK	1431	6
2026-07-15 20:05:18.719457+07	ASII	3914	ASK	1367	7
2026-07-15 20:05:18.719457+07	ASII	3924	ASK	1732	8
2026-07-15 20:05:18.719457+07	ASII	3934	ASK	1845	9
2026-07-15 20:05:19.724785+07	ASII	3894	BID	54653	5
2026-07-15 20:05:19.724785+07	ASII	3884	BID	1450	6
2026-07-15 20:05:19.724785+07	ASII	3874	BID	1236	7
2026-07-15 20:05:19.724785+07	ASII	3864	BID	1359	8
2026-07-15 20:05:19.724785+07	ASII	3854	BID	1588	9
2026-07-15 20:05:19.724785+07	ASII	3894	ASK	1468	5
2026-07-15 20:05:19.724785+07	ASII	3904	ASK	1501	6
2026-07-15 20:05:19.724785+07	ASII	3914	ASK	1517	7
2026-07-15 20:05:19.724785+07	ASII	3924	ASK	1664	8
2026-07-15 20:05:19.724785+07	ASII	3934	ASK	1510	9
2026-07-15 20:05:20.734166+07	ASII	3894	BID	52039	5
2026-07-15 20:05:20.734166+07	ASII	3884	BID	1394	6
2026-07-15 20:05:20.734166+07	ASII	3874	BID	1377	7
2026-07-15 20:05:20.734166+07	ASII	3864	BID	1694	8
2026-07-15 20:05:20.734166+07	ASII	3854	BID	1527	9
2026-07-15 20:05:20.734166+07	ASII	3894	ASK	1425	5
2026-07-15 20:05:20.734166+07	ASII	3904	ASK	1484	6
2026-07-15 20:05:20.734166+07	ASII	3914	ASK	1510	7
2026-07-15 20:05:20.734166+07	ASII	3924	ASK	1438	8
2026-07-15 20:05:20.734166+07	ASII	3934	ASK	1897	9
2026-07-15 20:05:21.74068+07	ASII	3894	BID	52067	5
2026-07-15 20:05:21.74068+07	ASII	3884	BID	1502	6
2026-07-15 20:05:21.74068+07	ASII	3874	BID	1424	7
2026-07-15 20:05:21.74068+07	ASII	3864	BID	1550	8
2026-07-15 20:05:21.74068+07	ASII	3854	BID	1812	9
2026-07-15 20:05:21.74068+07	ASII	3894	ASK	1422	5
2026-07-15 20:05:21.74068+07	ASII	3904	ASK	1308	6
2026-07-15 20:05:21.74068+07	ASII	3914	ASK	1242	7
2026-07-15 20:05:21.74068+07	ASII	3924	ASK	1698	8
2026-07-15 20:05:21.74068+07	ASII	3934	ASK	1801	9
2026-07-15 20:05:22.751059+07	ASII	3894	BID	56770	5
2026-07-15 20:05:22.751059+07	ASII	3884	BID	1400	6
2026-07-15 20:05:22.751059+07	ASII	3874	BID	1370	7
2026-07-15 20:05:22.751059+07	ASII	3864	BID	1555	8
2026-07-15 20:05:22.751059+07	ASII	3854	BID	1531	9
2026-07-15 20:05:22.751059+07	ASII	3894	ASK	1498	5
2026-07-15 20:05:22.751059+07	ASII	3904	ASK	1252	6
2026-07-15 20:05:22.751059+07	ASII	3914	ASK	1695	7
2026-07-15 20:05:22.751059+07	ASII	3924	ASK	1348	8
2026-07-15 20:05:22.751059+07	ASII	3934	ASK	1779	9
2026-07-15 20:05:23.756791+07	ASII	3894	BID	52926	5
2026-07-15 20:05:23.756791+07	ASII	3884	BID	1499	6
2026-07-15 20:05:23.756791+07	ASII	3874	BID	1286	7
2026-07-15 20:05:23.756791+07	ASII	3864	BID	1726	8
2026-07-15 20:05:23.756791+07	ASII	3854	BID	1696	9
2026-07-15 20:05:23.756791+07	ASII	3894	ASK	1077	5
2026-07-15 20:05:23.756791+07	ASII	3904	ASK	1476	6
2026-07-15 20:05:23.756791+07	ASII	3914	ASK	1437	7
2026-07-15 20:05:23.756791+07	ASII	3924	ASK	1546	8
2026-07-15 20:05:23.756791+07	ASII	3934	ASK	1517	9
2026-07-15 20:05:24.76769+07	ASII	3894	BID	55797	5
2026-07-15 20:05:24.76769+07	ASII	3884	BID	1489	6
2026-07-15 20:05:24.76769+07	ASII	3874	BID	1387	7
2026-07-15 20:05:24.76769+07	ASII	3864	BID	1431	8
2026-07-15 20:05:24.76769+07	ASII	3854	BID	1669	9
2026-07-15 20:05:24.76769+07	ASII	3894	ASK	1246	5
2026-07-15 20:05:24.76769+07	ASII	3904	ASK	1140	6
2026-07-15 20:05:24.76769+07	ASII	3914	ASK	1415	7
2026-07-15 20:05:24.76769+07	ASII	3924	ASK	1350	8
2026-07-15 20:05:24.76769+07	ASII	3934	ASK	1628	9
\.


--
-- Data for Name: _hyper_3_1_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_3_1_chunk ("time", index_name, last_price, daily_change_percent) FROM stdin;
2026-07-15 01:29:50.819442+07	SP500	5450.0	0.45
2026-07-15 01:29:50.819442+07	NASDAQ	19120.0	-0.12
2026-07-15 01:29:50.819442+07	DXY	101.5	0.05
2026-07-15 01:29:50.819442+07	COMPOSITE	7200.0	0.25
2026-07-15 01:30:01.893984+07	SP500	5450.0	0.45
2026-07-15 01:30:01.893984+07	NASDAQ	19120.0	-0.12
2026-07-15 01:30:01.893984+07	DXY	101.5	0.05
2026-07-15 01:30:01.893984+07	COMPOSITE	7200.0	0.25
2026-07-15 20:04:54.953055+07	SP500	5450.0	0.45
2026-07-15 20:04:54.953055+07	NASDAQ	19120.0	-0.12
2026-07-15 20:04:54.953055+07	DXY	101.5	0.05
2026-07-15 20:04:54.953055+07	COMPOSITE	7200.0	0.25
2026-07-15 20:05:19.282341+07	SP500	5450.0	0.45
2026-07-15 20:05:19.282341+07	NASDAQ	19120.0	-0.12
2026-07-15 20:05:19.282341+07	DXY	101.5	0.05
2026-07-15 20:05:19.282341+07	COMPOSITE	7200.0	0.25
\.


--
-- Data for Name: _hyper_4_2_chunk; Type: TABLE DATA; Schema: _timescaledb_internal; Owner: postgres
--

COPY _timescaledb_internal._hyper_4_2_chunk ("time", ticker, foreign_buy_volume, foreign_sell_volume, net_foreign_val_idr) FROM stdin;
2026-07-15 01:29:50.845388+07	BBCA	1222131	1022131	200000000
2026-07-15 01:29:50.845388+07	BBRI	1167009	1067009	100000000
2026-07-15 01:29:50.845388+07	BMRI	1228175	928175	300000000
2026-07-15 01:29:50.845388+07	TLKM	1288274	1188274	100000000
2026-07-15 01:29:50.845388+07	ASII	1414512	1014512	400000000
2026-07-15 01:30:01.906856+07	BBCA	1366248	1166248	200000000
2026-07-15 01:30:01.906856+07	BBRI	1329687	929687	400000000
2026-07-15 01:30:01.906856+07	BMRI	1380243	980243	400000000
2026-07-15 01:30:01.906856+07	TLKM	1083370	983370	100000000
2026-07-15 01:30:01.906856+07	ASII	1412959	912959	500000000
2026-07-15 20:04:54.98203+07	BBCA	1388108	988108	400000000
2026-07-15 20:04:54.98203+07	BBRI	1275661	975661	300000000
2026-07-15 20:04:54.98203+07	BMRI	1236951	836951	400000000
2026-07-15 20:04:54.98203+07	TLKM	1164782	1164782	0
2026-07-15 20:04:54.98203+07	ASII	1316073	1116073	200000000
2026-07-15 20:05:19.292487+07	BBCA	1053058	1153058	-100000000
2026-07-15 20:05:19.292487+07	BBRI	1411135	1111135	300000000
2026-07-15 20:05:19.292487+07	BMRI	1064578	1164578	-100000000
2026-07-15 20:05:19.292487+07	TLKM	1495512	995512	500000000
2026-07-15 20:05:19.292487+07	ASII	1227894	1027894	200000000
\.


--
-- Data for Name: app_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.app_notifications (id, "time", title, message, type, is_read) FROM stdin;
\.


--
-- Data for Name: bot_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bot_orders (order_id, "time", ticker, side, price, quantity_lot, trigger_reason, status, broker_order_ref) FROM stdin;
\.


--
-- Data for Name: equity_performance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.equity_performance (date, total_equity, daily_pnl, daily_pnl_percent, total_trades, winning_trades, losing_trades, win_rate, profit_factor, max_drawdown, updated_at) FROM stdin;
\.


--
-- Data for Name: foreign_flow_ihsg; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.foreign_flow_ihsg ("time", ticker, foreign_buy_volume, foreign_sell_volume, net_foreign_val_idr) FROM stdin;
\.


--
-- Data for Name: global_sentiment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.global_sentiment ("time", index_name, last_price, daily_change_percent) FROM stdin;
\.


--
-- Data for Name: idx_holidays; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.idx_holidays (holiday_date, description) FROM stdin;
2026-01-01	Tahun Baru Masehi
2026-03-19	Hari Raya Nyepi
2026-12-25	Hari Raya Natal
\.


--
-- Data for Name: market_trades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.market_trades ("time", ticker, price, volume, buyer_broker, seller_broker, trade_type) FROM stdin;
\.


--
-- Data for Name: negotiated_market_trades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.negotiated_market_trades ("time", ticker, price, volume, buyer_broker, seller_broker, total_value_idr) FROM stdin;
\.


--
-- Data for Name: order_book_snapshots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_book_snapshots ("time", ticker, price, type, total_volume_lot, queue_count) FROM stdin;
\.


--
-- Data for Name: stress_test_scenarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stress_test_scenarios (scenario_id, scenario_name, price_drop_multiplier, liquidity_drain_ratio, volume_spike_multiplier) FROM stdin;
1	SYSTEMIC_GLOBAL_PANIC	0.85	0.75	6
2	TECH_BUBBLE_BURST	0.7	0.85	8
3	COVID_MARKET_CRASH	0.6	0.9	10
4	FLASH_CRASH_EVENT	0.8	0.95	15
5	LIQUIDITY_CRISIS	0.9	0.6	5
\.


--
-- Data for Name: user_portfolio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_portfolio (ticker, avg_buy_price, current_lot_qty, total_invested_idr, last_updated) FROM stdin;
\.


--
-- Data for Name: virtual_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.virtual_account (user_id, cash_balance_idr, updated_at) FROM stdin;
1	100000000.00	2026-07-15 00:11:10.095753+07
\.


--
-- Data for Name: virtual_portfolio; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.virtual_portfolio (ticker, avg_buy_price, current_lot_qty, total_value_idr, updated_at) FROM stdin;
\.


--
-- Name: bgw_job_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.bgw_job_id_seq', 1000, false);


--
-- Name: chunk_column_stats_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_column_stats_id_seq', 1, false);


--
-- Name: chunk_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.chunk_id_seq', 8, true);


--
-- Name: dimension_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_id_seq', 5, true);


--
-- Name: dimension_slice_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.dimension_slice_id_seq', 8, true);


--
-- Name: hypertable_id_seq; Type: SEQUENCE SET; Schema: _timescaledb_catalog; Owner: postgres
--

SELECT pg_catalog.setval('_timescaledb_catalog.hypertable_id_seq', 5, true);


--
-- Name: app_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_notifications_id_seq', 1, false);


--
-- Name: bot_orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bot_orders_order_id_seq', 1, false);


--
-- Name: stress_test_scenarios_scenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stress_test_scenarios_scenario_id_seq', 5, true);


--
-- Name: virtual_account_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.virtual_account_user_id_seq', 1, true);


--
-- Name: app_notifications app_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_notifications
    ADD CONSTRAINT app_notifications_pkey PRIMARY KEY (id);


--
-- Name: bot_orders bot_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bot_orders
    ADD CONSTRAINT bot_orders_pkey PRIMARY KEY (order_id);


--
-- Name: equity_performance equity_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equity_performance
    ADD CONSTRAINT equity_performance_pkey PRIMARY KEY (date);


--
-- Name: idx_holidays idx_holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.idx_holidays
    ADD CONSTRAINT idx_holidays_pkey PRIMARY KEY (holiday_date);


--
-- Name: stress_test_scenarios stress_test_scenarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stress_test_scenarios
    ADD CONSTRAINT stress_test_scenarios_pkey PRIMARY KEY (scenario_id);


--
-- Name: user_portfolio user_portfolio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_portfolio
    ADD CONSTRAINT user_portfolio_pkey PRIMARY KEY (ticker);


--
-- Name: virtual_account virtual_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.virtual_account
    ADD CONSTRAINT virtual_account_pkey PRIMARY KEY (user_id);


--
-- Name: virtual_portfolio virtual_portfolio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.virtual_portfolio
    ADD CONSTRAINT virtual_portfolio_pkey PRIMARY KEY (ticker);


--
-- Name: _hyper_1_3_chunk_idx_ticker_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_3_chunk_idx_ticker_time ON _timescaledb_internal._hyper_1_3_chunk USING btree (ticker, "time" DESC);


--
-- Name: _hyper_1_3_chunk_market_trades_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_3_chunk_market_trades_time_idx ON _timescaledb_internal._hyper_1_3_chunk USING btree ("time" DESC);


--
-- Name: _hyper_1_4_chunk_idx_ticker_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_4_chunk_idx_ticker_time ON _timescaledb_internal._hyper_1_4_chunk USING btree (ticker, "time" DESC);


--
-- Name: _hyper_1_4_chunk_market_trades_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_4_chunk_market_trades_time_idx ON _timescaledb_internal._hyper_1_4_chunk USING btree ("time" DESC);


--
-- Name: _hyper_1_5_chunk_idx_ticker_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_5_chunk_idx_ticker_time ON _timescaledb_internal._hyper_1_5_chunk USING btree (ticker, "time" DESC);


--
-- Name: _hyper_1_5_chunk_market_trades_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_5_chunk_market_trades_time_idx ON _timescaledb_internal._hyper_1_5_chunk USING btree ("time" DESC);


--
-- Name: _hyper_1_6_chunk_idx_ticker_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_6_chunk_idx_ticker_time ON _timescaledb_internal._hyper_1_6_chunk USING btree (ticker, "time" DESC);


--
-- Name: _hyper_1_6_chunk_market_trades_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_6_chunk_market_trades_time_idx ON _timescaledb_internal._hyper_1_6_chunk USING btree ("time" DESC);


--
-- Name: _hyper_1_7_chunk_idx_ticker_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_7_chunk_idx_ticker_time ON _timescaledb_internal._hyper_1_7_chunk USING btree (ticker, "time" DESC);


--
-- Name: _hyper_1_7_chunk_market_trades_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_1_7_chunk_market_trades_time_idx ON _timescaledb_internal._hyper_1_7_chunk USING btree ("time" DESC);


--
-- Name: _hyper_2_8_chunk_idx_ob_spoof; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_2_8_chunk_idx_ob_spoof ON _timescaledb_internal._hyper_2_8_chunk USING btree (ticker, price, "time" DESC);


--
-- Name: _hyper_2_8_chunk_order_book_snapshots_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_2_8_chunk_order_book_snapshots_time_idx ON _timescaledb_internal._hyper_2_8_chunk USING btree ("time" DESC);


--
-- Name: _hyper_3_1_chunk_global_sentiment_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_3_1_chunk_global_sentiment_time_idx ON _timescaledb_internal._hyper_3_1_chunk USING btree ("time" DESC);


--
-- Name: _hyper_3_1_chunk_idx_global_name_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_3_1_chunk_idx_global_name_time ON _timescaledb_internal._hyper_3_1_chunk USING btree (index_name, "time" DESC);


--
-- Name: _hyper_4_2_chunk_foreign_flow_ihsg_time_idx; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_4_2_chunk_foreign_flow_ihsg_time_idx ON _timescaledb_internal._hyper_4_2_chunk USING btree ("time" DESC);


--
-- Name: _hyper_4_2_chunk_idx_foreign_ticker_time; Type: INDEX; Schema: _timescaledb_internal; Owner: postgres
--

CREATE INDEX _hyper_4_2_chunk_idx_foreign_ticker_time ON _timescaledb_internal._hyper_4_2_chunk USING btree (ticker, "time" DESC);


--
-- Name: foreign_flow_ihsg_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX foreign_flow_ihsg_time_idx ON public.foreign_flow_ihsg USING btree ("time" DESC);


--
-- Name: global_sentiment_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX global_sentiment_time_idx ON public.global_sentiment USING btree ("time" DESC);


--
-- Name: idx_bot_ticker_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_bot_ticker_time ON public.bot_orders USING btree (ticker, "time" DESC);


--
-- Name: idx_equity_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_equity_date ON public.equity_performance USING btree (date DESC);


--
-- Name: idx_foreign_ticker_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_foreign_ticker_time ON public.foreign_flow_ihsg USING btree (ticker, "time" DESC);


--
-- Name: idx_global_name_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_global_name_time ON public.global_sentiment USING btree (index_name, "time" DESC);


--
-- Name: idx_neg_market; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_neg_market ON public.negotiated_market_trades USING btree (ticker, "time" DESC);


--
-- Name: idx_notifications_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_time ON public.app_notifications USING btree ("time" DESC);


--
-- Name: idx_ob_spoof; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ob_spoof ON public.order_book_snapshots USING btree (ticker, price, "time" DESC);


--
-- Name: idx_portfolio_ticker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_portfolio_ticker ON public.user_portfolio USING btree (ticker);


--
-- Name: idx_ticker_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ticker_time ON public.market_trades USING btree (ticker, "time" DESC);


--
-- Name: idx_virtual_portfolio_ticker; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_virtual_portfolio_ticker ON public.virtual_portfolio USING btree (ticker);


--
-- Name: market_trades_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX market_trades_time_idx ON public.market_trades USING btree ("time" DESC);


--
-- Name: negotiated_market_trades_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX negotiated_market_trades_time_idx ON public.negotiated_market_trades USING btree ("time" DESC);


--
-- Name: order_book_snapshots_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX order_book_snapshots_time_idx ON public.order_book_snapshots USING btree ("time" DESC);


--
-- PostgreSQL database dump complete
--

\unrestrict s7I7wQuesVwcJEvcx7XAtooOG8VhYf65EIPkkKLVePiYZzGmQWrBc86IXtNj88I

