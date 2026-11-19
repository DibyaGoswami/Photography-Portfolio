CREATE TABLE photo (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug          text UNIQUE NOT NULL,
    title         text,
    description   text,
    status        text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
    taken_at      timestamptz,
    camera        text,
    lens          text,
    focal_mm      real,
    aperture      real,
    shutter_s     real,
    iso           int,
    width         int NOT NULL,
    height        int NOT NULL,
    original_key  text NOT NULL,
    placeholder   text,
    processed_at  timestamptz,
    created_at    timestamptz NOT NULL DEFAULT now(),
    published_at  timestamptz
);

CREATE TABLE photo_variant (
    photo_id  uuid REFERENCES photo(id) ON DELETE CASCADE,
    format    text CHECK (format IN ('avif','webp','jpeg')),
    width     int,
    key       text NOT NULL,
    PRIMARY KEY (photo_id, format, width)
);

CREATE TABLE palette_colour (
    photo_id   uuid REFERENCES photo(id) ON DELETE CASCADE,
    rank       smallint,
    hue        real NOT NULL CHECK (hue >= 0 AND hue < 360),
    chroma     real NOT NULL,
    lightness  real NOT NULL,
    weight     real NOT NULL CHECK (weight > 0 AND weight <= 1),
    hex        char(7) NOT NULL,
    PRIMARY KEY (photo_id, rank)
);
CREATE INDEX palette_hue_idx ON palette_colour (hue) WHERE chroma > 0.03;

CREATE TABLE collection (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    slug        text UNIQUE NOT NULL,
    title       text NOT NULL,
    description text,
    cover_photo uuid REFERENCES photo(id) ON DELETE SET NULL,
    position    int NOT NULL DEFAULT 0
);

CREATE TABLE collection_photo (
    collection_id uuid REFERENCES collection(id) ON DELETE CASCADE,
    photo_id      uuid REFERENCES photo(id) ON DELETE CASCADE,
    position      int NOT NULL,
    PRIMARY KEY (collection_id, photo_id)
);

CREATE TABLE comment (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id    uuid NOT NULL REFERENCES photo(id) ON DELETE CASCADE,
    author_name text NOT NULL,
    author_ref  text,
    body        text NOT NULL CHECK (length(body) <= 2000),
    status      text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
    ip_hash     text,
    created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX comment_photo_idx ON comment (photo_id, created_at) WHERE status = 'approved';