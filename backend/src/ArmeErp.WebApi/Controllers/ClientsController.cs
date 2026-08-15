using ArmeErp.Application.DTOs;
using ArmeErp.Application.Features.Clients.Commands.CreateClient;
using ArmeErp.Application.Features.Clients.Commands.DeleteClient;
using ArmeErp.Application.Features.Clients.Commands.UpdateClient;
using ArmeErp.Application.Features.Clients.Queries.GetAllClients;
using ArmeErp.Application.Features.Clients.Queries.GetClientById;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ArmeErp.WebApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Policy = "Authenticated")]
public class ClientsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ClientsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ClientDto>>> GetAll(CancellationToken cancellationToken)
    {
        var clients = await _mediator.Send(new GetAllClientsQuery(), cancellationToken);
        return Ok(clients);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<ClientDto>> GetById(Guid id, CancellationToken cancellationToken)
    {
        var client = await _mediator.Send(new GetClientByIdQuery(id), cancellationToken);
        
        if (client == null)
            return NotFound(new { message = $"Client with ID {id} not found" });

        return Ok(client);
    }

    [HttpPost]
    public async Task<ActionResult<ClientDto>> Create([FromBody] CreateClientDto dto, CancellationToken cancellationToken)
    {
        var command = new CreateClientCommand(
            dto.CompanyName,
            dto.ContactName,
            dto.Email,
            dto.Phone,
            dto.Address,
            dto.TaxId
        );

        var client = await _mediator.Send(command, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = client.Id }, client);
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult<ClientDto>> Update(Guid id, [FromBody] UpdateClientDto dto, CancellationToken cancellationToken)
    {
        if (id != dto.Id)
            return BadRequest(new { message = "ID mismatch" });

        try
        {
            var command = new UpdateClientCommand(
                dto.Id,
                dto.CompanyName,
                dto.ContactName,
                dto.Email,
                dto.Phone,
                dto.Address,
                dto.TaxId
            );

            var client = await _mediator.Send(command, cancellationToken);
            return Ok(client);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> Delete(Guid id, CancellationToken cancellationToken)
    {
        var result = await _mediator.Send(new DeleteClientCommand(id), cancellationToken);
        
        if (!result)
            return NotFound(new { message = $"Client with ID {id} not found" });

        return NoContent();
    }
}
