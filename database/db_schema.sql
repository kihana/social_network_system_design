CREATE TYPE "media_status" AS ENUM (
  'UPLOADING',
  'PROCESSING',
  'READY'
);

CREATE TABLE "users" (
  "id" integer PRIMARY KEY,
  "name" varchar,
  "created_at" timestamp,
  "updated_at" timestamp,
  "avatar" varchar
);

CREATE TABLE "locations" (
  "id" integer PRIMARY KEY,
  "name" varchar,
  "address" varchar,
  "description" varchar,
  "latitude" double,
  "longitude" double,
  "post_count" integer,
  "created_at" timestamp,
  "thumbnail" varchar
);

CREATE TABLE "subscriptions" (
  "follower_id" integer,
  "following_id" integer,
  "created_at" timestamp,
  PRIMARY KEY ("follower_id", "following_id")
);

CREATE TABLE "posts" (
  "id" integer PRIMARY KEY,
  "title" varchar,
  "body" text,
  "user_id" integer NOT NULL,
  "location_id" integer NOT NULL,
  "teaser_body" varchar,
  "teaser_thumbnail" varchar,
  "created_at" timestamp,
  "updated_at" timestamp,
  "like_count" integer,
  "comment_count" integer
);

CREATE TABLE "media" (
  "id" integer,
  "post_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "object_key" varchar,
  "content_type" varchar,
  "size" integer,
  "status" media_status,
  "checksum" blob,
  "created_at" timestamp
);

CREATE TABLE "likes" (
  "post_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "created_at" timestamp,
  PRIMARY KEY ("post_id", "user_id")
);

CREATE TABLE "comments" (
  "id" integer,
  "post_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "message" varchar,
  "reply_id" integer,
  "created_at" timestamp
);

COMMENT ON COLUMN "users"."avatar" IS 'S3 object_key for avatar of user';

COMMENT ON COLUMN "locations"."thumbnail" IS 'S3 object_key for thumbnail of location';

COMMENT ON COLUMN "posts"."body" IS 'Content of the post';

COMMENT ON COLUMN "posts"."teaser_thumbnail" IS 'S3 object_key for thumbnail of post teaser';

COMMENT ON COLUMN "media"."object_key" IS 'S3 object_key for image of post';

ALTER TABLE "posts" ADD CONSTRAINT "user_posts" FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "subscriptions" ADD FOREIGN KEY ("following_id") REFERENCES "users" ("id");

ALTER TABLE "subscriptions" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("id");

ALTER TABLE "posts" ADD FOREIGN KEY ("location_id") REFERENCES "locations" ("id");

ALTER TABLE "media" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "media" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "comments" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "comments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "likes" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "likes" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
