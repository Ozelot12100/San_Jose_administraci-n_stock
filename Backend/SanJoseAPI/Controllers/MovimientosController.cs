using Microsoft.AspNetCore.Mvc;
using SanJoseAPI.DTOs;
using SanJoseAPI.Helpers;
using SanJoseAPI.Models;
using SanJoseAPI.Repositories;
using SanJoseAPI.Utils;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SanJoseAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MovimientosController : ControllerBase
    {
        private readonly IMovimientoRepository _movimientoRepository;
        private readonly IInsumoRepository _insumoRepository;

        public MovimientosController(IMovimientoRepository movimientoRepository, IInsumoRepository insumoRepository)
        {
            _movimientoRepository = movimientoRepository;
            _insumoRepository = insumoRepository;
        }

        // GET: api/movimientos
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MovimientoDto>>> GetMovimientos()
        {
            var movimientos = await _movimientoRepository.GetMovimientosConDetallesAsync();
            return Ok(movimientos.ToDtos());
        }

        // GET: api/movimientos/5
        [HttpGet("{id}")]
        public async Task<ActionResult<MovimientoDto>> GetMovimiento(int id)
        {
            var movimiento = await _movimientoRepository.GetByIdAsync(id);

            if (movimiento == null)
            {
                return NotFound();
            }

            return Ok(movimiento.ToDto());
        }

        // GET: api/movimientos/insumo/5
        [HttpGet("insumo/{insumoId}")]
        public async Task<ActionResult<IEnumerable<MovimientoDto>>> GetMovimientosPorInsumo(int insumoId)
        {
            var movimientos = await _movimientoRepository.GetMovimientosPorInsumoAsync(insumoId);
            return Ok(movimientos.ToDtos());
        }

        // GET: api/movimientos/area/5
        [HttpGet("area/{areaId}")]
        public async Task<ActionResult<IEnumerable<MovimientoDto>>> GetMovimientosPorArea(int areaId)
        {
            var movimientos = await _movimientoRepository.GetMovimientosPorAreaAsync(areaId);
            return Ok(movimientos.ToDtos());
        }

        // GET: api/movimientos/fecha?inicio=2025-01-01&fin=2025-12-31
        [HttpGet("fecha")]
        public async Task<ActionResult<IEnumerable<MovimientoDto>>> GetMovimientosPorFecha([FromQuery] DateTime inicio, [FromQuery] DateTime fin)
        {
            var movimientos = await _movimientoRepository.GetMovimientosPorFechaAsync(inicio, fin);
            return Ok(movimientos.ToDtos());
        }

        // POST: api/movimientos
        [HttpPost]
        public async Task<ActionResult<MovimientoDto>> PostMovimiento(MovimientoDto movimientoDto)
        {
            // Validación de campos obligatorios
            if (movimientoDto.IdInsumo == 0 || movimientoDto.IdUsuario == 0 || movimientoDto.IdArea == 0)
            {
                return BadRequest("Faltan datos obligatorios para registrar el movimiento (id_insumo, id_usuario o id_area).");
            }

            var insumo = await _insumoRepository.GetByIdAsync(movimientoDto.IdInsumo);
            if (insumo == null)
            {
                return BadRequest(AppConstants.InsumoNoExiste);
            }

            // Validación de tipo_movimiento
            if (movimientoDto.TipoMovimiento != "entrada" && movimientoDto.TipoMovimiento != "salida")
            {
                return BadRequest("El tipo de movimiento debe ser 'entrada' o 'salida'.");
            }

            var movimiento = movimientoDto.ToModel();
            
            // Actualizar el stock del insumo
            if (movimiento.TipoMovimiento == "entrada")
            {
                insumo.Stock += movimiento.Cantidad;
            }
            else // salida
            {
                if (insumo.Stock < movimiento.Cantidad)
                {
                    return BadRequest(AppConstants.InsuficienteStock);
                }
                insumo.Stock -= movimiento.Cantidad;
            }

            // Guardar el movimiento
            await _movimientoRepository.AddAsync(movimiento);
            
            // Actualizar el insumo
            await _insumoRepository.UpdateAsync(insumo);

            return CreatedAtAction(nameof(GetMovimiento), new { id = movimiento.Id }, movimiento.ToDto());
        }

        // DELETE: api/movimientos/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMovimiento(int id)
        {
            var movimiento = await _movimientoRepository.GetByIdAsync(id);
            if (movimiento == null)
            {
                return NotFound();
            }

            // Revertir el cambio en el stock del insumo
            var insumo = await _insumoRepository.GetByIdAsync(movimiento.IdInsumo);
            if (insumo != null)
            {
                if (movimiento.TipoMovimiento == "entrada")
                {
                    // Si fue una entrada, reducimos el stock
                    insumo.Stock -= movimiento.Cantidad;
                }
                else // salida
                {
                    // Si fue una salida, aumentamos el stock
                    insumo.Stock += movimiento.Cantidad;
                }
                await _insumoRepository.UpdateAsync(insumo);
            }

            await _movimientoRepository.DeleteAsync(id);

            return NoContent();
        }
    }
} 