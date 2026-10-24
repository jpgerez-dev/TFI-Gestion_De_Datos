-- =====================================================================
-- UTN - Facultad Regional Tucumán | Gestión de Datos (GDD)
-- TRABAJO FINAL INTEGRADOR - Comisión 3k3 - Cuatrimestre 2023.01
-- Integrantes: Gerez Juan Pablo (53231) / Salazar Ana Carolina (52592)
--
-- Base de datos: TFI_GDD  (MySQL 8 / MariaDB)
-- Módulos: Compras, Ventas, RRHH y Liquidación de Haberes
--
-- Uso:  mysql -u root -p < TFI_GDD.sql
-- Nota: el script borra y vuelve a crear la base TFI_GDD, así que se
--       puede ejecutar todas las veces que haga falta.
-- =====================================================================

DROP DATABASE IF EXISTS TFI_GDD;
CREATE DATABASE TFI_GDD CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE TFI_GDD;

-- El modelo tiene referencias circulares (proveedor <-> direccion,
-- factura <-> pago, stock <-> deposito), por eso se desactivan los
-- controles de FK mientras se crean las tablas y se cargan los datos.
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
-- 1) TABLAS COMUNES / COMPRAS / VENTAS
-- =====================================================================

CREATE TABLE sector (
    Id_sector   INT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(100),
    PRIMARY KEY (Id_sector)
);

CREATE TABLE rubro (
    Id_rubro     INT NOT NULL AUTO_INCREMENT,
    Id_sector    INT,
    Id_direccion INT,
    Nombre       VARCHAR(100),
    PRIMARY KEY (Id_rubro),
    FOREIGN KEY (Id_sector)    REFERENCES sector (Id_sector),
    FOREIGN KEY (Id_direccion) REFERENCES direccion (Id_direccion)
);

CREATE TABLE direccion (
    Id_direccion  INT NOT NULL AUTO_INCREMENT,
    Id_proveedor  INT,
    Id_cliente    INT,
    calle         VARCHAR(100),
    numero        INT,
    provincia     VARCHAR(100),
    localidad     VARCHAR(100),
    codigo_postal INT,
    pais          VARCHAR(100),
    PRIMARY KEY (Id_direccion),
    FOREIGN KEY (Id_proveedor) REFERENCES proveedor (Id_proveedor),
    FOREIGN KEY (Id_cliente)   REFERENCES cliente (Id_cliente)
);

CREATE TABLE sucursal (
    Id_sucursal  INT NOT NULL AUTO_INCREMENT,
    Id_direccion INT,
    Nombre       VARCHAR(100),
    PRIMARY KEY (Id_sucursal),
    FOREIGN KEY (Id_direccion) REFERENCES direccion (Id_direccion)
);

CREATE TABLE cliente (
    Id_cliente   INT NOT NULL AUTO_INCREMENT,
    Id_rubro     INT,
    Credito      INT,
    Ranking      INT,
    RazonSocial  VARCHAR(100),
    Fecha_Alta   DATE,
    CUIT         INT,
    Telefono     VARCHAR(20),
    Mail         VARCHAR(100),
    PRIMARY KEY (Id_cliente),
    FOREIGN KEY (Id_rubro) REFERENCES rubro (Id_rubro)
);

CREATE TABLE proveedor (
    Id_proveedor INT NOT NULL AUTO_INCREMENT,
    Id_direccion INT,
    Id_rubro     INT,
    RazonSocial  VARCHAR(100),
    CUIT         INT,
    Fecha_alta   DATE,
    Ranking      INT,
    Credito      INT,
    Telefono     VARCHAR(20),
    Mail         VARCHAR(100),
    PRIMARY KEY (Id_proveedor),
    FOREIGN KEY (Id_direccion) REFERENCES direccion (Id_direccion),
    FOREIGN KEY (Id_rubro)     REFERENCES rubro (Id_rubro)
);

CREATE TABLE articulo (
    Id_articulo INT NOT NULL AUTO_INCREMENT,
    Id_rubro    INT,
    descripcion VARCHAR(100),
    precio      DOUBLE,
    codigo      INT,
    PRIMARY KEY (Id_articulo),
    FOREIGN KEY (Id_rubro) REFERENCES rubro (Id_rubro)
);

CREATE TABLE stock (
    Id_stock          INT NOT NULL AUTO_INCREMENT,
    Id_articulo       INT,
    Id_rubro          INT,
    Id_deposito       INT,
    cantidad_articulo INT,
    stock_seguridad   INT,
    PRIMARY KEY (Id_stock),
    FOREIGN KEY (Id_articulo) REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_rubro)    REFERENCES rubro (Id_rubro),
    FOREIGN KEY (Id_deposito) REFERENCES deposito (Id_deposito)
);

CREATE TABLE deposito (
    Id_deposito  INT NOT NULL AUTO_INCREMENT,
    Id_articulo  INT,
    Id_sucursal  INT,
    Id_stock     INT,
    Id_direccion INT,
    valoracion   VARCHAR(100),
    Nombre       VARCHAR(100),
    PRIMARY KEY (Id_deposito),
    FOREIGN KEY (Id_articulo)  REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_sucursal)  REFERENCES sucursal (Id_sucursal),
    FOREIGN KEY (Id_stock)     REFERENCES stock (Id_stock),
    FOREIGN KEY (Id_direccion) REFERENCES direccion (Id_direccion)
);

