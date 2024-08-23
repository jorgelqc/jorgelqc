-- CREAR BASE DE DATOS
CREATE DATABASE DrinkingTeamDB;

-- POSICIONARME EN LA BASE DE DATOS
USE DrinkingTeamDB;
---------------------------------------------------------------------   
-- CREACION DE TABLAS
---------------------------------------------------------------------

-- Tabla Proveedores
CREATE TABLE Proveedores (
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY, 
    Nombre NVARCHAR(50) NOT NULL,  
    NumeroProveedor INT NOT NULL,   
);

-- Tabla Productos
CREATE TABLE Productos (
    ProductoID INT IDENTITY(1,1) PRIMARY KEY,
    Marca NVARCHAR(100) NOT NULL,  
    Nombre NVARCHAR(100) NOT NULL,  
    Volumen NVARCHAR(100) NOT NULL,   
);

-- Tabla Tiendas
CREATE TABLE Tiendas (
    TiendaID INT IDENTITY(1,1) PRIMARY KEY,
    NumeroTienda NVARCHAR(50) NOT NULL,    
	Ciudad NVARCHAR(50) NOT NULL,      
);

-- Tabla Inventario
CREATE TABLE Inventario (
	InventarioID INT IDENTITY(1,1) PRIMARY KEY,
    ProductoID INT NOT NULL,
	TiendaID INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL, 
    Fecha DATE NOT NULL,     
	Stock INT NOT NULL,      
);

-- Tabla Ventas
CREATE TABLE Ventas (
    VentaID INT IDENTITY(1,1) PRIMARY KEY,
    InventarioID INT NOT NULL,
	ProveedorID INT NOT NULL,
    CantidadVendida INT NOT NULL,   
    TotalVenta DECIMAL(10, 2) NOT NULL,  
    PrecioVenta DECIMAL(10, 2) NOT NULL,   
    FechaVenta DATE NOT NULL,  
);

-- Tabla Compras
CREATE TABLE Compras (
    ComprasID INT IDENTITY(1,1) PRIMARY KEY,
    InventarioID INT NOT NULL,
    ProveedorID INT NOT NULL,
    NumeroOrdenCompra INT NOT NULL,   
    FechaOrdenCompra DATE NOT NULL, 
    FechaRecibido DATE NOT NULL,   
    FechaFacturado DATE NOT NULL,  
	FechaPagado DATE NOT NULL,  
    PrecioCompra DECIMAL(10, 2) NOT NULL,   
	Cantidad INT NOT NULL,   
	TotalCompra DECIMAL(10, 2) NOT NULL,   
);
-----------------------------------------------------------
-- CREACION DE RELACIONES ENTRE TABLAS
-----------------------------------------------------------

-- RELACION ENTRE LA TABLA INVENTARIO Y PRODUCTOS
ALTER TABLE Inventario
ADD CONSTRAINT Fk_Inventario_Productos -- Conecta las tablas
FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID);

-- RELACION ENTRE LA TABLA INVENTARIO Y TIENDAS
ALTER TABLE Inventario
ADD CONSTRAINT Fk_Inventario_Tiendas -- Conecta las tablas
FOREIGN KEY (TiendaID) REFERENCES Tiendas(TiendaID);

-- RELACION ENTRE LA TABLA DE VENTAS E INVENTARIO
ALTER TABLE Ventas
ADD CONSTRAINT Fk_Ventas_Inventario -- Conecta las tablas
FOREIGN KEY (InventarioID) REFERENCES Inventario(InventarioID);

-- RELACION ENTRE LA TABLA DE VENTAS Y PROVEEDOR
ALTER TABLE Ventas
ADD CONSTRAINT Fk_Ventas_Proveedores -- Conecta las tablas
FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID);

-- RELACION ENTRE LA TABLA DE COMPRAS E INVENTARIO
ALTER TABLE Compras
ADD CONSTRAINT Fk_Compras_Inventario -- Conecta las tablas
FOREIGN KEY (InventarioID) REFERENCES Inventario(InventarioID);

-- RELACION ENTRE LA TABLA DE COMPRAS Y PROVEEDOR
ALTER TABLE Compras
ADD CONSTRAINT Fk_Compras_Proveedores -- Conecta las tablas
FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID);
-- CREACION DE LA TABLA `ingestion_control` para controlar la insercion de datos dentro de las tablas maestras
CREATE TABLE ingestion_control (
  id INT IDENTITY(1,1) PRIMARY KEY,
  table_name NVARCHAR(255) NOT NULL,
  last_ingestion_id INT NOT NULL,
  created_at DATETIME DEFAULT GETDATE(),
  updated_at DATETIME DEFAULT GETDATE()
);
-- Creacion del campo dentro de las tablas maestras, en este caso `Tiendas`, `Productos`, `Proveedores`.
ALTER TABLE Tiendas
ADD last_ingestion_id INT ;


