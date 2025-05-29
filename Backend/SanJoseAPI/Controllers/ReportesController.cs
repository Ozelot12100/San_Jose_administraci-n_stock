using Microsoft.AspNetCore.Mvc;
using SanJoseAPI.Repositories;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using iTextSharp.text;
using iTextSharp.text.pdf;
using System.IO;

namespace SanJoseAPI.Controllers
{
    [ApiController]
    [Route("api/reportes")]
    public class ReportesController : ControllerBase
    {
        private readonly IInsumoRepository _insumoRepository;
        private readonly IMovimientoRepository _movimientoRepository;

        public ReportesController(IInsumoRepository insumoRepository, IMovimientoRepository movimientoRepository)
        {
            _insumoRepository = insumoRepository;
            _movimientoRepository = movimientoRepository;
        }

        // GET: api/reportes/inventario/csv
        [HttpGet("inventario/csv")]
        public async Task<IActionResult> GetInventarioCsv()
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var sb = new StringBuilder();
            sb.AppendLine("ID,Nombre,Descripción,Unidad,Stock,Stock Mínimo,Proveedor");
            foreach (var insumo in insumos)
            {
                var proveedor = insumo.Proveedor != null ? insumo.Proveedor.NombreProveedor : "";
                sb.AppendLine($"{insumo.Id},\"{insumo.NombreInsumo}\",\"{insumo.Descripcion}\",{insumo.Unidad},{insumo.Stock},{insumo.StockMinimo},\"{proveedor}\"");
            }
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            return File(bytes, "text/csv", "inventario_actual.csv");
        }