CREATE TABLE remito (
    Id_remito   INT NOT NULL AUTO_INCREMENT,
    Id_articulo INT,
    Id_deposito INT,
    Fecha       DATE,
    observacion VARCHAR(100),
    descripcion VARCHAR(100),
    PRIMARY KEY (Id_remito),
    FOREIGN KEY (Id_articulo) REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_deposito) REFERENCES deposito (Id_deposito)
);

CREATE TABLE pago (
    Id_pago     INT NOT NULL AUTO_INCREMENT,
    Id_factura  INT,
    precio      DOUBLE,
    descripcion VARCHAR(100),
    PRIMARY KEY (Id_pago),
    FOREIGN KEY (Id_factura) REFERENCES factura (Id_factura)
);

CREATE TABLE forma_pago (
    Id_forma_pago INT NOT NULL AUTO_INCREMENT,
    Id_pago       INT,
    Id_factura    INT,
    condicion     VARCHAR(100),
    PRIMARY KEY (Id_forma_pago),
    FOREIGN KEY (Id_pago)    REFERENCES pago (Id_pago),
    FOREIGN KEY (Id_factura) REFERENCES factura (Id_factura)
);

CREATE TABLE orden_compra (
    Id_orden_compra INT NOT NULL AUTO_INCREMENT,
    Id_sector       INT,
    Id_pago         INT,
    Id_articulo     INT,
    Id_proveedor    INT,
    Id_deposito     INT,
    Id_forma_pago   INT,
    estado          VARCHAR(100),
    Fecha           DATE,
    Precio          DOUBLE,
    PRIMARY KEY (Id_orden_compra),
    FOREIGN KEY (Id_sector)     REFERENCES sector (Id_sector),
    FOREIGN KEY (Id_pago)       REFERENCES pago (Id_pago),
    FOREIGN KEY (Id_articulo)   REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_proveedor)  REFERENCES proveedor (Id_proveedor),
    FOREIGN KEY (Id_deposito)   REFERENCES deposito (Id_deposito),
    FOREIGN KEY (Id_forma_pago) REFERENCES forma_pago (Id_forma_pago)
);

CREATE TABLE factura (
    Id_factura      INT NOT NULL AUTO_INCREMENT,
    Id_sector       INT,
    Id_pago         INT,
    Id_orden_compra INT,
    Id_proveedor    INT,
    Id_deposito     INT,
    Id_forma_pago   INT,
    Id_remito       INT,
    importeBruto    INT,
    neto            INT,
    IVA             DOUBLE,
    Fecha           DATE,
    descripcion     VARCHAR(100),
    PRIMARY KEY (Id_factura),
    FOREIGN KEY (Id_sector)       REFERENCES sector (Id_sector),
    FOREIGN KEY (Id_pago)         REFERENCES pago (Id_pago),
    FOREIGN KEY (Id_orden_compra) REFERENCES orden_compra (Id_orden_compra),
    FOREIGN KEY (Id_proveedor)    REFERENCES proveedor (Id_proveedor),
    FOREIGN KEY (Id_deposito)     REFERENCES deposito (Id_deposito),
    FOREIGN KEY (Id_forma_pago)   REFERENCES forma_pago (Id_forma_pago),
    FOREIGN KEY (Id_remito)       REFERENCES remito (Id_remito)
);

CREATE TABLE pedido (
    Id_pedido         INT NOT NULL AUTO_INCREMENT,
    Id_articulo       INT,
    Id_orden_compra   INT,
    Id_sector         INT,
    cantidad_articulo INT,
    PRIMARY KEY (Id_pedido),
    FOREIGN KEY (Id_articulo)     REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_orden_compra) REFERENCES orden_compra (Id_orden_compra),
    FOREIGN KEY (Id_sector)       REFERENCES sector (Id_sector)
);

CREATE TABLE cotizacion (
    Id_cotizacion   INT NOT NULL AUTO_INCREMENT,
    Id_orden_compra INT,
    Id_sector       INT,
    Id_proveedor    INT,
    Id_pedido       INT,
    descripcion     VARCHAR(100),
    precio          DOUBLE,
    PRIMARY KEY (Id_cotizacion),
    FOREIGN KEY (Id_orden_compra) REFERENCES orden_compra (Id_orden_compra),
    FOREIGN KEY (Id_sector)       REFERENCES sector (Id_sector),
    FOREIGN KEY (Id_proveedor)    REFERENCES proveedor (Id_proveedor),
    FOREIGN KEY (Id_pedido)       REFERENCES pedido (Id_pedido)
);

CREATE TABLE linea_orden_compra (
    Id_linea_orden    INT NOT NULL AUTO_INCREMENT,
    Id_articulo       INT,
    Id_orden_compra   INT,
    subtotal          DOUBLE,
    cantidad_articulo INT,
    PRIMARY KEY (Id_linea_orden),
    FOREIGN KEY (Id_articulo)     REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_orden_compra) REFERENCES orden_compra (Id_orden_compra)
);

CREATE TABLE linea_factura (
    Id_linea_factura INT NOT NULL AUTO_INCREMENT,
    Id_articulo      INT,
    Id_factura       INT,
    Id_rubro         INT,
    total            DOUBLE,
    PRIMARY KEY (Id_linea_factura),
    FOREIGN KEY (Id_articulo) REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_factura)  REFERENCES factura (Id_factura),
    FOREIGN KEY (Id_rubro)    REFERENCES rubro (Id_rubro)
);

-- ---------------------------------------------------------------------
-- RRHH / Liquidación (se crean antes de orden_venta por la FK a empleado)
-- ---------------------------------------------------------------------

