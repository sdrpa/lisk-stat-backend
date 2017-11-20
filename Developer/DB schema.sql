-- DROP TABLE market_history;

CREATE TABLE "market_history" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"timestamp" bigint NOT NULL,
	"quantity" double precision NOT NULL,
	"price" double precision NOT NULL,
	"total" double precision NOT NULL,
	"fill_type" text NOT NULL,
	"order_type" text NOT NULL
);
