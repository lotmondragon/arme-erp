using ArmeErp.Application.Interfaces;
using ArmeErp.Domain.Entities;
using ArmeErp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore.Storage;

namespace ArmeErp.Infrastructure.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private IDbContextTransaction? _transaction;
    
    private IRepository<Client>? _clients;
    private IRepository<Project>? _projects;
    private IRepository<Budget>? _budgets;
    private IRepository<BudgetItem>? _budgetItems;
    private IRepository<Invoice>? _invoices;

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
    }

    public IRepository<Client> Clients => _clients ??= new Repository<Client>(_context);
    public IRepository<Project> Projects => _projects ??= new Repository<Project>(_context);
    public IRepository<Budget> Budgets => _budgets ??= new Repository<Budget>(_context);
    public IRepository<BudgetItem> BudgetItems => _budgetItems ??= new Repository<BudgetItem>(_context);
    public IRepository<Invoice> Invoices => _invoices ??= new Repository<Invoice>(_context);

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
    {
        _transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
    }

    public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.CommitAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
    {
        if (_transaction != null)
        {
            await _transaction.RollbackAsync(cancellationToken);
            await _transaction.DisposeAsync();
            _transaction = null;
        }
    }

    public void Dispose()
    {
        _transaction?.Dispose();
        _context.Dispose();
    }
}