CREATE TABLE empleado (
    Id_empleado INT NOT NULL AUTO_INCREMENT,
    Id_rubro    INT,
    Credito     INT,
    Ranking     INT,
    RazonSocial VARCHAR(100),
    Legajo      INT,
    CUIL        INT,
    PRIMARY KEY (Id_empleado),
    FOREIGN KEY (Id_rubro) REFERENCES rubro (Id_rubro)
);

CREATE TABLE orden_venta (
    Id_orden_venta    INT NOT NULL AUTO_INCREMENT,
    Id_cliente        INT,
    Id_articulo       INT,
    Id_factura        INT,
    Id_empleado       INT,
    Id_sucursal       INT,
    cantidad_articulo INT,
    precio            DOUBLE,
    estado            VARCHAR(100),
    fecha             DATE,
    PRIMARY KEY (Id_orden_venta),
    FOREIGN KEY (Id_cliente)  REFERENCES cliente (Id_cliente),
    FOREIGN KEY (Id_articulo) REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_factura)  REFERENCES factura (Id_factura),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado),
    FOREIGN KEY (Id_sucursal) REFERENCES sucursal (Id_sucursal)
);

-- Tablas intermedias (relaciones N:M del diagrama de Ventas)
CREATE TABLE articulo_rubro (
    Id_articulo INT NOT NULL,
    Id_rubro    INT NOT NULL,
    PRIMARY KEY (Id_articulo, Id_rubro),
    FOREIGN KEY (Id_articulo) REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_rubro)    REFERENCES rubro (Id_rubro)
);

CREATE TABLE articulo_stock (
    Id_articulo INT NOT NULL,
    Id_stock    INT NOT NULL,
    PRIMARY KEY (Id_articulo, Id_stock),
    FOREIGN KEY (Id_articulo) REFERENCES articulo (Id_articulo),
    FOREIGN KEY (Id_stock)    REFERENCES stock (Id_stock)
);

CREATE TABLE stock_deposito (
    Id_stock    INT NOT NULL,
    Id_deposito INT NOT NULL,
    PRIMARY KEY (Id_stock, Id_deposito),
    FOREIGN KEY (Id_stock)    REFERENCES stock (Id_stock),
    FOREIGN KEY (Id_deposito) REFERENCES deposito (Id_deposito)
);

CREATE TABLE orden_venta_sucursal (
    Id_orden_venta INT NOT NULL,
    Id_sucursal    INT NOT NULL,
    PRIMARY KEY (Id_orden_venta, Id_sucursal),
    FOREIGN KEY (Id_orden_venta) REFERENCES orden_venta (Id_orden_venta),
    FOREIGN KEY (Id_sucursal)    REFERENCES sucursal (Id_sucursal)
);

-- =====================================================================
-- 2) RRHH
-- =====================================================================

CREATE TABLE persona (
    Id_persona       INT NOT NULL AUTO_INCREMENT,
    Id_direccion     INT,
    Id_empleado      INT,
    Id_cliente       INT,
    Id_rubro         INT,
    Nombre           VARCHAR(100),
    Apellido         VARCHAR(100),
    Dni              INT,
    Fecha_Nacimiento DATE,
    Lugar_Nacimiento VARCHAR(100),
    Telefono         INT,
    Mail             VARCHAR(100),
    Edad             INT,
    PRIMARY KEY (Id_persona),
    FOREIGN KEY (Id_direccion) REFERENCES direccion (Id_direccion),
    FOREIGN KEY (Id_empleado)  REFERENCES empleado (Id_empleado),
    FOREIGN KEY (Id_cliente)   REFERENCES cliente (Id_cliente),
    FOREIGN KEY (Id_rubro)     REFERENCES rubro (Id_rubro)
);

CREATE TABLE grupo_familiar (
    Id_GF       INT NOT NULL AUTO_INCREMENT,
    Id_empleado INT,
    Create_Ad   INT,
    PRIMARY KEY (Id_GF),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado)
);

CREATE TABLE grupo_familiar_persona (
    Id_GF_persona INT NOT NULL AUTO_INCREMENT,
    Id_GF         INT,
    Id_persona    INT,
    Create_Ad     INT,
    PRIMARY KEY (Id_GF_persona),
    FOREIGN KEY (Id_GF)      REFERENCES grupo_familiar (Id_GF),
    FOREIGN KEY (Id_persona) REFERENCES persona (Id_persona)
);

CREATE TABLE antiguedad (
    Id_antiguedad INT NOT NULL AUTO_INCREMENT,
    Id_empleado   INT,
    Cant_Anios    INT,
    PRIMARY KEY (Id_antiguedad),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado)
);

CREATE TABLE puesto_trabajo (
    Id_puesto_trabajo  INT NOT NULL AUTO_INCREMENT,
    Id_empleado        INT,
    Nombre             VARCHAR(100),
    Categoria_Salarial VARCHAR(100),
    Anio               INT,
    PRIMARY KEY (Id_puesto_trabajo),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado)
);

CREATE TABLE empleado_puesto_trabajo (
    Id_empleado       INT NOT NULL,
    Id_puesto_trabajo INT NOT NULL,
    PRIMARY KEY (Id_empleado, Id_puesto_trabajo),
    FOREIGN KEY (Id_empleado)       REFERENCES empleado (Id_empleado),
    FOREIGN KEY (Id_puesto_trabajo) REFERENCES puesto_trabajo (Id_puesto_trabajo)
);

