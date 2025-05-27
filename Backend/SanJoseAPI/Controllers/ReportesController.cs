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

        public ReportesController(IInsumoRepository insumoRepository)
        {
            _insumoRepository = insumoRepository;
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
    }
}
