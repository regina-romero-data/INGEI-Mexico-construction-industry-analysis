/****** Object:  Database [plataformasdeanalitica]    Script Date: 14/04/2026 03:20:20 p. m. ******/
CREATE DATABASE [plataformasdeanalitica]  (EDITION = 'GeneralPurpose', SERVICE_OBJECTIVE = 'GP_S_Gen5_1', MAXSIZE = 32 GB) WITH CATALOG_COLLATION = SQL_Latin1_General_CP1_CI_AS, LEDGER = OFF;
GO
ALTER DATABASE [plataformasdeanalitica] SET COMPATIBILITY_LEVEL = 170
GO
ALTER DATABASE [plataformasdeanalitica] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET ARITHABORT OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [plataformasdeanalitica] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [plataformasdeanalitica] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [plataformasdeanalitica] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [plataformasdeanalitica] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [plataformasdeanalitica] SET  MULTI_USER 
GO
ALTER DATABASE [plataformasdeanalitica] SET ENCRYPTION ON
GO
ALTER DATABASE [plataformasdeanalitica] SET QUERY_STORE = ON
GO
ALTER DATABASE [plataformasdeanalitica] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 100, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
/*** Los scripts de las configuraciones con ámbito de base de datos en Azure deben ejecutarse dentro de la conexión de base de datos de destino. ***/
GO
-- ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
GO
/****** Object:  Table [dbo].[DimEstado]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimEstado](
	[Cve_estado_Key] [int] NOT NULL,
	[Estado] [varchar](50) NULL,
	[RegionKey] [int] NOT NULL,
 CONSTRAINT [PK_DimEstado] PRIMARY KEY CLUSTERED 
(
	[Cve_estado_Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRegion](
	[RegionKey] [int] NOT NULL,
	[Región] [varchar](50) NULL,
 CONSTRAINT [PK_DimRegion] PRIMARY KEY CLUSTERED 
(
	[RegionKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_estado_region]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_estado_region] AS
SELECT 
    e.Cve_estado_Key,
    e.Estado,
    r.RegionKey,
    r.Región
FROM dbo.DimEstado e
LEFT JOIN dbo.DimRegion r ON r.RegionKey = e.RegionKey;
GO
/****** Object:  Table [dbo].[FactPIB]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPIB](
	[DateKey] [int] NOT NULL,
	[Cve_estado_Key] [int] NOT NULL,
	[PIB_general] [varchar](50) NULL,
	[PIB_construccion] [varchar](50) NULL,
 CONSTRAINT [PK_FactPIB] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Cve_estado_Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_pib_region_anual]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vw_pib_region_anual] AS
SELECT  f.DateKey AS Anio,
        r.Región,
        SUM(TRY_CONVERT(decimal(18,2), REPLACE(f.PIB_general,       ',', ''))) AS PIB_nacional,
        SUM(TRY_CONVERT(decimal(18,2), REPLACE(f.PIB_construccion,  ',', ''))) AS PIB_construccion
FROM dbo.FactPIB f
JOIN dbo.vw_estado_region r ON r.Cve_estado_Key = f.Cve_estado_Key
GROUP BY f.DateKey, r.Región;
GO
/****** Object:  View [dbo].[vw_PIBConstruccionRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_PIBConstruccionRegion] AS
SELECT 
    r.Región,
    p.DateKey AS Año,
    SUM(CAST(p.PIB_construccion AS FLOAT)) AS PIB_Construccion_Total
FROM FactPIB p
JOIN DimEstado e 
    ON p.Cve_estado_Key = e.Cve_estado_Key
JOIN DimRegion r 
    ON e.RegionKey = r.RegionKey
GROUP BY r.Región, p.DateKey;
GO
/****** Object:  Table [dbo].[FactProductividadEdo]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactProductividadEdo](
	[Cve_estado_Key] [int] NOT NULL,
	[SectorKey] [int] NOT NULL,
	[DateKey] [int] NOT NULL,
	[Valor_prod_total] [varchar](50) NULL,
	[Horas_trabajadas] [varchar](50) NULL,
	[Personal_ocupado_total] [varchar](50) NULL,
 CONSTRAINT [PK_FactProductividadEdo] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Cve_estado_Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_ProductividadRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ProductividadRegion] AS
SELECT 
    r.Región,
    CAST(LEFT(f.DateKey,4) AS INT) AS Año,
    SUM(CAST(f.Valor_prod_total AS FLOAT)) 
        / NULLIF(SUM(CAST(f.Horas_trabajadas AS FLOAT)),0) AS Prod_Hora,
    SUM(CAST(f.Valor_prod_total AS FLOAT)) 
        / NULLIF(SUM(CAST(f.Personal_ocupado_total AS FLOAT)),0) AS Prod_Persona
FROM FactProductividadEdo f
JOIN DimEstado e 
    ON f.Cve_estado_Key = e.Cve_estado_Key
JOIN DimRegion r 
    ON e.RegionKey = r.RegionKey
GROUP BY r.Región, CAST(LEFT(f.DateKey,4) AS INT);
GO
/****** Object:  Table [dbo].[FactPersonalHorasSector]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPersonalHorasSector](
	[DateKey] [int] NOT NULL,
	[SubsectorKey] [int] NOT NULL,
	[Horas_trabajadas] [varchar](50) NULL,
	[Personal_ocupado_total] [varchar](50) NULL,
 CONSTRAINT [PK_FactPersonalHorasSector] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[SubsectorKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimSubsector]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSubsector](
	[SubsectorKey] [int] NOT NULL,
	[NombreSubsector] [varchar](50) NULL,
	[SectorKey] [int] NULL,
 CONSTRAINT [PK_DimSubsector] PRIMARY KEY CLUSTERED 
(
	[SubsectorKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_HorasPersonalSubsector]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_HorasPersonalSubsector] AS
SELECT 
    s.NombreSubsector,
    CAST(LEFT(f.DateKey,4) AS INT) AS Año,
    SUM(CAST(f.Horas_trabajadas AS FLOAT)) AS Total_Horas,
    SUM(CAST(f.Personal_ocupado_total AS FLOAT)) AS Total_Personal
FROM FactPersonalHorasSector f
JOIN DimSubsector s 
    ON f.SubsectorKey = s.SubsectorKey
GROUP BY s.NombreSubsector, CAST(LEFT(f.DateKey,4) AS INT);
GO
/****** Object:  Table [dbo].[FactValorProduccionSector]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactValorProduccionSector](
	[DateKey] [int] NOT NULL,
	[TipoPropiedadKey] [int] NOT NULL,
	[SubsectorKey] [int] NOT NULL,
	[Valor_prod_total] [varchar](50) NULL,
 CONSTRAINT [PK_FactProductividadSector] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[SubsectorKey] ASC,
	[TipoPropiedadKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_ValorProduccionSubsector]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ValorProduccionSubsector] AS
SELECT 
    s.NombreSubsector,
    CAST(LEFT(f.DateKey,4) AS INT) AS Año,
    SUM(CAST(f.Valor_prod_total AS FLOAT)) AS Valor_Produccion
FROM FactValorProduccionSector f
JOIN DimSubsector s 
    ON f.SubsectorKey = s.SubsectorKey
GROUP BY s.NombreSubsector, CAST(LEFT(f.DateKey,4) AS INT);
GO
/****** Object:  Table [dbo].[DimFecha]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimFecha](
	[DateKey] [int] NOT NULL,
	[Año] [varchar](50) NULL,
	[MesNum] [varchar](50) NULL,
	[MesNombre] [varchar](50) NULL,
	[Trimestre] [varchar](50) NULL,
	[TrimNombre] [varchar](50) NULL,
	[SemestreNum] [varchar](50) NULL,
	[SemestreNombre] [varchar](50) NULL,
 CONSTRAINT [PK_DimFecha] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_EficienciaEconomicaPorRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_EficienciaEconomicaPorRegion] AS
SELECT 
    fecha.Año,
    reg.Región,
    FORMAT(SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT)), 'C', 'es-MX') AS Produccion_total,
    FORMAT(SUM(TRY_CAST(pib.PIB_construccion AS FLOAT)), 'C', 'es-MX') AS PIB_total,
    CAST(
        SUM(TRY_CAST(pib.PIB_construccion AS FLOAT)) /
        NULLIF(SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT)), 0)
    AS DECIMAL(10,2)) AS EficienciaEconomica
FROM [dbo].[FactPIB] AS pib
INNER JOIN [dbo].[DimEstado] AS edo 
    ON pib.Cve_estado_Key = edo.Cve_estado_Key
INNER JOIN [dbo].[DimRegion] AS reg 
    ON edo.RegionKey = reg.RegionKey
INNER JOIN [dbo].[FactProductividadEdo] AS prod 
    ON edo.Cve_estado_Key = prod.Cve_estado_Key
INNER JOIN [dbo].[DimFecha] AS fecha
    ON pib.[DateKey] = fecha.[DateKey]
GROUP BY fecha.Año, reg.Región;
GO
/****** Object:  Table [dbo].[FactDenue]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactDenue](
	[DateKey] [int] NOT NULL,
	[id_empresa] [int] NOT NULL,
	[SubsectorKey] [int] NULL,
	[per_ocu] [varchar](50) NULL,
	[tipo_asent] [varchar](50) NULL,
	[cod_postal] [varchar](50) NULL,
	[Cve_estado_Key] [int] NULL,
	[latitud] [varchar](50) NULL,
	[longitud] [varchar](50) NULL,
	[fecha_alta] [varchar](50) NULL,
 CONSTRAINT [PK_FactDenue] PRIMARY KEY CLUSTERED 
(
	[id_empresa] ASC,
	[DateKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_CrecimientoEmpresasPorRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_CrecimientoEmpresasPorRegion] AS
SELECT edo.RegionKey, reg.Región, fecha.Año, COUNT(*) AS TotalEmpresas,
LAG(COUNT(*)) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año) AS EmpresasAñoAnterior,
  CASE WHEN LAG(COUNT(*)) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año) = 0 THEN NULL
  ELSE CAST((COUNT(*) - LAG(COUNT(*)) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año)) * 100.0
            / LAG(COUNT(*)) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año) AS DECIMAL(5,2))
  END AS CambioPorcentual
FROM [dbo].[FactDenue] AS denue
INNER JOIN [dbo].[DimEstado] AS edo
    ON denue.Cve_estado_Key = edo.Cve_estado_Key
INNER JOIN [dbo].[DimRegion] AS reg
    ON edo.RegionKey = reg.RegionKey
INNER JOIN [dbo].[DimFecha] AS fecha
    ON denue.DateKey = fecha.DateKey
GROUP BY
    edo.RegionKey,
    reg.Región,
    fecha.Año;
GO
/****** Object:  View [dbo].[vw_ContribucionPIB_construccion_PorRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ContribucionPIB_construccion_PorRegion] AS
SELECT 
    fecha.Año,
    reg.Región,
    SUM(TRY_CAST(pib.PIB_general AS FLOAT)) AS PIB_Total,
    SUM(TRY_CAST(pib.PIB_construccion AS FLOAT)) AS PIB_Construccion,
    CAST(
        SUM(TRY_CAST(pib.PIB_construccion AS FLOAT)) * 100.0 / 
        NULLIF(SUM(TRY_CAST(pib.PIB_general AS FLOAT)), 0) AS DECIMAL(5,2)
    ) AS Aporte_PIB_Construccion_Porcentaje
FROM [dbo].[FactPIB] AS pib
INNER JOIN [dbo].[DimEstado] AS edo ON pib.Cve_estado_Key = edo.Cve_estado_Key
INNER JOIN [dbo].[DimRegion] AS reg ON edo.RegionKey = reg.RegionKey
INNER JOIN [dbo].[DimFecha] AS fecha ON pib.DateKey = fecha.DateKey
GROUP BY fecha.Año, reg.Región
GO
/****** Object:  View [dbo].[vw_CrecimientoValorProduccionPorRegion]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_CrecimientoValorProduccionPorRegion] AS
SELECT 
    edo.RegionKey,
    reg.Región,
    fecha.Año,
    SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT)) AS ValorProduccion,
    
    -- Valor producción del año anterior
    LAG(SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT))) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año) AS ValorProduccionAnoAnterior,
    
    -- Tasa de crecimiento anual (%)
    CASE 
        WHEN LAG(SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT))) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año) = 0 THEN NULL
        ELSE CAST(
            (SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT)) - 
             LAG(SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT))) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año)
            ) * 100.0 / 
            LAG(SUM(TRY_CAST(prod.Valor_prod_total AS FLOAT))) OVER (PARTITION BY edo.RegionKey ORDER BY fecha.Año)
        AS DECIMAL(5,2))
    END AS TasaCrecimientoAnual
FROM [dbo].[FactProductividadEdo] AS prod
INNER JOIN [dbo].[DimEstado] AS edo
    ON prod.Cve_estado_Key = edo.Cve_estado_Key
INNER JOIN [dbo].[DimRegion] AS reg
    ON edo.RegionKey = reg.RegionKey
INNER JOIN [dbo].[DimFecha] AS fecha
    ON prod.DateKey = fecha.DateKey
GROUP BY
    edo.RegionKey,
    reg.Región,
    fecha.Año;
GO
/****** Object:  View [dbo].[vw_ProduccionPorEmpresaTrabajador]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ProduccionPorEmpresaTrabajador] AS
SELECT 
    reg.Región, 
    FORMAT(SUM(CAST(prod.[Valor_prod_total] AS FLOAT)), 'C', 'es-MX') AS ProduccionTotal,
    COUNT(DISTINCT [id_empresa]) AS NumEmpresas, 
    SUM(CAST(prod.[Personal_ocupado_total] AS BIGINT)) AS TotalTrabajadores,
    FORMAT(SUM(CAST(prod.[Valor_prod_total] AS FLOAT))/COUNT(DISTINCT [id_empresa]), 'C', 'es-MX') AS ProduccionPorEmpresa,
    FORMAT(SUM(CAST(prod.[Valor_prod_total] AS FLOAT))/SUM(CAST(prod.[Personal_ocupado_total] AS BIGINT)), 'C', 'es-MX') AS ProduccionPorTrabajador
FROM [dbo].[FactProductividadEdo] AS prod
INNER JOIN [dbo].[DimEstado] AS edo ON prod.[Cve_estado_Key]=edo.[Cve_estado_Key]
INNER JOIN [dbo].[DimRegion] AS reg ON edo.[RegionKey]=reg.[RegionKey]
INNER JOIN [dbo].[FactDenue] AS denue ON edo.[Cve_estado_Key]=denue.[Cve_estado_Key]
GROUP BY reg.Región;
GO
/****** Object:  View [dbo].[vw_PIBConstruccionEstado]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_PIBConstruccionEstado] AS
SELECT 
    e.Estado,
    p.DateKey AS Año,
    SUM(CAST(p.PIB_construccion AS FLOAT)) AS PIB_Construccion_Total
FROM dbo.FactPIB p
JOIN dbo.DimEstado e 
    ON p.Cve_estado_Key = e.Cve_estado_Key
GROUP BY e.Estado, p.DateKey;
GO
/****** Object:  Table [dbo].[DimSector]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSector](
	[SectorKey] [int] NOT NULL,
	[Nombre_sector] [varchar](50) NULL,
 CONSTRAINT [PK_DimSector] PRIMARY KEY CLUSTERED 
(
	[SectorKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimTipoPropiedad]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTipoPropiedad](
	[TipoPropiedadKey] [int] NOT NULL,
	[Tipo_propiedad] [varchar](50) NULL,
 CONSTRAINT [PK_DimTipoPropiedad] PRIMARY KEY CLUSTERED 
(
	[TipoPropiedadKey] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactCostosEdo]    Script Date: 14/04/2026 03:20:20 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCostosEdo](
	[DateKey] [int] NOT NULL,
	[Cve_estado_Key] [int] NOT NULL,
	[SectorKey] [int] NOT NULL,
	[RemuneracionesTotales] [varchar](50) NULL,
	[RemuneracionesMediasPorPersona] [varchar](50) NULL,
	[RemuneracionesMediasPorHora] [varchar](50) NULL,
	[ConsumoMateriales] [varchar](50) NULL,
 CONSTRAINT [PK_FactCostosEdo] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC,
	[Cve_estado_Key] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DimEstado]  WITH CHECK ADD  CONSTRAINT [FK_DimEstado_RegionKey] FOREIGN KEY([RegionKey])
REFERENCES [dbo].[DimRegion] ([RegionKey])
GO
ALTER TABLE [dbo].[DimEstado] CHECK CONSTRAINT [FK_DimEstado_RegionKey]
GO
ALTER TABLE [dbo].[DimSubsector]  WITH CHECK ADD  CONSTRAINT [FK_DimSubsector_SectorKey] FOREIGN KEY([SectorKey])
REFERENCES [dbo].[DimSector] ([SectorKey])
GO
ALTER TABLE [dbo].[DimSubsector] CHECK CONSTRAINT [FK_DimSubsector_SectorKey]
GO
ALTER TABLE [dbo].[FactCostosEdo]  WITH CHECK ADD  CONSTRAINT [FK_FactCostosEdo_Cve_estado_Key] FOREIGN KEY([Cve_estado_Key])
REFERENCES [dbo].[DimEstado] ([Cve_estado_Key])
GO
ALTER TABLE [dbo].[FactCostosEdo] CHECK CONSTRAINT [FK_FactCostosEdo_Cve_estado_Key]
GO
ALTER TABLE [dbo].[FactCostosEdo]  WITH CHECK ADD  CONSTRAINT [FK_FactCostosEdo_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimFecha] ([DateKey])
GO
ALTER TABLE [dbo].[FactCostosEdo] CHECK CONSTRAINT [FK_FactCostosEdo_DateKey]
GO
ALTER TABLE [dbo].[FactCostosEdo]  WITH CHECK ADD  CONSTRAINT [FK_FactCostosEdo_SectorKey] FOREIGN KEY([SectorKey])
REFERENCES [dbo].[DimSector] ([SectorKey])
GO
ALTER TABLE [dbo].[FactCostosEdo] CHECK CONSTRAINT [FK_FactCostosEdo_SectorKey]
GO
ALTER TABLE [dbo].[FactDenue]  WITH CHECK ADD  CONSTRAINT [FK_FactDenue_Cve_estado_Key] FOREIGN KEY([Cve_estado_Key])
REFERENCES [dbo].[DimEstado] ([Cve_estado_Key])
GO
ALTER TABLE [dbo].[FactDenue] CHECK CONSTRAINT [FK_FactDenue_Cve_estado_Key]
GO
ALTER TABLE [dbo].[FactDenue]  WITH CHECK ADD  CONSTRAINT [FK_FactDenue_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimFecha] ([DateKey])
GO
ALTER TABLE [dbo].[FactDenue] CHECK CONSTRAINT [FK_FactDenue_DateKey]
GO
ALTER TABLE [dbo].[FactDenue]  WITH CHECK ADD  CONSTRAINT [FK_FactDenue_SubsectorKey] FOREIGN KEY([SubsectorKey])
REFERENCES [dbo].[DimSubsector] ([SubsectorKey])
GO
ALTER TABLE [dbo].[FactDenue] CHECK CONSTRAINT [FK_FactDenue_SubsectorKey]
GO
ALTER TABLE [dbo].[FactPersonalHorasSector]  WITH CHECK ADD  CONSTRAINT [FK_FactPersonalHorasSector_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimFecha] ([DateKey])
GO
ALTER TABLE [dbo].[FactPersonalHorasSector] CHECK CONSTRAINT [FK_FactPersonalHorasSector_DateKey]
GO
ALTER TABLE [dbo].[FactPersonalHorasSector]  WITH CHECK ADD  CONSTRAINT [FK_FactPersonalHorasSector_SubsectorKey] FOREIGN KEY([SubsectorKey])
REFERENCES [dbo].[DimSubsector] ([SubsectorKey])
GO
ALTER TABLE [dbo].[FactPersonalHorasSector] CHECK CONSTRAINT [FK_FactPersonalHorasSector_SubsectorKey]
GO
ALTER TABLE [dbo].[FactPIB]  WITH CHECK ADD  CONSTRAINT [FK_FactPIB_Cve_estado_Key] FOREIGN KEY([Cve_estado_Key])
REFERENCES [dbo].[DimEstado] ([Cve_estado_Key])
GO
ALTER TABLE [dbo].[FactPIB] CHECK CONSTRAINT [FK_FactPIB_Cve_estado_Key]
GO
ALTER TABLE [dbo].[FactPIB]  WITH CHECK ADD  CONSTRAINT [FK_FactPIB_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimFecha] ([DateKey])
GO
ALTER TABLE [dbo].[FactPIB] CHECK CONSTRAINT [FK_FactPIB_DateKey]
GO
ALTER TABLE [dbo].[FactProductividadEdo]  WITH CHECK ADD  CONSTRAINT [FK_FactProductividadEdo_Cve_estado_Key] FOREIGN KEY([Cve_estado_Key])
REFERENCES [dbo].[DimEstado] ([Cve_estado_Key])
GO
ALTER TABLE [dbo].[FactProductividadEdo] CHECK CONSTRAINT [FK_FactProductividadEdo_Cve_estado_Key]
GO
ALTER TABLE [dbo].[FactProductividadEdo]  WITH CHECK ADD  CONSTRAINT [FK_FactProductividadEdo_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimFecha] ([DateKey])
GO
ALTER TABLE [dbo].[FactProductividadEdo] CHECK CONSTRAINT [FK_FactProductividadEdo_DateKey]
GO
ALTER TABLE [dbo].[FactProductividadEdo]  WITH CHECK ADD  CONSTRAINT [FK_FactProductividadEdo_SectorKey] FOREIGN KEY([SectorKey])
REFERENCES [dbo].[DimSector] ([SectorKey])
GO
ALTER TABLE [dbo].[FactProductividadEdo] CHECK CONSTRAINT [FK_FactProductividadEdo_SectorKey]
GO
ALTER TABLE [dbo].[FactValorProduccionSector]  WITH CHECK ADD  CONSTRAINT [FK_FactValorProduccion_SubsectorKey] FOREIGN KEY([SubsectorKey])
REFERENCES [dbo].[DimSubsector] ([SubsectorKey])
GO
ALTER TABLE [dbo].[FactValorProduccionSector] CHECK CONSTRAINT [FK_FactValorProduccion_SubsectorKey]
GO
ALTER TABLE [dbo].[FactValorProduccionSector]  WITH CHECK ADD  CONSTRAINT [FK_FactValorProduccion_TipoPropiedadKey] FOREIGN KEY([TipoPropiedadKey])
REFERENCES [dbo].[DimTipoPropiedad] ([TipoPropiedadKey])
GO
ALTER TABLE [dbo].[FactValorProduccionSector] CHECK CONSTRAINT [FK_FactValorProduccion_TipoPropiedadKey]
GO
ALTER TABLE [dbo].[FactValorProduccionSector]  WITH CHECK ADD  CONSTRAINT [FK_FactValorProduccionSector_DateKey] FOREIGN KEY([DateKey])
REFERENCES [dbo].[DimFecha] ([DateKey])
GO
ALTER TABLE [dbo].[FactValorProduccionSector] CHECK CONSTRAINT [FK_FactValorProduccionSector_DateKey]
GO
ALTER DATABASE [plataformasdeanalitica] SET  READ_WRITE 
GO