CREATE TABLE titulo (
    Id_titulo        INT NOT NULL AUTO_INCREMENT,
    Nombre           VARCHAR(100),
    Fecha_Ingreso    DATE,
    Fecha_Graduacion DATE,
    PRIMARY KEY (Id_titulo)
);

CREATE TABLE tipo_titulo (
    Id_tipo_titulo INT NOT NULL AUTO_INCREMENT,
    Id_titulo      INT,
    descripcion    VARCHAR(100),
    PRIMARY KEY (Id_tipo_titulo),
    FOREIGN KEY (Id_titulo) REFERENCES titulo (Id_titulo)
);

CREATE TABLE curso (
    Id_curso    INT NOT NULL AUTO_INCREMENT,
    Id_empleado INT,
    Nombre      VARCHAR(100),
    Lugar       VARCHAR(100),
    Idioma      VARCHAR(100),
    Fecha       DATE,
    Codigo      INT,
    Duracion    INT,
    PRIMARY KEY (Id_curso),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado)
);

CREATE TABLE accidente (
    Id_accidente INT NOT NULL AUTO_INCREMENT,
    Fecha        DATE,
    descripcion  VARCHAR(100),
    Codigo       INT,
    PRIMARY KEY (Id_accidente)
);

CREATE TABLE empleado_accidente (
    Id_empleado  INT NOT NULL,
    Id_accidente INT NOT NULL,
    PRIMARY KEY (Id_empleado, Id_accidente),
    FOREIGN KEY (Id_empleado)  REFERENCES empleado (Id_empleado),
    FOREIGN KEY (Id_accidente) REFERENCES accidente (Id_accidente)
);

CREATE TABLE revision (
    Id_revision          INT NOT NULL AUTO_INCREMENT,
    Id_empleado          INT,
    Estatura             INT,
    Coeficiente_auditivo VARCHAR(100),
    IMC                  INT,
    Electrocardiograma   VARCHAR(100),
    Presion              VARCHAR(100),
    Sexo                 VARCHAR(100),
    Peso                 INT,
    TipoyFactor_Sangre   VARCHAR(100),
    PRIMARY KEY (Id_revision),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado)
);

CREATE TABLE analisis (
    Id_analisis INT NOT NULL AUTO_INCREMENT,
    Id_revision INT,
    descripcion VARCHAR(100),
    PRIMARY KEY (Id_analisis),
    FOREIGN KEY (Id_revision) REFERENCES revision (Id_revision)
);

CREATE TABLE salario (
    Id_salario    INT NOT NULL AUTO_INCREMENT,
    Id_persona    INT,
    Cant_hijos    INT,
    Recibo_Sueldo INT,
    Estado_Civil  VARCHAR(100),
    Familiar      INT,
    PRIMARY KEY (Id_salario),
    FOREIGN KEY (Id_persona) REFERENCES persona (Id_persona)
);

CREATE TABLE departamento (
    Id_departamento INT NOT NULL AUTO_INCREMENT,
    Id_empleado     INT,
    Localidad       VARCHAR(100),
    Telefono        INT,
    CUIL            INT,
    Categoria       VARCHAR(100),
    Mail            VARCHAR(100),
    Nombre          VARCHAR(100),
    PRIMARY KEY (Id_departamento),
    FOREIGN KEY (Id_empleado) REFERENCES empleado (Id_empleado)
);

CREATE TABLE area (
    Id_area         INT NOT NULL AUTO_INCREMENT,
    Id_empleado     INT,
    Id_departamento INT,
    Fecha_Ingreso   DATE,
    Fecha_Egreso    DATE,
    PRIMARY KEY (Id_area),
    FOREIGN KEY (Id_empleado)     REFERENCES empleado (Id_empleado),
    FOREIGN KEY (Id_departamento) REFERENCES departamento (Id_departamento)
);

CREATE TABLE salario_area (
    Id_salario INT NOT NULL,
    Id_area    INT NOT NULL,
    PRIMARY KEY (Id_salario, Id_area),
    FOREIGN KEY (Id_salario) REFERENCES salario (Id_salario),
    FOREIGN KEY (Id_area)    REFERENCES area (Id_area)
);

-- =====================================================================
-- 3) LIQUIDACIÓN DE HABERES
-- =====================================================================

CREATE TABLE liquidacion (
    Id_liquidacion    INT NOT NULL AUTO_INCREMENT,
    Id_empleado       INT,
    Id_puesto_trabajo INT,
    Numero            VARCHAR(50),
    Total             DOUBLE,
    PRIMARY KEY (Id_liquidacion),
    FOREIGN KEY (Id_empleado)       REFERENCES empleado (Id_empleado),
    FOREIGN KEY (Id_puesto_trabajo) REFERENCES puesto_trabajo (Id_puesto_trabajo)
);

CREATE TABLE concepto (
    Id_concepto INT NOT NULL AUTO_INCREMENT,
    Monto       DOUBLE,
    PRIMARY KEY (Id_concepto)
);

CREATE TABLE detalle_liquidacion (
    Id_detalle_liquidacion INT NOT NULL AUTO_INCREMENT,
    Id_liquidacion         INT,
    Id_concepto            INT,
    Bono                   INT,
    Premio                 INT,
    Fecha_Despido          DATE,
    Descuento              DOUBLE,
    Duracion_Vacaciones    INT,
    SAC                    DOUBLE,
    PRIMARY KEY (Id_detalle_liquidacion),
    FOREIGN KEY (Id_liquidacion) REFERENCES liquidacion (Id_liquidacion),
    FOREIGN KEY (Id_concepto)    REFERENCES concepto (Id_concepto)
);