ALTER TABLE Productos
ADD last_ingestion_id INT;


ALTER TABLE Proveedores
ADD last_ingestion_id INT;


---------------------------------------------------------------------------
-- Conectar las tablas maestro con la tabla ingestion_control
ALTER TABLE Proveedores
ADD CONSTRAINT Fk_last_ingestion_Proveedores
FOREIGN KEY (last_ingestion_id) REFERENCES ingestion_control(last_ingestion_id);



----------------------------------------------------------------------------
-- Crea un trigger llamado `trg_Tiendas_last_ingestion_id` en la tabla `Tiendas`
CREATE TRIGGER trg_Tiendas_last_ingestion_id
ON Tiendas
AFTER INSERT  -- Se activa después de que se inserte un nuevo registro en la tabla `Tiendas`
AS
BEGIN
    -- Actualiza la columna `last_ingestion_id` en la tabla `Tiendas` con el último ID de la tabla `ingestion_control`
    UPDATE t
    SET t.last_ingestion_id = (SELECT MAX(id) FROM ingestion_control WHERE table_name = 'Tiendas')
    -- Selecciona la tabla `Tiendas` como `t`
    FROM Tiendas t
    -- Realiza un INNER JOIN con la tabla `inserted` que contiene los registros recién insertados
    INNER JOIN inserted i ON t.TiendaID = i.TiendaID;  -- `TiendaID` debe ser la clave primaria real de la tabla `Tiendas`
END;

---- Crea un trigger llamado `trg_Proveedores_last_ingestion_id` en la tabla `Proveedores`
CREATE TRIGGER trg_Proveedores_last_ingestion_id
ON Proveedores
AFTER INSERT -- Se activa después de que se inserte un nuevo registro en la tabla `Tiendas`

AS
BEGIN
    -- Actualiza la columna `last_ingestion_id` en la tabla `Proveedores` con el último ID de la tabla `ingestion_control`
    UPDATE p
    SET p.last_ingestion_id = (SELECT MAX(id) FROM ingestion_control WHERE table_name = 'Proveedores')
    FROM Proveedores p
 -- Realiza un INNER JOIN con la tabla `inserted` que contiene los registros recién insertados
    INNER JOIN inserted i ON p.ProveedorID = i.ProveedorID;  -- `ProveedorID` debe ser la clave primaria real de la tabla `Proveedor`
END;

---- Crea un trigger llamado `trg_Productos_last_ingestion_id` en la tabla `Prodcutos`

-- Productos
CREATE TRIGGER trg_Productos_last_ingestion_id
ON Productos
AFTER INSERT -- Se activa después de que se inserte un nuevo registro en la tabla `Tiendas`
AS
BEGIN
    -- Actualiza la columna last_ingestion_id en la tabla Tiendas con el último id de ingestion_control
    UPDATE p
    SET p.last_ingestion_id = (SELECT MAX(id) FROM ingestion_control WHERE table_name = 'Productos')
    FROM Productos p
	 -- Realiza un INNER JOIN con la tabla `inserted` que contiene los registros recién insertados
    INNER JOIN inserted i ON p.ProductoID = i.ProductoID;  -- `ProductoID` debe ser la clave primaria real de la tabla `Producto`
END;
--------------------------------------------------------------------------------------------------------------

-- Crea un procedimiento almacenado llamado `sp_insert_ingestion_control`
CREATE PROCEDURE sp_insert_ingestion_control
    -- Define dos parámetros de entrada:
    -- @Table_name: un campo de tipo NVARCHAR que almacenará el nombre de la tabla. 
    --              Se ha limitado a un máximo de 255 caracteres.
    -- @last_ingestion_id: un campo de tipo INT que almacenará el último ID de ingesta procesado.
    @Table_name NVARCHAR(255),
    @last_ingestion_id INT
AS
BEGIN
    -- Inserta un nuevo registro en la tabla `ingestion_control`
    -- Los valores para `table_name` y `last_ingestion_id` son proporcionados a través de los parámetros de entrada
    INSERT INTO ingestion_control (table_name, last_ingestion_id)
    VALUES (@Table_name, @last_ingestion_id);
END;
----------------------------------------------------------------------------------------------------


