using ArmeErp.Domain.Entities;
using ArmeErp.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace ArmeErp.Infrastructure.Persistence;

public static class DatabaseSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Verificar si ya hay datos
        if (await context.Clients.AnyAsync())
        {
            return; // Ya hay datos, no hacer seed
        }

        // Seed Clients
        var client1 = new Client
        {
            ClientCode = "CLI-000001",
            CompanyName = "Constructora del Norte S.A. de C.V.",
            ContactName = "Juan Pérez García",
            Email = "juan.perez@constructoranorte.com",
            Phone = "8181234567",
            Mobile = "8112345678",
            Address = "Av. Constitución 1234",
            City = "Monterrey",
            State = "Nuevo León",
            ZipCode = "64000",
            RFC = "CDN850101ABC",
            TaxRegime = "Régimen General",
            ClientType = "corporativo",
            Priority = "high",
            CreditLimit = 5000000,
            CreditDays = 30,
            Notes = "Cliente preferente con historial de pagos puntuales",
            TotalProjects = 0,
            TotalRevenue = 0,
            CreatedAt = DateTime.UtcNow,
            IsDeleted = false
        };

        var client2 = new Client
        {
            ClientCode = "CLI-000002",
            CompanyName = "Almacenes Industriales del Bajío",
            ContactName = "María González López",
            Email = "maria.gonzalez@almabajio.com",
            Phone = "4421234567",
            Mobile = "4422345678",
            Address = "Blvd. Bernardo Quintana 5678",
            City = "Querétaro",
            State = "Querétaro",
            ZipCode = "76000",
            RFC = "AIB900215XYZ",
            TaxRegime = "Régimen General",
            ClientType = "corporativo",
            Priority = "normal",
            CreditLimit = 3000000,
            CreditDays = 45,
            Notes = "Cliente nuevo con buen potencial",
            TotalProjects = 0,
            TotalRevenue = 0,
            CreatedAt = DateTime.UtcNow,
            IsDeleted = false
        };

        await context.Clients.AddRangeAsync(client1, client2);
        await context.SaveChangesAsync();

        // Seed Projects
        var project1 = new Project
        {
            ProjectCode = "PRJ-000001",
            Name = "Nave Industrial Parque Norte",
            Description = "Construcción de nave industrial de 5,000 m² para almacenamiento y distribución",
            Location = "Parque Industrial Norte, Monterrey, N.L.",
            Address = "Carretera a Laredo Km 15",
            City = "Monterrey",
            State = "Nuevo León",
            ClientId = client1.Id,
            Status = ProjectStatus.InProgress,
            ProgressPercentage = 35,
            HealthStatus = "on_track",
            PlannedStartDate = DateTime.UtcNow.AddDays(-60),
            PlannedEndDate = DateTime.UtcNow.AddDays(120),
            ActualStartDate = DateTime.UtcNow.AddDays(-60),
            TotalArea = 5000,
            CoveredArea = 4500,
            ContractAmount = 8500000,
            CurrentBudget = 8500000,
            TotalExpenses = 2975000,
            TotalIncome = 3400000,
            Priority = "high",
            Notes = "Proyecto con especificaciones de altura de 12 metros",
            CreatedAt = DateTime.UtcNow,
            IsDeleted = false
        };

        var project2 = new Project
        {
            ProjectCode = "PRJ-000002",
            Name = "Bodega Logística Querétaro",
            Description = "Nave industrial de 3,500 m² con oficinas administrativas",
            Location = "Parque Industrial Querétaro, Qro.",
            Address = "Av. 5 de Febrero s/n",
            City = "Querétaro",
            State = "Querétaro",
            ClientId = client2.Id,
            Status = ProjectStatus.Planning,
            ProgressPercentage = 10,
            HealthStatus = "on_track",
            PlannedStartDate = DateTime.UtcNow.AddDays(15),
            PlannedEndDate = DateTime.UtcNow.AddDays(150),
            TotalArea = 3500,
            CoveredArea = 3200,
            ContractAmount = 6200000,
            CurrentBudget = 6200000,
            TotalExpenses = 0,
            TotalIncome = 1240000, // Anticipo 20%
            Priority = "normal",
            Notes = "Incluye área de oficinas de 300 m²",
            CreatedAt = DateTime.UtcNow,
            IsDeleted = false
        };

        await context.Projects.AddRangeAsync(project1, project2);
        await context.SaveChangesAsync();

        // Seed Project Stages para Project 1
        var stages = new List<ProjectStage>
        {
            new ProjectStage
            {
                ProjectId = project1.Id,
                StageNumber = 1,
                Name = "Planeación y Permisos",
                Description = "Obtención de permisos y diseño final",
                Status = StageStatus.Completed,
                PlannedStartDate = DateTime.UtcNow.AddDays(-60),
                PlannedEndDate = DateTime.UtcNow.AddDays(-45),
                ActualStartDate = DateTime.UtcNow.AddDays(-60),
                ActualEndDate = DateTime.UtcNow.AddDays(-43),
                ProgressPercentage = 100,
                WeightPercentage = 10,
                EstimatedCost = 850000,
                ActualCost = 820000,
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new ProjectStage
            {
                ProjectId = project1.Id,
                StageNumber = 2,
                Name = "Cimentación",
                Description = "Excavación y construcción de cimientos",
                Status = StageStatus.Completed,
                PlannedStartDate = DateTime.UtcNow.AddDays(-42),
                PlannedEndDate = DateTime.UtcNow.AddDays(-22),
                ActualStartDate = DateTime.UtcNow.AddDays(-42),
                ActualEndDate = DateTime.UtcNow.AddDays(-20),
                ProgressPercentage = 100,
                WeightPercentage = 20,
                EstimatedCost = 1700000,
                ActualCost = 1650000,
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new ProjectStage
            {
                ProjectId = project1.Id,
                StageNumber = 3,
                Name = "Estructura Metálica",
                Description = "Montaje de estructura de acero",
                Status = StageStatus.InProgress,
                PlannedStartDate = DateTime.UtcNow.AddDays(-20),
                PlannedEndDate = DateTime.UtcNow.AddDays(30),
                ActualStartDate = DateTime.UtcNow.AddDays(-20),
                ProgressPercentage = 60,
                WeightPercentage = 30,
                EstimatedCost = 2550000,
                ActualCost = 1500000,
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new ProjectStage
            {
                ProjectId = project1.Id,
                StageNumber = 4,
                Name = "Cubierta y Cerramiento",
                Description = "Instalación de láminas y muros",
                Status = StageStatus.Pending,
                PlannedStartDate = DateTime.UtcNow.AddDays(32),
                PlannedEndDate = DateTime.UtcNow.AddDays(70),
                ProgressPercentage = 0,
                WeightPercentage = 25,
                EstimatedCost = 2125000,
                ActualCost = 0,
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new ProjectStage
            {
                ProjectId = project1.Id,
                StageNumber = 5,
                Name = "Acabados y Entrega",
                Description = "Instalaciones, pisos y entrega final",
                Status = StageStatus.Pending,
                PlannedStartDate = DateTime.UtcNow.AddDays(72),
                PlannedEndDate = DateTime.UtcNow.AddDays(120),
                ProgressPercentage = 0,
                WeightPercentage = 15,
                EstimatedCost = 1275000,
                ActualCost = 0,
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            }
        };

        await context.ProjectStages.AddRangeAsync(stages);
        await context.SaveChangesAsync();

        // Seed Contracts
        var contract1 = new Contract
        {
            ContractCode = "CTR-000001",
            Title = "Contrato de Construcción Nave Industrial Parque Norte",
            Description = "Contrato para construcción llave en mano de nave industrial",
            ProjectId = project1.Id,
            ClientId = client1.Id,
            TotalAmount = 8500000,
            Currency = "MXN",
            ContractDate = DateTime.UtcNow.AddDays(-65),
            StartDate = DateTime.UtcNow.AddDays(-60),
            EndDate = DateTime.UtcNow.AddDays(120),
            SignedDate = DateTime.UtcNow.AddDays(-62),
            Status = ContractStatus.Active,
            PaymentTerms = "40% anticipo, 30% avance de obra, 20% al terminar estructura, 10% contra entrega",
            DeliveryTerms = "180 días naturales a partir de la firma",
            Notes = "Incluye garantía de 2 años en estructura",
            CreatedAt = DateTime.UtcNow,
            IsDeleted = false
        };

        await context.Contracts.AddAsync(contract1);
        await context.SaveChangesAsync();

        // Seed Expenses
        var expenses = new List<Expense>
        {
            new Expense
            {
                ExpenseCode = "EXP-000001",
                ProjectId = project1.Id,
                ExpenseType = ExpenseType.Material,
                Category = "Acero estructural",
                Description = "Compra de vigas y columnas de acero",
                Amount = 1200000,
                Currency = "MXN",
                ExpenseDate = DateTime.UtcNow.AddDays(-40),
                IsBillable = true,
                Notes = "Proveedor: Aceros del Norte",
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new Expense
            {
                ExpenseCode = "EXP-000002",
                ProjectId = project1.Id,
                ExpenseType = ExpenseType.Labor,
                Category = "Mano de obra",
                Description = "Pago de nómina semanal - Semana 6",
                Amount = 185000,
                Currency = "MXN",
                ExpenseDate = DateTime.UtcNow.AddDays(-14),
                IsBillable = true,
                Notes = "15 trabajadores",
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new Expense
            {
                ExpenseCode = "EXP-000003",
                ProjectId = project1.Id,
                ExpenseType = ExpenseType.Equipment,
                Category = "Renta de maquinaria",
                Description = "Renta de grúa telescópica - 2 semanas",
                Amount = 95000,
                Currency = "MXN",
                ExpenseDate = DateTime.UtcNow.AddDays(-7),
                IsBillable = true,
                Notes = "Grúa de 50 toneladas",
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            }
        };

        await context.Expenses.AddRangeAsync(expenses);
        await context.SaveChangesAsync();

        // Seed Payments (Ingresos)
        var payments = new List<Payment>
        {
            new Payment
            {
                PaymentCode = "PAY-000001",
                PaymentType = "income",
                ProjectId = project1.Id,
                ClientId = client1.Id,
                Amount = 3400000, // 40% anticipo
                Currency = "MXN",
                PaymentMethod = PaymentMethod.Transfer,
                PaymentReference = "TRANSF-2024-001",
                BankName = "BBVA Bancomer",
                PaymentDate = DateTime.UtcNow.AddDays(-58),
                ProcessedAt = DateTime.UtcNow.AddDays(-58),
                Status = PaymentStatus.Completed,
                Notes = "Anticipo del 40% según contrato",
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            },
            new Payment
            {
                PaymentCode = "PAY-000002",
                PaymentType = "income",
                ProjectId = project2.Id,
                ClientId = client2.Id,
                Amount = 1240000, // 20% anticipo
                Currency = "MXN",
                PaymentMethod = PaymentMethod.Transfer,
                PaymentReference = "TRANSF-2024-002",
                BankName = "Santander",
                PaymentDate = DateTime.UtcNow.AddDays(-5),
                ProcessedAt = DateTime.UtcNow.AddDays(-5),
                Status = PaymentStatus.Completed,
                Notes = "Anticipo del 20% según contrato",
                CreatedAt = DateTime.UtcNow,
                IsDeleted = false
            }
        };

        await context.Payments.AddRangeAsync(payments);
        await context.SaveChangesAsync();

        // Actualizar totales de clientes
        client1.TotalProjects = 1;
        client1.TotalRevenue = 3400000;
        client2.TotalProjects = 1;
        client2.TotalRevenue = 1240000;

        await context.SaveChangesAsync();
    }
}