-- =====================================================================
-- 4) CARGA DE DATOS
-- =====================================================================

-- ----- Sector -----
INSERT INTO sector (descripcion) VALUES
 ('Compras'), ('Ventas'), ('RR.HH'), ('Tesoreria');

-- ----- Dirección (clientes, proveedores, sucursales, depósitos, rubros) -----
INSERT INTO direccion (Id_proveedor, Id_cliente, calle, numero, provincia, localidad, codigo_postal, pais) VALUES
 (1, 1, 'San Martin',      560, 'Tucumán', 'S.M. Tucumán', 4000, 'Argentina'),
 (2, 2, 'Mendoza',         800, 'Tucumán', 'S.M. Tucumán', 4000, 'Argentina'),
 (3, 3, '24 de Septiembre',463, 'Tucumán', 'S.M. Tucumán', 4000, 'Argentina'),
 (4, 4, 'Muñecas',         375, 'Tucumán', 'S.M. Tucumán', 4000, 'Argentina');

-- ----- Rubro -----
INSERT INTO rubro (Id_sector, Id_direccion, Nombre) VALUES
 (1, 1, 'Caño para agua'),
 (2, 2, 'Cemento'),
 (3, 3, 'Pegamento'),
 (4, 4, 'Electricidad');

-- ----- Sucursal -----
INSERT INTO sucursal (Id_direccion, Nombre) VALUES
 (1, 'CENTRO'), (2, 'YERBA BUENA'), (3, 'TAFI VIEJO'), (4, 'LAS TALITAS');

-- ----- Cliente -----
INSERT INTO cliente (Id_rubro, Credito, Ranking, RazonSocial, Fecha_Alta, CUIT, Telefono, Mail) VALUES
 (1, 200000, 5, 'Grandes Ventas',      '2021-04-14', 154623, '3815550101', 'contacto@grandesventas.example.com'),
 (2, 300000, 6, 'Las Mejores Marcas',  '2020-04-14', 147852, '3815550102', 'contacto@mejoresmarcas.example.com'),
 (3, 150000, 4, 'Ferreteria Daniel',   '2022-06-25', 369852, '3815550103', 'contacto@ferreteriadaniel.example.com'),
 (4, 250000, 3, 'Kapo',                '2021-04-14', 154623, '3815550104', 'contacto@kapo.example.com');

-- ----- Proveedor -----
INSERT INTO proveedor (Id_direccion, Id_rubro, RazonSocial, CUIT, Fecha_alta, Ranking, Credito, Telefono, Mail) VALUES
 (1, 1, 'Herramientas Jose',  23441221, '2021-01-30', 2, 200000, '3815550201', 'ventas@herramientasjose.example.com'),
 (2, 2, 'Lucena',             23411221, '2020-08-06', 3, 150000, '3815550202', 'ventas@lucena.example.com'),
 (3, 3, 'Tucumán Alambres',   23421221, '2021-04-13', 4, 100000, '3815550203', 'ventas@tucumanalambres.example.com'),
 (4, 4, 'Corralón el Amigo',  23481221, '2020-02-12', 1, 300000, '3815550204', 'ventas@corralonelamigo.example.com');

-- ----- Artículo -----
INSERT INTO articulo (Id_rubro, descripcion, precio, codigo) VALUES
 (1, 'caños',                5000,  1),
 (2, 'bolsa de cemento',     2637,  1100),
 (3, 'arena fina',           10500, 10),
 (4, 'pegamento para caños', 2800,  100);

-- ----- Stock (cantidades del TFI; stock_seguridad: 300 y 780 surgen del resultado
--       del punto 2.a del PDF, los otros dos valores son de relleno) -----
INSERT INTO stock (Id_articulo, Id_rubro, Id_deposito, cantidad_articulo, stock_seguridad) VALUES
 (1, 1, 1, 1500, 300),
 (2, 2, 2,  500, 150),
 (3, 3, 3, 1000, 250),
 (4, 4, 4, 2000, 780);

-- ----- Depósito -----
INSERT INTO deposito (Id_articulo, Id_sucursal, Id_stock, Id_direccion, valoracion, Nombre) VALUES
 (1, 1, 1, 1, '7500000', 'Deposito1'),
 (2, 2, 2, 2, '1318500', 'Deposito2'),
 (3, 3, 3, 3, '1050000', 'Deposito3'),
 (4, 4, 4, 4, '7500000', 'Deposito4');

-- ----- Remito -----
INSERT INTO remito (Id_articulo, Id_deposito, Fecha, observacion, descripcion) VALUES
 (1, 1, '2020-09-11', 'Ninguna',                          'caños, bolsas de cemento, bolsas de arena fina'),
 (2, 2, '2019-01-01', 'Daños en una bolsa de arena fina', 'bolsas de arena fina, bolsas de cemento'),
 (3, 3, '2018-08-30', 'Ninguna',                          'Cables Unipolares, caños de agua'),
 (4, 4, '2017-03-12', 'Cable cortado',                    '1 metro Cable Unipolar');

-- ----- Pago -----
INSERT INTO pago (Id_factura, precio, descripcion) VALUES
 (1, 100000, '2018-07-30'),
 (2, 150000, '2019-01-01'),
 (3, 200000, '2020-09-11'),
 (4, 250000, '2013-05-25');

