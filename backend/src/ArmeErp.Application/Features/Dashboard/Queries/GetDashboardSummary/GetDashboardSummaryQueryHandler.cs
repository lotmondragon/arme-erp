using ArmeErp.Application.DTOs;
using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Enums;
using MediatR;

namespace ArmeErp.Application.Features.Dashboard.Queries.GetDashboardSummary;

public class GetDashboardSummaryQueryHandler : IRequestHandler<GetDashboardSummaryQuery, DashboardSummaryDto>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetDashboardSummaryQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<DashboardSummaryDto> Handle(GetDashboardSummaryQuery request, CancellationToken cancellationToken)
    {
        var projects = await _unitOfWork.Projects.GetAllAsync();
        var clients = await _unitOfWork.Clients.GetAllAsync();
        
        var totalRevenue = projects.Sum(p => p.TotalIncome);
        var totalExpenses = projects.Sum(p => p.TotalExpenses);
        var netProfit = totalRevenue - totalExpenses;
        var profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

        var oneMonthAgo = DateTime.UtcNow.AddMonths(-1);
        var newClientsThisMonth = clients.Count(c => c.CreatedAt >= oneMonthAgo);

        var recentProjects = projects
            .OrderByDescending(p => p.CreatedAt)
            .Take(5)
            .Select(p => new ProjectSummaryDto
            {
                Id = p.Id,
                ProjectCode = p.ProjectCode,
                Name = p.Name,
                ClientName = p.Client?.CompanyName ?? string.Empty,
                Status = p.Status.ToString(),
                ProgressPercentage = p.ProgressPercentage,
                HealthStatus = p.HealthStatus,
                ContractAmount = p.ContractAmount
            })
            .ToList();

        var projectFinancials = projects
            .Where(p => p.Status != ProjectStatus.Cancelled)
            .Select(p => new FinancialSummaryDto
            {
                ProjectId = p.Id,
                ProjectCode = p.ProjectCode,
                ProjectName = p.Name,
                ContractAmount = p.ContractAmount,
                TotalIncome = p.TotalIncome,
                TotalExpenses = p.TotalExpenses,
                NetProfit = p.TotalIncome - p.TotalExpenses,
                ProfitMargin = p.TotalIncome > 0 ? ((p.TotalIncome - p.TotalExpenses) / p.TotalIncome) * 100 : 0
            })
            .ToList();

        return new DashboardSummaryDto
        {
            TotalProjects = projects.Count(),
            ActiveProjects = projects.Count(p => p.Status == ProjectStatus.InProgress),
            PlanningProjects = projects.Count(p => p.Status == ProjectStatus.Planning),
            CompletedProjects = projects.Count(p => p.Status == ProjectStatus.Completed),
            TotalClients = clients.Count(),
            NewClientsThisMonth = newClientsThisMonth,
            TotalRevenue = totalRevenue,
            TotalExpenses = totalExpenses,
            NetProfit = netProfit,
            ProfitMargin = profitMargin,
            PendingReceivables = 0, // TODO: Calculate from invoices
            PendingPayables = 0, // TODO: Calculate from invoices
            RecentProjects = recentProjects,
            ProjectFinancials = projectFinancials
        };
    }
}
