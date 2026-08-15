using ArmeErp.Domain.Entities;

namespace ArmeErp.Application.Interfaces;

public interface IUnitOfWork : IDisposable
{
    IRepository<Client> Clients { get; }
    IRepository<Project> Projects { get; }
    IRepository<Budget> Budgets { get; }
    IRepository<BudgetItem> BudgetItems { get; }
    IRepository<Invoice> Invoices { get; }
    
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync(CancellationToken cancellationToken = default);
    Task CommitTransactionAsync(CancellationToken cancellationToken = default);
    Task RollbackTransactionAsync(CancellationToken cancellationToken = default);
}
