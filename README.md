# TFI Gestión de Datos: Modelo relacional y base de datos SQL

Trabajo Final Integrador de la cátedra **Gestión de Datos** (Ingeniería en Sistemas de Información, UTN Facultad Regional Tucumán, comisión 3k3, cuatrimestre 2023.01).

El proyecto diseña e implementa una base de datos relacional que integra cuatro módulos de una empresa: **Compras, Ventas, RRHH y Liquidación de Haberes**. Incluye el modelo entidad-relación, el script de creación con datos de prueba y las consultas SQL pedidas por la cátedra.

![MySQL](https://img.shields.io/badge/MySQL-8.x-4479A1?logo=mysql&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-compatible-003545?logo=mariadb&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-DDL%20%2F%20DML-blue)

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `TFI_GDD.sql` | Script completo: creación de la base `TFI_GDD`, 44 tablas, claves foráneas, datos de prueba y consultas obligatorias |
| `TFI_GDD.pdf` | Informe del trabajo: consigna, diagramas del modelo por módulo, consultas y capturas de resultados |

## Módulos del modelo

La base tiene **44 tablas** relacionadas entre sí mediante claves primarias y foráneas.

| Módulo | Tablas principales |
|---|---|
| **Compras** | `sector`, `rubro`, `proveedor`, `articulo`, `stock`, `deposito`, `remito`, `pedido`, `cotizacion`, `orden_compra`, `linea_orden_compra`, `factura`, `linea_factura`, `pago`, `forma_pago`, `direccion` |
| **Ventas** | `cliente`, `sucursal`, `orden_venta`, y las tablas intermedias `articulo_rubro`, `articulo_stock`, `stock_deposito`, `orden_venta_sucursal` |
| **RRHH** | `empleado`, `persona`, `grupo_familiar`, `grupo_familiar_persona`, `antiguedad`, `puesto_trabajo`, `titulo`, `tipo_titulo`, `curso`, `accidente`, `revision`, `analisis`, `departamento`, `area`, `salario` y sus tablas intermedias |
| **Liquidación de Haberes** | `liquidacion`, `concepto`, `detalle_liquidacion` |

Los diagramas de cada módulo están en el PDF.

## Requisitos

- MySQL 8.x o MariaDB 10.x
- Cualquier cliente SQL: MySQL Workbench, DBeaver, DbSchema o la línea de comandos

## Instalación

### Desde la terminal

```bash
mysql -u root -p < TFI_GDD.sql
```

### Desde MySQL Workbench

1. Conectarse al servidor local.
2. `File → Open SQL Script` y elegir `TFI_GDD.sql`.
3. Ejecutar el script completo con el botón del rayo.

### Desde DBeaver

1. Abrir un editor SQL sobre la conexión y cargar `TFI_GDD.sql`.
2. Ejecutar el script completo con `Alt + X`.

> El script elimina y vuelve a crear la base `TFI_GDD` en cada ejecución, por lo que se puede correr cuantas veces haga falta.

Para comprobar que la carga fue correcta:

```sql
USE TFI_GDD;
SELECT * FROM articulo;   -- debe devolver 4 filas
```

## Consultas obligatorias

Las cuatro consultas del Ejercicio 2 están al final de `TFI_GDD.sql`.

**a) Artículos con stock mayor a 1000** (código, descripción, depósito y stock de seguridad)

```sql
SELECT a.Id_articulo, a.codigo, a.descripcion,
       d.Nombre AS deposito, s.cantidad_articulo AS stock, s.stock_seguridad
FROM articulo a
INNER JOIN stock s    ON s.Id_articulo = a.Id_articulo
INNER JOIN deposito d ON d.Id_deposito = s.Id_deposito
WHERE s.cantidad_articulo > 1000;
```

Resultado esperado: `caños` (Deposito1) y `pegamento para caños` (Deposito4).

**b) Integrantes del grupo familiar de cada empleado**

Une `empleado`, `persona`, `grupo_familiar` y `grupo_familiar_persona` para mostrar cada empleado junto a sus familiares.

**c) Informe separado de clientes y proveedores**

Dos consultas independientes con razón social, CUIT, teléfono, mail, domicilio y provincia de residencia.

**d) Empleados con más de 10 años de antigüedad y sueldo menor a $75.000**

```sql
SELECT e.Id_empleado, e.Legajo, e.CUIL,
       a.Cant_Anios AS antiguedad_anios, l.Total AS sueldo
FROM empleado e
INNER JOIN antiguedad a  ON a.Id_empleado = e.Id_empleado
INNER JOIN liquidacion l ON l.Id_empleado = e.Id_empleado
WHERE a.Cant_Anios > 10 AND l.Total < 75000;
```

## Decisiones de diseño

- **Claves foráneas completas** entre módulos, con relaciones N:M resueltas mediante tablas intermedias de clave primaria compuesta.
- **Referencias circulares** (por ejemplo `factura` ↔ `pago`, `stock` ↔ `deposito`): el script desactiva temporalmente `FOREIGN_KEY_CHECKS` durante la carga y lo reactiva al terminar.
- **Identificadores sin tildes ni caracteres especiales** (`antiguedad`, `anio`) para garantizar compatibilidad entre motores y sistemas operativos.
- **Datos de prueba** coherentes con las relaciones, que permiten responder todas las consultas del trabajo.

## Autores

- Gerez, Juan Pablo
- Salazar, Ana Carolina

**Profesores:** Lemir, Carlos y Fraga, Álvaro
**Universidad Tecnológica Nacional, Facultad Regional Tucumán**

---

*Proyecto académico. Los datos contenidos son de prueba.*