-- ----- Forma de pago -----
INSERT INTO forma_pago (Id_pago, Id_factura, condicion) VALUES
 (1, 1, 'Efectivo'),
 (2, 2, 'Tarjeta de crédito'),
 (3, 3, 'Tarjeta de débito'),
 (4, 4, 'e-cheq');

-- ----- Orden de compra -----
INSERT INTO orden_compra (Id_sector, Id_pago, Id_articulo, Id_proveedor, Id_deposito, Id_forma_pago, estado, Fecha, Precio) VALUES
 (1, 1, 1, 1, 1, 1, 'pagado',         '2020-09-11', 158000),
 (2, 2, 2, 2, 2, 2, 'esperando pago', '2019-01-01', 138250),
 (3, 3, 3, 3, 3, 3, 'pagado',         '2018-08-30', 118500),
 (4, 4, 4, 4, 4, 4, 'esperando pago', '2017-03-02',  98750);

-- ----- Factura (las facturas 5 a 8 no tenían ids de relación en el script
--       original; se asignan con el mismo criterio 1..4) -----
INSERT INTO factura (Id_sector, Id_pago, Id_orden_compra, Id_proveedor, Id_deposito, Id_forma_pago, Id_remito, importeBruto, neto, IVA, Fecha, descripcion) VALUES
 (1, 1,    1, 1, 1, 1, 1,  25000,  3000, 0.21, '2013-05-25', '058-005'),
 (2, 2,    2, 2, 2, 2, 2,  50000,  4000, 0.21, '2014-06-08', '963-214'),
 (3, 3,    3, 3, 3, 3, 3,  75000,  3500, 0.21, '2015-08-10', '852-741'),
 (4, 4,    4, 4, 4, 4, 4, 100000,  5000, 0.21, '2016-04-17', '789-456'),
 (1, NULL, 1, 1, 1, 1, 1, 125000,  4500, 0.21, '2017-03-02', '654-123'),
 (2, NULL, 2, 2, 2, 2, 2, 150000,  6000, 0.21, '2018-07-30', '258-214'),
 (3, NULL, 3, 3, 3, 3, 3, 175000,  6500, 0.21, '2019-01-01', '321-689'),
 (4, NULL, 4, 4, 4, 4, 4, 200000, 15000, 0.21, '2020-09-11', '346-927');

-- ----- Pedido -----
INSERT INTO pedido (Id_articulo, Id_orden_compra, Id_sector, cantidad_articulo) VALUES
 (1, 1, 1,  10),
 (2, 2, 2,  15),
 (3, 3, 3,  20),
 (4, 4, 4, 100);

-- ----- Cotización -----
INSERT INTO cotizacion (Id_orden_compra, Id_sector, Id_proveedor, Id_pedido, descripcion, precio) VALUES
 (1, 1, 1, 1, 'bolsas de cemento',     100000),
 (2, 2, 2, 2, 'bolsas de arena',        50000),
 (3, 3, 3, 3, 'pegamento para caños',   70000),
 (4, 4, 4, 4, 'cable Unipolar',        150000);

-- ----- Línea de orden de compra -----
INSERT INTO linea_orden_compra (Id_articulo, Id_orden_compra, subtotal, cantidad_articulo) VALUES
 (1, 1, 100000,  10),
 (2, 2, 150000,  15),
 (3, 3, 200000,  20),
 (4, 4, 250000, 100);

-- ----- Línea de factura -----
INSERT INTO linea_factura (Id_articulo, Id_factura, Id_rubro, total) VALUES
 (1, 1, 1, 150000),
 (2, 2, 2, 200000),
 (3, 3, 3, 250000),
 (4, 4, 4, 300000);

-- ----- Empleado -----
INSERT INTO empleado (Id_rubro, Credito, Ranking, RazonSocial, Legajo, CUIL) VALUES
 (1,  25000, 5, '25864', 52592, 23156789),
 (2, 250000, 3, '36981', 52534, 20732589),
 (3, 150000, 1, '25864', 52564, 45961331),
 (4,  50000, 4, '14527', 52578, 43706736);

-- ----- Orden de venta -----
INSERT INTO orden_venta (Id_cliente, Id_articulo, Id_empleado, Id_sucursal, cantidad_articulo, precio, estado, fecha) VALUES
 (1, 1, 1, 1,  10, 100000, 'En proceso', '2021-01-30'),
 (2, 2, 2, 2,  15, 200000, 'Pagado',     '2020-09-11'),
 (3, 3, 3, 3,  20, 250000, 'En proceso', '2019-01-01'),
 (4, 4, 4, 4, 100, 300000, 'Pagado',     '2022-03-02');

-- ----- Tablas intermedias (derivadas de las FK de las tablas anteriores) -----
INSERT INTO articulo_rubro (Id_articulo, Id_rubro) VALUES (1,1),(2,2),(3,3),(4,4);
INSERT INTO articulo_stock (Id_articulo, Id_stock) VALUES (1,1),(2,2),(3,3),(4,4);
INSERT INTO stock_deposito (Id_stock, Id_deposito) VALUES (1,1),(2,2),(3,3),(4,4);
INSERT INTO orden_venta_sucursal (Id_orden_venta, Id_sucursal) VALUES (1,1),(2,2),(3,3),(4,4);

