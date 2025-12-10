-- 1. CENTRO
CREATE TABLE centro (
    id_centro       SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    direccion       VARCHAR(200) NOT NULL,
    telefono        VARCHAR(20),
    email           VARCHAR(100),
    ubicacion       VARCHAR(200)
);

-- 2. USUARIO (super-tabla de la herencia)
CREATE TABLE usuario (
    id_usuario      SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    apellido        VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    contraseña      VARCHAR(255) NOT NULL,
    rol             VARCHAR(20)  NOT NULL CHECK (rol IN ('NIÑO','TUTOR','EDUCADOR','ADMINISTRADOR')),
    telefono        VARCHAR(20),
    direccion       VARCHAR(200),
    fecha_alta      DATE DEFAULT CURRENT_DATE,
    activo          BOOLEAN DEFAULT TRUE,
    
    -- Cada usuario pertenece exactamente a un centro
    id_centro       INT NOT NULL,
    FOREIGN KEY (id_centro) REFERENCES centro(id_centro)
);

-- 3. NIÑO (especialización + entidad débil identificadora)
CREATE TABLE niño (
    id_usuario      INT PRIMARY KEY,  -- coincide con usuario.id_usuario
    fecha_nacimiento DATE NOT NULL,
    nivel_desarrollo VARCHAR(100),
    datos_medicos   TEXT,
    alergias        TEXT,
    autorizaciones_recogida TEXT,
    
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 4. TUTOR (especialización, sin atributos propios adicionales)
CREATE TABLE tutor (
    id_usuario      INT PRIMARY KEY,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 5. EDUCADOR (especialización)
CREATE TABLE educador (
    id_usuario      INT PRIMARY KEY,
    titulacion      VARCHAR(150),
    especialidad    VARCHAR(100),
    anios_experiencia INT CHECK (anios_experiencia >= 0),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 6. ADMINISTRADOR (especialización)
CREATE TABLE administrador (
    id_usuario      INT PRIMARY KEY,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 7. AULA
CREATE TABLE aula (
    id_aula             SERIAL PRIMARY KEY,
    nombre              VARCHAR(50) NOT NULL,
    nivel_edad          VARCHAR(50),
    capacidad_maxima    INT NOT NULL CHECK (capacidad_maxima > 0),
    edad_min            INT,
    edad_max            INT,
    
    -- Cada aula pertenece exactamente a un centro
    id_centro           INT NOT NULL,
    -- Cada aula tiene exactamente un educador responsable
    id_educador         INT NOT NULL,
    
    FOREIGN KEY (id_centro)   REFERENCES centro(id_centro),
    FOREIGN KEY (id_educador) REFERENCES educador(id_usuario),
    UNIQUE (nombre, id_centro)  -- opcional: evita aulas con mismo nombre en mismo centro
);

-- Relación pertenece: cada niño está en exactamente una aula
ALTER TABLE niño 
ADD COLUMN id_aula INT NOT NULL;
ALTER TABLE niño 
ADD FOREIGN KEY (id_aula) REFERENCES aula(id_aula);

-- 8. ACTIVIDAD
CREATE TABLE actividad (
    id_actividad    SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    descripcion     TEXT,
    fecha           DATE NOT NULL,
    hora            TIME NOT NULL,
    duracion_min    INT NOT NULL
);

-- Relación realiza (N:M con atributo grado)
CREATE TABLE niño_realiza_actividad (
    id_usuario      INT,
    id_actividad    INT,
    grado           VARCHAR(10),        -- ej: "Excelente", "Bueno", "A mejorar", o nota numérica
    PRIMARY KEY (id_usuario, id_actividad),
    FOREIGN KEY (id_usuario)   REFERENCES niño(id_usuario),
    FOREIGN KEY (id_actividad) REFERENCES actividad(id_actividad)
);

-- 9. AREA_DESARROLLO
CREATE TABLE area_desarrollo (
    id_area         SERIAL PRIMARY KEY,
    descripcion     VARCHAR(150) NOT NULL UNIQUE
);

-- Relación categoriza_en (N:M)
CREATE TABLE actividad_area_desarrollo (
    id_actividad    INT,
    id_area         INT,
    PRIMARY KEY (id_actividad, id_area),
    FOREIGN KEY (id_actividad) REFERENCES actividad(id_actividad),
    FOREIGN KEY (id_area)      REFERENCES area_desarrollo(id_area)
);

-- 10. FACTURA
CREATE TABLE factura (
    id_factura      SERIAL PRIMARY KEY,
    fecha           DATE NOT NULL DEFAULT CURRENT_DATE,
    importe         DECIMAL(10,2) NOT NULL,
    metodo_pago     VARCHAR(50),
    
    id_administrador INT NOT NULL,   -- quien la emite
    id_tutor         INT NOT NULL,   -- quien la paga
    
    FOREIGN KEY (id_administrador) REFERENCES administrador(id_usuario),
    FOREIGN KEY (id_tutor)         REFERENCES tutor(id_usuario)
);

-- 11. MENSAJE
CREATE TABLE mensaje (
    id_mensaje      SERIAL PRIMARY KEY,
    fecha_hora      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    contenido       TEXT NOT NULL,
    id_emisor       INT NOT NULL,
    id_receptor     INT NOT NULL,
    
    FOREIGN KEY (id_emisor)   REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_receptor) REFERENCES usuario(id_usuario)
);

-- Un niño puede tener varios tutores (madre, padre, tutor legal, etc.)
CREATE TABLE tutor_niño (
    id_tutor   INT REFERENCES tutor(id_usuario),
    id_niño    INT REFERENCES niño(id_usuario),
    parentesco VARCHAR(20) CHECK (parentesco IN ('madre','padre','tutor_legal','abuelo','otro')),
    PRIMARY KEY (id_tutor, id_niño, parentesco)
);
