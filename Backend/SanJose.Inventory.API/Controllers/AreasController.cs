using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SanJose.Inventory.Core.DTOs;
using SanJose.Inventory.Core.Services;

namespace SanJose.Inventory.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AreasController : ControllerBase
{
    private readonly IAreaService _areaService;

    public AreasController(IAreaService areaService)
    {
        _areaService = areaService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<AreaDTO>>> GetAll()
    {
        var areas = await _areaService.GetAllAsync();
        return Ok(areas);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<AreaDTO>> GetById(int id)
    {
        var area = await _areaService.GetByIdAsync(id);
        if (area == null)
        {
            return NotFound(new { mensaje = "Área no encontrada" });
        }

        return Ok(area);
    }

    [HttpPost]
    [Authorize(Roles = "admin")]
    public async Task<ActionResult<AreaDTO>> Create([FromBody] CreateAreaDTO areaDto)
    {
        try
        {
            var area = await _areaService.CreateAsync(areaDto);
            return CreatedAtAction(nameof(GetById), new { id = area.Id }, area);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { mensaje = ex.Message });
        }
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAreaDTO areaDto)
    {
        try
        {
            await _areaService.UpdateAsync(id, areaDto);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { mensaje = "Área no encontrada" });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { mensaje = ex.Message });
        }
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            await _areaService.DeleteAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { mensaje = "Área no encontrada" });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { mensaje = ex.Message });
        }
    }
} 