-- ----- Persona (1 a 4: empleados; 5 a 8: familiares agregados para el punto 2.b) -----
INSERT INTO persona (Id_direccion, Id_empleado, Id_cliente, Id_rubro, Nombre, Apellido, Dni, Fecha_Nacimiento, Lugar_Nacimiento, Telefono, Mail, Edad) VALUES
 (1, 1, 1, 1, 'Carolina',   'Salazar', 43706736, '2002-04-17', 'S.M. Tucumán', 381356,  'csalazar@gmail.com',      21),
 (2, 2, 2, 2, 'Juan Pablo', 'Gerez',   23156789, '2003-07-26', 'S.M. Tucumán', 3813546, 'juampygerez@gmail.com',  20),
 (3, 3, 3, 3, 'Manuel',     'Perez',   20732589, '2000-08-23', 'S.M. Tucumán', 381587,  'manuperez@gmail.com',    22),
 (4, 4, 4, 4, 'Celeste',    'Gomez',   20732589, '2000-09-22', 'S.M. Tucumán', 381512,  'celegomez@gmail.com',    21),
 (NULL, NULL, NULL, NULL, 'Laura',  'Rios',  NULL, NULL, NULL, NULL, NULL, NULL),
 (NULL, NULL, NULL, NULL, 'Sofía',  'Diaz',  NULL, NULL, NULL, NULL, NULL, NULL),
 (NULL, NULL, NULL, NULL, 'Pedro',  'Luna',  NULL, NULL, NULL, NULL, NULL, NULL),
 (NULL, NULL, NULL, NULL, 'Ana',    'Torres',NULL, NULL, NULL, NULL, NULL, NULL);

-- ----- Grupo familiar -----
INSERT INTO grupo_familiar (Id_empleado, Create_Ad) VALUES (1,10),(2,5),(3,8),(4,7);
INSERT INTO grupo_familiar_persona (Id_GF, Id_persona, Create_Ad) VALUES (1,5,10),(2,6,5),(3,7,8),(4,8,7);

-- ----- Antigüedad -----
INSERT INTO antiguedad (Id_empleado, Cant_Anios) VALUES (1,5),(2,20),(3,9),(4,2);

-- ----- Puesto de trabajo -----
INSERT INTO puesto_trabajo (Id_empleado, Nombre, Categoria_Salarial, Anio) VALUES
 (1, 'Vendedor',   'Mensual',     2020),
 (2, 'Cajero',     'Operacional', 2021),
 (3, 'Gerente',    'Jerárquico',  2022),
 (4, 'Supervisor', 'Operacional', 2000);

INSERT INTO empleado_puesto_trabajo (Id_empleado, Id_puesto_trabajo) VALUES (1,1),(2,2),(3,3),(4,4);

-- ----- Título -----
INSERT INTO titulo (Nombre, Fecha_Ingreso, Fecha_Graduacion) VALUES
 ('Ingeniero en Sistemas',    '2017-04-30', '2022-12-21'),
 ('Administrador de Empresas','2015-05-31', '2020-08-11'),
 ('Contador',                 '2013-04-29', '2018-12-19'),
 ('Enfermero',                '2011-07-21', '2020-12-05');

INSERT INTO tipo_titulo (Id_titulo, descripcion) VALUES
 (1,'Universitario'),(2,'Universitario'),(3,'Universitario'),(4,'Universitario');

-- ----- Curso -----
INSERT INTO curso (Id_empleado, Nombre, Lugar, Idioma, Fecha, Codigo, Duracion) VALUES
 (1, 'ATICANA',         'Escuela de ingles',  'Ingles',  '2020-04-29', 52548, 12),
 (2, 'AF Alliance',     'Escuela de frances', 'Frances', '2019-04-29', 45961,  6),
 (3, 'Curso de Idioma', 'Online',             'Aleman',  '2021-06-07', 43706,  4),
 (4, 'Platzi',          'Online',             'Inglés',  '2018-06-02', 12412,  6);

-- ----- Accidente -----
INSERT INTO accidente (Fecha, descripcion, Codigo) VALUES
 ('2020-05-24', 'Accidente en el trabajo moviendo caños',          52364),
 ('2021-02-17', 'Accidente Automovilístico Llegando a la sucursal', 51241),
 ('2022-03-28', 'Intoxicación',                                     5223),
 ('2023-01-19', 'Heridas de gravedad',                              53124);

-- ----- Revisión médica y análisis -----
INSERT INTO revision (Id_empleado, Estatura, Coeficiente_auditivo, IMC, Electrocardiograma, Presion, Sexo, Peso, TipoyFactor_Sangre) VALUES
 (1, 170, 'Apto', 19, 'Normal',  'Normal', 'Masculino', 55, 'A+'),
 (2, 165, 'Apto', 22, 'Normal',  'Normal', 'Femenino',  60, '0+'),
 (3, 185, 'Apto', 24, 'Normal',  'Normal', 'Masculino', 82, 'RH-'),
 (4, 190, 'Apto', 21, 'Mediano', 'Normal', 'Masculino', 55, 'AB+');

INSERT INTO analisis (Id_revision, descripcion) VALUES
 (1, 'Todo Normal. Está apto para trabajar'),
 (2, 'Todo Normal. Está apto para trabajar'),
 (3, 'Todo Normal. Está apto para trabajar'),
 (4, 'No apto para trabajar');

-- ----- Salario -----
INSERT INTO salario (Id_persona, Cant_hijos, Recibo_Sueldo, Estado_Civil, Familiar) VALUES
 (1, 2, 200000, 'Casado',     26400),
 (2, 3, 150000, 'Divorciado', 39600),
 (3, 0, 150000, 'Soltero',        0),
 (4, 1, 300000, 'Casado',         0);

