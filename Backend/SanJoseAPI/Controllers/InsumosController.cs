using Microsoft.AspNetCore.Mvc;
using SanJoseAPI.DTOs;
using SanJoseAPI.Helpers;
using SanJoseAPI.Models;
using SanJoseAPI.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;

namespace SanJoseAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class InsumosController : ControllerBase
    {
        private readonly IInsumoRepository _insumoRepository;

        public InsumosController(IInsumoRepository insumoRepository)
        {
            _insumoRepository = insumoRepository;
        }

        // GET: api/insumos
        [HttpGet]
        public async Task<ActionResult<IEnumerable<InsumoDto>>> GetInsumos()
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            return Ok(insumos.ToDtos());
        }

        // GET: api/insumos/5
        [HttpGet("{id}")]
        public async Task<ActionResult<InsumoDto>> GetInsumo(int id)
        {
            var insumo = await _insumoRepository.GetInsumoPorIdConProveedorAsync(id);

            if (insumo == null)
            {
                return NotFound();
            }

            return Ok(insumo.ToDto());
        }

        // GET: api/insumos/caducidad/30
        [HttpGet("caducidad/{dias}")]
        public async Task<ActionResult<IEnumerable<InsumoDto>>> GetInsumosPorCaducidad(int dias)
        {
            var insumos = await _insumoRepository.GetInsumosPorCaducidadAsync(dias);
            return Ok(insumos.ToDtos());
        }

        // GET: api/insumos/bajo-stock
        [HttpGet("bajo-stock")]
        public async Task<ActionResult<IEnumerable<InsumoDto>>> GetInsumosBajoStock([FromQuery] int stockMinimo = 10)
        {
            var insumos = await _insumoRepository.GetInsumosConProveedorAsync();
            var insumosBajoStock = insumos.Where(i => i.Stock < stockMinimo).ToList();
            return Ok(insumosBajoStock.ToDtos());
        }

        // POST: api/insumos
        [HttpPost]
        public async Task<ActionResult<InsumoDto>> PostInsumo(InsumoDto insumoDto)
        {
            var insumo = insumoDto.ToModel();
            await _insumoRepository.AddAsync(insumo);

            return CreatedAtAction(nameof(GetInsumo), new { id = insumo.Id }, insumo.ToDto());
        }

        // PUT: api/insumos/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutInsumo(int id, InsumoDto insumoDto)
        {
            if (id != insumoDto.Id)
            {
                return BadRequest();
            }

            var existingInsumo = await _insumoRepository.GetByIdAsync(id);
            if (existingInsumo == null)
            {
                return NotFound();
            }

            var insumo = insumoDto.ToModel();
            await _insumoRepository.UpdateAsync(insumo);

            return NoContent();
        }

        // DELETE: api/insumos/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteInsumo(int id)
        {
            var insumo = await _insumoRepository.GetByIdAsync(id);
            if (insumo == null)
            {
                return NotFound();
            }

            await _insumoRepository.DeleteAsync(id);

            return NoContent();
        }
    }
} 