using Microsoft.AspNetCore.Mvc;
using SanJoseAPI.DTOs;
using SanJoseAPI.Helpers;
using SanJoseAPI.Models;
using SanJoseAPI.Repositories;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SanJoseAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProveedoresController : ControllerBase
    {
        private readonly IProveedorRepository _proveedorRepository;

        public ProveedoresController(IProveedorRepository proveedorRepository)
        {
            _proveedorRepository = proveedorRepository;
        }

        // GET: api/proveedores
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProveedorDto>>> GetProveedores()
        {
            var proveedores = await _proveedorRepository.GetAllAsync();
            return Ok(proveedores.ToDtos());
        }

        // GET: api/proveedores/5
        [HttpGet("{id}")]
        public async Task<ActionResult<ProveedorDto>> GetProveedor(int id)
        {
            var proveedor = await _proveedorRepository.GetByIdAsync(id);

            if (proveedor == null)
            {
                return NotFound();
            }

            return Ok(proveedor.ToDto());
        }

        // POST: api/proveedores
        [HttpPost]
        public async Task<ActionResult<ProveedorDto>> PostProveedor(ProveedorDto proveedorDto)
        {
            var proveedor = proveedorDto.ToModel();
            await _proveedorRepository.AddAsync(proveedor);

            return CreatedAtAction(nameof(GetProveedor), new { id = proveedor.Id }, proveedor.ToDto());
        }

        // PUT: api/proveedores/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutProveedor(int id, ProveedorDto proveedorDto)
        {
            if (id != proveedorDto.Id)
            {
                return BadRequest();
            }

            var existingProveedor = await _proveedorRepository.GetByIdAsync(id);
            if (existingProveedor == null)
            {
                return NotFound();
            }

            var proveedor = proveedorDto.ToModel();
            await _proveedorRepository.UpdateAsync(proveedor);

            return NoContent();
        }

        // DELETE: api/proveedores/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProveedor(int id)
        {
            var proveedor = await _proveedorRepository.GetByIdAsync(id);
            if (proveedor == null)
            {
                return NotFound();
            }

            await _proveedorRepository.DeleteAsync(id);

            return NoContent();
        }
    }
} 