        // ENDPOINTS PARA PDF Y EXCEL (estructura base, puedes implementar la lógica de generación de archivo después)
        [HttpGet("inventario/pdf")]
        public async Task<IActionResult> GetInventarioPdf()
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            using (var ms = new MemoryStream())
            {
                var doc = new Document(PageSize.A4);
                var writer = PdfWriter.GetInstance(doc, ms);
                doc.Open();
                var table = new PdfPTable(7) { WidthPercentage = 100 };
                var headers = new[] { "ID", "Nombre", "Descripción", "Unidad", "Stock", "Stock Mínimo", "Proveedor" };
                foreach (var h in headers) table.AddCell(new Phrase(h));
                foreach (var insumo in insumos)
                {
                    table.AddCell(insumo.Id.ToString());
                    table.AddCell(insumo.NombreInsumo ?? "");
                    table.AddCell(insumo.Descripcion ?? "");
                    table.AddCell(insumo.Unidad ?? "");
                    table.AddCell(insumo.Stock.ToString());
                    table.AddCell(insumo.StockMinimo.ToString());
                    table.AddCell(insumo.Proveedor?.NombreProveedor ?? "");
                }
                doc.Add(table);
                doc.Close();
                var bytes = ms.ToArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/pdf", $"reporte_inventario_{fechaStr}.pdf");
            }
        }

        [HttpGet("inventario/excel")]
        public async Task<IActionResult> GetInventarioExcel()
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            OfficeOpenXml.ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using (var package = new OfficeOpenXml.ExcelPackage())
            {
                var ws = package.Workbook.Worksheets.Add("Inventario");
                var headers = new[] { "ID", "Nombre", "Descripción", "Unidad", "Stock", "Stock Mínimo", "Proveedor" };
                for (int i = 0; i < headers.Length; i++)
                    ws.Cells[1, i + 1].Value = headers[i];
                int row = 2;
                foreach (var insumo in insumos)
                {
                    ws.Cells[row, 1].Value = insumo.Id;
                    ws.Cells[row, 2].Value = insumo.NombreInsumo ?? string.Empty;
                    ws.Cells[row, 3].Value = insumo.Descripcion ?? string.Empty;
                    ws.Cells[row, 4].Value = insumo.Unidad ?? string.Empty;
                    ws.Cells[row, 5].Value = insumo.Stock;
                    ws.Cells[row, 6].Value = insumo.StockMinimo;
                    ws.Cells[row, 7].Value = insumo.Proveedor?.NombreProveedor ?? string.Empty;
                    row++;
                }
                ws.Cells[ws.Dimension.Address].AutoFitColumns();
                var bytes = package.GetAsByteArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"reporte_inventario_{fechaStr}.xlsx");
            }
        }

        [HttpGet("inventario")]
        public async Task<IActionResult> GetInventarioJson()
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var datos = insumos.Select(insumo => new {
                id = insumo.Id,
                nombre = insumo.NombreInsumo ?? string.Empty,
                descripcion = insumo.Descripcion ?? string.Empty,
                unidad = insumo.Unidad ?? string.Empty,
                stock = insumo.Stock,
                stockMinimo = insumo.StockMinimo,
                proveedor = insumo.Proveedor?.NombreProveedor ?? string.Empty
            }).ToList();
            return Ok(new {
                titulo = "Inventario Actual",
                datos
            });
        }

        [HttpGet("movimientos")]
        public async Task<IActionResult> GetMovimientosPorPeriodo([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            // Ajustar inicio a las 00:00:00 y fin a las 23:59:59
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);

            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            var datos = movimientos.Select(m => new {
                fecha = m.Fecha.ToString("yyyy-MM-dd HH:mm"),
                insumo = m.Insumo?.NombreInsumo ?? "",
                tipo = m.TipoMovimiento,
                cantidad = m.Cantidad,
                area = m.Area?.NombreArea ?? "",
                usuario = m.Usuario?.NombreUsuario ?? ""
            }).ToList();

            return Ok(new {
                titulo = "Movimientos por Período",
                datos
            });
        }

        [HttpGet("movimientos/csv")]
        public async Task<IActionResult> GetMovimientosCsv([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            var sb = new StringBuilder();
            sb.AppendLine("Fecha,Insumo,Tipo,Cantidad,Área,Usuario");
            foreach (var m in movimientos)
            {
                sb.AppendLine($"{m.Fecha:yyyy-MM-dd HH:mm},\"{m.Insumo?.NombreInsumo}\",{m.TipoMovimiento},{m.Cantidad},\"{m.Area?.NombreArea}\",\"{m.Usuario?.NombreUsuario}\"");
            }
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
            return File(bytes, "text/csv", $"reporte_movimientos_{fechaStr}.csv");
        }

        [HttpGet("movimientos/excel")]
        public async Task<IActionResult> GetMovimientosExcel([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            OfficeOpenXml.ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using (var package = new OfficeOpenXml.ExcelPackage())
            {
                var ws = package.Workbook.Worksheets.Add("Movimientos");
                var headers = new[] { "Fecha", "Insumo", "Tipo", "Cantidad", "Área", "Usuario" };
                for (int i = 0; i < headers.Length; i++)
                    ws.Cells[1, i + 1].Value = headers[i];
                int row = 2;
                foreach (var m in movimientos)
                {
                    ws.Cells[row, 1].Value = m.Fecha.ToString("yyyy-MM-dd HH:mm");
                    ws.Cells[row, 2].Value = m.Insumo?.NombreInsumo ?? string.Empty;
                    ws.Cells[row, 3].Value = m.TipoMovimiento;
                    ws.Cells[row, 4].Value = m.Cantidad;
                    ws.Cells[row, 5].Value = m.Area?.NombreArea ?? string.Empty;
                    ws.Cells[row, 6].Value = m.Usuario?.NombreUsuario ?? string.Empty;
                    row++;
                }
                ws.Cells[ws.Dimension.Address].AutoFitColumns();
                var bytes = package.GetAsByteArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"reporte_movimientos_{fechaStr}.xlsx");
            }
        }

        [HttpGet("movimientos/pdf")]
        public async Task<IActionResult> GetMovimientosPdf([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            using (var ms = new MemoryStream())
            {
                var doc = new Document(PageSize.A4.Rotate());
                var writer = PdfWriter.GetInstance(doc, ms);
                doc.Open();
                var table = new PdfPTable(6) { WidthPercentage = 100 };
                var headers = new[] { "Fecha", "Insumo", "Tipo", "Cantidad", "Área", "Usuario" };
                foreach (var h in headers) table.AddCell(new Phrase(h));
                foreach (var m in movimientos)
                {
                    table.AddCell(m.Fecha.ToString("yyyy-MM-dd HH:mm"));
                    table.AddCell(m.Insumo?.NombreInsumo ?? "");
                    table.AddCell(m.TipoMovimiento);
                    table.AddCell(m.Cantidad.ToString());
                    table.AddCell(m.Area?.NombreArea ?? "");
                    table.AddCell(m.Usuario?.NombreUsuario ?? "");
                }
                doc.Add(table);
                doc.Close();
                var bytes = ms.ToArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/pdf", $"reporte_movimientos_{fechaStr}.pdf");
            }
        }

        [HttpGet("bajo-stock")]
        public async Task<IActionResult> GetBajoStockJson([FromQuery] int umbral = 10)
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var bajoStock = insumos.Where(i => i.Stock < umbral).ToList();
            var datos = bajoStock.Select(i => new {
                id = i.Id,
                nombre = i.NombreInsumo ?? string.Empty,
                descripcion = i.Descripcion ?? string.Empty,
                unidad = i.Unidad ?? string.Empty,
                stock = i.Stock,
                stockMinimo = i.StockMinimo,
                proveedor = i.Proveedor?.NombreProveedor ?? string.Empty
            }).ToList();
            return Ok(new {
                titulo = "Insumos con Bajo Stock",
                datos
            });
        }

        [HttpGet("bajo-stock/csv")]
        public async Task<IActionResult> GetBajoStockCsv([FromQuery] int umbral = 10)
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var bajoStock = insumos.Where(i => i.Stock < umbral).ToList();
            var sb = new StringBuilder();
            sb.AppendLine("ID,Nombre,Descripción,Unidad,Stock,Stock Mínimo,Proveedor");
            foreach (var i in bajoStock)
            {
                sb.AppendLine($"{i.Id},\"{i.NombreInsumo}\",\"{i.Descripcion}\",{i.Unidad},{i.Stock},{i.StockMinimo},\"{i.Proveedor?.NombreProveedor}\"");
            }
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
            return File(bytes, "text/csv", $"reporte_bajo_stock_{fechaStr}.csv");
        }

        [HttpGet("bajo-stock/excel")]
        public async Task<IActionResult> GetBajoStockExcel([FromQuery] int umbral = 10)
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var bajoStock = insumos.Where(i => i.Stock < umbral).ToList();
            OfficeOpenXml.ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using (var package = new OfficeOpenXml.ExcelPackage())
            {
                var ws = package.Workbook.Worksheets.Add("BajoStock");
                var headers = new[] { "ID", "Nombre", "Descripción", "Unidad", "Stock", "Stock Mínimo", "Proveedor" };
                for (int i = 0; i < headers.Length; i++)
                    ws.Cells[1, i + 1].Value = headers[i];
                int row = 2;
                foreach (var i in bajoStock)
                {
                    ws.Cells[row, 1].Value = i.Id;
                    ws.Cells[row, 2].Value = i.NombreInsumo ?? string.Empty;
                    ws.Cells[row, 3].Value = i.Descripcion ?? string.Empty;
                    ws.Cells[row, 4].Value = i.Unidad ?? string.Empty;
                    ws.Cells[row, 5].Value = i.Stock;
                    ws.Cells[row, 6].Value = i.StockMinimo;
                    ws.Cells[row, 7].Value = i.Proveedor?.NombreProveedor ?? string.Empty;
                    row++;
                }
                ws.Cells[ws.Dimension.Address].AutoFitColumns();
                var bytes = package.GetAsByteArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"reporte_bajo_stock_{fechaStr}.xlsx");
            }
        }

        [HttpGet("bajo-stock/pdf")]
        public async Task<IActionResult> GetBajoStockPdf([FromQuery] int umbral = 10)
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var bajoStock = insumos.Where(i => i.Stock < umbral).ToList();
            using (var ms = new MemoryStream())
            {
                var doc = new Document(PageSize.A4);
                var writer = PdfWriter.GetInstance(doc, ms);
                doc.Open();
                var table = new PdfPTable(7) { WidthPercentage = 100 };
                var headers = new[] { "ID", "Nombre", "Descripción", "Unidad", "Stock", "Stock Mínimo", "Proveedor" };
                foreach (var h in headers) table.AddCell(new Phrase(h));
                foreach (var i in bajoStock)
                {
                    table.AddCell(i.Id.ToString());
                    table.AddCell(i.NombreInsumo ?? "");
                    table.AddCell(i.Descripcion ?? "");
                    table.AddCell(i.Unidad ?? "");
                    table.AddCell(i.Stock.ToString());
                    table.AddCell(i.StockMinimo.ToString());
                    table.AddCell(i.Proveedor?.NombreProveedor ?? "");
                }
                doc.Add(table);
                doc.Close();
                var bytes = ms.ToArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/pdf", $"reporte_bajo_stock_{fechaStr}.pdf");
            }
        }

        // --- REPORTE DE CONSUMO POR ÁREAS ---
        // GET: api/reportes/consumo-areas
        [HttpGet("consumo-areas")]
        public async Task<IActionResult> GetConsumoAreasJson([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            var datos = movimientos
                .Where(m => m.TipoMovimiento == "salida")
                .Select(m => new {
                    fecha = m.Fecha.ToString("yyyy-MM-dd HH:mm"),
                    area = m.Area?.NombreArea ?? "Sin Área",
                    insumo = m.Insumo?.NombreInsumo ?? "Sin Insumo",
                    cantidad = m.Cantidad
                }).ToList();
            return Ok(new {
                titulo = "Consumo de Insumos por Áreas (Detalle)",
                datos = datos
            });
        }

        // GET: api/reportes/consumo-areas/csv
        [HttpGet("consumo-areas/csv")]
        public async Task<IActionResult> GetConsumoAreasCsv([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            var datos = movimientos
                .Where(m => m.TipoMovimiento == "salida")
                .Select(m => new {
                    fecha = m.Fecha.ToString("yyyy-MM-dd HH:mm"),
                    area = m.Area?.NombreArea ?? "Sin Área",
                    insumo = m.Insumo?.NombreInsumo ?? "Sin Insumo",
                    cantidad = m.Cantidad
                }).ToList();
            var sb = new StringBuilder();
            sb.AppendLine("Fecha,Área,Insumo,Cantidad Consumida");
            foreach (var row in datos)
            {
                sb.AppendLine($"{row.fecha},\"{row.area}\",\"{row.insumo}\",{row.cantidad}");
            }
            var bytes = Encoding.UTF8.GetBytes(sb.ToString());
            var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
            return File(bytes, "text/csv", $"reporte_consumo_areas_{fechaStr}.csv");
        }

        // GET: api/reportes/consumo-areas/excel
        [HttpGet("consumo-areas/excel")]
        public async Task<IActionResult> GetConsumoAreasExcel([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            var datos = movimientos
                .Where(m => m.TipoMovimiento == "salida")
                .Select(m => new {
                    fecha = m.Fecha.ToString("yyyy-MM-dd HH:mm"),
                    area = m.Area?.NombreArea ?? "Sin Área",
                    insumo = m.Insumo?.NombreInsumo ?? "Sin Insumo",
                    cantidad = m.Cantidad
                }).ToList();
            OfficeOpenXml.ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;
            using (var package = new OfficeOpenXml.ExcelPackage())
            {
                var ws = package.Workbook.Worksheets.Add("ConsumoPorAreas");
                var headers = new[] { "Fecha", "Área", "Insumo", "Cantidad Consumida" };
                for (int i = 0; i < headers.Length; i++)
                    ws.Cells[1, i + 1].Value = headers[i];
                int row = 2;
                foreach (var d in datos)
                {
                    ws.Cells[row, 1].Value = d.fecha;
                    ws.Cells[row, 2].Value = d.area;
                    ws.Cells[row, 3].Value = d.insumo;
                    ws.Cells[row, 4].Value = d.cantidad;
                    row++;
                }
                ws.Cells[ws.Dimension.Address].AutoFitColumns();
                var bytes = package.GetAsByteArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", $"reporte_consumo_areas_{fechaStr}.xlsx");
            }
        }

        // GET: api/reportes/consumo-areas/pdf
        [HttpGet("consumo-areas/pdf")]
        public async Task<IActionResult> GetConsumoAreasPdf([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var fechaInicio = new DateTime(inicio.Year, inicio.Month, inicio.Day, 0, 0, 0);
            var fechaFin = new DateTime(fin.Year, fin.Month, fin.Day, 23, 59, 59);
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(fechaInicio, fechaFin);
            var datos = movimientos
                .Where(m => m.TipoMovimiento == "salida")
                .Select(m => new {
                    fecha = m.Fecha.ToString("yyyy-MM-dd HH:mm"),
                    area = m.Area?.NombreArea ?? "Sin Área",
                    insumo = m.Insumo?.NombreInsumo ?? "Sin Insumo",
                    cantidad = m.Cantidad
                }).ToList();
            using (var ms = new MemoryStream())
            {
                var doc = new iTextSharp.text.Document(iTextSharp.text.PageSize.A4.Rotate());
                var writer = iTextSharp.text.pdf.PdfWriter.GetInstance(doc, ms);
                doc.Open();
                var table = new iTextSharp.text.pdf.PdfPTable(4) { WidthPercentage = 100 };
                var headers = new[] { "Fecha", "Área", "Insumo", "Cantidad Consumida" };
                foreach (var h in headers) table.AddCell(new iTextSharp.text.Phrase(h));
                foreach (var d in datos)
                {
                    table.AddCell(d.fecha);
                    table.AddCell(d.area);
                    table.AddCell(d.insumo);
                    table.AddCell(d.cantidad.ToString());
                }
                doc.Add(table);
                doc.Close();
                var bytes = ms.ToArray();
                var fechaStr = DateTime.Now.ToString("yyyy-MM-dd");
                return File(bytes, "application/pdf", $"reporte_consumo_areas_{fechaStr}.pdf");
            }
        }
    }
}
