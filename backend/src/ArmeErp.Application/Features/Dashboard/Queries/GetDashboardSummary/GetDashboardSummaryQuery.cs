using ArmeErp.Application.DTOs;
using MediatR;

namespace ArmeErp.Application.Features.Dashboard.Queries.GetDashboardSummary;

public record GetDashboardSummaryQuery : IRequest<DashboardSummaryDto>;
