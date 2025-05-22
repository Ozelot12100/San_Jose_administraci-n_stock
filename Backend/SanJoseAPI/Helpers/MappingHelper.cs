using SanJoseAPI.DTOs;
using SanJoseAPI.Models;
using System.Collections.Generic;
using System.Linq;
using System;

namespace SanJoseAPI.Helpers
{
    public static class MappingHelper
    {
        // Mapeo de Area
        public static AreaDto ToDto(this Area model)
        {
            if (model == null) return null;

            return new AreaDto
            {
                Id = model.Id,
                NombreArea = model.NombreArea
            };
        }

        public static Area ToModel(this AreaDto dto)
        {
            if (dto == null) return null;

            return new Area
            {
                Id = dto.Id,
                NombreArea = dto.NombreArea
            };
        }

        public static IEnumerable<AreaDto> ToDtos(this IEnumerable<Area> models)
        {
            return models?.Select(m => m.ToDto());
        }

        // Mapeo de Proveedor
        public static ProveedorDto ToDto(this Proveedor model)
        {
            if (model == null) return null;

            return new ProveedorDto
            {
                Id = model.Id,
                NombreProveedor = model.NombreProveedor,
                Telefono = model.Telefono,
                Direccion = model.Direccion
            };
        }

        public static Proveedor ToModel(this ProveedorDto dto)
        {
            if (dto == null) return null;

            return new Proveedor
            {
                Id = dto.Id,
                NombreProveedor = dto.NombreProveedor,
                Telefono = dto.Telefono,
                Direccion = dto.Direccion
            };
        }

        public static IEnumerable<ProveedorDto> ToDtos(this IEnumerable<Proveedor> models)
        {
            return models?.Select(m => m.ToDto());
        }

        // Mapeo de Insumo
        public static InsumoDto ToDto(this Insumo model)
        {
            if (model == null) return null;

            return new InsumoDto
            {
                Id = model.Id,
                NombreInsumo = model.NombreInsumo,
                Descripcion = model.Descripcion,
                Unidad = model.Unidad,
                Stock = model.Stock,
                StockMinimo = model.StockMinimo,
                IdProveedor = model.IdProveedor,
                Proveedor = model.Proveedor?.ToDto()
            };
        }

        public static Insumo ToModel(this InsumoDto dto)
        {
            if (dto == null) return null;

            return new Insumo
            {
                Id = dto.Id,
                NombreInsumo = dto.NombreInsumo,
                Descripcion = dto.Descripcion,
                Unidad = dto.Unidad,
                Stock = dto.Stock,
                StockMinimo = dto.StockMinimo,
                IdProveedor = dto.IdProveedor
            };
        }

        public static IEnumerable<InsumoDto> ToDtos(this IEnumerable<Insumo> models)
        {
            return models?.Select(m => m.ToDto());
        }

        // Mapeo de Movimiento
        public static MovimientoDto ToDto(this Movimiento model)
        {
            if (model == null) return null;

            return new MovimientoDto
            {
                Id = model.Id,
                TipoMovimiento = model.TipoMovimiento ?? string.Empty,
                Fecha = model.Fecha,
                Cantidad = model.Cantidad,
                IdInsumo = model.IdInsumo,
                IdUsuario = model.IdUsuario,
                IdArea = model.IdArea,
                Insumo = model.Insumo?.ToDto() ?? new InsumoDto { Id = 0, NombreInsumo = string.Empty, Descripcion = string.Empty, Unidad = string.Empty, Stock = 0, StockMinimo = 0 },
                Usuario = model.Usuario != null ? new UsuarioDto { Id = model.Usuario.Id, Usuario = model.Usuario.NombreUsuario ?? string.Empty, Rol = model.Usuario.Rol ?? string.Empty, Activo = model.Usuario.Activo, IdArea = model.Usuario.IdArea ?? 0, Contrasena = string.Empty } : new UsuarioDto { Id = 0, Usuario = string.Empty, Rol = string.Empty, Activo = false, IdArea = 0, Contrasena = string.Empty },
                Area = model.Area?.ToDto() ?? new AreaDto { Id = 0, NombreArea = string.Empty }
            };
        }

        public static Movimiento ToModel(this MovimientoDto dto)
        {
            if (dto == null) return null;
            if (dto.IdArea is int?) {
                if (dto.IdArea == null)
                    throw new ArgumentException("El campo id_area es obligatorio para registrar un movimiento.");
                return new Movimiento
                {
                    Id = dto.Id,
                    TipoMovimiento = dto.TipoMovimiento,
                    Fecha = dto.Fecha,
                    Cantidad = dto.Cantidad,
                    IdInsumo = dto.IdInsumo,
                    IdUsuario = dto.IdUsuario,
                    IdArea = ((int?)dto.IdArea).Value
                };
            } else {
                return new Movimiento
                {
                    Id = dto.Id,
                    TipoMovimiento = dto.TipoMovimiento,
                    Fecha = dto.Fecha,
                    Cantidad = dto.Cantidad,
                    IdInsumo = dto.IdInsumo,
                    IdUsuario = dto.IdUsuario,
                    IdArea = dto.IdArea
                };
            }
        }

        public static IEnumerable<MovimientoDto> ToDtos(this IEnumerable<Movimiento> models)
        {
            return models?.Select(m => m.ToDto());
        }
    }
} 