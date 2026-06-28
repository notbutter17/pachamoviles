CREATE TYPE vehiculo_tipo   AS ENUM ('AUTO','MOTO','CAMIONETA');
CREATE TYPE espacio_estado  AS ENUM ('LIBRE','OCUPADO');

CREATE CAST (character varying AS vehiculo_tipo)  WITH INOUT AS IMPLICIT;
CREATE CAST (character varying AS espacio_estado) WITH INOUT AS IMPLICIT;

-- ── VEHÍCULOS ──────────────────────────────────────────────
CREATE TABLE vehiculos (
                           id         BIGSERIAL PRIMARY KEY,
                           placa      VARCHAR(20)   NOT NULL UNIQUE,
                           marca      VARCHAR(50)   NOT NULL,
                           modelo     VARCHAR(50)   NOT NULL,
                           color      VARCHAR(30),
                           tipo       vehiculo_tipo NOT NULL DEFAULT 'AUTO',
                           created_at TIMESTAMP     NOT NULL DEFAULT NOW()
);

-- ── ESPACIOS DE COCHERA ────────────────────────────────────
CREATE TABLE espacios_cochera (
                                  id         BIGSERIAL PRIMARY KEY,
                                  codigo     VARCHAR(10)    NOT NULL UNIQUE,
                                  ubicacion  VARCHAR(100),
                                  estado     espacio_estado NOT NULL DEFAULT 'LIBRE',
                                  created_at TIMESTAMP      NOT NULL DEFAULT NOW()
);

-- ── REGISTROS DE COCHERA (IN/OUT) ─────────────────────────
CREATE TABLE registros_cochera (
                                   id            BIGSERIAL PRIMARY KEY,
                                   vehiculo_id   BIGINT  NOT NULL REFERENCES vehiculos(id),
                                   espacio_id    BIGINT  NOT NULL REFERENCES espacios_cochera(id),
                                   usuario_id    BIGINT  NOT NULL REFERENCES usuarios(id),
                                   reserva_id    BIGINT  REFERENCES reservas(id),
                                   fecha_ingreso TIMESTAMP NOT NULL DEFAULT NOW(),
                                   fecha_salida  TIMESTAMP,
                                   observacion   TEXT,
                                   created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ── ÍNDICES ────────────────────────────────────────────────
CREATE INDEX idx_registros_cochera_vehiculo ON registros_cochera(vehiculo_id);
CREATE INDEX idx_registros_cochera_espacio  ON registros_cochera(espacio_id);
CREATE INDEX idx_registros_cochera_usuario  ON registros_cochera(usuario_id);
CREATE INDEX idx_registros_cochera_activos  ON registros_cochera(espacio_id) WHERE fecha_salida IS NULL;
