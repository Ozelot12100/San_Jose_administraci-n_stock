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
    public class AreasController : ControllerBase
    {
        private readonly IAreaRepository _areaRepository;

        public AreasController(IAreaRepository areaRepository)
        {
            _areaRepository = areaRepository;
        }

        // GET: api/areas
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AreaDto>>> GetAreas()
        {
            var areas = await _areaRepository.GetAllAsync();
            return Ok(areas.ToDtos());
        }

        // GET: api/areas/activas
        [HttpGet("activas")]
        public async Task<ActionResult<IEnumerable<AreaDto>>> GetAreasActivas()
        {
            var areas = await _areaRepository.GetAreasActivasAsync();
            return Ok(areas.ToDtos());
        }

        // GET: api/areas/5
        [HttpGet("{id}")]
        public async Task<ActionResult<AreaDto>> GetArea(int id)
        {
            var area = await _areaRepository.GetByIdAsync(id);

            if (area == null)
            {
                return NotFound();
            }

            return Ok(area.ToDto());
        }

        // POST: api/areas
        [HttpPost]
        public async Task<ActionResult<AreaDto>> PostArea(AreaDto areaDto)
        {
            var area = areaDto.ToModel();
            await _areaRepository.AddAsync(area);

            return CreatedAtAction(nameof(GetArea), new { id = area.Id }, area.ToDto());
        }

        // PUT: api/areas/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutArea(int id, AreaDto areaDto)
        {
            if (id != areaDto.Id)
            {
                return BadRequest();
            }

            var existingArea = await _areaRepository.GetByIdAsync(id);
            if (existingArea == null)
            {
                return NotFound();
            }

            var area = areaDto.ToModel();
            await _areaRepository.UpdateAsync(area);

            return NoContent();
        }

        // DELETE: api/areas/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteArea(int id)
        {
            var area = await _areaRepository.GetByIdAsync(id);
            if (area == null)
            {
                return NotFound();
            }

            await _areaRepository.DeleteAsync(id);

            return NoContent();
        }
    }
} 