-- ----- Departamento y Área -----
INSERT INTO departamento (Id_empleado, Localidad, Telefono, CUIL, Categoria, Mail, Nombre) VALUES
 (1,    'S.M. Tucumán', 3698521, 2043706, 'RR.HH',        'dptoRRHH@gmail.com',   'Personal'),
 (2,    'S.M. Tucumán', 3209199, 2058745, 'Ventas',       'dptoVentas@gmail.com', 'Personal'),
 (3,    'S.M. Tucumán', 8541236, 2785462, 'Compras',      'dptoCompras@gmail.com','Personal'),
 (4,    'S.M. Tucumán', 4596321, 2625879, 'Contabilidad', 'dptoCont@gmail.com',   'Sueldos y Jornales'),
 (NULL, 'S.M. Tucumán', 3596223, 2784512, 'Sistemas',     'dptoSist@gmail.com',   'Capacitación'),
 (NULL, 'S.M. Tucumán', 3201547, 2230145, 'RR.HH',        'dptoRRHH@gmail.com',   'Seguridad e Higiene'),
 (NULL, 'S.M. Tucumán', 3305264, 2874596, 'RR.HH',        'dptoRRHH@gmail.com',   'Servicio Medico');

INSERT INTO area (Id_empleado, Id_departamento, Fecha_Ingreso, Fecha_Egreso) VALUES
 (1, 1, '2021-05-05', '2023-04-02'),
 (2, 2, '2019-01-31', '2021-12-20'),
 (3, 3, '2018-06-12', '2023-02-05'),
 (4, 4, '2012-02-05', '2022-07-26');

-- ----- Liquidación de haberes -----
INSERT INTO liquidacion (Id_empleado, Id_puesto_trabajo, Total, Numero) VALUES
 (1, 1, 20000, '2023-01'),
 (2, 2, 15000, '2023-03'),
 (3, 3, 30000, '2022-01'),
 (4, 4, 10000, '2022-05');

INSERT INTO concepto (Monto) VALUES (250000),(200000),(350000),(450000);

INSERT INTO detalle_liquidacion (Id_liquidacion, Id_concepto, Bono, Premio, Fecha_Despido, Descuento, Duracion_Vacaciones, SAC) VALUES
 (1, 1, 2000, 10000, '2022-09-29', 15000, 4, 200000),
 (2, 2, 1500, 15000, '2021-04-01', 10000, 4, 150000),
 (3, 3, 5000, 10000, '2019-03-05', 20000, 4, 100000),
 (4, 4, 6000,  9000, '2020-01-05',  5000, 5,  30000);

SET FOREIGN_KEY_CHECKS = 1;


-- =====================================================================
-- 5) CONSULTAS OBLIGATORIAS (Ejercicio 2)
-- =====================================================================

-- 2.a) Artículos con stock mayor a 1000: código, descripción, depósito y
--      stock de seguridad.
--      Resultado esperado: 'caños' (Deposito1, 300) y 'pegamento para caños' (Deposito4, 780)
SELECT a.Id_articulo,
       a.codigo,
       a.descripcion,
       d.Nombre            AS deposito,
       s.cantidad_articulo AS stock,
       s.stock_seguridad
FROM articulo a
INNER JOIN stock s    ON s.Id_articulo = a.Id_articulo
INNER JOIN deposito d ON d.Id_deposito = s.Id_deposito
WHERE s.cantidad_articulo > 1000;

-- 2.b) Integrantes del grupo familiar de cada empleado.
SELECT e.Id_empleado,
       e.Legajo,
       CONCAT(pe.Nombre, ' ', pe.Apellido)   AS empleado,
       CONCAT(fam.Nombre, ' ', fam.Apellido) AS integrante_grupo_familiar
FROM empleado e
INNER JOIN persona pe                 ON pe.Id_empleado = e.Id_empleado
INNER JOIN grupo_familiar gf          ON gf.Id_empleado = e.Id_empleado
INNER JOIN grupo_familiar_persona gfp ON gfp.Id_GF = gf.Id_GF
INNER JOIN persona fam                ON fam.Id_persona = gfp.Id_persona
ORDER BY e.Id_empleado;

-- 2.c) Informe separado de Clientes y Proveedores con datos de contacto
--      y provincia de residencia.

-- Clientes
SELECT c.Id_cliente,
       c.RazonSocial,
       c.CUIT,
       c.Telefono,
       c.Mail,
       d.calle, d.numero, d.localidad, d.provincia
FROM cliente c
INNER JOIN direccion d ON d.Id_cliente = c.Id_cliente;

-- Proveedores
SELECT p.Id_proveedor,
       p.RazonSocial,
       p.CUIT,
       p.Telefono,
       p.Mail,
       d.calle, d.numero, d.localidad, d.provincia
FROM proveedor p
INNER JOIN direccion d ON d.Id_direccion = p.Id_direccion;

-- 2.d) Empleados con más de 10 años de antigüedad y sueldo menor a $75000.
--      Con los datos cargados el resultado es el empleado 2 (20 años, $15000).
SELECT e.Id_empleado,
       CONCAT(p.Nombre, ' ', p.Apellido) AS empleado,
       e.Legajo,
       e.CUIL,
       a.Cant_Anios                      AS antiguedad_anios,
       l.Total                           AS sueldo
FROM empleado e
INNER JOIN persona p      ON p.Id_empleado = e.Id_empleado
INNER JOIN antiguedad a   ON a.Id_empleado = e.Id_empleado
INNER JOIN liquidacion l  ON l.Id_empleado = e.Id_empleado
WHERE a.Cant_Anios > 10
  AND l.Total < 75000;
